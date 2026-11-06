-- Complete the verification verdict/source unions without coercion and make
-- logical source identity tenant-scoped for verification.v1 records.
alter type evidence.support_verdict add value if not exists 'pending_semantic_review';
alter type evidence.support_verdict add value if not exists 'mixed_or_conflicting';
alter type evidence.support_verdict add value if not exists 'insufficient_evidence';
alter type evidence.support_verdict add value if not exists 'source_unavailable';
alter type evidence.support_verdict add value if not exists 'locator_error';
alter type evidence.support_verdict add value if not exists 'parser_error';
alter type evidence.support_verdict add value if not exists 'derived_verified';
alter type evidence.support_verdict add value if not exists 'derived_failed';

begin;

drop index evidence.source_canonical_url_uq;
create unique index source_tenant_canonical_url_uq on evidence.source(tenant_id,canonical_url)
 where canonical_url is not null;
alter table evidence.source drop constraint source_source_class_check;
alter table evidence.source add constraint source_source_class_check check(source_class in(
 'web_page','api','repository','pdf','image','table','transcript','audio','video',
 'dataset','registry','upload','other'
));
alter table evidence.source
 add column verification_contract_version text check(verification_contract_version is null or verification_contract_version='verification.v1'),
 add column logical_identity text,
 add constraint source_verification_identity_ck check(verification_contract_version is null or
  (logical_identity is not null and btrim(logical_identity)<>'')),
 add constraint source_tenant_logical_identity_uq unique(tenant_id,source_class,logical_identity);

commit;
