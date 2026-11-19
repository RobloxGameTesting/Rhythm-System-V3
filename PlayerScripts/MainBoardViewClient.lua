local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer

local Modules = ReplicatedStorage:WaitForChild("Modules")
local HallOfFameUI = require(Modules:WaitForChild("HallOfFameUI"))
local SessionCameraSettings = require(Modules:WaitForChild("SessionCameraSettings"))
local BoardSwitch = require(Modules:WaitForChild("BoardSwitch"))
local BoardZoom = require(Modules:WaitForChild("BoardZoom"))

local boardExtras = workspace:WaitForChild("Map"):WaitForChild("BoardExtras")
local boardViewAnchor = boardExtras:WaitForChild("BoardViewAnchor")
local hallOfFameBanner = boardExtras:WaitForChild("HallOfFameBanner")
local hallOfFameDrop = boardExtras:WaitForChild("HallOfFameDrop")
local boardPrompt = boardViewAnchor:WaitForChild("BoardPrompt")

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local hallOfFameBannerSurface = Instance.new("SurfaceGui")
hallOfFameBannerSurface.Name = "HallOfFameBannerSurface"
hallOfFameBannerSurface.Adornee = hallOfFameBanner
hallOfFameBannerSurface.Face = Enum.NormalId.Front
hallOfFameBannerSurface.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
hallOfFameBannerSurface.CanvasSize = HallOfFameUI.BannerCanvas
hallOfFameBannerSurface.LightInfluence = 0.1
hallOfFameBannerSurface.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
hallOfFameBannerSurface.ResetOnSpawn = false
hallOfFameBannerSurface.AlwaysOnTop = false
hallOfFameBannerSurface.MaxDistance = 140
hallOfFameBannerSurface.Active = false
hallOfFameBannerSurface.Parent = PlayerGui

local hallOfFameDropSurface = Instance.new("SurfaceGui")
hallOfFameDropSurface.Name = "HallOfFameDropSurface"
hallOfFameDropSurface.Adornee = hallOfFameDrop
hallOfFameDropSurface.Face = Enum.NormalId.Front
hallOfFameDropSurface.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
hallOfFameDropSurface.CanvasSize = HallOfFameUI.DropCanvas
hallOfFameDropSurface.LightInfluence = 0.1
hallOfFameDropSurface.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
hallOfFameDropSurface.ResetOnSpawn = false
hallOfFameDropSurface.AlwaysOnTop = false
hallOfFameDropSurface.MaxDistance = 90
hallOfFameDropSurface.Active = false
hallOfFameDropSurface.Enabled = false
hallOfFameDropSurface.Parent = PlayerGui

local function playSfx() -- 2 equivalent calls inferred from this helper
	local boardViewSfx = Instance.new("Sound")
	boardViewSfx.Name = "BoardViewSfx"
	boardViewSfx.SoundId = "rbxassetid://82896519916504"
	boardViewSfx.Volume = 0.6
	boardViewSfx.Parent = SoundService
	boardViewSfx:Play()
	Debris:AddItem(boardViewSfx, 4)
end

local flag = false
local v = "overview"
local v2 = nil
local v3 = nil
local v4 = 4
local v5 = nil
local fn
local fn2

local HallOfFameRemotes = ReplicatedStorage:WaitForChild("HallOfFameRemotes")
local HallGet = HallOfFameRemotes:WaitForChild("HallGet")
local HallChanged = HallOfFameRemotes:WaitForChild("HallChanged")
local FreePlayGet = HallOfFameRemotes:WaitForChild("FreePlayGet", 15)

local v6 = nil

local function fetch(p)
	for _ = 1, 3 do
		local success, result = pcall(function()
			return HallGet:InvokeServer(p)
		end)

		if success and typeof(result) == "table" then
			return result
		end

		task.wait(1.2)
	end

	return nil
end

local function loadTop5() -- 1 equivalent call inferred from this helper
	local v7 = fetch("Top5")

	if v7 and v6 then
		v6:SetTop5(v7.Top)
		v6:SetYou(v7.You)
		v6:SetRankedCount(v7.Total)
	end
end

local function loadTop100()
	local v7 = fetch("Top100")

	if v7 and v6 then
		v6:SetTop100(v7.Top, v7.You)
	end
end

local v7 = {}
local function loadFreePlay(p)
	if not FreePlayGet or v7[p] then
		return
	end

	v7[p] = true
	local v8 = nil

	for _ = 1, 3 do
		local success, result = pcall(function()
			return FreePlayGet:InvokeServer(p)
		end)

		if success and typeof(result) == "table" then
			v8 = result
			break
		end

		task.wait(0.7)
	end

	v7[p] = nil

	if v6 then
		if v8 then
			v6:SetFreePlay(p, v8.Top, v8.You)
		else
			v6:SetFreePlay(p, nil, nil)
		end
	end
end

HallChanged.OnClientEvent:Connect(function(p, p2)
	if p == "You" and v6 and typeof(p2) == "table" then
		v6:SetYou(p2)
	end
end)

v6 = HallOfFameUI.new(hallOfFameBannerSurface, hallOfFameDropSurface, {
	dropPart = hallOfFameDrop,
	onFreePlay = function(p)
		task.spawn(loadFreePlay, p)
	end,
	onMore = function()
		if v6:IsDropOpen() then
			return
		end

		v6:OpenDrop()
	end,
	onDropOpened = function()
		playSfx() -- inferred equivalent call

		if flag then
			v = "drop"
			fn2()
		end

		task.spawn(loadTop100)

		if v6 and v6:GetTab() == "freeplay" then
			task.spawn(loadFreePlay, v6:GetFreePlayFilter())
		end
	end,
	onDropClosed = function(p)
		if not p then
			playSfx() -- inferred equivalent call
		end

		if flag and v == "drop" then
			v = "hall"
			fn2()
		end
	end
})

task.spawn(function()
	while v6 and not v6._destroyed do
		loadTop5() -- inferred equivalent call
		task.wait(60)
	end
end)

local v8 = {}
local connections = {}

local function hideInstance(instance)
	if instance:IsA("BasePart") then
		if not v8[instance] then
			v8[instance] = { canQuery = instance.CanQuery }
		end

		instance.LocalTransparencyModifier = 1

		instance.CanQuery = false
	elseif instance:IsA("Decal") then
		if not v8[instance] then
			v8[instance] = { transparency = instance.Transparency }
		end

		instance.Transparency = 1
	elseif
		instance:IsA("ParticleEmitter")
		or instance:IsA("Trail")
		or instance:IsA("Beam")
		or instance:IsA("Fire")
		or instance:IsA("Smoke")
		or instance:IsA("Sparkles")
		or instance:IsA("Highlight")
		or instance:IsA("BillboardGui")
		or instance:IsA("SurfaceGui")
	then
		if not v8[instance] then
			v8[instance] = { enabled = instance.Enabled }
		end

		instance.Enabled = false
	elseif instance:IsA("Humanoid") then
		if not v8[instance] then
			v8[instance] = { displayDistance = instance.DisplayDistanceType }
		end

		instance.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end
end

local function hideCharacter(folder)
	for _, descendant in ipairs(folder:GetDescendants()) do
		hideInstance(descendant)
	end

	table.insert(connections, folder.DescendantAdded:Connect(hideInstance))
end

local function watchPlayer(player)
	if player.Character then
		hideCharacter(player.Character)
	end

	table.insert(connections, player.CharacterAdded:Connect(function(character)
		task.defer(hideCharacter, character)
	end))
end

local function hideAllPlayers()
	for _, v9 in ipairs(Players:GetPlayers()) do
		if v9.Character then
			hideCharacter(v9.Character)
		end

		table.insert(connections, v9.CharacterAdded:Connect(function(character)
			task.defer(hideCharacter, character)
		end))
	end

	table.insert(connections, Players.PlayerAdded:Connect(watchPlayer))
end

local function stopWatchingPlayers()
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	connections = {}
end

local function restoreAllHidden()
	for k, v9 in pairs(v8) do
		if not k.Parent then
			continue
		end

		if v9.canQuery == nil then
			if v9.transparency == nil then
				if v9.enabled == nil then
					if v9.displayDistance ~= nil then
						k.DisplayDistanceType = v9.displayDistance
					end
				else
					k.Enabled = v9.enabled
				end
			else
				k.Transparency = v9.transparency
			end
		else
			k.LocalTransparencyModifier = 0
			k.CanQuery = v9.canQuery
		end
	end

	v8 = {}
end

local count = 0
local v9 = nil
local cameraType = nil
local v10 = nil
local fieldOfView = nil
local v11 = true
local menuFlag = false
local controls = nil
local diedConnection = nil
local renderSteppedConnection = nil
local viewportSizeChangedConnection = nil
local v12 = nil

local cframe = nil
local v13 = 7.5
local flag2 = false
local total = 0
local total2 = 0
local total3 = 0
local total4 = 0

local function numberAttribute(attributeName, p) -- 3 equivalent calls inferred from this helper
	local attribute = script:GetAttribute(attributeName)
	return if type(attribute) == "number" then attribute else p
end

local function fitDistance(p, x, y, p2, p3) -- 1 equivalent call inferred from this helper
	local viewportSize = p.ViewportSize
	local v14 = math.max(viewportSize.X / math.max(viewportSize.Y, 1), 0.2)

	return (math.max(y * p3 / 2 / 0.7002075382097097, x * p2 / 2 / v14 / 0.7002075382097097))
end

local function computeGoal(currentCamera)
	local cframe2, x, y, v14, v15

	if v == "drop" then
		cframe2 = hallOfFameDrop.CFrame
		x = hallOfFameDrop.Size.X
		y = hallOfFameDrop.Size.Y
		v14 = 1.1
		v15 = 1.04
	elseif v == "hall" then
		cframe2 = hallOfFameBanner.CFrame
		x = hallOfFameBanner.Size.X
		y = hallOfFameBanner.Size.Y
		v14 = 1.18
		v15 = 1.05
	else
		cframe2 = boardViewAnchor.CFrame
		x = boardViewAnchor.Size.X
		y = boardViewAnchor.Size.Y
		v14 = 1.1
		v15 = 1.04
	end

	local v16 = fitDistance(currentCamera, x, y, v15, v14) -- inferred equivalent call
	local v17 = cframe2.Position + cframe2.LookVector * v16
	return CFrame.lookAt(v17, cframe2.Position, Vector3.new(0, 1, 0)), v16
end

fn2 = function()
	local currentCamera = workspace.CurrentCamera

	if not (flag and currentCamera) then
		return
	end

	v3, v4 = computeGoal(currentCamera)
end

local function parallaxCurve(p) -- 2 equivalent calls inferred from this helper
	return math.sign(p) * math.abs(p) ^ 1.25
end

local function cameraStep(p)
	local currentCamera = workspace.CurrentCamera

	if not (currentCamera and v3 and cframe) then
		return
	end

	local v14 = math.min(p, 0.1)

	cframe = cframe:Lerp(v3, 1 - math.exp(-v14 * v13))
	local v15 = numberAttribute("ParallaxYawDeg", 4.5) -- inferred equivalent call
	local v16 = numberAttribute("ParallaxPitchDeg", 2.2) -- inferred equivalent call
	local v17 = numberAttribute("ParallaxShift", 0.022) -- inferred equivalent call
	total += ((flag and v ~= "overview" and 1 or 0) - total) * (1 - math.exp(-v14 * 3))
	local v18, v19

	if UserInputService.MouseEnabled then
		local mouseLocation = UserInputService:GetMouseLocation()
		local viewportSize = currentCamera.ViewportSize
		local v20 = math.clamp((mouseLocation.X - viewportSize.X / 2) / (viewportSize.X / 2), -1, 1)
		local v21 = math.clamp(-(mouseLocation.Y - viewportSize.Y / 2) / (viewportSize.Y / 2), -1, 1)
		v18 = parallaxCurve(v20) -- inferred equivalent call
		v19 = parallaxCurve(v21) -- inferred equivalent call
	else
		v18 = 0
		v19 = 0
	end

	local v20 = (v6 and v6:IsInteractiveHovered() or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1))
		and 1
		or v6 and v6:IsDropOpen() and 0.4
		or 0
	total4 += (v20 - total4) * (1 - math.exp(-v14 * 12))
	local v21 = (1 - math.exp(-v14 * 5)) * (1 - total4)
	total2 += (v18 - total2) * v21
	total3 += (v19 - total3) * v21

	local now = os.clock()
	local v22 = math.sin(now * 0.7) * 0.1 + math.sin(now * 1.9) * 0.1 * 0.35
	local v23 = math.cos(now * 0.55) * 0.07
	local v24 = 1 - total4 * 0.9
	local v25 = (total2 + v22 * v24) * total
	local v26 = (total3 + v23 * v24) * total

	local v27 = -math.rad(v15) * v25
	local v28 = math.rad(v16) * v26
	local v29 = -v25 * 0.02
	local v30 = cframe.RightVector * (v25 * v4 * v17) + cframe.UpVector * (v26 * v4 * v17)
	currentCamera.CFrame = cframe * CFrame.Angles(v28, v27, v29) + v30
end

local function stopCameraStep() -- 2 equivalent calls inferred from this helper
	if flag2 then
		flag2 = false
		RunService:UnbindFromRenderStep("MainBoardViewCamera")
	end
end

local function waitForCameraSettle(p)
	local lastTime = os.clock()

	while os.clock() - lastTime < p do
		RunService.RenderStepped:Wait()

		if cframe and v3 and (cframe.Position - v3.Position).Magnitude < 0.02 then
			break
		end
	end
end

local function setControlsEnabled(p) -- 2 equivalent calls inferred from this helper
	pcall(function()
		if not controls then
			local PlayerModule = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
			controls = PlayerModule:GetControls()
		end

		if p then
			controls:Enable()
		else
			controls:Disable()
		end
	end)
end

local function lockZoomTemporarily(p)
	LocalPlayer.CameraMinZoomDistance = p
	LocalPlayer.CameraMaxZoomDistance = p
	task.delay(0.35, function()
		LocalPlayer.CameraMinZoomDistance = 0.5
		LocalPlayer.CameraMaxZoomDistance = 20
	end)
end

local function releaseMenuFlag() -- 1 equivalent call inferred from this helper
	if menuFlag then
		menuFlag = false
		SessionCameraSettings.SetMenuOpen(false)
	end
end

local function fn3()
	local v14 = v5

	if not v14 then
		return
	end

	local v15 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	local v16 = v == "overview" and "CLOSE" or "BACK"
	v14.Text = v15 and v16 or v16 .. "  [Q]"
	v14.AnchorPoint = Vector2.new(0.5, 1)
	v14.Position = UDim2.new(0.5, 0, 1, -18)
	v14.Size = UDim2.fromOffset(v15 and 150 or 210, 46)
end

local function createFocusGui()
	if v12 then
		return v12
	end

	local mainBoardViewFocusUI = Instance.new("ScreenGui")
	mainBoardViewFocusUI.Name = "MainBoardViewFocusUI"
	mainBoardViewFocusUI.ResetOnSpawn = false
	mainBoardViewFocusUI.DisplayOrder = 60
	mainBoardViewFocusUI.IgnoreGuiInset = false
	mainBoardViewFocusUI.Enabled = false
	mainBoardViewFocusUI.Parent = PlayerGui

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.AnchorPoint = Vector2.new(0.5, 1)
	closeButton.Position = UDim2.new(0.5, 0, 1, -18)
	closeButton.Size = UDim2.fromOffset(210, 46)
	closeButton.BackgroundColor3 = Color3.fromRGB(26, 26, 28)
	closeButton.AutoButtonColor = true
	closeButton.Font = Enum.Font.GothamBlack
	closeButton.Text = "CLOSE  [Q]"
	closeButton.TextSize = 20
	closeButton.TextColor3 = Color3.fromRGB(244, 232, 200)
	closeButton.Rotation = -1.5
	closeButton.Parent = mainBoardViewFocusUI
	v5 = closeButton

	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	require(ReplicatedStorage2.Modules:WaitForChild("BoardBackButton")).Style(closeButton)

	closeButton.MouseButton1Click:Connect(function()
		BoardSwitch.Back()
	end)

	v12 = mainBoardViewFocusUI
	return mainBoardViewFocusUI
end

local function enterFocus(data, value)
	if flag then
		return
	end

	local currentCamera = workspace.CurrentCamera
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not currentCamera or not humanoid or humanoid.Health <= 0 then
		return
	end

	flag = true
	v = value or "overview"
	count += 1
	local v14 = count
	v9 = character

	if data then
		cameraType = data.CameraType
		v10 = data.CameraCFrame
		fieldOfView = data.FieldOfView
	else
		cameraType = currentCamera.CameraType
		v10 = currentCamera.CFrame
		fieldOfView = currentCamera.FieldOfView
	end

	if data then
		menuFlag = data.MenuFlag == true
	elseif not menuFlag then
		menuFlag = true
		SessionCameraSettings.SetMenuOpen(true)
	end

	if not data then
		RunService.RenderStepped:Wait()

		if not flag or count ~= v14 then
			return
		end
	end

	setControlsEnabled(false) -- inferred equivalent call

	if data then
		v11 = data.PromptServiceEnabled
	else
		v11 = ProximityPromptService.Enabled
	end

	ProximityPromptService.Enabled = false

	hideAllPlayers()
	task.spawn(function()
		while flag and count == v14 do
			for _, v15 in ipairs(Players:GetPlayers()) do
				local character2 = v15.Character

				if not character2 then
					continue
				end

				for _, part in ipairs(character2:GetDescendants()) do
					if part:IsA("BasePart") and (part.LocalTransparencyModifier ~= 1 or part.CanQuery) then
						hideInstance(part)
					end
				end
			end

			task.wait(0.25)
		end
	end)

	hallOfFameBannerSurface.Active = true
	hallOfFameBannerSurface.Active = v ~= "overview"

	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.FieldOfView = 70

	v3, v4 = computeGoal(currentCamera)
	cframe = currentCamera.CFrame
	v13 = 7.5
	total = 0
	total2 = 0
	total3 = 0
	total4 = 0
	RunService:BindToRenderStep("MainBoardViewCamera", Enum.RenderPriority.Camera.Value + 1, cameraStep)
	flag2 = true

	viewportSizeChangedConnection = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if flag then
			fn2()
		end
	end)

	local focusGui = createFocusGui()
	focusGui.Enabled = true
	v5.Visible = true
	fn3()

	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true

		if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
			task.spawn(fn)
			return
		end

		local fov = BoardZoom.Fov(70)

		if math.abs(currentCamera.FieldOfView - fov) > 0.01 then
			currentCamera.FieldOfView = fov
		end
	end)

	ContextActionService:BindActionAtPriority("MainBoardViewExit", function(_, p)
		if UserInputService:GetFocusedTextBox() then
			return Enum.ContextActionResult.Pass
		end

		if p == Enum.UserInputState.Begin then
			BoardSwitch.Back()
		end

		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.Q, Enum.KeyCode.Backspace, Enum.KeyCode.ButtonB)

	diedConnection = humanoid.Died:Connect(function()
		fn()
	end)

	v2 = v == "overview" and "Overview" or "Hall"
	BoardSwitch.SetCurrent(v2)
end

fn = function(p)
	if not flag then
		return
	end

	flag = false
	count += 1

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if diedConnection then
		diedConnection:Disconnect()
		diedConnection = nil
	end

	if viewportSizeChangedConnection then
		viewportSizeChangedConnection:Disconnect()
		viewportSizeChangedConnection = nil
	end

	ContextActionService:UnbindAction("MainBoardViewExit")

	if v6 then
		v6:CloseDrop(true)
		v6:ResetHover()
	end

	hallOfFameBannerSurface.Active = false

	if v12 then
		v12.Enabled = false
	end

	local v14 = v2
	v2 = nil
	v = "overview"

	if p then
		stopCameraStep() -- inferred equivalent call
		stopWatchingPlayers()
		restoreAllHidden()
		local v15 = {
			CameraType = cameraType,
			CameraCFrame = v10,
			FieldOfView = fieldOfView,
			PromptServiceEnabled = v11,
			MenuFlag = menuFlag
		}

		menuFlag = false
		v10 = nil
		v9 = nil
		BoardSwitch.ClearCurrent(v14)
		return v15
	else
		local currentCamera = workspace.CurrentCamera
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local v15

		if currentCamera == nil or v10 == nil or character ~= v9 or humanoid == nil or not (humanoid.Health > 0) then
			v15 = false
		else
			v15 = humanoidRootPart ~= nil
		end

		stopWatchingPlayers()
		restoreAllHidden()

		if v15 then
			v3 = v10
			v13 = 9
			waitForCameraSettle(0.9)
		end

		stopCameraStep() -- inferred equivalent call
		stopWatchingPlayers()
		restoreAllHidden()
		ProximityPromptService.Enabled = v11
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default

		if currentCamera then
			local cameraType2 = cameraType or Enum.CameraType.Custom

			if cameraType2 == Enum.CameraType.Scriptable then
				cameraType2 = Enum.CameraType.Custom
			end

			if v15 then
				currentCamera.CFrame = v10
				local v16 = math.clamp((v10.Position - humanoidRootPart.Position).Magnitude, 0.5, 20)
				LocalPlayer.CameraMinZoomDistance = v16
				LocalPlayer.CameraMaxZoomDistance = v16
				task.delay(0.35, function()
					LocalPlayer.CameraMinZoomDistance = 0.5
					LocalPlayer.CameraMaxZoomDistance = 20
				end)
			end

			currentCamera.CameraType = cameraType2

			if fieldOfView then
				currentCamera.FieldOfView = fieldOfView
			end
		end

		setControlsEnabled(true) -- inferred equivalent call
		releaseMenuFlag() -- inferred equivalent call
		v10 = nil
		v9 = nil
		BoardSwitch.ClearCurrent(v14)
	end
end

boardPrompt.Triggered:Connect(function(player)
	if player == LocalPlayer then
		enterFocus(nil, "overview")
	end
end)

LocalPlayer.CharacterAdded:Connect(function()
	if flag then
		task.spawn(fn)
	end
end)

BoardSwitch.Register("Overview", {
	ExitForHandoff = function()
		return fn(true)
	end,
	EnterWithHandoff = function(p)
		enterFocus(p, "overview")
	end,
	Exit = function()
		fn()
	end,
	Back = function()
		fn()
	end,
	NoEmptyClickBack = true
})

BoardSwitch.Register("Hall", {
	Part = hallOfFameBanner,
	ExitForHandoff = function()
		return fn(true)
	end,
	EnterWithHandoff = function(p)
		enterFocus(p, "hall")
	end,
	Exit = function()
		fn()
	end,
	Back = function()
		if v6 and v6:CloseInfo() then
			return
		end

		if v6 and v6:IsDropOpen() then
			v6:CloseDrop()
		else
			BoardSwitch.Request("Overview")
		end
	end
})

task.spawn(function()
	local switchClick = hallOfFameBanner:WaitForChild("SwitchClick", 15)

	if switchClick then
		switchClick.MouseClick:Connect(function(p)
			if p == LocalPlayer then
				BoardSwitch.Request("Hall")
			end
		end)
	end
end)