# Changes and known limits

## Included compatibility work

- TrinityCore 12.0.7 API and build-system adaptation.
- Headless bot session login/logout and shutdown safety fixes.
- Map unload ordering fix for transports and bot sessions.
- Graveyard lookup guard and faction fallback for invalid area IDs.
- MySQL/CMake version-detection compatibility.
- Runtime memory reduction: eager common-zone and battleground terrain pinning removed.
- Low-latency configuration profile with bounded workers and a 3 ms bot tick budget.
- Player-facing social chat reactions, emotes, whispers, grouping, buffs, guilds, and session rhythm.
- Database-backed WoW lore answers in local, party, guild, and whisper chat, including ten-minute per-player follow-up context.

## Default resource profile

- 40 concurrent bots.
- 2 AI workers and 1 snapshot-build worker.
- 3 ms bot tick budget.
- Automatic battleground seeding disabled.
- Bot housing disabled.
- Handcrafted road graph disabled because the tested dataset produced no successful routes.
- Terrain and navigation data load on demand.

## Unsupported or incomplete areas

- This is not compatible with TrinityCore 12.1.x or other expansions.
- Not every dungeon, raid, battleground, quest, class mechanic, or modern retail system has bespoke bot logic.
- Nearby buffs are primarily group-oriented; bots do not continuously buff every stranger in crowded cities.
- Bot speakers are prevented from recursively triggering other bot chat replies. This avoids local-channel echo storms.
- Lore is a curated 42-topic offline library rather than a generative AI model. It covers major characters, factions, cosmology, races, conflicts, expansions, and current-saga foundations, but cannot guarantee a bespoke answer for every minor NPC or future story update.
- A first-time map/navmesh load can cause a short pause.
- The executable's displayed Git revision can show `unknown/Archived` because the final build was produced from a relocated source checkout; protocol and database compatibility are unchanged.

## Scaling guidance

The tested 16 GB host approached its memory/commit limit around 60–100 active bots. Use 40 on 16 GB. A 100-bot target should have at least 32 GB RAM, ample Windows page-file capacity, and staged latency testing.

## Licensing and content

This pack contains server-side open-source-derived binaries and support files only. It intentionally excludes Blizzard client files and extracted game data. Users are responsible for complying with the licenses and laws applicable in their location.
