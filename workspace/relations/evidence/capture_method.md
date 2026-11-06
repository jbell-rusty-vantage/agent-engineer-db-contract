---
id: "rel:evidence.capture_method"
kind: table
schema: evidence
name: capture_method
domain: evidence
aliases: [capture method]
tokens: [evidence, capture_method, evidence.capture_method, code, description]
summary: Vocabulary of how a source_capture was taken.
summary_basis: curated
rls: disabled
readers: [control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: [executor_service, pipeline_agent, service_role]
typescript: "Database[\"evidence\"][\"Tables\"][\"capture_method\"][\"Row\"]"
defined_in: ["20260912010100_km_01_vocabularies.sql"]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# evidence.capture_method

table in domain `evidence`.

> curated (model_assisted, unreviewed) — Vocabulary of how a source_capture was taken.

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `code` | `text` | no | — | PK; _curated:_ Stable method code referenced by evidence.source_capture.capture_method. |
| 2 | `description` | `text` | no | — | — |

## Constraints

- PK (code)

## Relationships

Outbound: none.
Inbound: [`evidence.source_capture`](source_capture.md).capture_method.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`control_plane`: SELECT; `executor_service`: INSERT, SELECT, UPDATE; `pipeline_agent`: INSERT, SELECT, UPDATE; `service_role`: INSERT, SELECT, UPDATE; `verifier_agent`: SELECT. None: `anon`, `app_reader`, `authenticated`.

## Read paths

- Direct SELECT: `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

- Direct DML: `executor_service`, `pipeline_agent`.

## TypeScript

insert: `Database["evidence"]["Tables"]["capture_method"]["Insert"]`; row: `Database["evidence"]["Tables"]["capture_method"]["Row"]`; update: `Database["evidence"]["Tables"]["capture_method"]["Update"]`

## Examples

Captures for one source

```bash
knowledge db query evidence.captures_for_source --param source_id=0192e000-0000-7000-8000-000000000001
```
capture_method on each row is a code from this table.

Defined in: `20260912010100_km_01_vocabularies.sql`.
