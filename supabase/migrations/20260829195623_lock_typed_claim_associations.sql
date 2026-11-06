begin;

create or replace function evidence.enforce_claim_association_proposed() returns trigger
language plpgsql
set search_path=''
as $$
declare v_status evidence.claim_status;
begin
  select status into v_status from evidence.claim where id=new.claim_id;
  if v_status<>'proposed' then
    raise exception 'typed entity associations may be added only while claim is proposed'
      using errcode='restrict_violation';
  end if;
  return new;
end;
$$;

do $$
declare relation_name text;
begin
  foreach relation_name in array array[
    'claim_library','claim_repository','claim_person','claim_organization','claim_paper',
    'claim_talk','claim_video','claim_product','claim_product_version','claim_concept',
    'claim_dataset','claim_benchmark','claim_ai_model_version','claim_protocol_version',
    'claim_mcp_server_version','claim_agent_skill_version','claim_technical_record','claim_case_study'
  ] loop
    execute format(
      'create trigger claim_entity_association_proposed before insert on evidence.%I for each row execute function evidence.enforce_claim_association_proposed()',
      relation_name);
    execute format(
      'create trigger claim_entity_association_immutable before update or delete on evidence.%I for each row execute function util.reject_mutation()',
      relation_name);
  end loop;
end;
$$;

comment on function evidence.enforce_claim_association_proposed() is
  'Freezes typed claim meaning before review; later retargeting requires a superseding claim.';

commit;
