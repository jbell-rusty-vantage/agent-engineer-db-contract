---
id: "rel:evidence.source_provider_attempt#details"
kind: details
schema: evidence
name: source_provider_attempt
of: "rel:evidence.source_provider_attempt"
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.source_provider_attempt — details

Spill-over from [the main page](source_provider_attempt.md).

## Constraints
- PK (id)
- unique (tenant_id, id)
- unique (tenant_id, idempotency_key)
- unique (tenant_id, source_query_id, attempt_ordinal)
- check `source_attempt_original_dispatch_ck`: `(((original_dispatch_token IS NULL) AND (original_dispatch_fencing_token IS NULL)) OR ((original_dispatch_token IS NOT NULL) AND (original_dispatch_fencing_token IS NOT NULL) AND (original_dispatch_fencing_token > 0)))`
- check `source_attempt_retry_ck`: `((retry_of_attempt_id IS NULL) OR ((retry_of_attempt_id <> id) AND (root_attempt_id IS NOT NULL) AND (attempt_ordinal > 0)))`
- check `source_provider_attempt_attempt_ordinal_check`: `(attempt_ordinal >= 0)`
- check `source_provider_attempt_check`: `((completed_at IS NULL) OR (completed_at >= started_at))`
- check `source_provider_attempt_check1`: `(((state = 'started'::text) AND (completed_at IS NULL) AND (completion_sha256 IS NULL) AND (raw_output_artifact_id IS NULL) AND (failure_code IS NULL) AND (((dispatch_owner IS NULL) AND (dispatch_token IS NULL) AND (dispatch_claimed_at IS NULL) AND (dispatch_expires_at IS NULL)) OR ((dispatch_owner IS NOT NULL) AND (dispatch_token IS NOT NULL) AND (dispatch_claimed_at IS NOT NULL) AND (dispatch_expires_at IS NOT NULL) AND (dispatch_expires_at > dispatch_claimed_at)))) OR ((state = 'succeeded'::text) AND (completed_at IS NOT NULL) AND (completion_sha256 IS NOT NULL) AND (COALESCE(raw_output_artifact_id, external_receipt_artifact_id) IS NOT NULL) AND (failure_code IS NULL) AND (dispatch_owner IS NULL) AND (dispatch_token IS NULL) AND (dispatch_claimed_at IS NULL) AND (dispatch_expires_at IS NULL)) OR ((state = ANY (ARRAY['failed'::text, 'uncertain'::text, 'cancelled'::text])) AND (completed_at IS NOT NULL) AND (completion_sha256 IS NOT NULL) AND (COALESCE(raw_output_artifact_id, external_receipt_artifact_id) IS NOT NULL) AND (failure_code IS NOT NULL) AND (dispatch_owner IS NULL) AND (dispatch_token IS NULL) AND (dispatch_claimed_at IS NULL) AND (dispatch_expires_at IS NULL)))`
- check `source_provider_attempt_check2`: `(((origin = 'managed'::text) AND (external_receipt_artifact_id IS NULL) AND ((state = 'started'::text) OR (raw_output_artifact_id IS NOT NULL))) OR ((origin = 'imported'::text) AND (external_receipt_artifact_id IS NOT NULL) AND (state <> 'started'::text)))`
- check `source_provider_attempt_completion_sha256_check`: `((completion_sha256 IS NULL) OR (completion_sha256 ~ '^[0-9a-f]{64}$'::text))`
- check `source_provider_attempt_dispatch_fencing_token_check`: `(dispatch_fencing_token >= 0)`
- check `source_provider_attempt_failure_code_check`: `((failure_code IS NULL) OR (failure_code ~ '^[A-Z][A-Z0-9_]{2,127}$'::text))`
- check `source_provider_attempt_idempotency_key_check`: `((length(btrim(idempotency_key)) >= 1) AND (length(btrim(idempotency_key)) <= 256))`
- check `source_provider_attempt_origin_check`: `(origin = ANY (ARRAY['managed'::text, 'imported'::text]))`
- check `source_provider_attempt_provider_version_check`: `((length(btrim(provider_version)) >= 1) AND (length(btrim(provider_version)) <= 128))`
- check `source_provider_attempt_request_sha256_check`: `(request_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `source_provider_attempt_requested_urls_check`: `(jsonb_typeof(requested_urls) = 'array'::text)`
- check `source_provider_attempt_state_check`: `(state = ANY (ARRAY['started'::text, 'succeeded'::text, 'failed'::text, 'uncertain'::text, 'cancelled'::text]))`

## Relationships

Outbound: `tenant_id,completion_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.tenant_id,id`; `tenant_id,retry_of_attempt_id` → [`evidence.source_provider_attempt`](source_provider_attempt.md)`.tenant_id,id`; `tenant_id,root_attempt_id` → [`evidence.source_provider_attempt`](source_provider_attempt.md)`.tenant_id,id`; `external_receipt_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.id` (+tenant); `provider_code` → [`evidence.search_provider`](search_provider.md)`.code`; `raw_output_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.id` (+tenant); `request_artifact_id` → [`orchestration.artifact`](../orchestration/artifact.md)`.id` (+tenant); `source_query_id` → [`evidence.source_query`](source_query.md)`.id` (+tenant) on delete restrict.
Inbound: [`evidence.provider_result`](provider_result.md).source_provider_attempt_id, [`evidence.source_encounter`](source_encounter.md).source_provider_attempt_id, [`evidence.source_provider_attempt`](source_provider_attempt.md).retry_of_attempt_id|root_attempt_id, [`evidence.source_result_selection`](source_result_selection.md).attempt_id, [`evidence.source_selection_revision`](source_selection_revision.md).attempt_id.

## Indexes

| Index | Definition |
| --- | --- |
| `source_provider_attempt_query_idx` | `CREATE INDEX source_provider_attempt_query_idx ON evidence.source_provider_attempt USING btree (tenant_id, source_query_id, started_at)` |
| `source_provider_attempt_tenant_id_id_key` | `CREATE UNIQUE INDEX source_provider_attempt_tenant_id_id_key ON evidence.source_provider_attempt USING btree (tenant_id, id)` |
| `source_provider_attempt_tenant_id_idempotency_key_key` | `CREATE UNIQUE INDEX source_provider_attempt_tenant_id_idempotency_key_key ON evidence.source_provider_attempt USING btree (tenant_id, idempotency_key)` |
| `source_provider_attempt_tenant_id_source_query_id_attempt_o_key` | `CREATE UNIQUE INDEX source_provider_attempt_tenant_id_source_query_id_attempt_o_key ON evidence.source_provider_attempt USING btree (tenant_id, source_query_id, attempt_ordinal)` |
| `source_provider_attempt_terminal_idx` | `CREATE INDEX source_provider_attempt_terminal_idx ON evidence.source_provider_attempt USING btree (tenant_id, state, completed_at) WHERE (state <> 'started'::text)` |

## Triggers

- `artifact_retirement_0f1a05c99b3406a2b0e4e888` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_0f1a05c99b3406a2b0e4e888 BEFORE INSERT OR UPDATE ON evidence.source_provider_attempt FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "raw_output_artifact_id", "parent": "id"}]')`
- `artifact_retirement_36494a1d0ab44dd62496402c` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_36494a1d0ab44dd62496402c BEFORE INSERT OR UPDATE ON evidence.source_provider_attempt FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "completion_artifact_id", "parent": "id"}]')`
- `artifact_retirement_4d9f72e38570044458d04025` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_4d9f72e38570044458d04025 BEFORE INSERT OR UPDATE ON evidence.source_provider_attempt FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "request_artifact_id", "parent": "id"}]')`
- `artifact_retirement_94ee16aebff2670ee3981d24` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_94ee16aebff2670ee3981d24 BEFORE INSERT OR UPDATE ON evidence.source_provider_attempt FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "raw_output_artifact_id", "parent": "id"}]')`
- `artifact_retirement_a007b9b7729ad7a7c55f2959` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_a007b9b7729ad7a7c55f2959 BEFORE INSERT OR UPDATE ON evidence.source_provider_attempt FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "external_receipt_artifact_id", "parent": "id"}]')`
- `artifact_retirement_ed4a7bee9537deb067a27ea4` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_ed4a7bee9537deb067a27ea4 BEFORE INSERT OR UPDATE ON evidence.source_provider_attempt FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "request_artifact_id", "parent": "id"}]')`
- `artifact_retirement_ef887290123bd441b53aef22` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_ef887290123bd441b53aef22 BEFORE INSERT OR UPDATE ON evidence.source_provider_attempt FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "external_receipt_artifact_id", "parent": "id"}]')`
- `source_provider_attempt_guard` → [`evidence.guard_source_provider_attempt`](../../functions/evidence/guard_source_provider_attempt.md): `CREATE TRIGGER source_provider_attempt_guard BEFORE DELETE OR UPDATE ON evidence.source_provider_attempt FOR EACH ROW EXECUTE FUNCTION evidence.guard_source_provider_attempt()`

## Row-level security

Enabled.
- `source_provider_attempt_tenant_access` (ALL) for `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
