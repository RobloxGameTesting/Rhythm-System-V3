local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer

local v = {}

local f4 = Enum.KeyCode.F4
local f3 = Enum.KeyCode.F3
local f2 = Enum.KeyCode.F2
local PageDown = Enum.KeyCode.PageDown
local PageUp = Enum.KeyCode.PageUp

local _ = {
	LaneCount = 5,
	Score = 248760,
	Combo = 247,
	FrozenTime = 100,
	PulseEvery = 0.4,
	StarPower = false,
	HideSelf = false,
	Cinematic = true,
	DepthOfField = true,
	DofFarIntensity = 0.9,
	DofNearIntensity = 0.35,
	DemoLights = true,
	HideCursor = true
}

local v2 = {
	{
		name = "Hero kanan",
		dist = 10.5,
		side = -3.2,
		height = -0.6,
		aimUp = 0.6,
		aimShift = 2.8,
		fov = 52,
		dofRadius = 5
	},
	{
		name = "Hero kiri",
		dist = 10.5,
		side = 3.2,
		height = -0.6,
		aimUp = 0.6,
		aimShift = -2.8,
		fov = 52,
		dofRadius = 5
	},
	{
		name = "Tengah rendah",
		dist = 12,
		side = 0,
		height = -1.2,
		aimUp = 0.9,
		aimShift = 0,
		fov = 58,
		dofRadius = 5
	},
	{
		name = "Samping dramatis",
		dist = 8,
		side = -8.5,
		height = -0.2,
		aimUp = 0.5,
		aimShift = 1.2,
		fov = 48,
		dofRadius = 3.5
	},
	{
		name = "Wide panggung",
		dist = 21,
		side = -2,
		height = 1.6,
		aimUp = 1.6,
		aimShift = 0,
		fov = 62,
		dofRadius = 9
	}
}

local v3 = {
	ThumbnailModeUI = true,
	NoteLaneUI = true,
	NoteLaneUI3D = true,
	NoteLaneUI3DInput = true,
	StarPowerUI = true,
	StarPowerReadyGui = true,
	MeterContainer = true,
	RockMeterUI = true,
	ScoreDisplayUI = true,
	BandScoreUI = true,
	StreakNoticeGui = true,
	StreakNoticeGui3D = true,
	RhythmVibratoHUD = true,
	BandCameraFX = true
}

local v4 = { "judg", "streak", "notice" }

local function isDeveloper(): boolean
	if RunService:IsStudio() or game.CreatorType == Enum.CreatorType.User and game.CreatorId == LocalPlayer.UserId then
		return true
	end

	return table.find(v, LocalPlayer.UserId) ~= nil
end

if
	not RunService:IsStudio()
	and (game.CreatorType ~= Enum.CreatorType.User or game.CreatorId ~= LocalPlayer.UserId)
	and table.find(v, LocalPlayer.UserId) == nil
then
	return
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local thumbnailScene = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ThumbnailScene", 20)

if not thumbnailScene then
	warn("[ThumbnailMode] RemoteEvent ThumbnailScene tidak ada (ThumbnailSceneServer belum jalan?)")
	return
end

local ThemeState = require(Modules:WaitForChild("ThemeState"))
local SettingsState = require(Modules:WaitForChild("SettingsState"))
local NoteLaneUI = require(Modules:WaitForChild("NoteLaneUI"))
local NoteLaneUI3D = require(Modules:WaitForChild("NoteLaneUI3D"))
local StarPowerUI = require(Modules:WaitForChild("StarPowerUI"))
local RhythmEngineConfig = require(Modules:WaitForChild("RhythmEngineConfig"))

local function tryRequire(childName) -- 3 equivalent calls inferred from this helper
	local child = Modules:FindFirstChild(childName)

	if not child then
		return nil
	end

	local success, result = pcall(require, child)
	return success and result or nil
end

local color = Color3.fromRGB(22, 22, 26)
Color3.fromRGB(245, 245, 247)
local color2 = Color3.fromRGB(204, 162, 72)

local function make(className, items, parent) -- 6 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local v5 = false
local flag = false
local v6 = nil
local v7 = nil
local v8 = false
local v9 = false
local v10 = 1

local v11 = {}
local childAddedConnection = nil
local v12 = {}
local v13 = nil
local enabled = nil
local enabledsByInstance = {}
local displayDistanceTypesByInstance = {}
local descendantAddedConnection = nil
local v14 = {}
local v15 = {}
local v16 = nil
local enabledsByDepthOfFieldEffect = {}
local mouseIconEnabled = nil
local v17 = nil

local function hideGui(screenGui)
	if not screenGui:IsA("ScreenGui") or v3[screenGui.Name] or v11[screenGui] then
		return
	end

	local v18 = { was = screenGui.Enabled }
	v11[screenGui] = v18
	v18.conn = screenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if flag and screenGui.Enabled then
			v18.was = true
			screenGui.Enabled = false
		end
	end)
	screenGui.Enabled = false
end

local function restoreGuis()
	if childAddedConnection then
		childAddedConnection:Disconnect()
		childAddedConnection = nil
	end

	for k, v18 in pairs(v11) do
		if v18.conn then
			v18.conn:Disconnect()
		end

		if k.Parent then
			k.Enabled = v18.was
		end
	end

	table.clear(v11)
end

local function startHideGuis()
	for _, child in ipairs(PlayerGui:GetChildren()) do
		hideGui(child)
	end

	childAddedConnection = PlayerGui.ChildAdded:Connect(function(child)
		task.defer(function()
			if flag then
				hideGui(child)
			end
		end)
	end)
end

local function hideCore()
	for _, v18 in ipairs({ "PlayerList", "Chat", "Backpack", "Health", "EmotesMenu", "SelfView" }) do
		local success, result = pcall(function()
			return Enum.CoreGuiType[v18]
		end)

		if not (success and result) then
			continue
		end

		local success2, result2 = pcall(function()
			return StarterGui:GetCoreGuiEnabled(result)
		end)

		if not success2 then
			continue
		end

		v12[result] = result2
		pcall(function()
			StarterGui:SetCoreGuiEnabled(result, false)
		end)
	end

	local success, result = pcall(function()
		return StarterGui:GetCore("TopbarEnabled")
	end)

	v13 = not success or result == nil or not result or result
	pcall(function()
		StarterGui:SetCore("TopbarEnabled", false)
	end)
	enabled = ProximityPromptService.Enabled
	ProximityPromptService.Enabled = false
end

local function restoreCore()
	for k, v18 in pairs(v12) do
		pcall(function()
			StarterGui:SetCoreGuiEnabled(k, v18)
		end)
	end

	table.clear(v12)

	if v13 ~= nil then
		pcall(function()
			StarterGui:SetCore("TopbarEnabled", v13)
		end)
		v13 = nil
	end

	if enabled ~= nil then
		ProximityPromptService.Enabled = enabled
		enabled = nil
	end
end

local function keepBillboard(name): boolean
	local v18 = string.lower(name)

	for _, v19 in ipairs(v4) do
		if string.find(v18, v19, 1, true) then
			return true
		end
	end

	return false
end

local function relevantForOverhead(instance): boolean -- 1 equivalent call inferred from this helper
	if v6 and instance:IsDescendantOf(v6) then
		return true
	end

	local model = instance:FindFirstAncestorOfClass("Model")
	return model ~= nil and model:FindFirstChildOfClass("Humanoid") ~= nil
end

local function considerOverhead(descendant)
	if descendant:IsA("BillboardGui") then
		if
			enabledsByInstance[descendant] == nil
			and not keepBillboard(descendant.Name)
			and relevantForOverhead(descendant) -- inferred equivalent call
		then
			enabledsByInstance[descendant] = descendant.Enabled
			descendant.Enabled = false
		end
	elseif descendant:IsA("Humanoid") and displayDistanceTypesByInstance[descendant] == nil then
		displayDistanceTypesByInstance[descendant] = descendant.DisplayDistanceType
		descendant.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end
end

local function startHideOverhead()
	local v18 = {}

	if v6 then
		table.insert(v18, v6)
	end

	for _, v19 in ipairs(Players:GetPlayers()) do
		if v19.Character then
			table.insert(v18, v19.Character)
		end
	end

	for _, folder in ipairs(v18) do
		for _, descendant in ipairs(folder:GetDescendants()) do
			considerOverhead(descendant)
		end
	end

	descendantAddedConnection = workspace.DescendantAdded:Connect(function(instance)
		if flag and (instance:IsA("BillboardGui") or instance:IsA("Humanoid")) then
			task.defer(considerOverhead, instance)
		end
	end)
end

local function restoreOverhead()
	if descendantAddedConnection then
		descendantAddedConnection:Disconnect()
		descendantAddedConnection = nil
	end

	for k, enabled2 in pairs(enabledsByInstance) do
		if k.Parent then
			k.Enabled = enabled2
		end
	end

	table.clear(enabledsByInstance)

	for k, displayDistanceType in pairs(displayDistanceTypesByInstance) do
		if k.Parent then
			k.DisplayDistanceType = displayDistanceType
		end
	end

	table.clear(displayDistanceTypesByInstance)
end

local function setCharHidden(folder, p) -- 3 equivalent calls inferred from this helper
	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = p and 1 or 0
		end
	end
end

local function restoreChars()
	for k in pairs(v14) do
		if k.Parent then
			setCharHidden(k, false) -- inferred equivalent call
		end
	end

	table.clear(v14)
end

local function startFx()
	for _, depthOfFieldEffect in ipairs(Lighting:GetChildren()) do
		if not depthOfFieldEffect:IsA("DepthOfFieldEffect") then
			continue
		end

		enabledsByDepthOfFieldEffect[depthOfFieldEffect] = depthOfFieldEffect.Enabled
		depthOfFieldEffect.Enabled = false
	end

	v16 = make("DepthOfFieldEffect", { -- inferred equivalent call
		Name = "ThumbFX_DepthOfField",
		FocusDistance = 12,
		InFocusRadius = 5,
		NearIntensity = 0.35,
		FarIntensity = 0.9
	}, Lighting)

	table.insert(v15, v16)

	table.insert(v15, make("ColorCorrectionEffect", { -- inferred equivalent call
		Name = "ThumbFX_ColorCorrection",
		Brightness = 0.02,
		Contrast = 0.12,
		Saturation = 0.18,
		TintColor = Color3.fromRGB(255, 246, 238)
	}, Lighting))

	table.insert(
		v15,
		make("BloomEffect", { Name = "ThumbFX_Bloom", Intensity = 0.35, Size = 28, Threshold = 1.6 }, Lighting) -- inferred equivalent call
	)
end

local function stopFx()
	for _, v18 in ipairs(v15) do
		v18:Destroy()
	end

	table.clear(v15)
	v16 = nil

	for k, enabled2 in pairs(enabledsByDepthOfFieldEffect) do
		if k.Parent then
			k.Enabled = enabled2
		end
	end

	table.clear(enabledsByDepthOfFieldEffect)
end

local function cameraStep()
	local character = LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local currentCamera = workspace.CurrentCamera

	if not (humanoidRootPart and currentCamera) then
		return
	end

	local v18 = v2[v10]
	local cframe = humanoidRootPart.CFrame
	local position = cframe.Position
	local vector3 = Vector3.new(cframe.LookVector.X, 0, cframe.LookVector.Z)
	local unit = vector3.Magnitude > 0.01 and vector3.Unit or Vector3.new(0, 0, -1)
	local cross = unit:Cross(Vector3.new(0, 1, 0))
	local v19 = position + unit * v18.dist + cross * v18.side + Vector3.new(0, 1, 0) * v18.height
	local v20 = position + Vector3.new(0, 1, 0) * v18.aimUp + cross * v18.aimShift
	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.CFrame = CFrame.lookAt(v19, v20)
	currentCamera.FieldOfView = v18.fov

	if v16 and v16.Parent then
		v16.FocusDistance = (v19 - (position + Vector3.new(0, 1.2, 0))).Magnitude
		v16.InFocusRadius = v18.dofRadius or 5
	end
end

local function startCamera() -- 1 equivalent call inferred from this helper
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		v17 = {
			Type = currentCamera.CameraType,
			Subject = currentCamera.CameraSubject,
			Fov = currentCamera.FieldOfView
		}
	end
end

local function stopCamera()
	local currentCamera = workspace.CurrentCamera

	if currentCamera and v17 then
		currentCamera.CameraType = v17.Type == Enum.CameraType.Scriptable and Enum.CameraType.Custom or v17.Type
		currentCamera.CameraSubject = LocalPlayer.Character
			and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			or v17.Subject
		currentCamera.FieldOfView = v17.Fov
	end

	v17 = nil
end

local v18 = {
	Name = "ThumbnailModeUI",
	ResetOnSpawn = false,
	DisplayOrder = 1000,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}
local screenGui = Instance.new("ScreenGui")
local count = 0
local v19 = {}
local v20 = nil
local v21 = nil
local v22 = {}
local total = 0
local v23 = false
local lastTime = 0
local v24 = nil

for k, v25 in pairs(v18) do
	screenGui[k] = v25
end

screenGui.Parent = PlayerGui

local bindableEvent = make("BindableEvent", { Name = "ThumbnailRequest" }, ReplicatedStorage) -- inferred equivalent call

local function setStatus(thumbnailStatus) -- 6 equivalent calls inferred from this helper
	LocalPlayer:SetAttribute("ThumbnailStatus", thumbnailStatus)
end

setStatus("Idle") -- inferred equivalent call
LocalPlayer:SetAttribute("ThumbnailDeveloper", true)

local textLabel = make("TextLabel", { -- inferred equivalent call
	Name = "Toast",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 22),
	Size = UDim2.fromOffset(460, 28),
	BackgroundColor3 = color,
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
	Text = "",
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	TextColor3 = color2,
	Visible = false
}, screenGui)

make("UICorner", { CornerRadius = UDim.new(0, 8) }, textLabel) -- inferred equivalent call

local count2 = 0
local function showToast(text, value) -- 7 equivalent calls inferred from this helper
	count2 += 1
	local v25 = count2
	textLabel.Text = text
	textLabel.TextTransparency = 0
	textLabel.BackgroundTransparency = 0.2
	textLabel.Visible = true
	task.delay(value or 2, function()
		if v25 ~= count2 then
			return
		end

		TweenService:Create(textLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 1,
			BackgroundTransparency = 1
		}):Play()
		task.delay(0.55, function()
			if v25 == count2 then
				textLabel.Visible = false
			end
		end)
	end)
end

local function pickRenderer() -- 1 equivalent call inferred from this helper
	return if ThemeState.Get() == "3D" then NoteLaneUI3D else NoteLaneUI
end

local function buildNotes()
	local notes = {}
	local function add(p, lane, value) -- 11 equivalent calls inferred from this helper
		table.insert(notes, {
			Time = 100 + p,
			Lane = lane,
			Duration = value or 0
		})
	end

	add(0, 1) -- inferred equivalent call
	add(0, 3) -- inferred equivalent call
	add(0, 5) -- inferred equivalent call

	for i, v25 in ipairs({
		2,
		4,
		1,
		5,
		2,
		4,
		1,
		5,
		2,
		4,
		1,
		5
	}) do
		add(0.22 * i, v25) -- inferred equivalent call
	end

	add(0.55, 3, 0.85) -- inferred equivalent call
	add(1.1, 1) -- inferred equivalent call
	add(1.1, 5) -- inferred equivalent call
	add(1.65, 2) -- inferred equivalent call
	add(1.65, 4) -- inferred equivalent call
	add(2, 1, 0.6) -- inferred equivalent call
	add(2.3, 5) -- inferred equivalent call
	table.sort(notes, function(a, b): boolean
		return a.Time < b.Time
	end)

	return notes
end

local function showHighway()
	v7 = pickRenderer() -- inferred equivalent call
	local keybindFiveKey = SettingsState.GetKeybindFiveKey()
	v7.Show("GuitarLead", 5, keybindFiveKey, nil, nil)

	local v25 = v7.GetTrackWidth and v7.GetTrackWidth(5) or nil
	local v26 = v7.GetTrackHeight and v7.GetTrackHeight() or nil
	local v27 = v7.GetTrackRightEdgeX and v7.GetTrackRightEdgeX() or nil
	local v28 = v7.GetTrackCenterY and v7.GetTrackCenterY() or nil
	StarPowerUI.Show(v25, v26, RhythmEngineConfig.StarPowerThresholds, v27, v28)
	task.defer(function()
		if not (flag and v7) then
			return
		end

		local v29 = v7.GetTrackRightEdgeX and v7.GetTrackRightEdgeX() or nil
		local v30 = v7.GetTrackCenterY and v7.GetTrackCenterY() or nil

		if v29 and v29 > 0 or v30 and v30 > 0 then
			StarPowerUI.Show(v25, v26, RhythmEngineConfig.StarPowerThresholds, v29, v30)
		end
	end)

	if v7.SetScoreState then
		v7.SetScoreState(248760, 247)
	end
end

local function applyStar(p) -- 2 equivalent calls inferred from this helper
	v8 = p
	pcall(function()
		if v7 and v7.SetStarPowerVisual then
			v7.SetStarPowerVisual(p)
		end

		if v7 and v7.SetStarPowerAtmosphere then
			v7.SetStarPowerAtmosphere(p)
		end

		if not p then
			StarPowerUI.SetMeter(0.82, 0.9)

			return
		end

		StarPowerUI.PlayActivationEffect(3)
		StarPowerUI.SetActiveResource(0.88)
	end)
end

local v25 = {
	{ 1, 3, 5 },
	{ 2, 4 },
	{ 1, 2, 3, 4, 5 },
	{ 3 },
	{ 2, 3, 4 },
	{ 1, 5 }
}

local function pulse()
	count += 1

	if v7.SetScoreState then
		v7.SetScoreState(248760, 247)
	end

	local v26 = v25[count % #v25 + 1]
	local set = {}

	for _, v27 in ipairs(v26) do
		set[v27] = true
	end

	for k in pairs(v19) do
		if set[k] then
			continue
		end

		v7.SetLanePressed(k, false)
		v19[k] = nil
	end

	for _, v27 in ipairs(v26) do
		v7.SetLanePressed(v27, true)
		v19[v27] = true

		v7.ShowJudgment(v27, "Perfect", false, 247, true)
	end

	if v20 then
		v20.OnJudgment("Perfect", false)
	end

	if v21 and count % 2 == 0 and LocalPlayer.Character then
		v21.Spawn(LocalPlayer.Character, "Perfect")
	end
end

local function onRenderStep(p)
	if not flag then
		return
	end

	cameraStep()

	local character = LocalPlayer.Character

	if v9 and character then
		v14[character] = true
		setCharHidden(character, true) -- inferred equivalent call
	elseif character and v14[character] then
		setCharHidden(character, false) -- inferred equivalent call
		v14[character] = nil
	end

	if v7 then
		if not v7.IsVisible() then
			showHighway()
			applyStar(v8) -- inferred equivalent call
		end

		local success, result = pcall(function()
			v7.SyncNotes(v22, 100)
			total += p

			if total >= 0.4 then
				total = 0
				pulse()
			end
		end)

		if not (success or v23) then
			v23 = true
			warn("[ThumbnailMode] highway beku error:", result)
		end
	end

	if os.clock() - lastTime > 0.5 then
		lastTime = os.clock()

		for k in pairs(enabledsByInstance) do
			if k.Parent and k.Enabled then
				k.Enabled = false
			end
		end

		if enabled ~= nil and ProximityPromptService.Enabled then
			ProximityPromptService.Enabled = false
		end
	end
end

local function stopScene()
	RunService:UnbindFromRenderStep("ThumbnailModeStep")

	if v7 then
		pcall(function()
			for k in pairs(v19) do
				v7.SetLanePressed(k, false)
			end

			if v8 then
				if v7.SetStarPowerVisual then
					v7.SetStarPowerVisual(false)
				end

				if v7.SetStarPowerAtmosphere then
					v7.SetStarPowerAtmosphere(false)
				end
			end

			if v7.SetScoreState then
				v7.SetScoreState(0, 0)
			end

			StarPowerUI.Hide()
			v7.Hide()
		end)
	end

	if v20 then
		pcall(v20.Reset)
	end

	v7 = nil
	table.clear(v19)
	v8 = false

	if v24 and v6 then
		pcall(function()
			v24.SetDemo(v6, false)
		end)
	end

	restoreGuis()
	restoreCore()
	restoreOverhead()
	restoreChars()
	stopFx()
	stopCamera()

	if mouseIconEnabled ~= nil then
		UserInputService.MouseIconEnabled = mouseIconEnabled
		mouseIconEnabled = nil
	end

	v6 = nil
end

local function exitScene(p) -- 2 equivalent calls inferred from this helper
	if not flag then
		return
	end

	flag = false
	stopScene()
	thumbnailScene:FireServer("Exit")
	setStatus("Idle") -- inferred equivalent call

	if not p then
		showToast("Thumbnail mode OFF", 1.5) -- inferred equivalent call
	end
end

local function startScene(_, p)
	v6 = p
	flag = true
	v23 = false
	total = 0.4
	count = 0
	v9 = false
	v10 = 1
	v22 = buildNotes()
	setStatus("Active") -- inferred equivalent call
	startCamera() -- inferred equivalent call
	startHideGuis()
	hideCore()
	startHideOverhead()

	startFx()

	mouseIconEnabled = UserInputService.MouseIconEnabled
	UserInputService.MouseIconEnabled = false
	v20 = tryRequire("RockMeterUI") -- inferred equivalent call
	v21 = tryRequire("FloatingJudgmentPool") -- inferred equivalent call
	v24 = tryRequire("StageLightingController") -- inferred equivalent call

	if v24 and v6 then
		pcall(function()
			v24.SetDemo(v6, true)
		end)
	end

	showHighway()
	v8 = false
	local v26 = false
	pcall(function()
		if v7 and v7.SetStarPowerVisual then
			v7.SetStarPowerVisual(v26)
		end

		if v7 and v7.SetStarPowerAtmosphere then
			v7.SetStarPowerAtmosphere(v26)
		end

		if not v26 then
			StarPowerUI.SetMeter(0.82, 0.9)

			return
		end

		StarPowerUI.PlayActivationEffect(3)
		StarPowerUI.SetActiveResource(0.88)
	end)

	RunService:BindToRenderStep("ThumbnailModeStep", Enum.RenderPriority.Last.Value, onRenderStep)
	showToast("SIAP SCREENSHOT  -  F4 keluar  |  PageUp/Dn kamera  |  F3 star power  |  F2 karakter", 3.5) -- inferred equivalent call
end

local function requestScene()
	if v5 or flag then
		return
	end

	if NoteLaneUI.IsVisible() or NoteLaneUI3D.IsVisible() then
		showToast("Highway sedang dipakai (lagu berjalan). Selesaikan / keluar dulu.", 3) -- inferred equivalent call
	else
		v5 = true
		setStatus("Busy") -- inferred equivalent call
		thumbnailScene:FireServer("Enter")

		task.delay(8, function()
			if v5 and not flag then
				v5 = false
				setStatus("Idle") -- inferred equivalent call
				showToast("Server tidak merespons. Coba lagi.", 3) -- inferred equivalent call
			end
		end)
	end
end

thumbnailScene.OnClientEvent:Connect(function(p, value, p2)
	if p == "Ready" then
		if not v5 then
			return
		end

		v5 = false

		local character = LocalPlayer.Character
		local lastTime2 = os.clock()

		while character and not character:FindFirstChild("GuitarLead_Held") and os.clock() - lastTime2 < 3 do
			task.wait(0.1)
		end

		startScene(value, p2)
	elseif p == "Fail" then
		v5 = false
		setStatus("Idle") -- inferred equivalent call
		showToast(tostring(value or "Gagal menyiapkan adegan."), 4) -- inferred equivalent call
	end
end)

bindableEvent.Event:Connect(requestScene)

UserInputService.InputBegan:Connect(function(input)
	if not flag or UserInputService:GetFocusedTextBox() then
		return
	end

	local keyCode = input.KeyCode

	if keyCode == f4 then
		exitScene(false) -- inferred equivalent call
	elseif keyCode == f3 then
		applyStar(not v8) -- inferred equivalent call
	elseif keyCode == f2 then
		v9 = not v9
	elseif keyCode == PageUp then
		v10 = v10 % #v2 + 1
		showToast("Kamera: " .. v2[v10].name, 1.2) -- inferred equivalent call
	elseif keyCode == PageDown then
		v10 = (v10 - 2) % #v2 + 1
		showToast("Kamera: " .. v2[v10].name, 1.2) -- inferred equivalent call
	end
end)

local function watchCharacter(instance)
	local humanoid = instance:WaitForChild("Humanoid", 10)

	if humanoid then
		humanoid.Died:Connect(function()
			if flag then
				exitScene(true) -- inferred equivalent call
			end
		end)
	end
end

if LocalPlayer.Character then
	task.spawn(watchCharacter, LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(watchCharacter)