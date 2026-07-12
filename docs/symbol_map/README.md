# The Saboteur — Engine Symbol Map

Subsystem-by-subsystem catalog of the WildStar/Odin engine, recovered from the clean `Saboteur.exe` decomp. Each subsystem was documented by a dedicated agent and then checked by an adversarial verifier (categorize → document → verify/seam workflow).

> **Key enabler:** the retail decomp retains the original EA Los Angeles build's `__FILE__` / `__FUNCTION__` assertion strings (build root `C:\EALA-BUILD-SAB1\p4\Ref_Sab_POV\wildstar\POV\code\WildStar\...`) — e.g. `WSAIPanicker.cpp` immediately followed by `"WSAIPanicker::Update"` inside the function body. These pin `FUN_` VAs to real `Class::Method` names directly, without the RTTI vtable→VA map.

> **Confidence tiers — read before trusting a VA.** The assertion strings form a hard backbone of **199 distinct `WSClass::Method` names across 98 `.cpp` files** — those labels are as good as symbols. The catalog below pins **more** functions than that (via caller/callee chains, string proximity, and Lua-corpus behavior matches), so a labelled VA is either *assertion-anchored* (trust it) or *inferred* (a proposal). The adversarial "confirmed" count means the verifier confirmed the VA **exists and plausibly matches** its role — it is not proof of the exact method identity for inferred entries. A completed `tools/rtti_symbol_map.py` (RTTI vtable→VA) will promote many inferred labels to hard IDs.

| Subsystem | Doc | Confidence | Verdict | Key fns (confirmed) | Classes |
|---|---|---|---|---|---|
| [AI & Behavior](ai-behavior.md) | `ai-behavior.md` | high | solid | 23 (23) | 79 |
| [Human, Ragdoll & Disguise](human-disguise.md) | `human-disguise.md` | high | solid | 25 (25) | 41 |
| [Damage, Physics & Explosion](damage-physics.md) | `damage-physics.md` | high | solid | 22 (22) | 49 |
| [Animation (Havok 6.5 edge)](animation.md) | `animation.md` | medium | solid | 17 (17) | 30 |
| [Vehicle & Train](vehicle-train.md) | `vehicle-train.md` | medium | solid | 20 (18) | 43 |
| [Camera](camera.md) | `camera.md` | medium | solid | 21 (21) | 23 |
| [Cinematics](cinematics.md) | `cinematics.md` | high | solid | 22 (22) | 44 |
| [Render, Particle, Light & Fx](render-fx-light.md) | `render-fx-light.md` | medium | solid | 13 (13) | 31 |
| [Sound (Wwise)](sound.md) | `sound.md` | high | solid | 22 (22) | 14 |
| [Task graph, Managers & Streaming](task-managers.md) | `task-managers.md` | medium | solid | 11 (11) | 43 |
| [Mission, Objective & Trigger](mission-objective.md) | `mission-objective.md` | medium | solid | 14 (14) | 18 |
| [Perks, Weapons & Inventory](progression.md) | `progression.md` | medium | solid | 20 (20) | 31 |
| [Suspicion, Alarm & Will-to-Fight](suspicion-wtf.md) | `suspicion-wtf.md` | high | solid | 17 (17) | 13 |
| [HUD & UI (Scaleform)](hud-ui.md) | `hud-ui.md` | high | solid | 20 (19) | 61 |
| [World, Water, Terrain & Props](world-water.md) | `world-water.md` | medium | solid | 19 (19) | 26 |

**Totals:** 15 subsystems, 286 key functions pinned, 283 adversarially confirmed.

## Method & provenance

- Evidence per function: an assertion string (`Class.cpp` + `"Class::Method"`) inside the body, a caller/callee chain from the decomp's `callers=[..]` lists, a string anchor, or a behavior match against the decompiled Lua corpus (`docs/saboteur-luacd/src`).
- Lua binding families (`Nav.*`, `Combat.*`, `Vehicle.*`, …) front each subsystem; see per-doc "Lua API surface" sections.
- Generated from a 30-agent workflow (15 document + 15 verify). Regenerate/extend by editing the workflow script and re-running.
