"""The deployable graph: the same Release Scout agent, exported as a module-level graph for the Agent Server.
No checkpointer here: the server provides persistence (threads, checkpoints, runs) itself."""
import sys
import pathlib

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
from langchain.agents import create_agent  # noqa: E402
from scout import MODEL, TOOLS  # noqa: E402

agent = create_agent(model=MODEL, tools=TOOLS,
                     system_prompt="You are Release Scout, deployed on an Agent Server. Use your tools and answer briefly.")
