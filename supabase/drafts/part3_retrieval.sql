-- Build 08 R2 draft. Part 3: one retrieval stack (lens + source tier + facets), both space layouts, RLS-isolated learner notes, product API on the same stack.

-- ---------------------------------------------------------------------------------------------- 14. projection targets: units, digests, own revisions, private passages
alter table retrieval.projection_target drop constraint projection_target_tenant_id_target_kind_entity_id_record_id_key;
alter table retrieval.projection_target drop constraint projection_target_check;
alter table retrieval.projection_target drop constraint projection_target_check1;
alter table retrieval.projection_target drop constraint projection_target_target_kind_check;
alter table retrieval.projection_target
  add column document_node_id uuid,
  add column digest_id uuid references content.document_digest(id),
  add column authored_revision_id uuid references authoring.work_revision(id),
  add column passage_id uuid;
alter table retrieval.projection_target add constraint projection_target_node_fk foreign key (tenant_id, document_node_id) references content.document_node(tenant_id, id) deferrable initially deferred;
comment on column retrieval.projection_target.passage_id is 'library.passage of a private/own passage; soft reference (passages are re-indexed by deletion) so the retired vector item keeps its target row.';
comment on column retrieval.projection_target.record_id is 'guidance.item (expert knowledge item) when target_kind = record.';
alter table retrieval.projection_target add constraint projection_target_target_kind_check check (target_kind in ('entity','record','chunk','claim','summary','unit','digest','authored','passage'));
alter table retrieval.projection_target add constraint projection_target_exactly_one check (num_nonnulls(entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id) = 1);
alter table retrieval.projection_target add constraint projection_target_kind_matches check (
  (target_kind = 'entity' and entity_id is not null) or (target_kind = 'record' and record_id is not null) or (target_kind = 'chunk' and chunk_id is not null)
  or (target_kind = 'claim' and claim_id is not null) or (target_kind = 'summary' and summary_id is not null) or (target_kind = 'unit' and document_node_id is not null)
  or (target_kind = 'digest' and digest_id is not null) or (target_kind = 'authored' and authored_revision_id is not null) or (target_kind = 'passage' and passage_id is not null));
alter table retrieval.projection_target add constraint projection_target_one_row_per_target unique nulls not distinct (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id);
comment on table retrieval.projection_target is 'What a search projection is about: an entity card, a guidance item, a chunk, a claim, a summary, a typed unit, a digest, one of our authored revisions or a private passage. Exactly one target per row.';

-- ---------------------------------------------------------------------------------------------- 15. vector items carry lens, source tier and the facets questions filter on
alter table retrieval.vector_item
  add column lens text not null default 'corpus' check (lens in ('corpus','ours','private','evidence')),
  add column source_tier smallint check (source_tier between 0 and 4),
  add column workspace_id uuid,
  add column unit_kind text,
  add column document_id uuid,
  add column document_version_id uuid,
  add column source_role_code text references content.source_role(code),
  add column observed_at timestamptz,
  add column search_tsv_en tsvector generated always as (to_tsvector('english', coalesce(search_text, ''))) stored;
alter table retrieval.vector_item drop constraint vector_item_content_kind_check;
alter table retrieval.vector_item add constraint vector_item_content_kind_check check (content_kind in ('chunk','summary','claim','record','profile','timeline','measurement','unit','digest','passage','authored','guidance'));
alter table retrieval.vector_item add constraint vector_item_private_has_workspace check (lens <> 'private' or workspace_id is not null);
create index vector_item_lens_tier_idx on retrieval.vector_item (tenant_id, lens, source_tier) where lifecycle = 'active';
create index vector_item_tsv_en_idx on retrieval.vector_item using gin (search_tsv_en);
create index vector_item_workspace_idx on retrieval.vector_item (tenant_id, workspace_id) where lens = 'private' and lifecycle = 'active';
create index vector_item_document_idx on retrieval.vector_item (tenant_id, document_id) where lifecycle = 'active';
comment on column retrieval.vector_item.lens is 'Whose knowledge: corpus (ingested sources), ours (our courses/guides/reports), private (one workspace''s notes, RLS-isolated), evidence (assertions/claims).';
comment on column retrieval.vector_item.source_tier is 'T0 verified assertions, T1 our content, T2 primary corpus, T3 third-party corpus, T4 live web; a filter and a boost, never a truth claim.';
comment on table retrieval.vector_item is 'One searchable item in one vector space version: the text, its lens/tier/facets (document kind, unit kind, entity, time, assurance) and lifecycle. Embeddings live in vector_item_embedding_1536 partitions.';

-- the knowledge roles never see private items; the product owner sees only private and own items
drop policy bounded_role_access on retrieval.vector_item;
create policy bounded_role_access on retrieval.vector_item for all to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader
  using (tenant_id = util.current_tenant_id() and lens <> 'private') with check (tenant_id = util.current_tenant_id() and lens <> 'private');
create policy product_private_access on retrieval.vector_item for all to product_api_owner using (lens in ('private','ours')) with check (lens in ('private','ours'));
drop policy bounded_role_access on retrieval.vector_item_embedding_1536;
create policy bounded_role_access on retrieval.vector_item_embedding_1536 for all to executor_service, pipeline_agent, verifier_agent, control_plane, app_reader
  using (tenant_id = util.current_tenant_id() and exists (select 1 from retrieval.vector_item v where v.id = vector_item_id and v.lens <> 'private'))
  with check (tenant_id = util.current_tenant_id() and exists (select 1 from retrieval.vector_item v where v.id = vector_item_id and v.lens <> 'private'));
create policy product_private_access on retrieval.vector_item_embedding_1536 for all to product_api_owner
  using (exists (select 1 from retrieval.vector_item v where v.id = vector_item_id and v.lens in ('private','ours')))
  with check (exists (select 1 from retrieval.vector_item v where v.id = vector_item_id and v.lens in ('private','ours')));
create policy product_private_access on retrieval.projection_target for all to product_api_owner using (true) with check (target_kind in ('passage','authored'));
create policy product_private_access on retrieval.search_projection for all to product_api_owner using (true) with check (visibility in ('private','workspace','tenant'));
grant select, insert, update on retrieval.vector_item, retrieval.vector_item_embedding_1536, retrieval.projection_target, retrieval.search_projection to product_api_owner;
grant select on retrieval.vector_space, retrieval.vector_space_version, retrieval.projection_procedure to product_api_owner, app_reader, pipeline_agent, verifier_agent, control_plane;
grant select on retrieval.vector_item, retrieval.vector_item_embedding_1536 to app_reader, pipeline_agent, verifier_agent, control_plane;

-- append-only items may be retired (re-indexing) without a successor; any other change still needs a first successor assignment
create or replace function retrieval.vector_item_guard() returns trigger language plpgsql set search_path = '' as $$
declare successor_created timestamptz; begin
 if tg_op='DELETE' then raise exception 'retrieval.vector_item is append-only' using errcode='restrict_violation'; end if;
 -- generated columns (search_tsv, search_tsv_en) are not computed yet in a BEFORE trigger, so they are excluded from the comparison
 if (to_jsonb(new)-'{lifecycle,search_tsv,search_tsv_en}'::text[]) = (to_jsonb(old)-'{lifecycle,search_tsv,search_tsv_en}'::text[]) and old.lifecycle='active' and new.lifecycle in ('retired','superseded') then return new; end if;
 if (to_jsonb(new)-'{superseded_by_id,search_tsv,search_tsv_en}'::text[]) is distinct from (to_jsonb(old)-'{superseded_by_id,search_tsv,search_tsv_en}'::text[])
    or old.superseded_by_id is not null or new.superseded_by_id is null or new.superseded_by_id=new.id then
  raise exception 'vector item is immutable; only a first successor assignment or retirement is allowed' using errcode='restrict_violation';
 end if;
 select created_at into successor_created from retrieval.vector_item where tenant_id=old.tenant_id and id=new.superseded_by_id;
 if successor_created is null or successor_created<=old.created_at then raise exception 'vector successor must be newer and same-tenant' using errcode='check_violation'; end if;
 return new;
end $$;

-- ---------------------------------------------------------------------------------------------- 16. spaces: layout A (kind spaces) and layout B (one topical space), 1536 halfvec partitions
insert into retrieval.projection_procedure(slug, version, description, template, projection_policy) values
  ('build08-text', 1, 'Build 08: the unit/digest/card/assertion/passage text itself (optionally with a short contextual prefix) is the embedding text', '{prefix}{text}', '{"layout_experiment":"A_vs_B"}')
on conflict (slug, version) do nothing;
insert into retrieval.vector_space(tenant_id, slug, purpose, class) values
  (util.default_tenant_id(), 'units', 'Layout A: text-bearing typed units (sections, rows, segments, slides, code examples)', 'exploratory'),
  (util.default_tenant_id(), 'digests', 'Layout A: digest items (key points, changes, open questions)', 'exploratory'),
  (util.default_tenant_id(), 'entity_cards', 'Layout A: one profile card per entity/concept (never a number)', 'exploratory'),
  (util.default_tenant_id(), 'assertions', 'Layout A: claim statements with qualifiers (evidence lens)', 'exploratory'),
  (util.default_tenant_id(), 'own_content', 'Layout A: our courses, guides and reports (ours lens, tier 1)', 'exploratory'),
  (util.default_tenant_id(), 'learner_notes', 'Layout A: private notes and uploads, RLS-isolated per workspace (private lens)', 'exploratory'),
  (util.default_tenant_id(), 'knowledge_text', 'Layout B: every corpus/ours text item in one topical space, facets do the scoping', 'exploratory')
on conflict (tenant_id, slug) do nothing;
insert into retrieval.vector_space_version(tenant_id, vector_space_id, version, embedding_model, dims, backend, precision, distance_operator, normalization, index_configuration, provider_routing_policy, publication_lifecycle)
select util.default_tenant_id(), s.id, 1, 'openai/text-embedding-3-small', 1536, 'pgvector', 'halfvec', 'cosine', 'l2', '{"hnsw":{"m":16,"ef_construction":64}}', '{"provider":"openai","role":"OPENAI_EMBEDDING_API_KEY"}', 'draft'
from retrieval.vector_space s where s.slug in ('units','digests','entity_cards','assertions','own_content','learner_notes','knowledge_text')
  and not exists (select 1 from retrieval.vector_space_version v where v.vector_space_id = s.id);
do $$
declare s text;
begin
  foreach s in array array['units','digests','entity_cards','assertions','own_content','learner_notes','knowledge_text'] loop
    execute format('create table if not exists retrieval.vector_item_embedding_1536_%I partition of retrieval.vector_item_embedding_1536 for values in (%L)', s, s);
    execute format('create index if not exists embedding_%s_hnsw on retrieval.vector_item_embedding_1536_%I using hnsw (embedding extensions.halfvec_cosine_ops)', s, s);
  end loop;
end $$;

-- ---------------------------------------------------------------------------------------------- 17. one way in: index a text item; one way to store its embedding
create or replace function retrieval.index_text_item(
  p_space_slug text, p_target_kind text, p_target_id uuid, p_text text, p_lens text, p_source_tier smallint, p_content_kind text,
  p_entity_id uuid default null, p_secondary_entity_ids uuid[] default '{}', p_document_type_code text default null, p_unit_kind text default null,
  p_document_id uuid default null, p_document_version_id uuid default null, p_source_role_code text default null, p_valid_during tstzrange default null,
  p_knowledge_seq bigint default null, p_workspace_id uuid default null, p_language text default 'en', p_observed_at timestamptz default null,
  p_start_ms integer default null, p_end_ms integer default null, p_contextual_prefix text default '', p_assurance_rank smallint default null)
returns uuid language plpgsql security definer set search_path = '' as $$
declare t uuid := util.default_tenant_id(); vsv uuid; target uuid; proj uuid; item uuid; proc uuid; sha text := encode(sha256(convert_to(p_text,'UTF8')),'hex'); esha text := encode(sha256(convert_to(p_contextual_prefix||p_text,'UTF8')),'hex'); psha text := encode(sha256(convert_to(coalesce(p_contextual_prefix,''),'UTF8')),'hex');
begin
  if p_text is null or btrim(p_text) = '' then raise exception 'empty text cannot be indexed' using errcode='invalid_parameter_value'; end if;
  if p_lens = 'private' and p_workspace_id is null then raise exception 'private items need a workspace' using errcode='invalid_parameter_value'; end if;
  select v.id into vsv from retrieval.vector_space_version v join retrieval.vector_space s on s.id = v.vector_space_id where s.tenant_id = t and s.slug = p_space_slug order by v.version desc limit 1;
  if vsv is null then raise exception 'unknown vector space %', p_space_slug; end if;
  select id into proc from retrieval.projection_procedure where slug = 'build08-text' and version = 1;
  insert into retrieval.projection_target(tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id)
  values (t, p_target_kind,
    case when p_target_kind='entity' then p_target_id end, case when p_target_kind='record' then p_target_id end, case when p_target_kind='chunk' then p_target_id end,
    case when p_target_kind='claim' then p_target_id end, case when p_target_kind='summary' then p_target_id end, case when p_target_kind='unit' then p_target_id end,
    case when p_target_kind='digest' then p_target_id end, case when p_target_kind='authored' then p_target_id end, case when p_target_kind='passage' then p_target_id end)
  on conflict (tenant_id, target_kind, entity_id, record_id, chunk_id, claim_id, summary_id, document_node_id, digest_id, authored_revision_id, passage_id) do update set retired_at = null
  returning id into target;
  select id into proj from retrieval.search_projection where tenant_id = t and projection_target_id = target and projection_procedure_id = proc and purpose = 'build08_text' and embedding_text_sha256 = esha;
  if proj is null then
    insert into retrieval.search_projection(tenant_id, projection_target_id, projection_procedure_id, purpose, source_text, contextual_prefix, embedding_text, source_text_sha256, contextual_prefix_sha256, embedding_text_sha256, language, content_kind, visibility, classification, promotion_state, generator_identity)
    values (t, target, proc, 'build08_text', p_text, coalesce(p_contextual_prefix,''), p_contextual_prefix||p_text, sha, psha, esha, p_language, p_content_kind,
            case p_lens when 'private' then 'private' when 'ours' then 'tenant' else 'public' end, case p_lens when 'private' then 'private' else 'public' end, 'candidate', 'build08-text/1')
    returning id into proj;
  end if;
  select id into item from retrieval.vector_item where tenant_id = t and space_version_id = vsv and search_projection_id = proj and lifecycle = 'active';
  if item is not null then return item; end if;
  insert into retrieval.vector_item(tenant_id, space_version_id, content_sha256, chunk_index, verification_state, lifecycle, search_projection_id, projection_target_id, language, visibility, classification,
    authority_level, freshness_at, search_text, entity_id, entity_kind, secondary_entity_ids, document_type_code, content_kind, valid_during, knowledge_seq, assurance_rank, start_ms, end_ms,
    lens, source_tier, workspace_id, unit_kind, document_id, document_version_id, source_role_code, observed_at)
  values (t, vsv, sha, 0, 'pending', 'active', proj, target, p_language, case p_lens when 'private' then 'private' when 'ours' then 'tenant' else 'public' end, case p_lens when 'private' then 'private' else 'public' end,
    p_source_role_code, coalesce(p_observed_at, now()), p_contextual_prefix||p_text, p_entity_id, (select kind from catalog.entity where id = p_entity_id), coalesce(p_secondary_entity_ids,'{}'), p_document_type_code, p_content_kind, p_valid_during, p_knowledge_seq, p_assurance_rank, p_start_ms, p_end_ms,
    p_lens, p_source_tier, p_workspace_id, p_unit_kind, p_document_id, p_document_version_id, p_source_role_code, p_observed_at)
  returning id into item;
  return item;
end $$;
comment on function retrieval.index_text_item is 'The one way a text becomes searchable: upserts the projection target, the search projection and an active vector item in the named space with lens/tier/facets. Idempotent on identical text.';
create or replace function retrieval.store_embedding(p_vector_item uuid, p_embedding extensions.halfvec, p_embedding_sha256 text)
returns void language plpgsql security definer set search_path = '' as $$
declare t uuid; vsv uuid; key text;
begin
  select vi.tenant_id, vi.space_version_id, s.slug into t, vsv, key from retrieval.vector_item vi join retrieval.vector_space_version v on v.id = vi.space_version_id join retrieval.vector_space s on s.id = v.vector_space_id where vi.id = p_vector_item;
  if key is null then raise exception 'unknown vector item %', p_vector_item; end if;
  insert into retrieval.vector_item_embedding_1536(tenant_id, vector_space_key, vector_space_version_id, vector_item_id, embedding, embedding_sha256)
  values (t, key, vsv, p_vector_item, p_embedding, p_embedding_sha256)
  on conflict (vector_space_key, vector_item_id) do nothing;
end $$;
create or replace function retrieval.retire_items_for_passages(p_passage_ids uuid[]) returns integer language plpgsql security definer set search_path = '' as $$
declare n integer;
begin
  update retrieval.vector_item vi set lifecycle = 'retired' from retrieval.projection_target pt where pt.id = vi.projection_target_id and pt.passage_id = any(p_passage_ids) and vi.lifecycle = 'active';
  get diagnostics n = row_count; return n;
end $$;
grant execute on function retrieval.index_text_item(text,text,uuid,text,text,smallint,text,uuid,uuid[],text,text,uuid,uuid,text,tstzrange,bigint,uuid,text,timestamptz,integer,integer,text,smallint) to executor_service, product_api_owner;
grant execute on function retrieval.store_embedding(uuid, extensions.halfvec, text) to executor_service, product_api_owner;
grant execute on function retrieval.retire_items_for_passages(uuid[]) to product_api_owner;

-- ---------------------------------------------------------------------------------------------- 18. the one search: scope first (facets), then lexical + trigram + ANN fused with RRF
create or replace function api.search_unified(
  p_query text, p_query_embedding extensions.halfvec default null, p_lenses text[] default array['corpus','ours'], p_tiers smallint[] default null,
  p_space_slugs text[] default null, p_document_types text[] default null, p_unit_kinds text[] default null, p_entity_ids uuid[] default null,
  p_as_of timestamptz default null, p_workspace_ids uuid[] default null, p_source_roles text[] default null, p_content_kinds text[] default null,
  p_limit integer default 20, p_candidate_limit integer default 100, p_rrf_k integer default 60)
returns table(vector_item_id uuid, lens text, source_tier smallint, content_kind text, document_type_code text, unit_kind text, entity_id uuid, document_id uuid, document_version_id uuid,
              target_kind text, target_id uuid, workspace_id uuid, snippet text, start_ms integer, end_ms integer, observed_at timestamptz, valid_during tstzrange, space_slug text,
              fused_score double precision, channel_scores jsonb)
language plpgsql stable security definer set search_path = '' as $$
declare t uuid := util.default_tenant_id(); q tsquery := websearch_to_tsquery('english', p_query);
begin
  if coalesce(length(btrim(p_query)),0) < 1 or length(p_query) > 4096 then raise exception 'query text length must be between 1 and 4096' using errcode='invalid_parameter_value'; end if;
  if p_limit not between 1 and 200 or p_candidate_limit not between p_limit and 2000 then raise exception 'result/candidate bounds are invalid' using errcode='invalid_parameter_value'; end if;
  perform set_config('hnsw.iterative_scan','relaxed_order',true);
  return query
  with eligible as materialized (
    select vi.*, s.slug as space_slug_
    from retrieval.vector_item vi join retrieval.vector_space_version v on v.id = vi.space_version_id join retrieval.vector_space s on s.id = v.vector_space_id
    where vi.tenant_id = t and vi.lifecycle = 'active'
      and vi.lens = any(p_lenses)
      and (vi.lens <> 'private' or (p_workspace_ids is not null and vi.workspace_id = any(p_workspace_ids)))
      and (p_tiers is null or vi.source_tier = any(p_tiers))
      and (p_space_slugs is null or s.slug = any(p_space_slugs))
      and (p_document_types is null or vi.document_type_code = any(p_document_types))
      and (p_unit_kinds is null or vi.unit_kind = any(p_unit_kinds))
      and (p_content_kinds is null or vi.content_kind = any(p_content_kinds))
      and (p_source_roles is null or vi.source_role_code = any(p_source_roles))
      and (p_entity_ids is null or vi.entity_id = any(p_entity_ids) or vi.secondary_entity_ids && p_entity_ids)
      and (p_as_of is null or vi.valid_during is null or vi.valid_during @> p_as_of)
  ), fts as (
    select e.id, ts_rank_cd(e.search_tsv_en, q)::double precision raw, row_number() over (order by ts_rank_cd(e.search_tsv_en, q) desc, e.id)::bigint rk
    from eligible e where e.search_tsv_en @@ q limit p_candidate_limit
  ), trigram as (
    select e.id, extensions.similarity(e.search_text, p_query)::double precision raw, row_number() over (order by extensions.similarity(e.search_text, p_query) desc, e.id)::bigint rk
    from eligible e where length(p_query) >= 3 and extensions.similarity(e.search_text, p_query) > 0.3 limit p_candidate_limit
  ), ann as (
    select e.id, (1 - (emb.embedding operator(extensions.<=>) p_query_embedding))::double precision raw, row_number() over (order by emb.embedding operator(extensions.<=>) p_query_embedding, e.id)::bigint rk
    from eligible e join retrieval.vector_item_embedding_1536 emb on emb.vector_item_id = e.id and emb.vector_space_key = e.space_slug_
    where p_query_embedding is not null
    order by emb.embedding operator(extensions.<=>) p_query_embedding, e.id limit p_candidate_limit
  ), channels as (
    select id, 'fts' ch, raw, rk from fts union all select id, 'trigram', raw, rk from trigram union all select id, 'ann', raw, rk from ann
  ), fused as (
    select id, sum(1.0/(p_rrf_k + rk))::double precision score, jsonb_object_agg(ch, jsonb_build_object('score', raw, 'rank', rk) order by ch) details from channels group by id
  )
  select e.id, e.lens, e.source_tier, e.content_kind, e.document_type_code, e.unit_kind, e.entity_id, e.document_id, e.document_version_id,
         pt.target_kind, coalesce(pt.entity_id, pt.record_id, pt.chunk_id, pt.claim_id, pt.summary_id, pt.document_node_id, pt.digest_id, pt.authored_revision_id, pt.passage_id),
         e.workspace_id, left(e.search_text, 320), e.start_ms, e.end_ms, e.observed_at, e.valid_during, e.space_slug_, f.score * (1 + coalesce(0.1 * (3 - e.source_tier), 0)), f.details
  from fused f join eligible e on e.id = f.id left join retrieval.projection_target pt on pt.id = e.projection_target_id
  order by f.score * (1 + coalesce(0.1 * (3 - e.source_tier), 0)) desc, e.id limit p_limit;
end $$;
comment on function api.search_unified is 'L3 scoped semantic search over the one stack: resolve the scope first (lens, tier, space, document kind, unit kind, entity, as-of, workspace for private), then fuse english full-text, trigram and ANN (if an embedding is given) with RRF; tier is a mild boost. Private items are returned only for the workspaces passed in.';
grant execute on function api.search_unified(text, extensions.halfvec, text[], smallint[], text[], text[], text[], uuid[], timestamptz, uuid[], text[], text[], integer, integer, integer) to app_reader, pipeline_agent, verifier_agent, control_plane, executor_service, product_api_owner, authenticated, service_role;

-- ---------------------------------------------------------------------------------------------- 19. product API: private passages and our content join the same stack
drop table library.passage_embedding_1536;
