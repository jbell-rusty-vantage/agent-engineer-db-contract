begin;

-- Organization ecosystem roles and a person's professional roles are inherently
-- multi-dimensional. Keep entity_subtype for intrinsic organizational nature;
-- move roles to explicit multi-cardinality facets.
insert into taxonomy.facet (slug,label,description,cardinality) values
  ('organization_role','Organization AI ecosystem role','Roles an organization performs in the AI ecosystem; intentionally multi-valued.','multi'),
  ('person_role','Person role','Contextual professional roles held by a person; intentionally multi-valued and supplemented by temporal relationship rows.','multi')
on conflict (tenant_id,slug) do update set
  label=excluded.label,description=excluded.description,cardinality=excluded.cardinality;

insert into taxonomy.facet_version(facet_id,version,status,notes)
select id,1,'active','Multidimensional role taxonomy 2026-08-29'
from taxonomy.facet where slug in ('organization_role','person_role')
on conflict(facet_id,version) do nothing;

with terms(facet_slug,slug,label,ord) as (values
  ('organization_role','model-developer','Model developer',10),
  ('organization_role','software-product-vendor','Software product vendor',20),
  ('organization_role','cloud-compute-provider','Cloud or compute provider',30),
  ('organization_role','hardware-chip-provider','Hardware or semiconductor provider',40),
  ('organization_role','data-provider','Data provider',50),
  ('organization_role','developer-tool-provider','Developer-tool provider',60),
  ('organization_role','benchmark-evaluation-provider','Benchmark or evaluation provider',70),
  ('organization_role','safety-governance-provider','Safety or governance provider',80),
  ('organization_role','research-publisher','Research publisher',90),
  ('organization_role','integrator-consultancy','Integrator or consultancy',100),
  ('organization_role','enterprise-adopter','Enterprise AI adopter',110),
  ('organization_role','funder-investor','Funder or investor',120),
  ('person_role','researcher','Researcher',10),
  ('person_role','engineer','Engineer',20),
  ('person_role','maintainer','Maintainer',30),
  ('person_role','founder','Founder',40),
  ('person_role','executive','Executive',50),
  ('person_role','product-lead','Product lead',60),
  ('person_role','standards-contributor','Standards contributor',70),
  ('person_role','educator-advocate','Educator or developer advocate',80),
  ('person_role','investor-analyst','Investor or analyst',90)
)
insert into taxonomy.term(facet_version_id,slug,label,sort_order)
select fv.id,t.slug,t.label,t.ord
from taxonomy.facet f join taxonomy.facet_version fv on fv.facet_id=f.id and fv.version=1
join terms t on t.facet_slug=f.slug
on conflict(facet_version_id,slug) do update set label=excluded.label,sort_order=excluded.sort_order;

-- Remove role-like children from the single-valued entity_subtype facet. These
-- terms are new and cannot have valid assignments yet because this migration
-- immediately follows their introduction.
delete from taxonomy.term_target_kind s
using taxonomy.term t,taxonomy.facet_version fv,taxonomy.facet f
where s.term_id=t.id and t.facet_version_id=fv.id and fv.facet_id=f.id
  and f.slug='entity_subtype'
  and t.slug in ('researcher','engineer','founder','executive','educator','investor',
    'model-lab','software-vendor','cloud-provider','hardware-vendor',
    'consultancy-integrator','enterprise-adopter');

delete from taxonomy.term t
using taxonomy.facet_version fv,taxonomy.facet f
where t.facet_version_id=fv.id and fv.facet_id=f.id and f.slug='entity_subtype'
  and t.slug in ('researcher','engineer','founder','executive','educator','investor',
    'model-lab','software-vendor','cloud-provider','hardware-vendor',
    'consultancy-integrator','enterprise-adopter');

-- Add intrinsic organization natures that align with corpus.organization.org_kind.
with terms(slug,label,ord) as (values
  ('commercial-company','Commercial company',510),
  ('research-lab','Research institute or laboratory',520),
  ('government-agency','Government or public agency',530),
  ('publisher-media','Publisher or media organization',540),
  ('investor-funder-organization','Investor or funding organization',550)
), inserted as (
  insert into taxonomy.term(facet_version_id,slug,label,parent_term_id,sort_order)
  select fv.id,t.slug,t.label,parent.id,t.ord
  from taxonomy.facet f join taxonomy.facet_version fv on fv.facet_id=f.id and fv.version=1
  join taxonomy.term parent on parent.facet_version_id=fv.id and parent.slug='organization'
  cross join terms t where f.slug='entity_subtype'
  on conflict(facet_version_id,slug) do update set label=excluded.label,parent_term_id=excluded.parent_term_id,sort_order=excluded.sort_order
  returning id
)
insert into taxonomy.term_target_kind(term_id,entity_kind_code)
select id,'organization' from inserted on conflict do nothing;

-- Role facets are explicitly scoped to the compatible primary kind.
insert into taxonomy.term_target_kind(term_id,entity_kind_code)
select t.id,case f.slug when 'organization_role' then 'organization' else 'person' end
from taxonomy.term t join taxonomy.facet_version fv on fv.id=t.facet_version_id
join taxonomy.facet f on f.id=fv.facet_id
where f.slug in ('organization_role','person_role')
on conflict do nothing;

commit;
