---
id: "rel:api.model_offerings#details"
kind: details
schema: api
name: model_offerings
of: "rel:api.model_offerings"
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
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
