-- Migration 9 (housekeeping): pin the search_path on public.match_chunks so
-- the security advisor stops flagging function_search_path_mutable. We
-- explicitly include both `public` (chunk lives there) and `extensions`
-- (vector type + operators live there).

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
language sql
stable
set search_path = public, extensions
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
