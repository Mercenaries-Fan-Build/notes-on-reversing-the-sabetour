"""Dump, per PC function, the set of "Class::Method" string literals in its body.
This is an independent per-function ground-truth signal (the inlined __FUNCTION__
assert strings) used to cross-validate the RTTI-alignment proposals.

Output: body_names.tsv  ->  pc_va \t name1;name2;...
"""
from __future__ import annotations
import re
import sys
from pathlib import Path

DECOMP = Path(r"c:/Users/Shadow/Desktop/notes-on-the-released-game/output/_ghidra_saboteur/saboteur_all_functions_decomp.txt")
OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("body_names.tsv")

HDR = re.compile(r"^==== FUN_[0-9a-f]+ @0x([0-9a-f]+)\b")
NAME = re.compile(r'"([A-Za-z_][A-Za-z0-9_]*(?:::[A-Za-z_~][A-Za-z0-9_]*)+)"')


def main():
    cur = None
    names = None
    rows = {}

    def flush():
        if cur is not None and names:
            rows[cur] = list(names)

    with open(DECOMP, "r", errors="replace") as f:
        for line in f:
            h = HDR.match(line)
            if h:
                flush()
                cur = int(h.group(1), 16)
                names = []
                continue
            if cur is None:
                continue
            for m in NAME.finditer(line):
                nm = m.group(1)
                if nm.count("::") <= 3 and nm not in names:
                    names.append(nm)
        flush()

    with open(OUT, "w", encoding="utf-8") as w:
        w.write("pc_va\tnames\n")
        for va in sorted(rows):
            w.write("%08x\t%s\n" % (va, ";".join(rows[va])))
    print(f"functions_with_name_strings={len(rows)}", file=sys.stderr)


if __name__ == "__main__":
    main()
