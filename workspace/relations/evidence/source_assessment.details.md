---
id: "rel:evidence.source_assessment#details"
kind: details
schema: evidence
name: source_assessment
of: "rel:evidence.source_assessment"
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# evidence.source_assessment — details

Spill-over from [the main page](source_assessment.md).

## Constraints
- PK (id)
- check `source_assessment_authority_score_check`: `((authority_score >= (0)::numeric) AND (authority_score <= (100)::numeric))`
- check `source_assessment_check`: `(claims_checked = ((confirmed + qualified) + refuted))`
- check `source_assessment_check1`: `(claims_checked <= claims_observed)`
- check `source_assessment_conflict_of_interest_check`: `(conflict_of_interest = ANY (ARRAY['none'::text, 'vendor_self'::text, 'vendor_adjacent'::text, 'competitor'::text, 'unknown'::text]))`
- check `source_assessment_method_check`: `(method = ANY (ARRAY['prior'::text, 'derived'::text, 'reviewed'::text]))`
- check `source_assessment_method_disclosure_check`: `(method_disclosure = ANY (ARRAY['none'::text, 'partial'::text, 'full'::text, 'not_applicable'::text]))`
- check `source_assessment_recommended_watch_level_check`: `(recommended_watch_level = ANY (ARRAY['W0'::text, 'W1'::text, 'W2'::text, 'W3'::text]))`
- check `source_assessment_self_checked_check`: `(self_checked >= 0)`

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
