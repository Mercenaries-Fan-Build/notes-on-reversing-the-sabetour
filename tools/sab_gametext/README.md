# sab_gametext

Reader/writer for **The Saboteur (2009) `GameText.dlg`** — the game's complete localized-text
container (one file per language under `Cinematics/Dialog/<Lang>/`). It holds every UI string
(objectives, mission names, tooltips, fail messages, shop/object display names — the text
`GameTemplates` and the Lua scripts reference) **and** every cinematic VO subtitle.

Format spec + confidence table: [`../../docs/formats/gametext.md`](../../docs/formats/gametext.md).
std-only (no dependencies). Verified **byte-identical round-trip on all six retail language files**.

## Commands

```
sab_gametext hash  <string>                          pandemic_hash of a text id
sab_gametext info  <in.dlg>                           header + UI/VO record counts + tail summary
sab_gametext list  <in.dlg> [--ui|--vo] [--limit N]   list records (asset_id, key, text preview)
sab_gametext get   <in.dlg> (--id <DottedID> | --hash 0x..)      read one string
sab_gametext set   <in.dlg> <out.dlg> (--id <DottedID> | --hash 0x..) --text "<STRING>"
                                                       overwrite an existing record's string
sab_gametext add   <in.dlg> <out.dlg> --id <DottedID> --text "<STRING>"
                                                       append a NEW UI-text record
sab_gametext roundtrip <in.dlg>                        parse -> re-emit; assert byte-identical
```

## How UI text is keyed (the modding-relevant fact)

A UI string is looked up by `pandemic_hash("<File>_Text.<Key>")` (e.g.
`GetLocalizedText("A1M0_Text.TASK_RaceJavier")`). On disk that record has an **empty key** and its
`asset_id` **is** that hash. So `add --id A1M0_Text.MyKey --text "…"` writes a record the engine will
resolve immediately — **no Lua `LoadGameTextFile` registration is required** (UI text lives in the
always-loaded base records). VO subtitles instead carry an ascii `vo_…` key and are looked up by
`pandemic_hash(key)`; their `asset_id` is the audio event id.

## Examples

```
$ sab_gametext get   English/GameText.dlg --id A1M0_Text.TASK_RaceJavier
0xafc7fd9c  "Race Javier"

$ sab_gametext set   English/GameText.dlg out.dlg --id A1M0_Text.TASK_RaceJavier --text "Beat Javier to Germany"
$ sab_gametext add   out.dlg out2.dlg --id KatMod_Text.Obj1 --text "Blow the bridge"
```

Ship an edited `GameText.dlg` by placing it at `Cinematics/Dialog/<Lang>/GameText.dlg` (back up the
original first). Editing strings and adding UI ids are both any-length; the writer recomputes the
header string-heap size and rebases the trailing `DNEC` (cinematic-overlay) offsets automatically.
