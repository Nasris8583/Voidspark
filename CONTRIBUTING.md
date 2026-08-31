# Contributing

## Bug reports

Include the exact TrinityCore/client build, bot population, relevant `.playerbot` diagnostics, `Server.log`, and newest crash report. Remove passwords, public IP addresses, and account details before uploading logs.

## Source changes

1. Base changes on the tested 12.0.7 Playerbot V2 line.
2. Preserve bot behavior unless compatibility or safety requires a change.
3. Keep world-thread mutations on the world thread.
4. Test startup, bot login/logout, player chat, combat, travel, and shutdown.
5. Document unsupported behavior and memory/latency effects.

Do not submit Blizzard client files, extracted game data, database dumps containing account information, or credentials.
