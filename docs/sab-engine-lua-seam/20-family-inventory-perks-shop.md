# Family: Inventory, perks, shops & collectables

> **Verified:** All 37 VA→name pairings re-checked against `data/lua_registration_map.tsv`; every
> decomp VA, callee, `DAT_` global and exe string literal cited below re-grepped and found; the
> `EnableAmmoDrops`, `SetupShop` and `GiveAmmo` defects independently reproduced from
> `Saboteur.exe` bytes with capstone; all 28 spot-checked corpus citations exist and say what is
> claimed. **Corrected:** corpus-usage counts were name occurrences (calls *plus* table-value
> references) presented as call sites — convention now stated and each figure split;
> `HolsterWeaponImmediate` (4 sites) and `SetDropWeaponWhenRagdolled` (1 site) were wrongly marked
> "0 corpus sites"; zero-usage tally 11→10; `AddToShop` 4→5 call sites; `GetCountOfType` 14→16;
> `RemoveAllWeapons` 25→22; `UnlockShopLabel` "second-most-used"→third; the `FUN_00733100` gap-end
> arithmetic (`0x73321E`→`0x733216`) and the defect-2 listing's fallback address.

The player-facing economy seam: what an actor carries, what contraband buys, which perks are
unlocked, and what a shopkeeper sells. `Script\Interface\Inventory.cpp` is the anchor file.

Engine-side background (the C++ layers under these bindings) is already written up in
[`docs/symbol_map/progression.md`](../symbol_map/progression.md); this document covers only the
**binding layer** and does not repeat it. Read the ABI first:
[`02-marshalling-abi.md`](02-marshalling-abi.md).

## Inclusion rule (auditable)

`data/lua_registration_map.tsv` is the authority for names. I selected:

1. **Every binding whose `table` is `Inventory`** (18) — the anchor module.
2. **Perk economy** — `Util` bindings whose `cpp_symbol` contains `Perk` (4).
3. **Shop economy** — every binding whose `cpp_symbol` contains `Shop`, in any table (7: 5 in
   `Util`, 2 in `Actor`).
4. **Collectables** — `Freeplay` bindings whose `cpp_symbol` contains `Collectable` (3).
5. **Contraband HUD** — `HUD.AddContraband` (1), the contraband award notifier.
6. **Actor weapon carriage** (4) — `FireCurrentWeapon`, `GetWeaponPitch`,
   `HolsterWeaponImmediate`, `SetDropWeaponWhenRagdolled`. These live in the `Actor` table and are
   *claimed here* because they drive `WSInventory`'s stow state machine, not the combat AI. This is
   the one genuinely ambiguous edge of the family; the sibling actor family may also claim them.

**Total: 37.**

Explicitly **excluded**, with reasons (not silent omissions):

| Excluded | Why | Covered by |
|---|---|---|
| The whole `Combat` table — incl. `ThrowGrenade`, `GlobalAllowGrenades`, `SetIdleHoldWeapon`, `SetBroadcastWeaponFire` | grenades/fire policy are combat-AI policy, and the sibling doc already claims the entire table | [`11-family-ai-squad-combat.md`](11-family-ai-squad-combat.md) |
| `Train.TrainRegisterTrain{Ammo,Item,Weapon}Callback` | `Train`-table callback registration, already documented | [`13-family-vehicle-train-plane.md`](13-family-vehicle-train-plane.md) |
| `Object.SetGrenadeToExplode`, `Actor.PlayerOnSabSetGrenadeToExplode` | detonator ordnance, not inventory containment | unclaimed — flagged in Open questions |

## Coverage honesty

**37 of 37 bindings in this family located.** Every one has a byte-level signature.

> **Coverage update (post-verify).** A later pass appended
> [The `Freeplay` table — ambient events](#the-freeplay-table--ambient-events), adding the **17
> orphaned `Freeplay` bindings** that appeared in no family doc. **Doc total: 54** (37 verified here
> + 17 in the appended section). The three collectable rows and `BlockZoneForSave` are cross-linked
> there rather than re-counted. That section was **not** covered by the verify pass recorded at the
> top of this doc; the 37 figure above and everything else in this section remain as verified.

- **1 confirmed by assertion string** — `DetachItem`, which is the *only* binding in the family
  carrying an EALA assertion (`Script\Interface\Inventory.cpp:351`). The family is essentially
  assertion-free; §9 of the ABI ("only 12 of 898 carry one") holds hard here.
- **36 confirmed by byte-level disassembly** — I did not rely on the Ghidra pseudocode for
  signatures. Argument indices were read as literal `push <k>` operands directly out of
  `Saboteur.exe` before each `FUN_006f7*` primitive call. This matters: **5 of the 18 `Inventory`
  bindings are absent from the 54 MB decomp dump entirely** (`GetCountOfType` `0x00732df0`,
  `GetItemOfType` `0x00732f70`, `HasItem` `0x00732c80`, `HasWeapon` `0x00733c50`, `List`
  `0x00733220`). They are real functions sitting in un-exported gaps — e.g. `FUN_00733100`
  (`size=278`) ends at `0x00733216` and the next header is `0x00733350`, so `List` at `0x00733220`
  falls in the hole. I recovered all five from the exe bytes.
- **0 not found.**
- **A caveat on what "confirmed" covers here.** Byte-level disassembly confirms each *signature*.
  It does not by itself prove *identity* — that a given VA is the binding named. For the 36
  assertion-free rows identity rests on `data/lua_registration_map.tsv` (`impl_va` → `table`/
  `cpp_symbol`), which is this doc's stated authority and was re-verified row-by-row, but it is a
  derived artifact, not an in-binary string. Only `DetachItem` is self-identifying.
- **Semantics** (what each engine callee *does*) are tiered per row and are largely **inferred**.
- **27 of 37 have Lua usage**; 10 have **zero** corpus usage (`EnableAmmoDrops`, `GetMaxDollars`,
  `HasWeapon`, `List`, `ListOfType`, `SetMaxDollars`, `UnlockPerk`, `UnlockPerkReward`, `IsAShop`,
  `ShopMacro` — absence is itself evidence).

**Counting convention** (matters — the raw figures below were originally ambiguous): a *call site*
is a literal `Table.Name(` in the corpus. A *table-value reference* is a bare `Table.Name,` passed
as a function value — overwhelmingly into `RewardsManager`'s reward-dispatch tables, where it is
invoked indirectly with arguments supplied by the table. Both are real usage, but they are not the
same thing, so they are reported separately (`N calls + M refs`) rather than summed.

Reproduction: VA→file-offset via the PE section table, then capstone in 32-bit mode over
`size=` bytes taken from the decomp header.

## The table

`Namespaced form` is what scripts actually call. Note the C++ symbol and the Lua name are identical
for all 37 here **except `HUDAddContraband` → `HUD.AddContraband`** — do not generalise that to
other families (§0: 256 of 898 differ).

Signature notation: `h` handle (lightuserdata), `s` string, `n` number, `b` boolean, `t` table.
`[x]` optional. Per §6, `LuaGlueFunctor0` (adapter) bindings return **no meaningful value** even
though the thunk claims 1 result; only `LuaGlueFunctor0R` (jmp) rows genuinely return.

### Inventory core (18)

| Binding | Namespaced form | VA | Source (file:line) | Signature | Confidence | Evidence |
|---|---|---|---|---|---|---|
| `DetachItem` | `Inventory.DetachItem` | `0x007334c0` | `Script\Interface\Inventory.cpp:351` | `(hActor, hItem [, b]) -> ()` | **confirmed** | assertion string `"DetachItem"`, `uStack_4 = 0x15f`; arg 3 is type-checked with no argc gate and defaults false, so it is optional; 3/3 call sites pass exactly 3 args — [`Paris_4_Mission_1B.lua:303`](../saboteur-luacd/src/Missions/Paris_4_Mission_1B.lua#L303) |
| `EnableAmmoDrops` | `Inventory.EnableAmmoDrops` | `0x007322b0` | — | `(b, <any>) -> ()` — **see defect below** | **confirmed** (bytes) | `cmp eax,1; jle 0x732319` @`0x7322f6`; writes `DAT_012119e0`. **0 corpus sites** |
| `GetAmmoCount` | `Inventory.GetAmmoCount` | `0x007337d0` | — | `(hActor, hItem\|sType) -> n` | **confirmed** | `isHANDLE(1)`, `isHANDLE(2)`/`isstr(2)`, `pushnum` @`0x7338b9`; [`Saboteur.lua:268`](../saboteur-luacd/src/Modules/Behavior/Player/Saboteur.lua#L268) |
| `GetCountOfType` | `Inventory.GetCountOfType` | `0x00732df0` | — | `(hActor, sType) -> n` | **confirmed** (bytes; not in decomp dump) | `isHANDLE(1)` @`0x732e37`, `toSTR(2)` @`0x732ec3`; 16 call sites — [`Act_3_Mission_3.lua:165`](../saboteur-luacd/src/Missions/Act_3_Mission_3.lua#L165) |
| `GetItemOfType` | `Inventory.GetItemOfType` | `0x00732f70` | — | `(hActor, sType) -> h \| nil` | **confirmed** (bytes; not in decomp dump) | `isHANDLE(1)`, `isstr(2)` @`0x733042`; used truthily — [`Paris_3_Mission_1.lua:1593`](../saboteur-luacd/src/Missions/Paris_3_Mission_1.lua#L1593) |
| `GetMaxDollars` | `Inventory.GetMaxDollars` | `0x00732240` | — | `() -> n` | **confirmed** | zero args; reads global `DAT_01494320`, `pushnum` @`0x732296` |
| `GetMoney` | `Inventory.GetMoney` | `0x00732140` | — | `() -> n` | **confirmed** | zero args; reads global `DAT_01494324`; [`Connect_P2Papers.lua:32`](../saboteur-luacd/src/Missions/Connect_P2Papers.lua#L32) |
| `GiveAmmo` | `Inventory.GiveAmmo` | `0x00733640` | — | `(hActor, hItem\|sBlueprint, nCount)` — **`nCount > 0` enforced** | **confirmed** | `isHANDLE(1)`, `isnum(3)`+`toINT(3)` with `0 < iVar2`, `isHANDLE(2)`/`isstr(2)`; [`RewardsManager.lua:4555`](../saboteur-luacd/src/Managers/RewardsManager.lua#L4555) |
| `GiveItem` | `Inventory.GiveItem` | `0x00732990` | — | `(hActor, hItem\|sBlueprint, bEquip [, nCount])` | **confirmed** | indices read from bytes: `isHANDLE(1)`, `isbool(3)`, `cmp eax,3` → `isnum(4)`, `isHANDLE(2)`/`isstr(2)`. **116 call sites + 9 refs** — the family's most-used binding — [`Act_1_Farm.lua:630`](../saboteur-luacd/src/Missions/Act_1_Farm.lua#L630) |
| `GiveMoney` | `Inventory.GiveMoney` | `0x00733910` | — | **two overloads** — `(nAmount [, sLabel])` player award; `(hActor\|sName, nCount)` targeted | **confirmed** | `isnum(1)` branch vs `isHANDLE(1)`/`isstr(1)` branch @`0x73395c`/`0x7339cf`; corpus only ever uses overload 1 — [`RewardsManager.lua:4749`](../saboteur-luacd/src/Managers/RewardsManager.lua#L4749) |
| `HasAnyGuns` | `Inventory.HasAnyGuns` | `0x00733100` | — | `(hActor) -> b` | **confirmed** | `isHANDLE(1)`; `FUN_00498f10(0/1/2)` — three slots; `pushboolean`; [`BelleInteriorSceneManager.lua:778`](../saboteur-luacd/src/ScriptControllers/BelleInteriorSceneManager.lua#L778) |
| `HasItem` | `Inventory.HasItem` | `0x00732c80` | — | `(hActor, hItem) -> b` | **confirmed** (bytes; not in decomp dump) | `isHANDLE(1)` @`0x732cca`, `toHANDLE(2)` @`0x732d57` → `FUN_0067c0a0`. Takes a **handle**, not a name — [`P2FP_MadeleineSniper.lua:293`](../saboteur-luacd/src/Missions/P2FP_MadeleineSniper.lua#L293) wraps in `Handle(...)` |
| `HasWeapon` | `Inventory.HasWeapon` | `0x00733c50` | — | `(hActor) -> b` | **confirmed** (bytes; not in decomp dump) | `isHANDLE(1)` only @`0x733c91`; `FUN_0049a420` + `FUN_00498f10` ×2. **0 corpus sites.** Despite the name it takes **no weapon argument** |
| `HolsterWeapons` | `Inventory.HolsterWeapons` | `0x00733b90` | — | `(hActor) -> ()` | **confirmed** | `isHANDLE(1)` → `FUN_004f29b0` (stow FSM); 3 call sites + 1 ref — [`Act_1_Race.lua:279`](../saboteur-luacd/src/Missions/Act_1_Race.lua#L279) (`Act_1_BarFight.lua:1247` is a table-value reference, not a call) |
| `List` | `Inventory.List` | `0x00733220` | — | `(hActor) -> t` (array of item handles) | **confirmed** (bytes; not in decomp dump) | `isHANDLE(1)`; `FUN_006f69c0` = `lua_createtable`; `FUN_00498f10` slot walk. **0 corpus sites** |
| `ListOfType` | `Inventory.ListOfType` | `0x00733350` | — | `(hActor, sType) -> t` | **confirmed** | `isHANDLE(1)`, `isstr(2)`; `lua_createtable` + `FUN_006f6cc0` (`t[i]=v`). **0 corpus sites** |
| `RemoveAllWeapons` | `Inventory.RemoveAllWeapons` | `0x00733ac0` | — | `(hActor) -> ()` | **confirmed** | `isHANDLE(1)` → `FUN_004f4640` (a `jmp` thunk to `FUN_00663390` — Ghidra renders the call as `thunk_FUN_00663390`, so `0x004f4640` has no header in the dump), then `FUN_00499d50` (a `WSInventory.cpp` function); 22 call sites |
| `SetMaxDollars` | `Inventory.SetMaxDollars` | `0x007321b0` | — | `(n) -> ()` | **confirmed** | `isnum(1)`+`toFLOAT(1)` → `FUN_009929f0`. **0 corpus sites** |

### Perks (4)

| Binding | Namespaced form | VA | Source (file:line) | Signature | Confidence | Evidence |
|---|---|---|---|---|---|---|
| `SendPerkMessage` | `Util.SendPerkMessage` | `0x00751d70` | — | `(sMessage) -> ()` | **confirmed** | `isstr(1)` only; 10× `FUN_009da510` dispatch chain. 6 call sites + 22 refs — [`FP_CountryRace_1.lua:249`](../saboteur-luacd/src/Missions/FP_CountryRace_1.lua#L249) `Util.SendPerkMessage("FreeplayRacePlace")` |
| `SetPerkAvailable` | `Util.SetPerkAvailable` | `0x00751f30` | — | `(sPerkName [, bAvailable])` | **confirmed** | `isstr(1)`; `cmp eax,1` → `isbool(2)`; → `FUN_009d5d10`. [`RewardsManager.lua:5300`](../saboteur-luacd/src/Managers/RewardsManager.lua#L5300) `("Perksv3.FriendlyFireTitle", bEnable)` |
| `UnlockPerk` | `Util.UnlockPerk` | `0x00753100` | — | `(nPerk, nTier [, bUnlocked=true])` — **`nPerk < 10`, `nTier < 3`** | **confirmed** | `isnum(1)`+`isnum(2)`; `2 < argc` → `isbool(3)`; bounds `(uVar4 < 10) && (uVar5 < 3)` → `FUN_009d4d30`/`FUN_009da9d0`. **0 corpus sites** |
| `UnlockPerkReward` | `Util.UnlockPerkReward` | `0x007531d0` | — | `(nIndex \| sName [, b])` | **confirmed** (signature) / *inferred* (semantics) | `isnum(1)` vs `isstr(1)` dual branch @`0x753214`/`0x753221`; `cmp eax,1` → `isbool(2)`. **0 corpus sites** |

### Shops (7)

| Binding | Namespaced form | VA | Source (file:line) | Signature | Confidence | Evidence |
|---|---|---|---|---|---|---|
| `SetupShop` | `Actor.SetupShop` | `0x00713110` | — | `(hKeeper, s2, s3, s4, s5, s6, s7)` — **all 7 slots required**, each `nil`-or-string | **confirmed** | fully nested `isnil(k) \|\| isstr(k)` gate for `k`=2..7, then `FUN_00509370(s2..s7)` (6 strings). Only correct call site: [`Shopkeeper.lua:7`](../saboteur-luacd/src/Modules/Behavior/Human/Resistance/Shopkeeper.lua#L7) — **see defect below** |
| `IsAShop` | `Actor.IsAShop` | `0x00713050` | — | `(hActor) -> b` | **confirmed** | `isHANDLE(1)` → `FUN_0083a200` → `pushboolean` @`0x713100`. **0 corpus sites** |
| `SetShopEnable` | `Util.SetShopEnable` | `0x007528f0` | — | `(b) -> ()` | **confirmed** | `isbool(1)`+`toBOOL(1)` only; [`RewardsManager.lua:5047`](../saboteur-luacd/src/Managers/RewardsManager.lua#L5047) |
| `SetShopDisplayLockedByPerks` | `Util.SetShopDisplayLockedByPerks` | `0x00752c40` | — | `(b) -> ()` | **confirmed** | `isbool(1)` → `FUN_009dfb20`; **0 call sites** — its single corpus appearance is a table-value reference ([`RewardsManager.lua:920`](../saboteur-luacd/src/Managers/RewardsManager.lua#L920)) |
| `ShopMacro` | `Util.ShopMacro` | `0x007529d0` | — | `(b) -> ()` | **confirmed** (signature) / *inferred* (semantics) | `isbool(1)` only, then a 12× `FUN_009e1b00` unroll + `FUN_009dfb20` + `FUN_009929f0`. **0 corpus sites** — a debug/cheat bulk-unlock, *inferred* |
| `UnlockShopLabel` | `Util.UnlockShopLabel` | `0x00752e90` | — | `(sLabel [, bUnlock])` | **confirmed** | `isstr(1)`; `cmp eax,1` → `isbool(2)`; → `FUN_009e1b00`. 4 call sites + 22 refs — [`RewardsManager.lua:5050`](../saboteur-luacd/src/Managers/RewardsManager.lua#L5050) |
| `DisableShopKeeperBlip` | `Util.DisableShopKeeperBlip` | `0x00753fa0` | — | `(sName, bDisable)` — **both mandatory** | **confirmed** | `isstr(1)` **&&** `isbool(2)` chained before any fetch (no `gettop` gate, so both are mandatory) → `FUN_009e0470`. 56 call sites + 33 refs |

### Collectables & contraband HUD (4)

| Binding | Namespaced form | VA | Source (file:line) | Signature | Confidence | Evidence |
|---|---|---|---|---|---|---|
| `GetTotalCollectables` | `Freeplay.GetTotalCollectables` | `0x0072ae80` | — | `() -> n` | **confirmed** | zero args; single `pushnum(i)` @`0x72aece`; [`AmbientRubberStamp.lua:538`](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua#L538) |
| `GetNumCollectablesCollected` | `Freeplay.GetNumCollectablesCollected` | `0x0072aee0` | — | `() -> n` | **confirmed** | zero args; single `pushnum(i)` @`0x72af28`; [`AmbientRubberStamp.lua:539`](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua#L539) |
| `SetupCollectableCallback` | `Freeplay.SetupCollectableCallback` | `0x0072bb40` | — | `(sCallbackName, tSelf [, tUser])` | **confirmed** | `isstr(1)`+`toSTR(1)`, `istable(2)`, `istable(3)`; the §10 name-string callback idiom. [`AmbientRubberStamp.lua:284`](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua#L284) |
| `HUDAddContraband` | `HUD.AddContraband` | `0x0072d180` | — | `(nAmount, sText, <ignored>, <ignored>, <ignored> [, bForce])` | **confirmed** | only indices **1, 2, 6** are ever read; `cmp eax,5` → `isbool(6)`. [`AmbientRubberStamp.lua:557`](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua#L557) |

### Actor weapon carriage (4) — boundary rows

| Binding | Namespaced form | VA | Source (file:line) | Signature | Confidence | Evidence |
|---|---|---|---|---|---|---|
| `FireCurrentWeapon` | `Actor.FireCurrentWeapon` | `0x00710d70` | — | `(hActor [, nShots])` | **confirmed** | `isHANDLE(1)`; `isnum(2)`+`toFLOAT(2)` with no argc gate ⇒ arg 2 optional. Corpus uses both forms — [`Act_3_Mission_1_E3.lua:449`](../saboteur-luacd/src/Missions/Act_3_Mission_1_E3.lua#L449) (1 arg), [`Act_3_Mission_2.lua:1631`](../saboteur-luacd/src/Missions/Act_3_Mission_2.lua#L1631) (2 args) |
| `GetWeaponPitch` | `Actor.GetWeaponPitch` | `0x00710e50` | — | `(hActor) -> n` | **confirmed** | `isHANDLE(1)` → `FUN_0044a090`/`FUN_00440a00` → `pushnum(f)` @`0x710f82`; [`Paris_1_Mission_1B.lua:1813`](../saboteur-luacd/src/Missions/Paris_1_Mission_1B.lua#L1813) |
| `HolsterWeaponImmediate` | `Actor.HolsterWeaponImmediate` | `0x00714a60` | — | `(hActor) -> ()` | **confirmed** | `isHANDLE(1)` → `FUN_004f29b0` — **the same stow entry point as `Inventory.HolsterWeapons`**. 4 call sites — [`__UtilFunctions.lua:576`](../saboteur-luacd/src/Includes/__UtilFunctions.lua#L576), `:586`, [`SOE_1_Mission_7b.lua:170`](../saboteur-luacd/src/Missions/SOE_1_Mission_7b.lua#L170), [`Belle_Interior.lua:163`](../saboteur-luacd/src/Modules/InteriorLevels/Belle_Interior.lua#L163) |
| `SetDropWeaponWhenRagdolled` | `Actor.SetDropWeaponWhenRagdolled` | `0x007143d0` | — | `(hActor, b) -> ()` | **confirmed** | `isHANDLE(1)` **&&** `isbool(2)` chained; resolves via `FUN_00498440`. 1 call site — [`Paris_1_Mission_6.lua:895`](../saboteur-luacd/src/Missions/Paris_1_Mission_6.lua#L895) `Actor.SetDropWeaponWhenRagdolled(hVeron, false)` |

## How the subsystem actually works

### An inventory is an array of salted weak references

The single most informative callee in the family is `FUN_00498f10 @0x00498f10`, which every
enumerating binding (`HasAnyGuns`, `HasWeapon`, `List`, `ListOfType`) funnels through. It is a slot
getter, and its body exposes the container layout:

```c
uint __thiscall FUN_00498f10(int inv, int slot)
{
  if (slot < 0) { /* zeroed local */ }
  else puVar3 = (uint *)(*(int *)(inv + 4) + slot * 8);   // array base at inv+4, 8 bytes/entry
  if (puVar3[1] != 0) {
    uVar2 = *puVar3 & 0xffffff;                            // 24-bit slot index
    if ((DAT_01321e98 < uVar2) ||
        ((char)(*puVar3 >> 0x18) != *(char *)(DAT_01321e9c + uVar2)))  // 8-bit generation compare
      puVar3[1] = 0;                                       // poison the cached pointer
  }
}
```

So an inventory holds, at `+4`, an array of 8-byte `{salted_id, cached_ptr}` pairs — **exactly the
handle encoding of §7** (24-bit index | 8-bit generation), with `DAT_01321e9c` as the global
generation table and `DAT_01321e98` as its high-water mark. Items are not owned by pointer; they
are weakly referenced by the same salted ID the script layer passes around, and a dead item
self-poisons its cache slot on next read. This is *inferred* to be `WSInventory`'s storage, on the
evidence that `RemoveAllWeapons` calls `FUN_00499d50`, which carries a
`WildStar\Objects\WSInventory.cpp` assertion path.

`HasAnyGuns` probes exactly slots **0, 1, 2** and ORs the results — three weapon slots, checked
by index, not by search. `HasWeapon` probes `FUN_0049a420` (which itself early-outs on
`FUN_00498f80() > 0`) plus two more slot reads.

### Item identity is dual-mode: handle *or* blueprint name

The family's signature idiom is a two-way check on the item argument — try lightuserdata first,
fall back to string:

```c
if (!FUN_006f71a0(2)) {            // not a handle?
  if (FUN_006f7160(2)) {           // ...then a string
    uVar7 = FUN_006f7a80(2);
    FUN_00db7e10(uVar7, 1);        // copy out of Lua ownership (§8)
  }
} else FUN_006f6ec0(2);            // handle path
```

`GiveItem`, `GiveAmmo`, `GetAmmoCount` and `GiveMoney` all do this. The string form is a
**blueprint name** — `"WP_MG_Thompson"`, `"WP_SAB_BridgeKiller"`, `"WTF_Token"` — resolved through
`FUN_00460980`. This is why the corpus overwhelmingly passes literals rather than handles: names
survive save/load, handles do not (§7). Note the split is not uniform: **`HasItem` accepts only a
handle**, which is why [`P2FP_MadeleineSniper.lua:293`](../saboteur-luacd/src/Missions/P2FP_MadeleineSniper.lua#L293)
must wrap its path in `Handle(...)` while the adjacent `GetCountOfType` takes a bare string.

### Money is contraband, and it is two globals

`GetMoney` and `GetMaxDollars` are the family's simplest bindings, and unusually revealing: they
take **no arguments at all** and read fixed globals — `DAT_01494324` (current) and `DAT_01494320`
(maximum), adjacent words, *inferred* to be one small struct. Both use the standard
unsigned-int→float fixup (`if (x < 0) x += 4294967296.0f`), so both are `uint32`.

There is no "player" argument because there is no concept of *whose* money: contraband is a
process-global scalar. The corpus confirms the identification —
[`Connect_P2Papers.lua:32`](../saboteur-luacd/src/Missions/Connect_P2Papers.lua#L32) reads
`local nContraband = Inventory.GetMoney()`.

`GiveMoney` splits on arg 1's type into two genuinely different operations: a **number** first
means "award contraband to the player" (routed to the HUD via `FUN_009bbb20(6)` → `FUN_0079d700`,
the same pair `HUD.AddContraband` ends with), while a **handle or name** first means "give `n`
units to *that* inventory". The corpus only ever uses the first overload.

### Perks are a 10 × 3 grid

`UnlockPerk` bounds-checks its two integer arguments as `nPerk < 10 && nTier < 3` (unsigned
compares, so negatives wrap and are rejected). That is a concrete game-logic fact recoverable
nowhere else in the seam: **10 perk categories, 3 tiers each**. The `Perksv3.` prefix on every
perk name the corpus passes to `SetPerkAvailable` ("Perksv3.FriendlyFireTitle",
"Perksv3.NotoriousTitle", "Perksv3.DoubleAgentTitle") dates the system to a third design revision.

Perk *presentation* is Flash: the exe carries `exSetPerkLevel`, `exSetPerkRewards`,
`exSetPerkReqs`, `exSetPerkPopupInfo`, `exSetPerkFlavors`, `exSetPerkCategoryTitle` as literals —
consistent with the ActionScript bridge described in
[`progression.md`](../symbol_map/progression.md).

### Shops are unlocked by label, not by object

The shop bindings barely touch shop objects. `UnlockShopLabel(sLabel)` — 4 direct call sites plus 22
reward-table references, the family's third-most-referenced binding after `GiveItem` and
`DisableShopKeeperBlip` — takes a **string label**, and the exe carries the matching
literals: `Shop_Tier1`…`Shop_Tier4`, `Shop_Unlocked`, `Shop_Santos`, `Shop_garage`,
`Shop_Resistance`, `Shop_DynamiteUnlocked`, `Shop_RDXUnlocked`. These match the corpus verbatim
([`RewardsManager.lua:5050-5053`](../saboteur-luacd/src/Managers/RewardsManager.lua#L5050)). The
economy is therefore a **global set of unlocked label strings**, gated by
`SetShopEnable(b)` and `SetShopDisplayLockedByPerks(b)` — both single-boolean, no target. Actual
stock lists live in Lua (`ShopManager.MasterList`), not in the engine.

### `Actor.SetupShop` is not about shop stock — it wires a garage

Despite the name, `SetupShop` passes **no inventory** to the engine. It gathers six `nil`-or-string
arguments and hands exactly those to `FUN_00509370(s2, s3, s4, s5, s6, s7)` (a 7-byte forwarder to
`FUN_004f12a6`). The only call site whose arity matches names them:

```lua
-- Modules/Behavior/Human/Resistance/Shopkeeper.lua:7
Actor.SetupShop(self.hController, self.SMEDTable.sGarageLocatorName,
  self.SMEDTable.sGarageTankLocatorName, self.SMEDTable.sGarageTriggerColbyTag,
  self.SMEDTable.sGarageTankTriggerColbyTag, self.SMEDTable.sGarageMCTrigger,
  self.SMEDTable.sGarageTankMCTrigger)
```

Six garage locator/trigger names. The binding is **garage spawn-point wiring** that happens to hang
off the shopkeeper actor.

## Defects found in retail

These are byte-level readings against retail `Saboteur.exe` plus its own shipped scripts. Because
no binding in this family raises a Lua error (§6), every one of these fails **silently**.

### 1. Four of the five `Actor.SetupShop` call sites are dead

`SetupShop`'s argument gates are **nested**, not independent: arg 3 is only examined if arg 2
passed, and `FUN_00509370` is reached only from the innermost block, after arg 7 clears
`isnil(7) || isstr(7)`. Two consequences, both verified against the primitives themselves
(`FUN_006f7100` is `lua_type(L,n)==0`; `FUN_006f7160` is `lua_isstring`):

- An **absent** argument is `LUA_TNONE` (−1), which is neither `0` nor a string — so it fails
  *both* gates. Trailing arguments cannot be omitted; they must be explicitly `nil`.
- A **table** fails both gates too.

So every call passing a blueprint table no-ops entirely:

| Call site | Args | Fails at |
|---|---|---|
| [`ShopManager.lua:225`](../saboteur-luacd/src/Managers/ShopManager.lua#L225) | `(h, sName, tBlueprintTable)` | arg 3 is a table |
| [`ShopManager.lua:234`](../saboteur-luacd/src/Managers/ShopManager.lua#L234) | `(h, nil, tBlueprintTable)` | arg 3 is a table |
| [`ShopManager.lua:348`](../saboteur-luacd/src/Managers/ShopManager.lua#L348) | `(h, sName, tBlueprintTable, bIsGarage, sGarageName)` | arg 3 table; arg 4 boolean |
| [`SabTaskMission.lua:526`](../saboteur-luacd/src/Modules/SabTaskMission.lua#L526) | `(h, sName, tBlueprintList)` | arg 3 is a table |
| [`Shopkeeper.lua:7`](../saboteur-luacd/src/Modules/Behavior/Human/Resistance/Shopkeeper.lua#L7) | `(h, ×6 strings)` | **— reaches the engine** |

The four table-passing sites are stale calls against an older signature that took a stock list. They
have no effect and no diagnostic. (Shops still work because stock is managed Lua-side; the adjacent
`Actor.AddToShop` those sites call is **not a binding at all** — it is absent from
`lua_registration_map.tsv`, undefined anywhere in the 321-file corpus, and the string `AddToShop`
does not occur in `Saboteur.exe` at all, so it would raise a genuine "attempt to call nil" at
runtime. It is called at **5** sites, all in `ShopManager.lua` (lines 226, 229, 350, 353, 405).
That deserves its own investigation.)

### 2. `Inventory.EnableAmmoDrops` has an off-by-one argument guard

Every variadic binding in the family uses `cmp argc, N-1; jle skip` before reading arg `N`.
`EnableAmmoDrops` uses that guard — but reads arg **1**:

```
007322ef  mov     bl, 1
007322f1  call    0x6f6970          ; lua_gettop
007322f6  cmp     eax, 1
007322f9  jle     0x732319          ; argc <= 1  -> fallback
007322fb  push    1
007322ff  call    0x6f7120          ; lua_type(L,1)==LUA_TBOOLEAN
0073230c  call    0x6f6e60          ; lua_toboolean(L,1)
00732312  mov     byte ptr [0x12119e0], al
00732318  ret
00732319  pop     esi                        ; <-- jle lands here
0073231a  mov     byte ptr [0x12119e0], bl   ; <-- unconditional TRUE
```

The guard was written for an arg-2 pattern and the accessor for an arg-1 one. Net effect:
`Inventory.EnableAmmoDrops(false)` — the natural call — takes the `jle` and stores **`bl` = 1**,
enabling ammo drops. The flag can only be cleared by padding the call
(`Inventory.EnableAmmoDrops(false, 0)`). The flag `DAT_012119e0` has exactly one reader,
`FUN_0049b739 @0x0049b739` (reached from `FUN_004f6906`), in the `WSInventory` address range.

**Never exercised**: the binding has zero corpus call sites, so this bug is latent, not live. It is
worth knowing for anyone scripting against retail.

### 3. `Inventory.GiveAmmo` cannot remove ammo, but a shipped script tries

`GiveAmmo` gates on `toINT(3) > 0`. [`Saboteur.lua:284`](../saboteur-luacd/src/Modules/Behavior/Player/Saboteur.lua#L284):

```lua
function Saboteur.DecrementToken()
  local tSabSelf = Tips.GetSelf("Saboteur")
  if Inventory.GetAmmoCount(tSabSelf.hController, "WTF_Token") > 0 then
    local hToken = Inventory.GiveAmmo(tSabSelf.hController, "WTF_Token", -1)
  end
end
```

`-1` fails the guard, so the call is a no-op and `DecrementToken` never decrements. Worse, `hToken`
is not a handle at all: `GiveAmmo` is a `LuaGlueFunctor0` adapter (nresults hardcoded to 1) that
pushes nothing, so per §6 Lua takes the top-of-stack slot — the binding's own last argument. `hToken`
receives `-1`. Mitigating: this sits in a `Tips`-based debug module, not the shipping gameplay path.

## Open questions

- **Semantics of the perk callees.** `FUN_009d4d30(perk, 0, tier)` returns something that
  `FUN_009da9d0(x, bUnlock, 0)` consumes; `FUN_009d5d10` (`SetPerkAvailable`) and the 10×
  `FUN_009da510` chain in `SendPerkMessage` are unread. What `SendPerkMessage`'s string keys
  ("TimeTrial", "FreeplayRaceWin", "FreeplayRacePlace") index into is **open**.
- **`UnlockPerkReward`'s number branch.** It accepts either an index or a name, but the index
  branch's bound (if any) was not read. Zero corpus sites, so no behavioural cross-check exists.
- **`HUD.AddContraband` args 3–5 are never read** by the binding (only 1, 2 and 6 appear as
  indices), yet both corpus sites dutifully pass `2, a_nNumerator, a_nDenominator`. Were these a
  progress-fraction display in an earlier signature? The `':'`-splitting logic (`0x3a`) on arg 2
  suggests the text carries `"prefix:suffix"` structure. **Open.**
- **Why is `SetupShop` named that** if it wires garage locators? Possibly `FUN_004f12a6` does more
  than garage setup. Not read.
- **`ShopMacro`'s 12× `FUN_009e1b00` unroll** is *inferred* to be a bulk label unlock (it calls the
  same function `UnlockShopLabel` does), i.e. a developer cheat. The 12 label strings it passes were
  not extracted. **Open.**
- **Five functions missing from the decomp dump** (`0x00732c80`, `0x00732df0`, `0x00732f70`,
  `0x00733220`, `0x00733c50`). I recovered their signatures from the exe, but their bodies are not
  in the shared artifact — the Ghidra export appears to have skipped them. Worth a re-export; if
  the same gap affects other families, other docs may be silently under-covered. (Re-verified: all
  five are genuinely absent as `==== FUN_` headers, and all five disassemble cleanly from the exe
  at the stated VAs.)
- **`HUD.AddContraband` gates arg 1 twice** — `isnum(1)` **and then** `isstring(1)`, rather than
  `isstring(2)` as the subsequent `toSTR(2)` would suggest. `lua_isstring` accepts numbers, so the
  second gate is satisfied by the same numeric arg and the binding still works; but it reads like a
  transcription slip in the original source. Whether an unrelated arg-2 guard was intended is
  **open**.
- **`Object.SetGrenadeToExplode` / `Actor.PlayerOnSabSetGrenadeToExplode`** are claimed by no
  family. They are detonator ordnance and belong either here or with sabotage.
- **`Actor.AddToShop` is called but does not exist** — not in the registration map, not defined in
  the corpus, and the string is not in the exe. Either the corpus is missing a file that defines it,
  or five shop call sites (`ShopManager.lua` 226, 229, 350, 353, 405) raise a runtime error. This is
  the single highest-value follow-up in the family.

---

# The `Freeplay` table — ambient events

> **Scope and provenance.** This section **post-dates the adversarial verify pass** recorded in the
> header above and is **not covered by it**. It was added to close the seam's orphan-binding hole:
> 17 of the 21 `Freeplay` bindings appeared in no family doc. Nothing above this rule was altered.
> The section is self-contained; its claims stand or fall on their own citations.
>
> **Verified (this section only; the header's verify note above covers the other 37 rows).** The
> `awk '$1=="Freeplay"'` partition re-run: 21 rows, all 21 covered, no silent omission. All 21 `impl_va`
> match the tsv. Re-disassembled from `Saboteur.exe` with pefile+capstone and reproduced exactly: both
> retail stubs (`0x0072beb0` = `b8 01 00 00 00 c3`; `0x0072c0d0`'s `push 0; call 0x6f7020`), the
> `UnlockAmbientTag` thunk at `0x0072bff0`, the `0x006f7020`→`0x0043fbc6`→`0x006f7025` split-label
> artifact, the `0x0072b161` stanza immediate → `"UnlockAmbientTag"` at `0x00fe0f20`, the RTTI string at
> `0x011c4540`, and all four `Script\Freeplay\`/`Managers\` assertion paths. Decomp bodies re-read and
> found to say what is claimed: `FUN_00729f30`, `FUN_00729e00`, `FUN_0072a2f0`, `FUN_0072a170`
> (`uVar5 - 1 < 8` is verbatim), `FUN_0072a380` (`+0x48`, `0x10` cap, `+0x14a0`), `FUN_00984060`
> (the quoted polarity branch is verbatim), `FUN_00984110`. All corpus citations exist and say what is
> claimed; **every call-site count re-counted by grep and correct** — 56 across the 17 orphans, 72 with
> `BlockZoneForSave`'s 16, 75 with the collectables, 18 into the two stubs, 3 bare refs, and
> `IsAmbientTagUnlocked` really does have 0. No Mercenaries 2 import.
>
> **Corrected:** the claim that `grep "Script.Freeplay"` returns *zero* decomp hits — it returns **six**;
> the conclusion (none is in a binding body) survives and is now proved the right way.
> `DoStartupUnlocks` cited at line 575 (blank) → **576**, and its description omitted the load-bearing
> `"SB"` zone argument on all six archetype calls — it is zone-scoped, not global. "the target is spliced
> out of the live list" was asserted in a *confirmed* row from unopened callees → downgraded to inferred.
> The achievement-guard range `1214-1290` excluded `AFP_COUNTRY` (1306) and `EIFFEL` (1316) → `1186-1316`.
> **Strengthened:** `Util.GetCRC` sharing the CRC path was listed *open*; it is byte-provable and now
> proved from the exe (its impl `0x0074c830` is absent from the decomp), which closes leg 3 of the
> tag-is-a-CRC argument.

The three collectable bindings in the [Collectables & contraband HUD](#collectables--contraband-hud-4)
section are `Freeplay` rows, which makes this doc the closest home for the rest of the table. That is
the only reason they live here: **freeplay ambients are not inventory**, and if this catalog is ever
re-partitioned they deserve a family doc of their own.

## Partition (auditable)

`awk -F'\t' '$1=="Freeplay"' data/lua_registration_map.tsv` returns **21 rows**. All 21 are covered
below. Four were already claimed and are **cross-linked, not re-adjudicated**:

| Already owned by | Rows |
|---|---|
| [`16-family-world-zone-interior.md`](16-family-world-zone-interior.md) | `BlockZoneForSave` |
| This doc, Collectables & contraband HUD | `GetTotalCollectables`, `GetNumCollectablesCollected`, `SetupCollectableCallback` |

The remaining **17** are the orphans, documented here for the first time.

## The registration map, independently re-derived

The [README](README.md) flags the registration map as a single point of failure for 876 bindings:
every family doc checked its rows against the same derived tsv. For this family I did **not** do that.
I re-derived all 21 names straight from `Saboteur.exe`.

The name slot named in the `s_name_slot` column is **zero on disk** — it is written at runtime. The
pointer lives as an immediate in the registration stanza. For `UnlockAmbientTag` (`stanza_va`
`0x0072b161`):

```
0072b161  c7 00 6413fe00           mov dword ptr [eax], 0xfe1364        ; vtable_va
0072b167  c7 05 48dc4201 200ffe00  mov dword ptr [0x142dc48], 0xfe0f20  ; s_name_slot <- name
```

`0x00fe0f20` is the C string `"UnlockAmbientTag"`. Reading the `c7 05 <s_name_slot> <imm32>` immediate
out of each stanza window and dereferencing it yields **21 of 21 names matching the tsv exactly**.
This is independent byte-level confirmation of the map for this family, and the strongest identity
evidence any row below carries.

It is *not* an assertion string. `Script\Freeplay\WSAmbGeneric.cpp` (`0x00fea5d0`),
`WSAmbInterrogation.cpp` (`0x00feade8`) and `WSAmbFreeplayManager.cpp` (`0x00fe9cc8`) are all present in
the exe, and `grep "Script.Freeplay"` over the 54 MB decomp returns **six** hits — but **not one of them
is in a `Freeplay` binding body**. They live in `FUN_00768600`, `FUN_0076a5d6`, `FUN_0076ab00` and
`FUN_0076c700`; every `Freeplay` implementation lies in `0x00729e00`–`0x0072bb40`, and no row's body or
callee chain reaches those four. Those assertions belong to the C++ ambient classes underneath, not to
the binding layer. The README's "12 of 898" rule holds here without exception.

## The bindings

`FUN_006f7020` = `lua_pushboolean` is used throughout. Note that Ghidra renders it as
`thunk_FUN_0043fbc6`: `0x006f7020` is `jmp 0x43fbc6`, which does `movzx eax, byte [esp+4]` and jumps
*back* to `0x006f7025` → `lua_pushboolean` (`0x004019b0`). It is one function split across two labels —
the same Ghidra artifact [02](02-marshalling-abi.md) warns about; the two names are the same thing.

| Binding | VA | Shape | Signature | Confidence | Evidence |
|---|---|---|---|---|---|
| `UnlockAmbientTag` | `0x00729f30` | adapter | `(vTag:string\|handle [, bA:boolean=false] [, bLock:boolean=false]) -> ()` | **confirmed** | `gettop()`; `isbool(2)`→`tobool(2)`, `isbool(3)`→`tobool(3)`; `isstr(1)`→`toSTR(1)`→`FUN_00db7e10` (CRC), **else** `islud(1)`→`toUD(1)`; tail `FUN_00984260`. Polarity proven below. [`Paris_1_Mission_1.lua:255`](../saboteur-luacd/src/Missions/Paris_1_Mission_1.lua#L255) |
| `UnlockAmbientType` | `0x0072a040` | adapter | `(tTypes:table [, bA:boolean=false] [, bLock:boolean=false]) -> ()` | **confirmed** (shape); *inferred* (arg 2/3) | `istable(1)` **mandatory**; `isbool(2)`, `isbool(3)`; reads `t[1..32]` as lightuserdata via `FUN_006f78b0`, **hard cap `0x20`**; walks the target list matching `*(target+8)` (type) → `FUN_00984110`. [`AmbientRubberStamp.lua:763`](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua#L763) |
| `IsAmbientTagUnlocked` | `0x0072a2f0` | jmp eax | `(hTag:handle) -> boolean` | **confirmed** | `islud(1)` → **`return 0` if absent** (pushes *nothing*, so Lua sees `nil`, not `false`); `toUD(1)` → `FUN_009842e0` → `pushboolean`. **0 corpus call sites.** |
| `GetAmbientTypeFromTag` | `0x00729ea0` | jmp eax | `(hTag:handle) -> hType:handle\|nil` | **confirmed** | `islud(1)`, else `pushnil`; `FUN_009842a0` reads `target[+0x08]`; `thunk_FUN_004418c0` pushes it. [`AmbientRubberStamp.lua:302`](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua#L302) |
| `GetAllAmbientTags` | `0x00729e00` | jmp eax | `() -> tTags:table` (or nothing) | **confirmed** | zero args; `if mgr+0x14b4 == 0 return 0`; `FUN_006f69c0(n,0)` = `lua_createtable`; walks the list writing `t[i] = <lightuserdata target[+0x00]>` via `FUN_006f6cc0`. 4 call sites — [`AmbientRubberStamp.lua:32`](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua#L32) |
| `ResetAmbientTag` | `0x0072a170` | adapter | `(vTag:string\|handle, nCount:int, tTargets:table) -> ()` | *inferred* | **`gettop() > 2` mandatory**; arg 1 string→CRC or lightuserdata; `isnum(2)`→`toINT(2)`, **range-gated `n-1 < 8`**; `istable(3)`; builds an `n*4` array, each element lightuserdata-or-string→CRC; tail `FUN_00985240`. Signature is byte-solid; *`FUN_00985240`'s list surgery is only partly read* — see Open questions. 2 sites, [`AmbientRubberStamp.lua:1449`](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua#L1449) |
| `SetAmbientNamesTable` | `0x0072a780` | adapter | `(tTypeNames:table) -> ()` | *inferred* | `istable(1)` mandatory; same nested-table walk as the `Update*` pair (`FUN_006f7780`); 831-byte body **not read in full**. 1 site, [`AmbientRubberStamp.lua:286`](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua#L286) |
| `UpdateAmbientTotalsTable` | `0x0072a380` | adapter | `(tTotals:table) -> ()` | **confirmed** | `istable(1)` mandatory; lazily counts rows into `mgr+0x14a0`; per row reads ≤`0x10` nested entries (`FUN_006f7780`), writes `mgr+0x48+k*0x14`, row stride `0x140`; sets `mgr+0x14a4 = 1`. 1 site, [`AmbientRubberStamp.lua:329`](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua#L329) |
| `UpdateAmbientCompleteTable` | `0x0072a580` | adapter | `(tComplete:table) -> ()` | **confirmed** | byte-for-byte the twin of the above except the field written is `mgr+0x44` (not `+0x48`) and the flag byte is `+2` (not `+1`). 3 sites, [`AmbientRubberStamp.lua:296`](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua#L296) |
| `GetAmbientTotalsTable` | `0x0072aad0` | jmp eax | `(tOut:table) -> bInited:boolean` | **confirmed** | **no type check on arg 1**; `if mgr+0x14a4 == 0 { pushboolean(0); return 1; }`; else fills `t[i]` with nested tables via `FUN_006f6d50(1,i,…)` from `mgr+0x48`, then `pushboolean(1)`. 2 sites, [`AmbientRubberStamp.lua:33`](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua#L33) |
| `GetAmbientCompleteTable` | `0x0072ac80` | jmp eax | `(tOut:table) -> bInited:boolean` | **confirmed** | twin of the above, reading `mgr+0x44`. 2 sites, [`AmbientRubberStamp.lua:34`](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua#L34) |
| `UnloadAmbientFreeplay` | `0x0072af40` | adapter | `([bUnload:boolean=true]) -> ()` | **confirmed** | `gettop() > 0` → `isbool(1)` **mandatory if present** (else early `return`), default `1`; `FUN_00984320(b)`; stores `mgr+0x18 = b`. **8 call sites + 3 bare refs** (passed as a table value at [`Act_3_Mission_1.lua:698`](../saboteur-luacd/src/Missions/Act_3_Mission_1.lua#L698), `Act_3_Mission_1_E3.lua` 733 and 769) |
| `SetAmbientOnInitCallback` | `0x0072b920` | adapter | `(sCallbackName:string [, tSelf:table] [, tUser:table]) -> ()` | **confirmed** | the [05](05-engine-to-lua-callbacks.md) name-string idiom: `isstr(1)`→`toSTR(1)`→`FUN_0070a180`; `istable(2)`→`FUN_0070a4b0`; `istable(3)`. 1 site, [`AmbientRubberStamp.lua:282`](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua#L282) |
| `SetAmbientOnCompleteCallback` | `0x0072b810` | adapter | *as above* | **confirmed** | same body shape; `FUN_0070a180` then `FUN_0072c200`. 1 site, [`AmbientRubberStamp.lua:283`](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua#L283) |
| `SetAmbientOnReloadCallback` | `0x0072ba30` | adapter | *as above* | **confirmed** | same body shape. 1 site, [`AmbientRubberStamp.lua:285`](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua#L285) |
| `UnlockFreeplayAchievement` | `0x0072beb0` | inlined | `(sAchievement:string) -> ()` — **retail no-op** | **confirmed** | absent from the decomp; the exe holds `b8 01 00 00 00 c3` = `mov eax,1; ret`. **10 call sites.** See below |
| `IsFreeplayAchievementUnlocked` | `0x0072c0d0` | inlined | `(sAchievement:string) -> false` — **hard-wired false** | **confirmed** | absent from the decomp; the exe holds the singleton prologue, `FUN_006f8470(L)`, then `push 0; call 0x6f7020` (`lua_pushboolean(L,0)`), `mov eax,1; ret`. **8 call sites.** See below |
| `BlockZoneForSave` | `0x0072afd0` | adapter | `(sZoneCode:string [, bBlock:boolean=true]) -> ()` | cross-link | owned by [`16-family-world-zone-interior.md`](16-family-world-zone-interior.md). I re-read the body and **independently reproduce its `"ARSHUDNames."` finding**; see below for what that prefix means |
| `GetTotalCollectables` | `0x0072ae80` | jmp eax | `() -> n` | cross-link | Collectables & contraband HUD, above |
| `GetNumCollectablesCollected` | `0x0072aee0` | jmp eax | `() -> n` | cross-link | Collectables & contraband HUD, above |
| `SetupCollectableCallback` | `0x0072bb40` | adapter | `(sCallbackName, tSelf [, tUser])` | cross-link | Collectables & contraband HUD, above |

**Coverage: 21 of 21 located, 15 confirmed, 2 inferred, 0 not found** — plus 4 cross-linked rows
adjudicated elsewhere; the 17 orphans break down 15 confirmed / 2 inferred. All 21 names were
re-derived from exe bytes.

**Confidence: high** for the tag model, the arg-3 polarity and the two stubs — each is anchored in
bytes I disassembled and corroborated against shipped callers. **Medium** for `ResetAmbientTag` and
`SetAmbientNamesTable`, whose engine-side tails are only partly read.

Corpus usage, counted by grep and following this doc's convention of separating direct calls from
bare table references: **56 direct call sites across the 17 orphans** (72 including `BlockZoneForSave`'s
16, 75 including the three collectables), plus 3 bare refs to `UnloadAmbientFreeplay`. Every other row
has zero bare refs.

## What an ambient tag actually is

**An ambient tag is a CRC of a name string, and nothing else.** This is the load-bearing finding of the
section, and it is anchored three independent ways:

1. **RTTI.** The exe carries `.?AV?$PblTree@PAUWSAmbientFreeplayTarget@@VPblCRC@@$0A@VPblCriticalSection@@@@`
   at `0x011c4540` — demangled, `PblTree<WSAmbientFreeplayTarget*, PblCRC, 0, PblCriticalSection>`. The
   registry of ambient targets is **keyed by `PblCRC`**.
2. **The bindings.** Every tag-taking binding accepts *either* a string *or* a lightuserdata. The string
   path runs `FUN_00db7e10(s)` → `FUN_00db7c10(s)` and keeps the resulting scalar; the lightuserdata path
   takes the pointer value as-is. **They converge on the same 32-bit integer.**
3. **The corpus.** [`AmbientRubberStamp.lua:591-592`](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua#L591)
   is decisive:
   ```lua
   local hSupDropCatTag = Util.GetCRC("fp_amb_p3_supplydrop_46")
   Freeplay.UnlockAmbientTag(hSupDropCatTag)
   ```
   Script itself builds a tag by calling `Util.GetCRC` on the name. The handle *is* the CRC.

   This leg is byte-closed, not just suggestive. `Util.GetCRC`'s implementation (`0x0074c830`) is **absent
   from the decomp** and was read from the exe: at `0x0074c88f` it does `lea ecx,[esp+0xc]; call 0xdb7e10`
   — the *same* `PblCRC`-from-string constructor `UnlockAmbientTag` calls at `FUN_00729f30`, with the same
   `push 1` — then pushes the resulting scalar through `FUN_006f70c0` (`0x006f7020`-style thunk:
   `jmp 0x4418c0` → `call 0x4019d0`). Per [02](02-marshalling-abi.md), `0x004019d0` is
   `lua_pushlightuserdata`, and `0x004418c0` is the very routine `GetAmbientTypeFromTag` pushes its result
   through. So `Util.GetCRC` returns a lightuserdata box holding `FUN_00db7c10`'s scalar, and
   `UnlockAmbientTag`'s lightuserdata path unboxes exactly that. The two paths are the same value by
   construction.

This matters for [`03-handle-and-object-model.md`](03-handle-and-object-model.md): an ambient tag is
**not** a doc-03 handle. It carries no 24-bit slot, no 8-bit generation, no salt, and it is not resolved
through the red-black tree find at `FUN_004436f0`. It is a raw hash in a lightuserdata box. Two
consequences follow, both of which doc 03's model would get wrong:

- **Ambient tags are stable across save/load and across sessions**, unlike every handle doc 03 describes.
  They are content-addressed. A tag minted in one run is valid in the next.
- **They are forgeable from script.** `Util.GetCRC("anything")` produces one. There is no validation:
  `UnlockAmbientTag` on an unknown CRC simply walks the target list, matches nothing, and returns.

The target record is legible from the three accessors that read it:

| Offset | Field | Proof |
|---|---|---|
| `+0x00` | `PblCRC` tag | `FUN_00984260` compares `*(int*)target == tagCRC`; `GetAllAmbientTags` pushes `*target` as the handle |
| `+0x08` | ambient **type** (also a CRC) | `FUN_009842a0` returns `target[2]`; `UnlockAmbientType` matches on `*(int*)(target+8)` |
| `+0x40` | `bUnlocked` | `FUN_009842e0` returns `target[0x10] != 0`; `FUN_00984060` writes it |

The manager singleton is `DAT_0148e1dc` (`WSAmbientFreeplayManager`, `Managers\WSAmbientFreeplayManager.cpp`
at `0x010289a0`). Note this is a **different class** from `WSAmbFreeplayManager` in `Script\Freeplay\`
(`0x00fe9cc8`); the seam only ever touches the former. Its known fields: `+0x18` unload flag, `+0x40` the
totals/complete grid, `+0x14a0` row count, `+0x14a4` "tables initialised", `+0x14a8` the target list head,
`+0x14b4` target count, `+0x14c0` a second list that `ResetAmbientTag` splices.

## "Unlock" is a misnomer: arg 3 is `bLock`

`UnlockAmbientTag`'s third argument **locks**. The engine says so and the corpus agrees.

`FUN_00984060` — reached from `UnlockAmbientTag` via `FUN_00984260`, and from `UnlockAmbientType` via
`FUN_00984110` — branches on that flag:

```c
if (param_2 == '\0') { *(undefined1 *)(param_1 + 0x10) = 1;  /* +0x40 = unlocked */ ... }
else                 { *(undefined1 *)(param_1 + 0x10) = 0;  /* +0x40 = locked   */ ... }
```

Flag clear → unlocked. Flag set → locked. The `+0x40` write is the proven part; each branch then calls a
different registration helper under a `FUN_009e4040` predicate (`FUN_009ef570` on unlock, `FUN_009ef5d0`
on lock), which *reads* like add-to / remove-from a live list, but those three callees were not opened —
that reading is **inferred**, and the row is confirmed on the flag write and the corpus, not on it. Since
the argument defaults to `false`, the *common* call unlocks — which is presumably how the name survived
code review.

[`Paris_1_Mission_1.lua`](../saboteur-luacd/src/Missions/Paris_1_Mission_1.lua) proves the polarity from
the caller side, and it is a clean natural experiment because the same three tags are toggled both ways
in one file. At mission start (lines 254-259):

```lua
Util.UnloadStaticENTag("fp_amb_p1_radar_07", true)
Freeplay.UnlockAmbientTag("fp_amb_p1_radar_07", false, true)
```

and at mission end (lines 2545-2550):

```lua
Util.LoadStaticENTag("fp_amb_p1_radar_07", true)
Freeplay.UnlockAmbientTag("fp_amb_p1_radar_07", false, false)
```

The static entity is **unloaded** alongside `true` and **reloaded** alongside `false`. `true` = lock,
`false` = unlock. Byte-level branch and corpus semantics agree, so this row is **confirmed**.

This is the mechanism by which story missions carve their own space out of the open world: a mission that
needs the radar dish at `fp_amb_p1_radar_07` for its own scripted purposes locks the freeplay ambient
that would otherwise own it, and hands it back on completion. Freeplay and missions contend for the same
props, and the tag is the mutex.

## How the subsystem fits together

The engine owns the target list; **Lua owns the policy**. The shape is:

1. **The engine populates** `WSAmbientFreeplayManager`'s target list from world data at load. Script
   never creates a target — there is no `AddAmbientTarget` binding. Script can only enumerate
   (`GetAllAmbientTags`), interrogate (`GetAmbientTypeFromTag`, `IsAmbientTagUnlocked`) and gate
   (`UnlockAmbientTag`, `UnlockAmbientType`).
2. **[`AmbientRubberStamp.lua`](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua) is the policy
   layer**, and the name is the giveaway: a *rubber stamp* is a template applied repeatedly. It registers
   three callbacks at lines 282-285 — `OnInit`, `OnComplete`, `OnEnter` (as *reload*) — and the engine
   fires them by name per [05](05-engine-to-lua-callbacks.md). One Lua module drives every ambient in
   Paris; the engine just tells it which one and when.
3. **Gating is by type, not by tag, in bulk.** `UnlockAmbientType(tTypes, ...)` takes up to **32** type
   CRCs and unlocks every target matching any of them. `AmbientRubberStamp.DoStartupUnlocks`
   ([line 576](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua#L576)) is exactly this, and it is
   **zone-scoped, not global**: six archetype unlocks all passed the literal zone `"SB"` —
   `UnlockAmbientAAGun("SB")`, `UnlockAmbientArmored("SB")`, `UnlockAmbientRadar("SB")`,
   `UnlockAmbientRocket("SB")`, `UnlockAmbientSearchlight("SB")`, `UnlockAmbientTower("SB")` — then
   `UnlockAmbientAllInZone({"P1","P2","P3","LH"})`, which fans out to the *full* archetype list per zone,
   then `UnlockAmbientSweetJump()`, `UnlockAmbientTopSpot()` and the single direct
   `Freeplay.UnlockAmbientTag(Util.GetCRC("fp_amb_p3_supplydrop_46"))`. **The game's side content is
   switched on at startup in one function: six archetypes in Saarbrücken, everything in P1/P2/P3/LH.**
4. **Progress lives in a grid.** `SetAmbientNamesTable` declares the type rows; `UpdateAmbient*Table`
   pushes a Lua table down into `mgr+0x44`/`+0x48`; `GetAmbient*Table` reads it back. The C side is a
   `[nTypes][16]` array of 20-byte records (row stride `0x140` = `16 * 0x14`), with `+0x44` = completed
   and `+0x48` = total. The 16-per-row cap is a hard `cmp` — **no ambient type may have more than 16
   tracked buckets.**

`BlockZoneForSave` (doc 16's row) slots in here, and this section explains doc 16's open question about
it. It prefixes the literal `"ARSHUDNames."` to its argument before CRC-ing — `"ARSHUDNames." .. "P1S"` —
and `ARSHUDNames` is **A**mbient **R**ubber **S**tamp **HUD** **Names**. It is not really a zone-save
primitive at all: it keys into the same ambient name table that `SetAmbientNamesTable` populates,
addressing a per-zone row of the rubber-stamp HUD grid. The name is as misleading as
`UnlockAmbientTag`'s third argument.

## Two retail no-ops: the freeplay achievement API is gutted

Both `Freeplay` achievement bindings are dead in the shipped PC exe. This is the second `33 c0 c3`-class
finding in the catalog after `Vehicle.CanPassengerGetOut`.

`UnlockFreeplayAchievement` at `0x0072beb0` is **six bytes**:

```
0072beb0  b8 01 00 00 00    mov eax, 1
0072beb5  c3                ret
```

Compare the normal adapter, `UnlockAmbientTag`'s thunk at `0x0072bff0`:

```
0072bff0  8b 44 24 04       mov eax, dword ptr [esp + 4]
0072bff4  50                push eax
0072bff5  e8 36 df ff ff    call 0x729f30          ; <- the implementation
0072bffa  83 c4 04          add esp, 4
0072bffd  b8 01 00 00 00    mov eax, 1
0072c002  c3                ret
```

They are the same function with the `call` — and the argument marshalling — **elided**. The C++ body
compiled to nothing, so the compiler folded the adapter down to its `return`. That is why the tsv marks it
`shape=inlined` and `impl_va == thunk_va`: there is no implementation to point at.

`IsFreeplayAchievementUnlocked` at `0x0072c0d0` is worse, because it is not empty — it is *decided*:

```
0072c0ff  8b 44 24 04       mov eax, dword ptr [esp + 4]
0072c103  50                push eax
0072c104  e8 67 c3 fc ff    call 0x6f8470          ; state -> wrapper
0072c109  6a 00             push 0                 ; <- constant 0
0072c10b  8b c8             mov ecx, eax
0072c10d  e8 0e af fc ff    call 0x6f7020          ; lua_pushboolean(L, 0)
0072c112  b8 01 00 00 00    mov eax, 1
0072c117  c3                ret
```

It never reads its argument. It pushes a **literal `false`** and returns 1 result. Every call returns
false, for every achievement name, always.

The gameplay consequence is concrete and visible in the corpus. Eighteen live call sites route into these
two stubs (10 `UnlockFreeplayAchievement`, 8 `IsFreeplayAchievementUnlocked`), and
[`AmbientRubberStamp.lua:1186-1316`](../saboteur-luacd/src/Modules/AmbientRubberStamp.lua#L1186) is built
entirely on them:

```lua
local bEiffel = Freeplay.IsFreeplayAchievementUnlocked("EIFFEL")
...
if Freeplay.IsFreeplayAchievementUnlocked("AFP_EACH_TYPE") then
```

Because the query is hard-wired false, **every one of those guards takes its else-branch forever**. The
script believes no freeplay achievement is ever unlocked, re-evaluates the award condition every time,
and calls `UnlockFreeplayAchievement("AFP_PARIS1")` — which does nothing. The names read like a complete
design: `AFP_ANY`, `AFP_EACH_TYPE`, `AFP_PARIS1/2/3`, `AFP_SAAR`, `AFP_LEHAVRE`, `AFP_COUNTRY`, `EIFFEL`.
**The Lua side of the freeplay achievement system shipped complete and the C++ side shipped hollow.** PC
achievements were presumably wired through a different path — or, given the 2009 PC landscape, not wired
at all — and the Lua was left calling into stubs rather than being stripped. It is the sharpest evidence
in this doc of what the console-to-PC port dropped.

## Open questions

- **`FUN_00985240` (`ResetAmbientTag`'s tail) is only partly read.** The first 457 bytes show it marking
  the tag unlocked (`target[0x10] = 1`) and then performing intrusive doubly-linked-list removal against
  `mgr+0x14c0`, decrementing a count at `mgr+0x14b8`. What the `nCount`/`tTargets` pair *means* — my
  reading is "detach these child targets from the tag" — is **inferred from the splice, not proven**. The
  name says "reset"; the body says "unlock and unlink". Given that `UnlockAmbientTag` and
  `BlockZoneForSave` are both misnamed, the name deserves no benefit of the doubt. **Open.**
- **`ResetAmbientTag` hard-gates `nCount` to `1..8`** (`uVar5 - 1 < 8`) while `UnlockAmbientType` caps at
  `32` and the progress grid caps at `16`. Three different limits on what look like related collections.
  Whether 8 is a real design bound or a fixed-buffer artifact is **open**.
- **`SetAmbientNamesTable`'s 831-byte body was not read in full.** Its argument gate and its shared
  nested-table walk are byte-verified; the tail is not. Marked *inferred* for that reason.
- **`IsAmbientTagUnlocked` has zero corpus call sites** despite being a fully working binding. Either the
  corpus is missing a caller, or script tracks unlock state itself in `AmbientRubberStamp`'s tables and
  never asks the engine. Note it also has a real defect: the no-lightuserdata path does `return 0`
  **without pushing**, so it yields `nil` rather than `false`. **Open.**
- **`WSAmbInterrogation.cpp` (`0x00feade8`) has no binding.** Interrogation is a named freeplay ambient
  subsystem with its own source file and assertions, yet nothing in the `Freeplay` table reaches it. It is
  presumably driven entirely engine-side, or through another table. Worth a sweep.
- **`Modules/France.lua` was named as relevant in the brief but contains no `Freeplay.*` call.** The
  ambient-tag concept there, if any, is indirect. Not chased.
- **The CRC is `FUN_00db7c10`; the polynomial is still unidentified.** (That `Util.GetCRC` shares it is no
  longer open — it is byte-proven above via `0x0074c88f → 0xdb7e10 → 0xdb7c10`. `FUN_00db7c10` itself
  begins `call 0xdc1e20` on the string and consults a flag at `0x014e1cf8`, so it is table-driven and the
  polynomial lives in that table; not chased.)
  Confirming that `FUN_00db7c10` is the same hash used for `.luac` descriptor hashing in
  [`04-vm-lifecycle-and-script-objects.md`](04-vm-lifecycle-and-script-objects.md) would let modders mint
  tags offline. **Open, and cheap.**
