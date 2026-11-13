---
id: "rel:evidence.source_assessment#details"
kind: details
schema: evidence
name: source_assessment
of: "rel:evidence.source_assessment"
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# evidence.source_assessment — details

Spill-over from [the main page](source_assessment.md).

## Relationships

Outbound: `source_role_code` → [`content.source_role`](../content/source_role.md)`.code`; `subject_entity_id` → [`catalog.entity`](../catalog/entity.md)`.id`; `supersedes_id` → [`evidence.source_assessment`](source_assessment.md)`.id`; `topic_entity_id` → [`catalog.entity`](../catalog/entity.md)`.id`.
Inbound: [`evidence.source_assessment`](source_assessment.md).supersedes_id.

## Indexes

| Index | Definition |
| --- | --- |
| `source_assessment_subject_ix` | `CREATE INDEX source_assessment_subject_ix ON evidence.source_assessment USING btree (subject_entity_id, topic_entity_id, as_of DESC)` |

## Triggers

_None._

## Row-level security

Enabled.
- `source_assessment_tenant` (ALL) for `public`: using `(tenant_id = util.current_tenant_id())`
