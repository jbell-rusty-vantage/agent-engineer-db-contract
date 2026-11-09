---
id: "voc:guidance.item_kind"
kind: vocabulary
schema: guidance
name: item_kind
rows: 10
rows_sha256: "sha256:1ffd615df305bcea22d99e82ec7e3e6d456f436ccb931900915ed7a8aef00c9e"
codes: [advanced_usage_pattern, compatibility_constraint, failure_mode, implementation_example, operational_practice, research_direction, security_consideration, setup_guide_step, solution_pattern, technical_problem]
workspace_fingerprint: "sha256:0bdaf1f915461feecb08d7ad5612fcb8db9039b883dd9c6e7e9be6d621251eee"
---
# guidance.item_kind

Reference data snapshot (10 rows, digest `sha256:1ffd615df305bcea22d99e82ec7e3e6d456f436ccb931900915ed7a8aef00c9e`). Codes are enforced wherever a column has a foreign key to [`guidance.item_kind`](../relations/guidance/item_kind.md).

| code | description | payload_schema |
| --- | --- | --- |
| `advanced_usage_pattern` | A non-obvious usage with prerequisites | `{"type":"object"}` |
| `compatibility_constraint` | A version/compatibility rule between components | `{"type":"object"}` |
| `failure_mode` | How a component or technique fails, its triggers and mitigations | `{"type":"object"}` |
| `implementation_example` | A concrete code example anchored to a repository file/symbol or document unit | `{"type":"object"}` |
| `operational_practice` | A procedure for running something in production | `{"type":"object"}` |
| `research_direction` | A cautious research direction stated by a speaker/author; never a fact | `{"type":"object"}` |
| `security_consideration` | A threat and its mitigation | `{"type":"object"}` |
| `setup_guide_step` | A setup or development-guide step with exact commands and versions | `{"type":"object"}` |
| `solution_pattern` | A mechanism that solves a problem, with trade-offs | `{"type":"object"}` |
| `technical_problem` | A problem engineers hit, with symptoms and context of occurrence | `{"type":"object"}` |
