"""Build 08 knowledge loop 3: the 13 questions of BUILD-08-LOOP-3-SELECTION.md §7. Expected answers are computed from the SOURCE FILES
(tarball surfaces parsed outside the database, the talk and docs .md captures, the tree captures) before each query; the question is then
answered through the schema as app_reader and the verdict goes to QUERY-LEDGER.jsonl (rows tagged loop 3).
Questions marked two-way are run summary-first (digest items, then their anchors) and units-first; both paths are recorded with calls,
whether the expected target was reached and at which rank, and the characters returned.

Run: python -I -X utf8 scripts/knowledge-lab/loop3_questions.py [question numbers]
"""
import os, sys, json, re, glob, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lab_common import *  # noqa
import loop1_questions as Q1
from loop3_acquire import SOURCES3, RUN3

LEDGER = Q1.LEDGER
PASS = int(os.environ.get("LOOP3_QUESTION_PASS", "1"))
SOURCES2 = os.path.join(os.path.dirname(SOURCES3), "2026-11-09")
reader = Q1.reader


def record(n, question, level, expected, answer, verdict, delta, statements, note=""):
    row = {"loop": 3, "pass": PASS, "question": n, "text": question, "level": level, "expected": expected, "answer": answer, "verdict": verdict, "delta": delta, "schema_calls": Q1.schema_calls(statements), "schema_call_count": len(statements), "path": statements, "note": note, "asked_at": now_iso()}
    append_jsonl(LEDGER, row)
    log(f"Q{n}: {verdict} ({len(statements)} schema calls) {note[:200]}")


def rows(stmts, statement):
    stmts.append(statement)
    out, err = reader(statement)
    if err:
        raise RuntimeError(err[:600])
    return out


def surface(sw, tag):
    f = glob.glob(os.path.join(SOURCES3, f"surface3-{sw}-{re.sub(r'[^0-9a-zA-Z.]+', '-', tag)}-*.json"))
    return json.load(open(f[0], encoding="utf-8"))


def src_text(key):
    f = sorted(glob.glob(os.path.join(SOURCES3, key + "-*.md")))
    return open(f[0], encoding="utf-8", errors="replace").read()


def search(stmts, query, spaces, limit=8, doc_types=None, unit_kinds=None):
    emb = embed_texts([query])[0]
    arr = lambda v: "null" if not v else qarr(v)
    return rows(stmts, f"""select to_jsonb(x) from (select target_kind, target_id, document_id, unit_kind, content_kind, start_ms, left(snippet, 220) snippet, round(fused_score::numeric, 4) score
      from api.search_unified({q(query)}, {q(vec_literal(emb))}, array['corpus'], null, {arr(spaces)}, {arr(doc_types)}, {arr(unit_kinds)}, null, null, null, null, null, {limit}, 200, 60)) x""")


def chars(x):
    return len(json.dumps(x, ensure_ascii=False))


def ent(stmts, kind, slug):
    return rows(stmts, f"select to_jsonb(x) from (select id from api.entity_rows() where kind={q(kind)} and slug={q(slug)}) x")[0]["id"] if False else one(f"select id from catalog.entity where kind={q(kind)} and slug={q(slug)}")


def talk_id(key):
    return one(f"select api.document_work(d.id) from content.document d where d.attributes->>'key' = {q(key)}")


# ------------------------------------------------------------------ questions
def q1():
    a, b = surface("langchain-legacy", "langchain==0.3.27"), surface("langchain", "langchain==1.0.0")
    an, bn = {s["qualified_name"]: s for s in a["symbols"]}, {s["qualified_name"]: s for s in b["symbols"]}
    exp = {"added": len(set(bn) - set(an)), "removed": len(set(an) - set(bn)), "signature_changed": sum(1 for k in set(an) & set(bn) if (an[k].get("signature") or "") != (bn[k].get("signature") or "")),
           "packages_at_tag_0.3.27": "the tag carries both libs/langchain (released 0.3.27) and libs/langchain_v1 (v1 under development)", "guide": "migration guide states legacy code moved to langchain-classic" if "langchain-classic" in src_text("doc-oss-python-migrate-langchain-v1") or "langchain_classic" in src_text("doc-oss-python-migrate-langchain-v1") else "not stated"}
    st = []
    got = {r["change"]: r["n"] for r in rows(st, "select to_jsonb(x) from (select change, count(*) n from api.symbol_changes('langchain-ai/langchain', 'langchain==0.3.27', 'langchain==1.0.0') group by 1) x")}
    kept = rows(st, "select to_jsonb(x) from (select qualified_name, symbol_kind from api.symbol_changes('langchain-ai/langchain', 'langchain==0.3.27', 'langchain==1.0.0') where change = 'added' and symbol_kind in ('class','function') order by 1 limit 25) x")
    dig = rows(st, "select to_jsonb(x) from (select i.text from api.digest_items i where i.document_title = 'LangChain docs: oss/python/migrate/langchain-v1' and i.scope = 'document' and i.item_kind <> 'entity_role' order by i.ordinal limit 8) x")
    ok = all(got.get(k, 0) == exp[k] for k in ("added", "removed", "signature_changed"))
    record(1, "What changed between the last 0.x LangChain release and v1 (public symbols added/removed/moved, deprecations)?", "L2 / T2", exp, {"symbol_changes": got, "added_sample": [r["qualified_name"] for r in kept], "migration_guide_digest": [r["text"] for r in dig]},
           "answered" if ok and dig else "partial", None if ok else "symbol diff differs from the independent AST diff", st, f"0.3.27 -> 1.0.0: {got}; the migration-guide digest supplies what moved where (langchain-classic) in {len(dig)} anchored items")


def q2():
    surfs = sorted((json.load(open(f, encoding="utf-8")) for f in glob.glob(os.path.join(SOURCES3, "surface3-deepagents-deepagents-*.json"))), key=lambda d: (d.get("released_on") or "", [int(x) for x in re.findall(r"\d+", d["release_tag"])]))
    tags = [d["release_tag"].split("==")[1] for d in surfs]
    first = {}
    for d in surfs:
        for qn, kind in d["all_names"]:
            first.setdefault(qn, d["release_tag"].split("==")[1])
    latest = {qn for qn, _ in surfs[-1]["all_names"]}
    top = {qn: first[qn] for qn in latest if qn.count(".") == 1}
    pypi = json.load(open(glob.glob(os.path.join(SOURCES2, "pypi-deepagents*.json"))[0], encoding="utf-8"))["info"]["requires_dist"]
    exp = {"releases_scanned": len(tags), "top_level_names_in_latest": len(top), "first_release": dict(sorted(top.items())[:12]), "create_deep_agent_since": first.get("deepagents.create_deep_agent"), "requires_dist": [d for d in pypi if "extra" not in d]}
    st = []
    hist = rows(st, "select to_jsonb(x) from (select qualified_name, replace(first_tag, 'deepagents==', '') first_tag, first_released_on, releases_present, releases_total from api.symbol_history('langchain-ai/deepagents', 'deepagents') where in_latest and qualified_name ~ '^deepagents\\.[A-Za-z_]+$' order by 1) x")
    deps = rows(st, """select to_jsonb(x) from (select split_part(t.attributes->>'qualified_name', '.', 1) package, count(*) links, count(distinct t.id) symbols from content.unit_link l join content.document_node s on s.id = l.from_node_id join content.document_node t on t.id = l.to_node_id
                        join api.api_symbols a on a.node_id = s.id where l.kind = 'imports' and a.release_tag = 'deepagents==0.7.35' group by 1 order by 2 desc) x""")
    names = rows(st, """select to_jsonb(x) from (select a.qualified_name, jsonb_agg(distinct t.attributes->>'qualified_name') uses from content.unit_link l join api.api_symbols a on a.node_id = l.from_node_id join content.document_node t on t.id = l.to_node_id
                         where l.kind = 'imports' and a.release_tag = 'deepagents==0.7.35' and a.qualified_name = 'deepagents.graph.create_deep_agent' group by 1) x""")
    rel = rows(st, "select to_jsonb(x) from (select e.display_name library, r.properties->>'constraint' as spec from api.current_relationships r join api.entities f on f.id = r.from_entity_id join api.entities e on e.id = r.to_entity_id where r.kind = 'depends_on' and f.slug = 'deepagents-0-7-35' order by 1) x")
    got_first = {r["qualified_name"]: r["first_tag"] for r in hist}
    ok = got_first == top
    record(2, "Which Deep Agents public APIs exist, in which release did each appear, and what do they depend on in LangGraph/LangChain?", "L2 / T2", exp,
           {"top_level_public_names": len(hist), "first_release_sample": dict(list(got_first.items())[:12]), "imports_by_package": deps, "create_deep_agent_uses": names[0]["uses"] if names else None, "depends_on": rel},
           "answered" if ok and deps else "partial", None if ok else {"mismatch": sorted(set(got_first.items()) ^ set(top.items()))[:10]}, st,
           f"{len(hist)} top-level public names with first release across {exp['releases_scanned']} releases match the independent tag scan: {ok}; imports resolve into {[(d['package'], d['links']) for d in deps]}")


def q3():
    sym = "create_deep_agent"
    exp_pages = sorted({re.search(r"doc-(.+)-[0-9a-f]{12}\.md$", os.path.basename(f)).group(1) for f in glob.glob(os.path.join(SOURCES3, "doc-*.md")) if sym in open(f, encoding="utf-8", errors="replace").read()})
    exp_stale = json.load(open(os.path.join(RUN3, "stale-doc-imports.json"), encoding="utf-8"))
    st_u, st_s = [], []
    units = rows(st_u, f"select to_jsonb(x) from (select d.attributes->>'key' as key, count(*) units, count(*) filter (where s.link_kind = 'documents') documents from api.symbol_docs s join content.document d on d.id = s.document_id where s.qualified_name = 'deepagents.{sym}' and s.release_tag = 'deepagents==0.7.35' group by 1 order by 2 desc) x")
    got_pages = sorted(r["key"][4:] for r in units)
    hits = search(st_s, f"{sym} deep agent creation parameters", ["digests"], 10)
    items = [h for h in hits if h["target_kind"] == "digest_item"]
    pages_s = rows(st_s, f"select to_jsonb(x) from (select distinct d.attributes->>'key' as key from content.document d where d.id = any({qarr([h['document_id'] for h in items if h.get('document_id')], 'uuid')})) x") if items else []
    stale = rows(st_u, """select to_jsonb(x) from (select d.attributes->>'docs_path' docs_path, imp.name as import from content.document_node n join content.document_representation r on r.id = n.representation_id join content.document_version v on v.id = r.document_version_id
                          join content.document d on d.id = v.document_id cross join lateral jsonb_array_elements_text(n.attributes->'imports') imp(name)
                         where n.unit_kind = 'code_example' and d.attributes->>'loop' = '3' and split_part(imp.name, '.', 1) in ('deepagents', 'langchain', 'langchain_core')
                           and not exists (select 1 from api.api_symbols a where a.release_tag in ('deepagents==0.7.35', 'langchain==1.4.10', 'langchain-core==1.7.7') and a.package = split_part(imp.name, '.', 1)
                                            and (a.qualified_name = imp.name or split_part(a.qualified_name, '.', -1) = split_part(imp.name, '.', -1)))) x""")
    got_stale = sorted({(r["docs_path"], r["import"]) for r in stale})
    exp_st = sorted({(r["docs_path"], r["import"]) for r in exp_stale})
    recall_u = len(set(got_pages) & set(exp_pages)) / max(1, len(exp_pages))
    recall_s = len({p["key"][4:] for p in pages_s} & set(exp_pages)) / max(1, len(exp_pages))
    record(3, "Which docs pages explain symbol S (create_deep_agent) for the latest release, and which appear stale against it?", "L3 / T2",
           {"pages_naming_symbol_by_grep": len(exp_pages), "stale_imports_by_independent_resolution": exp_st},
           {"units_first": {"calls": len(st_u), "pages": len(got_pages), "recall_vs_grep": round(recall_u, 2), "top_pages": units[:6], "chars": chars(units)}, "summary_first": {"calls": len(st_s), "digest_items_in_top10": len(items), "pages": [p["key"][4:] for p in pages_s], "recall_vs_grep": round(recall_s, 2), "chars": chars(hits)},
            "appears_stale": got_stale}, "answered" if recall_u >= 0.9 and got_stale == exp_st else "partial", None, st_u + st_s,
           f"units-first (api.symbol_docs, 1 call) reaches {len(got_pages)} of {len(exp_pages)} pages; summary-first reaches {len(pages_s)} pages (only the 22 digested pages can appear); imports that appear stale: {got_stale}")


def q4():
    tk = talk_id("talk-trivedy-data-mining")
    text = src_text("talk-trivedy-data-mining")
    exp_line = next(l for l in text.splitlines() if l.startswith("[3:55]"))
    st_u, st_s = [], []
    seg = rows(st_u, f"select to_jsonb(x) from (select node_id, start_ms, left(text, 400) text, deep_link from api.talk_segments({q(tk)}, 235000, 235000) where unit_kind = 'transcript_segment' and start_ms = 235000) x")
    claims = rows(st_u, f"select to_jsonb(x) from (select statement, assertion_mode, status, consistency, consistency_note, surfaces, deep_link, conflicts from api.claim_surfaces where talk_id = {q(tk)} and start_ms between 230000 and 240000) x")
    ment = rows(st_u, f"select to_jsonb(x) from (select entity, entity_kind, role, method from api.unit_entities({q(seg[0]['node_id'])})) x") if seg else []
    hits = search(st_s, "agents have tools, skills, hooks and middleware and call other agents; hard to predict what a prompt change does", ["digests"], 8, doc_types=["aie_talk"])
    target = [i for i, h in enumerate(hits) if h["document_id"] and h.get("start_ms") is not None and 200000 <= h["start_ms"] <= 281000]
    passages = rows(st_s, f"select to_jsonb(x) from (select start_ms, left(text, 200) text, deep_link from api.digest_item_passages({q(hits[target[0]]['target_id'])})) x") if target else []
    tk2 = talk_id("talk-broekhuizen-next-run")
    c2 = rows(st_u, f"select to_jsonb(x) from (select statement, consistency, consistency_note, surfaces, deep_link from api.claim_surfaces where talk_id = {q(tk2)} and start_ms between 700000 and 710000) x")
    ok = bool(seg) and norm_in(exp_line, seg[0]["text"]) and bool(claims)
    record(4, "What does the speaker state at timecode T, which library surface or docs page does it concern, and do they appear consistent?", "L3 to L1 / T2",
           {"trivedy_3:55_transcript_line": exp_line[:260], "expected_surfaces": "Deep Agents skills / sub-agents and LangChain middleware pages", "broekhuizen_11:44": "Context Hub; expected to appear consistent with the Context Hub docs page"},
           {"units_first": {"calls": len(st_u), "segment": seg[:1], "passage_mentions": ment, "claim_candidates_at_T": claims, "broekhuizen_11:44": c2, "chars": chars(seg) + chars(claims)},
            "summary_first": {"calls": len(st_s), "rank_of_item_in_range": target[0] + 1 if target else None, "top": hits[:3], "passages_behind_item": passages[:3], "chars": chars(hits)}},
           "answered" if ok and c2 else "partial",
           None if claims and any((c.get("surfaces") or []) for c in claims) else "the claim candidate at 3:55 is read 'not addressed' by the docs (no surface link through the claim); the surface is reached through the passage's entity mentions instead",
           st_u + st_s, f"3:55 resolves to its segment and deep link; {len(claims)} claim candidate(s) there, reading {[c['consistency'] for c in claims]}; Broekhuizen 11:44 reading {[c['consistency'] for c in c2]} with {sum(len(c.get('surfaces') or []) for c in c2)} docs surfaces")


def norm_in(line, seg_text):
    body = re.sub(r"^\[[0-9:]+\]\([^)]*\)\s*", "", line)
    return re.sub(r"\s+", " ", body[:120]).strip() in re.sub(r"\s+", " ", seg_text)


def q5():
    st = []
    out = {}
    for slug in ("langchain", "langchain-core", "deepagents", "langgraph"):
        lib = one(f"select id from catalog.entity where kind='library' and slug={q(slug)}")
        out[slug] = len(rows(st, f"select to_jsonb(x) from api.modules_using_software({q(lib)}) x"))
    record(5, "Which of our course modules import a symbol that changed in v1?", "L2 / T1", "none: one module in the lab, bound to LangGraph; none bound to LangChain or Deep Agents", {"modules_using": out}, "answered" if out["langchain"] == 0 and out["langgraph"] >= 1 else "partial",
           "content gap: no authored module binds LangChain v1 or Deep Agents yet, so the symbol-change join has nothing to return", st, f"modules bound per library: {out}")


def q6():
    exp = sorted(re.search(r"doc-oss-python-deepagents-(.+)-[0-9a-f]{12}\.md$", os.path.basename(f)).group(1) for f in glob.glob(os.path.join(SOURCES3, "doc-oss-python-deepagents-*.md")))
    st = []
    pages = rows(st, """select to_jsonb(x) from (select d.attributes->>'docs_path' docs_path, (select count(*) from content.document_version v join content.document_representation r on r.document_version_id = v.id join content.document_node n on n.representation_id = r.id where v.document_id = d.id and n.unit_kind = 'docs_section') sections,
                         exists (select 1 from content.document_digest g join content.document_version v on v.id = g.document_version_id where v.document_id = d.id and g.producer_kind = 'model') as digested
                         from content.document d where d.attributes->>'loop' = '3' and d.attributes->>'docs_path' like 'oss/python/deepagents/%' order by 1) x""")
    lk = rows(st, "select to_jsonb(x) from (select document_title, text from api.digest_items where (payload->>'lesser_known')::boolean order by document_title, ordinal) x")
    lib = one("select id from catalog.entity where kind='library' and slug='deepagents'")
    mods = rows(st, f"select to_jsonb(x) from api.modules_using_software({q(lib)}) x")
    record(6, "What are the lesser-known capabilities (long-tail how-to pages) that no course module mentions yet?", "L3 / T1+T2", {"deepagents_pages_captured": len(exp), "modules_mentioning_deepagents": 0},
           {"pages": len(pages), "not_digested_long_tail": [p["docs_path"].split("/")[-1] for p in pages if not p["digested"]], "lesser_known_items": len(lk), "sample": [f"{r['document_title'].split('/')[-1]}: {r['text'][:140]}" for r in lk[:8]], "modules_using_deepagents": len(mods)},
           "answered" if len(pages) == len(exp) and lk and not mods else "partial", None, st, f"{len(pages)} Deep Agents pages as units, {len(lk)} 'lesser-known' digest items on the digested pages; no module binds Deep Agents, so every page qualifies")


def q7():
    st = []
    cen = rows(st, """select to_jsonb(x) from (select d.attributes->>'key' as key, c.counts->'releases_on_page' on_page, c.counts->'releases_kept' kept, c.counts->'releases_skipped_by_package' skipped, c.counts->'over_cap' over_cap, c.counts->'bundle_bytes' bundle_bytes, c.counts->'bytes_fetched' bytes_fetched
                       from content.structure_census c join content.document_representation r on r.id = c.representation_id join content.document_version v on v.id = r.document_version_id join content.document d on d.id = v.document_id
                       where c.census_version = 'build08-census/3' and (c.counts ? 'releases_on_page' or c.counts ? 'bundle_bytes' or c.counts ? 'over_cap')) x""")
    rel = [c for c in cen if c.get("on_page") is not None]
    caps = [c for c in cen if c.get("bundle_bytes") is not None]
    surf = [c for c in cen if c.get("over_cap") is not None]
    skipped = collections.Counter()
    for c in rel:
        for k, n in (c.get("skipped") or {}).items():
            skipped[k] += n
    res = json.load(open(os.path.join(RUN3, "connection-shapes-resources.json"), encoding="utf-8"))
    emb = rows(st, "select to_jsonb(x) from (select count(distinct a.release_tag) releases, count(*) symbols, count(*) filter (where a.embedded) embedded from api.api_symbols a where a.repository in ('langchain-ai/deepagents', 'langchain-ai/langchain')) x")[0]
    ans = {"releases_of_other_packages_not_unitized": sum(skipped.values()), "packages_skipped": len(skipped), "releases_kept": sum(c["kept"] for c in rel), "surfaces": len(surf), "surfaces_over_cap": sum(1 for c in surf if c["over_cap"]),
           "symbols_rows_only_not_embedded": emb["symbols"] - emb["embedded"], "symbols_embedded": emb["embedded"], "capability_bundle_bytes": sum(c["bundle_bytes"] or 0 for c in caps), "capability_bytes_fetched": sum(c["bytes_fetched"] or 0 for c in caps),
           "talk_resources_not_captured": [r["href"] for r in res if not r["resolved"]]}
    record(7, "What did we decide to leave as reference only, and why?", "L1 / T1", "selection file §4: other monorepo packages, older-release symbols not embedded, capability bytes beyond entry/config files, blog posts linked by the talk, JS lines, langgraph docs",
           ans, "answered", "JS lines, langgraph/integrations docs pages and the LangSmith API reference were never fetched, so the schema holds no row for them: 'rejected before capture' is recorded only in the selection file", st,
           f"census: {ans['releases_of_other_packages_not_unitized']} releases of {ans['packages_skipped']} other packages left out; {ans['symbols_rows_only_not_embedded']} symbols kept as rows only; capability bundles {ans['capability_bundle_bytes']} bytes vs {ans['capability_bytes_fetched']} fetched")


def q8():
    mem = one("select id from catalog.entity where kind='concept' and slug='memory'")
    st_s, st_u = [], []
    summ = rows(st_s, f"select to_jsonb(x) from (select talk, level, entity_role, item_kind, left(text, 160) text, start_ms, deep_link from api.talks_about({q(mem)}) where level in ('document', 'summary')) x")
    pas = rows(st_u, f"select to_jsonb(x) from (select talk, start_ms, left(text, 120) text, deep_link from api.talks_about({q(mem)}) where level = 'passage') x")
    talks_s = sorted({r["talk"] for r in summ})
    by_talk = collections.defaultdict(list)
    for r in pas:
        by_talk[r["talk"]].append(r["start_ms"] // 1000)
    exp = {"The Next Run Should Be Better": "whole talk; chapters at 163 s, 307 s, 375 s, 481 s", "Improving Agents is a Data Mining Problem": "last chapter from 1026 s; memory at about 1080 s"}
    ok_s = set(exp) <= set(talks_s)
    tri = [t for t in by_talk.get("Improving Agents is a Data Mining Problem", []) if t >= 1026]
    bro = by_talk.get("The Next Run Should Be Better", [])
    ok_u = bool(tri) and len(bro) >= 10
    record(8, "Which talks are about concept C (agent memory), and at which timecode does each discuss it?", "L3 / T2", exp,
           {"summary_first": {"calls": len(st_s), "talks": talks_s, "rows": len(summ), "roles": sorted({(r['talk'][:20], r['level'], r['entity_role']) for r in summ if r['entity_role']})[:8], "item_timecodes_s": sorted({r['start_ms'] // 1000 for r in summ if r.get('start_ms') is not None})[:20], "chars": chars(summ)},
            "units_first": {"calls": len(st_u), "passages_per_talk": {k: len(v) for k, v in by_talk.items()}, "trivedy_after_1026s": tri[:8], "broekhuizen_first": sorted(bro)[:10], "chars": chars(pas)}},
           "answered" if ok_s and ok_u else "partial", None, st_s + st_u,
           f"summary level names {len(talks_s)} talks with roles in {len(summ)} rows ({chars(summ)} chars); passage level gives {sum(len(v) for v in by_talk.values())} timecoded mentions ({chars(pas)} chars); the summary level answers 'about', the passage level answers 'where'")


def q9():
    tk = talk_id("talk-broekhuizen-next-run")
    st_s, st_u = [], []
    items = rows(st_s, f"select to_jsonb(x) from (select item_id, ordinal, item_kind, text, anchor_count, start_ms, end_ms, deep_link from api.digest_items where work_id = {q(tk)} and scope = 'document' and item_kind <> 'entity_role' order by ordinal) x")
    pick = next((i for i in items if "procedural" in i["text"].lower()), None)
    pas = rows(st_s, f"select to_jsonb(x) from (select unit_kind, start_ms, left(text, 260) text, deep_link from api.digest_item_passages({q(pick['item_id'])})) x") if pick else []
    hits = search(st_u, "procedural memory: rules, instructions and skills that guide how the agent should behave", ["units"], 6, doc_types=["aie_talk"], unit_kinds=["transcript_segment"])
    in_range = [i for i, h in enumerate(hits) if h.get("start_ms") is not None and 290000 <= h["start_ms"] <= 380000]
    exp_takeaways = [l[2:] for l in src_text("talk-broekhuizen-next-run").split("## Key takeaways")[1].split("##")[0].splitlines() if l.startswith("- ")]
    ok = pick and pas and all(290000 <= p["start_ms"] <= 380000 for p in pas)
    record(9, "Give the summary of talk T (The Next Run Should Be Better), then open the passage behind item N.", "L3 / T2", {"key_takeaways_on_the_page": exp_takeaways, "passage_range_for_procedural_memory": "5:07 to 6:15 (307 s to 375 s)"},
           {"summary_first": {"calls": len(st_s), "items": [f"{i['ordinal']} [{i['item_kind']}] {i['text'][:170]}" for i in items], "picked_item": pick["ordinal"] if pick else None, "passages": pas, "chars": chars(items) + chars(pas)},
            "units_first": {"calls": len(st_u), "rank_of_segment_in_range": in_range[0] + 1 if in_range else None, "top": [(h["start_ms"], h["snippet"][:90]) for h in hits[:3]], "chars": chars(hits)}},
           "answered" if ok else "partial", None, st_s + st_u, f"{len(items)} document-level items; item {pick['ordinal'] if pick else '-'} opens {len(pas)} transcript segments at {[p['start_ms'] // 1000 for p in pas]} s; units-first search finds a segment in the range at rank {in_range[0] + 1 if in_range else None}")


def q10():
    rels = json.load(open(glob.glob(os.path.join(SOURCES2, "deepagents-releases*.json"))[0], encoding="utf-8"))
    body = next(r for r in rels if r["tag_name"] == "deepagents==0.7.35")["body"]
    exp_lines = [l.strip() for l in body.splitlines() if re.match(r"^(\*|-)\s", l.strip())]
    a, b = {n for n, _ in surface("deepagents", "deepagents==0.7.34")["all_names"]}, {n for n, _ in surface("deepagents", "deepagents==0.7.35")["all_names"]}
    exp = {"change_lines_in_release_body": len(exp_lines), "first_lines": exp_lines[:5], "public_symbols_added": sorted(b - a), "public_symbols_removed": sorted(a - b)}
    rel = one("select id from catalog.entity where kind='library_release' and slug='deepagents-0-7-35'")
    st_s, st_u = [], []
    dig = rows(st_s, f"select to_jsonb(x) from (select ordinal, text, jsonb_array_length(coalesce(change_items, '[]')) notes, coalesce(symbols, '[]') symbols from api.release_digest({q(rel)})) x")
    notes = rows(st_u, f"select to_jsonb(x) from (select c.attributes->>'kind' kind, left(c.inline_text, 200) text from content.unit_entity_role r join content.document_node p on p.id = r.node_id and p.unit_kind = 'release_entry' join content.document_node c on c.parent_id = p.id and c.unit_kind = 'change_item' where r.entity_id = {q(rel)} and r.role = 'release' order by c.ordinal) x")
    sym = rows(st_u, "select to_jsonb(x) from (select change, qualified_name from api.symbol_changes('langchain-ai/deepagents', 'deepagents==0.7.34', 'deepagents==0.7.35')) x")
    ok = 1 <= len(dig) <= 5 and all(d["notes"] or d["symbols"] for d in dig) and len(notes) == len(exp_lines) and len(sym) == len(exp["public_symbols_added"]) + len(exp["public_symbols_removed"])
    record(10, "What changed in release R (deepagents 0.7.35), in five items, with the symbols behind each item?", "L2 to L3 / T2", exp,
           {"summary_first": {"calls": len(st_s), "items": [f"{d['ordinal']}: {d['text'][:200]} (notes {d['notes']}, symbols {len(d['symbols'])})" for d in dig], "chars": chars(dig)}, "units_first": {"calls": len(st_u), "change_items": len(notes), "symbol_changes": sym, "chars": chars(notes) + chars(sym)}},
           "answered" if ok else "partial", None if sym else "0.7.34 -> 0.7.35 changed no public symbol, so no item carries a symbol anchor; the items anchor to change notes", st_s + st_u,
           f"{len(dig)} digest items anchored to {sum(d['notes'] for d in dig)} change notes; units-first returns all {len(notes)} notes and {len(sym)} symbol changes")


def q11():
    def tools(tag):
        f = sorted(glob.glob(os.path.join(SOURCES3, f"mcp-github-server-readme-{tag}-*.md")))[0]
        t = open(f, encoding="utf-8").read()
        sec = t.split("\n## Tools\n", 1)[1].split("\n## Read-Only Mode", 1)[0]
        return re.findall(r"^- \*\*([A-Za-z0-9_\-]+)\*\* - ", sec, re.M)
    new, old = tools("v2.1.0"), tools("v1.14.0")
    exp = {"tools_v2.1.0": len(new), "distinct": len(set(new)), "added_vs_v1.14.0": sorted(set(new) - set(old)), "removed_vs_v1.14.0": sorted(set(old) - set(new))}
    st = []
    cnt = rows(st, "select to_jsonb(x) from (select version_label, count(*) n, count(distinct name) names, count(distinct toolset) toolsets from api.mcp_tools where server = 'io.github.github/github-mcp-server' group by 1 order by 1) x")
    sample = rows(st, "select to_jsonb(x) from (select name, toolset, required, scopes from api.mcp_tools where server = 'io.github.github/github-mcp-server' and version_label like 'tag-v2.1.0%' and name in ('create_branch', 'add_issue_comment')) x")
    chg = rows(st, "select to_jsonb(x) from (select c.change_kind, c.logical_key, c.changed_attributes from content.unit_change c join content.document d on d.id = c.document_id where d.attributes->>'key' = 'mcp-github-server-readme' order by 2) x")
    v2 = next((c for c in cnt if c["version_label"].startswith("tag-v2.1.0")), {})
    ok = v2.get("n") == len(new) and not [c for c in chg if c["change_kind"] in ("added", "removed")] == bool(exp["added_vs_v1.14.0"] or exp["removed_vs_v1.14.0"])
    record(11, "Which tools does server S (GitHub MCP server) expose at version V and what changed?", "L1 to L2 / T2", exp, {"per_version": cnt, "sample": sample, "changes_v1.14.0_to_v2.1.0": chg, "custody": "C1, published README manifest; not a live tools/list"},
           "answered" if v2.get("n") == len(new) and v2.get("names") == len(set(new)) else "partial", None, st, f"v2.1.0: {v2.get('n')} tool units ({v2.get('names')} distinct names, {v2.get('toolsets')} toolsets); diff from v1.14.0: {[(c['change_kind'], c['logical_key'].split('|')[-1]) for c in chg]}")


def q12():
    tree = json.load(open(sorted(glob.glob(os.path.join(SOURCES3, "skill-dcode-skill-creator-tree-*.json")))[0], encoding="utf-8"))
    pre = "libs/code/deepagents_code/built_in_skills/skill-creator/"
    exp = sorted((e["path"][len(pre):], e["mode"] == "100755", e.get("size")) for e in tree["tree"] if e["path"].startswith(pre) and e["type"] == "blob")
    st = []
    files = rows(st, "select to_jsonb(x) from (select path, executable, size, file_role, left(git_blob_id, 10) blob, sha256 is not null as bytes_fetched, custody_level, left(commit, 10) commit from api.bundle_files where capability = 'skill-creator' order by path) x")
    cap = rows(st, "select to_jsonb(x) from (select capability, kind, identifiers, custody_level, files, executable_files, compatible_with from api.capabilities where kind = 'agent_skill' order by 1) x")
    got = sorted((f["path"], f["executable"], f["size"]) for f in files)
    record(12, "Which files does skill K (skill-creator) contain and which are executable?", "L1 / T2", {"files": exp}, {"files": files, "skills": cap}, "answered" if got == exp else "partial", None, st,
           f"{len(files)} files, executable: {[f['path'] for f in files if f['executable']]}; bytes held for {[f['path'] for f in files if f['bytes_fetched']]} only (C1); 4 skills listed with identifiers")


def q13():
    readme = json.load(open(sorted(glob.glob(os.path.join(SOURCES3, "plugin-langchain-mcp-[0-9a-f]*.json")))[0], encoding="utf-8"))["files"].get("../README.md", {}).get("text", "")
    exp = {"deep_agents_code": "first-party docs page oss/deepagents/code/plugins", "marketplace_readme_names": [n for n in ("Claude Code", "Codex", "deepagents-code", "dcode") if n.lower() in readme.lower()]}
    st = []
    feat = rows(st, "select to_jsonb(x) from (select p.display_name product, f.display_name feature, f.slug from api.current_relationships r join api.entities p on p.id = r.from_entity_id join api.entities f on f.id = r.to_entity_id where r.kind = 'has_feature' and f.slug like '%-plugins') x")
    comp = rows(st, "select to_jsonb(x) from (select h.display_name harness, count(*) plugins, jsonb_agg(distinct c.display_name) names, jsonb_agg(distinct r.properties->>'stated_by') stated_by from api.current_relationships r join api.entities c on c.id = r.from_entity_id join api.entities h on h.id = r.to_entity_id where r.kind = 'compatible_with' and c.kind = 'agent_plugin' group by 1 order by 1) x")
    caps = rows(st, "select to_jsonb(x) from (select capability, custody_level, files, hooks, bundles, compatible_with, listed_in from api.capabilities where kind = 'agent_plugin' order by 1) x")
    ok = any(f["product"] == "Deep Agents Code" for f in feat) and {c["harness"] for c in comp} >= {"Claude Code", "Codex", "Deep Agents Code"}
    record(13, "Which harnesses support plugins?", "L1 / T2 and T3", exp, {"has_feature_plugins": feat, "plugins_compatible_with": comp, "plugins": caps}, "answered" if ok else "partial",
           "support for Claude Code and Codex is recorded as what the plugin manifests state (compatible_with from the plugin), not as a first-party feature fact of those products: their own docs are not ingested", st,
           f"first-party feature: {[f['product'] for f in feat]}; plugins state compatibility with {[(c['harness'], c['plugins']) for c in comp]}")


QUESTIONS = {1: q1, 2: q2, 3: q3, 4: q4, 5: q5, 6: q6, 7: q7, 8: q8, 9: q9, 10: q10, 11: q11, 12: q12, 13: q13}

if __name__ == "__main__":
    wanted = [int(a) for a in sys.argv[1:]] or sorted(QUESTIONS)
    for n in wanted:
        try:
            QUESTIONS[n]()
        except Exception as e:
            log(f"Q{n}: ERROR {e!r}"[:900])
    write_json(os.path.join(RUN3, f"spend-questions-pass{PASS}.json"), SPEND)
