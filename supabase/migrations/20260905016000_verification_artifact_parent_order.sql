-- Preserve canonical parent ordering as part of immutable handle identity.
begin;
alter table orchestration.verification_artifact_metadata
 add column if not exists parent_artifact_ids uuid[] not null default '{}';
comment on column orchestration.verification_artifact_metadata.parent_artifact_ids is
 'Ordered immutable parent IDs as serialized in the verification artifact handle; normalized lineage edges remain authoritative relations.';
commit;
