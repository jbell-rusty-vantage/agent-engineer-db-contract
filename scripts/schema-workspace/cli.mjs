#!/usr/bin/env node
import { parseArgs } from "node:util";
import { runCheck } from "./lib/commands/check.mjs";
import { runBuild, runIntrospect, runValidate } from "./lib/commands/build.mjs";
import { runEnrichDraft } from "./lib/commands/enrich.mjs";
import { runMaterialize } from "./lib/commands/materialize.mjs";
import { ErrorCode, ExitCode, WorkspaceError } from "./lib/errors.mjs";

const USAGE = `schema-workspace <command> [options]

Commands
  introspect   --db-url <url> [--out <file>]                 derived schema-ir.v1 (JSON)
  build        [--db-url <url>] [--out <dir>] [--enrichment <dir>] [--dry-run]
  check        [--db-url <url>] [--workspace <dir>]          drift report vs committed fingerprint
  validate     [--workspace <dir>] [--db-url <url>]          re-validate the committed tree
  materialize  --scope <id|file> [--out <dir>] [--format tree|json-bundle] [--workspace <dir>]
  enrich       --draft <schema.relation | domain:slug>       YAML stub with ids pre-filled

Connection: --db-url or POSTGRES_URL. Errors are JSON on stderr. Exit: 0 ok, 1 domain outcome, 2 infrastructure.`;

const OPTIONS = {
  "db-url": { type: "string" },
  out: { type: "string" },
  enrichment: { type: "string" },
  workspace: { type: "string" },
  scope: { type: "string" },
  format: { type: "string" },
  draft: { type: "string" },
  "dry-run": { type: "boolean" },
  help: { type: "boolean", short: "h" },
};

const COMMANDS = {
  introspect: runIntrospect,
  build: runBuild,
  check: runCheck,
  validate: runValidate,
  materialize: runMaterialize,
  enrich: runEnrichDraft,
};

async function main(argv) {
  const { values, positionals } = parseArgs({ args: argv, options: OPTIONS, allowPositionals: true });
  const [command] = positionals;
  if (values.help || !command) {
    process.stdout.write(`${USAGE}\n`);
    return values.help ? ExitCode.OK : ExitCode.INFRASTRUCTURE;
  }
  const run = COMMANDS[command];
  if (!run) throw new WorkspaceError(ErrorCode.USAGE, `Unknown command "${command}".\n${USAGE}`);
  return run(values);
}

main(process.argv.slice(2))
  .then((exitCode) => process.exit(exitCode ?? ExitCode.OK))
  .catch((error) => {
    const payload = error instanceof WorkspaceError ? error.toJSON() : { code: ErrorCode.IO, message: error.message, stack: error.stack };
    process.stderr.write(`${JSON.stringify(payload, null, 2)}\n`);
    process.exit(error instanceof WorkspaceError ? error.exitCode : ExitCode.INFRASTRUCTURE);
  });
