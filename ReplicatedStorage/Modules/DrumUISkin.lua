local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local SettingsState = require(script.Parent:WaitForChild("SettingsState"))

local function rgb(p, p2, p3) -- 26 equivalent calls inferred from this helper
	return Color3.fromRGB(p, p2, p3)
end

local v = {
	Tape = rgb(206, 190, 150), -- inferred equivalent call
	TapeDark = rgb(96, 90, 80), -- inferred equivalent call
	Ink = rgb(14, 14, 13), -- inferred equivalent call
	Plate = rgb(16, 16, 15), -- inferred equivalent call
	Border = rgb(86, 84, 80), -- inferred equivalent call
	Edge = rgb(122, 120, 114), -- inferred equivalent call
	Text = rgb(222, 220, 214), -- inferred equivalent call
	Amber = rgb(204, 162, 72), -- inferred equivalent call
	Rust = rgb(74, 42, 28), -- inferred equivalent call
	Black = Color3.new(0, 0, 0)
}

local v2 = {
	Cymbal = rgb(170, 140, 66), -- inferred equivalent call
	Tom = rgb(46, 45, 42), -- inferred equivalent call
	Kick = rgb(104, 102, 96), -- inferred equivalent call
	Snare = rgb(200, 194, 176), -- inferred equivalent call
	Small = rgb(104, 140, 80) -- inferred equivalent call
}

local v3 = {
	{ rgb(22, 22, 25), rgb(20, 20, 19) }, -- inferred equivalent call
	{ rgb(38, 38, 42), rgb(28, 28, 26) }, -- inferred equivalent call
	{ rgb(70, 70, 78), rgb(56, 55, 51) }, -- inferred equivalent call
	{ rgb(40, 150, 60), rgb(150, 118, 44) }, -- inferred equivalent call
	{ rgb(66, 200, 120), rgb(214, 170, 78) }, -- inferred equivalent call
	{ rgb(235, 235, 235), rgb(222, 220, 214) }, -- inferred equivalent call
	{ rgb(170, 170, 178), rgb(158, 156, 150) }, -- inferred equivalent call
	{ rgb(150, 150, 158), rgb(150, 148, 142) }, -- inferred equivalent call
	{ rgb(190, 48, 48), rgb(150, 34, 30) }, -- inferred equivalent call
	{ rgb(200, 120, 30), rgb(176, 110, 44) }, -- inferred equivalent call
	{ rgb(255, 120, 120), rgb(226, 96, 72) }, -- inferred equivalent call
	{ rgb(255, 255, 255), rgb(232, 228, 218) } -- inferred equivalent call
}

local function key(data) -- 4 equivalent calls inferred from this helper
	return string.format(
		"%d,%d,%d",
		math.floor(data.R * 255 + 0.5),
		math.floor(data.G * 255 + 0.5),
		(math.floor(data.B * 255 + 0.5))
	)
end

local v4 = {}
local v5 = {}
local DrumUISkin = {}

for _, v6 in ipairs(v3) do
	v4[key(v6[1])] = v6[2] -- inferred equivalent call
	v5[key(v6[2])] = v6[1] -- inferred equivalent call
end

local oswalds = {
	[Enum.Font.GothamBold] = Enum.Font.Oswald,
	[Enum.Font.GothamBlack] = Enum.Font.Oswald,
	[Enum.Font.GothamMedium] = Enum.Font.Oswald,
	[Enum.Font.Gotham] = Enum.Font.Oswald
}

local v6 = {
	"BackgroundColor3",
	"TextColor3",
	"ImageColor3",
	"ScrollBarImageColor3",
	"Color",
	"PlaceholderColor3"
}

local v7 = nil
local flag = false
local v8 = {}
local v9 = {}
local v10 = {}
local connections = {}
local instanceSet = {}
local v11 = nil

local function mk(className, items, parent) -- 44 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	if instance:IsA("GuiObject") then
		instance.BorderSizePixel = 0
		instance.Active = false
	end

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function track(p) -- 6 equivalent calls inferred from this helper
	table.insert(v10, p)
	return p
end

local function setp(p, p2, p3) -- 11 equivalent calls inferred from this helper
	local v12 = v8[p]

	if not v12 then
		v12 = {}
		v8[p] = v12
	end

	if v12[p2] == nil then
		v12[p2] = p[p2]
	end

	p[p2] = p3
end

local function nameHash(value)
	local v12 = 0

	for i = 1, #value do
		v12 = (v12 * 31 + value:byte(i)) % 100003
	end

	return v12
end

local function startsNewUI(name): boolean -- 1 equivalent call inferred from this helper
	return name:sub(1, 5) == "NewUI"
end

local function inScope(instance): boolean
	local v12 = nil

	while instance and instance ~= v7.Panel do
		if startsNewUI(instance.Name) then -- inferred equivalent call
			return false
		end

		v12 = instance
		instance = instance.Parent
	end

	if instance == v7.Panel and v12 then
		return v12 == v7.Header or v12.Name == "SizeControls" or v12.Name:match("Holder$") ~= nil
	end

	return false
end

local function readColor(p, p2) -- 2 equivalent calls inferred from this helper
	local success, result = pcall(function()
		return p[p2]
	end)

	if success and typeof(result) == "Color3" then
		return result
	end

	return nil
end

local function mapWith(p, p2)
	for _, v12 in ipairs(v6) do
		local result = readColor(p, v12) -- inferred equivalent call

		if not result then
			continue
		end

		local v13 = p2[key(result)] -- inferred equivalent call

		if v13 then
			p[v12] = v13
		end
	end
end

local function hookInst(instance)
	if instanceSet[instance] then
		return
	end

	instanceSet[instance] = true

	for _, propertyName in ipairs(v6) do
		if readColor(instance, propertyName) then -- inferred equivalent call
			table.insert(connections, instance:GetPropertyChangedSignal(propertyName):Connect(function()
				if not flag then
					return
				end

				local v12 = v4[key(instance[propertyName])] -- inferred equivalent call

				if v12 then
					instance[propertyName] = v12
				end
			end))
		end
	end
end

local function skinInst(descendant)
	if not inScope(descendant) then
		return
	end

	if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
		local v12 = oswalds[descendant.Font]

		if v12 then
			setp(descendant, "Font", v12) -- inferred equivalent call
		end
	elseif descendant:IsA("UICorner") then
		local cornerRadius = descendant.CornerRadius

		if cornerRadius.Scale == 0 and cornerRadius.Offset > 3 then
			setp(descendant, "CornerRadius", UDim.new(0, 3)) -- inferred equivalent call
		end
	end

	hookInst(descendant)
	mapWith(descendant, v4)
end

local function tape(parent, name, position, size, rotation, backgroundColor, backgroundTransparency, zIndex, p)
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = name,
		BackgroundColor3 = backgroundColor,
		BackgroundTransparency = backgroundTransparency,
		AnchorPoint = p or Vector2.new(0, 0),
		Position = position,
		Size = size,
		Rotation = rotation,
		ZIndex = zIndex
	}, parent)

	mk("Frame", { -- inferred equivalent call
		Name = "Crease",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.72,
		Position = UDim2.new(0, 0, 0.3, 0),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = zIndex
	}, parent2)
	mk("Frame", { -- inferred equivalent call
		Name = "Shade",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.78,
		Position = UDim2.new(0, 0, 1, -2),
		Size = UDim2.new(1, 0, 0, 2),
		ZIndex = zIndex
	}, parent2)
	local random = Random.new(nameHash(name) + 17)

	for i = 1, 3 do
		mk("Frame", { -- inferred equivalent call
			Name = "Dirt" .. i,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.7 + random:NextNumber() * 0.15,
			Position = UDim2.new(random:NextNumber() * 0.8, 0, random:NextNumber() * 0.6, 0),
			Size = UDim2.fromOffset(random:NextInteger(3, 9), random:NextInteger(2, 4)),
			ZIndex = zIndex
		}, parent2)
	end

	return parent2
end

local function markerLabel(parent, text, zIndex, p)
	local parent2 = mk("TextLabel", { -- inferred equivalent call
		Name = "Label",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = zIndex,
		Font = Enum.Font.PermanentMarker,
		TextScaled = true,
		Text = text,
		TextColor3 = p or v.Ink
	}, parent)

	mk("UITextSizeConstraint", { MinTextSize = 6, MaxTextSize = 26 }, parent2) -- inferred equivalent call
	mk( -- inferred equivalent call
		"UIPadding",
		{
			PaddingTop = UDim.new(0.08, 0),
			PaddingBottom = UDim.new(0.04, 0),
			PaddingLeft = UDim.new(0.06, 0),
			PaddingRight = UDim.new(0.06, 0)
		},
		parent2
	)
	return parent2
end

local function grime(parent, p, zIndex, p2, p3, p4)
	local random = Random.new(p)

	for i = 1, p2 do
		local integer = random:NextInteger(40, 120)
		local parent2 = mk("Frame", { -- inferred equivalent call
			Name = "Stain" .. i,
			BackgroundColor3 = i % 3 == 0 and v.Rust or Color3.new(0, 0, 0),
			BackgroundTransparency = 0.88 + random:NextNumber() * 0.06,
			Position = UDim2.fromScale(random:NextNumber() * 0.85, random:NextNumber() * 0.8),
			Size = UDim2.fromOffset(integer, (math.floor(integer * (0.35 + random:NextNumber() * 0.4)))),
			ZIndex = zIndex
		}, parent)

		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
	end

	for i = 1, p3 do
		mk("Frame", { -- inferred equivalent call
			Name = "Scratch" .. i,
			BackgroundColor3 = v.Text,
			BackgroundTransparency = 0.9 + random:NextNumber() * 0.05,
			Position = UDim2.fromScale(random:NextNumber() * 0.9, random:NextNumber()),
			Size = UDim2.fromOffset(random:NextInteger(40, 140), 1),
			Rotation = random:NextInteger(-50, 50),
			ZIndex = zIndex
		}, parent)
	end

	for i = 1, (math.floor)(p3 / 2) do
		mk("Frame", { -- inferred equivalent call
			Name = "Scuff" .. i,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.55,
			Position = UDim2.fromScale(random:NextNumber() * 0.9, random:NextNumber()),
			Size = UDim2.fromOffset(random:NextInteger(30, 90), 1),
			Rotation = random:NextInteger(-60, 60),
			ZIndex = zIndex
		}, parent)
	end

	for i = 1, p4 do
		local v12 = random:NextNumber() > 0.35
		local integer = random:NextInteger(1, 3)
		mk("Frame", { -- inferred equivalent call
			Name = "Speck" .. i,
			BackgroundColor3 = v12 and v.Text or Color3.new(0, 0, 0),
			BackgroundTransparency = v12 and 0.8 + random:NextNumber() * 0.12 or 0.45 + random:NextNumber() * 0.25,
			Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			Size = UDim2.fromOffset(integer, integer),
			ZIndex = zIndex
		}, parent)
	end
end

local function vignette(parent, name, position, size, rotation, p, zIndex)
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = name,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0,
		Position = position,
		Size = size,
		ZIndex = zIndex
	}, parent)
	mk("UIGradient", { -- inferred equivalent call
		Rotation = rotation,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, p), NumberSequenceKeypoint.new(1, 1) })
	}, parent2)
end

local function boardTransparency()
	local v12 = 0.58
	local success, result = pcall(function()
		return SettingsState.GetFreePlayOpacity()
	end)

	if success and type(result) == "number" then
		v12 = result
	end

	return (math.clamp(1 - v12 * 0.75, 0.2, 0.9))
end

local function buildBoard()
	local panel = v7.Panel
	local _offset = v7.PadArea.Position.Y.Offset
	local newUIBoard = {
		Name = "NewUIBoard",
		BackgroundColor3 = v.Plate,
		BackgroundTransparency = 0,
		AnchorPoint = 0,
		Position = 0,
		Size = 0,
		ZIndex = 0
	}
	local v12 = 0.58
	local success, result = pcall(function()
		return SettingsState.GetFreePlayOpacity()
	end)

	if success and type(result) == "number" then
		v12 = result
	end

	newUIBoard.BackgroundTransparency = math.clamp(1 - v12 * 0.75, 0.2, 0.9)
	newUIBoard.AnchorPoint = v7.PadArea.AnchorPoint
	newUIBoard.Position = v7.PadArea.Position
	newUIBoard.Size = v7.PadArea.Size
	local parent = mk("Frame", newUIBoard, panel) -- inferred equivalent call
	v11 = track(parent) -- inferred equivalent call
	local function syncBoard()
		parent.AnchorPoint = v7.PadArea.AnchorPoint
		parent.Position = v7.PadArea.Position
		parent.Size = v7.PadArea.Size
	end

	for _, propertyName in ipairs({ "AnchorPoint", "Position", "Size" }) do
		table.insert(connections, v7.PadArea:GetPropertyChangedSignal(propertyName):Connect(syncBoard))
	end

	mk("UICorner", { CornerRadius = UDim.new(0, 3) }, parent) -- inferred equivalent call
	mk("UIStroke", { Color = Color3.fromRGB(6, 6, 6), Thickness = 2, Transparency = 0.1 }, parent) -- inferred equivalent call

	vignette(parent, "VigTop", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 40), 90, 0.45, 1)
	vignette(parent, "VigBottom", UDim2.new(0, 0, 1, -40), UDim2.new(1, 0, 0, 40), 270, 0.4, 1)
	vignette(parent, "VigLeft", UDim2.new(0, 0, 0, 0), UDim2.new(0, 46, 1, 0), 0, 0.5, 1)
	vignette(parent, "VigRight", UDim2.new(1, -46, 0, 0), UDim2.new(0, 46, 1, 0), 180, 0.5, 1)
	grime(parent, 31, 2, 9, 9, 50)

	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = "EdgeWear",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 3, 0, 3),
		Size = UDim2.new(1, -6, 1, -6),
		ZIndex = 3
	}, parent)
	mk("UIStroke", { Color = v.Edge, Thickness = 1.5, Transparency = 0.7 }, parent2) -- inferred equivalent call
	mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent2) -- inferred equivalent call

	tape(parent, "TapeTL", UDim2.new(0, -14, 0, -4), UDim2.fromOffset(58, 14), -38, v.Tape, 0.1, 0)
	tape(parent, "TapeTR", UDim2.new(1, -44, 0, -4), UDim2.fromOffset(56, 13), 38, v.TapeDark, 0.12, 0)
	tape(parent, "TapeBL", UDim2.new(0, -12, 1, -18), UDim2.fromOffset(48, 12), 36, v.TapeDark, 0.15, 5)
	tape(parent, "TapeBR1", UDim2.new(1, -40, 1, -20), UDim2.fromOffset(54, 12), -40, v.Tape, 0.15, 5)
	tape(parent, "TapeBR2", UDim2.new(1, -38, 1, -22), UDim2.fromOffset(46, 11), 42, v.Tape, 0.2, 5)

	local v13 = tape(
		parent,
		"TapeSideL",
		UDim2.fromScale(0.07, 0.5),
		UDim2.fromOffset(120, 22),
		-88,
		v.Tape,
		0.06,
		6,
		Vector2.new(0.5, 0.5)
	)
	markerLabel(v13, "PLAY LOUD", 6)
	local v14 = tape(
		parent,
		"TapeSideR",
		UDim2.fromScale(0.875, 0.64),
		UDim2.fromOffset(110, 22),
		87,
		v.Tape,
		0.08,
		6,
		Vector2.new(0.5, 0.5)
	)
	markerLabel(v14, "NO RULES", 6)

	local function layout()
		local y = parent.AbsoluteSize.Y

		if y <= 0 then
			return
		end

		local v15 = math.clamp(math.floor(y * 0.16), 16, 26)
		v13.Size = UDim2.fromOffset(math.floor(y * 0.78), v15)
		v14.Size = UDim2.fromOffset(math.floor(y * 0.58), v15)
	end
	layout()
	table.insert(connections, parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout))
end

local function skinHeaderButton(button)
	if not button:IsA("TextButton") or button:FindFirstChild("NewUIStroke") then
		return
	end

	track(mk("UIStroke", { -- inferred equivalent call
		Name = "NewUIStroke",
		Color = v.Border,
		Thickness = 1,
		Transparency = 0.15,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, button))
end

local function buildHeader()
	local header = v7.Header
	local parent = track(mk( -- inferred equivalent call
		"Frame",
		{
			Name = "NewUIDecor",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 0
		},
		header
	))
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = "Plate",
		BackgroundColor3 = v.Plate,
		BackgroundTransparency = 0.15,
		Position = UDim2.new(0, 0, 0, 2),
		Size = UDim2.new(1, 0, 1, -3),
		ZIndex = 0
	}, parent)
	mk("UICorner", { CornerRadius = UDim.new(0, 3) }, parent2) -- inferred equivalent call
	mk("UIStroke", { Color = Color3.fromRGB(6, 6, 6), Thickness = 2, Transparency = 0.1 }, parent2) -- inferred equivalent call
	grime(parent, 47, 0, 4, 4, 22)
	local parent3 = mk("Frame", { -- inferred equivalent call
		Name = "EdgeWear",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 3, 0, 4),
		Size = UDim2.new(1, -6, 1, -8),
		ZIndex = 0
	}, parent)
	mk("UIStroke", { Color = v.Edge, Thickness = 1, Transparency = 0.75 }, parent3) -- inferred equivalent call
	mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent3) -- inferred equivalent call

	local parent4 = mk("Frame", { -- inferred equivalent call
		Name = "Rule",
		BackgroundColor3 = v.Amber,
		BackgroundTransparency = 0.5,
		Position = UDim2.new(0, 10, 1, -3),
		Size = UDim2.new(1, -20, 0, 2),
		ZIndex = 0
	}, parent)
	mk("UIGradient", { -- inferred equivalent call
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.18, 0.2),
			NumberSequenceKeypoint.new(0.19, 1),
			NumberSequenceKeypoint.new(0.23, 1),
			NumberSequenceKeypoint.new(0.24, 0.1),
			NumberSequenceKeypoint.new(0.62, 0.1),
			NumberSequenceKeypoint.new(0.63, 1),
			NumberSequenceKeypoint.new(0.66, 1),
			NumberSequenceKeypoint.new(0.67, 0.3),
			NumberSequenceKeypoint.new(1, 0.3)
		})
	}, parent4)

	tape(parent, "TapeL", UDim2.new(0, -16, 0, -2), UDim2.fromOffset(46, 12), -36, v.Tape, 0.1, 0)
	tape(parent, "TapeR", UDim2.new(1, -30, 0, -2), UDim2.fromOffset(44, 12), 36, v.TapeDark, 0.12, 0)

	for _, child in ipairs(header:GetChildren()) do
		skinHeaderButton(child)
	end

	local sizeControls = v7.Panel:FindFirstChild("SizeControls")

	if sizeControls then
		for _, child in ipairs(sizeControls:GetChildren()) do
			skinHeaderButton(child)
		end
	end

	table.insert(connections, header.ChildAdded:Connect(function(child)
		if flag then
			task.defer(skinHeaderButton, child)
		end
	end))
end

local function buildPopupDecor(frame, total)
	if frame:FindFirstChild("NewUIDecor") then
		return
	end

	local zIndex = frame.ZIndex
	local parent = track(mk("Frame", { -- inferred equivalent call
		Name = "NewUIDecor",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -8, 0, -8),
		Size = UDim2.new(1, 16, 1, 16),
		ZIndex = zIndex
	}, frame))

	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = "Clip",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Size = UDim2.fromScale(1, 1),
		ZIndex = zIndex
	}, parent)
	vignette(parent2, "VigTop", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 40), 90, 0.55, zIndex)
	vignette(parent2, "VigBottom", UDim2.new(0, 0, 1, -40), UDim2.new(1, 0, 0, 40), 270, 0.5, zIndex)
	vignette(parent2, "VigLeft", UDim2.new(0, 0, 0, 0), UDim2.new(0, 36, 1, 0), 0, 0.6, zIndex)
	vignette(parent2, "VigRight", UDim2.new(1, -36, 0, 0), UDim2.new(0, 36, 1, 0), 180, 0.6, zIndex)
	grime(parent2, total, zIndex, 8, 8, 40)
	local parent3 = mk("Frame", { -- inferred equivalent call
		Name = "EdgeWear",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 4, 0, 4),
		Size = UDim2.new(1, -8, 1, -8),
		ZIndex = zIndex
	}, parent2)
	mk("UIStroke", { Color = v.Edge, Thickness = 1, Transparency = 0.75 }, parent3) -- inferred equivalent call
	mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent3) -- inferred equivalent call
	tape(parent, "TapeTL", UDim2.new(0, -18, 0, -2), UDim2.fromOffset(54, 13), -38, v.Tape, 0.1, zIndex)
	tape(parent, "TapeBR", UDim2.new(1, -38, 1, -12), UDim2.fromOffset(52, 12), -38, v.TapeDark, 0.14, zIndex)
	tape(parent, "TapeBL", UDim2.new(0, -16, 1, -14), UDim2.fromOffset(40, 11), 36, v.Tape, 0.2, zIndex)
end

local function decoratePopups()
	local total = 70

	for _, guiObject in ipairs(v7.Panel:GetChildren()) do
		if not (guiObject:IsA("GuiObject") and guiObject.Name:match("Holder$")) then
			continue
		end

		for _, frame in ipairs(guiObject:GetChildren()) do
			if not (frame:IsA("Frame") and frame.Name:match("Popup$")) then
				continue
			end

			total += 13
			buildPopupDecor(frame, total)
		end
	end
end

local color = Color3.fromRGB(255, 196, 80)

local function reduceMotion()
	local success, result = pcall(function()
		return SettingsState.GetReduceMotionEnabled()
	end)

	return success and result == true
end

local function skinPad(state)
	local button = state.Button
	local viewport = state.Viewport
	local spec = state.Spec

	if not (button and spec) then
		return
	end

	local z = spec.Z or 3

	v9[state] = v9[state] or { Base = state.Base, Pressed = state.Pressed }
	local v12 = v2[spec.Kind]

	if v12 then
		state.Base = v12
		state.Pressed = v12:Lerp(Color3.fromRGB(255, 190, 70), 0.6)

		if (state.Count or 0) == 0 then
			button.BackgroundColor3 = v12
		end
	end

	if viewport then
		setp(viewport, "ZIndex", 20 + 4 * z) -- inferred equivalent call
	end

	setp(button, "ZIndex", 21 + 4 * z) -- inferred equivalent call
	local zIndex = 22 + 4 * z

	local uiStroke = button:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		setp(uiStroke, "Thickness", 3) -- inferred equivalent call
		setp(uiStroke, "Color", v.Ink) -- inferred equivalent call
	end

	local parent = track(mk("Frame", { -- inferred equivalent call
		Name = "NewUIPad_" .. (spec.Pad or "x"),
		BackgroundTransparency = 1,
		AnchorPoint = button.AnchorPoint,
		Position = button.Position,
		Size = button.Size,
		ZIndex = zIndex
	}, v7.PadArea))
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = "Outer",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, 7, 1, 7),
		ZIndex = zIndex
	}, parent)

	mk("UICorner", { CornerRadius = UDim.new(0.5, 0) }, parent2) -- inferred equivalent call
	mk("UIStroke", { Color = v.Edge, Thickness = 1.5, Transparency = 0.45 }, parent2) -- inferred equivalent call

	table.insert(connections, button:GetPropertyChangedSignal("Position"):Connect(function()
		parent.Position = button.Position
	end))

	setp(button, "Font", Enum.Font.Sarpanch) -- inferred equivalent call
	setp(button, "TextColor3", Color3.fromRGB(240, 232, 205)) -- inferred equivalent call
	setp(button, "TextStrokeColor3", Color3.new(0, 0, 0)) -- inferred equivalent call
	setp(button, "TextStrokeTransparency", 0.05) -- inferred equivalent call
	local v13 = {}

	for _, v14 in ipairs({ viewport, button, parent }) do
		if v14 then
			table.insert(v13, track(mk("UIScale", { Scale = 1 }, v14))) -- inferred equivalent call
		end
	end

	local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tweenInfo3 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function burst()
		local padArea = v7.PadArea
		local parent3 = mk("Frame", { -- inferred equivalent call
			Name = "NewUIHitRing",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = button.Position,
			Size = button.Size,
			ZIndex = zIndex + 1
		}, padArea)

		mk("UICorner", { CornerRadius = UDim.new(0.5, 0) }, parent3) -- inferred equivalent call
		local uiStroke2 = mk("UIStroke", { Color = color, Thickness = 3, Transparency = 0.1 }, parent3) -- inferred equivalent call
		TweenService:Create(parent3, tweenInfo3, {
			Size = UDim2.new(button.Size.X.Scale * 1.5, 0, button.Size.Y.Scale * 1.5, 0)
		}):Play()
		TweenService:Create(uiStroke2, tweenInfo3, { Transparency = 1, Thickness = 1 }):Play()
		Debris:AddItem(parent3, 0.35)

		for i = 1, 4 do
			local v14 = math.rad((i - 1) * 90 + math.random(-30, 30))
			local frame = mk("Frame", { -- inferred equivalent call
				Name = "NewUISpark",
				BackgroundColor3 = color,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = button.Position,
				Size = UDim2.fromOffset(2, math.random(6, 10)),
				Rotation = math.deg(v14) + 90,
				ZIndex = zIndex + 1
			}, padArea)

			local v15 = math.cos(v14) * button.Size.X.Scale * 0.78
			local v16 = math.sin(v14) * button.Size.Y.Scale * 0.78
			TweenService:Create(frame, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(button.Position.X.Scale + v15, button.Position.Y.Scale + v16),
				BackgroundTransparency = 1
			}):Play()
			Debris:AddItem(frame, 0.32)
		end
	end

	local v14 = false
	local function update()
		local v15 = (state.Count or 0) > 0

		if v15 == v14 then
			return
		end

		v14 = v15
		local success, result = pcall(function()
			return SettingsState.GetReduceMotionEnabled()
		end)
		local v16 = success and result == true

		for _, instance in ipairs(v13) do
			TweenService:Create(instance, v15 and tweenInfo or tweenInfo2, {
				Scale = v15 and (v16 and 0.97 or 0.92) or 1
			}):Play()
		end

		if uiStroke then
			TweenService:Create(uiStroke, TweenInfo.new(v15 and 0.04 or 0.22), {
				Color = v15 and color or v.Ink
			}):Play()
		end

		if v15 and not v16 then
			burst()
		end
	end

	table.insert(connections, button:GetPropertyChangedSignal("BackgroundColor3"):Connect(update))
end

local function apply()
	flag = true
	buildBoard()
	buildHeader()
	decoratePopups()

	for _, padFrame in pairs(v7.PadFrames) do
		local success, result = pcall(skinPad, padFrame)

		if not success then
			warn("[DrumUISkin] skinPad:", result)
		end
	end

	for _, descendant in ipairs(v7.ScreenGui:GetDescendants()) do
		skinInst(descendant)
	end

	table.insert(connections, v7.ScreenGui.DescendantAdded:Connect(function(descendant)
		if flag then
			task.defer(function()
				if flag and descendant.Parent then
					skinInst(descendant)
				end
			end)
		end
	end))

	if v7.PadArea then
		for _, button in ipairs(v7.PadArea:GetChildren()) do
			if not (button:IsA("TextButton") and button.Name ~= "" and oswalds[button.Font] and button.TextTransparency < 1) then
				continue
			end

			if button.Text ~= "" then
				continue
			end

			setp(button, "Font", Enum.Font.Oswald) -- inferred equivalent call
		end
	end
end

local function revert()
	flag = false

	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	connections = {}

	for _, descendant in ipairs(v7.ScreenGui:GetDescendants()) do
		if inScope(descendant) then
			mapWith(descendant, v5)
		end
	end

	for _, v12 in ipairs(v10) do
		if v12.Parent then
			v12:Destroy()
		end
	end

	v10 = {}

	for k, v12 in pairs(v8) do
		for k2, v13 in pairs(v12) do
			local v14 = k2
			local v15 = v13
			pcall(function()
				k[v14] = v15
			end)
		end
	end

	v8 = {}
	instanceSet = {}

	for k, v12 in pairs(v9) do
		k.Base = v12.Base
		k.Pressed = v12.Pressed

		if (k.Count or 0) == 0 and k.Button then
			k.Button.BackgroundColor3 = k.Base
		end
	end

	v9 = {}
	v11 = nil
end

local function refresh()
	local v12 = SettingsState.GetUIStyle() == "NewUI"

	if v12 == flag then
		if flag and v11 then
			local v13 = v11
			local v14 = 0.58
			local success, result = pcall(function()
				return SettingsState.GetFreePlayOpacity()
			end)

			if success and type(result) == "number" then
				v14 = result
			end

			v13.BackgroundTransparency = math.clamp(1 - v14 * 0.75, 0.2, 0.9)
		end
	elseif v12 then
		apply()
	else
		revert()
	end
end

function DrumUISkin.Init(p)
	if v7 then
		return
	end

	v7 = p
	SettingsState.OnChanged(function()
		local success, result = pcall(refresh)

		if not success then
			warn("[DrumUISkin]", result)
		end
	end)
	local success, result = pcall(refresh)

	if not success then
		warn("[DrumUISkin]", result)
	end
end

return DrumUISkin