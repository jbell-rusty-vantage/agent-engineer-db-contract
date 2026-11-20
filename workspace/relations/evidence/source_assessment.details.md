---
id: "rel:evidence.source_assessment#details"
kind: details
schema: evidence
name: source_assessment
of: "rel:evidence.source_assessment"
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
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

- `source_assessment_append_only` → [`util.reject_mutation`](../../functions/util/reject_mutation.md): `CREATE TRIGGER source_assessment_append_only BEFORE DELETE OR UPDATE ON evidence.source_assessment FOR EACH ROW EXECUTE FUNCTION util.reject_mutation()`
- `source_assessment_human_judgment` → [`verification.guard_human_judgment`](../../functions/verification/guard_human_judgment.md): `CREATE TRIGGER source_assessment_human_judgment BEFORE INSERT ON evidence.source_assessment FOR EACH ROW EXECUTE FUNCTION verification.guard_human_judgment()`

## Row-level security

Enabled.
- `source_assessment_tenant` (ALL) for `public`: using `(tenant_id = util.current_tenant_id())`
