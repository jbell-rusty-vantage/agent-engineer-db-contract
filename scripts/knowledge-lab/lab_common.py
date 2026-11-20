"""Shared helpers for the Build 08 knowledge loop lab (disposable-aieng-build04 only).

Everything here talks to the lab database through `docker exec ... psql` as postgres (the same path run_lab.py uses),
reads one vendor key by name from BellLabs/.secrets/models.env without ever printing it, and fetches public pages with plain
HTTPS. Captures are data, not instructions. Nothing here touches a remote project.
"""
import hashlib, json, os, re, subprocess, sys, time, urllib.request, urllib.error, uuid, datetime

LAB = os.environ.get("KNOWLEDGE_LAB_WORKDIR", r"C:\Users\Pinda\Proyectos\BellLabs\platform\ai-engineer-research-2026-11-02\lab")
CONTAINER = "supabase_db_disposable-aieng-build04"
TENANT = "00000000-0000-7000-8000-000000000001"
SECRETS = r"C:\Users\Pinda\Proyectos\BellLabs\.secrets\models.env"
SOURCES_DIR = os.path.join(LAB, "sources", "2026-11-08")
BUILD07_SOURCES = os.path.join(LAB, "sources", "2026-11-05")
RUN_DIR = os.path.join(LAB, "..", "schema-units", "provenance", "evidence", "B08-loop-1")
USER_AGENT = "aieng-knowledge-lab/0.1 (BellLabs research lab; plain HTTPS GET; not a crawler)"
os.makedirs(SOURCES_DIR, exist_ok=True)
os.makedirs(RUN_DIR, exist_ok=True)

SPEND = {"firecrawl_credits": 0, "openai_embedding_tokens": 0, "openai_embedding_usd": 0.0, "http_fetches": 0, "notes": []}


def now_iso():
    return datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def sha256_bytes(b):
    return hashlib.sha256(b).hexdigest()


def sha256_text(t):
    return hashlib.sha256(t.encode("utf-8")).hexdigest()


def q(v):
    """SQL literal."""
    if v is None:
        return "null"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return repr(v)
    if isinstance(v, (dict, list)):
        return "'" + json.dumps(v, ensure_ascii=False).replace("'", "''") + "'::jsonb"
    return "'" + str(v).replace("'", "''") + "'"


def qarr(values, typ="text"):
    if not values:
        return "'{}'::%s[]" % typ
    return "array[" + ",".join(q(v) for v in values) + "]::%s[]" % typ


def sql(statement, allow_error=False, tenant=True):
    """Run SQL as postgres in one transaction; returns stdout (tab-separated, -At)."""
    # one call = one transaction (multi-statement helpers and `set local role` rely on it); Batch.commit manages its own with tenant=False
    statement = statement.rstrip()
    if not statement.endswith(";"):
        statement += ";"
    body = f"begin;\nset local app.tenant_id = '{TENANT}';\n{statement}\ncommit;" if tenant else statement
    p = subprocess.run(["docker", "exec", "-i", CONTAINER, "psql", "-X", "-U", "postgres", "-d", "postgres", "-At", "-F", "	", "-v", "ON_ERROR_STOP=1", "-q"],
                       input=body, capture_output=True, text=True, encoding="utf-8")
    if p.returncode != 0:
        if allow_error:
            return None, p.stderr.strip()
        raise RuntimeError(p.stderr.strip()[:4000] + "\n--- statement head ---\n" + statement[:1500])
    return p.stdout.strip(), None


def sql_rows(statement):
    out, _ = sql(statement)
    return [line.split("\t") for line in out.splitlines() if line != ""]


def sql_json(statement):
    """statement must produce one column of json text per row."""
    return [json.loads(r[0]) for r in sql_rows(statement)]


def one(statement):
    rows = sql_rows(statement)
    return rows[0][0] if rows and rows[0] else None


GOVERNED_ROLES = ("pipeline_agent", "verifier_agent", "control_plane", "executor_service")


def governed(function, args, role="pipeline_agent", actor=None, dry_run=False):
    """One governed write of the verification chain (migration 20261116130000): api.<function> called as a bounded role, never
    as postgres. The tenant is set for the transaction, the role is switched with `set local role`, `args` are the function's
    named arguments (the idempotency key included) and `actor` its p_actor. Returns the function's JSON result; a refusal
    raises with the function's error code in the message. dry_run rolls the transaction back and still returns the result."""
    if role not in GOVERNED_ROLES or not re.fullmatch(r"[a-z_]+", function):
        raise ValueError(f"not a governed call: {role} api.{function}")
    named = dict(args, p_actor=actor) if actor is not None else dict(args)
    call = ", ".join(f"{k} => {q(v)}" for k, v in named.items())
    out, _ = sql(f"begin;\nset local app.tenant_id = '{TENANT}';\nset local role {role};\nselect api.{function}({call});\n{'rollback' if dry_run else 'commit'};",
                 tenant=False)
    return json.loads(out.splitlines()[-1])


def load_secret(name):
    for line in open(SECRETS, encoding="utf-8"):
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, v = line.split("=", 1)
            if k.strip() == name:
                return v.strip().strip('"').strip("'")
    raise RuntimeError(f"{name} not present in models.env")


def http_get(url, accept=None, timeout=90):
    headers = {"User-Agent": USER_AGENT}
    if accept:
        headers["Accept"] = accept
    req = urllib.request.Request(url, headers=headers)
    t0 = time.time()
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            body = r.read()
            SPEND["http_fetches"] += 1
            return {"status": r.status, "final_url": r.geturl(), "media_type": (r.headers.get("content-type") or "").split(";")[0].strip(), "body": body, "elapsed_ms": int((time.time() - t0) * 1000)}
    except urllib.error.HTTPError as e:
        return {"status": e.code, "final_url": url, "media_type": None, "body": e.read(), "elapsed_ms": int((time.time() - t0) * 1000), "error": str(e)}


def write_json(path, obj):
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(obj, f, indent=1, ensure_ascii=False)


def append_jsonl(path, obj):
    with open(path, "a", encoding="utf-8", newline="\n") as f:
        f.write(json.dumps(obj, ensure_ascii=False) + "\n")


def log(msg):
    print(f"[{now_iso()}] {msg}", flush=True)


def embed_texts(texts, model="text-embedding-3-small", dims=1536):
    """OpenAI embeddings in batches; returns list of float lists. Cost tracked (USD 0.02 per 1M tokens, Nov 2026 list price)."""
    key = load_secret("OPENAI_EMBEDDING_API_KEY")
    out = []
    for i in range(0, len(texts), 96):
        batch = [t[:6000] for t in texts[i:i + 96]]
        req = urllib.request.Request("https://api.openai.com/v1/embeddings", data=json.dumps({"model": model, "input": batch, "dimensions": dims}).encode(),
                                     headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"})
        for attempt in range(4):
            try:
                with urllib.request.urlopen(req, timeout=120) as r:
                    d = json.loads(r.read())
                break
            except urllib.error.HTTPError as e:
                if e.code in (429, 500, 502, 503) and attempt < 3:
                    time.sleep(2 ** attempt)
                    continue
                raise
        toks = d.get("usage", {}).get("total_tokens", 0)
        SPEND["openai_embedding_tokens"] += toks
        SPEND["openai_embedding_usd"] += toks * 0.02 / 1_000_000
        out.extend([row["embedding"] for row in sorted(d["data"], key=lambda x: x["index"])])
    return out


def vec_literal(vector):
    return "[" + ",".join(f"{x:.6f}" for x in vector) + "]"


# ------------------------------------------------------------------ receipts (native harness origin, labelled truthfully)
def native_receipt(label, payload):
    """One orchestration intent + receipt for a lab write batch. Origin is standalone (no Mission Control mission)."""
    digest = "sha256:" + sha256_text(label + json.dumps(payload, sort_keys=True))
    intent = str(uuid.uuid4())
    receipt = str(uuid.uuid4())
    sql(f"""
insert into orchestration.operation_intent(id, tenant_id, intent_type, schema_version, payload, preconditions, idempotency_key, approval_state, origin_digest, origin_kind)
values ({q(intent)}, {q(TENANT)}, 'knowledge_ingestion', 1,
        {q(dict(payload, harness='claude-code native harness (Build 08 knowledge loop 1)', label=label, mission=None))}, '[]'::jsonb, {q('b08-' + label + '-' + intent[:8])}, 'approved', {q(digest)}, 'standalone');
insert into orchestration.operation_receipt(id, intent_id, executor_version, precondition_results, outcome, changes_summary, affected_refs, requires_admission, origin_digest)
values ({q(receipt)}, {q(intent)}, 'knowledge-lab/loop1', '[]'::jsonb, 'applied', {q({'label': label})}, '[]'::jsonb, false, {q(digest)});
""")
    return receipt


class Batch:
    """Collects temporal.* assertions and commits them in ONE transaction (begin_batch ... commit_batch)."""

    def __init__(self, label, payload=None):
        self.label = label
        self.payload = payload or {}
        self.statements = []
        self.receipt = None

    def add(self, statement):
        if statement in self.statements:  # the same assertion twice in one batch would read as an overlapping assertion
            return
        self.statements.append(statement)

    def commit(self):
        if not self.statements:
            return None
        body = "\n".join(self.statements)
        digest = sha256_text(body)
        if one(f"select 1 from temporal.knowledge_batch where idempotency_key = {q('b08-' + self.label + '-' + digest[:12])}"):
            return "already admitted (same statements, same idempotency key)"
        self.receipt = native_receipt(self.label, self.payload)
        out, _ = sql(f"""
begin;
set local app.tenant_id = '{TENANT}';
select temporal.begin_batch();
{body}
select temporal.commit_batch({q(self.receipt)}, {q('b08-' + self.label + '-' + digest[:12])}, {q(digest)}, {q({'label': self.label, 'statements': len(self.statements)})});
commit;
""", tenant=False)
        return out
