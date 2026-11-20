---
id: "sch:access"
kind: schema
name: access
lens: ours
domains: [access]
relations: 7
functions: 0
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# access

Lens `ours`. Domains: [`access`](../../domains/access.md).

| Relation | Kind | Rows | Summary | Key edges |
| --- | --- | --- | --- | --- |
| [`account_profile`](../../relations/access/account_profile.md) | table | unknown | — | → `auth.users`, → `access.policy_version` |
| [`client_grant`](../../relations/access/client_grant.md) | table | small | — | → `auth.users` |
| [`guardian_link`](../../relations/access/guardian_link.md) | table | unknown | — | → `auth.users`, → `orchestration.artifact` |
| [`policy_version`](../../relations/access/policy_version.md) | table | unknown | — | → `auth.users` |
| [`processing_authorization`](../../relations/access/processing_authorization.md) | table | unknown | — | → `auth.users`, → `access.guardian_link`, → `access.policy_version` |
| [`provided_credential`](../../relations/access/provided_credential.md) | table | unknown | — | → `auth.users` |
| [`source_restriction`](../../relations/access/source_restriction.md) | table | unknown | — | → `auth.users`, → `orchestration.artifact`, → `evidence.source_capture` |

Functions: none.

Types: none.
