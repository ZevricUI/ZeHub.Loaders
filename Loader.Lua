-- ============================================================================
-- FLOWAUTH CONFIGURATION
-- This file is intended to be the protected Runaways payload used by FlowAuth.
-- The outer FlowAuth UI verifies the user's key and calls this payload as
-- loader(key). Do NOT call the same protected-loader URL from inside this
-- payload, as that would recursively load itself.
-- ============================================================================

local FLOWAUTH_UI_URL =
    "https://flowauth.net/v1/ui/748f0ff5458570ecd6d79bcac8253c5a.lua"

local FLOWAUTH_LOADER_HASH = "2f8015eedaf4c092d6afc919837270de"

-- Optional: replace with your ZeHub Discord invite.
local ZEHUB_DISCORD_URL = "https://discord.gg/zehub"
local FLOWAUTH_LOADER_URL =
    "https://flowauth.net/v1/loaders/" .. FLOWAUTH_LOADER_HASH .. ".lua"

-- FlowAuth-compatible entry point. The key is supplied by the outer
-- FlowAuth loader; the protected payload itself does not need to verify it
-- again.
local function FlowAuthLoader(key)
    return key
end

-- ZeHub Runaways - Standalone Integrated Build
-- The previous embedded Runaways UI has been removed and replaced with
-- the uploaded ZeHub UI library.
-- ============================================================================

-- ============================================================================
-- [ 1 ] Services
-- ============================================================================
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local Workspace         = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

repeat task.wait() until game:IsLoaded()

-- ============================================================================
-- [ 2 ] Platform Detection
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
print("[ZeHub] Platform detected: " .. PLATFORM)

-- ============================================================================
-- [ 3 ] Config
-- ============================================================================
getgenv().config = getgenv().config or {
    killAura = false, killAuraRange = 250, killAuraDamage = 100,
    aimbot = false, aimbotSmoothness = 1, aimbotLimb = "Head", aimbotFov = 150,
    infiniteAmmo = false, infiniteAmmoAmount = 1000000,
    vehicleAccel = nil, vehicleTopSpeed = nil, infiniteFuel = false,
    lootEsp = false,
    buildingEsp = false, moneyEsp = false, npcEsp = false, vehicleEsp = false,
    walkSpeedEnabled = false, walkSpeed = 16,
    jumpPowerEnabled = false, jumpPower = 50,
    infiniteJump = false, noclip = false,
    savedPosition = nil, previousPosition = nil
}
local Config = getgenv().config
local DEFAULT_WALKSPEED = 16
local DEFAULT_JUMPPOWER = 50

-- ============================================================================
-- [ 4 ] Utility Table
-- ============================================================================
local utility = {
    espHighlights = {}, espConns = {}, auraConn = nil, aimbotConn = nil,
    vehicleConn = nil, ammoConn = nil, noclipConn = nil, noclipPropertyConns = {},
    playerConn = nil, posTrackerConn = nil,
    lastPos = nil, auraTick = 0, aimbotHolding = false
}

-- ============================================================================

-- ============================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local guiAlive = true

local ThemePresets = {
    Dark = {
        Background = Color3.fromRGB(7, 7, 8),
        Topbar = Color3.fromRGB(10, 10, 11),
        Sidebar = Color3.fromRGB(8, 8, 9),
        Row = Color3.fromRGB(15, 15, 16),
        RowHover = Color3.fromRGB(23, 23, 24),
        Input = Color3.fromRGB(11, 11, 12),
        Border = Color3.fromRGB(45, 45, 47),
        BorderBright = Color3.fromRGB(105, 105, 108),
        Text = Color3.fromRGB(245, 245, 246),
        Muted = Color3.fromRGB(145, 145, 149),
        Placeholder = Color3.fromRGB(82, 82, 86),
        ToggleOn = Color3.fromRGB(235, 235, 238),
        TabActive = Color3.fromRGB(28, 28, 30),
    },

    Light = {
        Background = Color3.fromRGB(235, 235, 235),
        Topbar = Color3.fromRGB(245, 245, 245),
        Sidebar = Color3.fromRGB(239, 239, 239),
        Row = Color3.fromRGB(248, 248, 248),
        RowHover = Color3.fromRGB(228, 228, 228),
        Input = Color3.fromRGB(232, 232, 232),
        Border = Color3.fromRGB(190, 190, 190),
        BorderBright = Color3.fromRGB(105, 105, 105),
        Text = Color3.fromRGB(18, 18, 19),
        Muted = Color3.fromRGB(105, 105, 108),
        Placeholder = Color3.fromRGB(135, 135, 138),
        ToggleOn = Color3.fromRGB(25, 25, 26),
        TabActive = Color3.fromRGB(220, 220, 220),
    }
}

local currentThemeName = "Dark"
local Theme = ThemePresets[currentThemeName]
local themeRefreshers = {}
local activePageName = nil
local minimized = false

local function create(className, properties)
    local object = Instance.new(className)

    for property, value in pairs(properties) do
        if property ~= "Parent" then
            object[property] = value
        end
    end

    if properties.Parent then
        object.Parent = properties.Parent
    end

    return object
end

local function corner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius),
        Parent = parent
    })
end

local function stroke(parent, color, transparency)
    return create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = color,
        Transparency = transparency or 0,
        Thickness = 1,
        Parent = parent
    })
end

local function tween(object, properties, duration)
    if not object or not object.Parent then
        return
    end

    local animation = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        properties
    )
    animation:Play()
    return animation
end

local function registerThemeRefresh(callback)
    table.insert(themeRefreshers, callback)
end

local function getGuiParent()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then
            return result
        end
    end

    return player:WaitForChild("PlayerGui")
end

local guiParent = getGuiParent()
local oldGui = guiParent:FindFirstChild("ZeHubUILibrary")
if oldGui then
    oldGui:Destroy()
end

local gui = create("ScreenGui", {
    Name = "ZeHubUILibrary",
    ResetOnSpawn = false,
    IgnoreGuiInset = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = guiParent
})
gui.Enabled = false

-- ZeHub responsive scaling: the whole window scales to the available viewport
-- while keeping the internal layout proportions intact.
local responsiveScale = create("UIScale", {
    Scale = 1,
    Parent = gui
})

local BASE_WIDTH = 900
local BASE_HEIGHT = 600
local TOPBAR_HEIGHT = 48
local SIDEBAR_COLLAPSED = 0
local SIDEBAR_EXPANDED = 0
local CONTENT_GAP = 12
local PAGE_HEADER_HEIGHT = 26
local SECTION_BAR_HEIGHT = 34
local sidebarExpanded = true

local NAV_MARKS = {}

local main = create("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(BASE_WIDTH, BASE_HEIGHT),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Active = true,
    Parent = gui
})
corner(main, 7)
local mainStroke = stroke(main, Theme.BorderBright, 0.35)

local topbar = create("Frame", {
    Name = "Topbar",
    Size = UDim2.new(1, 0, 0, TOPBAR_HEIGHT),
    BackgroundColor3 = Theme.Topbar,
    BackgroundTransparency = 0.18,
    BorderSizePixel = 0,
    Active = true,
    Parent = main
})
corner(topbar, 7)

local topbarSquareBottom = create("Frame", {
    Name = "SquareBottom",
    Position = UDim2.new(0, 0, 1, -7),
    Size = UDim2.new(1, 0, 0, 7),
    BackgroundColor3 = Theme.Topbar,
    BorderSizePixel = 0,
    Parent = topbar
})

local menuButton = create("TextButton", {
    Name = "Navigation",
    Position = UDim2.fromOffset(10, 8),
    Size = UDim2.fromOffset(22, 22),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Visible = false,
    Text = "≡",
    TextColor3 = Theme.Muted,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    Parent = topbar
})

local title = create("TextLabel", {
    Name = "Title",
    Position = UDim2.fromOffset(40, 4),
    Size = UDim2.new(1, -136, 0, 17),
    BackgroundTransparency = 1,
    Text = "ZeHub",
    TextColor3 = Theme.Text,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    Parent = topbar
})

local subtitle = create("TextLabel", {
    Name = "Subtitle",
    Position = UDim2.fromOffset(40, 20),
    Size = UDim2.new(1, -136, 0, 14),
    BackgroundTransparency = 1,
    Text = "UI Library",
    TextColor3 = Theme.Muted,
    TextSize = 9,
    Font = Enum.Font.GothamSemibold,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    Parent = topbar
})

local themeButton = create("TextButton", {
    Name = "Theme",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -61, 0.5, 0),
    Size = UDim2.fromOffset(20, 20),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
    Parent = topbar
})

local themeCenter = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(5, 5),
    BackgroundColor3 = Theme.Muted,
    BorderSizePixel = 0,
    Parent = themeButton
})
corner(themeCenter, 5)

local themeRays = {}
local rayData = {
    {UDim2.new(0.5, -1, 0.5, -7), UDim2.fromOffset(2, 3), 0},
    {UDim2.new(0.5, -1, 0.5, 4), UDim2.fromOffset(2, 3), 0},
    {UDim2.new(0.5, -7, 0.5, -1), UDim2.fromOffset(3, 2), 0},
    {UDim2.new(0.5, 4, 0.5, -1), UDim2.fromOffset(3, 2), 0},
}

for _, data in ipairs(rayData) do
    local ray = create("Frame", {
        Position = data[1],
        Size = data[2],
        Rotation = data[3],
        BackgroundColor3 = Theme.Muted,
        BorderSizePixel = 0,
        Parent = themeButton
    })
    table.insert(themeRays, ray)
end

local minimizeButton = create("TextButton", {
    Name = "Minimize",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -34, 0.5, 0),
    Size = UDim2.fromOffset(20, 20),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
    Parent = topbar
})

local minimizeLine = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(9, 1),
    BackgroundColor3 = Theme.Text,
    BorderSizePixel = 0,
    Parent = minimizeButton
})

local close = create("TextButton", {
    Name = "Close",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -8, 0.5, 0),
    Size = UDim2.fromOffset(18, 18),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Text = "X",
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    AutoButtonColor = false,
    Parent = topbar
})

local topLine = create("Frame", {
    Position = UDim2.new(0, 0, 1, -1),
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = Theme.Border,
    BorderSizePixel = 0,
    Parent = topbar
})

local TABBAR_HEIGHT = 54

local sidebar = create("Frame", {
    Name = "TopTabs",
    Position = UDim2.fromOffset(0, TOPBAR_HEIGHT),
    Size = UDim2.new(1, 0, 0, TABBAR_HEIGHT),
    BackgroundColor3 = Theme.Sidebar,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = main
})

local sidebarLine = create("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = Theme.Border,
    BorderSizePixel = 0,
    Parent = sidebar
})

local navHolder = create("Frame", {
    Position = UDim2.fromOffset(12, 6),
    Size = UDim2.new(1, -24, 1, -12),
    BackgroundTransparency = 1,
    Parent = sidebar
})

create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = navHolder
})

local content = create("Frame", {
    Name = "Content",
    Position = UDim2.fromOffset(CONTENT_GAP, TOPBAR_HEIGHT + TABBAR_HEIGHT + CONTENT_GAP),
    Size = UDim2.new(1, -(CONTENT_GAP * 2), 1, -(TOPBAR_HEIGHT + TABBAR_HEIGHT + CONTENT_GAP * 2)),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Parent = main
})

local pages = {}
local sideButtons = {}
local activeSectionByPage = {}

local function setGlyphColor(glyph, color)
    if not glyph then
        return
    end
    for _, part in ipairs(glyph.Fills or {}) do
        if part and part.Parent then
            part.BackgroundColor3 = color
        end
    end
    for _, line in ipairs(glyph.Strokes or {}) do
        if line and line.Parent then
            line.Color = color
        end
    end
    for _, textPart in ipairs(glyph.Texts or {}) do
        if textPart and textPart.Parent then
            textPart.TextColor3 = color
        end
    end
end

local function createNavGlyph(parent, kind)
    local root = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(18, 18),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local glyph = {Root = root, Fills = {}, Strokes = {}, Texts = {}}

    local function fill(position, size, radius)
        local part = create("Frame", {
            Position = position,
            Size = size,
            BackgroundColor3 = Theme.Muted,
            BorderSizePixel = 0,
            Parent = root
        })
        if radius then
            corner(part, radius)
        end
        table.insert(glyph.Fills, part)
        return part
    end

    local function outline(position, size, radius, thickness)
        local part = create("Frame", {
            Position = position,
            Size = size,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = root
        })
        if radius then
            corner(part, radius)
        end
        local partStroke = stroke(part, Theme.Muted, 0)
        partStroke.Thickness = thickness or 1
        table.insert(glyph.Strokes, partStroke)
        return part
    end

    local function textGlyph(value, textSize)
        local label = create("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = value,
            TextColor3 = Theme.Muted,
            TextSize = textSize or 12,
            Font = Enum.Font.GothamBold,
            Parent = root
        })
        table.insert(glyph.Texts, label)
        return label
    end

    if kind == "Changelog" or kind == "Home" then
        outline(UDim2.fromOffset(2, 2), UDim2.fromOffset(14, 14), 7, 1)
        fill(UDim2.fromOffset(8, 5), UDim2.fromOffset(2, 5), 1)
        local hand = fill(UDim2.fromOffset(9, 9), UDim2.fromOffset(5, 2), 1)
        hand.Rotation = 22
    elseif kind == "Auto Farm" or kind == "Farm" then
        outline(UDim2.fromOffset(3, 3), UDim2.fromOffset(12, 12), 7, 1)
        fill(UDim2.fromOffset(11, 2), UDim2.fromOffset(4, 2), 1)
        fill(UDim2.fromOffset(14, 2), UDim2.fromOffset(2, 5), 1)
        fill(UDim2.fromOffset(4, 11), UDim2.fromOffset(4, 2), 1)
        fill(UDim2.fromOffset(3, 9), UDim2.fromOffset(2, 4), 1)
    elseif kind == "Events" then
        outline(UDim2.fromOffset(3, 3), UDim2.fromOffset(12, 12), 7, 1)
        textGlyph("!", 11)
    elseif kind == "Pets" then
        fill(UDim2.fromOffset(3, 4), UDim2.fromOffset(4, 4), 3)
        fill(UDim2.fromOffset(7, 2), UDim2.fromOffset(4, 4), 3)
        fill(UDim2.fromOffset(11, 4), UDim2.fromOffset(4, 4), 3)
        fill(UDim2.fromOffset(6, 9), UDim2.fromOffset(7, 6), 4)
    elseif kind == "Progress" or kind == "Stats" then
        fill(UDim2.fromOffset(3, 11), UDim2.fromOffset(3, 4), 1)
        fill(UDim2.fromOffset(8, 7), UDim2.fromOffset(3, 8), 1)
        fill(UDim2.fromOffset(13, 3), UDim2.fromOffset(3, 12), 1)
    elseif kind == "Rewards" or kind == "Gift" then
        outline(UDim2.fromOffset(3, 6), UDim2.fromOffset(12, 9), 2, 1)
        fill(UDim2.fromOffset(8, 6), UDim2.fromOffset(2, 9), 1)
        fill(UDim2.fromOffset(2, 5), UDim2.fromOffset(14, 2), 1)
        fill(UDim2.fromOffset(5, 3), UDim2.fromOffset(4, 2), 2)
        fill(UDim2.fromOffset(9, 3), UDim2.fromOffset(4, 2), 2)
    elseif kind == "Visuals" or kind == "Eye" then
        outline(UDim2.fromOffset(2, 5), UDim2.fromOffset(14, 8), 6, 1)
        fill(UDim2.fromOffset(7, 7), UDim2.fromOffset(4, 4), 3)
    elseif kind == "Utility" or kind == "Settings" then
        fill(UDim2.fromOffset(3, 4), UDim2.fromOffset(12, 1), 1)
        fill(UDim2.fromOffset(3, 9), UDim2.fromOffset(12, 1), 1)
        fill(UDim2.fromOffset(3, 14), UDim2.fromOffset(12, 1), 1)
        fill(UDim2.fromOffset(6, 2), UDim2.fromOffset(3, 5), 2)
        fill(UDim2.fromOffset(11, 7), UDim2.fromOffset(3, 5), 2)
        fill(UDim2.fromOffset(5, 12), UDim2.fromOffset(3, 5), 2)
    else
        fill(UDim2.fromOffset(5, 5), UDim2.fromOffset(8, 8), 5)
    end

    return glyph
end

local function refreshPageSections(pageData)
    local activeSection = activeSectionByPage[pageData.Name]

    for sectionName, section in pairs(pageData.Sections) do
        section.Visible = sectionName == activeSection
    end

    for sectionName, buttonData in pairs(pageData.SectionButtons) do
        local active = sectionName == activeSection
        buttonData.Button.BackgroundColor3 = active and Theme.Row or Theme.Background
        buttonData.Button.BackgroundTransparency = active and 0 or 1
        buttonData.Label.TextColor3 = active and Theme.Text or Theme.Muted
        buttonData.Underline.BackgroundColor3 = Theme.Text
        buttonData.Underline.BackgroundTransparency = active and 0.15 or 1
    end
end

local function selectSection(pageName, sectionName)
    local pageData = pages[pageName]
    if not pageData or not pageData.Sections[sectionName] then
        return
    end

    activeSectionByPage[pageName] = sectionName
    refreshPageSections(pageData)
end

local function refreshSideTabs()
    for name, data in pairs(sideButtons) do
        local active = name == activePageName

        data.Button.BackgroundColor3 = Theme.Topbar
        data.IconHolder.BackgroundColor3 = active and Theme.TabActive or Theme.Topbar
        data.IconHolder.BackgroundTransparency = active and 0 or 1

        data.IconStroke.Color = Theme.Border
        data.IconStroke.Transparency = 1

        data.Label.TextColor3 = active and Theme.Text or Theme.Muted
        data.Indicator.BackgroundColor3 = Theme.Text
        data.Indicator.BackgroundTransparency = active and 0 or 1
        setGlyphColor(data.Glyph, active and Theme.Text or Theme.Muted)
    end
end

local function selectPage(name)
    local pageData = pages[name]
    if not pageData then
        return
    end

    activePageName = name

    for pageName, data in pairs(pages) do
        data.Root.Visible = pageName == name
    end

    if not activeSectionByPage[name] and pageData.FirstSection then
        activeSectionByPage[name] = pageData.FirstSection
    end

    refreshPageSections(pageData)
    refreshSideTabs()
end

local function createPage(name, iconAsset)
    local root = create("Frame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = content
    })

    local pageHeader = create("Frame", {
        Name = "PageHeader",
        Position = UDim2.fromOffset(0, SECTION_BAR_HEIGHT + 2),
        Size = UDim2.new(1, 0, 0, PAGE_HEADER_HEIGHT),
        BackgroundTransparency = 1,
        Parent = root
    })

    local headerDot = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(4, 4),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
        Parent = pageHeader
    })
    corner(headerDot, 3)

    local headerLabel = create("TextLabel", {
        Position = UDim2.fromOffset(13, 0),
        Size = UDim2.fromOffset(92, PAGE_HEADER_HEIGHT),
        BackgroundTransparency = 1,
        Text = string.upper(name),
        TextColor3 = Theme.Muted,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = pageHeader
    })

    local headerLine = create("Frame", {
        Position = UDim2.fromOffset(103, math.floor(PAGE_HEADER_HEIGHT / 2)),
        Size = UDim2.new(1, -106, 0, 1),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Parent = pageHeader
    })

    local sectionBar = create("ScrollingFrame", {
        Name = "SectionTabs",
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, SECTION_BAR_HEIGHT),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollingDirection = Enum.ScrollingDirection.X,
        Active = true,
        Parent = root
    })

    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = sectionBar
    })

    local contentTop = SECTION_BAR_HEIGHT + PAGE_HEADER_HEIGHT + 7
    local sectionContent = create("Frame", {
        Position = UDim2.fromOffset(0, contentTop),
        Size = UDim2.new(1, 0, 1, -contentTop),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = root
    })

    local pageData = {
        Name = name,
        Root = root,
        PageHeader = pageHeader,
        HeaderDot = headerDot,
        HeaderLabel = headerLabel,
        HeaderLine = headerLine,
        SectionBar = sectionBar,
        SectionContent = sectionContent,
        Sections = {},
        SectionButtons = {},
        FirstSection = nil
    }
    pages[name] = pageData

    local navButton = create("TextButton", {
        Name = "Nav_" .. name,
        Size = UDim2.fromOffset(150, 40),
        BackgroundColor3 = Theme.Topbar,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = navHolder
    })
    corner(navButton, 4)

    local indicator = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(3, 24),
        BackgroundColor3 = Theme.Text,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = navButton
    })
    corner(indicator, 2)

    local iconHolder = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 9, 0.5, 0),
        Size = UDim2.fromOffset(28, 28),
        BackgroundColor3 = Theme.Input,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = navButton
    })
    corner(iconHolder, 5)
    local iconStroke = stroke(iconHolder, Theme.Border, 1)

    local glyph = createNavGlyph(iconHolder, iconAsset or name)

    local label = create("TextLabel", {
        Position = UDim2.fromOffset(45, 0),
        Size = UDim2.new(1, -51, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Muted,
        TextTransparency = sidebarExpanded and 0 or 1,
        TextSize = 11,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = navButton
    })

    sideButtons[name] = {
        Button = navButton,
        IconHolder = iconHolder,
        IconStroke = iconStroke,
        Glyph = glyph,
        Label = label,
        Indicator = indicator
    }

    navButton.Activated:Connect(function()
        selectPage(name)
    end)

    navButton.MouseEnter:Connect(function()
        if activePageName ~= name then
            tween(navButton, {BackgroundColor3 = Theme.RowHover}, 0.08)
            tween(label, {TextColor3 = Theme.Text}, 0.08)
            setGlyphColor(glyph, Theme.Text)
        end
    end)

    navButton.MouseLeave:Connect(function()
        refreshSideTabs()
    end)

    registerThemeRefresh(function()
        if root.Parent then
            headerDot.BackgroundColor3 = Theme.Text
            headerLabel.TextColor3 = Theme.Muted
            headerLine.BackgroundColor3 = Theme.Border
            refreshPageSections(pageData)
        end
    end)

    return pageData
end

local function createSection(pageData, sectionName)
    local section = create("ScrollingFrame", {
        Name = sectionName,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = UserInputService.TouchEnabled and 4 or 2,
        ScrollBarImageColor3 = Theme.BorderBright,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
        Parent = pageData.SectionContent
    })

    create("UIPadding", {
        PaddingTop = UDim.new(0, 2),
        PaddingBottom = UDim.new(0, 7),
        PaddingLeft = UDim.new(0, 1),
        PaddingRight = UDim.new(0, 3),
        Parent = section
    })

    create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = section
    })

    pageData.Sections[sectionName] = section
    if not pageData.FirstSection then
        pageData.FirstSection = sectionName
        activeSectionByPage[pageData.Name] = sectionName
    end

    local tabWidth = math.clamp(#sectionName * 6 + 25, 76, 142)
    local tab = create("TextButton", {
        Name = "Section_" .. sectionName,
        Size = UDim2.new(0, tabWidth, 0, SECTION_BAR_HEIGHT),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = pageData.SectionBar
    })
    corner(tab, 4)

    local tabLabel = create("TextLabel", {
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.new(1, -16, 1, -2),
        BackgroundTransparency = 1,
        Text = sectionName,
        TextColor3 = Theme.Muted,
        TextSize = 10,
        Font = Enum.Font.GothamSemibold,
        Parent = tab
    })

    local underline = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -1),
        Size = UDim2.new(1, -18, 0, 2),
        BackgroundColor3 = Theme.Text,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = tab
    })
    corner(underline, 2)

    pageData.SectionButtons[sectionName] = {
        Button = tab,
        Label = tabLabel,
        Underline = underline
    }

    tab.Activated:Connect(function()
        selectSection(pageData.Name, sectionName)
    end)

    tab.MouseEnter:Connect(function()
        if activeSectionByPage[pageData.Name] ~= sectionName then
            tab.BackgroundColor3 = Theme.RowHover
            tween(tab, {BackgroundTransparency = 0.35}, 0.08)
            tween(tabLabel, {TextColor3 = Theme.Text}, 0.08)
        end
    end)

    tab.MouseLeave:Connect(function()
        refreshPageSections(pageData)
    end)

    registerThemeRefresh(function()
        if section.Parent then
            section.ScrollBarImageColor3 = Theme.BorderBright
            refreshPageSections(pageData)
        end
    end)

    refreshPageSections(pageData)
    return section
end

local function bindRowHover(buttonObject, row, rowStroke)
    buttonObject.MouseEnter:Connect(function()
        tween(row, {BackgroundColor3 = Theme.RowHover}, 0.08)
        tween(rowStroke, {Color = Theme.Text, Transparency = 0.48}, 0.08)
    end)

    buttonObject.MouseLeave:Connect(function()
        tween(row, {BackgroundColor3 = Theme.Row}, 0.08)
        tween(rowStroke, {Color = Theme.Border, Transparency = 0.38}, 0.08)
    end)
end

local function toggle(parent, name, callback, defaultValue)
    local enabled = defaultValue == true

    local row = create("Frame", {
        Name = "Toggle_" .. tostring(name),
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.Row,
        BorderSizePixel = 0,
        Parent = parent
    })
    corner(row, 3)
    local rowStroke = stroke(row, Theme.Border, 0.38)

    local label = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(9, 0),
        Size = UDim2.new(1, -42, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = tostring(name),
        TextColor3 = Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row
    })

    local box = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(15, 15),
        BackgroundColor3 = Theme.Input,
        BorderSizePixel = 0,
        Parent = row
    })
    corner(box, 2)
    local boxStroke = stroke(box, Theme.BorderBright, 0.15)

    local fill = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(7, 7),
        BackgroundColor3 = Theme.ToggleOn,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = box
    })
    corner(fill, 1)

    local hitbox = create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        AutoButtonColor = false,
        Parent = row
    })

    local function render(instant)
        local duration = instant and 0 or 0.1
        row.BackgroundColor3 = Theme.Row
        rowStroke.Color = Theme.Border
        label.TextColor3 = Theme.Text
        box.BackgroundColor3 = Theme.Input
        fill.BackgroundColor3 = Theme.ToggleOn
        tween(fill, {BackgroundTransparency = enabled and 0 or 1}, duration)
        tween(boxStroke, {Color = enabled and Theme.ToggleOn or Theme.BorderBright}, duration)
    end

    hitbox.Activated:Connect(function()
        enabled = not enabled
        render(false)
        if callback then
            task.spawn(callback, enabled)
        end
    end)

    bindRowHover(hitbox, row, rowStroke)
    registerThemeRefresh(function()
        if row.Parent then
            render(true)
        end
    end)
    render(true)
    return row
end

local function dropdown(parent, name, options, callback, defaultValue)
    local opened = false
    local selected = defaultValue ~= nil and defaultValue or options[1]
    local ROW_HEIGHT = 32
    local OPTION_HEIGHT = 25
    local GAP = 4

    local holder = create("Frame", {
        Name = "Dropdown_" .. tostring(name),
        Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
        BackgroundColor3 = Theme.Row,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = parent
    })
    corner(holder, 3)
    local holderStroke = stroke(holder, Theme.Border, 0.38)

    local label = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(9, 0),
        Size = UDim2.new(0.47, -8, 0, ROW_HEIGHT),
        Font = Enum.Font.GothamSemibold,
        Text = tostring(name),
        TextColor3 = Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = holder
    })

    local valueBox = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -6, 0, ROW_HEIGHT / 2),
        Size = UDim2.new(0.50, -4, 0, 22),
        BackgroundColor3 = Theme.Input,
        BorderSizePixel = 0,
        Parent = holder
    })
    corner(valueBox, 3)
    local valueStroke = stroke(valueBox, Theme.Border, 0.28)

    local valueLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(7, 0),
        Size = UDim2.new(1, -27, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = selected and tostring(selected) or "None",
        TextColor3 = Theme.Muted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = valueBox
    })

    local arrow = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -5, 0.5, 0),
        Size = UDim2.fromOffset(13, 18),
        BackgroundTransparency = 1,
        Text = "v",
        TextColor3 = Theme.Muted,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        Parent = valueBox
    })

    local headerButton = create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
        Text = "",
        AutoButtonColor = false,
        Parent = holder
    })

    local optionsPanel = create("Frame", {
        Position = UDim2.fromOffset(5, ROW_HEIGHT + GAP),
        Size = UDim2.new(1, -10, 0, (#options * OPTION_HEIGHT) + 6),
        BackgroundColor3 = Theme.Input,
        BorderSizePixel = 0,
        Parent = holder
    })
    corner(optionsPanel, 3)
    local panelStroke = stroke(optionsPanel, Theme.Border, 0.22)

    create("UIPadding", {
        PaddingTop = UDim.new(0, 3),
        PaddingBottom = UDim.new(0, 3),
        Parent = optionsPanel
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = optionsPanel
    })

    local optionRows = {}

    local function refreshOptions()
        for option, data in pairs(optionRows) do
            local active = option == selected
            data.Button.BackgroundColor3 = active and Theme.RowHover or Theme.Input
            data.Label.TextColor3 = active and Theme.Text or Theme.Muted
            data.Check.Text = active and "✓" or ""
            data.Check.TextColor3 = Theme.Text
        end
    end

    local function setOpen(value)
        opened = value == true
        arrow.Text = opened and "^" or "v"
        local expandedHeight = ROW_HEIGHT + GAP + (#options * OPTION_HEIGHT) + 10
        tween(holder, {Size = UDim2.new(1, 0, 0, opened and expandedHeight or ROW_HEIGHT)}, 0.12)
    end

    for index, option in ipairs(options) do
        local optionButton = create("TextButton", {
            Name = "Option" .. index,
            Size = UDim2.new(1, 0, 0, OPTION_HEIGHT),
            BackgroundColor3 = Theme.Input,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = optionsPanel
        })

        local optionLabel = create("TextLabel", {
            Position = UDim2.fromOffset(8, 0),
            Size = UDim2.new(1, -34, 1, 0),
            BackgroundTransparency = 1,
            Text = tostring(option),
            TextColor3 = Theme.Muted,
            TextSize = 10,
            Font = Enum.Font.GothamSemibold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = optionButton
        })

        local check = create("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.fromOffset(14, 14),
            BackgroundTransparency = 1,
            Text = "",
            TextColor3 = Theme.Text,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            Parent = optionButton
        })

        optionRows[option] = {Button = optionButton, Label = optionLabel, Check = check}

        optionButton.Activated:Connect(function()
            selected = option
            valueLabel.Text = tostring(option)
            refreshOptions()
            setOpen(false)
            if callback then
                task.spawn(callback, option)
            end
        end)

        optionButton.MouseEnter:Connect(function()
            if selected ~= option then
                tween(optionButton, {BackgroundColor3 = Theme.RowHover}, 0.07)
                tween(optionLabel, {TextColor3 = Theme.Text}, 0.07)
            end
        end)
        optionButton.MouseLeave:Connect(function()
            refreshOptions()
        end)
    end

    headerButton.Activated:Connect(function()
        setOpen(not opened)
    end)
    bindRowHover(headerButton, holder, holderStroke)

    registerThemeRefresh(function()
        if holder.Parent then
            holder.BackgroundColor3 = Theme.Row
            holderStroke.Color = Theme.Border
            label.TextColor3 = Theme.Text
            valueBox.BackgroundColor3 = Theme.Input
            valueStroke.Color = Theme.Border
            valueLabel.TextColor3 = Theme.Muted
            arrow.TextColor3 = Theme.Muted
            optionsPanel.BackgroundColor3 = Theme.Input
            panelStroke.Color = Theme.Border
            refreshOptions()
        end
    end)

    refreshOptions()
    return holder
end

local function multiDropdown(parent, name, options, callback, defaults)
    local opened = false
    local selected = {}
    local optionRows = {}
    local ROW_HEIGHT = 32
    local OPTION_HEIGHT = 25
    local GAP = 4

    if defaults == "All" then
        for _, option in ipairs(options) do
            selected[option] = true
        end
    elseif type(defaults) == "table" then
        for key, value in pairs(defaults) do
            if type(key) == "number" and type(value) == "string" then
                selected[value] = true
            elseif type(key) == "string" and value == true then
                selected[key] = true
            end
        end
    end

    local holder = create("Frame", {
        Name = "MultiDropdown_" .. tostring(name),
        Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
        BackgroundColor3 = Theme.Row,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = parent
    })
    corner(holder, 3)
    local holderStroke = stroke(holder, Theme.Border, 0.38)

    local label = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(9, 0),
        Size = UDim2.new(0.47, -8, 0, ROW_HEIGHT),
        Font = Enum.Font.GothamSemibold,
        Text = tostring(name),
        TextColor3 = Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = holder
    })

    local valueBox = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -6, 0, ROW_HEIGHT / 2),
        Size = UDim2.new(0.50, -4, 0, 22),
        BackgroundColor3 = Theme.Input,
        BorderSizePixel = 0,
        Parent = holder
    })
    corner(valueBox, 3)
    local valueStroke = stroke(valueBox, Theme.Border, 0.28)

    local valueLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(7, 0),
        Size = UDim2.new(1, -27, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = "None",
        TextColor3 = Theme.Muted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = valueBox
    })

    local arrow = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -5, 0.5, 0),
        Size = UDim2.fromOffset(13, 18),
        BackgroundTransparency = 1,
        Text = "v",
        TextColor3 = Theme.Muted,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        Parent = valueBox
    })

    local headerButton = create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
        Text = "",
        AutoButtonColor = false,
        Parent = holder
    })

    local totalRows = #options + 1
    local optionsPanel = create("Frame", {
        Position = UDim2.fromOffset(5, ROW_HEIGHT + GAP),
        Size = UDim2.new(1, -10, 0, (totalRows * OPTION_HEIGHT) + 6),
        BackgroundColor3 = Theme.Input,
        BorderSizePixel = 0,
        Parent = holder
    })
    corner(optionsPanel, 3)
    local panelStroke = stroke(optionsPanel, Theme.Border, 0.22)

    create("UIPadding", {
        PaddingTop = UDim.new(0, 3),
        PaddingBottom = UDim.new(0, 3),
        Parent = optionsPanel
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = optionsPanel
    })

    local function snapshot()
        local values = {}
        for _, option in ipairs(options) do
            if selected[option] then
                table.insert(values, option)
            end
        end
        return values
    end

    local function isAllSelected()
        if #options == 0 then
            return false
        end
        for _, option in ipairs(options) do
            if not selected[option] then
                return false
            end
        end
        return true
    end

    local allRow
    local function refresh()
        local values = snapshot()
        valueLabel.Text = isAllSelected() and "All" or (#values == 0 and "None" or (#values == 1 and tostring(values[1]) or (tostring(#values) .. " selected")))

        if allRow then
            local activeAll = isAllSelected()
            allRow.Button.BackgroundColor3 = activeAll and Theme.RowHover or Theme.Input
            allRow.Label.TextColor3 = activeAll and Theme.Text or Theme.Muted
            allRow.Fill.BackgroundTransparency = activeAll and 0 or 1
            allRow.BoxStroke.Color = activeAll and Theme.ToggleOn or Theme.BorderBright
        end

        for option, data in pairs(optionRows) do
            local active = selected[option] == true
            data.Button.BackgroundColor3 = active and Theme.RowHover or Theme.Input
            data.Label.TextColor3 = active and Theme.Text or Theme.Muted
            data.Fill.BackgroundColor3 = Theme.ToggleOn
            data.Fill.BackgroundTransparency = active and 0 or 1
            data.Box.BackgroundColor3 = Theme.Input
            data.BoxStroke.Color = active and Theme.ToggleOn or Theme.BorderBright
        end
    end

    local function setOpen(value)
        opened = value == true
        arrow.Text = opened and "^" or "v"
        local expandedHeight = ROW_HEIGHT + GAP + (totalRows * OPTION_HEIGHT) + 10
        tween(holder, {Size = UDim2.new(1, 0, 0, opened and expandedHeight or ROW_HEIGHT)}, 0.12)
    end

    local function createCheckRow(text, order, onClick)
        local optionButton = create("TextButton", {
            Name = "Option" .. order,
            LayoutOrder = order,
            Size = UDim2.new(1, 0, 0, OPTION_HEIGHT),
            BackgroundColor3 = Theme.Input,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = optionsPanel
        })

        local optionLabel = create("TextLabel", {
            Position = UDim2.fromOffset(8, 0),
            Size = UDim2.new(1, -38, 1, 0),
            BackgroundTransparency = 1,
            Text = tostring(text),
            TextColor3 = Theme.Muted,
            TextSize = 10,
            Font = Enum.Font.GothamSemibold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = optionButton
        })

        local box = create("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.fromOffset(13, 13),
            BackgroundColor3 = Theme.Input,
            BorderSizePixel = 0,
            Parent = optionButton
        })
        corner(box, 2)
        local boxStroke = stroke(box, Theme.BorderBright, 0.15)

        local fill = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(6, 6),
            BackgroundColor3 = Theme.ToggleOn,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = box
        })
        corner(fill, 1)

        optionButton.Activated:Connect(onClick)
        optionButton.MouseEnter:Connect(function()
            tween(optionButton, {BackgroundColor3 = Theme.RowHover}, 0.07)
            tween(optionLabel, {TextColor3 = Theme.Text}, 0.07)
        end)
        optionButton.MouseLeave:Connect(function()
            refresh()
        end)

        return {
            Button = optionButton,
            Label = optionLabel,
            Box = box,
            BoxStroke = boxStroke,
            Fill = fill
        }
    end

    allRow = createCheckRow("All", 0, function()
        local selectAll = not isAllSelected()
        for _, option in ipairs(options) do
            selected[option] = selectAll or nil
        end
        refresh()
        if callback then
            task.spawn(callback, snapshot(), isAllSelected())
        end
    end)

    for index, option in ipairs(options) do
        optionRows[option] = createCheckRow(option, index, function()
            selected[option] = not selected[option] or nil
            refresh()
            if callback then
                task.spawn(callback, snapshot(), isAllSelected())
            end
        end)
    end

    headerButton.Activated:Connect(function()
        setOpen(not opened)
    end)
    bindRowHover(headerButton, holder, holderStroke)

    registerThemeRefresh(function()
        if holder.Parent then
            holder.BackgroundColor3 = Theme.Row
            holderStroke.Color = Theme.Border
            label.TextColor3 = Theme.Text
            valueBox.BackgroundColor3 = Theme.Input
            valueStroke.Color = Theme.Border
            valueLabel.TextColor3 = Theme.Muted
            arrow.TextColor3 = Theme.Muted
            optionsPanel.BackgroundColor3 = Theme.Input
            panelStroke.Color = Theme.Border
            refresh()
        end
    end)

    refresh()
    return holder
end

local function slider(parent, name, minimum, maximum, defaultValue, step, callback)
    minimum = tonumber(minimum) or 0
    maximum = math.max(tonumber(maximum) or minimum + 1, minimum + 0.0001)
    step = math.max(tonumber(step) or 1, 0.0001)
    local value = math.clamp(tonumber(defaultValue) or minimum, minimum, maximum)
    local dragging = false

    local holder = create("Frame", {
        Name = "Slider_" .. tostring(name),
        Size = UDim2.new(1, 0, 0, 43),
        BackgroundColor3 = Theme.Row,
        BorderSizePixel = 0,
        Parent = parent
    })
    corner(holder, 3)
    local holderStroke = stroke(holder, Theme.Border, 0.35)

    local label = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(9, 0),
        Size = UDim2.new(1, -58, 0, 25),
        Font = Enum.Font.GothamSemibold,
        Text = tostring(name),
        TextColor3 = Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = holder
    })

    local valueLabel = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -9, 0, 0),
        Size = UDim2.fromOffset(48, 25),
        Font = Enum.Font.GothamBold,
        Text = tostring(value),
        TextColor3 = Theme.Muted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = holder
    })

    local bar = create("Frame", {
        Position = UDim2.fromOffset(9, 30),
        Size = UDim2.new(1, -18, 0, 4),
        BackgroundColor3 = Theme.Input,
        BorderSizePixel = 0,
        Parent = holder
    })
    corner(bar, 2)
    local fill = create("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = Theme.ToggleOn,
        BorderSizePixel = 0,
        Parent = bar
    })
    corner(fill, 2)

    local hitbox = create("TextButton", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(5, 23),
        Size = UDim2.new(1, -10, 0, 18),
        Text = "",
        AutoButtonColor = false,
        Parent = holder
    })

    local function render()
        local alpha = (value - minimum) / (maximum - minimum)
        fill.Size = UDim2.fromScale(alpha, 1)
        valueLabel.Text = math.abs(value - math.floor(value + 0.5)) < 0.0001 and tostring(math.floor(value + 0.5)) or string.format("%.2f", value)
    end

    local function setFromX(x, fireCallback)
        local width = math.max(bar.AbsoluteSize.X, 1)
        local alpha = math.clamp((x - bar.AbsolutePosition.X) / width, 0, 1)
        local raw = minimum + (maximum - minimum) * alpha
        value = math.clamp(math.floor((raw - minimum) / step + 0.5) * step + minimum, minimum, maximum)
        render()
        if fireCallback and callback then
            task.spawn(callback, value)
        end
    end

    hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X, true)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X, true)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    registerThemeRefresh(function()
        if holder.Parent then
            holder.BackgroundColor3 = Theme.Row
            holderStroke.Color = Theme.Border
            label.TextColor3 = Theme.Text
            valueLabel.TextColor3 = Theme.Muted
            bar.BackgroundColor3 = Theme.Input
            fill.BackgroundColor3 = Theme.ToggleOn
        end
    end)

    render()
    return holder
end

local function numberBox(parent, name, defaultValue, callback)
    local holder = create("Frame", {
        Name = "NumberBox_" .. tostring(name),
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.Row,
        BorderSizePixel = 0,
        Parent = parent
    })
    corner(holder, 3)
    local holderStroke = stroke(holder, Theme.Border, 0.35)

    local label = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(9, 0),
        Size = UDim2.new(1, -18, 0, 22),
        Font = Enum.Font.GothamSemibold,
        Text = tostring(name),
        TextColor3 = Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = holder
    })

    local box = create("TextBox", {
        Position = UDim2.fromOffset(7, 23),
        Size = UDim2.new(1, -14, 0, 20),
        BackgroundColor3 = Theme.Input,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.GothamSemibold,
        Text = tostring(defaultValue or 0),
        TextColor3 = Theme.Text,
        PlaceholderText = "0",
        PlaceholderColor3 = Theme.Placeholder,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder
    })
    corner(box, 3)

    box.FocusLost:Connect(function()
        local value = tonumber(box.Text) or 0
        box.Text = tostring(value)
        if callback then
            task.spawn(callback, value)
        end
    end)

    registerThemeRefresh(function()
        if holder.Parent then
            holder.BackgroundColor3 = Theme.Row
            holderStroke.Color = Theme.Border
            label.TextColor3 = Theme.Text
            box.BackgroundColor3 = Theme.Input
            box.TextColor3 = Theme.Text
            box.PlaceholderColor3 = Theme.Placeholder
        end
    end)

    return holder
end

local function textBox(parent, name, placeholder, callback)
    local holder = create("Frame", {
        Name = "TextBox_" .. tostring(name),
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.Row,
        BorderSizePixel = 0,
        Parent = parent
    })
    corner(holder, 3)
    local holderStroke = stroke(holder, Theme.Border, 0.35)

    local label = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(9, 0),
        Size = UDim2.new(1, -18, 0, 22),
        Font = Enum.Font.GothamSemibold,
        Text = tostring(name),
        TextColor3 = Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = holder
    })

    local box = create("TextBox", {
        Position = UDim2.fromOffset(7, 23),
        Size = UDim2.new(1, -14, 0, 20),
        BackgroundColor3 = Theme.Input,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = Enum.Font.GothamSemibold,
        Text = "",
        TextColor3 = Theme.Text,
        PlaceholderText = tostring(placeholder or ""),
        PlaceholderColor3 = Theme.Placeholder,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder
    })
    corner(box, 3)

    box.FocusLost:Connect(function()
        if callback then
            task.spawn(callback, box.Text)
        end
    end)

    registerThemeRefresh(function()
        if holder.Parent then
            holder.BackgroundColor3 = Theme.Row
            holderStroke.Color = Theme.Border
            label.TextColor3 = Theme.Text
            box.BackgroundColor3 = Theme.Input
            box.TextColor3 = Theme.Text
            box.PlaceholderColor3 = Theme.Placeholder
        end
    end)

    return holder
end

local function infoCard(parent, text, height, textColor)
    local holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, height or 46),
        BackgroundColor3 = Theme.Row,
        BorderSizePixel = 0,
        Parent = parent
    })
    corner(holder, 3)
    local holderStroke = stroke(holder, Theme.Border, 0.35)

    local label = create("TextLabel", {
        Position = UDim2.fromOffset(9, 0),
        Size = UDim2.new(1, -18, 1, 0),
        BackgroundTransparency = 1,
        Text = tostring(text or ""),
        TextWrapped = true,
        TextColor3 = textColor or Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = holder
    })

    registerThemeRefresh(function()
        if holder.Parent then
            holder.BackgroundColor3 = Theme.Row
            holderStroke.Color = Theme.Border
            if not textColor then
                label.TextColor3 = Theme.Text
            end
        end
    end)

    return label
end


local function featureCard(parent, titleText, items)
    local itemHeight = 18
    local height = 31 + (#items * itemHeight) + 8
    local holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Theme.Row,
        BorderSizePixel = 0,
        Parent = parent
    })
    corner(holder, 4)
    local holderStroke = stroke(holder, Theme.Border, 0.32)

    local titleLabel = create("TextLabel", {
        Position = UDim2.fromOffset(11, 7),
        Size = UDim2.new(1, -22, 0, 17),
        BackgroundTransparency = 1,
        Text = string.upper(tostring(titleText or "FEATURES")),
        TextColor3 = Theme.Muted,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder
    })

    local dots = {}
    local labels = {}
    for index, item in ipairs(items) do
        local y = 29 + ((index - 1) * itemHeight)
        local dot = create("Frame", {
            Position = UDim2.fromOffset(12, y + 6),
            Size = UDim2.fromOffset(4, 4),
            BackgroundColor3 = Theme.Text,
            BorderSizePixel = 0,
            Parent = holder
        })
        corner(dot, 3)
        table.insert(dots, dot)

        local itemLabel = create("TextLabel", {
            Position = UDim2.fromOffset(23, y),
            Size = UDim2.new(1, -34, 0, itemHeight),
            BackgroundTransparency = 1,
            Text = tostring(item),
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamSemibold,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = holder
        })
        table.insert(labels, itemLabel)
    end

    registerThemeRefresh(function()
        if holder.Parent then
            holder.BackgroundColor3 = Theme.Row
            holderStroke.Color = Theme.Border
            titleLabel.TextColor3 = Theme.Muted
            for _, dot in ipairs(dots) do
                dot.BackgroundColor3 = Theme.Text
            end
            for _, itemLabel in ipairs(labels) do
                itemLabel.TextColor3 = Theme.Text
            end
        end
    end)

    return holder
end

local function updateSidebarGeometry(instant)
    local tabbarHeight = TABBAR_HEIGHT
    local sidebarTarget = UDim2.new(1, 0, 0, tabbarHeight)
    local contentPosition = UDim2.fromOffset(CONTENT_GAP, TOPBAR_HEIGHT + tabbarHeight + CONTENT_GAP)
    local contentSize = UDim2.new(1, -(CONTENT_GAP * 2), 1, -(TOPBAR_HEIGHT + tabbarHeight + CONTENT_GAP * 2))

    if instant then
        sidebar.Size = sidebarTarget
        content.Position = contentPosition
        content.Size = contentSize
    else
        tween(sidebar, {Size = sidebarTarget}, 0.14)
        tween(content, {Position = contentPosition, Size = contentSize}, 0.14)
    end

    for _, data in pairs(sideButtons) do
        tween(data.Label, {TextTransparency = 0}, instant and 0 or 0.1)
    end
end

local function applyTheme(name)
    if not ThemePresets[name] then
        return
    end

    currentThemeName = name
    Theme = ThemePresets[name]

    main.BackgroundColor3 = Theme.Background
    main.BackgroundTransparency = 0.12
    mainStroke.Color = Theme.BorderBright
    topbar.BackgroundColor3 = Theme.Topbar
    topbar.BackgroundTransparency = 0.18
    topbarSquareBottom.BackgroundColor3 = Theme.Topbar
    sidebar.BackgroundColor3 = Theme.Sidebar
    sidebarLine.BackgroundColor3 = Theme.Border
    title.TextColor3 = Theme.Text
    subtitle.TextColor3 = Theme.Muted
    topLine.BackgroundColor3 = Theme.Border
    minimizeLine.BackgroundColor3 = Theme.Text
    close.TextColor3 = Theme.Text
    menuButton.TextColor3 = Theme.Muted
    themeCenter.BackgroundColor3 = Theme.Muted

    for _, ray in ipairs(themeRays) do
        ray.BackgroundColor3 = Theme.Muted
    end

    for _, refresh in ipairs(themeRefreshers) do
        pcall(refresh)
    end

    refreshSideTabs()
    for _, pageData in pairs(pages) do
        refreshPageSections(pageData)
    end
end

local function updateResponsiveSize(instant)
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)

    -- ZeHub auto-scaling: preserve the 900x600 design proportions while
    -- fitting inside the current viewport with safe margins.
    local scaleX = (viewport.X * 0.88) / BASE_WIDTH
    local scaleY = (viewport.Y * 0.84) / BASE_HEIGHT
    local targetScale = math.clamp(math.min(scaleX, scaleY), 0.58, 1.35)

    local function applyScale()
        responsiveScale.Scale = targetScale
        if minimized then
            main.Size = UDim2.fromOffset(BASE_WIDTH, TOPBAR_HEIGHT)
        else
            main.Size = UDim2.fromOffset(BASE_WIDTH, BASE_HEIGHT)
        end
        updateSidebarGeometry(true)
    end

    if instant then
        applyScale()
    else
        responsiveScale.Scale = targetScale
        tween(main, {Size = minimized and UDim2.fromOffset(BASE_WIDTH, TOPBAR_HEIGHT) or UDim2.fromOffset(BASE_WIDTH, BASE_HEIGHT)}, 0.14)
        updateSidebarGeometry(false)
    end
end

local function setMinimized(value)
    minimized = value == true
    sidebar.Visible = not minimized
    content.Visible = not minimized
    updateResponsiveSize(false)
end

menuButton.Activated:Connect(function()
    sidebarExpanded = not sidebarExpanded
    updateSidebarGeometry(true)
end)

menuButton.MouseEnter:Connect(function()
    tween(menuButton, {TextColor3 = Theme.Text}, 0.08)
end)

menuButton.MouseLeave:Connect(function()
    tween(menuButton, {TextColor3 = Theme.Muted}, 0.08)
end)

themeButton.Activated:Connect(function()
    applyTheme(currentThemeName == "Dark" and "Light" or "Dark")
end)

themeButton.MouseEnter:Connect(function()
    themeCenter.BackgroundColor3 = Theme.Text
    for _, ray in ipairs(themeRays) do
        ray.BackgroundColor3 = Theme.Text
    end
end)

themeButton.MouseLeave:Connect(function()
    themeCenter.BackgroundColor3 = Theme.Muted
    for _, ray in ipairs(themeRays) do
        ray.BackgroundColor3 = Theme.Muted
    end
end)

minimizeButton.Activated:Connect(function()
    setMinimized(not minimized)
end)

minimizeButton.MouseEnter:Connect(function()
    tween(minimizeLine, {BackgroundColor3 = Theme.Muted}, 0.08)
end)

minimizeButton.MouseLeave:Connect(function()
    tween(minimizeLine, {BackgroundColor3 = Theme.Text}, 0.08)
end)

close.MouseEnter:Connect(function()
    tween(close, {TextColor3 = Color3.fromRGB(255, 100, 100)}, 0.08)
end)

close.MouseLeave:Connect(function()
    tween(close, {TextColor3 = Theme.Text}, 0.08)
end)

close.Activated:Connect(function()
    guiAlive = false
    gui:Destroy()
end)

local camera = workspace.CurrentCamera
if camera then
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        updateResponsiveSize(true)
    end)
end

applyTheme("Dark")
updateResponsiveSize(true)


local function actionButton(parent, name, callback)
    local row = create("Frame", {
        Name = "Button_" .. tostring(name),
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Row,
        BorderSizePixel = 0,
        Parent = parent
    })
    corner(row, 3)
    local rowStroke = stroke(row, Theme.Border, 0.38)

    local label = create("TextLabel", {
        Position = UDim2.fromOffset(9, 0),
        Size = UDim2.new(1, -34, 1, 0),
        BackgroundTransparency = 1,
        Text = tostring(name),
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row
    })

    local arrow = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -9, 0.5, 0),
        Size = UDim2.fromOffset(14, 18),
        BackgroundTransparency = 1,
        Text = ">",
        TextColor3 = Theme.Muted,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        Parent = row
    })

    local hitbox = create("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = row
    })

    hitbox.Activated:Connect(function()
        tween(row, {BackgroundColor3 = Theme.RowHover}, 0.06)
        task.delay(0.08, function()
            if row.Parent then
                tween(row, {BackgroundColor3 = Theme.Row}, 0.08)
            end
        end)
        if callback then
            task.spawn(callback)
        end
    end)

    bindRowHover(hitbox, row, rowStroke)

    registerThemeRefresh(function()
        if row.Parent then
            row.BackgroundColor3 = Theme.Row
            rowStroke.Color = Theme.Border
            label.TextColor3 = Theme.Text
            arrow.TextColor3 = Theme.Muted
        end
    end)

    return row
end

local function spacer(parent, height)
    return create("Frame", {
        Name = "Spacer",
        Size = UDim2.new(1, 0, 0, math.max(0, tonumber(height) or 6)),
        BackgroundTransparency = 1,
        Parent = parent
    })
end


local windowDragging = false
local windowDragStart = nil
local windowStartPosition = nil

topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        windowDragging = true
        windowDragStart = input.Position
        windowStartPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if windowDragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - windowDragStart
        main.Position = UDim2.new(
            windowStartPosition.X.Scale,
            windowStartPosition.X.Offset + delta.X,
            windowStartPosition.Y.Scale,
            windowStartPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        windowDragging = false
    end
end)


local Library = {
    Version = "1.0.0",
    Themes = {"Dark", "Light"},
    Icons = {
        "Home",
        "Farm",
        "Events",
        "Pets",
        "Stats",
        "Gift",
        "Eye",
        "Settings"
    }
}

local WindowMethods = {}
WindowMethods.__index = WindowMethods

local TabMethods = {}
TabMethods.__index = TabMethods

local SectionMethods = {}
SectionMethods.__index = SectionMethods

local function normalizeConfig(value, fallbackName)
    if type(value) == "table" then
        return value
    end
    return {Name = value ~= nil and tostring(value) or fallbackName}
end

function Library:CreateWindow(config)
    config = type(config) == "table" and config or {}

    if self._window and self._window._alive then
        self._window:SetTitle(config.Title or config.Name, config.Subtitle)
        if config.Theme then
            self._window:SetTheme(config.Theme)
        end
        gui.Enabled = true
        return self._window
    end

    BASE_WIDTH = math.max(330, tonumber(config.Width) or 500)
    BASE_HEIGHT = math.max(300, tonumber(config.Height) or 430)

    title.Text = tostring(config.Title or config.Name or "ZeHub")
    subtitle.Text = tostring(config.Subtitle or "UI Library")

    if typeof(config.Position) == "UDim2" then
        main.Position = config.Position
    end

    themeButton.Visible = config.ThemeButton ~= false
    minimizeButton.Visible = config.MinimizeButton ~= false
    close.Visible = config.CloseButton ~= false

    local window = setmetatable({
        _alive = true,
        _tabs = {},
        Gui = gui,
        Main = main
    }, WindowMethods)

    self._window = window
    gui.Enabled = true

    applyTheme(ThemePresets[config.Theme] and config.Theme or "Dark")
    updateResponsiveSize(true)

    return window
end

function WindowMethods:SetTitle(newTitle, newSubtitle)
    if newTitle ~= nil then
        title.Text = tostring(newTitle)
    end
    if newSubtitle ~= nil then
        subtitle.Text = tostring(newSubtitle)
    end
    return self
end

function WindowMethods:SetTheme(themeName)
    if ThemePresets[themeName] then
        applyTheme(themeName)
    end
    return self
end

function WindowMethods:ToggleTheme()
    applyTheme(currentThemeName == "Dark" and "Light" or "Dark")
    return self
end

function WindowMethods:SetMinimized(value)
    setMinimized(value)
    return self
end

function WindowMethods:SetSidebarExpanded(value)
    sidebarExpanded = value == true
    updateSidebarGeometry(false)
    return self
end

function WindowMethods:SelectTab(name)
    selectPage(tostring(name))
    return self
end

function WindowMethods:CreateTab(config)
    config = normalizeConfig(config, "Tab")
    local name = tostring(config.Name or "Tab")
    local icon = config.Icon or config.IconType or name

    if self._tabs[name] then
        return self._tabs[name]
    end

    local pageData = createPage(name, icon)
    local tab = setmetatable({
        Name = name,
        _page = pageData,
        _sections = {},
        Window = self
    }, TabMethods)

    self._tabs[name] = tab

    if not activePageName then
        selectPage(name)
    end

    return tab
end

function WindowMethods:Destroy()
    if not self._alive then
        return
    end
    self._alive = false
    guiAlive = false
    if gui and gui.Parent then
        gui:Destroy()
    end
end

function TabMethods:Select()
    selectPage(self.Name)
    return self
end

function TabMethods:CreateSection(config)
    config = normalizeConfig(config, "Section")
    local name = tostring(config.Name or "Section")

    if self._sections[name] then
        return self._sections[name]
    end

    local root = createSection(self._page, name)
    local section = setmetatable({
        Name = name,
        Root = root,
        Tab = self
    }, SectionMethods)

    self._sections[name] = section
    return section
end

function SectionMethods:CreateToggle(config)
    config = normalizeConfig(config, "Toggle")
    return toggle(
        self.Root,
        config.Name or "Toggle",
        config.Callback,
        config.Default
    )
end

function SectionMethods:CreateButton(config)
    config = normalizeConfig(config, "Button")
    return actionButton(
        self.Root,
        config.Name or "Button",
        config.Callback
    )
end

function SectionMethods:CreateDropdown(config)
    config = normalizeConfig(config, "Dropdown")
    return dropdown(
        self.Root,
        config.Name or "Dropdown",
        config.Options or config.Values or {},
        config.Callback,
        config.Default
    )
end

function SectionMethods:CreateMultiDropdown(config)
    config = normalizeConfig(config, "Multi Dropdown")
    return multiDropdown(
        self.Root,
        config.Name or "Multi Dropdown",
        config.Options or config.Values or {},
        config.Callback,
        config.Default or config.Defaults
    )
end

function SectionMethods:CreateSlider(config)
    config = normalizeConfig(config, "Slider")
    return slider(
        self.Root,
        config.Name or "Slider",
        config.Min or config.Minimum or 0,
        config.Max or config.Maximum or 100,
        config.Default or config.Value or 0,
        config.Step or 1,
        config.Callback
    )
end

function SectionMethods:CreateNumberBox(config)
    config = normalizeConfig(config, "Number")
    return numberBox(
        self.Root,
        config.Name or "Number",
        config.Default or config.Value or 0,
        config.Callback
    )
end

function SectionMethods:CreateInput(config)
    config = normalizeConfig(config, "Input")
    return textBox(
        self.Root,
        config.Name or "Input",
        config.Placeholder or "",
        config.Callback
    )
end

SectionMethods.CreateTextBox = SectionMethods.CreateInput

function SectionMethods:CreateParagraph(config)
    if type(config) ~= "table" then
        config = {Text = tostring(config or "")}
    end
    return infoCard(
        self.Root,
        config.Text or config.Content or "",
        config.Height or 46,
        config.TextColor
    )
end

SectionMethods.CreateInfo = SectionMethods.CreateParagraph
SectionMethods.CreateLabel = SectionMethods.CreateParagraph

function SectionMethods:CreateFeatureCard(config)
    config = type(config) == "table" and config or {}
    return featureCard(
        self.Root,
        config.Title or config.Name or "Features",
        config.Items or {}
    )
end

function SectionMethods:CreateSpacer(height)
    return spacer(self.Root, height)
end

WindowMethods.AddTab = WindowMethods.CreateTab
TabMethods.AddSection = TabMethods.CreateSection
SectionMethods.AddToggle = SectionMethods.CreateToggle
SectionMethods.AddButton = SectionMethods.CreateButton
SectionMethods.AddDropdown = SectionMethods.CreateDropdown
SectionMethods.AddMultiDropdown = SectionMethods.CreateMultiDropdown
SectionMethods.AddSlider = SectionMethods.CreateSlider
SectionMethods.AddNumberBox = SectionMethods.CreateNumberBox
SectionMethods.AddInput = SectionMethods.CreateInput
SectionMethods.AddParagraph = SectionMethods.CreateParagraph
SectionMethods.AddFeatureCard = SectionMethods.CreateFeatureCard



-- [ 6 ] HELPERS
-- ============================================================================
function utility:GetLocalHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

function utility:GetLocalHum()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

function utility:init()
    self.NPCs = Workspace:FindFirstChild("NPCs")
    self.FlowClient = ReplicatedStorage:FindFirstChild("FlowClient")
    if self.FlowClient then
        self.ClientRunner = self.FlowClient:FindFirstChild("ClientRunner")
        if self.ClientRunner then
            self.Event = self.ClientRunner:FindFirstChild("Event")
        end
    end
end
utility:init()

-- ============================================================================
-- [ 7 ] ESP
-- ============================================================================
local ESP_COLORS = {
    Loot = Color3.fromRGB(0,255,100), Building = Color3.fromRGB(0,150,255),
    Money = Color3.fromRGB(255,215,0), NPC = Color3.fromRGB(255,0,0),
    Vehicle = Color3.fromRGB(255,0,255)
}

function utility:CreateESP(inst, colorKey)
    if not inst or self.espHighlights[inst] then return end
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_"..colorKey
    hl.FillColor = ESP_COLORS[colorKey] or Color3.new(1,1,1)
    hl.OutlineColor = Color3.fromRGB(255,255,255)
    hl.FillTransparency = 0.55
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = inst
    hl.Parent = inst
    self.espHighlights[inst] = hl
end

function utility:DestroyESP(inst)
    if self.espHighlights[inst] then
        if self.espHighlights[inst].Parent then self.espHighlights[inst]:Destroy() end
        self.espHighlights[inst] = nil
    end
end

function utility:ClearESPByColor(colorKey)
    for inst, hl in pairs(self.espHighlights) do
        if hl and hl.Name == "ESP_"..colorKey then self:DestroyESP(inst) end
    end
end

function utility:StartContainerESP(container, colorKey, filterFn, connKey)
    if self.espConns[connKey] then self.espConns[connKey]:Disconnect() end
    local function process()
        if not container or not container.Parent then return end
        for _, item in ipairs(container:GetChildren()) do
            if not filterFn or filterFn(item) then self:CreateESP(item, colorKey) end
        end
    end
    process()
    self.espConns[connKey] = RunService.Heartbeat:Connect(function()
        process()
        for inst, hl in pairs(self.espHighlights) do
            if hl and hl.Name == "ESP_"..colorKey and not inst.Parent then self:DestroyESP(inst) end
        end
    end)
end

function utility:ToggleLootESP(s)
    if not s then
        self:ClearESPByColor("Loot")
        if self.espConns["Loot"] then self.espConns["Loot"]:Disconnect(); self.espConns["Loot"]=nil end
        return
    end
    local L = Workspace:FindFirstChild("Loot")
    if not L then return end
    self:StartContainerESP(L, "Loot", function(i) return i:IsA("Model") end, "Loot")
end

function utility:ToggleBuildingESP(s)
    if s then
        local map = Workspace:FindFirstChild("Map")
        local b = map and map:FindFirstChild("Buildings")
        if not b then return end
        self:StartContainerESP(b, "Building", function(i) return i:IsA("Model") or i:IsA("BasePart") end, "Building")
    else
        self:ClearESPByColor("Building")
        if self.espConns["Building"] then self.espConns["Building"]:Disconnect(); self.espConns["Building"]=nil end
    end
end

local MONEY_TARGET_NAMES = {"ATM", "CashRegister", "MailBox", "Register", "Vault", "Cash"}

local function IsMoneyTarget(inst)
    if not inst then return false end
    for _, n in ipairs(MONEY_TARGET_NAMES) do
        if inst.Name:find(n, 1, true) then return true end
    end
    return false
end

function utility:ToggleMoneyESP(s)
    if not s then
        for key, conn in pairs(self.espConns) do
            if key:sub(1, 6) == "Money_" then
                conn:Disconnect()
                self.espConns[key] = nil
            end
        end
        self:ClearESPByColor("Money")
        return
    end

    local cash = Workspace:FindFirstChild("Cash")
    if cash then
        self:StartContainerESP(cash, "Money",
            function(i) return i:IsA("Model") or i:IsA("BasePart") end,
            "Money_Cash")
    end

    local function processSources()
        for _, d in ipairs(Workspace:GetDescendants()) do
            if IsMoneyTarget(d) and (d:IsA("Model") or d:IsA("BasePart")) then
                if not d:FindFirstAncestorOfClass("Tool") then
                    local parentMarked = false
                    local p = d.Parent
                    while p and p ~= Workspace do
                        if self.espHighlights[p] then parentMarked = true; break end
                        p = p.Parent
                    end
                    if not parentMarked then
                        self:CreateESP(d, "Money")
                    end
                end
            end
        end
    end

    processSources()
    self.espConns["Money_Sources"] = RunService.Heartbeat:Connect(function()
        if not Config.moneyEsp then return end
        processSources()
        for inst, hl in pairs(self.espHighlights) do
            if hl and hl.Name == "ESP_Money" and not inst.Parent then
                self:DestroyESP(inst)
            end
        end
    end)
end

function utility:ToggleNPCESP(s)
    if s then
        local n = Workspace:FindFirstChild("NPCs")
        if not n then return end
        self:StartContainerESP(n, "NPC", function(i) return i:IsA("Model") and i:FindFirstChildOfClass("Humanoid") end, "NPC")
    else
        self:ClearESPByColor("NPC")
        if self.espConns["NPC"] then self.espConns["NPC"]:Disconnect(); self.espConns["NPC"]=nil end
    end
end

function utility:ToggleVehicleESP(s)
    if s then
        local v = Workspace:FindFirstChild("Vehicles")
        if not v then return end
        self:StartContainerESP(v, "Vehicle", function(i) return i:IsA("Model") end, "Vehicle")
    else
        self:ClearESPByColor("Vehicle")
        if self.espConns["Vehicle"] then self.espConns["Vehicle"]:Disconnect(); self.espConns["Vehicle"]=nil end
    end
end

-- ============================================================================
-- [ 8 ] KILL AURA
-- ============================================================================
function utility:GetNPCsInRange(range)
    local list, hrp = {}, self:GetLocalHRP()
    if not hrp then return list end
    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return list end
    local myPos = hrp.Position
    for _, npc in ipairs(npcs:GetChildren()) do
        local hum = npc:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            local ok, pivot = pcall(function() return npc:GetPivot().Position end)
            if ok and pivot and (myPos - pivot).Magnitude <= range then
                table.insert(list, hum)
            end
        end
    end
    return list
end

function utility:DamageNPC(hum)
    pcall(function()
        if self.Event then
            self.Event:FireServer("NPCs", "Damage", hum, Config.killAuraDamage)
        end
    end)
end

function utility:StartKillAuraLoop()
    if self.auraConn then self.auraConn:Disconnect() end
    self.auraTick = 0
    self.auraConn = RunService.Heartbeat:Connect(function()
        if tick() - self.auraTick < 1 then return end
        self.auraTick = tick()
        if Config.killAura then
            for _, hum in ipairs(self:GetNPCsInRange(Config.killAuraRange)) do
                self:DamageNPC(hum)
            end
        end
    end)
end
utility:StartKillAuraLoop()

-- ============================================================================
-- [ 9 ] AIMBOT
-- ============================================================================
function utility:FindAimbotTarget()
    local hrp = self:GetLocalHRP()
    if not hrp then return nil end
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local screenCenter = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local fov = Config.aimbotFov
    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return nil end
    local best, bestDist = nil, math.huge
    for _, npc in ipairs(npcs:GetChildren()) do
        local hum = npc:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            local limb = npc:FindFirstChild(Config.aimbotLimb) or hum.RootPart
            if limb and limb:IsA("BasePart") then
                local sp, on = cam:WorldToViewportPoint(limb.Position)
                if on then
                    local d = (Vector2.new(sp.X, sp.Y) - screenCenter).Magnitude
                    if d <= fov and d < bestDist then bestDist, best = d, limb end
                end
            end
        end
    end
    return best
end

function utility:StartAimbotLoop()
    if self.aimbotConn then self.aimbotConn:Disconnect() end
    if self.aimbotInputBegan then self.aimbotInputBegan:Disconnect() end
    if self.aimbotInputEnded then self.aimbotInputEnded:Disconnect() end
    self.aimbotInputBegan = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then self.aimbotHolding = true end
    end)
    self.aimbotInputEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then self.aimbotHolding = false end
    end)
    self.aimbotConn = RunService.RenderStepped:Connect(function(dt)
        if not Config.aimbot then return end
        if not self.aimbotHolding then return end
        local target = self:FindAimbotTarget()
        if not target then return end
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local currentCF = cam.CFrame
        local desiredCF = CFrame.new(currentCF.Position, target.Position)
        local s = Config.aimbotSmoothness
        if s <= 1 then cam.CFrame = desiredCF
        else cam.CFrame = currentCF:Lerp(desiredCF, math.clamp(dt * (10/s), 0, 1)) end
    end)
end
utility:StartAimbotLoop()

-- ============================================================================
-- [ 10 ] INFINITE AMMO
-- ============================================================================
function utility:StartInfiniteAmmo()
    if self.ammoConn then self.ammoConn:Disconnect() end
    self.ammoConn = RunService.Heartbeat:Connect(function()
        if not Config.infiniteAmmo then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then
                pcall(function() t:SetAttribute("Ammo", Config.infiniteAmmoAmount) end)
            end
        end
    end)
end
utility:StartInfiniteAmmo()

-- ============================================================================
-- [ 11 ] VEHICLE
-- ============================================================================
function utility:StartVehicleLoop()
    if self.vehicleConn then self.vehicleConn:Disconnect() end
    self.vehicleConn = RunService.Heartbeat:Connect(function()
        local vehicles = Workspace:FindFirstChild("Vehicles")
        if not vehicles then return end
        for _, cm in ipairs(vehicles:GetChildren()) do
            if cm:IsA("Model") then
                if Config.infiniteFuel then
                    local gas = cm:FindFirstChild("gasLevel")
                    if gas then pcall(function() gas.Value = 1 end) end
                end
                local prop = cm:FindFirstChild("VehicleProperty")
                if prop then
                    if Config.vehicleAccel then
                        pcall(function() prop:SetAttribute("Acceleration", Config.vehicleAccel) end)
                    end
                    if Config.vehicleTopSpeed then
                        pcall(function() prop:SetAttribute("TopSpeedMPH", Config.vehicleTopSpeed) end)
                    end
                end
            end
        end
    end)
end
utility:StartVehicleLoop()

-- ============================================================================
-- [ 12 ] TELEPORT TO NEXT LOOT
-- ============================================================================
function utility:TeleportToNextLoot()
    local hrp = self:GetLocalHRP()
    if not hrp then return end
    local L = Workspace:FindFirstChild("Loot")
    if not L then return end
    local myPos = hrp.Position
    local best, bestDist = nil, math.huge
    for _, item in ipairs(L:GetChildren()) do
        if item:IsA("Model") and item.PrimaryPart then
            local d = (myPos - item.PrimaryPart.Position).Magnitude
            if d < bestDist then bestDist, best = d, item end
        end
    end
    if best and best.PrimaryPart then
        self:TeleportTo(best.PrimaryPart.Position + Vector3.new(0, 3, 0))
    end
end

-- ============================================================================
-- [ 13 ] AUTO ESCAPE
-- ============================================================================
function utility:StartAutoEscape()
    local hrp = self:GetLocalHRP()
    if not hrp then return end
    task.spawn(function()
        local x, y0, z0, z1 = 518.1, 3503, -15721.9, 83568.8
        local step = 100
        local waitPerStep = 0.05

        pcall(function() hrp.CFrame = CFrame.new(x, y0, z0) end)
        task.wait(0.2)

        local z = z0
        while z < z1 do
            z = math.min(z + step, z1)
            local y = y0 - (z - z0) * 0.00001
            pcall(function() hrp.CFrame = CFrame.new(x, y, z) end)
            task.wait(waitPerStep)
        end

        local MEXICO = Vector3.new(-346.26, 3224.43, 83628.91)
        local overMexico = Vector3.new(MEXICO.X, MEXICO.Y + 300, MEXICO.Z)
        pcall(function() hrp.CFrame = CFrame.new(overMexico) end)
        task.wait(1.5)

        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.CFrame = CFrame.new(overMexico)
        end)

        local startFall = tick()
        while tick() - startFall < 6 do
            local hum = self:GetLocalHum()
            if hum and hum.FloorMaterial ~= Enum.Material.Air then
                break
            end
            task.wait(0.1)
        end
    end)
end

-- ============================================================================
-- [ 14 ] DROP ALL 
-- ============================================================================
local function FindTouchDropButton()
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not pg then return nil end

    local found = nil
    local function search(container, depth)
        if depth > 6 then return end
        for _, c in ipairs(container:GetChildren()) do
            if c.Name == "Drop" and (c:IsA("GuiButton") or c:IsA("ImageButton") or c:IsA("TextButton")) then
                found = c
                return
            end
            if #c:GetChildren() > 0 then
                search(c, depth + 1)
            end
            if found then return end
        end
    end

    local hud = pg:FindFirstChild("HudGui")
    if hud then
        local tc = hud:FindFirstChild("TouchControl")
        if tc then
            local d = tc:FindFirstChild("Drop")
            if d then return d end
        end
        local ctx = hud:FindFirstChild("Context")
        if ctx then
            local actions = ctx:FindFirstChild("Actions")
            if actions then
                local d = actions:FindFirstChild("Drop")
                if d then return d end
            end
        end
    end

    search(pg, 0)
    return found
end

local function ClickGuiButton(btn)
    if not btn then return false end
    pcall(function()
        if btn:IsA("GuiButton") then
            btn:Activate()
        end
    end)
    return true
end

function utility:DropAllLootSequential()
    task.spawn(function()
        local plr = LocalPlayer
        local char = plr.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        if isMobile then
            local dropBtn = FindTouchDropButton()
            if not dropBtn then
                warn("[Drop All] Kein Drop-Button gefunden!")
                return
            end
            local function dropFrom(container)
                if not container then return end
                for _, tool in ipairs(container:GetChildren()) do
                    if tool:IsA("Tool") then
                        if tool.Parent ~= char then
                            pcall(function() hum:EquipTool(tool) end)
                            task.wait(0.15)
                        end
                        ClickGuiButton(dropBtn)
                        task.wait(0.25)
                    end
                end
            end
            dropFrom(plr:FindFirstChild("Backpack"))
            dropFrom(char)
        else
            local function dropFrom(container)
                if not container then return end
                for _, tool in ipairs(container:GetChildren()) do
                    if tool:IsA("Tool") then
                        if tool.Parent ~= char then
                            pcall(function() hum:EquipTool(tool) end)
                            task.wait(0.15)
                        end
                        pcall(function()
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.X, false, game)
                            task.wait(0.05)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.X, false, game)
                        end)
                        task.wait(0.18)
                    end
                end
            end
            dropFrom(plr:FindFirstChild("Backpack"))
            dropFrom(char)
        end
    end)
end

-- ============================================================================
-- [ 15 ] TELEPORTS
-- ============================================================================
local OWNED_VEHICLE_NAMES = {
    "Claptima", "Chunkmover", "GR8R", "Mudrunner", "Charged",
    "Fastbacker", "T1000", "T-1000", "Reventador",
    "FloppyTruck", "Floppy Truck", "GTruck", "G-Truck",
}

local function NormalizeName(s)
    if not s then return "" end
    s = s:lower()
    s = s:gsub("[%s%-_]", "")
    return s
end

local function MatchesVehicleName(vehicleName)
    local normV = NormalizeName(vehicleName)
    for _, n in ipairs(OWNED_VEHICLE_NAMES) do
        local normN = NormalizeName(n)
        if normV == normN or normV:find(normN, 1, true) or normN:find(normV, 1, true) then
            return true, n
        end
    end
    return false, nil
end

function utility:TeleportTo(pos)
    local hrp = self:GetLocalHRP()
    if not hrp then return end
    Config.previousPosition = hrp.CFrame
    pcall(function() hrp.CFrame = CFrame.new(pos) end)
end

function utility:FindClosestBuilding(name)
    local map = Workspace:FindFirstChild("Map")
    local buildings = map and map:FindFirstChild("Buildings")
    if not buildings then return nil end
    local hrp = self:GetLocalHRP()
    if not hrp then return nil end
    local myPos = hrp.Position
    local best, bestDist = nil, math.huge
    for _, b in ipairs(buildings:GetChildren()) do
        if b.Name == name then
            local ok, pivot = pcall(function() return b:GetPivot().Position end)
            if ok and pivot then
                local d = (myPos - pivot).Magnitude
                if d < bestDist then bestDist, best = d, b end
            end
        end
    end
    return best
end

function utility:TeleportToPawnShop()
    local ps = self:FindClosestBuilding("PawnShop")
    if not ps then return end
    local bell
    for _, d in ipairs(ps:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.ActionText == "Add item to sell" then bell = d.Parent; break end
    end
    local target = bell and bell.Position or ps:GetPivot().Position
    self:TeleportTo(target + Vector3.new(0, 3, 0))
end

function utility:TeleportToGasStation()
    local gs = self:FindClosestBuilding("GasStation")
    if not gs then return end
    self:TeleportTo(gs:GetPivot().Position + Vector3.new(0, 5, 0))
end

function utility:TeleportToStart()
    local spawn = Workspace:FindFirstChild("SpawnLocation")
    if not spawn then return end
    self:TeleportTo(spawn.Position + Vector3.new(0, 5, 0))
end

function utility:TeleportToMyVehicle()
    local vehicles = Workspace:FindFirstChild("Vehicles")
    if not vehicles then return end
    local hum = self:GetLocalHum()
    if hum and hum.SeatPart then
        local veh = hum.SeatPart:FindFirstAncestorOfClass("Model")
        if veh then self:TeleportTo(veh:GetPivot().Position + Vector3.new(0, 5, 0)); return end
    end
    for _, v in ipairs(vehicles:GetChildren()) do
        if v:IsA("Model") and MatchesVehicleName(v.Name) then
            self:TeleportTo(v:GetPivot().Position + Vector3.new(0, 5, 0))
            return
        end
    end
end

function utility:SavePosition()
    local hrp = self:GetLocalHRP()
    if not hrp then return end
    Config.savedPosition = hrp.CFrame
end

function utility:LoadPosition()
    if not Config.savedPosition then return end
    self:TeleportTo(Config.savedPosition.Position)
end

function utility:PreviousPosition()
    if not Config.previousPosition then return end
    local hrp = self:GetLocalHRP()
    if not hrp then return end
    local cur = hrp.CFrame
    hrp.CFrame = Config.previousPosition
    Config.previousPosition = cur
end

function utility:StartPositionTracker()
    if self.posTrackerConn then self.posTrackerConn:Disconnect() end
    self.lastPos = nil
    self.posTrackerConn = RunService.Heartbeat:Connect(function()
        local hrp = self:GetLocalHRP()
        if not hrp then return end
        if self.lastPos and (hrp.Position - self.lastPos).Magnitude > 50 then
            Config.previousPosition = CFrame.new(self.lastPos)
        end
        self.lastPos = hrp.Position
    end)
end
utility:StartPositionTracker()

-- ============================================================================
-- [ 16 ] PLAYER
-- ============================================================================
function utility:StartPlayerLoop()
    if self.playerConn then self.playerConn:Disconnect() end
    self.playerConn = RunService.Heartbeat:Connect(function()
        local hum = self:GetLocalHum()
        if not hum then return end
        if Config.walkSpeedEnabled then
            if Config.walkSpeed ~= hum.WalkSpeed then hum.WalkSpeed = Config.walkSpeed end
        end
        if Config.jumpPowerEnabled then
            if not hum.UseJumpPower then hum.UseJumpPower = true end
            if Config.jumpPower ~= hum.JumpPower then hum.JumpPower = Config.jumpPower end
        end
    end)
end
utility:StartPlayerLoop()

UserInputService.JumpRequest:Connect(function()
    if not Config.infiniteJump then return end
    local hum = utility:GetLocalHum()
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

function utility:StartNoclipLoop()
    if self.noclipConn then self.noclipConn:Disconnect() end
    if self.noclipPropertyConns then
        for _, c in ipairs(self.noclipPropertyConns) do pcall(function() c:Disconnect() end) end
    end
    self.noclipPropertyConns = {}

    local function hookCharacter(char)
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                if Config.noclip and p.CanCollide then
                    p.CanCollide = false
                end
                local conn = p:GetPropertyChangedSignal("CanCollide"):Connect(function()
                    if Config.noclip and p.CanCollide then
                        p.CanCollide = false
                    end
                end)
                table.insert(self.noclipPropertyConns, conn)
            end
        end
        local childConn = char.DescendantAdded:Connect(function(d)
            if d:IsA("BasePart") and Config.noclip then
                d.CanCollide = false
            end
        end)
        table.insert(self.noclipPropertyConns, childConn)
    end

    self.noclipConn = RunService.Stepped:Connect(function()
        if not Config.noclip then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                p.CanCollide = false
            end
        end
    end)

    if LocalPlayer.Character then hookCharacter(LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(function(c)
        task.wait(0.5)
        hookCharacter(c)
    end)
end
utility:StartNoclipLoop()

-- ============================================================================

-- ============================================================================


-- ============================================================================
-- ZEHub UI - USING THE REPLACEMENT LIBRARY
-- ============================================================================
local Window = Library:CreateWindow({
    Title = "ZeHub",
    Subtitle = "ZeHub Access • Runaways",
    Width = 900,
    Height = 600,
    Theme = "Dark",
    MinimizeButton = true,
    ThemeButton = true,
    CloseButton = true
})

-- ZeHub loader navigation: exactly two top-level tabs.
local KeyTab = Window:CreateTab({Name = "Key", Icon = "Settings"})
local KeyedScriptsTab = Window:CreateTab({Name = "Keyed Scripts", Icon = "Home"})

-- Existing Runaways controls remain available under the Keyed Scripts tab.
local MainTab = KeyedScriptsTab
local FireTab = KeyedScriptsTab
local VehTab = KeyedScriptsTab
local EspTab = KeyedScriptsTab
local TpTab = KeyedScriptsTab
local PlayerTab = KeyedScriptsTab

local currentKey = ""
local KeyStatusLabel

local function copyText(value)
    if type(setclipboard) == "function" then
        return pcall(setclipboard, value)
    elseif type(toclipboard) == "function" then
        return pcall(toclipboard, value)
    end
    return false
end

local function setStatus(text)
    if KeyStatusLabel then
        KeyStatusLabel.Text = tostring(text)
    end
end

local KeySection = KeyTab:CreateSection({Name = "ZEHUB ACCESS"})
KeySection:CreateParagraph({
    Text = "Enter your ZeHub / FlowAuth key below, then use LOAD SCRIPT. GET KEY copies the current FlowAuth access page.",
    Height = 58
})
KeySection:CreateInput({
    Name = "KEY / AUTH TOKEN",
    Placeholder = "Paste your key here...",
    Callback = function(value)
        currentKey = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if currentKey == "" then
            setStatus("Status: waiting for key")
        else
            setStatus("Status: key entered — ready to load")
        end
    end
})
KeySection:CreateButton({
    Name = "GET KEY",
    Callback = function()
        local copied = copyText(FLOWAUTH_UI_URL)
        if copied then
            setStatus("Status: FlowAuth access link copied")
        else
            setStatus("Status: copy unavailable — use the FlowAuth link from your dashboard")
        end
    end
})
KeySection:CreateButton({
    Name = "LOAD SCRIPT",
    Callback = function()
        if currentKey == "" then
            setStatus("Status: enter a key first")
            return
        end

        setStatus("Status: loading protected script...")

        task.spawn(function()
            local ok, result = pcall(function()
                -- FlowAuth loader endpoints are normally executed directly. The key is
                -- retained as the current auth value for loaders that expose it through
                -- the executor environment, while the protected endpoint performs the
                -- actual server-side authentication.
                if type(getgenv) == "function" then
                    local env = getgenv()
                    env.ZeHubKey = currentKey
                    env.FlowAuthKey = currentKey
                end

                local source = game:HttpGet(FLOWAUTH_LOADER_URL)
                local fn, compileError = loadstring(source)
                if not fn then
                    error(compileError or "FlowAuth loader could not be compiled")
                end

                return fn()
            end)

            if ok then
                setStatus("Status: script loaded")
                Window:SelectTab("Keyed Scripts")
            else
                setStatus("Status: load failed — " .. tostring(result))
            end
        end)
    end
})
KeySection:CreateButton({
    Name = "DISCORD • discord.gg/zehub",
    Callback = function()
        local copied = copyText("discord.gg/zehub")
        if copied then
            setStatus("Status: Discord invite copied")
        else
            setStatus("Status: discord.gg/zehub")
        end
    end
})

local KeyStatus = KeyTab:CreateSection({Name = "STATUS"})
KeyStatusLabel = KeyStatus:CreateParagraph({
    Text = "Status: waiting for key",
    Height = 44
})

local KillSection = MainTab:CreateSection({Name = "KILL AURA ACTIONS"})
KillSection:CreateToggle({
    Name = "Kill Aura",
    Default = Config.killAura,
    Callback = function(v) Config.killAura = v end
})
KillSection:CreateSlider({
    Name = "Kill Aura Distance",
    Min = 5, Max = 500, Default = Config.killAuraRange, Step = 1,
    Callback = function(v) Config.killAuraRange = v end
})
KillSection:CreateSlider({
    Name = "Kill Aura Damage",
    Min = 1, Max = 1000, Default = Config.killAuraDamage, Step = 1,
    Callback = function(v) Config.killAuraDamage = v end
})

local AutoSection = MainTab:CreateSection({Name = "AUTOMATION ACTIONS"})
AutoSection:CreateButton({
    Name = "Auto Escape (Finish Tutorial first)",
    Callback = function() utility:StartAutoEscape() end
})

local LootSection = MainTab:CreateSection({Name = "LOOT ACTIONS"})
LootSection:CreateButton({
    Name = "Teleport to Next Loot",
    Callback = function() utility:TeleportToNextLoot() end
})
LootSection:CreateButton({
    Name = "Drop All Loot",
    Callback = function() utility:DropAllLootSequential() end
})

local AimbotSection = FireTab:CreateSection({Name = "AIMBOT OPTIONS"})
AimbotSection:CreateToggle({
    Name = "Aimbot (NPCs, hold RMB)",
    Default = Config.aimbot,
    Callback = function(v) Config.aimbot = v end
})
AimbotSection:CreateSlider({
    Name = "Smoothness (1 = instant)",
    Min = 1, Max = 20, Default = Config.aimbotSmoothness, Step = 1,
    Callback = function(v) Config.aimbotSmoothness = v end
})
AimbotSection:CreateDropdown({
    Name = "Target Limb",
    Options = {"Head","Torso","UpperTorso","LowerTorso","HumanoidRootPart"},
    Default = Config.aimbotLimb,
    Callback = function(v) Config.aimbotLimb = v end
})
AimbotSection:CreateSlider({
    Name = "FOV Radius",
    Min = 10, Max = 500, Default = Config.aimbotFov, Step = 1,
    Callback = function(v) Config.aimbotFov = v end
})

local FirearmSection = FireTab:CreateSection({Name = "FIREARM OPTIONS"})
FirearmSection:CreateToggle({
    Name = "Infinite Ammo",
    Default = Config.infiniteAmmo,
    Callback = function(v) Config.infiniteAmmo = v end
})
FirearmSection:CreateNumberBox({
    Name = "Ammo Amount",
    Default = Config.infiniteAmmoAmount,
    Callback = function(v) Config.infiniteAmmoAmount = v end
})

local VehSection = VehTab:CreateSection({Name = "VEHICLE OPTIONS"})
VehSection:CreateInput({
    Name = "Acceleration (empty = default)",
    Placeholder = "",
    Callback = function(t) Config.vehicleAccel = tonumber(t) end
})
VehSection:CreateInput({
    Name = "Top Speed MPH (empty = default)",
    Placeholder = "",
    Callback = function(t) Config.vehicleTopSpeed = tonumber(t) end
})
VehSection:CreateToggle({
    Name = "Infinite Fuel",
    Default = Config.infiniteFuel,
    Callback = function(v) Config.infiniteFuel = v end
})

local EspSection = EspTab:CreateSection({Name = "ESP OPTIONS"})
EspSection:CreateToggle({
    Name = "Loot ESP (green)",
    Default = Config.lootEsp,
    Callback = function(v)
        Config.lootEsp = v
        utility:ToggleLootESP(v)
    end
})
EspSection:CreateToggle({
    Name = "Building ESP (blue)",
    Default = Config.buildingEsp,
    Callback = function(v)
        Config.buildingEsp = v
        utility:ToggleBuildingESP(v)
    end
})
EspSection:CreateToggle({
    Name = "Money ESP (gold)",
    Default = Config.moneyEsp,
    Callback = function(v)
        Config.moneyEsp = v
        utility:ToggleMoneyESP(v)
    end
})
EspSection:CreateToggle({
    Name = "NPC ESP (red)",
    Default = Config.npcEsp,
    Callback = function(v)
        Config.npcEsp = v
        utility:ToggleNPCESP(v)
    end
})
EspSection:CreateToggle({
    Name = "Vehicle ESP (magenta)",
    Default = Config.vehicleEsp,
    Callback = function(v)
        Config.vehicleEsp = v
        utility:ToggleVehicleESP(v)
    end
})

local TpSection = TpTab:CreateSection({Name = "TELEPORT ACTIONS"})
TpSection:CreateButton({
    Name = "Teleport to Start",
    Callback = function() utility:TeleportToStart() end
})
TpSection:CreateButton({
    Name = "Teleport to Pawn Shop (nearest)",
    Callback = function() utility:TeleportToPawnShop() end
})
TpSection:CreateButton({
    Name = "Teleport to Gas Station (nearest)",
    Callback = function() utility:TeleportToGasStation() end
})
TpSection:CreateButton({
    Name = "Teleport to My Vehicle",
    Callback = function() utility:TeleportToMyVehicle() end
})

local SaveSection = TpTab:CreateSection({Name = "SAVE / LOAD"})
SaveSection:CreateButton({
    Name = "Save Current Position",
    Callback = function() utility:SavePosition() end
})
SaveSection:CreateButton({
    Name = "Load Saved Position",
    Callback = function() utility:LoadPosition() end
})
SaveSection:CreateButton({
    Name = "Previous Position",
    Callback = function() utility:PreviousPosition() end
})

local PlayerSection = PlayerTab:CreateSection({Name = "PLAYER OPTIONS"})
PlayerSection:CreateToggle({
    Name = "WalkSpeed",
    Default = Config.walkSpeedEnabled,
    Callback = function(v)
        Config.walkSpeedEnabled = v
        if not v then
            local hum = utility:GetLocalHum()
            if hum then hum.WalkSpeed = DEFAULT_WALKSPEED end
        end
    end
})
PlayerSection:CreateSlider({
    Name = "WalkSpeed (default 16)",
    Min = 1, Max = 200, Default = Config.walkSpeed, Step = 1,
    Callback = function(v) Config.walkSpeed = v end
})
PlayerSection:CreateToggle({
    Name = "JumpPower",
    Default = Config.jumpPowerEnabled,
    Callback = function(v)
        Config.jumpPowerEnabled = v
        if not v then
            local hum = utility:GetLocalHum()
            if hum then hum.JumpPower = DEFAULT_JUMPPOWER end
        end
    end
})
PlayerSection:CreateSlider({
    Name = "JumpPower (default 50)",
    Min = 1, Max = 200, Default = Config.jumpPower, Step = 1,
    Callback = function(v) Config.jumpPower = v end
})
PlayerSection:CreateToggle({
    Name = "Infinite Jump",
    Default = Config.infiniteJump,
    Callback = function(v) Config.infiniteJump = v end
})
PlayerSection:CreateToggle({
    Name = "No-Clip",
    Default = Config.noclip,
    Callback = function(v) Config.noclip = v end
})

print("========================================")
print("ZeHub Runaways Loaded")
print("Platform: " .. PLATFORM)
print("RightCtrl = UI Toggle (library)")
print("========================================")

-- FlowAuth protected loader completed successfully.
return true
