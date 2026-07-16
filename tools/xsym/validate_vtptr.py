"""Independent STRUCTURAL validation of the exact-tier vtable alignment.

A class's (deleting) destructor writes the class's own vtable pointer into the
object; Ghidra renders that store as `&PTR_LAB_<vtva>`. We know each PC class's
vtable VA. So for every exact-tier slot whose 360 name is a destructor, the aligned
PC function body must reference its own class's vtable VA. This confirms the slot
alignment WITHOUT relying on assert strings -> hundreds of independent checks.
"""
from __future__ import annotations
import collections
import re
import sys
from pathlib import Path

SCR = Path(sys.argv[1])
DECOMP = Path(r"c:/Users/Shadow/Desktop/notes-on-the-released-game/output/_ghidra_saboteur/saboteur_all_functions_decomp.txt")


def load_vt(p):
    d = collections.defaultdict(dict)
    for ln in open(p, encoding="utf-8").read().splitlines()[1:]:
        c = ln.split("\t")
        if len(c) < 4:
            continue
        d[c[0]][int(c[1])] = c
    return d


a = load_vt(SCR / "vt360.tsv")
b = load_vt(SCR / "vtpc.tsv")
common = set(a) & set(b)

# exact-tier destructor slots: pc_va -> expected vtable VA (lowercased 8-hex)
targets = {}
for cls in common:
    if len(a[cls]) != len(b[cls]):
        continue
    for i in a[cls]:
        if i not in b[cls]:
            continue
        name = a[cls][i][3]
        if "::~" not in name:      # destructor
            continue
        pc_va = int(b[cls][i][2], 16)
        vt_va = b[cls][i][3].lower()
        targets[pc_va] = (cls, vt_va, name)

print(f"exact-tier destructor slots to check: {len(targets)}", file=sys.stderr)

# capture bodies for target VAs
HDR = re.compile(r"^==== FUN_[0-9a-f]+ @0x([0-9a-f]+)\b")
bodies = {}
cur = None
buf = None
with open(DECOMP, "r", errors="replace") as f:
    for line in f:
        h = HDR.match(line)
        if h:
            if cur in targets:
                bodies[cur] = "".join(buf)
            cur = int(h.group(1), 16)
            buf = [] if cur in targets else None
            continue
        if buf is not None:
            buf.append(line)
    if cur in targets:
        bodies[cur] = "".join(buf)

confirm = contradict = nobody = 0
bad = []
for pc_va, (cls, vt_va, name) in targets.items():
    body = bodies.get(pc_va)
    if body is None:
        nobody += 1
        continue
    if f"PTR_LAB_{vt_va}" in body or vt_va in body:
        confirm += 1
    else:
        contradict += 1
        bad.append((pc_va, cls, vt_va, name))

print(f"checked={confirm+contradict}  confirm={confirm}  no_vtref={contradict}  (missing_body={nobody})")
print(f"structural confirm rate = {confirm/(confirm+contradict)*100:.1f}%" if confirm+contradict else "n/a")
for pc_va, cls, vt_va, name in bad[:20]:
    print(f"  no vtref: {pc_va:08x} {name} (expected PTR_LAB_{vt_va})")
