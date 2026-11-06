begin;
select plan(6);

select has_column('retrieval','retrieval_run','operation_id','retrieval run is bound to its durable operation');
select has_column('retrieval','retrieval_run','request_sha256','retrieval run stores the immutable request digest');
select has_index('retrieval','retrieval_run','retrieval_run_operation_uq','operation identity is unique per tenant');
select trigger_is('retrieval','retrieval_plan','retrieval_plan_immutable','util','reject_mutation','retrieval plans are immutable');
select trigger_is('retrieval','retrieval_run','retrieval_run_immutable','util','reject_mutation','retrieval runs are immutable');
select trigger_is('retrieval','retrieval_candidate','retrieval_candidate_immutable','util','reject_mutation','retrieval candidates are immutable');
select * from finish();
rollback;
