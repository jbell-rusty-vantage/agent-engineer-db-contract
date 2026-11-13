"""P18: LengthBasedExampleSelector after a failed add_example (langchain issue, opened 2026-11-13: 1a5b70c6, 26b950e1, a7c3b8d9)."""
import asyncio, warnings
from _fake import *
warnings.simplefilter("ignore")


def build():
    from langchain_core.example_selectors import LengthBasedExampleSelector
    from langchain_core.prompts import PromptTemplate
    p = PromptTemplate.from_template("Q: {question}\nA: {answer}")
    return LengthBasedExampleSelector(examples=[{"question": "1+1", "answer": "2"}], example_prompt=p, max_length=200)


def run():
    s = build()
    _, add_err = attempt(lambda: s.add_example({"question": "2+2"}))
    lens = {"examples": len(s.examples), "lengths": len(s.example_text_lengths)}
    sel, sel_err = attempt(lambda: s.select_examples({"question": "3+3"}))
    s2 = build()
    _, aadd_err = attempt(lambda: asyncio.run(s2.aadd_example({"question": "2+2"})))
    lens2 = {"examples": len(s2.examples), "lengths": len(s2.example_text_lengths)}
    return {"add_error": add_err, "after_add": lens, "select": sel, "select_error": sel_err, "aadd_error": aadd_err, "after_aadd": lens2}


out, err = attempt(run)
o = out or {}
emit("P18", {"result": out, "error": err},
     {"ran": out is not None, "add_raises_keyerror": (o.get("add_error") or {}).get("type") == "KeyError",
      "examples_longer_than_lengths": bool(o) and o["after_add"]["examples"] == o["after_add"]["lengths"] + 1,
      "select_raises_indexerror": (o.get("select_error") or {}).get("type") == "IndexError",
      "aadd_same": bool(o) and (o.get("aadd_error") or {}).get("type") == "KeyError" and o["after_aadd"]["examples"] == o["after_aadd"]["lengths"] + 1})
