// Sprint V SV-08: deterministic Ed25519 seal fixtures for the AIDB SQL suites over knowledge_verification 2.2.0.
// The component's seal_run checks key/algorithm/length/context; the signature itself is verified by the KS binding.
// These fixtures are real signatures over research-core `sealSigningBytes` = K01 canonical JSON of
// {keyId, manifestDigest, signedAt, signer}, made with a fixed TEST-ONLY seed (never a production key).
//
//   node supabase/tests/research_report_v2_seal_fixture.mjs            -> prints the values embedded in research_report_v2_projection.sql
//   import { testSealKey, sealFixture } from "./research_report_v2_seal_fixture.mjs"  (used by the concurrency proof)
import { createHash, createPrivateKey, createPublicKey, sign, verify } from "node:crypto";
import { fileURLToPath } from "node:url";

const SEED = createHash("sha256").update("sv08-aidb-seal-fixture (test only)", "utf8").digest();
const PKCS8_ED25519_PREFIX = Buffer.from("302e020100300506032b657004220420", "hex");

/** Compact JSON with keys sorted by UTF-16 code units (K01 canonical form for the ASCII-only fixture values). */
export function canonicalJson(value) {
  if (value === null || typeof value !== "object") return JSON.stringify(value);
  if (Array.isArray(value)) return `[${value.map(canonicalJson).join(",")}]`;
  return `{${Object.keys(value).sort().map((key) => `${JSON.stringify(key)}:${canonicalJson(value[key])}`).join(",")}}`;
}
export const digest = (text) => `sha256:${createHash("sha256").update(text, "utf8").digest("hex")}`;

export function testSealKey(keyId) {
  const privateKey = createPrivateKey({ key: Buffer.concat([PKCS8_ED25519_PREFIX, SEED]), format: "der", type: "pkcs8" });
  const publicKey = createPublicKey(privateKey);
  const raw = publicKey.export({ format: "der", type: "spki" }).subarray(-32);
  return { keyId, privateKey, publicKey, publicKeyHex: raw.toString("hex") };
}

/** A verification_snapshot manifest for `runId` with its canonical digest and detached seal. */
export function sealFixture(key, runId, { signer = "signer:sv08", signedAt = "2026-10-25T00:00:00Z" } = {}) {
  const manifest = {
    snapshot: "verification_snapshot",
    run: { id: runId },
    predecessor: null,
    families: { capture: "capture-family", claims: "claims-family", report: "report-family", observations: "observations-family" },
  };
  const manifestCanonical = canonicalJson(manifest);
  const manifestDigest = digest(manifestCanonical);
  const context = { keyId: key.keyId, manifestDigest, signedAt, signer };
  const signingBytes = Buffer.from(canonicalJson(context), "utf8");
  const signature = sign(null, signingBytes, key.privateKey);
  if (!verify(null, signingBytes, key.publicKey, signature) || signature.length !== 64) throw new Error("FIXTURE_SIGNATURE_INVALID");
  return { manifest, manifestCanonical, manifestDigest, context, signer, signatureHex: signature.toString("hex"), familyRefs: manifest.families };
}

if (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1]) {
  const key = testSealKey("sv08-test-key-sql");
  const out = { keyId: key.keyId, publicKeyHex: key.publicKeyHex, runs: {} };
  for (const runId of ["00000000-0000-7000-8000-00000000a001", "00000000-0000-7000-8000-00000000a002"]) {
    const f = sealFixture(key, runId);
    out.runs[runId] = { manifest: f.manifestCanonical, manifestDigest: f.manifestDigest, context: canonicalJson(f.context), signatureHex: f.signatureHex };
  }
  console.log(JSON.stringify(out, null, 2));
}
