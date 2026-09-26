local Library = (function()

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

local BASE_WIDTH = 500
local BASE_HEIGHT = 430
local TOPBAR_HEIGHT = 48
local SIDEBAR_COLLAPSED = 58
local SIDEBAR_EXPANDED = 150
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

local sidebar = create("Frame", {
    Name = "Sidebar",
    Position = UDim2.fromOffset(0, TOPBAR_HEIGHT),
    Size = UDim2.new(0, SIDEBAR_COLLAPSED, 1, -TOPBAR_HEIGHT),
    BackgroundColor3 = Theme.Sidebar,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = main
})

local sidebarLine = create("Frame", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 0),
    Size = UDim2.new(0, 1, 1, 0),
    BackgroundColor3 = Theme.Border,
    BorderSizePixel = 0,
    Parent = sidebar
})

local navHolder = create("Frame", {
    Position = UDim2.fromOffset(5, 7),
    Size = UDim2.new(1, -10, 1, -14),
    BackgroundTransparency = 1,
    Parent = sidebar
})

create("UIListLayout", {
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = navHolder
})

local content = create("Frame", {
    Name = "Content",
    Position = UDim2.fromOffset(SIDEBAR_COLLAPSED + CONTENT_GAP, TOPBAR_HEIGHT + CONTENT_GAP),
    Size = UDim2.new(1, -(SIDEBAR_COLLAPSED + CONTENT_GAP * 2), 1, -(TOPBAR_HEIGHT + CONTENT_GAP * 2)),
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
        Size = UDim2.new(1, 0, 0, 36),
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
        Size = UDim2.fromOffset(2, 18),
        BackgroundColor3 = Theme.Text,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = navButton
    })
    corner(indicator, 2)

    local iconHolder = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 5, 0.5, 0),
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
        Position = UDim2.fromOffset(40, 0),
        Size = UDim2.new(1, -45, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Muted,
        TextTransparency = sidebarExpanded and 0 or 1,
        TextSize = 10,
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
    local sidebarWidth = sidebarExpanded and SIDEBAR_EXPANDED or SIDEBAR_COLLAPSED
    local sidebarTarget = UDim2.new(0, sidebarWidth, 1, -TOPBAR_HEIGHT)
    local contentPosition = UDim2.fromOffset(sidebarWidth + CONTENT_GAP, TOPBAR_HEIGHT + CONTENT_GAP)
    local contentSize = UDim2.new(1, -(sidebarWidth + CONTENT_GAP * 2), 1, -(TOPBAR_HEIGHT + CONTENT_GAP * 2))

    if instant then
        sidebar.Size = sidebarTarget
        content.Position = contentPosition
        content.Size = contentSize
    else
        tween(sidebar, {Size = sidebarTarget}, 0.14)
        tween(content, {Position = contentPosition, Size = contentSize}, 0.14)
    end

    for _, data in pairs(sideButtons) do
        tween(data.Label, {TextTransparency = sidebarExpanded and 0 or 1}, instant and 0 or 0.1)
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
    local viewport = camera and camera.ViewportSize or Vector2.new(BASE_WIDTH + 40, BASE_HEIGHT + 40)
    local width = math.min(BASE_WIDTH, math.max(330, viewport.X - 20))
    local height = math.min(BASE_HEIGHT, math.max(300, viewport.Y - 30))
    local target = minimized and UDim2.fromOffset(width, TOPBAR_HEIGHT) or UDim2.fromOffset(width, height)

    if instant then
        main.Size = target
    else
        tween(main, {Size = target}, 0.14)
    end

    updateSidebarGeometry(instant)
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


    return Library
end)()

-- =================================================================
-- ZEHUB MM2 MASTER SUITE
-- Converted from Rayfield to the ZeHub Black/White Transparent UI.
-- =================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local function notify(title, content, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title or "ZeHub"),
            Text = tostring(content or ""),
            Duration = duration or 4
        })
    end)
end

local Window = Library:CreateWindow({
    Name = "ZeHub MM2 Master Suite",
    Title = "ZeHub MM2 Master Suite",
    Subtitle = "Autofarm • Visuals • Combat • Utilities",
    Theme = "Dark",
    Width = 520,
    Height = 460,
    ThemeButton = true,
    MinimizeButton = true,
    CloseButton = true
})

local VisualsTab = Window:CreateTab({Name = "Visuals", Icon = "Eye"})
local ProVisualsTab = Window:CreateTab({Name = "Pro Visuals", Icon = "Eye"})
local FarmTab = Window:CreateTab({Name = "Automation", Icon = "Farm"})
local CombatTab = Window:CreateTab({Name = "Combat", Icon = "Stats"})
local AdvancedCombatTab = Window:CreateTab({Name = "Kill Aura", Icon = "Stats"})
local HitboxTab = Window:CreateTab({Name = "Hitboxes", Icon = "Stats"})
local CaseTab = Window:CreateTab({Name = "Cases", Icon = "Gift"})
local SkinsTab = Window:CreateTab({Name = "Skins", Icon = "Gift"})
local PlayerModsTab = Window:CreateTab({Name = "Player Mods", Icon = "Home"})
local WebhookTab = Window:CreateTab({Name = "Webhooks", Icon = "Settings"})
local StreamerTab = Window:CreateTab({Name = "Streamer", Icon = "Eye"})
local ExtraTab = Window:CreateTab({Name = "Extras", Icon = "Settings"})
local UtilityTab = Window:CreateTab({Name = "Utilities", Icon = "Home"})
local StatusTab = Window:CreateTab({Name = "Match Status", Icon = "Stats"})

local settings = {
    ESPEnabled = false,
    InnocentESP = false,
    NameESPEnabled = false,
    FullbrightEnabled = false,
    NoclipEnabled = false,
    AutoGrabGun = false,
    AutoFarmCoins = false,
    AimbotEnabled = false,
    AutoShootMurderer = false,
    KillAuraEnabled = false,
    AutoEvadeEnabled = false,
    WebhookURL = "",
    WebhookEnabled = false,
    CoinsFarmedSession = 0,
    StreamerModeEnabled = false,
    AutoReconnectEnabled = true,
    HitboxExpanderEnabled = false,
    HitboxSize = 2,
}

local roles = {Murderer = nil, Sheriff = nil, GunDrop = nil}
local tracers = {}
local selectedKnifeSkin = "Default"
local selectedGunSkin = "Default"
local virtualInventory = {"Default Knife", "Default Gun"}
local customWalkSpeed = 16
local customJumpPower = 50

local function sendWebhookRequest(url, payload)
    if not url or url == "" then return end
    local requestFunc = http_request or syn and syn.request or request
    local encodedData = HttpService:JSONEncode(payload)
    if requestFunc then
        pcall(function()
            requestFunc({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = encodedData
            })
        end)
    else
        pcall(function()
            HttpService:PostAsync(url, encodedData)
        end)
    end
end

local function safeTeleport(targetCFrame)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 2)
    if root then root.CFrame = targetCFrame end
end

CoreGui.ChildAdded:Connect(function(child)
    if child.Name == "RobloxPromptGui" and settings.AutoReconnectEnabled then
        task.spawn(function()
            task.wait(2)
            pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        end)
    end
end)

local function applyHighlight(player, color, isMurvOrSheriff)
    if not player or not player.Character then return end
    local character = player.Character
    if not isMurvOrSheriff and not settings.InnocentESP then
        local old = character:FindFirstChild("MM2_Highlight")
        if old then old:Destroy() end
        return
    end
    local old = character:FindFirstChild("MM2_Highlight")
    if old then old:Destroy() end
    if settings.ESPEnabled or (not isMurvOrSheriff and settings.InnocentESP) then
        local highlight = Instance.new("Highlight")
        highlight.Name = "MM2_Highlight"
        highlight.Adornee = character
        highlight.FillColor = color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.4
        highlight.Parent = character
    end
end

local function updateRoles()
    roles.Murderer = nil
    roles.Sheriff = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local backpack = player:FindFirstChild("Backpack")
            local character = player.Character
            local function hasItem(itemType)
                return character:FindFirstChild(itemType) or (backpack and backpack:FindFirstChild(itemType))
            end
            if hasItem("Knife") then
                roles.Murderer = player
                applyHighlight(player, Color3.fromRGB(255, 0, 0), true)
            elseif hasItem("Gun") then
                roles.Sheriff = player
                applyHighlight(player, Color3.fromRGB(0, 0, 255), true)
            else
                applyHighlight(player, Color3.fromRGB(0, 255, 0), false)
            end
        end
    end
end

Workspace.ChildAdded:Connect(function(child)
    if child.Name == "GunDrop" or child:FindFirstChild("GunDrop") then
        roles.GunDrop = child
        if settings.AutoGrabGun and child:IsA("BasePart") then
            safeTeleport(child.CFrame + Vector3.new(0, 3, 0))
        end
    end
end)

Workspace.ChildRemoved:Connect(function(child)
    if child == roles.GunDrop then roles.GunDrop = nil end
end)

local function updateTracers()
    if not settings.ESPEnabled then
        for _, line in pairs(tracers) do pcall(function() line.Visible = false end) end
        return
    end
    local targets = {
        {player = roles.Murderer, color = Color3.fromRGB(255, 0, 0)},
        {player = roles.Sheriff, color = Color3.fromRGB(0, 0, 255)}
    }
    for _, target in ipairs(targets) do
        local player = target.player
        if player and Drawing and not tracers[player] then
            local line = Drawing.new("Line")
            line.Thickness = 1.5
            line.Transparency = 1
            tracers[player] = line
        end
        local line = tracers[player]
        if line then
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local vector, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                line.Visible = onScreen
                if onScreen then
                    line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    line.To = Vector2.new(vector.X, vector.Y)
                    line.Color = target.color
                end
            else
                line.Visible = false
            end
        end
    end
end

local function sendWebhookNotification(title, description, fields)
    if not settings.WebhookEnabled or settings.WebhookURL == "" then return end
    sendWebhookRequest(settings.WebhookURL, {
        embeds = {{
            title = title,
            description = description,
            color = 3447003,
            fields = fields or {},
            footer = {text = "ZeHub MM2 Master Suite"}
        }}
    })
end

local function startCoinFarm()
    task.spawn(function()
        while settings.AutoFarmCoins do
            task.wait(0.2)
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then continue end
            local rootPart = character.HumanoidRootPart
            local coinContainer
            for _, descendant in ipairs(Workspace:GetDescendants()) do
                if descendant.Name == "CoinContainer" then coinContainer = descendant break end
            end
            if coinContainer then
                for _, coin in ipairs(coinContainer:GetChildren()) do
                    if not settings.AutoFarmCoins then break end
                    local targetPart = coin:IsA("BasePart") and coin or coin:FindFirstChild("Coin")
                    if targetPart then
                        local distance = (rootPart.Position - targetPart.Position).Magnitude
                        local tween = TweenService:Create(rootPart, TweenInfo.new(distance / 18, Enum.EasingStyle.Linear), {
                            CFrame = targetPart.CFrame + Vector3.new(0, 2, 0)
                        })
                        tween:Play()
                        tween.Completed:Wait()
                        settings.CoinsFarmedSession += 1
                        task.wait(0.1)
                    end
                end
            end
        end
    end)
end

local visualsSection = VisualsTab:CreateSection({Name = "Role Visuals"})
visualsSection:CreateToggle({Name = "Role ESP & Tracers (Murderer/Sheriff)", Default = false, Callback = function(value)
    settings.ESPEnabled = value
    if not value then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                local h = player.Character:FindFirstChild("MM2_Highlight")
                if h then h:Destroy() end
            end
        end
        for _, line in pairs(tracers) do pcall(function() line.Visible = false end) end
    end
end})
visualsSection:CreateToggle({Name = "Innocent ESP (Green Highlight)", Default = false, Callback = function(value) settings.InnocentESP = value end})

local proVisualsSection = ProVisualsTab:CreateSection({Name = "Player Information"})
proVisualsSection:CreateToggle({Name = "Player Name & Distance Tags", Default = false, Callback = function(value) settings.NameESPEnabled = value end})
proVisualsSection:CreateParagraph({Text = "Visual overlays are controlled locally by the MM2 Master Suite.", Height = 44})

local farmSection = FarmTab:CreateSection({Name = "Automation"})
farmSection:CreateToggle({Name = "Instant Gun Grabber (Auto-Teleport)", Default = false, Callback = function(value) settings.AutoGrabGun = value end})
farmSection:CreateToggle({Name = "Auto-Farm Coins", Default = false, Callback = function(value)
    settings.AutoFarmCoins = value
    if value then
        startCoinFarm()
        sendWebhookNotification("🚜 Autofarm Started", "Auto-farm loop activated.", {{name = "Player", value = LocalPlayer.Name, inline = true}})
    end
end})

local combatSection = CombatTab:CreateSection({Name = "Sheriff"})
combatSection:CreateToggle({Name = "Sheriff Aimbot (Lock onto Murderer)", Default = false, Callback = function(value) settings.AimbotEnabled = value end})
combatSection:CreateToggle({Name = "Auto-Shoot Murderer (Instant Fire)", Default = false, Callback = function(value) settings.AutoShootMurderer = value end})

local auraSection = AdvancedCombatTab:CreateSection({Name = "Advanced Combat"})
auraSection:CreateToggle({Name = "Kill Aura (Auto-Kill Nearby Players)", Default = false, Callback = function(value) settings.KillAuraEnabled = value end})
auraSection:CreateToggle({Name = "Auto-Evade (Teleport Away if Murderer is Close)", Default = false, Callback = function(value) settings.AutoEvadeEnabled = value end})

local hitboxSection = HitboxTab:CreateSection({Name = "Hitbox"})
hitboxSection:CreateToggle({Name = "Enable Hitbox Expander", Default = false, Callback = function(value) settings.HitboxExpanderEnabled = value end})
hitboxSection:CreateSlider({Name = "Hitbox Size Scale", Min = 1, Max = 10, Default = 2, Step = 1, Callback = function(value) settings.HitboxSize = value end})

local caseSection = CaseTab:CreateSection({Name = "Case Simulator"})
caseSection:CreateButton({Name = "Open Mystery Case (Spin & Unbox)", Callback = function()
    local possibleDrops = {"Chroma Blade", "Corrupt Knife", "Bat Godly", "Hallow's Edge", "Elderwood Scythe", "Seer", "Common Gun"}
    local wonItem = possibleDrops[math.random(1, #possibleDrops)]
    table.insert(virtualInventory, wonItem)
    notify("Mystery Case Unboxed!", "You won: " .. wonItem, 4.5)
end})
caseSection:CreateButton({Name = "View Virtual Inventory", Callback = function()
    notify("Virtual Inventory", table.concat(virtualInventory, ", "), 6)
end})

local skinsSection = SkinsTab:CreateSection({Name = "Client Skins"})
skinsSection:CreateDropdown({Name = "Client Knife Skin", Options = {"Default", "Chroma Blade"}, Default = "Default", Callback = function(option) selectedKnifeSkin = option end})
skinsSection:CreateDropdown({Name = "Client Gun Skin", Options = {"Default", "Gold Gun"}, Default = "Default", Callback = function(option) selectedGunSkin = option end})

local playerModsSection = PlayerModsTab:CreateSection({Name = "Movement"})
playerModsSection:CreateSlider({Name = "WalkSpeed", Min = 16, Max = 100, Default = 16, Step = 1, Callback = function(value) customWalkSpeed = value end})
playerModsSection:CreateSlider({Name = "JumpPower", Min = 50, Max = 150, Default = 50, Step = 1, Callback = function(value) customJumpPower = value end})

local webhookSection = WebhookTab:CreateSection({Name = "Discord Telemetry"})
webhookSection:CreateInput({Name = "Discord Webhook URL", Placeholder = "Paste your Discord Webhook URL here", Callback = function(text) settings.WebhookURL = text end})
webhookSection:CreateToggle({Name = "Enable Discord Telemetry Reports", Default = false, Callback = function(value) settings.WebhookEnabled = value end})
webhookSection:CreateButton({Name = "Send Test Webhook Report", Callback = function()
    sendWebhookNotification("🛡️ ZeHub MM2 Status Report", "Test telemetry report triggered successfully.", {
        {name = "Player", value = LocalPlayer.Name, inline = true},
        {name = "Server Job ID", value = game.JobId, inline = false}
    })
end})

local streamerSection = StreamerTab:CreateSection({Name = "Streamer Protection"})
streamerSection:CreateToggle({Name = "Enable Streamer Mode (Hide Name)", Default = false, Callback = function(value) settings.StreamerModeEnabled = value end})
streamerSection:CreateParagraph({Text = "Streamer mode controls custom ZeHub overlays and does not alter Roblox account information.", Height = 52})

local extraSection = ExtraTab:CreateSection({Name = "Player Utilities"})
extraSection:CreateToggle({Name = "Fullbright (Remove Shadows/Darkness)", Default = false, Callback = function(value)
    settings.FullbrightEnabled = value
    if value then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end})
extraSection:CreateToggle({Name = "Noclip (Walk Through Walls)", Default = false, Callback = function(value) settings.NoclipEnabled = value end})
extraSection:CreateToggle({Name = "Auto-Reconnect on Crash/Disconnect", Default = true, Callback = function(value) settings.AutoReconnectEnabled = value end})

local utilitySection = UtilityTab:CreateSection({Name = "Utilities"})
utilitySection:CreateParagraph({Text = "Anti-AFK Protection\nActive: Prevents server timeout kicks automatically.", Height = 58})
utilitySection:CreateButton({Name = "Refresh Role Scan", Callback = function() updateRoles(); notify("ZeHub", "Role scan refreshed.", 3) end})

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local StatusParagraph = StatusTab:CreateSection({Name = "Live Round Information"}):CreateParagraph({
    Text = "Scanning players...\n• Murderer: None\n• Sheriff: None\n• Gun Status: Held",
    Height = 72
})

StatusTab:CreateSection({Name = "Session"}):CreateParagraph({
    Text = "ZeHub MM2 Master Suite\nUI: ZeHub Black / White Transparent",
    Height = 54
})

task.spawn(function()
    while true do
        task.wait(600)
        if settings.WebhookEnabled then
            sendWebhookNotification("📊 ZeHub Periodic Autofarm Report", string.format("Session running for player: **%s**", LocalPlayer.Name), {
                {name = "Coins Farmed This Session", value = tostring(settings.CoinsFarmedSession), inline = true},
                {name = "Current Place ID", value = tostring(game.PlaceId), inline = true}
            })
        end
    end
end)

local elapsedTimer = 0
RunService.Heartbeat:Connect(function(deltaTime)
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        if customWalkSpeed > 16 and humanoid.WalkSpeed ~= customWalkSpeed then humanoid.WalkSpeed = customWalkSpeed end
        if customJumpPower > 50 and humanoid.JumpPower ~= customJumpPower then humanoid.JumpPower = customJumpPower end
    end

    if settings.NoclipEnabled and character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    if settings.HitboxExpanderEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = player.Character.HumanoidRootPart
                rootPart.Size = Vector3.new(settings.HitboxSize * 2, settings.HitboxSize * 2, settings.HitboxSize * 2)
                rootPart.Transparency = 0.7
                rootPart.CanCollide = false
            end
        end
    end

    if settings.AutoEvadeEnabled and roles.Murderer and roles.Murderer ~= LocalPlayer then
        local murvChar = roles.Murderer.Character
        if murvChar and murvChar:FindFirstChild("HumanoidRootPart") and character and character:FindFirstChild("HumanoidRootPart") then
            local distance = (character.HumanoidRootPart.Position - murvChar.HumanoidRootPart.Position).Magnitude
            if distance < 12 then safeTeleport(character.HumanoidRootPart.CFrame + Vector3.new(0, 25, 0)) end
        end
    end

    if settings.KillAuraEnabled and character and character:FindFirstChild("HumanoidRootPart") then
        local knife = character:FindFirstChild("Knife") or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Knife"))
        if knife then
            if knife.Parent == LocalPlayer.Backpack then character.Humanoid:EquipTool(knife) end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= 15 then pcall(function() knife:Activate() end) end
                end
            end
        end
    end

    if settings.ESPEnabled or settings.InnocentESP then
        elapsedTimer += deltaTime
        if elapsedTimer >= 1.5 then
            elapsedTimer = 0
            updateRoles()
            local murdererName = roles.Murderer and roles.Murderer.Name or "None / Hidden"
            local sheriffName = roles.Sheriff and roles.Sheriff.Name or "None / Hidden"
            local gunStatus = roles.GunDrop and "Dropped in Map!" or "Held / Secure"
            StatusParagraph.Text = string.format("• Murderer: %s\n• Sheriff: %s\n• Gun Status: %s", murdererName, sheriffName, gunStatus)
        end
    end
    updateTracers()
end)
