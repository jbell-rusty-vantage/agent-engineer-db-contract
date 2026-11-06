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
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
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
