"""Produce the final committable PC symbol map.

Confident sources (shipped):
  * assert  : "Class::Method" __FUNCTION__ string unique to one function body.
  * rtti_exact : 360<->PC vtable slot alignment for classes whose vtable LENGTH is
                 identical in both builds (drift-free layout).  Double-confirmed
                 where an assert anchor agrees.

Excluded (written to a separate experimental file, NOT part of the deliverable):
  * rtti_drift : classes whose vtable length differs across builds (prefix alignment
                 measured ~11% accurate -> unreliable).

Usage: finalize.py <scratch_dir> <out_confident.tsv> <out_experimental.tsv>
"""
from __future__ import annotations
import collections
import sys
from pathlib import Path

SCR = Path(sys.argv[1])
OUT = Path(sys.argv[2])
OUT_EXP = Path(sys.argv[3])

RUNTIME = {"_purecall", ""}

# known class-name prefixes in this engine (Odin/WildStar + middleware)
_KNOWN = ("WS", "hk", "Pbl", "CAk", "IAk", "Ak", "Odin", "OC3", "Pcl", "Puckel",
          "GFx", "Fx", "G", "C", "Bink")


def clean_display(name: str) -> str:
    """Cosmetic: MSVC template-arg '@'-split leaks a type code + '?$' marker into
    components, e.g. 'V?$WSFactory' / 'VWSEntityBlueprint' / 'VGImage'. Strip a
    leading V/U class/struct type code IFF the remainder is a known class name, and
    drop the '?$' template marker. Never touches real WS*/G* class names. The join
    already ran on the raw name, so this is display-only and safe."""
    out = []
    for comp in name.split("::"):
        c = comp.replace("?$", "")
        if len(c) > 1 and c[0] in "VU":
            rem = c[1:]
            if any(rem.startswith(p) for p in _KNOWN):
                c = rem
        out.append(c)
    return "::".join(out)


def load_vt(p):
    d = collections.defaultdict(dict)
    for ln in open(p, encoding="utf-8").read().splitlines()[1:]:
        c = ln.split("\t")
        if len(c) < 4:
            continue
        d[c[0]][int(c[1])] = c
    return d


def leaf(n):
    p = n.split("::")
    if len(p) < 2:
        return n.lower()
    c, l = p[-2], p[-1]
    if l == c or l == "ctor":
        return "{ctor}"
    if l.startswith("~") or l == "dtor":
        return "{dtor}"
    return l.lower()


def full(n):
    p = n.split("::")
    return ("::".join(p[:-1]) + "::" + leaf(n)) if len(p) >= 2 else n.lower()


def main():
    a = load_vt(SCR / "vt360.tsv")
    b = load_vt(SCR / "vtpc.tsv")
    common = set(a) & set(b)

    exact_prop = collections.defaultdict(list)   # va -> [(name, cls)]
    drift_prop = collections.defaultdict(list)
    for cls in common:
        la, lb = len(a[cls]), len(b[cls])
        n = min(la, lb)
        dst = exact_prop if la == lb else drift_prop
        for i in range(n):
            if i not in a[cls] or i not in b[cls]:
                continue
            name = a[cls][i][3]
            if not name or name in RUNTIME:
                continue
            va = int(b[cls][i][2], 16)
            dst[va].append((name, cls))

    # assert anchors
    asrt = {}
    for ln in open(SCR / "assert_anchors.tsv", encoding="utf-8").read().splitlines()[1:]:
        c = ln.split("\t")
        asrt[int(c[0], 16)] = c[1]

    def majority(props):
        cnt = collections.Counter(full(n) for n, c in props)
        best_full, _ = cnt.most_common(1)[0]
        # recover a display name matching best_full
        for n, c in props:
            if full(n) == best_full:
                return n, len(set(c2 for _, c2 in props))
        return props[0][0], 1

    confident = {}   # va -> (name, method, confidence, evidence)
    # 1) RTTI exact
    for va, props in exact_prop.items():
        name, nclasses = majority(props)
        method = "rtti_exact"
        conf = "high"
        ev = f"vtable;{nclasses}cls;{len(props)}votes"
        if va in asrt:
            if full(asrt[va]) == full(name) or leaf(asrt[va]) == leaf(name):
                method = "rtti_exact+assert"
                ev += ";assert_confirmed"
            else:
                # conflict on an exact-tier VA (should be rare) -> trust assert
                name = asrt[va]
                method = "assert"
                ev += ";assert_override"
        confident[va] = (name, method, conf, ev)
    # 2) assert anchors not already covered
    for va, nm in asrt.items():
        if va not in confident:
            confident[va] = (nm, "assert", "high", "unique_function_string")

    with open(OUT, "w", encoding="utf-8") as w:
        w.write("pc_va\tname\tmethod\tconfidence\tevidence\n")
        for va in sorted(confident):
            nm, meth, conf, ev = confident[va]
            w.write("%08x\t%s\t%s\t%s\t%s\n" % (va, clean_display(nm), meth, conf, ev))

    # experimental drift (excluded from deliverable)
    with open(OUT_EXP, "w", encoding="utf-8") as w:
        w.write("pc_va\tname\tmethod\tconfidence\tevidence\n")
        for va in sorted(drift_prop):
            if va in confident:
                continue
            name, nclasses = majority(drift_prop[va])
            w.write("%08x\t%s\trtti_drift\tlow\tprefix_align;%dcls\n" % (va, name, nclasses))

    by_m = collections.Counter(v[1] for v in confident.values())
    print(f"CONFIDENT map: {len(confident)} PC VAs")
    print("  by method:", dict(by_m))
    print(f"  rtti_exact distinct VAs: {len(exact_prop)}  assert anchors: {len(asrt)}")
    print(f"EXPERIMENTAL drift (excluded): {sum(1 for va in drift_prop if va not in confident)} VAs")


if __name__ == "__main__":
    main()
