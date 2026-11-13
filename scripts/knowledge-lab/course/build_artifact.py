"""Build the course-module prototype page from the snippet files that ran and the outputs they printed.
Run: python -I -X utf8 scripts/knowledge-lab/course/build_artifact.py <out.html>"""
import html, json, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
import lab_common as C

OUT_DIR = os.path.join(C.LAB, "course-prototype", "outputs")
HIST = json.load(open(os.path.join(C.LAB, "knowledge-loop-5", "release-history-from-captures.json"), encoding="utf-8"))
E = html.escape


def out(name):
    return json.load(open(os.path.join(OUT_DIR, name + ".json"), encoding="utf-8"))


def mermaid_of(text):
    m = re.search(r"---\nconfig:.*?\n---\n(graph TD;.*?)(?=\n\s*classDef|\n\S)", text, re.S)
    if not m:
        return None
    body = re.sub(r"\n\s*classDef.*", "", m.group(1)).replace(":::first", "").replace(":::last", "")
    body = re.sub(r"\(\[<p>__(\w+)__</p>\]\)", r"([\1])", body)
    body = re.sub(r"\((\w+)<hr/><small><em>__tools = ([^<]+)</em></small>\)", r'["\1: \2"]', body)
    return body


def clean_output(text):
    text = re.sub(r"---\nconfig:.*?classDef last fill:#bfb6fc\n", "[graph printed with draw_mermaid(); rendered as the diagram in this lesson]\n", text, flags=re.S)
    lines = [l for l in text.splitlines() if not l.startswith("USAGE ")]
    if len(lines) > 60:
        lines = lines[:58] + ["…", f"({len(lines) - 58} more lines in the recorded output)"]
    return "\n".join(lines).strip()


SNIPS = {}
for name, file, outs in [("s01_tool_calling", "s01_tool_calling.py", ["s01_tool_calling"]), ("s02_create_agent", "s02_create_agent.py", ["s02_create_agent"]),
                         ("s03_event_streaming", "s03_event_streaming.py", ["s03_event_streaming"]), ("s04_structured_output", "s04_structured_output.py", ["s04_structured_output"]),
                         ("s05_middleware_hitl", "s05_middleware_hitl.py", ["s05_middleware_hitl"]), ("s06_graph_api", "s06_graph_api.py", ["s06_graph_api"]),
                         ("s07_persistence_postgres", "s07_persistence_postgres.py", ["s07_persistence_postgres"]), ("s08_durable_interrupt", "s08_durable_interrupt.py", ["s08a_start", "s08b_resume"]),
                         ("s09_send_map_reduce", "s09_send_map_reduce.py", ["s09_send_map_reduce"]), ("s10_multi_agent", "s10_multi_agent.py", ["s10_multi_agent"]),
                         ("s11_deep_agent", "s11_deep_agent.py", ["s11_deep_agent"]), ("s12_deploy", os.path.join("deploy", "client.py"), ["s12_deploy"]),
                         ("s12_agent", os.path.join("deploy", "agent.py"), []), ("s12_config", os.path.join("deploy", "langgraph.json"), []),
                         ("s13_eval", "s13_eval_tool_descriptions.py", ["s13_eval_tool_descriptions"]), ("scout", "scout.py", [])]:
    code = open(os.path.join(HERE, file), encoding="utf-8").read().strip()
    recs = [out(o) for o in outs]
    output = "\n\n".join((f"$ python {r['args'][0]} {' '.join(r['args'][1:])}\n" if len(outs) > 1 else "") + clean_output(r["stdout"]) for r in recs) if recs else "(no output: this file is imported by the lessons)"
    SNIPS[name] = {"file": file.replace("\\", "/"), "code": code, "output": output,
                   "tokens_in": sum(r["tokens_in"] for r in recs), "tokens_out": sum(r["tokens_out"] for r in recs), "usd": round(sum(r["usd"] for r in recs), 4),
                   "seconds": round(sum(r["seconds"] for r in recs), 1), "ran_at": recs[-1]["ran_at"] if recs else None, "exit": max([r["exit_code"] for r in recs] or [0]),
                   "mermaid": mermaid_of(recs[0]["stdout"]) if recs else None}
TOTAL = round(sum(s["usd"] for s in SNIPS.values()), 2)


def run_box(name, label=None, start="code"):
    s = SNIPS[name]
    meta = (f"<span>ran {s['ran_at'][:16].replace('T', ' ')}Z</span><span>exit {s['exit']}</span><span>{s['seconds']} s</span><span>{s['tokens_in']:,} in / {s['tokens_out']:,} out tokens</span><span>${s['usd']}</span>"
            if s["ran_at"] else "<span>support file</span>")
    return (f'<div class="run" data-snippet="{name}"><div class="bar"><span class="file">{E(label or s["file"])}</span><span class="tabs" role="tablist">'
            f'<button type="button" role="tab" data-view="code" aria-selected="{str(start == "code").lower()}">Code</button>'
            f'<button type="button" role="tab" data-view="out" aria-selected="{str(start == "out").lower()}">What it printed</button>'
            f'<button type="button" class="copy">Copy</button></span></div>'
            f'<pre class="code"{" hidden" if start == "out" else ""}></pre><pre class="out"{" hidden" if start == "code" else ""}></pre><div class="meta">{meta}</div></div>')


def mermaid(name, caption):
    m = SNIPS[name]["mermaid"]
    return f'<figure><pre class="mermaid">{E(m)}</pre><figcaption>{caption} Printed by <code>get_graph().draw_mermaid()</code>; HTML labels simplified for display.</figcaption></figure>' if m else ""


def callout(kind, label, body):
    return f'<div class="callout {kind}"><span class="k">{label}</span><span>{body}</span></div>'


def checks(items):
    return '<div class="check"><h4>Check yourself</h4>' + "".join(f"<details><summary>{q}</summary><p>{a}</p></details>" for q, a in items) + "</div>"


def tutor(chips):
    return ('<div class="tutor"><span class="eyebrow">Ask the tutor about this lesson</span><div class="chips">' + "".join(f'<button type="button">{E(c)}</button>' for c in chips) +
            '</div><div class="row"><textarea aria-label="Your question" placeholder="Ask about the code, the output or the idea"></textarea><button type="button" class="ask">Ask</button></div><div class="answer muted"></div></div>')


V = '<span class="src ver">verified</span>'
P = '<span class="src probe">probe</span>'
K = '<span class="src kb">KB · docs</span>'
R = '<span class="src ran">ran</span>'
G = '<span class="src gk">general knowledge</span>'
T = '<span class="src kb">KB · talk</span>'

LESSONS = []


def lesson(id_, num, level, title, prose, body, call, chk, chips):
    LESSONS.append(f'<section class="block" id="{id_}"><div class="lesson-head"><span class="num">LESSON {num} · {level}</span><h2>{title}</h2></div>'
                   f'<div class="prose">{prose}</div>{body}<div class="callouts">{"".join(call)}</div>{checks(chk)}{tutor(chips)}</section>')


s1 = SNIPS["s01_tool_calling"]
lesson("l1", 1, "BEGINNER", "Tool calling by hand: the whole idea of an agent",
       "<p>A chat model takes a list of messages and returns a message. <code>init_chat_model(\"anthropic:claude-haiku-4-5\")</code> builds one for any provider from a single string. "
       "<code>bind_tools</code> sends each tool's name, docstring and argument schema with every request. The model may answer with text, or with <code>tool_calls</code>: the name of a function and arguments it chose.</p>"
       "<p>Run the call yourself, wrap the result in a <code>ToolMessage</code> that carries the call's id, and ask again. That loop (model, tool, model) is what every framework in this module automates.</p>"
       "<p>The Release Scout tools live in one small file, shared by every lesson. They read data exported from our knowledge base.</p>",
       f'<div class="two">{run_box("s01_tool_calling", start="out")}{run_box("scout", "scout.py (the shared tools)")}</div>',
       [callout("real", "What happened when it ran", f"The model picked <code>latest_release</code> and the argument <code>library=\"langgraph\"</code> itself, from the docstring alone, then answered from the tool's text. {R}"),
        callout("design", "The docstring is the interface", "The model never sees your code, only the tool's name, docstring and parameter types. Lesson 13 shows a docstring changing an agent's accuracy from 2 of 8 to 8 of 8."),
        callout("evidence", "History in one call", "In 2022 the same exchange was a block of text your code had to parse (lesson 0). Native tool calls are typed and carry an id, so several calls can run in one turn and their results can be matched back.")],
       [("Why does the ToolMessage need the tool call's id?", "A model may request several calls in one turn. The id ties each result to the call that asked for it; providers reject a result with no matching call."),
        ("What decides which tool the model calls?", "Only what you send: the conversation, the tool names, docstrings and argument schemas. Better descriptions beat cleverer prompts.")],
       ["Why use init_chat_model instead of ChatAnthropic directly?", "What happens if the model calls a tool that throws?"])

lesson("l2", 2, "BEGINNER", "create_agent: the loop as a graph",
       "<p><code>langchain.agents.create_agent</code> is the one high-level abstraction LangChain 1.0 kept. You pass a model, tools and a <code>system_prompt</code>; it returns a compiled LangGraph graph with two nodes, <code>model</code> and <code>tools</code>, and an edge that loops until the model stops asking for tools.</p>"
       "<p><code>stream(..., stream_mode=\"updates\")</code> yields one event per step, keyed by the node that ran. The diagram below was printed by the agent itself with <code>get_graph().draw_mermaid()</code>.</p>",
       f'<div class="two">{run_box("s02_create_agent")}{mermaid("s02_create_agent", "The compiled agent, drawn by LangGraph: dotted edges are conditional (does the last message contain tool calls?).")}</div>'
       '<div class="tbl"><table><thead><tr><th>If your tutorial says</th><th>Today (langchain 1.5 / langgraph 1.2)</th><th>Evidence</th></tr></thead><tbody>'
       f'<tr><td><code>from langgraph.prebuilt import create_react_agent</code></td><td><code>from langchain.agents import create_agent</code>; the prebuilt still works but warns <code>LangGraphDeprecatedSinceV10</code> and names <code>create_agent</code></td><td>{V} probe P1, 5 dated environments</td></tr>'
       f'<tr><td><code>prompt=...</code></td><td><code>system_prompt=...</code>; dynamic prompts move to middleware. <code>prompt=</code> raises <code>TypeError</code>, it is not silent</td><td>{V} P2 · the "silently renamed" claim is disputed</td></tr>'
       f'<tr><td>filter stream updates on node <code>"agent"</code></td><td>the node is <code>"model"</code>; code filtering on <code>"agent"</code> matches nothing, without an error</td><td>{V} P3</td></tr>'
       f'<tr><td><code>create_react_agent(..., middleware=..., system_prompt=...)</code></td><td>the prebuilt has neither keyword; both raise <code>TypeError</code></td><td>{V} P4</td></tr>'
       f'<tr><td><code>AgentExecutor</code>, chains, <code>langchain.hub</code></td><td>moved to <code>langchain-classic</code></td><td>{V} P6</td></tr>'
       f'<tr><td>the docs link for <code>create_react_agent</code></td><td>points to the langchain-classic text-ReAct function, whose signature differs from the prebuilt</td><td>{V} P7</td></tr>'
       '</tbody></table></div>',
       [callout("real", "What happened", f"The model chose <code>release_lines</code>, read the dates, and computed the gap between 1.0 (2025-10-17) and 1.1 (2026-03-10) itself. {R}"),
        callout("watch", "Silent breakage", "The streaming node rename is the dangerous one: nothing raises, your progress bar just stops updating. Search your code for <code>\"agent\"</code> after migrating.")],
       [("What does create_agent return?", "A compiled LangGraph graph (CompiledStateGraph). Everything a graph can do, it can do: checkpointers, interrupts, streaming, deployment."),
        ("Why did LangChain 1.0 remove most chains?", "LangGraph had become the way to build anything more than one model call; one agent abstraction on top of it replaced the old chains (the old ones live on in langchain-classic).")],
       ["How do I add memory to this agent?", "What does the dotted edge in the diagram mean?"])

lesson("l3", 3, "BEGINNER", "Streaming events: text, tool calls and state, separately",
       f"<p>LangChain 1.3 added <b>event streaming</b>: <code>agent.stream_events(..., version=\"v3\")</code> returns a stream you can <code>interleave</code> by projection (messages, tool calls, values, subgraphs) instead of branching on <code>stream_mode</code> chunks {K}. Each message projection yields text as it arrives; each tool-call projection exposes its input, its output deltas and its final output.</p>"
       "<p>The older <code>stream_mode</code> values still work: <code>updates</code> (what each node returned), <code>values</code> (the full state after each step), <code>messages</code> (model tokens), <code>custom</code> (anything a node writes to the stream writer) and <code>debug</code>.</p>",
       run_box("s03_event_streaming", start="out"),
       [callout("real", "A bug we made, and fixed", f"The first run printed <code>tool result: None</code>: we read <code>item.output</code> before draining <code>item.output_deltas</code>. The docs' example drains first, and so does this code now. {R}"),
        callout("design", "Why projections", "A UI usually wants tokens in one place, tool activity in another and the final state at the end. Projections let each consumer read only what it needs.")],
       [("When would you use stream_mode='updates' instead of event streaming?", "For logging and step-by-step progress: one event per node, already keyed by node name, as in lesson 2.")],
       ["How do I stream tokens to a web page?", "What is the difference between values and updates?"])

lesson("l4", 4, "BEGINNER", "Structured output: shape is guaranteed, truth is not",
       "<p>Pass a Pydantic model as <code>response_format</code> and the agent's final answer arrives in <code>result[\"structured_response\"]</code> as a validated object. create_agent uses the provider's native structured output when the model supports it and a tool-based strategy otherwise.</p>"
       "<p>Read the output below carefully. The plan has exactly the fields we asked for, each change cites evidence, and one line is still wrong.</p>",
       run_box("s04_structured_output", start="out"),
       [callout("watch", "Catch the model", "The first change says <code>from langchain import create_agent</code>. The correct import is <code>from langchain.agents import create_agent</code>, and none of the verified facts the plan cites contains an import path: the model filled the gap. Validation checked the <i>shape</i>; it cannot check the <i>truth</i>."),
        callout("evidence", "What is verified here", f"The rename (P2), the deprecation (P1) and the Pydantic-state behaviour (P5: <code>create_agent</code> accepts a Pydantic <code>state_schema</code> but no longer validates it; the prebuilt raised <code>ValidationError</code>) are all {V}."),
        callout("design", "Make truth checkable", "Put an <code>evidence</code> field in every schema, as here, and test it: an evidence string that is not one of the tool outputs is a hallucination you can detect in code.")],
       [("How would you detect the wrong import automatically?", "Check each change's 'after' code against a source of truth: import it in a pinned environment, or require its text to appear in a verified fact."),
        ("Where does the structured answer live in the result?", "result['structured_response']; the message history is still in result['messages'].")],
       ["Can I use a TypedDict instead of Pydantic?", "What happens when the model's output fails validation?"])

lesson("l5", 5, "INTERMEDIATE", "Middleware: hooks around the model and the tools, and a human gate",
       f"<p>Middleware is how LangChain 1.0 replaced dozens of agent variants with one agent. A middleware can run <code>before_agent</code>, <code>before_model</code>, <code>after_model</code> and <code>after_agent</code>, or wrap each call with <code>wrap_model_call</code> and <code>wrap_tool_call</code> {K}. Decorators (<code>@before_model</code>, <code>@wrap_tool_call</code>, <code>@dynamic_prompt</code>) cover the simple cases; subclass <code>AgentMiddleware</code> for state and configuration.</p>"
       f"<p>The built-in set {K}: tool error, tool retry, model retry, model fallback, model refusal, summarization, human-in-the-loop, model call limit, tool call limit, PII detection, to-do list, LLM tool selector, provider tool search, shell tool, filesystem, subagent, rubric grading, file search, context editing, LLM tool emulator.</p>"
       "<p><code>HumanInTheLoopMiddleware(interrupt_on={...})</code> pauses before a tool runs. The paused run is saved in the checkpointer; the reviewer answers with <code>approve</code>, <code>edit</code>, <code>reject</code> or <code>respond</code>, and <code>Command(resume=...)</code> continues it.</p>",
       '<figure><div class="diagram-scroll"><svg viewBox="0 0 900 190" role="img" aria-label="Middleware hook points in the agent loop"><g font-size="12">'
       '<rect x="10" y="70" width="110" height="46" rx="8" style="fill: var(--soft); stroke: var(--line)"></rect><text x="22" y="98">input</text>'
       '<rect x="170" y="56" width="150" height="74" rx="8" style="fill: color-mix(in srgb, var(--accent) 14%, var(--paper)); stroke: var(--accent)"></rect><text x="186" y="86" font-weight="600">model node</text><text x="186" y="106" class="mut">wrap_model_call</text>'
       '<rect x="420" y="56" width="150" height="74" rx="8" style="fill: color-mix(in srgb, var(--kb) 14%, var(--paper)); stroke: var(--kb)"></rect><text x="436" y="86" font-weight="600">tools node</text><text x="436" y="106" class="mut">wrap_tool_call</text>'
       '<rect x="680" y="70" width="110" height="46" rx="8" style="fill: var(--soft); stroke: var(--line)"></rect><text x="692" y="98">output</text>'
       '<text x="126" y="50" class="mono" style="fill: var(--violet)">before_agent</text><text x="170" y="40" class="mono" style="fill: var(--violet)">before_model</text>'
       '<text x="322" y="50" class="mono" style="fill: var(--violet)">after_model</text><text x="690" y="50" class="mono" style="fill: var(--violet)">after_agent</text>'
       '<line x1="120" y1="93" x2="168" y2="93" style="stroke: var(--muted)"></line><line x1="320" y1="80" x2="418" y2="80" style="stroke: var(--muted)"></line><line x1="418" y1="108" x2="320" y2="108" style="stroke: var(--muted)"></line>'
       '<line x1="320" y1="93" x2="678" y2="93" style="stroke: var(--muted); stroke-dasharray: 4 4"></line>'
       '<rect x="430" y="146" width="250" height="34" rx="6" style="fill: var(--amber-bg); stroke: var(--amber)"></rect><text x="442" y="168" style="fill: var(--amber)">HumanInTheLoop: interrupt before the tool runs</text>'
       '</g></svg></div><figcaption>Where each hook runs. The dashed line is the exit when the model returns no tool calls.</figcaption></figure>'
       + run_box("s05_middleware_hitl", start="out"),
       [callout("real", "What happened", f"<code>before_model</code> saw 1, then 3, then 5 messages; the tool timing wrapper measured each call; the run paused with the exact <code>publish_note</code> arguments for review, and only after <code>approve</code> did the note appear. {R}"),
        callout("watch", "Answer every interrupt once", f"The docs warn {K}: if one of several answers sent together is invalid, the tools for the others can run while their interrupts still show as pending, and answering again runs them twice. Validate answers against each interrupt's <code>response_schema</code> first."),
        callout("evidence", "An open report we could not reproduce", f"An open issue says HITL middleware throws under <code>ainvoke</code>. Our probe could not reproduce it with a minimal agent on langchain 1.0.0, 1.2.15 and 1.5.0 {P}: not a refutation, since the report used a real model, several tools and FastAPI.")],
       [("Why does HumanInTheLoopMiddleware need a checkpointer?", "The run has to stop and be continued later, possibly by another process; the checkpointer is where the paused state lives."),
        ("What is the difference between before_model and wrap_model_call?", "before_model runs once before the call and can change state or jump; wrap_model_call surrounds the call itself, so it can retry, swap the model or change the request and response.")],
       ["How do I let the reviewer edit the tool arguments?", "Which built-in middleware limits cost?"])

lesson("l6", 6, "INTERMEDIATE", "The Graph API: write the agent yourself",
       "<p>Underneath create_agent is a <code>StateGraph</code>. State is a TypedDict whose fields are <b>channels</b>; a field annotated with a reducer (<code>add_messages</code>, <code>operator.add</code>) merges partial updates instead of overwriting. A node is a function from state to a partial update. Edges are fixed or conditional; <code>tools_condition</code> routes to <code>tools</code> when the last message has tool calls and to <code>END</code> otherwise.</p>"
       "<p>Each step of the stream is a <b>super-step</b>: the nodes triggered by the previous step run, their writes are merged at a barrier, and the state is checkpointed (see the Pregel diagram above).</p>",
       f'<div class="two">{run_box("s06_graph_api")}{mermaid("s06_graph_api", "The hand-built graph, drawn by LangGraph. The solid tools → model edge is the loop.")}</div>',
       [callout("real", "Two calls, one super-step", f"The model asked for <code>release_lines</code> twice in one turn; <code>ToolNode</code> ran both in super-step 2. The <code>model_calls</code> reducer summed to 2 on the second run. {R}"),
        callout("watch", "A wrong answer worth studying", "Asked how many <i>releases</i> each library shipped, the model counted minor <i>lines</i> (10 and 10). The real counts (528 and 286) were one tool away, in <code>latest_release</code>. Lesson 13 measures this failure and fixes it."),
        callout("evidence", "Invalid tool calls end the loop", f"When the model returns only <code>invalid_tool_calls</code> (malformed arguments), <code>create_agent</code> stops after one model call with no tool message; on 1.5.0 an invalid call next to a valid one gets an error ToolMessage, on 1.2.15 it does not {P}.")],
       [("Why annotate messages with add_messages?", "Without a reducer each node's return would replace the list; add_messages appends new messages and merges ones with the same id."),
        ("When is the Graph API worth it over create_agent?", "When the flow is not a single loop: deterministic steps, branches, parallel work, custom state, or human checkpoints between steps.")],
       ["What is a channel in LangGraph?", "How would I add a node that runs after every tool call?"])

lesson("l7", 7, "INTERMEDIATE", "Persistence: memory, history and time travel in Postgres",
       "<p>Compile a graph with a checkpointer and every super-step is saved under a <code>thread_id</code>. The same thread remembers earlier turns; <code>get_state_history</code> lists every checkpoint; <code>update_state</code> on an old checkpoint creates a fork, and invoking from it writes a new branch of history.</p>"
       "<p>This lesson used <code>PostgresSaver</code> against a real Postgres database. <code>setup()</code> creates the tables once; in production you share one database across workers.</p>",
       run_box("s07_persistence_postgres", start="out")
       + '<figure><div class="diagram-scroll"><svg viewBox="0 0 900 150" role="img" aria-label="Checkpoint history with a fork"><g font-size="11.5" class="mono">'
       + "".join(f'<circle cx="{60 + i * 110}" cy="50" r="13" style="fill: var(--paper); stroke: var(--accent)"></circle><text x="{60 + i * 110}" y="54" text-anchor="middle">{i}</text><text x="{60 + i * 110}" y="84" text-anchor="middle" class="mut">{lbl}</text>'
                 + (f'<line x1="{73 + i * 110}" y1="50" x2="{157 + i * 110}" y2="50" style="stroke: var(--muted)"></line>' if i < 6 else "")
                 for i, lbl in enumerate(["input", "model", "tools", "model", "turn 2", "model", "answer"]))
       + '<path d="M 280 63 C 300 120, 380 120, 410 120" style="fill: none; stroke: var(--amber)"></path><circle cx="424" cy="120" r="13" style="fill: var(--amber-bg); stroke: var(--amber)"></circle><text x="424" y="124" text-anchor="middle">f</text>'
       + '<text x="450" y="124" style="fill: var(--amber)">fork: update_state at step 2, then invoke(None) → "1.5.0"</text></g></svg></div>'
       '<figcaption>The thread above, as recorded: 8 checkpoints before the fork, 10 after. Each circle is one super-step snapshot.</figcaption></figure>',
       [callout("real", "What happened", f"Turn 2 answered \"You just asked about langchain\" from memory alone; the fork from the step before the first answer replied with only the version number, \"1.5.0\". {R}"),
        callout("evidence", "Where a sub-agent's checkpoints go", f"When a sub-agent runs inside a tool with the parent's config, its checkpoints land under a namespace like <code>tools:&lt;task id&gt;</code>, not under its graph name, and a <code>checkpoint_ns</code> you pass on a root invoke is not stored {P}. Two forum answers each had half of this right."),
        callout("design", "Threads are your unit of memory", "Short-term memory is the thread. Memory across threads (user preferences, learned facts) belongs in a store, which LangGraph provides separately from checkpoints.")],
       [("What happens to the original branch after a fork?", "Nothing: checkpoints are append-only. The fork adds new checkpoints whose parent is the one you updated; both histories stay readable."),
        ("Why not keep memory in a Python list?", "It dies with the process and cannot be shared by several workers or inspected later; a checkpointer gives you all three.")],
       ["How do I list all threads for a user?", "What is the difference between a checkpointer and a store?"])

lesson("l8", 8, "INTERMEDIATE", "Durable execution: pause in one process, resume in another",
       f"<p><code>interrupt(value)</code> inside a node stops the run and returns <code>value</code> to the caller under <code>__interrupt__</code>. The state is in the checkpointer, so the process can exit. Later, any process with the same <code>thread_id</code> calls <code>invoke(Command(resume=answer))</code>; the node runs again from its start and <code>interrupt()</code> returns <code>answer</code>.</p>"
       f"<p>Durability modes trade safety for speed {G}: <code>\"exit\"</code> saves only when the run ends or pauses, <code>\"async\"</code> saves while the next step runs, <code>\"sync\"</code> saves every checkpoint before moving on. This lesson used <code>\"sync\"</code>.</p>",
       run_box("s08_durable_interrupt", start="out")
       + '<figure><div class="diagram-scroll"><svg viewBox="0 0 900 170" role="img" aria-label="Durable interrupt across two processes"><g font-size="12">'
       '<text x="10" y="24" font-weight="600">process A</text><text x="10" y="134" font-weight="600">process B</text>'
       '<rect x="110" y="8" width="150" height="30" rx="6" style="fill: var(--paper); stroke: var(--accent)"></rect><text x="122" y="28">draft_note (LLM)</text>'
       '<rect x="290" y="8" width="170" height="30" rx="6" style="fill: var(--amber-bg); stroke: var(--amber)"></rect><text x="302" y="28">human_review: interrupt()</text>'
       '<text x="480" y="28" class="mut">process exits</text>'
       '<rect x="300" y="62" width="300" height="34" rx="6" style="fill: var(--soft); stroke: var(--line)"></rect><text x="314" y="84">Postgres: checkpoint, next = human_review</text>'
       '<rect x="290" y="118" width="170" height="30" rx="6" style="fill: var(--amber-bg); stroke: var(--amber)"></rect><text x="302" y="138">Command(resume="yes")</text>'
       '<rect x="490" y="118" width="150" height="30" rx="6" style="fill: var(--paper); stroke: var(--accent)"></rect><text x="502" y="138">publish</text>'
       '<line x1="375" y1="38" x2="375" y2="62" style="stroke: var(--muted)"></line><line x1="375" y1="96" x2="375" y2="118" style="stroke: var(--muted)"></line>'
       '</g></svg></div><figcaption>The recorded run: two different process ids, one thread, the draft written once by the LLM and published after the resume.</figcaption></figure>',
       [callout("real", "What happened", f"Process 31524 drafted the note and paused at <code>human_review</code>; process 10872 found the paused run in Postgres, resumed it with \"yes\" and published the same draft, with no second model call. {R}"),
        callout("watch", "Code before interrupt() runs twice", "On resume the node restarts from its first line. Keep side effects after the interrupt, or make them idempotent; never charge a card before asking for approval in the same node."),
        callout("evidence", "A live race report", "Our event sweep after the deepagents 0.7.36–0.7.37 releases selected a fresh LangGraph issue: with <code>durability=\"exit\"</code> and parallel tool calls under human-in-the-loop, an approved call can be presented again and run twice. It is in the knowledge base as an open claim, not yet probed.")],
       [("Why did the resumed process make no model call?", "draft_note had already completed and its result was checkpointed; only the interrupted node and the ones after it ran."),
        ("When would 'exit' durability be the right choice?", "Short runs where losing in-flight progress on a crash is acceptable and checkpoint writes are the bottleneck.")],
       ["How do I resume several interrupts at once?", "Can a deployed agent be resumed from a web UI?"])

lesson("l9", 9, "ADVANCED INTERMEDIATE", "Parallel fan-out with Send: map, then reduce",
       "<p>A conditional edge can return a list of <code>Send(node, payload)</code> objects. Each one schedules a copy of <code>node</code> with its own input, and all of them run in the same super-step. Their writes merge through the reducer (<code>operator.add</code> on <code>profiles</code>), and the next super-step sees all of them at once.</p>"
       "<p>Use it when the number of parallel tasks is known only at run time: one per document, per library, per search query.</p>",
       f'<div class="two">{run_box("s09_send_map_reduce", start="out")}{mermaid("s09_send_map_reduce", "The map-reduce graph, drawn by LangGraph. The dotted edge from start fans out through Send.")}</div>',
       [callout("real", "Parallel, measured", f"Three profile workers took 1.9 s, 1.6 s and 1.5 s; the whole run, including the reduce call, took 3.5 s, because the three ran in one super-step. {R}"),
        callout("design", "Send versus a loop", "A loop node calling the model three times serializes them. Send lets the runtime parallelize and checkpoint each branch separately, so a failed branch can be retried without redoing the others.")],
       [("Why does profiles need a reducer here?", "Three workers write to it in the same super-step; without operator.add the writes would conflict."),
        ("What payload does each worker see?", "Only the dict passed to its Send, not the whole graph state.")],
       ["How would I cap the number of parallel workers?", "Can Send target a subgraph?"])

lesson("l10", 10, "ADVANCED INTERMEDIATE", "Multi-agent systems: subagents, handoffs, routers",
       f"<p>The docs list the reasons people reach for several agents {K}: context management (each agent sees only what it needs), distributed development (teams own agents) and parallelization. They name five patterns:</p>"
       "<div class=\"tbl\"><table><thead><tr><th>Pattern</th><th>How it works</th></tr></thead><tbody>"
       "<tr><td>Subagents</td><td>a main agent calls subagents as tools; all routing passes through it</td></tr>"
       "<tr><td>Handoffs</td><td>a tool call updates state that switches which agent or configuration is active</td></tr>"
       "<tr><td>Skills</td><td>one agent loads specialized prompts and knowledge on demand</td></tr>"
       "<tr><td>Router</td><td>a routing step classifies the input and sends it to one or more agents, then combines the results</td></tr>"
       "<tr><td>Custom workflow</td><td>a LangGraph graph that mixes deterministic steps and agents</td></tr></tbody></table></div>"
       "<p>This lesson builds the first: a supervisor whose two tools are whole agents with their own prompts, tools and context windows.</p>",
       run_box("s10_multi_agent", start="out"),
       [callout("real", "What happened", f"The supervisor called both specialists in its first turn, then combined the historian's date (2025-10-17) with the fact-checker's verified deprecation facts. {R}"),
        callout("watch", "Two handoffs in one turn can lose one", f"When two tools in the same model turn each return <code>Command(graph=Command.PARENT, ...)</code> from an agent used as a subgraph, only the first update reaches the parent, on langgraph 1.1.9 and still on 1.2.21, although the issues were closed {P}. Hand off one at a time."),
        callout("design", "Context engineering is the point", f"The docs put it at the center of multi-agent design {K}: decide what each agent sees. The specialists here never see each other's prompts or tools, and the supervisor sees only their final answers.")],
       [("What does the supervisor receive from a subagent?", "Only the string the wrapper tool returns: the subagent's final message. Its intermediate steps stay in its own context."),
        ("When are handoffs better than subagents?", "When the specialist should talk to the user directly for several turns, not answer one question and return.")],
       ["How do subagents share memory?", "What is the cost of a supervisor architecture?"])

lesson("l11", 11, "ADVANCED INTERMEDIATE", "Deep Agents: a harness on top of create_agent",
       f"<p><code>create_deep_agent</code> returns a create_agent graph with a harness already attached {K}: a <code>write_todos</code> planner, a virtual filesystem (<code>ls</code>, <code>read_file</code>, <code>write_file</code>, <code>edit_file</code>, <code>delete</code>, <code>glob</code>, <code>grep</code>, and <code>execute</code> with sandbox backends), a <code>task</code> tool that spawns subagents with isolated context, summarization for long runs, and pluggable backends (in-memory state, disk, the LangGraph store, sandboxes).</p>"
       "<p>The docs' rule of thumb: use Deep Agents for autonomous, long-running work like research and coding; use create_agent when you want full control of the architecture.</p>",
       run_box("s11_deep_agent", start="out"),
       [callout("real", "What the harness did, and did not do", f"It wrote <code>/brief.md</code> to its virtual filesystem, grounded in the verified facts. It did not call <code>write_todos</code> or the fact-checker subagent: on a small task the model went straight to the tools. Harness tools are offers, not obligations. {R}"),
        callout("real", "Prompt caching came with the harness", f"The usage record shows 4,689 tokens read from Anthropic's prompt cache and 5,156 written to it, without any caching code in the lesson: the harness's long, stable system prompt is cached for you. {R}"),
        callout("evidence", "What a subagent sees", f"A subagent's model receives its own system prompt and one human message with the task description, never the parent's conversation, and the parent gets back only the subagent's last message {P}. A CompiledSubAgent's answer reaches the parent as a ToolMessage {V} (P10)."),
        callout("watch", "Version speed", "deepagents shipped 150 releases in fifteen months, and 0.7.38 shipped during this module's build. Pin it, and re-run your checks when it moves.")],
       [("Why do subagents improve long tasks?", "Each subagent's exploration stays in its own context window; the parent keeps a short history of delegated results instead of every intermediate step."),
        ("Where did /brief.md go?", "Into the agent's state (the default in-memory backend). Configure a disk or store backend to keep files outside the run.")],
       ["How do I force the agent to plan first?", "When should I use a sandbox backend?"])

lesson("l12", 12, "ADVANCED INTERMEDIATE", "Deploying an Agent Server: langgraph.json, langgraph dev, the SDK, RemoteGraph",
       "<p>A deployment names its graphs in <code>langgraph.json</code>. <code>langgraph dev</code> serves them locally on an in-memory Agent Server (no Docker); <code>langgraph up</code> and <code>langgraph build</code> package the same project as containers. The server adds what a production agent needs and the graph should not reimplement: <b>assistants</b> (a graph plus configuration), <b>threads</b> (persistent state), <b>runs</b> (executions you can stream, join, cancel or schedule), and its own checkpoints.</p>"
       f"<p>Deployment options {K}: LangSmith Cloud, hybrid, a standalone server, or self-hosted with a control plane. A self-hosted server runs against Postgres for persistence and Redis for its task queue {G}.</p>",
       f'<div class="two">{run_box("s12_config", "deploy/langgraph.json")}{run_box("s12_agent", "deploy/agent.py")}</div>' + run_box("s12_deploy", "deploy/client.py (against langgraph dev on :2024)", start="out")
       + '<figure><div class="diagram-scroll"><svg viewBox="0 0 900 200" role="img" aria-label="Agent Server deployment topology"><g font-size="12">'
       '<rect x="10" y="70" width="150" height="60" rx="8" style="fill: var(--soft); stroke: var(--line)"></rect><text x="24" y="96">client</text><text x="24" y="116" class="mut mono">langgraph_sdk / RemoteGraph</text>'
       '<rect x="230" y="40" width="250" height="120" rx="10" style="fill: color-mix(in srgb, var(--amber) 12%, var(--paper)); stroke: var(--amber)"></rect><text x="246" y="66" font-weight="600">Agent Server</text>'
       '<text x="246" y="88" class="mut">assistants · threads · runs · crons</text><text x="246" y="108" class="mut">your graph from langgraph.json</text><text x="246" y="128" class="mut">streaming over HTTP/SSE</text>'
       '<rect x="560" y="30" width="150" height="50" rx="8" style="fill: var(--paper); stroke: var(--kb)"></rect><text x="574" y="60">Postgres: state</text>'
       '<rect x="560" y="110" width="150" height="50" rx="8" style="fill: var(--paper); stroke: var(--kb)"></rect><text x="574" y="140">Redis: task queue</text>'
       '<rect x="760" y="70" width="130" height="60" rx="8" style="fill: var(--paper); stroke: var(--violet)"></rect><text x="774" y="98">LangSmith</text><text x="774" y="116" class="mut">traces, evals</text>'
       '<line x1="160" y1="100" x2="228" y2="100" style="stroke: var(--muted)"></line><line x1="480" y1="70" x2="558" y2="55" style="stroke: var(--muted)"></line><line x1="480" y1="130" x2="558" y2="135" style="stroke: var(--muted)"></line><line x1="710" y1="100" x2="758" y2="100" style="stroke: var(--muted); stroke-dasharray: 4 4"></line>'
       '<text x="10" y="190" class="mut">langgraph dev (this lesson) keeps all of this in memory in one process; the production shape splits it.</text></g></svg></div></figure>',
       [callout("real", "What happened", f"The server registered the <code>release_scout</code> assistant from langgraph.json; the SDK created a thread, streamed the run (model, tools, model), and read back 4 messages and 5 server-side checkpoints; <code>RemoteGraph</code> then called the deployed agent like a local graph. {R}"),
        callout("watch", "A Windows deployment gotcha, real", "The first <code>langgraph dev</code> crashed before serving: on Windows its console logger requires the <code>colorama</code> package (\"ConsoleRenderer with colors=True on Windows requires the colorama package installed\"). Installing it fixed the run."),
        callout("watch", "The same wrong answer, now deployed", "Asked how many deepagents releases there are, the deployed agent answered \"8 minor version lines\" (the real count is 150). Deployment changes where an agent runs, not whether its tools are well described. Lesson 13.")],
       [("Why does the deployed agent.py have no checkpointer?", "The Agent Server supplies persistence for every thread; a checkpointer in the module would be ignored or conflict."),
        ("What is an assistant on the server?", "A graph plus a configuration. Several assistants can share one graph with different prompts or models.")],
       ["How do I add authentication to the Agent Server?", "How do crons work on the server?"])

lesson("l13", 13, "ADVANCED INTERMEDIATE", "Evaluate, change the harness, evaluate again",
       f"<p>Lessons 6 and 12 showed the same failure: \"how many releases\" answered by counting minor version lines. The hypothesis is that the tool descriptions, not the model, cause it. A four-question eval set with answers from the captured PyPI data tests that hypothesis, twice per question, before and after rewriting two docstrings.</p>"
       f"<p>This is the loop LangChain's Vivek Trivedy describes in his 2026 World's Fair talk {T}: ship the agent, collect traces, mine them, and run data-driven experiments on prompts, tools, orchestration and loops. His advice, marked faithful by our reviewer, is a sandwich: <i>harness engineering first, because it gives feedback in minutes; fine-tune when harness gains plateau; then more harness engineering.</i></p>",
       run_box("s13_eval", start="out"),
       [callout("real", "The measurement", f"Baseline docstrings: <b>2 of 8</b> correct (the model counted minor lines, or said no tool could count releases). Rewritten docstrings: <b>8 of 8</b>. Same model, same data, same questions; two docstrings changed. {R}"),
        callout("design", "Why this generalizes", "The fix said what each tool returns and what it is not for. Tool descriptions are prompts the model reads on every turn; treat them as code under test."),
        callout("evidence", "Reading traces at scale", f"Trivedy's second point {T}: reading traces is an input-token cost multiplied by the number and length of traces, and long agent traces do not fit in a reviewing agent's context, so traces must be queried as external objects. That is why the eval here checks a substring, not a second model's opinion.")],
       [("Why repeat each question twice?", "Model outputs vary; one pass can hide a flaky failure. Real evals repeat more and report the spread."),
        ("What would you add to this eval next?", "Questions the tools cannot answer, to check the agent says so instead of guessing, and a check that cited numbers appear in tool outputs.")],
       ["How do I run this eval in LangSmith?", "How many eval cases are enough?"])

HISTORY = [
    {"date": "2022-10", "text": "The ReAct paper (Yao et al.) proposes interleaving reasoning traces and actions; LangChain's first agents are built on it.", "src": ["kb"]},
    {"date": "2022-10-24", "text": "<b>LangChain v0.0.1</b>, \"a month before ChatGPT\": LLM abstractions and \"chains\" of predetermined steps. The name is Language + Chains. PyPI records the first upload on 2022-10-25 (UTC).", "src": ["kb", "reg"]},
    {"date": "2022-12", "text": "The first general-purpose agents: the LLM generated JSON that represented tool calls, and LangChain parsed it to decide which tool to run.", "src": ["kb"]},
    {"date": "2023-01", "text": "OpenAI's Chat Completions API: models take a list of messages and return a message; LangChain moves to messages. LangChain.js ships the same month.", "src": ["kb"]},
    {"date": "2023-02", "text": "<b>LangChain Inc. is formed</b> around the open-source project, with the goal to \"make intelligent agents ubiquitous\".", "src": ["kb"]},
    {"date": "2023-03 / 06", "text": "Native function calling arrives in OpenAI's API and LangChain makes it the preferred way to call tools. The docs date it 2023-03; OpenAI announced function calling on 2023-06-13. The discrepancy is recorded, not resolved.", "src": ["kb", "gk"], "disc": True},
    {"date": "2023", "text": "The company raises a seed round led by Benchmark (2023) and a Series A led by Sequoia (2024, alongside LangSmith's general availability), followed by later rounds as LangGraph and LangSmith grew.", "src": ["gk"]},
    {"date": "2023-06", "text": "<b>LangSmith</b>, a closed-source platform for observability and evals, because the hard part of agents is reliability.", "src": ["kb"]},
    {"date": "2023-11-20", "text": "<b>langchain-core 0.0.1</b> on PyPI: the small, stable kernel (messages, Runnables, tools) split out so integrations can depend on it.", "src": ["reg"]},
    {"date": "2024-01", "text": "<b>LangChain 0.1.0</b> (PyPI 2024-01-06), the first non-0.0.x: the turn from prototypes to production and stability.", "src": ["kb", "reg"]},
    {"date": "2024-02 / 01", "text": "<b>LangGraph</b>, a low-level orchestration layer with cycles, streaming, durable execution, short-term memory and human-in-the-loop. The docs say 2024-02; PyPI already has langgraph 0.0.8 on 2024-01-08.", "src": ["kb", "reg"], "disc": True},
    {"date": "2024-06", "text": "Over 700 integrations, split out of the core package into standalone packages and langchain-community.", "src": ["kb"]},
    {"date": "2024-10", "text": "LangGraph becomes the preferred way to build anything beyond a single LLM call; most chains and agents are deprecated with migration guides. One agent abstraction remains, built on LangGraph.", "src": ["kb"]},
    {"date": "2025-04", "text": "Model APIs turn multimodal; langchain-core's message format standardizes files, images and video inputs.", "src": ["kb"]},
    {"date": "2025-07-29", "text": "<b>deepagents 0.0.1</b> on PyPI.", "src": ["reg"]},
    {"date": "2025-10-20 / 17", "text": "<b>LangChain 1.0</b>: every chain and agent replaced by one agent abstraction on LangGraph (create_agent), legacy code moved to langchain-classic, and a standard content-block message format. The docs say 2025-10-20; PyPI has langchain 1.0.0 and langgraph 1.0.0 on 2025-10-17.", "src": ["kb", "reg"], "disc": True},
    {"date": "2026-03-15 / 2025-07", "text": "The docs date the release of <b>Deep Agents</b> as an open-source harness to 2026-03-15 (\"v0.5.3\"); PyPI shows 0.0.1 on 2025-07-29 and the 0.5 line starting on 2026-04-07. A first upload and a launch are different events.", "src": ["kb", "reg"], "disc": True},
    {"date": "2026-11-13", "text": "Today: langchain 1.5.0, langchain-core 1.8.0, langgraph 1.2.21, deepagents 0.7.38 (shipped while this module was built). 528, 323, 286 and 150 releases respectively.", "src": ["reg"]},
]

data = {"snippets": {k: {"code": v["code"], "output": v["output"]} for k, v in SNIPS.items()}, "history": HISTORY,
        "history_data": {p: {"count": HIST[p]["count"], "quarters": HIST[p]["quarters"], "minors": HIST[p]["minors"]} for p in HIST}}
tool_call = "\n".join(l for l in SNIPS["s01_tool_calling"]["output"].splitlines()[:12])
page = open(os.path.join(HERE, "artifact_template.html"), encoding="utf-8").read()
subs = {"{{run_date}}": "2026-11-13", "{{total_usd}}": f"{TOTAL:.2f}", "{{tool_call_excerpt}}": E(tool_call), "{{lessons}}": "\n".join(LESSONS),
        "{{lc_count}}": str(HIST["langchain"]["count"]), "{{lc_first}}": HIST["langchain"]["first"][0], "{{lg_count}}": str(HIST["langgraph"]["count"]),
        "{{lg_first}}": HIST["langgraph"]["first"][0], "{{da_count}}": str(HIST["deepagents"]["count"]), "{{da_first}}": HIST["deepagents"]["first"][0],
        "{{course_data}}": json.dumps(data, ensure_ascii=False).replace("</", "<\\/")}
for k, v in subs.items():
    page = page.replace(k, v)
assert "{{" not in page.replace("{{{", ""), re.findall(r"\{\{[a-z_]+\}\}", page)
open(sys.argv[1], "w", encoding="utf-8", newline="\n").write(page)
print(sys.argv[1], len(page), "bytes; total model cost", TOTAL, "; lessons", len(LESSONS))
