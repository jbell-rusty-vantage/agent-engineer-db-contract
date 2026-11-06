---
id: "voc:taxonomy.relationship_kind"
kind: vocabulary
schema: taxonomy
name: relationship_kind
rows: 65
rows_sha256: "sha256:b3e61c771146acabc263b3d88664d3c5599de8290d47affb55669a4f6c994d59"
codes: [about, advisor_to, affected_by_advisory, announced_at, authored_by, backed_by_repository, benchmark_executed_by, benchmark_subject, benchmark_uses_dataset, board_member_of, built_on_model, case_study_uses, channel_owned_by, cites, competes_with, customer_of, depends_on, derived_from_model, develops, distributes, edition_of, employed_by, evaluated_on, feature_of_protocol, founded, hardware_requirement, has_feature, hosts, implements_protocol, implements_technique, in_series, instance_of_concept, introduces_technique, investor_in, listed_in, maintains, manufactures, offered_as, offered_by, operates, organized_by, owns_stake_in, participates_in_round, partner_of, party_to_transaction, presented_at, presented_by, provides_compute, published_by, published_on, recipient_of_round, recorded_as, records_event, runs_on, series_on_channel, sponsors, subsidiary_of, supersedes, technique_relates_to, trained_on, transaction_asset, uses_technique, variant_of, vends, version_of]
workspace_fingerprint: "sha256:4e9df120bfb6759a1ae43b1e31c9019c82c3a604e8a95e33b47ce2f5463eb5a9"
---
# taxonomy.relationship_kind

Reference data snapshot (65 rows, digest `sha256:b3e61c771146acabc263b3d88664d3c5599de8290d47affb55669a4f6c994d59`). Codes are enforced wherever a column has a foreign key to [`taxonomy.relationship_kind`](../relations/taxonomy/relationship_kind.md).

| code | description | from_kinds | inverse_label | property_schema | symmetric | temporal | to_kinds |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `about` | about | story, case_study | — | `{}` | no | no | person, organization, product, product_version, product_feature, ai_model, ai_model_version, model_offering, technique, dataset, benchmark, benchmark_run, repository, library, library_release, mcp_server, agent_skill, ai_protocol, ai_protocol_version, ai_protocol_feature, paper, media_channel, media_series, media_work, event_series, industry_event, talk, story, case_study, concept, funding_round, corporate_transaction, registry, security_advisory, compute_device, compute_offering |
| `advisor_to` | advisor to | person | — | `{}` | no | yes | organization |
| `affected_by_advisory` | affected by advisory | library, mcp_server, product, ai_model | — | `{}` | no | no | security_advisory |
| `announced_at` | announced at | product_version, ai_model_version, product | — | `{}` | no | no | industry_event |
| `authored_by` | authored by | paper, story, agent_skill | — | `{}` | no | no | person |
| `backed_by_repository` | backed by repository | product, library, mcp_server, agent_skill | — | `{}` | no | no | repository |
| `benchmark_executed_by` | benchmark executed by | benchmark_run | — | `{}` | no | no | organization |
| `benchmark_subject` | benchmark subject | benchmark_run | — | `{}` | no | no | ai_model_version, product_version, library_release |
| `benchmark_uses_dataset` | benchmark uses dataset | benchmark | — | `{}` | no | no | dataset |
| `board_member_of` | board member of | person | — | `{}` | no | yes | organization |
| `built_on_model` | built on model | product, product_version | — | `{}` | no | yes | ai_model_version |
| `case_study_uses` | case study uses | case_study | — | `{}` | no | no | product, ai_model_version, library, technique |
| `channel_owned_by` | channel owned by | media_channel | — | `{}` | no | yes | organization, person |
| `cites` | cites | paper | — | `{}` | no | no | paper |
| `competes_with` | competes with | product, ai_model | — | `{}` | yes | no | product, ai_model |
| `customer_of` | customer of | organization | — | `{}` | no | yes | product, ai_model, library, mcp_server, agent_skill |
| `depends_on` | depends on | library_release, product_version | — | `{}` | no | no | library |
| `derived_from_model` | derived from model | ai_model_version | — | `{}` | no | no | ai_model_version |
| `develops` | develops | organization | — | `{}` | no | yes | product, ai_model, library, mcp_server, agent_skill |
| `distributes` | distributes | organization | — | `{}` | no | yes | product, ai_model, library, mcp_server, agent_skill |
| `edition_of` | edition of | industry_event | — | `{}` | no | no | event_series |
| `employed_by` | employed by | person | — | `{}` | no | yes | organization |
| `evaluated_on` | evaluated on | benchmark_run | — | `{}` | no | no | benchmark |
| `feature_of_protocol` | feature of protocol | ai_protocol_feature | — | `{}` | no | no | ai_protocol |
| `founded` | founded | person | — | `{}` | no | no | organization |
| `hardware_requirement` | hardware requirement | ai_model_version | — | `{}` | no | no | compute_device |
| `has_feature` | has feature | product | — | `{}` | no | no | product_feature |
| `hosts` | hosts | person | — | `{}` | no | yes | media_channel, media_series |
| `implements_protocol` | implements protocol | product, library, mcp_server | — | `{}` | no | yes | ai_protocol_version, ai_protocol_feature |
| `implements_technique` | implements technique | product, library, mcp_server, agent_skill | — | `{}` | no | no | technique |
| `in_series` | in series | media_work | — | `{}` | no | no | media_series |
| `instance_of_concept` | instance of concept | person, organization, product, product_version, product_feature, ai_model, ai_model_version, model_offering, technique, dataset, benchmark, benchmark_run, repository, library, library_release, mcp_server, agent_skill, ai_protocol, ai_protocol_version, ai_protocol_feature, paper, media_channel, media_series, media_work, event_series, industry_event, talk, story, case_study, concept, funding_round, corporate_transaction, registry, security_advisory, compute_device, compute_offering | — | `{}` | no | no | concept |
| `introduces_technique` | introduces technique | paper | — | `{}` | no | no | technique |
| `investor_in` | investor in | person | — | `{}` | no | yes | organization |
| `listed_in` | listed in | library, mcp_server, agent_skill, ai_model, dataset | — | `{}` | no | yes | registry |
| `maintains` | maintains | person, organization | — | `{}` | no | yes | library, repository, mcp_server, agent_skill |
| `manufactures` | manufactures | organization | — | `{}` | no | no | compute_device |
| `offered_as` | offered as | ai_model_version | — | `{}` | no | no | model_offering |
| `offered_by` | offered by | model_offering | — | `{}` | no | no | organization |
| `operates` | operates | organization | — | `{}` | no | yes | product, ai_model, library, mcp_server, agent_skill |
| `organized_by` | organized by | industry_event, event_series | — | `{}` | no | no | organization |
| `owns_stake_in` | owns stake in | organization | — | `{}` | no | yes | organization |
| `participates_in_round` | participates in round | organization, person | — | `{}` | no | no | funding_round |
| `partner_of` | partner of | organization | — | `{}` | yes | yes | organization |
| `party_to_transaction` | party to transaction | organization | — | `{}` | no | no | corporate_transaction |
| `presented_at` | presented at | talk | — | `{}` | no | no | industry_event |
| `presented_by` | presented by | talk | — | `{}` | no | no | person |
| `provides_compute` | provides compute | organization | — | `{}` | no | no | compute_offering |
| `published_by` | published by | paper, story, media_work | — | `{}` | no | no | organization |
| `published_on` | published on | media_work | — | `{}` | no | no | media_channel |
| `recipient_of_round` | recipient of round | organization | — | `{}` | no | no | funding_round |
| `recorded_as` | recorded as | talk | — | `{}` | no | no | media_work |
| `records_event` | records event | media_series | — | `{}` | no | no | industry_event |
| `runs_on` | runs on | model_offering, compute_offering | — | `{}` | no | no | compute_device |
| `series_on_channel` | series on channel | media_series | — | `{}` | no | no | media_channel |
| `sponsors` | sponsors | organization | — | `{}` | no | no | industry_event |
| `subsidiary_of` | subsidiary of | organization | — | `{}` | no | yes | organization |
| `supersedes` | supersedes | product, ai_model | — | `{}` | no | no | product, ai_model |
| `technique_relates_to` | technique relates to | technique | — | `{}` | no | no | technique |
| `trained_on` | trained on | ai_model_version | — | `{}` | no | no | dataset |
| `transaction_asset` | transaction asset | corporate_transaction | — | `{}` | no | no | product, repository, ai_model |
| `uses_technique` | uses technique | ai_model_version, product, library | — | `{}` | no | no | technique |
| `variant_of` | variant of | product, ai_model | — | `{}` | no | no | product, ai_model |
| `vends` | vends | organization | — | `{}` | no | yes | product, ai_model, library, mcp_server, agent_skill |
| `version_of` | version of | product_version, ai_model_version, library_release, ai_protocol_version | — | `{}` | no | no | product, ai_model, library, ai_protocol |
