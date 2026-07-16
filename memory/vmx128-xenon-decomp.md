---
name: vmx128-xenon-decomp
description: VMX128 (Xbox360 Xenon PPC vector ISA) encoding reference — the enabler for a FULL decomp of the symbol-rich 2008 prototype .xex, a far richer oracle than the .map alone.
metadata:
  type: reference
---

**Why:** the 2008 prototype ([[prototype-symbols-goldmine]]) is Xbox360/Xenon (PowerPC, big-endian) with
FULL PDB symbols. Using the `.map`/`.pdb` gives NAMES↔addresses. The next tier is to actually
**decompile** `game-files/symbols/WildStar_d.xex` (or `.exe`) → named, decompiled *logic* (much richer
than name-correlation). The blocker: Xenon code is dense with **VMX128**, the 360's custom 128-vector-
register SIMD extension, which stock PowerPC/AltiVec disassemblers don't decode.

**Reference:** https://biallas.net/doc/vmx128/vmx128.txt — encodings for **96 VMX128 instructions**
(loads/stores `lvx128`/`stvx128`/`lvlx128`…, FP `vaddfp128`/`vmaddfp128`/`vrsqrtefp128`, logic/shift,
compare/select `vcmpeqfp128`/`vsel128`/`vperm128`, pack/unpack incl. D3D `vpkd3d128`/`vupkd3d128`,
fixed-point conv). Primary opcodes **0x04 and 0x05**; 128 vector regs; the hard part is **split register
fields** (5-bit base + upper 2–3 bits scattered in the word), and the `.`/R-bit compare forms.

**Path to a named 360 decomp:**
1. Ghidra + Xbox360 **XEX loader**, PowerPC/AltiVec processor.
2. Extend the SLEIGH spec with the VMX128 ops from the doc (or use an existing Xenon SLEIGH if found).
3. Import the **PDB** symbols → every function named + decompiled.
Result = fully-named 360 decomp: read `PblCRC`/`WSConduit`/`WSPackFile`/Havok/damage-solver logic
directly; confirm write-path formulas (e.g. the crc pre-hash string) from named code.

**Caveat:** 360/PPC/big-endian, 2008 pre-release — a REFERENCE ORACLE. Verify every finding against the
2009 PC retail decomp before relying on offsets/behavior. Names + algorithms transfer; addresses/struct
offsets/endianness do NOT. Queued as the highest-leverage campaign after the symbol-name + write-edge
streams. See [[symbol-map-methodology]], [[operating-model-and-modding]].
