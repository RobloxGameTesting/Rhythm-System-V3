local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local CustomGuitarConfig = require(script.Parent:WaitForChild("CustomGuitarConfig"))
local CustomGuitarBuilder = require(script.Parent:WaitForChild("CustomGuitarBuilder"))

local CustomGuitarCelebration = {}

local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function fontOr(p, p2) -- 3 equivalent calls inferred from this helper
	local success, result = pcall(function()
		return Enum.Font[p]
	end)
	return success and result or p2
end

local GothamBlack = Enum.Font.GothamBlack
GothamBlack = fontOr("PermanentMarker", GothamBlack) -- inferred equivalent call
local GothamBold = Enum.Font.GothamBold
GothamBold = fontOr("SpecialElite", GothamBold) -- inferred equivalent call
local gothamBold = Enum.Font.GothamBold
gothamBold = fontOr("Oswald", gothamBold) -- inferred equivalent call
local v2 = {
	Plate = Color3.fromRGB(26, 25, 23),
	Edge = Color3.fromRGB(122, 120, 114),
	Rust = Color3.fromRGB(104, 58, 34),
	Well = Color3.fromRGB(8, 8, 9),
	Tape = Color3.fromRGB(206, 190, 150),
	TapeDark = Color3.fromRGB(96, 90, 80),
	TapeLine = Color3.fromRGB(70, 62, 48),
	Ink = Color3.fromRGB(20, 18, 16),
	Bone = Color3.fromRGB(222, 220, 214),
	Dim = Color3.fromRGB(74, 72, 66),
	Black = Color3.fromRGB(6, 6, 7)
}
local v3 = v and 6 or 16
local v4 = v and 30 or 90
local v5 = v and 14 or 36
local flag = false

local function rnd(p, p2) -- 54 equivalent calls inferred from this helper
	return p + math.random() * (p2 - p)
end

local function at(p, p2) -- 22 equivalent calls inferred from this helper
	return UDim2.new(0.5, p, 0.5, p2)
end

local function tween(instance, duration, goal, p, p2)
	local tween2 = TweenService:Create(
		instance,
		TweenInfo.new(duration, p or Enum.EasingStyle.Quad, p2 or Enum.EasingDirection.Out),
		goal
	)
	tween2:Play()
	return tween2
end

local function mk(className, items, parent) -- 64 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function luminance(data) -- 3 equivalent calls inferred from this helper
	return 0.299 * data.R + 0.587 * data.G + 0.114 * data.B
end

local function textOn(data) -- 1 equivalent call inferred from this helper
	return luminance(data) > 0.5 and v2.Ink or v2.Bone -- inferred equivalent call
end

local function playInternal(data)
	if flag then
		return "continue"
	end

	local design = data and data.Design
	local v6 = design and CustomGuitarConfig.GetFamily(design.Family)

	if not v6 then
		return "continue"
	end

	flag = true

	local connection = Players.LocalPlayer
	local isNew = data.IsNew ~= false
	local v7 = CustomGuitarConfig.Finishes[design.Finish]

	local function readable(data2) -- 2 equivalent calls inferred from this helper
		if luminance(data2) < 0.32 then -- inferred equivalent call
			return data2:Lerp(v2.Bone, 0.45)
		end

		return data2
	end

	local color2 = CustomGuitarConfig.GetColor(design.Colors.Body) or v2.Bone
	local v8 = CustomGuitarConfig.GetColor(design.Colors.Accents)
		or CustomGuitarConfig.GetColor(design.Colors.Neck)
		or color2
	local v9 = readable(color2) -- inferred equivalent call
	v8 = readable(v8) -- inferred equivalent call
	local lerped = v9:Lerp(Color3.new(1, 1, 1), 0.82)

	local lerped2 = v9:Lerp(Color3.new(1, 1, 1), 0.85)

	if luminance(color2) > 0.8 then -- inferred equivalent call
		color2 = color2:Lerp(v2.Ink, 0.2)
	end

	local currentCamera = Workspace.CurrentCamera
	local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
	local scale = math.clamp(math.min((viewportSize.Y - 24) / 824, (viewportSize.X - 24) / 740), 0.4, 1.2)
	local v10 = viewportSize.X / 2
	local v11 = viewportSize.Y / 2
	local v12 = v11 + scale * -108

	local v13 = {
		Name = "CustomGuitarCelebration",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 120,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}
	local folder = connection:WaitForChild("PlayerGui")
	local screenGui = Instance.new("ScreenGui")
	local v14 = v10
	local flag2 = false
	local flag3 = false
	local finish

	for k, v15 in pairs(v13) do
		screenGui[k] = v15
	end

	screenGui.Parent = folder

	folder = Lighting
	local blurEffect = mk("BlurEffect", { Name = "CustomGuitarCelebrationBlur", Size = 0 }, folder) -- inferred equivalent call

	folder = Lighting
	local colorCorrectionEffect = mk( -- inferred equivalent call
		"ColorCorrectionEffect",
		{
			Name = "CustomGuitarCelebrationGrade",
			Saturation = 0,
			Contrast = 0,
			TintColor = Color3.new(1, 1, 1)
		},
		folder
	)

	local textButton = mk("TextButton", { -- inferred equivalent call
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = v2.Black,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1
	}, screenGui)

	local function vignette(anchorPoint, position, size, rotation)
		local parent = mk("Frame", { -- inferred equivalent call
			BackgroundColor3 = v2.Black,
			BorderSizePixel = 0,
			AnchorPoint = anchorPoint,
			Position = position,
			Size = size,
			ZIndex = 2
		}, screenGui)

		mk("UIGradient", { -- inferred equivalent call
			Rotation = rotation,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(1, 1) })
		}, parent)
	end
	vignette(Vector2.new(0, 0), UDim2.fromScale(0, 0), UDim2.fromScale(0.32, 1), 0)
	vignette(Vector2.new(1, 0), UDim2.fromScale(1, 0), UDim2.fromScale(0.32, 1), 180)
	vignette(Vector2.new(0, 0), UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.3), 90)
	vignette(Vector2.new(0, 1), UDim2.fromScale(0, 1), UDim2.fromScale(1, 0.3), 270)

	local function wallWord(text, position, rotation)
		return mk("TextLabel", { -- inferred equivalent call
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = position,
			Size = UDim2.fromOffset(scale * 700, scale * 120),
			Font = GothamBlack,
			TextSize = math.floor(math.clamp(scale, 0.5, 1) * 100),
			TextColor3 = v2.Bone,
			TextTransparency = 1,
			Text = text,
			Rotation = rotation,
			ZIndex = 3
		}, screenGui)
	end

	local v15 = wallWord("NO RULES", UDim2.fromScale(0.78, 0.2), -8)
	local v16 = wallWord("PLAY LOUD", UDim2.fromScale(0.22, 0.82), 7)

	local frame3 = mk("Frame", { -- inferred equivalent call
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = at(0, 0), -- inferred equivalent call
		Size = UDim2.fromOffset(640, 800),
		BackgroundColor3 = v2.Plate,
		BorderSizePixel = 0,
		Rotation = -5,
		Visible = false,
		ZIndex = 5
	}, screenGui)

	mk("UICorner", { CornerRadius = UDim.new(0, 2) }, frame3) -- inferred equivalent call
	mk( -- inferred equivalent call
		"UIStroke",
		{
			Color = v2.Edge,
			Thickness = 1.6,
			Transparency = 0.2,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		},
		frame3
	)
	mk("UIGradient", { -- inferred equivalent call
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(205, 200, 195)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 145, 140))
		})
	}, frame3)

	local uiScale = mk("UIScale", { Scale = scale }, frame3) -- inferred equivalent call
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 1.3

	local parent = mk( -- inferred equivalent call
		"Frame",
		{
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(10, 12),
			Size = UDim2.new(1, -18, 1, -23),
			ZIndex = 6
		},
		frame3
	)

	mk( -- inferred equivalent call
		"UIStroke",
		{
			Color = v2.Dim,
			Thickness = 1,
			Transparency = 0.2,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		},
		parent
	)

	local function rust(anchorPoint, position, size, rotation)
		local parent2 = mk("Frame", { -- inferred equivalent call
			BackgroundColor3 = v2.Rust,
			BorderSizePixel = 0,
			AnchorPoint = anchorPoint,
			Position = position,
			Size = size,
			ZIndex = 6
		}, frame3)

		mk("UIGradient", { -- inferred equivalent call
			Rotation = rotation,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 1) })
		}, parent2)
	end
	rust(Vector2.new(1, 0), UDim2.new(1, 0, 0, 0), UDim2.fromOffset(210, 130), 135)
	rust(Vector2.new(0, 1), UDim2.new(0, 0, 1, 0), UDim2.fromOffset(250, 120), -45)
	rust(Vector2.new(0, 0.5), UDim2.new(0, 0, 0.55, 0), UDim2.fromOffset(70, 230), 0)
	rust(Vector2.new(1, 1), UDim2.new(1, 0, 1, 0), UDim2.fromOffset(150, 90), -135)

	for _ = 1, 30 do
		mk("Frame", { -- inferred equivalent call
			BackgroundColor3 = v2.Edge,
			BackgroundTransparency = 0.78 + math.random() * 0.14,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.04 + math.random() * 0.9199999999999999, 0, 0.03 + math.random() * 0.94, 0),
			Size = UDim2.fromOffset(30 + math.random() * 160, 1),
			Rotation = -50 + math.random() * 100,
			ZIndex = 6
		}, frame3)
	end

	local function blotch(p, p2, p3, backgroundColor, backgroundTransparency)
		local parent2 = mk("Frame", { -- inferred equivalent call
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = backgroundTransparency,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(p, p2),
			Size = UDim2.fromOffset(p3, p3 * rnd(0.7, 1.2)), -- inferred equivalent call
			ZIndex = 6
		}, frame3)

		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
	end

	for _ = 1, 4 do
		blotch(
			40 + math.random() * 560,
			40 + math.random() * 720,
			50 + math.random() * 60,
			v2.Ink,
			0.65 + math.random() * 0.16999999999999993
		)
	end

	for _ = 1, 22 do
		local v17 = math.random()
		local bone = v17 < 0.4 and v2.Bone or v17 < 0.7 and v2.Rust or v2.Ink
		blotch(
			14 + math.random() * 612,
			14 + math.random() * 772,
			3 + math.random() * 17,
			bone,
			0.45 + math.random() * 0.43
		)
	end

	for _, v17 in ipairs({
		{ 20, 24 },
		{ 616, 20 },
		{ 24, 780 },
		{ 620, 775 },
		{ 334, 19 },
		{ 302, 779 }
	}) do
		local parent2 = mk("Frame", { -- inferred equivalent call
			BackgroundColor3 = v2.Edge,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(v17[1], v17[2]),
			Size = UDim2.fromOffset(9, 9),
			ZIndex = 7
		}, frame3)

		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
		mk("UIStroke", { Color = v2.Ink, Thickness = 1, Transparency = 0.2 }, parent2) -- inferred equivalent call
	end

	local function edgeScrawl(text, p, p2, rotation, textSize)
		mk("TextLabel", { -- inferred equivalent call
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(p, p2),
			Size = UDim2.fromOffset(200, textSize + 6),
			Font = GothamBlack,
			TextSize = textSize,
			TextColor3 = v2.Bone,
			TextTransparency = 0.5,
			Text = text,
			Rotation = rotation,
			ZIndex = 7
		}, frame3)
	end
	edgeScrawl("DIY OR DIE", 625, 150, 90, 20)
	edgeScrawl("LOUDER", 16, 560, -90, 20)

	local function stageLine(p, p2, p3, p4, p5, backgroundColor, zIndex, value)
		local v17 = 320 + p
		local v18 = 400 + p2
		local v19 = 320 + p3
		local v20 = 400 + p4
		local v21 = v19 - v17
		local v22 = v20 - v18
		return mk("Frame", { -- inferred equivalent call
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = value or 0,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset((v17 + v19) / 2, (v18 + v20) / 2),
			Size = UDim2.fromOffset(math.sqrt(v21 * v21 + v22 * v22) + 1, p5),
			Rotation = math.deg((math.atan2(v22, v21))),
			ZIndex = zIndex
		}, frame3)
	end

	local parent2 = mk("Frame", { -- inferred equivalent call
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = at(0, -108), -- inferred equivalent call
		Size = UDim2.fromOffset(560, 410),
		BackgroundColor3 = v2.Well,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 8
	}, frame3)

	mk( -- inferred equivalent call
		"UIStroke",
		{
			Color = v2.Edge,
			Thickness = 1.6,
			Transparency = 0.3,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		},
		parent2
	)
	mk( -- inferred equivalent call
		"UIGradient",
		{
			Rotation = 90,
			Color = ColorSequence.new(Color3.fromRGB(46, 45, 47), Color3.fromRGB(8, 8, 9))
		},
		parent2
	)

	local parent3 = mk( -- inferred equivalent call
		"Frame",
		{
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(3, 3),
			Size = UDim2.new(1, -6, 1, -6),
			ZIndex = 9
		},
		parent2
	)

	local uiStroke = mk( -- inferred equivalent call
		"UIStroke",
		{
			Color = v9,
			Thickness = 1.5,
			Transparency = 0.8,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		},
		parent3
	)

	local v17 = {}

	for _, v18 in ipairs({
		{ 440, 0.978 },
		{ 320, 0.968 },
		{ 210, 0.955 }
	}) do
		local frame = mk("Frame", { -- inferred equivalent call
			BackgroundColor3 = v9:Lerp(v2.Bone, 0.4),
			BackgroundTransparency = v18[2],
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(v18[1], v18[1]),
			ZIndex = 9
		}, parent2)

		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, frame) -- inferred equivalent call
		table.insert(v17, { Frame = frame, Base = v18[2] })
	end

	local v18 = {}

	for _, v19 in ipairs({
		{ -298, -318, 289, -314 },
		{ 283, -328, 288, 108 },
		{ 294, 102, -291, 99 },
		{ -284, 110, -289, -324 }
	}) do
		table.insert(v18, (stageLine(v19[1], v19[2], v19[3], v19[4], 2, v2.Bone, 7, 1)))
	end

	local frame4 = mk("Frame", { -- inferred equivalent call
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, -410),
		Size = UDim2.fromOffset(380, 410),
		ZIndex = 10
	}, parent2)

	local parent4 = mk("ViewportFrame", { -- inferred equivalent call
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Ambient = Color3.fromRGB(105, 105, 115),
		LightColor = Color3.fromRGB(255, 246, 232),
		ZIndex = 10
	}, frame4)

	local currentCamera2 = mk("Camera", { FieldOfView = 24 }, parent4) -- inferred equivalent call
	parent4.CurrentCamera = currentCamera2

	folder = CustomGuitarBuilder.Build(design, "GuitarRhythm")

	local unit = v6.PreviewFront.Unit
	local v19, v20

	if folder then
		for _, part in ipairs(folder:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end

		folder:PivotTo(CFrame.new())
		folder.Parent = parent4
		local boundingBox, v21 = folder:GetBoundingBox()
		v19 = boundingBox.Position
		v20 = v21.Magnitude / 2 / math.sin((math.rad(currentCamera2.FieldOfView / 2))) * 0.9
	else
		v19 = Vector3.new(0, 0, 0)
		v20 = 10
	end

	local function updateCamera(p)
		local vectorToWorldSpace = CFrame.Angles(0, p, 0):VectorToWorldSpace(unit)
		currentCamera2.CFrame = CFrame.lookAt(v19 + vectorToWorldSpace * v20, v19, Vector3.new(0, 1, 0)) * CFrame.Angles(0, 0, 0.24434609527920614)
		parent4.LightDirection = -vectorToWorldSpace + Vector3.new(0.5, -0.8, 0)
	end
	updateCamera(-1.3)

	local v21 = os.clock() + 3
	local lastTime = nil
	local v22 = 0
	local function kick(p) -- 6 equivalent calls inferred from this helper
		if v21 < os.clock() then
			return
		end

		lastTime = os.clock()
		v22 = p
	end

	local function makeSfx(soundId, p, p2)
		local v23 = {}
		local v24 = {}

		for i = 1, p do
			v23[i] = mk("Sound", { SoundId = soundId, Volume = 0 }, screenGui) -- inferred equivalent call
		end

		task.spawn(function()
			pcall(function()
				local ContentProvider = game:GetService("ContentProvider")
				ContentProvider:PreloadAsync(v23)
			end)
		end)
		local v25 = 0

		return function(duration, value, value2, value3)
			if flag2 then
				return
			end

			local now = os.clock()

			if now - v25 < p2 then
				return
			end

			for i, v26 in ipairs(v23) do
				if not v24[i] then
					v25 = now
					v24[i] = true
					local v27 = v26.TimeLength - duration - 0.05
					local timePosition

					if v27 > 0 then
						timePosition = rnd(0, v27 * (value3 or 0)) or 0 -- inferred equivalent call
					else
						timePosition = 0
					end

					v26.TimePosition = timePosition
					local v28 = value or 0.95
					v26.PlaybackSpeed = v28 + math.random() * ((value2 or 1.08) - v28)
					v26.Volume = 0.01
					v26:Play()
					task.delay(duration, function()
						if v26.Parent then
							TweenService:Create(
								v26,
								TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{ Volume = 0 }
							):Play()
							task.wait(0.05)
							v26:Stop()
						end

						v24[i] = false
					end)
					break
				end
			end
		end
	end

	local sfx = makeSfx("rbxassetid://9113957245", 2, 0.2)
	local sfx2 = makeSfx("rbxassetid://9119907907", 3, 0.12)

	local function spaced(value) -- 1 equivalent call inferred from this helper
		local v23 = string.gsub(string.upper(value), "(.)", "%1 ")
		return (string.gsub(v23, " $", ""))
	end

	local function makePlate(data2)
		local z = data2.Z or 12
		local offset = data2.Size.X.Offset
		local offset2 = data2.Size.Y.Offset
		local frame = mk("Frame", { -- inferred equivalent call
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = data2.Pos,
			Size = data2.Size,
			Rotation = data2.Rot,
			BackgroundColor3 = Color3.fromRGB(58, 57, 54),
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = z
		}, frame3)

		mk("UICorner", { CornerRadius = UDim.new(0, 2) }, frame) -- inferred equivalent call
		mk( -- inferred equivalent call
			"UIStroke",
			{
				Color = v2.Edge,
				Thickness = 1.8,
				Transparency = 0.1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			},
			frame
		)
		mk("UIGradient", { -- inferred equivalent call
			Rotation = 90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(178, 176, 172)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 118, 114))
			})
		}, frame)

		local scale2 = mk("UIScale", { Scale = 1.7 }, frame) -- inferred equivalent call

		local parent5 = mk("Frame", { -- inferred equivalent call
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(5, 5),
			Size = UDim2.new(1, -10, 1, -10),
			ZIndex = z + 1
		}, frame)

		mk( -- inferred equivalent call
			"UIStroke",
			{
				Color = v2.Black,
				Thickness = 1,
				Transparency = 0.35,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			},
			parent5
		)

		local parent6 = mk("Frame", { -- inferred equivalent call
			BackgroundColor3 = v2.Rust,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.fromOffset(offset * 0.28, offset2),
			ZIndex = z + 1
		}, frame)

		mk("UIGradient", { -- inferred equivalent call
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.45) })
		}, parent6)

		for _ = 1, 7 do
			mk("Frame", { -- inferred equivalent call
				BackgroundColor3 = v2.Edge,
				BackgroundTransparency = rnd(0.7, 0.88), -- inferred equivalent call
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(rnd(0.05, 0.95), 0, rnd(0.1, 0.9), 0), -- inferred equivalent call
				Size = UDim2.fromOffset(rnd(14, 60), 1), -- inferred equivalent call
				Rotation = rnd(-35, 35), -- inferred equivalent call
				ZIndex = z + 2
			}, frame)
		end

		for _, position in ipairs({
			UDim2.new(0, 11, 0, 11),
			UDim2.new(1, -11, 0, 11),
			UDim2.new(0, 11, 1, -11),
			UDim2.new(1, -11, 1, -11)
		}) do
			local parent7 = mk("Frame", { -- inferred equivalent call
				BackgroundColor3 = Color3.fromRGB(150, 148, 142),
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = position,
				Size = UDim2.fromOffset(8, 8),
				ZIndex = z + 4
			}, frame)

			mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent7) -- inferred equivalent call
			mk("UIStroke", { Color = v2.Ink, Thickness = 1, Transparency = 0.1 }, parent7) -- inferred equivalent call
		end

		local parent7 = mk("TextLabel", { -- inferred equivalent call
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -48, 1, -14),
			Font = data2.Font,
			TextColor3 = data2.TextColor,
			TextScaled = true,
			Text = data2.Text,
			ZIndex = z + 3
		}, frame)

		mk("UITextSizeConstraint", { MaxTextSize = data2.TextSize, MinTextSize = 8 }, parent7) -- inferred equivalent call
		mk("UIStroke", { -- inferred equivalent call
			Color = v2.Ink,
			Thickness = data2.StrokeThickness or 2
		}, parent7)

		for _ = 1, 12 do
			mk("Frame", { -- inferred equivalent call
				BackgroundColor3 = Color3.fromRGB(72, 71, 68),
				BackgroundTransparency = 0.05,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(rnd(0.08, 0.92), 0, rnd(0.2, 0.8), 0), -- inferred equivalent call
				Size = UDim2.fromOffset(rnd(2, 8), rnd(1, 3)), -- inferred equivalent call
				Rotation = rnd(-40, 40), -- inferred equivalent call
				ZIndex = z + 5
			}, frame)
		end

		return { Frame = frame, Scale = scale2, Rot = data2.Rot }
	end

	local function slamPlate(plate, p)
		if flag2 then
			return
		end

		plate.Frame.Rotation = plate.Rot + rnd(-6, 6) -- inferred equivalent call
		plate.Frame.Visible = true
		TweenService:Create(plate.Scale, TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
		local frame = plate.Frame
		local v23 = { Rotation = plate.Rot }
		local back = Enum.EasingStyle.Back
		TweenService:Create(frame, TweenInfo.new(0.16, back or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), v23):Play()

		if p > 0 then
			sfx2(0.3, 0.95, 1.1, 0)
		end

		kick(p) -- inferred equivalent call
	end

	local plate = makePlate({
		Pos = at(0, -348), -- inferred equivalent call
		Size = UDim2.fromOffset(576, 64),
		Rot = -1.4,
		Text = spaced(isNew and "BUILT NOT BOUGHT" or "REWIRED. STILL YOURS."), -- inferred equivalent call
		Font = gothamBold,
		TextSize = 34,
		TextColor = v2.Bone,
		Z = 12
	})

	local v23 = (v6.Name or "Guitar") .. " / " .. (v7 and v7.Label or "Gloss")
	local plate2 = makePlate({
		Pos = at(0, 240), -- inferred equivalent call
		Size = UDim2.fromOffset(470, 38),
		Rot = 0.9,
		Text = string.upper(v23),
		Font = GothamBold,
		TextSize = 19,
		TextColor = Color3.fromRGB(205, 201, 191),
		StrokeThickness = 1,
		Z = 12
	})

	local textLabel = mk("TextLabel", { -- inferred equivalent call
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = at(0, 146), -- inferred equivalent call
		Size = UDim2.fromOffset(560, 72),
		Font = GothamBlack,
		TextSize = 54,
		TextColor3 = v2.Bone,
		TextScaled = true,
		Text = string.upper(design.Name),
		Rotation = -3.4,
		MaxVisibleGraphemes = 0,
		ZIndex = 12
	}, frame3)

	mk("UITextSizeConstraint", { MaxTextSize = 54, MinTextSize = 22 }, textLabel) -- inferred equivalent call
	mk("UIStroke", { Color = v2.Ink, Thickness = 3 }, textLabel) -- inferred equivalent call

	local lerped3 = v8:Lerp(v2.Bone, 0.2)
	local v24 = -200
	local v25 = 192
	local v26 = {}

	for i = 1, 11 do
		local v27 = -200 + i * 38
		local v28 = 192 + (i % 2 == 0 and 6 or -5) * (0.6 + math.random() * 0.7000000000000001)
		table.insert(v26, (stageLine(v24, v25, v27, v28, 3, lerped3, 12, 1)))
		v25 = v28
		v24 = v27
	end

	local v27 = 214
	local v28 = 206

	for i = 1, 8 do
		local v29 = 214 - i * 44
		local v30 = 206 + (i % 2 == 0 and 5 or -4) * (0.6 + math.random() * 0.7000000000000001)
		table.insert(v26, (stageLine(v27, v28, v29, v30, 2.5, lerped3, 12, 1)))
		v28 = v30
		v27 = v29
	end

	local function revealScribble()
		for i, v29 in ipairs(v26) do
			task.delay(i * 0.014, function()
				if not flag2 then
					TweenService:Create(v29, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundTransparency = 0.05
					}):Play()
				end
			end)
		end
	end

	local function doodleBolt(p, p2, p3)
		local v29 = {
			{ 0, 0 },
			{ 9, -24 },
			{ -6, -22 },
			{ 7, -52 },
			{ -3, -48 },
			{ 10, -70 }
		}

		for i = 1, #v29 - 1 do
			stageLine(p + v29[i][1] * p3, p2 + v29[i][2], p + v29[i + 1][1] * p3, p2 + v29[i + 1][2], 3, v9, 11, 0.12)
		end
	end
	doodleBolt(-302, 12, 1)
	doodleBolt(300, -128, -1)

	local function makeTape(data2)
		local v29 = data2.Button and "TextButton" or "TextLabel"
		local z = data2.Z or 12
		local frame = mk(v29, { -- inferred equivalent call
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = data2.Pos,
			Size = data2.Size,
			Rotation = data2.Rot,
			BackgroundColor3 = data2.Color,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = data2.Font or GothamBold,
			TextSize = data2.TextSize or 18,
			TextColor3 = data2.TextColor or v2.Ink,
			Text = data2.Text or "",
			TextTransparency = 1,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = z
		}, frame3)

		if data2.Button then
			frame.AutoButtonColor = false
		end

		local stroke = mk( -- inferred equivalent call
			"UIStroke",
			{
				Color = v2.TapeLine,
				Thickness = 1,
				Transparency = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			},
			frame
		)
		mk( -- inferred equivalent call
			"UIGradient",
			{
				Rotation = 90,
				Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(214, 210, 202))
			},
			frame
		)

		local scale2 = mk("UIScale", { Scale = 1.9 }, frame) -- inferred equivalent call

		local extras = {}
		local function jag(p)
			for i = 1, 4 do
				local frame2 = mk("Frame", { -- inferred equivalent call
					BackgroundColor3 = v2.Plate,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(p, rnd(-1, 1), (i - 0.5) / 4 + rnd(-0.07, 0.07), 0), -- inferred equivalent call
					Size = UDim2.fromOffset(rnd(6, 11), rnd(6, 11)), -- inferred equivalent call
					Rotation = rnd(25, 65), -- inferred equivalent call
					ZIndex = z + 1
				}, frame)

				extras[#extras + 1] = { Frame = frame2, Target = 0.05 }
			end
		end
		jag(0)
		jag(1)

		for _ = 1, 2 do
			local frame2 = mk("Frame", { -- inferred equivalent call
				BackgroundColor3 = v2.Ink,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(rnd(0.12, 0.88), 0, 0, 0), -- inferred equivalent call
				Size = UDim2.new(0, 1, 1, 0),
				ZIndex = z + 1
			}, frame)

			extras[#extras + 1] = { Frame = frame2, Target = 0.78 }
		end

		return {
			Frame = frame,
			Scale = scale2,
			Stroke = stroke,
			BaseT = data2.BaseT or 0.12,
			Rotation = data2.Rot,
			Extras = extras
		}
	end

	local function slap(data2, value)
		local frame = data2.Frame
		local v29 = { BackgroundTransparency = data2.BaseT, TextTransparency = 0 }
		TweenService:Create(frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), v29):Play()
		TweenService:Create(data2.Stroke, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 0.55
		}):Play()
		TweenService:Create(data2.Scale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()

		for _, extra in ipairs(data2.Extras) do
			local frame2 = extra.Frame
			local v30 = { BackgroundTransparency = extra.Target }
			TweenService:Create(frame2, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), v30):Play()
		end

		kick(value or 3) -- inferred equivalent call
	end

	local v29 = {
		makeTape({
			Pos = at(-296, -378), -- inferred equivalent call
			Size = UDim2.fromOffset(112, 24),
			Rot = -38,
			Color = v2.Tape,
			Z = 14
		}),
		makeTape({
			Pos = at(-308, -364), -- inferred equivalent call
			Size = UDim2.fromOffset(84, 20),
			Rot = 17,
			Color = v2.TapeDark,
			Z = 15,
			BaseT = 0.16
		}),
		makeTape({
			Pos = at(292, -380), -- inferred equivalent call
			Size = UDim2.fromOffset(98, 22),
			Rot = 36,
			Color = v2.TapeDark,
			Z = 14,
			BaseT = 0.16
		}),
		makeTape({
			Pos = at(302, -370), -- inferred equivalent call
			Size = UDim2.fromOffset(88, 20),
			Rot = -21,
			Color = v2.Tape,
			Z = 15
		}),
		makeTape({
			Pos = at(-298, 376), -- inferred equivalent call
			Size = UDim2.fromOffset(102, 22),
			Rot = 34,
			Color = v2.TapeDark,
			Z = 14,
			BaseT = 0.16
		}),
		makeTape({
			Pos = at(-308, 366), -- inferred equivalent call
			Size = UDim2.fromOffset(86, 20),
			Rot = -19,
			Color = v2.Tape,
			Z = 15
		}),
		makeTape({
			Pos = at(298, 372), -- inferred equivalent call
			Size = UDim2.fromOffset(114, 24),
			Rot = -36,
			Color = v2.Tape,
			Z = 14
		}),
		makeTape({
			Pos = at(306, 382), -- inferred equivalent call
			Size = UDim2.fromOffset(84, 20),
			Rot = 24,
			Color = v2.TapeDark,
			Z = 15,
			BaseT = 0.16
		})
	}

	local v30 = {}

	for i, v31 in ipairs({
		{ -1, -1 },
		{ 1, -1 },
		{ 1, 1 },
		{ -1, 1 }
	}) do
		local rot = v31[1] * v31[2] > 0 and -62 + math.random() * 28 or 34 + math.random() * 28
		v30[i] = makeTape({
			Pos = at(v31[1] * 278, -108 + v31[2] * 203), -- inferred equivalent call
			Size = UDim2.fromOffset(56 + math.random() * 14, 17),
			Rot = rot,
			Color = i % 2 == 0 and v2.TapeDark or v2.Tape,
			Z = 16,
			BaseT = 0.14
		})
	end

	local tape = makeTape({
		Pos = at(-120, 294), -- inferred equivalent call
		Size = UDim2.fromOffset(232, 38),
		Rot = -5.5,
		Color = color2,
		Text = isNew and "ONE OF ONE" or "REWORKED",
		Font = GothamBlack,
		TextSize = 24,
		TextColor = textOn(color2), -- inferred equivalent call
		BaseT = 0.06,
		Z = 12
	})

	local tape2 = makeTape({
		Pos = at(112, 300), -- inferred equivalent call
		Size = UDim2.fromOffset(262, 34),
		Rot = 3.4,
		Color = v2.TapeDark,
		Text = "BUILT BY " .. string.upper(connection.DisplayName),
		Font = GothamBlack,
		TextSize = 19,
		TextColor = v2.Bone,
		BaseT = 0.08,
		Z = 13
	})

	local bindableEvent = Instance.new("BindableEvent")

	local function makeButtonTape(pos, size, p, color, text, textColor, textSize, p2)
		local tape3 = makeTape({
			Pos = pos,
			Size = size,
			Rot = p,
			Color = color,
			Text = text,
			TextSize = textSize,
			TextColor = textColor,
			Font = GothamBlack,
			Button = true,
			Z = 17,
			BaseT = 0.05
		})
		local frame = tape3.Frame
		frame.MouseEnter:Connect(function()
			if flag3 then
				TweenService:Create(tape3.Scale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Scale = 1.07
				}):Play()
				local v31 = {
					Rotation = p + (math.random() < 0.5 and -2.5 or 2.5)
				}
				TweenService:Create(frame, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), v31):Play()
			end
		end)
		frame.MouseLeave:Connect(function()
			TweenService:Create(tape3.Scale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = 1
			}):Play()
			TweenService:Create(frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Rotation = p
			}):Play()
		end)
		frame.MouseButton1Click:Connect(function()
			if flag3 then
				finish(p2)
			end
		end)
		return tape3
	end

	local tape3 = makeTape({
		Pos = at(-116, 362), -- inferred equivalent call
		Size = UDim2.fromOffset(268, 56),
		Rot = 5.5,
		Color = v2.TapeDark,
		Z = 14,
		BaseT = 0.1
	})
	local tape4 = makeTape({
		Pos = at(144, 358), -- inferred equivalent call
		Size = UDim2.fromOffset(182, 52),
		Rot = -5,
		Color = v2.Rust,
		Z = 14,
		BaseT = 0.08
	})
	local buttonTape = makeButtonTape(
		at(-124, 357), -- inferred equivalent call
		UDim2.fromOffset(248, 56),
		-4,
		v2.Tape,
		"STRAP IT ON",
		v2.Ink,
		27,
		"equip"
	)
	local buttonTape2 = makeButtonTape(
		at(142, 361), -- inferred equivalent call
		UDim2.fromOffset(160, 50),
		3.8,
		v2.TapeDark,
		"LATER",
		v2.Bone,
		25,
		"continue"
	)

	local parent5 = mk("Frame", { -- inferred equivalent call
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 8
	}, screenGui)
	local v31 = {}
	local v32 = {}
	local v51 = 0
	local v52 = 0
	local v53 = 0

	local function acquire(zIndex) -- 4 equivalent calls inferred from this helper
		local selected = table.remove(v31)

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
		v31[#v31 + 1] = p
	end
	local function placeLine(p, p2, p3, p4, p5, p6)
		local v54 = p4 - p2
		local v55 = p5 - p3
		p.Position = UDim2.fromOffset((p2 + p4) / 2, (p3 + p5) / 2)
		p.Size = UDim2.fromOffset(math.sqrt(v54 * v54 + v55 * v55) + 0.5, p6)
		p.Rotation = math.deg((math.atan2(v55, v54)))
	end

	local function emitSpark(total, total2, p, p2, p3, p4)
		if v4 <= v52 then
			return
		end

		v52 += 1
		local v54 = p2 * (scale * 1.15)
		local v55 = acquire(11) -- inferred equivalent call
		local v56 = math.cos(p) * v54
		local v57 = math.sin(p) * v54
		local total3 = 0
		v32[#v32 + 1] = function(p5): boolean
			total3 += p5

			if p3 <= total3 then
				v52 -= 1
				release(v55) -- inferred equivalent call
				return false
			else
				local v58 = math.exp(-2.4 * p5)
				v56 *= v58
				v57 = v57 * v58 + scale * 420 * p5
				total += v56 * p5
				total2 += v57 * p5
				local v59 = total3 / p3
				local v60 = math.sqrt(v56 * v56 + v57 * v57)
				v55.Position = UDim2.fromOffset(total, total2)
				v55.Rotation = math.deg((math.atan2(v57, v56)))
				v55.Size = UDim2.fromOffset(math.clamp(v60 * 0.045, 3, 24), (math.max(1.5, p4 * (1 - v59 * 0.5))))
				v55.BackgroundColor3 = lerped2:Lerp(v8, (math.clamp(v59 * 1.5, 0, 1)))
				v55.BackgroundTransparency = v59 * v59 * 0.95
				return true
			end
		end
	end

	local function emitEmber(total, total2, color)
		if v5 <= v53 then
			return
		end

		v53 += 1
		local v54 = acquire(10) -- inferred equivalent call
		local v55 = rnd(2, v and 3 or 4) -- inferred equivalent call
		v54.Size = UDim2.fromOffset(v55, v55)
		v54.Rotation = rnd(0, 90) -- inferred equivalent call
		v54.BackgroundColor3 = color
		local v56 = -rnd(26, 80) * scale -- inferred equivalent call
		local v57 = rnd(-12, 12) -- inferred equivalent call
		local v58 = rnd(1.6, 3) -- inferred equivalent call
		local total3 = 0
		local v59 = rnd(0, 6.28) -- inferred equivalent call

		v32[#v32 + 1] = function(p): boolean
			total3 += p

			if v58 <= total3 then
				v53 -= 1
				release(v54) -- inferred equivalent call
				return false
			else
				total += (v57 + math.sin(total3 * 6 + v59) * 14) * p
				total2 += v56 * p
				local v60 = total3 / v58
				v54.Position = UDim2.fromOffset(total, total2)
				v54.BackgroundTransparency = math.clamp(v60 * v60 + (math.random() < 0.12 and 0.4 or 0), 0, 1)
				return true
			end
		end
	end

	local v54 = {}
	local v55 = {}

	for i = 1, 5 do
		v54[i] = mk("Sound", { SoundId = "rbxassetid://5509750509", Volume = 0 }, screenGui) -- inferred equivalent call
	end

	task.spawn(function()
		pcall(function()
			local ContentProvider = game:GetService("ContentProvider")
			ContentProvider:PreloadAsync(v54)
		end)
	end)
	local v56 = 0
	local function playZap(duration, _)
		if flag2 then
			return
		end

		local now = os.clock()

		if now - v56 < 0.06 then
			return
		end

		for i, v57 in ipairs(v54) do
			if not v55[i] then
				v56 = now
				v55[i] = true
				local timeLength = v57.TimeLength
				local timePosition

				if duration + 0.05 < timeLength then
					timePosition = rnd(0, timeLength - duration - 0.05) or 0 -- inferred equivalent call
				else
					timePosition = 0
				end

				v57.TimePosition = timePosition
				v57.PlaybackSpeed = rnd(0.92, 1.12) -- inferred equivalent call
				v57.Volume = 0.01
				v57:Play()
				task.delay(duration, function()
					if v57.Parent then
						TweenService:Create(v57, TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Volume = 0
						}):Play()
						task.wait(0.05)
						v57:Stop()
					end

					v55[i] = false
				end)
				break
			end
		end
	end

	local function emitBolt(p, p2, p3, p4, p5, p6, p7, p8)
		if v3 <= v51 then
			return
		end

		v51 += 1

		if p7 then
			playZap(p5, p8 > 3 and 0.14 or 0.07)
		end

		local v57 = {}
		local v58 = {}

		for i = 1, p6 do
			local v59 = acquire(8) -- inferred equivalent call
			v59.BackgroundColor3 = v9
			v57[i] = v59
			local v60 = acquire(10) -- inferred equivalent call
			v60.BackgroundColor3 = lerped
			v58[i] = v60
		end

		local v59 = (math.cos)(p3)
		local v60 = (math.sin)(p3)
		local v61 = -v60
		local v62 = math.clamp(p4 * 0.12, 6, scale * 42)
		local function relayout()
			local v63 = {}
			local v64 = {}

			for i = 0, p6 do
				local v65 = i / p6
				local v66

				if i == 0 then
					v66 = 0
				else
					v66 = rnd(-v62, v62) * (1 - v65 * 0.25) -- inferred equivalent call
				end

				v63[i] = p + v59 * p4 * v65 + v61 * v66
				v64[i] = p2 + v60 * p4 * v65 + v59 * v66
			end

			for i = 1, p6 do
				placeLine(v57[i], v63[i - 1], v64[i - 1], v63[i], v64[i], p8 * 3)
				placeLine(v58[i], v63[i - 1], v64[i - 1], v63[i], v64[i], p8)
			end
		end
		relayout()

		if p7 and p4 > 70 then
			local v63 = rnd(0.35, 0.65) -- inferred equivalent call
			local v64 = math.random() < 0.5 and -1 or 1
			emitBolt(
				p + v59 * p4 * v63,
				p2 + v60 * p4 * v63,
				p3 + v64 * rnd(0.5, 0.9), -- inferred equivalent call
				p4 * 0.4,
				p5 * 0.85,
				(math.max)(3, p6 - 4),
				false,
				p8 * 0.8
			)
		end

		local total = 0
		local total2 = 0
		v32[#v32 + 1] = function(p9): boolean
			total += p9
			total2 += p9

			if p5 <= total then
				for i = 1, p6 do
					release(v57[i]) -- inferred equivalent call
					release(v58[i]) -- inferred equivalent call
				end

				v51 -= 1
				return false
			else
				if total2 >= 0.045 then
					total2 = 0
					relayout()
				end

				local v63 = total / p5
				local v64 = math.random() < 0.28 and 0.4 or 0
				local backgroundTransparency = math.clamp(v63 * v63 * 0.9 + v64, 0, 1)
				local backgroundTransparency2 = math.clamp(0.7 + v63 * 0.3 + v64 * 0.3, 0, 1)

				for i = 1, p6 do
					v58[i].BackgroundTransparency = backgroundTransparency
					v57[i].BackgroundTransparency = backgroundTransparency2
				end

				return true
			end
		end
	end

	local function sparkBurst(p, p2, p3, p4, p5, p6)
		for _ = 1, p3 do
			emitSpark(
				p,
				p2,
				p6 and -1.5707963267948966 + rnd(-1.3, 1.3) or rnd(0, 6.283185307179586), -- inferred equivalent call
				rnd(p4, p5), -- inferred equivalent call
				rnd(0.5, 1.1), -- inferred equivalent call
				rnd(2, 3.4) -- inferred equivalent call
			)
		end
	end

	local function strike(p, p2, p3) -- 2 equivalent calls inferred from this helper
		for _ = 1, p3 do
			local v57 = p + rnd(-360, 360) * scale -- inferred equivalent call

			local v58 = p - v57
			local v59 = p2 - -20
			emitBolt(
				v57,
				-20,
				math.atan2(v59, v58),
				math.sqrt(v58 * v58 + v59 * v59),
				rnd(0.22, 0.34), -- inferred equivalent call
				v and 7 or 11,
				true,
				3.2
			)
		end
	end

	local function edgeBolt()
		local v57 = math.random() < 0.5
		emitBolt(
			v10 + (v57 and -1 or 1) * 320 * scale,
			v11 + rnd(-360, 360) * scale, -- inferred equivalent call
			(v57 and 3.141592653589793 or 0) + rnd(-0.7, 0.7), -- inferred equivalent call
			rnd(60, 150) * scale, -- inferred equivalent call
			rnd(0.12, 0.22), -- inferred equivalent call
			v and 4 or 6,
			true,
			2.4
		)
	end

	local numberValue2 = Instance.new("NumberValue")
	numberValue2.Value = -1.3

	local lastTime2 = os.clock()
	local total = 0
	local v57 = 0
	local v58 = 0
	local v59 = 0.5 + math.random() * 0.5
	local v60 = 2.2 + math.random() * 1.2999999999999998

	local flag4 = false

	local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		local v61 = os.clock() - lastTime2

		uiScale.Scale = scale * numberValue.Value
		updateCamera(numberValue2.Value + math.sin(v61 * 0.8) * 0.3)

		if lastTime then
			local v62 = 1 - (os.clock() - lastTime) / 0.4

			if v62 > 0 then
				local v63 = v22 * v62 * v62
				frame3.Position = at((math.random() - 0.5) * 2 * v63, (math.random() - 0.5) * 2 * v63) -- inferred equivalent call
			else
				lastTime = nil
				frame3.Position = at(0, 0) -- inferred equivalent call
			end
		end

		total += dt

		if total >= 0.12 then
			total = 0
			uiStroke.Transparency = rnd(0.66, 0.9) -- inferred equivalent call

			for _, v62 in ipairs(v17) do
				v62.Frame.BackgroundTransparency = math.clamp(v62.Base + rnd(-0.008, 0.012), 0, 1) -- inferred equivalent call
			end

			if flag4 then
				frame3.Rotation = os.clock() < v21 and -1.3 + rnd(-0.14, 0.14) or -1.3 -- inferred equivalent call
			end
		end

		if flag4 then
			v57 += dt * (v and 4 or 9)

			while v57 >= 1 do
				v57 -= 1
				emitEmber(
					rnd(0, viewportSize.X), -- inferred equivalent call
					viewportSize.Y + 6,
					math.random() < 0.5 and Color3.fromRGB(110, 104, 96) or math.random() < 0.5 and v9 or v8
				)
			end

			v58 += dt * 2.4

			while v58 >= 1 do
				v58 -= 1
				local v62 = math.random() < 0.5
				emitSpark(
					v10 + (v62 and -1 or 1) * 320 * scale,
					v11 + rnd(-400, 400) * scale, -- inferred equivalent call
					rnd(-1.2, 1.2) + (v62 and 3.141592653589793 or 0), -- inferred equivalent call
					rnd(140, 320), -- inferred equivalent call
					rnd(0.4, 0.9), -- inferred equivalent call
					rnd(2, 3) -- inferred equivalent call
				)
			end

			v59 -= dt

			if v59 <= 0 then
				v59 = v61 > 4 and rnd(2.2, 4) or rnd(0.3, 0.8) -- inferred equivalent call
				edgeBolt()
			end

			v60 -= dt

			if v60 <= 0 then
				v60 = v61 > 4 and rnd(5, 8) or rnd(2.5, 4.5) -- inferred equivalent call
				strike(v14, v12, 1) -- inferred equivalent call
				kick(4) -- inferred equivalent call
			end
		end

		for i = #v32, 1, -1 do
			if not v32[i](dt) then
				table.remove(v32, i)
			end
		end
	end)

	finish = function(p)
		if flag2 then
			return
		end

		flag2 = true
		flag3 = false
		task.spawn(function()
			local frame = mk("Frame", { -- inferred equivalent call
				BackgroundColor3 = v2.Black,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 100
			}, screenGui)
			TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0
			}):Play()
			task.wait(0.22)

			if data.OnCovered then
				pcall(data.OnCovered, p)
			end

			renderSteppedConnection:Disconnect()
			frame3.Visible = false
			parent5.Visible = false
			textButton.Visible = false
			v15.Visible = false
			v16.Visible = false
			TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1
			}):Play()
			TweenService:Create(blurEffect, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = 0
			}):Play()
			local v62 = { Saturation = 0, Contrast = 0, TintColor = Color3.new(1, 1, 1) }
			TweenService:Create(
				colorCorrectionEffect,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				v62
			):Play()

			task.wait(0.32)
			blurEffect:Destroy()
			colorCorrectionEffect:Destroy()
			numberValue2:Destroy()
			numberValue:Destroy()
			screenGui:Destroy()
			flag = false
			bindableEvent:Fire(p)
		end)
	end

	connection = UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Escape and flag3 then
			finish("continue")
		end
	end)

	task.spawn(function()
		local success, result = pcall(function()
			TweenService:Create(textButton, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.12
			}):Play()
			TweenService:Create(blurEffect, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = 12
			}):Play()
			local v61 = {
				Saturation = -0.5,
				Contrast = 0.14,
				TintColor = Color3.fromRGB(226, 236, 246)
			}
			TweenService:Create(
				colorCorrectionEffect,
				TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				v61
			):Play()

			task.wait(0.45)

			if flag2 then
				return
			end

			local frame = mk( -- inferred equivalent call
				"Frame",
				{
					BackgroundColor3 = lerped,
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1),
					ZIndex = 30
				},
				screenGui
			)
			TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1
			}):Play()
			task.delay(0.4, function()
				frame:Destroy()
			end)
			kick(isNew and 18 or 9) -- inferred equivalent call
			frame3.Visible = true
			sfx2(0.45, 0.75, 0.85, 0)
			local quint = Enum.EasingStyle.Quint
			TweenService:Create(
				numberValue,
				TweenInfo.new(0.2, quint or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Value = 1 }
			):Play()
			local back = Enum.EasingStyle.Back
			TweenService:Create(frame3, TweenInfo.new(0.22, back or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Rotation = -1.3
			}):Play()
			strike(v14, v12, isNew and 4 or 2)
			sparkBurst(v14, v12, isNew and 40 or 20, 260, 900, false)
			TweenService:Create(v15, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 0.9
			}):Play()
			TweenService:Create(v16, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 0.9
			}):Play()

			task.wait(0.35)

			if flag2 then
				return
			end

			for _, v63 in ipairs(v29) do
				slap(v63, 4)
				task.wait(0.06)
			end

			for _, v63 in ipairs(v30) do
				slap(v63, 3)
				task.wait(0.06)
			end

			task.wait(0.1)

			if flag2 then
				return
			end

			local quint2 = Enum.EasingStyle.Quint
			TweenService:Create(
				numberValue2,
				TweenInfo.new(0.7, quint2 or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Value = 0.35 }
			):Play()
			local v63 = { Position = UDim2.new(0.5, 0, 0.5, 10) }
			local quad = Enum.EasingStyle.Quad
			local v64 = Enum.EasingDirection.In
			TweenService:Create(
				frame4,
				TweenInfo.new(0.26, quad or Enum.EasingStyle.Quad, v64 or Enum.EasingDirection.Out),
				v63
			):Play()

			task.wait(0.27)

			if flag2 then
				return
			end

			sfx2(0.4, 0.7, 0.8, 0)
			kick(12) -- inferred equivalent call
			sparkBurst(v14, v12 + scale * 150, 34, 220, 760, true)
			emitBolt(v14 - scale * 60, v12 + scale * 140, -2.0707963267948966, scale * 110, 0.2, 5, true, 2.6)
			emitBolt(v14 + scale * 60, v12 + scale * 140, -1.0707963267948966, scale * 110, 0.2, 5, true, 2.6)
			local v65 = { Position = UDim2.new(0.5, 0, 0.5, 0) }
			local back2 = Enum.EasingStyle.Back
			TweenService:Create(
				frame4,
				TweenInfo.new(0.18, back2 or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				v65
			):Play()

			flag4 = true

			for i, v66 in ipairs(v18) do
				task.delay(i * 0.08, function()
					if not flag2 then
						TweenService:Create(v66, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							BackgroundTransparency = 0.45
						}):Play()
					end
				end)
			end

			task.wait(0.4)

			if flag2 then
				return
			end

			slamPlate(plate, 10)

			sparkBurst(v10 - scale * 270, v11 - scale * 350, 12, 160, 520, false)
			sparkBurst(v10 + scale * 270, v11 - scale * 350, 12, 160, 520, false)
			playZap(0.14, 0.08)

			task.wait(0.65)

			if flag2 then
				return
			end

			local v66 = utf8.len(design.Name) or #design.Name
			local v67 = math.clamp(0.8 / math.max(v66, 1), 0.03, 0.07)
			sfx(v66 * v67 + 0.2, 0.98, 1.04, 0.5)

			for i = 1, v66 do
				if flag2 then
					return
				end

				textLabel.MaxVisibleGraphemes = i
				task.wait(v67)
			end

			textLabel.MaxVisibleGraphemes = -1
			revealScribble()
			strike(v14, v11 + scale * 148, 1) -- inferred equivalent call
			kick(6) -- inferred equivalent call
			task.wait(0.4)

			if flag2 then
				return
			end

			slamPlate(plate2, 5)
			task.wait(0.3)
			slap(tape, 9)
			sfx2(0.35, 0.9, 1, 0)
			sparkBurst(v10 - scale * 120, v11 + scale * 294, 16, 160, 520, false)
			task.wait(0.2)
			slap(tape2, 4)
			task.wait(0.35)

			if flag2 then
				return
			end

			slap(tape3, 3)
			slap(tape4, 3)
			task.wait(0.08)
			slap(buttonTape, 3)
			task.wait(0.1)
			slap(buttonTape2, 3)
			flag3 = true
		end)

		if not (success or flag2) then
			warn("[CustomGuitarCelebration] timeline error: " .. tostring(result))
			frame3.Visible = true
			frame3.Rotation = -1.3
			textLabel.MaxVisibleGraphemes = -1
			slamPlate(plate, 0)
			slamPlate(plate2, 0)

			for _, v62 in ipairs({ tape3, tape4, buttonTape, buttonTape2 }) do
				v62.Frame.BackgroundTransparency = v62.BaseT
				v62.Frame.TextTransparency = 0
				v62.Scale.Scale = 1
			end

			flag3 = true
		end
	end)

	v7 = bindableEvent.Event:Wait()
	connection:Disconnect()
	bindableEvent:Destroy()
	return v7
end

function CustomGuitarCelebration:Play()
	local success, result = pcall(playInternal, self)

	if success then
		return result
	end

	warn("[CustomGuitarCelebration] " .. tostring(result))
	flag = false
	local customGuitarCelebration = Players.LocalPlayer.PlayerGui:FindFirstChild("CustomGuitarCelebration")

	if customGuitarCelebration then
		customGuitarCelebration:Destroy()
	end

	for _, childName in ipairs({ "CustomGuitarCelebrationBlur", "CustomGuitarCelebrationGrade" }) do
		local child = Lighting:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end

	return "continue"
end

return CustomGuitarCelebration