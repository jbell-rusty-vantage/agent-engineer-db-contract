"""Release Scout: the course's running example. Three tools over data exported from the AI Engineer knowledge base
(PyPI release histories captured 2026-11-13; 13 claims verified through a Knowledge Services admission)."""
import json
import pathlib

from langchain.tools import tool

DATA = json.loads((pathlib.Path(__file__).parent / "data" / "release_scout.json").read_text(encoding="utf-8"))
LIBS = DATA["libraries"]
MODEL = "anthropic:claude-haiku-4-5"


@tool
def latest_release(library: str) -> str:
    """Return the newest release of a library and its date.
    library: one of langchain, langchain-core, langgraph, deepagents, langgraph-sdk, langgraph-cli."""
    lib = LIBS.get(library.lower().strip())
    if not lib:
        return f"unknown library {library!r}; known: {', '.join(LIBS)}"
    day, version = lib["latest"]
    return f"{library} {version} (published {day}); {lib['count']} releases since {lib['first'][1]} on {lib['first'][0]}"


@tool
def release_lines(library: str) -> str:
    """Return the date each minor version line (0.1, 0.2, ..., 1.0, 1.1, ...) of a library first shipped."""
    lib = LIBS.get(library.lower().strip())
    if not lib:
        return f"unknown library {library!r}"
    return "; ".join(f"{line} on {first[0]} ({first[1]})" for line, first in lib["minor_lines"].items())


@tool
def verified_facts(topic: str) -> str:
    """Return verified, probe-tested facts about the create_react_agent -> create_agent -> Deep Agents migration
    whose text mentions the topic (for example: prompt, deprecat, pydantic, classic, ToolMessage, swarm)."""
    hits = [c for c in DATA["verified_claims"] if topic.lower() in c["statement"].lower()]
    if not hits:
        return f"no verified fact mentions {topic!r}"
    return "\n".join(f"- {c['statement']} [probe {c['probe']}, verified {c['verified_on']}]" for c in hits)


TOOLS = [latest_release, release_lines, verified_facts]
