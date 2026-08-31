# Voidspark

Voidspark is a TrinityCore 12.0.7 Playerbot V2 compatibility project and Windows easy-installer for private, single-player development realms.

It ports the Playerbot V2 system to the TrinityCore 12.0.7 API, fixes compile and runtime failures found during integration, and provides a conservative social-bot profile for machines with 16 GB of RAM.

> [!IMPORTANT]
> Voidspark does not contain World of Warcraft client files, Blizzard assets, databases, DB2 files, maps, vmaps, or mmaps. You need an existing working TrinityCore 12.0.7 server and a compatible 12.0.7.68887 client.

## Download

Download [`TrinityCore-12.0.7-PlayerbotV2-EasyPack.zip`](dist/TrinityCore-12.0.7-PlayerbotV2-EasyPack.zip), extract it, and read `README-FIRST.md`.

SHA-256:

```text
9A4CCB78004AC6FD29C18EDD87F7B3881F79D33ECF165961E34D49B968718DFA
```

## Features

- Headless bot login and logout integrated with TrinityCore 12.0.7.
- Gradual population management with a tested 40-bot default.
- Player-facing `/say`, `/yell`, party, guild, whisper, and emote reactions.
- Database-backed WoW lore answers across local, party, guild, and whisper chat, with short conversational follow-ups.
- Player invitations, supported group buffs, guild recruitment, and scheduled guild activity.
- Automatic, versioned character-database migrations.
- One-click Windows installer with timestamped backups and restoration tools.
- Memory fixes that remove eager terrain/navmesh loading for every common zone and battleground.
- Shutdown, map unload, graveyard fallback, MySQL/CMake, and API compatibility fixes.

## Supported environment

| Component | Supported value |
|---|---|
| TrinityCore line | 12.0.7 Playerbot V2 fork |
| Tested source revision | `57655680a93c` |
| Client | 12.0.7.68887 |
| Server OS | Windows x64 |
| Recommended RAM | 16 GB for 40 bots; 32 GB or more for experimental larger fleets |
| Database | MySQL 8.0.x |

This is not a drop-in package for TrinityCore 12.1.x, older expansions, AzerothCore, or other emulator projects.

## Installation

1. Start with a functioning TrinityCore 12.0.7 server.
2. Stop `worldserver.exe` and `bnetserver.exe`.
3. Extract the Easy Pack.
4. Run `Install-PlayerbotV2.cmd`.
5. Enter the existing server directory.
6. Start it using the installed `Start-Playerbot-V2.cmd`.
7. Wait for the world server to report that it is ready.

The installer keeps the existing database configuration, creates a timestamped file backup, installs matched server executables, deploys SQL migrations, and applies the low-memory runtime profile.

Detailed instructions: [Easy Pack guide](docs/README-FIRST.md)

## First test

Log in using a GM account and run:

```text
.playerbot status
.playerbot count
.playerbot health
.playerbot list
```

The fleet fills gradually. Useful diagnostics include:

```text
.playerbot activity
.playerbot wedges
.playerbot fleethealth
.playerbot inspect BOTNAME
```

Try the lore system with ordinary questions:

```text
/say Who is Arthas?
/say What are the Old Gods?
/say Tell me about the Titans
```

You can also whisper a bot for a longer reply, then say `tell me more`, `go on`, or `what happened next`. The bot remembers that player's last lore topic for ten minutes.

## Repository layout

```text
config/       Tested low-memory Playerbot profile
dist/         Ready-to-install Windows package
docs/         Installation, build, assessment, and compatibility reports
installer/    Installer and server-tool source
patches/      Source patch against TrinityCore/Playerbot V2
sql/          Versioned bot and navigation migrations
```

## Building from source

The main adaptation is represented by [`patches/trinitycore-playerbot-v2-12.0.7.patch`](patches/trinitycore-playerbot-v2-12.0.7.patch), followed by [`patches/0002-low-memory-on-demand-terrain.patch`](patches/0002-low-memory-on-demand-terrain.patch). Apply them to the matching Playerbot V2/TrinityCore base and build with Visual Studio 2026, CMake, Ninja, Boost, OpenSSL, and MySQL development libraries.

The conversational lore implementation is available as the apply-ready [`0003-conversational-wow-lore.patch`](patches/0003-conversational-wow-lore.patch). It includes the chat-reactor integration, lore knowledge source, and migration `0017`. Copy the patch into the matching TrinityCore source root, then run:

```text
git apply --check patches/0003-conversational-wow-lore.patch
git apply patches/0003-conversational-wow-lore.patch
```

The individual source snapshots remain under [`patches/lore-source`](patches/lore-source), and the standalone migration is at [`0017_lore_knowledge.sql`](sql/playerbot_v2/0017_lore_knowledge.sql).

See the [build report](docs/trinitycore-12.0.7-playerbot-v2-build-report.md) for the tested build and runtime history.

## Scaling warning

Testing on a 16 GB host showed that 60–100 active bots exhausted physical and committed-memory headroom and recreated severe paging/latency risk. The distributed profile therefore uses 40 bots. Larger fleets require more RAM, a larger page file, and staged latency testing.

## Known limitations

- Not every retail dungeon, raid, battleground, quest, class mechanic, or modern subsystem has bespoke AI.
- Nearby buffs are primarily group-oriented.
- Bots do not recursively answer other bot messages, preventing local-channel echo storms.
- Lore answers are a curated offline knowledge base, not a live AI service. Broad Warcraft topics are covered, but obscure NPCs, newly released material, and ambiguous questions can still receive a topic suggestion instead of a specific answer.
- Navigation data loads on first use, so the first entry into a map can briefly pause.
- The packaged executable can display an `unknown/Archived` revision label because the final binary was linked from a relocated checkout; protocol compatibility remains 12.0.7.

See [changes and limits](docs/CHANGES-AND-LIMITS.md) for more detail.

## Contributing

Bug reports should include `Server.log`, the newest crash report, `.playerbot` diagnostics, bot count, and observed world latency. Remove credentials and account details first.

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a patch.

## License and legal notice

The TrinityCore-derived source adaptation is distributed under the GNU General Public License v2; see [COPYING](COPYING). Bundled third-party runtime libraries retain their respective upstream licenses.

This project is not affiliated with or endorsed by Blizzard Entertainment. World of Warcraft and related names are trademarks of Blizzard Entertainment. Users are responsible for complying with applicable software licenses and local law.
