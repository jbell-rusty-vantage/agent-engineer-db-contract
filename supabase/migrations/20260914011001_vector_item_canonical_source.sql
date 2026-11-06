begin;
set local lock_timeout = '15s';

-- Inline embeddings and claim_id were removed in km_00. Follow the retained typed references.
create or replace function retrieval.enforce_canonical_source() returns trigger
language plpgsql set search_path = '' as $$
declare
  space_class text;
  expected_dims integer;
  item_dims integer;
  target_claim uuid;
  claim_status text;
begin
  select s.class::text,v.dims into space_class,expected_dims
    from retrieval.vector_space_version v
    join retrieval.vector_space s on s.tenant_id=v.tenant_id and s.id=v.vector_space_id
    where v.tenant_id=new.tenant_id and v.id=new.space_version_id;
  if space_class is null then
    raise exception 'vector space version is missing or belongs to another tenant' using errcode='restrict_violation';
  end if;

  if new.embedding_item_id is not null then
    select i.dimensions into item_dims from retrieval.embedding_item i
      join retrieval.embedding_run r on r.tenant_id=i.tenant_id and r.id=i.embedding_run_id
      where i.tenant_id=new.tenant_id and i.id=new.embedding_item_id
        and r.vector_space_version_id=new.space_version_id;
    if item_dims is distinct from expected_dims then
      raise exception 'embedding item dimensions or space binding differ from vector space version' using errcode='data_exception';
    end if;
  end if;

  if space_class='canonical' then
    if not exists(select 1 from retrieval.projection_target t
      join retrieval.search_projection p on p.tenant_id=t.tenant_id and p.projection_target_id=t.id
      where t.tenant_id=new.tenant_id and t.id=new.projection_target_id
        and p.id=new.search_projection_id and t.retired_at is null) then
      raise exception 'canonical vector space requires its current typed projection target' using errcode='restrict_violation';
    end if;
    select t.claim_id into target_claim from retrieval.projection_target t
      where t.tenant_id=new.tenant_id and t.id=new.projection_target_id and t.target_kind='claim';
    if target_claim is not null then
      select c.status::text into claim_status from evidence.claim c where c.tenant_id=new.tenant_id and c.id=target_claim;
      if claim_status is distinct from 'verified' then
        raise exception 'canonical vector space requires a verified claim; claim % is %',target_claim,coalesce(claim_status,'missing')
          using errcode='restrict_violation';
      end if;
    end if;
  end if;
  return new;
end;
$$;

commit;
