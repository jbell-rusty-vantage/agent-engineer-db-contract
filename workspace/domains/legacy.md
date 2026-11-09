---
id: "dom:legacy"
kind: domain
lens: machinery
schemas: [public]
aliases: [public, legacy]
relations: []
functions: [public.reject_immutable_row_change, public.set_updated_at]
tasks: []
summary: The public schema holds no tables since Build 08; two generic trigger functions remain.
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# Legacy (public schema)

The public schema holds no tables since Build 08; two generic trigger functions remain.

> curated (model_assisted, unreviewed) — Build 08 dropped the `public.research_*` and `public.factory_*` tables and the `research`,
> `provenance` and `research_private` schemas. What remains in `public` is two trigger
> helpers (`public.set_updated_at`, `public.reject_immutable_row_change`) used by older
> tables. Nothing here is a navigation target; it is listed so INDEX.md stays complete.

## Relations that matter

_None._

## Functions

[`public.reject_immutable_row_change`](../functions/public/reject_immutable_row_change.md), [`public.set_updated_at`](../functions/public/set_updated_at.md)

Schemas: [`public`](../schemas/public/README.md).
