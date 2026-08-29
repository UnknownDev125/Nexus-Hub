if not game:IsLoaded() then game.Loaded:Wait() end

local PlaceId = game.PlaceId
local ArsenalIds = {
    [286090429] = true,
}

if not ArsenalIds[PlaceId] then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Nexus",
        Text = "This script only works for Arsenal.",
        Duration = 5,
    })
    return
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/UnknownDev125/Nexus-Source/refs/heads/main/source.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Window = Library:CreateWindow({Name = "Nexus | Arsenal"})

local Combat = Window:AddTab("Combat")
local Visuals = Window:AddTab("Visuals")
local Movement = Window:AddTab("Movement")
local Misc = Window:AddTab("Misc")

local Config = {
    Aimbot = false,
    AimbotFOV = 180,
    AimbotHitPart = "Head",
    AimbotTeamCheck = true,
    AimbotSmooth = 0.15,
    AimbotHold = true,
    ShowFOV = true,
    FOVColor = Color3.fromRGB(90, 120, 255),
    FOVCenterLock = true,
    Hitbox = false,
    HitboxSize = 6,
    HitboxTransparency = 0.65,
    HitboxColor = Color3.fromRGB(90, 120, 255),
    HitboxTeamCheck = true,
    BoxESP = false,
    NameESP = false,
    TracerESP = false,
    Chams = false,
    ESPColor = Color3.fromRGB(90, 120, 255),
    ESPTeamCheck = true,
    Speed = false,
    SpeedValue = 20,
    JumpPower = false,
    JumpValue = 50,
    Fly = false,
    FlySpeed = 50,
    NoClip = false,
}

local Holding = false
local FOVCircle = nil
local OriginalSizes = {}
local ESPObjects = {}
local BodyVelocity = nil

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
    Default = 180,
    Callback = function(v) Config.AimbotFOV = v end
})
Combat:AddSlider({
    Name = "Smoothness",
    Min = 1,
    Max = 100,
    Default = 15,
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

Combat:AddSection("Hitbox Expander")
Combat:AddToggle({
    Name = "Enabled",
    Default = false,
    Callback = function(v) Config.Hitbox = v end
})
Combat:AddSlider({
    Name = "Size",
    Min = 1,
    Max = 20,
    Default = 6,
    Callback = function(v) Config.HitboxSize = v end
})
Combat:AddSlider({
    Name = "Transparency",
    Min = 0,
    Max = 100,
    Default = 65,
    Callback = function(v) Config.HitboxTransparency = v / 100 end
})
Combat:AddToggle({
    Name = "Team Check",
    Default = true,
    Callback = function(v) Config.HitboxTeamCheck = v end
})
Combat:AddColorPicker({
    Name = "Hitbox Color",
    Default = Config.HitboxColor,
    Callback = function(c) Config.HitboxColor = c end
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
    Max = 100,
    Default = 20,
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
    Default = 50,
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
    Name = "Reset Hitboxes",
    Callback = function()
        for plr, data in pairs(OriginalSizes) do
            local char = plr.Character
            if char then
                for partName, size in pairs(data) do
                    local part = char:FindFirstChild(partName)
                    if part and part:IsA("BasePart") then
                        part.Size = size
                        part.Transparency = 1
                        part.Material = Enum.Material.Plastic
                    end
                end
            end
        end
        OriginalSizes = {}
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
        if d < bestDist then
            bestDist = d
            best = part
        end
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
    FOVCircle.Color = Config.FOVColor
    FOVCircle.Visible = Config.ShowFOV and Config.Aimbot
end

local function RunAimbot()
    if not Config.Aimbot then return end
    if Config.AimbotHold and not Holding then return end
    local target = GetClosest()
    if not target then return end
    local goal = CFrame.new(Camera.CFrame.Position, target.Position)
    local smooth = math.clamp(Config.AimbotSmooth, 0.01, 1)
    Camera.CFrame = Camera.CFrame:Lerp(goal, smooth)
end

local function ApplyHitbox(plr)
    if not IsEnemy(plr, Config.HitboxTeamCheck) then
        if OriginalSizes[plr] then
            local char = plr.Character
            if char then
                for partName, size in pairs(OriginalSizes[plr]) do
                    local part = char:FindFirstChild(partName)
                    if part and part:IsA("BasePart") then
                        part.Size = size
                        part.Transparency = 1
                        part.Material = Enum.Material.Plastic
                    end
                end
            end
            OriginalSizes[plr] = nil
        end
        return
    end
    local char = plr.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if not OriginalSizes[plr] then OriginalSizes[plr] = {} end
    if not OriginalSizes[plr]["HumanoidRootPart"] then
        OriginalSizes[plr]["HumanoidRootPart"] = root.Size
    end
    if Config.Hitbox then
        root.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
        root.Transparency = Config.HitboxTransparency
        root.CanCollide = false
        root.Material = Enum.Material.ForceField
        root.Color = Config.HitboxColor
    else
        root.Size = OriginalSizes[plr]["HumanoidRootPart"]
        root.Transparency = 1
        root.Material = Enum.Material.Plastic
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
    for _, plr in ipairs(Players:GetPlayers()) do
        ApplyHitbox(plr)
        UpdateESP(plr)
    end
    HandleMovement()
end)

Players.PlayerRemoving:Connect(function(plr)
    OriginalSizes[plr] = nil
    ClearESP(plr)
end)

print("[Nexus] Arsenal loaded")
