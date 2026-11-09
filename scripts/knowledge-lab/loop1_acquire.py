"""Build 08 knowledge loop 1, stage A: acquire the 9-kind sample with honest provenance.

Every fetch is one acquisition.fetch row (origin native_harness, tool http, status, sha, size) before it becomes an
evidence.source_capture -> content.document(_version/_representation). The Build 07 pricing captures (2026-11-06) are
replayed as capture 1 of the pricing pages (origin label says so), today's fetch is capture 2, which gives the loop its
real refresh diff. Run: python -I scripts/knowledge-lab/loop1_acquire.py
"""
import json, os, re, sys, uuid, datetime
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lab_common import *  # noqa

GITHUB_ACCEPT = "application/vnd.github+json"

# kind, source_role, format, url, file, title, publisher, extra
MANIFEST = [
    # 1. pricing pages (first party) -- capture 2 of the Build 07 set, same logical pages
    dict(key="openai-pricing", kind="pricing_page", role="first_party", fmt="markdown", url="https://developers.openai.com/api/docs/pricing.md", title="OpenAI API pricing", publisher="OpenAI", org="openai", build07="openai-pricing.md"),
    dict(key="anthropic-pricing", kind="pricing_page", role="first_party", fmt="markdown", url="https://platform.claude.com/docs/en/about-claude/pricing.md", title="Anthropic model pricing", publisher="Anthropic", org="anthropic", build07="anthropic-pricing-docs.html", build07_fmt="html"),
    dict(key="gemini-pricing", kind="pricing_page", role="first_party", fmt="markdown", url="https://aistudio.google.com/docs/pricing.md", title="Gemini API pricing", publisher="Google", org="google", build07="gemini-pricing.md"),
    dict(key="deepseek-pricing", kind="pricing_page", role="first_party", fmt="markdown", url="https://api-docs.deepseek.com/quick_start/pricing.md", title="DeepSeek API pricing", publisher="DeepSeek", org="deepseek", build07="deepseek-pricing.md"),
    # 2. changelogs / release notes (first party, machine-structured GitHub releases + one release-notes page)
    dict(key="langgraph-releases", kind="github_release", role="first_party", fmt="json", url="https://api.github.com/repos/langchain-ai/langgraph/releases?per_page=12", title="langchain-ai/langgraph releases", publisher="LangChain", accept=GITHUB_ACCEPT, software="langgraph"),
    dict(key="openai-agents-releases", kind="github_release", role="first_party", fmt="json", url="https://api.github.com/repos/openai/openai-agents-python/releases?per_page=12", title="openai/openai-agents-python releases", publisher="OpenAI", accept=GITHUB_ACCEPT, software="openai-agents-python"),
    dict(key="mcp-python-sdk-releases", kind="github_release", role="first_party", fmt="json", url="https://api.github.com/repos/modelcontextprotocol/python-sdk/releases?per_page=8", title="modelcontextprotocol/python-sdk releases", publisher="Model Context Protocol", accept=GITHUB_ACCEPT, software="mcp-python-sdk"),
    dict(key="langgraph-v1-notes", kind="release_notes", role="first_party", fmt="markdown", url="https://docs.langchain.com/oss/python/releases/langgraph-v1.md", title="What's new in LangGraph v1", publisher="LangChain", software="langgraph"),
    # 3. model pages (first party): spec fields and pricing/eval tables
    dict(key="openai-models", kind="product_page", role="first_party", fmt="markdown", url="https://developers.openai.com/api/docs/models.md", title="OpenAI models", publisher="OpenAI", org="openai"),
    dict(key="openai-gpt-6-1-sol", kind="product_page", role="first_party", fmt="markdown", url="https://developers.openai.com/api/docs/models/gpt-6.1-sol.md", title="GPT-6.1 Sol model page", publisher="OpenAI", org="openai", model_hint="gpt-6.1-sol"),
    dict(key="openai-gpt-6-1-terra", kind="product_page", role="first_party", fmt="markdown", url="https://developers.openai.com/api/docs/models/gpt-6.1-terra.md", title="GPT-6.1 Terra model page", publisher="OpenAI", org="openai", model_hint="gpt-6.1-terra"),
    dict(key="anthropic-models-overview", kind="product_page", role="first_party", fmt="markdown", url="https://platform.claude.com/docs/en/about-claude/models/overview.md", title="Claude models overview", publisher="Anthropic", org="anthropic"),
    # 4. aie_talk: organizer session/speaker records + published talk pages (markdown with timestamped transcript)
    dict(key="wf2026-sessions", kind="aie_talk", role="event_organizer", fmt="json", url="https://ai.engineer/worldsfair/2026/sessions.json", title="AI Engineer World's Fair 2026 sessions", publisher="AI Engineer", event="worldsfair-2026"),
    dict(key="wf2026-speakers", kind="aie_talk", role="event_organizer", fmt="json", url="https://ai.engineer/worldsfair/2026/speakers.json", title="AI Engineer World's Fair 2026 speakers", publisher="AI Engineer", event="worldsfair-2026"),
    dict(key="talk-no-more-slop", kind="aie_talk", role="event_organizer", fmt="markdown", url="https://ai.engineer/talks/IoiHI7p12Ao-no-more-slop-swyx.md", title="No More Slop (swyx)", publisher="AI Engineer"),
    dict(key="talk-better-search", kind="aie_talk", role="event_organizer", fmt="markdown", url="https://ai.engineer/talks/3Ad73Onx3Aw-better-search-took-this-ai-agent.md", title="Better search took this AI agent ...", publisher="AI Engineer"),
    dict(key="talk-coding-agent-undo", kind="aie_talk", role="event_organizer", fmt="markdown", url="https://ai.engineer/talks/BT1Mo-fD-g0-your-coding-agent-cant-undo-its-own.md", title="Your coding agent can't undo its own ...", publisher="AI Engineer"),
    dict(key="talk-proving-agents", kind="aie_talk", role="event_organizer", fmt="markdown", url="https://ai.engineer/talks/5UgnatzpZ9E-building-ai-agent-is-easy-proving-its.md", title="Building an AI agent is easy, proving it ...", publisher="AI Engineer"),
    dict(key="talk-verifiers-train-own-ai", kind="aie_talk", role="event_organizer", fmt="markdown", url="https://ai.engineer/talks/5SRjPT2Eo7A-your-company-should-train-its-own-ai.md", title="Your company should train its own AI (PrimeIntellect)", publisher="AI Engineer"),
    dict(key="talk-dont-approve-model", kind="aie_talk", role="event_organizer", fmt="markdown", url="https://ai.engineer/talks/-uBABM2AuFg-dont-approve-ai-model-approve-app.md", title="Don't approve the AI model, approve the app", publisher="AI Engineer"),
    # 5. framework docs pages (first party)
    dict(key="langgraph-persistence-docs", kind="framework_docs_page", role="first_party", fmt="markdown", url="https://docs.langchain.com/oss/python/langgraph/durable-execution.md", title="LangGraph persistence / durable execution", publisher="LangChain", software="langgraph"),
    dict(key="openai-agents-running-docs", kind="framework_docs_page", role="first_party", fmt="html", url="https://openai.github.io/openai-agents-python/running_agents/", title="OpenAI Agents SDK: running agents", publisher="OpenAI", software="openai-agents-python"),
    # 6. repositories: README + the host's repository record (stars, license)
    dict(key="langgraph-readme", kind="repository_readme", role="first_party", fmt="markdown", url="https://raw.githubusercontent.com/langchain-ai/langgraph/main/README.md", title="langchain-ai/langgraph README", publisher="LangChain", software="langgraph"),
    dict(key="openai-agents-readme", kind="repository_readme", role="first_party", fmt="markdown", url="https://raw.githubusercontent.com/openai/openai-agents-python/main/README.md", title="openai/openai-agents-python README", publisher="OpenAI", software="openai-agents-python"),
    dict(key="langgraph-repo-record", kind="registry_listing_page", role="registry", fmt="json", url="https://api.github.com/repos/langchain-ai/langgraph", title="GitHub repository record: langchain-ai/langgraph", publisher="GitHub", accept=GITHUB_ACCEPT, software="langgraph"),
    dict(key="openai-agents-repo-record", kind="registry_listing_page", role="registry", fmt="json", url="https://api.github.com/repos/openai/openai-agents-python", title="GitHub repository record: openai/openai-agents-python", publisher="GitHub", accept=GITHUB_ACCEPT, software="openai-agents-python"),
    # 8. news / social (first-party announcement, third-party restatement, community post = the conflict candidate)
    dict(key="openai-sol-announcement", kind="official_blog_post", role="first_party", fmt="html", url="https://openai.com/index/introducing-gpt-6-1-sol/", title="Introducing GPT-6.1 Sol", publisher="OpenAI", org="openai", model_hint="gpt-6.1-sol"),
    dict(key="technology-org-terra", kind="news_article", role="third_party_editorial", fmt="html", url="https://www.technology.org/2026/10/27/openai-gpt-6-1-terra-computer-use-pricing-terminal-bench/", title="OpenAI launches GPT-6.1 Terra at $1 per million input tokens", publisher="Technology.org", model_hint="gpt-6.1-terra"),
    dict(key="aipricing-guru-sol", kind="analysis_post", role="third_party_editorial", fmt="html", url="https://www.aipricing.guru/models/gpt-6-1-sol/", title="GPT-6.1 Sol API pricing (aipricing.guru)", publisher="aipricing.guru", model_hint="gpt-6.1-sol"),
    dict(key="reddit-sol-pricing", kind="social_post", role="community", fmt="json", url="https://www.reddit.com/r/OpenAI/comments/1vx5mrz/new_sol_api_pricing_4_per_million_input_tokens/.json", title="Reddit: New Sol API pricing - $4 per million input tokens", publisher="reddit r/OpenAI", model_hint="gpt-6.1-sol", accept="application/json"),
    # 9. unclassified oddball: an iCal feed
    dict(key="wf2026-calendar", kind="unclassified", role="event_organizer", fmt="unknown", url="https://ai.engineer/worldsfair/2026/calendar.ics", title="World's Fair 2026 calendar.ics", publisher="AI Engineer"),
]

MEDIA_BY_FMT = {"markdown": "text/markdown", "html": "text/html", "json": "application/json", "unknown": "text/calendar"}
REPRESENTATION_KIND = {"markdown": "markdown", "html": "html", "json": "json", "unknown": "source_native"}


def ensure_source(src, url, publisher, source_class):
    host = re.sub(r"^https?://", "", url).split("/")[0]
    existing = one(f"select id from evidence.source where tenant_id={q(TENANT)} and canonical_url={q(url)}")
    if existing:
        return existing
    sid = str(uuid.uuid4())
    sql(f"""insert into evidence.source(id, tenant_id, source_class, canonical_url, publisher, sensitivity, host, registrable_domain, source_kind, first_seen_at, last_seen_at, capture_count)
            values ({q(sid)}, {q(TENANT)}, {q(source_class)}, {q(url)}, {q(publisher)}, 'public', {q(host)}, {q('.'.join(host.split('.')[-2:]))}, {q(src['kind'])}, now(), now(), 0)""")
    return sid


def register_capture(src, body, fetched, origin_label, requested_at, fmt, outcome="captured", prior_capture=None, tool="http", credits=None):
    """acquisition.fetch -> orchestration.artifact -> evidence.source_capture; returns (fetch_id, capture_id, sha, artifact_id)."""
    sha = sha256_bytes(body)
    media = MEDIA_BY_FMT.get(fmt, "application/octet-stream")
    fetch_id = str(uuid.uuid4())
    sql(f"""insert into acquisition.fetch(id, tenant_id, origin_kind, origin_label, tool, tool_version, request_url, final_url, requested_at, completed_at, http_status, outcome, content_sha256, media_type, size_bytes, credits_used, prior_capture_id, notes)
            values ({q(fetch_id)}, {q(TENANT)}, 'native_harness', {q(origin_label)}, {q(tool)}, 'urllib/python3.12', {q(src['url'])}, {q(fetched.get('final_url'))}, {q(requested_at)}, now(), {q(fetched.get('status'))}, {q(outcome)}, {q(sha)}, {q(media)}, {len(body)}, {q(credits)}, {q(prior_capture)}, {q({'elapsed_ms': fetched.get('elapsed_ms'), 'kind': src['kind'], 'format': fmt})})""")
    if outcome != "captured":
        return fetch_id, None, sha, None
    artifact = str(uuid.uuid4())
    object_path = f"{TENANT}/knowledge-loop-1/{src['key']}/{sha}"
    sql(f"""insert into orchestration.artifact(id, tenant_id, artifact_type, schema_version, sha256, bucket_class, storage_bucket, object_path, media_type, size_bytes, storage_state, available_at)
            values ({q(artifact)}, {q(TENANT)}, 'source_capture', 1, {q(sha)}, 'source_captures', 'lab-sources', {q(object_path)}, {q(media)}, {len(body)}, 'available', now())""")
    source_id = ensure_source(src, src["url"], src["publisher"], "api" if fmt == "json" else "web_page")
    capture = str(uuid.uuid4())
    sql(f"""insert into evidence.source_capture(id, tenant_id, source_id, artifact_id, content_sha256, media_type, captured_at, capture_method, capture_method_version, request_url, http_status, context, acquisition_fetch_id)
            values ({q(capture)}, {q(TENANT)}, {q(source_id)}, {q(artifact)}, {q(sha)}, {q(media)}, {q(requested_at)}, 'native_harness_http', '0.1', {q(src['url'])}, {q(fetched.get('status'))}, {q({'origin': origin_label, 'final_url': fetched.get('final_url')})}, {q(fetch_id)});
            update evidence.source set capture_count = capture_count + 1, last_seen_at = now(), last_capture_id = {q(capture)} where id = {q(source_id)}""")
    return fetch_id, capture, sha, artifact


def ensure_document(src):
    doc = one(f"select id from content.document where tenant_id={q(TENANT)} and canonical_title={q(src['title'])} and document_type_code={q(src['kind'])}")
    if doc:
        return doc
    doc = str(uuid.uuid4())
    source_id = ensure_source(src, src["url"], src["publisher"], "api" if src["fmt"] == "json" else "web_page")
    attrs = {k: v for k, v in src.items() if k in ("key", "org", "software", "event", "model_hint", "publisher")}
    sql(f"""insert into content.document(id, tenant_id, document_type_code, canonical_title, canonical_source_id, lifecycle, source_role_code, source_role_method, attributes)
            values ({q(doc)}, {q(TENANT)}, {q(src['kind'])}, {q(src['title'])}, {q(source_id)}, 'active', {q(src['role'])}, 'rule', {q(attrs)});
            insert into content.document_kind_assignment(tenant_id, document_id, document_type_code, method, confidence, rationale)
            values ({q(TENANT)}, {q(doc)}, {q(src['kind'])}, 'rule', 0.9, 'URL/publisher rule in the loop-1 manifest')""")
    return doc


def add_version(doc, capture, sha, artifact, fmt, label, published_at=None):
    existing = one(f"select id from content.document_version where document_id={q(doc)} and manifest_sha256={q(sha)}")
    if existing:
        return existing, False
    ver = str(uuid.uuid4())
    rep = str(uuid.uuid4())
    sql(f"""insert into content.document_version(id, tenant_id, document_id, version_label, published_at, manifest_sha256, correction_state, format_code)
            values ({q(ver)}, {q(TENANT)}, {q(doc)}, {q(label)}, {q(published_at)}, {q(sha)}, 'current', {q(fmt)});
            insert into content.document_version_source_capture(tenant_id, document_version_id, source_capture_id, capture_role, identity_confidence, resolution_evidence)
            values ({q(TENANT)}, {q(ver)}, {q(capture)}, 'primary', 1.0, {q({'rule': 'same canonical url'})});
            insert into content.document_representation(id, tenant_id, document_version_id, artifact_id, representation_kind, representation_class, media_type, content_sha256, acceptance_state, source_native_byte_identical, grammar_version)
            values ({q(rep)}, {q(TENANT)}, {q(ver)}, {q(artifact)}, {q(REPRESENTATION_KIND[fmt])}, 'source_native', {q(MEDIA_BY_FMT[fmt])}, {q(sha)}, 'accepted', true, 'build08-grammar/1')""")
    return ver, True


def main():
    ledger_path = os.path.join(RUN_DIR, "ACQUISITION-LEDGER.jsonl")
    if os.path.exists(ledger_path) and not sys.argv[1:]:
        os.remove(ledger_path)
    b07 = {s["file"]: s for s in json.load(open(os.path.join(BUILD07_SOURCES, "sources.json"), encoding="utf-8"))["sources"]}
    only = set(sys.argv[1:])
    for src in MANIFEST:
        if only and src['key'] not in only:
            continue
        doc = ensure_document(src)
        # capture 1 for pricing pages: the Build 07 files, replayed with their recorded fetch time
        prior_capture = None
        if src.get("build07"):
            meta = b07[src["build07"]]
            body = open(os.path.join(BUILD07_SOURCES, src["build07"]), "rb").read()
            fmt1 = src.get("build07_fmt", src["fmt"])
            fetched = {"status": meta["http_status"], "final_url": meta["final_url"], "elapsed_ms": None}
            f_id, cap, sha, art = register_capture(dict(src, url=meta["url"]), body, fetched, "replay of the Build 07 lab source set (plain HTTP GET on 2026-11-06, run_lab.py J10)", meta["fetched_at"], fmt1)
            ver, created = add_version(doc, cap, sha, art, fmt1, f"c1-{meta['fetched_at'][:10]}-{sha[:8]}")
            prior_capture = cap
            append_jsonl(ledger_path, {"key": src["key"], "capture": 1, "url": meta["url"], "fetched_at": meta["fetched_at"], "sha256": sha, "bytes": len(body), "format": fmt1, "fetch_id": f_id, "capture_id": cap, "version_id": ver, "origin": "build07_replay"})
        requested_at = now_iso()
        fetched = http_get(src["url"], accept=src.get("accept") or ("text/markdown" if src["fmt"] == "markdown" else None))
        ok = fetched["status"] == 200 and len(fetched["body"]) > 0
        path = os.path.join(SOURCES_DIR, src["key"] + {"markdown": ".md", "html": ".html", "json": ".json", "unknown": ".ics"}[src["fmt"]])
        if ok:
            open(path, "wb").write(fetched["body"])
        outcome = "captured" if ok else ("blocked" if fetched["status"] in (401, 403, 429) else "failed")
        # unchanged check against the prior capture (pricing pages)
        if ok and prior_capture:
            prior_sha = one(f"select content_sha256 from evidence.source_capture where id={q(prior_capture)}")
            if prior_sha == sha256_bytes(fetched["body"]):
                outcome = "unchanged"
        f_id, cap, sha, art = register_capture(src, fetched["body"] if ok else b"", fetched, "native harness fetch, Build 08 knowledge loop 1 (claude-code session 2026-11-08)", requested_at, src["fmt"], outcome=outcome, prior_capture=prior_capture)
        ver = None
        if outcome == "captured":
            ver, _ = add_version(doc, cap, sha, art, src["fmt"], f"c2-{requested_at[:10]}-{sha[:8]}")
        if prior_capture:
            prior_ver = one(f"select document_version_id from content.document_version_source_capture where source_capture_id={q(prior_capture)}")
            sql(f"""insert into content.refresh_check(tenant_id, document_id, prior_version_id, fetch_id, outcome, content_sha256, new_version_id)
                    values ({q(TENANT)}, {q(doc)}, {q(prior_ver)}, {q(f_id)}, {q('unchanged' if outcome == 'unchanged' else ('changed' if outcome == 'captured' else 'failed'))}, {q(sha if ok else None)}, {q(ver)})""")
        append_jsonl(ledger_path, {"key": src["key"], "capture": 2 if prior_capture else 1, "url": src["url"], "final_url": fetched.get("final_url"), "status": fetched["status"], "fetched_at": requested_at, "sha256": sha if ok else None, "bytes": len(fetched["body"]), "format": src["fmt"], "outcome": outcome, "fetch_id": f_id, "capture_id": cap, "version_id": ver, "document_id": doc, "file": os.path.basename(path) if ok else None})
        log(f"{src['key']}: {fetched['status']} {outcome} {len(fetched['body'])} bytes")
    write_json(os.path.join(RUN_DIR, "spend-acquire.json"), SPEND)
    log("acquisition done")


if __name__ == "__main__":
    main()
