local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local HeadTrackingConfig = require(ReplicatedStorage.Modules.HeadTrackingSystem.HeadTrackingConfig)
local SessionCameraSettings = require(ReplicatedStorage.Modules.SessionCameraSettings)
local ModeManager = require(ReplicatedStorage.Modules.ModeManager)

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local InstrumentHUDUpdate = RemoteEvents:WaitForChild("InstrumentHUDUpdate")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local v2 = nil
InstrumentHUDUpdate.OnClientEvent:Connect(function(p, p2)
	v2 = p and p2 or nil
end)

LocalPlayer.CameraMinZoomDistance = 0.5

local folder = nil
local humanoid = nil
local head = nil
local flag = false
local position = nil
local v3 = false
local v4 = Vector3.new(0, 0, 0)

local cframe = CFrame.new()

local v5 = {
	HiHat = { yaw = 22, pitch = -3 },
	Snare = { yaw = 20, pitch = -8 }
}

local atsByType = {}
local v6 = 0
local v7 = 0
local v8 = 0
local v9 = 0
local v10 = 0
local v11 = 0

local v12 = 12.5
local v13 = false

local v14 = nil

local fn

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		if SessionCameraSettings.GetIsMenuOpen() or SessionCameraSettings.GetIsScrollBlocked() then
			return
		end

		local v15 = v12 > 3
		v12 -= input.Position.Z * 2
		v12 = math.clamp(v12, 0.5, 20)

		local v16 = v12 <= 3

		if v15 and v16 and not flag then
			fn(function()
				v12 = 0.5

				LocalPlayer.CameraMinZoomDistance = 0.5
				LocalPlayer.CameraMaxZoomDistance = 0.5
				task.delay(0.35, function()
					LocalPlayer.CameraMinZoomDistance = 0.5
					LocalPlayer.CameraMaxZoomDistance = 20
				end)
			end)
		end
	end
end)

RunService:BindToRenderStep("FirstPersonMenuZoomLock", Enum.RenderPriority.First.Value, function()
	local v15 = SessionCameraSettings.GetIsMenuOpen() or SessionCameraSettings.GetIsScrollBlocked()

	if v15 and not v13 then
		local v16 = math.clamp((CurrentCamera.CFrame.Position - CurrentCamera.Focus.Position).Magnitude, 0.5, 20)
		LocalPlayer.CameraMinZoomDistance = v16
		LocalPlayer.CameraMaxZoomDistance = v16
	elseif not v15 and v13 then
		task.delay(0.35, function()
			LocalPlayer.CameraMinZoomDistance = 0.5
			LocalPlayer.CameraMaxZoomDistance = 20

			local character = LocalPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				v12 = math.clamp((CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude, 0.5, 20)

				if v12 <= HeadTrackingConfig.FIRST_PERSON_DISTANCE then
					v14()
				end
			end
		end)
	end

	v13 = v15
end)

local function setAccessoriesTransparency(p)
	if not folder then
		return
	end

	for _, child in ipairs(folder:GetChildren()) do
		if not (child:IsA("Accessory") or child:IsA("Hat")) then
			continue
		end

		for _, descendant in ipairs(child:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.LocalTransparencyModifier = p
			elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
				descendant.Transparency = p
			end
		end
	end
end

local function keepBodyVisible()
	if not folder then
		return
	end

	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "Head" and part.Name ~= "HumanoidRootPart" then
			part.LocalTransparencyModifier = 0
		end
	end
end

local function isSeated(): boolean -- 5 equivalent calls inferred from this helper
	return humanoid ~= nil and humanoid:GetState() == Enum.HumanoidStateType.Seated
end

local function enterFirstPersonImpl()
	flag = true

	SessionCameraSettings.SetIsFirstPerson(true)

	if head then
		head.LocalTransparencyModifier = 1
	end

	setAccessoriesTransparency(1)
	CurrentCamera.FieldOfView = SessionCameraSettings.GetFirstPersonFOV()
end
v14 = enterFirstPersonImpl

local function exitFirstPerson() -- 2 equivalent calls inferred from this helper
	flag = false
	SessionCameraSettings.SetIsFirstPerson(false)

	if head then
		head.LocalTransparencyModifier = 0
	end

	setAccessoriesTransparency(0)
	CurrentCamera.FieldOfView = HeadTrackingConfig.DEFAULT_FOV

	if humanoid then
		humanoid.CameraOffset = Vector3.new(0, 0, 0)
	end
end

local function onCharacterAdded(character)
	folder = character
	humanoid = character:WaitForChild("Humanoid")
	head = character:WaitForChild("Head")
	flag = false
	SessionCameraSettings.SetIsFirstPerson(false)
	position = nil
	v4 = Vector3.new(0, 0, 0)

	task.defer(function()
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local upperTorso = character:FindFirstChild("UpperTorso")

		if humanoidRootPart and upperTorso then
			position = humanoidRootPart.CFrame:ToObjectSpace(upperTorso.CFrame).Position
		end
	end)
end

local function onCharacterRemoving()
	folder = nil
	humanoid = nil
	head = nil
	position = nil
end

if LocalPlayer.Character then
	onCharacterAdded(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
LocalPlayer.CharacterRemoving:Connect(onCharacterRemoving)

local v15 = false
RemoteEvents:WaitForChild("SongSessionStatusUpdate").OnClientEvent:Connect(function(p)
	v15 = p
end)

local cameraBlinkEffect = Instance.new("ScreenGui")
cameraBlinkEffect.Name = "CameraBlinkEffect"
cameraBlinkEffect.ResetOnSpawn = false
cameraBlinkEffect.IgnoreGuiInset = true
cameraBlinkEffect.DisplayOrder = 100
cameraBlinkEffect.Parent = LocalPlayer:WaitForChild("PlayerGui")

local topLid = Instance.new("Frame")
topLid.Name = "TopLid"
topLid.AnchorPoint = Vector2.new(0, 0)
topLid.Position = UDim2.new(0, 0, 0, 0)
topLid.Size = UDim2.new(1, 0, 0, 0)
topLid.BackgroundColor3 = Color3.new(0, 0, 0)
topLid.BorderSizePixel = 0
topLid.ZIndex = 10
topLid.Parent = cameraBlinkEffect

local bottomLid = Instance.new("Frame")
bottomLid.Name = "BottomLid"
bottomLid.AnchorPoint = Vector2.new(0, 1)
bottomLid.Position = UDim2.new(0, 0, 1, 0)
bottomLid.Size = UDim2.new(1, 0, 0, 0)
bottomLid.BackgroundColor3 = Color3.new(0, 0, 0)
bottomLid.BorderSizePixel = 0
bottomLid.ZIndex = 10
bottomLid.Parent = cameraBlinkEffect

local count = 0

local v16 = 0
local renderSteppedConnection = nil

local function updateToggleShake()
	if v16 <= 0.001 then
		if not flag and humanoid then
			humanoid.CameraOffset = Vector3.new(0, 0, 0)
		end

		SessionCameraSettings.SetDrumCameraShakeOffset(Vector3.new(0, 0, 0))

		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end

		v16 = 0
	else
		local vector3 = Vector3.new((math.random() - 0.5) * v16, (math.random() - 0.5) * v16, 0)

		if not flag and humanoid then
			humanoid.CameraOffset = vector3
		end

		SessionCameraSettings.SetDrumCameraShakeOffset(vector3)

		v16 *= 0.82
	end
end

local function triggerToggleShake() -- 1 equivalent call inferred from this helper
	v16 = 0.12

	if not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(updateToggleShake)
	end
end

fn = function(fn2)
	count += 1
	local v17 = count

	local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	local tweenInfo2 = TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	local tween = TweenService:Create(topLid, tweenInfo, { Size = UDim2.new(1, 0, 0.52, 0) })
	TweenService:Create(bottomLid, tweenInfo, { Size = UDim2.new(1, 0, 0.52, 0) }):Play()
	tween:Play()

	tween.Completed:Connect(function(p)
		if v17 ~= count or p ~= Enum.PlaybackState.Completed then
			return
		end

		if fn2 then
			fn2()
		end

		triggerToggleShake() -- inferred equivalent call
		task.delay(0.05, function()
			if v17 ~= count then
				return
			end

			TweenService:Create(topLid, tweenInfo2, { Size = UDim2.new(1, 0, 0, 0) }):Play()
			TweenService:Create(bottomLid, tweenInfo2, { Size = UDim2.new(1, 0, 0, 0) }):Play()
		end)
	end)
end

local v17 = 0
local flag2 = false

local function alignHoldStep()
	if head then
		local now = os.clock()

		if not (v17 <= now) then
			CurrentCamera.CFrame = CFrame.new(
				CurrentCamera.CFrame.Position,
				CurrentCamera.CFrame.Position + head.CFrame.LookVector
			)
			return
		end
	end

	RunService:UnbindFromRenderStep("FirstPersonAlignHold")
	flag2 = false
end

local function holdCameraAlignedBrieflyImpl()
	if not head then
		return
	end

	v17 = os.clock() + 0.25

	if flag2 then
		return
	end

	flag2 = true
	RunService:BindToRenderStep("FirstPersonAlignHold", Enum.RenderPriority.Character.Value + 9, alignHoldStep)
end

local function fn2(value)
	local v18 = not flag
	fn(function()
		local v19 = math.clamp(value or 6, 0.5, 20)
		local v20 = flag and v19 or 0.5
		v12 = v20

		if v18 then
			holdCameraAlignedBrieflyImpl()
		end

		LocalPlayer.CameraMinZoomDistance = v20
		LocalPlayer.CameraMaxZoomDistance = v20

		task.delay(0.35, function()
			if SessionCameraSettings.GetIsMenuOpen() or SessionCameraSettings.GetIsScrollBlocked() then
				return
			end

			LocalPlayer.CameraMinZoomDistance = 0.5
			LocalPlayer.CameraMaxZoomDistance = 20
		end)
	end)
end

local function requestManualFPPToggle() -- 1 equivalent call inferred from this helper
	if v15 or ModeManager.IsFreePlay() or SessionCameraSettings.GetIsMenuOpen() then
		return
	end

	fn2()
end

SessionCameraSettings.SetFPPToggleHandler(function()
	if SessionCameraSettings.GetIsMenuOpen() then
		return
	end

	fn2(14)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or input.KeyCode ~= Enum.KeyCode.V then
		return
	end

	requestManualFPPToggle() -- inferred equivalent call
end)

local color = Color3.fromRGB(23, 23, 27)
local color2 = Color3.fromRGB(245, 245, 247)
local color3 = Color3.fromRGB(60, 60, 70)

local function getTopbarInsetHeight()
	local success, result = pcall(function()
		return GuiService:GetGuiInset()
	end)

	local v18 = not (success and result) and 0 or result.Y

	return v18 <= 0 and 36 or v18
end

local function computeFppButtonX(): number
	return -168
end

local fppToggleTopbarUI = Instance.new("ScreenGui")
fppToggleTopbarUI.Name = "FPPToggleTopbarUI"
fppToggleTopbarUI.ResetOnSpawn = false
fppToggleTopbarUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
fppToggleTopbarUI.DisplayOrder = 100
fppToggleTopbarUI.IgnoreGuiInset = true
fppToggleTopbarUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

local fppToggleButton = Instance.new("TextButton")
fppToggleButton.Name = "FPPToggleButton"
fppToggleButton.AnchorPoint = Vector2.new(1, 0.5)
local success, result = pcall(function()
	return GuiService:GetGuiInset()
end)

local v18 = not (success and result) and 0 or result.Y

fppToggleButton.Position = UDim2.new(1, -168, 0, (v18 <= 0 and 36 or v18) / 2)
fppToggleButton.Size = UDim2.new(0, 70, 0, 30)
fppToggleButton.BackgroundColor3 = color
fppToggleButton.TextColor3 = color2
fppToggleButton.Font = Enum.Font.GothamBold
fppToggleButton.TextSize = 11
fppToggleButton.Text = "TPP"
fppToggleButton.ZIndex = 10
fppToggleButton.Parent = fppToggleTopbarUI

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = fppToggleButton

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = color3
uiStroke.Transparency = 0.5
uiStroke.Thickness = 1
uiStroke.Parent = fppToggleButton

local function refreshFppButtonText() -- 3 equivalent calls inferred from this helper
	fppToggleButton.Text = flag and "FPP" or "TPP"
end

local function requestButtonFPPToggle()
	if v15 or SessionCameraSettings.GetIsMenuOpen() then
		return
	end

	fn2()
end

fppToggleButton.MouseButton1Click:Connect(requestButtonFPPToggle)

local function onFppTopbarViewportChanged()
	local success2, result2 = pcall(function()
		return GuiService:GetGuiInset()
	end)

	local v19 = not (success2 and result2) and 0 or result2.Y

	local v20 = v19 <= 0 and 36 or v19

	fppToggleButton.Position = UDim2.new(1, -168, 0, v20 / 2)
end

local function connectFppTopbarViewportListener() -- 1 equivalent call inferred from this helper
	local currentCamera = Workspace.CurrentCamera

	if currentCamera then
		currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(onFppTopbarViewportChanged)
	end
end

connectFppTopbarViewportListener() -- inferred equivalent call
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(connectFppTopbarViewportListener)
refreshFppButtonText() -- inferred equivalent call

if v then
	local v19 = nil

	UserInputService.TouchPinch:Connect(function(_, p, _, p2, p3)
		if p3 then
			return
		end

		if SessionCameraSettings.GetIsMenuOpen() or SessionCameraSettings.GetIsScrollBlocked() then
			v19 = nil
			return
		end

		if p2 == Enum.UserInputState.Begin then
			v19 = p
			return
		end

		if p2 == Enum.UserInputState.Cancel or p2 == Enum.UserInputState.End then
			v19 = nil
			return
		end

		if not v19 then
			v19 = p
			return
		end

		local v20 = p - v19
		v19 = p
		local v21 = v12 > 3
		v12 -= v20 * 25
		v12 = math.clamp(v12, 0.5, 20)

		local v22 = v12 <= 3

		if v21 and v22 and not flag then
			fn(function()
				v12 = 0.5

				LocalPlayer.CameraMinZoomDistance = 0.5
				LocalPlayer.CameraMaxZoomDistance = 0.5
				task.delay(0.35, function()
					LocalPlayer.CameraMinZoomDistance = 0.5
					LocalPlayer.CameraMaxZoomDistance = 20
				end)
			end)
		end
	end)
end

RunService:BindToRenderStep("FirstPersonBodyDetect", Enum.RenderPriority.Camera.Value + 1, function()
	if not head then
		return
	end

	if SessionCameraSettings.GetIsCinematicActive() then
		if flag then
			exitFirstPerson() -- inferred equivalent call
			refreshFppButtonText() -- inferred equivalent call
		end
	else
		local v19 = v12 <= HeadTrackingConfig.FIRST_PERSON_DISTANCE

		if v19 ~= flag then
			if v19 then
				v14()
			else
				exitFirstPerson() -- inferred equivalent call
			end

			refreshFppButtonText() -- inferred equivalent call
		end

		if flag then
			keepBodyVisible()
			setAccessoriesTransparency(1)

			CurrentCamera.FieldOfView = SessionCameraSettings.GetFirstPersonFOV()
		end
	end
end)

RunService:BindToRenderStep("FirstPersonBodyCameraPush", Enum.RenderPriority.Character.Value + 5, function(p)
	if not (flag and humanoid) then
		return
	end

	local v19 = Vector3.new(0, 0, 0)

	local y = CurrentCamera.CFrame.LookVector.Y

	if y < HeadTrackingConfig.FIRST_PERSON_TORSO_TRACK_FREEZE_LOOKDOWN then
		v3 = true
	elseif HeadTrackingConfig.FIRST_PERSON_TORSO_TRACK_RESUME_LOOKDOWN < y then
		v3 = false
	end

	local v20, humanoidRootPart, v21, v22

	if position and folder and head then
		if isSeated() or v3 then -- inferred equivalent call
			if flag then
				v20 = isSeated() -- inferred equivalent call

				if v20 and folder and head and v2 == "Drum" and not v3 then
					humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart then
						v21 = SessionCameraSettings.GetDrumGoProHeadDelta()
						v22 = humanoidRootPart.CFrame:VectorToWorldSpace(v21.Position)
						v19 = CurrentCamera.CFrame:VectorToObjectSpace(v22)

						if v19.Magnitude > 0.4 then
							v19 = v19.Unit * 0.4
						end
					end
				end
			end
		else
			local humanoidRootPart2 = folder:FindFirstChild("HumanoidRootPart")
			local upperTorso = folder:FindFirstChild("UpperTorso")

			if humanoidRootPart2 and upperTorso then
				local v23 = humanoidRootPart2.CFrame:ToObjectSpace(upperTorso.CFrame).Position - position

				local vectorToWorldSpace = humanoidRootPart2.CFrame:VectorToWorldSpace(v23)
				v19 = CurrentCamera.CFrame:VectorToObjectSpace(vectorToWorldSpace) * HeadTrackingConfig.FIRST_PERSON_TORSO_TRACK_MULTIPLIER
			end
		end
	elseif flag then
		v20 = isSeated() -- inferred equivalent call

		if v20 and folder and head and v2 == "Drum" and not v3 then
			humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				v21 = SessionCameraSettings.GetDrumGoProHeadDelta()
				v22 = humanoidRootPart.CFrame:VectorToWorldSpace(v21.Position)
				v19 = CurrentCamera.CFrame:VectorToObjectSpace(v22)

				if v19.Magnitude > 0.4 then
					v19 = v19.Unit * 0.4
				end
			end
		end
	end

	local v23 = 1 - math.exp(-HeadTrackingConfig.FIRST_PERSON_TORSO_TRACK_SMOOTH_SPEED * p)
	v4 = v4:Lerp(v19, v23)

	local vector3 = Vector3.new(0, 0, -HeadTrackingConfig.FIRST_PERSON_FORWARD_OFFSET)

	local drumCameraShakeOffset = SessionCameraSettings.GetDrumCameraShakeOffset()
	humanoid.CameraOffset = drumCameraShakeOffset + vector3 + v4
end)

RunService:BindToRenderStep("FirstPersonPitchClamp", Enum.RenderPriority.Character.Value + 8, function()
	if not flag then
		return
	end

	local lookVector = CurrentCamera.CFrame.LookVector

	if math.asin((math.clamp(lookVector.Y, -1, 1))) < -HeadTrackingConfig.FIRST_PERSON_MAX_DOWN_PITCH then
		local position2 = CurrentCamera.CFrame.Position
		local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)
		local unit = vector3.Magnitude > 0.001 and vector3.Unit or Vector3.new(0, 0, -1)

		local v19 = -HeadTrackingConfig.FIRST_PERSON_MAX_DOWN_PITCH
		local v20 = unit * math.cos(v19) + Vector3.new(0, math.sin(v19), 0)

		CurrentCamera.CFrame = CFrame.new(position2, position2 + v20)
	end
end)

local total = 0

RunService:BindToRenderStep("FirstPersonSeatedLookClamp", Enum.RenderPriority.Character.Value + 10, function(p)
	if flag and isSeated() and folder then -- inferred equivalent call
		local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local lookVector = humanoidRootPart.CFrame.LookVector
		local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)

		if vector3.Magnitude < 0.001 then
			return
		end

		local unit = vector3.Unit
		local cframe2 = CFrame.new(Vector3.new(), unit)

		local position2 = CurrentCamera.CFrame.Position
		local vectorToObjectSpace = cframe2:VectorToObjectSpace(CurrentCamera.CFrame.LookVector)

		local v19 = math.atan2(-vectorToObjectSpace.X, -vectorToObjectSpace.Z)
		local v20 = math.asin((math.clamp(vectorToObjectSpace.Y, -1, 1)))

		local v21 = HeadTrackingConfig.SEATED_FPP_MAX_YAW * math.tanh(v19 / HeadTrackingConfig.SEATED_FPP_MAX_YAW)

		local v22 = 1 - math.exp(-HeadTrackingConfig.SEATED_FPP_LOOK_SPRING_SPEED * p)
		total += (v21 - total) * v22

		local v23 = cframe2 * CFrame.Angles(0, total, 0) * CFrame.Angles(v20, 0, 0)
		CurrentCamera.CFrame = CFrame.new(position2, position2 + v23.LookVector)
	end
end)

local cframe2 = CFrame.new()

RunService:BindToRenderStep("FirstPersonDrumGoPro", Enum.RenderPriority.Character.Value + 12, function(p)
	local v19 = flag

	if v19 then
		v19 = isSeated() and folder and head -- inferred equivalent call

		if v19 then
			if v2 == "Drum" then
				v19 = not v3
			else
				v19 = false
			end
		end
	end

	SessionCameraSettings.SetIsDrumFirstPersonGoPro(v19)

	local drumGoProHeadDelta = SessionCameraSettings.GetDrumGoProHeadDelta()
	local cframe3 = CFrame.fromMatrix(
		Vector3.new(),
		drumGoProHeadDelta.XVector,
		drumGoProHeadDelta.YVector,
		drumGoProHeadDelta.ZVector
	)

	local v20 = 1 - math.exp(-HeadTrackingConfig.FIRST_PERSON_TORSO_TRACK_SMOOTH_SPEED * p)
	cframe = cframe:Lerp(cframe3, v20)

	local axisAngle, v21 = cframe:ToAxisAngle()
	local v22 = math.min(v21, 0.13962634015954636)
	local cframe4 = CFrame.fromAxisAngle(axisAngle, v22)

	local drainDrumGlanceRequests = SessionCameraSettings.DrainDrumGlanceRequests()

	if drainDrumGlanceRequests and v19 then
		for _, drainDrumGlanceRequest in ipairs(drainDrumGlanceRequests) do
			local v23 = v5[drainDrumGlanceRequest.type]

			if not v23 then
				continue
			end

			local v24 = atsByType[drainDrumGlanceRequest.type]
			atsByType[drainDrumGlanceRequest.type] = drainDrumGlanceRequest.at

			if not (not v24 or drainDrumGlanceRequest.at - v24 > 4) then
				continue
			end

			v6 = drainDrumGlanceRequest.at - 0.3
			v7 = drainDrumGlanceRequest.at + 1.1
			local yaw = math.rad(v23.yaw)
			local pitch = math.rad(v23.pitch)
			v8 = yaw
			v9 = pitch
		end
	end

	local now = os.clock()
	local v23, v24

	if v19 and v6 <= now and now < v7 then
		v23 = v8
		v24 = v9
	else
		v23 = 0
		v24 = 0
	end

	local v25 = 1 - math.exp(-(v23 == 0 and v24 == 0 and 4.5 or 9) * p)
	v10 = math.clamp(v10 + (v23 - v10) * v25, -0.5235987755982988, 0.5235987755982988)
	v11 = math.clamp(v11 + (v24 - v11) * v25, -0.2617993877991494, 0.2617993877991494)
	local v26 = cframe4 * (CFrame.Angles(0, v10, 0) * CFrame.Angles(v11, 0, 0))
	CurrentCamera.CFrame = CurrentCamera.CFrame * cframe2:Inverse() * v26
	cframe2 = v26
end)