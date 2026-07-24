# Gaps and next steps — what the seam series does *not* cover

*The completeness critic. Everything here is a hole, a contradiction, or a lie of omission in the other
21 documents. Each entry carries a citation and a concrete next step.*

The series ([00](00-seam-overview.md)–[23](23-family-render-weather-fx.md)) is unusually careful:
counts close, most claims are tiered honestly, and several docs carry adversarial-verification headers
that corrected their own authors. The failure is not sloppiness. It is **structural**: the family split
was carved by *gameplay topic*, and the binding surface is carved by *translation unit*. Where those two
carvings disagree, bindings fell through — silently, because no doc's inclusion rule ever claimed them,
so no doc's count ever missed them.

**Headline: 86 of 898 bindings (9.6%) appear in no family doc. 73 appear in no document at all.**
Two entire namespace tables (`Sensory`, `Damage`) and effectively three more (`Sabotage` 8/8,
`AttractionPt` 24/25, `Freeplay` 17/21) are undocumented. They are not dead corners: the orphaned tables
carry **207 `AttractionPt.*` and 79 `Freeplay.*` call sites** in the shipped Lua corpus.

> **Closed 2026-07-16 — the headline above is now historical.** All 86 orphans are documented, by two new
> docs and three extensions: [22](22-family-attraction-focus-sabotage-points.md) (§1.1),
> [23](23-family-render-weather-fx.md) (§1.2), and the `Sensory`/`Damage`/`Freeplay` adoptions into
> [11](11-family-ai-squad-combat.md), [16](16-family-world-zone-interior.md) and
> [20](20-family-inventory-perks-shop.md). The census was **re-run with §6's script, unmodified except to
> widen the doc glob to `10–23`: 0 orphans against the family docs, 0 against 00–06 as well, 26 of 26
> tables complete, 898/898 pinned.** All five docs were adversarially verified and all five came back
> *corrected*. §1's method, its numbers and its diagnosis are preserved below as written, because the
> **method is the durable part** — the strict-matcher warning especially (see the callout in §1 Method).
> Nothing structural stops this recurring; see §2's CI recommendation, now the successor open item.

---

## 1. The orphan census — ~~the main deliverable~~ **resolved ✅**

### Method (reproducible, and deliberately strict)

Coverage was computed against [`data/lua_registration_map.tsv`](../../data/lua_registration_map.tsv), not
[`data/lua_bindings.txt`](../../data/lua_bindings.txt), per [00 §Machine-readable](00-seam-overview.md) —
the tsv's `lua_name` is the byte-level registered name, and the flat list is only C++ symbols. (The two
sets reconcile exactly: 898 = 898, 0 in either and not the other, once `WSTrain::` is stripped. Verified.)

A binding counts as **covered** by a doc only if that doc contains its distinctive `cpp_symbol` as a
token, the qualified `Table.LuaName`, or its `impl_va`. **A bare `lua_name` match was rejected**, because
`Sabotage.Set`, `FocusPt.Create`, `AttractionPt.Delete` and `FocusPt.Enable` have `lua_name`s that are
single generic English words (`Set`, `Create`, `Delete`, `Enable`) which appear in every document in the
series. A naive token diff scores 77 orphans; **the honest number is 86**, and the 9 extra are precisely
those generic-name rows that a loose match falsely credits. Any future audit that reports ~77 has been
fooled by this.

> **Keep the strict matcher even though it currently makes no difference.** At 100% coverage
> (2026-07-16) strict and loose both score 0, so the trap below is *dormant, not gone* — it cannot be
> re-demonstrated by running the script today. The moment coverage regresses, a loose matcher will
> silently under-report by roughly the same 9 rows, and the rows it hides are exactly the ones most
> likely to be missed for real: generic-named members of mechanism tables. This is the single most
> reusable thing in this section.

| Scope | Orphans (as found) | Re-run 2026-07-16 |
|---|---:|---:|
| In no **family** doc (10–21 → now 10–23) | **86** | **0** |
| In no document at all, including core 00–06 | **73** | **0** |
| Fully covered tables | 18 of 26 | **26 of 26** |

### Where they are

| Table | Orphans / total | Corpus call sites | Should have gone to | **Went to ✅** |
|---|---:|---:|---|---|
| `AttractionPt` | **24 / 25** | 207 | new doc (§1.1) — [11](11-family-ai-squad-combat.md) took only the 5 need-related | [22](22-family-attraction-focus-sabotage-points.md) |
| `Freeplay` | **17 / 21** | 79 | [20](20-family-inventory-perks-shop.md) — it already owns collectables | [20 § Freeplay](20-family-inventory-perks-shop.md#the-freeplay-table--ambient-events) |
| `Render` | **15 / 42** | 454 (whole table) | new doc (§1.2) — 7 docs took slices, nobody took weather/FX | [23](23-family-render-weather-fx.md) — which found the residue is **19**, not 15 (see §1.2) |
| `FocusPt` | **11 / 18** | 30 | new doc (§1.1) | [22](22-family-attraction-focus-sabotage-points.md) |
| `Sabotage` | **8 / 8** | **0** | new doc (§1.1) | [22](22-family-attraction-focus-sabotage-points.md) |
| `Sensory` | **8 / 8** | 27 | [11](11-family-ai-squad-combat.md) — it is AI perception, unambiguously | [11](11-family-ai-squad-combat.md) |
| `Damage` | **2 / 2** | 6 | [16](16-family-world-zone-interior.md) — prop damage states | [16](16-family-world-zone-interior.md) — adopted, counted separately from its 55 family rows |
| `Searchlight` | **1 / 2** | 6 | [11](11-family-ai-squad-combat.md) — it already took `Searchlight.SetTarget` | [22](22-family-attraction-focus-sabotage-points.md) — the point primitives cohered better than AI did |

The full 86-row list with `cpp_symbol`, `impl_va`, `family` and `shape` is reproducible in ~20 lines of
Python (§6). The highest-value rows, with proof they are live:

| Orphan | `impl_va` | Shape | Corpus proof it is called |
|---|---|---|---|
| `Sensory.CanSee` | `0x00742f00` | `0R`/`jmp` | [SoldierState_PaperCheckLeader.lua:41](../saboteur-luacd/src/Experimental/SoldierState_PaperCheckLeader.lua#L41); 18 sites |
| `Sensory.HaveLOS` | `0x00743040` | `0R`/`jmp` | 2 sites |
| `Sensory.GetVisibleEnemyList` | `0x00742940` | `0R`/`jmp` | 2 sites |
| `Damage.SetDamageState` | `0x00727e80` | `0`/`adapter` | [Act_1_Farm.lua:1127](../saboteur-luacd/src/Missions/Act_1_Farm.lua#L1127) — `(hProp, "Canal_Scaffold_Med", 1)` |
| `AttractionPt.IsAvailable` | `0x00717d60` | `0R`/`jmp` | [Act_1_BarFight.lua:576](../saboteur-luacd/src/Missions/Act_1_BarFight.lua#L576) |
| `AttractionPt.IsBeingUsedBySomeone` | `0x00717e80` | `0R`/`jmp` | [P3FP_Hit.lua:416](../saboteur-luacd/src/Missions/P3FP_Hit.lua#L416) |
| `AttractionPt.FindPtInObject` | `0x00718070` | `0R`/`jmp` | [Act_3_Mission_4.lua:186](../saboteur-luacd/src/Missions/Act_3_Mission_4.lua#L186) |
| `Freeplay.UnlockAmbientTag` | `0x00729f30` | `0`/`adapter` | [Paris_1_Mission_1.lua:255](../saboteur-luacd/src/Missions/Paris_1_Mission_1.lua#L255) |
| `Render.EnableLightning` | `0x0073dbd0` | `0`/`adapter` | [Act_1_Escape.lua:32](../saboteur-luacd/src/Missions/Act_1_Escape.lua#L32) |
| `Render.FadeTo` | `0x0073e660` | `0`/`adapter` | [WRAPPER_Event.lua:500](../saboteur-luacd/src/Includes/WRAPPER_Event.lua#L500) — **in the wrapper layer itself** |
| `FocusPt.SetOnFocusCallback` | `0x00729680` | `0`/`adapter` | [Paris_2_Mission_5.lua:367](../saboteur-luacd/src/Missions/Paris_2_Mission_5.lua#L367) |

`Render.FadeTo` deserves special mention: it is called from `WRAPPER_Event.lua`, i.e. **the wrapper layer
that [06](06-lua-side-wrapper-layer.md) documents depends on a binding no family doc describes.**

### 1.1 ~~Proposed~~ **Written ✅** — [`22-family-attraction-focus-sabotage-points.md`](22-family-attraction-focus-sabotage-points.md)

> **Written and verified 2026-07-16**, at the 53 bindings proposed below and with this section's scoping
> argument intact. The **`Sabotage` next-step below was executed and it settled the question**:
> `SabotagePtOnSet` @ `0x00740f70` *does* store a callback name via `FUN_0070a180` — arg 2 is gated
> non-empty (`cmp byte [ebx],0`) and pushed as the name, with an optional self table via `0x70a4b0` —
> the same registrar `Actor.SetDeathCallback` @ `0x00762da0` uses. So **hypothesis (b) is wrong: the
> `Sabotage` table is a live C→Lua surface**, registered and callable, that the shipped corpus simply
> never uses. Its 0 call sites are a fact about the shipped scripts, not about the engine.

`AttractionPt` (25) + `FocusPt` (18) + `Sabotage` (8) + `Searchlight` (2) = **53 bindings**. These four
tables are the engine's "point" primitives — named, placed, world-anchored markers that actors navigate
to, cameras focus on, and bombs attach to. They occupy four adjacent VA slabs (§2) and share an idiom.
Doc [11](11-family-ai-squad-combat.md) took 5 `AttractionPt` rows because *needs* are AI; docs
[15](15-family-mission-objective-task.md)/[18](18-family-cinematics-camera-face.md) took 7 `FocusPt` rows
because *objectives and cameras* are theirs. Nobody owned the primitive itself. 53 bindings and 243
call sites is comfortably doc-sized — larger than [14](14-family-navigation-movement.md) (23) or
[18](18-family-cinematics-camera-face.md).

**`Sabotage` is the standout finding inside it.** All 8 bindings are registered, and **`Sabotage.*` has
zero call sites across all 321 corpus files.** Sabotage points are instead reached *through the
attraction-point API by name string*:

```lua
-- Missions/Act_3_Mission_4.lua:186
local hSabPoint = AttractionPt.FindPtInObject(self.hMainTrainEngine, "SabotagePt_Dynamite01")
```

So the `Sabotage` table is a registered-but-unused-by-shipped-script surface, and the shipped path to the
same objects goes via `AttractionPt`. That is either (a) a superseded API kept alive for the unshipped
`LuaMissions.luap`, or (b) engine-internal-only. **Next step:** read `SabotagePtSet` @ `0x00740b00` and
`SabotagePtOnSet` @ `0x00740f70`; if `OnSet` stores a callback name via `FUN_0070a180`
([05 §3](05-engine-to-lua-callbacks.md)), the table is a live C→Lua surface and (b) is wrong.

### 1.2 ~~Proposed~~ **Written ✅** — [`23-family-render-weather-fx.md`](23-family-render-weather-fx.md)

> **Written and verified 2026-07-16 — and it corrected this section's own arithmetic.** The residue is
> **19 bindings, not the 15 listed below.** Doc 23 re-partitioned all 42 rows against the claimant docs'
> own **inclusion rules** and found four more that no doc actually claims: `HeatShimmerFilter`,
> `DrunkEffectFilter`, `FadeScreen` and `PrintDialogue` are named in docs 12/17/19 **only in order to
> exclude themselves from them** (e.g. [12:31](12-family-suspicion-wtf-alarm.md),
> [19:59](19-family-ui-hud-tutorial.md), [17:41](17-family-sound-voice-conversation.md)). Both numbers are
> honest measures of different things, and they nest exactly — re-derived here: the 15 are a strict subset
> of the 19, difference exactly those four.
>
> **The lesson, and it is the sharpest one in this document: the strict matcher is not conservative
> enough.** All four were credited by its *qualified* `Table.LuaName` rule — its **strongest** form, the
> one §1's Method callout holds up as the trustworthy alternative to bare names. But "doc 12 contains the
> string `Render.HeatShimmerFilter`" is equally true whether the doc documents that row or disclaims it,
> and here it disclaimed it. **A textual match can prove mention; it can never prove ownership.** §2's CI
> script must therefore parse each doc's *table rows* (or a declared manifest), not grep its prose — a
> grep-based invariant would have scored this gap 15 and called it 15 forever.
> The method note below was also vindicated — the three `shape=inlined` bodies were absent from the
> Ghidra export exactly as predicted, and were recovered from the exe with [19](19-family-ui-hud-tutorial.md)'s
> capstone harness.

`Render` is the worst-managed table in the series: **42 bindings sliced across seven documents by topic** —
[12](12-family-suspicion-wtf-alarm.md) took the 17 `Render.WTF*` rows, [19](19-family-ui-hud-tutorial.md)
took the screen-print/filter rows, [16](16-family-world-zone-interior.md) took `SetWaterLevel`/
`ResetWaterLevel`, [17](17-family-sound-voice-conversation.md) took `PrintDialogue`,
[10](10-family-actor-human.md) took `EnableHumanHalos`, [18](18-family-cinematics-camera-face.md) took
`CameraShakeExplosion`, [15](15-family-mission-objective-task.md) took `ShowMissionComplete`. The residue —
**weather, lightning, screen fade, FX lifetime, UV scrolling, object highlight, lights** — matches no
gameplay noun and so matched no family:

`EnableAmbientRain` `Rain` `EnableLightning` `EnableLightningFlash` `SetLightningFlashParams`
`StartFX` `EndFX` `SetFXTime` `FadeTo` `StartHighlight` `StopHighlight` `ToggleLights`
`PauseUVScrolling` `ResumeUVScrolling` `ResetUVScrolling`

This is not obscure content: `Render.EnableLightning(true)` opens three separate missions
([Act_1_Escape.lua:32](../saboteur-luacd/src/Missions/Act_1_Escape.lua#L32),
[Act_1_Factory.lua:387](../saboteur-luacd/src/Missions/Act_1_Factory.lua#L387),
[Act_1_Farm.lua:33](../saboteur-luacd/src/Missions/Act_1_Farm.lua#L33)) and `Render.FadeTo` is
load-bearing for the wrapper layer. The Saboteur's signature aesthetic is weather and colour, and **the
bindings that drive it are the least documented part of the seam.**

**Method note for whoever writes it:** 3 of the 15 (`PauseUVScrolling` `0x0073fec0`, `ResetUVScrolling`
`0x0073fe70`, `ResumeUVScrolling` `0x0073ff10`) are `shape=inlined` and will be missing from the Ghidra
export. Use [19](19-family-ui-hud-tutorial.md)'s capstone-on-retail-exe method, which was built for
exactly this and is the series' best methodological contribution.

---

## 2. Why the orphans are *whole tables* — the diagnosis

Sorting the tsv by `impl_va` shows every table is one **contiguous VA slab**, and the slabs run in
**alphabetical order of table name**:

```
0x0070c300-0x00716930  Actor         111
0x00717790-0x00719a50  AttractionPt   25   <- orphan
0x0071a6a0-0x0071bd90  Checkpoint     24
0x0071c3b0-0x0071ebf0  Cin            32
0x0071f690-0x00724f40  Combat         65
0x00727e80-0x00727f70  Damage          2   <- orphan
0x00728230-0x00728510  Filter          3
0x007286f0-0x00729ae0  FocusPt        18   <- orphan
0x00729e00-0x0072c0d0  Freeplay       21   <- orphan
...
0x007407d0-0x00740f70  Sabotage        8   <- orphan
0x00742130-0x00742290  Searchlight     2   <- orphan
0x00742940-0x007433e0  Sensory         8   <- orphan
0x00765aa0               Zone            2
```

(`Train` is the sole exception at `0x0061f1a0`–`0x006254e0`, consistent with
[13](13-family-vehicle-train-plane.md)'s finding that it is `WSTrain` class statics in a separate TU.)

This **independently confirms** [01](01-registration-and-dispatch.md)/[00 §2](00-seam-overview.md)'s claim
of "26 registries, one per `Script\*.cpp` translation unit" — from link order, which neither doc used.
The linker emitted one alphabetically-ordered object file per table.

And it explains the failure mode exactly: **the binary is partitioned by table; the docs were partitioned
by topic.** For the 18 tables whose name *is* a gameplay noun (`Actor`, `Vehicle`, `Sound`) the two
carvings coincide and coverage is 100%. For the 8 tables that are *mechanisms* rather than nouns
(`AttractionPt`, `Sensory`, `FocusPt`, `Sabotage`, `Damage`, `Searchlight`) or that cut across nouns
(`Render`, `Freeplay`), topic-carving shredded them: each family doc reached in, took the rows matching
its noun, and left the rest. Because every family doc's inclusion rule is stated in terms of *its own*
scope, none of them was ever wrong — and the residue was invisible to all of them.

**Structural recommendation:** the series needs a coverage invariant, not another doc. Add
`tools/check_seam_coverage.py` asserting **every** tsv row is claimed by ≥1 family doc, and run it in CI.
That converts this class of gap from "found by an agent who happened to look" into "cannot be committed".
The strict matcher in §6 is that script's core.

> **Still open, and now the point of this document (2026-07-16).** Two docs were written and the 86
> orphans are gone — which is the outcome this section explicitly argued *against* treating as the fix.
> The diagnosis above is unaffected by the coverage number: the docs are still partitioned by topic and
> the binary is still partitioned by table, so the next family doc can re-open the gap exactly as the
> last twelve did, and no doc's inclusion rule will be wrong when it happens. **Coverage is 898/898 by
> accident of effort, not by construction.** One caveat learned since, from §1.2: §6's matcher is *not*
> a sufficient core for that script — it credits mention as ownership and under-reported `Render` by four
> rows. The invariant must read table rows or a manifest.

---

## 3. Mechanisms nobody explained

### 3.1 The plaintext-`.lua` loading path — **real, byte-confirmed, and undocumented**

The brief asks whether DLC plaintext implies a path a modder could use. **A plaintext path exists, but it
is not the DLC's and no doc describes it.** `FUN_006fa920` @ `0x006fa920` — called from `FUN_006faad0` as
`FUN_006fa920("Scripts\\Modules",0,1)`, transcribed in [04 §4](04-vm-lifecycle-and-script-objects.md) and
then **never explained there** — is a directory scanner with an extension filter:

```c
if (((*(byte *)(param_1 + 0x15c14) & 4) != 0) && ((char)param_3 == '\0')) {
    FUN_00706200(1);      // pack mode -> the autorun pass doc 04 s5 documents
    return;
}
// ...else: enumerate the directory, and per entry:
if ((((DAT_0142d305 != '\0') && (DAT_0142d304 == '\0')) ||
    (cVar1 = FUN_00db4be0(&DAT_00fdb8f8), cVar1 != '\0')) &&        // DAT_00fdb8f8 = ".lua"
   (((DAT_0142d305 == '\0' || (DAT_0142d304 != '\0')) ||
    (cVar1 = FUN_00db4be0(".luac"), cVar1 != '\0'))))
```

`DAT_00fdb8f8` reads `2e 6c 75 61 00` = **`".lua"`**, read from retail `Saboteur.exe` at file offset
`0xbdaaf8` (`.rdata` VA `0xf71000` → raw `0xb70200`, the mapping [04 §5](04-vm-lifecycle-and-script-objects.md)
established). So `FUN_006fa920` is a **pack-or-loose selector for the module autorun pass**, and its loose
branch accepts **plaintext `.lua` from disk**. `DAT_0142d304` / `DAT_0142d305` select `.lua` vs `.luac`;
both are **read at exactly two sites in the whole 54 MB decomp and written at none**, so they are BSS
zeros in retail, and with both zero the filter reduces to `endswith(".lua")` — plaintext.

The sibling `FUN_006fa8a0` @ `0x006fa8a0` is the same idea for a single file:

```c
if ((*(byte *)(param_1 + 0x15c14) & 4) != 0) {
    FUN_00db4a60(&DAT_00fdbdfc);        // DAT_00fdbdfc = "c"  -> ".lua" + "c" = ".luac"
}
FUN_006fa430(0,local_104,&local_110,&local_10c,1,0,0,0);
```

`DAT_00fdbdfc` = `63 00` = `"c"`, read from the exe — the same `.lua`→`.luac` rewrite
[04 §5](04-vm-lifecycle-and-script-objects.md) found in `FUN_00706190`, but on a *second, independent*
path. **Confidence: confirmed** (bodies read; both strings read from retail bytes).

**And this is a third script-loading path the series does not mention at all.** `FUN_006fa8a0`'s other
caller is `FUN_00834100` @ `0x00834100`, which builds:

```c
FUN_00db4610(&local_118,"Scripts\\ScriptControllers\\%s.lua");
... FUN_006fa8a0();
```

So **ScriptControllers are loaded by name-formatting into `Scripts\ScriptControllers\%s.lua`**, then
pack-or-loose resolved. [04 §7](04-vm-lifecycle-and-script-objects.md) documents ScriptControllers'
`OnEnter`/`OnExit` dispatch in detail and **never says how the controller's chunk is loaded**. The three
script-loading paths are therefore:

| Path | Entry | Documented? |
|---|---|---|
| `require(...)` → `package.loaders[2]` → pack BST | `FUN_00706190` | ✅ [04 §5](04-vm-lifecycle-and-script-objects.md), 321/321 |
| Module autorun (`Scripts\Modules`), pack **or loose `.lua` dir scan** | `FUN_006fa920` | ❌ transcribed, unexplained |
| ScriptController by name (`Scripts\ScriptControllers\%s.lua`), pack or loose | `FUN_00834100` → `FUN_006fa8a0` | ❌ absent from the series |

**Next step, and it is cheap:** rename `LuaScripts.luap`, drop
`Scripts\ScriptControllers\Null.lua` as plaintext next to the exe, and breakpoint `FUN_006fa430`
@ `0x006fa430`. If it loads, **The Saboteur has a full plaintext-script mode** — which is the single most
useful fact this project could hand a modder, and it is one x32dbg session away. The MCP tooling is
already in this environment. See §5.1.

### 3.2 The DLC plaintext question — doc 04's answer is a **non-sequitur**

[04 §4](04-vm-lifecycle-and-script-objects.md) states:

> The `.luap` pack is **optional by design**. If `LuaScripts.luap` fails to open, the engine *removes* its
> own `package.loaders` entry and lets stock Lua resolve via `package.path = "Scripts\?.lua"` from disk.
> **This is exactly why `DLC/01/Scripts/*.lua` ships as plaintext source** rather than compiled chunks.

The mechanism is correctly read; **the conclusion does not follow, and is false.**

1. `C:\GOG Games\The Saboteur\LuaScripts.luap` **is present** on the retail install (verified on disk).
   `FUN_00706670("LuaScripts.luap", 0)` therefore succeeds, `cVar2 != 0`, and the
   `table.remove(package.loaders, 2)` branch **never executes**. The fallback doc 04 invokes is dead code
   in every shipped configuration.
2. Even if the fallback fired, `package.path` is `"Scripts\?.lua"` — relative to the game root. **There is
   no `Scripts\` directory at the retail root** (verified: the only 4 loose `.lua` files on the install are
   under `DLC\01\Scripts\`). `DLC\01\Scripts` is on no search path the series has identified.

So **how `DLC/01/Scripts/*.lua` is loaded remains genuinely open**, and the series believes it is solved.

I disproved the obvious candidate: `DLC\01\dlcinfo.ini` contains a **commented-out `//autorunlua=""`** key —
exactly the hook one would want. But the string **`autorunlua` does not appear anywhere in
`Saboteur.exe`** (byte search of the whole image: not found), and the shipped ini parser at
`FUN_?` (the `_sprintf(local_10c,"%s\\dlcinfo.ini",...)` site, decomp line ~823796) only `__strnicmp`s
**`megapack`**, **`dlclevel`**, **`saveddlclevel`**. The key is dead in retail. Note the ini also
misspells its own parser's key (`savedlclevel` in the file vs `saveddlclevel` in the binary) — the file is
lightly-maintained boilerplate.

**Working hypothesis (inferred, not proven):** the 4 DLC `.lua` files are **unshipped/dead**, left in the
DLC payload by the cook, and their live counterparts are compiled into `dlc01mega0.megapack` or into
`LuaScripts.luap` itself. **Next step:** compute
`pandemic_hash("d:\Scripts\DLC_InteriorManager.luac")` with [04's §Reproducing](04-vm-lifecycle-and-script-objects.md)
snippet and look it up in retail `LuaScripts.luap`. A hit proves the DLC ships the same module twice —
once compiled in the pack (live) and once as plaintext (vestigial) — and closes the question in minutes,
with no debugger. **This is the cheapest open item in the series.**

### 3.3 `WSTrain::` — **already answered; the brief's premise is wrong**

The brief lists the 31 `WSTrain::`-prefixed entries as a candidate "second registration shape" nobody
owned. [13](13-family-vehicle-train-plane.md) owns it and refutes it, well: the RTTI descriptors partition
`898 = 867 + 31` on `@@YA` (free function) vs `@@SA` (static member of `WSTrain`); the 31 are ordinary
`LuaGlueFunctor0`/`adapter` rows in the same registry, and `WSTrain::` is a demangling artifact. I
re-checked the tsv: all 31 `Train` rows carry `cpp_class=WSTrain` and standard `family`/`shape`. **No gap
here.** Recording it so the next critic does not re-open it.

### 3.4 `LuaHook_Require` / module loading — covered, but with a wrong evidence attribution

[04 §5](04-vm-lifecycle-and-script-objects.md) solves `require` convincingly (321/321 forward, 26/26
reverse). I re-read `FUN_006f8a90` and `FUN_006faad0` and confirm the transcriptions are exact. One
supporting claim is wrong, and it matters because it is the latch the whole loader path is gated on.
[04 §3](04-vm-lifecycle-and-script-objects.md)'s field table says:

> `+0x15c14` | flag byte — bit1 = initialised, bit2 = `.luap` pack loaded | *Evidence:* `FUN_006faad0`

`FUN_006faad0` **never sets** the `4` bit; it only clears it (`& 0xfb`) on pack-open failure and sets the
`2` bit (`| 2`). The set is in the manager constructor, `FUN_006f96e7` @ `0x006f96e7`:

```c
*(undefined1 *)(param_1 + 0x15c00) = 0;
*(byte *)(param_1 + 0x15c14) = *(byte *)(param_1 + 0x15c14) & 0xfc | 4;
```

Grepping the whole decomp: `0x15c14` has **12 reference sites**, and `0x006f96e7` is the **only** one that
sets bit 2. So the bit is set **at construction, unconditionally, before any pack is opened** — it cannot
mean "`.luap` pack loaded". It means "**expect the pack**", initialised true and cleared on failure.

This matters: `FUN_006f8a90`'s require-hook install is gated on `(flags & 4) != 0`, and it runs **before**
`FUN_00706670("LuaScripts.luap", 0)` in `FUN_006faad0`. Had doc 04's reading been right, the gate would be
false on first init and the hook would never install — contradicting its own 26/26 result. The ctor is what
makes the sequence coherent. Doc 04's *conclusion* survives intact; its *evidence column* is wrong and its
*semantics* for the bit are wrong. **Fix:** correct the row to cite `FUN_006f96e7 @0x006f96e7` and rename
the bit "pack expected".

### 3.5 Save/load of live script state — covered, and the docs agree

Adversarially checked, and I found no gap. [03 §7](03-handle-and-object-model.md) ("Handles cannot survive
a save"), [00 §4](00-seam-overview.md) and [04 §10](04-vm-lifecycle-and-script-objects.md) (reload builds a
fresh `lua_State`, so self tables are discarded wholesale) are consistent, and
[21](21-family-utility-saveload-object.md) documents all 13 `SaveLoad.*` bindings as the survival
mechanism. The story closes: handles die, self tables die, `SaveLoad.*` is the only survivor. **No action.**

### 3.6 The absent `LuaMissions.luap` — noted, never chased

`FUN_00706670("LuaMissions.luap", 1)` is in `FUN_006faad0` and retail ships no such file (verified).
[04 §3](04-vm-lifecycle-and-script-objects.md) proposes it as the candidate for VM slot 1 and
[04 Q6](04-vm-lifecycle-and-script-objects.md#open-questions) proposes it as the home of the orphan
handlers `OnMeleeAttack`/`OnGrabbedAttack`/`OnGrabbedEnter`. Both are plausible; neither is tested, and
they are in tension with [04 §3](04-vm-lifecycle-and-script-objects.md)'s own **confirmed** finding that
only slot 0 is ever written and `lua_newstate` has one live caller. If `LuaMissions.luap` were a slot-1
bank, something would have to write slot 1; nothing does. **The slot-1 hypothesis is probably wrong**, and
the second-argument difference (`0` for `LuaScripts`, `1` for `LuaMissions`) is more likely the same
`+0x14` autorun-filter flag that [04 §5](04-vm-lifecycle-and-script-objects.md) already decoded for
`FUN_00706200(1)`. **Next step:** read `FUN_00706670` @ `0x00706670` to the end and pin its second
parameter — [04 Q2](04-vm-lifecycle-and-script-objects.md#open-questions) already flags the signature as
unrecovered (`__thiscall` with `ECX` dropped). Cheap, static, and it retires two open questions at once.

### 3.7 The `+0x00` preimage — solved in 04; ~~still marked OPEN in the format doc~~ **now propagated ✅**

> **Closed 2026-07-16.** The propagation below has been done, after an independent re-test against retail
> `LuaScripts.luap`: **321/321** descriptors reproduce `+0x00` as
> `pandemic_hash("d:\" + <Scripts-relative> + ".luac")`, and 04's worked example hashes to `0xda8b14f5`
> exactly (control: the documented `+0x04 = pandemic_hash(basename)` also re-confirms 321/321). The three
> stale lines in [`lua_scripts.md`](../formats/lua_scripts.md) are patched, "hash-map key" is corrected to
> the red-black-tree find, and §4.1's contradiction is resolved. **This finding is now third-party
> confirmed, not single-sourced** — the strongest-evidenced claim in the series.
>
> Worth recording *why* the original sweep missed it: it did try `Scripts`-relative paths, but only with
> the `.lua` the debug path carries. The engine substitutes `.luac` at `require` time, so the preimage is
> neither the shipped path nor the shipped extension.

[04 §5](04-vm-lifecycle-and-script-objects.md) closes it at byte level: `+0x00` is
`pandemic_hash("d:\" + <Scripts-relative path> + ".luac")`, 321/321. I re-read the three `.rdata`
constants out of retail `Saboteur.exe` and they reproduce exactly (`0xfdc408` = `64 3a 5c 00` = `"d:\"`,
`0xfdc40c` = `".lua"`, `0xfdc414` = `"c"`). The work is sound.

**But the correction never propagated.** [`docs/formats/lua_scripts.md`](../formats/lua_scripts.md) still
reads, today:

- line 37: `` `+0x00` | u32 | **name hash** — hash-map key … **Preimage still OPEN — see below** ``
- line 69: `## Open: what does `+0x00` hash?`
- line 119: `` `+0x00` preimage: ❌ open (non-blocking). ``

Doc 04 says solved + **BST**; the format doc says open + **hash-map**. Both are in the repo. A reader
starting from `docs/formats/` — the natural entry point for a tools author — gets the stale answer.
**Next step:** patch those three lines to cite [04 §5](04-vm-lifecycle-and-script-objects.md), correct
"hash-map key" → "BST key (`FUN_00706910`)", and move the preimage to solved. Ten minutes; it is the
highest value-per-effort item in this document.

---

## 4. Contradictions across the docs

[00 §8](00-seam-overview.md) already resolves five inter-doc contradictions, and does it well — that work
is not repeated here. These are the ones it missed, ranked by consequence.

### 4.1 `lua_scripts.md` vs `04 §5` — solved-vs-open, unpropagated → **RESOLVED ✅**

Covered in §3.7, and now fixed: the format doc reads "solved", cites 04, and the preimage was
independently re-derived 321/321 before the edit landed. Was the only contradiction in the set where a
reader was actively misled by a live document.

### 4.2 `04 §4`'s DLC conclusion vs the retail install

Covered in §3.2. Doc 04 asserts the plaintext fallback explains DLC; the fallback requires
`LuaScripts.luap` to be absent, and it is present. **Cited:** [04 §4](04-vm-lifecycle-and-script-objects.md)
vs `C:\GOG Games\The Saboteur\LuaScripts.luap`.

### 4.3 `04 §3`'s `+0x15c14` evidence vs `FUN_006f96e7`

Covered in §3.4. **Cited:** [04 §3](04-vm-lifecycle-and-script-objects.md) field table vs decomp
`FUN_006f96e7 @0x006f96e7`.

### 4.4 `00 §7.1` is marked **confirmed** but rests on a dropped `ECX`

[00 §7.1](00-seam-overview.md) presents the registry drain as closed, **Confidence: confirmed**, with:

```c
for (node in list at registry[+0x04]) { ... }
thunk_FUN_015fd2d0(L, registry + 0x14, arr, 0);   // luaL_register(L, "<TableName>", regs, 0)
```

and describes `FUN_006f8a90` as "one loop over `manager+0x04` registries calling `FUN_006f6690(registry, L)`".
The actual decompiled body is:

```c
iVar2 = 0;
if (0 < *(int *)(param_1 + 4)) {
  do {
    FUN_006f6690(*param_2);        // <- only ONE argument, and it is the lua_State*
    iVar2 = iVar2 + 1;
  } while (iVar2 < *(int *)(param_1 + 4));
}
```

**The loop body never advances a registry pointer and never passes a registry.** The call is invariant
across iterations as decompiled. The `(registry, L)` signature is an *inference* that `ECX` carries the
registry and Ghidra dropped it — the same recovery failure [04 Q4](04-vm-lifecycle-and-script-objects.md#open-questions)
explicitly warns about for three sibling functions ("all three are rendered `__thiscall` with one fewer
parameter than their call sites pass; `ECX` is dropped"). The inference is very likely right — but doc 00
is the document that scolds the others for over-claiming ([00 §8.1](00-seam-overview.md), [00 §8.3](00-seam-overview.md)),
and it graded its own headline result **confirmed** on evidence its own sibling classifies as unreliable.
**Fix:** downgrade 7.1 to **inferred**, or disassemble `0x006f8a90` in retail and show the `mov ecx, …`
that Ghidra ate. The latter is ~5 minutes with the capstone harness
[19](19-family-ui-hud-tutorial.md) already built, and would make it genuinely confirmed.

### 4.5 `00 §8.1`'s return contract asserts 898 rows; the tsv only determines 881

[00 §8.1](00-seam-overview.md) is the series' most-cited resolution: *"722 of 898 bindings
(`LuaGlueFunctor0`) always claim exactly 1 result … 176 (`LuaGlueFunctor0R`) return their own count."*
The `family`/`shape` counts reproduce exactly against the tsv (640+82=722, 172+4=176 — verified). But
`nresults` in that same authoritative file is **blank on 17 rows**:

```
nresults: '1' -> 709,  'eax' -> 172,  '' -> 17      (total 898)
```

All 17 are `shape=inlined` (15 `LuaGlueFunctor0`, 2 `LuaGlueFunctor0R`) — e.g. `SaveLoad.LoadCheckpoint`
`0x00741e90`, `Util.ClearDisguiseCallback` `0x0075d1f0`, `Render.ClearGlobalWTF` `0x007400f0`,
`Vehicle.CanPassengerGetOut` `0x00763fa0`. This is not a contradiction of fact but of *epistemics*, and it
lands on the weakest spot: an `inlined` thunk has no separate adapter to read `mov eax,1` from — which is
presumably exactly why the dumper left them blank. So the 15 rows where the "always 1" rule is
*least* directly observable are the 15 the doc's own tool declined to call. **Fix:** either disassemble
the 17 and fill the column, or have [00 §8.1](00-seam-overview.md) say "722 by shape-rule, of which 707
are directly observed and 15 inferred from the rule". **No doc in the series mentions the blank column.**

### 4.6 Superseded rows still readable as fact

[00 §8.3](00-seam-overview.md) rules that [06 §3](06-lua-side-wrapper-layer.md)'s class counts and
[05 §6](05-engine-to-lua-callbacks.md)'s "table open" rows "should be treated as superseded". They still
sit in those documents un-annotated — e.g. [05](05-engine-to-lua-callbacks.md) lines 349/350/353 still say
`TrainRegisterCreationCallback` *(table open)* when the tsv says `Train.TrainRegisterCreationCallback`.
A reader who opens 05 directly has no signal. **Fix:** a one-line superseded-by banner at the top of
[05 §6](05-engine-to-lua-callbacks.md) and [06 §3](06-lua-side-wrapper-layer.md). Cheap, and it is the
same propagation failure as §3.7.

---

## 5. The highest-value next investigation

### 5.1 First: prove or kill the plaintext-script mode (§3.1)

Nothing else in the open list changes what a person can *do* with the game. Every other item refines a
description; this one either hands the modding community a supported, no-tooling script path or removes a
false hope. It is also nearly free — the mechanism is already read at byte level (§3.1), only the
reachability is unverified.

**Protocol** (one x32dbg session; the MCP tooling is in this environment):

1. Breakpoint `FUN_006fa920` @ `0x006fa920` and `FUN_006fa430` @ `0x006fa430`. Boot. Confirm the retail
   path early-outs at the `(flags & 4)` gate into `FUN_00706200(1)` — i.e. pack mode, dir scan skipped.
2. Rename `LuaScripts.luap`. Re-boot. Confirm `FUN_006faad0` takes the `cVar2 == '\0'` branch, executes
   `table.remove(package.loaders, 2)`, and that `FUN_006fa920` now falls through to the dir scan.
3. Create `Scripts\Modules\Test.lua` (plaintext) at the game root with a `print("hello")`. Watch for
   `FUN_006fa430`. `print` is the engine closure at `LAB_006f8220`
   ([04 §4](04-vm-lifecycle-and-script-objects.md)) so output is observable.
4. Separately, drop plaintext `Scripts\ScriptControllers\Null.lua` and breakpoint `FUN_006fa8a0`
   @ `0x006fa8a0` — this tests the third path (§3.1) independently of the module autorun.
5. If the dir scan runs but rejects `.lua`, flip `DAT_0142d305` / `DAT_0142d304` in memory and re-test:
   that pins their polarity, which no static read can (both are written nowhere).

**Outcome either way is publishable.** Success → a documented plaintext modding path, and `docs/formats/lua_scripts.md`
gains a "you may not need this container at all" section. Failure → the two loose-file branches are dev-only
dead code, which is itself the answer to the DLC question and retires §3.2.

### 5.2 Then, in cost order (all cheap, all static)

| # | Item | Cost | Retires |
|---|---|---|---|
| 1 | Patch the three stale lines in [`formats/lua_scripts.md`](../formats/lua_scripts.md) (§3.7) | 10 min, no analysis | The only actively-misleading contradiction |
| 2 | Hash `"d:\Scripts\DLC_InteriorManager.luac"` against `LuaScripts.luap` (§3.2) | 5 min, script only | The DLC plaintext question |
| 3 | Read `FUN_00706670` @ `0x00706670` to the end (§3.6) | 30 min, static | [04 Q2](04-vm-lifecycle-and-script-objects.md#open-questions) + the `LuaMissions` slot-1 hypothesis |
| 4 | Disassemble `0x006f8a90`'s `mov ecx` (§4.4) | 5 min, capstone | Makes [00 §7.1](00-seam-overview.md) honestly *confirmed* |
| 5 | Fill the 17 blank `nresults` (§4.5) | 1 hr, capstone | The last hole in the return contract |
| 6 | `tools/check_seam_coverage.py` in CI (§2) | 1 hr | The entire class of gap this doc found — **still open, and now the successor to item 7** |
| 7 | ~~Write `22-family-…-points.md` (§1.1) and `23-family-render-weather-fx.md` (§1.2)~~ | ~~2 docs~~ | ~~The 86 orphans~~ — **done 2026-07-16 ✅** (both written, both verified; plus the `Sensory`/`Damage`/`Freeplay` adoptions into 11/16/20) |

**Deliberately ranked below the above:** the 2008 pre-release build
([00 §9.1](00-seam-overview.md)'s top item). It is the right way to settle whether the 24 unresolved
corpus calls are cut dev bindings, but it requires acquiring a pre-release build that the project's
tracked "2008 build diff" lead records as **not yet downloaded**, and it answers a question about *dev
history*. Items 1–5 answer questions about *the shipped
game*, cost under two hours combined, and use only what is already on disk. Do them first.

---

## 6. Reproducing the orphan census

Unchanged since the census was taken, except that the doc glob now spans `10–23` and the assertion is
**0**. Both assertions below hold as of 2026-07-16.

```python
import re, os, glob, csv
ROOT = r"C:\Users\Shadow\Desktop\notes-on-reversing-the-sabetour"
DOCS = os.path.join(ROOT, "docs", "sab-engine-lua-seam")

rows = list(csv.DictReader(open(os.path.join(ROOT, "data", "lua_registration_map.tsv"),
                                encoding="utf-8"), delimiter="\t"))
fam  = [d for d in sorted(glob.glob(os.path.join(DOCS, "*.md")))
        if re.match(r"^(1[0-9]|2[0-3])-", os.path.basename(d))]   # was 1[0-9]|2[01]
txt  = {d: open(d, encoding="utf-8").read() for d in fam}
tok  = {d: set(re.findall(r"[A-Za-z_][A-Za-z0-9_]*", txt[d])) for d in fam}

def covered(r, d):
    # STRICT. A bare lua_name match is rejected: 'Set', 'Create', 'Delete',
    # 'Enable' are real lua_names and appear in every doc in the series.
    return (r["cpp_symbol"] in tok[d]
            or f'{r["table"]}.{r["lua_name"]}' in txt[d]
            or (r["impl_va"] and r["impl_va"].lower() in txt[d].lower()))

orphans = [r for r in rows if not any(covered(r, d) for d in fam)]
assert len(rows) == 898
assert len(orphans) == 0           # was 86 over docs 10-21, before 22/23 and the
                                   # Sensory/Damage/Freeplay adoptions landed.
                                   # Loose bare-name matching scored that 86 as 77.
for r in sorted(orphans, key=lambda r: (r["table"], r["lua_name"])):
    print(f'{r["table"]}.{r["lua_name"]:34s} {r["cpp_symbol"]:42s} '
          f'0x{r["impl_va"]}  {r["family"]}/{r["shape"]}')
```

**Two limits on this script, both load-bearing for anyone promoting it to CI (§2):**

1. **It measures mention, not ownership.** Its qualified-name rule credited four `Render` rows to docs
   that name them only to *disclaim* them (§1.2). It under-reports. A real invariant must read each doc's
   table rows or a declared manifest.
2. **Its 0 is not the same 0 as the README's.** This script says 0 orphans; the README's `Coverage` table
   says 0 rows lack a family-doc **table entry**. The two measures disagreed before (86 vs 93) and agree
   now only because coverage is total. Do not treat either as a proxy for the other.

## Sources

Function bodies were read from
`C:/Users/Shadow/Desktop/notes-on-the-released-game/output/_ghidra_saboteur/saboteur_all_functions_decomp.txt`
(36,935 functions; not in this repo). `.rdata` constants (`DAT_00fdb8f8` = `".lua"`, `DAT_00fdbdfc` =
`"c"`, `DAT_00fdc408` = `"d:\"`) were read directly from `C:\GOG Games\The Saboteur\Saboteur.exe` using the
`.rdata` VA `0xf71000` → raw `0xb70200` mapping established in
[04 §5](04-vm-lifecycle-and-script-objects.md). Install-layout claims (`LuaScripts.luap` present, no root
`Scripts\`, 4 loose DLC `.lua`, `dlcinfo.ini` contents) were verified against
`C:\GOG Games\The Saboteur`. Names, VAs, `family`/`shape`/`nresults` are from
[`data/lua_registration_map.tsv`](../../data/lua_registration_map.tsv). Corpus citations are file:line into
[`docs/saboteur-luacd/src`](../saboteur-luacd/src) and were re-read at the quoted line. No fact here is
carried over from Mercenaries 2 work.
