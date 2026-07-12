#!/usr/bin/env python3
"""Merge several SMSH geometry dumps (character body parts) into one.

All parts must skin to the SAME skeleton (JOINTS_0 are global bone indices), which
is true for a character's _HD/_UB/_LB/_GR/... parts. Vertices/attrs are
concatenated; indices are offset by each part's vertex base.

Usage: python tools/merge_smsh.py out.smsh part1.smsh part2.smsh ...
"""
import struct, sys


def read(path):
    d = open(path, "rb").read()
    assert d[:4] == b"SMSH", f"{path}: not SMSH"
    nv, ni, np = struct.unpack_from("<III", d, 8)
    o = 20
    pos = d[o:o + nv * 12]; o += nv * 12
    nrm = d[o:o + nv * 12]; o += nv * 12
    uv = d[o:o + nv * 8]; o += nv * 8
    jnt = d[o:o + nv * 8]; o += nv * 8
    wgt = d[o:o + nv * 16]; o += nv * 16
    idx = list(struct.unpack_from("<%dI" % ni, d, o)); o += ni * 4
    prims = d[o:o + np * 16]
    return dict(nv=nv, ni=ni, np=np, pos=pos, nrm=nrm, uv=uv, jnt=jnt, wgt=wgt, idx=idx, prims=prims)


def main() -> int:
    if len(sys.argv) < 3:
        print("usage: merge_smsh.py <out.smsh> <part1.smsh> [part2.smsh ...]", file=sys.stderr)
        return 2
    out, parts = sys.argv[1], sys.argv[2:]
    pos = nrm = uv = jnt = wgt = b""
    idx = []
    prims = b""
    base_v = 0
    base_i = 0
    for p in parts:
        m = read(p)
        pos += m["pos"]; nrm += m["nrm"]; uv += m["uv"]; jnt += m["jnt"]; wgt += m["wgt"]
        idx += [i + base_v for i in m["idx"]]
        # offset each prim's index_start by base_i
        for k in range(m["np"]):
            s, c, mat, fl = struct.unpack_from("<IIII", m["prims"], k * 16)
            prims += struct.pack("<IIII", s + base_i, c, mat, fl)
        print(f"  + {p}: {m['nv']} verts, {m['ni']//3} tris")
        base_v += m["nv"]; base_i += m["ni"]

    nv = base_v; ni = len(idx); npr = len(prims) // 16
    body = struct.pack("<4sIIII", b"SMSH", 1, nv, ni, npr)
    body += pos + nrm + uv + jnt + wgt
    body += struct.pack("<%dI" % ni, *idx)
    body += prims
    open(out, "wb").write(body)
    print(f"merged {len(parts)} parts -> {out}: {nv} verts, {ni//3} tris")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
