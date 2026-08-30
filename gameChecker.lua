if not game:IsLoaded() then game.Loaded:Wait() end

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

-- Add Hooked FFA as a separate check
local HookedFFA = 9663968307

local PlaceId = game.PlaceId
local Entry = Games[PlaceId]

-- Debug print
print("[Nexus Hub] Place ID detected:", PlaceId)

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
elseif PlaceId == HookedFFA then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Nexus Hub",
        Text = "Loading Hooked FFA...",
        Duration = 3,
    })
    local ok, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/UnknownDev125/Nexus-Hub/refs/heads/main/hooked.lua"))()
    end)
    if not ok then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Nexus Hub",
            Text = "Failed to load Hooked FFA",
            Duration = 5,
        })
        warn("[Nexus Hub] " .. tostring(err))
    end
else
    -- Fallback detection
    local isHooked = false
    
    local success, info = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    end)
    if success and info then
        local name = info.Name or ""
        if name:lower():find("hooked") then
            isHooked = true
        end
    end
    
    if game.JobId and game.JobId:lower():find("hooked") then
        isHooked = true
    end
    
    if isHooked then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Nexus Hub",
            Text = "Loading Hooked...",
            Duration = 3,
        })
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/UnknownDev125/Nexus-Hub/refs/heads/main/hooked.lua"))()
        end)
        if not ok then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Nexus Hub",
                Text = "Failed to load Hooked",
                Duration = 5,
            })
        end
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Nexus Hub",
            Text = "No script available for this game. Place ID: " .. PlaceId,
            Duration = 5,
        })
        print("[Nexus Hub] Unknown game - Place ID:", PlaceId)
    end
end
