---
id: "fn:product.finalize(uuid,text,uuid)"
kind: function
schema: product
name: finalize
domain: learning
lens: ours
overloads: ["fn:product.finalize(uuid,text,uuid)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [curriculum.requirement, curriculum.requirement_option, learning.attempt, learning.submission], writes: [learning.assessment_result, learning.credit] }
tokens: [product, finalize, product.finalize]
defined_in: ["20261105010300_product_api.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# product.finalize

Domain `learning`, lens `ours`.

## finalize(uuid, text, uuid) → void

function, volatile, security invoker, language plpgsql, config `search_path=""`.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `result_id` | `uuid` | — | — |
| `how` | `text` | — | — |
| `policy` | `uuid` | — | — |

Execute: no configured role.

Touches (best effort): reads [`curriculum.requirement`](../../relations/curriculum/requirement.md), [`curriculum.requirement_option`](../../relations/curriculum/requirement_option.md), [`learning.attempt`](../../relations/learning/attempt.md), [`learning.submission`](../../relations/learning/submission.md); writes [`learning.assessment_result`](../../relations/learning/assessment_result.md), [`learning.credit`](../../relations/learning/credit.md); calls —.

TypeScript: `Database["product"]["Functions"]["finalize"]`.

Defined in: `20261105010300_product_api.sql`.
