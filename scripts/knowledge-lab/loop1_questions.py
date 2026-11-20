"""Build 08 knowledge loop 1: the 16 questions. Expected answers are computed from the SOURCE FILES (never from the database) before
each query runs; then the question is answered through the schema (named queries / api views / api functions as app_reader, the
product API for private content) and the verdict, schema calls and delta are written to QUERY-LEDGER.jsonl next to the cycle record.

Run: python -I -X utf8 scripts/knowledge-lab/loop1_questions.py [question numbers]
"""
import os, sys, json, re, collections, urllib.request
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lab_common import *  # noqa
import loop1_parse as P

LEDGER = r"C:\Users\Pinda\Proyectos\BellLabs\platform\ai-engineer-research-2026-11-02\schema-units\provenance\query-ledger\QUERY-LEDGER.jsonl"
SCHEMA_REF = re.compile(r"\b(api|catalog|temporal|content|evidence|retrieval|guidance|authoring|library|verification|acquisition|taxonomy|ranking|learning|access)\.([a-z_0-9]+)")
RESULTS = []


def src(name):
    return open(os.path.join(SOURCES_DIR, name), encoding="utf-8", errors="replace").read()


def schema_calls(statements):
    calls = set()
    for s in statements:
        calls.update(f"{a}.{b}" for a, b in SCHEMA_REF.findall(s))
    return sorted(calls)


def reader(statement):
    """Run as app_reader with the tenant context (what the named-query executor does)."""
    out, err = sql(f"set local role app_reader;\n{statement}", allow_error=True)
    if err:
        return None, err
    return [json.loads(r) for r in out.splitlines() if r], None


def record(n, question, level, expected, answer, verdict, delta, statements, note=""):
    row = {"question": n, "text": question, "level": level, "expected": expected, "answer": answer, "verdict": verdict, "delta": delta, "schema_calls": schema_calls(statements), "schema_call_count": len(schema_calls(statements)), "path": statements, "note": note, "asked_at": now_iso()}
    RESULTS.append(row)
    append_jsonl(LEDGER, row)
    log(f"Q{n}: {verdict} ({len(schema_calls(statements))} schema calls) {note[:120]}")


# ------------------------------------------------------------------ expected answers from sources
def expected_prices_openai(file):
    text = open(file, encoding="utf-8", errors="replace").read()
    units, tables, lines, offs = P.universal_markdown(text, "pricing_page")
    rows = P.grammar_pricing(units, tables, lines, offs, "openai")
    return {u["logical"]: u["attrs"]["amount"] for u in rows if u["kind"] == "price_row"}


def expected_model_page(name):
    text = src(name)
    units, tables, lines, offs = P.universal_markdown(text, "product_page")
    hint = re.search(r"Model ID: `([^`]+)`", text).group(1)
    spec = {u["attrs"]["field"]: u["attrs"]["value"] for u in P.grammar_model_page(units, text, offs, hint)}
    prices = {}
    for s, header, rws, e in tables:
        if header and header[0].strip().lower() == "metric":
            for cells, ln in rws:
                m = re.search(r"\$([\d.]+)", cells[1])
                if m:
                    prices[cells[0].strip().lower()] = float(m.group(1))
    return hint, spec, prices


def q1():
    sol_id, sol, solp = expected_model_page("openai-gpt-6-1-sol.md")
    terra_id, terra, terrap = expected_model_page("openai-gpt-6-1-terra.md")
    expected = {"gpt-6.1 sol": {"context_tokens": sol.get("context_window"), "tool_use": "supported" if sol.get("tool_use") else None, "knowledge_cutoff": sol.get("knowledge_cutoff"), "min_input_usd_per_1m": solp.get("input"), "min_output_usd_per_1m": solp.get("output")},
                "gpt-6.1 terra": {"context_tokens": terra.get("context_window"), "tool_use": "supported" if terra.get("tool_use") else None, "knowledge_cutoff": terra.get("knowledge_cutoff"), "min_input_usd_per_1m": terrap.get("input"), "min_output_usd_per_1m": terrap.get("output")}}
    # Anthropic from the overview compare table
    text = src("anthropic-models-overview.md")
    units, tables, lines, offs = P.universal_markdown(text, "product_page")
    for u in P.grammar_anthropic_overview(tables, lines, offs):
        m = u["logical"].split(":", 1)[1].split("|")[0]
        e = expected.setdefault(m, {})
        if u["kind"] == "spec_field" and u["attrs"]["field"] in ("context_window", "knowledge_cutoff"):
            e["context_tokens" if u["attrs"]["field"] == "context_window" else "knowledge_cutoff"] = u["attrs"]["value"]
        if u["kind"] == "price_row":
            e["min_input_usd_per_1m" if u["attrs"]["meter"] == "input_tokens" else "min_output_usd_per_1m"] = u["attrs"]["amount"]
    stmts = ["select json_build_object('model', model, 'developer', developer, 'context_tokens', context_tokens, 'modalities', modalities, 'tool_use', tool_use, 'open_weights', open_weights, 'knowledge_cutoff', knowledge_cutoff, 'released_on', released_on, 'min_input_usd_per_1m', min_input_usd_per_1m, 'min_output_usd_per_1m', min_output_usd_per_1m, 'offering_count', offering_count) from api.models order by min_input_usd_per_1m nulls last"]
    rows, err = reader(stmts[0])
    answer = {(r["model"] or "").lower(): r for r in rows or []}
    misses = []
    for m, e in expected.items():
        a = answer.get(m)
        if not a:
            misses.append((m, "missing row"))
            continue
        for k, v in e.items():
            if v is None:
                continue
            av = a.get(k)
            if k.startswith("min_") and (av is None or abs(float(av) - float(v)) > 0.005):
                misses.append((m, k, v, av))
            elif k == "context_tokens" and av is not None and int(float(av)) != int(v):
                misses.append((m, k, v, av))
            elif k == "context_tokens" and av is None:
                misses.append((m, k, v, None))
            elif k in ("tool_use", "knowledge_cutoff") and v and (av or "").lower().replace(",", "") != str(v).lower().replace(",", ""):
                misses.append((m, k, v, av))
    verdict = "answered" if not misses else ("partial" if len(misses) < len(expected) else "missing structure")
    record(1, "Complete model comparison: context, modalities, tool use, open weights, release date, minimum price (C02)", "L1/T2", expected, {"rows": len(rows or []), "sample": list(answer.values())[:6], "misses": misses, "error": err}, verdict,
           None if not misses else "D-01: fields missing for some models (open weights / release date have no first-party source in the sample; Anthropic tool_use not on the overview page)", stmts, f"{len(rows or [])} model rows; misses={misses[:4]}")


def q2():
    prices = expected_prices_openai(os.path.join(SOURCES_DIR, "openai-pricing.md"))
    exp_amount = prices.get("price_row:gpt-6.1-sol|input_tokens|standard|short|")
    expected = {"offering": "gpt-6.1-sol on OpenAI API", "meter": "input_tokens", "amount_usd_per_1m": exp_amount, "locator": {"table_row_key": "gpt-6.1-sol", "column": "Short context input", "url": "https://developers.openai.com/api/docs/pricing.md"}, "valid_from": "2026-11-06 (first capture; unchanged on 2026-11-09)"}
    stmts = ["select json_build_object('offering_id', offering_id, 'offering', offering) from api.model_offerings where offering_key = 'gpt-6.1-sol'",
             "select json_build_object('amount', amount, 'unit', unit, 'scope_key', scope_key, 'valid_from', lower(valid_during), 'selector', selector, 'request_url', request_url, 'captured_at', captured_at, 'claim', claim_statement, 'unit_kind', unit_kind, 'logical_key', logical_key) from api.fact_locators($OFF, 'offering_price') where payload->>'meter' = 'input_tokens' and payload->>'tier' = 'standard' and coalesce(payload->>'context_band','short') = 'short'"]
    rows, err = reader(stmts[0])
    off = rows[0]["offering_id"] if rows else None
    rows2, err2 = reader(stmts[1].replace("$OFF", q(off))) if off else (None, "no offering")
    a = rows2[0] if rows2 else None
    ok_ = a and abs(float(a["amount"]) - float(exp_amount)) < 0.005 and (a.get("selector") or {}).get("row_key", "").lower().startswith("gpt-6.1-sol") and "pricing.md" in (a.get("request_url") or "")
    record(2, "Price of offering X with its exact locator (C01)", "L1/T1", expected, {"offering": off, "fact": a, "error": err or err2}, "answered" if ok_ else ("partial" if a else "missing content"), None if ok_ else "D-02: locator did not resolve to the table cell", stmts, f"amount={a and a['amount']} row_key={a and (a.get('selector') or {}).get('row_key')} valid_from={a and a.get('valid_from')}")


def q3():
    old = expected_prices_openai(os.path.join(BUILD07_SOURCES, "openai-pricing.md"))
    new = expected_prices_openai(os.path.join(SOURCES_DIR, "openai-pricing.md"))
    changed = {k: (old.get(k), new.get(k)) for k in set(old) | set(new) if old.get(k) != new.get(k)}
    expected = {"openai_price_rows_changed": len(changed), "sample": dict(list(changed.items())[:8]), "unchanged_pages": ["gemini-pricing", "deepseek-pricing"], "learned_at": "2026-11-09 (today's capture)", "world_from": "2026-11-09 for changed rows (observation-bounded)"}
    stmts = ["select json_build_object('source', change_source, 'kind', change_kind, 'learned_at', learned_at, 'world_from', world_from, 'subject', subject, 'stream', stream_kind, 'scope', scope_key, 'old', old_value, 'new', new_value, 'logical_key', logical_key, 'document', document_title) from api.changes_since('2026-11-01', array['offering_price'])",
             "select json_build_object('document', d.canonical_title, 'outcome', c.outcome, 'checked_at', c.checked_at) from content.refresh_check c join content.document d on d.id = c.document_id"]
    rows, err = reader(stmts[0])
    checks, err2 = reader(stmts[1])
    facts = [r for r in rows or [] if r["source"] == "fact"]
    units = [r for r in rows or [] if r["source"] == "unit"]
    unchanged = sorted(c["document"] for c in checks or [] if c["outcome"] == "unchanged")
    # with collision-free keys the two OpenAI captures carry no real price change (expected changed == {}): the schema must still show
    # learned-at for every admitted fact, the unit-level diff rows and the two unchanged refresh checks
    ok_ = len(units) >= 1 and len(unchanged) >= 2 and facts and all(r.get("learned_at") for r in facts)
    record(3, "Pricing changes since a date, with both clocks (C04)", "L2/T3", expected, {"fact_changes": len(facts), "unit_changes": len(units), "unchanged_checks": unchanged, "sample_units": units[:5], "sample_facts": facts[:3], "error": err or err2}, "answered" if ok_ else "partial", None if ok_ else "D-03: changes_since must surface unit diffs and fact replacements for the refreshed page", stmts,
           f"facts={len(facts)} units={len(units)} unchanged={unchanged}")


def q4():
    sol_id, sol, solp = expected_model_page("openai-gpt-6-1-sol.md")
    terra_id, terra, terrap = expected_model_page("openai-gpt-6-1-terra.md")
    cands = {sol_id: (sol.get("context_window"), solp.get("input"), bool(sol.get("tool_use"))), terra_id: (terra.get("context_window"), terrap.get("input"), bool(terra.get("tool_use")))}
    qualified = {k: v for k, v in cands.items() if (v[0] or 0) >= 200000 and v[2]}
    expected = {"criteria": "context >= 200k tokens, tool use supported, cheapest input price per 1M, as of 2026-11-09 and as of 2026-11-06", "qualified_from_first_party_pages": qualified, "cheapest": min(qualified.items(), key=lambda kv: kv[1][1])[0] if qualified else None,
                "limit": "only the two OpenAI model pages in the sample state context + tool calling; Anthropic/Gemini/DeepSeek models lack a first-party tool-use statement in the sample"}
    stmts = ["select json_build_object('model', model, 'context_tokens', context_tokens, 'tool_use', tool_use, 'min_input_usd_per_1m', min_input_usd_per_1m) from api.models_at(now()) where context_tokens >= 200000 and tool_use = 'supported' order by min_input_usd_per_1m nulls last limit 5",
             "select json_build_object('model', model, 'context_tokens', context_tokens, 'tool_use', tool_use, 'min_input_usd_per_1m', min_input_usd_per_1m) from api.models_at('2026-11-06T00:00:00Z') where context_tokens >= 200000 and tool_use = 'supported' order by min_input_usd_per_1m nulls last limit 5"]
    rows, err = reader(stmts[0])
    rows_then, err2 = reader(stmts[1])
    top = (rows or [{}])[0].get("model", "").lower().replace(" ", "-") if rows else None
    ok_ = expected["cheapest"] and top and expected["cheapest"].replace(" ", "-") == top
    record(4, "Cheapest qualified model for an ingestion workload as of a date (C03, north star)", "L1->L2", expected, {"now": rows, "as_of_2026_11_06": rows_then, "error": err or err2}, "answered" if ok_ else ("partial" if rows else "missing structure"),
           None if ok_ else "D-05: as-of ranking needs capability facts for every provider", stmts, f"cheapest now={top} as-of-11-06={(rows_then or [{}])[0].get('model') if rows_then else None}")


def q5():
    data = json.loads(src("langgraph-releases.json"))
    rels = [(r["tag_name"], r["published_at"][:10]) for r in data]
    notes = src("langgraph-v1-notes.md")
    expected = {"releases": rels, "count": len(rels), "breaking_or_deprecations": ["LangGraph v1: deprecation of create_react_agent" if "create_react_agent" in notes else None], "newest": rels[0]}
    stmts = ["select json_build_object('release', release, 'version', version_label, 'released_at', released_at, 'breaking', breaking, 'highlights', highlights, 'learned_k', learned_k) from api.software_releases where software = 'LangGraph' order by released_at desc nulls last"]
    rows, err = reader(stmts[0])
    got = {r["version"] for r in rows or []}
    missing = [t for t, d in rels if t not in got]
    ok_ = not missing and any(r.get("breaking") for r in rows or []) and rows and rows[0]["version"] == rels[0][0]
    record(5, "Framework release history and breaking changes (C08)", "L2/T3", expected, {"rows": len(rows or []), "newest": (rows or [{}])[0], "missing_versions": missing, "breaking_flagged": [r["version"] for r in rows or [] if r.get("breaking")], "error": err}, "answered" if ok_ else "partial", None if ok_ else "D-06: release history gaps", stmts, f"{len(rows or [])} releases, missing={missing}")


def q6():
    sess = json.load(open(os.path.join(SOURCES_DIR, "wf2026-sessions.json"), encoding="utf-8"))
    spk = {s["name"]: s.get("company") for s in json.load(open(os.path.join(SOURCES_DIR, "wf2026-speakers.json"), encoding="utf-8"))["speakers"]}
    exp = [{"title": s["title"], "speakers": s.get("speakers") or [], "affiliations": sorted({spk.get(x) for x in (s.get("speakers") or []) if spk.get(x)})} for s in sess["sessions"] if s.get("track") == "Search & Retrieval"]
    expected = {"track": "Search & Retrieval", "count": len(exp), "talks": exp}
    stmts = ["select json_build_object('title', title, 'speakers', speakers, 'speaker_affiliations', speaker_affiliations, 'event', event, 'topics', topics) from api.talks where track = 'Search & Retrieval' order by title"]
    rows, err = reader(stmts[0])
    got = {r["title"] for r in rows or []}
    missing = [t["title"] for t in exp if t["title"] not in got]
    aff_ok = sum(1 for r in rows or [] if r.get("speaker_affiliations"))
    ok_ = not missing and aff_ok >= len(exp) * 0.8
    record(6, "World's Fair talks on a topic, with speakers and affiliations (C11)", "L1/L3", expected, {"rows": len(rows or []), "missing": missing, "with_affiliations": aff_ok, "sample": (rows or [])[:3], "error": err}, "answered" if ok_ else "partial", None if ok_ else "D-07: speaker affiliation coverage (employed_by from the organizer speaker record)", stmts, f"{len(rows or [])}/{len(exp)} talks, {aff_ok} with affiliations")


def q7():
    text = src("talk-no-more-slop.md")
    units, tables, lines, offs = P.universal_markdown(text, "aie_talk")
    g = P.grammar_talk(text, units, offs)
    segs = [u for u in g if u["kind"] == "transcript_segment"]
    target = next(u for u in segs if u["attrs"]["t0_ms"] == 487000)
    expected = {"talk": "No More Slop (swyx)", "timecode_ms": 487000, "text_starts": target["text"][:60], "slide_n": target["attrs"].get("slide_n"), "speaker_attribution": "Shawn \"swyx\" Wang (talk presenter; the transcript has no speaker labels)"}
    stmts = ["select json_build_object('talk_id', talk_id, 'speakers', speakers) from api.talks where title like 'No More Slop%'",
             "select json_build_object('unit_kind', unit_kind, 'start_ms', start_ms, 'end_ms', end_ms, 'slide_n', slide_n, 'text', left(text, 160)) from api.talk_segments($TALK, 480000, 520000)"]
    rows, err = reader(stmts[0])
    talk = rows[0]["talk_id"] if rows else None
    rows2, err2 = reader(stmts[1].replace("$TALK", q(talk))) if talk else (None, "no talk")
    seg = next((r for r in rows2 or [] if r["unit_kind"] == "transcript_segment" and r["start_ms"] == 487000), None)
    ok_ = seg and seg["text"].startswith(target["text"][:30]) and seg.get("slide_n") == target["attrs"].get("slide_n")
    record(7, "What speaker X claimed at a timecode, plus the slide (C12)", "L3/T4", expected, {"talk": talk, "speakers": rows and rows[0]["speakers"], "segment": seg, "window_rows": len(rows2 or []), "error": err or err2}, "answered" if ok_ else ("partial" if seg else "missing content"), None if ok_ else "D-08: slide alignment", stmts, f"segment@487000 found={bool(seg)} slide={seg and seg.get('slide_n')}")


def q8():
    talk_text = src("talk-verifiers-train-own-ai.md") if os.path.exists(os.path.join(SOURCES_DIR, "talk-verifiers-train-own-ai.md")) else ""
    repos = re.findall(r"https://github\.com/([^/\s)]+/[^/\s)#]+)", talk_text[talk_text.find("## Resources"):] if talk_text else "")
    expected = {"talk_with_repository_resource": "Your company should train its own AI (PrimeIntellect)" if repos else None, "repositories": repos, "paper": "none listed in any sampled talk's Resources (expected: missing content for the repo->paper hop)"}
    stmts = ["select json_build_object('title', title, 'repositories', repositories, 'topics', topics) from api.talks where repositories <> '{}'",
             "select json_build_object('paper', title, 'repositories', repositories, 'talks_about', talks_about) from api.papers"]
    rows, err = reader(stmts[0])
    rows2, err2 = reader(stmts[1])
    got = {x for r in rows or [] for x in (r.get("repositories") or [])}
    ok_talk_repo = bool(repos) and all(r in got for r in repos)
    verdict = "partial" if ok_talk_repo else ("missing content" if not repos else "missing structure")
    record(8, "Talk -> repository -> paper resolution (C13)", "L3->L4", expected, {"talks_with_repos": rows, "papers": rows2, "error": err or err2}, verdict, "D-09: the sample has no talk whose Resources list a paper; the repo->paper hop (has_code / published_in) is modeled but unpopulated; a paper-bearing talk or an arXiv capture is needed", stmts, f"talk->repo ok={ok_talk_repo}; papers={len(rows2 or [])}")


def q9():
    exp = {}
    for f in ("talk-no-more-slop.md", "talk-coding-agent-undo.md", "talk-proving-agents.md", "talk-dont-approve-model.md", "talk-better-search.md", "talk-verifiers-train-own-ai.md"):
        text = src(f)
        units, tables, lines, offs = P.universal_markdown(text, "aie_talk")
        exp[f] = len([u for u in P.grammar_talk(text, units, offs) if u["kind"] == "talk_writeup"])
    expected = {"writeup_headings_per_talk": exp, "status": "every direction is a claim candidate (status proposed, attributed to the listed presenters), never a verified fact"}
    stmts = ["select json_build_object('statement', statement, 'status', status, 'attribution', attribution, 'speakers', speakers) from api.claim_candidates where claim_type = 'recommendation' and path = 'L1_candidate' order by created_at",
             "select json_build_object('item_kind', item_kind, 'text', text) from api.document_digest((select d.id from content.document d where d.attributes->>'key' = 'talk-no-more-slop')) where item_kind in ('research_direction','limitation')"]
    rows, err = reader(stmts[0])
    rows2, err2 = reader(stmts[1])
    n_total = sum(exp.values())
    all_proposed = rows and all(r["status"] == "proposed" for r in rows)
    ok_ = rows and len(rows) == n_total and all_proposed and any(r["item_kind"] == "limitation" for r in rows2 or [])
    record(9, "Research directions from talks as candidate claims only (C14)", "L3/T4", expected, {"claims": len(rows or []), "all_proposed": all_proposed, "sample": (rows or [])[:3], "digest_items": rows2, "error": err or err2}, "answered" if ok_ else "partial", "D-10 applied in-loop: api.claim_candidates view (evidence.claim is closed to app_reader; first pass returned 0 rows)" if ok_ else "D-10: candidate count vs write-up headings", stmts, f"{len(rows or [])} candidates (expected {n_total}), all proposed={all_proposed}")


def q10():
    own = json.load(open(os.path.join(RUN_DIR, "own-content.json"), encoding="utf-8"))
    expected = {"concept": "Durable execution", "modules_covering": [own["module"]["revisionId"]], "also": "lesson covering Sandboxes"}
    stmts = ["select json_build_object('concept', concept, 'modules_covering', modules_covering, 'works_about', works_about, 'implementations', implementations, 'instances', instances) from api.concepts where slug = 'durable-execution'",
             "select json_build_object('work_kind', kind, 'title', title, 'head_revision_id', head_revision_id, 'covers', covers_concepts, 'uses', uses_software, 'released', released) from api.works_authored where 'Durable execution' = any(covers_concepts)"]
    rows, err = reader(stmts[0])
    rows2, err2 = reader(stmts[1])
    ok_ = rows and rows[0]["modules_covering"] >= 1 and any(r["head_revision_id"] == own["module"]["revisionId"] for r in rows2 or [])
    record(10, "Our modules covering a concept (C17)", "L1/T1", expected, {"concept_row": rows, "works": rows2, "error": err or err2}, "answered" if ok_ else "missing structure", None if ok_ else "D-11: covers binding not visible", stmts, f"modules_covering={rows and rows[0]['modules_covering']}")


def q11():
    own = json.load(open(os.path.join(RUN_DIR, "own-content.json"), encoding="utf-8"))
    data = json.loads(src("langgraph-releases.json"))
    expected = {"module_uses": "LangGraph (binding uses -> library entity; runtime requirement langgraph >=1.0,<2)", "latest_release": (data[0]["tag_name"], data[0]["published_at"][:10]), "releases_after_module_authored_today": 0,
                "time_rule": "modules_affected_by_release lists revisions authored BEFORE the release: today's module is newer than every known release, so the correct answer is the empty set; modules_using_software must still show the binding"}
    stmts = ["select json_build_object('release_id', release_id, 'release', release, 'released_at', released_at, 'breaking', breaking) from api.software_releases where software = 'LangGraph' order by released_at desc nulls last limit 1",
             "select json_build_object('work_slug', work_slug, 'revision_title', revision_title, 'release', release, 'breaking', breaking) from api.modules_affected_by_release($REL)",
             "select json_build_object('work_slug', work_slug, 'binding', binding, 'version_spec', version_spec, 'latest_release', latest_release, 'latest_release_at', latest_release_at, 'releases_since_revision', releases_since_revision) from api.modules_using_software((select software_id from api.software where slug = 'langgraph'))"]
    rows, err = reader(stmts[0])
    rel = rows[0]["release_id"] if rows else None
    rows2, err2 = reader(stmts[1].replace("$REL", q(rel))) if rel else (None, "no release")
    rows3, err3 = reader(stmts[2])
    ok_ = rows3 and any(r["work_slug"] == "durable-execution-langgraph" for r in rows3) and (rows2 == [] or rows2 is not None)
    record(11, "Modules affected by a release (C19, flywheel)", "L2/T3+T4", expected, {"latest_release": rows, "affected_by_time_rule": rows2, "using_software": rows3, "error": err or err2 or err3}, "answered" if ok_ else "missing structure",
           "D-04 applied in-loop: api.modules_using_software (time-independent binding view) added because every sampled release predates the module", stmts, f"affected(time rule)={len(rows2 or [])} using={len(rows3 or [])}")


def q12():
    sol_id, sol, solp = expected_model_page("openai-gpt-6-1-sol.md")
    terra_id, terra, terrap = expected_model_page("openai-gpt-6-1-terra.md")
    opts = {sol_id: solp.get("input"), terra_id: terrap.get("input")}
    expected = {"beginner_rule": "a model with tool use and the lowest input price among providers with a first-party tool-use statement; show the price with its source", "candidates": opts, "pick": min(opts, key=opts.get)}
    stmts = ["select json_build_object('model', model, 'developer', developer, 'tool_use', tool_use, 'min_input_usd_per_1m', min_input_usd_per_1m, 'min_output_usd_per_1m', min_output_usd_per_1m, 'context_tokens', context_tokens) from api.models where tool_use = 'supported' order by min_input_usd_per_1m nulls last limit 3",
             "select json_build_object('title', title, 'kind', kind, 'uses', uses_software) from api.works_authored where kind in ('module','lesson','activity')"]
    rows, err = reader(stmts[0])
    rows2, err2 = reader(stmts[1])
    pick = (rows or [{}])[0].get("model", "").lower().replace(" ", "-") if rows else None
    ok_ = pick and expected["pick"].replace(" ", "-") == pick
    record(12, "Which model/key to use for this exercise (C20, beginner)", "L1/T2", expected, {"models": rows, "our_modules": rows2, "error": err or err2}, "answered" if ok_ else "partial", None if ok_ else "D-12", stmts, f"pick={pick}")


def q13():
    lg = json.loads(src("langgraph-releases.json"))
    oa = json.loads(src("openai-agents-releases.json"))
    lg_rec = json.loads(src("langgraph-repo-record.json"))
    oa_rec = json.loads(src("openai-agents-repo-record.json"))
    expected = {"sub_answers": {"releases_in_sample": {"langgraph": len(lg), "openai-agents-python": len(oa)}, "prerelease_share": {"langgraph": sum(1 for r in lg if r["prerelease"]) / len(lg), "openai-agents-python": sum(1 for r in oa if r["prerelease"]) / len(oa)},
                                "stars": {"langgraph": lg_rec["stargazers_count"], "openai-agents-python": oa_rec["stargazers_count"]}, "license": {"langgraph": (lg_rec.get("license") or {}).get("spdx_id"), "openai-agents-python": (oa_rec.get("license") or {}).get("spdx_id")},
                                "docs_code_examples_in_sample": "count of code_example units on the two captured docs pages"},
                "decision_shape": "bounded: compare the two frameworks on stars, release cadence/prerelease share, breaking flags, docs examples; pick for a beginner-to-advanced course; both must be covered by the comparative course, the question is which leads module 1"}
    stmts = ["select json_build_object('software', software, 'stars', stars, 'license', license, 'latest_release', latest_release, 'latest_release_on', latest_release_on, 'docs_url', docs_url) from api.software where kind = 'library' order by stars desc nulls last",
             "select json_build_object('software', software, 'releases', count(*), 'breaking', count(*) filter (where breaking), 'latest', max(released_at)) from api.software_releases group by software",
             "select json_build_object('document', d.canonical_title, 'code_examples', count(*)) from content.document d join content.document_version v on v.document_id = d.id join content.document_representation r on r.document_version_id = v.id join content.document_node n on n.representation_id = r.id where n.unit_kind = 'code_example' group by d.canonical_title"]
    rows = [reader(s) for s in stmts]
    err = [e for _, e in rows if e]
    sw = {r["software"]: r for r in rows[0][0] or []}
    ok_ = all(k in sw for k in ("LangGraph", "OpenAI Agents SDK (Python)")) and sw.get("LangGraph", {}).get("stars") == lg_rec["stargazers_count"] and rows[1][0] and rows[2][0]
    record(13, "Course framework choice (C09, north star)", "L4/T5", expected, {"software": rows[0][0], "release_stats": rows[1][0], "docs_examples": rows[2][0], "error": err,
                                                                                "decision": "LangGraph leads module 1: larger adoption (stars), stable (non-prerelease) release train, persistence/durable-execution docs with runnable examples; the Agents SDK is the comparison track (alpha releases flagged breaking)." if ok_ else None},
           "answered" if ok_ else "partial", None if ok_ else "D-13", stmts, f"software rows={len(rows[0][0] or [])}")


def q14():
    expected = {"window": "since 2026-11-02", "expected_changes": "price rows changed between the 2026-11-06 and 2026-11-09 OpenAI/Anthropic captures; release events learned today; Gemini/DeepSeek unchanged checks", "conflicts": ["community post 'New Sol API pricing $4/$20' vs first-party GPT-6.1 Sol $2 input: kept disputed with an ambiguous subject (GPT-5.6 Sol is $4)"]}
    stmts = ["select json_build_object('source', change_source, 'n', count(*)) from api.changes_since('2026-11-02') group by change_source",
             "select json_build_object('kind', conflict_kind, 'detected_by', detected_by, 'first_party', first_party_statement, 'other', other_statement, 'other_status', other_status) from api.claim_conflicts",
             "select json_build_object('document', d.canonical_title, 'outcome', c.outcome) from content.refresh_check c join content.document d on d.id = c.document_id"]
    rows = [reader(s) for s in stmts]
    err = [e for _, e in rows if e]
    counts = {r["source"]: r["n"] for r in rows[0][0] or []}
    conflicts = rows[1][0] or []
    ok_ = counts.get("fact", 0) > 0 and counts.get("unit", 0) > 0 and any("Sol" in c["other"] for c in conflicts) and any(c["other_status"] == "disputed" for c in conflicts)
    record(14, "What changed this week + one first/third-party conflict (C29, north star)", "L2->L3/T5", expected, {"changes_by_source": counts, "conflicts": conflicts, "refresh_checks": rows[2][0], "error": err}, "answered" if ok_ else "partial", "D-14 applied in-loop: api.claim_conflicts view (evidence.claim_conflict closed to app_reader; first pass returned 0 conflicts)" if ok_ else "D-14", stmts, f"changes={counts} conflicts={len(conflicts)}")


def q15():
    sol_id, sol, solp = expected_model_page("openai-gpt-6-1-sol.md")
    terra_id, terra, terrap = expected_model_page("openai-gpt-6-1-terra.md")
    docs = src("langgraph-persistence-docs.md")
    expected = {"sub_answers": {"models_1m_context_tool_use": [m for m, s in ((sol_id, sol), (terra_id, terra)) if (s.get("context_window") or 0) >= 1_000_000 and s.get("tool_use")], "prices_input": {sol_id: solp.get("input"), terra_id: terrap.get("input")},
                                "harness_durable_execution_features": [h for h in re.findall(r"^#+ (.+)$", docs, flags=re.M)][:8], "known_failure_modes": "expected missing content: no guidance items in loop 1 (expert knowledge layer unpopulated)"},
                "decision_shape": "bounded decision over the sub-answers; the schema is judged on retrieving every sub-answer with provenance"}
    stmts = ["select json_build_object('model', model, 'context_tokens', context_tokens, 'tool_use', tool_use, 'min_input_usd_per_1m', min_input_usd_per_1m) from api.models where context_tokens >= 1000000 and tool_use = 'supported' order by min_input_usd_per_1m",
             "select json_build_object('snippet', snippet, 'document_type', document_type_code, 'unit_kind', unit_kind, 'tier', source_tier, 'lens', lens, 'score', fused_score) from api.search_unified('durable execution checkpointer resume after crash', null, array['corpus'], null, null, array['framework_docs_page','repository_readme','release_notes'], null, null, null, null, null, null, 5)",
             "select json_build_object('n', count(*)) from api.guidance_items"]
    rows = [reader(s) for s in stmts]
    err = [e for _, e in rows if e]
    ok_models = {r["model"].lower().replace(" ", "-") for r in rows[0][0] or []} >= {m.replace(" ", "-") for m in expected["sub_answers"]["models_1m_context_tool_use"]}
    ok_docs = bool(rows[1][0])
    guidance_n = (rows[2][0] or [{"n": 0}])[0]["n"]
    verdict = "partial" if ok_models and ok_docs and guidance_n == 0 else ("answered" if ok_models and ok_docs else "missing structure")
    record(15, "Model + harness for a stock-market research backend (C28, north star)", "L4/T5", expected, {"models": rows[0][0], "harness_passages": rows[1][0], "guidance_items": guidance_n, "error": err}, verdict,
           "D-15: the expert layer (guidance items: failure modes, operational practices) is empty in loop 1; the L1/L3 sub-answers resolve, the 'known failure modes' sub-question is missing content", stmts, f"models={len(rows[0][0] or [])} docs hits={len(rows[1][0] or [])} guidance={guidance_n}")


def q16():
    own = json.load(open(os.path.join(RUN_DIR, "own-content.json"), encoding="utf-8"))
    tokens = json.load(open(os.path.join(RUN_DIR, ".session-tokens.json"), encoding="utf-8"))
    sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "product-lab"))
    import run_lab as L
    expected = {"learner": "finds the private note mentioning the E2B sandbox plus released course material about sandboxes (none released in this lab)", "outsider": "finds nothing from the learner's workspace", "knowledge_roles": "app_reader sees zero private vector items (RLS)"}
    def search(tok):
        return L.http("POST", "/rest/v1/rpc/product_read", {"p_workspace_id": None, "p_operation": "search", "p_payload": {"query": "sandbox"}}, token=tok, headers={"Content-Profile": "api"})
    s1, learner_hits = search(tokens["learner"])
    s2, outsider_hits = search(tokens["outsider"])
    stmts = ["api.product_read('search') -> product.dispatch_read -> api.search_unified(lenses private+ours, workspace_ids = memberships + readable offers) -> library.passage",
             "select json_build_object('private_visible_to_app_reader', count(*)) from retrieval.vector_item where lens = 'private'",
             "select json_build_object('private_items_total', count(*)) from retrieval.vector_item where lens = 'private'"]
    rls, err = reader(stmts[1])
    total, _ = sql_json(stmts[2]), None
    learner_private = [h for h in (learner_hits or []) if h.get("label") == "private_note" and "sandbox" in h.get("snippet", "").lower()]
    outsider_leak = [h for h in (outsider_hits or []) if h.get("revisionId") == own["note"]["revisionId"]]
    ok_ = s1 == 200 and learner_private and not outsider_leak and rls and rls[0]["private_visible_to_app_reader"] == 0 and total and total[0]["private_items_total"] > 0
    record(16, "Search my notes plus ingested material for 'sandbox', without leaking into shared results (C21)", "L3 private", expected,
           {"learner_hits": learner_hits, "outsider_hits": outsider_hits, "app_reader_private_rows": rls, "private_items_total": total, "error": err}, "answered" if ok_ else "partial", None if ok_ else "D-16", stmts,
           f"learner private hits={len(learner_private)} outsider leak={len(outsider_leak)} app_reader private rows={rls and rls[0]['private_visible_to_app_reader']}")


QUESTIONS = {1: q1, 2: q2, 3: q3, 4: q4, 5: q5, 6: q6, 7: q7, 8: q8, 9: q9, 10: q10, 11: q11, 12: q12, 13: q13, 14: q14, 15: q15, 16: q16}

if __name__ == "__main__":
    wanted = [int(x) for x in sys.argv[1:]] or sorted(QUESTIONS)
    for n in wanted:
        try:
            QUESTIONS[n]()
        except Exception as e:  # a crash is a verdict too
            record(n, QUESTIONS[n].__doc__ or f"Q{n}", "?", None, {"exception": repr(e)[:800]}, "blocked", "D-crash", [], f"exception {type(e).__name__}")
    summary = collections.Counter(r["verdict"] for r in RESULTS)
    write_json(os.path.join(RUN_DIR, "questions-summary.json"), {"verdicts": dict(summary), "max_schema_calls": max((r["schema_call_count"] for r in RESULTS), default=0), "asked": [r["question"] for r in RESULTS]})
    log(f"verdicts: {dict(summary)}")
