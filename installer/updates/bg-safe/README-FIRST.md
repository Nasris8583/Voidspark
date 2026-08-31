# Voidspark 16 GB Battleground Safe Update

Use this one-click profile on 16 GB Windows PCs that encounter `std::bad_alloc` or very low available memory when entering battlegrounds.

## Install

1. Stop `worldserver.exe` and `bnetserver.exe`.
2. Extract the entire update ZIP.
3. Double-click `Install-16GB-BG-Safe.cmd`.
4. Select the existing TrinityCore 12.0.7 Voidspark server folder.
5. Start the server normally.
6. Wait for the bots to finish logging in before entering a battleground.

No manual editing is required. The updater backs up `playerbot.conf`, preserves database and realm settings, and changes only Playerbot resource settings.

## Applied profile

- 20 active bots maximum.
- Two AI workers and one snapshot worker.
- Automatic bot-only battleground and arena seeding disabled.
- Battleground team coordination remains enabled for normal play.
- Bot housing remains disabled.

The backup location is printed after installation and recorded in `playerbot-v2-bg-safe-update.txt` in the server folder.

This update cannot compensate for other applications consuming most of the machine's memory. Close browsers and other large applications before running the server and client together.

