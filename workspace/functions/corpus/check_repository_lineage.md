---
id: "fn:corpus.check_repository_lineage()"
kind: function
schema: corpus
name: check_repository_lineage
domain: identity
overloads: ["fn:corpus.check_repository_lineage()"]
security: invoker
volatility: volatile
executors: []
raises: [file module belongs to another repository, file revision belongs to another repository]
touches: { reads: [corpus.repository_module, corpus.repository_revision], writes: [] }
tokens: [corpus, check_repository_lineage, corpus.check_repository_lineage]
defined_in: ["20260912011100_km_11_grants_rls.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# corpus.check_repository_lineage

Domain `identity`.

## check_repository_lineage() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `file module belongs to another repository`; `file revision belongs to another repository`.

Touches (best effort): reads [`corpus.repository_module`](../../relations/corpus/repository_module.md), [`corpus.repository_revision`](../../relations/corpus/repository_revision.md); writes —; calls —.

Defined in: `20260912011100_km_11_grants_rls.sql`.
