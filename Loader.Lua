-- ============================================================================
-- ZeHub • Black Glass Key System
-- ============================================================================

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================================
-- LINKS
-- ============================================================================

local DISCORD_LINK = "https://discord.gg/pehqQJzRm9"

local GET_KEY_LINK =
    "https://flowauth.net/reward/95257bff957772ebbe918833738a8fea"

-- ============================================================================
-- LOGO
-- ============================================================================

local LOGO_IMAGE = "rbxassetid://137776481151936"

-- ============================================================================
-- BLACK / GLASS THEME
-- ============================================================================

local BACKGROUND = Color3.fromRGB(7, 7, 8)
local HEADER = Color3.fromRGB(10, 10, 11)

local PANEL = Color3.fromRGB(11, 11, 12)
local PANEL_2 = Color3.fromRGB(15, 15, 16)

local CARD = Color3.fromRGB(16, 16, 17)
local CARD_HOVER = Color3.fromRGB(24, 24, 25)
local CARD_SELECTED = Color3.fromRGB(28, 28, 29)

local INPUT = Color3.fromRGB(11, 11, 12)

local BORDER = Color3.fromRGB(45, 45, 47)
local BORDER_BRIGHT = Color3.fromRGB(100, 100, 103)

local WHITE = Color3.fromRGB(245, 245, 246)
local TEXT = Color3.fromRGB(220, 220, 223)

local MUTED = Color3.fromRGB(145, 145, 149)
local DARK_MUTED = Color3.fromRGB(82, 82, 86)

local SUCCESS = Color3.fromRGB(220, 220, 222)
local ERROR = Color3.fromRGB(190, 190, 193)

local WINDOW_TRANSPARENCY = 0.08
local PANEL_TRANSPARENCY = 0.14
local CARD_TRANSPARENCY = 0.10
local INPUT_TRANSPARENCY = 0.08

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

    local widthScale =
        viewport.X / 900

    local heightScale =
        viewport.Y / 560

    local finalScale =
        math.min(widthScale, heightScale)

    scale.Scale =
        math.clamp(finalScale, 0.72, 1.05)

end

updateScale()

if workspace.CurrentCamera then

    workspace.CurrentCamera:GetPropertyChangedSignal(
        "ViewportSize"
    ):Connect(updateScale)

end

-- ============================================================================
-- HELPERS
-- ============================================================================

local function rounded(parent, radius)

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, radius or 9)

    corner.Parent = parent

    return corner

end

local function stroke(parent, color, transparency, thickness)

    local s =
        Instance.new("UIStroke")

    s.Color =
        color or BORDER

    s.Transparency =
        transparency or 0.45

    s.Thickness =
        thickness or 1

    s.Parent = parent

    return s

end

local function tween(object, properties, duration)

    local info =
        TweenInfo.new(
            duration or 0.2,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        )

    return TweenService:Create(
        object,
        info,
        properties
    )

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

local function openLink(text)

    pcall(function()

        GuiService:OpenBrowserWindow(text)

    end)

    return copyToClipboard(text)

end

-- ============================================================================
-- NOTIFICATION SYSTEM
-- ============================================================================

local notificationHolder =
    Instance.new("Frame")

notificationHolder.Name =
    "Notifications"

notificationHolder.Size =
    UDim2.fromOffset(360, 300)

notificationHolder.Position =
    UDim2.new(1, -380, 0, 25)

notificationHolder.BackgroundTransparency = 1

notificationHolder.Parent = gui

local notificationLayout =
    Instance.new("UIListLayout")

notificationLayout.HorizontalAlignment =
    Enum.HorizontalAlignment.Right

notificationLayout.VerticalAlignment =
    Enum.VerticalAlignment.Top

notificationLayout.Padding =
    UDim.new(0, 8)

notificationLayout.Parent =
    notificationHolder

local function notify(titleText, messageText, duration)

    local notification =
        Instance.new("Frame")

    notification.Name =
        "Notification"

    notification.Size =
        UDim2.fromOffset(330, 70)

    notification.BackgroundColor3 =
        PANEL

    notification.BackgroundTransparency =
        0.05

    notification.BorderSizePixel = 0

    notification.ClipsDescendants = true

    notification.Parent =
        notificationHolder

    rounded(notification, 10)

    local notificationStroke =
        stroke(
            notification,
            BORDER_BRIGHT,
            0.55,
            1
        )

    local indicator =
        Instance.new("Frame")

    indicator.Size =
        UDim2.fromOffset(3, 42)

    indicator.Position =
        UDim2.fromOffset(12, 14)

    indicator.BackgroundColor3 =
        ACCENT

    indicator.BorderSizePixel = 0

    indicator.Parent =
        notification

    rounded(indicator, 2)

    local title =
        Instance.new("TextLabel")

    title.Size =
        UDim2.new(1, -45, 0, 22)

    title.Position =
        UDim2.fromOffset(27, 10)

    title.BackgroundTransparency = 1

    title.Text =
        titleText

    title.TextColor3 =
        WHITE

    title.Font =
        Enum.Font.GothamBold

    title.TextSize = 10

    title.TextXAlignment =
        Enum.TextXAlignment.Left

    title.Parent =
        notification

    local message =
        Instance.new("TextLabel")

    message.Size =
        UDim2.new(1, -45, 0, 28)

    message.Position =
        UDim2.fromOffset(27, 32)

    message.BackgroundTransparency = 1

    message.Text =
        messageText

    message.TextColor3 =
        MUTED

    message.Font =
        Enum.Font.Gotham

    message.TextSize = 9

    message.TextWrapped = true

    message.TextXAlignment =
        Enum.TextXAlignment.Left

    message.Parent =
        notification

    notification.Position =
        UDim2.new(1, 40, 0, 0)

    tween(
        notification,
        {
            Position =
                UDim2.new(1, 0, 0, 0)
        },
        0.25
    ):Play()

    task.delay(
        duration or 3,
        function()

            if not notification.Parent then
                return
            end

            local out =
                tween(
                    notification,
                    {
                        Position =
                            UDim2.new(1, 40, 0, 0),
                        BackgroundTransparency = 1
                    },
                    0.25
                )

            out:Play()

            task.delay(
                0.3,
                function()

                    if notification then
                        notification:Destroy()
                    end

                end
            )

        end
    )

end

-- ============================================================================
-- MAIN FRAME
-- ============================================================================

local frame =
    Instance.new("Frame")

frame.Name =
    "Main"

frame.Size =
    UDim2.fromOffset(680, 430)

frame.Position =
    UDim2.fromScale(0.5, 0.5)

frame.AnchorPoint =
    Vector2.new(0.5, 0.5)

frame.BackgroundColor3 =
    BACKGROUND

frame.BackgroundTransparency =
    WINDOW_TRANSPARENCY

frame.BorderSizePixel = 0

frame.ClipsDescendants = true

frame.Parent = gui

rounded(frame, 14)

stroke(
    frame,
    BORDER_BRIGHT,
    0.45,
    1.15
)

-- ============================================================================
-- HEADER
-- ============================================================================

local header =
    Instance.new("Frame")

header.Name =
    "Header"

header.Size =
    UDim2.new(1, 0, 0, 118)

header.BackgroundColor3 =
    HEADER

header.BackgroundTransparency =
    0.08

header.BorderSizePixel = 0

header.Parent = frame

local headerLine =
    Instance.new("Frame")

headerLine.Size =
    UDim2.new(1, -36, 0, 1)

headerLine.Position =
    UDim2.fromOffset(18, 117)

headerLine.BackgroundColor3 =
    BORDER_BRIGHT

headerLine.BackgroundTransparency =
    0.65

headerLine.BorderSizePixel = 0

headerLine.Parent = header

-- ============================================================================
-- LOGO
-- ============================================================================

local logo =
    Instance.new("ImageLabel")

logo.Name =
    "ZeHubLogo"

logo.Size =
    UDim2.fromOffset(62, 62)

logo.Position =
    UDim2.fromOffset(22, 20)

logo.BackgroundTransparency = 1

logo.Image =
    LOGO_IMAGE

logo.ScaleType =
    Enum.ScaleType.Fit

logo.Parent =
    header

-- ============================================================================
-- TITLE
-- ============================================================================

local title =
    Instance.new("TextLabel")

title.Size =
    UDim2.fromOffset(300, 34)

title.Position =
    UDim2.fromOffset(92, 24)

title.BackgroundTransparency = 1

title.Text =
    "ZEHUB"

title.TextColor3 =
    WHITE

title.Font =
    Enum.Font.GothamBold

title.TextSize =
    25

title.TextXAlignment =
    Enum.TextXAlignment.Left

title.Parent =
    header

local titleLine =
    Instance.new("Frame")

titleLine.Size =
    UDim2.fromOffset(70, 2)

titleLine.Position =
    UDim2.fromOffset(92, 61)

titleLine.BackgroundColor3 =
    BORDER_BRIGHT

titleLine.BackgroundTransparency =
    0.25

titleLine.BorderSizePixel = 0

titleLine.Parent =
    header

rounded(titleLine, 2)

-- ============================================================================
-- SUBTITLE
-- ============================================================================

local subtitle =
    Instance.new("TextLabel")

subtitle.Size =
    UDim2.fromOffset(330, 22)

subtitle.Position =
    UDim2.fromOffset(92, 73)

subtitle.BackgroundTransparency = 1

subtitle.Text =
    "SCRIPT LOADER   •   SECURE ACCESS"

subtitle.TextColor3 =
    MUTED

subtitle.Font =
    Enum.Font.GothamMedium

subtitle.TextSize =
    9

subtitle.TextXAlignment =
    Enum.TextXAlignment.Left

subtitle.Parent =
    header

-- ============================================================================
-- DISCORD HEADER BUTTON
-- ============================================================================

local discordButton =
    Instance.new("TextButton")

discordButton.Name =
    "Discord"

discordButton.Size =
    UDim2.fromOffset(145, 38)

discordButton.Position =
    UDim2.new(1, -195, 0, 27)

discordButton.BackgroundColor3 =
    PANEL_2

discordButton.BackgroundTransparency =
    0.12

discordButton.BorderSizePixel = 0

discordButton.Text =
    "DISCORD  ↗"

discordButton.TextColor3 =
    TEXT

discordButton.Font =
    Enum.Font.GothamBold

discordButton.TextSize =
    10

discordButton.AutoButtonColor = false

discordButton.Parent =
    header

rounded(discordButton, 8)

local discordStroke =
    stroke(
        discordButton,
        BORDER,
        0.35,
        1
    )

discordButton.MouseEnter:Connect(function()

    discordButton.BackgroundColor3 =
        CARD_HOVER

    discordStroke.Color =
        BORDER_BRIGHT

end)

discordButton.MouseLeave:Connect(function()

    discordButton.BackgroundColor3 =
        PANEL_2

    discordStroke.Color =
        BORDER

end)

discordButton.Activated:Connect(function()

    local copied =
        openLink(DISCORD_LINK)

    if copied then

        notify(
            "DISCORD LINK COPIED",
            "Discord invite copied to clipboard.",
            3
        )

    else

        notify(
            "DISCORD",
            "Opening the Discord invite.",
            3
        )

    end

end)

-- ============================================================================
-- MINIMIZE
-- ============================================================================

local minimizeButton =
    Instance.new("TextButton")

minimizeButton.Name =
    "Minimize"

minimizeButton.Size =
    UDim2.fromOffset(35, 35)

minimizeButton.Position =
    UDim2.new(1, -92, 0, 28)

minimizeButton.BackgroundTransparency = 1

minimizeButton.Text =
    "—"

minimizeButton.TextColor3 =
    MUTED

minimizeButton.Font =
    Enum.Font.GothamBold

minimizeButton.TextSize =
    18

minimizeButton.AutoButtonColor = false

minimizeButton.Parent =
    header

minimizeButton.MouseEnter:Connect(function()

    minimizeButton.TextColor3 =
        WHITE

end)

minimizeButton.MouseLeave:Connect(function()

    minimizeButton.TextColor3 =
        MUTED

end)

-- ============================================================================
-- CLOSE
-- ============================================================================

local closeButton =
    Instance.new("TextButton")

closeButton.Name =
    "Close"

closeButton.Size =
    UDim2.fromOffset(35, 35)

closeButton.Position =
    UDim2.new(1, -50, 0, 28)

closeButton.BackgroundTransparency = 1

closeButton.Text =
    "×"

closeButton.TextColor3 =
    MUTED

closeButton.Font =
    Enum.Font.Gotham

closeButton.TextSize =
    25

closeButton.AutoButtonColor = false

closeButton.Parent =
    header

closeButton.MouseEnter:Connect(function()

    closeButton.TextColor3 =
        WHITE

end)

closeButton.MouseLeave:Connect(function()

    closeButton.TextColor3 =
        MUTED

end)

closeButton.Activated:Connect(function()

    gui:Destroy()

end)

-- ============================================================================
-- BODY
-- ============================================================================

local body =
    Instance.new("Frame")

body.Name =
    "Body"

body.Size =
    UDim2.new(1, -36, 1, -136)

body.Position =
    UDim2.fromOffset(18, 128)

body.BackgroundTransparency = 1

body.Parent =
    frame

-- ============================================================================
-- SIDEBAR
-- ============================================================================

local sidebar =
    Instance.new("Frame")

sidebar.Name =
    "Sidebar"

sidebar.Size =
    UDim2.fromOffset(190, 302)

sidebar.Position =
    UDim2.fromOffset(0, 0)

sidebar.BackgroundColor3 =
    PANEL

sidebar.BackgroundTransparency =
    PANEL_TRANSPARENCY

sidebar.BorderSizePixel = 0

sidebar.Parent =
    body

rounded(sidebar, 12)

stroke(
    sidebar,
    BORDER,
    0.42,
    1
)

-- ============================================================================
-- SIDEBAR TITLE
-- ============================================================================

local sidebarTitle =
    Instance.new("TextLabel")

sidebarTitle.Size =
    UDim2.new(1, -34, 0, 25)

sidebarTitle.Position =
    UDim2.fromOffset(17, 18)

sidebarTitle.BackgroundTransparency = 1

sidebarTitle.Text =
    "◆  SUPPORTED GAMES"

sidebarTitle.TextColor3 =
    TEXT

sidebarTitle.Font =
    Enum.Font.GothamBold

sidebarTitle.TextSize =
    10

sidebarTitle.TextXAlignment =
    Enum.TextXAlignment.Left

sidebarTitle.Parent =
    sidebar

-- ============================================================================
-- GAME LIST
-- ============================================================================

local gameList =
    Instance.new("Frame")

gameList.Size =
    UDim2.new(1, -24, 0, 195)

gameList.Position =
    UDim2.fromOffset(12, 55)

gameList.BackgroundTransparency = 1

gameList.Parent =
    sidebar

local listLayout =
    Instance.new("UIListLayout")

listLayout.Padding =
    UDim.new(0, 9)

listLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

listLayout.Parent =
    gameList

-- ============================================================================
-- SIDEBAR FOOTER
-- ============================================================================

local footerLine =
    Instance.new("Frame")

footerLine.Size =
    UDim2.new(1, -34, 0, 1)

footerLine.Position =
    UDim2.new(0, 17, 1, -51)

footerLine.BackgroundColor3 =
    BORDER

footerLine.BackgroundTransparency =
    0.45

footerLine.BorderSizePixel = 0

footerLine.Parent =
    sidebar

local footer =
    Instance.new("TextLabel")

footer.Size =
    UDim2.new(1, -20, 0, 20)

footer.Position =
    UDim2.new(0, 10, 1, -38)

footer.BackgroundTransparency = 1

footer.Text =
    "FAST   •   SECURE   •   RELIABLE"

footer.TextColor3 =
    DARK_MUTED

footer.Font =
    Enum.Font.GothamMedium

footer.TextSize =
    8

footer.TextXAlignment =
    Enum.TextXAlignment.Center

footer.Parent =
    sidebar

-- ============================================================================
-- CONTENT PANEL
-- ============================================================================

local contentPanel =
    Instance.new("Frame")

contentPanel.Name =
    "ContentPanel"

contentPanel.Size =
    UDim2.new(1, -202, 0, 302)

contentPanel.Position =
    UDim2.fromOffset(202, 0)

contentPanel.BackgroundColor3 =
    PANEL

contentPanel.BackgroundTransparency =
    PANEL_TRANSPARENCY

contentPanel.BorderSizePixel = 0

contentPanel.Parent =
    body

rounded(contentPanel, 12)

stroke(
    contentPanel,
    BORDER,
    0.42,
    1
)

-- ============================================================================
-- SELECTED ICON
-- ============================================================================

local selectedIcon =
    Instance.new("Frame")

selectedIcon.Size =
    UDim2.fromOffset(64, 64)

selectedIcon.Position =
    UDim2.fromOffset(18, 18)

selectedIcon.BackgroundColor3 =
    CARD

selectedIcon.BackgroundTransparency =
    CARD_TRANSPARENCY

selectedIcon.BorderSizePixel = 0

selectedIcon.Parent =
    contentPanel

rounded(selectedIcon, 10)

stroke(
    selectedIcon,
    BORDER_BRIGHT,
    0.5,
    1
)

local selectedIconText =
    Instance.new("TextLabel")

selectedIconText.Size =
    UDim2.new(1, 0, 1, 0)

selectedIconText.BackgroundTransparency = 1

selectedIconText.Text =
    selectedScript.Short

selectedIconText.TextColor3 =
    WHITE

selectedIconText.Font =
    Enum.Font.GothamBold

selectedIconText.TextSize =
    28

selectedIconText.Parent =
    selectedIcon

-- ============================================================================
-- SELECTED GAME NAME
-- ============================================================================

local selectedLabel =
    Instance.new("TextLabel")

selectedLabel.Size =
    UDim2.new(1, -105, 0, 35)

selectedLabel.Position =
    UDim2.fromOffset(90, 20)

selectedLabel.BackgroundTransparency = 1

selectedLabel.Text =
    selectedScript.Name

selectedLabel.TextColor3 =
    WHITE

selectedLabel.Font =
    Enum.Font.GothamBold

selectedLabel.TextSize =
    22

selectedLabel.TextXAlignment =
    Enum.TextXAlignment.Left

selectedLabel.Parent =
    contentPanel

-- ============================================================================
-- SELECTED SUBTITLE
-- ============================================================================

local selectedSub =
    Instance.new("TextLabel")

selectedSub.Size =
    UDim2.new(1, -105, 0, 24)

selectedSub.Position =
    UDim2.fromOffset(90, 55)

selectedSub.BackgroundTransparency = 1

selectedSub.Text =
    "Enter your ZeHub access key"

selectedSub.TextColor3 =
    MUTED

selectedSub.Font =
    Enum.Font.Gotham

selectedSub.TextSize =
    11

selectedSub.TextXAlignment =
    Enum.TextXAlignment.Left

selectedSub.Parent =
    contentPanel

local selectedUnderline =
    Instance.new("Frame")

selectedUnderline.Size =
    UDim2.fromOffset(62, 2)

selectedUnderline.Position =
    UDim2.fromOffset(90, 82)

selectedUnderline.BackgroundColor3 =
    BORDER_BRIGHT

selectedUnderline.BackgroundTransparency =
    0.15

selectedUnderline.BorderSizePixel = 0

selectedUnderline.Parent =
    contentPanel

rounded(selectedUnderline, 2)

-- ============================================================================
-- KEY BOX
-- ============================================================================

local keyBox =
    Instance.new("TextBox")

keyBox.Name =
    "KeyBox"

keyBox.Size =
    UDim2.new(1, -36, 0, 58)

keyBox.Position =
    UDim2.fromOffset(18, 101)

keyBox.BackgroundColor3 =
    INPUT

keyBox.BackgroundTransparency =
    INPUT_TRANSPARENCY

keyBox.BorderSizePixel = 0

keyBox.PlaceholderText =
    "Enter your ZeHub key..."

keyBox.PlaceholderColor3 =
    DARK_MUTED

keyBox.Text =
    ""

keyBox.TextColor3 =
    WHITE

keyBox.Font =
    Enum.Font.Gotham

keyBox.TextSize =
    12

keyBox.ClearTextOnFocus = false

keyBox.TextXAlignment =
    Enum.TextXAlignment.Left

keyBox.Parent =
    contentPanel

rounded(keyBox, 10)

local keyStroke =
    stroke(
        keyBox,
        BORDER,
        0.35,
        1
    )

local keyPadding =
    Instance.new("UIPadding")

keyPadding.PaddingLeft =
    UDim.new(0, 18)

keyPadding.PaddingRight =
    UDim.new(0, 15)

keyPadding.Parent =
    keyBox

keyBox.Focused:Connect(function()

    tween(
        keyStroke,
        {
            Color = BORDER_BRIGHT,
            Transparency = 0.05
        },
        0.15
    ):Play()

end)

keyBox.FocusLost:Connect(function()

    tween(
        keyStroke,
        {
            Color = BORDER,
            Transparency = 0.35
        },
        0.15
    ):Play()

end)

-- ============================================================================
-- BUTTON ROW
-- ============================================================================

local buttonRow =
    Instance.new("Frame")

buttonRow.Size =
    UDim2.new(1, -36, 0, 45)

buttonRow.Position =
    UDim2.fromOffset(18, 169)

buttonRow.BackgroundTransparency = 1

buttonRow.Parent =
    contentPanel

-- ============================================================================
-- DISCORD ACTION
-- ============================================================================

local discordAction =
    Instance.new("TextButton")

discordAction.Name =
    "DiscordAction"

discordAction.Size =
    UDim2.new(0.5, -5, 1, 0)

discordAction.Position =
    UDim2.fromOffset(0, 0)

discordAction.BackgroundColor3 =
    CARD

discordAction.BackgroundTransparency =
    CARD_TRANSPARENCY

discordAction.BorderSizePixel = 0

discordAction.Text =
    "DISCORD  ↗"

discordAction.TextColor3 =
    TEXT

discordAction.Font =
    Enum.Font.GothamBold

discordAction.TextSize =
    10

discordAction.AutoButtonColor = false

discordAction.Parent =
    buttonRow

rounded(discordAction, 9)

local discordActionStroke =
    stroke(
        discordAction,
        BORDER,
        0.35,
        1
    )

discordAction.MouseEnter:Connect(function()

    discordAction.BackgroundColor3 =
        CARD_HOVER

    discordActionStroke.Color =
        BORDER_BRIGHT

end)

discordAction.MouseLeave:Connect(function()

    discordAction.BackgroundColor3 =
        CARD

    discordActionStroke.Color =
        BORDER

end)

discordAction.Activated:Connect(function()

    local copied =
        openLink(DISCORD_LINK)

    if copied then

        notify(
            "DISCORD LINK COPIED",
            "Discord invite copied to clipboard.",
            3
        )

    else

        notify(
            "DISCORD",
            "Opening the Discord invite.",
            3
        )

    end

end)

-- ============================================================================
-- GET KEY
-- ============================================================================

local getKeyButton =
    Instance.new("TextButton")

getKeyButton.Name =
    "GetKey"

getKeyButton.Size =
    UDim2.new(0.5, -5, 1, 0)

getKeyButton.Position =
    UDim2.new(0.5, 5, 0, 0)

getKeyButton.BackgroundColor3 =
    CARD

getKeyButton.BackgroundTransparency =
    CARD_TRANSPARENCY

getKeyButton.BorderSizePixel = 0

getKeyButton.Text =
    "GET KEY  ↗"

getKeyButton.TextColor3 =
    WHITE

getKeyButton.Font =
    Enum.Font.GothamBold

getKeyButton.TextSize =
    10

getKeyButton.AutoButtonColor = false

getKeyButton.Parent =
    buttonRow

rounded(getKeyButton, 9)

local getKeyStroke =
    stroke(
        getKeyButton,
        BORDER_BRIGHT,
        0.35,
        1
    )

getKeyButton.MouseEnter:Connect(function()

    getKeyButton.BackgroundColor3 =
        CARD_HOVER

end)

getKeyButton.MouseLeave:Connect(function()

    getKeyButton.BackgroundColor3 =
        CARD

end)

-- ============================================================================
-- LOAD BUTTON
-- ============================================================================

local runButton =
    Instance.new("TextButton")

runButton.Name =
    "LoadScript"

runButton.Size =
    UDim2.new(1, -36, 0, 49)

runButton.Position =
    UDim2.fromOffset(18, 224)

runButton.BackgroundColor3 =
    CARD

runButton.BackgroundTransparency =
    0.02

runButton.BorderSizePixel = 0

runButton.Text =
    "⚡   LOAD SCRIPT                         ›"

runButton.TextColor3 =
    WHITE

runButton.Font =
    Enum.Font.GothamBold

runButton.TextSize =
    12

runButton.AutoButtonColor = false

runButton.Parent =
    contentPanel

rounded(runButton, 9)

local loadStroke =
    stroke(
        runButton,
        BORDER_BRIGHT,
        0.4,
        1
    )

runButton.MouseEnter:Connect(function()

    runButton.BackgroundColor3 =
        CARD_HOVER

    loadStroke.Transparency =
        0.15

end)

runButton.MouseLeave:Connect(function()

    runButton.BackgroundColor3 =
        CARD

    loadStroke.Transparency =
        0.4

end)

-- ============================================================================
-- STATUS BOX
-- ============================================================================

local statusBox =
    Instance.new("Frame")

statusBox.Name =
    "StatusBox"

statusBox.Size =
    UDim2.new(1, -36, 0, 48)

statusBox.Position =
    UDim2.fromOffset(18, 283)

statusBox.BackgroundColor3 =
    PANEL_2

statusBox.BackgroundTransparency =
    0.08

statusBox.BorderSizePixel = 0

statusBox.Parent =
    contentPanel

rounded(statusBox, 9)

local statusStroke =
    stroke(
        statusBox,
        BORDER,
        0.45,
        1
    )

local infoIcon =
    Instance.new("TextLabel")

infoIcon.Size =
    UDim2.fromOffset(30, 30)

infoIcon.Position =
    UDim2.fromOffset(12, 9)

infoIcon.BackgroundTransparency = 1

infoIcon.Text =
    "ⓘ"

infoIcon.TextColor3 =
    MUTED

infoIcon.Font =
    Enum.Font.Gotham

infoIcon.TextSize =
    21

infoIcon.Parent =
    statusBox

local status =
    Instance.new("TextLabel")

status.Size =
    UDim2.new(1, -58, 1, 0)

status.Position =
    UDim2.fromOffset(50, 0)

status.BackgroundTransparency = 1

status.Text =
    "Ready. Enter your key to continue."

status.TextColor3 =
    MUTED

status.Font =
    Enum.Font.Gotham

status.TextSize =
    10

status.TextWrapped = true

status.TextXAlignment =
    Enum.TextXAlignment.Left

status.TextYAlignment =
    Enum.TextYAlignment.Center

status.Parent =
    statusBox

-- ============================================================================
-- STATUS HELPERS
-- ============================================================================

local authorizing = false

local function setStatus(titleText, messageText)

    status.Text =
        titleText .. "  •  " .. messageText

end

local function setStatusNormal(text)

    status.Text = text

    infoIcon.Text =
        "ⓘ"

    infoIcon.TextColor3 =
        MUTED

    statusStroke.Color =
        BORDER

end

local function setStatusLoading(text)

    status.Text =
        text

    infoIcon.Text =
        "◌"

    infoIcon.TextColor3 =
        WHITE

    statusStroke.Color =
        BORDER_BRIGHT

end

local function setStatusSuccess(text)

    status.Text =
        text

    infoIcon.Text =
        "✓"

    infoIcon.TextColor3 =
        SUCCESS

    statusStroke.Color =
        BORDER_BRIGHT

end

local function setStatusError(text)

    status.Text =
        text

    infoIcon.Text =
        "!"

    infoIcon.TextColor3 =
        ERROR

    statusStroke.Color =
        BORDER_BRIGHT

end

-- ============================================================================
-- GAME BUTTONS
-- ============================================================================

local buttons = {}

local function createGameButton(scriptData)

    local button =
        Instance.new("TextButton")

    button.Size =
        UDim2.new(1, 0, 0, 58)

    button.BackgroundColor3 =
        CARD

    button.BackgroundTransparency =
        CARD_TRANSPARENCY

    button.BorderSizePixel = 0

    button.Text = ""

    button.AutoButtonColor = false

    button.Parent =
        gameList

    rounded(button, 10)

    local buttonStroke =
        stroke(
            button,
            BORDER,
            0.75,
            1
        )

    local iconBackground =
        Instance.new("Frame")

    iconBackground.Size =
        UDim2.fromOffset(40, 40)

    iconBackground.Position =
        UDim2.fromOffset(9, 9)

    iconBackground.BackgroundColor3 =
        PANEL_2

    iconBackground.BackgroundTransparency =
        0.1

    iconBackground.BorderSizePixel = 0

    iconBackground.Parent =
        button

    rounded(iconBackground, 8)

    local icon =
        Instance.new("TextLabel")

    icon.Size =
        UDim2.new(1, 0, 1, 0)

    icon.BackgroundTransparency = 1

    icon.Text =
        scriptData.Short

    icon.TextColor3 =
        TEXT

    icon.Font =
        Enum.Font.GothamBold

    icon.TextSize =
        18

    icon.Parent =
        iconBackground

    local name =
        Instance.new("TextLabel")

    name.Size =
        UDim2.new(1, -82, 0, 20)

    name.Position =
        UDim2.fromOffset(62, 10)

    name.BackgroundTransparency = 1

    name.Text =
        scriptData.Name

    name.TextColor3 =
        TEXT

    name.Font =
        Enum.Font.GothamBold

    name.TextSize =
        11

    name.TextXAlignment =
        Enum.TextXAlignment.Left

    name.Parent =
        button

    local description =
        Instance.new("TextLabel")

    description.Size =
        UDim2.new(1, -82, 0, 18)

    description.Position =
        UDim2.fromOffset(62, 30)

    description.BackgroundTransparency = 1

    description.Text =
        scriptData.Description

    description.TextColor3 =
        MUTED

    description.Font =
        Enum.Font.Gotham

    description.TextSize =
        8

    description.TextXAlignment =
        Enum.TextXAlignment.Left

    description.Parent =
        button

    local arrow =
        Instance.new("TextLabel")

    arrow.Size =
        UDim2.fromOffset(25, 40)

    arrow.Position =
        UDim2.new(1, -33, 0.5, -20)

    arrow.BackgroundTransparency = 1

    arrow.Text =
        "›"

    arrow.TextColor3 =
        MUTED

    arrow.Font =
        Enum.Font.Gotham

    arrow.TextSize =
        24

    arrow.Parent =
        button

    local data = {
        Button = button,
        Stroke = buttonStroke,
        Script = scriptData
    }

    table.insert(buttons, data)

    button.MouseEnter:Connect(function()

        if selectedScript ~= scriptData then

            button.BackgroundColor3 =
                CARD_HOVER

        end

    end)

    button.MouseLeave:Connect(function()

        if selectedScript ~= scriptData then

            button.BackgroundColor3 =
                CARD

        end

    end)

    button.Activated:Connect(function()

        selectedScript =
            scriptData

        selectedLabel.Text =
            scriptData.Name

        selectedIconText.Text =
            scriptData.Short

        if scriptData.Name ==
            "Coming Soon" then

            selectedSub.Text =
                "This game is coming soon"

            setStatusNormal(
                "This game is coming soon."
            )

        else

            selectedSub.Text =
                "Enter your ZeHub access key"

            setStatusNormal(
                "Ready to load "
                    .. scriptData.Name
                    .. "."
            )

        end

        for _, item in ipairs(buttons) do

            item.Button.BackgroundColor3 =
                CARD

            item.Stroke.Color =
                BORDER

            item.Stroke.Transparency =
                0.75

        end

        button.BackgroundColor3 =
            CARD_SELECTED

        buttonStroke.Color =
            BORDER_BRIGHT

        buttonStroke.Transparency =
            0.2

    end)

    return button

end

for _, scriptData in ipairs(Scripts) do

    createGameButton(scriptData)

end

if buttons[1] then

    buttons[1].Button.BackgroundColor3 =
        CARD_SELECTED

    buttons[1].Stroke.Color =
        BORDER_BRIGHT

    buttons[1].Stroke.Transparency =
        0.2

end

-- ============================================================================
-- GET KEY
-- ============================================================================

getKeyButton.Activated:Connect(function()

    setStatusLoading(
        "Opening FlowAuth..."
    )

    local copied =
        openLink(GET_KEY_LINK)

    if copied then

        setStatusSuccess(
            "KEY LINK COPIED"
                .. "  •  Complete the FlowAuth steps."
        )

        notify(
            "KEY LINK COPIED",
            "FlowAuth key link copied to clipboard.",
            3
        )

    else

        setStatusNormal(
            "FlowAuth opened. Complete the steps and copy your key."
        )

        notify(
            "GET KEY",
            "FlowAuth key page opened.",
            3
        )

    end

end)

-- ============================================================================
-- LOAD SCRIPT / AUTHENTICATION
-- ============================================================================

runButton.Activated:Connect(function()

    if authorizing then
        return
    end

    local key =
        tostring(keyBox.Text or "")

    if key:gsub("%s+", "") == "" then

        setStatusError(
            "KEY REQUIRED  •  Enter your ZeHub key first."
        )

        notify(
            "KEY REQUIRED",
            "Enter your ZeHub key before loading.",
            3
        )

        return

    end

    if not selectedScript then

        setStatusError(
            "NO SCRIPT SELECTED"
        )

        return

    end

    if selectedScript.Name ==
        "Coming Soon" then

        setStatusError(
            "COMING SOON  •  This game is not available yet."
        )

        notify(
            "COMING SOON",
            "This script is not available yet.",
            3
        )

        return

    end

    authorizing = true

    runButton.Text =
        "◌   AUTHORIZING ZEHUB..."

    runButton.Active = false

    setStatusLoading(
        "AUTHORIZING ZEHUB  •  Checking your access key..."
    )

    notify(
        "AUTHORIZING ZEHUB",
        "Checking your access key...",
        2
    )

    task.wait(0.35)

    local ok, success, message =
        pcall(function()

            local source =
                game:HttpGet(
                    "https://flowauth.net/v1/loaders/"
                        .. selectedScript.Hash
                        .. ".lua"
                )

            local loader, loadError =
                loadstring(source)

            if not loader then

                error(
                    loadError
                        or "Failed to compile loader."
                )

            end

            return loader(key)

        end)

    if not ok then

        authorizing = false

        runButton.Active = true

        runButton.Text =
            "⚡   LOAD SCRIPT                         ›"

        setStatusError(
            "AUTHENTICATION FAILED  •  "
                .. tostring(success)
        )

        notify(
            "AUTHENTICATION FAILED",
            tostring(success),
            4
        )

        return

    end

    if success == false then

        authorizing = false

        runButton.Active = true

        runButton.Text =
            "⚡   LOAD SCRIPT                         ›"

        setStatusError(
            "INVALID KEY  •  "
                .. tostring(
                    message
                        or "Invalid or expired key."
                )
        )

        notify(
            "INVALID KEY",
            tostring(
                message
                    or "The key is invalid or expired."
            ),
            4
        )

        return

    end

    -- ========================================================================
    -- AUTHENTICATION SUCCESS
    -- ========================================================================

    setStatusSuccess(
        "ACCESS GRANTED  •  Key verified successfully."
    )

    runButton.Text =
        "✓   ACCESS GRANTED"

    notify(
        "ACCESS GRANTED",
        "Key verified. Loading "
            .. selectedScript.Name
            .. "...",
        2
    )

    task.wait(0.65)

    setStatusSuccess(
        selectedScript.Name
            .. " loaded successfully!"
    )

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

    minimized =
        not minimized

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

        minimizeButton.Text =
            "+"

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

        minimizeButton.Text =
            "—"

    end

end)

-- ============================================================================
-- DRAGGING
-- ============================================================================

local dragging = false
local dragStart
local startPosition

local function updateDrag(input)

    local delta =
        input.Position - dragStart

    frame.Position =
        UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )

end

header.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        dragging = true

        dragStart =
            input.Position

        startPosition =
            frame.Position

        input.Changed:Connect(function()

            if input.UserInputState ==
                Enum.UserInputState.End then

                dragging = false

            end

        end)

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if dragging
        and (
            input.UserInputType ==
                Enum.UserInputType.MouseMovement
            or
            input.UserInputType ==
                Enum.UserInputType.Touch
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

        notify(
            "ZEHUB READY",
            "Enter your access key to continue.",
            2.5
        )

    end

end)
