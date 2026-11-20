---
id: "rel:api.papers#details"
kind: details
schema: api
name: papers
of: "rel:api.papers"
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# api.papers — details

Spill-over from [the main page](papers.md).

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
WITH doc AS (
         SELECT a.entity_id,
            d.id AS document_id,
            d.attributes,
            d.document_type_code,
            row_number() OVER (PARTITION BY a.entity_id ORDER BY d.created_at DESC) AS rn
           FROM content.document_about_entity a
             JOIN content.document d ON d.id = a.document_id
          WHERE a.role = 'primary'::text AND (d.document_type_code = ANY (ARRAY['arxiv_paper'::text, 'conference_paper'::text, 'journal_article'::text, 'tech_report'::text, 'model_card'::text, 'system_card'::text, 'dataset_card'::text, 'research_report'::text]))
        )
 SELECT w.id AS paper_id,
    w.title,
    w.attributes ->> 'arxiv_id'::text AS arxiv_id,
    w.attributes ->> 'doi'::text AS doi,
    w.published_at,
    w.canonical_url,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(w.id, 'authored_by'::text, 'outgoing'::text) x(x))) AS authors,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(w.id, 'published_by'::text, 'outgoing'::text) x(x))) AS publishers,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(w.id, 'has_code'::text, 'outgoing'::text) x(x))) AS repositories,
    api.names(( SELECT array_agg(x.x) AS array_agg
           FROM api.related(w.id, 'introduces_technique'::text, 'outgoing'::text) x(x))) AS techniques,
    ( SELECT count(*) AS count
           FROM catalog.relationship r
             JOIN catalog.entity t ON t.id = r.from_entity_id
          WHERE r.to_entity_id = w.id AND (r.kind = ANY (ARRAY['about'::text, 'cites'::text])) AND t.kind = 'talk'::text AND r.k_to IS NULL) AS talks_about,
    ( SELECT count(*) AS count
           FROM catalog.relationship r
          WHERE r.to_entity_id = w.id AND r.kind = 'cites'::text AND r.k_to IS NULL) AS cited_by_count,
    ( SELECT count(*) AS count
           FROM catalog.relationship r
          WHERE r.from_entity_id = w.id AND r.kind = 'cites'::text AND r.k_to IS NULL) AS cites_count,
    api.fact_amount(w.id, 'paper_citations'::text) AS citations,
    w.abstract,
    COALESCE(doc.attributes ->> 'ingestion_level'::text, w.attributes ->> 'ingestion_level'::text, 'P0'::text) AS ingestion_level,
    COALESCE(doc.attributes -> 'promotion'::text, w.attributes -> 'promotion'::text) AS promotion,
    doc.document_id,
    doc.document_type_code,
    w.attributes ->> 'publication_form'::text AS publication_form
   FROM catalog.work w
     JOIN catalog.entity e ON e.id = w.id
     LEFT JOIN doc ON doc.entity_id = w.id AND doc.rn = 1
  WHERE w.tenant_id = util.current_tenant_id() AND w.kind = 'paper'::text AND e.lifecycle = 'active'::text;
```
