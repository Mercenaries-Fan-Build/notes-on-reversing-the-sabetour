"""Minimal PE reader supporting VA<->file-offset mapping for 32-bit x86 and PPC (Xenon)."""
from __future__ import annotations
import struct


class PE:
    def __init__(self, path: str):
        self.raw = open(path, "rb").read()
        raw = self.raw
        e = struct.unpack_from("<I", raw, 0x3C)[0]
        assert raw[e:e + 4] == b"PE\0\0", "not a PE"
        self.machine, self.nsec = struct.unpack_from("<HH", raw, e + 4)
        optsz = struct.unpack_from("<H", raw, e + 20)[0]
        self.imgbase = struct.unpack_from("<I", raw, e + 24 + 28)[0]
        secoff = e + 24 + optsz
        self.secs = []  # (name, va(abs), vsz, roff, rsz)
        for i in range(self.nsec):
            o = secoff + i * 40
            name = raw[o:o + 8].rstrip(b"\0").decode("latin1")
            vsz, va, rsz, roff = struct.unpack_from("<IIII", raw, o + 8)
            self.secs.append((name, va + self.imgbase, vsz, roff, rsz))

    def va2off(self, va: int):
        for name, sva, vsz, roff, rsz in self.secs:
            if sva <= va < sva + vsz:
                fo = roff + (va - sva)
                if fo < roff + rsz:
                    return fo
        return None

    def text_range(self):
        for name, sva, vsz, roff, rsz in self.secs:
            if name.startswith(".text"):
                return (sva, sva + vsz)
        return None

    def in_text(self, va: int) -> bool:
        lo, hi = self.text_range()
        return lo <= va < hi

    def dword(self, va: int, be: bool = False):
        o = self.va2off(va)
        if o is None:
            return None
        return struct.unpack_from(">I" if be else "<I", self.raw, o)[0]

    def read(self, va: int, n: int):
        o = self.va2off(va)
        if o is None:
            return None
        return self.raw[o:o + n]
