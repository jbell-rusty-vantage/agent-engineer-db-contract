import { readFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';

export function assertDisposableReset(config, args = []) {
  if (args.length) throw new Error('RESET_ARGUMENTS_NOT_ALLOWED: this command never accepts remote targets or overrides.');
  const matches = [...config.matchAll(/^project_id\s*=\s*"([^"\r\n]+)"\s*$/gm)];
  if (matches.length !== 1 || !/^(?:vfy|disposable)-[a-z0-9][a-z0-9-]{5,63}$/.test(matches[0][1])) {
    throw new Error('SHARED_DATABASE_RESET_REFUSED: use db:migrate for the populated shared project. Prove fresh migrations in a separate disposable workspace; preserve its evidence and volume.');
  }
  return matches[0][1];
}

const repository = fileURLToPath(new URL('../', import.meta.url));
if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    assertDisposableReset(readFileSync(resolve(repository, 'supabase/config.toml'), 'utf8'), process.argv.slice(2));
    const result = spawnSync(process.platform === 'win32' ? 'supabase.exe' : 'supabase', ['db', 'reset', '--local'], { cwd: repository, stdio: 'inherit', windowsHide: true });
    process.exitCode = result.error ? 1 : result.status ?? 1;
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
