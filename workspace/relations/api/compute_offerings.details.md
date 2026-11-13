---
id: "rel:api.compute_offerings#details"
kind: details
schema: api
name: compute_offerings
of: "rel:api.compute_offerings"
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# api.compute_offerings — details

Spill-over from [the main page](compute_offerings.md).

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
SELECT o.id AS offering_id,
    o.display_name AS offering,
    o.slug,
    o.attributes ->> 'offering_class'::text AS offering_class,
    o.attributes ->> 'provider_slug'::text AS provider_slug,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(o.id, 'provides_compute'::text, 'incoming'::text) x(x))) AS providers,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(o.id, 'runs_on'::text, 'outgoing'::text) x(x))) AS devices,
    (o.attributes ->> 'gpu_count'::text)::integer AS gpu_count,
    (o.attributes ->> 'vcpu'::text)::numeric AS vcpu,
    (o.attributes ->> 'memory_gb'::text)::numeric AS memory_gb,
    o.attributes ->> 'pricing_url'::text AS pricing_url,
    p.meter,
    p.commitment,
    p.region,
    p.amount,
    p.currency,
    p.unit,
    p.per,
    p.usd_per_gpu_hour,
    p.valid_from,
    p.learned_k,
    p.claim_id
   FROM catalog.entity o
     LEFT JOIN LATERAL ( SELECT s.payload ->> 'meter'::text AS meter,
            COALESCE(s.payload ->> 'commitment'::text, 'unknown'::text) AS commitment,
            s.payload ->> 'region'::text AS region,
            s.amount,
            s.currency,
            s.unit,
            s.payload ->> 'per'::text AS per,
                CASE
                    WHEN s.unit = 'USD_per_GPU_hour'::text THEN s.amount
                    WHEN (s.unit = ANY (ARRAY['USD_per_node_hour'::text, 'USD_per_hour'::text])) AND COALESCE((s.payload ->> 'gpu_count'::text)::numeric, (o.attributes ->> 'gpu_count'::text)::numeric) > 0::numeric THEN s.amount / COALESCE((s.payload ->> 'gpu_count'::text)::numeric, (o.attributes ->> 'gpu_count'::text)::numeric)
                    WHEN s.unit = 'USD_per_chip_hour'::text THEN s.amount
                    ELSE NULL::numeric
                END AS usd_per_gpu_hour,
            lower(s.valid_during) AS valid_from,
            s.k_from AS learned_k,
            s.primary_claim_id AS claim_id
           FROM temporal.segment s
             JOIN temporal.stream st ON st.id = s.stream_id
          WHERE st.subject_entity_id = o.id AND st.kind = 'offering_price'::text AND s.k_to IS NULL AND (upper_inf(s.valid_during) OR upper(s.valid_during) > now())) p ON true
  WHERE o.tenant_id = util.current_tenant_id() AND o.kind = 'compute_offering'::text AND o.lifecycle = 'active'::text;
```
