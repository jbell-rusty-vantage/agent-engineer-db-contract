import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

const repositoryRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..", "..");

/** Loads workspace.config.json and package.json; resolves every configured path against the repo root. */
export function loadConfig(overrides = {}) {
  const raw = JSON.parse(readFileSync(path.join(repositoryRoot, "workspace.config.json"), "utf8"));
  const pkg = JSON.parse(readFileSync(path.join(repositoryRoot, "package.json"), "utf8"));
  const resolvePath = (relativePath) => path.resolve(repositoryRoot, relativePath);
  return {
    ...raw,
    repositoryRoot,
    contractVersion: pkg.version,
    allRoles: [...raw.roles.bounded, ...raw.roles.platform],
    paths: {
      generatedTypes: resolvePath(raw.paths.generatedTypes),
      migrations: resolvePath(raw.paths.migrations),
      enrichment: resolvePath(overrides.enrichment ?? raw.paths.enrichment),
      workspace: resolvePath(overrides.workspace ?? raw.paths.workspace),
      scopes: resolvePath(raw.paths.scopes),
    },
  };
}
