---
id: "fn:util.ensure_month_partitions(int4)"
kind: function
schema: util
name: ensure_month_partitions
domain: api-surface
lens: machinery
overloads: ["fn:util.ensure_month_partitions(int4)"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: ["p_months_ahead must be >= 0"]
touches: { reads: [], writes: [] }
tokens: [util, ensure_month_partitions, util.ensure_month_partitions]
defined_in: ["20260826001200_observability.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# util.ensure_month_partitions

Domain `api-surface`, lens `machinery`.

## ensure_month_partitions(integer) → integer

function, volatile, security invoker, language plpgsql, config `search_path=""`. Idempotently creates monthly partitions for the observability event tables, from one month back to p_months_ahead forward. Call from the control plane; there is no pg_cron on this instance.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_months_ahead` | `integer` | `3` | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `p_months_ahead must be >= 0`.

TypeScript: `Database["util"]["Functions"]["ensure_month_partitions"]`.

Defined in: `20260826001200_observability.sql`.
