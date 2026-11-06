---
id: "rel:evidence.claim_type"
kind: table
schema: evidence
name: claim_type
domain: evidence
aliases: []
tokens: [evidence, claim_type, evidence.claim_type, code, description, created_at]
summary: null
summary_basis: none
rls: enabled
readers: [executor_service, service_role, verifier_agent]
writers: [executor_service, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"claim_type\"][\"Row\"]"
defined_in: ["20260826000300_evidence_core.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# evidence.claim_type

table in domain `evidence`.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK |
| 2 | `description` | `text` | no | — | — |
| 3 | `created_at` | `timestamp with time zone` | no | `now()` | — |

## Constraints

- PK (code)

## Relationships

Outbound: none.
Inbound: [`evidence.claim`](claim.md).claim_type.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Enabled.
- `bounded_role_access` (ALL) for `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`: `false`

## Grants

`executor_service`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`, `control_plane`, `pipeline_agent`.

## Read paths

- Direct SELECT: `executor_service`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`.

## TypeScript

insert: `Database["evidence"]["Tables"]["claim_type"]["Insert"]`; row: `Database["evidence"]["Tables"]["claim_type"]["Row"]`; update: `Database["evidence"]["Tables"]["claim_type"]["Update"]`

Defined in: `20260826000300_evidence_core.sql`.
