---
id: "sch:access"
kind: schema
name: access
lens: ours
domains: [access]
relations: 7
functions: 0
workspace_fingerprint: "sha256:027ab2b6133d5d59318c478f06d832d89f937e563c387539f37fb3d7668818a8"
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
