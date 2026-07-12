#!/usr/bin/env python3
"""Extract one clip's track->bone-index map from a sab_animmeta JSON, as the
whitespace `trackmap` sab_havok65's gltf-rigged consumes (0xFFFFFFFF -> -1).

Usage: python tools/extract_trackmap.py anim_bone_map.json <clip_index> out.trackmap
"""
import json, sys

SENTINEL = 0xFFFFFFFF


def main() -> int:
    if len(sys.argv) < 4:
        print("usage: extract_trackmap.py <anim_bone_map.json> <clip_index> <out.trackmap>", file=sys.stderr)
        return 2
    j = json.load(open(sys.argv[1], encoding="utf-8"))
    idx = int(sys.argv[2])
    clip = next(c for c in j["clips"] if c["index"] == idx)
    if clip.get("bone_repr") != "index":
        print(f"warning: clip #{idx} bone_repr={clip.get('bone_repr')} (not index); "
              f"values are name-hashes, not skeleton indices — trackmap will be unbound",
              file=sys.stderr)
    ids = [(-1 if v == SENTINEL else v) for v in clip["bone_ids"]]
    open(sys.argv[3], "w").write(" ".join(str(v) for v in ids) + "\n")
    print(f"clip #{idx} '{clip['name']}': {len(ids)} tracks, "
          f"{sum(1 for v in ids if v >= 0)} bound -> {sys.argv[3]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
