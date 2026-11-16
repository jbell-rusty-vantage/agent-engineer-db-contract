---
id: "rel:api.models#details"
kind: details
schema: api
name: models
of: "rel:api.models"
workspace_fingerprint: "sha256:ccec60ca7715c4edc1685d828a7324ce66fa6f9af95ad2a789d9a2fc6418dc0e"
---
# api.models — details

Spill-over from [the main page](models.md).

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
SELECT model_version_id,
    model,
    slug,
    version_label,
    provider_model_id,
    model_family_id,
    model_family,
    developer_id,
    developer,
    released_on,
    context_tokens,
    max_output_tokens,
    modalities,
    tool_use,
    structured_output,
    reasoning,
    vision,
    open_weights,
    knowledge_cutoff,
    availability,
    min_input_usd_per_1m,
    min_output_usd_per_1m,
    offering_count,
    observed_at,
    as_of_knowledge_seq
   FROM api.models_at(now()) models_at(model_version_id, model, slug, version_label, provider_model_id, model_family_id, model_family, developer_id, developer, released_on, context_tokens, max_output_tokens, modalities, tool_use, structured_output, reasoning, vision, open_weights, knowledge_cutoff, availability, min_input_usd_per_1m, min_output_usd_per_1m, offering_count, observed_at, as_of_knowledge_seq);
```
