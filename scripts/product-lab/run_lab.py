"""Product schema lab proof (Builds 01-07) on a disposable Supabase stack with real GoTrue, PostgREST and Storage.

Surfaces (PRODUCT_LAB_SURFACE):
  database  user calls go to the database functions through Supabase's generated REST endpoint (default)
  api       user calls go through the AI Engineer product API (PRODUCT_LAB_API_URL, aiengineer/ai-engineer-service);
            uploads and platform manifests are stored and verified by the API itself
In both modes this script also plays the worker role (grading, indexing, profiles) through `product_worker`.

Run: PRODUCT_LAB_WORKDIR=<lab workdir> python -I scripts/product-lab/run_lab.py. Writes <workdir>/tests/results-<surface>.json.
Never prints keys or tokens.
Fixtures are labelled: users are real Auth accounts created for this lab; course content, grades and embeddings are
synthetic test data, not research findings or model outputs.
"""
import hashlib, json, os, re, subprocess, sys, time, urllib.error, urllib.request, uuid

LAB = os.environ.get("PRODUCT_LAB_WORKDIR") or os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # disposable Supabase workdir
SB = r"C:\Users\Pinda\Proyectos\BellLabs\aiengineer\ai-engineer-db-contract\node_modules\.bin\supabase.CMD"
RESULTS = []
SURFACE = os.environ.get("PRODUCT_LAB_SURFACE", "database")
SERVICE_API = os.environ.get("PRODUCT_LAB_API_URL", "http://127.0.0.1:3200").rstrip("/")
assert SURFACE in ("database", "api"), SURFACE


def status_env():
    out = subprocess.run([SB, "status", "--workdir", LAB, "-o", "env"], capture_output=True, text=True, shell=False).stdout
    env = dict(re.findall(r'^([A-Z_]+)="(.*)"$', out, re.M))
    return env["API_URL"], env["ANON_KEY"], env["SERVICE_ROLE_KEY"]


API, ANON, SERVICE = status_env()


def http(method, path, body=None, token=None, key=None, headers=None, raw=None, ctype="application/json"):
    data = raw if raw is not None else (json.dumps(body).encode() if body is not None else None)
    h = {"apikey": key or ANON, "Content-Type": ctype}
    if token:
        h["Authorization"] = "Bearer " + token
    h.update(headers or {})
    req = urllib.request.Request(API + path, data=data, method=method, headers=h)
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            txt = r.read().decode()
            return r.status, (json.loads(txt) if txt else None)
    except urllib.error.HTTPError as e:
        txt = e.read().decode()
        try:
            return e.code, json.loads(txt)
        except Exception:
            return e.code, {"raw": txt[:300]}


def record(name, ok, detail=""):
    RESULTS.append({"check": name, "pass": bool(ok), "detail": detail})
    print(("PASS " if ok else "FAIL ") + name + (f" — {detail}" if detail and not ok else ""))


def skip(name, reason):
    RESULTS.append({"check": name, "pass": None, "detail": reason})
    print(f"SKIP {name} — {reason}")


API_STORES_MANIFESTS = "the API stores and verifies platform manifests itself, so this storage-boundary state cannot occur; proven on the database surface"


def service_api(path, body=None, token=None, client_token=None, raw=None, extra=None):
    headers = {"Content-Type": "application/octet-stream" if raw is not None else "application/json"}
    if token:
        headers["Authorization"] = "Bearer " + token
    if client_token:
        headers["x-aieng-client-token"] = client_token
    headers.update(extra or {})
    data = raw if raw is not None else json.dumps(body).encode()
    req = urllib.request.Request(SERVICE_API + path, data=data, method="POST", headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            txt = r.read().decode()
            return r.status, (json.loads(txt) if txt else None)
    except urllib.error.HTTPError as e:
        txt = e.read().decode()
        try:
            return e.code, json.loads(txt)
        except Exception:
            return e.code, {"raw": txt[:300]}


class User:
    def __init__(self, label):
        self.label = label
        self.email = f"{label}-{uuid.uuid4().hex[:8]}@lab.invalid"
        pw = uuid.uuid4().hex
        s, b = http("POST", "/auth/v1/admin/users", {"email": self.email, "password": pw, "email_confirm": True}, token=SERVICE, key=SERVICE)
        assert s in (200, 201), (s, b)
        self.id = b["id"]
        s, b = http("POST", "/auth/v1/token?grant_type=password", {"email": self.email, "password": pw})
        assert s == 200, (s, b)
        self.token = b["access_token"]
        self.client_token = None

    def cmd(self, ws, op, payload=None, head=None, key=None, client=False):
        if SURFACE == "api":
            return service_api(f"/v1/commands/{op}", {"workspaceId": ws, "idempotencyKey": key or ("k-" + uuid.uuid4().hex),
                               "expectedHead": head, "payload": payload or {}}, self.token, self.client_token if client else None)
        hdr = {"Content-Profile": "api"}
        if client and self.client_token:
            hdr["x-aieng-client-token"] = self.client_token
        return http("POST", "/rest/v1/rpc/product_command", {"p_workspace_id": ws, "p_operation": op, "p_idempotency_key": key or ("k-" + uuid.uuid4().hex),
                    "p_expected_head": head, "p_payload": payload or {}}, token=self.token, headers=hdr)

    def read(self, ws, op, payload=None, client=False):
        if SURFACE == "api":
            return service_api(f"/v1/reads/{op}", {"workspaceId": ws, "payload": payload or {}}, self.token, self.client_token if client else None)
        hdr = {"Content-Profile": "api"}
        if client and self.client_token:
            hdr["x-aieng-client-token"] = self.client_token
        return http("POST", "/rest/v1/rpc/product_read", {"p_workspace_id": ws, "p_operation": op, "p_payload": payload or {}}, token=self.token, headers=hdr)


def worker(op, payload):
    return http("POST", "/rest/v1/rpc/product_worker", {"p_operation": op, "p_payload": payload}, token=SERVICE, key=SERVICE, headers={"Content-Profile": "api"})


def ok(resp):
    s, b = resp
    if s != 200:
        raise AssertionError(f"{s} {b}")
    return b


def err(resp):
    s, b = resp
    return None if s == 200 else (b or {}).get("message")


def denied(resp):
    """Not readable: the database layer returns an empty result, the API maps it to NOT_FOUND."""
    s, b = resp
    return b is None if s == 200 else (b or {}).get("message") == "NOT_FOUND"


def upload(path, data, ctype="application/octet-stream"):
    return http("POST", f"/storage/v1/object/aieng-workspaces/{path}", raw=data, token=SERVICE, key=SERVICE, ctype=ctype)


def store_and_complete(object_path, artifact_id, data, ctype, upsert=False):
    if SURFACE == "api" and run_sql(f"select storage_state from orchestration.artifact where id='{artifact_id}'") == "available":
        return {"state": "available"}
    s, b = http("POST", f"/storage/v1/object/aieng-workspaces/{object_path}", raw=data, token=SERVICE, key=SERVICE, ctype=ctype,
                headers={"x-upsert": "true"} if upsert else None)
    assert s in (200, 201), (s, b)
    # worker readback: download the stored object with the worker credential and hash what Storage returns
    req = urllib.request.Request(f"{API}/storage/v1/object/authenticated/aieng-workspaces/{object_path}", headers={"apikey": SERVICE, "Authorization": "Bearer " + SERVICE})
    with urllib.request.urlopen(req, timeout=60) as r:
        readback = r.read()
    return ok(worker("complete_asset", {"artifact_id": artifact_id, "verified_sha256": hashlib.sha256(readback).hexdigest()}))


def asset(user, ws, data, ctype, usage, atype="authored_work_asset"):
    if SURFACE == "api":
        metadata = {"workspaceId": ws, "artifactType": atype, "mediaType": ctype, "usage": usage, "rightsBasis": "lab fixture authored for this test"}
        s, b = service_api("/v1/assets", token=user.token, raw=data, extra={"x-aieng-asset": json.dumps(metadata)})
        assert s == 201, (s, b)
        return b["artifactId"]
    r = ok(user.cmd(ws, "register_asset", {"artifact_type": atype, "sha256": hashlib.sha256(data).hexdigest(), "size_bytes": len(data),
                                            "media_type": ctype, "usage": usage, "rights_basis": "lab fixture authored for this test"}))
    store_and_complete(r["objectPath"], r["artifactId"], data, ctype)
    return r["artifactId"]


def body(md, metadata=None):
    return {"formatVersion": 1, "blocks": [{"id": str(uuid.uuid4()), "kind": "markdown", "content": {"text": md}}], "metadata": metadata or {}}


RULE = {"schema": "aieng.evidence-rule.v2", "observables": ["working retry wrapper", "explanation"], "facet": "assisted"}


# ---------------------------------------------------------------- J10 Build 07: research request, dataset, report, experience, reviewed change
SOURCES = os.environ.get("PRODUCT_LAB_SOURCES") or os.path.join(LAB, "sources", "2026-11-05")


class _Text(__import__("html.parser").parser.HTMLParser):
    """aieng html-text normalization for text-quote selectors: visible text, one line per block element."""
    def __init__(self):
        super().__init__()
        self.out, self.skip = [], 0

    def handle_starttag(self, tag, attrs):
        if tag in ("script", "style", "noscript", "svg"):
            self.skip += 1
        if tag in ("tr", "p", "li", "h1", "h2", "h3", "h4", "br", "div", "td", "th"):
            self.out.append(" | " if tag in ("td", "th") else "\n")

    def handle_endtag(self, tag):
        if tag in ("script", "style", "noscript", "svg") and self.skip:
            self.skip -= 1

    def handle_data(self, data):
        if not self.skip:
            self.out.append(data)


def normalized_lines(data, media_type):
    text = data.decode("utf-8", errors="replace")
    if media_type == "text/html":
        p = _Text()
        p.feed(text)
        import html as _html
        text = _html.unescape("".join(p.out))
    return [re.sub(r"[ \t ]+", " ", l).strip() for l in text.splitlines() if l.strip()]


def quotes_resolve(data, media_type, quotes):
    """Every quote is (a substring of) a normalized line, in document order."""
    lines, i = normalized_lines(data, media_type), 0
    for q in quotes:
        while i < len(lines) and q not in lines[i]:
            i += 1
        if i == len(lines):
            return False
        i += 1
    return True


def j10_research(john, outsider, ws):
    if not os.path.exists(os.path.join(SOURCES, "sources.json")):
        skip("J10 research journey", f"source set not present at {SOURCES}")
        return
    manifest = json.load(open(os.path.join(SOURCES, "sources.json"), encoding="utf-8"))
    def K():
        return str(uuid.uuid4())

    # 1. brief → proposal → acceptance (agent proposes through John's MCP grant; John accepts)
    research = {"schema": "aieng.research-brief.v1",
                "question": "How do frontier model API offerings compare on price per million tokens and context window?",
                "plan": ["Fetch each provider's public pricing page", "Build a provider/model pricing dataset with value-level support",
                         "Write a comparison report with findings and limitations", "Build an interactive comparison view"],
                "world": {"from": "2026-10-01T00:00:00Z", "to": "2026-11-01T00:00:00Z", "precision": "day"},
                "knowledge_policy": "latest_at_run", "budget_limit_usd": 0,
                "obligations": [{"key": "pricing-dataset", "form": "dataset", "enforcement": "required", "expected_work_kind": "dataset",
                                 "criteria": {"min_rows": 6, "fields": ["provider", "model", "input_usd_per_mtok", "output_usd_per_mtok"]}},
                                {"key": "comparison-report", "form": "report", "enforcement": "required", "expected_work_kind": "report"},
                                {"key": "comparison-view", "form": "experience", "enforcement": "expected", "expected_work_kind": "experience"}]}
    brief = ok(john.cmd(ws, "create_work", {"kind": "brief", "slug": "frontier-api-pricing", "revision": {"title": "Frontier model API pricing, October 2026",
        "body": {"formatVersion": 2, "blocks": [{"key": K(), "type": "text", "content": {"markdown": research["question"]}}], "metadata": {"research": dict(research, obligations=[])}}}}, client=True))
    bad = ok(john.cmd(ws, "propose_research", {"revision_id": brief["revisionId"]}, client=True))
    record("J10 a brief without output obligations is not a valid proposal", bad["valid"] is False and any("obligation" in p for p in bad["problems"]), str(bad["problems"]))
    brief2 = ok(john.cmd(ws, "revise_work", {"work_id": brief["workId"], "revision": {"title": "Frontier model API pricing, October 2026",
        "body": {"formatVersion": 2, "blocks": [{"key": K(), "type": "text", "content": {"markdown": research["question"]}}], "metadata": {"research": research}}}},
        head=brief["revisionId"], client=True))
    prop = ok(john.cmd(ws, "propose_research", {"revision_id": brief2["revisionId"]}, client=True))
    record("J10 the agent's revised brief validates as a proposal", prop["valid"] is True)
    record("J10 an agent cannot accept research scope or budget",
           err(john.cmd(ws, "accept_research", {"revision_id": brief2["revisionId"], "execution_origin": "native_harness"}, client=True)) == "FORBIDDEN")
    record("J10 an MC acceptance needs MC mission coordinates", err(john.cmd(ws, "accept_research", {"revision_id": brief2["revisionId"], "execution_origin": "mc"})) is not None)
    acc = ok(john.cmd(ws, "accept_research", {"revision_id": brief2["revisionId"], "execution_origin": "native_harness"}))
    ob = acc["obligations"]
    record("J10 John accepts the exact proposal: 3 obligations, $0 limit, native harness origin, October window",
           len(ob) == 3 and run_sql(f"select budget_limit_usd || ':' || execution_origin || ':' || world_precision || ':' || to_char(world_from at time zone 'UTC','YYYY-MM-DD') from inquiry.acceptance where id='{acc['acceptanceId']}'")
           == "0.00:native_harness:day:2026-10-01")
    record("J10 recorded spend over the limit is refused",
           err(john.cmd(ws, "set_acceptance_state", {"acceptance_id": acc["acceptanceId"], "state": "running", "spent_usd": 0.01}, client=True)) == "BUDGET_EXCEEDED")
    ok(john.cmd(ws, "set_acceptance_state", {"acceptance_id": acc["acceptanceId"], "state": "running", "spent_usd": 0}, client=True))

    # 2. sources: fetched public pages become private document works with their bytes in custody
    src = {}
    for s in manifest["sources"]:
        data = open(os.path.join(SOURCES, s["file"]), "rb").read()
        assert hashlib.sha256(data).hexdigest() == s["sha256"], s["file"]
        art = asset(john, ws, data, s["media_type"], "private_copy", atype="course_source_capture")
        doc = ok(john.cmd(ws, "create_work", {"kind": "document", "slug": "src-" + s["file"].split(".")[0], "revision": {"title": f"{s['publisher']} pricing ({s['final_url']})",
            "origin": "native_harness", "origin_ref": {"acceptance_id": acc["acceptanceId"], "fetch": s["method"]},
            "body": {"formatVersion": 2, "blocks": [], "metadata": {"source": {"schema": "aieng.fetched-source.v1", "url": s["url"], "final_url": s["final_url"],
                     "publisher": s["publisher"], "fetched_at": s["fetched_at"], "http_status": s["http_status"], "media_type": s["media_type"], "sha256": s["sha256"]}}},
            "bindings": [{"local_key": "original", "relation": "representation", "role": "original", "target": {"kind": "artifact", "id": art},
                          "usage": "private_copy", "rights_basis": "public page fetched for private research; original URL retained"}]}}, client=True))
        src[s["file"]] = {"rev": doc["revisionId"], "data": data, "media": s["media_type"], "fetched": s["fetched_at"], "artifact": art}
    record("J10 five fetched provider pages stored as private document revisions with verified bytes",
           run_sql(f"select count(*) from orchestration.artifact a join authoring.asset_scope s on s.artifact_id=a.id where s.workspace_id='{ws}' and a.storage_state='available' "
                   f"and a.sha256 in ({','.join(repr(s['sha256']) for s in manifest['sources'])})") == "5")

    # 3. dataset shape A (real values from the pages) + shape B (labelled fixture observations)
    F = {k: K() for k in ("provider", "model", "input", "output", "cached", "context", "ratio", "note")}
    fields = [{"field_key": F["provider"], "name": "provider", "value_type": "text", "meaning": "Organization offering the API", "required": True, "position": 0},
              {"field_key": F["model"], "name": "model", "value_type": "text", "meaning": "Model identifier or product name as listed", "required": True, "position": 1},
              {"field_key": F["input"], "name": "input_usd_per_mtok", "value_type": "number", "unit": "USD per 1M input tokens", "meaning": "Standard (base, off-peak, short-context) input price", "position": 2},
              {"field_key": F["output"], "name": "output_usd_per_mtok", "value_type": "number", "unit": "USD per 1M output tokens", "meaning": "Standard output price (including thinking tokens where stated)", "position": 3},
              {"field_key": F["cached"], "name": "cached_input_usd_per_mtok", "value_type": "number", "unit": "USD per 1M cached input tokens", "meaning": "Cache hit / cached input price", "position": 4},
              {"field_key": F["context"], "name": "context_window_tokens", "value_type": "integer", "unit": "tokens", "meaning": "Maximum context window stated in the named source", "position": 5},
              {"field_key": F["ratio"], "name": "output_to_input_ratio", "value_type": "number", "meaning": "output price / input price", "position": 6},
              {"field_key": F["note"], "name": "price_note", "value_type": "text", "meaning": "Conditions that change the price", "position": 7}]
    rows = [("Anthropic", "Claude Opus 5.5", 4, 20, 0.20, 1000000, None, "anthropic-pricing-docs.html"),
            ("Anthropic", "Claude Sonnet 5.5", 2, 10, 0.10, 1000000, None, "anthropic-pricing-docs.html"),
            ("Anthropic", "Claude Haiku 5.5", 0.10, 0.50, 0.01, "not_found", "Prompts over 100,000 tokens cost $0.50 input / $2.50 output", "anthropic-pricing-docs.html"),
            ("OpenAI", "gpt-6.1-sol", 2.00, 10.00, 0.10, "not_found", "Long-context prices are higher ($4.00 input / $15.00 output)", "openai-pricing.md"),
            ("OpenAI", "gpt-6-luna", 0.10, 0.50, 0.01, "not_found", None, "openai-pricing.md"),
            ("Google", "gemini-4-argon", 2.00, 10.00, 0.10, "not_found", "Through 2026-11-30; $4.00 input / $20.00 output from 2026-12-01", "gemini-pricing.md"),
            ("DeepSeek", "deepseek-v4-pro", 1.32, 1.98, 0.022, 1000000, "Off-peak and peak prices differ", "deepseek-pricing.md"),
            ("DeepSeek", "deepseek-flash", 0.15, 0.6, 0.003, 1000000, "Off-peak prices; peak doubles", "deepseek-pricing.md")]
    rk = {r[1]: K() for r in rows}
    cells = []
    for prov, model, i_, o_, c_, ctx, note, f_ in rows:
        fetched = src[f_]["fetched"]
        def cell(fk, v, status="observed"):
            cells.append({"row_key": rk[model], "field_key": F[fk], "value": v if status in ("observed", "calculated") else None, "value_status": status,
                          "observed_at": fetched if status == "observed" else None})
        cell("provider", prov); cell("model", model); cell("input", i_); cell("output", o_); cell("cached", c_)
        cell("context", ctx if ctx != "not_found" else None, "observed" if ctx != "not_found" else "not_found")
        cell("ratio", round(o_ / i_, 4), "calculated")
        cell("note", note, "observed") if note else cell("note", None, "not_applicable")
    ds = ok(john.cmd(ws, "create_dataset", {"slug": "frontier-api-pricing-data", "title": "Frontier model API pricing (fetched 2026-11-06)", "origin": "native_harness",
        "fields_add": fields, "rows_add": [{"row_key": rk[r[1]], "label": f"{r[0]} {r[1]}", "position": n} for n, r in enumerate(rows)], "cells": cells,
        "origin_ref": {"acceptance_id": acc["acceptanceId"]}}, client=True))
    d1 = ok(john.read(ws, "get_dataset", {"dataset_work_id": ds["workId"]}))
    statuses = sorted({c["status"] for r in d1["rows"] for c in r["cells"].values()})
    record("J10 dataset revision 1: 8 fields, 8 rows, 64 cells with observed/calculated/not_found/not_applicable statuses",
           d1["revisionNo"] == 1 and len(d1["fields"]) == 8 and d1["rowCount"] == 8 and sum(len(r["cells"]) for r in d1["rows"]) == 64
           and statuses == ["calculated", "not_applicable", "not_found", "observed"], f"{d1['revisionNo']} {len(d1['fields'])} {d1['rowCount']} {statuses}")
    record("J10 a value of the wrong type is refused", err(john.cmd(ws, "edit_dataset", {"dataset_work_id": ds["workId"],
           "cells": [{"row_key": rk["gpt-6-luna"], "field_key": F["input"], "value": "cheap", "value_status": "observed"}]}, client=True)) == "VALIDATION")
    record("J10 a status without a value cannot carry one", err(john.cmd(ws, "edit_dataset", {"dataset_work_id": ds["workId"],
           "cells": [{"row_key": rk["gpt-6-luna"], "field_key": F["context"], "value": 5, "value_status": "undisclosed"}]}, client=True)) is not None)
    record("J10 datasets change only through dataset commands", err(john.cmd(ws, "revise_work", {"work_id": ds["workId"], "revision": {"title": "x", "body": {"formatVersion": 2, "blocks": []}}},
           head=ds["revisionId"])) == "VALIDATION")
    cid = {(r["rowKey"], fk): c["cellId"] for r in d1["rows"] for fk, c in r["cells"].items()}

    def C(model, fk):
        return cid[(rk[model], F[fk])]

    # 4. support: row-level source support, cell-level quotes, a qualifier, calculations
    A, OA, G, D = (src[x]["rev"] for x in ("anthropic-pricing-docs.html", "openai-pricing.md", "gemini-pricing.md", "deepseek-pricing.md"))
    CL = src["claude-pricing.html"]["rev"]
    quotes = {
        "opus": (A, ["Claude Opus 5.5For long-running agentic coding and knowledge work |", "$4 / MTok |", "$20 / MTok |"]),
        "opus2": (CL, ["Opus 5.5", "$4 / MTok", "$20 / MTok"]),
        "sonnet": (A, ["Claude Sonnet 5.5The best combination of speed and intelligence |", "$2 / MTok |", "$10 / MTok |"]),
        "haiku": (A, ["Claude Haiku 5.5For high-volume", "$0.10 / MTokfor prompts up to 100,000 tokens |", "$0.50 / MTok |"]),
        "haiku_tier": (A, ["$0.50 / MTokfor prompts over 100,000 tokens |", "$2.50 / MTok |"]),
        "ctx_1m": (A, ["Claude 4.6 and later models (except Claude Haiku 5.5) and Claude Mythos Preview include the full 1M token context window at standard pricing."]),
        "sol": (OA, ["| gpt-6.1-sol | $2.00 | $10.00 | $0.10 |"]),
        "luna": (OA, ["| gpt-6-luna | $0.10 | $0.50 | $0.01 |"]),
        "argon_in": (G, ["## Gemini 4 Argon", "* Input price", "* $2.00 through November 30, 2026."]),
        "argon_in_dec": (G, ["## Gemini 4 Argon", "* $2.00 through November 30, 2026.", "$4.00 starting December 1, 2026."]),
        "argon_out": (G, ["## Gemini 4 Argon", "* $10.00 through November 30, 2026."]),
        "ds_ctx": (D, ["| CONTEXT LENGTH | CONTEXT LENGTH | CONTEXT LENGTH | 1M | 1M |"]),
        "ds_pro_in": (D, ["| PRICING(2) | 1M INPUT TOKENS / (CACHE MISS) | OFF-PEAK | $0.15 | $0.66 |"]),
        "ds_pro_in_peak": (D, ["| PRICING(2) | 1M INPUT TOKENS / (CACHE MISS) | PEAK | $0.3 | $1.32 |"]),
        "ds_flash": (D, ["| PRICING(2) | 1M INPUT TOKENS / (CACHE MISS) | OFF-PEAK | $0.15 | $0.66 |", "| PRICING(2) | 1M OUTPUT TOKENS | OFF-PEAK | $0.6 | $1.98 |"]),
    }
    srcmeta = {v["rev"]: v for v in src.values()}
    record("J10 every text-quote selector resolves in the stored source bytes",
           all(quotes_resolve(srcmeta[r]["data"], srcmeta[r]["media"], q) for r, q in quotes.values()),
           str([k for k, (r, q) in quotes.items() if not quotes_resolve(srcmeta[r]["data"], srcmeta[r]["media"], q)]))

    def sup(subject, role, target=None, quote=None, method=None):
        pl = {"subject": subject, "role": role}
        if quote:
            r, q = quotes[quote]
            pl["target"] = {"kind": "source_revision", "id": r}
            pl["selector"] = {"type": "aieng.text-quotes.v1", "normalization": "html-text" if srcmeta[r]["media"] == "text/html" else "none", "quotes": q}
            pl["excerpt"] = " … ".join(q)
        elif target:
            pl["target"] = target
        if method:
            pl["method"] = method
        return ok(john.cmd(ws, "add_support", pl, client=True))["supportId"]

    dsw = ds["workId"]
    row_src = {"Claude Opus 5.5": "opus", "Claude Sonnet 5.5": "sonnet", "Claude Haiku 5.5": "haiku", "gpt-6.1-sol": "sol", "gpt-6-luna": "luna",
               "gemini-4-argon": "argon_in", "deepseek-v4-pro": "ds_pro_in", "deepseek-flash": "ds_flash"}
    for model, q in row_src.items():
        sup({"dataset_work_id": dsw, "row_key": rk[model]}, "supports", quote=q)
    sup({"dataset_work_id": dsw, "row_key": rk["Claude Opus 5.5"], "field_key": F["input"], "cell_id": C("Claude Opus 5.5", "input")}, "supports", quote="opus2")
    sup({"dataset_work_id": dsw, "row_key": rk["Claude Haiku 5.5"], "field_key": F["input"], "cell_id": C("Claude Haiku 5.5", "input")}, "qualifies", quote="haiku_tier")
    for model in ("Claude Opus 5.5", "Claude Sonnet 5.5"):
        sup({"dataset_work_id": dsw, "row_key": rk[model], "field_key": F["context"], "cell_id": C(model, "context")}, "supports", quote="ctx_1m")
    for model in rk:
        sup({"dataset_work_id": dsw, "row_key": rk[model], "field_key": F["ratio"], "cell_id": C(model, "ratio")}, "calculated_from",
            method={"expression": "output_usd_per_mtok / input_usd_per_mtok", "inputs": [C(model, "output"), C(model, "input")], "rounding": 4})
    record("J10 a calculation must name its inputs' expression", err(john.cmd(ws, "add_support", {"subject": {"dataset_work_id": dsw, "row_key": rk["gpt-6-luna"],
           "field_key": F["ratio"], "cell_id": C("gpt-6-luna", "ratio")}, "role": "calculated_from", "method": {"inputs": []}}, client=True)) is not None)
    cs = ok(john.read(ws, "get_support", {"cell_id": C("Claude Haiku 5.5", "input")}))
    record("J10 a cell shows its row-level source quote and its own qualifier (two-tier price)",
           sorted(s["role"] for s in cs) == ["qualifies", "supports"] and all(s["target"]["kind"] == "source_revision" for s in cs), str([s["role"] for s in cs]))

    # 5. deliver the dataset; the agent cannot accept its own delivery
    dl1 = ok(john.cmd(ws, "deliver_output", {"obligation_id": ob["pricing-dataset"], "revision_id": ds["revisionId"]}, client=True))["deliveryId"]
    record("J10 an output of the wrong kind cannot be delivered", err(john.cmd(ws, "deliver_output", {"obligation_id": ob["comparison-report"], "revision_id": ds["revisionId"]}, client=True)) == "VALIDATION")
    record("J10 the producing agent cannot accept its own delivery", err(john.cmd(ws, "decide_delivery", {"delivery_id": dl1, "decision": "accept"}, client=True)) == "FORBIDDEN")
    ok(john.cmd(ws, "decide_delivery", {"delivery_id": dl1, "decision": "accept", "assessment": {"min_rows": "met", "fields": "met"}}))

    # 6. report with statements anchored to finding blocks, a pinned dataset view, support and contradiction
    decision = ok(john.cmd(ws, "create_work", {"kind": "decision_attempt", "slug": "cheapest-high-volume", "revision": {"title": "Cheapest option for high-volume extraction",
        "origin": "native_harness", "body": {"formatVersion": 2, "blocks": [], "metadata": {
            "definition": {"question": "Which sampled model has the lowest standard input+output price?", "choices": [r[1] for r in rows], "kind": "choice"},
            "answers": {"cheapest": {"value": "deepseek-flash", "status": "answered", "execution": "deterministic_fixture", "input": {"dataset_revision_id": ds["revisionId"]}}}}}}}, client=True))
    bk = {k: K() for k in ("intro", "ratio", "argon", "cheap", "limit", "ctx", "view")}
    ak = {k: K() for k in ("ratio", "argon", "cheap", "limit", "ctx")}
    report_blocks = [{"key": bk["intro"], "type": "text", "content": {"markdown": "Prices per million tokens from each provider's public pricing page."}},
                     {"key": bk["view"], "type": "dataset_view", "fallback": "Table of provider, model and prices", "bindings": ["data"], "content": {"columns": ["provider", "model", "input_usd_per_mtok", "output_usd_per_mtok"]}},
                     {"key": bk["ratio"], "type": "finding", "content": {"assertion_key": ak["ratio"]}},
                     {"key": bk["argon"], "type": "finding", "content": {"assertion_key": ak["argon"]}},
                     {"key": bk["cheap"], "type": "finding", "content": {"assertion_key": ak["cheap"]}},
                     {"key": bk["ctx"], "type": "finding", "content": {"assertion_key": ak["ctx"]}},
                     {"key": bk["limit"], "type": "callout", "content": {"tone": "warning", "markdown": "Observed 2026-11-06; October values not independently confirmed."}}]
    assertions = [
        {"assertion_key": ak["ratio"], "block_key": bk["ratio"], "kind": "finding", "support_status": "supported",
         "statement": "Claude Opus 5.5 and gpt-6.1-sol both price output at five times their input price."},
        {"assertion_key": ak["argon"], "block_key": bk["argon"], "kind": "comparison", "support_status": "partially_supported",
         "statement": "Gemini 4 Argon's input price ($2.00 per million tokens) is half of Claude Opus 5.5's ($4).",
         "world": {"from": "2026-11-06T00:00:00Z", "to": "2026-12-01T00:00:00Z", "precision": "day"}},
        {"assertion_key": ak["cheap"], "block_key": bk["cheap"], "kind": "recommendation", "support_status": "judgment",
         "statement": "For high-volume extraction, deepseek-flash is the lowest-cost option in this sample."},
        {"assertion_key": ak["ctx"], "block_key": bk["ctx"], "kind": "claim", "support_status": "unsupported",
         "statement": "Context windows above one million tokens are now standard across providers."},
        {"assertion_key": ak["limit"], "block_key": bk["limit"], "kind": "limitation", "support_status": "unknown",
         "statement": "Prices were observed on 2026-11-06; whether they held throughout October 2026 is not confirmed by these sources."}]
    rep_bindings = [{"local_key": "data", "relation": "uses", "role": "dataset", "target": {"kind": "revision", "id": ds["revisionId"]}}]
    record("J10 a finding block without a statement is refused", err(john.cmd(ws, "create_work", {"kind": "report", "slug": "bad-report", "revision": {"title": "x",
           "body": {"formatVersion": 2, "blocks": report_blocks}, "bindings": rep_bindings, "assertions": assertions[:2]}}, client=True)) == "VALIDATION")
    record("J10 a dataset view must pin an exact dataset revision", err(john.cmd(ws, "create_work", {"kind": "report", "slug": "bad-report2", "revision": {"title": "x",
           "body": {"formatVersion": 2, "blocks": report_blocks}, "assertions": assertions,
           "bindings": [{"local_key": "data", "relation": "uses", "role": "dataset", "target": {"kind": "revision", "id": brief2["revisionId"]}}]}}, client=True)) == "VALIDATION")
    rep = ok(john.cmd(ws, "create_work", {"kind": "report", "slug": "frontier-api-pricing-report", "revision": {"title": "Frontier model API pricing: what the pages say",
        "origin": "native_harness", "body": {"formatVersion": 2, "blocks": report_blocks}, "bindings": rep_bindings, "assertions": assertions}}, client=True))
    aid = {k: run_sql(f"select id from inquiry.assertion where revision_id='{rep['revisionId']}' and assertion_key='{v}'") for k, v in ak.items()}
    sup({"assertion_id": aid["ratio"]}, "supports", quote="opus")
    sup({"assertion_id": aid["ratio"]}, "supports", quote="sol")
    sup({"assertion_id": aid["ratio"]}, "calculated_from", target={"kind": "cell", "id": C("Claude Opus 5.5", "ratio")},
        method={"expression": "ratio cells equal 5", "inputs": [C("Claude Opus 5.5", "ratio"), C("gpt-6.1-sol", "ratio")]})
    sup({"assertion_id": aid["argon"]}, "supports", quote="argon_in")
    sup({"assertion_id": aid["argon"]}, "supports", quote="opus")
    sup({"assertion_id": aid["argon"]}, "contradicts", quote="argon_in_dec")
    sup({"assertion_id": aid["cheap"]}, "inferred_by", target={"kind": "decision", "id": decision["revisionId"], "answer_key": "cheapest"})
    record("J10 an inference must name a decision answer that exists", err(john.cmd(ws, "add_support", {"subject": {"assertion_id": aid["cheap"]}, "role": "inferred_by",
           "target": {"kind": "decision", "id": decision["revisionId"], "answer_key": "fastest"}}, client=True)) == "NOT_FOUND")
    gr = ok(john.read(ws, "get_report", {"revision_id": rep["revisionId"]}))
    sc = {a["assertionKey"]: a["support"] for a in gr["assertions"]}
    record("J10 report read: 5 statements, support counts per statement, dataset pinned at revision 1",
           len(gr["assertions"]) == 5 and sc[ak["argon"]] == {"supports": 2, "contradicts": 1} and gr["datasets"][0]["revisionNo"] == 1, str(sc[ak["argon"]]))
    ta = ok(john.read(ws, "trace_assertion", {"assertion_id": aid["argon"]}))
    con = [s for s in ta["supports"] if s["role"] == "contradicts"]
    record("J10 forward trace: the comparison's contradiction leads to the exact Gemini quote, source URL and stored bytes",
           len(con) == 1 and "$4.00 starting December 1, 2026." in con[0]["excerpt"] and con[0]["target"]["source"]["url"] == "https://aistudio.google.com/docs/pricing.md"
           and con[0]["target"]["artifacts"][0]["sha256"] == hashlib.sha256(src["gemini-pricing.md"]["data"]).hexdigest())
    tu = ok(john.read(ws, "trace_assertion", {"assertion_id": aid["ctx"]}))
    record("J10 missing-link outcome: an unsupported claim traces to no support", tu["unsupported"] is True and tu["supports"] == [])
    tc = ok(john.read(ws, "trace_assertion", {"assertion_id": aid["cheap"]}))
    record("J10 an inferred recommendation traces to the decision answer and its definition",
           tc["supports"][0]["target"]["kind"] == "decision" and tc["supports"][0]["target"]["answer"]["value"] == "deepseek-flash")
    rv = ok(john.read(ws, "trace_reverse", {"source_revision_ids": [G]}))
    record("J10 reverse trace from the Gemini page reaches the dataset revision, the statements, the report and their deliveries",
           any(a["assertionId"] == aid["argon"] for a in rv["assertions"]) and any(r["revisionId"] == rep["revisionId"] for r in rv["dependentRevisions"])
           and [r["revisionNo"] for r in rv["datasetRevisions"]] == [1]
           and any(a["deliveryId"] for a in rv["acceptances"]), json.dumps(rv)[:300])
    dl2 = ok(john.cmd(ws, "deliver_output", {"obligation_id": ob["comparison-report"], "revision_id": rep["revisionId"]}, client=True))["deliveryId"]
    ok(john.cmd(ws, "decide_delivery", {"delivery_id": dl2, "decision": "accept"}))

    # 7. interactive experience over the pinned report and dataset, and a reader view that changes nothing
    page = b"<!doctype html><title>Pricing explorer</title><script src=app.js></script><div id=table></div>"
    app = b"fetch('data.json').then(r=>r.json()).then(d=>{/* filter by provider; citations link to report statements */})"
    data_json = json.dumps({"datasetRevisionId": ds["revisionId"], "rows": d1["rows"]}).encode()
    ids = {p_: asset(john, ws, b_, ct, "private_copy") for p_, b_, ct in (("index.html", page, "text/html"), ("app.js", app, "text/plain"), ("data.json", data_json, "application/json"))}
    fs = ok(john.cmd(ws, "register_file_set", {"entrypoint": "index.html", "files": [{"path": p_, "artifact_id": a_} for p_, a_ in ids.items()]}, client=True))
    xp = ok(john.cmd(ws, "create_work", {"kind": "experience", "slug": "pricing-explorer", "revision": {"title": "Pricing explorer", "origin": "native_harness",
        "body": {"formatVersion": 2, "blocks": [{"key": K(), "type": "embedded_site", "fallback": "Filterable pricing table", "bindings": ["build"]}],
                 "metadata": {"experience": {"schema": "aieng.experience.v1", "reader_questions": ["Which model is cheapest for my input/output mix?"],
                              "interactions": ["filter by provider", "sort by price", "open the supporting quote"], "does_not_change": "report findings or dataset values"}}},
        "bindings": [{"local_key": "build", "relation": "representation", "role": "build", "target": {"kind": "file_set", "id": fs["fileSetId"]}, "usage": "private_copy"},
                     {"local_key": "report", "relation": "derived_from", "target": {"kind": "revision", "id": rep["revisionId"]}},
                     {"local_key": "data", "relation": "uses", "role": "dataset", "target": {"kind": "revision", "id": ds["revisionId"]}},
                     {"local_key": "finding", "relation": "links_to", "target": {"kind": "assertion", "id": aid["argon"]}}]}}, client=True))
    dl3 = ok(john.cmd(ws, "deliver_output", {"obligation_id": ob["comparison-view"], "revision_id": xp["revisionId"]}, client=True))["deliveryId"]
    ok(john.cmd(ws, "decide_delivery", {"delivery_id": dl3, "decision": "accept"}))
    before = run_sql(f"select content_sha256 from authoring.work_revision where id='{rep['revisionId']}'")
    ok(john.cmd(ws, "create_work", {"kind": "view", "slug": "my-cheap-models-view", "revision": {"title": "Models under $1 input",
        "body": {"formatVersion": 2, "blocks": [], "metadata": {"view": {"schema": "aieng.view.v1", "filter": {"input_usd_per_mtok": {"lt": 1}}, "scenario": {"monthly_input_mtok": 500}}}},
        "bindings": [{"local_key": "of", "relation": "scenario_of", "target": {"kind": "revision", "id": xp["revisionId"]}}]}}))
    record("J10 a saved reader view leaves the report revision byte-identical",
           run_sql(f"select content_sha256 from authoring.work_revision where id='{rep['revisionId']}'") == before)
    record("J10 an agent cannot close accepted research", err(john.cmd(ws, "set_acceptance_state", {"acceptance_id": acc["acceptanceId"], "state": "delivered"}, client=True)) is None
           and err(john.cmd(ws, "set_acceptance_state", {"acceptance_id": acc["acceptanceId"], "state": "closed"}, client=True)) == "FORBIDDEN")
    ga = ok(john.read(ws, "get_acceptance", {"acceptance_id": acc["acceptanceId"]}))
    ok(john.cmd(ws, "set_acceptance_state", {"acceptance_id": acc["acceptanceId"], "state": "closed"}))
    record("J10 all obligations fulfilled by accepted deliveries; John closes the acceptance",
           ga["fulfilled"] is True and all(o["fulfilled"] for o in ga["obligations"]) and
           run_sql(f"select state from inquiry.acceptance where id='{acc['acceptanceId']}'") == "closed")

    # 8. rights: private source copies do not silently travel with a named-audience release
    ex = ok(john.read(ws, "preview_exposure", {"root_revision_id": rep["revisionId"], "ceiling": "named"}))
    record("J10 releasing the report to a named audience surfaces the private source copies as blockers",
           len(ex["blockers"]) >= 5 and any(i["kind"] == "revision" and i["id"] == G for i in ex["items"]), f"blockers={len(ex['blockers'])}")

    # 9. reviewed change: a correction proposal → revision 2; old report keeps revision 1; duplicates and no-ops are silent
    acc2 = ok(john.cmd(ws, "accept_research", {"revision_id": brief2["revisionId"], "execution_origin": "native_harness", "trigger": "refresh"}))
    corr = {"dataset_work_id": dsw, "base_revision_no": 1, "reason": "correction", "acceptance_id": acc2["acceptanceId"], "dedupe_key": "correction:deepseek-v4-pro:input:off-peak",
            "explanation": "deepseek-v4-pro input was entered at the peak price; the field means the standard (off-peak) price",
            "cells": [{"row_key": rk["deepseek-v4-pro"], "field_key": F["input"], "value": 0.66, "value_status": "observed", "observed_at": src["deepseek-pricing.md"]["fetched"]},
                      {"row_key": rk["deepseek-v4-pro"], "field_key": F["ratio"], "value": 3.0, "value_status": "calculated"},
                      {"row_key": rk["Claude Opus 5.5"], "field_key": F["input"], "value": 4, "value_status": "observed", "observed_at": src["anthropic-pricing-docs.html"]["fetched"]}]}
    pr = ok(john.cmd(ws, "propose_dataset_change", corr, client=True))
    record("J10 the correction proposal stages only the 2 values that actually change", pr["summary"]["cellsChanged"] == 2 and len(pr["stagedCells"]) == 2, str(pr["summary"]))
    staged = {s["fieldKey"]: s["cellId"] for s in pr["stagedCells"]}
    sup({"dataset_work_id": dsw, "row_key": rk["deepseek-v4-pro"], "field_key": F["input"], "cell_id": staged[F["input"]]}, "supports", quote="ds_pro_in")
    sup({"dataset_work_id": dsw, "row_key": rk["deepseek-v4-pro"], "field_key": F["input"], "cell_id": staged[F["input"]]}, "qualifies", quote="ds_pro_in_peak")
    dup = ok(john.cmd(ws, "propose_dataset_change", corr, client=True))
    noop = ok(john.cmd(ws, "propose_dataset_change", dict(corr, dedupe_key="refresh:2026-11-06", reason="refresh",
        cells=[{"row_key": rk["gpt-6-luna"], "field_key": F["input"], "value": 0.10, "value_status": "observed", "observed_at": src["openai-pricing.md"]["fetched"]}]), client=True))
    record("J10 the same refresh again is a duplicate; an unchanged refresh creates no proposal",
           dup["duplicate"] is True and dup["proposalId"] == pr["proposalId"] and noop["unchanged"] is True and noop["proposalId"] is None)
    record("J10 exactly one change notice for the dataset so far",
           run_sql(f"select count(*) from authoring.event where workspace_id='{ws}' and work_id='{dsw}' and kind='change_proposed'") == "1")
    dfp = ok(john.read(ws, "get_dataset_diff", {"proposal_id": pr["proposalId"]}))
    record("J10 the proposal diff shows old and new values with support for the new input price",
           any(c["from"]["value"] == 1.32 and c["to"]["value"] == 0.66 and c["support"] == {"supports": 1, "qualifies": 1} for c in dfp["changes"]), json.dumps(dfp["changes"])[:300])
    record("J10 an agent cannot apply a dataset change", err(john.cmd(ws, "decide_dataset_change", {"proposal_id": pr["proposalId"], "decision": "apply"}, client=True)) == "FORBIDDEN")
    applied = ok(john.cmd(ws, "decide_dataset_change", {"proposal_id": pr["proposalId"], "decision": "apply"}))
    r1 = ok(john.read(ws, "get_dataset", {"dataset_work_id": dsw, "revision_no": 1}))
    r2 = ok(john.read(ws, "get_dataset", {"dataset_work_id": dsw, "revision_no": 2}))
    def val(d, model, fk):
        return next(r for r in d["rows"] if r["rowKey"] == rk[model])["cells"][F[fk]]["value"]
    record("J10 applying creates revision 2 (0.66); revision 1 still reads 1.32",
           applied["revisionNo"] == 2 and val(r1, "deepseek-v4-pro", "input") == 1.32 and val(r2, "deepseek-v4-pro", "input") == 0.66 and r1["cellsSha256"] != r2["cellsSha256"])
    d12 = ok(john.read(ws, "get_dataset_diff", {"dataset_work_id": dsw, "from_revision_no": 1, "to_revision_no": 2}))
    record("J10 revision diff 1 to 2 lists exactly the two corrected values", len(d12["changes"]) == 2, json.dumps(d12["changes"])[:300])
    record("J10 the delivered report still pins dataset revision 1", ok(john.read(ws, "get_report", {"revision_id": rep["revisionId"]}))["datasets"][0]["revisionNo"] == 1)
    record("J10 a proposal against an old base is refused", err(john.cmd(ws, "propose_dataset_change", dict(corr, dedupe_key="late"), client=True)) == "CONFLICT")
    record("J10 the change is traceable from the corrected cell back to the DeepSeek page",
           any(c["cellId"] == staged[F["input"]] and c["fromRevisionNo"] == 2 for c in ok(john.read(ws, "trace_reverse", {"source_revision_ids": [D]}))["cells"]))
    # revised scope supersedes; watches are opt-in by a person
    acc3 = ok(john.cmd(ws, "accept_research", {"revision_id": brief2["revisionId"], "execution_origin": "native_harness", "revises_acceptance_id": acc2["acceptanceId"]}))
    record("J10 a revised acceptance supersedes the previous scope", acc3["supersededAcceptanceId"] == acc2["acceptanceId"]
           and run_sql(f"select state from inquiry.acceptance where id='{acc2['acceptanceId']}'") == "superseded")
    wpl = {"brief_work_id": brief["workId"], "subjects": [{"kind": "provider", "name": n} for n in ("Anthropic", "OpenAI", "Google", "DeepSeek")],
           "sources": [s["url"] for s in manifest["sources"]], "cadence": "P7D", "budget_per_run_usd": 0, "budget_total_usd": 0,
           "stop_condition": {"after": "2027-01-01"}, "target_work_ids": [dsw]}
    record("J10 an agent cannot opt into a watch", err(john.cmd(ws, "create_watch", wpl, client=True)) == "FORBIDDEN")
    wid = ok(john.cmd(ws, "create_watch", wpl))["watchId"]
    ok(john.cmd(ws, "set_watch_state", {"watch_id": wid, "state": "paused"}, client=True))
    record("J10 a paused watch can be resumed only by a person", err(john.cmd(ws, "set_watch_state", {"watch_id": wid, "state": "active"}, client=True)) == "FORBIDDEN"
           and ok(john.read(ws, "list_watches"))[0]["state"] == "paused")

    # 10. denials and invariants
    record("J10 an outsider cannot read the acceptance, dataset, report or trace",
           all(denied(r) for r in (outsider.read(ws, "get_acceptance", {"acceptance_id": acc["acceptanceId"]}), outsider.read(ws, "get_dataset", {"dataset_work_id": dsw}),
                                   outsider.read(ws, "get_report", {"revision_id": rep["revisionId"]}), outsider.read(ws, "trace_assertion", {"assertion_id": aid["argon"]}))))
    record("J10 an outsider cannot add support", err(outsider.cmd(ws, "add_support", {"subject": {"assertion_id": aid["ctx"]}, "role": "supports",
           "target": {"kind": "source_revision", "id": G}})) == "NOT_FOUND")
    record("SQL a committed dataset value cannot be rewritten", "immutable" in run_sql(f"update dataset.cell set value='9' where id='{C('gpt-6-luna', 'input')}'", allow_error=True))
    record("SQL support records are append-only", "append-only" in run_sql(f"delete from inquiry.support where workspace_id='{ws}'", allow_error=True))
    record("SQL a statement cannot be added to a sealed report revision",
           "sealed" in run_sql(f"insert into inquiry.assertion(tenant_id, workspace_id, revision_id, assertion_key, kind, statement, support_status, created_by) "
                               f"select tenant_id, workspace_id, id, gen_random_uuid(), 'claim', 'late', 'unknown', created_by from authoring.work_revision where id='{rep['revisionId']}'", allow_error=True))


def main():
    t0 = time.time()
    # ---------------------------------------------------------------- setup: policy, accounts
    policy = {"schema": "aieng.access-policy.v1", "default_band": "adult", "public_publish_min_band": "adult", "public_read_min_band": "teen",
              "connector_min_band": "teen", "self_consent_min_band": "teen",
              "consent_required_bands": {"embedding": ["child", "unknown"], "connector": ["child", "teen", "unknown"],
                                         "llm_inference": ["child", "unknown"], "third_party_share": ["child", "teen", "unknown"]},
              "retention": {"temporary_asset_days": 7, "child_inactive_days": 365}, "backup_purge_days": 35,
              "jurisdictions": {"US": {"child_under": 13, "teen_under": 18, "guardian_consent_required_under": 13}}}
    ok(worker("add_policy_version", {"body": policy}))
    john, learner, outsider, child, guardian = (User(x) for x in ("john", "learner", "outsider", "child", "guardian"))
    for u, band in ((john, "adult"), (learner, "adult"), (outsider, "adult"), (child, "child"), (guardian, "adult")):
        ok(worker("set_account_profile", {"principal_id": u.id, "age_band": band, "jurisdiction": "US", "established_by": "admin",
                                          "eligibility": "pending_guardian_consent" if band == "child" else "eligible"}))
    ok(worker("grant_publisher", {"principal_id": john.id}))
    record("worker boundary refuses a user token", err(http("POST", "/rest/v1/rpc/product_worker", {"p_operation": "grant_publisher", "p_payload": {"principal_id": learner.id}},
                                                            token=learner.token, headers={"Content-Profile": "api"})) is not None)

    # ---------------------------------------------------------------- J1 authoring
    ws = ok(john.cmd(None, "create_workspace", {"name": "Agent Orchestration Course"}))["workspaceId"]
    png = b"\x89PNG\r\n\x1a\n" + os.urandom(64)
    img = asset(john, ws, png, "image/png", "private_copy")
    py = b"def with_retry(fn, attempts=3):\n    for i in range(attempts):\n        try:\n            return fn()\n        except Exception:\n            if i == attempts - 1: raise\n"
    code_asset = asset(john, ws, py, "text/x-python", "redistributable")
    hidden = asset(john, ws, b"def test_idempotent_retry(): assert True\n", "text/x-python", "private_copy")
    comp = ok(john.cmd(ws, "create_work", {"kind": "competency", "slug": "retry-idempotency", "revision": {"title": "Design idempotent retries", "body": body("Independent/assisted/agent-directed facets.")}}))
    pol = ok(john.cmd(ws, "create_work", {"kind": "action_policy", "slug": "finalization-v1", "revision": {"title": "Auto-finalization policy",
              "body": body("Finalize automatically when all model judgments answered with confidence >= 0.8.", {"finalization": {"auto": True, "min_confidence": 0.8}})}}))
    rubric = ok(john.cmd(ws, "create_work", {"kind": "decision_definition", "slug": "retry-rubric", "revision": {"title": "Retry rubric", "body": body("Criteria: works, explains.")}}))
    act = ok(john.cmd(ws, "create_work", {"kind": "activity", "slug": "build-retry", "revision": {"title": "Build a retry wrapper", "body": body("Implement and explain a retry wrapper."),
              "bindings": [{"local_key": "diagram", "relation": "representation", "target": {"kind": "artifact", "id": img}, "usage": "private_copy"},
                           {"local_key": "starter", "relation": "representation", "target": {"kind": "artifact", "id": code_asset}, "usage": "redistributable"},
                           {"local_key": "hidden-tests", "relation": "evaluates_with", "target": {"kind": "artifact", "id": hidden}, "usage": "private_copy"},
                           {"local_key": "rubric", "relation": "evaluates_with", "target": {"kind": "revision", "id": rubric["revisionId"]}}],
              "runtime": [{"local_key": "py", "kind": "language_runtime", "name": "python", "version_spec": ">=3.12"},
                          {"local_key": "lg", "kind": "package", "ecosystem": "pypi", "name": "langgraph", "version_spec": ">=1.0,<2", "resolved_version": "1.0.2"}]}}))
    mod = ok(john.cmd(ws, "create_work", {"kind": "module", "slug": "durable-execution", "revision": {"title": "Durable execution", "body": body("Module 1"),
              "parts": [{"occurrence_key": str(uuid.uuid4()), "child_revision_id": act["revisionId"], "ordinal": 0}]}}))
    okey, rkey = str(uuid.uuid4()), str(uuid.uuid4())
    course_spec = {"title": "Agent orchestration: beginner to advanced", "body": body("Course map"),
                   "parts": [{"occurrence_key": str(uuid.uuid4()), "child_revision_id": mod["revisionId"], "ordinal": 0}],
                   "outcomes": [{"outcome_key": okey, "statement": "Build and explain idempotent retries", "bloom_level": "create", "evidence_rule": RULE,
                                 "alignments": [{"competency_revision_id": comp["revisionId"], "facet": "assisted", "coverage": "full", "rationale": "direct"}]}],
                   "requirements": [{"requirement_key": rkey, "kind": "outcome", "outcome_key": okey, "rationale": "core outcome",
                                     "options": [{"route": "standard", "activity_revision_id": act["revisionId"], "evidence_rule": RULE, "approval_state": "approved"},
                                                 {"route": "generated_eligible", "evidence_rule": RULE, "approval_state": "proposed"}]}]}
    course = ok(john.cmd(ws, "create_work", {"kind": "course", "slug": "agent-orchestration", "revision": course_spec}))
    record("J1 course/module/activity/competency/policy created as sealed revisions", all(x.get("revisionId") for x in (comp, pol, rubric, act, mod, course)))
    record("J1 module cannot contain a course (composition kind matrix)",
           err(john.cmd(ws, "create_work", {"kind": "module", "slug": "bad", "revision": {"title": "x", "body": body("x"),
               "parts": [{"occurrence_key": str(uuid.uuid4()), "child_revision_id": course["revisionId"], "ordinal": 0}]}})) == "VALIDATION")
    record("J1 stale expected head is a conflict",
           err(john.cmd(ws, "revise_work", {"work_id": course["workId"], "revision": course_spec}, head=mod["revisionId"])) == "CONFLICT")
    rev2 = ok(john.cmd(ws, "revise_work", {"work_id": course["workId"], "revision": course_spec}, head=course["revisionId"]))
    record("J1 revise with correct head creates revision 2", bool(rev2.get("revisionId")))
    record("J1 learner (non-member) cannot read a private draft", err(learner.read(None, "get_revision", {"revision_id": rev2["revisionId"]})) == "NOT_FOUND")
    record("J1 invalid body shape rejected", err(john.cmd(ws, "create_work", {"kind": "note", "slug": "bad-body", "revision": {"title": "x", "body": {"blocks": []}}})) == "VALIDATION")
    record("J1 binding to an artifact from another workspace rejected",
           err(learner.cmd(ok(learner.cmd(None, "ensure_personal_workspace"))["workspaceId"], "create_work",
               {"kind": "note", "slug": "steal", "revision": {"title": "x", "body": body("x"), "bindings": [{"local_key": "x", "relation": "representation", "target": {"kind": "artifact", "id": img}}]}})) == "NOT_FOUND")

    # ---------------------------------------------------------------- J2 release with exposure check
    root = rev2["revisionId"]
    ex_public = ok(john.read(ws, "preview_exposure", {"root_revision_id": root, "ceiling": "public"}))
    blockers = [b["item_key"] for b in ex_public["blockers"]]
    withheld = [i for i in ex_public["items"] if i["disposition"] == "withheld"]
    record("J2 public ceiling blocks the private_copy diagram", len(blockers) == 1, str(blockers))
    record("J2 hidden tests and rubric (evaluates_with) are withheld", len(withheld) == 2, str([w["item_key"] for w in withheld]))
    ok(john.cmd(ws, "create_client_grant", {"client_kind": "mcp", "label": "lab mcp", "scopes": ["read", "author"], "ttl_hours": 2}))  # discard: show minting works
    g = ok(john.cmd(ws, "create_client_grant", {"client_kind": "mcp", "label": "harness agent", "scopes": ["read", "author"], "ttl_hours": 2}))
    john.client_token = g["token"]
    review_payload = {"work_id": course["workId"], "revision_id": root, "review": {"reviewType": "release_review", "decision": "approve",
                      "closure_sha256": ex_public["closure_sha256"], "ceiling": "public", "audience": "public"}}
    record("J2 an MCP agent cannot record a human release review", err(john.cmd(ws, "review_revision", review_payload, client=True)) == "FORBIDDEN")
    ev = ok(john.cmd(ws, "review_revision", review_payload))["eventId"]
    record("J2 freeze refuses unresolved exposure blockers",
           err(john.cmd(ws, "freeze_release", {"root_revision_id": root, "ceiling": "public", "approval_event_id": ev})) == "EXPOSURE_BLOCKED")
    decisions = [{"item_key": blockers[0], "disposition": "withheld", "rationale": "diagram is licensed for private use only"}]
    rel = ok(john.cmd(ws, "freeze_release", {"root_revision_id": root, "ceiling": "public", "approval_event_id": ev, "decisions": decisions}))
    record("J2 release frozen with author decision", rel["releaseNo"] == 1)
    dist_inv = ok(john.cmd(ws, "open_distribution", {"root_work_id": course["workId"], "channel": "invited", "title": "Cohort 1"}))["distributionId"]
    terms = {"study": True, "adapt": "private", "redistribute": "none", "derived_work": "none", "attribution": "BellLabs", "updates": "corrections_included", "endorsement": "creator"}
    if SURFACE == "database":
        early = err(john.cmd(ws, "offer_release", {"distribution_id": dist_inv, "release_id": rel["releaseId"], "terms": terms, "approval_event_id": ev}))
        record("J2 offer refused while manifest bytes are not stored/verified", early == "CONFLICT", str(early))
    else:
        skip("J2 offer refused while manifest bytes are not stored/verified", API_STORES_MANIFESTS)
    manifest = rel["manifestText"].encode()
    store_and_complete(rel["objectPath"], rel["manifestArtifactId"], manifest, "application/json")
    offer_inv = ok(john.cmd(ws, "offer_release", {"distribution_id": dist_inv, "release_id": rel["releaseId"], "terms": terms, "approval_event_id": ev}))["offerId"]
    dist_off = ok(john.cmd(ws, "open_distribution", {"root_work_id": course["workId"], "channel": "official_catalog", "title": "Official: Agent orchestration"}))["distributionId"]
    off_terms = dict(terms, endorsement="official")
    record("J2 official catalog refuses a creator release review",
           err(john.cmd(ws, "offer_release", {"distribution_id": dist_off, "release_id": rel["releaseId"], "terms": off_terms, "approval_event_id": ev})) == "FORBIDDEN")
    bad_ev = ok(john.cmd(ws, "review_revision", {"work_id": course["workId"], "revision_id": root, "review": {"reviewType": "official_publication", "decision": "approve",
                 "closure_sha256": ex_public["closure_sha256"], "terms": dict(off_terms, adapt="shareable")}}))["eventId"]
    record("J2 official offer refused when the publisher review names different terms",
           err(john.cmd(ws, "offer_release", {"distribution_id": dist_off, "release_id": rel["releaseId"], "terms": off_terms, "approval_event_id": bad_ev})) == "FORBIDDEN")
    off_ev = ok(john.cmd(ws, "review_revision", {"work_id": course["workId"], "revision_id": root, "review": {"reviewType": "official_publication", "decision": "approve",
                 "closure_sha256": ex_public["closure_sha256"], "terms": off_terms}}))["eventId"]
    offer_off = ok(john.cmd(ws, "offer_release", {"distribution_id": dist_off, "release_id": rel["releaseId"], "terms": off_terms, "approval_event_id": off_ev}))["offerId"]
    record("J2 official catalog offer accepted with an exact publisher review", bool(offer_off))
    record("J2 a second open official distribution for the same work is refused",
           err(john.cmd(ws, "open_distribution", {"root_work_id": course["workId"], "channel": "official_catalog", "title": "dup"})) is not None)

    # ---------------------------------------------------------------- J3 learner journey
    lws = ok(learner.cmd(None, "ensure_personal_workspace"))["workspaceId"]
    record("J3 uninvited learner cannot see the invited offer", err(learner.read(None, "get_offer", {"offer_id": offer_inv})) == "NOT_FOUND")
    ok(john.cmd(ws, "grant_reader", {"distribution_id": dist_inv, "principal_id": learner.id}))
    view = ok(learner.read(None, "get_offer", {"offer_id": offer_inv}))
    keys = {i["itemKey"]: i for i in view["items"]}
    record("J3 invited learner sees the offer; withheld items absent", not any(i["disposition"] == "withheld" for i in view["items"]) and len(view["items"]) >= 4)
    record("J3 learner can read a released revision", ok(learner.read(None, "get_revision", {"revision_id": act["revisionId"]}))["title"] == "Build a retry wrapper")
    record("J3 learner cannot read the hidden rubric revision", err(learner.read(None, "get_revision", {"revision_id": rubric["revisionId"]})) == "NOT_FOUND")
    record("J3 outsider cannot enroll", err(outsider.cmd(ok(outsider.cmd(None, "ensure_personal_workspace"))["workspaceId"], "enroll", {"distribution_id": dist_inv})) == "NOT_FOUND")
    enr = ok(learner.cmd(lws, "enroll", {"distribution_id": dist_inv}))["enrollmentId"]
    adp = ok(learner.cmd(lws, "adopt_release", {"enrollment_id": enr, "offer_id": offer_inv, "reason": "start course"}))["adoptionId"]
    opt_id = run_sql(f"select o.id from curriculum.requirement_option o join curriculum.requirement r on r.id=o.requirement_id where r.revision_id='{root}' and o.route='standard'")
    gen_opt = run_sql(f"select o.id from curriculum.requirement_option o join curriculum.requirement r on r.id=o.requirement_id where r.revision_id='{root}' and o.route='generated_eligible'")
    record("J3 proposed (unapproved) generated option cannot back an official attempt",
           err(learner.cmd(lws, "start_attempt", {"purpose": "official", "task_revision_id": None, "task_release_item_id": run_sql(
               f"select id from authoring.release_item where release_id='{rel['releaseId']}' and revision_id='{act['revisionId']}'"),
               "enrollment_id": enr, "adoption_id": adp, "requirement_key": rkey, "option_id": gen_opt,
               "conditions": {"schema": "aieng.attempt-conditions.v1", "facet": "assisted", "assistance": "build_with_me"}})) == "VALIDATION")
    task_item = run_sql(f"select id from authoring.release_item where release_id='{rel['releaseId']}' and revision_id='{act['revisionId']}'")
    att = ok(learner.cmd(lws, "start_attempt", {"purpose": "official", "task_release_item_id": task_item, "enrollment_id": enr, "adoption_id": adp,
                                                "requirement_key": rkey, "option_id": opt_id,
                                                "conditions": {"schema": "aieng.attempt-conditions.v1", "facet": "assisted", "assistance": "build_with_me", "allowed_models": ["any"]}}))["attemptId"]
    proj = ok(learner.cmd(lws, "create_work", {"kind": "project", "slug": "retry-agent", "revision": {"title": "My retry agent", "body": body("repo: github.com/example/retry @ abc123",
               {"repository": {"remote_url": "https://example.invalid/retry.git", "commit": "abc123"}})}}))
    sub = ok(learner.cmd(lws, "submit_attempt", {"attempt_id": att, "items": [{"item_key": "project", "kind": "project_revision", "revision_id": proj["revisionId"]},
              {"item_key": "commit", "kind": "repository_commit", "external_ref": {"url": "https://example.invalid/retry.git", "commit": "abc123"}, "availability": "reference_only"}]}))
    record("J3 resubmitting the same attempt is a conflict", err(learner.cmd(lws, "submit_attempt", {"attempt_id": att, "items": []})) == "CONFLICT")
    storage_boundary_checks = ("J3 grading refused before submission manifest is stored",
                               "J3 worker readback digest mismatch keeps the artifact pending",
                               "J3 custody guard refuses deleting bytes of a live artifact registration",
                               "J3 re-upload of the registered bytes verifies and becomes available")
    if SURFACE == "database":
        record(storage_boundary_checks[0],
               err(worker("record_grading", {"submission_id": sub["submissionId"], "pipeline_revision_id": pol["revisionId"], "kind": "deterministic", "status": "completed",
                                             "criteria": [], "outcomes": {}})) == "CONFLICT")
        bad = store_and_complete(sub["objectPath"], sub["manifestArtifactId"], b'{"tampered": true}', "application/json")
        record(storage_boundary_checks[1], bad["state"] == "pending" and bad["reason"] == "digest_mismatch")
        sd, bd = http("DELETE", "/storage/v1/object/aieng-workspaces", {"prefixes": [sub["objectPath"]]}, token=SERVICE, key=SERVICE)
        record(storage_boundary_checks[2], sd != 200, str(sd))
        good = store_and_complete(sub["objectPath"], sub["manifestArtifactId"], sub["manifestText"].encode(), "application/json", upsert=True)
        record(storage_boundary_checks[3], good["state"] == "available")
    else:
        for name in storage_boundary_checks:
            skip(name, API_STORES_MANIFESTS)
    unav = ok(worker("record_grading", {"submission_id": sub["submissionId"], "pipeline_revision_id": pol["revisionId"], "kind": "deterministic", "status": "unavailable",
                                        "failure_class": "runner_unreachable", "reason": "runner pool down", "criteria": [], "outcomes": {}}))
    record("J3 unavailable runner records no result (not a learner failure)", unav["result"] is None)
    judged = {"schema": "aieng.decision-answer.v1", "status": "answered", "confidence": 0.62, "requested_model": "fixture", "returned_model": "fixture", "execution": "fixture"}
    g1 = ok(worker("record_grading", {"submission_id": sub["submissionId"], "pipeline_revision_id": pol["revisionId"], "kind": "mixed", "status": "completed",
                                      "finalization_policy_revision_id": pol["revisionId"], "outcomes": {rkey: "met"},
                                      "criteria": [{"criterion_key": "works", "value": {"pass": True}, "judged_by": "deterministic", "explanation": "4/4 visible checks pass"},
                                                   {"criterion_key": "hidden", "value": {"pass": True}, "judged_by": "deterministic", "visibility": "withheld", "explanation": "withheld checks summarized"},
                                                   {"criterion_key": "explains", "value": {"level": 3}, "judged_by": "model", "judgment": judged, "explanation": "explanation covers idempotency keys"}]}))
    record("J3 low model confidence leaves the result provisional", g1["status"] == "provisional")
    prog0 = ok(learner.read(None, "progress", {"enrollment_id": enr}))
    record("J3 provisional result grants no credit", prog0["requirements"][0]["met"] is False)
    record("J3 learner cannot finalize their own result", err(learner.cmd(lws, "finalize_result", {"result_id": g1["resultId"]})) == "NOT_FOUND")
    record("J3 MCP agent cannot finalize", err(john.cmd(lws, "finalize_result", {"result_id": g1["resultId"]}, client=True)) is not None)
    ok(john.cmd(ws, "finalize_result", {"result_id": g1["resultId"]}))
    prog1 = ok(learner.read(None, "progress", {"enrollment_id": enr}))
    record("J3 human finalization grants credit", prog1["requirements"][0]["met"] is True)
    res = ok(learner.read(None, "get_result", {"result_id": g1["resultId"]}))
    hidden_c = [c for c in res["criteria"] if c["criterion"] == "hidden"][0]
    record("J3 withheld criterion value hidden from learner", hidden_c["value"] is None and hidden_c["visibility"] == "withheld")
    record("J3 outsider cannot read the result", denied(outsider.read(None, "get_result", {"result_id": g1["resultId"]})))
    ap = ok(learner.cmd(lws, "open_appeal", {"result_id": g1["resultId"], "grounds": "Explanation criterion ignored my design notes"}))["appealId"]
    rap = ok(john.cmd(ws, "resolve_appeal", {"appeal_id": ap, "decision": "modified", "resolution": "level raised after reading design notes", "outcomes": {rkey: "met"}}))
    orig = run_sql(f"select status from learning.assessment_result where id='{g1['resultId']}'")
    credits = run_sql(f"select string_agg(status, ',' order by created_at) from learning.credit where adoption_id='{adp}'")
    record("J3 appeal creates a superseding result; original preserved", rap["newResultId"] and orig == "superseded", f"orig={orig}")
    record("J3 credit history kept (superseded + active)", credits == "superseded,active", credits)
    ok(learner.cmd(lws, "grant_evidence", {"grantee_id": outsider.id, "scope_kind": "enrollment", "enrollment_id": enr, "includes": ["progress", "results"]}))
    record("J3 learner-granted teacher can read progress", ok(outsider.read(None, "progress", {"enrollment_id": enr}))["requirements"][0]["met"] is True)

    # ---------------------------------------------------------------- J4 library, search, conversations
    note = ok(learner.cmd(lws, "create_work", {"kind": "note", "slug": "retry-notes", "revision": {"title": "Retry notes", "body": body("Idempotency keys prevent duplicate side effects.")}}))
    ok(worker("index_passages", {"workspace_id": lws, "revision_id": note["revisionId"], "procedure_version": "lab-md-1",
                                 "passages": [{"text": "Idempotency keys prevent duplicate side effects when an ingestion run retries.", "locator": {"schema": "aieng.locator.v1", "block": 0}}]}))
    ok(worker("index_passages", {"workspace_id": ws, "revision_id": act["revisionId"], "procedure_version": "lab-md-1",
                                 "passages": [{"text": "Build a retry wrapper; explain why duplicate side effects happen without idempotency.", "locator": {"schema": "aieng.locator.v1", "block": 0}}]}))
    ok(worker("index_passages", {"workspace_id": ws, "revision_id": rubric["revisionId"], "procedure_version": "lab-md-1",
                                 "passages": [{"text": "Hidden rubric: award level 3 when duplicate side effects are explained.", "locator": {"schema": "aieng.locator.v1", "block": 0}}]}))
    mine = {note["revisionId"], act["revisionId"], rubric["revisionId"]}
    hits = [h for h in ok(learner.read(None, "search", {"query": "duplicate side effects"})) if h["revisionId"] in mine]
    labels = sorted(h["label"] for h in hits)
    record("J4 learner search labels private note and released course material", labels == ["course_material", "private_note"], str(labels))
    record("J4 hidden rubric passage never reaches the learner", not any("Hidden rubric" in h["snippet"] for h in hits))
    out_hits = [h for h in ok(outsider.read(None, "search", {"query": "duplicate side effects"})) if h["revisionId"] in mine]
    record("J4 outsider sees only officially published course material, never the learner's note",
           [h["label"] for h in out_hits] == ["course_material"], str([h["label"] for h in out_hits]))
    ok(learner.cmd(lws, "set_control", {"work_id": note["workId"], "exclude": True}))
    record("J4 excluded note disappears from search",
           [h["label"] for h in ok(learner.read(None, "search", {"query": "duplicate side effects"})) if h["revisionId"] in mine] == ["course_material"])
    th = ok(learner.cmd(lws, "create_thread", {"title": "Retry help", "purpose": "tutor"}))["threadId"]
    m = ok(learner.cmd(lws, "append_message", {"thread_id": th, "role": "user", "content": {"schema": "aieng.message.v1", "parts": [{"text": "Why did my run duplicate rows?"}]},
                                               "context": {"schema": "aieng.context.v1", "view": "activity", "items": [{"item_key": "act", "reason": "view", "revision_id": act["revisionId"]}]}}))
    m2 = ok(learner.cmd(lws, "append_message", {"thread_id": th, "role": "user", "content": {"schema": "aieng.message.v1", "parts": [{"text": "And with a different key?"}]},
                                                "context": {"schema": "aieng.context.v1", "view": "activity", "items": [{"item_key": "act", "reason": "view", "revision_id": act["revisionId"]}]}}, client=False))
    record("J4 identical context snapshots are deduplicated", m["contextSnapshotId"] == m2["contextSnapshotId"] and m2["seq"] == 2)
    record("J4 context cannot reference unreadable material",
           err(learner.cmd(lws, "append_message", {"thread_id": th, "role": "user", "content": {"schema": "aieng.message.v1", "parts": [{"text": "x"}]},
               "context": {"schema": "aieng.context.v1", "items": [{"item_key": "r", "reason": "pinned", "revision_id": rubric["revisionId"]}]}})) == "NOT_FOUND")
    record("J4 another user cannot read the private thread", denied(john.read(None, "get_thread", {"thread_id": th})))

    # ---------------------------------------------------------------- J5 RV20 youth, consent, clients, restrictions
    cws = ok(child.cmd(None, "ensure_personal_workspace"))["workspaceId"]
    cnote = ok(child.cmd(cws, "create_work", {"kind": "note", "slug": "my-notes", "revision": {"title": "My notes", "body": body("hello")}}))
    record("J5 child cannot enable semantic indexing without guardian consent",
           err(child.cmd(cws, "set_control", {"work_id": cnote["workId"], "semantic_index": True})) == "CONSENT_REQUIRED")
    record("J5 child cannot self-consent", err(child.cmd(None, "authorize_processing", {"principal_id": child.id, "processor_class": "embedding", "processor_key": "openai", "purpose": "semantic search"})) == "CONSENT_REQUIRED")
    record("J5 child cannot open a public library distribution",
           err(child.cmd(cws, "open_distribution", {"root_work_id": cnote["workId"], "channel": "public_library", "title": "mine"})) == "FORBIDDEN")
    link = ok(child.cmd(None, "invite_guardian", {"guardian_id": guardian.id}))["guardianLinkId"]
    record("J5 guardian cannot authorize before consenting",
           err(guardian.cmd(None, "authorize_processing", {"principal_id": child.id, "processor_class": "embedding", "processor_key": "openai", "purpose": "semantic search"})) == "NOT_FOUND")
    ok(guardian.cmd(None, "consent_guardian", {"guardian_link_id": link, "consent_method": "lab_fixture_signed_form", "help_scope": ["progress"]}))
    ok(guardian.cmd(None, "authorize_processing", {"principal_id": child.id, "processor_class": "embedding", "processor_key": "openai", "purpose": "semantic search"}))
    record("J5 after guardian consent the child can enable semantic indexing", err(child.cmd(cws, "set_control", {"work_id": cnote["workId"], "semantic_index": True})) is None)
    record("J5 guardian evidence grant limited to the consented help scope",
           err(child.cmd(cws, "grant_evidence", {"grantee_id": guardian.id, "scope_kind": "all_learning", "includes": ["results"], "guardian_link_id": link})) == "FORBIDDEN")
    record("J5 guardian has no automatic access to the child's notes", err(guardian.read(None, "get_revision", {"revision_id": cnote["revisionId"]})) == "NOT_FOUND")
    vsv = run_sql("insert into retrieval.vector_space(tenant_id, slug, purpose) values (util.default_tenant_id(), 'lab-private-notes-" + uuid.uuid4().hex[:8] + "', 'lab') returning id")
    vsv = run_sql(f"insert into retrieval.vector_space_version(tenant_id, vector_space_id, version, embedding_model, dims, backend, precision, distance_operator, normalization, index_configuration, provider_routing_policy, publication_lifecycle) "
                  f"values (util.default_tenant_id(), '{vsv}', 1, 'fixture-embedding', 1536, 'pgvector', 'halfvec', 'cosine', 'l2', '{{}}', '{{}}', 'draft') returning id")
    ok(worker("index_passages", {"workspace_id": cws, "revision_id": cnote["revisionId"], "procedure_version": "lab-md-1",
                                 "passages": [{"text": "hello world", "locator": {"schema": "aieng.locator.v1", "block": 0}}]}))
    pid = run_sql(f"select id from library.passage where revision_id='{cnote['revisionId']}'")
    vec = "[" + ",".join("0.01" for _ in range(1536)) + "]"
    ok(worker("record_embeddings", {"workspace_id": cws, "principal_id": child.id, "processor_key": "openai", "space_version_id": vsv, "items": [{"passage_id": pid, "embedding": vec}]}))
    record("J5 embedding stored only with semantic opt-in and guardian-backed authorization", run_sql(f"select count(*) from library.passage_embedding_1536 where passage_id='{pid}'") == "1")
    rg = ok(learner.cmd(None, "create_client_grant", {"client_kind": "mcp", "label": "read-only", "scopes": ["read"], "ttl_hours": 1}))
    learner.client_token = rg["token"]
    record("J5 read-only client grant cannot run a command", err(learner.cmd(lws, "create_thread", {"title": "x", "purpose": "general"}, client=True)) == "CLIENT_SCOPE_DENIED")
    record("J5 read-only client grant can read", err(learner.read(None, "search", {"query": "duplicate"}, client=True)) is None)
    record("J5 a client grant cannot mint another grant", err(learner.cmd(None, "create_client_grant", {"client_kind": "mcp", "label": "x", "scopes": ["read"]}, client=True)) is not None)
    ok(learner.cmd(None, "revoke_client_grant", {"grant_id": rg["grantId"]}))
    record("J5 revoked client grant refused", err(learner.read(None, "search", {"query": "duplicate"}, client=True)) == "CLIENT_GRANT_INVALID")
    via = ok(john.cmd(ws, "create_work", {"kind": "note", "slug": "agent-draft-" + uuid.uuid4().hex[:6], "revision": {"title": "Agent draft", "body": body("drafted by harness agent"), "origin": "native_harness"}}, client=True))
    record("J5 command lineage records the client grant and origin",
           run_sql(f"select origin || ':' || (client_grant_id is not null) from authoring.command where result->>'workId' = '{via['workId']}'") == "mcp:true")
    doc_bytes = b"%PDF-1.4 lab fixture paper about retries"
    doc = asset(learner, lws, doc_bytes, "application/pdf", "private_copy", atype="uploaded_document")
    ok(worker("index_passages", {"workspace_id": lws, "artifact_id": doc, "procedure_version": "lab-pdf-1",
                                 "passages": [{"text": "Paper: exactly-once delivery is impossible; design idempotent consumers.", "locator": {"schema": "aieng.locator.v1", "page": 3}}]}))
    record("J5 uploaded source searchable before restriction", any(h["label"] == "uploaded_source" for h in ok(learner.read(None, "search", {"query": "idempotent consumers"}))))
    ok(worker("restrict_source", {"artifact_id": doc, "kind": "takedown", "effect": "deny_all", "reason": "lab fixture takedown notice"}))
    record("J5 takedown removes the source from every search", ok(learner.read(None, "search", {"query": "idempotent consumers"})) == [])

    # ---------------------------------------------------------------- J6 removal
    blocked = ok(john.cmd(ws, "preview_removal", {"work_id": act["workId"]}))
    record("J6 removing released material is blocked while offers are active", blocked["state"] == "blocked")
    n2 = ok(learner.cmd(lws, "create_work", {"kind": "note", "slug": "to-delete", "revision": {"title": "Delete me", "body": body("secret plan for retries")}}))
    ok(worker("index_passages", {"workspace_id": lws, "revision_id": n2["revisionId"], "procedure_version": "lab-md-1",
                                 "passages": [{"text": "secret plan for retries", "locator": {"schema": "aieng.locator.v1", "block": 0}}]}))
    pv = ok(learner.cmd(lws, "preview_removal", {"work_id": n2["workId"]}))
    done = ok(learner.cmd(lws, "confirm_removal", {"removal_id": pv["removalId"]}))
    after = ok(learner.read(None, "get_revision", {"revision_id": n2["revisionId"]}))
    record("J6 removal purges body and passages, keeps a tombstone", done["purgedRevisions"] == 1 and done["deletedPassages"] == 1 and after["purged"] is True
           and "secret" not in json.dumps(after["body"]))
    record("J6 purged content no longer searchable", ok(learner.read(None, "search", {"query": "secret plan"})) == [])
    proj_after = ok(learner.cmd(lws, "preview_removal", {"work_id": proj["workId"]}))
    record("J6 impact shows retained submission evidence", proj_after["impact"]["retained_submission_evidence"] == 1)

    # ---------------------------------------------------------------- J7 storage and table denial; J8 idempotency
    path = run_sql(f"select object_path from orchestration.artifact where id='{rel['manifestArtifactId']}'")
    s1, _ = http("GET", f"/storage/v1/object/authenticated/aieng-workspaces/{path}", token=learner.token)
    s2, b2 = http("POST", "/storage/v1/object/list/aieng-workspaces", {"prefix": "", "limit": 10}, token=learner.token)
    s3, _ = http("GET", f"/storage/v1/object/public/aieng-workspaces/{path}")
    record("J7 learner cannot download product bytes directly from Storage", s1 in (400, 403, 404), str(s1))
    record("J7 learner cannot list the private bucket", s2 != 200 or b2 == [], f"{s2}")
    record("J7 bucket is not public", s3 in (400, 403, 404), str(s3))
    s4, b4 = http("GET", "/rest/v1/work?select=id", token=learner.token, headers={"Accept-Profile": "authoring"})
    record("J7 product tables are not reachable through REST", s4 in (400, 401, 403, 404, 406), str(s4))
    k = "idem-" + uuid.uuid4().hex
    a1 = ok(learner.cmd(lws, "create_thread", {"title": "idem", "purpose": "general"}, key=k))
    a2 = ok(learner.cmd(lws, "create_thread", {"title": "idem", "purpose": "general"}, key=k))
    record("J8 idempotent replay returns the stored result", a1["threadId"] == a2["threadId"] and a2["replayed"] is True)
    record("J8 key reuse with different input conflicts", err(learner.cmd(lws, "create_thread", {"title": "other", "purpose": "general"}, key=k)) == "CONFLICT")

    # ---------------------------------------------------------------- J9 Build 05: worked lesson section, sites, learner layer, projects, challenges, environments
    def K():
        return str(uuid.uuid4())

    def blk(t, **kw):
        b = {"key": kw.pop("key", None) or K(), "type": t}
        b.update(kw)
        return b

    vid = asset(john, ws, os.urandom(256), "video/mp4", "redistributable")
    transcript = asset(john, ws, b"[00:00] Retries without idempotency duplicate side effects.", "text/plain", "redistributable")
    captions = asset(john, ws, b"WEBVTT\n\n00:00.000 --> 00:04.000\nRetries without idempotency duplicate side effects.\n", "text/vtt", "redistributable")
    mmd = asset(john, ws, b"flowchart LR\n  A[run] -->|retry| B[side effect]\n", "text/plain", "redistributable")
    devc = asset(john, ws, b'{"image":"python:3.12","postCreateCommand":"pip install langgraph"}', "application/json", "redistributable")
    hidden_quiz = asset(john, ws, b'{"answers":["b"]}', "application/json", "private_copy")
    # a harness-built three-file site, registered through John's MCP client grant
    site = {"index.html": b"<!doctype html><script src=app.js></script><link rel=stylesheet href=style.css>", "app.js": b"console.log('retry sim')", "style.css": b"body{font:16px sans-serif}"}
    site_ids = {p_: asset(john, ws, b_, "text/html" if p_.endswith(".html") else "text/plain", "redistributable") for p_, b_ in site.items()}
    record("J9 path traversal in a file set is rejected",
           err(john.cmd(ws, "register_file_set", {"entrypoint": "index.html", "files": [{"path": "../index.html", "artifact_id": site_ids["index.html"]}, {"path": "index.html", "artifact_id": site_ids["index.html"]}]}, client=True)) is not None)
    fs = ok(john.cmd(ws, "register_file_set", {"entrypoint": "index.html", "files": [{"path": p_, "artifact_id": a_} for p_, a_ in site_ids.items()]}, client=True))
    dep = ok(john.cmd(ws, "record_deployment", {"file_set_id": fs["fileSetId"], "target": "platform_static", "environment": "preview"}, client=True))
    record("J9 harness-built site becomes a 3-file set with a per-deployment isolated-origin preview URL",
           run_sql(f"select file_count || ':' || origin from authoring.file_set where id='{fs['fileSetId']}'") == "3:mcp"
           and dep["url"].startswith(f"https://{dep['deploymentId']}.preview.") and dep["status"] == "pending")
    ok(worker("set_deployment_status", {"deployment_id": dep["deploymentId"], "status": "live"}))
    ui = ok(john.cmd(ws, "create_work", {"kind": "component", "slug": "quiz-renderer", "revision": {"title": "Quiz renderer v1", "body": body("Renders single-choice checks", {"renderer_id": "quiz", "input_schema": {"type": "object"}})}}))
    snip = ok(john.cmd(ws, "create_work", {"kind": "snippet", "slug": "retry-diagram", "revision": {"title": "Retry diagram", "body": {"formatVersion": 2, "blocks": [
        blk("diagram", fallback="A run retries and repeats its side effect", bindings=["src"])]},
        "bindings": [{"local_key": "src", "relation": "representation", "role": "original", "target": {"kind": "artifact", "id": mmd}, "usage": "redistributable"}]}}))
    ch1 = ok(john.cmd(ws, "create_work", {"kind": "challenge", "slug": "add-idempotency-key", "revision": {"title": "Add an idempotency key", "body": body("Make the ingestion step idempotent.",
        {"challenge": {"schema": "aieng.challenge.v1", "designed_by": "system", "runs_in": "browser_runtime", "browser_runtime": "pyodide", "verification": ["auto_in_app", "runner"]}})}}))
    ch2 = ok(john.cmd(ws, "create_work", {"kind": "challenge", "slug": "deploy-and-break", "revision": {"title": "Deploy, then survive an incident", "body": body("Deploy for real and handle a forced failure.",
        {"challenge": {"schema": "aieng.challenge.v1", "designed_by": "system", "runs_in": "real_deployment", "verification": ["external_evidence", "rubric", "defense"]}})}}))
    tmpl = ok(john.cmd(ws, "create_work", {"kind": "project_template", "slug": "research-agent", "revision": {"title": "Build a research-and-ingestion agent", "body": body("Guided project with two milestones",
        {"project_template": {"schema": "aieng.project-template.v1", "mode": "challenge_based"}}),
        "parts": [{"occurrence_key": K(), "child_revision_id": ch1["revisionId"], "ordinal": 0}, {"occurrence_key": K(), "child_revision_id": ch2["revisionId"], "ordinal": 1}],
        "bindings": [{"local_key": "env", "relation": "uses", "role": "environment_spec", "target": {"kind": "artifact", "id": devc}, "usage": "redistributable"}]}}))
    vkey = K()
    v_bad = {"formatVersion": 2, "blocks": [blk("video", key=vkey, fallback="Video about retries", bindings=["vo", "vt"])]}
    vb = [{"local_key": "vo", "relation": "representation", "role": "original", "target": {"kind": "artifact", "id": vid}, "usage": "redistributable"},
          {"local_key": "vt", "relation": "representation", "role": "transcript", "target": {"kind": "artifact", "id": transcript}, "usage": "redistributable"},
          {"local_key": "vc", "relation": "representation", "role": "captions", "target": {"kind": "artifact", "id": captions}, "usage": "redistributable"}]
    record("J9 a video block without captions is rejected", err(john.cmd(ws, "create_work", {"kind": "lesson", "slug": "bad-video", "revision": {"title": "x", "body": v_bad, "bindings": vb}})) == "VALIDATION")
    record("J9 a non-text block without a text fallback is rejected", err(john.cmd(ws, "create_work", {"kind": "lesson", "slug": "bad-fallback", "revision": {"title": "x",
        "body": {"formatVersion": 2, "blocks": [blk("math", content={"latex": "e^{i\\pi}"})]}}})) == "VALIDATION")
    record("J9 an unknown block type is rejected", err(john.cmd(ws, "create_work", {"kind": "lesson", "slug": "bad-type", "revision": {"title": "x",
        "body": {"formatVersion": 2, "blocks": [blk("hologram", fallback="x")]}}})) == "VALIDATION")
    record("J9 an interactive block must name a component", err(john.cmd(ws, "create_work", {"kind": "lesson", "slug": "bad-int", "revision": {"title": "x",
        "body": {"formatVersion": 2, "blocks": [blk("interactive", fallback="quiz", content={})]}}})) == "VALIDATION")
    record("J9 a block naming a revision without a uses binding is rejected (closure would miss it)", err(john.cmd(ws, "create_work", {"kind": "lesson", "slug": "bad-ref", "revision": {"title": "x",
        "body": {"formatVersion": 2, "blocks": [blk("challenge_embed", fallback="c", content={"challenge_revision_id": ch1["revisionId"]})]}}})) == "VALIDATION")
    lesson_blocks = [
        blk("section", content={"title": "Why retries duplicate work"}, children=[
            blk("text", content={"markdown": "When a run retries, every **side effect** may happen twice."}),
            blk("callout", content={"tone": "warning", "markdown": "Exactly-once delivery is not available; design idempotent consumers."}),
            blk("math", content={"latex": "P(\\text{dup}) = 1-(1-p)^{r}"}, fallback="Probability of a duplicate grows with the retry count"),
            blk("video", key=vkey, fallback="Two-minute walkthrough of a duplicated write", bindings=["vo", "vt", "vc"]),
            blk("snippet_ref", bindings=["snip"])]),
        blk("section", content={"title": "Try it"}, children=[
            blk("embedded_site", fallback="Interactive retry simulator (open link)", bindings=["site"], content={"deployment_id": dep["deploymentId"]}),
            blk("quiz", fallback="Which change prevents the duplicate? (a) longer timeout (b) idempotency key", content={"component_revision_id": ui["revisionId"]}, bindings=["qkey", "comp"]),
            blk("code", content={"language": "python", "text": "def with_retry(fn, attempts=3): ..."}),
            blk("sources_panel", content={"note": "Why idempotency keys rather than locks"}),
            blk("challenge_embed", fallback="Challenge: add an idempotency key", content={"challenge_revision_id": ch1["revisionId"]}, bindings=["ch1"]),
            blk("project_milestone", fallback="Project milestone 1 of the research agent", content={"project_template_revision_id": tmpl["revisionId"], "milestone": 0}, bindings=["tmpl"])])]
    lesson_bindings = vb + [
        {"local_key": "snip", "relation": "uses", "target": {"kind": "revision", "id": snip["revisionId"]}},
        {"local_key": "site", "relation": "representation", "role": "build", "target": {"kind": "file_set", "id": fs["fileSetId"]}, "usage": "redistributable"},
        {"local_key": "qkey", "relation": "evaluates_with", "role": "hidden_check", "target": {"kind": "artifact", "id": hidden_quiz}, "usage": "private_copy"},
        {"local_key": "comp", "relation": "uses", "target": {"kind": "revision", "id": ui["revisionId"]}},
        {"local_key": "ch1", "relation": "uses", "target": {"kind": "revision", "id": ch1["revisionId"]}},
        {"local_key": "tmpl", "relation": "uses", "target": {"kind": "revision", "id": tmpl["revisionId"]}}]
    lesson = ok(john.cmd(ws, "create_work", {"kind": "lesson", "slug": "retries-and-idempotency", "revision": {"title": "Retries and idempotency", "body": {"formatVersion": 2, "blocks": lesson_blocks}, "bindings": lesson_bindings}}))
    nblocks = run_sql(f"select count(*) || ':' || count(*) filter (where parent_key is not null) from authoring.revision_block where revision_id='{lesson['revisionId']}'")
    record("J9 worked lesson section saved with 13 blocks (2 sections, 11 nested) in the block projection", nblocks == "13:11", nblocks)
    mod2 = ok(john.cmd(ws, "create_work", {"kind": "module", "slug": "reliable-ingestion", "revision": {"title": "Reliable ingestion", "body": body("Module 2"),
        "parts": [{"occurrence_key": K(), "child_revision_id": lesson["revisionId"], "ordinal": 0}, {"occurrence_key": K(), "child_revision_id": tmpl["revisionId"], "ordinal": 1}]}}))
    ok2, rk2 = K(), K()
    c2 = ok(john.cmd(ws, "create_work", {"kind": "course", "slug": "real-agents", "revision": {"title": "Real agents in production", "body": body("Course with a real project"),
        "parts": [{"occurrence_key": K(), "child_revision_id": mod2["revisionId"], "ordinal": 0}],
        "outcomes": [{"outcome_key": ok2, "statement": "Ship and operate a real research agent", "bloom_level": "create", "evidence_rule": RULE}],
        "requirements": [{"requirement_key": rk2, "kind": "outcome", "outcome_key": ok2, "rationale": "the real project",
                          "options": [{"route": "standard", "activity_revision_id": tmpl["revisionId"], "evidence_rule": RULE, "approval_state": "approved"},
                                      {"route": "learner_project", "evidence_rule": RULE, "approval_state": "approved"}]}]}}))
    ex2 = ok(john.read(ws, "preview_exposure", {"root_revision_id": c2["revisionId"], "ceiling": "named"}))
    site_items = [i for i in ex2["items"] if i["item_key"].count(":") == 2 and i["disposition"] == "include"]
    hidden_items = [i for i in ex2["items"] if i["disposition"] == "withheld"]
    record("J9 release closure expands the site's 3 files and withholds the hidden quiz key", len(site_items) == 3 and len(hidden_items) == 1 and not ex2["blockers"],
           f"site={len(site_items)} withheld={len(hidden_items)} blockers={ex2['blockers']}")
    ev2 = ok(john.cmd(ws, "review_revision", {"work_id": c2["workId"], "revision_id": c2["revisionId"], "review": {"reviewType": "release_review", "decision": "approve",
                       "closure_sha256": ex2["closure_sha256"], "ceiling": "named"}}))["eventId"]
    rel2 = ok(john.cmd(ws, "freeze_release", {"root_revision_id": c2["revisionId"], "ceiling": "named", "approval_event_id": ev2}))
    store_and_complete(rel2["objectPath"], rel2["manifestArtifactId"], rel2["manifestText"].encode(), "application/json")
    d2 = ok(john.cmd(ws, "open_distribution", {"root_work_id": c2["workId"], "channel": "invited", "title": "Real agents cohort"}))["distributionId"]
    ok(john.cmd(ws, "grant_reader", {"distribution_id": d2, "principal_id": learner.id}))
    of2 = ok(john.cmd(ws, "offer_release", {"distribution_id": d2, "release_id": rel2["releaseId"], "terms": terms, "approval_event_id": ev2}))["offerId"]
    en2 = ok(learner.cmd(lws, "enroll", {"distribution_id": d2}))["enrollmentId"]
    ad2 = ok(learner.cmd(lws, "adopt_release", {"enrollment_id": en2, "offer_id": of2, "reason": "start"}))["adoptionId"]
    view = ok(learner.read(None, "get_lesson_view", {"revision_id": lesson["revisionId"]}))
    record("J9 learner renders the released lesson: 13 blocks, nothing hidden in the body", len(view["blocks"]) == 13 and "answers" not in json.dumps(view))
    record("J9 outsider cannot open the invited lesson", err(outsider.read(None, "get_lesson_view", {"revision_id": lesson["revisionId"]})) == "NOT_FOUND")
    li = run_sql(f"select id from authoring.release_item where release_id='{rel2['releaseId']}' and revision_id='{lesson['revisionId']}'")
    record("J9 an anchor to a block that is not in the lesson is refused",
           err(learner.cmd(lws, "create_work", {"kind": "note", "slug": "bad-anchor", "revision": {"title": "x", "body": body("x"),
               "bindings": [{"local_key": "a", "relation": "anchored_to", "target": {"kind": "release_item", "id": li}, "block_key": K()}]}})) == "NOT_FOUND")
    mynote = ok(learner.cmd(lws, "create_work", {"kind": "note", "slug": "my-video-notes", "revision": {"title": "My notes on the video",
        "body": {"formatVersion": 2, "blocks": [blk("text", content={"markdown": "Key insight: idempotency key = request identity."})]},
        "bindings": [{"local_key": "a", "relation": "anchored_to", "target": {"kind": "release_item", "id": li}, "block_key": vkey}]}}))
    gen = ok(learner.cmd(lws, "create_work", {"kind": "experience", "slug": "my-generated-explainer", "revision": {"title": "Assistant-generated explainer", "origin": "agent",
        "body": {"formatVersion": 2, "blocks": [blk("text", content={"markdown": "A simpler explanation generated for me."})]},
        "bindings": [{"local_key": "a", "relation": "anchored_to", "target": {"kind": "release_item", "id": li}, "block_key": vkey}]}}))
    lv = ok(learner.read(None, "get_lesson_view", {"revision_id": lesson["revisionId"]}))
    record("J9 learner sees their private layer (note + generated explainer) inline on the video block",
           sorted(x["kind"] for x in lv["learnerLayer"]) == ["experience", "note"] and all(x["blockKey"] == vkey for x in lv["learnerLayer"]))
    record("J9 the course owner does not see the learner's private layer", ok(john.read(ws, "get_lesson_view", {"revision_id": lesson["revisionId"]}))["learnerLayer"] == [])
    # stable block keys across revisions (learner's own lesson, so no re-release is needed)
    kk, kd = K(), K()
    own = ok(learner.cmd(lws, "create_work", {"kind": "lesson", "slug": "my-lesson", "revision": {"title": "My lesson",
        "body": {"formatVersion": 2, "blocks": [blk("text", key=kk, content={"markdown": "keep"}), blk("text", key=kd, content={"markdown": "drop"})]}}}))
    for key_, slug_ in ((kk, "on-kept"), (kd, "on-dropped")):
        ok(learner.cmd(lws, "create_work", {"kind": "note", "slug": slug_, "revision": {"title": slug_, "body": body("n"),
            "bindings": [{"local_key": "a", "relation": "anchored_to", "target": {"kind": "revision", "id": own["revisionId"]}, "block_key": key_}]}}))
    own2 = ok(learner.cmd(lws, "revise_work", {"work_id": own["workId"], "revision": {"title": "My lesson",
        "body": {"formatVersion": 2, "blocks": [blk("text", key=kk, content={"markdown": "keep, edited"})]}}}, head=own["revisionId"]))
    lv2 = ok(learner.read(None, "get_lesson_view", {"revision_id": own2["revisionId"]}))
    record("J9 an annotation follows its stable block key into the next revision; one on a removed block does not",
           [(x["title"], x["carriedForward"]) for x in lv2["learnerLayer"]] == [("on-kept", True)], str(lv2["learnerLayer"]))
    # projects and environments
    tmpl_item = run_sql(f"select id from authoring.release_item where release_id='{rel2['releaseId']}' and revision_id='{tmpl['revisionId']}'")
    inst = ok(learner.cmd(lws, "create_work", {"kind": "project", "slug": "my-research-agent", "revision": {"title": "My research agent",
        "body": body("From the template", {"project": {"schema": "aieng.project.v1", "origin": "template"}}),
        "bindings": [{"local_key": "tpl", "relation": "adapted_from", "target": {"kind": "release_item", "id": tmpl_item}}]}}))
    record("J9 learner project instance derived from the released template", bool(inst["revisionId"]))
    record("J9 a secret value in an environment key handle is refused",
           err(learner.cmd(lws, "request_environment", {"provider": "local_harness", "key_handles": [{"name": "OPENAI_API_KEY", "value": "sk-live-123", "source": "byo"}]})) == "VALIDATION")
    env_local = ok(learner.cmd(lws, "request_environment", {"provider": "local_harness", "project_work_id": inst["workId"], "spec_revision_id": tmpl["revisionId"],
                                                            "key_handles": [{"name": "OPENAI_API_KEY", "source": "byo"}]}))
    record("J9 local harness environment with the learner's own keys is ready at once", env_local["status"] == "ready")
    record("J9 platform keys need an issued provided credential",
           err(learner.cmd(lws, "request_environment", {"provider": "cloud_sandbox", "adapter": "e2b", "key_handles": [{"name": "OPENAI_API_KEY", "source": "platform", "provided_credential_id": K()}]})) == "NOT_FOUND")
    pc = ok(worker("issue_provided_credential", {"principal_id": learner.id, "provider_key": "openai", "secret_handle": "vault:platform/openai/course-real-agents", "spend_limit_usd": 5, "period": "month"}))
    env_cloud = ok(learner.cmd(lws, "request_environment", {"provider": "cloud_sandbox", "adapter": "e2b", "spec_revision_id": tmpl["revisionId"], "spend_limit_usd": 5,
                                                            "key_handles": [{"name": "OPENAI_API_KEY", "source": "platform", "provided_credential_id": pc["providedCredentialId"]}]}))
    record("J9 cloud sandbox with a platform key (spend-limited) is requested for provisioning", env_cloud["status"] == "requested")
    att_t = ok(learner.cmd(lws, "start_attempt", {"purpose": "official", "task_release_item_id": tmpl_item, "enrollment_id": en2, "adoption_id": ad2, "requirement_key": rk2,
              "option_id": run_sql(f"select o.id from curriculum.requirement_option o join curriculum.requirement r on r.id=o.requirement_id where r.revision_id='{c2['revisionId']}' and o.route='standard'"),
              "environment_session_id": env_local["environmentSessionId"], "conditions": {"schema": "aieng.attempt-conditions.v1", "facet": "assisted"}}))
    record("J9 official attempt on the system project template, tied to the learner's environment", bool(att_t["attemptId"]))
    # fully custom project counted through an approved equivalence request
    lp_opt = run_sql(f"select o.id from curriculum.requirement_option o join curriculum.requirement r on r.id=o.requirement_id where r.revision_id='{c2['revisionId']}' and o.route='learner_project'")
    custom = ok(learner.cmd(lws, "create_work", {"kind": "project", "slug": "my-own-agent", "revision": {"title": "Company research agent for biotech",
        "body": body("Custom: TypeScript + Deep Agents + Postgres", {"project": {"schema": "aieng.project.v1", "origin": "custom"}})}}))
    cond = {"schema": "aieng.attempt-conditions.v1", "facet": "agent_directed"}
    record("J9 a custom project cannot be an official attempt before approval",
           err(learner.cmd(lws, "start_attempt", {"purpose": "official", "task_revision_id": custom["revisionId"], "enrollment_id": en2, "adoption_id": ad2,
               "requirement_key": rk2, "option_id": lp_opt, "conditions": cond})) == "VALIDATION")
    eq = ok(learner.cmd(lws, "propose_equivalence", {"enrollment_id": en2, "work_revision_id": custom["revisionId"], "requirement_keys": [rk2],
                                                     "evidence_plan": "Deployed agent, incident write-up and defense covering the outcome"}))
    ok(worker("record_equivalence_check", {"request_id": eq["equivalenceRequestId"], "check": {"schema": "aieng.decision-answer.v1", "status": "answered",
               "value": "covers_outcome", "confidence": 0.8, "execution": "fixture"}}))
    record("J9 the learner cannot approve their own equivalence request",
           err(learner.cmd(lws, "decide_equivalence", {"request_id": eq["equivalenceRequestId"], "decision": "approve"})) == "NOT_FOUND")
    ok(john.cmd(ws, "decide_equivalence", {"request_id": eq["equivalenceRequestId"], "decision": "approve", "reason": "covers ship-and-operate outcome"}))
    att_c = ok(learner.cmd(lws, "start_attempt", {"purpose": "official", "task_revision_id": custom["revisionId"], "enrollment_id": en2, "adoption_id": ad2,
               "requirement_key": rk2, "option_id": lp_opt, "equivalence_request_id": eq["equivalenceRequestId"], "conditions": cond}))
    ext = ok(learner.cmd(lws, "record_deployment", {"revision_id": custom["revisionId"], "target": "external", "environment": "published",
              "url": "https://my-own-agent.example.invalid", "external_ref": {"provider": "vercel", "commit": "abc123", "deployment_id": "dpl_fixture"}}))
    sub_c = ok(learner.cmd(lws, "submit_attempt", {"attempt_id": att_c["attemptId"], "items": [
        {"item_key": "project", "kind": "project_revision", "revision_id": custom["revisionId"]},
        {"item_key": "deploy", "kind": "deployment", "deployment_id": ext["deploymentId"], "availability": "reference_only"}]}))
    record("J9 approved custom project submitted with a real (registered) external deployment as evidence", bool(sub_c["submissionId"]) and ext["status"] == "live")
    # John's own personal course: equivalence approves automatically
    jws = ok(john.cmd(None, "ensure_personal_workspace"))["workspaceId"]
    jen = ok(john.cmd(jws, "enroll", {"distribution_id": d2}))["enrollmentId"]
    jp = ok(john.cmd(jws, "create_work", {"kind": "project", "slug": "john-agent", "revision": {"title": "John's agent", "body": body("custom")}}))
    jeq = ok(john.cmd(jws, "propose_equivalence", {"enrollment_id": jen, "work_revision_id": jp["revisionId"], "requirement_keys": [rk2], "evidence_plan": "own course"}))
    record("J9 a learner who owns the course gets automatic equivalence approval", jeq["state"] == "approved")
    # learner-designed challenge: practice only
    lch = ok(learner.cmd(lws, "create_work", {"kind": "challenge", "slug": "my-chaos-test", "revision": {"title": "My chaos test", "body": body("Kill the worker mid-write",
        {"challenge": {"schema": "aieng.challenge.v1", "designed_by": "learner", "runs_in": "harness", "verification": ["runner"]}})}}))
    record("J9 a learner-designed challenge runs as practice",
           bool(ok(learner.cmd(lws, "start_attempt", {"purpose": "practice", "task_revision_id": lch["revisionId"], "conditions": {"schema": "aieng.attempt-conditions.v1", "facet": "independent"}}))["attemptId"]))
    record("J9 a learner-designed challenge cannot satisfy the standard route",
           err(learner.cmd(lws, "start_attempt", {"purpose": "official", "task_revision_id": lch["revisionId"], "enrollment_id": en2, "adoption_id": ad2, "requirement_key": rk2,
               "option_id": run_sql(f"select o.id from curriculum.requirement_option o join curriculum.requirement r on r.id=o.requirement_id where r.revision_id='{c2['revisionId']}' and o.route='standard'"),
               "conditions": {"schema": "aieng.attempt-conditions.v1", "facet": "independent"}})) == "VALIDATION")

    j10_research(john, outsider, ws)

    # ---------------------------------------------------------------- direct-SQL invariants (as postgres)
    record("SQL sealed revision cannot be updated even by postgres", "immutable" in run_sql(f"update authoring.work_revision set title='x' where id='{act['revisionId']}'", allow_error=True))
    record("SQL sealed revision cannot receive new children",
           "sealed" in run_sql(f"insert into curriculum.prerequisite(tenant_id, workspace_id, revision_id, required_revision_id, strength, rationale) "
                               f"select tenant_id, workspace_id, id, '{mod['revisionId']}', 'required', 'late' from authoring.work_revision where id='{act['revisionId']}'", allow_error=True))
    record("SQL unsealed revision cannot commit",
           "seal" in run_sql(f"insert into authoring.work_revision(tenant_id, workspace_id, work_id, revision_no, title, body_schema, body, origin, created_by) "
                             f"select tenant_id, workspace_id, work_id, 99, 't', 'aieng.work-body.v1', '{{\"formatVersion\":1,\"blocks\":[]}}', 'human', created_by from authoring.work_revision where id='{act['revisionId']}'", allow_error=True))
    record("SQL released items cannot be deleted", "append-only" in run_sql(f"delete from authoring.release_item where release_id='{rel['releaseId']}'", allow_error=True))
    record("SQL authenticated role has no table privilege", "permission denied" in run_sql("set role authenticated; select count(*) from authoring.work", allow_error=True))

    out = {"ran_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()), "surface": SURFACE, "seconds": round(time.time() - t0, 1),
           "passed": sum(r["pass"] is True for r in RESULTS), "failed": sum(r["pass"] is False for r in RESULTS),
           "skipped": sum(r["pass"] is None for r in RESULTS), "checks": RESULTS}
    os.makedirs(os.path.join(LAB, "tests"), exist_ok=True)
    with open(os.path.join(LAB, "tests", f"results-{SURFACE}.json"), "w", encoding="utf-8") as f:
        json.dump(out, f, indent=2)
    print(f"\n[{SURFACE}] {out['passed']} passed, {out['failed']} failed, {out['skipped']} skipped in {out['seconds']}s")
    return 0 if out["failed"] == 0 else 1


def run_sql(sql, allow_error=False):
    p = subprocess.run(["docker", "exec", "-i", "supabase_db_disposable-aieng-build04", "psql", "-U", "postgres", "-At", "-v", "ON_ERROR_STOP=1", "-q"],
                       input=sql, capture_output=True, text=True)
    if p.returncode != 0:
        if allow_error:
            return p.stderr.strip()
        raise AssertionError(p.stderr.strip())
    return p.stdout.strip().splitlines()[-1] if p.stdout.strip() else ""


if __name__ == "__main__":
    sys.exit(main())
