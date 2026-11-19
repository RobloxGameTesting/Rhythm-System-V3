local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local ResultHistoryUI = {}

local LocalPlayer = Players.LocalPlayer

local function pickFont(p, p2) -- 4 equivalent calls inferred from this helper
	local success, result = pcall(function()
		return Enum.Font[p]
	end)
	return success and result or p2
end

local GothamBold = Enum.Font.GothamBold
GothamBold = pickFont("PermanentMarker", GothamBold) -- inferred equivalent call
local Code = Enum.Font.Code
Code = pickFont("SpecialElite", Code) -- inferred equivalent call
local Gotham = Enum.Font.Gotham
Gotham = pickFont("PatrickHand", Gotham) -- inferred equivalent call
local Merriweather = Enum.Font.Merriweather
Merriweather = pickFont("Fondamento", Merriweather) -- inferred equivalent call

local function C(p, p2, p3) -- 59 equivalent calls inferred from this helper
	return Color3.fromRGB(p, p2, p3)
end
local v = {
	{
		Palette = {
			paper = Color3.fromRGB(190, 176, 146),
			paperDark = Color3.fromRGB(164, 150, 122),
			ink = Color3.fromRGB(26, 22, 20),
			soft = Color3.fromRGB(82, 70, 58),
			accent = Color3.fromRGB(150, 28, 26),
			good = Color3.fromRGB(40, 78, 52),
			stain = Color3.fromRGB(96, 70, 38)
		},
		Title = "SCORE REPORT",
		Sub = "PLAY LOUD  //  OFFICIAL STAGE RECORD",
		TitleFont = GothamBold,
		BodyFont = Code,
		TitleSize = 32
	},
	{
		Palette = {
			paper = Color3.fromRGB(200, 182, 140),
			paperDark = Color3.fromRGB(172, 152, 110),
			ink = Color3.fromRGB(44, 28, 20),
			soft = Color3.fromRGB(104, 78, 50),
			accent = Color3.fromRGB(120, 22, 20),
			good = Color3.fromRGB(52, 76, 44),
			stain = Color3.fromRGB(110, 80, 36)
		},
		Title = "CERTIFICATE OF NOISE",
		Sub = "THIS CERTIFIES THE PERFORMER MADE A RACKET",
		TitleFont = Merriweather,
		BodyFont = Code,
		TitleSize = 25,
		GradeFilled = true
	},
	{
		Palette = {
			paper = Color3.fromRGB(200, 200, 186),
			paperDark = Color3.fromRGB(172, 172, 158),
			ink = Color3.fromRGB(28, 36, 84),
			soft = Color3.fromRGB(66, 76, 112),
			accent = Color3.fromRGB(170, 30, 34),
			good = Color3.fromRGB(30, 92, 70),
			stain = Color3.fromRGB(110, 100, 70)
		},
		Title = "STAGE DIARY",
		Sub = "dont read this. seriously.",
		TitleFont = GothamBold,
		BodyFont = Gotham,
		TitleSize = 34
	},
	{
		Palette = {
			paper = Color3.fromRGB(176, 174, 168),
			paperDark = Color3.fromRGB(150, 148, 142),
			ink = Color3.fromRGB(14, 14, 14),
			soft = Color3.fromRGB(58, 58, 58),
			accent = Color3.fromRGB(14, 14, 14),
			good = Color3.fromRGB(14, 14, 14),
			stain = Color3.fromRGB(60, 60, 60)
		},
		Title = "LIVE & LOUD",
		Sub = "XEROX THIS. PASS IT ON.",
		TitleFont = GothamBold,
		BodyFont = Code,
		TitleSize = 36
	},
	{
		Palette = {
			paper = Color3.fromRGB(158, 126, 90),
			paperDark = Color3.fromRGB(132, 102, 70),
			ink = Color3.fromRGB(24, 18, 12),
			soft = Color3.fromRGB(66, 48, 30),
			accent = Color3.fromRGB(150, 30, 24),
			good = Color3.fromRGB(30, 60, 36),
			stain = Color3.fromRGB(70, 48, 24)
		},
		Title = "BACKSTAGE LOG",
		Sub = "CREW ONLY // NO AUTOGRAPHS",
		TitleFont = GothamBold,
		BodyFont = Code,
		TitleSize = 32
	}
}
local v2 = C(214, 198, 138) -- inferred equivalent call
local v3 = {
	GuitarRhythm = "Rhythm Guitar",
	GuitarLead = "Lead Guitar",
	Bass = "Bass",
	Drum = "Drums",
	Keyboard = "Keyboard",
	Piano = "Piano"
}

local v4 = {
	{ Key = "P", Name = "PERFECT", Token = "good" },
	{ Key = "G", Name = "GREAT", Token = "good" },
	{ Key = "Go", Name = "GOOD", Token = "ink" },
	{ Key = "Ok", Name = "OK", Token = "ink" },
	{ Key = "M", Name = "MISS", Token = "accent" },
	{ Key = "W", Name = "WRONG", Token = "accent" }
}

local v5 = {
	S = { "LEGEND.", "UNREAL!!", "ENCORE!" },
	A = { "NICE ONE", "LOUD & PROUD", "almost perfect" },
	B = { "not bad...", "KEEP GOING", "getting there" },
	C = { "PRACTICE!", "AGAIN.", "hands warm?" },
	D = { "OUCH.", "rough night", "TRY AGAIN" },
	F = { "...yikes", "never happened", "SHRED LESS?" }
}

local function make(className, items)
	local instance = Instance.new(className)
	local parent = nil

	for k, item in pairs(items) do
		if k == "Parent" then
			parent = item
		else
			instance[k] = item
		end
	end

	instance.Parent = parent
	return instance
end

local v6 = {}

local function tag(p, p2, p3) -- 20 equivalent calls inferred from this helper
	table.insert(v6, { p, p2, p3 })
	return p
end

local v7 = nil

local function applyPalette(clone)
	v7 = clone

	for _, v8 in ipairs(v6) do
		local v9 = clone[v8[3]]

		if v9 ~= nil then
			v8[1][v8[2]] = v9
		end
	end
end

local function stroke(parent, color, value, value2)
	local v8 = make("UIStroke", {
		Parent = parent,
		Thickness = value or 1,
		Transparency = value2 or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	})

	if typeof(color) == "Color3" then
		v8.Color = color
		return v8
	end

	return tag(v8, "Color", color) -- inferred equivalent call
end

local function text(parent, data)
	local v8 = make("TextLabel", {
		Parent = parent,
		BackgroundTransparency = 1,
		Text = data.Text or "",
		TextSize = data.Size or 14,
		TextXAlignment = data.XAlign or Enum.TextXAlignment.Left,
		TextYAlignment = data.YAlign or Enum.TextYAlignment.Center,
		TextWrapped = data.Wrapped == true,
		TextTruncate = data.Truncate or Enum.TextTruncate.None,
		Position = UDim2.fromOffset(data.X or 0, data.Y or 0),
		Size = UDim2.fromOffset(data.W or 100, data.H or 18),
		Rotation = data.Rotation or 0,
		Visible = data.Visible ~= false
	})

	local color = data.Color or "ink"

	if typeof(color) == "Color3" then
		v8.TextColor3 = color
	else
		tag(v8, "TextColor3", color) -- inferred equivalent call
	end

	local font = data.Font or "body"

	if typeof(font) == "EnumItem" then
		v8.Font = font
		return v8
	end

	return tag(v8, "Font", font) -- inferred equivalent call
end

local function rect(parent, p, p2, p3, p4, backgroundColor, backgroundTransparency, value, p5) -- 10 equivalent calls inferred from this helper
	local parent2 = make("Frame", {
		Parent = parent,
		Position = UDim2.fromOffset(p, p2),
		Size = UDim2.fromOffset(p3, p4),
		BackgroundColor3 = backgroundColor,
		BackgroundTransparency = backgroundTransparency,
		BorderSizePixel = 0,
		Rotation = value or 0
	})

	if p5 then
		make("UICorner", { Parent = parent2, CornerRadius = UDim.new(1, 0) })
	end

	return parent2
end

local v8 = {
	masking = {
		color = Color3.fromRGB(214, 198, 138),
		transparency = 0.2,
		edge = Color3.fromRGB(160, 142, 86)
	},
	duct = {
		color = Color3.fromRGB(150, 152, 150),
		transparency = 0.1,
		edge = Color3.fromRGB(84, 86, 84),
		lines = true
	},
	black = {
		color = Color3.fromRGB(34, 34, 36),
		transparency = 0.06,
		edge = Color3.fromRGB(8, 8, 8)
	},
	red = {
		color = Color3.fromRGB(172, 38, 34),
		transparency = 0.14,
		edge = Color3.fromRGB(98, 14, 12)
	}
}

local v9 = { "masking", "duct", "black", "masking", "red", "duct" }

local function makeTape(parent, p, p2, p3, p4, p5, p6, object)
	local v10 = v8[p6] or v8.masking
	local tape = rect(parent, p, p2, p3, p4, v10.color, v10.transparency, p5, false)
	stroke(tape, v10.edge, 1, 0.3)
	local color = Color3.new(1, 1, 1)
	make("Frame", {
		Parent = tape,
		Position = UDim2.fromOffset(0, 2),
		Size = UDim2.fromOffset(p3, 2),
		BackgroundColor3 = color,
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
		Rotation = 0
	})

	if v10.lines then
		for i = 1, 3 do
			local v11 = math.floor(p4 * i / 4)
			local edge = v10.edge
			make("Frame", {
				Parent = tape,
				Position = UDim2.fromOffset(0, v11),
				Size = UDim2.fromOffset(p3, 1),
				BackgroundColor3 = edge,
				BackgroundTransparency = 0.6,
				BorderSizePixel = 0,
				Rotation = 0
			})
		end
	end

	for _ = 1, 5 do
		local integer = object:NextInteger(2, 5)
		rect(
			tape,
			object:NextInteger(2, (math.max(3, (math.floor)(p3) - 6))),
			object:NextInteger(1, (math.max(2, (math.floor)(p4) - 4))),
			integer,
			integer,
			Color3.new(0, 0, 0),
			object:NextNumber(0.5, 0.8),
			0,
			true
		)
	end

	return tape
end

local function hashString(value) -- 3 equivalent calls inferred from this helper
	local v10 = 5381

	for i = 1, #value do
		v10 = (v10 * 33 + string.byte(value, i)) % 2147483647
	end

	return v10
end

local function withCommas(p)
	return (tostring((math.floor((tonumber(p) or 0) + 0.5))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

local function fmtDuration(duration) -- 1 equivalent call inferred from this helper
	local v10 = math.max(0, (math.floor(tonumber(duration) or 0)))
	return string.format("%d:%02d", v10 // 60, v10 % 60)
end

local function relativeTime(p)
	local v10 = math.max(0, Workspace:GetServerTimeNow() - (tonumber(p) or 0))

	if v10 < 60 then
		return "just now"
	end

	if v10 < 3600 then
		return string.format("%d min ago", v10 // 60)
	end

	if v10 < 86400 then
		return string.format("%dh ago", v10 // 3600)
	end

	local v11 = v10 // 86400

	if v11 < 2 then
		return "yesterday"
	end

	if v11 < 30 then
		return string.format("%d days ago", v11)
	end

	return string.format("%d mo ago", v11 // 30)
end

local function absoluteTime(time) -- 1 equivalent call inferred from this helper
	local success, result = pcall(function()
		return DateTime.fromUnixTimestamp(tonumber(time) or 0):FormatLocalTime("MMM DD, YYYY  HH:mm", "en-us")
	end)

	return success and result or "unknown date"
end

local function reduceMotion()
	local success, result = pcall(function()
		local SettingsState = require(ReplicatedStorage.Modules.SettingsState)
		return SettingsState.GetReduceMotionEnabled()
	end)

	return success and result == true
end

local function instrumentName(value) -- 3 equivalent calls inferred from this helper
	return v3[value] or tostring(value or "?")
end

local function idOf(p) -- 7 equivalent calls inferred from this helper
	return p.Id or "t" .. tostring(p.Time)
end

local function styleIndexOf(p) -- 3 equivalent calls inferred from this helper
	return (math.floor(tonumber(p.Style) or (tonumber(p.Time) or 0) % #v + 1) - 1) % #v + 1
end

local flag = false
local parent = nil
local v10 = nil
local parent2 = nil
local v11 = nil
local parent3 = nil
local parent4 = nil
local v12 = nil
local v13 = nil
local v14 = nil
local v15 = nil
local v16 = nil
local flag2 = false
local lastTime = 0
local v17 = false
local v18 = 1
local v19 = 1

local parent5 = nil
local v20 = nil
local parent6 = nil
local v21 = nil
local v22 = nil
local parent7 = nil
local v23 = nil
local v24 = nil
local v25 = nil
local v26 = nil
local v27 = nil
local v28 = nil
local v29 = nil
local parent8 = nil
local v30 = nil
local v31 = nil
local v32 = nil
local v41 = nil
local v42 = nil
local v43 = nil
local parent9 = nil
local v45 = nil
local v46 = nil
local v47 = nil
local v48 = nil
local parent10 = nil
local v50 = {}
local v51 = {}
local v52 = {}
local parent11 = nil
local v54 = nil
local v55 = nil
local v56 = nil
local v57 = nil
local v58 = nil
local v59 = nil
local v60 = nil
local v61 = nil
local v62 = nil

local v63 = false
local v64 = false
local v65 = nil
local count = 0
local resultHistoryHiddenChangedConnection = nil
local v66 = nil
local flag3 = false
local v67 = false
local text2 = nil

local function setMenuLock(p)
	local success, result = pcall(function()
		return require(ReplicatedStorage.Modules.SessionCameraSettings)
	end)

	if success and result then
		if p and not v64 then
			v64 = true
			result.SetMenuOpen(true)
		elseif not p and v64 then
			v64 = false
			result.SetMenuOpen(false)
		end
	end
end

local function currentList() -- 4 equivalent calls inferred from this helper
	if v65 and v65.State == "ready" then
		return v65.Mode == "kept" and v65.Kept or v65.Entries
	end

	return {}
end

local function rebuildKeptIds()
	v65.KeptIds = {}

	for _, v69 in ipairs(v65.Kept) do
		v65.KeptIds[idOf(v69)] = true -- inferred equivalent call
	end
end

local function isKept(p): boolean -- 4 equivalent calls inferred from this helper
	return v65 ~= nil and v65.KeptIds ~= nil and v65.KeptIds[idOf(p)] == true -- inferred equivalent call
end

local function clearChildren(instance) -- 5 equivalent calls inferred from this helper
	for _, child in ipairs(instance:GetChildren()) do
		child:Destroy()
	end
end

local function vignette(p)
	local function strip(p2, p3, p4, p5, rotation)
		local parent12 = rect(p, p2, p3, p4, p5, Color3.new(0, 0, 0), 0) -- inferred equivalent call
		make("UIGradient", {
			Parent = parent12,
			Rotation = rotation,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.58), NumberSequenceKeypoint.new(1, 1) })
		})
	end
	strip(0, 0, 540, 70, 90)
	strip(0, 648, 540, 90, 270)
	strip(0, 0, 46, 752, 0)
	strip(494, 0, 46, 752, 180)
end

local function buildTapes(random)
	for _, v69 in ipairs({
		{ cx = 14, cy = 12, rot = -45 },
		{ cx = 526, cy = 12, rot = 45 },
		{ cx = 14, cy = 734, rot = 45 },
		{ cx = 526, cy = 734, rot = -45 }
	}) do
		local integer = random:NextInteger(104, 128)
		local integer2 = random:NextInteger(26, 32)
		makeTape(
			v23,
			v69.cx - integer / 2 + random:NextInteger(-6, 6),
			v69.cy - integer2 / 2 + random:NextInteger(-4, 4),
			integer,
			integer2,
			v69.rot + random:NextInteger(-9, 9),
			v9[random:NextInteger(1, #v9)],
			random
		)
	end

	for _ = 1, random:NextInteger(1, 2) do
		local integer = random:NextInteger(90, 120)
		local v69 = random:NextInteger(0, 1) == 0 and 2 or 538
		local integer2 = random:NextInteger(250, 560)
		makeTape(
			v23,
			v69 - integer / 2,
			integer2 - 13,
			integer,
			26,
			90 + random:NextInteger(-14, 14),
			v9[random:NextInteger(1, #v9)],
			random
		)
	end
end

local function buildDecor(p, p2)
	clearChildren(parent4) -- inferred equivalent call
	clearChildren(v12) -- inferred equivalent call
	clearChildren(v23) -- inferred equivalent call
	local palette = v[p].Palette

	-- [DEDUP] synthesized from 2 duplicated terminal regions
	local function deduplicatedTail()
		for i = 0, 15 do
			local parent12 = v12
			local accent = palette.accent
			local v72 = i % 2 == 0 and 14 or -14
			make("Frame", {
				Parent = parent12,
				Position = UDim2.fromOffset(i * 13 + 34, i % 2 * 3 + 58),
				Size = UDim2.fromOffset(16, 3),
				BackgroundColor3 = accent,
				BackgroundTransparency = 0.1,
				BorderSizePixel = 0,
				Rotation = v72 or 0
			})
		end
	end

	local random = Random.new(hashString(tostring(p2 and idOf(p2) or "empty"))) -- inferred equivalent call

	for _ = 1, 18 do
		local integer = random:NextInteger(16, 74)
		rect(
			parent4,
			random:NextInteger(6, 540 - integer - 6),
			random:NextInteger(6, 752 - integer - 6),
			integer,
			math.floor(integer * random:NextNumber(0.55, 1)),
			palette.stain,
			random:NextNumber(0.82, 0.93),
			random:NextInteger(0, 180),
			true
		)
	end

	for _ = 1, 2 do
		local integer = random:NextInteger(70, 112)
		stroke(
			rect(
				parent4,
				random:NextInteger(10, 540 - integer - 10),
				random:NextInteger(10, 752 - integer - 10),
				integer,
				integer,
				palette.paper,
				1,
				0,
				true
			),
			palette.stain,
			random:NextInteger(3, 5),
			random:NextNumber(0.68, 0.8)
		)
	end

	for _ = 1, 20 do
		local integer = random:NextInteger(30, 170)
		rect(
			v12,
			random:NextInteger(0, 520),
			random:NextInteger(0, 742),
			integer,
			random:NextInteger(1, 2),
			palette.ink,
			random:NextNumber(0.72, 0.9),
			random:NextInteger(0, 180),
			false
		)
	end

	for _ = 1, 50 do
		local integer = random:NextInteger(2, 4)
		rect(
			v12,
			random:NextInteger(4, 532),
			random:NextInteger(4, 744),
			integer,
			integer,
			palette.ink,
			random:NextNumber(0.5, 0.75),
			0,
			true
		)
	end

	for _, v69 in ipairs({ 248, 496 }) do
		local parent12 = v12
		local color = Color3.new(0, 0, 0)
		make("Frame", {
			Parent = parent12,
			Position = UDim2.fromOffset(0, v69),
			Size = UDim2.fromOffset(540, 1),
			BackgroundColor3 = color,
			BackgroundTransparency = 0.8,
			BorderSizePixel = 0,
			Rotation = 0
		})

		local parent13 = v12
		local v72 = v69 + 1
		local color2 = Color3.new(1, 1, 1)
		make("Frame", {
			Parent = parent13,
			Position = UDim2.fromOffset(0, v72),
			Size = UDim2.fromOffset(540, 1),
			BackgroundColor3 = color2,
			BackgroundTransparency = 0.88,
			BorderSizePixel = 0,
			Rotation = 0
		})
	end

	local parent12 = v12
	local color = Color3.new(0, 0, 0)
	make("Frame", {
		Parent = parent12,
		Position = UDim2.fromOffset(270, 0),
		Size = UDim2.fromOffset(1, 752),
		BackgroundColor3 = color,
		BackgroundTransparency = 0.86,
		BorderSizePixel = 0,
		Rotation = 0
	})

	vignette(v12)
	buildTapes(random)

	local v70 = v5[p2 and tostring(p2.Grade) or "B"] or v5.B

	if p2 then
		local text_2 = text(v12, {
			Text = v70[random:NextInteger(1, #v70)],
			Font = GothamBold,
			Size = 19,
			Color = palette.accent,
			X = 248,
			Y = 360,
			W = 250,
			H = 28,
			Rotation = random:NextInteger(-5, -2)
		})
		text_2.TextTransparency = 0.12
	end

	if p == 1 then
		for _, v71 in ipairs({}) do
			stroke(rect(v12, v71[1], v71[2], 104, 28, v2, 0.2, v71[3]), C(176, 160, 100), 1, 0.45) -- inferred equivalent call
		end

		return deduplicatedTail()
	elseif p == 2 then
		stroke(rect(parent4, 12, 12, 516, 728, palette.paper, 1), palette.soft, 3, 0.25) -- inferred equivalent call
		stroke(rect(parent4, 20, 20, 500, 712, palette.paper, 1), palette.soft, 1, 0.35) -- inferred equivalent call

		for _, v71 in ipairs({
			{ 14, 14 },
			{ 512, 14 },
			{ 14, 724 },
			{ 512, 724 }
		}) do
			local parent13 = parent4
			local v73 = v71[1]
			local v74 = v71[2]
			local soft = palette.soft
			make("Frame", {
				Parent = parent13,
				Position = UDim2.fromOffset(v73, v74),
				Size = UDim2.fromOffset(14, 14),
				BackgroundColor3 = soft,
				BackgroundTransparency = 0.15,
				BorderSizePixel = 0,
				Rotation = 45
			})
		end
	elseif p == 3 then
		for i = 104, 682, 26 do
			local parent13 = parent4
			local soft = palette.soft
			make("Frame", {
				Parent = parent13,
				Position = UDim2.fromOffset(0, i),
				Size = UDim2.fromOffset(540, 1),
				BackgroundColor3 = soft,
				BackgroundTransparency = 0.7,
				BorderSizePixel = 0,
				Rotation = 0
			})
		end

		local parent13 = parent4
		local accent = palette.accent
		make("Frame", {
			Parent = parent13,
			Position = UDim2.fromOffset(26, 0),
			Size = UDim2.fromOffset(2, 752),
			BackgroundColor3 = accent,
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			Rotation = 0
		})

		for i = 52, 712, 96 do
			stroke(rect(parent4, 6, i, 14, 14, Color3.fromRGB(30, 28, 26), 0.15, 0, true), palette.paperDark, 2, 0.2)
		end

		local parent14 = rect(v12, 0, 0, 1, 1, v2, 1) -- inferred equivalent call
		parent14.Visible = false
		stroke(parent14, C(176, 160, 100), 1, 0.45) -- inferred equivalent call
		return deduplicatedTail()
	elseif p == 4 then
		local parent13 = parent4
		local ink = palette.ink
		make("Frame", {
			Parent = parent13,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(540, 12),
			BackgroundColor3 = ink,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			Rotation = 0
		})

		local parent14 = parent4
		local ink2 = palette.ink
		make("Frame", {
			Parent = parent14,
			Position = UDim2.fromOffset(0, 726),
			Size = UDim2.fromOffset(540, 12),
			BackgroundColor3 = ink2,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			Rotation = 0
		})

		for i = 0, 5 do
			for j = 0, 9 do
				local v73 = math.floor(j / 3) + 3
				rect(parent4, j * 16 + 316, i * 16 + 96, v73, v73, palette.ink, 0.5, 0, true)
			end
		end

		local text_2 = text(parent4, {
			Text = "LOUD",
			Font = GothamBold,
			Size = 170,
			Color = palette.ink,
			X = 20,
			Y = 330,
			W = 500,
			H = 220,
			Rotation = -14,
			XAlign = Enum.TextXAlignment.Center
		})
		text_2.TextTransparency = 0.93
	elseif p == 5 then
		for i = 0, 30 do
			local backgroundColor = i % 2 == 0 and C(232, 188, 40) or palette.ink -- inferred equivalent call
			make("Frame", {
				Parent = parent4,
				Position = UDim2.fromOffset(i * 18, 0),
				Size = UDim2.fromOffset(18, 14),
				BackgroundColor3 = backgroundColor,
				BackgroundTransparency = 0.05,
				BorderSizePixel = 0,
				Rotation = 0
			})
			make("Frame", {
				Parent = parent4,
				Position = UDim2.fromOffset(i * 18, 724),
				Size = UDim2.fromOffset(18, 14),
				BackgroundColor3 = backgroundColor,
				BackgroundTransparency = 0.05,
				BorderSizePixel = 0,
				Rotation = 0
			})
		end

		for i = 40, 712, 22 do
			local parent13 = parent4
			local paperDark = palette.paperDark
			make("Frame", {
				Parent = parent13,
				Position = UDim2.fromOffset(0, i),
				Size = UDim2.fromOffset(540, 1),
				BackgroundColor3 = paperDark,
				BackgroundTransparency = 0.55,
				BorderSizePixel = 0,
				Rotation = 0
			})
		end

		local parent13 = v12
		local backgroundColor = C(170, 170, 170) -- inferred equivalent call
		make("Frame", {
			Parent = parent13,
			Position = UDim2.fromOffset(22, 24),
			Size = UDim2.fromOffset(22, 5),
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = 0.1,
			BorderSizePixel = 0,
			Rotation = 0
		})

		local parent14 = v12
		local backgroundColor2 = C(170, 170, 170) -- inferred equivalent call
		make("Frame", {
			Parent = parent14,
			Position = UDim2.fromOffset(496, 24),
			Size = UDim2.fromOffset(22, 5),
			BackgroundColor3 = backgroundColor2,
			BackgroundTransparency = 0.1,
			BorderSizePixel = 0,
			Rotation = 0
		})
		local parent15 = rect(v12, 0, 0, 1, 1, C(214, 190, 140), 1) -- inferred equivalent call
		parent15.Visible = false
		stroke(parent15, C(176, 150, 100), 1, 0.5) -- inferred equivalent call
	end
end

local function makeStamp(parent12, text3, p, p2, p3, p4, rotation, color, value)
	local stamp = make("Frame", {
		Parent = parent12,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(p, p2),
		Size = UDim2.fromOffset(p3, p4),
		Rotation = rotation,
		Visible = false
	})

	make("UICorner", { Parent = stamp, CornerRadius = UDim.new(0, 4) })
	stroke(stamp, color, 3, 0.1)
	local text_2 = text(stamp, {
		Text = text3,
		Font = GothamBold,
		Size = value or 18,
		Color = color,
		XAlign = Enum.TextXAlignment.Center,
		W = p3,
		H = p4
	})

	text_2.TextTransparency = 0.08
	return stamp
end

local function makePaperButton(parent12, text3, p, p2, p3, p4)
	local paperButton = tag(tag(tag(make("TextButton", { -- inferred equivalent call
		Parent = parent12,
		AutoButtonColor = false,
		BackgroundTransparency = 0.35,
		Text = text3,
		TextSize = 14,
		Position = UDim2.fromOffset(p, p2),
		Size = UDim2.fromOffset(p3, p4)
	}), "BackgroundColor3", "paperDark"), "TextColor3", "ink"), "Font", "body")

	make("UICorner", { Parent = paperButton, CornerRadius = UDim.new(0, 3) })
	local v69 = {
		make("UIStroke", {
			Parent = paperButton,
			Thickness = 2,
			Transparency = 0.15,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}),
		"Color",
		"ink"
	}
	table.insert(v6, v69)

	paperButton.MouseEnter:Connect(function()
		paperButton.BackgroundTransparency = 0.1
	end)
	paperButton.MouseLeave:Connect(function()
		paperButton.BackgroundTransparency = paperButton:GetAttribute("BaseTransparency") or 0.35
	end)
	return paperButton
end

local backgroundColor = C(40, 34, 30) -- inferred equivalent call
local v70 = C(150, 28, 26) -- inferred equivalent call
local textColor = C(232, 220, 192) -- inferred equivalent call

local function makeControlButton(parent12, text3, p, p2, p3, p4, value)
	local controlButton = make("TextButton", {
		Parent = parent12,
		AutoButtonColor = false,
		BackgroundColor3 = backgroundColor,
		BackgroundTransparency = 0.08,
		Text = text3,
		Font = Code,
		TextSize = 14,
		TextColor3 = textColor,
		Position = UDim2.fromOffset(p, p2),
		Size = UDim2.fromOffset(p3, p4),
		Rotation = value or 0,
		ZIndex = 9
	})

	controlButton:SetAttribute("BaseTransparency", 0.08)
	make("UICorner", { Parent = controlButton, CornerRadius = UDim.new(0, 3) })
	local color = C(14, 10, 8) -- inferred equivalent call
	local v73 = make("UIStroke", {
		Parent = controlButton,
		Thickness = 2,
		Transparency = 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	})

	if typeof(color) == "Color3" then
		v73.Color = color
	else
		tag(v73, "Color", color) -- inferred equivalent call
	end

	local v74 = hashString(text3) -- inferred equivalent call
	local random = Random.new(v74)

	for _ = 1, 4 do
		local integer = random:NextInteger(2, 4)
		rect(
			controlButton,
			random:NextInteger(2, ((math.max)(3, p3 - 6))),
			random:NextInteger(2, ((math.max)(3, p4 - 6))),
			integer,
			integer,
			Color3.new(0, 0, 0),
			0.5,
			0,
			true
		)
	end

	local tape = makeTape(controlButton, p3 - 34, -8, 46, 15, 18 + v74 % 10, v9[v74 % #v9 + 1], random)
	tape.ZIndex = 10
	controlButton.MouseEnter:Connect(function()
		controlButton.BackgroundTransparency = 0
		controlButton.TextColor3 = Color3.new(1, 1, 1)
	end)
	controlButton.MouseLeave:Connect(function()
		controlButton.BackgroundTransparency = controlButton:GetAttribute("BaseTransparency") or 0.08
		controlButton.TextColor3 = textColor
	end)
	return controlButton
end

local function makeArrowButton(parent12, text3, p, p2, p3, p4)
	local arrowButton = make("TextButton", {
		Parent = parent12,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = text3,
		Font = GothamBold,
		TextSize = 52,
		TextColor3 = textColor,
		TextStrokeColor3 = C(14, 10, 8), -- inferred equivalent call
		TextStrokeTransparency = 0.15,
		Position = UDim2.fromOffset(p, p2),
		Size = UDim2.fromOffset(p3, p4),
		ZIndex = 9
	})

	arrowButton.MouseEnter:Connect(function()
		arrowButton.TextColor3 = C(220, 56, 50) -- inferred equivalent call
	end)
	arrowButton.MouseLeave:Connect(function()
		arrowButton.TextColor3 = textColor
	end)
	return arrowButton
end

local function makeCloseButton(parent12, p, p2)
	local closeButton = make("TextButton", {
		Parent = parent12,
		Name = "Close",
		Position = UDim2.fromOffset(p, p2),
		Size = UDim2.fromOffset(38, 38),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "X",
		Font = GothamBold,
		TextSize = 30,
		TextColor3 = C(236, 226, 200), -- inferred equivalent call
		TextStrokeColor3 = C(14, 10, 8), -- inferred equivalent call
		TextStrokeTransparency = 0.15,
		ZIndex = 9
	})

	closeButton.MouseEnter:Connect(function()
		closeButton.TextColor3 = C(220, 56, 50) -- inferred equivalent call
	end)
	closeButton.MouseLeave:Connect(function()
		closeButton.TextColor3 = C(236, 226, 200) -- inferred equivalent call
	end)
	closeButton.MouseButton1Click:Connect(function()
		ResultHistoryUI.Close()
	end)
	return closeButton
end

local function build()
	if flag then
		return
	end

	flag = true

	local playerGui = LocalPlayer:WaitForChild("PlayerGui")

	parent = make("ScreenGui", {
		Name = "ResultHistoryGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 60,
		Enabled = false,
		Parent = playerGui
	})

	v10 = make("TextButton", {
		Parent = parent,
		Name = "Backdrop",
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(8, 8, 9),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1
	})

	v10.MouseButton1Click:Connect(function()
		if flag2 or os.clock() - lastTime < 0.2 then
			return
		end

		ResultHistoryUI.Close()
	end)

	parent2 = make("Frame", {
		Parent = parent,
		Name = "Holder",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(540, 752),
		BackgroundTransparency = 1,
		ZIndex = 2
	})

	v11 = make("UIScale", { Parent = parent2 })

	local make_2 = make("Frame", {
		Parent = parent2,
		Name = "ClickShield",
		Size = UDim2.fromOffset(548, 760),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 2
	})
	make_2.Name = "ClickShield"

	v13 = 1
	v15 = false
	local v72 = nil
	local function setZoomed(p)
		if v15 == p then
			return
		end

		v15 = p

		if v72 then
			v72:Cancel()
		end

		v72 = TweenService:Create(
			v11,
			TweenInfo.new(p and 0.12 or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Scale = p and v14 or v13
			}
		)

		v72:Play()
	end
	local function onPaperPress(p)
		if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
			flag2 = true
			setZoomed(true)
		end
	end
	parent2:FindFirstChild("ClickShield").InputBegan:Connect(onPaperPress)
	UserInputService.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if flag2 then
				flag2 = false
				lastTime = os.clock()
			end

			setZoomed(false)
		end
	end)
	v16 = onPaperPress
	make("Frame", {
		Parent = parent2,
		Name = "Shadow",
		Position = UDim2.fromOffset(6, 8),
		Size = UDim2.fromOffset(540, 748),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		ZIndex = 2
	})

	parent3 = make("Frame", {
		Parent = parent2,
		Name = "Paper",
		Size = UDim2.fromOffset(540, 738),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Active = true,
		ZIndex = 3
	})

	if v16 then
		parent3.InputBegan:Connect(v16)
	end

	tag(parent3, "BackgroundColor3", "paper") -- inferred equivalent call
	make("UICorner", { Parent = parent3, CornerRadius = UDim.new(0, 2) })

	local random = Random.new(7)
	local total = 0
	local v73 = 7

	while total < 540 do
		local integer = random:NextInteger(3, 6)
		v73 = math.clamp(v73 + random:NextInteger(-3, 3), 2, 14)

		if random:NextInteger(1, 24) == 1 then
			v73 = random:NextInteger(1, 4)
		end

		local v74 = math.min(integer, 540 - total) + 1
		local v75 = {
			make("Frame", {
				Parent = parent2,
				BorderSizePixel = 0,
				ZIndex = 3,
				Position = UDim2.fromOffset(total, 737),
				Size = UDim2.fromOffset(v74, v73 + 1)
			}),
			"BackgroundColor3",
			"paperDark"
		}
		table.insert(v6, v75)
		local v76 = {
			make("Frame", {
				Parent = parent2,
				BorderSizePixel = 0,
				ZIndex = 3,
				Position = UDim2.fromOffset(total, v73 + 738 - 2),
				Size = UDim2.fromOffset(v74, 3)
			}),
			"BackgroundColor3",
			"paperFiber"
		}
		table.insert(v6, v76)

		total += integer
	end

	v23 = make("Frame", {
		Parent = parent2,
		Name = "TapeLayer",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(540, 752),
		ZIndex = 8
	})

	parent4 = make("Frame", {
		Parent = parent3,
		Name = "DecorBack",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1)
	})

	v24 = text(parent3, {
		Text = "SCORE REPORT",
		Font = "title",
		Size = 32,
		X = 34,
		Y = 20,
		W = 330,
		H = 42
	})
	v25 = text(parent3, {
		Text = "",
		Size = 12,
		Color = "soft",
		X = 34,
		Y = 64,
		W = 380,
		H = 16
	})
	v27 = text(parent3, {
		Text = "",
		Size = 14,
		Color = "soft",
		X = 306,
		Y = 30,
		W = 200,
		H = 22,
		XAlign = Enum.TextXAlignment.Right
	})

	v28 = makeControlButton(parent2, "RECENT", 6, -48, 132, 34, -1)
	v29 = makeControlButton(parent2, "KEPT", 146, -48, 132, 34, 1)
	local v74 = v29
	v28.TextSize = 14
	v74.TextSize = 14
	local parent12 = parent3
	local backgroundColor2 = C(0, 0, 0) -- inferred equivalent call
	local v77 = {
		make("Frame", {
			Parent = parent12,
			Position = UDim2.fromOffset(34, 84),
			Size = UDim2.fromOffset(472, 2),
			BackgroundColor3 = backgroundColor2,
			BackgroundTransparency = 0.65,
			BorderSizePixel = 0,
			Rotation = 0
		}),
		"BackgroundColor3",
		"ink"
	}
	table.insert(v6, v77)

	v26 = text(parent3, {
		Text = "",
		Size = 15,
		X = 34,
		Y = 94,
		W = 340,
		H = 20,
		Truncate = Enum.TextTruncate.AtEnd
	})

	parent8 = make("Frame", {
		Parent = parent3,
		Name = "Entry",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(540, 752),
		Visible = false
	})

	v41 = text(parent8, {
		Text = "",
		Size = 20,
		X = 34,
		Y = 118,
		W = 320,
		H = 50,
		Wrapped = true,
		YAlign = Enum.TextYAlignment.Top,
		Truncate = Enum.TextTruncate.AtEnd
	})

	v42 = text(parent8, {
		Text = "",
		Size = 14,
		Color = "soft",
		X = 34,
		Y = 170,
		W = 340,
		H = 18,
		Truncate = Enum.TextTruncate.AtEnd
	})
	v43 = text(parent8, {
		Text = "",
		Size = 13,
		Color = "soft",
		X = 34,
		Y = 192,
		W = 350,
		H = 18,
		Truncate = Enum.TextTruncate.AtEnd
	})

	parent9 = make("Frame", {
		Parent = parent8,
		Position = UDim2.fromOffset(388, 100),
		Size = UDim2.fromOffset(112, 112),
		BackgroundTransparency = 1,
		Rotation = -10
	})
	tag(parent9, "BackgroundColor3", "accent") -- inferred equivalent call
	make("UICorner", { Parent = parent9, CornerRadius = UDim.new(1, 0) })
	local v78 = {
		make("UIStroke", {
			Parent = parent9,
			Thickness = 5,
			Transparency = 0.1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}),
		"Color",
		"accent"
	}
	table.insert(v6, v78)

	local parent13 = make("Frame", {
		Parent = parent9,
		Position = UDim2.fromOffset(9, 9),
		Size = UDim2.fromOffset(94, 94),
		BackgroundTransparency = 1
	})

	make("UICorner", { Parent = parent13, CornerRadius = UDim.new(1, 0) })
	local v80 = {
		make("UIStroke", {
			Parent = parent13,
			Thickness = 2,
			Transparency = 0.25,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}),
		"Color",
		"accent"
	}
	table.insert(v6, v80)

	v45 = text(parent9, {
		Text = "-",
		Font = GothamBold,
		Size = 64,
		Color = "accent",
		XAlign = Enum.TextXAlignment.Center,
		W = 112,
		H = 112
	})

	v46 = makeStamp(parent8, "NEW RECORD", 330, 226, 164, 32, 6, "accent", 18)
	v47 = makeStamp(parent8, "LEFT EARLY", 330, 226, 164, 32, 6, "soft", 18)
	v48 = makeStamp(parent8, "MVP", 256, 226, 60, 32, -8, "good", 18)

	local parent14 = parent8
	local backgroundColor3 = C(0, 0, 0) -- inferred equivalent call
	local v83 = {
		make("Frame", {
			Parent = parent14,
			Position = UDim2.fromOffset(34, 222),
			Size = UDim2.fromOffset(272, 2),
			BackgroundColor3 = backgroundColor3,
			BackgroundTransparency = 0.6,
			BorderSizePixel = 0,
			Rotation = 0
		}),
		"BackgroundColor3",
		"ink"
	}
	table.insert(v6, v83)

	for i, v84 in ipairs({
		{ Key = "Accuracy", Label = "ACCURACY" },
		{ Key = "Score", Label = "SCORE" },
		{ Key = "Combo", Label = "MAX COMBO" },
		{ Key = "Notes", Label = "NOTES HIT" }
	}) do
		local v85 = 236 + (i - 1) * 30
		text(parent8, {
			Text = v84.Label,
			Size = 15,
			Color = "soft",
			X = 34,
			Y = v85,
			W = 170,
			H = 26
		})
		v50[v84.Key] = text(parent8, {
			Text = "-",
			Size = v84.Key == "Accuracy" and 24 or 19,
			Font = v84.Key == "Accuracy" and GothamBold or "body",
			X = 184,
			Y = v85 - 2,
			W = 300,
			H = 30,
			XAlign = Enum.TextXAlignment.Right
		})

		local parent15 = parent8
		local v87 = v85 + 28
		local backgroundColor4 = C(0, 0, 0) -- inferred equivalent call
		local v89 = {
			make("Frame", {
				Parent = parent15,
				Position = UDim2.fromOffset(34, v87),
				Size = UDim2.fromOffset(472, 1),
				BackgroundColor3 = backgroundColor4,
				BackgroundTransparency = 0.8,
				BorderSizePixel = 0,
				Rotation = 0
			}),
			"BackgroundColor3",
			"ink"
		}
		table.insert(v6, v89)
	end

	text(parent8, {
		Text = "JUDGEMENTS",
		Font = GothamBold,
		Size = 18,
		X = 34,
		Y = 364,
		W = 200,
		H = 24
	})

	for i, v84 in ipairs(v4) do
		local v85 = 394 + (i - 1) * 22
		text(parent8, {
			Text = v84.Name,
			Size = 13,
			Color = "soft",
			X = 34,
			Y = v85,
			W = 90,
			H = 18
		})
		local parent15 = tag(rect(parent8, 130, v85 + 4, 280, 10, C(0, 0, 0), 0.88), "BackgroundColor3", "ink") -- inferred equivalent call

		local v87 = make("Frame", {
			Parent = parent15,
			Size = UDim2.fromScale(0, 1),
			BackgroundTransparency = 0.1,
			BorderSizePixel = 0
		})
		local v88 = { v87, "BackgroundColor3", v84.Token }
		table.insert(v6, v88)

		v51[v84.Key] = v87
		v52[v84.Key] = text(parent8, {
			Text = "0",
			Size = 14,
			X = 420,
			Y = v85,
			W = 86,
			H = 18,
			XAlign = Enum.TextXAlignment.Right
		})
	end

	text(parent8, {
		Text = "ACCURACY OVER TIME",
		Font = GothamBold,
		Size = 18,
		X = 34,
		Y = 534,
		W = 280,
		H = 24
	})
	local parent15 = parent8
	local backgroundColor4 = C(0, 0, 0) -- inferred equivalent call
	parent11 = make("Frame", {
		Parent = parent15,
		Position = UDim2.fromOffset(68, 562),
		Size = UDim2.fromOffset(438, 78),
		BackgroundColor3 = backgroundColor4,
		BackgroundTransparency = 0.93,
		BorderSizePixel = 0,
		Rotation = 0
	})
	tag(parent11, "BackgroundColor3", "ink") -- inferred equivalent call
	local v86 = {
		make("UIStroke", {
			Parent = parent11,
			Thickness = 1,
			Transparency = 0.6,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}),
		"Color",
		"ink"
	}
	table.insert(v6, v86)

	text(parent8, {
		Text = "100%",
		Size = 11,
		Color = "soft",
		X = 32,
		Y = 558,
		W = 34,
		H = 14,
		XAlign = Enum.TextXAlignment.Right
	})
	text(parent8, {
		Text = "0%",
		Size = 11,
		Color = "soft",
		X = 32,
		Y = 626,
		W = 34,
		H = 14,
		XAlign = Enum.TextXAlignment.Right
	})
	text(parent8, {
		Text = "0:00",
		Size = 11,
		Color = "soft",
		X = 68,
		Y = 642,
		W = 60,
		H = 14
	})
	v54 = text(parent8, {
		Text = "",
		Size = 11,
		Color = "soft",
		X = 426,
		Y = 642,
		W = 80,
		H = 14,
		XAlign = Enum.TextXAlignment.Right
	})

	v55 = text(parent8, {
		Text = "",
		Font = GothamBold,
		Size = 19,
		Color = "accent",
		X = 34,
		Y = 662,
		W = 472,
		H = 24
	})
	v56 = text(parent8, {
		Text = "",
		Size = 12,
		Color = "soft",
		X = 34,
		Y = 688,
		W = 472,
		H = 34,
		Wrapped = true,
		YAlign = Enum.TextYAlignment.Top,
		Truncate = Enum.TextTruncate.AtEnd
	})

	v57 = text(parent8, {
		Text = "",
		Size = 11,
		Color = "soft",
		X = 34,
		Y = 721,
		W = 472,
		H = 14,
		XAlign = Enum.TextXAlignment.Right
	})

	v57.Visible = false

	v30 = make("Frame", {
		Parent = parent3,
		Name = "Message",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(540, 752),
		Visible = true
	})

	v31 = text(v30, {
		Text = "",
		Font = GothamBold,
		Size = 38,
		Color = "accent",
		XAlign = Enum.TextXAlignment.Center,
		X = 34,
		Y = 290,
		W = 472,
		H = 90,
		Wrapped = true
	})

	v32 = text(v30, {
		Text = "",
		Size = 16,
		Color = "soft",
		XAlign = Enum.TextXAlignment.Center,
		X = 54,
		Y = 390,
		W = 432,
		H = 70,
		Wrapped = true,
		YAlign = Enum.TextYAlignment.Top
	})

	v58 = makeArrowButton(parent2, "<", -84, 312, 66, 128)
	v60 = makeControlButton(parent2, "KEEP THIS", 150, 772, 240, 42, 0)
	v60.Font = GothamBold
	v60.TextSize = 17
	v59 = makeArrowButton(parent2, ">", 558, 312, 66, 128)

	v61 = makeControlButton(parent2, "KEEPSAKE BOARD", 0, 832, 250, 34, -1)
	v61.TextSize = 12
	v62 = makeControlButton(parent2, "HIDE MY HISTORY: OFF", 290, 832, 250, 34, 1)
	v62.TextSize = 12

	parent10 = make("Frame", {
		Parent = parent2,
		Name = "Pin",
		Position = UDim2.fromOffset(260, -9),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = C(176, 30, 28), -- inferred equivalent call
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 9
	})

	make("UICorner", { Parent = parent10, CornerRadius = UDim.new(1, 0) })
	local parent16 = parent10
	local color = C(60, 10, 10) -- inferred equivalent call
	local v89 = make("UIStroke", {
		Parent = parent16,
		Thickness = 2,
		Transparency = 0.1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	})

	if typeof(color) == "Color3" then
		v89.Color = color
	else
		tag(v89, "Color", color) -- inferred equivalent call
	end

	make("Frame", {
		Parent = parent10,
		Position = UDim2.fromOffset(4, 3),
		Size = UDim2.fromOffset(6, 6),
		BackgroundColor3 = C(250, 190, 180), -- inferred equivalent call
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		ZIndex = 10
	}):FindFirstChildOfClass("UICorner")
	make("UICorner", {
		Parent = parent10:FindFirstChildOfClass("Frame"),
		CornerRadius = UDim.new(1, 0)
	})

	v12 = make("Frame", {
		Parent = parent3,
		Name = "DecorFront",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 4
	})

	makeCloseButton(parent2, 516, -14)

	parent5 = make("Frame", {
		Parent = parent,
		Name = "BoardHolder",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(660, 560),
		BackgroundColor3 = C(98, 70, 46), -- inferred equivalent call
		BorderSizePixel = 0,
		Visible = false,
		Active = true,
		ZIndex = 2
	})

	v20 = make("UIScale", { Parent = parent5 })

	local v90 = nil
	local function setBoardZoomed(p)
		if v17 == p then
			return
		end

		v17 = p

		if v90 then
			v90:Cancel()
		end

		v90 = TweenService:Create(
			v20,
			TweenInfo.new(p and 0.12 or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Scale = p and v19 or v18
			}
		)

		v90:Play()
	end
	local function onBoardPress(p)
		if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
			flag2 = true
			setBoardZoomed(true)
		end
	end
	parent5.InputBegan:Connect(onBoardPress)
	UserInputService.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if flag2 then
				flag2 = false
				lastTime = os.clock()
			end

			setBoardZoomed(false)
		end
	end)
	make("UICorner", { Parent = parent5, CornerRadius = UDim.new(0, 6) })
	local parent17 = parent5
	local color2 = C(40, 26, 14) -- inferred equivalent call
	local v93 = make("UIStroke", {
		Parent = parent17,
		Thickness = 6,
		Transparency = 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	})

	if typeof(color2) == "Color3" then
		v93.Color = color2
	else
		tag(v93, "Color", color2) -- inferred equivalent call
	end

	local random2 = Random.new(11)

	for _ = 1, 140 do
		local integer = random2:NextInteger(2, 6)
		rect(
			parent5,
			random2:NextInteger(4, 650),
			random2:NextInteger(4, 550),
			integer,
			integer,
			random2:NextInteger(0, 1) == 0 and C(60, 40, 24) or C(140, 108, 74), -- inferred equivalent call
			random2:NextNumber(0.4, 0.75),
			0,
			true
		)
	end

	make("TextLabel", {
		Parent = parent5,
		BackgroundTransparency = 1,
		Text = "KEEPSAKE BOARD",
		Font = GothamBold,
		TextSize = 32,
		TextColor3 = C(236, 224, 196), -- inferred equivalent call
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(24, 14),
		Size = UDim2.fromOffset(380, 40),
		ZIndex = 3
	})

	v21 = make("TextLabel", {
		Parent = parent5,
		BackgroundTransparency = 1,
		Text = "",
		Font = Code,
		TextSize = 14,
		TextColor3 = C(206, 190, 160), -- inferred equivalent call
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(26, 56),
		Size = UDim2.fromOffset(380, 20),
		ZIndex = 3
	})

	local parent18 = make("Frame", {
		Parent = parent5,
		Name = "BoardDecorBack",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2
	})

	local parent19 = make("Frame", {
		Parent = parent5,
		Name = "BoardDecorFront",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 6
	})
	local parent20 = rect(parent18, 8, 8, 644, 544, C(0, 0, 0), 1) -- inferred equivalent call
	local color3 = C(30, 18, 10) -- inferred equivalent call
	local v98 = make("UIStroke", {
		Parent = parent20,
		Thickness = 2,
		Transparency = 0.3,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	})

	if typeof(color3) == "Color3" then
		v98.Color = color3
	else
		tag(v98, "Color", color3) -- inferred equivalent call
	end

	for _ = 1, 18 do
		local integer = random2:NextInteger(26, 120)
		rect(
			parent18,
			random2:NextInteger(0, 660 - integer),
			random2:NextInteger(0, 560 - integer),
			integer,
			math.floor(integer * random2:NextNumber(0.5, 1)),
			C(44, 28, 16), -- inferred equivalent call
			random2:NextNumber(0.74, 0.9),
			random2:NextInteger(0, 180),
			true
		)
	end

	for _ = 1, 3 do
		local integer = random2:NextInteger(26, 44)
		local parent21 = rect(
			parent18,
			random2:NextInteger(30, 580),
			random2:NextInteger(100, 480),
			integer,
			integer,
			C(16, 10, 6), -- inferred equivalent call
			0.45,
			0,
			true
		)
		local color4 = C(72, 42, 18) -- inferred equivalent call
		local v101 = make("UIStroke", {
			Parent = parent21,
			Thickness = 4,
			Transparency = 0.55,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		})

		if typeof(color4) == "Color3" then
			v101.Color = color4
		else
			tag(v101, "Color", color4) -- inferred equivalent call
		end
	end

	for _ = 1, 2 do
		local integer = random2:NextInteger(80, 120)
		local parent21 = rect(
			parent18,
			random2:NextInteger(10, 660 - integer - 10),
			random2:NextInteger(90, 560 - integer - 10),
			integer,
			integer,
			C(98, 70, 46), -- inferred equivalent call
			1,
			0,
			true
		)
		local color4 = C(40, 26, 14) -- inferred equivalent call
		local v101 = make("UIStroke", {
			Parent = parent21,
			Thickness = 5,
			Transparency = 0.72,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		})

		if typeof(color4) == "Color3" then
			v101.Color = color4
		else
			tag(v101, "Color", color4) -- inferred equivalent call
		end
	end

	for _, v99 in ipairs({
		{ "KEEP IT LOUD", 30, 456, 46, -5, C(176, 40, 34), 0.5 }, -- inferred equivalent call
		{ "NO FEAR", 410, 384, 40, 6, C(236, 224, 196), 0.72 }, -- inferred equivalent call
		{ "RIFF OR DIE", 36, 258, 30, -4, C(176, 40, 34), 0.6 }, -- inferred equivalent call
		{ "X", 530, 120, 90, 8, C(236, 224, 196), 0.8 } -- inferred equivalent call
	}) do
		make("TextLabel", {
			Parent = parent18,
			BackgroundTransparency = 1,
			Text = v99[1],
			Font = GothamBold,
			TextSize = v99[4],
			TextColor3 = v99[6],
			TextTransparency = v99[7],
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(v99[2], v99[3]),
			Size = UDim2.fromOffset(300, v99[4] + 20),
			Rotation = v99[5]
		})
	end

	for _, v99 in ipairs({
		{ "ADMIT ONE", 450, 464, 7 },
		{ "BACKSTAGE", 22, 310, -8 }
	}) do
		local parent21 = rect(parent18, v99[2], v99[3], 128, 48, C(206, 184, 130), 0.05, v99[4]) -- inferred equivalent call
		local color4 = C(90, 66, 36) -- inferred equivalent call
		local v102 = make("UIStroke", {
			Parent = parent21,
			Thickness = 1,
			Transparency = 0.4,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		})

		if typeof(color4) == "Color3" then
			v102.Color = color4
		else
			tag(v102, "Color", color4) -- inferred equivalent call
		end

		make("TextLabel", {
			Parent = parent21,
			BackgroundTransparency = 1,
			Text = v99[1],
			Font = Code,
			TextSize = 15,
			TextColor3 = C(40, 26, 16), -- inferred equivalent call
			Size = UDim2.fromScale(1, 1)
		})
	end

	for i = 0, 15 do
		local backgroundColor5 = C(170, 36, 32) -- inferred equivalent call
		local v102 = i % 2 == 0 and 14 or -14
		make("Frame", {
			Parent = parent18,
			Position = UDim2.fromOffset(i * 14 + 26, 52 + i % 2 * 3),
			Size = UDim2.fromOffset(17, 3),
			BackgroundColor3 = backgroundColor5,
			BackgroundTransparency = 0.1,
			BorderSizePixel = 0,
			Rotation = v102 or 0
		})
	end

	for _ = 1, 26 do
		rect(
			parent19,
			random2:NextInteger(0, 640),
			random2:NextInteger(0, 550),
			random2:NextInteger(30, 160),
			random2:NextInteger(1, 2),
			random2:NextInteger(0, 1) == 0 and C(236, 224, 196) or C(20, 12, 8), -- inferred equivalent call
			random2:NextNumber(0.76, 0.92),
			random2:NextInteger(0, 180),
			false
		)
	end

	for _ = 1, 90 do
		local integer = random2:NextInteger(2, 4)
		rect(
			parent19,
			random2:NextInteger(4, 652),
			random2:NextInteger(4, 552),
			integer,
			integer,
			C(10, 6, 4), -- inferred equivalent call
			random2:NextNumber(0.45, 0.75),
			0,
			true
		)
	end

	local function boardStrip(p, p2, p3, p4, rotation)
		local parent21 = rect(parent19, p, p2, p3, p4, Color3.new(0, 0, 0), 0) -- inferred equivalent call
		make("UIGradient", {
			Parent = parent21,
			Rotation = rotation,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1) })
		})
	end
	boardStrip(0, 0, 660, 60, 90)
	boardStrip(0, 480, 660, 80, 270)
	boardStrip(0, 0, 44, 560, 0)
	boardStrip(616, 0, 44, 560, 180)

	for _, v99 in ipairs({
		{ 16, 14, -45 },
		{ 644, 14, 45 },
		{ 16, 546, 45 },
		{ 644, 546, -45 }
	}) do
		local integer = random2:NextInteger(110, 134)
		local integer2 = random2:NextInteger(26, 32)
		makeTape(
			parent19,
			v99[1] - integer / 2,
			v99[2] - integer2 / 2,
			integer,
			integer2,
			v99[3] + random2:NextInteger(-8, 8),
			v9[random2:NextInteger(1, #v9)],
			random2
		)
	end

	makeTape(parent19, 180, -8, 110, 26, 3, "duct", random2)
	makeTape(parent19, 410, 542, 110, 26, -4, "black", random2)

	local parent21 = make("TextButton", {
		Parent = parent5,
		Text = "< BACK TO PAPER",
		Font = Code,
		TextSize = 13,
		AutoButtonColor = false,
		TextColor3 = C(28, 24, 22), -- inferred equivalent call
		BackgroundColor3 = C(214, 198, 160), -- inferred equivalent call
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(450, 20),
		Size = UDim2.fromOffset(150, 28),
		ZIndex = 3
	})

	make("UICorner", { Parent = parent21, CornerRadius = UDim.new(0, 3) })
	local color4 = C(28, 24, 22) -- inferred equivalent call
	local v101 = make("UIStroke", {
		Parent = parent21,
		Thickness = 2,
		Transparency = 0.15,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	})

	if typeof(color4) == "Color3" then
		v101.Color = color4
	else
		tag(v101, "Color", color4) -- inferred equivalent call
	end

	parent21.MouseButton1Click:Connect(function()
		ResultHistoryUI.SetView("paper")
	end)
	parent6 = make("ScrollingFrame", {
		Parent = parent5,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 92),
		Size = UDim2.fromOffset(628, 452),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = C(214, 198, 160), -- inferred equivalent call
		ZIndex = 3
	})

	make("UIGridLayout", {
		Parent = parent6,
		CellSize = UDim2.fromOffset(188, 132),
		CellPadding = UDim2.fromOffset(12, 14),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	make("UIPadding", {
		Parent = parent6,
		PaddingTop = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 10)
	})
	parent6.InputBegan:Connect(onBoardPress)
	v22 = make("TextLabel", {
		Parent = parent5,
		BackgroundTransparency = 1,
		Text = "",
		Font = GothamBold,
		TextSize = 26,
		TextColor3 = C(236, 224, 196), -- inferred equivalent call
		TextWrapped = true,
		Position = UDim2.fromOffset(60, 220),
		Size = UDim2.fromOffset(540, 120),
		ZIndex = 3,
		Visible = false
	})

	parent7 = make("Frame", {
		Parent = parent5,
		Name = "EmptyNote",
		Position = UDim2.fromOffset(130, 210),
		Size = UDim2.fromOffset(400, 140),
		BackgroundColor3 = C(196, 182, 150), -- inferred equivalent call
		BorderSizePixel = 0,
		Rotation = -2,
		Visible = false,
		ZIndex = 4
	})

	local parent22 = parent7
	local color5 = C(60, 44, 30) -- inferred equivalent call
	local v104 = make("UIStroke", {
		Parent = parent22,
		Thickness = 1,
		Transparency = 0.4,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	})

	if typeof(color5) == "Color3" then
		v104.Color = color5
	else
		tag(v104, "Color", color5) -- inferred equivalent call
	end

	for _ = 1, 5 do
		local integer = random2:NextInteger(14, 44)
		rect(
			parent7,
			random2:NextInteger(0, 360),
			random2:NextInteger(0, 100),
			integer,
			integer,
			C(96, 70, 38), -- inferred equivalent call
			random2:NextNumber(0.82, 0.92),
			0,
			true
		)
	end

	local tape = makeTape(parent7, 150, -10, 100, 24, 3, "masking", random2)
	tape.ZIndex = 6
	v22.Parent = parent7
	v22.Position = UDim2.fromOffset(16, 14)
	v22.Size = UDim2.fromOffset(368, 112)
	v22.TextColor3 = C(28, 24, 22) -- inferred equivalent call
	v22.TextSize = 24
	v22.ZIndex = 5
	v22.Visible = true
	makeCloseButton(parent5, 636, -14)

	local function fit()
		local currentCamera = Workspace.CurrentCamera

		if not currentCamera then
			return
		end

		local viewportSize = currentCamera.ViewportSize
		v13 = math.clamp(math.min(1, viewportSize.Y * 0.93 / 992, viewportSize.X * 0.96 / 740), 0.28, 1)

		v14 = math.max(v13, (math.min(v13 * 1.45, viewportSize.Y * 0.98 / 752, viewportSize.X * 0.98 / 540)))

		v11.Scale = v15 and v14 or v13
		v18 = math.clamp(math.min(1, viewportSize.Y * 0.92 / 584, viewportSize.X * 0.96 / 690), 0.28, 1)
		v19 = math.max(v18, (math.min(v18 * 1.1, viewportSize.Y * 0.99 / 584, viewportSize.X * 0.99 / 690)))

		v20.Scale = v17 and v19 or v18
	end
	fit()
	local currentCamera = Workspace.CurrentCamera

	if currentCamera then
		currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not v63 or gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.Left then
			ResultHistoryUI.Step(-1)
		elseif input.KeyCode == Enum.KeyCode.Right then
			ResultHistoryUI.Step(1)
		end
	end)
end

local function drawChart(data)
	clearChildren(parent11) -- inferred equivalent call
	local v72 = v7
	local line = data.Line
	local offset = parent11.Size.X.Offset
	local offset2 = parent11.Size.Y.Offset

	if type(line) == "table" and not (#line < 2) then
		v54.Text = fmtDuration(data.Duration) -- inferred equivalent call

		local parent12 = parent11
		local halfOffset2 = offset2 / 2
		local ink = v72.ink
		make("Frame", {
			Parent = parent12,
			Position = UDim2.fromOffset(0, halfOffset2),
			Size = UDim2.fromOffset(offset, 1),
			BackgroundColor3 = ink,
			BackgroundTransparency = 0.78,
			BorderSizePixel = 0,
			Rotation = 0
		})

		local count2 = #line
		local function pointAt(p) -- 2 equivalent calls inferred from this helper
			local v76 = math.clamp(tonumber(line[p]) or 0, 0, 100)
			return Vector2.new((p - 1) / (count2 - 1) * offset, offset2 - v76 / 100 * offset2)
		end

		for i = 1, count2 - 1 do
			local v76 = pointAt(i) -- inferred equivalent call
			local v77 = pointAt(i + 1) -- inferred equivalent call
			local v78 = v77 - v76
			local magnitude = v78.Magnitude

			if not (magnitude > 0.1) then
				continue
			end

			local parent13 = parent11
			local midpointX = (v76.X + v77.X) / 2
			local midpointY = (v76.Y + v77.Y) / 2
			local v82 = magnitude + 1
			local accent = v72.accent
			local v83 = math.deg((math.atan2(v78.Y, v78.X)))
			local make_2 = make("Frame", {
				Parent = parent13,
				Position = UDim2.fromOffset(midpointX, midpointY),
				Size = UDim2.fromOffset(v82, 3),
				BackgroundColor3 = accent,
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Rotation = v83 or 0
			})

			make_2.AnchorPoint = Vector2.new(0.5, 0.5)
		end
	else
		text(parent11, {
			Text = "(no timeline for this run)",
			Size = 12,
			Color = v72.soft,
			W = offset,
			H = offset2,
			XAlign = Enum.TextXAlignment.Center,
			Font = Code
		})

		v54.Text = ""
	end
end

local function applyStyle(p, p2)
	local v72 = v[p]
	local clone = table.clone(v72.Palette)
	clone.body = v72.BodyFont
	clone.title = v72.TitleFont
	clone.paperFiber = clone.paper:Lerp(Color3.new(1, 1, 1), 0.4)
	applyPalette(clone)

	v24.Text = v72.Title
	v24.TextSize = v72.TitleSize
	v25.Text = v72.Sub

	if v72.GradeFilled then
		parent9.BackgroundTransparency = 0.06
		v45.TextColor3 = clone.paper
	else
		parent9.BackgroundTransparency = 1
	end

	local v73 = tostring(p) .. ":" .. tostring(p2 and idOf(p2) or "none") -- inferred equivalent call

	if v73 ~= v66 then
		v66 = v73
		buildDecor(p, p2)
	end
end

local function renderEntry(data)
	local grade = tostring(data.Grade or "-")
	v45.Text = grade

	v41.Text = string.upper((tostring(data.Song or "?")))
	local tier

	if type(data.Tier) == "string" then
		tier = data.Tier or nil
	end

	local v72 = (not tier or tier == "" or tier:lower() == "normal" or not tier) and "Natural" or tier
	local lanes = tonumber(data.Lanes) or tonumber(data.NativeLanes)
	v42.Text = instrumentName(data.Instrument) .. " / " .. v72 .. (lanes and " / " .. math.floor(lanes) .. " keys" or "") -- inferred equivalent call

	v43.Text = "FILED: " .. absoluteTime(data.Time) .. "  (" .. relativeTime(data.Time) .. ")" -- inferred equivalent call

	v50.Accuracy.Text = string.format("%.1f%%", tonumber(data.Accuracy) or 0)
	v50.Score.Text = withCommas(data.Score)
	v50.Combo.Text = withCommas(data.MaxCombo)
	v50.Notes.Text = string.format("%s / %s", withCommas(data.Hits), withCommas(data.TotalNotes))

	if type(data.Crowd) == "number" then
		v57.Text = "total crowd : " .. withCommas(data.Crowd)
		v57.Visible = true
	else
		v57.Text = ""
		v57.Visible = false
	end

	local j = type(data.J) == "table" and data.J or {}
	local maxValue = 1

	for _, v75 in ipairs(v4) do
		maxValue = math.max(maxValue, tonumber(j[v75.Key]) or 0)
	end

	for _, v75 in ipairs(v4) do
		local v76 = tonumber(j[v75.Key]) or 0
		v52[v75.Key].Text = withCommas(v76)
		v51[v75.Key].Size = UDim2.fromScale(math.clamp(v76 / maxValue, 0, 1), 1)
	end

	drawChart(data)

	v47.Visible = data.Early == true
	v46.Visible = data.NewPB == true and data.Early ~= true
	v48.Visible = data.MVP == true and data.Early ~= true

	if data.MVP == true and data.Early ~= true and data.NewPB ~= true then
		v48.Position = UDim2.fromOffset(330, 226)
	else
		v48.Position = UDim2.fromOffset(256, 226)
	end

	if data.Early then
		v55.Text = "RANK: n/a (left before the song ended)"
		v56.Text = ""
	elseif data.Rank and data.Count then
		v55.Text = string.format("RANK #%d of %d players", data.Rank, data.Count) .. (data.MVP and "  -  MVP" or "")
		local v79 = {}

		for _, v80 in ipairs(type(data.Band) == "table" and data.Band or {}) do
			local n = tostring(v80.N or "?")
			table.insert(v79, string.format("@%s (%s)", n, instrumentName(v80.I))) -- inferred equivalent call
		end

		v56.Text = #v79 > 0 and "PLAYED WITH: " .. table.concat(v79, ", ") or ""
	else
		v55.Text = "SOLO PERFORMANCE"
		v56.Text = ""
	end

	parent10.Visible = isKept(data) -- inferred equivalent call
end

local function refreshHideButton() -- 1 equivalent call inferred from this helper
	if not (flag and v65) then
		return
	end

	local v72 = v65.Player == LocalPlayer
	v62.Visible = v72 and v65.State ~= "loading"

	if v72 then
		local resultHistoryHidden = LocalPlayer:GetAttribute("ResultHistoryHidden") == true
		v62.Text = resultHistoryHidden and "HIDDEN FROM OTHERS (tap to show)" or "HIDE MY HISTORY: OFF"
		v62.TextSize = 12
	end
end

local function refreshKeepButton()
	if not (flag and v65) then
		return
	end

	local visible = v65.Player == LocalPlayer
	local v73 = currentList()[v65.Index] -- inferred equivalent call
	local v74 = v60

	if visible then
		if v73 == nil then
			visible = false
		else
			visible = v65.View == "paper"
		end
	end

	v74.Visible = visible

	if not v60.Visible then
		return
	end

	local kept = isKept(v73) -- inferred equivalent call

	if text2 then
		v60.Text = text2
	elseif flag3 then
		v60.Text = "TAP AGAIN TO REMOVE"
	elseif kept then
		v60.Text = "KEPT  (tap to unkeep)"
	else
		v60.Text = "KEEP THIS"
	end

	v60.TextSize = (kept or text2 or flag3) and 13 or 17
end

local function renderBoard()
	clearChildren(parent6) -- inferred equivalent call
	make("UIGridLayout", {
		Parent = parent6,
		CellSize = UDim2.fromOffset(188, 132),
		CellPadding = UDim2.fromOffset(12, 14),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	make("UIPadding", {
		Parent = parent6,
		PaddingTop = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 10)
	})

	local kept = v65 and v65.Kept or {}
	v21.Text = string.format("%d / %d pinned  -  tap a paper to read it again", #kept, 15)
	local displayName = v65 and v65.Player and v65.Player.DisplayName or "?"
	v22.Visible = #kept == 0
	parent7.Visible = #kept == 0

	if #kept == 0 then
		v22.Text = v65 and v65.Player == LocalPlayer and "Nothing pinned yet.\nOpen a result and tap KEEP THIS."
			or displayName .. " hasn't pinned anything yet."
	end

	for i, v72 in ipairs(kept) do
		local palette = v[styleIndexOf(v72)].Palette -- inferred equivalent call
		local random = Random.new(hashString(idOf(v72))) -- inferred equivalent call
		local parent12 = make("TextButton", {
			Parent = parent6,
			LayoutOrder = i,
			Text = "",
			AutoButtonColor = false,
			BackgroundColor3 = palette.paper,
			BorderSizePixel = 0,
			Rotation = random:NextNumber(-2.5, 2.5),
			ZIndex = 4
		})

		local soft = palette.soft
		local v74 = make("UIStroke", {
			Parent = parent12,
			Thickness = 1,
			Transparency = 0.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		})

		if typeof(soft) == "Color3" then
			v74.Color = soft
		else
			tag(v74, "Color", soft) -- inferred equivalent call
		end

		make("UICorner", { Parent = parent12, CornerRadius = UDim.new(0, 2) })

		for _ = 1, 4 do
			local integer = random:NextInteger(10, 34)
			rect(
				parent12,
				random:NextInteger(0, 150),
				random:NextInteger(0, 100),
				integer,
				integer,
				palette.stain,
				random:NextNumber(0.84, 0.93),
				0,
				true
			)
		end

		for _ = 1, 5 do
			local integer = random:NextInteger(0, 150)
			local integer2 = random:NextInteger(0, 120)
			local integer3 = random:NextInteger(20, 70)
			local ink = palette.ink
			local number = random:NextNumber(0.75, 0.9)
			local integer4 = random:NextInteger(0, 180)
			make("Frame", {
				Parent = parent12,
				Position = UDim2.fromOffset(integer, integer2),
				Size = UDim2.fromOffset(integer3, 1),
				BackgroundColor3 = ink,
				BackgroundTransparency = number,
				BorderSizePixel = 0,
				Rotation = integer4 or 0
			})
		end

		local tape = makeTape(
			parent12,
			66,
			-9,
			56,
			18,
			random:NextInteger(-8, 8),
			v9[random:NextInteger(1, #v9)],
			random
		)
		tape.ZIndex = 6
		text(parent12, {
			Text = tostring(v72.Grade or "-"),
			Font = GothamBold,
			Size = 46,
			Color = palette.accent,
			X = 8,
			Y = 8,
			W = 56,
			H = 56,
			XAlign = Enum.TextXAlignment.Center
		})
		text(parent12, {
			Text = string.upper((tostring(v72.Song or "?"))),
			Font = v[styleIndexOf(v72)].BodyFont, -- inferred equivalent call
			Size = 13,
			Color = palette.ink,
			X = 64,
			Y = 12,
			W = 118,
			H = 40,
			Wrapped = true,
			YAlign = Enum.TextYAlignment.Top,
			Truncate = Enum.TextTruncate.AtEnd
		})

		text(parent12, {
			Text = string.format("%.1f%%   %s", tonumber(v72.Accuracy) or 0, withCommas(v72.Score)),
			Font = Code,
			Size = 14,
			Color = palette.ink,
			X = 10,
			Y = 70,
			W = 170,
			H = 18,
			Truncate = Enum.TextTruncate.AtEnd
		})

		text(parent12, {
			Text = instrumentName(v72.Instrument) .. " / " .. relativeTime(v72.KeptAt or v72.Time), -- inferred equivalent call
			Font = Code,
			Size = 11,
			Color = palette.soft,
			X = 10,
			Y = 92,
			W = 170,
			H = 16,
			Truncate = Enum.TextTruncate.AtEnd
		})

		parent12.MouseEnter:Connect(function()
			parent12.BackgroundColor3 = palette.paper:Lerp(Color3.new(1, 1, 1), 0.12)
			parent12.ZIndex = 5
		end)
		parent12.MouseLeave:Connect(function()
			parent12.BackgroundColor3 = palette.paper
			parent12.ZIndex = 4
		end)
		parent12.MouseButton1Click:Connect(function()
			if v65 then
				v65.Mode = "kept"
				v65.Index = i
				ResultHistoryUI.SetView("paper")
			end
		end)
	end
end

local function render()
	if not (flag and v65) then
		return
	end

	if v65.View == "board" then
		renderBoard()
		return
	end

	local state = v65.State
	local visible = state == "ready"
	local displayName = v65.Player and v65.Player.DisplayName or "?"
	v26.Text = "PERFORMER: " .. displayName
	local v73 = currentList() -- inferred equivalent call

	if visible then
		v65.Index = math.clamp(v65.Index, 1, (math.max(1, #v73)))
	end

	local v74

	if visible then
		v74 = v73[v65.Index] or nil
	end

	applyStyle(v74 and styleIndexOf(v74) or 1, v74) -- inferred equivalent call

	local v75 = v29
	v28.Visible = visible
	v75.Visible = visible
	v61.Visible = visible
	v28.Text = string.format("RECENT %d", visible and #v65.Entries or 0)
	v29.Text = string.format("KEPT %d/%d", visible and #v65.Kept or 0, 15)
	local v76 = v65.Mode ~= "kept"
	v28:SetAttribute("BaseTransparency", v76 and 0.05 or 0.55)
	v29:SetAttribute("BaseTransparency", v76 and 0.55 or 0.05)
	v28.BackgroundTransparency = v76 and 0.05 or 0.55
	v29.BackgroundTransparency = v76 and 0.55 or 0.05
	v28.BackgroundColor3 = v76 and v70 or backgroundColor
	v29.BackgroundColor3 = v76 and backgroundColor or v70

	parent8.Visible = v74 ~= nil
	v30.Visible = v74 == nil

	if v74 then
		v27.Text = string.format("%s %d / %d", v65.Mode == "kept" and "KEPT" or "ENTRY", v65.Index, #v73)
		renderEntry(v74)
		v58.Visible = #v73 > 1
		v59.Visible = #v73 > 1
	else
		v27.Text = ""
		v58.Visible = false
		v59.Visible = false
		parent10.Visible = false

		if state == "loading" then
			v31.Text = "FETCHING REPORT..."
			v32.Text = "Digging through the stage manager's filing cabinet."
		elseif state == "locked" then
			v31.Text = "CLASSIFIED"
			v32.Text = displayName .. " chose to hide their Result History."
		elseif state == "ready" and v65.Mode == "kept" then
			v31.Text = "Nothing kept yet"
			v32.Text = v65.Player == LocalPlayer and "Open a result under RECENT and tap KEEP THIS to pin it here."
				or displayName .. " hasn't kept any results yet."
		elseif state == "ready" then
			v31.Text = "No results yet"
			v32.Text = v65.Player == LocalPlayer and "Finish a song and your first report gets filed here."
				or displayName .. " hasn't finished a song yet."
		else
			v31.Text = "REPORT LOST"
			v32.Text = "Couldn't fetch this history. Close the paper and try again."
		end
	end

	refreshHideButton() -- inferred equivalent call
	refreshKeepButton()
end

local function invokeKeep(p, p2)
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	local keepResultHistory = remoteEvents and remoteEvents:FindFirstChild("KeepResultHistory")

	if not keepResultHistory then
		return nil
	end

	local success, result = pcall(function()
		return keepResultHistory:InvokeServer(p, p2)
	end)

	return success and result or nil
end

local function flashKeep(p) -- 1 equivalent call inferred from this helper
	text2 = p
	refreshKeepButton()
	task.delay(2, function()
		if text2 == p then
			text2 = nil
			refreshKeepButton()
		end
	end)
end

local function onKeepClicked()
	if not v65 or v65.Player ~= LocalPlayer or v67 then
		return
	end

	local v72 = currentList()[v65.Index] -- inferred equivalent call

	if not v72 then
		return
	end

	local id = idOf(v72) -- inferred equivalent call
	local v74 = "keep"

	if isKept(v72) then -- inferred equivalent call
		if flag3 then
			flag3 = false
			v74 = "unkeep"
		else
			flag3 = true
			refreshKeepButton()
			task.delay(2.5, function()
				if flag3 then
					flag3 = false
					refreshKeepButton()
				end
			end)
			return
		end
	end

	v67 = true
	task.spawn(function()
		local v75 = invokeKeep(v74, id)
		v67 = false

		if not v65 then
			return
		end

		if v75 and v75.Ok then
			if v74 == "keep" then
				if not isKept(v72) then -- inferred equivalent call
					local clone = table.clone(v72)
					clone.Id = id
					clone.KeptAt = Workspace:GetServerTimeNow()
					table.insert(v65.Kept, 1, clone)
				end
			else
				for i, v76 in ipairs(v65.Kept) do
					if idOf(v76) == id then -- inferred equivalent call
						table.remove(v65.Kept, i)
						break
					end
				end
			end

			rebuildKeptIds()
		elseif v75 and v75.Reason == "Full" then
			flashKeep(string.format("FULL %d/%d - UNKEEP ONE FIRST", 15, 15)) -- inferred equivalent call
		else
			text2 = "COULDN'T KEEP - TRY AGAIN"
			refreshKeepButton()
			local v76 = "COULDN'T KEEP - TRY AGAIN"
			task.delay(2, function()
				if text2 == v76 then
					text2 = nil
					refreshKeepButton()
				end
			end)
		end

		render()
	end)
end

local function fetch(p, value)
	count += 1
	local v72 = count
	task.spawn(function()
		local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
		local getResultHistory = remoteEvents and remoteEvents:WaitForChild("GetResultHistory", 10)

		if getResultHistory then
			local success, result = pcall(function()
				return getResultHistory:InvokeServer(p.UserId)
			end)

			if v72 ~= count or not (v65 and v63) then
				return
			end

			if success and type(result) == "table" then
				if result.Locked then
					v65.State = "locked"
				elseif result.Busy or result.Loading then
					if (value or 1) < 4 then
						task.wait(0.6)

						if v72 == count and v65 and v63 then
							fetch(p, (value or 1) + 1)
						end

						return
					end

					v65.State = "error"
				elseif type(result.Entries) == "table" then
					v65.Entries = result.Entries
					v65.Kept = type(result.Kept) == "table" and result.Kept or {}
					rebuildKeptIds()
					v65.Index = 1
					v65.State = "ready"
				else
					v65.State = "error"
				end
			else
				v65.State = "error"
			end

			render()
		elseif v72 == count and v65 then
			v65.State = "error"
			render()
		end
	end)
end

function ResultHistoryUI.IsOpen()
	return v63
end

function ResultHistoryUI.SetView(view)
	if not (flag and v65) then
		return
	end

	v65.View = view
	parent2.Visible = view == "paper"
	parent5.Visible = view == "board"
	flag3 = false
	render()
end

function ResultHistoryUI.Step(p)
	if v65 and v65.View == "paper" and v65.State == "ready" then
		local count2 = #currentList() -- inferred equivalent call

		if count2 > 1 then
			v65.Index = (v65.Index - 1 + p) % count2 + 1
			flag3 = false
			render()
		end
	end
end

function ResultHistoryUI.Open(player)
	if not (player and player.Parent) then
		return
	end

	build()

	v65 = {
		Player = player,
		Entries = {},
		Kept = {},
		KeptIds = {},
		Index = 1,
		Mode = "recent",
		View = "paper",
		State = "loading"
	}

	flag3 = false
	v67 = false
	text2 = nil
	v66 = nil
	parent2.Visible = true
	parent5.Visible = false

	if resultHistoryHiddenChangedConnection then
		resultHistoryHiddenChangedConnection:Disconnect()
	end

	resultHistoryHiddenChangedConnection = LocalPlayer:GetAttributeChangedSignal("ResultHistoryHidden"):Connect(refreshHideButton)

	render()
	local v72 = v63
	v63 = true
	count += 1
	local v73 = count
	local v74 = 1
	task.spawn(function()
		local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
		local getResultHistory = remoteEvents and remoteEvents:WaitForChild("GetResultHistory", 10)

		if getResultHistory then
			local success, result = pcall(function()
				return getResultHistory:InvokeServer(player.UserId)
			end)

			if v73 ~= count or not (v65 and v63) then
				return
			end

			if success and type(result) == "table" then
				if result.Locked then
					v65.State = "locked"
				elseif result.Busy or result.Loading then
					if (v74 or 1) < 4 then
						task.wait(0.6)

						if v73 == count and v65 and v63 then
							fetch(player, (v74 or 1) + 1)
						end

						return
					end

					v65.State = "error"
				elseif type(result.Entries) == "table" then
					v65.Entries = result.Entries
					v65.Kept = type(result.Kept) == "table" and result.Kept or {}
					rebuildKeptIds()
					v65.Index = 1
					v65.State = "ready"
				else
					v65.State = "error"
				end
			else
				v65.State = "error"
			end

			render()
		elseif v73 == count and v65 then
			v65.State = "error"
			render()
		end
	end)

	if not v72 then
		local success, result = pcall(function()
			return require(ReplicatedStorage.Modules.SessionCameraSettings)
		end)

		if success and result and not v64 then
			v64 = true
			result.SetMenuOpen(true)
		end

		parent.Enabled = true
		local success2, result2 = pcall(function()
			local SettingsState = require(ReplicatedStorage.Modules.SettingsState)
			return SettingsState.GetReduceMotionEnabled()
		end)

		if success2 and result2 == true then
			v10.BackgroundTransparency = 0.45
			parent2.Position = UDim2.fromScale(0.5, 0.5)
		else
			v10.BackgroundTransparency = 1
			parent2.Position = UDim2.new(0.5, 0, 0.5, 60)
			TweenService:Create(v10, TweenInfo.new(0.2), { BackgroundTransparency = 0.45 }):Play()
			TweenService:Create(parent2, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(0.5, 0.5)
			}):Play()
		end
	end
end

function ResultHistoryUI.Close()
	if not v63 then
		return
	end

	v63 = false
	count += 1
	local success, result = pcall(function()
		return require(ReplicatedStorage.Modules.SessionCameraSettings)
	end)

	if success and result and v64 then
		v64 = false
		result.SetMenuOpen(false)
	end

	if resultHistoryHiddenChangedConnection then
		resultHistoryHiddenChangedConnection:Disconnect()
		resultHistoryHiddenChangedConnection = nil
	end

	v65 = nil
	local success2, result2 = pcall(function()
		local SettingsState = require(ReplicatedStorage.Modules.SettingsState)
		return SettingsState.GetReduceMotionEnabled()
	end)

	if success2 and result2 == true then
		parent.Enabled = false
		return
	end

	local tween = TweenService:Create(v10, TweenInfo.new(0.16), { BackgroundTransparency = 1 })
	TweenService:Create(parent2, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, 0, 0.5, 40)
	}):Play()
	tween:Play()
	tween.Completed:Once(function()
		if not v63 then
			parent.Enabled = false
		end
	end)
end

local flag4 = false
local v72 = build
build = function()
	v72()

	if flag4 then
		return
	end

	flag4 = true

	v58.MouseButton1Click:Connect(function()
		ResultHistoryUI.Step(-1)
	end)
	v59.MouseButton1Click:Connect(function()
		ResultHistoryUI.Step(1)
	end)
	v60.MouseButton1Click:Connect(onKeepClicked)
	v28.MouseButton1Click:Connect(function()
		if v65 and v65.State == "ready" and v65.Mode ~= "recent" then
			local v73 = v65
			v65.Mode = "recent"
			v73.Index = 1
			flag3 = false
			render()
		end
	end)
	v29.MouseButton1Click:Connect(function()
		if v65 and v65.State == "ready" and v65.Mode ~= "kept" then
			local v73 = v65
			v65.Mode = "kept"
			v73.Index = 1
			flag3 = false
			render()
		end
	end)
	v61.MouseButton1Click:Connect(function()
		ResultHistoryUI.SetView("board")
	end)
	v62.MouseButton1Click:Connect(function()
		local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
		local setResultHistoryHidden = remoteEvents and remoteEvents:FindFirstChild("SetResultHistoryHidden")

		if setResultHistoryHidden then
			setResultHistoryHidden:FireServer(LocalPlayer:GetAttribute("ResultHistoryHidden") ~= true)
		end
	end)
end

return ResultHistoryUI