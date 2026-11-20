---
id: "rel:api.source_registry#details"
kind: details
schema: api
name: source_registry
of: "rel:api.source_registry"
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# api.source_registry — details

Spill-over from [the main page](source_registry.md).

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
SELECT e.id AS source_entity_id,
    e.kind AS source_kind,
    e.display_name AS source,
    e.attributes ->> 'platform'::text AS platform,
    COALESCE(e.attributes ->> 'url'::text, e.attributes ->> 'profile_url'::text) AS url,
    t.id AS topic_entity_id,
    t.display_name AS topic,
    a.as_of,
    a.method,
    a.source_role_code,
    a.conflict_of_interest,
    a.method_disclosure,
    a.claims_observed,
    a.claims_checked,
    a.confirmed,
    a.qualified,
    a.refuted,
    a.median_lead_days,
    a.noise_ratio,
    a.authority_score,
    a.recommended_watch_level,
    ( SELECT p.watch_level
           FROM acquisition.attention_policy p
          WHERE (e.id = ANY (p.channel_entity_ids)) AND p.state <> 'retired'::text
          ORDER BY p.watch_level DESC
         LIMIT 1) AS current_watch_level,
    ( SELECT count(*) AS count
           FROM evidence.source s
          WHERE s.channel_entity_id = e.id) AS urls,
    a.rationale,
    a.id AS assessment_id,
    a.self_checked
   FROM ( SELECT DISTINCT ON (sa.subject_entity_id, sa.topic_entity_id) sa.id,
            sa.tenant_id,
            sa.subject_entity_id,
            sa.topic_entity_id,
            sa.as_of,
            sa.method,
            sa.source_role_code,
            sa.conflict_of_interest,
            sa.method_disclosure,
            sa.claims_observed,
            sa.claims_checked,
            sa.confirmed,
            sa.qualified,
            sa.refuted,
            sa.median_lead_days,
            sa.noise_ratio,
            sa.authority_score,
            sa.recommended_watch_level,
            sa.rationale,
            sa.inputs,
            sa.assessed_by,
            sa.receipt_id,
            sa.supersedes_id,
            sa.created_at,
            sa.self_checked
           FROM evidence.source_assessment sa
          ORDER BY sa.subject_entity_id, sa.topic_entity_id, sa.as_of DESC, sa.created_at DESC) a
     JOIN catalog.entity e ON e.id = a.subject_entity_id
     LEFT JOIN catalog.entity t ON t.id = a.topic_entity_id;
```
