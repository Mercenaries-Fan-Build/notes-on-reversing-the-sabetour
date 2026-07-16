"""Build the PC side: walk MSVC 32-bit RTTI in the retail Saboteur.exe to recover,
for every class, its vtable = ordered array of virtual-method VAs.

Chain:  vtable[-1] -> COL -> TypeDescriptor -> ".?AVClass@@"
Output (scratchpad): vtpc.tsv  ->  class \t slot \t method_va \t vtable_va
"""
from __future__ import annotations
import re
import struct
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pe import PE

PC_EXE = Path(r"C:/GOG Games/The Saboteur/Saboteur.exe")
OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("vtpc.tsv")


def td_name_to_class(s: str):
    # s like ".?AVWSFoo@@" or ".?AVInner@Outer@@" or ".?AUName@@"
    if not (s.startswith(".?AV") or s.startswith(".?AU") or s.startswith(".?AW")):
        return None
    body = s[4:]
    if not body.endswith("@@") and "@@" not in body:
        return None
    body = body.split("@@")[0]
    scopes = [t for t in body.split("@") if t]
    if not scopes:
        return None
    return "::".join(reversed(scopes))


def main():
    pe = PE(str(PC_EXE))
    lo, hi = pe.text_range()
    imgbase = pe.imgbase
    raw = pe.raw

    # section offset<->VA helpers over raw file
    def off2va(o):
        for name, sva, vsz, roff, rsz in pe.secs:
            if roff <= o < roff + rsz:
                return sva + (o - roff)
        return None

    # 1) TypeDescriptors: find ".?AV"/".?AU" strings, TD starts 8 bytes before the name
    td_by_va = {}  # td_va -> class
    for m in re.finditer(rb"\.\?A[VUW][\w@?$]+@@", raw):
        s = m.group().decode("latin1")
        cls = td_name_to_class(s)
        if cls is None:
            continue
        name_off = m.start()
        td_off = name_off - 8
        td_va = off2va(td_off)
        if td_va is not None:
            td_by_va[td_va] = cls
    print(f"typedescriptors={len(td_by_va)}", file=sys.stderr)

    # index: dword value -> list of file offsets (only rdata/data sections)
    from collections import defaultdict
    val_offs = defaultdict(list)
    for name, sva, vsz, roff, rsz in pe.secs:
        if name.startswith(".text") or name.startswith(".reloc"):
            continue
        end = roff + (rsz & ~3)
        o = roff
        while o < end:
            v = struct.unpack_from("<I", raw, o)[0]
            if v:
                val_offs[v].append(o)
            o += 4

    # 2) COLs: dword == td_va at COL+12, signature(COL+0)==0
    col_by_va = {}  # col_va -> class
    for td_va, cls in td_by_va.items():
        for o in val_offs.get(td_va, ()):
            col_off = o - 12
            if col_off < 0:
                continue
            sig = struct.unpack_from("<I", raw, col_off)[0]
            if sig != 0:
                continue
            col_va = off2va(col_off)
            if col_va is not None:
                col_by_va[col_va] = cls
    print(f"COLs={len(col_by_va)}", file=sys.stderr)

    # 3) vtables: dword == col_va -> vtable starts at next dword.
    #    First collect ALL vtable-start offsets (from every COL ref) so each vtable
    #    can be upper-bounded by the next vtable start (vtables are packed with no
    #    gap; without this bound the reader runs past the end into the next vtable).
    starts = {}  # vt_off -> cls
    for col_va, cls in col_by_va.items():
        for o in val_offs.get(col_va, ()):
            vt_off = o + 4
            starts.setdefault(vt_off, cls)
    start_offs = sorted(starts)
    import bisect
    rows = []
    for vt_off in start_offs:
        cls = starts[vt_off]
        vt_va = off2va(vt_off)
        if vt_va is None:
            continue
        # upper bound = next vtable start (the dword before it is that vtable's COL ptr)
        idx = bisect.bisect_right(start_offs, vt_off)
        end = start_offs[idx] - 4 if idx < len(start_offs) else vt_off + 500 * 4
        slots = []
        p = vt_off
        while p + 4 <= len(raw) and p < end:
            v = struct.unpack_from("<I", raw, p)[0]
            if not (lo <= v < hi):
                break
            slots.append(v)
            p += 4
        if not slots:
            continue
        for i, mva in enumerate(slots):
            rows.append((cls, i, mva, vt_va))

    with open(OUT, "w", encoding="utf-8") as w:
        w.write("class\tslot\tmethod_va\tvtable_va\n")
        for cls, i, mva, vt in rows:
            w.write("%s\t%d\t%08x\t%08x\n" % (cls, i, mva, vt))
    ncls = len(set(r[0] for r in rows))
    print(f"pc vtable classes={ncls} total_slots={len(rows)}", file=sys.stderr)


if __name__ == "__main__":
    main()
