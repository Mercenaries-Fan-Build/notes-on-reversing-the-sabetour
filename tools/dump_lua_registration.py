#!/usr/bin/env python3
r"""
dump_lua_registration.py -- recover the complete {Table.Name -> C impl VA} Lua binding
map from the retail PC Saboteur.exe, statically, with no Ghidra project required.

    python tools/dump_lua_registration.py "C:/GOG Games/The Saboteur/Saboteur.exe" \
        -o data/lua_registration_map.tsv

How it works (see docs/sab-engine-lua-seam/01-registration-and-dispatch.md):

  Every binding is an instantiation of the class template LuaGlueFunctor0<&F> (void F)
  or LuaGlueFunctor0R<H,&F> (int F). MSVC emits, per instantiation:

    * an RTTI type descriptor whose mangled name embeds the C++ function symbol, e.g.
        .?AV?$LuaGlueFunctor0@$1?ActorRagdoll@@YAXPAUlua_State@@@Z@@
    * an RTTI complete-object-locator (COL) pointing at that type descriptor
    * a single-entry vtable, preceded at [vtable-4] by the COL. Slot 0 is a getter
        mov eax, <thunk>; ret
    * a 32-byte lua_CFunction thunk
        mov eax,[esp+4]; push eax; call <impl>; add esp,4; mov eax,<n>; ret
    * an 84-byte registration stanza inside a CRT static initializer, which news the
      4-byte functor, stores the vtable, stores the Lua name into the template's
      static s_name slot, and links a {functor,name} node into a per-table registry.

  Registration is per-table: each initializer opens with
      push <table-name>; mov ecx,<new 0x3c-byte registry>; call 0x6f6620
  and every stanza that follows inserts into that registry (ecx=ebx) via the intrusive
  list-insert at 0x006f6660.

Verified anchor: Actor.Ragdoll -> C++ ActorRagdoll -> impl 0x00714230, whose EALA
assertion string names Script\Interface\Actor.cpp / "ActorRagdoll".
"""
import argparse, re, struct, sys
from collections import Counter, defaultdict

CALL_TABLE_CTOR = 0x006f6620   # LuaTable-ish registry ctor (tail-jmps into .secu)
CALL_LIST_INSERT = 0x006f6660  # intrusive registry list insert


class PE:
    def __init__(self, path):
        self.d = d = open(path, "rb").read()
        pe = struct.unpack_from("<I", d, 0x3C)[0]
        if d[pe:pe + 4] != b"PE\0\0":
            raise SystemExit("not a PE: %s" % path)
        nsec = struct.unpack_from("<H", d, pe + 6)[0]
        optsz = struct.unpack_from("<H", d, pe + 20)[0]
        self.base = struct.unpack_from("<I", d, pe + 24 + 28)[0]
        self.secs = []
        o = pe + 24 + optsz
        for _ in range(nsec):
            n = d[o:o + 8].rstrip(b"\0").decode()
            vs, va, rs, ro = struct.unpack_from("<IIII", d, o + 8)
            self.secs.append((n, self.base + va, vs, ro, rs))
            o += 40

    def va2off(self, v):
        for n, b, vs, ro, rs in self.secs:
            if b <= v < b + max(vs, rs):
                return ro + (v - b)

    def off2va(self, o):
        for n, b, vs, ro, rs in self.secs:
            if ro <= o < ro + rs:
                return b + (o - ro)

    def sec(self, v):
        for n, b, vs, ro, rs in self.secs:
            if b <= v < b + max(vs, rs):
                return n
        return "?"

    def cstr(self, v, maxlen=128):
        o = self.va2off(v)
        if o is None:
            return None
        e = self.d.find(b"\0", o)
        if e < 0 or e - o > maxlen or e == o:
            return None
        try:
            s = self.d[o:e].decode("ascii")
        except Exception:
            return None
        return s if all(32 <= ord(c) < 127 for c in s) else None


def demangle(m):
    """.?AV?$LuaGlueFunctor0@$1?Name@Class@@SAX... -> (family, fn, class|None)"""
    r = re.match(r"\.\?AV\?\$(LuaGlueFunctor0R?)@(\w*)\$1\?(\w+)(?:@(\w+))?@@[SQY]A", m)
    return (r.group(1), r.group(3), r.group(4)) if r else (None, None, None)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("exe")
    ap.add_argument("-o", "--out", default="lua_registration_map.tsv")
    a = ap.parse_args()
    p = PE(a.exe)
    d = p.d

    # 1. RTTI type descriptors for LuaGlue* instantiations
    tds = {}
    for m in re.finditer(rb"\.\?AV[^\x00]{0,300}?\x00", d):
        s = m.group()[:-1]
        if b"LuaGlue" in s:
            tds[p.off2va(m.start() - 8)] = s.decode()

    # 2. complete-object-locators referencing them
    cols = {}
    for n, base, vs, ro, rs in p.secs:
        if n != ".rdata":
            continue
        for o in range(0, rs - 0x14, 4):
            t, = struct.unpack_from("<I", d, ro + o + 0x0C)
            if t in tds and struct.unpack_from("<III", d, ro + o) == (0, 0, 0):
                cols[base + o] = t

    # 3. vtable at COL+4; slot0 = `mov eax,<thunk>; ret`; thunk -> impl
    vt = {}
    for col, td in cols.items():
        i = d.find(struct.pack("<I", col))
        while i >= 0:
            v = p.off2va(i)
            if v and p.sec(v) == ".rdata":
                s0, = struct.unpack_from("<I", d, i + 4)
                if p.sec(s0) == ".text":
                    so = p.va2off(s0)
                    thunk = impl = None
                    nres = shape = ""
                    if d[so] == 0xB8 and d[so + 5] == 0xC3:      # mov eax,<thunk>; ret
                        thunk, = struct.unpack_from("<I", d, so + 1)
                        to = p.va2off(thunk)
                        if to is None:
                            pass
                        elif d[to:to + 6] == b"\x8b\x44\x24\x04\x50\xe8":
                            # void-adapter: push L; call F; add esp,4; mov eax,<n>; ret
                            rel, = struct.unpack_from("<i", d, to + 6)
                            impl = thunk + 10 + rel
                            shape = "adapter"
                            t = d[to + 10:to + 19]
                            if t[:3] == b"\x83\xc4\x04" and t[3] == 0xB8:
                                nres = str(struct.unpack_from("<I", d, to + 14)[0])
                        elif d[to] == 0xE9:                       # jmp <impl>  (int F is
                            rel, = struct.unpack_from("<i", d, to + 1)   # already a
                            impl = thunk + 5 + rel                       # lua_CFunction)
                            shape = "jmp"
                            nres = "eax"
                        else:
                            # F was inlined into the adapter: the adapter IS the impl
                            impl = thunk
                            shape = "inlined"
                            w = d[to:to + 0x40]
                            k = w.find(b"\xb8\x01\x00\x00\x00\xc3")
                            if k >= 0:
                                nres = "1"
                    vt[v + 4] = dict(col=col, td=td, mangled=tds[td], stub=s0,
                                     thunk=thunk, impl=impl, nres=nres, shape=shape)
            i = d.find(struct.pack("<I", col), i + 1)

    # 4. registration stanzas: c7 00 <vtable> ; c7 05 <s_name slot> <name ptr>
    _, TVA, _, TRO, TRS = [s for s in p.secs if s[0] == ".text"][0]
    b = d[TRO:TRO + TRS]
    reg = {}
    for o in range(len(b) - 16):
        if b[o] != 0xC7 or b[o + 1] != 0x00:
            continue
        v, = struct.unpack_from("<I", b, o + 2)
        if v not in vt or b[o + 6] != 0xC7 or b[o + 7] != 0x05:
            continue
        slot, np = struct.unpack_from("<II", b, o + 8)
        nm = p.cstr(np)
        if nm:
            reg[v] = dict(site=TVA + o, slot=slot, name=nm)

    # 5. group stanzas into per-initializer runs; recover each run's table name by
    #    scanning back from the first stanza for `push <str>` + `call <ctor>`
    sites = sorted((r["site"], v) for v, r in reg.items())
    runs, cur = [], [sites[0]]
    for s in sites[1:]:
        if s[0] - cur[-1][0] <= 200:
            cur.append(s)
        else:
            runs.append(cur)
            cur = [s]
    runs.append(cur)

    tbl_of = {}
    for run in runs:
        first = run[0][0]
        o = p.va2off(first)
        name = None
        for back in range(4, 0x400):
            q = o - back
            if d[q] != 0x68:
                continue
            sp, = struct.unpack_from("<I", d, q + 1)
            s = p.cstr(sp, 48)
            if not s:
                continue
            # require a `call <ctor>` within the next 16 bytes
            w = d[q + 5:q + 21]
            hit = False
            for k in range(len(w) - 5):
                if w[k] == 0xE8:
                    rel, = struct.unpack_from("<i", w, k + 1)
                    if p.off2va(q + 5 + k) + 5 + rel == CALL_TABLE_CTOR:
                        hit = True
            if hit:
                name = s
                break
        for _, v in run:
            tbl_of[v] = name

    rows = []
    for v, info in vt.items():
        fam, fn, cls = demangle(info["mangled"])
        r = dict(vtable=v, family=fam, cpp=fn, cls=cls, **info)
        r.update(reg.get(v, {}))
        r["table"] = tbl_of.get(v)
        rows.append(r)
    named = [r for r in rows if r.get("name")]

    print("LuaGlue instantiations : %d" % len(rows))
    print("registration stanzas   : %d" % len(named))
    print("initializer runs       : %d" % len(runs))
    print("tables recovered       : %d" % len(set(filter(None, tbl_of.values()))))
    print("families               : %s" % Counter(r["family"] for r in rows).most_common())
    print("thunk shapes           : %s" % Counter(r["shape"] for r in named).most_common())
    print("rows with impl VA      : %d / %d" % (sum(1 for r in named if r["impl"]), len(named)))
    per = Counter(r["table"] for r in named)
    print("\nbindings per table:")
    for t, c in per.most_common():
        print("   %-22s %d" % (t, c))

    with open(a.out, "w", newline="") as f:
        f.write("table\tlua_name\tcpp_symbol\tcpp_class\tfamily\tshape\tnresults\t"
                "impl_va\tthunk_va\tstub_va\tvtable_va\ts_name_slot\tstanza_va\n")
        for r in sorted(named, key=lambda x: (x["table"] or "~", x["name"])):
            f.write("\t".join([
                r["table"] or "", r["name"], r["cpp"] or "", r["cls"] or "",
                r["family"] or "", r["shape"], r["nres"],
                "%08x" % r["impl"] if r["impl"] else "",
                "%08x" % r["thunk"] if r["thunk"] else "",
                "%08x" % r["stub"], "%08x" % r["vtable"],
                "%08x" % r["slot"], "%08x" % r["site"]]) + "\n")
    print("\nwrote %s (%d rows)" % (a.out, len(named)))


if __name__ == "__main__":
    main()
