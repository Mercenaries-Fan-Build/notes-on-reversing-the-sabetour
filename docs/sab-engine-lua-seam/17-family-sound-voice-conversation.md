# Family 17 — Sound, Voice, Conversation

> **Verified:** all 38 VAs re-grepped against the decomp (28 present / 10 absent — exactly as claimed) and
> re-matched to `data/lua_registration_map.tsv`, whose `thunk_va` provably equals each body's `callers=[]`
> entry minus 5; all 26 corpus citations re-read at the quoted line and all hold; the zero-assertion-string
> sweep reproduces (0 hits, no `Script\Interface\Sound.cpp`). Corrected five overclaims: `LoadSoundBank`
> does **not** pass `DAT_01442928` into `FUN_00914b30` (gate-read only); the `_strstr(".")` check is
> `LoadSoundBank`'s, not `PlayConversation`'s; the `LoudSpeakers` pair **does** have corpus evidence
> (`RewardsManager.lua:275,622`) and is no longer "open"; `PlayOwnerlessSoundEvent`'s `-> hPlaying` is
> downgraded to inferred (0 of 48 sites use the return); `Actor.SetTalkable`'s attraction point (arg 4) is
> **not** gated on `bTalkable`, only the conversation (arg 3) is.

The Wwise-backed audio seam, plus the conversation/VO director that sits on top of it.
Engine-side counterpart: [`docs/symbol_map/sound.md`](../symbol_map/sound.md), which documents the
`WSSoundManager` / `WSSoundBankManager` / `WSSoundEmitter` layer but lists the Lua glue VAs as an
explicit gap ("*Lua glue thunk VAs … require the RTTI vtable→VA map; here they are matched to manager
methods by behavior, not by a call edge*"). **This document closes that gap**: every binding below is
pinned to a VA by [`data/lua_registration_map.tsv`](../../data/lua_registration_map.tsv) and, where the
body exists, to a real call edge into the `0x0091xxxx` manager range.

Method and vocabulary follow [`02-marshalling-abi.md`](02-marshalling-abi.md); primitive numbers
(`FUN_006f71a0` = "arg *n* is lightuserdata", etc.) are used without re-deriving them.

## Inclusion rule

A binding is in this family if it satisfies **any** of:

1. It is in the **`Sound` table** — the whole table, all 21 rows, no exceptions. The table *is* the Wwise seam.
2. It is in the **`Cin` table** and its `lua_name` contains `Conversation`, `Speaker`, `Music`, or `Subtitles` (11 rows).
3. It lives in another table but its **subject is sound or speech**: `Actor.SetTalkable`, `Actor.IsTalkable`,
   `Actor.SetDistantRagdollSound`, `Combat.BroadcastSound`, `Combat.SetRespondToSound` (5 rows).
4. `Util.SetLastMissionChatter` — claimed on the "chatter" keyword shared with `Sound.*Chatter` (1 row).

**M = 38.**

Deliberately **excluded**, named so the boundary is auditable rather than silent:

| Excluded | Why |
|---|---|
| `Cin.GetLocalizedText`, `Cin.LoadGameTextFile`, `Cin.ReleaseGameTextFile` | Localized-text container management. **Genuinely coupled** — `Sound.PlayTextID` resolves a text ID through the same store (`FUN_0095e4e0`) — but they are a text family, not an audio one. Overlap acknowledged. |
| `HUD.AddSubtitle`, `Render.PrintDialogue` | Text *rendering*. `Cin.SubtitlesOn` is claimed (it is a Cin/VO policy toggle); the drawing calls belong to the HUD/Render families. |
| `Cin.PlayBinkMovie`, `Cin.BinkDemoPlay`, `Cin.StopBinkMovie` | Bink video; carries its own audio track outside Wwise. |

One inclusion is deliberately contestable: **`Combat.BroadcastSound` and `Combat.SetRespondToSound` make
and hear no sound** — they are AI-perception bindings wearing sound names (see the false-friend note
below). They are claimed anyway, because a reader partitioning by name will land on them here, and
omitting them would leave that misreading uncorrected rather than fixed.

## Coverage honesty

> **38 of 38 bindings in this family located** (VA, table, Lua name, and return family read byte-level from
> the exe via `data/lua_registration_map.tsv`).
> **0 confirmed by assertion string.**
> **28 signatures derived from a decomp body** (read directly; 17 of those additionally corroborated by a Lua call site).
> **10 signatures inferred or open** — the function body is **absent from the decomp export**.
> **0 not found.**
>
> Of those 10 bodyless rows, **8 are inferred** from corpus evidence and **2 remain fully open**
> (`Cin.SetSpeakerWeight`, `Cin.GetHumanConversationID` — no body, no call site, no string).
> The `LoudSpeakers` pair moved open → inferred on verification (see their rows).

Two things deserve emphasis, because they cut against the method the assignment prescribes:

**There is not one EALA assertion string in this entire family.** A sweep of all 38 `lua_name` values as
quoted string literals across the 54 MB decomp returns zero hits. The known `Script\*.cpp` assertion sites
are `{Actor, Object, Vehicle, Utility, Navigation, Inventory, SaveLoad}.cpp` and the Freeplay/Events set —
there is **no `Script\Interface\Sound.cpp`** among them. So the **Source (file:line) column is empty for
every row**, and stays empty. That is a real absence, not an unfinished search. Identity is nonetheless
*confirmed*, just by a different instrument: the registration map is read from the binary's own
`luaL_register` stanzas, which is byte-level proof of name↔VA, and it is what the assertion string would
only corroborate.

**Ten bodies are missing from the decomp export itself.** All six `Sound.*Chatter` / `*LoudSpeakers`
toggles (`0x00744e10`–`0x00744e70`), plus `Cin.SetSpeakerWeight` (`0x0071ea30`), `Cin.SubtitlesOn`
(`0x0071e950`), `Cin.IsHumanInConversation` (`0x0071cb20`) and `Cin.GetHumanConversationID`
(`0x0071cc00`) have **no `==== FUN_… ====` record**. The nearest exported functions bracket them
(`FUN_007449b0` … `FUN_00744f00`; `FUN_0071c890` … `FUN_0071cca0`), so the addresses fall in a genuine
hole in Ghidra's function discovery. This correlates with — but is **not explained by** — the `inlined`
and `jmp` shapes in the tsv: `Sound.AttachSoundEvent` and `Sound.PlayOwnerlessSoundEvent` are `jmp`-shape
too and *are* exported. Their signatures below come from the Lua corpus only, and are marked accordingly.
This is an **open** item, recorded rather than papered over.

---

## The bindings

`Source` is empty for all 38 rows for the reason given above and is omitted from the table rather than
printed as 38 dashes. Confidence is per-**signature**; VA/name/return-family are confirmed for every row.

### `Sound` — banks

| Binding | Namespaced form | VA | Signature | Confidence | Evidence |
|---|---|---|---|---|---|
| `LoadSoundBank` | `Sound.LoadSoundBank` | `0x007449b0` | `(sBank, [sCallback, [tSelf, [tArgs]]]) -> ()` | confirmed | Body: `FUN_006f7160(1)`; gated on `*(DAT_01442928+0x11dc)`; optional arg 2 string must contain `"."` (`_strstr(_Str,".")`) → dotted callback name; `FUN_006f6970()>2` → arg 3, `>3` + `FUN_006f71c0(4)` → arg 4 table. Calls `FUN_00914b30` = **LoadBankAsync** with default callback `FUN_00913d20` ([sound.md](../symbol_map/sound.md)). Corpus: `Missions/Act_1_Race.lua:31` |
| `ReleaseSoundBank` | `Sound.ReleaseSoundBank` | `0x00743850` | `(sBank, [bFlag]) -> ()` | confirmed | Body `FUN_00743850`: `FUN_006f7160(1)`, optional `FUN_006f7120(2)`→`FUN_006f6e60(2)`; the flag is **inverted** (`uStack_4 = (cVar1=='\0')`, default `1`). Calls `FUN_00913df0` = **UnloadBank**. Corpus: `Missions/Act_1_BarFight.lua:230` — but **every** corpus site is 1-arg; the optional flag is never exercised |
| `UnloadSoundBank` | `Sound.UnloadSoundBank` | `0x007437c0` | `(sBank) -> ()` | confirmed | Body `FUN_007437c0`: `FUN_006f7160(1)` only; gated on `*(char*)(DAT_01442928+0x11dc)`; calls `FUN_00913df0(DAT_01442928,0,0,1)` — same UnloadBank, 4th arg **hardcoded 1**. Corpus: `Sound.UnloadSoundBank("M_A1M4_InGame.bnk")` |

`ReleaseSoundBank` and `UnloadSoundBank` reach the **same** engine function, `FUN_00913df0`. They differ in
exactly two ways: `UnloadSoundBank` checks the `+0x11dc` "SoundEngine ready" gate and `ReleaseSoundBank`
does not, and `ReleaseSoundBank` lets Lua drive the final flag while `UnloadSoundBank` pins it to `1`.
*Inferred:* the flag is force-vs-refcounted, making `Release` the decrement and `Unload` the eviction —
but the flag's meaning is **open**, and the gate asymmetry looks more like an oversight than a design.

### `Sound` — emitters and events

| Binding | Namespaced form | VA | Signature | Confidence | Evidence |
|---|---|---|---|---|---|
| `AttachSoundEvent` | `Sound.AttachSoundEvent` | `0x007438f0` | `(hEmitter, sEvent) -> hPlaying` | confirmed | Body: `FUN_006f71a0(1)`→`FUN_006f6ec0(1)`→`FUN_0067c0a0`, vtable`+0x280`, then `FUN_006f7160(2)`→`FUN_006f7a80(2)`. `LuaGlueFunctor0R`, `return 1` on success / `0` on failure. Return **is a handle**: `Paris_6_Mission_1.lua:1279` `self.hSoundSputter = Sound.AttachSoundEvent(self.hTrucky, "VEH_P3M1_Engine_01_Sputter_loop")`, consumed at `:1696` by `StopSoundEvent` arg 2, which type-checks `FUN_006f71a0` |
| `PlayOwnerlessSoundEvent` | `Sound.PlayOwnerlessSoundEvent` | `0x007439e0` | `(sEvent) -> ?` | confirmed (args); **return inferred** | Body: `FUN_006f7160(1)` only → `FUN_0091ae20(uVar3,0,0,0)` = **`WSSoundEmitter::PlayEvent`** ([sound.md](../symbol_map/sound.md)); `return 1` / `0` = *result count*, so one value is pushed on success. **What** it is is not established: unlike `AttachSoundEvent` there is no consuming call site — **0 of 48 corpus sites use the return value**. Corpus: `Sound.PlayOwnerlessSoundEvent("A1M1_Race_Start")` (`Missions/Act_1_Race.lua`) |
| `StopSoundEvent` | `Sound.StopSoundEvent` | `0x00743a80` | `(hEmitter, hPlaying) -> ()` **or** `(hPlaying) -> ()` | confirmed | Body: `FUN_006f6970()` switches. `==2`: `FUN_006f6ec0(1)`→`FUN_0067c0a0`, vtable`+0x280`, `FUN_006f71a0(2)`→`FUN_006f6ec0(2)`. `==1`: `FUN_006f71a0(1)`→`FUN_0091aef0`. Corpus proves both: `Paris_6_Mission_1.lua:1696` (2-arg), `Act_1_Farm.lua:89` (1-arg) |
| `ActivateSoundEmitter` | `Sound.ActivateSoundEmitter` | `0x00743b90` | `(hEmitter) -> ()` | confirmed | Body: `FUN_006f71a0(1)`→`FUN_006f6ec0(1)`→`FUN_0067c0a0(h)`, vtable`+0x284` → on the result, vtable`+0x3c` **with literal `1`** |
| `DeactivateSoundEmitter` | `Sound.DeactivateSoundEmitter` | `0x00743c40` | `(hEmitter) -> ()` | confirmed | `FUN_00743c40` is **byte-for-byte `FUN_00743b90` with the `1` replaced by `0`**. One engine setter, two Lua names |
| `PlayTextID` | `Sound.PlayTextID` | `0x00743eb0` | `(hEmitter \| sEmitterName, sTextID) -> ()` | confirmed (body); **no corpus use** | Body: arg 1 tried as `FUN_006f71a0(1)`, else **falls back** to `FUN_006f7160(1)`+`FUN_006f7a80(1)`. Arg 2 `FUN_006f7160(2)` → `FUN_0095e4e0` (text lookup, requires `*(id+0x1c)!=0`) → `FUN_0095df40`. Zero call sites in the 321-file corpus |

`ActivateSoundEmitter` / `DeactivateSoundEmitter` route through **`FUN_0067c0a0`**, the *second* handle map
(`DAT_01321e38`, with the extra `+0x18` gate — [§7 of the ABI](02-marshalling-abi.md)), not the `FUN_004436f0`
actor map. Every `Sound.*` binding that takes a handle uses this map. Emitters are world objects, not actors.

### `Sound` — music, parameters, states

| Binding | Namespaced form | VA | Signature | Confidence | Evidence |
|---|---|---|---|---|---|
| `SetMusicLocale` | `Sound.SetMusicLocale` | `0x00743cf0` | `(sLocale) -> ()` **or** `(sStateGroup, sState) -> ()` | confirmed | Body: `FUN_006f6970()` ≥1 + `FUN_006f7160(1)`; `==1` → `FUN_00911400(s)`; else `FUN_006f7160(2)` → `FUN_00911440(s1,s2)` — **the two arities call different engine functions and mean different things** (see below). (This is the canonical variadic example in [`02-marshalling-abi.md` §5](02-marshalling-abi.md).) Corpus: 1-arg `Missions/Connect_AmbientFP.lua:490` `Sound.SetMusicLocale("P1M1b_LaVilletteLiberate")`; 2-arg `Missions/Connect_A1_M2c_JulesToTrack.lua:167` `Sound.SetMusicLocale("Cinematic", "In")`, `Missions/P1FP_Traitor.lua:858` `Sound.SetMusicLocale("fp_P1FP_Traitor", "disguised")` |
| `ResetMusicLocale` | `Sound.ResetMusicLocale` | `0x00743690` | `() -> ()` | confirmed | Body takes **no `param_1`** — it never touches the Lua stack. Hardcodes `"default"` and `"intensity"` into the same two engine calls `SetMusicLocale` uses — i.e. it is `SetMusicLocale("default")` **plus** a state reset. Corpus: `Missions/Act_1_BarFight.lua:229` |
| `PlayMusicStab` | `Sound.PlayMusicStab` | `0x00743e30` | `(sStab) -> ()` | confirmed | Body: `FUN_006f7160(1)` → `FUN_00db7e10` → `FUN_00910fb0`. Corpus: `Sound.PlayMusicStab("Success_Stab")` (only distinct argument in the corpus) |
| `SetParam` | `Sound.SetParam` | `0x00744070` | `(sParam, fValue) -> ()` | confirmed (body); **no corpus use** | Body: `FUN_006f6970() == 2` **exactly**, `FUN_006f7160(1)`, `FUN_006f7140(2)`→`FUN_006f7950(2)` → **`FUN_00918460(name, float, 0xffffffff)` = `SetRTPCValue` by name** ([sound.md](../symbol_map/sound.md)). `0xffffffff` = "all game objects" |
| `SetTimedParam` | `Sound.SetTimedParam` | `0x00744120` | `(sParam, f2, f3, f4, f5) -> ()` | confirmed (body); **no corpus use** | Body: `FUN_006f6970() == 5` **exactly**; `FUN_006f7160(1)` + `FUN_006f7140(2..5)` → `FUN_00918be0(name, f,f,f,f, 0xffffffff)`. The four floats' roles (value / duration / curve / delay?) are **open** |
| `SetState` | `Sound.SetState` | `0x00743fc0` | `(sGroup, sState) -> ()` | confirmed (body); **no corpus use** | Body: `FUN_006f6970() == 2` exactly, `FUN_006f7160(1)`+`FUN_006f7160(2)` → **`FUN_00918540` = `SetState`** ([sound.md](../symbol_map/sound.md)). Beware: every `SetState` hit in the Lua corpus is `Suspicion.SetState`, a different binding |

### `Sound` — the six toggles (bodies absent)

| Binding | Namespaced form | VA | Signature | Confidence | Evidence |
|---|---|---|---|---|---|
| `EnableSeanChatter` | `Sound.EnableSeanChatter` | `0x00744e20` | `() -> ()` | inferred | No body in decomp. Corpus calls it with **no arguments** |
| `DisableSeanChatter` | `Sound.DisableSeanChatter` | `0x00744e10` | `() -> ()` | inferred | ditto |
| `EnableAllChatter` | `Sound.EnableAllChatter` | `0x00744e40` | `() -> ()` | inferred | ditto. **tsv anomaly:** this is the only row of 898 with an *empty* `nresults` |
| `DisableAllChatter` | `Sound.DisableAllChatter` | `0x00744e30` | `() -> ()` | inferred | ditto |
| `EnableLoudSpeakers` | `Sound.EnableLoudSpeakers` | `0x00744e50` | `() -> ()` | inferred | No body, and **no direct call site** — but referenced as a deferred action at `Managers/RewardsManager.lua:622`: `{ Sound.EnableLoudSpeakers, {} }`, a `(function, argsTable)` pair whose args table is **empty**. Positive evidence for zero arity |
| `DisableLoudSpeakers` | `Sound.DisableLoudSpeakers` | `0x00744e70` | `() -> ()` | inferred | ditto, `Managers/RewardsManager.lua:275`: `{ Sound.DisableLoudSpeakers, {} }` |

The six sit on a 0x10-byte stride across the span `0x00744e10`–`0x00744e70` in strict
disable/enable/disable/enable/enable/disable pairing order, all `inlined` shape with
`thunk_va == impl_va`. The stride has one hole: `0x00744e60` is claimed by no row in the tsv, so the block
is evenly spaced but not quite contiguous. *Inferred:* each is a one-instruction global flag write, which is why they were
inlined into their own thunks and why Ghidra never promoted them to functions.

### `Cin` — conversation

| Binding | Namespaced form | VA | Signature | Confidence | Evidence |
|---|---|---|---|---|---|
| `PlayConversation` | `Cin.PlayConversation` | `0x0071dfe0` | `(sConv, [sCallback, [tSelf, [tArgs, [bFlag]]]]) -> ()` | confirmed | Body: `FUN_006f7160(1)`; `FUN_006f6970()>1` → `FUN_006f7160(2)` **mandatory once argc>1** (else bare `return`), non-empty string → `FUN_0070a180` (dotted-name split); `FUN_006f71c0(3)`→`FUN_0070a4b0(3)`; `FUN_006f71c0(4)`→`thunk_FUN_00481ae6`; `FUN_006f7120(5)` bool. → `FUN_00950c00(conv, cb, 1, bFlag)`. Corpus nails it: `Includes/__UtilFunctions.lua:752` `Cin.PlayConversation(sBestConv, "ConvManager.SetConvDone", nil, {self, sBestConv, true})` |
| `PlayConversationWith` | `Cin.PlayConversationWith` | `0x0071e100` | `(sConv, tSpeakers, [sCallback, [tSelf, [tArgs]]]) -> ()` | confirmed | See the walkthrough below. Corpus: `Missions/P1FP_Entourage.lua:665` `Cin.PlayConversationWith("cht_com_Miss", {self.hLeader}, "P1FP_Entourage.SendGuardsToHelp", self)` |
| `StopConversation` | `Cin.StopConversation` | `0x0071c680` | `(sConv) -> ()` **or** `(nConvID) -> ()` | confirmed | Body: `FUN_006f7160(1)` → `FUN_0094d650(s,1)`; **else** `FUN_006f7140(1)` → `FUN_006f7990(1)` (int) → `FUN_0094c670(id,1)`. Two engine functions behind one name. Corpus: `Missions/Act_1_GetCaught.lua:673` (string form) |
| `InterruptConversation` | `Cin.InterruptConversation` | `0x0071c710` | `(sConv) -> ()` **or** `(nConvID) -> ()` | confirmed | Same dual dispatch: `FUN_0094d6c0(s)` / `FUN_0094adc0(id)`. Corpus: `Missions/SOE_2_Mission_2.lua:2335` |
| `ConversationConditionPassed` | `Cin.ConversationConditionPassed` | `0x0071c790` | `(nConvID, bPassed) -> ()` | confirmed | Body: `FUN_006f7140(1)` + `FUN_006f7120(2)` → `FUN_00956980(int, bool)`. **Note the fetch order is inverted vs. the check order** (`FUN_006f6e60(2)` runs before `FUN_006f7990(1)`) — harmless, both are pure. Corpus: `Includes/__UtilFunctions.lua:369` `Cin.ConversationConditionPassed(ConversationID, bCompleted)` |
| `IsHumanInConversation` | `Cin.IsHumanInConversation` | `0x0071cb20` | `(hHuman) -> bool` | inferred | **Body absent from decomp.** `LuaGlueFunctor0R`/`jmp` ⇒ real result count. Corpus is unambiguous: `Missions/Act_1_GetCaught.lua:556,1177,1543` all `Cin.IsHumanInConversation(hSab)` in boolean position |
| `GetHumanConversationID` | `Cin.GetHumanConversationID` | `0x0071cc00` | `(hHuman) -> nConvID` *(presumed)* | **open** | **Body absent from decomp AND zero corpus call sites.** Name + `LuaGlueFunctor0R` is all the evidence there is. The `nConvID` it presumably returns is the integer `StopConversation`/`InterruptConversation`/`ConversationConditionPassed` accept — that pairing is the only reason to believe the shape |
| `SetSpeakerWeight` | `Cin.SetSpeakerWeight` | `0x0071ea30` | unknown | **open** | Body absent (`inlined`); zero corpus call sites. Nothing but the name is known |
| `SubtitlesOn` | `Cin.SubtitlesOn` | `0x0071e950` | `(bOn) -> ()` | inferred | Body absent (`inlined`). Corpus: `Cin.SubtitlesOn(true)` / `Cin.SubtitlesOn(false)` — both literals appear |

### `Cin` — music override

| Binding | Namespaced form | VA | Signature | Confidence | Evidence |
|---|---|---|---|---|---|
| `SetEnterMusicOverride` | `Cin.SetEnterMusicOverride` | `0x0071ced0` | `(s1, s2, s3, s4) -> ()` | confirmed (body); **no corpus use** | Body: four `FUN_006f7160(1..4)` `&&`-chained — **all four mandatory** — then four `FUN_006f7a80` copies into `DAT_0147db40 + 0x48/0x4c/0x50/0x54`, and sets **bit 0 of `+0x58`** as the "override present" flag |
| `SetExitMusicOverride` | `Cin.SetExitMusicOverride` | `0x0071cfd0` | `(sBank, sGroup, sState, sX) -> ()` | confirmed | **Identical body**, different destination: `+0x5c/0x60/0x64/0x68`, flag bit 0 of `+0x6c`. Corpus, exactly one site: `Cin.SetExitMusicOverride("cin_116_CinB_FollowD", "Cinematic", "In", "Cinematic")` |

The single `SetExitMusicOverride` call site is what gives the four strings meaning: arg 1 is a bank
(`cin_…`), args 2/4 look like a Wwise State Group and args 3 a State — i.e. the same `(group, state)` pair
`Sound.SetState` takes. The two structs are 0x14 bytes apart in one object (`DAT_0147db40`), enter at
`+0x48`, exit at `+0x5c`. *Inferred* — one call site is thin evidence for four parameter names, and arg 4's
role is **open**.

### Cross-table

| Binding | Namespaced form | VA | Signature | Confidence | Evidence |
|---|---|---|---|---|---|
| `SetTalkable` | `Actor.SetTalkable` | `0x00713470` | `(hActor, bTalkable, [sConv, [sAttrPt, [bFlag]]]) -> ()` | confirmed | Body: canonical `FUN_004436f0` actor lookup + vtable`+0x1c`; `FUN_006f7120(2)`→`FUN_006f6e60(2)` sets **bit 3 of `+0x1d4`**. **arg 3 is read only if arg 2 is true** (`if ((cVar1 != '\0') && (cVar1 = FUN_006f7160(3), ...))`); arg 3 → `FUN_007166a0` copies `+0x20`→`+0x178` and `+0x78`→`+0x1d0`; arg 4 → `+0x17c`; arg 5 bool. Corpus: `Modules/SabTaskObjectiveInteract.lua:43` `Actor.SetTalkable(hInterActor, true, sConversation, tConfig.sStarterAttrPt)` and `:226` `Actor.SetTalkable(hInterActor, false)` |
| `IsTalkable` | `Actor.IsTalkable` | `0x007133b0` | `(hActor) -> bool` | confirmed | Body: actor lookup → vtable`+0x78` → `thunk_FUN_0043fbc6` (push) → `return 1`; `return 0` on any failure. Corpus: `Modules/SabTaskObjectiveInteract.lua:578,586` |
| `SetDistantRagdollSound` | `Actor.SetDistantRagdollSound` | `0x00714170` | `(hActor) -> ()` | confirmed | Body: the textbook `Actor.Ragdoll` idiom (`FUN_006f71a0(1)`→`FUN_006f6ec0(1)`→`FUN_004436f0`→vtable`+0x1c`→`FUN_0083a200` weak-ref recheck) → `FUN_004f2210`. **No prefix strip** — the C++ symbol and the Lua name are both `SetDistantRagdollSound`. Corpus: `Actor.SetDistantRagdollSound(hDropNazi1)` |
| `BroadcastSound` | `Combat.BroadcastSound` | `0x0071f780` | `(fX, fY, fZ, fRadius, fB, [bFlag]) -> ()` **or** `(hOrigin, fRadius, fB, [bFlag]) -> ()` | confirmed | See below |
| `SetRespondToSound` | `Combat.SetRespondToSound` | `0x00721d50` | `(hActor, bRespond) -> ()` | confirmed | Body: `FUN_006f71a0(1)` + `FUN_006f7120(2)`, `FUN_00498440` lookup → vtable`+0x1c` → `+0x140` → sets **bit 1 of `+0x228`**. Corpus: `Combat.SetRespondToSound(Handle(hActor), …)` |
| `SetLastMissionChatter` | `Util.SetLastMissionChatter` | `0x0074ec40` | `(sChatter) -> ()` | confirmed (arg); **store inferred** | Body: `FUN_006f7160(1)` → `FUN_006f7a80(1)` → `FUN_00db7e10(s,1)` (intern), then a store into `*(DAT_01240328 + 0x220c)`. A single global slot. *Caveat:* Ghidra types this `__thiscall` and renders the store as `= param_1`, i.e. the `this` pointer, while `FUN_00db7e10`'s result is uncaptured — the interned string reaching the slot is the **inferred** reading of that artifact, not a literal one. Corpus: `Util.SetLastMissionChatter(SabTask._tMiscSaveTable.LastMissionChatter)` — it is **save-game state** |

---

## How the subsystem actually works

### The `Sound` table is a direct, unwrapped seam

Unlike `Actor`/`Util`/`Event`, which scripts reach through
[`Includes/WRAPPER_*.lua`](../saboteur-luacd/src/Includes/), **there is no `WRAPPER_Sound.lua`** — a grep
for `function Sound.` and `Sound = {` across all 321 corpus files returns nothing. Mission code calls the C
table straight. The `Sound` namespace also happens to be the clean case for name mapping: all 21 rows have
`cpp_symbol == lua_name`, so no prefix is stripped and none is added. That is a property of this table, not
a rule — `Actor.SetDistantRagdollSound` is unstripped while its neighbour `ActorRagdoll` → `Actor.Ragdoll`
is not.

The practical consequence is that **the Lua caller gets no safety net**, which matters because of the next
two sections.

### Handles are the currency, and the corpus gets it wrong three times

Every emitter binding demands lightuserdata (`FUN_006f71a0`) and every fetch silently returns zero on a
type mismatch. Scripts are expected to wrap names with `Handle(...)` — `Modules/Libraries/TipsLib.lua:25`,
`function Handle(a_vVariable) return Tips.CheckForHandle(a_vVariable) end`. Most do: 53 of 55
`Sound.ActivateSoundEmitter`/`DeactivateSoundEmitter` call sites pass a handle or a `Handle(...)` result.

**Two do not**, and one `StopSoundEvent` joins them:

- `Missions/Act_1_Race.lua:1010` — `Sound.ActivateSoundEmitter("CountrySide\\alsace\\racetracks\\sound\\A1M1_TunnelCrash")`
- `Missions/Act_1_Race.lua:1020` — `Sound.ActivateSoundEmitter("CountrySide\\alsace\\racetracks\\sound\\A1M1_CarCrash")`
- `Missions/Act_3_Mission_3.lua:2088` — `Sound.StopSoundEvent("a3m3_tesla_coils_lp")`

A Lua string is `LUA_TSTRING` (4), not `LUA_TLIGHTUSERDATA` (2). `FUN_006f71a0(1)` returns false, the
binding falls out of its `if`, and **nothing happens** — no error, no log, no assert. These are dead calls
in shipped retail. The tunnel and car crash emitters in Act 1's race never activate from these lines, and
the Act 3 tesla-coil loop is never stopped from that one. This is the
[§7 silent-failure property](02-marshalling-abi.md) meeting an unwrapped table, and it is exactly the class
of bug an unwrapped seam cannot catch. *(Confirmed at the type level; not observed at runtime.)*

Note that `Sound.PlayTextID` (`0x00743eb0`) **does** accept either — it tries `FUN_006f71a0(1)` and falls
back to `FUN_006f7160(1)`. Somebody knew. It just wasn't applied to the emitter pair.

### `"Speaker%d"` — how a conversation binds its cast

`Cin.PlayConversationWith` (`FUN_0071e100`) is the most informative body in the family, because it shows
the conversation system's role model in the clear:

```c
iVar2 = FUN_00959a30(pcVar4);            // resolve conversation by name; bail if 0
iVar7 = 1;  cStack_21 = '\x01';
do {
  uVar5 = FUN_006f78b0(2, iVar7, &cStack_21);   // tSpeakers[iVar7] -> lightuserdata, ok flag
  if (cStack_21 != '\0') {
    iVar6 = FUN_0067c0a0(uVar5);                // handle -> object
    if (iVar6 == 0) { FUN_00957ae0(); FUN_00db41e0(iVar2); return; }   // abort whole conv
    _sprintf(acStack_20, "Speaker%d", iVar7);   // <-- the role name
    uVar5 = extraout_ECX;                       // (Ghidra artifact: uVar5 is reused here)
    FUN_00db7e10(acStack_20, 1);                // intern "SpeakerN"
    FUN_00957720(uVar5, iVar6);                 // bind role -> object
  }
  iVar7 = iVar7 + 1;
} while (cStack_21 != '\0');
```

So a conversation asset is authored against **positional role names — `Speaker1`, `Speaker2`, … — and the
Lua array's index *is* the role number.** `Cin.PlayConversationWith("cht_com_Miss", {self.hLeader}, …)`
binds `self.hLeader` to `Speaker1`. There is no way to name a role from script; ordering is the entire
contract. That also explains the family's `SetSpeakerWeight` and the `Speaker*` naming in the assignment
brief.

`FUN_006f78b0(tableIndex, arrayIndex, &okFlag)` is a **marshalling primitive not in the cheat sheet** —
a Lua array-element fetch returning lightuserdata plus a success flag, driving a 1-based loop that
terminates on the first absent index. Worth adding to [`02-marshalling-abi.md`](02-marshalling-abi.md).

The failure mode is the interesting part: a bad speaker handle does **not** skip that speaker — it calls
`FUN_00957ae0()` (teardown), releases the conversation (`FUN_00db41e0`), and returns. **One dead actor
kills the whole conversation, silently.** Contrast `PlayConversation`, which has no cast and cannot fail
this way. Mission scripts guard for this: `Missions/Act_1_BarFight.lua:830` re-checks `hDude` before
`Cin.PlayConversationWith("A1M2_NaziFightChatter", {hDude})`.

### Conversations have two identities, and callbacks are strings

`StopConversation` and `InterruptConversation` each dispatch on arg 1's *type*: a string routes to one
engine function (`FUN_0094d650` / `FUN_0094d6c0`), a number to a different one (`FUN_0094c670` /
`FUN_0094adc0`). A conversation therefore has both a **name** (authoring identity, stable across sessions)
and a runtime **integer ID** (`Cin.GetHumanConversationID`, `Cin.ConversationConditionPassed`). This is the
same name-vs-handle split the [handle model](03-handle-and-object-model.md) describes for objects, solved
the same way and for the same reason: the name survives save/load, the ID does not.

The callback convention is the standard one from [ABI §10](02-marshalling-abi.md) — a **dotted name
string**, never a function. `Includes/__UtilFunctions.lua:752` shows the full four-slot form:

```lua
Cin.PlayConversation(sBestConv, "ConvManager.SetConvDone", nil, {self, sBestConv, true})
```

`nil` in the `tSelf` slot is legal precisely because `FUN_006f71c0(3)` is a bare presence-and-type test with
no `else` branch — an absent or nil arg 3 just skips the bind. `Sound.LoadSoundBank` carries the same
`(sCallback, tSelf, tArgs)` tail, which is how an async bank load reports completion.

The two are **not** identical in how they police the callback, and the difference is worth recording because
an earlier draft of this doc had it backwards. Only `Sound.LoadSoundBank` (`0x007449b0`) validates the dot,
with `pcVar6 = _strstr(_Str,"."); if (pcVar6 == NULL) goto LAB_00744b11;` — a missing dot skips the bank
load's callback bind entirely. `Cin.PlayConversation` (`0x0071dfe0`) has **no `_strstr` call at all**: it
checks only that arg 2 is a non-empty string (`pcVar5 != NULL && *pcVar5 != '\0'`) before handing it to
`FUN_0070a180`. A dotless conversation callback is therefore accepted by the binding where a dotless bank
callback is not; what `FUN_0070a180` then does with it is **open** (its body was not read for this doc).

### `SetMusicLocale` is two functions sharing a name

The 1-arg and 2-arg branches call **different engine functions** (`FUN_00911400` vs `FUN_00911440`) and
mean different things. The corpus separates cleanly:

| Arity | Argument shape | Distinct corpus values |
|---|---|---|
| 1 | a **locale** | `"A1M1_Race"`, `"A1M2_Barfight"`, `"Belle_De_Nuit"`, `"Default"`, … |
| 2 | a **State Group + State** | `("Cinematic","In")`, `("fp_P1FP_Traitor","disguised")`, `("fp_CountryRace1","startRace")`, `("fp_P1FP_DestroyConvoy","truckDestroyed")`, … |

The 2-arg form is a Wwise **State** set, not a locale set at all — `("Cinematic","In")` is the *same pair*
`Cin.SetExitMusicOverride` stores in its args 2–3, and the same `(group, state)` shape `Sound.SetState`
takes. So three bindings converge on one Wwise concept. The 1-arg form's `"Default"` and
`ResetMusicLocale`'s hardcoded `"default"` are the same value, confirming `ResetMusicLocale()` ≡
`SetMusicLocale("default")` + a state reset (`"intensity"`).

*Inferred:* the naming is a leftover — `SetMusicLocale` grew a State overload rather than getting its own
binding. Note the freeplay convention (`fp_<mission>` groups with per-beat states like `arriveAtTrucks`,
`grabBottle`, `timeLapse`) is the clearest surviving evidence of how the dynamic score was authored:
one State Group per freeplay mission, one State per narrative beat.

### Two false friends worth naming

**`Combat.BroadcastSound` makes no sound.** Its body ends at `FUN_00898a30`, nowhere near the `0x0091xxxx`
Wwise wrappers. It reads a world position — either three floats, or a handle via vtable`+0x14` (position
getter) — and broadcasts an **AI perception stimulus**. `Missions/Paris_1_Mission_1.lua:768` —
`Combat.BroadcastSound(hSoundOrigin, 75, 100, false)` — alerts guards; it does not play audio. The two arities share code via an index cursor (`iVar3 = 2` for the
handle form, `4` for the float form), which is why `(hOrigin, f, f, [b])` and `(fX, fY, fZ, f, f, [b])` both
work. `Combat.SetRespondToSound` is its receiver-side switch (bit 1 of `+0x228`) and is likewise pure AI.
[`sound.md`'s gap list](../symbol_map/sound.md) suggests `WSSoundTrigger`/`WSSoundTriggerManager` sit behind
these two — **the Lua bindings do not support that**; they reach `FUN_00898a30` directly. Whatever
`WSSoundTrigger` does, `Combat.BroadcastSound` is not its Lua entry point.

**`Sound.SetState` is not the `SetState` in your grep results.** Every `SetState(` hit in the Lua corpus is
`Suspicion.SetState`. `Sound.SetState` has zero call sites.

### A correction to `sound.md`

[`sound.md`](../symbol_map/sound.md)'s "Bank management" heading calls `DAT_01442928` the
**`WSSoundBankManager`** singleton, while its flag list assigns the `+0x11dc` "SoundEngine ready" gate to
**`WSSoundManager`**. `Sound.UnloadSoundBank` (`0x007437c0`) reads `*(char *)(DAT_01442928 + 0x11dc)` **and**
loads `DAT_01442928` into `iVar2` to pass as `FUN_00913df0`'s first argument — one object read at both
offsets, which the two labels cannot both survive.

*Correcting an earlier draft of this section:* `Sound.LoadSoundBank` (`0x007449b0`) does **not** corroborate
this. It reads the `*(DAT_01442928 + 0x11dc)` gate, but its call is `FUN_00914b30(bankName, FUN_00913d20, 0)`
— the singleton is never passed. Only `UnloadSoundBank` carries the double use, and the point rests on it
alone.

The contradiction is in any case **internal to `sound.md`**, and that file already answers it: its own
addendum states "*the global singleton pointer `DAT_01442928` **IS** the `WSSoundManager` instance*",
citing the same `+0x11dc` gate in `LoadBankAsync`. The Lua seam corroborates the addendum over the heading.
*Inferred:* `DAT_01442928` is `WSSoundManager` and the heading is the error; the bank table is reached
through it. The heading should be fixed, not this doc's reading.

### What the family says about game logic

The script layer's audio vocabulary is **declarative and coarse**: name a bank, name an event, name a music
locale, name a conversation. Nothing in the 38 bindings exposes a voice, a bus, a mix, a fade, or a volume.
`Sound.SetParam`/`SetTimedParam` are the only continuous controls and **neither is called anywhere in the
corpus** — the RTPC feeds `sound.md` finds at `0x0042cfd0` / `0x005a9f40` (vehicle RPM) are engine-internal.
Mission designers scheduled audio; they did not mix it.

The dead weight is real, though smaller than an earlier draft of this section claimed. Of 21 `Sound`
bindings, **four are named nowhere in the corpus at all** — `PlayTextID`, `SetParam`, `SetTimedParam` and
`SetState`. The `LoudSpeakers` pair was miscounted here as a fifth and sixth: both are named at
`Managers/RewardsManager.lua:275`/`:622`, as deferred-action references rather than direct calls, so they are
reachable at runtime and are not dead. `PlayMusicStab` has exactly one distinct argument in the whole game
(`"Success_Stab"`). The
`Cin` side is worse: `SetSpeakerWeight`, `GetHumanConversationID`, and `SetEnterMusicOverride` are unused,
and `SetExitMusicOverride` has one site. This is a bound API considerably wider than the game that shipped
on it.

Some of that dead weight is explained rather than merely observed: **`Sound.SetState` is unused because
`Sound.SetMusicLocale`'s 2-arg overload already does it.** Scripts had two doors onto the same Wwise State
mechanism and used the one that was presumably there first. That is redundancy in the API, not an
unfinished feature — and it is a caution against reading "zero call sites" as "cut content".

The `Chatter` toggles are the tell for the ambient-VO design. There is a **Sean-specific** channel
(`EnableSeanChatter`/`DisableSeanChatter`) separate from **all** chatter — the player character's barks were
important enough to gate independently, presumably to silence him during cinematics and scripted VO without
killing world ambience. `Util.SetLastMissionChatter` writing a single global string into save state
(`DAT_01240328 + 0x220c`, fed from `SabTask._tMiscSaveTable.LastMissionChatter`) suggests a
"remember what he last commented on" anti-repeat mechanism that survives reload.

Finally, `Actor.SetTalkable`'s arg 3 being read **only when arg 2 is true** encodes the interaction model:
you don't "make an actor talkable and then set his conversation" — the conversation is part of the same
atomic enable. Disabling (`SetTalkable(h, false)`) takes one argument because the conversation is
meaningless without it.

Be precise about the scope of that gate, though — an earlier draft of this doc overstated it. Only **arg 3
(the conversation)** sits inside the `if (bTalkable)` branch. **Arg 4, the attraction point the player walks
to** (`tConfig.sStarterAttrPt`,
[`Modules/SabTaskObjectiveInteract.lua:43`](../saboteur-luacd/src/Modules/SabTaskObjectiveInteract.lua)), is
fetched *outside* it: the `cVar1 = FUN_006f7160(4)` test follows the arg-2 block at the same nesting level,
so `+0x17c` is writable with `bTalkable` false. Arg 5 is likewise ungated. The atomic-enable reading holds
for the conversation only.

---

## Open questions

1. **Ten missing bodies.** `0x00744e10`–`0x00744e70`, `0x0071ea30`, `0x0071e950`, `0x0071cb20`, `0x0071cc00`
   have no decomp record while `jmp`-shape siblings at `0x007438f0`/`0x007439e0` do. Is this a Ghidra
   analysis gap or a real difference in how these were emitted? A raw disassembly of those ~0x60 bytes would
   settle all six toggles at once — and they are almost certainly trivial.
2. **`Cin.SetSpeakerWeight` is completely dark** — no body, no call site, no string. Given `"Speaker%d"`,
   *inferred:* it biases which speaker a conversation prefers, or their audio prominence. Pure speculation.
   It and `Cin.GetHumanConversationID` are the only two rows in the family with **no evidence of any kind**
   beyond their registration entry.
3. **The `ReleaseSoundBank` / `UnloadSoundBank` flag.** Both call `FUN_00913df0`; the 4th argument is
   Lua-controlled (inverted) in one and hardcoded `1` in the other. What does it select? And why does
   `ReleaseSoundBank` skip the `+0x11dc` engine-ready gate that `UnloadSoundBank` checks?
4. **`Sound.SetTimedParam`'s four floats.** `FUN_00918be0(name, f, f, f, f, 0xffffffff)` — with zero call
   sites, the parameter roles are unrecoverable from this side. `FUN_00918be0`'s own body would tell.
5. **`DAT_01442928`'s true class** — see the `sound.md` correction above. Largely **answered on
   verification**: `sound.md`'s own addendum already asserts `DAT_01442928` **is** the `WSSoundManager`
   instance, contradicting only its own "Bank management" heading. What remains open is narrower — where the
   bank table actually lives relative to that singleton.
6. **Do `FUN_00911440` and `FUN_00918540` converge?** `Sound.SetMusicLocale`'s 2-arg branch reaches
   `FUN_00911440`; `Sound.SetState` reaches `FUN_00918540`, which [`sound.md`](../symbol_map/sound.md)
   identifies as `SetState`. Both take a `(group, state)` string pair from Lua. If they bottom out in the
   same `AK::SoundEngine::SetState`, the redundancy above is proven rather than inferred. One level of
   callee-walking would settle it.
7. **The second music backend.** `SetMusicLocale` and `ResetMusicLocale` both branch on
   `FUN_009bbb20(0x22)` (subsystem 0x22) plus `piVar[0x2c]==1`, a vtable`+8` predicate, and
   `thunk_FUN_004f42ed` — choosing `FUN_00784860`/`FUN_00784880` over `FUN_00911400`/`FUN_00911440`.
   **There are two complete music implementations behind one binding.** What is subsystem 0x22 — a
   cinematic music director, a demo/attract mode, a replay recorder? Not addressed by `sound.md`.
8. **`Cin.SetEnterMusicOverride`'s four strings.** The exit variant has one call site
   (`"cin_116_CinB_FollowD", "Cinematic", "In", "Cinematic"`); the enter variant has none. Arg 4 duplicating
   arg 2's value in the only sample makes its role unguessable.
9. **`FUN_006f78b0` is undocumented.** It is a real marshalling primitive (Lua array-element → lightuserdata
   + ok-flag) found only via `PlayConversationWith`. How many other bindings iterate tables this way? A
   caller sweep would extend the ABI doc.
10. **Were the three type-mismatch call sites ever noticed?** `Act_1_Race.lua:1010/1020` and
   `Act_3_Mission_3.lua:2088` are dead by the type rules. Confirming them at runtime (breakpoint on
   `0x00743b90`, check `FUN_006f71a0`'s return) would turn an inference into an observation — and the
   [2008 prototype build](../../data/) diff might show whether they ever worked.
11. **`Sound.PlayTextID` vs. `Cin.GetLocalizedText`.** `FUN_0095e4e0` is shared with the excluded text
   family. Mapping that store would tie VO playback to subtitle text and probably to `WWiseIDTable.bin`.
