---
id: "voc:temporal.correction_reason"
kind: vocabulary
schema: temporal
name: correction_reason
rows: 9
rows_sha256: "sha256:361f3c84b1869477e96a2aa4a8c6d9f7f5c271f591032d65a5bbd5ff7d6445f7"
codes: [better_source, duplicate_record, late_evidence, merge_undone, misread, mixed_record, not_recorded, source_corrected, wrong_entity]
workspace_fingerprint: "sha256:db20bac4d9e82d9b94cd2f3b580d4c145bcc3820969fdd572c6e7868ecca53fd"
---
# temporal.correction_reason

Reference data snapshot (9 rows, digest `sha256:361f3c84b1869477e96a2aa4a8c6d9f7f5c271f591032d65a5bbd5ff7d6445f7`). Codes are enforced wherever a column has a foreign key to [`temporal.correction_reason`](../relations/temporal/correction_reason.md).

| code | applies_to | description |
| --- | --- | --- |
| `better_source` | fact, relationship | A more authoritative source disagrees |
| `duplicate_record` | fact, relationship, merge | Closed or moved because its record was merged into another |
| `late_evidence` | fact, relationship | The right value or date was learned later |
| `merge_undone` | fact, relationship | Moved back because a merge was undone |
| `misread` | fact, relationship | We extracted or parsed it wrongly |
| `mixed_record` | split | One record described several things |
| `not_recorded` | fact, relationship | A replacement made before reasons existed; set by backfill, refused on new writes |
| `source_corrected` | fact, relationship | The source corrected itself |
| `wrong_entity` | fact, relationship, split | It belonged to another entity |
