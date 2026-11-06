-- Full-text search: generated tsvector columns + GIN indexes.
-- Version matches supabase_migrations on hosted project (supabase-blue-ocean).

ALTER TABLE person ADD COLUMN IF NOT EXISTS fts tsvector
GENERATED ALWAYS AS (
  setweight(to_tsvector('english', coalesce(full_name, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(first_name, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(last_name, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(bio, '')), 'C') ||
  setweight(to_tsvector('english', coalesce(tag_line, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(expertise_or_focus_area, '')), 'C') ||
  setweight(to_tsvector('english', coalesce(role_title, '')), 'C')
) STORED;

CREATE INDEX IF NOT EXISTS person_fts_idx ON person USING GIN (fts);

ALTER TABLE organization ADD COLUMN IF NOT EXISTS fts tsvector
GENERATED ALWAYS AS (
  setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(overview, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(primary_ai_focus, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(flagship_products, '')), 'C') ||
  setweight(to_tsvector('english', coalesce(website_domain, '')), 'C') ||
  setweight(to_tsvector('english', coalesce(organization_type, '')), 'C')
) STORED;

CREATE INDEX IF NOT EXISTS organization_fts_idx ON organization USING GIN (fts);

ALTER TABLE youtube_video ADD COLUMN IF NOT EXISTS fts tsvector
GENERATED ALWAYS AS (
  setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(description, '')), 'B')
) STORED;

CREATE INDEX IF NOT EXISTS youtube_video_fts_idx ON youtube_video USING GIN (fts);

COMMENT ON COLUMN person.fts IS 'Full-text search vector; use websearch via PostgREST textSearch';
COMMENT ON COLUMN organization.fts IS 'Full-text search vector; use websearch via PostgREST textSearch';
COMMENT ON COLUMN youtube_video.fts IS 'Full-text search vector; use websearch via PostgREST textSearch';
