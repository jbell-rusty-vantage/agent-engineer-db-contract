---
id: "rel:api.compute_devices"
kind: view
schema: api
name: compute_devices
domain: api-surface
lens: corpus
aliases: []
tokens: [api, compute_devices, api.compute_devices, device_id, device, slug, vendor, device_class, memory_gb, memory_bandwidth_tbps, bf16_tflops, fp8_tflops, fp4_pflops, sparse_figures, tdp_w, interconnect, form_factor, released_on, spec_url, manufacturers, offering_count]
summary: "L1: accelerators and systems with first-party spec attributes (sparse figures flagged) and how many offerings run on them."
summary_basis: comment
rls: disabled
readers: [app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
writers: []
typescript: "Database[\"api\"][\"Views\"][\"compute_devices\"][\"Row\"]"
defined_in: ["20261109130000_build08_loop2_numbers_compute_apis.sql"]
workspace_fingerprint: "sha256:216c4ae7230478c8e60934da25c852e10680d6caed71a662962ea3c0ac1676d3"
---
# api.compute_devices

view in domain `api-surface`, lens `corpus` — L1: accelerators and systems with first-party spec attributes (sparse figures flagged) and how many offerings run on them..

## Columns

| # | Column | Type | Null | Default | Notes |
| ---: | --- | --- | --- | --- | --- |
| 1 | `device_id` | `uuid` | yes | — | — |
| 2 | `device` | `text` | yes | — | — |
| 3 | `slug` | `text` | yes | — | — |
| 4 | `vendor` | `text` | yes | — | — |
| 5 | `device_class` | `text` | yes | — | — |
| 6 | `memory_gb` | `numeric` | yes | — | — |
| 7 | `memory_bandwidth_tbps` | `numeric` | yes | — | — |
| 8 | `bf16_tflops` | `numeric` | yes | — | — |
| 9 | `fp8_tflops` | `numeric` | yes | — | — |
| 10 | `fp4_pflops` | `numeric` | yes | — | — |
| 11 | `sparse_figures` | `boolean` | yes | — | — |
| 12 | `tdp_w` | `numeric` | yes | — | — |
| 13 | `interconnect` | `text` | yes | — | — |
| 14 | `form_factor` | `text` | yes | — | — |
| 15 | `released_on` | `text` | yes | — | — |
| 16 | `spec_url` | `text` | yes | — | — |
| 17 | `manufacturers` | `text[]` | yes | — | — |
| 18 | `offering_count` | `bigint` | yes | — | — |

## Constraints

_None._

## Relationships

Outbound: none.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## Grants

`app_reader`: SELECT; `authenticated`: SELECT; `control_plane`: SELECT; `executor_service`: SELECT; `pipeline_agent`: SELECT; `service_role`: SELECT; `verifier_agent`: SELECT. None: `anon`.

## Read paths

- Direct SELECT: `app_reader`, `control_plane`, `executor_service`, `pipeline_agent`, `verifier_agent`.

## Write path

Views are not written.

## View definition

See [details](compute_devices.details.md).

## TypeScript

row: `Database["api"]["Views"]["compute_devices"]["Row"]`

Defined in: `20261109130000_build08_loop2_numbers_compute_apis.sql`.
