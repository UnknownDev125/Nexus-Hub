if not game:IsLoaded() then game.Loaded:Wait() end

local Games = {
    [286090429] = {
        Name = "Arsenal",
        Script = "https://raw.githubusercontent.com/UnknownDev125/Nexus-Hub/refs/heads/main/arsenal.lua"
    },
}

local PlaceId = game.PlaceId
local Entry = Games[PlaceId]

if Entry then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Nexus Hub",
        Text = "Loading " .. Entry.Name .. "...",
        Duration = 3,
    })
    local ok, err = pcall(function()
        loadstring(game:HttpGet(Entry.Script))()
    end)
    if not ok then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Nexus Hub",
            Text = "Failed to load " .. Entry.Name,
            Duration = 5,
        })
        warn("[Nexus Hub] " .. tostring(err))
    end
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Nexus Hub",
        Text = "No script available for this game.",
        Duration = 5,
    })
end
