begin;

create index source_query_response_artifact_idx
  on evidence.source_query (response_artifact_id)
  where response_artifact_id is not null;

create index source_retrieval_capture_idx
  on evidence.source_retrieval (capture_id)
  where capture_id is not null;

create index source_support_locator_idx
  on evidence.source_support (locator_id)
  where locator_id is not null;

commit;
