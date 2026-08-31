#pragma once

#include <cstdint>
#include <mutex>
#include <string>
#include <unordered_map>
#include <vector>

class Player;

namespace Playerbot {

class LoreKnowledge
{
public:
    static LoreKnowledge& Instance();
    void Reload();
    bool LooksLikeQuestion(std::string const& message) const;
    std::string Answer(Player const* asker, Player const* speaker,
                       std::string const& message, bool detailed);

private:
    struct Entry
    {
        std::string key;
        std::vector<std::string> aliases;
        std::string short_answer;
        std::string long_answer;
    };
    struct Context { std::string topic; uint32_t at_ms = 0; };

    void EnsureLoaded();
    static std::string Normalize(std::string const& text);
    static bool ContainsPhrase(std::string const& text, std::string const& phrase);

    mutable std::mutex mutex_;
    bool loaded_ = false;
    std::vector<Entry> entries_;
    std::unordered_map<uint64_t, Context> contexts_;
};

} // namespace Playerbot
