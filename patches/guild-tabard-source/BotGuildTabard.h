#pragma once

class Player;

namespace Playerbot::V2 {

// Equip the standard dynamic guild tabard. The client renders this item with
// the wearer's own guild emblem.
bool EnsureBotGuildTabard(Player* bot);

} // namespace Playerbot::V2

