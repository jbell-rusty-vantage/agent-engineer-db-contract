# Build 04 R1: RV20 permissions, youth/guardian scope, processing consent, client grants, retention and source revocation

**Status: schema ACCEPTED by owner pre-approval, 2026-11-05** ("I will pre-approve RV 20 recommendations. Use the feature context to come up with the best structure you can."). Implemented together with Builds 01–03 in the disposable lab recorded in [Build 04](../../../platform/ai-engineer-research-2026-11-02/10-review-workspace/reviews/BUILD-04-SCHEMA-LAB.md). Not a legal opinion: youth and retention rules are stored as reviewed policy data and need jurisdiction review before any youth launch.

## A. What RV20 adds

Builds 01–03 already decide *who may act inside a workspace* (membership, distributions, evidence grants, appeal scope). RV20 adds the cross-cutting rules that apply to a **person** and an **installation**:

1. **Policy as data.** One versioned installation access policy holds jurisdiction youth rules, processor eligibility and retention windows. Code enforces whatever the active policy says; changing a rule is a reviewed new version, not a code change.
2. **Account eligibility.** An append-only account profile records age band (adult/teen/child/unknown), jurisdiction and how it was established, with the minimum data needed (no birth date).
3. **Optional, precisely scoped guardian help (U03).** A guardian link records verifiable consent where policy requires it, separately from what the guardian may see (`help_scope`, default none). No automatic parent access.
4. **Processing consent.** Sending a person's private material to an external processor (LLM inference, embeddings, connectors, third-party sharing) needs an active processing authorization when policy requires it. For children this is guardian consent, matching the amended COPPA rule's separate consent for third-party disclosure ([FTC, 2025](https://www.ftc.gov/news-events/news/press-releases/2025/01/ftc-finalizes-changes-childrens-privacy-rule-limiting-companies-ability-monetize-kids-data); [Federal Register 2025-04-22](https://www.federalregister.gov/documents/2025/04/22/2025-05904/childrens-online-privacy-protection-rule)).
5. **Client grants.** Harness, MCP, CLI and API clients act through revocable, scoped, expiring grants stored as token digests (never tokens). Every product command records which grant was used. This is the no-sandbox MCP client's authority (FC-D26).
6. **Retention.** Policy sets windows per data class. Durable saved work stays until removal for adults (FC-D30), but **child personal information requires a purpose-bound window** — the amended COPPA rule forbids indefinite retention. Expiry runs through Build 02 tracked removal.
7. **Source restriction.** An installation-level restriction on a source, capture or artifact (takedown, license change, legal hold, access lost, safety) takes effect at every read path for every workspace: bytes, passages, release items, exports. A legal hold blocks deletion.

## B. Relations (schema `access`, tenant-scoped)

| Relation / one row | Key columns | Rules |
| --- | --- | --- |
| `access.policy_version` / one reviewed installation policy | `tenant_id, version, body jsonb (aieng.access-policy.v1), body_sha256, approved_by, active_from` | UNIQUE(tenant_id, version). Immutable. Active = highest version with `active_from <= now()`. Body: per-jurisdiction `{child_under, teen_under, guardian_consent_required_under, public_publish_min_band, public_read_min_band, connector_min_band, external_processing_requires_guardian_under}`, `processors` allowlist per band, `retention` days per data class, `backup_purge_days` |
| `access.account_profile` / one append-only statement of a person's band and eligibility | `tenant_id, principal_id, seq, age_band, jurisdiction, established_by, eligibility, policy_version_id, created_at` | PK(tenant_id, principal_id, seq). age_band adult/teen/child/unknown; established_by self_declared/guardian/verified/admin; eligibility eligible/pending_guardian_consent/restricted/suspended. Current = highest seq. Missing profile = adult only when policy says the installation is adult-only; otherwise `unknown` is restricted |
| `access.guardian_link` / one guardian relationship for a youth account | `tenant_id, id, youth_id, guardian_id, state, consent_method, consent_evidence_artifact_id, help_scope text[], created_at, consented_at, revoked_at` | state invited/consented/declined/revoked. One non-revoked link per pair. `help_scope` ⊆ progress/results/projects/conversations, default empty — consent and visibility are separate. Either party can revoke visibility; revoking consent where policy requires it restricts the youth account |
| `access.processing_authorization` / one consent for a processor class/key and purpose | `tenant_id, id, principal_id, processor_class, processor_key, purpose, basis, guardian_link_id, policy_version_id, granted_by, granted_at, withdrawn_at` | processor_class llm_inference/embedding/connector/analytics/third_party_share. basis self/guardian. Guardian basis requires a consented link. Withdrawal is monotonic and triggers removal of derivatives made by that processor (e.g. embeddings) |
| `access.client_grant` / one revocable client credential | `tenant_id, id, principal_id, client_kind, label, token_sha256, scopes text[], workspace_ids uuid[], expires_at, created_at, last_used_at, revoked_at` | client_kind mcp/cli/harness/api. token_sha256 UNIQUE; raw token returned once at creation. scopes ⊆ read/author/learn/library/assess. `workspace_ids` NULL = all of the principal's workspaces. Expired/revoked grants are refused at every call |
| `access.source_restriction` / one installation-level restriction | `tenant_id, id, source_id?, capture_id?, artifact_id?, kind, effect, reason, decided_by, created_at, lifted_at` | Exactly one target. kind takedown/license_change/legal_hold/access_lost/safety; effect deny_bytes/deny_all/reference_only/hold_no_delete. Enforced in byte delivery, passage search, release items and removal |

**Amendment:** `authoring.command` gains `client_grant_id uuid?` (FK `access.client_grant`).

## C. Enforcement points

| Operation | Check |
| --- | --- |
| Open a `public_library` distribution | creator band ≥ `public_publish_min_band` |
| Read the public library | reader band ≥ `public_read_min_band`; official catalog and invited offers follow their own grants |
| Create a connection | band ≥ `connector_min_band` and active `connector` authorization for that provider |
| Enable semantic indexing | active `embedding` authorization for the space's provider |
| Assistant use of external LLM on private content | active `llm_inference` authorization when policy requires it |
| Evidence grant to a guardian | only via a consented guardian link whose `help_scope` covers it |
| Any command through a client | grant active, unexpired, scope covers the operation, workspace allowed |
| Byte/passage/release reads | no active `deny_*` source restriction on the target |
| Removal | blocked by `hold_no_delete` |

## D. Keeping current

Watch: new policy versions (re-evaluate eligibility; restrictions apply immediately, relaxations only for new actions), guardian link or consent changes, processing authorization withdrawal (purge derivatives), client grant expiry/revocation, source restrictions (deny at once; maintainers see affected offers/works), retention expiry (removal runs). No notification delivery or schedule is started by the schema.

## E. Staged

Organization/school accounts and assigned teachers; age-assurance providers; jurisdiction legal review; consent UI; disclosure logs for audits; cross-tenant hosted catalog rules.
