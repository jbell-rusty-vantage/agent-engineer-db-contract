import { test } from 'node:test';
import assert from 'node:assert/strict';
import { assertDisposableReset } from './reset-disposable-local.mjs';

test('shared, missing, duplicate and malformed identities fail closed', () => {
  for (const config of ['', 'project_id = "aiengineer"', 'project_id = "vfy-test123"\nproject_id = "aiengineer"', 'project_id = "vfy-../shared"']) assert.throws(() => assertDisposableReset(config), /SHARED_DATABASE_RESET_REFUSED/);
});
test('only an explicit disposable identity passes the configuration guard', () => {
  assert.equal(assertDisposableReset('project_id = "vfy-test123"'), 'vfy-test123');
});
test('remote and override arguments are refused even for disposable identities', () => {
  for (const args of [['--linked'], ['--db-url', 'postgres://example'], ['--yes']]) assert.throws(() => assertDisposableReset('project_id = "vfy-test123"', args), /RESET_ARGUMENTS_NOT_ALLOWED/);
});
