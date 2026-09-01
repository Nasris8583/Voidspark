#include "BotGuildTabard.h"

#include "Config.h"
#include "Item.h"
#include "Log.h"
#include "ObjectMgr.h"
#include "Player.h"

namespace Playerbot::V2 {

bool EnsureBotGuildTabard(Player* bot)
{
    constexpr uint32 kGuildTabardEntry = 5976;

    if (!bot || bot->GetGuildId() == 0)
        return false;
    if (!sConfigMgr->GetBoolDefault("Playerbot.Guild.AutoEquipTabard", true))
        return false;

    Item* equipped = bot->GetItemByPos(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_TABARD);
    if (equipped && equipped->GetEntry() == kGuildTabardEntry)
        return true;

    if (!sObjectMgr->GetItemTemplate(kGuildTabardEntry))
    {
        TC_LOG_ERROR("playerbot.v2",
            "[GuildTabard] Item {} is unavailable; cannot equip guild tabard for {}",
            kGuildTabardEntry, bot->GetName());
        return false;
    }

    uint16 destination = 0;
    if (bot->CanEquipNewItem(EQUIPMENT_SLOT_TABARD, destination,
            kGuildTabardEntry, equipped != nullptr) != EQUIP_ERR_OK)
        return false;

    // Bot gear generation deliberately skips cosmetic slots. Replacing an
    // imported cosmetic tabard directly also works when every bag is full.
    if (equipped)
        bot->DestroyItem(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_TABARD, true);

    destination = 0;
    if (bot->CanEquipNewItem(EQUIPMENT_SLOT_TABARD, destination,
            kGuildTabardEntry, false) != EQUIP_ERR_OK)
        return false;

    if (!bot->EquipNewItem(destination, kGuildTabardEntry, ItemContext::NONE, true))
        return false;

    TC_LOG_INFO("playerbot.v2", "[GuildTabard] {} equipped the tabard for guild {}",
        bot->GetName(), bot->GetGuildId());
    return true;
}

} // namespace Playerbot::V2

