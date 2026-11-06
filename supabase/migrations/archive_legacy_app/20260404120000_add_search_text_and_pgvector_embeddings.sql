-- Semantic search: denormalized search_text + pgvector embedding column per entity.
-- Embedding dimension 1536 matches OpenAI text-embedding-3-small and text-embedding-ada-002.
-- If you use text-embedding-3-large (3072), alter column types and recreate indexes.

create extension if not exists vector with schema extensions;

alter table organization
  add column if not exists search_text text,
  add column if not exists embedding extensions.vector(1536);

alter table person
  add column if not exists search_text text,
  add column if not exists embedding extensions.vector(1536);

alter table session
  add column if not exists search_text text,
  add column if not exists embedding extensions.vector(1536);

alter table youtube_video
  add column if not exists search_text text,
  add column if not exists embedding extensions.vector(1536);

-- HNSW + cosine distance; partial index skips null embeddings until backfill completes.
create index if not exists organization_embedding_hnsw_idx
  on organization using hnsw (embedding extensions.vector_cosine_ops)
  where embedding is not null;

create index if not exists person_embedding_hnsw_idx
  on person using hnsw (embedding extensions.vector_cosine_ops)
  where embedding is not null;

create index if not exists session_embedding_hnsw_idx
  on session using hnsw (embedding extensions.vector_cosine_ops)
  where embedding is not null;

create index if not exists youtube_video_embedding_hnsw_idx
  on youtube_video using hnsw (embedding extensions.vector_cosine_ops)
  where embedding is not null;

comment on column organization.search_text is 'Concatenated / curated text for embedding; ingest from app or script.';
comment on column organization.embedding is 'Vector of search_text; OpenAI-compatible 1536-dim; query with <=> via RPC.';
comment on column person.search_text is 'Concatenated / curated text for embedding; ingest from app or script.';
comment on column person.embedding is 'Vector of search_text; OpenAI-compatible 1536-dim; query with <=> via RPC.';
comment on column session.search_text is 'Concatenated / curated text for embedding; ingest from app or script.';
comment on column session.embedding is 'Vector of search_text; OpenAI-compatible 1536-dim; query with <=> via RPC.';
comment on column youtube_video.search_text is 'Concatenated / curated text for embedding; ingest from app or script.';
comment on column youtube_video.embedding is 'Vector of search_text; OpenAI-compatible 1536-dim; query with <=> via RPC.';
