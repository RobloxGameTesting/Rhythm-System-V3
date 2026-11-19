local font = game:GetService("Players")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local result = game:GetService("UserInputService")

local RhythmEngineConfig = require(script.Parent:WaitForChild("RhythmEngineConfig"))
local v = require(script.Parent:WaitForChild("GuiFade"))

local ScoreDisplayUI = {}

local playerGui = font.LocalPlayer:WaitForChild("PlayerGui")
local v2 = result.TouchEnabled and not result.KeyboardEnabled

local function fontOr(p, p2)
	local success, result2 = pcall(function()
		return Enum.Font[p]
	end)
	return success and result2 or p2
end

font = Enum.Font.GothamBold
local v3 = "Oswald"
local success
success, result = pcall(function()
	return Enum.Font[v3]
end)
font = success and result or font
result = Enum.Font.GothamBlack
local v4 = "PermanentMarker"
local success2, result2 = pcall(function()
	return Enum.Font[v4]
end)
result = success2 and result2 or result
local font2 = Enum.Font.Code
local v5 = "RobotoMono"
local success3
success3, result2 = pcall(function()
	return Enum.Font[v5]
end)
font2 = success3 and result2 or font2
result2 = Color3.fromRGB(20, 20, 19)
local color = Color3.fromRGB(15, 15, 14)
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
local color12 = Color3.fromRGB(14, 12, 10)

local color13 = Color3.fromRGB(16, 27, 15)
local color14 = Color3.fromRGB(24, 40, 22)
local color15 = Color3.fromRGB(156, 230, 96)
local color16 = Color3.fromRGB(44, 78, 40)

local color17 = Color3.fromRGB(236, 178, 72)
local color18 = Color3.fromRGB(52, 36, 30)

local color19 = Color3.fromRGB(75, 200, 220)
local color20 = Color3.fromRGB(200, 245, 255)
local color21 = Color3.fromRGB(70, 150, 168)
local color22 = Color3.fromRGB(235, 252, 255)
local color23 = Color3.fromRGB(255, 132, 44)
local color24 = Color3.fromRGB(60, 170, 235)
local color25 = Color3.fromRGB(214, 60, 48)

local function chargeUp(p, p2, p3)
	local hsv, v6, v7 = p:ToHSV()
	return Color3.fromHSV(hsv, math.clamp(v6 + p2, 0, 1), (math.clamp(v7 + p3, 0, 1)))
end

local function rnd(p, p2) -- 19 equivalent calls inferred from this helper
	return p + math.random() * (p2 - p)
end

local function mk(className, items, parent) -- 64 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function gradient(parent, p, color26, value) -- 3 equivalent calls inferred from this helper
	return mk("UIGradient", { -- inferred equivalent call
		Color = ColorSequence.new(p, color26),
		Rotation = value or 90
	}, parent)
end

local function circleOf(parent) -- 6 equivalent calls inferred from this helper
	mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent) -- inferred equivalent call
end

local v6 = {
	Name = "ScoreDisplayUI",
	ResetOnSpawn = false,
	DisplayOrder = 14,
	ZIndexBehavior = Enum.ZIndexBehavior.Global
}
local screenGui = Instance.new("ScreenGui")
local scale = v2 and 2 / 3 or 1
local v7 = false
local v8 = nil
local v9 = -1
local v10 = nil
local v11 = nil
local v12 = 0
local v13 = 0
local v14 = 0
local v15 = 0
local v16 = 1
local v17 = 0
local v18 = 0
local v19 = 0
local v20 = 0
local v21 = 0
local v22 = { bolt = 0, spark = 0 }
local v23 = nil
local v24 = v2 and 104 or 0
local v25 = nil
local v26 = nil
local flag = false
local total = 1

for k, v27 in pairs(v6) do
	screenGui[k] = v27
end

screenGui.Parent = playerGui

local parent = mk("CanvasGroup", { -- inferred equivalent call
	Name = "Container",
	AnchorPoint = Vector2.new(0, 0),
	Size = UDim2.fromOffset(202, 248),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	GroupTransparency = 1,
	Visible = false,
	ZIndex = 1
}, screenGui)

mk("UIScale", { Scale = scale }, parent) -- inferred equivalent call
v.Attach(parent, "Hud", 0.8, v.Presets.Score)

local parent2 = mk("Frame", { -- inferred equivalent call
	Name = "Plate",
	Position = UDim2.fromOffset(26, 26),
	Size = UDim2.fromOffset(150, 196),
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
	Size = UDim2.fromOffset(150, 196),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.5,
	BorderSizePixel = 0,
	ZIndex = 1
}, parent2)

mk("UICorner", { CornerRadius = UDim.new(0, 5) }, parent4) -- inferred equivalent call

local parent5 = mk("Frame", { -- inferred equivalent call
	Name = "Body",
	Size = UDim2.fromOffset(150, 196),
	BackgroundColor3 = result2,
	BorderSizePixel = 0,
	ZIndex = 2
}, parent2)

mk("UICorner", { CornerRadius = UDim.new(0, 4) }, parent5) -- inferred equivalent call
mk("UIStroke", { Color = color6, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, parent5) -- inferred equivalent call
v = Color3.fromRGB(255, 255, 255)
gradient(parent5, v, Color3.fromRGB(205, 203, 198), nil) -- inferred equivalent call

local parent6 = mk("Frame", { -- inferred equivalent call
	Name = "Piping",
	Position = UDim2.fromOffset(5, 5),
	Size = UDim2.fromOffset(140, 186),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 3
}, parent2)

mk("UICorner", { CornerRadius = UDim.new(0, 3) }, parent6) -- inferred equivalent call
local uiStroke = mk("UIStroke", { Color = color5, Thickness = 1, Transparency = 0.6 }, parent6) -- inferred equivalent call

local parent7 = mk("Frame", { -- inferred equivalent call
	Name = "Lcd",
	Position = UDim2.fromOffset(11, 11),
	Size = UDim2.fromOffset(128, 30),
	BackgroundColor3 = color13,
	BorderSizePixel = 0,
	ZIndex = 4
}, parent2)

mk("UICorner", { CornerRadius = UDim.new(0, 3) }, parent7) -- inferred equivalent call
mk("UIStroke", { Color = color6, Thickness = 2 }, parent7) -- inferred equivalent call

local v27 = {}

for i = 1, 7 do
	local parent8 = mk("Frame", { -- inferred equivalent call
		Name = "Cell",
		Position = UDim2.fromOffset((i - 1) * (120 / 7) + 4 + 0.5, 3),
		Size = UDim2.fromOffset(219 / 14, 24),
		BackgroundColor3 = color14,
		BorderSizePixel = 0,
		ZIndex = 5
	}, parent7)

	mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent8) -- inferred equivalent call
	v27[i] = mk("TextLabel", { -- inferred equivalent call
		Name = "Digit",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Font = font2,
		Text = "0",
		TextSize = 19,
		TextColor3 = color16,
		ZIndex = 6
	}, parent8)
end

mk("Frame", { -- inferred equivalent call
	Name = "Glass",
	Position = UDim2.fromOffset(2, 2),
	Size = UDim2.new(1, -4, 0, 5),
	BackgroundColor3 = color11,
	BackgroundTransparency = 0.9,
	BorderSizePixel = 0,
	ZIndex = 7
}, parent7)

local parent8 = mk("Frame", { -- inferred equivalent call
	Name = "RingOuter",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(86, 98),
	Size = UDim2.fromOffset(84, 84),
	BackgroundColor3 = color11,
	BorderSizePixel = 0,
	ZIndex = 4
}, parent2)
circleOf(parent8) -- inferred equivalent call
gradient(parent8, color9, color10) -- inferred equivalent call
local uiStroke2 = mk("UIStroke", { Color = color6, Thickness = 2 }, parent8) -- inferred equivalent call

local parent9 = mk("Frame", { -- inferred equivalent call
	Name = "RingPipe",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(86, 98),
	Size = UDim2.fromOffset(72, 72),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 5
}, parent2)
circleOf(parent9) -- inferred equivalent call
local uiStroke3 = mk("UIStroke", { Color = color5, Thickness = 1.5, Transparency = 0.15 }, parent9) -- inferred equivalent call

local parent10 = mk("Frame", { -- inferred equivalent call
	Name = "Face",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(86, 98),
	Size = UDim2.fromOffset(64, 64),
	BackgroundColor3 = color11,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	ZIndex = 6
}, parent2)
circleOf(parent10) -- inferred equivalent call
v = Color3.fromRGB(44, 42, 39)
gradient(parent10, v, Color3.fromRGB(12, 12, 11), nil) -- inferred equivalent call
mk("UIStroke", { Color = color6, Thickness = 1.5 }, parent10) -- inferred equivalent call

local textLabel = mk("TextLabel", { -- inferred equivalent call
	Name = "X",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(20, 40),
	Size = UDim2.fromOffset(18, 20),
	BackgroundTransparency = 1,
	Font = font,
	Text = "x",
	TextSize = 20,
	TextColor3 = color4,
	ZIndex = 7
}, parent10)

local parent11 = mk("TextLabel", { -- inferred equivalent call
	Name = "Numeral",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(38, 31),
	Size = UDim2.fromOffset(38, 52),
	BackgroundTransparency = 1,
	Font = result,
	Text = "1",
	TextSize = 46,
	TextColor3 = color5,
	ZIndex = 7
}, parent10)

local uiScale = mk("UIScale", { Scale = 1 }, parent11) -- inferred equivalent call
mk("UIStroke", { Color = Color3.fromRGB(8, 8, 8), Thickness = 2.5 }, parent11) -- inferred equivalent call
local frame = mk("Frame", { -- inferred equivalent call
	Name = "Flash",
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = color11,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 8
}, parent10)

mk("Frame", { -- inferred equivalent call
	Name = "Glare",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(18, 14),
	Size = UDim2.fromOffset(12, 60),
	Rotation = 30,
	BackgroundColor3 = color11,
	BackgroundTransparency = 0.93,
	BorderSizePixel = 0,
	ZIndex = 8
}, parent10)

local v28 = {}

for i = 1, 10 do
	local parent12 = mk("Frame", { -- inferred equivalent call
		Name = "LampSlot",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(21, 148 - (i - 1) * (94 / 9)),
		Size = UDim2.fromOffset(16, 8),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ZIndex = 4
	}, parent2)

	mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent12) -- inferred equivalent call
	mk("UIStroke", { Color = color6, Thickness = 1.2 }, parent12) -- inferred equivalent call
	local parent13 = mk("Frame", { -- inferred equivalent call
		Name = "Lens",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = color18,
		BorderSizePixel = 0,
		ZIndex = 5
	}, parent12)

	mk("UICorner", { CornerRadius = UDim.new(0, 1) }, parent13) -- inferred equivalent call
	v28[i] = parent13
end

local parent12 = mk("Frame", { -- inferred equivalent call
	Name = "StreakBox",
	Position = UDim2.fromOffset(14, 160),
	Size = UDim2.fromOffset(122, 28),
	BackgroundColor3 = color,
	BorderSizePixel = 0,
	ZIndex = 4
}, parent2)

mk("UICorner", { CornerRadius = UDim.new(0, 3) }, parent12) -- inferred equivalent call
local uiStroke4 = mk("UIStroke", { Color = color2, Thickness = 1.5, Transparency = 0.1 }, parent12) -- inferred equivalent call
local parent13 = mk("Frame", { -- inferred equivalent call
	Name = "Flash",
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = color25,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 9
}, parent12)

mk("UICorner", { CornerRadius = UDim.new(0, 3) }, parent13) -- inferred equivalent call

local function part(items) -- 3 equivalent calls inferred from this helper
	items.BorderSizePixel = 0
	items.BackgroundColor3 = color5
	items.ZIndex = 6
	return mk("Frame", items, parent12) -- inferred equivalent call
end

circleOf(part({ -- inferred equivalent call
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(11, 19),
	Size = UDim2.fromOffset(8, 6),
	Rotation = -22
}))

part({ -- inferred equivalent call
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.fromOffset(14.5, 5),
	Size = UDim2.fromOffset(1.8, 14)
})
part({ -- inferred equivalent call
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.fromOffset(15, 6),
	Size = UDim2.fromOffset(7, 2.2),
	Rotation = 38
})

local v29 = {}
local v30 = {}

for i = 1, 4 do
	local parent14 = mk("Frame", { -- inferred equivalent call
		Name = "Cell",
		Position = UDim2.fromOffset(118 - (5 - i) * 23 + 2, 3),
		Size = UDim2.fromOffset(21, 22),
		BackgroundColor3 = i == 4 and Color3.fromRGB(214, 212, 206) or Color3.fromRGB(30, 29, 27),
		BorderSizePixel = 0,
		ZIndex = 5
	}, parent12)

	mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent14) -- inferred equivalent call
	mk("UIStroke", { Color = color6, Thickness = 1, Transparency = 0.2 }, parent14) -- inferred equivalent call
	v29[i] = parent14
	v30[i] = mk("TextLabel", { -- inferred equivalent call
		Name = "Digit",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Font = font2,
		Text = "0",
		TextSize = 17,
		TextColor3 = i == 4 and color12 or Color3.fromRGB(70, 68, 64),
		ZIndex = 6
	}, parent14)
end

local folder = mk("Frame", { -- inferred equivalent call
	Name = "DecorFront",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 1, 0),
	ZIndex = 20
}, parent2)
local random = Random.new(31)
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

for i = 1, 5 do
	local integer = random:NextInteger(26, 58)
	circleOf(mk("Frame", { -- inferred equivalent call
		Name = "Stain" .. i,
		BackgroundColor3 = i % 2 == 0 and color8 or Color3.new(0, 0, 0),
		BackgroundTransparency = 0.88 + random:NextNumber() * 0.06,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(random:NextNumber() * 0.8, random:NextNumber() * 0.8),
		Size = UDim2.new(0, integer, 0, (math.floor(integer * (0.35 + random:NextNumber() * 0.4))))
	}, folder))
end

for i, v31 in ipairs({
	{ 0.08, 0.33, 50, 24 },
	{ 0.58, 0.52, 40, -31 },
	{ 0.28, 0.82, 60, 12 },
	{ 0.7, 0.14, 34, 40 }
}) do
	mk("Frame", { -- inferred equivalent call
		Name = "Scratch" .. i,
		BackgroundColor3 = color3,
		BackgroundTransparency = 0.9,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(v31[1], v31[2]),
		Size = UDim2.new(0, v31[3], 0, 1),
		Rotation = v31[4]
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

for i = 1, 24 do
	local v31 = random:NextNumber() > 0.35
	local integer = random:NextInteger(1, 2)
	mk("Frame", { -- inferred equivalent call
		Name = "Speck" .. i,
		BackgroundColor3 = v31 and color3 or Color3.new(0, 0, 0),
		BackgroundTransparency = v31 and 0.8 + random:NextNumber() * 0.12 or 0.45 + random:NextNumber() * 0.25,
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
local uiStroke5 = mk("UIStroke", { Color = color7, Thickness = 1.5, Transparency = 0.55 }, parent14) -- inferred equivalent call
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
	local color26 = Color3.fromRGB(196, 192, 182)
	local color27 = Color3.fromRGB(70, 68, 63)
	mk("UIGradient", { -- inferred equivalent call
		Color = ColorSequence.new(color26, color27),
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
rivet(7, 7)
rivet(143, 7)
rivet(7, 189)
rivet(143, 189)
local v31 = v2 and 16 or 36
local v32 = v2 and 3 or 7
local v76 = v2 and 4 or 5
local v77 = {}
local v78 = {}
local v79 = 0
local v80 = 0

local function acquire(zIndex) -- 5 equivalent calls inferred from this helper
	local selected = table.remove(v78)

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
	v78[#v78 + 1] = p
end

local function clearParticles()
	v77 = {}
	v79 = 0
	v80 = 0
	v78 = {}

	for _, child in ipairs(parent3:GetChildren()) do
		child.Visible = false
		v78[#v78 + 1] = child
	end
end

local function placeLine(p, p2, p3, p4, p5, p6)
	local v81 = p4 - p2
	local v82 = p5 - p3
	p.Position = UDim2.fromOffset((p2 + p4) / 2, (p3 + p5) / 2)
	p.Size = UDim2.fromOffset(math.sqrt(v81 * v81 + v82 * v82) + 0.5, p6)
	p.Rotation = math.deg((math.atan2(v82, v81)))
end

local function emitSpark(total2, total3, p, p2, p3, p4, p5, p6)
	if v31 <= v79 then
		return
	end

	v79 += 1
	local v81 = acquire(41) -- inferred equivalent call
	local v82 = math.cos(p) * p2
	local v83 = math.sin(p) * p2
	local total4 = 0
	v77[#v77 + 1] = function(p7): boolean
		total4 += p7

		if p3 <= total4 then
			v79 -= 1
			release(v81) -- inferred equivalent call
			return false
		else
			local v84 = math.exp(-2.4 * p7)
			v82 *= v84
			v83 = v83 * v84 + 380 * p7
			total2 += v82 * p7
			total3 += v83 * p7
			local v85 = total4 / p3
			local v86 = math.sqrt(v82 * v82 + v83 * v83)
			v81.Position = UDim2.fromOffset(total2, total3)
			v81.Rotation = math.deg((math.atan2(v83, v82)))
			v81.Size = UDim2.fromOffset(math.clamp(v86 * 0.045, 3, 18), (math.max(1.5, p4 * (1 - v85 * 0.5))))
			v81.BackgroundColor3 = p5:Lerp(p6, (math.clamp(v85 * 1.5, 0, 1)))
			v81.BackgroundTransparency = v85 * v85 * 0.95
			return true
		end
	end
end

local function emitBolt(p, p2, p3, p4, p5, backgroundColor, backgroundColor2)
	if v32 <= v80 then
		return
	end

	v80 += 1
	local v81 = v76
	local v82 = v2 and 1.8 or 2.2
	local v83 = {}
	local v84 = {}

	for i = 1, v81 do
		local v85 = acquire(41) -- inferred equivalent call
		v85.BackgroundColor3 = backgroundColor
		v83[i] = v85
		local v86 = acquire(42) -- inferred equivalent call
		v86.BackgroundColor3 = backgroundColor2
		v84[i] = v86
	end

	local v85 = math.cos(p3)
	local v86 = math.sin(p3)
	local v87 = -v86
	local v88 = p4 * 0.22
	local function relayout()
		local v89 = {}
		local v90 = {}

		for i = 0, v81 do
			local v91 = i / v81
			local v92

			if i == 0 then
				v92 = 0
			else
				v92 = rnd(-v88, v88) * (1 - v91 * 0.25) -- inferred equivalent call
			end

			v89[i] = p + v85 * p4 * v91 + v87 * v92
			v90[i] = p2 + v86 * p4 * v91 + v85 * v92
		end

		for i = 1, v81 do
			placeLine(v83[i], v89[i - 1], v90[i - 1], v89[i], v90[i], v82 * 3)
			placeLine(v84[i], v89[i - 1], v90[i - 1], v89[i], v90[i], v82)
		end
	end
	relayout()
	local total2 = 0
	local total3 = 0
	v77[#v77 + 1] = function(p6): boolean
		total2 += p6
		total3 += p6

		if p5 <= total2 then
			for i = 1, v81 do
				release(v83[i]) -- inferred equivalent call
				release(v84[i]) -- inferred equivalent call
			end

			v80 -= 1
			return false
		else
			if total3 >= 0.045 then
				total3 = 0
				relayout()
			end

			local v89 = total2 / p5
			local v90 = math.random() < 0.28 and 0.4 or 0
			local backgroundTransparency = math.clamp(v89 * v89 * 0.9 + v90, 0, 1)
			local backgroundTransparency2 = math.clamp(0.7 + v89 * 0.3 + v90 * 0.3, 0, 1)

			for i = 1, v81 do
				v84[i].BackgroundTransparency = backgroundTransparency
				v83[i].BackgroundTransparency = backgroundTransparency2
			end

			return true
		end
	end
end

local function fxColors()
	if v7 then
		return color22, color23, color24, Color3.fromRGB(225, 248, 255)
	end

	return Color3.fromRGB(255, 232, 170), Color3.fromRGB(200, 90, 30), color5, Color3.fromRGB(255, 244, 214)
end

local function ringBurst(p, p2)
	local v81, v82, backgroundColor, backgroundColor2 = fxColors()

	for _ = 1, p do
		local v85 = rnd(0, 6.2832) -- inferred equivalent call
		local v86 = math.cos(v85) * 40 + 112
		local v87 = math.sin(v85) * 40 + 124
		local v88 = v85 + rnd(-0.4, 0.4) -- inferred equivalent call
		local v89 = rnd(120, 320) -- inferred equivalent call
		local v90 = rnd(0.35, 0.75) -- inferred equivalent call

		if v31 <= v79 then
			continue
		end

		v79 += 1
		local v91 = acquire(41) -- inferred equivalent call
		local v92 = math.cos(v88) * v89
		local v93 = math.sin(v88) * v89
		local total2 = 0
		local v94 = 2
		v77[#v77 + 1] = function(p3): boolean
			total2 += p3

			if v90 <= total2 then
				v79 -= 1
				release(v91) -- inferred equivalent call
				return false
			else
				local v95 = math.exp(-2.4 * p3)
				v92 *= v95
				v93 = v93 * v95 + 380 * p3
				v86 += v92 * p3
				v87 += v93 * p3
				local v96 = total2 / v90
				local v97 = math.sqrt(v92 * v92 + v93 * v93)
				v91.Position = UDim2.fromOffset(v86, v87)
				v91.Rotation = math.deg((math.atan2(v93, v92)))
				v91.Size = UDim2.fromOffset(math.clamp(v97 * 0.045, 3, 18), (math.max(1.5, v94 * (1 - v96 * 0.5))))
				v91.BackgroundColor3 = v81:Lerp(v82, (math.clamp(v96 * 1.5, 0, 1)))
				v91.BackgroundTransparency = v96 * v96 * 0.95
				return true
			end
		end
	end

	for _ = 1, p2 do
		local v85 = rnd(0, 6.2832) -- inferred equivalent call
		emitBolt(
			math.cos(v85) * 42 + 112,
			math.sin(v85) * 42 + 124,
			v85 + rnd(-0.3, 0.3), -- inferred equivalent call
			rnd(18, 36), -- inferred equivalent call
			rnd(0.12, 0.22), -- inferred equivalent call
			backgroundColor,
			backgroundColor2
		)
	end
end

local function applyTheme() -- 2 equivalent calls inferred from this helper
	uiStroke5.Color = v7 and color21 or color7
	uiStroke5.Transparency = v7 and 0.3 or 0.55
	uiStroke2.Color = v7 and color21 or color6
	uiStroke3.Color = v7 and color19 or color5
	uiStroke.Color = v7 and color19 or color5
	uiStroke4.Color = v7 and color21 or color2
	parent11.TextColor3 = v7 and color20 or color5
	textLabel.TextColor3 = v7 and color19 or color4
	v8 = nil
	v9 = -1
end

local function setScoreText(p)
	local v81 = math.clamp((math.floor)(p + 0.5), 0, 9999999)
	local v82 = string.format("%07d", v81)

	if v82 == v10 then
		return
	end

	v10 = v82
	local v83 = 7

	for i = 1, 7 do
		if v82:sub(i, i) ~= "0" then
			v83 = i
			break
		end
	end

	for i = 1, 7 do
		v27[i].Text = v82:sub(i, i)
		v27[i].TextColor3 = v83 <= i and color15 or color16
	end
end

local function setComboText(p)
	local v81 = math.clamp((math.floor)(p), 0, 9999)
	local v82 = string.format("%04d", v81)

	if v82 == v11 then
		return
	end

	v11 = v82
	local v83 = 4

	for i = 1, 4 do
		if v82:sub(i, i) ~= "0" then
			v83 = i
			break
		end
	end

	for i = 1, 4 do
		v30[i].Text = v82:sub(i, i)

		if i == 4 then
			v30[4].TextColor3 = color12
		else
			v30[i].TextColor3 = v83 <= i and color3 or Color3.fromRGB(70, 68, 64)
		end
	end
end

local function comboMultiplier() -- 1 equivalent call inferred from this helper
	return RhythmEngineConfig.GetComboMultiplier(v12)
end

local function lampLitCount(p) -- 1 equivalent call inferred from this helper
	if RhythmEngineConfig.ComboMaxMultiplier <= p then
		return 10
	end

	local comboNotesPerLevel = RhythmEngineConfig.ComboNotesPerLevel
	return (math.floor(v12 % comboNotesPerLevel / comboNotesPerLevel * 10 + 0.0001))
end

local function refreshLamps(p, _)
	local v81 = v7 and color19 or color17
	local v82 = v7 and color19:Lerp(color, 0.82) or color18

	for i = 1, 10 do
		local backgroundColor = i <= p and v81 or v82

		if v13 > 0 then
			backgroundColor = backgroundColor:Lerp(color11, v13 * 0.7)
		end

		v28[i].BackgroundColor3 = backgroundColor
	end
end

local function resetState() -- 3 equivalent calls inferred from this helper
	v14 = 0
	v15 = 0
	v12 = 0
	v16 = 1
	v17 = 0
	v18 = 0
	v13 = 0
	v19 = 0
	v20 = 0
	v21 = 0
	v22.bolt = 0
	v22.spark = 0
	v7 = false
	v10 = nil
	v11 = nil
	applyTheme() -- inferred equivalent call
	setScoreText(0)
	setComboText(0)
	parent11.Text = "1"
end

local function triggerMoment(p) -- 2 equivalent calls inferred from this helper
	v17 = math.max(v17, 1)
	v18 = math.max(v18, p)
end

local function onMultiplierUp() -- 1 equivalent call inferred from this helper
	triggerMoment(0.8) -- inferred equivalent call
	v13 = 1
	v20 = 1
	v21 = 1
	ringBurst(v2 and 8 or 14, v2 and 2 or 3)
end

local function onComboBreak() -- 1 equivalent call inferred from this helper
	v19 = 1
	v18 = math.max(v18, 0.35)
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

local function getTrackFrame()
	if v23 == nil then
		local success4, result3 = pcall(function()
			return require(script.Parent:WaitForChild("NoteLaneUI", 5))
		end)

		v23 = success4 and result3 or false
	end

	if v23 and v23.GetTrackFrame then
		return v23.GetTrackFrame()
	end

	return nil
end

local v81 = (v2 and 92 or 79) * (v2 and 5 / 7 or 15 / 14)

local function reposition(starBar, _)
	local absoluteSize = screenGui.AbsoluteSize
	local absolutePosition = screenGui.AbsolutePosition
	local v82 = starBar.AbsolutePosition - absolutePosition
	local absoluteSize2 = starBar.AbsoluteSize
	local v83 = 150 * scale
	local v84 = 196 * scale
	local v85 = math.clamp(v82.X + absoluteSize2.X + 22, 6, (math.max(6, absoluteSize.X - v83 - 6 - v24)))
	local v86 = math.max(6, (math.min(v82.Y + absoluteSize2.Y / 2 - v81 / 2 - 10 - v84, absoluteSize.Y - v84 - 6)))
	local v87 = math.floor(v85 - 26 * scale + 0.5)
	local v88 = math.floor(v86 - 26 * scale + 0.5)

	if v87 ~= v25 or v88 ~= v26 then
		v25 = v87
		v26 = v88
		parent.Position = UDim2.fromOffset(v87, v88)
	end
end

local function step(p)
	local starBar = findStarBar() -- inferred equivalent call
	local v82

	if starBar == nil then
		v82 = false
	else
		v82 = laneUiOn() -- inferred equivalent call
	end

	if v82 then
		local v83 = p > 0.05 and 0.05 or p

		if not flag then
			flag = true
			resetState() -- inferred equivalent call
			total = 1
			parent.GroupTransparency = 1
			parent.Visible = true
			v17 = 1.8
		end

		reposition(starBar, v83)
		local now = os.clock()

		for i = #v77, 1, -1 do
			if v77[i](v83) then
				continue
			end

			v77[i] = v77[#v77]
			v77[#v77] = nil
		end

		v15 += (v14 - v15) * (1 - math.exp(-9 * v83))

		if math.abs(v14 - v15) < 0.5 then
			v15 = v14
		end

		setScoreText(v15)
		setComboText(v12)
		local v84 = comboMultiplier() -- inferred equivalent call

		if v16 < v84 then
			onMultiplierUp() -- inferred equivalent call
		elseif v84 < v16 then
			onComboBreak() -- inferred equivalent call
		end

		v16 = v84
		local text = tostring(v84 * (v7 and RhythmEngineConfig.StarPowerScoreMultiplier or 1))

		if parent11.Text ~= text then
			parent11.Text = text
		end

		local v86 = lampLitCount(v84) -- inferred equivalent call

		if v86 ~= v9 or v13 > 0 then
			v9 = v86
			refreshLamps(v86, now)
		end

		if v13 > 0 then
			v13 = math.max(0, v13 - v83 * 3)
		end

		if v20 > 0 then
			v20 = math.max(0, v20 - v83 * 3.2)
			frame.BackgroundTransparency = 1 - v20 * 0.7
		end

		if v21 > 0 then
			v21 = math.max(0, v21 - v83 * 3.5)
		end

		uiScale.Scale = v21 * 0.4 + 1 + (v7 and math.sin(now * 9) * 0.04 or 0)

		if v19 > 0 then
			v19 = math.max(0, v19 - v83 * 2.4)
			parent13.BackgroundTransparency = 1 - v19 * 0.6
		end

		if v7 then
			local color26 = Color3.fromRGB(225, 248, 255)
			v22.bolt += (v2 and 2.5 or 4) * v83

			while v22.bolt >= 1 do
				v22.bolt -= 1
				local v89 = rnd(0, 6.2832) -- inferred equivalent call
				emitBolt(
					math.cos(v89) * 42 + 112,
					math.sin(v89) * 42 + 124,
					v89 + rnd(-0.35, 0.35), -- inferred equivalent call
					rnd(14, 30), -- inferred equivalent call
					rnd(0.1, 0.2), -- inferred equivalent call
					color24,
					color26
				)
			end

			v22.spark += (v2 and 3 or 5) * v83

			while v22.spark >= 1 do
				v22.spark -= 1
				local v90 = rnd(0, 6.2832) -- inferred equivalent call
				local v91 = math.cos(v90) * 41 + 112
				local v92 = math.sin(v90) * 41 + 124
				local v93 = v90 + rnd(-0.5, 0.5) -- inferred equivalent call
				local v94 = rnd(90, 220) -- inferred equivalent call
				local v95 = rnd(0.3, 0.6) -- inferred equivalent call
				local v96 = color22
				local v97 = color23

				if v31 <= v79 then
					continue
				end

				v79 += 1
				local v98 = acquire(41) -- inferred equivalent call
				local v99 = math.cos(v93) * v94
				local v100 = math.sin(v93) * v94
				local total2 = 0
				local v101 = 2
				v77[#v77 + 1] = function(p2): boolean
					total2 += p2

					if v95 <= total2 then
						v79 -= 1
						release(v98) -- inferred equivalent call
						return false
					else
						local v102 = math.exp(-2.4 * p2)
						v99 *= v102
						v100 = v100 * v102 + 380 * p2
						v91 += v99 * p2
						v92 += v100 * p2
						local v103 = total2 / v95
						local v104 = math.sqrt(v99 * v99 + v100 * v100)
						v98.Position = UDim2.fromOffset(v91, v92)
						v98.Rotation = math.deg((math.atan2(v100, v99)))
						v98.Size = UDim2.fromOffset(
							math.clamp(v104 * 0.045, 3, 18),
							(math.max(1.5, v101 * (1 - v103 * 0.5)))
						)
						v98.BackgroundColor3 = v96:Lerp(v97, (math.clamp(v103 * 1.5, 0, 1)))
						v98.BackgroundTransparency = v103 * v103 * 0.95
						return true
					end
				end
			end
		end

		if v18 > 0 then
			v18 = math.max(0, v18 - v83 * 1.8)
			parent2.Position = UDim2.fromOffset(26 + rnd(-1, 1) * v18 * 3, 26 + rnd(-1, 1) * v18 * 3) -- inferred equivalent call
		elseif parent2.Position.X.Offset ~= 26 or parent2.Position.Y.Offset ~= 26 then
			parent2.Position = UDim2.fromOffset(26, 26)
		end

		local v87 = v7 and 0.5 or 0.62
		local v88

		if v17 > 0 then
			v17 -= v83
			v88 = math.clamp(v17 / 0.5, 0, 1)
		else
			v88 = 0
		end

		total += (v87 * (1 - v88) - total) * (1 - math.exp(-9 * v83))
		parent.GroupTransparency = total
	elseif flag then
		flag = false
		parent.Visible = false
		clearParticles()
		resetState() -- inferred equivalent call
	end
end

RunService.Heartbeat:Connect(step)

function ScoreDisplayUI.SetState(value, value2)
	v14 = math.max(0, value or 0)
	v12 = math.max(0, value2 or 0)
end

function ScoreDisplayUI.SetStarPowerActive(p)
	local v82 = p and true or false

	if v82 == v7 then
		return
	end

	v7 = v82
	applyTheme() -- inferred equivalent call

	if flag then
		triggerMoment(0.9) -- inferred equivalent call
		v20 = 1
		v21 = 1
		v13 = 1
		ringBurst(v2 and 10 or 18, v2 and 3 or 5)
	end
end

function ScoreDisplayUI.Reset()
	resetState() -- inferred equivalent call
end

return ScoreDisplayUI