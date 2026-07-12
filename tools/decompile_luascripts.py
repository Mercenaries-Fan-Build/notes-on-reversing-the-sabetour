#!/usr/bin/env python3
"""Decompile The Saboteur's LuaScripts.luap into a readable source corpus.

Pipeline:
  1. `saboteur_lua` (Rust) parses the .luap and writes chunks/ named by the real
     source path recovered from the LuaQ debug info. See docs/formats/lua_scripts.md.
  2. unluac decompiles each chunk to Lua source.

Unlike the Mercenaries 2 *retail DLC* corpus, Saboteur's bytecode is **not debug-stripped**:
local names and line numbers survive, so unluac output is already readable and no
copy-propagation cleanup pass is needed.

Java: reuses the JDK vendored in the Mercenaries 2 repo (nothing to install).

Usage:
  python tools/decompile_luascripts.py [--chunks <dir>] [--out <dir>] [--jobs N]
"""
from __future__ import annotations

import argparse
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
MERCS2 = REPO.parent / "notes-on-the-released-game"

JAVA = MERCS2 / "tools" / "jdk21" / "jdk-21.0.11+10" / "bin" / "java.exe"
UNLUAC = MERCS2 / "tools" / "external" / "unluac" / "unluac.jar"

DEFAULT_OUT = REPO / "docs" / "saboteur-luacd" / "src"


def decompile(chunk: Path) -> tuple[Path, bool, str]:
    try:
        r = subprocess.run(
            [str(JAVA), "-jar", str(UNLUAC), str(chunk)],
            capture_output=True,
            timeout=120,
        )
    except subprocess.TimeoutExpired:
        return chunk, False, "unluac timeout"
    out = r.stdout.decode("utf-8", "replace")
    err = r.stderr.decode("utf-8", "replace")
    if r.returncode == 0 and out.strip() and "Exception" not in err:
        return chunk, True, out
    tail = (err or out).strip().splitlines()
    return chunk, False, tail[-1] if tail else "empty output"


def write_lua(path: Path, text: str) -> None:
    """Normalise CRLF -> LF; unluac emits CRLF on Windows."""
    path.parent.mkdir(parents=True, exist_ok=True)
    body = text.replace("\r\n", "\n").replace("\r", "\n")
    path.write_bytes(body.encode("utf-8"))


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--chunks", type=Path, required=True,
                    help="chunks/ dir produced by saboteur_lua")
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT)
    ap.add_argument("--jobs", type=int, default=8)
    args = ap.parse_args()

    for tool, p in (("java", JAVA), ("unluac.jar", UNLUAC)):
        if not p.exists():
            print(f"error: {tool} not found at {p}", file=sys.stderr)
            return 1
    if not args.chunks.is_dir():
        print(f"error: no chunks dir at {args.chunks}", file=sys.stderr)
        return 1

    chunks = sorted(p for p in args.chunks.rglob("*") if p.is_file())
    print(f"decompiling {len(chunks)} chunks with {args.jobs} workers -> {args.out}")

    ok, fail = [], []
    with ThreadPoolExecutor(max_workers=args.jobs) as ex:
        for chunk, success, text in ex.map(decompile, chunks):
            rel = chunk.relative_to(args.chunks)
            if success:
                write_lua(args.out / rel.with_suffix(".lua"), text)
                ok.append(rel)
            else:
                fail.append((rel, text))
                print(f"  FAIL {rel}: {text}")

    print(f"\n=== decompiled {len(ok)}/{len(chunks)} -> {args.out}")
    if fail:
        f = args.out.parent / "_decompile_failures.txt"
        f.parent.mkdir(parents=True, exist_ok=True)
        f.write_text("\n".join(f"{r}\t{w}" for r, w in fail), encoding="utf-8")
        print(f"failures ({len(fail)}) -> {f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
