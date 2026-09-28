if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait()
    LocalPlayer = Players.LocalPlayer
end

local function detectExecutorName()
    for _, detector in ipairs({identifyexecutor, getexecutorname}) do
        if type(detector) == "function" then
            local ok, name = pcall(detector)
            if ok and type(name) == "string" and name ~= "" then
                return name
            end
        end
    end
    return "Unknown Executor"
end

local ExecutorName = detectExecutorName()
local executorDisplayName = ExecutorName
local executorNameLower = string.lower(executorDisplayName)
local limitedModuleExecutor = string.find(executorNameLower, "xeno", 1, true) ~= nil
    or string.find(executorNameLower, "solara", 1, true) ~= nil

local function getExecutorStatus()
    if limitedModuleExecutor then
        return "Fallback Mode", Color3.fromRGB(255, 190, 80)
    end
    return "Full Mode", Color3.fromRGB(100, 255, 120)
end

local executorStatusText, executorStatusColor = getExecutorStatus()
local Global = _G
if type(getgenv) == "function" then
    local environmentOk, environment = pcall(getgenv)
    if environmentOk and type(environment) == "table" then
        Global = environment
    end
end

local PreviousRuntime = Global.__AXONIC_TOWER_OF_HELL_RUNTIME

if type(PreviousRuntime) == "table" and type(PreviousRuntime.Destroy) == "function" then
    pcall(PreviousRuntime.Destroy)
end

local Runtime = {
    Alive = true,
    Connections = {},
    Window = nil,
    ExecutorName = ExecutorName,
    LimitedModuleExecutor = limitedModuleExecutor,
    OptionalTouch = type(firetouchinterest) == "function",
    DisabledFeatures = {},

    GodMode = true,
    WalkSpeedEnabled = false,
    WalkSpeed = 32,
    JumpEnabled = false,
    JumpPower = 80,
    DoubleJump = false,
    DoubleJumpPower = 55,
    GravityEnabled = false,
    Gravity = 147.15,
    GravityRestore = nil,
    Fly = false,
    FlySpeed = 55,

    Character = nil,
    Humanoid = nil,
    Root = nil,
    Baseline = nil,
    AirJumps = 0,
    LastGroundJump = 0,

    GodFlag = nil,
    FlyAttachment = nil,
    FlyVelocity = nil,
    FlyOrientation = nil,

    WinBusy = false,
    AutoWin = false,
    WaitingForRound = false,
    LastRetryNotice = 0,
    WinVersion = 0,
    WinTravelSpeed = 85,
    RouteMoving = false,
    RouteCollisionState = nil,
    RouteHumanoid = nil,
    RoutePlatformStand = nil,
    RouteAutoRotate = nil,
}
Global.__AXONIC_TOWER_OF_HELL_RUNTIME = Runtime

local function addConnection(connection)
    table.insert(Runtime.Connections, connection)
    return connection
end

local function notify(title, description, kind)
    local window = Runtime.Window
    if not window or type(window.Notify) ~= "function" then
        warn("[ZeHub] " .. tostring(title) .. ": " .. tostring(description))
        return
    end

    pcall(function()
        window:Notify({
            Title = title,
            Description = description,
            Duration = 3,
            Type = kind or "Info",
        })
    end)
end

local function getCharacter(timeout)
    local deadline = os.clock() + (timeout or 5)

    repeat
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")

        if character and humanoid and root and humanoid.Health > 0 then
            return character, humanoid, root
        end

        task.wait(0.08)
    until not Runtime.Alive or os.clock() >= deadline

    return nil, nil, nil
end

local function captureCharacter(character)
    if not character then
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
    local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)

    if not humanoid or not root then
        return false
    end

    Runtime.Character = character
    Runtime.Humanoid = humanoid
    Runtime.Root = root
    Runtime.Baseline = {
        Humanoid = humanoid,
        WalkSpeed = humanoid.WalkSpeed,
        JumpPower = humanoid.JumpPower,
        JumpHeight = humanoid.JumpHeight,
        AutoRotate = humanoid.AutoRotate,
        PlatformStand = humanoid.PlatformStand,
    }
    Runtime.AirJumps = 0
    Runtime.LastGroundJump = 0
    return true
end

local function currentCharacter()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if character and humanoid and root and humanoid.Health > 0 then
        if Runtime.Character ~= character or Runtime.Humanoid ~= humanoid then
            captureCharacter(character)
        end
        return character, humanoid, root
    end

    return nil, nil, nil
end

local function restoreWalkSpeed()
    local baseline = Runtime.Baseline
    if baseline and baseline.Humanoid and baseline.Humanoid.Parent then
        pcall(function()
            baseline.Humanoid.WalkSpeed = baseline.WalkSpeed
        end)
    end
end

local function restoreJump()
    local baseline = Runtime.Baseline
    if baseline and baseline.Humanoid and baseline.Humanoid.Parent then
        pcall(function()
            baseline.Humanoid.JumpPower = baseline.JumpPower
            baseline.Humanoid.JumpHeight = baseline.JumpHeight
        end)
    end
end

local function ensureGodFlag()
    local existing = Workspace:FindFirstChild("KillbrickFlag")
    if existing then
        return existing
    end

    local flag = Instance.new("Folder")
    flag.Name = "KillbrickFlag"
    flag:SetAttribute("AxonicTowerOfHell", true)
    flag.Parent = Workspace
    Runtime.GodFlag = flag
    return flag
end

local function removeGodFlag()
    local flag = Runtime.GodFlag
    Runtime.GodFlag = nil

    if flag and flag.Parent and flag:GetAttribute("AxonicTowerOfHell") == true then
        pcall(function()
            flag:Destroy()
        end)
    end
end

local function setGodMode(enabled)
    Runtime.GodMode = enabled == true

    if Runtime.GodMode or Runtime.AutoWin then
        ensureGodFlag()
    else
        removeGodFlag()
    end
end

local function destroyFlyObjects()
    for _, object in ipairs({Runtime.FlyOrientation, Runtime.FlyVelocity, Runtime.FlyAttachment}) do
        if object and object.Parent then
            pcall(function()
                object:Destroy()
            end)
        end
    end

    Runtime.FlyAttachment = nil
    Runtime.FlyVelocity = nil
    Runtime.FlyOrientation = nil
end

local function stopFlyMotion()
    destroyFlyObjects()

    local baseline = Runtime.Baseline
    local humanoid = Runtime.Humanoid
    if humanoid and humanoid.Parent then
        pcall(function()
            humanoid.PlatformStand = baseline and baseline.Humanoid == humanoid and baseline.PlatformStand or false
            humanoid.AutoRotate = baseline and baseline.Humanoid == humanoid and baseline.AutoRotate or true
        end)
    end
end

local function startFlyMotion()
    if not Runtime.Alive or not Runtime.Fly or Runtime.RouteMoving or Runtime.DisabledFeatures.Fly then
        return false
    end

    local _, humanoid, root = currentCharacter()
    if not humanoid or not root then
        return false
    end

    destroyFlyObjects()

    local attachment
    local velocity
    local orientation
    local supported, featureError = pcall(function()
        attachment = Instance.new("Attachment")
        attachment.Name = "AxonicFlyAttachment"
        attachment.Parent = root

        velocity = Instance.new("LinearVelocity")
        velocity.Name = "AxonicFlyVelocity"
        velocity.Attachment0 = attachment
        velocity.RelativeTo = Enum.ActuatorRelativeTo.World
        velocity.MaxForce = math.huge
        pcall(function()
            velocity.ForceLimitsEnabled = false
        end)
        velocity.VectorVelocity = Vector3.zero
        velocity.Parent = root

        orientation = Instance.new("AlignOrientation")
        orientation.Name = "AxonicFlyOrientation"
        orientation.Attachment0 = attachment
        orientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
        orientation.MaxTorque = math.huge
        orientation.Responsiveness = 25
        orientation.RigidityEnabled = false
        orientation.Parent = root
    end)

    if not supported then
        for _, object in ipairs({orientation, velocity, attachment}) do
            if object and object.Parent then
                pcall(function()
                    object:Destroy()
                end)
            end
        end

        Runtime.DisabledFeatures.Fly = tostring(featureError)
        Runtime.Fly = false
        notify("Compatibility", "Fly is unsupported here and was skipped.", "Warning")
        return false
    end

    Runtime.FlyAttachment = attachment
    Runtime.FlyVelocity = velocity
    Runtime.FlyOrientation = orientation

    humanoid.PlatformStand = true
    humanoid.AutoRotate = false
    return true
end

local function setFly(enabled)
    enabled = enabled == true
    if enabled and Runtime.DisabledFeatures.Fly then
        Runtime.Fly = false
        notify("Compatibility", "Fly was skipped because this executor rejected its physics objects.", "Warning")
        return false
    end

    Runtime.Fly = enabled

    if Runtime.Fly then
        startFlyMotion()
    else
        stopFlyMotion()
    end
    return Runtime.Fly == enabled
end

local function flyDirection()
    if UserInputService:GetFocusedTextBox() then
        return Vector3.zero
    end

    local camera = Workspace.CurrentCamera
    if not camera then
        return Vector3.zero
    end

    local direction = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        direction = direction + camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        direction = direction - camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        direction = direction + camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        direction = direction - camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        direction = direction + Vector3.yAxis
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
        or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
        direction = direction - Vector3.yAxis
    end

    return direction.Magnitude > 0 and direction.Unit or Vector3.zero
end

local function updateFly()
    if not Runtime.Fly or Runtime.RouteMoving then
        return
    end

    local _, humanoid, root = currentCharacter()
    if not humanoid or not root then
        return
    end

    if not Runtime.FlyVelocity or Runtime.FlyVelocity.Parent ~= root then
        if not startFlyMotion() then
            return
        end
    end

    humanoid.PlatformStand = true
    humanoid.AutoRotate = false
    Runtime.FlyVelocity.VectorVelocity = flyDirection() * Runtime.FlySpeed
    root.AssemblyAngularVelocity = Vector3.zero

    local camera = Workspace.CurrentCamera
    local look = camera and camera.CFrame.LookVector or root.CFrame.LookVector
    local flatLook = Vector3.new(look.X, 0, look.Z)
    if flatLook.Magnitude > 0.01 then
        Runtime.FlyOrientation.CFrame = CFrame.lookAt(Vector3.zero, flatLook.Unit)
    end
end

local function setGravity(enabled)
    enabled = enabled == true

    if enabled and not Runtime.GravityEnabled then
        Runtime.GravityRestore = Workspace.Gravity
    end

    Runtime.GravityEnabled = enabled
    if Runtime.GravityEnabled then
        Workspace.Gravity = Runtime.Gravity
    elseif Runtime.GravityRestore ~= nil then
        Workspace.Gravity = Runtime.GravityRestore
        Runtime.GravityRestore = nil
    end
end

local function applyCharacterFeatures()
    local _, humanoid = currentCharacter()
    if not humanoid then
        return
    end

    if Runtime.WalkSpeedEnabled and humanoid.WalkSpeed ~= Runtime.WalkSpeed then
        humanoid.WalkSpeed = Runtime.WalkSpeed
    end

    if Runtime.JumpEnabled then
        if humanoid.UseJumpPower then
            if humanoid.JumpPower ~= Runtime.JumpPower then
                humanoid.JumpPower = Runtime.JumpPower
            end
        else
            local height = math.max(0, (Runtime.JumpPower * Runtime.JumpPower) / (2 * math.max(Workspace.Gravity, 1)))
            if math.abs(humanoid.JumpHeight - height) > 0.01 then
                humanoid.JumpHeight = height
            end
        end
    end

    if humanoid.FloorMaterial ~= Enum.Material.Air then
        Runtime.AirJumps = 0
    end

end

local function cancelWin()
    Runtime.WinVersion = Runtime.WinVersion + 1
end

local function winCancelled(version)
    return not Runtime.Alive or not Runtime.AutoWin or version ~= Runtime.WinVersion
end

local function findTowerRoute()
    local tower = Workspace:FindFirstChild("tower")
    local sectionsFolder = tower and tower:FindFirstChild("sections")
    if not sectionsFolder then
        return nil, nil, "tower sections were not found"
    end

    local route = {}
    for _, section in ipairs(sectionsFolder:GetChildren()) do
        local indexValue = section:FindFirstChild("i")
        local startPart = section:FindFirstChild("start")

        if indexValue and tonumber(indexValue.Value) and startPart and startPart:IsA("BasePart") then
            table.insert(route, {
                Index = tonumber(indexValue.Value),
                Name = section.Name,
                Start = startPart,
            })
        end
    end

    table.sort(route, function(a, b)
        if a.Index == b.Index then
            return a.Name < b.Name
        end
        return a.Index < b.Index
    end)

    local finishModel = sectionsFolder:FindFirstChild("finish")
    local finishGlow = finishModel and finishModel:FindFirstChild("FinishGlow", true)
    if not finishGlow or not finishGlow:IsA("BasePart") then
        finishGlow = sectionsFolder:FindFirstChild("FinishGlow", true)
    end

    if #route == 0 then
        return nil, nil, "no generated section starts were found"
    end
    if not finishGlow or not finishGlow:IsA("BasePart") then
        return nil, nil, "FinishGlow was not found"
    end

    return route, finishGlow, nil
end

local function getRoundProgress()
    local dataFolder = ReplicatedStorage:FindFirstChild("data")
    local playerData = dataFolder and dataFolder:FindFirstChild(tostring(LocalPlayer.UserId))
    local highestSection = playerData and playerData:FindFirstChild("highestSection")
    local tower = Workspace:FindFirstChild("tower")
    local sectionCount = tower and tower:FindFirstChild("sectionCount")

    local highest = highestSection and tonumber(highestSection.Value)
    local required = sectionCount and tonumber(sectionCount.Value)
    return highest, required
end

local function hasWonCurrentRound()
    local highest, required = getRoundProgress()
    return highest ~= nil and required ~= nil and required > 0 and highest >= required
end

local function waitForWinConfirmation(version, timeout)
    local deadline = os.clock() + (timeout or 5)
    repeat
        if hasWonCurrentRound() then
            return true
        end
        task.wait(0.12)
    until winCancelled(version) or os.clock() >= deadline

    return hasWonCurrentRound()
end

local function waitForNextRound()
    local resetStarted = nil

    while Runtime.Alive and Runtime.AutoWin do
        if hasWonCurrentRound() then
            resetStarted = nil
        else
            resetStarted = resetStarted or os.clock()
            if os.clock() - resetStarted >= 0.5 then
                return true
            end
        end
        task.wait(0.15)
    end

    return false
end

local function setRouteCollision(character, enabled, saved)
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") then
            if enabled == false and saved[descendant] == nil then
                saved[descendant] = descendant.CanCollide
            end

            pcall(function()
                descendant.CanCollide = enabled == true and saved[descendant] == true or false
            end)
        end
    end
end

local function restoreRouteCollision(saved)
    for part, canCollide in pairs(saved) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = canCollide
            end)
        end
    end
end

local function releaseRouteState()
    if Runtime.RouteCollisionState then
        restoreRouteCollision(Runtime.RouteCollisionState)
    end

    local humanoid = Runtime.RouteHumanoid
    if humanoid and humanoid.Parent then
        pcall(function()
            humanoid.PlatformStand = Runtime.RoutePlatformStand == true
            humanoid.AutoRotate = Runtime.RouteAutoRotate ~= false
        end)
    end

    Runtime.RouteCollisionState = nil
    Runtime.RouteHumanoid = nil
    Runtime.RoutePlatformStand = nil
    Runtime.RouteAutoRotate = nil
    Runtime.RouteMoving = false
end

local function pulseTouch(root, part)
    if not root or not part or not part.Parent then
        return
    end

    if type(firetouchinterest) == "function" then
        pcall(function()
            firetouchinterest(root, part, 0)
            RunService.Heartbeat:Wait()
            firetouchinterest(root, part, 1)
        end)
    else
        pcall(function()
            local rotation = root.CFrame.Rotation
            local contactHeight = (part.Size.Y * 0.5) + 2.5
            root.CFrame = CFrame.new(part.Position + Vector3.new(0, contactHeight, 0)) * rotation
            root.AssemblyLinearVelocity = Vector3.zero
            RunService.Heartbeat:Wait()
        end)
    end
end

local function moveToPosition(targetPosition, version, collisionState)
    local _, _, startingRoot = currentCharacter()
    local startingDistance = startingRoot and (targetPosition - startingRoot.Position).Magnitude or 0
    local deadline = os.clock() + math.max(6, (startingDistance / math.max(Runtime.WinTravelSpeed, 1)) * 3 + 3)

    while not winCancelled(version) do
        local character, humanoid, root = currentCharacter()
        if not character or not humanoid or not root then
            return false, "character was lost"
        end

        setRouteCollision(character, false, collisionState)
        local offset = targetPosition - root.Position
        local distance = offset.Magnitude
        if distance <= 1.5 then
            root.CFrame = CFrame.new(targetPosition) * root.CFrame.Rotation
            root.AssemblyLinearVelocity = Vector3.zero
            return true
        end
        if os.clock() >= deadline then
            return false, "travel timed out"
        end

        local deltaTime = RunService.Heartbeat:Wait()
        local step = math.min(distance, Runtime.WinTravelSpeed * math.max(deltaTime, 1 / 240))
        local nextPosition = root.Position + offset.Unit * step
        local flatDirection = Vector3.new(offset.X, 0, offset.Z)

        if flatDirection.Magnitude > 0.01 then
            root.CFrame = CFrame.lookAt(nextPosition, nextPosition + flatDirection.Unit)
        else
            root.CFrame = CFrame.new(nextPosition) * root.CFrame.Rotation
        end
        root.AssemblyLinearVelocity = Vector3.zero
    end

    return false, "cancelled"
end

local function waitRouteDelay(seconds, version)
    local deadline = os.clock() + seconds
    repeat
        RunService.Heartbeat:Wait()
    until winCancelled(version) or os.clock() >= deadline
    return not winCancelled(version)
end

local function runWinRoute(version)
    local route, finishGlow, routeError = findTowerRoute()
    if not route then
        return false, routeError
    end

    local character, humanoid, root = getCharacter(5)
    if not character then
        return false, "character was not ready"
    end

    local collisionState = {}
    local temporaryGod = not Runtime.GodMode and Workspace:FindFirstChild("KillbrickFlag") == nil
    local resumeFly = Runtime.Fly
    local oldPlatformStand = humanoid.PlatformStand
    local oldAutoRotate = humanoid.AutoRotate

    Runtime.RouteMoving = true
    Runtime.RouteCollisionState = collisionState
    Runtime.RouteHumanoid = humanoid
    Runtime.RoutePlatformStand = oldPlatformStand
    Runtime.RouteAutoRotate = oldAutoRotate
    if resumeFly then
        stopFlyMotion()
    end
    if temporaryGod then
        ensureGodFlag()
    end

    humanoid.PlatformStand = true
    humanoid.AutoRotate = false

    local completed = false
    local failureReason = nil

    for _, stage in ipairs(route) do
        if winCancelled(version) then
            failureReason = "cancelled"
            break
        end

        if stage.Start and stage.Start.Parent then
            local reached, reason = moveToPosition(stage.Start.Position + Vector3.new(0, 4.5, 0), version, collisionState)
            if not reached then
                failureReason = reason
                break
            end

            local _, _, currentRoot = currentCharacter()
            pulseTouch(currentRoot, stage.Start)
            if not waitRouteDelay(0.16, version) then
                failureReason = "cancelled"
                break
            end
        end
    end

    if not failureReason then
        local finishPosition = finishGlow.Position + Vector3.new(0, math.max(1, finishGlow.Size.Y * 0.25), 0)
        local reached, reason = moveToPosition(finishPosition, version, collisionState)
        if reached then
            local _, _, currentRoot = currentCharacter()
            pulseTouch(currentRoot, finishGlow)
            waitRouteDelay(0.6, version)
            completed = not winCancelled(version)
        else
            failureReason = reason
        end
    end

    releaseRouteState()

    if temporaryGod and not Runtime.GodMode then
        removeGodFlag()
    end
    if resumeFly and Runtime.Fly then
        startFlyMotion()
    end

    return completed, failureReason or (completed and nil or "finish was not reached")
end

local function setAutoWin(enabled)
    Runtime.AutoWin = enabled == true
    Runtime.WaitingForRound = false
    cancelWin()

    if Runtime.AutoWin then
        ensureGodFlag()
        notify("Auto Win", "Enabled. Death and anti-stuck retries are active.", "Success")
    else
        if not Runtime.GodMode then
            removeGodFlag()
        end
        notify("Auto Win", "Disabled.", "Info")
    end
end

local function hasToolNamed(name, backpack, character)
    return (backpack and backpack:FindFirstChild(name) ~= nil)
        or (character and character:FindFirstChild(name) ~= nil)
end

local function getEveryItem()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack") or LocalPlayer:WaitForChild("Backpack", 3)
    if not backpack then
        notify("Get Every Item", "Backpack was not found.", "Warning")
        return
    end

    local assets = ReplicatedStorage:FindFirstChild("Assets")
    local gearFolder = (assets and assets:FindFirstChild("Gear")) or ReplicatedStorage:FindFirstChild("Gear")
    if not gearFolder then
        notify("Get Every Item", "The game's Gear folder was not found.", "Warning")
        return
    end

    local added = 0
    local failed = 0
    local character = LocalPlayer.Character

    for _, source in ipairs(gearFolder:GetDescendants()) do
        if source:IsA("Tool") and not hasToolNamed(source.Name, backpack, character) then
            local ok = pcall(function()
                source:Clone().Parent = backpack
            end)

            if ok then
                added = added + 1
            else
                failed = failed + 1
            end
        end
    end

    if added > 0 then
        local suffix = failed > 0 and (" (" .. failed .. " failed)") or ""
        notify("Get Every Item", "Added " .. added .. " local gear item(s)" .. suffix .. ".", "Success")
    else
        notify("Get Every Item", "No new local gear could be added.", "Warning")
    end
end

task.spawn(function()
    while Runtime.Alive do
        if not Runtime.AutoWin then
            task.wait(0.15)
        elseif hasWonCurrentRound() then
            if not Runtime.WaitingForRound then
                Runtime.WaitingForRound = true
                notify("Auto Win", "Win detected. Waiting for the next round.", "Success")
            end

            if waitForNextRound() and Runtime.AutoWin then
                Runtime.WaitingForRound = false
                notify("Auto Win", "New round detected. Starting again.", "Info")
            end
        elseif not Runtime.WinBusy then
            Runtime.WaitingForRound = false
            Runtime.WinBusy = true
            cancelWin()
            local version = Runtime.WinVersion
            local ok, completed, reason = pcall(runWinRoute, version)
            Runtime.WinBusy = false

            if Runtime.AutoWin then
                local confirmed = hasWonCurrentRound()
                if ok and completed and not confirmed then
                    confirmed = waitForWinConfirmation(version, 5)
                end

                if confirmed then
                    Runtime.WaitingForRound = true
                    notify("Auto Win", "Win detected. Waiting for the next round.", "Success")
                else
                    if not ok then
                        releaseRouteState()
                        if Runtime.Fly then
                            startFlyMotion()
                        end
                        reason = "route error: " .. tostring(completed)
                    end

                    if reason ~= "cancelled" and os.clock() - Runtime.LastRetryNotice >= 6 then
                        Runtime.LastRetryNotice = os.clock()
                        notify("Anti-Stuck", "Retrying automatically: " .. tostring(reason or "win not confirmed"), "Warning")
                    end

                    local retryAt = os.clock() + 0.75
                    repeat
                        task.wait(0.1)
                    until not Runtime.Alive or not Runtime.AutoWin or os.clock() >= retryAt
                end
            end
        else
            task.wait(0.1)
        end
    end
end)

addConnection(UserInputService.JumpRequest:Connect(function()
    if not Runtime.Alive or not Runtime.DoubleJump or Runtime.Fly or Runtime.RouteMoving then
        return
    end

    local _, humanoid, root = currentCharacter()
    if not humanoid or not root then
        return
    end

    if humanoid.FloorMaterial ~= Enum.Material.Air then
        Runtime.AirJumps = 0
        Runtime.LastGroundJump = os.clock()
        return
    end

    if os.clock() - Runtime.LastGroundJump < 0.12 or Runtime.AirJumps >= 1 then
        return
    end

    Runtime.AirJumps = Runtime.AirJumps + 1
    local velocity = root.AssemblyLinearVelocity
    root.AssemblyLinearVelocity = Vector3.new(
        velocity.X,
        math.max(velocity.Y, Runtime.DoubleJumpPower),
        velocity.Z
    )
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end))

addConnection(LocalPlayer.CharacterAdded:Connect(function(character)
    cancelWin()
    releaseRouteState()
    stopFlyMotion()

    task.spawn(function()
        if captureCharacter(character) and Runtime.Fly then
            task.wait(0.15)
            startFlyMotion()
        end
    end)
end))

addConnection(RunService.Heartbeat:Connect(function()
    if not Runtime.Alive then
        return
    end

    if Runtime.GodMode or Runtime.AutoWin then
        ensureGodFlag()
    end
    if Runtime.GravityEnabled and Workspace.Gravity ~= Runtime.Gravity then
        Workspace.Gravity = Runtime.Gravity
    end

    applyCharacterFeatures()
    updateFly()
end))

if LocalPlayer.Character then
    captureCharacter(LocalPlayer.Character)
end

--// ZeHub UI Library (embedded; no external UI fetch required)
local UiLibrary = (function()
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

    local function setValue(value, fireCallback)
        enabled = value == true
        render(false)
        if fireCallback ~= false and callback then
            task.spawn(callback, enabled)
        end
    end

    hitbox.Activated:Connect(function()
        setValue(not enabled, true)
    end)

    bindRowHover(hitbox, row, rowStroke)
    registerThemeRefresh(function()
        if row.Parent then
            render(true)
        end
    end)
    render(true)
    return {
        Row = row,
        SetValue = function(_, value)
            setValue(value, true)
        end,
        GetValue = function()
            return enabled
        end,
    }
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

return Library
end)()

local Icons = {
    Player = "rbxassetid://10747373176",
    Fly = "rbxassetid://10734922971",
    Tower = "rbxassetid://10747363809",
}

local Window = UiLibrary:CreateWindow({
    Title = "ZeHub | Tower of Hell",
    Subtitle = "Movement • Survival • Tower",
    Theme = "Dark",
    Width = 500,
    Height = 430,
})
Runtime.Window = Window

local PlayerTab = Window:CreateTab({Name = "Player", Icon = Icons.Player})
local PlayerSurvival = PlayerTab:CreateSection({Name = "Survival"})

PlayerSurvival:CreateToggle({
    Name = "God Mode",
    Default = true,
    Flag = "TowerOfHell_GodMode",
    Callback = function(value)
        setGodMode(value)
    end,
})

local PlayerMovement = PlayerTab:CreateSection({Name = "Movement"})

PlayerMovement:CreateToggle({
    Name = "Walk Speed",
    Default = false,
    Flag = "TowerOfHell_WalkSpeedEnabled",
    Callback = function(value)
        Runtime.WalkSpeedEnabled = value == true
        if not Runtime.WalkSpeedEnabled then
            restoreWalkSpeed()
        end
    end,
})

PlayerMovement:CreateSlider({
    Name = "Walk Speed Value",
    Min = 16,
    Max = 200,
    Default = 32,
    Step = 1,
    Suffix = " studs/s",
    Flag = "TowerOfHell_WalkSpeed",
    Callback = function(value)
        Runtime.WalkSpeed = tonumber(value) or 32
    end,
})

PlayerMovement:CreateToggle({
    Name = "Jump",
    Default = false,
    Flag = "TowerOfHell_JumpEnabled",
    Callback = function(value)
        Runtime.JumpEnabled = value == true
        if not Runtime.JumpEnabled then
            restoreJump()
        end
    end,
})

PlayerMovement:CreateSlider({
    Name = "Jump Power",
    Min = 25,
    Max = 200,
    Default = 80,
    Step = 1,
    Flag = "TowerOfHell_JumpPower",
    Callback = function(value)
        Runtime.JumpPower = tonumber(value) or 80
    end,
})

PlayerMovement:CreateToggle({
    Name = "Double Jump",
    Default = false,
    Flag = "TowerOfHell_DoubleJump",
    Callback = function(value)
        Runtime.DoubleJump = value == true
        Runtime.AirJumps = 0
    end,
})

PlayerMovement:CreateSlider({
    Name = "Double Jump Power",
    Min = 25,
    Max = 150,
    Default = 55,
    Step = 1,
    Flag = "TowerOfHell_DoubleJumpPower",
    Callback = function(value)
        Runtime.DoubleJumpPower = tonumber(value) or 55
    end,
})

PlayerGravity:CreateToggle({
    Name = "Custom Gravity",
    Default = false,
    Flag = "TowerOfHell_GravityEnabled",
    Callback = function(value)
        setGravity(value)
    end,
})

PlayerGravity:CreateSlider({
    Name = "Gravity",
    Min = 25,
    Max = 300,
    Default = 147.15,
    Step = 0.05,
    Flag = "TowerOfHell_Gravity",
    Callback = function(value)
        Runtime.Gravity = tonumber(value) or 147.15
        if Runtime.GravityEnabled then
            Workspace.Gravity = Runtime.Gravity
        end
    end,
})

local PlayerGravity = PlayerTab:CreateSection({Name = "Gravity"})
local FlyTab = Window:CreateTab({Name = "Fly", Icon = Icons.Fly})
local FlyFlight = FlyTab:CreateSection({Name = "Flight"})

local FlyToggle
FlyToggle = FlyFlight:CreateToggle({
    Name = "Fly",
    Default = false,
    Flag = "TowerOfHell_Fly",
    Callback = function(value)
        local accepted = setFly(value)
        if value == true and not accepted and FlyToggle then
            task.defer(function()
                FlyToggle:SetValue(false)
            end)
        end
    end,
})

FlyFlight:CreateSlider({
    Name = "Fly Speed",
    Min = 10,
    Max = 250,
    Default = 55,
    Step = 1,
    Suffix = " studs/s",
    Flag = "TowerOfHell_FlySpeed",
    Callback = function(value)
        Runtime.FlySpeed = tonumber(value) or 55
    end,
})

FlyControls:CreateParagraph({
    Content = "Controls: WASD to move, Space to rise, and Left Ctrl or Q to descend.",
})

local FlyControls = FlyTab:CreateSection({Name = "Controls"})
local TowerTab = Window:CreateTab({Name = "Tower", Icon = Icons.Tower})
local TowerGame = TowerTab:CreateSection({Name = "Game"})

TowerGame:CreateToggle({
    Name = "Auto Win",
    Default = false,
    Flag = "TowerOfHell_AutoWin",
    Callback = function(value)
        setAutoWin(value)
    end,
})

TowerGame:CreateSlider({
    Name = "Win Travel Speed",
    Min = 30,
    Max = 180,
    Default = 85,
    Step = 1,
    Suffix = " studs/s",
    Flag = "TowerOfHell_WinTravelSpeed",
    Callback = function(value)
        Runtime.WinTravelSpeed = tonumber(value) or 85
    end,
})

TowerGame:CreateButton({
    Name = "Get Every Item",
    Callback = getEveryItem,
})

TowerGame:CreateParagraph({
    Content = "Get Every Item (Experimental): Copies locally available Tools from Assets.Gear into your Backpack. Server-only gear may not function or persist.",
})

local TowerCompatibility = TowerTab:CreateSection({Name = "Compatibility"})
TowerCompatibility:CreateParagraph({
    Content = executorDisplayName .. " • " .. executorStatusText,
})

TowerCompatibility:CreateParagraph({
    Content = (limitedModuleExecutor and "Xeno / Solara Fallback: " or "Executor Support: ") .. (limitedModuleExecutor
        and "Module-dependent extras are skipped. Auto Win stays available because it uses no ModuleScripts."
        or "Normal executor mode. Auto Win also stays module-free for reliability."),
})

function Runtime.Destroy()
    if not Runtime.Alive then
        return
    end

    Runtime.Alive = false
    Runtime.AutoWin = false
    cancelWin()
    releaseRouteState()
    Runtime.Fly = false
    stopFlyMotion()

    Runtime.GodMode = false
    removeGodFlag()
    setGravity(false)
    restoreWalkSpeed()
    restoreJump()

    for _, connection in ipairs(Runtime.Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(Runtime.Connections)

    if Runtime.Window and type(Runtime.Window.Destroy) == "function" then
        pcall(Runtime.Window.Destroy, Runtime.Window)
    end

    if Global.__AXONIC_TOWER_OF_HELL_RUNTIME == Runtime then
        Global.__AXONIC_TOWER_OF_HELL_RUNTIME = nil
    end
end

notify("ZeHub", "Tower of Hell loaded on " .. ExecutorName .. ".", "Success")
