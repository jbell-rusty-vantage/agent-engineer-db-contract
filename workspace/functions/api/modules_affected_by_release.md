---
id: "fn:api.modules_affected_by_release(uuid)"
kind: function
schema: api
name: modules_affected_by_release
domain: api-surface
lens: corpus
overloads: ["fn:api.modules_affected_by_release(uuid)"]
security: definer
volatility: stable
executors: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [api.software_releases, authoring.revision_binding, authoring.runtime_requirement, authoring.work, authoring.work_revision], writes: [] }
tokens: [api, modules_affected_by_release, api.modules_affected_by_release]
defined_in: ["20261108120000_build08_r2_knowledge_continuum.sql", "20261116120000_build08_api_default_closed.sql", part4_views_seeds.sql]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# api.modules_affected_by_release

Domain `api-surface`, lens `corpus`.

## modules_affected_by_release(uuid) → TABLE(work_id uuid, work_kind text, work_slug text, revision_id uuid, revision_title text, revision_created_at timestamp with time zone, software text, release text, released_at timestamp with time zone, breaking boolean, binding text, version_spec text)

function, stable, security definer, language sql, config `search_path=""`. L2 flywheel: our head revisions (modules, activities, courses) that bind or require the software a release belongs to and were authored before that release; breaking tells which need review first. A signed-in user sees the head revisions they may read (api.works_authored has the rule); database roles see all.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_release` | `uuid` | — | — |

Execute: `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`api.software_releases`](../../relations/api/software_releases.md), [`authoring.revision_binding`](../../relations/authoring/revision_binding.md), [`authoring.runtime_requirement`](../../relations/authoring/runtime_requirement.md), [`authoring.work`](../../relations/authoring/work.md), [`authoring.work_revision`](../../relations/authoring/work_revision.md); writes —; calls [`product.session_reads_revision`](../product/session_reads_revision.md).

Named queries: `q:ours.modules_affected_by_release`.

TypeScript: `Database["api"]["Functions"]["modules_affected_by_release"]`.

Defined in: `20261108120000_build08_r2_knowledge_continuum.sql`, `20261116120000_build08_api_default_closed.sql`, `part4_views_seeds.sql`.
