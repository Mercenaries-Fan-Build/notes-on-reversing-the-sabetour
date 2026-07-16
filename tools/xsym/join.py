"""Align 360 vtables (named) to PC vtables (VAs) by class+slot, validate each tier
against ground truth (curated oracle + per-function assert strings), aggregate per PC VA.

Usage: join.py vt360.tsv vtpc.tsv oracle.tsv body_names.tsv out_map.tsv
"""
from __future__ import annotations
import collections
import sys


def load_vt(p):
    d = collections.defaultdict(dict)
    for ln in open(p, encoding="utf-8").read().splitlines()[1:]:
        c = ln.split("\t")
        if len(c) < 4:
            continue
        d[c[0]][int(c[1])] = c
    return d


def leaf_norm(name):
    parts = name.split("::")
    if len(parts) < 2:
        return name.lower()
    cls, leaf = parts[-2], parts[-1]
    if leaf == "ctor" or leaf == cls:
        return "{ctor}"
    if leaf.startswith("~") or leaf == "dtor":
        return "{dtor}"
    return leaf.lower()


def full_norm(name):
    parts = name.split("::")
    if len(parts) >= 2:
        return "::".join(parts[:-1]) + "::" + leaf_norm(name)
    return name.lower()


def main():
    f360, fpc, foracle, fbody, fout = sys.argv[1:6]
    a = load_vt(f360)
    b = load_vt(fpc)

    # ground truth: va -> set of acceptable full_norm names
    gt = collections.defaultdict(set)
    gt_single = {}   # va -> the single curated oracle name (for strict metric)
    for ln in open(foracle, encoding="utf-8").read().splitlines()[1:]:
        va, nm = ln.split("\t")[:2]
        gt[int(va, 16)].add(full_norm(nm))
        gt_single[int(va, 16)] = nm
    for ln in open(fbody, encoding="utf-8").read().splitlines()[1:]:
        parts = ln.split("\t")
        if len(parts) < 2:
            continue
        va = int(parts[0], 16)
        for nm in parts[1].split(";"):
            if nm:
                gt[va].add(full_norm(nm))

    common = set(a) & set(b)
    prop = collections.defaultdict(list)  # pc_va -> [(name, cls, tier)]
    for cls in common:
        la, lb = len(a[cls]), len(b[cls])
        if la == lb:
            tier, n = "exact", la
        elif lb > la:
            tier, n = "pc_longer", la
        else:
            tier, n = "pc_shorter", lb
        for i in range(n):
            if i not in a[cls] or i not in b[cls]:
                continue
            name = a[cls][i][3]
            if not name:
                continue
            pc_va = int(b[cls][i][2], 16)
            prop[pc_va].append((name, cls, tier))

    # per-tier validation on the RAW proposals
    tier_stat = collections.defaultdict(lambda: [0, 0, 0])  # tier -> [checked, ok, wrong]
    tier_wrong = collections.defaultdict(list)
    for va, ps in prop.items():
        if va not in gt:
            continue
        for name, cls, tier in ps:
            fn = full_norm(name)
            ln_ = leaf_norm(name)
            gset = gt[va]
            gleaf = set(x.split("::")[-1] for x in gset)
            st = tier_stat[tier]
            st[0] += 1
            if fn in gset or ln_ in gleaf:
                st[1] += 1
            else:
                st[2] += 1
                tier_wrong[tier].append((va, sorted(gset), name))

    # aggregate per VA (choose best proposal), assign confidence from validated tiers
    final = {}
    for va, ps in prop.items():
        fulls = set(full_norm(n) for n, c, t in ps)
        exact = [p for p in ps if p[2] == "exact"]
        pick = exact[0] if exact else ps[0]
        agree_full = len(fulls) == 1
        if exact and agree_full:
            conf = "high"
        elif exact:
            conf = "medium"        # exact-tier but disagreeing votes
        elif agree_full:
            conf = "low"           # drifted class, appended-only assumption
        else:
            conf = "low"
        final[va] = (pick[0], conf, pick[2], len(ps))

    with open(fout, "w", encoding="utf-8") as w:
        w.write("pc_va\tname\tmethod\tconfidence\ttier\tn_votes\n")
        for va in sorted(final):
            name, conf, tier, nv = final[va]
            w.write("%08x\t%s\tvtable_rtti\t%s\t%s\t%d\n" % (va, name, conf, tier, nv))

    print("=== per-tier validation (raw proposals vs ground truth) ===")
    for tier in ("exact", "pc_longer", "pc_shorter"):
        c, ok, wr = tier_stat[tier]
        acc = ok / c * 100 if c else 0
        print(f"  {tier:11s} checked={c:4d} correct={ok:4d} wrong={wr:4d} acc={acc:5.1f}%")
    print("=== final map size & confidence ===")
    print("  total named VAs:", len(final))
    print(" ", dict(collections.Counter(v[1] for v in final.values())))
    print("=== sample EXACT-tier mismatches (max 15) ===")
    for va, gset, name in tier_wrong["exact"][:15]:
        print(f"  {va:08x} gt={gset} rtti={name}")
    print("=== sample pc_longer mismatches (max 10) ===")
    for va, gset, name in tier_wrong["pc_longer"][:10]:
        print(f"  {va:08x} gt={gset} rtti={name}")


if __name__ == "__main__":
    main()
