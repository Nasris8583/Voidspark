# TrinityCore 12.0.7 Playerbot V2 Easy Pack

This installs the tested Playerbot V2 system into an **existing TrinityCore 12.0.7 single-player server**.

It does not include World of Warcraft client files, DB2 files, maps, vmaps, mmaps, or a database. Your friend must already have a working 12.0.7 server and client.

## Quick installation

1. Shut down `worldserver.exe` and `bnetserver.exe`.
2. Extract this entire pack to a normal folder.
3. Right-click `Install-PlayerbotV2.cmd` and choose **Run as administrator** if the server is under a protected folder.
4. Enter the existing server folder, for example `C:\repack-12.0.7`.
5. Start the server with the new `Start-Playerbot-V2.cmd` shortcut in that server folder.
6. Wait until the window says the world server is ready, then log in.

The first startup automatically creates or updates the Playerbot database tables. Existing database passwords and server data are not replaced.

## First in-game test

Use a GM account and enter:

```text
.playerbot status
.playerbot count
.playerbot health
```

The included profile gradually starts up to 40 bots. This is the tested safe setting for a 16 GB machine. On a 32 GB or larger machine, edit `playerbot.conf` and raise `TotalTarget`, `Floor`, `Ceiling`, and `AutoResumeCap` together.

Bots respond to appropriate player messages in `/say`, `/yell`, party, guild, and whisper chat. They also react to emotes, accept player invitations, and provide supported group buffs.

Bots can answer a broad offline library of WoW lore questions. For example:

```text
/say Who is Arthas?
/say Tell me about the Titans
/say What is the Worldsoul Saga?
```

Whispering a bot gives room for a longer response. After an answer, use `tell me more`, `go on`, or `what happened next`; the bot remembers your last topic for ten minutes. The lore library is curated and does not use the internet or an external AI account.

## Important compatibility limits

- Intended for TrinityCore 12.0.7 / client build 68887.
- Replaces the server's world and login executables with the matched Playerbot build.
- Do not install it over a different expansion or newer 12.1.x server.
- Keep automatic battleground seeding and housing disabled on low-memory computers.
- The first visit to a map can briefly pause while navigation data loads on demand. This prevents the older 20+ GB eager-loading problem.

## Starting and stopping

- Start: `Start-Playerbot-V2.cmd`
- Stop: `Stop-Playerbot-V2.cmd`

Always stop the server before shutting down Windows.

## Restoring the old server

Run `Restore-PlayerbotV2-Backup.cmd` from the installed server folder. The installer creates a timestamped backup under `playerbot-v2-backups` before changing files.

Database migrations are additive and are not removed by file restoration. They are isolated in tables named `playerbot_v2_*` and are harmless when the original executable is restored.

## Useful commands

```text
.playerbot count
.playerbot list
.playerbot health
.playerbot activity
.playerbot wedges
.playerbot inspect BOTNAME
.playerbot summonall
.playerbot logoutall
```

Avoid `.playerbot loginall` on a 16 GB computer. The configured population manager starts bots gradually.

## Troubleshooting

- Stuck at “Logging into game server”: verify the client is exactly 12.0.7.68887 and both services were started by the included launcher.
- High latency: lower the four population values in `playerbot.conf`, restart, and test again.
- Startup migration error: verify the pack installed `sql\playerbot_v2` under the server folder.
- Crash: send `Server.log` and the newest files from `playerbot-v2-runtime\Crashes`.

See `docs\CHANGES-AND-LIMITS.md` for technical details.
