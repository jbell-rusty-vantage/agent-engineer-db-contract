-- Report package v1 extends the existing report/version and artifact authorities.
begin;
set local lock_timeout = '15s';

insert into storage.buckets(id,name,public,file_size_limit)
values ('research-reports','research-reports',false,1073741824)
on conflict(id) do update set public=false;

insert into orchestration.artifact_type(code,description) values
 ('research_report_structure','research-report.v1 structured sections, blocks and assertion references'),
 ('research_report_manifest','Immutable report package artifact/dependency manifest'),
 ('research_report_verification','Exact-revision report verification output; registration is not admission')
on conflict(code) do update set description=excluded.description;

alter table research.report
 alter column tenant_id set default util.current_tenant_id(),
 add column report_type text not null default 'research_synthesis' check(btrim(report_type)<>''),
 add column purpose text not null default '',
 add constraint report_tenant_id_uq unique(tenant_id,id),
 add constraint report_tenant_mission_fk foreign key(tenant_id,mission_id) references orchestration.mission(tenant_id,id);

-- Ownership is backfilled only from the existing parent, preserving all old content.
alter table research.report_version add column tenant_id uuid;
alter table research.report_version disable trigger report_version_immutable;
update research.report_version v set tenant_id=r.tenant_id from research.report r where r.id=v.report_id;
alter table research.report_version enable trigger report_version_immutable;
alter table research.report_version
 alter column tenant_id set default util.current_tenant_id(),
 alter column tenant_id set not null,
 add constraint report_version_tenant_id_uq unique(tenant_id,id),
 add constraint report_version_report_id_uq unique(tenant_id,report_id,id),
 add constraint report_version_tenant_report_fk foreign key(tenant_id,report_id) references research.report(tenant_id,id),
 add constraint report_version_tenant_markdown_fk foreign key(tenant_id,markdown_artifact_id) references orchestration.artifact(tenant_id,id),
 add constraint report_version_tenant_json_fk foreign key(tenant_id,json_artifact_id) references orchestration.artifact(tenant_id,id),
 add constraint report_version_positive check(version>0);

alter table research.report_claim add column tenant_id uuid;
update research.report_claim c set tenant_id=v.tenant_id from research.report_version v where v.id=c.report_version_id;
alter table research.report_claim
 alter column tenant_id set default util.current_tenant_id(),
 alter column tenant_id set not null,
 add constraint report_claim_tenant_version_fk foreign key(tenant_id,report_version_id) references research.report_version(tenant_id,id),
 add constraint report_claim_tenant_claim_fk foreign key(tenant_id,claim_id) references evidence.claim(tenant_id,id);

create table research.report_package (
 report_version_id uuid primary key,
 tenant_id uuid not null default util.current_tenant_id(),
 report_id uuid not null,
 schema_version text not null default 'research-report.v1' check(schema_version='research-report.v1'),
 authoring_mode text not null check(authoring_mode in ('incremental','post_research')),
 title text not null check(btrim(title)<>''),
 scope jsonb not null check(jsonb_typeof(scope)='object'),
 as_of timestamptz not null,
 producer_attempt_id uuid,
 producer_identity text not null check(btrim(producer_identity)<>''),
 producer_version text not null check(btrim(producer_version)<>''),
 predecessor_version_id uuid,
 created_at timestamptz not null default now(),
 unique(tenant_id,report_version_id),
 unique(tenant_id,report_id,report_version_id),
 foreign key(tenant_id,report_id,report_version_id) references research.report_version(tenant_id,report_id,id),
 foreign key(tenant_id,report_id,predecessor_version_id) references research.report_version(tenant_id,report_id,id),
 foreign key(tenant_id,producer_attempt_id) references orchestration.attempt(tenant_id,id),
 check(predecessor_version_id is distinct from report_version_id)
);

create table research.report_section (
 id uuid primary key default util.uuidv7(),
 tenant_id uuid not null default util.current_tenant_id(),
 report_id uuid not null,
 section_key text not null check(btrim(section_key)<>''),
 unique(tenant_id,report_id,section_key),
 unique(tenant_id,report_id,id),
 foreign key(tenant_id,report_id) references research.report(tenant_id,id)
);

create table research.report_section_version (
 tenant_id uuid not null default util.current_tenant_id(),
 report_id uuid not null,
 report_version_id uuid not null,
 section_id uuid not null,
 ordinal integer not null check(ordinal>=0),
 heading text not null check(btrim(heading)<>''),
 section_kind text not null check(section_kind in ('scope','summary','finding','comparison','timeline','measurement','synthesis','limitations','methods','sources')),
 question text,
 conclusion text,
 context jsonb not null default '{}' check(jsonb_typeof(context)='object'),
 content_pointer text not null check(content_pointer like '/sections/%'),
 primary key(tenant_id,report_version_id,section_id),
 unique(report_version_id,ordinal),
 foreign key(tenant_id,report_id,report_version_id) references research.report_package(tenant_id,report_id,report_version_id),
 foreign key(tenant_id,report_id,section_id) references research.report_section(tenant_id,report_id,id)
);

create table research.report_section_dependency (
 tenant_id uuid not null default util.current_tenant_id(),
 report_version_id uuid not null,
 section_id uuid not null,
 required_version_id uuid not null,
 required_section_id uuid not null,
 relation text not null check(relation in ('requires_context','derived_from','supersedes')),
 primary key(report_version_id,section_id,required_version_id,required_section_id,relation),
 foreign key(tenant_id,report_version_id,section_id) references research.report_section_version(tenant_id,report_version_id,section_id),
 foreign key(tenant_id,required_version_id,required_section_id) references research.report_section_version(tenant_id,report_version_id,section_id),
 check((report_version_id,section_id)<>(required_version_id,required_section_id))
);

create table research.report_artifact (
 tenant_id uuid not null default util.current_tenant_id(),
 report_version_id uuid not null,
 artifact_id uuid not null,
 role text not null check(role in ('structure','markdown','html','pdf','manifest','verification','input')),
 primary key(report_version_id,artifact_id,role),
 foreign key(tenant_id,report_version_id) references research.report_package(tenant_id,report_version_id),
 foreign key(tenant_id,artifact_id) references orchestration.artifact(tenant_id,id)
);
create unique index report_single_rendition on research.report_artifact(report_version_id,role)
 where role in ('structure','markdown','manifest');
create index report_artifact_reverse on research.report_artifact(tenant_id,artifact_id);

create table research.report_assertion (
 id uuid primary key default util.uuidv7(),
 tenant_id uuid not null default util.current_tenant_id(),
 report_version_id uuid not null,
 section_id uuid not null,
 assertion_key text not null check(btrim(assertion_key)<>''),
 statement_kind text not null check(statement_kind in ('reported','observed','derived','interpretation','recommendation','illustrative')),
 proposition text not null check(btrim(proposition)<>''),
 artifact_id uuid not null,
 start_utf16 integer not null check(start_utf16>=0),
 end_utf16 integer not null,
 block_pointer text not null check(block_pointer like '/sections/%'),
 qualifiers jsonb not null default '[]' check(jsonb_typeof(qualifiers)='array'),
 derivation jsonb not null default '{}' check(jsonb_typeof(derivation)='object'),
 unique(tenant_id,report_version_id,id),
 unique(report_version_id,assertion_key),
 foreign key(tenant_id,report_version_id,section_id) references research.report_section_version(tenant_id,report_version_id,section_id),
 foreign key(tenant_id,artifact_id) references orchestration.artifact(tenant_id,id),
 check(end_utf16>start_utf16)
);

create table research.report_assertion_claim (
 tenant_id uuid not null default util.current_tenant_id(),
 report_version_id uuid not null,
 assertion_id uuid not null,
 run_id text not null check(btrim(run_id)<>''),
 claim_key text not null check(btrim(claim_key)<>''),
 claim_digest text not null check(claim_digest ~ '^[0-9a-f]{64}$'),
 claim_id uuid,
 evidence_manifest_artifact_id uuid not null,
 role text not null check(role in ('supports','premise','context','caveat','contradicts')),
 primary key(assertion_id,run_id,claim_key,claim_digest,role),
 foreign key(tenant_id,report_version_id,assertion_id) references research.report_assertion(tenant_id,report_version_id,id),
 foreign key(tenant_id,claim_id) references evidence.claim(tenant_id,id),
 foreign key(tenant_id,evidence_manifest_artifact_id) references orchestration.artifact(tenant_id,id)
);
create index report_assertion_claim_reverse on research.report_assertion_claim(tenant_id,run_id,claim_key,claim_digest);

create table research.report_question (
 tenant_id uuid not null default util.current_tenant_id(),
 report_version_id uuid not null,
 question_key text not null check(btrim(question_key)<>''),
 question text not null check(btrim(question)<>''),
 required boolean not null default true,
 coverage text not null check(coverage in ('answered','partial','unanswered','conflicting','out_of_scope')),
 explanation text not null,
 resolution_evidence_needed text,
 primary key(tenant_id,report_version_id,question_key),
 foreign key(tenant_id,report_version_id) references research.report_package(tenant_id,report_version_id),
 check(coverage='answered' or btrim(explanation)<>'')
);
create table research.report_question_section (
 tenant_id uuid not null default util.current_tenant_id(),
 report_version_id uuid not null,
 question_key text not null,
 section_id uuid not null,
 primary key(report_version_id,question_key,section_id),
 foreign key(tenant_id,report_version_id,question_key) references research.report_question(tenant_id,report_version_id,question_key),
 foreign key(tenant_id,report_version_id,section_id) references research.report_section_version(tenant_id,report_version_id,section_id)
);

-- Receipts arrive after authoring; these append-only links are not sealed content.
create table research.report_ingestion_link (
 id uuid primary key default util.uuidv7(),
 tenant_id uuid not null default util.current_tenant_id(),
 report_version_id uuid not null,
 assertion_id uuid,
 intent_id uuid not null references orchestration.operation_intent(id),
 proposal_id text not null check(btrim(proposal_id)<>''),
 receipt_id uuid references orchestration.operation_receipt(id),
 outcome text not null check(outcome in ('proposed','applied','held','rejected','no_op','unresolved')),
 canonical_refs jsonb not null default '[]' check(jsonb_typeof(canonical_refs)='array'),
 created_at timestamptz not null default now(),
 foreign key(tenant_id,report_version_id) references research.report_package(tenant_id,report_version_id),
 foreign key(tenant_id,report_version_id,assertion_id) references research.report_assertion(tenant_id,report_version_id,id),
 check(outcome not in ('applied','no_op') or receipt_id is not null)
);
create index report_ingestion_revision on research.report_ingestion_link(tenant_id,report_version_id);

create table research.report_package_seal (
 tenant_id uuid not null default util.current_tenant_id(),
 report_version_id uuid primary key,
 manifest_artifact_id uuid not null,
 sealed_at timestamptz not null default now(),
 foreign key(tenant_id,report_version_id) references research.report_package(tenant_id,report_version_id),
 foreign key(tenant_id,manifest_artifact_id) references orchestration.artifact(tenant_id,id)
);

-- Locking the owning immutable version serializes projection inserts and sealing.
create function research.guard_report_projection() returns trigger
language plpgsql security definer set search_path='' as $$
begin
 if new.tenant_id is distinct from util.current_tenant_id() then raise exception 'REPORT_TENANT_MISMATCH' using errcode='23514'; end if;
 perform 1 from research.report_version where id=new.report_version_id and tenant_id=new.tenant_id for update;
 if tg_table_name='report_package' then
  if new.predecessor_version_id is not null and not exists(
   select 1 from research.report_version predecessor
   join research.report_version current_version on current_version.id=new.report_version_id
   where predecessor.id=new.predecessor_version_id and predecessor.tenant_id=new.tenant_id
    and predecessor.report_id=new.report_id and predecessor.version<current_version.version
  ) then raise exception 'REPORT_PREDECESSOR_NOT_EARLIER' using errcode='23514'; end if;
 end if;
 if exists(select 1 from research.report_package_seal where report_version_id=new.report_version_id) then
  raise exception 'REPORT_REVISION_SEALED' using errcode='55000';
 end if;
 return new;
end $$;

create function research.guard_report_ingestion_link() returns trigger
language plpgsql set search_path='' as $$
begin
 if not exists(select 1 from orchestration.operation_intent where id=new.intent_id and tenant_id=new.tenant_id) then
  raise exception 'REPORT_INGESTION_TENANT_MISMATCH' using errcode='23514';
 end if;
 if new.receipt_id is not null and not exists(select 1 from orchestration.operation_receipt where id=new.receipt_id and intent_id=new.intent_id) then
  raise exception 'REPORT_INGESTION_RECEIPT_MISMATCH' using errcode='23514';
 end if;
 return new;
end $$;
create trigger report_ingestion_link_guard before insert on research.report_ingestion_link
 for each row execute function research.guard_report_ingestion_link();

create function research.guard_report_seal() returns trigger
language plpgsql security definer set search_path='' as $$
begin
 if new.tenant_id is distinct from util.current_tenant_id() then raise exception 'REPORT_TENANT_MISMATCH' using errcode='23514'; end if;
 perform 1 from research.report_version where id=new.report_version_id and tenant_id=new.tenant_id for update;
 if (select count(*) from research.report_artifact where report_version_id=new.report_version_id and role in ('structure','markdown','manifest'))<>3 then
  raise exception 'REPORT_REQUIRED_ARTIFACTS_MISSING' using errcode='23514';
 end if;
 if not exists(select 1 from research.report_artifact where report_version_id=new.report_version_id and role='manifest' and artifact_id=new.manifest_artifact_id) then
  raise exception 'REPORT_MANIFEST_MISMATCH' using errcode='23514';
 end if;
 if exists(select 1 from research.report_artifact r join orchestration.artifact a on a.id=r.artifact_id where r.report_version_id=new.report_version_id and (a.storage_state<>'available' or a.size_bytes is null)) then
  raise exception 'REPORT_ARTIFACT_UNAVAILABLE' using errcode='23514';
 end if;
 if exists(select 1 from research.report_artifact r join orchestration.artifact a on a.id=r.artifact_id where r.report_version_id=new.report_version_id and r.role in ('structure','markdown','manifest') and a.storage_bucket<>'research-reports') then
  raise exception 'REPORT_BUCKET_MISMATCH' using errcode='23514';
 end if;
 if not exists(select 1 from research.report_version v
  join research.report_artifact m on m.report_version_id=v.id and m.role='markdown' and m.artifact_id=v.markdown_artifact_id
  join research.report_artifact j on j.report_version_id=v.id and j.role='structure' and j.artifact_id=v.json_artifact_id
  where v.id=new.report_version_id) then
  raise exception 'REPORT_RENDITION_MISMATCH' using errcode='23514';
 end if;
 if exists(select 1 from research.report_assertion_claim c join orchestration.artifact a on a.id=c.evidence_manifest_artifact_id where c.report_version_id=new.report_version_id and a.storage_state<>'available') then
  raise exception 'REPORT_EVIDENCE_MANIFEST_UNAVAILABLE' using errcode='23514';
 end if;
 if not exists(select 1 from research.report_section_version where report_version_id=new.report_version_id) then
  raise exception 'REPORT_SECTIONS_MISSING' using errcode='23514';
 end if;
 if exists(select 1 from research.report_assertion a where a.report_version_id=new.report_version_id and a.statement_kind<>'illustrative'
  and not exists(select 1 from research.report_assertion_claim c where c.assertion_id=a.id and c.role in ('supports','premise'))) then
  raise exception 'REPORT_ASSERTION_BINDING_MISSING' using errcode='23514';
 end if;
 if exists(select 1 from research.report_assertion a where a.report_version_id=new.report_version_id
  and not exists(select 1 from research.report_artifact f where f.report_version_id=a.report_version_id and f.role='markdown' and f.artifact_id=a.artifact_id)) then
  raise exception 'REPORT_ASSERTION_ARTIFACT_MISMATCH' using errcode='23514';
 end if;
 if exists(select 1 from research.report_question q where q.report_version_id=new.report_version_id and q.coverage in ('answered','partial','conflicting')
  and not exists(select 1 from research.report_question_section s where s.report_version_id=q.report_version_id and s.question_key=q.question_key)) then
  raise exception 'REPORT_QUESTION_SECTION_MISSING' using errcode='23514';
 end if;
 return new;
end $$;
create trigger report_package_seal_guard before insert on research.report_package_seal
 for each row execute function research.guard_report_seal();

do $$
declare relation_name text;
begin
 foreach relation_name in array array['report_version','report_claim','report_package','report_section','report_section_version','report_section_dependency','report_artifact','report_assertion','report_assertion_claim','report_question','report_question_section','report_ingestion_link','report_package_seal'] loop
  execute format('alter table research.%I enable row level security',relation_name);
  execute format('drop policy if exists bounded_role_access on research.%I',relation_name);
  execute format('create policy bounded_role_access on research.%I to executor_service,pipeline_agent,verifier_agent,control_plane,app_reader using(tenant_id=util.current_tenant_id()) with check(tenant_id=util.current_tenant_id())',relation_name);
  execute format('revoke all on research.%I from anon,authenticated',relation_name);
  execute format('grant select on research.%I to executor_service,pipeline_agent,verifier_agent,control_plane,app_reader',relation_name);
  execute format('grant insert on research.%I to executor_service,control_plane',relation_name);
  execute format('revoke update,delete on research.%I from executor_service,pipeline_agent,verifier_agent,control_plane,app_reader',relation_name);
  if relation_name<>'report_version' then
   execute format('create trigger report_row_immutable before update or delete on research.%I for each row execute function util.reject_mutation()',relation_name);
  end if;
  if relation_name not in ('report_version','report_section','report_ingestion_link','report_package_seal') then
   execute format('create trigger report_projection_open before insert on research.%I for each row execute function research.guard_report_projection()',relation_name);
  end if;
 end loop;
end $$;
grant usage on schema research to executor_service,pipeline_agent,verifier_agent,control_plane,app_reader;
grant select on research.report to executor_service,pipeline_agent,verifier_agent,control_plane,app_reader;
grant insert,update on research.report to executor_service,control_plane;
revoke all on function research.guard_report_projection(),research.guard_report_seal(),research.guard_report_ingestion_link() from public;

comment on table research.report_package is 'Report v1 authoring envelope. Incremental and post-research assembly share one contract. Legacy report versions remain readable without this envelope.';
comment on table research.report_package_seal is 'Immutable registration seal, not verification or policy admission. Official publication must independently verify final bytes and evidence.';
comment on table research.report_assertion_claim is 'Run-qualified immutable claim references; optional canonical claim materialization. Verification/admission remains owned by evidence and policy.';
comment on table research.report_artifact is 'References the canonical artifact registry; storage location, digest, bytes and availability are never copied into report rows.';
commit;
