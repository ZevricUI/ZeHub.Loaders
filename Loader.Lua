-- ============================================================================
-- ZeHub • Secure Access Loader
-- ============================================================================
-- Black Glass UI matching the ZeHub reference design.
--
-- FEATURES
-- • ZeHub black / transparent glass design
-- • Supported games sidebar
-- • Rivals / Runaway / Coming Soon
-- • Get Key page
-- • Discord page
-- • FlowAuth integration
-- • Automatic clipboard copying
-- • Key authorization screen
-- • Key verified screen
-- • Invalid key screen
-- • Authentication error screen
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
-- FLOWAUTH LOADERS
-- ============================================================================

local FLOWAUTH_LOADER =
    "https://flowauth.net/v1/loaders/"

-- ============================================================================
-- THEME
-- ============================================================================

local BACKGROUND =
    Color3.fromRGB(5, 7, 9)

local WINDOW =
    Color3.fromRGB(8, 10, 12)

local HEADER =
    Color3.fromRGB(7, 9, 11)

local SIDEBAR =
    Color3.fromRGB(6, 8, 10)

local PANEL =
    Color3.fromRGB(8, 10, 12)

local PANEL_2 =
    Color3.fromRGB(11, 13, 15)

local CARD =
    Color3.fromRGB(13, 16, 19)

local CARD_HOVER =
    Color3.fromRGB(19, 22, 25)

local CARD_SELECTED =
    Color3.fromRGB(23, 26, 30)

local INPUT =
    Color3.fromRGB(8, 10, 12)

local WHITE =
    Color3.fromRGB(245, 247, 249)

local TEXT =
    Color3.fromRGB(221, 225, 229)

local MUTED =
    Color3.fromRGB(132, 139, 146)

local DARK_MUTED =
    Color3.fromRGB(76, 83, 90)

local BORDER =
    Color3.fromRGB(43, 48, 54)

local BORDER_LIGHT =
    Color3.fromRGB(72, 78, 85)

local SUCCESS =
    Color3.fromRGB(191, 218, 156)

local ERROR =
    Color3.fromRGB(235, 92, 103)

local ACCENT =
    Color3.fromRGB(224, 228, 232)

local ACCENT_DARK =
    Color3.fromRGB(30, 34, 38)

-- ============================================================================
-- TRANSPARENCY
-- ============================================================================

local WINDOW_TRANSPARENCY = 0.08
local PANEL_TRANSPARENCY = 0.10
local CARD_TRANSPARENCY = 0.08
local INPUT_TRANSPARENCY = 0.06

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

local old =
    playerGui:FindFirstChild("ZeHub Key System")

if old then
    old:Destroy()
end

-- ============================================================================
-- SCREEN GUI
-- ============================================================================

local gui =
    Instance.new("ScreenGui")

gui.Name =
    "ZeHub Key System"

gui.ResetOnSpawn =
    false

gui.IgnoreGuiInset =
    true

gui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

gui.Parent =
    playerGui

-- ============================================================================
-- SCALE
-- ============================================================================

local scale =
    Instance.new("UIScale")

scale.Scale =
    1

scale.Parent =
    gui

local function updateScale()

    local camera =
        workspace.CurrentCamera

    if not camera then
        return
    end

    local viewport =
        camera.ViewportSize

    local widthScale =
        viewport.X / 820

    local heightScale =
        viewport.Y / 540

    local finalScale =
        math.min(
            widthScale,
            heightScale
        )

    scale.Scale =
        math.clamp(
            finalScale,
            0.68,
            1.08
        )

end

updateScale()

if workspace.CurrentCamera then

    workspace.CurrentCamera:
        GetPropertyChangedSignal(
            "ViewportSize"
        ):
        Connect(updateScale)

end

-- ============================================================================
-- HELPERS
-- ============================================================================

local function rounded(parent, radius)

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(
            0,
            radius or 8
        )

    corner.Parent =
        parent

    return corner

end

local function stroke(
    parent,
    color,
    transparency,
    thickness
)

    local uiStroke =
        Instance.new("UIStroke")

    uiStroke.Color =
        color or BORDER

    uiStroke.Transparency =
        transparency or 0.45

    uiStroke.Thickness =
        thickness or 1

    uiStroke.ApplyStrokeMode =
        Enum.ApplyStrokeMode.Border

    uiStroke.Parent =
        parent

    return uiStroke

end

local function tween(
    object,
    properties,
    duration
)

    local info =
        TweenInfo.new(
            duration or 0.18,
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

    local copied =
        false

    pcall(function()

        if setclipboard then

            setclipboard(text)

            copied =
                true

        elseif toclipboard then

            toclipboard(text)

            copied =
                true

        end

    end)

    return copied

end

local function openLink(link)

    local opened =
        false

    pcall(function()

        GuiService:OpenBrowserWindow(
            link
        )

        opened =
            true

    end)

    local copied =
        copyToClipboard(
            link
        )

    return opened, copied

end

local function makeLabel(
    parent,
    text,
    position,
    size,
    textSize,
    color,
    font
)

    local label =
        Instance.new("TextLabel")

    label.BackgroundTransparency =
        1

    label.Position =
        position

    label.Size =
        size

    label.Text =
        text

    label.TextColor3 =
        color or TEXT

    label.Font =
        font or Enum.Font.Gotham

    label.TextSize =
        textSize or 10

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.TextYAlignment =
        Enum.TextYAlignment.Center

    label.Parent =
        parent

    return label

end

-- ============================================================================
-- MAIN WINDOW
-- ============================================================================

local frame =
    Instance.new("Frame")

frame.Name =
    "Main"

frame.Size =
    UDim2.fromOffset(
        760,
        500
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
    WINDOW

frame.BackgroundTransparency =
    WINDOW_TRANSPARENCY

frame.BorderSizePixel =
    0

frame.ClipsDescendants =
    true

frame.Parent =
    gui

rounded(
    frame,
    12
)

stroke(
    frame,
    BORDER_LIGHT,
    0.42,
    1
)

-- ============================================================================
-- HEADER
-- ============================================================================

local header =
    Instance.new("Frame")

header.Size =
    UDim2.new(
        1,
        0,
        0,
        72
    )

header.BackgroundColor3 =
    HEADER

header.BackgroundTransparency =
    0.05

header.BorderSizePixel =
    0

header.Parent =
    frame

local headerBottom =
    Instance.new("Frame")

headerBottom.Size =
    UDim2.new(
        1,
        -32,
        0,
        1
    )

headerBottom.Position =
    UDim2.fromOffset(
        16,
        71
    )

headerBottom.BackgroundColor3 =
    BORDER

headerBottom.BackgroundTransparency =
    0.35

headerBottom.BorderSizePixel =
    0

headerBottom.Parent =
    header

-- ============================================================================
-- HEADER TITLE
-- ============================================================================

makeLabel(
    header,
    "ZEHUB",
    UDim2.fromOffset(
        20,
        13
    ),
    UDim2.fromOffset(
        220,
        28
    ),
    20,
    WHITE,
    Enum.Font.GothamBold
)

makeLabel(
    header,
    "SCRIPT LOADER  •  SECURE ACCESS",
    UDim2.fromOffset(
        20,
        40
    ),
    UDim2.fromOffset(
        260,
        17
    ),
    8,
    MUTED,
    Enum.Font.GothamMedium
)

-- ============================================================================
-- HEADER DISCORD
-- ============================================================================

local headerDiscord =
    Instance.new("TextButton")

headerDiscord.Size =
    UDim2.fromOffset(
        95,
        32
    )

headerDiscord.Position =
    UDim2.new(
        1,
        -145,
        0,
        17
    )

headerDiscord.BackgroundColor3 =
    PANEL_2

headerDiscord.BackgroundTransparency =
    0.12

headerDiscord.BorderSizePixel =
    0

headerDiscord.Text =
    "DISCORD ↗"

headerDiscord.TextColor3 =
    TEXT

headerDiscord.Font =
    Enum.Font.GothamBold

headerDiscord.TextSize =
    8

headerDiscord.AutoButtonColor =
    false

headerDiscord.Parent =
    header

rounded(
    headerDiscord,
    7
)

local headerDiscordStroke =
    stroke(
        headerDiscord,
        BORDER,
        0.35
    )

headerDiscord.MouseEnter:Connect(function()

    tween(
        headerDiscord,
        {
            BackgroundColor3 =
                CARD_HOVER
        },
        0.12
    )

    headerDiscordStroke.Color =
        BORDER_LIGHT

end)

headerDiscord.MouseLeave:Connect(function()

    tween(
        headerDiscord,
        {
            BackgroundColor3 =
                PANEL_2
        },
        0.12
    )

    headerDiscordStroke.Color =
        BORDER

end)

-- ============================================================================
-- MINIMIZE
-- ============================================================================

local minimizeButton =
    Instance.new("TextButton")

minimizeButton.Size =
    UDim2.fromOffset(
        30,
        30
    )

minimizeButton.Position =
    UDim2.new(
        1,
        -93,
        0,
        18
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
    16

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
        30,
        30
    )

closeButton.Position =
    UDim2.new(
        1,
        -53,
        0,
        18
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
    21

closeButton.AutoButtonColor =
    false

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

body.Size =
    UDim2.new(
        1,
        -28,
        1,
        -86
    )

body.Position =
    UDim2.fromOffset(
        14,
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
        170,
        402
    )

sidebar.BackgroundColor3 =
    SIDEBAR

sidebar.BackgroundTransparency =
    0.05

sidebar.BorderSizePixel =
    0

sidebar.Parent =
    body

rounded(
    sidebar,
    9
)

stroke(
    sidebar,
    BORDER,
    0.48
)

-- ============================================================================
-- SIDEBAR TITLE
-- ============================================================================

makeLabel(
    sidebar,
    "◆  SUPPORTED GAMES",
    UDim2.fromOffset(
        15,
        14
    ),
    UDim2.fromOffset(
        140,
        20
    ),
    8,
    TEXT,
    Enum.Font.GothamBold
)

-- ============================================================================
-- GAME LIST
-- ============================================================================

local gameList =
    Instance.new("Frame")

gameList.Size =
    UDim2.new(
        1,
        -18,
        0,
        260
    )

gameList.Position =
    UDim2.fromOffset(
        9,
        46
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

local sidebarFooterLine =
    Instance.new("Frame")

sidebarFooterLine.Size =
    UDim2.new(
        1,
        -28,
        0,
        1
    )

sidebarFooterLine.Position =
    UDim2.new(
        0,
        14,
        1,
        -47
    )

sidebarFooterLine.BackgroundColor3 =
    BORDER

sidebarFooterLine.BackgroundTransparency =
    0.48

sidebarFooterLine.BorderSizePixel =
    0

sidebarFooterLine.Parent =
    sidebar

makeLabel(
    sidebar,
    "FAST  •  SECURE  •  RELIABLE",
    UDim2.new(
        0,
        8,
        1,
        -36
    ),
    UDim2.new(
        1,
        -16,
        0,
        20
    ),
    7,
    DARK_MUTED,
    Enum.Font.GothamMedium
).TextXAlignment =
    Enum.TextXAlignment.Center

-- ============================================================================
-- CONTENT CONTAINER
-- ============================================================================

local content =
    Instance.new("Frame")

content.Size =
    UDim2.new(
        1,
        -180,
        1,
        0
    )

content.Position =
    UDim2.fromOffset(
        180,
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

rounded(
    content,
    9
)

stroke(
    content,
    BORDER,
    0.48
)

-- ============================================================================
-- PAGE CONTAINER
-- ============================================================================

local pages =
    Instance.new("Frame")

pages.Size =
    UDim2.fromScale(
        1,
        1
    )

pages.BackgroundTransparency =
    1

pages.Parent =
    content

-- ============================================================================
-- PAGE CREATOR
-- ============================================================================

local function createPage()

    local page =
        Instance.new("Frame")

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
        pages

    return page

end

local mainPage =
    createPage()

local getKeyPage =
    createPage()

local discordPage =
    createPage()

-- ============================================================================
-- PAGE SWITCHER
-- ============================================================================

local currentPage =
    mainPage

local function showPage(page)

    if currentPage == page then
        return
    end

    currentPage.Visible =
        false

    page.Visible =
        true

    currentPage =
        page

end

mainPage.Visible =
    true

-- ============================================================================
-- SIDEBAR GAME BUTTONS
-- ============================================================================

local gameButtons =
    {}

local function createGameButton(scriptData)

    local button =
        Instance.new("TextButton")

    button.Size =
        UDim2.new(
            1,
            0,
            0,
            58
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
        7
    )

    local buttonStroke =
        stroke(
            button,
            BORDER,
            0.70
        )

    -- Icon

    local iconBox =
        Instance.new("Frame")

    iconBox.Size =
        UDim2.fromOffset(
            36,
            36
        )

    iconBox.Position =
        UDim2.fromOffset(
            8,
            11
        )

    iconBox.BackgroundColor3 =
        INPUT

    iconBox.BackgroundTransparency =
        0.02

    iconBox.BorderSizePixel =
        0

    iconBox.Parent =
        button

    rounded(
        iconBox,
        7
    )

    stroke(
        iconBox,
        BORDER,
        0.38
    )

    local icon =
        makeLabel(
            iconBox,
            scriptData.Short,
            UDim2.fromScale(
                0,
                0
            ),
            UDim2.fromScale(
                1,
                1
            ),
            16,
            WHITE,
            Enum.Font.GothamBold
        )

    icon.TextXAlignment =
        Enum.TextXAlignment.Center

    icon.TextYAlignment =
        Enum.TextYAlignment.Center

    -- Name

    local name =
        makeLabel(
            button,
            scriptData.Name,
            UDim2.fromOffset(
                53,
                10
            ),
            UDim2.new(
                1,
                -78,
                0,
                17
            ),
            9,
            TEXT,
            Enum.Font.GothamBold
        )

    -- Description

    local description =
        makeLabel(
            button,
            scriptData.Description,
            UDim2.fromOffset(
                53,
                29
            ),
            UDim2.new(
                1,
                -75,
                0,
                15
            ),
            7,
            MUTED,
            Enum.Font.Gotham
        )

    -- Arrow

    local arrow =
        makeLabel(
            button,
            "›",
            UDim2.new(
                1,
                -23,
                0,
                9
            ),
            UDim2.fromOffset(
                15,
                35
            ),
            18,
            MUTED,
            Enum.Font.Gotham
        )

    arrow.TextXAlignment =
        Enum.TextXAlignment.Center

    arrow.TextYAlignment =
        Enum.TextYAlignment.Center

    local data =
        {
            Button = button,
            Stroke = buttonStroke,
            Script = scriptData
        }

    table.insert(
        gameButtons,
        data
    )

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

            buttonStroke.Transparency =
                0.35

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

            buttonStroke.Transparency =
                0.70

        end

    end)

    button.Activated:Connect(function()

        selectedScript =
            scriptData

        for _, item in
            ipairs(gameButtons) do

            item.Button.BackgroundColor3 =
                CARD

            item.Stroke.Color =
                BORDER

            item.Stroke.Transparency =
                0.70

        end

        button.BackgroundColor3 =
            CARD_SELECTED

        buttonStroke.Color =
            BORDER_LIGHT

        buttonStroke.Transparency =
            0.15

        if selectedScript.Name ==
            "Coming Soon" then

            setStatus(
                "ⓘ",
                "This game is coming soon.",
                MUTED
            )

        else

            setStatus(
                "ⓘ",
                "Ready. Enter your access key to continue.",
                MUTED
            )

        end

        showPage(
            mainPage
        )

    end)

    return button

end

for _, scriptData in
    ipairs(Scripts) do

    createGameButton(
        scriptData
    )

end

if gameButtons[1] then

    gameButtons[1].Button.BackgroundColor3 =
        CARD_SELECTED

    gameButtons[1].Stroke.Color =
        BORDER_LIGHT

    gameButtons[1].Stroke.Transparency =
        0.15

end

-- ============================================================================
-- STATUS BAR
-- ============================================================================

local statusBar =
    Instance.new("Frame")

statusBar.Size =
    UDim2.new(
        1,
        -24,
        0,
        38
    )

statusBar.Position =
    UDim2.new(
        0,
        12,
        1,
        -50
    )

statusBar.BackgroundColor3 =
    PANEL_2

statusBar.BackgroundTransparency =
    0.08

statusBar.BorderSizePixel =
    0

statusBar.ZIndex =
    10

statusBar.Parent =
    content

rounded(
    statusBar,
    7
)

local statusStroke =
    stroke(
        statusBar,
        BORDER,
        0.48
    )

local statusIcon =
    makeLabel(
        statusBar,
        "ⓘ",
        UDim2.fromOffset(
            10,
            0
        ),
        UDim2.fromOffset(
            22,
            38
        ),
        15,
        MUTED,
        Enum.Font.Gotham
    )

statusIcon.TextXAlignment =
    Enum.TextXAlignment.Center

statusIcon.TextYAlignment =
    Enum.TextYAlignment.Center

local statusText =
    makeLabel(
        statusBar,
        "Ready. Enter your access key to continue.",
        UDim2.fromOffset(
            35,
            0
        ),
        UDim2.new(
            1,
            -45,
            1,
            0
        ),
        8,
        MUTED,
        Enum.Font.Gotham
    )

-- ============================================================================
-- STATUS FUNCTION
-- ============================================================================

function setStatus(
    icon,
    textValue,
    color
)

    statusIcon.Text =
        icon

    statusIcon.TextColor3 =
        color or MUTED

    statusText.Text =
        textValue

    statusText.TextColor3 =
        color or MUTED

end

-- ============================================================================
-- MAIN PAGE
-- ============================================================================

do

    -- Header

    makeLabel(
        mainPage,
        selectedScript.Name,
        UDim2.fromOffset(
            22,
            18
        ),
        UDim2.fromOffset(
            280,
            30
        ),
        18,
        WHITE,
        Enum.Font.GothamBold
    )

    local mainSubtitle =
        makeLabel(
            mainPage,
            "Enter your ZeHub access key",
            UDim2.fromOffset(
                22,
                44
            ),
            UDim2.fromOffset(
                300,
                18
            ),
            8,
            MUTED,
            Enum.Font.Gotham
        )

    local mainIcon =
        Instance.new("Frame")

    mainIcon.Size =
        UDim2.fromOffset(
            52,
            52
        )

    mainIcon.Position =
        UDim2.new(
            1,
            -74,
            0,
            18
        )

    mainIcon.BackgroundColor3 =
        CARD

    mainIcon.BackgroundTransparency =
        0.02

    mainIcon.BorderSizePixel =
        0

    mainIcon.Parent =
        mainPage

    rounded(
        mainIcon,
        8
    )

    stroke(
        mainIcon,
        BORDER_LIGHT,
        0.50
    )

    local mainIconText =
        makeLabel(
            mainIcon,
            "R",
            UDim2.fromScale(
                0,
                0
            ),
            UDim2.fromScale(
                1,
                1
            ),
            22,
            WHITE,
            Enum.Font.GothamBold
        )

    mainIconText.TextXAlignment =
        Enum.TextXAlignment.Center

    mainIconText.TextYAlignment =
        Enum.TextYAlignment.Center

    -- Underline

    local underline =
        Instance.new("Frame")

    underline.Size =
        UDim2.fromOffset(
            58,
            2
        )

    underline.Position =
        UDim2.fromOffset(
            22,
            70
        )

    underline.BackgroundColor3 =
        ACCENT

    underline.BorderSizePixel =
        0

    underline.Parent =
        mainPage

    rounded(
        underline,
        2
    )

    -- Key box

    local keyBox =
        Instance.new("TextBox")

    keyBox.Name =
        "KeyBox"

    keyBox.Size =
        UDim2.new(
            1,
            -44,
            0,
            49
        )

    keyBox.Position =
        UDim2.fromOffset(
            22,
            91
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
        9

    keyBox.ClearTextOnFocus =
        false

    keyBox.TextXAlignment =
        Enum.TextXAlignment.Left

    keyBox.Parent =
        mainPage

    rounded(
        keyBox,
        7
    )

    local keyStroke =
        stroke(
            keyBox,
            BORDER,
            0.30
        )

    local padding =
        Instance.new("UIPadding")

    padding.PaddingLeft =
        UDim.new(
            0,
            13
        )

    padding.PaddingRight =
        UDim.new(
            0,
            13
        )

    padding.Parent =
        keyBox

    keyBox.Focused:Connect(function()

        keyStroke.Color =
            BORDER_LIGHT

        keyStroke.Transparency =
            0.05

    end)

    keyBox.FocusLost:Connect(function()

        keyStroke.Color =
            BORDER

        keyStroke.Transparency =
            0.30

    end)

    -- Button row

    local actionRow =
        Instance.new("Frame")

    actionRow.Size =
        UDim2.new(
            1,
            -44,
            0,
            42
        )

    actionRow.Position =
        UDim2.fromOffset(
            22,
            151
        )

    actionRow.BackgroundTransparency =
        1

    actionRow.Parent =
        mainPage

    -- Discord action

    local discordAction =
        Instance.new("TextButton")

    discordAction.Size =
        UDim2.new(
            0.5,
            -4,
            1,
            0
        )

    discordAction.BackgroundColor3 =
        CARD

    discordAction.BackgroundTransparency =
        0.02

    discordAction.BorderSizePixel =
        0

    discordAction.Text =
        "DISCORD ↗"

    discordAction.TextColor3 =
        TEXT

    discordAction.Font =
        Enum.Font.GothamBold

    discordAction.TextSize =
        9

    discordAction.AutoButtonColor =
        false

    discordAction.Parent =
        actionRow

    rounded(
        discordAction,
        7
    )

    local discordActionStroke =
        stroke(
            discordAction,
            BORDER,
            0.35
        )

    discordAction.MouseEnter:Connect(function()

        discordAction.BackgroundColor3 =
            CARD_HOVER

        discordActionStroke.Color =
            BORDER_LIGHT

    end)

    discordAction.MouseLeave:Connect(function()

        discordAction.BackgroundColor3 =
            CARD

        discordActionStroke.Color =
            BORDER

    end)

    discordAction.Activated:Connect(function()

        showPage(
            discordPage
        )

    end)

    -- Get key

    local getKeyAction =
        Instance.new("TextButton")

    getKeyAction.Size =
        UDim2.new(
            0.5,
            -4,
            1,
            0
        )

    getKeyAction.Position =
        UDim2.new(
            0.5,
            4,
            0,
            0
        )

    getKeyAction.BackgroundColor3 =
        ACCENT

    getKeyAction.BackgroundTransparency =
        0.02

    getKeyAction.BorderSizePixel =
        0

    getKeyAction.Text =
        "GET KEY ↗"

    getKeyAction.TextColor3 =
        Color3.fromRGB(
            10,
            11,
            13
        )

    getKeyAction.Font =
        Enum.Font.GothamBold

    getKeyAction.TextSize =
        9

    getKeyAction.AutoButtonColor =
        false

    getKeyAction.Parent =
        actionRow

    rounded(
        getKeyAction,
        7
    )

    getKeyAction.MouseEnter:Connect(function()

        getKeyAction.BackgroundColor3 =
            WHITE

    end)

    getKeyAction.MouseLeave:Connect(function()

        getKeyAction.BackgroundColor3 =
            ACCENT

    end)

    getKeyAction.Activated:Connect(function()

        showPage(
            getKeyPage
        )

    end)

    -- Load button

    local loadButton =
        Instance.new("TextButton")

    loadButton.Size =
        UDim2.new(
            1,
            -44,
            0,
            48
        )

    loadButton.Position =
        UDim2.fromOffset(
            22,
            205
        )

    loadButton.BackgroundColor3 =
        CARD_HOVER

    loadButton.BackgroundTransparency =
        0.02

    loadButton.BorderSizePixel =
        0

    loadButton.Text =
        "⚡  LOAD SCRIPT"

    loadButton.TextColor3 =
        WHITE

    loadButton.Font =
        Enum.Font.GothamBold

    loadButton.TextSize =
        10

    loadButton.AutoButtonColor =
        false

    loadButton.Parent =
        mainPage

    rounded(
        loadButton,
        7
    )

    local loadStroke =
        stroke(
            loadButton,
            BORDER_LIGHT,
            0.32
        )

    local loadArrow =
        makeLabel(
            loadButton,
            "›",
            UDim2.new(
                1,
                -34,
                0,
                0
            ),
            UDim2.fromOffset(
                25,
                48
            ),
            20,
            MUTED,
            Enum.Font.Gotham
        )

    loadArrow.TextXAlignment =
        Enum.TextXAlignment.Center

    loadArrow.TextYAlignment =
        Enum.TextYAlignment.Center

    loadButton.MouseEnter:Connect(function()

        loadButton.BackgroundColor3 =
            Color3.fromRGB(
                26,
                29,
                33
            )

        loadStroke.Transparency =
            0.10

        loadArrow.TextColor3 =
            WHITE

    end)

    loadButton.MouseLeave:Connect(function()

        loadButton.BackgroundColor3 =
            CARD_HOVER

        loadStroke.Transparency =
            0.32

        loadArrow.TextColor3 =
            MUTED

    end)

    -- Store globals

    _G.ZeHubKeyBox =
        keyBox

    _G.ZeHubLoadButton =
        loadButton

    _G.ZeHubMainSubtitle =
        mainSubtitle

    _G.ZeHubMainIcon =
        mainIconText

end

-- ============================================================================
-- GET KEY PAGE
-- ============================================================================

do

    local back =
        Instance.new("TextButton")

    back.Size =
        UDim2.fromOffset(
            90,
            30
        )

    back.Position =
        UDim2.fromOffset(
            17,
            14
        )

    back.BackgroundTransparency =
        1

    back.Text =
        "‹  GET KEY"

    back.TextColor3 =
        TEXT

    back.Font =
        Enum.Font.GothamBold

    back.TextSize =
        9

    back.TextXAlignment =
        Enum.TextXAlignment.Left

    back.AutoButtonColor =
        false

    back.Parent =
        getKeyPage

    back.Activated:Connect(function()

        showPage(
            mainPage
        )

    end)

    -- Key icon

    local keyIcon =
        Instance.new("Frame")

    keyIcon.Size =
        UDim2.fromOffset(
            44,
            44
        )

    keyIcon.Position =
        UDim2.fromOffset(
            17,
            54
        )

    keyIcon.BackgroundColor3 =
        CARD

    keyIcon.BorderSizePixel =
        0

    keyIcon.Parent =
        getKeyPage

    rounded(
        keyIcon,
        7
    )

    stroke(
        keyIcon,
        BORDER_LIGHT,
        0.45
    )

    local keyIconText =
        makeLabel(
            keyIcon,
            "⚿",
            UDim2.fromScale(
                0,
                0
            ),
            UDim2.fromScale(
                1,
                1
            ),
            21,
            WHITE,
            Enum.Font.Gotham
        )

    keyIconText.TextXAlignment =
        Enum.TextXAlignment.Center

    keyIconText.TextYAlignment =
        Enum.TextYAlignment.Center

    makeLabel(
        getKeyPage,
        "Get Your ZeHub Key",
        UDim2.fromOffset(
            72,
            54
        ),
        UDim2.new(
            1,
            -90,
            0,
            22
        ),
        11,
        WHITE,
        Enum.Font.GothamBold
    )

    makeLabel(
        getKeyPage,
        "Follow the steps below to get your key from FlowAuth.",
        UDim2.fromOffset(
            72,
            75
        ),
        UDim2.new(
            1,
            -90,
            0,
            18
        ),
        7,
        MUTED,
        Enum.Font.Gotham
    )

    -- Steps box

    local stepsBox =
        Instance.new("Frame")

    stepsBox.Size =
        UDim2.new(
            1,
            -34,
            0,
            174
        )

    stepsBox.Position =
        UDim2.fromOffset(
            17,
            106
        )

    stepsBox.BackgroundColor3 =
        PANEL_2

    stepsBox.BackgroundTransparency =
        0.05

    stepsBox.BorderSizePixel =
        0

    stepsBox.Parent =
        getKeyPage

    rounded(
        stepsBox,
        8
    )

    stroke(
        stepsBox,
        BORDER,
        0.45
    )

    local function keyStep(
        number,
        titleText,
        subText,
        y
    )

        local numberBox =
            Instance.new("Frame")

        numberBox.Size =
            UDim2.fromOffset(
                25,
                25
            )

        numberBox.Position =
            UDim2.fromOffset(
                11,
                y
            )

        numberBox.BackgroundColor3 =
            CARD_HOVER

        numberBox.BorderSizePixel =
            0

        numberBox.Parent =
            stepsBox

        rounded(
            numberBox,
            12
        )

        stroke(
            numberBox,
            BORDER_LIGHT,
            0.45
        )

        local numberText =
            makeLabel(
                numberBox,
                tostring(number),
                UDim2.fromScale(
                    0,
                    0
                ),
                UDim2.fromScale(
                    1,
                    1
                ),
                8,
                WHITE,
                Enum.Font.GothamBold
            )

        numberText.TextXAlignment =
            Enum.TextXAlignment.Center

        numberText.TextYAlignment =
            Enum.TextYAlignment.Center

        makeLabel(
            stepsBox,
            titleText,
            UDim2.fromOffset(
                48,
                y - 2
            ),
            UDim2.new(
                1,
                -60,
                0,
                17
            ),
            8,
            TEXT,
            Enum.Font.GothamBold
        )

        makeLabel(
            stepsBox,
            subText,
            UDim2.fromOffset(
                48,
                y + 13
            ),
            UDim2.new(
                1,
                -60,
                0,
                15
            ),
            7,
            MUTED,
            Enum.Font.Gotham
        )

    end

    keyStep(
        1,
        "Open the key page",
        "Click the button below to open FlowAuth.",
        11
    )

    keyStep(
        2,
        "Complete the required steps",
        "Finish the verification process.",
        49
    )

    keyStep(
        3,
        "Copy your generated key",
        "You will receive your key after completion.",
        87
    )

    keyStep(
        4,
        "Paste it into the key box",
        "Return to the loader and enter your key.",
        125
    )

    -- Link box

    local linkBox =
        Instance.new("TextLabel")

    linkBox.Size =
        UDim2.new(
            1,
            -34,
            0,
            32
        )

    linkBox.Position =
        UDim2.fromOffset(
            17,
            290
        )

    linkBox.BackgroundColor3 =
        INPUT

    linkBox.BackgroundTransparency =
        0.02

    linkBox.BorderSizePixel =
        0

    linkBox.Text =
        "  🔗  " .. GET_KEY_LINK

    linkBox.TextColor3 =
        MUTED

    linkBox.Font =
        Enum.Font.Gotham

    linkBox.TextSize =
        6.5

    linkBox.TextXAlignment =
        Enum.TextXAlignment.Left

    linkBox.TextTruncate =
        Enum.TextTruncate.AtEnd

    linkBox.Parent =
        getKeyPage

    rounded(
        linkBox,
        6
    )

    stroke(
        linkBox,
        BORDER,
        0.38
    )

    -- Open key page

    local openKey =
        Instance.new("TextButton")

    openKey.Size =
        UDim2.new(
            0.63,
            -6,
            0,
            34
        )

    openKey.Position =
        UDim2.fromOffset(
            17,
            330
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
        6
    )

    stroke(
        openKey,
        BORDER_LIGHT,
        0.35
    )

    openKey.MouseEnter:Connect(function()

        openKey.BackgroundColor3 =
            Color3.fromRGB(
                26,
                29,
                33
            )

    end)

    openKey.MouseLeave:Connect(function()

        openKey.BackgroundColor3 =
            CARD_HOVER

    end)

    openKey.Activated:Connect(function()

        local opened, copied =
            openLink(
                GET_KEY_LINK
            )

        if copied then

            notify(
                "KEY LINK COPIED",
                "FlowAuth link copied to clipboard.",
                3
            )

        elseif opened then

            notify(
                "FLOWAUTH OPENED",
                "Complete the steps and return here.",
                3
            )

        else

            notify(
                "FLOWAUTH",
                "Unable to open the key page.",
                3
            )

        end

    end)

    -- Copy link

    local copyKey =
        Instance.new("TextButton")

    copyKey.Size =
        UDim2.new(
            0.37,
            -6,
            0,
            34
        )

    copyKey.Position =
        UDim2.new(
            0.63,
            0,
            0,
            330
        )

    copyKey.BackgroundColor3 =
        CARD

    copyKey.BorderSizePixel =
        0

    copyKey.Text =
        "▣  COPY LINK"

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
        6
    )

    stroke(
        copyKey,
        BORDER,
        0.35
    )

    copyKey.Activated:Connect(function()

        if copyToClipboard(
            GET_KEY_LINK
        ) then

            notify(
                "KEY LINK COPIED",
                "FlowAuth link copied to clipboard.",
                3
            )

        end

    end)

end

-- ============================================================================
-- DISCORD PAGE
-- ============================================================================

do

    local back =
        Instance.new("TextButton")

    back.Size =
        UDim2.fromOffset(
            95,
            30
        )

    back.Position =
        UDim2.fromOffset(
            17,
            14
        )

    back.BackgroundTransparency =
        1

    back.Text =
        "‹  DISCORD"

    back.TextColor3 =
        TEXT

    back.Font =
        Enum.Font.GothamBold

    back.TextSize =
        9

    back.TextXAlignment =
        Enum.TextXAlignment.Left

    back.AutoButtonColor =
        false

    back.Parent =
        discordPage

    back.Activated:Connect(function()

        showPage(
            mainPage
        )

    end)

    -- Discord icon

    local discordIcon =
        Instance.new("Frame")

    discordIcon.Size =
        UDim2.fromOffset(
            56,
            56
        )

    discordIcon.Position =
        UDim2.fromOffset(
            17,
            56
        )

    discordIcon.BackgroundColor3 =
        CARD

    discordIcon.BorderSizePixel =
        0

    discordIcon.Parent =
        discordPage

    rounded(
        discordIcon,
        8
    )

    stroke(
        discordIcon,
        BORDER_LIGHT,
        0.45
    )

    local discordIconText =
        makeLabel(
            discordIcon,
            "◉",
            UDim2.fromScale(
                0,
                0
            ),
            UDim2.fromScale(
                1,
                1
            ),
            25,
            WHITE,
            Enum.Font.GothamBold
        )

    discordIconText.TextXAlignment =
        Enum.TextXAlignment.Center

    discordIconText.TextYAlignment =
        Enum.TextYAlignment.Center

    makeLabel(
        discordPage,
        "ZEHUB DISCORD",
        UDim2.fromOffset(
            88,
            57
        ),
        UDim2.new(
            1,
            -105,
            0,
            22
        ),
        11,
        WHITE,
        Enum.Font.GothamBold
    )

    makeLabel(
        discordPage,
        "Join our Discord for updates, support, new scripts",
        UDim2.fromOffset(
            88,
            78
        ),
        UDim2.new(
            1,
            -105,
            0,
            17
        ),
        7,
        MUTED,
        Enum.Font.Gotham
    )

    makeLabel(
        discordPage,
        "and key assistance.",
        UDim2.fromOffset(
            88,
            91
        ),
        UDim2.new(
            1,
            -105,
            0,
            17
        ),
        7,
        MUTED,
        Enum.Font.Gotham
    )

    -- Features

    local featureBox =
        Instance.new("Frame")

    featureBox.Size =
        UDim2.new(
            1,
            -34,
            0,
            130
        )

    featureBox.Position =
        UDim2.fromOffset(
            17,
            126
        )

    featureBox.BackgroundColor3 =
        PANEL_2

    featureBox.BackgroundTransparency =
        0.05

    featureBox.BorderSizePixel =
        0

    featureBox.Parent =
        discordPage

    rounded(
        featureBox,
        8
    )

    stroke(
        featureBox,
        BORDER,
        0.45
    )

    local features = {
        "Latest updates",
        "Support & help",
        "New scripts",
        "Key assistance"
    }

    for i, textValue in
        ipairs(features) do

        local y =
            16 + ((i - 1) * 25)

        local check =
            makeLabel(
                featureBox,
                "●",
                UDim2.fromOffset(
                    12,
                    y
                ),
                UDim2.fromOffset(
                    16,
                    18
                ),
                9,
                MUTED,
                Enum.Font.GothamBold
            )

        check.TextXAlignment =
            Enum.TextXAlignment.Center

        makeLabel(
            featureBox,
            textValue,
            UDim2.fromOffset(
                34,
                y
            ),
            UDim2.new(
                1,
                -45,
                0,
                18
            ),
            8,
            TEXT,
            Enum.Font.Gotham
        )

    end

    -- Discord link

    local discordLink =
        Instance.new("TextLabel")

    discordLink.Size =
        UDim2.new(
            1,
            -34,
            0,
            32
        )

    discordLink.Position =
        UDim2.fromOffset(
            17,
            267
        )

    discordLink.BackgroundColor3 =
        INPUT

    discordLink.BackgroundTransparency =
        0.02

    discordLink.BorderSizePixel =
        0

    discordLink.Text =
        "  🔗  " .. DISCORD_LINK

    discordLink.TextColor3 =
        MUTED

    discordLink.Font =
        Enum.Font.Gotham

    discordLink.TextSize =
        7

    discordLink.TextXAlignment =
        Enum.TextXAlignment.Left

    discordLink.TextTruncate =
        Enum.TextTruncate.AtEnd

    discordLink.Parent =
        discordPage

    rounded(
        discordLink,
        6
    )

    stroke(
        discordLink,
        BORDER,
        0.38
    )

    -- Join button

    local joinDiscord =
        Instance.new("TextButton")

    joinDiscord.Size =
        UDim2.new(
            0.63,
            -6,
            0,
            34
        )

    joinDiscord.Position =
        UDim2.fromOffset(
            17,
            307
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
        6
    )

    stroke(
        joinDiscord,
        BORDER_LIGHT,
        0.35
    )

    joinDiscord.MouseEnter:Connect(function()

        joinDiscord.BackgroundColor3 =
            Color3.fromRGB(
                26,
                29,
                33
            )

    end)

    joinDiscord.MouseLeave:Connect(function()

        joinDiscord.BackgroundColor3 =
            CARD_HOVER

    end)

    joinDiscord.Activated:Connect(function()

        local opened, copied =
            openLink(
                DISCORD_LINK
            )

        if copied then

            notify(
                "DISCORD LINK COPIED",
                "Discord invite copied to clipboard.",
                3
            )

        elseif opened then

            notify(
                "DISCORD OPENED",
                "Join the ZeHub Discord server.",
                3
            )

        else

            notify(
                "DISCORD",
                "Unable to open the invite.",
                3
            )

        end

    end)

    -- Copy invite

    local copyDiscord =
        Instance.new("TextButton")

    copyDiscord.Size =
        UDim2.new(
            0.37,
            -6,
            0,
            34
        )

    copyDiscord.Position =
        UDim2.new(
            0.63,
            0,
            0,
            307
        )

    copyDiscord.BackgroundColor3 =
        CARD

    copyDiscord.BorderSizePixel =
        0

    copyDiscord.Text =
        "▣  COPY INVITE"

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
        6
    )

    stroke(
        copyDiscord,
        BORDER,
        0.35
    )

    copyDiscord.Activated:Connect(function()

        if copyToClipboard(
            DISCORD_LINK
        ) then

            notify(
                "DISCORD LINK COPIED",
                "Discord invite copied to clipboard.",
                3
            )

        end

    end)

end

-- ============================================================================
-- NOTIFICATION HOLDER
-- ============================================================================

local notificationHolder =
    Instance.new("Frame")

notificationHolder.Size =
    UDim2.fromOffset(
        310,
        300
    )

notificationHolder.Position =
    UDim2.new(
        0.5,
        -155,
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
    Enum.HorizontalAlignment.Center

notificationLayout.VerticalAlignment =
    Enum.VerticalAlignment.Top

notificationLayout.Padding =
    UDim.new(
        0,
        7
    )

notificationLayout.Parent =
    notificationHolder

-- ============================================================================
-- NOTIFY
-- ============================================================================

function notify(
    titleText,
    messageText,
    duration,
    notificationType
)

    local notification =
        Instance.new("Frame")

    notification.Size =
        UDim2.fromOffset(
            285,
            61
        )

    notification.BackgroundColor3 =
        PANEL

    notification.BackgroundTransparency =
        0.03

    notification.BorderSizePixel =
        0

    notification.ClipsDescendants =
        true

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
        BORDER_LIGHT,
        0.35
    )

    local bar =
        Instance.new("Frame")

    bar.Size =
        UDim2.fromOffset(
            3,
            37
        )

    bar.Position =
        UDim2.fromOffset(
            10,
            12
        )

    bar.BackgroundColor3 =
        ACCENT

    if notificationType ==
        "error" then

        bar.BackgroundColor3 =
            ERROR

    elseif notificationType ==
        "success" then

        bar.BackgroundColor3 =
            SUCCESS

    end

    bar.BorderSizePixel =
        0

    bar.ZIndex =
        101

    bar.Parent =
        notification

    rounded(
        bar,
        2
    )

    makeLabel(
        notification,
        titleText,
        UDim2.fromOffset(
            23,
            9
        ),
        UDim2.new(
            1,
            -34,
            0,
            18
        ),
        8,
        WHITE,
        Enum.Font.GothamBold
    ).ZIndex =
        101

    makeLabel(
        notification,
        messageText,
        UDim2.fromOffset(
            23,
            28
        ),
        UDim2.new(
            1,
            -34,
            0,
            25
        ),
        7,
        MUTED,
        Enum.Font.Gotham
    ).ZIndex =
        101

    notification.Position =
        UDim2.new(
            0,
            0,
            0,
            -75
        )

    tween(
        notification,
        {
            Position =
                UDim2.new(
                    0,
                    0,
                    0,
                    0
                )
        },
        0.22
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
                            0,
                            0,
                            0,
                            -75
                        ),
                    BackgroundTransparency =
                        1
                },
                0.20
            )

            task.delay(
                0.25,
                function()

                    if notification
                        and notification.Parent then

                        notification:Destroy()

                    end

                end
            )

        end
    )

end

-- ============================================================================
-- AUTH OVERLAY
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
    0.08

authOverlay.BorderSizePixel =
    0

authOverlay.Visible =
    false

authOverlay.ZIndex =
    50

authOverlay.Parent =
    content

-- ============================================================================
-- AUTH CARD
-- ============================================================================

local authCard =
    Instance.new("Frame")

authCard.Size =
    UDim2.fromOffset(
        390,
        270
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
    9
)

stroke(
    authCard,
    BORDER_LIGHT,
    0.35
)

-- ============================================================================
-- AUTH ICON
-- ============================================================================

local authIcon =
    Instance.new("Frame")

authIcon.Size =
    UDim2.fromOffset(
        54,
        54
    )

authIcon.Position =
    UDim2.new(
        0.5,
        -27,
        0,
        32
    )

authIcon.BackgroundColor3 =
    CARD

authIcon.BorderSizePixel =
    0

authIcon.ZIndex =
    52

authIcon.Parent =
    authCard

rounded(
    authIcon,
    27
)

stroke(
    authIcon,
    BORDER_LIGHT,
    0.25
)

local authIconText =
    makeLabel(
        authIcon,
        "◌",
        UDim2.fromScale(
            0,
            0
        ),
        UDim2.fromScale(
            1,
            1
        ),
        27,
        WHITE,
        Enum.Font.Gotham
    )

authIconText.TextXAlignment =
    Enum.TextXAlignment.Center

authIconText.TextYAlignment =
    Enum.TextYAlignment.Center

authIconText.ZIndex =
    52

-- ============================================================================
-- AUTH TITLE
-- ============================================================================

local authTitle =
    makeLabel(
        authCard,
        "AUTHORIZING ZEHUB",
        UDim2.fromOffset(
            20,
            94
        ),
        UDim2.new(
            1,
            -40,
            0,
            25
        ),
        13,
        WHITE,
        Enum.Font.GothamBold
    )

authTitle.TextXAlignment =
    Enum.TextXAlignment.Center

authTitle.ZIndex =
    52

local authSubtitle =
    makeLabel(
        authCard,
        "Checking your access key...",
        UDim2.fromOffset(
            20,
            120
        ),
        UDim2.new(
            1,
            -40,
            0,
            20
        ),
        8,
        MUTED,
        Enum.Font.Gotham
    )

authSubtitle.TextXAlignment =
    Enum.TextXAlignment.Center

authSubtitle.ZIndex =
    52

-- ============================================================================
-- AUTH PROGRESS
-- ============================================================================

local progressBack =
    Instance.new("Frame")

progressBack.Size =
    UDim2.new(
        1,
        -100,
        0,
        3
    )

progressBack.Position =
    UDim2.fromOffset(
        50,
        157
    )

progressBack.BackgroundColor3 =
    BORDER

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

-- ============================================================================
-- AUTH HINT
-- ============================================================================

local authHint =
    makeLabel(
        authCard,
        "Verifying authentication with FlowAuth.",
        UDim2.fromOffset(
            20,
            174
        ),
        UDim2.new(
            1,
            -40,
            0,
            20
        ),
        7,
        DARK_MUTED,
        Enum.Font.Gotham
    )

authHint.TextXAlignment =
    Enum.TextXAlignment.Center

authHint.ZIndex =
    52

-- ============================================================================
-- AUTH STATE
-- ============================================================================

local function showAuth(
    titleText,
    subtitleText,
    icon,
    iconColor,
    progressValue,
    hint
)

    authOverlay.Visible =
        true

    authTitle.Text =
        titleText

    authSubtitle.Text =
        subtitleText

    authIconText.Text =
        icon

    authIconText.TextColor3 =
        iconColor or WHITE

    authHint.Text =
        hint or ""

    tween(
        progress,
        {
            Size =
                UDim2.new(
                    progressValue or 0,
                    0,
                    1,
                    0
                )
        },
        0.35
    )

end

local function hideAuth()

    authOverlay.Visible =
        false

end

-- ============================================================================
-- HEADER DISCORD
-- ============================================================================

headerDiscord.Activated:Connect(function()

    local opened, copied =
        openLink(
            DISCORD_LINK
        )

    if copied then

        notify(
            "DISCORD LINK COPIED",
            "Discord invite copied to clipboard.",
            3,
            "success"
        )

    elseif opened then

        notify(
            "DISCORD OPENED",
            "Join the ZeHub Discord server.",
            3
        )

    end

end)

-- ============================================================================
-- LOAD SCRIPT
-- ============================================================================

local authorizing =
    false

_G.ZeHubLoadButton.Activated:Connect(function()

    if authorizing then
        return
    end

    local key =
        tostring(
            _G.ZeHubKeyBox.Text or ""
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

    -- Empty key

    if key == "" then

        setStatus(
            "!",
            "KEY REQUIRED  •  Enter your ZeHub key first.",
            ERROR
        )

        notify(
            "KEY REQUIRED",
            "Enter your ZeHub key before loading.",
            3,
            "error"
        )

        return

    end

    -- Coming soon

    if selectedScript.Name ==
        "Coming Soon" then

        setStatus(
            "!",
            "COMING SOON  •  This game is not available yet.",
            ERROR
        )

        notify(
            "COMING SOON",
            "This script is not available yet.",
            3,
            "error"
        )

        return

    end

    -- Begin

    authorizing =
        true

    _G.ZeHubLoadButton.Active =
        false

    _G.ZeHubLoadButton.Text =
        "◌  AUTHORIZING ZEHUB"

    setStatus(
        "◌",
        "AUTHORIZING ZEHUB  •  Checking your access key...",
        WHITE
    )

    showAuth(
        "AUTHORIZING ZEHUB",
        "Checking your access key...",
        "◌",
        WHITE,
        0.22,
        "Verifying authentication with FlowAuth."
    )

    notify(
        "AUTHORIZING ZEHUB",
        "Checking your access key.",
        2
    )

    task.wait(
        0.35
    )

    -- Validating

    showAuth(
        "AUTHORIZING ZEHUB",
        "Validating your access key...",
        "◌",
        WHITE,
        0.58,
        "Checking your key with FlowAuth."
    )

    setStatus(
        "◌",
        "AUTHORIZING ZEHUB  •  Validating your access key...",
        WHITE
    )

    task.wait(
        0.20
    )

    -- Load FlowAuth loader

    local ok, success, message =
        pcall(function()

            local source =
                game:HttpGet(
                    FLOWAUTH_LOADER
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

    -- HTTP / loader error

    if not ok then

        authorizing =
            false

        _G.ZeHubLoadButton.Active =
            true

        _G.ZeHubLoadButton.Text =
            "⚡  LOAD SCRIPT"

        showAuth(
            "AUTHENTICATION FAILED",
            "Unable to authenticate the loader.",
            "!",
            ERROR,
            1,
            "Please check your key and try again."
        )

        setStatus(
            "!",
            "AUTHENTICATION FAILED  •  Loader error.",
            ERROR
        )

        notify(
            "AUTHENTICATION FAILED",
            tostring(
                success
            ),
            4,
            "error"
        )

        task.delay(
            1.2,
            hideAuth
        )

        return

    end

    -- Invalid key

    if success == false then

        authorizing =
            false

        _G.ZeHubLoadButton.Active =
            true

        _G.ZeHubLoadButton.Text =
            "⚡  LOAD SCRIPT"

        showAuth(
            "INVALID KEY",
            tostring(
                message
                    or "The key is invalid or expired."
            ),
            "!",
            ERROR,
            1,
            "Get a new key and try again."
        )

        setStatus(
            "!",
            "INVALID KEY  •  The key is invalid or expired.",
            ERROR
        )

        notify(
            "INVALID KEY",
            tostring(
                message
                    or "The key is invalid or expired."
            ),
            4,
            "error"
        )

        task.delay(
            1.8,
            hideAuth
        )

        return

    end

    -- Verified

    showAuth(
        "KEY VERIFIED",
        "Authentication successful.",
        "✓",
        SUCCESS,
        0.82,
        "Loading "
            .. selectedScript.Name
            .. "..."
    )

    setStatus(
        "✓",
        "KEY VERIFIED  •  Authentication successful.",
        SUCCESS
    )

    _G.ZeHubLoadButton.Text =
        "✓  KEY VERIFIED"

    notify(
        "KEY VERIFIED",
        "Authentication successful.",
        2.5,
        "success"
    )

    task.wait(
        0.75
    )

    -- Loading complete

    showAuth(
        "KEY VERIFIED",
        "Authentication successful.",
        "✓",
        SUCCESS,
        1,
        "Loading "
            .. selectedScript.Name
            .. "..."
    )

    setStatus(
        "✓",
        "Loading "
            .. selectedScript.Name
            .. "...",
        SUCCESS
    )

    task.wait(
        0.55
    )

    -- Final success

    showAuth(
        "KEY VERIFIED",
        "Authentication successful.",
        "✓",
        SUCCESS,
        1,
        "Loading "
            .. selectedScript.Name
            .. "..."
    )

    notify(
        "SCRIPT LOADED",
        selectedScript.Name
            .. " loaded successfully.",
        2.5,
        "success"
    )

    task.wait(
        0.55
    )

    if gui
        and gui.Parent then

        gui:Destroy()

    end

end)

-- ============================================================================
-- MINIMIZE
-- ============================================================================

local minimized =
    false

minimizeButton.Activated:Connect(function()

    minimized =
        not minimized

    if minimized then

        body.Visible =
            false

        headerBottom.Visible =
            false

        tween(
            frame,
            {
                Size =
                    UDim2.fromOffset(
                        760,
                        72
                    )
            },
            0.25
        )

        minimizeButton.Text =
            "+"

    else

        body.Visible =
            true

        headerBottom.Visible =
            true

        tween(
            frame,
            {
                Size =
                    UDim2.fromOffset(
                        760,
                        500
                    )
            },
            0.25
        )

        minimizeButton.Text =
            "—"

    end

end)

-- ============================================================================
-- DRAGGING
-- ============================================================================

local dragging =
    false

local dragStart
local startPosition

header.InputBegan:Connect(function(
    input
)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or
        input.UserInputType ==
            Enum.UserInputType.Touch then

        dragging =
            true

        dragStart =
            input.Position

        startPosition =
            frame.Position

        input.Changed:Connect(function()

            if input.UserInputState ==
                Enum.UserInputState.End then

                dragging =
                    false

            end

        end)

    end

end)

UserInputService.InputChanged:Connect(function(
    input
)

    if not dragging then
        return
    end

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement
        or
        input.UserInputType ==
            Enum.UserInputType.Touch then

        local delta =
            input.Position
                - dragStart

        frame.Position =
            UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset
                    + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset
                    + delta.Y
            )

    end

end)

-- ============================================================================
-- READY
-- ============================================================================

task.defer(function()

    task.wait(
        0.25
    )

    if gui
        and gui.Parent then

        notify(
            "ZEHUB READY",
            "Enter your access key to continue.",
            2.5
        )

    end

end)
