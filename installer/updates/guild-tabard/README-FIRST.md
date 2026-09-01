# Voidspark Automatic Guild Tabards 1.0

This one-click update makes guilded bots automatically wear the standard dynamic Guild Tabard. World of Warcraft renders that item with the wearer's current guild emblem, so bots from different guilds display their respective guild designs.

## Install

1. Stop `worldserver.exe` and `bnetserver.exe`.
2. Extract the complete ZIP.
3. Double-click `Install-Guild-Tabards.cmd`.
4. Select the existing TrinityCore 12.0.7 Voidspark server folder.
5. Start the server normally.

No manual editing is required. The updater checks its executable, backs up the existing world server and `playerbot.conf`, installs the new server, and enables the feature.

Existing guilded bots equip their tabard when they next log in. Bots that found or join a guild while online equip it immediately. Guildless bots and all real-player inventories are untouched.

The feature replaces another cosmetic tabard already worn by a bot. It does not replace armor or combat equipment.

