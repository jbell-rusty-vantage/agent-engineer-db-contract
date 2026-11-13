---
id: "rel:api.claim_surfaces#details"
kind: details
schema: api
name: claim_surfaces
of: "rel:api.claim_surfaces"
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# api.claim_surfaces — details

Spill-over from [the main page](claim_surfaces.md).

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
SELECT id AS claim_id,
    claim_type,
    statement,
    status::text AS status,
    structured ->> 'path'::text AS path,
    structured ->> 'assertion_mode'::text AS assertion_mode,
    structured -> 'speakers'::text AS speakers,
    structured ->> 'quote'::text AS quote,
    (structured ->> 't0_ms'::text)::integer AS start_ms,
    structured ->> 'deep_link'::text AS deep_link,
    (structured ->> 'talk_id'::text)::uuid AS talk_id,
    ( SELECT w.title
           FROM catalog.work w
          WHERE w.id = ((c.structured ->> 'talk_id'::text)::uuid)) AS talk,
    structured ->> 'consistency'::text AS consistency,
    structured ->> 'consistency_note'::text AS consistency_note,
    structured ->> 'compared_by'::text AS compared_by,
    api.names(( SELECT array_agg(s.entity_id) AS array_agg
           FROM evidence.claim_subject s
          WHERE s.claim_id = c.id)) AS subjects,
    ( SELECT jsonb_agg(jsonb_build_object('node_id', n.id, 'unit_kind', n.unit_kind, 'label', COALESCE(n.attributes ->> 'qualified_name'::text, n.attributes ->> 'heading'::text, "left"(n.inline_text, 80)), 'document', d.canonical_title, 'url', src.canonical_url, 'role', l.role) ORDER BY d.canonical_title) AS jsonb_agg
           FROM evidence.claim_evidence_link l
             JOIN evidence.locator lo ON lo.id = l.locator_id
             JOIN content.document_node n ON n.id = ((lo.selector ->> 'node_id'::text)::uuid)
             JOIN content.document_representation r ON r.id = n.representation_id
             JOIN content.document_version v ON v.id = r.document_version_id
             JOIN content.document d ON d.id = v.document_id
             LEFT JOIN evidence.source src ON src.id = d.canonical_source_id
          WHERE l.claim_id = c.id AND l.role = 'context'::text) AS surfaces,
    ( SELECT count(*) AS count
           FROM evidence.claim_conflict x
          WHERE x.claim_a_id = c.id OR x.claim_b_id = c.id) AS conflicts
   FROM evidence.claim c
  WHERE tenant_id = util.current_tenant_id() AND (structured ->> 'path'::text) = 'L1_candidate'::text AND structured ? 'quote'::text;
```
