-- Converge already-migrated installations with the revised, unpublished initial
-- verification migrations. Preserve legacy identities and every existing handle.
begin;
set local lock_timeout='10s';
set local statement_timeout='120s';

lock table orchestration.artifact, orchestration.verification_artifact_metadata
 in access exclusive mode;
alter table orchestration.artifact add column if not exists verification_contract_version text;
alter table orchestration.artifact add constraint artifact_verification_contract_version_ck
 check(verification_contract_version is null or verification_contract_version='verification.v1');

-- Only metadata-backed records are candidates. Refuse incomplete provenance or
-- non-CAS candidates instead of silently reclassifying or rewriting their bytes.
do $$
begin
 if exists(select 1 from orchestration.verification_artifact_metadata m
  where (cardinality(m.parent_artifact_ids)>0 and m.transformation_signature is null)
   or cardinality(m.parent_artifact_ids)<>(select count(distinct id) from unnest(m.parent_artifact_ids) p(id))
   or m.artifact_id=any(m.parent_artifact_ids) or m.artifact_id=m.attestation_artifact_id
 ) then raise exception 'verification marker backfill requires signed distinct non-self parents'
  using errcode='check_violation'; end if;
 if exists(
  select 1 from orchestration.verification_artifact_metadata m
  join orchestration.artifact a on a.tenant_id=m.tenant_id and a.id=m.artifact_id
  where a.storage_bucket is distinct from 'ai-engineer-cloud-bucket'
   or a.object_path !~ ('^'||a.tenant_id::text||'/[0-9a-f]{2}/[0-9a-f]{64}$')
   or split_part(a.object_path,'/',2)<>left(a.sha256,2)
   or split_part(a.object_path,'/',3)<>a.sha256
   or a.media_type is null or btrim(a.media_type)='' or a.size_bytes is null or a.size_bytes<0
 ) then raise exception 'verification marker backfill requires valid CAS metadata-backed artifacts'
  using errcode='check_violation'; end if;
 if exists(
  select 1 from orchestration.verification_artifact_metadata m
  cross join lateral unnest(m.parent_artifact_ids ||
   case when m.attestation_artifact_id is null then '{}'::uuid[] else array[m.attestation_artifact_id] end) p(id)
  where not exists(select 1 from orchestration.artifact a
   join orchestration.verification_artifact_metadata pm on pm.tenant_id=a.tenant_id and pm.artifact_id=a.id
   where a.tenant_id=m.tenant_id and a.id=p.id and a.storage_state='available')
 ) then raise exception 'verification marker backfill requires available metadata-backed parents and attestations'
  using errcode='foreign_key_violation'; end if;
 if exists(select 1 from orchestration.verification_artifact_metadata m
  cross join lateral unnest(m.parent_artifact_ids) p(id)
  where not exists(select 1 from orchestration.artifact_lineage l
   where l.tenant_id=m.tenant_id and l.from_artifact_id=m.artifact_id and l.to_artifact_id=p.id
    and l.relation_kind='generated' and l.activity_id=m.producer_activity_id
    and l.activity_version=m.producer_version and l.transformation_signature=m.transformation_signature)
 ) then raise exception 'verification marker backfill requires exact generated parent lineage'
  using errcode='foreign_key_violation'; end if;
 if exists(select 1 from orchestration.artifact_lineage l
  join orchestration.verification_artifact_metadata m on m.tenant_id=l.tenant_id and m.artifact_id=l.from_artifact_id
  where l.relation_kind in('generated','derived_from','quoted_from')
   and (not(l.to_artifact_id=any(m.parent_artifact_ids))
    or l.activity_id is distinct from m.producer_activity_id
    or l.activity_version is distinct from m.producer_version
    or l.transformation_signature is distinct from m.transformation_signature)
 ) then raise exception 'verification marker backfill found incompatible parent lineage'
  using errcode='check_violation'; end if;
 if exists(
  with recursive edges as (
   select m.tenant_id,m.artifact_id,p.id as parent_id
   from orchestration.verification_artifact_metadata m
   cross join lateral unnest(m.parent_artifact_ids ||
    case when m.attestation_artifact_id is null then '{}'::uuid[] else array[m.attestation_artifact_id] end) p(id)
  ), walk as (
   select e.tenant_id,e.artifact_id,e.parent_id,array[e.artifact_id,e.parent_id] as path,
    e.artifact_id=e.parent_id as cyclic from edges e
   union all
   select w.tenant_id,w.artifact_id,e.parent_id,w.path||e.parent_id,e.parent_id=any(w.path)
    from walk w join edges e on e.tenant_id=w.tenant_id and e.artifact_id=w.parent_id
    where not w.cyclic
  ) select 1 from walk where cyclic
 ) then raise exception 'verification marker backfill found cyclic provenance'
  using errcode='check_violation'; end if;
end $$;

-- The exclusive lock and transaction bound this one-column migration exception.
-- The runtime immutability guard remains unchanged and forbids marker changes.
alter table orchestration.artifact disable trigger artifact_immutable;
update orchestration.artifact a set verification_contract_version='verification.v1'
 where a.verification_contract_version is null and exists(
  select 1 from orchestration.verification_artifact_metadata m
   where m.tenant_id=a.tenant_id and m.artifact_id=a.id);
alter table orchestration.artifact enable trigger artifact_immutable;

alter table orchestration.artifact drop constraint verification_bucket_cas_path_ck;
alter table orchestration.artifact add constraint verification_bucket_cas_path_ck check(
 verification_contract_version is null
 or (storage_bucket='ai-engineer-cloud-bucket'
     and object_path ~ ('^'||tenant_id::text||'/[0-9a-f]{2}/[0-9a-f]{64}$')
     and split_part(object_path,'/',2)=left(sha256,2)
     and split_part(object_path,'/',3)=sha256
     and media_type is not null and btrim(media_type)<>''
     and size_bytes is not null and size_bytes>=0)
);

create function orchestration.validate_verification_artifact_metadata() returns trigger
language plpgsql set search_path='' as $$
begin
 if not exists(select 1 from orchestration.artifact a
  where a.tenant_id=new.tenant_id and a.id=new.artifact_id
   and a.verification_contract_version='verification.v1') then
  raise exception 'verification metadata requires a marked same-tenant artifact' using errcode='foreign_key_violation';
 end if;
 if cardinality(new.parent_artifact_ids)>0 and new.transformation_signature is null then
  raise exception 'verification parents require a transformation signature' using errcode='check_violation';
 end if;
 if cardinality(new.parent_artifact_ids)<>(select count(distinct id) from unnest(new.parent_artifact_ids) p(id)) then
  raise exception 'verification parents must be distinct and nonnull' using errcode='check_violation';
 end if;
 if exists(select 1 from unnest(new.parent_artifact_ids ||
   case when new.attestation_artifact_id is null then '{}'::uuid[] else array[new.attestation_artifact_id] end) p(id)
  where not exists(select 1 from orchestration.artifact a
   join orchestration.verification_artifact_metadata m on m.tenant_id=a.tenant_id and m.artifact_id=a.id
   where a.tenant_id=new.tenant_id and a.id=p.id and a.storage_state='available'
    and a.verification_contract_version='verification.v1')) then
  raise exception 'verification parents and attestations require available marked same-tenant registrations'
   using errcode='foreign_key_violation';
 end if;
 return new;
end $$;
create trigger verification_artifact_metadata_admission before insert
 on orchestration.verification_artifact_metadata for each row
 execute function orchestration.validate_verification_artifact_metadata();

create function orchestration.validate_verification_parent_edge_completeness() returns trigger
language plpgsql set search_path='' as $$
begin
 if exists(select 1 from unnest(new.parent_artifact_ids) p(id)
  where not exists(select 1 from orchestration.artifact_lineage l
   where l.tenant_id=new.tenant_id and l.from_artifact_id=new.artifact_id and l.to_artifact_id=p.id
    and l.relation_kind='generated' and l.activity_id=new.producer_activity_id
    and l.activity_version=new.producer_version and l.transformation_signature=new.transformation_signature)) then
  raise exception 'verification metadata requires complete generated parent edges before commit'
   using errcode='foreign_key_violation';
 end if;
 return new;
end $$;
create constraint trigger verification_parent_edge_completeness after insert
 on orchestration.verification_artifact_metadata deferrable initially deferred
 for each row execute function orchestration.validate_verification_parent_edge_completeness();

create function orchestration.validate_verification_artifact_lineage() returns trigger
language plpgsql set search_path='' as $$
begin
 if new.relation_kind in('generated','derived_from','quoted_from') and exists(
  select 1 from orchestration.artifact a where a.tenant_id=new.tenant_id and a.id=new.from_artifact_id
   and a.verification_contract_version='verification.v1') and not exists(
  select 1 from orchestration.verification_artifact_metadata m
   where m.tenant_id=new.tenant_id and m.artifact_id=new.from_artifact_id
    and new.to_artifact_id=any(m.parent_artifact_ids)
    and new.activity_id=m.producer_activity_id and new.activity_version=m.producer_version
    and new.transformation_signature=m.transformation_signature) then
  raise exception 'verification lineage must match immutable registered parent metadata'
   using errcode='foreign_key_violation';
 end if;
 return new;
end $$;
create trigger verification_artifact_lineage_admission before insert
 on orchestration.artifact_lineage for each row
 execute function orchestration.validate_verification_artifact_lineage();

comment on column orchestration.artifact.verification_contract_version is
 'Immutable opt-in to verification CAS and metadata admission. NULL preserves legacy artifact identity and writer compatibility.';
commit;
