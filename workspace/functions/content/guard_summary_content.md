---
id: "fn:content.guard_summary_content()"
kind: function
schema: content
name: guard_summary_content
domain: content
overloads: ["fn:content.guard_summary_content()"]
security: invoker
volatility: volatile
executors: []
raises: [summary history cannot be deleted]
touches: { reads: [], writes: [] }
tokens: [content, guard_summary_content, content.guard_summary_content]
defined_in: ["20260912010600_km_06_content.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# content.guard_summary_content

Domain `content`.

## guard_summary_content() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `summary history cannot be deleted`.

Defined in: `20260912010600_km_06_content.sql`.
