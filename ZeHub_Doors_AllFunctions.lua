--// ZeHub | Shared UI Library
--// Standalone copy extracted from the current ZeHub FlowAuth loader.
--// Source endpoint:
--// https://flowauth.net/v1/ui/465ea7165cc765fb6d66c312f98a2bc4.lua

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
    Text = "â¡",
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
            data.Check.Text = active and "â" or ""
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



-- [ 5 ] DOORS FEATURES ON ZEHUB UI

-- ============================================================================
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local Camera = Workspace.CurrentCamera

local Window = Library:CreateWindow({
    Title = "ZeHub - Doors",
    Subtitle = "Doors features | ZeHub UI",
    Width = 500,
    Height = 430,
    Theme = "Dark",
})

local MainTab = Window:CreateTab({Name = "Main", Icon = "Home"})
local EspTab  = Window:CreateTab({Name = "ESP", Icon = "Eye"})

-- ============================================================================
-- [ 6 ] DOORS — CONFIG
-- ============================================================================
local Config = {
    toggleJump = false,
    fullbright = false, brightness = 2,
    walkSpeedEnabled = false, walkSpeed = 16, noclip = false,
    doorEsp = false, objEsp = false, entityEsp = false,
    goldPileEsp = false, itemEsp = false, hidingEsp = false,
    shedEsp = false, playerEsp = false,
    rainbowEsp = false, enableText = false,
    textSize = 29, textHeight = 0.2, maxDistance = 1000,
    doorColor   = Color3.fromRGB(120, 0, 0),
    objColor    = Color3.fromRGB(0, 0, 255),
    entityColor = Color3.fromRGB(255, 0, 0),
    goldColor   = Color3.fromRGB(255, 225, 0),
    itemColor   = Color3.fromRGB(0, 255, 255),
    hideColor   = Color3.fromRGB(100, 100, 100),
    shedColor   = Color3.fromRGB(139, 69, 19),
    playerColor = Color3.fromRGB(0, 255, 0),
    autoKeyPickup = false, autoLoot = false,
    walkReachedDistance = 6,
}

-- ============================================================================
-- [ 7 ] PLAYER — Main Tab
-- ============================================================================
local PlayerSection = MainTab:CreateSection({Name = "PLAYER"})

PlayerSection:CreateToggle({Name = "Toggle Jump", Default = false, Callback = function(v)
    Config.toggleJump = v
    local char = workspace:FindFirstChild(LocalPlayer.Name)
    if char then pcall(function() char:SetAttribute("CanJump", v) end) end
end})

PlayerSection:CreateToggle({Name = "WalkSpeed", Default = false, Callback = function(v)
    Config.walkSpeedEnabled = v
    if not v then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.WalkSpeed = 16 end) end
    end
end})

PlayerSection:CreateSlider({Name = "WalkSpeed Value", Default = 16, Min = 1, Max = 200, Step = 1, Callback = function(v)
    Config.walkSpeed = v
    if Config.walkSpeedEnabled then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.WalkSpeed = v end) end
    end
end})

PlayerSection:CreateToggle({Name = "No-Clip", Default = false, Callback = function(v)
    Config.noclip = v
    if v then
        local char = LocalPlayer.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    pcall(function() p.CanCollide = false end)
                end
            end
        end
    end
end})

-- ============================================================================
-- [ 8 ] VISUALS — Main Tab
-- ============================================================================
local VisualsSection = MainTab:CreateSection({Name = "VISUALS"})

VisualsSection:CreateToggle({Name = "Fullbright", Default = false, Callback = function(v)
    Config.fullbright = v
    Lighting.ClockTime = v and 12 or 14
    Lighting.GlobalShadows = not v
    Lighting.Brightness = v and Config.brightness or 1
end})

VisualsSection:CreateSlider({Name = "Fullbright Intensity", Default = 2, Min = 1, Max = 10, Step = 1, Callback = function(v)
    Config.brightness = v
    if Config.fullbright then Lighting.Brightness = v end
end})

-- ============================================================================
-- [ 9 ] AUTO-FARM — Main Tab
-- ============================================================================
local function ForEachRoomChild(callback)
    local rooms = workspace:FindFirstChild("CurrentRooms")
    if not rooms then return end
    for _, room in ipairs(rooms:GetChildren()) do
        for _, d in ipairs(room:GetDescendants()) do
            callback(d, room)
        end
    end
end

local function FindKey()
    local result = nil
    ForEachRoomChild(function(d)
        if result then return end
        if d.Name == "KeyObtain" and d:FindFirstChild("ModulePrompt") then
            result = d
        end
    end)
    return result
end

local function FindLoot()
    local result = nil
    ForEachRoomChild(function(d)
        if result then return end
        if d.Name == "Knobs" and d:FindFirstChild("ActivateEventPrompt") then
            result = d
        end
    end)
    return result
end

local function FindHidingSpot()
    local result = nil
    ForEachRoomChild(function(d)
        if result then return end
        if (d.Name == "Wardrobe" or d.Name == "Bed") and d:FindFirstChild("HidePrompt") then
            result = d
        end
    end)
    return result
end

local function GetPosition(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local ok, pivot = pcall(function() return obj:GetPivot().Position end)
        if ok and pivot then return pivot end
    end
    return nil
end

local function FirePrompt(prompt)
    if not prompt then return false end
    local ok = pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration or 0.1)
            prompt:InputHoldEnd()
        end
    end)
    return ok
end

local AutoFarmSection = MainTab:CreateSection({Name = "AUTO-FARM"})

AutoFarmSection:CreateButton({Name = "Grab Key", Callback = function()
    local key = FindKey()
    if not key then print("[Zehub] Kein Key gefunden!"); return end
    local prompt = key:FindFirstChild("ModulePrompt")
    if prompt then FirePrompt(prompt) end
end})

AutoFarmSection:CreateButton({Name = "Loot Drawer", Callback = function()
    local loot = FindLoot()
    if not loot then print("[Zehub] Kein Loot gefunden!"); return end
    for _, d in ipairs(loot:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Name == "ActivateEventPrompt" then
            FirePrompt(d)
        end
    end
end})

AutoFarmSection:CreateButton({Name = "Hide in Hiding Spot", Callback = function()
    local hiding = FindHidingSpot()
    if not hiding then print("[Zehub] Kein Hiding-Spot gefunden!"); return end
    local prompt = hiding:FindFirstChild("HidePrompt")
    if prompt then FirePrompt(prompt) end
end})

AutoFarmSection:CreateToggle({Name = "Auto-Key-Pickup (nah)", Default = false, Callback = function(v)
    Config.autoKeyPickup = v
end})

AutoFarmSection:CreateToggle({Name = "Auto-Loot Drawers (nah)", Default = false, Callback = function(v)
    Config.autoLoot = v
end})

AutoFarmSection:CreateSlider({Name = "Interact-Reichweite", Default = 12, Min = 5, Max = 30, Step = 1, Callback = function(v)
    Config.walkReachedDistance = v
end})

-- ============================================================================
-- [ 10 ] ESP TAB — TOGGLES
-- ============================================================================
local EspToggles = EspTab:CreateSection({Name = "ESP TOGGLES"})
EspToggles:CreateToggle({Name = "Door ESP", Default = false, Callback = function(v) Config.doorEsp = v end})
EspToggles:CreateToggle({Name = "Objective ESP", Default = false, Callback = function(v) Config.objEsp = v end})
EspToggles:CreateToggle({Name = "Entity Highlight", Default = false, Callback = function(v) Config.entityEsp = v end})
EspToggles:CreateToggle({Name = "Gold Highlight", Default = false, Callback = function(v) Config.goldPileEsp = v end})
EspToggles:CreateToggle({Name = "Item Highlight", Default = false, Callback = function(v) Config.itemEsp = v end})
EspToggles:CreateToggle({Name = "Hiding ESP", Default = false, Callback = function(v) Config.hidingEsp = v end})
EspToggles:CreateToggle({Name = "ToolShed ESP", Default = false, Callback = function(v) Config.shedEsp = v end})
EspToggles:CreateToggle({Name = "Player ESP", Default = false, Callback = function(v) Config.playerEsp = v end})

local EspSettings = EspTab:CreateSection({Name = "ESP SETTINGS"})
EspSettings:CreateToggle({Name = "Rainbow ESP", Default = false, Callback = function(v) Config.rainbowEsp = v end})
EspSettings:CreateToggle({Name = "Enable Text", Default = false, Callback = function(v) Config.enableText = v end})
EspSettings:CreateSlider({Name = "Text Size", Default = 29, Min = 10, Max = 40, Step = 1, Callback = function(v) Config.textSize = v end})
EspSettings:CreateSlider({Name = "Text Offset Y", Default = 0, Min = -5, Max = 15, Step = 1, Callback = function(v) Config.textHeight = v end})
EspSettings:CreateSlider({Name = "Max ESP Distance", Default = 1000, Min = 50, Max = 5000, Step = 1, Callback = function(v) Config.maxDistance = v end})

-- ============================================================================
-- [ 11 ] LOOPS — Player / Movement
-- ============================================================================
task.spawn(function()
    while task.wait(0.2) do
        if Config.walkSpeedEnabled then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum.WalkSpeed = Config.walkSpeed end) end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if Config.toggleJump then
            local char = workspace:FindFirstChild(LocalPlayer.Name)
            if char then pcall(function() char:SetAttribute("CanJump", true) end) end
        end
    end
end)

RunService.Stepped:Connect(function()
    if Config.noclip and LocalPlayer.Character then
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                pcall(function() p.CanCollide = false end)
            end
        end
    end
end)

-- ============================================================================
-- [ 12 ] LOOPS — Auto-Farm
-- ============================================================================
task.spawn(function()
    while task.wait(0.4) do
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        if Config.autoKeyPickup then
            local key = FindKey()
            if key then
                local hitbox = key:FindFirstChild("Hitbox") or key
                local targetPos = GetPosition(hitbox)
                if targetPos and (root.Position - targetPos).Magnitude < Config.walkReachedDistance then
                    local prompt = key:FindFirstChild("ModulePrompt")
                    if prompt then FirePrompt(prompt) end
                end
            end
        end

        if Config.autoLoot then
            local rooms = workspace:FindFirstChild("CurrentRooms")
            if rooms then
                for _, room in ipairs(rooms:GetChildren()) do
                    for _, d in ipairs(room:GetDescendants()) do
                        if d:IsA("ProximityPrompt") and d.Name == "ActivateEventPrompt" then
                            local pp = d.Parent
                            if pp and pp:IsA("BasePart") and (root.Position - pp.Position).Magnitude < Config.walkReachedDistance then
                                FirePrompt(d)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================================
-- [ 13 ] ESP LOGIC
-- ============================================================================
local activeESPs = {}
local EntityNames = {"Rush","Ambush","Seek","Eyes","Screech","Halt","A-60","A-120","GiggleCeiling","MonumentEntity","SallyMoving","JeffTheKiller","GloombatSwarm","FigureRig"}
local ObjList = {"LibraryHintPaper","LiveHintBook","KeyObtain","LeverForGate","LiveBreakerPolePickup","ElectricalKeyObtain"}
local ItemList = {"AK-47","AlarmClock","Aloe","AN-94","Anchors","A-90sStopSign","BackdoorKey","BackdoorLock","Bandage","BandagePack","Battery","BatteryPack","BigBomb","BlueKeycard","BluePrince","Bomb","Bread","BreakerPole","Bulklight","Buddy","Cactus","Candle","CarmelApple","Cheese","ChocolateBar","Citamines","ColtAnaconda","Cookie","Crossbow","Crucifix","DBShotgun","DesertEagle","ElectricalKey","ElectricalRoomFuse","EnergyDrink","ExecutionRoomKey","Flashlight","FreezeGun","Flamethrower","G36C","Generator","GeneratorFuse","GiftLauncher","GlitchFragment","GweenSoda","GuidanceCandy","Headlamp","HealingPad","HolyHandGrenade","HasteLever","Hookshot","HotelKey","HotelLock","IceTripmine","InvincibilityStar","JackoBomb","Keycard","Knockbomb","Landmine","Lantern","LaserPointer","Level5Keycard","LibearyBook","LibearyLock","LibearyPaper","Light_Bulb","Lockpick","Lolipop","MG42","M14","M16A2","M1911","M249","M5K","M4A1","MoonlightCandle","MoonlightFloat","MoonlightSmoothie","Monkey","Nanner","NannerPeel","NestGenerator","NVCS-3000","OrangeKeycard","P90","Paintingoval","Paintingrectanglelyingshortsides","Paintingrectanglelyinglongsides","PaintingSquare","PlantofVirdis","Potion","R870","RedEnergyDrink","Rock","Roto_Door","RubberChicken","SacredHerb","SaltShaker","Shakelight","Shears","SkeletonKey","Smoothie","SmallShieldPotion","SpeedBoostPad","SprayPaint","StarlightBottle","StarlightJug","StarlightVial","Straplight","StrawberryCandy","StrongHerb","StrongerHerb","StrongestHerb","SuperHerb","SweetHerb","ThrowableHatStand","ThrowableNormalCardboardBox","ThrowableOfficeChair","ThrowablePottedPlant","ThrowableRegalChair","ThrowableRegalOttoman","ThrowableStool","ThrowableTrashCan","ThrowableWideCardboardBox","ThrowableWoodenChair","ThrowableWoodenCrate","TipJar","Vitamins"}
local HSList = {"Locker_Large","Toolshed","Wardrobe","Bed","Backdoor_Wardrobe","Rooms_Locker","CircularVent"}

local function NameMatches(name, list)
    if not name then return false, nil end
    local lower = name:lower()
    for _, target in ipairs(list) do
        if lower:find(target:lower(), 1, true) then
            return true, target
        end
    end
    return false, nil
end

local function Cleanup(obj, data)
    pcall(function()
        if data.Highlight then data.Highlight:Destroy() end
        if data.Box then data.Box:Destroy() end
        if data.Bill then data.Bill:Destroy() end
    end)
    activeESPs[obj] = nil
end

local function CreateESP(obj, name, type)
    if activeESPs[obj] then return end
    local objN = obj.Name
    if objN == "LiveHintBook" or objN == "FigureRig" or objN == "LiveBreakerPolePickup" or objN == "ElectricalKeyObtain" then
        local displayName = (objN == "LiveHintBook" and "Book") or
                            (objN == "FigureRig" and "Figure") or
                            (objN == "LiveBreakerPolePickup" and "Breaker") or
                            (objN == "ElectricalKeyObtain" and "Electrical Key")
        activeESPs[obj] = { Name = displayName, Type = type }
        return
    end
    local lowerN = objN:lower()
    if lowerN:find("bookcase") or lowerN:find("modular_bookshelf") then return end
    activeESPs[obj] = { Name = name, Type = type }
end

local function ScanInstance(child)
    local n = child.Name
    if not n or n == "" then return end

    if Config.entityEsp then
        local matched = NameMatches(n, EntityNames)
        if matched then
            local display = (n:lower():find("figurerig") and "Figure") or n
            CreateESP(child, display, "Entity")
            return
        end
    end

    if Config.objEsp and table.find(ObjList, n) then
        local d = (n == "KeyObtain" and "Key") or
                  (n == "LeverForGate" and "Lever") or
                  (n == "LiveHintBook" and "Book") or
                  (n == "LiveBreakerPolePickup" and "Breaker") or
                  (n == "ElectricalKeyObtain" and "Electrical Key") or n
        CreateESP(child, d, "Objective")
        return
    end

    if Config.doorEsp and n == "Door" and child:IsA("BasePart") then
        CreateESP(child, "Door", "Door")
        return
    end

    if Config.goldPileEsp then
        local lower = n:lower()
        if lower:find("goldpile", 1, true) or lower:find("gold_pile", 1, true) or lower == "gold" then
            CreateESP(child, "Gold", "Gold")
            return
        end
    end

    if Config.itemEsp and table.find(ItemList, n) then
        CreateESP(child, n, "Item")
        return
    end

    if Config.hidingEsp then
        local matched = NameMatches(n, HSList)
        if matched then
            CreateESP(child, n, "Hiding")
            return
        end
    end

    if Config.shedEsp and n == "Toolshed_Small" then
        CreateESP(child, "Tool Shed", "Shed")
        return
    end
end

task.spawn(function()
    while true do
        for _, ent in pairs(workspace:GetChildren()) do
            pcall(ScanInstance, ent)
        end

        local rooms = workspace:FindFirstChild("CurrentRooms")
        if rooms then
            for _, room in pairs(rooms:GetChildren()) do
                for _, child in pairs(room:GetDescendants()) do
                    pcall(ScanInstance, child)
                end
                task.wait(0.005)
            end
        end

        for _, d in pairs(workspace:GetDescendants()) do
            if d.Name and d.Name ~= "" then
                local lower = d.Name:lower()
                if lower:find("rush", 1, true)
                    or lower:find("ambush", 1, true)
                    or lower:find("seek", 1, true)
                    or lower:find("figurerig", 1, true)
                    or lower:find("a-60", 1, true)
                    or lower:find("a-120", 1, true)
                    or lower:find("screech", 1, true)
                    or lower:find("goldpile", 1, true)
                    or lower:find("gold_pile", 1, true)
                    or lower:find("locker_large", 1, true)
                    or lower:find("wardrobe", 1, true) then
                    pcall(ScanInstance, d)
                end
            end
        end

        task.wait(1.0)
    end
end)

local function UpdateESP()
    local rainbow = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    local char = LocalPlayer.Character
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Collision"))
    if not root then return end

    for obj, data in pairs(activeESPs) do
        local isEnabled = (data.Type == "Door" and Config.doorEsp) or
                          (data.Type == "Objective" and Config.objEsp) or
                          (data.Type == "Entity" and Config.entityEsp) or
                          (data.Type == "Gold" and Config.goldPileEsp) or
                          (data.Type == "Item" and Config.itemEsp) or
                          (data.Type == "Hiding" and Config.hidingEsp) or
                          (data.Type == "Shed" and Config.shedEsp)

        if not obj or not obj.Parent or not isEnabled then
            Cleanup(obj, data)
            continue
        end

        local targetPos
        local ok = pcall(function()
            targetPos = (obj:IsA("Model") and obj:GetPivot().Position) or (obj:IsA("BasePart") and obj.Position)
        end)
        if not ok or not targetPos then continue end

        local dist = (root.Position - targetPos).Magnitude
        if dist > Config.maxDistance then
            if data.Highlight then data.Highlight.Enabled = false end
            if data.Box then data.Box.Visible = false end
            if data.Bill then data.Bill.Enabled = false end
            continue
        end

        local _, onScreen = Camera:WorldToViewportPoint(targetPos)
        if onScreen then
            local color = Config.doorColor
            if data.Type == "Entity" then color = Config.entityColor
            elseif data.Type == "Gold" then color = Config.goldColor
            elseif data.Type == "Item" then color = Config.itemColor
            elseif data.Type == "Objective" then color = Config.objColor
            elseif data.Type == "Hiding" then color = Config.hideColor
            elseif data.Type == "Shed" then color = Config.shedColor end
            if Config.rainbowEsp then color = rainbow end

            if data.Type == "Door" and obj:IsA("BasePart") then
                if not data.Box then
                    data.Box = Instance.new("BoxHandleAdornment", obj)
                    data.Box.AlwaysOnTop = true; data.Box.Adornee = obj; data.Box.ZIndex = 5
                end
                data.Box.Visible = true; data.Box.Size = obj.Size
                data.Box.Color3 = color; data.Box.Transparency = 0.7
            else
                if not data.Highlight then
                    data.Highlight = Instance.new("Highlight", obj)
                    data.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                data.Highlight.Enabled = true
                data.Highlight.FillColor = color
                data.Highlight.OutlineColor = color
                data.Highlight.FillTransparency = 0.5
            end

            if not data.Bill then
                data.Bill = Instance.new("BillboardGui", obj)
                data.Bill.AlwaysOnTop = true
                data.Bill.Size = UDim2.new(0, 150, 0, 40)
                local txt = Instance.new("TextLabel", data.Bill)
                txt.BackgroundTransparency = 1
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.Font = "SourceSansBold"
                txt.Name = "L"
                txt.TextStrokeTransparency = 0
            end
            data.Bill.Enabled = Config.enableText
            data.Bill.StudsOffset = Vector3.new(0, Config.textHeight, 0)
            local lbl = data.Bill:FindFirstChild("L")
            if lbl then
                lbl.TextColor3 = color
                lbl.TextSize = Config.textSize
                lbl.Text = data.Name .. " [" .. math.floor(dist) .. "]"
            end
        else
            if data.Highlight then data.Highlight.Enabled = false end
            if data.Box then data.Box.Visible = false end
            if data.Bill then data.Bill.Enabled = false end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

-- ============================================================================
-- [ 14 ] Finished
-- ============================================================================
print("========================================")
print("Zehub - Doors Loaded")
print("Platform: " .. PLATFORM)
print("========================================")