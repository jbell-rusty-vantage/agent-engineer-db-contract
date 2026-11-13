"""Lesson 12: call the deployed agent over HTTP. Threads, runs and streaming come from the Agent Server API; the same
graph is also usable as a RemoteGraph inside another graph."""
import asyncio
import json

from langgraph.pregel.remote import RemoteGraph
from langgraph_sdk import get_client

URL = "http://127.0.0.1:2024"


async def main():
    client = get_client(url=URL)
    assistants = await client.assistants.search()
    print("assistants on the server:", [(a["graph_id"], a["assistant_id"][:8]) for a in assistants])
    thread = await client.threads.create()
    print("thread:", thread["thread_id"])
    async for part in client.runs.stream(thread["thread_id"], "release_scout",
                                         input={"messages": [{"role": "user", "content": "Newest langgraph release?"}]},
                                         stream_mode="updates"):
        if part.event == "updates":
            for node, update in part.data.items():
                last = update["messages"][-1]
                print(f"  server event [{node}]", [c["name"] for c in last.get("tool_calls") or []] or str(last.get("content"))[:200])
    state = await client.threads.get_state(thread["thread_id"])
    print("server-side checkpoint holds", len(state["values"]["messages"]), "messages; next:", state["next"])
    history = await client.threads.get_history(thread["thread_id"])
    print("checkpoints kept by the server for this thread:", len(history))
    runs = await client.runs.list(thread["thread_id"])
    print("runs on the thread:", [(r["run_id"][:8], r["status"]) for r in runs])

    remote = RemoteGraph("release_scout", url=URL)  # a deployed graph used like a local one
    out = remote.invoke({"messages": [{"role": "user", "content": "How many releases has deepagents shipped?"}]})
    print("RemoteGraph answer:", out["messages"][-1]["content"] if isinstance(out["messages"][-1], dict) else out["messages"][-1])


asyncio.run(main())
