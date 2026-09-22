-- ============================================================================
-- ZeHub • Black Transparent Key System
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
-- ZEHUB LOGO
-- ============================================================================

local LOGO_IMAGE = "rbxassetid://137776481151936"

-- ============================================================================
-- ZEHUB BLACK / GLASS THEME
-- ============================================================================

local BACKGROUND = Color3.fromRGB(7, 7, 8)
local TOPBAR = Color3.fromRGB(10, 10, 11)
local PANEL = Color3.fromRGB(11, 11, 12)

local ROW = Color3.fromRGB(15, 15, 16)
local ROW_HOVER = Color3.fromRGB(23, 23, 24)

local INPUT = Color3.fromRGB(11, 11, 12)

local BORDER = Color3.fromRGB(45, 45, 47)
local BORDER_BRIGHT = Color3.fromRGB(105, 105, 108)

local WHITE = Color3.fromRGB(245, 245, 246)
local TEXT = Color3.fromRGB(220, 220, 223)
local MUTED = Color3.fromRGB(145, 145, 149)
local PLACEHOLDER = Color3.fromRGB(82, 82, 86)

local ACCENT = Color3.fromRGB(235, 235, 238)

-- Transparent glass effect
local WINDOW_TRANSPARENCY = 0.08
local PANEL_TRANSPARENCY = 0.14
local ROW_TRANSPARENCY = 0.12
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

local function makeStroke(parent, color, transparency)

    local stroke =
        Instance.new("UIStroke")

    stroke.Color =
        color or BORDER

    stroke.Transparency =
        transparency or 0.45

    stroke.Thickness = 1

    stroke.Parent = parent

    return stroke

end

local function openLink(link)

    pcall(function()

        GuiService:OpenBrowserWindow(link)

    end)

    pcall(function()

        if setclipboard then

            setclipboard(link)

        end

    end)

end

-- ============================================================================
-- MAIN FRAME
-- ============================================================================

local frame =
