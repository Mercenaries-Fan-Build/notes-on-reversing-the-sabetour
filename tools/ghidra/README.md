# Ghidra: full-binary decompile export

`DecompileSaboteur.java` decompiles every non-thunk function in `Saboteur.exe` to one text file
(`output/_ghidra_saboteur/saboteur_all_functions_decomp.txt`, ~54 MB, gitignored). ⚠️ **The existing
export is not under this repo** — the copy everything cites lives in the sibling repo at
`C:/Users/Shadow/Desktop/notes-on-the-released-game/output/_ghidra_saboteur/`. Re-running the script
here would write a fresh one to this repo's `output/`; point your greps at the sibling path unless you
have actually regenerated it. Because the retail
exe is unpacked and RTTI-rich, Ghidra's auto-analysis recovers thousands of class/function names, so the
export comes out substantially pre-named.

## Prereqs
- Ghidra 12.x + a JDK 21 (Temurin used originally).
- A local copy of `Saboteur.exe` (retail GOG install).

## Run (headless)
```
analyzeHeadless <projectDir> SaboteurPC \
  -import "C:\GOG Games\The Saboteur\Saboteur.exe" \
  -scriptPath tools/ghidra \
  -postScript DecompileSaboteur.java \
  -analysisTimeoutPerFile 5400 -max-cpu 6
```
Import + auto-analyze + the post-script export run in one pass (~30–90 min). Adjust `OUT_DIR` at the top
of the script if your checkout isn't at `C:\Users\Shadow\Desktop\notes-on-reversing-the-sabetour`.

## Output
- `# Saboteur ALL export: 36935 functions` header, then per-function blocks:
  `==== <name> @0xADDR  size=N  callers=[...] ====` followed by the decompiled C.
- Last run: 36,935 functions, 1 decomp failure.

Grep this file as the engine oracle (it's authoritative — the exe is unpacked). It is intentionally
gitignored (too large); regenerate locally.
