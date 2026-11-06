---
id: "fn:content.check_document_work()"
kind: function
schema: content
name: check_document_work
domain: content
overloads: ["fn:content.check_document_work()"]
security: invoker
volatility: volatile
executors: []
raises: [document type/work entity mismatch, repository file tenant mismatch]
touches: { reads: [content.document_type, corpus.entity, corpus.repository_file], writes: [] }
tokens: [content, check_document_work, content.check_document_work]
defined_in: ["20260912010600_km_06_content.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# content.check_document_work

Domain `content`.

## check_document_work() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `document type/work entity mismatch`; `repository file tenant mismatch`.

Touches (best effort): reads [`content.document_type`](../../relations/content/document_type.md), [`corpus.entity`](../../relations/corpus/entity.md), [`corpus.repository_file`](../../relations/corpus/repository_file.md); writes —; calls —.

Defined in: `20260912010600_km_06_content.sql`.
