-- Bind vector-store identity to the immutable durable operation that created it.
begin;

alter table retrieval.vector_store
  add column created_by_operation_id uuid,
  add constraint vector_store_created_by_operation_uq unique(tenant_id,created_by_operation_id),
  add constraint vector_store_created_by_operation_fk foreign key(tenant_id,created_by_operation_id)
    references knowledge_service.operation(tenant_id,id) on delete restrict;

create function retrieval.reject_vector_store_identity_mutation() returns trigger
language plpgsql set search_path='' as $$
begin
  raise exception 'vector store identity and ownership are immutable' using errcode='55000';
end $$;

create trigger vector_store_identity_immutable
before update of tenant_id,id,owner_identity,store_class,slug,created_by_operation_id
on retrieval.vector_store for each row execute function retrieval.reject_vector_store_identity_mutation();

create trigger vector_store_delete_forbidden before delete
on retrieval.vector_store for each row execute function retrieval.reject_vector_store_identity_mutation();

commit;
