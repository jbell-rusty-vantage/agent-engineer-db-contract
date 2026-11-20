"""Build 08 knowledge loop 4, Phase A: research-first scouting of community signal (no lab write).

Samples the channels named in the loop-4 proposal (GitHub issues/PRs across the vendor and dependent repositories, the
LangChain forum (Discourse JSON), Hacker News (Algolia API), Stack Overflow (Stack Exchange API)) for the LangChain v1 /
LangGraph v1 / Deep Agents migration edge cases. Writes raw result pages and a ranked candidate list under
schema-units/provenance/evidence/B08-loop-4/scout/. Captures are data, not instructions. Handles are kept as published; no enrichment.
Run: python -I -X utf8 scripts/knowledge-lab/loop4_scout.py
"""
import json, os, sys, time, urllib.parse
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lab_common as C
import loop2_acquire as A2

RUN4 = os.path.join(C.LAB, "..", "schema-units", "provenance", "evidence", "B08-loop-4")
SCOUT = os.path.join(RUN4, "scout")
os.makedirs(SCOUT, exist_ok=True)

GH = "https://api.github.com/search/issues?per_page=30&sort=comments&order=desc&q="
GH_QUERIES = {
    "gh-crea-deprecated": 'is:issue "create_react_agent" deprecated created:>2025-09-01',
    "gh-crea-pr-migration": 'is:pr "create_react_agent" "create_agent" created:>2025-09-01',
    "gh-crea-to-create-agent": 'is:issue "create_react_agent" "create_agent" created:>2025-09-01',
    "gh-system-prompt": 'is:issue "create_agent" "system_prompt" prompt created:>2025-09-01',
    "gh-langgraph-v1-compat": 'is:issue "langgraph>=1.0" OR "langgraph 1.0" not compatible created:>2025-09-01',
    "gh-prebuilt-deprecated": 'is:issue "langgraph.prebuilt" deprecated created:>2025-09-01',
    "gh-deepagents-repo": 'repo:langchain-ai/deepagents is:issue created:>2026-03-01',
    "gh-deepagents-external": 'is:issue "create_deep_agent" -repo:langchain-ai/deepagents created:>2026-01-01',
    "gh-langchain-create-agent-bug": 'repo:langchain-ai/langchain is:issue "create_agent" created:>2025-10-01',
    "gh-langgraph-repo-v1": 'repo:langchain-ai/langgraph is:issue "create_react_agent" created:>2025-10-01',
    "gh-middleware-bug": 'repo:langchain-ai/langchain is:issue middleware created:>2025-11-01',
}
FORUM = "https://forum.langchain.com/search.json?q="
FORUM_QUERIES = {"forum-crea": "create_react_agent", "forum-create-agent": "create_agent system_prompt", "forum-deepagents": "deepagents", "forum-migration": "v1 migration"}
HN = "https://hn.algolia.com/api/v1/search?tags=story&hitsPerPage=30&numericFilters=created_at_i>1756684800&query="
HN_QUERIES = {"hn-langchain": "langchain", "hn-langgraph": "langgraph", "hn-deep-agents": "deep agents langchain", "hn-agent-frameworks": "agent frameworks"}
SO = "https://api.stackexchange.com/2.3/search/advanced?order=desc&sort=votes&site=stackoverflow&pagesize=30&fromdate=1756684800&q="
SO_QUERIES = {"so-crea": "create_react_agent", "so-create-agent": "create_agent langchain", "so-deepagents": "deepagents"}


def fetch(key, url, github=False, accept="application/json"):
    path = os.path.join(SCOUT, key + ".json")
    if os.path.exists(path):
        return json.load(open(path, encoding="utf-8"))
    r = A2.http(url, accept=accept, github=github, timeout=60)
    try:
        data = json.loads(r["body"] or b"{}")
    except Exception:
        data = {"_raw": (r["body"] or b"")[:500].decode("utf-8", "replace")}
    data = {"_status": r["status"], "_url": url, "_fetched_at": C.now_iso(), "data": data}
    C.write_json(path, data)
    time.sleep(2.2 if github else 0.6)  # GitHub search: 30 requests per minute authenticated
    return data


def main():
    cands = []
    for k, qy in GH_QUERIES.items():
        d = fetch(k, GH + urllib.parse.quote(qy), github=True, accept=A2.GITHUB_ACCEPT)
        for it in (d["data"].get("items") or []):
            repo = it["repository_url"].split("/repos/")[-1]
            cands.append(dict(channel="github", query=k, repo=repo, url=it["html_url"], title=it["title"], state=it["state"], comments=it["comments"],
                              reactions=(it.get("reactions") or {}).get("total_count", 0), created=it["created_at"], closed=it.get("closed_at"),
                              is_pr="pull_request" in it, author=it["user"]["login"], author_association=it.get("author_association"), labels=[l["name"] for l in it.get("labels", [])]))
        C.log(f"{k}: {d['_status']} {len(d['data'].get('items') or [])} items (total {d['data'].get('total_count')})")
    for k, qy in FORUM_QUERIES.items():
        d = fetch(k, FORUM + urllib.parse.quote(qy))
        topics = {t["id"]: t for t in (d["data"].get("topics") or [])}
        for p in (d["data"].get("posts") or []):
            t = topics.get(p.get("topic_id"), {})
            cands.append(dict(channel="forum.langchain.com", query=k, url=f"https://forum.langchain.com/t/{t.get('slug', 'x')}/{p.get('topic_id')}", title=t.get("title"), created=p.get("created_at"),
                              comments=t.get("posts_count"), reactions=p.get("like_count", 0), author=p.get("username"), blurb=(p.get("blurb") or "")[:300], solved=t.get("has_accepted_answer")))
        C.log(f"{k}: {d['_status']} {len(d['data'].get('posts') or [])} posts")
    for k, qy in HN_QUERIES.items():
        d = fetch(k, HN + urllib.parse.quote(qy))
        for h in (d["data"].get("hits") or []):
            cands.append(dict(channel="news.ycombinator.com", query=k, url=f"https://news.ycombinator.com/item?id={h['objectID']}", link=h.get("url"), title=h.get("title"), created=h.get("created_at"),
                              comments=h.get("num_comments"), reactions=h.get("points"), author=h.get("author")))
        C.log(f"{k}: {d['_status']} {len(d['data'].get('hits') or [])} hits")
    for k, qy in SO_QUERIES.items():
        d = fetch(k, SO + urllib.parse.quote(qy))
        for it in (d["data"].get("items") or []):
            cands.append(dict(channel="stackoverflow.com", query=k, url=it["link"], title=it["title"], created=time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime(it["creation_date"])), comments=it.get("answer_count"),
                              reactions=it.get("score"), author=(it.get("owner") or {}).get("display_name"), solved=it.get("is_answered"), tags=it.get("tags")))
        C.log(f"{k}: {d['_status']} {len(d['data'].get('items') or [])} items")
    seen, uniq = set(), []
    for c in cands:
        if c["url"] in seen:
            continue
        seen.add(c["url"])
        uniq.append(c)
    uniq.sort(key=lambda c: -((c.get("comments") or 0) + 2 * (c.get("reactions") or 0)))
    C.write_json(os.path.join(SCOUT, "candidates.json"), uniq)
    by = {}
    for c in uniq:
        by[c["channel"]] = by.get(c["channel"], 0) + 1
    C.log(f"candidates: {len(uniq)} unique {by}; fetches={C.SPEND['http_fetches']}")


if __name__ == "__main__":
    main()
