---
id: "rel:api.source_registry#details"
kind: details
schema: api
name: source_registry
of: "rel:api.source_registry"
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
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
    a.id AS assessment_id
   FROM ( SELECT DISTINCT ON (source_assessment.subject_entity_id, source_assessment.topic_entity_id) source_assessment.id,
            source_assessment.tenant_id,
            source_assessment.subject_entity_id,
            source_assessment.topic_entity_id,
            source_assessment.as_of,
            source_assessment.method,
            source_assessment.source_role_code,
            source_assessment.conflict_of_interest,
            source_assessment.method_disclosure,
            source_assessment.claims_observed,
            source_assessment.claims_checked,
            source_assessment.confirmed,
            source_assessment.qualified,
            source_assessment.refuted,
            source_assessment.median_lead_days,
            source_assessment.noise_ratio,
            source_assessment.authority_score,
            source_assessment.recommended_watch_level,
            source_assessment.rationale,
            source_assessment.inputs,
            source_assessment.assessed_by,
            source_assessment.receipt_id,
            source_assessment.supersedes_id,
            source_assessment.created_at
           FROM evidence.source_assessment
          ORDER BY source_assessment.subject_entity_id, source_assessment.topic_entity_id, source_assessment.as_of DESC, source_assessment.created_at DESC) a
     JOIN catalog.entity e ON e.id = a.subject_entity_id
     LEFT JOIN catalog.entity t ON t.id = a.topic_entity_id;
```
