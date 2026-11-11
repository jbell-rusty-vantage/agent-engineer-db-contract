"""Build 08 knowledge loop 3, deterministic stages for the loop-3 documents:
census -> typed units (talks, docs, releases, API surfaces grammar/3, capability manifests, MCP tool manifest) -> entities and roles
-> links (docs -> symbol, symbol -> symbol imports, talk resource -> document) -> facts (release events, repository counts, depends_on)
-> diff (MCP tool manifest across versions) -> projections -> embeddings.
The model-written digests and the claim candidates are loop3_digests.py (run between `diff` and `projections`).

Run: python -I -X utf8 scripts/knowledge-lab/loop3_process.py [stage ...]   (stages are idempotent)
"""
import json, os, re, sys, uuid, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lab_common as C
from lab_common import *  # noqa
import loop1_parse as P1
import loop1_process as L1
import loop2_parse as G
from loop3_acquire import MANIFEST, SOURCES3, RUN3, SKIP_SURFACE_KEYS, CAPABILITIES, MCP_SERVER

L1.SOURCES_DIR = SOURCES3
L1.RUN_DIR = RUN3
C.RUN_DIR = RUN3
GRAMMAR = "build08-grammar/3"
STATS = collections.defaultdict(dict)
RECEIPT = None
LATEST = {"deepagents": "deepagents==0.7.35", "langchain": "langchain==1.4.10", "langchain_core": "langchain-core==1.7.7", "langgraph": "1.2.20"}
DERIVED_KINDS = ("api_surface", "agent_skill_manifest", "agent_plugin_manifest")
MEDIA = {"markdown": "text/markdown", "html": "text/html", "json": "application/json", "archive": "application/gzip"}


def receipt():
    global RECEIPT
    if RECEIPT is None:
        RECEIPT = native_receipt("loop3-entities", {"stage": "entities", "loop": 3})
    return RECEIPT


L1.receipt = receipt
slugify, ensure_entity, ensure_work, add_role, flush_roles, nodes_of = L1.slugify, L1.ensure_entity, L1.ensure_work, L1.add_role, L1.flush_roles, L1.nodes_of
_index_item = L1.index_item
L1.index_item = lambda space, target_kind, target_id, text, lens, tier, content_kind, **kw: _index_item(space, target_kind, target_id, (text or "")[:2000], lens, tier, content_kind, **kw)
L1.TIER_BY_ROLE.update({"academic": 2, "system": 2})


def set_attrs(eid, attrs):
    """ensure_entity merges attributes only on first sight in a run; this writes them explicitly (keys replaced)."""
    attrs = {k: v for k, v in attrs.items() if v is not None}
    if attrs:
        sql(f"update catalog.entity set attributes = (attributes - {qarr(list(attrs))}) || {q(attrs)}, updated_at = now() where id = {q(eid)}")


def identifier(eid, scheme, value):
    sql(f"insert into catalog.entity_identifier(tenant_id, entity_id, scheme, value) values ({q(TENANT)}, {q(eid)}, {q(scheme)}, {q(value)}) on conflict do nothing")


def about_doc(doc, eid, role="primary", method="provider", confidence=1.0):
    sql(f"insert into content.document_about_entity(tenant_id, document_id, entity_id, role, method, confidence) values ({q(TENANT)}, {q(doc)}, {q(eid)}, {q(role)}, {q(method)}, {confidence}) on conflict do nothing")


# ------------------------------------------------------------------ versions of the loop-3 documents
def versions():
    rows = sql_json(f"""select json_build_object('key', d.attributes->>'key', 'kind', d.document_type_code, 'role', d.source_role_code, 'document_id', d.id, 'version_id', v.id, 'label', v.version_label, 'format', v.format_code, 'sha', v.manifest_sha256,
      'representation_id', r.id, 'rep_sha', r.content_sha256, 'capture_id', vc.source_capture_id, 'captured_at', c.captured_at, 'title', d.canonical_title, 'attrs', d.attributes, 'rep_class', r.representation_class)
      from content.document d join content.document_version v on v.document_id = d.id join content.document_representation r on r.document_version_id = v.id
      join content.document_version_source_capture vc on vc.document_version_id = v.id join evidence.source_capture c on c.id = vc.source_capture_id
      where d.tenant_id = {q(TENANT)} and d.attributes->>'loop' = '3' order by d.attributes->>'key', c.captured_at, v.created_at""")
    files = {}
    for f in os.listdir(SOURCES3):
        p = os.path.join(SOURCES3, f)
        if os.path.isfile(p):
            m = re.search(r"-([0-9a-f]{12})\.[a-z.]+$", f)
            if m:
                files[m.group(1)] = p
    out = []
    for v in rows:
        if v["key"] in SKIP_SURFACE_KEYS:
            continue
        if v["kind"] in DERIVED_KINDS and v["rep_class"] != "structural_extraction":
            continue
        if v["kind"] not in DERIVED_KINDS and v["rep_class"] == "structural_extraction":
            continue
        v["path"] = files.get(v["rep_sha"][:12])
        out.append(v)
    return out


def load(v):
    raw = open(v["path"], "rb").read()
    text = raw.decode("utf-8", "replace")
    data = json.loads(raw) if v["path"].endswith(".json") else None
    return text, data, raw


def stage_census(vs):
    n = 0
    for v in vs:
        if not v.get("path") or one(f"select 1 from content.structure_census where representation_id={q(v['representation_id'])} and census_version='build08-census/3'"):
            continue
        text, data, raw = load(v)
        counts, sigs = P1.census(text[:400000], "json" if data is not None else "markdown")
        counts["bytes"] = len(raw)
        if v["kind"] == "api_surface":
            counts.update({"symbols_total": data.get("symbol_count"), "symbols_kept": len(data.get("symbols") or []), "modules_parsed": data.get("modules_parsed"), "files_skipped": data.get("files_skipped"), "over_cap": data.get("over_cap"), "cap": data.get("cap")})
        if v["kind"] in ("agent_skill_manifest", "agent_plugin_manifest"):
            counts.update({"bundle_files": len(data.get("tree") or []), "files_fetched": len(data.get("files") or {}), "bundle_bytes": data.get("bytes_total"), "bytes_fetched": data.get("bytes_fetched"), "custody_level": data.get("custody_level")})
        if v["kind"] == "github_release":
            pk = collections.Counter((r.get("tag_name") or "").split("==")[0] for r in data)
            counts.update({"releases_on_page": len(data), "releases_kept": sum(1 for r in data if keep_release(r, v["attrs"])), "releases_skipped_by_package": {k: n_ for k, n_ in pk.items() if k not in (v["attrs"].get("release_packages") or [])}})
        sql(f"""insert into content.structure_census(tenant_id, representation_id, census_version, format_code, counts, signatures, language, digest)
                values ({q(TENANT)}, {q(v['representation_id'])}, 'build08-census/3', {q(v['format'])}, {q(counts)}, {q(sigs)}, 'en', {q(sha256_text(json.dumps(counts, sort_keys=True)))})""")
        n += 1
    log(f"census rows written: {n}")


# ------------------------------------------------------------------ grammars (loop 3)
def keep_release(rel, attrs):
    m = re.match(r"^(.*?)==(\d+)\.", rel.get("tag_name") or "")
    return bool(m and m.group(1) in (attrs.get("release_packages") or []) and int(m.group(2)) >= int(attrs.get("release_major") or 0))


IMPORT_RE = re.compile(r"^\s*from\s+((?:langchain|langgraph|deepagents|langsmith)[\w.]*)\s+import\s+\(?([^\n#)]*(?:\n[^\n#)]*?)*?)\)?\s*$", re.M)


def code_imports(code):
    out = []
    for m in re.finditer(r"^\s*from\s+((?:langchain|langgraph|deepagents|langsmith)[\w.]*)\s+import\s+(\([^)]*\)|[^\n]+)", code, re.M):
        for nm in re.split(r"[,\s()]+", m.group(2).split("#")[0]):
            nm = nm.strip()
            if nm and nm != "as" and re.match(r"^[A-Za-z_]\w*$", nm):
                out.append(f"{m.group(1)}.{nm}")
    return sorted(set(out))[:40]


def grammar_surface3(data):
    out = []
    for s in data.get("symbols") or []:
        attrs = {k: v for k, v in s.items() if v not in (None, "", [])}
        text = f"{s['qualified_name']} [{s['kind']}] {s.get('signature') or ''}\n{s.get('docstring_head') or ''}"
        out.append(dict(kind="api_symbol", key=f"sym:{P1.sha(s['qualified_name'])[:12]}", parent=None, attrs=attrs, text=text[:1500], logical=f"api_symbol:{s['qualified_name']}", start=None, end=None,
                        selector={"kind": "repository", "repository": data.get("repository"), "tag": data.get("release_tag"), "path": s.get("path"), "line": s.get("lineno")}))
    return out


def frontmatter(text):
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.S)
    if not m:
        return {}, text
    fm, key = {}, None
    for line in m.group(1).splitlines():
        km = re.match(r"^([A-Za-z_\-]+):\s*(.*)$", line)
        if km:
            key = km.group(1)
            fm[key] = km.group(2).strip().strip('"').strip("'")
        elif key and line.strip():
            fm[key] = (fm[key] + " " + line.strip()).strip()
    return fm, text[m.end():]


def grammar_capability(data):
    out = []
    ident = data["identifier"]["value"]
    meta = {"identifier": data["identifier"], "commit": data["commit"], "commit_date": data.get("commit_date"), "custody_level": data["custody_level"], "capability": data["capability"], "bundle_bytes": data.get("bytes_total"), "bytes_fetched": data.get("bytes_fetched")}
    files = data.get("files") or {}
    entry = next((k for k in files if k.split("/")[-1] == "SKILL.md"), None) or next((k for k in files if k.endswith(".claude-plugin/plugin.json")), None) or next((k for k in files if k.endswith("plugin.json")), None)
    fm = {}
    if entry and entry.endswith(".md"):
        fm, _ = frontmatter(files[entry]["text"])
        meta["frontmatter"] = fm
    elif entry:
        try:
            meta["plugin"] = json.loads(files[entry]["text"])
        except Exception:
            pass
    for rel, f in files.items():
        if rel.endswith(".mcp.json"):
            try:
                meta["mcp_config"] = json.loads(f["text"])
            except Exception:
                pass
        if rel.endswith("marketplace.json"):
            try:
                mk = json.loads(f["text"])
                meta["marketplace"] = {"name": mk.get("name"), "owner": mk.get("owner"), "plugins": [p.get("name") for p in mk.get("plugins") or []], "entry": next((p for p in mk.get("plugins") or [] if p.get("name") == data["capability"]), None)}
            except Exception:
                pass
    for k, v in meta.items():
        if v is None:
            continue
        out.append(dict(kind="metadata_field", key=f"meta:{k}", parent=None, attrs={"key": k, "value": v}, text=f"{k}: {json.dumps(v, ensure_ascii=False)[:600]}", logical=f"metadata_field:{k}", start=None, end=None, selector={"kind": "json_pointer", "pointer": "/" + k}))
    for i, r in enumerate(data.get("tree") or []):
        attrs = {k: v for k, v in dict(r, commit=data["commit"]).items() if v is not None}
        out.append(dict(kind="bundle_file", key=f"file:{P1.sha(r['path'])[:12]}", parent=None, attrs=attrs, text=f"{ident}/{r['path']} [{r['role']}] mode {r['mode']} size {r.get('size')} blob {r['git_blob_id']}", logical=f"bundle_file:{r['path']}", start=None, end=None,
                        selector={"kind": "repository", "repository": data["repository"], "commit": data["commit"], "path": f"{data['path']}/{r['path']}"}))
    for rel, f in files.items():
        if rel.startswith("../") and not rel.endswith("README.md"):
            continue
        if rel.endswith(".md"):
            fm_, body = frontmatter(f["text"])
            units, tables, lines, offs = P1.universal_markdown(body, "official_docs_page")
            secs = [u for u in units if u["kind"] == "section"]
            if not secs and body.strip():
                secs = [dict(key="root", attrs={"heading": fm_.get("description") or rel, "path": rel}, text=body, start=0, end=len(body))]
            for u in secs:
                out.append(dict(kind="docs_section", key=f"doc:{rel}:{u['key']}", parent=None, attrs={"heading": u["attrs"]["heading"], "path": f"{rel}#{u['attrs']['path']}"}, text=u["text"][:3000], logical=f"docs_section:{rel}#{u['attrs']['path']}", start=None, end=None,
                                selector={"kind": "text_quote", "exact": u["attrs"]["heading"], "file": rel}))
        elif rel.endswith("hooks.json") or rel.endswith("hooks.binary.json"):
            try:
                hk = json.loads(f["text"])
            except Exception:
                continue
            n = 0
            for event, groups in (hk.get("hooks") or {}).items():
                for g in groups if isinstance(groups, list) else []:
                    for h in g.get("hooks") or [g]:
                        n += 1
                        attrs = {"event": event, "matcher": g.get("matcher") or "", "hook_type": h.get("type"), "command": h.get("command"), "timeout": h.get("timeout"), "config_path": rel, "ordinal": n}
                        out.append(dict(kind="hook_entry", key=f"hook:{rel}:{n}", parent=None, attrs={k: v for k, v in attrs.items() if v is not None}, text=f"hook {event} matcher '{g.get('matcher') or ''}' -> {h.get('type')}: {h.get('command')}", logical=f"hook_entry:{rel}|{event}|{g.get('matcher') or ''}|{n}", start=None, end=None,
                                        selector={"kind": "json_pointer", "pointer": f"/hooks/{event}", "file": rel}))
    return out


def grammar_mcp_readme(text, server):
    lines = text.splitlines()
    offs = P1.line_offsets(text)
    out = []
    in_tools, toolset, availability, i = False, None, "local_and_remote", 0
    while i < len(lines):
        l = lines[i]
        if l.startswith("## "):
            in_tools = l.strip() == "## Tools"
        if in_tools:
            if l.startswith("### Additional Tools in Remote"):
                availability = "remote_only"
            sm = re.search(r"<summary>(.*)</summary>", l)
            if sm:
                toolset = re.sub(r"<[^>]+>", "", sm.group(1)).strip()
            m = re.match(r"^- \*\*([A-Za-z0-9_\-]+)\*\* - (.*)$", l)
            if m:
                name, desc = m.group(1), m.group(2).strip()
                props, required, scopes = {}, [], []
                j = i + 1
                while j < len(lines) and (lines[j].startswith("  ") or not lines[j].strip()):
                    pl = lines[j].strip()
                    pm = re.match(r"^- `([^`]+)`: (.*?)(?:\s*\(([^()]*)\))?$", pl)
                    sc = re.match(r"^- \*\*.*Scopes\*\*: (.*)$", pl)
                    if sc:
                        scopes = re.findall(r"`([^`]+)`", sc.group(1))
                    elif pm:
                        typ = (pm.group(3) or "").split(",")
                        props[pm.group(1)] = {"type": typ[0].strip() or "string", "description": pm.group(2).strip()[:400]}
                        if any("required" == t.strip() for t in typ):
                            required.append(pm.group(1))
                    if not pl and j + 1 < len(lines) and not lines[j + 1].startswith("  "):
                        break
                    j += 1
                attrs = {"server": server, "name": name, "description": desc[:600], "toolset": toolset, "input_schema": {"type": "object", "properties": props, "required": sorted(required)}, "required": sorted(required), "scopes": scopes, "availability": availability}
                txt = f"{server} tool {name}: {desc}\nparameters: " + "; ".join(f"{k} ({v['type']}{', required' if k in required else ''}): {v['description'][:120]}" for k, v in props.items())
                out.append(dict(kind="mcp_tool", key=f"tool:{name}", parent=None, attrs={k: v for k, v in attrs.items() if v not in (None, [])}, text=txt[:3000], logical=f"mcp_tool:{server}|{name}", start=offs[i], end=offs[min(j, len(offs) - 1)], selector={"kind": "text_quote", "exact": f"**{name}**"}))
                i = j
                continue
        i += 1
    return out


def parse3(v):
    text, data, raw = load(v)
    kind, key = v["kind"], v["key"]
    units, tables, lines, offs = ([], [], [], [])
    if data is None:
        units, tables, lines, offs = P1.universal_markdown(text, kind)
    grammar = []
    if kind == "aie_talk":
        grammar = P1.grammar_talk(text, units, offs)
    elif kind in ("framework_docs_page", "official_docs_page", "release_notes"):
        grammar = P1.grammar_docs(units, "framework_docs_page")
        for g in grammar:
            if g["kind"] == "code_example":
                imps = code_imports(g["text"])
                if imps:
                    g["attrs"]["imports"] = imps
    elif kind == "repository_readme":
        grammar = P1.grammar_docs(units, "repository_readme")
    elif kind == "github_release":
        kept = [r for r in data if keep_release(r, v["attrs"])]
        grammar = P1.grammar_releases(kept)
        for g in grammar:
            if g["kind"] == "release_entry":
                pkg, ver = g["attrs"]["version"].split("==")
                g["attrs"].update({"package": pkg, "version_label": ver})
    elif kind == "registry_listing_page" and v["attrs"].get("registry"):
        grammar = G.grammar_registry(data, v["attrs"]["registry"], STATS[key])
    elif kind == "registry_listing_page":
        grammar = P1.grammar_repo_record(data)
    elif kind == "package_version_page":
        grammar = G.grammar_pypi(data, STATS[key])
    elif kind == "api_surface":
        grammar = grammar_surface3(data)
    elif kind in ("agent_skill_manifest", "agent_plugin_manifest"):
        grammar = grammar_capability(data)
    elif kind == "mcp_server_manifest":
        grammar = grammar_mcp_readme(text, v["attrs"]["server"])
    keep_universal = [u for u in units if u["kind"] in ("section", "table", "link", "metadata_field")] if kind in ("aie_talk",) else [u for u in units if u["kind"] in ("table",)]
    STATS[key][v["label"]] = dict(collections.Counter(u["kind"] for u in keep_universal + grammar))
    return keep_universal + grammar


def stage_units(vs):
    total = 0
    for v in vs:
        if not v.get("path") or one(f"select 1 from content.document_node where representation_id={q(v['representation_id'])} limit 1"):
            continue
        try:
            units = parse3(v)
        except Exception as e:
            log(f"units: {v['key']} PARSE ERROR {e!r}")
            STATS[v["key"]]["error"] = repr(e)[:300]
            continue
        if not units:
            log(f"units: {v['key']}: 0 units (census only)")
            continue
        ids, rows = {}, []
        ordinal_by_parent, seen = collections.Counter(), collections.Counter()
        for u in units:
            seen[u["key"]] += 1
            if seen[u["key"]] > 1:
                u["key"] = f"{u['key']}#{seen[u['key']]}"
            ids[u["key"]] = str(uuid.uuid4())
        for u in units:
            parent_id = ids.get(u.get("parent")) if u.get("parent") else None
            ordinal_by_parent[u.get("parent")] += 1
            txt = (u.get("text") or "")[:8000]
            rows.append(f"""({q(TENANT)}, {q(ids[u['key']])}, {q(v['representation_id'])}, {q(parent_id)}, {ordinal_by_parent[u.get('parent')]}, {q(u['key'][:200])}, {q(u['kind'])}, 1, {q({k: val for k, val in (u.get('attrs') or {}).items() if val is not None})}, {q((u.get('logical') or '')[:500] or None)}, {q(GRAMMAR)}, {q(txt)},
                {q(u.get('selector') or {'kind': 'character_position', 'start': u.get('start'), 'end': u.get('end')})}, {q(u.get('start'))}, {q(u.get('end'))}, {q(u.get('start_ms'))}, {q(u.get('end_ms'))}, {q(sha256_text(txt))})""")
        for i in range(0, len(rows), 150):
            sql(f"""insert into content.document_node(tenant_id, id, representation_id, parent_id, ordinal, stable_local_key, unit_kind, unit_kind_version, attributes, logical_key, grammar_version, inline_text, selector, start_offset, end_offset, start_ms, end_ms, normalized_content_sha256)
                    values {','.join(rows[i:i + 150])}""")
        total += len(rows)
        log(f"units: {v['key']} {v['label']}: {len(rows)} nodes")
    write_json(os.path.join(RUN3, "parse-stats.json"), STATS)
    log(f"units total: {total}")


CC_LINE = re.compile(r"^(feat|fix|chore|docs|refactor|release|perf|test|style|revert|ci|build|infra)(\(([^)]*)\))?(!)?:\s+(.{6,})$")


def stage_units_supplement(vs):
    """D-42: LangChain release bodies are plain conventional-commit lines, not bullets, so grammar_releases (loop 1) emitted almost no
    change_item units. Nodes are append-only: the missing change items are added under their existing release_entry nodes."""
    total = 0
    for v in vs:
        if v["kind"] != "github_release" or not v.get("path"):
            continue
        if one(f"select 1 from content.document_node where representation_id={q(v['representation_id'])} and stable_local_key like 'rel:%:cc%' limit 1"):
            continue
        data = json.loads(open(v["path"], "rb").read())
        kept = [r for r in data if keep_release(r, v["attrs"])]
        parents = {r[0]: r[1] for r in sql_rows(f"select stable_local_key, id from content.document_node where representation_id={q(v['representation_id'])} and unit_kind='release_entry'")}
        rows = []
        for i, rel in enumerate(kept):
            parent = parents.get(f"rel:{i}")
            if not parent:
                continue
            n = 0
            for line in (rel.get("body") or "").splitlines():
                m = CC_LINE.match(line.strip())
                if not m or m.group(1) == "release":
                    continue
                n += 1
                typ, comp, bang, msg = m.group(1), m.group(3), m.group(4), m.group(5)
                kind = "breaking" if bang or "breaking" in msg.lower() else {"feat": "added", "fix": "fixed", "docs": "docs", "perf": "changed", "refactor": "changed", "revert": "removed"}.get(typ, "other")
                kind = "deprecated" if "deprecat" in msg.lower() else ("security" if re.search(r"secur|CVE|GHSA", msg) else kind)
                pr = re.search(r"\(#(\d+)\)\s*$", msg)
                attrs = {"kind": kind, "component": comp, "ordinal": 1000 + n, "commit_type": typ, "pull_request": int(pr.group(1)) if pr else None}
                txt = line.strip()[:600]
                rows.append(f"""({q(TENANT)}, {q(str(uuid.uuid4()))}, {q(v['representation_id'])}, {q(parent)}, {1000 + n}, {q(f'rel:{i}:cc{n}')}, 'change_item', 1, {q({k: val for k, val in attrs.items() if val is not None})}, {q(f"change_item:{rel['tag_name']}|cc{n}")}, {q(GRAMMAR)}, {q(txt)},
                    {q({'kind': 'json_pointer', 'pointer': f'/{i}/body', 'line_text': txt[:120]})}, null, null, null, null, {q(sha256_text(txt))})""")
        for j in range(0, len(rows), 150):
            sql(f"""insert into content.document_node(tenant_id, id, representation_id, parent_id, ordinal, stable_local_key, unit_kind, unit_kind_version, attributes, logical_key, grammar_version, inline_text, selector, start_offset, end_offset, start_ms, end_ms, normalized_content_sha256)
                    values {','.join(rows[j:j + 150])}""")
        total += len(rows)
        log(f"units supplement {v['key']}: {len(rows)} change items")
    log(f"units supplement total: {total}")


# ------------------------------------------------------------------ entities, roles, relationships
def all_nodes(kinds, doc_kinds=None, extra=""):
    where = f"n.unit_kind = any({qarr(kinds)})" + (f" and d.document_type_code = any({qarr(doc_kinds)})" if doc_kinds else "") + extra
    return sql_json(f"""select json_build_object('id', n.id, 'unit_kind', n.unit_kind, 'attrs', n.attributes, 'logical_key', n.logical_key, 'text', n.inline_text, 'key', d.attributes->>'key', 'doc_attrs', d.attributes, 'document_id', d.id, 'version_id', v.id,
                        'representation_id', r.id, 'kind', d.document_type_code, 'title', d.canonical_title, 'start_ms', n.start_ms)
                        from content.document_node n join content.document_representation r on r.id = n.representation_id join content.document_version v on v.id = r.document_version_id join content.document d on d.id = v.document_id
                        where n.tenant_id={q(TENANT)} and d.attributes->>'loop' = '3' and {where} order by d.attributes->>'key', n.ordinal""")


CONCEPTS3 = [("memory", "Agent memory", "memory", "intermediate"), ("continual-learning", "Continual learning", "memory", "advanced"), ("traces-and-observability", "Traces and observability", "eval", "intermediate"), ("trace-mining", "Trace mining", "eval", "advanced"),
             ("fine-tuning", "Fine-tuning and distillation", "other", "advanced"), ("subagents", "Sub-agents", "agent_pattern", "intermediate"), ("agent-skills", "Agent skills", "skill", "beginner"), ("middleware", "Agent middleware", "harness", "intermediate"),
             ("context-compaction", "Context compaction and summarization", "context", "intermediate"), ("human-in-the-loop", "Human in the loop", "workflow", "beginner"), ("sleep-time-compute", "Sleep-time compute", "memory", "advanced"),
             ("procedural-memory", "Procedural memory", "memory", "intermediate"), ("agent-hooks", "Agent hooks", "harness", "intermediate"), ("agent-plugins", "Agent plugins", "harness", "intermediate"), ("model-harness-task-fit", "Model, harness and task fit", "harness", "advanced"),
             ("llm-judges", "LLM judges and verifiers", "eval", "intermediate"), ("harness-engineering", "Harness engineering", "harness", "advanced"), ("evals", "Evals", "eval", "intermediate"), ("sandboxes", "Sandboxes", "sandbox", "intermediate"),
             ("mcp", "Model Context Protocol", "mcp", "beginner"), ("context-engineering", "Context engineering", "context", "intermediate"), ("agent-backends", "Agent filesystem backends", "harness", "intermediate"), ("agent-permissions", "Agent permissions", "harness", "intermediate")]
# full-content mentions: (entity key, regex). Deliberately conservative; a mention is "this passage names it", nothing more.
MENTIONS = [("c:memory", r"\bmemor(y|ies)\b"), ("c:continual-learning", r"continual(ly)? learning"), ("c:traces-and-observability", r"\btrac(e|es|ing)\b|observability"), ("c:trace-mining", r"(min(e|ing)|curat\w+) (the |agent |your )?(trace|data)|data mining"),
            ("c:harness-engineering", r"harness"), ("c:fine-tuning", r"fine[- ]?tun\w+|\bSFT\b|distill"), ("c:subagents", r"sub-?agents?"), ("c:agent-skills", r"\bskills?\b"), ("c:middleware", r"middlewares?"),
            ("c:context-compaction", r"compact(ion|ed|ing)|summariz(e|ation) (the )?(conversation|context|history)"), ("c:human-in-the-loop", r"human[- ]in[- ]the[- ]loop|\binterrupts?\b"), ("c:sleep-time-compute", r"sleep[- ]time|dreaming"),
            ("c:procedural-memory", r"procedural memory"), ("c:agent-hooks", r"\bhooks?\b"), ("c:agent-plugins", r"\bplugins?\b"), ("c:evals", r"\bevals?\b|evaluations?"), ("c:sandboxes", r"sandbox"), ("c:mcp", r"\bMCP\b"),
            ("c:context-engineering", r"context engineering"), ("c:llm-judges", r"\bjudg(e|es|ing)\b|verifiers?"), ("c:model-harness-task-fit", r"model[- ]harness[- ]task"),
            ("l:deepagents", r"deep ?agents"), ("l:langgraph", r"langgraph"), ("l:langchain", r"\blangchain\b"), ("p:langsmith-engine", r"langsmith engine"), ("p:langsmith", r"langsmith"), ("p:langsmith-context-hub", r"context hub"),
            ("b:terminal-bench", r"terminal[- ]?bench"), ("p:claude-code", r"claude code"), ("p:codex", r"\bcodex\b")]


def stage_entities(vs):
    b = Batch("loop3-entities-and-relationships", {"stage": "entities", "loop": 3})
    done = {r[0] for r in sql_rows(f"select distinct r.node_id from content.unit_entity_role r join content.document_node n on n.id = r.node_id where n.grammar_version = {q(GRAMMAR)}")}
    org = {s: one(f"select id from catalog.entity where kind='organization' and slug={q(s)}") for s in ("langchain", "github", "ai-engineer")}
    con = {slug: ensure_entity("concept", slug, name, {"component": comp, "level": level}) for slug, name, comp, level in CONCEPTS3}
    # libraries, repository
    lib = {"deepagents": ensure_entity("library", "deepagents", "Deep Agents"), "langgraph": ensure_entity("library", "langgraph", "LangGraph"), "langchain": ensure_entity("library", "langchain", "LangChain"),
           "langchain-core": ensure_entity("library", "langchain-core", "langchain-core"), "langsmith": ensure_entity("library", "langsmith", "langsmith")}
    sql(f"update catalog.entity set display_name='LangChain' where id={q(lib['langchain'])} and display_name='langchain'")
    set_attrs(lib["langchain"], {"ecosystem": "pypi", "package_name": "langchain", "category": "agent framework (v1: agents, models, middleware)", "docs_url": "https://docs.langchain.com/oss/python/langchain/overview", "repository_url": "https://github.com/langchain-ai/langchain"})
    set_attrs(lib["langchain-core"], {"ecosystem": "pypi", "package_name": "langchain-core", "category": "base abstractions (runnables, messages, tools, language models)", "docs_url": "https://reference.langchain.com/python/langchain_core/", "repository_url": "https://github.com/langchain-ai/langchain"})
    for slug in ("langchain", "langchain-core"):
        identifier(lib[slug], "pypi", slug)
    repo = ensure_entity("repository", "langchain-ai-langchain", "langchain-ai/langchain", {"host": "github.com", "owner": "langchain-ai", "name": "langchain", "default_branch": "master"})
    for r in sql_rows("select id, display_name from catalog.entity where kind='repository'"):  # repair: loop 1 wrote scheme 'github_full_name', which the vocabulary rejects
        identifier(r[0], "github", r[1])
    for slug in ("langchain", "langchain-core"):
        b.add(f"select temporal.assert_relationship('backed_by_repository', {q(lib[slug])}, {q(repo)});")
        b.add(f"select temporal.assert_relationship('develops', {q(org['langchain'])}, {q(lib[slug])}, tstzrange('2022-01-01', null, '[)'), p_extent => temporal.make_extent('since 2022 (repository creation year, year precision)', 'year'));")
        b.add(f"select temporal.assert_relationship('instance_of_concept', {q(lib[slug])}, {q(con['harness-engineering'] if slug == 'x' else ensure_entity('concept', 'agent-orchestration', 'Agent orchestration'))});")
    for slug, cs in {"deepagents": ["subagents", "agent-skills", "memory", "middleware", "context-compaction", "sandboxes", "human-in-the-loop", "harness-engineering"], "langchain": ["middleware", "human-in-the-loop", "mcp"]}.items():
        for c in cs:
            b.add(f"select temporal.assert_relationship('instance_of_concept', {q(lib[slug])}, {q(con[c])});")
    # products named by the talks and the capability items
    prod = {"deep-agents-code": ensure_entity("product", "deep-agents-code", "Deep Agents Code", {"category": "coding agent harness (CLI)", "docs_url": "https://docs.langchain.com/oss/deepagents/code/overview", "also_known_as": ["dcode", "deepagents-code"]}, aliases=["dcode", "deepagents-code"]),
            "langsmith": ensure_entity("product", "langsmith", "LangSmith", {"category": "observability and evaluation platform", "website_url": "https://www.langchain.com/langsmith"}),
            "langsmith-engine": ensure_entity("product", "langsmith-engine", "LangSmith Engine", {"category": "trace analysis agent (feature of LangSmith)", "docs_url": "https://docs.langchain.com/langsmith/engine"}),
            "langsmith-context-hub": ensure_entity("product", "langsmith-context-hub", "LangSmith Context Hub", {"category": "versioned context store (feature of LangSmith)", "docs_url": "https://docs.langchain.com/langsmith/use-the-context-hub"}),
            "claude-code": one("select id from catalog.entity where kind='product' and slug='claude-code'"), "codex": one("select id from catalog.entity where kind='product' and slug='codex'")}
    for p in ("deep-agents-code", "langsmith", "langsmith-engine", "langsmith-context-hub"):
        b.add(f"select temporal.assert_relationship('develops', {q(org['langchain'])}, {q(prod[p])}, tstzrange('2026-01-01', null, '[)'), p_extent => temporal.make_extent('as of the 2026 docs capture (year precision)', 'year'));")
    feats = {}
    for f, page in {"plugins": "plugins", "hooks": "hooks", "skills": "memory-and-skills", "mcp-tools": "mcp-tools", "subagents": "subagents", "remote-sandboxes": "remote-sandboxes"}.items():
        feats[f] = ensure_entity("product_feature", f"deep-agents-code-{f}", f"Deep Agents Code: {f}", {"feature": f, "docs_url": f"https://docs.langchain.com/oss/deepagents/code/{page}", "stated_by": "first-party docs page captured 2026-11-10"})
        b.add(f"select temporal.assert_relationship('has_feature', {q(prod['deep-agents-code'])}, {q(feats[f])});")
    bench = one("select id from catalog.entity where kind='benchmark' and slug='terminal-bench'")
    ent = {**{"c:" + k: v for k, v in con.items()}, **{"l:" + k: v for k, v in lib.items()}, **{"p:" + k: v for k, v in prod.items() if v}, "b:terminal-bench": bench}
    write_json(os.path.join(RUN3, "entity-keys.json"), ent)

    # releases: GitHub release entries (langchain, langchain-core 1.x) and the tags of every ingested surface
    rel = {}

    def release(sw, ver, **attrs):
        k = (sw, ver)
        if k not in rel:
            name = {"deepagents": "Deep Agents", "langchain": "LangChain", "langchain-core": "langchain-core"}[sw]
            rel[k] = ensure_entity("library_release", slugify(f"{sw}-{ver}"), f"{name} {ver}", {"version_label": ver, **attrs})
            b.add(f"select temporal.assert_relationship('version_of', {q(rel[k])}, {q(lib[sw])});")
        return rel[k]

    for u in all_nodes(["release_entry"], ["github_release"]):
        a = u["attrs"]
        rid = release(a["package"], a["version_label"], tag=a["version"], released_on=a.get("released_on"), release_url=a.get("url"), breaking=bool(a.get("breaking")), prerelease=bool(a.get("prerelease")), highlights=[])
        if u["id"] not in done:
            add_role(u["id"], rid, "release")
            add_role(u["id"], lib[a["package"]], "software")
    for u in sql_json(f"""select json_build_object('id', c.id, 'parent', p.attributes) from content.document_node c join content.document_node p on p.id = c.parent_id where c.unit_kind='change_item' and c.grammar_version={q(GRAMMAR)} and p.unit_kind='release_entry'"""):
        if u["id"] not in done:
            add_role(u["id"], lib[u["parent"]["package"]], "software")
    surf = sql_json(f"""select json_build_object('rep', r.id, 'attrs', d.attributes, 'document_id', d.id, 'n', (select count(*) from content.document_node n where n.representation_id = r.id)) from content.document d join content.document_version v on v.document_id=d.id
                        join content.document_representation r on r.document_version_id=v.id where d.document_type_code='api_surface' and d.attributes->>'loop'='3' and r.representation_class='structural_extraction'""")
    for s in surf:
        a = s["attrs"]
        if a["key"] in SKIP_SURFACE_KEYS or not s["n"]:
            continue
        ver = a["release_tag"].split("==")[1]
        rid = release(a["software"], ver, tag=a["release_tag"], released_on=a.get("released_on"))
        set_attrs(rid, {"parser": "python-ast/2", "symbol_count": s["n"], "over_cap": False})
        about_doc(s["document_id"], rid, "primary")
        if not one(f"select 1 from content.unit_entity_role r join content.document_node n on n.id=r.node_id where n.representation_id={q(s['rep'])} limit 1"):
            sql(f"""insert into content.unit_entity_role(tenant_id, node_id, entity_id, role, method, confidence)
                    select {q(TENANT)}, n.id, x.e, x.r, 'mapping', 1.0 from content.document_node n cross join (values ({q(rid)}::uuid, 'release'), ({q(lib[a['software']])}::uuid, 'software')) x(e, r)
                     where n.representation_id={q(s['rep'])} and n.unit_kind='api_symbol' on conflict do nothing""")
    log(f"releases: {len(rel)} release entities touched; surfaces: {len(surf)}")

    # talks: header -> talk work, speaker, employer, event; the talk document is linked to its work (document_about_entity primary)
    wf = one("select id from catalog.entity where kind='industry_event' and slug='worldsfair-2026'")
    talks = {}
    for u in all_nodes(["talk_header"], ["aie_talk"]):
        a, da = u["attrs"], u["doc_attrs"]
        title = da.get("session_title") or a.get("title")
        talk = ensure_entity("talk", slugify((a.get("session_id") or "") + "-" + title)[:80], title, {"talk_kind": "talk", "video_url": a.get("video_url"), "session_id": a.get("session_id"), "edition": a.get("event"), "published_title": a.get("title"), "page_url": re.sub(r"\.md$", "", [m for m in MANIFEST if m["key"] == u["key"]][0]["url"])})
        identifier(talk, "youtube_video", a["session_id"])
        ensure_work(talk, "talk", title, canonical_url=a.get("video_url"), venue=wf, attributes={"published_title": a.get("title"), "transcript": "published on ai.engineer", "video": "link only (no bytes)"})
        about_doc(u["document_id"], talk, "primary")
        talks[u["key"]] = talk
        b.add(f"select temporal.assert_relationship('presented_at', {q(talk)}, {q(wf)});")
        for sp in a.get("speakers") or []:
            pid = ensure_entity("person", slugify(sp), sp, {"affiliation_text": a.get("affiliation") or "LangChain"})
            b.add(f"select temporal.assert_relationship('presented_by', {q(talk)}, {q(pid)});")
            b.add(f"select temporal.assert_relationship('employed_by', {q(pid)}, {q(org['langchain'])}, tstzrange('2026-01-01', null, '[)'), p_extent => temporal.make_extent('as of the talk edition 2026', 'year'));")
            if u["id"] not in done:
                add_role(u["id"], pid, "speaker")
        if u["id"] not in done:
            add_role(u["id"], wf, "event")
    # talk resources: docs page in the lab -> unit_link cites; arXiv -> paper P0 + cites; benchmark -> about; everything else recorded as unresolved
    shapes = []
    for u in all_nodes(["talk_resource"], ["aie_talk"]):
        href, talk = u["attrs"]["href"], talks[u["key"]]
        docm = re.match(r"https://docs\.langchain\.com/(.+?)/?$", href)
        target = one(f"select d.id from content.document d where d.attributes->>'docs_path' = {q(docm.group(1))}") if docm else None
        if target:
            first = one(f"select n.id from content.document_node n join content.document_representation r on r.id=n.representation_id join content.document_version v on v.id=r.document_version_id where v.document_id={q(target)} and n.unit_kind='docs_section' order by n.ordinal limit 1")
            sql(f"insert into content.unit_link(tenant_id, from_node_id, to_node_id, kind, method, confidence) values ({q(TENANT)}, {q(u['id'])}, {q(first)}, 'cites', 'url_match', 1.0) on conflict do nothing")
            shapes.append({"shape": "talk_resource -> docs page in the lab (unit_link cites)", "talk": u["key"], "href": href, "resolved": True})
        elif "arxiv.org" in href:
            ax = re.search(r"arxiv\.org/abs/([\d.]+)", href).group(1)
            paper = ensure_entity("paper", slugify("arxiv-" + ax), u["attrs"].get("text") or ax, {"arxiv_id": ax, "ingestion_level": "P0"})
            identifier(paper, "arxiv", ax)
            ensure_work(paper, "paper", u["attrs"].get("text") or ax, canonical_url=href, attributes={"arxiv_id": ax})
            b.add(f"select temporal.assert_relationship('cites', {q(talk)}, {q(paper)});")
            add_role(u["id"], paper, "references")
            shapes.append({"shape": "talk_resource -> paper P0 (cites)", "talk": u["key"], "href": href, "resolved": True})
        elif "tbench.ai" in href and bench:
            b.add(f"select temporal.assert_relationship('about', {q(talk)}, {q(bench)});")
            add_role(u["id"], bench, "references")
            shapes.append({"shape": "talk_resource -> benchmark entity of loop 2 (about)", "talk": u["key"], "href": href, "resolved": True})
        else:
            shapes.append({"shape": "talk_resource -> document", "talk": u["key"], "href": href, "resolved": False, "why": "not captured (blog post or external site outside the selection); the URL stays on the talk_resource unit"})
    write_json(os.path.join(RUN3, "connection-shapes-resources.json"), shapes)

    # docs sections and examples -> software / product role
    for u in all_nodes(["docs_section", "readme_section", "code_example"], ["framework_docs_page", "official_docs_page", "release_notes", "repository_readme"]):
        if u["id"] in done:
            continue
        da = u["doc_attrs"]
        target = prod.get(da.get("product")) or lib.get(da.get("software")) or prod.get(da.get("software"))
        if target:
            add_role(u["id"], target, "software", "mapping", 0.9)
    # capabilities
    caps = {}
    for v in vs:
        if v["kind"] not in ("agent_skill_manifest", "agent_plugin_manifest") or not v.get("path"):
            continue
        da = v["attrs"]
        data = json.load(open(v["path"], encoding="utf-8"))
        meta = {n["attributes"]["key"]: n["attributes"]["value"] for n in nodes_of(v, ["metadata_field"])}
        if v["kind"] == "agent_skill_manifest":
            fm = meta.get("frontmatter") or {}
            eid = ensure_entity("agent_skill", slugify("dcode-" + da["capability_name"]), fm.get("name") or da["capability_name"], {"name": fm.get("name") or da["capability_name"], "description": (fm.get("description") or "")[:600], "license": fm.get("license"), "entry_path": "SKILL.md",
                                "declared_tools": [t.strip() for t in re.split(r"[,\s]+", fm.get("allowed-tools") or "") if t.strip()] or None, "source_repository": da["repository"], "source_path": da["bundle_path"], "shipped_with": da.get("shipped_with")})
            b.add(f"select temporal.assert_relationship('compatible_with', {q(eid)}, {q(prod['deep-agents-code'])}, p_properties => {q({'stated_by': 'ships inside deepagents_code/built_in_skills at ' + da['ref'], 'constraint': da['ref']})});")
            b.add(f"select temporal.assert_relationship('instance_of_concept', {q(eid)}, {q(con['agent-skills'])});")
        else:
            pj = meta.get("plugin") or {}
            eid = ensure_entity("agent_plugin", slugify(da["repository"].split("/")[1] + "-" + da["capability_name"]), pj.get("name") or da["capability_name"], {"name": pj.get("name") or da["capability_name"], "description": pj.get("description"), "version": pj.get("version"),
                                "author": (pj.get("author") or {}).get("name") if isinstance(pj.get("author"), dict) else pj.get("author"), "harnesses": da.get("harnesses"), "source_repository": da["repository"], "source_path": da["bundle_path"],
                                "components": {"hooks": sum(1 for n in nodes_of(v, ["hook_entry"])), "commands": sum(1 for r in data["tree"] if r["path"].startswith("commands/")), "mcp_servers": len(((meta.get("mcp_config") or {}).get("mcpServers") or {}))}})
            b.add(f"select temporal.assert_relationship('instance_of_concept', {q(eid)}, {q(con['agent-plugins'])});")
            for h in da.get("harnesses") or []:
                if prod.get(h):
                    b.add(f"select temporal.assert_relationship('compatible_with', {q(eid)}, {q(prod[h])}, p_properties => {q({'stated_by': 'plugin manifest directory for this harness in ' + da['repository']})});")
            mk = meta.get("marketplace") or {}
            if mk.get("name"):
                reg = ensure_entity("registry", slugify("marketplace-" + da["repository"].split("/")[1]), f"{da['repository']} plugin marketplace", {"registry_kind": "plugin_marketplace", "website_url": "https://github.com/" + da["repository"], "description": f"marketplace '{mk['name']}' ({len(mk.get('plugins') or [])} plugins)"})
                b.add(f"select temporal.assert_relationship('listed_in', {q(eid)}, {q(reg)}, tstzrange({q(da['commit_date'])}, null, '[)'), p_extent => temporal.make_extent('listed at commit ' || {q(da['commit'][:10])}, 'day'));")
            for name, cfg in ((meta.get("mcp_config") or {}).get("mcpServers") or {}).items():
                url = cfg.get("url") or " ".join([cfg.get("command") or ""] + (cfg.get("args") or []))
                srv = ensure_entity("mcp_server", slugify("plugin-" + name), f"{name} (MCP server configured by plugin {da['capability_name']})", {"hosting": "remote" if cfg.get("url") else "local", "transport": [cfg.get("type") or ("http" if cfg.get("url") else "stdio")], "website_url": cfg.get("url"), "description": f"configured in .mcp.json of {da['identifier_value']}", "registry_status": "not_in_registry_capture"})
                identifier(srv, "other", url)
                b.add(f"select temporal.assert_relationship('bundles', {q(eid)}, {q(srv)}, p_properties => {q({'config_path': '.mcp.json', 'transport': cfg.get('type') or ('http' if cfg.get('url') else 'stdio')})});")
        identifier(eid, da["identifier_scheme"], da["identifier_value"])
        b.add(f"select temporal.assert_relationship('develops', {q(org['langchain'])}, {q(eid)}, tstzrange('2026-01-01', null, '[)'), p_extent => temporal.make_extent('as of the pinned commit (year precision)', 'year'));")
        about_doc(v["document_id"], eid, "primary")
        caps[v["key"]] = eid
        for n in nodes_of(v, ["bundle_file", "hook_entry"]):
            if n["id"] not in done:
                add_role(n["id"], eid, "capability")
    # the GitHub MCP server: registry record -> entity with shared identifiers; tool units -> server role
    reg_nodes = [u for u in all_nodes(["registry_listing"], ["registry_listing_page"]) if u["attrs"].get("name") == MCP_SERVER["server"]]
    gh_srv = None
    if reg_nodes:
        a = reg_nodes[0]["attrs"]
        gh_srv = ensure_entity("mcp_server", slugify(a["name"]), a["name"], {"registry_name": a["name"], "namespace": a.get("namespace"), "latest_version": a.get("version"), "description": a.get("description"), "transport": a.get("transports"), "repository_url": "https://github.com/github/github-mcp-server",
                               "first_party_inferred": True, "registry_status": "active", "hosting": "both", "package_identifiers": a.get("package_identifiers")})
        identifier(gh_srv, "mcp_registry", a["name"])
        raw = json.load(open([v for v in vs if v["key"] == "mcp-registry-github-mcp-server"][0]["path"], encoding="utf-8"))
        for s in raw["servers"]:
            sv = s.get("server", s)
            if sv.get("name") == a["name"]:
                for p in sv.get("packages") or []:
                    if p.get("registryType") == "oci":
                        identifier(gh_srv, "oci", p["identifier"].split(":")[0])
        mcpreg = one("select id from catalog.entity where kind='registry' and slug='mcp-registry'")
        b.add(f"select temporal.assert_relationship('listed_in', {q(gh_srv)}, {q(mcpreg)}, tstzrange('2026-11-10', null, '[)'), p_extent => temporal.make_extent('observed in the registry on 2026-11-10', 'day'));")
        b.add(f"select temporal.assert_relationship('develops', {q(org['github'])}, {q(gh_srv)}, tstzrange('2025-01-01', null, '[)'), p_extent => temporal.make_extent('since 2025 (year precision)', 'year'));")
        for n in reg_nodes:
            if n["id"] not in done:
                add_role(n["id"], gh_srv, "server")
        mdoc = one(f"select id from content.document where attributes->>'key' = {q(MCP_SERVER['key'])}")
        about_doc(mdoc, gh_srv, "primary")
        sql(f"""insert into content.unit_entity_role(tenant_id, node_id, entity_id, role, method, confidence) select {q(TENANT)}, n.id, {q(gh_srv)}, 'server', 'mapping', 1.0 from content.document_node n where n.unit_kind='mcp_tool' and n.grammar_version={q(GRAMMAR)} on conflict do nothing""")
    # full-content mentions (rule): transcript segments, write-up chapters, docs sections
    n_m = 0
    pats = [(k, re.compile(p, re.I)) for k, p in MENTIONS if ent.get(k)]
    for u in all_nodes(["transcript_segment", "talk_writeup", "docs_section"], ["aie_talk", "framework_docs_page", "official_docs_page", "release_notes"]):
        if u["id"] in done:
            continue
        txt = u["text"] or ""
        for k, pat in pats:
            if pat.search(txt):
                role = "mentions" if u["unit_kind"] != "docs_section" else ("concept" if k.startswith("c:") else None)
                if role:
                    add_role(u["id"], ent[k], role, "rule", 0.7)
                    n_m += 1
    flush_roles()
    out = b.commit()
    log(f"entities committed ({(out or '').splitlines()[-1] if out else 'no new statements'}); mentions written {n_m}; capabilities {len(caps)}; github server {bool(gh_srv)}")
    write_json(os.path.join(RUN3, "entities-summary.json"), {"by_kind": dict(sql_rows(f"select kind, count(*) from catalog.entity where tenant_id={q(TENANT)} group by kind order by 1")), "relationships": dict(sql_rows("select kind, count(*) from catalog.relationship where k_to is null group by kind order by 1")),
                                                              "roles_loop3": dict(sql_rows(f"select r.role, count(*) from content.unit_entity_role r join content.document_node n on n.id=r.node_id where n.grammar_version={q(GRAMMAR)} group by 1"))})


# ------------------------------------------------------------------ links: docs -> symbol (R4), symbol -> symbol (imports)
STOP = {"Any", "None", "True", "False", "List", "Dict", "Optional", "Union", "Callable", "State", "Type", "Self", "Tool", "tool", "tools", "run", "name", "Agent", "model", "Model", "messages", "Message", "Config", "config", "Context", "context", "Runtime", "runtime", "store", "Store", "Command", "content"}


def latest_symbols():
    rows = sql_json(f"""select json_build_object('id', s.node_id, 'qn', s.qualified_name, 'kind', s.symbol_kind, 'pkg', s.package, 'tag', s.release_tag, 'exported', (select n.attributes->>'exported_by' from content.document_node n where n.id = s.node_id))
                        from api.api_symbols s join content.document d on d.id = s.document_id
                       where (s.package, s.release_tag) in (('deepagents','deepagents==0.7.35'),('langchain','langchain==1.4.10'),('langchain_core','langchain-core==1.7.7'),('langgraph','1.2.20')) and (d.attributes->>'loop' = '3' or s.package = 'langgraph')""")
    return rows


def stage_links(vs):
    syms = latest_symbols()
    by_qn = {s["qn"]: s for s in syms}
    by_last = collections.defaultdict(list)
    for s in syms:
        if s["kind"] != "method":
            by_last[s["qn"].split(".")[-1]].append(s)

    def resolve(name, prefer_pkg=None):
        """qualified or bare name -> symbol. Qualified: exact, else same root package + same last name (re-exports). Bare: unique or preferred package."""
        if name in by_qn:
            return by_qn[name], "exact"
        last = name.split(".")[-1]
        cands = by_last.get(last) or []
        if "." in name:
            root = name.split(".")[0]
            cands = [c for c in cands if c["pkg"] == root]
            method = "reexport_same_package"
        else:
            if last in STOP or len(last) < 4:
                return None, None
            if prefer_pkg and any(c["pkg"] == prefer_pkg for c in cands):
                cands = [c for c in cands if c["pkg"] == prefer_pkg]
            method = "bare_name"
        if not cands:
            return None, None
        cands.sort(key=lambda c: (0 if c["exported"] else 1, c["qn"].count("."), c["qn"]))
        if len({c["pkg"] for c in cands}) > 1:
            return None, "ambiguous_package"
        return cands[0], method

    # docs -> symbols
    links, stale, n_units = {}, [], 0
    pkg_of = {"deepagents": "deepagents", "langchain": "langchain", "langgraph": "langgraph"}
    for u in all_nodes(["docs_section", "code_example"], ["framework_docs_page", "official_docs_page", "release_notes"]):
        n_units += 1
        prefer = pkg_of.get(u["doc_attrs"].get("software"))
        txt = u["text"] or ""
        heading = (u["attrs"].get("heading") or "") if u["unit_kind"] == "docs_section" else ""
        imports = u["attrs"].get("imports") or []
        for imp in imports:
            s, how = resolve(imp, prefer)
            if s:
                links[(u["id"], s["id"], "documents")] = ("import_in_example", 0.95)
            elif imp.split(".")[0] in ("deepagents", "langchain", "langchain_core"):
                stale.append({"document": u["title"], "docs_path": u["doc_attrs"].get("docs_path"), "node_id": u["id"], "import": imp, "why": how or "not defined in the latest ingested surface of its package"})
        names = set(re.findall(r"`([A-Za-z_][\w.]*?)(?:\(\))?`", txt)) | set(re.findall(r"\b([A-Za-z_]\w+)\(", txt if u["unit_kind"] == "code_example" else ""))
        for nm in names:
            s, how = resolve(nm, prefer)
            if not s:
                continue
            in_heading = nm.split(".")[-1] in heading
            key = (u["id"], s["id"], "documents" if in_heading else "mentions")
            if (u["id"], s["id"], "documents") in links:
                continue
            links.setdefault(key, ("heading_names_symbol" if in_heading else "backtick_or_call_name", 0.9 if in_heading else (0.8 if how == "exact" else 0.6)))
    rows = [f"({q(TENANT)}, {q(a)}, {q(b_)}, {q(k)}, {q(m)}, {c})" for (a, b_, k), (m, c) in links.items()]
    for i in range(0, len(rows), 400):
        sql("insert into content.unit_link(tenant_id, from_node_id, to_node_id, kind, method, confidence) values " + ",".join(rows[i:i + 400]) + " on conflict do nothing")
    write_json(os.path.join(RUN3, "stale-doc-imports.json"), stale)
    log(f"docs -> symbol links: {len(rows)} over {n_units} docs units ({collections.Counter(k for (_, _, k) in links)}); imports in examples that do not resolve to the latest surface: {len(stale)}")
    # symbol -> symbol imports (latest deepagents and langchain surfaces)
    imp_rows, unresolved, n_uses = [], collections.Counter(), 0
    for s in sql_json(f"""select json_build_object('id', n.id, 'qn', n.attributes->>'qualified_name', 'uses', n.attributes->'uses_external', 'tag', d.attributes->>'release_tag') from content.document_node n join content.document_representation r on r.id=n.representation_id
                          join content.document_version v on v.id=r.document_version_id join content.document d on d.id=v.document_id
                         where n.unit_kind='api_symbol' and n.grammar_version={q(GRAMMAR)} and n.attributes ? 'uses_external' and d.attributes->>'release_tag' in ('deepagents==0.7.35','langchain==1.4.10')"""):
        for name in s["uses"] or []:
            n_uses += 1
            t, how = resolve(name)
            if t and t["id"] != s["id"]:
                imp_rows.append(f"({q(TENANT)}, {q(s['id'])}, {q(t['id'])}, 'imports', {q(how)}, {1.0 if how == 'exact' else 0.8})")
            else:
                unresolved[name.split(".")[0]] += 1
    for i in range(0, len(imp_rows), 400):
        sql("insert into content.unit_link(tenant_id, from_node_id, to_node_id, kind, method, confidence) values " + ",".join(imp_rows[i:i + 400]) + " on conflict do nothing")
    write_json(os.path.join(RUN3, "imports-resolution.json"), {"external_uses": n_uses, "resolved_links": len(imp_rows), "unresolved_by_root_package": dict(unresolved), "note": "unresolved names stay readable in the symbol's uses_external attribute; langgraph is capped at 400 symbols (loop 2), langsmith and partner packages are not ingested as surfaces"})
    log(f"symbol -> symbol imports: {len(imp_rows)} links from {n_uses} external uses; unresolved by root: {dict(unresolved)}")


# ------------------------------------------------------------------ facts: release events, repository counts, depends_on
def stage_facts(vs):
    lib = {r[0]: r[1] for r in sql_rows("select slug, id from catalog.entity where kind='library'")}
    for v in vs:
        if v["kind"] not in ("github_release", "registry_listing_page", "package_version_page") or not v.get("path") or v["attrs"].get("registry"):
            continue
        label = f"loop3-facts-{v['key']}-{v['label']}"
        if one(f"select 1 from temporal.knowledge_batch where summary->>'label' = {q(label)}"):
            continue
        b = Batch(label, {"document": v["key"], "version": v["label"], "loop": 3})
        run_id = L1.extraction_run_for(v)
        rcpt = native_receipt(f"loop3-claims-{v['key']}", {"document": v["key"], "loop": 3})
        captured = v["captured_at"]
        n = 0
        if v["kind"] == "github_release":
            mid = L1.mapping_id("release_entry", "github_release", "event", event="release_published")
            for nd in nodes_of(v, ["release_entry"]):
                a = nd["attributes"]
                rel = L1.role_entity(nd["id"], "release")
                if not rel or not a.get("released_on"):
                    continue
                loc = L1.locator_for(v, nd, "json_pointer")
                cid = L1.make_claim(rcpt, f"{a['package']} {a['version_label']} was published on {a['released_on']} (GitHub release {a['version']})", "event", {"subject": rel, "version": a["version_label"], "released_on": a["released_on"], "url": a.get("url"), "path": "deterministic_first_party"}, [(rel, "subject")], loc, run_id, nd, mid)
                highlights = [c["text"][:160] for c in sql_json(f"select json_build_object('text', inline_text) from content.document_node where parent_id={q(nd['id'])} and unit_kind='change_item' order by ordinal limit 6")]
                set_attrs(rel, {"highlights": highlights})
                b.add(f"""with e as (select temporal.assert_event('release_published', {q(rel)}, tstzrange({q(a['released_on'])}, ({q(a['released_on'])})::timestamptz + interval '1 second', '[)'), 'actual', null, null, {q(a['version'])}, null, {q(cid)}, {q({'version': a['version_label'], 'package': a['package'], 'url': a.get('url')})}) id)
                         insert into evidence.segment_support(tenant_id, event_occurrence_id, claim_id, locator_id, role, k_from) select {q(TENANT)}, e.id, {q(cid)}, {q(loc)}, 'supports', temporal.current_k() from e on conflict do nothing;""")
                n += 1
        elif v["kind"] == "registry_listing_page":
            rep = one("select id from catalog.entity where kind='repository' and slug='langchain-ai-langchain'")
            for nd in nodes_of(v, ["metadata_field"]):
                a = nd["attributes"]
                sk = {"stargazers_count": "repository_stars", "forks_count": "repository_forks", "open_issues_count": "repository_open_issues"}.get(a.get("key"))
                if sk:
                    loc = L1.locator_for(v, nd, "json_pointer")
                    cid = L1.make_claim(rcpt, f"langchain-ai/langchain repository {a['key']} = {a['value']} on {captured[:10]} (GitHub API)", "measurement", {"subject": rep, "field": a["key"], "value": a["value"]}, [(rep, "subject")], loc, run_id, nd, None)
                    b.add(f"select temporal.assert_state({q(rep)}, {q(sk)}, tstzrange({q(captured)}, null, '[)'), '', null, {a['value']}, null, 'count', null, '{{}}'::jsonb, null, {q(cid)}, 'observation_bounded');")
                    n += 1
                if a.get("key") == "license_spdx":
                    loc = L1.locator_for(v, nd, "json_pointer")
                    cid = L1.make_claim(rcpt, f"langchain-ai/langchain repository license is {a['value']} (GitHub API record {captured[:10]})", "attribute", {"subject": rep, "spdx": a["value"]}, [(rep, "subject")], loc, run_id, nd, None)
                    b.add(f"select temporal.assert_state({q(rep)}, 'library_license', tstzrange({q(captured)}, null, '[)'), '', null, null, null, null, null, {q({'license_code': a['value'], 'spdx': a['value']})}, null, {q(cid)}, 'observation_bounded');")
                    n += 1
        elif v["kind"] == "package_version_page" and v["attrs"].get("software") in ("langchain", "langchain-core"):
            sw = v["attrs"]["software"]
            fields = {nd["attributes"]["key"]: nd["attributes"]["value"] for nd in nodes_of(v, ["metadata_field"]) if nd["attributes"]["key"] != "requires_dist"}
            rel = one(f"select id from catalog.entity where kind='library_release' and slug={q(slugify(sw + '-' + str(fields.get('version'))))}")
            for nd in nodes_of(v, ["metadata_field"]):
                a = nd["attributes"]
                if a["key"] != "requires_dist" or not rel or a["value"].get("extra") or ";" in a["value"]["raw"] and "extra" in a["value"]["raw"]:
                    continue
                dep = a["value"]["package"]
                target = lib.get(dep) or ensure_entity("library", slugify(dep), dep, {"ecosystem": "pypi", "package_name": dep})
                lib[dep] = target
                b.add(f"select temporal.assert_relationship('depends_on', {q(rel)}, {q(target)}, p_properties => {q({'constraint': a['value']['spec'], 'source': 'PyPI requires_dist', 'raw': a['value']['raw']})});")
                n += 1
        out = b.commit()
        log(f"facts {v['key']}: {n} assertions -> {(out or '-').splitlines()[-1] if out else '-'}")


# ------------------------------------------------------------------ diff across versions of one document (MCP tool manifest)
def stage_diff(vs):
    by = collections.defaultdict(list)
    for v in vs:
        by[v["key"]].append(v)
    for key, vv in by.items():
        if len(vv) < 2:
            continue
        old, new = vv[-2], vv[-1]
        if one(f"select 1 from content.unit_change where to_version_id={q(new['version_id'])} limit 1"):
            continue
        rc = one(f"select id from content.refresh_check where new_version_id={q(new['version_id'])}")
        kinds = ["mcp_tool", "metadata_field", "registry_listing"]
        a = {n["logical_key"]: n for n in nodes_of(old, kinds) if n["logical_key"]}
        b2 = {n["logical_key"]: n for n in nodes_of(new, kinds) if n["logical_key"]}
        changes = []
        for lk, n in b2.items():
            if lk not in a:
                changes.append(("added", lk, n["unit_kind"], None, n["id"], {"to": {k: n["attributes"].get(k) for k in ("name", "toolset", "description")}}))
            else:
                o = a[lk]
                if n["unit_kind"] == "mcp_tool":
                    po, pn = (o["attributes"].get("input_schema") or {}).get("properties") or {}, (n["attributes"].get("input_schema") or {}).get("properties") or {}
                    delta = {}
                    if set(po) != set(pn):
                        delta["parameters"] = {"added": sorted(set(pn) - set(po)), "removed": sorted(set(po) - set(pn))}
                    if sorted(o["attributes"].get("required") or []) != sorted(n["attributes"].get("required") or []):
                        delta["required"] = {"from": sorted(o["attributes"].get("required") or []), "to": sorted(n["attributes"].get("required") or [])}
                    if o["attributes"].get("toolset") != n["attributes"].get("toolset"):
                        delta["toolset"] = {"from": o["attributes"].get("toolset"), "to": n["attributes"].get("toolset")}
                    if delta:
                        changes.append(("attribute_changed", lk, "mcp_tool", o["id"], n["id"], delta))
                    elif sha256_text(o["text"] or "") != sha256_text(n["text"] or ""):
                        changes.append(("text_changed", lk, "mcp_tool", o["id"], n["id"], {"what": "description wording"}))
        for lk, o in a.items():
            if lk not in b2:
                changes.append(("removed", lk, o["unit_kind"], o["id"], None, {"from": {k: o["attributes"].get(k) for k in ("name", "toolset", "description")}}))
        for kind, lk, uk, fn, tn, changed in changes:
            sql(f"insert into content.unit_change(tenant_id, document_id, logical_key, unit_kind, from_version_id, to_version_id, from_node_id, to_node_id, change_kind, changed_attributes, refresh_check_id, update_proposal_state) values ({q(TENANT)}, {q(new['document_id'])}, {q(lk)}, {q(uk)}, {q(old['version_id'])}, {q(new['version_id'])}, {q(fn)}, {q(tn)}, {q(kind)}, {q(changed)}, {q(rc)}, 'none')")
        log(f"diff {key} {old['label']} -> {new['label']}: {dict(collections.Counter(c[0] for c in changes))} (units old={len(a)} new={len(b2)})")


# ------------------------------------------------------------------ projections and embeddings
EMBED3 = {"talk_writeup", "transcript_segment", "slide", "talk_header", "docs_section", "code_example", "readme_section", "release_entry", "change_item", "mcp_tool", "hook_entry", "registry_listing", "api_symbol"}
EMBED_SURFACE_TAGS = {"deepagents==0.7.35", "langchain==1.4.10", "langchain-core==1.7.7"}


def stage_projections(vs):
    counts = collections.Counter()
    for v in vs:
        if not v.get("path"):
            continue
        if v["kind"] == "api_surface" and v["attrs"].get("release_tag") not in EMBED_SURFACE_TAGS:
            continue  # older releases: symbols stay queryable rows (history, diffs); only the latest release of each package is embedded
        tier = L1.TIER_BY_ROLE.get(v["role"], 3)
        prefix = f"[{v['kind']} | {v['title'][:90]} | {v['captured_at'][:10]}] "
        nodes = nodes_of(v, sorted(EMBED3))
        eligible = sum(1 for n in nodes if len((n["text"] or "").strip()) >= 12)
        have = int(one(f"select count(*) from retrieval.vector_item vi where vi.document_version_id={q(v['version_id'])} and vi.content_kind='unit' and vi.lifecycle='active'") or 0)
        if not nodes or have >= 2 * eligible:  # resumable: index_text_item is idempotent, a partly indexed version is completed on the next run
            continue
        roles = collections.defaultdict(list)
        for r in sql_rows(f"select r.node_id, r.entity_id from content.unit_entity_role r join content.document_node n on n.id=r.node_id where n.representation_id={q(v['representation_id'])} order by r.role"):
            roles[r[0]].append(r[1])
        stmts = []
        for n in nodes:
            text = (n["text"] or "").strip()
            if len(text) < 12:
                continue
            ents = roles.get(n["id"]) or []
            args = {"p_entity_id": ents[0] if ents else None, "p_secondary_entity_ids": ents[1:6], "p_document_type_code": v["kind"], "p_unit_kind": n["unit_kind"], "p_document_id": v["document_id"], "p_document_version_id": v["version_id"], "p_source_role_code": v["role"],
                    "p_observed_at": v["captured_at"], "p_start_ms": n.get("start_ms"), "p_end_ms": n.get("end_ms"), "p_contextual_prefix": prefix}
            named = ", ".join(f"{k} => {qarr(val, 'uuid') if k == 'p_secondary_entity_ids' else q(val)}" for k, val in args.items() if val not in (None, [], ""))
            for space in ("units", "knowledge_text"):
                stmts.append(f"select retrieval.index_text_item({q(space)}, 'unit', {q(n['id'])}, {q(text[:2000])}, 'corpus', {tier}::smallint, 'unit', {named});")
            counts["units"] += 1
        for i in range(0, len(stmts), 120):
            sql("\n".join(stmts[i:i + 120]))
        log(f"projected {v['key']} {v['label']}: {len(stmts) // 2} units")
    # digest items: one item = one vector item (target digest_item); legacy digest-target items are retired once their items are re-indexed
    items = sql_json(f"""select json_build_object('id', i.id, 'text', i.text, 'kind', i.item_kind, 'entity', i.entity_id, 'version', g.document_version_id, 'doc', dv.document_id, 'kind_code', d.document_type_code, 'role', d.source_role_code, 'title', d.canonical_title,
                           'scope', g.scope, 'heading', (select sn.attributes->>'heading' from content.document_node sn where sn.id = g.scope_node_id),
                           'start_ms', (select min(n.start_ms) from content.document_node n where n.id = any(i.node_ids)), 'end_ms', (select max(coalesce(n.end_ms, n.start_ms)) from content.document_node n where n.id = any(i.node_ids)))
                          from content.digest_item i join content.document_digest g on g.id=i.digest_id join content.document_version dv on dv.id=g.document_version_id join content.document d on d.id=dv.document_id
                         where i.tenant_id={q(TENANT)} and i.text is not null and g.lifecycle='active'
                           and not exists (select 1 from retrieval.projection_target pt join retrieval.vector_item vi on vi.projection_target_id = pt.id where pt.digest_item_id = i.id and vi.lifecycle = 'active')""")
    stmts = []
    for r in items:
        text = f"[{r['kind']} of {r['title'][:90]}{' / ' + r['heading'][:60] if r.get('heading') else ''}] {r['text']}"
        args = {"p_entity_id": r["entity"], "p_document_type_code": r["kind_code"], "p_document_id": r["doc"], "p_document_version_id": r["version"], "p_source_role_code": r["role"], "p_start_ms": r.get("start_ms"), "p_end_ms": r.get("end_ms")}
        named = ", ".join(f"{k} => {q(val)}" for k, val in args.items() if val is not None)
        for space in ("digests", "knowledge_text"):
            stmts.append(f"select retrieval.index_text_item({q(space)}, 'digest_item', {q(r['id'])}, {q(text[:2000])}, 'corpus', {L1.TIER_BY_ROLE.get(r['role'], 3)}::smallint, 'digest', {named});")
        counts["digest_items"] += 1
    for i in range(0, len(stmts), 120):
        sql("\n".join(stmts[i:i + 120]))
    retired = one("""with u as (update retrieval.vector_item vi set lifecycle = 'retired' from retrieval.projection_target pt where pt.id = vi.projection_target_id and pt.target_kind = 'digest' and vi.lifecycle = 'active' returning 1) select count(*) from u""")
    counts["legacy_digest_items_retired"] = int(retired or 0)
    # entity cards for entities created or changed in loop 3; claims created in loop 3
    for r in sql_json(f"""select json_build_object('id', e.id, 'kind', e.kind, 'name', e.display_name, 'attrs', e.attributes) from catalog.entity e where e.tenant_id={q(TENANT)} and e.lifecycle='active' and (e.created_at > '2026-11-10T22:00:00Z' or e.updated_at > '2026-11-10T22:00:00Z')"""):
        rels = sql_rows(f"select r.kind, x.display_name from catalog.relationship r join catalog.entity x on x.id = case when r.from_entity_id={q(r['id'])} then r.to_entity_id else r.from_entity_id end where (r.from_entity_id={q(r['id'])} or r.to_entity_id={q(r['id'])}) and r.k_to is null limit 25")
        card = f"{r['name']} ({r['kind'].replace('_', ' ')}). " + "; ".join(f"{k.replace('_', ' ')}: {val}" for k, val in (r["attrs"] or {}).items() if val not in (None, "", [], {}))[:900] + (". Related: " + "; ".join(f"{a} {b_}" for a, b_ in rels) if rels else "")
        for space in ("entity_cards", "knowledge_text"):
            L1.index_item(space, "entity", r["id"], card[:2000], "corpus", 2, "profile", entity_id=r["id"])
        counts["entity_cards"] += 1
    for r in sql_json(f"""select json_build_object('id', c.id, 'statement', c.statement, 'structured', c.structured, 'status', c.status::text, 'subject', (select entity_id from evidence.claim_subject s where s.claim_id=c.id limit 1)) from evidence.claim c
                          where c.tenant_id={q(TENANT)} and c.created_at > '2026-11-10T22:00:00Z'"""):
        role = (r["structured"] or {}).get("source_role", "first_party")
        tier = L1.TIER_BY_ROLE.get(role, 2)
        for space in ("assertions", "knowledge_text"):
            L1.index_item(space, "claim", r["id"], f"[{r['status']} claim] {r['statement']}", "evidence", tier, "claim", entity_id=r["subject"], assurance_rank=10 if r["status"] == "proposed" else 20)
        counts["claims"] += 1
    log(f"projections: {dict(counts)}; vector items active = {one('select count(*) from retrieval.vector_item where lifecycle=' + q('active'))}")
    write_json(os.path.join(RUN3, "projection-counts.json"), dict(counts))


def stage_embed():
    C.RUN_DIR = RUN3
    L1.RUN_DIR = RUN3
    L1.stage_embed()
    os.replace(os.path.join(RUN3, "spend-process.json"), os.path.join(RUN3, f"spend-embed-{now_iso().replace(':', '')}.json"))


STAGES = {"census": stage_census, "units": stage_units, "units_supplement": stage_units_supplement, "entities": stage_entities, "links": stage_links, "facts": stage_facts, "diff": stage_diff, "projections": stage_projections}
ORDER = ["census", "units", "units_supplement", "entities", "links", "facts", "diff", "projections", "embed"]

if __name__ == "__main__":
    wanted = sys.argv[1:] or ORDER
    vs = versions()
    log(f"{len(vs)} loop-3 versions ({sum(1 for v in vs if v.get('path'))} with local files)")
    for st in ORDER:
        if st not in wanted:
            continue
        if st == "embed":
            stage_embed()
        else:
            STAGES[st](vs)
