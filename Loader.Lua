-- ============================================================================
-- ZeHub • Secure Script Loader
-- Natural / Compact UI Edition
-- ============================================================================

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ============================================================================
-- CONFIG
-- ============================================================================

local DISCORD_LINK = "https://discord.gg/pehqQJzRm9"

local GET_KEY_LINK =
    "https://flowauth.net/reward/95257bff957772ebbe918833738a8fea"

local LOGO_IMAGE = "rbxassetid://137776481151936"

local LOADER_URL =
    "https://flowauth.net/v1/loaders/"

-- ============================================================================
-- SCRIPTS
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

local SelectedScript = Scripts[1]

-- ============================================================================
-- THEME
-- ============================================================================

local BG = Color3.fromRGB(7, 9, 11)
local PANEL = Color3.fromRGB(10, 12, 14)
local PANEL2 = Color3.fromRGB(13, 15, 18)
local ROW = Color3.fromRGB(15, 18, 21)
local ROW_HOVER = Color3.fromRGB(20, 23, 27)
local ROW_SELECTED = Color3.fromRGB(25, 29, 34)

local WHITE = Color3.fromRGB(235, 237, 240)
local TEXT = Color3.fromRGB(205, 208, 213)
local MUTED = Color3.fromRGB(125, 130, 137)
local DIM = Color3.fromRGB(82, 87, 94)

local BORDER = Color3.fromRGB(34, 38, 43)
local BORDER_LIGHT = Color3.fromRGB(55, 60, 67)

local GREEN = Color3.fromRGB(180, 205, 145)
local RED = Color3.fromRGB(220, 105, 105)

-- ============================================================================
-- REMOVE OLD UI
-- ============================================================================

local Existing = PlayerGui:FindFirstChild("ZeHub Key System")

if Existing then
    Existing:Destroy()
end

-- ============================================================================
-- SCREEN GUI
-- ============================================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "ZeHub Key System"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

-- ============================================================================
-- SCALE
-- ============================================================================

local UIScale = Instance.new("UIScale")
UIScale.Parent = Gui

local function UpdateScale()
    local Camera = workspace.CurrentCamera

    if not Camera then
        return
    end

    local Viewport = Camera.ViewportSize

    local X = Viewport.X / 760
    local Y = Viewport.Y / 500

    UIScale.Scale = math.clamp(math.min(X, Y), 0.70, 1)
end

UpdateScale()

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(
        UpdateScale
    )
end

-- ============================================================================
-- HELPERS
-- ============================================================================

local function Corner(Object, Radius)
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, Radius or 6)
    C.Parent = Object
    return C
end

local function Stroke(Object, Color, Transparency)
    local S = Instance.new("UIStroke")
    S.Color = Color or BORDER
    S.Transparency = Transparency or 0
    S.Thickness = 1
    S.Parent = Object
    return S
end

local function Tween(Object, Properties, Time)
    local T = TweenService:Create(
        Object,
        TweenInfo.new(
            Time or 0.18,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        Properties
    )

    T:Play()
    return T
end

local function Clipboard(Text)
    local Success = false

    pcall(function()
        if setclipboard then
            setclipboard(Text)
            Success = true
        end
    end)

    return Success
end

local function OpenLink(Link)
    local Opened = false

    pcall(function()
        GuiService:OpenBrowserWindow(Link)
        Opened = true
    end)

    local Copied = Clipboard(Link)

    return Opened, Copied
end

-- ============================================================================
-- MAIN WINDOW
-- ============================================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(760, 500)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = BG
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = Gui

Corner(Main, 10)
Stroke(Main, BORDER_LIGHT, 0.45)

-- ============================================================================
-- TOP BAR
-- ============================================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 70)
TopBar.BackgroundColor3 = PANEL
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1, -32, 0, 1)
TopLine.Position = UDim2.fromOffset(16, 69)
TopLine.BackgroundColor3 = BORDER
TopLine.BorderSizePixel = 0
TopLine.Parent = TopBar

-- ============================================================================
-- TITLE
-- ============================================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromOffset(220, 25)
Title.Position = UDim2.fromOffset(18, 13)
Title.BackgroundTransparency = 1
Title.Text = "ZEHUB"
Title.TextColor3 = WHITE
Title.Font = Enum.Font.GothamBold
Title.TextSize = 19
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.fromOffset(260, 18)
Subtitle.Position = UDim2.fromOffset(19, 38)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "SCRIPT LOADER  •  SECURE ACCESS"
Subtitle.TextColor3 = DIM
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextSize = 8
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = TopBar

-- ============================================================================
-- TOP DISCORD
-- ============================================================================

local TopDiscord = Instance.new("TextButton")
TopDiscord.Size = UDim2.fromOffset(82, 32)
TopDiscord.Position = UDim2.new(1, -132, 0, 19)
TopDiscord.BackgroundColor3 = PANEL2
TopDiscord.BorderSizePixel = 0
TopDiscord.Text = "DISCORD ↗"
TopDiscord.TextColor3 = TEXT
TopDiscord.Font = Enum.Font.GothamBold
TopDiscord.TextSize = 8
TopDiscord.AutoButtonColor = false
TopDiscord.Parent = TopBar

Corner(TopDiscord, 5)

local TopDiscordStroke = Stroke(
    TopDiscord,
    BORDER,
    0.25
)

TopDiscord.MouseEnter:Connect(function()
    TopDiscord.BackgroundColor3 = ROW_HOVER
    TopDiscordStroke.Color = BORDER_LIGHT
end)

TopDiscord.MouseLeave:Connect(function()
    TopDiscord.BackgroundColor3 = PANEL2
    TopDiscordStroke.Color = BORDER
end)

-- ============================================================================
-- MINIMIZE
-- ============================================================================

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(30, 30)
Minimize.Position = UDim2.new(1, -84, 0, 20)
Minimize.BackgroundTransparency = 1
Minimize.Text = "—"
Minimize.TextColor3 = MUTED
Minimize.Font = Enum.Font.GothamBold
Minimize.TextSize = 16
Minimize.AutoButtonColor = false
Minimize.Parent = TopBar

Minimize.MouseEnter:Connect(function()
    Minimize.TextColor3 = WHITE
end)

Minimize.MouseLeave:Connect(function()
    Minimize.TextColor3 = MUTED
end)

-- ============================================================================
-- CLOSE
-- ============================================================================

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(30, 30)
Close.Position = UDim2.new(1, -49, 0, 20)
Close.BackgroundTransparency = 1
Close.Text = "×"
Close.TextColor3 = MUTED
Close.Font = Enum.Font.Gotham
Close.TextSize = 18
Close.AutoButtonColor = false
Close.Parent = TopBar

Close.MouseEnter:Connect(function()
    Close.TextColor3 = WHITE
end)

Close.MouseLeave:Connect(function()
    Close.TextColor3 = MUTED
end)

Close.Activated:Connect(function()
    Gui:Destroy()
end)

-- ============================================================================
-- BODY
-- ============================================================================

local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, -32, 1, -86)
Body.Position = UDim2.fromOffset(16, 80)
Body.BackgroundTransparency = 1
Body.Parent = Main

-- ============================================================================
-- SIDEBAR
-- ============================================================================

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.fromOffset(170, 404)
Sidebar.BackgroundColor3 = PANEL
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Body

Corner(Sidebar, 7)
Stroke(Sidebar, BORDER, 0.25)

local SidebarTitle = Instance.new("TextLabel")
SidebarTitle.Size = UDim2.new(1, -24, 0, 20)
SidebarTitle.Position = UDim2.fromOffset(12, 13)
SidebarTitle.BackgroundTransparency = 1
SidebarTitle.Text = "◆ SUPPORTED GAMES"
SidebarTitle.TextColor3 = TEXT
SidebarTitle.Font = Enum.Font.GothamBold
SidebarTitle.TextSize = 8
SidebarTitle.TextXAlignment = Enum.TextXAlignment.Left
SidebarTitle.Parent = Sidebar

-- ============================================================================
-- GAME LIST
-- ============================================================================

local GameList = Instance.new("Frame")
GameList.Size = UDim2.new(1, -16, 0, 220)
GameList.Position = UDim2.fromOffset(8, 43)
GameList.BackgroundTransparency = 1
GameList.Parent = Sidebar

local GameLayout = Instance.new("UIListLayout")
GameLayout.Padding = UDim.new(0, 7)
GameLayout.SortOrder = Enum.SortOrder.LayoutOrder
GameLayout.Parent = GameList

-- ============================================================================
-- SIDEBAR FOOTER
-- ============================================================================

local FooterLine = Instance.new("Frame")
FooterLine.Size = UDim2.new(1, -24, 0, 1)
FooterLine.Position = UDim2.new(0, 12, 1, -48)
FooterLine.BackgroundColor3 = BORDER
FooterLine.BorderSizePixel = 0
FooterLine.Parent = Sidebar

local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, -20, 0, 20)
Footer.Position = UDim2.new(0, 10, 1, -35)
Footer.BackgroundTransparency = 1
Footer.Text = "FAST  •  SECURE  •  RELIABLE"
Footer.TextColor3 = DIM
Footer.Font = Enum.Font.GothamMedium
Footer.TextSize = 7
Footer.TextXAlignment = Enum.TextXAlignment.Center
Footer.Parent = Sidebar

-- ============================================================================
-- CONTENT
-- ============================================================================

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -182, 1, 0)
Content.Position = UDim2.fromOffset(182, 0)
Content.BackgroundColor3 = PANEL
Content.BorderSizePixel = 0
Content.ClipsDescendants = true
Content.Parent = Body

Corner(Content, 7)
Stroke(Content, BORDER, 0.25)

-- ============================================================================
-- NOTIFICATIONS
-- ============================================================================

local NotificationHolder = Instance.new("Frame")
NotificationHolder.Size = UDim2.fromOffset(300, 250)
NotificationHolder.Position = UDim2.new(1, -315, 0, 14)
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.ZIndex = 100
NotificationHolder.Parent = Gui

local NotificationLayout = Instance.new("UIListLayout")
NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationLayout.VerticalAlignment = Enum.VerticalAlignment.Top
NotificationLayout.Padding = UDim.new(0, 6)
NotificationLayout.Parent = NotificationHolder

local function Notify(Header, Message, Duration)
    local N = Instance.new("Frame")
    N.Size = UDim2.fromOffset(285, 57)
    N.BackgroundColor3 = PANEL2
    N.BorderSizePixel = 0
    N.ZIndex = 100
    N.Parent = NotificationHolder

    Corner(N, 6)
    Stroke(N, BORDER_LIGHT, 0.35)

    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1, -35, 0, 18)
    NTitle.Position = UDim2.fromOffset(15, 8)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = Header
    NTitle.TextColor3 = WHITE
    NTitle.Font = Enum.Font.GothamBold
    NTitle.TextSize = 8
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.ZIndex = 101
    NTitle.Parent = N

    local NMessage = Instance.new("TextLabel")
    NMessage.Size = UDim2.new(1, -30, 0, 24)
    NMessage.Position = UDim2.fromOffset(15, 27)
    NMessage.BackgroundTransparency = 1
    NMessage.Text = Message
    NMessage.TextColor3 = MUTED
    NMessage.Font = Enum.Font.Gotham
    NMessage.TextSize = 7
    NMessage.TextWrapped = true
    NMessage.TextXAlignment = Enum.TextXAlignment.Left
    NMessage.ZIndex = 101
    NMessage.Parent = N

    N.Position = UDim2.new(1, 25, 0, 0)

    Tween(
        N,
        {
            Position = UDim2.new(1, 0, 0, 0)
        },
        0.2
    )

    task.delay(Duration or 3, function()
        if not N.Parent then
            return
        end

        Tween(
            N,
            {
                Position = UDim2.new(1, 25, 0, 0)
            },
            0.18
        )

        task.wait(0.2)

        if N.Parent then
            N:Destroy()
        end
    end)
end

-- ============================================================================
-- PAGE SYSTEM
-- ============================================================================

local CurrentPage = "game"

local function ClearContent()
    for _, Child in ipairs(Content:GetChildren()) do
        Child:Destroy()
    end

    -- restore clipping/styling because content children are cleared only
    Corner(Content, 7)
    Stroke(Content, BORDER, 0.25)
end

-- ============================================================================
-- COMMON PAGE HELPERS
-- ============================================================================

local function PageTitle(Text, SmallText)
    local Back = Instance.new("TextButton")
    Back.Size = UDim2.fromOffset(60, 22)
    Back.Position = UDim2.fromOffset(15, 12)
    Back.BackgroundTransparency = 1
    Back.Text = "‹  BACK"
    Back.TextColor3 = MUTED
    Back.Font = Enum.Font.GothamBold
    Back.TextSize = 8
    Back.TextXAlignment = Enum.TextXAlignment.Left
    Back.AutoButtonColor = false
    Back.Parent = Content

    Back.MouseEnter:Connect(function()
        Back.TextColor3 = WHITE
    end)

    Back.MouseLeave:Connect(function()
        Back.TextColor3 = MUTED
    end)

    Back.Activated:Connect(function()
        CurrentPage = "game"
        BuildGamePage()
    end)

    local Heading = Instance.new("TextLabel")
    Heading.Size = UDim2.new(1, -40, 0, 25)
    Heading.Position = UDim2.fromOffset(15, 43)
    Heading.BackgroundTransparency = 1
    Heading.Text = Text
    Heading.TextColor3 = WHITE
    Heading.Font = Enum.Font.GothamBold
    Heading.TextSize = 15
    Heading.TextXAlignment = Enum.TextXAlignment.Left
    Heading.Parent = Content

    local Small = Instance.new("TextLabel")
    Small.Size = UDim2.new(1, -40, 0, 18)
    Small.Position = UDim2.fromOffset(16, 68)
    Small.BackgroundTransparency = 1
    Small.Text = SmallText
    Small.TextColor3 = MUTED
    Small.Font = Enum.Font.Gotham
    Small.TextSize = 8
    Small.TextXAlignment = Enum.TextXAlignment.Left
    Small.Parent = Content
end

-- ============================================================================
-- SIMPLE BOX
-- ============================================================================

local function CreateBox(Y, Height)
    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(1, -30, 0, Height)
    Box.Position = UDim2.fromOffset(15, Y)
    Box.BackgroundColor3 = PANEL2
    Box.BorderSizePixel = 0
    Box.Parent = Content

    Corner(Box, 6)
    Stroke(Box, BORDER, 0.3)

    return Box
end

-- ============================================================================
-- GAME PAGE
-- ============================================================================

local KeyBox

local function BuildGamePage()
    ClearContent()

    CurrentPage = "game"

    local HeaderBox = Instance.new("Frame")
    HeaderBox.Size = UDim2.new(1, -30, 0, 78)
    HeaderBox.Position = UDim2.fromOffset(15, 15)
    HeaderBox.BackgroundTransparency = 1
    HeaderBox.Parent = Content

    local Icon = Instance.new("Frame")
    Icon.Size = UDim2.fromOffset(58, 58)
    Icon.Position = UDim2.fromOffset(0, 0)
    Icon.BackgroundColor3 = ROW
    Icon.BorderSizePixel = 0
    Icon.Parent = HeaderBox

    Corner(Icon, 7)
    Stroke(Icon, BORDER_LIGHT, 0.25)

    local IconText = Instance.new("TextLabel")
    IconText.Size = UDim2.fromScale(1, 1)
    IconText.BackgroundTransparency = 1
    IconText.Text = SelectedScript.Short
    IconText.TextColor3 = WHITE
    IconText.Font = Enum.Font.GothamBold
    IconText.TextSize = 23
    IconText.Parent = Icon

    local GameName = Instance.new("TextLabel")
    GameName.Size = UDim2.new(1, -75, 0, 22)
    GameName.Position = UDim2.fromOffset(72, 5)
    GameName.BackgroundTransparency = 1
    GameName.Text = SelectedScript.Name
    GameName.TextColor3 = WHITE
    GameName.Font = Enum.Font.GothamBold
    GameName.TextSize = 14
    GameName.TextXAlignment = Enum.TextXAlignment.Left
    GameName.Parent = HeaderBox

    local GameSub = Instance.new("TextLabel")
    GameSub.Size = UDim2.new(1, -75, 0, 18)
    GameSub.Position = UDim2.fromOffset(72, 29)
    GameSub.BackgroundTransparency = 1
    GameSub.Text =
        SelectedScript.Name == "Coming Soon"
        and "Stay tuned..."
        or "Enter your ZeHub access key"
    GameSub.TextColor3 = MUTED
    GameSub.Font = Enum.Font.Gotham
    GameSub.TextSize = 8
    GameSub.TextXAlignment = Enum.TextXAlignment.Left
    GameSub.Parent = HeaderBox

    local Underline = Instance.new("Frame")
    Underline.Size = UDim2.fromOffset(48, 1)
    Underline.Position = UDim2.fromOffset(72, 55)
    Underline.BackgroundColor3 = BORDER_LIGHT
    Underline.BorderSizePixel = 0
    Underline.Parent = HeaderBox

    -- KEY INPUT
    KeyBox = Instance.new("TextBox")
    KeyBox.Size = UDim2.new(1, -30, 0, 43)
    KeyBox.Position = UDim2.fromOffset(15, 104)
    KeyBox.BackgroundColor3 = ROW
    KeyBox.BorderSizePixel = 0
    KeyBox.Text = ""
    KeyBox.PlaceholderText = "Enter your ZeHub key..."
    KeyBox.PlaceholderColor3 = DIM
    KeyBox.TextColor3 = WHITE
    KeyBox.Font = Enum.Font.Gotham
    KeyBox.TextSize = 9
    KeyBox.ClearTextOnFocus = false
    KeyBox.TextXAlignment = Enum.TextXAlignment.Left
    KeyBox.Parent = Content

    Corner(KeyBox, 6)

    local KeyStroke = Stroke(
        KeyBox,
        BORDER,
        0.25
    )

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 12)
    Padding.PaddingRight = UDim.new(0, 12)
    Padding.Parent = KeyBox

    KeyBox.Focused:Connect(function()
        KeyStroke.Color = BORDER_LIGHT
    end)

    KeyBox.FocusLost:Connect(function()
        KeyStroke.Color = BORDER
    end)

    -- BUTTONS
    local Discord = Instance.new("TextButton")
    Discord.Size = UDim2.new(0.5, -18, 0, 39)
    Discord.Position = UDim2.fromOffset(15, 155)
    Discord.BackgroundColor3 = ROW
    Discord.BorderSizePixel = 0
    Discord.Text = "DISCORD ↗"
    Discord.TextColor3 = TEXT
    Discord.Font = Enum.Font.GothamBold
    Discord.TextSize = 8
    Discord.AutoButtonColor = false
    Discord.Parent = Content

    Corner(Discord, 6)
    Stroke(Discord, BORDER, 0.25)

    Discord.MouseEnter:Connect(function()
        Discord.BackgroundColor3 = ROW_HOVER
    end)

    Discord.MouseLeave:Connect(function()
        Discord.BackgroundColor3 = ROW
    end)

    Discord.Activated:Connect(function()
        CurrentPage = "discord"
        BuildDiscordPage()
    end)

    local GetKey = Instance.new("TextButton")
    GetKey.Size = UDim2.new(0.5, -18, 0, 39)
    GetKey.Position = UDim2.new(0.5, 3, 0, 155)
    GetKey.BackgroundColor3 = ROW
    GetKey.BorderSizePixel = 0
    GetKey.Text = "GET KEY ↗"
    GetKey.TextColor3 = TEXT
    GetKey.Font = Enum.Font.GothamBold
    GetKey.TextSize = 8
    GetKey.AutoButtonColor = false
    GetKey.Parent = Content

    Corner(GetKey, 6)
    Stroke(GetKey, BORDER, 0.25)

    GetKey.MouseEnter:Connect(function()
        GetKey.BackgroundColor3 = ROW_HOVER
    end)

    GetKey.MouseLeave:Connect(function()
        GetKey.BackgroundColor3 = ROW
    end)

    GetKey.Activated:Connect(function()
        CurrentPage = "key"
        BuildKeyPage()
    end)

    -- LOAD BUTTON
    local Load = Instance.new("TextButton")
    Load.Size = UDim2.new(1, -30, 0, 44)
    Load.Position = UDim2.fromOffset(15, 207)
    Load.BackgroundColor3 = ROW
    Load.BorderSizePixel = 0
    Load.Text =
        SelectedScript.Name == "Coming Soon"
        and "COMING SOON"
        or "⚡  LOAD SCRIPT                              ›"
    Load.TextColor3 =
        SelectedScript.Name == "Coming Soon"
        and DIM
        or WHITE
    Load.Font = Enum.Font.GothamBold
    Load.TextSize = 9
    Load.AutoButtonColor = false
    Load.Parent = Content

    Corner(Load, 6)

    local LoadStroke = Stroke(
        Load,
        BORDER_LIGHT,
        0.25
    )

    if SelectedScript.Name ~= "Coming Soon" then
        Load.MouseEnter:Connect(function()
            Load.BackgroundColor3 = ROW_HOVER
            LoadStroke.Color = BORDER_LIGHT
        end)

        Load.MouseLeave:Connect(function()
            Load.BackgroundColor3 = ROW
            LoadStroke.Color = BORDER_LIGHT
        end)

        Load.Activated:Connect(function()
            StartAuthentication()
        end)
    end

    -- STATUS
    local Status = Instance.new("Frame")
    Status.Size = UDim2.new(1, -30, 0, 43)
    Status.Position = UDim2.fromOffset(15, 264)
    Status.BackgroundColor3 = PANEL2
    Status.BorderSizePixel = 0
    Status.Parent = Content

    Corner(Status, 6)
    Stroke(Status, BORDER, 0.35)

    local StatusIcon = Instance.new("TextLabel")
    StatusIcon.Size = UDim2.fromOffset(28, 43)
    StatusIcon.Position = UDim2.fromOffset(8, 0)
    StatusIcon.BackgroundTransparency = 1
    StatusIcon.Text = "ⓘ"
    StatusIcon.TextColor3 = MUTED
    StatusIcon.Font = Enum.Font.Gotham
    StatusIcon.TextSize = 14
    StatusIcon.Parent = Status

    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(1, -45, 1, 0)
    StatusText.Position = UDim2.fromOffset(40, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text =
        SelectedScript.Name == "Coming Soon"
        and "This script is not available yet."
        or "Ready. Enter your key to continue."
    StatusText.TextColor3 = MUTED
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextSize = 8
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.TextYAlignment = Enum.TextYAlignment.Center
    StatusText.Parent = Status
end

-- ============================================================================
-- GAME BUTTONS
-- ============================================================================

local GameButtons = {}

local function UpdateGameButtons()
    for ScriptData, Data in pairs(GameButtons) do
        if ScriptData == SelectedScript then
            Data.Background.BackgroundColor3 = ROW_SELECTED
            Data.Stroke.Color = BORDER_LIGHT
            Data.Stroke.Transparency = 0.15
        else
            Data.Background.BackgroundColor3 = ROW
            Data.Stroke.Color = BORDER
            Data.Stroke.Transparency = 0.35
        end
    end
end

local function CreateGameButton(ScriptData)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 54)
    Button.BackgroundColor3 = ROW
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = GameList

    Corner(Button, 6)

    local ButtonStroke = Stroke(
        Button,
        BORDER,
        0.35
    )

    local Icon = Instance.new("Frame")
    Icon.Size = UDim2.fromOffset(34, 34)
    Icon.Position = UDim2.fromOffset(7, 10)
    Icon.BackgroundColor3 = PANEL2
    Icon.BorderSizePixel = 0
    Icon.Parent = Button

    Corner(Icon, 5)
    Stroke(Icon, BORDER, 0.25)

    local IconText = Instance.new("TextLabel")
    IconText.Size = UDim2.fromScale(1, 1)
    IconText.BackgroundTransparency = 1
    IconText.Text = ScriptData.Short
    IconText.TextColor3 = TEXT
    IconText.Font = Enum.Font.GothamBold
    IconText.TextSize = 14
    IconText.Parent = Icon

    local Name = Instance.new("TextLabel")
    Name.Size = UDim2.new(1, -67, 0, 16)
    Name.Position = UDim2.fromOffset(50, 9)
    Name.BackgroundTransparency = 1
    Name.Text = ScriptData.Name
    Name.TextColor3 = TEXT
    Name.Font = Enum.Font.GothamBold
    Name.TextSize = 8
    Name.TextXAlignment = Enum.TextXAlignment.Left
    Name.Parent = Button

    local Description = Instance.new("TextLabel")
    Description.Size = UDim2.new(1, -67, 0, 14)
    Description.Position = UDim2.fromOffset(50, 26)
    Description.BackgroundTransparency = 1
    Description.Text = ScriptData.Description
    Description.TextColor3 = DIM
    Description.Font = Enum.Font.Gotham
    Description.TextSize = 6
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.Parent = Button

    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.fromOffset(18, 30)
    Arrow.Position = UDim2.new(1, -24, 0.5, -15)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "›"
    Arrow.TextColor3 = MUTED
    Arrow.Font = Enum.Font.Gotham
    Arrow.TextSize = 16
    Arrow.Parent = Button

    GameButtons[ScriptData] = {
        Background = Button,
        Stroke = ButtonStroke
    }

    Button.MouseEnter:Connect(function()
        if ScriptData ~= SelectedScript then
            Button.BackgroundColor3 = ROW_HOVER
        end
    end)

    Button.MouseLeave:Connect(function()
        if ScriptData ~= SelectedScript then
            Button.BackgroundColor3 = ROW
        end
    end)

    Button.Activated:Connect(function()
        SelectedScript = ScriptData
        UpdateGameButtons()
        BuildGamePage()
    end)
end

for _, ScriptData in ipairs(Scripts) do
    CreateGameButton(ScriptData)
end

-- ============================================================================
-- GET KEY PAGE
-- ============================================================================

function BuildKeyPage()
    ClearContent()

    CurrentPage = "key"

    PageTitle(
        "GET KEY",
        "Follow the steps below to get your key from FlowAuth."
    )

    local Steps = CreateBox(100, 178)

    local KeyIcon = Instance.new("TextLabel")
    KeyIcon.Size = UDim2.fromOffset(45, 45)
    KeyIcon.Position = UDim2.fromOffset(12, 14)
    KeyIcon.BackgroundColor3 = ROW
    KeyIcon.Text = "⌕"
    KeyIcon.TextColor3 = WHITE
    KeyIcon.Font = Enum.Font.GothamBold
    KeyIcon.TextSize = 25
    KeyIcon.Parent = Steps

    Corner(KeyIcon, 6)
    Stroke(KeyIcon, BORDER_LIGHT, 0.25)

    local StepTitle = Instance.new("TextLabel")
    StepTitle.Size = UDim2.new(1, -75, 0, 20)
    StepTitle.Position = UDim2.fromOffset(68, 14)
    StepTitle.BackgroundTransparency = 1
    StepTitle.Text = "Get Your ZeHub Key"
    StepTitle.TextColor3 = WHITE
    StepTitle.Font = Enum.Font.GothamBold
    StepTitle.TextSize = 10
    StepTitle.TextXAlignment = Enum.TextXAlignment.Left
    StepTitle.Parent = Steps

    local StepSub = Instance.new("TextLabel")
    StepSub.Size = UDim2.new(1, -75, 0, 18)
    StepSub.Position = UDim2.fromOffset(68, 34)
    StepSub.BackgroundTransparency = 1
    StepSub.Text = "Follow the steps below to receive your key."
    StepSub.TextColor3 = MUTED
    StepSub.Font = Enum.Font.Gotham
    StepSub.TextSize = 7
    StepSub.TextXAlignment = Enum.TextXAlignment.Left
    StepSub.Parent = Steps

    local Instructions = {
        {"1", "Open the key page", "Click the button below to open FlowAuth."},
        {"2", "Complete the required steps", "Finish the verification process."},
        {"3", "Copy your generated key", "You will receive your key after completion."},
        {"4", "Paste it into the key box", "Return to the loader and enter your key."}
    }

    for Index, Data in ipairs(Instructions) do
        local Y = 68 + ((Index - 1) * 25)

        local Number = Instance.new("TextLabel")
        Number.Size = UDim2.fromOffset(18, 18)
        Number.Position = UDim2.fromOffset(13, Y)
        Number.BackgroundColor3 = ROW
        Number.Text = Data[1]
        Number.TextColor3 = TEXT
        Number.Font = Enum.Font.GothamBold
        Number.TextSize = 7
        Number.Parent = Steps

        Corner(Number, 9)

        local Text = Instance.new("TextLabel")
        Text.Size = UDim2.new(1, -48, 0, 13)
        Text.Position = UDim2.fromOffset(40, Y - 2)
        Text.BackgroundTransparency = 1
        Text.Text = Data[2]
        Text.TextColor3 = TEXT
        Text.Font = Enum.Font.GothamBold
        Text.TextSize = 7
        Text.TextXAlignment = Enum.TextXAlignment.Left
        Text.Parent = Steps

        local Small = Instance.new("TextLabel")
        Small.Size = UDim2.new(1, -48, 0, 11)
        Small.Position = UDim2.fromOffset(40, Y + 10)
        Small.BackgroundTransparency = 1
        Small.Text = Data[3]
        Small.TextColor3 = DIM
        Small.Font = Enum.Font.Gotham
        Small.TextSize = 6
        Small.TextXAlignment = Enum.TextXAlignment.Left
        Small.Parent = Steps
    end

    -- URL
    local Url = Instance.new("TextBox")
    Url.Size = UDim2.new(1, -30, 0, 35)
    Url.Position = UDim2.fromOffset(15, 289)
    Url.BackgroundColor3 = ROW
    Url.BorderSizePixel = 0
    Url.Text = GET_KEY_LINK
    Url.TextColor3 = MUTED
    Url.Font = Enum.Font.Gotham
    Url.TextSize = 7
    Url.TextEditable = false
    Url.ClearTextOnFocus = false
    Url.TextXAlignment = Enum.TextXAlignment.Left
    Url.Parent = Content

    Corner(Url, 5)
    Stroke(Url, BORDER, 0.3)

    local URLPadding = Instance.new("UIPadding")
    URLPadding.PaddingLeft = UDim.new(0, 12)
    URLPadding.Parent = Url

    -- OPEN
    local Open = Instance.new("TextButton")
    Open.Size = UDim2.new(0.5, -18, 0, 36)
    Open.Position = UDim2.fromOffset(15, 334)
    Open.BackgroundColor3 = ROW
    Open.BorderSizePixel = 0
    Open.Text = "OPEN KEY PAGE ↗"
    Open.TextColor3 = TEXT
    Open.Font = Enum.Font.GothamBold
    Open.TextSize = 7
    Open.AutoButtonColor = false
    Open.Parent = Content

    Corner(Open, 5)
    Stroke(Open, BORDER, 0.3)

    Open.MouseEnter:Connect(function()
        Open.BackgroundColor3 = ROW_HOVER
    end)

    Open.MouseLeave:Connect(function()
        Open.BackgroundColor3 = ROW
    end)

    Open.Activated:Connect(function()
        local Opened, Copied = OpenLink(GET_KEY_LINK)

        if Copied then
            Notify(
                "KEY LINK COPIED",
                "FlowAuth link copied to clipboard.",
                3
            )
        elseif Opened then
            Notify(
                "FLOWAUTH OPENED",
                "Complete the required steps.",
                3
            )
        end
    end)

    -- COPY
    local Copy = Instance.new("TextButton")
    Copy.Size = UDim2.new(0.5, -18, 0, 36)
    Copy.Position = UDim2.new(0.5, 3, 0, 334)
    Copy.BackgroundColor3 = ROW
    Copy.BorderSizePixel = 0
    Copy.Text = "COPY LINK"
    Copy.TextColor3 = TEXT
    Copy.Font = Enum.Font.GothamBold
    Copy.TextSize = 7
    Copy.AutoButtonColor = false
    Copy.Parent = Content

    Corner(Copy, 5)
    Stroke(Copy, BORDER, 0.3)

    Copy.MouseEnter:Connect(function()
        Copy.BackgroundColor3 = ROW_HOVER
    end)

    Copy.MouseLeave:Connect(function()
        Copy.BackgroundColor3 = ROW
    end)

    Copy.Activated:Connect(function()
        if Clipboard(GET_KEY_LINK) then
            Notify(
                "KEY LINK COPIED",
                "The FlowAuth link is on your clipboard.",
                3
            )
        end
    end)
end

-- ============================================================================
-- DISCORD PAGE
-- ============================================================================

function BuildDiscordPage()
    ClearContent()

    CurrentPage = "discord"

    PageTitle(
        "DISCORD",
        "Join the ZeHub Discord for updates, support and key assistance."
    )

    local DiscordBox = CreateBox(100, 145)

    local DiscordIcon = Instance.new("TextLabel")
    DiscordIcon.Size = UDim2.fromOffset(54, 54)
    DiscordIcon.Position = UDim2.fromOffset(15, 17)
    DiscordIcon.BackgroundColor3 = ROW
    DiscordIcon.Text = "◉"
    DiscordIcon.TextColor3 = WHITE
    DiscordIcon.Font = Enum.Font.GothamBold
    DiscordIcon.TextSize = 23
    DiscordIcon.Parent = DiscordBox

    Corner(DiscordIcon, 7)
    Stroke(DiscordIcon, BORDER_LIGHT, 0.25)

    local DTitle = Instance.new("TextLabel")
    DTitle.Size = UDim2.new(1, -90, 0, 20)
    DTitle.Position = UDim2.fromOffset(82, 17)
    DTitle.BackgroundTransparency = 1
    DTitle.Text = "ZEHUB DISCORD"
    DTitle.TextColor3 = WHITE
    DTitle.Font = Enum.Font.GothamBold
    DTitle.TextSize = 10
    DTitle.TextXAlignment = Enum.TextXAlignment.Left
    DTitle.Parent = DiscordBox

    local DSub = Instance.new("TextLabel")
    DSub.Size = UDim2.new(1, -90, 0, 28)
    DSub.Position = UDim2.fromOffset(82, 39)
    DSub.BackgroundTransparency = 1
    DSub.Text = "Join our Discord for updates, support, new scripts and key assistance."
    DSub.TextColor3 = MUTED
    DSub.Font = Enum.Font.Gotham
    DSub.TextSize = 7
    DSub.TextWrapped = true
    DSub.TextXAlignment = Enum.TextXAlignment.Left
    DSub.Parent = DiscordBox

    local Info = CreateBox(255, 80)

    local Items = {
        "Latest updates",
        "Support & help",
        "New scripts",
        "Key assistance"
    }

    for Index, Text in ipairs(Items) do
        local Y = 10 + ((Index - 1) * 16)

        local Check = Instance.new("TextLabel")
        Check.Size = UDim2.fromOffset(15, 15)
        Check.Position = UDim2.fromOffset(12, Y)
        Check.BackgroundColor3 = ROW
        Check.Text = "✓"
        Check.TextColor3 = TEXT
        Check.Font = Enum.Font.GothamBold
        Check.TextSize = 7
        Check.Parent = Info

        Corner(Check, 7)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -40, 0, 15)
        Label.Position = UDim2.fromOffset(35, Y)
        Label.BackgroundTransparency = 1
        Label.Text = Text
        Label.TextColor3 = TEXT
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 7
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Info
    end

    local URL = Instance.new("TextBox")
    URL.Size = UDim2.new(1, -30, 0, 35)
    URL.Position = UDim2.fromOffset(15, 345)
    URL.BackgroundColor3 = ROW
    URL.BorderSizePixel = 0
    URL.Text = DISCORD_LINK
    URL.TextColor3 = MUTED
    URL.Font = Enum.Font.Gotham
    URL.TextSize = 7
    URL.TextEditable = false
    URL.ClearTextOnFocus = false
    URL.TextXAlignment = Enum.TextXAlignment.Left
    URL.Parent = Content

    Corner(URL, 5)
    Stroke(URL, BORDER, 0.3)

    local URLPadding = Instance.new("UIPadding")
    URLPadding.PaddingLeft = UDim.new(0, 12)
    URLPadding.Parent = URL

    local Join = Instance.new("TextButton")
    Join.Size = UDim2.new(0.5, -18, 0, 36)
    Join.Position = UDim2.fromOffset(15, 390)
    Join.BackgroundColor3 = ROW
    Join.BorderSizePixel = 0
    Join.Text = "JOIN DISCORD ↗"
    Join.TextColor3 = TEXT
    Join.Font = Enum.Font.GothamBold
    Join.TextSize = 7
    Join.AutoButtonColor = false
    Join.Parent = Content

    Corner(Join, 5)
    Stroke(Join, BORDER, 0.3)

    Join.MouseEnter:Connect(function()
        Join.BackgroundColor3 = ROW_HOVER
    end)

    Join.MouseLeave:Connect(function()
        Join.BackgroundColor3 = ROW
    end)

    Join.Activated:Connect(function()
        local Opened, Copied = OpenLink(DISCORD_LINK)

        if Copied then
            Notify(
                "DISCORD LINK COPIED",
                "Invite copied to clipboard.",
                3
            )
        elseif Opened then
            Notify(
                "DISCORD OPENED",
                "Join the ZeHub community.",
                3
            )
        end
    end)

    local Copy = Instance.new("TextButton")
    Copy.Size = UDim2.new(0.5, -18, 0, 36)
    Copy.Position = UDim2.new(0.5, 3, 0, 390)
    Copy.BackgroundColor3 = ROW
    Copy.BorderSizePixel = 0
    Copy.Text = "COPY INVITE"
    Copy.TextColor3 = TEXT
    Copy.Font = Enum.Font.GothamBold
    Copy.TextSize = 7
    Copy.AutoButtonColor = false
    Copy.Parent = Content

    Corner(Copy, 5)
    Stroke(Copy, BORDER, 0.3)

    Copy.MouseEnter:Connect(function()
        Copy.BackgroundColor3 = ROW_HOVER
    end)

    Copy.MouseLeave:Connect(function()
        Copy.BackgroundColor3 = ROW
    end)

    Copy.Activated:Connect(function()
        if Clipboard(DISCORD_LINK) then
            Notify(
                "DISCORD LINK COPIED",
                "Discord invite copied to clipboard.",
                3
            )
        end
    end)
end

-- ============================================================================
-- AUTHENTICATION OVERLAY
-- ============================================================================

local function StartAuthentication()
    if SelectedScript.Name == "Coming Soon" then
        Notify(
            "COMING SOON",
            "This script is not available yet.",
            3
        )
        return
    end

    if not KeyBox then
        return
    end

    local Key = tostring(KeyBox.Text or "")

    Key = Key:gsub("^%s+", "")
    Key = Key:gsub("%s+$", "")

    if Key == "" then
        Notify(
            "KEY REQUIRED",
            "Enter your ZeHub key first.",
            3
        )
        return
    end

    -- ================================================================
    -- OVERLAY
    -- ================================================================

    local Overlay = Instance.new("Frame")
    Overlay.Name = "AuthOverlay"
    Overlay.Size = UDim2.fromScale(1, 1)
    Overlay.BackgroundColor3 = BG
    Overlay.BackgroundTransparency = 0.08
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 20
    Overlay.Parent = Main

    local Card = Instance.new("Frame")
    Card.Size = UDim2.fromOffset(310, 190)
    Card.Position = UDim2.fromScale(0.5, 0.5)
    Card.AnchorPoint = Vector2.new(0.5, 0.5)
    Card.BackgroundColor3 = PANEL
    Card.BorderSizePixel = 0
    Card.ZIndex = 21
    Card.Parent = Overlay

    Corner(Card, 7)
    Stroke(Card, BORDER_LIGHT, 0.25)

    local StateIcon = Instance.new("TextLabel")
    StateIcon.Size = UDim2.fromOffset(44, 44)
    StateIcon.Position = UDim2.fromScale(0.5, 0)
    StateIcon.AnchorPoint = Vector2.new(0.5, 0)
    StateIcon.Position = UDim2.new(0.5, 0, 0, 25)
    StateIcon.BackgroundColor3 = ROW
    StateIcon.Text = "◌"
    StateIcon.TextColor3 = WHITE
    StateIcon.Font = Enum.Font.GothamBold
    StateIcon.TextSize = 22
    StateIcon.ZIndex = 22
    StateIcon.Parent = Card

    Corner(StateIcon, 22)
    Stroke(StateIcon, BORDER_LIGHT, 0.2)

    local StateTitle = Instance.new("TextLabel")
    StateTitle.Size = UDim2.new(1, -30, 0, 20)
    StateTitle.Position = UDim2.fromOffset(15, 78)
    StateTitle.BackgroundTransparency = 1
    StateTitle.Text = "AUTHORIZING ZEHUB"
    StateTitle.TextColor3 = WHITE
    StateTitle.Font = Enum.Font.GothamBold
    StateTitle.TextSize = 11
    StateTitle.TextXAlignment = Enum.TextXAlignment.Center
    StateTitle.ZIndex = 22
    StateTitle.Parent = Card

    local StateSub = Instance.new("TextLabel")
    StateSub.Size = UDim2.new(1, -30, 0, 20)
    StateSub.Position = UDim2.fromOffset(15, 101)
    StateSub.BackgroundTransparency = 1
    StateSub.Text = "Checking your access key..."
    StateSub.TextColor3 = MUTED
    StateSub.Font = Enum.Font.Gotham
    StateSub.TextSize = 7
    StateSub.TextXAlignment = Enum.TextXAlignment.Center
    StateSub.ZIndex = 22
    StateSub.Parent = Card

    local ProgressBackground = Instance.new("Frame")
    ProgressBackground.Size = UDim2.new(1, -50, 0, 3)
    ProgressBackground.Position = UDim2.fromOffset(25, 137)
    ProgressBackground.BackgroundColor3 = ROW
    ProgressBackground.BorderSizePixel = 0
    ProgressBackground.ZIndex = 22
    ProgressBackground.Parent = Card

    Corner(ProgressBackground, 2)

    local Progress = Instance.new("Frame")
    Progress.Size = UDim2.new(0, 0, 1, 0)
    Progress.BackgroundColor3 = WHITE
    Progress.BorderSizePixel = 0
    Progress.ZIndex = 23
    Progress.Parent = ProgressBackground

    Corner(Progress, 2)

    local BottomText = Instance.new("TextLabel")
    BottomText.Size = UDim2.new(1, -30, 0, 20)
    BottomText.Position = UDim2.fromOffset(15, 152)
    BottomText.BackgroundTransparency = 1
    BottomText.Text = "Verifying authentication..."
    BottomText.TextColor3 = DIM
    BottomText.Font = Enum.Font.Gotham
    BottomText.TextSize = 6
    BottomText.TextXAlignment = Enum.TextXAlignment.Center
    BottomText.ZIndex = 22
    BottomText.Parent = Card

    -- ================================================================
    -- LOADING
    -- ================================================================

    Tween(
        Progress,
        {
            Size = UDim2.new(0.35, 0, 1, 0)
        },
        0.35
    )

    task.wait(0.3)

    local OK, Success, Message = pcall(function()
        local Source = game:HttpGet(
            LOADER_URL .. SelectedScript.Hash .. ".lua"
        )

        local Loader, CompileError = loadstring(Source)

        if not Loader then
            error(CompileError or "Failed to compile loader.")
        end

        return Loader(Key)
    end)

    -- ================================================================
    -- ERROR
    -- ================================================================

    if not OK then
        StateIcon.Text = "!"
        StateIcon.TextColor3 = RED
        StateTitle.Text = "AUTHENTICATION FAILED"
        StateSub.Text = "Unable to authenticate the loader."
        BottomText.Text = "Loader error. Please try again."

        Tween(
            Progress,
            {
                Size = UDim2.new(1, 0, 1, 0)
            },
            0.25
        )

        Notify(
            "AUTHENTICATION FAILED",
            tostring(Success),
            4
        )

        task.wait(1.2)

        Overlay:Destroy()
        return
    end

    -- ================================================================
    -- INVALID KEY
    -- ================================================================

    if Success == false then
        StateIcon.Text = "!"
        StateIcon.TextColor3 = RED
        StateTitle.Text = "INVALID KEY"
        StateSub.Text =
            tostring(Message or "The key is invalid or expired.")
        BottomText.Text = "Please get a new key and try again."

        Tween(
            Progress,
            {
                Size = UDim2.new(1, 0, 1, 0)
            },
            0.25
        )

        Notify(
            "INVALID KEY",
            tostring(Message or "The key is invalid or expired."),
            4
        )

        task.wait(1.2)

        Overlay:Destroy()
        return
    end

    -- ================================================================
    -- VERIFIED
    -- ================================================================

    Tween(
        Progress,
        {
            Size = UDim2.new(0.75, 0, 1, 0)
        },
        0.25
    )

    task.wait(0.3)

    StateIcon.Text = "✓"
    StateIcon.TextColor3 = GREEN
    StateTitle.Text = "KEY VERIFIED"
    StateSub.Text = "Authentication successful."
    BottomText.Text = "Loading " .. SelectedScript.Name .. "..."

    Tween(
        Progress,
        {
            Size = UDim2.new(1, 0, 1, 0)
        },
        0.35
    )

    Notify(
        "KEY VERIFIED",
        "Authentication successful. Loading " .. SelectedScript.Name .. ".",
        3
    )

    task.wait(0.8)

    if Gui and Gui.Parent then
        Gui:Destroy()
    end
end

-- ============================================================================
-- TOP DISCORD
-- ============================================================================

TopDiscord.Activated:Connect(function()
    local Opened, Copied = OpenLink(DISCORD_LINK)

    if Copied then
        Notify(
            "DISCORD LINK COPIED",
            "Discord invite copied to clipboard.",
            3
        )
    elseif Opened then
        Notify(
            "DISCORD OPENED",
            "Join the ZeHub Discord.",
            3
        )
    end
end)

-- ============================================================================
-- INITIAL PAGE
-- ============================================================================

BuildGamePage()
UpdateGameButtons()

-- ============================================================================
-- MINIMIZE
-- ============================================================================

local Minimized = false

Minimize.Activated:Connect(function()
    Minimized = not Minimized

    if Minimized then
        Body.Visible = false

        Tween(
            Main,
            {
                Size = UDim2.fromOffset(760, 70)
            },
            0.22
        )

        Minimize.Text = "+"
    else
        Body.Visible = true

        Tween(
            Main,
            {
                Size = UDim2.fromOffset(760, 500)
            },
            0.22
        )

        Minimize.Text = "—"
    end
end)

-- ============================================================================
-- DRAGGING
-- ============================================================================

local Dragging = false
local DragStart
local StartPosition

TopBar.InputBegan:Connect(function(Input)
    if
        Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch
    then
        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position

        Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if not Dragging then
        return
    end

    if
        Input.UserInputType == Enum.UserInputType.MouseMovement
        or Input.UserInputType == Enum.UserInputType.Touch
    then
        local Delta = Input.Position - DragStart

        Main.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
    end
end)

-- ============================================================================
-- READY
-- ============================================================================

task.delay(0.25, function()
    if Gui and Gui.Parent then
        Notify(
            "ZEHUB READY",
            "Enter your access key to continue.",
            2.5
        )
    end
end)
