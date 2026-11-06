import { existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, renameSync, rmSync, statSync, writeFileSync } from "node:fs";
import path from "node:path";

/** Writes a `Map<posixPath, content>` as a directory tree, replacing `targetDir` atomically. */
export function writeTree(targetDir, files) {
  const parent = path.dirname(targetDir);
  mkdirSync(parent, { recursive: true });
  const staging = mkdtempSync(path.join(parent, `.${path.basename(targetDir)}-build-`));
  try {
    for (const [relativePath, content] of files) {
      const absolute = path.join(staging, ...relativePath.split("/"));
      mkdirSync(path.dirname(absolute), { recursive: true });
      writeFileSync(absolute, content, "utf8");
    }
    const previous = `${targetDir}.previous`;
    rmSync(previous, { recursive: true, force: true });
    if (existsSync(targetDir)) renameSync(targetDir, previous);
    renameSync(staging, targetDir);
    rmSync(previous, { recursive: true, force: true });
  } catch (error) {
    rmSync(staging, { recursive: true, force: true });
    throw error;
  }
}

/** Reads a directory tree back into a `Map<posixPath, content>`. */
export function readTree(rootDir) {
  const files = new Map();
  const visit = (directory) => {
    for (const entry of readdirSync(directory, { withFileTypes: true }).sort((a, b) => (a.name < b.name ? -1 : 1))) {
      const absolute = path.join(directory, entry.name);
      if (entry.isDirectory()) visit(absolute);
      else if (statSync(absolute).isFile()) files.set(path.relative(rootDir, absolute).replaceAll("\\", "/"), readFileSync(absolute, "utf8"));
    }
  };
  if (existsSync(rootDir)) visit(rootDir);
  return files;
}
