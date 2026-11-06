-- Verification-specific metadata augments the shared artifact registry without
-- creating a second artifact service or duplicating object identity.
begin;

create table orchestration.verification_artifact_metadata(
 tenant_id uuid not null default util.default_tenant_id(),
 artifact_id uuid not null,
 producer_activity_id text not null check(btrim(producer_activity_id)<>''),
 producer_version text not null check(btrim(producer_version)<>''),
 content_encoding text,
 encryption_class text not null check(btrim(encryption_class)<>''),
 retention_class text not null check(btrim(retention_class)<>''),
 data_classification text not null check(data_classification in('public','internal','confidential','restricted')),
 parent_artifact_ids uuid[] not null default '{}',
 transformation_signature text check(transformation_signature is null or transformation_signature ~ '^[0-9a-f]{64}$'),
 attestation_artifact_id uuid,
 created_at timestamptz not null default now(),
 primary key(tenant_id,artifact_id),
 foreign key(tenant_id,artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict,
 foreign key(tenant_id,attestation_artifact_id) references orchestration.artifact(tenant_id,id) on delete restrict
);

create trigger verification_artifact_metadata_immutable before update or delete
 on orchestration.verification_artifact_metadata for each row execute function util.reject_mutation();
alter table orchestration.verification_artifact_metadata enable row level security;
create policy bounded_role_access on orchestration.verification_artifact_metadata for all
 to executor_service,pipeline_agent,verifier_agent,control_plane,app_reader
 using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id());
grant select,insert on orchestration.verification_artifact_metadata to executor_service,verifier_agent,control_plane;

comment on table orchestration.verification_artifact_metadata is
 'Immutable verification.v1 metadata for an artifact whose canonical identity remains orchestration.artifact.';

commit;
