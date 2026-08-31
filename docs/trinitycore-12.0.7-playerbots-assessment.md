# Playerbots on TrinityCore 12.0.7 — engineering assessment

## Outcome

The requested repository cannot be made compatible with TrinityCore 12.0.7
through ordinary source, CMake, and configuration edits. Current
`mod-playerbots` is an AzerothCore 3.3.5a module that requires a custom
AzerothCore fork. TrinityCore 12.0.7 is the retail core and has a different
module/build model, packet protocol, character/database model, game data, and
class/content systems.

Treating this as a header/API update would produce a build that is either
non-functional or corrupts data. A valid port is a versioned TrinityCore fork
plus a retail Playerbots rewrite.

## Repositories and revisions inspected

- `mod-playerbots/mod-playerbots`, current master at time of inspection.
- `TrinityCore/TrinityCore`, current master; official history identifies
  12.0.7 build 68887 in the July 2026 master history.
- `agatho/TrinityCore`, `playerbot-v2` at
  `57655680a93c9cf1284cc0dced3da9c9f05e51d1` (2026-07-27), used as a public
  retail-port reference.

## Compatibility findings

| Area | WotLK module assumption | TrinityCore 12.0.7 requirement |
|---|---|---|
| Build | AzerothCore module discovery and `conf.sh` source lists | Explicit TC targets, include/link wiring, opt-in flag |
| Session | AzerothCore/WotLK bot login extensions | Retail-compatible server-side `WorldSession` lifecycle |
| Packets | 3.3.5 packet structures/opcodes | 12.0.7 packet structures and handler contracts |
| Scripts/hooks | AzerothCore script hooks and custom Playerbot core APIs | Core-side bot API plus explicit event hooks |
| Classes | WotLK classes, talent tabs, glyphs, spell IDs | 12.0.7 specs, class/spec/hero/PvP talents and spell data |
| Data | WotLK maps, quests, items, raids, BGs | Retail DB2/world/hotfix data and encounter strategies |
| Database | AzerothCore Playerbots tables/queries | TC prepared statements and a new retail bot schema |

Static scope illustrates why this is a rewrite: the source module contains
1,362 C++ files (about 203k lines). The retail reference contains 427 C++ files
(about 127k lines), 16 SQL files, 12 Playerbot subsystem libraries, a core-side
API, and edits across at least 12 TrinityCore hook-bearing core files.

## Necessary implementation shape

The public `playerbot-v2` work demonstrates the minimum viable architecture:

- `BUILD_PLAYERBOT_V2` CMake switch;
- separate bot, combat, fleet, group, session, threading, travel, persistence,
  world, diagnostics, utility, and core libraries;
- a stable core-facing `PlayerbotAPI`, movement adapter, and hook facade;
- world-tick and lifecycle integration;
- combat/heal/death, chat/guild/group, LFG/BG, loot, and DB integrations;
- a retail configuration file and dedicated SQL migrations.

Those changes must be carried together. The module directory alone is not a
working patch.

## Behavior preservation and unsupported areas

The original AI concepts—state-driven decisions, autonomous population,
grouping, questing, combat roles, travel, and economy—can be preserved.
Byte-for-byte WotLK behavior cannot be preserved where retail mechanics have
no equivalent.

Known gaps requiring explicit acceptance/testing:

- WotLK dungeon/raid strategies need retail replacements.
- All class rotations and talent selection need 12.0.7 validation.
- Full battle-pet behavior is deferred in the reference design.
- Optional PlayerbotControl addon server integration is documented as stubbed.
- No supported migration exists from AzerothCore Playerbots SQL to the retail
  schema.
- LFG, battleground, auction, mail, guild, and high-population concurrency
  require live runtime testing.

## Verification result

Repository, API-boundary, CMake, configuration, SQL, and source-scope review
completed. The retail V2 fork was configured with MSVC 19.51, CMake/Ninja,
Boost 1.92, MySQL 8.0.46, and OpenSSL 4.0.1. A complete RelWithDebInfo
`worldserver` build with `BUILD_PLAYERBOT_V2=ON` passed all 1,927 build steps.

The generated bundle contains `worldserver.exe`, `worldserver.conf.dist`, and
`playerbot.conf.dist`. Database-backed runtime testing still requires matching
12.0.7 world/hotfix/characters databases, extracted client data
(maps/vmaps/mmaps), and a matching client. No database migration or live realm
was available in this workspace, so the server was not allowed to mutate a
production database.

## Recommended delivery path

1. Pin the July 2026 TrinityCore 12.0.7 revision and the retail Playerbot fork
   revision in a dedicated integration branch.
2. Build with `BUILD_PLAYERBOT_V2=ON`; do not import WotLK module SQL.
3. Resolve any delta between the reference fork's TC base and the exact 12.0.7
   pin.
4. Smoke-test boot with bots disabled, then one bot login/logout, movement,
   combat, group/chat, quests, loot, and vendors.
5. Test LFG/BG and economy systems, then soak-test population scaling with
   sanitizer/debug builds before production use.

## Changed files

- `docs/TRINITYCORE_12_0_7_PORT.md` — records the compatibility boundary,
  required architecture, reference implementation, verification, and known
  unsupported areas. No unsafe claim of drop-in TrinityCore support was added.
- Retail V2 build helpers now consistently use the real CMake switch,
  `BUILD_PLAYERBOT_V2`, in `build-playerbot.sh`, the three Windows configure
  batch files, and `scripts/verify_playerbot_dependencies.sh`.
- `configure_playerbot_v2.ps1` adds a Windows configuration entry point which
  discovers CMake and enables Playerbot V2, static scripts, and the selected
  build configuration.
