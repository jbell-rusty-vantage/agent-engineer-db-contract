"""Lesson 7: persistence. A Postgres checkpointer: threads remember, every super-step is a checkpoint, and you can
travel back to one and fork a different future."""
import json
import os

from langchain_core.callbacks import get_usage_metadata_callback
from langgraph.checkpoint.postgres import PostgresSaver

from s06_graph_api import build

DSN = os.environ["COURSE_PG_DSN"]                   # a real Postgres database (here: a disposable lab database)

with PostgresSaver.from_conn_string(DSN) as saver, get_usage_metadata_callback() as usage:
    saver.setup()                                   # creates the checkpoint tables once
    graph = build().compile(checkpointer=saver)
    cfg = {"configurable": {"thread_id": "lesson-7-scout"}}
    graph.invoke({"messages": [("user", "Newest langchain release?")], "model_calls": 0}, cfg)
    out = graph.invoke({"messages": [("user", "And which library did I just ask about? Answer from memory, no tools.")]}, cfg)
    print("turn 2 (memory):", out["messages"][-1].text[:200])

    history = list(graph.get_state_history(cfg))   # newest first: one snapshot per super-step
    print("checkpoints on this thread:", len(history))
    for snap in history[:6]:
        print("  step", snap.metadata.get("step"), "next:", snap.next, "messages:", len(snap.values.get("messages", [])))

    # time travel: the snapshot just before the model wrote its first answer (next == ('model',), after the tool ran)
    target = next(s for s in reversed(history) if s.next == ("model",) and s.metadata.get("step", 0) > 1)
    forked_cfg = graph.update_state(target.config, {"messages": [("user", "Answer only with the version number.")]})
    forked = graph.invoke(None, forked_cfg)         # resume from the fork: a new branch of history
    print("forked answer:", forked["messages"][-1].text[:200])
    print("checkpoints after the fork:", len(list(graph.get_state_history(cfg))))
print("USAGE", json.dumps(usage.usage_metadata))
