if not game:IsLoaded() then game.Loaded:Wait() end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/UnknownDev125/Nexus-Source/refs/heads/main/source.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local Window = Library:CreateWindow({Name = "Nexus | Hooked"})

local Combat = Window:AddTab("Combat")
local Visuals = Window:AddTab("Visuals")
local ConfigTab = Window:AddTab("Config")

local Config = {
    HookHitbox = false,
    HookHitboxSize = 10,
    HookHitboxColor = Color3.fromRGB(255,0,0),
    HookHitboxTransparency = 0.5,
    BoxESP = false,
    NameESP = false,
    Chams = false,
    ESPColor = Color3.fromRGB(0,255,0),
}

local OriginalHookParts = {}
local ESPObjects = {}
local ConfigFileName = "Nexus_Hooked_Config.json"

local function SerializeColor3(c) return {r=c.R,g=c.G,b=c.B} end
local function DeserializeColor3(d) return Color3.new(d.r,d.g,d.b) end

local function SaveConfigToFile()
    local success = pcall(function()
        local data = {}
        for k,v in pairs(Config) do
            data[k] = typeof(v) == "Color3" and SerializeColor3(v) or v
        end
        writefile(ConfigFileName, HttpService:JSONEncode(data))
    end)
    return success
end

local function LoadConfigFromFile()
    local success, data = pcall(function()
        if not isfile(ConfigFileName) then return nil end
        return HttpService:JSONDecode(readfile(ConfigFileName))
    end)
    if success and data then
        for k,v in pairs(data) do
            if k:find("Color") then Config[k] = DeserializeColor3(v)
            else Config[k] = v end
        end
        return true
    end
    return false
end

local function ResetConfig()
    Config = {
        HookHitbox = false,
        HookHitboxSize = 10,
        HookHitboxColor = Color3.fromRGB(255,0,0),
        HookHitboxTransparency = 0.5,
        BoxESP = false,
        NameESP = false,
        Chams = false,
        ESPColor = Color3.fromRGB(0,255,0),
    }
end

ConfigTab:AddSection("Config Management")
ConfigTab:AddButton({Name="Save Config",Callback=function()
    local s=SaveConfigToFile()
    StarterGui:SetCore("SendNotification",{Title="Nexus",Text=s and "Saved!" or "Failed!",Duration=3})
end})
ConfigTab:AddButton({Name="Load Config",Callback=function()
    local l=LoadConfigFromFile()
    StarterGui:SetCore("SendNotification",{Title="Nexus",Text=l and "Loaded!" or "No config!",Duration=3})
end})
ConfigTab:AddButton({Name="Reset Settings",Callback=function()
    ResetConfig()
    StarterGui:SetCore("SendNotification",{Title="Nexus",Text="Reset!",Duration=3})
end})
ConfigTab:AddButton({Name="Delete Config",Callback=function()
    pcall(function() if isfile(ConfigFileName) then delfile(ConfigFileName) end end)
    StarterGui:SetCore("SendNotification",{Title="Nexus",Text="Deleted!",Duration=3})
end})

Combat:AddSection("Hook Hitbox")
Combat:AddLabel("Makes hooking enemies easier by expanding their hitbox")
Combat:AddToggle({Name="Enabled",Default=false,Callback=function(v)
    Config.HookHitbox = v
    if not v then
        for part,data in pairs(OriginalHookParts) do
            if part and part.Parent then
                pcall(function()
                    part.Size = data.Size
                    part.Transparency = data.Transparency
                    part.Color = data.Color
                    part.Material = data.Material or Enum.Material.Plastic
                    part.CanCollide = true
                end)
            end
        end
        OriginalHookParts = {}
    end
end})
Combat:AddSlider({Name="Hitbox Size",Min=1,Max=30,Default=10,Callback=function(v)
    Config.HookHitboxSize = v
    if Config.HookHitbox then
        for part,_ in pairs(OriginalHookParts) do
            if part and part.Parent then
                pcall(function()
                    part.Size = Vector3.new(v, v, v)
                end)
            end
        end
    end
end})
Combat:AddSlider({Name="Transparency",Min=0,Max=100,Default=50,Callback=function(v)
    Config.HookHitboxTransparency = v/100
    if Config.HookHitbox then
        for part,_ in pairs(OriginalHookParts) do
            if part and part.Parent then
                pcall(function()
                    part.Transparency = v/100
                end)
            end
        end
    end
end})
Combat:AddColorPicker({Name="Hitbox Color",Default=Config.HookHitboxColor,Callback=function(c)
    Config.HookHitboxColor = c
    if Config.HookHitbox then
        for part,_ in pairs(OriginalHookParts) do
            if part and part.Parent then
                pcall(function()
                    part.Color = c
                end)
            end
        end
    end
end})

Visuals:AddSection("ESP")
Visuals:AddToggle({Name="Box ESP",Default=false,Callback=function(v)Config.BoxESP=v end})
Visuals:AddToggle({Name="Name ESP",Default=false,Callback=function(v)Config.NameESP=v end})
Visuals:AddToggle({Name="Chams",Default=false,Callback=function(v)Config.Chams=v end})
Visuals:AddColorPicker({Name="ESP Color",Default=Config.ESPColor,Callback=function(c)Config.ESPColor=c end})

Visuals:AddSection("UI")
Visuals:AddLabel("Press NX or RightCtrl to toggle UI")
Visuals:AddButton({Name="Hide Window",Callback=function()
    Window.Main.Visible=false
    Window.Visible=false
end})
Visuals:AddButton({Name="Show Window",Callback=function()
    Window.Main.Visible=true
    Window.Visible=true
end})

local function ClearESP(p)
    if ESPObjects[p] then
        for _,o in pairs(ESPObjects[p]) do
            if typeof(o)=="Instance" then pcall(function() o:Destroy() end)
            elseif type(o)=="table" and o.Remove then pcall(function() o:Remove() end) end
        end
        ESPObjects[p]=nil
    end
end

local function IsAlive(p)
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function IsEnemy(p)
    if p == LocalPlayer then return false end
    return true
end

local function UpdateESP(p)
    if not IsEnemy(p) then ClearESP(p) return end
    local c = p.Character
    if not c or not IsAlive(p) then ClearESP(p) return end
    local root = c:FindFirstChild("HumanoidRootPart")
    local head = c:FindFirstChild("Head")
    if not root or not head then ClearESP(p) return end
    if not ESPObjects[p] then ESPObjects[p] = {} end
    local store = ESPObjects[p]
    if Config.BoxESP or Config.Chams then
        if not store.Highlight then
            local hl = Instance.new("Highlight")
            hl.Adornee = c
            hl.FillTransparency = Config.Chams and 0.3 or 0.8
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = CoreGui
            store.Highlight = hl
        end
        store.Highlight.Adornee = c
        store.Highlight.FillColor = Config.ESPColor
        store.Highlight.OutlineColor = Config.ESPColor
        store.Highlight.FillTransparency = Config.Chams and 0.3 or 0.8
        store.Highlight.Enabled = true
    elseif store.Highlight then
        store.Highlight.Enabled = false
        store.Highlight.Adornee = nil
    end
    if Config.NameESP then
        if not store.Billboard then
            local bb = Instance.new("BillboardGui")
            bb.Size = UDim2.new(0,120,0,18)
            bb.AlwaysOnTop = true
            bb.Parent = CoreGui
            local tl = Instance.new("TextLabel")
            tl.Size = UDim2.new(1,0,1,0)
            tl.BackgroundTransparency = 1
            tl.Font = Enum.Font.GothamBold
            tl.TextSize = 14
            tl.TextStrokeTransparency = 0.5
            tl.Parent = bb
            store.Billboard = bb
            store.NameLabel = tl
        end
        store.Billboard.Adornee = head
        store.NameLabel.Text = p.DisplayName or p.Name
        store.NameLabel.TextColor3 = Config.ESPColor
        store.Billboard.Enabled = true
    elseif store.Billboard then
        store.Billboard.Enabled = false
        store.Billboard.Adornee = nil
    end
end

local function ApplyHookHitbox(p)
    if p == LocalPlayer then return end
    if not Config.HookHitbox then return end
    
    local c = p.Character
    if not c or not IsAlive(p) then return end
    
    local hitParts = {}
    for _,part in ipairs(c:GetDescendants()) do
        if part:IsA("BasePart") then
            local name = part.Name:lower()
            if name:find("handle") or name:find("torso") or name:find("head") or 
               name:find("arm") or name:find("leg") or name:find("root") or
               part:FindFirstChild("Attachment") then
                table.insert(hitParts, part)
            end
        end
    end
    
    if #hitParts == 0 then
        for _,part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then
                table.insert(hitParts, part)
            end
        end
    end
    
    for _,part in ipairs(hitParts) do
        if not OriginalHookParts[part] then
            OriginalHookParts[part] = {
                Size = part.Size,
                Transparency = part.Transparency,
                Color = part.Color,
                Material = part.Material,
                CanCollide = part.CanCollide
            }
        end
        pcall(function()
            part.Size = Vector3.new(Config.HookHitboxSize, Config.HookHitboxSize, Config.HookHitboxSize)
            part.Transparency = Config.HookHitboxTransparency
            part.Color = Config.HookHitboxColor
            part.CanCollide = false
            part.Material = Enum.Material.ForceField
        end)
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        ClearESP(p)
        if OriginalHookParts then
            for part,data in pairs(OriginalHookParts) do
                if part and part.Parent then
                    pcall(function()
                        part.Size = data.Size
                        part.Transparency = data.Transparency
                        part.Color = data.Color
                        part.Material = data.Material or Enum.Material.Plastic
                        part.CanCollide = true
                    end)
                end
            end
            OriginalHookParts = {}
        end
    end)
end)

LocalPlayer.CharacterAdded:Connect(function()
    for p,_ in pairs(ESPObjects) do ClearESP(p) end
    for part,data in pairs(OriginalHookParts) do
        if part and part.Parent then
            pcall(function()
                part.Size = data.Size
                part.Transparency = data.Transparency
                part.Color = data.Color
                part.Material = data.Material or Enum.Material.Plastic
                part.CanCollide = true
            end)
        end
    end
    OriginalHookParts = {}
end)

RunService.RenderStepped:Connect(function()
    for _,p in ipairs(Players:GetPlayers()) do
        ApplyHookHitbox(p)
        UpdateESP(p)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    ClearESP(p)
end)

LoadConfigFromFile()
print("Nexus | Hooked loaded - Hitbox expander ready!")
