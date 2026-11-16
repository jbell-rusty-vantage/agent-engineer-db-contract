---
id: "fn:taxonomy.enforce_facet_cardinality()"
kind: function
schema: taxonomy
name: enforce_facet_cardinality
domain: relationships
lens: machinery
overloads: ["fn:taxonomy.enforce_facet_cardinality()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [taxonomy.assignment, taxonomy.facet, taxonomy.facet_version, taxonomy.term], writes: [] }
tokens: [taxonomy, enforce_facet_cardinality, taxonomy.enforce_facet_cardinality]
defined_in: ["20260826001400_deferred_fks.sql", "20260829012824_case_study_entity_contract.sql", "20260829192855_optimize_ai_entity_taxonomy_and_relationships.sql", "20261105010200_product_curriculum_cutover.sql"]
workspace_fingerprint: "sha256:1632162dedd33f48177992e3e5ad79c363556a7b68ee650fc7e68b2bb3855da4"
---
# taxonomy.enforce_facet_cardinality

Domain `relationships`, lens `machinery`.

## enforce_facet_cardinality() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`taxonomy.assignment`](../../relations/taxonomy/assignment.md), [`taxonomy.facet`](../../relations/taxonomy/facet.md), [`taxonomy.facet_version`](../../relations/taxonomy/facet_version.md), [`taxonomy.term`](../../relations/taxonomy/term.md); writes —; calls —.

Defined in: `20260826001400_deferred_fks.sql`, `20260829012824_case_study_entity_contract.sql`, `20260829192855_optimize_ai_entity_taxonomy_and_relationships.sql`, `20261105010200_product_curriculum_cutover.sql`.
