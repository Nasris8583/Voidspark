#include "LoreKnowledge.h"

#include "DatabaseEnv.h"
#include "GameTime.h"
#include "Log.h"
#include "Player.h"

#include <algorithm>
#include <cctype>
#include <sstream>

namespace Playerbot {

LoreKnowledge& LoreKnowledge::Instance()
{
    static LoreKnowledge store;
    return store;
}

std::string LoreKnowledge::Normalize(std::string const& text)
{
    std::string out;
    out.reserve(std::min<size_t>(text.size(), 512));
    bool space = true;
    for (unsigned char c : text)
    {
        if (out.size() == 512) break;
        if (std::isalnum(c)) { out.push_back(char(std::tolower(c))); space = false; }
        else if (!space) { out.push_back(' '); space = true; }
    }
    while (!out.empty() && out.back() == ' ') out.pop_back();
    return out;
}

bool LoreKnowledge::ContainsPhrase(std::string const& text, std::string const& phrase)
{
    size_t pos = text.find(phrase);
    while (pos != std::string::npos)
    {
        bool const left = pos == 0 || text[pos - 1] == ' ';
        bool const right = pos + phrase.size() == text.size() || text[pos + phrase.size()] == ' ';
        if (left && right) return true;
        pos = text.find(phrase, pos + 1);
    }
    return false;
}

void LoreKnowledge::Reload()
{
    std::lock_guard lock(mutex_);
    entries_.clear();
    contexts_.clear();
    auto result = CharacterDatabase.Query(
        "SELECT topic_key, aliases, short_answer, long_answer "
        "FROM playerbot_v2_lore_topic WHERE enabled = 1 ORDER BY priority DESC, topic_key");
    if (result)
    {
        do
        {
            Field* f = result->Fetch();
            Entry e;
            e.key = Normalize(f[0].GetString());
            e.short_answer = f[2].GetString();
            e.long_answer = f[3].GetString();
            std::stringstream aliases(f[1].GetString());
            std::string alias;
            while (std::getline(aliases, alias, '|'))
                if (auto n = Normalize(alias); !n.empty()) e.aliases.push_back(std::move(n));
            if (!e.key.empty()) e.aliases.push_back(e.key);
            if (!e.aliases.empty() && !e.short_answer.empty()) entries_.push_back(std::move(e));
        } while (result->NextRow());
    }
    loaded_ = true;
    TC_LOG_INFO("playerbot.v2", "[PlayerbotV2 Lore] Loaded {} lore topics.", entries_.size());
}

void LoreKnowledge::EnsureLoaded()
{
    std::lock_guard lock(mutex_);
    if (loaded_) return;
    // Avoid recursive locking by doing the small initial load inline.
    auto result = CharacterDatabase.Query(
        "SELECT topic_key, aliases, short_answer, long_answer "
        "FROM playerbot_v2_lore_topic WHERE enabled = 1 ORDER BY priority DESC, topic_key");
    if (result)
    {
        do
        {
            Field* f = result->Fetch();
            Entry e{Normalize(f[0].GetString()), {}, f[2].GetString(), f[3].GetString()};
            std::stringstream aliases(f[1].GetString());
            std::string alias;
            while (std::getline(aliases, alias, '|'))
                if (auto n = Normalize(alias); !n.empty()) e.aliases.push_back(std::move(n));
            e.aliases.push_back(e.key);
            entries_.push_back(std::move(e));
        } while (result->NextRow());
    }
    loaded_ = true;
}

bool LoreKnowledge::LooksLikeQuestion(std::string const& message) const
{
    std::string const n = Normalize(message);
    static char const* cues[] = { "who", "what", "why", "how", "where", "when",
        "tell me", "explain", "lore", "history", "story", "what happened", "do you know" };
    for (char const* cue : cues)
        if (ContainsPhrase(n, cue)) return true;
    return false;
}

std::string LoreKnowledge::Answer(Player const* asker, Player const* speaker,
                                  std::string const& message, bool detailed)
{
    EnsureLoaded();
    std::lock_guard lock(mutex_);
    std::string const n = Normalize(message);
    uint64_t const askerId = asker ? asker->GetGUID().GetCounter() : 0;
    uint32_t const now = GameTime::GetGameTimeMS();

    Entry const* chosen = nullptr;
    size_t score = 0;
    bool const followup = ContainsPhrase(n, "tell me more") || ContainsPhrase(n, "more lore") ||
        ContainsPhrase(n, "what happened next") || ContainsPhrase(n, "go on");
    if (followup)
    {
        auto it = contexts_.find(askerId);
        if (it != contexts_.end() && now - it->second.at_ms < 10u * 60u * 1000u)
            for (Entry const& e : entries_) if (e.key == it->second.topic) { chosen = &e; break; }
        detailed = true;
    }
    if (!chosen)
    {
        for (Entry const& e : entries_)
            for (std::string const& alias : e.aliases)
                if (alias.size() >= 3 && ContainsPhrase(n, alias) && alias.size() > score)
                { chosen = &e; score = alias.size(); }
    }

    if (!chosen)
        return "I don't know that part well. Try asking me about Azeroth, the Titans, the Horde, the Alliance, the Old Gods, the Burning Legion, Arthas, Illidan, or the Dragon Aspects.";

    contexts_[askerId] = {chosen->key, now};
    std::string answer = detailed && !chosen->long_answer.empty() ? chosen->long_answer : chosen->short_answer;
    if (speaker && speaker->GetTeamId() == TEAM_HORDE && chosen->key == "horde")
        answer = "From our side of the story: " + answer;
    else if (speaker && speaker->GetTeamId() == TEAM_ALLIANCE && chosen->key == "alliance")
        answer = "From our side of the story: " + answer;
    return answer;
}

} // namespace Playerbot
