-- Initial local baseline for core content entities.
--
-- The hosted project already had these tables before the earliest checked-in
-- search migrations. Keeping this local baseline first lets `supabase db reset`
-- replay the repository migration history from an empty database.

create table if not exists public.organization (
  organization_id      text primary key,
  name                 text,
  overview             text,
  primary_ai_focus     text,
  flagship_products    text,
  website_domain       text,
  organization_type    text
);

create table if not exists public.person (
  person_id                    text primary key,
  full_name                    text,
  first_name                   text,
  last_name                    text,
  bio                          text,
  tag_line                     text,
  expertise_or_focus_area      text,
  role_title                   text,
  ai_engineer_url              text,
  linkedin_url                 text,
  sessionize_profile_picture_url text
);

create table if not exists public.session (
  session_id            text primary key,
  title                 text,
  description           text,
  extended_description  text,
  level                 text
);

create table if not exists public.youtube_channel (
  channel_id     text primary key,
  channel_title  text,
  channel_url    text
);

create table if not exists public.youtube_video (
  video_id          text primary key,
  channel_id        text references public.youtube_channel(channel_id) on delete set null,
  title             text,
  description       text,
  url               text,
  thumbnail_url     text,
  published_at      timestamptz,
  duration          text,
  duration_seconds  int,
  view_count        bigint,
  like_count        bigint,
  comment_count     bigint
);

create table if not exists public.session_recorded_as_video (
  session_id        text primary key references public.session(session_id) on delete cascade,
  video_id          text not null references public.youtube_video(video_id) on delete cascade,
  match_similarity  numeric
);

create table if not exists public.person_appeared_in_video (
  person_id             text not null references public.person(person_id) on delete cascade,
  video_id              text not null references public.youtube_video(video_id) on delete cascade,
  match_method          text,
  matched_name_variant  text,
  primary key (person_id, video_id)
);

create table if not exists public.person_presented_at_session (
  person_id   text not null references public.person(person_id) on delete cascade,
  session_id  text not null references public.session(session_id) on delete cascade,
  primary key (person_id, session_id)
);

create table if not exists public.person_employed_by (
  person_id        text not null references public.person(person_id) on delete cascade,
  organization_id  text not null references public.organization(organization_id) on delete cascade,
  role_title       text,
  confidence       numeric,
  needs_review     boolean,
  primary key (person_id, organization_id)
);

create table if not exists public.person_founded_organization (
  person_id        text not null references public.person(person_id) on delete cascade,
  organization_id  text not null references public.organization(organization_id) on delete cascade,
  role_title       text,
  confidence       numeric,
  needs_review     boolean,
  primary key (person_id, organization_id)
);

create table if not exists public.organization_has_ceo (
  organization_id  text primary key references public.organization(organization_id) on delete cascade,
  person_id        text not null references public.person(person_id) on delete cascade,
  role_title       text,
  confidence       numeric,
  needs_review     boolean
);
