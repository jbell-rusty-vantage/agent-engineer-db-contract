---
id: "fn:api.database_release()"
kind: function
schema: api
name: database_release
domain: api-surface
lens: corpus
overloads: ["fn:api.database_release()"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [util.database_release], writes: [] }
tokens: [api, database_release, api.database_release]
defined_in: ["20261120120000_database_release_record.sql"]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# api.database_release

Domain `api-surface`, lens `corpus`.

## database_release() → jsonb

function, stable, security definer, language plpgsql, config `search_path=""`. Which release this database is, for a service to check before it starts. Returns {format, release, state, declared, observed, stamped_at, stamped_by}. declared is the newest stamp (migration head, count, digest, pinned components). observed is read now: the live migration version and count, and the installed version of each guest component (null when that component is not in this database). state: unstamped (no stamp), current (the live head is the stamped head and every present component matches its pin), ahead (migrations applied after the stamp, as on a lab during a unit session), inconsistent (the live head is behind the stamp), component_drift (a present component differs from its pin), unverifiable (the migration list cannot be read).

No arguments.

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`util.database_release`](../../relations/util/database_release.md); writes —; calls —.

TypeScript: `Database["api"]["Functions"]["database_release"]`.

Defined in: `20261120120000_database_release_record.sql`.
