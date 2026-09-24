local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ZeHub projects / FlowAuth loaders
local Scripts = {
    {
        Name = "Loot The Forge",
        Hash = "a315f0a408a8a08b7eace4550185adcb"
    },
    {
        Name = "Rivals",
        Hash = "99468e8b743345db35bfac9d99632320"
    },
    {
        Name = "Runaways",
        Hash = "2f8015eedaf4c092d6afc919837270de"
    }
}

local selectedScript = Scripts[1]

-- Optional executor file persistence.
-- If writefile/readfile are unavailable, the loader still works normally.
local KEY_FILE = "ZeHub_Key.txt"

local function saveKey(key)
    if typeof(writefile) ~= "function" then
        return false
    end

    local ok = pcall(function()
        writefile(KEY_FILE, key)
    end)

    return ok
end

local function loadSavedKey()
    if typeof(isfile) ~= "function" or typeof(readfile) ~= "function" then
        return nil
    end

    local ok, exists = pcall(function()
        return isfile(KEY_FILE)
    end)

    if not ok or not exists then
        return nil
    end

    local readOk, value = pcall(function()
        return readfile(KEY_FILE)
    end)

    if readOk and type(value) == "string" and value ~= "" then
        return value
    end

    return nil
end

local old = playerGui:FindFirstChild("ZeHub")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ZeHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- Main container: scales with the screen while keeping a stable design size.
local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(460, 285)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.04
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Transparency = 0.82
stroke.Thickness = 1
stroke.Parent = frame

local scale = Instance.new("UIScale")
scale.Parent = frame

local function updateScale()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local viewport = camera.ViewportSize
    local sx = viewport.X / 520
    local sy = viewport.Y / 360
    local s = math.clamp(math.min(sx, sy), 0.72, 1.18)
    scale.Scale = s
end

updateScale()

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 36)
title.Position = UDim2.fromOffset(15, 9)
title.BackgroundTransparency = 1
title.Text = "ZeHub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -30, 0, 20)
subtitle.Position = UDim2.fromOffset(15, 34)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Select a script and enter your key"
subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = frame

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.fromOffset(150, 210)
sidebar.Position = UDim2.fromOffset(15, 62)
sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
sidebar.BackgroundTransparency = 0.18
sidebar.BorderSizePixel = 0
sidebar.Parent = frame

Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 9)

local sidebarStroke = Instance.new("UIStroke")
sidebarStroke.Color = Color3.fromRGB(255, 255, 255)
sidebarStroke.Transparency = 0.9
sidebarStroke.Parent = sidebar

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 7)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.Parent = sidebar

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -185, 0, 210)
content.Position = UDim2.fromOffset(175, 62)
content.BackgroundTransparency = 1
content.Parent = frame

local selectedLabel = Instance.new("TextLabel")
selectedLabel.Size = UDim2.new(1, 0, 0, 25)
selectedLabel.BackgroundTransparency = 1
selectedLabel.Text = selectedScript.Name
selectedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
selectedLabel.Font = Enum.Font.GothamBold
selectedLabel.TextSize = 15
selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
selectedLabel.Parent = content

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, 0, 0, 38)
keyBox.Position = UDim2.fromOffset(0, 38)
keyBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
keyBox.BackgroundTransparency = 0.94
keyBox.BorderSizePixel = 0
keyBox.PlaceholderText = "Enter key..."
keyBox.Text = ""
keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 13
keyBox.ClearTextOnFocus = false
keyBox.Parent = content

local savedKey = loadSavedKey()
if savedKey then
    keyBox.Text = savedKey
end

Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 7)

local keyStroke = Instance.new("UIStroke")
keyStroke.Color = Color3.fromRGB(255, 255, 255)
keyStroke.Transparency = 0.9
keyStroke.Parent = keyBox

local runButton = Instance.new("TextButton")
runButton.Size = UDim2.new(1, 0, 0, 38)
runButton.Position = UDim2.fromOffset(0, 88)
runButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
runButton.BackgroundTransparency = 0.88
runButton.BorderSizePixel = 0
runButton.Text = "LOAD SELECTED"
runButton.TextColor3 = Color3.fromRGB(255, 255, 255)
runButton.Font = Enum.Font.GothamSemibold
runButton.TextSize = 12
runButton.AutoButtonColor = false
runButton.Parent = content

Instance.new("UICorner", runButton).CornerRadius = UDim.new(0, 7)

local runStroke = Instance.new("UIStroke")
runStroke.Color = Color3.fromRGB(255, 255, 255)
runStroke.Transparency = 0.78
runStroke.Parent = runButton

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 32)
status.Position = UDim2.fromOffset(0, 137)
status.BackgroundTransparency = 1
status.Text = "Ready."
status.TextColor3 = Color3.fromRGB(150, 150, 150)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = content

-- Transparent monochrome utility buttons.
local getKey = Instance.new("TextButton")
getKey.Size = UDim2.new(0.48, -3, 0, 32)
getKey.Position = UDim2.new(0, 0, 1, -32)
getKey.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
getKey.BackgroundTransparency = 0.94
getKey.BorderSizePixel = 0
getKey.Text = "GET KEY"
getKey.TextColor3 = Color3.fromRGB(255, 255, 255)
getKey.Font = Enum.Font.GothamSemibold
getKey.TextSize = 10
getKey.AutoButtonColor = false
getKey.Parent = content

Instance.new("UICorner", getKey).CornerRadius = UDim.new(0, 7)

local discord = Instance.new("TextButton")
discord.Size = UDim2.new(0.48, -3, 0, 32)
discord.Position = UDim2.new(0.52, 0, 1, -32)
discord.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
discord.BackgroundTransparency = 0.94
discord.BorderSizePixel = 0
discord.Text = "DISCORD"
discord.TextColor3 = Color3.fromRGB(255, 255, 255)
discord.Font = Enum.Font.GothamSemibold
discord.TextSize = 10
discord.AutoButtonColor = false
discord.Parent = content

Instance.new("UICorner", discord).CornerRadius = UDim.new(0, 7)

local buttons = {}

local function styleHover(button, normalTransparency, hoverTransparency)
    button.MouseEnter:Connect(function()
        button.BackgroundTransparency = hoverTransparency
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundTransparency = normalTransparency
    end)
end

styleHover(runButton, 0.88, 0.78)
styleHover(getKey, 0.94, 0.86)
styleHover(discord, 0.94, 0.86)

local function selectScript(scriptData, button)
    selectedScript = scriptData
    selectedLabel.Text = scriptData.Name
    status.Text = "Selected " .. scriptData.Name

    for _, other in pairs(buttons) do
        other.BackgroundTransparency = 0.94
    end

    button.BackgroundTransparency = 0.84
end

for _, scriptData in ipairs(Scripts) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -16, 0, 38)
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundTransparency = 0.94
    button.BorderSizePixel = 0
    button.Text = scriptData.Name
    button.TextColor3 = Color3.fromRGB(225, 225, 225)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 11
    button.AutoButtonColor = false
    button.Parent = sidebar

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)

    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(255, 255, 255)
    buttonStroke.Transparency = 0.94
    buttonStroke.Parent = button

    table.insert(buttons, button)

    styleHover(button, 0.94, 0.89)

    button.Activated:Connect(function()
        selectScript(scriptData, button)
    end)
end

if buttons[1] then
    buttons[1].BackgroundTransparency = 0.84
end

if savedKey then
    status.Text = "Saved key restored."
end

-- Open the supplied key page.
getKey.Activated:Connect(function()
    local ok = pcall(function()
        if setclipboard then
            setclipboard("discord.gg/zehub")
        end
    end)

    status.Text = ok and "Key link copied. Open it in your browser." or "Use the Get Key link below."
end)

-- Copy the Discord invite for easy access.
discord.Activated:Connect(function()
    local ok = pcall(function()
        if setclipboard then
            setclipboard("discord.gg/zehub")
        end
    end)

    status.Text = ok and "Discord invite copied." or "Discord: discord.gg/zehub"
end)

runButton.Activated:Connect(function()
    local key = keyBox.Text

    if key == "" then
        status.Text = "Enter a key first."
        return
    end

    if not selectedScript then
        status.Text = "Select a script."
        return
    end

    status.Text = "Loading " .. selectedScript.Name .. "..."
    runButton.Active = false
    runButton.Text = "LOADING..."

    -- Remember the key for the next execution when the environment supports file storage.
    saveKey(key)

    local ok, success, message = pcall(function()
        local source = game:HttpGet(
            "https://flowauth.net/v1/loaders/" .. selectedScript.Hash .. ".lua"
        )

        local loader, loadError = loadstring(source)

        if not loader then
            error(loadError or "Failed to compile loader.")
        end

        return loader(key)
    end)

    if not ok then
        runButton.Active = true
        runButton.Text = "LOAD SELECTED"
        status.Text = "Loader error: " .. tostring(success)
        return
    end

    if success == false then
        runButton.Active = true
        runButton.Text = "LOAD SELECTED"
        status.Text = message or "Invalid key."
        return
    end

    status.Text = selectedScript.Name .. " loaded!"

    -- Once the selected script has loaded successfully, remove the ZeHub loader UI.
    task.wait(0.35)
    if gui and gui.Parent then
        gui:Destroy()
    end
end)
