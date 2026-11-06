begin;

-- Earlier local development revisions temporarily made this legacy column
-- globally NOT NULL. Restore legacy compatibility and enforce content presence
-- only for resolved verification.v1 locators.
alter table evidence.locator alter column selected_content_sha256 drop not null;
alter table evidence.locator drop constraint if exists locator_resolution_state_check;
alter table evidence.locator add constraint locator_resolution_state_check check(
 resolution_state is null or resolution_state in('resolved','not_found','ambiguous','invalid','parse_error')
);
alter table evidence.locator drop constraint locator_resolution_cardinality_ck;
alter table evidence.locator add constraint locator_resolution_cardinality_ck check(
 verification_contract_version is null or (
  tenant_id is not null and representation_artifact_id is not null and selector_sha256 is not null
  and selected_size_bytes is not null and normalization_policy is not null and resolution_version is not null
  and resolution_state is not null and occurrence_count is not null
  and ((resolution_state='resolved' and occurrence_count=1 and selected_content_sha256 is not null)
    or (resolution_state='ambiguous' and occurrence_count>1 and selected_content_sha256 is null)
    or (resolution_state in('not_found','invalid','parse_error') and occurrence_count=0 and selected_content_sha256 is null))
 )
);

commit;
