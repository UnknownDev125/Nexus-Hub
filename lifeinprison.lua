if not game:IsLoaded() then game.Loaded:Wait() end

local PlaceId = game.PlaceId
local GameIds = {
    [72659788689464] = true,
}

if not GameIds[PlaceId] then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Nexus",
        Text = "This script only works for Life in Prison.",
        Duration = 5,
    })
    return
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/UnknownDev125/Nexus-Source/refs/heads/main/source.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Window = Library:CreateWindow({Name = "Nexus | Life in Prison"})

local Combat = Window:AddTab("Combat")
local Weapons = Window:AddTab("Weapons")
local Visuals = Window:AddTab("Visuals")
local Movement = Window:AddTab("Movement")
local Misc = Window:AddTab("Misc")

local Config = {
    Aimbot = false,
    AimbotFOV = 160,
    AimbotHitPart = "Head",
    AimbotTeamCheck = true,
    AimbotWallCheck = true,
    AimbotSmooth = 0.18,
    AimbotHold = true,
    ShowFOV = true,
    FOVColor = Color3.fromRGB(90, 120, 255),
    FOVColorTarget = Color3.fromRGB(255, 75, 85),
    FOVCenterLock = true,

    InfiniteAmmo = false,
    NoRecoil = false,
    RapidFire = false,
    InstantReload = false,

    BoxESP = false,
    NameESP = false,
    TracerESP = false,
    Chams = false,
    ESPColor = Color3.fromRGB(90, 120, 255),
    ESPTeamCheck = true,

    Speed = false,
    SpeedValue = 24,
    JumpPower = false,
    JumpValue = 60,
    Fly = false,
    FlySpeed = 50,
    NoClip = false,
}

local Holding = false
local FOVCircle = nil
local ESPObjects = {}
local BodyVelocity = nil
local HasClearTarget = false
local WeaponLoop = nil

local WeaponNames = {
    "M4A1", "AK47", "Glock", "Pistol", "Shotgun", "Sniper", "Rifle",
    "MP5", "Uzi", "Desert Eagle", "Revolver", "SMG", "AR15", "M9",
    "Combat Pistol", "Tactical Shotgun", "Assault Rifle", "Carbine",
    "Keycard", "Crowbar", "Knife", "Bat", "Taser", "Cuffs",
}

Combat:AddSection("Aimbot")
Combat:AddToggle({
    Name = "Enabled",
    Default = false,
    Callback = function(v) Config.Aimbot = v end
})
Combat:AddToggle({
    Name = "Hold to Aim",
    Default = true,
    Callback = function(v) Config.AimbotHold = v end
})
Combat:AddToggle({
    Name = "Wall Check",
    Default = true,
    Callback = function(v) Config.AimbotWallCheck = v end
})
Combat:AddToggle({
    Name = "Show FOV",
    Default = true,
    Callback = function(v) Config.ShowFOV = v end
})
Combat:AddToggle({
    Name = "FOV Center Lock",
    Default = true,
    Callback = function(v) Config.FOVCenterLock = v end
})
Combat:AddSlider({
    Name = "FOV Size",
    Min = 40,
    Max = 400,
    Default = 160,
    Callback = function(v) Config.AimbotFOV = v end
})
Combat:AddSlider({
    Name = "Smoothness",
    Min = 1,
    Max = 100,
    Default = 18,
    Callback = function(v) Config.AimbotSmooth = v / 100 end
})
Combat:AddDropdown({
    Name = "Hit Part",
    Options = {"Head", "HumanoidRootPart", "UpperTorso"},
    Default = "Head",
    Callback = function(v) Config.AimbotHitPart = v end
})
Combat:AddToggle({
    Name = "Team Check",
    Default = true,
    Callback = function(v) Config.AimbotTeamCheck = v end
})
Combat:AddColorPicker({
    Name = "FOV Color",
    Default = Config.FOVColor,
    Callback = function(c) Config.FOVColor = c end
})

Weapons:AddSection("Get Weapons")
Weapons:AddButton({
    Name = "Get All Tools Nearby",
    Callback = function()
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not char or not backpack then return end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") or obj:IsA("HopperBin") then
                pcall(function()
                    obj.Parent = backpack
                end)
            end
        end
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("Tool") then
                pcall(function()
                    local clone = obj:Clone()
                    clone.Parent = backpack
                end)
            end
        end
    end
})
Weapons:AddButton({
    Name = "Equip All From Backpack",
    Callback = function()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        local char = LocalPlayer.Character
        if not backpack or not char then return end
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                pcall(function()
                    tool.Parent = char
                end)
            end
        end
    end
})
Weapons:AddButton({
    Name = "Drop All Tools",
    Callback = function()
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if char then
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    pcall(function() tool.Parent = workspace end)
                end
            end
        end
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    pcall(function() tool.Parent = workspace end)
                end
            end
        end
    end
})

Weapons:AddSection("Gun Mods")
Weapons:AddToggle({
    Name = "Infinite Ammo",
    Default = false,
    Callback = function(v) Config.InfiniteAmmo = v end
})
Weapons:AddToggle({
    Name = "No Recoil",
    Default = false,
    Callback = function(v) Config.NoRecoil = v end
})
Weapons:AddToggle({
    Name = "Rapid Fire",
    Default = false,
    Callback = function(v) Config.RapidFire = v end
})
Weapons:AddToggle({
    Name = "Instant Reload",
    Default = false,
    Callback = function(v) Config.InstantReload = v end
})
Weapons:AddButton({
    Name = "Max Current Gun Stats",
    Callback = function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                for _, v in ipairs(tool:GetDescendants()) do
                    if v:IsA("NumberValue") or v:IsA("IntValue") then
                        local n = string.lower(v.Name)
                        if n:find("ammo") or n:find("clip") or n:find("magazine") then
                            pcall(function() v.Value = 999 end)
                        elseif n:find("damage") then
                            pcall(function() v.Value = 200 end)
                        elseif n:find("spread") or n:find("recoil") then
                            pcall(function() v.Value = 0 end)
                        elseif n:find("firerate") or n:find("fire rate") or n:find("cooldown") then
                            pcall(function() v.Value = 0.01 end)
                        elseif n:find("reload") then
                            pcall(function() v.Value = 0.05 end)
                        end
                    end
                end
            end
        end
    end
})

Visuals:AddSection("ESP")
Visuals:AddToggle({
    Name = "Box ESP",
    Default = false,
    Callback = function(v) Config.BoxESP = v end
})
Visuals:AddToggle({
    Name = "Name ESP",
    Default = false,
    Callback = function(v) Config.NameESP = v end
})
Visuals:AddToggle({
    Name = "Tracers",
    Default = false,
    Callback = function(v) Config.TracerESP = v end
})
Visuals:AddToggle({
    Name = "Chams",
    Default = false,
    Callback = function(v) Config.Chams = v end
})
Visuals:AddToggle({
    Name = "Team Check",
    Default = true,
    Callback = function(v) Config.ESPTeamCheck = v end
})
Visuals:AddColorPicker({
    Name = "ESP Color",
    Default = Config.ESPColor,
    Callback = function(c) Config.ESPColor = c end
})

Movement:AddSection("Character")
Movement:AddToggle({
    Name = "Speed",
    Default = false,
    Callback = function(v) Config.Speed = v end
})
Movement:AddSlider({
    Name = "Speed Value",
    Min = 16,
    Max = 120,
    Default = 24,
    Callback = function(v) Config.SpeedValue = v end
})
Movement:AddToggle({
    Name = "Jump Power",
    Default = false,
    Callback = function(v) Config.JumpPower = v end
})
Movement:AddSlider({
    Name = "Jump Value",
    Min = 50,
    Max = 200,
    Default = 60,
    Callback = function(v) Config.JumpValue = v end
})
Movement:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(v)
        Config.Fly = v
        if not v and BodyVelocity then
            BodyVelocity:Destroy()
            BodyVelocity = nil
        end
    end
})
Movement:AddSlider({
    Name = "Fly Speed",
    Min = 20,
    Max = 150,
    Default = 50,
    Callback = function(v) Config.FlySpeed = v end
})
Movement:AddToggle({
    Name = "NoClip",
    Default = false,
    Callback = function(v) Config.NoClip = v end
})

Misc:AddSection("UI")
Misc:AddLabel("NX button or RightCtrl toggles UI")
Misc:AddButton({
    Name = "Hide Window",
    Callback = function()
        Window.Main.Visible = false
        Window.Visible = false
    end
})
Misc:AddButton({
    Name = "Rejoin",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2
        or input.UserInputType == Enum.UserInputType.Touch
        or input.KeyCode == Enum.KeyCode.E then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2
        or input.UserInputType == Enum.UserInputType.Touch
        or input.KeyCode == Enum.KeyCode.E then
        Holding = false
    end
end)

local function IsAlive(plr)
    local c = plr.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function IsEnemy(plr, teamCheck)
    if plr == LocalPlayer then return false end
    if teamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then return false end
    return true
end

local function GetHitPart(char)
    return char:FindFirstChild(Config.AimbotHitPart)
        or char:FindFirstChild("Head")
        or char:FindFirstChild("HumanoidRootPart")
end

local function GetAimOrigin()
    if Config.FOVCenterLock then
        local vp = Camera.ViewportSize
        return Vector2.new(vp.X / 2, vp.Y / 2)
    end
    return UserInputService:GetMouseLocation()
end

local function IsVisible(part)
    if not Config.AimbotWallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = {LocalPlayer.Character, Camera}
    local targetChar = part:FindFirstAncestorOfClass("Model")
    if targetChar then table.insert(ignore, targetChar) end
    params.FilterDescendantsInstances = ignore
    params.IgnoreWater = true
    return workspace:Raycast(origin, direction, params) == nil
end

local function GetClosest()
    local best, bestDist = nil, Config.AimbotFOV
    local origin = GetAimOrigin()
    for _, plr in ipairs(Players:GetPlayers()) do
        if not IsEnemy(plr, Config.AimbotTeamCheck) then continue end
        if not IsAlive(plr) then continue end
        local char = plr.Character
        if not char then continue end
        local part = GetHitPart(char)
        if not part then continue end
        local sp, on = Camera:WorldToViewportPoint(part.Position)
        if not on or sp.Z < 0 then continue end
        local d = (Vector2.new(sp.X, sp.Y) - origin).Magnitude
        if d >= bestDist then continue end
        if not IsVisible(part) then continue end
        bestDist = d
        best = part
    end
    return best
end

if Drawing and Drawing.new then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 64
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.7
    FOVCircle.Visible = false
end

local function UpdateFOV()
    if not FOVCircle then return end
    FOVCircle.Position = GetAimOrigin()
    FOVCircle.Radius = Config.AimbotFOV
    FOVCircle.Color = HasClearTarget and Config.FOVColorTarget or Config.FOVColor
    FOVCircle.Visible = Config.ShowFOV and Config.Aimbot
end

local function RunAimbot()
    HasClearTarget = false
    if not Config.Aimbot then return end
    local target = GetClosest()
    if not target then return end
    HasClearTarget = true
    if Config.AimbotHold and not Holding then return end
    local goal = CFrame.new(Camera.CFrame.Position, target.Position)
    local smooth = math.clamp(Config.AimbotSmooth, 0.01, 1)
    Camera.CFrame = Camera.CFrame:Lerp(goal, smooth)
end

local function ApplyGunMods()
    local char = LocalPlayer.Character
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if not tool:IsA("Tool") then continue end
        for _, v in ipairs(tool:GetDescendants()) do
            if v:IsA("NumberValue") or v:IsA("IntValue") then
                local n = string.lower(v.Name)
                if Config.InfiniteAmmo and (n:find("ammo") or n:find("clip") or n:find("magazine")) then
                    pcall(function() v.Value = 999 end)
                end
                if Config.NoRecoil and (n:find("recoil") or n:find("spread") or n:find("kick")) then
                    pcall(function() v.Value = 0 end)
                end
                if Config.RapidFire and (n:find("firerate") or n:find("fire rate") or n:find("cooldown") or n:find("delay")) then
                    pcall(function() v.Value = 0.01 end)
                end
                if Config.InstantReload and n:find("reload") then
                    pcall(function() v.Value = 0.05 end)
                end
            end
        end
    end
end

local function ClearESP(plr)
    if ESPObjects[plr] then
        for _, obj in pairs(ESPObjects[plr]) do
            if typeof(obj) == "Instance" then
                pcall(function() obj:Destroy() end)
            elseif type(obj) == "table" and obj.Remove then
                pcall(function() obj:Remove() end)
            end
        end
        ESPObjects[plr] = nil
    end
end

local function UpdateESP(plr)
    if not IsEnemy(plr, Config.ESPTeamCheck) then
        ClearESP(plr)
        return
    end
    local char = plr.Character
    if not char or not IsAlive(plr) then
        ClearESP(plr)
        return
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not root or not head then
        ClearESP(plr)
        return
    end
    if not ESPObjects[plr] then ESPObjects[plr] = {} end
    local store = ESPObjects[plr]

    if Config.BoxESP or Config.Chams then
        if not store.Highlight then
            local hl = Instance.new("Highlight")
            hl.Adornee = char
            hl.FillTransparency = Config.Chams and 0.5 or 0.85
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = CoreGui
            store.Highlight = hl
        end
        store.Highlight.Adornee = char
        store.Highlight.FillColor = Config.ESPColor
        store.Highlight.OutlineColor = Config.ESPColor
        store.Highlight.FillTransparency = Config.Chams and 0.5 or 0.85
        store.Highlight.Enabled = true
    elseif store.Highlight then
        store.Highlight.Enabled = false
    end

    if Config.NameESP then
        if not store.Billboard then
            local bb = Instance.new("BillboardGui")
            bb.Size = UDim2.new(0, 120, 0, 18)
            bb.AlwaysOnTop = true
            bb.Parent = CoreGui
            local tl = Instance.new("TextLabel")
            tl.Size = UDim2.new(1, 0, 1, 0)
            tl.BackgroundTransparency = 1
            tl.Font = Enum.Font.GothamBold
            tl.TextSize = 12
            tl.TextStrokeTransparency = 0.5
            tl.Parent = bb
            store.Billboard = bb
            store.NameLabel = tl
        end
        store.Billboard.Adornee = head
        store.NameLabel.Text = plr.DisplayName or plr.Name
        store.NameLabel.TextColor3 = Config.ESPColor
        store.Billboard.Enabled = true
    elseif store.Billboard then
        store.Billboard.Enabled = false
    end

    if Config.TracerESP and Drawing and Drawing.new then
        if not store.Tracer then
            local line = Drawing.new("Line")
            line.Thickness = 1
            line.Transparency = 0.8
            store.Tracer = line
        end
        local sp, on = Camera:WorldToViewportPoint(root.Position)
        store.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        store.Tracer.To = Vector2.new(sp.X, sp.Y)
        store.Tracer.Color = Config.ESPColor
        store.Tracer.Visible = on
    elseif store.Tracer then
        store.Tracer.Visible = false
    end
end

local function HandleMovement()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    if Config.Speed then
        hum.WalkSpeed = Config.SpeedValue
    end
    if Config.JumpPower then
        hum.JumpPower = Config.JumpValue
    end

    if Config.Fly then
        if not BodyVelocity or not BodyVelocity.Parent then
            BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            BodyVelocity.Parent = root
        end
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
        BodyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * Config.FlySpeed or Vector3.zero
    elseif BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end

    if Config.NoClip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    RunAimbot()
    UpdateFOV()
    ApplyGunMods()
    for _, plr in ipairs(Players:GetPlayers()) do
        UpdateESP(plr)
    end
    HandleMovement()
end)

Players.PlayerRemoving:Connect(function(plr)
    ClearESP(plr)
end)

print("[Nexus] Life in Prison loaded")
