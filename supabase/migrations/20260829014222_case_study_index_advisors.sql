begin;

create index case_study_merged_into_idx on corpus.case_study (merged_into_id)
  where merged_into_id is not null;
create index case_study_created_receipt_idx on corpus.case_study (created_by_receipt_id);
create index case_study_updated_receipt_idx on corpus.case_study (updated_by_receipt_id)
  where updated_by_receipt_id is not null;
create index candidate_case_study_kind_fk_idx
  on staging.candidate_case_study (candidate_id, candidate_kind);

commit;
