local result = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local InputRouter = require(Modules:WaitForChild("InputRouter"))
local ModeManager = require(Modules:WaitForChild("ModeManager"))
local FreePlayController = require(Modules:WaitForChild("FreePlayController"))
local FreePlayAssetPreloader = require(Modules:WaitForChild("FreePlayAssetPreloader"))
local InstrumentLifecycleSignal = require(Modules:WaitForChild("InstrumentLifecycleSignal"))
local FreePlayKeyBindings = require(Modules:WaitForChild("FreePlayKeyBindings"))
local DrumKeybindRules = require(Modules:WaitForChild("DrumKeybindRules"))
local SettingsState = require(Modules:WaitForChild("SettingsState"))
local SessionCameraSettings = require(Modules:WaitForChild("SessionCameraSettings"))

local v = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InstrumentHUDUpdate")
local instrumentLifecycleEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("InstrumentLifecycleEvent")
local setDrumKeybinds = v.Parent:WaitForChild("SetDrumKeybinds", 10)

local localPlayer = result.LocalPlayer
result = localPlayer:WaitForChild("PlayerGui")

local v2 = {
	Cymbal = Color3.fromRGB(236, 226, 78),
	Tom = Color3.fromRGB(48, 48, 52),
	Kick = Color3.fromRGB(150, 150, 154),
	Snare = Color3.fromRGB(238, 238, 238),
	Small = Color3.fromRGB(40, 205, 45)
}

local parent2 = {
	{
		Pad = "RideEdge",
		Label = "U",
		Lanes = { 10 },
		X = 506,
		Y = 125,
		D = 104,
		Kind = "Cymbal",
		Z = 3,
		LabelAnchor = "BottomLeft"
	},
	{
		Pad = "HighCrash",
		Label = "E",
		Lanes = { 1 },
		X = 203,
		Y = 88,
		D = 84,
		Kind = "Cymbal",
		Z = 4
	},
	{
		Pad = "Splash",
		Label = "W",
		Lanes = { 2 },
		X = 311,
		Y = 103,
		D = 56,
		Kind = "Cymbal",
		Z = 4
	},
	{
		Pad = "MediumCrash",
		Label = "R",
		Lanes = { 3 },
		X = 417,
		Y = 88,
		D = 84,
		Kind = "Cymbal",
		Z = 4
	},
	{
		Pad = "FootHiHat",
		Label = "M  X",
		Lanes = { 4, 5 },
		X = 132,
		Y = 152,
		D = 76,
		Kind = "Cymbal",
		Z = 4
	},
	{
		Pad = "HighTom",
		Label = "D  F",
		Lanes = { 6, 7 },
		X = 254,
		Y = 153,
		D = 78,
		Kind = "Tom",
		Z = 4
	},
	{
		Pad = "MidTom",
		Label = "G  H",
		Lanes = { 8, 9 },
		X = 363,
		Y = 155,
		D = 78,
		Kind = "Tom",
		Z = 4
	},
	{
		Pad = "RideBell",
		Label = "I",
		Lanes = { 11 },
		X = 506,
		Y = 125,
		D = 34,
		Kind = "Small",
		Z = 6
	},
	{
		Pad = "OpenHiHat",
		Label = "Comma  Z",
		Lanes = { 12, 13 },
		X = 127,
		Y = 227,
		D = 78,
		Kind = "Cymbal",
		Z = 4
	},
	{
		Pad = "Snare",
		Label = "C  V",
		Lanes = { 14, 15 },
		X = 221,
		Y = 224,
		D = 80,
		Kind = "Snare",
		Z = 4
	},
	{
		Pad = "SideStick",
		Label = "S",
		Lanes = { 16 },
		X = 259,
		Y = 224,
		D = 28,
		Kind = "Small",
		Z = 6
	},
	{
		Pad = "BassDrum",
		Label = "B  N",
		Lanes = { 17, 18 },
		X = 306,
		Y = 224,
		D = 92,
		Kind = "Kick",
		Z = 5
	},
	{
		Pad = "FloorTom",
		Label = "J  K",
		Lanes = { 19, 20 },
		X = 418,
		Y = 224,
		D = 78,
		Kind = "Tom",
		Z = 4
	},
	{
		Pad = "China",
		Label = "O",
		Lanes = { 21 },
		X = 515,
		Y = 227,
		D = 76,
		Kind = "Cymbal",
		Z = 4
	},
	{
		Pad = "Cowbell",
		Label = "A",
		Lanes = { 22 },
		X = 313,
		Y = 152,
		D = 34,
		Kind = "Small",
		Z = 6
	}
}
local minValue = 1e999
local maxValue = -1e999
local v3 = false

for _, v4 in ipairs(parent2) do
	minValue = math.min(minValue, v4.X - v4.D / 2)
	maxValue = math.max(maxValue, v4.X + v4.D / 2)
end

local v4 = minValue + maxValue

local v5 = false

local function padCenterX(p) -- 4 equivalent calls inferred from this helper
	return v5 and v4 - p.X or p.X
end

local drumFreePlayUI = Instance.new("ScreenGui")
drumFreePlayUI.Name = "DrumFreePlayUI"
drumFreePlayUI.ResetOnSpawn = false
drumFreePlayUI.IgnoreGuiInset = false
drumFreePlayUI.DisplayOrder = 20
drumFreePlayUI.Enabled = false
drumFreePlayUI.Parent = result

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 1)
panel.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
panel.BackgroundTransparency = 1
panel.BorderSizePixel = 0
panel.Parent = drumFreePlayUI

result = Instance.new("UICorner")
result.CornerRadius = UDim.new(0, 12)
result.Parent = panel

local padArea = nil

local function layoutPanel()
	local currentCamera = Workspace.CurrentCamera
	local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
	local v6 = math.min(math.clamp(viewportSize.X * 0.66, 380, 900), viewportSize.X - 12)

	local drumPadScale = SettingsState.GetDrumPadScale()
	local v7

	if math.abs(drumPadScale - 1) > 0.001 then
		local v8 = math.min(
			math.clamp(v6 * drumPadScale, 190, (math.max(190, viewportSize.X - 12))),
			(math.max(190, (viewportSize.Y * 0.85 - 34) * 888 / 297))
		)
		v7 = math.max(v6, v8)
		v6 = v8
	else
		v7 = v6
	end

	local v8 = v6 * 297 / 888
	panel.Size = UDim2.fromOffset(v7, v8 + 34)

	if padArea then
		padArea.Size = UDim2.fromOffset(v6, v8)
	end

	panel.Position = UDim2.new(0.5, 0, 1, 0)
end

local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundTransparency = 1
header.Size = UDim2.new(1, 0, 0, 34)
header.Parent = panel

local function makeHeaderButton(name, text, backgroundColor, textColor, p, p2, p3)
	local textButton = Instance.new("TextButton")
	textButton.Name = name
	textButton.AutoButtonColor = false
	textButton.Text = text
	textButton.Font = Enum.Font.GothamBold
	textButton.TextSize = 14
	textButton.TextColor3 = textColor
	textButton.BackgroundColor3 = backgroundColor
	textButton.BorderSizePixel = 0
	textButton.AnchorPoint = Vector2.new(p2, 0.5)
	textButton.Position = UDim2.new(p2 == 1 and 1 or 0, p3, 0.5, 0)
	textButton.Size = UDim2.fromOffset(p, 26)
	textButton.Parent = header
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 6)
	uiCorner.Parent = textButton
	return textButton
end

local headerButton = makeHeaderButton("Kit", "KIT", Color3.fromRGB(38, 38, 42), Color3.fromRGB(235, 235, 235), 56, 0, 8)
result = makeHeaderButton("Close", "CLOSE", Color3.fromRGB(190, 48, 48), Color3.new(1, 1, 1), 70, 1, -8)

local TouchEnabled = UserInputService.TouchEnabled
local v6 = TouchEnabled and 72 or 164
local size2 = TouchEnabled and 72 or 84
local v7 = v6 + size2 + 8

local v8 = v7 + 56 + 8 + (TouchEnabled and 52 or 56) + 8

do
	local headerButton2 = makeHeaderButton(
		"Tabs",
		"MENU",
		Color3.fromRGB(38, 120, 220),
		Color3.new(1, 1, 1),
		TouchEnabled and 52 or 56,
		0,
		v7 + 56 + 8
	)
	headerButton2.TextSize = TouchEnabled and 12 or 14
	headerButton2.Activated:Connect(function()
		local success, result2 = pcall(function()
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			return require(ReplicatedStorage2.Modules:WaitForChild("TabsMenu", 5))
		end)

		if success then
			result2.Toggle(headerButton2)
		else
			warn("[MENU] gagal memuat TabsMenu:", result2)
		end
	end)
end

local v9 = {}

do
	local function closePopupsExcept(p) -- 3 equivalent calls inferred from this helper
		for k, v10 in pairs(v9) do
			if k ~= p then
				v10()
			end
		end
	end
end

local v10 = TouchEnabled and 96 or 124
local v11 = v10 + 8
local color = Color3.fromRGB(38, 38, 42)
local color2 = Color3.fromRGB(40, 150, 60)
local headerButton2 = makeHeaderButton("Overlap", "OVERLAP: OFF", color, Color3.fromRGB(235, 235, 235), v10, 1, -86)
headerButton2.TextSize = TouchEnabled and 12 or 14
local v12 = nil
local v13 = nil
local hint = nil

if TouchEnabled then
	v12 = makeHeaderButton("Choke", "CHOKE", Color3.fromRGB(70, 70, 78), Color3.new(1, 1, 1), 78, 1, -86 - v11)
	v13 = makeHeaderButton("Stick", "STICK", Color3.fromRGB(70, 70, 78), Color3.new(1, 1, 1), 78, 1, -170 - v11)
else
	hint = Instance.new("TextLabel")
	hint.Name = "Hint"
	hint.BackgroundTransparency = 1
	hint.Text = "SPACE  Choke      L CTRL  Stick click"
	hint.Font = Enum.Font.Gotham
	hint.TextSize = 13
	hint.TextColor3 = Color3.fromRGB(170, 170, 178)

	local v14 = 86 + v10 + 8
	hint.AnchorPoint = Vector2.new(0, 0.5)
	hint.Position = UDim2.new(0, v8, 0.5, 0)
	hint.Size = UDim2.new(1, -(v8 + v14), 1, 0)
	hint.TextWrapped = true
	hint.TextScaled = true
	v14 = Instance.new("UITextSizeConstraint")
	v14.MaxTextSize = 13
	v14.MinTextSize = 8
	v14.Parent = hint
	hint.Parent = header
end

padArea = Instance.new("Frame")
padArea.Name = "PadArea"
padArea.BackgroundTransparency = 1
padArea.AnchorPoint = Vector2.new(0.5, 0)
padArea.Position = UDim2.new(0.5, 0, 0, 34)
padArea.Size = UDim2.new(1, 0, 1, -34)
padArea.ClipsDescendants = true
padArea.Parent = panel

local parent3 = Instance.new("UICorner")
parent3.CornerRadius = UDim.new(0, 10)
parent3.Parent = padArea

parent3 = Instance.new("ViewportFrame")
parent3.Name = "KitRender"
parent3.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
parent3.BackgroundTransparency = 1
parent3.BorderSizePixel = 0
parent3.Size = UDim2.fromScale(1, 1)
parent3.Ambient = Color3.fromRGB(190, 190, 190)
parent3.LightColor = Color3.fromRGB(255, 244, 225)
parent3.LightDirection = Vector3.new(-0.4, -1, -0.5)
parent3.ZIndex = 1
parent3.Visible = false
parent3.Parent = padArea

Instance.new("WorldModel").Parent = parent3
local currentCamera2 = Instance.new("Camera")
currentCamera2.FieldOfView = 55
currentCamera2.Parent = parent3
parent3.CurrentCamera = currentCamera2

parent3 = Instance.new("Frame")
parent3.Name = "Dim"
parent3.BackgroundColor3 = Color3.new(0, 0, 0)
parent3.BackgroundTransparency = 1
parent3.Visible = false
parent3.BorderSizePixel = 0
parent3.Size = UDim2.fromScale(1, 1)
parent3.ZIndex = 2
parent3.Parent = padArea

local v14 = nil

local function findKit()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local seatPart = humanoid and humanoid.SeatPart
	local v15 = seatPart

	while v15 and v15 ~= Workspace do
		local drumKIT = v15:FindFirstChild("DrumKIT", true)

		if drumKIT then
			return drumKIT, seatPart
		end

		v15 = v15.Parent
	end

	return Workspace:FindFirstChild("DrumKIT", true), seatPart
end

local fn

do
	local function buildKit() -- 1 equivalent call inferred from this helper
		if v14 then
			v14:Destroy()
			v14 = nil
		end

		local kit, _ = findKit()

		if fn then
			local v15 = fn

			if not (kit and kit:IsA("Model") and kit) then
				kit = nil
			end

			v15(kit)
		end
	end
end

local v15 = {}

local function pressedColorFor(data)
	local r = data.R
	local g = data.G
	local b = data.B

	if (r + g + b) / 3 > 0.6 then
		return data:Lerp(Color3.fromRGB(255, 140, 20), 0.55)
	end

	return data:Lerp(Color3.new(1, 1, 1), 0.5)
end

local color3 = Color3.fromRGB(255, 200, 70)

do
	local function setPadVisual(data) -- 2 equivalent calls inferred from this helper
		if data.Count > 0 then
			data.Button.BackgroundColor3 = data.HasRender and color3 or data.Pressed
			data.Button.BackgroundTransparency = data.HasRender and 0.45 or 0
		else
			data.Button.BackgroundColor3 = data.Base
			data.Button.BackgroundTransparency = data.HasRender and 1 or 0
		end
	end
end

do
	local function releaseHeldInput(p) -- 3 equivalent calls inferred from this helper
		local v16 = v15[p]

		if not v16 then
			return
		end

		v15[p] = nil
		InputRouter.HandleRelease(v16.Lane)
	end
end

do
	local function isPointerInput(input): boolean -- 2 equivalent calls inferred from this helper
		return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
	end
end

local padFrames = {}
local v16 = {}

for _, spec in ipairs(parent2) do
	local v17 = v2[spec.Kind]
	local textButton = Instance.new("TextButton")
	textButton.Name = spec.Pad
	textButton.AutoButtonColor = false
	textButton.AnchorPoint = Vector2.new(0.5, 0.5)
	textButton.Position = UDim2.fromScale((padCenterX(spec) + 121) / 888, spec.Y / 297) -- inferred equivalent call
	textButton.Size = UDim2.fromScale(spec.D / 888, spec.D / 297)
	textButton.BackgroundColor3 = v17
	textButton.BorderSizePixel = 0
	textButton.ZIndex = 20 + spec.Z * 2 + 1
	textButton.Font = Enum.Font.GothamBold
	textButton.TextScaled = true
	textButton.Text = spec.Label
	textButton.TextColor3 = Color3.new(1, 1, 1)
	textButton.Parent = padArea

	local v18 = Instance.new("UICorner")
	v18.CornerRadius = UDim.new(0.5, 0)
	v18.Parent = textButton

	v18 = Instance.new("UIStroke")
	v18.Color = Color3.fromRGB(10, 10, 10)
	v18.Thickness = 2
	v18.Transparency = 0
	v18.Parent = textButton

	v18 = Instance.new("UIPadding")
	v18.PaddingTop = UDim.new(0.3, 0)
	v18.PaddingBottom = UDim.new(0.3, 0)
	v18.PaddingLeft = UDim.new(0.14, 0)
	v18.PaddingRight = UDim.new(0.14, 0)
	v18.Parent = textButton

	if spec.LabelAnchor == "BottomLeft" then
		textButton.TextXAlignment = Enum.TextXAlignment.Left
		textButton.TextYAlignment = Enum.TextYAlignment.Bottom
		v18.PaddingLeft = UDim.new(0.12, 0)
		v18.PaddingTop = UDim.new(0.55, 0)
		v18.PaddingBottom = UDim.new(0.12, 0)
		v18.PaddingRight = UDim.new(0.6, 0)
	end

	v18 = Instance.new("ViewportFrame")
	v18.Name = spec.Pad .. "Render"
	v18.AnchorPoint = textButton.AnchorPoint
	v18.Position = textButton.Position
	v18.Size = textButton.Size
	v18.BackgroundTransparency = 1
	v18.BorderSizePixel = 0
	v18.Ambient = Color3.fromRGB(185, 185, 185)
	v18.LightColor = Color3.fromRGB(255, 255, 255)
	v18.ZIndex = 20 + spec.Z * 2
	v18.Visible = false
	v18.Parent = padArea

	local world = Instance.new("UICorner")
	world.CornerRadius = UDim.new(0.5, 0)
	world.Parent = v18

	world = Instance.new("WorldModel")
	world.Parent = v18
	local camera = Instance.new("Camera")
	camera.FieldOfView = 20
	camera.Parent = v18
	v18.CurrentCamera = camera

	local v19 = {
		Button = textButton,
		Base = v17,
		Pressed = pressedColorFor(v17),
		Count = 0,
		Spec = spec,
		Viewport = v18,
		World = world,
		Camera = camera,
		HasRender = false
	}

	padFrames[spec.Pad] = v19

	textButton:SetAttribute("TabsLanes", table.concat(spec.Lanes, ","))
	textButton:SetAttribute("TabsGuideSibling", true)

	for _, lane in ipairs(spec.Lanes) do
		v16[lane] = v19
	end

	textButton.InputBegan:Connect(function(input)
		if
			v3
			or input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
			or v15[input]
		then
			return
		end

		local lane = spec.Lanes[1]
		v15[input] = { Lane = lane }
		InputRouter.HandlePress(lane)
	end)
end

do
	local v17 = {
		HighCrash = { Group = "crash", Part = "cymbal" },
		MediumCrash = { Group = "crash", Part = "cymbal" },
		Splash = { Group = "crash", Part = "cymbal" },
		China = { Group = "crash", Part = "cymbal" },
		RideEdge = { Group = "ride", Part = "cymbal" },
		RideBell = { Group = "ride", Part = "cymbal", Zoom = 0.33 },
		FootHiHat = { Group = "hi hat", Part = "hattop" },
		OpenHiHat = { Group = "hi hat", Part = "hatbottom" },
		HighTom = { Group = "hi tom", Part = "batter" },
		MidTom = { Group = "mid tom", Part = "batter" },
		FloorTom = { Group = "floor", Part = "batter" },
		Snare = { Group = "snare", Part = "batter" },
		SideStick = { Group = "snare", Part = "batter", Zoom = 0.3, Edge = 0.95 },
		BassDrum = { Group = "kick", Part = "kickbatter" },
		Cowbell = { Group = "prop", Part = "model" }
	}

	local function findGroup(instance, group)
		for _, child in ipairs(instance:GetChildren()) do
			if string.find(string.lower(child.Name), group, 1, true) then
				return child
			end
		end

		return nil
	end

	local function findNamedPart(folder, value)
		local v18 = string.lower(value)

		for _, part in ipairs(folder:GetDescendants()) do
			if part:IsA("BasePart") and string.lower(part.Name) == v18 then
				return part
			end
		end

		return nil
	end

	local function thinNormal(instance) -- 5 equivalent calls inferred from this helper
		local size = instance.Size
		local v18 = size.X
		local v19

		if size.Y < v18 then
			v18 = size.Y
			v19 = Vector3.new(0, 1, 0)
		else
			v19 = Vector3.new(1, 0, 0)
		end

		local v20 = size.Z < v18 and Vector3.new(0, 0, 1) or v19

		local vectorToWorldSpace = instance.CFrame:VectorToWorldSpace(v20)

		if vectorToWorldSpace.Y < 0 then
			vectorToWorldSpace = -vectorToWorldSpace
		end

		return vectorToWorldSpace.Unit
	end

	local function findBatter(folder)
		local parts = {}

		for _, part in ipairs(folder:GetDescendants()) do
			if not (part:IsA("BasePart") and part:FindFirstChildOfClass("Decal")) then
				continue
			end

			local size = part.Size

			if math.min(size.X, size.Y, size.Z) <= 0.06 then
				table.insert(parts, part)
			end
		end

		table.sort(parts, function(a, b): boolean
			return a.Position.Y > b.Position.Y
		end)

		local v18 = parts[1]

		if not v18 then
			return nil
		end

		local v19 = parts[2] and v18.Position - parts[2].Position or thinNormal(v18) -- inferred equivalent call

		if v19.Magnitude < 0.01 then
			v19 = thinNormal(v18) -- inferred equivalent call
		end

		return v18, v19.Unit
	end

	local function findKickBatter(p)
		local namedPart = findNamedPart(p, "Batter Head")

		if not namedPart then
			return nil
		end

		local namedPart2 = findNamedPart(p, "Reso Head")
		local v18 = namedPart2 and namedPart.Position - namedPart2.Position or thinNormal(namedPart) -- inferred equivalent call

		if v18.Magnitude < 0.01 then
			v18 = thinNormal(namedPart) -- inferred equivalent call
		end

		return namedPart, v18.Unit
	end

	local function cleanClone(folder)
		for _, descendant in ipairs(folder:GetDescendants()) do
			if not (descendant:IsA("LuaSourceContainer") or descendant:IsA("Sound") or descendant:IsA("ProximityPrompt") or descendant:IsA("Light")) then
				continue
			end

			descendant:Destroy()
		end

		if folder:IsA("BasePart") then
			folder.Anchored = true
		end

		for _, part in ipairs(folder:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end
	end

	local function aimPadCamera(state, p, position, p2, p3)
		local v18 = math.abs(p2.Y) > 0.5 and Vector3.new(0, 0, -1) or Vector3.new(0, 1, 0)

		local v19 = position + CFrame.lookAt(position + p2, position, v18).RightVector * ((p.Edge or 0) * p3 * 0.5)
		local v20 = p3 * (p.Zoom or 1) * 1.04 * 0.5 / 0.17632698070846498
		local cframe = CFrame.lookAt(v19 + p2 * v20, v19, v18)
		state.Camera.CFrame = cframe
		state.Viewport.LightDirection = (cframe.LookVector - cframe.UpVector * 0.4 + cframe.RightVector * 0.3).Unit
	end

	local function renderPad(state, p)
		local v18 = v17[state.Spec.Pad]
		state.World:ClearAllChildren()
		state.HasRender = false
		state.Viewport.Visible = false

		local v19 = p and v18 and findGroup(p, v18.Group)

		if v19 then
			local v20 = nil
			local v21 = nil
			local position = nil
			local v22 = nil

			if v18.Part == "cymbal" then
				v20 = findNamedPart(v19, "piring")
			elseif v18.Part == "hattop" then
				v20 = findNamedPart(v19, "piring atas")
			elseif v18.Part == "hatbottom" then
				v20 = findNamedPart(v19, "piring bawah")
			elseif v18.Part == "batter" then
				v20, v21 = findBatter(v19)
			elseif v18.Part == "kickbatter" then
				v20, v21 = findKickBatter(v19)
			end

			if v18.Part == "model" then
				local clone = v19:Clone()
				cleanClone(clone)
				clone.Parent = state.World
				local boundingBox, v23 = v19:GetBoundingBox()
				position = boundingBox.Position
				v22 = math.sqrt(v23.X * v23.X + v23.Z * v23.Z)
				v21 = Vector3.new(0, 1, 0)
			elseif v20 then
				local clone = v20:Clone()
				cleanClone(clone)
				clone.Parent = state.World
				position = v20.Position
				v22 = math.max(v20.Size.X, v20.Size.Y, v20.Size.Z)

				if not v21 then
					v21 = thinNormal(v20) -- inferred equivalent call
				end
			end

			if position and v21 and v22 and v22 > 0 then
				aimPadCamera(state, v18, position, v21, v22)
				state.HasRender = true
				state.Viewport.Visible = true
			end
		end

		setPadVisual(state) -- inferred equivalent call
	end

	fn = function(p)
		for _, v18 in pairs(padFrames) do
			renderPad(v18, p)
		end
	end
end

UserInputService.InputEnded:Connect(function(input)
	if v15[input] then
		releaseHeldInput(input) -- inferred equivalent call
	end
end)

InputRouter.OnLaneEvent(function(p, p2)
	local v17 = v16[p]

	if not v17 then
		return
	end

	if p2 then
		v17.Count += 1
	else
		v17.Count = math.max(0, v17.Count - 1)
	end

	setPadVisual(v17) -- inferred equivalent call
end)

local color4 = Color3.fromRGB(170, 170, 178)
local color5 = Color3.fromRGB(255, 120, 120)

local v17 = {
	HighCrash = "High Crash",
	Splash = "Splash",
	MediumCrash = "Medium Crash",
	FootHiHat = "Foot Hi-Hat",
	HighTom = "High Tom",
	MidTom = "Mid Tom",
	RideEdge = "Ride",
	RideBell = "Ride Bell",
	OpenHiHat = "Open Hi-Hat",
	Snare = "Snare",
	SideStick = "Side Stick",
	BassDrum = "Bass Drum",
	FloorTom = "Floor Tom",
	China = "China",
	Cowbell = "Cowbell"
}

local v18 = nil
local v19 = {}
local count = 0
local v20 = nil
local v21 = nil

do
	local function padNameForLane(p) -- 6 equivalent calls inferred from this helper
		local v22 = v16[p]
		local pad = v22 and v22.Spec.Pad
		return v17[pad] or pad or "another pad"
	end
end

do
	local function setHint(text, p) -- 6 equivalent calls inferred from this helper
		if hint then
			hint.Text = text
			hint.TextColor3 = p or color4
		end
	end
end

do
	local function currentHint()
		if v3 and v20 then
			return v20.Message
		end

		if v3 and v18 then
			return string.format("Press a new key for %s  -  ESC to cancel", padNameForLane(v18)) -- inferred equivalent call
		elseif v3 then
			return "Click a key, then press its new key  -  ESC to cancel"
		else
			return "SPACE  Choke      L CTRL  Stick click"
		end
	end
end

do
	local function flashError(text) -- 2 equivalent calls inferred from this helper
		count += 1
		local v22 = count
		setHint(text, color5) -- inferred equivalent call
		task.delay(2.5, function()
			if count == v22 then
				local v23, v24

				if v3 and v20 then
					v23 = v20.Message
				elseif v3 and v18 then
					v23, v24 = string.format("Press a new key for %s  -  ESC to cancel", padNameForLane(v18)) -- inferred equivalent call
				elseif v3 then
					v23 = "Click a key, then press its new key  -  ESC to cancel"
				else
					v23 = "SPACE  Choke      L CTRL  Stick click"
				end

				setHint(v23, v24) -- inferred equivalent call
			end
		end)
	end
end

local function keyLabel(lane) -- 1 equivalent call inferred from this helper
	return DrumKeybindRules.DisplayName(FreePlayKeyBindings.Drum[lane].Name)
end

local function refreshPadLabels()
	for _, v22 in pairs(padFrames) do
		if v3 then
			v22.Button.Text = ""
		else
			local v23 = {}

			for _, lane in ipairs(v22.Spec.Lanes) do
				table.insert(v23, keyLabel(lane))
			end

			v22.Button.Text = table.concat(v23, "  ")
		end
	end
end

local function refreshChips()
	for k, v22 in pairs(v19) do
		local v23 = v18 == k
		v22.Button.Text = v23 and "..." or keyLabel(k) -- inferred equivalent call
		v22.Button.BackgroundColor3 = v23 and Color3.fromRGB(70, 52, 10) or Color3.fromRGB(18, 18, 22)
		v22.Stroke.Color = v23 and Color3.fromRGB(255, 200, 70) or Color3.fromRGB(255, 255, 255)
		v22.Stroke.Thickness = v23 and 2.5 or 1.5
		v22.Stroke.Transparency = v23 and 0 or 0.55
	end
end

local function refreshAll() -- 6 equivalent calls inferred from this helper
	refreshPadLabels()
	refreshChips()
end

do
	local function clearPendingSwap() -- 4 equivalent calls inferred from this helper
		v20 = nil

		if v21 then
			v21.Visible = false
		end
	end
end

do
	local function selectLane(p) -- 6 equivalent calls inferred from this helper
		clearPendingSwap() -- inferred equivalent call
		v18 = p
		count += 1
		refreshChips()
		local v22, v23

		if v3 and v20 then
			v22 = v20.Message
		elseif v3 and v18 then
			v22, v23 = string.format("Press a new key for %s  -  ESC to cancel", padNameForLane(v18)) -- inferred equivalent call
		elseif v3 then
			v22 = "Click a key, then press its new key  -  ESC to cancel"
		else
			v22 = "SPACE  Choke      L CTRL  Stick click"
		end

		setHint(v22, v23) -- inferred equivalent call
	end
end

do
	local function currentKeyNames() -- 1 equivalent call inferred from this helper
		local names = {}

		for i = 1, DrumKeybindRules.LANE_COUNT do
			names[i] = FreePlayKeyBindings.Drum[i].Name
		end

		return names
	end
end

do
	local function sendKeybinds() -- 3 equivalent calls inferred from this helper
		if setDrumKeybinds then
			setDrumKeybinds:FireServer(currentKeyNames()) -- inferred equivalent call
		end
	end
end

local function applyKeyNames(list): boolean
	if not DrumKeybindRules.Validate(list) then
		return false
	end

	for i = 1, DrumKeybindRules.LANE_COUNT do
		FreePlayKeyBindings.Drum[i] = Enum.KeyCode[list[i]]
	end

	return true
end

local v22 = nil
local v23 = nil

local function setEditMode(visible)
	if v3 == visible then
		return
	end

	v3 = visible
	v18 = nil
	clearPendingSwap() -- inferred equivalent call
	count += 1

	if visible then
		for k in pairs(v15) do
			releaseHeldInput(k) -- inferred equivalent call
		end
	end

	if InputRouter.SetInputCaptured then
		InputRouter.SetInputCaptured(visible)
	end

	for _, v24 in pairs(v19) do
		v24.Button.Visible = visible
	end

	if v22 then
		v22.Text = visible and "DONE" or "KEYBIND"
		v22.BackgroundColor3 = visible and Color3.fromRGB(40, 150, 60) or Color3.fromRGB(38, 38, 42)
	end

	if v23 then
		v23.Visible = visible
	end

	if hint and not TouchEnabled then
		local v24 = visible and 164 or v8
		local v25 = visible and 162 + v11 + 64 + 8 or 86 + v10 + 8
		hint.Position = UDim2.new(0, v24, 0.5, 0)
		hint.Size = UDim2.new(1, -(v24 + v25), 1, 0)

		for _, childName in ipairs({ "Tuning", "Eq" }) do
			local child = hint.Parent and hint.Parent:FindFirstChild(childName)

			if child then
				child.Visible = not visible
			end
		end
	end

	refreshAll() -- inferred equivalent call
	local v24, v25

	if v3 and v20 then
		v24 = v20.Message
	elseif v3 and v18 then
		v24, v25 = string.format("Press a new key for %s  -  ESC to cancel", padNameForLane(v18)) -- inferred equivalent call
	elseif v3 then
		v24 = "Click a key, then press its new key  -  ESC to cancel"
	else
		v24 = "SPACE  Choke      L CTRL  Stick click"
	end

	setHint(v24, v25) -- inferred equivalent call
end

do
	local function resetToDefaults()
		applyKeyNames(DrumKeybindRules.Defaults)
		selectLane(nil) -- inferred equivalent call
		refreshAll() -- inferred equivalent call
		sendKeybinds() -- inferred equivalent call
	end

	local function confirmSwap()
		local v24 = v20

		if not v24 then
			return
		end

		if FreePlayKeyBindings.Drum[v24.Other] == v24.KeyCode then
			local v25 = FreePlayKeyBindings.Drum[v24.Lane]
			FreePlayKeyBindings.Drum[v24.Lane] = v24.KeyCode
			FreePlayKeyBindings.Drum[v24.Other] = v25
			selectLane(nil) -- inferred equivalent call
			refreshAll() -- inferred equivalent call
			sendKeybinds() -- inferred equivalent call
		else
			clearPendingSwap() -- inferred equivalent call
			local v25, v26

			if v3 and v20 then
				v25 = v20.Message
			elseif v3 and v18 then
				v25, v26 = string.format("Press a new key for %s  -  ESC to cancel", padNameForLane(v18)) -- inferred equivalent call
			elseif v3 then
				v25 = "Click a key, then press its new key  -  ESC to cancel"
			else
				v25 = "SPACE  Choke      L CTRL  Stick click"
			end

			setHint(v25, v26) -- inferred equivalent call
		end
	end

	if not TouchEnabled then
		v22 = makeHeaderButton(
			"Keybind",
			"KEYBIND",
			Color3.fromRGB(38, 38, 42),
			Color3.fromRGB(235, 235, 235),
			84,
			0,
			72
		)
		v23 = makeHeaderButton("Reset", "RESET", Color3.fromRGB(70, 70, 78), Color3.new(1, 1, 1), 70, 1, -86 - v11)
		v23.Visible = false
		v21 = makeHeaderButton("Swap", "SWAP", Color3.fromRGB(200, 120, 30), Color3.new(1, 1, 1), 64, 1, -162 - v11)
		v21.Visible = false
		v21.Activated:Connect(confirmSwap)

		v22.Activated:Connect(function()
			setEditMode(not v3)
		end)
		v23.Activated:Connect(resetToDefaults)

		local v24 = {
			RideEdge = { side = -1, caption = "EDGE" },
			RideBell = { side = 1, caption = "BELL" }
		}

		for _, spec in ipairs(parent2) do
			local v25 = #spec.Lanes

			for i, lane in ipairs(spec.Lanes) do
				local v26 = spec.D

				local stroke = v24[spec.Pad]
				local dx, v27, v28

				if stroke then
					dx = stroke.side * 23
					v27 = 40
					v28 = 34
				elseif spec.Kind == "Small" then
					v27 = v26 * 0.9
					v28 = v26 * 0.8
					dx = 0
				elseif v25 == 1 then
					v27 = v26 * 0.62
					v28 = v26 * 0.4
					dx = 0
				else
					v27 = v26 * 0.44
					v28 = v26 * 0.38
					dx = (i == 1 and -1 or 1) * v26 * 0.24
				end

				v26 = Instance.new("TextButton")
				v26.Name = spec.Pad .. "_Key" .. i
				v26.AutoButtonColor = false
				v26.AnchorPoint = Vector2.new(0.5, 0.5)
				v26.Position = UDim2.fromScale((padCenterX(spec) + 121 + dx) / 888, spec.Y / 297) -- inferred equivalent call
				v26.Size = UDim2.fromScale(v27 / 888, v28 / 297)
				v26.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
				v26.BackgroundTransparency = 0.1
				v26.BorderSizePixel = 0
				v26.Font = Enum.Font.GothamBold
				v26.TextScaled = true
				v26.TextColor3 = Color3.new(1, 1, 1)
				v26.Text = ""
				v26.ZIndex = 60 + spec.Z
				v26.Visible = false
				v26.Parent = padArea

				v27 = Instance.new("UICorner")
				v27.CornerRadius = UDim.new(0.25, 0)
				v27.Parent = v26

				if stroke then
					local caption = Instance.new("TextLabel")
					caption.Name = "Caption"
					caption.BackgroundTransparency = 1
					caption.AnchorPoint = Vector2.new(0.5, 0)
					caption.Position = UDim2.new(0.5, 0, 1.2, 0)
					caption.Size = UDim2.new(1.3, 0, 0.42, 0)
					caption.Font = Enum.Font.GothamBold
					caption.TextScaled = true
					caption.Text = stroke.caption
					caption.TextColor3 = Color3.fromRGB(235, 235, 235)
					caption.TextTransparency = 0.15
					caption.TextStrokeColor3 = Color3.new(0, 0, 0)
					caption.TextStrokeTransparency = 0.35
					caption.ZIndex = v26.ZIndex
					caption.Parent = v26
				end

				stroke = Instance.new("UIPadding")
				stroke.PaddingTop = UDim.new(0.12, 0)
				stroke.PaddingBottom = UDim.new(0.12, 0)
				stroke.PaddingLeft = UDim.new(0.08, 0)
				stroke.PaddingRight = UDim.new(0.08, 0)
				stroke.Parent = v26

				stroke = Instance.new("UIStroke")
				stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				stroke.Parent = v26

				v19[lane] = { Button = v26, Stroke = stroke, Spec = spec, Dx = dx }
				local v29 = lane
				v26.Activated:Connect(function()
					if v18 == v29 then
						selectLane(nil) -- inferred equivalent call
					else
						selectLane(v29) -- inferred equivalent call
					end
				end)
			end
		end

		UserInputService.InputBegan:Connect(function(input)
			if
				not (v3 and v18)
				or input.UserInputType ~= Enum.UserInputType.Keyboard
				or UserInputService:GetFocusedTextBox()
			then
				return
			end

			local keyCode = input.KeyCode
			local name = keyCode.Name
			clearPendingSwap() -- inferred equivalent call

			if keyCode == Enum.KeyCode.Escape then
				selectLane(nil) -- inferred equivalent call
			elseif DrumKeybindRules.IsModifierName(name) then
				flashError("Shift, Ctrl and Alt can't be used as drum keys.") -- inferred equivalent call
			elseif DrumKeybindRules.IsAllowedName(name) then
				local lane = v18

				for i = 1, DrumKeybindRules.LANE_COUNT do
					if i ~= lane and FreePlayKeyBindings.Drum[i] == keyCode then
						v20 = {
							Lane = lane,
							Other = i,
							KeyCode = keyCode,
							Message = string.format(
								"\"%s\" is already used by %s. Swap keys?",
								DrumKeybindRules.DisplayName(name),
								padNameForLane(i) -- inferred equivalent call
							)
						}

						if v21 then
							v21.Visible = true
						end

						count += 1
						setHint(v20.Message, color5) -- inferred equivalent call
						return
					end
				end

				if FreePlayKeyBindings.Drum[lane] ~= keyCode then
					FreePlayKeyBindings.Drum[lane] = keyCode
					sendKeybinds() -- inferred equivalent call
				end

				selectLane(nil) -- inferred equivalent call
				refreshAll() -- inferred equivalent call
			else
				flashError("That key is reserved. Use a letter, number or punctuation key.") -- inferred equivalent call
			end
		end)
	end
end

do
	local function loadSavedKeybinds()
		local drumKeybinds = localPlayer:GetAttribute("DrumKeybinds")

		if typeof(drumKeybinds) ~= "string" then
			return
		end

		local success, result2 = pcall(function()
			return HttpService:JSONDecode(drumKeybinds)
		end)

		if success and applyKeyNames(result2) then
			refreshAll() -- inferred equivalent call
		end
	end
	loadSavedKeybinds()
	localPlayer:GetAttributeChangedSignal("DrumKeybinds"):Connect(loadSavedKeybinds)
end

refreshAll() -- inferred equivalent call

local function onPointer(p, callback) -- 5 equivalent calls inferred from this helper
	p.InputBegan:Connect(function(input)
		if isPointerInput(input) then -- inferred equivalent call
			callback()
		end
	end)
end

do
	local function fn2()
		ModeManager.SetRhythm()
	end

	result.InputBegan:Connect(function(input)
		if isPointerInput(input) then -- inferred equivalent call
			fn2()
		end
	end)
end

do
	local function fireStickClick()
		local v24 = { InstrumentType = "Drum", Lifecycle = "ManualStickClick" }
		InstrumentLifecycleSignal:Fire(v24)
		instrumentLifecycleEvent:FireServer(v24)
	end

	if v12 then
		local function fn2()
			InputRouter.HandleMute()
		end

		onPointer(v12, fn2) -- inferred equivalent call
		InputRouter.OnMuteEvent(function()
			v12.BackgroundColor3 = Color3.fromRGB(190, 120, 30)
			TweenService:Create(v12, TweenInfo.new(0.25), {
				BackgroundColor3 = Color3.fromRGB(70, 70, 78)
			}):Play()
		end)
	end

	if v13 then
		onPointer(v13, fireStickClick) -- inferred equivalent call
	end
end

local function refreshOverlapButton() -- 2 equivalent calls inferred from this helper
	local overlap = FreePlayController.GetOverlap()
	headerButton2.Text = overlap and "OVERLAP: ON" or "OVERLAP: OFF"
	headerButton2.BackgroundColor3 = overlap and color2 or color
end

do
	local function fn2()
		FreePlayController.SetOverlap(not FreePlayController.GetOverlap())
		refreshOverlapButton() -- inferred equivalent call
	end

	onPointer(headerButton2, fn2) -- inferred equivalent call
end

do
	local FreePlaySyncState = require(Modules:WaitForChild("FreePlaySyncState"))
	local ThemeSwitchToast = require(Modules:WaitForChild("ThemeSwitchToast"))
	local v24 = ThemeSwitchToast.new(drumFreePlayUI)

	local headerButton3 = makeHeaderButton(
		"Sync",
		"SYNC: OFF",
		color,
		Color3.fromRGB(235, 235, 235),
		TouchEnabled and 88 or 108,
		1,
		-8
	)
	headerButton3.TextSize = TouchEnabled and 12 or 14

	headerButton3.AnchorPoint = Vector2.new(1, 1)
	headerButton3.Position = UDim2.new(1, -8, 0, -4)

	local function refreshSync()
		local isEnabled = FreePlaySyncState.IsEnabled()
		headerButton3.Text = isEnabled and "SYNC: ON" or "SYNC: OFF"
		headerButton3.BackgroundColor3 = isEnabled and color2 or color
	end
	FreePlaySyncState.OnChanged(refreshSync)
	result = FreePlaySyncState.IsEnabled()
	headerButton3.Text = result and "SYNC: ON" or "SYNC: OFF"

	if result then
		result = color2 or color
	else
		result = color
	end

	headerButton3.BackgroundColor3 = result

	local function fn2()
		local v25 = not FreePlaySyncState.IsEnabled()
		FreePlaySyncState.SetEnabled(v25)
		v24:Show(v25 and "Sync ON - others delayed " .. FreePlaySyncState.GetDelayMs() .. " ms" or "Sync OFF")
	end

	onPointer(headerButton3, fn2) -- inferred equivalent call
	local laptopOpenFromSongList = v.Parent:WaitForChild("LaptopOpenFromSongList", 10)

	result = makeHeaderButton(
		"Metronome",
		"METRONOME",
		color,
		Color3.fromRGB(235, 235, 235),
		TouchEnabled and 96 or 112,
		1,
		-8
	)
	result.TextSize = TouchEnabled and 12 or 14
	result.AnchorPoint = Vector2.new(1, 1)
	result.Position = UDim2.new(1, -(8 + (TouchEnabled and 88 or 108) + 6), 0, -4)

	local v25 = false
	local function fn3()
		if v25 or not laptopOpenFromSongList then
			return
		end

		v25 = true
		localPlayer:SetAttribute("LaptopOpenTab", "metro")
		local success, result2 = pcall(function()
			return laptopOpenFromSongList:InvokeServer()
		end)

		v25 = false

		if not (success and result2) then
			localPlayer:SetAttribute("LaptopOpenTab", nil)
			v24:Show("Laptop unavailable (in use or not on a stage)")
		end
	end

	onPointer(result, fn3) -- inferred equivalent call
end

do
	local FreePlaySoundAdapter = require(Modules:WaitForChild("FreePlaySoundAdapter"))
	local DRUM_TUNING_ORDER = FreePlaySoundAdapter.DRUM_TUNING_ORDER
	local DRUM_TUNING_STEP_CENTS = FreePlaySoundAdapter.DRUM_TUNING_STEP_CENTS
	local DRUM_TUNING_MAX_CENTS = FreePlaySoundAdapter.DRUM_TUNING_MAX_CENTS

	local color6 = Color3.fromRGB(38, 38, 42)
	result = Color3.fromRGB(70, 70, 78)
	local color7 = Color3.fromRGB(40, 150, 60)
	local color8 = Color3.fromRGB(66, 200, 120)
	local color9 = Color3.fromRGB(235, 235, 235)
	Color3.fromRGB(170, 170, 178)

	local v24 = {}
	local v25 = false
	local v26 = true
	local v27 = {
		{
			Name = "Standard",
			Snare = 0,
			HighTom = 0,
			MidTom = 0,
			FloorTom = 0,
			BassDrum = 0
		},
		{
			Name = "Deep Rock",
			Snare = -1,
			HighTom = -2,
			MidTom = -2.5,
			FloorTom = -3,
			BassDrum = -2
		},
		{
			Name = "Tight Funk",
			Snare = 1.5,
			HighTom = 2.5,
			MidTom = 2,
			FloorTom = 1.5,
			BassDrum = 1
		},
		{
			Name = "High Jazz",
			Snare = 1,
			HighTom = 3.5,
			MidTom = 3,
			FloorTom = 2.5,
			BassDrum = 2
		},
		{
			Name = "Punk",
			Snare = 2,
			HighTom = 1.5,
			MidTom = 1,
			FloorTom = 0,
			BassDrum = 0.5
		},
		{
			Name = "Metal",
			Snare = 1.5,
			HighTom = -1,
			MidTom = -2,
			FloorTom = -3,
			BassDrum = -1.5
		},
		{
			Name = "Grindcore",
			Snare = 3,
			HighTom = 0.5,
			MidTom = -0.5,
			FloorTom = -1.5,
			BassDrum = 1
		},
		{
			Name = "Slam Metal",
			Snare = -2,
			HighTom = -3.5,
			MidTom = -4.5,
			FloorTom = -5.5,
			BassDrum = -4
		},
		{
			Name = "Blast Beats",
			Snare = 2.5,
			HighTom = 1,
			MidTom = 0,
			FloorTom = -1,
			BassDrum = 2
		}
	}

	for _, v28 in ipairs(DRUM_TUNING_ORDER) do
		v24[v28] = 0
	end

	local function commit()
		local v28 = {}
		local v29 = false

		for _, v30 in ipairs(DRUM_TUNING_ORDER) do
			if v24[v30] == 0 then
				continue
			end

			v28[v30] = v24[v30]
			v29 = true
		end

		FreePlaySoundAdapter.SetLocalDrumTuning(v29 and v28 or nil)
	end

	local function formatValue(p) -- 1 equivalent call inferred from this helper
		if p == 0 then
			return "0"
		end

		return string.format("%+.1f", p / 100)
	end

	local function corner(parent, p) -- 3 equivalent calls inferred from this helper
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, p)
		uiCorner.Parent = parent
	end

	local function newButton(parent, text, size, position, p)
		local textButton = Instance.new("TextButton")
		textButton.AutoButtonColor = false
		textButton.Text = text
		textButton.Font = Enum.Font.GothamBold
		textButton.TextSize = 13
		textButton.TextColor3 = color9
		textButton.BackgroundColor3 = p or color6
		textButton.BorderSizePixel = 0
		textButton.Size = size
		textButton.Position = position
		textButton.Parent = parent
		corner(textButton, 6) -- inferred equivalent call
		return textButton
	end

	local function newLabel(frame, text, size, position, p, value) -- 1 equivalent call inferred from this helper
		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.Text = text
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextSize = value or 12
		textLabel.TextColor3 = color9
		textLabel.TextXAlignment = p or Enum.TextXAlignment.Left
		textLabel.Size = size
		textLabel.Position = position
		textLabel.Parent = frame
		return textLabel
	end

	local function makeCheckbox(parent, text, size, position, value)
		local textButton = Instance.new("TextButton")
		textButton.AutoButtonColor = false
		textButton.Text = ""
		textButton.BackgroundTransparency = 1
		textButton.Size = size
		textButton.Position = position
		textButton.Parent = parent
		local frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0, 0.5)
		frame.Position = UDim2.new(0, 0, 0.5, 0)
		frame.Size = UDim2.fromOffset(18, 18)
		frame.BackgroundColor3 = color6
		frame.BorderSizePixel = 0
		frame.Parent = textButton
		corner(frame, 4) -- inferred equivalent call
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = Color3.fromRGB(120, 120, 128)
		uiStroke.Thickness = 1.5
		uiStroke.Parent = frame
		local frame2 = Instance.new("Frame")
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		frame2.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame2.Size = UDim2.fromOffset(10, 10)
		frame2.BackgroundColor3 = color8
		frame2.BorderSizePixel = 0
		frame2.Visible = false
		frame2.Parent = frame
		corner(frame2, 3) -- inferred equivalent call
		local textLabel = newLabel( -- inferred equivalent call
			textButton,
			text,
			UDim2.new(1, -24, 1, 0),
			UDim2.fromOffset(24, 0),
			Enum.TextXAlignment.Left,
			value
		)
		return textButton, function(visible)
			frame2.Visible = visible
			textLabel.TextColor3 = visible and color8 or color9
		end
	end

	local headerButton3 = makeHeaderButton("Tuning", "TUNING", color6, color9, size2, 0, v6)
	headerButton3.TextSize = TouchEnabled and 12 or 14

	local tuningHolder = Instance.new("Frame")
	tuningHolder.Name = "TuningHolder"
	tuningHolder.BackgroundTransparency = 1
	tuningHolder.AnchorPoint = Vector2.new(0, 1)
	tuningHolder.Size = UDim2.fromOffset(290, 286)
	tuningHolder.Position = UDim2.fromOffset(v6, -6)
	tuningHolder.Visible = false
	tuningHolder.ZIndex = 200
	tuningHolder.Parent = panel

	local tuningPopup = Instance.new("Frame")
	tuningPopup.Name = "TuningPopup"
	tuningPopup.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
	tuningPopup.BackgroundTransparency = 0.04
	tuningPopup.BorderSizePixel = 0
	tuningPopup.Size = UDim2.fromOffset(290, 286)
	tuningPopup.Position = UDim2.fromOffset(0, 0)
	tuningPopup.ZIndex = 200
	tuningPopup.Parent = tuningHolder
	parent2 = Instance.new("UICorner")
	parent2.CornerRadius = UDim.new(0, 10)
	parent2.Parent = tuningPopup

	parent2 = Instance.new("UIStroke")
	parent2.Color = result
	parent2.Thickness = 1.5
	parent2.Parent = tuningPopup
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = tuningPopup
	parent2 = Instance.new("UIPadding")
	parent2.PaddingTop = UDim.new(0, 8)
	parent2.PaddingBottom = UDim.new(0, 8)
	parent2.PaddingLeft = UDim.new(0, 8)
	parent2.PaddingRight = UDim.new(0, 8)
	parent2.Parent = tuningPopup

	parent2 = Instance.new("Frame")
	parent2.BackgroundTransparency = 1
	parent2.Size = UDim2.new(1, 0, 0, 28)
	parent2.Parent = tuningPopup
	size2 = UDim2.new(1, -96, 1, 0)
	v13 = UDim2.fromOffset(0, 0)
	parent3 = Enum.TextXAlignment.Left
	currentCamera2 = Instance.new("TextLabel")
	currentCamera2.BackgroundTransparency = 1
	currentCamera2.Text = "DRUM TUNING"
	currentCamera2.Font = Enum.Font.GothamBold
	currentCamera2.TextSize = 14
	currentCamera2.TextColor3 = color9
	currentCamera2.TextXAlignment = parent3 or Enum.TextXAlignment.Left
	currentCamera2.Size = size2
	currentCamera2.Position = v13
	currentCamera2.Parent = parent2

	size2 = UDim2.fromOffset(56, 24)
	v13 = UDim2.new(1, -90, 0.5, -12)
	parent3 = Instance.new("TextButton")
	parent3.AutoButtonColor = false
	parent3.Text = "RESET"
	parent3.Font = Enum.Font.GothamBold
	parent3.TextSize = 13
	parent3.TextColor3 = color9
	parent3.BackgroundColor3 = result or color6
	parent3.BorderSizePixel = 0
	parent3.Size = size2
	parent3.Position = v13
	parent3.Parent = parent2
	size2 = Instance.new("UICorner")
	size2.CornerRadius = UDim.new(0, 6)
	size2.Parent = parent3

	parent3.TextSize = 12
	size2 = UDim2.fromOffset(26, 24)
	v13 = UDim2.new(1, -26, 0.5, -12)
	currentCamera2 = Color3.fromRGB(190, 48, 48)
	local textButton = Instance.new("TextButton")
	textButton.AutoButtonColor = false
	textButton.Text = "X"
	textButton.Font = Enum.Font.GothamBold
	textButton.TextSize = 13
	textButton.TextColor3 = color9
	textButton.BackgroundColor3 = currentCamera2 or color6
	textButton.BorderSizePixel = 0
	textButton.Size = size2
	textButton.Position = v13
	textButton.Parent = parent2
	parent2 = Instance.new("UICorner")
	parent2.CornerRadius = UDim.new(0, 6)
	parent2.Parent = textButton

	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Position = UDim2.fromOffset(0, 32)
	frame.Size = UDim2.new(1, 0, 1, -32)
	frame.Parent = tuningPopup
	parent2 = Instance.new("UIListLayout")
	parent2.Padding = UDim.new(0, 4)
	parent2.SortOrder = Enum.SortOrder.LayoutOrder
	parent2.Parent = frame

	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.Position = UDim2.fromOffset(0, 32)
	scrollingFrame.Size = UDim2.new(1, 0, 1, -32)
	scrollingFrame.ScrollBarThickness = 4
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.Visible = false
	scrollingFrame.Parent = tuningPopup
	parent2 = Instance.new("UIListLayout")
	parent2.Padding = UDim.new(0, 4)
	parent2.SortOrder = Enum.SortOrder.LayoutOrder
	parent2.Parent = scrollingFrame

	local fn2

	local function clampCents(value) -- 5 equivalent calls inferred from this helper
		return (math.clamp(value, -DRUM_TUNING_MAX_CENTS, DRUM_TUNING_MAX_CENTS))
	end

	local function change(p, p2)
		if v25 then
			for _, v28 in ipairs(DRUM_TUNING_ORDER) do
				if v28 ~= "SideStick" or not v26 then
					v24[v28] = clampCents(v24[v28] + p2) -- inferred equivalent call
				end
			end

			if v26 then
				v24.SideStick = v24.Snare
			end
		elseif p == "SideStick" then
			v26 = false
			v24.SideStick = clampCents(v24.SideStick + p2) -- inferred equivalent call
		else
			v24[p] = clampCents(v24[p] + p2) -- inferred equivalent call

			if p == "Snare" and v26 then
				v24.SideStick = v24.Snare
			end
		end

		commit()
		fn2()
	end

	parent2 = Instance.new("Frame")
	parent2.BackgroundTransparency = 1
	parent2.Size = UDim2.new(1, 0, 0, 26)
	parent2.LayoutOrder = 1
	parent2.Parent = frame
	local checkbox, v28 = makeCheckbox(
		parent2,
		"TUNE ALL (move every drum together)",
		UDim2.new(1, 0, 1, 0),
		UDim2.fromOffset(0, 0),
		11
	)
	checkbox.Activated:Connect(function()
		v25 = not v25
		fn2()
	end)

	local v29 = {}
	local v30 = nil

	for i, v31 in ipairs(DRUM_TUNING_ORDER) do
		local frame2 = Instance.new("Frame")
		frame2.Name = v31 .. "Row"
		frame2.BackgroundTransparency = 1
		frame2.Size = UDim2.new(1, 0, 0, 26)
		frame2.LayoutOrder = i + 1
		frame2.Parent = frame
		newLabel(
			frame2,
			v17[v31] or v31,
			UDim2.fromOffset(80, 26),
			UDim2.fromOffset(0, 0),
			Enum.TextXAlignment.Left,
			12
		)
		local v32 = newButton(frame2, "-", UDim2.fromOffset(26, 26), UDim2.fromOffset(84, 0))
		local v41 = newLabel(
			frame2,
			"0",
			UDim2.fromOffset(50, 26),
			UDim2.fromOffset(114, 0),
			Enum.TextXAlignment.Center,
			13
		)
		local v42 = newButton(frame2, "+", UDim2.fromOffset(26, 26), UDim2.fromOffset(168, 0))
		v32.Activated:Connect(function()
			change(v31, -DRUM_TUNING_STEP_CENTS)
		end)
		v42.Activated:Connect(function()
			change(v31, DRUM_TUNING_STEP_CENTS)
		end)
		v29[v31] = v41

		if v31 ~= "SideStick" then
			continue
		end

		local v43
		v43, v30 = makeCheckbox(frame2, "= SNARE", UDim2.fromOffset(74, 26), UDim2.fromOffset(200, 0), 10)

		v43.Activated:Connect(function()
			v26 = not v26

			if v26 then
				v24.SideStick = v24.Snare
				commit()
			end

			fn2()
		end)
	end

	parent2 = newButton(frame, "PRESETS", UDim2.new(1, 0, 0, 28), UDim2.fromOffset(0, 0), color7)
	parent2.LayoutOrder = 20

	size2 = newButton(scrollingFrame, "< BACK", UDim2.new(1, -8, 0, 26), UDim2.fromOffset(0, 0), result)
	size2.LayoutOrder = 0
	local v31 = {}

	for i, v32 in ipairs(v27) do
		local parent = newButton(scrollingFrame, v32.Name, UDim2.new(1, -8, 0, 26), UDim2.fromOffset(0, 0), color6)
		parent.LayoutOrder = i
		v31[i] = parent
		parent.Activated:Connect(function()
			for _, v42 in ipairs(DRUM_TUNING_ORDER) do
				v24[v42] = clampCents(math.round((v32[v42] or 0) * 100 / DRUM_TUNING_STEP_CENTS) * DRUM_TUNING_STEP_CENTS) -- inferred equivalent call
			end

			v24.SideStick = v24.Snare
			v26 = true
			commit()
			fn2()
		end)
	end

	local function presetMatches(p): boolean
		for _, v32 in ipairs(DRUM_TUNING_ORDER) do
			local v41

			if v32 == "SideStick" then
				v41 = p.Snare or 0
			else
				v41 = p[v32] or 0
			end

			if v24[v32] ~= clampCents(math.round(v41 * 100 / DRUM_TUNING_STEP_CENTS) * DRUM_TUNING_STEP_CENTS) then -- inferred equivalent call
				return false
			end
		end

		return true
	end

	fn2 = function()
		for _, v32 in ipairs(DRUM_TUNING_ORDER) do
			local v41 = v29[v32]
			v41.Text = formatValue(v24[v32]) -- inferred equivalent call
			v41.TextColor3 = v24[v32] ~= 0 and color8 or color9
		end

		v28(v25)
		v30(v26)

		for i, v32 in ipairs(v27) do
			v31[i].BackgroundColor3 = presetMatches(v32) and color7 or color6
		end
	end

	local function showView(p)
		frame.Visible = p == "tuning"
		scrollingFrame.Visible = p == "presets"
	end
	parent2.Activated:Connect(function()
		frame.Visible = false
		scrollingFrame.Visible = true
	end)
	size2.Activated:Connect(function()
		frame.Visible = true
		scrollingFrame.Visible = false
	end)

	local function layoutPopup()
		local currentCamera = Workspace.CurrentCamera
		local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
		local offset = panel.Size.X.Offset
		local offset2 = panel.Size.Y.Offset
		local scale = math.max(math.min(1, (viewportSize.Y - offset2 - 60) / 286, (viewportSize.X - 12) / 290), 0.5)
		uiScale.Scale = scale
		tuningHolder.Size = UDim2.fromOffset(scale * 290, scale * 286)
		local v32 = (viewportSize.X - offset) / 2
		local v42 = 6 - v32
		local v43 = viewportSize.X - 6 - v32 - scale * 290
		local v44 = math.clamp(v6, v42, (math.max(v42, v43)))
		tuningHolder.Position = UDim2.fromOffset(v44, -6)
	end

	local function setOpen(visible) -- 5 equivalent calls inferred from this helper
		tuningHolder.Visible = visible
		headerButton3.BackgroundColor3 = visible and color7 or color6

		if visible then
			closePopupsExcept("tuning") -- inferred equivalent call
			frame.Visible = true
			scrollingFrame.Visible = false

			layoutPopup()
			fn2()
		end
	end
	function v9.tuning()
		setOpen(false) -- inferred equivalent call
	end

	headerButton3.Activated:Connect(function()
		setOpen(not tuningHolder.Visible) -- inferred equivalent call
	end)
	textButton.Activated:Connect(function()
		setOpen(false) -- inferred equivalent call
	end)

	local function resetState() -- 1 equivalent call inferred from this helper
		for _, v32 in ipairs(DRUM_TUNING_ORDER) do
			v24[v32] = 0
		end

		v26 = true
		commit()
		fn2()
	end
	parent3.Activated:Connect(resetState)

	v.OnClientEvent:Connect(function()
		v25 = false
		resetState() -- inferred equivalent call
		setOpen(false) -- inferred equivalent call
	end)

	local function hiddenOnlyForKitLoading()
		local v32 = isEquipped

		if not v32 then
			return v32
		end

		if currentType == "Drum" then
			v32 = ModeManager.IsFreePlay()

			if v32 then
				if
					drumFreePlayUI:GetAttribute("HiddenByLaptop") == true
					or FreePlayAssetPreloader.IsPreloaded("Drum", FreePlayController.GetCurrentTone()) ~= true
				then
					return false
				end

				return not kitBundlesReady()
			end
		else
			return false
		end

		return v32
	end

	drumFreePlayUI:GetPropertyChangedSignal("Enabled"):Connect(function()
		if drumFreePlayUI.Enabled then
			if tuningHolder.Visible then
				layoutPopup()
				fn2()
			end
		elseif not hiddenOnlyForKitLoading() then
			setOpen(false) -- inferred equivalent call
		end
	end)
	panel:GetPropertyChangedSignal("Size"):Connect(layoutPopup)

	for _, guiObject in ipairs(tuningPopup:GetDescendants()) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local v32 = guiObject
		local count2 = 0

		while v32 and v32 ~= tuningPopup do
			count2 += 1
			v32 = v32.Parent
		end

		guiObject.ZIndex = 200 + count2
	end

	fn2()
	layoutPopup()
end

local v24 = false
local v25 = nil

do
	local function releaseAllHeld() -- 1 equivalent call inferred from this helper
		for k in pairs(v15) do
			releaseHeldInput(k) -- inferred equivalent call
		end
	end
end

local function fn2(): boolean
	return true
end

local function refreshVisibility()
	local v26

	if v25 == "Drum" and FreePlayAssetPreloader.IsPreloaded("Drum", FreePlayController.GetCurrentTone()) == true then
		v26 = fn2()
	else
		v26 = false
	end

	local enabled = v24

	if enabled then
		if v25 == "Drum" then
			enabled = ModeManager.IsFreePlay() and v26 and drumFreePlayUI:GetAttribute("HiddenByLaptop") ~= true
		else
			enabled = false
		end
	end

	if enabled and not drumFreePlayUI.Enabled then
		layoutPanel()
		buildKit() -- inferred equivalent call
	end

	if not enabled then
		releaseAllHeld() -- inferred equivalent call
		setEditMode(false)
	end

	drumFreePlayUI.Enabled = enabled
	refreshOverlapButton() -- inferred equivalent call
end

v.OnClientEvent:Connect(function(p, p2)
	v24 = p == true
	v25 = v24 and p2 or nil
	refreshVisibility()
	task.defer(refreshOverlapButton)
	task.defer(refreshVisibility)
end)

ModeManager.OnChanged(function()
	refreshVisibility()
end)

result = require(Modules:WaitForChild("LaptopUI"):WaitForChild("LaptopClientController"))
result.OnEnter(function()
	drumFreePlayUI:SetAttribute("HiddenByLaptop", true)
	refreshVisibility()
end)
result.OnExit(function()
	drumFreePlayUI:SetAttribute("HiddenByLaptop", nil)
	refreshVisibility()
end)

FreePlayAssetPreloader.OnPreloadComplete(function()
	refreshVisibility()
end)

do
	local FreePlayDrumKits = require(Modules:WaitForChild("FreePlayDrumKits"))
	local FreePlaySoundAdapter = require(Modules:WaitForChild("FreePlaySoundAdapter"))
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")

	local pads = FreePlayDrumKits.PADS

	local color6 = Color3.fromRGB(38, 38, 42)
	result = Color3.fromRGB(70, 70, 78)
	local color7 = Color3.fromRGB(40, 150, 60)
	local color8 = Color3.fromRGB(235, 235, 235)

	local v26 = {}

	for _, pad in ipairs(pads) do
		v26[pad] = { Kit = FreePlayDrumKits.DEFAULT, Velocity = 1 }
	end

	local v27 = false
	local saveFreePlayDrumKitSelection = nil
	local count2 = 0

	local function nonDefault()
		local v28 = {}
		local v29 = false

		for _, pad in ipairs(pads) do
			local v30 = v26[pad]

			if v30.Kit == FreePlayDrumKits.DEFAULT then
				continue
			end

			v28[pad] = { Kit = v30.Kit, Velocity = v30.Velocity }
			v29 = true
		end

		return v29 and v28 or nil
	end

	local function scheduleSave() -- 5 equivalent calls inferred from this helper
		count2 += 1
		local v28 = count2
		task.delay(0.6, function()
			if v28 == count2 and saveFreePlayDrumKitSelection then
				saveFreePlayDrumKitSelection:FireServer(nonDefault() or {})
			end
		end)
	end

	local function commit(p) -- 5 equivalent calls inferred from this helper
		FreePlaySoundAdapter.SetLocalDrumSelection(nonDefault())

		if p then
			v27 = true
			scheduleSave() -- inferred equivalent call
		end
	end

	local function bundleKeyOf(p) -- 3 equivalent calls inferred from this helper
		local v28 = v26[p]

		if v28.Kit == FreePlayDrumKits.DEFAULT then
			return nil
		end

		return FreePlayDrumKits.BundleKey(v28.Kit, p)
	end

	fn2 = function(): boolean
		for _, pad in ipairs(pads) do
			local v28 = bundleKeyOf(pad) -- inferred equivalent call

			if v28 and FreePlayAssetPreloader.IsPreloaded("Drum", v28) ~= true then
				return false
			end
		end

		return true
	end

	local function ensurePadLoaded(p) -- 2 equivalent calls inferred from this helper
		local v28 = bundleKeyOf(p) -- inferred equivalent call

		if v28 and FreePlayAssetPreloader.IsPreloaded("Drum", v28) ~= true then
			FreePlayAssetPreloader.EnsureLoaded("Drum", v28, "Loading drum kit...")
		end
	end

	local function ensureSelectedLoaded() -- 2 equivalent calls inferred from this helper
		for _, pad in ipairs(pads) do
			ensurePadLoaded(pad) -- inferred equivalent call
		end
	end

	local function corner(textButton, p) -- 1 equivalent call inferred from this helper
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, p)
		uiCorner.Parent = textButton
	end

	local function newButton(parent, text, size, position, p) -- 5 equivalent calls inferred from this helper
		local textButton = Instance.new("TextButton")
		textButton.AutoButtonColor = false
		textButton.Text = text
		textButton.Font = Enum.Font.GothamBold
		textButton.TextSize = 13
		textButton.TextColor3 = color8
		textButton.BackgroundColor3 = p or color6
		textButton.BorderSizePixel = 0
		textButton.Size = size
		textButton.Position = position
		textButton.Parent = parent
		corner(textButton, 6) -- inferred equivalent call
		return textButton
	end

	local function newLabel(parent, text, size, position, left, value) -- 2 equivalent calls inferred from this helper
		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.Text = text
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextSize = value or 12
		textLabel.TextColor3 = color8
		textLabel.TextXAlignment = left or Enum.TextXAlignment.Left
		textLabel.Size = size
		textLabel.Position = position
		textLabel.Parent = parent
		return textLabel
	end

	local kitHolder = Instance.new("Frame")
	kitHolder.Name = "KitHolder"
	kitHolder.BackgroundTransparency = 1
	kitHolder.AnchorPoint = Vector2.new(0, 1)
	kitHolder.Size = UDim2.fromOffset(340, 404)
	kitHolder.Position = UDim2.fromOffset(8, -6)
	kitHolder.Visible = false
	kitHolder.ZIndex = 200
	kitHolder.Parent = panel

	local kitPopup = Instance.new("Frame")
	kitPopup.Name = "KitPopup"
	kitPopup.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
	kitPopup.BackgroundTransparency = 0.04
	kitPopup.BorderSizePixel = 0
	kitPopup.Size = UDim2.fromOffset(340, 404)
	kitPopup.Position = UDim2.fromOffset(0, 0)
	kitPopup.ZIndex = 200
	kitPopup.Parent = kitHolder
	parent2 = Instance.new("UICorner")
	parent2.CornerRadius = UDim.new(0, 10)
	parent2.Parent = kitPopup

	parent2 = Instance.new("UIStroke")
	parent2.Color = result
	parent2.Thickness = 1.5
	parent2.Parent = kitPopup
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = kitPopup
	parent2 = Instance.new("UIPadding")
	parent2.PaddingTop = UDim.new(0, 8)
	parent2.PaddingBottom = UDim.new(0, 8)
	parent2.PaddingLeft = UDim.new(0, 8)
	parent2.PaddingRight = UDim.new(0, 8)
	parent2.Parent = kitPopup

	local function applyZ(folder)
		local function setZ(guiObject) -- 2 equivalent calls inferred from this helper
			if guiObject:IsA("GuiObject") then
				local v28 = guiObject
				local count3 = 0

				while v28 and v28 ~= kitPopup do
					count3 += 1
					v28 = v28.Parent
				end

				guiObject.ZIndex = count3 + 200
			end
		end

		setZ(folder) -- inferred equivalent call

		for _, descendant in ipairs(folder:GetDescendants()) do
			setZ(descendant) -- inferred equivalent call
		end
	end

	parent2 = Instance.new("Frame")
	parent2.BackgroundTransparency = 1
	parent2.Size = UDim2.new(1, 0, 0, 28)
	parent2.Parent = kitPopup
	size2 = UDim2.fromOffset(28, 24)
	v13 = UDim2.new(0, 0, 0.5, -12)
	local parent4 = newButton(parent2, "<", size2, v13, result) -- inferred equivalent call
	parent4.Visible = false
	local v28 = newLabel(
		parent2,
		"KIT",
		UDim2.new(1, -150, 1, 0),
		UDim2.fromOffset(34, 0),
		Enum.TextXAlignment.Left,
		14
	)
	local parent5 = newButton(parent2, "PRESETS", UDim2.fromOffset(72, 24), UDim2.new(1, -104, 0.5, -12), color7)
	parent5.TextSize = 12
	size2 = newButton(parent2, "X", UDim2.fromOffset(26, 24), UDim2.new(1, -26, 0.5, -12), Color3.fromRGB(190, 48, 48))

	local function newPage(name)
		local scrollingFrame = Instance.new("ScrollingFrame")
		scrollingFrame.Name = name
		scrollingFrame.BackgroundTransparency = 1
		scrollingFrame.BorderSizePixel = 0
		scrollingFrame.Position = UDim2.fromOffset(0, 32)
		scrollingFrame.Size = UDim2.new(1, 0, 1, -64)
		scrollingFrame.ScrollBarThickness = 4
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
		scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scrollingFrame.Visible = false
		scrollingFrame.Parent = kitPopup
		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.Padding = UDim.new(0, 4)
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout.Parent = scrollingFrame
		return scrollingFrame
	end

	local main = newPage("MainPage")
	local presets = newPage("PresetPage")
	local kits = newPage("KitListPage")
	local v29 = { main = main, presets = presets, kits = kits }
	local v30 = nil

	local fn3
	local fn4
	local fn5

	local function fn6(p, text, p2)
		for k, v31 in pairs(v29) do
			v31.Visible = k == p
		end

		v28.Text = text
		v30 = p2
		parent4.Visible = p2 ~= nil
		parent5.Visible = p == "main"
	end

	local function fn7()
		fn6("main", "KIT", nil)
	end

	local function fn8(p)
		fn6("cat:" .. p.Name, p.Name, fn7)
	end

	parent4.Activated:Connect(function()
		if v30 then
			v30()
		end
	end)

	local v31 = {}

	local function makePadRow(parent, layoutOrder, text, pad, p)
		local frame = Instance.new("Frame")
		frame.Name = pad .. "Row"
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.new(1, -8, 0, 28)
		frame.LayoutOrder = layoutOrder
		frame.Parent = parent
		newLabel(frame, text, UDim2.fromOffset(74, 28), UDim2.fromOffset(0, 0), Enum.TextXAlignment.Left) -- inferred equivalent call
		local kit = newButton(frame, "", UDim2.fromOffset(128, 28), UDim2.fromOffset(78, 0), color6) -- inferred equivalent call
		kit.TextSize = 11
		kit.TextTruncate = Enum.TextTruncate.AtEnd
		local udim = UDim2.fromOffset(24, 28)
		local udim2, v32 = UDim2.fromOffset(212, 0)
		local minus = newButton(frame, "-", udim, udim2, v32) -- inferred equivalent call
		local textLabel = newLabel( -- inferred equivalent call
			frame,
			"",
			UDim2.fromOffset(40, 28),
			UDim2.fromOffset(238, 0),
			Enum.TextXAlignment.Center,
			13
		)
		local udim3 = UDim2.fromOffset(24, 28)
		local udim4, v58 = UDim2.fromOffset(280, 0)
		local plus = newButton(frame, "+", udim3, udim4, v58) -- inferred equivalent call
		kit.Activated:Connect(function()
			fn3(pad, p)
		end)
		minus.Activated:Connect(function()
			fn5(pad, -1)
		end)
		plus.Activated:Connect(function()
			fn5(pad, 1)
		end)
		v31[pad] = { Kit = kit, Minus = minus, Value = textLabel, Plus = plus }
	end

	for i, v32 in ipairs(FreePlayDrumKits.CATEGORIES) do
		if #v32.Pads == 1 then
			local pad = v32.Pads[1]
			makePadRow(main, i, v32.Name, pad, fn7)
		else
			local parent = newButton(main, v32.Name .. "   >", UDim2.new(1, -8, 0, 28), UDim2.fromOffset(0, 0), color6)
			parent.LayoutOrder = i
			parent.TextXAlignment = Enum.TextXAlignment.Left
			local uiPadding = Instance.new("UIPadding")
			uiPadding.PaddingLeft = UDim.new(0, 10)
			uiPadding.Parent = parent
			local parent6 = newPage("CatPage_" .. v32.Name)
			v29["cat:" .. v32.Name] = parent6
			local function backToCategory()
				fn8(v32)
			end

			for j, pad in ipairs(v32.Pads) do
				makePadRow(parent6, j, FreePlayDrumKits.PAD_DISPLAY_NAME[pad] or pad, pad, backToCategory)
			end

			parent.Activated:Connect(backToCategory)
		end
	end

	parent2 = newButton(presets, "< BACK", UDim2.new(1, -8, 0, 28), UDim2.fromOffset(0, 0), result)
	parent2.LayoutOrder = 0
	parent2.Activated:Connect(function()
		fn7()
	end)

	for i, v32 in ipairs({
		{ Name = "Normal", Kits = {} }
	}) do
		local parent = newButton(presets, v32.Name, UDim2.new(1, -8, 0, 28), UDim2.fromOffset(0, 0), color6)
		parent.LayoutOrder = i
		parent.Activated:Connect(function()
			for _, pad in ipairs(pads) do
				v26[pad] = { Kit = FreePlayDrumKits.DEFAULT, Velocity = 1 }
			end

			for k, kit in pairs(v32.Kits) do
				if not (v26[k] and type(kit) == "table" and FreePlayDrumKits.PadHasKit(kit.Kit, k)) then
					continue
				end

				local layerCount = FreePlayDrumKits.GetLayerCount(kit.Kit, k)
				v26[k] = {
					Kit = kit.Kit,
					Velocity = math.clamp(math.floor(tonumber(kit.Velocity) or 1), 1, layerCount)
				}
			end

			commit(false) -- inferred equivalent call
			v27 = true
			scheduleSave() -- inferred equivalent call
			ensureSelectedLoaded() -- inferred equivalent call
			refreshVisibility()
			fn4()
			fn7()
		end)
	end

	parent5.Activated:Connect(function()
		fn6("presets", "PRESETS", fn7)
	end)

	local function fn9(p, kit)
		if not FreePlayDrumKits.PadHasKit(kit, p) then
			return
		end

		local v32 = v26[p]

		if v32.Kit ~= kit then
			v32.Kit = kit
			v32.Velocity = 1
		end

		commit(false) -- inferred equivalent call
		v27 = true
		scheduleSave() -- inferred equivalent call
		ensurePadLoaded(p) -- inferred equivalent call
		refreshVisibility()
		fn4()
	end

	fn5 = function(p, p2)
		local v32 = v26[p]
		local layerCount = FreePlayDrumKits.GetLayerCount(v32.Kit, p)

		if layerCount <= 1 then
			return
		end

		local velocity = math.clamp(v32.Velocity + p2, 1, layerCount)

		if velocity ~= v32.Velocity then
			v32.Velocity = velocity
			commit(false) -- inferred equivalent call
			v27 = true
			scheduleSave() -- inferred equivalent call
			fn4()
		end
	end

	fn3 = function(p, callback)
		for _, button in ipairs(kits:GetChildren()) do
			if button:IsA("TextButton") then
				button:Destroy()
			end
		end

		local kit = v26[p].Kit

		for i, v32 in ipairs(FreePlayDrumKits.GetPadKits(p)) do
			local parent = newButton( -- inferred equivalent call
				kits,
				FreePlayDrumKits.DISPLAY_NAME[v32] or v32,
				UDim2.new(1, -8, 0, 28),
				UDim2.fromOffset(0, 0),
				v32 == kit and color7 or color6
			)
			parent.LayoutOrder = i
			parent.TextXAlignment = Enum.TextXAlignment.Left
			local uiPadding = Instance.new("UIPadding")
			uiPadding.PaddingLeft = UDim.new(0, 10)
			uiPadding.Parent = parent
			parent.Activated:Connect(function()
				fn9(p, v32)

				if callback then
					callback()
				else
					fn7()
				end
			end)
			applyZ(parent)
		end

		fn6("kits", (FreePlayDrumKits.PAD_DISPLAY_NAME[p] or p) .. " kit", callback or fn7)
	end

	fn4 = function()
		for k, v32 in pairs(v31) do
			local v55 = v26[k]
			v32.Kit.Text = FreePlayDrumKits.DISPLAY_NAME[v55.Kit] or v55.Kit
			v32.Kit.BackgroundColor3 = v55.Kit ~= FreePlayDrumKits.DEFAULT and color7 or color6
			local layerCount = FreePlayDrumKits.GetLayerCount(v55.Kit, k)
			local visible = layerCount > 1
			v32.Minus.Visible = visible
			v32.Value.Visible = visible
			v32.Plus.Visible = visible

			if not visible then
				continue
			end

			v32.Value.Text = FreePlayDrumKits.GetLayerLabel(v55.Kit, k, v55.Velocity) or tostring(v55.Velocity)
			local v57 = v55.Velocity <= 1
			local v58 = layerCount <= v55.Velocity
			v32.Minus.BackgroundTransparency = v57 and 0.6 or 0
			v32.Minus.TextTransparency = v57 and 0.6 or 0
			v32.Plus.BackgroundTransparency = v58 and 0.6 or 0
			v32.Plus.TextTransparency = v58 and 0.6 or 0
		end
	end

	local function layoutPopup()
		local currentCamera = Workspace.CurrentCamera
		local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
		local offset = panel.Size.X.Offset
		local offset2 = panel.Size.Y.Offset
		local scale = math.max(math.min(1, (viewportSize.Y - offset2 - 60) / 404, (viewportSize.X - 12) / 340), 0.5)
		uiScale.Scale = scale
		kitHolder.Size = UDim2.fromOffset(scale * 340, scale * 404)
		local v32 = (viewportSize.X - offset) / 2
		local v56 = 6 - v32
		local v57 = viewportSize.X - 6 - v32 - scale * 340
		kitHolder.Position = UDim2.fromOffset(math.clamp(8, v56, (math.max(v56, v57))), -6)
	end

	local function setOpen(visible) -- 5 equivalent calls inferred from this helper
		kitHolder.Visible = visible
		headerButton.BackgroundColor3 = visible and color7 or color6

		if visible then
			closePopupsExcept("kit") -- inferred equivalent call
			fn7()
			layoutPopup()
			fn4()
		end
	end
	function v9.kit()
		setOpen(false) -- inferred equivalent call
	end

	headerButton.Activated:Connect(function()
		setOpen(not kitHolder.Visible) -- inferred equivalent call
	end)
	size2.Activated:Connect(function()
		setOpen(false) -- inferred equivalent call
	end)

	v.OnClientEvent:Connect(function(p, p2)
		local v32

		if p == true then
			v32 = p2 == "Drum"
		else
			v32 = false
		end

		FreePlaySoundAdapter.SetDrumPayloadEnabled(v32)
		setOpen(false) -- inferred equivalent call

		if v32 then
			task.defer(ensureSelectedLoaded)
		end
	end)
	drumFreePlayUI:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not drumFreePlayUI.Enabled then
			setOpen(false) -- inferred equivalent call
		end
	end)
	panel:GetPropertyChangedSignal("Size"):Connect(layoutPopup)

	local DrumPresetMenu = require(Modules:WaitForChild("DrumPresetMenu"))
	local v32 = DrumPresetMenu.Create({
		Kind = "Kit",
		Popup = kitPopup,
		ScreenGui = drumFreePlayUI,
		Colors = {
			Panel = Color3.fromRGB(22, 22, 25),
			Button = color6,
			ButtonHi = result,
			On = color7,
			Text = color8,
			Dim = Color3.fromRGB(150, 150, 158)
		},
		Collect = function()
			return nonDefault() or {}
		end,
		Apply = function(p)
			local v32 = FreePlayDrumKits.SanitizeSelection(p)

			for _, pad in ipairs(pads) do
				v26[pad] = { Kit = FreePlayDrumKits.DEFAULT, Velocity = 1 }
			end

			for k, v56 in pairs(v32 or {}) do
				v26[k] = { Kit = v56.Kit, Velocity = v56.Velocity }
			end

			commit(false) -- inferred equivalent call
			v27 = true
			scheduleSave() -- inferred equivalent call
			ensureSelectedLoaded() -- inferred equivalent call
			refreshVisibility()
			fn4()
			fn7()
		end
	})

	kitHolder:GetPropertyChangedSignal("Visible"):Connect(function()
		if not kitHolder.Visible then
			v32.Close()
		end
	end)
	parent4.Activated:Connect(v32.Close)
	parent5.Activated:Connect(v32.Close)

	applyZ(kitPopup)
	v32.ApplyZ()
	fn7()
	fn4()
	layoutPopup()

	task.spawn(function()
		local remoteEvents = ReplicatedStorage2:WaitForChild("RemoteEvents", 30)

		if not remoteEvents then
			return
		end

		local getFreePlayDrumKitSelection = remoteEvents:WaitForChild("GetFreePlayDrumKitSelection", 30)
		saveFreePlayDrumKitSelection = remoteEvents:WaitForChild("SaveFreePlayDrumKitSelection", 30)

		if not getFreePlayDrumKitSelection then
			return
		end

		local success, result2 = pcall(function()
			return getFreePlayDrumKitSelection:InvokeServer()
		end)

		if not success or v27 then
			return
		end

		local v55 = FreePlayDrumKits.SanitizeSelection(result2)

		if v55 then
			for k, v56 in pairs(v55) do
				v26[k] = { Kit = v56.Kit, Velocity = v56.Velocity }
			end

			commit(false) -- inferred equivalent call
			fn4()

			for _, pad in ipairs(pads) do
				local v56 = bundleKeyOf(pad) -- inferred equivalent call

				if v56 then
					FreePlayAssetPreloader.PreloadInBackground("Drum", v56)
				end
			end

			refreshVisibility()
		end
	end)
end

do
	local FreePlayDrumKits = require(Modules:WaitForChild("FreePlayDrumKits"))
	local FreePlaySoundAdapter = require(Modules:WaitForChild("FreePlaySoundAdapter"))

	local mix = FreePlayDrumKits.MIX
	local pads = FreePlayDrumKits.PADS

	local color6 = Color3.fromRGB(38, 38, 42)
	result = Color3.fromRGB(70, 70, 78)
	local color7 = Color3.fromRGB(40, 150, 60)
	local color8 = Color3.fromRGB(66, 200, 120)
	local color9 = Color3.fromRGB(235, 235, 235)
	local color10 = Color3.fromRGB(150, 150, 158)

	local v26 = {}

	for _, pad in ipairs(pads) do
		v26[pad] = {
			Volume = mix.VOLUME_DEFAULT,
			Reverb = mix.REVERB_DEFAULT,
			Bass = mix.BASS_DEFAULT
		}
	end

	local visible2 = false

	local function commit()
		local v27 = {}
		local v28 = false

		for _, pad in ipairs(pads) do
			local v29 = v26[pad]

			if not (v29.Volume ~= mix.VOLUME_DEFAULT or v29.Reverb ~= mix.REVERB_DEFAULT or v29.Bass ~= mix.BASS_DEFAULT) then
				continue
			end

			v27[pad] = { Volume = v29.Volume, Reverb = v29.Reverb, Bass = v29.Bass }
			v28 = true
		end

		FreePlaySoundAdapter.SetLocalDrumMix(v28 and v27 or nil)
	end

	local v27 = {
		Kick = { "BassDrum" },
		Snare = { "Snare", "SideStick" },
		Tom = { "HighTom", "MidTom", "FloorTom" },
		HiHat = { "FootHiHat", "OpenHiHat" },
		Cymbal = { "HighCrash", "MediumCrash", "Splash", "China", "RideEdge", "RideBell" },
		Cowbell = { "Cowbell" }
	}

	local function corner(parent, p) -- 1 equivalent call inferred from this helper
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, p)
		uiCorner.Parent = parent
	end

	local function newButton(parent, text, size, position, p) -- 4 equivalent calls inferred from this helper
		local textButton = Instance.new("TextButton")
		textButton.AutoButtonColor = false
		textButton.Text = text
		textButton.Font = Enum.Font.GothamBold
		textButton.TextSize = 13
		textButton.TextColor3 = color9
		textButton.BackgroundColor3 = p or color6
		textButton.BorderSizePixel = 0
		textButton.Size = size
		textButton.Position = position
		textButton.Parent = parent
		corner(textButton, 6) -- inferred equivalent call
		return textButton
	end

	local function newLabel(parent, text, size, position, p, value, p2)
		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.Text = text
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextSize = value or 12
		textLabel.TextColor3 = p2 or color9
		textLabel.TextXAlignment = p or Enum.TextXAlignment.Left
		textLabel.Size = size
		textLabel.Position = position
		textLabel.Parent = parent
		return textLabel
	end

	local headerButton3 = makeHeaderButton("Eq", "EQ", color6, color9, 56, 0, v7)
	headerButton3.TextSize = TouchEnabled and 12 or 14

	local eqHolder = Instance.new("Frame")
	eqHolder.Name = "EqHolder"
	eqHolder.BackgroundTransparency = 1
	eqHolder.AnchorPoint = Vector2.new(0, 1)
	eqHolder.Size = UDim2.fromOffset(372, 434)
	eqHolder.Position = UDim2.fromOffset(v7, -6)
	eqHolder.Visible = false
	eqHolder.ZIndex = 200
	eqHolder.Parent = panel

	local eqPopup = Instance.new("Frame")
	eqPopup.Name = "EqPopup"
	eqPopup.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
	eqPopup.BackgroundTransparency = 0.04
	eqPopup.BorderSizePixel = 0
	eqPopup.Size = UDim2.fromOffset(372, 434)
	eqPopup.Position = UDim2.fromOffset(0, 0)
	eqPopup.ZIndex = 200
	eqPopup.Parent = eqHolder
	parent2 = Instance.new("UICorner")
	parent2.CornerRadius = UDim.new(0, 10)
	parent2.Parent = eqPopup

	parent2 = Instance.new("UIStroke")
	parent2.Color = result
	parent2.Thickness = 1.5
	parent2.Parent = eqPopup
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = eqPopup
	parent2 = Instance.new("UIPadding")
	parent2.PaddingTop = UDim.new(0, 8)
	parent2.PaddingBottom = UDim.new(0, 8)
	parent2.PaddingLeft = UDim.new(0, 8)
	parent2.PaddingRight = UDim.new(0, 8)
	parent2.Parent = eqPopup

	local function applyZ(folder)
		local function setZ(guiObject) -- 2 equivalent calls inferred from this helper
			if guiObject:IsA("GuiObject") then
				local v28 = guiObject
				local count2 = 0

				while v28 and v28 ~= eqPopup do
					count2 += 1
					v28 = v28.Parent
				end

				guiObject.ZIndex = count2 + 200
			end
		end

		setZ(folder) -- inferred equivalent call

		for _, descendant in ipairs(folder:GetDescendants()) do
			setZ(descendant) -- inferred equivalent call
		end
	end

	parent2 = Instance.new("Frame")
	parent2.BackgroundTransparency = 1
	parent2.Size = UDim2.new(1, 0, 0, 28)
	parent2.Parent = eqPopup
	size2 = UDim2.fromOffset(28, 24)
	v13 = UDim2.new(0, 0, 0.5, -12)
	local textButton = Instance.new("TextButton")
	textButton.AutoButtonColor = false
	textButton.Text = "<"
	textButton.Font = Enum.Font.GothamBold
	textButton.TextSize = 13
	textButton.TextColor3 = color9
	textButton.BackgroundColor3 = result or color6
	textButton.BorderSizePixel = 0
	textButton.Size = size2
	textButton.Position = v13
	textButton.Parent = parent2
	size2 = Instance.new("UICorner")
	size2.CornerRadius = UDim.new(0, 6)
	size2.Parent = textButton

	textButton.Visible = false
	size2 = UDim2.new(1, -176, 1, 0)
	v13 = UDim2.fromOffset(0, 0)
	parent3 = Enum.TextXAlignment.Left
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "EQ"
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 14
	textLabel.TextColor3 = color9
	textLabel.TextXAlignment = parent3 or Enum.TextXAlignment.Left
	textLabel.Size = size2
	textLabel.Position = v13
	textLabel.Parent = parent2

	size2 = UDim2.fromOffset(72, 24)
	v13 = UDim2.new(1, -168, 0.5, -12)
	local parent4 = newButton(parent2, "PRESETS", size2, v13, color7) -- inferred equivalent call
	parent4.TextSize = 12
	size2 = UDim2.fromOffset(56, 24)
	v13 = UDim2.new(1, -92, 0.5, -12)
	local parent5 = newButton(parent2, "RESET", size2, v13, result) -- inferred equivalent call
	parent5.TextSize = 12
	size2 = newButton(parent2, "X", UDim2.fromOffset(26, 24), UDim2.new(1, -26, 0.5, -12), Color3.fromRGB(190, 48, 48))

	local humanize = FreePlayDrumKits.HUMANIZE
	local v28 = true
	local v29 = humanize.DEFAULT
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Position = UDim2.fromOffset(0, 32)
	frame.Size = UDim2.new(1, 0, 0, 26)
	frame.Parent = eqPopup
	newLabel(frame, "HUMANIZE", UDim2.fromOffset(70, 26), UDim2.fromOffset(0, 0), Enum.TextXAlignment.Left, 12)
	local parent6 = newButton(frame, "ON", UDim2.fromOffset(52, 26), UDim2.fromOffset(72, 0), color7)
	parent6.TextSize = 12
	local v30 = newButton(frame, "-", UDim2.fromOffset(22, 26), UDim2.fromOffset(164, 0))
	local v31 = newLabel(frame, "", UDim2.fromOffset(42, 26), UDim2.fromOffset(186, 0), Enum.TextXAlignment.Center, 12)
	local v32 = newButton(frame, "+", UDim2.fromOffset(22, 26), UDim2.fromOffset(228, 0))

	local function renderHuman()
		parent6.Text = v28 and "ON" or "OFF"
		parent6.BackgroundColor3 = v28 and color7 or color6
		v31.Text = string.format("%d%%", v29)
		v31.TextColor3 = v28 and (v29 ~= humanize.DEFAULT and color8 or color9) or color10
		local v67 = not v28 or v29 <= humanize.MIN
		local v68 = not v28 or v29 >= humanize.MAX
		v30.BackgroundTransparency = v67 and 0.6 or 0
		v30.TextTransparency = v67 and 0.6 or 0
		v32.BackgroundTransparency = v68 and 0.6 or 0
		v32.TextTransparency = v68 and 0.6 or 0
	end

	local frame2 = Instance.new("Frame")
	frame2.BackgroundTransparency = 1
	frame2.Position = UDim2.fromOffset(0, 62)
	frame2.Size = UDim2.new(1, 0, 0, 26)
	frame2.Parent = eqPopup
	parent2 = Instance.new("TextButton")
	parent2.AutoButtonColor = false
	parent2.Text = ""
	parent2.BackgroundTransparency = 1
	parent2.Size = UDim2.new(1, 0, 1, 0)
	parent2.Parent = frame2
	v13 = Instance.new("Frame")
	v13.AnchorPoint = Vector2.new(0, 0.5)
	v13.Position = UDim2.new(0, 0, 0.5, 0)
	v13.Size = UDim2.fromOffset(18, 18)
	v13.BackgroundColor3 = color6
	v13.BorderSizePixel = 0
	v13.Parent = parent2
	corner(v13, 4)
	parent3 = Instance.new("UIStroke")
	parent3.Color = Color3.fromRGB(120, 120, 128)
	parent3.Thickness = 1.5
	parent3.Parent = v13
	local frame3 = Instance.new("Frame")
	frame3.AnchorPoint = Vector2.new(0.5, 0.5)
	frame3.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame3.Size = UDim2.fromOffset(10, 10)
	frame3.BackgroundColor3 = color8
	frame3.BorderSizePixel = 0
	frame3.Visible = false
	frame3.Parent = v13
	corner(frame3, 3)
	local v67 = newLabel(
		parent2,
		"ALL PADS (move every pad together)",
		UDim2.new(1, -24, 1, 0),
		UDim2.fromOffset(24, 0),
		Enum.TextXAlignment.Left,
		11
	)

	local frame4 = Instance.new("Frame")
	frame4.BackgroundTransparency = 1
	frame4.Position = UDim2.fromOffset(0, 90)
	frame4.Size = UDim2.new(1, 0, 0, 16)
	frame4.Parent = eqPopup
	newLabel(
		frame4,
		"VOLUME",
		UDim2.fromOffset(86, 16),
		UDim2.fromOffset(72, 0),
		Enum.TextXAlignment.Center,
		10,
		color10
	)
	newLabel(
		frame4,
		"REVERB",
		UDim2.fromOffset(86, 16),
		UDim2.fromOffset(164, 0),
		Enum.TextXAlignment.Center,
		10,
		color10
	)
	newLabel(
		frame4,
		"BASS (dB)",
		UDim2.fromOffset(86, 16),
		UDim2.fromOffset(256, 0),
		Enum.TextXAlignment.Center,
		10,
		color10
	)

	local function newPage(name, p)
		local scrollingFrame = Instance.new("ScrollingFrame")
		scrollingFrame.Name = name
		scrollingFrame.BackgroundTransparency = 1
		scrollingFrame.BorderSizePixel = 0
		scrollingFrame.Position = UDim2.fromOffset(0, p)
		scrollingFrame.Size = UDim2.new(1, 0, 1, -(p + 32))
		scrollingFrame.ScrollBarThickness = 4
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
		scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scrollingFrame.Visible = false
		scrollingFrame.Parent = eqPopup
		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.Padding = UDim.new(0, 4)
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout.Parent = scrollingFrame
		return scrollingFrame
	end

	local parent7 = newPage("MainPage", 110)
	local parent8 = newPage("PresetPage", 32)

	local fn3
	local fn4

	local function showMain() -- 2 equivalent calls inferred from this helper
		fn3("main")
	end
	fn3 = function(p)
		local visible = p == "main"
		parent7.Visible = visible
		frame2.Visible = visible
		frame.Visible = visible
		frame4.Visible = visible
		parent8.Visible = p == "presets"
		parent4.Visible = visible
		parent5.Visible = visible
		textButton.Visible = not visible
		textLabel.Text = visible and "EQ" or "PRESETS"
		textLabel.Position = visible and UDim2.fromOffset(0, 0) or UDim2.fromOffset(34, 0)
	end
	textButton.Activated:Connect(showMain)

	local function commitHuman() -- 3 equivalent calls inferred from this helper
		FreePlaySoundAdapter.SetLocalDrumHumanize(v28 and v29 or 0)
	end
	parent6.Activated:Connect(function()
		v28 = not v28
		commitHuman() -- inferred equivalent call
		fn4()
	end)
	v30.Activated:Connect(function()
		if v28 then
			v29 = math.clamp(v29 - humanize.STEP, humanize.MIN, humanize.MAX)
			commitHuman() -- inferred equivalent call
			fn4()
		end
	end)
	v32.Activated:Connect(function()
		if v28 then
			v29 = math.clamp(v29 + humanize.STEP, humanize.MIN, humanize.MAX)
			commitHuman() -- inferred equivalent call
			fn4()
		end
	end)

	local v70 = {
		Volume = {
			Step = mix.VOLUME_STEP,
			Lo = mix.VOLUME_MIN,
			Hi = mix.VOLUME_MAX,
			Default = mix.VOLUME_DEFAULT
		},
		Reverb = {
			Step = mix.REVERB_STEP,
			Lo = mix.REVERB_MIN,
			Hi = mix.REVERB_MAX,
			Default = mix.REVERB_DEFAULT
		},
		Bass = {
			Step = mix.BASS_STEP,
			Lo = mix.BASS_MIN,
			Hi = mix.BASS_MAX,
			Default = mix.BASS_DEFAULT
		}
	}

	local function change(p, p2, p3)
		local v71 = v70[p2]
		local function bump(p4) -- 2 equivalent calls inferred from this helper
			v26[p4][p2] = math.clamp(v26[p4][p2] + p3 * v71.Step, v71.Lo, v71.Hi)
		end

		if visible2 then
			for _, pad in ipairs(pads) do
				bump(pad) -- inferred equivalent call
			end
		else
			bump(p) -- inferred equivalent call
		end

		commit()
		fn4()
	end

	local v71 = { Volume = 72, Reverb = 164, Bass = 256 }
	local v72 = {}

	local function makeStepper(frame5, p, p2)
		local v73 = v71[p2]
		local udim = UDim2.fromOffset(22, 26)
		local udim2, v74 = UDim2.fromOffset(v73, 0)
		local minus = newButton(frame5, "-", udim, udim2, v74) -- inferred equivalent call
		local udim3 = UDim2.fromOffset(42, 26)
		local udim4 = UDim2.fromOffset(v73 + 22, 0)
		local center = Enum.TextXAlignment.Center
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.BackgroundTransparency = 1
		textLabel2.Text = ""
		textLabel2.Font = Enum.Font.GothamBold
		textLabel2.TextSize = 12
		textLabel2.TextColor3 = color9
		textLabel2.TextXAlignment = center or Enum.TextXAlignment.Left
		textLabel2.Size = udim3
		textLabel2.Position = udim4
		textLabel2.Parent = frame5

		local udim5 = UDim2.fromOffset(22, 26)
		local udim6, v76 = UDim2.fromOffset(v73 + 64, 0)
		local plus = newButton(frame5, "+", udim5, udim6, v76) -- inferred equivalent call
		minus.Activated:Connect(function()
			change(p, p2, -1)
		end)
		plus.Activated:Connect(function()
			change(p, p2, 1)
		end)
		return { Val = textLabel2, Minus = minus, Plus = plus }
	end

	local function makeRow(parent, layoutOrder, pad)
		local frame5 = Instance.new("Frame")
		frame5.Name = pad .. "Row"
		frame5.BackgroundTransparency = 1
		frame5.Size = UDim2.new(1, -8, 0, 26)
		frame5.LayoutOrder = layoutOrder
		frame5.Parent = parent
		local text = FreePlayDrumKits.PAD_DISPLAY_NAME[pad] or pad
		local udim = UDim2.fromOffset(70, 26)
		local udim2 = UDim2.fromOffset(0, 0)
		local left = Enum.TextXAlignment.Left
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.BackgroundTransparency = 1
		textLabel2.Text = text
		textLabel2.Font = Enum.Font.GothamBold
		textLabel2.TextSize = 12
		textLabel2.TextColor3 = color9
		textLabel2.TextXAlignment = left or Enum.TextXAlignment.Left
		textLabel2.Size = udim
		textLabel2.Position = udim2
		textLabel2.Parent = frame5

		v72[pad] = {
			Volume = makeStepper(frame5, pad, "Volume"),
			Reverb = makeStepper(frame5, pad, "Reverb"),
			Bass = makeStepper(frame5, pad, "Bass")
		}
	end

	local count2 = 0

	for _, v73 in ipairs(FreePlayDrumKits.CATEGORIES) do
		count2 += 1
		newLabel(
			parent7,
			string.upper(v73.Name),
			UDim2.new(1, -8, 0, 16),
			UDim2.fromOffset(0, 0),
			Enum.TextXAlignment.Left,
			10,
			color10
		).LayoutOrder = count2

		for _, pad in ipairs(v73.Pads) do
			count2 += 1
			makeRow(parent7, count2, pad)
		end
	end

	v13 = newButton(parent8, "< BACK", UDim2.new(1, -8, 0, 26), UDim2.fromOffset(0, 0), result)
	v13.LayoutOrder = 0
	v13.Activated:Connect(showMain)

	for i, v73 in ipairs({
		{ Name = "Flat (reset)", Groups = {} },
		{
			Name = "Dry (no reverb)",
			Groups = {
				Kick = { 100, 0 },
				Snare = { 100, 0 },
				Tom = { 100, 0 },
				HiHat = { 100, 0 },
				Cymbal = { 100, 0 },
				Cowbell = { 100, 0 }
			}
		},
		{
			Name = "Studio",
			Groups = {
				Kick = { 100, 5, 1 },
				Snare = { 110, 25 },
				Tom = { 100, 25 },
				HiHat = { 90, 15 },
				Cymbal = { 90, 25 },
				Cowbell = { 100, 20 }
			}
		},
		{
			Name = "Hall",
			Groups = {
				Kick = { 100, 15 },
				Snare = { 110, 50 },
				Tom = { 100, 50 },
				HiHat = { 90, 35 },
				Cymbal = { 90, 50 },
				Cowbell = { 100, 40 }
			}
		},
		{
			Name = "Punchy",
			Groups = {
				Kick = { 130, 5, 2 },
				Snare = { 130, 10, 1 },
				Tom = { 110, 10, 1 },
				HiHat = { 80, 5 },
				Cymbal = { 80, 10 },
				Cowbell = { 100, 10 }
			}
		},
		{
			Name = "Metal",
			Groups = {
				Kick = { 140, 5, 3 },
				Snare = { 130, 15, 1 },
				Tom = { 120, 15, 2 },
				HiHat = { 90, 10 },
				Cymbal = { 85, 20, -1 },
				Cowbell = { 100, 10 }
			}
		}
	}) do
		local parent = newButton(parent8, v73.Name, UDim2.new(1, -8, 0, 26), UDim2.fromOffset(0, 0), color6)
		parent.LayoutOrder = i
		parent.Activated:Connect(function()
			for _, pad in ipairs(pads) do
				v26[pad] = {
					Volume = mix.VOLUME_DEFAULT,
					Reverb = mix.REVERB_DEFAULT,
					Bass = mix.BASS_DEFAULT
				}
			end

			for k, group in pairs(v73.Groups) do
				for _, v75 in ipairs(v27[k] or {}) do
					v26[v75] = {
						Volume = math.clamp(group[1], mix.VOLUME_MIN, mix.VOLUME_MAX),
						Reverb = math.clamp(group[2], mix.REVERB_MIN, mix.REVERB_MAX),
						Bass = math.clamp(group[3] or mix.BASS_DEFAULT, mix.BASS_MIN, mix.BASS_MAX)
					}
				end
			end

			commit()
			fn4()
			showMain() -- inferred equivalent call
		end)
	end

	parent4.Activated:Connect(function()
		fn3("presets")
	end)

	parent5.Activated:Connect(function()
		for _, pad in ipairs(pads) do
			v26[pad] = {
				Volume = mix.VOLUME_DEFAULT,
				Reverb = mix.REVERB_DEFAULT,
				Bass = mix.BASS_DEFAULT
			}
		end

		commit()
		fn4()
	end)

	parent2.Activated:Connect(function()
		visible2 = not visible2
		fn4()
	end)

	fn4 = function()
		frame3.Visible = visible2
		renderHuman()
		v67.TextColor3 = visible2 and color8 or color9

		for k, v73 in pairs(v72) do
			local v74 = v26[k]

			for k2, v75 in pairs(v70) do
				local v76 = v73[k2]
				local v77 = v74[k2]

				if k2 == "Volume" or k2 == "Reverb" then
					v76.Val.Text = string.format("%d%%", v77)
				else
					v76.Val.Text = v77 == 0 and "0" or string.format("%+d", v77)
				end

				v76.Val.TextColor3 = v77 ~= v75.Default and color8 or color9
				local v78 = v77 <= v75.Lo
				local v79 = v75.Hi <= v77
				v76.Minus.BackgroundTransparency = v78 and 0.6 or 0
				v76.Minus.TextTransparency = v78 and 0.6 or 0
				v76.Plus.BackgroundTransparency = v79 and 0.6 or 0
				v76.Plus.TextTransparency = v79 and 0.6 or 0
			end
		end
	end

	local function layoutPopup()
		local currentCamera = Workspace.CurrentCamera
		local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
		local offset = panel.Size.X.Offset
		local offset2 = panel.Size.Y.Offset
		local scale = math.max(math.min(1, (viewportSize.Y - offset2 - 60) / 434, (viewportSize.X - 12) / 372), 0.5)
		uiScale.Scale = scale
		eqHolder.Size = UDim2.fromOffset(scale * 372, scale * 434)
		local v74 = (viewportSize.X - offset) / 2
		local v75 = 6 - v74
		local v76 = viewportSize.X - 6 - v74 - scale * 372
		eqHolder.Position = UDim2.fromOffset(math.clamp(v7, v75, (math.max(v75, v76))), -6)
	end

	local function setOpen(visible) -- 5 equivalent calls inferred from this helper
		eqHolder.Visible = visible
		headerButton3.BackgroundColor3 = visible and color7 or color6

		if visible then
			closePopupsExcept("eq") -- inferred equivalent call
			showMain() -- inferred equivalent call
			layoutPopup()
			fn4()
		end
	end
	function v9.eq()
		setOpen(false) -- inferred equivalent call
	end

	headerButton3.Activated:Connect(function()
		setOpen(not eqHolder.Visible) -- inferred equivalent call
	end)
	size2.Activated:Connect(function()
		setOpen(false) -- inferred equivalent call
	end)

	v.OnClientEvent:Connect(function()
		setOpen(false) -- inferred equivalent call
	end)
	drumFreePlayUI:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not drumFreePlayUI.Enabled then
			setOpen(false) -- inferred equivalent call
		end
	end)
	panel:GetPropertyChangedSignal("Size"):Connect(layoutPopup)

	local DrumPresetMenu = require(Modules:WaitForChild("DrumPresetMenu"))
	local v73 = DrumPresetMenu.Create({
		Kind = "Eq",
		Popup = eqPopup,
		ScreenGui = drumFreePlayUI,
		Colors = {
			Panel = Color3.fromRGB(22, 22, 25),
			Button = color6,
			ButtonHi = result,
			On = color8,
			Text = color9,
			Dim = color10
		},
		Collect = function()
			local result2 = {}

			for _, pad in ipairs(pads) do
				result2[pad] = {
					Volume = v26[pad].Volume,
					Reverb = v26[pad].Reverb,
					Bass = v26[pad].Bass
				}
			end

			return result2
		end,
		Apply = function(p)
			local v74 = FreePlayDrumKits.SanitizeMixFull(p)

			for _, pad in ipairs(pads) do
				v26[pad] = {
					Volume = v74[pad].Volume,
					Reverb = v74[pad].Reverb,
					Bass = v74[pad].Bass
				}
			end

			commit()
			fn4()
		end
	})

	eqHolder:GetPropertyChangedSignal("Visible"):Connect(function()
		if not eqHolder.Visible then
			v73.Close()
		end
	end)
	parent4.Activated:Connect(v73.Close)
	parent5.Activated:Connect(v73.Close)

	applyZ(eqPopup)
	v73.ApplyZ()
	showMain()
	fn4()
	layoutPopup()
end

do
	local function hookCamera() -- 1 equivalent call inferred from this helper
		local currentCamera = Workspace.CurrentCamera

		if currentCamera then
			currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutPanel)
		end
	end
end

result = Workspace.CurrentCamera

if result then
	result:GetPropertyChangedSignal("ViewportSize"):Connect(layoutPanel)
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	hookCamera() -- inferred equivalent call
	layoutPanel()
end)

do
	local v26 = TouchEnabled and 32 or 28
	local sizeControls = Instance.new("Frame")
	sizeControls.Name = "SizeControls"
	sizeControls.BackgroundTransparency = 1
	sizeControls.AnchorPoint = Vector2.new(1, 0)
	sizeControls.Position = UDim2.new(1, -8, 0, 40)
	sizeControls.Size = UDim2.fromOffset(v26, v26 * 4 + 12)
	sizeControls.ZIndex = 100
	sizeControls.Parent = panel

	local function makeSizeButton(name, text, p)
		local textButton = Instance.new("TextButton")
		textButton.Name = name
		textButton.AutoButtonColor = false
		textButton.Text = text
		textButton.Font = Enum.Font.GothamBold
		textButton.TextSize = 18
		textButton.TextColor3 = Color3.fromRGB(235, 235, 235)
		textButton.BackgroundColor3 = Color3.fromRGB(38, 38, 42)
		textButton.BackgroundTransparency = 0.1
		textButton.BorderSizePixel = 0
		textButton.Position = UDim2.fromOffset(0, p)
		textButton.Size = UDim2.fromOffset(v26, v26)
		textButton.ZIndex = 101
		textButton.Parent = sizeControls
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 6)
		uiCorner.Parent = textButton
		return textButton
	end

	local sizeButton = makeSizeButton("SizePlus", "+", 0)
	local sizeButton2 = makeSizeButton("SizeMinus", "-", v26 + 4)

	local sizeButton3 = makeSizeButton("FPPToggle", "TPP", (v26 + 4) * 2)
	sizeButton3.TextSize = 11
	local function refreshFppButton() -- 1 equivalent call inferred from this helper
		sizeButton3.Text = SessionCameraSettings.GetIsFirstPerson() and "FPP" or "TPP"
	end
	sizeButton3.Activated:Connect(function()
		SessionCameraSettings.RequestFPPToggle()
	end)
	SessionCameraSettings.OnFirstPersonChanged(refreshFppButton)
	refreshFppButton() -- inferred equivalent call
	local sizeButton4 = makeSizeButton("LeftHandToggle", "RH", (v26 + 4) * 3)
	sizeButton4.TextSize = 11
	local function applyHandedness()
		for _, v27 in pairs(padFrames) do
			local udim = UDim2.fromScale((padCenterX(v27.Spec) + 121) / 888, v27.Spec.Y / 297) -- inferred equivalent call
			v27.Button.Position = udim
			v27.Viewport.Position = udim
		end

		for _, v27 in pairs(v19) do
			if not v27.Spec then
				continue
			end

			local button = v27.Button
			button.Position = UDim2.fromScale((padCenterX(v27.Spec) + 121 + v27.Dx) / 888, v27.Spec.Y / 297) -- inferred equivalent call
		end

		sizeButton4.Text = v5 and "LH" or "RH"
	end
	result = ReplicatedStorage:WaitForChild("RemoteEvents")
	local setDrumPreference = result:WaitForChild("SetDrumPreference")
	v = result:WaitForChild("DrumPreferenceUpdate")
	sizeButton4.Activated:Connect(function()
		setDrumPreference:FireServer("Flip", not v5)
	end)
	v.OnClientEvent:Connect(function(p)
		local v27

		if type(p) == "table" then
			v27 = p.FlipEnabled == true
		else
			v27 = false
		end

		if v27 ~= v5 then
			v5 = v27
			applyHandedness()
		end
	end)

	local function refreshSizeButtons() -- 1 equivalent call inferred from this helper
		local drumPadScale = SettingsState.GetDrumPadScale()
		sizeButton.TextTransparency = drumPadScale >= 1.499 and 0.65 or 0
		sizeButton2.TextTransparency = drumPadScale <= 0.501 and 0.65 or 0
	end

	local function stepScale(p) -- 2 equivalent calls inferred from this helper
		local drumPadScale = SettingsState.GetDrumPadScale()
		local v27 = math.clamp(math.floor((drumPadScale + p) * 10 + 0.5) / 10, 0.5, 1.5)

		if math.abs(v27 - drumPadScale) > 0.001 then
			SettingsState.SetField("DrumPadScale", v27)
		end
	end
	sizeButton.Activated:Connect(function()
		stepScale(0.1) -- inferred equivalent call
	end)
	sizeButton2.Activated:Connect(function()
		stepScale(-0.1) -- inferred equivalent call
	end)

	SettingsState.OnChanged(function()
		layoutPanel()
		refreshSizeButtons() -- inferred equivalent call
	end)
	result = SettingsState.GetDrumPadScale()
	sizeButton.TextTransparency = result >= 1.499 and 0.65 or 0
	sizeButton2.TextTransparency = result <= 0.501 and 0.65 or 0
end

result = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DrumUISkin", 5)

if result then
	local success, result2 = pcall(require, result)

	if success then
		local success2, result3 = pcall(result2.Init, {
			ScreenGui = drumFreePlayUI,
			Panel = panel,
			Header = header,
			PadArea = padArea,
			PadFrames = padFrames
		})

		if not success2 then
			warn("[DrumFreePlayUI] DrumUISkin gagal:", result3)
		end
	else
		warn("[DrumFreePlayUI] DrumUISkin gagal dimuat:", result2)
	end
end

do
	local function isFirstPersonNow(): boolean -- 2 equivalent calls inferred from this helper
		if SessionCameraSettings.GetIsFirstPerson() then
			return true
		end

		local currentCamera = workspace.CurrentCamera
		return currentCamera ~= nil and (currentCamera.CFrame.Position - currentCamera.Focus.Position).Magnitude < 1
	end
end

result = game:GetService("RunService")

do
	local UserInputService2 = game:GetService("UserInputService")
	result:BindToRenderStep("DrumFreePlayMouseOverride", Enum.RenderPriority.Camera.Value + 50, function()
		if not UserInputService2.MouseEnabled then
			return
		end

		if drumFreePlayUI.Enabled and isFirstPersonNow() then -- inferred equivalent call
			if UserInputService2:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				return
			end

			if UserInputService2.MouseBehavior ~= Enum.MouseBehavior.Default then
				UserInputService2.MouseBehavior = Enum.MouseBehavior.Default
			end

			if not UserInputService2.MouseIconEnabled then
				UserInputService2.MouseIconEnabled = true
			end
		end
	end)
end

result = game:GetService("RunService")

do
	local v26 = false
	result:BindToRenderStep("DrumFreePlayFppScrollLock", Enum.RenderPriority.First.Value - 1, function()
		local v27 = drumFreePlayUI.Enabled and isFirstPersonNow() -- inferred equivalent call

		if v27 ~= v26 then
			v26 = v27
			SessionCameraSettings.SetScrollBlocked(v27)
		end
	end)
end

do
	local success
	success, result = pcall(function()
		return require(Modules:WaitForChild("FreePlayScrollGuard"))
	end)

	if success then
		result.Attach(drumFreePlayUI, function()
			local guiObjects = { panel }

			for _, guiObject in ipairs(panel:GetChildren()) do
				if guiObject:IsA("GuiObject") and guiObject.Name:match("Holder$") then
					table.insert(guiObjects, guiObject)
				end
			end

			return guiObjects
		end)
	else
		warn("[DrumFreePlayUI] FreePlayScrollGuard gagal dimuat:", result)
	end
end

layoutPanel()
refreshVisibility()