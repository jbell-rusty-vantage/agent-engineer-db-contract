---
id: "rel:api.benchmarks#details"
kind: details
schema: api
name: benchmarks
of: "rel:api.benchmarks"
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# api.benchmarks — details

Spill-over from [the main page](benchmarks.md).

## Relationships

Outbound: none.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## View definition

```sql
SELECT id AS benchmark_id,
    display_name AS benchmark,
    slug,
    attributes ->> 'organizer'::text AS organizer,
    attributes ->> 'metric'::text AS metric,
    attributes ->> 'score_type'::text AS score_type,
    attributes ->> 'domain'::text AS domain,
    (attributes ->> 'agentic'::text)::boolean AS agentic,
    attributes ->> 'canonical_url'::text AS canonical_url,
    COALESCE(( SELECT array_agg(v.display_name ORDER BY v.display_name) AS array_agg
           FROM catalog.relationship r
             JOIN catalog.entity v ON v.id = r.from_entity_id
          WHERE r.to_entity_id = b.id AND r.kind = 'version_of'::text AND r.k_to IS NULL AND v.kind = 'benchmark_version'::text), '{}'::text[]) AS versions,
    ( SELECT count(*) AS count
           FROM api.benchmark_scores sc
          WHERE sc.benchmark_id = b.id) AS score_count,
    ( SELECT array_agg(DISTINCT sc.reported_by) AS array_agg
           FROM api.benchmark_scores sc
          WHERE sc.benchmark_id = b.id) AS reported_by_kinds
   FROM catalog.entity b
  WHERE tenant_id = util.current_tenant_id() AND kind = 'benchmark'::text AND lifecycle = 'active'::text;
```
