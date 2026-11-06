export const PROVENANCE_BUCKET = "ai-engineer-project-provenance" as const;

export const PROVENANCE_OBJECT_KINDS = [
  "conversation",
  "architecture_doc",
  "adr",
  "spec",
  "feature",
  "issue",
  "pr",
] as const;

export const PROVENANCE_EDGE_KINDS = [
  "informed_by",
  "derived_from",
  "supersedes",
] as const;

export const PROVENANCE_BINDING_SYSTEMS = [
  "linear",
  "github",
  "cursor_local",
  "cursor_cloud",
] as const;

export type ProvenanceObjectKind = (typeof PROVENANCE_OBJECT_KINDS)[number];
export type ProvenanceEdgeKind = (typeof PROVENANCE_EDGE_KINDS)[number];
export type ProvenanceBindingSystem =
  (typeof PROVENANCE_BINDING_SYSTEMS)[number];

export function provenanceCasPath(sha256: string): string {
  const digest = sha256.trim().toLowerCase();
  if (!/^[0-9a-f]{64}$/.test(digest)) {
    throw new Error("sha256 must be 64 lowercase hex characters");
  }
  return `cas/sha256/${digest.slice(0, 2)}/${digest}`;
}
