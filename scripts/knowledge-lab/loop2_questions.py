"""Build 08 knowledge loop 2: the 20 questions of BUILD-08-LOOP-2-SELECTION.md §7. Expected answers are computed from the SOURCE FILES
(grammars over the captures, never from the database) before each query; the question is then answered through the schema as
app_reader (api views / functions) and the verdict, schema calls and delta go to QUERY-LEDGER.jsonl (rows tagged loop 2).

Run: python -I -X utf8 scripts/knowledge-lab/loop2_questions.py [question numbers]
"""
import os, sys, json, re, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lab_common import *  # noqa
import loop1_parse as P
import loop2_parse as G
import loop2_parse_shapes as S
from loop2_acquire import SOURCES2, RUN2, MANIFEST
import loop1_questions as Q1

LEDGER = Q1.LEDGER
BY_KEY = {m["key"]: m for m in MANIFEST}
RESULTS = []
PASS = int(os.environ.get("LOOP2_QUESTION_PASS", "2"))


def src(name, mode="r"):
    p = os.path.join(SOURCES2, name)
    return open(p, "rb").read() if mode == "rb" else open(p, encoding="utf-8", errors="replace").read()


def md_units(name, kind):
    text = src(name)
    if name.endswith(".html"):
        text = P.html_to_text(text)
    return P.universal_markdown(text, kind) + (text,)


def reader(statement):
    return Q1.reader(statement)


def record(n, question, level, expected, answer, verdict, delta, statements, note=""):
    row = {"loop": 2, "pass": PASS, "question": n, "text": question, "level": level, "expected": expected, "answer": answer, "verdict": verdict, "delta": delta, "schema_calls": Q1.schema_calls(statements), "schema_call_count": len(Q1.schema_calls(statements)), "path": statements, "note": note, "asked_at": now_iso()}
    RESULTS.append(row)
    append_jsonl(LEDGER, row)
    log(f"Q{n}: {verdict} ({len(Q1.schema_calls(statements))} schema calls) {note[:140]}")


def norm(s):
    return re.sub(r"[^a-z0-9]+", "", (s or "").lower())


def same_name(a, b):
    """order-insensitive token match: 'Claude 4.5 Opus' == 'Claude Opus 4.5' (the resolver canonicalises family-first)."""
    ta = set(re.findall(r"[a-z0-9.]+", (a or "").lower())) - {"claude", "preview"}
    tb = set(re.findall(r"[a-z0-9.]+", (b or "").lower())) - {"claude", "preview"}
    return bool(ta) and (ta <= tb or tb <= ta)


# ------------------------------------------------------------------ expected answers from captures
def exp_board(name, board):
    u, tabs, lines, offs, text = md_units(name, "leaderboard_page")
    return G.grammar_leaderboard(u, tabs, lines, offs, board, {})


def q1():
    rows = exp_board("swebench-board.md", "swe-bench")[:5]
    expected = [{"rank": r["attrs"]["rank"], "subject": r["attrs"]["subject_name"], "harness": r["attrs"].get("harness"), "score": r["attrs"]["score"], "board_date_of_row": r["attrs"].get("run_date")} for r in rows]
    stmts = ["select json_build_object('rank', rank, 'name', display_name, 'score', score, 'unit', unit, 'edition', edition_no, 'published_at', published_at) from api.leaderboard('swe-bench', 5)",
             "select json_build_object('subject', subject, 'harness', harness, 'score', score, 'reported_by', reported_by, 'claim_id', claim_id, 'run_date', run_date) from api.benchmark_scores where benchmark_version = 'SWE-bench Verified' and reported_by = 'organizer' order by score desc limit 8"]
    lb, err = reader(stmts[0])
    sc, err2 = reader(stmts[1])
    misses = []
    for e in expected:
        hit = next((r for r in (lb or []) if r["rank"] == e["rank"]), None)
        if not hit or abs(float(hit["score"]) - e["score"]) > 0.01 or not same_name(e["subject"], hit["name"]):
            misses.append((e["rank"], e["subject"], hit and hit["name"]))
        h = next((r for r in (sc or []) if same_name(e["subject"], r["subject"]) and abs(float(r["score"]) - e["score"]) < 0.01 and norm(r.get("harness")) == norm(e["harness"])), None)
        if not h or not h.get("claim_id"):
            misses.append((e["rank"], "no conditioned score with locator/harness", h and (h.get("harness"), h.get("claim_id"))))
    verdict = "answered" if not misses else ("partial" if len(misses) < 2 * len(expected) else "missing structure")
    record(1, "Top 5 on the organizer-run SWE-bench Verified board at capture, with harness and locator", "L1/T2", expected, {"leaderboard": lb, "scores": sc, "misses": misses, "error": err or err2}, verdict, None if not misses else "D-22: leaderboard entries vs conditioned scores disagree", stmts,
           f"board rows={len(lb or [])}; misses={misses[:3]}; board newest row date on page = {max((r['attrs'].get('run_date') or '') for r in exp_board('swebench-board.md', 'swe-bench'))}")


def q2():
    model = "Opus 5.5"
    tb = [r for r in exp_board("tbench-board.md", "terminal-bench") if norm(model) in norm(r["attrs"]["subject_name"])]
    u, tabs, lines, offs, text = md_units("anthropic-opus-5-5.html", "official_blog_post")
    ev = [r for r in G.grammar_eval_tables(u, tabs, lines, offs, {}) if norm(model) == norm(r["attrs"]["model"])]
    expected = {"organizer": [(r["attrs"]["benchmark_version"], r["attrs"]["harness"], r["attrs"]["score"]) for r in tb], "self_reported": sorted((r["attrs"]["benchmark"], r["attrs"]["score"]) for r in ev)}
    stmts = [f"select json_build_object('benchmark', benchmark_version, 'harness', harness, 'score', score, 'reported_by', reported_by, 'source_note', conditions->>'source_note', 'claim_id', claim_id) from api.benchmark_scores where subject ilike '%Opus 5.5%' order by reported_by, benchmark_version"]
    rows, err = reader(stmts[0])
    by = collections.defaultdict(list)
    for r in rows or []:
        by[r["reported_by"]].append((r["benchmark"], r["score"]))
    ok_org = all(any(norm(b) == norm(rb) and abs(float(s) - sc) < 0.01 for rb, s in by.get("organizer", [])) for b, h, sc in expected["organizer"])
    got_self = {(norm(b), round(float(s), 2)) for b, s in by.get("self_reported", [])}
    miss_self = [(b, s) for b, s in expected["self_reported"] if (norm(b), round(s, 2)) not in got_self]
    verdict = "answered" if ok_org and not miss_self else ("partial" if rows else "missing structure")
    record(2, "All scores for Claude Opus 5.5, split organizer-run vs self-reported (announcement table)", "L1/T2", expected, {"by_reporter": {k: len(v) for k, v in by.items()}, "rows": rows, "miss_self": miss_self, "error": err}, verdict, None if verdict == "answered" else "D-23: self-reported eval rows did not all resolve to the same model version as the organizer rows", stmts,
           f"organizer={len(by.get('organizer', []))} self_reported={len(by.get('self_reported', []))} missing self={miss_self[:3]}")


def q3():
    expected = {"note": "two editions of the Terminal-Bench board (capture 1 and the refresh capture); diff computed from the two capture files"}
    files = sorted(f for f in os.listdir(SOURCES2) if f.startswith("tbench-board") and f.endswith(".md"))
    stmts = ["select json_build_object('change', change, 'subject', subject_label, 'rank_a', rank_a, 'rank_b', rank_b, 'score_a', score_a, 'score_b', score_b, 'edition_a', edition_a, 'edition_b', edition_b, 'observed_a', observed_a, 'observed_b', observed_b) from api.leaderboard_diff('terminal-bench')",
             "select json_build_object('kind', change_kind, 'learned_at', learned_at, 'logical_key', logical_key, 'document', document_title) from api.changes_since('2026-11-09T20:00:00Z', null, null, array['leaderboard_page'])"]
    rows, err = reader(stmts[0])
    ch, err2 = reader(stmts[1])
    editions = {r["edition_b"] for r in rows or []} | {r["edition_a"] for r in rows or []}
    counts = collections.Counter(r["change"] for r in rows or [])
    rc, _ = reader("select json_build_object('document', d.canonical_title, 'outcome', c.outcome) from content.refresh_check c join content.document d on d.id = c.document_id where d.attributes->>'key' = 'tbench-board'")
    expected["refresh_check"] = rc
    two = len([e for e in editions if e is not None]) >= 2
    unchanged = bool(rc) and all(c["outcome"] == "unchanged" for c in rc)
    verdict = "answered" if (two or (unchanged and rows is not None)) else ("partial" if rows is not None else "missing structure")
    record(3, "What changed on the Terminal-Bench board between capture 1 and capture 2 (entered / left / moved), both clocks", "L2/T2", expected, {"diff_counts": dict(counts), "sample": (rows or [])[:5], "unit_changes": len(ch or []), "refresh_checks": rc, "error": err or err2}, verdict,
           None if two else "second capture happened within the same session; the refresh check records the outcome (unchanged = one edition only)", stmts, f"editions={sorted(e for e in editions if e is not None)} counts={dict(counts)} refresh={rc}")


def q4():
    u, tabs, lines, offs, text = md_units("aa-methodology.html", "official_docs_page")
    defs = S.grammar_metric_definitions(tabs, lines, offs, {})
    fc = next((d for d in defs if d["attrs"]["name"].lower().startswith("frontiercode")), None)
    expected = {"terminal-bench": {"organizer": "Harbor / Laude Institute", "versions_seen_in_sources": ["4.1 (tbench.ai)", "4.0 (Anthropic announcement, Artificial Analysis index)"], "score_type": "accuracy (resolution rate)"}, "frontiercode_definition_from_AA": fc and fc["attrs"]}
    stmts = ["select json_build_object('benchmark', benchmark, 'organizer', organizer, 'metric', metric, 'score_type', score_type, 'versions', versions, 'score_count', score_count, 'reported_by_kinds', reported_by_kinds) from api.benchmarks where slug in ('terminal-bench','frontiercode','swe-bench','osworld','undobench') order by benchmark",
             "select json_build_object('name', attributes->>'name', 'formula', attributes->>'formula', 'scale', attributes->>'scale', 'version', attributes->>'version') from api.document_units((select document_id from api.endpoints limit 0) , null) limit 0"]
    rows, err = reader(stmts[0])
    doc = one(f"select id from content.document where attributes->>'key'='aa-methodology' and tenant_id={q(TENANT)}")
    stmts[1] = f"select json_build_object('name', attributes->>'name', 'formula', attributes->>'formula', 'scale', attributes->>'scale', 'version', attributes->>'version') from api.document_units({q(doc)}, array['metric_definition'])"
    defs_db, err2 = reader(stmts[1])
    tb = next((r for r in rows or [] if r["benchmark"].lower().startswith("terminal")), None)
    ok_ = tb and tb.get("organizer") and len(tb.get("versions") or []) >= 2 and any("4.1" in v for v in tb["versions"]) and any(d["name"].lower().startswith("frontiercode") for d in defs_db or [])
    record(4, "What does Terminal-Bench measure, who runs it, which versions do we hold; what does the AA methodology say FrontierCode scores", "L1→L3/T2", expected, {"benchmarks": rows, "metric_definitions": defs_db, "error": err or err2}, "answered" if ok_ else ("partial" if rows else "missing structure"),
           None if ok_ else "D-24: benchmark versions or metric definitions missing", stmts, f"terminal-bench versions={tb and tb.get('versions')} definitions={len(defs_db or [])}")


def q5():
    pages = G.pdf_text(src("paper-undobench.pdf", "rb"))
    units, text = G.grammar_paper_pdf(pages, "P1", {})
    absn = next(u for u in units if u["attrs"].get("section_role") == "abstract")
    kr = [(k["value"], k["unit"]) for k in G.key_results(absn["text"]) if k["unit"] == "percent"]
    expected = {"abstract_percentages": kr, "named": {"nominal_task_competence": 83.54, "conditional_recovery_success_rate": 46.72, "duplicate_external_effects_under_naive_retry": 53.33}}
    stmts = ["select json_build_object('subject', subject, 'subject_kind', subject_kind, 'benchmark', benchmark_version, 'score', score, 'setting', setting, 'reported_by', reported_by, 'n_tasks', conditions->>'n_tasks', 'claim_id', claim_id) from api.benchmark_scores where benchmark ilike 'UndoBench%' order by score desc",
             "select json_build_object('paper', title, 'level', ingestion_level, 'repositories', repositories, 'talks_about', talks_about) from api.papers where arxiv_id = '2610.05622'"]
    rows, err = reader(stmts[0])
    paper, err2 = reader(stmts[1])
    got = {r["setting"]: float(r["score"]) for r in rows or []}
    misses = [(k, v) for k, v in expected["named"].items() if abs(got.get(k, -1) - v) > 0.01]
    ok_ = not misses and all(r["subject_kind"] == "paper" and r["claim_id"] for r in rows or [])
    record(5, "Paper-reported UndoBench results as conditioned scores (metric, n, who measured)", "L1/T2", expected, {"scores": rows, "paper": paper, "misses": misses, "error": err or err2}, "answered" if ok_ else ("partial" if rows else "missing structure"),
           "D-21 applied in-loop: benchmark_score accepts a paper as subject for aggregate results of the paper's own system" if ok_ else "D-21 incomplete", stmts, f"scores={len(rows or [])} misses={misses}")


def exp_h100_prices():
    out = []
    for key, fn in (("lambda-pricing", lambda: G.grammar_compute_pricing(*md_units("lambda-pricing.html", "pricing_page")[:4], "lambda", {})), ("runpod-pricing", lambda: S.grammar_runpod_sentences(P.html_to_text(src("runpod-pricing.html")), {})),
                    ("coreweave-pricing", lambda: S.grammar_coreweave_html(src("coreweave-pricing.html"), {})), ("modal-pricing", lambda: S.grammar_modal_text(P.html_to_text(src("modal-pricing.html")), {})), ("azure-nd-h100", lambda: G.grammar_azure_prices(json.loads(src("azure-nd-h100.json")), {}))):
        for r in fn():
            a = r["attrs"]
            if a.get("device", "").upper() != "H100" and "H100" not in a.get("offering", "").upper():
                continue
            if a.get("commitment") != "on_demand" or a.get("meter") not in ("gpu_hour", "node_hour", "instance_hour"):
                continue
            per = a["amount"] / (a.get("gpu_count") or 1) if a.get("per") in ("node", "instance") else a["amount"]
            if key == "azure-nd-h100" and (a.get("tier") == "windows" or (a.get("region") or "") not in ("eastus", "westus3", "eastus2", "westus", "southcentralus", "westeurope", "northeurope")):
                continue
            out.append((key, a["offering"], round(per, 4), a.get("region")))
    return sorted(out, key=lambda x: x[2])


def q6():
    exp = exp_h100_prices()
    expected = {"cheapest_on_demand_usd_per_gpu_hour": exp[:5], "note": "per-node prices divided by the node's GPU count; Azure limited to US/EU regions, Linux meters"}
    stmts = ["select json_build_object('offering', offering, 'provider', provider, 'class', offering_class, 'region', region, 'commitment', commitment, 'amount', amount, 'unit', unit, 'usd_per_gpu_hour', usd_per_gpu_hour, 'gpu_count', gpu_count, 'claim_id', claim_id, 'locators', locator_count) from api.cheapest_compute('nvidia-h100', 'on_demand') limit 12"]
    rows, err = reader(stmts[0])
    got = [(r["offering"], round(float(r["usd_per_gpu_hour"]), 4)) for r in rows or [] if r.get("usd_per_gpu_hour") is not None]
    ok_ = got and exp and abs(got[0][1] - exp[0][2]) < 0.01 and all(r.get("claim_id") for r in rows or [])
    record(6, "Cheapest on-demand H100 price per GPU-hour across the captured providers, with locator", "L1/T2", expected, {"rows": rows, "error": err}, "answered" if ok_ else ("partial" if rows else "missing structure"), None if ok_ else "D-25: cheapest_compute normalisation differs from the source computation", stmts,
           f"db cheapest={got[:3]} expected={exp[:3]}")


def q7():
    exp = {}
    for f, dev in (("nvidia-h100.html", "h100"), ("nvidia-h200.html", "h200"), ("nvidia-gb200-nvl72.html", "gb200-nvl72")):
        u, tabs, lines, offs, text = md_units(f, "product_page")
        for r in G.grammar_spec_page(u, tabs, lines, offs, dev, {}):
            if r["attrs"]["field"] in ("memory_gb", "memory_bandwidth_tbps") and re.search(r"SXM|NVL72", r["attrs"]["variant"]):
                exp.setdefault(dev, {})[r["attrs"]["field"]] = r["attrs"]["value"]
    expected = exp
    stmts = ["select json_build_object('device', device, 'slug', slug, 'memory_gb', memory_gb, 'bandwidth_tbps', memory_bandwidth_tbps, 'fp8_tflops', fp8_tflops, 'fp4_pflops', fp4_pflops, 'sparse', sparse_figures, 'released_on', released_on, 'manufacturers', manufacturers, 'offerings', offering_count) from api.compute_devices where slug in ('nvidia-h100','nvidia-h200','nvidia-gb200') order by slug"]
    rows, err = reader(stmts[0])
    got = {r["slug"]: r for r in rows or []}
    misses = []
    for dev, e in exp.items():
        slug = "nvidia-" + dev.split("-")[0]
        r = got.get(slug)
        if not r:
            misses.append((dev, "missing"))
            continue
        for f in e:
            key = {"memory_gb": "memory_gb", "memory_bandwidth_tbps": "bandwidth_tbps"}[f]
            if r.get(key) is None or abs(float(r[key]) - float(e[f])) > 0.01:
                misses.append((dev, f, e[f], r.get(key)))
    ok_ = not misses and all(r.get("manufacturers") for r in rows or [])
    record(7, "Spec comparison H100 / H200 / GB200 NVL72 from first-party pages (memory, bandwidth, sparse-flagged compute)", "L1/T2", expected, {"rows": rows, "misses": misses, "error": err}, "answered" if ok_ else ("partial" if rows else "missing structure"), None if ok_ else "D-26: spec attributes not carried to the device entity", stmts, f"devices={list(got)} misses={misses[:3]}")


def q8():
    def hourly(vcpu_s, gib_s):
        return round((2 * vcpu_s + 4 * gib_s) * 3600, 4)
    e2b = {r["attrs"]["meter"]: r["attrs"]["amount"] for r in S.grammar_e2b_tables(*md_units("e2b-pricing.html", "pricing_page")[1:4], {})}
    modal_text = P.html_to_text(src("modal-pricing.html"))
    u, tabs, lines, offs = P.universal_markdown(modal_text, "pricing_page")
    modal = {r["attrs"]["meter"]: r["attrs"]["amount"] for r in G.grammar_compute_pricing(u, tabs, lines, offs, "modal", {}) if r["kind"] == "price_row"}
    vt = src("vercel-sandbox-pricing.md")
    u, tabs, lines, offs = P.universal_markdown(vt, "pricing_page")
    vercel = {r["attrs"]["meter"]: r["attrs"]["amount"] for r in S.grammar_sandbox_table(tabs, lines, offs, "vercel", {})}
    expected = {"e2b_2vcpu_4gib_usd_per_hour": hourly(e2b.get("vcpu_second", 0), e2b.get("gib_second", 0)), "modal_sandbox_usd_per_hour_assuming_1_core_per_vcpu": hourly(modal.get("vcpu_second", 0), modal.get("gib_second", 0)), "vercel_usd_per_hour_active": round(2 * vercel.get("vcpu_hour", 0) + 4 * vercel.get("gib_hour", 0), 4),
                "sessions_over_1h": {"e2b": "Pro 24 h (Hobby 1 h)", "vercel": "Pro 24 h (Hobby 45 min); persistent sandboxes unbounded", "modal": "no maximum stated on the pricing page"}}
    stmts = ["select json_build_object('offering', offering, 'provider', provider_slug, 'meter', meter, 'amount', amount, 'unit', unit, 'commitment', commitment, 'claim_id', claim_id) from api.compute_offerings where offering_class = 'sandbox' order by offering, meter",
             "select json_build_object('offering', o.offering, 'limit', f.payload->>'limit_name', 'plan', f.payload->>'plan', 'amount', f.amount, 'unit', f.unit) from (select distinct offering_id, offering from api.compute_offerings where offering_class = 'sandbox') o, api.fact_locators(o.offering_id, 'offering_limit') f"]
    rows, err = reader(stmts[0])
    lims, err2 = reader(stmts[1])
    prices = collections.defaultdict(dict)
    for r in rows or []:
        prices[r["provider"] and r["provider"][0] if isinstance(r["provider"], list) else r["offering"]][r["meter"]] = float(r["amount"]) if r["amount"] is not None else None
    def db_hourly(p):
        d = next((v for k, v in prices.items() if p in (k or "").lower()), {})
        if "vcpu_hour" in d:
            return round(2 * d["vcpu_hour"] + 4 * d.get("gib_hour", 0), 4)
        if "vcpu_second" in d:
            return hourly(d["vcpu_second"], d.get("gib_second", 0))
        return None
    got = {"e2b": db_hourly("e2b"), "modal": db_hourly("modal"), "vercel": db_hourly("vercel")}
    ok_ = abs((got["e2b"] or -1) - expected["e2b_2vcpu_4gib_usd_per_hour"]) < 0.001 and abs((got["vercel"] or -1) - expected["vercel_usd_per_hour_active"]) < 0.001 and any((l.get("limit") == "max_session_hours") for l in lims or [])
    record(8, "Sandbox products allowing sessions over 1 h, and the price of a 2 vCPU / 4 GiB sandbox-hour", "L1/T2", expected, {"hourly_from_db": got, "price_rows": len(rows or []), "limits": lims, "error": err or err2}, "answered" if ok_ else ("partial" if rows else "missing structure"),
           None if ok_ else "D-27: sandbox limits or unit prices missing in the offering views", stmts, f"db hourly={got} limits={len(lims or [])}")


def q9():
    stmts = ["select json_build_object('subject', subject, 'kind', change_kind, 'learned_at', learned_at, 'world_from', world_from, 'old', old_value->'amount', 'new', new_value->'amount', 'scope', scope_key) from api.changes_since('2026-11-09T20:00:00Z', array['offering_price'])",
             "select json_build_object('document', d.canonical_title, 'outcome', c.outcome, 'checked_at', c.checked_at) from content.refresh_check c join content.document d on d.id = c.document_id where d.document_type_code = 'pricing_page' and c.checked_at > '2026-11-09T20:00:00Z'"]
    rows, err = reader(stmts[0])
    checks, err2 = reader(stmts[1])
    replaced = [r for r in rows or [] if r["kind"] == "replaced"]
    expected = {"note": "Lambda's page states its new prices take effect 2026-11-16; before that date the refresh must record unchanged, and no price fact may be replaced", "refresh_checks": checks}
    ok_ = checks is not None and all(c["outcome"] in ("unchanged", "changed", "failed") for c in checks or []) and (not replaced or all(r.get("learned_at") for r in replaced))
    record(9, "Compute prices that changed since capture 1 (both clocks); unchanged pages not reported", "L2/T2", expected, {"replaced_facts": len(replaced), "opened_facts": len([r for r in rows or [] if r["kind"] == "opened"]), "sample": replaced[:5], "refresh_checks": checks, "error": err or err2}, "answered" if ok_ and checks else ("partial" if checks is not None else "missing structure"),
           None, stmts, f"replaced={len(replaced)} checks={[(c['document'][:20], c['outcome']) for c in checks or []]}")


def q10():
    a = json.load(open(os.path.join(SOURCES2, "surface-deepagents-deepagents-0.7.1.json"), encoding="utf-8"))
    b = json.load(open(os.path.join(SOURCES2, "surface-deepagents-deepagents-0.7.35.json"), encoding="utf-8"))
    def agg(syms):
        out = {}
        for s_ in syms:
            e = out.setdefault(s_["qualified_name"], {"sigs": set(), "dep": False})
            e["sigs"].add(s_.get("signature") or "")
            e["dep"] = e["dep"] or bool(s_.get("deprecated"))
        return out
    sa, sb = agg(a["symbols"]), agg(b["symbols"])
    added = sorted(set(sb) - set(sa))
    removed = sorted(set(sa) - set(sb))
    resigned = sorted(k for k in set(sa) & set(sb) if sa[k]["sigs"] != sb[k]["sigs"] or sa[k]["dep"] != sb[k]["dep"])
    expected = {"added": len(added), "removed": len(removed), "signature_changed": len(resigned), "sample_added": added[:6], "sample_removed": removed[:6], "caps": {"0.7.1": a["over_cap"], "0.7.35": b["over_cap"]}}
    stmts = ["select json_build_object('change', change, 'name', qualified_name, 'kind', symbol_kind, 'from', signature_from, 'to', signature_to) from api.symbol_changes('langchain-ai/deepagents', 'deepagents==0.7.1', 'deepagents==0.7.35')"]
    rows, err = reader(stmts[0])
    counts = collections.Counter(r["change"] for r in rows or [])
    ok_ = counts.get("added", 0) == len(added) and counts.get("removed", 0) == len(removed) and counts.get("signature_changed", 0) + counts.get("deprecation_changed", 0) == len(resigned)
    record(10, "Public symbols added / removed / re-signed between deepagents 0.7.1 and 0.7.35 (R3)", "L2/T2", expected, {"counts": dict(counts), "sample": (rows or [])[:8], "error": err}, "answered" if ok_ else ("partial" if rows else "missing structure"), None if ok_ else "D-28: symbol diff differs from the surface files", stmts, f"db={dict(counts)} expected add={len(added)} rem={len(removed)} resign={len(resigned)}")


def q11():
    sym = "create_deep_agent"
    docs = []
    for f, kind in (("deepagents-reference-docs.html", "framework_docs_page"), ("deepagents-overview-docs.md", "framework_docs_page"), ("deepagents-readme.md", "repository_readme")):
        u, tabs, lines, offs, text = md_units(f, kind)
        for d in P.grammar_docs(u, kind):
            if re.search(r"(?<![A-Za-z0-9_])" + sym + r"(?![A-Za-z0-9_])", (d["attrs"].get("heading") or "") + " " + d["text"]):
                docs.append((f, d["attrs"].get("heading")))
    expected = {"symbol": sym, "release": "deepagents==0.7.35", "docs_sections_mentioning_it": len(docs), "sample": docs[:6]}
    stmts = [f"select json_build_object('symbol', s.qualified_name, 'kind', s.symbol_kind, 'release', s.release_tag, 'docs_links', s.docs_links) from api.api_symbols s where s.repository = 'langchain-ai/deepagents' and s.release_tag = 'deepagents==0.7.35' and s.qualified_name like '%.{sym}'",
             f"select json_build_object('heading', n.attributes->>'heading', 'document', d.canonical_title, 'kind', n.unit_kind) from api.api_symbols s join content.unit_link l on l.to_node_id = s.node_id and l.kind = 'documents' join content.document_node n on n.id = l.from_node_id join content.document_representation r on r.id = n.representation_id join content.document_version v on v.document_id is not null and v.id = r.document_version_id join content.document d on d.id = v.document_id where s.release_tag = 'deepagents==0.7.35' and s.qualified_name like '%.{sym}' and s.symbol_kind in ('function','class') limit 20"]
    syms, err = reader(stmts[0])
    links, err2 = reader(stmts[1])
    ok_ = syms and links and len(links) >= min(3, len(docs))
    record(11, "Which docs pages explain create_deep_agent for deepagents 0.7.35 (R4 unit links)", "L3/T2", expected, {"symbols": syms, "docs": links, "error": err or err2}, "answered" if ok_ else ("partial" if syms else "missing structure"), None if ok_ else "D-29: docs→symbol links missing", stmts, f"symbols={len(syms or [])} docs links={len(links or [])} expected≈{len(docs)}")


def q12():
    data = json.loads(src("ghsa-langgraph.json"))
    adv = G.grammar_ghsa(data, "langgraph", {})
    def affects(rng, ver="1.2.10"):
        parts = [int(x) for x in ver.split(".")]
        ok = True
        for c in (rng or "").split(","):
            c = c.strip()
            m = re.match(r"(<=|>=|<|>|=)\s*([\d.]+)", c)
            if not m:
                continue
            op, vv = m.group(1), [int(x) for x in m.group(2).split(".")]
            ok = ok and {"<": parts < vv, "<=": parts <= vv, ">": parts > vv, ">=": parts >= vv, "=": parts == vv}[op]
        return ok
    expected = [{"ghsa": a["attrs"]["ghsa_id"], "range": a["attrs"].get("affected_range"), "fixed": a["attrs"].get("fixed_version"), "affects_1.2.10": affects(a["attrs"].get("affected_range"))} for a in adv]
    stmts = ["select json_build_object('ghsa', ghsa_id, 'cve', cve_id, 'severity', severity, 'range', affected_range, 'fixed', fixed_version, 'affects', affects_version, 'claim_id', claim_id) from api.advisories_for('langgraph', '1.2.10')"]
    rows, err = reader(stmts[0])
    got = {r["ghsa"]: r for r in rows or []}
    misses = [e["ghsa"] for e in expected if e["ghsa"] not in got or got[e["ghsa"]]["affects"] != e["affects_1.2.10"]]
    ok_ = not misses and len(got) == len(expected)
    record(12, "Advisories affecting langgraph, and whether version 1.2.10 falls in each range (fixed version)", "L1/T2", expected, {"rows": rows, "misses": misses, "error": err}, "answered" if ok_ else ("partial" if rows else "missing structure"), None if ok_ else "D-30: range evaluation disagrees", stmts, f"advisories={len(got)} misses={misses}")


def q13():
    files = sorted(f for f in os.listdir(SOURCES2) if f.startswith("openai-openapi") and f.endswith(".json"))
    expected = {"captures": files, "note": "second capture compares by commit; identical bytes -> refresh unchanged -> no endpoint changes"}
    stmts = ["select json_build_object('n', count(*), 'families', count(distinct family), 'versions', array_agg(distinct version_label)) from api.endpoints",
             "select json_build_object('kind', change_kind, 'logical_key', logical_key, 'learned_at', learned_at) from api.changes_since('2026-11-09T20:00:00Z', null, null, array['openapi_spec']) limit 20",
             "select json_build_object('document', d.canonical_title, 'outcome', c.outcome) from content.refresh_check c join content.document d on d.id = c.document_id where d.document_type_code = 'openapi_spec'"]
    n, err = reader(stmts[0])
    ch, err2 = reader(stmts[1])
    rc, err3 = reader(stmts[2])
    ok_ = n and int(n[0]["n"]) >= 380 and rc is not None
    record(13, "Endpoints / parameters added to the OpenAI API since capture 1, or 'none, verified'", "L2/T2", expected, {"endpoints": n, "changes": ch, "refresh_checks": rc, "error": err or err2 or err3}, "answered" if ok_ and (rc or ch is not None) else ("partial" if n else "missing structure"), None, stmts, f"endpoints={n and n[0]['n']} changes={len(ch or [])} refresh={rc}")


def q14():
    exp = []
    for f in ("mcp-registry-github.json", "mcp-registry-postgres.json", "mcp-registry-langchain.json"):
        for r in G.grammar_registry(json.loads(src(f)), "mcp-registry", {}):
            if r["attrs"].get("first_party_inferred"):
                exp.append((r["attrs"]["name"], r["attrs"].get("transports")))
    expected = {"first_party_inferred": len(exp), "sample": exp[:8], "rule": "namespace domain appears in the server's website/repository/remote URL and is not a marketplace namespace; the registry's own official flag means validation, not vendor status"}
    stmts = ["select json_build_object('server', server, 'namespace', namespace, 'transports', transports, 'status', current_status, 'registry_status', registry_status, 'version', latest_version) from api.registry_listings where first_party_inferred order by server"]
    rows, err = reader(stmts[0])
    ok_ = rows is not None and len(rows) == len(exp) and all(r.get("status") or r.get("registry_status") for r in rows)
    record(14, "Which MCP servers in the captured registry slice are first-party (namespace rule), and which transport they use", "L1/T2", expected, {"rows": rows, "error": err}, "answered" if ok_ else ("partial" if rows else "missing structure"), None if ok_ else "D-31: registry listings or status stream missing", stmts, f"db={len(rows or [])} expected={len(exp)}")


def q15():
    feature = "server/discover"
    text = src("mcp-changelog-2026-07-28.md")
    expected = {"feature": feature, "introduced_in": "2026-07-28" if feature in text else "unknown", "current_version_per_versioning_page": (re.search(r"current protocol version is\s*\**(\d{4}-\d\d-\d\d)", src("mcp-versioning.md")) or [None, None])[1], "implemented_by": "not derivable from the captured sources (no release note of mcp-python-sdk names the protocol revision)"}
    stmts = ["select json_build_object('version', version_label, 'status', status, 'released_on', released_on, 'implemented_by', implemented_by, 'highlights', highlights) from api.protocol_versions order by version_label desc",
             f"select json_build_object('version', d.attributes->>'protocol_version', 'kind', u.attributes->>'kind', 'text', left(u.inline_text, 160)) from content.document d, api.document_units(d.id, array['change_item']) u where d.document_type_code = 'changelog' and d.attributes->>'protocol_version' is not null and u.inline_text ilike '%{feature}%'"]
    pv, err = reader(stmts[0])
    hits, err2 = reader(stmts[1])
    versions_ = {r["version"] for r in hits or []}
    cur = next((r for r in pv or [] if r["status"] == "current"), None)
    ok_ = "2026-07-28" in versions_ and cur and cur["version"] == "2026-07-28"
    verdict = "answered" if ok_ else ("partial" if pv else "missing structure")
    record(15, "Which MCP protocol version introduced server/discover; which mcp-python-sdk release implements it", "L1/L2/T2", expected, {"protocol_versions": pv, "feature_hits": hits, "error": err or err2}, verdict if not ok_ else "partial",
           "content gap: implements_protocol per SDK release needs the SDK release notes to name the protocol revision (not in the loop-2 sample); the version-introduced half is answered", stmts, f"introduced_in={sorted(versions_)} current={cur and cur['version']} implemented_by={cur and cur.get('implemented_by')}")


def q16():
    a = json.load(open(os.path.join(SOURCES2, "surface-langgraph-1.2.18.json"), encoding="utf-8"))
    b = json.load(open(os.path.join(SOURCES2, "surface-langgraph-1.2.20.json"), encoding="utf-8"))
    removed = sorted(set(s["qualified_name"] for s in a["symbols"]) - set(s["qualified_name"] for s in b["symbols"]))
    expected = {"langgraph_symbols_removed_1.2.18_to_1.2.20": removed[:20], "count": len(removed), "note": "modules bound to LangGraph come from api.modules_using_software; a module is affected only if its code references a removed symbol"}
    stmts = ["select json_build_object('module', work_slug, 'revision', revision_title, 'software', software, 'latest_release', latest_release) from api.modules_using_software((select software_id from api.software where slug = 'langgraph' limit 1))",
             "select json_build_object('change', change, 'name', qualified_name) from api.symbol_changes('langchain-ai/langgraph', '1.2.18', '1.2.20') where change = 'removed'"]
    mods, err = reader(stmts[0])
    rem, err2 = reader(stmts[1])
    affected = []
    for m in mods or []:
        body = one(f"select string_agg(coalesce(vi.search_text, ''), ' ') from retrieval.vector_item vi join authoring.work w on w.id = vi.entity_id where w.slug = {q(m['module'])} and vi.lens = 'ours'") or ""
        for r in rem or []:
            if r["name"].rsplit(".", 1)[-1] in body:
                affected.append((m["module"], r["name"]))
    ok_ = mods is not None and rem is not None and len(rem) == len(removed)
    record(16, "Which of our modules import a symbol removed in a LangGraph release (flywheel)", "L2/T1+T2", expected, {"modules_using_langgraph": mods, "removed": rem, "affected": affected, "error": err or err2}, "answered" if ok_ else ("partial" if mods is not None else "missing structure"),
           None if ok_ else "D-32: symbol removals do not match the surface files", stmts, f"modules={len(mods or [])} removed={len(rem or [])} affected={affected}")


def q17():
    expected = {"talk": "Your Coding Agent Can't Undo Its Own Mistakes", "papers_cited_from_slides": ["2610.05622 UndoBench", "2608.28363 EvoUndo"], "code": "tradertanmay/undobench (UndoBench)"}
    stmts = ["select json_build_object('paper', title, 'arxiv', arxiv_id, 'level', ingestion_level, 'authors', authors, 'repositories', repositories, 'talks_about', talks_about, 'cites_count', cites_count) from api.papers where arxiv_id in ('2610.05622','2608.28363')",
             "select json_build_object('talk', title, 'speakers', speakers) from api.talks where title ilike '%undo%'",
             "select json_build_object('from_kind', f.unit_kind, 'to_kind', g.unit_kind, 'kind', l.kind) from content.unit_link l join content.document_node f on f.id = l.from_node_id join content.document_node g on g.id = l.to_node_id where l.kind = 'cites'"]
    papers, err = reader(stmts[0])
    talk, err2 = reader(stmts[1])
    links, err3 = reader(stmts[2])
    ok_ = papers and len(papers) == 2 and all(p["talks_about"] >= 1 for p in papers) and any(p.get("repositories") for p in papers) and talk and links is not None and len(links) >= 2
    record(17, "Talk → paper → code: from the captured undo talk to UndoBench/EvoUndo and the UndoBench repository (D-09)", "L3→L1/T2", expected, {"papers": papers, "talk": talk, "unit_links": links, "error": err or err2 or err3}, "answered" if ok_ else ("partial" if papers else "missing structure"), "D-09 closed by content (speaker-authored papers linked from slides) and by grammar (slide links become cites)" if ok_ else "D-09 still open", stmts,
           f"papers={len(papers or [])} talks_about={[p['talks_about'] for p in papers or []]} unit_links={len(links or [])}")


def q18():
    expected = {"min_items": 10, "sources": ["OWASP Top 10 for Agentic Applications 2026 (T3)", "Anthropic multiagent research post 2026-08-13 (T2)", "UndoBench abstract (T2)"], "assurance": "asserted (source-backed, not tested)"}
    stmts = ["select json_build_object('kind', kind, 'title', title, 'assurance', assurance_level, 'tier', scope->>'tier', 'source', scope->>'source_document', 'subjects', api.names(subject_entity_ids), 'claim', provenance_claim_id) from api.guidance_items where kind in ('failure_mode','security_consideration','operational_practice') order by kind, title",
             "select to_jsonb(x) from api.search_unified(p_query => 'agent fails to recover after a lost acknowledgment duplicate side effects', p_limit => 8) x"]
    items, err = reader(stmts[0])
    hits, err2 = reader(stmts[1])
    kinds = collections.Counter(i["kind"] for i in items or [])
    ok_ = items and len(items) >= 10 and len(kinds) >= 2 and all(i.get("claim") and i.get("subjects") for i in items)
    record(18, "Known failure modes for sandboxed tool-using agents, with sources and assurance level (D-15; loop-1 Q15 re-run)", "L3/T2+T3", expected, {"items": len(items or []), "by_kind": dict(kinds), "sample": (items or [])[:6], "search_hits": hits, "error": err or err2}, "answered" if ok_ else ("partial" if items else "missing structure"),
           "D-15 closed: first guidance items exist on the L1 path with claim provenance and concept subjects" if ok_ else "D-15 still thin", stmts, f"items={len(items or [])} kinds={dict(kinds)} search_err={err2}")


def q19():
    stats = json.load(open(os.path.join(RUN2, "parse-stats.json"), encoding="utf-8")) if os.path.exists(os.path.join(RUN2, "parse-stats.json")) else {}
    refs = (stats.get("paper-undobench", {}).get("references") or 0) + (stats.get("paper-evoundo", {}).get("references") or 0)
    expected = {"P1": ["UndoBench", "EvoUndo"], "P2": ["Sparks of Weight-Space Programming (owner-selected 2026-11-09)"], "P0_from_references": f"≤ {refs} (arXiv/DOI references resolved from the two P1 papers; duplicates collapse)", "promotion_recorded": True}
    stmts = ["select json_build_object('level', ingestion_level, 'n', count(*), 'titles', array_agg(left(title, 60) order by title) filter (where ingestion_level <> 'P0'), 'promotions', array_agg(promotion) filter (where promotion is not null)) from api.papers group by ingestion_level order by ingestion_level"]
    rows, err = reader(stmts[0])
    by = {r["level"]: r for r in rows or []}
    ok_ = by.get("P1", {}).get("n") == 2 and by.get("P2", {}).get("n") == 1 and by.get("P2", {}).get("promotions") and (by.get("P0", {}).get("n") or 0) >= 10
    record(19, "Which papers are P0 / P1 / P2 and why (promotion audit)", "L1/T1", expected, {"rows": rows, "error": err}, "answered" if ok_ else ("partial" if rows else "missing structure"), None if ok_ else "D-33: ingestion levels not visible per paper", stmts, "levels=" + json.dumps({k: v["n"] for k, v in by.items()}))


def q20():
    u, tabs, lines, offs, text = md_units("weight-space-programming.html", "tech_report")
    ev = [r for r in G.grammar_eval_tables(u, tabs, lines, offs, {}) if re.search(r"MATH|GSM|IFEval", r["attrs"]["benchmark"])]
    expected = {"rows": [(r["attrs"]["benchmark"], r["attrs"]["model"], r["attrs"]["score"]) for r in ev][:12], "headline": "MATH-500 7.9 -> 48.1 after editing 0.016 % of Qwen3.5-0.8B's weights with GPT-6 Astra (50 forward passes)"}
    stmts = ["select json_build_object('subject', subject, 'benchmark', benchmark_version, 'score', score, 'setting', setting, 'reported_by', reported_by, 'claim_id', claim_id) from api.benchmark_scores where benchmark in ('MATH-500','GSM8K','IFEval') or benchmark_version in ('MATH-500','GSM8K','IFEval') order by benchmark_version, score"]
    rows, err = reader(stmts[0])
    got = {(norm(r["benchmark"]), round(float(r["score"]), 1)) for r in rows or []}
    misses = [(b, s) for b, m, s in expected["rows"] if (norm(b), round(s, 1)) not in got]
    ok_ = rows and not misses
    record(20, "Key results of the weight-space post as conditioned score candidates (editor, edited model, benchmark, before/after)", "L1/T3", expected, {"rows": rows, "misses": misses, "error": err}, "answered" if ok_ else ("partial" if rows else "missing structure"), None if ok_ else "D-34: transposed eval table not fully mapped", stmts, f"db rows={len(rows or [])} misses={misses[:4]}")


QUESTIONS = {1: q1, 2: q2, 3: q3, 4: q4, 5: q5, 6: q6, 7: q7, 8: q8, 9: q9, 10: q10, 11: q11, 12: q12, 13: q13, 14: q14, 15: q15, 16: q16, 17: q17, 18: q18, 19: q19, 20: q20}

if __name__ == "__main__":
    wanted = [int(x) for x in sys.argv[1:]] or sorted(QUESTIONS)
    for n in wanted:
        try:
            QUESTIONS[n]()
        except Exception as e:
            record(n, f"question {n}", "-", None, {"exception": repr(e)[:500]}, "error", "harness error", [], repr(e)[:200])
    write_json(os.path.join(RUN2, "questions-summary.json"), [{k: r[k] for k in ("question", "verdict", "schema_call_count", "note")} for r in RESULTS])
