"""Build the 360 side: parse WildStar_d.map, read each primary vtable's contents from
WildStar_d.exe (big-endian PPC), resolve slots to demangled Class::Method names.

Output (scratchpad): vt360.tsv  ->  class \t slot \t method_va \t qualified_name \t rawsym
"""
from __future__ import annotations
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pe import PE
from demangle import demangle, classname

GF = Path(r"c:/Users/Shadow/Desktop/notes-on-reversing-the-sabetour/game-files/symbols")
MAP = GF / "WildStar_d.map"
XEXE = GF / "WildStar_d.exe"
OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("vt360.tsv")

LINE = re.compile(r"^\s*([0-9a-f]{4}):([0-9a-f]{8})\s+(\S+)\s+([0-9a-f]{8})\b(.*)$")


def parse_map():
    va2names = {}          # int VA -> list[str] mangled symbols (all)
    data_syms = []         # sorted VAs of DATA-section symbols (sect 0001)
    vftables = []          # (class, va, obj)
    with open(MAP, "r", errors="replace") as f:
        for line in f:
            m = LINE.match(line)
            if not m:
                continue
            sect, off, sym, rva, tail = m.groups()
            va = int(rva, 16)
            va2names.setdefault(va, []).append(sym)
            if sect == "0001":
                data_syms.append(va)
            # primary vftable:  ??_7Class@@6B@
            mv = re.match(r"^\?\?_7(.+)@@6B@$", sym)
            if mv:
                cls = classname_of_vft(sym)
                obj = tail.strip().split()[-1] if tail.strip() else ""
                vftables.append((cls, va, obj))
    data_syms.sort()
    return va2names, data_syms, vftables


def classname_of_vft(sym):
    # ??_7WSConduit@@6B@  ->  WSConduit ; also nested ??_7Inner@Outer@@6B@
    m = re.match(r"^\?\?_7(.+)@@6B@$", sym)
    body = m.group(1)
    scopes = [t for t in body.split("@") if t]
    return "::".join(reversed(scopes))


def next_bound(data_syms, va):
    import bisect
    i = bisect.bisect_right(data_syms, va)
    return data_syms[i] if i < len(data_syms) else va + 0x4000


def choose_name(names, cls):
    """Pick the best mangled symbol for a method VA. Prefer a real function symbol
    whose owning class == the vtable class (an override declared here)."""
    dems = []
    for n in names:
        q, k = demangle(n)
        if q is None:
            continue
        dems.append((n, q, k, classname(n)))
    if not dems:
        return (names[0] if names else None), None
    # prefer class match
    for n, q, k, c in dems:
        if c == cls:
            return q, n
    return dems[0][1], dems[0][0]


def main():
    pe = PE(str(XEXE))
    lo, hi = pe.text_range()
    va2names, data_syms, vftables = parse_map()
    print(f"symbols={sum(len(v) for v in va2names.values())} vftables={len(vftables)}", file=sys.stderr)
    rows = []
    seen_cls = set()
    for cls, vft_va, obj in vftables:
        if cls in seen_cls:
            continue
        seen_cls.add(cls)
        bound = next_bound(data_syms, vft_va)
        slot = 0
        va = vft_va
        while va < bound and slot < 400:
            ptr = pe.dword(va, be=True)
            if ptr is None or not (lo <= ptr < hi):
                break
            names = va2names.get(ptr, [])
            q, raw = choose_name(names, cls) if names else (None, None)
            rows.append((cls, slot, ptr, q or "", raw or ""))
            slot += 1
            va += 4
    with open(OUT, "w", encoding="utf-8") as w:
        w.write("class\tslot\tmethod_va\tqual\trawsym\n")
        for r in rows:
            w.write("%s\t%d\t%08x\t%s\t%s\n" % r)
    ncls = len(set(r[0] for r in rows))
    named = sum(1 for r in rows if r[3])
    print(f"vtable classes with slots={ncls} total_slots={len(rows)} named_slots={named}", file=sys.stderr)


if __name__ == "__main__":
    main()
