---
id: "fn:content.guard_summary_content()"
kind: function
schema: content
name: guard_summary_content
domain: content
lens: machinery
overloads: ["fn:content.guard_summary_content()"]
security: invoker
volatility: volatile
executors: []
raises: [summary history cannot be deleted]
touches: { reads: [], writes: [] }
tokens: [content, guard_summary_content, content.guard_summary_content]
defined_in: ["20260912010600_km_06_content.sql"]
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# content.guard_summary_content

Domain `content`, lens `machinery`.

## guard_summary_content() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `summary history cannot be deleted`.

Defined in: `20260912010600_km_06_content.sql`.
