begin;

-- Content-link execution authenticates the immutable prepared source census.
-- Existing tenant RLS remains authoritative; preparation writes retain their owner.
grant select on retrieval.chunking_procedure_version, retrieval.chunk_set,
  retrieval.retrieval_chunk, retrieval.chunk_span to executor_service;

commit;
