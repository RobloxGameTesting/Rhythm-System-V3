local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer

local Modules = ReplicatedStorage:WaitForChild("Modules")
local InfoBoardUI = require(Modules:WaitForChild("InfoBoardUI"))
local SessionCameraSettings = require(Modules:WaitForChild("SessionCameraSettings"))
local BoardSwitch = require(Modules:WaitForChild("BoardSwitch"))
local BoardZoom = require(Modules:WaitForChild("BoardZoom"))

local v = 5
local v2 = 2.5

local v3 = 0.025

local v4 = 0.14

local inFocusRadius = 0.06
local v5 = 1
local v6 = 1

local function numberAttribute(attributeName, p) -- 7 equivalent calls inferred from this helper
	local attribute = script:GetAttribute(attributeName)
	return if type(attribute) == "number" then attribute else p
end

local function refreshTunables()
	v4 = numberAttribute("LiftPaper", v4) -- inferred equivalent call
	inFocusRadius = numberAttribute("DofInFocusRadius", inFocusRadius) -- inferred equivalent call
	v5 = numberAttribute("DofFarIntensity", v5) -- inferred equivalent call
	v6 = numberAttribute("DofLayers", v6) -- inferred equivalent call
	v = numberAttribute("ParallaxYawDeg", v) -- inferred equivalent call
	v2 = numberAttribute("ParallaxPitchDeg", v2) -- inferred equivalent call
	v3 = numberAttribute("ParallaxShift", v3) -- inferred equivalent call
end

local infoBoard = workspace:WaitForChild("Map"):WaitForChild("InfoBoard")
local paper = infoBoard:WaitForChild("Paper")

local cframe = paper.CFrame
local pivot = infoBoard:GetPivot()
local v7 = InfoBoardUI.CanvasSize.X / paper.Size.X

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local infoBoardSurface = Instance.new("SurfaceGui")
infoBoardSurface.Name = "InfoBoardSurface"
infoBoardSurface.Adornee = paper
infoBoardSurface.Face = Enum.NormalId.Front
infoBoardSurface.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
infoBoardSurface.CanvasSize = InfoBoardUI.CanvasSize
infoBoardSurface.LightInfluence = 0.2
infoBoardSurface.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
infoBoardSurface.ResetOnSpawn = false
infoBoardSurface.AlwaysOnTop = false
infoBoardSurface.MaxDistance = 90
infoBoardSurface.Active = false
infoBoardSurface.Parent = PlayerGui

local function playSfx() -- 2 equivalent calls inferred from this helper
	local infoBoardSfx = Instance.new("Sound")
	infoBoardSfx.Name = "InfoBoardSfx"
	infoBoardSfx.SoundId = "rbxassetid://82896519916504"
	infoBoardSfx.Volume = 0.6
	infoBoardSfx.Parent = SoundService
	infoBoardSfx:Play()
	Debris:AddItem(infoBoardSfx, 4)
end

local flag = false
local v8 = "paper"
local v9 = nil
local v10 = nil
local v11 = 2
local v12 = nil
local fn
local fn2

local InfoBoardRemotes = ReplicatedStorage:WaitForChild("InfoBoardRemotes")
local InfoSync = InfoBoardRemotes:WaitForChild("InfoSync")
local InfoChanged = InfoBoardRemotes:WaitForChild("InfoChanged")
local InfoFocus = InfoBoardRemotes:WaitForChild("InfoFocus")

local v13 = nil
local v14 = {}

local function applyEvent(p, p2) -- 2 equivalent calls inferred from this helper
	if p == "Map" then
		v13:SetMap(p2)
	elseif p == "Board" then
		v13:SetBoard(p2)
	elseif p == "Online" then
		v13:SetOnline(p2)
	end
end

InfoChanged.OnClientEvent:Connect(function(value, p)
	if typeof(value) ~= "string" or typeof(p) ~= "table" then
		return
	end

	if v13 then
		applyEvent(value, p) -- inferred equivalent call
	else
		table.insert(v14, { value, p })
	end
end)

v13 = InfoBoardUI.new(infoBoardSurface, {
	onOpened = function(p)
		playSfx() -- inferred equivalent call
		v8 = "open"
		v9 = p

		if v12 then
			v12.Visible = false
		end

		fn2()
	end,
	onClosed = function(p)
		if not p then
			playSfx() -- inferred equivalent call
		end

		v8 = "paper"
		v9 = nil

		if v12 then
			v12.Visible = true
		end

		fn2()
	end
})

for _, v15 in ipairs(v14) do
	applyEvent(v15[1], v15[2]) -- inferred equivalent call
end

v14 = {}

InfoSync:FireServer()

task.spawn(function()
	while v13 and not v13._destroyed do
		task.wait(60)
		v13:RefreshTimes()
	end
end)

local v15 = {}
local connections = {}

local function hideInstance(instance)
	if instance:IsA("BasePart") then
		if not v15[instance] then
			v15[instance] = { canQuery = instance.CanQuery }
		end

		instance.LocalTransparencyModifier = 1

		instance.CanQuery = false
	elseif instance:IsA("Decal") then
		if not v15[instance] then
			v15[instance] = { transparency = instance.Transparency }
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
		if not v15[instance] then
			v15[instance] = { enabled = instance.Enabled }
		end

		instance.Enabled = false
	elseif instance:IsA("Humanoid") then
		if not v15[instance] then
			v15[instance] = { displayDistance = instance.DisplayDistanceType }
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
	for _, v16 in ipairs(Players:GetPlayers()) do
		if v16.Character then
			hideCharacter(v16.Character)
		end

		table.insert(connections, v16.CharacterAdded:Connect(function(character)
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
	for k, v16 in pairs(v15) do
		if not k.Parent then
			continue
		end

		if v16.canQuery == nil then
			if v16.transparency == nil then
				if v16.enabled == nil then
					if v16.displayDistance ~= nil then
						k.DisplayDistanceType = v16.displayDistance
					end
				else
					k.Enabled = v16.enabled
				end
			else
				k.Transparency = v16.transparency
			end
		else
			k.LocalTransparencyModifier = 0
			k.CanQuery = v16.canQuery
		end
	end

	v15 = {}
end

local count = 0
local v16 = nil
local cameraType = nil
local v17 = nil
local fieldOfView = nil
local v18 = true
local menuFlag = false
local controls = nil
local diedConnection = nil
local renderSteppedConnection = nil
local viewportSizeChangedConnection = nil
local v19 = nil

local cframe2 = nil
local v20 = 7.5
local flag2 = false
local v21 = false
local total = 0
local total2 = 0
local total3 = 0
local total4 = 0

local total5 = 0
local v22 = 0
local v23 = {}
local depthOfFieldEffect = nil
local enabled = nil
local total6 = 0
local v24 = 0
local focusDistance = 2

local function focusPaperCFrame() -- 2 equivalent calls inferred from this helper
	return cframe + cframe.LookVector * v4
end

local function canvasToWorld(cframe3, p, p2) -- 1 equivalent call inferred from this helper
	return cframe3:PointToWorldSpace((Vector3.new(paper.Size.X / 2 - p / v7, paper.Size.Y / 2 - p2 / v7, 0)))
end

local function computeGoal(currentCamera)
	local canvasSize = InfoBoardUI.CanvasSize
	local viewportSize = currentCamera.ViewportSize
	local v25 = focusPaperCFrame() -- inferred equivalent call
	local v26, v27

	if v8 == "open" and v9 then
		v26 = math.min(viewportSize.Y * 0.96 / (v9.H + 16), viewportSize.X * 0.96 / (v9.W + 16), 2.2)

		v27 = canvasToWorld(v25, v9.X + v9.W / 2, v9.Y + v9.H / 2) -- inferred equivalent call
	else
		v26 = math.min(viewportSize.Y * 0.88 / canvasSize.Y, viewportSize.X * 0.92 / canvasSize.X)
		v27 = v25.Position
	end

	local v28 = viewportSize.Y / (v26 * v7) / 2 / 0.7002075382097097

	local v29 = v27 + v25.LookVector * v28
	return CFrame.lookAt(v29, v27, Vector3.new(0, 1, 0)), v28
end

fn2 = function()
	local currentCamera = workspace.CurrentCamera

	if not (flag and currentCamera) then
		return
	end

	v10, v11 = computeGoal(currentCamera)
end

local function updateLayers() -- 1 equivalent call inferred from this helper
	infoBoard:PivotTo(pivot + cframe.LookVector * total5)
end

local function ensureDofLayers(parent)
	local v25 = math.clamp(math.floor(v6 + 0.5), 1, 3)

	while #v23 < v25 do
		local infoBoardFocusDoF = Instance.new("DepthOfFieldEffect")
		infoBoardFocusDoF.Name = "InfoBoardFocusDoF"
		infoBoardFocusDoF.InFocusRadius = inFocusRadius
		infoBoardFocusDoF.NearIntensity = 0
		infoBoardFocusDoF.FarIntensity = 0
		infoBoardFocusDoF.FocusDistance = focusDistance
		infoBoardFocusDoF.Parent = parent
		table.insert(v23, infoBoardFocusDoF)
	end

	while v25 < #v23 do
		table.remove(v23):Destroy()
	end
end

local function startDof(currentCamera)
	depthOfFieldEffect = Lighting:FindFirstChildOfClass("DepthOfFieldEffect")

	if depthOfFieldEffect then
		enabled = depthOfFieldEffect.Enabled
		depthOfFieldEffect.Enabled = false
	end

	total6 = 0
	v24 = 1
	local cframe3 = currentCamera.CFrame
	focusDistance = math.max((focusPaperCFrame().Position - cframe3.Position):Dot(cframe3.LookVector), 0.5) -- inferred equivalent call
	ensureDofLayers(currentCamera)
end

local function stopDof()
	for _, v25 in ipairs(v23) do
		v25:Destroy()
	end

	v23 = {}

	if depthOfFieldEffect and enabled ~= nil then
		depthOfFieldEffect.Enabled = enabled
	end

	depthOfFieldEffect = nil
	enabled = nil
	total6 = 0
	v24 = 0
end

local function updateDof(p, currentCamera)
	if #v23 == 0 then
		return
	end

	ensureDofLayers(currentCamera)
	total6 += (v24 - total6) * (1 - math.exp(-p * 4))

	local v25 = cframe.Position + cframe.LookVector * total5
	local cframe3 = currentCamera.CFrame
	local v26 = math.max((v25 - cframe3.Position):Dot(cframe3.LookVector), 0.2)
	focusDistance += (v26 - focusDistance) * (1 - math.exp(-p * 8))

	for _, v27 in ipairs(v23) do
		v27.FocusDistance = focusDistance
		v27.InFocusRadius = inFocusRadius
		v27.NearIntensity = 0
		v27.FarIntensity = v5 * total6
	end
end

local function finalizeLayers() -- 2 equivalent calls inferred from this helper
	total5 = 0
	v22 = 0
	infoBoard:PivotTo(pivot)
	stopDof()
end

local function parallaxCurve(p) -- 2 equivalent calls inferred from this helper
	return math.sign(p) * math.abs(p) ^ 1.25
end

local function cameraStep(p)
	local currentCamera = workspace.CurrentCamera

	if not (currentCamera and v10 and cframe2) then
		return
	end

	local v25 = math.min(p, 0.1)

	refreshTunables()

	if flag then
		v22 = v4
	end

	cframe2 = cframe2:Lerp(v10, 1 - math.exp(-v25 * v20))

	total5 += (v22 - total5) * (1 - math.exp(-v25 * 6))
	updateLayers() -- inferred equivalent call
	total += ((v21 and 1 or 0) - total) * (1 - math.exp(-v25 * 3))
	local v26, v27

	if UserInputService.MouseEnabled then
		local mouseLocation = UserInputService:GetMouseLocation()
		local viewportSize = currentCamera.ViewportSize
		local v28 = math.clamp((mouseLocation.X - viewportSize.X / 2) / (viewportSize.X / 2), -1, 1)
		local v29 = math.clamp(-(mouseLocation.Y - viewportSize.Y / 2) / (viewportSize.Y / 2), -1, 1)
		v26 = parallaxCurve(v28) -- inferred equivalent call
		v27 = parallaxCurve(v29) -- inferred equivalent call
	else
		v26 = 0
		v27 = 0
	end

	local v28 = v13 and v13:IsInteractiveHovered()
		or v13 and v13:IsOpen()
		or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)

	total4 += ((v28 and 1 or 0) - total4) * (1 - math.exp(-v25 * 12))
	local v29 = (1 - math.exp(-v25 * 5)) * (1 - total4)
	total2 += (v26 - total2) * v29
	total3 += (v27 - total3) * v29

	local now = os.clock()
	local v30 = math.sin(now * 0.7) * 0.1 + math.sin(now * 1.9) * 0.1 * 0.35
	local v31 = math.cos(now * 0.55) * 0.07
	local v32 = total
	local v36 = 1 - total4 * 0.9
	local v37 = (total2 + v30 * v36) * v32
	local v38 = (total3 + v31 * v36) * v32

	local v39 = -math.rad(v) * v37
	local v40 = math.rad(v2) * v38
	local v41 = -v37 * 0.02
	local v42 = cframe2.RightVector * (v37 * v11 * v3) + cframe2.UpVector * (v38 * v11 * v3)
	currentCamera.CFrame = cframe2 * CFrame.Angles(v40, v39, v41) + v42

	updateDof(v25, currentCamera)
end

local function stopCameraStep() -- 2 equivalent calls inferred from this helper
	if flag2 then
		flag2 = false
		RunService:UnbindFromRenderStep("InfoBoardCamera")
	end
end

local function waitForCameraSettle(p)
	local lastTime = os.clock()

	while os.clock() - lastTime < p do
		RunService.RenderStepped:Wait()

		if
			cframe2
			and v10
			and (cframe2.Position - v10.Position).Magnitude < 0.02
			and total < 0.03
			and total5 < 0.01
		then
			break
		end
	end
end

local function setControlsEnabled(p) -- 2 equivalent calls inferred from this helper
	return (pcall(function()
		if not controls then
			local PlayerModule = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
			controls = PlayerModule:GetControls()
		end

		if p then
			controls:Enable()
		else
			controls:Disable()
		end
	end))
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

local function positionCloseButton()
	local v25 = v12

	if not v25 then
		return
	end

	local v26 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	v25.Text = v26 and "BACK" or "BACK  [Q]"
	v25.AnchorPoint = Vector2.new(0.5, 1)
	v25.Position = UDim2.new(0.5, 0, 1, -18)
	v25.Size = UDim2.fromOffset(v26 and 150 or 210, 46)
end

local function createFocusGui()
	if v19 then
		return v19
	end

	local infoBoardFocusUI = Instance.new("ScreenGui")
	infoBoardFocusUI.Name = "InfoBoardFocusUI"
	infoBoardFocusUI.ResetOnSpawn = false
	infoBoardFocusUI.DisplayOrder = 60
	infoBoardFocusUI.IgnoreGuiInset = false
	infoBoardFocusUI.Enabled = false
	infoBoardFocusUI.Parent = PlayerGui

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.AnchorPoint = Vector2.new(0.5, 1)
	closeButton.Position = UDim2.new(0.5, 0, 1, -18)
	closeButton.Size = UDim2.fromOffset(210, 46)
	closeButton.BackgroundColor3 = Color3.fromRGB(26, 26, 28)
	closeButton.AutoButtonColor = true
	closeButton.Font = Enum.Font.GothamBlack
	closeButton.Text = "BACK  [Q]"
	closeButton.TextSize = 20
	closeButton.TextColor3 = Color3.fromRGB(244, 232, 200)
	closeButton.Rotation = -1.5
	closeButton.Parent = infoBoardFocusUI
	v12 = closeButton

	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	require(ReplicatedStorage2.Modules:WaitForChild("BoardBackButton")).Style(closeButton)

	closeButton.MouseButton1Click:Connect(function()
		BoardSwitch.Back()
	end)

	v19 = infoBoardFocusUI
	return infoBoardFocusUI
end

local function enterFocus(data)
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
	v8 = "paper"
	v9 = nil
	count += 1
	local v25 = count
	v16 = character

	refreshTunables()

	if data then
		cameraType = data.CameraType
		v17 = data.CameraCFrame
		fieldOfView = data.FieldOfView
	else
		cameraType = currentCamera.CameraType
		v17 = currentCamera.CFrame
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

		if not flag or count ~= v25 then
			return
		end
	end

	setControlsEnabled(false) -- inferred equivalent call

	if data then
		v18 = data.PromptServiceEnabled
	else
		v18 = ProximityPromptService.Enabled
	end

	ProximityPromptService.Enabled = false

	hideAllPlayers()
	task.spawn(function()
		while flag and count == v25 do
			for _, v26 in ipairs(Players:GetPlayers()) do
				local character2 = v26.Character

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

	infoBoardSurface.Active = true

	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.FieldOfView = 70

	total5 = 0
	v22 = v4
	startDof(currentCamera)

	v10, v11 = computeGoal(currentCamera)
	cframe2 = currentCamera.CFrame
	v20 = 7.5
	v21 = false
	total = 0
	total2 = 0
	total3 = 0
	total4 = 0

	RunService:BindToRenderStep("InfoBoardCamera", Enum.RenderPriority.Camera.Value + 1, cameraStep)
	flag2 = true
	task.delay(0.45, function()
		if flag and count == v25 then
			v21 = true
		end
	end)

	viewportSizeChangedConnection = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if flag then
			fn2()
		end
	end)

	local focusGui = createFocusGui()
	focusGui.Enabled = true
	v12.Visible = true
	positionCloseButton()

	if data then
		task.delay(0.45, function()
			if flag and count == v25 then
				InfoFocus:FireServer(true)
			end
		end)
	else
		InfoFocus:FireServer(true)
	end

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

	ContextActionService:BindActionAtPriority("InfoBoardExit", function(_, p)
		if UserInputService:GetFocusedTextBox() then
			return Enum.ContextActionResult.Pass
		end

		if p == Enum.UserInputState.Begin then
			if v13 and v13:IsOpen() then
				v13:Close()
			else
				BoardSwitch.Back()
			end
		end

		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.Q, Enum.KeyCode.Backspace, Enum.KeyCode.ButtonB)

	diedConnection = humanoid.Died:Connect(function()
		fn()
	end)

	BoardSwitch.SetCurrent("Info")
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

	ContextActionService:UnbindAction("InfoBoardExit")

	InfoFocus:FireServer(false)

	if v13 then
		v13:Close(true)
		v13:ResetHover()
	end

	v8 = "paper"
	v9 = nil

	infoBoardSurface.Active = false

	if v19 then
		v19.Enabled = false
	end

	if p then
		stopCameraStep() -- inferred equivalent call
		finalizeLayers() -- inferred equivalent call
		stopWatchingPlayers()
		restoreAllHidden()
		local v25 = {
			CameraType = cameraType,
			CameraCFrame = v17,
			FieldOfView = fieldOfView,
			PromptServiceEnabled = v18,
			MenuFlag = menuFlag
		}

		menuFlag = false
		v17 = nil
		v16 = nil
		BoardSwitch.ClearCurrent("Info")
		return v25
	else
		local currentCamera = workspace.CurrentCamera
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local v25

		if currentCamera == nil or v17 == nil or character ~= v16 or humanoid == nil or not (humanoid.Health > 0) then
			v25 = false
		else
			v25 = humanoidRootPart ~= nil
		end

		v22 = 0
		v24 = 0
		v21 = false

		stopWatchingPlayers()
		restoreAllHidden()

		if v25 then
			v10 = v17
			v20 = 9
			waitForCameraSettle(0.9)
		end

		stopCameraStep() -- inferred equivalent call
		finalizeLayers() -- inferred equivalent call
		stopWatchingPlayers()
		restoreAllHidden()
		ProximityPromptService.Enabled = v18
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default

		if currentCamera then
			local cameraType2 = cameraType or Enum.CameraType.Custom

			if cameraType2 == Enum.CameraType.Scriptable then
				cameraType2 = Enum.CameraType.Custom
			end

			if v25 then
				currentCamera.CFrame = v17
				local v26 = math.clamp((v17.Position - humanoidRootPart.Position).Magnitude, 0.5, 20)
				LocalPlayer.CameraMinZoomDistance = v26
				LocalPlayer.CameraMaxZoomDistance = v26
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
		v17 = nil
		v16 = nil
		BoardSwitch.ClearCurrent("Info")
	end
end

LocalPlayer.CharacterAdded:Connect(function()
	if flag then
		task.spawn(fn)
	end
end)

BoardSwitch.Register("Info", {
	Part = paper,
	ExitForHandoff = function()
		return fn(true)
	end,
	EnterWithHandoff = function(p)
		enterFocus(p)
	end,
	Exit = function()
		fn()
	end
})

task.spawn(function()
	local switchClick = paper:WaitForChild("SwitchClick", 15)

	if switchClick then
		switchClick.MouseClick:Connect(function(p)
			if p == LocalPlayer then
				BoardSwitch.Request("Info")
			end
		end)
	end
end)