---
id: "rel:api.probes#details"
kind: details
schema: api
name: probes
of: "rel:api.probes"
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# api.probes — details

Spill-over from [the main page](probes.md).

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
SELECT id AS probe_id,
    slug,
    title,
    kind,
    hypothesis,
    model_policy,
    matrix,
    script_path,
    designed_by,
    designed_in_thread_id,
    ( SELECT array_agg(e.slug) AS array_agg
           FROM catalog.entity e
          WHERE e.id = ANY (p.subject_entity_ids)) AS subjects,
    ( SELECT count(*) AS count
           FROM verification.probe_claim pc
          WHERE pc.probe_id = p.id) AS claims,
    ( SELECT count(*) AS count
           FROM verification.probe_run r
          WHERE r.probe_id = p.id) AS runs,
    ( SELECT max(r.started_at) AS max
           FROM verification.probe_run r
          WHERE r.probe_id = p.id) AS last_run_at,
    ( SELECT jsonb_agg(jsonb_build_object('claim', c.statement, 'verdict', v.verdict, 'review_state', v.review_state)) AS jsonb_agg
           FROM verification.probe_verdict v
             JOIN evidence.claim c ON c.id = v.claim_id
          WHERE v.probe_id = p.id AND NOT (EXISTS ( SELECT 1
                   FROM verification.probe_verdict w
                  WHERE w.supersedes_id = v.id))) AS verdicts
   FROM verification.probe p;
```
