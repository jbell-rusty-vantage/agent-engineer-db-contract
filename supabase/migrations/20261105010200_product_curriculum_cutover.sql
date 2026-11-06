-- Build 01 R1 §C cutover: replace the thirteen legacy curriculum relations with authored works.
-- Empty-baseline path only. Populated targets need the deterministic conversion manifest (staged) and refuse here.
begin;
set local lock_timeout = '15s';

do $$
declare t text; n bigint;
begin
  foreach t in array array['curriculum','track','module','lesson','lesson_version','challenge','challenge_version','learning_objective',
                           'lesson_covers_concept','challenge_targets','lesson_backed_by','challenge_derived_from','lesson_prerequisite'] loop
    execute format('select count(*) from curriculum.%I', t) into n;
    if n > 0 then
      raise exception 'CURRICULUM_CONVERSION_MANIFEST_REQUIRED' using detail = format('curriculum.%s has %s rows', t, n),
        hint = 'populated conversion requires the Build 01 R1 deterministic converter manifest; legacy tables left intact';
    end if;
  end loop;
  if exists (select 1 from taxonomy.assignment where lesson_id is not null) then
    raise exception 'CURRICULUM_CONVERSION_MANIFEST_REQUIRED' using detail = 'taxonomy.assignment rows target legacy lessons';
  end if;
end $$;

-- taxonomy.assignment: lesson target becomes an authored work target (UUIDs preserved by the converter when populated).
alter table taxonomy.assignment drop constraint assignment_lesson_id_fkey;
alter table taxonomy.assignment drop constraint assignment_check;
alter table taxonomy.assignment rename column lesson_id to target_work_id;
alter table taxonomy.assignment add constraint assignment_target_work_fk
  foreign key (tenant_id, target_work_id) references authoring.work(tenant_id, id) on delete restrict;
alter table taxonomy.assignment add constraint assignment_one_target_ck
  check (num_nonnulls(target_entity_id, target_record_id, target_work_id) = 1);
create index if not exists assignment_target_work_ix on taxonomy.assignment(tenant_id, target_work_id) where target_work_id is not null;

-- Pre-existing defect fixed in passing (lab finding F-02): this function read ~20 columns that no longer exist on
-- taxonomy.assignment, so any single-cardinality facet assignment raised at runtime.
create or replace function taxonomy.enforce_facet_cardinality() returns trigger language plpgsql set search_path = '' as $$
declare v_card text; v_facet uuid; v_dupes integer;
begin
  select f.cardinality, f.id into v_card, v_facet
    from taxonomy.term t join taxonomy.facet_version fv on fv.id = t.facet_version_id join taxonomy.facet f on f.id = fv.facet_id
   where t.id = new.term_id;
  if v_card is distinct from 'single' then return new; end if;
  select count(*) into v_dupes from taxonomy.assignment a
    join taxonomy.term t on t.id = a.term_id join taxonomy.facet_version fv on fv.id = t.facet_version_id
   where fv.facet_id = v_facet and a.valid_to is null and a.id <> new.id and a.tenant_id = new.tenant_id
     and a.target_entity_id is not distinct from new.target_entity_id
     and a.target_record_id is not distinct from new.target_record_id
     and a.target_work_id is not distinct from new.target_work_id;
  if v_dupes > 0 then
    raise exception 'facet is single-cardinality; target already holds a current term from it' using errcode = 'unique_violation';
  end if;
  return new;
end $$;

create or replace function taxonomy.enforce_term_target_scope() returns trigger language plpgsql set search_path = '' as $$
declare actual text;
begin
  if new.target_entity_id is not null then
    select kind into strict actual from corpus.entity where id = new.target_entity_id and tenant_id = new.tenant_id;
  elsif new.target_record_id is not null then
    select kind into strict actual from knowledge.record where id = new.target_record_id and tenant_id = new.tenant_id;
  else
    select kind into strict actual from authoring.work where id = new.target_work_id and tenant_id = new.tenant_id;
  end if;
  if exists (select 1 from taxonomy.term_target_kind where term_id = new.term_id)
     and not exists (select 1 from taxonomy.term_target_kind where term_id = new.term_id and entity_kind_code = actual) then
    raise exception 'taxonomy term does not admit target kind' using errcode = '23514';
  end if;
  return new;
end $$;

-- Drop replaced relations in dependency order. Never CASCADE.
drop table curriculum.lesson_prerequisite;
drop table curriculum.challenge_derived_from;
drop table curriculum.lesson_backed_by;
drop table curriculum.challenge_targets;
drop table curriculum.lesson_covers_concept;
drop table curriculum.learning_objective;
drop table curriculum.challenge_version;
drop table curriculum.lesson_version;
drop table curriculum.challenge;
drop table curriculum.lesson;
drop table curriculum.module;
drop table curriculum.track;
drop table curriculum.curriculum;
drop function if exists curriculum.lesson_version_guard();
do $$ begin
  if not exists (select 1 from pg_attribute a join pg_class c on c.oid = a.attrelid
                 where a.atttypid = 'curriculum.publish_status'::regtype and not a.attisdropped) then
    drop type curriculum.publish_status;
  end if;
end $$;

commit;
