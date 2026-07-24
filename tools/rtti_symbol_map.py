#!/usr/bin/env python3
"""Recover a symbol map from Saboteur.exe's MSVC RTTI.

The Ghidra text export gives 36,935 anonymous `FUN_*` bodies with a call graph, but it
drops `.rdata` — so the 2,765 RTTI class names and 898 `LuaGlueFunctor` binding names
never get attached to code. This tool rebuilds that link straight from the PE.

MSVC 32-bit RTTI chain (what we walk, in reverse):

    vtable[-1] -> RTTICompleteObjectLocator -> TypeDescriptor -> ".?AVWSFoo@@"
    vtable[0..] -> virtual method VAs (pointers into .text)

So: find TypeDescriptors, find the COLs that reference them, find the .rdata dwords that
point at a COL — the vtable begins at the next dword. Everything after that which points
into .text is a virtual method.

Output (data/):
  rtti_vtables.tsv     class, vtable VA, slot, method VA        <- the symbol map
  lua_binding_map.tsv  binding name, functor class, glue VA, callee VA
  symbol_map.tsv       VA -> best-known name (the thing to feed back into Ghidra)

Usage:  python tools/rtti_symbol_map.py [--exe "C:\\GOG Games\\The Saboteur\\Saboteur.exe"]
"""
from __future__ import annotations

import argparse
import re
import struct
from collections import defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
DEFAULT_EXE = Path(r"C:\GOG Games\The Saboteur\Saboteur.exe")
DATA = REPO / "data"


class PE:
    """Minimal 32-bit PE reader: sections + VA<->file-offset mapping."""

    def __init__(self, raw: bytes):
        self.raw = raw
        e_lfanew = struct.unpack_from("<I", raw, 0x3C)[0]
        assert raw[e_lfanew:e_lfanew + 4] == b"PE\0\0", "not a PE"
        coff = e_lfanew + 4
        machine, nsec = struct.unpack_from("<HH