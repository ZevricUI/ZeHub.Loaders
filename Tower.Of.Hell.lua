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

-- ============================================================================
-- ZeHub UI
-- Converted from the previous UI library to the uploaded ZeHub library.
-- ============================================================================
local UI_LIBRARY_URL = "https://raw.githubusercontent.com/Footagesus/ZeHub/main/ZeHub.lua"

local function loadUiLibrary()
    local lastError = "unknown UI error"

    for _ = 1, 3 do
        local ok, result = pcall(function()
            local source = game:HttpGet(UI_LIBRARY_URL)
            assert(type(source) == "string" and #source > 0, "empty ZeHub response")

            local loader, compileError = loadstring(source)
            assert(type(loader) == "function", compileError or "loadstring is unavailable")
            return loader()
        end)

        if ok and type(result) == "table" and type(result.CreateWindow) == "function" then
            return result
        end

        lastError = tostring(result)
        task.wait(0.4)
    end

    error("ZeHub UI could not load on " .. ExecutorName .. ": " .. lastError)
end

local ZeHub = loadUiLibrary()

-- notify() is kept compatible with the runtime code above.
-- ZeHub uses Content rather than Description and exposes Notify on the library.
local function notify(title, description, kind)
    if not ZeHub or type(ZeHub.Notify) ~= "function" then
        return
    end

    pcall(function()
        ZeHub:Notify({
            Title = title,
            Content = description,
            Duration = 3,
            CanClose = true,
        })
    end)
end

local Window = ZeHub:CreateWindow({
    Title = "Axonic | Tower of Hell",
    Folder = "AxonicConfigs",
    Icon = "solar:gamepad-bold",
    NewElements = true,
    HideSearchBar = false,

    OpenButton = {
        Title = "Open Axonic",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.5,
    },

    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },
})

Runtime.Window = Window
Runtime.Ui = ZeHub

-- --------------------------------------------------------------------------
-- Player
-- --------------------------------------------------------------------------
local PlayerTab = Window:Tab({
    Title = "Player",
    Icon = "solar:user-bold",
    IconShape = "Square",
    Border = true,
})

PlayerTab:Section({
    Title = "Survival",
})

PlayerTab:Toggle({
    Title = "God Mode",
    Desc = "Prevents Tower of Hell killbrick handling from affecting the script.",
    Value = true,
    Flag = "TowerOfHell_GodMode",
    Callback = function(value)
        setGodMode(value)
    end,
})

PlayerTab:Space()

PlayerTab:Section({
    Title = "Movement",
})

PlayerTab:Toggle({
    Title = "Walk Speed",
    Value = false,
    Flag = "TowerOfHell_WalkSpeedEnabled",
    Callback = function(value)
        Runtime.WalkSpeedEnabled = value == true
        if not Runtime.WalkSpeedEnabled then
            restoreWalkSpeed()
        end
    end,
})

PlayerTab:Slider({
    Title = "Walk Speed Value",
    Step = 1,
    Value = {
        Min = 16,
        Max = 200,
        Default = 32,
    },
    Callback = function(value)
        Runtime.WalkSpeed = tonumber(value) or 32
    end,
})

PlayerTab:Space()

PlayerTab:Toggle({
    Title = "Jump",
    Value = false,
    Flag = "TowerOfHell_JumpEnabled",
    Callback = function(value)
        Runtime.JumpEnabled = value == true
        if not Runtime.JumpEnabled then
            restoreJump()
        end
    end,
})

PlayerTab:Slider({
    Title = "Jump Power",
    Step = 1,
    Value = {
        Min = 25,
        Max = 200,
        Default = 80,
    },
    Callback = function(value)
        Runtime.JumpPower = tonumber(value) or 80
    end,
})

PlayerTab:Space()

PlayerTab:Toggle({
    Title = "Double Jump",
    Desc = "Allows one additional jump while airborne.",
    Value = false,
    Flag = "TowerOfHell_DoubleJump",
    Callback = function(value)
        Runtime.DoubleJump = value == true
        Runtime.AirJumps = 0
    end,
})

PlayerTab:Slider({
    Title = "Double Jump Power",
    Step = 1,
    Value = {
        Min = 25,
        Max = 150,
        Default = 55,
    },
    Callback = function(value)
        Runtime.DoubleJumpPower = tonumber(value) or 55
    end,
})

PlayerTab:Space()

PlayerTab:Toggle({
    Title = "Custom Gravity",
    Value = false,
    Flag = "TowerOfHell_GravityEnabled",
    Callback = function(value)
        setGravity(value)
    end,
})

PlayerTab:Slider({
    Title = "Gravity",
    Step = 0.05,
    Value = {
        Min = 25,
        Max = 300,
        Default = 147.15,
    },
    Callback = function(value)
        Runtime.Gravity = tonumber(value) or 147.15
        if Runtime.GravityEnabled then
            Workspace.Gravity = Runtime.Gravity
        end
    end,
})

-- --------------------------------------------------------------------------
-- Fly
-- --------------------------------------------------------------------------
local FlyTab = Window:Tab({
    Title = "Fly",
    Icon = "solar:plain-bold",
    IconShape = "Square",
    Border = true,
})

FlyTab:Section({
    Title = "Flight",
})

local FlyToggle
FlyToggle = FlyTab:Toggle({
    Title = "Fly",
    Desc = "WASD to move, Space to rise, Left Ctrl or Q to descend.",
    Value = false,
    Flag = "TowerOfHell_Fly",
    Callback = function(value)
        local accepted = setFly(value)

        if value == true and not accepted and FlyToggle then
            task.defer(function()
                pcall(function()
                    FlyToggle:Set(false)
                end)
            end)
        end
    end,
})

FlyTab:Slider({
    Title = "Fly Speed",
    Step = 1,
    Value = {
        Min = 10,
        Max = 250,
        Default = 55,
    },
    Callback = function(value)
        Runtime.FlySpeed = tonumber(value) or 55
    end,
})

FlyTab:Paragraph({
    Title = "Controls",
    Desc = "WASD to move, Space to rise, and Left Ctrl or Q to descend.",
})

-- --------------------------------------------------------------------------
-- Tower
-- --------------------------------------------------------------------------
local TowerTab = Window:Tab({
    Title = "Tower",
    Icon = "solar:buildings-2-bold",
    IconShape = "Square",
    Border = true,
})

TowerTab:Section({
    Title = "Game",
})

TowerTab:Toggle({
    Title = "Auto Win",
    Desc = "Runs the tower route automatically and retries if the route gets stuck.",
    Value = false,
    Flag = "TowerOfHell_AutoWin",
    Callback = function(value)
        setAutoWin(value)
    end,
})

TowerTab:Slider({
    Title = "Win Travel Speed",
    Step = 1,
    Value = {
        Min = 30,
        Max = 180,
        Default = 85,
    },
    Callback = function(value)
        Runtime.WinTravelSpeed = tonumber(value) or 85
    end,
})

TowerTab:Button({
    Title = "Get Every Item",
    Desc = "Copies locally available Tools from Assets.Gear into your Backpack.",
    Icon = "package",
    Callback = getEveryItem,
})

TowerTab:Paragraph({
    Title = "Get Every Item — Experimental",
    Desc = "Server-only gear may not function or persist.",
})

-- --------------------------------------------------------------------------
-- Compatibility / information
-- --------------------------------------------------------------------------
local InfoTab = Window:Tab({
    Title = "Info",
    Icon = "solar:info-square-bold",
    IconShape = "Square",
    Border = true,
})

InfoTab:Section({
    Title = "Compatibility",
})

InfoTab:Paragraph({
    Title = executorDisplayName,
    Desc = executorStatusText,
})

InfoTab:Paragraph({
    Title = limitedModuleExecutor and "Xeno / Solara Fallback" or "Executor Support",
    Desc = limitedModuleExecutor
        and "Module-dependent extras are skipped. Auto Win stays available because it uses no ModuleScripts."
        or "Normal executor mode. Auto Win also stays module-free for reliability.",
})

InfoTab:Button({
    Title = "Reload Character Features",
    Icon = "refresh-cw",
    Callback = function()
        captureCharacter(LocalPlayer.Character)
        applyCharacterFeatures()

        if Runtime.Fly then
            startFlyMotion()
        end

        notify("Axonic", "Character features refreshed.", "Success")
    end,
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

notify("Axonic", "Tower of Hell loaded on " .. ExecutorName .. " with ZeHub.", "Success")
