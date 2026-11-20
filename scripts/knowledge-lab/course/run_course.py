"""Run every lesson snippet of the course prototype for real and record what it printed.

Environment: %TEMP%\\aieng-course-env (langchain 1.5.0, langgraph 1.2.21, deepagents 0.7.38, langchain-anthropic, langgraph-cli[inmem],
langgraph-checkpoint-postgres). Model: claude-haiku-4-5 via the lab's Anthropic key (read by name, passed to the child process only).
Postgres: a disposable database `course_demo` on the replay stack (port 55722). Outputs: schema-units/provenance/evidence/B08-course-prototype/outputs/.
Run: python -I -X utf8 scripts/knowledge-lab/course/run_course.py [s01 ... s12]
"""
import json, os, subprocess, sys, time, urllib.request, uuid
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
import lab_common as C

HERE = os.path.dirname(os.path.abspath(__file__))
PY = os.path.join(os.environ["TEMP"], "aieng-course-env", "Scripts", "python.exe")
OUT = os.path.join(C.LAB, "..", "schema-units", "provenance", "evidence", "B08-course-prototype", "outputs")
os.makedirs(OUT, exist_ok=True)
DSN = "postgresql://postgres:postgres@127.0.0.1:55722/course_demo"
PRICE_IN, PRICE_OUT = 1.0, 5.0   # claude-haiku-4-5, USD per million tokens


def env():
    keep = {k: v for k, v in os.environ.items() if k.upper() in ("PATH", "SYSTEMROOT", "TEMP", "TMP", "USERPROFILE", "APPDATA", "LOCALAPPDATA", "HOMEDRIVE", "HOMEPATH", "COMSPEC", "PATHEXT", "WINDIR")}
    keep.update(PYTHONIOENCODING="utf-8", PYTHONUTF8="1", ANTHROPIC_API_KEY=C.load_secret("ANTHROPIC_PRODUCER_API_KEY"), COURSE_PG_DSN=DSN,
                COURSE_RUN_ID=uuid.uuid4().hex[:8], LANGSMITH_TRACING="false")
    return keep


def usage_of(stdout):
    tin = tout = 0
    for line in stdout.splitlines():
        if line.startswith("USAGE "):
            for m in (json.loads(line[6:]) or {}).values():
                tin += m.get("input_tokens", 0); tout += m.get("output_tokens", 0)
    return tin, tout, round(tin * PRICE_IN / 1e6 + tout * PRICE_OUT / 1e6, 4)


def run(name, args, cwd=HERE, e=None, timeout=600):
    t0 = time.time()
    p = subprocess.run([PY, *args], cwd=cwd, capture_output=True, text=True, encoding="utf-8", timeout=timeout, env=e or env())
    tin, tout, usd = usage_of(p.stdout)
    rec = {"snippet": name, "args": args, "exit_code": p.returncode, "seconds": round(time.time() - t0, 1), "stdout": p.stdout, "stderr_tail": p.stderr[-3000:],
           "tokens_in": tin, "tokens_out": tout, "usd": usd, "ran_at": C.now_iso()}
    C.write_json(os.path.join(OUT, f"{name}.json"), rec)
    C.log(f"{name}: exit {p.returncode} in {rec['seconds']}s, {tin}/{tout} tokens, ${usd}" + ("" if p.returncode == 0 else " :: " + p.stderr.strip().splitlines()[-1][:300] if p.stderr.strip() else ""))
    return rec


def deploy():
    e = env()
    d = os.path.join(HERE, "deploy")
    log = open(os.path.join(OUT, "s12-server.log"), "w", encoding="utf-8")
    cli = os.path.join(os.path.dirname(PY), "langgraph.exe")
    srv = subprocess.Popen([cli, "dev", "--no-browser", "--port", "2024", "--config", "langgraph.json"], cwd=d, stdout=log, stderr=subprocess.STDOUT, env=e)
    try:
        for _ in range(90):
            try:
                if urllib.request.urlopen("http://127.0.0.1:2024/ok", timeout=2).status == 200:
                    break
            except Exception:
                time.sleep(1)
        rec = run("s12_deploy", ["client.py"], cwd=d, e=e)
    finally:
        srv.terminate()
        try:
            srv.wait(timeout=20)
        except Exception:
            srv.kill()
        log.close()
    return rec


PLAN = ["s01_tool_calling", "s02_create_agent", "s03_event_streaming", "s04_structured_output", "s05_middleware_hitl", "s06_graph_api",
        "s07_persistence_postgres", "s08_durable_interrupt", "s09_send_map_reduce", "s10_multi_agent", "s11_deep_agent", "s12_deploy", "s13_eval_tool_descriptions"]

if __name__ == "__main__":
    want = sys.argv[1:] or PLAN
    for name in PLAN:
        if not any(name.startswith(w) for w in want):
            continue
        if name == "s08_durable_interrupt":
            e = env()
            a = run("s08a_start", ["s08_durable_interrupt.py", "start"], e=e)
            b = run("s08b_resume", ["s08_durable_interrupt.py", "resume"], e=e)
        elif name == "s12_deploy":
            deploy()
        else:
            run(name, [name + ".py"])
