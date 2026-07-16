"""Targeted MSVC name -> qualified Class::Method extractor.

We do NOT need full signatures, only the qualified name path. Handles the common
cases that appear in vtables: named methods, ctors/dtors, deleting destructors,
and the frequent operator codes. Returns (qualified_name, kind) or (None, None).
"""
from __future__ import annotations

_OP = {
    "0": "{ctor}", "1": "{dtor}", "2": "operator new", "3": "operator delete",
    "4": "operator=", "5": "operator>>", "6": "operator<<", "7": "operator!",
    "8": "operator==", "9": "operator!=", "A": "operator[]", "C": "operator->",
    "D": "operator*", "E": "operator++", "F": "operator--", "G": "operator-",
    "H": "operator+", "I": "operator&", "K": "operator/", "M": "operator<",
    "N": "operator<=", "O": "operator>", "P": "operator>=", "R": "operator()",
    "S": "operator~", "T": "operator^", "U": "operator|", "V": "operator&&",
    "W": "operator||", "Y": "operator+=", "Z": "operator-=",
    "_0": "operator/=", "_1": "operator%=", "_2": "operator>>=",
    "_3": "operator<<=", "_4": "operator&=", "_5": "operator|=", "_6": "operator^=",
    "_G": "{vdtor}", "_E": "{vdtor}", "_7": "{vftable}", "_8": "{vbtable}",
    "_U": "operator new[]", "_V": "operator delete[]",
}


def _read_scopes(s: str, i: int):
    """Read @-separated scope tokens until '@@' terminator. Returns (scopes, next_i)."""
    scopes = []
    while i < len(s):
        if s[i] == "@":
            if i + 1 < len(s) and s[i + 1] == "@":
                return scopes, i + 2
            i += 1
            continue
        j = s.find("@", i)
        if j < 0:
            scopes.append(s[i:])
            return scopes, len(s)
        scopes.append(s[i:j])
        i = j
    return scopes, i


def demangle(sym: str):
    """Return (qualified_name, kind). kind in {method,ctor,dtor,vdtor,operator,vftable,other}."""
    if not sym or sym[0] != "?":
        return None, None
    if sym.startswith("??"):
        rest = sym[2:]
        code = None
        if rest and rest[0] == "_" and len(rest) > 1:
            code = "_" + rest[1]
            rest2 = rest[2:]
        elif rest:
            code = rest[0]
            rest2 = rest[1:]
        else:
            return None, None
        opname = _OP.get(code)
        if opname is None:
            return None, "other"
        scopes, _ = _read_scopes(rest2, 0)
        if not scopes:
            return None, "other"
        cls = "::".join(reversed(scopes))
        if opname == "{ctor}":
            return f"{cls}::{scopes[0]}", "ctor"
        if opname == "{dtor}":
            return f"{cls}::~{scopes[0]}", "dtor"
        if opname == "{vdtor}":
            return f"{cls}::~{scopes[0]}", "vdtor"
        if opname == "{vftable}":
            return f"{cls}::`vftable'", "vftable"
        if opname.startswith("{"):
            return f"{cls}::{opname}", "other"
        return f"{cls}::{opname}", "operator"
    rest = sym[1:]
    j = rest.find("@")
    if j < 0:
        return None, None
    name = rest[:j]
    scopes, _ = _read_scopes(rest, j)
    if not scopes:
        return name, "other"
    qual = "::".join(reversed(scopes)) + "::" + name
    return qual, "method"


def classname(sym: str):
    q, kind = demangle(sym)
    if q is None:
        return None
    parts = q.split("::")
    if len(parts) >= 2:
        return "::".join(parts[:-1])
    return None
