"""Build 08 knowledge loop 2: grammars for the new kinds (pure functions, no database). Grammar version build08-grammar/2.

Unit dict shape is loop 1's: kind, attrs, text, parent, key, logical, start/end, selector, roles. Everything here reads captures as data.
Grammars are header-driven and tolerant: a table whose header does not match yields no typed units (the universal units remain),
and every grammar reports how many rows it kept and dropped through the `stats` dict it fills.
"""
import csv, io, json, re, zipfile
import loop1_parse as P1
from loop1_parse import sha, universal_markdown, html_to_text, PRICE_RE

GRAMMAR = "build08-grammar/2"
PCT = re.compile(r"(-?\d+(?:\.\d+)?)\s*%")
NUM = re.compile(r"-?\d+(?:,\d{3})*(?:\.\d+)?")
BENCH_WORDS = re.compile(r"(%|\bMATH|GSM8K|IFEval|MMLU|HumanEval|GPQA|AIME|SWE|Terminal|OSWorld|ARC-AGI|HLE|Bench|Eval|Arena|LiveCode|Breakout|MinAtar|score)", re.I)
MODEL_WORDS = re.compile(r"(claude|gpt|gemini|grok|deepseek|qwen|llama|mistral|muse|inkling|o\d\b|sonnet|opus|haiku|fable|mythos|astra|sol\b|terra|luna|kimi|glm|minimax|nova|command|phi\b)", re.I)
EFFORT = re.compile(r"\((max|xhigh|high|medium|low|none|thinking|minimal)\)|\b(max|xhigh|high|medium|low)\b$", re.I)


def num(s):
    if s is None:
        return None
    m = NUM.search(str(s).replace("$", ""))
    return float(m.group(0).replace(",", "")) if m else None


def clean(s):
    return re.sub(r"\s+", " ", re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", str(s or ""))).strip()


def col(header, *names):
    """index of the first header cell containing any of the names (case-insensitive substring)."""
    low = [clean(h).lower() for h in header]
    for n in names:
        for i, h in enumerate(low):
            if (n == "#" and h.strip() == "#") or (n != "#" and re.search(r"(?<![a-z0-9])" + re.escape(n) + r"(?![a-z0-9])", h)):
                return i
    return None


def table_section(units, tkey):
    t = next((u for u in units if u["key"] == tkey), None)
    if t and t.get("parent"):
        s = next((u for u in units if u["key"] == t["parent"]), None)
        if s:
            return s["attrs"].get("path") or s["attrs"].get("heading") or ""
    return ""


# ------------------------------------------------------------------ RV07 leaderboards (markdown/html tables)
BOARD = {
    # board slug: benchmark, default version, score unit, extra condition columns
    "swe-bench": dict(benchmark="SWE-bench", version="SWE-bench Verified", unit="percent", harness_cols=("agent", "scaffold"), reported_by="organizer"),
    "terminal-bench": dict(benchmark="Terminal-Bench", version="Terminal-Bench 4.1", unit="percent", harness_cols=("agent", "harness"), reported_by="organizer"),
    "arc-agi": dict(benchmark="ARC-AGI", version=None, unit="percent", harness_cols=(), reported_by="organizer", multi_score=True),
    "swe-bench-pro-public": dict(benchmark="SWE-Bench Pro", version="SWE-Bench Pro (public)", unit="percent", harness_cols=("harness", "agent"), reported_by="organizer"),
    "osworld": dict(benchmark="OSWorld", version="OSWorld 2.1", unit="percent", harness_cols=("tool mode", "tool setting"), reported_by="organizer"),
    "arena-text": dict(benchmark="Arena text", version="Arena text (Elo-style preference)", unit="elo", harness_cols=(), reported_by="organizer", score_type="elo_preference"),
}


def grammar_leaderboard(units, tables, lines, offs, board, stats):
    cfg = BOARD.get(board)
    out = []
    if not cfg:
        return out
    n = 0
    for ti, (s, header, rows, e) in enumerate(tables):
        hdr = [clean(h) for h in header]
        i_subj = col(hdr, "model", "system", "ai system", "agent name", "name", "submission")
        i_rank = col(hdr, "rank", "#")
        score_cols = [i for i, h in enumerate(hdr) if re.search(r"resolved|score|accuracy|acc\.|%|rate|arc-agi|elo|binary|partial|pass", h, re.I) and i != i_subj]
        if i_subj is None or not score_cols:
            continue
        i_h = next((col(hdr, c) for c in cfg["harness_cols"] if col(hdr, c) is not None), None)
        i_date = col(hdr, "date", "release")
        i_cost = col(hdr, "cost", "$")
        i_org = col(hdr, "org", "creator", "lab")
        i_votes = col(hdr, "votes")
        i_ci = col(hdr, "ci", "±", "+/-")
        i_effort = col(hdr, "effort", "reasoning")
        i_mode = col(hdr, "tool mode", "tool setting", "tool")
        i_ver = col(hdr, "version", "release version")
        sec = table_section(units, f"tbl:{ti + 1}")
        for ri, (cells, ln) in enumerate(rows):
            cells = [clean(c) for c in cells]
            if len(cells) <= max(i_subj, max(score_cols)):
                continue
            subj = cells[i_subj]
            if not subj or len(subj) > 120 or subj.lower() in ("model", "system"):
                continue
            effort = None
            m = EFFORT.search(subj) or re.search(r"(?<=[a-z])(max|xhigh|high|medium|low)$", subj)
            if m:
                effort = (m.group(1) or (m.group(2) if m.lastindex and m.lastindex >= 2 else None) or m.group(0)).lower().strip("()")
                subj_clean = re.sub(r"(?<=[a-z])(max|xhigh|high|medium|low)$", "", EFFORT.sub("", subj)).strip(" ()")
            else:
                subj_clean = subj
            i_rel = col(hdr, "release") if board == "swe-bench" else None
            if i_effort is not None and i_effort < len(cells) and cells[i_effort]:
                effort = cells[i_effort].lower()
            for sc in score_cols:
                raw = cells[sc]
                val = num(raw)
                if val is None:
                    continue
                bench = cfg["version"] or hdr[sc]
                if cfg.get("multi_score"):
                    if re.fullmatch(r"score|cost", hdr[sc].strip(), re.I):
                        continue
                    bench = re.sub(r"v\d(?:\s*·.*)?$", "", hdr[sc]).strip()
                if i_ver is not None and i_ver < len(cells) and cells[i_ver]:
                    bench = f"{cfg['benchmark']} {cells[i_ver]}"
                ci = None
                mci = re.search(r"±\s*(\d+(?:\.\d+)?)|\+/-\s*(\d+(?:\.\d+)?)", raw)
                if mci:
                    ci = float(mci.group(1) or mci.group(2))
                elif i_ci is not None and i_ci < len(cells):
                    ci = num(cells[i_ci])
                n += 1
                attrs = {"rank": int(num(cells[i_rank])) if i_rank is not None and i_rank < len(cells) and num(cells[i_rank]) is not None else ri + 1, "subject_name": subj_clean, "score": val, "unit": cfg["unit"],
                         "benchmark": cfg["benchmark"], "benchmark_version": bench, "harness": cells[i_h] if i_h is not None and i_h < len(cells) and cells[i_h] else None, "reported_by": cfg["reported_by"],
                         "run_date": cells[i_date] if i_date is not None and i_date < len(cells) and re.search(r"\d{4}", cells[i_date] or "") else None, "cost_usd": num(cells[i_cost]) if i_cost is not None and i_cost < len(cells) else None,
                         "organization": cells[i_org] if i_org is not None and i_org < len(cells) and not re.match(r"^[!\[]|^$", cells[i_org]) else None, "votes": int(num(cells[i_votes])) if i_votes is not None and i_votes < len(cells) and num(cells[i_votes]) is not None else None,
                         "effort": effort, "tool_mode": cells[i_mode] if i_mode is not None and i_mode < len(cells) else None, "ci_low": (val - ci) if ci is not None else None, "ci_high": (val + ci) if ci is not None else None,
                         "source_label": sec or None, "notes": hdr[sc] if cfg.get("multi_score") else None, "harness_version": cells[i_rel] if i_rel is not None and i_rel < len(cells) and cells[i_rel] not in ("-", "") else None}
                attrs = {k: v for k, v in attrs.items() if v not in (None, "")}
                out.append(dict(kind="leaderboard_row", key=f"lb:{ti + 1}:{ri + 1}:{sc}", parent=f"tbl:{ti + 1}", attrs=attrs, text=" | ".join(cells)[:1500], logical=f"leaderboard_row:{bench}|{subj_clean}|{attrs.get('harness') or ''}|{effort or ''}", start=offs[ln] if ln < len(offs) else None, end=(offs[ln] + len(lines[ln])) if ln < len(lines) else None,
                                selector={"kind": "table", "table": ti + 1, "row": ri + 1, "column": sc, "header": hdr}, roles={"subject": [subj_clean], "benchmark": [bench], "harness": [attrs.get("harness")] if attrs.get("harness") else []}))
    stats["leaderboard_rows"] = n
    return out


def grammar_mlperf_csv(text, stats, cap=240):
    """MLPerf summary.csv: one row per (system, model, scenario) result; keep closed-division LLM rows."""
    out = []
    rd = csv.DictReader(io.StringIO(text))
    n = 0
    for i, r in enumerate(rd):
        model = (r.get("MlperfModel") or r.get("Model") or "")
        if not re.search(r"llama|gpt|deepseek|mixtral|whisper|stable-diffusion|retinanet|resnet|dlrm", model, re.I):
            continue
        if (r.get("Division") or "").lower() != "closed":
            continue
        val = num(r.get("Result"))
        if val is None:
            continue
        n += 1
        if n > cap:
            break
        subj = r.get("SystemName") or r.get("Platform") or "system"
        unit_raw = (r.get("Units") or "").strip().lower()
        unit = "tokens_per_second" if "token" in unit_raw else ("samples_per_second" if "sample" in unit_raw else ("ms" if "ms" in unit_raw or "latency" in unit_raw else "count"))
        attrs = {"subject_name": subj[:120], "score": val, "unit": unit, "benchmark": "MLPerf Inference", "benchmark_version": "MLPerf Inference v6.1 (datacenter)", "scenario": r.get("Scenario"), "model": model,
                 "organization": r.get("Organization"), "accelerator": r.get("accelerator_model_name") or r.get("Accelerator"), "accelerators_per_node": int(num(r.get("accelerators_per_node"))) if num(r.get("accelerators_per_node")) is not None else None,
                 "system_name": subj, "reported_by": "organizer", "notes": f"availability={r.get('Availability')}; accuracy={r.get('Accuracy')}"}
        attrs = {k: v for k, v in attrs.items() if v not in (None, "")}
        out.append(dict(kind="leaderboard_row", key=f"mlperf:{i + 1}", parent=None, attrs=attrs, text=json.dumps({k: r.get(k) for k in ("Organization", "SystemName", "MlperfModel", "Scenario", "Result", "Units", "accelerator_model_name", "accelerators_per_node") if r.get(k)}, ensure_ascii=False)[:1500],
                        logical=f"leaderboard_row:mlperf-6.1|{subj}|{model}|{r.get('Scenario')}", start=None, end=None, selector={"kind": "dataset", "row": i + 1}, roles={"subject": [subj], "system": [subj], "benchmark": ["MLPerf Inference v6.1 (datacenter)"], "publisher": [r.get("Organization")]}))
    stats["mlperf_rows"] = n
    return out


def grammar_epoch_zip(raw, stats, cap=600):
    """Epoch AI benchmark_data.zip: find the CSV with model/benchmark/score columns; one leaderboard_row per external or internal run."""
    out = []
    try:
        zf = zipfile.ZipFile(io.BytesIO(raw))
    except Exception:
        stats["epoch_error"] = "not a zip"
        return out
    files = [n for n in zf.namelist() if n.lower().endswith(".csv")]
    stats["epoch_files"] = files[:20]
    n = 0
    for name in files:
        text = zf.read(name).decode("utf-8", "replace")
        rd = csv.DictReader(io.StringIO(text))
        fields = [f.lower() for f in (rd.fieldnames or [])]
        f_model = next((f for f in rd.fieldnames or [] if f.lower() in ("model", "model name", "model_name", "system")), None)
        f_bench = next((f for f in rd.fieldnames or [] if "benchmark" in f.lower() or f.lower() in ("task", "dataset")), None)
        f_score = next((f for f in rd.fieldnames or [] if f.lower() in ("score", "best score", "best_score", "accuracy", "result", "mean score", "value")), None)
        if not (f_model and f_score):
            stats.setdefault("epoch_skipped", []).append({"file": name, "fields": (rd.fieldnames or [])[:12]})
            continue
        f_date = next((f for f in rd.fieldnames or [] if "date" in f.lower()), None)
        f_src = next((f for f in rd.fieldnames or [] if f.lower() in ("source", "source link", "source_link", "run source", "run type", "source type")), None)
        f_ci = next((f for f in rd.fieldnames or [] if "stderr" in f.lower() or "std" in f.lower() or "ci" == f.lower()), None)
        f_org = next((f for f in rd.fieldnames or [] if "organization" in f.lower() or "developer" in f.lower() or "lab" == f.lower()), None)
        for i, r in enumerate(rd):
            val = num(r.get(f_score))
            model = clean(r.get(f_model))
            if val is None or not model:
                continue
            bench = clean(r.get(f_bench)) if f_bench else name.rsplit("/", 1)[-1][:-4]
            if not re.search(r"swe-bench|terminal|gpqa|frontiermath|aime|humanity|hle|osworld|arc", bench, re.I):
                continue
            n += 1
            if n > cap:
                break
            src = clean(r.get(f_src)) if f_src else ""
            reported = "third_party" if re.search(r"epoch|internal", src, re.I) else ("self_reported" if re.search(r"self|developer|provider|report", src, re.I) else "third_party")
            attrs = {"subject_name": model, "score": val, "unit": "percent" if val <= 100 else "score", "benchmark": bench, "benchmark_version": bench, "reported_by": reported, "source_label": src or None,
                     "run_date": clean(r.get(f_date)) if f_date else None, "organization": clean(r.get(f_org)) if f_org else None, "ci_low": (val - num(r.get(f_ci))) if f_ci and num(r.get(f_ci)) is not None else None, "ci_high": (val + num(r.get(f_ci))) if f_ci and num(r.get(f_ci)) is not None else None, "notes": f"file={name}"}
            attrs = {k: v for k, v in attrs.items() if v not in (None, "")}
            out.append(dict(kind="leaderboard_row", key=f"epoch:{sha(name)[:6]}:{i + 1}", parent=None, attrs=attrs, text=json.dumps({k: r.get(k) for k in (f_model, f_bench, f_score, f_date, f_src) if k and r.get(k)}, ensure_ascii=False)[:1200],
                            logical=f"leaderboard_row:{bench}|{model}|{src}", start=None, end=None, selector={"kind": "dataset", "file": name, "row": i + 1}, roles={"subject": [model], "benchmark": [bench]}))
    stats["epoch_rows"] = n
    return out


# ------------------------------------------------------------------ vendor eval tables (announcement HTML, blog HTML, model-card PDF text)
def grammar_eval_tables(units, tables, lines, offs, stats, publisher_models=None):
    """Tables whose header cells name models: each row is a benchmark, each cell a score -> eval_row (model, benchmark, score)."""
    out = []
    n = 0
    for ti, (s, header, rows, e) in enumerate(tables):
        hdr = [clean(h) for h in header]
        model_cols = [i for i, h in enumerate(hdr) if i > 0 and MODEL_WORDS.search(h)]
        sec = table_section(units, f"tbl:{ti + 1}")
        if len(model_cols) < 1 and hdr and MODEL_WORDS.search(hdr[0]) and len(hdr) > 2 and sum(1 for h in hdr[1:] if BENCH_WORDS.search(h)) >= max(1, (len(hdr) - 1) // 2):
            # transposed: header[0] names the model, other header cells name benchmarks, rows are variants/settings
            for ri, (cells, ln) in enumerate(rows):
                cells = [clean(c) for c in cells]
                if not cells or not cells[0]:
                    continue
                for bc in range(1, min(len(hdr), len(cells))):
                    val = num(cells[bc])
                    if val is None:
                        continue
                    bench = re.sub(r"\s*\(%\)\s*$", "", hdr[bc]).strip()
                    model = f"{hdr[0]} ({cells[0]})"
                    n += 1
                    out.append(dict(kind="eval_row", key=f"evt:{ti + 1}:{ri + 1}:{bc}", parent=f"tbl:{ti + 1}", attrs={"benchmark": bench, "benchmark_version": bench, "model": model, "score": val, "unit": "percent" if "%" in hdr[bc] or "%" in cells[bc] else "score", "setting": cells[0][:120], "reported_by": "self_reported", "table_heading": sec or None},
                                    text=f"{bench} | {model} | {cells[bc]}", logical=f"eval_row:{bench}|{cells[0][:120]}|{hdr[0]}|self_reported", start=offs[ln] if ln < len(offs) else None, end=(offs[ln] + len(lines[ln])) if ln < len(lines) else None, selector={"kind": "table", "table": ti + 1, "row": ri + 1, "column": bc}, roles={"model": [hdr[0]], "benchmark": [bench]}))
            continue
        if len(model_cols) < 1:
            continue
        for ri, (cells, ln) in enumerate(rows):
            cells = [clean(c) for c in cells]
            if not cells or not cells[0] or len(cells[0]) > 140:
                continue
            bench = re.sub(r"^[A-Z][a-z]+(?: [a-z]+)*(?=[A-Z])", "", cells[0])  # "Agentic codingTerminal-Bench 4.0" -> "Terminal-Bench 4.0"
            bench = re.sub(r"[¹²³⁴⁵⁶⁷⁸⁹⁰]+$", "", bench).strip()
            bench_base = re.sub(r"\s*\(.*?\)\s*$", "", bench)
            setting = (re.search(r"\((.*?)\)", bench) or [None, None])[1]
            for mc in model_cols:
                if mc >= len(cells):
                    continue
                val = num(cells[mc])
                if val is None:
                    continue
                unit = "percent" if "%" in cells[mc] or (0 <= val <= 100 and not re.search(r"elo|score|\$", bench, re.I)) else "score"
                if "$" in cells[mc]:
                    unit = "usd"
                note = re.search(r"\^(\d+)|\[(\d+)\]|\*+|[¹²³⁴⁵⁶⁷⁸⁹⁰]+", cells[mc] + " " + cells[0])
                n += 1
                attrs = {"benchmark": bench_base, "benchmark_version": bench_base, "model": hdr[mc], "score": val, "unit": unit, "setting": setting, "reported_by": "self_reported", "source_note": note.group(0) if note else None, "table_heading": sec or None}
                attrs = {k: v for k, v in attrs.items() if v not in (None, "")}
                out.append(dict(kind="eval_row", key=f"ev:{ti + 1}:{ri + 1}:{mc}", parent=f"tbl:{ti + 1}", attrs=attrs, text=f"{bench} | {hdr[mc]} | {cells[mc]}", logical=f"eval_row:{bench_base}|{setting or ''}|{hdr[mc]}|self_reported", start=offs[ln] if ln < len(offs) else None, end=(offs[ln] + len(lines[ln])) if ln < len(lines) else None,
                                selector={"kind": "table", "table": ti + 1, "row": ri + 1, "column": mc}, roles={"model": [hdr[mc]], "benchmark": [bench_base]}))
    stats["eval_rows"] = n
    return out


def pdf_text(raw):
    import fitz  # PyMuPDF
    doc = fitz.open(stream=raw, filetype="pdf")
    pages = []
    for i, page in enumerate(doc):
        pages.append(page.get_text("text"))
    return pages


def pdf_tables_as_markdown(raw, max_pages=40):
    """PyMuPDF table finder -> markdown tables (best effort; a PDF without detectable tables yields nothing)."""
    import fitz
    doc = fitz.open(stream=raw, filetype="pdf")
    out = []
    for pno, page in enumerate(doc):
        if pno >= max_pages:
            break
        try:
            tabs = page.find_tables()
        except Exception:
            continue
        for t in tabs.tables:
            rows = t.extract()
            rows = [[clean(c) for c in r] for r in rows if r and any(c for c in r)]
            if len(rows) < 2 or len(rows[0]) < 2:
                continue
            out.append(f"\n## PDF table page {pno + 1}\n")
            out.append("| " + " | ".join(rows[0]) + " |")
            out.append("|" + " --- |" * len(rows[0]))
            for r in rows[1:]:
                out.append("| " + " | ".join(r) + " |")
            out.append("")
    return "\n".join(out)


# ------------------------------------------------------------------ RV05: spec pages and compute pricing
DEVICE_HINTS = re.compile(r"\b(H100|H200|B200|B300|GB200|GB300|A100|L40S|L4|A10G|RTX ?\d{4}|GH200|MI300X|MI350X|MI355X|TPU v?\d\w*|Trillium|Ironwood|T4|V100)\b", re.I)
SPEC_FIELDS = [
    (r"nvlink|pcie|interconnect", "interconnect", None),
    (r"memory bandwidth|bandwidth", "memory_bandwidth_tbps", "TB/s"),
    (r"gpu memory|hbm3e?\b|total memory|memory\b", "memory_gb", "GB"),
    (r"fp4|nvfp4", "fp4_pflops", "PFLOPS"),
    (r"fp8", "fp8_tflops", "TFLOPS"),
    (r"bf16|fp16|tf32 tensor", "bf16_tflops", "TFLOPS"),
    (r"max thermal design power|tdp|power", "tdp_w", "W"),
    (r"form factor", "form_factor", None),
    (r"gpus\b|gpu count", "gpus_per_system", "count"),
    (r"decoders|multi-instance|confidential", None, None),
]


def grammar_spec_page(units, tables, lines, offs, device_hint, stats):
    """NVIDIA-style spec table: first column = field, other columns = product variants (H100 SXM, H100 NVL)."""
    out = []
    n = 0
    for ti, (s, header, rows, e) in enumerate(tables):
        hdr = [clean(h) for h in header]
        if len(hdr) < 2:
            continue
        variants = [re.sub(r"[¹²³⁴⁵⁶⁷⁸⁹⁰*]+", "", h).strip() for h in hdr[1:]] if any(DEVICE_HINTS.search(h) for h in hdr[1:]) else [device_hint.upper()]
        for ri, (cells, ln) in enumerate(rows):
            cells = [clean(c) for c in cells]
            if not cells or not cells[0]:
                continue
            field_label = cells[0]
            field = None
            unit = None
            for pat, f, u in SPEC_FIELDS:
                if re.search(pat, field_label, re.I):
                    field, unit = f, u
                    break
            if not field:
                continue
            for vi, var in enumerate(variants):
                ci_ = vi + 1 if len(hdr) > 1 and any(DEVICE_HINTS.search(h) for h in hdr[1:]) else 1
                if ci_ >= len(cells):
                    continue
                raw = cells[ci_]
                if not raw or raw == "-":
                    continue
                val = raw
                if unit:
                    mv = NUM.search(raw.replace(",", ""))
                    if not mv:
                        continue  # a numeric spec field whose cell has no number is a mislabelled row: skip it
                    if mv:
                        val = float(mv.group(0))
                        if field == "memory_gb" and re.search(r"\bTB\b", raw):
                            val *= 1000
                        if field in ("fp8_tflops", "bf16_tflops") and re.search(r"petaFLOPS|PFLOPS|PF\b", raw, re.I):
                            val *= 1000
                        if field == "fp4_pflops" and re.search(r"TFLOPS", raw, re.I):
                            val /= 1000
                        if field == "memory_bandwidth_tbps" and re.search(r"GB/s", raw):
                            val /= 1000
                        if field == "tdp_w" and re.search(r"\bkW\b", raw, re.I):
                            val *= 1000
                sparse = bool(re.search(r"sparsity|\*|\d\s*\|\s*\d", raw)) or field in ("fp8_tflops", "fp4_pflops", "bf16_tflops")
                n += 1
                out.append(dict(kind="spec_field", key=f"spec:{ti + 1}:{ri + 1}:{vi}", parent=f"tbl:{ti + 1}", attrs={"field": field, "value": val, "unit": unit, "variant": var, "raw": raw[:120], "sparse": sparse if field in ("fp8_tflops", "fp4_pflops", "bf16_tflops") else None, "label": field_label[:80]},
                                text=f"{var} {field_label}: {raw}", logical=f"spec_field:{var}|{field}", start=offs[ln] if ln < len(offs) else None, end=(offs[ln] + len(lines[ln])) if ln < len(lines) else None, selector={"kind": "table", "table": ti + 1, "row": ri + 1, "column": ci_}, roles={"device": [var]}))
    stats["spec_fields"] = n
    return out


COMMIT = [(r"spot|interruptible|preemptible|community", "spot"), (r"reserved|commit|1.?y|3.?y|contract|cluster", "reserved"), (r"flex", "flex_start"), (r"on.?demand|secure|hourly|pay as you go|list", "on_demand")]


def commitment_of(label):
    l = (label or "").lower()
    for pat, c in COMMIT:
        if re.search(pat, l):
            return c
    return "on_demand"


def grammar_compute_pricing(units, tables, lines, offs, provider, stats):
    """GPU-cloud price tables: a GPU column plus $/hr columns (commitment from the header); sandbox per-second rates from text."""
    out = []
    n = 0
    for ti, (s, header, rows, e) in enumerate(tables):
        hdr = [clean(h) for h in header]
        i_gpu = next((i for i, h in enumerate(hdr) if re.search(r"gpu|instance|accelerator|type|model|name|plan", h, re.I) and not re.search(r"count|price|\$|/", h, re.I)), 0)
        i_count = col(hdr, "gpu count", "gpus", "count")
        price_cols = [i for i, h in enumerate(hdr) if re.search(r"\$|price|/hr|hour|on.?demand|spot|secure|community|reserved", h, re.I) and i != i_gpu]
        sec = table_section(units, f"tbl:{ti + 1}")
        for ri, (cells, ln) in enumerate(rows):
            cells = [clean(c) for c in cells]
            if not cells or i_gpu >= len(cells):
                continue
            gpu_cell = cells[i_gpu]
            dm = DEVICE_HINTS.search(gpu_cell) or DEVICE_HINTS.search(sec or "")
            if not dm:
                continue
            device = dm.group(1).upper().replace("  ", " ")
            gpus = re.search(r"(\d+)\s*[x×]\s*", gpu_cell) or re.search(r"[x×]\s*(\d+)", gpu_cell) or re.search(r"\b(\d+)\s*GPUs?\b", gpu_cell) or re.search(r"(\d+)x", sec or "")
            gpu_count = int(gpus.group(1)) if gpus else None
            if i_count is not None and i_count < len(cells) and num(cells[i_count]) is not None:
                gpu_count = int(num(cells[i_count]))
            cols = price_cols or [i for i, c in enumerate(cells) if "$" in c and i != i_gpu]
            for pc in cols:
                if pc >= len(cells):
                    continue
                raw = cells[pc]
                if "$" not in raw:
                    continue
                for mp in PRICE_RE.finditer(raw.replace(",", "")):
                    amount = float(mp.group(1))
                    label = hdr[pc] if pc < len(hdr) else ""
                    per_node = bool(re.search(r"node|instance|8x|8 ?gpu|cluster", (label + " " + gpu_cell + " " + (sec or "")), re.I)) and not re.search(r"per gpu|/gpu|gpu.?hr|gpu.?hour", label + " " + raw, re.I)
                    if provider in ("coreweave",) and gpu_count and gpu_count > 1:
                        per_node = True
                    region = None
                    rm = re.search(r"\b(US|EU|NA|North America|Europe|APAC|us-[a-z]+-\d|europe-[a-z]+\d)\b", label + " " + (sec or ""), re.I)
                    if rm:
                        region = rm.group(1)
                    commitment = commitment_of(label + " " + (sec or ""))
                    tier = "community" if re.search(r"community", label, re.I) else ("secure" if re.search(r"secure", label, re.I) else None)
                    unit = "USD_per_node_hour" if per_node else "USD_per_GPU_hour"
                    if re.search(r"/\s*mo|month", label + raw, re.I):
                        unit = "USD_per_month"
                    n += 1
                    offering = f"{provider}:{gpu_cell[:60]}"
                    attrs = {"offering": offering, "meter": "node_hour" if per_node else "gpu_hour", "amount": amount, "currency": "USD", "unit": unit, "commitment": commitment, "per": "node" if per_node else "gpu", "gpu_count": gpu_count or (8 if per_node else 1), "tier": tier, "region": region, "condition": label[:80] or None, "section": sec[:120] or None, "device": device}
                    attrs = {k: v for k, v in attrs.items() if v not in (None, "")}
                    out.append(dict(kind="price_row", key=f"pr:{ti + 1}:{ri + 1}:{pc}:{mp.start()}", parent=f"tbl:{ti + 1}", attrs=attrs, text=" | ".join(cells)[:800], logical=f"price_row:{offering}|{attrs['meter']}|{tier or 'standard'}|{region or ''}|{commitment}", start=offs[ln] if ln < len(offs) else None, end=(offs[ln] + len(lines[ln])) if ln < len(lines) else None,
                                    selector={"kind": "table", "table": ti + 1, "row": ri + 1, "column": pc}, roles={"offering": [offering], "provider": [provider], "device": [device]}))
                    break  # one price per cell
    # sandbox / serverless per-unit rates in text or tables: "$0.000014 per vCPU-second", "$0.128/h Active CPU"
    text = re.sub(r"(\$\d+(?:\.\d+)?)\s+\d+(?:\.\d+)?(?=\s*/)", r"\1", "\n".join(lines))
    seen = set()
    for m in re.finditer(r"\$(\d+(?:\.\d+)?)\s*(?:/|per)\s*((?:v?cpu|core|physical core|gi?b|gb|memory|sandbox|creation|snapshot)[^\n|.,;)]{0,40}?)(second|sec|s\b|hour|hr|h\b|month|mo\b|1M|million)", text, re.I):
        amount, what, per = float(m.group(1)), m.group(2).strip().lower(), m.group(3).lower()
        meter = ("vcpu_second" if re.search(r"cpu|core", what) else "gib_second" if re.search(r"gi?b|memory", what) else "creations" if "creation" in what else "snapshot_storage" if "snapshot" in what else "sandbox_hour")
        if per.startswith("h"):
            meter = meter.replace("_second", "_hour")
        elif per.startswith("mo"):
            meter = meter.replace("_second", "_month")
        elif per in ("1m", "million"):
            meter = "creations_per_million"
        unit = {"vcpu_second": "USD_per_vcpu_second", "gib_second": "USD_per_GiB_second", "vcpu_hour": "USD_per_vcpu_hour", "gib_hour": "USD_per_GB_hour", "gib_month": "USD_per_GB_month", "creations_per_million": "USD_per_1M_creations", "snapshot_storage": "USD_per_GB_month", "snapshot_storage_month": "USD_per_GB_month", "sandbox_hour": "USD_per_sandbox_hour"}.get(meter, "USD_per_hour")
        key = (meter, amount)
        if key in seen:
            continue
        seen.add(key)
        n += 1
        pos = m.start()
        offering = f"{provider}:sandbox"
        out.append(dict(kind="price_row", key=f"prs:{len(seen)}", parent=None, attrs={"offering": offering, "meter": meter, "amount": amount, "currency": "USD", "unit": unit, "commitment": "on_demand", "per": "unit", "condition": text[max(0, pos - 60):pos + len(m.group(0)) + 40].replace("\n", " ")[:160]},
                        text=text[max(0, pos - 80):pos + len(m.group(0)) + 80].replace("\n", " "), logical=f"price_row:{offering}|{meter}|standard||on_demand", start=pos, end=pos + len(m.group(0)), selector={"kind": "text_quote", "exact": m.group(0)}, roles={"offering": [offering], "provider": [provider]}))
    # limits: max session / concurrency statements -> metadata_field (mapped to offering_limit by the processor)
    k = 0
    for m in re.finditer(r"(?:max(?:imum)?\s+(?:session\s+)?(?:duration|length|lifetime|session)|session (?:limit|duration|timeout)|sandbox (?:lifetime|duration))[^\n.]{0,60}?(\d+(?:\.\d+)?)\s*(hours?|hrs?|h\b|minutes?|mins?|days?)", text, re.I):
        k += 1
        val = float(m.group(1))
        u = m.group(2).lower()
        hours = val if u.startswith("h") else (val / 60 if u.startswith("m") else val * 24)
        ctx = text[max(0, m.start() - 120):m.start()].lower()
        plan = "pro" if re.search(r"pro|team|enterprise", ctx) else ("hobby" if re.search(r"hobby|free", ctx) else None)
        out.append(dict(kind="metadata_field", key=f"limit:{k}", parent=None, attrs={"key": "max_session_hours", "value": hours, "plan": plan, "raw": m.group(0)[:160]}, text=m.group(0), logical=f"metadata_field:max_session_hours|{plan or ''}", start=m.start(), end=m.end(), selector={"kind": "text_quote", "exact": m.group(0)[:200]}, roles={}))
    seen_limits = set()
    for m in re.finditer(r"(\d{1,3}(?:,\d{3})*)\s+concurrent\s+(?:sandboxes|containers|devboxes|sessions|machines)", text, re.I):
        if m.group(0).lower() in seen_limits:
            continue
        seen_limits.add(m.group(0).lower())
        k += 1
        ctx = text[max(0, m.start() - 120):m.start()].lower()
        plan = "pro" if re.search(r"pro|team|enterprise", ctx) else ("hobby" if re.search(r"hobby|free|starter", ctx) else None)
        out.append(dict(kind="metadata_field", key=f"limit:{k}", parent=None, attrs={"key": "max_concurrency", "value": int(m.group(1).replace(",", "")), "plan": plan, "raw": m.group(0)}, text=m.group(0), logical=f"metadata_field:max_concurrency|{plan or ''}|{m.group(1)}", start=m.start(), end=m.end(), selector={"kind": "text_quote", "exact": m.group(0)}, roles={}))
    stats["price_rows"] = n
    stats["limits"] = k
    return out


def grammar_azure_prices(data, stats):
    out = []
    items = data.get("Items") or []
    for i, it in enumerate(items):
        price = it.get("retailPrice")
        if price is None or not it.get("armSkuName"):
            continue
        meter = it.get("meterName") or ""
        commitment = "spot" if "spot" in meter.lower() else ("preemptible" if "low priority" in meter.lower() else "on_demand")
        offering = f"azure:{it['armSkuName']}"
        gpu_count = 8 if "ND96" in it["armSkuName"] else None
        attrs = {"offering": offering, "meter": "instance_hour", "amount": float(price), "currency": it.get("currencyCode") or "USD", "unit": "USD_per_node_hour", "commitment": commitment, "per": "node", "gpu_count": gpu_count, "region": it.get("armRegionName"), "condition": f"{it.get('productName')} / {meter}"[:120], "effective_from": it.get("effectiveStartDate"), "tier": ("windows" if "windows" in (it.get("productName") or "").lower() else None)}
        attrs = {k: v for k, v in attrs.items() if v not in (None, "")}
        out.append(dict(kind="price_row", key=f"az:{i}", parent=None, attrs=attrs, text=json.dumps({k: it.get(k) for k in ("armSkuName", "armRegionName", "meterName", "retailPrice", "unitOfMeasure", "effectiveStartDate", "productName")}, ensure_ascii=False), logical=f"price_row:{offering}|instance_hour|{attrs.get('tier') or 'standard'}|{it.get('armRegionName')}|{commitment}", start=None, end=None, selector={"kind": "json_pointer", "pointer": f"/Items/{i}"}, roles={"offering": [offering], "provider": ["azure"], "device": ["H100"]}))
    stats["price_rows"] = len(out)
    return out


def grammar_epoch_hardware_csv(text, stats):
    out = []
    rd = csv.DictReader(io.StringIO(text))
    f_name = next((f for f in rd.fieldnames or [] if f.lower() in ("hardware name", "name", "hardware")), (rd.fieldnames or [None])[0])
    for i, r in enumerate(rd):
        name = clean(r.get(f_name))
        if not DEVICE_HINTS.search(name or ""):
            continue
        cells = {k: v for k, v in r.items() if v not in (None, "")}
        out.append(dict(kind="table_row", key=f"hw:{i + 1}", parent=None, attrs={"row_key": name, "cells": [f"{k}={v}" for k, v in list(cells.items())[:40]]}, text=json.dumps(cells, ensure_ascii=False)[:2000], logical=f"table_row:{name}", start=None, end=None, selector={"kind": "dataset", "row": i + 1}, roles={"device": [name]}))
    stats["hardware_rows"] = len(out)
    return out


# ------------------------------------------------------------------ RV04
def grammar_api_surface(data, stats):
    out = []
    for i, s in enumerate(data.get("symbols") or []):
        attrs = {k: v for k, v in s.items() if v not in (None, "")}
        out.append(dict(kind="api_symbol", key=f"sym:{sha(s['qualified_name'])[:12]}", parent=None, attrs=attrs, text=f"{s['qualified_name']} [{s['kind']}] {s.get('signature') or ''}\n{s.get('docstring_head') or ''}"[:1500], logical=f"api_symbol:{s['qualified_name']}", start=None, end=None,
                        selector={"kind": "repository", "repository": data.get("repository"), "tag": data.get("release_tag"), "path": s.get("path"), "line": s.get("lineno")}, roles={"release": [data.get("release_tag")], "software": [data.get("package")]}))
    stats["symbols"] = len(out)
    stats["over_cap"] = data.get("over_cap")
    return out


FAMILY_KEEP = ("responses", "chat", "embeddings", "files", "batches", "models", "vector_stores", "realtime", "conversations")


def grammar_openapi(spec, stats, cap_endpoints=460, cap_params=1200):
    out = []
    n_e = n_p = 0
    paths = spec.get("paths") or {}
    info = spec.get("info") or {}
    out.append(dict(kind="metadata_field", key="meta:info", parent=None, attrs={"key": "info", "value": {"title": info.get("title"), "version": info.get("version"), "paths": len(paths), "schemas": len(((spec.get("components") or {}).get("schemas") or {}))}}, text=f"{info.get('title')} {info.get('version')}: {len(paths)} paths", logical="metadata_field:info", start=None, end=None, selector={"kind": "json_pointer", "pointer": "/info"}, roles={}))
    for path in sorted(paths):
        ops = paths[path] or {}
        family = path.strip("/").split("/")[0] if path.strip("/") else "root"
        for method in ("get", "post", "put", "patch", "delete"):
            op = ops.get(method)
            if not isinstance(op, dict):
                continue
            n_e += 1
            if n_e > cap_endpoints:
                continue
            params = [p for p in (op.get("parameters") or []) if isinstance(p, dict)]
            ekey = f"ep:{sha(method + ' ' + path)[:12]}"
            body = (op.get("requestBody") or {}).get("content") or {}
            body_props = {}
            for mt, c in body.items():
                sch = (c or {}).get("schema") or {}
                if "$ref" in sch:
                    ref = sch["$ref"].rsplit("/", 1)[-1]
                    sch = ((spec.get("components") or {}).get("schemas") or {}).get(ref) or {}
                body_props = sch.get("properties") or {}
                req = set(sch.get("required") or [])
                break
            attrs = {"method": method.upper(), "path": path, "operation_id": op.get("operationId"), "summary": (op.get("summary") or "")[:200] or None, "tags": op.get("tags") or [], "deprecated": bool(op.get("deprecated")), "parameter_count": len(params) + len(body_props), "has_request_body": bool(body), "family": family}
            attrs = {k: v for k, v in attrs.items() if v not in (None, "")}
            out.append(dict(kind="endpoint", key=ekey, parent=None, attrs=attrs, text=f"{method.upper()} {path} — {op.get('summary') or op.get('operationId') or ''}\n{(op.get('description') or '')[:600]}", logical=f"endpoint:{method.upper()}|{path}", start=None, end=None, selector={"kind": "json_pointer", "pointer": f"/paths/{path.replace('/', '~1')}/{method}"}, roles={"api": [info.get("title") or "api"], "provider": []}))
            if family in FAMILY_KEEP:
                for p in params:
                    if n_p >= cap_params:
                        break
                    n_p += 1
                    out.append(dict(kind="parameter", key=f"{ekey}:p:{p.get('in')}:{p.get('name')}", parent=ekey, attrs={k: v for k, v in {"endpoint_key": f"{method.upper()} {path}", "name": p.get("name"), "location": p.get("in") if p.get("in") in ("path", "query", "header", "cookie") else "query", "schema_type": (p.get("schema") or {}).get("type") if isinstance((p.get("schema") or {}).get("type"), str) else None, "required": bool(p.get("required")), "description": (p.get("description") or "")[:200] or None, "deprecated": bool(p.get("deprecated"))}.items() if v is not None},
                                    text=f"{p.get('in')} {p.get('name')}: {(p.get('description') or '')[:300]}", logical=f"parameter:{method.upper()} {path}|{p.get('in')}|{p.get('name')}", start=None, end=None, selector={"kind": "json_pointer", "pointer": f"/paths/{path.replace('/', '~1')}/{method}/parameters"}, roles={"api": []}))
                for name, prop in list(body_props.items())[:80]:
                    if n_p >= cap_params:
                        break
                    n_p += 1
                    out.append(dict(kind="parameter", key=f"{ekey}:b:{name}", parent=ekey, attrs={k: v for k, v in {"endpoint_key": f"{method.upper()} {path}", "name": name, "location": "body", "schema_type": (prop or {}).get("type") if isinstance(prop, dict) and isinstance(prop.get("type"), str) else None, "required": name in req, "description": (((prop or {}).get("description") or "")[:200] or None) if isinstance(prop, dict) else None, "deprecated": bool(isinstance(prop, dict) and prop.get("deprecated"))}.items() if v is not None},
                                    text=f"body {name}: {((prop or {}).get('description') or '')[:300] if isinstance(prop, dict) else ''}", logical=f"parameter:{method.upper()} {path}|body|{name}", start=None, end=None, selector={"kind": "json_pointer", "pointer": f"/paths/{path.replace('/', '~1')}/{method}/requestBody"}, roles={"api": []}))
    stats.update({"endpoints": min(n_e, cap_endpoints), "endpoints_total": n_e, "parameters": n_p, "schemas_total": len(((spec.get("components") or {}).get("schemas") or {}))})
    return out


def grammar_json_schema(schema, protocol_version, stats):
    out = []
    defs = schema.get("definitions") or schema.get("$defs") or {}
    for name, d in defs.items():
        if not isinstance(d, dict):
            continue
        props = d.get("properties") or {}
        out.append(dict(kind="schema_component", key=f"def:{sha(name)[:12]}", parent=None, attrs={"name": name, "type": d.get("type") if isinstance(d.get("type"), str) else None, "required": d.get("required") or [], "property_count": len(props), "description": (d.get("description") or "")[:300] or None, "protocol_version": protocol_version},
                        text=f"{name}: {(d.get('description') or '')[:400]}\nproperties: {', '.join(list(props)[:30])}", logical=f"schema_component:{name}", start=None, end=None, selector={"kind": "json_pointer", "pointer": f"/definitions/{name}"}, roles={"protocol_version": [protocol_version]}))
    stats["schema_components"] = len(out)
    return out


CHANGE_KIND = [(r"remov|drop|delet", "removed"), (r"deprecat", "deprecated"), (r"\badd|introduc|new\b", "added"), (r"break", "breaking"), (r"secur|auth", "security"), (r"chang|renam|mov|replac|updat", "changed"), (r"fix", "fixed")]


def grammar_changelog_protocol(units, text, protocol_version, stats):
    """MCP changelog page: one release_entry for the protocol version, change_item per bullet/section with a kind."""
    out = []
    rel_key = f"rel:{protocol_version}"
    date_m = re.search(r"(20\d\d-\d\d-\d\d)", protocol_version)
    out.append(dict(kind="release_entry", key=rel_key, parent=None, attrs={"version": protocol_version, "title": f"MCP specification {protocol_version}", "released_on": date_m.group(1) if date_m else None, "url": f"https://modelcontextprotocol.io/specification/{protocol_version}/changelog", "breaking": bool(re.search(r"breaking|remov", text, re.I))}, text=text[:1500], logical=f"release_entry:{protocol_version}", start=0, end=min(len(text), 1500), selector={"kind": "text_quote", "exact": text.splitlines()[0][:120] if text else protocol_version}, roles={"release": [protocol_version], "software": ["mcp"]}))
    n = 0
    for u in units:
        if u["kind"] in ("list_item", "paragraph") and len(u["text"]) > 20 or (u["kind"] == "section" and u["attrs"].get("level", 1) >= 3):
            body = u["text"] if u["kind"] != "section" else u["attrs"]["heading"] + ": " + (u["text"].split("\n", 1) + [""])[1][:400]
            kind = "other"
            for pat, k in CHANGE_KIND:
                if re.search(pat, body, re.I):
                    kind = k
                    break
            n += 1
            sep = re.search(r"\b(SEP-\d+|#\d{3,5})\b", body)
            out.append(dict(kind="change_item", key=f"chg:{n}", parent=rel_key, attrs={"kind": kind, "ordinal": n, "component": sep.group(1) if sep else None}, text=body[:1500], logical=f"change_item:{protocol_version}|{n}", start=u.get("start"), end=u.get("end"), selector={"kind": "text_quote", "exact": body[:200]}, roles={"software": ["mcp"], "component": [sep.group(1)] if sep else [], "mentions": []}))
    stats["change_items"] = n
    return out


def grammar_registry(data, registry, stats):
    out = []
    for i, entry in enumerate(data.get("servers") or []):
        s = entry.get("server") or entry
        meta = (entry.get("_meta") or {}).get("io.modelcontextprotocol.registry/official") or {}
        name = s.get("name")
        if not name:
            continue
        transports = sorted({(r.get("type") or "") for r in (s.get("remotes") or []) if isinstance(r, dict)} | {((p.get("transport") or {}).get("type") or "") for p in (s.get("packages") or []) if isinstance(p, dict)})
        transports = [t for t in transports if t]
        ns = name.split("/")[0]
        domain = ".".join(reversed(ns.split(".")))
        urls = " ".join(x for x in [s.get("websiteUrl") or "", ((s.get("repository") or {}).get("url") if isinstance(s.get("repository"), dict) else "") or ""] + [r.get("url") or "" for r in (s.get("remotes") or []) if isinstance(r, dict)])
        first_party = (not ns.startswith("io.github.")) and domain.lower() in urls.lower() and not re.search(r"smithery|glama|mcp\.so|pulsemcp", ns)
        attrs = {"registry": registry, "name": name, "namespace": ns, "publisher": ns, "version": s.get("version"), "transports": transports, "package_identifiers": [p.get("identifier") for p in (s.get("packages") or []) if isinstance(p, dict) and p.get("identifier")][:10], "first_party_inferred": first_party,
                 "registry_status": meta.get("status"), "repository_url": ((s.get("repository") or {}).get("url") if isinstance(s.get("repository"), dict) else None), "website_url": s.get("websiteUrl"), "published_at": meta.get("publishedAt"), "updated_at": meta.get("updatedAt"), "description": (s.get("description") or "")[:300] or None, "is_latest": meta.get("isLatest")}
        attrs = {k: v for k, v in attrs.items() if v not in (None, "", [])}
        out.append(dict(kind="registry_listing", key=f"reg:{sha(name)[:12]}", parent=None, attrs=attrs, text=f"{name} {s.get('version') or ''}: {(s.get('description') or '')[:400]} transports={','.join(transports)}", logical=f"registry_listing:{registry}|{name}", start=None, end=None, selector={"kind": "json_pointer", "pointer": f"/servers/{i}"}, roles={"server": [name], "registry": [registry], "publisher": [ns]}))
    stats["listings"] = len(out)
    return out


def grammar_ghsa(data, package, stats):
    out = []
    for i, a in enumerate(data if isinstance(data, list) else []):
        vuln = next((v for v in (a.get("vulnerabilities") or []) if ((v.get("package") or {}).get("name") or "").lower() == package.lower()), (a.get("vulnerabilities") or [{}])[0] if a.get("vulnerabilities") else {})
        attrs = {"ghsa_id": a.get("ghsa_id"), "cve_id": a.get("cve_id"), "severity": a.get("severity"), "package": (vuln.get("package") or {}).get("name") or package, "ecosystem": (vuln.get("package") or {}).get("ecosystem") or "pip", "affected_range": vuln.get("vulnerable_version_range"), "fixed_version": vuln.get("first_patched_version"),
                 "published_at": a.get("published_at"), "updated_at": a.get("updated_at"), "summary": (a.get("summary") or "")[:300], "url": a.get("html_url"), "cwe": [c.get("cwe_id") for c in (a.get("cwes") or []) if c.get("cwe_id")]}
        attrs = {k: v for k, v in attrs.items() if v not in (None, "", [])}
        if not attrs.get("ghsa_id"):
            continue
        out.append(dict(kind="advisory", key=f"adv:{attrs['ghsa_id']}", parent=None, attrs=attrs, text=f"{attrs['ghsa_id']} {attrs.get('cve_id') or ''} [{attrs.get('severity')}] {attrs.get('package')} {attrs.get('affected_range') or ''} fixed {attrs.get('fixed_version') or '-'}: {attrs.get('summary')}\n{(a.get('description') or '')[:800]}", logical=f"advisory:{attrs['ghsa_id']}|{attrs.get('package')}", start=None, end=None, selector={"kind": "json_pointer", "pointer": f"/{i}"}, roles={"advisory": [attrs["ghsa_id"]], "software": [attrs.get("package")], "package": [attrs.get("package")]}))
    stats["advisories"] = len(out)
    return out


def grammar_pypi(data, stats):
    out = []
    info = data.get("info") or {}
    releases = data.get("releases") or {}
    for k, v in {"version": info.get("version"), "requires_python": info.get("requires_python"), "license": info.get("license") or info.get("license_expression"), "summary": info.get("summary"), "home_page": (info.get("project_urls") or {}).get("Homepage") or info.get("home_page"), "release_count": len(releases)}.items():
        if v in (None, ""):
            continue
        out.append(dict(kind="metadata_field", key=f"meta:{k}", parent=None, attrs={"key": k, "value": v}, text=f"{k}: {v}", logical=f"metadata_field:{k}", start=None, end=None, selector={"kind": "json_pointer", "pointer": f"/info/{k}"}, roles={}))
    for i, dep in enumerate(info.get("requires_dist") or []):
        m = re.match(r"^([A-Za-z0-9_.\-]+)\s*(\[.*?\])?\s*([<>=!~].*?)?(?:\s*;.*)?$", dep.strip())
        if not m:
            continue
        out.append(dict(kind="metadata_field", key=f"dep:{i}", parent=None, attrs={"key": "requires_dist", "value": {"package": m.group(1).lower(), "spec": (m.group(3) or "").strip(), "extra": m.group(2), "raw": dep}}, text=f"requires_dist: {dep}", logical=f"metadata_field:requires_dist|{m.group(1).lower()}", start=None, end=None, selector={"kind": "json_pointer", "pointer": f"/info/requires_dist/{i}"}, roles={}))
    latest = info.get("version")
    files = releases.get(latest) or []
    if files:
        out.append(dict(kind="metadata_field", key="meta:upload_time", parent=None, attrs={"key": "latest_upload_time", "value": files[0].get("upload_time_iso_8601")}, text=f"latest_upload_time: {files[0].get('upload_time_iso_8601')}", logical="metadata_field:latest_upload_time", start=None, end=None, selector={"kind": "json_pointer", "pointer": f"/releases/{latest}/0/upload_time_iso_8601"}, roles={}))
    stats["pypi_fields"] = len(out)
    return out


# ------------------------------------------------------------------ papers (PDF text) and research posts
SECTION_ROLE = [(r"^abstract", "abstract"), (r"introduction", "introduction"), (r"method|approach|framework|design|setup", "method"), (r"result|evaluation|experiment|finding", "results"), (r"discussion|analysis", "discussion"), (r"limitation|threat", "limitations"), (r"conclusion", "conclusion"), (r"^references|^bibliography", "references"), (r"appendix|supplement", "appendix")]
HEADING_RE = re.compile(r"^(?:(\d{1,2}(?:\.\d{1,2})*)\s+)?([A-Z][A-Za-z][A-Za-z0-9 ,:&\-()/']{2,80})$")


def grammar_paper_pdf(pages, level, stats):
    """Sections from numbered or capitalised headings; abstract/conclusion kept as paper_section units (P1: abstract + conclusion only; P2: all);
    references from the References section (arXiv ids/DOIs); the text offsets index the concatenated page text."""
    text = "\n".join(pages)
    lines = text.splitlines()
    offs = P1.line_offsets(text)
    heads = []
    for i, l in enumerate(lines):
        s = l.strip()
        if not s or len(s) > 90:
            continue
        if re.match(r"^(abstract|references|bibliography|acknowledg\w+|appendix\b.*)$", s, re.I) or (HEADING_RE.match(s) and not s.endswith(".") and not re.search(r"\b(et al|arXiv|Figure|Table|University|@)\b", s) and (re.match(r"^\d", s) or s.isupper() or (i + 1 < len(lines) and lines[i + 1].strip() and not lines[i + 1].strip()[0].islower() and len(s.split()) <= 8 and re.match(r"^\d", s)))):
            heads.append((i, s))
    out = []
    kept = 0
    for hi, (i, heading) in enumerate(heads):
        j = heads[hi + 1][0] if hi + 1 < len(heads) else len(lines)
        body = "\n".join(lines[i + 1:j]).strip()
        role = "other"
        for pat, r in SECTION_ROLE:
            if re.search(pat, heading, re.I):
                role = r
                break
        if level == "P1" and role not in ("abstract", "conclusion", "references", "limitations"):
            continue
        kept += 1
        out.append(dict(kind="paper_section", key=f"ps:{hi}", parent=None, attrs={"heading": heading[:120], "level": 1 if re.match(r"^\d+\s", heading) or role != "other" else 2, "path": heading[:120], "section_role": role}, text=(heading + "\n" + body)[:6000], logical=f"paper_section:{heading[:120]}", start=offs[i], end=offs[j - 1] + len(lines[j - 1]) if j - 1 < len(lines) else len(text), selector={"kind": "pdf_text", "heading": heading[:120]}, roles={"paper": []}))
        if role == "references":
            k = 0
            for m in re.finditer(r"(?:arXiv[:\s]*(\d{4}\.\d{4,5})(?:v\d+)?)|(?:doi\.org/|doi:\s*)(10\.\d{4,9}/[^\s,;]+)", body, re.I):
                k += 1
                arx, doi = m.group(1), m.group(2)
                key = arx or doi
                out.append(dict(kind="reference", key=f"ref:{sha(key)[:10]}", parent=f"ps:{hi}", attrs={"ref_key": key, "arxiv_id": arx, "doi": doi, "ordinal": k, "url": f"https://arxiv.org/abs/{arx}" if arx else f"https://doi.org/{doi}"}, text=body[max(0, m.start() - 160):m.end()].replace("\n", " "), logical=f"reference:{key}", start=None, end=None, selector={"kind": "pdf_text", "exact": m.group(0)}, roles={"cited": [key]}))
            stats["references"] = k
    # abstract fallback when no heading matched: first 2,500 chars
    if not any(u["attrs"]["section_role"] == "abstract" for u in out if u["kind"] == "paper_section"):
        m = re.search(r"abstract", text[:6000], re.I)
        start = m.start() if m else 0
        out.insert(0, dict(kind="paper_section", key="ps:abstract", parent=None, attrs={"heading": "Abstract", "level": 1, "path": "Abstract", "section_role": "abstract"}, text=text[start:start + 2500], logical="paper_section:Abstract", start=start, end=start + 2500, selector={"kind": "pdf_text", "heading": "Abstract"}, roles={"paper": []}))
        kept += 1
    stats["paper_sections"] = kept
    stats["headings_seen"] = len(heads)
    return out, text


def key_results(abstract_text):
    """Numeric claims in an abstract: (sentence, value, unit) for digest key_result items and claim candidates."""
    out = []
    for sent in re.split(r"(?<=[.!?])\s+", abstract_text.replace("\n", " ")):
        for m in re.finditer(r"(-?\d+(?:\.\d+)?)\s*(%|percent|pp|x\b|×)", sent):
            out.append({"sentence": sent.strip()[:400], "value": float(m.group(1)), "unit": "percent" if m.group(2) in ("%", "percent") else m.group(2)})
    return out


def grammar_guidance_sections(units, text, source_key, stats):
    """OWASP ASI items and research-post sections -> paper_section/post_paragraph units already exist; this returns the candidate
    guidance statements (kind, title, statement, quantitative) the processor turns into guidance.item rows through claims."""
    cands = []
    if source_key == "owasp-agentic-top10":
        for m in re.finditer(r"(ASI\s?(\d{2}))\s*[:\-–—]?\s*([A-Z][A-Za-z &/\-]{4,70})", text):
            code = f"ASI{m.group(2)}"
            title = m.group(3).strip()
            if any(c["code"] == code for c in cands) or len(title) < 5:
                continue
            tail = text[m.end():m.end() + 900].replace("\n", " ")
            desc = re.split(r"(?<=[.!?])\s+", tail)
            statement = " ".join(desc[:2])[:600]
            cands.append({"code": code, "kind": "security_consideration", "title": f"{code} {title}", "statement": statement, "pos": m.start()})
        cands.sort(key=lambda c: c["code"])
    elif source_key == "anthropic-multiagent":
        secs = [u for u in units if u["kind"] == "section"]
        for s in secs:
            if not re.search(r"failure|epistemic|incompatible|coordinat|conformity", s["attrs"]["heading"], re.I):
                continue
            body = (s["text"].split("\n", 1) + [""])[1]
            for sent in re.split(r"(?<=[.!?])\s+", body.replace("\n", " ")):
                if re.search(r"\d", sent) and len(sent) > 60 and re.search(r"agents?|model", sent, re.I) and not sent.lstrip().startswith("-") and "Introducing" not in sent:
                    cands.append({"code": None, "kind": "failure_mode", "title": s["attrs"]["heading"][:120], "statement": sent.strip()[:600], "pos": s["start"]})
                    if sum(1 for c in cands if c["title"] == s["attrs"]["heading"][:120]) >= 3:
                        break
    stats["guidance_candidates"] = len(cands)
    return cands
