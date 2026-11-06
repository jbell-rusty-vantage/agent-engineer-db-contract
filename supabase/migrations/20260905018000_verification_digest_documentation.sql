begin;

comment on column evidence.verification_run.manifest_sha256 is
 'SHA-256 of the stored run-manifest artifact bytes. The inner signable manifest and detached seal payload use separate contract digests.';

comment on column evidence.verification_finding.replay_signature_match is
 'Nullable observation: true/false only when a replay receipt checked the signature; null means replay was not performed or is unknown.';

commit;
