-- Learner Units 05/06: first-class learning assets and vault asset links.

create table if not exists public.learning_asset (
  asset_id uuid primary key default gen_random_uuid(),
  slug text not null,
  title text not null,
  description text,
  asset_kind text not null,
  provider text not null,
  bucket text,
  storage_path text,
  external_url text,
  mime_type text,
  file_size_bytes bigint,
  checksum_sha256 text,
  preview_url text,
  extraction_status text not null default 'pending',
  extraction_error text,
  extracted_text text,
  text_extracted_at timestamptz,
  source_path text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint learning_asset_slug_nonempty check (length(btrim(slug)) > 0),
  constraint learning_asset_kind_check check (
    asset_kind in (
      'pdf',
      'docx',
      'image',
      'slides',
      'source-file',
      'archive',
      'web',
      'text',
      'markdown',
      'data',
      'other'
    )
  ),
  constraint learning_asset_provider_check check (
    provider in ('supabase-storage', 's3', 'external-url')
  ),
  constraint learning_asset_extraction_status_check check (
    extraction_status in ('pending', 'processing', 'succeeded', 'failed', 'not_required')
  ),
  constraint learning_asset_location_check check (
    (
      provider in ('supabase-storage', 's3')
      and bucket is not null
      and storage_path is not null
      and external_url is null
    )
    or (
      provider = 'external-url'
      and external_url is not null
      and bucket is null
      and storage_path is null
    )
  ),
  constraint learning_asset_file_size_nonnegative check (
    file_size_bytes is null or file_size_bytes >= 0
  )
);

create unique index if not exists learning_asset_slug_uniq
  on public.learning_asset (slug);
create index if not exists learning_asset_kind_idx
  on public.learning_asset (asset_kind);
create index if not exists learning_asset_provider_idx
  on public.learning_asset (provider);
create index if not exists learning_asset_extraction_status_idx
  on public.learning_asset (extraction_status);
create index if not exists learning_asset_checksum_idx
  on public.learning_asset (checksum_sha256)
  where checksum_sha256 is not null;
create index if not exists learning_asset_metadata_gin
  on public.learning_asset using gin (metadata jsonb_path_ops);

drop trigger if exists set_learning_asset_updated_at on public.learning_asset;
create trigger set_learning_asset_updated_at
before update on public.learning_asset
for each row execute procedure public.set_updated_at();

alter table public.learning_asset enable row level security;

drop policy if exists "learning_asset_authenticated_read" on public.learning_asset;
create policy "learning_asset_authenticated_read" on public.learning_asset
  for select
  to authenticated
  using (
    exists (
      select 1
        from public.module_uses_artifact mua
        join public.course_module cm
          on cm.module_id = mua.module_id
       where mua.artifact_kind = 'learning_asset'
         and mua.artifact_id = learning_asset.asset_id::text
         and cm.status = 'published'
    )
  );

create or replace function public.reject_published_learning_asset_mutation()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if exists (
    select 1
      from public.module_uses_artifact mua
      join public.course_module cm
        on cm.module_id = mua.module_id
     where mua.artifact_kind = 'learning_asset'
       and mua.artifact_id = old.asset_id::text
       and cm.status = 'published'
  ) then
    raise exception
      'Published learning asset % is immutable while linked from a published module; bump module version before changing it',
      old.slug
      using errcode = '23514';
  end if;

  if tg_op = 'DELETE' then
    return old;
  end if;

  return new;
end;
$$;

drop trigger if exists reject_published_learning_asset_update on public.learning_asset;
create trigger reject_published_learning_asset_update
before update on public.learning_asset
for each row execute procedure public.reject_published_learning_asset_mutation();

drop trigger if exists reject_published_learning_asset_delete on public.learning_asset;
create trigger reject_published_learning_asset_delete
before delete on public.learning_asset
for each row execute procedure public.reject_published_learning_asset_mutation();

comment on table public.learning_asset is
  'Owned or referenced learner-facing course assets. Modules link to these rows through module_uses_artifact with artifact_kind=learning_asset.';
comment on column public.learning_asset.provider is
  'supabase-storage for current owned files, s3 for future owned files, external-url for referenced remote assets.';
comment on column public.learning_asset.source_path is
  'Original vault-relative source path used by the publish pipeline for auditing.';
comment on column public.learning_asset.extraction_status is
  'Offline extraction lifecycle. Required extraction failures block module publish in the vault pipeline.';

alter table public.module_uses_artifact drop constraint if exists module_uses_artifact_kind_check;

alter table public.module_uses_artifact add constraint module_uses_artifact_kind_check check (
  artifact_kind in (
    'video', 'session', 'dossier', 'repo', 'library', 'product',
    'paper', 'slide', 'report', 'news_item', 'chunk',
    'doc_page', 'web_article', 'learning_asset'
  )
);

alter table public.module_uses_artifact drop constraint if exists module_uses_artifact_role_check;

alter table public.module_uses_artifact add constraint module_uses_artifact_role_check check (
  role is null
  or role in ('primary', 'reference', 'supporting', 'example', 'source')
);

drop policy if exists "module_uses_artifact_public_read" on public.module_uses_artifact;
drop policy if exists "module_uses_artifact_published_read" on public.module_uses_artifact;
create policy "module_uses_artifact_published_read" on public.module_uses_artifact
  for select
  to authenticated
  using (
    exists (
      select 1
        from public.course_module cm
       where cm.module_id = module_uses_artifact.module_id
         and cm.status = 'published'
    )
  );

insert into storage.buckets (id, name, public)
values ('learning-assets', 'learning-assets', false)
on conflict (id) do update
set public = false;

drop policy if exists "learning_assets_select_authenticated" on storage.objects;
create policy "learning_assets_select_authenticated"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'learning-assets'
  and exists (
    select 1
      from public.learning_asset la
      join public.module_uses_artifact mua
        on mua.artifact_kind = 'learning_asset'
       and mua.artifact_id = la.asset_id::text
      join public.course_module cm
        on cm.module_id = mua.module_id
     where la.provider = 'supabase-storage'
       and la.bucket = storage.objects.bucket_id
       and la.storage_path = storage.objects.name
       and cm.status = 'published'
  )
);
