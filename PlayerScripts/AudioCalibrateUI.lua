local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")

local SettingsState = require(ReplicatedStorage.Modules.SettingsState)
local NoteLaneUI = require(ReplicatedStorage.Modules.NoteLaneUI)
local RhythmEngineConfig = require(ReplicatedStorage.Modules.RhythmEngineConfig)
local RhythmShapeGeometry = require(ReplicatedStorage.Modules.RhythmShapeGeometry)
local StyledTheme = require(ReplicatedStorage.Modules.SongListUI.StyledTheme)

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local AudioCalibrateUI = {}

local v = { Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.B, Enum.KeyCode.N }
local color = Color3.fromRGB(150, 125, 45)

local v2 = { "3", "2", "1", "GO!" }

local v3 = { Group = nil, Tween = nil, Token = 0 }

local function make(className, items, parent) -- 46 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function toHex(data) -- 2 equivalent calls inferred from this helper
	return string.format(
		"#%02X%02X%02X",
		math.floor(data.R * 255 + 0.5),
		math.floor(data.G * 255 + 0.5),
		(math.floor(data.B * 255 + 0.5))
	)
end

local function currentSkin()
	local isNew = SettingsState.GetUIStyle() == "NewUI"
	local name = isNew and "NewUI" or "Default"
	local style = StyledTheme.Styles[name]
	local colors = style.Colors or {}
	return {
		Name = name,
		IsNew = isNew,
		Pal = style.Settings,
		Success = colors.Success or Color3.fromRGB(62, 150, 92),
		Grunge = StyledTheme.Grunge,
		Body = isNew and Enum.Font.SpecialElite or Enum.Font.Gotham,
		Head = isNew and Enum.Font.Oswald or Enum.Font.GothamBold,
		Radius = UDim.new(0, isNew and 3 or 8)
	}
end

local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local v8 = nil
local v9 = nil
local name = nil
local viewportSizeChangedConnection = nil
local v10 = nil
local v11 = nil
local v12 = nil
local v13 = nil

local v14 = false
local heartbeatConnection = nil
local inputBeganConnection = nil
local v15 = nil
local parent2 = nil

local flag = false

local function getLaneKey() -- 1 equivalent call inferred from this helper
	local keybindFiveKey = SettingsState.GetKeybindFiveKey()
	return keybindFiveKey and keybindFiveKey[3] or Enum.KeyCode.V
end

local function getLaneColor() -- 1 equivalent call inferred from this helper
	local rhythmLaneColors = SettingsState.GetRhythmLaneColors(5)

	if rhythmLaneColors and rhythmLaneColors[3] and rhythmLaneColors[3].NoteInner then
		return rhythmLaneColors[3].NoteInner
	end

	return color
end

local function playClick() -- 1 equivalent call inferred from this helper
	v13.TimePosition = 0
	v13:Play()
end

local function judgmentForDelta(p) -- 1 equivalent call inferred from this helper
	for _, hitWindow in ipairs(RhythmEngineConfig.HitWindows) do
		if p <= hitWindow.Seconds then
			return hitWindow.Judgment
		end
	end

	return "OK"
end

local function getFeedbackComment(p): string -- 1 equivalent call inferred from this helper
	local v16 = math.abs(p)

	if p <= -100 then
		return "Whoa, are you playing on a NASA supercomputer? That's faster than humanly possible!"
	end

	if p < -30 then
		return "You're tapping a little early - try to relax and follow the beat naturally."
	end

	if v16 <= 30 then
		return "Nice! Your timing looks well synced."
	end

	if p <= 100 then
		return "A small delay - might be worth double-checking your audio setup."
	end

	if p <= 200 then
		return "That's a noticeable delay. Are you using Bluetooth headphones or a TV speaker?"
	end

	return "That's a big delay! Wireless or Bluetooth audio is likely the cause - wired audio may feel more precise."
end

local function computeStdDevMs(list)
	local count = #list

	if count == 0 then
		return 0
	end

	local total = 0

	for _, item in ipairs(list) do
		total += item
	end

	local v16 = total / count
	local total2 = 0

	for _, item in ipairs(list) do
		local v17 = item - v16
		total2 += v17 * v17
	end

	return math.sqrt(total2 / count) * 1000
end

local function getConsistencyWarning(p): nil | string -- 1 equivalent call inferred from this helper
	if p > 30 then
		return "Your taps varied a lot - consider retrying for a more reliable result."
	end

	return nil
end

local function setupSingleLane()
	parent2 = nil
	local trackFrame = NoteLaneUI.GetTrackFrame()

	if not trackFrame then
		return
	end

	local children = trackFrame:GetChildren()

	for i, child in ipairs(children) do
		local match = child.Name:match("^Lane(%d+)Rail$")

		if not match then
			continue
		end

		local v16 = tonumber(match)
		local child2 = children[i + 1]

		if not child2 or child2.Name ~= "HitContainer" or not child2 then
			child2 = nil
		end

		if v16 == 3 then
			parent2 = child2
		else
			child.Visible = false

			if child2 then
				child2.Visible = false
			end
		end
	end
end

local function spawnPopGem()
	if not parent2 then
		return
	end

	local tapPopGem = Instance.new("Frame")
	tapPopGem.Name = "TapPopGem"
	tapPopGem.AnchorPoint = Vector2.new(0.5, 0.5)
	tapPopGem.Position = UDim2.new(0.5, 0, 0.5, 0)
	tapPopGem.BackgroundColor3 = getLaneColor() -- inferred equivalent call
	tapPopGem.BorderSizePixel = 0
	tapPopGem.ZIndex = 8
	tapPopGem.Parent = parent2

	RhythmShapeGeometry.Apply(tapPopGem, SettingsState.GetRhythmShape(), 42)

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(255, 255, 255)
	uiStroke.Thickness = 2
	uiStroke.Transparency = 0.25
	uiStroke.Parent = tapPopGem

	local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(tapPopGem, tweenInfo, {
		Position = UDim2.new(0.5, 0, 0.5, -70),
		BackgroundTransparency = 1
	}):Play()
	TweenService:Create(uiStroke, tweenInfo, { Transparency = 1 }):Play()

	task.delay(0.5, function()
		tapPopGem:Destroy()
	end)
end

local function isRealSongUsingTrack() -- 1 equivalent call inferred from this helper
	local noteLaneUI = PlayerGui:FindFirstChild("NoteLaneUI")
	return noteLaneUI ~= nil and noteLaneUI.Enabled
end

local function spawnMsLabel(p)
	if not parent2 then
		return
	end

	local v16 = p > 0 and "+" or ""
	local msResultLabel = Instance.new("TextLabel")
	msResultLabel.Name = "MsResultLabel"
	msResultLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	msResultLabel.Position = UDim2.new(0.5, 0, 0.5, -90)
	msResultLabel.Size = UDim2.new(0, 140, 0, 30)
	msResultLabel.BackgroundTransparency = 1
	msResultLabel.Font = Enum.Font.GothamBold
	msResultLabel.TextSize = 22
	msResultLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	msResultLabel.TextStrokeTransparency = 0.1
	msResultLabel.TextTransparency = 0
	msResultLabel.Text = string.format("%s%dms", v16, p)
	msResultLabel.ZIndex = 9
	msResultLabel.Parent = parent2

	TweenService:Create(msResultLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, 0, 0.5, -130),
		TextTransparency = 1,
		TextStrokeTransparency = 1
	}):Play()

	task.delay(0.55, function()
		msResultLabel:Destroy()
	end)
end

local function setPanelState(p)
	v10.Visible = p == "idle"
	v11.Visible = p == "result"
	v12.Visible = p == "result"
	v5.Visible = p == "running"
	v7.Visible = false
end

local function ensureDuckGroup()
	if v3.Group and v3.Group.Parent then
		return v3.Group
	end

	local monoBoundaryMix = SoundService:FindFirstChild("MonoBoundaryMix", true)

	if not (monoBoundaryMix and monoBoundaryMix:IsA("SoundGroup")) then
		return nil
	end

	local calibrateDuck = SoundService:FindFirstChild("CalibrateDuck")

	if not calibrateDuck then
		calibrateDuck = Instance.new("SoundGroup")
		calibrateDuck.Name = "CalibrateDuck"
		calibrateDuck.Volume = 1
		calibrateDuck.Parent = SoundService
	end

	if monoBoundaryMix.Parent ~= calibrateDuck then
		monoBoundaryMix.Parent = calibrateDuck
	end

	v3.Group = calibrateDuck
	return calibrateDuck
end

local function duckSongAudio()
	local duckGroup = ensureDuckGroup()

	if not duckGroup then
		return
	end

	v3.Token += 1

	if v3.Tween then
		v3.Tween:Cancel()
	end

	v3.Tween = TweenService:Create(duckGroup, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Volume = 0.05
	})

	v3.Tween:Play()
end

local function restoreSongAudio()
	local group = v3.Group

	if not (group and group.Parent) then
		return
	end

	v3.Token += 1
	local token = v3.Token

	if v3.Tween then
		v3.Tween:Cancel()
	end

	v3.Tween = TweenService:Create(group, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Volume = 1
	})

	v3.Tween:Play()
	task.delay(0.55, function()
		if v3.Token == token and group.Parent then
			group.Volume = 1
		end
	end)
end

local function stopLoop() -- 3 equivalent calls inferred from this helper
	v14 = false
	pcall(restoreSongAudio)

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if inputBeganConnection then
		inputBeganConnection:Disconnect()
		inputBeganConnection = nil
	end

	parent2 = nil

	if flag then
		flag = false
		NoteLaneUI.Hide()
	end
end

local function finishRun(list)
	stopLoop() -- inferred equivalent call

	if #list < 8 then
		v15 = nil
		v6.Text = string.format("Only caught %d/%d taps - try again.", #list, 16)
		v11.Visible = false
		v12.Visible = true
		v5.Visible = false
	else
		table.sort(list)
		local v16 = math.ceil(#list / 2)
		local v17

		if #list % 2 == 0 then
			v17 = (list[v16] + list[v16 + 1]) / 2
		else
			v17 = list[v16]
		end

		local v18 = math.clamp(math.floor(v17 * 1000 - 105 + 0.5), -500, 500)
		v15 = v18

		local v19 = computeStdDevMs(list)
		local v20 = v18 > 0 and "+" or ""
		local pal = v9.Pal
		local isNew = v9.IsNew
		local hex = toHex(pal.TEXT_DIM) -- inferred equivalent call

		v7.Text = string.format(
			"<font size=\"%d\" color=\"%s\">%s</font>  %s%dms  <font size=\"%d\" color=\"%s\">±%dms</font>",
			isNew and 13 or 11,
			hex,
			isNew and "DETECTED OFFSET" or "Detected offset",
			v20,
			v18,
			isNew and 15 or 12,
			hex,
			(math.floor(v19 + 0.5))
		)

		v7.TextColor3 = math.abs(v18) <= 30 and v9.Success or pal.ACCENT
		v7.Visible = true
		local text = getFeedbackComment(v18) -- inferred equivalent call
		local consistencyWarning = getConsistencyWarning(v19) -- inferred equivalent call

		if consistencyWarning then
			text ..= string.format("\n<font color=\"%s\">%s</font>", toHex(pal.WARNING), consistencyWarning) -- inferred equivalent call
		end

		v6.Text = text
		v11.Visible = true
		v12.Visible = true
		v5.Visible = false
	end
end

local function startRun()
	v15 = nil
	v10.Visible = false
	v11.Visible = false
	v12.Visible = false
	v5.Visible = true
	v7.Visible = false

	v6.Text = ""

	if isRealSongUsingTrack() then -- inferred equivalent call
		v10.Visible = true
		v11.Visible = false
		v12.Visible = false
		v5.Visible = false
		v7.Visible = false

		v6.Text = "Can't calibrate while a song is playing."
	else
		pcall(duckSongAudio)
		local laneKey = getLaneKey() -- inferred equivalent call
		local v16 = v5

		local success, result = pcall(function()
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			return require(ReplicatedStorage2.Modules.ControllerGlyphs).Display(laneKey)
		end)
		v16.Text = string.format("Listen and tap [%s] on every beat", success and result or laneKey.Name)

		local v17 = SettingsState.GetKeybindFiveKey() or v
		NoteLaneUI.Show("Calibrate", 5, v17, { "", "", "Yellow", "", "" }, nil)
		flag = true
		setupSingleLane()

		local trackFrame = NoteLaneUI.GetTrackFrame()
		local breakCountdownLabel = trackFrame and trackFrame:FindFirstChild("BreakCountdownLabel")
		local breakCountdownCaption = trackFrame and trackFrame:FindFirstChild("BreakCountdownCaption")

		local v18 = {}
		local v19 = {}
		local count = 0
		local lastTime = os.clock()
		v14 = true

		inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed or not v14 or input.KeyCode ~= laneKey then
				return
			end

			local v20 = os.clock() - lastTime

			NoteLaneUI.SetLanePressed(3, true)
			spawnPopGem()
			task.delay(0.08, function()
				NoteLaneUI.SetLanePressed(3, false)
			end)

			local v21 = math.floor(v20 / 0.6 + 0.5)

			if v21 < 4 or v21 >= 20 or v19[v21] then
				return
			end

			local v22 = v20 - v21 * 0.6

			if math.abs(v22) > 0.3 then
				return
			end

			v19[v21] = true
			table.insert(v18, v22)

			NoteLaneUI.ShowJudgment(3, judgmentForDelta(math.abs(v22))) -- inferred equivalent call

			spawnMsLabel(math.floor(v22 * 1000 + 0.5))
		end)

		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if not v14 then
				return
			end

			local v20 = os.clock() - lastTime

			while count < 20 and count * 0.6 <= v20 do
				playClick() -- inferred equivalent call

				if count < 4 then
					if breakCountdownLabel then
						breakCountdownLabel.Text = v2[count + 1]
						breakCountdownLabel.Visible = true
					end

					if breakCountdownCaption then
						breakCountdownCaption.Visible = true
					end
				else
					if count == 4 then
						NoteLaneUI.HideCountdown()
					end

					v6.Text = string.format("Tap %d / %d", count - 4 + 1, 16)
				end

				count += 1
			end

			for i = 4, 19 do
				if v19[i] or not (i * 0.6 + 0.3 < v20) then
					continue
				end

				v19[i] = "missed"
				NoteLaneUI.ShowJudgment(3, "Miss")
			end

			if v20 >= 12.5 then
				finishRun(v18)
			end
		end)
	end
end

local function buildGrungeDecor(parent)
	local grunge = v9.Grunge
	local pal = v9.Pal
	local random = Random.new(31)

	local parent3 = make("Frame", { -- inferred equivalent call
		Name = "DecorBack",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		ClipsDescendants = true,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1
	}, parent)

	local function vignette(name2, position, size, rotation, p)
		local parent4 = make("Frame", { -- inferred equivalent call
			Name = name2,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Active = false,
			Position = position,
			Size = size
		}, parent3)

		make("UIGradient", { -- inferred equivalent call
			Rotation = rotation,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, p), NumberSequenceKeypoint.new(1, 1) })
		}, parent4)
	end
	vignette("VigTop", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 30), 90, 0.5)
	vignette("VigBottom", UDim2.new(0, 0, 1, -30), UDim2.new(1, 0, 0, 30), 270, 0.5)
	vignette("VigLeft", UDim2.new(0, 0, 0, 0), UDim2.new(0, 36, 1, 0), 0, 0.55)
	vignette("VigRight", UDim2.new(1, -36, 0, 0), UDim2.new(0, 36, 1, 0), 180, 0.55)

	for i = 1, 6 do
		local integer = random:NextInteger(40, 110)
		local parent4 = make("Frame", { -- inferred equivalent call
			Name = "Stain" .. i,
			BackgroundColor3 = i % 3 == 0 and grunge.Rust or Color3.new(0, 0, 0),
			BackgroundTransparency = 0.9 + random:NextNumber() * 0.05,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber() * 0.8, random:NextNumber() * 0.6),
			Size = UDim2.new(0, integer, 0, (math.floor(integer * (0.35 + random:NextNumber() * 0.4))))
		}, parent3)

		make("UICorner", { CornerRadius = UDim.new(1, 0) }, parent4) -- inferred equivalent call
	end

	local parent4 = make("Frame", { -- inferred equivalent call
		Name = "DecorMid",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		ClipsDescendants = true,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 4
	}, parent)

	for i = 1, 3 do
		local integer = random:NextInteger(50, 120)
		local parent5 = make("Frame", { -- inferred equivalent call
			Name = "Grime" .. i,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.93 + random:NextNumber() * 0.04,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			Size = UDim2.new(0, integer, 0, (math.floor(integer * 0.6)))
		}, parent4)

		make("UICorner", { CornerRadius = UDim.new(1, 0) }, parent5) -- inferred equivalent call
	end

	for i, v16 in ipairs({
		{ 0.08, 0.3, 90, 24 },
		{ 0.6, 0.55, 70, -31 },
		{ 0.28, 0.75, 110, 12 },
		{ 0.78, 0.2, 60, -20 },
		{ 0.05, 0.88, 80, 35 },
		{ 0.5, 0.1, 70, -14 },
		{ 0.88, 0.7, 50, 52 }
	}) do
		make("Frame", { -- inferred equivalent call
			Name = "Scratch" .. i,
			BackgroundColor3 = pal.TEXT,
			BackgroundTransparency = 0.95,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(v16[1], v16[2]),
			Size = UDim2.new(0, v16[3], 0, 1),
			Rotation = v16[4]
		}, parent4)
	end

	for i = 1, 3 do
		make("Frame", { -- inferred equivalent call
			Name = "Scuff" .. i,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.55,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			Size = UDim2.new(0, random:NextInteger(30, 80), 0, 1),
			Rotation = random:NextInteger(-60, 60)
		}, parent4)
	end

	for i = 1, 30 do
		local v16 = random:NextNumber() > 0.35
		local integer = random:NextInteger(1, 3)
		make("Frame", { -- inferred equivalent call
			Name = "Speck" .. i,
			BackgroundColor3 = v16 and pal.TEXT or Color3.new(0, 0, 0),
			BackgroundTransparency = v16 and 0.8 + random:NextNumber() * 0.12 or 0.45 + random:NextNumber() * 0.25,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			Size = UDim2.new(0, integer, 0, integer)
		}, parent4)
	end

	local parent5 = make("Frame", { -- inferred equivalent call
		Name = "EdgeWear",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.new(0, 3, 0, 3),
		Size = UDim2.new(1, -6, 1, -6)
	}, parent4)

	make("UIStroke", { Color = grunge.EdgeWear, Thickness = 1.5, Transparency = 0.55 }, parent5) -- inferred equivalent call
	make("UICorner", { CornerRadius = UDim.new(0, 2) }, parent5) -- inferred equivalent call

	local parent6 = make("Frame", { -- inferred equivalent call
		Name = "DecorTape",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 6
	}, parent)

	local function tape(name2, position, size, rotation, backgroundColor, backgroundTransparency) -- 3 equivalent calls inferred from this helper
		make("Frame", { -- inferred equivalent call
			Name = name2,
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = backgroundTransparency,
			BorderSizePixel = 0,
			Active = false,
			Position = position,
			Size = size,
			Rotation = rotation
		}, parent6)
	end
	tape("TapeLeft", UDim2.new(0, -16, 0, 2), UDim2.new(0, 56, 0, 13), -38, grunge.Tape, 0.12) -- inferred equivalent call
	tape("TapeBottomRight", UDim2.new(1, -36, 1, -12), UDim2.new(0, 46, 0, 12), -38, grunge.Tape, 0.18) -- inferred equivalent call
	tape("TapeBottomLeft", UDim2.new(0, -12, 1, -14), UDim2.new(0, 38, 0, 11), 34, grunge.TapeDark, 0.15) -- inferred equivalent call
end

local function makeButton(name2, text, p, layoutOrder, p2)
	local pal = v9.Pal
	local grunge = v9.Grunge
	local accent = p2 and pal.ACCENT or pal.BTN
	local backgroundColor = p2 and pal.ACCENT:Lerp(Color3.new(1, 1, 1), 0.18) or pal.CARD_ACTIVE
	local v16 = {
		Name = name2,
		LayoutOrder = layoutOrder,
		Size = UDim2.new(0, p, 0, 34),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		BackgroundColor3 = accent,
		Font = v9.Head,
		TextSize = v9.IsNew and 17 or 13,
		TextColor3 = p2 and pal.DARKTEXT or pal.TEXT,
		Text = 0,
		Visible = false
	}
	text = v9.IsNew and string.upper(text) or text
	v16.Text = text
	local button = make("TextButton", v16, v8) -- inferred equivalent call
	make("UICorner", { CornerRadius = v9.Radius }, button) -- inferred equivalent call
	make("UIStroke", { -- inferred equivalent call
		Color = p2 and (v9.IsNew and grunge.WindowStroke or pal.ACCENT) or pal.BORDER,
		Thickness = p2 and v9.IsNew and 2 or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, button)

	local uiScale = make("UIScale", { Scale = 1 }, button) -- inferred equivalent call

	local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local function rest()
		TweenService:Create(button, tweenInfo, { BackgroundColor3 = accent }):Play()
		TweenService:Create(uiScale, tweenInfo, { Scale = 1 }):Play()
	end
	button.MouseEnter:Connect(function()
		TweenService:Create(button, tweenInfo, { BackgroundColor3 = backgroundColor }):Play()
	end)
	button.MouseLeave:Connect(rest)
	button.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			TweenService:Create(uiScale, tweenInfo, { Scale = 0.96 }):Play()
		end
	end)
	button.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			TweenService:Create(uiScale, tweenInfo, { Scale = 1 }):Play()
		end
	end)

	button:GetPropertyChangedSignal("Visible"):Connect(function()
		button.BackgroundColor3 = accent
		uiScale.Scale = 1
	end)
	return button
end

local function buildCloseButton(parent)
	local pal = v9.Pal
	local grunge = v9.Grunge
	local isNew = v9.IsNew

	local closeButton = make("TextButton", { -- inferred equivalent call
		Name = "CloseBtn",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -16, 0, isNew and 2 or 6),
		Size = UDim2.new(0, 44, 0, 34),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		ZIndex = 8
	}, parent)

	local tape = isNew and grunge.Tape or pal.BTN
	local color2 = isNew and Color3.fromRGB(232, 218, 176) or Color3.fromRGB(196, 64, 64)
	local color3 = isNew and Color3.fromRGB(28, 24, 20) or Color3.fromRGB(200, 195, 185)
	local danger = isNew and pal.DANGER or Color3.fromRGB(255, 255, 255)

	local parent3 = make("Frame", { -- inferred equivalent call
		Name = "Visual",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = isNew and UDim2.new(0, 38, 0, 22) or UDim2.new(0, 22, 0, 22),
		BackgroundColor3 = tape,
		BackgroundTransparency = isNew and 0.08 or 0,
		BorderSizePixel = 0,
		Rotation = isNew and -5 or 0,
		ZIndex = 8
	}, closeButton)

	if isNew then
		make("UICorner", { CornerRadius = UDim.new(0, 1) }, parent3) -- inferred equivalent call
	else
		make("UICorner", { CornerRadius = UDim.new(1, 0) }, parent3) -- inferred equivalent call
		make("UIStroke", { -- inferred equivalent call
			Color = Color3.fromRGB(255, 255, 255),
			Transparency = 0.85,
			Thickness = 1
		}, parent3)
	end

	local uiScale = make("UIScale", { Scale = 1 }, parent3) -- inferred equivalent call

	local v16 = {}

	for _, rotation in ipairs({ 45, -45 }) do
		local parent4 = make("Frame", { -- inferred equivalent call
			Name = "Bar",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = isNew and UDim2.new(0, 15, 0, 3) or UDim2.new(0, 11, 0, 2),
			Rotation = rotation,
			BackgroundColor3 = color3,
			BorderSizePixel = 0,
			ZIndex = 9
		}, parent3)

		make("UICorner", { -- inferred equivalent call
			CornerRadius = isNew and UDim.new(0, 1) or UDim.new(1, 0)
		}, parent4)
		table.insert(v16, parent4)
	end

	local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local function setHover(p)
		TweenService:Create(parent3, tweenInfo, {
			BackgroundColor3 = p and color2 or tape
		}):Play()

		for _, instance in ipairs(v16) do
			TweenService:Create(instance, tweenInfo, {
				BackgroundColor3 = p and danger or color3
			}):Play()
		end
	end
	local function setPressed(p) -- 4 equivalent calls inferred from this helper
		TweenService:Create(uiScale, tweenInfo, {
			Scale = p and 0.9 or 1
		}):Play()
	end

	closeButton.MouseEnter:Connect(function()
		setHover(true)
	end)
	closeButton.MouseLeave:Connect(function()
		setHover(false)
		setPressed(false) -- inferred equivalent call
	end)
	closeButton.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			setPressed(true) -- inferred equivalent call
		end
	end)
	closeButton.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			setPressed(false) -- inferred equivalent call
		end
	end)

	closeButton.MouseButton1Click:Connect(function()
		setHover(false)
		setPressed(false) -- inferred equivalent call
		v15 = nil
		AudioCalibrateUI.Hide()
	end)

	return closeButton
end

local function build()
	if v4 then
		return
	end

	v9 = currentSkin()
	name = v9.Name
	local pal = v9.Pal
	local grunge = v9.Grunge
	local isNew = v9.IsNew

	v4 = make("ScreenGui", { -- inferred equivalent call
		Name = "AudioCalibrateUI",
		ResetOnSpawn = false,
		Enabled = false,
		DisplayOrder = 105,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}, PlayerGui)

	local parent = make("Frame", { -- inferred equivalent call
		Name = "Panel",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 18),
		Size = UDim2.new(0.92, 0, 0, 130),
		BackgroundColor3 = pal.BG,
		BackgroundTransparency = isNew and 0.04 or 0.02,
		BorderSizePixel = 0
	}, v4)

	make("UISizeConstraint", { MaxSize = Vector2.new(420, 1e999) }, parent) -- inferred equivalent call
	make("UICorner", { CornerRadius = v9.Radius }, parent) -- inferred equivalent call
	make("UIStroke", { -- inferred equivalent call
		Color = isNew and grunge.WindowStroke or pal.BORDER,
		Thickness = isNew and 2 or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, parent)

	local uiScale = make("UIScale", { Scale = 1 }, parent) -- inferred equivalent call

	if isNew then
		buildGrungeDecor(parent)
	end

	local parent3 = make("Frame", { -- inferred equivalent call
		Name = "Content",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 2
	}, parent)

	make( -- inferred equivalent call
		"UIPadding",
		{
			PaddingTop = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 14),
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16)
		},
		parent3
	)

	make( -- inferred equivalent call
		"UIListLayout",
		{
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 7)
		},
		parent3
	)

	make("TextLabel", { -- inferred equivalent call
		Name = "Title",
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Font = v9.Head,
		TextSize = isNew and 22 or 15,
		TextColor3 = pal.ACCENT,
		Text = isNew and "CALIBRATE TIMING" or "Calibrate Timing"
	}, parent3)

	make("Frame", { -- inferred equivalent call
		Name = "Divider",
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = pal.BORDER,
		BackgroundTransparency = 0.35
	}, parent3)

	v5 = make("TextLabel", { -- inferred equivalent call
		Name = "Instruction",
		LayoutOrder = 3,
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Font = v9.Body,
		TextSize = isNew and 14 or 12,
		TextColor3 = pal.TEXT,
		Text = "",
		Visible = false
	}, parent3)

	v7 = make("TextLabel", { -- inferred equivalent call
		Name = "Headline",
		LayoutOrder = 4,
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		Font = v9.Head,
		TextSize = isNew and 30 or 22,
		TextColor3 = pal.ACCENT,
		RichText = true,
		Text = "",
		Visible = false
	}, parent3)

	v6 = make("TextLabel", { -- inferred equivalent call
		Name = "Status",
		LayoutOrder = 5,
		Size = UDim2.new(1, 0, 0, 18),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Font = v9.Body,
		TextSize = isNew and 14 or 12,
		LineHeight = 1.12,
		TextWrapped = true,
		RichText = true,
		TextColor3 = pal.TEXT,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = "Press Start when you're ready."
	}, parent3)

	make("UISizeConstraint", { MinSize = Vector2.new(0, 18) }, v6) -- inferred equivalent call

	v8 = make("Frame", { -- inferred equivalent call
		Name = "Buttons",
		LayoutOrder = 6,
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	}, parent3)

	make("UIListLayout", { -- inferred equivalent call
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10)
	}, v8)

	v10 = makeButton("StartBtn", "Start", 170, 1, true)
	v11 = makeButton("ApplyBtn", "Apply", 124, 2, true)
	v12 = makeButton("RetryBtn", "Retry", 124, 3, false)

	v10.MouseButton1Click:Connect(function()
		startRun()
	end)

	v11.MouseButton1Click:Connect(function()
		if v15 then
			SettingsState.SetAudioOffsetMs(v15)
		end

		AudioCalibrateUI.Hide()
	end)

	v12.MouseButton1Click:Connect(function()
		v10.Visible = true
		v11.Visible = false
		v12.Visible = false
		v5.Visible = false
		v7.Visible = false

		v6.Text = "Press Start when you're ready."
	end)

	local function syncButtonRow() -- 1 equivalent call inferred from this helper
		v8.Visible = v10.Visible or v11.Visible or v12.Visible
	end
	local v16 = { v10, v11, v12 }

	for _, v17 in ipairs(v16) do
		v17:GetPropertyChangedSignal("Visible"):Connect(syncButtonRow)
	end

	syncButtonRow() -- inferred equivalent call
	local closeButton = buildCloseButton(parent)
	closeButton.Visible = false

	local function syncCloseVisibility()
		closeButton.Visible = v11.Visible or v12.Visible
	end
	v11:GetPropertyChangedSignal("Visible"):Connect(syncCloseVisibility)
	v12:GetPropertyChangedSignal("Visible"):Connect(syncCloseVisibility)

	local function fitScale() -- 1 equivalent call inferred from this helper
		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		local viewportSize = currentCamera.ViewportSize
		uiScale.Scale = math.clamp(math.min(viewportSize.Y / 380, viewportSize.X / 460), 0.72, 1)
	end

	local function syncPanelHeight() -- 1 equivalent call inferred from this helper
		local v17 = math.ceil(parent3.AbsoluteSize.Y / math.max(uiScale.Scale, 0.01))

		if v17 > 0 and parent.Size.Y.Offset ~= v17 then
			parent.Size = UDim2.new(0.92, 0, 0, v17)
		end
	end
	parent3:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncPanelHeight)
	uiScale:GetPropertyChangedSignal("Scale"):Connect(syncPanelHeight)
	fitScale() -- inferred equivalent call
	syncPanelHeight() -- inferred equivalent call
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		viewportSizeChangedConnection = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitScale)
	end

	v4.Destroying:Connect(function()
		if viewportSizeChangedConnection then
			viewportSizeChangedConnection:Disconnect()
			viewportSizeChangedConnection = nil
		end
	end)

	v13 = make("Sound", { -- inferred equivalent call
		Name = "CalibrateClickSound",
		SoundId = "rbxassetid://91725271068764",
		Volume = 1
	}, v4)

	task.spawn(function()
		pcall(function()
			ContentProvider:PreloadAsync({ v13 })
		end)
	end)
end

function AudioCalibrateUI.Show()
	if v4 and name ~= SettingsState.GetUIStyle() then
		stopLoop() -- inferred equivalent call
		v4:Destroy()
		v4 = nil
	end

	build()
	v10.Visible = true
	v11.Visible = false
	v12.Visible = false
	v5.Visible = false
	v7.Visible = false

	v6.Text = "Press Start when you're ready."
	v4.Enabled = true
end

function AudioCalibrateUI.Hide()
	stopLoop() -- inferred equivalent call

	if v4 then
		v4.Enabled = false
	end
end

return AudioCalibrateUI