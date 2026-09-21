-- ============================================================================
-- ZeHub • Dark Key System
-- ============================================================================

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================================
-- LINKS
-- ============================================================================

local DISCORD_LINK = "https://discord.gg/pehqQJzRm9"

local GET_KEY_LINK =
    "https://flowauth.net/reward/95257bff957772ebbe918833738a8fea"

-- ============================================================================
-- ZEHUB LOGO
-- ============================================================================

local LOGO_IMAGE = "rbxassetid://137776481151936"

-- ============================================================================
-- DARK ZEHUB COLOURS
-- ============================================================================

local BACKGROUND = Color3.fromRGB(2, 12, 24)
local HEADER = Color3.fromRGB(3, 17, 33)

local PANEL = Color3.fromRGB(3, 20, 38)
local PANEL_2 = Color3.fromRGB(4, 24, 44)

local CARD = Color3.fromRGB(5, 31, 54)
local CARD_HOVER = Color3.fromRGB(7, 40, 67)

local INPUT = Color3.fromRGB(4, 27, 49)

local BLUE = Color3.fromRGB(17, 91, 151)
local BLUE_LIGHT = Color3.fromRGB(27, 116, 188)

local ORANGE = Color3.fromRGB(255, 111, 20)

local WHITE = Color3.fromRGB(245, 248, 252)
local TEXT = Color3.fromRGB(215, 226, 237)

local MUTED = Color3.fromRGB(112, 143, 168)
local DARK_MUTED = Color3.fromRGB(67, 96, 119)

-- ============================================================================
-- SUPPORTED SCRIPTS
-- ============================================================================

local Scripts = {
    {
        Name = "Rivals",
        Short = "R",
        Description = "Get key & load script",
        Hash = "99468e8b743345db35bfac9d99632320"
    },

    {
        Name = "Runaway",
        Short = "R",
        Description = "Get key & load script",
        Hash = "2f8015eedaf4c092d6afc919837270de"
    },

    {
        Name = "Coming Soon",
        Short = "?",
        Description = "Stay tuned...",
        Hash = "BLOXFRUITS_HASH_HERE"
    }
}

local selectedScript = Scripts[1]

-- ============================================================================
-- REMOVE OLD UI
-- ============================================================================

local old = playerGui:FindFirstChild("ZeHub Key System")

if old then
    old:Destroy()
end

-- ============================================================================
-- SCREEN GUI
-- ============================================================================

local gui = Instance.new("ScreenGui")
gui.Name = "ZeHub Key System"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- ============================================================================
-- SCALE
-- ============================================================================

local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = gui

local function updateScale()
    local camera = workspace.CurrentCamera

    if not camera then
        return
    end

    local viewport = camera.ViewportSize

    local targetWidth = 900
    local targetHeight = 560

    local widthScale = viewport.X / targetWidth
    local heightScale = viewport.Y / targetHeight

    local finalScale = math.min(widthScale, heightScale)

    scale.Scale = math.clamp(finalScale, 0.72, 1.05)
end

updateScale()

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

-- ============================================================================
-- MAIN FRAME
-- ============================================================================

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(680, 430)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = BACKGROUND
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = BLUE
frameStroke.Thickness = 1.25
frameStroke.Transparency = 0.18
frameStroke.Parent = frame

-- ============================================================================
-- HEADER
-- ============================================================================

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 118)
header.BackgroundColor3 = HEADER
header.BorderSizePixel = 0
header.Parent = frame

-- Bottom header line
local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, -36, 0, 1)
headerLine.Position = UDim2.fromOffset(18, 117)
headerLine.BackgroundColor3 = BLUE
headerLine.BackgroundTransparency = 0.45
headerLine.BorderSizePixel = 0
headerLine.Parent = header

-- ============================================================================
-- LOGO
-- ============================================================================

local logo = Instance.new("ImageLabel")
logo.Name = "ZeHubLogo"
logo.Size = UDim2.fromOffset(62, 62)
logo.Position = UDim2.fromOffset(22, 20)
logo.BackgroundTransparency = 1
logo.Image = LOGO_IMAGE
logo.ScaleType = Enum.ScaleType.Fit
logo.Parent = header

-- ============================================================================
-- TITLE
-- ============================================================================

local title = Instance.new("TextLabel")
title.Size = UDim2.fromOffset(300, 34)
title.Position = UDim2.fromOffset(92, 24)
title.BackgroundTransparency = 1
title.Text = "ZEHUB"
title.TextColor3 = WHITE
title.Font = Enum.Font.GothamBold
title.TextSize = 25
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Small blue underline
local titleLine = Instance.new("Frame")
titleLine.Size = UDim2.fromOffset(70, 3)
titleLine.Position = UDim2.fromOffset(92, 61)
titleLine.BackgroundColor3 = BLUE_LIGHT
titleLine.BorderSizePixel = 0
titleLine.Parent = header

-- ============================================================================
-- SUBTITLE
-- ============================================================================

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.fromOffset(330, 22)
subtitle.Position = UDim2.fromOffset(92, 73)
subtitle.BackgroundTransparency = 1
subtitle.Text = "SCRIPT LOADER   •   SECURE ACCESS"
subtitle.TextColor3 = MUTED
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 9
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

-- ============================================================================
-- DISCORD BUTTON
-- ============================================================================

local discordButton = Instance.new("TextButton")
discordButton.Name = "Discord"
discordButton.Size = UDim2.fromOffset(145, 38)
discordButton.Position = UDim2.new(1, -195, 0, 27)
discordButton.BackgroundColor3 = PANEL_2
discordButton.BorderSizePixel = 0
discordButton.Text = "DISCORD  ↗"
discordButton.TextColor3 = BLUE_LIGHT
discordButton.Font = Enum.Font.GothamBold
discordButton.TextSize = 10
discordButton.AutoButtonColor = false
discordButton.Parent = header

Instance.new("UICorner", discordButton).CornerRadius = UDim.new(0, 8)

local discordStroke = Instance.new("UIStroke")
discordStroke.Color = BLUE
discordStroke.Transparency = 0.45
discordStroke.Thickness = 1
discordStroke.Parent = discordButton

discordButton.MouseEnter:Connect(function()
    discordButton.BackgroundColor3 = CARD_HOVER
end)

discordButton.MouseLeave:Connect(function()
    discordButton.BackgroundColor3 = PANEL_2
end)

discordButton.Activated:Connect(function()
    pcall(function()
        GuiService:OpenBrowserWindow(DISCORD_LINK)
    end)

    pcall(function()
        if setclipboard then
            setclipboard(DISCORD_LINK)
        end
    end)
end)

-- ============================================================================
-- MINIMIZE BUTTON
-- ============================================================================

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "Minimize"
minimizeButton.Size = UDim2.fromOffset(35, 35)
minimizeButton.Position = UDim2.new(1, -92, 0, 28)
minimizeButton.BackgroundTransparency = 1
minimizeButton.Text = "—"
minimizeButton.TextColor3 = MUTED
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 18
minimizeButton.AutoButtonColor = false
minimizeButton.Parent = header

-- ============================================================================
-- CLOSE BUTTON
-- ============================================================================

local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.Size = UDim2.fromOffset(35, 35)
closeButton.Position = UDim2.new(1, -50, 0, 28)
closeButton.BackgroundTransparency = 1
closeButton.Text = "×"
closeButton.TextColor3 = MUTED
closeButton.Font = Enum.Font.Gotham
closeButton.TextSize = 25
closeButton.AutoButtonColor = false
closeButton.Parent = header

closeButton.MouseEnter:Connect(function()
    closeButton.TextColor3 = WHITE
end)

closeButton.MouseLeave:Connect(function()
    closeButton.TextColor3 = MUTED
end)

closeButton.Activated:Connect(function()
    gui:Destroy()
end)

-- ============================================================================
-- CONTENT AREA
-- ============================================================================

local body = Instance.new("Frame")
body.Name = "Body"
body.Size = UDim2.new(1, -36, 1, -136)
body.Position = UDim2.fromOffset(18, 128)
body.BackgroundTransparency = 1
body.Parent = frame

-- ============================================================================
-- SIDEBAR
-- ============================================================================

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.fromOffset(190, 302)
sidebar.Position = UDim2.fromOffset(0, 0)
sidebar.BackgroundColor3 = PANEL
sidebar.BorderSizePixel = 0
sidebar.Parent = body

Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 12)

local sidebarStroke = Instance.new("UIStroke")
sidebarStroke.Color = BLUE
sidebarStroke.Transparency = 0.48
sidebarStroke.Thickness = 1
sidebarStroke.Parent = sidebar

-- ============================================================================
-- SIDEBAR TITLE
-- ============================================================================

local sidebarTitle = Instance.new("TextLabel")
sidebarTitle.Size = UDim2.new(1, -34, 0, 25)
sidebarTitle.Position = UDim2.fromOffset(17, 18)
sidebarTitle.BackgroundTransparency = 1
sidebarTitle.Text = "◆  SUPPORTED GAMES"
sidebarTitle.TextColor3 = BLUE_LIGHT
sidebarTitle.Font = Enum.Font.GothamBold
sidebarTitle.TextSize = 10
sidebarTitle.TextXAlignment = Enum.TextXAlignment.Left
sidebarTitle.Parent = sidebar

-- ============================================================================
-- GAME LIST
-- ============================================================================

local gameList = Instance.new("Frame")
gameList.Size = UDim2.new(1, -24, 0, 195)
gameList.Position = UDim2.fromOffset(12, 55)
gameList.BackgroundTransparency = 1
gameList.Parent = sidebar

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 9)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = gameList

-- ============================================================================
-- SIDEBAR FOOTER LINE
-- ============================================================================

local footerLine = Instance.new("Frame")
footerLine.Size = UDim2.new(1, -34, 0, 1)
footerLine.Position = UDim2.new(0, 17, 1, -51)
footerLine.BackgroundColor3 = BLUE
footerLine.BackgroundTransparency = 0.5
footerLine.BorderSizePixel = 0
footerLine.Parent = sidebar

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -20, 0, 20)
footer.Position = UDim2.new(0, 10, 1, -38)
footer.BackgroundTransparency = 1
footer.Text = "FAST   •   SECURE   •   RELIABLE"
footer.TextColor3 = MUTED
footer.Font = Enum.Font.GothamMedium
footer.TextSize = 8
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.Parent = sidebar

-- ============================================================================
-- MAIN CONTENT PANEL
-- ============================================================================

local contentPanel = Instance.new("Frame")
contentPanel.Name = "ContentPanel"
contentPanel.Size = UDim2.new(1, -202, 0, 302)
contentPanel.Position = UDim2.fromOffset(202, 0)
contentPanel.BackgroundColor3 = PANEL
contentPanel.BorderSizePixel = 0
contentPanel.Parent = body

Instance.new("UICorner", contentPanel).CornerRadius = UDim.new(0, 12)

local contentStroke = Instance.new("UIStroke")
contentStroke.Color = BLUE
contentStroke.Transparency = 0.48
contentStroke.Thickness = 1
contentStroke.Parent = contentPanel

-- ============================================================================
-- SELECTED GAME ICON
-- ============================================================================

local selectedIcon = Instance.new("Frame")
selectedIcon.Name = "SelectedIcon"
selectedIcon.Size = UDim2.fromOffset(64, 64)
selectedIcon.Position = UDim2.fromOffset(18, 18)
selectedIcon.BackgroundColor3 = CARD
selectedIcon.BorderSizePixel = 0
selectedIcon.Parent = contentPanel

Instance.new("UICorner", selectedIcon).CornerRadius = UDim.new(0, 10)

local selectedIconStroke = Instance.new("UIStroke")
selectedIconStroke.Color = BLUE
selectedIconStroke.Transparency = 0.25
selectedIconStroke.Thickness = 1
selectedIconStroke.Parent = selectedIcon

local selectedIconText = Instance.new("TextLabel")
selectedIconText.Size = UDim2.new(1, 0, 1, 0)
selectedIconText.BackgroundTransparency = 1
selectedIconText.Text = selectedScript.Short
selectedIconText.TextColor3 = BLUE_LIGHT
selectedIconText.Font = Enum.Font.GothamBold
selectedIconText.TextSize = 28
selectedIconText.Parent = selectedIcon

-- ============================================================================
-- SELECTED GAME NAME
-- ============================================================================

local selectedLabel = Instance.new("TextLabel")
selectedLabel.Size = UDim2.new(1, -105, 0, 35)
selectedLabel.Position = UDim2.fromOffset(90, 20)
selectedLabel.BackgroundTransparency = 1
selectedLabel.Text = selectedScript.Name
selectedLabel.TextColor3 = WHITE
selectedLabel.Font = Enum.Font.GothamBold
selectedLabel.TextSize = 22
selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
selectedLabel.Parent = contentPanel

-- ============================================================================
-- SELECTED GAME SUBTITLE
-- ============================================================================

local selectedSub = Instance.new("TextLabel")
selectedSub.Size = UDim2.new(1, -105, 0, 24)
selectedSub.Position = UDim2.fromOffset(90, 55)
selectedSub.BackgroundTransparency = 1
selectedSub.Text = "Enter your ZeHub access key"
selectedSub.TextColor3 = MUTED
selectedSub.Font = Enum.Font.Gotham
selectedSub.TextSize = 11
selectedSub.TextXAlignment = Enum.TextXAlignment.Left
selectedSub.Parent = contentPanel

-- Small underline
local selectedUnderline = Instance.new("Frame")
selectedUnderline.Size = UDim2.fromOffset(62, 3)
selectedUnderline.Position = UDim2.fromOffset(90, 82)
selectedUnderline.BackgroundColor3 = BLUE_LIGHT
selectedUnderline.BorderSizePixel = 0
selectedUnderline.Parent = contentPanel

Instance.new("UICorner", selectedUnderline).CornerRadius = UDim.new(1, 0)

-- ============================================================================
-- KEY BOX
-- ============================================================================

local keyBox = Instance.new("TextBox")
keyBox.Name = "KeyBox"
keyBox.Size = UDim2.new(1, -36, 0, 58)
keyBox.Position = UDim2.fromOffset(18, 101)
keyBox.BackgroundColor3 = INPUT
keyBox.BorderSizePixel = 0
keyBox.PlaceholderText = "Enter your ZeHub key..."
keyBox.PlaceholderColor3 = MUTED
keyBox.Text = ""
keyBox.TextColor3 = WHITE
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 12
keyBox.ClearTextOnFocus = false
keyBox.TextXAlignment = Enum.TextXAlignment.Left
keyBox.Parent = contentPanel

Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 10)

local keyStroke = Instance.new("UIStroke")
keyStroke.Color = BLUE
keyStroke.Transparency = 0.65
keyStroke.Thickness = 1
keyStroke.Parent = keyBox

local keyPadding = Instance.new("UIPadding")
keyPadding.PaddingLeft = UDim.new(0, 18)
keyPadding.PaddingRight = UDim.new(0, 15)
keyPadding.Parent = keyBox

keyBox.Focused:Connect(function()
    keyStroke.Color = BLUE_LIGHT
    keyStroke.Transparency = 0.2
end)

keyBox.FocusLost:Connect(function()
    keyStroke.Color = BLUE
    keyStroke.Transparency = 0.65
end)

-- ============================================================================
-- BUTTON ROW
-- ============================================================================

local buttonRow = Instance.new("Frame")
buttonRow.Size = UDim2.new(1, -36, 0, 45)
buttonRow.Position = UDim2.fromOffset(18, 169)
buttonRow.BackgroundTransparency = 1
buttonRow.Parent = contentPanel

-- ============================================================================
-- DISCORD ACTION
-- ============================================================================

local discordAction = Instance.new("TextButton")
discordAction.Name = "DiscordAction"
discordAction.Size = UDim2.new(0.5, -5, 1, 0)
discordAction.Position = UDim2.fromOffset(0, 0)
discordAction.BackgroundColor3 = CARD
discordAction.BorderSizePixel = 0
discordAction.Text = "DISCORD  ↗"
discordAction.TextColor3 = BLUE_LIGHT
discordAction.Font = Enum.Font.GothamBold
discordAction.TextSize = 10
discordAction.AutoButtonColor = false
discordAction.Parent = buttonRow

Instance.new("UICorner", discordAction).CornerRadius = UDim.new(0, 9)

local discordActionStroke = Instance.new("UIStroke")
discordActionStroke.Color = BLUE
discordActionStroke.Transparency = 0.45
discordActionStroke.Thickness = 1
discordActionStroke.Parent = discordAction

discordAction.MouseEnter:Connect(function()
    discordAction.BackgroundColor3 = CARD_HOVER
end)

discordAction.MouseLeave:Connect(function()
    discordAction.BackgroundColor3 = CARD
end)

discordAction.Activated:Connect(function()
    pcall(function()
        GuiService:OpenBrowserWindow(DISCORD_LINK)
    end)

    pcall(function()
        if setclipboard then
            setclipboard(DISCORD_LINK)
        end
    end)
end)

-- ============================================================================
-- GET KEY ACTION
-- ============================================================================

local getKeyButton = Instance.new("TextButton")
getKeyButton.Name = "GetKey"
getKeyButton.Size = UDim2.new(0.5, -5, 1, 0)
getKeyButton.Position = UDim2.new(0.5, 5, 0, 0)
getKeyButton.BackgroundColor3 = BLUE
getKeyButton.BorderSizePixel = 0
getKeyButton.Text = "GET KEY  ↗"
getKeyButton.TextColor3 = WHITE
getKeyButton.Font = Enum.Font.GothamBold
getKeyButton.TextSize = 10
getKeyButton.AutoButtonColor = false
getKeyButton.Parent = buttonRow

Instance.new("UICorner", getKeyButton).CornerRadius = UDim.new(0, 9)

local getKeyStroke = Instance.new("UIStroke")
getKeyStroke.Color = BLUE_LIGHT
getKeyStroke.Transparency = 0.35
getKeyStroke.Thickness = 1
getKeyStroke.Parent = getKeyButton

getKeyButton.MouseEnter:Connect(function()
    getKeyButton.BackgroundColor3 = BLUE_LIGHT
end)

getKeyButton.MouseLeave:Connect(function()
    getKeyButton.BackgroundColor3 = BLUE
end)

-- ============================================================================
-- LOAD SCRIPT BUTTON
-- ============================================================================

local runButton = Instance.new("TextButton")
runButton.Name = "LoadScript"
runButton.Size = UDim2.new(1, -36, 0, 49)
runButton.Position = UDim2.fromOffset(18, 224)
runButton.BackgroundColor3 = Color3.fromRGB(19, 111, 187)
runButton.BorderSizePixel = 0
runButton.Text = "⚡   LOAD SCRIPT                         ›"
runButton.TextColor3 = WHITE
runButton.Font = Enum.Font.GothamBold
runButton.TextSize = 12
runButton.AutoButtonColor = false
runButton.Parent = contentPanel

Instance.new("UICorner", runButton).CornerRadius = UDim.new(0, 9)

local loadStroke = Instance.new("UIStroke")
loadStroke.Color = BLUE_LIGHT
loadStroke.Transparency = 0.3
loadStroke.Thickness = 1
loadStroke.Parent = runButton

-- Orange right accent
local orangeAccent = Instance.new("Frame")
orangeAccent.Size = UDim2.fromOffset(5, 43)
orangeAccent.Position = UDim2.new(1, -8, 0.5, -21)
orangeAccent.BackgroundColor3 = ORANGE
orangeAccent.BorderSizePixel = 0
orangeAccent.Parent = runButton

Instance.new("UICorner", orangeAccent).CornerRadius = UDim.new(0, 3)

runButton.MouseEnter:Connect(function()
    runButton.BackgroundColor3 = Color3.fromRGB(24, 125, 205)
end)

runButton.MouseLeave:Connect(function()
    runButton.BackgroundColor3 = Color3.fromRGB(19, 111, 187)
end)

-- ============================================================================
-- STATUS BOX
-- ============================================================================

local statusBox = Instance.new("Frame")
statusBox.Name = "StatusBox"
statusBox.Size = UDim2.new(1, -36, 0, 48)
statusBox.Position = UDim2.fromOffset(18, 283)
statusBox.BackgroundColor3 = PANEL_2
statusBox.BorderSizePixel = 0
statusBox.Parent = contentPanel

Instance.new("UICorner", statusBox).CornerRadius = UDim.new(0, 9)

local statusStroke = Instance.new("UIStroke")
statusStroke.Color = BLUE
statusStroke.Transparency = 0.55
statusStroke.Thickness = 1
statusStroke.Parent = statusBox

-- Info icon
local infoIcon = Instance.new("TextLabel")
infoIcon.Size = UDim2.fromOffset(30, 30)
infoIcon.Position = UDim2.fromOffset(12, 9)
infoIcon.BackgroundTransparency = 1
infoIcon.Text = "ⓘ"
infoIcon.TextColor3 = BLUE_LIGHT
infoIcon.Font = Enum.Font.Gotham
infoIcon.TextSize = 21
infoIcon.Parent = statusBox

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -58, 1, 0)
status.Position = UDim2.fromOffset(50, 0)
status.BackgroundTransparency = 1
status.Text = "Ready. Enter your key to continue."
status.TextColor3 = MUTED
status.Font = Enum.Font.Gotham
status.TextSize = 10
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Center
status.Parent = statusBox

-- ============================================================================
-- GAME BUTTON CREATION
-- ============================================================================

local buttons = {}

local function createGameButton(scriptData)

    local button = Instance.new("TextButton")

    button.Size = UDim2.new(1, 0, 0, 58)
    button.BackgroundColor3 = CARD
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = gameList

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke")
    stroke.Color = BLUE
    stroke.Transparency = 0.8
    stroke.Thickness = 1
    stroke.Parent = button

    -- Icon background
    local iconBackground = Instance.new("Frame")
    iconBackground.Size = UDim2.fromOffset(40, 40)
    iconBackground.Position = UDim2.fromOffset(9, 9)
    iconBackground.BackgroundColor3 = PANEL_2
    iconBackground.BorderSizePixel = 0
    iconBackground.Parent = button

    Instance.new("UICorner", iconBackground).CornerRadius = UDim.new(0, 8)

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = scriptData.Short
    icon.TextColor3 = BLUE_LIGHT
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 18
    icon.Parent = iconBackground

    -- Game name
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -82, 0, 20)
    name.Position = UDim2.fromOffset(62, 10)
    name.BackgroundTransparency = 1
    name.Text = scriptData.Name
    name.TextColor3 = TEXT
    name.Font = Enum.Font.GothamBold
    name.TextSize = 11
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = button

    -- Description
    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(1, -82, 0, 18)
    description.Position = UDim2.fromOffset(62, 30)
    description.BackgroundTransparency = 1
    description.Text = scriptData.Description
    description.TextColor3 = MUTED
    description.Font = Enum.Font.Gotham
    description.TextSize = 8
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.Parent = button

    -- Arrow
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.fromOffset(25, 40)
    arrow.Position = UDim2.new(1, -33, 0.5, -20)
    arrow.BackgroundTransparency = 1
    arrow.Text = "›"
    arrow.TextColor3 = MUTED
    arrow.Font = Enum.Font.Gotham
    arrow.TextSize = 24
    arrow.Parent = button

    table.insert(buttons, {
        Button = button,
        Stroke = stroke,
        Script = scriptData
    })

    button.MouseEnter:Connect(function()

        if selectedScript ~= scriptData then
            button.BackgroundColor3 = CARD_HOVER
        end

    end)

    button.MouseLeave:Connect(function()

        if selectedScript ~= scriptData then
            button.BackgroundColor3 = CARD
        end

    end)

    button.Activated:Connect(function()

        selectedScript = scriptData

        selectedLabel.Text = scriptData.Name
        selectedIconText.Text = scriptData.Short

        if scriptData.Name == "Coming Soon" then

            selectedSub.Text = "This game is coming soon"
            status.Text = "This game is coming soon."

        else

            selectedSub.Text = "Enter your ZeHub access key"
            status.Text = "Ready to load " .. scriptData.Name .. "."

        end

        for _, data in ipairs(buttons) do

            data.Button.BackgroundColor3 = CARD
            data.Stroke.Color = BLUE
            data.Stroke.Transparency = 0.8

        end

        button.BackgroundColor3 = Color3.fromRGB(6, 42, 69)
        stroke.Color = BLUE_LIGHT
        stroke.Transparency = 0.15

    end)

    return button
end

-- ============================================================================
-- CREATE GAME BUTTONS
-- ============================================================================

for _, scriptData in ipairs(Scripts) do
    createGameButton(scriptData)
end

-- Select first
if buttons[1] then

    buttons[1].Button.BackgroundColor3 = Color3.fromRGB(6, 42, 69)
    buttons[1].Stroke.Color = BLUE_LIGHT
    buttons[1].Stroke.Transparency = 0.15

end

-- ============================================================================
-- GET KEY
-- ============================================================================

getKeyButton.Activated:Connect(function()

    status.Text = "Opening FlowAuth key page..."

    pcall(function()
        GuiService:OpenBrowserWindow(GET_KEY_LINK)
    end)

    pcall(function()
        if setclipboard then
            setclipboard(GET_KEY_LINK)
        end
    end)

    task.delay(1.5, function()

        if status and status.Parent then
            status.Text =
                "FlowAuth opened. Complete the steps and paste your key here."
        end

    end)

end)

-- ============================================================================
-- LOAD SCRIPT
-- ============================================================================

runButton.Activated:Connect(function()

    local key = keyBox.Text

    if key == "" then

        status.Text = "Please enter your ZeHub key first."
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

    status.Text = "Authenticating ZeHub key..."

    local ok, success, message = pcall(function()

        local source = game:HttpGet(
            "https://flowauth.net/v1/loaders/"
                .. selectedScript.Hash
                .. ".lua"
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

    status.Text =
        selectedScript.Name .. " loaded successfully!"

    task.wait(0.35)

    if gui and gui.Parent then
        gui:Destroy()
    end

end)

-- ============================================================================
-- MINIMIZE
-- ============================================================================

local minimized = false

minimizeButton.Activated:Connect(function()

    minimized = not minimized

    if minimized then

        body.Visible = false
        headerLine.Visible = false

        frame:TweenSize(
            UDim2.fromOffset(680, 118),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quint,
            0.25,
            true
        )

        minimizeButton.Text = "+"

    else

        body.Visible = true
        headerLine.Visible = true

        frame:TweenSize(
            UDim2.fromOffset(680, 430),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quint,
            0.25,
            true
        )

        minimizeButton.Text = "—"

    end

end)

-- ============================================================================
-- DRAGGING
-- ============================================================================

local dragging = false
local dragStart
local startPosition

local function updateDrag(input)

    local delta = input.Position - dragStart

    frame.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )

end

header.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = frame.Position

        input.Changed:Connect(function()

            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end

        end)

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then

        updateDrag(input)

    end

end)
