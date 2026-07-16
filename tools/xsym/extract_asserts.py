"""Independent assert-anchored oracle from the retail decomp.

Every WS/engine method compiled with EA's assert/verify macros embeds its own
__FUNCTION__ string ("Class::Method") in its body. We take, per FUN block, the set
of distinct "Ident::Ident..." string literals; when a block has EXACTLY ONE such
name we treat it as that function's true name (assert-anchored, ground truth).

Output: asserts.tsv  ->  pc_va \t name \t ndistinct
"""
from __future__ import annotations
import re
import sys
from pathlib import Path

DECOMP = Path(r"c:/Users/Shadow/Desktop/notes-on-the-released-game/output/_ghidra_saboteur/saboteur_all_functions_decomp.txt")
OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("asserts.tsv")

HDR = re.compile(r"^==== FUN_[0-9a-f]+ @0x([0-9a-f]+)\b")
# "Class::Method" or "Ns::Class::Method"; class token starts uppercase letter.
NAME = re.compile(r'"([A-Za-z_][A-Za-z0-9_]*(?:::[A-Za-z_~][A-Za-z0-9_]*)+)"')


def main():
    cur_va = None
    names = None
    out = {}
    allnames = {}

    def flush():
        if cur_va is None:
            return
        allnames[cur_va] = set(names)
        if len(names) == 1:
            out[cur_va] = next(iter(names))

    with open(DECOMP, "r", errors="replace") as f:
        for line in f:
            h = HDR.match(line)
            if h:
                flush()
                cur_va = int(h.group(1), 16)
                names = set()
                continue
            if cur_va is None:
                continue
            for m in NAME.finditer(line):
                nm = m.group(1)
                # keep plausible method names (2-3 components, not paths/urls)
                if nm.count("::") <= 3 and " " not in nm:
                    names.add(nm)
        flush()

    with open(OUT, "w", encoding="utf-8") as w:
        w.write("pc_va\tname\tnnames\n")
        for va in sorted(out):
            w.write("%08x\t%s\t%d\n" % (va, out[va], len(allnames[va])))
    print(f"blocks_with_names={len(allnames)} unique_anchored={len(out)}", file=sys.stderr)


if __name__ == "__main__":
    main()
