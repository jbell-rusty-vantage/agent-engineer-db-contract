---
id: "dom:verified-knowledge"
kind: domain
lens: evidence
schemas: []
aliases: [verified claims, claim candidates, verdicts, probes, probe runs, probe matrix, conflicts, restatements, claim triage, disputed claims, what is verified]
relations: [api.verified_claims, api.claim_candidates, api.claim_verdicts, api.claim_conflicts, api.claim_restatements, api.claim_triage, api.claim_surfaces, api.community_claims, api.probes, verification.probe, verification.probe_claim, verification.probe_run, verification.probe_verdict, verification.claim_triage, evidence.claim_conflict]
functions: [api.interview_outputs, api.library_dossier, api.probe_matrix, api.probe_revalidation_due, api.propose_verdict, api.record_claim, api.record_probe_run, api.record_triage, api.register_probe, api.releases_needing_review, api.restate_claim]
tasks: [propose-verdict-from-probe, read-claim-with-evidence, record-claim-with-evidence, triage-claims-and-assess-sources, what-a-release-affects, what-agents-may-not-write, what-is-due, what-is-verified-about-subject, why-claim-disputed-or-restated, write-verification-chain]
summary: A claim is a candidate until a probe judges it and a Knowledge Services admission verifies it; conflicts and restatements are kept beside it.
provenance: model_assisted
reviewed: null
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# Verified knowledge (claims, probes, verdicts)

A claim is a candidate until a probe judges it and a Knowledge Services admission verifies it; conflicts and restatements are kept beside it.

> curated (model_assisted, unreviewed) — Read through the `api` views; the tables behind them are not readable by app_reader or a
> signed-in session.
> 
> **A claim's life.** Every statement read from a source is a row of `evidence.claim`, shown
> by `api.claim_candidates` with its `path` (how it entered), `status` (`proposed`,
> `verified`, `disputed`), subjects and the document it was read from. Candidates are never
> facts. `verification.claim_triage` (`api.claim_triage`) records what to do with a candidate
> before anyone checks it: probe it, check the docs or a registry, or leave it (not
> checkable, duplicate, out of scope).
> 
> **Probes and verdicts.** A `verification.probe` is an experiment that tests stated claims
> against a matrix of cells; a cell is a date (what an install resolved that day) or an
> explicit pin. Each execution is a `verification.probe_run`; `api.probe_matrix` returns the
> latest run per cell with the versions it resolved and what it observed. What the runs say
> about one claim is a `verification.probe_verdict`: `directly_supported`,
> `supported_with_qualification`, `contradicted`, `not_supported` or `unverifiable`, proposed
> by an agent and confirmed or rejected by a person (`review_state`). `api.claim_verdicts`
> has the latest verdict per claim; `api.probes` lists probes with their verdicts.
> 
> **Verified.** A supportive verdict does not verify a claim. `api.verified_claims` holds the
> claims that reached `verified` under a receipt bound to an admitted Knowledge Services use
> decision (`use_decision_id`, `receipt_id`, the bound `effect`), with their current verdicts.
> Only these are verified knowledge (source tier 0 in search). A deterministic probe that
> contradicts a claim moves it to `disputed`.
> 
> **Kept beside the claim.** `evidence.claim_conflict` (`api.claim_conflicts`) keeps a
> disagreement between a first-party claim and another statement until someone reconciles
> it. `api.claim_restatements` pairs a restated claim with the attribution-framed original
> it was atomized from; the original stays `proposed`. `api.claim_surfaces` (talk claims and
> the docs they concern) and `api.community_claims` (issue trackers, forums, comparison
> articles) are candidate views by channel.
> 
> **What goes stale.** `api.probe_revalidation_due` lists probes whose latest cell ran on an
> older version than the newest catalogued release; `api.releases_needing_review` lists our
> frozen releases whose bound claims changed verdict since (a signed-in user sees those of
> their workspaces). `api.library_dossier` assembles releases, claims, probes and ranked
> sources for one library in one call.
> 
> Start with `q:evidence.verified_claims`; one claim in depth is `q:evidence.claim`,
> `q:evidence.claim_verdicts` and `q:evidence.probe_matrix`. Sources and watch policies are
> the source-intelligence domain.
> 
> **Writing.** An agent role writes this chain through governed functions, never by
> inserting rows: `api.record_claim`, `api.restate_claim`, `api.register_probe`,
> `api.record_probe_run`, `api.propose_verdict` and `api.record_triage`
> (`tasks/write-verification-chain.md`). Each is idempotent on a caller key and leaves a
> receipt naming the role and the mission run. What they never do: verify a claim (only a
> Knowledge Services admission does) or record a person's review
> (`tasks/what-agents-may-not-write.md`). A read role writes nothing.

## Relations that matter

| Relation | Summary | Enforced | Direct writers |
| --- | --- | --- | --- |
| [`api.verified_claims`](../relations/api/verified_claims.md) | Loop 6: claims that reached verified through a Knowledge Services admission, with the use decision, the admis… | — | helpers only |
| [`api.claim_candidates`](../relations/api/claim_candidates.md) | L3/evidence: every claim with its path (deterministic_first_party = cheap path, L1_candidate = prose/media ca… | — | helpers only |
| [`api.claim_verdicts`](../relations/api/claim_verdicts.md) | Claims that a probe has judged, with who stated them, on which channel, the latest verdict, its review state … | — | helpers only |
| [`api.claim_conflicts`](../relations/api/claim_conflicts.md) | Kept disagreements between a first-party claim and another statement (value, scope or subject ambiguity); nev… | — | helpers only |
| [`api.claim_restatements`](../relations/api/claim_restatements.md) | Loop 7 (D-80): restated claims and the attribution-framed originals they were atomized from (the original sta… | — | helpers only |
| [`api.claim_triage`](../relations/api/claim_triage.md) | Loop 5: the current triage of each claim candidate, with the probe it became and its verdict if probed. | — | helpers only |
| [`api.claim_surfaces`](../relations/api/claim_surfaces.md) | Claim candidates from talks (speaker, timecode, exact quote; always proposed, never adjudicated) with the lib… | — | helpers only |
| [`api.community_claims`](../relations/api/community_claims.md) | Claims stated on a community or editorial channel (issue trackers, forums, aggregators, comparison articles):… | — | helpers only |
| [`api.probes`](../relations/api/probes.md) | Probes (experiments that test stated claims) with their subjects, the number of claims and runs, the last run… | — | helpers only |
| [`verification.probe`](../relations/verification/probe.md) | Loop 4: an experiment that tests stated claims against a matrix of environments. Cells are dates (uv --exclud… | PK (id); unique (tenant_id, slug); RLS | `control_plane`, `pipeline_agent`, `verifier_agent` |
| [`verification.probe_claim`](../relations/verification/probe_claim.md) | table | PK (probe_id, claim_id); RLS | `control_plane`, `pipeline_agent`, `verifier_agent` |
| [`verification.probe_run`](../relations/verification/probe_run.md) | Loop 4: one execution of a probe in one cell. outcome pass/fail is about the probe's own checks, not about th… | PK (id); RLS | `control_plane`, `pipeline_agent`, `verifier_agent` |
| [`verification.probe_verdict`](../relations/verification/probe_verdict.md) | Loop 4: what a probe's runs say about one claim. Append-only: a changed verdict is a new row that supersedes.… | PK (id); RLS | `control_plane`, `pipeline_agent`, `verifier_agent` |
| [`verification.claim_triage`](../relations/verification/claim_triage.md) | Loop 5: what to do with a claim candidate before anyone checks it: probe it, check the docs or the registry, … | PK (id); RLS | `control_plane`, `pipeline_agent`, `verifier_agent` |
| [`evidence.claim_conflict`](../relations/evidence/claim_conflict.md) | table | PK (id); unique (claim_a_id, claim_b_id, conflict_kind); RLS | `executor_service`, `verifier_agent` |

## Functions

[`api.interview_outputs`](../functions/api/interview_outputs.md), [`api.library_dossier`](../functions/api/library_dossier.md), [`api.probe_matrix`](../functions/api/probe_matrix.md), [`api.probe_revalidation_due`](../functions/api/probe_revalidation_due.md), [`api.propose_verdict`](../functions/api/propose_verdict.md), [`api.record_claim`](../functions/api/record_claim.md), [`api.record_probe_run`](../functions/api/record_probe_run.md), [`api.record_triage`](../functions/api/record_triage.md), [`api.register_probe`](../functions/api/register_probe.md), [`api.releases_needing_review`](../functions/api/releases_needing_review.md), [`api.restate_claim`](../functions/api/restate_claim.md)

## Named queries

[`q:evidence.claim`](../queries/README.md), [`q:evidence.claim_conflicts`](../queries/README.md), [`q:evidence.claim_restatements`](../queries/README.md), [`q:evidence.claim_triage`](../queries/README.md), [`q:evidence.claim_verdicts`](../queries/README.md), [`q:evidence.probe_matrix`](../queries/README.md), [`q:evidence.probe_revalidation_due`](../queries/README.md), [`q:evidence.probes`](../queries/README.md), [`q:evidence.verified_claims`](../queries/README.md), [`q:ours.releases_needing_review`](../queries/README.md)

## Tasks

[`propose-verdict-from-probe`](../tasks/propose-verdict-from-probe.md), [`read-claim-with-evidence`](../tasks/read-claim-with-evidence.md), [`record-claim-with-evidence`](../tasks/record-claim-with-evidence.md), [`triage-claims-and-assess-sources`](../tasks/triage-claims-and-assess-sources.md), [`what-a-release-affects`](../tasks/what-a-release-affects.md), [`what-agents-may-not-write`](../tasks/what-agents-may-not-write.md), [`what-is-due`](../tasks/what-is-due.md), [`what-is-verified-about-subject`](../tasks/what-is-verified-about-subject.md), [`why-claim-disputed-or-restated`](../tasks/why-claim-disputed-or-restated.md), [`write-verification-chain`](../tasks/write-verification-chain.md)

Schemas: —.
