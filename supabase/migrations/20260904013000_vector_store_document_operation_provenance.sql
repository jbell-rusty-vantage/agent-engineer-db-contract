-- Atomic vector-store document attachment with durable operation provenance.
begin;

alter table retrieval.vector_store_document
  add column created_by_operation_id uuid,
  add constraint vector_store_document_operation_document_uq unique(tenant_id,created_by_operation_id,document_id),
  add constraint vector_store_document_created_by_operation_fk foreign key(tenant_id,created_by_operation_id)
    references knowledge_service.operation(tenant_id,id) on delete restrict;

-- The first slice has no removal/tombstone implementation yet. Prevent two
-- independently admitted active memberships for the same document while still
-- leaving the lifecycle model able to admit a replacement after tombstoning.
create unique index vector_store_document_active_membership_uq
  on retrieval.vector_store_document(tenant_id,vector_store_id,document_id)
  where lifecycle='active';

create function retrieval.reject_vector_store_document_identity_mutation() returns trigger
language plpgsql set search_path='' as $$
begin
  raise exception 'vector store document identity is immutable' using errcode='55000';
end $$;

create trigger vector_store_document_identity_immutable before update of
  tenant_id,id,vector_store_id,document_id,document_version_id,representation_id,requested_profile,created_by_operation_id
on retrieval.vector_store_document for each row execute function retrieval.reject_vector_store_document_identity_mutation();

commit;
