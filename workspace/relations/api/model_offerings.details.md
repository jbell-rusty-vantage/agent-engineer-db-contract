---
id: "rel:api.model_offerings#details"
kind: details
schema: api
name: model_offerings
of: "rel:api.model_offerings"
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# api.model_offerings — details

Spill-over from [the main page](model_offerings.md).

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
SELECT offering_id,
    offering,
    offering_key,
    model_version_id,
    model,
    provider_id,
    provider,
    region,
    tier,
    input_usd_per_1m,
    output_usd_per_1m,
    cached_input_usd_per_1m,
    batch_input_usd_per_1m,
    availability,
    pricing_url,
    price_valid_from,
    price_observed_at,
    price_claim_id,
    price_locator_id,
    as_of_knowledge_seq
   FROM api.model_offerings_at(now()) model_offerings_at(offering_id, offering, offering_key, model_version_id, model, provider_id, provider, region, tier, input_usd_per_1m, output_usd_per_1m, cached_input_usd_per_1m, batch_input_usd_per_1m, availability, pricing_url, price_valid_from, price_observed_at, price_claim_id, price_locator_id, as_of_knowledge_seq);
```
