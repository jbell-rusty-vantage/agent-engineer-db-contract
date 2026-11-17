---
id: "fn:api.modules_using_software(uuid)"
kind: function
schema: api
name: modules_using_software
domain: api-surface
lens: corpus
overloads: ["fn:api.modules_using_software(uuid)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [api.software_releases, authoring.revision_binding, authoring.runtime_requirement, authoring.work, authoring.work_revision, catalog.entity], writes: [] }
tokens: [api, modules_using_software, api.modules_using_software]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", "20261108120300_build08_r2_fixups3.sql", "20261116120000_build08_api_default_closed.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# api.modules_using_software

Domain `api-surface`, lens `corpus`.

## modules_using_software(uuid) → TABLE(work_id uuid, work_kind text, work_slug text, revision_id uuid, revision_title text, revision_created_at timestamp with time zone, binding text, version_spec text, software text, latest_release text, latest_release_at timestamp with time zone, latest_release_breaking boolean, releases_since_revision bigint)

function, stable, security definer, language sql, config `search_path=""`. L2 flywheel (time-independent): our head revisions that bind or require a software thing, with its latest known release and how many releases landed after the revision was authored. A signed-in user sees the head revisions they may read (api.works_authored has the rule); database roles see all.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_software` | `uuid` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`api.software_releases`](../../relations/api/software_releases.md), [`authoring.revision_binding`](../../relations/authoring/revision_binding.md), [`authoring.runtime_requirement`](../../relations/authoring/runtime_requirement.md), [`authoring.work`](../../relations/authoring/work.md), [`authoring.work_revision`](../../relations/authoring/work_revision.md), [`catalog.entity`](../../relations/catalog/entity.md); writes —; calls [`product.session_reads_revision`](../product/session_reads_revision.md).

TypeScript: `Database["api"]["Functions"]["modules_using_software"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `20261108120300_build08_r2_fixups3.sql`, `20261116120000_build08_api_default_closed.sql`.
