"""Build 08 knowledge loop 1: census and grammar parsers (pure functions, no database).

A parsed unit is a dict: kind, attrs, text, parent (stable key or None), key (stable_local_key), logical (logical_key or None),
start/end (character offsets into the text representation), start_ms/end_ms (timed text), selector (jsonb), roles ({role: [entity hints]}).
Grammar version build08-grammar/1. Everything here reads source bytes as data.
"""
import json, re, hashlib
from html.parser import HTMLParser

GRAMMAR = "build08-grammar/1"
TIMECODE = re.compile(r"^\[(\d+):(\d\d)(?::(\d\d))?\]\((https://www\.youtube\.com/watch\?v=([^&\s]+)&t=(\d+)s)\)\s*(.*)$")
PRICE_RE = re.compile(r"\$\s?(\d+(?:\.\d+)?)")
PRICE_MENTION = re.compile(r"\$(\d+(?:\.\d+)?)\s*(?:per|/)\s*(?:million|1M|M)\s*(cached input|input|output)\s*tokens", re.I)
MODEL_NAME_RE = re.compile(r"(GPT-\d(?:\.\d)?\s?(?:Sol|Terra|Luna|Astra)|Claude (?:Fable|Opus|Sonnet|Haiku) \d(?:\.\d)?|Gemini \d(?:\.\d)? [A-Z][a-z]+|DeepSeek[- ][A-Za-z0-9.]+)", re.I)


def sha(t):
    return hashlib.sha256(t.encode("utf-8")).hexdigest()


def ms_of(m, s, h=None):
    """[m:ss] or [h:mm:ss] -> ms."""
    if h is not None:
        return (int(m) * 3600 + int(s) * 60 + int(h)) * 1000
    return (int(m) * 60 + int(s)) * 1000


# ------------------------------------------------------------------ census
def census(text, fmt):
    lines = text.splitlines()
    heads = [l for l in lines if re.match(r"^#{1,6} ", l)]
    tables = 0
    table_rows = 0
    sigs = []
    in_table = False
    for l in lines:
        if l.startswith("|"):
            if not in_table:
                tables += 1
                in_table = True
                sigs.append(re.sub(r"\s+", " ", l.strip("| ").replace("|", " | "))[:160])
            elif not re.match(r"^\|\s*:?-", l):
                table_rows += 1
        else:
            in_table = False
    if fmt == "html":
        tables = text.lower().count("<table")
        table_rows = text.lower().count("<tr")
        heads = re.findall(r"<h[1-6][^>]*>", text, flags=re.I)
    counts = {
        "headings": len(heads),
        "heading_depth": max([len(h.split(" ")[0]) for h in heads if h.startswith("#")] or [0]),
        "paragraphs": len([l for l in lines if l.strip() and not l.startswith(("#", "|", "-", "*", "```", "[", "!", ">")) and len(l) > 40]),
        "tables": tables,
        "table_rows": table_rows,
        "lists": len(re.findall(r"(?:^|\n)(?:- |\* |\d+\. )", text)) and len([1 for i, l in enumerate(lines) if re.match(r"^(- |\* |\d+\. )", l) and (i == 0 or not re.match(r"^(- |\* |\d+\. )", lines[i - 1]))]),
        "list_items": len([l for l in lines if re.match(r"^\s*(- |\* |\d+\. )", l)]),
        "code_blocks": text.count("```") // 2 + (text.lower().count("<pre") if fmt == "html" else 0),
        "links": len(re.findall(r"\]\(https?://", text)) + (len(re.findall(r"<a\s", text, flags=re.I)) if fmt == "html" else 0),
        "timecodes": len([l for l in lines if TIMECODE.match(l)]),
        "speaker_labels": len([l for l in lines if re.match(r"^[A-Z][a-zA-Z.'-]+(?: [A-Z][a-zA-Z.'-]+){0,2}:\s", l)]),
        "figures": len(re.findall(r"!\[", text)) + (len(re.findall(r"<img\s", text, flags=re.I)) if fmt == "html" else 0),
        "machine_blocks": (1 if fmt == "json" else 0) + (1 if text.startswith("---\n") else 0) + text.count("BEGIN:VEVENT"),
        "words": len(re.findall(r"\w+", text)),
    }
    return counts, {"table_headers": sigs[:12], "top_headings": [h[:100] for h in heads[:12]]}


# ------------------------------------------------------------------ markdown universal units
def md_tables(lines):
    """Yield (start_line, header_cells, rows[list[cells]], end_line)."""
    i = 0
    while i < len(lines):
        if lines[i].startswith("|") and i + 1 < len(lines) and re.match(r"^\|\s*:?-", lines[i + 1]):
            header = [c.strip() for c in lines[i].strip().strip("|").split("|")]
            rows = []
            j = i + 2
            while j < len(lines) and lines[j].startswith("|"):
                rows.append(([c.strip() for c in lines[j].strip().strip("|").split("|")], j))
                j += 1
            yield i, header, rows, j
            i = j
        else:
            i += 1


def line_offsets(text):
    offs = []
    pos = 0
    for l in text.splitlines(True):
        offs.append(pos)
        pos += len(l)
    return offs


def universal_markdown(text, kind):
    """Sections (path), paragraphs, lists/items, tables/rows, code blocks, links, metadata fields."""
    lines = text.splitlines()
    offs = line_offsets(text)
    units = []
    stack = []  # (level, key)
    seen_paths = {}
    section_key = None
    para_n = 0
    code_n = 0
    link_n = 0
    in_code = False
    code_start = None
    code_lang = None
    table_lines = set()
    tables = list(md_tables(lines))
    for ti, (s, header, rows, e) in enumerate(tables):
        for k in range(s, e):
            table_lines.add(k)
    if text.startswith("---\n"):
        end = text.find("\n---", 4)
        for ln in text[4:end].splitlines():
            if ":" in ln:
                k, v = ln.split(":", 1)
                units.append(dict(kind="metadata_field", key=f"meta:{k.strip()}", parent=None, attrs={"key": k.strip(), "value": v.strip()}, text=f"{k.strip()}: {v.strip()}", logical=f"metadata_field:{k.strip()}", start=0, end=end))
    for i, l in enumerate(lines):
        if l.startswith("```"):
            if not in_code:
                in_code = True
                code_start = i
                code_lang = l[3:].strip() or None
            else:
                in_code = False
                code_n += 1
                body = "\n".join(lines[code_start + 1:i])
                units.append(dict(kind="code_block", key=f"code:{code_n}", parent=section_key, attrs={"language": code_lang, "lines": i - code_start - 1}, text=body[:6000], logical=None, start=offs[code_start], end=offs[i] + len(l)))
            continue
        if in_code or i in table_lines:
            continue
        m = re.match(r"^(#{1,6}) (.*)$", l)
        if m:
            level = len(m.group(1))
            heading = re.sub(r"\s*\{%.*?%\}\s*$", "", m.group(2)).strip()
            while stack and stack[-1][0] >= level:
                stack.pop()
            path = "/".join([x[2] for x in stack] + [heading])
            seen_paths[path] = seen_paths.get(path, 0) + 1
            if seen_paths[path] > 1:
                path = f"{path}#{seen_paths[path]}"
            key = f"sec:{sha(path)[:12]}"
            parent = stack[-1][1] if stack else None
            stack.append((level, key, heading))
            section_key = key
            # section text = heading + following non-heading lines until next heading of same/higher level
            j = i + 1
            while j < len(lines) and not re.match(r"^#{1,%d} " % level, lines[j]):
                j += 1
            body = "\n".join(lines[i + 1:j]).strip()
            units.append(dict(kind="section", key=key, parent=parent, attrs={"heading": heading, "level": level, "path": path}, text=(heading + "\n" + body)[:4000], logical=f"section:{path}", start=offs[i], end=(offs[j] if j < len(lines) else len(text))))
            continue
        if re.match(r"^\s*(- |\* |\d+\. )", l):
            item = re.sub(r"^\s*(- |\* |\d+\. )", "", l).strip()
            para_n += 1
            units.append(dict(kind="list_item", key=f"li:{para_n}", parent=section_key, attrs={"ordinal": para_n}, text=item[:2000], logical=None, start=offs[i], end=offs[i] + len(l)))
        elif l.strip() and not l.startswith(("[", "!", ">")) and len(l.strip()) > 2:
            para_n += 1
            units.append(dict(kind="paragraph", key=f"p:{para_n}", parent=section_key, attrs={"ordinal_in_section": para_n}, text=l.strip()[:4000], logical=None, start=offs[i], end=offs[i] + len(l)))
        for lm in re.finditer(r"\[([^\]]{1,200})\]\((https?://[^)\s]+)\)", l):
            link_n += 1
            units.append(dict(kind="link", key=f"link:{link_n}", parent=section_key, attrs={"href": lm.group(2), "text": lm.group(1)}, text=lm.group(1) + " -> " + lm.group(2), logical=f"link:{lm.group(2)}", start=offs[i] + lm.start(), end=offs[i] + lm.end()))
    for ti, (s, header, rows, e) in enumerate(tables):
        tkey = f"tbl:{ti + 1}"
        # parent = nearest section above
        parent = None
        for u in reversed(units):
            if u["kind"] == "section" and u["start"] <= offs[s]:
                parent = u["key"]
                break
        units.append(dict(kind="table", key=tkey, parent=parent, attrs={"header": header, "rows": len(rows)}, text=" | ".join(header), logical=f"table:{'|'.join(header)[:120]}", start=offs[s], end=offs[e - 1] + len(lines[e - 1])))
        for ri, (cells, ln) in enumerate(rows):
            rk = re.sub(r"\s+", " ", re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", cells[0]))[:120] if cells else str(ri)
            units.append(dict(kind="table_row", key=f"{tkey}:r{ri + 1}", parent=tkey, attrs={"row_key": rk, "cells": cells}, text=" | ".join(cells)[:2000], logical=f"table_row:{rk}", start=offs[ln], end=offs[ln] + len(lines[ln])))
    return units, tables, lines, offs


# ------------------------------------------------------------------ html -> markdown-ish text (headings, paragraphs, tables, code)
class _Html(HTMLParser):
    def __init__(self):
        super().__init__()
        self.out = []
        self.skip = 0
        self.cell = None
        self.row = None
        self.rows = None
        self.in_pre = False
        self.heading = None
        self.buf = []

    def handle_starttag(self, tag, attrs):
        if tag in ("script", "style", "noscript", "svg", "nav", "footer", "header"):
            self.skip += 1
        if self.skip:
            return
        if tag in ("h1", "h2", "h3", "h4"):
            self.heading = int(tag[1])
            self.buf = []
        elif tag == "table":
            self.rows = []
        elif tag == "tr" and self.rows is not None:
            self.row = []
        elif tag in ("td", "th") and self.row is not None:
            self.cell = []
        elif tag == "pre":
            self.in_pre = True
            self.buf = []
        elif tag in ("p", "li") and self.rows is None:
            self.buf = []
        elif tag == "br" and self.cell is not None:
            self.cell.append(" ")

    def handle_endtag(self, tag):
        if tag in ("script", "style", "noscript", "svg", "nav", "footer", "header"):
            if self.skip:
                self.skip -= 1
            return
        if self.skip:
            return
        if tag in ("h1", "h2", "h3", "h4") and self.heading:
            self.out.append("#" * self.heading + " " + " ".join("".join(self.buf).split()))
            self.out.append("")
            self.heading = None
        elif tag in ("td", "th") and self.cell is not None and self.row is not None:
            self.row.append(" ".join("".join(self.cell).split()))
            self.cell = None
        elif tag == "tr" and self.row is not None:
            if any(self.row):
                self.rows.append(self.row)
            self.row = None
        elif tag == "table" and self.rows is not None:
            if self.rows:
                self.out.append("| " + " | ".join(self.rows[0]) + " |")
                self.out.append("|" + " --- |" * len(self.rows[0]))
                for r in self.rows[1:]:
                    self.out.append("| " + " | ".join(r) + " |")
                self.out.append("")
            self.rows = None
        elif tag == "pre" and self.in_pre:
            self.out.append("```")
            self.out.append("".join(self.buf))
            self.out.append("```")
            self.in_pre = False
        elif tag in ("p", "li") and self.rows is None:
            t = " ".join("".join(self.buf).split())
            if t:
                self.out.append(("- " if tag == "li" else "") + t)
                self.out.append("")
            self.buf = []

    def handle_data(self, data):
        if self.skip:
            return
        if self.cell is not None:
            self.cell.append(data)
        elif self.heading or self.in_pre or self.buf is not None:
            self.buf.append(data)


def html_to_text(html):
    p = _Html()
    p.feed(html)
    return "\n".join(p.out)


# ------------------------------------------------------------------ grammar overlays
METER_MAP = [
    (r"cached? input|cache hits?|cache read", "cached_input_tokens"),
    (r"(\d+ ?(?:m|min|minutes?)|5m|30m|1h|12h|30 ?minute|12.?hour).*(cache )?writes?|cache writes?", "cache_write_tokens"),
    (r"\binput\b", "input_tokens"),
    (r"\boutput\b", "output_tokens"),
]


def meter_of(header):
    h = header.lower()
    for pat, meter in METER_MAP:
        if re.search(pat, h):
            band = "long" if "long context" in h or "272" in h else ("short" if "short context" in h else None)
            cond = None
            m = re.search(r"(5m|1h|30m|12h|30 ?minutes?|12 ?hours?)", h)
            if meter == "cache_write_tokens" and m:
                cond = m.group(1).replace(" ", "")
            return meter, band, cond
    return None, None, None


def parse_price(cell):
    m = PRICE_RE.search(cell.replace(",", ""))
    if not m:
        return None
    v = float(m.group(1))
    unit = "USD_per_1M_tokens"
    if re.search(r"/\s?1?K\s?tok|per 1K", cell, re.I):
        unit = "USD_per_1K_tokens"
    return v, unit


TIER_LABELS = {"standard": "standard", "batch": "batch", "flex": "flex", "fast": "fast", "ultrafast": "ultrafast", "priority": "priority"}


def tier_of(heading_path, lines=None, table_start=None):
    """Tier from the nearest heading; when the heading does not say, the last short label line above the table (OpenAI renders
    Standard/Batch/Fast toggles as plain text before some tables) decides; otherwise standard."""
    h = (heading_path or "").lower()
    for t in ("ultrafast", "batch", "flex", "fast", "priority"):
        if t in h:
            return t
    if lines is not None and table_start is not None:
        for j in range(table_start - 1, max(-1, table_start - 12), -1):
            label = lines[j].strip().lower()
            if label.startswith("#"):
                break
            if label in TIER_LABELS:
                return TIER_LABELS[label]
    return "standard"


def grammar_pricing(units, tables, lines, offs, source_key):
    """price_row units from any table that has a model column and price columns; DeepSeek style (models as columns) handled."""
    out = []
    n = 0
    sections = {u["key"]: u for u in units if u["kind"] == "section"}
    for ti, (s, header, rows, e) in enumerate(tables):
        tkey = f"tbl:{ti + 1}"
        table_unit = next((u for u in units if u["key"] == tkey), None)
        sec_path = sections.get(table_unit["parent"], {}).get("attrs", {}).get("path", "") if table_unit and table_unit["parent"] else ""
        tier = tier_of(sec_path, lines, s)
        if rows and rows[0][0] and rows[0][0][0].strip().lower() in ("name", "model") and not any("$" in c for c in rows[0][0]):
            header = rows[0][0]
            rows = rows[1:]
        hl = [h.lower() for h in header]
        if hl and ("model" in hl[0] or hl[0] in ("", "feature", "name")) and any(meter_of(h)[0] for h in header[1:]):
            plan_key = f"plan:{ti + 1}"
            out.append(dict(kind="plan_section", key=plan_key, parent=table_unit["parent"] if table_unit else None, attrs={"plan": sec_path or header[0], "tier": tier}, text=f"{sec_path} ({tier})", logical=f"plan_section:{sec_path}|{tier}", start=table_unit["start"] if table_unit else 0, end=table_unit["end"] if table_unit else 0))
            for ri, (cells, ln) in enumerate(rows):
                offering = re.sub(r"\s+", " ", re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", re.sub(r"<[^>]+>", "", cells[0]))).strip()
                offering_norm = re.sub(r"\s*\(.*\)$", "", offering)
                cond_row = re.search(r"\((.*)\)", offering)
                for ci, cell in enumerate(cells[1:], start=1):
                    if ci >= len(header):
                        break
                    meter, band, cond = meter_of(header[ci])
                    price = parse_price(cell)
                    if not meter or not price:
                        continue
                    n += 1
                    attrs = {"offering": offering_norm, "meter": meter, "amount": price[0], "currency": "USD", "unit": price[1], "tier": tier, "region": None,
                             "context_band": band, "condition": cond or (cond_row.group(1) if cond_row else None), "column": header[ci]}
                    logical = f"price_row:{offering_norm.lower()}|{meter}|{tier}|{band or ''}|{(cond or '').lower()}"
                    out.append(dict(kind="price_row", key=f"{tkey}:r{ri + 1}:c{ci}", parent=plan_key, attrs=attrs, text=f"{offering_norm}: {header[ci]} = {cell.strip()} ({tier})", logical=logical, start=offs[ln], end=offs[ln] + len(lines[ln]),
                                    selector={"kind": "table", "table": ti + 1, "row": ri + 1, "column": ci, "row_key": offering, "column_header": header[ci], "cell": cell.strip()}, roles={"offering": [offering_norm], "provider": [source_key.split("-")[0]]}))
        elif hl and hl[0] == "model" and len(hl) > 2 and all(h == "model" for h in hl[:3]):
            # DeepSeek layout: models are columns from the first non-'model' header; rows are attributes
            model_cols = [(ci, h) for ci, h in enumerate(header) if h.lower() != "model" and h.strip()]
            plan_key = f"plan:{ti + 1}"
            out.append(dict(kind="plan_section", key=plan_key, parent=table_unit["parent"] if table_unit else None, attrs={"plan": sec_path or "models", "tier": "standard"}, text=f"{sec_path} (standard)", logical=f"plan_section:{sec_path}|standard", start=table_unit["start"] if table_unit else 0, end=table_unit["end"] if table_unit else 0))
            for ri, (cells, ln) in enumerate(rows):
                label = " ".join(c for c in cells[:3] if c).lower()
                meter, band, cond = meter_of(label)
                if not meter or "price" not in label and "$" not in " ".join(cells):
                    continue
                cache_hit = "hit" in label
                for ci, mh in model_cols:
                    if ci >= len(cells):
                        continue
                    price = parse_price(cells[ci])
                    if not price:
                        continue
                    n += 1
                    mt = "cached_input_tokens" if (meter == "input_tokens" and cache_hit) else meter
                    mh_clean = re.sub(r"\s*\(\d+\)\s*$", "", mh).strip()
                    cond = re.sub(r"\s+", " ", label)[:80]
                    attrs = {"offering": mh_clean, "meter": mt, "amount": price[0], "currency": "USD", "unit": price[1], "tier": "standard", "region": None, "context_band": None, "condition": cond, "column": mh}
                    out.append(dict(kind="price_row", key=f"{tkey}:r{ri + 1}:c{ci}", parent=plan_key, attrs=attrs, text=f"{mh_clean}: {label} = {cells[ci]}", logical=f"price_row:{mh_clean.lower()}|{mt}|standard||{cond.lower()}", start=offs[ln], end=offs[ln] + len(lines[ln]),
                                    selector={"kind": "table", "table": ti + 1, "row": ri + 1, "column": ci, "row_key": label, "column_header": mh, "cell": cells[ci]}, roles={"offering": [mh_clean], "provider": [source_key.split("-")[0]]}))
    return out


def grammar_gemini(text, offs, source_key):
    """Gemini pricing.md is Markdoc: '## Model' sections, {% tab title="Standard|Batch" %} and {% table %} blocks whose rows are
    separated by '---' and whose cells are '* text' lines (a cell may continue on following lines). Row = Feature | Free tier | Paid tier.
    A paid cell may carry a dated schedule ("$2.00 through November 30, 2026. $4.00 starting December 1, 2026.") -> one price_row per dated price."""
    out = []
    lines = text.splitlines()
    cur = None
    tier = "standard"
    in_table = False
    row = []
    cell = None
    row_start = None
    n = 0

    def flush_row(end_line):
        nonlocal row, cell, n
        if cell is not None:
            row.append(cell)
        cell = None
        if len(row) >= 3 and cur:
            label = " ".join(row[0]).strip()
            paid = " ".join(row[2]).strip()
            meter, band, cond = meter_of(label)
            if meter and "$" in paid:
                parts = re.findall(r"\$\s?([\d.,]+)\s*([^$]*)", paid)
                for amt, tail in parts:
                    try:
                        amount = float(amt.replace(",", ""))
                    except ValueError:
                        continue
                    cond2 = tail.strip().rstrip(".").strip()
                    cond2 = re.sub(r"\s+", " ", cond2)[:120] or None
                    n += 1
                    attrs = {"offering": cur, "meter": meter, "amount": amount, "currency": "USD", "unit": "USD_per_1M_tokens", "tier": tier, "region": None, "context_band": None, "condition": cond2, "column": label[:80]}
                    out.append(dict(kind="price_row", key=f"gem:{n}", parent=None, attrs=attrs, text=f"{cur} ({tier}): {label} = ${amt} {cond2 or ''}".strip(), logical=f"price_row:{cur.lower()}|{meter}|{tier}||{re.sub(r'[^a-z0-9]+', ' ', label.lower()).strip()}|{(cond2 or '').lower()}", start=offs[row_start] if row_start is not None else 0, end=offs[end_line] + len(lines[end_line]),
                                    selector={"kind": "text_quote", "exact": f"{label}: {paid}"[:300], "line": (row_start or 0) + 1}, roles={"offering": [cur], "provider": ["google"]}))
        row = []

    for i, l in enumerate(lines):
        m = re.match(r"^## (.+?)\s*(\{%.*%\})?\s*$", l)
        if m:
            cur = m.group(1).strip()
            continue
        tm = re.search(r'\{%\s*tab\s+title="([^"]+)"', l)
        if tm:
            tier = "batch" if "batch" in tm.group(1).lower() else "standard"
            continue
        s = l.strip()
        if s.startswith("{% table"):
            in_table = True
            row = []
            cell = None
            row_start = i
            continue
        if s.startswith("{% /table"):
            flush_row(i)
            in_table = False
            continue
        if not in_table:
            continue
        if s == "---":
            flush_row(i)
            row_start = i + 1
            continue
        if s.startswith("* "):
            if cell is not None:
                row.append(cell)
            cell = [s[2:].strip()]
        elif cell is not None and s and not s.startswith("{%"):
            cell.append(s)
    return out


def grammar_releases(data):
    """GitHub releases JSON -> release_entry + change_item units (json pointers as selectors)."""
    out = []
    for i, rel in enumerate(data if isinstance(data, list) else []):
        body = rel.get("body") or ""
        version = rel.get("tag_name") or rel.get("name")
        breaking = bool(re.search(r"breaking|BREAKING|behaviou?r changes?", body + (rel.get("name") or "")))
        attrs = {"version": version, "released_on": (rel.get("published_at") or "")[:10], "title": rel.get("name"), "breaking": breaking, "url": rel.get("html_url"), "prerelease": bool(rel.get("prerelease"))}
        rk = f"rel:{i}"
        out.append(dict(kind="release_entry", key=rk, parent=None, attrs=attrs, text=f"{rel.get('name')} ({version}) released {attrs['released_on']}\n{body[:1500]}", logical=f"release_entry:{version}", start=None, end=None, selector={"kind": "json_pointer", "pointer": f"/{i}"}, roles={"release": [version], "software": []}))
        n = 0
        for line in body.splitlines():
            s = line.strip()
            if not re.match(r"^(\*|-|\d+\.)\s", s) or len(s) < 8:
                continue
            n += 1
            low = s.lower()
            kind = "breaking" if "breaking" in low else "added" if re.search(r"\bfeat|\badd", low) else "fixed" if "fix" in low else "deprecated" if "deprecat" in low else "removed" if "remov" in low else "security" if "secur" in low else "docs" if "doc" in low else "changed"
            comp = None
            cm = re.match(r"^[*-]\s*(?:feat|fix|chore|docs|refactor|release)\(([^)]+)\)", s)
            if cm:
                comp = cm.group(1)
            out.append(dict(kind="change_item", key=f"{rk}:c{n}", parent=rk, attrs={"kind": kind, "component": comp, "ordinal": n}, text=re.sub(r"^[*-]\s*", "", s)[:600], logical=f"change_item:{version}|{n}", start=None, end=None, selector={"kind": "json_pointer", "pointer": f"/{i}/body", "line": n}, roles={"software": [], "component": [comp] if comp else []}))
    return out


SPEC_PATTERNS = [
    (re.compile(r"^([\d,]+) context window", re.I), "context_window", "tokens"),
    (re.compile(r"^Maximum input tokens:\s*([\d,]+)", re.I), "max_input_tokens", "tokens"),
    (re.compile(r"^([\d,]+) max output tokens", re.I), "max_output_tokens", "tokens"),
    (re.compile(r"^(.+?) knowledge cutoff", re.I), "knowledge_cutoff", None),
    (re.compile(r"^Input modalities:\s*(.+)$", re.I), "input_modalities", None),
    (re.compile(r"^Output modalities:\s*(.+)$", re.I), "output_modalities", None),
    (re.compile(r"^Reasoning token support", re.I), "reasoning", None),
    (re.compile(r"^Default snapshot:\s*`?([^`]+)`?", re.I), "default_snapshot", None),
]


def grammar_model_page(units, text, offs, model_hint):
    """OpenAI model page: spec_field units from the Model details bullets + Text tokens price table + capability hints."""
    out = []
    lines = text.splitlines()
    n = 0
    for i, l in enumerate(lines):
        s = re.sub(r"^\s*[-*]\s*", "", l).strip()
        for pat, field, unit in SPEC_PATTERNS:
            m = pat.match(s)
            if m:
                n += 1
                val = m.group(1).replace(",", "") if m.groups() else "supported"
                if field in ("context_window", "max_input_tokens", "max_output_tokens"):
                    val = int(val)
                if field in ("input_modalities", "output_modalities"):
                    val = [x.strip() for x in val.split(",")]
                out.append(dict(kind="spec_field", key=f"spec:{field}", parent=None, attrs={"field": field, "value": val, "unit": unit}, text=s, logical=f"spec_field:{model_hint}|{field}", start=offs[i], end=offs[i] + len(l),
                                selector={"kind": "text_quote", "exact": s, "line": i + 1}, roles={"model": [model_hint]}))
                break
        if re.search(r"Tool calling requires|supports tool calling|function calling", s, re.I):
            n += 1
            out.append(dict(kind="spec_field", key="spec:tool_use", parent=None, attrs={"field": "tool_use", "value": "supported", "unit": None}, text=s, logical=f"spec_field:{model_hint}|tool_use", start=offs[i], end=offs[i] + len(l), selector={"kind": "text_quote", "exact": s, "line": i + 1}, roles={"model": [model_hint]}))
    return out


def grammar_anthropic_overview(tables, lines, offs):
    """Compare-models table: features as rows, models as columns -> spec_field per (model, feature); pricing rows become price_rows."""
    out = []
    for ti, (s, header, rows, e) in enumerate(tables):
        if not header or header[0].strip().lower() != "feature":
            continue
        models = [re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", h).strip() for h in header[1:]]
        for ri, (cells, ln) in enumerate(rows):
            feature = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", cells[0]).strip()
            fl = feature.lower()
            field = {"context window": "context_window", "max output": "max_output_tokens", "reliable knowledge cutoff": "knowledge_cutoff", "training data cut-off": "knowledge_cutoff", "knowledge cutoff": "knowledge_cutoff", "extended thinking": "reasoning", "comparative latency": "latency", "description": "description"}.get(fl)
            if fl.startswith("pricing") or "price" in fl or "/ mtok" in " ".join(cells).lower():
                field = "pricing"
            if not field:
                field = re.sub(r"[^a-z0-9]+", "_", fl).strip("_")[:40]
            for ci, model in enumerate(models, start=1):
                if ci >= len(cells):
                    continue
                cell = re.sub(r"<sup>.*?</sup>", "", cells[ci]).strip()
                if not cell:
                    continue
                if field == "pricing":
                    prices = re.findall(r"\$([\d.]+)\s*/\s*MTok\s*(input|output)", cell, re.I)
                    for amt, meter in prices:
                        out.append(dict(kind="price_row", key=f"ov:{ri}:{ci}:{meter}", parent=None, attrs={"offering": model, "meter": meter.lower() + "_tokens", "amount": float(amt), "currency": "USD", "unit": "USD_per_1M_tokens", "tier": "standard", "region": None, "context_band": None, "condition": None, "column": model}, text=f"{model}: {meter} ${amt}/MTok", logical=f"price_row:{model.lower()}|{meter.lower()}_tokens|standard||", start=offs[ln], end=offs[ln] + len(lines[ln]), selector={"kind": "table", "table": ti + 1, "row": ri + 1, "column": ci, "row_key": feature, "column_header": model, "cell": cell}, roles={"offering": [model], "provider": ["anthropic"]}))
                    continue
                val = cell
                if field in ("context_window", "max_output_tokens"):
                    m = re.search(r"([\d,.]+)\s*([kKmM])?", cell)
                    if m:
                        num = float(m.group(1).replace(",", ""))
                        mult = {"k": 1000, "m": 1_000_000}.get((m.group(2) or "").lower(), 1)
                        val = int(num * mult)
                out.append(dict(kind="spec_field", key=f"ov:{ri}:{ci}", parent=None, attrs={"field": field, "value": val, "unit": "tokens" if field in ("context_window", "max_output_tokens") else None}, text=f"{model}: {feature} = {cell}", logical=f"spec_field:{model.lower()}|{field}", start=offs[ln], end=offs[ln] + len(lines[ln]), selector={"kind": "table", "table": ti + 1, "row": ri + 1, "column": ci, "row_key": feature, "column_header": model, "cell": cell}, roles={"model": [model]}))
    return out


def grammar_talk(text, units, offs):
    """ai.engineer talk page: header, write-up sections (claim candidates), resources, slides, transcript segments."""
    out = []
    lines = text.splitlines()
    title = lines[0].lstrip("# ").strip() if lines else ""
    speakers_line = next((l.strip() for l in lines[1:6] if l.strip() and not l.startswith(("#", "["))), "")
    edition = next((l.strip() for l in lines[2:8] if re.match(r"^AI Engineer ", l.strip())), None)
    video = re.search(r"\[Video\]\((https://www\.youtube\.com/watch\?v=([^)&]+))\)", text)
    yt = video.group(2) if video else None
    speakers = [s.strip() for s in re.split(r",|&| and |·|/", speakers_line) if s.strip()] if speakers_line else []
    # speakers_line may be 'Name, Company' -> keep first as speaker, rest as affiliation when it looks like Name, Company
    affiliation = None
    if len(speakers) == 2 and " " in speakers[0] and not re.search(r"\b(and|&)\b", speakers_line):
        speakers, affiliation = [speakers[0]], speakers[1]
    out.append(dict(kind="talk_header", key="talk:header", parent=None, attrs={"title": title, "speakers": speakers, "track": None, "event": edition, "session_id": yt, "video_url": video.group(1) if video else None, "affiliation": affiliation}, text=f"{title}\n{speakers_line}\n{edition or ''}", logical=f"talk_header:{yt}", start=0, end=offs[min(4, len(offs) - 1)], selector={"kind": "text_quote", "exact": title}, roles={"speaker": speakers, "event": [edition] if edition else []}))
    # sections: writeup (before Resources/Slides/Full transcript), resources, slides, transcript
    sec_bounds = {}
    for u in units:
        if u["kind"] == "section" and u["attrs"]["level"] == 2:
            sec_bounds[u["attrs"]["heading"].lower()] = (u["start"], u["end"])
    res = sec_bounds.get("resources")
    slides = sec_bounds.get("slides")
    trans = sec_bounds.get("full transcript") or sec_bounds.get("transcript")
    n = 0
    for u in units:
        if u["kind"] == "section" and u["attrs"]["level"] == 3:
            inside_slides = slides and slides[0] <= u["start"] < slides[1]
            inside_trans = trans and trans[0] <= u["start"] < trans[1]
            if inside_slides:
                m = re.search(r"\[(\d+):(\d\d)(?::(\d\d))?\]\(https://www\.youtube\.com/watch\?v=[^&]+&t=(\d+)s\)", u["text"])
                t0 = int(m.group(4)) * 1000 if m else None
                n += 1
                out.append(dict(kind="slide", key=f"slide:{n}", parent="talk:header", attrs={"n": n, "title": u["attrs"]["heading"], "t0_ms": t0 if t0 is not None else -1}, text=u["text"][:2000], logical=f"slide:{n}", start=u["start"], end=u["end"], start_ms=t0, end_ms=None, selector={"kind": "media_timecode", "t0_ms": t0, "heading": u["attrs"]["heading"]}, roles={}))
            elif not inside_trans and not (res and res[0] <= u["start"] < res[1]):
                m = re.search(r"\[(\d+):(\d\d)(?::(\d\d))?\]\(https://www\.youtube\.com/watch\?v=[^&]+&t=(\d+)s\)", u["text"])
                t0 = int(m.group(4)) * 1000 if m else None
                out.append(dict(kind="talk_writeup", key=f"wu:{u['key']}", parent="talk:header", attrs={"heading": u["attrs"]["heading"], "path": u["attrs"]["path"], "t0_ms": t0}, text=u["text"][:3000], logical=f"talk_writeup:{u['attrs']['path']}", start=u["start"], end=u["end"], start_ms=t0, selector={"kind": "text_quote", "exact": u["attrs"]["heading"]}, roles={"mentions": [], "speaker": speakers}))
    if res:
        for u in units:
            if u["kind"] == "link" and res[0] <= u["start"] < res[1]:
                href = u["attrs"]["href"]
                rk = "repository" if "github.com" in href else "paper" if "arxiv.org" in href or "doi.org" in href else "video" if "youtube.com" in href or "youtu.be" in href else "docs" if "docs." in href or "/docs" in href else "website"
                out.append(dict(kind="talk_resource", key=f"res:{sha(href)[:10]}", parent="talk:header", attrs={"href": href, "text": u["attrs"]["text"], "resource_kind": rk}, text=f"{u['attrs']['text']} -> {href}", logical=f"talk_resource:{href}", start=u["start"], end=u["end"], selector={"kind": "text_quote", "exact": u["attrs"]["text"]}, roles={"references": [href]}))
    # transcript segments: timecoded lines inside the transcript section (fallback: all timecoded lines after the slides)
    seg = []
    for i, l in enumerate(lines):
        m = TIMECODE.match(l)
        if not m:
            continue
        if trans and not (trans[0] <= offs[i] < trans[1]):
            continue
        if not trans and slides and offs[i] < slides[1]:
            continue
        t0 = int(m.group(6)) * 1000
        seg.append((i, t0, m.group(7)))
    slide_times = sorted([(u["attrs"]["t0_ms"], u["attrs"]["n"]) for u in out if u["kind"] == "slide" and u["attrs"]["t0_ms"] is not None and u["attrs"]["t0_ms"] >= 0])
    for k, (i, t0, body) in enumerate(seg):
        t1 = seg[k + 1][1] if k + 1 < len(seg) else None
        slide_n = None
        for st, sn in slide_times:
            if st <= t0:
                slide_n = sn
        attrs = {"t0_ms": t0, "t1_ms": t1, "slide_n": slide_n}
        out.append(dict(kind="transcript_segment", key=f"seg:{t0}", parent="talk:header", attrs=attrs, text=body.strip()[:3000], logical=f"transcript_segment:{t0}", start=offs[i], end=offs[i] + len(lines[i]), start_ms=t0, end_ms=t1, selector={"kind": "media_timecode", "t0_ms": t0, "t1_ms": t1, "video": yt}, roles={"speaker": speakers, "mentions": []}))
    return out


def grammar_docs(units, kind_code):
    out = []
    for u in units:
        if u["kind"] == "section":
            vn = re.search(r"(v\d+(?:\.\d+)*|version \d+(?:\.\d+)*|deprecat\w+|breaking)", u["text"], re.I)
            out.append(dict(kind="docs_section" if kind_code != "repository_readme" else "readme_section", key=f"doc:{u['key']}", parent=None, attrs={"heading": u["attrs"]["heading"], "path": u["attrs"]["path"], **({"version_note": vn.group(1)} if vn and kind_code != "repository_readme" else {})}, text=u["text"][:3000], logical=f"docs_section:{u['attrs']['path']}", start=u["start"], end=u["end"], selector={"kind": "text_quote", "exact": u["attrs"]["heading"]}, roles={"software": [], "concept": []}))
        elif u["kind"] == "code_block" and kind_code != "repository_readme":
            sec = next((s for s in units if s["key"] == u["parent"]), None)
            out.append(dict(kind="code_example", key=f"ex:{u['key']}", parent=f"doc:{u['parent']}" if u["parent"] else None, attrs={"language": u["attrs"].get("language"), "demonstrates": sec["attrs"]["heading"] if sec else None, "path": sec["attrs"]["path"] if sec else None}, text=u["text"][:4000], logical=f"code_example:{(sec['attrs']['path'] if sec else '')}|{u['attrs'].get('language')}|{u['key']}", start=u["start"], end=u["end"], selector={"kind": "character_position", "start": u["start"], "end": u["end"]}, roles={"software": [], "demonstrates": [sec["attrs"]["heading"]] if sec else []}))
    return out


def grammar_post(units, published_at=None, byline=None):
    out = []
    n = 0
    for u in units:
        if u["kind"] in ("paragraph", "list_item") and len(u["text"]) > 30:
            n += 1
            mentions = [{"amount": float(a), "meter": m.lower().replace(" ", "_") + "_tokens", "models": [x.strip() for x in MODEL_NAME_RE.findall(u["text"])]} for a, m in PRICE_MENTION.findall(u["text"])]
            out.append(dict(kind="post_paragraph", key=f"post:{n}", parent=u["parent"], attrs={"ordinal": n, "byline": byline, "published_at": published_at, **({"price_mentions": mentions} if mentions else {}), "model_mentions": sorted(set(x.strip() for x in MODEL_NAME_RE.findall(u["text"])))}, text=u["text"], logical=f"post_paragraph:{n}", start=u["start"], end=u["end"], selector={"kind": "text_quote", "exact": u["text"][:300]}, roles={"mentions": sorted(set(x.strip() for x in MODEL_NAME_RE.findall(u["text"])))}))
    return out


def grammar_repo_record(data):
    out = []
    fields = {"full_name": data.get("full_name"), "description": data.get("description"), "stargazers_count": data.get("stargazers_count"), "forks_count": data.get("forks_count"), "open_issues_count": data.get("open_issues_count"),
              "license_spdx": (data.get("license") or {}).get("spdx_id"), "default_branch": data.get("default_branch"), "pushed_at": data.get("pushed_at"), "created_at": data.get("created_at"), "language": data.get("language"), "homepage": data.get("homepage")}
    for k, v in fields.items():
        if v is None:
            continue
        out.append(dict(kind="metadata_field", key=f"meta:{k}", parent=None, attrs={"key": k, "value": v}, text=f"{k}: {v}", logical=f"metadata_field:{k}", start=None, end=None, selector={"kind": "json_pointer", "pointer": "/" + k}, roles={}))
    return out


def grammar_sessions(data, tracks):
    out = []
    for i, s in enumerate(data.get("sessions", [])):
        if s.get("track") not in tracks:
            continue
        sid = sha(s.get("title", ""))[:16]
        out.append(dict(kind="talk_header", key=f"sess:{sid}", parent=None, attrs={"title": s.get("title"), "speakers": s.get("speakers") or [], "track": s.get("track"), "event": data.get("conference"), "session_id": sid, "day": s.get("day"), "time": s.get("time"), "room": s.get("room"), "type": s.get("type")}, text=f"{s.get('title')}\n{', '.join(s.get('speakers') or [])}\n{s.get('track')} | {s.get('day')} {s.get('time')}\n{(s.get('description') or '')[:1500]}", logical=f"talk_header:{sid}", start=None, end=None, selector={"kind": "json_pointer", "pointer": f"/sessions/{i}"}, roles={"speaker": s.get("speakers") or [], "event": [data.get("conference")]}))
    return out


def grammar_speakers(data, names):
    out = []
    for i, sp in enumerate(data.get("speakers", [])):
        if sp.get("name") not in names:
            continue
        out.append(dict(kind="metadata_field", key=f"spk:{sha(sp['name'])[:12]}", parent=None, attrs={"key": "speaker", "value": {"name": sp.get("name"), "role": sp.get("role"), "company": sp.get("company"), "linkedin": sp.get("linkedin")}}, text=f"{sp.get('name')} — {sp.get('role') or ''}, {sp.get('company') or ''}\n{(sp.get('bio') or '')[:600]}", logical=f"metadata_field:speaker|{sp['name']}", start=None, end=None, selector={"kind": "json_pointer", "pointer": f"/speakers/{i}"}, roles={}))
    return out


def grammar_ics(text):
    out = []
    for i, ev in enumerate(re.findall(r"BEGIN:VEVENT(.*?)END:VEVENT", text, flags=re.S)):
        for ln in ev.strip().splitlines():
            if ":" in ln:
                k, v = ln.split(":", 1)
                out.append(dict(kind="metadata_field", key=f"ics:{i}:{k}", parent=None, attrs={"key": k.strip(), "value": v.strip()}, text=f"{k.strip()}: {v.strip()}", logical=f"metadata_field:vevent{i}|{k.strip()}", start=None, end=None, selector={"kind": "text_quote", "exact": ln.strip()[:200]}, roles={}))
    return out
