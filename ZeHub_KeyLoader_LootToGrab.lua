-- ============================================================================
-- ZeHub • Black Transparent Key System
-- Matches the ZeHub black / white glass UI branding.
-- FlowAuth functionality preserved.
-- ============================================================================

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local DISCORD_LINK = "https://discord.gg/pehqQJzRm9"
local GET_KEY_LINK = "https://flowauth.net/reward/95257bff957772ebbe918833738a8fea"
local LOGO_IMAGE = "rbxassetid://137776481151936"

-- ============================================================================
-- ZEHUB BLACK / GLASS THEME
-- ============================================================================

local BACKGROUND = Color3.fromRGB(7, 7, 8)
local TOPBAR = Color3.fromRGB(10, 10, 11)
local PANEL = Color3.fromRGB(11, 11, 12)
local ROW = Color3.fromRGB(15, 15, 16)
local ROW_HOVER = Color3.fromRGB(23, 23, 24)
local INPUT = Color3.fromRGB(11, 11, 12)

local BORDER = Color3.fromRGB(45, 45, 47)
local BORDER_BRIGHT = Color3.fromRGB(105, 105, 108)

local WHITE = Color3.fromRGB(245, 245, 246)
local TEXT = Color3.fromRGB(220, 220, 223)
local MUTED = Color3.fromRGB(145, 145, 149)
local PLACEHOLDER = Color3.fromRGB(82, 82, 86)
local DARK_MUTED = Color3.fromRGB(78, 78, 82)

local ACCENT = Color3.fromRGB(235, 235, 238)

-- Transparency levels are intentionally subtle so the UI stays readable.
local WINDOW_TRANSPARENCY = 0.08
local PANEL_TRANSPARENCY = 0.14
local ROW_TRANSPARENCY = 0.12
local INPUT_TRANSPARENCY = 0.08

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
        Name = "Loot To Grab",
        Short = "L",
        Description = "Get key & load script",
        Hash = "a315f0a408a8a08b7eace4550185adcb"
    }
}

local selectedScript = Scripts[1]

local old = playerGui:FindFirstChild("ZeHub Key System")
if old then
    old:Destroy()
end

-- ============================================================================
-- SCREEN GUI / SCALE
-- ============================================================================

local gui = Instance.new("ScreenGui")
gui.Name = "ZeHub Key System"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = gui

local function updateScale()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local viewport = camera.ViewportSize
    local widthScale = viewport.X / 900
    local heightScale = viewport.Y / 560

    scale.Scale = math.clamp(math.min(widthScale, heightScale), 0.72, 1.05)
end

updateScale()

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

-- ============================================================================
-- MAIN WINDOW
-- ============================================================================

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(680, 430)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = BACKGROUND
frame.BackgroundTransparency = WINDOW_TRANSPARENCY
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = BORDER_BRIGHT
frameStroke.Thickness = 1
frameStroke.Transparency = 0.45
frameStroke.Parent = frame

-- ============================================================================
-- HEADER
-- ============================================================================

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 118)
header.BackgroundColor3 = TOPBAR
header.BackgroundTransparency = 0.12
header.BorderSizePixel = 0
header.Parent = frame

local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, -36, 0, 1)
headerLine.Position = UDim2.fromOffset(18, 117)
headerLine.BackgroundColor3 = BORDER_BRIGHT
headerLine.BackgroundTransparency = 0.55
headerLine.BorderSizePixel = 0
headerLine.Parent = header

local logo = Instance.new("ImageLabel")
logo.Name = "ZeHubLogo"
logo.Size = UDim2.fromOffset(62, 62)
logo.Position = UDim2.fromOffset(22, 20)
logo.BackgroundTransparency = 1
logo.Image = LOGO_IMAGE
logo.ScaleType = Enum.ScaleType.Fit
logo.Parent = header

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

local titleLine = Instance.new("Frame")
titleLine.Size = UDim2.fromOffset(70, 2)
titleLine.Position = UDim2.fromOffset(92, 61)
titleLine.BackgroundColor3 = ACCENT
titleLine.BackgroundTransparency = 0.18
titleLine.BorderSizePixel = 0
titleLine.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.fromOffset(330, 22)
subtitle.Position = UDim2.fromOffset(92, 73)
subtitle.BackgroundTransparency = 1
subtitle.Text = "SCRIPT LOADER"
subtitle.TextColor3 = MUTED
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 9
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

-- ============================================================================
-- HELPERS
-- ============================================================================

local function makeStroke(parent, color, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or BORDER
    stroke.Transparency = transparency or 0.45
    stroke.Thickness = 1
    stroke.Parent = parent
    return stroke
end

local function rounded(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 9)
    corner.Parent = parent
    return corner
end

local function copyToClipboard(text)
    local copied = false

    pcall(function()
        if setclipboard then
            setclipboard(text)
            copied = true
        end
    end)

    return copied
end

local function openLink(link)
    local opened = false

    pcall(function()
        GuiService:OpenBrowserWindow(link)
        opened = true
    end)

    local copied = copyToClipboard(link)

    return opened, copied
end

-- ============================================================================
-- NOTIFICATION SYSTEM
-- ============================================================================

local notificationHolder = Instance.new("Frame")
notificationHolder.Name = "Notifications"
notificationHolder.Size = UDim2.fromOffset(350, 300)
notificationHolder.Position = UDim2.new(1, -365, 0, 22)
notificationHolder.BackgroundTransparency = 1
notificationHolder.ZIndex = 100
notificationHolder.Parent = gui

local notificationLayout = Instance.new("UIListLayout")
notificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notificationLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notificationLayout.Padding = UDim.new(0, 8)
notificationLayout.Parent = notificationHolder

local function notify(titleText, messageText, duration)
    local notification = Instance.new("Frame")
    notification.Size = UDim2.fromOffset(325, 68)
    notification.BackgroundColor3 = PANEL
    notification.BackgroundTransparency = 0.04
    notification.BorderSizePixel = 0
    notification.ClipsDescendants = true
    notification.ZIndex = 100
    notification.Parent = notificationHolder
    rounded(notification, 10)

    local notificationStroke = makeStroke(notification, BORDER_BRIGHT, 0.55)
    notificationStroke.ZIndex = 100

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.fromOffset(3, 40)
    indicator.Position = UDim2.fromOffset(11, 14)
    indicator.BackgroundColor3 = ACCENT
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 101
    indicator.Parent = notification
    rounded(indicator, 2)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -42, 0, 20)
    title.Position = UDim2.fromOffset(24, 9)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = WHITE
    title.Font = Enum.Font.GothamBold
    title.TextSize = 10
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 101
    title.Parent = notification

    local message = Instance.new("TextLabel")
    message.Size = UDim2.new(1, -42, 0, 30)
    message.Position = UDim2.fromOffset(24, 30)
    message.BackgroundTransparency = 1
    message.Text = messageText
    message.TextColor3 = MUTED
    message.Font = Enum.Font.Gotham
    message.TextSize = 9
    message.TextWrapped = true
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.ZIndex = 101
    message.Parent = notification

    notification.Position = UDim2.new(1, 30, 0, 0)

    tween = TweenService:Create(
        notification,
        TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, 0, 0, 0)}
    )
    tween:Play()

    task.delay(duration or 3, function()
        if not notification.Parent then
            return
        end

        local out = TweenService:Create(
            notification,
            TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            {
                Position = UDim2.new(1, 30, 0, 0),
                BackgroundTransparency = 1
            }
        )
        out:Play()

        task.delay(0.25, function()
            if notification and notification.Parent then
                notification:Destroy()
            end
        end)
    end)
end

-- ============================================================================
-- HEADER BUTTONS
-- ============================================================================

local discordButton = Instance.new("TextButton")
discordButton.Name = "Discord"
discordButton.Size = UDim2.fromOffset(145, 38)
discordButton.Position = UDim2.new(1, -195, 0, 27)
discordButton.BackgroundColor3 = ROW
discordButton.BackgroundTransparency = 0.1
discordButton.BorderSizePixel = 0
discordButton.Text = "DISCORD  ↗"
discordButton.TextColor3 = TEXT
discordButton.Font = Enum.Font.GothamBold
discordButton.TextSize = 10
discordButton.AutoButtonColor = false
discordButton.Parent = header
rounded(discordButton, 8)

local discordStroke = makeStroke(discordButton, BORDER_BRIGHT, 0.62)

discordButton.MouseEnter:Connect(function()
    TweenService:Create(discordButton, TweenInfo.new(0.15), {
        BackgroundColor3 = ROW_HOVER
    }):Play()
end)

discordButton.MouseLeave:Connect(function()
    TweenService:Create(discordButton, TweenInfo.new(0.15), {
        BackgroundColor3 = ROW
    }):Play()
end)

discordButton.Activated:Connect(function()
    local opened, copied = openLink(DISCORD_LINK)

    if copied then
        setStatusSuccess("DISCORD LINK COPIED  •  Invite copied to clipboard.")
        notify("DISCORD LINK COPIED", "The ZeHub Discord invite was copied.", 3)
    elseif opened then
        setStatusNormal("Discord opened  •  Join the ZeHub server.")
        notify("DISCORD", "The Discord invite was opened.", 3)
    else
        setStatusError("DISCORD  •  Unable to open the invite.")
        notify("DISCORD", "Could not open the Discord invite.", 3)
    end
end)

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
-- BODY
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
sidebar.BackgroundTransparency = PANEL_TRANSPARENCY
sidebar.BorderSizePixel = 0
sidebar.Parent = body
rounded(sidebar, 8)
makeStroke(sidebar, BORDER, 0.38)

local sidebarTitle = Instance.new("TextLabel")
sidebarTitle.Size = UDim2.new(1, -34, 0, 25)
sidebarTitle.Position = UDim2.fromOffset(17, 18)
sidebarTitle.BackgroundTransparency = 1
sidebarTitle.Text = "GAMES"
sidebarTitle.TextColor3 = TEXT
sidebarTitle.Font = Enum.Font.GothamBold
sidebarTitle.TextSize = 10
sidebarTitle.TextXAlignment = Enum.TextXAlignment.Left
sidebarTitle.Parent = sidebar

local gameList = Instance.new("Frame")
gameList.Size = UDim2.new(1, -24, 0, 195)
gameList.Position = UDim2.fromOffset(12, 55)
gameList.BackgroundTransparency = 1
gameList.Parent = sidebar

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 9)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = gameList

local footerLine = Instance.new("Frame")
footerLine.Size = UDim2.new(1, -34, 0, 1)
footerLine.Position = UDim2.new(0, 17, 1, -51)
footerLine.BackgroundColor3 = BORDER
footerLine.BackgroundTransparency = 0.5
footerLine.BorderSizePixel = 0
footerLine.Parent = sidebar

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -20, 0, 20)
footer.Position = UDim2.new(0, 10, 1, -38)
footer.BackgroundTransparency = 1
footer.Text = "ZeHub"
footer.TextColor3 = MUTED
footer.Font = Enum.Font.GothamMedium
footer.TextSize = 8
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.Parent = sidebar

-- ============================================================================
-- CONTENT PANEL
-- ============================================================================

local contentPanel = Instance.new("Frame")
contentPanel.Name = "ContentPanel"
contentPanel.Size = UDim2.new(1, -202, 0, 302)
contentPanel.Position = UDim2.fromOffset(202, 0)
contentPanel.BackgroundColor3 = PANEL
contentPanel.BackgroundTransparency = PANEL_TRANSPARENCY
contentPanel.BorderSizePixel = 0
contentPanel.Parent = body
rounded(contentPanel, 8)
makeStroke(contentPanel, BORDER, 0.38)

local selectedIcon = Instance.new("Frame")
selectedIcon.Name = "SelectedIcon"
selectedIcon.Size = UDim2.fromOffset(64, 64)
selectedIcon.Position = UDim2.fromOffset(18, 18)
selectedIcon.BackgroundColor3 = ROW
selectedIcon.BackgroundTransparency = ROW_TRANSPARENCY
selectedIcon.BorderSizePixel = 0
selectedIcon.Parent = contentPanel
rounded(selectedIcon, 7)
makeStroke(selectedIcon, BORDER_BRIGHT, 0.58)

local selectedIconText = Instance.new("TextLabel")
selectedIconText.Size = UDim2.new(1, 0, 1, 0)
selectedIconText.BackgroundTransparency = 1
selectedIconText.Text = selectedScript.Short
selectedIconText.TextColor3 = WHITE
selectedIconText.Font = Enum.Font.GothamBold
selectedIconText.TextSize = 28
selectedIconText.Parent = selectedIcon

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

local selectedUnderline = Instance.new("Frame")
selectedUnderline.Size = UDim2.fromOffset(62, 2)
selectedUnderline.Position = UDim2.fromOffset(90, 82)
selectedUnderline.BackgroundColor3 = ACCENT
selectedUnderline.BackgroundTransparency = 0.2
selectedUnderline.BorderSizePixel = 0
selectedUnderline.Parent = contentPanel
rounded(selectedUnderline, 1)

-- ============================================================================
-- KEY BOX
-- ============================================================================

local keyBox = Instance.new("TextBox")
keyBox.Name = "KeyBox"
keyBox.Size = UDim2.new(1, -36, 0, 58)
keyBox.Position = UDim2.fromOffset(18, 101)
keyBox.BackgroundColor3 = INPUT
keyBox.BackgroundTransparency = INPUT_TRANSPARENCY
keyBox.BorderSizePixel = 0
keyBox.PlaceholderText = "Enter your ZeHub key..."
keyBox.PlaceholderColor3 = PLACEHOLDER
keyBox.Text = ""
keyBox.TextColor3 = WHITE
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 12
keyBox.ClearTextOnFocus = false
keyBox.TextXAlignment = Enum.TextXAlignment.Left
keyBox.Parent = contentPanel
rounded(keyBox, 7)

local keyStroke = makeStroke(keyBox, BORDER, 0.4)

local keyPadding = Instance.new("UIPadding")
keyPadding.PaddingLeft = UDim.new(0, 18)
keyPadding.PaddingRight = UDim.new(0, 15)
keyPadding.Parent = keyBox

keyBox.Focused:Connect(function()
    keyStroke.Color = BORDER_BRIGHT
    keyStroke.Transparency = 0.15
end)

keyBox.FocusLost:Connect(function()
    keyStroke.Color = BORDER
    keyStroke.Transparency = 0.4
end)

-- ============================================================================
-- BUTTON ROW
-- ============================================================================

local buttonRow = Instance.new("Frame")
buttonRow.Size = UDim2.new(1, -36, 0, 45)
buttonRow.Position = UDim2.fromOffset(18, 169)
buttonRow.BackgroundTransparency = 1
buttonRow.Parent = contentPanel

local discordAction = Instance.new("TextButton")
discordAction.Name = "DiscordAction"
discordAction.Size = UDim2.new(0.5, -5, 1, 0)
discordAction.Position = UDim2.fromOffset(0, 0)
discordAction.BackgroundColor3 = ROW
discordAction.BackgroundTransparency = ROW_TRANSPARENCY
discordAction.BorderSizePixel = 0
discordAction.Text = "DISCORD  ↗"
discordAction.TextColor3 = TEXT
discordAction.Font = Enum.Font.GothamBold
discordAction.TextSize = 10
discordAction.AutoButtonColor = false
discordAction.Parent = buttonRow
rounded(discordAction, 6)
makeStroke(discordAction, BORDER, 0.35)

discordAction.MouseEnter:Connect(function()
    discordAction.BackgroundColor3 = ROW_HOVER
end)

discordAction.MouseLeave:Connect(function()
    discordAction.BackgroundColor3 = ROW
end)

discordAction.Activated:Connect(function()
    local opened, copied = openLink(DISCORD_LINK)

    if copied then
        setStatusSuccess("DISCORD LINK COPIED  •  Invite copied to clipboard.")
        notify("DISCORD LINK COPIED", "The ZeHub Discord invite was copied.", 3)
    elseif opened then
        setStatusNormal("Discord opened  •  Join the ZeHub server.")
        notify("DISCORD", "The Discord invite was opened.", 3)
    else
        setStatusError("DISCORD  •  Unable to open the invite.")
        notify("DISCORD", "Could not open the Discord invite.", 3)
    end
end)

local getKeyButton = Instance.new("TextButton")
getKeyButton.Name = "GetKey"
getKeyButton.Size = UDim2.new(0.5, -5, 1, 0)
getKeyButton.Position = UDim2.new(0.5, 5, 0, 0)
getKeyButton.BackgroundColor3 = ACCENT
getKeyButton.BackgroundTransparency = 0.03
getKeyButton.BorderSizePixel = 0
getKeyButton.Text = "GET KEY  ↗"
getKeyButton.TextColor3 = Color3.fromRGB(10, 10, 11)
getKeyButton.Font = Enum.Font.GothamBold
getKeyButton.TextSize = 10
getKeyButton.AutoButtonColor = false
getKeyButton.Parent = buttonRow
rounded(getKeyButton, 6)
makeStroke(getKeyButton, WHITE, 0.65)

getKeyButton.MouseEnter:Connect(function()
    getKeyButton.BackgroundColor3 = WHITE
end)

getKeyButton.MouseLeave:Connect(function()
    getKeyButton.BackgroundColor3 = ACCENT
end)

-- ============================================================================
-- LOAD BUTTON
-- ============================================================================

local runButton = Instance.new("TextButton")
runButton.Name = "LoadScript"
runButton.Size = UDim2.new(1, -36, 0, 49)
runButton.Position = UDim2.fromOffset(18, 224)
runButton.BackgroundColor3 = ROW_HOVER
runButton.BackgroundTransparency = 0.04
runButton.BorderSizePixel = 0
runButton.Text = "LOAD SCRIPT                         ›"
runButton.TextColor3 = WHITE
runButton.Font = Enum.Font.GothamBold
runButton.TextSize = 12
runButton.AutoButtonColor = false
runButton.Parent = contentPanel
rounded(runButton, 6)

local loadStroke = makeStroke(runButton, BORDER_BRIGHT, 0.25)

local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.fromOffset(3, 31)
accentBar.Position = UDim2.new(1, -8, 0.5, -15)
accentBar.BackgroundColor3 = ACCENT
accentBar.BackgroundTransparency = 0.05
accentBar.BorderSizePixel = 0
accentBar.Parent = runButton
rounded(accentBar, 2)

runButton.MouseEnter:Connect(function()
    runButton.BackgroundColor3 = Color3.fromRGB(30, 30, 32)
end)

runButton.MouseLeave:Connect(function()
    runButton.BackgroundColor3 = ROW_HOVER
end)

-- ============================================================================
-- STATUS
-- ============================================================================

local statusBox = Instance.new("Frame")
statusBox.Name = "StatusBox"
statusBox.Size = UDim2.new(1, -36, 0, 48)
statusBox.Position = UDim2.fromOffset(18, 283)
statusBox.BackgroundColor3 = PANEL
statusBox.BackgroundTransparency = PANEL_TRANSPARENCY
statusBox.BorderSizePixel = 0
statusBox.Parent = contentPanel
rounded(statusBox, 6)
makeStroke(statusBox, BORDER, 0.5)

local infoIcon = Instance.new("TextLabel")
infoIcon.Size = UDim2.fromOffset(30, 30)
infoIcon.Position = UDim2.fromOffset(12, 9)
infoIcon.BackgroundTransparency = 1
infoIcon.Text = "ⓘ"
infoIcon.TextColor3 = MUTED
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

local authorizing = false

local function setStatusNormal(text)
    status.Text = text
    infoIcon.Text = "ⓘ"
    infoIcon.TextColor3 = MUTED
end

local function setStatusLoading(text)
    status.Text = text
    infoIcon.Text = "◌"
    infoIcon.TextColor3 = WHITE
end

local function setStatusSuccess(text)
    status.Text = text
    infoIcon.Text = "✓"
    infoIcon.TextColor3 = WHITE
end

local function setStatusError(text)
    status.Text = text
    infoIcon.Text = "!"
    infoIcon.TextColor3 = WHITE
end

-- ============================================================================
-- AUTHORIZATION PANEL
-- ============================================================================

local authOverlay = Instance.new("Frame")
authOverlay.Name = "AuthorizationOverlay"
authOverlay.Size = UDim2.fromScale(1, 1)
authOverlay.BackgroundColor3 = BACKGROUND
authOverlay.BackgroundTransparency = 0.16
authOverlay.BorderSizePixel = 0
authOverlay.Visible = false
authOverlay.ZIndex = 50
authOverlay.Parent = frame

local authCard = Instance.new("Frame")
authCard.Size = UDim2.fromOffset(330, 205)
authCard.Position = UDim2.fromScale(0.5, 0.5)
authCard.AnchorPoint = Vector2.new(0.5, 0.5)
authCard.BackgroundColor3 = PANEL
authCard.BackgroundTransparency = 0.03
authCard.BorderSizePixel = 0
authCard.ZIndex = 51
authCard.Parent = authOverlay
rounded(authCard, 8)
makeStroke(authCard, BORDER_BRIGHT, 0.4)

local authTitle = Instance.new("TextLabel")
authTitle.Size = UDim2.new(1, -40, 0, 28)
authTitle.Position = UDim2.fromOffset(20, 20)
authTitle.BackgroundTransparency = 1
authTitle.Text = "AUTHORIZING ZEHUB"
authTitle.TextColor3 = WHITE
authTitle.Font = Enum.Font.GothamBold
authTitle.TextSize = 15
authTitle.TextXAlignment = Enum.TextXAlignment.Left
authTitle.ZIndex = 52
authTitle.Parent = authCard

local authSubtitle = Instance.new("TextLabel")
authSubtitle.Size = UDim2.new(1, -40, 0, 24)
authSubtitle.Position = UDim2.fromOffset(20, 50)
authSubtitle.BackgroundTransparency = 1
authSubtitle.Text = "Checking your access key..."
authSubtitle.TextColor3 = MUTED
authSubtitle.Font = Enum.Font.Gotham
authSubtitle.TextSize = 9
authSubtitle.TextXAlignment = Enum.TextXAlignment.Left
authSubtitle.ZIndex = 52
authSubtitle.Parent = authCard

local authSteps = {}

local function createAuthStep(index, textValue, y)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(8, 8)
    dot.Position = UDim2.fromOffset(21, y + 5)
    dot.BackgroundColor3 = DARK_MUTED
    dot.BorderSizePixel = 0
    dot.ZIndex = 52
    dot.Parent = authCard
    rounded(dot, 4)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 0, 20)
    label.Position = UDim2.fromOffset(40, y)
    label.BackgroundTransparency = 1
    label.Text = textValue
    label.TextColor3 = DARK_MUTED
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 9
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 52
    label.Parent = authCard

    authSteps[index] = {Dot = dot, Label = label}
end

createAuthStep(1, "Connecting to FlowAuth", 84)
createAuthStep(2, "Validating access key", 113)
createAuthStep(3, "Loading selected script", 142)

local authHint = Instance.new("TextLabel")
authHint.Size = UDim2.new(1, -40, 0, 22)
authHint.Position = UDim2.fromOffset(20, 173)
authHint.BackgroundTransparency = 1
authHint.Text = "Please wait..."
authHint.TextColor3 = DARK_MUTED
authHint.Font = Enum.Font.Gotham
authHint.TextSize = 8
authHint.TextXAlignment = Enum.TextXAlignment.Left
authHint.ZIndex = 52
authHint.Parent = authCard

local function authStep(index, state)
    local item = authSteps[index]
    if not item then
        return
    end

    if state == "active" then
        item.Dot.BackgroundColor3 = WHITE
        item.Label.TextColor3 = WHITE
    elseif state == "done" then
        item.Dot.BackgroundColor3 = WHITE
        item.Label.TextColor3 = TEXT
    else
        item.Dot.BackgroundColor3 = DARK_MUTED
        item.Label.TextColor3 = DARK_MUTED
    end
end

local function showAuthOverlay()
    authOverlay.Visible = true
    authOverlay.BackgroundTransparency = 1
    authCard.Position = UDim2.fromScale(0.5, 0.54)

    for i = 1, #authSteps do
        authStep(i, "idle")
    end

    TweenService:Create(
        authOverlay,
        TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0.16}
    ):Play()

    TweenService:Create(
        authCard,
        TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {Position = UDim2.fromScale(0.5, 0.5)}
    ):Play()
end

local function hideAuthOverlay()
    authOverlay.Visible = false
end

-- ============================================================================
-- GAME BUTTONS
-- ============================================================================

local buttons = {}

local function updateGameSelection()
    for _, data in ipairs(buttons) do
        local selected = data.Script == selectedScript

        if selected then
            data.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 27)
            data.Stroke.Color = BORDER_BRIGHT
            data.Stroke.Transparency = 0.18
        else
            data.Button.BackgroundColor3 = ROW
            data.Stroke.Color = BORDER
            data.Stroke.Transparency = 0.65
        end
    end
end

local function selectGame(scriptData)
    if not scriptData then
        return
    end

    selectedScript = scriptData

    selectedLabel.Text = scriptData.Name
    selectedIconText.Text = scriptData.Short
    keyBox.Text = ""

    if scriptData.Name == "Coming Soon" then
        selectedSub.Text = "This game is coming soon"
        setStatusNormal("This game is coming soon.")
    else
        selectedSub.Text = "Enter your ZeHub access key"
        setStatusNormal("Ready to load " .. scriptData.Name .. ".")
    end

    updateGameSelection()
end

local function createGameButton(scriptData)
    local button = Instance.new("TextButton")
    button.Name = scriptData.Name:gsub("%s+", "") .. "Button"
    button.Size = UDim2.new(1, 0, 0, 58)
    button.BackgroundColor3 = ROW
    button.BackgroundTransparency = ROW_TRANSPARENCY
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.Active = true
    button.Parent = gameList
    rounded(button, 7)

    local stroke = makeStroke(button, BORDER, 0.65)

    local iconBackground = Instance.new("Frame")
    iconBackground.Size = UDim2.fromOffset(40, 40)
    iconBackground.Position = UDim2.fromOffset(9, 9)
    iconBackground.BackgroundColor3 = INPUT
    iconBackground.BackgroundTransparency = 0.04
    iconBackground.BorderSizePixel = 0
    iconBackground.Active = false
    iconBackground.Parent = button
    rounded(iconBackground, 6)

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = scriptData.Short
    icon.TextColor3 = WHITE
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 18
    icon.Active = false
    icon.Parent = iconBackground

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -82, 0, 20)
    name.Position = UDim2.fromOffset(62, 10)
    name.BackgroundTransparency = 1
    name.Text = scriptData.Name
    name.TextColor3 = TEXT
    name.Font = Enum.Font.GothamBold
    name.TextSize = 11
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Active = false
    name.Parent = button

    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(1, -82, 0, 18)
    description.Position = UDim2.fromOffset(62, 30)
    description.BackgroundTransparency = 1
    description.Text = scriptData.Description
    description.TextColor3 = MUTED
    description.Font = Enum.Font.Gotham
    description.TextSize = 8
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.Active = false
    description.Parent = button

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.fromOffset(25, 40)
    arrow.Position = UDim2.new(1, -33, 0.5, -20)
    arrow.BackgroundTransparency = 1
    arrow.Text = "›"
    arrow.TextColor3 = MUTED
    arrow.Font = Enum.Font.Gotham
    arrow.TextSize = 24
    arrow.Active = false
    arrow.Parent = button

    table.insert(buttons, {
        Button = button,
        Stroke = stroke,
        Script = scriptData
    })

    button.MouseEnter:Connect(function()
        if selectedScript ~= scriptData then
            button.BackgroundColor3 = ROW_HOVER
        end
    end)

    button.MouseLeave:Connect(function()
        if selectedScript ~= scriptData then
            button.BackgroundColor3 = ROW
        end
    end)

    -- Activated handles both mouse and touch without the duplicate InputBegan handler.
    button.Activated:Connect(function()
        selectGame(scriptData)
    end)

    return button
end

for _, scriptData in ipairs(Scripts) do
    createGameButton(scriptData)
end

updateGameSelection()

-- ============================================================================
-- GET KEY
-- ============================================================================

getKeyButton.Activated:Connect(function()
    setStatusLoading("OPENING FLOWAUTH  •  Preparing your key page...")
    notify("GET KEY", "Opening FlowAuth and copying the key link.", 2.5)

    local opened, copied = openLink(GET_KEY_LINK)

    if copied and opened then
        setStatusSuccess("KEY LINK COPIED  •  FlowAuth opened in your browser.")
        notify("KEY LINK COPIED", "The FlowAuth link is on your clipboard.", 3)
    elseif copied then
        setStatusSuccess("KEY LINK COPIED  •  Paste it into your browser.")
        notify("KEY LINK COPIED", "The FlowAuth link was copied.", 3)
    elseif opened then
        setStatusNormal("FLOWAUTH OPENED  •  Complete the steps and copy your key.")
        notify("FLOWAUTH OPENED", "Complete the key steps, then return here.", 3)
    else
        setStatusError("FLOWAUTH  •  Unable to open the key page.")
        notify("FLOWAUTH", "Could not open the key page.", 3)
    end
end)

-- ============================================================================
-- LOAD SCRIPT / AUTHENTICATION
-- ============================================================================

runButton.Activated:Connect(function()
    if authorizing then
        return
    end

    local key = tostring(keyBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")

    if key == "" then
        setStatusError("KEY REQUIRED  •  Enter your ZeHub key first.")
        notify("KEY REQUIRED", "Enter your ZeHub key before loading.", 3)
        return
    end

    if not selectedScript then
        setStatusError("NO SCRIPT SELECTED  •  Select a supported game.")
        return
    end

    if selectedScript.Name == "Coming Soon" then
        setStatusError("COMING SOON  •  This game is not available yet.")
        notify("COMING SOON", "This script is not available yet.", 3)
        return
    end

    authorizing = true
    runButton.Active = false
    runButton.Text = "◌   AUTHORIZING ZEHUB..."
    setStatusLoading("AUTHORIZING ZEHUB  •  Checking your access key...")
    notify("AUTHORIZING ZEHUB", "Validating your key with FlowAuth.", 2)

    showAuthOverlay()

    authTitle.Text = "AUTHORIZING ZEHUB"
    authSubtitle.Text = "Connecting to FlowAuth..."
    authHint.Text = "Do not close the loader while authorization is running."

    authStep(1, "active")
    authStep(2, "idle")
    authStep(3, "idle")

    task.wait(0.25)
    authStep(1, "done")
    authStep(2, "active")
    authSubtitle.Text = "Validating your access key..."
    setStatusLoading("AUTHORIZING ZEHUB  •  Validating your access key...")

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
        authorizing = false
        runButton.Active = true
        runButton.Text = "LOAD SCRIPT                         ›"

        authTitle.Text = "AUTHENTICATION FAILED"
        authSubtitle.Text = "The loader returned an error."
        authHint.Text = "Check your key and try again."
        authStep(2, "idle")

        setStatusError("AUTHENTICATION FAILED  •  " .. tostring(success))
        notify("AUTHENTICATION FAILED", tostring(success), 4)

        task.delay(0.8, hideAuthOverlay)
        return
    end

    if success == false then
        authorizing = false
        runButton.Active = true
        runButton.Text = "LOAD SCRIPT                         ›"

        authTitle.Text = "INVALID KEY"
        authSubtitle.Text = tostring(message or "The key is invalid or expired.")
        authHint.Text = "Get a new key through FlowAuth and try again."
        authStep(2, "idle")

        setStatusError(
            "INVALID KEY  •  "
                .. tostring(message or "Invalid or expired key.")
        )

        notify(
            "INVALID KEY",
            tostring(message or "The key is invalid or expired."),
            4
        )

        task.delay(0.8, hideAuthOverlay)
        return
    end

    authStep(2, "done")
    authStep(3, "active")
    authTitle.Text = "ACCESS GRANTED"
    authSubtitle.Text = "Key verified successfully."
    authHint.Text = "Loading " .. selectedScript.Name .. "..."

    setStatusSuccess("ACCESS GRANTED  •  Key verified successfully.")
    runButton.Text = "✓   ACCESS GRANTED"

    notify(
        "ACCESS GRANTED",
        "Key verified. Loading " .. selectedScript.Name .. "...",
        2
    )

    task.wait(0.65)

    authStep(3, "done")
    authTitle.Text = "LOADED"
    authSubtitle.Text = selectedScript.Name .. " loaded successfully."
    authHint.Text = "ZeHub authorization completed."

    setStatusSuccess(selectedScript.Name .. " loaded successfully!")

    task.wait(0.45)

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

-- ============================================================================
-- FINAL
-- ============================================================================

task.defer(function()
    task.wait(0.2)
    if gui and gui.Parent then
        setStatusNormal("Ready. Enter your access key to continue.")
        notify("ZEHUB READY", "Enter your access key to continue.", 2.5)
    end
end)
