---
id: "rel:orchestration.verification_semantic_response_observation#details"
kind: details
schema: orchestration
name: verification_semantic_response_observation
of: "rel:orchestration.verification_semantic_response_observation"
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# orchestration.verification_semantic_response_observation — details

Spill-over from [the main page](verification_semantic_response_observation.md).

## Constraints
- PK (tenant_id, provider_attempt_id)
- check `verification_semantic_response_o_response_envelope_sha256_check`: `(response_envelope_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_semantic_response_obs_dispatch_fencing_token_check`: `(dispatch_fencing_token > 0)`
- check `verification_semantic_response_obser_blinded_input_sha256_check`: `(blinded_input_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_semantic_response_obser_reported_cost_micros_check`: `((reported_cost_micros IS NULL) OR ((reported_cost_micros >= 0) AND (reported_cost_micros <= 2000000000)))`
- check `verification_semantic_response_obser_reported_cost_status_check`: `(reported_cost_status = ANY (ARRAY['reported'::text, 'unknown'::text]))`
- check `verification_semantic_response_observ_raw_response_sha256_check`: `(raw_response_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_semantic_response_observa_observation_sha256_check`: `(observation_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_semantic_response_observat_completion_tokens_check`: `((completion_tokens IS NULL) OR ((completion_tokens >= 0) AND (completion_tokens <= 2000000)))`
- check `verification_semantic_response_observatio_requested_model_check`: `(requested_model ~ '^[A-Za-z0-9_./:-]{1,255}$'::text)`
- check `verification_semantic_response_observation_check`: `(producer_attempt_id <> provider_attempt_id)`
- check `verification_semantic_response_observation_check1`: `((profile_artifact_id <> blinded_input_artifact_id) AND (profile_artifact_id <> request_artifact_id) AND (profile_artifact_id <> raw_response_artifact_id) AND (profile_artifact_id <> response_envelope_artifact_id) AND (profile_artifact_id <> observation_artifact_id) AND (blinded_input_artifact_id <> request_artifact_id) AND (blinded_input_artifact_id <> raw_response_artifact_id) AND (blinded_input_artifact_id <> response_envelope_artifact_id) AND (blinded_input_artifact_id <> observation_artifact_id) AND (request_artifact_id <> raw_response_artifact_id) AND (request_artifact_id <> response_envelope_artifact_id) AND (request_artifact_id <> observation_artifact_id) AND (raw_response_artifact_id <> response_envelope_artifact_id) AND (raw_response_artifact_id <> observation_artifact_id) AND (response_envelope_artifact_id <> observation_artifact_id))`
- check `verification_semantic_response_observation_check2`: `(((model_status = 'matched'::text) AND (observed_model IS NOT NULL) AND (observed_model = requested_model) AND (NOT revalidation_required)) OR ((model_status = 'missing'::text) AND (observed_model IS NULL) AND revalidation_required) OR ((model_status = 'mismatch'::text) AND (observed_model IS NOT NULL) AND (observed_model <> requested_model) AND revalidation_required))`
- check `verification_semantic_response_observation_check3`: `(((reported_cost_status = 'reported'::text) AND (reported_cost_micros IS NOT NULL)) OR ((reported_cost_status = 'unknown'::text) AND (reported_cost_micros IS NULL)))`
- check `verification_semantic_response_observation_check4`: `((total_tokens IS NULL) OR (((prompt_tokens IS NULL) OR (total_tokens >= prompt_tokens)) AND ((completion_tokens IS NULL) OR (total_tokens >= completion_tokens)) AND ((prompt_tokens IS NULL) OR (completion_tokens IS NULL) OR (total_tokens >= (prompt_tokens + completion_tokens)))))`
- check `verification_semantic_response_observation_model_status_check`: `(model_status = ANY (ARRAY['matched'::text, 'missing'::text, 'mismatch'::text]))`
- check `verification_semantic_response_observation_observed_model_check`: `((observed_model IS NULL) OR (observed_model ~ '^[A-Za-z0-9_./:-]{1,255}$'::text))`
- check `verification_semantic_response_observation_profile_sha256_check`: `(profile_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_semantic_response_observation_prompt_tokens_check`: `((prompt_tokens IS NULL) OR ((prompt_tokens >= 0) AND (prompt_tokens <= 2000000)))`
- check `verification_semantic_response_observation_request_sha256_check`: `(request_sha256 ~ '^[0-9a-f]{64}$'::text)`
- check `verification_semantic_response_observation_total_tokens_check`: `((total_tokens IS NULL) OR ((total_tokens >= 0) AND (total_tokens <= 4000000)))`

## Relationships

Outbound: `tenant_id,blinded_input_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`; `tenant_id,observation_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`; `tenant_id,producer_attempt_id` → [`orchestration.attempt`](attempt.md)`.tenant_id,id`; `tenant_id,profile_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`; `tenant_id,provider_attempt_id` → [`orchestration.verification_provider_attempt`](verification_provider_attempt.md)`.tenant_id,id`; `tenant_id,raw_response_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`; `tenant_id,request_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`; `tenant_id,response_envelope_artifact_id` → [`orchestration.artifact`](artifact.md)`.tenant_id,id`; `tenant_id,operation_id` → [`knowledge_service.operation`](../knowledge_service/operation.md)`.tenant_id,id`; `tenant_id,operation_step_id` → [`knowledge_service.operation_step`](../knowledge_service/operation_step.md)`.tenant_id,id`.
Inbound: none.

## Indexes

_None._

## Triggers

- `artifact_retirement_3071116bdd1e11fa63a36336` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_3071116bdd1e11fa63a36336 BEFORE INSERT OR UPDATE ON orchestration.verification_semantic_response_observation FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "request_artifact_id", "parent": "id"}]')`
- `artifact_retirement_41fe33650052aaa782380b7a` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_41fe33650052aaa782380b7a BEFORE INSERT OR UPDATE ON orchestration.verification_semantic_response_observation FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "profile_artifact_id", "parent": "id"}]')`
- `artifact_retirement_6eb528afc90ba0ed7b044f4b` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_6eb528afc90ba0ed7b044f4b BEFORE INSERT OR UPDATE ON orchestration.verification_semantic_response_observation FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "raw_response_artifact_id", "parent": "id"}]')`
- `artifact_retirement_75a04c6e86eb814ed154f6d0` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_75a04c6e86eb814ed154f6d0 BEFORE INSERT OR UPDATE ON orchestration.verification_semantic_response_observation FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "response_envelope_artifact_id", "parent": "id"}]')`
- `artifact_retirement_9a8c3b2d52e1c8f2ee382258` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_9a8c3b2d52e1c8f2ee382258 BEFORE INSERT OR UPDATE ON orchestration.verification_semantic_response_observation FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "blinded_input_artifact_id", "parent": "id"}]')`
- `artifact_retirement_d5035fdaef48abee352b082a` → [`orchestration.guard_retired_artifact_reference`](../../functions/orchestration/guard_retired_artifact_reference.md): `CREATE TRIGGER artifact_retirement_d5035fdaef48abee352b082a BEFORE INSERT OR UPDATE ON orchestration.verification_semantic_response_observation FOR EACH ROW EXECUTE FUNCTION orchestration.guard_retired_artifact_reference('[{"local": "tenant_id", "parent": "tenant_id"}, {"local": "observation_artifact_id", "parent": "id"}]')`
- `verification_semantic_response_observation_guard` → [`orchestration.verification_semantic_response_observation_guard`](../../functions/orchestration/verification_semantic_response_observation_guard.md): `CREATE TRIGGER verification_semantic_response_observation_guard BEFORE INSERT OR DELETE OR UPDATE ON orchestration.verification_semantic_response_observation FOR EACH ROW EXECUTE FUNCTION orchestration.verification_semantic_response_observation_guard()`

## Row-level security

Enabled.
- `verification_semantic_response_observation_reader` (SELECT) for `app_reader`: using `(tenant_id = util.current_tenant_id())`
- `verification_semantic_response_observation_worker` (ALL) for `control_plane`, `executor_service`, `verifier_agent`: using `(tenant_id = util.current_tenant_id())`; with check `(tenant_id = util.current_tenant_id())`
