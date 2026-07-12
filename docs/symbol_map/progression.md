# Perks, Weapons & Inventory (progression)

Perk unlocks, the weapon fire/reload model, the actor inventory, and the
contraband economy. This is the player-facing "progression" loop: you collect
contraband, spend it / earn perks, and carry weapons and items in an inventory.

## Shape of the subsystem

Three C++ layers plus a Lua control layer:

1. **Inventory core** (`WildStar\Objects\WSInventory.cpp`, `Weapon\WSItem.cpp`,
   `Weapon\WSInventoryStateStow.cpp`). `WSInventory` is the per-actor container
   that holds `WSItem`/`WSWeapon` instances, handles pickup/drop/holster and the
   stow (holstering) state machine. Items are instantiated from `WSItemBlueprint`
   data.
2. **Weapon/fire model** (`WildStar\Weapon\WSWeapon.cpp`, `WSGrenade.cpp`,
   `WSRocket.cpp`, `WSOrdnanceReactionHelper.cpp`). `WSWeapon` is a fire/cock/
   reload state machine; `WSSpecialWeaponItem` covers detonator-style ordnance.
3. **HUD / progression UI** (HUD manager module ~`0x0079xxxx`–`0x009bexxxx`).
   The perks popup and contraband ticker are driven by ActionScript/Flash calls
   (`exSetPerk*`, `exAddContraband`, `exPlayerContraband`) invoked through a
   movie vtable slot (`(**(...+0x48))("exName", args, argdesc, argc)`).
4. **Lua layer** (`docs/saboteur-luacd/src`). The `Inventory.*` binding module,
   `Managers/RewardsManager.lua` (per-mission `RWDList` giving money / ammo /
   items / labels / HQ unlocks), and `Managers/ShopManager.lua` (`Actor.SetupShop`).

### Lua API surface (from corpus + `lua_bindings.txt`)

- `Inventory.GiveItem` (125+ call sites), `GiveAmmo`, `GiveMoney`, `GetMoney`,
  `GetCountOfType`, `GetItemOfType`, `GetAmmoCount`, `HasItem`, `HasAnyGuns`,
  `DetachItem`, `RemoveAllWeapons`, `HolsterWeapons`.
- Perks: `UnlockPerk`, `UnlockPerkReward`, `SetPerkAvailable`, `SendPerkMessage`
  (wrapped as `Util.SendPerkMessage`, ~28 sites in RewardsManager), plus
  `SetEnablePerkFriendlyFire / NotoriousTitle / DoubleAgentTitle`.
- Weapons/combat: `FireCurrentWeapon`, `HasWeapon`, `HolsterWeapons`,
  `EnableAmmoDrops`, `SetBroadcastWeaponFire`, `SetDryFire`, `SetIdleHoldWeapon`,
  `SetDropWeaponWhenRagdolled`, `GetFireThreshold`, `GetWeaponPitch`.
- Shops/economy: `Actor.SetupShop`, `IsAShop`, `SetShopEnable`,
  `SetShopDisplayLockedByPerks`, `ShopMacro`, `HUDAddContraband`,
  `DisableShopKeeperBlip`.

The reward model lives in `RewardsManager.__GiveMissionReward` /
`__GivePreMissionReward`: a `RWDList[mission]` table with `ContrabandType`
(-> `Inventory.GiveMoney`), `AmmoType` (-> `GiveAmmo`), `ItemType`
(-> `GiveItem`), `Label`/`RemoveLabel`, and `HQUnlock`/`HQLock`.

## RTTI classes owned (from `ws_engine_classes.txt`)

`WSInventory`, `WSInventoryState`, `WSInventoryStateStow`, `WSInventoryCheckEvent`,
`WSHUDInventory`, `WSItem`, `WSItemBlueprint`, `WSItemCache`, `WSItemCacheBlueprint`,
`WSWeapon`, `WSWeaponBlueprint`, `WSWeaponItem`, `WSMeleeWeapon`,
`WSMeleeWeaponBlueprint`, `WSSpecialWeaponItem`, `WSAmmo`, `WSAmmoBlueprint`,
`WSPerk`, `WSPerkBlueprint`, `WSPerksManager`, `WSPerkFactorBlueprint`,
`WSCounterPerk`, `WSTimerPerk`, `WSTrackerPerk`, `WSDualTriggerPerk`,
`WSHUDPerksPopup`, `WSPerksPopupCallback`, `WSSearcherItem`, `WSStartPosItem`,
`WSTrainItem`, `WSTrainWeaponAmmoUpdateFunction`, `WSWeaponItemSetGroupFunction`,
`WSPlayerItemCacheAction`.

## Pinned functions (evidence)

All VAs verified present in `saboteur_all_functions_decomp.txt`. C++ names come
from the retained `.cpp`+method assert strings (`FUN_00453070(path, method, line)`
pattern) unless noted "inferred".

### Inventory core (WSInventory.cpp asserts)

- `FUN_004991e0` **WSInventory::DropItem** — assert string names it; 6 callers
  incl. ragdoll/death paths. Backs `Inventory.DetachItem`/drop behavior.
- `FUN_0049c4b0` **WSInventory::EmptyInventoryImmediate** — assert; called from
  two teardown paths (`FUN_006543d0`, `FUN_00654900`). This is the clear-all used
  by `Inventory.RemoveAllWeapons`.
- `FUN_004a7cd0` **WSInventory::TakeOutItem** — assert; equips/draws an item.
- `FUN_016113e0` **WSInventory::HolsterItem** — assert; holster path.
- `FUN_01611640` **WSInventory::PickupItem** — assert; item acquisition (backs
  `Inventory.GiveItem`).
- `FUN_0058d6c0` **WSInventory::DropAllItems** — assert.
- `FUN_0069c160` **WSInventoryStateStow::FinishState** — assert
  (`WSInventoryStateStow.cpp`); completes the holster/stow animation state.

### Item / blueprint

- `FUN_0069cb70` **WSItem::OnFinishedSettingUp** — assert (`WSItem.cpp`); item
  post-load init, called after blueprint instantiation.
- `FUN_0069dc40` **WSItemBlueprint::SetProperty** — assert (`WSItem.cpp` line
  0x167). A large `switch` over **FNV-hashed property IDs** (e.g. `0x650a47ed`,
  `0x5b724250`, `0x1e757409` selecting an enum 0..10) that sets bitflags and
  object refs at `this-0x10/-0x14/-0x24/-0x48`. This is the item-blueprint text
  property parser. Property *names* are not recoverable (hashed) — see gaps.

### Weapon / fire model (WSWeapon.cpp asserts)

- `FUN_006be5a0` **WSWeapon::UpdateFire** — assert; ~1.6 KB per-frame fire tick,
  calls UpdateGrenadeFire. Core of `FireCurrentWeapon`.
- `FUN_006b5960` **WSWeapon::UpdateGrenadeFire** — assert; called only from
  UpdateFire (`0x006beba2`). Grenade throw arc/release.
- `FUN_006b1fa0` **WSWeapon::UpdateReload** — assert; reload tick.
- `FUN_006b1bf0` **WSWeapon::BulletReloaded** — assert; per-bullet reload
  callback (revolver/shotgun style).
- `FUN_006b76a0` **WSSpecialWeaponItem::TriggerDetonator** — assert; remote
  detonation of placed ordnance (callers `0x0052a4fd`, `0x0052be9f`).
- `FUN_005072a0` **weapon/model attach-readiness gate** (inferred) — returns
  reason strings `"Saboteur model isn't loaded"`, `"its weapon blueprint isn't
  loaded"`, `"animations aren't loaded yet"`; the guard that decides whether a
  weapon can be equipped/spawned this frame.

### Perks & contraband HUD (Flash-call driven)

- `FUN_0079d050` **contraband HUD ticker** (inferred) — drives `"exAddContraband"`
  and `"exHideContraband"` on the movie vtable; walks a ring buffer of
  0x10c-byte pickup entries and accumulates value into `+0x54`. This is the
  on-screen "contraband collected" popup manager (Lua `HUDAddContraband`).
- `FUN_007a0e40` **perks-popup data populate** (inferred) — pushes
  `"exSetPerkReqs"`, `"exSetPerkRewards"`, `"exSetPerkLevels"` etc. into the
  Flash perks screen; backs `WSHUDPerksPopup`.
- `FUN_007acd30` **exCallPerks handler** (inferred) — perks screen open/refresh.
- `FUN_007b0b50` **exEndPerks handler** (inferred) — perks screen close.
- `FUN_007a8bc0` **perks_unlocked** notifier (inferred) — emits `"perks_unlocked"`
  event string.
- `FUN_0077c5c0` **SetupPerkTutorial** (inferred) — emits `"SetupPerkTutorial"`;
  first-time perk tutorial trigger.
- `FUN_009be9d0` **WSHUDManager::SetupPerksPopupTemplate** — assert string names
  the method; HUD manager wiring for the perks popup template.
- `FUN_009befb0` **exPlayerContraband HUD update** (inferred) — pushes
  `"exPlayerContraband"` and branches on `"KnifeThrow"` / vehicle contraband
  (`"VH_CV_CR_HORCH853_Jules"`); updates the player contraband counter.

### Lua glue

- `FUN_007334c0` **Inventory.DetachItem** (Lua binding) — the only Inventory
  binding carrying its `Interface\Inventory.cpp`+`"DetachItem"` assert (line
  0x15f). Uses the Lua arg-getter helpers `FUN_006f71a0`/`FUN_006f6ec0`/
  `FUN_006f7120` (get-arg-N). Its siblings `FUN_007322b0`, `FUN_00732990`,
  `FUN_00733100`, `FUN_00733350`, `FUN_00733640`, `FUN_007337d0`, `FUN_00733910`
  form the rest of the `Inventory.*` binding module (registered together; exact
  name-to-VA needs the binding table — see gaps).

## Cross-references

- **HUD/Flash UI** — perks popup and contraband ticker are pure Flash-call
  emitters through the movie vtable `+0x48` slot shared with the wider HUD.
- **Actor/Character** — `WSInventory` is owned per-actor; drop paths fire from
  ragdoll/death (Actor subsystem). `SetupShop`/`HasWeapon` are `Actor.*` bindings.
- **Rewards/Mission scripting** — `RewardsManager`/`ShopManager` Lua drive all
  give-item / give-money / unlock traffic.
- **Blueprint/asset loader** — items built from `WSItemBlueprint` (hashed
  property parser `FUN_0069dc40`).

## Gaps / caveats

- **No RTTI vtable→VA map yet.** `WSPerksManager`, `WSPerk` and its subclasses
  (`WSCounterPerk`, `WSTimerPerk`, `WSTrackerPerk`, `WSDualTriggerPerk`),
  `WSPerkBlueprint`, `WSAmmo`/`WSAmmoBlueprint`, `WSMeleeWeapon`,
  `WSItemCache`, and `WSWeaponBlueprint` could not be pinned to concrete VAs —
  none carry `.cpp` asserts in the dump. They need the vtable map.
- **Item/weapon blueprint property names are FNV-hashed** in
  `WSItemBlueprint::SetProperty` (`FUN_0069dc40`); recovering names requires a
  hash dictionary or the blueprint text schema.
- **Lua binding table not resolved.** Only `Inventory.DetachItem` (`FUN_007334c0`)
  is name-pinned. The registrar that maps names→stubs sits in an
  un-named region around `0x00733d00`–`0x00733f30` (Ghidra left it headerless),
  so `GiveItem`/`GiveAmmo`/`GetCountOfType` etc. are located as a cluster but
  not individually named.
- Perk/contraband HUD names (`exCallPerks`, `exEndPerks`, `perks_unlocked`,
  `exPlayerContraband`) are the **Flash method strings**, not the C++ function
  names; the C++ names are inferred from which Flash call each function emits.
- `FireCurrentWeapon`/`GiveMoney`/`UnlockPerk` binding names do **not** appear as
  inline strings (confirmed by grep), consistent with the note that binding names
  aren't string-greppable.

---

## Verification (adversarial pass)

**Verdict: solid** — 20/20 key functions confirmed against the decomp.

**Seams (cross-subsystem):**

- WSItemBlueprint::SetProperty (0x0069dc40) delegates to parent-blueprint property parsers FUN_007dbdf0 then FUN_007e0f30 BEFORE its own FNV-hash switch — a blueprint-inheritance parse chain the doc omits; and one of its 5 callers, 0x006b8d56 inside FUN_006b8d30 (a WSWeaponBlueprint parse), means weapon-blueprint SetProperty falls through into item-blueprint SetProperty.
- Equip-readiness gate (0x005072a0) reaches into the animation/skeleton subsystem: FUN_00638c70 (skeleton-loaded check), FUN_00516020 / FUN_00516b50 (model/anim resolve). Sole caller FUN_0050d0d0. Doc frames it purely as a weapon gate but half its checks are animation-subsystem state.
- Shared name-hash registry FUN_00db7e10 is a cross-subsystem seam: WSWeapon::UpdateFire (0x006be5a0) queries it with "Shotgun"/"Shotgun Terror" and Player-contraband HUD (0x009befb0) with "VH_CV_CR_HORCH853_Jules" — the same registry the vehicle subsystem uses at 0x00872731+. Links inventory/weapon/HUD naming to the vehicle subsystem.
- WSInventory::DropItem (0x004991e0) routes through FUN_0049f1e0 (local-player resolve) and FUN_009234a0/FUN_00498c30 (HUD/notification) on the drop path — a HUD seam beyond the ragdoll/death callers already noted.

**Additional gaps / suspected decomp corruption:**

- Systematic caller-list gap: 8 of the claimed virtual functions show callers=[] despite clearly being live — UpdateFire (0x006be5a0), UpdateReload (0x006b1fa0), TakeOutItem (0x004a7cd0), DropAllItems (0x0058d6c0), InventoryStateStow::FinishState (0x0069c160), contraband ticker (0x0079d050), HolsterItem (0x016113e0), PickupItem (0x01611640). These are vtable/virtual-dispatch entries so the direct-call xref extractor found nothing. callers=[] here means 'dispatched indirectly', NOT 'dead code' — the doc must not read it as unused.
- WSInventory.cpp is split across two disjoint code regions: DropItem/TakeOutItem/EmptyInventoryImmediate/DropAllItems sit in 0x0049xx-0x0058xx, but HolsterItem (0x016113e0), PickupItem (0x01611640) and helpers FUN_01611580/FUN_01611720 sit in an appended 0x0161xxxx segment — all with identical WSInventory.cpp assert paths. Looks like LTCG/relocated TU, not corruption, but anyone grepping only the low region silently loses half the inventory API surface.
- A SECOND function (~line 517274, distinct FUN, not the doc's 0x007a0e40) also pushes exSetPerkReqs/exSetPerkRewards/exSetPerkLevels through movie vtable +0x48. Two perk-screen populate paths exist; the doc names only one — worth identifying which is the popup vs. the main perks screen.

**Verifier corrections:**

Every claimed key function verified: all 20 headers exist at the stated VAs, all cited assert strings match (WSInventory.cpp DropItem@0x154, TakeOutItem@0x76, HolsterItem@0x22f, PickupItem@0x21f, EmptyInventoryImmediate@0x9da, DropAllItems@0x30b; WSItem.cpp WSItemBlueprint::SetProperty@0x167; WSWeapon.cpp UpdateFire@0x30d, plus UpdateGrenadeFire/UpdateReload/BulletReloaded; WSSpecialWeaponItem::TriggerDetonator; Inventory.cpp DetachItem@0x15f). SetProperty FNV hashes (0x650a47ed, 0x5b724250, 0x1e757409) and the -0x10/-0x24/-0x48 field writes are exactly as claimed. All movie-vtable strings (exAddContraband/exHideContraband, exSetPerkReqs/Rewards/Levels, exPlayerContraband) and the KnifeThrow/VH_CV_CR_HORCH853_Jules branches confirmed at the stated functions. All sampled Lua bindings and RTTI class names exist in the data files. Suggested doc edits: (1) add a note that callers=[] on virtual functions reflects xref-extraction limits, not dead code; (2) note WSInventory's split across the 0x0049xx and 0x0161xxxx regions; (3) record SetProperty's parent-parse chain (FUN_007dbdf0/FUN_007e0f30) and that the gate at 0x005072a0 is partly an animation/skeleton readiness check.
