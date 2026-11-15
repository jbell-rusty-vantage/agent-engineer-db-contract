---
id: rules
kind: entry
rules: 14
rules_version: "ingestion-rules.v1@c36ddd5cc0bc31406df785eb0333381a6ca07fd91181d2340a7733203cbdb687"
workspace_fingerprint: "sha256:195a7bf46350274849f7ac517bb02381bbf8851afdacebee2c17dad0d348934c"
---
# Ingestion rules

The knowledge executor applies these rules in its plan phase and cites `rulesVersion: ingestion-rules.v1@c36ddd5cc0bc31406df785eb0333381a6ca07fd91181d2340a7733203cbdb687` in every plan and receipt. `basis: enforced` means the database already guarantees the rule (the executor only reports it early); `basis: curated` means only the executor checks it.

| Rule | Basis | Applies to | Action | Detail |
| --- | --- | --- | --- | --- |
| `alias.must_not_collide_canonical` | curated | proposal_kind=`entity.alias` | reject | The alias unique key is per entity, not global. The same alias string may exist on two entities. The executor rejects an alias that `api.resolve_entity` matches to a different active canonical entity at score ≥ 0.98, so agents do not silently attach a well-known name to the wrong id.  |
| `availability.transitions_are_ordered` | curated | proposal_kind=`fact.assert_state` stream_kind=`model_offering_availability` | hold | `temporal.stream_kind:model_offering_availability` admits statuses announced, preview, ga, deprecated, retired. The database does not order them. Hold a proposal that would move a current status backward along that sequence unless the evidence is an explicit correction with `temporal_basis=explicit` and a replacing interval. The same order applies to `temporal.stream_kind:product_feature_availability` (removed instead of retired).  |
| `entity.kind_in_vocabulary` | enforced | proposal_kind=`entity.create` | reject | `catalog.entity.kind` references `taxonomy.entity_kind(code)`. A `new` subject whose kind is not a vocabulary code is rejected before a batch opens (`VOCABULARY_VIOLATION`). Kind-specific attributes go into `catalog.entity.attributes` and are validated by trigger `catalog.validate_entity_attributes` against `taxonomy.entity_kind.attributes_schema` (for example `model_offering` requires `offering_key`, `ai_model_version` requires `version_label`). Numbers that change over time are fact streams, never attributes.  |
| `fact.world_time_required` | enforced | proposal_kind=`fact.assert_state` | reject | `temporal.segment.valid_during` is `not null` and `segment_valid_during_check` requires a non-empty `[)` range bounded below. Events use the same shape on `temporal.event_occurrence.occurred_during`. A proposal without `worldInterval.from` is rejected.  |
| `identifier.namespace_in_vocabulary` | enforced | proposal_kind=`entity.identifier` | reject | `entity_identifier_scheme_check` restricts `scheme` to the closed list (wikidata, ror, orcid, github, huggingface, npm, pypi, crates, go_module, doi, arxiv, openreview, mcp_registry, cve, ghsa, spdx, crunchbase, pitchbook, linkedin, x, youtube_channel, youtube_playlist, youtube_video, spotify, apple_podcasts, domain, sec_cik, lei, isin, other). `(scheme, value)` is unique per tenant.  |
| `price.currency_iso4217` | enforced | proposal_kind=`fact.assert_state` stream_kind=`offering_price` | reject | `temporal.commit_batch` requires `currency ~ '^[A-Z]{3}$'` for `offering_price`, `compute_offering_price`, and `valuation`. Amount and a unit from `unit_values` are also required (`requires_amount`).  |
| `price.scope_key_is_meter` | curated | proposal_kind=`fact.assert_state` stream_kind=`offering_price` | rewrite | Two `offering_price` facts on the same subject and world interval do not collide only when `scope_key` distinguishes them, so a **new** series with no `scopeKey` is rewritten to `meter\|tier\|region` from the payload (for example `input_tokens\|\|`); the exclusion constraint `segment_stream_id_valid_during_excl` would otherwise reject the second current segment. The database does not enforce any naming convention for `scope_key`: a series that already exists for the same subject, stream and meter keeps whatever `scope_key` it was created with. Read `q:facts.price_history` first; if a current segment with the same meter exists under another `scope_key`, name that key explicitly, or the stale segment stays current beside your new one. The payload `meter` is required by the `temporal.stream_kind:offering_price` payload schema.  |
| `proposal.idempotent_repeat` | enforced | proposal_kind=`fact.assert_state` | note | `temporal.assert_state` returns the existing segment id when an identical current segment exists. `temporal.knowledge_batch` is unique on `(tenant_id, idempotency_key)` (`knowledge_batch_tenant_id_idempotency_key_key`). A second submit of the same intent bytes returns `duplicate_of` without opening a new batch.  |
| `relationship.kinds_constrain_endpoints` | enforced | proposal_kind=`relationship.assert` | reject | Trigger `relationship_kinds` on `catalog.relationship` runs `catalog.check_relationship_kinds` and raises if the from/to entity kinds are not in `taxonomy.relationship_kind.from_kinds` / `to_kinds`. `version_of` additionally requires a matching pair (product_version/product, ai_model_version/ai_model, …); the parent kind is also recorded on `taxonomy.entity_kind.parent_kind`.  |
| `segment.do_not_close_without_later_world_time` | curated | proposal_kind=`fact.assert_state` | reject | Closing a current segment (`k_to` set) without asserting a successor that starts at or after the close instant leaves a world-time hole. `api.entity_timeline` will emit `unknown` gaps. Reject a close-only proposal that does not supply a later `worldInterval.from`. `temporal.close_segment` only stamps knowledge time; it does not invent a replacement fact.  |
| `stage.when_confidence_below_threshold` | curated | proposal_kind=`entity.create` | stage | If `api.resolve_entity` or an identifier lookup scores below the configured threshold (default 0.98 on identifier, lower on alias), rewrite entity.create to candidate.stage with reason `identity_ambiguous` unless the intent says `onMatch: use_existing`. `staging.candidate.proposed_kind` still must be a `taxonomy.entity_kind` (`candidate_proposed_kind_fkey`).  |
| `support.must_precede_claim_use` | curated | proposal_kind=`fact.assert_state` | hold | A fact may cite `primary_claim_id` only after the claim exists. The executor implies claim.materialize for cited claims not yet in `evidence.claim`, then admits support.admit through `temporal.admit_support`. `segment_support_claim_id_fkey` and `segment_primary_claim_id_fkey` enforce the FK once rows exist; the ordering is an executor rule so agents get a readable plan instead of a mid-batch FK failure.  |
| `unit.mapping_before_assertion` | curated | proposal_kind=`fact.assert_state` | hold | A fact read from a document unit (`content.document_node`) must name the `content.unit_assertion_mapping` that interprets the unit kind into a stream, relationship or event. Deterministic mappings on first-party structured units (`content.unit_kind:price_row` on a `content.document_type:pricing_page`) take the cheap path; other mappings carry a `risk_floor` and are held for Knowledge Services verification. The locator of the fact is the unit's position, so `api.fact_locators` can show the exact row later.  |
| `write.expected_head_required` | enforced | proposal_kind=`fact.assert_state` | reject | `temporal.begin_batch(p_expected_head)` locks `temporal.knowledge_head` and raises `rebase_required` (SQLSTATE 40001) when `p_expected_head` is not null and does not equal the current `knowledge_seq`. The ingestion executor always passes the snapshot head. A write without `expectedKnowledgeHead` is rejected at plan time so a stale snapshot cannot silently land.  |

`alias.must_not_collide_canonical` refs: `rel:catalog.entity_alias`, `rel:catalog.entity`, `fn:api.resolve_entity(text)`

`availability.transitions_are_ordered` refs: `voc:temporal.stream_kind.model_offering_availability`, `voc:temporal.stream_kind.product_feature_availability`, `rel:temporal.segment`

`entity.kind_in_vocabulary` refs: `rel:catalog.entity`, `rel:taxonomy.entity_kind`, `fn:catalog.validate_entity_attributes()`

`fact.world_time_required` refs: `rel:temporal.segment`, `rel:temporal.event_occurrence`, `fn:temporal.assert_state(uuid,text,tstzrange,text,text,numeric,text,text,uuid,jsonb,uuid,uuid,text,uuid,text)`

`identifier.namespace_in_vocabulary` refs: `rel:catalog.entity_identifier`

`price.currency_iso4217` refs: `voc:temporal.stream_kind.offering_price`, `fn:temporal.commit_batch(uuid,text,text,jsonb)`, `rel:temporal.segment`

`price.scope_key_is_meter` refs: `voc:temporal.stream_kind.offering_price`, `rel:temporal.segment`, `rel:temporal.stream`

`proposal.idempotent_repeat` refs: `fn:temporal.assert_state(uuid,text,tstzrange,text,text,numeric,text,text,uuid,jsonb,uuid,uuid,text,uuid,text)`, `rel:temporal.knowledge_batch`, `rel:orchestration.operation_intent`

`relationship.kinds_constrain_endpoints` refs: `rel:catalog.relationship`, `rel:taxonomy.relationship_kind`, `fn:temporal.assert_relationship(text,uuid,uuid,tstzrange,text,int4,jsonb,uuid,uuid)`

`segment.do_not_close_without_later_world_time` refs: `fn:temporal.close_segment(uuid)`, `rel:temporal.segment`, `q:entity.timeline`

`stage.when_confidence_below_threshold` refs: `rel:staging.candidate`, `fn:api.resolve_entity(text)`, `rel:taxonomy.entity_kind`

`support.must_precede_claim_use` refs: `rel:evidence.claim`, `rel:evidence.segment_support`, `fn:temporal.admit_support(uuid,uuid,uuid,uuid,text)`, `rel:temporal.segment`

`unit.mapping_before_assertion` refs: `rel:content.unit_assertion_mapping`, `rel:content.document_node`, `rel:content.unit_kind`, `rel:evidence.extraction_record`

`write.expected_head_required` refs: `fn:temporal.begin_batch(int8)`, `rel:temporal.knowledge_head`, `q:knowledge.head`
