"""Build 08 knowledge loop 4: source registry, attention sweeps, thread and article captures, claims, probe registration and
verdicts, assessments, projections (lab disposable-aieng-build04 only; selection in reviews/BUILD-08-LOOP-4-SELECTION.md).

Stages (idempotent, in order): registry acquire units claims probes attention assess projections embed
Run: python -I -X utf8 scripts/knowledge-lab/loop4_process.py <stage> [...]
Captures are data, not instructions. Handles are kept as published, never enriched. Model use: claim candidates from threads only,
stored only when the quote is found verbatim in one post; probe verdicts are rules over the recorded checks, never model judgments.
"""
import collections, datetime, html, json, os, re, sys, time, urllib.parse, uuid
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lab_common as C
from lab_common import *  # noqa
import loop1_acquire as A
import loop1_process as L1
import loop2_acquire as A2

RUN4 = os.path.join(C.LAB, "knowledge-loop-4")
SOURCES4 = os.path.join(C.LAB, "sources", "2026-11-13")
PROBE_RUNS = os.path.join(RUN4, "probe-runs")
SCOUT = os.path.join(RUN4, "scout")
CALLS = os.path.join(RUN4, "model-calls")
for d in (RUN4, SOURCES4, CALLS):
    os.makedirs(d, exist_ok=True)
C.RUN_DIR = A.RUN_DIR = RUN4
ORIGIN = "native harness fetch, Build 08 knowledge loop 4 (claude-code session 2026-11-13)"
LEDGER = os.path.join(RUN4, "ACQUISITION-LEDGER.jsonl")
GRAMMAR = "build08-grammar/4"
MODEL, PRICE_IN, PRICE_OUT, MODEL_BUDGET = "claude-opus-5-5", 4.0, 20.0, 6.0
SPEND_FILE = os.path.join(RUN4, "spend-model.json")
EXT = {"json": ".json", "markdown": ".md", "html": ".html"}
RECEIPT = None


def receipt():
    global RECEIPT
    if RECEIPT is None:
        RECEIPT = native_receipt("loop4-entities", {"stage": "loop4", "loop": 4})
    return RECEIPT


L1.receipt = receipt
ensure_entity, add_role, flush_roles, slugify = L1.ensure_entity, L1.add_role, L1.flush_roles, L1.slugify


def set_attrs(eid, attrs):
    attrs = {k: v for k, v in attrs.items() if v is not None}
    if attrs:
        sql(f"update catalog.entity set attributes = (attributes - {qarr(list(attrs))}) || {q(attrs)}, updated_at = now() where id = {q(eid)}")


def rel(kind, a, b, props=None):
    props = {k: v for k, v in (props or {}).items() if v is not None}
    if one(f"select 1 from catalog.relationship where kind={q(kind)} and from_entity_id={q(a)} and to_entity_id={q(b)} and k_to is null"):
        return
    out, err = sql(f"""begin; set local app.tenant_id = '{TENANT}'; select temporal.begin_batch();
        select temporal.assert_relationship({q(kind)}, {q(a)}, {q(b)}, p_properties => {q(props or {})});
        select temporal.commit_batch({q(native_receipt('loop4-rel', {'kind': kind}))}, {q('b08-loop4-rel-' + kind + '-' + a[:8] + b[:8])}, {q(sha256_text(kind + a + b))}, {q({'label': 'loop4 relationship ' + kind})}); commit;""", tenant=False, allow_error=True)
    if err:
        log(f"relationship {kind} {a[:8]}->{b[:8]}: {err[:200]}")


def ent(kind, slug):
    return one(f"select id from catalog.entity where kind={q(kind)} and slug={q(slug)}")


def strip_html(s):
    s = re.sub(r"<pre><code[^>]*>(.*?)</code></pre>", lambda m: "\n```\n" + m.group(1) + "\n```\n", s or "", flags=re.S)
    s = re.sub(r"<br\s*/?>|</p>|</li>|</h\d>", "\n", s)
    s = re.sub(r"<[^>]+>", "", s)
    return html.unescape(s).strip()


# ====================================================================================================== registry
CHANNELS = [  # slug, name, platform, channel_kind, url, operator (org slug), role, policy notes
    ("github-langchain-ai-langchain-issues", "langchain-ai/langchain issue tracker", "github", "issue_tracker", "https://github.com/langchain-ai/langchain/issues", "langchain", "community", "langchain-ai/langchain"),
    ("github-langchain-ai-langgraph-issues", "langchain-ai/langgraph issue tracker", "github", "issue_tracker", "https://github.com/langchain-ai/langgraph/issues", "langchain", "community", "langchain-ai/langgraph"),
    ("github-langchain-ai-deepagents-issues", "langchain-ai/deepagents issue tracker", "github", "issue_tracker", "https://github.com/langchain-ai/deepagents/issues", "langchain", "community", "langchain-ai/deepagents"),
    ("github-langchain-ai-langgraph-swarm-py-issues", "langchain-ai/langgraph-swarm-py issue tracker", "github", "issue_tracker", "https://github.com/langchain-ai/langgraph-swarm-py/issues", "langchain", "community", "langchain-ai/langgraph-swarm-py"),
    ("github-copilotkit-copilotkit-issues", "CopilotKit/CopilotKit issue tracker (dependent project)", "github", "issue_tracker", "https://github.com/CopilotKit/CopilotKit/issues", "copilotkit", "community", "CopilotKit/CopilotKit"),
    ("github-langfuse-langfuse-issues", "langfuse/langfuse issue tracker (dependent project)", "github", "issue_tracker", "https://github.com/langfuse/langfuse/issues", "langfuse", "community", "langfuse/langfuse"),
    ("forum-langchain-com", "LangChain Forum (forum.langchain.com)", "discourse", "forum", "https://forum.langchain.com", "langchain", "community", None),
    ("hacker-news", "Hacker News", "hacker_news", "aggregator", "https://news.ycombinator.com", "y-combinator", "community", None),
    ("stackoverflow-langgraph", "Stack Overflow (langchain / langgraph tags)", "stack_exchange", "qa_site", "https://stackoverflow.com/questions/tagged/langgraph", "stack-exchange", "community", None),
    ("docs-langchain-com", "LangChain docs (docs.langchain.com)", "web", "docs_site", "https://docs.langchain.com", "langchain", "first_party", None),
    ("agentmail-blog", "AgentMail blog (agentmail.to/blog)", "web", "blog", "https://www.agentmail.to/blog", "agentmail", "third_party_editorial", None),
    ("pypi", "PyPI (pypi.org)", "pypi", "registry", "https://pypi.org", "python-software-foundation", "registry", None),
    ("reddit-r-langchain", "reddit r/LangChain", "reddit", "social", "https://www.reddit.com/r/LangChain/", "reddit", "community", None),
    ("x-langchain", "X (posts about LangChain)", "x", "social", "https://x.com", "x-corp", "community", None),
    ("belllabs-probes", "AI Engineer probes (this system)", "belllabs", "event_site", "urn:belllabs:probes", "belllabs-aieng", "own_experiment", None),
]
ORGS = {"langchain": "LangChain", "copilotkit": "CopilotKit", "langfuse": "Langfuse", "y-combinator": "Y Combinator", "stack-exchange": "Stack Exchange", "agentmail": "AgentMail",
        "python-software-foundation": "Python Software Foundation", "reddit": "Reddit", "x-corp": "X Corp", "belllabs-aieng": "AI Engineer research (this system)"}
PRIORS = {  # channel slug -> conflict of interest, method disclosure, note
    "agentmail-blog": ("vendor_adjacent", "full", "AgentMail sells agent infrastructure and says its ranking reflects what it would pick; the post discloses model, dates, runs and install method (2026-07-08)"),
    "docs-langchain-com": ("vendor_self", "not_applicable", "the vendor documents its own libraries"),
    "github-copilotkit-copilotkit-issues": ("none", "partial", "a dependent project fixing its own docs against LangGraph v1"),
    "belllabs-probes": ("none", "full", "our probes: scripts, cells, lockfiles and outputs recorded"),
}


def stage_registry():
    org_ids = {s: ensure_entity("organization", s, n) for s, n in ORGS.items()}
    for slug, name, platform, kind, url, op, role, repo in CHANNELS:
        cid = ensure_entity("source_channel", slug, name, {"platform": platform, "channel_kind": kind, "url": url, "repository": repo})
        rel("operates_channel", org_ids[op], cid)
        coi, disc, note = PRIORS.get(slug, ("none" if role == "community" else "unknown", "not_applicable", f"{role} channel"))
        if not one(f"select 1 from evidence.source_assessment where subject_entity_id={q(cid)} and method='prior'"):
            prior = int(one(f"select authority_rank from content.source_role where code={q(role)}"))
            sql(f"""insert into evidence.source_assessment(subject_entity_id, topic_entity_id, method, source_role_code, conflict_of_interest, method_disclosure, authority_score, recommended_watch_level, rationale, inputs, assessed_by)
                    values ({q(cid)}, null, 'prior', {q(role)}, {q(coi)}, {q(disc)}, {prior}, null, {q('prior from source role ' + role + ': ' + note)}, {q({'prior': prior})}, 'agent:loop4_process registry (rule)')""")
    # organizations as publishers: the vendor speaks first party about its own libraries; AgentMail is third-party editorial (vendor-adjacent); we are own_experiment
    for slug, role, coi, disc, note in (("langchain", "first_party", "vendor_self", "not_applicable", "the vendor about its own libraries"), ("agentmail", "third_party_editorial", "vendor_adjacent", "full", "sells agent infrastructure; its comparison post discloses method"),
                                        ("belllabs-aieng", "own_experiment", "none", "full", "this system's probes and findings")):
        oid = org_ids[slug]
        if not one(f"select 1 from evidence.source_assessment where subject_entity_id={q(oid)} and method='prior'"):
            prior = int(one(f"select authority_rank from content.source_role where code={q(role)}"))
            sql(f"""insert into evidence.source_assessment(subject_entity_id, method, source_role_code, conflict_of_interest, method_disclosure, authority_score, rationale, inputs, assessed_by)
                    values ({q(oid)}, 'prior', {q(role)}, {q(coi)}, {q(disc)}, {prior}, {q('prior from source role ' + role + ': ' + note)}, {q({'prior': prior})}, 'agent:loop4_process registry (rule)')""")
    log(f"registry: {one('select count(*) from catalog.entity where kind=' + q('source_channel'))} channels, {one('select count(*) from evidence.source_assessment')} assessments")


# ====================================================================================================== acquisition (threads, article, registry pages)
THREADS = [  # key, kind, channel slug, api urls, html url, policy slug
    ("gh-langchain-36957", "issue_thread", "github-langchain-ai-langchain-issues", ("langchain-ai/langchain", 36957), "vendor-issues-on-release"),
    ("gh-langchain-34974", "issue_thread", "github-langchain-ai-langchain-issues", ("langchain-ai/langchain", 34974), "vendor-issues-on-release"),
    ("gh-langchain-33787", "issue_thread", "github-langchain-ai-langchain-issues", ("langchain-ai/langchain", 33787), "vendor-issues-on-release"),
    ("gh-langchain-33504", "issue_thread", "github-langchain-ai-langchain-issues", ("langchain-ai/langchain", 33504), "vendor-issues-on-release"),
    ("gh-langchain-35011", "issue_thread", "github-langchain-ai-langchain-issues", ("langchain-ai/langchain", 35011), "vendor-issues-on-release"),
    ("gh-langchain-33808", "issue_thread", "github-langchain-ai-langchain-issues", ("langchain-ai/langchain", 33808), "vendor-issues-on-release"),
    ("gh-langgraph-6731", "issue_thread", "github-langchain-ai-langgraph-issues", ("langchain-ai/langgraph", 6731), "vendor-issues-on-release"),
    ("gh-langgraph-9072", "issue_thread", "github-langchain-ai-langgraph-issues", ("langchain-ai/langgraph", 9072), "vendor-issues-on-release"),
    ("gh-deepagents-2184", "issue_thread", "github-langchain-ai-deepagents-issues", ("langchain-ai/deepagents", 2184), "vendor-issues-on-release"),
    ("gh-deepagents-573", "issue_thread", "github-langchain-ai-deepagents-issues", ("langchain-ai/deepagents", 573), "vendor-issues-on-release"),
    ("gh-copilotkit-6614", "issue_thread", "github-copilotkit-copilotkit-issues", ("CopilotKit/CopilotKit", 6614), "dependents-on-major"),
    ("gh-swarm-106", "issue_thread", "github-langchain-ai-langgraph-swarm-py-issues", ("langchain-ai/langgraph-swarm-py", 106), "dependents-on-major"),
    ("gh-langfuse-10828", "issue_thread", "github-langfuse-langfuse-issues", ("langfuse/langfuse", 10828), "dependents-on-major"),
]
FORUM_TITLES = ["Versions of langchain libraries do not satisfy", "Create_react_agent.invoke throwing error", "Call multiple deep agent from a parent langgraph/deepagent",
                "How to persist intermediate subagent messages in deep agents (survive page reload)?", "Inter Communication between agents using create_agent as a supervisor and as a tools"]
HN_IDS = {"46386009": "Critical vulnerability in LangChain – CVE-2025-68664", "47132187": "Does anyone use CrewAI or LangChain anymore?", "48761132": "Comparing Fable and 10 other LLMs on refactoring a LangGraph god node"}
SO_TITLE = "LangGraph agent, built using create_react_agent, ignores the outputs from callable tools"
ARTICLE = dict(key="article-agentmail-frameworks-2026", kind="comparison_article", role="third_party_editorial", fmt="markdown", url="https://www.agentmail.to/blog/best-ai-agent-frameworks-2026",
               title="The 10 Best AI Agent Frameworks in 2026 (We Tested Every Single One) | AgentMail", publisher="AgentMail", channel="agentmail-blog", published_at="2026-07-08", byline="Binoy Perera", policy="comparison-articles")
REGISTRY_PAGES = [dict(key="pypi-langgraph-l4", kind="package_version_page", role="registry", fmt="json", url="https://pypi.org/pypi/langgraph/json", title="PyPI: langgraph", publisher="PyPI", channel="pypi", software="langgraph", accept="application/json"),
                  dict(key="pypi-deepagents-l4", kind="package_version_page", role="registry", fmt="json", url="https://pypi.org/pypi/deepagents/json?l4", title="PyPI: deepagents (loop 4 refresh)", publisher="PyPI", channel="pypi", software="deepagents", accept="application/json")]


def save(key, body, fmt):
    path = os.path.join(SOURCES4, f"{key}-{sha256_bytes(body)[:12]}{EXT.get(fmt, '.bin')}")
    if not os.path.exists(path):
        open(path, "wb").write(body)
    return path


def register_capture4(src, body, fetched, requested_at, fmt, sweep_id, tool="http", credits=None):
    sha = sha256_bytes(body)
    media = A.MEDIA_BY_FMT.get(fmt, "application/octet-stream")
    fetch_id = str(uuid.uuid4())
    sql(f"""insert into acquisition.fetch(id, tenant_id, origin_kind, origin_label, tool, tool_version, request_url, final_url, requested_at, completed_at, http_status, outcome, content_sha256, media_type, size_bytes, credits_used, notes, sweep_id)
            values ({q(fetch_id)}, {q(TENANT)}, 'native_harness', {q(ORIGIN)}, {q(tool)}, 'urllib/python3.12', {q(src['url'])}, {q(fetched.get('final_url'))}, {q(requested_at)}, now(), {q(fetched.get('status'))}, 'captured', {q(sha)}, {q(media)}, {len(body)}, {q(credits)}, {q({'kind': src['kind'], 'format': fmt, 'loop': 4, 'api_urls': src.get('api_urls')})}, {q(sweep_id)})""")
    object_path = f"{TENANT}/sha256/{sha}"
    artifact = one(f"select id from orchestration.artifact where tenant_id={q(TENANT)} and storage_bucket='lab-sources' and object_path={q(object_path)}")
    if not artifact:
        artifact = str(uuid.uuid4())
        sql(f"""insert into orchestration.artifact(id, tenant_id, artifact_type, schema_version, sha256, bucket_class, storage_bucket, object_path, media_type, size_bytes, storage_state, available_at)
                values ({q(artifact)}, {q(TENANT)}, 'source_capture', 1, {q(sha)}, 'source_captures', 'lab-sources', {q(object_path)}, {q(media)}, {len(body)}, 'available', now())""")
    cap = one(f"select id from evidence.source_capture where artifact_id={q(artifact)}")
    source_id = A.ensure_source(src, src["url"], src["publisher"], "api" if fmt == "json" else "web_page")
    sql(f"update evidence.source set channel_entity_id = {q(ent('source_channel', src['channel']))} where id = {q(source_id)} and channel_entity_id is null")
    if not cap:
        cap = str(uuid.uuid4())
        method = "probe_execution" if src.get("probe") else "native_harness_http"
        sql(f"""insert into evidence.source_capture(id, tenant_id, source_id, artifact_id, content_sha256, media_type, captured_at, capture_method, capture_method_version, request_url, http_status, context, acquisition_fetch_id)
                values ({q(cap)}, {q(TENANT)}, {q(source_id)}, {q(artifact)}, {q(sha)}, {q(media)}, {q(requested_at)}, {q(method)}, '0.4', {q(src['url'])}, {q(fetched.get('status'))}, {q({'origin': ORIGIN, 'tool': tool})}, {q(fetch_id)});
                update evidence.source set capture_count = capture_count + 1, last_seen_at = now(), last_capture_id = {q(cap)} where id = {q(source_id)}""")
    return fetch_id, cap, sha, artifact


def ensure_document4(src):
    doc = one(f"select id from content.document where tenant_id={q(TENANT)} and canonical_title={q(src['title'])} and document_type_code={q(src['kind'])}")
    if doc:
        return doc
    doc = str(uuid.uuid4())
    source_id = A.ensure_source(src, src["url"], src["publisher"], "api" if src["fmt"] == "json" else "web_page")
    attrs = {k: v for k, v in src.items() if k not in ("url", "title", "fmt", "accept", "kind", "role", "api_urls") and v is not None}
    attrs["loop"] = 4
    sql(f"""insert into content.document(id, tenant_id, document_type_code, canonical_title, canonical_source_id, lifecycle, source_role_code, source_role_method, attributes)
            values ({q(doc)}, {q(TENANT)}, {q(src['kind'])}, {q(src['title'])}, {q(source_id)}, 'active', {q(src['role'])}, 'rule', {q(attrs)});
            insert into content.document_kind_assignment(tenant_id, document_id, document_type_code, method, confidence, rationale)
            values ({q(TENANT)}, {q(doc)}, {q(src['kind'])}, 'rule', 0.95, 'loop-4 selection (BUILD-08-LOOP-4-SELECTION.md §6)')""")
    return doc


def capture(src, body, fetched, sweep_id, fmt="json", tool="http", credits=None, published_at=None):
    doc = ensure_document4(src)
    if one(f"select 1 from content.document_version where document_id={q(doc)} and manifest_sha256={q(sha256_bytes(body))}"):
        return doc, None
    requested_at = now_iso()
    path = save(src["key"], body, fmt)
    f_id, cap, sha, art = register_capture4(src, body, fetched, requested_at, fmt, sweep_id, tool=tool, credits=credits)
    ver, _ = A.add_version(doc, cap, sha, art, fmt, f"l4-{requested_at[:10]}-{sha[:8]}", published_at=published_at)
    append_jsonl(LEDGER, {"key": src["key"], "url": src["url"], "sha256": sha, "bytes": len(body), "format": fmt, "fetch_id": f_id, "capture_id": cap, "version_id": ver, "document_id": doc, "file": os.path.basename(path), "sweep_id": sweep_id, "at": requested_at})
    return doc, ver


def policy_id(slug):
    return one(f"select id from acquisition.attention_policy where slug={q(slug)}")


def open_sweep(policy, trigger, ref, note, window=(None, None)):
    sid = str(uuid.uuid4())
    sql(f"""insert into acquisition.attention_sweep(id, policy_id, trigger_kind, trigger_ref, origin_kind, window_from, window_to, note, receipt_id)
            values ({q(sid)}, {q(policy_id(policy))}, {q(trigger)}, {q(ref)}, 'standalone', {q(window[0])}, {q(window[1])}, {q(note)}, {q(native_receipt('loop4-sweep-' + policy, {'trigger': trigger}))})""")
    return sid


def close_sweep(sid, seen, selected, captured, rejected, spend=0.0, credits=0, outcome="completed"):
    sql(f"""update acquisition.attention_sweep set ended_at = now(), items_seen = {seen}, items_selected = {selected}, items_captured = {captured}, rejected = {q(rejected)}, spend_usd = {spend}, credits = {credits}, outcome = {q(outcome)} where id = {q(sid)}""")


def gh_thread(repo, n):
    i = A2.http(f"https://api.github.com/repos/{repo}/issues/{n}", accept=A2.GITHUB_ACCEPT, github=True)
    c = A2.http(f"https://api.github.com/repos/{repo}/issues/{n}/comments?per_page=100", accept=A2.GITHUB_ACCEPT, github=True)
    assert i["status"] == 200 and c["status"] == 200, (repo, n, i["status"], c["status"])
    issue = json.loads(i["body"])
    body = json.dumps({"issue": issue, "comments": json.loads(c["body"])}, ensure_ascii=False, sort_keys=True).encode("utf-8")
    return issue, body, {"status": 200, "final_url": issue["html_url"]}


def stage_acquire():
    # the scout is the backfill sweep of every W2/W3 community policy: seen = scout candidates of the channel, selected = §6 picks
    cands = json.load(open(os.path.join(SCOUT, "candidates.json"), encoding="utf-8"))
    by_channel = collections.Counter(c["channel"] for c in cands if c.get("query") != "gh-langgraph-v1-compat")
    sweeps = {}
    for pol, chan_key, note in (("vendor-issues-on-release", "github", "Phase A scout, GitHub search across vendor and dependent trackers (11 queries; one over-broad OR query excluded)"),
                                ("forum-weekly", "forum.langchain.com", "Phase A scout, Discourse search (4 queries)"), ("hn-monthly", "news.ycombinator.com", "Phase A scout, HN Algolia (4 queries)"),
                                ("stackoverflow-quarterly", "stackoverflow.com", "Phase A scout, Stack Exchange (3 queries)"), ("comparison-articles", "article", "the article John shared (2026-11-12)")):
        existing = one(f"select id from acquisition.attention_sweep where policy_id={q(policy_id(pol))} and trigger_kind='backfill'")
        sweeps[pol] = existing or open_sweep(pol, "backfill", {"scout": "knowledge-loop-4/scout/candidates.json"}, note, ("2025-09-01", "2026-11-13"))
    seen = collections.Counter()
    # GitHub threads
    for key, kind, chan, (repo, n), pol in THREADS:
        sw = sweeps["dependents-on-major" if pol == "dependents-on-major" else "vendor-issues-on-release"] if pol != "dependents-on-major" else sweeps["vendor-issues-on-release"]
        issue, body, fetched = gh_thread(repo, n)
        src = dict(key=key, kind=kind, role="community", fmt="json", url=issue["html_url"], title=f"{repo}#{n}: {issue['title']}", publisher=repo, channel=chan, repo=repo, number=n, thread_state=issue["state"], state_reason=issue.get("state_reason"),
                   created_at=issue["created_at"], closed_at=issue.get("closed_at"), api_urls=[f"https://api.github.com/repos/{repo}/issues/{n}", f"https://api.github.com/repos/{repo}/issues/{n}/comments"])
        capture(src, body, fetched, sw, published_at=issue["created_at"])
        seen["github"] += 1
        time.sleep(0.4)
    # forum topics (ids from the scout by title)
    topics = {c["title"]: c["url"] for c in cands if c["channel"] == "forum.langchain.com"}
    for t in FORUM_TITLES:
        url = topics.get(t)
        if not url:
            log(f"forum: no scout url for {t!r}")
            continue
        tid = url.rstrip("/").split("/")[-1]
        r = A2.http(f"https://forum.langchain.com/t/{tid}.json", accept="application/json")
        if r["status"] != 200:
            log(f"forum {tid}: {r['status']}")
            continue
        d = json.loads(r["body"])
        src = dict(key=f"forum-{tid}", kind="forum_thread", role="community", fmt="json", url=f"https://forum.langchain.com/t/{d.get('slug')}/{tid}", title=f"LangChain Forum: {d.get('title')}", publisher="LangChain Forum", channel="forum-langchain-com",
                   thread_state="solved" if d.get("accepted_answer") or d.get("has_accepted_answer") else "open", created_at=d.get("created_at"), api_urls=[f"https://forum.langchain.com/t/{tid}.json"])
        capture(src, r["body"], {"status": 200, "final_url": src["url"]}, sweeps["forum-weekly"], published_at=d.get("created_at"))
        seen["forum"] += 1
    for hid, title in HN_IDS.items():
        r = A2.http(f"https://hn.algolia.com/api/v1/items/{hid}", accept="application/json", timeout=120)
        if r["status"] != 200:
            log(f"hn {hid}: {r['status']}")
            continue
        d = json.loads(r["body"])
        src = dict(key=f"hn-{hid}", kind="forum_thread", role="community", fmt="json", url=f"https://news.ycombinator.com/item?id={hid}", title=f"Hacker News: {d.get('title') or title}", publisher="Hacker News", channel="hacker-news",
                   link=d.get("url"), created_at=d.get("created_at"), points=d.get("points"), api_urls=[f"https://hn.algolia.com/api/v1/items/{hid}"])
        capture(src, r["body"], {"status": 200, "final_url": src["url"]}, sweeps["hn-monthly"], published_at=d.get("created_at"))
        seen["hn"] += 1
    so = next((c for c in cands if c["channel"] == "stackoverflow.com" and c["title"] == SO_TITLE), None)
    if so:
        qid = re.search(r"/questions/(\d+)", so["url"]).group(1)
        qu = A2.http(f"https://api.stackexchange.com/2.3/questions/{qid}?site=stackoverflow&filter=withbody", accept="application/json")
        an = A2.http(f"https://api.stackexchange.com/2.3/questions/{qid}/answers?site=stackoverflow&filter=withbody", accept="application/json")
        body = json.dumps({"question": json.loads(qu["body"]), "answers": json.loads(an["body"])}, ensure_ascii=False, sort_keys=True).encode("utf-8")
        src = dict(key=f"so-{qid}", kind="forum_thread", role="community", fmt="json", url=so["url"], title=f"Stack Overflow: {SO_TITLE}", publisher="Stack Overflow", channel="stackoverflow-langgraph", created_at=so.get("created"),
                   api_urls=[f"https://api.stackexchange.com/2.3/questions/{qid}", f"https://api.stackexchange.com/2.3/questions/{qid}/answers"])
        capture(src, body, {"status": 200, "final_url": so["url"]}, sweeps["stackoverflow-quarterly"], published_at=so.get("created"))
        seen["so"] += 1
    # the article (Firecrawl markdown: 1 credit)
    if not one(f"select 1 from content.document where attributes->>'key' = {q(ARTICLE['key'])}"):
        f = A2.firecrawl(ARTICLE["url"])
        assert f["status"] == 200, f
        capture(ARTICLE, f["body"], f, sweeps["comparison-articles"], fmt="markdown", tool="firecrawl", credits=1, published_at=ARTICLE["published_at"])
        C.SPEND["firecrawl_credits"] += 0
    for src in REGISTRY_PAGES:
        r = A2.http(src["url"], accept=src["accept"], timeout=180)
        if r["status"] == 200:
            capture(src, r["body"], r, sweeps["vendor-issues-on-release"])
    close_sweep(sweeps["vendor-issues-on-release"], by_channel["github"], len(THREADS), len(THREADS), {"spam_template_rfc": 9, "bot_or_inbox": 3, "unrelated_repo": 41, "not_selected_course_value": by_channel["github"] - len(THREADS) - 53})
    close_sweep(sweeps["forum-weekly"], by_channel["forum.langchain.com"], len(FORUM_TITLES), seen["forum"], {"not_selected_course_value": by_channel["forum.langchain.com"] - len(FORUM_TITLES)})
    close_sweep(sweeps["hn-monthly"], by_channel["news.ycombinator.com"], len(HN_IDS), seen["hn"], {"below_20_points_or_unrelated": by_channel["news.ycombinator.com"] - len(HN_IDS)})
    close_sweep(sweeps["stackoverflow-quarterly"], by_channel["stackoverflow.com"], 1, seen["so"], {"unrelated_or_unanswered": by_channel["stackoverflow.com"] - 1})
    close_sweep(sweeps["comparison-articles"], 1, 1, 1, {}, credits=1)
    log(f"acquire: {dict(seen)}; scout by channel {dict(by_channel)}")


# ====================================================================================================== units (thread posts, article sections) and actors
def v4():
    return sql_json(f"""select json_build_object('key', d.attributes->>'key', 'kind', d.document_type_code, 'role', d.source_role_code, 'document_id', d.id, 'version_id', v.id, 'format', v.format_code, 'sha', v.manifest_sha256,
      'representation_id', r.id, 'capture_id', vc.source_capture_id, 'captured_at', c.captured_at, 'title', d.canonical_title, 'attrs', d.attributes)
      from content.document d join content.document_version v on v.document_id = d.id join content.document_representation r on r.document_version_id = v.id
      join content.document_version_source_capture vc on vc.document_version_id = v.id join evidence.source_capture c on c.id = vc.source_capture_id
      where d.tenant_id = {q(TENANT)} and d.attributes->>'loop' = '4' order by d.attributes->>'key', c.captured_at""")


def body_of(v):
    f = next((os.path.join(SOURCES4, x) for x in os.listdir(SOURCES4) if x.startswith(v["key"] + "-") and v["sha"][:12] in x), None)
    raw = open(f, "rb").read()
    return raw.decode("utf-8"), (json.loads(raw) if f.endswith(".json") else None)


def posts_of(v):
    text, d = body_of(v)
    k, out = v["key"], []
    if k.startswith("gh-"):
        i = d["issue"]
        out.append(dict(post_id=str(i["id"]), author=i["user"]["login"], platform="github", role=i.get("author_association"), created_at=i["created_at"], reactions=(i.get("reactions") or {}).get("total_count", 0), is_op=True,
                        url=i["html_url"], text=f"{i['title']}\n\n{i.get('body') or ''}"))
        for c in d["comments"]:
            out.append(dict(post_id=str(c["id"]), author=c["user"]["login"], platform="github", role=c.get("author_association"), created_at=c["created_at"], reactions=(c.get("reactions") or {}).get("total_count", 0), is_op=False, url=c["html_url"], text=c.get("body") or ""))
    elif k.startswith("forum-"):
        for p in d["post_stream"]["posts"]:
            out.append(dict(post_id=str(p["id"]), author=p["username"], platform="discourse", role=("staff" if p.get("staff") else ("moderator" if p.get("moderator") else None)), created_at=p["created_at"], reactions=p.get("like_count") or 0,
                            is_op=p.get("post_number") == 1, accepted=bool(p.get("accepted_answer")), url=f"{v['attrs'].get('url') or ''}/{p.get('post_number')}", text=(d.get("title") + "\n\n" if p.get("post_number") == 1 else "") + strip_html(p.get("cooked"))))
    elif k.startswith("hn-"):
        out.append(dict(post_id=str(d["id"]), author=d.get("author"), platform="hacker_news", role=None, created_at=d.get("created_at"), reactions=d.get("points") or 0, is_op=True, url=f"https://news.ycombinator.com/item?id={d['id']}",
                        text=(d.get("title") or "") + ("\n" + d["url"] if d.get("url") else "") + ("\n\n" + strip_html(d.get("text")) if d.get("text") else "")))

        def walk(node, depth):
            for ch in (node.get("children") or [])[:40]:
                if ch.get("author") and ch.get("text"):
                    out.append(dict(post_id=str(ch["id"]), author=ch["author"], platform="hacker_news", role=None, created_at=ch.get("created_at"), reactions=0, is_op=False, url=f"https://news.ycombinator.com/item?id={ch['id']}", text=strip_html(ch["text"])))
                if depth < 2:
                    walk(ch, depth + 1)
        walk(d, 1)
    elif k.startswith("so-"):
        qq = d["question"]["items"][0]
        out.append(dict(post_id=str(qq["question_id"]), author=(qq.get("owner") or {}).get("display_name"), platform="stack_exchange", role=None, created_at=datetime.datetime.utcfromtimestamp(qq["creation_date"]).isoformat() + "Z", reactions=qq.get("score", 0),
                        is_op=True, url=qq["link"], text=qq["title"] + "\n\n" + strip_html(qq.get("body"))))
        for a in d["answers"].get("items", []):
            out.append(dict(post_id=str(a["answer_id"]), author=(a.get("owner") or {}).get("display_name"), platform="stack_exchange", role=None, created_at=datetime.datetime.utcfromtimestamp(a["creation_date"]).isoformat() + "Z", reactions=a.get("score", 0),
                            is_op=False, accepted=a.get("is_accepted"), url=f"https://stackoverflow.com/a/{a['answer_id']}", text=strip_html(a.get("body"))))
    return out


def article_sections(v):
    text, _ = body_of(v)
    secs, cur, buf = [], "Introduction", []
    for line in text.splitlines():
        m = re.match(r"^#{1,3}\s+(.+)$", line)
        if m:
            if "".join(buf).strip():
                secs.append((cur, "\n".join(buf).strip()))
            cur, buf = m.group(1).strip(), []
        else:
            buf.append(line)
    if "".join(buf).strip():
        secs.append((cur, "\n".join(buf).strip()))
    return [s for s in secs if not s[0].lower().startswith(("suggested reading", "ready"))]


def insert_nodes(v, units):
    rows = []
    for i, u in enumerate(units, 1):
        txt = (u["text"] or "")[:12000]
        rows.append(f"""({q(TENANT)}, {q(u['id'])}, {q(v['representation_id'])}, null, {i}, {q(u['key'][:200])}, {q(u['kind'])}, 1, {q({k: x for k, x in u['attrs'].items() if x is not None})}, {q(u['logical'])}, {q(GRAMMAR)}, {q(txt)},
                       {q({'kind': u.get('selector_kind', 'json_pointer'), 'pointer': u.get('pointer')})}, null, null, null, null, {q(sha256_text(txt))})""")
    for i in range(0, len(rows), 100):
        sql(f"""insert into content.document_node(tenant_id, id, representation_id, parent_id, ordinal, stable_local_key, unit_kind, unit_kind_version, attributes, logical_key, grammar_version, inline_text, selector, start_offset, end_offset, start_ms, end_ms, normalized_content_sha256)
                values {','.join(rows[i:i + 100])}""")


def stage_actor_edges():
    """actor -> channel edges for every author role on a loop-4 thread post (backfill after the null-property fix)."""
    rows = sql_json(f"""select json_build_object('actor', actor, 'channel', ch, 'role', pr) from (select distinct r.entity_id as actor, d.attributes->>'channel' as ch, n.attributes->>'platform_role' as pr from content.unit_entity_role r join content.document_node n on n.id = r.node_id
                         join content.document_representation rp on rp.id = n.representation_id join content.document_version v on v.id = rp.document_version_id join content.document d on d.id = v.document_id
                         where r.role = 'author' and d.attributes->>'loop' = '4') x""")
    for x in rows:
        rel("active_on", x["actor"], ent("source_channel", x["channel"]), {"platform_role": x["role"]})
    log(f"actor edges: {one('select count(*) from catalog.relationship where kind=' + q('active_on'))}")


def stage_units():
    libs = {s: ent("library", s) for s in ("langchain", "langgraph", "deepagents", "langchain-core")}
    for v in v4():
        if v["kind"] not in ("issue_thread", "forum_thread", "comparison_article") or one(f"select 1 from content.document_node where representation_id={q(v['representation_id'])} limit 1"):
            continue
        chan = ent("source_channel", v["attrs"]["channel"])
        units = []
        if v["kind"] == "comparison_article":
            for i, (h, t) in enumerate(article_sections(v)):
                units.append(dict(id=str(uuid.uuid4()), key=f"section-{i}", kind="section", attrs={"heading": h}, logical=f"section:{slugify(h)[:80]}", text=f"{h}\n\n{t}", pointer=f"/sections/{i}", selector_kind="text_quote"))
            insert_nodes(v, units)
            org = ent("organization", "agentmail")
            sql(f"insert into content.document_about_entity(tenant_id, document_id, entity_id, role, method, confidence) select {q(TENANT)}, {q(v['document_id'])}, id, 'secondary', 'extraction', 0.8 from catalog.entity where kind='library' and slug in ('langgraph','langchain') on conflict do nothing")
            log(f"units {v['key']}: {len(units)} sections")
            continue
        posts = posts_of(v)
        for i, p in enumerate(posts):
            uid = str(uuid.uuid4())
            units.append(dict(id=uid, key=f"post-{p['post_id']}", kind="thread_post", attrs={"post_id": p["post_id"], "author": p["author"], "platform_role": p.get("role"), "created_at": p.get("created_at"), "reactions": p.get("reactions"), "is_op": p.get("is_op"), "accepted": p.get("accepted"), "url": p.get("url")},
                              logical=f"post:{p['post_id']}", text=p["text"], pointer=f"/posts/{i}"))
        insert_nodes(v, units)
        for p, u in zip(posts, units):
            if not p["author"]:
                continue
            aslug = slugify(f"{p['platform']}-{p['author']}")[:120]
            aid = ensure_entity("community_actor", aslug, f"{p['author']} ({p['platform']})", {"platform": p["platform"], "handle": p["author"], "profile_url": f"https://github.com/{p['author']}" if p["platform"] == "github" else None,
                                                                                                 "platform_roles": [p["role"]] if p.get("role") else [], "first_seen_at": p.get("created_at")})
            add_role(u["id"], aid, "author", "rule", 1.0)
            rel("active_on", aid, chan, {"platform_role": p.get("role")})
        flush_roles()
        text = " ".join(p["text"] for p in posts).lower()
        for s, lid in libs.items():
            if lid and re.search(r"\b" + re.escape(s) + r"\b", text):
                sql(f"insert into content.document_about_entity(tenant_id, document_id, entity_id, role, method, confidence) values ({q(TENANT)}, {q(v['document_id'])}, {q(lid)}, 'secondary', 'extraction', 0.7) on conflict do nothing")
        log(f"units {v['key']}: {len(units)} posts")
    # same_actor_as only when the platform states it: a GitHub MEMBER of langchain-ai who is a catalogued person (none expected in this sample)
    log(f"actors: {one('select count(*) from catalog.entity where kind=' + q('community_actor'))}")


# ====================================================================================================== claims
def locator(v, node_id, quote):
    lid = one(f"select id from evidence.locator where tenant_id={q(TENANT)} and capture_id={q(v['capture_id'])} and selector->>'node_id'={q(node_id)} and normalized_value={q(quote[:500])}")
    if lid:
        return lid
    lid = str(uuid.uuid4())
    media = "application/json" if v["format"] == "json" else "text/markdown"
    sql(f"""insert into evidence.locator(id, tenant_id, capture_id, media_type, selector, selector_kind, selected_content_sha256, normalized_value, extractor_name, extractor_version, extraction_params)
            values ({q(lid)}, {q(TENANT)}, {q(v['capture_id'])}, {q(media)}, {q({'node_id': node_id, 'exact': quote[:1000]})}, 'text_quote', {q(sha256_text(quote))}, {q(quote[:500])}, 'build08-grammar', '4', {q({'loop': 4})})""")
    return lid


def norm_ws(s):
    return re.sub(r"\s+", " ", (s or "").replace("’", "'").replace("“", '"').replace("”", '"')).strip()


def find_node(document_id, quote, kinds=None):
    """The unit of a document whose text contains the quote verbatim (whitespace-normalised)."""
    nq = norm_ws(quote)
    for r in sql_json(f"""select json_build_object('id', n.id, 'text', n.inline_text, 'kind', n.unit_kind, 'attrs', n.attributes) from content.document_node n join content.document_representation r on r.id = n.representation_id
                           join content.document_version v on v.id = r.document_version_id where v.document_id = {q(document_id)} {"and n.unit_kind = any(" + qarr(kinds) + ")" if kinds else ""} and n.inline_text is not null"""):
        if nq in norm_ws(r["text"]):
            return r
    return None


def make_claim(statement, claim_type, quote, doc_id, stated_by, structured, subjects, run_label):
    """A claim with a verbatim quote, a locator on the capture, attribution to the actor/organization and the channel's source."""
    v = next(x for x in v4_all() if x["document_id"] == doc_id)
    node = find_node(doc_id, quote)
    if not node:
        log(f"claim NOT stored (quote not found verbatim): {statement[:90]}")
        return None
    cid = one(f"select id from evidence.claim where tenant_id={q(TENANT)} and statement={q(statement)}")
    if cid:
        return cid
    cid = str(uuid.uuid4())
    loc = locator(v, node["id"], quote)
    structured = dict(structured, quote=quote, node_id=node["id"], document=v["key"])
    rcpt = native_receipt("loop4-claims-" + run_label, {"loop": 4})
    sql(f"""insert into evidence.claim(id, tenant_id, claim_type, statement, structured, status, composite, producer_origin_digest, created_by_receipt_id)
            values ({q(cid)}, {q(TENANT)}, {q(claim_type)}, {q(statement)}, {q(structured)}, 'proposed', false, {q('sha256:' + sha256_text('build08-loop4:' + statement))}, {q(rcpt)});
            insert into evidence.claim_evidence_link(tenant_id, claim_id, locator_id, role) values ({q(TENANT)}, {q(cid)}, {q(loc)}, 'context') on conflict do nothing;""")
    src = one(f"select canonical_source_id from content.document where id={q(doc_id)}")
    for eid in stated_by:
        sql(f"insert into evidence.attribution(tenant_id, source_id, claim_id, entity_id, role, locator_id) values ({q(TENANT)}, {q(src)}, {q(cid)}, {q(eid)}, 'stated_by', {q(loc)})")
    for sid in subjects:
        if sid:
            sql(f"insert into evidence.claim_subject(tenant_id, claim_id, entity_id, role) values ({q(TENANT)}, {q(cid)}, {q(sid)}, 'subject') on conflict do nothing", allow_error=True)
    return cid


_V4ALL = None


def v4_all():
    """loop-4 documents plus the loop-3 LangChain docs pages (first-party quotes)."""
    global _V4ALL
    if _V4ALL is None:
        _V4ALL = sql_json(f"""select json_build_object('key', d.attributes->>'key', 'kind', d.document_type_code, 'document_id', d.id, 'version_id', v.id, 'format', v.format_code, 'capture_id', vc.source_capture_id, 'title', d.canonical_title, 'attrs', d.attributes)
          from content.document d join content.document_version v on v.document_id = d.id join content.document_version_source_capture vc on vc.document_version_id = v.id
          where d.tenant_id = {q(TENANT)} and (d.attributes->>'loop' = '4' or d.attributes->>'docs_path' in ('oss/python/migrate/langgraph-v1','oss/python/migrate/langchain-v1','oss/python/releases/langgraph-v1','oss/python/releases/langchain-v1'))
          order by v.created_at desc""")
    return _V4ALL


def doc_by(key=None, docs_path=None):
    for x in v4_all():
        if (key and x["key"] == key) or (docs_path and x["attrs"].get("docs_path") == docs_path):
            return x["document_id"]
    return None


def actor_of(doc_id, quote):
    n = find_node(doc_id, quote)
    if n and n["attrs"].get("author"):
        return one(f"select entity_id from content.unit_entity_role where node_id={q(n['id'])} and role='author' limit 1")
    return None


# claim_key -> (statement, type, quote, document locator, stated_by kind, subjects, structured extras)
KEY_CLAIMS = [
    ("C1", "langgraph.prebuilt.create_react_agent now emits a deprecation warning that points to create_agent", "assertion",
     "The `create_react_agent` helper that half the internet's tutorials use now emits a deprecation warning pointing you to `create_agent`", ("key", "article-agentmail-frameworks-2026"), "org:agentmail", ["langgraph"], {"stated_at": "2026-07-08", "first_party_at": "2025-10-17"}),
    ("C2b", "create_agent silently renamed a core parameter (prompt became system_prompt without an error)", "assertion",
     "which also silently renamed a core parameter", ("key", "article-agentmail-frameworks-2026"), "org:agentmail", ["langchain"], {"stated_at": "2026-07-08", "first_party_at": "2025-10-17"}),
    ("C12", "A one-tool agent orchestrated by LangGraph on claude-haiku-4-5 used 1,288 input tokens per run on average", "measurement",
     "costs 1,288 input tokens orchestrated by LangGraph", ("key", "article-agentmail-frameworks-2026"), "org:agentmail", ["langgraph"], {"stated_at": "2026-07-08", "value": 1288, "unit": "input tokens (mean of 10 runs)"}),
    ("C13", "LangGraph went 1.0 in October 2025 and was at 1.2.x in early July 2026", "event",
     "it went 1.0 in October 2025 and sits at 1.2.x now", ("key", "article-agentmail-frameworks-2026"), "org:agentmail", ["langgraph"], {"stated_at": "2026-07-08"}),
    ("C1d", "LangGraph v1 deprecates the create_react_agent prebuilt in favour of LangChain's create_agent", "event",
     "LangGraph v1 deprecates the", ("docs", "oss/python/migrate/langgraph-v1"), "org:langchain", ["langgraph", "langchain"], {"stated_at": "2025-10-17", "first_party_at": "2025-10-17"}),
    ("C2d", "In create_agent the prompt parameter is renamed to system_prompt; dynamic prompts use middleware", "compatibility",
     "The `prompt` parameter has been renamed to", ("docs", "oss/python/migrate/langchain-v1"), "org:langchain", ["langchain"], {"stated_at": "2025-10-17", "first_party_at": "2025-10-17"}),
    ("C3d", "The model node in streaming output is named model, not agent, in create_agent", "compatibility",
     "Node name changed from", ("docs", "oss/python/migrate/langchain-v1"), "org:langchain", ["langchain"], {"stated_at": "2025-10-17", "first_party_at": "2025-10-17"}),
    ("C5d", "create_agent has no Pydantic state: AgentStatePydantic is replaced by langchain.agents.AgentState", "compatibility",
     "no more pydantic state", ("docs", "oss/python/migrate/langgraph-v1"), "org:langchain", ["langchain", "langgraph"], {"stated_at": "2025-10-17", "first_party_at": "2025-10-17"}),
    ("C6d", "Legacy LangChain functionality (chains, hub, AgentExecutor) moved to the langchain-classic package in v1", "compatibility",
     "langchain-classic", ("docs", "oss/python/migrate/langchain-v1"), "org:langchain", ["langchain"], {"stated_at": "2025-10-17", "first_party_at": "2025-10-17"}),
    ("C4", "create_react_agent has neither middleware nor system_prompt parameters", "compatibility",
     "has neither `middleware` nor `system_prompt` parameters", ("key", "gh-copilotkit-6614"), "actor", ["langgraph"], {"stated_at": "2026-08-20", "first_party_at": "2025-10-17", "path": "community_thread"}),
    ("C8", "With create_agent, response_format and a checkpointer, turn N+1 returns turn N's structured_response", "assertion",
     "turn 2 returns `Answer(text='Hi')`", ("key", "gh-langchain-36957"), "actor", ["langchain"], {"stated_at": "2026-04-22", "first_party_at": "2026-08-05", "path": "community_thread"}),
    ("C9", "HumanInTheLoopMiddleware throws an error when the agent is invoked with .ainvoke()", "assertion",
     "Human In the Loop Middleware throws error when the agent is invoked as .ainvoke()", ("key", "gh-langchain-34974"), "actor", ["langchain"], {"stated_at": "2026-02-02", "path": "community_thread"}),
    ("C10a", "A CompiledSubAgent's final AIMessage reaches the parent Deep Agent wrapped in a ToolMessage", "assertion",
     "Subagent returns AIMessage, but Parent's middleware wraps it in ToolMessage", ("key", "gh-deepagents-2184"), "actor", ["deepagents"], {"stated_at": "2026-03-24", "path": "community_thread"}),
    ("C10b", "A CompiledSubAgent with a custom StateGraph makes the parent Deep Agent loop, re-invoking the subagent", "assertion",
     "The agent enters an infinite loop", ("key", "gh-deepagents-2184"), "actor", ["deepagents"], {"stated_at": "2026-03-24", "path": "community_thread"}),
    ("C11", "langgraph-swarm>=0.0.14 cannot be installed together with langchain>=1.0.2 and langgraph>=1.0.1", "compatibility",
     "Dependency resolution fails because `langgraph-swarm` restricts `langgraph` to <0.7.0", ("key", "gh-swarm-106"), "actor", ["langgraph"], {"stated_at": "2025-10-28", "first_party_at": "2025-12-04", "path": "community_thread"}),
]
OWN_CLAIMS = [  # our findings: stated by this system, verified by our probes (P5, P7, P11)
    ("C5o", "create_agent accepts a Pydantic state_schema without error but no longer validates it: an invalid field value passes, where the deprecated prebuilt raised a ValidationError", "compatibility", ["langchain"]),
    ("C7o", "The create_react_agent links on the LangGraph v1 migration and release pages point to the langchain-classic reference, which documents a different function (a text-ReAct agent taking prompt: BasePromptTemplate), not the deprecated LangGraph prebuilt", "assertion", ["langgraph"]),
    ("C11o", "Without a version pin, installing langgraph>=1.0 with langgraph-swarm on 2025-10-28 resolves to langgraph 1.0.1 with langchain-core 0.3.79 (a mixed 0.x/1.x environment) by backtracking to langgraph-swarm 0.0.13", "compatibility", ["langgraph"]),
    ("C0b", "On 2025-10-16, installing deepagents with langchain and langgraph pulled the 1.0 release candidates (langchain 1.0.0rc1, langgraph 1.0.0a4) into the environment", "compatibility", ["deepagents", "langchain"]),
]


def own_claim(key, statement, ctype, subjects):
    cid = one(f"select id from evidence.claim where tenant_id={q(TENANT)} and statement={q(statement)}")
    if cid:
        return cid
    cid = str(uuid.uuid4())
    sql(f"""insert into evidence.claim(id, tenant_id, claim_type, statement, structured, status, composite, producer_origin_digest, created_by_receipt_id)
            values ({q(cid)}, {q(TENANT)}, {q(ctype)}, {q(statement)}, {q({'key': key, 'path': 'own_probe_finding', 'stated_at': '2026-11-13', 'source_role': 'own_experiment'})}, 'proposed', false, {q('sha256:' + sha256_text('build08-loop4-own:' + statement))}, {q(native_receipt('loop4-own-claims', {'loop': 4}))});
            insert into evidence.attribution(tenant_id, claim_id, entity_id, role) values ({q(TENANT)}, {q(cid)}, {q(ent('organization', 'belllabs-aieng'))}, 'stated_by')""")
    for s in subjects:
        sql(f"insert into evidence.claim_subject(tenant_id, claim_id, entity_id, role) values ({q(TENANT)}, {q(cid)}, {q(ent('library', s))}, 'subject') on conflict do nothing")
    return cid


def call_model(label, system, user, max_tokens=8000):
    cache = os.path.join(CALLS, re.sub(r"[^a-zA-Z0-9_.-]+", "_", label) + ".json")
    if os.path.exists(cache):
        return json.load(open(cache, encoding="utf-8"))["parsed"]
    sp = json.load(open(SPEND_FILE)) if os.path.exists(SPEND_FILE) else {"model": MODEL, "calls": 0, "input_tokens": 0, "output_tokens": 0, "usd": 0.0}
    if sp["usd"] >= MODEL_BUDGET:
        raise RuntimeError("model budget reached")
    import anthropic
    client = anthropic.Anthropic(api_key=load_secret("ANTHROPIC_PRODUCER_API_KEY"), max_retries=3, timeout=600.0)
    with client.messages.stream(model=MODEL, max_tokens=max_tokens, system=system, messages=[{"role": "user", "content": user}]) as s:
        msg = s.get_final_message()
    text = "".join(b.text for b in msg.content if getattr(b, "type", None) == "text")
    tin, tout = msg.usage.input_tokens or 0, msg.usage.output_tokens or 0
    sp["calls"] += 1; sp["input_tokens"] += tin; sp["output_tokens"] += tout
    sp["usd"] = round(sp["usd"] + tin * PRICE_IN / 1e6 + tout * PRICE_OUT / 1e6, 4)
    write_json(SPEND_FILE, sp)
    m = re.search(r"\{.*\}", text, re.S)
    parsed = json.loads(m.group(0)) if m else {"claims": []}
    write_json(cache, {"label": label, "model": msg.model, "stop_reason": msg.stop_reason, "usage": {"in": tin, "out": tout}, "text": text, "parsed": parsed})
    log(f"model {label}: in {tin} out {tout}; total USD {sp['usd']:.2f}")
    return parsed


SYSTEM_CLAIMS = ("You extract claim candidates from a developer community thread about the LangChain / LangGraph / Deep Agents libraries. Describe what a post states, never whether it is right "
                 "(use 'the post states'; never 'confirmed', 'true', 'false', 'wrong'). Return JSON {\"claims\":[{\"post_id\":..., \"quote\":<an exact substring of that post, 8-40 words, copied character for character>, "
                 "\"statement\":<one neutral sentence of what is stated>, \"claim_type\":one of assertion|compatibility|capability|recommendation|event|measurement, \"libraries\":[langchain|langgraph|deepagents|langchain-core], "
                 "\"versions\":[...], \"probe_ready\":<true if a short deterministic script could test it>}]}. At most 4 claims per thread, only technical statements about library behaviour, versions, errors, workarounds or fixes.")


def stage_claims():
    orgs = {"org:agentmail": ent("organization", "agentmail"), "org:langchain": ent("organization", "langchain")}
    keys = {}
    for key, stmt, ctype, quote, (how, ref), by, subj, extra in KEY_CLAIMS:
        doc = doc_by(key=ref) if how == "key" else doc_by(docs_path=ref)
        if not doc:
            log(f"{key}: document {ref} not found")
            continue
        stated_by = [orgs[by]] if by.startswith("org:") else [x for x in [actor_of(doc, quote)] if x]
        cid = make_claim(stmt, ctype, quote, doc, stated_by, dict(extra, key=key, path=extra.get("path", "first_party_docs" if how == "docs" else "comparison_article")), [ent("library", s) for s in subj], key)
        keys[key] = cid
    for key, stmt, ctype, subj in OWN_CLAIMS:
        keys[key] = own_claim(key, stmt, ctype, subj)
    write_json(os.path.join(RUN4, "claim-keys.json"), keys)
    log(f"key claims stored: {sum(1 for v in keys.values() if v)} of {len(keys)}")
    # model-extracted candidates from every captured thread (the attention path: selected items become candidates)
    n_ok = n_drop = 0
    for v in v4():
        if v["kind"] not in ("issue_thread", "forum_thread"):
            continue
        posts = sql_json(f"select json_build_object('id', n.id, 'post_id', n.attributes->>'post_id', 'author', n.attributes->>'author', 'created_at', n.attributes->>'created_at', 'text', n.inline_text) from content.document_node n where n.representation_id={q(v['representation_id'])} order by n.ordinal")
        material = "\n\n".join(f"[post {p['post_id']} by {p['author']} at {p['created_at']}]\n{p['text'][:3500]}" for p in posts[:30])[:60000]
        parsed = call_model(f"claims-{v['key']}", SYSTEM_CLAIMS, f"Thread: {v['title']}\nURL: {v['attrs'].get('url')}\nState: {v['attrs'].get('thread_state')}\n\n{material}")
        for c in (parsed.get("claims") or [])[:4]:
            post = next((p for p in posts if p["post_id"] == str(c.get("post_id"))), None)
            if not post or norm_ws(c.get("quote")) not in norm_ws(post["text"]) or len(norm_ws(c.get("quote"))) < 20:
                n_drop += 1
                continue
            aid = one(f"select entity_id from content.unit_entity_role where node_id={q(post['id'])} and role='author' limit 1")
            ctype = c.get("claim_type") if c.get("claim_type") in ("assertion", "compatibility", "capability", "recommendation", "event", "measurement") else "assertion"
            cid = make_claim(c["statement"][:600], ctype, c["quote"], v["document_id"], [aid] if aid else [], {"path": "community_thread", "stated_at": (post["created_at"] or "")[:10], "url": v["attrs"].get("url"), "thread_state": v["attrs"].get("thread_state"),
                                                                                                         "versions": c.get("versions"), "probe_ready": c.get("probe_ready"), "producer": MODEL}, [ent("library", s) for s in (c.get("libraries") or []) if s in ("langchain", "langgraph", "deepagents", "langchain-core")], "model-" + v["key"])
            n_ok += cid is not None
    log(f"model claim candidates: stored {n_ok}, dropped {n_drop} (quote not verbatim or too short)")


# ====================================================================================================== probes, runs, verdicts
PROBES = {  # slug: (title, hypothesis, kind, subjects, script, claims, model_policy)
    "P1": ("crea-deprecation", "create_react_agent deprecation warning", "The prebuilt warns from 1.0 on and names create_agent", "executed", ["langgraph"], "p01_crea_deprecation.py", ["C1", "C1d"], "fake"),
    "P2": ("create-agent-prompt-kwarg", "create_agent: prompt= vs system_prompt=", "prompt= is rejected loudly (TypeError) and system_prompt reaches the model", "executed", ["langchain"], "p02_create_agent_prompt_kwarg.py", ["C2d", "C2b"], "fake"),
    "P3": ("stream-node-name", "Streaming node names", "the model node is 'agent' in the prebuilt and 'model' in create_agent", "executed", ["langchain", "langgraph"], "p03_stream_node_name.py", ["C3d"], "fake"),
    "P4": ("crea-new-kwargs", "The prebuilt and the new keywords", "create_react_agent rejects system_prompt= and middleware=", "executed", ["langgraph"], "p04_crea_new_kwargs.py", ["C4"], "fake"),
    "P5": ("pydantic-state", "Pydantic state schemas", "create_agent does not support Pydantic state the way the prebuilt did", "executed", ["langchain", "langgraph"], "p05_pydantic_state.py", ["C5d", "C5o"], "fake"),
    "P6": ("legacy-imports", "Legacy imports and langchain-classic", "hub and AgentExecutor import from langchain before 1.0 and from langchain_classic after", "executed", ["langchain"], "p06_legacy_imports.py", ["C6d"], "fake"),
    "P7": ("docs-link-target", "Where the create_react_agent link goes", "the LangGraph v1 pages link to the langchain-classic function, whose signature differs from the prebuilt", "static_docs", ["langgraph"], "p07_docs_link_target.py", ["C7o"], "none"),
    "P8": ("stale-structured-response", "Stale structured_response across turns", "turn N+1 returns turn N's structured response before the fix, not after", "executed", ["langchain"], "p08_stale_structured_response.py", ["C8"], "fake"),
    "P9": ("hitl-ainvoke", "HITL middleware with ainvoke", "ainvoke raises where invoke does not", "executed", ["langchain"], "p09_hitl_ainvoke.py", ["C9"], "fake"),
    "P10": ("compiled-subagent", "CompiledSubAgent result and loop", "the subagent answer arrives as a ToolMessage; a deterministic parent stops", "executed", ["deepagents"], "p10_compiled_subagent.py", ["C10a", "C10b"], "fake"),
    "P11": ("swarm-v1-resolution", "langgraph-swarm with langgraph 1.0", "the reporter's pins do not resolve on 2025-11-04 and do now; without pins the resolver backtracks", "resolution", ["langgraph"], None, ["C11", "C11o"], "none"),
    "P12": ("token-overhead-live", "Token overhead of a one-tool agent (live)", "mean input tokens near 1,288 with the tool called every run", "live_model", ["langgraph", "langchain"], "p12_token_overhead_live.py", ["C12"], "live"),
    "P13": ("release-facts", "LangGraph 1.0 date and the 1.2.x line", "1.0.0 on 2025-10-17; newest release on 2026-07-08 is 1.2.x", "registry_check", ["langgraph"], None, ["C13"], "none"),
    "P0b": ("deepagents-prerelease-pull", "deepagents pulled 1.0 pre-releases on 2025-10-16", "the D0b cell resolves langchain 1.0.0rc1 / langgraph 1.0.0a4", "resolution", ["deepagents"], None, ["C0b"], "none"),
}


def runs_of(p):
    out = []
    for f in sorted(os.listdir(PROBE_RUNS)):
        if f.startswith(p + "__") and f.endswith(".json") and "attempt" not in f:
            out.append(json.load(open(os.path.join(PROBE_RUNS, f), encoding="utf-8")))
    return out


def verdicts(p, runs, keys):
    """Rules over the recorded checks -> [(claim key, verdict, rationale, cells summary)]."""
    ch = {r["cell"]: ((r.get("result") or {}).get("checks") or {}) for r in runs}
    cells = {c: {k: v for k, v in x.items() if not isinstance(v, (dict, list))} for c, x in ch.items()}
    D0, D1, D2, D3 = "D0-2025-10-16", "D1-2025-10-18", "D2-2026-04-23", "D3-latest"
    out = []
    if p == "P1":
        ok = ch[D0].get("deprecation_warning") is False and all(ch[c].get("deprecation_warning") and ch[c].get("names_create_agent") for c in (D1, D2, D3))
        out += [(k, "directly_supported" if ok else "contradicted", f"No warning on 2025-10-16 (langgraph 0.6.10); LangGraphDeprecatedSinceV10 naming create_agent on 1.0.0, 1.1.9 and 1.2.21" if ok else "pattern not observed", cells) for k in ("C1", "C1d")]
    elif p == "P2":
        renamed = all(ch[c].get("has_system_prompt_param") and not ch[c].get("has_prompt_param") and ch[c].get("system_prompt_reaches_model") for c in (D1, D2, D3))
        loud = all(ch[c].get("prompt_kwarg_rejected") and ch[c].get("prompt_kwarg_error_type") == "TypeError" for c in (D1, D2, D3))
        out.append(("C2d", "directly_supported" if renamed else "contradicted", "system_prompt reaches the model; there is no prompt parameter (langchain 1.0.0, 1.2.15, 1.5.0)", cells))
        out.append(("C2b", "contradicted" if loud else "directly_supported", "the rename is real but not silent: create_agent(prompt=...) raises TypeError (unexpected keyword) in every 1.x cell" if loud else "prompt= accepted without effect", cells))
    elif p == "P3":
        ok = ch[D0].get("prebuilt_model_node") == "agent" and all(ch[c].get("create_agent_model_node") == "model" for c in (D1, D2, D3))
        out.append(("C3d", "directly_supported" if ok else "contradicted", "updates are keyed 'agent' for the prebuilt (all cells) and 'model' for create_agent (1.0.0 to 1.5.0); code filtering on 'agent' silently matches nothing after migrating", cells))
    elif p == "P4":
        ok = all(ch[c].get("system_prompt_rejected") and ch[c].get("middleware_rejected") for c in ch)
        out.append(("C4", "directly_supported" if ok else "contradicted", "both keywords raise TypeError on the prebuilt in every cell (0.6.10 to 1.2.21)", cells))
    elif p == "P5":
        acc = all(ch[c].get("create_agent_accepts_pydantic") for c in (D1, D2, D3))
        noval = all(ch[c].get("create_agent_validates") is False for c in (D1, D2, D3))
        out.append(("C5d", "supported_with_qualification" if acc and noval else ("directly_supported" if not acc else "contradicted"),
                    "create_agent accepts a Pydantic class as state_schema without an error and carries its fields, but it no longer validates them (an invalid value passes); the prebuilt raised ValidationError. 'No more pydantic state' holds for validation, not for acceptance", cells))
        out.append(("C5o", "directly_supported" if acc and noval and all(ch[c].get("prebuilt_validates") for c in ch) else "contradicted", "observed in all three 1.x cells; the prebuilt validated in all four cells", cells))
    elif p == "P6":
        ok = ch[D0].get("langchain_hub_imports") and ch[D0].get("langchain_agents_AgentExecutor_imports") and all(not ch[c].get("langchain_hub_imports") and ch[c].get("langchain_classic_hub_imports") and ch[c].get("langchain_classic_agents_AgentExecutor_imports") for c in (D1, D2, D3))
        out.append(("C6d", "directly_supported" if ok else "contradicted", "langchain.hub and langchain.agents.AgentExecutor import on 0.3.27 and fail from 1.0.0; langchain_classic provides both", cells))
    elif p == "P7":
        ok = ch[D3].get("links_point_to_classic") and ch[D3].get("signatures_differ")
        out.append(("C7o", "directly_supported" if ok else "contradicted", f"{ch[D3].get('links_found')} links, all to the langchain-classic reference; the classic function takes (llm, tools, prompt: BasePromptTemplate, ...) and the prebuilt (model, tools, *, prompt=...)", cells))
    elif p == "P8":
        ok = ch[D1].get("stale_turn2") and ch[D2].get("stale_turn2") and ch[D3].get("fresh_turn2")
        out.append(("C8", "supported_with_qualification" if ok else "not_supported", "reproduced with the reporter's own fake-model script on langchain 1.0.0 and 1.2.15; not on 1.5.0 (the issue was closed as completed on 2026-08-05)" if ok else "not reproduced", cells))
    elif p == "P9":
        repro = any(not ch[c].get("async_ok") for c in ch)
        out.append(("C9", "directly_supported" if repro else "not_supported", "not reproduced: a minimal deterministic agent with HumanInTheLoopMiddleware interrupts and resumes under both invoke and ainvoke on 1.0.0, 1.2.15 and 1.5.0. The report used a real model, several tools with allowed_decisions and FastAPI; the issue is still open, so this is not a refutation" if not repro else "reproduced", cells))
    elif p == "P10":
        out.append(("C10a", "directly_supported" if all(ch[c].get("answer_arrives_as_tool_message") for c in ch) else "contradicted", "the subagent's final text reaches the parent as a ToolMessage (deepagents 0.5.3 and 0.7.37)", cells))
        out.append(("C10b", "unverifiable", "a deterministic parent stops after the ToolMessage; whether a real model loops on it is model behaviour, which this probe cannot show (the issue was closed as not planned)", cells))
    elif p == "P11":
        rep, now, unp = ch.get("2025-11-04-reporter-pins", {}), ch.get("D3-latest-reporter-pins", {}), ch.get("2025-10-28-unpinned", {})
        out.append(("C11", "directly_supported" if rep.get("resolves") is False and now.get("resolves") else "contradicted", "unsatisfiable with the reporter's pins on 2025-11-04 (langgraph-swarm>=0.0.14 requires langchain-core<0.4); resolves today with langgraph-swarm 0.1.0 (2025-12-04)", cells))
        out.append(("C11o", "directly_supported" if unp.get("mixed_major") else "contradicted", f"unpinned on 2025-10-28: langgraph {unp.get('langgraph')}, langgraph-swarm {unp.get('langgraph_swarm')}, langchain-core {unp.get('langchain_core')}", cells))
    elif p == "P12":
        c = ch[D3]
        ok = c.get("tool_invoked_all") and c.get("within_15pct_of_1288")
        out.append(("C12", "supported_with_qualification" if ok else ("partially_supported" if c.get("within_30pct_of_1288") else "not_supported"),
                    f"mean {c.get('mean_input_tokens')} input tokens over {c.get('runs_ok')} runs, tool called every run (create_agent on langchain 1.5.0, claude-haiku-4-5, our prompt); a live arm never verifies alone", cells))
    elif p == "P13":
        c = ch.get("registry", {})
        out.append(("C13", "directly_supported" if c.get("v1_on") == "2025-10-17" and str(c.get("latest_on_2026_07_08", "")).startswith("1.2.") else "contradicted", f"PyPI: langgraph 1.0.0 published {c.get('v1_on')}; newest release on 2026-07-08 is {c.get('latest_on_2026_07_08')}", cells))
    elif p == "P0b":
        c = ch.get("D0b-2025-10-16-with-deepagents", {})
        out.append(("C0b", "directly_supported" if c.get("pre") else "contradicted", "the D0b environment resolved " + json.dumps(c.get("versions")), cells))
    return out


def registry_check_P13():
    doc = doc_by(key="pypi-langgraph-l4")
    v = next(x for x in v4_all() if x["document_id"] == doc)
    _, d = body_of(dict(key="pypi-langgraph-l4", sha=one(f"select manifest_sha256 from content.document_version where id={q(v['version_id'])}")))
    rel_ = sorted([(ver, f[0]["upload_time"][:10]) for ver, f in d["releases"].items() if f], key=lambda x: x[1])
    v1 = next((t for ver, t in rel_ if ver == "1.0.0"), None)
    stable = [x for x in rel_ if x[1] <= "2026-07-08" and re.match(r"^\d+\.\d+\.\d+$", x[0])]
    latest = stable[-1][0] if stable else None
    rec = {"probe": "P13", "cell": "registry", "script": "PyPI JSON (captured as pypi-langgraph-l4)", "started_at": now_iso(), "ended_at": now_iso(), "exit_code": 0, "outcome": "pass",
           "result": {"probe": "P13", "observations": {"releases_counted": len(rel_), "v1": v1, "stable_on_2026_07_08": stable[-3:]}, "checks": {"v1_on": v1, "latest_on_2026_07_08": latest}}}
    write_json(os.path.join(PROBE_RUNS, "P13__registry.json"), rec)
    env = json.load(open(os.path.join(os.environ.get("TEMP"), "aieng-loop4-envs", "D0b-2025-10-16-with-deepagents", "probe-env.json"), encoding="utf-8"))
    vers = {l.split("==")[0]: l.split("==")[1] for l in env["freeze"].splitlines() if "==" in l and l.split("==")[0] in ("langchain", "langgraph", "langchain-core", "deepagents")}
    write_json(os.path.join(PROBE_RUNS, "P0b__D0b-2025-10-16-with-deepagents.json"), {"probe": "P0b", "cell": "D0b-2025-10-16-with-deepagents", "script": "uv pip install --exclude-newer 2025-10-17 langgraph langchain langchain-core langgraph-prebuilt deepagents",
                                                                                     "started_at": env["built_at"], "ended_at": env["built_at"], "exit_code": 0, "outcome": "pass", "lock_sha256": env["lock_sha256"], "exclude_newer": env["exclude_newer"],
                                                                                     "result": {"probe": "P0b", "observations": {"freeze": env["freeze"]}, "checks": {"versions": vers, "pre": any(re.search(r"(a|b|rc)\d", x) for x in vers.values())}}})


def stage_probes():
    registry_check_P13()
    keys = json.load(open(os.path.join(RUN4, "claim-keys.json"), encoding="utf-8"))
    sweep = one(f"select id from acquisition.attention_sweep where policy_id={q(policy_id('probe-revalidation'))} and trigger_kind='manual'") if policy_id("probe-revalidation") else None
    thread = one("select id from conversation.thread where purpose='interview' order by created_at limit 1")
    summary = {}
    for p, (slug, title, hyp, kind, subj, script, claims, model_policy) in PROBES.items():
        script_path = f"scripts/knowledge-lab/probes/{script}" if script else ("scripts/knowledge-lab/loop4_probes.py (resolve)" if kind == "resolution" else "scripts/knowledge-lab/loop4_process.py (registry_check_P13)")
        sha = sha256_bytes(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "probes", script), "rb").read()) if script else None
        runs = runs_of(p)
        matrix = [{"label": r["cell"], "exclude_newer": r.get("exclude_newer")} for r in runs]
        pid = one(f"select id from verification.probe where slug={q(p + '-' + slug)}")
        if not pid:
            pid = str(uuid.uuid4())
            sql(f"""insert into verification.probe(id, slug, title, hypothesis, kind, subject_entity_ids, script_path, script_sha256, environment, matrix, model_policy, budget_usd, designed_in_thread_id, designed_by)
                    values ({q(pid)}, {q(p + '-' + slug)}, {q(title)}, {q(hyp)}, {q(kind)}, {qarr([ent('library', s) for s in subj], 'uuid')}, {q(script_path)}, {q(sha)}, {q({'python': '3.12', 'platform': 'Windows', 'installer': 'uv 0.12.23', 'cells': 'dates via --exclude-newer'})},
                            {q(matrix)}, {q(model_policy)}, {0.05 if model_policy == 'live' else 0}, {q(thread)}, 'agent:claude-code (loop 4 interview with John)')""")
        for k in claims:
            if keys.get(k):
                sql(f"insert into verification.probe_claim(probe_id, claim_id, expectation) values ({q(pid)}, {q(keys[k])}, {q({'claim_key': k, 'expected': 'see knowledge-loop-4/EXPECTED.json'})}) on conflict do nothing")
        # the probe report document: one version holding every run of this batch; one probe_observation unit per run
        if not one(f"select 1 from verification.probe_run where probe_id={q(pid)}"):
            body = json.dumps({"probe": p, "slug": slug, "runs": runs}, ensure_ascii=False, sort_keys=True, default=str).encode("utf-8")
            src = dict(key=f"probe-report-{p}", kind="probe_report", role="own_experiment", fmt="json", url=f"urn:belllabs:probe:{p}-{slug}", title=f"Probe report {p}: {title}", publisher="AI Engineer research (this system)", channel="belllabs-probes", probe=p)
            doc, ver = capture(src, body, {"status": 200, "final_url": src["url"]}, sweep)
            vrow = sql_json(f"""select json_build_object('representation_id', r.id, 'capture_id', vc.source_capture_id, 'format', v.format_code) from content.document_version v join content.document_representation r on r.document_version_id = v.id
                                join content.document_version_source_capture vc on vc.document_version_id = v.id where v.document_id = {q(doc)} order by v.created_at desc limit 1""")[0]
            units = []
            for i, r in enumerate(runs):
                res = r.get("result") or {}
                vers = res.get("versions") or (res.get("checks") or {}).get("versions") or {}
                txt = (f"Probe {p} ({title}) in cell {r['cell']}" + (f" (packages as of {r.get('exclude_newer')})" if r.get("exclude_newer") else "") + ": " +
                       ", ".join(f"{k} {v}" for k, v in vers.items() if v) + ". Checks: " + json.dumps(res.get("checks"), ensure_ascii=False)[:1500] + f". Outcome {r['outcome']}.")
                units.append(dict(id=str(uuid.uuid4()), key=f"run-{r['cell']}", kind="probe_observation", attrs={"probe": p, "cell": r["cell"], "outcome": r["outcome"], "resolved": vers, "observation": res.get("checks")},
                                  logical=f"probe:{p}:{r['cell']}", text=txt, pointer=f"/runs/{i}"))
            insert_nodes(dict(representation_id=vrow["representation_id"]), units)
            for r, u in zip(runs, units):
                loc = str(uuid.uuid4())
                sql(f"""insert into evidence.locator(id, tenant_id, capture_id, media_type, selector, selector_kind, selected_content_sha256, normalized_value, extractor_name, extractor_version, extraction_params)
                        values ({q(loc)}, {q(TENANT)}, {q(vrow['capture_id'])}, 'application/json', {q({'node_id': u['id'], 'pointer': u['pointer']})}, 'json_pointer', {q(sha256_text(u['text']))}, {q(u['text'][:500])}, 'build08-grammar', '4', '{{}}'::jsonb)""")
                res = r.get("result") or {}
                obs = dict(checks=res.get("checks"), observations=res.get("observations"), stderr_tail=(r.get("stderr_tail") or "")[-800:] or None)
                tok_in = (res.get("checks") or {}).get("mean_input_tokens")
                sql(f"""insert into verification.probe_run(probe_id, cell_label, cell, resolved, lock_sha256, python_version, platform, started_at, ended_at, exit_code, outcome, observations, output_capture_id, output_locator_id, tokens_in, cost_usd, sweep_id, origin_kind, receipt_id)
                        values ({q(pid)}, {q(r['cell'])}, {q({'exclude_newer': r.get('exclude_newer'), 'requirements': r.get('requirements')})}, {q(res.get('versions') or (res.get('checks') or {}).get('versions') or {})}, {q(r.get('lock_sha256'))}, {q(res.get('python'))}, {q(res.get('platform'))},
                                {q(r['started_at'])}, {q(r.get('ended_at'))}, {q(r.get('exit_code'))}, {q(r['outcome'])}, {q(obs)}, {q(vrow['capture_id'])}, {q(loc)}, {int(tok_in * 5) if tok_in else 'null'}, {0.0085 if p == 'P12' else 0}, {q(sweep)}, 'standalone', {q(native_receipt('loop4-probe-run-' + p, {'cell': r['cell']}))})""")
                for su in subj:
                    add_role(u["id"], ent("library", su), "subject", "rule", 1.0)
            flush_roles()
        # verdicts
        for ck, verdict, rationale, cells in verdicts(p, runs, keys):
            cid = keys.get(ck)
            if not cid or one(f"select 1 from verification.probe_verdict where claim_id={q(cid)} and probe_id={q(pid)}"):
                continue
            sql(f"""insert into verification.probe_verdict(claim_id, probe_id, verdict, cells, rationale, decided_by) values ({q(cid)}, {q(pid)}, {q(verdict)}::evidence.support_verdict, {q(cells)}, {q(rationale)}, 'agent:loop4_process verdict rules (code, not a model)')""")
            loc = one(f"select output_locator_id from verification.probe_run where probe_id={q(pid)} order by started_at desc limit 1")
            role = "supports" if verdict in ("directly_supported", "supported_with_qualification", "partially_supported") else ("contradicts" if verdict in ("contradicted", "not_supported") else "context")
            sql(f"insert into evidence.claim_evidence_link(tenant_id, claim_id, locator_id, role, support_verdict) values ({q(TENANT)}, {q(cid)}, {q(loc)}, {q(role)}, {q(verdict)}::evidence.support_verdict) on conflict do nothing")
            deterministic = kind in ("executed", "static_docs", "resolution", "registry_check")
            # D-55: 'verified' is gated (evidence.enforce_verified_claim_gate): only a receipt bound to an admitted Knowledge Services use decision may set it.
            # A probe verdict is evidence for that admission, not a substitute: supported claims stay 'proposed' with their verdict; a deterministic contradiction disputes.
            new_status = "disputed" if deterministic and verdict == "contradicted" else None
            if new_status:
                sql(f"update evidence.claim set status = {q(new_status)}::evidence.claim_status, updated_at = now() where id = {q(cid)}")
            summary[ck] = (p, verdict, new_status or "proposed")
    write_json(os.path.join(RUN4, "verdicts-summary.json"), summary)
    for k, v in sorted(summary.items()):
        log(f"verdict {k}: {v}")


# ====================================================================================================== attention policies, missions, sweeps
POLICIES = [  # slug, title, scope, channels, subjects, level, cadence, depth, selection, triggers, budget usd, credits, rationale
    ("vendor-issues-on-release", "Vendor issue trackers on release", "channel", ["github-langchain-ai-langchain-issues", "github-langchain-ai-langgraph-issues", "github-langchain-ai-deepagents-issues"], ["langchain", "langgraph", "deepagents"], "W3", "P7D",
     {"max_items_per_query": 30, "since": "release date", "comments": "all"}, {"author_associations": "any", "drop": ["crypto/payment/compliance RFC templates", "bot command inboxes", "unrelated repositories"], "prefer": ["bug label", "names a public symbol", "maintainer reply"]},
     [{"on": "release_published", "window_days": 14}], 0.50, 0, "issues opened after a release are the earliest signal of breakage; the scout showed the top threads by comment count are noise, so selection rules matter more than volume"),
    ("dependents-on-major", "Dependent projects on a major release", "query", ["github-copilotkit-copilotkit-issues", "github-langchain-ai-langgraph-swarm-py-issues", "github-langfuse-langfuse-issues"], ["langchain", "langgraph"], "W3", None,
     {"max_items": 30, "window_days": 30}, {"query": "issues and PRs naming a removed or deprecated symbol of the subject library", "code_search": True},
     [{"on": "release_published", "window_days": 30, "only": "major"}], 0.50, 0, "dependent projects broke on 1.0 (langgraph-swarm, CopilotKit docs, Langfuse prompt linking) before the vendor documented every edge"),
    ("forum-weekly", "LangChain forum weekly", "channel", ["forum-langchain-com"], ["langchain", "langgraph", "deepagents"], "W2", "P7D", {"max_topics": 20}, {"queries": ["create_agent", "create_react_agent", "deepagents", "v1 migration"], "prefer": ["solved", "staff reply"]},
     [], 0.25, 0, "active, practical questions; slower signal than the trackers"),
    ("hn-monthly", "Hacker News monthly", "channel", ["hacker-news"], ["langchain", "langgraph", "deepagents"], "W2", "P30D", {"max_items": 30}, {"min_points": 20, "queries": ["langchain", "langgraph", "deepagents", "agent frameworks"]},
     [], 0.10, 0, "sentiment and security news (CVE-2025-68664), rarely technical detail"),
    ("stackoverflow-quarterly", "Stack Overflow quarterly", "channel", ["stackoverflow-langgraph"], ["langchain", "langgraph"], "W1", "P90D", {"max_items": 30}, {"tags": ["langgraph", "langchain"]},
     [], 0.0, 0, "the scout found 10 questions in 14 months for this ecosystem"),
    ("comparison-articles", "Comparison articles with a disclosed method", "query", ["agentmail-blog"], ["langgraph", "langchain", "deepagents"], "W2", "P30D", {"max_articles": 5}, {"require": "disclosed method (tests, dates, models)", "skip": "SEO refreshes of 2024 rankings"},
     [], 0.0, 2, "only articles that ran something are worth the credits; their numbers become probe targets"),
    ("probe-revalidation", "Re-run probes when a subject library releases", "probe_set", ["belllabs-probes"], ["langchain", "langgraph", "deepagents"], "W3", None, {"cells": ["latest"]}, {"probes": "all active probes whose subjects include the released library"},
     [{"on": "release_published", "window_days": 7}], 0.10, 0, "a verdict is only as current as its latest cell; a changed outcome opens a review"),
    ("reddit-langchain", "reddit r/LangChain", "channel", ["reddit-r-langchain"], ["langchain"], "W0", None, {}, {}, [], 0.0, 0, "W0: commercial API terms not reviewed; noisy; deferred by John 2026-11-12"),
    ("x-langchain", "X posts about LangChain", "channel", ["x-langchain"], ["langchain"], "W0", None, {}, {}, [], 0.0, 0, "W0: API cost and terms; deferred by John 2026-11-12"),
]
MISSIONS = [("watch-langchain-ecosystem", "Watch the LangChain / LangGraph / Deep Agents ecosystem: run the due attention policies within budget and write sweeps, captures, claim candidates and probe reruns back",
             ["vendor-issues-on-release", "dependents-on-major", "forum-weekly", "hn-monthly", "stackoverflow-quarterly", "comparison-articles"], 2.0),
            ("revalidate-langchain-probes", "Re-run the LangChain ecosystem probes on a release and open a review when an outcome changes", ["probe-revalidation"], 0.25)]


def stage_attention():
    thread = one("select id from conversation.thread where purpose='interview' order by created_at limit 1")
    mids = {}
    for slug, goal, pols, budget in MISSIONS:
        mid = one(f"select id from orchestration.mission where slug={q(slug)}")
        if not mid:
            mid = str(uuid.uuid4())
            sql(f"""insert into orchestration.mission(id, tenant_id, slug, goal, research_questions, acceptance_criteria, budget_cost_usd, budget_wall_seconds, budget_max_fanout, budget_max_depth, budget_max_retries, status)
                    values ({q(mid)}, {q(TENANT)}, {q(slug)}, {q(goal)}, {q(['which attention policies are due (api.attention_due)?', 'what changed since the last sweep?'])}, {q(['every due policy swept or skipped with a reason', 'spend within the per-run budgets', 'sweeps and fetches written back with sweep_id'])},
                            {budget}, 3600, 6, 2, 2, 'created')""")
        for p in pols:
            mids[p] = mid
    for slug, title, scope, chans, subj, level, cadence, depth, sel, trig, usd, cred, why in POLICIES:
        if policy_id(slug):
            continue
        sql(f"""insert into acquisition.attention_policy(slug, title, scope_kind, channel_entity_ids, subject_entity_ids, watch_level, cadence, depth, selection, triggers, budget_usd_per_run, budget_credits_per_run, mission_id, designed_in_thread_id, rationale, decided_by, state)
                values ({q(slug)}, {q(title)}, {q(scope)}, {qarr([ent('source_channel', c) for c in chans], 'uuid')}, {qarr([ent('library', s) for s in subj], 'uuid')}, {q(level)}, {q(cadence)}, {q(depth)}, {q(sel)}, {q(trig)}, {usd}, {cred},
                        {q(mids.get(slug))}, {q(thread)}, {q(why)}, {q('human:John (owner), 2026-11-12/13; drafted by agent:claude-code' if level != 'W0' else 'human:John (owner) deferred, 2026-11-12')}, {q('paused' if level == 'W0' else 'active')})""")
    # the probe revalidation sweep that the probe runs of this session belong to
    if not one(f"select 1 from acquisition.attention_sweep where policy_id={q(policy_id('probe-revalidation'))}"):
        sid = open_sweep("probe-revalidation", "manual", {"reason": "first run of the loop-4 probes (all cells)"}, "loop-4 first execution of P1-P13", ("2025-10-16", "2026-11-13"))
        close_sweep(sid, 14, 14, 14, {}, spend=0.0085)
    log(f"attention: {one('select count(*) from acquisition.attention_policy')} policies, {one('select count(*) from orchestration.mission where slug like ' + q('%langchain%'))} missions")


def stage_release_events():
    """deepagents 0.7.36 / 0.7.37 from the loop-4 PyPI capture -> library_release + release_published (so api.attention_due sees them)."""
    doc = doc_by(key="pypi-deepagents-l4")
    v = next(x for x in v4_all() if x["document_id"] == doc)
    _, d = body_of(dict(key="pypi-deepagents-l4", sha=one(f"select manifest_sha256 from content.document_version where id={q(v['version_id'])}")))
    lib = ent("library", "deepagents")
    known = {r[0] for r in sql_rows("select attributes->>'version_label' from catalog.entity where kind='library_release' and slug like 'deepagents-%'")}
    b = Batch("loop4-deepagents-releases", {"document": "pypi-deepagents-l4", "loop": 4})
    added = []
    for ver, files in d["releases"].items():
        if not files or ver in known or not re.match(r"^0\.7\.(3[6-9])$", ver):
            continue
        day = files[0]["upload_time"][:10]
        rid = ensure_entity("library_release", slugify(f"deepagents-{ver}"), f"deepagents {ver}", {"version_label": ver, "released_on": day, "tag": f"deepagents=={ver}", "prerelease": False})
        rel("version_of", rid, lib)
        cid = one(f"select id from evidence.claim where statement={q(f'deepagents {ver} was published on {day} (PyPI)')}") or own_like_claim(f"deepagents {ver} was published on {day} (PyPI)", rid)
        b.add(f"select temporal.assert_event('release_published', {q(rid)}, tstzrange({q(day)}, ({q(day)})::timestamptz + interval '1 second', '[)'), 'actual', null, null, {q('deepagents==' + ver)}, null, {q(cid)}, {q({'version': ver, 'package': 'deepagents', 'source': 'PyPI'})});")
        added.append((ver, day))
    out = b.commit()
    log(f"release events: {added} -> {(out or '-').splitlines()[-1] if out else '-'}")


def own_like_claim(statement, subject):
    cid = str(uuid.uuid4())
    sql(f"""insert into evidence.claim(id, tenant_id, claim_type, statement, structured, status, composite, producer_origin_digest, created_by_receipt_id)
            values ({q(cid)}, {q(TENANT)}, 'event', {q(statement)}, {q({'path': 'deterministic_registry', 'subject': subject})}, 'proposed', false, {q('sha256:' + sha256_text(statement))}, {q(native_receipt('loop4-release-claims', {}))});
            insert into evidence.claim_subject(tenant_id, claim_id, entity_id, role) values ({q(TENANT)}, {q(cid)}, {q(subject)}, 'subject')""")
    return cid


def stage_event_sweep():
    """Execute what api.attention_due returns for vendor-issues-on-release: per subject library, the issues opened since its earliest triggering release."""
    due = sql_json("select row_to_json(d) from api.attention_due(now()) d")
    write_json(os.path.join(RUN4, "attention-due-before.json"), due)
    repos = {"langchain": "langchain-ai/langchain", "langgraph": "langchain-ai/langgraph", "deepagents": "langchain-ai/deepagents"}
    chans = {"langchain": "github-langchain-ai-langchain-issues", "langgraph": "github-langchain-ai-langgraph-issues", "deepagents": "github-langchain-ai-deepagents-issues"}
    for d in due:
        if d["slug"] != "vendor-issues-on-release" or not d["trigger_ref"]:
            continue
        since = {}
        for x in d["trigger_ref"]:
            since[x["subject"]] = min(since.get(x["subject"], x["at"][:10]), x["at"][:10])
        sid = open_sweep("vendor-issues-on-release", "event", {"events": len(d["trigger_ref"]), "since": since, "reason": d["reason"][:500]}, "event-triggered sweep: issues opened since each subject's earliest triggering release in the 14-day window",
                         (min(since.values()), now_iso()))
        seen, rej, sel = 0, collections.Counter(), []
        for subj, day in since.items():
            qy = f"repo:{repos[subj]} is:issue created:>={day}"
            r = A2.http("https://api.github.com/search/issues?per_page=50&sort=created&order=desc&q=" + urllib.parse.quote(qy), accept=A2.GITHUB_ACCEPT, github=True)
            items = json.loads(r["body"]).get("items", []) if r["status"] == 200 else []
            seen += len(items)
            picked = []
            for it in items:
                t = (it["title"] or "").lower() + " " + " ".join(l["name"].lower() for l in it.get("labels", []))
                if it.get("user", {}).get("type") == "Bot":
                    rej["bot"] += 1
                elif re.search(r"crypto|payment|x402|governance|compliance|identity verification|kill switch", t):
                    rej["rfc_template_or_promotion"] += 1
                elif not re.search(r"bug|error|regression|broken|fail|crash|loop|not work|exception|deprecat|typeerror|keyerror", t):
                    rej["not_a_failure_report"] += 1
                elif len(picked) >= 2:
                    rej["over_per_repository_cap"] += 1
                else:
                    picked.append((subj, it))
            sel += picked
            time.sleep(2.2)
        for subj, it in sel:
            issue, body, fetched = gh_thread(repos[subj], it["number"])
            src = dict(key=f"gh-{subj}-{it['number']}", kind="issue_thread", role="community", fmt="json", url=issue["html_url"], title=f"{repos[subj]}#{it['number']}: {issue['title']}", publisher=repos[subj], channel=chans[subj],
                       repo=repos[subj], number=it["number"], thread_state=issue["state"], created_at=issue["created_at"], api_urls=[f"https://api.github.com/repos/{repos[subj]}/issues/{it['number']}"])
            capture(src, body, fetched, sid, published_at=issue["created_at"])
        close_sweep(sid, seen, len(sel), len(sel), dict(rej))
        log(f"event sweep: since {since}; seen {seen}, selected {len(sel)}, rejected {dict(rej)}")
    write_json(os.path.join(RUN4, "attention-due-after.json"), sql_json("select row_to_json(d) from api.attention_due(now()) d"))


# ====================================================================================================== assessments
def stage_assess():
    topics = [None] + [ent("library", s) for s in ("langchain", "langgraph", "deepagents")]
    subjects = [r[0] for r in sql_rows("select id from catalog.entity where kind in ('source_channel') or (kind='organization' and slug in ('agentmail','langchain','belllabs-aieng'))")]
    subjects += [r[0] for r in sql_rows("select distinct a.entity_id from evidence.attribution a join catalog.entity e on e.id = a.entity_id where e.kind = 'community_actor' and exists (select 1 from verification.probe_verdict v where v.claim_id = a.claim_id)")]
    n = 0
    for s in subjects:
        for t in topics:
            stated = one(f"""select count(*) from evidence.attribution a left join evidence.source so on so.id = a.source_id where (a.entity_id = {q(s)} or so.channel_entity_id = {q(s)} or so.publisher_entity_id = {q(s)})
                             {'' if t is None else f'and exists (select 1 from evidence.claim_subject cs where cs.claim_id = a.claim_id and cs.entity_id = {q(t)})'}""")
            if t is not None and int(stated or 0) == 0:
                continue
            sql(f"select evidence.derive_source_assessment({q(s)}, {q(t) if t else 'null'}, 'agent:loop4_process assess')")
            n += 1
    log(f"assessments derived: {n}")


# ====================================================================================================== projections and embeddings
def stage_projections():
    retired = one("select retrieval.retire_deterministic_digest_items()")
    log(f"deterministic digest items retired from the digests space: {retired}")
    counts = collections.Counter()
    for v in v4():
        if v["kind"] not in ("issue_thread", "forum_thread", "comparison_article", "probe_report"):
            continue
        tier = {"community": 3, "third_party_editorial": 3, "own_experiment": 1}.get(v["role"], 3)
        prefix = f"[{v['kind']} | {v['title'][:120]} | {(v['attrs'].get('created_at') or v['captured_at'] or '')[:10]}] "
        for n in sql_json(f"select json_build_object('id', n.id, 'text', n.inline_text, 'kind', n.unit_kind) from content.document_node n where n.representation_id={q(v['representation_id'])}"):
            if len((n["text"] or "").strip()) < 20 or one(f"select 1 from retrieval.projection_target where document_node_id={q(n['id'])}"):
                continue
            ents = [r[0] for r in sql_rows(f"select entity_id from content.unit_entity_role where node_id={q(n['id'])}")]
            kw = dict(entity_id=ents[0] if ents else None, secondary=ents[1:], document_type_code=v["kind"], unit_kind=n["kind"], document_id=v["document_id"], document_version_id=v["version_id"], source_role_code=v["role"], observed_at=v["captured_at"], prefix=prefix)
            for space in ("units", "knowledge_text"):
                L1.index_item(space, "unit", n["id"], n["text"][:2000], "corpus" if tier != 1 else "evidence", tier, "unit", **kw)
            counts[v["kind"]] += 1
    # claims touched in loop 4: re-index with tier 0 when verified (supersedes the earlier item of the same target and space)
    for r in sql_json(f"""select json_build_object('id', c.id, 'statement', c.statement, 'status', c.status::text, 'subject', (select entity_id from evidence.claim_subject s where s.claim_id=c.id limit 1),
                           'role', coalesce(c.structured->>'source_role', case when c.structured->>'path' = 'community_thread' then 'community' when c.structured->>'path' = 'comparison_article' then 'third_party_editorial' else 'first_party' end))
                           from evidence.claim c where c.tenant_id={q(TENANT)} and (c.producer_origin_digest like 'sha256:%' and (c.structured ? 'key' or c.structured->>'path' in ('community_thread','own_probe_finding','comparison_article')))"""):
        tier = 0 if r["status"] == "verified" else {"community": 3, "third_party_editorial": 3, "own_experiment": 1, "first_party": 2}.get(r["role"], 3)
        text = f"[{r['status']} claim] {r['statement']}"
        for space in ("assertions", "knowledge_text"):
            L1.index_item(space, "claim", r["id"], text, "evidence", tier, "claim", entity_id=r["subject"], assurance_rank=20 if r["status"] == "verified" else 10)
        counts["claims"] += 1
    log(f"projections: {dict(counts)}")


def stage_embed():
    L1.RUN_DIR = RUN4
    L1.stage_embed()


STAGES = {"actor_edges": stage_actor_edges, "registry": stage_registry, "acquire": stage_acquire, "units": stage_units, "claims": stage_claims, "probes": stage_probes, "attention": stage_attention,
          "release_events": stage_release_events, "event_sweep": stage_event_sweep, "assess": stage_assess, "projections": stage_projections, "embed": stage_embed}

if __name__ == "__main__":
    for s in sys.argv[1:]:
        log(f"=== stage {s}")
        STAGES[s]()
