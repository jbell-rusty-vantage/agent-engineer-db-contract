-- Build 08 R2 draft, fixup 3 (loop-1 delta D-04): a time-independent view of which of our head revisions bind a software thing,
-- for the flywheel check when a release lands after the module was authored (api.modules_affected_by_release keeps the time rule).
begin;
create or replace function api.modules_using_software(p_software uuid) returns table(
  work_id uuid, work_kind text, work_slug text, revision_id uuid, revision_title text, revision_created_at timestamptz, binding text, version_spec text, software text,
  latest_release text, latest_release_at timestamptz, latest_release_breaking boolean, releases_since_revision bigint)
language sql stable security definer set search_path = '' as $$
  with b as (
    select x.revision_id, 'binding:'||x.relation binding, null::text version_spec from authoring.revision_binding x where x.entity_id = p_software
    union all select q.revision_id, 'runtime_requirement', q.version_spec from authoring.runtime_requirement q where q.entity_id = p_software
  ), rel as (select r.* from api.software_releases r where r.software_id = p_software)
  select w.id, w.kind, w.slug, rv.id, rv.title, rv.created_at, b.binding, b.version_spec, s.display_name,
    (select r.release from rel r order by r.released_at desc nulls last limit 1), (select r.released_at from rel r order by r.released_at desc nulls last limit 1),
    (select r.breaking from rel r order by r.released_at desc nulls last limit 1), (select count(*) from rel r where r.released_at > rv.created_at)
  from b join authoring.work_revision rv on rv.id = b.revision_id join authoring.work w on w.id = rv.work_id and w.head_revision_id = rv.id join catalog.entity s on s.id = p_software
  order by w.slug
$$;
comment on function api.modules_using_software is 'L2 flywheel (time-independent): our head revisions that bind or require a software thing, with its latest known release and how many releases landed after the revision was authored.';
grant execute on function api.modules_using_software(uuid) to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;
commit;
