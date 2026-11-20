"""Build 08 loop 1, M4: layout A (kind spaces, scope resolved first) vs layout B (one topical space) on the same embedded items.

Six probe queries with a known target unit; each runs through api.search_unified with a real query embedding in both layouts
(A: the one space the question shape names; B: knowledge_text with the same facets). Records rank of the expected target, top
score and candidate counts to LAYOUTS.json next to the cycle record. Spend: six embedding calls.
"""
import os, sys, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lab_common import *  # noqa

OUT = r"C:\Users\Pinda\Proyectos\BellLabs\platform\ai-engineer-research-2026-11-02\schema-units\provenance\evidence\B08-loop-1\LAYOUTS.json"
PROBES = [
    ("transcript passage about slop and judgment", "the war against slop: judgment is scarce, generation is cheap", "units", {"document_types": ["aie_talk"], "unit_kinds": ["transcript_segment", "talk_writeup"]}, "no more slop"),
    ("price row for GPT-6.1 Terra input", "GPT-6.1 Terra input tokens price per million", "units", {"document_types": ["pricing_page", "product_page"], "unit_kinds": ["price_row"]}, "gpt-6.1-terra"),
    ("docs passage on checkpointers", "resume a LangGraph run from the last checkpoint after a crash", "units", {"document_types": ["framework_docs_page", "release_notes", "repository_readme"]}, "checkpoint"),
    ("entity card for a model offering", "Claude Haiku 5.5 on the Anthropic API offering", "entity_cards", {}, "haiku 5.5"),
    ("digest of a release", "LangGraph SDK release adding strict_resume to runs", "digests", {}, "strict_resume"),
    ("claim about a release date", "openai-agents-python alpha release published with breaking changes", "assertions", {}, "alpha"),
]


def run(space_slugs, emb, text, facets, lenses):
    def arr(v):
        return qarr(v) if v else "null"
    stmt = f"""select json_build_object('snippet', snippet, 'score', fused_score, 'channels', channel_scores, 'unit_kind', unit_kind, 'space', space_slug, 'doc', document_type_code)
      from api.search_unified({q(text)}, {q(vec_literal(emb))}::extensions.halfvec(1536), {qarr(lenses)}, null, {arr(space_slugs)}, {arr(facets.get('document_types'))}, {arr(facets.get('unit_kinds'))}, null, null, null, null, null, 10, 200, 60)"""
    return sql_json(stmt)


def main():
    results = []
    embs = embed_texts([p[1] for p in PROBES])
    for (label, text, space, facets, needle), emb in zip(PROBES, embs):
        lenses = ["evidence"] if space == "assertions" else ["corpus"]
        a = run([space], emb, text, facets, lenses)
        b = run(["knowledge_text"], emb, text, facets, lenses)
        b_nofacet = run(["knowledge_text"], emb, text, {}, ["corpus", "evidence"])
        def rank(rows):
            for i, r in enumerate(rows):
                if needle.lower() in (r.get("snippet") or "").lower():
                    return i + 1
            return None
        results.append({"probe": label, "query": text, "needle": needle, "layout_A": {"space": space, "facets": facets, "rank_of_target": rank(a), "top": (a or [{}])[0].get("snippet", "")[:120], "n": len(a)},
                        "layout_B_same_facets": {"rank_of_target": rank(b), "top": (b or [{}])[0].get("snippet", "")[:120], "n": len(b)},
                        "layout_B_no_facets": {"rank_of_target": rank(b_nofacet), "top": (b_nofacet or [{}])[0].get("snippet", "")[:120], "n": len(b_nofacet)}})
        log(f"{label}: A rank={results[-1]['layout_A']['rank_of_target']} B(facets) rank={results[-1]['layout_B_same_facets']['rank_of_target']} B(no facets) rank={results[-1]['layout_B_no_facets']['rank_of_target']}")
    summary = {"probes": results, "spend": SPEND, "reading": "A and B carry the same items; with the same facet predicates B equals A in practice (facets do the scoping), while B without facets shows how far rank drifts when the scope is not resolved first."}
    write_json(OUT, summary)
    return summary


if __name__ == "__main__":
    main()
