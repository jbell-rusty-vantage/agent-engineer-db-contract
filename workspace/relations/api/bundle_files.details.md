---
id: "rel:api.bundle_files#details"
kind: details
schema: api
name: bundle_files
of: "rel:api.bundle_files"
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# api.bundle_files — details

Spill-over from [the main page](bundle_files.md).

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
SELECT n.id AS node_id,
    d.id AS document_id,
    v.version_label,
    ( SELECT r_1.entity_id
           FROM content.unit_entity_role r_1
          WHERE r_1.node_id = n.id AND r_1.role = 'capability'::text
         LIMIT 1) AS capability_id,
    ( SELECT e.display_name
           FROM content.unit_entity_role r_1
             JOIN catalog.entity e ON e.id = r_1.entity_id
          WHERE r_1.node_id = n.id AND r_1.role = 'capability'::text
         LIMIT 1) AS capability,
    n.attributes ->> 'path'::text AS path,
    (n.attributes ->> 'size'::text)::bigint AS size,
    n.attributes ->> 'mode'::text AS mode,
    (n.attributes ->> 'executable'::text)::boolean AS executable,
    n.attributes ->> 'git_blob_id'::text AS git_blob_id,
    n.attributes ->> 'sha256'::text AS sha256,
    n.attributes ->> 'role'::text AS file_role,
    n.attributes ->> 'commit'::text AS commit,
    d.attributes ->> 'custody_level'::text AS custody_level
   FROM content.document d
     JOIN content.document_version v ON v.document_id = d.id
     JOIN content.document_representation r ON r.document_version_id = v.id
     JOIN content.document_node n ON n.representation_id = r.id
  WHERE d.tenant_id = util.current_tenant_id() AND n.unit_kind = 'bundle_file'::text;
```
