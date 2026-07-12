#!/usr/bin/env python3
"""Convert a sab_skeleton JSON dump into the `.skel` format sab_havok65 consumes.

Each output line is one bone, in bone-index order:
    parent name  tx ty tz  rx ry rz rw  sx sy sz
(parent = 0-based index, -1 for root; t/r(xyzw)/s = the bind pose local to parent.)

Usage: python tools/json_to_skel.py skeleton.json skeleton.skel
"""
import json, sys


def main() -> int:
    if len(sys.argv) < 3:
        print("usage: json_to_skel.py <skeleton.json> <out.skel>", file=sys.stderr)
        return 2
    j = json.load(open(sys.argv[1], encoding="utf-8"))
    lines = ["# parent name  tx ty tz  rx ry rz rw  sx sy sz"]
    for b in j["bones"]:
        name = (b.get("name") or f"bone_{b['index']}_{b.get('name_hash_hex', '')}").replace(" ", "_")
        lo = b["local"]
        t, r, s = lo["t"], lo["r"], lo["s"]
        lines.append(
            f"{b['parent']} {name} "
            f"{t[0]} {t[1]} {t[2]} {r[0]} {r[1]} {r[2]} {r[3]} {s[0]} {s[1]} {s[2]}"
        )
    open(sys.argv[2], "w", encoding="utf-8").write("\n".join(lines) + "\n")
    print(f"wrote {sys.argv[2]}: {len(j['bones'])} bones")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
