-- LOCAL TEST STUB of pg_jsonschema: same signatures, no validation (always true).
create function jsonb_matches_schema(schema json, instance jsonb) returns boolean language sql immutable as 'select true';
create function json_matches_schema(schema json, instance json) returns boolean language sql immutable as 'select true';
