# The Saboteur — Engine Symbol Map

Subsystem-by-subsystem catalog of the WildStar/Odin engine, recovered from the clean `Saboteur.exe` decomp. Each subsystem was documented by a dedicated agent and then checked by an adversarial verifier (categorize → document → verify/seam workflow).

> **Key enabler:** the retail decomp retains the original EA Los Angeles build's `__FILE__` / `__FUNCTION__` assertion strings (build root `C:\EALA-BUILD-SAB1\p4\Ref_Sab_POV\wildstar\POV\code\WildStar\...`) — e.g. `WSAIPanicker.cpp` immediately followed by `"WSAIPanicker::Update"` inside the function body. These pin `FUN_` VAs to real `Class::Method` names directly, without the RTTI vtable→VA map.

> **Confidence tiers — read before trusting a VA.** ⚠️ **VA existence and name attribution are two
> different things, and this catalog is far stronger on the first than the second.** Measured against
> the decomp: **553 of the 554 cited VAs exist (99.8%)**, but only **126 of 290 key functions (43%)
> carry a `Class::Method` assertion string**. The rest are *proposals* inferred from caller/callee
> chains, string proximity and Lua-corpus behaviour matches.
>
> The assertion strings form a hard backbone of **204 distinct `WS*::Method` names (216 including
> `hka*`/`Pcl*`/`AK::`) across 111 `.cpp` files** — those labels are as good as symbols. Everything
> beyond them is not. **"Confirmed" in the table below means the verifier confirmed the VA exists and
> plausibly matches its role — it is NOT proof of method identity.** An assertion string also only
> proves *which `.cpp` a function was compiled from*, not that its body implements the claimed
> behaviour.
>
> The **Pinned** column is the one to trust. Where it is low, treat the whole doc's naming as a
> hypothesis.

| Subsystem | Doc | Pinned (string-anchored) | VA exists | Verdict | Key fns | Classes |
|---|---|---|---|---|---|---|
| [AI & Behavior](ai-behavior.md) | `ai-behavior.md` | **23 / 23** ✅ | 30/30 | solid | 23 | 79 |
| [Human, Ragdoll & Disguise](human-disguise.md) | `human-disguise.md` | 18 / 25 | 40/40 | solid | 25 | 41 |
| [Damage, Physics & Explosion](damage-physics.md) | `damage-physics.md` | 17 / 22 | 49/49 | solid ⚠️ | 22 | 49 |
| [Animation (Havok 6.5 edge)](animation.md) | `animation.md` | 7 / 17 | 34/35 | solid | 17 | 30 |
| [Vehicle & Train](vehicle-train.md) | `vehicle-train.md` | 3 / 20 | 46/46 | ⚠️ see doc | 17 | 43 |
| [Camera](camera.md) | `camera.md` | 3 / 21 | 45/45 | ⚠️ see doc | 21 | 23 |
| [Cinematics](cinematics.md) | `cinematics.md` | 12 / 22 | 52/52 | ⚠️ see doc | 22 | 44 |
| [Render, Particle, Light & Fx](render-fx-light.md) | `render-fx-light.md` | 1 / 13 | 26/26 | inferred | 13 | 31 |
| [Sound (Wwise)](sound.md) | `sound.md` | **0 / 22** ❌ | 39/39 | **inferred — no anchors exist** | 22 | 14 |
| [Task graph, Managers & Streaming](task-managers.md) | `task-managers.md` | 6 / 11 | 20/20 | solid | 11 | 43 |
| [Mission, Objective & Trigger](mission-objective.md) | `mission-objective.md` | 1 / 14 | 28/28 | inferred | 14 | 18 |
| [Perks, Weapons & Inventory](progression.md) | `progression.md` | 16 / 24 | 50/50 | solid | 20 | 31 |
| [Suspicion, Alarm & Will-to-Fight](suspicion-wtf.md) | `suspicion-wtf.md` | 4 / 17 | 28/28 | inferred | 17 | 13 |
| [HUD & UI (Scaleform)](hud-ui.md) | `hud-ui.md` | 7 / 20 | 31/31 | ⚠️ see doc | 19 | 61 |
| [World, Water, Terrain & Props](world-water.md) | `world-water.md` | 8 / 19 | 35/35 | solid | 19 | 26 |

**Totals:** 15 subsystems · **554 VAs cited, 553 exist (99.8%)** · **126 / 290 key functions
string-pinned (43%)**. The single non-existent VA (`FUN_00f22470`, `animation.md`) is FPU-heavy and
absent from the Ghidra export by design — see `docs/formats/animation_havok65.md`.

> **`sound.md` needs the loudest caveat.** There is **not one** `WSSound*::` assertion string anywhere
> in the 54 MB decomp (verified: 0 matches), and none of its 22 VAs appear in
> `data/symbol_map/pc_symbol_map.tsv`. Every `WSSoundManager::` / `WSSoundEmitter::` label there is a
> behavioural inference from the wrapped `AK::` call. `WSSoundManager` also has only 3 vtable slots,
> so the RTTI map will not rescue it.

## Method & provenance

- Evidence per function: an assertion string (`Class.cpp` + `"Class::Method"`) inside the body, a caller/callee chain from the decomp's `callers=[..]` lists, a string anchor, or a behavior match against the decompiled Lua corpus (`docs/saboteur-luacd/src`).
- Lua binding families (`Nav.*`, `Combat.*`, `Vehicle.*`, …) front each subsystem; see per-doc "Lua API surface" sections.
- Generated from a 30-agent workflow (15 document + 15 verify). Regenerate/extend by editing the workflow script and re-running.
- **Ground truth is the decomp in the *sibling* repo** (`notes-on-the-released-game/output/_ghidra_saboteur/…`), not this one — see `AGENTS.md`.

> ### ⚠️ Two traps when reading the per-doc "Lua API surface" sections
>
> **1. `data/lua_bindings.txt` holds C++ symbols, not Lua-callable names — 256 of the 898 differ.**
> Looking up a Lua name there and not finding it proves nothing. `Squad.Create` is absent from it;
> the C++ symbol is `CreateSquad`. Always use **`data/lua_registration_map.tsv`**, which carries the
> Lua table, the Lua name, the C++ symbol and the VAs together. This single confusion produced
> several wrong "corrections" across these docs (see the retraction in
> [`ai-behavior.md`](ai-behavior.md)) — one of which would have swapped two live bindings.
>
> **2. The "Verification (adversarial pass)" sections were appended, not folded in.** Where a
> verifier refuted a body claim, the body was generally left as written. Refuted claims are now
> marked inline with **⚠️ REFUTED**, but if you are reading a section without such a marker, still
> check the doc's verification section before relying on a *role* description. And note the verifier
> is not automatically right — in `ai-behavior.md` it was the verifier that was wrong.

## ✅ Stale gap, repeated in every doc: "no RTTI vtable→VA map yet"

Every document below carries a Gaps line of the form *"no RTTI vtable→VA map yet"* / *"the
registration table that maps each name to its C thunk was not located"* / *"needs the pending
vtable→VA map"* (≈20 such lines across the 15 docs). **All of those were written before the maps
existed, and are stale as of 2026-07-16/24.** The docs date to 2026-07-12; the artifacts landed after.

| What the gap lines ask for | Where it now is |
|---|---|
| RTTI vtable → function VA | [`data/symbol_map/pc_vtables.tsv`](../../data/symbol_map/pc_vtables.tsv) — **2,586 classes / 81,561 slots** (`class`/`slot`/`method_va`/`vtable_va`) |
| Assert-derived function names | [`data/symbol_map/pc_symbol_map.tsv`](../../data/symbol_map/pc_symbol_map.tsv) — 1,414 rows, **0 duplicate VAs** |
| Lua binding name → C thunk → impl | [`data/lua_registration_map.tsv`](../../data/lua_registration_map.tsv) — all **898** bindings with `impl_va`/`thunk_va`/`vtable_va` |

Spot-check of classes these docs said needed the map: `WSPerksManager` 180 slots, `WSGameCamera` 181,
`WSTriggerManager` 180, `WSHumanStateDisguise` 21. **The promotion pass README:7 promised has not been
run** — treat that as the open task, not the map's absence.

⚠️ One caveat before assuming the map rescues everything: `pc_vtables.tsv`'s `rtti_vtable` /
`rtti_exact` names are **slot-declaring-class** names, which need not describe a derived override's
behaviour (e.g. `FUN_00937c90` is tagged `hkUnaryAction::getEntities` but its body is a water-action
update). And it will **not** rescue [`sound.md`](sound.md): `WSSoundManager` has only 3 vtable slots.

## Known-wrong entries (do not propagate)

Confirmed against the decomp on 2026-07-24; each is marked inline in its doc.

| Doc | Claim | Reality |
|---|---|---|
| [`cinematics.md`](cinematics.md) | `FUN_009ccf30` = `WSMissionMessengerManager::AttemptDeliveryWithCurrentMessenger` | That method is **`FUN_009d0100`** (assertion strings at decomp lines 863575/863582), as [`mission-objective.md`](mission-objective.md) and `pc_symbol_map.tsv` both say. `FUN_009ccf30` is unnamed; its only string is `%sdata01.bin`. |
| [`vehicle-train.md`](vehicle-train.md) | `FUN_00422e90` = `WSVehicleSkidManager` | It is the renderer's drawlist/bucket registrar (~200 render-pass names: `Begin Far Zpass`, `AtmosphereBucket`, …). `"VehicleSkid"` is one bucket among them. [`world-water.md`](world-water.md) names the same VA correctly as `World_BuildRenderPasses`. |
| [`hud-ui.md`](hud-ui.md) | `FUN_00db7e10` = `LocalizedString_Fetch` | It is `HashedString`'s constructor — `FUN_00db7c10` → `FUN_00dc1e20` = `pandemic_hash`. It returns no string; it writes a hash to an out-param. `camera.md`, `vehicle-train.md`, `cinematics.md` and `suspicion-wtf.md` all describe it correctly. |
| [`damage-physics.md`](damage-physics.md) | "**Every** VA below carries an inline assert string … ground truth, not guesses" | False for 5 of 22 (`FUN_004886b0`, `FUN_00666b20`, `FUN_0099bc00`, `FUN_006c4030`, `FUN_006c4140`). The doc contradicts itself at its own line 83. |
