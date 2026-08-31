# Changelog

## 0.2.0 - 2026-08-31

- Added a database-backed World of Warcraft lore knowledge system with 42 curated topics.
- Added lore question detection in local, party, guild, and whisper chat.
- Added ten-minute per-player topic memory for conversational follow-ups such as `tell me more`.
- Added faction-aware answer variants and safe fallback suggestions for unknown questions.
- Preserved bot-message suppression and local cooldowns to prevent chat loops and spam.
- Added migration `0017_lore_knowledge.sql` and updated the Windows Easy Pack.
- Added apply-ready source patch `0003-conversational-wow-lore.patch` and verified it against source revision `57655680`.

## 0.1.0 - 2026-08-31

- Added the TrinityCore 12.0.7 Playerbot V2 compatibility patch.
- Added matched Windows world/login server package.
- Added automatic database migrations and installation tooling.
- Fixed bot shutdown and map-unload crashes.
- Fixed invalid graveyard/area lookup crashes.
- Fixed MySQL CMake version detection.
- Removed eager terrain/navmesh pinning that exhausted memory.
- Added tested 40-bot social configuration.
- Enabled player-facing local, party, guild, whisper, emote, invitation, and group-buff interactions.
- Added backup, restore, start, stop, diagnostics, and troubleshooting documentation.
