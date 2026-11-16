---
id: "voc:taxonomy.relationship_kind"
kind: vocabulary
schema: taxonomy
name: relationship_kind
rows: 70
rows_sha256: "sha256:a6f58980a24bd4c8cafb15bab45076cc1ab295f52850a7261cfa928140caac1f"
codes: [about, active_on, advisor_to, affected_by_advisory, announced_at, authored_by, backed_by_repository, benchmark_uses_dataset, board_member_of, built_on_model, bundles, case_study_uses, channel_owned_by, cites, compatible_with, competes_with, customer_of, depends_on, derived_from_model, develops, distributes, edition_of, employed_by, feature_of_protocol, founded, hardware_requirement, has_code, has_feature, hosts, implements_protocol, implements_technique, in_series, instance_of_concept, integrates_with, introduces_technique, investor_in, listed_in, maintains, manufactures, offered_as, offered_by, operates, operates_channel, organized_by, owns_stake_in, participates_in_round, partner_of, party_to_transaction, presented_at, presented_by, provides_compute, published_by, published_in, published_on, recipient_of_round, recorded_as, records_event, runs_on, same_actor_as, series_on_channel, sponsors, subsidiary_of, supersedes, technique_relates_to, trained_on, transaction_asset, uses_technique, variant_of, vends, version_of]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# taxonomy.relationship_kind

Reference data snapshot (70 rows, digest `sha256:a6f58980a24bd4c8cafb15bab45076cc1ab295f52850a7261cfa928140caac1f`). Codes are enforced wherever a column has a foreign key to [`taxonomy.relationship_kind`](../relations/taxonomy/relationship_kind.md).

| code | description | from_kinds | inverse_label | property_schema | symmetric | temporal | to_kinds |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `about` | about | story, case_study, talk, paper, media_work | — | `{}` | no | no | media_channel, ai_model, ai_model_version, product_feature, paper, person, industry_event, benchmark_version, compute_offering, organization, case_study, registry, product_version, repository, ai_protocol_feature, benchmark, compute_device, event_series, ai_protocol, media_series, talk, concept, agent_skill, product, story, corporate_transaction, media_work, model_offering, technique, ai_protocol_version, mcp_server, dataset, library, agent_plugin, library_release, funding_round, security_advisory |
| `active_on` | The actor published at least one captured statement on the channel | community_actor, person | has_participant | `{"properties":{"platform_role":{"type":"string"},"posts":{"type":"integer"}},"t…` | no | no | source_channel |
| `advisor_to` | advisor to | person | — | `{}` | no | yes | organization |
| `affected_by_advisory` | affected by advisory | ai_model, library, repository, product, library_release, mcp_server | — | `{}` | no | no | security_advisory |
| `announced_at` | announced at | product_version, ai_model_version, product | — | `{}` | no | no | industry_event |
| `authored_by` | authored by | paper, story, agent_skill | — | `{}` | no | no | person |
| `backed_by_repository` | backed by repository | library, agent_skill, product, agent_plugin, mcp_server | — | `{}` | no | no | repository |
| `benchmark_uses_dataset` | benchmark uses dataset | benchmark | — | `{}` | no | no | dataset |
| `board_member_of` | board member of | person | — | `{}` | no | yes | organization |
| `built_on_model` | built on model | product, product_version | — | `{}` | no | yes | ai_model_version |
| `bundles` | A plugin bundles a skill or an MCP server (exact member, by identifier) | agent_plugin | bundled_in | `{"properties":{"config_path":{"type":"string"},"transport":{"type":"string"}},"…` | no | no | agent_skill, mcp_server |
| `case_study_uses` | case study uses | case_study | — | `{}` | no | no | product, ai_model_version, library, technique |
| `channel_owned_by` | channel owned by | media_channel | — | `{}` | no | yes | organization, person |
| `cites` | cites | talk, story, paper, media_work | — | `{}` | no | no | paper |
| `compatible_with` | A stated compatibility between versions (constraint in properties) | ai_model_version, agent_skill, product_version, agent_plugin, library_release, mcp_server | compatible_with | `{"properties":{"constraint":{"type":"string"},"stated_by":{"type":"string"}},"t…` | no | no | ai_model_version, product, product_version, library_release, ai_protocol_version |
| `competes_with` | competes with | product, ai_model | — | `{}` | yes | no | product, ai_model |
| `customer_of` | customer of | organization | — | `{}` | no | yes | product, ai_model, library, mcp_server, agent_skill |
| `depends_on` | depends on | library_release, product_version | — | `{}` | no | no | library |
| `derived_from_model` | derived from model | ai_model_version | — | `{}` | no | no | ai_model_version |
| `develops` | develops | organization | — | `{}` | no | yes | ai_model, library, agent_skill, product, agent_plugin, mcp_server |
| `distributes` | distributes | organization | — | `{}` | no | yes | product, ai_model, library, mcp_server, agent_skill |
| `edition_of` | edition of | industry_event | — | `{}` | no | no | event_series |
| `employed_by` | employed by | person | — | `{}` | no | yes | organization |
| `feature_of_protocol` | feature of protocol | ai_protocol_feature | — | `{}` | no | no | ai_protocol |
| `founded` | founded | person | — | `{}` | no | no | organization |
| `hardware_requirement` | hardware requirement | ai_model_version | — | `{}` | no | no | compute_device |
| `has_code` | A work points at the repository that holds its code | talk, paper, media_work, story, case_study | code_for | `{"type":"object"}` | no | no | repository, talk, paper |
| `has_feature` | has feature | product | — | `{}` | no | no | product_feature |
| `hosts` | hosts | person | — | `{}` | no | yes | media_channel, media_series |
| `implements_protocol` | implements protocol | library, product, library_release, mcp_server | — | `{}` | no | yes | ai_protocol_version, ai_protocol_feature |
| `implements_technique` | implements technique | product, library, mcp_server, agent_skill | — | `{}` | no | no | technique |
| `in_series` | in series | media_work | — | `{}` | no | no | media_series |
| `instance_of_concept` | instance of concept | media_channel, ai_model, ai_model_version, product_feature, paper, person, industry_event, benchmark_version, compute_offering, organization, case_study, registry, product_version, repository, ai_protocol_feature, benchmark, compute_device, event_series, ai_protocol, media_series, talk, concept, agent_skill, product, story, corporate_transaction, media_work, model_offering, technique, ai_protocol_version, mcp_server, dataset, library, agent_plugin, library_release, funding_round, security_advisory | — | `{}` | no | no | concept |
| `integrates_with` | A documented integration between software things | library, product, mcp_server, agent_skill | integrated_by | `{"properties":{"kind":{"type":"string"}},"type":"object"}` | no | yes | library, product, mcp_server, ai_model, ai_protocol |
| `introduces_technique` | introduces technique | paper | — | `{}` | no | no | technique |
| `investor_in` | investor in | person | — | `{}` | no | yes | organization |
| `listed_in` | listed in | dataset, ai_model, library, agent_skill, agent_plugin, mcp_server | — | `{}` | no | yes | registry |
| `maintains` | maintains | person, organization | — | `{}` | no | yes | library, repository, mcp_server, agent_skill |
| `manufactures` | manufactures | organization | — | `{}` | no | no | compute_device |
| `offered_as` | offered as | ai_model_version | — | `{}` | no | no | model_offering |
| `offered_by` | offered by | model_offering | — | `{}` | no | no | organization |
| `operates` | operates | organization | — | `{}` | no | yes | product, ai_model, library, mcp_server, agent_skill |
| `operates_channel` | The organization or person that runs the channel (a vendor runs its issue tracker and docs site) | organization, person | operated_by | `{"type":"object"}` | no | no | source_channel |
| `organized_by` | organized by | industry_event, event_series | — | `{}` | no | no | organization |
| `owns_stake_in` | owns stake in | organization | — | `{}` | no | yes | organization |
| `participates_in_round` | participates in round | organization, person | — | `{}` | no | no | funding_round |
| `partner_of` | partner of | organization | — | `{}` | yes | yes | organization |
| `party_to_transaction` | party to transaction | organization | — | `{}` | no | no | corporate_transaction |
| `presented_at` | presented at | talk | — | `{}` | no | no | industry_event |
| `presented_by` | presented by | talk | — | `{}` | no | no | person |
| `provides_compute` | provides compute | organization | — | `{}` | no | no | compute_offering |
| `published_by` | published by | paper, story, media_work | — | `{}` | no | no | organization |
| `published_in` | Venue of a paper | paper | published | `{"type":"object"}` | no | no | industry_event, media_channel, organization |
| `published_on` | published on | media_work | — | `{}` | no | no | media_channel |
| `recipient_of_round` | recipient of round | organization | — | `{}` | no | no | funding_round |
| `recorded_as` | recorded as | talk | — | `{}` | no | no | media_work |
| `records_event` | records event | media_series | — | `{}` | no | no | industry_event |
| `runs_on` | runs on | model_offering, compute_offering | — | `{}` | no | no | compute_device |
| `same_actor_as` | Only when the platform itself states the link (e.g. a GitHub MEMBER of the vendor org who is a catalogued maintainer); … | community_actor | has_handle | `{"properties":{"stated_by":{"type":"string"}},"type":"object"}` | no | no | person |
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
| `version_of` | version of | ai_model_version, product_version, library_release, benchmark_version, ai_protocol_version | — | `{}` | no | no | ai_protocol, ai_model, library, product, benchmark |
