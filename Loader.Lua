-- ============================================================================
-- ZeHub • Black Glass Key System
-- ============================================================================
-- Exact-style loader based on the provided ZeHub reference.
--
-- FEATURES
-- • Black transparent / glass UI
-- • Square proportions
-- • Working game switching
-- • Rivals
-- • Runaway
-- • Coming Soon
-- • Get Key page
-- • Discord page
-- • FlowAuth integration
-- • Clipboard support
-- • Authentication overlay
-- • Invalid key / failed / success states
-- • Notifications
-- • Minimize / restore
-- • Dragging
-- • Mobile scaling
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

local DISCORD_LINK =
    "https://discord.gg/pehqQJzRm9"

local GET_KEY_LINK =
    "https://flowauth.net/reward/95257bff957772ebbe918833738a8fea"

-- ============================================================================
-- LOGO
-- ============================================================================

local LOGO_IMAGE =
    "rbxassetid://137776481151936"

-- ============================================================================
-- THEME
-- ============================================================================

local BACKGROUND = Color3.fromRGB(6, 7, 8)
local HEADER = Color3.fromRGB(9, 10, 11)

local PANEL = Color3.fromRGB(10, 11, 12)
local PANEL_2 = Color3.fromRGB(14, 15, 16)

local CARD = Color3.fromRGB(15, 16, 17)
local CARD_HOVER = Color3.fromRGB(22, 23, 24)
local CARD_SELECTED = Color3.fromRGB(26, 27, 28)

local INPUT = Color3.fromRGB(10, 11, 12)

local BORDER = Color3.fromRGB(43, 45, 47)
local BORDER_BRIGHT = Color3.fromRGB(104, 106, 109)

local WHITE = Color3.fromRGB(245, 246, 247)
local TEXT = Color3.fromRGB(218, 220, 222)
local MUTED = Color3.fromRGB(137, 140, 143)
local DARK_MUTED = Color3.fromRGB(78, 81, 84)

local SUCCESS = Color3.fromRGB(190, 215, 170)
local ERROR = Color3.fromRGB(220, 90, 95)

local ACCENT = Color3.fromRGB(232, 234, 236)

local WINDOW_TRANSPARENCY = 0.07
local PANEL_TRANSPARENCY = 0.13
local CARD_TRANSPARENCY = 0.10
local INPUT_TRANSPARENCY = 0.08

-- ============================================================================
-- SUPPORTED GAMES
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

    local widthScale = viewport.X / 900
    local heightScale = viewport.Y / 560

    scale.Scale = math.clamp(
        math.min(widthScale, heightScale),
        0.70,
        1.05
    )

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

    local corner = Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, radius or 9)

    corner.Parent = parent

    return corner

end

local function stroke(
    parent,
    color,
    transparency,
    thickness
)

    local s = Instance.new("UIStroke")

    s.Color = color or BORDER
    s.Transparency = transparency or 0.45
    s.Thickness = thickness or 1

    s.Parent = parent

    return s

end

local function tween(
    object,
    properties,
    duration
)

    local info = TweenInfo.new(
        duration or 0.2,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    )

    local animation =
        TweenService:Create(
            object,
            info,
            properties
        )

    animation:Play()

    return animation

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

    local copied =
        copyToClipboard(link)

    return opened, copied

end

-- ============================================================================
-- MAIN WINDOW
-- ============================================================================

local frame = Instance.new("Frame")

frame.Name = "Main"

frame.Size =
    UDim2.fromOffset(
        700,
        450
    )

frame.Position =
    UDim2.fromScale(
        0.5,
        0.5
    )

frame.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

frame.BackgroundColor3 =
    BACKGROUND

frame.BackgroundTransparency =
    WINDOW_TRANSPARENCY

frame.BorderSizePixel =
    0

frame.ClipsDescendants =
    true

frame.Parent =
    gui

rounded(frame, 14)

stroke(
    frame,
    BORDER_BRIGHT,
    0.48,
    1
)

-- ============================================================================
-- HEADER
-- ============================================================================

local header = Instance.new("Frame")

header.Size =
    UDim2.new(
        1,
        0,
        0,
        74
    )

header.BackgroundColor3 =
    HEADER

header.BackgroundTransparency =
    0.06

header.BorderSizePixel =
    0

header.Parent =
    frame

-- ============================================================================
-- LOGO
-- ============================================================================

local logo = Instance.new("ImageLabel")

logo.Size =
    UDim2.fromOffset(
        42,
        42
    )

logo.Position =
    UDim2.fromOffset(
        20,
        15
    )

logo.BackgroundTransparency =
    1

logo.Image =
    LOGO_IMAGE

logo.ScaleType =
    Enum.ScaleType.Fit

logo.Parent =
    header

-- ============================================================================
-- TITLE
-- ============================================================================

local title = Instance.new("TextLabel")

title.Size =
    UDim2.fromOffset(
        300,
        27
    )

title.Position =
    UDim2.fromOffset(
        70,
        13
    )

title.BackgroundTransparency =
    1

title.Text =
    "ZEHUB"

title.TextColor3 =
    WHITE

title.Font =
    Enum.Font.GothamBold

title.TextSize =
    20

title.TextXAlignment =
    Enum.TextXAlignment.Left

title.Parent =
    header

-- ============================================================================
-- SUBTITLE
-- ============================================================================

local subtitle = Instance.new("TextLabel")

subtitle.Size =
    UDim2.fromOffset(
        350,
        18
    )

subtitle.Position =
    UDim2.fromOffset(
        70,
        39
    )

subtitle.BackgroundTransparency =
    1

subtitle.Text =
    "SCRIPT LOADER  •  SECURE ACCESS"

subtitle.TextColor3 =
    MUTED

subtitle.Font =
    Enum.Font.GothamMedium

subtitle.TextSize =
    8

subtitle.TextXAlignment =
    Enum.TextXAlignment.Left

subtitle.Parent =
    header

-- ============================================================================
-- HEADER DISCORD
-- ============================================================================

local discordTop = Instance.new("TextButton")

discordTop.Size =
    UDim2.fromOffset(
        92,
        32
    )

discordTop.Position =
    UDim2.new(
        1,
        -150,
        0,
        20
    )

discordTop.BackgroundColor3 =
    PANEL_2

discordTop.BackgroundTransparency =
    0.08

discordTop.BorderSizePixel =
    0

discordTop.Text =
    "DISCORD ↗"

discordTop.TextColor3 =
    TEXT

discordTop.Font =
    Enum.Font.GothamBold

discordTop.TextSize =
    8

discordTop.AutoButtonColor =
    false

discordTop.Parent =
    header

rounded(discordTop, 7)

local discordTopStroke =
    stroke(
        discordTop,
        BORDER,
        0.35
    )

-- ============================================================================
-- MINIMIZE
-- ============================================================================

local minimizeButton =
    Instance.new("TextButton")

minimizeButton.Size =
    UDim2.fromOffset(
        25,
        32
    )

minimizeButton.Position =
    UDim2.new(
        1,
        -53,
        0,
        20
    )

minimizeButton.BackgroundTransparency =
    1

minimizeButton.Text =
    "—"

minimizeButton.TextColor3 =
    MUTED

minimizeButton.Font =
    Enum.Font.GothamBold

minimizeButton.TextSize =
    15

minimizeButton.AutoButtonColor =
    false

minimizeButton.Parent =
    header

-- ============================================================================
-- CLOSE
-- ============================================================================

local closeButton =
    Instance.new("TextButton")

closeButton.Size =
    UDim2.fromOffset(
        25,
        32
    )

closeButton.Position =
    UDim2.new(
        1,
        -25,
        0,
        20
    )

closeButton.BackgroundTransparency =
    1

closeButton.Text =
    "×"

closeButton.TextColor3 =
    MUTED

closeButton.Font =
    Enum.Font.Gotham

closeButton.TextSize =
    18

closeButton.AutoButtonColor =
    false

closeButton.Parent =
    header

closeButton.Activated:Connect(function()

    gui:Destroy()

end)

-- ============================================================================
-- HEADER LINE
-- ============================================================================

local headerLine =
    Instance.new("Frame")

headerLine.Size =
    UDim2.new(
        1,
        -32,
        0,
        1
    )

headerLine.Position =
    UDim2.new(
        0,
        16,
        1,
        -1
    )

headerLine.BackgroundColor3 =
    BORDER

headerLine.BackgroundTransparency =
    0.35

headerLine.BorderSizePixel =
    0

headerLine.Parent =
    header

-- ============================================================================
-- BODY
-- ============================================================================

local body =
    Instance.new("Frame")

body.Size =
    UDim2.new(
        1,
        -32,
        1,
        -92
    )

body.Position =
    UDim2.fromOffset(
        16,
        82
    )

body.BackgroundTransparency =
    1

body.Parent =
    frame

-- ============================================================================
-- SIDEBAR
-- ============================================================================

local sidebar =
    Instance.new("Frame")

sidebar.Size =
    UDim2.fromOffset(
        165,
        350
    )

sidebar.BackgroundColor3 =
    PANEL

sidebar.BackgroundTransparency =
    PANEL_TRANSPARENCY

sidebar.BorderSizePixel =
    0

sidebar.Parent =
    body

rounded(sidebar, 11)

stroke(
    sidebar,
    BORDER,
    0.40
)

-- ============================================================================
-- SIDEBAR TITLE
-- ============================================================================

local sidebarTitle =
    Instance.new("TextLabel")

sidebarTitle.Size =
    UDim2.new(
        1,
        -26,
        0,
        22
    )

sidebarTitle.Position =
    UDim2.fromOffset(
        13,
        15
    )

sidebarTitle.BackgroundTransparency =
    1

sidebarTitle.Text =
    "◆  SUPPORTED GAMES"

sidebarTitle.TextColor3 =
    TEXT

sidebarTitle.Font =
    Enum.Font.GothamBold

sidebarTitle.TextSize =
    8

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
    UDim2.new(
        1,
        -20,
        0,
        235
    )

gameList.Position =
    UDim2.fromOffset(
        10,
        48
    )

gameList.BackgroundTransparency =
    1

gameList.Parent =
    sidebar

local gameLayout =
    Instance.new("UIListLayout")

gameLayout.Padding =
    UDim.new(
        0,
        8
    )

gameLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

gameLayout.Parent =
    gameList

-- ============================================================================
-- SIDEBAR FOOTER
-- ============================================================================

local footerLine =
    Instance.new("Frame")

footerLine.Size =
    UDim2.new(
        1,
        -26,
        0,
        1
    )

footerLine.Position =
    UDim2.new(
        0,
        13,
        1,
        -47
    )

footerLine.BackgroundColor3 =
    BORDER

footerLine.BackgroundTransparency =
    0.45

footerLine.BorderSizePixel =
    0

footerLine.Parent =
    sidebar

local footer =
    Instance.new("TextLabel")

footer.Size =
    UDim2.new(
        1,
        -20,
        0,
        18
    )

footer.Position =
    UDim2.new(
        0,
        10,
        1,
        -36
    )

footer.BackgroundTransparency =
    1

footer.Text =
    "FAST  •  SECURE  •  RELIABLE"

footer.TextColor3 =
    DARK_MUTED

footer.Font =
    Enum.Font.GothamMedium

footer.TextSize =
    7

footer.Parent =
    sidebar

-- ============================================================================
-- CONTENT
-- ============================================================================

local content =
    Instance.new("Frame")

content.Size =
    UDim2.new(
        1,
        -177,
        350,
        0
    )

content.Position =
    UDim2.fromOffset(
        177,
        0
    )

content.BackgroundColor3 =
    PANEL

content.BackgroundTransparency =
    PANEL_TRANSPARENCY

content.BorderSizePixel =
    0

content.ClipsDescendants =
    true

content.Parent =
    body

rounded(content, 11)

stroke(
    content,
    BORDER,
    0.40
)

-- ============================================================================
-- PAGE SYSTEM
-- ============================================================================

local pages = {}

local currentPage = nil

local function createPage(name)

    local page =
        Instance.new("Frame")

    page.Name =
        name

    page.Size =
        UDim2.fromScale(
            1,
            1
        )

    page.BackgroundTransparency =
        1

    page.Visible =
        false

    page.Parent =
        content

    pages[name] =
        page

    return page

end

local gamePage =
    createPage("GamePage")

local getKeyPage =
    createPage("GetKeyPage")

local discordPage =
    createPage("DiscordPage")

local function switchPage(name)

    for pageName, page in pairs(pages) do

        page.Visible =
            pageName == name

    end

    currentPage =
        name

end

-- ============================================================================
-- GAME PAGE
-- ============================================================================

local gameIcon =
    Instance.new("Frame")

gameIcon.Size =
    UDim2.fromOffset(
        58,
        58
    )

gameIcon.Position =
    UDim2.fromOffset(
        18,
        18
    )

gameIcon.BackgroundColor3 =
    CARD

gameIcon.BackgroundTransparency =
    CARD_TRANSPARENCY

gameIcon.BorderSizePixel =
    0

gameIcon.Parent =
    gamePage

rounded(gameIcon, 9)

stroke(
    gameIcon,
    BORDER_BRIGHT,
    0.50
)

local gameIconText =
    Instance.new("TextLabel")

gameIconText.Size =
    UDim2.fromScale(
        1,
        1
    )

gameIconText.BackgroundTransparency =
    1

gameIconText.Text =
    selectedScript.Short

gameIconText.TextColor3 =
    WHITE

gameIconText.Font =
    Enum.Font.GothamBold

gameIconText.TextSize =
    25

gameIconText.Parent =
    gameIcon

local gameName =
    Instance.new("TextLabel")

gameName.Size =
    UDim2.new(
        1,
        -95,
        0,
        25
    )

gameName.Position =
    UDim2.fromOffset(
        87,
        19
    )

gameName.BackgroundTransparency =
    1

gameName.Text =
    selectedScript.Name

gameName.TextColor3 =
    WHITE

gameName.Font =
    Enum.Font.GothamBold

gameName.TextSize =
    16

gameName.TextXAlignment =
    Enum.TextXAlignment.Left

gameName.Parent =
    gamePage

local gameDescription =
    Instance.new("TextLabel")

gameDescription.Size =
    UDim2.new(
        1,
        -95,
        0,
        18
    )

gameDescription.Position =
    UDim2.fromOffset(
        87,
        42
    )

gameDescription.BackgroundTransparency =
    1

gameDescription.Text =
    "Enter your ZeHub access key"

gameDescription.TextColor3 =
    MUTED

gameDescription.Font =
    Enum.Font.Gotham

gameDescription.TextSize =
    8

gameDescription.TextXAlignment =
    Enum.TextXAlignment.Left

gameDescription.Parent =
    gamePage

local gameUnderline =
    Instance.new("Frame")

gameUnderline.Size =
    UDim2.fromOffset(
        54,
        2
    )

gameUnderline.Position =
    UDim2.fromOffset(
        87,
        64
    )

gameUnderline.BackgroundColor3 =
    ACCENT

gameUnderline.BackgroundTransparency =
    0.20

gameUnderline.BorderSizePixel =
    0

gameUnderline.Parent =
    gamePage

rounded(gameUnderline, 2)

-- ============================================================================
-- KEY BOX
-- ============================================================================

local keyBox =
    Instance.new("TextBox")

keyBox.Size =
    UDim2.new(
        1,
        -36,
        0,
        46
    )

keyBox.Position =
    UDim2.fromOffset(
        18,
        88
    )

keyBox.BackgroundColor3 =
    INPUT

keyBox.BackgroundTransparency =
    INPUT_TRANSPARENCY

keyBox.BorderSizePixel =
    0

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
    10

keyBox.ClearTextOnFocus =
    false

keyBox.TextXAlignment =
    Enum.TextXAlignment.Left

keyBox.Parent =
    gamePage

rounded(keyBox, 8)

local keyStroke =
    stroke(
        keyBox,
        BORDER,
        0.35
    )

local keyPadding =
    Instance.new("UIPadding")

keyPadding.PaddingLeft =
    UDim.new(
        0,
        14
    )

keyPadding.Parent =
    keyBox

keyBox.Focused:Connect(function()

    keyStroke.Color =
        BORDER_BRIGHT

    keyStroke.Transparency =
        0.10

end)

keyBox.FocusLost:Connect(function()

    keyStroke.Color =
        BORDER

    keyStroke.Transparency =
        0.35

end)

-- ============================================================================
-- BUTTONS
-- ============================================================================

local actionRow =
    Instance.new("Frame")

actionRow.Size =
    UDim2.new(
        1,
        -36,
        0,
        40
    )

actionRow.Position =
    UDim2.fromOffset(
        18,
        144
    )

actionRow.BackgroundTransparency =
    1

actionRow.Parent =
    gamePage

local gameDiscord =
    Instance.new("TextButton")

gameDiscord.Size =
    UDim2.new(
        0.5,
        -5,
        1,
        0
    )

gameDiscord.BackgroundColor3 =
    CARD

gameDiscord.BackgroundTransparency =
    CARD_TRANSPARENCY

gameDiscord.BorderSizePixel =
    0

gameDiscord.Text =
    "DISCORD ↗"

gameDiscord.TextColor3 =
    TEXT

gameDiscord.Font =
    Enum.Font.GothamBold

gameDiscord.TextSize =
    9

gameDiscord.AutoButtonColor =
    false

gameDiscord.Parent =
    actionRow

rounded(gameDiscord, 8)

stroke(
    gameDiscord,
    BORDER,
    0.35
)

local gameGetKey =
    Instance.new("TextButton")

gameGetKey.Size =
    UDim2.new(
        0.5,
        -5,
        1,
        0
    )

gameGetKey.Position =
    UDim2.new(
        0.5,
        5,
        0,
        0
    )

gameGetKey.BackgroundColor3 =
    ACCENT

gameGetKey.BackgroundTransparency =
    0.03

gameGetKey.BorderSizePixel =
    0

gameGetKey.Text =
    "GET KEY ↗"

gameGetKey.TextColor3 =
    Color3.fromRGB(
        10,
        10,
        11
    )

gameGetKey.Font =
    Enum.Font.GothamBold

gameGetKey.TextSize =
    9

gameGetKey.AutoButtonColor =
    false

gameGetKey.Parent =
    actionRow

rounded(gameGetKey, 8)

-- ============================================================================
-- LOAD BUTTON
-- ============================================================================

local loadButton =
    Instance.new("TextButton")

loadButton.Size =
    UDim2.new(
        1,
        -36,
        0,
        45
    )

loadButton.Position =
    UDim2.fromOffset(
        18,
        194
    )

loadButton.BackgroundColor3 =
    CARD_HOVER

loadButton.BackgroundTransparency =
    0.02

loadButton.BorderSizePixel =
    0

loadButton.Text =
    "⚡  LOAD SCRIPT                              ›"

loadButton.TextColor3 =
    WHITE

loadButton.Font =
    Enum.Font.GothamBold

loadButton.TextSize =
    10

loadButton.AutoButtonColor =
    false

loadButton.Parent =
    gamePage

rounded(loadButton, 8)

stroke(
    loadButton,
    BORDER_BRIGHT,
    0.32
)

local loadAccent =
    Instance.new("Frame")

loadAccent.Size =
    UDim2.fromOffset(
        3,
        28
    )

loadAccent.Position =
    UDim2.new(
        1,
        -8,
        0.5,
        -14
    )

loadAccent.BackgroundColor3 =
    ACCENT

loadAccent.BorderSizePixel =
    0

loadAccent.Parent =
    loadButton

rounded(loadAccent, 2)

-- ============================================================================
-- STATUS
-- ============================================================================

local statusBox =
    Instance.new("Frame")

statusBox.Size =
    UDim2.new(
        1,
        -36,
        0,
        40
    )

statusBox.Position =
    UDim2.fromOffset(
        18,
        250
    )

statusBox.BackgroundColor3 =
    PANEL_2

statusBox.BackgroundTransparency =
    0.08

statusBox.BorderSizePixel =
    0

statusBox.Parent =
    gamePage

rounded(statusBox, 8)

local statusStroke =
    stroke(
        statusBox,
        BORDER,
        0.45
    )

local statusIcon =
    Instance.new("TextLabel")

statusIcon.Size =
    UDim2.fromOffset(
        25,
        40
    )

statusIcon.Position =
    UDim2.fromOffset(
        9,
        0
    )

statusIcon.BackgroundTransparency =
    1

statusIcon.Text =
    "ⓘ"

statusIcon.TextColor3 =
    MUTED

statusIcon.Font =
    Enum.Font.Gotham

statusIcon.TextSize =
    15

statusIcon.Parent =
    statusBox

local statusText =
    Instance.new("TextLabel")

statusText.Size =
    UDim2.new(
        1,
        -45,
        1,
        0
    )

statusText.Position =
    UDim2.fromOffset(
        38,
        0
    )

statusText.BackgroundTransparency =
    1

statusText.Text =
    "Ready. Enter your key to continue."

statusText.TextColor3 =
    MUTED

statusText.Font =
    Enum.Font.Gotham

statusText.TextSize =
    8

statusText.TextXAlignment =
    Enum.TextXAlignment.Left

statusText.Parent =
    statusBox

-- ============================================================================
-- STATUS FUNCTIONS
-- ============================================================================

local function statusNormal(text)

    statusText.Text = text
    statusIcon.Text = "ⓘ"
    statusIcon.TextColor3 = MUTED

    statusStroke.Color = BORDER
    statusStroke.Transparency = 0.45

end

local function statusLoading(text)

    statusText.Text = text
    statusIcon.Text = "◌"
    statusIcon.TextColor3 = WHITE

    statusStroke.Color = BORDER_BRIGHT
    statusStroke.Transparency = 0.20

end

local function statusSuccess(text)

    statusText.Text = text
    statusIcon.Text = "✓"
    statusIcon.TextColor3 = SUCCESS

    statusStroke.Color = BORDER_BRIGHT
    statusStroke.Transparency = 0.10

end

local function statusError(text)

    statusText.Text = text
    statusIcon.Text = "!"
    statusIcon.TextColor3 = ERROR

    statusStroke.Color = ERROR
    statusStroke.Transparency = 0.20

end

-- ============================================================================
-- NOTIFICATIONS
-- ============================================================================

local notificationHolder =
    Instance.new("Frame")

notificationHolder.Size =
    UDim2.fromOffset(
        320,
        300
    )

notificationHolder.Position =
    UDim2.new(
        1,
        -335,
        0,
        15
    )

notificationHolder.BackgroundTransparency =
    1

notificationHolder.ZIndex =
    100

notificationHolder.Parent =
    gui

local notificationLayout =
    Instance.new("UIListLayout")

notificationLayout.HorizontalAlignment =
    Enum.HorizontalAlignment.Right

notificationLayout.VerticalAlignment =
    Enum.VerticalAlignment.Top

notificationLayout.Padding =
    UDim.new(
        0,
        7
    )

notificationLayout.Parent =
    notificationHolder

local function notify(
    titleText,
    messageText,
    duration
)

    local notification =
        Instance.new("Frame")

    notification.Size =
        UDim2.fromOffset(
            290,
            58
        )

    notification.BackgroundColor3 =
        PANEL

    notification.BackgroundTransparency =
        0.03

    notification.BorderSizePixel =
        0

    notification.ZIndex =
        100

    notification.Parent =
        notificationHolder

    rounded(
        notification,
        8
    )

    stroke(
        notification,
        BORDER_BRIGHT,
        0.50
    )

    local line =
        Instance.new("Frame")

    line.Size =
        UDim2.fromOffset(
            3,
            34
        )

    line.Position =
        UDim2.fromOffset(
            10,
            12
        )

    line.BackgroundColor3 =
        ACCENT

    line.BorderSizePixel =
        0

    line.ZIndex =
        101

    line.Parent =
        notification

    rounded(
        line,
        2
    )

    local notificationTitle =
        Instance.new("TextLabel")

    notificationTitle.Size =
        UDim2.new(
            1,
            -35,
            0,
            18
        )

    notificationTitle.Position =
        UDim2.fromOffset(
            21,
            8
        )

    notificationTitle.BackgroundTransparency =
        1

    notificationTitle.Text =
        titleText

    notificationTitle.TextColor3 =
        WHITE

    notificationTitle.Font =
        Enum.Font.GothamBold

    notificationTitle.TextSize =
        9

    notificationTitle.TextXAlignment =
        Enum.TextXAlignment.Left

    notificationTitle.ZIndex =
        101

    notificationTitle.Parent =
        notification

    local message =
        Instance.new("TextLabel")

    message.Size =
        UDim2.new(
            1,
            -35,
            0,
            25
        )

    message.Position =
        UDim2.fromOffset(
            21,
            27
        )

    message.BackgroundTransparency =
        1

    message.Text =
        messageText

    message.TextColor3 =
        MUTED

    message.Font =
        Enum.Font.Gotham

    message.TextSize =
        7

    message.TextWrapped =
        true

    message.TextXAlignment =
        Enum.TextXAlignment.Left

    message.ZIndex =
        101

    message.Parent =
        notification

    notification.Position =
        UDim2.new(
            1,
            25,
            0,
            0
        )

    tween(
        notification,
        {
            Position =
                UDim2.new(
                    1,
                    0,
                    0,
                    0
                )
        },
        0.20
    )

    task.delay(
        duration or 3,
        function()

            if not notification.Parent then
                return
            end

            tween(
                notification,
                {
                    Position =
                        UDim2.new(
                            1,
                            25,
                            0,
                            0
                        ),
                    BackgroundTransparency =
                        1
                },
                0.18
            )

            task.delay(
                0.22,
                function()

                    if notification.Parent then
                        notification:Destroy()
                    end

                end
            )

        end
    )

end

-- ============================================================================
-- GET KEY PAGE
-- ============================================================================

local getKeyBack =
    Instance.new("TextButton")

getKeyBack.Size =
    UDim2.fromOffset(
        80,
        25
    )

getKeyBack.Position =
    UDim2.fromOffset(
        18,
        12
    )

getKeyBack.BackgroundTransparency =
    1

getKeyBack.Text =
    "‹  GET KEY"

getKeyBack.TextColor3 =
    TEXT

getKeyBack.Font =
    Enum.Font.GothamBold

getKeyBack.TextSize =
    9

getKeyBack.TextXAlignment =
    Enum.TextXAlignment.Left

getKeyBack.Parent =
    getKeyPage

local getKeyTitle =
    Instance.new("TextLabel")

getKeyTitle.Size =
    UDim2.new(
        1,
        -36,
        0,
        28
    )

getKeyTitle.Position =
    UDim2.fromOffset(
        18,
        48
    )

getKeyTitle.BackgroundTransparency =
    1

getKeyTitle.Text =
    "Get Your ZeHub Key"

getKeyTitle.TextColor3 =
    WHITE

getKeyTitle.Font =
    Enum.Font.GothamBold

getKeyTitle.TextSize =
    15

getKeyTitle.TextXAlignment =
    Enum.TextXAlignment.Left

getKeyTitle.Parent =
    getKeyPage

local getKeySubtitle =
    Instance.new("TextLabel")

getKeySubtitle.Size =
    UDim2.new(
        1,
        -36,
        0,
        20
    )

getKeySubtitle.Position =
    UDim2.fromOffset(
        18,
        73
    )

getKeySubtitle.BackgroundTransparency =
    1

getKeySubtitle.Text =
    "Follow the steps below to get your key from FlowAuth."

getKeySubtitle.TextColor3 =
    MUTED

getKeySubtitle.Font =
    Enum.Font.Gotham

getKeySubtitle.TextSize =
    8

getKeySubtitle.TextXAlignment =
    Enum.TextXAlignment.Left

getKeySubtitle.Parent =
    getKeyPage

-- ============================================================================
-- KEY STEPS BOX
-- ============================================================================

local stepsBox =
    Instance.new("Frame")

stepsBox.Size =
    UDim2.new(
        1,
        -36,
        0,
        155
    )

stepsBox.Position =
    UDim2.fromOffset(
        18,
        101
    )

stepsBox.BackgroundColor3 =
    CARD

stepsBox.BackgroundTransparency =
    0.10

stepsBox.BorderSizePixel =
    0

stepsBox.Parent =
    getKeyPage

rounded(
    stepsBox,
    9
)

stroke(
    stepsBox,
    BORDER,
    0.45
)

local steps = {

    {
        "1",
        "Open the key page",
        "Click the button below to open FlowAuth."
    },

    {
        "2",
        "Complete the required steps",
        "Finish the verification process."
    },

    {
        "3",
        "Copy your generated key",
        "You will receive your key after completion."
    },

    {
        "4",
        "Paste it into the key box",
        "Return to the loader and enter your key."
    }

}

for i, step in ipairs(steps) do

    local y =
        11 + ((i - 1) * 35)

    local number =
        Instance.new("Frame")

    number.Size =
        UDim2.fromOffset(
            22,
            22
        )

    number.Position =
        UDim2.fromOffset(
            11,
            y
        )

    number.BackgroundColor3 =
        PANEL_2

    number.BorderSizePixel =
        0

    number.Parent =
        stepsBox

    rounded(
        number,
        11
    )

    stroke(
        number,
        BORDER_BRIGHT,
        0.55
    )

    local numberText =
        Instance.new("TextLabel")

    numberText.Size =
        UDim2.fromScale(
            1,
            1
        )

    numberText.BackgroundTransparency =
        1

    numberText.Text =
        step[1]

    numberText.TextColor3 =
        TEXT

    numberText.Font =
        Enum.Font.GothamBold

    numberText.TextSize =
        8

    numberText.Parent =
        number

    local stepTitle =
        Instance.new("TextLabel")

    stepTitle.Size =
        UDim2.new(
            1,
            -50,
            0,
            17
        )

    stepTitle.Position =
        UDim2.fromOffset(
            42,
            y - 1
        )

    stepTitle.BackgroundTransparency =
        1

    stepTitle.Text =
        step[2]

    stepTitle.TextColor3 =
        TEXT

    stepTitle.Font =
        Enum.Font.GothamBold

    stepTitle.TextSize =
        8

    stepTitle.TextXAlignment =
        Enum.TextXAlignment.Left

    stepTitle.Parent =
        stepsBox

    local stepDescription =
        Instance.new("TextLabel")

    stepDescription.Size =
        UDim2.new(
            1,
            -50,
            0,
            15
        )

    stepDescription.Position =
        UDim2.fromOffset(
            42,
            y + 13
        )

    stepDescription.BackgroundTransparency =
        1

    stepDescription.Text =
        step[3]

    stepDescription.TextColor3 =
        MUTED

    stepDescription.Font =
        Enum.Font.Gotham

    stepDescription.TextSize =
        7

    stepDescription.TextXAlignment =
        Enum.TextXAlignment.Left

    stepDescription.Parent =
        stepsBox

end

-- ============================================================================
-- KEY URL
-- ============================================================================

local keyLinkBox =
    Instance.new("TextBox")

keyLinkBox.Size =
    UDim2.new(
        1,
        -36,
        0,
        34
    )

keyLinkBox.Position =
    UDim2.fromOffset(
        18,
        267
    )

keyLinkBox.BackgroundColor3 =
    INPUT

keyLinkBox.BackgroundTransparency =
    0.08

keyLinkBox.BorderSizePixel =
    0

keyLinkBox.Text =
    GET_KEY_LINK

keyLinkBox.TextColor3 =
    MUTED

keyLinkBox.Font =
    Enum.Font.Gotham

keyLinkBox.TextSize =
    7

keyLinkBox.TextXAlignment =
    Enum.TextXAlignment.Left

keyLinkBox.ClearTextOnFocus =
    false

keyLinkBox.Parent =
    getKeyPage

rounded(
    keyLinkBox,
    7
)

stroke(
    keyLinkBox,
    BORDER,
    0.45
)

local keyLinkPadding =
    Instance.new("UIPadding")

keyLinkPadding.PaddingLeft =
    UDim.new(
        0,
        12
    )

keyLinkPadding.Parent =
    keyLinkBox

-- ============================================================================
-- GET KEY ACTIONS
-- ============================================================================

local openKey =
    Instance.new("TextButton")

openKey.Size =
    UDim2.new(
        0.5,
        -21,
        0,
        35
    )

openKey.Position =
    UDim2.fromOffset(
        18,
        309
    )

openKey.BackgroundColor3 =
    CARD_HOVER

openKey.BorderSizePixel =
    0

openKey.Text =
    "OPEN KEY PAGE ↗"

openKey.TextColor3 =
    WHITE

openKey.Font =
    Enum.Font.GothamBold

openKey.TextSize =
    8

openKey.AutoButtonColor =
    false

openKey.Parent =
    getKeyPage

rounded(
    openKey,
    7
)

stroke(
    openKey,
    BORDER_BRIGHT,
    0.40
)

local copyKey =
    Instance.new("TextButton")

copyKey.Size =
    UDim2.new(
        0.5,
        -21,
        0,
        35
    )

copyKey.Position =
    UDim2.new(
        0.5,
        3,
        0,
        309
    )

copyKey.BackgroundColor3 =
    CARD

copyKey.BorderSizePixel =
    0

copyKey.Text =
    "COPY LINK"

copyKey.TextColor3 =
    TEXT

copyKey.Font =
    Enum.Font.GothamBold

copyKey.TextSize =
    8

copyKey.AutoButtonColor =
    false

copyKey.Parent =
    getKeyPage

rounded(
    copyKey,
    7
)

stroke(
    copyKey,
    BORDER,
    0.35
)

-- ============================================================================
-- DISCORD PAGE
-- ============================================================================

local discordBack =
    Instance.new("TextButton")

discordBack.Size =
    UDim2.fromOffset(
        85,
        25
    )

discordBack.Position =
    UDim2.fromOffset(
        18,
        12
    )

discordBack.BackgroundTransparency =
    1

discordBack.Text =
    "‹  DISCORD"

discordBack.TextColor3 =
    TEXT

discordBack.Font =
    Enum.Font.GothamBold

discordBack.TextSize =
    9

discordBack.TextXAlignment =
    Enum.TextXAlignment.Left

discordBack.Parent =
    discordPage

local discordIcon =
    Instance.new("Frame")

discordIcon.Size =
    UDim2.fromOffset(
        58,
        58
    )

discordIcon.Position =
    UDim2.fromOffset(
        18,
        48
    )

discordIcon.BackgroundColor3 =
    CARD

discordIcon.BorderSizePixel =
    0

discordIcon.Parent =
    discordPage

rounded(
    discordIcon,
    9
)

stroke(
    discordIcon,
    BORDER_BRIGHT,
    0.50
)

local discordIconText =
    Instance.new("TextLabel")

discordIconText.Size =
    UDim2.fromScale(
        1,
        1
    )

discordIconText.BackgroundTransparency =
    1

discordIconText.Text =
    "◉"

discordIconText.TextColor3 =
    WHITE

discordIconText.Font =
    Enum.Font.GothamBold

discordIconText.TextSize =
    28

discordIconText.Parent =
    discordIcon

local discordTitle =
    Instance.new("TextLabel")

discordTitle.Size =
    UDim2.new(
        1,
        -95,
        0,
        25
    )

discordTitle.Position =
    UDim2.fromOffset(
        87,
        49
    )

discordTitle.BackgroundTransparency =
    1

discordTitle.Text =
    "ZEHUB DISCORD"

discordTitle.TextColor3 =
    WHITE

discordTitle.Font =
    Enum.Font.GothamBold

discordTitle.TextSize =
    15

discordTitle.TextXAlignment =
    Enum.TextXAlignment.Left

discordTitle.Parent =
    discordPage

local discordSubtitle =
    Instance.new("TextLabel")

discordSubtitle.Size =
    UDim2.new(
        1,
        -95,
        0,
        30
    )

discordSubtitle.Position =
    UDim2.fromOffset(
        87,
        75
    )

discordSubtitle.BackgroundTransparency =
    1

discordSubtitle.Text =
    "Join our Discord for updates, support, new scripts\nand key assistance."

discordSubtitle.TextColor3 =
    MUTED

discordSubtitle.Font =
    Enum.Font.Gotham

discordSubtitle.TextSize =
    8

discordSubtitle.TextWrapped =
    true

discordSubtitle.TextXAlignment =
    Enum.TextXAlignment.Left

discordSubtitle.Parent =
    discordPage

-- ============================================================================
-- DISCORD FEATURES
-- ============================================================================

local discordFeatures =
    Instance.new("Frame")

discordFeatures.Size =
    UDim2.new(
        1,
        -36,
        0,
        104
    )

discordFeatures.Position =
    UDim2.fromOffset(
        18,
        112
    )

discordFeatures.BackgroundColor3 =
    CARD

discordFeatures.BackgroundTransparency =
    0.10

discordFeatures.BorderSizePixel =
    0

discordFeatures.Parent =
    discordPage

rounded(
    discordFeatures,
    9
)

stroke(
    discordFeatures,
    BORDER,
    0.45
)

local featureList = {

    "Latest updates",
    "Support & help",
    "New scripts",
    "Key assistance"

}

for i, textValue in ipairs(featureList) do

    local item =
        Instance.new("TextLabel")

    item.Size =
        UDim2.new(
            1,
            -30,
            0,
            19
        )

    item.Position =
        UDim2.fromOffset(
            15,
            8 + ((i - 1) * 22)
        )

    item.BackgroundTransparency =
        1

    item.Text =
        "●   " .. textValue

    item.TextColor3 =
        TEXT

    item.Font =
        Enum.Font.Gotham

    item.TextSize =
        8

    item.TextXAlignment =
        Enum.TextXAlignment.Left

    item.Parent =
        discordFeatures

end

-- ============================================================================
-- DISCORD LINK
-- ============================================================================

local discordLinkBox =
    Instance.new("TextBox")

discordLinkBox.Size =
    UDim2.new(
        1,
        -36,
        0,
        34
    )

discordLinkBox.Position =
    UDim2.fromOffset(
        18,
        228
    )

discordLinkBox.BackgroundColor3 =
    INPUT

discordLinkBox.BackgroundTransparency =
    0.08

discordLinkBox.BorderSizePixel =
    0

discordLinkBox.Text =
    DISCORD_LINK

discordLinkBox.TextColor3 =
    MUTED

discordLinkBox.Font =
    Enum.Font.Gotham

discordLinkBox.TextSize =
    8

discordLinkBox.TextXAlignment =
    Enum.TextXAlignment.Left

discordLinkBox.ClearTextOnFocus =
    false

discordLinkBox.Parent =
    discordPage

rounded(
    discordLinkBox,
    7
)

stroke(
    discordLinkBox,
    BORDER,
    0.45
)

local discordLinkPadding =
    Instance.new("UIPadding")

discordLinkPadding.PaddingLeft =
    UDim.new(
        0,
        12
    )

discordLinkPadding.Parent =
    discordLinkBox

-- ============================================================================
-- DISCORD BUTTONS
-- ============================================================================

local joinDiscord =
    Instance.new("TextButton")

joinDiscord.Size =
    UDim2.new(
        0.5,
        -21,
        0,
        35
    )

joinDiscord.Position =
    UDim2.fromOffset(
        18,
        270
    )

joinDiscord.BackgroundColor3 =
    CARD_HOVER

joinDiscord.BorderSizePixel =
    0

joinDiscord.Text =
    "JOIN DISCORD ↗"

joinDiscord.TextColor3 =
    WHITE

joinDiscord.Font =
    Enum.Font.GothamBold

joinDiscord.TextSize =
    8

joinDiscord.AutoButtonColor =
    false

joinDiscord.Parent =
    discordPage

rounded(
    joinDiscord,
    7
)

stroke(
    joinDiscord,
    BORDER_BRIGHT,
    0.40
)

local copyDiscord =
    Instance.new("TextButton")

copyDiscord.Size =
    UDim2.new(
        0.5,
        -21,
        0,
        35
    )

copyDiscord.Position =
    UDim2.new(
        0.5,
        3,
        0,
        270
    )

copyDiscord.BackgroundColor3 =
    CARD

copyDiscord.BorderSizePixel =
    0

copyDiscord.Text =
    "COPY INVITE"

copyDiscord.TextColor3 =
    TEXT

copyDiscord.Font =
    Enum.Font.GothamBold

copyDiscord.TextSize =
    8

copyDiscord.AutoButtonColor =
    false

copyDiscord.Parent =
    discordPage

rounded(
    copyDiscord,
    7
)

stroke(
    copyDiscord,
    BORDER,
    0.35
)

-- ============================================================================
-- GAME BUTTONS
-- ============================================================================

local gameButtons = {}

local function updateGameSelection()

    for _, data in ipairs(gameButtons) do

        if data.Script == selectedScript then

            data.Button.BackgroundColor3 =
                CARD_SELECTED

            data.Stroke.Color =
                BORDER_BRIGHT

            data.Stroke.Transparency =
                0.15

        else

            data.Button.BackgroundColor3 =
                CARD

            data.Stroke.Color =
                BORDER

            data.Stroke.Transparency =
                0.72

        end

    end

end

-- ============================================================================
-- ACTUAL GAME SWITCH
-- ============================================================================

local function switchGame(scriptData)

    if not scriptData then
        return
    end

    selectedScript =
        scriptData

    gameName.Text =
        scriptData.Name

    gameIconText.Text =
        scriptData.Short

    if scriptData.Name ==
        "Coming Soon" then

        gameDescription.Text =
            "This game is coming soon."

        statusNormal(
            "This game is coming soon."
        )

    else

        gameDescription.Text =
            "Enter your ZeHub access key"

        statusNormal(
            "Ready. Enter your "
                .. scriptData.Name
                .. " key."
        )

    end

    -- Clear old key when changing game.
    keyBox.Text = ""

    -- Always return to game page.
    switchPage("GamePage")

    updateGameSelection()

end

local function createGameButton(scriptData)

    local button =
        Instance.new("TextButton")

    button.Size =
        UDim2.new(
            1,
            0,
            0,
            53
        )

    button.BackgroundColor3 =
        CARD

    button.BackgroundTransparency =
        CARD_TRANSPARENCY

    button.BorderSizePixel =
        0

    button.Text =
        ""

    button.AutoButtonColor =
        false

    button.Parent =
        gameList

    rounded(
        button,
        8
    )

    local buttonStroke =
        stroke(
            button,
            BORDER,
            0.72
        )

    local icon =
        Instance.new("Frame")

    icon.Size =
        UDim2.fromOffset(
            35,
            35
        )

    icon.Position =
        UDim2.fromOffset(
            8,
            9
        )

    icon.BackgroundColor3 =
        INPUT

    icon.BorderSizePixel =
        0

    icon.Parent =
        button

    rounded(
        icon,
        7
    )

    stroke(
        icon,
        BORDER_BRIGHT,
        0.65
    )

    local iconText =
        Instance.new("TextLabel")

    iconText.Size =
        UDim2.fromScale(
            1,
            1
        )

    iconText.BackgroundTransparency =
        1

    iconText.Text =
        scriptData.Short

    iconText.TextColor3 =
        TEXT

    iconText.Font =
        Enum.Font.GothamBold

    iconText.TextSize =
        16

    iconText.Parent =
        icon

    local name =
        Instance.new("TextLabel")

    name.Size =
        UDim2.new(
            1,
            -70,
            0,
            17
        )

    name.Position =
        UDim2.fromOffset(
            53,
            8
        )

    name.BackgroundTransparency =
        1

    name.Text =
        scriptData.Name

    name.TextColor3 =
        TEXT

    name.Font =
        Enum.Font.GothamBold

    name.TextSize =
        8

    name.TextXAlignment =
        Enum.TextXAlignment.Left

    name.Parent =
        button

    local description =
        Instance.new("TextLabel")

    description.Size =
        UDim2.new(
            1,
            -70,
            0,
            14
        )

    description.Position =
        UDim2.fromOffset(
            53,
            25
        )

    description.BackgroundTransparency =
        1

    description.Text =
        scriptData.Description

    description.TextColor3 =
        MUTED

    description.Font =
        Enum.Font.Gotham

    description.TextSize =
        6

    description.TextXAlignment =
        Enum.TextXAlignment.Left

    description.Parent =
        button

    local arrow =
        Instance.new("TextLabel")

    arrow.Size =
        UDim2.fromOffset(
            18,
            30
        )

    arrow.Position =
        UDim2.new(
            1,
            -24,
            0.5,
            -15
        )

    arrow.BackgroundTransparency =
        1

    arrow.Text =
        "›"

    arrow.TextColor3 =
        MUTED

    arrow.Font =
        Enum.Font.Gotham

    arrow.TextSize =
        18

    arrow.Parent =
        button

    local data = {
        Button = button,
        Stroke = buttonStroke,
        Script = scriptData
    }

    table.insert(
        gameButtons,
        data
    )

    -- IMPORTANT:
    -- Activated works on normal Roblox buttons, but we also explicitly
    -- handle InputBegan so the game switch works reliably on touch/mobile.

    button.Activated:Connect(function()

        switchGame(
            scriptData
        )

    end)

    button.InputBegan:Connect(function(input)

        if input.UserInputType ==
            Enum.UserInputType.Touch
            or input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            switchGame(
                scriptData
            )

        end

    end)

    button.MouseEnter:Connect(function()

        if selectedScript ~= scriptData then

            tween(
                button,
                {
                    BackgroundColor3 =
                        CARD_HOVER
                },
                0.12
            )

        end

    end)

    button.MouseLeave:Connect(function()

        if selectedScript ~= scriptData then

            tween(
                button,
                {
                    BackgroundColor3 =
                        CARD
                },
                0.12
            )

        end

    end)

    return button

end

for _, scriptData in ipairs(Scripts) do

    createGameButton(
        scriptData
    )

end

updateGameSelection()

-- ============================================================================
-- PAGE NAVIGATION
-- ============================================================================

getKeyBack.Activated:Connect(function()

    switchPage(
        "GamePage"
    )

end)

discordBack.Activated:Connect(function()

    switchPage(
        "GamePage"
    )

end)

gameGetKey.Activated:Connect(function()

    switchPage(
        "GetKeyPage"
    )

end)

gameDiscord.Activated:Connect(function()

    switchPage(
        "DiscordPage"
    )

end)

discordTop.Activated:Connect(function()

    switchPage(
        "DiscordPage"
    )

end)

-- ============================================================================
-- GET KEY
-- ============================================================================

openKey.Activated:Connect(function()

    statusLoading(
        "Opening FlowAuth..."
    )

    local opened, copied =
        openLink(
            GET_KEY_LINK
        )

    if opened or copied then

        notify(
            "KEY PAGE OPENED",
            "Complete the FlowAuth steps and return here.",
            3
        )

        statusSuccess(
            "FlowAuth opened. Complete the steps and return here."
        )

    else

        statusError(
            "Unable to open FlowAuth."
        )

        notify(
            "FLOWAUTH ERROR",
            "Unable to open the key page.",
            3
        )

    end

end)

copyKey.Activated:Connect(function()

    if copyToClipboard(
        GET_KEY_LINK
    ) then

        notify(
            "KEY LINK COPIED",
            "The FlowAuth link was copied to your clipboard.",
            3
        )

    else

        notify(
            "COPY FAILED",
            "Clipboard is not supported.",
            3
        )

    end

end)

-- ============================================================================
-- DISCORD
-- ============================================================================

joinDiscord.Activated:Connect(function()

    local opened, copied =
        openLink(
            DISCORD_LINK
        )

    if copied then

        notify(
            "DISCORD LINK COPIED",
            "The Discord invite was copied.",
            3
        )

    elseif opened then

        notify(
            "DISCORD OPENED",
            "The ZeHub Discord invite was opened.",
            3
        )

    else

        notify(
            "DISCORD ERROR",
            "Unable to open the Discord invite.",
            3
        )

    end

end)

copyDiscord.Activated:Connect(function()

    if copyToClipboard(
        DISCORD_LINK
    ) then

        notify(
            "DISCORD LINK COPIED",
            "The Discord invite was copied.",
            3
        )

    else

        notify(
            "COPY FAILED",
            "Clipboard is not supported.",
            3
        )

    end

end)

-- ============================================================================
-- HEADER DISCORD HOVER
-- ============================================================================

discordTop.MouseEnter:Connect(function()

    tween(
        discordTop,
        {
            BackgroundColor3 =
                CARD_HOVER
        },
        0.12
    )

    discordTopStroke.Color =
        BORDER_BRIGHT

end)

discordTop.MouseLeave:Connect(function()

    tween(
        discordTop,
        {
            BackgroundColor3 =
                PANEL_2
        },
        0.12
    )

    discordTopStroke.Color =
        BORDER

end)

-- ============================================================================
-- AUTHORIZATION OVERLAY
-- ============================================================================

local authOverlay =
    Instance.new("Frame")

authOverlay.Size =
    UDim2.fromScale(
        1,
        1
    )

authOverlay.BackgroundColor3 =
    BACKGROUND

authOverlay.BackgroundTransparency =
    0.14

authOverlay.BorderSizePixel =
    0

authOverlay.Visible =
    false

authOverlay.ZIndex =
    50

authOverlay.Parent =
    frame

local authCard =
    Instance.new("Frame")

authCard.Size =
    UDim2.fromOffset(
        350,
        235
    )

authCard.Position =
    UDim2.fromScale(
        0.5,
        0.5
    )

authCard.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

authCard.BackgroundColor3 =
    PANEL

authCard.BackgroundTransparency =
    0.02

authCard.BorderSizePixel =
    0

authCard.ZIndex =
    51

authCard.Parent =
    authOverlay

rounded(
    authCard,
    11
)

stroke(
    authCard,
    BORDER_BRIGHT,
    0.40
)

-- ============================================================================
-- AUTH ICON
-- ============================================================================

local authIcon =
    Instance.new("TextLabel")

authIcon.Size =
    UDim2.fromOffset(
        50,
        50
    )

authIcon.Position =
    UDim2.new(
        0.5,
        -25,
        0,
        25
    )

authIcon.BackgroundColor3 =
    CARD

authIcon.BackgroundTransparency =
    0.03

authIcon.BorderSizePixel =
    0

authIcon.Text =
    "◌"

authIcon.TextColor3 =
    WHITE

authIcon.Font =
    Enum.Font.GothamBold

authIcon.TextSize =
    24

authIcon.ZIndex =
    52

authIcon.Parent =
    authCard

rounded(
    authIcon,
    25
)

stroke(
    authIcon,
    BORDER_BRIGHT,
    0.35
)

local authTitle =
    Instance.new("TextLabel")

authTitle.Size =
    UDim2.new(
        1,
        -30,
        0,
        25
    )

authTitle.Position =
    UDim2.fromOffset(
        15,
        82
    )

authTitle.BackgroundTransparency =
    1

authTitle.Text =
    "AUTHORIZING ZEHUB"

authTitle.TextColor3 =
    WHITE

authTitle.Font =
    Enum.Font.GothamBold

authTitle.TextSize =
    13

authTitle.TextXAlignment =
    Enum.TextXAlignment.Center

authTitle.ZIndex =
    52

authTitle.Parent =
    authCard

local authSubtitle =
    Instance.new("TextLabel")

authSubtitle.Size =
    UDim2.new(
        1,
        -30,
        0,
        20
    )

authSubtitle.Position =
    UDim2.fromOffset(
        15,
        108
    )

authSubtitle.BackgroundTransparency =
    1

authSubtitle.Text =
    "Checking your access key..."

authSubtitle.TextColor3 =
    MUTED

authSubtitle.Font =
    Enum.Font.Gotham

authSubtitle.TextSize =
    8

authSubtitle.TextXAlignment =
    Enum.TextXAlignment.Center

authSubtitle.ZIndex =
    52

authSubtitle.Parent =
    authCard

-- ============================================================================
-- AUTH PROGRESS
-- ============================================================================

local progressBack =
    Instance.new("Frame")

progressBack.Size =
    UDim2.new(
        1,
        -50,
        0,
        3
    )

progressBack.Position =
    UDim2.fromOffset(
        25,
        145
    )

progressBack.BackgroundColor3 =
    BORDER

progressBack.BackgroundTransparency =
    0.30

progressBack.BorderSizePixel =
    0

progressBack.ZIndex =
    52

progressBack.Parent =
    authCard

rounded(
    progressBack,
    2
)

local progress =
    Instance.new("Frame")

progress.Size =
    UDim2.new(
        0,
        0,
        1,
        0
    )

progress.BackgroundColor3 =
    WHITE

progress.BorderSizePixel =
    0

progress.ZIndex =
    53

progress.Parent =
    progressBack

rounded(
    progress,
    2
)

local authStatus =
    Instance.new("TextLabel")

authStatus.Size =
    UDim2.new(
        1,
        -30,
        0,
        25
    )

authStatus.Position =
    UDim2.fromOffset(
        15,
        163
    )

authStatus.BackgroundTransparency =
    1

authStatus.Text =
    "Verifying authentication..."

authStatus.TextColor3 =
    MUTED

authStatus.Font =
    Enum.Font.Gotham

authStatus.TextSize =
    8

authStatus.TextXAlignment =
    Enum.TextXAlignment.Center

authStatus.ZIndex =
    52

authStatus.Parent =
    authCard

-- ============================================================================
-- AUTH OVERLAY FUNCTIONS
-- ============================================================================

local function showAuth()

    authOverlay.Visible =
        true

    authOverlay.BackgroundTransparency =
        1

    authCard.Position =
        UDim2.fromScale(
            0.5,
            0.53
        )

    progress.Size =
        UDim2.new(
            0,
            0,
            1,
            0
        )

    tween(
        authOverlay,
        {
            BackgroundTransparency =
                0.14
        },
        0.18
    )

    tween(
        authCard,
        {
            Position =
                UDim2.fromScale(
                    0.5,
                    0.5
                )
        },
        0.22
    )

end

local function hideAuth()

    authOverlay.Visible =
        false

end

local function authProgress(percent)

    tween(
        progress,
        {
            Size =
                UDim2.new(
                    percent,
                    0,
                    1,
                    0
                )
        },
        0.25
    )

end

-- ============================================================================
-- LOAD SCRIPT
-- ============================================================================

local authorizing = false

loadButton.Activated:Connect(function()

    if authorizing then
        return
    end

    local key =
        tostring(
            keyBox.Text or ""
        )

    key =
        key:gsub(
            "^%s+",
            ""
        )

    key =
        key:gsub(
            "%s+$",
            ""
        )

    if key == "" then

        statusError(
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
        return
    end

    if selectedScript.Name ==
        "Coming Soon" then

        statusError(
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

    loadButton.Active = false

    loadButton.Text =
        "◌  AUTHORIZING ZEHUB..."

    statusLoading(
        "AUTHORIZING ZEHUB  •  Checking your access key..."
    )

    showAuth()

    authIcon.Text =
        "◌"

    authIcon.TextColor3 =
        WHITE

    authTitle.Text =
        "AUTHORIZING ZEHUB"

    authSubtitle.Text =
        "Checking your access key..."

    authStatus.Text =
        "Verifying authentication..."

    authProgress(0.20)

    task.wait(0.30)

    authProgress(0.48)

    authSubtitle.Text =
        "Validating with FlowAuth..."

    statusLoading(
        "AUTHORIZING ZEHUB  •  Validating your access key..."
    )

    -- ========================================================================
    -- FLOWAUTH
    -- ========================================================================

    local ok, success, message =
        pcall(function()

            local source =
                game:HttpGet(
                    "https://flowauth.net/v1/loaders/"
                        .. selectedScript.Hash
                        .. ".lua"
                )

            local loader, loadError =
                loadstring(
                    source
                )

            if not loader then

                error(
                    loadError
                        or "Failed to compile loader."
                )

            end

            return loader(
                key
            )

        end)

    -- ========================================================================
    -- REQUEST ERROR
    -- ========================================================================

    if not ok then

        authorizing = false

        loadButton.Active = true

        loadButton.Text =
            "⚡  LOAD SCRIPT                              ›"

        authProgress(1)

        authIcon.Text =
            "!"

        authIcon.TextColor3 =
            ERROR

        authTitle.Text =
            "AUTHENTICATION FAILED"

        authSubtitle.Text =
            "Unable to authenticate the loader."

        authStatus.Text =
            "Loader error. Please try again."

        statusError(
            "AUTHENTICATION FAILED  •  "
                .. tostring(success)
        )

        notify(
            "AUTHENTICATION FAILED",
            tostring(success),
            4
        )

        task.delay(
            1.0,
            hideAuth
        )

        return

    end

    -- ========================================================================
    -- INVALID KEY
    -- ========================================================================

    if success == false then

        authorizing = false

        loadButton.Active = true

        loadButton.Text =
            "⚡  LOAD SCRIPT                              ›"

        authProgress(1)

        authIcon.Text =
            "!"

        authIcon.TextColor3 =
            ERROR

        authTitle.Text =
            "INVALID KEY"

        authSubtitle.Text =
            tostring(
                message
                    or "The key is invalid or expired."
            )

        authStatus.Text =
            "Please get a new key and try again."

        statusError(
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

        task.delay(
            1.0,
            hideAuth
        )

        return

    end

    -- ========================================================================
    -- SUCCESS
    -- ========================================================================

    authProgress(0.78)

    authIcon.Text =
        "✓"

    authIcon.TextColor3 =
        SUCCESS

    authTitle.Text =
        "KEY VERIFIED"

    authSubtitle.Text =
        "Authentication successful."

    authStatus.Text =
        "Loading "
            .. selectedScript.Name
            .. "..."

    statusSuccess(
        "KEY VERIFIED  •  Loading "
            .. selectedScript.Name
            .. "..."
    )

    loadButton.Text =
        "✓  KEY VERIFIED"

    notify(
        "KEY VERIFIED",
        "Loading "
            .. selectedScript.Name
            .. "...",
        2
    )

    task.wait(0.55)

    authProgress(1)

    authTitle.Text =
        "LOADED"

    authSubtitle.Text =
        selectedScript.Name
            .. " loaded successfully."

    authStatus.Text =
        "ZeHub authorization completed."

    statusSuccess(
        selectedScript.Name
            .. " loaded successfully."
    )

    task.wait(0.55)

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

        body.Visible =
            false

        headerLine.Visible =
            false

        frame:TweenSize(
            UDim2.fromOffset(
                700,
                74
            ),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quint,
            0.25,
            true
        )

        minimizeButton.Text =
            "+"

    else

        body.Visible =
            true

        headerLine.Visible =
            true

        frame:TweenSize(
            UDim2.fromOffset(
                700,
                450
            ),
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
        input.Position
        - dragStart

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

    if not dragging then
        return
    end

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        updateDrag(input)

    end

end)

-- ============================================================================
-- INITIAL PAGE
-- ============================================================================

switchPage(
    "GamePage"
)

switchGame(
    Scripts[1]
)

-- ============================================================================
-- READY
-- ============================================================================

task.defer(function()

    task.wait(0.25)

    if gui and gui.Parent then

        statusNormal(
            "Ready. Enter your access key to continue."
        )

        notify(
            "ZEHUB READY",
            "Enter your access key to continue.",
            2.5
        )

    end

end)
