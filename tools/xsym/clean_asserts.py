"""Clean assert-anchor set: a "Class::Method" string that appears in EXACTLY ONE
function body is an unambiguous name for that function (independent of RTTI).
Collisions (a name inlined into several callers) are dropped.

Output: assert_anchors.tsv -> pc_va \t name \t method(assert) \t confidence
"""
from __future__ import annotations
import collections
import sys
from pathlib import Path

SCR = Path(sys.argv[1])
body = SCR / "body_names.tsv"
OUT = SCR / "assert_anchors.tsv"

name_to_vas = collections.defaultdict(set)
va_names = {}
for ln in open(body, encoding="utf-8").read().splitlines()[1:]:
    parts = ln.split("\t")
    if len(parts) < 2:
        continue
    va = int(parts[0], 16)
    nms = [n for n in parts[1].split(";") if n]
    va_names[va] = nms
    for n in nms:
        name_to_vas[n].add(va)

rows = []
for va, nms in va_names.items():
    # a body may list several names; the anchor is a name unique to this body
    uniq = [n for n in nms if len(name_to_vas[n]) == 1]
    if len(uniq) == 1:
        rows.append((va, uniq[0]))
    # if body has exactly one name total and it's unique, already covered

rows.sort()
with open(OUT, "w", encoding="utf-8") as w:
    w.write("pc_va\tname\tmethod\tconfidence\n")
    for va, nm in rows:
        w.write("%08x\t%s\tassert\thigh\n" % (va, nm))
print(f"clean assert anchors={len(rows)}", file=sys.stderr)
