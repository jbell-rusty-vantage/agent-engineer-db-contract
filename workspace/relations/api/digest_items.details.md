---
id: "rel:api.digest_items#details"
kind: details
schema: api
name: digest_items
of: "rel:api.digest_items"
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# api.digest_items — details

Spill-over from [the main page](digest_items.md).

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
SELECT i.id AS item_id,
    g.id AS digest_id,
    g.scope,
    g.scope_node_id,
    ( SELECT sn.attributes ->> 'heading'::text
           FROM content.document_node sn
          WHERE sn.id = g.scope_node_id) AS scope_heading,
    d.id AS document_id,
    d.canonical_title AS document_title,
    d.document_type_code,
    v.id AS document_version_id,
    v.version_label,
    i.ordinal,
    i.item_kind,
    i.text,
    i.payload,
    i.node_ids,
    cardinality(i.node_ids) AS anchor_count,
    i.entity_id,
    ( SELECT e.display_name
           FROM catalog.entity e
          WHERE e.id = i.entity_id) AS entity,
    i.payload ->> 'role'::text AS entity_role,
    i.claim_id,
    i.unit_change_id,
    i.confidence,
    g.producer_kind,
    g.producer_identity,
    ( SELECT min(n.start_ms) AS min
           FROM content.document_node n
          WHERE n.id = ANY (i.node_ids)) AS start_ms,
    ( SELECT max(COALESCE(n.end_ms, n.start_ms)) AS max
           FROM content.document_node n
          WHERE n.id = ANY (i.node_ids)) AS end_ms,
    api.document_work(d.id) AS work_id,
    api.timecode_link(( SELECT w.canonical_url
           FROM catalog.work w
          WHERE w.id = api.document_work(d.id)), ( SELECT min(n.start_ms) AS min
           FROM content.document_node n
          WHERE n.id = ANY (i.node_ids))) AS deep_link
   FROM content.digest_item i
     JOIN content.document_digest g ON g.id = i.digest_id
     JOIN content.document_version v ON v.id = g.document_version_id
     JOIN content.document d ON d.id = v.document_id
  WHERE i.tenant_id = util.current_tenant_id() AND g.lifecycle = 'active'::text;
```
