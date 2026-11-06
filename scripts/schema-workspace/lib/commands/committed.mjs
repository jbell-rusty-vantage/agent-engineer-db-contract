import { existsSync, readFileSync } from "node:fs";
import path from "node:path";
import { ErrorCode, WorkspaceError } from "../errors.mjs";
import { pages } from "../render/model.mjs";

/** Loads the committed full workspace's IR (with its enrichment) and fingerprint. */
export function loadCommittedWorkspace(config) {
  const irPath = path.join(config.paths.workspace, pages.ir);
  const fingerprintPath = path.join(config.paths.workspace, pages.fingerprint);
  if (!existsSync(irPath) || !existsSync(fingerprintPath)) {
    throw new WorkspaceError(ErrorCode.IO, `No committed workspace at ${config.paths.workspace}; run \`workspace:build\` first.`);
  }
  const ir = JSON.parse(readFileSync(irPath, "utf8"));
  const { enrichment, ...derived } = ir;
  return { ir: { ...derived, enrichment: null }, enrichment, fingerprint: JSON.parse(readFileSync(fingerprintPath, "utf8")) };
}
