---
id: "rel:api.claim_candidates#details"
kind: details
schema: api
name: claim_candidates
of: "rel:api.claim_candidates"
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# api.claim_candidates — details

Spill-over from [the main page](claim_candidates.md).

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
    structured ->> 'source_role'::text AS source_role,
    (structured ->> 'subject_resolved'::text)::boolean AS subject_resolved,
    structured -> 'speakers'::text AS speakers,
    structured ->> 'attribution'::text AS attribution,
    structured ->> 'learned_at'::text AS learned_at,
    structured ->> 'agrees_with_first_party_claim'::text AS agrees_with_first_party_claim,
    api.names(( SELECT array_agg(s.entity_id) AS array_agg
           FROM evidence.claim_subject s
          WHERE s.claim_id = c.id)) AS subjects,
    ( SELECT x.document_node_id
           FROM evidence.extraction_record x
          WHERE x.claim_id = c.id
         LIMIT 1) AS document_node_id,
    ( SELECT d.canonical_title
           FROM evidence.extraction_record x
             JOIN content.document_node n ON n.id = x.document_node_id
             JOIN content.document_representation r ON r.id = n.representation_id
             JOIN content.document_version v ON v.id = r.document_version_id
             JOIN content.document d ON d.id = v.document_id
          WHERE x.claim_id = c.id
         LIMIT 1) AS document_title,
    created_at
   FROM evidence.claim c
  WHERE tenant_id = util.current_tenant_id();
```
