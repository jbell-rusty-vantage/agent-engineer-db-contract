---
id: "dom:access"
kind: domain
lens: ours
schemas: [access]
aliases: [client grant, harness grant, guardian, consent, policy, credentials, restrictions]
relations: [access.account_profile, access.client_grant, access.guardian_link, access.policy_version, access.processing_authorization, access.provided_credential, access.source_restriction]
functions: [product.actor, product.client_grant, product.processing_allowed, product.require_role, product.restricted, product.role_in]
tasks: [search-my-notes]
summary: "Who may act (lens ours): account profiles, MCP/CLI client grants, guardian consent, processing authorizations, policy versions, source restrictions."
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:fbf5703bf7a6f6131c452444ee949f1feec1bbe813c78d772fb3886b510815b9"
---
# Access (accounts, grants, policies, consent)

Who may act (lens ours): account profiles, MCP/CLI client grants, guardian consent, processing authorizations, policy versions, source restrictions.

> curated (model_assisted, unreviewed) — `access.account_profile` (`set_account_profile`) holds age band and preferences;
> `access.guardian_link` (`invite_guardian`, `consent_guardian`) and
> `access.processing_authorization` (`authorize_processing`) record consent, checked by
> `product.processing_allowed`. `access.client_grant` (`create_client_grant`,
> `revoke_client_grant`) lets an MCP server or CLI act for a principal within a scope
> (author, learn, library, assess, read); `product.client_grant` resolves the caller and
> decides whether the actor is human (web or interactive CLI) or an agent.
> `access.policy_version` (`add_policy_version`) is the workspace grading/finalization policy
> read by `product.policy`; `access.provided_credential` (`issue_provided_credential`) and
> `access.source_restriction` (`restrict_source`) are worker-managed.
> 
> Agents reach these only through operations; there are no reader views. Trap: a client
> grant can never mint grants (`FORBIDDEN`), and agent-kind actors cannot record human
> reviews or finalize results that the policy reserves for humans.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`access.account_profile`](../relations/access/account_profile.md) | table | PK (tenant_id, principal_id, seq); RLS | helpers only |
| [`access.client_grant`](../relations/access/client_grant.md) | table | PK (id); unique (tenant_id, id), (token_sha256); RLS | helpers only |
| [`access.guardian_link`](../relations/access/guardian_link.md) | table | PK (id); unique (tenant_id, id); RLS | helpers only |
| [`access.policy_version`](../relations/access/policy_version.md) | table | PK (id); unique (tenant_id, id), (tenant_id, version); RLS | helpers only |
| [`access.processing_authorization`](../relations/access/processing_authorization.md) | table | PK (id); unique (tenant_id, id); RLS | helpers only |
| [`access.provided_credential`](../relations/access/provided_credential.md) | table | PK (id); unique (tenant_id, id); RLS | helpers only |
| [`access.source_restriction`](../relations/access/source_restriction.md) | table | PK (id); unique (tenant_id, id); RLS | helpers only |

## Functions

[`product.actor`](../functions/product/actor.md), [`product.client_grant`](../functions/product/client_grant.md), [`product.processing_allowed`](../functions/product/processing_allowed.md), [`product.require_role`](../functions/product/require_role.md), [`product.restricted`](../functions/product/restricted.md), [`product.role_in`](../functions/product/role_in.md)

## Tasks

[`search-my-notes`](../tasks/search-my-notes.md)

Schemas: [`access`](../schemas/access/README.md).
