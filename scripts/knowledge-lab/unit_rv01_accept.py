"""Build 09, unit RV01: what John's acceptance answers set in motion on the lab (2026-11-20, "accept RV01, 8B 9A").

RV01-9 A: John endorses the identity proposal that ForgeCode and Forge Code are one product. The decision is written through
api.decide_proposal by the lab's owner role, which is the person's path until unit RV10 builds one; then the two records are
merged with the proposal named as the reason. (RV01-8 B is the draft migration 20261119122000.)
"""
import json

from lab_common import *  # noqa
from unit_rv01 import load_state, save_state, receipt
from unit_rv01_cases import ent, run_batch, snapshot, moves_of


def stage_accept():
    st = load_state()
    acc = st.setdefault("acceptance", {})
    pid = st["proposals"]["identity"]["proposal_id"]
    if "decision" not in acc:
        out, _ = sql(f"select api.decide_proposal({q(pid)}, 'endorsed', {q('John, in chat on 2026-11-20: accept RV01, 8B 9A')}, null, 'John')")
        acc["decision"] = json.loads(out)
        save_state(st)
    loser, winner = ent("product", "forge-code"), ent("product", "forgecode")
    out = run_batch(st, "accept-merge-forgecode", [
        f"select catalog.merge_entities({q(loser)}, {q(winner)}, {q(receipt('merge-forgecode'))}, 'duplicate_record', 'Forge Code and ForgeCode are one product; endorsed by John on 2026-11-20.', {q(pid)});"])
    acc["merge"] = json.loads(out[1])
    acc["moves"] = moves_of("merge_id", acc["merge"]["merge_id"])
    acc["winner"] = snapshot(winner)
    acc["proposal"] = sql_rows(f"select review_state, publication, decided_by, authored_by_kind from catalog.proposal where id = {q(pid)}")
    acc["merge_names_proposal"] = one(f"select proposal_id from catalog.entity_merge where id = {q(acc['merge']['merge_id'])}") == pid
    acc["resolve_forge_code"] = sql_rows("select kind, display_name, score from api.resolve_entity('Forge Code') limit 2")
    save_state(st)
    log(f"accept stage done: {acc['merge']['status']}, moves {acc['merge']['moves']}, proposal {acc['proposal']}, resolve {acc['resolve_forge_code']}")
