// Sprint V SV-08: two real sessions submit the same admitted effect concurrently; exactly one component effect receipt,
// one native operation intent/receipt and one committed admission survive (design section 9, M05/K05).
//
// DISPOSABLE databases only. Usage (from the repository root):
//   node supabase/tests/research_report_v2_concurrency.mjs --admin-dsn-env <NAME>
// The DSN is read from the NAMED environment variable and never printed; it must point at loopback port 54322.
// Fixtures are committed under a fresh random tenant (append-only component tables cannot be cleaned up).
import { randomUUID, createHash } from "node:crypto";
import pg from "pg";
import { canonicalJson, sealFixture, testSealKey } from "./research_report_v2_seal_fixture.mjs";

const nameIndex = process.argv.indexOf("--admin-dsn-env");
const dsn = nameIndex > 0 ? process.env[process.argv[nameIndex + 1]] : undefined;
if (!dsn) throw new Error("ADMIN_DSN_ENV_REQUIRED");
const url = new URL(dsn);
if (!["127.0.0.1", "localhost"].includes(url.hostname) || url.port !== "54322") throw new Error("DISPOSABLE_LOOPBACK_54322_REQUIRED");

const d = (text) => `sha256:${createHash("sha256").update(text, "utf8").digest("hex")}`;
const tenant = randomUUID();
const run = randomUUID();
const effectKey = `effect-${tenant.slice(0, 8)}`;
const bound = d(`bound-${tenant}`);
const decision = `ud-${tenant.slice(0, 8)}`;
const idempotencyKey = `sv08-concurrency-${tenant}`;
const receiptDigest = d(`receipt-${tenant}`);
const normalizedValues = '{"value":42}';
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function connect(name) {
  const client = new pg.Client({ connectionString: dsn, application_name: name });
  await client.connect();
  return client;
}

async function fixtures(admin) {
  await admin.query("begin");
  await admin.query("select set_config('app.tenant_id', $1, true)", [tenant]);
  await admin.query(
    "insert into knowledge_verification.origin (tenant_id, origin_digest, kind, installation_id, application_id, issuer, subject, identity) values ($1,$2,'standalone','sv08','ai-engineer','sv08-test-issuer','sv08','{}')",
    [tenant, d("origin")],
  );
  await admin.query(
    "insert into knowledge_verification.verification_task (tenant_id, task_id, schema_version, task_digest, original_task_ref, use_name, audience, minimum_risk, rubric_ref, policy_ref, body) values ($1,'task','research-core.task.v2',$2,'{}','publish','internal','low','rubric','policy','{}')",
    [tenant, d("task")],
  );
  await admin.query(
    "insert into knowledge_verification.verification_run (tenant_id, run_id, task_id, binding, originating_origin_digest) values ($1,$2,'task','aiengineer-postgres',$3)",
    [tenant, run, d("origin")],
  );
  for (const [id, text] of [["sb", "{}"], ["body", "# body"], ["ledger", "[]"]]) {
    const bytes = Buffer.from(`${text} ${tenant}`, "utf8");
    await admin.query(
      "insert into knowledge_verification.artifact_custody (tenant_id, artifact_id, digest, byte_length, media_type, custody_kind, inline_bytes) values ($1,$2,$3,$4,'text/plain','inline',$5)",
      [tenant, id, `sha256:${createHash("sha256").update(bytes).digest("hex")}`, bytes.length, bytes],
    );
  }
  await admin.query(
    `insert into knowledge_verification.report_revision (tenant_id, report_revision_id, report_id, revision, schema_version, report_kind, task_id, run_id,
       structured_body_artifact_id, body_artifact_id, ledger_artifact_id, body_digest, renderer_version, assertion_refs, time_coverage, record, digest)
     select $1, 'rr', 'report', 1, 'research-report.v2', 'evidence_report', 'task', $2, 'sb', 'body', 'ledger', a.digest, 'renderer:1', '[]', '{}',
            jsonb_build_object('kind', jsonb_build_object('kind','report_kind','id','evidence_report@1.0.0','version','research-report-kind.v1','digest',$3::text)), $4
       from knowledge_verification.artifact_custody a where a.tenant_id = $1 and a.artifact_id = 'body'`,
    [tenant, run, d("kind"), d("rr")],
  );
  // Component 2.2.0: pinned TEST-ONLY Ed25519 key, signed verification snapshot (12-argument seal_run).
  const key = testSealKey("sv08-test-key-concurrency");
  await admin.query(
    "insert into knowledge_verification.seal_signing_key (key_id, algorithm, public_key, status, issuer) values ($1,'Ed25519',$2,'active','sv08-test') on conflict (key_id) do nothing",
    [key.keyId, Buffer.from(key.publicKeyHex, "hex")],
  );
  const seal = sealFixture(key, run);
  await admin.query(
    "select knowledge_verification.seal_run($1,$2::uuid,null,'verification_snapshot',$3::jsonb,$4,$5::jsonb,$6,'Ed25519',$7,$8,$9::jsonb)",
    [tenant, run, seal.manifestCanonical, seal.manifestDigest, JSON.stringify(seal.familyRefs), seal.signer, key.keyId,
      Buffer.from(seal.signatureHex, "hex"), canonicalJson(seal.context)],
  );
  await admin.query("select knowledge_verification.bind_effect($1,$2,$3,$4,$5)", [tenant, effectKey, d("payload"), d("origin"), bound]);
  await admin.query(
    `insert into knowledge_verification.use_decision (tenant_id, use_decision_id, schema_version, subject_kind, subject_id, subject_digest, run_id, bound_effect_digest,
       use_name, audience, disposition, policy_ref, rubric_ref, qualifiers_digest, revocation_epoch, record, digest, normalized_values, normalized_values_digest)
     values ($1,$2,'research-core.use_decision.v2','report','rr',$3,$4,$5,'publish','internal','admitted','policy','rubric',null,0,
             jsonb_build_object('report', jsonb_build_object('id','rr'), 'normalizedValues', $6::jsonb),$7,$6::jsonb,$8)`,
    [tenant, decision, d("rr"), run, bound, normalizedValues, d(decision), d(normalizedValues)],
  );
  // The epoch row exists before the race, so the sessions contend on the effect receipt, not on epoch initialization.
  await admin.query("insert into knowledge_verification.revocation_epoch (tenant_id, epoch, reason) values ($1, 0, 'initial')", [tenant]);
  await admin.query("commit");
}

/** One native ingestion transaction: admission guard, component effect receipt, native intent + receipt. */
async function submit(client, label, hold) {
  await client.query("begin");
  await client.query("set local role executor_service");
  await client.query("select set_config('app.tenant_id', $1, true)", [tenant]);
  await client.query("select research.assert_admitted_use($1,$2,$3,0,$4)", [tenant, decision, bound, d(normalizedValues)]);
  const receipt = await client.query(
    "select digest from knowledge_verification.record_effect_receipt($1,$2,'applied','{}','[]',null,null,0,'[]',$3,$4)",
    [tenant, effectKey, decision, receiptDigest],
  );
  try {
    const intentId = randomUUID();
    await client.query(
      "insert into orchestration.operation_intent (id, tenant_id, intent_type, payload, idempotency_key, approval_state) values ($1,$2,'verify_claim','{}',$3,'approved')",
      [intentId, tenant, idempotencyKey],
    );
    const receiptId = randomUUID();
    await client.query(
      "insert into orchestration.operation_receipt (id, intent_id, executor_version, outcome, requires_admission, use_decision_id, bound_effect_digest) values ($1,$2,'sv08-test','applied',true,$3,$4)",
      [receiptId, intentId, decision, bound],
    );
    if (hold) await hold();
    await client.query("commit");
    return { label, committed: true, effectReceiptDigest: receipt.rows[0].digest, receiptId };
  } catch (error) {
    await client.query("rollback");
    if (error.code !== "23505") throw error;
    // Loser: return the winner's receipt (the KS executor's awaitWinner path).
    await client.query("begin");
    await client.query("set local role executor_service");
    await client.query("select set_config('app.tenant_id', $1, true)", [tenant]);
    const winner = await client.query(
      "select r.id from orchestration.operation_intent i join orchestration.operation_receipt r on r.intent_id = i.id where i.tenant_id = $1 and i.idempotency_key = $2",
      [tenant, idempotencyKey],
    );
    await client.query("commit");
    return { label, committed: false, sqlstate: error.code, effectReceiptDigest: receipt.rows[0].digest, winnerReceiptId: winner.rows[0]?.id };
  }
}

const started = Date.now();
const admin = await connect("sv08-admin");
const a = await connect("sv08-session-a");
const b = await connect("sv08-session-b");
try {
  await fixtures(admin);
  const bPid = (await b.query("select pg_backend_pid() pid")).rows[0].pid;
  let bWaited = null;
  let bPromise;
  const resultA = await submit(a, "A", async () => {
    // A holds its uncommitted effect receipt and native receipt while B runs the same submission.
    bPromise = submit(b, "B", null);
    for (let i = 0; i < 50 && !bWaited; i += 1) {
      await sleep(100);
      const w = await admin.query("select wait_event_type, wait_event, state from pg_stat_activity where pid = $1", [bPid]);
      if (w.rows[0]?.wait_event_type === "Lock") bWaited = w.rows[0];
    }
  });
  const resultB = await bPromise;
  await admin.query("begin");
  await admin.query("select set_config('app.tenant_id', $1, true)", [tenant]);
  const counts = (
    await admin.query(
      `select (select count(*) from knowledge_verification.effect_receipt where tenant_id = $1 and effect_key = $2)::int effect_receipts,
              (select count(*) from orchestration.operation_intent where tenant_id = $1 and idempotency_key = $3)::int intents,
              (select count(*) from orchestration.operation_receipt r join orchestration.operation_intent i on i.id = r.intent_id
                where i.tenant_id = $1 and i.idempotency_key = $3)::int native_receipts,
              (select count(*) from research.use_admission where tenant_id = $1 and use_decision_id = $4)::int admissions`,
      [tenant, effectKey, idempotencyKey, decision],
    )
  ).rows[0];
  await admin.query("commit");
  const pass =
    bWaited !== null &&
    resultA.committed &&
    !resultB.committed &&
    resultB.sqlstate === "23505" &&
    resultB.winnerReceiptId === resultA.receiptId &&
    resultA.effectReceiptDigest === resultB.effectReceiptDigest &&
    counts.effect_receipts === 1 &&
    counts.intents === 1 &&
    counts.native_receipts === 1 &&
    counts.admissions === 1;
  console.log(
    JSON.stringify(
      { test: "same-key concurrent admission", pass, sessionBBlockedOn: bWaited, resultA, resultB, counts, elapsedMs: Date.now() - started },
      null,
      2,
    ),
  );
  process.exitCode = pass ? 0 : 1;
} finally {
  await Promise.allSettled([admin.end(), a.end(), b.end()]);
}
