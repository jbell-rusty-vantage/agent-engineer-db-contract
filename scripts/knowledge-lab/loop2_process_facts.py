"""Build 08 knowledge loop 2, stages E-H: facts (benchmark_score, offering_price, offering_limit, events, relationships, status streams),
claim candidates and guidance items, digests (with paper key results), and the unit diff with format-only suppression (§14.7 a).
Imported by loop2_process.py; shares its helpers.
"""
import json, os, re, sys, uuid, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lab_common import *  # noqa
import loop1_process as L1
import loop2_parse as G
import loop2_process as M

nodes_of, role_entity, locator_for, extraction_run_for, make_claim, mapping_id, all_nodes, slugify = M.nodes_of, M.role_entity, M.locator_for, M.extraction_run_for, M.make_claim, M.mapping_id, M.all_nodes, M.slugify
UNIT_OK = {"percent", "score", "elo", "pass_at_1", "seconds", "usd", "count", "tokens_per_second", "samples_per_second", "ms"}


def parse_date(s):
    if not s:
        return None
    s = str(s).strip()
    for fmt in ("%Y-%m-%d", "%b %d, %Y", "%B %d, %Y", "%Y-%m-%dT%H:%M:%S.%fZ", "%Y-%m-%dT%H:%M:%SZ", "%Y-%m-%dT%H:%M:%S%z", "%Y-%m"):
        try:
            import datetime
            return datetime.datetime.strptime(s[:len(s)], fmt).strftime("%Y-%m-%d")
        except Exception:
            continue
    m = re.search(r"(20\d\d-\d\d-\d\d)", s)
    return m.group(1) if m else None


def support(b, stmt_sql, cid, loc, kind="segment"):
    col = "segment_id" if kind == "segment" else "event_occurrence_id"
    b.add(f"""with s as ({stmt_sql}) insert into evidence.segment_support(tenant_id, {col}, claim_id, locator_id, role, k_from) select {q(TENANT)}, s.id, {q(cid)}, {q(loc)}, 'supports', temporal.current_k() from s on conflict do nothing;""")


# ------------------------------------------------------------------ stage E facts
def stage_facts(vs):
    for v in vs:
        label = f"loop2-facts-{v['key']}-{v['label']}" + ("-hourly" if v["kind"] == "pricing_page" and M.BY_KEY.get(v["key"], {}).get("provider") in ("e2b", "modal") else "")
        if one(f"select 1 from temporal.knowledge_batch where summary->>'label' = {q(label)}"):
            continue
        b = Batch(label, {"document": v["key"], "version": v["label"], "loop": 2})
        run_id = extraction_run_for(v)
        rcpt = native_receipt(f"loop2-claims-{v['key']}-{v['label']}", {"document": v["key"]})
        captured = v["captured_at"]
        c = collections.Counter()
        kind = v["kind"]
        src = M.BY_KEY.get(v["key"], {})
        seen_slots = {}
        ambiguous = []

        def slot_ok(subject, scope, value, logical_key):
            """one assertion per (subject, scope) per batch: a second row with the same slot and a different value is kept out and reported (loop-1 rule)."""
            key = (subject, scope)
            if key in seen_slots:
                if seen_slots[key] != value:
                    ambiguous.append({"document": v["key"], "version": v["label"], "logical_key": logical_key, "kept": seen_slots[key], "dropped": value})
                return False
            seen_slots[key] = value
            return True
        # --- benchmark scores: leaderboard rows (organizer / aggregator) and eval rows (self-reported)
        if kind in ("leaderboard_page", "official_blog_post", "tech_report"):
            for n in nodes_of(v, ["leaderboard_row", "eval_row"]):
                a = n["attributes"]
                subj = role_entity(n["id"], "subject") or role_entity(n["id"], "model")
                bench = role_entity(n["id"], "benchmark")
                if not subj or not bench or a.get("score") is None:
                    continue
                unit = a.get("unit") or "score"
                if unit not in UNIT_OK:
                    unit = "score"
                reported = a.get("reported_by") or ("organizer" if n["unit_kind"] == "leaderboard_row" else "self_reported")
                harness = a.get("harness") or ""
                setting = a.get("effort") or a.get("setting") or a.get("scenario") or a.get("tool_mode") or ""
                scope = f"{a.get('benchmark_version') or a.get('benchmark')}|{harness}|{setting}|{reported}"
                if n["unit_kind"] == "leaderboard_row" and v["key"] in ("epoch-benchmarks",):
                    scope += f"|{(a.get('source_label') or '')[:40]}"
                if a.get("model") and v["key"] == "weight-space-programming":
                    scope += f"|{a.get('setting') or ''}"
                when = parse_date(a.get("run_date")) or parse_date(src.get("published_on")) or captured[:10]
                if not slot_ok(subj, scope[:400], a["score"], n["logical_key"]):
                    continue
                loc = locator_for(v, n, "table" if (n["selector"] or {}).get("kind") == "table" else ("dataset" if (n["selector"] or {}).get("kind") == "dataset" else "text_quote"))
                statement = f"{a.get('subject_name') or a.get('model')} scores {a['score']} {unit} on {a.get('benchmark_version') or a.get('benchmark')}" + (f" with {harness}" if harness else "") + (f" ({setting})" if setting else "") + f" as {reported.replace('_', ' ')} by {v['title']} ({when})"
                payload = {k: a.get(k) for k in ("harness", "harness_version", "setting", "effort", "cost_usd", "run_date", "n_tasks", "ci_low", "ci_high", "tool_mode", "scenario", "source_label", "source_note", "benchmark_version", "accelerator", "accelerators_per_node", "model", "notes") if a.get(k) is not None}
                payload.update({"reported_by": reported, "source_kind": "first_party" if reported == "self_reported" else "third_party", "reasoning_effort": a.get("effort"), "step_budget": a.get("step_budget")})
                payload = {k: x for k, x in payload.items() if x is not None}
                mid = mapping_id(n["unit_kind"], kind, "stream", stream="benchmark_score")
                cid = make_claim(rcpt, statement, "measurement", {"subject": subj, "benchmark": bench, "score": a["score"], "unit": unit, **payload, "path": "deterministic_structured_row", "act": 3}, [(subj, "subject"), (bench, "benchmark")], loc, run_id, n, mid)
                support(b, f"select temporal.assert_state({q(subj)}, 'benchmark_score', tstzrange({q(when)}, null, '[)'), {q(scope[:400])}, null, {a['score']}, null, {q(unit)}, {q(bench)}, {q(payload)}, null, {q(cid)}, 'observation_bounded') id", cid, loc)
                c["benchmark_score"] += 1
        # --- compute prices and limits
        if kind == "pricing_page" and src.get("provider"):
            for n in nodes_of(v, ["price_row"]):
                a = n["attributes"]
                off = role_entity(n["id"], "offering")
                if not off or a.get("amount") is None:
                    continue
                a = dict(a)
                if a.get("unit") in ("USD_per_vcpu_second", "USD_per_GiB_second") and a.get("amount") is not None:
                    # D-38: segment.amount is numeric(20,6); a per-second rate such as 0.0000045 would round to 0.000005, so the stated per-second rate is kept in the payload and the fact is the hourly rate
                    a["stated_rate_per_second"] = a["amount"]
                    a["amount"] = round(a["amount"] * 3600, 6)
                    a["unit"] = "USD_per_vcpu_hour" if a["unit"] == "USD_per_vcpu_second" else "USD_per_GB_hour"
                    a["meter"] = a["meter"].replace("_second", "_hour")
                scope = f"{a['meter']}|{a.get('tier') or 'standard'}|{a.get('region') or ''}|{a.get('commitment') or 'on_demand'}"
                when = parse_date(a.get("effective_from")) or captured[:10]
                if not slot_ok(off, scope, a["amount"], n["logical_key"]):
                    continue
                loc = locator_for(v, n, {"table": "table", "json_pointer": "json_pointer", "html": "html"}.get((n["selector"] or {}).get("kind"), "text_quote"))
                statement = f"{a['offering']} {a['meter'].replace('_', ' ')} ({a.get('commitment') or 'on_demand'}{', ' + a['region'] if a.get('region') else ''}{', ' + a['tier'] if a.get('tier') else ''}) costs USD {a['amount']} {a['unit'].replace('USD_', '').replace('_', ' ')} as stated by the provider on {when}"
                payload = {k: a.get(k) for k in ("meter", "tier", "region", "condition", "commitment", "per", "gpu_count", "effective_from", "section", "stated_rate_per_second") if a.get(k) is not None}
                payload["interruptible"] = a.get("commitment") in ("spot", "preemptible")
                payload["source_role"] = "first_party"
                mid = mapping_id("price_row", "pricing_page", "stream", stream="offering_price")
                cid = make_claim(rcpt, statement, "measurement", {"subject": off, **payload, "amount": a["amount"], "currency": "USD", "unit": a["unit"], "path": "deterministic_first_party", "act": 3}, [(off, "subject")], loc, run_id, n, mid)
                extent = f"temporal.make_extent({q('effective from ' + str(a.get('effective_from')) + ' as stated by the provider')}, 'day', {q(loc)})" if a.get("effective_from") else "null"
                support(b, f"select temporal.assert_state({q(off)}, 'offering_price', tstzrange({q(when)}, null, '[)'), {q(scope)}, null, {a['amount']}, 'USD', {q(a['unit'])}, null, {q(payload)}, {extent}, {q(cid)}, {q('explicit' if a.get('effective_from') else 'observation_bounded')}) id", cid, loc)
                c["offering_price"] += 1
            for n in nodes_of(v, ["metadata_field"]):
                a = n["attributes"]
                if a.get("key") not in ("max_session_hours", "max_concurrency"):
                    continue
                off = one(f"select id from catalog.entity where kind='compute_offering' and slug={q(slugify(src['provider'] + ':sandbox'))} and tenant_id={q(TENANT)}")
                if not off:
                    continue
                if not slot_ok(off, a["key"] + "|" + (a.get("plan") or ""), a["value"], n["logical_key"]):
                    continue
                loc = locator_for(v, n, "text_quote")
                unit = "hours" if a["key"] == "max_session_hours" else "count"
                statement = f"{src['provider']} sandbox {a['key'].replace('_', ' ')} = {a['value']} {unit}" + (f" on the {a['plan']} plan" if a.get("plan") else "") + f" (provider page captured {captured[:10]})"
                cid = make_claim(rcpt, statement, "capability", {"subject": off, "limit_name": a["key"], "value": a["value"], "plan": a.get("plan"), "path": "deterministic_first_party"}, [(off, "subject")], loc, run_id, n, None)
                support(b, f"select temporal.assert_state({q(off)}, 'offering_limit', tstzrange({q(captured)}, null, '[)'), {q(a['key'] + '|' + (a.get('plan') or ''))}, null, {a['value']}, null, {q(unit)}, null, {q({k2: v2 for k2, v2 in {'limit_name': a['key'], 'plan': a.get('plan'), 'raw': a.get('raw')}.items() if v2 is not None})}, null, {q(cid)}, 'observation_bounded') id", cid, loc)
                c["offering_limit"] += 1
        # --- spec fields -> claims (attributes were set in the entities stage)
        if kind == "product_page" and src.get("device"):
            for n in nodes_of(v, ["spec_field"]):
                a = n["attributes"]
                dev = role_entity(n["id"], "device")
                if not dev:
                    continue
                loc = locator_for(v, n, "table")
                make_claim(rcpt, f"{a.get('variant')} {a.get('label') or a['field']} = {a.get('raw') or a['value']} (NVIDIA spec page captured {captured[:10]}{'; sparse figure' if a.get('sparse') else ''})", "attribute", {"subject": dev, "field": a["field"], "value": a["value"], "unit": a.get("unit"), "variant": a.get("variant"), "sparse": a.get("sparse"), "path": "deterministic_first_party"}, [(dev, "subject")], loc, run_id, n, mapping_id("spec_field", "product_page", "entity_attribute"))
                c["spec_claims"] += 1
        # --- releases (deepagents) -> release_published events; repo record -> counts/license
        if kind == "github_release":
            mid = mapping_id("release_entry", "github_release", "event", event="release_published")
            for n in nodes_of(v, ["release_entry"]):
                a = n["attributes"]
                rel = role_entity(n["id"], "release")
                if not rel or not a.get("released_on"):
                    continue
                loc = locator_for(v, n, "json_pointer")
                cid = make_claim(rcpt, f"{a.get('title') or a['version']} (deepagents {a['version']}) was published on {a['released_on']}", "event", {"subject": rel, "version": a["version"], "released_on": a["released_on"], "url": a.get("url")}, [(rel, "subject")], loc, run_id, n, mid)
                highlights = [x["text"][:160] for x in sql_json(f"select json_build_object('text', inline_text) from content.document_node where parent_id={q(n['id'])} and unit_kind='change_item' order by ordinal limit 6")]
                sql(f"update catalog.entity set attributes = attributes || {q({'highlights': highlights})} where id={q(rel)}")
                support(b, f"select temporal.assert_event('release_published', {q(rel)}, tstzrange({q(a['released_on'])}, ({q(a['released_on'])})::timestamptz + interval '1 second', '[)'), 'actual', null, null, {q('deepagents==' + a['version'])}, null, {q(cid)}, {q({'version': a['version'], 'breaking': bool(a.get('breaking')), 'url': a.get('url'), 'highlights': highlights, 'prerelease': a.get('prerelease')})}) id", cid, loc, kind="event")
                c["release_published"] += 1
        if kind == "registry_listing_page" and v["key"] == "deepagents-repo-record":
            rep = one(f"select id from catalog.entity where kind='repository' and slug='langchain-ai-deepagents' and tenant_id={q(TENANT)}")
            for n in nodes_of(v, ["metadata_field"]):
                a = n["attributes"]
                sk = {"stargazers_count": "repository_stars", "forks_count": "repository_forks", "open_issues_count": "repository_open_issues"}.get(a.get("key"))
                loc = locator_for(v, n, "json_pointer")
                if a.get("key") == "license_spdx" and rep:
                    cid = make_claim(rcpt, f"deepagents repository license is {a['value']} (GitHub API record {captured[:10]})", "attribute", {"subject": rep, "spdx": a["value"]}, [(rep, "subject")], loc, run_id, n, None)
                    b.add(f"select temporal.assert_state({q(rep)}, 'library_license', tstzrange({q(captured)}, null, '[)'), '', null, null, null, null, null, {q({'license_code': a['value'], 'spdx': a['value']})}, null, {q(cid)}, 'observation_bounded');")
                    c["license"] += 1
                if sk and rep:
                    cid = make_claim(rcpt, f"deepagents repository {a['key']} = {a['value']} on {captured[:10]} (GitHub API)", "measurement", {"subject": rep, "field": a["key"], "value": a["value"]}, [(rep, "subject")], loc, run_id, n, None)
                    b.add(f"select temporal.assert_state({q(rep)}, {q(sk)}, tstzrange({q(captured)}, null, '[)'), '', null, {a['value']}, null, 'count', null, '{{}}'::jsonb, null, {q(cid)}, 'observation_bounded');")
                    c["repo_counts"] += 1
        # --- advisories -> relationship with range + event
        if kind == "security_advisory_page":
            for n in nodes_of(v, ["advisory"]):
                a = n["attributes"]
                adv = role_entity(n["id"], "advisory")
                sw = role_entity(n["id"], "software")
                if not adv:
                    continue
                loc = locator_for(v, n, "json_pointer")
                when = parse_date(a.get("published_at")) or captured[:10]
                cid = make_claim(rcpt, f"{a['ghsa_id']}{' / ' + a['cve_id'] if a.get('cve_id') else ''} ({a.get('severity')}) affects {a.get('package')} {a.get('affected_range') or ''}; first patched {a.get('fixed_version') or 'n/a'}: {a.get('summary')}", "event", {"subject": adv, **{k: a.get(k) for k in ('ghsa_id', 'cve_id', 'severity', 'package', 'affected_range', 'fixed_version', 'published_at')}, "path": "deterministic_registry_record"}, [(adv, "subject")] + ([(sw, "affected")] if sw else []), loc, run_id, n, mapping_id("advisory", "security_advisory_page", "event", event="advisory_published"))
                support(b, f"select temporal.assert_event('advisory_published', {q(adv)}, tstzrange({q(when)}, ({q(when)})::timestamptz + interval '1 second', '[)'), 'actual', null, null, {q(a['ghsa_id'])}, null, {q(cid)}, {q({'ghsa_id': a['ghsa_id'], 'cve_id': a.get('cve_id'), 'severity': a.get('severity'), 'package': a.get('package')})}) id", cid, loc, kind="event")
                if sw:
                    b.add(f"select temporal.assert_relationship('affected_by_advisory', {q(sw)}, {q(adv)}, null, {q(a.get('affected_range') or '')}, 1, {q({'affected_range': a.get('affected_range'), 'fixed_version': a.get('fixed_version'), 'severity': a.get('severity'), 'cve_id': a.get('cve_id')})}, null, {q(cid)});")
                c["advisories"] += 1
        # --- registry listings -> listed_in + status stream on the relationship
        if kind == "registry_listing_page" and src.get("registry"):
            reg = one(f"select id from catalog.entity where kind='registry' and slug='mcp-registry' and tenant_id={q(TENANT)}")
            for n in nodes_of(v, ["registry_listing"]):
                a = n["attributes"]
                srv = role_entity(n["id"], "server")
                if not srv or not reg:
                    continue
                loc = locator_for(v, n, "json_pointer")
                when = parse_date(a.get("published_at")) or captured[:10]
                cid = make_claim(rcpt, f"{a['name']} v{a.get('version')} is listed in the official MCP registry (status {a.get('registry_status')}, transports {', '.join(a.get('transports') or [])}) as of {captured[:10]}", "event", {"subject": srv, "registry": reg, **{k: a.get(k) for k in ('version', 'transports', 'registry_status', 'first_party_inferred', 'namespace')}, "path": "deterministic_registry_record"}, [(srv, "subject"), (reg, "registry")], loc, run_id, n, mapping_id("registry_listing", "registry_listing_page", "relationship", rel="listed_in"))
                b.add(f"""with r as (select temporal.assert_relationship('listed_in', {q(srv)}, {q(reg)}, tstzrange({q(when)}, null, '[)'), '', 1, {q({'version': a.get('version'), 'transports': a.get('transports'), 'first_party_inferred': a.get('first_party_inferred')})}, temporal.make_extent({q('registry publishedAt ' + str(a.get('published_at')))}, 'day', {q(loc)}), {q(cid)}) id)
                          select temporal.assert_state(p_entity => null::uuid, p_stream_kind => 'registry_listing_status', p_valid_during => tstzrange({q(parse_date(a.get('updated_at')) or captured[:10])}, null, '[)'), p_scope_key => '', p_status => {q({'active': 'listed', 'deprecated': 'archived', 'deleted': 'delisted'}.get(a.get('registry_status') or 'active', 'listed'))}, p_payload => {q({'version': a.get('version'), 'registry_status': a.get('registry_status')})}, p_claim => {q(cid)}, p_temporal_basis => 'observation_bounded', p_relationship => r.id) from r;""")
                c["listings"] += 1
        # --- paper-reported aggregate results (D-21): subject = the paper, ref = the benchmark version it defines
        if kind == "arxiv_paper" and v["key"] == "paper-undobench":
            paper = one(f"select entity_id from content.document_about_entity where document_id={q(v['document_id'])} and role='primary' limit 1")
            ubv = one(f"select id from catalog.entity where kind='benchmark_version' and slug='undobench-v1' and tenant_id={q(TENANT)}")
            absn = next((n for n in nodes_of(v, ["paper_section"]) if n["attributes"].get("section_role") == "abstract"), None)
            if paper and ubv and absn:
                loc = locator_for(v, absn, "pdf_text")
                when = parse_date(src.get("published_on")) or captured[:10]
                for kr in G.key_results(absn["text"]):
                    sent = kr["sentence"].lower()
                    setting = "nominal_task_competence" if "nominal competence" in sent and kr["value"] > 80 else ("conditional_recovery_success_rate" if 46 < kr["value"] < 47 else ("duplicate_external_effects_under_naive_retry" if 53 < kr["value"] < 54 else None))
                    if not setting or kr["unit"] != "percent":
                        continue
                    statement = f"UndoBench (Sah et al. 2026) reports {setting.replace('_', ' ')} = {kr['value']}% on 12 held-out test workflows (2,880 paired trials), self-reported in the paper abstract"
                    cid = make_claim(rcpt, statement, "measurement", {"subject": paper, "benchmark": ubv, "score": kr["value"], "unit": "percent", "setting": setting, "reported_by": "self_reported", "path": "deterministic_abstract_metric", "act": 3}, [(paper, "subject"), (ubv, "benchmark")], loc, run_id, absn, None)
                    support(b, f"select temporal.assert_state({q(paper)}, 'benchmark_score', tstzrange({q(when)}, null, '[)'), {q('UndoBench v1|paper system|' + setting + '|self_reported')}, null, {kr['value']}, null, 'percent', {q(ubv)}, {q({'setting': setting, 'reported_by': 'self_reported', 'source_kind': 'first_party', 'n_tasks': 12, 'notes': '2,880 paired trials; two open-weight models, two frameworks, three recovery paradigms'})}, temporal.make_extent({q('paper submitted ' + when + ' (arXiv v1)')}, 'day', {q(loc)}), {q(cid)}, 'explicit') id", cid, loc)
                    c["paper_scores"] += 1
        # --- protocol versions: publication events from the changelog release entry
        if kind == "changelog" and src.get("protocol_version"):
            for n in nodes_of(v, ["release_entry"]):
                a = n["attributes"]
                pv = role_entity(n["id"], "release")
                if not pv or not a.get("released_on"):
                    continue
                loc = locator_for(v, n, "text_quote")
                highlights = [x["text"][:200] for x in sql_json(f"select json_build_object('text', inline_text) from content.document_node where parent_id={q(n['id'])} and unit_kind='change_item' and attributes->>'kind' in ('added','removed','deprecated','breaking') order by ordinal limit 8")]
                sql(f"update catalog.entity set attributes = attributes || {q({'highlights': highlights, 'breaking': bool(a.get('breaking'))})} where id={q(pv)}")
                cid = make_claim(rcpt, f"MCP specification revision {a['version']} was published ({'with breaking changes' if a.get('breaking') else 'no breaking changes stated'}); changelog captured {captured[:10]}", "event", {"subject": pv, "version": a["version"], "released_on": a["released_on"], "highlights": highlights}, [(pv, "subject")], loc, run_id, n, None)
                support(b, f"select temporal.assert_event('protocol_version_published', {q(pv)}, tstzrange({q(a['released_on'])}, ({q(a['released_on'])})::timestamptz + interval '1 second', '[)'), 'actual', null, null, {q('mcp-' + a['version'])}, null, {q(cid)}, {q({'version': a['version'], 'breaking': bool(a.get('breaking')), 'highlights': highlights})}) id", cid, loc, kind="event")
                c["protocol_events"] += 1
        out = b.commit()
        if ambiguous:
            for row in ambiguous:
                append_jsonl(os.path.join(M.RUN2, "ambiguous-slots.jsonl"), row)
        if out or sum(c.values()):
            log(f"facts {v['key']} {v['label']}: {dict(c)} ambiguous={len(ambiguous)} -> {out.splitlines()[-1] if out else 'no batch'}")


# ------------------------------------------------------------------ stage F claim candidates (L1 path): paper key results, change items, provenance notes
def stage_claims(vs):
    rcpt = native_receipt("loop2-claim-candidates", {"stage": "claims", "loop": 2})
    n_c = 0
    for v in vs:
        run_id = extraction_run_for(v)
        src = M.BY_KEY.get(v["key"], {})
        if v["kind"] == "arxiv_paper":
            paper = one(f"select entity_id from content.document_about_entity where document_id={q(v['document_id'])} limit 1")
            absn = next((n for n in nodes_of(v, ["paper_section"]) if n["attributes"].get("section_role") == "abstract"), None)
            if not absn or not paper:
                continue
            loc = locator_for(v, absn, "pdf_text")
            bench = one(f"select id from catalog.entity where kind='benchmark' and slug='undobench' and tenant_id={q(TENANT)}") if "undobench" in v["key"] else None
            for kr in G.key_results(absn["text"])[:12]:
                statement = f"{src.get('title', 'The paper')} reports: {kr['sentence'][:300]} [{kr['value']} {kr['unit']}]"
                make_claim(rcpt, statement, "measurement", {"subject": paper, "benchmark": bench, "value": kr["value"], "unit": kr["unit"], "path": "L1_candidate", "source_role": "academic", "act": 3, "reported_by": "self_reported", "note": "paper-reported aggregate; the measured system is the paper's own agent configuration, not a catalogued model version"}, [(paper, "subject")] + ([(bench, "benchmark")] if bench else []), loc, run_id, absn, None, confidence=0.7)
                n_c += 1
        if v["kind"] == "model_card" and v["key"] == "gemini-4-carbon-eval":
            model = M.model_subject("Gemini 4 Carbon", "Google")[0]
            for n in nodes_of(v, ["section", "paragraph"])[:40]:
                if not re.search(r"self-computed|self-reported|sourced from|public leaderboard|Artificial Analysis|Vals", n["text"] or ""):
                    continue
                loc = locator_for(v, n, "pdf_text")
                make_claim(rcpt, f"Google DeepMind states (Gemini 4 Carbon model evaluation, Oct 2026): {n['text'][:300]}", "recommendation", {"subject": model, "path": "L1_candidate", "source_role": "first_party", "act": 3, "about": "evaluation provenance (who ran which benchmark)"}, [(model, "subject")], loc, run_id, n, None, confidence=0.8)
                n_c += 1
        if v["kind"] == "changelog" and src.get("protocol_version"):
            pv = one(f"select id from catalog.entity where kind='ai_protocol_version' and slug={q('mcp-' + src['protocol_version'])}")
            for n in nodes_of(v, ["change_item"]):
                if n["attributes"].get("kind") not in ("removed", "deprecated", "added", "breaking", "security"):
                    continue
                loc = locator_for(v, n, "text_quote")
                make_claim(rcpt, f"MCP {src['protocol_version']} {n['attributes']['kind']}: {n['text'][:280]}", "event", {"subject": pv, "change_kind": n["attributes"]["kind"], "component": n["attributes"].get("component"), "path": "L1_candidate", "source_role": "first_party", "act": 3}, [(pv, "subject")] if pv else [], loc, run_id, n, None, confidence=0.9)
                n_c += 1
    log(f"claim candidates (loop 2): {n_c}")


# ------------------------------------------------------------------ stage G guidance items (D-15): OWASP ASI items, Anthropic multiagent failures, UndoBench practices
CONCEPT_HINTS = [(r"tool|api|function call", "tool-use"), (r"mcp|protocol", "mcp"), (r"sandbox|code execution|rce", "sandboxes"), (r"memory|context poison|rag", "memory"), (r"idempot|retry|duplicate", "idempotency"), (r"recover|undo|rollback|fault", "recovery"), (r"orchestrat|multi-?agent|coordinat|swarm|delegat", "agent-orchestration"), (r"eval|benchmark", "evals"), (r"security|privilege|identity|supply chain|hijack|rogue|trust", "security"), (r"harness|durable|workflow", "durable-execution")]


def guidance_item(rcpt, kind, title, statement, v, node, subjects, payload, confidence=0.6, run_id=None):
    if one(f"select 1 from guidance.item where tenant_id={q(TENANT)} and title={q(title)} and kind={q(kind)}"):
        return None
    loc = locator_for(v, node, "pdf_text" if v["format"] == "pdf" else "text_quote")
    cid = make_claim(rcpt, f"[{kind}] {title}: {statement[:400]}", "recommendation", {"guidance_kind": kind, "path": "L1_candidate", "source_role": v["role"], "act": 3, **payload}, [(s, "subject") for s in subjects], loc, run_id or extraction_run_for(v), node, mapping_id("docs_section", "framework_docs_page", "claim_candidate") if False else None, confidence=confidence)
    iid = str(uuid.uuid4())
    sql(f"""insert into guidance.item(id, tenant_id, kind, title, statement, scope, assurance_level, provenance_claim_id, created_by_receipt_id, payload, source_node_id)
            values ({q(iid)}, {q(TENANT)}, {q(kind)}, {q(title[:200])}, {q(statement[:2000])}, {q({'applies_to': 'tool-using and multi-agent systems', 'source_document': v['key'], 'tier': 'T2' if v['role'] == 'first_party' else 'T3'})}, 'asserted', {q(cid)}, {q(rcpt)}, {q(payload)}, {q(node['id'])})""")
    for s in subjects:
        sql(f"insert into guidance.item_subject(tenant_id, item_id, entity_id, role) values ({q(TENANT)}, {q(iid)}, {q(s)}, 'concept') on conflict do nothing", allow_error=True)
    return iid


def concepts_for(text, concepts):
    out = []
    for pat, slug in CONCEPT_HINTS:
        if re.search(pat, text, re.I) and slug in concepts:
            out.append(concepts[slug])
    return out[:4] or [concepts.get("agent-orchestration")]


def stage_guidance(vs):
    import loop2_parse_shapes as S
    import fitz
    rcpt = native_receipt("loop2-guidance", {"stage": "guidance", "loop": 2})
    concepts = {r[1]: r[0] for r in sql_rows(f"select id, slug from catalog.entity where kind='concept' and tenant_id={q(TENANT)}")}
    n = 0
    for v in vs:
        if v["key"] == "owasp-agentic-top10":
            raw = open(v["path"], "rb").read()
            text = "\n".join(G.pdf_text(raw))
            cands = S.grammar_owasp(text, {})
            secs = nodes_of(v, ["section", "paragraph"])
            for cnd in cands:
                node = next((s for s in secs if cnd["code"] in (s["attributes"].get("heading") or "") or cnd["code"] in (s["text"] or "")[:120]), secs[0] if secs else None)
                if not node:
                    continue
                if guidance_item(rcpt, "security_consideration", cnd["title"], cnd["statement"], v, node, concepts_for(cnd["title"] + " " + cnd["statement"], concepts) + ([concepts["security"]] if concepts.get("security") else []), {"code": cnd["code"], "framework": "OWASP Top 10 for Agentic Applications 2026", "licence": "CC BY-SA 4.0"}, 0.7):
                    n += 1
        if v["key"] == "anthropic-multiagent":
            text, data, raw = M.load_text2(v)
            units, tabs, lines, offs = __import__("loop1_parse").universal_markdown(text, "official_blog_post")
            cands = G.grammar_guidance_sections(units, text, "anthropic-multiagent", {})
            paras = nodes_of(v, ["paragraph", "post_paragraph", "section"])
            seen = set()
            for cnd in cands:
                key = cnd["statement"][:80]
                if key in seen:
                    continue
                seen.add(key)
                node = next((p for p in paras if cnd["statement"][:50] in (p["text"] or "")), None) or next((p for p in paras if cnd["title"] in (p["attributes"].get("heading") or "")), None)
                if not node:
                    continue
                title = f"Multi-agent failure: {cnd['title']} — {cnd['statement'][:60]}"
                if guidance_item(rcpt, "failure_mode", title, cnd["statement"], v, node, concepts_for(cnd["title"] + " " + cnd["statement"], concepts), {"source": "Anthropic research post 2026-08-13 (Frontier Red Team)", "quantitative": bool(re.search(r"\d", cnd["statement"]))}, 0.7):
                    n += 1
        if v["key"] == "paper-undobench":
            absn = next((x for x in nodes_of(v, ["paper_section"]) if x["attributes"].get("section_role") == "abstract"), None)
            if absn:
                items = [("failure_mode", "Nominal task success hides phase-dependent recovery failures", "Tool-using agents that complete a task nominally often cannot recover when execution is interrupted: UndoBench measures a conditional recovery success rate well below nominal competence, and recovery depends on the phase of failure (before any mutation, during partial mutation, after commit but before acknowledgment)."),
                         ("operational_practice", "Prefer verification and server-side idempotency over naive retry after a lost acknowledgment", "After a commit whose acknowledgment was lost, naive retry duplicates external effects; verification of effect history and server-side idempotency keys substantially improve recovery safety (UndoBench, Sah et al. 2026).")]
                for kind, title, statement in items:
                    if guidance_item(rcpt, kind, title, statement, v, absn, [concepts[s] for s in ("recovery", "idempotency", "durable-execution") if s in concepts], {"source": "UndoBench arXiv:2610.05622 (abstract)", "paper_level": "P1"}, 0.7):
                        n += 1
    log(f"guidance items written: {n}; total guidance.item = {one('select count(*) from guidance.item')}")


# ------------------------------------------------------------------ stage H digests: loop-1 deterministic digest + paper key results and artifacts
def digests_base(vs):
    """loop-1 deterministic digest, reading rows as JSON (statements with tabs/newlines broke the tab-split reader)."""
    n = 0
    for v in vs:
        if one(f"select 1 from content.document_digest where document_version_id={q(v['version_id'])}"):
            continue
        gid = str(uuid.uuid4())
        sql(f"insert into content.document_digest(id, tenant_id, document_version_id, scope, digest_schema_version, producer_identity, producer_kind, lifecycle) values ({q(gid)}, {q(TENANT)}, {q(v['version_id'])}, 'document', 'aieng.digest.v1', 'build08-digest/2 (deterministic)', 'deterministic', 'active')")
        items = []
        for s_ in [x for x in nodes_of(v, ["section", "paper_section"]) if (x["attributes"].get("level") or 9) <= 2][:8]:
            first = (s_["text"].split(chr(10), 1) + [""])[1].strip().split(chr(10))[0][:300]
            items.append(("key_point", f"{s_['attributes'].get('heading')}: {first}" if first else (s_["attributes"].get("heading") or ""), {"heading": s_["attributes"].get("heading")}, [s_["id"]], None, None, None))
        for r in sql_json(f"""select json_build_object('e', r.entity_id, 'name', e.display_name, 'role', r.role, 'n', count(*), 'node', min(r.node_id::text)) from content.unit_entity_role r join content.document_node n on n.id=r.node_id join catalog.entity e on e.id=r.entity_id where n.representation_id={q(v['representation_id'])} group by r.entity_id, e.display_name, r.role order by count(*) desc limit 12"""):
            items.append(("entity_role", f"{r['name']} appears as {r['role']} in {r['n']} units", {"role": r["role"], "units": int(r["n"])}, [r["node"]], r["e"], None, None))
        for r in sql_json(f"""select json_build_object('c', c.id, 's', c.statement, 'node', x.document_node_id) from evidence.claim c join evidence.extraction_record x on x.claim_id=c.id join content.document_node n on n.id=x.document_node_id where n.representation_id={q(v['representation_id'])} order by n.ordinal limit 15"""):
            items.append(("assertion_ref", (r["s"] or "")[:300], {"path": "see claim.structured.path"}, [r["node"]], None, r["c"], None))
        for r in sql_json(f"""select json_build_object('id', id, 'k', change_kind, 'lk', logical_key, 'ch', changed_attributes::text, 'node', coalesce(to_node_id, from_node_id)::text) from content.unit_change where to_version_id={q(v['version_id'])} order by detected_at limit 20"""):
            items.append(("change", f"{r['k']}: {r['lk']} {(r['ch'] or '')[:200]}", {"change_kind": r["k"], "logical_key": r["lk"]}, [r["node"]], None, None, r["id"]))
        for i, (kind, text, payload, nodes, ent, claim, chg) in enumerate(items):
            sql(f"insert into content.digest_item(tenant_id, digest_id, ordinal, item_kind, text, payload, node_ids, entity_id, claim_id, unit_change_id, confidence) values ({q(TENANT)}, {q(gid)}, {i}, {q(kind)}, {q(text)}, {q(payload)}, {qarr([x for x in nodes if x], 'uuid')}, {q(ent)}, {q(claim)}, {q(chg)}, 1.0)")
        n += len(items)
    log(f"digest items written: {n}")


def stage_digests(vs):
    digests_base(vs)
    n = 0
    for v in vs:
        if v["kind"] not in ("arxiv_paper", "tech_report"):
            continue
        gid = one(f"select id from content.document_digest where document_version_id={q(v['version_id'])}")
        if not gid or one(f"select 1 from content.digest_item where digest_id={q(gid)} and item_kind='key_result'"):
            continue
        absn = next((x for x in nodes_of(v, ["paper_section", "section"]) if x["attributes"].get("section_role") == "abstract" or (x["attributes"].get("heading") or "").lower().startswith("tl;dr")), None)
        ordinal = int(one(f"select coalesce(max(ordinal),0)+1 from content.digest_item where digest_id={q(gid)}"))
        src = M.BY_KEY.get(v["key"], {})
        items = []
        if absn:
            for kr in G.key_results(absn["text"])[:8]:
                items.append(("key_result", kr["sentence"][:400], {"value": kr["value"], "unit": kr["unit"]}, [absn["id"]]))
            items.append(("problem", absn["text"].split(". ")[0][:400], {}, [absn["id"]]))
        if src.get("code_url"):
            items.append(("artifact", f"Code / logs: {src['code_url']}", {"url": src["code_url"]}, []))
        items.append(("limitation", f"Ingestion level {src.get('ingestion_level')}: " + ("abstract and conclusion as units plus this digest; full text captured for locators only" if src.get("ingestion_level") == "P1" else "full typed unit tree (owner-selected promotion)"), {"ingestion_level": src.get("ingestion_level"), "promotion": src.get("promotion")}, []))
        for i, (kind, text, payload, nodes) in enumerate(items):
            sql(f"insert into content.digest_item(tenant_id, digest_id, ordinal, item_kind, text, payload, node_ids, confidence) values ({q(TENANT)}, {q(gid)}, {ordinal + i}, {q(kind)}, {q(text)}, {q(payload)}, {qarr(nodes, 'uuid')}, 1.0)")
            n += 1
    log(f"paper digest items added: {n}")


# ------------------------------------------------------------------ stage I diff with format-only suppression (§14.7 a) on the loop-2 kinds
DIFF_KINDS = ["price_row", "section", "spec_field", "release_entry", "leaderboard_row", "eval_row", "endpoint", "parameter", "registry_listing", "advisory", "metadata_field"]


def stage_diff(vs):
    by_doc = collections.defaultdict(list)
    for v in vs:
        by_doc[v["key"]].append(v)
    total = collections.Counter()
    for key, versions_ in by_doc.items():
        if len(versions_) < 2:
            continue
        versions_.sort(key=lambda x: x["captured_at"])
        old, new = versions_[-2], versions_[-1]
        if one(f"select 1 from content.unit_change where to_version_id={q(new['version_id'])} limit 1"):
            continue
        rc = one(f"select id from content.refresh_check where new_version_id={q(new['version_id'])}")
        a = {n["logical_key"]: n for n in nodes_of(old, DIFF_KINDS) if n["logical_key"]}
        b2 = {n["logical_key"]: n for n in nodes_of(new, DIFF_KINDS) if n["logical_key"]}
        fmt_changed = old["format"] != new["format"]
        changes = []
        for lk, n in b2.items():
            if lk not in a:
                changes.append(("added", lk, n["unit_kind"], None, n["id"], {"to": n["attributes"]}))
                continue
            o = a[lk]
            num_fields = ("amount", "score", "value", "rank")
            diffs = {f: {"from": o["attributes"].get(f), "to": n["attributes"].get(f)} for f in num_fields if o["attributes"].get(f) != n["attributes"].get(f) and (f in o["attributes"] or f in n["attributes"])}
            same_text = re.sub(r"\s+", " ", (o["text"] or "")).strip() == re.sub(r"\s+", " ", (n["text"] or "")).strip()
            if diffs:
                changes.append(("attribute_changed", lk, n["unit_kind"], o["id"], n["id"], diffs))
            elif not same_text:
                if fmt_changed and re.sub(r"[^a-z0-9]+", "", (o["text"] or "").lower()) == re.sub(r"[^a-z0-9]+", "", (n["text"] or "").lower()):
                    changes.append(("format_only", lk, n["unit_kind"], o["id"], n["id"], {"format": {"from": old["format"], "to": new["format"]}}))
                else:
                    changes.append(("text_changed", lk, n["unit_kind"], o["id"], n["id"], {"text_sha_from": sha256_text(o["text"] or "")[:12], "text_sha_to": sha256_text(n["text"] or "")[:12]}))
        for lk, o in a.items():
            if lk not in b2:
                changes.append(("removed", lk, o["unit_kind"], o["id"], None, {"from": o["attributes"]}))
        for kind, lk, uk, fn, tn, changed in changes:
            sql(f"insert into content.unit_change(tenant_id, document_id, logical_key, unit_kind, from_version_id, to_version_id, from_node_id, to_node_id, change_kind, changed_attributes, refresh_check_id, update_proposal_state) values ({q(TENANT)}, {q(new['document_id'])}, {q(lk[:500])}, {q(uk)}, {q(old['version_id'])}, {q(new['version_id'])}, {q(fn)}, {q(tn)}, {q(kind)}, {q(changed)}, {q(rc)}, {q('applied' if kind == 'attribute_changed' and uk in ('price_row', 'leaderboard_row') else 'none')})")
        c = collections.Counter(x[0] for x in changes)
        total.update(c)
        log(f"diff {key}: {dict(c)} (units old={len(a)} new={len(b2)}, format {old['format']}->{new['format']})")
    log(f"unit changes (loop 2): {dict(total)}")
