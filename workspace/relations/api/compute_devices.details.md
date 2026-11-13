---
id: "rel:api.compute_devices#details"
kind: details
schema: api
name: compute_devices
of: "rel:api.compute_devices"
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# api.compute_devices — details

Spill-over from [the main page](compute_devices.md).

## Relationships

Outbound: none.
Inbound: none.

## Indexes

_None._

## Triggers

_None._

## Row-level security

Disabled.

## View definition

```sql
SELECT id AS device_id,
    display_name AS device,
    slug,
    attributes ->> 'vendor'::text AS vendor,
    attributes ->> 'device_class'::text AS device_class,
    (attributes ->> 'memory_gb'::text)::numeric AS memory_gb,
    (attributes ->> 'memory_bandwidth_tbps'::text)::numeric AS memory_bandwidth_tbps,
    (attributes ->> 'bf16_tflops'::text)::numeric AS bf16_tflops,
    (attributes ->> 'fp8_tflops'::text)::numeric AS fp8_tflops,
    (attributes ->> 'fp4_pflops'::text)::numeric AS fp4_pflops,
    (attributes ->> 'sparse_figures'::text)::boolean AS sparse_figures,
    (attributes ->> 'tdp_w'::text)::numeric AS tdp_w,
    attributes ->> 'interconnect'::text AS interconnect,
    attributes ->> 'form_factor'::text AS form_factor,
    attributes ->> 'released_on'::text AS released_on,
    attributes ->> 'spec_url'::text AS spec_url,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(d.id, 'manufactures'::text, 'incoming'::text) x(x))) AS manufacturers,
    ( SELECT count(*) AS count
           FROM catalog.relationship r
          WHERE r.to_entity_id = d.id AND r.kind = 'runs_on'::text AND r.k_to IS NULL) AS offering_count
   FROM catalog.entity d
  WHERE tenant_id = util.current_tenant_id() AND kind = 'compute_device'::text AND lifecycle = 'active'::text;
```
