# Render: weather, FX lifetime, colour and light

> **Verified:** every row's body read at its `impl_va`; the three `shape=inlined` bodies and six
> decomp-suspect bodies disassembled directly from `C:\GOG Games\The Saboteur\Saboteur.exe` (pefile +
> capstone, image base `0x400000`) per [19](19-family-ui-hud-tutorial.md)'s method. All corpus counts
> produced by grepping [`docs/saboteur-luacd/src`](../saboteur-luacd/src); direct calls and bare table
> references counted separately and never merged.
>
> **Adversarial re-verify:** all 19 `impl_va`s re-checked against the tsv and the exe (all correct); the
> 42-row partition re-derived by `awk` and all six claimant-doc line citations re-opened (all correct);
> all 19 corpus counts and all 13 quoted `file:line`s re-grepped and re-read (all correct). Four
> corrections: the `EndFX` mechanism cited the **bone** filter (`test esi,esi` @`0x73e486`) as the name
> filter — the name hash is `edi`, tested at `0x73e498`; the conclusion is unchanged but the citation was
> wrong. Open question 4 is **closed** — `FUN_00db7e10` demonstrably null-checks (@`0x00db7e14`), so the
> bug cannot fault. The rain callees "differ in exactly one instruction" was false — they differ in four.
> The weather-globals table was missing `[0x0142e648]` and the callees' string/ambience side effect.

`Render` is the seam's worst-partitioned table. Its 42 rows were sliced across seven documents by
gameplay noun, and the rows that matched no noun matched no family. That residue is not marginal
content — it is the rain, the lightning, the fade-to-black and the colour machinery that *is* The
Saboteur's look. This doc closes it.

## Partition, and a correction to the ledger

42 rows carry `table=Render` in [`data/lua_registration_map.tsv`](../../data/lua_registration_map.tsv).
Auditing every one against the seven claimant docs produces a different answer than
[99-gaps-and-next-steps.md](99-gaps-and-next-steps.md) records:

| Claimant | Rows genuinely carrying a table row | Ledger says |
|---|---|---|
| [12](12-family-suspicion-wtf-alarm.md) | **16** (`SetGlobalWTF`, `ClearGlobalWTF`, 14 × `WTF*`) — doc 12 lines 119–134 | 17 |
| [19](19-family-ui-hud-tutorial.md) | 2 (`PrintMessage`, `PrintMissionText`) | screen-print/filter |
| [15](15-family-mission-objective-task.md) | 2 (`ShowMissionComplete`, `PrintMissionText` — shared with 19) | `ShowMissionComplete` |
| [16](16-family-world-zone-interior.md) | 2 (`SetWaterLevel`, `ResetWaterLevel`) | ✓ |
| [18](18-family-cinematics-camera-face.md) | 1 (`CameraShakeExplosion`) | ✓ |
| [10](10-family-actor-human.md) | 1 (`EnableHumanHalos`) | ✓ |
| [17](17-family-sound-voice-conversation.md) | **0** | `PrintDialogue` |

Two defects, both verifiable in the claimant docs' own text:

1. **Doc 12 covers 16 `Render` rows, not 17.** Its table runs `SetGlobalWTF` … `WTFFinishTransition`
   (16 rows), and it *explicitly excludes* `Render.HeatShimmerFilter` at line 31.
2. **Four rows are credited to docs that disclaim them in writing.** Doc 17 line 41 lists
   `Render.PrintDialogue` under "Deliberately **excluded**" and hands it to "the HUD/Render families".
   Doc 19 line 64 excludes `Render.FadeScreen` ("screen/render family; no text or HUD widget") and line
   59 excludes `Render.DrunkEffectFilter` / `Render.HeatShimmerFilter`. Nobody picked them up.

The residue is therefore **19 rows, not 15** — the 15 briefed, plus `PrintDialogue`, `FadeScreen`,
`DrunkEffectFilter` and `HeatShimmerFilter`, which were orphaned by an exclusion nobody honoured. All 19
are covered below. Accounting closes exactly: 16 (doc 12) + 2 (19) + 1 (15, `ShowMissionComplete`) +
2 (16) + 1 (18) + 1 (10) + 19 (here) = 42, with `PrintMissionText` counted once to doc 19.

## The bindings

| Binding | VA | Shape | Signature | Confidence | Evidence |
|---|---|---|---|---|---|
| `Render.Rain` | `0x0073d410` | adapter | `(fOn:number, fSeconds:number) -> ()` — **arg 1 is a boolean in disguise; its magnitude is discarded** | confirmed | exe; `fldz; fcomp [esp+8]; fnstsw ax; test ah,5; jp` @`0x73d46f`–`0x73d481` → `0x7679d0` (on) / `0x767a20` (off). Both callees hardcode the target. 24 direct calls / 8 bare refs, 11 files |
| `Render.EnableAmbientRain` | `0x0073d3a0` | adapter | `(bEnable:boolean) -> ()` → `DAT_011b6d70`; **`false` also force-clears lightning** | confirmed | body; `false` path writes `_DAT_011f1cfc=0`, `_DAT_01111224=DAT_00f7d3bc`, `*DAT_0147dbc8=0`. 2 direct calls ([`Paris_3_Mission_1.lua:397`](../saboteur-luacd/src/Missions/Paris_3_Mission_1.lua), [`SabTaskMission.lua:496`](../saboteur-luacd/src/Modules/SabTaskMission.lua)) |
| `Render.EnableLightning` | `0x0073dbd0` | adapter | `(bEnable:boolean) -> ()` → `*DAT_0147dbc8`, then `FUN_009698f0()` | confirmed | body; `FUN_006f7120(1)` guard → `FUN_006f6e60(1)`. 14 direct calls / 1 bare ref, 9 files |
| `Render.EnableLightningFlash` | `0x0073de50` | adapter | `(nSet:number, bEnable:boolean) -> ()` → `FUN_00969740(nSet, b)` | confirmed (marshalling); *open* (what `nSet` indexes) | body; `FUN_00969700(nSet)` validates the index before the write. **Zero corpus calls** |
| `Render.SetLightningFlashParams` | `0x0073dc40` | adapter | **13 args**: `(nSet:number, f2..f10:number, n11:number, b12:boolean, b13:boolean) -> ()` | confirmed (marshalling); *open* (meaning of `f2..f10`) | body; guards `FUN_006f7140(1..0xb)` then `FUN_006f7120(0xc)`, `FUN_006f7120(0xd)` — **hex indices: `0xb`=11, `0xd`=13** → `FUN_00969770` with 13 params. **Zero corpus calls** |
| `Render.StartFX` | `0x0073e1a0` | adapter | `(hTarget:handle, sFXName:string [, sBone:string|nil]) -> ()` | confirmed | exe; arity `1 < argc < 4`; `FUN_006f7a80(2)` @`0x73e279`, `FUN_006f7a80(3)` @`0x73e29e`. 36 direct calls, 11 files |
| `Render.EndFX` | `0x0073e340` | adapter | `(hTarget:handle, sFXName:string [, sBone:string|nil]) -> ()` — **reads the name from slot 1; see "the EndFX slot bug"** | confirmed | exe; type-checks slot 2 (`FUN_006f7160(2)` @`0x73e3b7`) but fetches `FUN_006f7a80(1)` @`0x73e419` — slot 1 is lightuserdata → always NULL. 8 direct calls, 5 files |
| `Render.SetFXTime` | `0x0073e4d0` | adapter | `(hTarget:handle, fTime:number)` / variadic to 4 — **SHIPPED STUB: validates everything, then discards it** | confirmed | exe; `fstp st(0)` @`0x73e630` discards the time; two `FUN_006f7a80` results discarded; `ret` @`0x73e651`. 3 direct calls, all 2-arg |
| `Render.FadeTo` | `0x0073e660` | adapter | `(nR, nG, nB, nA:number, fSeconds:number) -> ()` — **exactly 5 args or no-op** | confirmed | body; `if (argc == 5)` then loop `FUN_006f7140(1..5)`; packs `((a<<8\|b)<<8\|g)<<8\|r` → `FUN_009bc170(packed, fSeconds)`. 46 direct / 2 bare, 19 files |
| `Render.FadeScreen` | `0x0073e730` | adapter | `(bFade:boolean) -> ()` — **arg 2 ignored** | confirmed | exe; `FUN_006f7120(1)` @`0x73e771` → `FUN_006f6e60(1)` → `[0x12e85c4]->FUN_00652690(b, 1)`; `false` also clears `(DAT_014a9d78+0x15c) & 0xfe`. 60 direct / 7 bare, 32 files |
| `Render.DrunkEffectFilter` | `0x0073d340` | adapter | `(fAmount:number) -> ()` → `*(float*)(DAT_0143d02c + 0x28)` | confirmed | exe; `fstp [esp]; fld [esp]; mov ecx,[0x143d02c]; fstp [ecx+0x28]` @`0x73d383`–`0x73d38f`. **Zero corpus calls** |
| `Render.HeatShimmerFilter` | `0x0073d2d0` | adapter | `(f1, f2, f3, f4:number) -> ()` — **SHIPPED STUB: fetches 4 floats and discards all 4** | confirmed | exe; four × `call 0x6f7950; fstp st(0)` @`0x73d310`–`0x73d336`, then `pop esi; ret` @`0x73d339`. 6 direct calls, 4 files, all no-ops |
| `Render.StartHighlight` | `0x0073e8c0` | adapter | `(hTarget:handle, sBlueprint:string) -> ()` | confirmed | body; `FUN_006f71a0(1)` + `FUN_006f7160(2)` → object vtable `+0x16c` → highlight iface `+0xc`. 1 direct call ([`Paris_2_Mission_5.lua:954`](../saboteur-luacd/src/Missions/Paris_2_Mission_5.lua)) |
| `Render.StopHighlight` | `0x0073e980` | adapter | `(hTarget:handle) -> ()` | confirmed | body; same `+0x16c` iface, method `+0x8`. **0 direct calls; 3 bare refs**, all event-table entries in `Paris_2_Mission_5.lua` (911, 1492, 2682) |
| `Render.ToggleLights` | `0x0073ea80` | adapter | `(nLightID:number, bOn:boolean) -> ()` — **silently drops negative IDs** | confirmed | body; `FUN_006f7990(1)`, `FUN_006f6e60(2)`, guard `if (-1 < nLightID)` → `FUN_007e6130`. 18 direct calls, 3 files |
| `Render.PrintDialogue` | `0x0073e000` | adapter | `(vTarget:handle\|string, sText:string, fSeconds:number) -> ()` | confirmed | body; handle-or-name union (`FUN_006f71a0(1)` else `FUN_006f7160(1)`→`FUN_009a0010`), generation check inline, then `FUN_0083cac0(sText, fSeconds)`. 25 direct calls, 13 files |
| `Render.PauseUVScrolling` | `0x0073fec0` | **inlined** | `() -> ()` → `[0x15cffe8]+0xab0 = 0` | confirmed | **exe only** (absent from decomp); whole body, 4 instructions: `mov eax,[0x15cffe8]; mov byte [eax+0xab0],0; mov eax,1; ret`. **Zero corpus calls** |
| `Render.ResumeUVScrolling` | `0x0073ff10` | **inlined** | `() -> ()` → `[0x15cffe8]+0xab0 = 1` | confirmed | **exe only**; `mov ecx,[0x15cffe8]; mov eax,1; mov byte [ecx+0xab0],al; ret` — writes `al` *because* `eax` is already the return value. **Zero corpus calls** |
| `Render.ResetUVScrolling` | `0x0073fe70` | **inlined** | `() -> ()` → `[0x15cffe8]+0xaac = 0.0f` | confirmed | **exe only**; `fldz; mov eax,[0x15cffe8]; fstp dword [eax+0xaac]; mov eax,1; ret`. **Not** the inverse of Pause — different field. **Zero corpus calls** |

**Coverage: 19 of 19 located, 19 confirmed, 0 inferred, 0 not found.** Three bodies exist only in the
retail exe and were recovered there; two are shipped stubs; one carries a live argument-slot bug.

## How the weather subsystem actually works

Five globals carry all of it, and reading the bodies together shows they are one machine, not five
independent switches:

| Global | Role | Written by |
|---|---|---|
| `[0x011f1cfc]` | target wetness, `0.0`–`1.0` | `FUN_007679d0` (→`1.0`), `FUN_00767a20` (→`0.0`), `EnableAmbientRain(false)` (→`0`) |
| `[0x01111224]` | wetness transition rate | both rain callees (`= 1/fSeconds`), `EnableAmbientRain(false)` (`= DAT_00f7d3bc`, the default) |
| `*[0x0147dbc8]` | lightning enabled | `EnableLightning`, `EnableAmbientRain(false)` (→`0`) |
| `[0x011b6d70]` | ambient rain enabled | `EnableAmbientRain` |
| `[0x0142e648]` | rain-on flag *(role inferred from the write sites)* | `FUN_007679d0` (→`1`, @`0x767a08`), `FUN_00767a20` (→`0`, @`0x767a58`) |

The rain callees carry one further side effect the fade/lightning rows do not: each interns a distinct
string constant (`0xfe9780` on, `0xfe978c` off) and passes its hash to `FUN_0083a2f0` on the object
returned by `FUN_008a6cb0` (@`0x7679e3`/`0x767a33`), guarded by a null check. That consumer is unread; on
the evidence of the call shape alone it is a named event or ambience cue, and it is *open*, not confirmed.

**`Render.Rain`'s first argument is a lie.** The corpus grades it carefully — `Rain(0.2, 1)` at
[`Act_1_Farm.lua:34`](../saboteur-luacd/src/Missions/Act_1_Farm.lua), `Rain(0.8, 1)` at
[`Act_1_Factory.lua:1158`](../saboteur-luacd/src/Missions/Act_1_Factory.lua), `Rain(1, 10)` at
[`Act_3_Mission_2.lua:2212`](../saboteur-luacd/src/Missions/Act_3_Mission_2.lua) — as though it were an
intensity in `0..1`. It is not. The body compares it against zero and branches:

```
0x0073d46f  d9 ee              fldz
0x0073d471  d8 5c 24 08        fcomp dword ptr [esp + 8]   ; 0.0 vs arg1
0x0073d475  df e0              fnstsw ax
0x0073d47b  f6 c4 05           test ah, 5                  ; MSVC "0.0 < arg1" idiom
0x0073d481  7a 0c              jp 0x73d48f                 ; arg1 <= 0 -> RainOff
0x0073d483  e8 48 a5 02 00     call 0x7679d0               ; arg1 > 0  -> RainOn
```

Both callees are near-identical twins. They differ in four places, all constants: `FUN_007679d0` opens
`fld1` where `FUN_00767a20` opens `fldz`; `push 1` (@`0x7679ee`) vs `push 0` (@`0x767a3e`); the interned
string constant `0xfe9780` vs `0xfe978c`; and `mov dword ptr [0x142e648], 1` (@`0x767a08`) vs `, 0`
(@`0x767a58`). The structure is otherwise instruction-for-instruction identical, and each stores its
**hardcoded** constant to the wetness target `[0x011f1cfc]`. Arg 1's magnitude never reaches memory. `Rain(0.2, 1)` and `Rain(0.8, 1)` produce
byte-identical state. The only surviving numeric input is arg 2, which both callees receive as
`1.0/fSeconds` (`fld1; fdivrp st(1)` @`0x73d465`) and store as the transition rate — so arg 2 is a
**duration in seconds**, not a rate. `Rain(1, 10)` means "rain on, ramping over ten seconds".

That reframes `Render.EnableAmbientRain` too. Its `false` path writes the same two wetness globals plus
the lightning flag, which makes it the subsystem's master reset rather than a peer toggle:
`EnableAmbientRain(false)` **silently turns the lightning off**, whatever `EnableLightning` was last
told. A modder chaining `EnableLightning(true)` after `EnableAmbientRain(false)` works; the reverse
order silently does not.

The lightning storm itself is a two-tier design that shipped half-used. `EnableLightning(b)` is the
master switch, and the corpus uses it heavily — `Render.EnableLightning(true)` opens three missions
([`Act_1_Escape.lua:32`](../saboteur-luacd/src/Missions/Act_1_Escape.lua),
[`Act_1_Factory.lua:387`](../saboteur-luacd/src/Missions/Act_1_Factory.lua),
[`Act_1_Farm.lua:33`](../saboteur-luacd/src/Missions/Act_1_Farm.lua), all verified verbatim) across 14
direct calls in 9 files. Beneath it sits an indexed per-flash-set API — `EnableLightningFlash(nSet, b)`
and the 13-argument `SetLightningFlashParams` — guarded by an index validator `FUN_00969700` and driving
`FUN_00969740` / `FUN_00969770`. **Neither has a single corpus call site.** The designers shipped a
parametric lightning authoring API and then drove the weather entirely from the master boolean.

`SetLightningFlashParams` is also the doc's best specimen of the hex-index trap
[02](02-marshalling-abi.md) warns about. Its guard chain runs `FUN_006f7140(1)` … `FUN_006f7140(0xb)`
then `FUN_006f7120(0xc)`, `FUN_006f7120(0xd)`. Read as decimal that is an 11-ish function with junk on
the end; read correctly it is **13 arguments** — eleven numbers and two booleans — marshalled into
`FUN_00969770(nSet, f2..f10, n11, b12, b13)`. It is the widest binding in the `Render` table.

## FX lifetime: `StartFX` / `EndFX` / `SetFXTime`

The three verbs share a prologue — resolve arg 1's handle via `FUN_0067c0a0`, walk to the owning entity,
then fetch the FX manager through vtable slot `+0x214` — and then diverge sharply in quality.

`StartFX(hTarget, sFXName, sBone)` is correct and well-used: 36 direct calls across 11 files, arity
bounded `1 < argc < 4`, arg 3 accepted as either a string or `nil` (`FUN_006f7160(3) || FUN_006f7100(3)`),
and an empty-string arg 3 normalised back to `NULL`. The corpus calls it exactly as the guard expects —
`Render.StartFX(hDeb, "0FX_Explosion01", nil)`
([`Act_3_Mission_3.lua:1329`](../saboteur-luacd/src/Missions/Act_3_Mission_3.lua)).

### The `EndFX` slot bug

`EndFX` type-checks its arguments identically to `StartFX` — slot 1 lightuserdata, slot 2 string, slot 3
string-or-nil — and then reads the FX name from **the wrong slot**:

```
0x0073e3a6  call 0x6f71a0      ; push 1  -> arg 1 IS lightuserdata? (guard)
0x0073e3b7  call 0x6f7160      ; push 2  -> arg 2 IS a string?      (guard)
...
0x0073e3e9  call 0x6f6ec0      ; push 1  -> fetch arg 1 as handle   (correct)
0x0073e419  call 0x6f7a80      ; push 1  -> fetch arg 1 as STRING   (*** wrong slot ***)
```

Compare `StartFX`, which fetches its name with `push 2; call 0x6f7a80` @`0x73e279`. This is not a Ghidra
artifact — the decomp and the bytes agree, and the bytes are authoritative. `FUN_006f7a80` is
`lua_isstring(n) ? lua_tolstring(n,NULL) : 0` ([02](02-marshalling-abi.md)); slot 1 holds lightuserdata,
`lua_isstring` is false, and the fetch returns **NULL every time**.

The NULL then propagates through the filter, and the mechanism is worth stating precisely because the two
hashes are easy to transpose. Both names are interned by `FUN_00db7e10(ptr, 1)`, which **null-checks its
input** (`test eax,eax; je 0xdb7e31` @`0x00db7e14` → `mov dword ptr [esi],0`) — so a NULL name hashes to
**0** rather than faulting. The name hash is written to the local at `esp+0x10` (`push 1; push ebx; lea
ecx,[esp+0x18]; call 0xdb7e10` @`0x73e44c`) and the bone hash to `esp+0x14` (@`0x73e458`); the loop
reloads them at `0x73e47e` into **`edi` = name, `esi` = bone**. The name filter is therefore
`test edi,edi` @`0x73e498`: `edi` is 0, the `cmp edi,[ecx+0x1e0]` name comparison @`0x73e4a6` is jumped
over, and control falls straight to `or byte ptr [eax+0x1f0],1` @`0x73e4ae` — the teardown bit — for
**every** FX on the target, not the named one. (The `test esi,esi` @`0x73e486` guarding
`cmp esi,[eax+0x1e4]` is the *bone* filter, not the name filter; every corpus caller passes `nil` for the
bone, so `esi` is 0 too and that filter is skipped as well.)

Every corpus caller passes the name correctly and is silently ignored:
`Render.EndFX(self.tRunwayFireRight[a_iIndex], "0FX_Fire06_Small_Torch", nil)`
([`Act_3_Mission_2.lua:482`](../saboteur-luacd/src/Missions/Act_3_Mission_2.lua)). All 8 call sites in 5
files behave as "end all FX on this object". Any mod relying on `EndFX` to remove one of several
concurrent effects will clear all of them.

### `SetFXTime` is a shipped stub

`SetFXTime` is the most elaborate no-op in the seam — far beyond `Render.PrintMessage`'s `mov eax,1; ret`
([19](19-family-ui-hud-tutorial.md)). It implements a genuine variadic **slot remapper**: for `argc` 2–4
it computes which stack slot holds the handle, the number, and up to two optional strings, probing
`FUN_006f71a0(2)` at `0x73e570` to disambiguate the 3-argument form. It then validates every slot,
resolves the handle, walks the vtable to the FX manager, and null-checks it. And then:

```
0x0073e628  55                push ebp          ; the number slot
0x0073e62b  e8 20 93 fb ff    call 0x6f7950     ; lua_tonumber -> st(0)
0x0073e630  dd d8             fstp st(0)        ; *** discard it ***
0x0073e632  85 ff             test edi, edi     ; (optional string 1 present?)
0x0073e636  57                push edi
0x0073e639  e8 42 94 fb ff    call 0x6f7a80     ; string -> eax, discarded
0x0073e63e  85 db             test ebx, ebx     ; (optional string 2 present?)
0x0073e645  e8 36 94 fb ff    call 0x6f7a80     ; string -> eax, discarded
0x0073e64a  5f                pop edi           ; function ends
```

`fstp st(0)` pops the FPU stack and throws the value away. Nothing is consumed; nothing is written. The
three corpus call sites — [`Paris_3_Mission_1.lua:960`](../saboteur-luacd/src/Missions/Paris_3_Mission_1.lua),
`:981`, and [`DestructionSequence.lua:143`](../saboteur-luacd/src/Modules/Libraries/DestructionSequence.lua)
— have never done anything. `HeatShimmerFilter` is the same story more bluntly: four `fstp st(0)` in a
row, six call sites in four files with carefully tuned parameters
(`Render.HeatShimmerFilter(0.4, 1.5, 1, 0.7)`,
[`SOE_Zeppelin.lua:1435`](../saboteur-luacd/src/Missions/SOE_Zeppelin.lua)), all inert.

The contrast with its sibling is instructive: `DrunkEffectFilter`, the row doc 19 excluded in the same
breath as `HeatShimmerFilter`, is **real** — it stores its float to `[0x143d02c]+0x28` — and has zero
corpus calls. One filter works and is never called; the other is called six times and does nothing.

## `FadeTo`, and the wrapper layer's dependency

`Render.FadeTo` (`0x0073e660`) is the residue's most load-bearing row: 46 direct calls across 19 files,
and — as briefed and verified — [`Includes/WRAPPER_Event.lua:500`](../saboteur-luacd/src/Includes/WRAPPER_Event.lua)
reads exactly `Render.FadeTo(0, 0, 0, 255, nInTime)`. The wrapper layer that
[06](06-lua-side-wrapper-layer.md) documents depends on a binding no family doc described.

It takes five arguments or silently does nothing: `if (argc == 5)`, then a loop guarding slots 1–5 with
`FUN_006f7140`. The four colour components are packed little-endian into one dword —
`((a<<8|b)<<8|g)<<8|r`, so arg 1 lands in the low byte — and handed to `FUN_009bc170(packed, fSeconds)`,
which unpacks each byte (`and edx,0xff`, `shr edx,8`, `shr edx,0x10`) and divides by the constant at
`[0xf8b710]` to normalise. The corpus confirms the byte order: `FadeTo(0,0,0,255,t)` packs `0xFF000000`
— opaque black — and `FadeTo(0,0,0,0,t)` packs zero. So the signature is `(r, g, b, a, seconds)`.

`EVENT_FadeInOut` composes the pair through the callback mechanism of [05](05-engine-to-lua-callbacks.md)
— note that the continuation is a **name string**, never a function value:

```lua
function EVENT_FadeInOut(a_nSeconds)                        -- WRAPPER_Event.lua:496
  Render.FadeTo(0, 0, 0, 255, nInTime)                      -- :500  fade to opaque black
  Util.CreateEvent({EventType = "TimerEvent", Time = nDarkTime},
                   "__UtilFunctions.CallbackFadeInOutHelper", nil, {nOutTime})
end
```

and the named helper closes it with `Render.FadeTo(0, 0, 0, 0, a_nSeconds)`
([`__UtilFunctions.lua:168`](../saboteur-luacd/src/Includes/__UtilFunctions.lua)) — fade back to
transparent. Every mission transition in the game runs through those two lines.

`FadeScreen` is the cruder relative — a single boolean into a singleton at `[0x12e85c4]` — and is the
most-called row in the whole residue (60 direct calls, 32 files). It reads only slot 1;
`Render.FadeScreen(true, 0)` at [`Act_1_BarFight.lua:1761`](../saboteur-luacd/src/Missions/Act_1_BarFight.lua)
passes a second argument the binding never looks at.

## UV scrolling, recovered from the exe

The three UV rows are `shape=inlined` and **absent from the Ghidra export entirely**. They are four or
five instructions each in the retail bytes, and they are complete:

```
PauseUVScrolling   0x0073fec0   mov eax,[0x15cffe8]; mov byte [eax+0xab0],0;  mov eax,1; ret
ResumeUVScrolling  0x0073ff10   mov ecx,[0x15cffe8]; mov eax,1; mov byte [ecx+0xab0],al; ret
ResetUVScrolling   0x0073fe70   fldz; mov eax,[0x15cffe8]; fstp dword [eax+0xaac]; mov eax,1; ret
```

UV scrolling is the texture-animation clock: a shader-visible phase (`+0xaac`, float) advanced each frame
while an enable byte (`+0xab0`) is set, on the singleton at `[0x015cffe8]`. It is what makes scrolling
water, smoke sheets and conveyor textures move. Two structural facts fall straight out of the bytes:

- **Pause and Resume are exact complements** — both write `+0xab0`, one `0` and one `1`. `Resume` writes
  `al` rather than an immediate purely because `eax` already holds the return value; the compiler reused
  the register. Cute, and unambiguous.
- **`Reset` is not the inverse of `Pause`.** It targets a *different field* (`+0xaac`, not `+0xab0`) and
  zeroes it as a float. Reset rewinds the scroll phase to zero; it does not resume anything. The naming
  invites the opposite reading, and a modder pairing `Pause`/`Reset` will get a still, rewound texture
  that never restarts.

All three have **zero corpus call sites** — the whole triad is dead script API in the shipped game.
They also expose a tsv defect: the map records `nresults` as blank for `ResumeUVScrolling` (and for
`ClearGlobalWTF`, `WTFExitActivePortal`), yet the body plainly ends `mov eax,1; ret`. The blank is a
dumper artifact, not a property of the binding.

## What the residue reveals

Read together, the 19 rows describe a subsystem built for a wetter, more parametric game than the one
that shipped. The rain has a target-wetness scalar the script API cannot reach; the lightning has an
indexed 13-parameter authoring interface with no callers; `SetFXTime` and `HeatShimmerFilter` retain
their full argument-marshalling plumbing with their effects surgically removed; and the entire UV
scrolling triad is unused. What shipped is the boolean subset: `EnableLightning(true)`, `Rain(x>0, t)`,
`FadeTo(0,0,0,255,t)`. The Saboteur's signature look is driven by three switches and a colour ramp.

It also shows what topic-based partitioning costs. These rows were skipped not because they were hard —
every one resolved to `confirmed` — but because "rain" is not a gameplay noun any family owned. Two
shipped stubs and a live argument-slot bug sat in the most-played code path in the game, in bindings the
seven claimant docs each assumed another doc had taken.

Cross-references: [06](06-lua-side-wrapper-layer.md) (the `FadeTo` dependency),
[12](12-family-suspicion-wtf-alarm.md) (the 16 `WTF*` rows), [16](16-family-world-zone-interior.md)
(water level, the other `Render` weather surface), [18](18-family-cinematics-camera-face.md)
(`CameraShakeExplosion`), [19](19-family-ui-hud-tutorial.md) (the disassembly method, and the
`PrintMessage` stub precedent), and [`docs/symbol_map/render-fx-light.md`](../symbol_map/render-fx-light.md)
— which lists `EndFX`, `SetFXTime`, `StartHighlight`/`StopHighlight`, `ToggleLights`,
`EnableLightning`/`EnableLightningFlash`/`SetLightningFlashParams` as "names only, backends not yet
pinned". This doc pins them: `FUN_007679d0`/`FUN_00767a20` (rain), `FUN_009698f0`/`FUN_00969700`/
`FUN_00969720`/`FUN_00969740`/`FUN_00969770` (lightning), `FUN_009d21a0`/`FUN_009d1fa0` (StartFX),
`FUN_009bc170` (FadeTo), `FUN_007e6130` (ToggleLights), `FUN_0083cac0` (PrintDialogue).

## Open questions

1. **What does `nSet` index in `EnableLightningFlash` / `SetLightningFlashParams`?** `FUN_00969700`
   validates it and `FUN_00969720` validates arg 11 the same way — two parallel index spaces. With zero
   corpus calls there is no caller-side evidence for either range. Reading `FUN_00969700` would settle it.
2. **What are `SetLightningFlashParams`' nine floats?** Colour, duration, intensity and delay are the
   obvious guesses and none are evidenced. `FUN_00969770`'s body would name them by their store offsets.
3. **What does `SetFXTime` return?** Its tail (`0x73e651`) has **no `mov eax,1`**, unlike every other row
   here — `eax` holds whatever `FUN_006f7a80` last returned, a `const char*`. `HeatShimmerFilter`
   (`0x73d339`) has the same shape. If the dispatcher reads `nresults` from `eax` rather than from the
   registration stanza, both bindings return a pointer as a Lua result count. [01](01-registration-and-dispatch.md)
   should be able to adjudicate; the tsv records `nresults=1` for both.
4. ~~**Is the `EndFX` slot bug reachable as a crash?**~~ **Closed — no.** `FUN_00db7e10` opens
   `mov eax,[esp+4]; test eax,eax; je 0xdb7e31` (@`0x00db7e10`–`0x00db7e19`), and the taken branch is
   `mov dword ptr [esi],0; mov eax,esi; ret 8`. It null-checks explicitly and returns hash `0` without
   dereferencing; it is not getting lucky. The bug is silently wrong, never fatal — which is precisely why
   it shipped.
5. **What is the singleton at `[0x015cffe8]`?** It carries UV scroll phase `+0xaac` and enable `+0xab0`.
   [`render-fx-light.md`](../symbol_map/render-fx-light.md) pins several fx singletons by RTTI; this one
   is not among them.
6. **Why is `DrunkEffectFilter` wired but uncalled while `HeatShimmerFilter` is called but stubbed?**
   The likeliest reading is that the shimmer effect was cut late and the drunk filter early, but the
   `[0x143d02c]+0x28` consumer is unread and would say for certain.

**Confidence: high.** All 19 bodies were read at byte level in the retail exe or the decomp; the six that
Ghidra rendered incompletely — `FadeScreen` among them, where the decomp shows a `thunk_FUN_004d771f`
where the bytes show `mov ecx,[0x12e85c4]; call 0x652690` @`0x73e791` — plus all three `inlined` rows,
nine in total, were disassembled directly from `Saboteur.exe` and the bytes are quoted inline. Every corpus number is a grep count with direct calls and
bare table references kept separate, and every `file:line` was opened and read. The two stub findings and
the `EndFX` slot bug rest on quoted instruction bytes, not on decompiler output. Residual risk is the
one [the README](README.md) names for all 876 non-self-identifying rows: name↔VA identity derives from
[`data/lua_registration_map.tsv`](../../data/lua_registration_map.tsv), a single derived artifact. No row
here carries an EALA assertion string. The `open` items above are open because the *callees* are unread,
not because the bindings are ambiguous.
