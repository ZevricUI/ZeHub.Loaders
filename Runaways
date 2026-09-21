local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local DISCORD_LINK = "https://discord.gg/pehqQJzRm9"

local PURPLE = Color3.fromRGB(139, 92, 246)
local DARK = Color3.fromRGB(13, 13, 18)
local PANEL = Color3.fromRGB(20, 20, 27)
local SIDEBAR = Color3.fromRGB(24, 24, 32)
local ELEMENT = Color3.fromRGB(30, 30, 40)
local TEXT = Color3.fromRGB(245, 245, 250)
local MUTED = Color3.fromRGB(145, 145, 160)

local Scripts = {
    {
        Name = "Rivals",
        Hash = "99468e8b743345db35bfac9d99632320"
    },
    {
        Name = "Runaway",
        Hash = "2f8015eedaf4c092d6afc919837270de"
    },
    {
        Name = "Coming Soon",
        Hash = "BLOXFRUITS_HASH_HERE"
    }
}

local selectedScript = Scripts[1]

local old = playerGui:FindFirstChild("ZeHub Key System")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ZeHub Key System"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(500, 320)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = DARK
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(45, 45, 58)
stroke.Thickness = 1
stroke.Transparency = 0.2
stroke.Parent = frame

-- Top accent
local accent = Instance.new("Frame")
accent.Size = UDim2.new(1, 0, 0, 3)
accent.BackgroundColor3 = PURPLE
accent.BorderSizePixel = 0
accent.Parent = frame

Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 12)

-- Logo / Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 30)
title.Position = UDim2.fromOffset(20, 14)
title.BackgroundTransparency = 1
title.Text = "ZeHub"
title.TextColor3 = TEXT
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -40, 0, 20)
subtitle.Position = UDim2.fromOffset(20, 40)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Script Loader"
subtitle.TextColor3 = MUTED
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 11
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = frame

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.fromOffset(155, 225)
sidebar.Position = UDim2.fromOffset(20, 78)
sidebar.BackgroundColor3 = SIDEBAR
sidebar.BorderSizePixel = 0
sidebar.Parent = frame

Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 9)

local sidebarTitle = Instance.new("TextLabel")
sidebarTitle.Size = UDim2.new(1, -20, 0, 25)
sidebarTitle.Position = UDim2.fromOffset(10, 8)
sidebarTitle.BackgroundTransparency = 1
sidebarTitle.Text = "SUPPORTED GAMES"
sidebarTitle.TextColor3 = MUTED
sidebarTitle.Font = Enum.Font.GothamBold
sidebarTitle.TextSize = 9
sidebarTitle.TextXAlignment = Enum.TextXAlignment.Left
sidebarTitle.Parent = sidebar

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 7)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = sidebar

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 38)
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.fromOffset(285, 225)
content.Position = UDim2.fromOffset(195, 78)
content.BackgroundTransparency = 1
content.Parent = frame

local selectedLabel = Instance.new("TextLabel")
selectedLabel.Size = UDim2.new(1, 0, 0, 28)
selectedLabel.BackgroundTransparency = 1
selectedLabel.Text = selectedScript.Name
selectedLabel.TextColor3 = TEXT
selectedLabel.Font = Enum.Font.GothamBold
selectedLabel.TextSize = 16
selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
selectedLabel.Parent = content

local selectedSub = Instance.new("TextLabel")
selectedSub.Size = UDim2.new(1, 0, 0, 20)
selectedSub.Position = UDim2.fromOffset(0, 27)
selectedSub.BackgroundTransparency = 1
selectedSub.Text = "Enter your ZeHub access key"
selectedSub.TextColor3 = MUTED
selectedSub.Font = Enum.Font.Gotham
selectedSub.TextSize = 10
selectedSub.TextXAlignment = Enum.TextXAlignment.Left
selectedSub.Parent = content

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, 0, 0, 38)
keyBox.Position = UDim2.fromOffset(0, 57)
keyBox.BackgroundColor3 = ELEMENT
keyBox.PlaceholderText = "Enter key..."
keyBox.Text = ""
keyBox.TextColor3 = TEXT
keyBox.PlaceholderColor3 = Color3.fromRGB(105, 105, 120)
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 12
keyBox.ClearTextOnFocus = false
keyBox.TextXAlignment = Enum.TextXAlignment.Left
keyBox.Parent = content

Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 7)

local keyPadding = Instance.new("UIPadding")
keyPadding.PaddingLeft = UDim.new(0, 12)
keyPadding.PaddingRight = UDim.new(0, 12)
keyPadding.Parent = keyBox

-- Get Key
local getKeyButton = Instance.new("TextButton")
getKeyButton.Size = UDim2.fromOffset(135, 34)
getKeyButton.Position = UDim2.fromOffset(0, 105)
getKeyButton.BackgroundColor3 = ELEMENT
getKeyButton.BorderSizePixel = 0
getKeyButton.Text = "GET KEY"
getKeyButton.TextColor3 = PURPLE
getKeyButton.Font = Enum.Font.GothamBold
getKeyButton.TextSize = 11
getKeyButton.AutoButtonColor = false
getKeyButton.Parent = content

Instance.new("UICorner", getKeyButton).CornerRadius = UDim.new(0, 7)

local getKeyStroke = Instance.new("UIStroke")
getKeyStroke.Color = PURPLE
getKeyStroke.Transparency = 0.55
getKeyStroke.Thickness = 1
getKeyStroke.Parent = getKeyButton

-- Load
local runButton = Instance.new("TextButton")
runButton.Size = UDim2.fromOffset(135, 34)
runButton.Position = UDim2.fromOffset(150, 105)
runButton.BackgroundColor3 = PURPLE
runButton.BorderSizePixel = 0
runButton.Text = "LOAD SCRIPT"
runButton.TextColor3 = Color3.fromRGB(255, 255, 255)
runButton.Font = Enum.Font.GothamBold
runButton.TextSize = 11
runButton.AutoButtonColor = false
runButton.Parent = content

Instance.new("UICorner", runButton).CornerRadius = UDim.new(0, 7)

-- Status
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 45)
status.Position = UDim2.fromOffset(0, 151)
status.BackgroundTransparency = 1
status.Text = "Ready. Enter your key to continue."
status.TextColor3 = MUTED
status.Font = Enum.Font.Gotham
status.TextSize = 10
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Top
status.Parent = content

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 18)
footer.Position = UDim2.fromOffset(0, 205)
footer.BackgroundTransparency = 1
footer.Text = "ZeHub • Secure Script Loader"
footer.TextColor3 = Color3.fromRGB(90, 90, 105)
footer.Font = Enum.Font.Gotham
footer.TextSize = 9
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.Parent = content

local buttons = {}

local function selectScript(scriptData, button)
    selectedScript = scriptData
    selectedLabel.Text = scriptData.Name

    if scriptData.Name == "Coming Soon" then
        status.Text = "This game is coming soon."
    else
        status.Text = "Ready to load " .. scriptData.Name .. "."
    end

    for _, other in pairs(buttons) do
        other.BackgroundColor3 = ELEMENT
        other.TextColor3 = Color3.fromRGB(215, 215, 225)
    end

    button.BackgroundColor3 = Color3.fromRGB(48, 38, 65)
    button.TextColor3 = PURPLE
end

for _, scriptData in ipairs(Scripts) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 34)
    button.BackgroundColor3 = ELEMENT
    button.BorderSizePixel = 0
    button.Text = scriptData.Name
    button.TextColor3 = Color3.fromRGB(215, 215, 225)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 10
    button.AutoButtonColor = false
    button.Parent = sidebar

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

    table.insert(buttons, button)

    button.Activated:Connect(function()
        selectScript(scriptData, button)
    end)
end

if buttons[1] then
    buttons[1].BackgroundColor3 = Color3.fromRGB(48, 38, 65)
    buttons[1].TextColor3 = PURPLE
end

-- GET KEY BUTTON
getKeyButton.Activated:Connect(function()
    status.Text = "Opening ZeHub Discord..."

    pcall(function()
        GuiService:OpenBrowserWindow(DISCORD_LINK)
    end)

    -- Clipboard fallback for supported environments
    pcall(function()
        if setclipboard then
            setclipboard(DISCORD_LINK)
        end
    end)
end)

-- LOAD SCRIPT
runButton.Activated:Connect(function()
    local key = keyBox.Text

    if key == "" then
        status.Text = "Please enter your key first."
        return
    end

    if not selectedScript then
        status.Text = "Please select a script."
        return
    end

    if selectedScript.Name == "Coming Soon" then
        status.Text = "This game is not available yet."
        return
    end

    status.Text = "Authenticating key..."

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
        status.Text = "Loader error: " .. tostring(success)
        return
    end

    if success == false then
        status.Text = message or "Invalid or expired key."
        return
    end

    status.Text = selectedScript.Name .. " loaded successfully!"

    task.wait(0.35)

    -- Remove the key system after successful execution
    if gui and gui.Parent then
        gui:Destroy()
    end
end)
