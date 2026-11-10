"""Build 08 loop 2: shape-specific grammars added after inspecting the 2026-11-09 captures (SEAL text board, RunPod sentences,
CoreWeave div/span cells, Modal per-second rates, E2B quantity tables, Artificial Analysis metric tables, Epoch zip driven by its
benchmark_metadata.csv, OWASP ASI items). Pure functions; same unit dict shape as loop1_parse. Grammar version build08-grammar/2.
"""
import csv, io, json, re, zipfile
from loop2_parse import clean, col, num, sha, DEVICE_HINTS, EFFORT


def grammar_seal_text(text, stats):
    """labs.scale.com board renders as text: a model line, a blank, then 'score±ci'; asterisk marks the mini-swe-agent harness."""
    out = []
    ls = text.splitlines()
    n = 0
    for i, l in enumerate(ls):
        m = re.match(r"^(\d{1,2}\.\d{2})±(\d+\.\d+)$", l.strip())
        if not m:
            continue
        prev = next((ls[j].strip() for j in range(i - 1, max(-1, i - 4), -1) if ls[j].strip()), None)
        if not prev or len(prev) > 80:
            continue
        n += 1
        subj = prev.rstrip("*").strip()
        eff = EFFORT.search(subj)
        effort = eff.group(1).lower() if eff and eff.group(1) else None
        subj_clean = EFFORT.sub("", subj).strip(" ()")
        val, ci = float(m.group(1)), float(m.group(2))
        attrs = {"rank": n, "subject_name": subj_clean, "score": val, "unit": "percent", "benchmark": "SWE-Bench Pro", "benchmark_version": "SWE-Bench Pro (public)", "harness": "mini-swe-agent" if prev.endswith("*") else None, "reported_by": "organizer", "effort": effort, "ci_low": val - ci, "ci_high": val + ci}
        attrs = {k: v for k, v in attrs.items() if v not in (None, "")}
        out.append(dict(kind="leaderboard_row", key=f"seal:{n}", parent=None, attrs=attrs, text=f"{prev} {l.strip()}", logical=f"leaderboard_row:SWE-Bench Pro (public)|{subj_clean}|{attrs.get('harness') or ''}|{effort or ''}", start=None, end=None, selector={"kind": "text_quote", "exact": (prev + " " + l.strip())[:200]}, roles={"subject": [subj_clean], "benchmark": ["SWE-Bench Pro (public)"]}))
    stats["leaderboard_rows"] = n
    return out


def grammar_runpod_sentences(text, stats):
    out = []
    n = 0
    for m in re.finditer(r"rents the ([A-Z0-9 ]+?) at \$(\d+\.\d+)/hr on Secure Cloud(?:, or from \$(\d+\.\d+)/hr on Community Cloud)?", text):
        gpu = m.group(1).strip()
        dev = DEVICE_HINTS.search(gpu)
        for tier, amt in (("secure", m.group(2)), ("community", m.group(3))):
            if not amt:
                continue
            n += 1
            offering = f"runpod:{gpu}"
            commitment = "spot" if tier == "community" else "on_demand"
            out.append(dict(kind="price_row", key=f"rp:{n}", parent=None, attrs={"offering": offering, "meter": "gpu_hour", "amount": float(amt), "currency": "USD", "unit": "USD_per_GPU_hour", "commitment": commitment, "per": "gpu", "gpu_count": 1, "tier": tier, "condition": f"{tier} cloud, per-second billing", "device": dev.group(1).upper() if dev else gpu},
                            text=m.group(0), logical=f"price_row:{offering}|gpu_hour|{tier}||{commitment}", start=m.start(), end=m.end(), selector={"kind": "text_quote", "exact": m.group(0)[:200]}, roles={"offering": [offering], "provider": ["runpod"], "device": [dev.group(1).upper() if dev else gpu]}))
    stats["price_rows"] = n
    return out


def grammar_coreweave_html(raw, stats):
    """CoreWeave renders prices in div/span cells: h3.table-model-name then 'On-Demand Price: $49.24 / Hour' and 'Spot Price: ...'."""
    out = []
    n = 0
    seen = set()
    for m in re.finditer(r'class="table-model-name">([^<]+)</h3>(.*?)(?=class="table-model-name">|$)', raw, re.S):
        name = clean(m.group(1))
        block = m.group(2)
        region = "EU" if re.search(r"europe|\bEU\b", block[:600], re.I) else "NA"
        for label, commitment in (("On-Demand Price", "on_demand"), ("Spot Price", "spot")):
            pm = re.search(re.escape(label) + r':\s*<span class="item-value">\$?([\d,]+\.\d\d)</span>', block)
            if not pm:
                continue
            amt = float(pm.group(1).replace(",", ""))
            key = (name, commitment, amt, region)
            if key in seen:
                continue
            seen.add(key)
            n += 1
            gpus = 4 if "NVL72" in name else 8
            dev = DEVICE_HINTS.search(name)
            device = dev.group(1).upper() if dev else name
            offering = f"coreweave:{name}"
            out.append(dict(kind="price_row", key=f"cw:{n}", parent=None, attrs={"offering": offering, "meter": "node_hour", "amount": amt, "currency": "USD", "unit": "USD_per_node_hour", "commitment": commitment, "per": "node", "gpu_count": gpus, "region": region, "condition": f"{label} / Hour", "device": device},
                            text=f"{name}: {label} ${amt} / Hour ({region})", logical=f"price_row:{offering}|node_hour|standard|{region}|{commitment}", start=m.start(), end=m.start() + len(m.group(0)), selector={"kind": "html", "css": "h3.table-model-name", "exact": name}, roles={"offering": [offering], "provider": ["coreweave"], "device": [device]}))
    stats["price_rows"] = n
    return out


def grammar_modal_text(text, stats):
    """Modal: '- Nvidia H100 SXM5 $0.001097 0.001097 / sec' -> stated $/s and the derived $/GPU-hour (meter gpu_hour)."""
    out = []
    n = 0
    for m in re.finditer(r"Nvidia ([A-Z][A-Za-z0-9 ]+?) \$(\d+\.\d+)\s+[\d.]+ / sec", text):
        gpu, amt = m.group(1).strip(), float(m.group(2))
        n += 1
        offering = f"modal:{gpu}"
        dev = DEVICE_HINTS.search(gpu)
        device = dev.group(1).upper() if dev else gpu
        out.append(dict(kind="price_row", key=f"md:{n}", parent=None, attrs={"offering": offering, "meter": "gpu_hour", "amount": round(amt * 3600, 4), "currency": "USD", "unit": "USD_per_GPU_hour", "commitment": "on_demand", "per": "gpu", "gpu_count": 1, "condition": f"serverless, billed per second at ${amt}/s (hourly derived)", "device": device},
                        text=m.group(0), logical=f"price_row:{offering}|gpu_hour|standard||on_demand", start=m.start(), end=m.end(), selector={"kind": "text_quote", "exact": m.group(0)}, roles={"offering": [offering], "provider": ["modal"], "device": [device]}))
    stats["price_rows_gpu"] = n
    return out


def grammar_e2b_tables(tables, lines, offs, stats):
    out = []
    n = 0
    for ti, (s, header, rows, e) in enumerate(tables):
        hdr = [clean(h).lower() for h in header]
        if not hdr or not re.search(r"vcpu|memory|gib|disk", hdr[0]):
            continue
        meter = "vcpu_second" if "vcpu" in hdr[0] else ("gib_second" if re.search(r"memory|gib", hdr[0]) and "disk" not in hdr[0] else "disk_gib_second")
        for ri, (cells, ln) in enumerate(rows):
            cells = [clean(c) for c in cells]
            if len(cells) < 3:
                continue
            qty = num(cells[0])
            amt = num(cells[2]) if "$" in cells[2] else None
            if not qty or amt is None:
                continue
            n += 1
            plan = cells[1].lower().replace(" / ", "_").replace(" ", "_")[:40]
            out.append(dict(kind="price_row", key=f"e2b:{ti + 1}:{ri + 1}", parent=f"tbl:{ti + 1}", attrs={"offering": "e2b:sandbox", "meter": meter, "amount": round(amt / qty, 9), "currency": "USD", "unit": {"vcpu_second": "USD_per_vcpu_second", "gib_second": "USD_per_GiB_second"}.get(meter, "USD_per_GiB_second"), "commitment": "on_demand", "per": "unit", "tier": plan, "condition": f"{cells[0]} {hdr[0]} at {cells[2]}", "section": hdr[0]},
                            text=" | ".join(cells), logical=f"price_row:e2b:sandbox|{meter}|{plan}||on_demand", start=offs[ln] if ln < len(offs) else None, end=None, selector={"kind": "table", "table": ti + 1, "row": ri + 1}, roles={"offering": ["e2b:sandbox"], "provider": ["e2b"]}))
            break  # the quantity-1 row fixes the unit price; the other rows are multiples
    stats["price_rows"] = n
    return out


def grammar_metric_definitions(tables, lines, offs, stats):
    """Artificial Analysis methodology tables: Category | Evaluation | Questions | Repeats | Response Type | Scoring | Weighting | Tool Usage | Private."""
    out = []
    n = 0
    for ti, (s, header, rows, e) in enumerate(tables):
        hdr = [clean(h) for h in header]
        i_name = col(hdr, "evaluation", "benchmark")
        i_scoring = col(hdr, "scoring")
        if i_name is None or i_scoring is None:
            continue
        i_q = col(hdr, "questions", "tasks")
        i_w = col(hdr, "weighting", "weight")
        for ri, (cells, ln) in enumerate(rows):
            cells = [clean(c) for c in cells]
            if len(cells) <= max(i_name, i_scoring) or not cells[i_name]:
                continue
            name = cells[i_name]
            if re.match(r"^\d", name) or len(name) < 3:
                continue
            ver = re.search(r"\bv?\d+(?:\.\d+)+\b", name)
            n += 1
            out.append(dict(kind="metric_definition", key=f"mdef:{ti + 1}:{ri + 1}", parent=f"tbl:{ti + 1}", attrs={"name": re.sub(r"\s*v?\d+(?:\.\d+)+\s*$", "", name).strip() or name, "version": ver.group(0) if ver else None, "scale": cells[i_q] if i_q is not None and i_q < len(cells) else None, "formula": cells[i_scoring][:300], "description": f"weight {cells[i_w]}" if i_w is not None and i_w < len(cells) else None, "higher_is_better": True},
                            text=" | ".join(cells)[:1200], logical=f"metric_definition:{name}", start=offs[ln] if ln < len(offs) else None, end=None, selector={"kind": "table", "table": ti + 1, "row": ri + 1}, roles={"benchmark": [name]}))
    stats["metric_definitions"] = n
    return out


def grammar_epoch_zip_v2(raw, stats, cap=700):
    """Epoch benchmark_data.zip driven by benchmark_metadata.csv (source_file + score_column); internal files are Epoch runs, *_external files carry a Source column."""
    out = []
    zf = zipfile.ZipFile(io.BytesIO(raw))
    meta = list(csv.DictReader(io.StringIO(zf.read("benchmark_metadata.csv").decode("utf-8", "replace"))))
    names = {}
    if "model_metadata.csv" in zf.namelist():
        for r in csv.DictReader(io.StringIO(zf.read("model_metadata.csv").decode("utf-8", "replace"))):
            if r.get("model_version") and r.get("display_name"):
                names[r["model_version"]] = r["display_name"]
    want = re.compile(r"swe|terminal|gpqa|frontiermath|aime|hle|humanity|osworld|os_world|arc|frontiercode|frontierswe|cursorbench|mmlu", re.I)
    priority = lambda m: (0 if re.search(r"swe|terminal|osworld|os_world|arc|hle|humanity", (m.get("benchmark") or "") + (m.get("source_file") or ""), re.I) else 1, m.get("source_file") or "")
    meta.sort(key=priority)
    n = 0
    per_file_cap = 90
    for mrow in meta:
        bench, file, score_col = mrow.get("benchmark"), mrow.get("source_file"), mrow.get("score_column")
        if not (bench and file and score_col) or not want.search(bench + " " + file) or file not in zf.namelist():
            continue
        rd = csv.DictReader(io.StringIO(zf.read(file).decode("utf-8", "replace")))
        fields = rd.fieldnames or []
        if score_col not in fields:
            stats.setdefault("epoch_missing_score_column", []).append({"file": file, "score_column": score_col})
            continue
        internal = "_external" not in file
        f_src = next((f for f in fields if f.lower() in ("source", "source link", "source link (site from table)", "source_link")), None)
        f_h = next((f for f in fields if f.lower() in ("agent", "harness", "scaffold", "tool setting")), None)
        f_eff = next((f for f in fields if f.lower() in ("reasoning effort", "reasoning", "reasoning level")), None)
        f_se = next((f for f in fields if re.search(r"stderr|standard error|\bse$|95% ci half-width", f.lower())), None)
        f_run = next((f for f in fields if f.lower() in ("run date", "date of evaluation", "evaluation date", "started at", "date", "created")), None)
        f_cost = next((f for f in fields if "cost" in f.lower()), None)
        scale = (mrow.get("scale") or "").lower()
        rows_sorted = sorted(enumerate(rd), key=lambda ir: (ir[1].get("Release date") or ""), reverse=True)[:per_file_cap]
        for i, r in rows_sorted:
            val = num(r.get(score_col))
            model_id = clean(r.get("Model version") or r.get("Model") or r.get("model"))
            model = names.get(model_id) or model_id
            if val is None or not model:
                continue
            fraction = scale in ("fraction", "proportion", "0-1", "0..1") or (val <= 1.0 and scale not in ("percent", "percentage") and not re.search(r"elo|arena|horizon", bench, re.I))
            val_pct = round(val * 100, 3) if fraction else val
            n += 1
            if n > cap:
                break
            src = "Epoch AI internal run" if internal else (clean(r.get(f_src)) if f_src else "external (source column absent)")
            reported = "third_party" if internal else ("self_reported" if re.search(r"self|developer|provider|announc|blog|system card|model card", src, re.I) else "third_party")
            se = num(r.get(f_se)) if f_se else None
            se_pct = (se * 100 if fraction and se is not None and se <= 1 else se) if se is not None else None
            attrs = {"subject_name": model, "model_id": model_id, "score": val_pct, "unit": "percent" if val_pct <= 100 and not re.search(r"elo|horizon", bench, re.I) else "score", "benchmark": bench, "benchmark_version": bench, "harness": clean(r.get(f_h)) if f_h else None, "effort": clean(r.get(f_eff)) if f_eff else None, "reported_by": reported, "source_label": src[:160],
                     "run_date": clean(r.get(f_run)) if f_run else None, "release_date": clean(r.get("Release date")), "organization": clean(r.get("Organization")), "cost_usd": num(r.get(f_cost)) if f_cost else None, "ci_low": (val_pct - se_pct) if se_pct is not None else None, "ci_high": (val_pct + se_pct) if se_pct is not None else None, "notes": f"file={file}; score_column={score_col}; scale={mrow.get('scale')}"}
            attrs = {k: v for k, v in attrs.items() if v not in (None, "")}
            out.append(dict(kind="leaderboard_row", key=f"epoch:{sha(file)[:6]}:{i + 1}", parent=None, attrs=attrs, text=json.dumps({k: r.get(k) for k in ("Model version", score_col, "Release date", "Organization", f_src, f_h, f_run) if k and r.get(k)}, ensure_ascii=False)[:1200],
                            logical=f"leaderboard_row:{bench}|{model}|{attrs.get('harness') or ''}|{attrs.get('effort') or ''}|{src[:40]}", start=None, end=None, selector={"kind": "dataset", "file": file, "row": i + 1}, roles={"subject": [model], "benchmark": [bench], "harness": [attrs.get("harness")] if attrs.get("harness") else []}))
    stats["epoch_rows"] = n
    stats["epoch_benchmarks"] = sorted({u["attrs"]["benchmark"] for u in out})
    return out


def grammar_owasp(text, stats):
    """OWASP Top 10 for Agentic Applications: 'ASI0n: Title' heading followed by a 'Description' block up to 'Common Examples'."""
    cands = []
    for m in re.finditer(r"(ASI(\d{2})): ([^\n]{4,80}?)\s*\n\s*(?:\n\s*)*Description\s*\n(.*?)(?=\n\s*Common Examples|\n\s*Example Attack|\Z)", text, re.S):
        code = m.group(1)
        if any(c["code"] == code for c in cands):
            continue
        title = re.sub(r"\s+", " ", m.group(3)).strip()
        statement = re.sub(r"\s+", " ", m.group(4)).strip()[:900]
        if len(statement) < 40:
            continue
        cands.append({"code": code, "kind": "security_consideration", "title": f"{code} {title}", "statement": statement, "pos": m.start()})
    cands.sort(key=lambda c: c["code"])
    stats["guidance_candidates"] = len(cands)
    return cands


def grammar_sandbox_table(tables, lines, offs, provider, stats):
    """Docs tables of the form 'Sandbox Active CPU | included | $0.128/hour | $0.128/hour' -> price rows per meter (Pro column when present)."""
    out = []
    n = 0
    for ti, (s, header, rows, e) in enumerate(tables):
        for ri, (cells, ln) in enumerate(rows):
            cells = [clean(c) for c in cells]
            if len(cells) < 3 or not re.search(r"cpu|memory|creation|snapshot|storage|transfer|read|write", cells[0], re.I):
                continue
            price_cells = [c for c in cells[1:] if "$" in c and "/" in c]
            if not price_cells:
                continue
            c = price_cells[-1]
            pm = re.search(r"\$(\d+(?:\.\d+)?)\s*/\s*([A-Za-z0-9\- ]+)", c)
            if not pm:
                continue
            amt, per = float(pm.group(1)), pm.group(2).strip().lower()
            label = cells[0].lower()
            meter = ("vcpu_hour" if "cpu" in label else "gib_hour" if "memory" in label else "creations_per_million" if "creation" in label else "snapshot_storage_month" if "snapshot" in label else "drive_storage_month" if "drive storage" in label else "data_transfer_gb" if "transfer" in label else label.replace(" ", "_"))
            unit = {"vcpu_hour": "USD_per_vcpu_hour", "gib_hour": "USD_per_GB_hour", "creations_per_million": "USD_per_1M_creations", "snapshot_storage_month": "USD_per_GB_month", "drive_storage_month": "USD_per_GB_month", "data_transfer_gb": "USD_per_GB"}.get(meter, "USD_per_GB")
            n += 1
            offering = f"{provider}:sandbox"
            out.append(dict(kind="price_row", key=f"sbt:{ti + 1}:{ri + 1}", parent=f"tbl:{ti + 1}", attrs={"offering": offering, "meter": meter, "amount": amt, "currency": "USD", "unit": unit, "commitment": "on_demand", "per": "unit", "tier": "pro" if len(price_cells) > 1 else None, "condition": f"{cells[0]}: {c}", "section": None},
                            text=" | ".join(cells)[:400], logical=f"price_row:{offering}|{meter}|{'pro' if len(price_cells) > 1 else 'standard'}||on_demand", start=offs[ln] if ln < len(offs) else None, end=None, selector={"kind": "table", "table": ti + 1, "row": ri + 1}, roles={"offering": [offering], "provider": [provider]}))
    stats["price_rows"] = stats.get("price_rows", 0) + n
    return out
