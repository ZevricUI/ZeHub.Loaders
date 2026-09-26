-- ============================================================================
-- ZeHub UI Library • Black / White Transparent Edition
-- ============================================================================
--
-- Visual changes:
--   • Black / charcoal / white theme
--   • Transparent / glass-style background
--   • Thin grey/white borders
--   • Minimal monochrome UI
--   • Compact sidebar
--   • Minimize -> floating compact box
--   • Click compact box -> restore
--   • Main window remains draggable
--   • Minimized box is draggable
--   • PC + mobile/touch support
--
-- Public API preserved:
--   Library:CreateWindow
--   Window:CreateTab / AddTab
--   Tab:CreateSection / AddSection
--   Section:CreateToggle
--   Section:CreateButton
--   Section:CreateDropdown
--   Section:CreateMultiDropdown
--   Section:CreateSlider
--   Section:CreateNumberBox
--   Section:CreateInput / CreateTextBox
--   Section:CreateParagraph / CreateInfo / CreateLabel
--   Section:CreateFeatureCard
--   Section:CreateSpacer
-- ============================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local guiAlive = true

-- ============================================================================
-- THEME
-- ============================================================================

local ThemePresets = {

    Dark = {
        Background = Color3.fromRGB(7, 8, 10),
        Topbar = Color3.fromRGB(10, 11, 14),
        Sidebar = Color3.fromRGB(8, 10, 12),

        Row = Color3.fromRGB(15, 17, 20),
        RowHover = Color3.fromRGB(22, 25, 29),

        Input = Color3.fromRGB(10, 12, 15),

        Border = Color3.fromRGB(48, 51, 57),
        BorderBright = Color3.fromRGB(112, 116, 124),

        Text = Color3.fromRGB(238, 240, 243),
        Muted = Color3.fromRGB(148, 152, 159),
        Placeholder = Color3.fromRGB(91, 96, 104),

        ToggleOn = Color3.fromRGB(232, 234, 238),
        TabActive = Color3.fromRGB(24, 27, 31),

        Accent = Color3.fromRGB(232, 234, 238),
        Shadow = Color3.fromRGB(0, 0, 0)
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

        Accent = Color3.fromRGB(25, 25, 26),
        Shadow = Color3.fromRGB(0, 0, 0)
    }
}

local currentThemeName = "Dark"
local Theme = ThemePresets[currentThemeName]

local themeRefreshers = {}

local activePageName = nil
local minimized = false
local sidebarExpanded = true

-- ============================================================================
-- HELPERS
-- ============================================================================

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
        TweenInfo.new(
            duration or 0.1,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        properties
    )

    animation:Play()

    return animation
end

local function registerThemeRefresh(callback)

    table.insert(themeRefreshers, callback)

end

-- ============================================================================
-- GUI PARENT
-- ============================================================================

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

-- ============================================================================
-- SCREEN GUI
-- ============================================================================

local gui = create("ScreenGui", {
    Name = "ZeHubUILibrary",
    ResetOnSpawn = false,
    IgnoreGuiInset = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = guiParent
})

gui.Enabled = false

-- ============================================================================
-- WINDOW SETTINGS
-- ============================================================================

local BASE_WIDTH = 500
local BASE_HEIGHT = 430

local TOPBAR_HEIGHT = 48

local SIDEBAR_COLLAPSED = 58
local SIDEBAR_EXPANDED = 150

local CONTENT_GAP = 12

local PAGE_HEADER_HEIGHT = 26
local SECTION_BAR_HEIGHT = 34

-- ============================================================================
-- MAIN WINDOW
-- ============================================================================

local main = create("Frame", {

    Name = "Main",

    AnchorPoint = Vector2.new(0.5, 0.5),

    Position = UDim2.fromScale(0.5, 0.5),

    Size = UDim2.fromOffset(
        BASE_WIDTH,
        BASE_HEIGHT
    ),

    BackgroundColor3 = Theme.Background,

    BackgroundTransparency = 0.15,

    BorderSizePixel = 0,

    ClipsDescendants = true,

    Active = true,

    Parent = gui
})

corner(main, 9)

local mainStroke = stroke(
    main,
    Theme.BorderBright,
    0.35
)

-- ============================================================================
-- TOPBAR
-- ============================================================================

local topbar = create("Frame", {

    Name = "Topbar",

    Size = UDim2.new(
        1,
        0,
        0,
        TOPBAR_HEIGHT
    ),

    BackgroundColor3 = Theme.Topbar,

    BackgroundTransparency = 0.21,

    BorderSizePixel = 0,

    Active = true,

    Parent = main
})

corner(topbar, 9)

local topbarBottom = create("Frame", {

    Position = UDim2.new(
        0,
        0,
        1,
        -7
    ),

    Size = UDim2.new(
        1,
        0,
        0,
        7
    ),

    BackgroundColor3 = Theme.Topbar,

    BackgroundTransparency = 0.21,

    BorderSizePixel = 0,

    Parent = topbar
})

-- ============================================================================
-- MENU
-- ============================================================================

local menuButton = create("TextButton", {

    Name = "Navigation",

    Position = UDim2.fromOffset(
        11,
        8
    ),

    Size = UDim2.fromOffset(
        22,
        22
    ),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    AutoButtonColor = false,

    Text = "≡",

    TextColor3 = Theme.Muted,

    Font = Enum.Font.GothamBold,

    TextSize = 16,

    Parent = topbar
})

-- ============================================================================
-- TITLE
-- ============================================================================

local title = create("TextLabel", {

    Name = "Title",

    Position = UDim2.fromOffset(
        40,
        4
    ),

    Size = UDim2.new(
        1,
        -135,
        0,
        18
    ),

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

    Position = UDim2.fromOffset(
        40,
        21
    ),

    Size = UDim2.new(
        1,
        -135,
        0,
        13
    ),

    BackgroundTransparency = 1,

    Text = "UI Library",

    TextColor3 = Theme.Muted,

    TextSize = 9,

    Font = Enum.Font.GothamSemibold,

    TextXAlignment = Enum.TextXAlignment.Left,

    TextTruncate = Enum.TextTruncate.AtEnd,

    Parent = topbar
})

-- ============================================================================
-- THEME BUTTON
-- ============================================================================

local themeButton = create("TextButton", {

    Name = "Theme",

    AnchorPoint = Vector2.new(
        1,
        0.5
    ),

    Position = UDim2.new(
        1,
        -61,
        0.5,
        0
    ),

    Size = UDim2.fromOffset(
        20,
        20
    ),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    Text = "",

    AutoButtonColor = false,

    Parent = topbar
})

local themeCenter = create("Frame", {

    AnchorPoint = Vector2.new(
        0.5,
        0.5
    ),

    Position = UDim2.fromScale(
        0.5,
        0.5
    ),

    Size = UDim2.fromOffset(
        5,
        5
    ),

    BackgroundColor3 = Theme.Muted,

    BorderSizePixel = 0,

    Parent = themeButton
})

corner(themeCenter, 5)

local themeRays = {}

local rayData = {

    {
        UDim2.new(
            0.5,
            -1,
            0.5,
            -7
        ),

        UDim2.fromOffset(
            2,
            3
        )
    },

    {
        UDim2.new(
            0.5,
            -1,
            0.5,
            4
        ),

        UDim2.fromOffset(
            2,
            3
        )
    },

    {
        UDim2.new(
            0.5,
            -7,
            0.5,
            -1
        ),

        UDim2.fromOffset(
            3,
            2
        )
    },

    {
        UDim2.new(
            0.5,
            4,
            0.5,
            -1
        ),

        UDim2.fromOffset(
            3,
            2
        )
    }
}

for _, data in ipairs(rayData) do

    local ray = create("Frame", {

        Position = data[1],

        Size = data[2],

        BackgroundColor3 = Theme.Muted,

        BorderSizePixel = 0,

        Parent = themeButton
    })

    table.insert(
        themeRays,
        ray
    )

end

-- ============================================================================
-- MINIMIZE BUTTON
-- ============================================================================

local minimizeButton = create("TextButton", {

    Name = "Minimize",

    AnchorPoint = Vector2.new(
        1,
        0.5
    ),

    Position = UDim2.new(
        1,
        -34,
        0.5,
        0
    ),

    Size = UDim2.fromOffset(
        20,
        20
    ),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    Text = "",

    AutoButtonColor = false,

    Parent = topbar
})

local minimizeLine = create("Frame", {

    AnchorPoint = Vector2.new(
        0.5,
        0.5
    ),

    Position = UDim2.fromScale(
        0.5,
        0.5
    ),

    Size = UDim2.fromOffset(
        9,
        1
    ),

    BackgroundColor3 = Theme.Text,

    BorderSizePixel = 0,

    Parent = minimizeButton
})

-- ============================================================================
-- CLOSE
-- ============================================================================

local close = create("TextButton", {

    Name = "Close",

    AnchorPoint = Vector2.new(
        1,
        0.5
    ),

    Position = UDim2.new(
        1,
        -8,
        0.5,
        0
    ),

    Size = UDim2.fromOffset(
        18,
        18
    ),

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

    Position = UDim2.new(
        0,
        0,
        1,
        -1
    ),

    Size = UDim2.new(
        1,
        0,
        0,
        1
    ),

    BackgroundColor3 = Theme.Border,

    BackgroundTransparency = 0.28,

    BorderSizePixel = 0,

    Parent = topbar
})

-- ============================================================================
-- SIDEBAR
-- ============================================================================

local sidebar = create("Frame", {

    Name = "Sidebar",

    Position = UDim2.fromOffset(
        0,
        TOPBAR_HEIGHT
    ),

    Size = UDim2.new(
        0,
        SIDEBAR_EXPANDED,
        1,
        -TOPBAR_HEIGHT
    ),

    BackgroundColor3 = Theme.Sidebar,

    BackgroundTransparency = 0.28,

    BorderSizePixel = 0,

    ClipsDescendants = true,

    Parent = main
})

local sidebarLine = create("Frame", {

    AnchorPoint = Vector2.new(
        1,
        0
    ),

    Position = UDim2.new(
        1,
        0,
        0,
        0
    ),

    Size = UDim2.new(
        0,
        1,
        1,
        0
    ),

    BackgroundColor3 = Theme.Border,

    BackgroundTransparency = 0.15,

    BorderSizePixel = 0,

    Parent = sidebar
})

local navHolder = create("Frame", {

    Position = UDim2.fromOffset(
        8,
        12
    ),

    Size = UDim2.new(
        1,
        -16,
        1,
        -24
    ),

    BackgroundTransparency = 1,

    Parent = sidebar
})

create("UIListLayout", {

    Padding = UDim.new(
        0,
        4
    ),

    SortOrder = Enum.SortOrder.LayoutOrder,

    Parent = navHolder
})

-- ============================================================================
-- CONTENT
-- ============================================================================

local content = create("Frame", {

    Name = "Content",

    Position = UDim2.fromOffset(
        SIDEBAR_EXPANDED + CONTENT_GAP,
        TOPBAR_HEIGHT + CONTENT_GAP
    ),

    Size = UDim2.new(
        1,
        -(SIDEBAR_EXPANDED + CONTENT_GAP * 2),
        1,
        -(TOPBAR_HEIGHT + CONTENT_GAP * 2)
    ),

    BackgroundTransparency = 1,

    ClipsDescendants = true,

    Parent = main
})

-- ============================================================================
-- DATA
-- ============================================================================

local pages = {}
local sideButtons = {}
local activeSectionByPage = {}

-- ============================================================================
-- ICON COLOR
-- ============================================================================

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

-- ============================================================================
-- NAV ICONS
-- ============================================================================

local function createNavGlyph(parent, kind)

    local root = create("Frame", {

        AnchorPoint = Vector2.new(
            0.5,
            0.5
        ),

        Position = UDim2.fromScale(
            0.5,
            0.5
        ),

        Size = UDim2.fromOffset(
            18,
            18
        ),

        BackgroundTransparency = 1,

        Parent = parent
    })

    local glyph = {
        Root = root,
        Fills = {},
        Strokes = {},
        Texts = {}
    }

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

        table.insert(
            glyph.Fills,
            part
        )

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

        local partStroke = stroke(
            part,
            Theme.Muted,
            0
        )

        partStroke.Thickness = thickness or 1

        table.insert(
            glyph.Strokes,
            partStroke
        )

        return part
    end

    local function textGlyph(value, textSize)

        local label = create("TextLabel", {

            Size = UDim2.fromScale(
                1,
                1
            ),

            BackgroundTransparency = 1,

            Text = value,

            TextColor3 = Theme.Muted,

            TextSize = textSize or 12,

            Font = Enum.Font.GothamBold,

            Parent = root
        })

        table.insert(
            glyph.Texts,
            label
        )

        return label
    end

    if kind == "Changelog"
        or kind == "Home" then

        outline(
            UDim2.fromOffset(2, 2),
            UDim2.fromOffset(14, 14),
            7,
            1
        )

        fill(
            UDim2.fromOffset(8, 5),
            UDim2.fromOffset(2, 5),
            1
        )

        local hand = fill(
            UDim2.fromOffset(9, 9),
            UDim2.fromOffset(5, 2),
            1
        )

        hand.Rotation = 22

    elseif kind == "Auto Farm"
        or kind == "Farm" then

        outline(
            UDim2.fromOffset(3, 3),
            UDim2.fromOffset(12, 12),
            7,
            1
        )

        fill(
            UDim2.fromOffset(11, 2),
            UDim2.fromOffset(4, 2),
            1
        )

        fill(
            UDim2.fromOffset(14, 2),
            UDim2.fromOffset(2, 5),
            1
        )

        fill(
            UDim2.fromOffset(4, 11),
            UDim2.fromOffset(4, 2),
            1
        )

        fill(
            UDim2.fromOffset(3, 9),
            UDim2.fromOffset(2, 4),
            1
        )

    elseif kind == "Events" then

        outline(
            UDim2.fromOffset(3, 3),
            UDim2.fromOffset(12, 12),
            7,
            1
        )

        textGlyph(
            "!",
            11
        )

    elseif kind == "Pets" then

        fill(
            UDim2.fromOffset(3, 4),
            UDim2.fromOffset(4, 4),
            3
        )

        fill(
            UDim2.fromOffset(7, 2),
            UDim2.fromOffset(4, 4),
            3
        )

        fill(
            UDim2.fromOffset(11, 4),
            UDim2.fromOffset(4, 4),
            3
        )

        fill(
            UDim2.fromOffset(6, 9),
            UDim2.fromOffset(7, 6),
            4
        )

    elseif kind == "Progress"
        or kind == "Stats" then

        fill(
            UDim2.fromOffset(3, 11),
            UDim2.fromOffset(3, 4),
            1
        )

        fill(
            UDim2.fromOffset(8, 7),
            UDim2.fromOffset(3, 8),
            1
        )

        fill(
            UDim2.fromOffset(13, 3),
            UDim2.fromOffset(3, 12),
            1
        )

    elseif kind == "Rewards"
        or kind == "Gift" then

        outline(
            UDim2.fromOffset(3, 6),
            UDim2.fromOffset(12, 9),
            2,
            1
        )

        fill(
            UDim2.fromOffset(8, 6),
            UDim2.fromOffset(2, 9),
            1
        )

        fill(
            UDim2.fromOffset(2, 5),
            UDim2.fromOffset(14, 2),
            1
        )

        fill(
            UDim2.fromOffset(5, 3),
            UDim2.fromOffset(4, 2),
            2
        )

        fill(
            UDim2.fromOffset(9, 3),
            UDim2.fromOffset(4, 2),
            2
        )

    elseif kind == "Visuals"
        or kind == "Eye" then

        outline(
            UDim2.fromOffset(2, 5),
            UDim2.fromOffset(14, 8),
            6,
            1
        )

        fill(
            UDim2.fromOffset(7, 7),
            UDim2.fromOffset(4, 4),
            3
        )

    elseif kind == "Utility"
        or kind == "Settings" then

        fill(
            UDim2.fromOffset(3, 4),
            UDim2.fromOffset(12, 1),
            1
        )

        fill(
            UDim2.fromOffset(3, 9),
            UDim2.fromOffset(12, 1),
            1
        )

        fill(
            UDim2.fromOffset(3, 14),
            UDim2.fromOffset(12, 1),
            1
        )

        fill(
            UDim2.fromOffset(6, 2),
            UDim2.fromOffset(3, 5),
            2
        )

        fill(
            UDim2.fromOffset(11, 7),
            UDim2.fromOffset(3, 5),
            2
        )

        fill(
            UDim2.fromOffset(5, 12),
            UDim2.fromOffset(3, 5),
            2
        )

    else

        fill(
            UDim2.fromOffset(5, 5),
            UDim2.fromOffset(8, 8),
            5
        )

    end

    return glyph
end

-- ============================================================================
-- PAGE SECTION REFRESH
-- ============================================================================

local function refreshPageSections(pageData)

    local activeSection =
        activeSectionByPage[pageData.Name]

    for sectionName, section in pairs(pageData.Sections) do

        section.Visible =
            sectionName == activeSection

    end

    for sectionName, buttonData in pairs(pageData.SectionButtons) do

        local active =
            sectionName == activeSection

        buttonData.Button.BackgroundColor3 =
            active
            and Theme.Row
            or Theme.Background

        buttonData.Button.BackgroundTransparency =
            active
            and 0.15
            or 1

        buttonData.Label.TextColor3 =
            active
            and Theme.Text
            or Theme.Muted

        buttonData.Underline.BackgroundColor3 =
            Theme.Text

        buttonData.Underline.BackgroundTransparency =
            active
            and 0.15
            or 1

    end

end

local function selectSection(pageName, sectionName)

    local pageData = pages[pageName]

    if not pageData
        or not pageData.Sections[sectionName] then
        return
    end

    activeSectionByPage[pageName] =
        sectionName

    refreshPageSections(pageData)

end

-- ============================================================================
-- SIDEBAR REFRESH
-- ============================================================================

local function refreshSideTabs()

    for name, data in pairs(sideButtons) do

        local active =
            name == activePageName

        data.Button.BackgroundColor3 =
            Theme.Sidebar

        data.IconHolder.BackgroundColor3 =
            active
            and Theme.TabActive
            or Theme.Sidebar

        data.IconHolder.BackgroundTransparency =
            active
            and 0
            or 1

        data.IconStroke.Color =
            active
            and Theme.BorderBright
            or Theme.Border

        data.IconStroke.Transparency =
            active
            and 0.45
            or 1

        data.Label.TextColor3 =
            active
            and Theme.Text
            or Theme.Muted

        data.Indicator.BackgroundColor3 =
            Theme.Text

        data.Indicator.BackgroundTransparency =
            active
            and 0
            or 1

        setGlyphColor(
            data.Glyph,
            active
            and Theme.Text
            or Theme.Muted
        )

    end

end

-- ============================================================================
-- SELECT PAGE
-- ============================================================================

local function selectPage(name)

    local pageData = pages[name]

    if not pageData then
        return
    end

    activePageName = name

    for pageName, data in pairs(pages) do

        data.Root.Visible =
            pageName == name

    end

    if not activeSectionByPage[name]
        and pageData.FirstSection then

        activeSectionByPage[name] =
            pageData.FirstSection

    end

    refreshPageSections(pageData)

    refreshSideTabs()

end

-- ============================================================================
-- CREATE PAGE
-- ============================================================================

local function createPage(name, iconAsset)

    local root = create("Frame", {

        Name = name,

        Size = UDim2.fromScale(
            1,
            1
        ),

        BackgroundTransparency = 1,

        Visible = false,

        Parent = content
    })

    local pageHeader = create("Frame", {

        Name = "PageHeader",

        Position = UDim2.fromOffset(
            0,
            SECTION_BAR_HEIGHT + 2
        ),

        Size = UDim2.new(
            1,
            0,
            0,
            PAGE_HEADER_HEIGHT
        ),

        BackgroundTransparency = 1,

        Parent = root
    })

    local headerDot = create("Frame", {

        AnchorPoint = Vector2.new(
            0,
            0.5
        ),

        Position = UDim2.new(
            0,
            3,
            0.5,
            0
        ),

        Size = UDim2.fromOffset(
            4,
            4
        ),

        BackgroundColor3 = Theme.Text,

        BorderSizePixel = 0,

        Parent = pageHeader
    })

    corner(
        headerDot,
        3
    )

    local headerLabel = create("TextLabel", {

        Position = UDim2.fromOffset(
            13,
            0
        ),

        Size = UDim2.fromOffset(
            92,
            PAGE_HEADER_HEIGHT
        ),

        BackgroundTransparency = 1,

        Text = string.upper(name),

        TextColor3 = Theme.Muted,

        TextSize = 9,

        Font = Enum.Font.GothamBold,

        TextXAlignment = Enum.TextXAlignment.Left,

        Parent = pageHeader
    })

    local headerLine = create("Frame", {

        Position = UDim2.fromOffset(
            103,
            math.floor(
                PAGE_HEADER_HEIGHT / 2
            )
        ),

        Size = UDim2.new(
            1,
            -106,
            0,
            1
        ),

        BackgroundColor3 = Theme.Border,

        BackgroundTransparency = 0.15,

        BorderSizePixel = 0,

        Parent = pageHeader
    })

    local sectionBar = create("ScrollingFrame", {

        Name = "SectionTabs",

        Position = UDim2.fromOffset(
            0,
            0
        ),

        Size = UDim2.new(
            1,
            0,
            0,
            SECTION_BAR_HEIGHT
        ),

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        ScrollBarThickness = 0,

        CanvasSize = UDim2.new(),

        AutomaticCanvasSize = Enum.AutomaticSize.X,

        ScrollingDirection =
            Enum.ScrollingDirection.X,

        Active = true,

        Parent = root
    })

    create("UIListLayout", {

        FillDirection =
            Enum.FillDirection.Horizontal,

        HorizontalAlignment =
            Enum.HorizontalAlignment.Left,

        Padding = UDim.new(
            0,
            3
        ),

        SortOrder =
            Enum.SortOrder.LayoutOrder,

        Parent = sectionBar
    })

    local contentTop =
        SECTION_BAR_HEIGHT
        + PAGE_HEADER_HEIGHT
        + 7

    local sectionContent = create("Frame", {

        Position = UDim2.fromOffset(
            0,
            contentTop
        ),

        Size = UDim2.new(
            1,
            0,
            1,
            -contentTop
        ),

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

    -- NAV BUTTON

    local navButton = create("TextButton", {

        Name = "Nav_" .. name,

        Size = UDim2.new(
            1,
            0,
            0,
            36
        ),

        BackgroundColor3 = Theme.Sidebar,

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false,

        Parent = navHolder
    })

    corner(
        navButton,
        5
    )

    local indicator = create("Frame", {

        AnchorPoint = Vector2.new(
            0,
            0.5
        ),

        Position = UDim2.new(
            0,
            0,
            0.5,
            0
        ),

        Size = UDim2.fromOffset(
            2,
            18
        ),

        BackgroundColor3 = Theme.Text,

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        Parent = navButton
    })

    corner(
        indicator,
        2
    )

    local iconHolder = create("Frame", {

        AnchorPoint = Vector2.new(
            0,
            0.5
        ),

        Position = UDim2.new(
            0,
            5,
            0.5,
            0
        ),

        Size = UDim2.fromOffset(
            28,
            28
        ),

        BackgroundColor3 = Theme.Input,

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        Parent = navButton
    })

    corner(
        iconHolder,
        5
    )

    local iconStroke =
        stroke(
            iconHolder,
            Theme.Border,
            1
        )

    local glyph =
        createNavGlyph(
            iconHolder,
            iconAsset or name
        )

    local label = create("TextLabel", {

        Position = UDim2.fromOffset(
            40,
            0
        ),

        Size = UDim2.new(
            1,
            -45,
            1,
            0
        ),

        BackgroundTransparency = 1,

        Text = name,

        TextColor3 = Theme.Muted,

        TextTransparency =
            sidebarExpanded
            and 0
            or 1,

        TextSize = 10,

        Font = Enum.Font.GothamSemibold,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextTruncate =
            Enum.TextTruncate.AtEnd,

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

            tween(
                navButton,
                {
                    BackgroundColor3 =
                        Theme.RowHover
                },
                0.08
            )

            tween(
                label,
                {
                    TextColor3 =
                        Theme.Text
                },
                0.08
            )

            setGlyphColor(
                glyph,
                Theme.Text
            )

        end

    end)

    navButton.MouseLeave:Connect(function()
        refreshSideTabs()
    end)

    registerThemeRefresh(function()

        if root.Parent then

            headerDot.BackgroundColor3 =
                Theme.Text

            headerLabel.TextColor3 =
                Theme.Muted

            headerLine.BackgroundColor3 =
                Theme.Border

            refreshPageSections(
                pageData
            )

        end

    end)

    return pageData

end

-- ============================================================================
-- CREATE SECTION
-- ============================================================================

local function createSection(pageData, sectionName)

    local section = create("ScrollingFrame", {

        Name = sectionName,

        Size = UDim2.fromScale(
            1,
            1
        ),

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        ScrollBarThickness =
            UserInputService.TouchEnabled
            and 4
            or 2,

        ScrollBarImageColor3 =
            Theme.BorderBright,

        CanvasSize = UDim2.new(),

        AutomaticCanvasSize =
            Enum.AutomaticSize.Y,

        ScrollingDirection =
            Enum.ScrollingDirection.Y,

        Visible = false,

        Parent = pageData.SectionContent
    })

    create("UIPadding", {

        PaddingTop = UDim.new(
            0,
            2
        ),

        PaddingBottom = UDim.new(
            0,
            7
        ),

        PaddingLeft = UDim.new(
            0,
            1
        ),

        PaddingRight = UDim.new(
            0,
            3
        ),

        Parent = section
    })

    create("UIListLayout", {

        Padding = UDim.new(
            0,
            5
        ),

        SortOrder =
            Enum.SortOrder.LayoutOrder,

        Parent = section
    })

    pageData.Sections[sectionName] =
        section

    if not pageData.FirstSection then

        pageData.FirstSection =
            sectionName

        activeSectionByPage[
            pageData.Name
        ] = sectionName

    end

    local tabWidth =
        math.clamp(
            #sectionName * 6 + 25,
            76,
            142
        )

    local tab = create("TextButton", {

        Name = "Section_" .. sectionName,

        Size = UDim2.new(
            0,
            tabWidth,
            0,
            SECTION_BAR_HEIGHT
        ),

        BackgroundColor3 =
            Theme.Background,

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false,

        Parent = pageData.SectionBar
    })

    corner(
        tab,
        4
    )

    local tabLabel = create("TextLabel", {

        Position = UDim2.fromOffset(
            8,
            0
        ),

        Size = UDim2.new(
            1,
            -16,
            1,
            -2
        ),

        BackgroundTransparency = 1,

        Text = sectionName,

        TextColor3 = Theme.Muted,

        TextSize = 10,

        Font = Enum.Font.GothamSemibold,

        Parent = tab
    })

    local underline = create("Frame", {

        AnchorPoint = Vector2.new(
            0.5,
            1
        ),

        Position = UDim2.new(
            0.5,
            0,
            1,
            -1
        ),

        Size = UDim2.new(
            1,
            -18,
            0,
            2
        ),

        BackgroundColor3 =
            Theme.Text,

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        Parent = tab
    })

    corner(
        underline,
        2
    )

    pageData.SectionButtons[
        sectionName
    ] = {

        Button = tab,

        Label = tabLabel,

        Underline = underline
    }

    tab.Activated:Connect(function()

        selectSection(
            pageData.Name,
            sectionName
        )

    end)

    tab.MouseEnter:Connect(function()

        if activeSectionByPage[
            pageData.Name
        ] ~= sectionName then

            tween(
                tab,
                {
                    BackgroundColor3 =
                        Theme.RowHover,
                    BackgroundTransparency =
                        0.35
                },
                0.08
            )

            tween(
                tabLabel,
                {
                    TextColor3 =
                        Theme.Text
                },
                0.08
            )

        end

    end)

    tab.MouseLeave:Connect(function()

        refreshPageSections(
            pageData
        )

    end)

    registerThemeRefresh(function()

        if section.Parent then

            section.ScrollBarImageColor3 =
                Theme.BorderBright

            refreshPageSections(
                pageData
            )

        end

    end)

    refreshPageSections(
        pageData
    )

    return section

end

-- ============================================================================
-- ROW HOVER
-- ============================================================================

local function bindRowHover(
    buttonObject,
    row,
    rowStroke
)

    buttonObject.MouseEnter:Connect(function()

        tween(
            row,
            {
                BackgroundColor3 =
                    Theme.RowHover
            },
            0.08
        )

        tween(
            rowStroke,
            {
                Color = Theme.Text,
                Transparency = 0.55
            },
            0.08
        )

    end)

    buttonObject.MouseLeave:Connect(function()

        tween(
            row,
            {
                BackgroundColor3 =
                    Theme.Row
            },
            0.08
        )

        tween(
            rowStroke,
            {
                Color = Theme.Border,
                Transparency = 0.38
            },
            0.08
        )

    end)

end

-- ============================================================================
-- TOGGLE
-- ============================================================================

local function toggle(
    parent,
    name,
    callback,
    defaultValue
)

    local enabled =
        defaultValue == true

    local row = create("Frame", {

        Name =
            "Toggle_" ..
            tostring(name),

        Size = UDim2.new(
            1,
            0,
            0,
            36
        ),

        BackgroundColor3 =
            Theme.Row,

        BackgroundTransparency =
            0.08,

        BorderSizePixel = 0,

        Parent = parent
    })

    corner(
        row,
        5
    )

    local rowStroke =
        stroke(
            row,
            Theme.Border,
            0.38
        )

    local label = create("TextLabel", {

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            12,
            0
        ),

        Size = UDim2.new(
            1,
            -64,
            1,
            0
        ),

        Font = Enum.Font.GothamMedium,

        Text = tostring(name),

        TextColor3 = Theme.Text,

        TextSize = 11,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextTruncate =
            Enum.TextTruncate.AtEnd,

        Parent = row
    })

    local track = create("Frame", {

        AnchorPoint = Vector2.new(
            1,
            0.5
        ),

        Position = UDim2.new(
            1,
            -11,
            0.5,
            0
        ),

        Size = UDim2.fromOffset(
            30,
            16
        ),

        BackgroundColor3 =
            Theme.Input,

        BorderSizePixel = 0,

        Parent = row
    })

    corner(
        track,
        8
    )

    local trackStroke =
        stroke(
            track,
            Theme.Border,
            0.12
        )

    local knob = create("Frame", {

        AnchorPoint = Vector2.new(
            0,
            0.5
        ),

        Position = UDim2.new(
            0,
            3,
            0.5,
            0
        ),

        Size = UDim2.fromOffset(
            10,
            10
        ),

        BackgroundColor3 =
            Theme.Muted,

        BorderSizePixel = 0,

        Parent = track
    })

    corner(
        knob,
        5
    )

    local hitbox = create("TextButton", {

        BackgroundTransparency = 1,

        Size = UDim2.fromScale(
            1,
            1
        ),

        Text = "",

        AutoButtonColor = false,

        Parent = row
    })

    local function render(instant)

        row.BackgroundColor3 =
            Theme.Row

        rowStroke.Color =
            Theme.Border

        label.TextColor3 =
            Theme.Text

        track.BackgroundColor3 =
            enabled
            and Theme.ToggleOn
            or Theme.Input

        trackStroke.Color =
            enabled
            and Theme.ToggleOn
            or Theme.Border

        knob.BackgroundColor3 =
            enabled
            and Theme.Text
            or Theme.Muted

        local x =
            enabled
            and 17
            or 3

        tween(
            knob,
            {
                Position = UDim2.new(
                    0,
                    x,
                    0.5,
                    0
                )
            },
            instant and 0 or 0.12
        )

    end

    hitbox.Activated:Connect(function()

        enabled = not enabled

        render(false)

        if callback then
            task.spawn(
                callback,
                enabled
            )
        end

    end)

    bindRowHover(
        hitbox,
        row,
        rowStroke
    )

    registerThemeRefresh(function()

        if row.Parent then
            render(true)
        end

    end)

    render(true)

    return row

end

-- ============================================================================
-- DROPDOWN
-- ============================================================================

local function dropdown(
    parent,
    name,
    options,
    callback,
    defaultValue
)

    local opened = false

    local selected =
        defaultValue ~= nil
        and defaultValue
        or options[1]

    local ROW_HEIGHT = 32
    local OPTION_HEIGHT = 25
    local GAP = 4

    local holder = create("Frame", {

        Name =
            "Dropdown_" ..
            tostring(name),

        Size = UDim2.new(
            1,
            0,
            0,
            ROW_HEIGHT
        ),

        BackgroundColor3 =
            Theme.Row,

        BackgroundTransparency =
            0.08,

        BorderSizePixel = 0,

        ClipsDescendants = true,

        Parent = parent
    })

    corner(
        holder,
        5
    )

    local holderStroke =
        stroke(
            holder,
            Theme.Border,
            0.38
        )

    local label = create("TextLabel", {

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            9,
            0
        ),

        Size = UDim2.new(
            0.47,
            -8,
            0,
            ROW_HEIGHT
        ),

        Font = Enum.Font.GothamSemibold,

        Text = tostring(name),

        TextColor3 = Theme.Text,

        TextSize = 11,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextTruncate =
            Enum.TextTruncate.AtEnd,

        Parent = holder
    })

    local valueBox = create("Frame", {

        AnchorPoint = Vector2.new(
            1,
            0.5
        ),

        Position = UDim2.new(
            1,
            -6,
            0,
            ROW_HEIGHT / 2
        ),

        Size = UDim2.new(
            0.50,
            -4,
            0,
            22
        ),

        BackgroundColor3 =
            Theme.Input,

        BorderSizePixel = 0,

        Parent = holder
    })

    corner(
        valueBox,
        3
    )

    local valueStroke =
        stroke(
            valueBox,
            Theme.Border,
            0.28
        )

    local valueLabel = create("TextLabel", {

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            7,
            0
        ),

        Size = UDim2.new(
            1,
            -27,
            1,
            0
        ),

        Font = Enum.Font.GothamSemibold,

        Text =
            selected
            and tostring(selected)
            or "None",

        TextColor3 = Theme.Muted,

        TextSize = 10,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextTruncate =
            Enum.TextTruncate.AtEnd,

        Parent = valueBox
    })

    local arrow = create("TextLabel", {

        AnchorPoint = Vector2.new(
            1,
            0.5
        ),

        Position = UDim2.new(
            1,
            -5,
            0.5,
            0
        ),

        Size = UDim2.fromOffset(
            13,
            18
        ),

        BackgroundTransparency = 1,

        Text = "v",

        TextColor3 = Theme.Muted,

        Font = Enum.Font.GothamBold,

        TextSize = 10,

        Parent = valueBox
    })

    local headerButton = create("TextButton", {

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            0,
            0,
            ROW_HEIGHT
        ),

        Text = "",

        AutoButtonColor = false,

        Parent = holder
    })

    local optionsPanel = create("Frame", {

        Position = UDim2.fromOffset(
            5,
            ROW_HEIGHT + GAP
        ),

        Size = UDim2.new(
            1,
            -10,
            0,
            (#options * OPTION_HEIGHT) + 6
        ),

        BackgroundColor3 =
            Theme.Input,

        BorderSizePixel = 0,

        Parent = holder
    })

    corner(
        optionsPanel,
        3
    )

    local panelStroke =
        stroke(
            optionsPanel,
            Theme.Border,
            0.22
        )

    create("UIPadding", {

        PaddingTop = UDim.new(
            0,
            3
        ),

        PaddingBottom = UDim.new(
            0,
            3
        ),

        Parent = optionsPanel
    })

    create("UIListLayout", {

        SortOrder =
            Enum.SortOrder.LayoutOrder,

        Parent = optionsPanel
    })

    local optionRows = {}

    local function refreshOptions()

        for option, data in pairs(optionRows) do

            local active =
                option == selected

            data.Button.BackgroundColor3 =
                active
                and Theme.RowHover
                or Theme.Input

            data.Label.TextColor3 =
                active
                and Theme.Text
                or Theme.Muted

            data.Check.Text =
                active
                and "✓"
                or ""

            data.Check.TextColor3 =
                Theme.Text

        end

    end

    local function setOpen(value)

        opened = value == true

        arrow.Text =
            opened
            and "^"
            or "v"

        local expandedHeight =
            ROW_HEIGHT
            + GAP
            + (#options * OPTION_HEIGHT)
            + 10

        tween(
            holder,
            {
                Size = UDim2.new(
                    1,
                    0,
                    0,
                    opened
                    and expandedHeight
                    or ROW_HEIGHT
                )
            },
            0.12
        )

    end

    for index, option in ipairs(options) do

        local optionButton = create("TextButton", {

            Name =
                "Option" ..
                index,

            Size = UDim2.new(
                1,
                0,
                0,
                OPTION_HEIGHT
            ),

            BackgroundColor3 =
                Theme.Input,

            BorderSizePixel = 0,

            Text = "",

            AutoButtonColor = false,

            Parent = optionsPanel
        })

        local optionLabel = create("TextLabel", {

            Position = UDim2.fromOffset(
                8,
                0
            ),

            Size = UDim2.new(
                1,
                -34,
                1,
                0
            ),

            BackgroundTransparency = 1,

            Text = tostring(option),

            TextColor3 =
                Theme.Muted,

            TextSize = 10,

            Font = Enum.Font.GothamSemibold,

            TextXAlignment =
                Enum.TextXAlignment.Left,

            Parent = optionButton
        })

        local check = create("TextLabel", {

            AnchorPoint = Vector2.new(
                1,
                0.5
            ),

            Position = UDim2.new(
                1,
                -8,
                0.5,
                0
            ),

            Size = UDim2.fromOffset(
                14,
                14
            ),

            BackgroundTransparency = 1,

            Text = "",

            TextColor3 =
                Theme.Text,

            TextSize = 11,

            Font = Enum.Font.GothamBold,

            Parent = optionButton
        })

        optionRows[option] = {

            Button = optionButton,

            Label = optionLabel,

            Check = check
        }

        optionButton.Activated:Connect(function()

            selected = option

            valueLabel.Text =
                tostring(option)

            refreshOptions()

            setOpen(false)

            if callback then
                task.spawn(
                    callback,
                    option
                )
            end

        end)

        optionButton.MouseEnter:Connect(function()

            if selected ~= option then

                tween(
                    optionButton,
                    {
                        BackgroundColor3 =
                            Theme.RowHover
                    },
                    0.07
                )

                tween(
                    optionLabel,
                    {
                        TextColor3 =
                            Theme.Text
                    },
                    0.07
                )

            end

        end)

        optionButton.MouseLeave:Connect(
            refreshOptions
        )

    end

    headerButton.Activated:Connect(function()

        setOpen(
            not opened
        )

    end)

    bindRowHover(
        headerButton,
        holder,
        holderStroke
    )

    registerThemeRefresh(function()

        if holder.Parent then

            holder.BackgroundColor3 =
                Theme.Row

            holderStroke.Color =
                Theme.Border

            label.TextColor3 =
                Theme.Text

            valueBox.BackgroundColor3 =
                Theme.Input

            valueStroke.Color =
                Theme.Border

            valueLabel.TextColor3 =
                Theme.Muted

            arrow.TextColor3 =
                Theme.Muted

            optionsPanel.BackgroundColor3 =
                Theme.Input

            panelStroke.Color =
                Theme.Border

            refreshOptions()

        end

    end)

    refreshOptions()

    return holder

end

-- ============================================================================
-- MULTI DROPDOWN
-- ============================================================================

local function multiDropdown(
    parent,
    name,
    options,
    callback,
    defaults
)

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

            if type(key) == "number"
                and type(value) == "string" then

                selected[value] = true

            elseif type(key) == "string"
                and value == true then

                selected[key] = true

            end

        end

    end

    local holder = create("Frame", {

        Name =
            "MultiDropdown_" ..
            tostring(name),

        Size = UDim2.new(
            1,
            0,
            0,
            ROW_HEIGHT
        ),

        BackgroundColor3 =
            Theme.Row,

        BackgroundTransparency =
            0.08,

        BorderSizePixel = 0,

        ClipsDescendants = true,

        Parent = parent
    })

    corner(
        holder,
        5
    )

    local holderStroke =
        stroke(
            holder,
            Theme.Border,
            0.38
        )

    local label = create("TextLabel", {

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            9,
            0
        ),

        Size = UDim2.new(
            0.47,
            -8,
            0,
            ROW_HEIGHT
        ),

        Font = Enum.Font.GothamSemibold,

        Text = tostring(name),

        TextColor3 = Theme.Text,

        TextSize = 11,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextTruncate =
            Enum.TextTruncate.AtEnd,

        Parent = holder
    })

    local valueBox = create("Frame", {

        AnchorPoint = Vector2.new(
            1,
            0.5
        ),

        Position = UDim2.new(
            1,
            -6,
            0,
            ROW_HEIGHT / 2
        ),

        Size = UDim2.new(
            0.50,
            -4,
            0,
            22
        ),

        BackgroundColor3 =
            Theme.Input,

        BorderSizePixel = 0,

        Parent = holder
    })

    corner(
        valueBox,
        3
    )

    local valueStroke =
        stroke(
            valueBox,
            Theme.Border,
            0.28
        )

    local valueLabel = create("TextLabel", {

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            7,
            0
        ),

        Size = UDim2.new(
            1,
            -27,
            1,
            0
        ),

        Font = Enum.Font.GothamSemibold,

        Text = "None",

        TextColor3 =
            Theme.Muted,

        TextSize = 10,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextTruncate =
            Enum.TextTruncate.AtEnd,

        Parent = valueBox
    })

    local arrow = create("TextLabel", {

        AnchorPoint = Vector2.new(
            1,
            0.5
        ),

        Position = UDim2.new(
            1,
            -5,
            0.5,
            0
        ),

        Size = UDim2.fromOffset(
            13,
            18
        ),

        BackgroundTransparency = 1,

        Text = "v",

        TextColor3 =
            Theme.Muted,

        Font = Enum.Font.GothamBold,

        TextSize = 10,

        Parent = valueBox
    })

    local headerButton = create("TextButton", {

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            0,
            0,
            ROW_HEIGHT
        ),

        Text = "",

        AutoButtonColor = false,

        Parent = holder
    })

    local totalRows =
        #options + 1

    local optionsPanel = create("Frame", {

        Position = UDim2.fromOffset(
            5,
            ROW_HEIGHT + GAP
        ),

        Size = UDim2.new(
            1,
            -10,
            0,
            (totalRows * OPTION_HEIGHT) + 6
        ),

        BackgroundColor3 =
            Theme.Input,

        BorderSizePixel = 0,

        Parent = holder
    })

    corner(
        optionsPanel,
        3
    )

    local panelStroke =
        stroke(
            optionsPanel,
            Theme.Border,
            0.22
        )

    create("UIPadding", {

        PaddingTop = UDim.new(
            0,
            3
        ),

        PaddingBottom = UDim.new(
            0,
            3
        ),

        Parent = optionsPanel
    })

    create("UIListLayout", {

        SortOrder =
            Enum.SortOrder.LayoutOrder,

        Parent = optionsPanel
    })

    local function snapshot()

        local values = {}

        for _, option in ipairs(options) do

            if selected[option] then
                table.insert(
                    values,
                    option
                )
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

        local values =
            snapshot()

        if isAllSelected() then

            valueLabel.Text = "All"

        elseif #values == 0 then

            valueLabel.Text = "None"

        elseif #values == 1 then

            valueLabel.Text =
                tostring(values[1])

        else

            valueLabel.Text =
                tostring(#values)
                .. " selected"

        end

        if allRow then

            local activeAll =
                isAllSelected()

            allRow.Button.BackgroundColor3 =
                activeAll
                and Theme.RowHover
                or Theme.Input

            allRow.Label.TextColor3 =
                activeAll
                and Theme.Text
                or Theme.Muted

            allRow.Fill.BackgroundTransparency =
                activeAll
                and 0
                or 1

            allRow.BoxStroke.Color =
                activeAll
                and Theme.ToggleOn
                or Theme.BorderBright

        end

        for option, data in pairs(optionRows) do

            local active =
                selected[option] == true

            data.Button.BackgroundColor3 =
                active
                and Theme.RowHover
                or Theme.Input

            data.Label.TextColor3 =
                active
                and Theme.Text
                or Theme.Muted

            data.Fill.BackgroundColor3 =
                Theme.ToggleOn

            data.Fill.BackgroundTransparency =
                active
                and 0
                or 1

            data.Box.BackgroundColor3 =
                Theme.Input

            data.BoxStroke.Color =
                active
                and Theme.ToggleOn
                or Theme.BorderBright

        end

    end

    local function setOpen(value)

        opened = value == true

        arrow.Text =
            opened
            and "^"
            or "v"

        local expandedHeight =
            ROW_HEIGHT
            + GAP
            + (totalRows * OPTION_HEIGHT)
            + 10

        tween(
            holder,
            {
                Size = UDim2.new(
                    1,
                    0,
                    0,
                    opened
                    and expandedHeight
                    or ROW_HEIGHT
                )
            },
            0.12
        )

    end

    local function createCheckRow(
        text,
        order,
        onClick
    )

        local optionButton = create(
            "TextButton",
            {

                Name =
                    "Option" ..
                    order,

                LayoutOrder = order,

                Size = UDim2.new(
                    1,
                    0,
                    0,
                    OPTION_HEIGHT
                ),

                BackgroundColor3 =
                    Theme.Input,

                BorderSizePixel = 0,

                Text = "",

                AutoButtonColor = false,

                Parent = optionsPanel
            }
        )

        local optionLabel =
            create(
                "TextLabel",
                {

                    Position =
                        UDim2.fromOffset(
                            8,
                            0
                        ),

                    Size = UDim2.new(
                        1,
                        -38,
                        1,
                        0
                    ),

                    BackgroundTransparency =
                        1,

                    Text =
                        tostring(text),

                    TextColor3 =
                        Theme.Muted,

                    TextSize = 10,

                    Font =
                        Enum.Font.GothamSemibold,

                    TextXAlignment =
                        Enum.TextXAlignment.Left,

                    Parent =
                        optionButton
                }
            )

        local box = create("Frame", {

            AnchorPoint =
                Vector2.new(
                    1,
                    0.5
                ),

            Position = UDim2.new(
                1,
                -8,
                0.5,
                0
            ),

            Size = UDim2.fromOffset(
                13,
                13
            ),

            BackgroundColor3 =
                Theme.Input,

            BorderSizePixel = 0,

            Parent =
                optionButton
        })

        corner(
            box,
            2
        )

        local boxStroke =
            stroke(
                box,
                Theme.BorderBright,
                0.15
            )

        local fill = create("Frame", {

            AnchorPoint =
                Vector2.new(
                    0.5,
                    0.5
                ),

            Position =
                UDim2.fromScale(
                    0.5,
                    0.5
                ),

            Size = UDim2.fromOffset(
                6,
                6
            ),

            BackgroundColor3 =
                Theme.ToggleOn,

            BackgroundTransparency = 1,

            BorderSizePixel = 0,

            Parent = box
        })

        corner(
            fill,
            1
        )

        optionButton.Activated:Connect(
            onClick
        )

        optionButton.MouseEnter:Connect(
            function()

                tween(
                    optionButton,
                    {
                        BackgroundColor3 =
                            Theme.RowHover
                    },
                    0.07
                )

                tween(
                    optionLabel,
                    {
                        TextColor3 =
                            Theme.Text
                    },
                    0.07
                )

            end
        )

        optionButton.MouseLeave:Connect(
            refresh
        )

        return {

            Button =
                optionButton,

            Label =
                optionLabel,

            Box =
                box,

            BoxStroke =
                boxStroke,

            Fill =
                fill
        }

    end

    allRow =
        createCheckRow(
            "All",
            0,
            function()

                local selectAll =
                    not isAllSelected()

                for _, option in ipairs(options) do

                    selected[option] =
                        selectAll
                        or nil

                end

                refresh()

                if callback then

                    task.spawn(
                        callback,
                        snapshot(),
                        isAllSelected()
                    )

                end

            end
        )

    for index, option in ipairs(options) do

        optionRows[option] =
            createCheckRow(
                option,
                index,
                function()

                    selected[option] =
                        not selected[option]
                        or nil

                    refresh()

                    if callback then

                        task.spawn(
                            callback,
                            snapshot(),
                            isAllSelected()
                        )

                    end

                end
            )

    end

    headerButton.Activated:Connect(
        function()

            setOpen(
                not opened
            )

        end
    )

    bindRowHover(
        headerButton,
        holder,
        holderStroke
    )

    registerThemeRefresh(
        function()

            if holder.Parent then

                holder.BackgroundColor3 =
                    Theme.Row

                holderStroke.Color =
                    Theme.Border

                label.TextColor3 =
                    Theme.Text

                valueBox.BackgroundColor3 =
                    Theme.Input

                valueStroke.Color =
                    Theme.Border

                valueLabel.TextColor3 =
                    Theme.Muted

                arrow.TextColor3 =
                    Theme.Muted

                optionsPanel.BackgroundColor3 =
                    Theme.Input

                panelStroke.Color =
                    Theme.Border

                refresh()

            end

        end
    )

    refresh()

    return holder

end

-- ============================================================================
-- SLIDER
-- ============================================================================

local function slider(
    parent,
    name,
    minimum,
    maximum,
    defaultValue,
    step,
    callback
)

    minimum =
        tonumber(minimum)
        or 0

    maximum =
        math.max(
            tonumber(maximum)
                or minimum + 1,
            minimum + 0.0001
        )

    step =
        math.max(
            tonumber(step)
                or 1,
            0.0001
        )

    local value =
        math.clamp(
            tonumber(defaultValue)
                or minimum,
            minimum,
            maximum
        )

    local dragging = false

    local holder = create("Frame", {

        Name =
            "Slider_" ..
            tostring(name),

        Size = UDim2.new(
            1,
            0,
            0,
            48
        ),

        BackgroundColor3 =
            Theme.Row,

        BackgroundTransparency =
            0.08,

        BorderSizePixel = 0,

        Parent = parent
    })

    corner(
        holder,
        5
    )

    local holderStroke =
        stroke(
            holder,
            Theme.Border,
            0.35
        )

    local label = create("TextLabel", {

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            9,
            0
        ),

        Size = UDim2.new(
            1,
            -58,
            0,
            25
        ),

        Font =
            Enum.Font.GothamSemibold,

        Text =
            tostring(name),

        TextColor3 =
            Theme.Text,

        TextSize = 11,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextTruncate =
            Enum.TextTruncate.AtEnd,

        Parent = holder
    })

    local valueLabel = create("TextLabel", {

        AnchorPoint =
            Vector2.new(
                1,
                0
            ),

        BackgroundTransparency = 1,

        Position = UDim2.new(
            1,
            -9,
            0,
            0
        ),

        Size = UDim2.fromOffset(
            48,
            25
        ),

        Font =
            Enum.Font.GothamBold,

        Text =
            tostring(value),

        TextColor3 =
            Theme.Muted,

        TextSize = 10,

        TextXAlignment =
            Enum.TextXAlignment.Right,

        Parent = holder
    })

    local bar = create("Frame", {

        Position = UDim2.fromOffset(
            10,
            32
        ),

        Size = UDim2.new(
            1,
            -20,
            0,
            3
        ),

        BackgroundColor3 =
            Theme.Input,

        BorderSizePixel = 0,

        Parent = holder
    })

    corner(
        bar,
        2
    )

    local fill = create("Frame", {

        Size =
            UDim2.fromScale(
                0,
                1
            ),

        BackgroundColor3 =
            Theme.ToggleOn,

        BorderSizePixel = 0,

        Parent = bar
    })

    corner(
        fill,
        2
    )

    local hitbox = create("TextButton", {

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            5,
            23
        ),

        Size = UDim2.new(
            1,
            -10,
            0,
            18
        ),

        Text = "",

        AutoButtonColor = false,

        Parent = holder
    })

    local function render()

        local alpha =
            (value - minimum)
            / (maximum - minimum)

        fill.Size =
            UDim2.fromScale(
                alpha,
                1
            )

        if math.abs(
            value
            - math.floor(
                value + 0.5
            )
        ) < 0.0001 then

            valueLabel.Text =
                tostring(
                    math.floor(
                        value + 0.5
                    )
                )

        else

            valueLabel.Text =
                string.format(
                    "%.2f",
                    value
                )

        end

    end

    local function setFromX(
        x,
        fireCallback
    )

        local width =
            math.max(
                bar.AbsoluteSize.X,
                1
            )

        local alpha =
            math.clamp(
                (
                    x
                    - bar.AbsolutePosition.X
                )
                / width,
                0,
                1
            )

        local raw =
            minimum
            + (
                maximum
                - minimum
            )
            * alpha

        value =
            math.clamp(
                math.floor(
                    (
                        raw
                        - minimum
                    )
                    / step
                    + 0.5
                )
                * step
                + minimum,
                minimum,
                maximum
            )

        render()

        if fireCallback
            and callback then

            task.spawn(
                callback,
                value
            )

        end

    end

    hitbox.InputBegan:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or input.UserInputType ==
                Enum.UserInputType.Touch then

                dragging = true

                setFromX(
                    input.Position.X,
                    true
                )

            end

        end
    )

    UserInputService.InputChanged:Connect(
        function(input)

            if dragging
                and (
                    input.UserInputType ==
                        Enum.UserInputType.MouseMovement
                    or input.UserInputType ==
                        Enum.UserInputType.Touch
                ) then

                setFromX(
                    input.Position.X,
                    true
                )

            end

        end
    )

    UserInputService.InputEnded:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or input.UserInputType ==
                Enum.UserInputType.Touch then

                dragging = false

            end

        end
    )

    registerThemeRefresh(
        function()

            if holder.Parent then

                holder.BackgroundColor3 =
                    Theme.Row

                holderStroke.Color =
                    Theme.Border

                label.TextColor3 =
                    Theme.Text

                valueLabel.TextColor3 =
                    Theme.Muted

                bar.BackgroundColor3 =
                    Theme.Input

                fill.BackgroundColor3 =
                    Theme.ToggleOn

            end

        end
    )

    render()

    return holder

end

-- ============================================================================
-- NUMBER BOX
-- ============================================================================

local function numberBox(
    parent,
    name,
    defaultValue,
    callback
)

    local holder = create("Frame", {

        Name =
            "NumberBox_" ..
            tostring(name),

        Size = UDim2.new(
            1,
            0,
            0,
            48
        ),

        BackgroundColor3 =
            Theme.Row,

        BackgroundTransparency =
            0.08,

        BorderSizePixel = 0,

        Parent = parent
    })

    corner(
        holder,
        5
    )

    local holderStroke =
        stroke(
            holder,
            Theme.Border,
            0.35
        )

    local label = create("TextLabel", {

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            9,
            0
        ),

        Size = UDim2.new(
            1,
            -18,
            0,
            22
        ),

        Font =
            Enum.Font.GothamSemibold,

        Text =
            tostring(name),

        TextColor3 =
            Theme.Text,

        TextSize = 11,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        Parent = holder
    })

    local box = create("TextBox", {

        Position = UDim2.fromOffset(
            7,
            23
        ),

        Size = UDim2.new(
            1,
            -14,
            0,
            20
        ),

        BackgroundColor3 =
            Theme.Input,

        BorderSizePixel = 0,

        ClearTextOnFocus = false,

        Font =
            Enum.Font.GothamSemibold,

        Text =
            tostring(
                defaultValue
                or 0
            ),

        TextColor3 =
            Theme.Text,

        PlaceholderText = "0",

        PlaceholderColor3 =
            Theme.Placeholder,

        TextSize = 10,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        Parent = holder
    })

    corner(
        box,
        3
    )

    box.FocusLost:Connect(
        function()

            local value =
                tonumber(
                    box.Text
                )
                or 0

            box.Text =
                tostring(value)

            if callback then

                task.spawn(
                    callback,
                    value
                )

            end

        end
    )

    registerThemeRefresh(
        function()

            if holder.Parent then

                holder.BackgroundColor3 =
                    Theme.Row

                holderStroke.Color =
                    Theme.Border

                label.TextColor3 =
                    Theme.Text

                box.BackgroundColor3 =
                    Theme.Input

                box.TextColor3 =
                    Theme.Text

                box.PlaceholderColor3 =
                    Theme.Placeholder

            end

        end
    )

    return holder

end

-- ============================================================================
-- TEXT BOX
-- ============================================================================

local function textBox(
    parent,
    name,
    placeholder,
    callback
)

    local holder = create("Frame", {

        Name =
            "TextBox_" ..
            tostring(name),

        Size = UDim2.new(
            1,
            0,
            0,
            48
        ),

        BackgroundColor3 =
            Theme.Row,

        BackgroundTransparency =
            0.08,

        BorderSizePixel = 0,

        Parent = parent
    })

    corner(
        holder,
        5
    )

    local holderStroke =
        stroke(
            holder,
            Theme.Border,
            0.35
        )

    local label = create("TextLabel", {

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            9,
            0
        ),

        Size = UDim2.new(
            1,
            -18,
            0,
            22
        ),

        Font =
            Enum.Font.GothamSemibold,

        Text =
            tostring(name),

        TextColor3 =
            Theme.Text,

        TextSize = 11,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextTruncate =
            Enum.TextTruncate.AtEnd,

        Parent = holder
    })

    local box = create("TextBox", {

        Position = UDim2.fromOffset(
            7,
            23
        ),

        Size = UDim2.new(
            1,
            -14,
            0,
            20
        ),

        BackgroundColor3 =
            Theme.Input,

        BorderSizePixel = 0,

        ClearTextOnFocus = false,

        Font =
            Enum.Font.GothamSemibold,

        Text = "",

        TextColor3 =
            Theme.Text,

        PlaceholderText =
            tostring(
                placeholder
                or ""
            ),

        PlaceholderColor3 =
            Theme.Placeholder,

        TextSize = 10,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        Parent = holder
    })

    corner(
        box,
        3
    )

    box.FocusLost:Connect(
        function()

            if callback then

                task.spawn(
                    callback,
                    box.Text
                )

            end

        end
    )

    registerThemeRefresh(
        function()

            if holder.Parent then

                holder.BackgroundColor3 =
                    Theme.Row

                holderStroke.Color =
                    Theme.Border

                label.TextColor3 =
                    Theme.Text

                box.BackgroundColor3 =
                    Theme.Input

                box.TextColor3 =
                    Theme.Text

                box.PlaceholderColor3 =
                    Theme.Placeholder

            end

        end
    )

    return holder

end

-- ============================================================================
-- INFO CARD
-- ============================================================================

local function infoCard(
    parent,
    text,
    height,
    textColor
)

    local holder = create("Frame", {

        Size = UDim2.new(
            1,
            0,
            0,
            height or 46
        ),

        BackgroundColor3 =
            Theme.Row,

        BackgroundTransparency =
            0.08,

        BorderSizePixel = 0,

        Parent = parent
    })

    corner(
        holder,
        5
    )

    local holderStroke =
        stroke(
            holder,
            Theme.Border,
            0.35
        )

    local label = create("TextLabel", {

        Position = UDim2.fromOffset(
            9,
            0
        ),

        Size = UDim2.new(
            1,
            -18,
            1,
            0
        ),

        BackgroundTransparency = 1,

        Text =
            tostring(
                text or ""
            ),

        TextWrapped = true,

        TextColor3 =
            textColor
            or Theme.Text,

        Font =
            Enum.Font.GothamSemibold,

        TextSize = 11,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextYAlignment =
            Enum.TextYAlignment.Center,

        Parent = holder
    })

    registerThemeRefresh(
        function()

            if holder.Parent then

                holder.BackgroundColor3 =
                    Theme.Row

                holderStroke.Color =
                    Theme.Border

                if not textColor then

                    label.TextColor3 =
                        Theme.Text

                end

            end

        end
    )

    return label

end

-- ============================================================================
-- FEATURE CARD
-- ============================================================================

local function featureCard(
    parent,
    titleText,
    items
)

    local itemHeight = 18

    local height =
        31
        + (#items * itemHeight)
        + 8

    local holder = create("Frame", {

        Size = UDim2.new(
            1,
            0,
            0,
            height
        ),

        BackgroundColor3 =
            Theme.Row,

        BackgroundTransparency =
            0.08,

        BorderSizePixel = 0,

        Parent = parent
    })

    corner(
        holder,
        5
    )

    local holderStroke =
        stroke(
            holder,
            Theme.Border,
            0.32
        )

    local titleLabel = create(
        "TextLabel",
        {

            Position =
                UDim2.fromOffset(
                    11,
                    7
                ),

            Size =
                UDim2.new(
                    1,
                    -22,
                    0,
                    17
                ),

            BackgroundTransparency =
                1,

            Text =
                string.upper(
                    tostring(
                        titleText
                        or "FEATURES"
                    )
                ),

            TextColor3 =
                Theme.Muted,

            Font =
                Enum.Font.GothamBold,

            TextSize = 9,

            TextXAlignment =
                Enum.TextXAlignment.Left,

            Parent = holder
        }
    )

    local dots = {}
    local labels = {}

    for index, item in ipairs(items) do

        local y =
            29
            + (
                (index - 1)
                * itemHeight
            )

        local dot = create("Frame", {

            Position =
                UDim2.fromOffset(
                    12,
                    y + 6
                ),

            Size =
                UDim2.fromOffset(
                    4,
                    4
                ),

            BackgroundColor3 =
                Theme.Text,

            BorderSizePixel = 0,

            Parent = holder
        })

        corner(
            dot,
            3
        )

        table.insert(
            dots,
            dot
        )

        local itemLabel =
            create(
                "TextLabel",
                {

                    Position =
                        UDim2.fromOffset(
                            23,
                            y
                        ),

                    Size =
                        UDim2.new(
                            1,
                            -34,
                            0,
                            itemHeight
                        ),

                    BackgroundTransparency =
                        1,

                    Text =
                        tostring(item),

                    TextColor3 =
                        Theme.Text,

                    Font =
                        Enum.Font.GothamSemibold,

                    TextSize = 10,

                    TextXAlignment =
                        Enum.TextXAlignment.Left,

                    TextTruncate =
                        Enum.TextTruncate.AtEnd,

                    Parent =
                        holder
                }
            )

        table.insert(
            labels,
            itemLabel
        )

    end

    registerThemeRefresh(
        function()

            if holder.Parent then

                holder.BackgroundColor3 =
                    Theme.Row

                holderStroke.Color =
                    Theme.Border

                titleLabel.TextColor3 =
                    Theme.Muted

                for _, dot in ipairs(dots) do

                    dot.BackgroundColor3 =
                        Theme.Text

                end

                for _, itemLabel in ipairs(labels) do

                    itemLabel.TextColor3 =
                        Theme.Text

                end

            end

        end
    )

    return holder

end

-- ============================================================================
-- ACTION BUTTON
-- ============================================================================

local function actionButton(
    parent,
    name,
    callback
)

    local row = create("Frame", {

        Name =
            "Button_" ..
            tostring(name),

        Size = UDim2.new(
            1,
            0,
            0,
            32
        ),

        BackgroundColor3 =
            Theme.Row,

        BackgroundTransparency =
            0.08,

        BorderSizePixel = 0,

        Parent = parent
    })

    corner(
        row,
        5
    )

    local rowStroke =
        stroke(
            row,
            Theme.Border,
            0.38
        )

    local label = create("TextLabel", {

        Position =
            UDim2.fromOffset(
                9,
                0
            ),

        Size =
            UDim2.new(
                1,
                -34,
                1,
                0
            ),

        BackgroundTransparency = 1,

        Text =
            tostring(name),

        TextColor3 =
            Theme.Text,

        Font =
            Enum.Font.GothamSemibold,

        TextSize = 11,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextTruncate =
            Enum.TextTruncate.AtEnd,

        Parent = row
    })

    local arrow = create("TextLabel", {

        AnchorPoint =
            Vector2.new(
                1,
                0.5
            ),

        Position =
            UDim2.new(
                1,
                -9,
                0.5,
                0
            ),

        Size =
            UDim2.fromOffset(
                14,
                18
            ),

        BackgroundTransparency = 1,

        Text = ">",

        TextColor3 =
            Theme.Muted,

        Font =
            Enum.Font.GothamBold,

        TextSize = 11,

        Parent = row
    })

    local hitbox = create("TextButton", {

        Size =
            UDim2.fromScale(
                1,
                1
            ),

        BackgroundTransparency = 1,

        Text = "",

        AutoButtonColor = false,

        Parent = row
    })

    hitbox.Activated:Connect(
        function()

            tween(
                row,
                {
                    BackgroundColor3 =
                        Theme.RowHover
                },
                0.06
            )

            task.delay(
                0.08,
                function()

                    if row.Parent then

                        tween(
                            row,
                            {
                                BackgroundColor3 =
                                    Theme.Row
                            },
                            0.08
                        )

                    end

                end
            )

            if callback then
                task.spawn(callback)
            end

        end
    )

    bindRowHover(
        hitbox,
        row,
        rowStroke
    )

    registerThemeRefresh(
        function()

            if row.Parent then

                row.BackgroundColor3 =
                    Theme.Row

                rowStroke.Color =
                    Theme.Border

                label.TextColor3 =
                    Theme.Text

                arrow.TextColor3 =
                    Theme.Muted

            end

        end
    )

    return row

end

-- ============================================================================
-- SPACER
-- ============================================================================

local function spacer(parent, height)

    return create("Frame", {

        Name = "Spacer",

        Size = UDim2.new(
            1,
            0,
            0,
            math.max(
                0,
                tonumber(height)
                or 6
            )
        ),

        BackgroundTransparency = 1,

        Parent = parent
    })

end

-- ============================================================================
-- SIDEBAR GEOMETRY
-- ============================================================================

local function updateSidebarGeometry(
    instant
)

    local sidebarWidth =
        sidebarExpanded
        and SIDEBAR_EXPANDED
        or SIDEBAR_COLLAPSED

    local sidebarTarget =
        UDim2.new(
            0,
            sidebarWidth,
            1,
            -TOPBAR_HEIGHT
        )

    local contentPosition =
        UDim2.fromOffset(
            sidebarWidth + CONTENT_GAP,
            TOPBAR_HEIGHT + CONTENT_GAP
        )

    local contentSize =
        UDim2.new(
            1,
            -(
                sidebarWidth
                + CONTENT_GAP * 2
            ),
            1,
            -(
                TOPBAR_HEIGHT
                + CONTENT_GAP * 2
            )
        )

    if instant then

        sidebar.Size =
            sidebarTarget

        content.Position =
            contentPosition

        content.Size =
            contentSize

    else

        tween(
            sidebar,
            {
                Size =
                    sidebarTarget
            },
            0.14
        )

        tween(
            content,
            {
                Position =
                    contentPosition,

                Size =
                    contentSize
            },
            0.14
        )

    end

    for _, data in pairs(sideButtons) do

        tween(
            data.Label,
            {
                TextTransparency =
                    sidebarExpanded
                    and 0
                    or 1
            },
            instant
            and 0
            or 0.1
        )

    end

end

-- ============================================================================
-- MINIMIZED FLOATING BOX
-- ============================================================================

local miniBox = create("TextButton", {

    Name = "MiniBox",

    AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        ),

    Position =
        UDim2.fromScale(
            0.5,
            0.5
        ),

    Size =
        UDim2.fromOffset(
            58,
            42
        ),

    BackgroundColor3 =
        Theme.Background,

    BackgroundTransparency =
        0.08,

    BorderSizePixel = 0,

    Text = "",

    AutoButtonColor = false,

    Visible = false,

    Active = true,

    Parent = gui
})

corner(
    miniBox,
    9
)

local miniStroke =
    stroke(
        miniBox,
        Theme.BorderBright,
        0.35
    )

local miniLogo = create("TextLabel", {

    AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        ),

    Position =
        UDim2.fromScale(
            0.5,
            0.5
        ),

    Size =
        UDim2.fromScale(
            0.9,
            0.8
        ),

    BackgroundTransparency = 1,

    Text = "ZH",

    TextColor3 =
        Theme.Text,

    Font =
        Enum.Font.GothamBold,

    TextSize = 14,

    Parent = miniBox
})

local miniDot = create("Frame", {

    AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        ),

    Position =
        UDim2.new(
            1,
            -7,
            0,
            7
        ),

    Size =
        UDim2.fromOffset(
            4,
            4
        ),

    BackgroundColor3 =
        Theme.Text,

    BorderSizePixel = 0,

    Parent = miniBox
})

corner(
    miniDot,
    4
)

-- ============================================================================
-- THEME
-- ============================================================================

local function applyTheme(name)

    if not ThemePresets[name] then
        return
    end

    currentThemeName =
        name

    Theme =
        ThemePresets[name]

    main.BackgroundColor3 =
        Theme.Background

    mainStroke.Color =
        Theme.BorderBright

    topbar.BackgroundColor3 =
        Theme.Topbar

    topbarBottom.BackgroundColor3 =
        Theme.Topbar

    sidebar.BackgroundColor3 =
        Theme.Sidebar

    sidebarLine.BackgroundColor3 =
        Theme.Border

    title.TextColor3 =
        Theme.Text

    subtitle.TextColor3 =
        Theme.Muted

    topLine.BackgroundColor3 =
        Theme.Border

    minimizeLine.BackgroundColor3 =
        Theme.Text

    close.TextColor3 =
        Theme.Text

    menuButton.TextColor3 =
        Theme.Muted

    themeCenter.BackgroundColor3 =
        Theme.Muted

    miniBox.BackgroundColor3 =
        Theme.Background

    miniStroke.Color =
        Theme.BorderBright

    miniLogo.TextColor3 =
        Theme.Text

    miniDot.BackgroundColor3 =
        Theme.Text

    for _, ray in ipairs(themeRays) do

        ray.BackgroundColor3 =
            Theme.Muted

    end

    for _, refresh in ipairs(
        themeRefreshers
    ) do

        pcall(refresh)

    end

    refreshSideTabs()

    for _, pageData in pairs(
        pages
    ) do

        refreshPageSections(
            pageData
        )

    end

end

-- ============================================================================
-- RESPONSIVE SIZE
-- ============================================================================

local function updateResponsiveSize(
    instant
)

    local camera =
        workspace.CurrentCamera

    local viewport =
        camera
        and camera.ViewportSize
        or Vector2.new(
            BASE_WIDTH + 40,
            BASE_HEIGHT + 40
        )

    local width =
        math.min(
            BASE_WIDTH,
            math.max(
                330,
                viewport.X - 20
            )
        )

    local height =
        math.min(
            BASE_HEIGHT,
            math.max(
                300,
                viewport.Y - 30
            )
        )

    local target =
        minimized

        and UDim2.fromOffset(
            width,
            TOPBAR_HEIGHT
        )

        or UDim2.fromOffset(
            width,
            height
        )

    if instant then

        main.Size =
            target

    else

        tween(
            main,
            {
                Size = target
            },
            0.14
        )

    end

    updateSidebarGeometry(
        instant
    )

end

-- ============================================================================
-- MINIMIZE / RESTORE
-- ============================================================================

local function setMinimized(value)

    minimized =
        value == true

    if minimized then

        sidebar.Visible = false
        content.Visible = false

        topbar.Visible = false

        miniBox.Visible = true

        tween(
            main,
            {
                Size = UDim2.fromOffset(
                    58,
                    42
                )
            },
            0.16
        )

        task.delay(
            0.02,
            function()

                if main.Parent
                    and minimized then

                    main.Visible = false

                end

            end
        )

    else

        main.Visible = true

        topbar.Visible = true

        sidebar.Visible = true
        content.Visible = true

        miniBox.Visible = false

        updateResponsiveSize(false)

    end

end

-- ============================================================================
-- BUTTON CONNECTIONS
-- ============================================================================

menuButton.Activated:Connect(
    function()

        sidebarExpanded =
            not sidebarExpanded

        updateSidebarGeometry(
            false
        )

    end
)

menuButton.MouseEnter:Connect(
    function()

        tween(
            menuButton,
            {
                TextColor3 =
                    Theme.Text
            },
            0.08
        )

    end
)

menuButton.MouseLeave:Connect(
    function()

        tween(
            menuButton,
            {
                TextColor3 =
                    Theme.Muted
            },
            0.08
        )

    end
)

themeButton.Activated:Connect(
    function()

        applyTheme(
            currentThemeName == "Dark"
            and "Light"
            or "Dark"
        )

    end
)

themeButton.MouseEnter:Connect(
    function()

        themeCenter.BackgroundColor3 =
            Theme.Text

        for _, ray in ipairs(
            themeRays
        ) do

            ray.BackgroundColor3 =
                Theme.Text

        end

    end
)

themeButton.MouseLeave:Connect(
    function()

        themeCenter.BackgroundColor3 =
            Theme.Muted

        for _, ray in ipairs(
            themeRays
        ) do

            ray.BackgroundColor3 =
                Theme.Muted

        end

    end
)

minimizeButton.Activated:Connect(
    function()

        setMinimized(
            not minimized
        )

    end
)

minimizeButton.MouseEnter:Connect(
    function()

        tween(
            minimizeLine,
            {
                BackgroundColor3 =
                    Theme.Muted
            },
            0.08
        )

    end
)

minimizeButton.MouseLeave:Connect(
    function()

        tween(
            minimizeLine,
            {
                BackgroundColor3 =
                    Theme.Text
            },
            0.08
        )

    end
)

close.MouseEnter:Connect(
    function()

        tween(
            close,
            {
                TextColor3 =
                    Color3.fromRGB(
                        255,
                        100,
                        100
                    )
            },
            0.08
        )

    end
)

close.MouseLeave:Connect(
    function()

        tween(
            close,
            {
                TextColor3 =
                    Theme.Text
            },
            0.08
        )

    end
)

close.Activated:Connect(
    function()

        guiAlive = false

        gui:Destroy()

    end
)

-- ============================================================================
-- MINI BOX HOVER
-- ============================================================================

miniBox.MouseEnter:Connect(
    function()

        tween(
            miniBox,
            {
                BackgroundColor3 =
                    Theme.RowHover
            },
            0.1
        )

        tween(
            miniLogo,
            {
                TextColor3 =
                    Theme.Text
            },
            0.1
        )

    end
)

miniBox.MouseLeave:Connect(
    function()

        tween(
            miniBox,
            {
                BackgroundColor3 =
                    Theme.Background
            },
            0.1
        )

    end
)

miniBox.Activated:Connect(
    function()

        setMinimized(false)

    end
)

-- ============================================================================
-- CAMERA RESIZE
-- ============================================================================

local camera =
    workspace.CurrentCamera

if camera then

    camera:GetPropertyChangedSignal(
        "ViewportSize"
    ):Connect(
        function()

            updateResponsiveSize(
                true
            )

        end
    )

end

-- ============================================================================
-- MAIN WINDOW DRAGGING
-- ============================================================================

local windowDragging = false
local windowDragStart = nil
local windowStartPosition = nil

topbar.InputBegan:Connect(
    function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            windowDragging = true

            windowDragStart =
                input.Position

            windowStartPosition =
                main.Position

        end

    end
)

UserInputService.InputChanged:Connect(
    function(input)

        if windowDragging
            and (
                input.UserInputType ==
                    Enum.UserInputType.MouseMovement
                or input.UserInputType ==
                    Enum.UserInputType.Touch
            ) then

            local delta =
                input.Position
                - windowDragStart

            main.Position =
                UDim2.new(

                    windowStartPosition.X.Scale,

                    windowStartPosition.X.Offset
                        + delta.X,

                    windowStartPosition.Y.Scale,

                    windowStartPosition.Y.Offset
                        + delta.Y
                )

        end

    end
)

UserInputService.InputEnded:Connect(
    function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            windowDragging = false

        end

    end
)

-- ============================================================================
-- MINI BOX DRAGGING
-- ============================================================================

local miniDragging = false
local miniDragStart = nil
local miniStartPosition = nil
local miniMoved = false

miniBox.InputBegan:Connect(
    function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            miniDragging = true
            miniMoved = false

            miniDragStart =
                input.Position

            miniStartPosition =
                miniBox.Position

        end

    end
)

UserInputService.InputChanged:Connect(
    function(input)

        if miniDragging
            and (
                input.UserInputType ==
                    Enum.UserInputType.MouseMovement
                or input.UserInputType ==
                    Enum.UserInputType.Touch
            ) then

            local delta =
                input.Position
                - miniDragStart

            if delta.Magnitude > 5 then
                miniMoved = true
            end

            miniBox.Position =
                UDim2.new(

                    miniStartPosition.X.Scale,

                    miniStartPosition.X.Offset
                        + delta.X,

                    miniStartPosition.Y.Scale,

                    miniStartPosition.Y.Offset
                        + delta.Y
                )

        end

    end
)

UserInputService.InputEnded:Connect(
    function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            miniDragging = false

        end

    end
)

-- ============================================================================
-- LIBRARY
-- ============================================================================

local Library = {

    Version = "2.0.0",

    Themes = {
        "Dark",
        "Light"
    },

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

-- ============================================================================
-- NORMALIZE CONFIG
-- ============================================================================

local function normalizeConfig(
    value,
    fallbackName
)

    if type(value) == "table" then
        return value
    end

    return {

        Name =
            value ~= nil
            and tostring(value)
            or fallbackName
    }

end

-- ============================================================================
-- CREATE WINDOW
-- ============================================================================

-- ============================================================================
-- BUILT-IN ZEHUB UTILITY TABS
-- ============================================================================

local function cleanSubtitle(value)

    local text = tostring(value or "")

    text = text:gsub("%s*[Ll][Ii][Tt][Ee]%s*", " ")
    text = text:gsub("%s+", " ")

    return text:match("^%s*(.-)%s*$") or ""

end

local function createUtilityCard(parent, height)

    local holder = create("Frame", {

        Size = UDim2.new(
            1,
            0,
            0,
            height or 58
        ),

        BackgroundColor3 = Theme.Row,

        BackgroundTransparency = 0.08,

        BorderSizePixel = 0,

        Parent = parent
    })

    corner(holder, 6)

    local holderStroke = stroke(
        holder,
        Theme.Border,
        0.35
    )

    registerThemeRefresh(function()

        if holder.Parent then
            holder.BackgroundColor3 = Theme.Row
            holderStroke.Color = Theme.Border
        end

    end)

    return holder

end

local function createUtilityLabel(parent, text, position, size, textSize, color, bold)

    return create("TextLabel", {

        Position = position,

        Size = size,

        BackgroundTransparency = 1,

        Text = tostring(text or ""),

        TextColor3 = color or Theme.Text,

        Font = bold and Enum.Font.GothamSemibold or Enum.Font.GothamMedium,

        TextSize = textSize or 11,

        TextXAlignment = Enum.TextXAlignment.Left,

        TextYAlignment = Enum.TextYAlignment.Center,

        TextTruncate = Enum.TextTruncate.AtEnd,

        Parent = parent
    })

end

local function createDynamicInfoCard(parent, titleText, initialText)

    local holder = createUtilityCard(parent, 58)

    local titleLabel = createUtilityLabel(
        holder,
        titleText,
        UDim2.fromOffset(13, 8),
        UDim2.new(1, -26, 0, 18),
        11,
        Theme.Text,
        true
    )

    local valueLabel = createUtilityLabel(
        holder,
        initialText,
        UDim2.fromOffset(13, 29),
        UDim2.new(1, -26, 0, 18),
        10,
        Theme.Muted,
        false
    )

    registerThemeRefresh(function()

        if holder.Parent then
            titleLabel.TextColor3 = Theme.Text
            valueLabel.TextColor3 = Theme.Muted
        end

    end)

    return {
        Root = holder,
        Title = titleLabel,
        Value = valueLabel
    }

end

local infoUserCard
local infoAvatarCard

local function addBuiltInTabs(window)

    local state = {
        HideUsername = false,
        HideAvatar = false
    }

    local profileTab = window:CreateTab({
        Name = "Profile",
        Icon = "Profile"
    })

    local profileSection = profileTab:CreateSection({
        Name = "Profile"
    })

    local profileCard = createUtilityCard(profileSection.Root, 76)

    local avatar = create("ImageLabel", {

        Position = UDim2.fromOffset(12, 12),

        Size = UDim2.fromOffset(52, 52),

        BackgroundColor3 = Theme.Input,

        BackgroundTransparency = 0.05,

        BorderSizePixel = 0,

        Image = "",

        ScaleType = Enum.ScaleType.Crop,

        Parent = profileCard
    })

    corner(avatar, 8)

    local avatarStroke = stroke(
        avatar,
        Theme.Border,
        0.25
    )

    local displayLabel = createUtilityLabel(
        profileCard,
        "",
        UDim2.fromOffset(76, 14),
        UDim2.new(1, -90, 0, 20),
        12,
        Theme.Text,
        true
    )

    local usernameLabel = createUtilityLabel(
        profileCard,
        "",
        UDim2.fromOffset(76, 37),
        UDim2.new(1, -90, 0, 18),
        10,
        Theme.Muted,
        false
    )

    local hideUsernameToggle = profileSection:CreateToggle({
        Name = "Hide Username",
        Default = false,
        Callback = function(value)
            state.HideUsername = value == true

            if state.HideUsername then
                usernameLabel.Text = "Username hidden"
                displayLabel.Text = "ZeHub Player"
            else
                usernameLabel.Text = "@" .. tostring(player.Name)
                displayLabel.Text = tostring(player.DisplayName or player.Name)
            end

            local status = infoUserCard
            if status then
                status.Value.Text = state.HideUsername and "Username hidden" or ("@" .. tostring(player.Name))
            end
        end
    })

    local hideAvatarToggle = profileSection:CreateToggle({
        Name = "Hide Avatar",
        Default = false,
        Callback = function(value)
            state.HideAvatar = value == true
            avatar.ImageTransparency = state.HideAvatar and 1 or 0

            if state.HideAvatar then
                avatar.BackgroundColor3 = Theme.Input
            end

            if infoAvatarCard then
                infoAvatarCard.Value.Text = state.HideAvatar and "Avatar hidden" or "Avatar visible"
            end
        end
    })

    local profileNote = profileSection:CreateParagraph({
        Text = "Your profile privacy settings are local to this UI. Changes are reflected on the Info page immediately.",
        Height = 48
    })

    local infoTab = window:CreateTab({
        Name = "Info",
        Icon = "Info"
    })

    local infoSection = infoTab:CreateSection({
        Name = "User"
    })

    infoUserCard = createDynamicInfoCard(
        infoSection.Root,
        "User",
        "@" .. tostring(player.Name)
    )

    infoAvatarCard = createDynamicInfoCard(
        infoSection.Root,
        "Avatar",
        "Avatar visible"
    )

    local accountCard = createDynamicInfoCard(
        infoSection.Root,
        "Account",
        "User ID: " .. tostring(player.UserId)
    )

    local usefulSection = infoTab:CreateSection({
        Name = "Useful Info"
    })

    usefulSection:CreateFeatureCard({
        Title = "Useful Info",
        Items = {
            "Settings are grouped into separate tabs.",
            "Profile privacy changes update the Info page.",
            "The window supports mouse, touch and minimize controls.",
            "Theme changes are applied without rebuilding the window."
        }
    })

    usefulSection:CreateParagraph({
        Text = "ZeHub is designed around a compact glass layout with simple controls and low visual noise.",
        Height = 50
    })

    local configTab = window:CreateTab({
        Name = "Configs",
        Icon = "Settings"
    })

    local configSection = configTab:CreateSection({
        Name = "Appearance"
    })

    configSection:CreateButton({
        Name = "Toggle Theme",
        Callback = function()
            window:ToggleTheme()
        end
    })

    configSection:CreateButton({
        Name = "Expand Sidebar",
        Callback = function()
            window:SetSidebarExpanded(true)
        end
    })

    configSection:CreateButton({
        Name = "Collapse Sidebar",
        Callback = function()
            window:SetSidebarExpanded(false)
        end
    })

    configSection:CreateButton({
        Name = "Minimize Window",
        Callback = function()
            window:SetMinimized(true)
        end
    })

    configSection:CreateParagraph({
        Text = "Configuration controls affect the current window session. Your existing game controls and callbacks are not changed.",
        Height = 50
    })

    local changelogTab = window:CreateTab({
        Name = "Changelog",
        Icon = "Changelog"
    })

    local changelogSection = changelogTab:CreateSection({
        Name = "Updates"
    })

    changelogSection:CreateFeatureCard({
        Title = "Recent",
        Items = {
            "Refined glass transparency and contrast.",
            "Added Profile privacy controls.",
            "Added Configs and Info tabs.",
            "Added a compact changelog and useful info."
        }
    })

    changelogSection:CreateParagraph({
        Text = "ZeHub UI • Natural Glass edition",
        Height = 42
    })

    local function updateProfile()

        if state.HideUsername then
            displayLabel.Text = "ZeHub Player"
            usernameLabel.Text = "Username hidden"
        else
            displayLabel.Text = tostring(player.DisplayName or player.Name)
            usernameLabel.Text = "@" .. tostring(player.Name)
        end

        avatar.ImageTransparency = state.HideAvatar and 1 or 0

        infoUserCard.Value.Text = state.HideUsername
            and "Username hidden"
            or ("@" .. tostring(player.Name))

        infoAvatarCard.Value.Text = state.HideAvatar
            and "Avatar hidden"
            or "Avatar visible"

    end

    task.spawn(function()

        local ok, image = pcall(function()
            local content = Players:GetUserThumbnailAsync(
                player.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size150x150
            )
            return content
        end)

        if ok and image then
            avatar.Image = image
        end

        updateProfile()

    end)

    -- Keep references alive for the callbacks above.
    return {
        Profile = profileTab,
        Configs = configTab,
        Info = infoTab,
        Changelog = changelogTab
    }

end


-- ============================================================================
-- ZE HUB GAME TESTING FEATURES
-- ============================================================================
-- These are intended for games/projects the developer owns or controls.
-- The existing ZeHub UI is not rebuilt or restyled; this only adds a new tab
-- and a separate world/overlay feature layer.
-- ============================================================================

local function createGameTestingFeatures(window)

    if not window or not window._alive then
        return nil
    end

    local RunService = game:GetService("RunService")
    local Camera = workspace.CurrentCamera
    local UIS = UserInputService

    local state = {
        FOV = false,
        FOVSize = 120,
        ESP = false,
        ESPName = true,
        ESPDistance = true,
        ESPHealth = true,
        ESPBox = false,
        Aimbot = false,
        AimFOV = 120,
        AimSmooth = 0.18,
        Triggerbot = false,
        TriggerDelay = 0,
        Fly = false,
        FlySpeed = 60,
        Noclip = false,
        JumpPower = 50,
        Kills = 0,
        Deaths = 0,
        Shots = 0,
        Hits = 0,
        SessionStart = os.clock(),
        BestKills = 0,
        BestKDRatio = 0,
        TrainingHistory = {},
        LastTrigger = 0,
        Connections = {},
        EspObjects = {},
        FlyObjects = nil,
        OriginalWalkSpeed = nil,
        OriginalJumpPower = nil,
    }

    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(state.Connections, connection)
        return connection
    end

    local function getCharacter(target)
        if not target then
            return nil
        end

        local character = target.Character
        if not character then
            return nil
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")

        if not humanoid or humanoid.Health <= 0 or not root then
            return nil
        end

        return character, humanoid, root
    end

    local function getDistance(target)
        local character, _, root = getCharacter(target)
        if not character or not Camera then
            return math.huge
        end

        local localCharacter = player.Character
        local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
        if not localRoot then
            return math.huge
        end

        return (root.Position - localRoot.Position).Magnitude
    end

    local function getScreenTarget(target)
        local character, humanoid, root = getCharacter(target)
        if not character or not Camera then
            return nil
        end

        local viewport = Camera.ViewportSize
        local screen, visible = Camera:WorldToViewportPoint(root.Position)
        if not visible or screen.Z <= 0 then
            return nil
        end

        local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
        local point = Vector2.new(screen.X, screen.Y)

        return character, humanoid, root, point, (point - center).Magnitude
    end

    local function getBestTarget(maxFov)
        local bestPlayer = nil
        local bestDistance = maxFov or math.huge

        for _, target in ipairs(Players:GetPlayers()) do
            if target ~= player then
                local result = getScreenTarget(target)
                if result then
                    local _, _, _, _, screenDistance = result
                    if screenDistance <= bestDistance then
                        bestDistance = screenDistance
                        bestPlayer = target
                    end
                end
            end
        end

        return bestPlayer
    end

    local function destroyEsp(target)
        local data = state.EspObjects[target]
        if not data then
            return
        end

        if data.Billboard then
            data.Billboard:Destroy()
        end

        if data.Box then
            data.Box:Destroy()
        end

        state.EspObjects[target] = nil
    end

    local function ensureEsp(target)
        if target == player then
            return nil
        end

        local character, humanoid, root = getCharacter(target)
        if not character or not humanoid or not root then
            destroyEsp(target)
            return nil
        end

        local data = state.EspObjects[target]

        if data and data.Character ~= character then
            destroyEsp(target)
            data = nil
        end

        if not data then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ZeHubESP"
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.fromOffset(220, 54)
            billboard.StudsOffset = Vector3.new(0, 3.4, 0)
            billboard.MaxDistance = 5000
            billboard.Parent = root

            local label = Instance.new("TextLabel")
            label.Name = "Info"
            label.BackgroundTransparency = 1
            label.Size = UDim2.fromScale(1, 1)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 11
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextStrokeTransparency = 0.5
            label.TextWrapped = true
            label.Parent = billboard

            local box = Instance.new("SelectionBox")
            box.Name = "ZeHubESPBox"
            box.Adornee = character
            box.LineThickness = 0.025
            box.SurfaceTransparency = 1
            box.Color3 = Color3.new(1, 1, 1)
            box.Visible = false
            box.Parent = character

            data = {
                Character = character,
                Humanoid = humanoid,
                Root = root,
                Billboard = billboard,
                Label = label,
                Box = box,
            }

            state.EspObjects[target] = data
        end

        local distance = getDistance(target)
        local parts = {}

        if state.ESPName then
            table.insert(parts, target.DisplayName or target.Name)
        end

        if state.ESPDistance then
            table.insert(parts, string.format("%.0f studs", distance))
        end

        if state.ESPHealth then
            table.insert(parts, string.format("HP %.0f", humanoid.Health))
        end

        data.Label.Text = table.concat(parts, "  |  ")
        data.Label.Visible = state.ESP and #parts > 0
        data.Box.Visible = state.ESP and state.ESPBox
        data.Billboard.Enabled = state.ESP and #parts > 0

        return data
    end

    local function refreshEsp()
        if not state.ESP then
            for target in pairs(state.EspObjects) do
                destroyEsp(target)
            end
            return
        end

        for _, target in ipairs(Players:GetPlayers()) do
            if target ~= player then
                ensureEsp(target)
            end
        end

        for target in pairs(state.EspObjects) do
            if not target.Parent then
                destroyEsp(target)
            end
        end
    end

    local overlayGui = Instance.new("ScreenGui")
    overlayGui.Name = "ZeHubGameTestingOverlay"
    overlayGui.ResetOnSpawn = false
    overlayGui.IgnoreGuiInset = true
    overlayGui.DisplayOrder = 999
    overlayGui.Enabled = true
    overlayGui.Parent = getGuiParent()

    local fovCircle = Instance.new("Frame")
    fovCircle.Name = "FOVCircle"
    fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    fovCircle.Position = UDim2.fromScale(0.5, 0.5)
    fovCircle.Size = UDim2.fromOffset(state.FOVSize * 2, state.FOVSize * 2)
    fovCircle.BackgroundTransparency = 1
    fovCircle.Visible = false
    fovCircle.Parent = overlayGui

    local fovCorner = Instance.new("UICorner")
    fovCorner.CornerRadius = UDim.new(1, 0)
    fovCorner.Parent = fovCircle

    local fovStroke = Instance.new("UIStroke")
    fovStroke.Color = Color3.new(1, 1, 1)
    fovStroke.Transparency = 0.2
    fovStroke.Thickness = 1
    fovStroke.Parent = fovCircle

    local function updateFovCircle()
        fovCircle.Size = UDim2.fromOffset(state.FOVSize * 2, state.FOVSize * 2)
        fovCircle.Visible = state.FOV
    end

    local function getHumanoid()
        local character = player.Character
        return character and character:FindFirstChildOfClass("Humanoid")
    end

    local function setJumpPower(value)
        state.JumpPower = tonumber(value) or 50
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = state.JumpPower
        end
    end

    local function stopFly()
        if state.FlyObjects then
            if state.FlyObjects.LinearVelocity then
                state.FlyObjects.LinearVelocity:Destroy()
            end
            if state.FlyObjects.Attachment then
                state.FlyObjects.Attachment:Destroy()
            end
            state.FlyObjects = nil
        end

        local humanoid = getHumanoid()
        if humanoid then
            humanoid.PlatformStand = false
        end
    end

    local function startFly()
        stopFly()

        local character, humanoid, root = getCharacter(player)
        if not character or not humanoid or not root then
            return
        end

        local attachment = Instance.new("Attachment")
        attachment.Name = "ZeHubFlyAttachment"
        attachment.Parent = root

        local velocity = Instance.new("LinearVelocity")
        velocity.Name = "ZeHubFlyVelocity"
        velocity.Attachment0 = attachment
        velocity.RelativeTo = Enum.ActuatorRelativeTo.World
        velocity.MaxForce = math.huge
        velocity.VectorVelocity = Vector3.zero
        velocity.Parent = root

        state.FlyObjects = {
            Attachment = attachment,
            LinearVelocity = velocity,
        }
    end

    local function updateFly()
        if not state.Fly or not state.FlyObjects then
            return
        end

        local character, humanoid, root = getCharacter(player)
        if not character or not humanoid or not root then
            stopFly()
            startFly()
            return
        end

        local move = humanoid.MoveDirection
        local vertical = 0

        if UIS:IsKeyDown(Enum.KeyCode.Space) or humanoid.Jump then
            vertical += 1
        end

        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            vertical -= 1
        end

        local camera = workspace.CurrentCamera
        local cameraLook = camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
        local horizontalLook = Vector3.new(cameraLook.X, 0, cameraLook.Z)
        if horizontalLook.Magnitude > 0 then
            horizontalLook = horizontalLook.Unit
        end

        local horizontal = move
        if horizontal.Magnitude > 0 then
            horizontal = Vector3.new(horizontal.X, 0, horizontal.Z)
        end

        local velocity = horizontal * state.FlySpeed
        velocity += Vector3.new(0, vertical * state.FlySpeed, 0)

        if velocity.Magnitude == 0 and horizontalLook.Magnitude > 0 and UIS:IsKeyDown(Enum.KeyCode.W) then
            velocity += horizontalLook * state.FlySpeed
        end

        state.FlyObjects.LinearVelocity.VectorVelocity = velocity
    end

    local function setNoclip(value)
        state.Noclip = value == true

        local character = player.Character
        if not character then
            return
        end

        for _, object in ipairs(character:GetDescendants()) do
            if object:IsA("BasePart") then
                object.CanCollide = not state.Noclip
            end
        end
    end

    local function resetMovement()
        stopFly()
        setNoclip(false)
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = state.JumpPower
        end
    end

    local function getKDRatio()
        if state.Deaths <= 0 then
            return state.Kills
        end
        return state.Kills / state.Deaths
    end

    local function recordTraining(reason)
        local entry = {
            Time = os.date("%H:%M:%S"),
            Reason = tostring(reason or "Session"),
            Kills = state.Kills,
            Deaths = state.Deaths,
            KD = getKDRatio(),
            Accuracy = state.Shots > 0 and (state.Hits / state.Shots) * 100 or 0,
        }

        table.insert(state.TrainingHistory, entry)
        while #state.TrainingHistory > 20 do
            table.remove(state.TrainingHistory, 1)
        end
    end

    local function updateBests()
        if state.Kills > state.BestKills then
            state.BestKills = state.Kills
        end

        local kd = getKDRatio()
        if kd > state.BestKDRatio then
            state.BestKDRatio = kd
        end
    end

    local function isEnemy(target)
        if target == player then
            return false
        end

        if player.Team and target.Team and player.Team == target.Team then
            return false
        end

        return getCharacter(target) ~= nil
    end

    local function getCenterRaycast()
        local camera = workspace.CurrentCamera
        if not camera then
            return nil
        end

        local viewport = camera.ViewportSize
        local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
        local ray = camera:ViewportPointToRay(center.X, center.Y)

        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {player.Character}
        params.IgnoreWater = true

        return workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
    end

    local function findPlayerFromInstance(instance)
        if not instance then
            return nil
        end

        local model = instance:FindFirstAncestorOfClass("Model")
        if not model then
            return nil
        end

        for _, target in ipairs(Players:GetPlayers()) do
            if target ~= player and target.Character == model then
                return target
            end
        end

        return nil
    end

    local function tryFire()
        local now = os.clock()
        if now - state.LastTrigger < state.TriggerDelay then
            return
        end

        local character = player.Character
        if not character then
            return
        end

        local tool = character:FindFirstChildOfClass("Tool")
        if not tool then
            return
        end

        state.LastTrigger = now
        state.Shots += 1

        local ok = pcall(function()
            tool:Activate()
        end)

        return ok
    end

    local function connectCharacter(character)
        local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
        if not humanoid then
            return
        end

        state.OriginalJumpPower = humanoid.JumpPower
        humanoid.UseJumpPower = true
        humanoid.JumpPower = state.JumpPower

        connect(humanoid.Died, function()
            state.Deaths += 1
            updateBests()
            recordTraining("Death")
        end)
    end

    local function inspectKillTag(humanoid)
        for _, child in ipairs(humanoid:GetChildren()) do
            if child:IsA("ObjectValue") and string.lower(child.Name) == "creator" and child.Value == player then
                return true
            end
        end
        return false
    end

    local function watchTarget(target)
        if target == player then
            return
        end

        connect(target.CharacterAdded, function(character)
            local humanoid = character:WaitForChild("Humanoid", 5)
            if not humanoid then
                return
            end

            connect(humanoid.Died, function()
                if inspectKillTag(humanoid) then
                    state.Kills += 1
                    updateBests()
                end
            end)
        end)

        if target.Character then
            local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                connect(humanoid.Died, function()
                    if inspectKillTag(humanoid) then
                        state.Kills += 1
                        updateBests()
                    end
                end)
            end
        end
    end

    local testingTab = window:CreateTab({
        Name = "Testing",
        Icon = "Stats"
    })

    local combatSection = testingTab:CreateSection({
        Name = "Combat"
    })

    combatSection:CreateToggle({
        Name = "Aimbot",
        Default = false,
        Callback = function(value)
            state.Aimbot = value == true
        end
    })

    combatSection:CreateSlider({
        Name = "Aim FOV",
        Min = 20,
        Max = 360,
        Default = state.AimFOV,
        Step = 1,
        Callback = function(value)
            state.AimFOV = tonumber(value) or 120
        end
    })

    combatSection:CreateSlider({
        Name = "Aim Smooth",
        Min = 0.02,
        Max = 1,
        Default = state.AimSmooth,
        Step = 0.01,
        Callback = function(value)
            state.AimSmooth = tonumber(value) or 0.18
        end
    })

    combatSection:CreateToggle({
        Name = "Triggerbot",
        Default = false,
        Callback = function(value)
            state.Triggerbot = value == true
        end
    })

    combatSection:CreateSlider({
        Name = "Trigger Delay",
        Min = 0,
        Max = 2,
        Default = 0,
        Step = 0.01,
        Callback = function(value)
            state.TriggerDelay = tonumber(value) or 0
        end
    })

    combatSection:CreateToggle({
        Name = "FOV Circle",
        Default = false,
        Callback = function(value)
            state.FOV = value == true
            updateFovCircle()
        end
    })

    combatSection:CreateSlider({
        Name = "FOV Size",
        Min = 20,
        Max = 360,
        Default = state.FOVSize,
        Step = 1,
        Callback = function(value)
            state.FOVSize = tonumber(value) or 120
            updateFovCircle()
        end
    })

    local visualsSection = testingTab:CreateSection({
        Name = "Visuals"
    })

    visualsSection:CreateToggle({
        Name = "ESP",
        Default = false,
        Callback = function(value)
            state.ESP = value == true
            refreshEsp()
        end
    })

    visualsSection:CreateToggle({
        Name = "ESP Name",
        Default = true,
        Callback = function(value)
            state.ESPName = value == true
            refreshEsp()
        end
    })

    visualsSection:CreateToggle({
        Name = "ESP Distance",
        Default = true,
        Callback = function(value)
            state.ESPDistance = value == true
            refreshEsp()
        end
    })

    visualsSection:CreateToggle({
        Name = "ESP Health",
        Default = true,
        Callback = function(value)
            state.ESPHealth = value == true
            refreshEsp()
        end
    })

    visualsSection:CreateToggle({
        Name = "ESP Box",
        Default = false,
        Callback = function(value)
            state.ESPBox = value == true
            refreshEsp()
        end
    })

    local movementSection = testingTab:CreateSection({
        Name = "Movement"
    })

    movementSection:CreateToggle({
        Name = "Fly",
        Default = false,
        Callback = function(value)
            state.Fly = value == true
            if state.Fly then
                startFly()
            else
                stopFly()
            end
        end
    })

    movementSection:CreateSlider({
        Name = "Fly Speed",
        Min = 10,
        Max = 200,
        Default = state.FlySpeed,
        Step = 1,
        Callback = function(value)
            state.FlySpeed = tonumber(value) or 60
        end
    })

    movementSection:CreateToggle({
        Name = "No Clip",
        Default = false,
        Callback = function(value)
            setNoclip(value == true)
        end
    })

    movementSection:CreateSlider({
        Name = "Jump Power",
        Min = 0,
        Max = 200,
        Default = state.JumpPower,
        Step = 1,
        Callback = function(value)
            setJumpPower(value)
        end
    })

    local statsSection = testingTab:CreateSection({
        Name = "Stats"
    })

    local statsCard = statsSection:CreateParagraph({
        Text = "Kills: 0\nDeaths: 0\nK/D: 0.00\nAccuracy: 0.0%\nSession: 00:00",
        Height = 82
    })

    local bestsCard = statsSection:CreateParagraph({
        Text = "Personal Bests\nKills: 0\nBest K/D: 0.00",
        Height = 70
    })

    local historyCard = statsSection:CreateParagraph({
        Text = "Training History\nNo sessions recorded yet.",
        Height = 70
    })

    statsSection:CreateButton({
        Name = "Record Training Session",
        Callback = function()
            recordTraining("Manual")
        end
    })

    statsSection:CreateButton({
        Name = "Reset Session Stats",
        Callback = function()
            state.Kills = 0
            state.Deaths = 0
            state.Shots = 0
            state.Hits = 0
            state.SessionStart = os.clock()
        end
    })

    statsSection:CreateParagraph({
        Text = "Kills are detected through a standard creator ObjectValue on defeated humanoids. Accuracy is based on tool activations and center-screen target detection where available.",
        Height = 62
    })

    local function updateStatsText()
        local elapsed = math.max(0, math.floor(os.clock() - state.SessionStart))
        local minutes = math.floor(elapsed / 60)
        local seconds = elapsed % 60
        local kd = getKDRatio()
        local accuracy = state.Shots > 0 and (state.Hits / state.Shots) * 100 or 0

        statsCard.Text = string.format(
            "Kills: %d\nDeaths: %d\nK/D: %.2f\nAccuracy: %.1f%%\nSession: %02d:%02d",
            state.Kills,
            state.Deaths,
            kd,
            accuracy,
            minutes,
            seconds
        )

        bestsCard.Text = string.format(
            "Personal Bests\nKills: %d\nBest K/D: %.2f",
            state.BestKills,
            state.BestKDRatio
        )

        if #state.TrainingHistory == 0 then
            historyCard.Text = "Training History\nNo sessions recorded yet."
        else
            local lines = {"Training History"}
            local start = math.max(1, #state.TrainingHistory - 2)
            for index = start, #state.TrainingHistory do
                local entry = state.TrainingHistory[index]
                table.insert(lines, string.format(
                    "%s • %s • K:%d D:%d KD:%.2f",
                    entry.Time,
                    entry.Reason,
                    entry.Kills,
                    entry.Deaths,
                    entry.KD
                ))
            end
            historyCard.Text = table.concat(lines, "\n")
        end
    end

    connect(Players.PlayerAdded, function(target)
        watchTarget(target)
    end)

    connect(Players.PlayerRemoving, function(target)
        destroyEsp(target)
    end)

    for _, target in ipairs(Players:GetPlayers()) do
        watchTarget(target)
    end

    connect(player.CharacterAdded, function(character)
        task.defer(function()
            connectCharacter(character)
            if state.Noclip then
                setNoclip(true)
            end
            if state.Fly then
                startFly()
            end
            setJumpPower(state.JumpPower)
        end)
    end)

    if player.Character then
        connectCharacter(player.Character)
    end

    connect(RunService.RenderStepped, function()
        if not guiAlive or not window._alive then
            return
        end

        Camera = workspace.CurrentCamera or Camera

        updateFly()

        if state.Noclip and player.Character then
            for _, object in ipairs(player.Character:GetDescendants()) do
                if object:IsA("BasePart") then
                    object.CanCollide = false
                end
            end
        end

        if state.FOV then
            updateFovCircle()
        end

        if state.Aimbot then
            local target = getBestTarget(state.AimFOV)
            if target and Camera then
                local character, _, root = getCharacter(target)
                if character and root then
                    local origin = Camera.CFrame.Position
                    local desired = CFrame.lookAt(origin, root.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(desired, math.clamp(state.AimSmooth, 0.02, 1))
                end
            end
        end

        if state.Triggerbot then
            local result = getCenterRaycast()
            local target = result and findPlayerFromInstance(result.Instance)
            if target and isEnemy(target) then
                if tryFire() then
                    state.Hits += 1
                end
            end
        end

        if state.ESP then
            refreshEsp()
        end

        updateStatsText()
    end)

    connect(window.Main.AncestryChanged, function(_, parent)
        if parent then
            return
        end

        for _, connection in ipairs(state.Connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end

        stopFly()

        for target in pairs(state.EspObjects) do
            destroyEsp(target)
        end

        if overlayGui then
            overlayGui:Destroy()
        end
    end)

    updateFovCircle()
    updateStatsText()

    return state
end


function Library:CreateWindow(config)

    config =
        type(config) == "table"
        and config
        or {}

    if self._window
        and self._window._alive then

        self._window:SetTitle(
            config.Title
                or config.Name,
            config.Subtitle
        )

        if config.Theme then

            self._window:SetTheme(
                config.Theme
            )

        end

        gui.Enabled = true

        return self._window

    end

    BASE_WIDTH =
        math.max(
            330,
            tonumber(
                config.Width
            )
            or 500
        )

    BASE_HEIGHT =
        math.max(
            300,
            tonumber(
                config.Height
            )
            or 430
        )

    title.Text =
        tostring(
            config.Title
            or config.Name
            or "ZeHub"
        )

    subtitle.Text =
        cleanSubtitle(
            config.Subtitle
            or "UI Library"
        )

    if typeof(
        config.Position
    ) == "UDim2" then

        main.Position =
            config.Position

    end

    themeButton.Visible =
        config.ThemeButton
        ~= false

    minimizeButton.Visible =
        config.MinimizeButton
        ~= false

    close.Visible =
        config.CloseButton
        ~= false

    local window =
        setmetatable(
            {

                _alive = true,

                _tabs = {},

                Gui = gui,

                Main = main

            },
            WindowMethods
        )

    self._window =
        window

    if config.BuiltInTabs ~= false then
        addBuiltInTabs(window)

        -- Built-in tabs are added without stealing the first custom tab
        -- created by the user's existing script.
        activePageName = nil

        for _, pageData in pairs(pages) do
            pageData.Root.Visible = false
        end

        refreshSideTabs()
    end

    -- Optional game-testing layer. Enabled by default for this ZeHub build.
    -- Set EnableTestingFeatures = false in CreateWindow if a project does not need it.
    if config.EnableTestingFeatures ~= false then
        window._gameTestingState = createGameTestingFeatures(window)
    end

    gui.Enabled = true

    applyTheme(
        ThemePresets[
            config.Theme
        ]
        and config.Theme
        or "Dark"
    )

    updateResponsiveSize(
        true
    )

    return window

end

-- ============================================================================
-- WINDOW METHODS
-- ============================================================================

function WindowMethods:SetTitle(
    newTitle,
    newSubtitle
)

    if newTitle ~= nil then

        title.Text =
            tostring(
                newTitle
            )

    end

    if newSubtitle ~= nil then

        subtitle.Text =
            cleanSubtitle(
                newSubtitle
            )

    end

    return self

end

function WindowMethods:SetTheme(
    themeName
)

    if ThemePresets[
        themeName
    ] then

        applyTheme(
            themeName
        )

    end

    return self

end

function WindowMethods:ToggleTheme()

    applyTheme(
        currentThemeName == "Dark"
        and "Light"
        or "Dark"
    )

    return self

end

function WindowMethods:SetMinimized(
    value
)

    setMinimized(
        value
    )

    return self

end

function WindowMethods:SetSidebarExpanded(
    value
)

    sidebarExpanded =
        value == true

    updateSidebarGeometry(
        false
    )

    return self

end

function WindowMethods:SelectTab(
    name
)

    selectPage(
        tostring(name)
    )

    return self

end

-- ============================================================================
-- CREATE TAB
-- ============================================================================

function WindowMethods:CreateTab(
    config
)

    config =
        normalizeConfig(
            config,
            "Tab"
        )

    local name =
        tostring(
            config.Name
            or "Tab"
        )

    local icon =
        config.Icon
        or config.IconType
        or name

    if self._tabs[name] then
        return self._tabs[name]
    end

    local pageData =
        createPage(
            name,
            icon
        )

    local tab =
        setmetatable(
            {

                Name = name,

                _page = pageData,

                _sections = {},

                Window = self

            },
            TabMethods
        )

    self._tabs[name] =
        tab

    if not activePageName then

        selectPage(
            name
        )

    end

    return tab

end

-- ============================================================================
-- DESTROY
-- ============================================================================

function WindowMethods:Destroy()

    if not self._alive then
        return
    end

    self._alive = false

    guiAlive = false

    if gui
        and gui.Parent then

        gui:Destroy()

    end

end

-- ============================================================================
-- TAB METHODS
-- ============================================================================

function TabMethods:Select()

    selectPage(
        self.Name
    )

    return self

end

function TabMethods:CreateSection(
    config
)

    config =
        normalizeConfig(
            config,
            "Section"
        )

    local name =
        tostring(
            config.Name
            or "Section"
        )

    if self._sections[name] then
        return self._sections[name]
    end

    local root =
        createSection(
            self._page,
            name
        )

    local section =
        setmetatable(
            {

                Name = name,

                Root = root,

                Tab = self

            },
            SectionMethods
        )

    self._sections[name] =
        section

    return section

end

-- ============================================================================
-- SECTION METHODS
-- ============================================================================

function SectionMethods:CreateToggle(
    config
)

    config =
        normalizeConfig(
            config,
            "Toggle"
        )

    return toggle(

        self.Root,

        config.Name
            or "Toggle",

        config.Callback,

        config.Default
    )

end

function SectionMethods:CreateButton(
    config
)

    config =
        normalizeConfig(
            config,
            "Button"
        )

    return actionButton(

        self.Root,

        config.Name
            or "Button",

        config.Callback
    )

end

function SectionMethods:CreateDropdown(
    config
)

    config =
        normalizeConfig(
            config,
            "Dropdown"
        )

    return dropdown(

        self.Root,

        config.Name
            or "Dropdown",

        config.Options
            or config.Values
            or {},

        config.Callback,

        config.Default
    )

end

function SectionMethods:CreateMultiDropdown(
    config
)

    config =
        normalizeConfig(
            config,
            "Multi Dropdown"
        )

    return multiDropdown(

        self.Root,

        config.Name
            or "Multi Dropdown",

        config.Options
            or config.Values
            or {},

        config.Callback,

        config.Default
            or config.Defaults
    )

end

function SectionMethods:CreateSlider(
    config
)

    config =
        normalizeConfig(
            config,
            "Slider"
        )

    return slider(

        self.Root,

        config.Name
            or "Slider",

        config.Min
            or config.Minimum
            or 0,

        config.Max
            or config.Maximum
            or 100,

        config.Default
            or config.Value
            or 0,

        config.Step
            or 1,

        config.Callback
    )

end

function SectionMethods:CreateNumberBox(
    config
)

    config =
        normalizeConfig(
            config,
            "Number"
        )

    return numberBox(

        self.Root,

        config.Name
            or "Number",

        config.Default
            or config.Value
            or 0,

        config.Callback
    )

end

function SectionMethods:CreateInput(
    config
)

    config =
        normalizeConfig(
            config,
            "Input"
        )

    return textBox(

        self.Root,

        config.Name
            or "Input",

        config.Placeholder
            or "",

        config.Callback
    )

end

SectionMethods.CreateTextBox =
    SectionMethods.CreateInput

function SectionMethods:CreateParagraph(
    config
)

    if type(config) ~= "table" then

        config = {
            Text =
                tostring(
                    config
                    or ""
                )
        }

    end

    return infoCard(

        self.Root,

        config.Text
            or config.Content
            or "",

        config.Height
            or 46,

        config.TextColor
    )

end

SectionMethods.CreateInfo =
    SectionMethods.CreateParagraph

SectionMethods.CreateLabel =
    SectionMethods.CreateParagraph

function SectionMethods:CreateFeatureCard(
    config
)

    config =
        type(config) == "table"
        and config
        or {}

    return featureCard(

        self.Root,

        config.Title
            or config.Name
            or "Features",

        config.Items
            or {}
    )

end

function SectionMethods:CreateSpacer(
    height
)

    return spacer(
        self.Root,
        height
    )

end

-- ============================================================================
-- API ALIASES
-- ============================================================================

WindowMethods.AddTab =
    WindowMethods.CreateTab

TabMethods.AddSection =
    TabMethods.CreateSection

SectionMethods.AddToggle =
    SectionMethods.CreateToggle

SectionMethods.AddButton =
    SectionMethods.CreateButton

SectionMethods.AddDropdown =
    SectionMethods.CreateDropdown

SectionMethods.AddMultiDropdown =
    SectionMethods.CreateMultiDropdown

SectionMethods.AddSlider =
    SectionMethods.CreateSlider

SectionMethods.AddNumberBox =
    SectionMethods.CreateNumberBox

SectionMethods.AddInput =
    SectionMethods.CreateInput

SectionMethods.AddParagraph =
    SectionMethods.CreateParagraph

SectionMethods.AddFeatureCard =
    SectionMethods.CreateFeatureCard

-- ============================================================================
-- INITIAL THEME
-- ============================================================================

applyTheme("Dark")

updateResponsiveSize(true)

-- ============================================================================
-- FLOWAUTH STARTUP
-- ============================================================================
-- This release is intended to be uploaded to FlowAuth as the protected
-- ZeHub payload. The FlowAuth key loader authenticates first; once this
-- payload is delivered, the code below actually creates the ZeHub window.
-- ============================================================================

local FlowAuthWindow

local startupSuccess, startupError = pcall(function()

    FlowAuthWindow = Library:CreateWindow({
        Title = "ZeHub",
        Subtitle = "Game Testing",
        Width = 500,
        Height = 430,
        Theme = "Dark",
        MinimizeButton = true,
        CloseButton = true,
        ThemeButton = true,
        BuiltInTabs = true,
        EnableTestingFeatures = true
    })

end)

if not startupSuccess then
    warn("[ZeHub] Failed to initialise UI: " .. tostring(startupError))
end

-- Keep returning the library so the payload remains usable as a normal
-- ZeHub library as well as a standalone FlowAuth payload.
return Library
