-- ============================================================================
-- [ 1 ] SERVICES
-- ============================================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")
local HttpService       = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

repeat task.wait() until game:IsLoaded()

-- ============================================================================
-- [ 2 ] HELPERS
-- ============================================================================
local function GetParent()
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    return pg or CoreGui
end

local function Create(cls, props)
    local i = Instance.new(cls)
    for k, v in pairs(props or {}) do i[k] = v end
    return i
end
local function Corner(r) return Create("UICorner", {CornerRadius = UDim.new(0, r or 8)}) end
local function Stroke(c, t, tr)
    return Create("UIStroke", {
        Color = c, Thickness = t or 1, Transparency = tr or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
end
local function Gradient(parent, c1, c2, rot)
    local g = Create("UIGradient", {Color = ColorSequence.new(c1, c2), Rotation = rot or 0})
    g.Parent = parent
    return g
end

-- ============================================================================
-- [ 3 ] PLATFORM
-- ============================================================================
local function GetPlatform()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return "Mobile"
    elseif UserInputService.KeyboardEnabled then
        return "PC"
    elseif UserInputService.GamepadEnabled then
        return "Console"
    end
    return "Unknown"
end
local PLATFORM = GetPlatform()
local isMobile = (PLATFORM == "Mobile")

-- ============================================================================
-- [ 4 ] ZEHUB UI
-- Uses the ZeHub UI library supplied with this script.
-- ============================================================================

local ZeHub = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/ZeHub/main/dist/main.lua"
))()

local Window = ZeHub:CreateWindow({
    Title = "Zehub - Doors",
    Author = "by oreganolaborant",
    Folder = "ZehubDoors",
    Icon = "door-open",
    NewElements = true,
    HideSearchBar = false,
    OpenButton = {
        Title = "Open Zehub Doors",
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.5,
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },
})

local MainTab = Window:Tab({
    Title = "Main",
    Icon = "house",
    IconShape = "Square",
    Border = true,
})

local EspTab = Window:Tab({
    Title = "ESP",
    Icon = "eye",
    IconShape = "Square",
    Border = true,
})

-- ============================================================================
-- [ 6 ] DOORS — CONFIG
-- ============================================================================
local Config = {
    toggleJump = false,
    fullbright = false, brightness = 2,
    walkSpeedEnabled = false, walkSpeed = 16, noclip = false,
    doorEsp = false, objEsp = false, entityEsp = false,
    goldPileEsp = false, itemEsp = false, hidingEsp = false,
    shedEsp = false, playerEsp = false,
    rainbowEsp = false, enableText = false,
    textSize = 29, textHeight = 0.2, maxDistance = 1000,
    doorColor   = Color3.fromRGB(120, 0, 0),
    objColor    = Color3.fromRGB(0, 0, 255),
    entityColor = Color3.fromRGB(255, 0, 0),
    goldColor   = Color3.fromRGB(255, 225, 0),
    itemColor   = Color3.fromRGB(0, 255, 255),
    hideColor   = Color3.fromRGB(100, 100, 100),
    shedColor   = Color3.fromRGB(139, 69, 19),
    playerColor = Color3.fromRGB(0, 255, 0),
    autoKeyPickup = false, autoLoot = false,
    walkReachedDistance = 6,
}

-- ============================================================================
-- [ 7 ] PLAYER — Main Tab
-- ============================================================================
local PlayerSection = MainTab:Section({Title = "PLAYER"})

PlayerSection:Toggle({Title = "Toggle Jump", Callback = function(v)
    Config.toggleJump = v
    local char = workspace:FindFirstChild(LocalPlayer.Name)
    if char then pcall(function() char:SetAttribute("CanJump", v) end) end
end})

PlayerSection:Toggle({Title = "WalkSpeed", Callback = function(v)
    Config.walkSpeedEnabled = v
    if not v then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.WalkSpeed = 16 end) end
    end
end})

PlayerSection:Slider({Title = "WalkSpeed Value", Step = 1, Value = {Min = 1, Max = 200, Default = 16}, Callback = function(v)
    Config.walkSpeed = v
    if Config.walkSpeedEnabled then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.WalkSpeed = v end) end
    end
end})

PlayerSection:Toggle({Title = "No-Clip", Callback = function(v)
    Config.noclip = v
    if v then
        local char = LocalPlayer.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    pcall(function() p.CanCollide = false end)
                end
            end
        end
    end
end})

-- ============================================================================
-- [ 8 ] VISUALS — Main Tab
-- ============================================================================
local VisualsSection = MainTab:Section({Title = "VISUALS"})

VisualsSection:Toggle({Title = "Fullbright", Callback = function(v)
    Config.fullbright = v
    Lighting.ClockTime = v and 12 or 14
    Lighting.GlobalShadows = not v
    Lighting.Brightness = v and Config.brightness or 1
end})

VisualsSection:Slider({Title = "Fullbright Intensity", Step = 1, Value = {Min = 1, Max = 10, Default = 2}, Callback = function(v)
    Config.brightness = v
    if Config.fullbright then Lighting.Brightness = v end
end})

-- ============================================================================
-- [ 9 ] AUTO-FARM — Main Tab
-- ============================================================================
local function ForEachRoomChild(callback)
    local rooms = workspace:FindFirstChild("CurrentRooms")
    if not rooms then return end
    for _, room in ipairs(rooms:GetChildren()) do
        for _, d in ipairs(room:GetDescendants()) do
            callback(d, room)
        end
    end
end

local function FindKey()
    local result = nil
    ForEachRoomChild(function(d)
        if result then return end
        if d.Name == "KeyObtain" and d:FindFirstChild("ModulePrompt") then
            result = d
        end
    end)
    return result
end

local function FindLoot()
    local result = nil
    ForEachRoomChild(function(d)
        if result then return end
        if d.Name == "Knobs" and d:FindFirstChild("ActivateEventPrompt") then
            result = d
        end
    end)
    return result
end

local function FindHidingSpot()
    local result = nil
    ForEachRoomChild(function(d)
        if result then return end
        if (d.Name == "Wardrobe" or d.Name == "Bed") and d:FindFirstChild("HidePrompt") then
            result = d
        end
    end)
    return result
end

local function GetPosition(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local ok, pivot = pcall(function() return obj:GetPivot().Position end)
        if ok and pivot then return pivot end
    end
    return nil
end

local function FirePrompt(prompt)
    if not prompt then return false end
    local ok = pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration or 0.1)
            prompt:InputHoldEnd()
        end
    end)
    return ok
end

local AutoFarmSection = MainTab:Section({Title = "AUTO-FARM"})

AutoFarmSection:Button({Title = "Grab Key", Callback = function()
    local key = FindKey()
    if not key then print("[Zehub] Kein Key gefunden!"); return end
    local prompt = key:FindFirstChild("ModulePrompt")
    if prompt then FirePrompt(prompt) end
end})

AutoFarmSection:Button({Title = "Loot Drawer", Callback = function()
    local loot = FindLoot()
    if not loot then print("[Zehub] Kein Loot gefunden!"); return end
    for _, d in ipairs(loot:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Name == "ActivateEventPrompt" then
            FirePrompt(d)
        end
    end
end})

AutoFarmSection:Button({Title = "Hide in Hiding Spot", Callback = function()
    local hiding = FindHidingSpot()
    if not hiding then print("[Zehub] Kein Hiding-Spot gefunden!"); return end
    local prompt = hiding:FindFirstChild("HidePrompt")
    if prompt then FirePrompt(prompt) end
end})

AutoFarmSection:Toggle({Title = "Auto-Key-Pickup (nah)", Callback = function(v)
    Config.autoKeyPickup = v
end})

AutoFarmSection:Toggle({Title = "Auto-Loot Drawers (nah)", Callback = function(v)
    Config.autoLoot = v
end})

AutoFarmSection:Slider({Title = "Interact-Reichweite", Step = 1, Value = {Min = 5, Max = 30, Default = 12}, Callback = function(v)
    Config.walkReachedDistance = v
end})

-- ============================================================================
-- [ 10 ] ESP TAB — TOGGLES
-- ============================================================================
local EspToggles = EspTab:Section({Title = "ESP TOGGLES"})
EspToggles:Toggle({Title = "Door ESP", Callback = function(v) Config.doorEsp = v end})
EspToggles:Toggle({Title = "Objective ESP", Callback = function(v) Config.objEsp = v end})
EspToggles:Toggle({Title = "Entity Highlight", Callback = function(v) Config.entityEsp = v end})
EspToggles:Toggle({Title = "Gold Highlight", Callback = function(v) Config.goldPileEsp = v end})
EspToggles:Toggle({Title = "Item Highlight", Callback = function(v) Config.itemEsp = v end})
EspToggles:Toggle({Title = "Hiding ESP", Callback = function(v) Config.hidingEsp = v end})
EspToggles:Toggle({Title = "ToolShed ESP", Callback = function(v) Config.shedEsp = v end})
EspToggles:Toggle({Title = "Player ESP", Callback = function(v) Config.playerEsp = v end})

local EspSettings = EspTab:Section({Title = "ESP SETTINGS"})
EspSettings:Toggle({Title = "Rainbow ESP", Callback = function(v) Config.rainbowEsp = v end})
EspSettings:Toggle({Title = "Enable Text", Callback = function(v) Config.enableText = v end})
EspSettings:Slider({Title = "Text Size", Step = 1, Value = {Min = 10, Max = 40, Default = 29}, Callback = function(v) Config.textSize = v end})
EspSettings:Slider({Title = "Text Offset Y", Step = 1, Value = {Min = -5, Max = 15, Default = 0}, Callback = function(v) Config.textHeight = v end})
EspSettings:Slider({Title = "Max ESP Distance", Step = 50, Value = {Min = 50, Max = 5000, Default = 1000}, Callback = function(v) Config.maxDistance = v end})

-- ============================================================================
-- [ 11 ] LOOPS — Player / Movement
-- ============================================================================
task.spawn(function()
    while task.wait(0.2) do
        if Config.walkSpeedEnabled then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum.WalkSpeed = Config.walkSpeed end) end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if Config.toggleJump then
            local char = workspace:FindFirstChild(LocalPlayer.Name)
            if char then pcall(function() char:SetAttribute("CanJump", true) end) end
        end
    end
end)

RunService.Stepped:Connect(function()
    if Config.noclip and LocalPlayer.Character then
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                pcall(function() p.CanCollide = false end)
            end
        end
    end
end)

-- ============================================================================
-- [ 12 ] LOOPS — Auto-Farm
-- ============================================================================
task.spawn(function()
    while task.wait(0.4) do
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        if Config.autoKeyPickup then
            local key = FindKey()
            if key then
                local hitbox = key:FindFirstChild("Hitbox") or key
                local targetPos = GetPosition(hitbox)
                if targetPos and (root.Position - targetPos).Magnitude < Config.walkReachedDistance then
                    local prompt = key:FindFirstChild("ModulePrompt")
                    if prompt then FirePrompt(prompt) end
                end
            end
        end

        if Config.autoLoot then
            local rooms = workspace:FindFirstChild("CurrentRooms")
            if rooms then
                for _, room in ipairs(rooms:GetChildren()) do
                    for _, d in ipairs(room:GetDescendants()) do
                        if d:IsA("ProximityPrompt") and d.Name == "ActivateEventPrompt" then
                            local pp = d.Parent
                            if pp and pp:IsA("BasePart") and (root.Position - pp.Position).Magnitude < Config.walkReachedDistance then
                                FirePrompt(d)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================================
-- [ 13 ] ESP LOGIC
-- ============================================================================
local activeESPs = {}
local EntityNames = {"Rush","Ambush","Seek","Eyes","Screech","Halt","A-60","A-120","GiggleCeiling","MonumentEntity","SallyMoving","JeffTheKiller","GloombatSwarm","FigureRig"}
local ObjList = {"LibraryHintPaper","LiveHintBook","KeyObtain","LeverForGate","LiveBreakerPolePickup","ElectricalKeyObtain"}
local ItemList = {"AK-47","AlarmClock","Aloe","AN-94","Anchors","A-90sStopSign","BackdoorKey","BackdoorLock","Bandage","BandagePack","Battery","BatteryPack","BigBomb","BlueKeycard","BluePrince","Bomb","Bread","BreakerPole","Bulklight","Buddy","Cactus","Candle","CarmelApple","Cheese","ChocolateBar","Citamines","ColtAnaconda","Cookie","Crossbow","Crucifix","DBShotgun","DesertEagle","ElectricalKey","ElectricalRoomFuse","EnergyDrink","ExecutionRoomKey","Flashlight","FreezeGun","Flamethrower","G36C","Generator","GeneratorFuse","GiftLauncher","GlitchFragment","GweenSoda","GuidanceCandy","Headlamp","HealingPad","HolyHandGrenade","HasteLever","Hookshot","HotelKey","HotelLock","IceTripmine","InvincibilityStar","JackoBomb","Keycard","Knockbomb","Landmine","Lantern","LaserPointer","Level5Keycard","LibearyBook","LibearyLock","LibearyPaper","Light_Bulb","Lockpick","Lolipop","MG42","M14","M16A2","M1911","M249","M5K","M4A1","MoonlightCandle","MoonlightFloat","MoonlightSmoothie","Monkey","Nanner","NannerPeel","NestGenerator","NVCS-3000","OrangeKeycard","P90","Paintingoval","Paintingrectanglelyingshortsides","Paintingrectanglelyinglongsides","PaintingSquare","PlantofVirdis","Potion","R870","RedEnergyDrink","Rock","Roto_Door","RubberChicken","SacredHerb","SaltShaker","Shakelight","Shears","SkeletonKey","Smoothie","SmallShieldPotion","SpeedBoostPad","SprayPaint","StarlightBottle","StarlightJug","StarlightVial","Straplight","StrawberryCandy","StrongHerb","StrongerHerb","StrongestHerb","SuperHerb","SweetHerb","ThrowableHatStand","ThrowableNormalCardboardBox","ThrowableOfficeChair","ThrowablePottedPlant","ThrowableRegalChair","ThrowableRegalOttoman","ThrowableStool","ThrowableTrashCan","ThrowableWideCardboardBox","ThrowableWoodenChair","ThrowableWoodenCrate","TipJar","Vitamins"}
local HSList = {"Locker_Large","Toolshed","Wardrobe","Bed","Backdoor_Wardrobe","Rooms_Locker","CircularVent"}

local function NameMatches(name, list)
    if not name then return false, nil end
    local lower = name:lower()
    for _, target in ipairs(list) do
        if lower:find(target:lower(), 1, true) then
            return true, target
        end
    end
    return false, nil
end

local function Cleanup(obj, data)
    pcall(function()
        if data.Highlight then data.Highlight:Destroy() end
        if data.Box then data.Box:Destroy() end
        if data.Bill then data.Bill:Destroy() end
    end)
    activeESPs[obj] = nil
end

local function CreateESP(obj, name, type)
    if activeESPs[obj] then return end
    local objN = obj.Name
    if objN == "LiveHintBook" or objN == "FigureRig" or objN == "LiveBreakerPolePickup" or objN == "ElectricalKeyObtain" then
        local displayName = (objN == "LiveHintBook" and "Book") or
                            (objN == "FigureRig" and "Figure") or
                            (objN == "LiveBreakerPolePickup" and "Breaker") or
                            (objN == "ElectricalKeyObtain" and "Electrical Key")
        activeESPs[obj] = { Name = displayName, Type = type }
        return
    end
    local lowerN = objN:lower()
    if lowerN:find("bookcase") or lowerN:find("modular_bookshelf") then return end
    activeESPs[obj] = { Name = name, Type = type }
end

local function ScanInstance(child)
    local n = child.Name
    if not n or n == "" then return end

    if Config.entityEsp then
        local matched = NameMatches(n, EntityNames)
        if matched then
            local display = (n:lower():find("figurerig") and "Figure") or n
            CreateESP(child, display, "Entity")
            return
        end
    end

    if Config.objEsp and table.find(ObjList, n) then
        local d = (n == "KeyObtain" and "Key") or
                  (n == "LeverForGate" and "Lever") or
                  (n == "LiveHintBook" and "Book") or
                  (n == "LiveBreakerPolePickup" and "Breaker") or
                  (n == "ElectricalKeyObtain" and "Electrical Key") or n
        CreateESP(child, d, "Objective")
        return
    end

    if Config.doorEsp and n == "Door" and child:IsA("BasePart") then
        CreateESP(child, "Door", "Door")
        return
    end

    if Config.goldPileEsp then
        local lower = n:lower()
        if lower:find("goldpile", 1, true) or lower:find("gold_pile", 1, true) or lower == "gold" then
            CreateESP(child, "Gold", "Gold")
            return
        end
    end

    if Config.itemEsp and table.find(ItemList, n) then
        CreateESP(child, n, "Item")
        return
    end

    if Config.hidingEsp then
        local matched = NameMatches(n, HSList)
        if matched then
            CreateESP(child, n, "Hiding")
            return
        end
    end

    if Config.shedEsp and n == "Toolshed_Small" then
        CreateESP(child, "Tool Shed", "Shed")
        return
    end
end

task.spawn(function()
    while true do
        for _, ent in pairs(workspace:GetChildren()) do
            pcall(ScanInstance, ent)
        end

        local rooms = workspace:FindFirstChild("CurrentRooms")
        if rooms then
            for _, room in pairs(rooms:GetChildren()) do
                for _, child in pairs(room:GetDescendants()) do
                    pcall(ScanInstance, child)
                end
                task.wait(0.005)
            end
        end

        for _, d in pairs(workspace:GetDescendants()) do
            if d.Name and d.Name ~= "" then
                local lower = d.Name:lower()
                if lower:find("rush", 1, true)
                    or lower:find("ambush", 1, true)
                    or lower:find("seek", 1, true)
                    or lower:find("figurerig", 1, true)
                    or lower:find("a-60", 1, true)
                    or lower:find("a-120", 1, true)
                    or lower:find("screech", 1, true)
                    or lower:find("goldpile", 1, true)
                    or lower:find("gold_pile", 1, true)
                    or lower:find("locker_large", 1, true)
                    or lower:find("wardrobe", 1, true) then
                    pcall(ScanInstance, d)
                end
            end
        end

        task.wait(1.0)
    end
end)

local function UpdateESP()
    local rainbow = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    local char = LocalPlayer.Character
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Collision"))
    if not root then return end

    for obj, data in pairs(activeESPs) do
        local isEnabled = (data.Type == "Door" and Config.doorEsp) or
                          (data.Type == "Objective" and Config.objEsp) or
                          (data.Type == "Entity" and Config.entityEsp) or
                          (data.Type == "Gold" and Config.goldPileEsp) or
                          (data.Type == "Item" and Config.itemEsp) or
                          (data.Type == "Hiding" and Config.hidingEsp) or
                          (data.Type == "Shed" and Config.shedEsp)

        if not obj or not obj.Parent or not isEnabled then
            Cleanup(obj, data)
            continue
        end

        local targetPos
        local ok = pcall(function()
            targetPos = (obj:IsA("Model") and obj:GetPivot().Position) or (obj:IsA("BasePart") and obj.Position)
        end)
        if not ok or not targetPos then continue end

        local dist = (root.Position - targetPos).Magnitude
        if dist > Config.maxDistance then
            if data.Highlight then data.Highlight.Enabled = false end
            if data.Box then data.Box.Visible = false end
            if data.Bill then data.Bill.Enabled = false end
            continue
        end

        local _, onScreen = Camera:WorldToViewportPoint(targetPos)
        if onScreen then
            local color = Config.doorColor
            if data.Type == "Entity" then color = Config.entityColor
            elseif data.Type == "Gold" then color = Config.goldColor
            elseif data.Type == "Item" then color = Config.itemColor
            elseif data.Type == "Objective" then color = Config.objColor
            elseif data.Type == "Hiding" then color = Config.hideColor
            elseif data.Type == "Shed" then color = Config.shedColor end
            if Config.rainbowEsp then color = rainbow end

            if data.Type == "Door" and obj:IsA("BasePart") then
                if not data.Box then
                    data.Box = Instance.new("BoxHandleAdornment", obj)
                    data.Box.AlwaysOnTop = true; data.Box.Adornee = obj; data.Box.ZIndex = 5
                end
                data.Box.Visible = true; data.Box.Size = obj.Size
                data.Box.Color3 = color; data.Box.Transparency = 0.7
            else
                if not data.Highlight then
                    data.Highlight = Instance.new("Highlight", obj)
                    data.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                data.Highlight.Enabled = true
                data.Highlight.FillColor = color
                data.Highlight.OutlineColor = color
                data.Highlight.FillTransparency = 0.5
            end

            if not data.Bill then
                data.Bill = Instance.new("BillboardGui", obj)
                data.Bill.AlwaysOnTop = true
                data.Bill.Size = UDim2.new(0, 150, 0, 40)
                local txt = Instance.new("TextLabel", data.Bill)
                txt.BackgroundTransparency = 1
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.Font = "SourceSansBold"
                txt.Name = "L"
                txt.TextStrokeTransparency = 0
            end
            data.Bill.Enabled = Config.enableText
            data.Bill.StudsOffset = Vector3.new(0, Config.textHeight, 0)
            local lbl = data.Bill:FindFirstChild("L")
            if lbl then
                lbl.TextColor3 = color
                lbl.TextSize = Config.textSize
                lbl.Text = data.Name .. " [" .. math.floor(dist) .. "]"
            end
        else
            if data.Highlight then data.Highlight.Enabled = false end
            if data.Box then data.Box.Visible = false end
            if data.Bill then data.Bill.Enabled = false end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

-- ============================================================================
-- [ 14 ] Finished
-- ============================================================================
print("========================================")
print("Zehub - Doors Loaded")
print("Platform: " .. PLATFORM)
print("RightCtrl = UI Toggle")
print("========================================")
