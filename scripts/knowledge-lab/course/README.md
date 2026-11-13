# Course module prototype: Agents That Act (LangChain 1.5, LangGraph 1.2, Deep Agents 0.7)

Prototype for review, not a released course. Thirteen lesson snippets that were run on 2026-11-13 against pinned releases
(langchain 1.5.0, langgraph 1.2.21, deepagents 0.7.38, langchain-anthropic 1.7.10, langgraph-cli[inmem], langgraph-checkpoint-postgres)
with `claude-haiku-4-5`, a disposable Postgres database (`course_demo` on the replay stack) and a local Agent Server (`langgraph dev`).

- `scout.py`: the Release Scout tools; their data (`data/release_scout.json`) is exported from the AI Engineer knowledge base
  (PyPI release histories captured 2026-11-13, 13 claims verified through a Knowledge Services admission).
- `s01`–`s13`, `deploy/`: the lessons. `run_course.py` runs them and records stdout, tokens and cost in `11-build04-lab/course-prototype/outputs/`.
- `build_artifact.py` + `artifact_template.html`: build the module page from the files that ran and their recorded outputs.

Run: `python -I -X utf8 scripts/knowledge-lab/course/run_course.py [s01 ...]`, then
`python -I -X utf8 scripts/knowledge-lab/course/build_artifact.py <out.html>`.
