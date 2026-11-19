local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiFade = require(script.Parent:WaitForChild("GuiFade"))
local UserInputService = game:GetService("UserInputService")

local StarPowerUI = {}

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function fontOr(p, p2) -- 2 equivalent calls inferred from this helper
	local success, result = pcall(function()
		return Enum.Font[p]
	end)
	return success and result or p2
end

local GothamBlack = Enum.Font.GothamBlack
GothamBlack = fontOr("PermanentMarker", GothamBlack) -- inferred equivalent call
local GothamBold = Enum.Font.GothamBold
GothamBold = fontOr("SpecialElite", GothamBold) -- inferred equivalent call
local v2 = v and 18 or 24
local v3 = v and 190 or 250
local v4 = v and 300 or 440
local v5 = v and 18 or 12
local v6 = v and 14 or 22
local v7 = v and 15 or 19
local v8 = v and 3 or 4
local v9 = v and 14 or 20
local v10 = v and 4 or 6
local v11 = v and 12 or 20
local v12 = {
	Plate = Color3.fromRGB(26, 25, 23),
	Edge = Color3.fromRGB(122, 120, 114),
	Rust = Color3.fromRGB(104, 58, 34),
	Well = Color3.fromRGB(8, 8, 9),
	Tape = Color3.fromRGB(206, 190, 150),
	TapeDark = Color3.fromRGB(140, 126, 96),
	Ink = Color3.fromRGB(20, 18, 16),
	Bone = Color3.fromRGB(222, 220, 214),
	Dim = Color3.fromRGB(74, 72, 66),
	DeniedTape = Color3.fromRGB(150, 52, 40),
	White = Color3.new(1, 1, 1)
}

local color = Color3.fromRGB(75, 200, 220)
local color2 = Color3.fromRGB(200, 245, 255)
local color3 = Color3.fromRGB(235, 252, 255)
local color4 = Color3.fromRGB(255, 132, 44)
local color5 = Color3.fromRGB(60, 170, 235)

local v13 = {
	{ 0, Color3.fromRGB(150, 40, 34) },
	{ 0.25, Color3.fromRGB(190, 92, 34) },
	{ 0.5, Color3.fromRGB(212, 168, 50) },
	{ 0.75, Color3.fromRGB(128, 168, 58) },
	{ 1, Color3.fromRGB(54, 160, 92) }
}

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v14 = v and 22 or 60
local v15 = v and 12 or 30
local v16 = v and 3 or 8
local v17 = v and 4 or 6
local v18 = v and 1 or 1.4
local v19 = v and 1 or 1.25
local starPowerUI = nil
local meterContainer = nil
local v20 = nil
local parent2 = nil
local v21 = nil
local parent3 = nil
local parent4 = nil
local parent5 = nil
local v22 = nil
local v23 = nil
local v24 = nil
local v25 = nil
local v26 = nil
local v27 = nil
local v28 = nil
local v29 = nil
local activationLabel = nil
local uiScale = nil
local v30 = nil
local v31 = nil
local v32 = nil
local v37 = nil
local v38 = nil
local v39 = {}
local v40 = {}
local v41 = {}
local v42 = nil

local flag = false
local v43 = 0.5
local v44 = 0
local v45 = 0
local v46 = { L1 = 0.33, L2 = 0.6, L3 = 0.9 }
local v47 = 0
local v48 = 0
local v49 = 0

local v50 = nil
local v51 = nil
local v52 = nil
local count = 0
local flag2 = false
local v53 = true
local count2 = 0
local v54 = nil
local count3 = 0
local count4 = 0
local v55 = 0
local flag3 = false

local v56 = {}
local v57 = {}
local v58 = 0
local v59 = 0
local v60 = 0
local v61 = { spark = 0, ember = 0, bolt = 0, crackle = 0 }
local v62 = 0
local heartbeatConnection = nil

local function rnd(p, p2) -- 81 equivalent calls inferred from this helper
	return p + math.random() * (p2 - p)
end

local function skillToColor(value)
	local v63 = math.clamp(value or 0.5, 0, 1)

	for i = 1, #v13 - 1 do
		local v64 = v13[i][1]
		local v65 = v13[i][2]
		local v66 = v13[i + 1][1]
		local v67 = v13[i + 1][2]

		if v63 <= v66 then
			return v65:Lerp(v67, v66 - v64 > 0 and (v63 - v64) / (v66 - v64) or 0)
		end
	end

	return v13[#v13][2]
end

local function chargeUpColor(p, p2, p3) -- 15 equivalent calls inferred from this helper
	local hsv, v63, v64 = p:ToHSV()
	return Color3.fromHSV(hsv, math.clamp(v63 + p2, 0, 1), (math.clamp(v64 + p3, 0, 1)))
end

local function addCorner(parent, p) -- 2 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, p)
	uiCorner.Parent = parent
	return uiCorner
end

local function addCircle(parent) -- 4 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = parent
	return uiCorner
end

local function addStroke(parent, color6, thickness, value) -- 8 equivalent calls inferred from this helper
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color6
	uiStroke.Thickness = thickness
	uiStroke.Transparency = value or 0
	uiStroke.Parent = parent
	return uiStroke
end

local function newFrame(parent, name, value) -- 26 equivalent calls inferred from this helper
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BorderSizePixel = 0
	frame.ZIndex = value or 1
	frame.Parent = parent
	return frame
end

local function placeLine(p, p2, p3, p4, p5, p6)
	local v63 = p4 - p2
	local v64 = p5 - p3
	p.AnchorPoint = Vector2.new(0.5, 0.5)
	p.Position = UDim2.fromOffset((p2 + p4) / 2, (p3 + p5) / 2)
	p.Size = UDim2.fromOffset(math.sqrt(v63 * v63 + v64 * v64) + 0.5, p6)
	p.Rotation = math.deg((math.atan2(v64, v63)))
end

local function acquire(zIndex) -- 4 equivalent calls inferred from this helper
	local selected = table.remove(v57)

	if not selected then
		selected = Instance.new("Frame")
		selected.AnchorPoint = Vector2.new(0.5, 0.5)
		selected.BorderSizePixel = 0
	end

	selected.ZIndex = zIndex
	selected.Rotation = 0
	selected.Visible = true
	selected.Parent = parent5
	return selected
end

local function release(p) -- 4 equivalent calls inferred from this helper
	p.Visible = false
	v57[#v57 + 1] = p
end

local function clearParticles()
	v56 = {}
	v58 = 0
	v59 = 0
	v60 = 0
	v57 = {}

	if parent5 then
		for _, child in ipairs(parent5:GetChildren()) do
			child.Visible = false
			v57[#v57 + 1] = child
		end
	end
end

local function emitSpark(total, total2, p, p2, p3, p4, p5, p6, p7)
	if parent5 then
		local v63 = v58

		if not (v14 * (p7 and 2 or 1) <= v63) then
			v58 += 1
			local v64 = p2 * v19
			local v65 = acquire(11) -- inferred equivalent call
			local v66 = math.cos(p) * v64
			local v67 = math.sin(p) * v64
			local total3 = 0
			v56[#v56 + 1] = function(p8): boolean
				total3 += p8

				if p3 <= total3 then
					v58 -= 1
					release(v65) -- inferred equivalent call
					return false
				else
					local v68 = math.exp(-2.4 * p8)
					v66 *= v68
					v67 = v67 * v68 + 380 * p8
					total += v66 * p8
					total2 += v67 * p8
					local v69 = total3 / p3
					local v70 = math.sqrt(v66 * v66 + v67 * v67)
					v65.Position = UDim2.fromOffset(total, total2)
					v65.Rotation = math.deg((math.atan2(v67, v66)))
					v65.Size = UDim2.fromOffset(math.clamp(v70 * 0.045, 3, 22), (math.max(1.5, p4 * (1 - v69 * 0.5))))
					v65.BackgroundColor3 = p5:Lerp(p6, (math.clamp(v69 * 1.5, 0, 1)))
					v65.BackgroundTransparency = v69 * v69 * 0.95
					return true
				end
			end
		end
	end
end

local function emitEmber(total, total2, backgroundColor, value)
	if not parent5 or v15 <= v59 then
		return
	end

	v59 += 1
	local v63 = acquire(10) -- inferred equivalent call
	local v64 = rnd(2, v and 3 or 4) -- inferred equivalent call
	v63.Size = UDim2.fromOffset(v64, v64)
	v63.Rotation = rnd(0, 90) -- inferred equivalent call
	v63.BackgroundColor3 = backgroundColor
	local v65 = (value or -1) * rnd(26, 80) -- inferred equivalent call
	local v66 = rnd(-12, 12) -- inferred equivalent call
	local v67 = rnd(0.7, 1.4) -- inferred equivalent call
	local total3 = 0
	local v68 = rnd(0, 6.28) -- inferred equivalent call

	v56[#v56 + 1] = function(p): boolean
		total3 += p

		if v67 <= total3 then
			v59 -= 1
			release(v63) -- inferred equivalent call
			return false
		else
			total += (v66 + math.sin(total3 * 6 + v68) * 14) * p
			total2 += v65 * p
			local v69 = total3 / v67
			v63.Position = UDim2.fromOffset(total, total2)
			v63.BackgroundTransparency = math.clamp(v69 * v69 + (math.random() < 0.12 and 0.4 or 0), 0, 1)
			return true
		end
	end
end

local function emitBolt(p, p2, p3, p4, p5, p6, backgroundColor, backgroundColor2, p7, p8)
	if parent5 then
		local v63 = v60

		if not (v16 * (p8 and 2 or 1) <= v63) then
			v60 += 1
			local v64 = p4 * v18
			local v65 = v and 2 or 2.6
			local v66 = {}
			local v67 = {}

			for i = 1, p6 do
				local v68 = acquire(8) -- inferred equivalent call
				v68.BackgroundColor3 = backgroundColor
				v66[i] = v68
				local v69 = acquire(10) -- inferred equivalent call
				v69.BackgroundColor3 = backgroundColor2
				v67[i] = v69
			end

			local v68 = math.cos(p3)
			local v69 = math.sin(p3)
			local v70 = -v69
			local v71 = v64 * 0.2
			local function relayout()
				local v72 = {}
				local v73 = {}

				for i = 0, p6 do
					local v74 = i / p6
					local v75

					if i == 0 then
						v75 = 0
					else
						v75 = rnd(-v71, v71) * (1 - v74 * 0.25) -- inferred equivalent call
					end

					v72[i] = p + v68 * v64 * v74 + v70 * v75
					v73[i] = p2 + v69 * v64 * v74 + v68 * v75
				end

				for i = 1, p6 do
					local v74 = v72[i - 1]
					local v75 = v73[i - 1]
					local v76 = v72[i]
					local v77 = v73[i]
					placeLine(v66[i], v74, v75, v76, v77, v65 * 3)
					placeLine(v67[i], v74, v75, v76, v77, v65)
				end
			end
			relayout()

			if p7 and v64 > 50 then
				local v72 = rnd(0.35, 0.65) -- inferred equivalent call
				local v73 = math.random() < 0.5 and -1 or 1
				emitBolt(
					p + v68 * v64 * v72,
					p2 + v69 * v64 * v72,
					p3 + v73 * rnd(0.6, 1), -- inferred equivalent call
					v64 * 0.5 / v18,
					p5 * 0.85,
					(math.max)(3, p6 - 2),
					backgroundColor,
					backgroundColor2,
					false,
					p8
				)
			end

			local total = 0
			local total2 = 0
			v56[#v56 + 1] = function(p9): boolean
				total += p9
				total2 += p9

				if p5 <= total then
					for i = 1, p6 do
						release(v66[i]) -- inferred equivalent call
						release(v67[i]) -- inferred equivalent call
					end

					v60 -= 1
					return false
				else
					if total2 >= 0.045 then
						total2 = 0
						relayout()
					end

					local v72 = total / p5
					local v73 = math.random() < 0.28 and 0.4 or 0
					local backgroundTransparency = math.clamp(v72 * v72 * 0.9 + v73, 0, 1)
					local backgroundTransparency2 = math.clamp(0.7 + v72 * 0.3 + v73 * 0.3, 0, 1)

					for i = 1, p6 do
						v67[i].BackgroundTransparency = backgroundTransparency
						v66[i].BackgroundTransparency = backgroundTransparency2
					end

					return true
				end
			end
		end
	end
end

local function sparkColors()
	if flag then
		return color3, color4
	end

	local v63 = skillToColor(v43)
	return chargeUpColor(v63, 0.15, 0.45), v63:Lerp(Color3.fromRGB(110, 36, 18), 0.55) -- inferred equivalent call
end

local function boltColors()
	if flag then
		return color5, Color3.fromRGB(225, 248, 255)
	end

	local v63 = skillToColor(v43)
	return v63, chargeUpColor(v63, -0.2, 0.55):Lerp(v12.White, 0.45) -- inferred equivalent call
end

local function radialSparks(p, p2, p3, p4, p5, p6)
	if v47 <= 0 then
		return
	end

	local v63, v64

	if flag then
		v63 = color3
		v64 = color4
	else
		local v65 = skillToColor(v43)
		v63 = chargeUpColor(v65, 0.15, 0.45) -- inferred equivalent call

		v64 = v65:Lerp(Color3.fromRGB(110, 36, 18), 0.55)
	end

	for _ = 1, p do
		emitSpark(rnd(2, v47 - 2), rnd(p2, p3), rnd(0, 6.2832), rnd(p4, p5), rnd(0.35, 0.8), 2.4, v63, v64, p6) -- inferred equivalent call
	end
end

local function sideBolts(p, p2, p3, p4, p5, p6)
	if v47 <= 0 then
		return
	end

	local v63, v64

	if flag then
		v63 = color5
		v64 = Color3.fromRGB(225, 248, 255)
	else
		v63 = skillToColor(v43)
		v64 = chargeUpColor(v63, -0.2, 0.55):Lerp(v12.White, 0.45) -- inferred equivalent call
	end

	for _ = 1, p do
		local v65 = math.random() < 0.5
		local v66 = v65 and 3.141592653589793 + rnd(-0.9, 0.9) or rnd(-0.9, 0.9) -- inferred equivalent call

		emitBolt(v65 and 0 or v47, rnd(p2, p3), v66, rnd(p4, p5), rnd(0.14, 0.26), v17 + 1, v63, v64, true, p6) -- inferred equivalent call
	end
end

local function activationBurst(value) -- 1 equivalent call inferred from this helper
	if v47 <= 0 then
		return
	end

	local v63 = value or 1
	radialSparks((v and 12 or 24) + v63 * 2, v7, v48 - v7, 160, 460, true)
	sideBolts(v and 2 or 5, v7, v48 - v7, 70, 150 + v63 * 8, true)
end

local function finalBurst() -- 1 equivalent call inferred from this helper
	if v47 <= 0 then
		return
	end

	radialSparks(v and 8 or 16, v7, v7 + v49 * 0.5, 120, 340, true)
	sideBolts(v and 1 or 3, v7, v7 + v49 * 0.4, 40, 90, true)
end

local function applyMarkColor(data) -- 2 equivalent calls inferred from this helper
	local reached = data.Reached
	data.Line.BackgroundTransparency = reached and 0.35 or 0.85
	local bone = reached and v12.Bone or v12.Dim
	data.Left.BackgroundColor3 = bone
	data.Right.BackgroundColor3 = bone
end

local function thresholdPop(p)
	if v47 <= 0 then
		return
	end

	local v63 = v7 + v49 * (1 - p.Value)
	local v64, v65

	if flag then
		v64 = color3
		v65 = color4
	else
		local v66 = skillToColor(v43)
		v64 = chargeUpColor(v66, 0.15, 0.45) -- inferred equivalent call

		v65 = v66:Lerp(Color3.fromRGB(110, 36, 18), 0.55)
	end

	for _ = 1, v and 4 or 8 do
		local v66 = math.random() < 0.5
		local v67 = v66 and 3.141592653589793 + rnd(-0.7, 0.7) or rnd(-0.7, 0.7) -- inferred equivalent call

		emitSpark(v66 and 0 or v47, v63, v67 - 0.3, rnd(120, 260), rnd(0.35, 0.65), 2, v64, v65, true) -- inferred equivalent call
	end

	p.Line.BackgroundTransparency = 0
	TweenService:Create(p.Line, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.35
	}):Play()
end

local function readyHintText()
	local v63 = "SPACE / H"
	local success, result = pcall(function()
		local SettingsState = require(script.Parent.SettingsState)
		return SettingsState.GetStarPowerHintText()
	end)

	if success and type(result) == "string" and result ~= "" then
		v63 = result
	end

	return "PRESS " .. v63 .. "  //  READY"
end

local function readyTapeWidth() -- 3 equivalent calls inferred from this helper
	local selected = v and 112 or 134

	if not v28 then
		return selected
	end

	local success, result = pcall(function()
		local TextService = game:GetService("TextService")
		return TextService:GetTextSize(v28.Text, v28.TextSize, v28.Font, Vector2.new(1000, 100))
	end)

	if success and result then
		return (math.max(selected, math.ceil(result.X) + 18))
	end

	return selected
end

local function refreshReadyHint()
	if not v28 then
		return
	end

	local v63 = "SPACE / H"
	local success, result = pcall(function()
		local SettingsState = require(script.Parent.SettingsState)
		return SettingsState.GetStarPowerHintText()
	end)

	if success and type(result) == "string" and result ~= "" then
		v63 = result
	end

	local text = "PRESS " .. v63 .. "  //  READY"

	if v28.Text ~= text then
		v28.Text = text
	end

	v28.Size = UDim2.new(0, readyTapeWidth(), 0, v28.Size.Y.Offset) -- inferred equivalent call
end

local function showReadyText()
	if not v28 then
		return
	end

	if v28 then
		local v63 = "SPACE / H"
		local success, result = pcall(function()
			local SettingsState = require(script.Parent.SettingsState)
			return SettingsState.GetStarPowerHintText()
		end)

		if success and type(result) == "string" and result ~= "" then
			v63 = result
		end

		local text = "PRESS " .. v63 .. "  //  READY"

		if v28.Text ~= text then
			v28.Text = text
		end

		v28.Size = UDim2.new(0, readyTapeWidth(), 0, v28.Size.Y.Offset) -- inferred equivalent call
	end

	count2 += 1
	local v63 = count2
	v28.TextTransparency = 1
	v28.BackgroundTransparency = 1
	TweenService:Create(v28, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		TextTransparency = 0,
		BackgroundTransparency = 0.06
	}):Play()
	v51 = TweenService:Create(v28, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		TextTransparency = 0.45
	})

	task.delay(0.25, function()
		if v63 == count2 and v51 then
			v51:Play()
		end
	end)
end

local function hideReadyText()
	if not v28 then
		return
	end

	count2 += 1

	if v51 then
		v51:Cancel()
		v51 = nil
	end

	TweenService:Create(v28, TweenInfo.new(0.2), {
		TextTransparency = 1,
		BackgroundTransparency = 1
	}):Play()
end

local function stopReadyGlow()
	if not flag2 then
		return
	end

	count += 1
	flag2 = false

	if v50 then
		v50:Cancel()
		v50 = nil
	end

	if parent3 then
		parent3.BackgroundTransparency = 1
	end

	if parent4 and v42 then
		v42:Cancel()
		parent4.Size = UDim2.new(1, 6, 0, 12)
		v42 = TweenService:Create(
			parent4,
			TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ BackgroundTransparency = 0.4 }
		)

		v42:Play()
	end

	hideReadyText()
end

local function startReadyGlow()
	if flag2 then
		return
	end

	count += 1
	flag2 = true
	local backgroundColor = chargeUpColor(skillToColor(v43), 0.2, 0.4) -- inferred equivalent call

	if parent4 and v42 then
		v42:Cancel()
		parent4.Size = UDim2.new(1, 8, 0, 18)
		v42 = TweenService:Create(
			parent4,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ BackgroundTransparency = 0.05 }
		)

		v42:Play()
	end

	if parent3 then
		parent3.BackgroundColor3 = backgroundColor
		parent3.BackgroundTransparency = 0.55
		parent3.Position = UDim2.new(0.5, 0, 1, 0)
		v50 = TweenService:Create(
			parent3,
			TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Position = UDim2.new(0.5, 0, 0, 0) }
		)

		v50:Play()
	end

	if v47 > 0 and starPowerUI and starPowerUI.Enabled then
		local v64, v65

		if flag then
			v64 = color3
			v65 = color4
		else
			local v66 = skillToColor(v43)
			v64 = chargeUpColor(v66, 0.15, 0.45) -- inferred equivalent call

			v65 = v66:Lerp(Color3.fromRGB(110, 36, 18), 0.55)
		end

		for _ = 1, v and 6 or 12 do
			emitSpark(
				v47 / 2 + rnd(-4, 4), -- inferred equivalent call
				v7 + 2,
				-1.5708 + rnd(-1.2, 1.2), -- inferred equivalent call
				rnd(140, 340), -- inferred equivalent call
				rnd(0.4, 0.75), -- inferred equivalent call
				2.2,
				v64,
				v65,
				true
			)
		end

		local v66, v67

		if flag then
			v66 = color5
			v67 = Color3.fromRGB(225, 248, 255)
		else
			v66 = skillToColor(v43)
			v67 = chargeUpColor(v66, -0.2, 0.55):Lerp(v12.White, 0.45) -- inferred equivalent call
		end

		for _ = 1, v and 1 or 3 do
			emitBolt(v47 / 2, v7 + 2, -1.5708 + rnd(-1.1, 1.1), rnd(40, 90), 0.22, v17, v66, v67, true, true) -- inferred equivalent call
		end
	end

	if v53 then
		showReadyText()
	end
end

local function refreshThresholdMarks(p, p2)
	for _, v63 in ipairs(v40) do
		local reached2 = v63.Value - 0.001 <= p

		if v63.Reached == reached2 then
			continue
		end

		local reached = v63.Reached
		v63.Reached = reached2
		applyMarkColor(v63) -- inferred equivalent call

		if reached2 and reached == false and p2 and p2 < v63.Value - 0.001 and v63.Value < 0.999 then
			thresholdPop(v63)
		end
	end

	if (v46.L2 or 0.6) - 0.001 <= p then
		startReadyGlow()
	else
		stopReadyGlow()
	end
end

local function applyIdleFillColor(backgroundColor, p)
	if not parent2 then
		return
	end

	if p then
		backgroundColor = chargeUpColor(backgroundColor, 0.22, 0.2) or backgroundColor -- inferred equivalent call
	end

	parent2.BackgroundTransparency = 0.04
	TweenService:Create(parent2, tweenInfo2, { BackgroundColor3 = backgroundColor }):Play()
	TweenService:Create(v21, tweenInfo2, {
		BackgroundColor3 = chargeUpColor(backgroundColor, 0.1, 0.3) -- inferred equivalent call
	}):Play()

	if parent4 then
		TweenService:Create(parent4, tweenInfo2, {
			BackgroundColor3 = chargeUpColor(backgroundColor, 0.1, 0.4) -- inferred equivalent call
		}):Play()
	end
end

local function applyActiveFillColor()
	if not parent2 then
		return
	end

	TweenService:Create(parent2, tweenInfo3, { BackgroundColor3 = color }):Play()
	TweenService:Create(v21, tweenInfo3, { BackgroundColor3 = color2 }):Play()

	if parent4 then
		TweenService:Create(parent4, tweenInfo3, { BackgroundColor3 = color2 }):Play()
	end
end

local function layoutBar(p)
	v47 = v2
	v48 = p
	v49 = p - 2 * v7

	for _, v63 in ipairs(v40) do
		local v64 = v7 + v49 * (1 - v63.Value)
		v63.Left.Position = UDim2.new(0, 0, 0, v64)
		v63.Right.Position = UDim2.new(1, 0, 0, v64)
		v63.Line.Position = UDim2.new(0.5, 0, 1 - v63.Value, 0)
	end

	local v63 = v and 0.8 or 1
	local v64 = v47 / 2
	local v65 = p - v7 / 2
	local v66 = {
		{ v64 + 2.5 * v63, v65 - 6.5 * v63 },
		{ v64 - 3 * v63, v65 + 0.5 * v63 },
		{ v64 + 0.5 * v63, v65 + 0.5 * v63 },
		{ v64 - 2.5 * v63, v65 + 6.5 * v63 }
	}

	for i = 1, 3 do
		if v39[i] then
			placeLine(v39[i], v66[i][1], v66[i][2], v66[i + 1][1], v66[i + 1][2], v and 1.6 or 2)
		end
	end

	if v37 then
		v37.Position = UDim2.fromOffset(3, 5)
	end

	if v38 then
		v38.Position = UDim2.fromOffset(v47 - 3, p - 5)
	end
end

local function buildTape(name, rotation)
	local tape = newFrame(meterContainer, name, 12) -- inferred equivalent call
	tape.AnchorPoint = Vector2.new(0.5, 0.5)
	tape.Size = UDim2.fromOffset(v9, v10)
	tape.BackgroundColor3 = v12.Tape
	tape.BackgroundTransparency = 0.06
	tape.Rotation = rotation
	tape:SetAttribute("BaseRot", rotation)
	addStroke(tape, v12.TapeDark, 1, 0.35) -- inferred equivalent call
	local frame = newFrame(tape, "Crease", 13) -- inferred equivalent call
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.7, 0, 0, 0)
	frame.Size = UDim2.new(0, 1, 1, 0)
	frame.BackgroundColor3 = v12.TapeDark
	frame.BackgroundTransparency = 0.45
	local frame2 = newFrame(tape, "Fray", 13) -- inferred equivalent call
	frame2.AnchorPoint = Vector2.new(0, 0.5)
	frame2.Position = UDim2.new(0, 0, 0.5, 0)
	frame2.Size = UDim2.new(0, 3, 0.7, 0)
	frame2.BackgroundColor3 = v12.TapeDark
	frame2.BackgroundTransparency = 0.3
	return tape
end

local function buildThresholdMark(p)
	local line = newFrame(v20, "ThresholdLine", 5) -- inferred equivalent call
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.Size = UDim2.new(1, 0, 0, 1.5)
	line.BackgroundColor3 = v12.Bone
	line.BackgroundTransparency = 0.85
	local left = newFrame(meterContainer, "NotchL", 4) -- inferred equivalent call
	left.AnchorPoint = Vector2.new(0, 0.5)
	left.Size = UDim2.fromOffset(v8, 1.5)
	left.BackgroundColor3 = v12.Dim
	local right = newFrame(meterContainer, "NotchR", 4) -- inferred equivalent call
	right.AnchorPoint = Vector2.new(1, 0.5)
	right.Size = UDim2.fromOffset(v8, 1.5)
	right.BackgroundColor3 = v12.Dim

	return {
		Line = line,
		Left = left,
		Right = right,
		Value = p,
		Reached = nil
	}
end

local function buildReadyTape(name, backgroundColor, textColor, textSize, zIndex) -- 2 equivalent calls inferred from this helper
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = name
	textLabel.AnchorPoint = Vector2.new(0.5, 0)
	textLabel.BackgroundColor3 = backgroundColor
	textLabel.BackgroundTransparency = 1
	textLabel.BorderSizePixel = 0
	textLabel.Font = GothamBold
	textLabel.TextSize = textSize
	textLabel.TextColor3 = textColor
	textLabel.TextTransparency = 1
	textLabel.TextStrokeTransparency = 1
	textLabel.ZIndex = zIndex
	textLabel.Parent = starPowerUI
	return textLabel
end

local function build()
	if starPowerUI then
		return
	end

	starPowerUI = Instance.new("ScreenGui")
	starPowerUI.Name = "StarPowerUI"
	starPowerUI.ResetOnSpawn = false
	starPowerUI.Enabled = false
	starPowerUI.Parent = PlayerGui

	meterContainer = Instance.new("Frame")
	meterContainer.Name = "MeterContainer"
	meterContainer.AnchorPoint = Vector2.new(1, 0.5)
	meterContainer.Size = UDim2.new(0, v2, 0, v3)
	meterContainer.BackgroundColor3 = v12.Plate
	meterContainer.BackgroundTransparency = v and 0.12 or 0
	meterContainer.BorderSizePixel = 0
	meterContainer.Active = true
	meterContainer.ClipsDescendants = false
	meterContainer.ZIndex = 1
	meterContainer.Parent = starPowerUI

	GuiFade.Attach(meterContainer, "StarPower", nil, GuiFade.Presets.StarPower)
	addCorner(meterContainer, 2) -- inferred equivalent call
	addStroke(meterContainer, v12.Edge, v and 1.2 or 1.6, 0.2) -- inferred equivalent call
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = 90
	uiGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(205, 200, 195)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 145, 140))
	})

	uiGradient.Parent = meterContainer

	v20 = newFrame(meterContainer, "Well", 2) -- inferred equivalent call
	v20.Position = UDim2.new(0, v8, 0, v7)
	v20.Size = UDim2.new(1, -2 * v8, 1, -2 * v7)
	v20.BackgroundColor3 = v12.Well
	v20.ClipsDescendants = true
	addStroke(v20, v12.Ink, 1, 0.1) -- inferred equivalent call

	parent2 = newFrame(v20, "MeterFill", 2) -- inferred equivalent call
	parent2.AnchorPoint = Vector2.new(0.5, 1)
	parent2.Position = UDim2.new(0.5, 0, 1, 0)
	parent2.Size = UDim2.new(1, 0, 0, 0)
	parent2.BackgroundColor3 = v13[3][2]
	parent2.BackgroundTransparency = 0.04
	parent2.ClipsDescendants = true
	local uiGradient2 = Instance.new("UIGradient")
	uiGradient2.Rotation = 90
	uiGradient2.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 140, 135))
	})

	uiGradient2.Parent = parent2

	parent3 = newFrame(parent2, "EnergyPulse", 3) -- inferred equivalent call
	parent3.AnchorPoint = Vector2.new(0.5, 0.5)
	parent3.Position = UDim2.new(0.5, 0, 1, 0)
	parent3.Size = UDim2.new(1, 0, 0, 16)
	parent3.BackgroundColor3 = color2
	parent3.BackgroundTransparency = 1
	local uiGradient3 = Instance.new("UIGradient")
	uiGradient3.Rotation = 90
	uiGradient3.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.25),
		NumberSequenceKeypoint.new(1, 1)
	})

	uiGradient3.Parent = parent3

	v21 = newFrame(parent2, "FillTip", 5) -- inferred equivalent call
	v21.AnchorPoint = Vector2.new(0.5, 0)
	v21.Position = UDim2.new(0.5, 0, 0, 0)
	v21.Size = UDim2.new(1, 0, 0, 2)
	v21.BackgroundColor3 = v13[3][2]
	v21.BackgroundTransparency = 0.05

	parent4 = newFrame(parent2, "FillEdgeGlow", 4) -- inferred equivalent call
	parent4.AnchorPoint = Vector2.new(0.5, 0.5)
	parent4.Position = UDim2.new(0.5, 0, 0, 0)
	parent4.Size = UDim2.new(1, 6, 0, 12)
	parent4.BackgroundColor3 = v13[3][2]
	parent4.BackgroundTransparency = 0.6
	local uiGradient4 = Instance.new("UIGradient")
	uiGradient4.Rotation = 90
	uiGradient4.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.25),
		NumberSequenceKeypoint.new(1, 1)
	})

	uiGradient4.Parent = parent4
	v42 = TweenService:Create(
		parent4,
		TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ BackgroundTransparency = 0.4 }
	)

	v42:Play()

	for i = 1, v11 - 1 do
		local frame = newFrame(v20, "Cell", 3) -- inferred equivalent call
		frame.AnchorPoint = Vector2.new(0, 0.5)
		frame.Position = UDim2.new(0, 0, i / v11, 0)
		frame.Size = UDim2.new(1, 0, 0, 1)
		frame.BackgroundColor3 = v12.Well
		frame.BackgroundTransparency = 0.05
	end

	local parent = newFrame(v20, "Sheen", 4) -- inferred equivalent call
	parent.Size = UDim2.new(1, 0, 1, 0)
	parent.BackgroundColor3 = Color3.new(0, 0, 0)
	local uiGradient5 = Instance.new("UIGradient")
	uiGradient5.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.3, 1),
		NumberSequenceKeypoint.new(0.7, 1),
		NumberSequenceKeypoint.new(1, 0.25)
	})

	uiGradient5.Parent = parent

	v40 = { buildThresholdMark(v46.L1), buildThresholdMark(v46.L2), buildThresholdMark(v46.L3) }

	v25 = newFrame(meterContainer, "NeonL", 4) -- inferred equivalent call
	v25.Position = UDim2.new(0, v8 - 1, 0, v7)
	v25.Size = UDim2.new(0, 1, 1, -2 * v7)
	v25.BackgroundColor3 = v12.Dim
	v25.BackgroundTransparency = 0.8
	v26 = newFrame(meterContainer, "NeonR", 4) -- inferred equivalent call
	v26.Position = UDim2.new(1, -v8, 0, v7)
	v26.Size = UDim2.new(0, 1, 1, -2 * v7)
	v26.BackgroundColor3 = v12.Dim
	v26.BackgroundTransparency = 0.8

	v22 = newFrame(meterContainer, "Lamp", 5) -- inferred equivalent call
	v22.AnchorPoint = Vector2.new(0.5, 0.5)
	v22.Position = UDim2.new(0.5, 0, 0, v7 / 2)
	v22.Size = UDim2.fromOffset(v and 7 or 8, v and 7 or 8)
	v22.BackgroundColor3 = v12.Dim
	addCircle(v22) -- inferred equivalent call
	v24 = addStroke(v22, v12.Ink, 1.5) -- inferred equivalent call

	v23 = newFrame(meterContainer, "LampRing", 5) -- inferred equivalent call
	v23.AnchorPoint = Vector2.new(0.5, 0.5)
	v23.Position = UDim2.new(0.5, 0, 0, v7 / 2)
	v23.Size = UDim2.fromOffset(v and 13 or 15, v and 13 or 15)
	v23.BackgroundTransparency = 1
	addCircle(v23) -- inferred equivalent call
	local ringStroke = addStroke(v23, v12.Dim, 1, 1) -- inferred equivalent call
	ringStroke.Name = "RingStroke"
	local frame = newFrame(meterContainer, "BoltSeg", 5) -- inferred equivalent call
	frame.BackgroundColor3 = v12.Dim
	v39[1] = frame
	local frame2 = newFrame(meterContainer, "BoltSeg", 5) -- inferred equivalent call
	frame2.BackgroundColor3 = v12.Dim
	v39[2] = frame2
	local frame3 = newFrame(meterContainer, "BoltSeg", 5) -- inferred equivalent call
	frame3.BackgroundColor3 = v12.Dim
	v39[3] = frame3

	local random = Random.new(11)
	local v67 = v and 3 or 4

	local function rivet(p, p2, p3, p4)
		local parent6 = newFrame(meterContainer, "Rivet", 3) -- inferred equivalent call
		parent6.AnchorPoint = Vector2.new(0.5, 0.5)
		parent6.Position = UDim2.new(p, p2, p3, p4)
		parent6.Size = UDim2.fromOffset(v67, v67)
		parent6.BackgroundColor3 = Color3.fromRGB(112, 108, 100)
		addCircle(parent6) -- inferred equivalent call
		addStroke(parent6, v12.Ink, 1, 0.2) -- inferred equivalent call
	end
	rivet(0, 3.5, 0, 3.5)
	rivet(1, -3.5, 0, 3.5)
	rivet(0, 3.5, 1, -3.5)
	rivet(1, -3.5, 1, -3.5)

	for i = 1, 14 do
		local frame4 = newFrame(meterContainer, "Grime", 3) -- inferred equivalent call
		frame4.AnchorPoint = Vector2.new(0.5, 0.5)
		local v69 = random:NextNumber() < 0.5 and random:NextNumber(0.004, 0.05) or random:NextNumber(0.95, 0.996)

		if i > 10 then
			v69 = random:NextNumber(0.1, 0.9)
		end

		frame4.Position = UDim2.new(random:NextNumber(0.05, 0.95), 0, v69, 0)
		frame4.Size = UDim2.fromOffset(random:NextInteger(1, 3), random:NextInteger(1, 3))
		frame4.BackgroundColor3 = i % 3 == 0 and v12.Ink or v12.Rust
		frame4.BackgroundTransparency = random:NextNumber(0.25, 0.7)
	end

	for i = 1, 4 do
		local frame4 = newFrame(meterContainer, "Scratch", 3) -- inferred equivalent call
		frame4.AnchorPoint = Vector2.new(0.5, 0.5)
		local v69 = i <= 2
		frame4.Position = UDim2.new(
			random:NextNumber(0.25, 0.75),
			0,
			v69 and 0 or 1,
			v69 and random:NextInteger(3, v7 - 3) or -random:NextInteger(3, v7 - 3)
		)
		frame4.Size = UDim2.fromOffset(random:NextInteger(6, 11), 1)
		frame4.Rotation = random:NextInteger(-35, 35)
		frame4.BackgroundColor3 = v12.Bone
		frame4.BackgroundTransparency = random:NextNumber(0.65, 0.85)
	end

	v37 = buildTape("TapeA", -34)
	v38 = buildTape("TapeB", -34)

	parent5 = newFrame(meterContainer, "FxLayer", 9) -- inferred equivalent call
	parent5.Size = UDim2.new(1, 0, 1, 0)
	parent5.BackgroundTransparency = 1
	parent5.ClipsDescendants = false

	v27 = newFrame(meterContainer, "ImpactFlash", 8) -- inferred equivalent call
	v27.AnchorPoint = Vector2.new(0.5, 0.5)
	v27.Position = UDim2.new(0.5, 0, 0.5, 0)
	v27.Size = UDim2.new(1, 6, 1, 6)
	v27.BackgroundColor3 = v12.White
	v27.BackgroundTransparency = 1
	addCorner(v27, 3) -- inferred equivalent call
	v28 = buildReadyTape("ReadyText", v12.Tape, v12.Ink, v and 11 or 13, 6) -- inferred equivalent call
	v28.Text = "PRESS SPACE / H  //  READY"
	v28.Rotation = -2

	v29 = buildReadyTape("DeniedNotice", v12.DeniedTape, Color3.fromRGB(235, 226, 210), v and 10 or 12, 6) -- inferred equivalent call
	v29.Text = "NO NOTES - WAIT"
	v29.Rotation = 1.5

	local function buildRing(name, color6, value)
		local ring = newFrame(starPowerUI, name, value) -- inferred equivalent call
		ring.AnchorPoint = Vector2.new(0.5, 0.5)
		ring.Position = UDim2.new(0.5, 0, 0.5, 0)
		ring.Size = UDim2.fromOffset(30, 30)
		ring.BackgroundTransparency = 1
		addCircle(ring) -- inferred equivalent call
		local ringStroke2 = addStroke(ring, color6, 3, 1) -- inferred equivalent call
		ringStroke2.Name = "RingStroke"
		return ring
	end

	v31 = buildRing("ActivationRing", color2, 19)
	v32 = buildRing("ActivationRing2", Color3.fromRGB(255, 160, 70), 18)

	activationLabel = Instance.new("TextLabel")
	activationLabel.Name = "ActivationLabel"
	activationLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	activationLabel.Position = UDim2.new(0.5, 0, 0.5, -50)
	activationLabel.Size = UDim2.new(0, 460, 0, 72)
	activationLabel.BackgroundTransparency = 1
	activationLabel.Font = GothamBlack
	activationLabel.TextSize = v and 34 or 50
	activationLabel.TextColor3 = color2
	activationLabel.TextStrokeTransparency = 1
	activationLabel.TextTransparency = 1
	activationLabel.Text = "STAR POWER!"
	activationLabel.ZIndex = 21
	activationLabel.Parent = starPowerUI
	v30 = addStroke(activationLabel, Color3.fromRGB(6, 14, 18), v and 3 or 4, 1) -- inferred equivalent call
	uiScale = Instance.new("UIScale")
	uiScale.Scale = 0.7
	uiScale.Parent = activationLabel

	meterContainer.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			for _, callback in ipairs(v41) do
				local success, result = pcall(callback)

				if not success then
					warn("[StarPowerUI] Error pada tap listener:", result)
				end
			end
		end
	end)
end

local function startEnergyPulseLoop()
	if not parent3 or v54 then
		return
	end

	parent3.BackgroundColor3 = color2
	parent3.BackgroundTransparency = 0.3
	parent3.Position = UDim2.new(0.5, 0, 1, 0)
	v54 = TweenService:Create(
		parent3,
		TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Position = UDim2.new(0.5, 0, 0, 0) }
	)

	v54:Play()
end

local function stopEnergyPulseLoop() -- 1 equivalent call inferred from this helper
	if v54 then
		v54:Cancel()
		v54 = nil
	end

	if parent3 then
		parent3.BackgroundTransparency = 1
	end
end

local function stopActiveEffects() -- 2 equivalent calls inferred from this helper
	count3 += 1
	stopEnergyPulseLoop() -- inferred equivalent call
end

local function updateIndicators(now, scale, p)
	local backgroundColor, transparency, backgroundTransparency, backgroundColor2

	if flag then
		local v67 = math.random() < 0.25 and rnd(0.15, 0.5) or 0 -- inferred equivalent call
		backgroundColor = color2
		transparency = 0.25 + v67
		p = color
		backgroundTransparency = 0.1 + v67
		backgroundColor2 = math.random() < 0.12 and v12.White or color2
		v23.RingStroke.Color = color
	elseif flag2 then
		local v67 = math.sin(now * 8) * 0.5 + 0.5
		p = chargeUpColor(p, 0.2, 0.4) -- inferred equivalent call

		backgroundColor = p:Lerp(v12.White, v67 * 0.55)
		transparency = 0.55 - v67 * 0.45

		backgroundTransparency = 0.45 - v67 * 0.4
		backgroundColor2 = p:Lerp(v12.White, v67 * 0.3)
		v23.RingStroke.Color = p
	else
		local v67 = math.clamp(scale, 0, 1)
		backgroundColor = p:Lerp(v12.Well, 0.75 - v67 * 0.5)

		backgroundTransparency = 0.85 - v67 * 0.4
		backgroundColor2 = v12.Dim:Lerp(p, v67 * 0.35 + 0.15)
		transparency = 1
	end

	v22.BackgroundColor3 = backgroundColor
	v23.RingStroke.Transparency = transparency
	v25.BackgroundColor3 = p
	v26.BackgroundColor3 = p
	v25.BackgroundTransparency = backgroundTransparency
	v26.BackgroundTransparency = backgroundTransparency

	if v39[1] then
		v39[1].BackgroundColor3 = backgroundColor2
	end

	if v39[2] then
		v39[2].BackgroundColor3 = backgroundColor2
	end

	if v39[3] then
		v39[3].BackgroundColor3 = backgroundColor2
	end
end

local function step(p)
	if not starPowerUI or not starPowerUI.Enabled or v47 <= 0 then
		return
	end

	local v63 = p > 0.05 and 0.05 or p
	local now = os.clock()

	for i = #v56, 1, -1 do
		if v56[i](v63) then
			continue
		end

		v56[i] = v56[#v56]
		v56[#v56] = nil
	end

	local v64 = v47
	local v65 = v7 + v49
	local scale = parent2.Size.Y.Scale
	local v66 = v7 + v49 * (1 - scale)
	local v67 = v64 / 2
	local v68 = skillToColor(v43)
	local v69, v70

	if flag then
		v69 = color3
		v70 = color4
	else
		local v71 = skillToColor(v43)
		v69 = chargeUpColor(v71, 0.15, 0.45) -- inferred equivalent call

		v70 = v71:Lerp(Color3.fromRGB(110, 36, 18), 0.55)
	end

	local v71, v72

	if flag then
		v71 = color5
		v72 = Color3.fromRGB(225, 248, 255)
	else
		v71 = skillToColor(v43)
		v72 = chargeUpColor(v71, -0.2, 0.55):Lerp(v12.White, 0.45) -- inferred equivalent call
	end

	if flag then
		local v73 = math.max(0.25, v45)

		v61.spark += (v and 10 or 28) * v73 * v63

		while v61.spark >= 1 do
			v61.spark -= 1

			if math.random() < 0.35 then
				emitSpark(v67 + rnd(-4, 4), v66, -1.5708 + rnd(-1, 1), rnd(130, 320), rnd(0.35, 0.7), 2.2, v69, v70) -- inferred equivalent call
			else
				local v76 = math.random() < 0.5
				local v77 = rnd(math.min(v66, v65 - 4), v65) -- inferred equivalent call
				local v78 = v76 and 3.641592653589793 + rnd(-0.8, 0.8) or -0.5 + rnd(-0.8, 0.8) -- inferred equivalent call

				emitSpark(
					v76 and 1 or v64 - 1,
					v77,
					v78,
					rnd(90, 260) * (v73 * 0.4 + 0.6), -- inferred equivalent call
					rnd(0.35, 0.7), -- inferred equivalent call
					2.2,
					v69,
					v70
				)
			end
		end

		v61.ember += (v and 4 or 7) * v73 * v63

		while v61.ember >= 1 do
			v61.ember -= 1
			emitEmber(
				rnd(2, v64 - 2), -- inferred equivalent call
				rnd(math.min(v66, v65 - 4), v65), -- inferred equivalent call
				Color3.fromRGB(255, 150 + math.random(0, 60), 70),
				-1
			)
		end

		v61.bolt += ((v and 2 or 3.5) + (v and 3 or 5) * v73) * v63

		while v61.bolt >= 1 do
			v61.bolt -= 1
			local v78 = rnd(math.min(v66, v65 - 6), v65) -- inferred equivalent call

			if math.random() < 0.6 then
				local v79 = math.random() < 0.5
				emitBolt(
					v79 and 0 or v64,
					v78,
					v79 and 3.141592653589793 + rnd(-0.8, 0.8) or rnd(-0.8, 0.8), -- inferred equivalent call
					rnd(22, 60) * (v73 * 0.4 + 0.6), -- inferred equivalent call
					rnd(0.1, 0.2), -- inferred equivalent call
					v17,
					v71,
					v72,
					false
				)
			else
				emitBolt(
					math.random() < 0.5 and -1 or v64 + 1,
					v78,
					-1.5708 + rnd(-0.25, 0.25), -- inferred equivalent call
					rnd(36, 80) * (v73 * 0.5 + 0.5), -- inferred equivalent call
					0.14,
					v17,
					v71,
					v72,
					false
				)
			end
		end

		parent2.BackgroundTransparency = 0.04 + (math.random() < 0.2 and rnd(0, 0.16) or 0) -- inferred equivalent call

		if now - v62 > 0.06 then
			v62 = now

			if v37 and v38 then
				v37.Rotation = v37:GetAttribute("BaseRot") + rnd(-1.6, 1.6) -- inferred equivalent call
				v38.Rotation = v38:GetAttribute("BaseRot") + rnd(-1.6, 1.6) -- inferred equivalent call
			end
		end
	elseif flag2 then
		v61.ember += (v and 3 or 5) * v63

		while v61.ember >= 1 do
			v61.ember -= 1
			emitEmber(v67 + rnd(-5, 5), v66 + 2, v69, -1) -- inferred equivalent call
		end

		v61.spark += (v and 3.5 or 6) * v63

		while v61.spark >= 1 do
			v61.spark -= 1
			emitSpark(v67 + rnd(-4, 4), v66, -1.5708 + rnd(-1.1, 1.1), rnd(110, 280), rnd(0.35, 0.7), 2, v69, v70) -- inferred equivalent call
		end

		v61.bolt += 1 / rnd(0.45, 1.1) * v63 -- inferred equivalent call

		while v61.bolt >= 1 do
			v61.bolt -= 1

			if math.random() < 0.7 then
				emitBolt(
					v67 + rnd(-4, 4), -- inferred equivalent call
					v7 + 2,
					-1.5708 + rnd(-1.1, 1.1), -- inferred equivalent call
					rnd(26, 58), -- inferred equivalent call
					rnd(0.12, 0.2), -- inferred equivalent call
					v17,
					v71,
					v72,
					false
				)
			else
				local v77 = math.random() < 0.5
				emitBolt(
					v77 and 0 or v64,
					rnd(v7, v7 + v49 * 0.3), -- inferred equivalent call
					v77 and 3.141592653589793 + rnd(-0.7, 0.7) or rnd(-0.7, 0.7), -- inferred equivalent call
					rnd(18, 40), -- inferred equivalent call
					0.12,
					v17 - 1,
					v71,
					v72,
					false
				)
			end
		end

		if now - v62 > 0.5 then
			v62 = now

			if v37 and v38 then
				v37.Rotation = v37:GetAttribute("BaseRot")
				v38.Rotation = v38:GetAttribute("BaseRot")
			end
		end
	else
		if scale > 0.02 then
			v61.ember += (v and 2.5 or 4.5) * scale * v63

			while v61.ember >= 1 do
				v61.ember -= 1
				emitEmber(v67 + rnd(-5, 5), v66 + 2, v69, -1) -- inferred equivalent call
			end

			v61.spark += 1.1 * scale * v63

			while v61.spark >= 1 do
				v61.spark -= 1
				emitSpark(v67 + rnd(-4, 4), v66, -1.5708 + rnd(-0.9, 0.9), rnd(90, 190), rnd(0.3, 0.55), 1.8, v69, v70) -- inferred equivalent call
			end

			if v46.L2 <= scale then
				v61.crackle += 0.5 * v63

				if v61.crackle >= 1 then
					v61.crackle = 0
					emitBolt(v67 + rnd(-3, 3), v66, -1.5708 + rnd(-1.2, 1.2), rnd(14, 26), 0.1, 4, v71, v72, false) -- inferred equivalent call
				end
			end
		end

		if now - v62 > 0.5 then
			v62 = now

			if v37 and v38 then
				v37.Rotation = v37:GetAttribute("BaseRot")
				v38.Rotation = v38:GetAttribute("BaseRot")
			end
		end
	end

	updateIndicators(now, scale, v68)

	if now < v55 then
		flag3 = true
		activationLabel.Position = UDim2.new(0.5, rnd(-3, 3), 0.5, -50 + rnd(-3, 3)) -- inferred equivalent call
	elseif flag3 then
		flag3 = false
		activationLabel.Position = UDim2.new(0.5, 0, 0.5, -50)
	end
end

function StarPowerUI.OnTapped(p)
	table.insert(v41, p)
end

function StarPowerUI.ShowActivationDenied(value)
	if not v29 then
		return
	end

	count4 += 1
	local v63 = count4

	v29.Text = value or "NO NOTES - WAIT"
	v29.TextTransparency = 1
	v29.BackgroundTransparency = 1

	TweenService:Create(v29, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		TextTransparency = 0,
		BackgroundTransparency = 0.06
	}):Play()

	task.delay(1, function()
		if v63 ~= count4 then
			return
		end

		TweenService:Create(v29, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			TextTransparency = 1,
			BackgroundTransparency = 1
		}):Play()
	end)
end

function StarPowerUI.SetNoteWindowActive(p)
	if p == v53 then
		return
	end

	v53 = p

	if not flag2 then
		return
	end

	if p then
		showReadyText()
	else
		hideReadyText()
	end
end

local function applyPlacement(p, p2, p3, p4)
	local v63 = p2 and math.clamp(p2 * 0.72, v3, v4) or v3
	local v64, v65, v66

	if p3 and p3 > 0 then
		v64 = p3 + v5
		v65 = 0
		v66 = 0
	elseif p and p > 0 then
		v64 = p / 2 + v5 + (v and -12 or 0)
		v65 = 0
		v66 = 0.5
	else
		v64 = -v6
		v65 = 1
		v66 = 1
	end

	local v67

	if p4 and p4 > 0 then
		v67 = 0
	else
		v67 = 0.5
		p4 = 0
	end

	local v68 = v64 + (v65 == 0 and v2 / 2 or -(v2 / 2))

	meterContainer.AnchorPoint = Vector2.new(v65, 0.5)
	meterContainer.Position = UDim2.new(v66, v64, v67, p4)
	meterContainer.Size = UDim2.new(0, v2, 0, v63)

	layoutBar(v63)

	if v28 then
		local v69 = v and 16 or 19
		local v71 = (v and 92 or 79) * (v and 5 / 7 or 15 / 14) / 2 + 10 + 196 * (v and 2 / 3 or 1) + 6
		local v72 = math.max(v63 / 2 + 10, v71)

		local y = starPowerUI and starPowerUI.AbsoluteSize.Y or 0

		if y > 0 then
			v72 = math.min(v72, (math.max(v63 / 2 + 10, v67 * y + p4 - v69 - 4)))
		end

		v52 = v72
		v28.AnchorPoint = Vector2.new(v65, 1)
		v28.Position = UDim2.new(v66, v64, v67, p4 - v72)
		v28.Size = UDim2.new(0, readyTapeWidth(), 0, v69) -- inferred equivalent call
	end

	if v29 then
		v29.AnchorPoint = Vector2.new(v65, 1)
		v29.Position = UDim2.new(v66, v64, v67, p4 - (v52 or v63 / 2 + 10) - 19 - 6)
		v29.Size = UDim2.new(0, v and 112 or 134, 0, v and 15 or 18)
	end

	local v69 = { v31, v32 }

	for _, v70 in ipairs(v69) do
		v70.Position = UDim2.new(v66, v68, v67, p4)
	end
end

function StarPowerUI.Reposition(p, p2, p3, p4)
	if meterContainer and meterContainer.Parent and starPowerUI and starPowerUI.Enabled then
		applyPlacement(p, p2, p3, p4)
	end
end

function StarPowerUI.Show(p, p2, p3, p4, p5)
	if p3 then
		v46 = p3
	end

	build()

	if v40[1] then
		v40[1].Value = v46.L1
		v40[2].Value = v46.L2
		v40[3].Value = v46.L3
	end

	applyPlacement(p, p2, p4, p5)

	if not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(step)
	end

	starPowerUI.Enabled = true
end

function StarPowerUI.GetRailState()
	return {
		meter = v44 or 0,
		resource = v45 or 0,
		active = flag == true,
		skill = v43 or 0.5,
		thresholds = { v46.L1, v46.L2, v46.L3 }
	}
end

function StarPowerUI.GetBarRect()
	if meterContainer and meterContainer.Parent and starPowerUI and starPowerUI.Enabled then
		return meterContainer.AbsolutePosition, meterContainer.AbsoluteSize
	end

	return nil, nil
end

function StarPowerUI.Hide()
	stopActiveEffects() -- inferred equivalent call
	stopReadyGlow()
	count4 += 1

	if v29 then
		v29.TextTransparency = 1
		v29.BackgroundTransparency = 1
	end

	if starPowerUI then
		starPowerUI.Enabled = false
	end

	clearParticles()
	flag = false
	v45 = 0
	v55 = 0
end

function StarPowerUI.SetMeter(value, p)
	if not parent2 then
		return
	end

	local v63 = math.clamp(value or 0, 0, 1)
	local v64 = v44
	v44 = v63

	if p ~= nil then
		v43 = p
	end

	if flag then
		flag = false
		v45 = 0
		stopActiveEffects() -- inferred equivalent call
	end

	if v47 > 0 and starPowerUI and starPowerUI.Enabled then
		local scale = parent2.Size.Y.Scale
		local v65 = v7 + v49 * (1 - scale)

		if v64 + 0.002 < v63 then
			local v66, v67

			if flag then
				v66 = color3
				v67 = color4
			else
				local v68 = skillToColor(v43)
				v66 = chargeUpColor(v68, 0.15, 0.45) -- inferred equivalent call

				v67 = v68:Lerp(Color3.fromRGB(110, 36, 18), 0.55)
			end

			for _ = 1, math.clamp(math.ceil((v63 - v64) * 55), 1, v and 3 or 5) do
				emitSpark(v47 / 2 + rnd(-4, 4), v65, -1.5708 + rnd(-1, 1), rnd(120, 260), rnd(0.3, 0.6), 2, v66, v67) -- inferred equivalent call
			end
		elseif v63 < v64 - 0.002 and scale > 0.02 then
			for _ = 1, math.random(2, 4) do
				emitEmber(v47 / 2 + rnd(-5, 5), v65, Color3.fromRGB(110, 104, 96), 1) -- inferred equivalent call
			end
		end
	end

	TweenService:Create(parent2, tweenInfo, { Size = UDim2.new(1, 0, v63, 0) }):Play()

	applyIdleFillColor(skillToColor(v43), v63 >= 1)
	refreshThresholdMarks(v63, v64)
end

function StarPowerUI.SetActiveResource(value)
	if not parent2 then
		return
	end

	local v63 = math.clamp(value or 0, 0, 1)

	if v45 > 0.001 and v63 <= 0.001 then
		v27.BackgroundTransparency = 0.4
		TweenService:Create(v27, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		}):Play()
		finalBurst() -- inferred equivalent call
	end

	v45 = v63

	parent2.Size = UDim2.new(1, 0, v63, 0)
end

function StarPowerUI.PlayActivationEffect(value)
	build()

	flag = true
	v45 = 1
	applyActiveFillColor()
	stopReadyGlow()
	startEnergyPulseLoop()

	for _, v63 in ipairs(v40) do
		v63.Reached = true
		applyMarkColor(v63) -- inferred equivalent call
	end

	count3 += 1
	local v63 = count3

	v27.BackgroundTransparency = 0.25
	TweenService:Create(v27, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1
	}):Play()

	local v64 = value or 1
	local function shock(instance, p, duration, duration2) -- 2 equivalent calls inferred from this helper
		task.delay(duration2, function()
			if v63 ~= count3 then
				return
			end

			local ringStroke = instance:FindFirstChild("RingStroke")
			instance.Size = UDim2.fromOffset(24, 24)
			ringStroke.Transparency = 0.05
			ringStroke.Thickness = 4
			TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.fromOffset(p, p)
			}):Play()
			TweenService:Create(ringStroke, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
				Thickness = 0.5
			}):Play()
		end)
	end
	shock(v31, 280 + v64 * 20, 0.5, 0) -- inferred equivalent call
	shock(v32, 190 + v64 * 14, 0.42, 0.08) -- inferred equivalent call
	activationBurst(v64) -- inferred equivalent call
	activationLabel.Rotation = rnd(-4, 4) -- inferred equivalent call
	activationLabel.TextColor3 = v12.White
	activationLabel.TextTransparency = 0
	v30.Transparency = 0
	uiScale.Scale = 1.7
	TweenService:Create(uiScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
	TweenService:Create(activationLabel, TweenInfo.new(0.5), { TextColor3 = color2 }):Play()
	v55 = os.clock() + 0.6

	task.delay(1, function()
		if v63 ~= count3 then
			return
		end

		TweenService:Create(activationLabel, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
		TweenService:Create(v30, TweenInfo.new(0.4), { Transparency = 1 }):Play()
	end)
end

return StarPowerUI