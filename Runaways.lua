local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- ZE HUB SETTINGS
--==================================================

local SESSION_ID = HttpService:GenerateGUID(false)

local Scripts = {
    {
        Name = "Loot The Forge",
        Hash = "a315f0a408a8a08b7eace4550185adcb",
        Webhook = "YOUR_LOOT_THE_FORGE_WEBHOOK"
    },
    {
        Name = "Rivals",
        Hash = "99468e8b743345db35bfac9d99632320",
        Webhook = "YOUR_RIVALS_WEBHOOK"
    },
    {
        Name = "Runaways",
        Hash = "2f8015eedaf4c092d6afc919837270de",
        Webhook = "YOUR_RUNAWAYS_WEBHOOK"
    }
}

local KEY_FILE = "ZeHub_Key.txt"
local DISCORD = "discord.gg/zehub"

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
-- DISCORD WEBHOOK LOGGER
--==================================================

local function sendLog(webhook, eventName, details, scriptName)
    if type(webhook) ~= "string"
        or webhook == ""
        or webhook:find("YOUR_")
        then
        return
    end

    local requestFunction = getRequestFunction()

    if not requestFunction then
        return
    end

    local payload = {
        username = "ZeHub Logger",

        embeds = {{
            title = "ZeHub • " .. tostring(eventName),

            fields = {
                {
                    name = "User",
                    value = tostring(player.Name),
                    inline = true
                },

                {
                    name = "User ID",
                    value = tostring(player.UserId),
                    inline = true
                },

                {
                    name = "Game",
                    value = tostring(game.Name),
                    inline = true
                },

                {
                    name = "Place ID",
                    value = tostring(game.PlaceId),
                    inline = true
                },

                {
                    name = "Script",
                    value = tostring(scriptName or "Unknown"),
                    inline = true
                },

                {
                    name = "Session",
                    value = tostring(SESSION_ID),
                    inline = true
                },

                {
                    name = "Details",
                    value = tostring(details or "None"),
                    inline = false
                }
            }
        }}
    }

    local body

    local encodeSuccess = pcall(function()
        body = HttpService:JSONEncode(payload)
    end)

    if not encodeSuccess or not body then
        return
    end

    task.spawn(function()
        pcall(function()
            requestFunction({
                Url = webhook,
                Method = "POST",

                Headers = {
                    ["Content-Type"] = "application/json"
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
    local old = playerGui:FindFirstChild("ZeHub")

    if old then
        old:Destroy()
    end
end)

--==================================================
-- LOAD SAVED KEY
--==================================================

local savedKey = ""

pcall(function()
    if isfile and isfile(KEY_FILE) then
        savedKey = readfile(KEY_FILE)
    end
end)

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZeHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

local Scale = Instance.new("UIScale")
Scale.Parent = ScreenGui

local function updateScale()
    local viewport = workspace.CurrentCamera.ViewportSize

    local scale = math.min(
        viewport.X / 650,
        viewport.Y / 500
    )

    Scale.Scale = math.clamp(scale, 0.72, 1.18)
end

updateScale()

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)

--==================================================
-- MAIN FRAME
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(460, 285)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.7
MainStroke.Parent = Main

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(18, 14)
Title.Size = UDim2.fromOffset(300, 28)
Title.Font = Enum.Font.GothamBold
Title.Text = "ZeHub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.fromOffset(19, 42)
Subtitle.Size = UDim2.fromOffset(330, 20)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "Select a script and enter your key"
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
Subtitle.TextSize = 11
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Main

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Instance.new("Frame")
Sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
Sidebar.BorderSizePixel = 0
Sidebar.Position = UDim2.fromOffset(12, 76)
Sidebar.Size = UDim2.fromOffset(125, 194)
Sidebar.Parent = Main

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 7)
SidebarCorner.Parent = Sidebar

local SidebarTitle = Instance.new("TextLabel")
SidebarTitle.BackgroundTransparency = 1
SidebarTitle.Position = UDim2.fromOffset(10, 8)
SidebarTitle.Size = UDim2.fromOffset(105, 20)
SidebarTitle.Font = Enum.Font.GothamBold
SidebarTitle.Text = "SCRIPTS"
SidebarTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
SidebarTitle.TextSize = 10
SidebarTitle.TextXAlignment = Enum.TextXAlignment.Left
SidebarTitle.Parent = Sidebar

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("Frame")
Content.BackgroundTransparency = 1
Content.Position = UDim2.fromOffset(150, 76)
Content.Size = UDim2.fromOffset(298, 194)
Content.Parent = Main

local SelectedLabel = Instance.new("TextLabel")
SelectedLabel.BackgroundTransparency = 1
SelectedLabel.Position = UDim2.fromOffset(0, 0)
SelectedLabel.Size = UDim2.fromOffset(290, 25)
SelectedLabel.Font = Enum.Font.GothamBold
SelectedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectedLabel.TextSize = 15
SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
SelectedLabel.Parent = Content

local KeyBox = Instance.new("TextBox")
KeyBox.Position = UDim2.fromOffset(0, 38)
KeyBox.Size = UDim2.fromOffset(298, 39)
KeyBox.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
KeyBox.BorderSizePixel = 0
KeyBox.ClearTextOnFocus = false
KeyBox.Font = Enum.Font.Gotham
KeyBox.PlaceholderText = "Enter your key..."
KeyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
KeyBox.Text = savedKey
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.TextSize = 12
KeyBox.Parent = Content

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 6)
KeyCorner.Parent = KeyBox

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Color = Color3.fromRGB(55, 55, 55)
KeyStroke.Thickness = 1
KeyStroke.Parent = KeyBox

--==================================================
-- STATUS
--==================================================

local Status = Instance.new("TextLabel")
Status.BackgroundTransparency = 1
Status.Position = UDim2.fromOffset(0, 82)
Status.Size = UDim2.fromOffset(298, 20)
Status.Font = Enum.Font.Gotham
Status.Text = "Ready."
Status.TextColor3 = Color3.fromRGB(150, 150, 150)
Status.TextSize = 10
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.TextTruncate = Enum.TextTruncate.AtEnd
Status.Parent = Content

--==================================================
-- BUTTON FUNCTION
--==================================================

local function createButton(parent, text, position, size)
    local Button = Instance.new("TextButton")

    Button.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Button.BorderSizePixel = 0
    Button.Position = position
    Button.Size = size
    Button.AutoButtonColor = false
    Button.Font = Enum.Font.GothamBold
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(230, 230, 230)
    Button.TextSize = 10
    Button.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(45, 45, 45)
    Stroke.Thickness = 1
    Stroke.Parent = Button

    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    end)

    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    end)

    return Button
end

--==================================================
-- LOAD BUTTON
--==================================================

local LoadButton = createButton(
    Content,
    "LOAD SELECTED",
    UDim2.fromOffset(0, 108),
    UDim2.fromOffset(298, 35)
)

--==================================================
-- GET KEY / DISCORD
--==================================================

local GetKeyButton = createButton(
    Content,
    "GET KEY",
    UDim2.fromOffset(0, 151),
    UDim2.fromOffset(142, 32)
)

local DiscordButton = createButton(
    Content,
    "DISCORD",
    UDim2.fromOffset(156, 151),
    UDim2.fromOffset(142, 32)
)

--==================================================
-- SCRIPT SELECTION
--==================================================

local selectedScript = Scripts[1]
local scriptButtons = {}

local function setStatus(text)
    Status.Text = tostring(text)
end

local function updateScriptButtons()
    for index, button in pairs(scriptButtons) do
        if Scripts[index] == selectedScript then
            button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        else
            button.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        end
    end
end

for index, scriptData in ipairs(Scripts) do
    local button = createButton(
        Sidebar,
        scriptData.Name,
        UDim2.fromOffset(7, 32 + ((index - 1) * 45)),
        UDim2.fromOffset(111, 36)
    )

    scriptButtons[index] = button

    button.MouseButton1Click:Connect(function()
        selectedScript = scriptData

        SelectedLabel.Text = scriptData.Name
        setStatus("Selected " .. scriptData.Name .. ".")

        updateScriptButtons()

        sendLog(
            scriptData.Webhook,
            "SCRIPT_SELECTED",
            "User selected this script in the ZeHub loader.",
            scriptData.Name
        )
    end)
end

SelectedLabel.Text = selectedScript.Name
updateScriptButtons()

--==================================================
-- INITIAL EXECUTION LOG
--==================================================

sendLog(
    selectedScript.Webhook,
    "SCRIPT_EXECUTED",
    "ZeHub loader started.",
    selectedScript.Name
)

--==================================================
-- GET KEY
--==================================================

GetKeyButton.MouseButton1Click:Connect(function()
    setStatus("Discord link copied.")

    sendLog(
        selectedScript.Webhook,
        "GET_KEY_CLICKED",
        "User clicked the Get Key button.",
        selectedScript.Name
    )

    pcall(function()
        if setclipboard then
            setclipboard(DISCORD)
        elseif toclipboard then
            toclipboard(DISCORD)
        end
    end)
end)

--==================================================
-- DISCORD
--==================================================

DiscordButton.MouseButton1Click:Connect(function()
    setStatus("Discord link copied.")

    sendLog(
        selectedScript.Webhook,
        "DISCORD_CLICKED",
        "User clicked the Discord button.",
        selectedScript.Name
    )

    pcall(function()
        if setclipboard then
            setclipboard(DISCORD)
        elseif toclipboard then
            toclipboard(DISCORD)
        end
    end)
end)

--==================================================
-- LOAD SCRIPT
--==================================================

LoadButton.MouseButton1Click:Connect(function()

    local scriptData = selectedScript
    local key = KeyBox.Text

    if not scriptData then
        setStatus("No script selected.")

        sendLog(
            selectedScript.Webhook,
            "KEY_FAILED",
            "No script was selected.",
            "Unknown"
        )

        return
    end

    if not key or key:gsub("%s+", "") == "" then
        setStatus("Please enter your key.")

        sendLog(
            scriptData.Webhook,
            "KEY_FAILED",
            "User attempted to load without entering a key.",
            scriptData.Name
        )

        return
    end

    -- Save key locally
    pcall(function()
        if writefile then
            writefile(KEY_FILE, key)
        end
    end)

    setStatus("Validating key...")

    sendLog(
        scriptData.Webhook,
        "KEY_VALIDATION_STARTED",
        "FlowAuth key validation started.",
        scriptData.Name
    )

    --==================================================
    -- GET FLOWAUTH LOADER
    --==================================================

    local loaderURL =
        "https://flowauth.net/v1/loaders/"
        .. scriptData.Hash
        .. ".lua"

    local source

    local getSuccess, getError = pcall(function()
        source = game:HttpGet(loaderURL)
    end)

    if not getSuccess or not source or source == "" then

        setStatus("Failed to contact FlowAuth.")

        sendLog(
            scriptData.Webhook,
            "LOADER_ERROR",
            "Could not retrieve the FlowAuth loader.",
            scriptData.Name
        )

        return
    end

    --==================================================
    -- LOAD FLOWAUTH
    --==================================================

    local loader
    local compileSuccess, compileError = pcall(function()
        loader = loadstring(source)
    end)

    if not compileSuccess or type(loader) ~= "function" then

        setStatus("Failed to load FlowAuth.")

        sendLog(
            scriptData.Webhook,
            "LOADER_ERROR",
            "FlowAuth loader could not be compiled.",
            scriptData.Name
        )

        return
    end

    --==================================================
    -- VALIDATE KEY
    --==================================================

    local result
    local executionSuccess, executionError = pcall(function()
        result = loader(key)
    end)

    if not executionSuccess then

        setStatus("Loader error.")

        sendLog(
            scriptData.Webhook,
            "LOADER_ERROR",
            "FlowAuth loader returned an execution error.",
            scriptData.Name
        )

        return
    end

    --==================================================
    -- INVALID KEY
    --==================================================

    if result == false then

        setStatus("Invalid key.")

        sendLog(
            scriptData.Webhook,
            "KEY_FAILED",
            "FlowAuth rejected the supplied key.",
            scriptData.Name
        )

        return
    end

    --==================================================
    -- SUCCESS
    --==================================================

    setStatus("Key accepted. Loading...")

    sendLog(
        scriptData.Webhook,
        "KEY_ACCEPTED",
        "FlowAuth accepted the key and the script was allowed to load.",
        scriptData.Name
    )

    task.wait(0.35)

    pcall(function()
        ScreenGui:Destroy()
    end)
end)
