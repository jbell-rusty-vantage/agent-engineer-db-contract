---
id: "rel:api.works_authored#details"
kind: details
schema: api
name: works_authored
of: "rel:api.works_authored"
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
---
# api.works_authored — details

Spill-over from [the main page](works_authored.md).

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
SELECT w.id AS work_id,
    w.kind,
    w.slug,
    r.title,
    r.id AS head_revision_id,
    r.revision_no,
    w.workspace_id,
    ws.kind AS workspace_kind,
    (EXISTS ( SELECT 1
           FROM authoring.release_item i
          WHERE i.revision_id = r.id AND (i.disposition = ANY (ARRAY['include'::text, 'snapshot'::text])))) AS released,
    api.names(( SELECT array_agg(b.entity_id) AS array_agg
           FROM authoring.revision_binding b
          WHERE b.revision_id = r.id AND b.relation = 'covers'::text AND b.entity_id IS NOT NULL)) AS covers_concepts,
    api.names(( SELECT array_agg(u.x) AS array_agg
           FROM ( SELECT b.entity_id AS x
                   FROM authoring.revision_binding b
                  WHERE b.revision_id = r.id AND b.relation = 'uses'::text AND b.entity_id IS NOT NULL
                UNION
                 SELECT q.entity_id
                   FROM authoring.runtime_requirement q
                  WHERE q.revision_id = r.id AND q.entity_id IS NOT NULL) u)) AS uses_software,
    ( SELECT array_agg((q.name || ' '::text) || COALESCE(q.version_spec, ''::text)) AS array_agg
           FROM authoring.runtime_requirement q
          WHERE q.revision_id = r.id) AS runtime_requirements,
    r.knowledge_seq,
    r.created_at,
    1::smallint AS source_tier
   FROM authoring.work w
     JOIN authoring.work_revision r ON r.id = w.head_revision_id
     JOIN authoring.workspace ws ON ws.id = w.workspace_id
  WHERE w.tenant_id = util.default_tenant_id() AND (w.kind = ANY (ARRAY['course'::text, 'track'::text, 'module'::text, 'lesson'::text, 'activity'::text, 'report'::text, 'project_template'::text, 'challenge'::text, 'component'::text, 'experience'::text]));
```
