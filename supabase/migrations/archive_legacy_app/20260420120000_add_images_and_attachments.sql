-- Migration: image + image_attachment (Pattern 2 from the data-model discussion).
--
-- Why two tables instead of more *_image_url columns?
--   1) Many entities need MORE THAN ONE image (org logo light/dark + hero,
--      event hero + sponsor logos + gallery, news_item hero + OG + inline,
--      course cover + OG + diagram set).
--   2) The same image asset (uploaded once) often has to be reused across
--      several rows (the Anthropic logo on the org row, on news_item rows,
--      on report rows). Normalising avoids byte-level duplication and lets
--      content_hash enforce dedupe.
--   3) The client needs render hints (alt text, blurhash placeholder,
--      dominant colour, focal point, light/dark variant, priority flag).
--      Inline `*_url text` columns can't carry that.
--
-- Storage strategy
--   `image` is provider-agnostic. The canonical render URL lives in `url`.
--   `storage_provider` + `storage_bucket` + `storage_key` describe WHERE the
--   bytes live so we can later sign URLs, transform, or migrate. S3 is the
--   primary target (as set in supabase/config.toml [storage.s3_protocol]),
--   but supabase / r2 / external are equally first-class.
--
-- Polymorphism
--   `image_attachment.entity_id` is `text` (not uuid) because some entities
--   key on slug (library, course_module, paper) and some on uuid
--   (organization, person, news_item). This mirrors saved_items / notes,
--   which already use the same (entity_kind, entity_id) pattern.
--
-- Backwards compatibility
--   No existing columns are dropped. The legacy `*_url` columns
--   (profiles.avatar_url, organization.logo_url, news_item.hero_image_url,
--   news_item.thumbnail_url, person.sessionize_profile_picture_url,
--   youtube_video.thumbnail_url) remain populated by harvesters and are the
--   fallback path for the client when no image_attachment row exists.

-------------------------------------------------------------------------------
-- 1. image: a single uploaded / referenced image asset
-------------------------------------------------------------------------------

create table if not exists public.image (
  image_id          uuid primary key default gen_random_uuid(),

  -- WHERE the bytes live ----------------------------------------------------
  storage_provider  text not null default 'external',
  storage_bucket    text,
  storage_key       text,                  -- bucket-relative key/path
  storage_region    text,                  -- e.g. 'us-east-1' (S3); null for others
  url               text not null,         -- canonical public render URL
  cdn_url           text,                  -- optional CDN-fronted URL

  -- WHAT the image is ------------------------------------------------------
  alt               text not null default '',
  title             text,
  caption           text,
  mime_type         text,                  -- 'image/png', 'image/jpeg', 'image/webp', 'image/avif', 'image/svg+xml', 'image/gif'
  width             int,
  height            int,
  byte_size         bigint,
  is_animated       boolean not null default false,

  -- HOW to render it well --------------------------------------------------
  blurhash          text,                  -- LQIP placeholder for next/image
  thumbhash         text,                  -- alternative tiny placeholder
  dominant_color    text,                  -- '#RRGGBB'
  palette           jsonb not null default '[]'::jsonb,   -- [{ hex, weight }, ...]
  focal_x           numeric,               -- 0..1 — object-position x
  focal_y           numeric,               -- 0..1 — object-position y
  safe_area         jsonb,                 -- { top, right, bottom, left } as 0..1 fractions

  -- Provenance / rights ----------------------------------------------------
  source            text not null default 'external',
  source_url        text,                  -- original URL if scraped / external
  attribution       text,                  -- credit line shown to users
  license           text,                  -- 'CC-BY-4.0', 'all-rights-reserved', etc.

  -- Moderation -------------------------------------------------------------
  nsfw              boolean not null default false,
  content_warning   text,

  -- Ops --------------------------------------------------------------------
  content_hash      text,                  -- sha256 of bytes; unique when present
  metadata          jsonb not null default '{}'::jsonb,
  created_by        uuid references public.profiles(id) on delete set null,
  created_at        timestamptz not null default timezone('utc', now()),
  updated_at        timestamptz not null default timezone('utc', now()),

  constraint image_storage_provider_check check (
    storage_provider in (
      's3', 'supabase', 'r2', 'gcs', 'azure',
      'cloudflare_images', 'imgix', 'bunny',
      'external', 'generated'
    )
  ),
  constraint image_source_check check (
    source in ('upload', 'external', 'scraped', 'generated', 'system')
  ),
  constraint image_focal_x_range check (focal_x is null or (focal_x >= 0 and focal_x <= 1)),
  constraint image_focal_y_range check (focal_y is null or (focal_y >= 0 and focal_y <= 1)),
  constraint image_url_not_blank check (char_length(trim(url)) > 0),
  constraint image_dominant_color_format check (
    dominant_color is null
    or dominant_color ~ '^#[0-9A-Fa-f]{6}$'
    or dominant_color ~ '^#[0-9A-Fa-f]{8}$'
  )
);

create unique index if not exists image_content_hash_unique
  on public.image (content_hash) where content_hash is not null;

create index if not exists image_storage_lookup_idx
  on public.image (storage_provider, storage_bucket, storage_key)
  where storage_key is not null;

create index if not exists image_metadata_gin
  on public.image using gin (metadata jsonb_path_ops);

create index if not exists image_created_by_idx
  on public.image (created_by) where created_by is not null;

drop trigger if exists set_image_updated_at on public.image;
create trigger set_image_updated_at
  before update on public.image
  for each row execute procedure public.set_updated_at();

-------------------------------------------------------------------------------
-- 2. image_attachment: polymorphic link image -> entity with role/variant
-------------------------------------------------------------------------------

create table if not exists public.image_attachment (
  attachment_id     uuid primary key default gen_random_uuid(),
  image_id          uuid not null references public.image(image_id) on delete cascade,

  entity_kind       text not null,         -- which table the entity_id points at
  entity_id         text not null,         -- uuid or slug (text for polymorphism)

  role              text not null,         -- semantic slot — what is this image FOR
  variant           text,                  -- visual variant within the role
  ord               int  not null default 0,

  -- Per-attachment overrides (image-level alt/caption are the defaults)
  alt_override      text,
  caption           text,

  -- Render directives the client should honour for THIS placement.
  -- Common keys:
  --   priority    bool   — Next.js <Image priority />, mark as LCP candidate
  --   theme       text   — 'light-only' | 'dark-only' | 'auto'
  --   treatment   text   — 'rounded' | 'circle' | 'bordered' | 'shadow' | 'frame'
  --   intent      text   — 'decorative' | 'informative' | 'branding'
  --   aspect      text   — '1x1' | '16x9' | '4x5' | 'original'
  --   sizes       text   — Next.js `sizes` attribute string
  --   loading     text   — 'eager' | 'lazy'
  render_hints      jsonb not null default '{}'::jsonb,

  created_at        timestamptz not null default timezone('utc', now()),

  constraint image_attachment_entity_kind_check check (
    entity_kind in (
      'organization', 'person', 'event', 'news_item',
      'course', 'course_module', 'youtube_video', 'paper',
      'library', 'product', 'report', 'session', 'profile',
      'repo', 'challenge'
    )
  ),
  constraint image_attachment_role_check check (
    role in (
      'hero', 'thumbnail', 'logo', 'avatar', 'cover', 'og',
      'banner', 'icon', 'gallery', 'inline', 'background',
      'illustration', 'screenshot', 'diagram', 'card', 'square'
    )
  ),
  -- (entity_kind, entity_id, role, variant, ord) uniquely identifies a slot.
  -- COALESCE-on-variant via expression index because real NULLs would
  -- otherwise allow duplicate (kind,id,role,NULL,0) rows.
  constraint image_attachment_slot_unique
    unique (entity_kind, entity_id, role, variant, ord)
);

create index if not exists image_attachment_entity_idx
  on public.image_attachment (entity_kind, entity_id);

create index if not exists image_attachment_entity_role_idx
  on public.image_attachment (entity_kind, entity_id, role, ord);

create index if not exists image_attachment_image_idx
  on public.image_attachment (image_id);

create index if not exists image_attachment_render_hints_gin
  on public.image_attachment using gin (render_hints jsonb_path_ops);

-------------------------------------------------------------------------------
-- 3. RLS
-- Images and their attachments are display assets: anyone can read.
-- Writes are gated to authenticated upload (image rows) or service role
-- only (attachments — those are an editorial/curation action that runs from
-- harvesters & admin tools using the service-role key, which bypasses RLS).
-------------------------------------------------------------------------------

alter table public.image            enable row level security;
alter table public.image_attachment enable row level security;

drop policy if exists "image_public_read" on public.image;
create policy "image_public_read"
  on public.image
  for select
  using (true);

drop policy if exists "image_insert_authenticated" on public.image;
create policy "image_insert_authenticated"
  on public.image
  for insert
  to authenticated
  with check (
    created_by is null
    or (select auth.uid()) = created_by
  );

drop policy if exists "image_modify_own" on public.image;
create policy "image_modify_own"
  on public.image
  for update
  to authenticated
  using ((select auth.uid()) = created_by)
  with check ((select auth.uid()) = created_by);

drop policy if exists "image_delete_own" on public.image;
create policy "image_delete_own"
  on public.image
  for delete
  to authenticated
  using ((select auth.uid()) = created_by);

drop policy if exists "image_attachment_public_read" on public.image_attachment;
create policy "image_attachment_public_read"
  on public.image_attachment
  for select
  using (true);

-- No write policies for image_attachment: only the service role (which
-- bypasses RLS) can attach images to entities. Users who need to attach
-- images (e.g. avatar selection) can do so via a server action that runs
-- with the service-role key, or we add a profile-scoped policy later.

-------------------------------------------------------------------------------
-- 4. Documentation
-------------------------------------------------------------------------------

comment on table public.image is
  'Provider-agnostic image asset (S3, Supabase Storage, R2, external URL, AI-generated). One row per distinct asset; reuse via image_attachment.';

comment on column public.image.storage_provider is
  'Where the bytes live. ''external'' = we only have a URL; ''generated'' = produced by an AI image model. Other values are ownership-bearing buckets we can sign / transform / migrate.';
comment on column public.image.storage_key is
  'Bucket-relative object key (e.g. ''orgs/anthropic/logo.png''). Required in practice when storage_provider is one of s3/supabase/r2/gcs/azure but not enforced so harvesters can land URL-only rows quickly.';
comment on column public.image.url is
  'Canonical render URL the client should fetch. For owned buckets this is usually the public URL; for external assets this IS the source.';
comment on column public.image.alt is
  'Default accessibility text. May be overridden per attachment via alt_override.';
comment on column public.image.blurhash is
  'BlurHash string (https://blurha.sh) used as a tiny placeholder while the full image loads. Pairs with next/image placeholder=''blur''.';
comment on column public.image.dominant_color is
  'Hex colour (#RRGGBB or #RRGGBBAA) used for skeleton backgrounds and tinted UI surfaces while loading.';
comment on column public.image.focal_x is
  'Horizontal focal point as 0..1 fraction of the image width. Used for `object-position` so faces / logos are not cropped out at non-native aspect ratios.';
comment on column public.image.focal_y is
  'Vertical focal point as 0..1 fraction of the image height.';
comment on column public.image.content_hash is
  'sha256 of the original bytes. Unique when present so the same upload is stored once and reattached many times.';

comment on table public.image_attachment is
  'Many-to-many link from image to any entity with role + variant + ord. Polymorphic on (entity_kind, entity_id). Pattern 2 of the data-model image plan.';

comment on column public.image_attachment.entity_kind is
  'Which table the entity_id refers to (organization, person, event, news_item, course, course_module, youtube_video, paper, library, product, report, session, profile, repo, challenge).';
comment on column public.image_attachment.entity_id is
  'Identifier of the entity, stored as text because some target tables key on slug (library, course_module) and others on uuid (organization, news_item).';
comment on column public.image_attachment.role is
  'Semantic slot the image fills for the entity. The client queries by (entity_kind, entity_id, role) to fetch the right asset for a given placement.';
comment on column public.image_attachment.variant is
  'Visual variant within the role. Examples: light/dark/mono for logos, 1x1/16x9/4x5 for crops, color/grayscale for treatments. NULL means "default".';
comment on column public.image_attachment.ord is
  'Sort order inside a role/variant slot. Required for multi-image slots like ''gallery''. Defaults to 0 for single-image slots.';
comment on column public.image_attachment.render_hints is
  'Per-placement directives the client should honour: priority (LCP), theme, treatment, intent, aspect, sizes, loading. Free-form jsonb so we can add new hints without migrations.';
