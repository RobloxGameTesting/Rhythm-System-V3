local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CaptureService = game:GetService("CaptureService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local GCamConfig = require(Modules:WaitForChild("GCamConfig"))
local GCamFx = require(Modules:WaitForChild("GCamFx"))
local GCamGalleryStore = require(Modules:WaitForChild("GCamGalleryStore"))
local GCamGalleryUI = require(Modules:WaitForChild("GCamGalleryUI"))
local GCamDevelop = require(Modules:WaitForChild("GCamDevelop"))
local SessionCameraSettings = require(Modules:WaitForChild("SessionCameraSettings"))

local GCamRemotes = ReplicatedStorage:WaitForChild("GCamRemotes")
local Request = GCamRemotes:WaitForChild("Request")
local ShutterFx = GCamRemotes:WaitForChild("ShutterFx")
local ShareReceive = GCamRemotes:WaitForChild("ShareReceive")
local Notify = GCamRemotes:WaitForChild("Notify")
local GCamAssets = ReplicatedStorage:WaitForChild("GCamAssets")

local Colors = GCamConfig.Colors
local CurrentCamera = Workspace.CurrentCamera
local low = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function inputMode(): string
	local lastInputType = UserInputService:GetLastInputType()

	if string.sub(lastInputType.Name, 1, 7) == "Gamepad" then
		return "gamepad"
	end

	if lastInputType == Enum.UserInputType.Touch or low then
		return "touch"
	end

	return "keyboard"
end

local v = {
	keyboard = {
		flash = "  [F]",
		filter = "Q  <   FILTER   >  E",
		help = "LMB SHOOT   RMB CLOSE   SCROLL ZOOM   G HIDE HUD   HOLD BACKSPACE: PUT AWAY",
		keep = "  K",
		share = "  T",
		discard = "  X"
	},
	gamepad = {
		flash = "  [Y]",
		filter = "L1  <   FILTER   >  R1",
		help = "R2 SHOOT   L2 CLOSE   D-PAD UP/DOWN ZOOM   R3 HIDE HUD   HOLD B: PUT AWAY",
		keep = "  A",
		share = "  X",
		discard = "  B"
	},
	touch = {
		flash = "",
		filter = "",
		help = "",
		keep = "",
		share = "",
		discard = ""
	}
}

local v2 = {
	holding = false,
	aiming = false,
	zoom = 1,
	targetZoom = 1,
	filterIndex = 1,
	flash = false,
	busy = false,
	cooldownUntil = 0,
	pending = nil,
	toggledFPP = false,
	recStart = 0,
	battery = 1,
	hudHidden = false
}

local id = 0
local cframe = nil
local v3 = nil
local v4 = nil
local screenGuiSet = {}
local set = {}
local focus = 40
local total = 0
local total2 = 0

local function corner(parent, value) -- 5 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, value or 3)
	uiCorner.Parent = parent
	return uiCorner
end

local function stroke(parent, color, value, value2) -- 7 equivalent calls inferred from this helper
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color
	uiStroke.Thickness = value or 1
	uiStroke.Transparency = value2 or 0
	uiStroke.Parent = parent
	return uiStroke
end

local function osdLabel(hud, text, textSize, p, value)
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.Arcade
	textLabel.TextSize = textSize
	textLabel.TextColor3 = Colors.Osd
	textLabel.Text = text
	textLabel.TextXAlignment = p or Enum.TextXAlignment.Left
	textLabel.ZIndex = value or 11
	textLabel.Parent = hud
	stroke(textLabel, Color3.new(0, 0, 0), 1.5, 0.35) -- inferred equivalent call
	return textLabel
end

local function toast(p, p2) -- 7 equivalent calls inferred from this helper
	GCamGalleryUI.Toast(p, p2)
end

local function currentFilter() -- 5 equivalent calls inferred from this helper
	return GCamConfig.Filters[v2.filterIndex]
end

local gCamLocal = Instance.new("Folder")
local v5 = {}
local object = setmetatable({}, { __mode = "k" })
local v6 = false

gCamLocal.Name = "GCamLocal"
gCamLocal.Parent = Workspace

local function createHeld(p)
	local handle = GCamAssets:FindFirstChild("Handle")

	if not handle then
		return nil
	end

	local clone = handle:Clone()
	clone.Name = "Held_" .. p.UserId
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.CastShadow = false
	clone.Massless = true
	clone.Parent = gCamLocal

	local lightEmit = Instance.new("Part")
	lightEmit.Name = "LightEmit"
	lightEmit.Size = Vector3.new(0.2, 0.2, 0.2)
	lightEmit.Transparency = 1
	lightEmit.Anchored = true
	lightEmit.CanCollide = false
	lightEmit.CanQuery = false
	lightEmit.CanTouch = false
	lightEmit.CastShadow = false
	lightEmit.Parent = gCamLocal

	local spotLight = Instance.new("SpotLight")
	spotLight.Face = Enum.NormalId.Front
	spotLight.Angle = 115
	spotLight.Range = 70
	spotLight.Brightness = 6
	spotLight.Color = Color3.fromRGB(255, 244, 228)
	spotLight.Shadows = true
	spotLight.Enabled = false
	spotLight.Parent = lightEmit

	local pointLight = Instance.new("PointLight")
	pointLight.Range = 16
	pointLight.Brightness = 3
	pointLight.Color = Color3.fromRGB(255, 244, 228)
	pointLight.Enabled = false
	pointLight.Parent = lightEmit

	local blink = Instance.new("Part")
	blink.Name = "Blink"
	blink.Shape = Enum.PartType.Ball
	blink.Size = Vector3.new(0.08, 0.08, 0.08)
	blink.Material = Enum.Material.Neon
	blink.Color = Color3.fromRGB(255, 40, 40)
	blink.Transparency = 1
	blink.Anchored = true
	blink.CanCollide = false
	blink.CanQuery = false
	blink.CanTouch = false
	blink.CastShadow = false
	blink.Parent = gCamLocal

	local v7 = {
		handle = clone,
		emit = lightEmit,
		spot = spotLight,
		point = pointLight,
		blink = blink,
		alpha = 0
	}

	v5[p] = v7
	return v7
end

local function resetPose(character)
	if not character then
		return
	end

	for k, c0 in pairs(object) do
		if not (k.Parent and k:IsDescendantOf(character)) then
			continue
		end

		k.C0 = c0
		object[k] = nil
	end
end

local function destroyHeld(player)
	local v7 = v5[player]

	if not v7 then
		return
	end

	for _, v8 in ipairs({ v7.handle, v7.emit, v7.blink }) do
		pcall(function()
			v8:Destroy()
		end)
	end

	v5[player] = nil
	resetPose(player.Character)
end

local function getArmJoints(instance, p)
	local child = instance:FindFirstChild(p .. "UpperArm")
	local child2 = instance:FindFirstChild(p .. "LowerArm")
	local child3 = instance:FindFirstChild(p .. "Hand")
	local child4 = child and child:FindFirstChild(p .. "Shoulder")
	local child5 = child2 and child2:FindFirstChild(p .. "Elbow")
	local child6 = child3 and child3:FindFirstChild(p .. "Wrist")

	if child4 and child5 and child6 then
		return child4, child5, child6
	end

	return nil
end

local function originalC0(instance, p, armJoints, p2)
	local upperTorso = instance:FindFirstChild("UpperTorso")
	local child = instance:FindFirstChild(p .. "UpperArm")
	local child2 = upperTorso and upperTorso:FindFirstChild(p .. "ShoulderRigAttachment")
	local child3 = child and child:FindFirstChild(p .. "ElbowRigAttachment")
	return child2 and child2.CFrame or armJoints.C0, child3 and child3.CFrame or p2.C0
end

local function applyArmPose(p, p2, p3): boolean
	local armJoints, v7 = getArmJoints(p, p2)

	if not armJoints then
		return false
	end

	local v8, v9 = originalC0(p, p2, armJoints, v7)
	object[armJoints] = v8
	object[v7] = v9
	local v10 = GCamConfig.POSE[p2]
	armJoints.C0 = object[armJoints] * CFrame.Angles(
		math.rad(v10[1] * p3),
		math.rad(v10[2] * p3),
		(math.rad(v10[3] * p3))
	)
	v7.C0 = object[v7] * CFrame.Angles(math.rad(v10[4] * p3), 0, 0)

	armJoints.Transform = armJoints.Transform:Lerp(CFrame.identity, p3)
	v7.Transform = v7.Transform:Lerp(CFrame.identity, p3)
	return true
end

local function applyPose(p, p2)
	local v7 = applyArmPose(p, "Right", p2)
	applyArmPose(p, "Left", p2)
	return v7
end

local function fkHand(character, p)
	local upperTorso = character:FindFirstChild("UpperTorso")
	local armJoints, v7, v8 = getArmJoints(character, p)

	if not (upperTorso and armJoints) then
		return nil
	end

	local v9 = GCamConfig.POSE[p]
	local v10 = object[armJoints] or armJoints.C0
	local v11 = object[v7] or v7.C0
	return upperTorso.CFrame * v10 * CFrame.Angles(math.rad(v9[1]), math.rad(v9[2]), (math.rad(v9[3]))) * armJoints.C1:Inverse() * v11 * CFrame.Angles(math.rad(v9[4]), 0, 0) * v7.C1:Inverse() * v8.C0 * v8.C1:Inverse()
end

local function updateHeld(p)
	for _, v7 in ipairs(Players:GetPlayers()) do
		local gCamHolding = v7:GetAttribute("GCamHolding") == true
		local v8 = v5[v7]

		if gCamHolding and not v8 then
			v8 = createHeld(v7)
		elseif not gCamHolding and v8 then
			destroyHeld(v7)
			v8 = nil
		end

		if not v8 then
			continue
		end

		local character = v7.Character
		local rightHand = character and (character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm"))
		local head = character and character:FindFirstChild("Head")

		if rightHand and head then
			local v9 = v7:GetAttribute("GCamAiming") == true

			if v7 == LocalPlayer then
				v9 = v2.aiming
			end

			local v10 = p * 5

			if v9 then
				v8.alpha = math.min(1, v8.alpha + v10)
			else
				v8.alpha = math.max(0, v8.alpha - v10)
			end

			local v11 = v8.alpha * v8.alpha * (3 - 2 * v8.alpha)
			local v12

			if character:FindFirstChild("RightUpperArm") then
				v12 = applyArmPose(character, "Right", v11)
				applyArmPose(character, "Left", v11)
			else
				v12 = false
			end

			local v13 = head.CFrame * GCamConfig.AIM_OFFSET
			local cframe2

			if v12 then
				cframe2 = fkHand(character, "Right") or nil
			end

			local cframe3

			if cframe2 then
				local v14 = cframe2:Inverse() * v13
				cframe3 = rightHand.CFrame * GCamConfig.HOLD_GRIP:Lerp(v14, v11)
			else
				cframe3 = (rightHand.CFrame * GCamConfig.HOLD_GRIP):Lerp(v13, v11)
			end

			v8.handle.CFrame = cframe3
			v8.emit.CFrame = cframe3 * CFrame.new(0, 0, -0.45)
			v8.blink.CFrame = cframe3 * CFrame.new(-0.36, 0.41, 0.2)

			local v14 = (CurrentCamera.CFrame.Position - head.Position).Magnitude < 3
			local v15 = v7 == LocalPlayer and (v11 > 0.5 and v14 or v6)
			local v16 = v6 and v7 ~= LocalPlayer and true or v15
			v8.handle.LocalTransparencyModifier = v16 and 1 or 0
			v8.blink.Transparency = v9 and not v16 and os.clock() % 1 < 0.6 and 0 or 1

			if v7 == LocalPlayer then
				for _, childName in ipairs({
					"RightUpperArm",
					"RightLowerArm",
					"RightHand",
					"LeftUpperArm",
					"LeftLowerArm",
					"LeftHand"
				}) do
					local child = character:FindFirstChild(childName)

					if child and v11 > 0.5 and v14 then
						child.LocalTransparencyModifier = 1
					end
				end
			end
		else
			v8.handle.LocalTransparencyModifier = 1
			v8.blink.Transparency = 1
		end
	end
end

local function setLights(p, enabled) -- 4 equivalent calls inferred from this helper
	local v7 = v5[p]

	if v7 then
		v7.spot.Enabled = enabled
		v7.point.Enabled = enabled
	end
end

local function playShutter(p, p2)
	local v7 = v5[p]

	if not v7 then
		return
	end

	local snap = v7.handle:FindFirstChild("Snap")

	if snap then
		snap:Play()
	end

	if p2 and p ~= LocalPlayer then
		setLights(p, true) -- inferred equivalent call
		task.delay(0.1, function()
			setLights(p, false) -- inferred equivalent call
		end)
	end
end

GCamGalleryUI.SetHeldHider(function(p)
	v6 = p
end)

Players.PlayerRemoving:Connect(function(player)
	destroyHeld(player)
end)

local gCamHUD = Instance.new("ScreenGui")
gCamHUD.Name = "GCamHUD"
gCamHUD.ResetOnSpawn = false
gCamHUD.IgnoreGuiInset = true
gCamHUD.DisplayOrder = 500
gCamHUD.Enabled = false
gCamHUD.Parent = PlayerGui

local v7 = GCamFx.new(gCamHUD, { low = low })
v7:SetFilter(currentFilter(), true) -- inferred equivalent call

local hud = Instance.new("Frame")
hud.Name = "Hud"
hud.BackgroundTransparency = 1
hud.Size = UDim2.fromScale(1, 1)
hud.ZIndex = 10
hud.Parent = gCamHUD

local uiScale = Instance.new("UIScale")
uiScale.Parent = hud
local function fitHud() -- 1 equivalent call inferred from this helper
	local scale = math.clamp(Workspace.CurrentCamera.ViewportSize.Y / 700, 0.6, 1)
	uiScale.Scale = scale
	hud.Size = UDim2.fromScale(1 / scale, 1 / scale)
end

fitHud() -- inferred equivalent call
Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitHud)

local v8 = {}

local function bracket(p, p2)
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.AnchorPoint = Vector2.new(p, p2)
	frame.Position = UDim2.new(p == 0 and 0.045 or 0.955, 0, p2 == 0 and 0.07 or 0.93, 0)
	frame.Size = UDim2.fromOffset(46, 46)
	frame.ZIndex = 11
	frame.Parent = hud
	local frame2 = Instance.new("Frame")
	frame2.BorderSizePixel = 0
	frame2.BackgroundColor3 = Colors.Osd
	frame2.BackgroundTransparency = 0.1
	frame2.AnchorPoint = Vector2.new(p, p2)
	frame2.Position = UDim2.fromScale(p, p2)
	frame2.Size = UDim2.new(1, 0, 0, 3)
	frame2.ZIndex = 11
	frame2.Parent = frame
	local clone = frame2:Clone()
	clone.Size = UDim2.new(0, 3, 1, 0)
	clone.Parent = frame
	table.insert(v8, frame2)
	table.insert(v8, clone)
end
bracket(0, 0)
bracket(1, 0)
bracket(0, 1)
bracket(1, 1)

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.Size = UDim2.fromOffset(120, 84)
frame.BackgroundTransparency = 1
frame.ZIndex = 11
frame.Parent = hud
local uiStroke = stroke(frame, Colors.Osd, 2, 0.15) -- inferred equivalent call

local frame2 = Instance.new("Frame")
frame2.AnchorPoint = Vector2.new(0.5, 0.5)
frame2.Position = UDim2.fromScale(0.5, 0.5)
frame2.Size = UDim2.fromOffset(10, 2)
frame2.BorderSizePixel = 0
frame2.BackgroundColor3 = Colors.Osd
frame2.ZIndex = 11
frame2.Parent = frame
local clone = frame2:Clone()
clone.Size = UDim2.fromOffset(2, 10)
clone.Parent = frame

local v9 = osdLabel(hud, "AF", 14, Enum.TextXAlignment.Center)
v9.AnchorPoint = Vector2.new(0.5, 0)
v9.Position = UDim2.new(0.5, 0, 0.5, 52)
v9.Size = UDim2.fromOffset(160, 18)

local frame3 = Instance.new("Frame")
frame3.Size = UDim2.fromOffset(16, 16)
frame3.Position = UDim2.new(0.045, 6, 0.07, 6)
frame3.BackgroundColor3 = Color3.fromRGB(235, 40, 40)
frame3.BorderSizePixel = 0
frame3.ZIndex = 12
frame3.Parent = hud
corner(frame3, 8) -- inferred equivalent call
local v10 = osdLabel(hud, "REC", 24)
v10.Position = UDim2.new(0.045, 30, 0.07, 0)
v10.Size = UDim2.fromOffset(80, 28)

local v11 = osdLabel(hud, "00:00:00", 18)
v11.Position = UDim2.new(0.045, 6, 0.07, 32)
v11.Size = UDim2.fromOffset(160, 22)

local v12 = osdLabel(hud, "SP  ▶", 16)
v12.Text = "SP  PLAY"
v12.Position = UDim2.new(0.045, 6, 0.07, 56)
v12.Size = UDim2.fromOffset(160, 20)

local frame4 = Instance.new("Frame")
frame4.AnchorPoint = Vector2.new(1, 0)
frame4.Position = UDim2.new(0.955, -52, 0.07, 6)
frame4.Size = UDim2.fromOffset(44, 18)
frame4.BackgroundTransparency = 1
frame4.ZIndex = 11
frame4.Parent = hud
stroke(frame4, Colors.Osd, 2, 0.1) -- inferred equivalent call
local frame5 = Instance.new("Frame")
frame5.BorderSizePixel = 0
frame5.BackgroundColor3 = Colors.Osd
frame5.Position = UDim2.fromOffset(3, 3)
frame5.Size = UDim2.new(1, -6, 1, -6)
frame5.ZIndex = 12
frame5.Parent = frame4
local frame6 = Instance.new("Frame")
frame6.BorderSizePixel = 0
frame6.BackgroundColor3 = Colors.Osd
frame6.Position = UDim2.new(1, 2, 0.5, -4)
frame6.Size = UDim2.fromOffset(4, 8)
frame6.ZIndex = 11
frame6.Parent = frame4
local v13 = osdLabel(hud, "100%", 14, Enum.TextXAlignment.Right)
v13.AnchorPoint = Vector2.new(1, 0)
v13.Position = UDim2.new(0.955, 0, 0.07, 28)
v13.Size = UDim2.fromOffset(120, 18)

local v14 = osdLabel(hud, "", 20, Enum.TextXAlignment.Center)
v14.AnchorPoint = Vector2.new(0.5, 0)
v14.Position = UDim2.new(0.5, 0, 0.07, 0)
v14.Size = UDim2.fromOffset(300, 26)
local lastInputType = UserInputService:GetLastInputType()
local v15 = osdLabel(
	hud,
	v[string.sub(lastInputType.Name, 1, 7) == "Gamepad" and "gamepad" or (lastInputType == Enum.UserInputType.Touch or low) and "touch" or "keyboard"].filter,
	13,
	Enum.TextXAlignment.Center
)
v15.AnchorPoint = Vector2.new(0.5, 0)
v15.Position = UDim2.new(0.5, 0, 0.07, 28)
v15.Size = UDim2.fromOffset(300, 18)
v15.TextTransparency = 0.25

local v16 = osdLabel(hud, "", 16)
v16.AnchorPoint = Vector2.new(0, 1)
v16.Position = UDim2.new(0.045, 6, 0.93, -26)
v16.Size = UDim2.fromOffset(300, 20)
local lastInputType2 = UserInputService:GetLastInputType()
local v17 = osdLabel(
	hud,
	v[string.sub(lastInputType2.Name, 1, 7) == "Gamepad" and "gamepad" or (lastInputType2 == Enum.UserInputType.Touch or low) and "touch" or "keyboard"].help,
	12
)
v17.AnchorPoint = Vector2.new(0, 1)
v17.Position = UDim2.new(0.045, 6, 0.93, 0)
v17.Size = UDim2.fromOffset(640, 18)
v17.TextTransparency = 0.3

local v18 = osdLabel(hud, "", 20, Enum.TextXAlignment.Right)
v18.AnchorPoint = Vector2.new(1, 1)
v18.Position = UDim2.new(0.955, 0, 0.93, -26)
v18.Size = UDim2.fromOffset(300, 24)
local v19 = osdLabel(hud, "", 20, Enum.TextXAlignment.Right)
v19.AnchorPoint = Vector2.new(1, 1)
v19.Position = UDim2.new(0.955, 0, 0.93, 0)
v19.Size = UDim2.fromOffset(300, 24)

local v20 = osdLabel(hud, "x1.0", 18, Enum.TextXAlignment.Center)
v20.AnchorPoint = Vector2.new(0.5, 1)
v20.Position = UDim2.new(0.5, 0, 0.93, -18)
v20.Size = UDim2.fromOffset(120, 22)
local frame7 = Instance.new("Frame")
frame7.AnchorPoint = Vector2.new(0.5, 1)
frame7.Position = UDim2.new(0.5, 0, 0.93, 0)
frame7.Size = UDim2.fromOffset(160, 6)
frame7.BackgroundColor3 = Color3.new(0, 0, 0)
frame7.BackgroundTransparency = 0.45
frame7.BorderSizePixel = 0
frame7.ZIndex = 11
frame7.Parent = hud
local frame8 = Instance.new("Frame")
frame8.BorderSizePixel = 0
frame8.BackgroundColor3 = Colors.Osd
frame8.Size = UDim2.fromScale(0, 1)
frame8.ZIndex = 12
frame8.Parent = frame7

local function refreshHud()
	local v21 = currentFilter() -- inferred equivalent call
	v14.Text = v21.name
	uiStroke.Color = v21.accent
	frame3.BackgroundColor3 = v21.accent
	local v22 = v2.flash and "FLASH ON" or "FLASH OFF"
	local lastInputType3 = UserInputService:GetLastInputType()
	v16.Text = v22 .. v[string.sub(lastInputType3.Name, 1, 7) == "Gamepad" and "gamepad" or (lastInputType3 == Enum.UserInputType.Touch or low) and "touch" or "keyboard"].flash
	v16.TextColor3 = v2.flash and Color3.fromRGB(255, 235, 120) or Colors.Osd

	for _, v23 in ipairs(v8) do
		v23.BackgroundColor3 = Colors.Osd
	end
end
refreshHud()

local function updateHudSlow()
	local now = DateTime.now()
	v18.Text = string.upper(now:FormatLocalTime("MMM DD YYYY", "en-us"))
	v19.Text = now:FormatLocalTime("HH:mm:ss", "en-us")

	local v21 = math.floor(os.clock() - v2.recStart)
	v11.Text = string.format("%02d:%02d:%02d", v21 // 3600, v21 % 3600 // 60, v21 % 60)

	v13.Text = math.floor(v2.battery * 100 + 0.5) .. "%"
	frame5.Size = UDim2.new(math.clamp(v2.battery, 0.05, 1), -6, 1, -6)
	frame5.BackgroundColor3 = v2.battery < 0.2 and Color3.fromRGB(235, 50, 50) or Colors.Osd

	v9.Text = string.format("AF  %dm", (math.floor(focus)))
end

local gCamPreview = Instance.new("ScreenGui")
gCamPreview.Name = "GCamPreview"
gCamPreview.ResetOnSpawn = false
gCamPreview.IgnoreGuiInset = true
gCamPreview.DisplayOrder = 520
gCamPreview.Enabled = false
gCamPreview.Parent = PlayerGui

local frame9 = Instance.new("Frame")
frame9.AnchorPoint = Vector2.new(1, 0.5)
frame9.Size = UDim2.fromOffset(320, 300)
frame9.BackgroundColor3 = Colors.Paper
frame9.Parent = gCamPreview
corner(frame9, 2) -- inferred equivalent call
stroke(frame9, Color3.new(0, 0, 0), 2, 0.5) -- inferred equivalent call

local imageLabel = Instance.new("ImageLabel")
imageLabel.Position = UDim2.fromOffset(12, 12)
imageLabel.BackgroundColor3 = Colors.Ink
imageLabel.ScaleType = Enum.ScaleType.Crop
imageLabel.Parent = frame9

local textButton = Instance.new("TextButton")
textButton.BackgroundTransparency = 1
textButton.Text = ""
textButton.Size = UDim2.fromScale(1, 1)
textButton.ZIndex = 5
textButton.Parent = imageLabel
textButton.MouseButton1Click:Connect(function()
	if v2.pending then
		GCamGalleryUI.OpenFullscreen(v2.pending)
	end
end)

local textLabel = Instance.new("TextLabel")
textLabel.BackgroundTransparency = 1
textLabel.Font = Enum.Font.PermanentMarker
textLabel.TextSize = 15
textLabel.TextColor3 = Colors.Ink
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.TextTruncate = Enum.TextTruncate.AtEnd
textLabel.Parent = frame9

local function cardButton(text, backgroundColor, textColor, p)
	local textButton2 = Instance.new("TextButton")
	textButton2.AutoButtonColor = false
	textButton2.BackgroundColor3 = backgroundColor
	textButton2.TextColor3 = textColor
	textButton2.Font = Enum.Font.GothamBold
	textButton2.TextSize = 12
	textButton2.Text = text
	textButton2.Size = UDim2.fromOffset(92, 32)
	textButton2.Position = UDim2.new(0, p, 1, -44)
	textButton2.Parent = frame9
	corner(textButton2) -- inferred equivalent call
	textButton2.MouseEnter:Connect(function()
		textButton2.BackgroundColor3 = backgroundColor:Lerp(Color3.new(1, 1, 1), 0.15)
	end)
	textButton2.MouseLeave:Connect(function()
		textButton2.BackgroundColor3 = backgroundColor
	end)
	return textButton2
end

local lastInputType3 = UserInputService:GetLastInputType()
local v21 = v[string.sub(lastInputType3.Name, 1, 7) == "Gamepad" and "gamepad" or (lastInputType3 == Enum.UserInputType.Touch or low) and "touch" or "keyboard"]

local keep = v21.keep
local share = v21.share
local discard = v21.discard
local v22 = cardButton("KEEP" .. keep, Colors.Ink, Colors.Paper, 12)
local v23 = cardButton("SHARE" .. share, Colors.Red, Colors.Paper, 114)
local v24 = cardButton("DISCARD" .. discard, Colors.Paper, Colors.Red, 216)
stroke(v24, Colors.Red, 1.5) -- inferred equivalent call

local uiScale2 = Instance.new("UIScale")
uiScale2.Parent = frame9
local function fitCard() -- 1 equivalent call inferred from this helper
	uiScale2.Scale = math.clamp(Workspace.CurrentCamera.ViewportSize.Y / 700, 0.62, 1)
end

fitCard() -- inferred equivalent call
Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitCard)

local function refreshHints()
	local lastInputType4 = UserInputService:GetLastInputType()
	local v25 = v[string.sub(lastInputType4.Name, 1, 7) == "Gamepad" and "gamepad" or (lastInputType4 == Enum.UserInputType.Touch or low) and "touch" or "keyboard"]

	v15.Text = v25.filter
	v17.Text = v25.help
	v22.Text = "KEEP" .. v25.keep
	v23.Text = "SHARE" .. v25.share
	v24.Text = "DISCARD" .. v25.discard
	refreshHud()
end
UserInputService.LastInputTypeChanged:Connect(refreshHints)

local function freePendingMouse(p)
	GCamGalleryUI.SetExternalHold(p)

	if p and UserInputService.MouseEnabled then
		RunService:BindToRenderStep("GCamPendingMouse", Enum.RenderPriority.Camera.Value + 2, function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		end)
	else
		pcall(function()
			RunService:UnbindFromRenderStep("GCamPendingMouse")
		end)
	end
end

local function hidePreview()
	GCamGalleryUI.SetExternalHold(false)

	pcall(function()
		RunService:UnbindFromRenderStep("GCamPendingMouse")
	end)

	TweenService:Create(frame9, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(1, 360, 0.5, 0),
		Rotation = 8
	}):Play()
	task.delay(0.24, function()
		if not v2.pending then
			gCamPreview.Enabled = false
		end
	end)
end

local function showPreview(pending)
	v2.pending = pending
	local viewportSize = CurrentCamera.ViewportSize
	local v25 = math.floor(296 / math.max(viewportSize.X / math.max(viewportSize.Y, 1), 0.5))
	imageLabel.Size = UDim2.fromOffset(296, v25)
	imageLabel.Image = pending.content
	textLabel.Position = UDim2.fromOffset(12, v25 + 16)
	textLabel.Size = UDim2.fromOffset(296, 24)
	local filter = GCamConfig.GetFilterById(pending.recipe.filter)
	textLabel.Text = string.upper(filter.name) .. "  •  " .. string.upper(DateTime.now():FormatLocalTime("MMM DD  HH:mm", "en-us"))
	frame9.Size = UDim2.fromOffset(320, v25 + 92)
	frame9.Position = UDim2.new(1, 360, 0.5, 0)
	frame9.Rotation = 8
	gCamPreview.Enabled = true
	TweenService:Create(frame9, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -28, 0.5, 0),
		Rotation = -2
	}):Play()
	freePendingMouse(true)
end

local function keepPhoto()
	local pending = v2.pending

	if not pending then
		return
	end

	v2.pending = nil
	local _, v25 = GCamGalleryStore.Add({
		content = pending.content,
		recipe = pending.recipe,
		ts = pending.ts
	})

	toast(v25 and "Kept - gallery full, oldest photo removed" or string.format( -- inferred equivalent call
		"Photo kept  (%d / %d)",
		GCamGalleryStore.Count(),
		GCamConfig.MAX_PHOTOS
	))
	hidePreview()
end

local function discardPhoto() -- 2 equivalent calls inferred from this helper
	if not v2.pending then
		return
	end

	v2.pending = nil
	toast("Photo discarded") -- inferred equivalent call
	hidePreview()
end

local function sharePending() -- 2 equivalent calls inferred from this helper
	if v2.pending then
		GCamGalleryUI.OpenSharePicker(v2.pending)
	end
end

v22.MouseButton1Click:Connect(keepPhoto)
v24.MouseButton1Click:Connect(discardPhoto)
v23.MouseButton1Click:Connect(sharePending)

local function hideOtherGuis()
	table.clear(screenGuiSet)

	for _, screenGui in ipairs(PlayerGui:GetChildren()) do
		if not (screenGui:IsA("ScreenGui") and screenGui.Enabled and string.sub(screenGui.Name, 1, 4) ~= "GCam" and screenGui.Name ~= "TouchGui") then
			continue
		end

		screenGuiSet[screenGui] = true
		screenGui.Enabled = false
	end

	for _, v25 in ipairs({ Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.EmotesMenu, Enum.CoreGuiType.Backpack }) do
		local success, result = pcall(function()
			return StarterGui:GetCoreGuiEnabled(v25)
		end)

		if not (success and result) then
			continue
		end

		set[v25] = true
		pcall(function()
			StarterGui:SetCoreGuiEnabled(v25, false)
		end)
	end
end

local function restoreOtherGuis()
	for k in pairs(screenGuiSet) do
		if k.Parent then
			k.Enabled = true
		end
	end

	table.clear(screenGuiSet)

	for k in pairs(set) do
		pcall(function()
			StarterGui:SetCoreGuiEnabled(k, true)
		end)
	end

	table.clear(set)
end

local function canAim(): boolean
	if
		not v2.holding
		or LocalPlayer:GetAttribute("EquippedInstrumentType") ~= nil
		or (SessionCameraSettings.GetIsMenuOpen() or SessionCameraSettings.GetIsCinematicActive())
	then
		return false
	end

	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0
end

local function fn(p)
	if p == v2.aiming then
		return
	end

	if p then
		if not canAim() then
			return
		end

		v2.aiming = true
		v2.recStart = os.clock()
		v2.zoom = 1
		v2.targetZoom = 1
		Request:FireServer("Aim", true)
		Request:FireServer("Flash", v2.flash)

		v2.toggledFPP = false
		v2.fppReached = false
		local cameraMinZoomDistance = LocalPlayer.CameraMinZoomDistance
		local cameraMaxZoomDistance = LocalPlayer.CameraMaxZoomDistance
		v2.savedMinZoom = cameraMinZoomDistance
		v2.savedMaxZoom = cameraMaxZoomDistance
		v2.savedDistance = (CurrentCamera.CFrame.Position - CurrentCamera.Focus.Position).Magnitude

		if not SessionCameraSettings.GetIsFirstPerson() and SessionCameraSettings.RequestFPPToggle() then
			v2.toggledFPP = true
		end

		SessionCameraSettings.SetScrollBlocked(true)
		ProximityPromptService.Enabled = false
		hideOtherGuis()

		v2.hudHidden = false
		hud.Visible = true
		GCamGalleryUI.SetToastsMuted(false)

		v7:SetEnabled(true)
		v7:SetFilter(currentFilter(), true) -- inferred equivalent call
		v7:Glitch()
		refreshHud()
		updateHudSlow()
		gCamHUD.Enabled = true
	else
		v2.aiming = false
		Request:FireServer("Aim", false)

		v2.hudHidden = false
		hud.Visible = true
		GCamGalleryUI.SetToastsMuted(false)

		v7:SetEnabled(false)
		gCamHUD.Enabled = false
		ProximityPromptService.Enabled = true
		restoreOtherGuis()

		local toggledFPP = v2.toggledFPP
		v2.toggledFPP = false

		if not (toggledFPP and SessionCameraSettings.GetIsFirstPerson()) then
			SessionCameraSettings.SetScrollBlocked(false)

			return
		end

		LocalPlayer.CameraMaxZoomDistance = v2.savedMaxZoom or 20
		LocalPlayer.CameraMinZoomDistance = v2.savedMinZoom or 0.5
		SessionCameraSettings.RequestFPPToggle()
		task.spawn(function()
			local lastTime = os.clock()

			while SessionCameraSettings.GetIsFirstPerson() and os.clock() - lastTime < 2 do
				task.wait(0.05)
			end

			local savedDistance = v2.savedDistance

			if savedDistance and savedDistance > 1.5 then
				local v25 = math.clamp(savedDistance, v2.savedMinZoom or 0.5, v2.savedMaxZoom or 20)
				LocalPlayer.CameraMinZoomDistance = v25
				LocalPlayer.CameraMaxZoomDistance = v25
			end

			task.wait(0.45)
			SessionCameraSettings.SetScrollBlocked(false)
		end)
	end
end

SessionCameraSettings.OnFirstPersonChanged(function(p)
	if not v2.aiming then
		return
	end

	if p then
		v2.fppReached = true
	elseif not v2.toggledFPP or v2.fppReached then
		v2.toggledFPP = false
		fn(false)
	end
end)

local function onHoldingChanged() -- 1 equivalent call inferred from this helper
	v2.holding = LocalPlayer:GetAttribute("GCamHolding") == true

	if not v2.holding and v2.aiming then
		fn(false)
	end
end
LocalPlayer:GetAttributeChangedSignal("GCamHolding"):Connect(onHoldingChanged)
onHoldingChanged() -- inferred equivalent call

local function buildRecipe()
	local cframe2 = v3 or CurrentCamera.CFrame
	local fov = v4 or CurrentCamera.FieldOfView
	local lookVector = cframe2.LookVector
	local v25 = math.cos((math.rad((math.min(fov * 0.85, 80)))))

	local v26 = {}

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not (player ~= LocalPlayer and humanoidRootPart) then
			continue
		end

		local v27 = humanoidRootPart.Position - cframe2.Position
		local magnitude = v27.Magnitude

		if magnitude <= GCamConfig.SHARE_RADIUS and magnitude > 0.5 and v25 < (v27 / magnitude):Dot(lookVector) then
			table.insert(v26, { player = player, character = character, distance = magnitude })
		end
	end

	table.sort(v26, function(a, b): boolean
		return a.distance < b.distance
	end)

	local chars = {}

	for i = 1, math.min(#v26, GCamConfig.SHARE_MAX_CHARACTERS) do
		local v27 = v26[i]
		local count = 0
		local v28 = {}

		for _, part in ipairs(v27.character:GetDescendants()) do
			if not (part:IsA("BasePart") and count < GCamConfig.SHARE_MAX_PARTS) then
				continue
			end

			v28[GCamDevelop.PartKey(v27.character, part)] = { part.CFrame:GetComponents() }
			count += 1
		end

		table.insert(chars, { uid = v27.player.UserId, p = v28 })
	end

	local cams = {}

	for k, v27 in pairs(v5) do
		if not (k ~= LocalPlayer and #cams < 8) then
			continue
		end

		local v28 = v27.handle.Position - cframe2.Position
		local magnitude = v28.Magnitude

		if magnitude <= GCamConfig.SHARE_RADIUS and magnitude > 0.5 and v25 < (v28 / magnitude):Dot(lookVector) then
			table.insert(cams, { v27.handle.CFrame:GetComponents() })
		end
	end

	return {
		cf = { cframe2:GetComponents() },
		fov = fov,
		zoom = v2.zoom,
		low = low,
		cams = cams,
		filter = currentFilter().id, -- inferred equivalent call
		flash = v2.flash,
		ts = os.time(),
		focus = focus,
		chars = chars
	}
end

local function captureNow()
	local v25 = nil
	local v26 = false

	if not pcall(function()
		CaptureService:CaptureScreenshot(function(p)
			v25 = p
			v26 = true
		end)
	end) then
		return nil
	end

	local lastTime = os.clock()

	while not v26 and os.clock() - lastTime < 4 do
		RunService.RenderStepped:Wait()
	end

	return v25
end

local function takePhoto()
	if not v2.aiming or v2.busy then
		return
	end

	if v2.pending then
		toast("Keep or discard the last photo first", true) -- inferred equivalent call
		return
	end

	if os.clock() < v2.cooldownUntil then
		return
	end

	v2.busy = true
	v2.cooldownUntil = os.clock() + GCamConfig.SHUTTER_COOLDOWN
	local flash = v2.flash

	Request:FireServer("Shutter")
	playShutter(LocalPlayer, flash)

	if flash then
		setLights(LocalPlayer, true) -- inferred equivalent call
		v7:SetBoost(0.1)
	end

	v2.battery = math.max(0.06, v2.battery - (flash and 0.035 or 0.015))

	hud.Visible = false
	local gCamToastGui = PlayerGui:FindFirstChild("GCamToastGui")

	if gCamToastGui then
		gCamToastGui.Enabled = false
	end

	local screenGuiSet2 = {}

	for _, childName in ipairs({ "GCamTouch", "TouchGui", "GCamIncomingGui", "GCamHolsterGui" }) do
		local screenGui = PlayerGui:FindFirstChild(childName)

		if not (screenGui and screenGui:IsA("ScreenGui") and screenGui.Enabled) then
			continue
		end

		screenGuiSet2[screenGui] = true
		screenGui.Enabled = false
	end

	RunService.RenderStepped:Wait()
	RunService.RenderStepped:Wait()
	RunService.RenderStepped:Wait()

	local recipe = buildRecipe()
	local content = captureNow()
	setLights(LocalPlayer, false) -- inferred equivalent call
	v7:SetBoost(0)
	hud.Visible = v2.aiming and not v2.hudHidden

	if gCamToastGui then
		gCamToastGui.Enabled = true
	end

	for k in pairs(screenGuiSet2) do
		if k.Parent then
			k.Enabled = true
		end
	end

	if content then
		v7:Flash(flash and 1 or 0.5)
		v7:Glitch()

		if v2.hudHidden then
			GCamGalleryStore.Add({ content = content, recipe = recipe, ts = recipe.ts })
		else
			id -= 1
			showPreview({ id = id, content = content, recipe = recipe, ts = recipe.ts })
		end
	else
		toast("The photo failed - try again", true) -- inferred equivalent call
	end

	v2.busy = false
end

local v25 = {}

local function releaseIdleFreeze()
	for k, v26 in pairs(v25) do
		if k.IsPlaying then
			pcall(function()
				k:AdjustSpeed(v26)
			end)
		end

		v25[k] = nil
	end
end

local function updateIdleFreeze()
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (animator and humanoidRootPart) then
		return
	end

	local magnitude = Vector3.new(
		humanoidRootPart.AssemblyLinearVelocity.X,
		0,
		humanoidRootPart.AssemblyLinearVelocity.Z
	).Magnitude

	if humanoid.MoveDirection.Magnitude > 0.05 or magnitude > 1.5 then
		releaseIdleFreeze()
		return
	end

	for _, v26 in ipairs(animator:GetPlayingAnimationTracks()) do
		if not (v26.Looped and v26.Length > 0 and v25[v26] == nil and (v26.Priority == Enum.AnimationPriority.Core or v26.Priority == Enum.AnimationPriority.Idle)) then
			continue
		end

		v25[v26] = v26.Speed
		v26:AdjustSpeed(0)
	end
end

RunService:BindToRenderStep("GCamShakeUndo", Enum.RenderPriority.First.Value, function()
	if cframe then
		CurrentCamera.CFrame *= cframe:Inverse()
		cframe = nil
	end
end)

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

RunService:BindToRenderStep("GCamApply", Enum.RenderPriority.Last.Value, function(p)
	CurrentCamera = Workspace.CurrentCamera

	updateHeld(p)

	if v2.aiming then
		updateIdleFreeze()

		if not v2.pending then
			if UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, GCamConfig.Pad.ZoomIn) then
				v2.targetZoom = math.clamp(v2.targetZoom + p * 1.8, GCamConfig.ZOOM_MIN, GCamConfig.ZOOM_MAX)
			elseif UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, GCamConfig.Pad.ZoomOut) then
				v2.targetZoom = math.clamp(v2.targetZoom - p * 1.8, GCamConfig.ZOOM_MIN, GCamConfig.ZOOM_MAX)
			end
		end

		v2.zoom += (v2.targetZoom - v2.zoom) * math.clamp(p * 8, 0, 1)
		CurrentCamera.FieldOfView = math.clamp(GCamConfig.BASE_FOV / v2.zoom, 5, 120)

		local now = os.clock()
		local v26 = 0.0032 * (0.6 + v2.zoom * 0.5)
		cframe = CFrame.Angles(
			math.noise(now * 0.8, 1.3) * v26 * 2,
			math.noise(now * 0.7, 7.1) * v26 * 2,
			math.noise(now * 0.5, 3.7) * v26
		)

		CurrentCamera.CFrame *= cframe
		local cframe2 = CurrentCamera.CFrame
		local fieldOfView = CurrentCamera.FieldOfView
		v3 = cframe2
		v4 = fieldOfView

		v2.battery = math.max(0.06, v2.battery - p * 0.0035)

		total += p

		if total >= 0.12 then
			total = 0
			raycastParams.FilterDescendantsInstances = { LocalPlayer.Character, gCamLocal }
			local raycastResult = Workspace:Raycast(
				CurrentCamera.CFrame.Position,
				CurrentCamera.CFrame.LookVector * 300,
				raycastParams
			)
			focus = raycastResult and raycastResult.Distance or 300
			v7:SetFocus(focus)
			frame.Size = UDim2.fromOffset(120, 84)
		end

		v7:Step(p, v2.zoom)

		frame3.BackgroundTransparency = os.clock() % 1.2 < 0.7 and 0 or 1

		v20.Text = string.format("x%.1f", v2.zoom)
		frame8.Size = UDim2.fromScale((v2.zoom - GCamConfig.ZOOM_MIN) / (GCamConfig.ZOOM_MAX - GCamConfig.ZOOM_MIN), 1)

		total2 += p

		if total2 >= 0.25 then
			total2 = 0
			updateHudSlow()
		end
	else
		v2.battery = math.min(1, v2.battery + p * 0.01)

		if next(v25) ~= nil then
			releaseIdleFreeze()
		end
	end
end)

local function changeFilter(p)
	if not v2.aiming then
		return
	end

	local v26 = #GCamConfig.Filters
	v2.filterIndex = (v2.filterIndex - 1 + p) % v26 + 1
	v7:SetFilter(currentFilter(), false) -- inferred equivalent call
	v7:Glitch()
	refreshHud()
	local v27 = v5[LocalPlayer]
	local snap = v27 and v27.handle:FindFirstChild("Snap")

	if snap then
		local clone2 = snap:Clone()
		clone2.PlaybackSpeed = 3
		clone2.Volume = 0.15
		clone2.Parent = v27.handle
		clone2:Play()
		local Debris = game:GetService("Debris")
		Debris:AddItem(clone2, 1)
	end
end

local function toggleFlash() -- 2 equivalent calls inferred from this helper
	if not v2.holding then
		return
	end

	v2.flash = not v2.flash
	Request:FireServer("Flash", v2.flash)
	refreshHud()

	if not v2.aiming then
		toast(v2.flash and "Flash ON" or "Flash OFF") -- inferred equivalent call
	end
end

local function toggleHud() -- 2 equivalent calls inferred from this helper
	if not v2.aiming then
		return
	end

	v2.hudHidden = not v2.hudHidden
	hud.Visible = not v2.hudHidden
	GCamGalleryUI.SetToastsMuted(v2.hudHidden)
end

local function holster() -- 1 equivalent call inferred from this helper
	if v2.aiming then
		fn(false)
	end

	Request:FireServer("Holster")
end

local gCamHolsterGui = Instance.new("ScreenGui")
gCamHolsterGui.Name = "GCamHolsterGui"
gCamHolsterGui.ResetOnSpawn = false
gCamHolsterGui.IgnoreGuiInset = true
gCamHolsterGui.DisplayOrder = 515
gCamHolsterGui.Enabled = false
gCamHolsterGui.Parent = PlayerGui

local frame10 = Instance.new("Frame")
frame10.AnchorPoint = Vector2.new(0.5, 0.5)
frame10.Position = UDim2.fromScale(0.5, 0.8)
frame10.Size = UDim2.fromOffset(240, 30)
frame10.BackgroundColor3 = Colors.Ink
frame10.BackgroundTransparency = 0.15
frame10.ClipsDescendants = true
frame10.Parent = gCamHolsterGui
corner(frame10) -- inferred equivalent call
stroke(frame10, Colors.Paper, 1.5, 0.2) -- inferred equivalent call

local frame11 = Instance.new("Frame")
frame11.BorderSizePixel = 0
frame11.BackgroundColor3 = Colors.Red
frame11.Size = UDim2.fromScale(0, 1)
frame11.Parent = frame10

local textLabel2 = Instance.new("TextLabel")
textLabel2.BackgroundTransparency = 1
textLabel2.Size = UDim2.fromScale(1, 1)
textLabel2.Font = Enum.Font.Arcade
textLabel2.TextSize = 15
textLabel2.TextColor3 = Colors.Paper
textLabel2.Text = "PUTTING CAMERA AWAY..."
textLabel2.ZIndex = 2
textLabel2.Parent = frame10

local count = 0

local function cancelHolsterHold() -- 2 equivalent calls inferred from this helper
	count += 1
	gCamHolsterGui.Enabled = false
end

local function startHolsterHold()
	if not v2.holding or gCamHolsterGui.Enabled then
		return
	end

	count += 1
	local v26 = count
	frame11.Size = UDim2.fromScale(0, 1)
	gCamHolsterGui.Enabled = true

	task.spawn(function()
		local lastTime = os.clock()

		while v26 == count do
			if v2.holding then
				local v27 = (os.clock() - lastTime) / GCamConfig.HOLSTER_HOLD_TIME
				frame11.Size = UDim2.fromScale(math.clamp(v27, 0, 1), 1)

				if v27 >= 1 then
					count += 1
					gCamHolsterGui.Enabled = false
					holster() -- inferred equivalent call
					toast("Camera put away") -- inferred equivalent call
					break
				end

				RunService.RenderStepped:Wait()
			else
				cancelHolsterHold() -- inferred equivalent call
				break
			end
		end
	end)
end

local lastTime = nil
local total3 = 0

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	local userInputType = input.UserInputType

	if userInputType == Enum.UserInputType.MouseButton2 then
		if v2.holding then
			lastTime = os.clock()
			total3 = 0
		end
	elseif userInputType == Enum.UserInputType.MouseButton1 then
		if v2.aiming then
			takePhoto()
		end
	elseif userInputType == Enum.UserInputType.Keyboard then
		local keyCode = input.KeyCode

		if v2.pending then
			if keyCode == GCamConfig.Keys.Keep then
				keepPhoto()
				return
			end

			if keyCode == GCamConfig.Keys.Discard then
				discardPhoto() -- inferred equivalent call
				return
			elseif keyCode == GCamConfig.Keys.Share then
				sharePending() -- inferred equivalent call
				return
			end
		end

		if v2.holding then
			if keyCode == GCamConfig.Keys.Flash then
				toggleFlash() -- inferred equivalent call
			elseif keyCode == GCamConfig.Keys.Holster then
				startHolsterHold()
			elseif v2.aiming and keyCode == GCamConfig.Keys.HideHud and not GCamGalleryUI.IsFullscreenOpen() then
				toggleHud() -- inferred equivalent call
			elseif v2.aiming and keyCode == GCamConfig.Keys.PrevFilter then
				changeFilter(-1)
			elseif v2.aiming and keyCode == GCamConfig.Keys.NextFilter then
				changeFilter(1)
			end
		end
	end
end)

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.Gamepad1 or UserInputService:GetFocusedTextBox() then
		return
	end

	local keyCode = input.KeyCode
	local pad = GCamConfig.Pad

	if v2.pending then
		if keyCode == pad.Keep then
			keepPhoto()
			return
		end

		if keyCode == pad.Discard then
			discardPhoto() -- inferred equivalent call
			return
		elseif keyCode == pad.Share then
			sharePending() -- inferred equivalent call
			return
		end
	end

	if not v2.holding then
		return
	end

	if keyCode == pad.Aim then
		fn(not v2.aiming)
	elseif keyCode == pad.Shutter then
		if v2.aiming then
			takePhoto()
		end
	elseif keyCode == pad.Flash then
		toggleFlash() -- inferred equivalent call
	elseif keyCode == pad.Holster and not (GCamGalleryUI.IsOpen() or GCamGalleryUI.IsFullscreenOpen()) then
		startHolsterHold()
	elseif v2.aiming and keyCode == pad.HideHud and not GCamGalleryUI.IsFullscreenOpen() then
		toggleHud() -- inferred equivalent call
	elseif v2.aiming and keyCode == pad.PrevFilter then
		changeFilter(-1)
	elseif v2.aiming and keyCode == pad.NextFilter then
		changeFilter(1)
	end
end)

UserInputService.InputChanged:Connect(function(input, _)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		if lastTime then
			total3 += input.Delta.Magnitude
		end
	elseif input.UserInputType == Enum.UserInputType.MouseWheel and v2.aiming and not v2.pending then
		v2.targetZoom = math.clamp(
			v2.targetZoom + input.Position.Z * GCamConfig.ZOOM_STEP,
			GCamConfig.ZOOM_MIN,
			GCamConfig.ZOOM_MAX
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == GCamConfig.Keys.Holster or input.KeyCode == GCamConfig.Pad.Holster then
		cancelHolsterHold() -- inferred equivalent call
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 and lastTime then
		local v26

		if os.clock() - lastTime < 0.3 then
			v26 = total3 < 40
		else
			v26 = false
		end

		lastTime = nil

		if v26 and v2.holding then
			fn(not v2.aiming)
		end
	end
end)

ShutterFx.OnClientEvent:Connect(function(player, p)
	if typeof(player) == "Instance" and player:IsA("Player") then
		playShutter(player, p == true)
	end
end)

Notify.OnClientEvent:Connect(function(value, p)
	if typeof(value) == "string" then
		toast(value, p == true) -- inferred equivalent call
	end
end)

ShareReceive.OnClientEvent:Connect(function(fromUserId, fromName, recipe)
	if typeof(recipe) ~= "table" or typeof(fromName) ~= "string" then
		return
	end

	local v26 = GCamGalleryStore.Add({
		recipe = recipe,
		ts = recipe.ts or os.time(),
		fromName = fromName,
		fromUserId = fromUserId,
		undeveloped = true
	})

	GCamGalleryUI.ShowIncoming(v26)
end)

ProximityPromptService.PromptShown:Connect(function(p)
	if p.Name == GCamConfig.PICKUP_PROMPT_NAME then
		p.ActionText = v2.holding and "Put Back Camera" or "Take Camera"
	end
end)

if low then
	local gCamTouch = Instance.new("ScreenGui")
	gCamTouch.Name = "GCamTouch"
	gCamTouch.ResetOnSpawn = false
	gCamTouch.DisplayOrder = 510
	gCamTouch.Enabled = false
	gCamTouch.Parent = PlayerGui

	local v26 = {}
	local function touchButton(p, text, position, value, onActivated)
		local textButton2 = Instance.new("TextButton")
		textButton2.AnchorPoint = Vector2.new(0.5, 0.5)
		textButton2.Position = position
		textButton2.Size = UDim2.fromOffset(value, value)
		textButton2.BackgroundColor3 = Colors.Ink
		textButton2.BackgroundTransparency = 0.25
		textButton2.TextColor3 = Colors.Paper
		textButton2.Font = Enum.Font.GothamBold
		textButton2.TextSize = value >= 70 and 15 or 12
		textButton2.TextWrapped = true
		textButton2.Text = text
		textButton2.AutoButtonColor = true
		textButton2.Parent = gCamTouch
		corner(textButton2, value) -- inferred equivalent call
		stroke(textButton2, Colors.Paper, 1.5, 0.3) -- inferred equivalent call
		textButton2.Activated:Connect(onActivated)
		v26[p] = textButton2
		return textButton2
	end

	touchButton("cam", "CAM", UDim2.new(1, -56, 0.26, 0), 54, function()
		fn(not v2.aiming)
	end)
	touchButton("flash", "FLASH", UDim2.new(1, -56, 0.4, 0), 50, toggleFlash)
	touchButton("shoot", "SHOOT", UDim2.new(1, -124, 0.58, 0), 86, takePhoto)
	touchButton("zoomIn", "+", UDim2.new(1, -204, 0.48, 0), 44, function()
		v2.targetZoom = math.clamp(v2.targetZoom + 0.6, GCamConfig.ZOOM_MIN, GCamConfig.ZOOM_MAX)
	end)
	touchButton("zoomOut", "-", UDim2.new(1, -204, 0.66, 0), 44, function()
		v2.targetZoom = math.clamp(v2.targetZoom - 0.6, GCamConfig.ZOOM_MIN, GCamConfig.ZOOM_MAX)
	end)

	touchButton("prev", "<", UDim2.new(0.5, -150, 0, 84), 42, function()
		changeFilter(-1)
	end)
	touchButton("next", ">", UDim2.new(0.5, 150, 0, 84), 42, function()
		changeFilter(1)
	end)
	touchButton("hud", "HUD", UDim2.new(1, -56, 0.12, 0), 44, toggleHud)
	touchButton("away", "PUT AWAY", UDim2.new(0, 60, 0.4, 0), 52, holster)

	local v27 = {
		shoot = true,
		zoomIn = true,
		zoomOut = true,
		prev = true,
		next = true,
		hud = true
	}

	task.spawn(function()
		while true do
			task.wait(0.15)
			gCamTouch.Enabled = v2.holding

			for k, v28 in pairs(v26) do
				if v2.aiming and v2.hudHidden then
					v28.Visible = k == "hud"
					v28.BackgroundTransparency = 0.8
					v28.TextTransparency = 0.5
				else
					v28.Visible = not v27[k] or v2.aiming
					v28.BackgroundTransparency = 0.25
					v28.TextTransparency = 0
				end
			end
		end
	end)
end

task.spawn(function()
	local permanent = GCamRemotes:WaitForChild("Permanent", 20)

	if not permanent then
		GCamGalleryStore.SetPermanentAvailable(false)
		return
	end

	local success, result = pcall(function()
		return permanent:InvokeServer("Get")
	end)

	if not success or typeof(result) ~= "table" then
		GCamGalleryStore.SetPermanentAvailable(false)
		return
	end

	GCamGalleryStore.SetPermanentAvailable(result.available ~= false)

	for k, v26 in pairs(result.slots or {}) do
		local v27 = tonumber(k)

		if v27 and v27 >= 1 and v27 <= GCamConfig.PERMANENT_SLOTS and typeof(v26) == "table" then
			GCamGalleryStore.SetPermanent(v27, {
				id = GCamGalleryStore.NewId(),
				recipe = v26.recipe,
				ts = v26.ts or os.time(),
				fromName = v26.fromName,
				undeveloped = true
			})
		end
	end
end)

print("[GCam] client ready")