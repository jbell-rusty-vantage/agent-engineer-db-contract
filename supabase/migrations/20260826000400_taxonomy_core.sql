-- 0004 | taxonomy: versioned multi-facet vocabularies.
--
-- Only the vocabulary lives here. taxonomy.assignment is deliberately deferred to
-- 0014, because its exclusive arc points into corpus (0005), knowledge (0006),
-- evaluation (0011) and curriculum (0013). Creating it here would be the forward
-- reference that breaks Fable's original ordering.

begin;

create type taxonomy.facet_status as enum ('draft', 'active', 'retired');

-- ---------------------------------------------------------------------------
-- Facets and their versions.
-- ---------------------------------------------------------------------------
create table taxonomy.facet (
  id          uuid primary key default util.uuidv7(),
  tenant_id   uuid not null default util.default_tenant_id(),
  slug        text not null,
  label       text not null,
  description text,
  -- Whether a target may hold more than one term from this facet.
  cardinality text not null default 'multi'
    check (cardinality in ('single','multi')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (tenant_id, slug)
);

create trigger facet_set_updated_at
  before update on taxonomy.facet
  for each row execute function util.set_updated_at();

create table taxonomy.facet_version (
  id          uuid primary key default util.uuidv7(),
  facet_id    uuid not null references taxonomy.facet(id) on delete cascade,
  version     integer not null,
  status      taxonomy.facet_status not null default 'draft',
  notes       text,
  -- forward reference: evaluation.review_task (0011), FK added in 0014
  approved_by_review_task_id uuid,
  approved_at timestamptz,
  created_at  timestamptz not null default now(),
  unique (facet_id, version),
  constraint facet_version_positive check (version > 0)
);

-- At most one active version per facet.
create unique index facet_version_one_active
  on taxonomy.facet_version (facet_id)
  where status = 'active';

-- ---------------------------------------------------------------------------
-- Terms. Poly-hierarchy is expressed through term_relation, not parent_term_id
-- alone, so a term can sit under more than one broader term.
-- ---------------------------------------------------------------------------
create table taxonomy.term (
  id               uuid primary key default util.uuidv7(),
  facet_version_id uuid not null references taxonomy.facet_version(id) on delete cascade,
  slug             text not null,
  label            text not null,
  definition       text,
  parent_term_id   uuid references taxonomy.term(id),
  sort_order       integer not null default 0,
  created_at       timestamptz not null default now(),
  unique (facet_version_id, slug)
);

create index term_parent_idx on taxonomy.term (parent_term_id);

create table taxonomy.term_relation (
  from_term_id  uuid not null references taxonomy.term(id) on delete cascade,
  to_term_id    uuid not null references taxonomy.term(id) on delete cascade,
  relation_kind text not null
    check (relation_kind in ('broader','narrower','related','replaced_by')),
  created_at    timestamptz not null default now(),
  primary key (from_term_id, to_term_id, relation_kind),
  constraint term_relation_no_self check (from_term_id <> to_term_id)
);

-- ---------------------------------------------------------------------------
-- Section 11: agent-proposed assignment changes require review on some facets.
-- The rule is data, so tightening a facet is a row, not a migration.
-- ---------------------------------------------------------------------------
create table taxonomy.assignment_review_requirement (
  facet_id        uuid primary key references taxonomy.facet(id) on delete cascade,
  requires_review boolean not null default true,
  rule            jsonb not null default '{}'::jsonb,
  created_at      timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Seed the nine facets from Fable section 6, each with a draft v1.
-- ---------------------------------------------------------------------------
insert into taxonomy.facet (slug, label, description, cardinality) values
  ('domain',             'Domain',              'Subject area the item belongs to',                  'multi'),
  ('lifecycle_stage',    'Lifecycle stage',     'Where in the delivery lifecycle this applies',      'multi'),
  ('architecture_role',  'Architecture role',   'Role an item plays in a system (agent-framework, eval-harness, vector-store, ...)', 'multi'),
  ('problem_class',      'Problem class',       'Class of technical problem addressed',              'multi'),
  ('solution_class',     'Solution class',      'Class of solution approach',                        'multi'),
  ('maturity',           'Maturity',            'Experimental through declining',                    'single'),
  ('evidence_state',     'Evidence state',      'Strength of the evidence backing the item',         'single'),
  ('production_concern', 'Production concern',  'Operational concern the item speaks to',            'multi'),
  ('learning_level',     'Learning level',      'Curriculum difficulty band',                        'single')
on conflict (tenant_id, slug) do nothing;

insert into taxonomy.facet_version (facet_id, version, status)
select id, 1, 'active' from taxonomy.facet
on conflict (facet_id, version) do nothing;

-- architecture_role is the facet that reclassifies libraries as agent frameworks,
-- eval harnesses and vector stores, which is how Fable avoids giving each of
-- those its own table. Seed it so 0005 has somewhere to point.
insert into taxonomy.term (facet_version_id, slug, label, sort_order)
select fv.id, t.slug, t.label, t.ord
from taxonomy.facet f
join taxonomy.facet_version fv on fv.facet_id = f.id and fv.version = 1
cross join (values
  ('agent-framework',       'Agent framework',        10),
  ('orchestration-library', 'Orchestration library',  20),
  ('eval-harness',          'Evaluation harness',     30),
  ('vector-store',          'Vector store',           40),
  ('retrieval-library',     'Retrieval library',      50),
  ('model-sdk',             'Model SDK',              60),
  ('observability-tool',    'Observability tool',     70),
  ('serving-runtime',       'Serving runtime',        80),
  ('training-library',      'Training library',       90),
  ('data-pipeline',         'Data pipeline',         100)
) as t(slug, label, ord)
where f.slug = 'architecture_role'
on conflict (facet_version_id, slug) do nothing;

insert into taxonomy.term (facet_version_id, slug, label, sort_order)
select fv.id, t.slug, t.label, t.ord
from taxonomy.facet f
join taxonomy.facet_version fv on fv.facet_id = f.id and fv.version = 1
cross join (values
  ('experimental', 'Experimental', 10),
  ('emerging',     'Emerging',     20),
  ('established',  'Established',  30),
  ('declining',    'Declining',    40)
) as t(slug, label, ord)
where f.slug = 'maturity'
on conflict (facet_version_id, slug) do nothing;

insert into taxonomy.term (facet_version_id, slug, label, sort_order)
select fv.id, t.slug, t.label, t.ord
from taxonomy.facet f
join taxonomy.facet_version fv on fv.facet_id = f.id and fv.version = 1
cross join (values
  ('introductory',  'Introductory',  10),
  ('intermediate',  'Intermediate',  20),
  ('advanced',      'Advanced',      30),
  ('expert',        'Expert',        40)
) as t(slug, label, ord)
where f.slug = 'learning_level'
on conflict (facet_version_id, slug) do nothing;

-- Facets where an agent-proposed change must go through review.
insert into taxonomy.assignment_review_requirement (facet_id, requires_review)
select id, slug in ('maturity','evidence_state','learning_level')
from taxonomy.facet
on conflict (facet_id) do nothing;

commit;
