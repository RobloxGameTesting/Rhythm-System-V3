local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local result = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local InstrumentIcons = require(script.Parent.SongListUI.InstrumentIcons)

local RockMeterConfig = require(script.Parent:WaitForChild("RockMeterConfig"))
local GuiFade = require(script.Parent:WaitForChild("GuiFade"))

local success, result2 = pcall(function()
	return require(script.Parent:WaitForChild("BandCamera", 10):WaitForChild("BandCameraFocus", 10))
end)

if not success then
	result2 = nil
end

local success2, result3 = pcall(function()
	return require(script.Parent:WaitForChild("VoteKickUI", 10))
end)

if not success2 then
	result3 = nil
end

local success3, result4 = pcall(function()
	return require(script.Parent:WaitForChild("BottomLeftStack", 10))
end)

if not success3 then
	result4 = nil
end

local BandScoreUI = {}

do
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local v = result.TouchEnabled and not result.KeyboardEnabled

	local function fontOr(p, result5) -- 1 equivalent call inferred from this helper
		local success4, result6 = pcall(function()
			return Enum.Font[p]
		end)
		return success4 and result6 or result5
	end

	local font = Enum.Font.GothamBold

	do
		local v2 = "Oswald"
		local success4
		success4, result = pcall(function()
			return Enum.Font[v2]
		end)
		font = success4 and result or font
	end

	local font2 = Enum.Font.GothamBold

	do
		local v2 = "SpecialElite"
		local success4
		success4, result = pcall(function()
			return Enum.Font[v2]
		end)
		font2 = success4 and result or font2
	end

	result = Enum.Font.GothamBlack
	local font3 = fontOr("PermanentMarker", result) -- inferred equivalent call
	local v2 = (v and 92 or 79) * (v and 5 / 7 or 15 / 14)

	local color = Color3.fromRGB(20, 20, 19)
	local color2 = Color3.fromRGB(15, 15, 14)
	local color3 = Color3.fromRGB(86, 84, 80)
	local color4 = Color3.fromRGB(222, 220, 214)
	local color5 = Color3.fromRGB(158, 156, 150)
	local color6 = Color3.fromRGB(204, 162, 72)
	local color7 = Color3.fromRGB(8, 8, 8)
	local color8 = Color3.fromRGB(122, 120, 114)
	local color9 = Color3.fromRGB(74, 42, 28)
	local color10 = Color3.new(1, 1, 1)
	local color11 = Color3.fromRGB(70, 150, 168)

	local color12 = Color3.fromRGB(75, 200, 220)
	local color13 = Color3.fromRGB(200, 245, 255)
	local color14 = Color3.fromRGB(235, 252, 255)
	local color15 = Color3.fromRGB(255, 132, 44)
	local color16 = Color3.fromRGB(60, 170, 235)

	local v3 = {
		{ 0, Color3.fromRGB(150, 40, 34) },
		{ 0.25, Color3.fromRGB(190, 92, 34) },
		{ 0.5, Color3.fromRGB(212, 168, 50) },
		{ 0.75, Color3.fromRGB(128, 168, 58) },
		{ 1, Color3.fromRGB(54, 160, 92) }
	}

	local function skillToColor(value)
		local v4 = math.clamp(value, 0, 1)

		for i = 1, #v3 - 1 do
			local v5 = v3[i][1]
			local v6 = v3[i][2]
			local v7 = v3[i + 1][1]
			local v8 = v3[i + 1][2]

			if v4 <= v7 then
				return v6:Lerp(v8, v7 - v5 > 0 and (v4 - v5) / (v7 - v5) or 0)
			end
		end

		return v3[#v3][2]
	end

	local function chargeUp(p, p2, p3) -- 6 equivalent calls inferred from this helper
		local hsv, v4, v5 = p:ToHSV()
		return Color3.fromHSV(hsv, math.clamp(v4 + p2, 0, 1), (math.clamp(v5 + p3, 0, 1)))
	end

	do
		local function rnd(p, p2) -- 22 equivalent calls inferred from this helper
			return p + math.random() * (p2 - p)
		end
	end

	result = chargeUp(v3[1][2], 0.12, 0.3) -- inferred equivalent call
	local hsv, v4, v5 = v3[3][2]:ToHSV()
	local v6 = {
		result,
		Color3.fromHSV(hsv, math.clamp(v4 + 0.08, 0, 1), (math.clamp(v5 + 0.28, 0, 1))),
		chargeUp(v3[5][2], 0.08, 0.3)
	}

	do
		local function zoneOfHeat(p): number -- 3 equivalent calls inferred from this helper
			if p < RockMeterConfig.ZoneLow then
				return 1
			end

			return if p < RockMeterConfig.ZoneHigh then 2 else 3
		end
	end

	local v7 = {
		Drum = { Label = "DRUMS", Color = Color3.fromRGB(196, 74, 52) },
		GuitarRhythm = { Label = "RHYTHM", Color = Color3.fromRGB(214, 170, 52) },
		GuitarLead = { Label = "LEAD", Color = Color3.fromRGB(232, 132, 44) },
		Bass = { Label = "BASS", Color = Color3.fromRGB(66, 150, 204) },
		Keyboard = { Label = "KEYS", Color = Color3.fromRGB(152, 104, 204) },
		Piano = { Label = "PIANO", Color = Color3.fromRGB(70, 172, 132) }
	}

	local DifficultyPlateColors = require(script.Parent.DifficultyPlateColors)
	local v8 = {
		Normal = {
			Label = "NATURAL",
			Color = Color3.fromRGB(226, 66, 54),
			TapeColor = DifficultyPlateColors.Normal,
			Ink = Color3.fromRGB(244, 232, 210),
			W = 48
		},
		Medium = {
			Label = "MEDIUM",
			Color = Color3.fromRGB(240, 180, 70),
			TapeColor = DifficultyPlateColors.Medium,
			Ink = Color3.fromRGB(28, 24, 20),
			W = 42
		},
		Easy = {
			Label = "EASY",
			Color = Color3.fromRGB(88, 210, 150),
			TapeColor = DifficultyPlateColors.Easy,
			Ink = Color3.fromRGB(20, 28, 22),
			W = 30
		},
		Baby = {
			Label = "BABY",
			Color = Color3.fromRGB(255, 132, 196),
			TapeColor = DifficultyPlateColors.Baby,
			Ink = Color3.fromRGB(44, 14, 30),
			W = 32
		}
	}

	local v9 = {
		["S+"] = Color3.fromRGB(255, 226, 120),
		S = Color3.fromRGB(236, 190, 84),
		A = Color3.fromRGB(110, 200, 120),
		B = Color3.fromRGB(150, 196, 90),
		C = Color3.fromRGB(222, 164, 60),
		D = Color3.fromRGB(214, 110, 52),
		F = Color3.fromRGB(190, 60, 52)
	}

	local function formatInt(p)
		local v10 = tostring((math.floor(p + 0.5)))
		local v11 = string.gsub(string.reverse(v10), "(%d%d%d)", "%1,")
		local v12 = string.reverse(v11)

		if string.sub(v12, 1, 1) == "," then
			return (string.sub(v12, 2))
		end

		return v12
	end

	local function mk(className, items, parent) -- 92 equivalent calls inferred from this helper
		local instance = Instance.new(className)

		for k, item in pairs(items) do
			instance[k] = item
		end

		instance.Parent = parent
		return instance
	end

	local function gradient(parent, p, color17, value) -- 3 equivalent calls inferred from this helper
		return mk("UIGradient", { -- inferred equivalent call
			Color = ColorSequence.new(p, color17),
			Rotation = value or 90
		}, parent)
	end

	local function circleOf(parent) -- 6 equivalent calls inferred from this helper
		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent) -- inferred equivalent call
	end

	local v10 = {
		Name = "BandScoreUI",
		ResetOnSpawn = false,
		DisplayOrder = 14,
		ZIndexBehavior = Enum.ZIndexBehavior.Global
	}
	local screenGui = Instance.new("ScreenGui")
	local scale2 = v and 1.15 or 1.45
	result = v and 14 or 8
	local v11 = v and 54 or 52
	local v12 = { Label = "-", Color = color5 }
	local v13 = 5
	local v14 = {
		F = 1,
		D = 2,
		C = 3,
		B = 4,
		A = 5,
		S = 6,
		["S+"] = 7
	}
	local v15 = { A = 3, S = 4, ["S+"] = 5 }
	local v16 = v and 2 / 3 or 1

	for k, v17 in pairs(v10) do
		screenGui[k] = v17
	end

	screenGui.Parent = PlayerGui

	local parent2 = mk("CanvasGroup", { -- inferred equivalent call
		Name = "Container",
		AnchorPoint = Vector2.new(0, 1),
		Size = UDim2.fromOffset(220, 162),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 1
	}, screenGui)

	local uiScale = mk("UIScale", { Scale = scale2 }, parent2) -- inferred equivalent call
	GuiFade.Attach(parent2, "Hud", 0.8, GuiFade.Presets.BandScore)

	local parent3 = mk("Frame", { -- inferred equivalent call
		Name = "Plate",
		Position = UDim2.fromOffset(26, 26),
		Size = UDim2.fromOffset(168, 110),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 1
	}, parent2)

	local frame2 = mk("Frame", { -- inferred equivalent call
		Name = "Fx",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 60
	}, parent2)

	local parent4 = mk("Frame", { -- inferred equivalent call
		Name = "FeedRoot",
		AnchorPoint = Vector2.new(0, 1),
		Size = UDim2.fromOffset(168, 125),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 1
	}, screenGui)

	local uiScale2 = mk("UIScale", { Scale = scale2 }, parent4) -- inferred equivalent call
	GuiFade.Attach(parent4, "BandFeed", nil, GuiFade.Presets.TextContent)
	local frame3 = mk("Frame", { -- inferred equivalent call
		Name = "FeedFx",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 60
	}, parent4)

	do
		local parent = mk("Frame", { -- inferred equivalent call
			Name = "Shadow",
			Position = UDim2.fromOffset(3, 5),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			ZIndex = 1
		}, parent3)

		mk("UICorner", { CornerRadius = UDim.new(0, 5) }, parent) -- inferred equivalent call
	end

	local parent5 = mk("Frame", { -- inferred equivalent call
		Name = "Body",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ZIndex = 2
	}, parent3)

	mk("UICorner", { CornerRadius = UDim.new(0, 4) }, parent5) -- inferred equivalent call
	mk("UIStroke", { Color = color7, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, parent5) -- inferred equivalent call
	local v17 = Color3.fromRGB(255, 255, 255)
	gradient(parent5, v17, Color3.fromRGB(205, 203, 198), nil) -- inferred equivalent call

	local textLabel2 = mk("TextLabel", { -- inferred equivalent call
		Name = "Title",
		Position = UDim2.fromOffset(8, 4),
		Size = UDim2.fromOffset(70, 12),
		BackgroundTransparency = 1,
		Font = font,
		Text = "BAND SCORE",
		TextSize = 11,
		TextColor3 = color6,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 5
	}, parent3)

	local textLabel3 = mk("TextLabel", { -- inferred equivalent call
		Name = "HeatLabel",
		Position = UDim2.fromOffset(90, 4),
		Size = UDim2.fromOffset(70, 12),
		BackgroundTransparency = 1,
		Font = font,
		Text = "HEAT 50%",
		TextSize = 11,
		TextColor3 = color5,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 5
	}, parent3)

	local textLabel4 = mk("TextLabel", { -- inferred equivalent call
		Name = "BandScore",
		Position = UDim2.fromOffset(8, 17),
		Size = UDim2.fromOffset(106, 28),
		BackgroundTransparency = 1,
		Font = font,
		Text = "0",
		TextSize = 25,
		TextColor3 = color4,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 5
	}, parent3)

	local parent6 = mk("TextLabel", { -- inferred equivalent call
		Name = "Grade",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(141, 30),
		Size = UDim2.fromOffset(40, 36),
		BackgroundTransparency = 1,
		Font = font3,
		Text = "-",
		TextSize = 32,
		TextColor3 = color5,
		ZIndex = 6
	}, parent3)

	mk("UIStroke", { Color = Color3.fromRGB(10, 10, 10), Thickness = 2 }, parent6) -- inferred equivalent call
	local uiScale3 = mk("UIScale", { Scale = 1 }, parent6) -- inferred equivalent call

	local parent7 = mk("Frame", { -- inferred equivalent call
		Name = "HeatBar",
		Position = UDim2.fromOffset(14, 49),
		Size = UDim2.fromOffset(139, 6),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 5
	}, parent3)

	local v18 = {}

	for i = 1, 20 do
		v18[i] = mk("Frame", { -- inferred equivalent call
			Name = "Seg" .. i,
			Position = UDim2.fromOffset((i - 1) * 7, 0),
			Size = UDim2.fromOffset(6, 6),
			BackgroundColor3 = color2,
			BorderSizePixel = 0,
			ZIndex = 5
		}, parent7)
	end

	mk("Frame", { -- inferred equivalent call
		Name = "HeaderLine",
		Position = UDim2.fromOffset(8, 58),
		Size = UDim2.fromOffset(152, 1),
		BackgroundColor3 = color3,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		ZIndex = 5
	}, parent3)

	local folder = mk("Frame", { -- inferred equivalent call
		Name = "DecorFront",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 20
	}, parent3)

	local random = Random.new(41)

	do
		local function vignette(name, position, size, rotation, p)
			local parent = mk("Frame", { -- inferred equivalent call
				Name = name,
				BackgroundColor3 = Color3.new(0, 0, 0),
				BorderSizePixel = 0,
				Position = position,
				Size = size
			}, folder)
			mk("UIGradient", { -- inferred equivalent call
				Rotation = rotation,
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, p), NumberSequenceKeypoint.new(1, 1) })
			}, parent)
		end
		vignette("VigTop", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 14), 90, 0.5)
		vignette("VigBottom", UDim2.new(0, 0, 1, -14), UDim2.new(1, 0, 0, 14), 270, 0.5)
		vignette("VigLeft", UDim2.new(0, 0, 0, 0), UDim2.new(0, 14, 1, 0), 0, 0.55)
		vignette("VigRight", UDim2.new(1, -14, 0, 0), UDim2.new(0, 14, 1, 0), 180, 0.55)
	end

	for i = 1, 5 do
		local integer = random:NextInteger(26, 56)
		circleOf(mk("Frame", { -- inferred equivalent call
			Name = "Stain" .. i,
			BackgroundColor3 = i % 2 == 0 and color9 or Color3.new(0, 0, 0),
			BackgroundTransparency = 0.88 + random:NextNumber() * 0.06,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(random:NextNumber() * 0.8, random:NextNumber() * 0.8),
			Size = UDim2.new(0, integer, 0, (math.floor(integer * (0.35 + random:NextNumber() * 0.4))))
		}, folder))
	end

	for i, v19 in ipairs({
		{ 0.08, 0.2, 50, 24 },
		{ 0.58, 0.46, 40, -31 },
		{ 0.28, 0.8, 60, 12 },
		{ 0.7, 0.12, 34, 40 }
	}) do
		mk("Frame", { -- inferred equivalent call
			Name = "Scratch" .. i,
			BackgroundColor3 = color4,
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(v19[1], v19[2]),
			Size = UDim2.new(0, v19[3], 0, 1),
			Rotation = v19[4]
		}, folder)
	end

	for i = 1, 26 do
		local v19 = random:NextNumber() > 0.35
		local integer = random:NextInteger(1, 2)
		mk("Frame", { -- inferred equivalent call
			Name = "Speck" .. i,
			BackgroundColor3 = v19 and color4 or Color3.new(0, 0, 0),
			BackgroundTransparency = v19 and 0.8 + random:NextNumber() * 0.12 or 0.45 + random:NextNumber() * 0.25,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			Size = UDim2.new(0, integer, 0, integer)
		}, folder)
	end

	local parent8 = mk("Frame", { -- inferred equivalent call
		Name = "EdgeWear",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 3, 0, 3),
		Size = UDim2.new(1, -6, 1, -6)
	}, folder)
	local uiStroke = mk("UIStroke", { Color = color8, Thickness = 1.5, Transparency = 0.55 }, parent8) -- inferred equivalent call
	mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent8) -- inferred equivalent call

	for _, guiObject in ipairs(folder:GetDescendants()) do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = 20
		end
	end

	do
		local function rivet(p, p2, p3, p4)
			local parent = mk("Frame", { -- inferred equivalent call
				Name = "Rivet",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(p, p3, p2, p4),
				Size = UDim2.fromOffset(7, 7),
				BackgroundColor3 = color10,
				BorderSizePixel = 0,
				ZIndex = 22
			}, parent3)
			circleOf(parent) -- inferred equivalent call
			local color17 = Color3.fromRGB(196, 192, 182)
			local color18 = Color3.fromRGB(70, 68, 63)
			mk("UIGradient", { -- inferred equivalent call
				Color = ColorSequence.new(color17, color18),
				Rotation = 45
			}, parent)

			mk("UIStroke", { Color = color7, Thickness = 1, Transparency = 0.05 }, parent) -- inferred equivalent call
			mk("Frame", { -- inferred equivalent call
				Name = "Slot",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, -2, 0, 1),
				Rotation = random:NextInteger(0, 170),
				BackgroundColor3 = color7,
				BackgroundTransparency = 0.15,
				BorderSizePixel = 0,
				ZIndex = 23
			}, parent)
		end
		rivet(0, 0, 8, 8)
		rivet(1, 0, -8, 8)
		rivet(0, 1, 8, -8)
		rivet(1, 1, -8, -8)
	end

	local parent9 = frame2
	local v19 = v and 14 or 30
	local v20 = v and 3 or 6
	local v21 = v and 4 or 5
	local v22 = {}
	local v23 = {}
	local v24 = 0
	local v25 = 0

	do
		local function acquire(zIndex) -- 5 equivalent calls inferred from this helper
			local selected = table.remove(v23)

			if not selected then
				selected = Instance.new("Frame")
				selected.AnchorPoint = Vector2.new(0.5, 0.5)
				selected.BorderSizePixel = 0
			end

			selected.ZIndex = zIndex
			selected.Rotation = 0
			selected.Visible = true
			selected.Parent = parent9
			return selected
		end
	end

	do
		local function release(p) -- 5 equivalent calls inferred from this helper
			p.Visible = false
			v23[#v23 + 1] = p
		end
	end

	local function clearParticles()
		v22 = {}
		v24 = 0
		v25 = 0
		v23 = {}

		for _, v26 in ipairs({ frame2, frame3 }) do
			for _, child in ipairs(v26:GetChildren()) do
				child.Visible = false
				v23[#v23 + 1] = child
			end
		end
	end

	local function placeLine(p, p2, p3, p4, p5, p6)
		local v26 = p4 - p2
		local v27 = p5 - p3
		p.Position = UDim2.fromOffset((p2 + p4) / 2, (p3 + p5) / 2)
		p.Size = UDim2.fromOffset(math.sqrt(v26 * v26 + v27 * v27) + 0.5, p6)
		p.Rotation = math.deg((math.atan2(v27, v26)))
	end

	do
		local function emitSpark(total, total2, p, p2, p3, p4, p5, p6)
			if v19 <= v24 then
				return
			end

			v24 += 1
			local v26 = acquire(61) -- inferred equivalent call
			local v27 = math.cos(p) * p2
			local v28 = math.sin(p) * p2
			local total3 = 0
			v22[#v22 + 1] = function(p7): boolean
				total3 += p7

				if p3 <= total3 then
					v24 -= 1
					release(v26) -- inferred equivalent call
					return false
				else
					local v29 = math.exp(-2.4 * p7)
					v27 *= v29
					v28 = v28 * v29 + 380 * p7
					total += v27 * p7
					total2 += v28 * p7
					local v30 = total3 / p3
					local v31 = math.sqrt(v27 * v27 + v28 * v28)
					v26.Position = UDim2.fromOffset(total, total2)
					v26.Rotation = math.deg((math.atan2(v28, v27)))
					v26.Size = UDim2.fromOffset(math.clamp(v31 * 0.045, 3, 18), (math.max(1.5, p4 * (1 - v30 * 0.5))))
					v26.BackgroundColor3 = p5:Lerp(p6, (math.clamp(v30 * 1.5, 0, 1)))
					v26.BackgroundTransparency = v30 * v30 * 0.95
					return true
				end
			end
		end
	end

	local function emitBolt(p, p2, p3, p4, p5, backgroundColor, backgroundColor2)
		if v20 <= v25 then
			return
		end

		v25 += 1
		local v26 = v21
		local v27 = v and 1.8 or 2.2
		local v28 = {}
		local v29 = {}

		for i = 1, v26 do
			local v30 = acquire(61) -- inferred equivalent call
			v30.BackgroundColor3 = backgroundColor
			v28[i] = v30
			local v31 = acquire(62) -- inferred equivalent call
			v31.BackgroundColor3 = backgroundColor2
			v29[i] = v31
		end

		local v30 = math.cos(p3)
		local v31 = math.sin(p3)
		local v32 = -v31
		local v57 = p4 * 0.22
		local function relayout()
			local v58 = {}
			local v59 = {}

			for i = 0, v26 do
				local v60 = i / v26
				local v61

				if i == 0 then
					v61 = 0
				else
					v61 = rnd(-v57, v57) * (1 - v60 * 0.25) -- inferred equivalent call
				end

				v58[i] = p + v30 * p4 * v60 + v32 * v61
				v59[i] = p2 + v31 * p4 * v60 + v30 * v61
			end

			for i = 1, v26 do
				placeLine(v28[i], v58[i - 1], v59[i - 1], v58[i], v59[i], v27 * 3)
				placeLine(v29[i], v58[i - 1], v59[i - 1], v58[i], v59[i], v27)
			end
		end
		relayout()
		local total = 0
		local total2 = 0
		v22[#v22 + 1] = function(p6): boolean
			total += p6
			total2 += p6

			if p5 <= total then
				for i = 1, v26 do
					release(v28[i]) -- inferred equivalent call
					release(v29[i]) -- inferred equivalent call
				end

				v25 -= 1
				return false
			else
				if total2 >= 0.045 then
					total2 = 0
					relayout()
				end

				local v58 = total / p5
				local v59 = math.random() < 0.28 and 0.4 or 0
				local backgroundTransparency = math.clamp(v58 * v58 * 0.9 + v59, 0, 1)
				local backgroundTransparency2 = math.clamp(0.7 + v58 * 0.3 + v59 * 0.3, 0, 1)

				for i = 1, v26 do
					v29[i].BackgroundTransparency = backgroundTransparency
					v28[i].BackgroundTransparency = backgroundTransparency2
				end

				return true
			end
		end
	end

	local flag = false
	local v26 = "bar"
	local v27 = false

	do
		local function isLeftDock(): boolean -- 4 equivalent calls inferred from this helper
			return v26 == "screen" or v26 == "hud"
		end
	end

	local v28 = {}
	local us = {}
	local v29 = 0
	local v30 = 110

	local v31 = 0
	local v32 = 0
	local v57 = RockMeterConfig.Start
	local v58 = RockMeterConfig.Start
	local text2 = "-"
	local v60 = 0
	local v61 = 0
	local v62 = 0
	local v63 = 0.8
	local v64 = nil
	local v65 = nil

	local v66 = nil
	local v67 = nil
	local v68 = nil

	local v69 = true
	local from = 1
	local v71 = nil

	local v72 = os.clock()

	do
		local function setPanelOpen(p) -- 1 equivalent call inferred from this helper
			local v73 = p and true or false

			if v69 == v73 then
				return
			end

			v69 = v73
			v71 = {
				from = from,
				to = v73 and 1 or 0,
				t = 0,
				dur = v73 and 0.55 or 0.36
			}
		end
	end

	local v73 = {
		Name = "SlideHandle",
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromOffset(3, 0),
		Size = UDim2.fromOffset(result, v11),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 80
	}
	local canvasGroup = Instance.new("CanvasGroup")
	local v74 = false
	local v75 = nil
	local total = 1

	for k, v76 in pairs(v73) do
		canvasGroup[k] = v76
	end

	canvasGroup.Parent = screenGui

	local uiScale4 = mk("UIScale", { Scale = scale2 }, canvasGroup) -- inferred equivalent call
	local parent10 = mk("Frame", { -- inferred equivalent call
		Name = "Body",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ZIndex = 81
	}, canvasGroup)

	mk("UICorner", { CornerRadius = UDim.new(0, 3) }, parent10) -- inferred equivalent call
	mk("UIStroke", { Color = color7, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, parent10) -- inferred equivalent call
	v11 = Color3.fromRGB(255, 255, 255)
	gradient(parent10, v11, Color3.fromRGB(190, 188, 182), nil) -- inferred equivalent call
	mk("Frame", { -- inferred equivalent call
		Name = "Edge",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -2, 0.5, 0),
		Size = UDim2.new(0, 1, 1, -12),
		BackgroundColor3 = color3,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		ZIndex = 82
	}, parent10)

	local v78 = result / 2

	for _, v79 in ipairs({ 0.13, 0.87 }) do
		circleOf(mk("Frame", { -- inferred equivalent call
			Name = "Bolt",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, v78, v79, 0),
			Size = UDim2.fromOffset(2, 2),
			BackgroundColor3 = color8,
			BorderSizePixel = 0,
			ZIndex = 82
		}, parent10))
	end

	result = v and 9 or 6
	v11 = v and 2.5 or 2
	v17 = result * 0.35
	local parent11 = mk("Frame", { -- inferred equivalent call
		Name = "ChevTop",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, v78, 0.5, -v17),
		Size = UDim2.fromOffset(result, v11),
		BackgroundColor3 = color6,
		BorderSizePixel = 0,
		Rotation = -45,
		ZIndex = 83
	}, parent10)

	local parent12 = mk("Frame", { -- inferred equivalent call
		Name = "ChevBottom",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, v78, 0.5, v17),
		Size = UDim2.fromOffset(result, v11),
		BackgroundColor3 = color6,
		BorderSizePixel = 0,
		Rotation = 45,
		ZIndex = 83
	}, parent10)
	circleOf(parent11) -- inferred equivalent call
	circleOf(parent12) -- inferred equivalent call

	do
		local textButton = mk("TextButton", { -- inferred equivalent call
			Name = "Hit",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 90
		}, canvasGroup)

		textButton.MouseEnter:Connect(function()
			v74 = true
		end)
		textButton.MouseLeave:Connect(function()
			v74 = false
		end)
		textButton.Activated:Connect(function()
			local v82 = not v69

			if v69 == v82 then
				return
			end

			v69 = v82
			v71 = {
				from = from,
				to = v82 and 1 or 0,
				t = 0,
				dur = v82 and 0.55 or 0.36
			}
		end)
	end

	GuiFade.Attach(canvasGroup, "Hud", nil, GuiFade.Presets.BandScore)
	local v82 = 0

	local v83 = -1
	local v84 = nil
	local v85 = nil
	local v86 = nil
	local v87 = nil
	local v88 = nil
	local v89 = nil
	local v90 = { valid = false, grade = nil, mvp = nil, zone = nil }
	local v91 = {}

	do
		local function triggerMoment(value) -- 6 equivalent calls inferred from this helper
			v60 = math.max(v60, value or 2)
		end
	end

	local function fxColors()
		if v27 then
			return color14, color15, color16, Color3.fromRGB(225, 248, 255)
		end

		local v92 = v6[zoneOfHeat(v58)] -- inferred equivalent call

		return
			chargeUp(v92, 0, 0.3):Lerp(color10, 0.35), -- inferred equivalent call
			v92:Lerp(Color3.fromRGB(110, 36, 18), 0.5),
			v92,
			chargeUp(v92, -0.2, 0.5):Lerp(color10, 0.45) -- inferred equivalent call
	end

	local function burst(p, p2, p3, p4, list)
		local v92, v93, v94, v95

		if list then
			v92 = list[1]
			v93 = list[2]
			v94 = list[3]
			v95 = list[4]
		else
			v92, v93, v94, v95 = fxColors()
		end

		for _ = 1, p3 do
			local v96 = p + rnd(-6, 6) -- inferred equivalent call
			local v97 = p2 + rnd(-3, 3) -- inferred equivalent call
			local v98 = rnd(0, 6.283185307179586) -- inferred equivalent call
			local v99 = rnd(110, 300) -- inferred equivalent call
			local v100 = rnd(0.35, 0.7) -- inferred equivalent call

			if v19 <= v24 then
				continue
			end

			v24 += 1
			local v101 = acquire(61) -- inferred equivalent call
			local v102 = math.cos(v98) * v99
			local v103 = math.sin(v98) * v99
			local total2 = 0
			local v104 = 2
			v22[#v22 + 1] = function(p5): boolean
				total2 += p5

				if v100 <= total2 then
					v24 -= 1
					release(v101) -- inferred equivalent call
					return false
				else
					local v105 = math.exp(-2.4 * p5)
					v102 *= v105
					v103 = v103 * v105 + 380 * p5
					v96 += v102 * p5
					v97 += v103 * p5
					local v106 = total2 / v100
					local v107 = math.sqrt(v102 * v102 + v103 * v103)
					v101.Position = UDim2.fromOffset(v96, v97)
					v101.Rotation = math.deg((math.atan2(v103, v102)))
					v101.Size = UDim2.fromOffset(
						math.clamp(v107 * 0.045, 3, 18),
						(math.max(1.5, v104 * (1 - v106 * 0.5)))
					)
					v101.BackgroundColor3 = v92:Lerp(v93, (math.clamp(v106 * 1.5, 0, 1)))
					v101.BackgroundTransparency = v106 * v106 * 0.95
					return true
				end
			end
		end

		for _ = 1, p4 do
			emitBolt(p, p2, rnd(0, 6.283185307179586), rnd(24, 52), rnd(0.12, 0.22), v94, v95) -- inferred equivalent call
		end
	end

	do
		local function centerOf(p) -- 6 equivalent calls inferred from this helper
			local scale = uiScale.Scale
			local v92 = p.AbsolutePosition - frame2.AbsolutePosition
			local absoluteSize = p.AbsoluteSize
			return (v92.X + absoluteSize.X / 2) / scale, (v92.Y + absoluteSize.Y / 2) / scale
		end
	end

	local function textLabel(frame, items)
		local v92 = {
			BackgroundTransparency = 1,
			Font = font,
			TextSize = 12,
			TextColor3 = color4,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 8
		}

		for k, item in pairs(items) do
			v92[k] = item
		end

		return mk("TextLabel", v92, frame) -- inferred equivalent call
	end

	local color17 = Color3.fromRGB(206, 190, 150)
	local color18 = Color3.fromRGB(206, 170, 62)
	local color19 = Color3.fromRGB(96, 90, 80)
	local color20 = Color3.fromRGB(28, 24, 20)

	local function makeTape(parent, name, text, p, p2, rotation, backgroundColor, rotation2, p3)
		local random2 = Random.new(p3)
		local tape = mk("Frame", { -- inferred equivalent call
			Name = name,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(p, p2),
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = 0.04,
			BorderSizePixel = 0,
			Rotation = rotation,
			ZIndex = 14,
			Visible = false
		}, parent)

		mk( -- inferred equivalent call
			"UIStroke",
			{
				Color = Color3.fromRGB(70, 62, 48),
				Thickness = 1,
				Transparency = 0.55,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			},
			tape
		)

		mk("Frame", { -- inferred equivalent call
			Name = "Sliver",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, random2:NextInteger(-6, 6), 0.5, random2:NextInteger(-2, 3)),
			Size = UDim2.fromOffset((math.floor)(p * 0.7), p2 - 2),
			Rotation = rotation2,
			BackgroundColor3 = color19,
			BackgroundTransparency = 0.1,
			BorderSizePixel = 0,
			ZIndex = 13
		}, tape)

		local function notch(p4, p5, p6)
			mk("Frame", { -- inferred equivalent call
				Name = "Notch",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(p4, p5),
				Size = UDim2.fromOffset(p6, p6),
				Rotation = 45 + random2:NextInteger(-12, 12),
				BackgroundColor3 = color,
				BorderSizePixel = 0,
				ZIndex = 16
			}, tape)
		end
		notch(0, 0.18 + random2:NextNumber() * 0.12, 3.6)
		notch(0, 0.6 + random2:NextNumber() * 0.15, 2.8)
		notch(1, 0.3 + random2:NextNumber() * 0.15, 3.2)
		notch(1, 0.74 + random2:NextNumber() * 0.12, 2.4)

		mk("Frame", { -- inferred equivalent call
			Name = "Crease",
			Position = UDim2.fromScale(0.58 + random2:NextNumber() * 0.14, 0),
			Size = UDim2.new(0, 1, 1, 0),
			Rotation = random2:NextInteger(-9, 9),
			BackgroundColor3 = color19,
			BackgroundTransparency = 0.65,
			BorderSizePixel = 0,
			ZIndex = 15
		}, tape)

		mk("Frame", { -- inferred equivalent call
			Name = "Smudge",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.15 + random2:NextNumber() * 0.2, 0.7),
			Size = UDim2.fromOffset(5, 2),
			Rotation = random2:NextInteger(-20, 20),
			BackgroundColor3 = color19,
			BackgroundTransparency = 0.7,
			BorderSizePixel = 0,
			ZIndex = 15
		}, tape)

		mk("TextLabel", { -- inferred equivalent call
			Name = "Text",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Font = font2,
			Text = text,
			TextSize = 9,
			TextColor3 = color20,
			Rotation = random2:NextInteger(-2, 2),
			ZIndex = 17
		}, tape)

		return tape
	end

	local v92 = v and 26 or 18
	local v93 = v and 20 or 14
	local v94 = v and 8 or 0
	local color21 = Color3.fromRGB(20, 19, 18)
	result = v and 46 or 38
	v11 = v and 18 or 13
	local color22 = Color3.fromRGB(226, 66, 54)

	local function paintFocus(data)
		local focusBtn = data.FocusBtn
		local focusStroke = data.FocusStroke

		if not focusBtn then
			return
		end

		local shown = data.Shown or {}
		local focusHover = shown.FocusHover == true
		local focusOn = shown.FocusOn == true

		if focusOn then
			focusBtn.BackgroundColor3 = color6
			focusBtn.BackgroundTransparency = 0.9
			focusStroke.Color = color6
			focusStroke.Transparency = focusHover and 0.35 or 0.6
		else
			focusBtn.BackgroundColor3 = color21
			focusBtn.BackgroundTransparency = focusHover and 0.55 or 0.88
			focusStroke.Color = focusHover and color6 or color3
			focusStroke.Transparency = focusHover and 0.6 or 0.92
		end

		local focusParts = data.FocusParts

		if focusParts then
			local backgroundColor = (focusOn or focusHover) and color6 or color5
			local backgroundTransparency = focusOn and 0.2 or focusHover and 0.35 or 0.78

			for _, fill in ipairs(focusParts.fills) do
				fill.BackgroundColor3 = backgroundColor
				fill.BackgroundTransparency = backgroundTransparency
			end
		end
	end

	local function createRow(u)
		local v95 = {
			Name = "Row_" .. tostring(u),
			Position = UDim2.fromOffset(6, 62),
			Size = UDim2.fromOffset(156, 34),
			BackgroundColor3 = color2,
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			ZIndex = 6
		}
		local frame = Instance.new("Frame")

		local row = {
			UserId = u,
			Y = nil,
			ScoreDisp = 0,
			ScoreTarget = 0,
			Shown = {}
		}

		for k, v96 in pairs(v95) do
			frame[k] = v96
		end

		frame.Parent = parent3

		row.Frame = frame

		mk("UICorner", { CornerRadius = UDim.new(0, 3) }, row.Frame) -- inferred equivalent call
		row.Stroke = mk( -- inferred equivalent call
			"UIStroke",
			{
				Color = color3,
				Thickness = 1,
				Transparency = 0.5,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			},
			row.Frame
		)

		row.Accent = mk("Frame", { -- inferred equivalent call
			Name = "Accent",
			Size = UDim2.new(0, 3, 1, 0),
			BackgroundColor3 = color6,
			BorderSizePixel = 0,
			ZIndex = 7
		}, row.Frame)
		mk("UICorner", { CornerRadius = UDim.new(0, 2) }, row.Accent) -- inferred equivalent call

		row.Name = textLabel(row.Frame, {
			Name = "Name",
			Position = UDim2.fromOffset(8, 2),
			Size = UDim2.fromOffset(94, 14),
			TextSize = 12
		})

		row.InstrChip = textLabel(row.Frame, {
			Name = "Instr",
			Position = UDim2.fromOffset(106, 5),
			Size = UDim2.fromOffset(46, 12),
			TextSize = 9,
			TextXAlignment = Enum.TextXAlignment.Center,
			BackgroundTransparency = 0.8,
			BackgroundColor3 = color6
		})

		mk("UICorner", { CornerRadius = UDim.new(0, 3) }, row.InstrChip) -- inferred equivalent call

		row.InstrIcon = mk("ImageLabel", { -- inferred equivalent call
			Name = "InstrIcon",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(96, 11),
			Size = UDim2.fromOffset(14, 14),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScaleType = Enum.ScaleType.Crop,
			Visible = false,
			ZIndex = 7
		}, row.Frame)

		row.TierTapes = {}
		row.TierChip = nil
		row.TierFlash = 0
		row.TierW = 0

		row.Score = textLabel(row.Frame, {
			Name = "Score",
			Position = UDim2.fromOffset(7, 18),
			Size = UDim2.fromOffset(61, 14),
			TextSize = 12
		})
		row.Combo = textLabel(row.Frame, {
			Name = "Combo",
			Position = UDim2.fromOffset(68, 18),
			Size = UDim2.fromOffset(40, 14),
			Font = font2,
			TextSize = 11,
			TextColor3 = color6
		})
		row.Acc = textLabel(row.Frame, {
			Name = "Acc",
			Position = UDim2.fromOffset(108, 18),
			Size = UDim2.fromOffset(44, 14),
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Right
		})
		row.AutoText = textLabel(row.Frame, {
			Name = "AutoText",
			Position = UDim2.fromOffset(8, 18),
			Size = UDim2.fromOffset(140, 14),
			Font = font2,
			TextSize = 10,
			TextColor3 = color5,
			Text = "autoplay",
			Visible = false
		})

		local v96 = ((tonumber(u) or 0) % 7 - 3) * 0.8
		row.MvpChip = makeTape(row.Frame, "Mvp", "MVP", 26, 12, 4.5 + v96, color18, -20, (tonumber(u) or 1) + 11)
		row.MvpChip.Position = UDim2.fromOffset(139, -3)
		row.YouChip = makeTape(row.Frame, "You", "YOU", 24, 12, -5.5 - v96 * 0.7, color17, 17, (tonumber(u) or 1) + 29)
		row.YouChip.Position = UDim2.fromOffset(140, -3)
		row.MvpFlash = 0

		row.KeyTag = mk("Frame", { -- inferred equivalent call
			Name = "KeyTag",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromOffset(9, 0),
			Size = UDim2.fromOffset(31, 10),
			Rotation = -1.5 + ((tonumber(u) or 0) % 3 - 1) * 0.8,
			BackgroundColor3 = Color3.fromRGB(24, 23, 21),
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 12
		}, row.Frame)
		mk("UICorner", { CornerRadius = UDim.new(0, 2) }, row.KeyTag) -- inferred equivalent call
		mk( -- inferred equivalent call
			"UIStroke",
			{
				Color = color6,
				Thickness = 1,
				Transparency = 0.45,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			},
			row.KeyTag
		)

		local parent = mk("Frame", { -- inferred equivalent call
			Name = "Bolt",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(4, 5),
			Size = UDim2.fromOffset(3, 3),
			BackgroundColor3 = color8,
			BorderSizePixel = 0,
			ZIndex = 13
		}, row.KeyTag)
		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent) -- inferred equivalent call
		row.KeyText = mk("TextLabel", { -- inferred equivalent call
			Name = "Text",
			Position = UDim2.fromOffset(7, 0),
			Size = UDim2.new(1, -8, 1, 0),
			BackgroundTransparency = 1,
			Font = font2,
			Text = "",
			TextSize = 8,
			TextColor3 = color6,
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 14
		}, row.KeyTag)

		row.FocusBtn = mk("TextButton", { -- inferred equivalent call
			Name = "Focus",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromOffset(167, 17),
			Size = UDim2.fromOffset(v92, v93),
			BackgroundColor3 = color21,
			BackgroundTransparency = 0.88,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = font2,
			Text = "",
			Visible = false,
			ZIndex = 18
		}, row.Frame)
		mk("UICorner", { CornerRadius = UDim.new(0, 3) }, row.FocusBtn) -- inferred equivalent call
		row.FocusStroke = mk( -- inferred equivalent call
			"UIStroke",
			{
				Color = color3,
				Thickness = 1,
				Transparency = 0.92,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			},
			row.FocusBtn
		)

		local v98 = math.floor(v92 * 0.8)
		local v99 = math.floor(v93 * 0.6)
		local v100 = math.floor(v98 * 0.66)
		local v101 = v98 - v100 - 1
		local parent13 = mk("Frame", { -- inferred equivalent call
			Name = "CamIcon",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(v98, v99),
			ZIndex = 19
		}, row.FocusBtn)
		local parent14 = mk("Frame", { -- inferred equivalent call
			Name = "Body",
			BackgroundColor3 = color5,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(v100, v99),
			ZIndex = 19
		}, parent13)

		mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent14) -- inferred equivalent call

		local parent15 = mk("Frame", { -- inferred equivalent call
			Name = "WedgeClip",
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Position = UDim2.fromOffset(v100 + 1, 0),
			Size = UDim2.fromOffset(v101, v99),
			ZIndex = 19
		}, parent13)

		local v105 = v99 / 1.4142135623730951
		local frame4 = mk("Frame", { -- inferred equivalent call
			Name = "Wedge",
			BackgroundColor3 = color5,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.fromOffset(v105, v105),
			Rotation = 45,
			ZIndex = 19
		}, parent15)

		row.FocusParts = {
			fills = { parent14, frame4 }
		}
		paintFocus(row)
		row.FocusBtn.MouseEnter:Connect(function()
			row.Shown.FocusHover = true
			paintFocus(row)
		end)
		row.FocusBtn.MouseLeave:Connect(function()
			row.Shown.FocusHover = false
			paintFocus(row)
		end)
		row.FocusBtn.Activated:Connect(function()
			if result2 == nil or row.Shown.Instr == nil then
				return
			end

			result2.Toggle(row.UserId, row.Shown.Instr)
		end)

		return row
	end

	local function applyFocusVisual(data)
		local focusBtn = data.FocusBtn

		if not focusBtn then
			return
		end

		local visible

		if result2 == nil or v26 ~= "screen" then
			visible = false
		else
			visible = not (data.Shown.Auto or data.Shown.Me)
		end

		focusBtn.Visible = visible
		local focusOn

		if visible then
			focusOn = result2.IsFocused(data.UserId) or false
		else
			focusOn = false
		end

		if data.Shown.FocusOn ~= focusOn then
			data.Shown.FocusOn = focusOn
			paintFocus(data)

			if focusOn then
				data.Stroke.Color = color6
				data.Stroke.Transparency = 0.35
			else
				local me = data.Shown.Me == true
				data.Stroke.Color = me and color6 or color3
				data.Stroke.Transparency = me and 0.35 or 0.5
			end
		end
	end

	if result2 then
		result2.OnChanged(function()
			for _, v95 in pairs(v28) do
				applyFocusVisual(v95)
			end
		end)
	end

	local fn

	if result3 == nil then
		fn = function() end
	else
		do
			local parent = mk("TextButton", {
				Name = "KickMenu",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 1, 0),
				Size = UDim2.fromOffset(result, v11),
				BackgroundColor3 = Color3.fromRGB(24, 23, 21),
				BackgroundTransparency = 0.05,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Font = font2,
				Text = "kick",
				TextSize = v and 10 or 9,
				TextColor3 = color5,
				Visible = false,
				ZIndex = 26
			}, parent3)

			mk("UICorner", { CornerRadius = UDim.new(0, 3) }, parent)

			do
				local v96 = mk(
					"UIStroke",
					{
						Color = color3,
						Thickness = 1,
						Transparency = 0.35,
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					},
					parent
				)
				parent.MouseEnter:Connect(function()
					parent.TextColor3 = color22
					v96.Color = color22
					v96.Transparency = 0.2
				end)
				parent.MouseLeave:Connect(function()
					parent.TextColor3 = color5
					v96.Color = color3
					v96.Transparency = 0.35
				end)
			end

			parent.Activated:Connect(function()
				result3.OpenMenu(parent, parent3)
			end)

			fn = function()
				local visible = #result3.GetTargets() > 0

				if parent.Visible ~= visible then
					parent.Visible = visible
				end
			end
		end

		do
			local set = {}
			local function watch(object)
				if set[object] then
					return
				end

				set[object] = true
				object:GetAttributeChangedSignal("VoteKickStageId"):Connect(fn)
			end

			for _, v97 in ipairs(Players:GetPlayers()) do
				watch(v97)
			end

			Players.PlayerAdded:Connect(watch)
		end

		Players.PlayerRemoving:Connect(function()
			task.defer(fn)
		end)
		fn()
	end

	do
		local function accuracyColor(p)
			return chargeUp(skillToColor(math.clamp((p - 70) / 30, 0, 1)), 0, 0.12)
		end
	end

	local function getTierTape(data, d)
		local tierTape = data.TierTapes[d]

		if tierTape then
			return tierTape
		end

		local v95 = v8[d]
		local userId = tonumber(data.UserId) or 1

		local rotation = ((userId + #d) % 5 - 2) * 1.6 + ((d == "Normal" or d == "Easy") and -2.5 or 2.5)
		local lerped = v95.TapeColor:Lerp(color19, 0.12)
		local tape = makeTape(
			data.Frame,
			"Tier",
			v95.Label,
			v95.W,
			12,
			rotation,
			lerped,
			(userId % 3 - 1) * 14 + 8,
			userId * 7 + #d
		)
		tape:SetAttribute("BaseColor", lerped)
		local text = tape:FindFirstChild("Text")

		if text then
			text.TextSize = 8
			text.TextColor3 = v95.Ink
		end

		data.TierTapes[d] = tape
		return tape
	end

	local function layoutNameAndTier(data)
		local tierW = data.TierW or 0
		local v95 = 103 - (data.Shown.IconOn and 17 or 0) - 8 - (tierW > 0 and tierW + 4 or 0)
		local name = data.Shown.Name or ""
		local nameW = math.max(
			10,
			(math.min(math.ceil(TextService:GetTextSize(name, 12, font, Vector2.new(1000, 20)).X) + 2, v95))
		)

		if data.Shown.NameW ~= nameW then
			data.Shown.NameW = nameW
			data.Name.Size = UDim2.fromOffset(nameW, 14)
		end

		if tierW > 0 and data.TierChip then
			data.TierChip.Position = UDim2.fromOffset(nameW + 8 + 4 + tierW / 2, 9)
		end
	end

	local function updateRow(state, data, p)
		local v95 = v7[data.i] or v12

		if state.Shown.Instr ~= data.i then
			state.Shown.Instr = data.i
			state.Accent.BackgroundColor3 = v95.Color
			state.InstrChip.Text = v95.Label
			state.InstrChip.TextColor3 = v95.Color
			state.InstrChip.BackgroundColor3 = v95.Color

			local image = InstrumentIcons.Get(data.i)

			if image then
				local size = InstrumentIcons.GetSize(data.i, 14)
				state.InstrIcon.Image = image
				state.InstrIcon.Size = UDim2.fromOffset(size.X, size.Y)
			end

			state.InstrIcon.Visible = image ~= nil
			state.Shown.IconOn = image ~= nil
			state.Shown.NameW = nil
		end

		local n = tostring(data.n or "?")

		if state.Shown.Name ~= n then
			state.Shown.Name = n
			state.Name.Text = n
		end

		local v96 = p and color6 or color4

		if state.Shown.NameColor ~= v96 then
			state.Shown.NameColor = v96
			state.Name.TextColor3 = v96
		end

		if state.Shown.Me ~= p then
			state.Shown.Me = p
			state.Stroke.Color = p and color6 or color3
			state.Stroke.Transparency = p and 0.35 or 0.5
		end

		state.YouChip.Visible = p

		local v97 = data.au == 1

		if state.Shown.Auto ~= v97 then
			state.Shown.Auto = v97
			state.AutoText.Visible = v97
			state.Score.Visible = not v97
			state.Combo.Visible = not v97
			state.Acc.Visible = not v97
			state.Frame.BackgroundTransparency = v97 and 0.55 or 0.15
			local v98 = v97 and 0.45 or 0
			state.Name.TextTransparency = v98
			state.InstrChip.TextTransparency = v98
			state.InstrIcon.ImageTransparency = v98
			state.Accent.BackgroundTransparency = v97 and 0.6 or 0
		end

		local visible = data.mv == 1
		state.MvpChip.Visible = visible

		state.YouChip.Position = UDim2.fromOffset(visible and 111 or 140, -3)

		if not v97 then
			state.ScoreTarget = data.s or 0
			local v99 = "x" .. tostring(data.c or 0)

			if state.Shown.Combo ~= v99 then
				state.Shown.Combo = v99
				state.Combo.Text = v99
			end

			local a = data.a or 0
			local v100 = string.format("%.1f%%", a)

			if state.Shown.Acc ~= v100 then
				state.Shown.Acc = v100
				state.Acc.Text = v100
				local acc = state.Acc
				acc.TextColor3 = chargeUp(skillToColor(math.clamp((a - 70) / 30, 0, 1)), 0, 0.12) -- inferred equivalent call
			end
		end

		local d = not v97 and (v8[data.d] and data.d or "Normal") or nil

		if state.Shown.Tier ~= d or state.Shown.TierInit == nil then
			local v99 = state.Shown.TierInit == nil
			state.Shown.TierInit = true
			state.Shown.Tier = d

			if state.TierChip then
				state.TierChip.Visible = false
			end

			if d then
				local v100 = v8[d]
				local tierTape = getTierTape(state, d)
				tierTape.Visible = true
				state.TierChip = tierTape
				state.TierW = v100.W

				if not v99 then
					state.TierFlash = 1
					state.PendingTierBurst = true
				end
			else
				state.TierChip = nil
				state.TierW = 0
			end
		end

		layoutNameAndTier(state)
		local k

		if not v97 then
			k = tonumber(data.k) or nil
		end

		local keys = k and math.clamp(math.floor(k + 0.5), 1, 8)

		if state.Shown.Keys ~= keys or state.Shown.KeysInit == nil then
			state.Shown.KeysInit = true
			state.Shown.Keys = keys
			state.KeyTag.Visible = keys ~= nil

			if keys then
				state.KeyText.Text = tostring(keys) .. " KEY"
			end
		end

		applyFocusVisual(state)
	end

	local function layoutSizes()
		v30 = math.max(v29, 1) * 42 + 62 + 6 - 4
		local v95 = result2 ~= nil and v26 == "screen" and v94 or 0
		parent2.Size = UDim2.fromOffset(220 + v95, v30 + 0 + 52)
		parent3.Position = UDim2.fromOffset(26, 26)
		parent3.Size = UDim2.fromOffset(168, v30)
	end

	local v95 = {
		you = color6,
		streak = color12,
		combo = Color3.fromRGB(232, 132, 44),
		accuracy = Color3.fromRGB(110, 200, 120),
		mvp = Color3.fromRGB(255, 226, 120),
		band = Color3.fromRGB(255, 226, 120),
		fire = Color3.fromRGB(236, 104, 40),
		points = Color3.fromRGB(222, 220, 214),
		star = color13
	}

	local function relayoutFeed()
		for i, v96 in ipairs(v91) do
			v96.Frame.Position = UDim2.fromOffset(-6, 108 - (i - 1) * 25 - 6)
		end
	end

	do
		local function shortName(p) -- 1 equivalent call inferred from this helper
			local v96 = string.upper((tostring(p)))

			if #v96 > 10 then
				return string.sub(v96, 1, 9) .. "."
			end

			return v96
		end
	end

	local function accentPalette(p)
		local lerped = chargeUp(p, 0, 0.3):Lerp(color10, 0.45) -- inferred equivalent call
		local lerped2 = p:Lerp(Color3.fromRGB(40, 12, 8), 0.5)
		local hsv2, v96, v97 = p:ToHSV()
		return {
			lerped,
			lerped2,
			p,
			Color3.fromHSV(hsv2, math.clamp(v96 + -0.2, 0, 1), (math.clamp(v97 + 0.5, 0, 1))):Lerp(color10, 0.45)
		}
	end

	local function feedBolt(parent, p, p2, p3, object)
		local parent13 = mk("Frame", { -- inferred equivalent call
			Name = "Bolt",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(p, p2),
			Size = UDim2.fromOffset(p3, p3),
			BackgroundColor3 = color10,
			BorderSizePixel = 0,
			ZIndex = 38
		}, parent)
		circleOf(parent13) -- inferred equivalent call
		local color23 = Color3.fromRGB(196, 192, 182)
		local color24 = Color3.fromRGB(70, 68, 63)
		mk("UIGradient", { -- inferred equivalent call
			Color = ColorSequence.new(color23, color24),
			Rotation = 45
		}, parent13)

		mk("UIStroke", { Color = color7, Thickness = 1, Transparency = 0.05 }, parent13) -- inferred equivalent call
		mk("Frame", { -- inferred equivalent call
			Name = "Slot",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, -2, 0, 1),
			Rotation = object:NextInteger(0, 170),
			BackgroundColor3 = color7,
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			ZIndex = 39
		}, parent13)
	end

	local function feedTape(parent, p, p2, p3, p4, rotation, backgroundColor, rotation2, p5)
		local tape = makeTape(parent, "DirtyTape", "", p3, p4, rotation, backgroundColor, rotation2, p5)
		tape.Position = UDim2.fromOffset(p, p2)
		tape.Visible = true
		tape.ZIndex += 22

		for _, guiObject in ipairs(tape:GetDescendants()) do
			if guiObject:IsA("GuiObject") then
				guiObject.ZIndex += 22
			end
		end

		local random2 = Random.new(p5 * 13 + 5)
		local number = random2:NextNumber()
		local v96 = random2:NextInteger(0, 1)

		if number < 0.3 or number >= 0.6 and number < 0.75 then
			local v97 = number < 0.3

			for _, child in ipairs(tape:GetChildren()) do
				if child.Name ~= "Notch" then
					continue
				end

				local v98 = child.Position.X.Scale < 0.5

				if v97 and v98 or not (v97 or v98) then
					child:Destroy()
				end
			end

			v96 = v97 and 1 or 0
		end

		for _ = 1, random2:NextInteger(0, 2) do
			local v97 = 2.5 + random2:NextNumber() * 2.2
			mk("Frame", { -- inferred equivalent call
				Name = "Notch",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(v96, 0.1 + random2:NextNumber() * 0.8),
				Size = UDim2.fromOffset(v97, v97),
				Rotation = 45 + random2:NextInteger(-15, 15),
				BackgroundColor3 = color,
				BorderSizePixel = 0,
				ZIndex = tape.ZIndex + 2
			}, tape)
		end

		local sliver = tape:FindFirstChild("Sliver")

		if sliver and random2:NextNumber() < 0.4 then
			sliver:Destroy()
		end

		local crease = tape:FindFirstChild("Crease")

		if crease and random2:NextNumber() < 0.35 then
			crease:Destroy()
		end

		if random2:NextNumber() < 0.35 then
			mk("Frame", { -- inferred equivalent call
				Name = "Fiber",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.3 + random2:NextNumber() * 0.4),
				Size = UDim2.new(1, -5, 0, 1),
				Rotation = random2:NextInteger(-3, 3),
				BackgroundColor3 = color10,
				BackgroundTransparency = 0.82,
				BorderSizePixel = 0,
				ZIndex = tape.ZIndex + 1
			}, tape)
		end

		return tape
	end

	local color23 = Color3.fromRGB(116, 118, 112)
	local color24 = Color3.fromRGB(60, 60, 57)

	local function pickTapeColor(object)
		local number = object:NextNumber()
		local v96, v97

		if number < 0.4 then
			v96 = color17
			v97 = 0.15 + object:NextNumber() * 0.18
		elseif number < 0.65 then
			v96 = color18
			v97 = 0.15 + object:NextNumber() * 0.2
		elseif number < 0.85 then
			v96 = color23
			v97 = 0.05 + object:NextNumber() * 0.12
		else
			v96 = color24
			v97 = 0
		end

		return v96:Lerp(color19, v97)
	end

	local v96 = {
		function(object)
			return {
				{
					168 - object:NextInteger(8, 16),
					17,
					object:NextInteger(18, 26),
					object:NextInteger(7, 9),
					-object:NextInteger(6, 16)
				}
			}
		end,
		function(object)
			return {
				{
					object:NextInteger(0, 4),
					-1,
					object:NextInteger(14, 22),
					object:NextInteger(7, 9),
					-object:NextInteger(10, 24)
				}
			}
		end,
		function(object)
			local v97 = object:NextNumber() < 0.5 and 1 or -1
			return {
				{
					168 - object:NextInteger(14, 22),
					8.5,
					object:NextInteger(30, 40),
					object:NextInteger(7, 9),
					v97 * object:NextInteger(24, 42)
				}
			}
		end,
		function(object)
			return {
				{
					object:NextInteger(26, 112),
					18,
					object:NextInteger(26, 42),
					object:NextInteger(6, 8),
					object:NextInteger(-6, 6)
				}
			}
		end,
		function(object)
			return {
				{
					object:NextInteger(48, 104),
					-1,
					object:NextInteger(22, 36),
					object:NextInteger(6, 8),
					object:NextInteger(-5, 5)
				}
			}
		end,
		function(object)
			local v97 = 168 - object:NextInteger(10, 16)
			return {
				{
					v97,
					8.5,
					24,
					7,
					38 + object:NextInteger(-6, 6)
				},
				{
					v97 + object:NextInteger(-3, 3),
					8.5 + object:NextInteger(-2, 2),
					22,
					7,
					-36 + object:NextInteger(-6, 6)
				}
			}
		end,
		function(object)
			return {
				{
					167,
					8.5 + object:NextInteger(-3, 3),
					object:NextInteger(18, 24),
					object:NextInteger(8, 10),
					84 + object:NextInteger(-10, 10)
				}
			}
		end,
		function(object)
			return {
				{
					168 - object:NextInteger(14, 40),
					object:NextInteger(3, 14),
					object:NextInteger(9, 13),
					object:NextInteger(7, 9),
					object:NextInteger(-60, 60)
				}
			}
		end,
		function(object)
			return {
				{
					object:NextInteger(2, 8),
					17,
					object:NextInteger(14, 22),
					object:NextInteger(7, 9),
					object:NextInteger(8, 20)
				}
			}
		end
	}

	local v97 = ""

	local function decorateTapes(frame, random2, p)
		local joined = nil
		local integers = nil

		for _ = 1, 8 do
			local number = random2:NextNumber()
			local v98 = number < 0.3 and 1 or number < 0.8 and 2 or 3
			integers = {}
			local count = 0
			local integerSet = {}

			while #integers < v98 and count < 30 do
				count += 1
				local integer = random2:NextInteger(1, #v96)

				if integerSet[integer] then
					continue
				end

				integerSet[integer] = true
				table.insert(integers, integer)
			end

			table.sort(integers)
			joined = table.concat(integers, ",")

			if joined ~= v97 then
				break
			end
		end

		v97 = joined
		local count = 0

		for _, v98 in ipairs(integers) do
			for _, v99 in ipairs(v96[v98](random2)) do
				count += 1
				feedTape(
					frame,
					6 + v99[1],
					6 + v99[2],
					v99[3],
					v99[4],
					v99[5],
					pickTapeColor(random2),
					random2:NextInteger(-26, 26),
					p + count * 17
				)
			end
		end

		local number = random2:NextNumber()

		if number < 0.45 then
			feedBolt(frame, 166, 6 + random2:NextInteger(8, 13), 7, random2)
		elseif number < 0.65 then
			feedBolt(frame, 166, 14, 5, random2)
			feedBolt(frame, 166, 20, 5, random2)
		elseif number < 0.85 then
			feedBolt(frame, 174 - random2:NextInteger(10, 30), 14.5 + random2:NextInteger(-3, 3), 6, random2)
		end
	end

	local function feedStarTape(frame, random2, p, p2)
		local v98 = math.clamp(math.floor(tonumber(p) or 2), 1, 5)
		local backgroundColor = v98 >= 4 and color18:Lerp(color19, 0.12)
			or color17:Lerp(color19, 0.15 + random2:NextNumber() * 0.1)
		local v100 = feedTape(
			frame,
			149 - random2:NextInteger(0, 5),
			6 + random2:NextInteger(-3, 0),
			42,
			12,
			random2:NextInteger(-7, 7),
			backgroundColor,
			random2:NextInteger(-20, 20),
			p2
		)
		local text = v100:FindFirstChild("Text")

		if not text then
			return v100
		end

		text.Font = font3
		text.TextSize = 9
		text.RichText = true
		text.Text = string.rep("★", v98) .. "<font color=\"#8c8068\">" .. string.rep("☆", 5 - v98) .. "</font>"

		return v100
	end

	local count = 0

	local function pushFeedLine(p, p2, backgroundColor, p3, p4, p5)
		if not flag then
			return
		end

		local v98 = (p4 == nil or p4 == "Normal" or not v8[p4]) and ""
			or string.format(" <font size=\"9\" color=\"#%s\">[%s]</font>", v8[p4].Color:ToHex(), v8[p4].Label)

		local text = string.format(
			"<font color=\"#%s\">%s</font>%s  %s",
			backgroundColor:ToHex(),
			shortName(p), -- inferred equivalent call
			v98,
			p2
		)

		for _, v101 in ipairs(v91) do
			if v101.Text == text and v101.Age < 2 then
				return
			end
		end

		count += 1
		local random2 = Random.new(count * 7919 + #text)

		local v101 = {
			Name = "Feed",
			Size = UDim2.fromOffset(180, 29),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			GroupTransparency = 0,
			ZIndex = 30
		}
		local canvasGroup2 = Instance.new("CanvasGroup")

		local v102 = { Age = 0, Text = text }

		for k, v103 in pairs(v101) do
			canvasGroup2[k] = v103
		end

		canvasGroup2.Parent = parent4

		v102.Frame = canvasGroup2

		local parent = mk("Frame", { -- inferred equivalent call
			Name = "Body",
			Position = UDim2.fromOffset(6, 6),
			Size = UDim2.fromOffset(168, 17),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			ZIndex = 30
		}, v102.Frame)
		mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent) -- inferred equivalent call
		mk("UIStroke", { -- inferred equivalent call
			Color = color7,
			Thickness = 1.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}, parent)
		gradient(parent, Color3.fromRGB(255, 255, 255), Color3.fromRGB(190, 188, 182), nil) -- inferred equivalent call

		local parent13 = mk("Frame", { -- inferred equivalent call
			Name = "Accent",
			Size = UDim2.new(0, 3, 1, 0),
			BackgroundColor3 = backgroundColor,
			BorderSizePixel = 0,
			ZIndex = 32
		}, parent)
		mk("UICorner", { CornerRadius = UDim.new(0, 1) }, parent13) -- inferred equivalent call

		for i = 1, 3 do
			local parent14 = mk("Frame", { -- inferred equivalent call
				Name = "Stain",
				BackgroundColor3 = i % 2 == 0 and color9 or Color3.new(0, 0, 0),
				BackgroundTransparency = 0.74 + random2:NextNumber() * 0.12,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(random2:NextInteger(10, 138), random2:NextInteger(-3, 8)),
				Size = UDim2.fromOffset(random2:NextInteger(14, 36), random2:NextInteger(5, 12)),
				Rotation = random2:NextInteger(-25, 25),
				ZIndex = 31
			}, parent)

			mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent14) -- inferred equivalent call
		end

		for _ = 1, 3 do
			mk("Frame", { -- inferred equivalent call
				Name = "Scratch",
				BackgroundColor3 = color4,
				BackgroundTransparency = 0.8 + random2:NextNumber() * 0.1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(random2:NextInteger(6, 124), random2:NextInteger(2, 14)),
				Size = UDim2.fromOffset(random2:NextInteger(14, 40), 1),
				Rotation = random2:NextInteger(-35, 35),
				ZIndex = 31
			}, parent)
		end

		for _ = 1, 9 do
			local v105 = random2:NextNumber() > 0.4
			local integer = random2:NextInteger(1, 2)
			mk("Frame", { -- inferred equivalent call
				Name = "Speck",
				BackgroundColor3 = v105 and color4 or Color3.new(0, 0, 0),
				BackgroundTransparency = v105 and 0.78 + random2:NextNumber() * 0.12 or 0.4 + random2:NextNumber() * 0.25,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(random2:NextInteger(4, 164), random2:NextInteger(1, 15)),
				Size = UDim2.fromOffset(integer, integer),
				ZIndex = 31
			}, parent)
		end

		local parent14 = mk("Frame", { -- inferred equivalent call
			Name = "Grime",
			Position = UDim2.new(0, 0, 1, -5),
			Size = UDim2.new(1, 0, 0, 5),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			ZIndex = 31
		}, parent)

		mk("UIGradient", { -- inferred equivalent call
			Rotation = 270,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.45), NumberSequenceKeypoint.new(1, 1) })
		}, parent14)

		local image = p5 and InstrumentIcons.Get(p5)
		local v107 = image and 17 or 0

		if image then
			local size = InstrumentIcons.GetSize(p5, 13)
			mk("ImageLabel", { -- inferred equivalent call
				Name = "InstrIcon",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(14.5, 8.5),
				Size = UDim2.fromOffset(size.X, size.Y),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = image,
				ScaleType = Enum.ScaleType.Crop,
				ZIndex = 33
			}, parent)
		end

		mk("TextLabel", { -- inferred equivalent call
			Name = "Text",
			Position = UDim2.fromOffset(8 + v107, 0),
			Size = UDim2.new(1, -(36 + v107), 1, 0),
			BackgroundTransparency = 1,
			Font = font,
			RichText = true,
			TextSize = 11,
			TextColor3 = color4,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = text,
			ZIndex = 33
		}, parent)

		decorateTapes(v102.Frame, random2, count * 31)

		feedStarTape(v102.Frame, random2, p3, count * 31 + 5)

		table.insert(v91, 1, v102)

		while true do
			local v108 = #v91

			if not (v13 < v108) then
				break
			end

			v91[#v91].Frame:Destroy()
			table.remove(v91)
		end

		relayoutFeed()
		triggerMoment(1.2) -- inferred equivalent call
		local v108 = accentPalette(backgroundColor)

		local v109 = parent9
		parent9 = frame3
		local v110 = math.clamp(math.floor(tonumber(p3) or 2), 1, 5)
		burst(6, 116.5, (v and 3 or 5) + v110, 1, v108)
		burst(160, 116.5, (v and 2 or 3) + v110, v110 >= 4 and 2 or 1, v108)
		parent9 = v109
	end

	do
		local function applyTheme() -- 1 equivalent call inferred from this helper
			uiStroke.Color = v27 and color11 or color8
			uiStroke.Transparency = v27 and 0.3 or 0.55
			textLabel2.TextColor3 = v27 and color12 or color6
			v84 = nil
			v83 = -1
		end
	end

	do
		local function onGradeUp()
			triggerMoment() -- inferred equivalent call
			v61 = 1
			local v98, v99 = centerOf(parent6) -- inferred equivalent call
			burst(v98, v99, v and 8 or 14, v and 2 or 3)

			if v31 >= 50000 and (v14[text2] or 0) >= 5 then
				pushFeedLine("BAND", "GRADE " .. tostring(text2), v95.band, v15[text2] or 3)
			end
		end

		local function onMvpChange(p, mvp)
			triggerMoment(1.8) -- inferred equivalent call
			local v98 = v28[p]

			if v98 then
				v98.MvpFlash = 1
				local v99, v100 = centerOf(v98.MvpChip) -- inferred equivalent call
				burst(v99, v100, v and 6 or 10, 2)

				if v31 >= 50000 then
					pushFeedLine(
						v98.Shown.Me and "YOU" or v98.Shown.Name or "?",
						mvp == nil and "MVP" or "TAKES MVP",
						v95.mvp,
						mvp == nil and 3 or 4,
						v98.Shown.Tier,
						v98.Shown.Instr
					)
				end
			end
		end

		local function onZoneChange(p, zone)
			triggerMoment() -- inferred equivalent call
			v62 = 1
			local v99, v100 = centerOf(v18[math.clamp(math.floor(v57 * 20 + 0.5), 1, 20)]) -- inferred equivalent call
			burst(v99, v100, v and 6 or 10, v and 2 or 3)

			if p == 1 and zone == 2 then
				burst(v99, v100, 4, 1)
			end
		end

		do
			local function findStarBar() -- 3 equivalent calls inferred from this helper
				local starPowerUI = PlayerGui:FindFirstChild("StarPowerUI")
				local meterContainer = starPowerUI and starPowerUI:FindFirstChild("MeterContainer", true)

				if
					meterContainer
					and starPowerUI.Enabled
					and meterContainer.Visible
					and meterContainer.AbsoluteSize.X > 0
				then
					return meterContainer
				end

				return nil
			end
		end

		do
			local v98 = nil

			do
				local function getTrackFrame()
					if v98 == nil then
						local success4, result5 = pcall(function()
							return require(script.Parent:WaitForChild("NoteLaneUI", 5))
						end)

						v98 = success4 and result5 or false
					end

					if v98 and v98.GetTrackFrame then
						return v98.GetTrackFrame()
					end

					return nil
				end
			end

			local function reposition()
				local absoluteSize = screenGui.AbsoluteSize
				local absolutePosition = screenGui.AbsolutePosition
				local v99

				if v26 == "bar" then
					v99 = findStarBar() or nil -- inferred equivalent call
				end

				local v100 = 0
				local v101, v102

				if v99 then
					local v103 = v99.AbsolutePosition - absolutePosition
					local absoluteSize2 = v99.AbsoluteSize
					local v104 = 150 * v16
					local v105 = 196 * v16

					if v98 == nil then
						local success4, result5 = pcall(function()
							return require(script.Parent:WaitForChild("NoteLaneUI", 5))
						end)

						v98 = success4 and result5 or false
					end

					local v106

					if v98 and v98.GetTrackFrame then
						v106 = v98.GetTrackFrame()
					end

					local v107

					if v106 and v106.Parent and v106.AbsoluteSize.X > 0 then
						v107 = (v106.AbsolutePosition - absolutePosition).X - 18 - v104
					else
						v107 = v103.X - 12 - 400 - 18 - v104
					end

					local v108 = math.clamp(v107, 6, (math.max(6, absoluteSize.X - v104 - 6)))
					local v109 = math.max(6, (math.min(v103.Y + absoluteSize2.Y - v105, absoluteSize.Y - v105 - 6)))
					v101 = v108 + v104
					v102 = v109 + v105
					v100 = 0
				else
					if v then
						local v103 = screenGui.IgnoreGuiInset and 0 or GuiService:GetGuiInset().Y
						v102 = (absoluteSize.Y - v103) / 2 + v30 * uiScale.Scale / 2
					else
						v102 = absoluteSize.Y - 40
					end

					if result4 and (v26 == "screen" or v26 == "hud") then
						local topAbsY = result4.GetTopAbsY()

						if topAbsY then
							v102 = math.min(v102, topAbsY - absolutePosition.Y - 10)
						end
					end
				end

				local v103 = v30 + 0
				local scale = math.max(math.min(scale2, (v102 - v100 - 6) / v103, (absoluteSize.X - 12) / 168), 0.75)

				if math.abs(scale - uiScale.Scale) > 0.004 then
					uiScale.Scale = scale
				end

				local v105 = scale * 168
				local v106

				if v101 then
					v106 = v101 - v105
				else
					v106 = 12 + (PlayerGui:GetAttribute("BandTunerPanelW") or 0)
				end

				local v107 = math.clamp(v106, 6, (math.max(6, absoluteSize.X - v105 - 6)))
				local v108 = v103 * scale
				local v109 = math.clamp(v102, math.min(v108 + v100 + 6, absoluteSize.Y - 6), absoluteSize.Y - 6)

				if isLeftDock() then -- inferred equivalent call
					local now = os.clock()
					local v110 = math.clamp(now - v72, 0, 0.1)
					v72 = now

					if v75 == nil then
						v75 = v109
					else
						v75 += (v109 - v75) * (1 - math.exp(v110 * -9))

						if math.abs(v109 - v75) < 0.4 then
							v75 = v109
						end
					end

					v109 = v75
				else
					v75 = nil
					v72 = os.clock()
				end

				local v110

				if isLeftDock() then -- inferred equivalent call
					local v111 = v107 - scale * 26 + parent2.Size.X.Offset * scale + 4
					v110 = -(1 - from) * v111

					local v112 = v107 - scale * 26 + v110 + scale * 192
					local v113 = v109 - v30 * scale + scale * 12
					canvasGroup.Position = UDim2.fromOffset(
						math.floor(math.max(3, v112) + 0.5),
						(math.floor(v113 + 0.5))
					)

					if math.abs(uiScale4.Scale - scale) > 0.004 then
						uiScale4.Scale = scale
					end
				else
					v110 = 0
				end

				local v111 = v107 + v110
				local v112 = v109 - v108
				v66 = v111
				v67 = v112
				v68 = scale
				PlayerGui:SetAttribute("BandPlateTopAbs", nil)

				local v113 = math.floor(v107 - scale * 26 + v110 + 0.5)
				local v114 = math.floor(v109 + scale * 26 + 0.5)

				if v113 ~= v64 or v114 ~= v65 then
					v64 = v113
					v65 = v114
					parent2.Position = UDim2.fromOffset(v113, v114)
				end
			end

			local function noticeGeometry(p)
				local absoluteSize = screenGui.AbsoluteSize
				local absolutePosition = screenGui.AbsolutePosition
				local v99 = math.min(scale2, (absoluteSize.X - 12) / 168)
				local v100, selected

				if p then
					local v102 = p.AbsolutePosition - absolutePosition
					local absoluteSize2 = p.AbsoluteSize
					v100 = v102.X + absoluteSize2.X + 22
					selected = v102.Y + absoluteSize2.Y / 2 - v2 / 2 - 10 - (196 * v16 + 10)
				else
					v100 = absoluteSize.X - v99 * 168 - 12
					selected = absoluteSize.Y / 2 - v2 / 2 - 10
				end

				local v102 = math.min(v99, (math.max(0.75, (selected - 6) / 125)))
				return
					math.clamp(v100, 6, (math.max(6, absoluteSize.X - v102 * 168 - 6))),
					selected,
					v102,
					absoluteSize,
					absolutePosition
			end

			local function repositionFeed()
				local v99 = v29 >= 6 and 3 or 5
				local v100, scale, v102

				if v66 then
					v100 = v66
					scale = v68
					local absoluteSize = screenGui.AbsoluteSize

					local v103 = v67 - 24 * scale

					if isLeftDock() then -- inferred equivalent call
						v99 = math.min(v99, (math.max(1, (math.floor(((v103 - 6) / scale + 8) / 25)))))
					end

					v102 = math.min(math.max(v103, v99 * 25 * scale + 6), absoluteSize.Y - 6)
				else
					local v103

					if v26 == "bar" then
						v103 = findStarBar() or nil -- inferred equivalent call
					end

					v100, v102, scale = noticeGeometry(v103)
				end

				if v99 ~= v13 then
					v13 = v99

					while true do
						local v103 = #v91

						if not (v13 < v103) then
							break
						end

						v91[#v91].Frame:Destroy()
						table.remove(v91)
					end

					relayoutFeed()
				end

				if math.abs(scale - uiScale2.Scale) > 0.004 then
					uiScale2.Scale = scale
				end

				parent4.Position = UDim2.fromOffset(math.floor(v100 + 0.5), (math.floor(v102 + 0.5)))
			end

			function BandScoreUI.GetNoticeSlot()
				local starBar = findStarBar() -- inferred equivalent call

				if not starBar then
					return nil
				end

				local v99, v100, _, v101, v102 = noticeGeometry(starBar)
				local v103 = v102.X + v99
				return v103, v102.Y + v100 - 8 - (v and 22 or 25), v102.X + v101.X - v103 - 10
			end

			local function refreshBar(p)
				for i = 1, 20 do
					local v99 = i <= p
					local backgroundColor

					if v27 then
						backgroundColor = v99 and color13 or color12:Lerp(color2, 0.75)
					elseif v99 then
						backgroundColor = chargeUp(skillToColor((i - 0.5) / 20), 0.06, 0.25) -- inferred equivalent call
					else
						backgroundColor = color5:Lerp(color2, 0.55)
					end

					v18[i].BackgroundColor3 = backgroundColor
				end
			end

			local v99 = 1
			local function step(p)
				if v71 then
					v71.t += p
					local v101 = math.clamp(v71.t / v71.dur, 0, 1)
					local v102 = v71.to == 1
					local value = TweenService:GetValue(
						v101,
						v102 and Enum.EasingStyle.Back or Enum.EasingStyle.Cubic,
						v102 and Enum.EasingDirection.Out or Enum.EasingDirection.InOut
					)
					from = v71.from + (v71.to - v71.from) * value

					if v101 >= 1 then
						from = v71.to
						v71 = nil
					end
				end

				local v100 = v82
				v82 = v100 + (0 - v82) * math.min(1, p * 6)
				GuiFade.SetExtra(parent2, v82)
				GuiFade.SetExtra(parent4, v82)
				GuiFade.SetExtra(canvasGroup, v82)

				local visible = flag and isLeftDock() and PlayerGui:GetAttribute("HudHidden") ~= true -- inferred equivalent call

				if canvasGroup.Visible ~= visible then
					canvasGroup.Visible = visible
				end

				if visible then
					total += ((v74 and 0.02 or v69 and 0.18 or 0.1) - total) * math.min(1, p * 10)
					canvasGroup.GroupTransparency = total
					local v103 = math.clamp(from, 0, 1)
					parent11.Rotation = (1 - v103) * 90 + -45
					parent12.Rotation = 45 - (1 - v103) * 90
				else
					total = 1
				end

				if flag and not parent2.Visible then
					parent2.Visible = true
					parent4.Visible = true
				end

				local v103 = flag and (v60 > 0 and 0.02 or v27 and 0.3 or 0.38) or 1
				local v104 = v99
				local groupTransparency = v104 + (v103 - v104) * math.min(1, p * 6)
				v99 = groupTransparency
				parent2.GroupTransparency = groupTransparency

				if flag or not (groupTransparency > 0.985) then
					v60 = math.max(0, v60 - p)
					reposition()
					repositionFeed()

					v32 += (v31 - v32) * math.min(1, p * 7)

					if math.abs(v31 - v32) < 1 then
						v32 = v31
					end

					local text = formatInt(v32)

					if text ~= v87 then
						v87 = text
						textLabel4.Text = text
					end

					v58 += (v57 - v58) * math.min(1, p * 6)
					local text3 = "HEAT " .. math.floor(v58 * 100 + 0.5) .. "%"

					if text3 ~= v86 then
						v86 = text3
						textLabel3.Text = text3
					end

					local v108 = zoneOfHeat(v58) -- inferred equivalent call
					textLabel3.TextColor3 = v27 and color13 or v6[v108]

					local v110 = math.floor(v58 * 20 + 0.5)

					if v110 ~= v83 then
						v83 = v110
						refreshBar(v110)
					end

					v62 = math.max(0, v62 - p * 1.6)
					parent7.BackgroundTransparency = 1

					if text2 ~= v85 then
						v85 = text2
						parent6.Text = text2
					end

					parent6.TextColor3 = v27 and color13 or v9[text2] or color5
					v61 = math.max(0, v61 - p * 2.2)
					uiScale3.Scale = v61 * 0.45 + 1

					local v111 = 1 - math.exp(-12 * p)

					for _, v112 in pairs(v28) do
						local v113 = 62 + ((v112.Index or 1) - 1) * 42

						if v112.Y == nil then
							v112.Y = v113
						else
							v112.Y += (v113 - v112.Y) * v111

							if math.abs(v113 - v112.Y) < 0.3 then
								v112.Y = v113
							end
						end

						v112.Frame.Position = UDim2.fromOffset(6, (math.floor(v112.Y + 0.5)))

						v112.ScoreDisp += (v112.ScoreTarget - v112.ScoreDisp) * math.min(1, p * 7)

						if math.abs(v112.ScoreTarget - v112.ScoreDisp) < 1 then
							v112.ScoreDisp = v112.ScoreTarget
						end

						local v114 = formatInt(v112.ScoreDisp)

						if v112.Shown.Score ~= v114 then
							v112.Shown.Score = v114
							v112.Score.Text = v114
						end

						if v112.MvpFlash > 0 then
							v112.MvpFlash = math.max(0, v112.MvpFlash - p * 1.8)
							v112.MvpChip.BackgroundColor3 = color18:Lerp(color10, v112.MvpFlash * 0.75)
						end

						if v112.TierFlash > 0 then
							v112.TierFlash = math.max(0, v112.TierFlash - p * 1.4)
							local baseColor = v112.TierChip and v112.TierChip:GetAttribute("BaseColor")

							if baseColor then
								v112.TierChip.BackgroundColor3 = baseColor:Lerp(color10, v112.TierFlash * 0.7)
							end
						end

						if not v112.PendingTierBurst then
							continue
						end

						v112.PendingTierBurst = nil
						local v115 = v8[v112.Shown.Tier or "Normal"]

						if not (v112.TierChip and v115) then
							continue
						end

						local v116, v117 = centerOf(v112.TierChip) -- inferred equivalent call
						burst(v116, v117, v and 3 or 6, 1, accentPalette(v115.Color))
						triggerMoment(1.2) -- inferred equivalent call
					end

					for i = #v91, 1, -1 do
						local v112 = v91[i]
						v112.Age += p

						if v112.Age >= 9 then
							v112.Frame:Destroy()
							table.remove(v91, i)
							relayoutFeed()
						else
							local groupTransparency2 = not (v112.Age > 8) and 0 or (v112.Age - 8) / 1

							v112.Frame.GroupTransparency = groupTransparency2
						end
					end

					if flag and (v27 or v58 >= RockMeterConfig.FullGreen) then
						v63 -= p

						if v63 <= 0 then
							v63 = rnd(0.5, 1.2) -- inferred equivalent call
							local v112, v113, backgroundColor, backgroundColor2 = fxColors()
							local v116 = 26 + rnd(8, 160) -- inferred equivalent call
							local v117 = 26 + rnd(2, 6) -- inferred equivalent call

							if math.random() < 0.5 then
								local v118, v119 = centerOf(v18[math.clamp(v110, 1, 20)]) -- inferred equivalent call
								emitBolt(
									v118,
									v119,
									-1.5708 + rnd(-1, 1), -- inferred equivalent call
									rnd(14, 28), -- inferred equivalent call
									rnd(0.1, 0.18), -- inferred equivalent call
									backgroundColor,
									backgroundColor2
								)

								for _ = 1, 2 do
									local v120 = v118 + rnd(-4, 4) -- inferred equivalent call

									local v121 = v119
									local v122 = -1.5708 + rnd(-1.2, 1.2) -- inferred equivalent call
									local v123 = rnd(90, 200) -- inferred equivalent call
									local v124 = rnd(0.3, 0.55) -- inferred equivalent call

									if v19 <= v24 then
										continue
									end

									v24 += 1
									local v125 = acquire(61) -- inferred equivalent call
									local v126 = math.cos(v122) * v123
									local v127 = math.sin(v122) * v123
									local total2 = 0
									local v128 = 2
									v22[#v22 + 1] = function(p2): boolean
										total2 += p2

										if v124 <= total2 then
											v24 -= 1
											release(v125) -- inferred equivalent call
											return false
										else
											local v129 = math.exp(-2.4 * p2)
											v126 *= v129
											v127 = v127 * v129 + 380 * p2
											v120 += v126 * p2
											v121 += v127 * p2
											local v130 = total2 / v124
											local v131 = math.sqrt(v126 * v126 + v127 * v127)
											v125.Position = UDim2.fromOffset(v120, v121)
											v125.Rotation = math.deg((math.atan2(v127, v126)))
											v125.Size = UDim2.fromOffset(
												math.clamp(v131 * 0.045, 3, 18),
												(math.max(1.5, v128 * (1 - v130 * 0.5)))
											)
											v125.BackgroundColor3 = v112:Lerp(v113, (math.clamp(v130 * 1.5, 0, 1)))
											v125.BackgroundTransparency = v130 * v130 * 0.95
											return true
										end
									end
								end
							else
								emitBolt(
									v116,
									v117,
									rnd(0.6, 2.5), -- inferred equivalent call
									rnd(14, 26), -- inferred equivalent call
									rnd(0.1, 0.18), -- inferred equivalent call
									backgroundColor,
									backgroundColor2
								)
							end
						end
					end

					for i = #v22, 1, -1 do
						if not v22[i](p) then
							table.remove(v22, i)
						end
					end
				else
					PlayerGui:SetAttribute("BandPlateTopAbs", nil)

					if parent2.Visible then
						parent2.Visible = false
						parent4.Visible = false

						for _, v106 in ipairs(v91) do
							v106.Frame:Destroy()
						end

						v91 = {}
						clearParticles()
					end
				end
			end

			RunService.Heartbeat:Connect(step)
		end

		function BandScoreUI.Show(p)
			v26 = p == "screen" and "screen" or p == "hud" and "hud" or "bar"
			flag = true
			layoutSizes()

			for _, v100 in pairs(v28) do
				applyFocusVisual(v100)
			end
		end

		function BandScoreUI.SetPanelOpen(p)
			setPanelOpen(p) -- inferred equivalent call
		end

		function BandScoreUI.IsPanelOpen()
			return v69
		end

		function BandScoreUI.Hide()
			flag = false
			v69 = true
			from = 1
			v71 = nil
			v74 = false

			if result2 then
				result2.Reset()
			end

			PlayerGui:SetAttribute("BandPlateTopAbs", nil)
			v90.valid = false
			v88 = nil
			v89 = nil
		end

		function BandScoreUI.IsShown()
			return flag
		end

		function BandScoreUI.SetStarPowerActive(p)
			local v100 = p == true

			if v27 == v100 then
				return
			end

			v27 = v100
			applyTheme() -- inferred equivalent call

			if flag then
				triggerMoment(1.4) -- inferred equivalent call
				local v101, v102 = centerOf(textLabel4) -- inferred equivalent call
				burst(v101, v102, 8, 2)
			end
		end

		local v100 = { 90, 95, 98, 99 }
		local v101 = { 2, 3, 4, 5 }

		do
			local function comboStars(lastCombo): number -- 1 equivalent call inferred from this helper
				if lastCombo < 40 then
					return 1
				end

				if lastCombo < 60 then
					return 2
				end

				if lastCombo < 100 then
					return 3
				end

				return if lastCombo < 150 then 4 else 5
			end
		end

		do
			local function streakStars(p): number -- 1 equivalent call inferred from this helper
				if p < 100 then
					return 2
				end

				if p < 200 then
					return 3
				end

				return if p < 300 then 4 else 5
			end
		end

		do
			local function tierOfPayload(p) -- 2 equivalent calls inferred from this helper
				local d = p.d

				if d == nil or d == "Normal" or not v8[d] then
					return nil
				end

				return d
			end
		end

		local v102 = { players = 0, bandLevel = 0, heatArmed = true }
		v102.players = {}

		do
			local function accLevelOf(a) -- 1 equivalent call inferred from this helper
				local v103 = 0

				for i, v104 in ipairs(v100) do
					if v104 <= a then
						v103 = i
					end
				end

				return v103
			end
		end

		local function detectMoments(p, p2, valid)
			if not valid then
				v102 = {
					players = {},
					bandLevel = math.floor(v31 / 500000),
					heatArmed = v57 < RockMeterConfig.FullGreen
				}
			end

			local v103 = v102

			for _, v104 in ipairs(p.p) do
				if not (v104.u ~= nil and v104.au ~= 1) then
					continue
				end

				local v105 = p2 ~= nil and v104.u == p2 and "YOU" or tostring(v104.n or "?")
				local c = tonumber(v104.c) or 0
				local a = tonumber(v104.a) or 0
				local s = tonumber(v104.s) or 0
				local player = v103.players[v104.u]

				if player then
					if c < player.lastCombo and player.lastCombo >= 30 and player.lastCombo > player.record then
						player.record = player.lastCombo
						pushFeedLine(
							v105,
							"BEST COMBO " .. player.lastCombo,
							v95.combo,
							comboStars(player.lastCombo), -- inferred equivalent call
							tierOfPayload(v104), -- inferred equivalent call
							v104.i
						)
					end

					player.lastCombo = c

					if s >= 30000 then
						local accLevel = accLevelOf(a) -- inferred equivalent call

						if player.accLevel < accLevel then
							player.accLevel = accLevel
							pushFeedLine(
								v105,
								string.format("ACCURACY %d%%", v100[accLevel]),
								v95.accuracy,
								v101[accLevel],
								tierOfPayload(v104), -- inferred equivalent call
								v104.i
							)
						elseif accLevel < player.accLevel and a < v100[player.accLevel] - 1.5 then
							player.accLevel = accLevel
						end
					end
				else
					local players = v103.players
					local u = v104.u
					local v106 = { lastCombo = c, record = 0, accLevel = 0 }
					local accLevel

					if s >= 30000 then
						accLevel = 0

						for i, v108 in ipairs(v100) do
							if v108 <= a then
								accLevel = i
							end
						end

						if not accLevel then
							accLevel = 0
						end
					else
						accLevel = 0
					end

					v106.accLevel = accLevel
					players[u] = v106
				end
			end

			local bandLevel = math.floor(v31 / 500000)

			if v103.bandLevel < bandLevel then
				v103.bandLevel = bandLevel

				if valid then
					pushFeedLine(
						"BAND",
						formatInt(bandLevel * 500000) .. " PTS",
						v95.points,
						(math.min(5, bandLevel + 1))
					)
				end
			elseif bandLevel < v103.bandLevel then
				v103.bandLevel = bandLevel
			end

			if v57 >= RockMeterConfig.FullGreen then
				if v103.heatArmed and valid and v31 >= 50000 then
					pushFeedLine("BAND", "ON FIRE", v95.fire, 4)
				end

				v103.heatArmed = false
			elseif v57 < 0.8 then
				v103.heatArmed = true
			end
		end

		function BandScoreUI.SetPayload(p, p2)
			if p == v88 and p2 == v89 then
				return
			end

			v88 = p
			v89 = p2

			if type(p) ~= "table" or type(p.p) ~= "table" or type(p.band) ~= "table" then
				return
			end

			local band = p.band
			v31 = tonumber(band.sc) or 0
			v57 = math.clamp(tonumber(band.ht) or RockMeterConfig.Start, 0, 1)
			local gr = tostring(band.gr or "-")

			if not v90.valid then
				v32 = v31
				v58 = v57
			end

			local uSet = {}
			local mvp2 = nil
			local count2 = 0
			us = {}

			for _, v104 in ipairs(p.p) do
				if count2 >= 7 then
					break
				end

				local u = v104.u

				if u == nil then
					continue
				end

				count2 += 1
				local v105 = v28[u]

				if not v105 then
					v105 = createRow(u)
					v28[u] = v105

					if not v90.valid then
						v105.ScoreDisp = tonumber(v104.s) or 0
					end
				end

				uSet[u] = true
				v105.Index = count2
				us[count2] = u
				updateRow(v105, v104, p2 ~= nil and u == p2)

				if v104.mv == 1 then
					mvp2 = u
				end
			end

			for k, v104 in pairs(v28) do
				if uSet[k] then
					continue
				end

				v104.Frame:Destroy()
				v28[k] = nil
			end

			v29 = count2
			layoutSizes()
			fn()

			if result2 then
				local v104 = {}

				if v26 == "screen" then
					for _, v105 in ipairs(p.p) do
						if not (v105.u ~= nil and v105.au ~= 1 and type(v105.i) == "string") then
							continue
						end

						v104[v105.u] = v105.i
					end
				end

				result2.SetPresent(v104)
			end

			local zone2 = zoneOfHeat(v57) -- inferred equivalent call
			local v105 = v14[v90.grade or ""] or 0
			local zone = v90.zone
			local mvp = v90.mvp
			text2 = gr
			v90.grade = gr
			v90.zone = zone2
			v90.mvp = mvp2

			if v90.valid then
				if v105 < (v14[gr] or 0) then
					onGradeUp()
				end

				if mvp2 ~= nil and mvp2 ~= mvp then
					onMvpChange(mvp2, mvp)
				end

				if zone2 ~= zone then
					onZoneChange(zone2, zone)
				end
			end

			detectMoments(p, p2, v90.valid)
			v90.valid = true
		end
	end

	function BandScoreUI.PushFeed(p, p2, p3, p4)
		local v103

		if p4 ~= nil then
			v103 = v28[p4] or nil
		end

		local v104 = tonumber(p2) or 0
		local v105 = string.format("%d %s", v104, p3 and "COMBO" or "STREAK")
		local you = p3 and v95.you or v95.streak
		local v106 = streakStars(v104) -- inferred equivalent call
		local v107

		if v103 then
			v107 = v103.Shown.Tier or nil
		end

		pushFeedLine(p, v105, you, v106, v107, v103 and v103.Shown.Instr or nil)
	end

	function BandScoreUI.PushMoment(p, p2, p3, p4, value)
		local v103

		if p4 ~= nil then
			v103 = v28[p4] or nil
		end

		local v104 = tostring(p2)
		local backgroundColor = v95[p3] or v95.band
		local v107

		if v103 then
			v107 = v103.Shown.Tier or nil
		end

		pushFeedLine(p, v104, backgroundColor, value or 3, v107, v103 and v103.Shown.Instr or nil)
	end
end

return BandScoreUI