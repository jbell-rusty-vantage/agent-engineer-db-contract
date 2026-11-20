-- Build 09, unit RV01 (packet r1): why a fact changed, governed merge and split of records, succession vocabulary, proposals.
-- Lab draft. Parts A to F of the packet. Additive, with vocabulary rows and two api type changes (api.changes_since, temporal.assert_state).

-- ============================================================================================ A. why a fact changed
create table temporal.correction_reason (
  code text primary key,
  applies_to text[] not null check (applies_to <@ array['fact','relationship','merge','split']::text[] and cardinality(applies_to) >= 1),
  description text not null
);
comment on table temporal.correction_reason is 'Coded reasons for a correction of our own belief (never for a change in the world). applies_to says where a code may be used. not_recorded is set by backfill only.';
insert into temporal.correction_reason(code, applies_to, description) values
  ('source_corrected', '{fact,relationship}', 'The source corrected itself'),
  ('misread', '{fact,relationship}', 'We extracted or parsed it wrongly'),
  ('better_source', '{fact,relationship}', 'A more authoritative source disagrees'),
  ('late_evidence', '{fact,relationship}', 'The right value or date was learned later'),
  ('wrong_entity', '{fact,relationship,split}', 'It belonged to another entity'),
  ('duplicate_record', '{fact,relationship,merge}', 'Closed or moved because its record was merged into another'),
  ('mixed_record', '{split}', 'One record described several things'),
  ('merge_undone', '{fact,relationship}', 'Moved back because a merge was undone'),
  ('not_recorded', '{fact,relationship}', 'A replacement made before reasons existed; set by backfill, refused on new writes');
grant select on temporal.correction_reason to control_plane, executor_service, pipeline_agent, verifier_agent, service_role;

alter table temporal.segment
  add column revision_kind text check (revision_kind in ('world_change', 'correction', 'carried')),
  add column correction_reason text references temporal.correction_reason(code),
  add constraint segment_correction_has_reason check (revision_kind is distinct from 'correction' or correction_reason is not null),
  add constraint segment_reason_only_on_correction check (correction_reason is null or revision_kind = 'correction');
comment on column temporal.segment.revision_kind is 'How this fact relates to the one it replaces: world_change (the world changed), correction (our belief was wrong; needs correction_reason) or carried (the unchanged part of an older fact, cut again). Empty for a first fact.';
comment on column temporal.segment.correction_reason is 'Why our earlier belief was wrong; required exactly when revision_kind is correction.';

alter table catalog.relationship
  add column closed_kind text check (closed_kind in ('world_change', 'correction')),
  add column closed_reason text references temporal.correction_reason(code),
  add column closed_by_event_id uuid references temporal.event(id),
  add constraint relationship_closed_kind_needs_closure check (closed_kind is null or k_to is not null),
  add constraint relationship_correction_has_reason check (closed_kind is distinct from 'correction' or closed_reason is not null),
  add constraint relationship_reason_only_on_correction check (closed_reason is null or closed_kind = 'correction');
comment on column catalog.relationship.closed_kind is 'Why the edge stopped being current knowledge: world_change or correction. Set by temporal.close_relationship and by merge and split.';
comment on column catalog.relationship.closed_reason is 'Coded reason when closed_kind is correction.';
comment on column catalog.relationship.closed_by_event_id is 'The event that ended the edge, when a source names one.';

-- backfill (history rows cannot be edited through the guard; this migration is the one exception)
alter table temporal.segment disable trigger guard_k;
alter table temporal.segment disable trigger sealed_batch;
update temporal.segment s set revision_kind = 'carried'
  from temporal.segment o
 where s.replaces_segment_id = o.id and s.stream_id = o.stream_id and s.valid_during <@ o.valid_during and s.valid_during <> o.valid_during
   and s.status is not distinct from o.status and s.amount is not distinct from o.amount and s.currency is not distinct from o.currency and s.unit is not distinct from o.unit
   and s.ref_entity_id is not distinct from o.ref_entity_id and s.payload = o.payload and s.primary_claim_id is not distinct from o.primary_claim_id
   and exists (select 1 from temporal.segment sib where sib.replaces_segment_id = o.id and sib.k_from = s.k_from and sib.id <> s.id);
update temporal.segment s set revision_kind = 'world_change'
  from temporal.segment o
 where s.replaces_segment_id = o.id and s.revision_kind is null and lower(s.valid_during) > lower(o.valid_during);
update temporal.segment s set revision_kind = 'correction', correction_reason = 'not_recorded'
 where s.replaces_segment_id is not null and s.revision_kind is null;
alter table temporal.segment enable trigger guard_k;
alter table temporal.segment enable trigger sealed_batch;

alter table catalog.relationship disable trigger guard_k;
alter table catalog.relationship disable trigger sealed_batch;
update catalog.relationship set closed_kind = 'correction', closed_reason = 'not_recorded' where k_to is not null and closed_kind is null;
alter table catalog.relationship enable trigger guard_k;
alter table catalog.relationship enable trigger sealed_batch;

-- the guard: closure may set the closure columns; a reason that was never recorded may be given later; nothing else changes
create or replace function temporal.guard_k() returns trigger language plpgsql set search_path = '' as $$
declare
  closure constant text[] := array['k_to', 'closed_kind', 'closed_reason', 'closed_by_event_id'];
  reasons constant text[] := array['correction_reason', 'closed_kind', 'closed_reason', 'closed_by_event_id'];
  o jsonb; n jsonb;
begin
 if tg_op='DELETE' then raise exception 'history cannot be deleted' using errcode='23001'; end if;
 o := to_jsonb(old); n := to_jsonb(new);
 if temporal.current_k() is not null and old.tenant_id = util.current_tenant_id()
    and coalesce(o ->> 'correction_reason', o ->> 'closed_reason') = 'not_recorded'
    and coalesce(n ->> 'correction_reason', n ->> 'closed_reason') is not null and (n - reasons) = (o - reasons) then
  return new;
 end if;
 if temporal.current_k() is null or old.tenant_id<>util.current_tenant_id() or old.k_to is not null or new.k_to is distinct from temporal.current_k() or (n - closure) <> (o - closure) then raise exception 'only closure in an open tenant batch is allowed' using errcode='23001'; end if;
 return new;
end $$;

drop function temporal.assert_state(uuid, text, tstzrange, text, text, numeric, text, text, uuid, jsonb, uuid, uuid, text, uuid, text);
create function temporal.assert_state(p_entity uuid, p_stream_kind text, p_valid_during tstzrange, p_scope_key text default '', p_status text default null, p_amount numeric default null, p_currency text default null, p_unit text default null, p_ref_entity uuid default null, p_payload jsonb default '{}'::jsonb, p_extent uuid default null, p_claim uuid default null, p_temporal_basis text default 'explicit', p_relationship uuid default null, p_belief text default 'accepted',
  p_revision_kind text default null, p_correction_reason text default null, p_caused_by_event uuid default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare st uuid; result uuid; old temporal.segment; piece tstzrange; sk temporal.stream_kind; subject text; t uuid:=util.current_tenant_id();
  v_replaces uuid; v_overlaps boolean := false; v_rewrites boolean := false; v_kind text := p_revision_kind;
begin
 if temporal.current_k() is null then raise exception 'no open knowledge batch'; end if;
 if p_revision_kind is not null and p_revision_kind not in ('world_change', 'correction') then raise exception 'revision kind is world_change or correction' using errcode='22023'; end if;
 if p_correction_reason is not null and p_revision_kind is distinct from 'correction' then raise exception 'a correction reason belongs to a correction' using errcode='22023'; end if;
 if p_revision_kind = 'correction' and (p_correction_reason is null or p_correction_reason = 'not_recorded'
    or not exists(select 1 from temporal.correction_reason cr where cr.code = p_correction_reason and 'fact' = any(cr.applies_to))) then
  raise exception 'correction requires a reason' using errcode='23514', detail = 'a code of temporal.correction_reason that applies to a fact; not_recorded is for backfill only';
 end if;
 select * into strict sk from temporal.stream_kind where code=p_stream_kind;
 if sk.subject_mode='entity' then
  if p_relationship is not null then raise exception 'entity stream cannot target relationship'; end if;
  select kind into strict subject from catalog.entity where id=p_entity and tenant_id=t;
  if not(subject=any(sk.subject_kinds)) then raise exception 'stream does not admit entity kind' using errcode='23514'; end if;
 else
  if p_entity is not null then raise exception 'relationship stream cannot target entity'; end if;
  select r.kind into strict subject from catalog.relationship r join taxonomy.relationship_kind k on k.code=r.kind where r.id=p_relationship and r.tenant_id=t and r.k_to is null and k.temporal;
  if sk.code<>'relationship_active' and not(subject=any(sk.subject_kinds)) then raise exception 'stream does not admit relationship kind' using errcode='23514'; end if;
 end if;
 insert into temporal.stream(kind,subject_entity_id,subject_relationship_id,scope_key) values(p_stream_kind,p_entity,p_relationship,p_scope_key) on conflict do nothing;
 select id into strict st from temporal.stream where tenant_id=t and kind=p_stream_kind and subject_entity_id is not distinct from p_entity and subject_relationship_id is not distinct from p_relationship and scope_key=p_scope_key;
 if exists(select 1 from temporal.segment where stream_id=st and k_to is null and valid_during=p_valid_during and status is not distinct from p_status and amount is not distinct from p_amount and currency is not distinct from p_currency and unit is not distinct from p_unit and ref_entity_id is not distinct from p_ref_entity and payload=p_payload and extent_id is not distinct from p_extent and primary_claim_id is not distinct from p_claim and belief=p_belief and temporal_basis=p_temporal_basis) then
  select id into result from temporal.segment where stream_id=st and k_to is null and valid_during=p_valid_during; return result;
 end if;
 -- which kind of replacement is this? decided before anything is written
 select true, bool_or(lower(p_valid_during) <= lower(x.valid_during)) into v_overlaps, v_rewrites
   from temporal.segment x where x.stream_id=st and x.k_to is null and x.valid_during && p_valid_during having count(*) > 0;
 if coalesce(v_overlaps, false) then
  if v_kind is null then
   if v_rewrites then
    raise exception 'correction requires a reason' using errcode='23514',
      detail = 'the new fact starts at or before the start of a fact it replaces, so it rewrites the past: pass p_revision_kind => correction and p_correction_reason';
   end if;
   v_kind := 'world_change';
  elsif v_kind = 'world_change' and v_rewrites then
   raise exception 'a world change cannot rewrite the start of the fact it replaces' using errcode='23514', detail = 'record a correction with its reason';
  end if;
 end if;
 for old in select * from temporal.segment where stream_id=st and k_to is null and valid_during && p_valid_during for update loop
  if old.k_from=temporal.current_k() then raise exception 'overlapping assertions in one batch; consolidate before admission'; end if;
  perform temporal.close_segment(old.id);
  v_replaces := old.id;
  for piece in select unnest(tstzmultirange(old.valid_during)-tstzmultirange(p_valid_during)) loop
   insert into temporal.segment(stream_id,valid_during,belief,temporal_basis,status,amount,currency,unit,ref_entity_id,payload,extent_id,caused_by_event_id,replaces_segment_id,primary_claim_id,revision_kind)
   values(st,piece,old.belief,old.temporal_basis,old.status,old.amount,old.currency,old.unit,old.ref_entity_id,old.payload,old.extent_id,old.caused_by_event_id,old.id,old.primary_claim_id,'carried');
  end loop;
 end loop;
 insert into temporal.segment(stream_id,valid_during,belief,temporal_basis,status,amount,currency,unit,ref_entity_id,payload,extent_id,caused_by_event_id,replaces_segment_id,primary_claim_id,revision_kind,correction_reason)
 values(st,p_valid_during,p_belief,p_temporal_basis,p_status,p_amount,p_currency,p_unit,p_ref_entity,p_payload,p_extent,p_caused_by_event,v_replaces,p_claim,v_kind,case when v_kind = 'correction' then p_correction_reason end) returning id into result;
 return result;
end $$;
revoke all on function temporal.assert_state(uuid, text, tstzrange, text, text, numeric, text, text, uuid, jsonb, uuid, uuid, text, uuid, text, text, text, uuid) from public;
grant execute on function temporal.assert_state(uuid, text, tstzrange, text, text, numeric, text, text, uuid, jsonb, uuid, uuid, text, uuid, text, text, text, uuid) to executor_service, service_role;
comment on function temporal.assert_state(uuid, text, tstzrange, text, text, numeric, text, text, uuid, jsonb, uuid, uuid, text, uuid, text, text, text, uuid) is
  'Assert a fact. A replacement is a world_change (the new fact starts later than the one it replaces; may name p_caused_by_event) or a correction (it rewrites the past; p_correction_reason required). Saying nothing is allowed only for a world change.';

create function temporal.close_relationship(p_relationship uuid, p_closed_kind text, p_reason text default null, p_event uuid default null, p_world_end timestamptz default null, p_extent uuid default null, p_claim uuid default null)
returns void language plpgsql security definer set search_path = '' as $$
declare r catalog.relationship; is_temporal boolean; t uuid := util.current_tenant_id(); st record; g record;
begin
 if temporal.current_k() is null then raise exception 'no open knowledge batch'; end if;
 select * into r from catalog.relationship where id = p_relationship and tenant_id = t and k_to is null for update;
 if not found then raise exception 'current relationship not found' using errcode='P0002'; end if;
 select temporal into strict is_temporal from taxonomy.relationship_kind where code = r.kind;
 if p_closed_kind is null or p_closed_kind not in ('world_change', 'correction') then raise exception 'closed kind is world_change or correction' using errcode='22023'; end if;
 if p_closed_kind = 'correction' then
  if p_reason is null or p_reason = 'not_recorded' or not exists(select 1 from temporal.correction_reason cr where cr.code = p_reason and 'relationship' = any(cr.applies_to)) then
   raise exception 'correction requires a reason' using errcode='23514', detail = 'a code of temporal.correction_reason that applies to a relationship';
  end if;
  update catalog.relationship set k_to = temporal.current_k(), closed_kind = 'correction', closed_reason = p_reason, closed_by_event_id = p_event where id = r.id;
  for g in select s.id from temporal.stream x join temporal.segment s on s.stream_id = x.id where x.subject_relationship_id = r.id and s.k_to is null and s.k_from < temporal.current_k() loop
   perform temporal.close_segment(g.id);
  end loop;
 else
  if p_reason is not null then raise exception 'a correction reason belongs to a correction' using errcode='22023'; end if;
  if is_temporal then
   -- the edge was true and ended in the world: the row stays, its active stream ends at p_world_end
   if p_world_end is null then raise exception 'a world ending of a temporal relationship needs p_world_end' using errcode='22023'; end if;
   perform temporal.assert_state(null, 'relationship_active', tstzrange(p_world_end, null, '[)'), p_status => 'ended', p_extent => p_extent, p_claim => p_claim,
     p_temporal_basis => case when p_extent is null then 'observation_bounded' else 'explicit' end, p_relationship => r.id, p_revision_kind => 'world_change', p_caused_by_event => p_event);
  else
   update catalog.relationship set k_to = temporal.current_k(), closed_kind = 'world_change', closed_by_event_id = p_event where id = r.id;
  end if;
 end if;
end $$;
revoke all on function temporal.close_relationship(uuid, text, text, uuid, timestamptz, uuid, uuid) from public;
grant execute on function temporal.close_relationship(uuid, text, text, uuid, timestamptz, uuid, uuid) to executor_service, service_role;
comment on function temporal.close_relationship(uuid, text, text, uuid, timestamptz, uuid, uuid) is
  'End an edge. correction: the edge was wrong; it leaves current knowledge with a coded reason. world_change: the edge was true and ended; an edge that carries world time keeps its row and its relationship_active fact ends at p_world_end with the cause event.';

alter table evidence.segment_support drop constraint segment_support_role_check;
alter table evidence.segment_support add constraint segment_support_role_check check (role in ('supports', 'challenges', 'context', 'explains'));
comment on column evidence.segment_support.role is 'supports, challenges, context, or explains (this claim states why the fact or event happened: a stated motive, attributed to its source).';

-- ============================================================================================ D. world events on identity (vocabulary rows)
insert into taxonomy.relationship_kind(code, from_kinds, to_kinds, temporal, "symmetric", inverse_label, description)
values ('split_from', '{library,product,repository,organization,ai_protocol}', '{library,product,repository,organization,ai_protocol}', false, false, 'split into',
        'The first thing was carved out of the second in the world (a package split out of another, a spin-off). Both records stay.');
update taxonomy.relationship_kind set from_kinds = '{product,ai_model,library,repository,organization,ai_protocol,mcp_server,agent_skill}', to_kinds = '{product,ai_model,library,repository,organization,ai_protocol,mcp_server,agent_skill}',
       description = 'The first thing succeeds the second in the world (successor to predecessor). Both records stay.' where code = 'supersedes';
update taxonomy.relationship_kind set to_kinds = '{library,repository,mcp_server,agent_skill,ai_protocol}' where code = 'maintains';
insert into temporal.event_kind(code, subject_kinds, object_kinds, description) values
  ('split_out', '{library,product,repository,organization,ai_protocol}', '{library,product,repository,organization,ai_protocol}', 'A part of the subject was carved out into a new thing (the object)'),
  ('stewardship_transferred', '{ai_protocol,library,repository,product,mcp_server,agent_skill}', '{organization,person}', 'Stewardship of the subject passed to the object');

-- ============================================================================================ E. proposals (created before C, which refers to them)
create table catalog.proposal (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.current_tenant_id(),
  proposal_kind text not null check (proposal_kind in ('relationship', 'cause', 'identity')),
  subject_entity_id uuid references catalog.entity(id),
  object_entity_id uuid references catalog.entity(id),
  relationship_kind text references taxonomy.relationship_kind(code),
  label text,
  target_segment_id uuid references temporal.segment(id),
  target_event_id uuid references temporal.event(id),
  target_relationship_id uuid references catalog.relationship(id),
  cause_event_id uuid references temporal.event(id),
  statement text not null check (length(btrim(statement)) between 1 and 2000),
  rationale text not null check (length(btrim(rationale)) between 1 and 8000),
  world_during tstzrange,
  confidence text not null check (confidence in ('low', 'medium', 'high')),
  authored_by_kind text not null check (authored_by_kind in ('person', 'agent')),
  authored_by text not null check (btrim(authored_by) <> ''),
  review_state text not null default 'agent_proposed' check (review_state in ('agent_proposed', 'person_proposed', 'endorsed', 'rejected', 'withdrawn', 'confirmed_by_source', 'refuted_by_source')),
  decided_by text,
  decided_at timestamptz,
  decision_note text,
  outcome_claim_id uuid references evidence.claim(id),
  publication text not null default 'private' check (publication in ('private', 'published')),
  published_at timestamptz,
  published_by text,
  created_by_receipt_id uuid references orchestration.operation_receipt(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, id),
  constraint proposal_relationship_shape check (proposal_kind <> 'relationship' or (subject_entity_id is not null and object_entity_id is not null and subject_entity_id <> object_entity_id and num_nonnulls(relationship_kind, nullif(btrim(label), '')) >= 1)),
  constraint proposal_cause_shape check (proposal_kind <> 'cause' or num_nonnulls(target_segment_id, target_event_id, target_relationship_id) = 1),
  constraint proposal_identity_shape check (proposal_kind <> 'identity' or (subject_entity_id is not null and object_entity_id is distinct from subject_entity_id)),
  constraint proposal_agent_state check (authored_by_kind <> 'agent' or review_state <> 'person_proposed'),
  constraint proposal_published_is_reviewed check (publication = 'private' or review_state in ('person_proposed', 'endorsed', 'confirmed_by_source')),
  constraint proposal_outcome_has_claim check (review_state not in ('confirmed_by_source', 'refuted_by_source') or outcome_claim_id is not null)
);
comment on table catalog.proposal is 'Our own view, never a fact: what a person or an agent proposes about how two things relate (relationship), why a recorded change happened (cause), or whether records are the same thing or a mix (identity). Private unless a person publishes it. No other read shows these rows.';
comment on column catalog.proposal.review_state is 'agent_proposed, person_proposed, endorsed, rejected, withdrawn, confirmed_by_source or refuted_by_source. Anything but agent_proposed is a person''s judgment.';
comment on column catalog.proposal.publication is 'private (default) or published. Only a person publishes.';
comment on column catalog.proposal.outcome_claim_id is 'The sourced claim that later confirmed or refuted the proposal.';
create index proposal_subject_idx on catalog.proposal (tenant_id, subject_entity_id);
create index proposal_object_idx on catalog.proposal (tenant_id, object_entity_id);

create table catalog.proposal_basis (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.current_tenant_id(),
  proposal_id uuid not null references catalog.proposal(id),
  role text not null default 'basis' check (role in ('basis', 'counter')),
  claim_id uuid references evidence.claim(id),
  segment_id uuid references temporal.segment(id),
  event_id uuid references temporal.event(id),
  relationship_id uuid references catalog.relationship(id),
  note text,
  constraint proposal_basis_one_target check (num_nonnulls(claim_id, segment_id, event_id, relationship_id) = 1)
);
comment on table catalog.proposal_basis is 'What a proposal reasons from (basis) or must answer (counter): a claim, a fact, an event or a relationship.';
create index proposal_basis_proposal_idx on catalog.proposal_basis (proposal_id);

alter table catalog.proposal enable row level security;
alter table catalog.proposal_basis enable row level security;
create policy km_tenant_access on catalog.proposal to control_plane, executor_service, pipeline_agent, verifier_agent using (tenant_id = util.current_tenant_id()) with check (tenant_id = util.current_tenant_id());
create policy km_tenant_access on catalog.proposal_basis to control_plane, executor_service, pipeline_agent, verifier_agent using (tenant_id = util.current_tenant_id()) with check (tenant_id = util.current_tenant_id());
grant select on catalog.proposal, catalog.proposal_basis to control_plane, executor_service, pipeline_agent, verifier_agent;
create trigger proposal_human_judgment before insert or update on catalog.proposal for each row execute function verification.guard_human_judgment();

-- who is calling, seen from inside a definer function
create function catalog.caller_role() returns text language sql stable set search_path = '' as $$
  select coalesce(nullif(pg_catalog.current_setting('role', true), 'none'), session_user::text)
$$;
create function catalog.caller_is_person() returns boolean language sql stable set search_path = '' as $$
  select coalesce((select r.rolsuper from pg_catalog.pg_roles r where r.rolname = catalog.caller_role()), false)
      or catalog.caller_role() = (select pg_catalog.pg_get_userbyid(c.relowner) from pg_catalog.pg_class c where c.oid = 'catalog.proposal'::regclass)
$$;
comment on function catalog.caller_is_person() is 'True when the session role is the owner of catalog.proposal or a superuser: the same test verification.guard_human_judgment applies. Agent roles are never a person. The person''s own path is unit RV10.';

create function api.propose(p_idempotency_key text, p_kind text, p_statement text, p_rationale text, p_confidence text, p_subject uuid default null, p_object uuid default null,
  p_relationship_kind text default null, p_label text default null, p_target jsonb default '{}'::jsonb, p_cause_event uuid default null, p_world_during tstzrange default null,
  p_basis jsonb default '[]'::jsonb, p_actor jsonb default '{}'::jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare ctx jsonb; v_tenant uuid; v_request jsonb; v_result jsonb; v_receipt uuid; v_id uuid; b jsonb; v_person boolean := catalog.caller_is_person();
  v_target jsonb := coalesce(p_target, '{}'::jsonb); v_basis jsonb := coalesce(p_basis, '[]'::jsonb); v_author text;
begin
  v_request := jsonb_build_object('kind', p_kind, 'statement', btrim(coalesce(p_statement, '')), 'rationale', btrim(coalesce(p_rationale, '')), 'confidence', p_confidence, 'subject', p_subject, 'object', p_object,
    'relationship_kind', p_relationship_kind, 'label', p_label, 'target', v_target, 'cause_event', p_cause_event, 'world_during', p_world_during::text, 'basis', v_basis);
  ctx := verification.chain_begin('api.propose', p_idempotency_key, v_request, p_actor);
  if ctx ? 'replay' then return ctx -> 'replay'; end if;
  v_tenant := (ctx ->> 'tenant')::uuid;
  if p_kind is null or p_kind not in ('relationship', 'cause', 'identity') then
    perform verification.chain_fail('PROPOSAL_KIND_INVALID', '22023', 'kind is relationship, cause or identity');
  end if;
  if btrim(coalesce(p_statement, '')) = '' or btrim(coalesce(p_rationale, '')) = '' then
    perform verification.chain_fail('STATEMENT_AND_RATIONALE_REQUIRED', '22023', 'a proposal says what is proposed and why');
  end if;
  if p_confidence is null or p_confidence not in ('low', 'medium', 'high') then
    perform verification.chain_fail('CONFIDENCE_INVALID', '22023', 'confidence is low, medium or high');
  end if;
  if jsonb_typeof(v_target) <> 'object' or jsonb_typeof(v_basis) <> 'array'
     or exists (select 1 from jsonb_object_keys(v_target) k where k not in ('segment_id', 'event_id', 'relationship_id')) then
    perform verification.chain_fail('TARGET_INVALID', '22023', 'p_target is {"segment_id"} or {"event_id"} or {"relationship_id"}; p_basis is an array');
  end if;
  v_author := case when v_person then coalesce(nullif(btrim(p_actor ->> 'label'), ''), catalog.caller_role()) else ctx ->> 'acting' end;
  v_id := util.uuidv7();
  v_result := verification.chain_record('api.propose', ctx, v_request,
    jsonb_build_object('proposal_id', v_id, 'review_state', case when v_person then 'person_proposed' else 'agent_proposed' end, 'publication', 'private'),
    jsonb_build_array(jsonb_build_object('schema', 'catalog', 'table', 'proposal', 'id', v_id)));
  v_receipt := (v_result ->> 'receipt_id')::uuid;
  insert into catalog.proposal(id, tenant_id, proposal_kind, subject_entity_id, object_entity_id, relationship_kind, label, target_segment_id, target_event_id, target_relationship_id, cause_event_id,
    statement, rationale, world_during, confidence, authored_by_kind, authored_by, review_state, publication, created_by_receipt_id)
  values (v_id, v_tenant, p_kind, p_subject, p_object, p_relationship_kind, nullif(btrim(p_label), ''), (v_target ->> 'segment_id')::uuid, (v_target ->> 'event_id')::uuid, (v_target ->> 'relationship_id')::uuid, p_cause_event,
    btrim(p_statement), btrim(p_rationale), p_world_during, p_confidence, case when v_person then 'person' else 'agent' end, v_author,
    case when v_person then 'person_proposed' else 'agent_proposed' end, 'private', v_receipt);
  for b in select * from jsonb_array_elements(v_basis) loop
    if jsonb_typeof(b) <> 'object' or exists (select 1 from jsonb_object_keys(b) k where k not in ('claim_id', 'segment_id', 'event_id', 'relationship_id', 'role', 'note')) then
      perform verification.chain_fail('BASIS_INVALID', '22023', 'a basis is {"claim_id" | "segment_id" | "event_id" | "relationship_id", "role" (basis or counter), "note"}');
    end if;
    insert into catalog.proposal_basis(tenant_id, proposal_id, role, claim_id, segment_id, event_id, relationship_id, note)
    values (v_tenant, v_id, coalesce(b ->> 'role', 'basis'), (b ->> 'claim_id')::uuid, (b ->> 'segment_id')::uuid, (b ->> 'event_id')::uuid, (b ->> 'relationship_id')::uuid, b ->> 'note');
  end loop;
  perform verification.chain_target(ctx, v_receipt, 'catalog', 'proposal', v_id, 'subject', 'created');
  return v_result;
end $$;
revoke all on function api.propose(text, text, text, text, text, uuid, uuid, text, text, jsonb, uuid, tstzrange, jsonb, jsonb) from public;
grant execute on function api.propose(text, text, text, text, text, uuid, uuid, text, text, jsonb, uuid, tstzrange, jsonb, jsonb) to pipeline_agent, executor_service;
comment on function api.propose(text, text, text, text, text, uuid, uuid, text, text, jsonb, uuid, tstzrange, jsonb, jsonb) is
  'Record a proposal: our own view of a relationship, of the cause of a recorded change, or of an identity. An agent role writes agent_proposed and private; nothing here is a fact.';

create function api.decide_proposal(p_proposal uuid, p_decision text, p_note text default null, p_outcome_claim uuid default null, p_decided_by text default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare p catalog.proposal;
begin
  if not catalog.caller_is_person() then
    raise exception 'HUMAN_REVIEW_NOT_AGENT_WRITABLE' using errcode = '42501', detail = format('a decision on a proposal is a person''s judgment; role %s is not a person', catalog.caller_role());
  end if;
  select * into p from catalog.proposal x where x.id = p_proposal and x.tenant_id = util.current_tenant_id() for update;
  if not found then raise exception 'PROPOSAL_NOT_FOUND' using errcode = 'P0002'; end if;
  if p_decision is null or p_decision not in ('endorsed', 'rejected', 'withdrawn', 'confirmed_by_source', 'refuted_by_source') then
    raise exception 'DECISION_INVALID' using errcode = '22023', detail = 'endorsed, rejected, withdrawn, confirmed_by_source or refuted_by_source';
  end if;
  if p_decision in ('confirmed_by_source', 'refuted_by_source') and p_outcome_claim is null then
    raise exception 'OUTCOME_CLAIM_REQUIRED' using errcode = '22023', detail = 'name the sourced claim that confirmed or refuted the proposal';
  end if;
  update catalog.proposal set review_state = p_decision, decided_by = coalesce(nullif(btrim(p_decided_by), ''), catalog.caller_role()), decided_at = clock_timestamp(), decision_note = p_note,
         outcome_claim_id = coalesce(p_outcome_claim, outcome_claim_id), updated_at = clock_timestamp(),
         publication = case when p_decision in ('rejected', 'withdrawn', 'refuted_by_source') then 'private' else publication end,
         published_at = case when p_decision in ('rejected', 'withdrawn', 'refuted_by_source') then null else published_at end
   where id = p.id;
  return jsonb_build_object('proposal_id', p.id, 'review_state', p_decision, 'was', p.review_state);
end $$;
create function api.publish_proposal(p_proposal uuid, p_publish boolean default true, p_published_by text default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare p catalog.proposal;
begin
  if not catalog.caller_is_person() then
    raise exception 'HUMAN_REVIEW_NOT_AGENT_WRITABLE' using errcode = '42501', detail = format('publishing a proposal is a person''s decision; role %s is not a person', catalog.caller_role());
  end if;
  select * into p from catalog.proposal x where x.id = p_proposal and x.tenant_id = util.current_tenant_id() for update;
  if not found then raise exception 'PROPOSAL_NOT_FOUND' using errcode = 'P0002'; end if;
  if p_publish and p.review_state not in ('person_proposed', 'endorsed', 'confirmed_by_source') then
    raise exception 'PROPOSAL_NOT_REVIEWED' using errcode = '23514', detail = format('a proposal is published after a person proposed or endorsed it; this one is %s', p.review_state);
  end if;
  update catalog.proposal set publication = case when p_publish then 'published' else 'private' end, published_at = case when p_publish then clock_timestamp() end,
         published_by = case when p_publish then coalesce(nullif(btrim(p_published_by), ''), catalog.caller_role()) end, updated_at = clock_timestamp() where id = p.id;
  return jsonb_build_object('proposal_id', p.id, 'publication', case when p_publish then 'published' else 'private' end);
end $$;
revoke all on function api.decide_proposal(uuid, text, text, uuid, text) from public;
revoke all on function api.publish_proposal(uuid, boolean, text) from public;
comment on function api.decide_proposal(uuid, text, text, uuid, text) is 'A person endorses, rejects or withdraws a proposal, or marks it confirmed or refuted by a sourced claim. Not granted to any agent role.';
comment on function api.publish_proposal(uuid, boolean, text) is 'A person publishes (or unpublishes) a proposal. Not granted to any agent role.';

create function api.proposals(p_entity uuid default null, p_segment uuid default null, p_event uuid default null, p_relationship uuid default null, p_review_states text[] default null)
returns table(proposal_id uuid, proposal_kind text, statement text, rationale text, confidence text, authored_by_kind text, authored_by text, review_state text, publication text,
  subject_entity_id uuid, subject text, object_entity_id uuid, object text, relationship_kind text, label text, target jsonb, cause_event_id uuid, basis jsonb, outcome_claim_id uuid, created_at timestamptz)
language sql stable security definer set search_path = '' as $$
  select p.id, p.proposal_kind, p.statement, p.rationale, p.confidence, p.authored_by_kind, p.authored_by, p.review_state, p.publication,
    p.subject_entity_id, s.display_name, p.object_entity_id, o.display_name, p.relationship_kind, p.label,
    jsonb_strip_nulls(jsonb_build_object('segment_id', p.target_segment_id, 'event_id', p.target_event_id, 'relationship_id', p.target_relationship_id)), p.cause_event_id,
    coalesce((select jsonb_agg(jsonb_strip_nulls(jsonb_build_object('role', b.role, 'claim_id', b.claim_id, 'segment_id', b.segment_id, 'event_id', b.event_id, 'relationship_id', b.relationship_id, 'note', b.note)))
                from catalog.proposal_basis b where b.proposal_id = p.id), '[]'::jsonb),
    p.outcome_claim_id, p.created_at
  from catalog.proposal p left join catalog.entity s on s.id = p.subject_entity_id left join catalog.entity o on o.id = p.object_entity_id
  where p.tenant_id = util.current_tenant_id()
    and (p.publication = 'published' or catalog.caller_is_person() or catalog.caller_role() in ('executor_service', 'pipeline_agent', 'verifier_agent', 'control_plane', 'service_role'))
    and (p_entity is null or p.subject_entity_id = p_entity or p.object_entity_id = p_entity)
    and (p_segment is null or p.target_segment_id = p_segment) and (p_event is null or p.target_event_id = p_event or p.cause_event_id = p_event)
    and (p_relationship is null or p.target_relationship_id = p_relationship) and (p_review_states is null or p.review_state = any(p_review_states))
  order by p.created_at
$$;
revoke all on function api.proposals(uuid, uuid, uuid, uuid, text[]) from public;
grant execute on function api.proposals(uuid, uuid, uuid, uuid, text[]) to app_reader, authenticated, pipeline_agent, verifier_agent, control_plane, executor_service, service_role;
comment on function api.proposals(uuid, uuid, uuid, uuid, text[]) is 'Proposals about an entity or a change. The service''s reader roles see published ones only; agent and control roles see private ones too.';

-- ============================================================================================ C. our mistakes on identity: merge and split
alter table catalog.entity_merge
  add column reason_code text references temporal.correction_reason(code),
  add column note text,
  add column proposal_id uuid references catalog.proposal(id),
  add column knowledge_seq bigint,
  add column undone_at timestamptz,
  add column undone_receipt_id uuid references orchestration.operation_receipt(id);
comment on table catalog.entity_merge is 'A merge of two records that were one thing (our mistake, never a merger in the world). Written by catalog.merge_entities; what moved is in catalog.identity_move; undone_at marks a merge that was reversed.';

create table catalog.entity_split (
  id uuid primary key default util.uuidv7(),
  tenant_id uuid not null default util.current_tenant_id(),
  from_entity_id uuid not null references catalog.entity(id),
  reason_code text not null references temporal.correction_reason(code),
  note text,
  proposal_id uuid references catalog.proposal(id),
  receipt_id uuid not null references orchestration.operation_receipt(id),
  knowledge_seq bigint,
  source_retired boolean not null default false,
  undone_at timestamptz,
  created_at timestamptz not null default now(),
  unique (tenant_id, id)
);
comment on table catalog.entity_split is 'A split of one record that mixed several things (our mistake, never a split in the world). The parts are in catalog.entity_split_part; what moved is in catalog.identity_move.';
create table catalog.entity_split_part (
  tenant_id uuid not null default util.current_tenant_id(),
  split_id uuid not null references catalog.entity_split(id),
  to_entity_id uuid not null references catalog.entity(id),
  primary key (split_id, to_entity_id)
);
comment on table catalog.entity_split_part is 'One record that a mixed record was split into.';
create table catalog.identity_move (
  id uuid primary key default util.uuidv7(),
  seq bigint generated always as identity,
  tenant_id uuid not null default util.current_tenant_id(),
  merge_id uuid references catalog.entity_merge(id),
  split_id uuid references catalog.entity_split(id),
  table_name text not null,
  column_name text,
  row_key jsonb not null,
  action text not null check (action in ('moved', 'closed_as_duplicate', 'kept_on_source', 'adopted', 'added')),
  detail jsonb not null default '{}'::jsonb,
  undone boolean not null default false,
  created_at timestamptz not null default now(),
  constraint identity_move_one_parent check (num_nonnulls(merge_id, split_id) = 1)
);
comment on table catalog.identity_move is 'One row per row touched by a merge or a split: moved, closed_as_duplicate (the winner already had it), kept_on_source (the table refused the change), adopted (a move made earlier by hand, now recorded) or added (an alias). The log an undo reads.';
create index identity_move_merge_idx on catalog.identity_move (merge_id);
create index identity_move_split_idx on catalog.identity_move (split_id);
alter table catalog.entity_split enable row level security;
alter table catalog.entity_split_part enable row level security;
alter table catalog.identity_move enable row level security;
create policy km_tenant_access on catalog.entity_split to control_plane, executor_service, pipeline_agent, verifier_agent using (tenant_id = util.current_tenant_id()) with check (tenant_id = util.current_tenant_id());
create policy km_tenant_access on catalog.entity_split_part to control_plane, executor_service, pipeline_agent, verifier_agent using (tenant_id = util.current_tenant_id()) with check (tenant_id = util.current_tenant_id());
create policy km_tenant_access on catalog.identity_move to control_plane, executor_service, pipeline_agent, verifier_agent using (tenant_id = util.current_tenant_id()) with check (tenant_id = util.current_tenant_id());
grant select on catalog.entity_split, catalog.entity_split_part, catalog.identity_move to control_plane, executor_service, pipeline_agent, verifier_agent;

create function catalog.canonical_entity(p_entity uuid) returns uuid language plpgsql stable security definer set search_path = '' as $$
declare v uuid := p_entity; nxt uuid; i integer := 0;
begin
  loop
    select e.merged_into_id into nxt from catalog.entity e where e.id = v and e.lifecycle = 'merged';
    exit when nxt is null or i >= 16;
    v := nxt; i := i + 1;
  end loop;
  return v;
end $$;
comment on function catalog.canonical_entity(uuid) is 'The record a merged record now stands for (itself when it was never merged). Use it where a read returns an entity id from rows a merge could not move.';
grant execute on function catalog.canonical_entity(uuid) to app_reader, authenticated, pipeline_agent, verifier_agent, control_plane, executor_service, service_role;

create function catalog.entity_references(p_entity uuid) returns table(table_name text, column_name text, row_count bigint)
language plpgsql stable security definer set search_path = '' as $$
declare fk record;
begin
  for fk in
    select c.conrelid::regclass::text as tbl, a.attname::text as col
      from pg_catalog.pg_constraint c
      cross join lateral unnest(c.conkey, c.confkey) as k(con, conf)
      join pg_catalog.pg_attribute a on a.attrelid = c.conrelid and a.attnum = k.con
      join pg_catalog.pg_attribute fa on fa.attrelid = c.confrelid and fa.attnum = k.conf
     where c.contype = 'f' and c.confrelid = 'catalog.entity'::regclass and fa.attname = 'id'
     group by 1, 2 order by 1, 2
  loop
    table_name := fk.tbl; column_name := fk.col;
    execute format('select count(*) from %s x where x.%I = $1', fk.tbl, fk.col) into row_count using p_entity;
    if row_count > 0 then return next; end if;
  end loop;
end $$;
comment on function catalog.entity_references(uuid) is 'Every table and column that points at this record, with a row count. What a merge has to move.';
revoke all on function catalog.entity_references(uuid) from public;
grant execute on function catalog.entity_references(uuid) to pipeline_agent, verifier_agent, control_plane, executor_service, service_role;

-- internal helpers of merge, undo and split (not granted)
create function catalog._row_key(p_table regclass, p_row jsonb) returns jsonb language sql stable set search_path = '' as $$
  select coalesce((select jsonb_object_agg(a.attname, p_row -> a.attname::text) from pg_catalog.pg_index i join pg_catalog.pg_attribute a on a.attrelid = i.indrelid and a.attnum = any(i.indkey)
                    where i.indrelid = p_table and i.indisprimary), p_row)
$$;
create function catalog._log_move(p_merge uuid, p_split uuid, p_table text, p_column text, p_row_key jsonb, p_action text, p_detail jsonb default '{}'::jsonb) returns void
language sql set search_path = '' as $$
  insert into catalog.identity_move(merge_id, split_id, table_name, column_name, row_key, action, detail) values (p_merge, p_split, p_table, p_column, p_row_key, p_action, coalesce(p_detail, '{}'::jsonb))
$$;
create function catalog._ensure_stream(p_kind text, p_entity uuid, p_relationship uuid, p_scope_key text) returns uuid language plpgsql set search_path = '' as $$
declare v uuid; t uuid := util.current_tenant_id();
begin
  insert into temporal.stream(kind, subject_entity_id, subject_relationship_id, scope_key) values (p_kind, p_entity, p_relationship, p_scope_key) on conflict do nothing;
  select id into strict v from temporal.stream where tenant_id = t and kind = p_kind and subject_entity_id is not distinct from p_entity and subject_relationship_id is not distinct from p_relationship and scope_key = p_scope_key;
  return v;
end $$;
-- close one current fact and reopen it on another stream (or with another ref entity); null when the target already holds a fact for that time
create function catalog._move_segment(p_segment uuid, p_stream uuid, p_ref uuid, p_reason text) returns uuid language plpgsql set search_path = '' as $$
declare g temporal.segment; v_new uuid;
begin
  select * into strict g from temporal.segment where id = p_segment and tenant_id = util.current_tenant_id() and k_to is null;
  perform temporal.close_segment(g.id);
  if exists (select 1 from temporal.segment x where x.stream_id = p_stream and x.k_to is null and x.valid_during && g.valid_during) then return null; end if;
  insert into temporal.segment(stream_id, valid_during, belief, temporal_basis, status, amount, currency, unit, ref_entity_id, payload, extent_id, caused_by_event_id, replaces_segment_id, primary_claim_id, revision_kind, correction_reason)
  values (p_stream, g.valid_during, g.belief, g.temporal_basis, g.status, g.amount, g.currency, g.unit, coalesce(p_ref, g.ref_entity_id), g.payload, g.extent_id, g.caused_by_event_id, g.id, g.primary_claim_id, 'correction', p_reason)
  returning id into v_new;
  insert into evidence.segment_support(segment_id, claim_id, locator_id, role) select v_new, s.claim_id, s.locator_id, s.role from evidence.segment_support s where s.segment_id = g.id and s.k_to is null;
  return v_new;
end $$;
-- reopen a fact that was closed (a copy on its own stream); null when the stream already holds a fact for that time
create function catalog._reopen_segment(p_segment uuid, p_reason text) returns uuid language plpgsql set search_path = '' as $$
declare g temporal.segment; v_new uuid;
begin
  select * into strict g from temporal.segment where id = p_segment and tenant_id = util.current_tenant_id();
  if exists (select 1 from temporal.segment x where x.stream_id = g.stream_id and x.k_to is null and x.valid_during && g.valid_during) then return null; end if;
  insert into temporal.segment(stream_id, valid_during, belief, temporal_basis, status, amount, currency, unit, ref_entity_id, payload, extent_id, caused_by_event_id, replaces_segment_id, primary_claim_id, revision_kind, correction_reason)
  values (g.stream_id, g.valid_during, g.belief, g.temporal_basis, g.status, g.amount, g.currency, g.unit, g.ref_entity_id, g.payload, g.extent_id, g.caused_by_event_id, g.id, g.primary_claim_id, 'correction', p_reason)
  returning id into v_new;
  insert into evidence.segment_support(segment_id, claim_id, locator_id, role) select v_new, s.claim_id, s.locator_id, s.role from evidence.segment_support s where s.segment_id = g.id and s.k_to is null;
  return v_new;
end $$;
-- copy the current facts of one edge's streams onto another edge (closing them on the first when it is still current)
create function catalog._carry_relationship_streams(p_from_rel uuid, p_to_rel uuid, p_reason text) returns void language plpgsql set search_path = '' as $$
declare st temporal.stream; g record; v_stream uuid;
begin
  for st in select * from temporal.stream where tenant_id = util.current_tenant_id() and subject_relationship_id = p_from_rel loop
    v_stream := catalog._ensure_stream(st.kind, null, p_to_rel, st.scope_key);
    for g in select id from temporal.segment where stream_id = st.id and k_to is null and k_from < temporal.current_k() order by lower(valid_during) loop
      perform catalog._move_segment(g.id, v_stream, null, p_reason);
    end loop;
  end loop;
end $$;
-- close one current edge as a correction and reopen it between other endpoints; null when it would join a record to itself or the edge already exists
create function catalog._move_relationship(p_relationship uuid, p_from uuid, p_to uuid, p_reason text) returns uuid language plpgsql set search_path = '' as $$
declare r catalog.relationship; v_new uuid; t uuid := util.current_tenant_id();
begin
  select * into strict r from catalog.relationship where id = p_relationship and tenant_id = t and k_to is null;
  update catalog.relationship set k_to = temporal.current_k(), closed_kind = 'correction', closed_reason = p_reason where id = r.id;
  if p_from = p_to then return null; end if;
  if exists (select 1 from catalog.relationship x where x.tenant_id = t and x.kind = r.kind and x.from_entity_id = p_from and x.to_entity_id = p_to and x.qualifier = r.qualifier and x.episode = r.episode and x.k_to is null) then return null; end if;
  insert into catalog.relationship(kind, from_entity_id, to_entity_id, qualifier, episode, properties, primary_claim_id) values (r.kind, p_from, p_to, r.qualifier, r.episode, r.properties, r.primary_claim_id) returning id into v_new;
  perform catalog._carry_relationship_streams(r.id, v_new, p_reason);
  return v_new;
end $$;
-- repoint every other table that points at p_from to p_to, row by row, logging what moved and what the table refused
create function catalog._repoint_references(p_from uuid, p_to uuid, p_merge uuid, p_split uuid) returns integer language plpgsql set search_path = '' as $$
declare fk record; rec record; v_key jsonb; v_moved integer := 0;
begin
  for fk in
    select c.conrelid::regclass::text as tbl, a.attname::text as col
      from pg_catalog.pg_constraint c
      cross join lateral unnest(c.conkey, c.confkey) as k(con, conf)
      join pg_catalog.pg_attribute a on a.attrelid = c.conrelid and a.attnum = k.con
      join pg_catalog.pg_attribute fa on fa.attrelid = c.confrelid and fa.attnum = k.conf
     where c.contype = 'f' and c.confrelid = 'catalog.entity'::regclass and fa.attname = 'id'
       and c.conrelid::regclass::text not in ('catalog.entity', 'catalog.entity_alias', 'catalog.entity_identifier', 'catalog.entity_merge', 'catalog.entity_split', 'catalog.entity_split_part',
                                               'catalog.relationship', 'temporal.stream', 'temporal.segment', 'temporal.event', 'orchestration.operation_receipt_target')
       and not (c.conrelid::regclass::text = 'catalog.work' and a.attname = 'id')
     group by 1, 2 order by 1, 2
  loop
    for rec in execute format('select to_jsonb(x) as j from %s x where x.%I = $1', fk.tbl, fk.col) using p_from loop
      v_key := catalog._row_key(fk.tbl::regclass, rec.j);
      begin
        execute format('update %s x set %I = $1 where x.%I = $2 and to_jsonb(x) @> $3', fk.tbl, fk.col, fk.col) using p_to, p_from, v_key;
        perform catalog._log_move(p_merge, p_split, fk.tbl, fk.col, v_key, 'moved', jsonb_build_object('from', p_from, 'to', p_to, 'key_after', v_key || jsonb_build_object(fk.col, p_to)));
        v_moved := v_moved + 1;
      exception when others then
        perform catalog._log_move(p_merge, p_split, fk.tbl, fk.col, v_key, 'kept_on_source', jsonb_build_object('refused', sqlerrm));
      end;
    end loop;
  end loop;
  return v_moved;
end $$;

create function catalog.merge_entities(p_loser uuid, p_winner uuid, p_receipt uuid, p_reason text default 'duplicate_record', p_note text default null, p_proposal uuid default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare t uuid := util.current_tenant_id(); k bigint; l catalog.entity; w catalog.entity; v_merge uuid := util.uuidv7();
  st temporal.stream; g record; r catalog.relationship; rec record; v_stream uuid; v_new uuid; v_from uuid; v_to uuid; v_alias uuid;
begin
  select * into l from catalog.entity where id = p_loser and tenant_id = t for update;
  if not found then raise exception 'merge: no record %', p_loser using errcode = 'P0002'; end if;
  select * into w from catalog.entity where id = p_winner and tenant_id = t for update;
  if not found then raise exception 'merge: no record %', p_winner using errcode = 'P0002'; end if;
  if p_loser = p_winner then raise exception 'merge: a record cannot be merged into itself' using errcode = '23514'; end if;
  if l.kind <> w.kind then raise exception 'merge: both records must be of the same kind (% and %)', l.kind, w.kind using errcode = '23514'; end if;
  if l.lifecycle = 'merged' and l.merged_into_id = p_winner then
    return jsonb_build_object('status', 'already_merged', 'merge_id', (select m.id from catalog.entity_merge m where m.from_entity_id = p_loser and m.to_entity_id = p_winner and m.undone_at is null order by m.created_at desc limit 1));
  end if;
  if l.lifecycle <> 'active' then raise exception 'merge: record % is % and cannot be merged again', p_loser, l.lifecycle using errcode = '23514'; end if;
  if w.lifecycle <> 'active' then raise exception 'merge: the winner % is %, not active', p_winner, w.lifecycle using errcode = '23514'; end if;
  if p_reason is null or p_reason = 'not_recorded' or not exists (select 1 from temporal.correction_reason cr where cr.code = p_reason and 'merge' = any(cr.applies_to)) then
    raise exception 'merge: % is not a reason for a merge', coalesce(p_reason, '(none)') using errcode = '23514';
  end if;
  k := temporal.current_k();
  if k is null then raise exception 'no open knowledge batch'; end if;

  insert into catalog.entity_merge(id, from_entity_id, to_entity_id, reason, receipt_id, reason_code, note, proposal_id, knowledge_seq)
  values (v_merge, p_loser, p_winner, coalesce(nullif(btrim(p_note), ''), (select description from temporal.correction_reason where code = p_reason)), p_receipt, p_reason, p_note, p_proposal, k);

  -- facts about the loser
  for st in select * from temporal.stream where tenant_id = t and subject_entity_id = p_loser loop
    v_stream := catalog._ensure_stream(st.kind, p_winner, null, st.scope_key);
    for g in select id from temporal.segment where stream_id = st.id and k_to is null order by lower(valid_during) loop
      v_new := catalog._move_segment(g.id, v_stream, null, 'duplicate_record');
      perform catalog._log_move(v_merge, null, 'temporal.segment', 'stream_id', jsonb_build_object('id', g.id), case when v_new is null then 'closed_as_duplicate' else 'moved' end,
        jsonb_build_object('stream_kind', st.kind, 'scope_key', st.scope_key, 'from_stream', st.id, 'to_stream', v_stream, 'to_segment', v_new));
    end loop;
  end loop;
  -- facts that name the loser as their reference
  for g in select s.id, s.stream_id from temporal.segment s where s.tenant_id = t and s.ref_entity_id = p_loser and s.k_to is null and s.k_from < k loop
    v_new := catalog._move_segment(g.id, g.stream_id, p_winner, 'duplicate_record');
    perform catalog._log_move(v_merge, null, 'temporal.segment', 'ref_entity_id', jsonb_build_object('id', g.id), 'moved', jsonb_build_object('from_stream', g.stream_id, 'to_stream', g.stream_id, 'to_segment', v_new, 'ref_was', p_loser));
  end loop;
  -- edges
  for r in select * from catalog.relationship where tenant_id = t and k_to is null and (from_entity_id = p_loser or to_entity_id = p_loser) loop
    v_from := case when r.from_entity_id = p_loser then p_winner else r.from_entity_id end;
    v_to := case when r.to_entity_id = p_loser then p_winner else r.to_entity_id end;
    v_new := catalog._move_relationship(r.id, v_from, v_to, 'duplicate_record');
    perform catalog._log_move(v_merge, null, 'catalog.relationship', null, jsonb_build_object('id', r.id), case when v_new is null then 'closed_as_duplicate' else 'moved' end,
      jsonb_build_object('kind', r.kind, 'from_was', r.from_entity_id, 'to_was', r.to_entity_id, 'to_relationship', v_new));
  end loop;
  -- events (an event row has no knowledge clock: the subject or object is repointed and logged)
  for rec in select e.id, e.subject_entity_id, e.object_entity_id from temporal.event e where e.tenant_id = t and (e.subject_entity_id = p_loser or e.object_entity_id = p_loser) loop
    begin
      update temporal.event set subject_entity_id = case when subject_entity_id = p_loser then p_winner else subject_entity_id end,
                                object_entity_id = case when object_entity_id = p_loser then p_winner else object_entity_id end where id = rec.id;
      perform catalog._log_move(v_merge, null, 'temporal.event', null, jsonb_build_object('id', rec.id), 'moved', jsonb_build_object('subject_was', rec.subject_entity_id, 'object_was', rec.object_entity_id));
    exception when others then
      perform catalog._log_move(v_merge, null, 'temporal.event', null, jsonb_build_object('id', rec.id), 'kept_on_source', jsonb_build_object('refused', sqlerrm));
    end;
  end loop;
  -- identifiers and names
  for rec in select i.id from catalog.entity_identifier i where i.tenant_id = t and i.entity_id = p_loser loop
    update catalog.entity_identifier set entity_id = p_winner where id = rec.id;
    perform catalog._log_move(v_merge, null, 'catalog.entity_identifier', 'entity_id', jsonb_build_object('id', rec.id), 'moved');
  end loop;
  for rec in select a.id from catalog.entity_alias a where a.tenant_id = t and a.entity_id = p_loser loop
    begin
      update catalog.entity_alias set entity_id = p_winner where id = rec.id;
      perform catalog._log_move(v_merge, null, 'catalog.entity_alias', 'entity_id', jsonb_build_object('id', rec.id), 'moved');
    exception when unique_violation then
      perform catalog._log_move(v_merge, null, 'catalog.entity_alias', 'entity_id', jsonb_build_object('id', rec.id), 'kept_on_source', jsonb_build_object('refused', 'the winner already has this alias'));
    end;
  end loop;
  if lower(btrim(l.display_name)) <> lower(btrim(w.display_name)) then
    insert into catalog.entity_alias(entity_id, alias, alias_kind) values (p_winner, l.display_name, 'synonym') on conflict do nothing returning id into v_alias;
    if v_alias is not null then perform catalog._log_move(v_merge, null, 'catalog.entity_alias', null, jsonb_build_object('id', v_alias), 'added', jsonb_build_object('alias', l.display_name, 'alias_kind', 'synonym')); end if;
  end if;
  if l.slug <> w.slug then
    v_alias := null;
    insert into catalog.entity_alias(entity_id, alias, alias_kind) values (p_winner, l.slug, 'slug') on conflict do nothing returning id into v_alias;
    if v_alias is not null then perform catalog._log_move(v_merge, null, 'catalog.entity_alias', null, jsonb_build_object('id', v_alias), 'added', jsonb_build_object('alias', l.slug, 'alias_kind', 'slug')); end if;
  end if;
  -- every other table that points at the loser
  perform catalog._repoint_references(p_loser, p_winner, v_merge, null);
  update catalog.entity set lifecycle = 'merged', merged_into_id = p_winner, updated_at = clock_timestamp() where id = p_loser;
  return jsonb_build_object('status', 'merged', 'merge_id', v_merge, 'loser', p_loser, 'winner', p_winner, 'knowledge_seq', k,
    'moves', coalesce((select jsonb_object_agg(x.action, x.n) from (select m.action, count(*) n from catalog.identity_move m where m.merge_id = v_merge group by 1) x), '{}'::jsonb));
end $$;
comment on function catalog.merge_entities(uuid, uuid, uuid, text, text, uuid) is
  'Merge a duplicate record into its twin, inside an open knowledge batch. Facts and edges close on the loser and reopen on the winner as corrections (duplicate_record); where both hold a fact for the same time the winner''s stays. Identifiers, names and other references move; rows a table refuses to change stay and are logged. Same kind only. Undo with catalog.undo_merge.';

create function catalog.undo_merge(p_merge uuid, p_receipt uuid, p_note text default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare t uuid := util.current_tenant_id(); m catalog.entity_merge; mv catalog.identity_move; g temporal.segment; r catalog.relationship; v_new uuid; v_skipped integer := 0; v_done integer := 0;
begin
  select * into m from catalog.entity_merge where id = p_merge and tenant_id = t for update;
  if not found then raise exception 'undo: no merge %', p_merge using errcode = 'P0002'; end if;
  if m.undone_at is not null then return jsonb_build_object('status', 'already_undone', 'merge_id', m.id); end if;
  if temporal.current_k() is null then raise exception 'no open knowledge batch'; end if;
  if not exists (select 1 from catalog.entity e where e.id = m.from_entity_id and e.lifecycle = 'merged' and e.merged_into_id = m.to_entity_id) then
    raise exception 'undo: the record is no longer merged into that winner' using errcode = '23514';
  end if;
  update catalog.entity set lifecycle = 'active', merged_into_id = null, updated_at = clock_timestamp() where id = m.from_entity_id;
  for mv in select * from catalog.identity_move where merge_id = m.id and not undone order by seq desc loop
    begin
      if mv.table_name = 'temporal.segment' and mv.action = 'moved' then
        select * into g from temporal.segment where id = (mv.detail ->> 'to_segment')::uuid;
        if g.k_to is not null then raise exception 'the moved fact was replaced since the merge'; end if;
        if mv.column_name = 'ref_entity_id' then
          perform catalog._move_segment(g.id, g.stream_id, (mv.detail ->> 'ref_was')::uuid, 'merge_undone');
        else
          perform catalog._move_segment(g.id, (mv.detail ->> 'from_stream')::uuid, null, 'merge_undone');
        end if;
      elsif mv.table_name = 'temporal.segment' and mv.action = 'closed_as_duplicate' then
        perform catalog._reopen_segment((mv.row_key ->> 'id')::uuid, 'merge_undone');
      elsif mv.table_name = 'catalog.relationship' and mv.action = 'moved' then
        perform catalog._move_relationship((mv.detail ->> 'to_relationship')::uuid, (mv.detail ->> 'from_was')::uuid, (mv.detail ->> 'to_was')::uuid, 'merge_undone');
      elsif mv.table_name = 'catalog.relationship' and mv.action = 'closed_as_duplicate' then
        select * into strict r from catalog.relationship where id = (mv.row_key ->> 'id')::uuid;
        if not exists (select 1 from catalog.relationship x where x.tenant_id = t and x.kind = r.kind and x.from_entity_id = r.from_entity_id and x.to_entity_id = r.to_entity_id and x.qualifier = r.qualifier and x.episode = r.episode and x.k_to is null) then
          insert into catalog.relationship(kind, from_entity_id, to_entity_id, qualifier, episode, properties, primary_claim_id) values (r.kind, r.from_entity_id, r.to_entity_id, r.qualifier, r.episode, r.properties, r.primary_claim_id) returning id into v_new;
          perform catalog._carry_relationship_streams(r.id, v_new, 'merge_undone');
        end if;
      elsif mv.table_name = 'temporal.event' and mv.action = 'moved' then
        update temporal.event set subject_entity_id = (mv.detail ->> 'subject_was')::uuid, object_entity_id = (mv.detail ->> 'object_was')::uuid where id = (mv.row_key ->> 'id')::uuid;
      elsif mv.table_name in ('catalog.entity_identifier', 'catalog.entity_alias') and mv.action = 'moved' then
        execute format('update %s set entity_id = $1 where id = $2', mv.table_name) using m.from_entity_id, (mv.row_key ->> 'id')::uuid;
      elsif mv.table_name = 'catalog.entity_alias' and mv.action = 'added' then
        delete from catalog.entity_alias where id = (mv.row_key ->> 'id')::uuid;
      elsif mv.action = 'moved' then
        execute format('update %s x set %I = $1 where x.%I = $2 and to_jsonb(x) @> $3', mv.table_name, mv.column_name, mv.column_name) using m.from_entity_id, m.to_entity_id, mv.detail -> 'key_after';
      end if;
      if mv.action <> 'kept_on_source' then
        update catalog.identity_move set undone = true where id = mv.id;
        v_done := v_done + 1;
      end if;
    exception when others then
      v_skipped := v_skipped + 1;
      update catalog.identity_move set detail = detail || jsonb_build_object('undo_refused', sqlerrm) where id = mv.id;
    end;
  end loop;
  update catalog.entity_merge set undone_at = clock_timestamp(), undone_receipt_id = p_receipt, note = concat_ws(' | ', note, 'undone: ' || coalesce(p_note, 'no note')) where id = m.id;
  return jsonb_build_object('status', 'undone', 'merge_id', m.id, 'reversed', v_done, 'not_reversed', v_skipped);
end $$;
comment on function catalog.undo_merge(uuid, uuid, text) is 'Reverse a merge from its move log, inside an open knowledge batch. History keeps both the merge and its undoing.';

create function catalog.split_entity(p_source uuid, p_parts jsonb, p_receipt uuid, p_reason text default 'mixed_record', p_note text default null, p_proposal uuid default null, p_retire_source boolean default false)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare t uuid := util.current_tenant_id(); k bigint := temporal.current_k(); s catalog.entity; part jsonb; pe catalog.entity; v_split uuid := util.uuidv7();
  x text; r catalog.relationship; st temporal.stream; g record; v_new uuid; v_stream uuid; pair jsonb; v_from uuid; v_to uuid;
begin
  if k is null then raise exception 'no open knowledge batch'; end if;
  select * into s from catalog.entity where id = p_source and tenant_id = t for update;
  if not found then raise exception 'split: no record %', p_source using errcode = 'P0002'; end if;
  if s.lifecycle <> 'active' then raise exception 'split: record % is %, not active', p_source, s.lifecycle using errcode = '23514'; end if;
  if jsonb_typeof(p_parts) <> 'array' or jsonb_array_length(p_parts) < 1 then raise exception 'split: p_parts is an array of at least one part' using errcode = '22023'; end if;
  if p_reason is null or p_reason = 'not_recorded' or not exists (select 1 from temporal.correction_reason cr where cr.code = p_reason and 'split' = any(cr.applies_to)) then
    raise exception 'split: % is not a reason for a split', coalesce(p_reason, '(none)') using errcode = '23514';
  end if;
  insert into catalog.entity_split(id, from_entity_id, reason_code, note, proposal_id, receipt_id, knowledge_seq, source_retired) values (v_split, p_source, p_reason, p_note, p_proposal, p_receipt, k, p_retire_source);
  for part in select * from jsonb_array_elements(p_parts) loop
    select * into pe from catalog.entity where id = (part ->> 'entity_id')::uuid and tenant_id = t;
    if not found then raise exception 'split: no part record %', part ->> 'entity_id' using errcode = 'P0002'; end if;
    if pe.id = p_source then raise exception 'split: a part cannot be the mixed record itself' using errcode = '23514'; end if;
    if pe.kind <> s.kind or pe.lifecycle <> 'active' then raise exception 'split: part % must be an active record of kind %', pe.id, s.kind using errcode = '23514'; end if;
    insert into catalog.entity_split_part(split_id, to_entity_id) values (v_split, pe.id);
    for x in select jsonb_array_elements_text(coalesce(part -> 'relationships', '[]'::jsonb)) loop
      select * into r from catalog.relationship where id = x::uuid and tenant_id = t and k_to is null and (from_entity_id = p_source or to_entity_id = p_source);
      if not found then raise exception 'split: % is not a current edge of the mixed record', x using errcode = '23514'; end if;
      v_from := case when r.from_entity_id = p_source then pe.id else r.from_entity_id end;
      v_to := case when r.to_entity_id = p_source then pe.id else r.to_entity_id end;
      v_new := catalog._move_relationship(r.id, v_from, v_to, 'wrong_entity');
      perform catalog._log_move(null, v_split, 'catalog.relationship', null, jsonb_build_object('id', r.id), case when v_new is null then 'closed_as_duplicate' else 'moved' end,
        jsonb_build_object('kind', r.kind, 'from_was', r.from_entity_id, 'to_was', r.to_entity_id, 'to_relationship', v_new, 'part', pe.id));
    end loop;
    for x in select jsonb_array_elements_text(coalesce(part -> 'streams', '[]'::jsonb)) loop
      select * into st from temporal.stream where id = x::uuid and tenant_id = t and subject_entity_id = p_source;
      if not found then raise exception 'split: % is not a fact stream of the mixed record', x using errcode = '23514'; end if;
      v_stream := catalog._ensure_stream(st.kind, pe.id, null, st.scope_key);
      for g in select id from temporal.segment where stream_id = st.id and k_to is null order by lower(valid_during) loop
        v_new := catalog._move_segment(g.id, v_stream, null, 'wrong_entity');
        perform catalog._log_move(null, v_split, 'temporal.segment', 'stream_id', jsonb_build_object('id', g.id), case when v_new is null then 'closed_as_duplicate' else 'moved' end,
          jsonb_build_object('stream_kind', st.kind, 'scope_key', st.scope_key, 'from_stream', st.id, 'to_stream', v_stream, 'to_segment', v_new, 'part', pe.id));
      end loop;
    end loop;
    for x in select jsonb_array_elements_text(coalesce(part -> 'identifiers', '[]'::jsonb)) loop
      update catalog.entity_identifier set entity_id = pe.id where id = x::uuid and tenant_id = t and entity_id = p_source;
      if not found then raise exception 'split: % is not an identifier of the mixed record', x using errcode = '23514'; end if;
      perform catalog._log_move(null, v_split, 'catalog.entity_identifier', 'entity_id', jsonb_build_object('id', x), 'moved', jsonb_build_object('part', pe.id));
    end loop;
    -- moves that were made by hand before this function existed: record them and give them their reason
    for pair in select * from jsonb_array_elements(coalesce(part -> 'adopt', '[]'::jsonb)) loop
      select * into r from catalog.relationship where id = (pair ->> 'closed')::uuid and tenant_id = t and k_to is not null and (from_entity_id = p_source or to_entity_id = p_source);
      if not found then raise exception 'split: % is not a closed edge of the mixed record', pair ->> 'closed' using errcode = '23514'; end if;
      if not exists (select 1 from catalog.relationship n where n.id = (pair ->> 'opened')::uuid and n.tenant_id = t and n.kind = r.kind and (n.from_entity_id = pe.id or n.to_entity_id = pe.id)) then
        raise exception 'split: % is not the edge that replaced it on the part', pair ->> 'opened' using errcode = '23514';
      end if;
      update catalog.relationship set closed_kind = 'correction', closed_reason = 'wrong_entity' where id = r.id and closed_reason = 'not_recorded';
      perform catalog._log_move(null, v_split, 'catalog.relationship', null, jsonb_build_object('id', r.id), 'adopted',
        jsonb_build_object('kind', r.kind, 'from_was', r.from_entity_id, 'to_was', r.to_entity_id, 'to_relationship', pair ->> 'opened', 'part', pe.id, 'closed_at_knowledge_seq', r.k_to));
    end loop;
    if part ->> 'references' = 'all' then
      perform catalog._repoint_references(p_source, pe.id, null, v_split);
    end if;
  end loop;
  if p_retire_source then
    update catalog.entity set lifecycle = 'retired', updated_at = clock_timestamp() where id = p_source;
  end if;
  return jsonb_build_object('status', 'split', 'split_id', v_split, 'source', p_source, 'knowledge_seq', k, 'source_retired', p_retire_source,
    'parts', (select jsonb_agg(sp.to_entity_id) from catalog.entity_split_part sp where sp.split_id = v_split),
    'moves', coalesce((select jsonb_object_agg(y.action, y.n) from (select m.action, count(*) n from catalog.identity_move m where m.split_id = v_split group by 1) y), '{}'::jsonb));
end $$;
comment on function catalog.split_entity(uuid, jsonb, uuid, text, text, uuid, boolean) is
  'Split a record that mixed several things, inside an open knowledge batch. Each part names the edges, fact streams and identifiers that move to it (as corrections, wrong_entity); "adopt" records moves made earlier by hand; "references":"all" repoints every other table to that part. p_retire_source retires a record that was nothing but the mix.';

revoke all on function catalog.merge_entities(uuid, uuid, uuid, text, text, uuid) from public;
revoke all on function catalog.undo_merge(uuid, uuid, text) from public;
revoke all on function catalog.split_entity(uuid, jsonb, uuid, text, text, uuid, boolean) from public;
grant execute on function catalog.merge_entities(uuid, uuid, uuid, text, text, uuid) to executor_service, service_role;
grant execute on function catalog.undo_merge(uuid, uuid, text) to executor_service, service_role;
grant execute on function catalog.split_entity(uuid, jsonb, uuid, text, text, uuid, boolean) to executor_service, service_role;
revoke all on function catalog._row_key(regclass, jsonb), catalog._log_move(uuid, uuid, text, text, jsonb, text, jsonb), catalog._ensure_stream(text, uuid, uuid, text), catalog._move_segment(uuid, uuid, uuid, text),
  catalog._reopen_segment(uuid, text), catalog._carry_relationship_streams(uuid, uuid, text), catalog._move_relationship(uuid, uuid, uuid, text), catalog._repoint_references(uuid, uuid, uuid, uuid) from public;

-- ============================================================================================ B. reads
create or replace function api.resolve_entity(p_text text) returns table(entity_id uuid, kind text, display_name text, score real)
language sql stable security definer set search_path = '' as $$
 with hit as (
   select catalog.canonical_entity(e.id) as id,
          greatest(extensions.similarity(e.display_name,p_text),
                   coalesce((select max(extensions.similarity(a.alias,p_text)) from catalog.entity_alias a where a.entity_id=e.id and a.tenant_id=e.tenant_id),0),
                   case when exists(select 1 from catalog.entity_identifier i where i.entity_id=e.id and i.tenant_id=e.tenant_id and i.value=p_text) then 1 else 0 end)::real as score
     from catalog.entity e
    where e.tenant_id=util.current_tenant_id() and e.lifecycle in ('active','merged')
      and (e.display_name operator(extensions.%) p_text or exists(select 1 from catalog.entity_alias a where a.entity_id=e.id and a.alias operator(extensions.%) p_text) or exists(select 1 from catalog.entity_identifier i where i.entity_id=e.id and i.value=p_text)))
 select c.id, c.kind, c.display_name, max(h.score) from hit h join catalog.entity c on c.id = h.id and c.lifecycle = 'active' group by c.id, c.kind, c.display_name order by 4 desc, c.id limit 25
$$;
comment on function api.resolve_entity(text) is 'Find a record by name, alias (former names included) or identifier. A merged record''s name leads to its winner.';

drop function api.changes_since(timestamptz, text[], text[], text[]);
create function api.changes_since(p_since timestamptz, p_stream_kinds text[] default null, p_entity_kinds text[] default null, p_document_types text[] default null) returns table(
  change_source text, change_kind text, learned_at timestamptz, knowledge_seq bigint, world_from timestamptz, subject_entity_id uuid, subject text, stream_kind text, scope_key text, old_value jsonb, new_value jsonb, document_id uuid, document_title text, logical_key text, unit_kind text, changed_attributes jsonb, claim_id uuid,
  revision_kind text, correction_reason text, cause_event_id uuid, cause_event_kind text)
language sql stable security definer set search_path = '' as $$
  with t as (select util.current_tenant_id() id)
  select 'fact', case when s.replaces_segment_id is null then 'opened' else 'replaced' end, kb.recorded_at, s.k_from, lower(s.valid_during), coalesce(st.subject_entity_id, sr.from_entity_id), e.display_name, st.kind, st.scope_key,
    (select jsonb_build_object('amount', o.amount, 'currency', o.currency, 'unit', o.unit, 'status', o.status, 'payload', o.payload) from temporal.segment o where o.id = s.replaces_segment_id),
    jsonb_build_object('amount', s.amount, 'currency', s.currency, 'unit', s.unit, 'status', s.status, 'payload', s.payload)
      || case when sr.id is null then '{}'::jsonb else jsonb_build_object('relationship', jsonb_build_object('id', sr.id, 'kind', sr.kind, 'to_entity_id', sr.to_entity_id, 'to', (select x.display_name from catalog.entity x where x.id = sr.to_entity_id))) end,
    null::uuid, null::text, null::text, null::text, null::jsonb, s.primary_claim_id,
    s.revision_kind, s.correction_reason, s.caused_by_event_id, (select ev.kind from temporal.event ev where ev.id = s.caused_by_event_id)
  from temporal.segment s join temporal.stream st on st.id = s.stream_id join temporal.knowledge_batch kb on kb.tenant_id = s.tenant_id and kb.knowledge_seq = s.k_from
  left join catalog.relationship sr on sr.id = st.subject_relationship_id
  left join catalog.entity e on e.id = coalesce(st.subject_entity_id, sr.from_entity_id), t
  where s.tenant_id = t.id and kb.recorded_at > p_since and s.revision_kind is distinct from 'carried'
    and (p_stream_kinds is null or st.kind = any(p_stream_kinds)) and (p_entity_kinds is null or e.kind = any(p_entity_kinds))
  union all
  select 'event', ev.kind, kb.recorded_at, o.k_from, lower(o.occurred_during), ev.subject_entity_id, e.display_name, null::text, null::text, null::jsonb, o.payload, null::uuid, null::text, null::text, null::text, null::jsonb, o.primary_claim_id,
    null::text, null::text, null::uuid, null::text
  from temporal.event_occurrence o join temporal.event ev on ev.id = o.event_id join temporal.knowledge_batch kb on kb.tenant_id = o.tenant_id and kb.knowledge_seq = o.k_from
  left join catalog.entity e on e.id = ev.subject_entity_id, t
  where o.tenant_id = t.id and kb.recorded_at > p_since and (p_entity_kinds is null or e.kind = any(p_entity_kinds))
  union all
  select 'unit', uc.change_kind, uc.detected_at, null::bigint, dv.published_at, d.work_entity_id, e.display_name, null::text, null::text,
    (select to_jsonb(n.attributes) from content.document_node n where n.id = uc.from_node_id), (select to_jsonb(n.attributes) from content.document_node n where n.id = uc.to_node_id),
    d.id, d.canonical_title, uc.logical_key, uc.unit_kind, uc.changed_attributes, null::uuid,
    null::text, null::text, null::uuid, null::text
  from content.unit_change uc join content.document d on d.id = uc.document_id join content.document_version dv on dv.id = uc.to_version_id left join catalog.entity e on e.id = d.work_entity_id, t
  where uc.tenant_id = t.id and uc.detected_at > p_since and uc.change_kind <> 'format_only' and (p_document_types is null or d.document_type_code = any(p_document_types))
  union all
  -- an edge opened (scope_key carries the relationship kind)
  select 'relationship', 'opened', kb.recorded_at, r.k_from, null::timestamptz, r.from_entity_id, e.display_name, null::text, r.kind, null::jsonb,
    jsonb_build_object('relationship_id', r.id, 'kind', r.kind, 'to_entity_id', r.to_entity_id, 'to', e2.display_name, 'qualifier', r.qualifier, 'properties', r.properties),
    null::uuid, null::text, null::text, null::text, null::jsonb, r.primary_claim_id, null::text, null::text, null::uuid, null::text
  from catalog.relationship r join temporal.knowledge_batch kb on kb.tenant_id = r.tenant_id and kb.knowledge_seq = r.k_from
  join catalog.entity e on e.id = r.from_entity_id join catalog.entity e2 on e2.id = r.to_entity_id, t
  where r.tenant_id = t.id and kb.recorded_at > p_since and p_stream_kinds is null and p_document_types is null and (p_entity_kinds is null or e.kind = any(p_entity_kinds))
  union all
  -- an edge left current knowledge
  select 'relationship', 'closed', kb.recorded_at, r.k_to, null::timestamptz, r.from_entity_id, e.display_name, null::text, r.kind,
    jsonb_build_object('relationship_id', r.id, 'kind', r.kind, 'to_entity_id', r.to_entity_id, 'to', e2.display_name, 'qualifier', r.qualifier, 'properties', r.properties), null::jsonb,
    null::uuid, null::text, null::text, null::text, null::jsonb, r.primary_claim_id, r.closed_kind, r.closed_reason, r.closed_by_event_id, (select ev.kind from temporal.event ev where ev.id = r.closed_by_event_id)
  from catalog.relationship r join temporal.knowledge_batch kb on kb.tenant_id = r.tenant_id and kb.knowledge_seq = r.k_to
  join catalog.entity e on e.id = r.from_entity_id join catalog.entity e2 on e2.id = r.to_entity_id, t
  where r.tenant_id = t.id and kb.recorded_at > p_since and p_stream_kinds is null and p_document_types is null and (p_entity_kinds is null or e.kind = any(p_entity_kinds))
  union all
  select 'identity', 'merged', m.created_at, m.knowledge_seq, null::timestamptz, m.from_entity_id, e.display_name, null::text, null::text, null::jsonb,
    jsonb_build_object('merge_id', m.id, 'merged_into', m.to_entity_id, 'winner', w.display_name, 'note', m.note, 'undone', m.undone_at is not null,
      'moves', (select jsonb_object_agg(x.action, x.n) from (select mv.action, count(*) n from catalog.identity_move mv where mv.merge_id = m.id group by 1) x)),
    null::uuid, null::text, null::text, null::text, null::jsonb, null::uuid, 'correction', m.reason_code, null::uuid, null::text
  from catalog.entity_merge m join catalog.entity e on e.id = m.from_entity_id join catalog.entity w on w.id = m.to_entity_id, t
  where m.tenant_id = t.id and m.created_at > p_since and p_stream_kinds is null and p_document_types is null and (p_entity_kinds is null or e.kind = any(p_entity_kinds))
  union all
  select 'identity', 'merge_undone', m.undone_at, null::bigint, null::timestamptz, m.from_entity_id, e.display_name, null::text, null::text,
    jsonb_build_object('merge_id', m.id, 'merged_into', m.to_entity_id, 'winner', w.display_name), jsonb_build_object('note', m.note),
    null::uuid, null::text, null::text, null::text, null::jsonb, null::uuid, 'correction', 'merge_undone', null::uuid, null::text
  from catalog.entity_merge m join catalog.entity e on e.id = m.from_entity_id join catalog.entity w on w.id = m.to_entity_id, t
  where m.tenant_id = t.id and m.undone_at > p_since and p_stream_kinds is null and p_document_types is null and (p_entity_kinds is null or e.kind = any(p_entity_kinds))
  union all
  select 'identity', 'split', sp.created_at, sp.knowledge_seq, null::timestamptz, sp.from_entity_id, e.display_name, null::text, null::text, null::jsonb,
    jsonb_build_object('split_id', sp.id, 'note', sp.note, 'source_retired', sp.source_retired,
      'parts', (select jsonb_agg(jsonb_build_object('entity_id', p.to_entity_id, 'name', pe.display_name)) from catalog.entity_split_part p join catalog.entity pe on pe.id = p.to_entity_id where p.split_id = sp.id),
      'moves', (select jsonb_object_agg(x.action, x.n) from (select mv.action, count(*) n from catalog.identity_move mv where mv.split_id = sp.id group by 1) x)),
    null::uuid, null::text, null::text, null::text, null::jsonb, null::uuid, 'correction', sp.reason_code, null::uuid, null::text
  from catalog.entity_split sp join catalog.entity e on e.id = sp.from_entity_id, t
  where sp.tenant_id = t.id and sp.created_at > p_since and p_stream_kinds is null and p_document_types is null and (p_entity_kinds is null or e.kind = any(p_entity_kinds))
  order by 3 desc
$$;
revoke all on function api.changes_since(timestamptz, text[], text[], text[]) from public;
grant execute on function api.changes_since(timestamptz, text[], text[], text[]) to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
comment on function api.changes_since(timestamptz, text[], text[], text[]) is
  'What we learned after p_since: facts (each a world_change or a correction with its reason and cause event; cut pieces are not listed), events, unit changes, edges opened and closed (scope_key carries the relationship kind), and merges and splits of records.';

create function api.change_explanation(p_segment uuid default null, p_event uuid default null, p_relationship uuid default null, p_include_proposals boolean default false)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare t uuid := util.current_tenant_id(); s temporal.segment; r catalog.relationship; v_event uuid; v_out jsonb; v_stated jsonb; v_props jsonb;
begin
  if num_nonnulls(p_segment, p_event, p_relationship) <> 1 then raise exception 'name one fact, one event or one relationship' using errcode = '22023'; end if;
  if p_segment is not null then
    select * into s from temporal.segment where id = p_segment and tenant_id = t;
    if not found then raise exception 'no such fact' using errcode = 'P0002'; end if;
    v_event := s.caused_by_event_id;
    v_out := jsonb_build_object('target', 'fact', 'segment_id', s.id, 'revision_kind', s.revision_kind, 'correction_reason', s.correction_reason,
      'correction_reason_means', (select description from temporal.correction_reason where code = s.correction_reason));
  elsif p_relationship is not null then
    select * into r from catalog.relationship where id = p_relationship and tenant_id = t;
    if not found then raise exception 'no such relationship' using errcode = 'P0002'; end if;
    select g.* into s from temporal.stream st join temporal.segment g on g.stream_id = st.id
     where st.subject_relationship_id = r.id and st.kind = 'relationship_active' and g.k_to is null and g.status = 'ended' order by lower(g.valid_during) desc limit 1;
    v_event := coalesce(r.closed_by_event_id, s.caused_by_event_id);
    v_out := jsonb_build_object('target', 'relationship', 'relationship_id', r.id, 'kind', r.kind, 'closed_kind', coalesce(r.closed_kind, case when s.id is not null then 'world_change' end),
      'closed_reason', r.closed_reason, 'ended_in_world_at', lower(s.valid_during), 'ending_segment_id', s.id);
  else
    v_event := p_event;
    v_out := jsonb_build_object('target', 'event');
  end if;
  v_out := v_out || jsonb_build_object('cause_event', (select jsonb_build_object('event_id', ev.id, 'kind', ev.kind, 'subject', se.display_name, 'object', oe.display_name,
      'occurred_from', lower(o.occurred_during), 'payload', o.payload)
    from temporal.event ev left join temporal.event_occurrence o on o.event_id = ev.id and o.k_to is null
    left join catalog.entity se on se.id = ev.subject_entity_id left join catalog.entity oe on oe.id = ev.object_entity_id where ev.id = v_event and ev.tenant_id = t limit 1));
  -- what a source said the reason was: claims attached with role explains to the fact or to the cause event
  select coalesce(jsonb_agg(jsonb_build_object('claim_id', c.id, 'statement', c.statement, 'status', c.status::text, 'quote', c.structured ->> 'quote',
           'stated_by', (select jsonb_agg(distinct x.display_name) from evidence.attribution a join catalog.entity x on x.id = a.entity_id where a.claim_id = c.id),
           'source_url', (select src.canonical_url from evidence.locator l join evidence.source_capture cap on cap.id = l.capture_id join evidence.source src on src.id = cap.source_id where l.id = sup.locator_id))), '[]'::jsonb)
    into v_stated
    from evidence.segment_support sup join evidence.claim c on c.id = sup.claim_id
   where sup.tenant_id = t and sup.role = 'explains' and sup.k_to is null
     and (sup.segment_id = coalesce(p_segment, s.id) or sup.event_occurrence_id in (select o.id from temporal.event_occurrence o where o.event_id = v_event));
  v_out := v_out || jsonb_build_object('stated_reasons', v_stated);
  if p_include_proposals then
    select coalesce(jsonb_agg(jsonb_build_object('proposal_id', p.proposal_id, 'ours', true, 'statement', p.statement, 'rationale', p.rationale, 'confidence', p.confidence, 'authored_by_kind', p.authored_by_kind,
             'authored_by', p.authored_by, 'review_state', p.review_state, 'publication', p.publication, 'basis', p.basis)), '[]'::jsonb) into v_props
      from api.proposals() p
     where p.proposal_kind = 'cause' and ((p.target ->> 'segment_id')::uuid = coalesce(p_segment, s.id) or (p.target ->> 'event_id')::uuid = v_event or (p.target ->> 'relationship_id')::uuid = p_relationship or p.cause_event_id = v_event);
    v_out := v_out || jsonb_build_object('proposals', v_props);
  end if;
  return v_out;
end $$;
revoke all on function api.change_explanation(uuid, uuid, uuid, boolean) from public;
grant execute on function api.change_explanation(uuid, uuid, uuid, boolean) to app_reader, authenticated, pipeline_agent, verifier_agent, control_plane, executor_service, service_role;
comment on function api.change_explanation(uuid, uuid, uuid, boolean) is
  'Why a fact, an event or a relationship changed, in three separate parts: the cause event; what a source said the reason was (claims with role explains, attributed); and, only when asked, our own proposals, marked ours.';

create function api.entity_history(p_entity uuid) returns table(item_kind text, world_from timestamptz, world_to timestamptz, learned_at timestamptz, details jsonb)
language sql stable security definer set search_path = '' as $$
  with t as (select util.current_tenant_id() id), c as (select catalog.canonical_entity(p_entity) id)
  select 'name', lower(s.valid_during), upper(s.valid_during), kb.recorded_at,
         jsonb_build_object('display_name', s.payload ->> 'display_name', 'revision_kind', s.revision_kind, 'correction_reason', s.correction_reason, 'cause_event_id', s.caused_by_event_id)
    from temporal.stream st join temporal.segment s on s.stream_id = st.id join temporal.knowledge_batch kb on kb.tenant_id = s.tenant_id and kb.knowledge_seq = s.k_from, t, c
   where st.tenant_id = t.id and st.kind = 'entity_name' and st.subject_entity_id = c.id and s.k_to is null
  union all
  select 'alias', null, null, null, jsonb_build_object('alias', a.alias, 'alias_kind', a.alias_kind) from catalog.entity_alias a, t, c where a.tenant_id = t.id and a.entity_id = c.id
  union all
  select 'identifier', null, null, null, jsonb_build_object('scheme', i.scheme, 'value', i.value) from catalog.entity_identifier i, t, c where i.tenant_id = t.id and i.entity_id = c.id
  union all
  select 'event', lower(o.occurred_during), null, kb.recorded_at,
         jsonb_build_object('event_id', ev.id, 'kind', ev.kind, 'role', case when ev.subject_entity_id = c.id then 'subject' else 'object' end, 'subject', se.display_name, 'object', oe.display_name, 'payload', o.payload)
    from temporal.event ev join temporal.event_occurrence o on o.event_id = ev.id and o.k_to is null join temporal.knowledge_batch kb on kb.tenant_id = o.tenant_id and kb.knowledge_seq = o.k_from
    left join catalog.entity se on se.id = ev.subject_entity_id left join catalog.entity oe on oe.id = ev.object_entity_id, t, c
   where ev.tenant_id = t.id and (ev.subject_entity_id = c.id or ev.object_entity_id = c.id)
     and ev.kind in ('renamed', 'split_out', 'stewardship_transferred', 'repo_renamed', 'repo_transferred', 'dissolved', 'transaction_closed', 'product_discontinued', 'founded')
  union all
  select 'relationship', lower(g.valid_during), upper(g.valid_during), kb.recorded_at,
         jsonb_build_object('relationship_id', r.id, 'kind', r.kind, 'direction', case when r.from_entity_id = c.id then 'outgoing' else 'incoming' end,
           'other_entity_id', case when r.from_entity_id = c.id then r.to_entity_id else r.from_entity_id end, 'other', case when r.from_entity_id = c.id then e2.display_name else e1.display_name end,
           'status', g.status, 'cause_event_id', g.caused_by_event_id)
    from catalog.relationship r join temporal.knowledge_batch kb on kb.tenant_id = r.tenant_id and kb.knowledge_seq = r.k_from
    join catalog.entity e1 on e1.id = r.from_entity_id join catalog.entity e2 on e2.id = r.to_entity_id
    left join temporal.stream st on st.subject_relationship_id = r.id and st.kind = 'relationship_active'
    left join temporal.segment g on g.stream_id = st.id and g.k_to is null, t, c
   where r.tenant_id = t.id and r.k_to is null and (r.from_entity_id = c.id or r.to_entity_id = c.id)
     and r.kind in ('supersedes', 'split_from', 'variant_of', 'subsidiary_of', 'maintains', 'develops', 'operates', 'backed_by_repository')
  union all
  select case when m.to_entity_id = c.id then 'merged_in' else 'merged_into' end, null, null, m.created_at,
         jsonb_build_object('merge_id', m.id, 'from', l.display_name, 'from_entity_id', m.from_entity_id, 'into', w.display_name, 'into_entity_id', m.to_entity_id, 'reason', m.reason_code, 'note', m.note, 'undone', m.undone_at is not null)
    from catalog.entity_merge m join catalog.entity l on l.id = m.from_entity_id join catalog.entity w on w.id = m.to_entity_id, t, c
   where m.tenant_id = t.id and (m.to_entity_id = c.id or m.from_entity_id = p_entity)
  union all
  select case when sp.from_entity_id = c.id then 'split_into' else 'split_out_of' end, null, null, sp.created_at,
         jsonb_build_object('split_id', sp.id, 'source', src.display_name, 'source_entity_id', sp.from_entity_id, 'reason', sp.reason_code, 'note', sp.note,
           'parts', (select jsonb_agg(pe.display_name) from catalog.entity_split_part p join catalog.entity pe on pe.id = p.to_entity_id where p.split_id = sp.id))
    from catalog.entity_split sp join catalog.entity src on src.id = sp.from_entity_id, t, c
   where sp.tenant_id = t.id and (sp.from_entity_id = c.id or exists (select 1 from catalog.entity_split_part p where p.split_id = sp.id and p.to_entity_id = c.id))
  order by 2 nulls last, 4 nulls last
$$;
revoke all on function api.entity_history(uuid) from public;
grant execute on function api.entity_history(uuid) to app_reader, authenticated, pipeline_agent, verifier_agent, control_plane, executor_service, service_role;
comment on function api.entity_history(uuid) is 'What happened to one identity: names through time, aliases, identifiers, renames and other identity events, successors and stewards with their world intervals, and merges and splits of its record.';

-- ============================================================================================ search: a merged record's index rows answer for its winner
-- retrieval.vector_item rows are immutable, so a merge leaves them on the loser. Search maps them: a filter by the winner also
-- finds the loser's items, and every hit carries the winner's id.
create function catalog.with_merged(p_ids uuid[]) returns uuid[] language sql stable security definer set search_path = '' as $$
  select case when p_ids is null then null else array(
    select unnest(p_ids) union
    select e.id from catalog.entity e where e.lifecycle = 'merged' and catalog.canonical_entity(e.id) = any(p_ids)) end
$$;
comment on function catalog.with_merged(uuid[]) is 'The given records plus every record merged into them.';
grant execute on function catalog.with_merged(uuid[]) to app_reader, authenticated, pipeline_agent, verifier_agent, control_plane, executor_service, service_role;

do $$
declare
  def text := pg_get_functiondef('api.search_unified(text, extensions.halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamptz, uuid[], text[], text[], integer, integer, integer, double precision, boolean)'::regprocedure);
  pairs constant text[] := array[
    'declare t uuid := util.default_tenant_id(); q tsquery := websearch_to_tsquery(''english'', p_query);',
    'declare t uuid := util.default_tenant_id(); q tsquery := websearch_to_tsquery(''english'', p_query); ids_ uuid[] := catalog.with_merged(p_entity_ids);',
    'and (p_entity_ids is null or vi.entity_id = any(p_entity_ids) or vi.secondary_entity_ids && p_entity_ids)',
    'and (p_entity_ids is null or vi.entity_id = any(ids_) or vi.secondary_entity_ids && ids_)',
    'e.unit_kind, e.entity_id, e.document_id, e.document_version_id,',
    'e.unit_kind, catalog.canonical_entity(e.entity_id), e.document_id, e.document_version_id,',
    'g.tk_, g.tid_, e.workspace_id,',
    'g.tk_, case when g.tk_ = ''entity'' then catalog.canonical_entity(g.tid_) else g.tid_ end, e.workspace_id,'];
  i integer;
begin
  for i in 1 .. cardinality(pairs) / 2 loop
    if (length(def) - length(replace(def, pairs[2 * i - 1], ''))) / length(pairs[2 * i - 1]) <> 1 then
      raise exception 'api.search_unified is not the body this migration patches (fragment % not found exactly once)', i;
    end if;
    def := replace(def, pairs[2 * i - 1], pairs[2 * i]);
  end loop;
  execute def;
end $$;
