---
name: community-contribution-plan
description: Where our RE amplifies the Saboteur community tools (extract-only); prioritized contribution plan
metadata:
  type: project
---

Goal: leverage our Pandemic-engine RE to fill gaps in the Saboteur modding community's tools. Community = extract-only: PredatorCZ/SaboteurToolset (C++), BoBoBaSs84/SabTool (C#), saboteur-team.github.io wiki.

**Why:** the community can extract but not decode/repack; we have decode knowledge, a clean decomp, and working audio tooling they lack.

**How to apply — their hard blockers = our openings:**
1. ★HKX anim DECODE — SaboteurToolset explicitly can't ("separated metadata"); no keyframes exist. Highest value, needs Havok-6.5 RE ([[animation-havok65-gap]]).
2. Audio — NO community audio tool; we already built it ([[audio-1kcp-wwise]], 80k WAV). Ship-ready drop-in = fastest win.
3. Symbol-named decomp (36,935 fns + 2765 RTTI, [[clean-binary-and-symbols]]) — publish as shared map.
Strengthen (partial): repack + patchmega writer ([[archive-and-patch-megapack]]); hash→name (identical pandemic_hash + rainbow table + WWiseIDTable 7340 strings); WSAO material/shader semantics.

**Sequence:** audio first → publish decomp map → Havok 6.5 decoder (coordinate w/ PredatorCZ on AP0L pairing) → megapack writer → hash res → material semantics. Full plan: docs/community_tooling.md.
