local font = game:GetService("Players")
local RunService = game:GetService("RunService")
local result = game:GetService("UserInputService")

local RockMeterUI = {}

local playerGui = font.LocalPlayer:WaitForChild("PlayerGui")
local v = result.TouchEnabled and not result.KeyboardEnabled

local function fontOr(p, p2)
	local success, result2 = pcall(function()
		return Enum.Font[p]
	end)
	return success and result2 or p2
end

font = Enum.Font.GothamBold
local v2 = "Oswald"
local success
success, result = pcall(function()
	return Enum.Font[v2]
end)
font = success and result or font
local font2 = Enum.Font.GothamBold
local v3 = "SpecialElite"
local success2
success2, result = pcall(function()
	return Enum.Font[v3]
end)
font2 = success2 and result or font2
result = Enum.Font.GothamBlack
local v4 = "PermanentMarker"
local success3, result2 = pcall(function()
	return Enum.Font[v4]
end)
result = success3 and result2 or result
local scale = v and 5 / 7 or 15 / 14
local v5 = (v and 92 or 79) * scale

result2 = require(script.Parent:WaitForChild("RockMeterConfig"))
local GuiFade = require(script.Parent:WaitForChild("GuiFade"))
local start = result2.Start
local step = result2.Step
local zoneLow = result2.ZoneLow
local zoneHigh = result2.ZoneHigh
local fullGreen = result2.FullGreen

result2 = Color3.fromRGB(20, 20, 19)
local color = Color3.fromRGB(15, 15, 14)
Color3.fromRGB(64, 62, 58)
local color2 = Color3.fromRGB(86, 84, 80)
local color3 = Color3.fromRGB(222, 220, 214)
local color4 = Color3.fromRGB(158, 156, 150)
local color5 = Color3.fromRGB(204, 162, 72)
local color6 = Color3.fromRGB(8, 8, 8)
local color7 = Color3.fromRGB(122, 120, 114)
local color8 = Color3.fromRGB(74, 42, 28)
local color9 = Color3.fromRGB(150, 147, 140)
local color10 = Color3.fromRGB(56, 54, 50)
local color11 = Color3.new(1, 1, 1)
local color12 = Color3.fromRGB(70, 150, 168)

local color13 = Color3.fromRGB(75, 200, 220)
local color14 = Color3.fromRGB(200, 245, 255)
local color15 = Color3.fromRGB(235, 252, 255)
local color16 = Color3.fromRGB(255, 132, 44)
local color17 = Color3.fromRGB(60, 170, 235)

local v6 = {
	{ 0, Color3.fromRGB(150, 40, 34) },
	{ 0.25, Color3.fromRGB(190, 92, 34) },
	{ 0.5, Color3.fromRGB(212, 168, 50) },
	{ 0.75, Color3.fromRGB(128, 168, 58) },
	{ 1, Color3.fromRGB(54, 160, 92) }
}

local function skillToColor(value)
	local v7 = math.clamp(value, 0, 1)

	for i = 1, #v6 - 1 do
		local v8 = v6[i][1]
		local v9 = v6[i][2]
		local v10 = v6[i + 1][1]
		local v11 = v6[i + 1][2]

		if v7 <= v10 then
			return v9:Lerp(v11, v10 - v8 > 0 and (v7 - v8) / (v10 - v8) or 0)
		end
	end

	return v6[#v6][2]
end

local function chargeUp(p, p2, p3) -- 4 equivalent calls inferred from this helper
	local hsv, v7, v8 = p:ToHSV()
	return Color3.fromHSV(hsv, math.clamp(v7 + p2, 0, 1), (math.clamp(v8 + p3, 0, 1)))
end

local function rnd(p, p2) -- 23 equivalent calls inferred from this helper
	return p + math.random() * (p2 - p)
end

local v7 = chargeUp(v6[1][2], 0.12, 0.3) -- inferred equivalent call
local hsv, v8, v9 = v6[3][2]:ToHSV()
local v10 = {
	v7,
	Color3.fromHSV(hsv, math.clamp(v8 + 0.08, 0, 1), (math.clamp(v9 + 0.28, 0, 1))),
	chargeUp(v6[5][2], 0.08, 0.3)
}

local function zoneOfValue(p): number -- 1 equivalent call inferred from this helper
	if p < zoneLow then
		return 1
	end

	return if p < zoneHigh then 2 else 3
end

local function mk(className, items, parent) -- 58 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function gradient(parent, p, color18, value) -- 5 equivalent calls inferred from this helper
	return mk("UIGradient", { -- inferred equivalent call
		Color = ColorSequence.new(p, color18),
		Rotation = value or 90
	}, parent)
end

local function circleOf(parent) -- 6 equivalent calls inferred from this helper
	mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent) -- inferred equivalent call
end

local v11 = {
	Name = "RockMeterUI",
	ResetOnSpawn = false,
	DisplayOrder = 14,
	ZIndexBehavior = Enum.ZIndexBehavior.Global
}
local screenGui = Instance.new("ScreenGui")
local v12 = start
local v13 = v12
v7 = v12
v7 = v13
local v14 = false
local v15 = 2
local v16 = nil
local v17 = -1
local v18 = 0
local v19 = 0
local v20 = 0
local v21 = { 0, 0, 0 }
local v22 = { spark = 0, bolt = 0 }
local v23 = v and 104 or 0
local v24 = nil
local v25 = nil
local flag = false
local total = 1

for k, v26 in pairs(v11) do
	screenGui[k] = v26
end

screenGui.Parent = playerGui

local parent = mk("CanvasGroup", { -- inferred equivalent call
	Name = "Container",
	AnchorPoint = Vector2.new(0, 0),
	Size = UDim2.fromOffset(192, 174),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	GroupTransparency = 1,
	Visible = false,
	ZIndex = 1
}, screenGui)

mk("UIScale", { Scale = scale }, parent) -- inferred equivalent call
GuiFade.Attach(parent, "Hud", 0.8, GuiFade.Presets.RockMeter)

local parent2 = mk("Frame", { -- inferred equivalent call
	Name = "Plate",
	Position = UDim2.fromOffset(26, 26),
	Size = UDim2.fromOffset(140, 122),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 1
}, parent)

local parent3 = mk("Frame", { -- inferred equivalent call
	Name = "Fx",
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 40
}, parent)

local parent4 = mk("Frame", { -- inferred equivalent call
	Name = "Shadow",
	Position = UDim2.fromOffset(3, 5),
	Size = UDim2.fromOffset(140, 122),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.5,
	BorderSizePixel = 0,
	ZIndex = 1
}, parent2)

mk("UICorner", { CornerRadius = UDim.new(0, 5) }, parent4) -- inferred equivalent call

local parent5 = mk("Frame", { -- inferred equivalent call
	Name = "Body",
	Size = UDim2.fromOffset(140, 122),
	BackgroundColor3 = result2,
	BorderSizePixel = 0,
	ZIndex = 2
}, parent2)

mk("UICorner", { CornerRadius = UDim.new(0, 4) }, parent5) -- inferred equivalent call
mk("UIStroke", { Color = color6, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, parent5) -- inferred equivalent call
result2 = Color3.fromRGB(255, 255, 255)
gradient(parent5, result2, Color3.fromRGB(205, 203, 198), nil) -- inferred equivalent call

local v26 = { 33, 70, 107 }
local v27 = {}
local vector2s = {}

for i = 1, 3 do
	local parent6 = mk("Frame", { -- inferred equivalent call
		Name = "LampSlot",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(v26[i], 15),
		Size = UDim2.fromOffset(38, 16),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ZIndex = 4
	}, parent2)

	mk("UICorner", { CornerRadius = UDim.new(0, 3) }, parent6) -- inferred equivalent call
	mk("UIStroke", { Color = color2, Thickness = 1, Transparency = 0.25 }, parent6) -- inferred equivalent call
	local lens = mk("Frame", { -- inferred equivalent call
		Name = "Lens",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -6, 1, -6),
		BackgroundColor3 = v10[i],
		BorderSizePixel = 0,
		ZIndex = 5
	}, parent6)

	mk("UICorner", { CornerRadius = UDim.new(0, 2) }, lens) -- inferred equivalent call
	gradient(lens, Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 150, 150), nil) -- inferred equivalent call
	local stroke = mk("UIStroke", { Color = color6, Thickness = 1, Transparency = 0.3 }, lens) -- inferred equivalent call
	mk("Frame", { -- inferred equivalent call
		Name = "Gloss",
		Position = UDim2.new(0, 2, 0, 1),
		Size = UDim2.new(1, -4, 0, 2),
		BackgroundColor3 = color11,
		BackgroundTransparency = 0.78,
		BorderSizePixel = 0,
		ZIndex = 6
	}, lens)

	v27[i] = { Lens = lens, Stroke = stroke }
	vector2s[i] = Vector2.new(26 + v26[i], 41)
end

local parent6 = mk("Frame", { -- inferred equivalent call
	Name = "DialClip",
	Position = UDim2.fromOffset(12, 30),
	Size = UDim2.fromOffset(116, 59),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	ZIndex = 3
}, parent2)

local parent7 = mk("Frame", { -- inferred equivalent call
	Name = "Bezel",
	Size = UDim2.fromOffset(116, 116),
	BackgroundColor3 = color11,
	BorderSizePixel = 0,
	ZIndex = 4
}, parent6)
circleOf(parent7) -- inferred equivalent call
gradient(parent7, color9, color10) -- inferred equivalent call
local uiStroke2 = mk("UIStroke", { Color = color6, Thickness = 2 }, parent7) -- inferred equivalent call

local parent8 = mk("Frame", { -- inferred equivalent call
	Name = "Face",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(58, 58),
	Size = UDim2.fromOffset(106, 106),
	BackgroundColor3 = color11,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	ZIndex = 5
}, parent6)
circleOf(parent8) -- inferred equivalent call
result2 = Color3.fromRGB(46, 44, 41)
gradient(parent8, result2, Color3.fromRGB(13, 13, 12), nil) -- inferred equivalent call
mk("UIStroke", { Color = color6, Thickness = 1.5, Transparency = 0.1 }, parent8) -- inferred equivalent call

local function polarPos(p, p2) -- 2 equivalent calls inferred from this helper
	local v28 = math.rad(p2)
	return 53 + p * math.sin(v28), 53 - p * math.cos(v28)
end

local v28 = {
	{ 0, zoneLow },
	{ zoneLow, zoneHigh },
	{ zoneHigh, 1 }
}
local v29 = { {}, {}, {} }

for i = 1, 3 do
	local v30 = v28[i][1]
	local v31 = v28[i][2]
	local v32 = -72 + 144 * v30
	local v45 = -72 + 144 * v31
	local v46 = math.max(6, (math.floor((v45 - v32) / 2.4)))

	for j = 0, v46 - 1 do
		local rotation = v32 + (j + 0.5) * (v45 - v32) / v46
		local v48, v49 = polarPos(47, rotation) -- inferred equivalent call
		local v50 = math.rad((v45 - v32) / v46) * 47 + 1.2
		local frame = mk("Frame", { -- inferred equivalent call
			Name = "Band",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(v48, v49),
			Size = UDim2.fromOffset(v50, 4.5),
			Rotation = rotation,
			BackgroundColor3 = v10[i],
			BorderSizePixel = 0,
			ZIndex = 6
		}, parent8)

		v29[i][#v29[i] + 1] = frame
	end
end

local v30 = {}

for i = 0, 20 do
	local rotation = i / 20 * 144 + -72
	local v31 = i % 5 == 0
	local v32 = v31 and 38 or 40
	local v46, v47 = polarPos((v32 + 45) / 2, rotation) -- inferred equivalent call

	v30[i] = mk("Frame", { -- inferred equivalent call
		Name = "Tick",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(v46, v47),
		Size = UDim2.fromOffset(v31 and 2 or 1.5, 45 - v32),
		Rotation = rotation,
		BackgroundColor3 = color4,
		BorderSizePixel = 0,
		ZIndex = 6
	}, parent8)
end

local parent9 = mk("TextLabel", { -- inferred equivalent call
	Name = "RockText",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(53, 33),
	Size = UDim2.fromOffset(84, 30),
	BackgroundTransparency = 1,
	Font = result,
	Text = "ROCK",
	TextSize = 26,
	TextColor3 = skillToColor(start),
	ZIndex = 7
}, parent8)

mk("UIStroke", { Color = Color3.fromRGB(6, 8, 8), Thickness = 2.5 }, parent9) -- inferred equivalent call

local parent10 = mk("Frame", { -- inferred equivalent call
	Name = "Glare",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(33, 35),
	Size = UDim2.fromOffset(20, 130),
	Rotation = 28,
	BackgroundColor3 = color11,
	BorderSizePixel = 0,
	ZIndex = 8
}, parent8)

mk("UIGradient", { -- inferred equivalent call
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.93),
		NumberSequenceKeypoint.new(1, 1)
	})
}, parent10)

local function buildNeedle(p, p2, p3, backgroundColor, backgroundTransparency, p4, zIndex)
	local parent11 = mk("Frame", { -- inferred equivalent call
		Name = p .. "Root",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(53 + p2, 53 + p3),
		Size = UDim2.fromOffset(94, 94),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = zIndex
	}, parent8)

	local function part(name, p5, p6, p7, p8)
		return mk("Frame", { -- inferred equivalent call
			Name = name,
			AnchorPoint = Vector2.new(0.5, p5),
			Position = UDim2.new(0.5, 0, 0.5, p6),
			Size = UDim2.fromOffset(p7, p8),
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = backgroundTransparency,
			BorderSizePixel = 0,
			ZIndex = zIndex
		}, parent11)
	end

	local parent12 = part("Blade", 1, 0, 3, 47)
	part("Base", 1, 0, 5.5, 15.040000000000001)
	part("Tail", 0, 0, 4.5, 9)
	local uiStroke

	if not p4 then
		return parent11, uiStroke
	end

	local v31 = { Color = Color3.fromRGB(6, 6, 6), Thickness = 1, Transparency = 0.2 }
	uiStroke = Instance.new("UIStroke")

	for k, v32 in pairs(v31) do
		uiStroke[k] = v32
	end

	uiStroke.Parent = parent12

	return parent11, uiStroke
end

local needle = buildNeedle("NeedleShadow", 2, 3, Color3.new(0, 0, 0), 0.55, false, 8)
local needle2, v31 = buildNeedle("Needle", 0, 0, color3, 0, true, 9)

local parent11 = mk("Frame", { -- inferred equivalent call
	Name = "Shelf",
	Position = UDim2.fromOffset(12, 88),
	Size = UDim2.fromOffset(116, 12),
	BackgroundColor3 = color11,
	BorderSizePixel = 0,
	ZIndex = 4
}, parent2)

mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent11) -- inferred equivalent call
result = Color3.fromRGB(96, 94, 89)
gradient(parent11, result, Color3.fromRGB(38, 37, 35), nil) -- inferred equivalent call
local uiStroke = mk("UIStroke", { Color = color6, Thickness = 1.5 }, parent11) -- inferred equivalent call

local function shelfLabel(text, p, textXAlignment)
	mk("TextLabel", { -- inferred equivalent call
		Name = "ShelfLabel",
		Position = UDim2.fromOffset(p, 89),
		Size = UDim2.fromOffset(34, 10),
		BackgroundTransparency = 1,
		Font = font2,
		Text = text,
		TextSize = 9,
		TextColor3 = color4,
		TextXAlignment = textXAlignment,
		ZIndex = 6
	}, parent2)
end
shelfLabel("LOW", 18, Enum.TextXAlignment.Left)
shelfLabel("HIGH", 88, Enum.TextXAlignment.Right)

local parent12 = mk("Frame", { -- inferred equivalent call
	Name = "Hub",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(70, 88),
	Size = UDim2.fromOffset(20, 20),
	BackgroundColor3 = color11,
	BorderSizePixel = 0,
	ZIndex = 11
}, parent2)
circleOf(parent12) -- inferred equivalent call
result = Color3.fromRGB(170, 167, 160)
local color18 = Color3.fromRGB(48, 47, 44)
mk("UIGradient", { -- inferred equivalent call
	Color = ColorSequence.new(result, color18),
	Rotation = 45
}, parent12)

local uiStroke3 = mk("UIStroke", { Color = color6, Thickness = 1.5 }, parent12) -- inferred equivalent call
local parent13 = mk("Frame", { -- inferred equivalent call
	Name = "Cap",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.fromOffset(8, 8),
	BackgroundColor3 = Color3.fromRGB(62, 60, 56),
	BorderSizePixel = 0,
	ZIndex = 12
}, parent12)
circleOf(parent13) -- inferred equivalent call
mk("Frame", { -- inferred equivalent call
	Name = "Slot",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(1, -2, 0, 1),
	Rotation = 35,
	BackgroundColor3 = color6,
	BorderSizePixel = 0,
	ZIndex = 13
}, parent13)

mk("Frame", { -- inferred equivalent call
	Name = "TitleLine",
	Position = UDim2.fromOffset(10, 103),
	Size = UDim2.fromOffset(120, 1),
	BackgroundColor3 = color2,
	BackgroundTransparency = 0.3,
	BorderSizePixel = 0,
	ZIndex = 5
}, parent2)

local textLabel = mk("TextLabel", { -- inferred equivalent call
	Name = "Title",
	Position = UDim2.fromOffset(10, 104),
	Size = UDim2.fromOffset(120, 15),
	BackgroundTransparency = 1,
	Font = font,
	Text = "ROCK METER",
	TextSize = 14,
	TextColor3 = color5,
	ZIndex = 5
}, parent2)

local folder = mk("Frame", { -- inferred equivalent call
	Name = "DecorFront",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 1, 0),
	ZIndex = 20
}, parent2)

local random = Random.new(23)

local function vignette(name, position, size, rotation, p)
	local parent14 = mk("Frame", { -- inferred equivalent call
		Name = name,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		Position = position,
		Size = size
	}, folder)
	mk("UIGradient", { -- inferred equivalent call
		Rotation = rotation,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, p), NumberSequenceKeypoint.new(1, 1) })
	}, parent14)
end
vignette("VigTop", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 14), 90, 0.5)
vignette("VigBottom", UDim2.new(0, 0, 1, -14), UDim2.new(1, 0, 0, 14), 270, 0.5)
vignette("VigLeft", UDim2.new(0, 0, 0, 0), UDim2.new(0, 14, 1, 0), 0, 0.55)
vignette("VigRight", UDim2.new(1, -14, 0, 0), UDim2.new(0, 14, 1, 0), 180, 0.55)

for i = 1, 4 do
	local integer = random:NextInteger(26, 56)
	circleOf(mk("Frame", { -- inferred equivalent call
		Name = "Stain" .. i,
		BackgroundColor3 = i % 2 == 0 and color8 or Color3.new(0, 0, 0),
		BackgroundTransparency = 0.88 + random:NextNumber() * 0.06,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(random:NextNumber() * 0.8, random:NextNumber() * 0.8),
		Size = UDim2.new(0, integer, 0, (math.floor(integer * (0.35 + random:NextNumber() * 0.4))))
	}, folder))
end

for i, v32 in ipairs({
	{ 0.08, 0.3, 50, 24 },
	{ 0.58, 0.46, 40, -31 },
	{ 0.28, 0.8, 60, 12 },
	{ 0.7, 0.12, 34, 40 }
}) do
	mk("Frame", { -- inferred equivalent call
		Name = "Scratch" .. i,
		BackgroundColor3 = color3,
		BackgroundTransparency = 0.9,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(v32[1], v32[2]),
		Size = UDim2.new(0, v32[3], 0, 1),
		Rotation = v32[4]
	}, folder)
end

for i = 1, 3 do
	mk("Frame", { -- inferred equivalent call
		Name = "Scuff" .. i,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
		Size = UDim2.new(0, random:NextInteger(16, 34), 0, 1),
		Rotation = random:NextInteger(-60, 60)
	}, folder)
end

for i = 1, 22 do
	local v32 = random:NextNumber() > 0.35
	local integer = random:NextInteger(1, 2)
	mk("Frame", { -- inferred equivalent call
		Name = "Speck" .. i,
		BackgroundColor3 = v32 and color3 or Color3.new(0, 0, 0),
		BackgroundTransparency = v32 and 0.8 + random:NextNumber() * 0.12 or 0.45 + random:NextNumber() * 0.25,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
		Size = UDim2.new(0, integer, 0, integer)
	}, folder)
end

for i = 1, 6 do
	mk("Frame", { -- inferred equivalent call
		Name = "Chip" .. i,
		BackgroundColor3 = color8,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		Position = i % 2 == 0 and UDim2.new(
			i % 4 == 0 and 0 or 1,
			i % 4 == 0 and 1 or -4,
			random:NextNumber(0.1, 0.9),
			0
		) or UDim2.new(random:NextNumber(0.1, 0.9), 0, i % 3 == 0 and 0 or 1, i % 3 == 0 and 1 or -3),
		Size = UDim2.fromOffset(random:NextInteger(2, 4), random:NextInteger(2, 3))
	}, folder)
end

local parent14 = mk("Frame", { -- inferred equivalent call
	Name = "EdgeWear",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 3, 0, 3),
	Size = UDim2.new(1, -6, 1, -6)
}, folder)
local uiStroke4 = mk("UIStroke", { Color = color7, Thickness = 1.5, Transparency = 0.55 }, parent14) -- inferred equivalent call
mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent14) -- inferred equivalent call

for _, guiObject in ipairs(folder:GetDescendants()) do
	if guiObject:IsA("GuiObject") then
		guiObject.ZIndex = 20
	end
end

local function rivet(p, p2)
	local parent15 = mk("Frame", { -- inferred equivalent call
		Name = "Rivet",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(p, p2),
		Size = UDim2.fromOffset(7, 7),
		BackgroundColor3 = color11,
		BorderSizePixel = 0,
		ZIndex = 22
	}, parent2)
	circleOf(parent15) -- inferred equivalent call
	local color19 = Color3.fromRGB(196, 192, 182)
	local color20 = Color3.fromRGB(70, 68, 63)
	mk("UIGradient", { -- inferred equivalent call
		Color = ColorSequence.new(color19, color20),
		Rotation = 45
	}, parent15)

	mk("UIStroke", { Color = color6, Thickness = 1, Transparency = 0.05 }, parent15) -- inferred equivalent call
	mk("Frame", { -- inferred equivalent call
		Name = "Slot",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -2, 0, 1),
		Rotation = random:NextInteger(0, 170),
		BackgroundColor3 = color6,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		ZIndex = 23
	}, parent15)

	mk("Frame", { -- inferred equivalent call
		Name = "RustDrip",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromOffset(p + random:NextInteger(-1, 1), p2 + 3),
		Size = UDim2.fromOffset(2, random:NextInteger(7, 15)),
		BackgroundColor3 = color8,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		ZIndex = 21
	}, parent2)
end
rivet(8, 8)
rivet(132, 8)
rivet(8, 114)
rivet(132, 114)
rivet(17, 94)
rivet(123, 94)
local v32 = v and 14 or 30
local v55 = v and 3 or 6
local v56 = v and 4 or 5
local v57 = {}
local v58 = {}
local v59 = 0
local v60 = 0

local function acquire(zIndex) -- 5 equivalent calls inferred from this helper
	local selected = table.remove(v58)

	if not selected then
		selected = Instance.new("Frame")
		selected.AnchorPoint = Vector2.new(0.5, 0.5)
		selected.BorderSizePixel = 0
	end

	selected.ZIndex = zIndex
	selected.Rotation = 0
	selected.Visible = true
	selected.Parent = parent3
	return selected
end

local function release(p) -- 5 equivalent calls inferred from this helper
	p.Visible = false
	v58[#v58 + 1] = p
end

local function clearParticles()
	v57 = {}
	v59 = 0
	v60 = 0
	v58 = {}

	for _, child in ipairs(parent3:GetChildren()) do
		child.Visible = false
		v58[#v58 + 1] = child
	end
end

local function placeLine(p, p2, p3, p4, p5, p6)
	local v61 = p4 - p2
	local v62 = p5 - p3
	p.Position = UDim2.fromOffset((p2 + p4) / 2, (p3 + p5) / 2)
	p.Size = UDim2.fromOffset(math.sqrt(v61 * v61 + v62 * v62) + 0.5, p6)
	p.Rotation = math.deg((math.atan2(v62, v61)))
end

local function emitSpark(total2, total3, p, p2, p3, p4, p5, p6)
	if v32 <= v59 then
		return
	end

	v59 += 1
	local v61 = acquire(41) -- inferred equivalent call
	local v62 = math.cos(p) * p2
	local v63 = math.sin(p) * p2
	local total4 = 0
	v57[#v57 + 1] = function(p7): boolean
		total4 += p7

		if p3 <= total4 then
			v59 -= 1
			release(v61) -- inferred equivalent call
			return false
		else
			local v64 = math.exp(-2.4 * p7)
			v62 *= v64
			v63 = v63 * v64 + 380 * p7
			total2 += v62 * p7
			total3 += v63 * p7
			local v65 = total4 / p3
			local v66 = math.sqrt(v62 * v62 + v63 * v63)
			v61.Position = UDim2.fromOffset(total2, total3)
			v61.Rotation = math.deg((math.atan2(v63, v62)))
			v61.Size = UDim2.fromOffset(math.clamp(v66 * 0.045, 3, 18), (math.max(1.5, p4 * (1 - v65 * 0.5))))
			v61.BackgroundColor3 = p5:Lerp(p6, (math.clamp(v65 * 1.5, 0, 1)))
			v61.BackgroundTransparency = v65 * v65 * 0.95
			return true
		end
	end
end

local function emitBolt(p, y, p2, p3, p4, backgroundColor, backgroundColor2)
	if v55 <= v60 then
		return
	end

	v60 += 1
	local v61 = v56
	local v62 = v and 1.8 or 2.2
	local v63 = {}
	local v64 = {}

	for i = 1, v61 do
		local v65 = acquire(41) -- inferred equivalent call
		v65.BackgroundColor3 = backgroundColor
		v63[i] = v65
		local v66 = acquire(42) -- inferred equivalent call
		v66.BackgroundColor3 = backgroundColor2
		v64[i] = v66
	end

	local v65 = math.cos(p2)
	local v66 = math.sin(p2)
	local v67 = -v66
	local v68 = p3 * 0.22
	local function relayout()
		local v69 = {}
		local v70 = {}

		for i = 0, v61 do
			local v71 = i / v61
			local v72

			if i == 0 then
				v72 = 0
			else
				v72 = rnd(-v68, v68) * (1 - v71 * 0.25) -- inferred equivalent call
			end

			v69[i] = p + v65 * p3 * v71 + v67 * v72
			v70[i] = y + v66 * p3 * v71 + v65 * v72
		end

		for i = 1, v61 do
			placeLine(v63[i], v69[i - 1], v70[i - 1], v69[i], v70[i], v62 * 3)
			placeLine(v64[i], v69[i - 1], v70[i - 1], v69[i], v70[i], v62)
		end
	end
	relayout()
	local total2 = 0
	local total3 = 0
	v57[#v57 + 1] = function(p5): boolean
		total2 += p5
		total3 += p5

		if p4 <= total2 then
			for i = 1, v61 do
				release(v63[i]) -- inferred equivalent call
				release(v64[i]) -- inferred equivalent call
			end

			v60 -= 1
			return false
		else
			if total3 >= 0.045 then
				total3 = 0
				relayout()
			end

			local v69 = total2 / p4
			local v70 = math.random() < 0.28 and 0.4 or 0
			local backgroundTransparency = math.clamp(v69 * v69 * 0.9 + v70, 0, 1)
			local backgroundTransparency2 = math.clamp(0.7 + v69 * 0.3 + v70 * 0.3, 0, 1)

			for i = 1, v61 do
				v64[i].BackgroundTransparency = backgroundTransparency
				v63[i].BackgroundTransparency = backgroundTransparency2
			end

			return true
		end
	end
end

local function fxColors()
	if v14 then
		return color15, color16, color17, Color3.fromRGB(225, 248, 255)
	end

	local v61 = v10[v15]
	return
		chargeUp(v61, 0, 0.3):Lerp(color11, 0.35), -- inferred equivalent call
		v61:Lerp(Color3.fromRGB(110, 36, 18), 0.5),
		v61,
		chargeUp(v61, -0.2, 0.5):Lerp(color11, 0.45) -- inferred equivalent call
end

local function lampBurst(p, p2, p3)
	local v61, v62, backgroundColor, backgroundColor2 = fxColors()
	local v65 = vector2s[p]

	for _ = 1, p2 do
		local v66 = v65.X + rnd(-8, 8) -- inferred equivalent call
		local v67 = v65.Y + rnd(-3, 3) -- inferred equivalent call
		local v68 = -1.5708 + rnd(-1.4, 1.4) -- inferred equivalent call
		local v69 = rnd(110, 300) -- inferred equivalent call
		local v70 = rnd(0.35, 0.7) -- inferred equivalent call

		if v32 <= v59 then
			continue
		end

		v59 += 1
		local v71 = acquire(41) -- inferred equivalent call
		local v72 = math.cos(v68) * v69
		local v73 = math.sin(v68) * v69
		local total2 = 0
		local v74 = 2
		v57[#v57 + 1] = function(p4): boolean
			total2 += p4

			if v70 <= total2 then
				v59 -= 1
				release(v71) -- inferred equivalent call
				return false
			else
				local v75 = math.exp(-2.4 * p4)
				v72 *= v75
				v73 = v73 * v75 + 380 * p4
				v66 += v72 * p4
				v67 += v73 * p4
				local v76 = total2 / v70
				local v77 = math.sqrt(v72 * v72 + v73 * v73)
				v71.Position = UDim2.fromOffset(v66, v67)
				v71.Rotation = math.deg((math.atan2(v73, v72)))
				v71.Size = UDim2.fromOffset(math.clamp(v77 * 0.045, 3, 18), (math.max(1.5, v74 * (1 - v76 * 0.5))))
				v71.BackgroundColor3 = v61:Lerp(v62, (math.clamp(v76 * 1.5, 0, 1)))
				v71.BackgroundTransparency = v76 * v76 * 0.95
				return true
			end
		end
	end

	for _ = 1, p3 do
		emitBolt(
			v65.X + rnd(-10, 10), -- inferred equivalent call
			v65.Y,
			-1.5708 + rnd(-1.3, 1.3), -- inferred equivalent call
			rnd(22, 46), -- inferred equivalent call
			rnd(0.12, 0.22), -- inferred equivalent call
			backgroundColor,
			backgroundColor2
		)
	end
end

local function applyTheme()
	uiStroke4.Color = v14 and color12 or color7
	uiStroke4.Transparency = v14 and 0.3 or 0.55
	uiStroke3.Color = v14 and color12 or color6
	uiStroke.Color = v14 and color12 or color6
	uiStroke2.Color = v14 and color12 or color6
	v31.Color = v14 and Color3.fromRGB(10, 40, 50) or Color3.fromRGB(6, 6, 6)
	textLabel.TextColor3 = v14 and color13 or color5
	v16 = nil
	v17 = -1
end

local function resetState() -- 3 equivalent calls inferred from this helper
	v13 = start
	v12 = start
	v15 = 2
	v18 = 0
	v19 = 0
	v20 = 0
	v21 = { 0, 0, 0 }
	v22.spark = 0
	v22.bolt = 0
	v14 = false
	applyTheme()
end

local v61 = -100

local function onZoneChange(p, p2)
	v21[p] = 1
	local now = os.clock()

	if p ~= 1 and now - v61 < 4 then
		return
	end

	v61 = now
	v18 = math.max(v18, 1)
	v19 = 1
	v20 = 0.6
	lampBurst(p, v and 6 or 10, v and 2 or 3)

	if p == 1 and p2 == 2 then
		lampBurst(1, 4, 1)
	end
end

local function findStarBar() -- 1 equivalent call inferred from this helper
	local starPowerUI = playerGui:FindFirstChild("StarPowerUI")
	local meterContainer = starPowerUI and starPowerUI:FindFirstChild("MeterContainer", true)

	if meterContainer and starPowerUI.Enabled and meterContainer.Visible and meterContainer.AbsoluteSize.X > 0 then
		return meterContainer
	end

	return nil
end

local function laneUiOn() -- 1 equivalent call inferred from this helper
	local noteLaneUI = playerGui:FindFirstChild("NoteLaneUI")

	if noteLaneUI ~= nil and noteLaneUI.Enabled then
		return true
	end

	local noteLaneUI3D = playerGui:FindFirstChild("NoteLaneUI3D")
	return noteLaneUI3D ~= nil and noteLaneUI3D.Enabled
end

local function reposition(starBar)
	local absoluteSize = screenGui.AbsoluteSize
	local absolutePosition = screenGui.AbsolutePosition
	local v62 = starBar.AbsolutePosition - absolutePosition
	local absoluteSize2 = starBar.AbsoluteSize
	local v63 = 140 * scale
	local v64 = 122 * scale
	local v65 = v62.X + absoluteSize2.X + 22
	local noteLaneUI3D = playerGui:FindFirstChild("NoteLaneUI3D")

	if v65 + v63 > absoluteSize.X - 6 and not (noteLaneUI3D and noteLaneUI3D.Enabled) then
		v65 = v62.X - 22 - v63
	end

	local v66 = math.clamp(v65, 6, (math.max(6, absoluteSize.X - v63 - 6 - v23)))
	local v67 = math.max(6, (math.min(v62.Y + absoluteSize2.Y / 2 + v5 / 2 + 10, absoluteSize.Y - v64 - 6)))
	local v68 = math.floor(v66 - 26 * scale + 0.5)
	local v69 = math.floor(v67 - 26 * scale + 0.5)

	if v68 ~= v24 or v69 ~= v25 then
		v24 = v68
		v25 = v69
		parent.Position = UDim2.fromOffset(v68, v69)
	end
end

local function refreshScale(p)
	for i = 0, 20 do
		local v62 = i / 20
		local v63 = i <= p
		local backgroundColor

		if v14 then
			backgroundColor = v63 and color14 or color13:Lerp(color, 0.7)
		else
			local v65 = v10[zoneOfValue(v62)] -- inferred equivalent call

			backgroundColor = v63 and v65 or color4:Lerp(color, 0.45)
		end

		v30[i].BackgroundColor3 = backgroundColor
	end
end

local function refreshBands()
	for i = 1, 3 do
		local v62 = v14 and color13 or v10[i]
		local backgroundColor = i == v15 and v62 or v62:Lerp(color, 0.72)

		for _, v64 in ipairs(v29[i]) do
			v64.BackgroundColor3 = backgroundColor
		end
	end
end

local v62 = nil
local v63 = nil

local function step2(p)
	local starBar = findStarBar() -- inferred equivalent call
	local v64

	if starBar == nil then
		v64 = false
	else
		v64 = laneUiOn() -- inferred equivalent call
	end

	if v64 then
		local v65 = p > 0.05 and 0.05 or p

		if not flag then
			flag = true
			resetState() -- inferred equivalent call
			total = 1
			parent.GroupTransparency = 1
			parent.Visible = true
			v18 = 1.8
		end

		reposition(starBar)
		local now = os.clock()

		for i = #v57, 1, -1 do
			if v57[i](v65) then
				continue
			end

			v57[i] = v57[#v57]
			v57[#v57] = nil
		end

		local v66 = v12 < v13 and 5 or 2.5
		v12 += (v13 - v12) * (1 - math.exp(-v66 * v65))
		local v67 = v15
		local v68, v69

		if v15 == 1 then
			local v70 = v12

			if zoneLow + 0.02 < v70 then
				v68 = 2
			elseif v15 == 2 and v12 < zoneLow - 0.02 then
				v68 = 1
			elseif v15 == 2 then
				v69 = v12

				if zoneHigh + 0.02 < v69 then
					v68 = 3
				else
					v68 = v15 == 3 and v12 < zoneHigh - 0.02 and 2 or v67
				end
			else
				v68 = v15 == 3 and v12 < zoneHigh - 0.02 and 2 or v67
			end
		elseif v15 == 2 and v12 < zoneLow - 0.02 then
			v68 = 1
		elseif v15 == 2 then
			v69 = v12

			if zoneHigh + 0.02 < v69 then
				v68 = 3
			else
				v68 = v15 == 3 and v12 < zoneHigh - 0.02 and 2 or v67
			end
		else
			v68 = v15 == 3 and v12 < zoneHigh - 0.02 and 2 or v67
		end

		if v68 ~= v15 then
			local v70 = v15
			v15 = v68
			onZoneChange(v68, v70)
		end

		local v70 = fullGreen <= v12

		local rotation = -72 + 144 * v12 + math.sin(now * 3) * 0.4

		if v15 == 1 then
			rotation += math.sin(now * 61) * 1.8 + (math.random() - 0.5) * 3.2
		end

		needle2.Rotation = rotation
		needle.Rotation = rotation

		local v72 = math.floor(v12 * 20 + 0.5)

		if v72 ~= v17 then
			v17 = v72
			refreshScale(v72)
		end

		if v15 ~= v62 or v14 ~= v63 then
			v62 = v15
			v63 = v14
			refreshBands()
		end

		for i = 1, 3 do
			local v73 = v14 and color13 or v10[i]
			local lerped = v73:Lerp(color, 0.82)

			if i == v15 then
				local v74 = i == 1 and not v14 and (math.sin(now * 12) > -0.2 and 1 or 0.15) or 1

				lerped = lerped:Lerp(v14 and color14 or v73, v74)
			end

			if v21[i] > 0 then
				lerped = lerped:Lerp(color11, v21[i] * 0.65)
				v21[i] = math.max(0, v21[i] - v65 * 2.2)
			end

			v27[i].Lens.BackgroundColor3 = lerped
		end

		local textColor

		if v14 then
			textColor = color14:Lerp(color13, 0.35)
		else
			textColor = chargeUp(skillToColor(v12), 0.1, 0.25) -- inferred equivalent call
		end

		if v70 then
			textColor = textColor:Lerp(color11, math.sin(now * 8) * 0.15 + 0.18)
		end

		parent9.TextColor3 = textColor
		parent9.TextTransparency = v15 == 1 and not v14 and math.random() < 0.12 and rnd(0.2, 0.45) or 0 -- inferred equivalent call

		if v19 > 0 then
			v19 = math.max(0, v19 - v65 * 1.8)
			parent2.Position = UDim2.fromOffset(26 + rnd(-1, 1) * v19 * 3, 26 + rnd(-1, 1) * v19 * 3) -- inferred equivalent call
		elseif parent2.Position.X.Offset ~= 26 or parent2.Position.Y.Offset ~= 26 then
			parent2.Position = UDim2.fromOffset(26, 26)
		end

		if v20 > 0 then
			v20 -= v65
			v22.bolt += 7 * v65

			while v22.bolt >= 1 do
				v22.bolt -= 1
				lampBurst(v15, 1, 1)
			end
		elseif v70 then
			v22.spark += (v and 3.5 or 6) * v65

			while v22.spark >= 1 do
				v22.spark -= 1
				local v76, v77, _, _ = fxColors()
				local v78 = vector2s[3]

				for _ = 1, 1 do
					local v79 = v78.X + rnd(-8, 8) -- inferred equivalent call
					local v80 = v78.Y + rnd(-3, 3) -- inferred equivalent call
					local v81 = -1.5708 + rnd(-1.4, 1.4) -- inferred equivalent call
					local v82 = rnd(110, 300) -- inferred equivalent call
					local v83 = rnd(0.35, 0.7) -- inferred equivalent call

					if v32 <= v59 then
						continue
					end

					v59 += 1
					local v84 = acquire(41) -- inferred equivalent call
					local v85 = math.cos(v81) * v82
					local v86 = math.sin(v81) * v82
					local total2 = 0
					local v87 = 2
					v57[#v57 + 1] = function(p2): boolean
						total2 += p2

						if v83 <= total2 then
							v59 -= 1
							release(v84) -- inferred equivalent call
							return false
						else
							local v88 = math.exp(-2.4 * p2)
							v85 *= v88
							v86 = v86 * v88 + 380 * p2
							v79 += v85 * p2
							v80 += v86 * p2
							local v89 = total2 / v83
							local v90 = math.sqrt(v85 * v85 + v86 * v86)
							v84.Position = UDim2.fromOffset(v79, v80)
							v84.Rotation = math.deg((math.atan2(v86, v85)))
							v84.Size = UDim2.fromOffset(
								math.clamp(v90 * 0.045, 3, 18),
								(math.max(1.5, v87 * (1 - v89 * 0.5)))
							)
							v84.BackgroundColor3 = v76:Lerp(v77, (math.clamp(v89 * 1.5, 0, 1)))
							v84.BackgroundTransparency = v89 * v89 * 0.95
							return true
						end
					end
				end
			end

			v22.bolt += 1 / rnd(0.7, 1.4) * v65 -- inferred equivalent call

			while v22.bolt >= 1 do
				v22.bolt -= 1
				local _, _, backgroundColor, backgroundColor2 = fxColors()
				local v79 = vector2s[3]

				for _ = 1, 1 do
					emitBolt(
						v79.X + rnd(-10, 10), -- inferred equivalent call
						v79.Y,
						-1.5708 + rnd(-1.3, 1.3), -- inferred equivalent call
						rnd(22, 46), -- inferred equivalent call
						rnd(0.12, 0.22), -- inferred equivalent call
						backgroundColor,
						backgroundColor2
					)
				end
			end
		end

		local v74 = v14 and 0.65 or 0.72

		if v15 == 1 then
			v74 = math.min(v74, 0.55)
		end

		if v70 then
			v74 = math.min(v74, 0.6)
		end

		local v75

		if v18 > 0 then
			v18 -= v65
			v75 = math.clamp(v18 / 0.5, 0, 1)
		else
			v75 = 0
		end

		local v76 = v74 * (1 - v75)
		total += (v76 - total) * (1 - math.exp(-9 * v65))
		parent.GroupTransparency = total
	elseif flag then
		flag = false
		parent.Visible = false
		clearParticles()
		resetState() -- inferred equivalent call
	end
end

RunService.Heartbeat:Connect(step2)

function RockMeterUI.OnJudgment(p, p2)
	if p2 then
		return
	end

	local v64 = step[p]

	if v64 then
		v13 = math.clamp(v13 + v64, 0, 1)
	end
end

function RockMeterUI.SetStarPowerActive(p)
	local v64 = p and true or false

	if v64 == v14 then
		return
	end

	v14 = v64
	applyTheme()

	if flag then
		v18 = math.max(v18, 1.2)
		v19 = math.max(v19, 0.6)
		v20 = math.max(v20, 0.4)
	end
end

function RockMeterUI.Reset()
	resetState() -- inferred equivalent call
end

return RockMeterUI