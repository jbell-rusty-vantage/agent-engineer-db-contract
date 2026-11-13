"""P17: prompt template formats and HTML escaping (langchain issue, open 2026-11-12: 7a14f69c, 28a30bff, b6133009)."""
import warnings
from _fake import *
warnings.simplefilter("ignore")
VAL = '<b>&"x"</b>'
ESCAPED = "v=&lt;b&gt;&amp;&quot;x&quot;&lt;/b&gt;"


def run():
    from langchain_core.prompts import PromptTemplate
    out = {}
    out["mustache"] = PromptTemplate.from_template("v={{x}}", template_format="mustache").format(x=VAL)
    out["mustache_triple"] = PromptTemplate.from_template("v={{{x}}}", template_format="mustache").format(x=VAL)
    out["f_string"] = PromptTemplate.from_template("v={x}").format(x=VAL)
    j, ej = attempt(lambda: PromptTemplate.from_template("v={{ x }}", template_format="jinja2").format(x=VAL))
    out["jinja2"], out["jinja2_error"] = j, ej
    return out


out, err = attempt(run)
o = out or {}
emit("P17", {"result": out, "error": err, "value": VAL},
     {"ran": out is not None, "mustache_escapes": o.get("mustache") == ESCAPED, "mustache_output": o.get("mustache"),
      "triple_unescaped": o.get("mustache_triple") == "v=" + VAL, "f_string_unescaped": o.get("f_string") == "v=" + VAL,
      "jinja2_available": o.get("jinja2") is not None, "jinja2_unescaped": (o.get("jinja2") == "v=" + VAL) if o.get("jinja2") is not None else None})
