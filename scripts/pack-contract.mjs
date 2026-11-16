#!/usr/bin/env node
// Packs the contract for a consumer that vendors a tarball (Knowledge Services: vendor/aiengineer-database-contract-<version>.tgz).
//
//   node scripts/pack-contract.mjs [--out <git-ignored directory>]      default: .scratch/release
//
// 1. Refuses unless the version identifies the chain (scripts/check-contract-version.mjs).
// 2. Stages package.json, README.md and the paths named in package.json `files`, with CRLF folded to LF in text files, so
//    a Windows working copy and a Linux checkout pack the same migration bytes (.gitattributes stores them as LF).
// 3. Runs `pnpm pack` on the staged copy and prints the tarball's name, path, size and sha256 (JSON on stdout).
// Tarballs are never tracked (*.tgz is ignored); the output directory must be ignored too.
import { execFileSync, spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import { copyFileSync, existsSync, mkdirSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from "node:fs";
import { dirname, extname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { checkContractVersion } from "./check-contract-version.mjs";

const repository = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const TEXT = new Set([".sql", ".ts", ".json", ".md", ".mjs", ".toml", ".yml", ".yaml", ".txt"]);
const option = (name) => { const index = process.argv.indexOf(`--${name}`); return index >= 0 ? process.argv[index + 1] : undefined; };

function stage(source, destination) {
  if (statSync(source).isDirectory()) {
    mkdirSync(destination, { recursive: true });
    let count = 0;
    for (const name of readdirSync(source).sort()) count += stage(join(source, name), join(destination, name));
    return count;
  }
  mkdirSync(dirname(destination), { recursive: true });
  if (TEXT.has(extname(source))) writeFileSync(destination, readFileSync(source, "utf8").replaceAll("\r\n", "\n"));
  else copyFileSync(source, destination);
  return 1;
}

const check = checkContractVersion(repository);
if (!check.ok) {
  process.stdout.write(`${JSON.stringify({ status: "refused", code: "CONTRACT_VERSION_STALE", problems: check.problems }, null, 2)}\n`);
  process.exit(2);
}
const out = resolve(option("out") ?? join(repository, ".scratch", "release"));
try {
  execFileSync("git", ["check-ignore", "-q", join(out, "x.tgz")], { cwd: repository, windowsHide: true });
} catch {
  process.stdout.write(`${JSON.stringify({ status: "refused", code: "OUTPUT_NOT_IGNORED", detail: relative(repository, out) })}\n`);
  process.exit(2);
}
const pkg = JSON.parse(readFileSync(join(repository, "package.json"), "utf8"));
const staging = join(out, `stage-${pkg.version}`);
rmSync(staging, { recursive: true, force: true });
mkdirSync(staging, { recursive: true });
let files = 0;
for (const path of ["package.json", "README.md", ...pkg.files]) {
  if (existsSync(join(repository, path))) files += stage(join(repository, path), join(staging, path));
}
// .cmd shims need a shell on Windows; the arguments are fixed flags and a path this script made.
const packed = spawnSync(`pnpm pack --pack-destination "${out}"`, { cwd: staging, encoding: "utf8", shell: true, windowsHide: true });
if (packed.status !== 0) {
  process.stderr.write(`pnpm pack exited ${packed.status}: ${(packed.stderr || packed.stdout || "").slice(-600)}\n`);
  process.exit(1);
}
rmSync(staging, { recursive: true, force: true });
const name = `${pkg.name.replace(/^@/, "").replace("/", "-")}-${pkg.version}.tgz`;
const tarball = join(out, name);
const bytes = readFileSync(tarball);
process.stdout.write(`${JSON.stringify({
  status: "packed", file: name, path: tarball, bytes: bytes.length, sha256: createHash("sha256").update(bytes).digest("hex"),
  version: pkg.version, migration_head: check.recorded.migration_head, migrations: check.recorded.migrations, staged_files: files,
}, null, 2)}\n`);
