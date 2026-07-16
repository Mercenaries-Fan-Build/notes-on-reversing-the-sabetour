"""Parse docs/symbol_map/*.md into the curated validation oracle: pc_va -> Class::Method.
Pairs a FUN_va with the Class::Method that follows it on the same line (the doc's
'`FUN_xxxx` - `Class::Method`' convention)."""
from __future__ import annotations
import re
import sys
from pathlib import Path

DOCS = Path(r"c:/Users/Shadow/Desktop/notes-on-reversing-the-sabetour/docs/symbol_map")
OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("oracle.tsv")

FUN = re.compile(r"FUN_([0-9a-f]{8})")
NAME = re.compile(r"\b([A-Z][A-Za-z0-9_]*(?:::[A-Za-z0-9_~]+)+)\b")


def main():
    pairs = {}
    conflicts = 0
    for md in sorted(DOCS.glob("*.md")):
        for line in md.read_text(errors="replace").splitlines():
            # find all FUN and NAME occurrences with positions
            funs = [(m.start(), int(m.group(1), 16)) for m in FUN.finditer(line)]
            names = [(m.start(), m.group(1)) for m in NAME.finditer(line)]
            if not funs or not names:
                continue
            for pos, va in funs:
                # nearest name occurring after this FUN within 60 chars
                cand = [(p, nm) for p, nm in names if pos < p <= pos + 60]
                if not cand:
                    continue
                nm = cand[0][1]
                if nm.endswith("::cpp"):
                    continue
                if va in pairs and pairs[va] != nm:
                    conflicts += 1
                pairs[va] = nm
    with open(OUT, "w", encoding="utf-8") as w:
        w.write("pc_va\tname\n")
        for va in sorted(pairs):
            w.write("%08x\t%s\n" % (va, pairs[va]))
    print(f"oracle pairs={len(pairs)} conflicts_overwritten={conflicts}", file=sys.stderr)


if __name__ == "__main__":
    main()
