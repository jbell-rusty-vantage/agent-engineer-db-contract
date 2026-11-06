-- Unit 04: Published content immutability guardrails.
--
-- Published course/module rows are versioned learner contracts. Semantic edits
-- to an already-published (slug, version) row must ship as a new version.

-- ============================================================================
-- course: block semantic updates and deletes once published
-- ============================================================================
create or replace function public.reject_published_course_semantic_update()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if old.status = 'published'
     and (
       new.slug is distinct from old.slug
       or new.version is distinct from old.version
       or new.title is distinct from old.title
       or new.summary is distinct from old.summary
       or new.narrative_md is distinct from old.narrative_md
       or new.est_hours is distinct from old.est_hours
       or new.domain_bucket is distinct from old.domain_bucket
       or new.domain_layer is distinct from old.domain_layer
       or new.capstone_challenge_id is distinct from old.capstone_challenge_id
       or new.status is distinct from old.status
     ) then
    raise exception
      'Published course %.% has immutable semantic content; bump version before changing learner-facing fields',
      old.slug,
      old.version
      using errcode = '23514';
  end if;

  return new;
end;
$$;

create or replace function public.reject_published_course_delete()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if old.status = 'published' then
    raise exception
      'Published course %.% cannot be deleted; publish a new version or retire it outside the learner contract',
      old.slug,
      old.version
      using errcode = '23514';
  end if;

  return old;
end;
$$;

drop trigger if exists reject_published_course_semantic_update on public.course;
create trigger reject_published_course_semantic_update
before update on public.course
for each row execute procedure public.reject_published_course_semantic_update();

drop trigger if exists reject_published_course_delete on public.course;
create trigger reject_published_course_delete
before delete on public.course
for each row execute procedure public.reject_published_course_delete();

-- ============================================================================
-- course_module: block semantic updates and deletes once published
-- ============================================================================
create or replace function public.reject_published_course_module_semantic_update()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if old.status = 'published'
     and (
       new.slug is distinct from old.slug
       or new.version is distinct from old.version
       or new.title is distinct from old.title
       or new.body_md is distinct from old.body_md
       or new.body_kind is distinct from old.body_kind
       or new.duration_min is distinct from old.duration_min
       or new.difficulty is distinct from old.difficulty
       or new.status is distinct from old.status
       or new.domain_buckets is distinct from old.domain_buckets
       or new.learning_objectives is distinct from old.learning_objectives
       or new.mini_quiz is distinct from old.mini_quiz
     ) then
    raise exception
      'Published module %.% has immutable semantic content; bump version before changing learner-facing fields',
      old.slug,
      old.version
      using errcode = '23514';
  end if;

  return new;
end;
$$;

create or replace function public.reject_published_course_module_delete()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if old.status = 'published' then
    raise exception
      'Published module %.% cannot be deleted; publish a new version or retire it outside the learner contract',
      old.slug,
      old.version
      using errcode = '23514';
  end if;

  return old;
end;
$$;

drop trigger if exists reject_published_course_module_semantic_update on public.course_module;
create trigger reject_published_course_module_semantic_update
before update on public.course_module
for each row execute procedure public.reject_published_course_module_semantic_update();

drop trigger if exists reject_published_course_module_delete on public.course_module;
create trigger reject_published_course_module_delete
before delete on public.course_module
for each row execute procedure public.reject_published_course_module_delete();

-- ============================================================================
-- Join tables: freeze composition, prerequisites, and artifacts after publish
-- ============================================================================
create or replace function public.reject_published_course_module_in_course_mutation()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_course public.course%rowtype;
begin
  if tg_op in ('UPDATE', 'DELETE') then
    select *
      into v_course
      from public.course
     where course_id = old.course_id;

    if v_course.status = 'published' then
      raise exception
        'Published course %.% has immutable module composition; bump version before changing course_module_in_course',
        v_course.slug,
        v_course.version
        using errcode = '23514';
    end if;
  end if;

  if tg_op in ('INSERT', 'UPDATE') then
    select *
      into v_course
      from public.course
     where course_id = new.course_id;

    if v_course.status = 'published' then
      raise exception
        'Published course %.% has immutable module composition; bump version before changing course_module_in_course',
        v_course.slug,
        v_course.version
        using errcode = '23514';
    end if;
  end if;

  if tg_op = 'DELETE' then
    return old;
  end if;

  return new;
end;
$$;

drop trigger if exists reject_published_course_module_in_course_insert on public.course_module_in_course;
create trigger reject_published_course_module_in_course_insert
before insert on public.course_module_in_course
for each row execute procedure public.reject_published_course_module_in_course_mutation();

drop trigger if exists reject_published_course_module_in_course_update on public.course_module_in_course;
create trigger reject_published_course_module_in_course_update
before update on public.course_module_in_course
for each row execute procedure public.reject_published_course_module_in_course_mutation();

drop trigger if exists reject_published_course_module_in_course_delete on public.course_module_in_course;
create trigger reject_published_course_module_in_course_delete
before delete on public.course_module_in_course
for each row execute procedure public.reject_published_course_module_in_course_mutation();

create or replace function public.reject_published_course_module_requires_mutation()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_module public.course_module%rowtype;
begin
  if tg_op in ('UPDATE', 'DELETE') then
    select *
      into v_module
      from public.course_module
     where module_id = old.module_id;

    if v_module.status = 'published' then
      raise exception
        'Published module %.% has immutable prerequisites; bump version before changing course_module_requires',
        v_module.slug,
        v_module.version
        using errcode = '23514';
    end if;
  end if;

  if tg_op in ('INSERT', 'UPDATE') then
    select *
      into v_module
      from public.course_module
     where module_id = new.module_id;

    if v_module.status = 'published' then
      raise exception
        'Published module %.% has immutable prerequisites; bump version before changing course_module_requires',
        v_module.slug,
        v_module.version
        using errcode = '23514';
    end if;
  end if;

  if tg_op = 'DELETE' then
    return old;
  end if;

  return new;
end;
$$;

drop trigger if exists reject_published_course_module_requires_insert on public.course_module_requires;
create trigger reject_published_course_module_requires_insert
before insert on public.course_module_requires
for each row execute procedure public.reject_published_course_module_requires_mutation();

drop trigger if exists reject_published_course_module_requires_update on public.course_module_requires;
create trigger reject_published_course_module_requires_update
before update on public.course_module_requires
for each row execute procedure public.reject_published_course_module_requires_mutation();

drop trigger if exists reject_published_course_module_requires_delete on public.course_module_requires;
create trigger reject_published_course_module_requires_delete
before delete on public.course_module_requires
for each row execute procedure public.reject_published_course_module_requires_mutation();

create or replace function public.reject_published_module_uses_artifact_mutation()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_module public.course_module%rowtype;
begin
  if tg_op in ('UPDATE', 'DELETE') then
    select *
      into v_module
      from public.course_module
     where module_id = old.module_id;

    if v_module.status = 'published' then
      raise exception
        'Published module %.% has immutable artifact references; bump version before changing module_uses_artifact',
        v_module.slug,
        v_module.version
        using errcode = '23514';
    end if;
  end if;

  if tg_op in ('INSERT', 'UPDATE') then
    select *
      into v_module
      from public.course_module
     where module_id = new.module_id;

    if v_module.status = 'published' then
      raise exception
        'Published module %.% has immutable artifact references; bump version before changing module_uses_artifact',
        v_module.slug,
        v_module.version
        using errcode = '23514';
    end if;
  end if;

  if tg_op = 'DELETE' then
    return old;
  end if;

  return new;
end;
$$;

drop trigger if exists reject_published_module_uses_artifact_insert on public.module_uses_artifact;
create trigger reject_published_module_uses_artifact_insert
before insert on public.module_uses_artifact
for each row execute procedure public.reject_published_module_uses_artifact_mutation();

drop trigger if exists reject_published_module_uses_artifact_update on public.module_uses_artifact;
create trigger reject_published_module_uses_artifact_update
before update on public.module_uses_artifact
for each row execute procedure public.reject_published_module_uses_artifact_mutation();

drop trigger if exists reject_published_module_uses_artifact_delete on public.module_uses_artifact;
create trigger reject_published_module_uses_artifact_delete
before delete on public.module_uses_artifact
for each row execute procedure public.reject_published_module_uses_artifact_mutation();

comment on function public.reject_published_course_semantic_update() is
  'Blocks same-version semantic edits to already-published course rows. Non-semantic operational fields such as is_latest_published/search/embedding remain updateable.';
comment on function public.reject_published_course_module_semantic_update() is
  'Blocks same-version semantic edits to already-published module rows. Non-semantic operational fields such as is_latest_published/search/embedding/source_path remain updateable.';
