if not game:IsLoaded() then game.Loaded:Wait() end

local PlaceId = game.PlaceId
local UniverseId = game.GameId or ""

print("[Nexus Hub] Place ID detected:", PlaceId)
print("[Nexus Hub] Universe ID detected:", UniverseId)

local Games = {
    [286090429] = {
        Name = "Arsenal",
        Script = "https://raw.githubusercontent.com/UnknownDev125/Nexus-Hub/refs/heads/main/arsenal.lua"
    },
    [11064669018] = {
        Name = "Hooked",
        Script = "https://raw.githubusercontent.com/UnknownDev125/Nexus-Hub/refs/heads/main/hooked.lua"
    },
    [14979493662] = {
        Name = "Hooked",
        Script = "https://raw.githubusercontent.com/UnknownDev125/Nexus-Hub/refs/heads/main/hooked.lua"
    },
    [14831286693] = {
        Name = "Hooked",
        Script = "https://raw.githubusercontent.com/UnknownDev125/Nexus-Hub/refs/heads/main/hooked.lua"
    },
    [72659788689464] = {
        Name = "Life in Prison",
        Script = "https://raw.githubusercontent.com/UnknownDev125/Nexus-Hub/refs/heads/main/lifeinprison.lua"
    },
}

local Entry = Games[PlaceId]
local ScriptToLoad = nil
local GameName = ""

if Entry then
    ScriptToLoad = Entry.Script
    GameName = Entry.Name
    print("[Nexus Hub] Found game by Place ID:", GameName)
elseif PlaceId == 100301524538263 or UniverseId == 9663968307 then
    ScriptToLoad = "https://raw.githubusercontent.com/UnknownDev125/Nexus-Hub/refs/heads/main/hooked.lua"
    GameName = "Hooked FFA"
    print("[Nexus Hub] Found Hooked FFA by Universe/Place ID")
else
    local success, info = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    end)
    if success and info then
        local name = info.Name or ""
        if name:lower():find("hooked") then
            ScriptToLoad = "https://raw.githubusercontent.com/UnknownDev125/Nexus-Hub/refs/heads/main/hooked.lua"
            GameName = "Hooked"
            print("[Nexus Hub] Found Hooked by game name")
        end
    end
end

if ScriptToLoad then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Nexus Hub",
        Text = "Loading " .. GameName .. "...",
        Duration = 3,
    })
    print("[Nexus Hub] Loading script from:", ScriptToLoad)
    local ok, err = pcall(function()
        loadstring(game:HttpGet(ScriptToLoad))()
    end)
    if not ok then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Nexus Hub",
            Text = "Failed to load " .. GameName,
            Duration = 5,
        })
        warn("[Nexus Hub] Error: " .. tostring(err))
    end
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Nexus Hub",
        Text = "No script available for this game.",
        Duration = 5,
    })
end
