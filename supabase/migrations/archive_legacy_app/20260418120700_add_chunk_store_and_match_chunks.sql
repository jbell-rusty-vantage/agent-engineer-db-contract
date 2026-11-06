-- Migration 8 (Slice D): chunk store + match_chunks hybrid retrieval RPC.
--
-- Single table for every kind of unstructured document we ingest (video
-- summaries, transcript segments, repo READMEs, paper sections, dossiers,
-- reports, news bodies, course modules, …). Source kind enumerated via a
-- check constraint so we can extend without altering the table; metadata
-- jsonb carries entity slugs / IDs / topic tags / event for filtered RAG.
--
-- The match_chunks RPC does hybrid retrieval via Reciprocal Rank Fusion of
-- HNSW vector search and FTS, optionally constrained by a metadata @> filter
-- and a source_kinds array. Returns rows + the rrf_score so callers can trim
-- or weight further.

create table if not exists public.chunk (
  chunk_id          uuid primary key default gen_random_uuid(),
  source_kind       text not null,
  source_id         text not null,
  ord               int  not null default 0,
  content           text not null,
  content_hash      text not null,
  embedding         extensions.vector(1536),
  tsv               tsvector generated always as (to_tsvector('english', content)) stored,
  metadata          jsonb not null default '{}'::jsonb,
  token_count       int,
  char_offset_start int,
  char_offset_end   int,
  created_at        timestamptz not null default timezone('utc', now()),
  updated_at        timestamptz not null default timezone('utc', now()),
  constraint chunk_source_kind_check check (source_kind in (
    'video_summary','video_transcript_segment','video_description','video_chapter',
    'session_description',
    'doc_page','repo_readme','repo_example','repo_doc',
    'paper_abstract','paper_section',
    'slide','dossier','report_section','news_item_body','module_body','custom'
  ))
);

create unique index if not exists chunk_source_ord_uniq
  on public.chunk (source_kind, source_id, ord);
create unique index if not exists chunk_content_hash_uniq
  on public.chunk (source_kind, source_id, content_hash);
create index if not exists chunk_embedding_hnsw on public.chunk
  using hnsw (embedding extensions.vector_cosine_ops) where embedding is not null;
create index if not exists chunk_tsv_gin on public.chunk using gin (tsv);
create index if not exists chunk_metadata_gin on public.chunk using gin (metadata jsonb_path_ops);
create index if not exists chunk_source_kind_idx on public.chunk (source_kind);
create index if not exists chunk_source_lookup_idx on public.chunk (source_kind, source_id);

drop trigger if exists set_chunk_updated_at on public.chunk;
create trigger set_chunk_updated_at before update on public.chunk
  for each row execute procedure public.set_updated_at();

alter table public.chunk enable row level security;
drop policy if exists "chunk_public_read" on public.chunk;
create policy "chunk_public_read" on public.chunk for select using (true);

comment on table public.chunk is
  'Unstructured-document chunk store. One row per chunk of any source artifact (video summary / transcript / repo README / paper section / dossier / report / news / module). source_kind + source_id + ord uniquely identifies a chunk; metadata jsonb carries entity slugs and tags for filtered RAG.';
comment on column public.chunk.source_kind is
  'Enumerated artifact kind. Extend the check constraint when new artifact kinds appear.';
comment on column public.chunk.source_id is
  'Foreign-key-shaped reference to the source row (video_id / repo_slug / paper_slug / news_item_id / report_id / etc.). Not enforced as a real FK because source_kind picks the table.';
comment on column public.chunk.metadata is
  'Open-ended JSONB pocket for entity slugs/IDs and tags (org_slugs, person_slugs, library_slugs, category, domain_layer, event, published_at, url, ...). Filterable via metadata @> filter and indexed via GIN(jsonb_path_ops).';
comment on column public.chunk.content_hash is
  'sha256 of normalized content. Combined with (source_kind, source_id) for dedup on re-ingestion.';

-- ============================================================================
-- match_chunks RPC: hybrid retrieval via Reciprocal Rank Fusion.
-- ============================================================================
create or replace function public.match_chunks(
  query_embedding   extensions.vector(1536),
  query_text        text default null,
  filter            jsonb default '{}'::jsonb,
  source_kinds      text[] default null,
  match_count       int   default 12,
  full_text_weight  float default 1.0,
  semantic_weight   float default 1.0,
  rrf_k             int   default 50
)
returns table (
  chunk_id     uuid,
  source_kind  text,
  source_id    text,
  ord          int,
  content      text,
  metadata     jsonb,
  rrf_score    float
)
language sql stable
as $$
  with semantic as (
    select c.chunk_id,
           row_number() over (order by c.embedding <=> query_embedding) as rank_ix
    from public.chunk c
    where c.embedding is not null
      and query_embedding is not null
      and c.metadata @> coalesce(filter, '{}'::jsonb)
      and (source_kinds is null or c.source_kind = any(source_kinds))
    order by c.embedding <=> query_embedding
    limit greatest(match_count, 30) * 2
  ),
  full_text as (
    select c.chunk_id,
           row_number() over (
             order by ts_rank_cd(c.tsv, websearch_to_tsquery('english', query_text)) desc
           ) as rank_ix
    from public.chunk c
    where query_text is not null
      and c.tsv @@ websearch_to_tsquery('english', query_text)
      and c.metadata @> coalesce(filter, '{}'::jsonb)
      and (source_kinds is null or c.source_kind = any(source_kinds))
    limit greatest(match_count, 30) * 2
  )
  select c.chunk_id, c.source_kind, c.source_id, c.ord, c.content, c.metadata,
         (coalesce(1.0 / (rrf_k + s.rank_ix), 0.0) * semantic_weight
          + coalesce(1.0 / (rrf_k + f.rank_ix), 0.0) * full_text_weight)::float as rrf_score
  from public.chunk c
  left join semantic  s on s.chunk_id = c.chunk_id
  left join full_text f on f.chunk_id = c.chunk_id
  where s.chunk_id is not null or f.chunk_id is not null
  order by rrf_score desc
  limit least(match_count, 50);
$$;

grant execute on function public.match_chunks(
  extensions.vector(1536), text, jsonb, text[], int, float, float, int
) to anon, authenticated, service_role;

comment on function public.match_chunks(
  extensions.vector(1536), text, jsonb, text[], int, float, float, int
) is
  'Hybrid retrieval over public.chunk via Reciprocal Rank Fusion of HNSW vector search and FTS. Supports metadata @> filter and source_kinds array filter (both AND-combined, both optional). Returns chunk rows + rrf_score; semantic_weight / full_text_weight tune the relative contribution and rrf_k smooths top-rank dominance.';
