# TrinityCore 12.0.7 Playerbot V2 build report

## Result

The credible retail-compatible implementation is the complete
`agatho/TrinityCore` `playerbot-v2` fork, pinned for this evaluation at commit
`57655680a93c9cf1284cc0dced3da9c9f05e51d1` (2026-07-27). It compiled and
linked successfully on Windows as a RelWithDebInfo `worldserver` with
`BUILD_PLAYERBOT_V2=ON`.

Build result: **passed, 1,927/1,927 server build steps**.

Follow-up unit-test result: **36/36 test cases passed, 320 assertions**.

Executable startup checks also pass: `worldserver.exe --help` exits normally,
and `--version` reports the pinned `57655680a93c` Playerbot V2 revision as a
Windows AMD64 RelWithDebInfo static build.

The original `mod-playerbots/mod-playerbots` tree remains an AzerothCore WotLK
module and cannot be installed into retail TrinityCore by itself. Its behavior
is represented by the retail V2 rewrite, which must remain coupled to its
TrinityCore core API and hooks.

## Tested toolchain

- Visual Studio MSVC 19.51 (x64)
- CMake with Ninja
- Boost 1.92.0
- MySQL 8.0.46
- OpenSSL 4.0.1
- `BUILD_PLAYERBOT_V2=ON`, `TOOLS=OFF`, `SCRIPTS=static`

The final build produced a 49,374,208-byte `worldserver.exe`, its symbols,
`worldserver.conf.dist`, `playerbot.conf.dist`, and the required OpenSSL helper
DLL.

## Compatibility changes made

| File | Change |
|---|---|
| `build-playerbot.sh` | Replaced the obsolete `BUILD_PLAYERBOT` switch with `BUILD_PLAYERBOT_V2`. |
| `configure_debug.bat` | Enabled the correct V2 switch. |
| `configure_release.bat` | Enabled the correct V2 switch. |
| `configure_test.bat` | Enabled the correct V2 switch. |
| `scripts/verify_playerbot_dependencies.sh` | Corrected its diagnostic and example configuration command. |
| `configure_playerbot_v2.ps1` | Added a Windows CMake discovery/configuration helper. |
| `dep/boost/CMakeLists.txt` | Maps vcpkg Boost imports from RelWithDebInfo to Release on Windows, preventing a debug/release ABI mix without globally changing MySQL imports. |
| `tests/CMakeLists.txt`, `tests/game/PlayerbotMigrationParser.cpp` | Excludes retired V1 prototype tests, repairs target linkage, and adds migration-parser regression coverage. |
| `Persistence/PlayerbotMigrationMgr.*` | Applies route/navigation data as tracked auxiliary migrations, parses quoted/commented SQL safely, and verifies every migration records completion. |
| `HandcraftedRoadStorage.cpp`, `0016_handcrafted_road.sql`, `worldserver.conf.dist` | Removes the final legacy shared-schema lookup, adds its missing table migration, and makes a clean first boot defer the early road load safely. |
| `Fleet/BotNamePool.*`, `World/WorldMetadata.cpp`, `Bot/Dungeon/DungeonScript.*` | Uses the same CharacterDatabase storage contract as the migration runner, removing broken cross-schema lookups. |
| `Fleet/BotNamePool.*`, `0015_name_pool.sql` | Correctly normalizes the imported 0–17 race/gender categories by parity instead of treating most entries as universal. |
| `playerbot.conf.dist`, SQL headers, installation/schema docs, and route generator | Removes the contradictory `Playerbot.SharedDatabase` requirement and documents CharacterDatabase deployment consistently. |
| `worldserver/CMakeLists.txt` and `PlayerbotMigrationMgr.cpp` | Deploys all primary and auxiliary migrations beside the server configuration and falls back to that bundle when the source checkout is unavailable. |
| Windows server/OpenSSL install rules | Uses relative install destinations so `cmake --install --prefix` works instead of always writing to Program Files. |
| `scripts/CMakeLists.txt` | Quotes the disabled-script removal list correctly, eliminating path-with-spaces warnings during installation. |
| `cmake/macros/FindMySQL.cmake` | Falls back to `mysql_version.h` when Windows cannot execute the compiled MySQL version probe, instead of parsing empty JSON and aborting configuration. |
| `Session/BotSession.*`, `Session/BotSessionMgr.*`, `Services.cpp` | Stops AI/fleet workers and synchronously logs out every headless bot session before map teardown. |
| `Map.cpp` | Removes active transports before unloading grids, preventing the reproducible Broken Isles (`map 1220`) null-grid assertion during shutdown. |
| `mod-playerbots/docs/TRINITYCORE_12_0_7_PORT.md` | Documented why the WotLK module is not a drop-in retail port and identified the required architecture and unsupported areas. |

Existing playerbot behavior was preserved, apart from targeted fixes to broken
database routing and name gender selection. The retail implementation's bot,
combat, fleet, group, session, threading, travel, persistence, world,
diagnostics, and utility libraries all compiled.

## Build notes

On Windows, a deeply nested source path caused Ninja's precompiled-header
command to exceed the process command-line limit. Building through a short
directory junction (`C:\tc-pb`) resolved this without changing source. A short
checkout path is recommended for repeatable Windows builds.

Warnings were non-fatal and mostly consisted of the fork selecting `/W3` after
TrinityCore selected `/W4`, plus several unused locals/parameters and one
signed/unsigned comparison. There were no Playerbot compile or link errors.

## Test repair and result

Enabling `BUILD_TESTING` initially exposed three independent integration
problems hidden by the normal server target:

- the test collector included retired V1 Phase 3/Phase 5 and movement sources
  whose production headers no longer exist;
- tests linked `extractor_common` even when `TOOLS=OFF`, leaving a literal
  nonexistent library on the Windows link line;
- because `game` contains the V2 hook bridge, the test executable also needs
  the `playerbot-v2` implementation libraries.

Those CMake issues were corrected. A further runtime crash revealed that
vcpkg's imported Boost targets defaulted RelWithDebInfo to Debug libraries in
this prefix-path configuration. Boost targets are now mapped specifically to
Release, without applying a global imported-config mapping that would break
MySQL. Both `tests.exe` and `worldserver.exe` were relinked after this repair.

The resulting active suite passed all 36 test cases and 320 assertions. The
retired V1 tests are documented and omitted rather than presented as V2
coverage; the fork still lacks dedicated automated tests for most V2 gameplay
subsystems, so its built-in GM smoke tests remain part of live-realm validation.

## First-boot database repair

Static runtime tracing found that the original migration runner executed all
numbered SQL through `CharacterDatabase`, but the name pool, world metadata,
and dungeon route readers qualified queries with a separately configured
`Playerbot.SharedDatabase`. The installation guide likewise instructed users
to import migrations into that separate schema. A successful build would
therefore still fail to find several core tables on first boot.

The runtime and migration paths now consistently use TrinityCore's configured
characters database. Primary migrations 0001–0016 were verified contiguous and
each records its version. Four route/navigation files are applied automatically
as auxiliary versions 10001, 10003, 10004, and 10005. This avoids an additional
database connection and cross-schema privilege requirement while retaining
distinct Playerbot-owned table names.

This storage repair was rebuilt successfully and the complete unit suite was
rerun afterward.

The SQL runner now recognizes single/double-quoted strings, backtick identifiers,
MySQL `--`/`#` line comments, and block comments without splitting on embedded
semicolons. After executing a primary or auxiliary migration it queries the
schema-version table and refuses Playerbot initialization if completion was not
recorded. The shipped SQL set uses no stored-program `DELIMITER` constructs.

The 0015 name seed was also audited. Its `gender` field is inherited from the
AzerothCore source and is actually an 18-value race/gender category (even male,
odd female), not a three-value gender enum. Runtime loading now normalizes those
categories correctly; race-specific name selection remains unsupported in V2.

## Deployment verification

Every runtime configuration key was compared with `playerbot.conf.dist`; no
active key is missing from the distributed configuration. A clean staged
Windows installation was then performed with `cmake --install --prefix`.

The staged layout contained `worldserver.exe`, `playerbot.conf.dist`, all 15
primary SQL migrations, and all four auxiliary migrations. The initial staging
attempt exposed absolute Windows install destinations and an unquoted static
script cleanup list; both CMake issues were repaired. The final staged install
completed with exit code 0 and without the earlier CMake syntax warnings. The
installed `worldserver.exe --version` and `--help` checks both exited successfully,
and the installed bundle contains 16 primary plus four auxiliary migrations.

The migration runner now prefers source-tree SQL for development builds and
falls back to `sql/playerbot_v2` beside the loaded `worldserver.conf` for a
binary-only installation. This removes the previous requirement to retain the
original source checkout on the production host.

## Live repack verification

The final build was exercised against the supplied `C:\repack-12.0.7`
environment with its MySQL 8.2.0 schemas and extracted retail client data. The
core completed startup, initialized 369 DB2 stores, loaded the world data, and
reached the ready console. Playerbot applied primary versions 1–16 and auxiliary
versions 10001, 10003, 10004, and 10005, then reported `Initialization complete`.

The live Playerbot status/count smoke test reported 90 marked bots, 16 registered
bot sessions, 12 AI workers, active world updates, and zero intent failures or
exceptions. Shutdown initially exposed a reproducible core assertion in
`Map::EnsureGridLoaded` for Broken Isles (`map 1220`). Headless sessions are now
logged out synchronously, and transports are removed while their grids still
exist. The rebuilt server then completed a full interactive start and normal
`server shutdown` cycle without the assertion or a crash dump. A subsequent
idempotency boot reused every recorded migration and initialized successfully
again.

The five missing `RoadGraph.*` warnings in the supplied `Server.log` were fixed
in the live `worldserver.conf` with the distributed defaults. The live repack
also now uses `Playerbot.Population.TotalTarget = 100` and
`Playerbot.Population.AutoScale = 0`; this prevents further automatic mass
provisioning but deliberately does not delete the bot accounts/characters that
were already created during testing.

An August 30 live crash dump exposed a separate corpse-release edge case. A bot
below valid terrain produced zone ID `0`; `ObjectMgr::GetClosestGraveyard()`
then used the strict `AreaTable` accessor and asserted in `LookupEntry(0)`. The
stack was symbolized against the matching PDB through
`Playerbot::API::release_corpse`, `Player::RepopAtGraveyard`, and
`ObjectMgr::GetClosestGraveyard`. The graveyard lookup now uses the nullable
DB2 accessor and falls back to the faction graveyard when the area record is
missing. The incremental server build linked successfully, all 320 assertions
still pass, and the corrected 49,374,720-byte executable is deployed.

The verified runtime is installed under
`C:\repack-12.0.7\playerbot-v2-runtime`; `Start-Playerbot-V2.cmd` selects the
matching OpenSSL provider and starts it with the repack configuration. The
Playerbot configuration and SQL bundle are installed beside the existing
configuration. The original repack server executable was not overwritten.

## Runtime work still required

The database-backed boot and basic console smoke test now pass. Before treating
the server as production-ready:

1. Test one bot through login/logout, movement, combat, death, questing, loot,
   vendors, chat, and grouping.
2. Validate every 12.0.7 class/spec rotation and talent profile.
3. Exercise LFG, battlegrounds, guilds, mail, auctions, and population scaling,
   followed by a long soak test.

Known functional gaps include battle-pet completeness, the optional client
control addon's stubbed server surface, missing migration from legacy
AzerothCore Playerbots data, and retail replacements for WotLK-specific
dungeon/raid strategies.
