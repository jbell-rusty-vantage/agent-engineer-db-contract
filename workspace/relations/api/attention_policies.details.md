---
id: "rel:api.attention_policies#details"
kind: details
schema: api
name: attention_policies
of: "rel:api.attention_policies"
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# api.attention_policies — details

Spill-over from [the main page](attention_policies.md).

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
SELECT p.id AS policy_id,
    p.slug,
    p.title,
    p.scope_kind,
    p.watch_level,
    p.cadence,
    p.depth,
    p.selection,
    p.triggers,
    p.budget_usd_per_run,
    p.budget_credits_per_run,
    p.state,
    p.rationale,
    p.decided_by,
    ( SELECT array_agg(e.display_name) AS array_agg
           FROM catalog.entity e
          WHERE e.id = ANY (p.channel_entity_ids)) AS channels,
    ( SELECT array_agg(e.slug) AS array_agg
           FROM catalog.entity e
          WHERE e.id = ANY (p.subject_entity_ids)) AS subjects,
    m.slug AS mission,
    p.designed_in_thread_id,
    s.started_at AS last_sweep_at,
    s.outcome AS last_outcome,
    s.items_seen AS last_seen,
    s.items_selected AS last_selected,
    ( SELECT count(*) AS count
           FROM acquisition.attention_sweep x
          WHERE x.policy_id = p.id) AS sweeps,
    ( SELECT sum(x.spend_usd) AS sum
           FROM acquisition.attention_sweep x
          WHERE x.policy_id = p.id) AS spend_usd
   FROM acquisition.attention_policy p
     LEFT JOIN orchestration.mission m ON m.id = p.mission_id
     LEFT JOIN LATERAL ( SELECT x.id,
            x.tenant_id,
            x.policy_id,
            x.trigger_kind,
            x.trigger_ref,
            x.mission_id,
            x.origin_kind,
            x.window_from,
            x.window_to,
            x.started_at,
            x.ended_at,
            x.items_seen,
            x.items_selected,
            x.items_captured,
            x.rejected,
            x.spend_usd,
            x.credits,
            x.outcome,
            x.receipt_id,
            x.note
           FROM acquisition.attention_sweep x
          WHERE x.policy_id = p.id
          ORDER BY x.started_at DESC
         LIMIT 1) s ON true
  WHERE NOT (EXISTS ( SELECT 1
           FROM acquisition.attention_policy q
          WHERE q.supersedes_id = p.id));
```
