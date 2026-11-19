local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local RhythmEngineConfig = require(ReplicatedStorage.Modules.RhythmEngineConfig)
local RhythmShapeGeometry = require(ReplicatedStorage.Modules.RhythmShapeGeometry)
local ScreenGlowEffect = require(ReplicatedStorage.Modules.ScreenGlowEffect)
local SettingsState = require(ReplicatedStorage.Modules.SettingsState)
local StarPowerVisualEffects = require(ReplicatedStorage.Modules.StarPowerVisualEffects)
local NewbieModeState = require(ReplicatedStorage.Modules.NewbieModeState)
local CountdownFx = require(ReplicatedStorage.Modules.CountdownFx)

local NoteLaneUI = {}

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local color = Color3.fromRGB(160, 150, 130)
local color2 = Color3.fromRGB(210, 200, 180)
local color3 = Color3.fromRGB(8, 8, 9)
local color4 = Color3.fromRGB(235, 225, 200)

local color5 = Color3.fromRGB(224, 212, 180)

local v2 = {
	Color3.fromRGB(75, 95, 60),
	Color3.fromRGB(120, 40, 35),
	Color3.fromRGB(150, 125, 45),
	Color3.fromRGB(55, 80, 95),
	Color3.fromRGB(150, 85, 30)
}

local v3 = {
	Perfect = Color3.fromRGB(140, 170, 110),
	Great = Color3.fromRGB(90, 130, 155),
	Good = Color3.fromRGB(175, 150, 70),
	OK = Color3.fromRGB(160, 105, 55),
	Miss = Color3.fromRGB(130, 40, 35),
	Wrong = Color3.fromRGB(110, 55, 110)
}

local v4 = {
	GuitarLead = "GUITAR LEAD",
	GuitarRhythm = "GUITAR RHYTHM",
	Bass = "BASS",
	Drum = "DRUM",
	Keyboard = "KEYBOARD",
	Piano = "PIANO"
}
local v5 = v and 36 or 58
local v6 = v and 16 or 8
local trackHeight = v and 360 or 560
local hitLineY = v and 285 or 470
local v7 = v and -90 or -150
local v8 = v and 38 or 52
local v9 = v and 22 or 28
local v10 = v and 6 or 8
local color6 = Color3.fromRGB(255, 255, 255)
local textSize = v and 15 or 22
local textSize2 = v and 8 or 10
local v11 = v and 30 or 46
local v12 = v and 3 or 5
local v13 = v and 9 or 22
local v14 = v and 5 or 9
local v15 = v and 6 or 12
local v16 = v and 10 or 28
local v17 = v and 5 or 8
local v18 = v and 2 or 3
local v19 = {
	HOLD_SIZE = 1.9,
	NOTE_BREAK_GAP = 4,
	STAR_STREAK_RATE = v and 3 or 6,
	FLIES_PER_LANE = v and 3 or 5,
	MAX_FLIES = v and 9 or 22,
	FLY_RATE_MAX = v and 1 or 1.5,
	flyCount = 0,
	flyCore = Color3.fromRGB(255, 242, 168),
	flyHalo = Color3.fromRGB(255, 208, 92),
	bloomColor = Color3.fromRGB(255, 196, 110)
}
local v20 = v and 11 or 24
local v21 = v and 1 / 30 or 0
local color7 = Color3.fromRGB(92, 84, 76)
local color8 = Color3.new(1, 1, 1)
local v22 = { Perfect = 1, Great = 0.8, Good = 0.55, OK = 0.4 }

local v23 = {
	Perfect = 1,
	Great = 0.85,
	Good = 0.6,
	OK = 0.45,
	Wrong = 0.3,
	Miss = 0
}

local function effectiveGemSize() -- 3 equivalent calls inferred from this helper
	return v8 * math.sqrt(SettingsState.GetButtonWidthMultiplier() * SettingsState.GetButtonHeightMultiplier())
end

local function effectiveLaneSpacing() -- 4 equivalent calls inferred from this helper
	return v6 + SettingsState.GetButtonSpacingExtra()
end

function v19.gemDims()
	local buttonWidthMultiplier = SettingsState.GetButtonWidthMultiplier()
	local buttonHeightMultiplier = SettingsState.GetButtonHeightMultiplier()
	local v24 = v and 1.3 or 1
	return
		v8 * buttonWidthMultiplier,
		v8 * buttonHeightMultiplier,
		v9 * buttonWidthMultiplier / v24,
		v9 * buttonHeightMultiplier / v24
end

function v19.laneExtra(p)
	return (math.max(0, p - v5 - 14))
end

function v19.groupOffset()
	return SettingsState.GetButtonGroupOffset()
end

local function effectiveIdleTransparency() -- 2 equivalent calls inferred from this helper
	return 1 - SettingsState.GetButtonOpacity()
end

local function effectiveApproachTime() -- 1 equivalent call inferred from this helper
	local v24 = NewbieModeState.GetNoteSpeedOverride() or SettingsState.GetNoteSpeedMultiplier()
	return RhythmEngineConfig.NoteApproachTime / v24
end

local noteLaneUI = nil
local track = nil
local glowLayer = nil
local v24 = false
local v25 = nil
local v26 = {}
local instrumentNameLabel = nil
local v27 = {}
local v28 = {}
local v29 = {}
local v30 = {}
local v31 = nil
local v32 = nil
local v35 = nil
local activeLaneCount = nil
local v36 = nil
local v37 = {}
local v38 = {}
local receptorPressColorForLanes = {}

local bigJudgmentLabel = nil
local uiScale = nil
local breakCountdownLabel = nil
local breakCountdownCaption = nil
local v39 = nil
local count = 0

local v40 = {}
local v41 = {}

local Debris = game:GetService("Debris")
local v42 = v and 170 or 290
local v43 = v and 6 or 10
local v44 = true
local v45 = {}
local renderSteppedConnection = nil
local v46 = nil
local random = Random.new()

local v47 = 0.9
local v48 = 0
local total = 0.9
local v49 = 1
local total2 = 0
local v50 = {}
local renderSteppedConnection2 = nil
local total3 = 0
local total4 = 0
local v51 = 0
local v52 = 0
local v53 = true
local v54 = nil
local v55 = 1
local v56 = -1000000000
local v57 = -1000000000
local v58 = nil
local v59 = {}
local backgroundColor3 = Color3.fromRGB(255, 244, 214)
local v61 = 1.6
local random2 = Random.new()

local function keyCodeToLabel(p)
	if not p then
		return "?"
	end

	local success, result = pcall(function()
		local ControllerGlyphs = require(script.Parent.ControllerGlyphs)
		return ControllerGlyphs.Label(p)
	end)

	return if success and result then result else p.Name
end

local function getAccentColorForLane(p) -- 7 equivalent calls inferred from this helper
	local v62 = v32 and v32[p]

	if v62 and v62.NoteOuter then
		return v62.NoteOuter
	end

	if v31 and v31[p] then
		return v31[p]
	end

	return v2[(p - 1) % #v2 + 1]
end

local function getNoteInnerColorForLane(lane) -- 2 equivalent calls inferred from this helper
	local v62 = v32 and v32[lane]
	return v62 and v62.NoteInner or nil
end

local function getReceptorRingColorForLane(i) -- 2 equivalent calls inferred from this helper
	local v62 = v32 and v32[i]

	if v62 and v62.ReceptorRing then
		return v62.ReceptorRing
	end

	return getAccentColorForLane(i) -- inferred equivalent call
end

local function getReceptorPressColorForLane(i) -- 2 equivalent calls inferred from this helper
	local v62 = v32 and v32[i]

	if v62 and v62.ReceptorPress then
		return v62.ReceptorPress
	end

	return getAccentColorForLane(i) -- inferred equivalent call
end

local function getJudgmentColor(value) -- 3 equivalent calls inferred from this helper
	return SettingsState.GetRhythmJudgmentColor(value) or v3[value]
end

local function repaintGemVisual(gem, p, backgroundColor, backgroundColor2, value, p2)
	if not gem then
		return
	end

	gem.BackgroundColor3 = backgroundColor
	RhythmShapeGeometry.Apply(gem, value or "Diamond", p, p2)

	local innerGem = gem:FindFirstChild("InnerGem")

	if backgroundColor2 then
		if not innerGem then
			innerGem = Instance.new("Frame")
			innerGem.Name = "InnerGem"
			innerGem.AnchorPoint = Vector2.new(0.5, 0.5)
			innerGem.Position = UDim2.new(0.5, 0, 0.5, 0)
			innerGem.Size = UDim2.new(0.5, 0, 0.5, 0)
			innerGem.BorderSizePixel = 0
			innerGem.Parent = gem
		end

		innerGem.ZIndex = gem.ZIndex + 1
		innerGem.BackgroundColor3 = backgroundColor2

		local uiCorner = gem:FindFirstChildOfClass("UICorner")
		local v62 = innerGem:FindFirstChildOfClass("UICorner")

		if not v62 then
			v62 = Instance.new("UICorner")
			v62.Parent = innerGem
		end

		v62.CornerRadius = uiCorner and uiCorner.CornerRadius or UDim.new(0, 4)
	elseif innerGem then
		innerGem:Destroy()
	end
end

local function makeGem(parent, p, backgroundColor, backgroundColor2, p2, zIndex, p3)
	local gem = Instance.new("Frame")
	gem.Name = "Gem"
	gem.AnchorPoint = Vector2.new(0.5, 0.5)
	gem.Position = UDim2.new(0.5, 0, 0.5, 0)
	gem.BorderSizePixel = 0
	gem.ZIndex = zIndex
	gem.Parent = parent

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color3
	uiStroke.Thickness = 2
	uiStroke.Transparency = 0.2
	uiStroke.Parent = gem

	repaintGemVisual(gem, p, backgroundColor, backgroundColor2, p2, p3)

	return gem
end

local function auraSmooth(value) -- 3 equivalent calls inferred from this helper
	local v62 = math.clamp(value, 0, 1)
	return v62 * v62 * (3 - 2 * v62)
end

function v19:noteFadeSet(p)
	local gem = self.Gem

	if not gem then
		return
	end

	local fadeList = self.FadeList

	if not fadeList then
		fadeList = {}
		fadeList[1] = { gem, "BackgroundTransparency", gem.BackgroundTransparency }

		for _, descendant in ipairs(gem:GetDescendants()) do
			if descendant:IsA("UIStroke") then
				fadeList[#fadeList + 1] = { descendant, "Transparency", descendant.Transparency }
			elseif descendant:IsA("GuiObject") then
				fadeList[#fadeList + 1] = { descendant, "BackgroundTransparency", descendant.BackgroundTransparency }

				if descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
					fadeList[#fadeList + 1] = { descendant, "ImageTransparency", descendant.ImageTransparency }
				elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
					fadeList[#fadeList + 1] = { descendant, "TextTransparency", descendant.TextTransparency }
				end
			end
		end

		self.FadeList = fadeList
	end

	for _, v63 in ipairs(fadeList) do
		local v64 = v63[1]

		if v64.Parent then
			v64[v63[2]] = 1 - (1 - v63[3]) * p
		end
	end
end

function v19.starCap(p)
	return (math.floor(p * (total2 * 0.7 + 1) + 0.5))
end

function v19.rock()
	if v19._rock ~= nil then
		return v19._rock or nil
	end

	local success, result = pcall(function()
		return require(script.Parent:WaitForChild("RockMeterUI", 5))
	end)

	v19._rock = success and result or false

	if not success then
		warn("[NoteLaneUI] RockMeterUI gagal dimuat:", result)
	end

	return v19._rock or nil
end

function v19.scoreUI()
	if v19._scoreUI ~= nil then
		return v19._scoreUI or nil
	end

	local success, result = pcall(function()
		return require(script.Parent:WaitForChild("ScoreDisplayUI", 5))
	end)

	v19._scoreUI = success and result or false

	if not success then
		warn("[NoteLaneUI] ScoreDisplayUI gagal dimuat:", result)
	end

	return v19._scoreUI or nil
end

function v19.applySkinShape(instance, instance2, p)
	local visible = p == "Circle"
	local skin = instance and instance:FindFirstChild("Skin")

	if skin then
		skin.Visible = visible
	end

	if instance2 then
		local skinShade = instance2:FindFirstChild("SkinShade")

		if skinShade then
			skinShade.Visible = visible
		end

		local skinBevel = instance2:FindFirstChild("SkinBevel")

		if skinBevel then
			skinBevel.Visible = visible
		end
	end
end

function v19.buildReceptorSkin(instance, parent, p, p2, p3)
	local skin = instance:FindFirstChild("Skin")

	if skin then
		skin:Destroy()
	end

	for _, childName in ipairs({ "SkinShade", "SkinBevel" }) do
		local child = parent:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end

	local random3 = Random.new(p2 * 131 + 17)
	local v62 = p / 2
	local function polar(p4, p5) -- 3 equivalent calls inferred from this helper
		return UDim2.new(0.5, math.cos(p4) * p5, 0.5, math.sin(p4) * p5)
	end

	local color9 = Color3.fromRGB(14, 12, 10)
	local color10 = Color3.fromRGB(104, 58, 34)

	local skinShade = Instance.new("Frame")
	skinShade.Name = "SkinShade"
	skinShade.AnchorPoint = Vector2.new(0.5, 0.5)
	skinShade.Position = UDim2.new(0.5, 0, 0.5, 0)
	skinShade.Size = UDim2.new(1, 0, 1, 0)
	skinShade.BackgroundTransparency = 1
	skinShade.BorderSizePixel = 0
	skinShade.ZIndex = parent.ZIndex
	skinShade.Parent = parent

	for i = 1, 4 do
		local grime = Instance.new("Frame")
		grime.Name = "Grime"
		grime.AnchorPoint = Vector2.new(0.5, 0.5)
		local integer = random3:NextInteger(2, (math.max(3, (math.floor(p * 0.12)))))
		grime.Size = UDim2.fromOffset(integer, integer)
		grime.Position = polar(random3:NextNumber(0, 6.283185307179586), random3:NextNumber(0.1, 0.8) * v62) -- inferred equivalent call
		grime.BackgroundColor3 = i % 3 == 0 and color10 or color9
		grime.BackgroundTransparency = random3:NextNumber(0.55, 0.82)
		grime.BorderSizePixel = 0
		grime.ZIndex = parent.ZIndex
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = grime
		grime.Parent = skinShade
	end

	for _ = 1, 1 do
		local smudge = Instance.new("Frame")
		smudge.Name = "Smudge"
		smudge.AnchorPoint = Vector2.new(0.5, 0.5)
		smudge.Size = UDim2.fromOffset(random3:NextInteger(8, 14), random3:NextInteger(3, 5))
		smudge.Position = polar(random3:NextNumber(0, 6.283185307179586), random3:NextNumber(0.25, 0.7) * v62) -- inferred equivalent call
		smudge.Rotation = random3:NextInteger(0, 180)
		smudge.BackgroundColor3 = color9
		smudge.BackgroundTransparency = random3:NextNumber(0.78, 0.9)
		smudge.BorderSizePixel = 0
		smudge.ZIndex = parent.ZIndex
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = smudge
		smudge.Parent = skinShade
	end

	for _ = 1, 1 do
		local scratch = Instance.new("Frame")
		scratch.Name = "Scratch"
		scratch.AnchorPoint = Vector2.new(0.5, 0.5)
		scratch.Size = UDim2.fromOffset(random3:NextInteger(6, 11), 1)
		scratch.Position = polar(random3:NextNumber(0, 6.283185307179586), random3:NextNumber(0.2, 0.7) * v62) -- inferred equivalent call
		scratch.Rotation = random3:NextInteger(0, 180)
		scratch.BackgroundColor3 = Color3.fromRGB(222, 220, 214)
		scratch.BackgroundTransparency = random3:NextNumber(0.68, 0.85)
		scratch.BorderSizePixel = 0
		scratch.ZIndex = parent.ZIndex
		scratch.Parent = skinShade
	end

	v19.applySkinShape(instance, parent, p3)
end

local function auraCircle(keyAura, name, zIndex)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.Size = UDim2.fromOffset(4, 4)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ZIndex = zIndex
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = frame
	frame.Parent = keyAura
	return frame
end

local function auraLine(keySwordFx, name, zIndex, p) -- 3 equivalent calls inferred from this helper
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ZIndex = zIndex
	frame.Visible = false

	if p then
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = frame
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.35, 0.35),
			NumberSequenceKeypoint.new(1, 0)
		})

		uiGradient.Parent = frame
	end

	frame.Parent = keySwordFx
	return frame
end

local function buildKeyAura(i, hitContainer, gem)
	local keyAura = Instance.new("Frame")
	keyAura.Name = "KeyAura"
	keyAura.AnchorPoint = Vector2.new(0.5, 0.5)
	keyAura.Position = UDim2.new(0.5, 0, 0.5, 0)
	keyAura.Size = UDim2.new(1, 0, 1, 0)
	keyAura.BackgroundTransparency = 1
	keyAura.BorderSizePixel = 0
	keyAura.ZIndex = 1
	keyAura.Parent = hitContainer

	local keySwordFx = Instance.new("Frame")
	keySwordFx.Name = "KeySwordFx"
	keySwordFx.AnchorPoint = Vector2.new(0.5, 0.5)
	keySwordFx.Position = UDim2.new(0.5, 0, 0.5, 0)
	keySwordFx.Size = UDim2.new(1, 0, 1, 0)
	keySwordFx.BackgroundTransparency = 1
	keySwordFx.BorderSizePixel = 0
	keySwordFx.ZIndex = 4
	keySwordFx.Parent = hitContainer

	local v62 = v38[i] or getAccentColorForLane(i) -- inferred equivalent call
	local keyAura2 = {
		Root = keyAura,
		Fx = keySwordFx,
		Gem = gem,
		Phase = random2:NextNumber(0, 6.283185307179586),
		Press = 0,
		Dip = 0,
		Hold = 0,
		HoldAcc = 0,
		BoltT = 0,
		StarAcc = 0,
		StarBoltT = random2:NextNumber(0.2, 1),
		FlyAcc = random2:NextNumber(),
		BloomT = 1,
		BloomPower = 0,
		SparkAcc = random2:NextNumber(),
		Tick = 0,
		GlowColor = v62:Lerp(color8, 0.2),
		CoreColor = v62:Lerp(color8, 0.5),
		Sparks = {},
		Streaks = {},
		Bolts = {},
		Flies = {}
	}

	for j = 1, v12 do
		local parent = auraCircle(keyAura, "AuraSpark", 4)
		parent.Visible = false
		keyAura2.Sparks[j] = {
			F = parent,
			Alive = false,
			Age = 0,
			Max = 1,
			X0 = 0,
			Y0 = 0,
			Rise = 0,
			Drift = 0,
			Ph = 0
		}
	end

	for j = 1, v15 do
		keyAura2.Streaks[j] = {
			F = auraLine(keySwordFx, "SwordSpark", 1, true),
			Alive = false,
			Age = 0,
			Max = 0.3,
			X = 0,
			Y = 0,
			VX = 0,
			VY = 0,
			Len = 10,
			Thick = 2
		}
	end

	for j = 1, v18 do
		local segs = {
			auraLine(keySwordFx, "BoltSeg", 2), -- inferred equivalent call
			auraLine(keySwordFx, "BoltSeg", 2), -- inferred equivalent call
			(auraLine(keySwordFx, "BoltSeg", 2)) -- inferred equivalent call
		}

		keyAura2.Bolts[j] = { Segs = segs, Alive = false, Age = 0, Max = 0.16 }
	end

	for j = 1, v19.FLIES_PER_LANE do
		local core = auraCircle(keyAura, "Firefly", 2)
		core.Visible = false
		keyAura2.Flies[j] = {
			Core = core,
			Alive = false,
			Age = 0,
			Max = 3,
			X0 = 0,
			Y0 = 0,
			Rise = 0,
			Drift = 0,
			Ph = 0,
			Blink = 1,
			Size = 4
		}
	end

	v50[i] = keyAura2
	return keyAura2
end

local function auraEmit(data, p)
	if v51 >= v19.starCap(v13) then
		return
	end

	for _, spark in ipairs(data.Sparks) do
		if not spark.Alive then
			local gem = data.Gem
			local hold = data.Hold
			local v62 = total2
			spark.Alive = true
			spark.Age = 0
			spark.Max = (v49 * 0.5 + 0.45) * (0.8 + 0.4 * random2:NextNumber()) * (1 + 0.5 * hold)
			spark.X0 = random2:NextNumber(-0.42, 0.42) * gem
			spark.Y0 = -gem * 0.6
			spark.Rise = gem * (v49 * 0.95 + 0.45) * (0.7 + 0.6 * random2:NextNumber()) * (p and 1.15 or 1) * (1 + 1.8 * hold) * (v62 * 0.35 + 1)
			spark.Rise = math.min(spark.Rise, hitLineY * 0.55)
			spark.Drift = random2:NextNumber(-0.18, 0.18) * gem
			spark.Ph = random2:NextNumber(0, 6.283185307179586)
			local v63 = (v and 2.5 or 3.5) * (0.7 + 0.8 * random2:NextNumber()) * (v49 * 0.45 + 0.55) * (v62 * 0.4 + 1)
			spark.F.Size = UDim2.fromOffset(v63, v63)
			spark.F.BackgroundColor3 = data.CoreColor
			spark.F.BackgroundTransparency = 0.1
			spark.F.Visible = true
			v51 += 1
			break
		end
	end
end

local function auraEmitStreak(p, p2, p3, p4, value)
	if v52 >= v19.starCap(v16) then
		return
	end

	local v62 = total2
	local v63 = value or 1

	for _, streak in ipairs(p.Streaks) do
		if not streak.Alive then
			local gem = p.Gem
			local v64 = p2 + random2:NextNumber(-p3, p3)
			local v65 = gem * random2:NextNumber(3.2, 6.2) * (0.6 + 0.4 * p4) * (1 + 0.25 * (v63 - 1)) * (v62 * 0.3 + 1)
			streak.Alive = true
			streak.Age = 0
			streak.Max = random2:NextNumber(0.2, 0.38) * (1 + 0.3 * (v63 - 1))
			streak.VX = math.cos(v64) * v65
			streak.VY = math.sin(v64) * v65
			streak.X = random2:NextNumber(-0.15, 0.15) * gem
			streak.Y = gem * 0.05
			streak.Len = gem * random2:NextNumber(0.22, 0.5) * (0.6 + 0.4 * p4) * v63 * (v62 * 0.5 + 1)
			streak.Thick = (v and 1.6 or 2.2) * v63 ^ 0.7 * (v62 * 0.4 + 1)
			streak.F.Size = UDim2.fromOffset(streak.Len, streak.Thick)
			streak.F.Position = UDim2.new(0.5, streak.X, 0.5, streak.Y)
			streak.F.Rotation = math.deg(v64)
			streak.F.BackgroundColor3 = backgroundColor3
			streak.F.BackgroundTransparency = 0
			streak.F.Visible = true
			v52 += 1
			break
		end
	end
end

local function auraBolt(p, p2, value)
	local v62 = total2
	local v63 = value or 1

	for _, bolt in ipairs(p.Bolts) do
		if not bolt.Alive then
			local gem = p.Gem
			local v64 = -1.5707963267948966 + random2:NextNumber(-0.9, 0.9)
			local v65 = gem * random2:NextNumber(0.9, 1.5) * (0.6 + 0.4 * p2) * v63 * (v62 * 0.4 + 1)
			local v66 = math.cos(v64)
			local v67 = math.sin(v64)
			local v68 = -v67
			local v69 = random2:NextNumber(-0.2, 0.2) * gem
			local v70 = -gem * 0.25
			local v72 = {
				{ v69, v70 }
			}

			for i = 1, 3 do
				local v73 = i / 3
				local v74 = i < 3 and random2:NextNumber(-0.22, 0.22) * gem * v63 or 0
				v72[#v72 + 1] = { v69 + v66 * v65 * v73 + v68 * v74, v70 + v67 * v65 * v73 + v66 * v74 }
			end

			local lerped = backgroundColor3:Lerp(color8, 0.5)
			local v73 = (v and 2 or 2.5) * v63 ^ 0.6 * (v62 * 0.3 + 1)

			for i = 1, 3 do
				local v74 = v72[i]
				local v75 = v72[i + 1]
				local v76 = v75[1] - v74[1]
				local v77 = v75[2] - v74[2]
				local seg = bolt.Segs[i]
				seg.Position = UDim2.new(0.5, (v74[1] + v75[1]) / 2, 0.5, (v74[2] + v75[2]) / 2)
				seg.Size = UDim2.fromOffset(math.sqrt(v76 * v76 + v77 * v77) + 1, v73)
				seg.Rotation = math.deg((math.atan2(v77, v76)))
				seg.BackgroundColor3 = lerped
				seg.BackgroundTransparency = 0
				seg.Visible = true
			end

			bolt.Alive = true
			bolt.Age = 0
			bolt.Max = (v62 * 0.3 + 1) * 0.16
			break
		end
	end
end

function v19.emitFly(data)
	if v19.flyCount >= v19.starCap(v19.MAX_FLIES) then
		return
	end

	for _, v62 in ipairs(data.Flies) do
		if not v62.Alive then
			local gem = data.Gem
			local hold = data.Hold
			local v63 = total2
			v62.Alive = true
			v62.Age = 0
			v62.Max = (2.6 + 1.6 * random2:NextNumber()) * (v49 * 0.25 + 0.75) * (1 + 0.4 * hold)
			v62.X0 = random2:NextNumber(-0.5, 0.5) * gem
			v62.Y0 = -gem * 0.6
			v62.Rise = gem * (v49 * 0.7 + 0.55) * (0.7 + 0.6 * random2:NextNumber()) * (1 + 1.6 * hold) * (v63 * 0.3 + 1)
			v62.Rise = math.min(v62.Rise, hitLineY * 0.6)
			v62.Drift = random2:NextNumber(0.18, 0.4) * gem
			v62.Ph = random2:NextNumber(0, 6.283185307179586)
			v62.Blink = random2:NextNumber(0.9, 1.8)
			local size = (v and 3 or 4) * (0.8 + 0.5 * random2:NextNumber()) * (v49 * 0.35 + 0.65) * (v63 * 0.35 + 1)
			v62.Size = size
			v62.Core.Size = UDim2.fromOffset(size, size)
			v62.Core.BackgroundColor3 = v19.flyCore
			v62.Core.BackgroundTransparency = 1
			v62.Core.Visible = true
			v19.flyCount += 1
			break
		end
	end
end

function v19.bloom(_, _) end

local function feedPerformance(value, p, p2) -- 1 equivalent call inferred from this helper
	local v62 = p and 1 or v23[value]

	if v62 == nil then
		return
	end

	local v63 = v47 < v62 and 0.35 or 0.13
	v47 = math.clamp(v47 + (v62 - v47) * v63, 0, 1)

	if value == "Miss" then
		v48 = 0
	elseif value ~= "Wrong" then
		v48 = p2 or v48 + 1
	end
end

local function resetPerformanceForm() -- 2 equivalent calls inferred from this helper
	v47 = 0.9
	v48 = 0
	total = 0.9
	v49 = 1
	total2 = 0
end

local function auraPulse(p, value, p2)
	local v62 = v50[p]

	if not v62 or p2 then
		return
	end

	if value == "Miss" then
		v62.Dip = 1
		return
	elseif value == "Wrong" then
		v62.Dip = math.max(v62.Dip, 0.5)
		return
	end

	local v63 = v22[value] or 0.45
	local v64 = v49 * 0.65 + 0.35
	local v65 = total2

	if v53 then
		for _ = 1, math.floor((v63 >= 0.8 and 3 or 2) * (v49 * 0.6 + 0.4) * (v65 * 0.5 + 1) + 0.5) do
			auraEmit(v62, true)
		end

		for _ = 1, math.floor(v17 * (v63 >= 0.8 and 1 or 0.6) * (v49 * 0.85 + 0.15) * (v65 * 1.2 + 1) + 0.5) do
			auraEmitStreak(v62, -1.5707963267948966, 1.7, v63 * v64, v65 * 0.4 + 1)
		end

		if v63 >= 0.55 and v49 > 0.2 then
			auraBolt(v62, v63 * v64, v65 * 0.4 + 1)

			if v65 > 0.5 then
				auraBolt(v62, v63 * v64, 1.2)
			end
		end
	else
		for _ = 1, math.floor((v63 >= 0.8 and 3 or 2) * (v49 * 0.6 + 0.4) * (v65 + 1) + 0.5) do
			v19.emitFly(v62)
		end

		v19.bloom(v62, v63 * v64)
	end
end

local function stepAura(p)
	local v62 = v44

	if not v62 then
		for _, v64 in pairs(v45) do
			if v64.Group.Visible then
				v62 = true
				break
			end
		end
	end

	if not v62 then
		return
	end

	total3 += p

	if total3 < v21 then
		return
	end

	local v63 = math.min(total3, 0.1)
	total3 = 0
	total4 += v63

	local v64 = math.min(1, v47 + math.min(v48 / 30, 1) * 0.12)

	if v24 then
		v64 = math.max(v64, 0.8)
	end

	local v65 = total < v64 and 6 or 0.8
	total += (v64 - total) * (1 - math.exp(-v65 * v63))
	total2 += ((v24 and 1 or 0) - total2) * (1 - math.exp(-5 * v63))
	local v66 = total2

	local v67 = auraSmooth((total - 0.15) / 0.7) -- inferred equivalent call
	v49 = v67
	local v68 = math.clamp((0.75 - total) / 0.75, 0, 1) * 0.85 * (1 - v66)
	local v69 = (0.3 + (v14 - 0.3) * v67 ^ 1.5) * (v54 and 0.35 or 1)
	local v70 = (0.4 + (v19.FLY_RATE_MAX - 0.4) * v67 ^ 1.3) * (v54 and 0.6 or 1)

	local v71 = false
	local v72

	if v54 and v58 then
		local v73 = v58
		local count2 = #v54

		if v55 > 1 then
			local v74 = v54[v55 - 1]

			if v73 + 0.05 < v74 then
				local v75 = count2 + 1
				local v76 = 1

				while v76 < v75 do
					local v77 = (v76 + v75) // 2

					if v54[v77] <= v73 then
						v76 = v77 + 1
					else
						v75 = v77
					end
				end

				v55 = v76
				v56 = v76 > 1 and v54[v76 - 1] or -1000000000
			end
		end

		while v55 <= count2 and v54[v55] <= v73 do
			local v74 = v54[v55]
			v55 += 1

			if v73 - v74 < 0.12 and v74 - v57 >= 0.09 then
				v57 = v74
				v71 = true
			end

			v56 = v74
		end

		v72 = math.exp(-math.max(0, v73 - v56) * 7)
	else
		v72 = 0
	end

	local v73 = Color3.fromRGB(255, 244, 214)
	local color9 = Color3.fromRGB(255, 150, 40)
	local color10 = Color3.fromRGB(255, 242, 168)
	local color11 = Color3.fromRGB(255, 208, 92)
	local color12 = Color3.fromRGB(255, 196, 110)

	if v66 > 0.01 then
		local ENERGY_COLOR = StarPowerVisualEffects.ENERGY_COLOR
		v73 = v73:Lerp(ENERGY_COLOR, v66 * 0.7):Lerp(color8, v66 * 0.3)
		color9 = color9:Lerp(ENERGY_COLOR, v66 * 0.8)
		color10 = color10:Lerp(ENERGY_COLOR, v66 * 0.55)
		color11 = color11:Lerp(ENERGY_COLOR, v66 * 0.7)
		color12 = color12:Lerp(ENERGY_COLOR, v66 * 0.6)
	end

	local lerped = v73:Lerp(color7, v68)
	local lerped2 = color9:Lerp(color7, v68)
	backgroundColor3 = lerped
	v19.flyCore = color10:Lerp(color7, v68)
	v19.flyHalo = color11:Lerp(color7, v68)
	v19.bloomColor = color12:Lerp(color7, v68)

	for k, v74 in pairs(v50) do
		if v74.Root.Parent then
			v74.Tick += 1
			local gem = v74.Gem
			local v75 = v72 * gem * 0.2 * (0.35 + 0.65 * v67)
			v74.Press += ((v37[k] and 1 or 0) - v74.Press) * (1 - math.exp(-14 * v63))
			v74.Dip = math.max(0, v74.Dip - v63 * 2.2)

			if v59[k] then
				v74.Hold = math.min(1, v74.Hold + v63 * 0.9)
			else
				v74.Hold = math.max(0, v74.Hold - v63 * 4)
			end

			if v71 and v67 > 0.1 then
				if v53 then
					auraEmit(v74, false)

					if v66 > 0.3 then
						auraEmitStreak(v74, -1.5707963267948966, 1.5, 0.6, 1.2)
						auraEmitStreak(v74, -1.5707963267948966, 1.5, 0.6, 1.2)

						if random2:NextNumber() < 0.3 then
							auraBolt(v74, 0.7, 1.1)
						end
					end
				elseif random2:NextNumber() < 0.5 then
					v19.emitFly(v74)
				end
			end

			if v59[k] and v67 > 0.05 then
				if v53 then
					v74.HoldAcc = math.min(v74.HoldAcc + v20 * (0.2 + 0.8 * v67) * (v66 * 0.6 + 1) * v63, 4)

					while v74.HoldAcc >= 1 do
						v74.HoldAcc -= 1
						auraEmitStreak(v74, -1.5707963267948966, 1.3, 0.75 * (0.35 + 0.65 * v67), v19.HOLD_SIZE)
					end

					v74.BoltT -= v63

					if v74.BoltT <= 0 then
						auraBolt(v74, 0.8 * (0.35 + 0.65 * v67), 1.5)
						v74.BoltT = random2:NextNumber(0.14, 0.3) / ((0.5 + 0.5 * v67) * (v66 * 0.6 + 1))
					end
				else
					v74.BoltT -= v63

					if v74.BoltT <= 0 then
						v19.bloom(v74, 0.55 * (0.35 + 0.65 * v67))
						v74.BoltT = 0.7
					end
				end
			else
				v74.HoldAcc = 0
				v74.BoltT = 0
			end

			if v66 > 0.3 and v67 > 0.1 then
				v74.StarBoltT -= v63

				if v53 then
					v74.StarAcc = math.min(v74.StarAcc + v19.STAR_STREAK_RATE * v66 * v63, 3)

					while v74.StarAcc >= 1 do
						v74.StarAcc -= 1
						auraEmitStreak(v74, -1.5707963267948966, 1.7, 0.6, 1.2)
					end

					if v74.StarBoltT <= 0 then
						auraBolt(v74, 0.7, 1)
						v74.StarBoltT = random2:NextNumber(0.5, 1.2)
					end
				elseif v74.StarBoltT <= 0 then
					v19.bloom(v74, 0.6)
					v74.StarBoltT = random2:NextNumber(1, 1.8)
				end
			end

			if v74.Tick <= 2 or v74.Tick % 3 == 0 then
				local lerped3 = (v38[k] or getAccentColorForLane(k)):Lerp(color8, 0.2) -- inferred equivalent call

				if v66 > 0.01 then
					lerped3 = lerped3:Lerp(StarPowerVisualEffects.ENERGY_COLOR, v66 * 0.75)
				end

				local lerped4 = lerped3:Lerp(color7, v68)
				v74.GlowColor = lerped4
				v74.CoreColor = lerped4:Lerp(color8, (1 - v68) * 0.45)
			end

			if v53 then
				local v76 = v69 * (1 + 0.8 * v74.Press) * (v66 * 1.2 + 1) * (1 - 0.8 * v74.Dip) * (1 + 1 * v74.Hold)
				v74.SparkAcc = math.min(v74.SparkAcc + v76 * v63, 3)

				while v74.SparkAcc >= 1 do
					v74.SparkAcc -= 1
					auraEmit(v74, false)
				end
			else
				local v76 = v70 * (1 + 0.8 * v74.Press) * (v66 * 1.2 + 1) * (1 - 0.8 * v74.Dip) * (1 + 1.2 * v74.Hold)
				v74.FlyAcc = math.min(v74.FlyAcc + v76 * v63, 3)

				while v74.FlyAcc >= 1 do
					v74.FlyAcc -= 1
					v19.emitFly(v74)
				end
			end

			for _, spark in ipairs(v74.Sparks) do
				if not spark.Alive then
					continue
				end

				spark.Age += v63
				local v76 = spark.Age / spark.Max

				if v76 >= 1 then
					spark.Alive = false
					spark.F.Visible = false
					v51 = math.max(0, v51 - 1)
				else
					local v77 = 1 - (1 - v76) * (1 - v76)
					spark.F.Position = UDim2.new(
						0.5,
						spark.X0 + math.sin(v76 * 5 + spark.Ph) * spark.Drift,
						0.5,
						spark.Y0 - spark.Rise * v77 - v75
					)
					local v78 = 0.08 + 0.92 * v76 * v76
					spark.F.BackgroundTransparency = 1 - (1 - v78) * (0.4 + 0.6 * v67)
				end
			end

			for _, streak in ipairs(v74.Streaks) do
				if not streak.Alive then
					continue
				end

				streak.Age += v63
				local v76 = streak.Age / streak.Max

				if v76 >= 1 then
					streak.Alive = false
					streak.F.Visible = false
					v52 = math.max(0, v52 - 1)
				else
					streak.VY += gem * 10 * v63
					local v77 = math.exp(-1.6 * v63)
					streak.VX *= v77
					streak.VY *= v77
					streak.X += streak.VX * v63
					streak.Y += streak.VY * v63
					local f = streak.F
					f.Position = UDim2.new(0.5, streak.X, 0.5, streak.Y)
					f.Rotation = math.deg((math.atan2(streak.VY, streak.VX)))
					f.Size = UDim2.fromOffset(streak.Len * (1 - 0.55 * v76), streak.Thick)
					f.BackgroundColor3 = lerped:Lerp(lerped2, v76)
					f.BackgroundTransparency = 1 - (1 - (v76 < 0.35 and 0 or ((v76 - 0.35) / 0.65) ^ 1.5)) * (0.3 + 0.7 * v67)
				end
			end

			for _, bolt in ipairs(v74.Bolts) do
				if not bolt.Alive then
					continue
				end

				bolt.Age += v63
				local v76 = bolt.Age / bolt.Max

				if v76 >= 1 then
					bolt.Alive = false

					for _, seg in ipairs(bolt.Segs) do
						seg.Visible = false
					end
				else
					local v77 = v76 ^ 1.3

					if total4 * 40 % 2 < 1 then
						v77 = math.min(1, v77 + 0.25)
					end

					local backgroundTransparency = 1 - (1 - v77) * (0.3 + 0.7 * v67)

					for _, seg in ipairs(bolt.Segs) do
						seg.BackgroundTransparency = backgroundTransparency
					end
				end
			end

			for _, v76 in ipairs(v74.Flies) do
				if not v76.Alive then
					continue
				end

				v76.Age += v63
				local v77 = v76.Age / v76.Max

				if v77 >= 1 then
					v76.Alive = false
					v76.Core.Visible = false
					v19.flyCount = math.max(0, v19.flyCount - 1)
				else
					local ph = v76.Ph
					local v78 = v76.X0 + (math.sin(v77 * 2.1 * 3.141592653589793 + ph) * 0.6 + math.sin(v77 * 3.7 * 3.141592653589793 + ph * 1.7) * 0.4) * v76.Drift
					local v79 = v76.Y0 - v76.Rise * v77 + math.sin(v77 * 5 + ph) * gem * 0.04 - v75 * 0.25
					v76.Core.Position = UDim2.new(0.5, v78, 0.5, v79)
					local v80 = math.sin(total4 * v76.Blink * 3.141592653589793 + ph) * 0.3 + 0.7
					local v81 = auraSmooth(v77 / 0.25) * auraSmooth((1 - v77) / 0.3) * v80 * (0.4 + 0.6 * v67) * (v72 * 0.3 + 1) -- inferred equivalent call
					v76.Core.BackgroundTransparency = 1 - math.clamp(v81, 0, 1) * 0.8
					local v82 = v76.Size * (math.sin(total4 * 1.3 + ph) * 0.15 + 0.9)
					v76.Core.Size = UDim2.fromOffset(v82, v82)
				end
			end

			if v74.BloomT < 1 then
				v74.BloomT = math.min(1, v74.BloomT + v63 / 0.6)
				local bloomT = v74.BloomT
				local v76 = gem * (1.2 + 1 * bloomT)
				v74.Bloom.Size = UDim2.fromOffset(v76, v76)

				if bloomT >= 1 then
					v74.Bloom.Visible = false
				else
					v74.Bloom.BackgroundTransparency = 1 - (1 - bloomT) * (1 - bloomT) * 0.22 * v74.BloomPower * (v66 * 0.8 + 1)
				end
			end
		else
			v50[k] = nil
		end
	end
end

local function startAuraDriver() -- 1 equivalent call inferred from this helper
	if not renderSteppedConnection2 then
		total3 = 0
		local RunService = game:GetService("RunService")
		renderSteppedConnection2 = RunService.RenderStepped:Connect(stepAura)
	end
end

local function clearTrack()
	for _, v62 in pairs(v30) do
		if v62.Gem then
			v62.Gem:Destroy()
		end

		if v62.HoldBar then
			v62.HoldBar:Destroy()
		end

		local RhythmVibratoWave2D = require(ReplicatedStorage.Modules.RhythmVibratoWave2D)
		RhythmVibratoWave2D.Destroy(v62)
	end

	v30 = {}

	for _, v62 in pairs(v27) do
		v62:Destroy()
	end

	v27 = {}

	for _, v62 in pairs(v28) do
		v62:Destroy()
	end

	v28 = {}
	v29 = {}

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	for _, v62 in pairs(v45) do
		if v62.Group then
			v62.Group:Destroy()
		end
	end

	v45 = {}

	if v46 then
		v46:Destroy()
		v46 = nil
	end

	if renderSteppedConnection2 then
		renderSteppedConnection2:Disconnect()
		renderSteppedConnection2 = nil
	end

	v50 = {}
	v51 = 0
	v52 = 0
	v19.flyCount = 0
	v59 = {}
	total3 = 0

	if NoteLaneUI._streakFx then
		NoteLaneUI._streakFx:Reset()
	end

	v44 = true
end

local function refreshRhythmCustomization()
	if not activeLaneCount then
		return
	end

	v32 = SettingsState.GetRhythmLaneColors(activeLaneCount)
	v35 = SettingsState.GetRhythmShape()

	for i = 1, activeLaneCount do
		local backgroundColor = getReceptorRingColorForLane(i) -- inferred equivalent call
		local receptorPressColorForLane = getReceptorPressColorForLane(i) -- inferred equivalent call
		v38[i] = backgroundColor
		receptorPressColorForLanes[i] = receptorPressColorForLane
		v26[i] = backgroundColor

		if v24 or not v36 then
			continue
		end

		local v63 = v28[i]
		local gem = v63 and v63:FindFirstChild("Gem")

		if not gem then
			continue
		end

		backgroundColor = v37[i] and receptorPressColorForLane or backgroundColor
		local activeW = v19.activeW or v36
		local v64 = v35
		local activeH = v19.activeH or v36

		if gem then
			gem.BackgroundColor3 = backgroundColor
			RhythmShapeGeometry.Apply(gem, v64 or "Diamond", activeW, activeH)

			local innerGem = gem:FindFirstChild("InnerGem")

			if innerGem then
				innerGem:Destroy()
			end
		end

		v19.applySkinShape(v63, gem, v35)
	end

	for k, v62 in pairs(v30) do
		if not k.Lane then
			continue
		end

		local accentColorForLane = getAccentColorForLane(k.Lane) -- inferred equivalent call
		local noteInnerColorForLane = getNoteInnerColorForLane(k.Lane) -- inferred equivalent call
		v62.OriginalAccentColor = accentColorForLane

		if v24 or not v62.Gem then
			continue
		end

		v62.AccentColor = accentColorForLane
		repaintGemVisual(v62.Gem, v19.noteW or v9, accentColorForLane, noteInnerColorForLane, v35, v19.noteH or v9)
	end
end

SettingsState.OnChanged(refreshRhythmCustomization)

function NoteLaneUI.GetTrackWidth(value)
	local v62 = value or 5

	local gemDims = v19.gemDims()
	local v63 = effectiveLaneSpacing() + v19.laneExtra(gemDims) -- inferred equivalent call
	return v62 * v5 + (v62 - 1) * v63
end

function NoteLaneUI.GetTrackHeight()
	return trackHeight
end

function NoteLaneUI.SetScoreState(p, p2)
	local scoreUI = v19.scoreUI()

	if scoreUI then
		scoreUI.SetState(p, p2)
	end
end

function NoteLaneUI.GetTrackFrame()
	return track
end

function NoteLaneUI.GetLaneRailXOffset(p)
	local v62 = v5
	local gemDims = v19.gemDims()
	local v63 = effectiveLaneSpacing() + v19.laneExtra(gemDims) -- inferred equivalent call
	return (p - 1) * (v62 + v63) + v62 / 2 + (SettingsState.GetButtonPositionOffset(p) + v19.groupOffset()).X
end

function NoteLaneUI.GetHitLineY()
	return hitLineY
end

function NoteLaneUI.GetHitContainer(p)
	return v28[p]
end

function NoteLaneUI.GetActiveLaneCount()
	return activeLaneCount
end

function NoteLaneUI.RelayoutLive()
	if not (activeLaneCount and track) then
		return
	end

	local v62 = v5
	local gemDims = v19.gemDims()
	local v63 = effectiveLaneSpacing() + v19.laneExtra(gemDims) -- inferred equivalent call
	local groupOffset = v19.groupOffset()

	for i = 1, activeLaneCount do
		local v64 = (i - 1) * (v62 + v63) + v62 / 2
		local v65 = SettingsState.GetButtonPositionOffset(i) + groupOffset
		local v66 = v27[i]

		if v66 then
			v66.Position = UDim2.new(0, v64 + v65.X, 0, v65.Y)
		end

		local v67 = v28[i]

		if v67 then
			v67.Position = UDim2.new(0, v64 + v65.X, 0, hitLineY + v65.Y)
		end
	end

	track.Size = UDim2.new(0, NoteLaneUI.GetTrackWidth(activeLaneCount), 0, trackHeight)
end

function NoteLaneUI.OnLanePressed(p)
	table.insert(v40, p)
end

function NoteLaneUI.OnLaneReleased(p)
	table.insert(v41, p)
end

local function fireLanePressed(i)
	for _, callback in ipairs(v40) do
		local success, result = pcall(callback, i)

		if not success then
			warn("[NoteLaneUI] Error pada lane pressed listener:", result)
		end
	end
end

local function fireLaneReleased(i)
	for _, callback in ipairs(v41) do
		local success, result = pcall(callback, i)

		if not success then
			warn("[NoteLaneUI] Error pada lane released listener:", result)
		end
	end
end

local function buildTrack(p, p2, p3, p4, p5)
	clearTrack()

	v31 = p5

	local v62 = p2 or RhythmEngineConfig.LaneCount[p]

	if not v62 then
		warn("[NoteLaneUI] LaneCount tidak ditemukan untuk instrumen:", p)
		return
	end

	v32 = SettingsState.GetRhythmLaneColors(v62)
	local rhythmShape = SettingsState.GetRhythmShape()
	v35 = rhythmShape
	activeLaneCount = v62

	local v63 = p3 or RhythmEngineConfig.KeyBindings[p] or {}
	local v64 = p4 or RhythmEngineConfig.LaneNames[p] or {}

	local v65 = v5
	local gemDims, activeH, noteW, noteH = v19.gemDims()
	local v69 = effectiveLaneSpacing() + v19.laneExtra(gemDims) -- inferred equivalent call
	local gem2 = effectiveGemSize() -- inferred equivalent call
	local backgroundTransparency = effectiveIdleTransparency() -- inferred equivalent call
	v36 = gem2
	v19.activeW = gemDims
	v19.activeH = activeH
	v19.noteW = noteW
	v19.noteH = noteH

	local trackWidth = NoteLaneUI.GetTrackWidth(v62)
	track.Size = UDim2.new(0, trackWidth, 0, trackHeight)

	instrumentNameLabel.Text = v4[p] or p
	instrumentNameLabel.Visible = true

	for i = 1, v62 do
		local v72 = v32 and v32[i]

		if v72 and v72.NoteOuter then
			local _noteOuter = v72.NoteOuter
		elseif v31 and v31[i] then
			local _ = v31[i]
		else
			local _ = v2[(i - 1) % #v2 + 1]
		end

		local receptorRingColorForLane = getReceptorRingColorForLane(i) -- inferred equivalent call
		local receptorPressColorForLane = getReceptorPressColorForLane(i) -- inferred equivalent call
		v38[i] = receptorRingColorForLane
		receptorPressColorForLanes[i] = receptorPressColorForLane
		local v73 = (i - 1) * (v65 + v69) + v65 / 2

		local v74 = SettingsState.GetButtonPositionOffset(i) + v19.groupOffset()

		local frame = Instance.new("Frame")
		frame.Name = "Lane" .. i .. "Rail"
		frame.AnchorPoint = Vector2.new(0.5, 0)
		frame.Position = UDim2.new(0, v73 + v74.X, 0, v74.Y)
		frame.Size = UDim2.new(0, 3, 0, hitLineY)
		frame.BackgroundColor3 = color
		frame.BackgroundTransparency = 0.82
		frame.BorderSizePixel = 0
		frame.ZIndex = 1
		frame.Parent = track
		v27[i] = frame

		local hitContainer = Instance.new("TextButton")
		hitContainer.Name = "HitContainer"
		hitContainer.Text = ""
		hitContainer.AutoButtonColor = false
		hitContainer.AnchorPoint = Vector2.new(0.5, 0.5)
		hitContainer.Position = UDim2.new(0, v73 + v74.X, 0, hitLineY + v74.Y)
		hitContainer.Size = UDim2.new(0, gemDims + 20, 0, activeH + 20)
		hitContainer.BackgroundTransparency = 1
		hitContainer.ZIndex = 3
		hitContainer.Parent = track

		hitContainer.MouseButton1Down:Connect(function()
			fireLanePressed(i)
		end)
		hitContainer.MouseButton1Up:Connect(function()
			fireLaneReleased(i)
		end)
		hitContainer.MouseLeave:Connect(function()
			fireLaneReleased(i)
		end)

		v29[i] = hitContainer

		buildKeyAura(i, hitContainer, gem2)

		local gem = makeGem(hitContainer, gemDims, receptorRingColorForLane, nil, rhythmShape, 3, activeH)
		gem.BackgroundTransparency = backgroundTransparency
		v26[i] = receptorRingColorForLane

		local uiScale2 = Instance.new("UIScale")
		uiScale2.Scale = 1
		uiScale2.Parent = gem

		v19.buildReceptorSkin(hitContainer, gem, gem2, i, rhythmShape)

		local keyLabel = Instance.new("TextLabel")
		keyLabel.Name = "KeyLabel"
		keyLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		keyLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		keyLabel.Size = UDim2.new(1, 0, 1, 0)
		keyLabel.BackgroundTransparency = 1
		keyLabel.Font = Enum.Font.GothamBlack
		keyLabel.TextSize = textSize
		keyLabel.TextColor3 = color2
		keyLabel.TextStrokeTransparency = 0.2
		keyLabel.TextStrokeColor3 = color3
		local v75 = v63[i]
		local text

		if v75 then
			local success, result = pcall(function()
				local ControllerGlyphs = require(script.Parent.ControllerGlyphs)
				return ControllerGlyphs.Label(v75)
			end)

			text = success and result or v75.Name
		else
			text = "?"
		end

		keyLabel.Text = text
		keyLabel.ZIndex = 5
		keyLabel.Parent = hitContainer

		local KeyArrowIcon = require(script.Parent.KeyArrowIcon)
		local rotation = KeyArrowIcon.GetRotation(v63[i])

		if rotation then
			keyLabel.Text = ""
			local KeyArrowIcon2 = require(script.Parent.KeyArrowIcon)
			KeyArrowIcon2.Create(keyLabel, rotation, math.floor(textSize * 1.15 + 0.5), color2, color3, 0.2)
		end

		local KeySpaceCap = require(script.Parent.KeySpaceCap)

		if KeySpaceCap.IsSpace(v63[i]) then
			keyLabel.Text = ""
			local KeySpaceCap2 = require(script.Parent.KeySpaceCap)
			KeySpaceCap2.Create(
				keyLabel,
				math.floor(gemDims * 0.8),
				math.floor(activeH * 0.26),
				color2,
				color3,
				0.2,
				0.5
			)
		end

		local laneNameLabel = Instance.new("TextLabel")
		laneNameLabel.Name = "LaneNameLabel"
		laneNameLabel.AnchorPoint = Vector2.new(0.5, 0)
		laneNameLabel.Position = UDim2.new(0.5, 0, 1, 2)
		laneNameLabel.Size = UDim2.new(0, v65 + 24, 0, 14)
		laneNameLabel.BackgroundTransparency = 1
		laneNameLabel.Font = Enum.Font.GothamBold
		laneNameLabel.TextSize = textSize2
		laneNameLabel.TextColor3 = color2
		laneNameLabel.TextStrokeTransparency = 0.3
		laneNameLabel.TextStrokeColor3 = color3
		laneNameLabel.Text = string.upper(v64[i] or "")
		laneNameLabel.ZIndex = 5
		laneNameLabel.Parent = hitContainer

		v28[i] = hitContainer
	end

	startAuraDriver() -- inferred equivalent call
	track.Visible = true
end

local function build()
	if noteLaneUI then
		return
	end

	noteLaneUI = Instance.new("ScreenGui")
	noteLaneUI.Name = "NoteLaneUI"
	noteLaneUI.ResetOnSpawn = false
	noteLaneUI.Enabled = false
	noteLaneUI.Parent = PlayerGui

	glowLayer = Instance.new("Frame")
	glowLayer.Name = "GlowLayer"
	glowLayer.Size = UDim2.new(1, 0, 1, 0)
	glowLayer.BackgroundTransparency = 1
	glowLayer.ClipsDescendants = false
	glowLayer.ZIndex = 0
	glowLayer.Parent = noteLaneUI

	v25 = StarPowerVisualEffects.BuildAtmosphere(noteLaneUI)

	track = Instance.new("Frame")
	track.Name = "Track"
	track.AnchorPoint = Vector2.new(0.5, 1)
	track.Position = UDim2.new(0.5, v and -12 or 0, 1, v7)
	track.BackgroundTransparency = 1
	track.Visible = false
	track.Parent = noteLaneUI

	instrumentNameLabel = Instance.new("TextLabel")
	instrumentNameLabel.Name = "InstrumentNameLabel"
	instrumentNameLabel.AnchorPoint = Vector2.new(0.5, 1)
	instrumentNameLabel.Position = UDim2.new(0.5, 0, 0, -12)
	instrumentNameLabel.Size = UDim2.new(0, 300, 0, 24)
	instrumentNameLabel.BackgroundTransparency = 1
	instrumentNameLabel.Font = Enum.Font.GothamBlack
	instrumentNameLabel.TextSize = v and 13 or 16
	instrumentNameLabel.TextColor3 = color2
	instrumentNameLabel.TextStrokeTransparency = 0.2
	instrumentNameLabel.TextStrokeColor3 = color3
	instrumentNameLabel.Text = ""
	instrumentNameLabel.Visible = false
	instrumentNameLabel.ZIndex = 5
	instrumentNameLabel.Parent = track

	bigJudgmentLabel = Instance.new("TextLabel")
	bigJudgmentLabel.Name = "BigJudgmentLabel"
	bigJudgmentLabel.AnchorPoint = Vector2.new(0.5, 1)
	bigJudgmentLabel.Position = UDim2.new(0.5, 0, 0, hitLineY - 44)
	bigJudgmentLabel.Size = UDim2.new(0, 280, 0, 44)
	bigJudgmentLabel.BackgroundTransparency = 1
	bigJudgmentLabel.Font = Enum.Font.GothamBlack
	bigJudgmentLabel.TextSize = v and 22 or 30
	bigJudgmentLabel.TextTransparency = 1
	bigJudgmentLabel.TextStrokeTransparency = 0.3
	bigJudgmentLabel.TextStrokeColor3 = color3
	bigJudgmentLabel.Text = ""
	bigJudgmentLabel.ZIndex = 6
	bigJudgmentLabel.Parent = track

	uiScale = Instance.new("UIScale")
	uiScale.Scale = 1
	uiScale.Parent = bigJudgmentLabel

	breakCountdownLabel = Instance.new("TextLabel")
	breakCountdownLabel.Name = "BreakCountdownLabel"
	breakCountdownLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	breakCountdownLabel.Position = UDim2.new(0.5, 0, 0, hitLineY - 110)
	breakCountdownLabel.Size = UDim2.new(0, v and 70 or 90, 0, v and 70 or 90)
	breakCountdownLabel.BackgroundColor3 = Color3.fromRGB(230, 220, 200)
	breakCountdownLabel.BackgroundTransparency = 0.85
	breakCountdownLabel.Font = Enum.Font.GothamBlack
	breakCountdownLabel.TextSize = v and 26 or 34
	breakCountdownLabel.TextColor3 = color2
	breakCountdownLabel.Text = ""
	breakCountdownLabel.Visible = false
	breakCountdownLabel.ZIndex = 6
	breakCountdownLabel.Parent = track

	local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
	uiTextSizeConstraint.MaxTextSize = v and 26 or 34
	uiTextSizeConstraint.MinTextSize = 14
	uiTextSizeConstraint.Parent = breakCountdownLabel
	breakCountdownLabel.TextScaled = true

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = breakCountdownLabel

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(230, 220, 200)
	uiStroke.Thickness = 2
	uiStroke.Transparency = 0.4
	uiStroke.Parent = breakCountdownLabel

	breakCountdownCaption = Instance.new("TextLabel")
	breakCountdownCaption.Name = "BreakCountdownCaption"
	breakCountdownCaption.AnchorPoint = Vector2.new(0.5, 0)
	breakCountdownCaption.Position = UDim2.new(0.5, 0, 1, 6)
	breakCountdownCaption.Size = UDim2.new(0, 200, 0, 18)
	breakCountdownCaption.BackgroundTransparency = 1
	breakCountdownCaption.Font = Enum.Font.GothamBold
	breakCountdownCaption.TextSize = v and 11 or 13
	breakCountdownCaption.TextColor3 = color2
	breakCountdownCaption.TextStrokeTransparency = 0.4
	breakCountdownCaption.TextStrokeColor3 = color3
	breakCountdownCaption.Text = "Get Ready..."
	breakCountdownCaption.Visible = false
	breakCountdownCaption.ZIndex = 6
	breakCountdownCaption.Parent = breakCountdownLabel

	v39 = CountdownFx.Attach(breakCountdownLabel, breakCountdownCaption)
end

local function timeToY(p, p2) -- 2 equivalent calls inferred from this helper
	return math.clamp(1 - p / p2, 0, 1.3) * hitLineY
end

local function spawnLightningBurst(parent, p)
	if not parent then
		return
	end

	for i = 1, 8 do
		local burstShard = Instance.new("Frame")
		burstShard.Name = "BurstShard"
		burstShard.AnchorPoint = Vector2.new(0.5, 1)
		burstShard.Position = UDim2.new(0.5, 0, 0.5, 0)
		burstShard.Size = UDim2.new(0, 3, 0, 4)
		burstShard.Rotation = i * 45
		burstShard.BackgroundColor3 = color4
		burstShard.BackgroundTransparency = 0
		burstShard.BorderSizePixel = 0
		burstShard.ZIndex = 7
		burstShard.Parent = parent

		local uiGradient = Instance.new("UIGradient")
		uiGradient.Color = ColorSequence.new(color4, p)
		uiGradient.Rotation = 90
		uiGradient.Parent = burstShard

		TweenService:Create(burstShard, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 3, 0, v11),
			BackgroundTransparency = 1
		}):Play()

		task.delay(0.28, function()
			burstShard:Destroy()
		end)
	end

	local centerFlash = Instance.new("Frame")
	centerFlash.Name = "CenterFlash"
	centerFlash.AnchorPoint = Vector2.new(0.5, 0.5)
	centerFlash.Position = UDim2.new(0.5, 0, 0.5, 0)
	centerFlash.Size = UDim2.new(0, effectiveGemSize(), 0, effectiveGemSize()) -- inferred equivalent call
	centerFlash.BackgroundColor3 = color4
	centerFlash.BackgroundTransparency = 0.1
	centerFlash.BorderSizePixel = 0
	centerFlash.ZIndex = 6
	centerFlash.Parent = parent

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = centerFlash

	local uiScale2 = Instance.new("UIScale")
	uiScale2.Scale = 0.6
	uiScale2.Parent = centerFlash

	TweenService:Create(uiScale2, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Scale = 1.6
	}):Play()
	TweenService:Create(centerFlash, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1
	}):Play()

	task.delay(0.28, function()
		centerFlash:Destroy()
	end)
end

local v62 = {
	Drift = {
		Duration = 1.7,
		Tint = Color3.fromRGB(190, 210, 235),
		TintAmt = 0.25,
		Appear = {
			SideMul = 0.5,
			DropMin = 70,
			DropMax = 120,
			Gravity = 560,
			Restitution = 0.15,
			XK = 36,
			XC = 9,
			RotMax = 14,
			RK = 36,
			RC = 7,
			ScaleStart = 0.85,
			SK = 55,
			SC = 9,
			Pop = 0.5,
			AlphaTime = 0.8,
			Stagger = 0.4,
			Order = "random",
			SwayAmp = 9,
			SwayFreq = 2.2,
			Trail = "mote",
			TrailRate = 0.1
		},
		Land = {
			Rings = {
				{
					From = 0.7,
					To = 3.2,
					Time = 0.9,
					Thick = 1.5,
					White = false
				},
				{
					From = 0.5,
					To = 2.2,
					Time = 0.7,
					Thick = 1,
					White = true
				}
			},
			Motes = 5
		},
		Out = {
			Shake = 0,
			VXMin = 40,
			VXMax = 95,
			VYMin = 60,
			VYMax = 110,
			Gravity = 70,
			Restitution = 0,
			SpinMin = 10,
			SpinMax = 26,
			FadeDelay = 0,
			FadeTime = 2,
			RailFadeTime = 2.6,
			Drag = 0.8,
			EndScale = 0.85,
			Stagger = 0.45,
			SwayAmp = 8,
			SwayFreq = 2,
			Trail = "mote",
			TrailRate = 0.1,
			Start = {
				Ring = { From = 0.5, To = 2, Time = 0.8, Thick = 1.5 },
				Motes = 4
			}
		}
	},
	Groove = {
		Duration = 1,
		Appear = {
			SideMul = 1,
			DropMin = 45,
			DropMax = 85,
			Gravity = 2200,
			Restitution = 0.4,
			XK = 130,
			XC = 12,
			RotMax = 70,
			RK = 120,
			RC = 10,
			ScaleStart = 0.5,
			SK = 180,
			SC = 12,
			Pop = 3,
			AlphaTime = 0.3,
			Stagger = 0.16,
			Order = "outer",
			Trail = "ember",
			TrailRate = 0.045
		},
		Land = {
			Flash = { Size = 1.6, Transp = 0.55, Time = 0.25 },
			Rings = {
				{
					From = 0.6,
					To = 2.3,
					Time = 0.45,
					Thick = 3,
					White = false
				},
				{
					From = 0.4,
					To = 1.6,
					Time = 0.32,
					Thick = 2,
					White = true
				}
			},
			Sparks = {
				Mul = 0.8,
				Min = 0.7,
				Max = 1.4,
				Time = 0.45,
				A1 = -170,
				A2 = -10
			},
			Dust = 3
		},
		Out = {
			Shake = 0,
			VXMin = 260,
			VXMax = 440,
			VYMin = 260,
			VYMax = 440,
			Gravity = 1400,
			FloorMin = 14,
			FloorMax = 40,
			Restitution = 0.5,
			SpinMin = 220,
			SpinMax = 520,
			FadeDelay = 0.03,
			FadeTime = 1,
			RailFadeTime = 1.5,
			Drag = 1.6,
			EndScale = 0.72,
			Stagger = 0.12,
			Trail = "ember",
			TrailRate = 0.045,
			Start = {
				Flash = { Size = 1.4, Transp = 0.55, Time = 0.2 },
				Ring = { From = 0.5, To = 1.7, Time = 0.34, Thick = 2.2 },
				Sparks = {
					Mul = 0.7,
					Min = 0.8,
					Max = 1.6,
					Time = 0.4,
					Spread = 50
				}
			}
		}
	},
	Punch = {
		Duration = 0.85,
		Appear = {
			SideMul = 1.15,
			DropMin = 40,
			DropMax = 75,
			Gravity = 3400,
			Restitution = 0.36,
			XK = 200,
			XC = 15,
			RotMax = 70,
			RK = 150,
			RC = 11,
			ScaleStart = 0.4,
			SK = 230,
			SC = 14,
			Pop = 3.8,
			AlphaTime = 0.2,
			Stagger = 0.09,
			Order = "outer",
			Trail = "ember",
			TrailRate = 0.035
		},
		Land = {
			Flash = { Size = 1.9, Transp = 0.45, Time = 0.22 },
			Rings = {
				{
					From = 0.6,
					To = 2.8,
					Time = 0.42,
					Thick = 3.5,
					White = false
				},
				{
					From = 0.4,
					To = 2,
					Time = 0.3,
					Thick = 2,
					White = true
				}
			},
			Sparks = {
				Mul = 1.2,
				Min = 0.8,
				Max = 1.7,
				Time = 0.4,
				A1 = -175,
				A2 = -5
			},
			Dust = 4
		},
		Out = {
			Shake = 0,
			VXMin = 380,
			VXMax = 620,
			VYMin = 320,
			VYMax = 560,
			Gravity = 1900,
			FloorMin = 14,
			FloorMax = 40,
			Restitution = 0.5,
			SpinMin = 320,
			SpinMax = 720,
			FadeDelay = 0.02,
			FadeTime = 0.9,
			RailFadeTime = 1.3,
			Drag = 1.4,
			EndScale = 0.68,
			Stagger = 0.1,
			Trail = "ember",
			TrailRate = 0.035,
			Start = {
				Flash = { Size = 1.6, Transp = 0.5, Time = 0.2 },
				Ring = { From = 0.5, To = 2, Time = 0.32, Thick = 2.5 },
				Sparks = {
					Mul = 1,
					Min = 0.9,
					Max = 1.9,
					Time = 0.38,
					Spread = 60
				}
			}
		}
	},
	Blitz = {
		Duration = 0.6,
		Tint = Color3.fromRGB(180, 230, 255),
		TintAmt = 0.25,
		Appear = {
			SideMul = 1.5,
			DropMin = 25,
			DropMax = 45,
			Gravity = 6200,
			Restitution = 0.28,
			XK = 420,
			XC = 26,
			RotMax = 30,
			RK = 360,
			RC = 22,
			ScaleStart = 0.7,
			SK = 420,
			SC = 22,
			Pop = 4.5,
			AlphaTime = 0.1,
			Stagger = 0.18,
			Order = "sequential",
			Trail = "streak",
			TrailRate = 0.025
		},
		Land = {
			Flash = { Size = 2.2, Transp = 0.35, Time = 0.16 },
			Rings = {
				{
					From = 0.5,
					To = 3.2,
					Time = 0.3,
					Thick = 3,
					White = true
				}
			},
			Sparks = {
				Mul = 1.5,
				Min = 0.9,
				Max = 1.9,
				Time = 0.32,
				A1 = -180,
				A2 = 0
			},
			Lines = 6,
			Dust = 2
		},
		Out = {
			Shake = 0,
			VXMin = 560,
			VXMax = 900,
			VYMin = 200,
			VYMax = 380,
			Gravity = 2600,
			FloorMin = 14,
			FloorMax = 30,
			Restitution = 0.4,
			SpinMin = 500,
			SpinMax = 1000,
			FadeDelay = 0,
			FadeTime = 0.65,
			RailFadeTime = 1,
			Drag = 1.8,
			EndScale = 0.6,
			Stagger = 0.06,
			Trail = "streak",
			TrailRate = 0.025,
			Start = {
				Flash = { Size = 1.8, Transp = 0.4, Time = 0.14 },
				Ring = { From = 0.5, To = 2.4, Time = 0.25, Thick = 2.5 },
				Sparks = {
					Mul = 1.3,
					Min = 1,
					Max = 2.2,
					Time = 0.3,
					Spread = 35
				}
			}
		}
	},
	Heavy = {
		Duration = 0.9,
		Tint = Color3.fromRGB(255, 140, 50),
		TintAmt = 0.45,
		Appear = {
			SideMul = 0.35,
			DropMin = 140,
			DropMax = 220,
			Gravity = 4400,
			Restitution = 0.16,
			XK = 300,
			XC = 40,
			RotMax = 10,
			RK = 260,
			RC = 28,
			ScaleStart = 1.45,
			SK = 220,
			SC = 26,
			Pop = -1.8,
			AlphaTime = 0.14,
			Stagger = 0.12,
			Order = "inner",
			Trail = "ember",
			TrailRate = 0.03
		},
		Land = {
			Flash = { Size = 2, Transp = 0.4, Time = 0.2 },
			Rings = {
				{
					From = 0.6,
					To = 3,
					Time = 0.5,
					Thick = 4,
					White = false
				}
			},
			Sparks = {
				Mul = 1.3,
				Min = 0.8,
				Max = 1.8,
				Time = 0.5,
				A1 = -160,
				A2 = -20
			},
			Dust = 6,
			Wave = { To = 4.2, Time = 0.42 }
		},
		Out = {
			Shake = 0.2,
			VXMin = 460,
			VXMax = 720,
			VYMin = 140,
			VYMax = 300,
			Gravity = 2800,
			FloorMin = 20,
			FloorMax = 50,
			Restitution = 0.3,
			SpinMin = 120,
			SpinMax = 320,
			FadeDelay = 0.04,
			FadeTime = 0.85,
			RailFadeTime = 1.3,
			Drag = 1.2,
			EndScale = 0.75,
			Stagger = 0.14,
			Trail = "ember",
			TrailRate = 0.03,
			Start = {
				Flash = { Size = 1.8, Transp = 0.4, Time = 0.2 },
				Ring = { From = 0.6, To = 2.2, Time = 0.4, Thick = 3.5 },
				Sparks = {
					Mul = 1.4,
					Min = 0.9,
					Max = 2,
					Time = 0.45,
					Spread = 55
				}
			}
		}
	}
}

local v63 = {
	Duration = 0.7,
	Tint = Color3.fromRGB(255, 235, 200),
	TintAmt = 0.2,
	Appear = {
		SideMul = 0,
		DropMin = 140,
		DropMax = 140,
		Gravity = 7000,
		Restitution = 0.22,
		XK = 300,
		XC = 36,
		RotMax = 0,
		RK = 300,
		RC = 30,
		ScaleStart = 1.35,
		SK = 420,
		SC = 40,
		Pop = -1.2,
		AlphaTime = 0.08,
		RailTime = 0.22,
		Stagger = 0.22,
		Order = "sequential",
		Trail = "none"
	},
	Land = {
		Flash = { Size = 1.8, Transp = 0.4, Time = 0.14 },
		Rings = {
			{
				From = 0.5,
				To = 2.4,
				Time = 0.28,
				Thick = 3,
				White = true
			}
		},
		Sparks = {
			Mul = 0.9,
			Min = 0.8,
			Max = 1.5,
			Time = 0.3,
			A1 = -165,
			A2 = -15
		},
		Wave = { To = 3, Time = 0.28 },
		Dust = 2
	}
}

local v64 = { Name = "Groove", Style = 0, Tempo = 1, Bpm = 120 }
v64.Style = v62.Groove
local v65 = 1

local function getBreakFadeTimes() -- 2 equivalent calls inferred from this helper
	local bpm = v64.Bpm or 120
	local v66 = 60 / bpm
	return math.clamp(v66 * 6, 2.6, 4.5), math.clamp(v66 * 5, 2.2, 3.5), bpm <= 100
end

local function resolveKeyFxStyleName(data, p)
	if data and data.KeyFxStyle and v62[data.KeyFxStyle] then
		return data.KeyFxStyle
	end

	local mood = string.lower(data and data.Mood or "")
	local genre = string.lower(data and data.Genre or "")
	local function hasGenre(...): boolean
		for _, v66 in ipairs({ ... }) do
			if genre:find(v66, 1, true) then
				return true
			end
		end

		return false
	end

	if mood == "slow" or hasGenre("dsbm", "gothic", "shoegaze", "waltz") then
		return "Drift"
	end

	if mood == "hardcore" or mood ~= "chill" and hasGenre("metal", "grindcore") then
		return "Heavy"
	end

	if mood == "chill" then
		if p <= 100 then
			return "Drift"
		end

		return if p <= 140 then "Groove" else "Punch"
	elseif mood == "punk" then
		return if p >= 190 then "Blitz" else "Punch"
	else
		if mood == "rock" then
			if p < 130 then
				return "Groove"
			end

			if p < 175 then
				return "Punch"
			end
		else
			if p < 100 then
				return "Groove"
			end

			if p < 155 then
				return "Punch"
			end
		end

		return "Blitz"
	end
end

function NoteLaneUI.SetSongProfile(data)
	local bpm = data and tonumber(data.BPM)
	local bpm2 = (not bpm or bpm < 20)
		and (string.lower(data and data.Genre or ""):find("metal", 1, true) and 170 or 120)
		or bpm

	local keyFxStyleName = resolveKeyFxStyleName(data, bpm2)
	local tempo = math.clamp((bpm2 / 120) ^ 0.5, 0.72, 1.4)

	if keyFxStyleName == "Drift" then
		tempo = math.min(tempo, 1.12)
	elseif keyFxStyleName == "Heavy" then
		tempo = math.clamp(tempo, 0.85, 1.3)
	end

	v64 = { Name = keyFxStyleName, Style = v62[keyFxStyleName], Tempo = tempo, Bpm = bpm2 }
	v65 = 1 / tempo

	local v68 = bpm2 / 60

	while v68 > 2.2 do
		v68 /= 2
	end

	while v68 < 0.75 do
		v68 *= 2
	end

	v61 = v68
	local keyAuraStyle

	if data and type(data.KeyAuraStyle) == "string" then
		keyAuraStyle = string.lower(data.KeyAuraStyle) or nil
	end

	if keyAuraStyle == "warm" then
		v53 = false
	elseif keyAuraStyle == "blade" then
		v53 = true
	else
		v53 = bpm2 >= 80
	end
end

function NoteLaneUI.GetKeyFxStyleName()
	return v64.Name
end

function NoteLaneUI.GetReceptorAppearDuration()
	local bpm = v64.Bpm or 120
	local v66 = 60 / bpm
	math.clamp(v66 * 6, 2.6, 4.5)
	local receptorAppearDuration = math.clamp(v66 * 5, 2.2, 3.5)
	local _ = bpm <= 100

	return receptorAppearDuration
end

local function getFxLayer() -- 4 equivalent calls inferred from this helper
	if v46 and v46.Parent then
		return v46
	end

	if not track then
		return nil
	end

	local receptorFx = Instance.new("Frame")
	receptorFx.Name = "ReceptorFx"
	receptorFx.BackgroundTransparency = 1
	receptorFx.BorderSizePixel = 0
	receptorFx.Size = UDim2.new(1, 0, 1, 0)
	receptorFx.ZIndex = 4
	receptorFx.Parent = track
	v46 = receptorFx
	return receptorFx
end

local function fxLighten(p, p2) -- 6 equivalent calls inferred from this helper
	return p:Lerp(Color3.new(1, 1, 1), p2)
end

local function fxRing(fxLayer, p, p2, color9, p3, p4, duration, thick)
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0, p, 0, p2)
	frame.Size = UDim2.new(0, p3, 0, p3)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ZIndex = 4
	frame.Parent = fxLayer

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = frame

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color9
	uiStroke.Thickness = thick
	uiStroke.Transparency = 0.1
	uiStroke.Parent = frame

	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	TweenService:Create(frame, tweenInfo, { Size = UDim2.new(0, p4, 0, p4) }):Play()
	TweenService:Create(uiStroke, tweenInfo, { Transparency = 1, Thickness = 0.5 }):Play()
	Debris:AddItem(frame, duration + 0.05)
end

local function fxFlash(fxLayer, p, p2, backgroundColor, p3, p4, duration, transp)
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0, p, 0, p2)
	frame.Size = UDim2.new(0, p3, 0, p3)
	frame.BackgroundColor3 = backgroundColor
	frame.BackgroundTransparency = transp
	frame.BorderSizePixel = 0
	frame.ZIndex = 4
	frame.Parent = fxLayer

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = frame

	TweenService:Create(frame, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, p4, 0, p4),
		BackgroundTransparency = 1
	}):Play()
	Debris:AddItem(frame, duration + 0.05)
end

local function fxSparks(fxLayer, p, p2, p3, p4, p5, p6, p7, p8, p9)
	for _ = 1, p4 do
		local number = random:NextNumber(p8, p9)
		local v66 = math.rad(number)
		local number2 = random:NextNumber(p5, p6)
		local number3 = random:NextNumber(8, 16)
		local v67 = p7 * random:NextNumber(0.75, 1.1)

		local frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.new(0, p, 0, p2)
		frame.Size = UDim2.new(0, number3, 0, 3)
		frame.Rotation = number
		frame.BackgroundColor3 = fxLighten(p3, random:NextNumber(0.35, 0.85)) -- inferred equivalent call
		frame.BorderSizePixel = 0
		frame.ZIndex = 5
		frame.Parent = fxLayer

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = frame

		TweenService:Create(frame, TweenInfo.new(v67, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, p + math.cos(v66) * number2, 0, p2 + math.sin(v66) * number2 + number2 * 0.18),
			Size = UDim2.new(0, 3, 0, 2),
			BackgroundTransparency = 1
		}):Play()
		Debris:AddItem(frame, v67 + 0.05)
	end
end

local function fxDust(fxLayer, p, p2, p3)
	for i = 1, p3 do
		local v66 = i % 2 == 0 and 1 or -1
		local number = random:NextNumber(8, 14)
		local v67 = v65 * 0.42

		local frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.new(0, p + v66 * random:NextNumber(4, 10), 0, p2)
		frame.Size = UDim2.new(0, number, 0, number)
		frame.BackgroundColor3 = Color3.fromRGB(200, 185, 160)
		frame.BackgroundTransparency = 0.55
		frame.BorderSizePixel = 0
		frame.ZIndex = 4
		frame.Parent = fxLayer

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = frame

		TweenService:Create(frame, TweenInfo.new(v67, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, p + v66 * random:NextNumber(22, 42), 0, p2 - random:NextNumber(4, 12)),
			Size = UDim2.new(0, number * 1.8, 0, number * 1.8),
			BackgroundTransparency = 1
		}):Play()
		Debris:AddItem(frame, v67 + 0.05)
	end
end

local function fxEmber(fxLayer, p, p2, p3, p4)
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0, p, 0, p2)
	frame.Size = UDim2.new(0, 5, 0, 5)
	frame.Rotation = 45
	frame.BackgroundColor3 = fxLighten(p3, 0.6) -- inferred equivalent call
	frame.BackgroundTransparency = 0.1
	frame.BorderSizePixel = 0
	frame.ZIndex = 5
	frame.Parent = fxLayer

	local v66 = v65 * 0.42
	TweenService:Create(frame, TweenInfo.new(v66, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, p + p4 * random:NextNumber(8, 26), 0, p2 + random:NextNumber(14, 34)),
		Size = UDim2.new(0, 1, 0, 1),
		BackgroundTransparency = 1
	}):Play()
	Debris:AddItem(frame, v66 + 0.05)
end

local function fxMote(fxLayer, p, p2, p3)
	local number = random:NextNumber(5, 9)
	local v66 = v65 * 0.9

	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0, p, 0, p2)
	frame.Size = UDim2.new(0, number, 0, number)
	frame.BackgroundColor3 = fxLighten(p3, 0.55) -- inferred equivalent call
	frame.BackgroundTransparency = 0.45
	frame.BorderSizePixel = 0
	frame.ZIndex = 4
	frame.Parent = fxLayer

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = frame

	TweenService:Create(frame, TweenInfo.new(v66, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, p + random:NextNumber(-14, 14), 0, p2 - random:NextNumber(22, 46)),
		Size = UDim2.new(0, number * 0.5, 0, number * 0.5),
		BackgroundTransparency = 1
	}):Play()
	Debris:AddItem(frame, v66 + 0.05)
end

local function fxStreak(fxLayer, p, p2, p3, dir)
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0, p - dir * 10, 0, p2)
	frame.Size = UDim2.new(0, 24, 0, 2)
	frame.BackgroundColor3 = fxLighten(p3, 0.7) -- inferred equivalent call
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.ZIndex = 5
	frame.Parent = fxLayer

	local v66 = v65 * 0.18
	TweenService:Create(frame, TweenInfo.new(v66, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, p - dir * 34, 0, p2),
		Size = UDim2.new(0, 4, 0, 1),
		BackgroundTransparency = 1
	}):Play()
	Debris:AddItem(frame, v66 + 0.05)
end

local function fxWave(fxLayer, p, p2, backgroundColor, p3, duration)
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0, p, 0, p2)
	frame.Size = UDim2.new(0, p3 * 0.15, 0, 4)
	frame.BackgroundColor3 = backgroundColor
	frame.BackgroundTransparency = 0.25
	frame.BorderSizePixel = 0
	frame.ZIndex = 4
	frame.Parent = fxLayer

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = frame

	TweenService:Create(frame, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, p3, 0, 1),
		BackgroundTransparency = 1
	}):Play()
	Debris:AddItem(frame, duration + 0.05)
end

local function receptorFxColor(p, style) -- 3 equivalent calls inferred from this helper
	local v66 = v38[p] or getAccentColorForLane(p) -- inferred equivalent call

	if style and style.Tint then
		return (v66:Lerp(style.Tint, style.TintAmt or 0.3))
	end

	return v66
end

local function playLandFx(data, p)
	local land = data.Style.Land
	local fxLayer = getFxLayer() -- inferred equivalent call

	if not fxLayer then
		return
	end

	local v66 = data.Home.X.Offset + data.X
	local v67 = data.Home.Y.Offset + data.Y
	local v68 = v36 or 52
	local v69 = receptorFxColor(p, data.Style) -- inferred equivalent call
	local backgroundColor = fxLighten(v69, 0.45) -- inferred equivalent call

	if land.Flash then
		fxFlash(
			fxLayer,
			v66,
			v67,
			backgroundColor,
			v68 * 0.5,
			v68 * land.Flash.Size,
			land.Flash.Time * v65,
			land.Flash.Transp
		)
	end

	if land.Rings then
		for _, ring in ipairs(land.Rings) do
			local v71

			if ring.White then
				v71 = Color3.new(1, 1, 1) or backgroundColor
			else
				v71 = backgroundColor
			end

			fxRing(fxLayer, v66, v67, v71, v68 * ring.From, v68 * ring.To, ring.Time * v65, ring.Thick)
		end
	end

	if land.Sparks then
		local sparks = land.Sparks
		local v71 = math.max(1, (math.floor(v43 * sparks.Mul + 0.5)))
		fxSparks(
			fxLayer,
			v66,
			v67 + v68 * 0.15,
			v69,
			v71,
			v68 * sparks.Min,
			v68 * sparks.Max,
			sparks.Time * v65,
			sparks.A1,
			sparks.A2
		)
	end

	if land.Lines and land.Lines > 0 then
		fxSparks(
			fxLayer,
			v66,
			v67,
			Color3.new(1, 1, 1),
			v and math.ceil(land.Lines / 2) or land.Lines,
			v68 * 0.9,
			v68 * 1.7,
			v65 * 0.22,
			-180,
			180
		)
	end

	if land.Wave then
		fxWave(fxLayer, v66, v67 + v68 * 0.5, backgroundColor, v68 * land.Wave.To, land.Wave.Time * v65)
	end

	if land.Dust and land.Dust > 0 then
		fxDust(fxLayer, v66, v67 + v68 * 0.4, v and math.ceil(land.Dust / 2) or land.Dust)
	end

	if land.Motes and land.Motes > 0 then
		for _ = 1, v and math.ceil(land.Motes / 2) or land.Motes do
			fxMote(fxLayer, v66 + random:NextNumber(-v68 * 0.5, v68 * 0.5), v67 + random:NextNumber(-8, v68 * 0.3), v69)
		end
	end
end

local function playMiniLandFx(data, _)
	local dust = data.Style.Land.Dust

	if not dust or dust <= 0 then
		return
	end

	local fxLayer = getFxLayer() -- inferred equivalent call

	if not fxLayer then
		return
	end

	fxDust(fxLayer, data.Home.X.Offset + data.X, data.Home.Y.Offset + data.Y + (v36 or 52) * 0.4, v and 1 or 2)
end

local function playScatterFx(data, p)
	local start = data.Style.Out.Start

	if not start then
		return
	end

	local fxLayer = getFxLayer() -- inferred equivalent call

	if not fxLayer then
		return
	end

	local v66 = data.Home.X.Offset + data.X
	local v67 = data.Home.Y.Offset + data.Y
	local v68 = v36 or 52
	local v69 = receptorFxColor(p, data.Style) -- inferred equivalent call
	local v70 = fxLighten(v69, 0.45) -- inferred equivalent call

	if start.Flash then
		fxFlash(fxLayer, v66, v67, v70, v68 * 0.6, v68 * start.Flash.Size, start.Flash.Time * v65, start.Flash.Transp)
	end

	if start.Ring then
		local ring = start.Ring
		fxRing(fxLayer, v66, v67, v70, v68 * ring.From, v68 * ring.To, ring.Time * v65, ring.Thick)
	end

	if start.Sparks then
		local sparks = start.Sparks
		local spread = sparks.Spread or 55
		local v71 = -spread

		if data.Dir < 0 then
			v71 = 180 - spread
			spread = 180 + spread
		end

		fxSparks(
			fxLayer,
			v66,
			v67,
			v69,
			math.max(1, (math.floor(v43 * sparks.Mul + 0.5))),
			v68 * sparks.Min,
			v68 * sparks.Max,
			sparks.Time * v65,
			v71,
			spread
		)
	end

	if start.Motes and start.Motes > 0 then
		for _ = 1, v and math.ceil(start.Motes / 2) or start.Motes do
			fxMote(fxLayer, v66 + random:NextNumber(-v68 * 0.4, v68 * 0.4), v67 + random:NextNumber(-8, 8), v69)
		end
	end
end

local function emitTrail(state, p, p2, trail, trailRate)
	if not trail or trail == "none" then
		return
	end

	state.EmberT -= p2

	if state.EmberT > 0 or state.A < 0.15 then
		return
	end

	trailRate = v and trailRate * 1.6 or trailRate
	state.EmberT = trailRate
	local fxLayer = getFxLayer() -- inferred equivalent call

	if not fxLayer then
		return
	end

	local v66 = state.Home.X.Offset + state.X
	local v67 = state.Home.Y.Offset + state.Y
	local v68 = receptorFxColor(p, state.Style) -- inferred equivalent call

	if trail == "ember" then
		fxEmber(fxLayer, v66, v67, v68, -state.Dir)
	elseif trail == "mote" then
		fxMote(fxLayer, v66, v67, v68)
	elseif trail == "streak" then
		fxStreak(fxLayer, v66, v67, v68, state.Dir)
	end
end

local v66 = {}

function v66.PropsFor(instance)
	if instance:IsA("UIStroke") then
		return { "Transparency" }
	end

	if not instance:IsA("GuiObject") then
		return nil
	end

	local v67 = { "BackgroundTransparency" }

	if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
		v67[#v67 + 1] = "TextTransparency"
		v67[#v67 + 1] = "TextStrokeTransparency"
	elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") or instance:IsA("ViewportFrame") then
		v67[#v67 + 1] = "ImageTransparency"
	end

	return v67
end

function v66.Track(p, inst)
	if p.FadeIndex[inst] then
		return
	end

	local propsFor = v66.PropsFor(inst)

	if not propsFor then
		return
	end

	local v67 = { Inst = inst, Props = propsFor, Logical = {}, Applied = {} }
	p.FadeIndex[inst] = v67
	p.FadeItems[#p.FadeItems + 1] = v67
end

function v66:Attach()
	self.FadeItems = {}
	self.FadeIndex = {}
	self.Alpha = 1

	for _, descendant in ipairs(self.Group:GetDescendants()) do
		v66.Track(self, descendant)
	end

	self.FadeConns = {
		self.Group.DescendantAdded:Connect(function(descendant)
			v66.Track(self, descendant)
		end),
		self.Group.DescendantRemoving:Connect(function(descendant)
			local v67 = self.FadeIndex[descendant]

			if v67 then
				v67.Dead = true
				self.FadeIndex[descendant] = nil
			end
		end)
	}
end

function v66:Apply(alpha)
	self.Alpha = alpha
	local fadeItems = self.FadeItems

	if not fadeItems then
		return
	end

	local flag = false

	for i = 1, #fadeItems do
		local fadeItem = fadeItems[i]
		local inst = fadeItem.Inst

		if fadeItem.Dead or not inst.Parent then
			flag = true
		else
			local props = fadeItem.Props
			local logical = fadeItem.Logical
			local applied = fadeItem.Applied

			for j = 1, #props do
				local v67 = props[j]
				local v68 = inst[v67]
				local v69 = applied[j]

				if v69 == nil or math.abs(v68 - v69) > 0.0003 then
					logical[j] = v68
				end

				local v70 = 1 - (1 - logical[j]) * alpha

				if math.abs(v70 - v68) > 1e-6 then
					inst[v67] = v70
				end

				applied[j] = v70
			end
		end
	end

	if flag then
		local fadeItems2 = {}

		for _, fadeItem in ipairs(fadeItems) do
			if fadeItem.Dead or not fadeItem.Inst.Parent then
				continue
			end

			fadeItems2[#fadeItems2 + 1] = fadeItem
		end

		self.FadeItems = fadeItems2
	end
end

local function wrapReceptor(k)
	local v67 = v45[k]

	if v67 then
		return v67
	end

	local v68 = v28[k]

	if not (v68 and track) then
		return nil
	end

	local position = v68.Position

	local canvasGroup = Instance.new("CanvasGroup")
	canvasGroup.Name = "ReceptorFade" .. k
	canvasGroup.AnchorPoint = Vector2.new(0.5, 0.5)
	canvasGroup.BackgroundTransparency = 1
	canvasGroup.BorderSizePixel = 0
	canvasGroup.Position = position
	canvasGroup.Size = UDim2.new(0, v68.Size.X.Offset + 140, 0, v68.Size.Y.Offset + 140)
	canvasGroup.ZIndex = 3
	canvasGroup.GroupTransparency = 0
	canvasGroup.Parent = track

	local uiScale2 = Instance.new("UIScale")
	uiScale2.Scale = 1
	uiScale2.Parent = canvasGroup

	v68.Position = UDim2.new(0.5, 0, 0.5, 0)
	v68.Parent = canvasGroup

	local v69 = {
		Lane = k,
		Group = canvasGroup,
		Scale = uiScale2,
		Home = position,
		Rail = v27[k],
		Style = v64.Style,
		Mode = "in",
		Target = true,
		StartAt = 0,
		A = 1,
		RA = 1,
		X = 0,
		VX = 0,
		Y = 0,
		VY = 0,
		R = 0,
		VR = 0,
		S = 1,
		VS = 0,
		JX = 0,
		JY = 0,
		SwayAmp = 0,
		SwayFreq = 2,
		SwayPhase = 0,
		SwayT = 0,
		SwayK = 0,
		Side = 0,
		Dir = 1,
		Rel = 0,
		RelNorm = 0,
		Rank = 0,
		Impacted = true,
		Rest = true,
		Settled = true,
		Launched = false,
		Entrance = false,
		EmberT = 0,
		T = 0,
		FloorY = nil
	}

	v45[k] = v69
	v66.Attach(v69)
	return v69
end

local function unwrapReceptors()
	for k, v67 in pairs(v45) do
		v66.Apply(v67, 1)

		if v67.FadeConns then
			for _, fadeConn in ipairs(v67.FadeConns) do
				fadeConn:Disconnect()
			end

			v67.FadeConns = nil
		end

		local v68 = v28[k]

		if v68 then
			v68.Position = v67.Home
			v68.Parent = track
		end

		if v67.Rail then
			v67.Rail.BackgroundTransparency = 0.82
		end

		v67.Group:Destroy()
	end

	v45 = {}
end

local function easeVisibility(value, soft) -- 2 equivalent calls inferred from this helper
	local v67 = math.clamp(value, 0, 1)

	if soft then
		return v67 * v67 * v67 * (v67 * (v67 * 6 - 15) + 10)
	end

	return v67 * v67 * (3 - 2 * v67)
end

local function applyReceptorState(data)
	local home = data.Home

	local v67 = not (data.SwayAmp > 0) and 0
		or math.sin(data.SwayT * data.SwayFreq + data.SwayPhase) * data.SwayAmp * data.SwayK

	data.Group.Position = UDim2.new(
		home.X.Scale,
		home.X.Offset + data.X + v67 + data.JX,
		home.Y.Scale,
		home.Y.Offset + data.Y + data.JY
	)
	data.Group.Rotation = data.R
	data.Scale.Scale = math.max(data.S, 0.01)
	local v68 = math.max(easeVisibility(data.A, data.Soft), data.Peek or 0) -- inferred equivalent call
	data.Group.GroupTransparency = 0
	v66.Apply(data, v68)

	if data.Rail then
		local v69 = easeVisibility(data.RA, data.Soft) -- inferred equivalent call
		data.Rail.BackgroundTransparency = 1 - 0.18000000000000005 * v69
	end
end

local function computeReceptorGeometry()
	local v67 = {}
	local total5 = 0

	for _, v68 in pairs(v45) do
		table.insert(v67, v68)
		total5 += v68.Home.X.Offset
	end

	if #v67 == 0 then
		return
	end

	local average = total5 / #v67
	local maxValue = 1

	for _, v68 in ipairs(v67) do
		maxValue = math.max(maxValue, (math.abs(v68.Home.X.Offset - average)))
	end

	table.sort(v67, function(a, b): boolean
		return a.Home.X.Offset < b.Home.X.Offset
	end)

	for i, v68 in ipairs(v67) do
		local rel = v68.Home.X.Offset - average
		v68.Rel = rel
		v68.RelNorm = math.abs(rel) / maxValue
		v68.Side = math.abs(rel) < 1 and 0 or rel > 0 and 1 or -1
		v68.Dir = v68.Side ~= 0 and v68.Side or random:NextInteger(0, 1) == 0 and -1 or 1
		v68.Rank = #v67 > 1 and (i - 1) / (#v67 - 1) or 0
	end
end

local function appearDelay(p, appear) -- 1 equivalent call inferred from this helper
	local order = appear.Order

	if order == "inner" then
		return p.RelNorm * appear.Stagger
	elseif order == "sequential" then
		return p.Rank * appear.Stagger
	elseif order == "random" then
		return random:NextNumber(0, appear.Stagger)
	end

	return (1 - p.RelNorm) * appear.Stagger
end

local function resetSway(p, swayAmp, swayFreq) -- 5 equivalent calls inferred from this helper
	p.SwayAmp = swayAmp or 0
	p.SwayFreq = swayFreq or 2
	p.SwayPhase = random:NextNumber(0, 6.283185307179586)
	p.SwayT = 0
	p.SwayK = 0
end

local function prepareAppear(state, startAt, style)
	local appear = style.Appear
	state.Style = style
	state.Mode = "in"
	state.Target = true
	state.StartAt = startAt
	state.A = 0
	state.RA = 0
	state.Entrance = style == v63

	local v67 = math.max(v42 * appear.SideMul, math.abs(state.Rel) + 30)

	if appear.SideMul <= 0 then
		state.X = 0
	elseif state.Side == 0 then
		state.X = state.Dir * v42 * appear.SideMul * 0.6
	else
		state.X = state.Side * v67 - state.Rel
	end

	state.VX = 0
	state.Y = -random:NextNumber(appear.DropMin, appear.DropMax)
	state.VY = 0
	state.R = state.Dir * random:NextNumber(appear.RotMax * 0.5, appear.RotMax)
	state.VR = 0
	state.S = appear.ScaleStart
	state.VS = 0
	state.JX = 0
	state.JY = 0
	state.Impacted = false
	state.Rest = false
	state.Settled = false
	state.Launched = false
	state.EmberT = 0
	resetSway(state, appear.SwayAmp, appear.SwayFreq) -- inferred equivalent call
end

local function prepareReturn(p, startAt, style)
	p.Style = style
	p.Mode = "in"
	p.Target = true
	p.StartAt = startAt
	p.Entrance = false
	p.R = (p.R + 180) % 360 - 180
	p.JX = 0
	p.JY = 0
	p.Impacted = true
	p.Rest = false
	p.Settled = false
	p.Launched = false
	p.EmberT = 0
	resetSway(p) -- inferred equivalent call
end

local function prepareScatter(p, startAt, style)
	p.Style = style
	p.Mode = "out"
	p.Entrance = false
	p.Target = false
	p.StartAt = startAt
	p.T = 0
	p.Settled = false
	p.Launched = false
	p.EmberT = 0
	resetSway(p) -- inferred equivalent call
end

local function prepareFade(p, now, target, style)
	p.Style = style
	local bpm = v64.Bpm or 120
	local v67 = 60 / bpm
	math.clamp(v67 * 6, 2.6, 4.5)
	math.clamp(v67 * 5, 2.2, 3.5)
	p.Soft = bpm <= 100
	p.Mode = target and "fadein" or "fadeout"
	p.Entrance = false
	p.Target = target
	p.StartAt = now
	p.Settled = false
	p.Launched = false
	p.X = 0
	p.VX = 0
	p.Y = 0
	p.VY = 0
	p.R = 0
	p.VR = 0
	p.S = 1
	p.VS = 0
	p.JX = 0
	p.JY = 0
	p.Rest = true
	p.Impacted = true
	resetSway(p) -- inferred equivalent call
end

local function stepFade(state, p)
	local breakFadeTimes, v67 = getBreakFadeTimes() -- inferred equivalent call

	if state.Mode == "fadein" then
		state.A = math.min(1, state.A + p / v67)
		state.RA = math.min(1, state.RA + p / (v67 * 1.2))
		state.Settled = state.A >= 1 and state.RA >= 1
	else
		state.A = math.max(0, state.A - p / breakFadeTimes)
		state.RA = math.max(0, state.RA - p / (breakFadeTimes * 1.3))
		state.Settled = state.A <= 0 and state.RA <= 0
	end
end

local function stepAppear(k, state, p)
	local appear = state.Style.Appear
	state.SwayT += p

	state.VX += (appear.XK * (0 - state.X) - appear.XC * state.VX) * p
	state.X += state.VX * p

	if state.Rest then
		state.Y = 0
		state.VY = 0
		state.SwayK = 0
	else
		state.VY += appear.Gravity * p
		state.Y += state.VY * p

		if state.Y >= 0 and state.VY > 0 then
			local vy = state.VY
			state.Y = 0
			state.VY = -vy * appear.Restitution

			if state.Impacted then
				if vy > 160 then
					playMiniLandFx(state, k)
				end
			else
				state.Impacted = true
				state.VS += appear.Pop
				state.VR *= 0.5
				playLandFx(state, k)
			end

			if vy < math.max(90, appear.Gravity * p * 2) then
				state.VY = 0
				state.Rest = true
			end
		end

		state.SwayK = math.clamp(-state.Y / 40, 0, 1)
	end

	state.VR += (appear.RK * (0 - state.R) - appear.RC * state.VR) * p
	state.R += state.VR * p
	state.VS += (appear.SK * (1 - state.S) - appear.SC * state.VS) * p
	state.S += state.VS * p

	state.A = math.min(1, state.A + p / appear.AlphaTime)
	state.RA = math.min(1, state.RA + p / (appear.RailTime or appear.AlphaTime * 1.6))

	if not state.Rest or math.abs(state.X) > 12 then
		emitTrail(state, k, p, appear.Trail, appear.TrailRate or 0.05)
	end

	local settled = state.Rest

	if settled then
		if
			state.A >= 1
			and state.RA >= 1
			and math.abs(state.X) < 0.3
			and math.abs(state.VX) < 2
			and math.abs(state.R) < 0.3
			and math.abs(state.VR) < 2
			and math.abs(state.S - 1) < 0.005
		then
			settled = math.abs(state.VS) < 0.05
		else
			settled = false
		end
	end

	if settled then
		state.X = 0
		state.VX = 0
		state.Y = 0
		state.VY = 0
		state.R = 0
		state.VR = 0
		state.S = 1
		state.VS = 0
		state.SwayK = 0
	end

	state.Settled = settled
end

local function stepScatter(k, state, p)
	local out = state.Style.Out
	state.T += p
	state.SwayT += p

	local shake = out.Shake or 0

	if state.T < shake then
		state.JX = random:NextNumber(-3.5, 3.5)
		state.JY = random:NextNumber(-2.5, 2.5)
	else
		state.JX = 0
		state.JY = 0

		if not state.Launched then
			state.Launched = true
			local floorY

			if out.FloorMin then
				floorY = random:NextNumber(out.FloorMin, out.FloorMax) or nil
			end

			state.FloorY = floorY
			state.VX = state.Dir * random:NextNumber(out.VXMin, out.VXMax)
			state.VY = -random:NextNumber(out.VYMin, out.VYMax)
			local number = random:NextNumber(out.SpinMin, out.SpinMax)

			if random:NextNumber() < 0.2 then
				number = -number
			end

			state.VR = state.Dir * number
			resetSway(state, out.SwayAmp, out.SwayFreq) -- inferred equivalent call
			state.SwayT = 0
			playScatterFx(state, k)
		end

		state.VY += out.Gravity * p
		state.Y += state.VY * p
		state.X += state.VX * p
		state.R += state.VR * p

		state.VX *= math.exp(-(out.Drag or 0) * p)
		state.VR *= math.exp(-0.5 * p)

		if state.FloorY and state.Y >= state.FloorY and state.VY > 0 then
			local vy = state.VY
			state.Y = state.FloorY
			state.VY = -vy * out.Restitution
			state.VX *= 0.82
			state.VR *= 0.7

			if vy > 180 then
				playMiniLandFx(state, k)
			end
		end

		if state.T - shake > out.FadeDelay then
			state.A = math.max(0, state.A - p / out.FadeTime)
			state.RA = math.max(0, state.RA - p / (out.RailFadeTime or out.FadeTime * 1.5))
		end

		state.S = out.EndScale + (1 - out.EndScale) * state.A
		state.SwayK = state.A

		emitTrail(state, k, p, out.Trail, out.TrailRate or 0.05)
	end
end

local function stepReceptors(p)
	local v67 = math.min(p, 1 / 30)
	local v68 = v67 * v64.Tempo
	local v69 = 1 / v64.Tempo
	local now = os.clock()
	local v70 = false

	for k, v71 in pairs(v45) do
		local v72 = v71.StartAt <= now
		local v73 = v71.Entrance and v67 or v68
		v65 = v71.Entrance and 1 or v69
		local v74

		if v72 then
			if v71.Mode == "fadein" or v71.Mode == "fadeout" then
				stepFade(v71, v67)
				v74 = v71.Settled
			elseif v71.Mode == "in" then
				stepAppear(k, v71, v73)
				v74 = v71.Settled
			else
				stepScatter(k, v71, v73)

				if v71.A <= 0 then
					v74 = v71.RA <= 0
				else
					v74 = false
				end
			end
		else
			v74 = false
		end

		local v76 = v44 == false and v37[k] and 1 or 0
		local peekP = v71.PeekP or 0

		if peekP ~= v76 then
			if peekP < v76 then
				peekP = math.min(1, peekP + v67 / 0.12)
			else
				peekP = math.max(0, peekP - v67 / 0.5)
			end

			v71.PeekP = peekP
			v71.Peek = 0.35 * (peekP * peekP * (3 - 2 * peekP))
		end

		v70 = peekP > 0 or v76 > 0 or (not v74 or v70)
		applyReceptorState(v71)
	end

	v65 = v69

	if v70 then
		return
	end

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if v44 then
		unwrapReceptors()
		return
	end

	for _, v71 in pairs(v45) do
		v71.Group.Visible = false
	end
end

local function startReceptorTransition(target, p, value)
	for k in pairs(v28) do
		wrapReceptor(k)
	end

	computeReceptorGeometry()

	local v67 = v64.Style
	local v68 = v64.Tempo

	if target and p then
		v67 = v63
		v68 = 1
	end

	local now = os.clock()

	for _, v69 in pairs(v45) do
		v69.Group.Visible = true

		if target and p then
			prepareAppear(v69, now + (value or 0) + appearDelay(v69, v67.Appear) / v68, v67) -- inferred equivalent call
		else
			prepareFade(v69, now, target, v67)
		end

		applyReceptorState(v69)
	end

	if not (target and p) then
		local breakFadeTimes, v70 = getBreakFadeTimes() -- inferred equivalent call
		breakFadeTimes = target and v70 or breakFadeTimes
		print(("[ReceptorFade v2] %s tombol | BPM=%s | durasi %.1f dtk"):format(
			target and "MUNCUL" or "HILANG",
			tostring(v64.Bpm),
			breakFadeTimes
		))
	end

	if not renderSteppedConnection then
		local RunService = game:GetService("RunService")
		renderSteppedConnection = RunService.RenderStepped:Connect(stepReceptors)
	end
end

local function beginReceptorEntrance(value)
	if not track or next(v28) == nil then
		return
	end

	v44 = true
	startReceptorTransition(true, true, value or 0)
end

function NoteLaneUI.SetReceptorsVisible(p)
	local v67 = p and true or false

	if v67 == v44 then
		return
	end

	v44 = v67

	if not track or next(v28) == nil then
		return
	end

	startReceptorTransition(v67, false)
end

function NoteLaneUI:Show(p, p2, p3, p4, value)
	v19.rock()
	v19.scoreUI()

	if value then
		resetPerformanceForm() -- inferred equivalent call
	end

	build()
	buildTrack(self, p, p2, p3, p4)
	noteLaneUI.Enabled = true

	if value and self ~= "Calibrate" then
		local v67 = type(value) == "number" and math.max(0, value) or 0

		if track then
			if next(v28) == nil then
				return
			end

			v44 = true
			startReceptorTransition(true, true, v67 or 0)
		end
	end
end

function NoteLaneUI.Hide()
	if not noteLaneUI then
		return
	end

	noteLaneUI.Enabled = false
	clearTrack()
	v31 = nil
	v32 = nil
	v35 = nil
	activeLaneCount = nil
	v36 = nil
	v37 = {}
	resetPerformanceForm() -- inferred equivalent call
	v54 = nil
	v58 = nil
	v24 = false

	if v25 then
		v25(false)
	end

	if instrumentNameLabel then
		instrumentNameLabel.Visible = false
	end

	if v39 then
		v39:Reset()
	else
		NoteLaneUI.HideCountdown()
	end
end

function NoteLaneUI.SyncNotes(list, p)
	v58 = p

	if not (track and track.Visible) then
		return
	end

	local v67 = effectiveApproachTime() -- inferred equivalent call
	local set = {}
	local laneSet = {}
	v59 = laneSet

	local RhythmVibratoWave2D = require(ReplicatedStorage.Modules.RhythmVibratoWave2D)
	RhythmVibratoWave2D.BeginFrame()
	local v68 = -1000000000

	for _, item in ipairs(list) do
		local v69 = item.Time + (item.Duration or 0)
		local v70 = item.Time - v68

		if v68 < v69 then
			v68 = v69
		end

		local v71 = not (item._judged or item._hidden)

		if v71 then
			if item.Time - p <= v67 then
				v71 = p <= v69 + RhythmEngineConfig.MissWindow
			else
				v71 = false
			end
		end

		if not v71 then
			continue
		end

		local _ = item.Time < 2

		local parent = v27[item.Lane]

		if not parent then
			continue
		end

		set[item] = true

		if item._holding == true then
			laneSet[item.Lane] = true
		end

		local v73 = v30[item]

		if not v73 then
			local accentColorForLane = getAccentColorForLane(item.Lane) -- inferred equivalent call
			local noteInnerColorForLane = getNoteInnerColorForLane(item.Lane) -- inferred equivalent call
			local holdBar

			if item.Duration and item.Duration > 0 then
				holdBar = Instance.new("Frame")
				holdBar.Name = "HoldBar"
				holdBar.AnchorPoint = Vector2.new(0.5, 0)
				holdBar.BackgroundColor3 = accentColorForLane
				holdBar.BackgroundTransparency = 0.5
				holdBar.BorderSizePixel = 0
				holdBar.ZIndex = 1
				holdBar.Parent = parent

				local uiCorner = Instance.new("UICorner")
				uiCorner.CornerRadius = UDim.new(1, 0)
				uiCorner.Parent = holdBar

				local holdGlowStroke = Instance.new("UIStroke")
				holdGlowStroke.Name = "HoldGlowStroke"
				holdGlowStroke.Color = color6
				holdGlowStroke.Thickness = 0
				holdGlowStroke.Transparency = 0
				holdGlowStroke.Parent = holdBar
			end

			local gem = makeGem(
				parent,
				v19.noteW or v9,
				accentColorForLane,
				noteInnerColorForLane,
				v35,
				2,
				v19.noteH or v9
			)

			gem.AnchorPoint = Vector2.new(0.5, 0.5)
			gem.BackgroundTransparency = 0.05

			v73 = {
				Gem = gem,
				HoldBar = holdBar,
				AccentColor = accentColorForLane,
				OriginalAccentColor = accentColorForLane,
				FadeK = 0,
				FadeDur = v19.NOTE_BREAK_GAP <= v70 and math.clamp(v67 * 0.55, 0.55, 1.2) or math.clamp(v67 * 0.14, 0.12, 0.25)
			}

			v30[item] = v73

			if v24 then
				v73.AccentColor = StarPowerVisualEffects.ENERGY_COLOR
				StarPowerVisualEffects.TintProperty(gem, "BackgroundColor3", StarPowerVisualEffects.ENERGY_COLOR)
			end
		end

		local v74 = timeToY(item.Time - p, v67) -- inferred equivalent call

		if v73.FadeK < 1 then
			local v75 = math.clamp((v67 - (item.Time - p)) / v73.FadeDur, 0, 1)
			local fadeK = v75 * v75 * (3 - v75 * 2)
			v73.FadeK = fadeK
			v19.noteFadeSet(v73, fadeK)

			if fadeK >= 1 then
				v73.FadeList = nil
			end
		end

		v73.Gem.Position = UDim2.new(0.5, 0, 0, v74)
		local v75

		if v73.HoldBar == nil then
			v75 = false
		else
			v75 = item._holding == true
		end

		if v73.Gem.Visible == v75 then
			v73.Gem.Visible = not v75
		end

		if not v73.HoldBar then
			continue
		end

		local v76 = timeToY(v69 - p, v67) -- inferred equivalent call

		if v75 then
			local v77 = hitLineY - v76
			v73.HoldBar.Visible = v77 > 0
			v73.HoldBar.Position = UDim2.new(0.5, 0, 0, v76)
			v73.HoldBar.Size = UDim2.new(0, v10, 0, (math.max(v77, 0)))
		else
			v73.HoldBar.Visible = true
			local v77 = math.min(v74, v76)
			local v78 = math.max(math.abs(v74 - v76), 2)
			v73.HoldBar.Position = UDim2.new(0.5, 0, 0, v77)
			v73.HoldBar.Size = UDim2.new(0, v10, 0, v78)
		end

		local holdGlowStroke = v73.HoldBar:FindFirstChild("HoldGlowStroke")

		if item._holding then
			v73.HoldBar.BackgroundColor3 = color6
			v73.HoldBar.BackgroundTransparency = 0.05

			if holdGlowStroke then
				holdGlowStroke.Thickness = 3
			end
		else
			v73.HoldBar.BackgroundColor3 = v73.AccentColor
			v73.HoldBar.BackgroundTransparency = 0.5

			if holdGlowStroke then
				holdGlowStroke.Thickness = 0
			end
		end

		local v77 = hitLineY - v76

		if v75 and v77 > 4 and RhythmVibratoWave2D.Draw(v73, parent, v76, v77, hitLineY, v10, color6) then
			v73.HoldBar.BackgroundTransparency = 1

			if holdGlowStroke then
				holdGlowStroke.Thickness = 0
			end
		else
			RhythmVibratoWave2D.Hide(v73)
		end

		if v73.FadeK < 1 then
			v73.HoldBar.BackgroundTransparency = 1 - (1 - v73.HoldBar.BackgroundTransparency) * v73.FadeK
		end
	end

	RhythmVibratoWave2D.ReportHold(next(laneSet) ~= nil)

	for k, v69 in pairs(v30) do
		if set[k] then
			continue
		end

		if v69.Gem then
			v69.Gem:Destroy()
		end

		if v69.HoldBar then
			v69.HoldBar:Destroy()
		end

		local RhythmVibratoWave2D2 = require(ReplicatedStorage.Modules.RhythmVibratoWave2D)
		RhythmVibratoWave2D2.Destroy(v69)
		v30[k] = nil
	end
end

function NoteLaneUI.ShowJudgment(p, value, p2, p3, p4)
	if not p4 then
		feedPerformance(value, p2, p3) -- inferred equivalent call
		local rock = v19.rock()

		if rock then
			rock.OnJudgment(value, p2)
		end
	end

	auraPulse(p, value, p2)
	local parent = v28[p]

	if parent then
		local gem = parent:FindFirstChild("Gem")
		local uiStroke = gem and gem:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			local color9 = uiStroke.Color
			uiStroke.Color = p2 and color5 or getJudgmentColor(value) or color9 -- inferred equivalent call
			task.delay(0.25, function()
				if uiStroke and uiStroke.Parent then
					uiStroke.Color = color9
				end
			end)
		end

		if not p2 and value ~= "Miss" and value ~= "Wrong" then
			local v68 = getJudgmentColor(value) or color4 -- inferred equivalent call

			if SettingsState.GetHitSparkleEnabled() then
				spawnLightningBurst(parent, v68)
			end

			if SettingsState.GetHitEffectEnabled() then
				local v69 = parent.AbsolutePosition + parent.AbsoluteSize / 2
				local v70 = v69.X - glowLayer.AbsolutePosition.X
				local v71 = v69.Y - glowLayer.AbsolutePosition.Y
				ScreenGlowEffect.Spawn(glowLayer, Vector2.new(v70, v71), v68)
			end
		end
	end

	if not bigJudgmentLabel then
		return
	end

	count += 1
	local v68 = count

	bigJudgmentLabel.Text = p2 and "AUTO" or string.upper(value)
	bigJudgmentLabel.TextColor3 = p2 and color5 or getJudgmentColor(value) or color2 -- inferred equivalent call
	bigJudgmentLabel.TextTransparency = 0
	bigJudgmentLabel.TextStrokeTransparency = 0.2
	uiScale.Scale = 1.3

	if SettingsState.GetJudgmentPopEnabled() then
		TweenService:Create(uiScale, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
	else
		uiScale.Scale = 1
	end

	task.delay(0.4, function()
		if v68 ~= count then
			return
		end

		TweenService:Create(bigJudgmentLabel, TweenInfo.new(0.25), {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()
	end)
end

function NoteLaneUI.GetHitLineRect()
	if track and track.Visible then
		local absolutePosition = track.AbsolutePosition
		local absoluteSize = track.AbsoluteSize
		return absolutePosition.X, absolutePosition.Y + hitLineY, absoluteSize.X
	end

	return nil
end

function NoteLaneUI.GetReceptorPoints()
	if not (track and track.Visible) then
		return nil
	end

	local result = {}

	for _, v67 in pairs(v28) do
		if not (v67 and v67.Parent and v67.Visible) then
			continue
		end

		local absolutePosition = v67.AbsolutePosition
		local absoluteSize = v67.AbsoluteSize
		result[#result + 1] = {
			X = absolutePosition.X + absoluteSize.X / 2,
			Y = absolutePosition.Y + absoluteSize.Y / 2,
			R = math.min(absoluteSize.X, absoluteSize.Y) / 2
		}
	end

	return result
end

function NoteLaneUI.ShatterStreakNotice(p)
	local v67 = NoteLaneUI.ShowStreakNotice("__EnsureOnly")

	if v67 then
		v67:Shatter(p, SettingsState.GetHitSparkleEnabled())
	end
end

function NoteLaneUI.SetStarPowerPromptCharge(p, p2)
	if NoteLaneUI._streakFx then
		NoteLaneUI._streakFx:SetPromptCharge(p, p2)
	end
end

function NoteLaneUI.DismissStreakNotice(p)
	if NoteLaneUI._streakFx then
		NoteLaneUI._streakFx:Dismiss(p)
	end
end

function NoteLaneUI.ShowStreakNotice(p, p2)
	if not (track and track.Visible) then
		return
	end

	local streakNoticeGui = NoteLaneUI._streakGui

	if not (streakNoticeGui and streakNoticeGui.Parent) then
		streakNoticeGui = Instance.new("ScreenGui")
		streakNoticeGui.Name = "StreakNoticeGui"
		streakNoticeGui.ResetOnSpawn = false
		streakNoticeGui.DisplayOrder = 20
		streakNoticeGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		local container = Instance.new("Frame")
		container.Name = "Container"

		local GuiFade = require(ReplicatedStorage.Modules.GuiFade)
		GuiFade.Attach(container, "StreakNotice", nil, GuiFade.Presets.TextContent)
		container.BackgroundTransparency = 1
		container.BorderSizePixel = 0
		container.Size = UDim2.fromScale(1, 1)
		container.Parent = streakNoticeGui
		local Players2 = game:GetService("Players")
		streakNoticeGui.Parent = Players2.LocalPlayer:WaitForChild("PlayerGui")
		NoteLaneUI._streakGui = streakNoticeGui

		if NoteLaneUI._streakFx then
			NoteLaneUI._streakFx:Reset()
			NoteLaneUI._streakFx = nil
		end
	end

	local container = streakNoticeGui.Container
	local streakFx = NoteLaneUI._streakFx

	if not streakFx or streakFx.Track ~= container then
		if streakFx then
			streakFx:Reset()
		end

		local StreakNoticeFx = require(ReplicatedStorage.Modules.StreakNoticeFx)
		local attach = StreakNoticeFx.Attach
		local v68 = {
			CenterY = math.floor(hitLineY * 0.27),
			PromptPlaceFn = 0,
			StrikeTargetFn = 0,
			PlaceFn = 0
		}

		local StreakNoticeFx2 = require(ReplicatedStorage.Modules.StreakNoticeFx)
		v68.PromptPlaceFn = StreakNoticeFx2.MakeTopCenterPlace(container, function()
			return track and track.Visible and track.AbsolutePosition.Y or nil
		end)

		function v68.StrikeTargetFn()
			return NoteLaneUI.GetHitLineRect()
		end

		function v68.PlaceFn(p3, p4)
			local success, result = pcall(function()
				return require(script.Parent:WaitForChild("BandScoreUI", 2))
			end)

			if success and result and result.GetNoticeSlot then
				local noticeSlot, v69, v70 = result.GetNoticeSlot()

				if noticeSlot then
					local absolutePosition = container.AbsolutePosition

					local v71 = not (v70 and v70 > 0) and 1 or math.clamp(v70 / p3, 0.5, 1)

					return noticeSlot - absolutePosition.X, v69 - p4 * v71 / 2 - absolutePosition.Y, v70
				end
			end

			local StarPowerUI = require(ReplicatedStorage.Modules.StarPowerUI)
			local barRect, v69 = StarPowerUI.GetBarRect()
			local absolutePosition = container.AbsolutePosition
			local x = container.AbsoluteSize.X
			local v70, v71

			if barRect and v69 then
				v70 = barRect.X + v69.X + 40
				v71 = barRect.Y + v69.Y / 2
			else
				local absolutePosition2 = track.AbsolutePosition
				local absoluteSize = track.AbsoluteSize
				v70 = absolutePosition2.X + absoluteSize.X + 12 + 24 + 40
				v71 = absolutePosition2.Y + absoluteSize.Y * 0.5
			end

			return v70 - absolutePosition.X, v71 - absolutePosition.Y, x - v70 - 10
		end

		streakFx = attach(container, v68)

		NoteLaneUI._streakFx = streakFx
	end

	if p == "__EnsureOnly" then
		return streakFx
	end

	streakFx:Show(p, p2, {
		Sparkle = SettingsState.GetHitSparkleEnabled()
	})
end

function NoteLaneUI.ShowCountdown(p, p2, p3, p4, p5)
	if v39 then
		v39:Show(p, p2, p3, p4, p5)
		return
	end

	if not breakCountdownLabel then
		return
	end

	breakCountdownLabel.Visible = true
	breakCountdownCaption.Visible = true
	breakCountdownLabel.Text = tostring((math.max(1, (math.ceil(p)))))
end

function NoteLaneUI.HideCountdown()
	if v39 then
		v39:Hide()
		return
	end

	if breakCountdownLabel then
		breakCountdownLabel.Visible = false
	end

	if breakCountdownCaption then
		breakCountdownCaption.Visible = false
	end
end

function NoteLaneUI.SetStarPowerAtmosphere(p)
	if v25 then
		v25(p)
	end
end

function NoteLaneUI.SetStarPowerVisual(p)
	v24 = p
	local rock = v19.rock()

	if rock then
		rock.SetStarPowerActive(p)
	end

	local scoreUI = v19.scoreUI()

	if scoreUI then
		scoreUI.SetStarPowerActive(p)
	end

	local success, result = pcall(function()
		return require(script.Parent:WaitForChild("BandScoreUI", 5))
	end)

	if success and result then
		result.SetStarPowerActive(p)
	end

	for k, v67 in pairs(v28) do
		local gem = v67:FindFirstChild("Gem")
		local ENERGY_COLOR = p and StarPowerVisualEffects.ENERGY_COLOR or v26[k]

		if gem and ENERGY_COLOR then
			StarPowerVisualEffects.TintProperty(gem, "BackgroundColor3", ENERGY_COLOR)
		end
	end

	for _, v67 in pairs(v30) do
		local ENERGY_COLOR = p and StarPowerVisualEffects.ENERGY_COLOR or v67.OriginalAccentColor

		if not ENERGY_COLOR then
			continue
		end

		v67.AccentColor = ENERGY_COLOR
		StarPowerVisualEffects.TintProperty(v67.Gem, "BackgroundColor3", ENERGY_COLOR)
	end
end

function NoteLaneUI.SetKickBeats(list)
	v54 = if type(list) == "table" and #list > 0 then list else nil

	v55 = 1
	v56 = -1000000000
	v57 = -1000000000
end

function NoteLaneUI.GetKeyAuraStyle(): string
	return if v53 then "Blade" else "Warm"
end

function NoteLaneUI.GetPerformanceForm()
	return total, v47, v48
end

function v19.receptorColor(p, p2)
	if v24 then
		local ENERGY_COLOR = StarPowerVisualEffects.ENERGY_COLOR
		return p2 and ENERGY_COLOR:Lerp(Color3.new(1, 1, 1), 0.3) or ENERGY_COLOR
	elseif p2 then
		return receptorPressColorForLanes[p]
	else
		return v38[p]
	end
end

function NoteLaneUI.SetLanePressed(p, p2)
	local v67 = v28[p]

	if not v67 then
		return
	end

	local gem = v67:FindFirstChild("Gem")

	if not gem then
		return
	end

	local uiScale2 = gem:FindFirstChildOfClass("UIScale")

	if p2 then
		local v68 = v44 == false and v45[p]

		if v68 then
			v68.Group.Visible = true

			if not renderSteppedConnection then
				local RunService = game:GetService("RunService")
				renderSteppedConnection = RunService.RenderStepped:Connect(stepReceptors)
			end
		end

		v37[p] = true
		gem.BackgroundColor3 = v19.receptorColor(p, true) or gem.BackgroundColor3
		gem.BackgroundTransparency = 0.05

		if uiScale2 then
			uiScale2.Scale = 1.15
		end
	else
		v37[p] = false
		gem.BackgroundColor3 = v19.receptorColor(p, false) or gem.BackgroundColor3
		gem.BackgroundTransparency = effectiveIdleTransparency() -- inferred equivalent call

		if uiScale2 then
			uiScale2.Scale = 1
		end
	end
end

function NoteLaneUI.IsVisible()
	return noteLaneUI ~= nil and noteLaneUI.Enabled
end

return NoteLaneUI