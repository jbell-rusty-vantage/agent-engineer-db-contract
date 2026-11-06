---
id: "fn:curriculum.lesson_version_guard()"
kind: function
schema: curriculum
name: lesson_version_guard
domain: curriculum
overloads: ["fn:curriculum.lesson_version_guard()"]
security: invoker
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: [published lesson versions cannot be deleted]
touches: { reads: [], writes: [] }
tokens: [curriculum, lesson_version_guard, curriculum.lesson_version_guard]
defined_in: ["20260826001300_curriculum.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# curriculum.lesson_version_guard

Domain `curriculum`.

## lesson_version_guard() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Raises (mechanically extracted): `published lesson versions cannot be deleted`.

Defined in: `20260826001300_curriculum.sql`.
