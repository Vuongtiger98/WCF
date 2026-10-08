# Route safety audit — 2026-09-19

## Scope

- 63 map data files currently present in `Data/`.
- 178 direct `Transfer Player` commands plus the scripted Map029 → Map025 handoff.
- Destination bounds and tile passage, native Fadeout/Fadein continuity, KUL opacity handoff, and event-script syntax.
- Existing route-specific audits for Atlantis, supermarket/coffee, spicy noodle, magic-book, Leo shop, Shylvie jewel, shared preparation, Wanderer rooms, Christmas scenes, and ending state.
- Dialogue box limits on every current map: at most four lines, 40 grapheme clusters without a face and 33 with a face.

## Confirmed fixes

1. Shylvie room (Map043)
   - Updated all five incoming office variants (Map013, Map038, Map039, Map050, Map052) from blocked `(2,6)` to walkable `(2,9)`.
   - The paired exit remains at `(1,9)` and the arrival can reach it.

2. Shared meeting rooms (Map061/Map062)
   - Updated Map038, Map039, Map048, Map050, Map052, and Map054 from blocked `(17,16)` to `(17,6)`, immediately below the exit at `(17,5)`.
   - Map013 was already using `(17,6)`.

3. Shared crafting room return (Map063)
   - Map013 now returns to `(36,36)` instead of blocked `(37,36)`.
   - Map038 now returns to `(36,37)` instead of blocked `(37,36)`, avoiding both the wall and an immediate bounce on the door event.
   - Other office variants already had a movable landing at their existing coordinate.

4. Spicy-noodle native fade/KUL handoffs
   - Map010 → Map020: Map020 restores native brightness while KUL is still fully black, then performs the intended KUL reveal.
   - Map037 → Map014: Map014 applies the same ordering before the kitchen reveal.
   - Map020 → Map019 Aira branch: Map019 now clears/hides the inherited black KUL overlay before dialogue.

5. Dialogue layout
   - Reflowed seven interaction descriptions on Map015 without changing their wording or event behavior.
   - Project-wide result: zero line-length or four-line violations.

## Intentionally blocked cutscene landings

Some transfers land on non-walkable tiles but never return control there. They are retained because their autorun page owns the player and ends in another transfer, an intentional Game Over, or Return to Title. The audit distinguishes these from free-roam destinations. This includes transit/visual scenes such as Map010, Map016, Map021, Map036, Map037, Map059, and Map064.

Map021 intentionally stays under native Fadeout while forwarding to Map023; Map023 restores brightness before its first visible dialogue. Map024 restores native brightness immediately after its transfer. These are valid multi-map transitions rather than persistent-black bugs.

## Final automated results

- Route transfer safety: `178 transfers`, `63 maps`, `0 errors`, `0 warnings`.
- Event script syntax across all current maps: `0 errors`.
- Dialogue frame limits across all current maps: `0 violations`.
- Repeated route-state audit: `0 suspects`.
- All focused route and scene audits executed in this pass: passed.

## Priority manual playtest

1. Bus choice → spicy-noodle shop → both Aira choices → preparation room → Wanderer kitchen → party → ending hint.
2. Every office variant entering and leaving Shylvie's room, the meeting room, and the crafting room; verify there is no immediate door bounce.
3. Magic-book branches from Atlantis shop through preparation, Christmas office, and ending hint; watch every black-screen/KUL handoff.
4. Leo shop branches and Shylvie jewel branches through their ending pages.
5. Atlantis mirror maze, clone encirclement, jumpscare, chase, post-chase memory, and Map029 → Map025 scripted handoff.
6. Optional bathroom dryer choice on Map015 → Map016; this intentionally locks control for the gag and ends in Game Over.

No coordinate remains unresolved by the static audit. Manual playtest is still required for runtime plugin timing, conditional page selection, camera composition, and save files carrying old switch/variable state.
