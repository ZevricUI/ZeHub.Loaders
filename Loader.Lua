local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- ZE HUB SETTINGS
--==================================================

local SESSION_ID = HttpService:GenerateGUID(false)

local LOADER_VERSION = "v2.0.0"

local KEY_FILE = "ZeHub_Key.txt"

local DISCORD = "discord.gg/zehub"

local KEY_URL =
    "discord.gg/zehub"

--==================================================
-- SCRIPTS
--==================================================

local Scripts = {

    {
        Name = "Loot The Forge",

        Hash =
            "a315f0a408a8a08b7eace4550185adcb",

        -- IMPORTANT:
        -- Do not paste the old exposed webhook here.
        -- Rotate it first.
        Webhook = "https://discord.com/api/webhooks/1552817999482986607/d-oUj3_bfBiWzfIKSYjOG9hp0ZlAJS5ogsAiQteB_8HCpv0qX8lnOoFDk93Vn-qhuXYE"
    },

    {
        Name = "Rivals",

        Hash =
            "99468e8b743345db35bfac9d99632320",

        Webhook = "https://discord.com/api/webhooks/1552818155015897111/4kTq941pwL2ZOY51VtEG6S5oZrC-KN_4hFtFfQZ7V5lddAwohdfoWXGrGibjHh898u-D"
    },

    {
        Name = "Runaways",

        Hash =
            "2f8015eedaf4c092d6afc919837270de",

        Webhook = "https://discord.com/api/webhooks/1552818085805957163/GzYsTrGDp9UGS9sgRepAwLNL0h0Lr6EebfglR6RENzabqdqEXdb7VZdOYSwwW6jIoHcD"
    }
}

--==================================================
-- OPTIONAL PLACE ID AUTO DETECTION
--==================================================
-- Add your actual PlaceIds here.
--
-- Example:
--
-- [123456789] = "Rivals",
--
-- Leave empty if you do not want automatic
-- PlaceId selection.

local PLACE_IDS = {

    -- [YOUR_LOOT_THE_FORGE_PLACE_ID] = "Loot The Forge",
    -- [YOUR_RIVALS_PLACE_ID] = "Rivals",
    -- [YOUR_RUNAWAYS_PLACE_ID] = "Runaways"

}

--==================================================
-- EVENT COLOURS
--==================================================

local EVENT_COLORS = {

    SCRIPT_SELECTED = 0x8B5CF6,

    SCRIPT_EXECUTED = 0x5865F2,

    GET_KEY_CLICKED = 0x3498DB,

    DISCORD_CLICKED = 0x3498DB,

    KEY_VALIDATION_STARTED = 0xF1C40F,

    KEY_ACCEPTED = 0x2ECC71,

    KEY_FAILED = 0xE74C3C,

    LOADER_ERROR = 0xE74C3C

}

--==================================================
-- EVENT EMOJIS
--==================================================

local EVENT_EMOJIS = {

    SCRIPT_SELECTED = "📜",

    SCRIPT_EXECUTED = "🚀",

    GET_KEY_CLICKED = "🔑",

    DISCORD_CLICKED = "💬",

    KEY_VALIDATION_STARTED = "🔐",

    KEY_ACCEPTED = "✅",

    KEY_FAILED = "❌",

    LOADER_ERROR = "⚠️"

}

--==================================================
-- DUPLICATE EVENT PROTECTION
--==================================================

local recentEvents = {}

--==================================================
-- REQUEST FUNCTION
--==================================================

local function getRequestFunction()

    return
        (syn and syn.request)
        or (http and http.request)
        or http_request
        or request

end

--==================================================
-- EVENT ID
--==================================================

local function generateEventId()

    local guid =
        HttpService:GenerateGUID(false)

    return
        "EVT-"
        .. string.upper(
            guid:gsub("-", ""):sub(1, 8)
        )

end

--==================================================
-- WEBHOOK LOGGER
--==================================================
-- This intentionally does NOT send:
-- UserId
-- Account age
-- JobId
-- Player profile
-- Avatar
--
-- Keep Discord webhooks off the client where possible.
-- A server-side webhook relay is safer.

local function sendLog(
    webhook,
    eventName,
    details,
    scriptName
)

    if type(webhook) ~= "string"
        or webhook == ""
        or webhook:find("YOUR_")
        then

        return

    end

    local requestFunction =
        getRequestFunction()

    if not requestFunction then
        return
    end

    local duplicateKey =
        tostring(eventName)
        .. "|"
        .. tostring(scriptName)
        .. "|"
        .. tostring(player.UserId)

    local currentTime =
        os.clock()

    if recentEvents[duplicateKey]
        and currentTime
            - recentEvents[duplicateKey]
            < 2
        then

        return

    end

    recentEvents[duplicateKey] =
        currentTime

    local eventId =
        generateEventId()

    local emoji =
        EVENT_EMOJIS[eventName]
        or "📡"

    local color =
        EVENT_COLORS[eventName]
        or 0x8B5CF6

    local payload = {

        username = "ZeHub Logger",

        embeds = {{

            title =
                emoji
                .. " ZeHub • "
                .. tostring(eventName),

            description =
                "**"
                .. tostring(
                    scriptName
                    or "Unknown"
                )
                .. "**\n"
                .. tostring(
                    details
                    or "No additional details."
                ),

            color = color,

            fields = {

                {
                    name = "📜 Script",

                    value =
                        "`"
                        .. tostring(
                            scriptName
                            or "Unknown"
                        )
                        .. "`",

                    inline = true
                },

                {
                    name = "📦 Loader",

                    value =
                        "`"
                        .. tostring(
                            LOADER_VERSION
                        )
                        .. "`",

                    inline = true
                },

                {
                    name = "⚡ Action",

                    value =
                        "`"
                        .. tostring(
                            eventName
                        )
                        .. "`",

                    inline = true
                },

                {
                    name = "🔗 Session",

                    value =
                        "`"
                        .. tostring(
                            SESSION_ID
                        )
                        .. "`",

                    inline = false
                },

                {
                    name = "🆔 Event",

                    value =
                        "`"
                        .. tostring(
                            eventId
                        )
                        .. "`",

                    inline = true
                },

                {
                    name = "🎮 Game",

                    value =
                        "`"
                        .. tostring(
                            game.Name
                        )
                        .. "`",

                    inline = true
                }

            },

            footer = {

                text =
                    "ZeHub Loader • "
                    .. tostring(
                        LOADER_VERSION
                    )

            },

            timestamp =
                os.date(
                    "!%Y-%m-%dT%H:%M:%SZ"
                )

        }}

    }

    local body

    local success =
        pcall(function()

            body =
                HttpService:JSONEncode(
                    payload
                )

        end)

    if not success
        or not body
        then

        return

    end

    task.spawn(function()

        pcall(function()

            requestFunction({

                Url = webhook,

                Method = "POST",

                Headers = {

                    ["Content-Type"] =
                        "application/json"

                },

                Body = body

            })

        end)

    end)

end

--==================================================
-- REMOVE OLD UI
--==================================================

pcall(function()

    local old =
        playerGui:FindFirstChild(
            "ZeHub"
        )

    if old then
        old:Destroy()
    end

end)

--==================================================
-- LOAD SAVED KEY
--==================================================

local savedKey = ""

pcall(function()

    if isfile
        and isfile(KEY_FILE)
        then

        savedKey =
            readfile(
                KEY_FILE
            )

    end

end)

--==================================================
-- SCREEN GUI
--==================================================

local ScreenGui =
    Instance.new("ScreenGui")

ScreenGui.Name =
    "ZeHub"

ScreenGui.ResetOnSpawn =
    false

ScreenGui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

ScreenGui.Parent =
    playerGui

--==================================================
-- SCALE
--==================================================

local Scale =
    Instance.new("UIScale")

Scale.Parent =
    ScreenGui

local function updateScale()

    local camera =
        workspace.CurrentCamera

    if not camera then
        return
    end

    local viewport =
        camera.ViewportSize

    local scale =
        math.min(
            viewport.X / 720,
            viewport.Y / 500
        )

    Scale.Scale =
        math.clamp(
            scale,
            0.72,
            1.15
        )

end

updateScale()

workspace.CurrentCamera
    :GetPropertyChangedSignal(
        "ViewportSize"
    )
    :Connect(
        updateScale
    )

--==================================================
-- MAIN
--==================================================

local Main =
    Instance.new("Frame")

Main.Name =
    "Main"

Main.Size =
    UDim2.fromOffset(
        540,
        330
    )

Main.Position =
    UDim2.fromScale(
        0.5,
        0.5
    )

Main.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

Main.BackgroundColor3 =
    Color3.fromRGB(
        3,
        3,
        3
    )

Main.BorderSizePixel =
    0

Main.Parent =
    ScreenGui

--==================================================
-- MAIN CORNER
--==================================================

local MainCorner =
    Instance.new("UICorner")

MainCorner.CornerRadius =
    UDim.new(
        0,
        12
    )

MainCorner.Parent =
    Main

--==================================================
-- MAIN STROKE
--==================================================

local MainStroke =
    Instance.new("UIStroke")

MainStroke.Color =
    Color3.fromRGB(
        255,
        255,
        255
    )

MainStroke.Thickness =
    1

MainStroke.Transparency =
    0.78

MainStroke.Parent =
    Main

--==================================================
-- TOP BAR
--==================================================

local TopBar =
    Instance.new("Frame")

TopBar.BackgroundTransparency =
    1

TopBar.Position =
    UDim2.fromOffset(
        0,
        0
    )

TopBar.Size =
    UDim2.new(
        1,
        0,
        0,
        65
    )

TopBar.Parent =
    Main

--==================================================
-- TITLE
--==================================================

local Title =
    Instance.new("TextLabel")

Title.BackgroundTransparency =
    1

Title.Position =
    UDim2.fromOffset(
        20,
        12
    )

Title.Size =
    UDim2.fromOffset(
        300,
        28
    )

Title.Font =
    Enum.Font.GothamBold

Title.Text =
    "ZeHub"

Title.TextColor3 =
    Color3.fromRGB(
        255,
        255,
        255
    )

Title.TextSize =
    23

Title.TextXAlignment =
    Enum.TextXAlignment.Left

Title.Parent =
    TopBar

--==================================================
-- SUBTITLE
--==================================================

local Subtitle =
    Instance.new("TextLabel")

Subtitle.BackgroundTransparency =
    1

Subtitle.Position =
    UDim2.fromOffset(
        21,
        38
    )

Subtitle.Size =
    UDim2.fromOffset(
        350,
        18
    )

Subtitle.Font =
    Enum.Font.Gotham

Subtitle.Text =
    "ZeHub • Script Loader"

Subtitle.TextColor3 =
    Color3.fromRGB(
        125,
        125,
        125
    )

Subtitle.TextSize =
    10

Subtitle.TextXAlignment =
    Enum.TextXAlignment.Left

Subtitle.Parent =
    TopBar

--==================================================
-- VERSION
--==================================================

local Version =
    Instance.new("TextLabel")

Version.BackgroundTransparency =
    1

Version.AnchorPoint =
    Vector2.new(
        1,
        0
    )

Version.Position =
    UDim2.new(
        1,
        -48,
        0,
        17
    )

Version.Size =
    UDim2.fromOffset(
        80,
        18
    )

Version.Font =
    Enum.Font.GothamMedium

Version.Text =
    LOADER_VERSION

Version.TextColor3 =
    Color3.fromRGB(
        105,
        105,
        105
    )

Version.TextSize =
    9

Version.TextXAlignment =
    Enum.TextXAlignment.Right

Version.Parent =
    TopBar

--==================================================
-- CLOSE BUTTON
--==================================================

local CloseButton =
    Instance.new("TextButton")

CloseButton.AnchorPoint =
    Vector2.new(
        1,
        0
    )

CloseButton.Position =
    UDim2.new(
        1,
        -14,
        0,
        14
    )

CloseButton.Size =
    UDim2.fromOffset(
        25,
        25
    )

CloseButton.BackgroundColor3 =
    Color3.fromRGB(
        12,
        12,
        12
    )

CloseButton.BorderSizePixel =
    0

CloseButton.AutoButtonColor =
    false

CloseButton.Font =
    Enum.Font.GothamBold

CloseButton.Text =
    "×"

CloseButton.TextColor3 =
    Color3.fromRGB(
        180,
        180,
        180
    )

CloseButton.TextSize =
    17

CloseButton.Parent =
    TopBar

local CloseCorner =
    Instance.new("UICorner")

CloseCorner.CornerRadius =
    UDim.new(
        0,
        6
    )

CloseCorner.Parent =
    CloseButton

CloseButton.MouseEnter:Connect(function()

    TweenService:Create(
        CloseButton,
        TweenInfo.new(
            0.15
        ),
        {
            BackgroundColor3 =
                Color3.fromRGB(
                    40,
                    40,
                    40
                ),

            TextColor3 =
                Color3.fromRGB(
                    255,
                    255,
                    255
                )
        }
    ):Play()

end)

CloseButton.MouseLeave:Connect(function()

    TweenService:Create(
        CloseButton,
        TweenInfo.new(
            0.15
        ),
        {
            BackgroundColor3 =
                Color3.fromRGB(
                    12,
                    12,
                    12
                ),

            TextColor3 =
                Color3.fromRGB(
                    180,
                    180,
                    180
                )
        }
    ):Play()

end)

CloseButton.MouseButton1Click:Connect(function()

    ScreenGui:Destroy()

end)

--==================================================
-- DRAGGING
--==================================================

local dragging = false
local dragStart
local startPosition

TopBar.InputBegan:Connect(function(
    input
)

    if input.UserInputType
        == Enum.UserInputType.MouseButton1
        or input.UserInputType
        == Enum.UserInputType.Touch
        then

        dragging = true

        dragStart =
            input.Position

        startPosition =
            Main.Position

        input.Changed:Connect(function()

            if input.UserInputState
                == Enum.UserInputState.End
                then

                dragging = false

            end

        end)

    end

end)

UIS.InputChanged:Connect(function(
    input
)

    if not dragging then
        return
    end

    if input.UserInputType
        ~= Enum.UserInputType.MouseMovement
        and input.UserInputType
        ~= Enum.UserInputType.Touch
        then

        return

    end

    local delta =
        input.Position
        - dragStart

    Main.Position =
        UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset
                + delta.X,

            startPosition.Y.Scale,
            startPosition.Y.Offset
                + delta.Y
        )

end)

--==================================================
-- SIDEBAR
--==================================================

local Sidebar =
    Instance.new("Frame")

Sidebar.BackgroundColor3 =
    Color3.fromRGB(
        8,
        8,
        8
    )

Sidebar.BorderSizePixel =
    0

Sidebar.Position =
    UDim2.fromOffset(
        14,
        76
    )

Sidebar.Size =
    UDim2.fromOffset(
        145,
        240
    )

Sidebar.Parent =
    Main

local SidebarCorner =
    Instance.new("UICorner")

SidebarCorner.CornerRadius =
    UDim.new(
        0,
        8
    )

SidebarCorner.Parent =
    Sidebar

local SidebarStroke =
    Instance.new("UIStroke")

SidebarStroke.Color =
    Color3.fromRGB(
        35,
        35,
        35
    )

SidebarStroke.Thickness =
    1

SidebarStroke.Parent =
    Sidebar

--==================================================
-- SIDEBAR TITLE
--==================================================

local SidebarTitle =
    Instance.new("TextLabel")

SidebarTitle.BackgroundTransparency =
    1

SidebarTitle.Position =
    UDim2.fromOffset(
        12,
        10
    )

SidebarTitle.Size =
    UDim2.fromOffset(
        120,
        20
    )

SidebarTitle.Font =
    Enum.Font.GothamBold

SidebarTitle.Text =
    "SCRIPTS"

SidebarTitle.TextColor3 =
    Color3.fromRGB(
        175,
        175,
        175
    )

SidebarTitle.TextSize =
    10

SidebarTitle.TextXAlignment =
    Enum.TextXAlignment.Left

SidebarTitle.Parent =
    Sidebar

--==================================================
-- CONTENT
--==================================================

local Content =
    Instance.new("Frame")

Content.BackgroundTransparency =
    1

Content.Position =
    UDim2.fromOffset(
        174,
        76
    )

Content.Size =
    UDim2.fromOffset(
        350,
        240
    )

Content.Parent =
    Main

--==================================================
-- SELECTED LABEL
--==================================================

local SelectedLabel =
    Instance.new("TextLabel")

SelectedLabel.BackgroundTransparency =
    1

SelectedLabel.Position =
    UDim2.fromOffset(
        0,
        0
    )

SelectedLabel.Size =
    UDim2.fromOffset(
        280,
        27
    )

SelectedLabel.Font =
    Enum.Font.GothamBold

SelectedLabel.TextColor3 =
    Color3.fromRGB(
        255,
        255,
        255
    )

SelectedLabel.TextSize =
    17

SelectedLabel.TextXAlignment =
    Enum.TextXAlignment.Left

SelectedLabel.Parent =
    Content

--==================================================
-- SELECTED SUBTITLE
--==================================================

local SelectedSubtitle =
    Instance.new("TextLabel")

SelectedSubtitle.BackgroundTransparency =
    1

SelectedSubtitle.Position =
    UDim2.fromOffset(
        0,
        25
    )

SelectedSubtitle.Size =
    UDim2.fromOffset(
        300,
        18
    )

SelectedSubtitle.Font =
    Enum.Font.Gotham

SelectedSubtitle.Text =
    "Authentication required"

SelectedSubtitle.TextColor3 =
    Color3.fromRGB(
        110,
        110,
        110
    )

SelectedSubtitle.TextSize =
    9

SelectedSubtitle.TextXAlignment =
    Enum.TextXAlignment.Left

SelectedSubtitle.Parent =
    Content

--==================================================
-- KEY BOX
--==================================================

local KeyBox =
    Instance.new("TextBox")

KeyBox.Position =
    UDim2.fromOffset(
        0,
        50
    )

KeyBox.Size =
    UDim2.fromOffset(
        350,
        42
    )

KeyBox.BackgroundColor3 =
    Color3.fromRGB(
        7,
        7,
        7
    )

KeyBox.BorderSizePixel =
    0

KeyBox.ClearTextOnFocus =
    false

KeyBox.Font =
    Enum.Font.Gotham

KeyBox.PlaceholderText =
    "Enter your key..."

KeyBox.PlaceholderColor3 =
    Color3.fromRGB(
        90,
        90,
        90
    )

KeyBox.Text =
    savedKey

KeyBox.TextColor3 =
    Color3.fromRGB(
        245,
        245,
        245
    )

KeyBox.TextSize =
    11

KeyBox.TextXAlignment =
    Enum.TextXAlignment.Left

KeyBox.Parent =
    Content

local KeyPadding =
    Instance.new("UIPadding")

KeyPadding.PaddingLeft =
    UDim.new(
        0,
        13
    )

KeyPadding.PaddingRight =
    UDim.new(
        0,
        13
    )

KeyPadding.Parent =
    KeyBox

local KeyCorner =
    Instance.new("UICorner")

KeyCorner.CornerRadius =
    UDim.new(
        0,
        7
    )

KeyCorner.Parent =
    KeyBox

local KeyStroke =
    Instance.new("UIStroke")

KeyStroke.Color =
    Color3.fromRGB(
        40,
        40,
        40
    )

KeyStroke.Thickness =
    1

KeyStroke.Parent =
    KeyBox

KeyBox.Focused:Connect(function()

    TweenService:Create(
        KeyStroke,
        TweenInfo.new(
            0.15
        ),
        {
            Color =
                Color3.fromRGB(
                    120,
                    120,
                    120
                )
        }
    ):Play()

end)

KeyBox.FocusLost:Connect(function()

    TweenService:Create(
        KeyStroke,
        TweenInfo.new(
            0.15
        ),
        {
            Color =
                Color3.fromRGB(
                    40,
                    40,
                    40
                )
        }
    ):Play()

end)

--==================================================
-- STATUS
--==================================================

local Status =
    Instance.new("TextLabel")

Status.BackgroundTransparency =
    1

Status.Position =
    UDim2.fromOffset(
        0,
        97
    )

Status.Size =
    UDim2.fromOffset(
        350,
        20
    )

Status.Font =
    Enum.Font.Gotham

Status.Text =
    "● Ready"

Status.TextColor3 =
    Color3.fromRGB(
        135,
        135,
        135
    )

Status.TextSize =
    10

Status.TextXAlignment =
    Enum.TextXAlignment.Left

Status.TextTruncate =
    Enum.TextTruncate.AtEnd

Status.Parent =
    Content

--==================================================
-- STATUS FUNCTION
--==================================================

local function setStatus(
    text,
    statusType
)

    Status.Text =
        tostring(text)

    local color =
        Color3.fromRGB(
            135,
            135,
            135
        )

    if statusType == "success" then

        color =
            Color3.fromRGB(
                70,
                220,
                130
            )

    elseif statusType == "error" then

        color =
            Color3.fromRGB(
                235,
                80,
                80
            )

    elseif statusType == "loading" then

        color =
            Color3.fromRGB(
                235,
                190,
                70
            )

    elseif statusType == "info" then

        color =
            Color3.fromRGB(
                120,
                170,
                255
            )

    end

    Status.TextColor3 =
        color

end

--==================================================
-- BUTTON FUNCTION
--==================================================

local function createButton(
    parent,
    text,
    position,
    size
)

    local Button =
        Instance.new("TextButton")

    Button.BackgroundColor3 =
        Color3.fromRGB(
            11,
            11,
            11
        )

    Button.BorderSizePixel =
        0

    Button.Position =
        position

    Button.Size =
        size

    Button.AutoButtonColor =
        false

    Button.Font =
        Enum.Font.GothamBold

    Button.Text =
        text

    Button.TextColor3 =
        Color3.fromRGB(
            220,
            220,
            220
        )

    Button.TextSize =
        10

    Button.Parent =
        parent

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(
            0,
            7
        )

    Corner.Parent =
        Button

    local Stroke =
        Instance.new("UIStroke")

    Stroke.Color =
        Color3.fromRGB(
            40,
            40,
            40
        )

    Stroke.Thickness =
        1

    Stroke.Parent =
        Button

    Button.MouseEnter:Connect(function()

        TweenService:Create(
            Button,
            TweenInfo.new(
                0.12
            ),
            {
                BackgroundColor3 =
                    Color3.fromRGB(
                        28,
                        28,
                        28
                    )
            }
        ):Play()

    end)

    Button.MouseLeave:Connect(function()

        TweenService:Create(
            Button,
            TweenInfo.new(
                0.12
            ),
            {
                BackgroundColor3 =
                    Color3.fromRGB(
                        11,
                        11,
                        11
                    )
            }
        ):Play()

    end)

    Button.MouseButton1Down:Connect(function()

        TweenService:Create(
            Button,
            TweenInfo.new(
                0.08
            ),
            {
                BackgroundColor3 =
                    Color3.fromRGB(
                        45,
                        45,
                        45
                    )
            }
        ):Play()

    end)

    return Button

end

--==================================================
-- LOAD BUTTON
--==================================================

local LoadButton =
    createButton(
        Content,
        "LOAD SCRIPT",
        UDim2.fromOffset(
            0,
            126
        ),
        UDim2.fromOffset(
            350,
            40
        )
    )

LoadButton.TextSize =
    11

--==================================================
-- SECONDARY BUTTONS
--==================================================

local GetKeyButton =
    createButton(
        Content,
        "GET KEY",
        UDim2.fromOffset(
            0,
            175
        ),
        UDim2.fromOffset(
            169,
            36
        )
    )

local DiscordButton =
    createButton(
        Content,
        "DISCORD",
        UDim2.fromOffset(
            181,
            175
        ),
        UDim2.fromOffset(
            169,
            36
        )
    )

--==================================================
-- SCRIPT SELECTION
--==================================================

local selectedScript =
    Scripts[1]

local scriptButtons = {}

--==================================================
-- FIND SCRIPT
--==================================================

local function findScriptByName(
    name
)

    for _, scriptData
        in ipairs(Scripts)
        do

        if scriptData.Name
            == name
            then

            return scriptData

        end

    end

    return nil

end

--==================================================
-- AUTO DETECT GAME
--==================================================

pcall(function()

    local detectedName =
        PLACE_IDS[
            game.PlaceId
        ]

    if detectedName then

        local detectedScript =
            findScriptByName(
                detectedName
            )

        if detectedScript then

            selectedScript =
                detectedScript

        end

    end

end)

--==================================================
-- UPDATE SCRIPT BUTTONS
--==================================================

local function updateScriptButtons()

    for index, button
        in pairs(
            scriptButtons
        )
        do

        local isSelected =
            Scripts[index]
            == selectedScript

        if isSelected then

            button.BackgroundColor3 =
                Color3.fromRGB(
                    35,
                    35,
                    35
                )

            local stroke =
                button:FindFirstChildOfClass(
                    "UIStroke"
                )

            if stroke then

                stroke.Color =
                    Color3.fromRGB(
                        125,
                        125,
                        125
                    )

            end

            button.TextColor3 =
                Color3.fromRGB(
                    255,
                    255,
                    255
                )

        else

            button.BackgroundColor3 =
                Color3.fromRGB(
                    11,
                    11,
                    11
                )

            local stroke =
                button:FindFirstChildOfClass(
                    "UIStroke"
                )

            if stroke then

                stroke.Color =
                    Color3.fromRGB(
                        40,
                        40,
                        40
                    )

            end

            button.TextColor3 =
                Color3.fromRGB(
                    195,
                    195,
                    195
                )

        end

    end

end

--==================================================
-- CREATE SCRIPT BUTTONS
--==================================================

for index, scriptData
    in ipairs(Scripts)
    do

    local button =
        createButton(
            Sidebar,
            scriptData.Name,
            UDim2.fromOffset(
                8,
                36
                    + (
                        (index - 1)
                        * 51
                    )
            ),
            UDim2.fromOffset(
                129,
                42
            )
        )

    button.TextSize =
        9

    scriptButtons[index] =
        button

    button.MouseButton1Click:Connect(
        function()

            selectedScript =
                scriptData

            SelectedLabel.Text =
                scriptData.Name

            SelectedSubtitle.Text =
                "Authentication required"

            LoadButton.Text =
                "LOAD "
                .. string.upper(
                    scriptData.Name
                )

            setStatus(
                "● "
                .. scriptData.Name
                .. " selected",
                "info"
            )

            updateScriptButtons()

            sendLog(
                scriptData.Webhook,
                "SCRIPT_SELECTED",
                "User selected this script.",
                scriptData.Name
            )

        end
    )

end

--==================================================
-- INITIAL UI
--==================================================

SelectedLabel.Text =
    selectedScript.Name

LoadButton.Text =
    "LOAD "
    .. string.upper(
        selectedScript.Name
    )

updateScriptButtons()

--==================================================
-- GET KEY
--==================================================

GetKeyButton.MouseButton1Click:Connect(
    function()

        setStatus(
            "● Key link copied",
            "success"
        )

        sendLog(
            selectedScript.Webhook,
            "GET_KEY_CLICKED",
            "User clicked Get Key.",
            selectedScript.Name
        )

        pcall(function()

            if setclipboard then

                setclipboard(
                    KEY_URL
                )

            elseif toclipboard then

                toclipboard(
                    KEY_URL
                )

            end

        end)

    end
)

--==================================================
-- DISCORD
--==================================================

DiscordButton.MouseButton1Click:Connect(
    function()

        setStatus(
            "● Discord link copied",
            "success"
        )

        sendLog(
            selectedScript.Webhook,
            "DISCORD_CLICKED",
            "User clicked Discord.",
            selectedScript.Name
        )

        pcall(function()

            if setclipboard then

                setclipboard(
                    DISCORD
                )

            elseif toclipboard then

                toclipboard(
                    DISCORD
                )

            end

        end)

    end
)

--==================================================
-- LOAD LOCK
--==================================================

local loading =
    false

--==================================================
-- LOADING OVERLAY
--==================================================

local LoadingOverlay =
    Instance.new("Frame")

LoadingOverlay.BackgroundColor3 =
    Color3.fromRGB(
        3,
        3,
        3
    )

LoadingOverlay.BackgroundTransparency =
    0.03

LoadingOverlay.Size =
    UDim2.fromScale(
        1,
        1
    )

LoadingOverlay.Visible =
    false

LoadingOverlay.ZIndex =
    50

LoadingOverlay.Parent =
    Main

local LoadingCorner =
    Instance.new("UICorner")

LoadingCorner.CornerRadius =
    UDim.new(
        0,
        12
    )

LoadingCorner.Parent =
    LoadingOverlay

--==================================================
-- LOADING TITLE
--==================================================

local LoadingTitle =
    Instance.new("TextLabel")

LoadingTitle.BackgroundTransparency =
    1

LoadingTitle.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

LoadingTitle.Position =
    UDim2.fromScale(
        0.5,
        0.43
    )

LoadingTitle.Size =
    UDim2.fromOffset(
        400,
        35
    )

LoadingTitle.Font =
    Enum.Font.GothamBold

LoadingTitle.Text =
    "Loading ZeHub..."

LoadingTitle.TextColor3 =
    Color3.fromRGB(
        255,
        255,
        255
    )

LoadingTitle.TextSize =
    20

LoadingTitle.ZIndex =
    51

LoadingTitle.Parent =
    LoadingOverlay

--==================================================
-- LOADING STATUS
--==================================================

local LoadingStatus =
    Instance.new("TextLabel")

LoadingStatus.BackgroundTransparency =
    1

LoadingStatus.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

LoadingStatus.Position =
    UDim2.fromScale(
        0.5,
        0.53
    )

LoadingStatus.Size =
    UDim2.fromOffset(
        400,
        25
    )

LoadingStatus.Font =
    Enum.Font.Gotham

LoadingStatus.Text =
    "Initializing..."

LoadingStatus.TextColor3 =
    Color3.fromRGB(
        130,
        130,
        130
    )

LoadingStatus.TextSize =
    10

LoadingStatus.ZIndex =
    51

LoadingStatus.Parent =
    LoadingOverlay

--==================================================
-- LOADING BAR BACKGROUND
--==================================================

local LoadingBar =
    Instance.new("Frame")

LoadingBar.AnchorPoint =
    Vector2.new(
        0.5,
        0
    )

LoadingBar.Position =
    UDim2.fromScale(
        0.5,
        0.60
    )

LoadingBar.Size =
    UDim2.fromOffset(
        280,
        4
    )

LoadingBar.BackgroundColor3 =
    Color3.fromRGB(
        25,
        25,
        25
    )

LoadingBar.BorderSizePixel =
    0

LoadingBar.ZIndex =
    51

LoadingBar.Parent =
    LoadingOverlay

local LoadingBarCorner =
    Instance.new("UICorner")

LoadingBarCorner.CornerRadius =
    UDim.new(
        1,
        0
    )

LoadingBarCorner.Parent =
    LoadingBar

--==================================================
-- LOADING BAR
--==================================================

local LoadingProgress =
    Instance.new("Frame")

LoadingProgress.Size =
    UDim2.new(
        0,
        0,
        1,
        0
    )

LoadingProgress.BackgroundColor3 =
    Color3.fromRGB(
        255,
        255,
        255
    )

LoadingProgress.BorderSizePixel =
    0

LoadingProgress.ZIndex =
    52

LoadingProgress.Parent =
    LoadingBar

local LoadingProgressCorner =
    Instance.new("UICorner")

LoadingProgressCorner.CornerRadius =
    UDim.new(
        1,
        0
    )

LoadingProgressCorner.Parent =
    LoadingProgress

--==================================================
-- LOAD SCRIPT
--==================================================

LoadButton.MouseButton1Click:Connect(
    function()

        if loading then
            return
        end

        local scriptData =
            selectedScript

        if not scriptData then

            setStatus(
                "● No script selected.",
                "error"
            )

            return

        end

        local key =
            KeyBox.Text

        key =
            tostring(
                key or ""
            )

        key =
            key:gsub(
                "^%s+",
                ""
            ):gsub(
                "%s+$",
                ""
            )

        if key == "" then

            setStatus(
                "● Please enter your key.",
                "error"
            )

            sendLog(
                scriptData.Webhook,
                "KEY_FAILED",
                "User attempted to load without entering a key.",
                scriptData.Name
            )

            return

        end

        loading =
            true

        LoadButton.Active =
            false

        LoadButton.AutoButtonColor =
            false

        setStatus(
            "● Validating key...",
            "loading"
        )

        sendLog(
            scriptData.Webhook,
            "KEY_VALIDATION_STARTED",
            "FlowAuth key validation started.",
            scriptData.Name
        )

        --==================================================
        -- SAVE KEY
        --==================================================

        pcall(function()

            if writefile then

                writefile(
                    KEY_FILE,
                    key
                )

            end

        end)

        --==================================================
        -- FLOWAUTH URL
        --==================================================

        local loaderURL =
            "https://flowauth.net/v1/loaders/"
            .. scriptData.Hash
            .. ".lua"

        local source

        local getSuccess,
            getError =
            pcall(
                function()

                    source =
                        game:HttpGet(
                            loaderURL
                        )

                end
            )

        if not getSuccess
            or not source
            or source == ""
            then

            loading =
                false

            LoadButton.Active =
                true

            setStatus(
                "● Failed to contact FlowAuth.",
                "error"
            )

            sendLog(
                scriptData.Webhook,
                "LOADER_ERROR",
                "Could not retrieve the FlowAuth loader.",
                scriptData.Name
            )

            return

        end

        --==================================================
        -- COMPILE
        --==================================================

        local loader

        local compileSuccess,
            compileError =
            pcall(
                function()

                    loader =
                        loadstring(
                            source
                        )

                end
            )

        if not compileSuccess
            or type(loader)
                ~= "function"
            then

            loading =
                false

            LoadButton.Active =
                true

            setStatus(
                "● Failed to compile FlowAuth.",
                "error"
            )

            sendLog(
                scriptData.Webhook,
                "LOADER_ERROR",
                "FlowAuth loader could not be compiled.",
                scriptData.Name
            )

            return

        end

        --==================================================
        -- VALIDATE
        --==================================================

        local result

        local executionSuccess,
            executionError =
            pcall(
                function()

                    result =
                        loader(
                            key
                        )

                end
            )

        if not executionSuccess then

            loading =
                false

            LoadButton.Active =
                true

            setStatus(
                "● Loader error.",
                "error"
            )

            sendLog(
                scriptData.Webhook,
                "LOADER_ERROR",
                "FlowAuth loader returned an execution error.",
                scriptData.Name
            )

            return

        end

        --==================================================
        -- INVALID
        --==================================================

        if result == false then

            loading =
                false

            LoadButton.Active =
                true

            setStatus(
                "● Invalid key.",
                "error"
            )

            sendLog(
                scriptData.Webhook,
                "KEY_FAILED",
                "FlowAuth rejected the supplied key.",
                scriptData.Name
            )

            return

        end

        --==================================================
        -- ACCEPTED
        --==================================================

        setStatus(
            "● Key accepted.",
            "success"
        )

        sendLog(
            scriptData.Webhook,
            "KEY_ACCEPTED",
            "FlowAuth accepted the supplied key.",
            scriptData.Name
        )

        --==================================================
        -- SHOW LOADING SCREEN
        --==================================================

        LoadingOverlay.Visible =
            true

        LoadingStatus.Text =
            "Authentication successful"

        TweenService:Create(
            LoadingProgress,
            TweenInfo.new(
                0.5,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Size =
                    UDim2.new(
                        0.35,
                        0,
                        1,
                        0
                    )
            }
        ):Play()

        task.wait(
            0.35
        )

        LoadingStatus.Text =
            "Loading "
            .. scriptData.Name
            .. "..."

        TweenService:Create(
            LoadingProgress,
            TweenInfo.new(
                0.65,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Size =
                    UDim2.new(
                        0.72,
                        0,
                        1,
                        0
                    )
            }
        ):Play()

        task.wait(
            0.55
        )

        LoadingStatus.Text =
            "Starting script..."

        TweenService:Create(
            LoadingProgress,
            TweenInfo.new(
                0.4,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Size =
                    UDim2.new(
                        1,
                        0,
                        1,
                        0
                    )
            }
        ):Play()

        task.wait(
            0.4
        )

        --==================================================
        -- CLOSE LOADER
        --==================================================

        pcall(function()

            ScreenGui:Destroy()

        end)

    end
)

--==================================================
-- INITIAL STATUS
--==================================================

if savedKey ~= ""
    then

    setStatus(
        "● Saved key loaded",
        "info"
    )

else

    setStatus(
        "● Ready",
        "info"
    )

end
