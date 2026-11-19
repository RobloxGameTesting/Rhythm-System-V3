local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local SettingsState = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SettingsState"))

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local NoticeStyle = {}

local colors = {
	Plate = Color3.fromRGB(26, 25, 23),
	FlatBg = Color3.fromRGB(16, 16, 19),
	FlatBorder = Color3.fromRGB(58, 58, 68),
	Ink = Color3.fromRGB(20, 18, 16),
	Bone = Color3.fromRGB(222, 220, 214),
	BodySoft = Color3.fromRGB(200, 198, 190),
	Muted = Color3.fromRGB(158, 156, 150),
	Edge = Color3.fromRGB(122, 120, 114),
	Rust = Color3.fromRGB(104, 58, 34),
	Tape = Color3.fromRGB(206, 190, 150),
	TapeDark = Color3.fromRGB(140, 126, 96),
	Stroke = Color3.fromRGB(8, 8, 8),
	Black = Color3.new(0, 0, 0),
	Amber = Color3.fromRGB(204, 162, 72),
	ButtonBg = Color3.fromRGB(15, 15, 14),
	ButtonHover = Color3.fromRGB(34, 34, 32),
	ButtonSelected = Color3.fromRGB(70, 58, 32)
}

NoticeStyle.Colors = colors

NoticeStyle.Kinds = {
	Global = {
		Tag = "ANNOUNCEMENT",
		Tape = Color3.fromRGB(214, 170, 80),
		Ink = colors.Ink,
		Accent = Color3.fromRGB(214, 170, 80)
	},
	Server = {
		Tag = "SERVER MESSAGE",
		Tape = Color3.fromRGB(122, 146, 164),
		Ink = colors.Ink,
		Accent = Color3.fromRGB(150, 172, 188)
	},
	Warn = {
		Tag = "MODERATOR",
		Tape = Color3.fromRGB(178, 62, 54),
		Ink = colors.Bone,
		Accent = Color3.fromRGB(214, 96, 84)
	},
	Countdown = {
		Tag = "NOTICE",
		Tape = Color3.fromRGB(214, 140, 48),
		Ink = colors.Ink,
		Accent = Color3.fromRGB(226, 150, 60)
	},
	Poll = {
		Tag = "POLL",
		Tape = Color3.fromRGB(96, 150, 104),
		Ink = colors.Ink,
		Accent = Color3.fromRGB(112, 176, 126)
	},
	Kick = {
		Tag = "PLAYER KICKED",
		Tape = Color3.fromRGB(214, 140, 48),
		Ink = colors.Ink,
		Accent = Color3.fromRGB(226, 150, 60)
	},
	Ban = {
		Tag = "PLAYER BANNED",
		Tape = Color3.fromRGB(178, 62, 54),
		Ink = colors.Bone,
		Accent = Color3.fromRGB(214, 96, 84)
	},
	ok = {
		Tape = Color3.fromRGB(96, 150, 104),
		Ink = colors.Ink,
		Accent = Color3.fromRGB(112, 176, 126)
	},
	error = {
		Tape = Color3.fromRGB(178, 62, 54),
		Ink = colors.Bone,
		Accent = Color3.fromRGB(214, 96, 84)
	},
	activity = {
		Tape = Color3.fromRGB(122, 146, 164),
		Ink = colors.Ink,
		Accent = Color3.fromRGB(150, 172, 188)
	},
	info = {
		Tape = Color3.fromRGB(214, 170, 80),
		Ink = colors.Ink,
		Accent = Color3.fromRGB(214, 170, 80)
	}
}

local v = {
	maxWidth = 440,
	minWidth = 300,
	holderTop = 12,
	tagH = 22,
	tagSize = 13,
	tapeX = 14,
	padTop = 20,
	padSide = 18,
	padBottom = 14,
	gap = 5,
	titleSize = 22,
	bodySize = 15,
	bodySoloSize = 17,
	timeSize = 17,
	toastPadTop = 12,
	toastPadBottom = 10,
	toastSize = 14,
	smallTape = Vector2.new(34, 13),
	transparency = 0,
	buttonH = 36,
	buttonSize = 14
}

local v2 = {
	maxWidth = 250,
	minWidth = 190,
	holderTop = 9,
	tagH = 17,
	tagSize = 11,
	tapeX = 10,
	padTop = 14,
	padSide = 11,
	padBottom = 9,
	gap = 3,
	titleSize = 16,
	bodySize = 12,
	bodySoloSize = 13,
	timeSize = 13,
	toastPadTop = 9,
	toastPadBottom = 7,
	toastSize = 12,
	smallTape = Vector2.new(26, 10),
	transparency = 0.12,
	buttonH = 28,
	buttonSize = 12
}

local v3 = { "NoteLaneUI", "NoteLaneUI3D" }
local v4 = {}
local compact2 = false
local v5 = {}

local function readPlaying()
	local modNoticeForcePlaying = PlayerGui:GetAttribute("ModNoticeForcePlaying")

	if typeof(modNoticeForcePlaying) == "boolean" then
		return modNoticeForcePlaying
	end

	for _, childName in ipairs(v3) do
		local screenGui = PlayerGui:FindFirstChild(childName)

		if screenGui and screenGui:IsA("ScreenGui") and screenGui.Enabled then
			return true
		end
	end

	return false
end

function NoticeStyle.IsPlaying()
	return compact2
end

function NoticeStyle.OnPlayingChanged(p)
	table.insert(v5, p)
end

compact2 = readPlaying()
task.spawn(function()
	while true do
		task.wait(0.25)
		local v6 = readPlaying()

		if v6 == compact2 then
			continue
		end

		compact2 = v6

		for k in pairs(v4) do
			if not k.Closed then
				k.SetCompact(v6)
			end
		end

		for _, callback in ipairs(v5) do
			task.spawn(callback, v6)
		end
	end
end)

local function mk(className, items, parent) -- 36 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function isGrunge(): boolean -- 3 equivalent calls inferred from this helper
	return SettingsState.GetUIStyle() ~= "Default"
end

local function viewportWidth() -- 1 equivalent call inferred from this helper
	local currentCamera = workspace.CurrentCamera
	return currentCamera and currentCamera.ViewportSize.X or 900
end

NoticeStyle.IsGrunge = isGrunge

function NoticeStyle.GetStack(value)
	local moderatorBroadcastUI = PlayerGui:WaitForChild("ModeratorBroadcastUI", value or 5)
	return moderatorBroadcastUI and moderatorBroadcastUI:WaitForChild("Stack", value or 5) or nil
end

local function buildTape(parent, data, p)
	local zIndex = data.ZIndex or 6
	local tape = mk("Frame", { -- inferred equivalent call
		Name = data.Name,
		AnchorPoint = data.AnchorPoint or Vector2.new(0, 0),
		BackgroundColor3 = data.Color,
		BackgroundTransparency = p and 0.06 or 0,
		BorderSizePixel = 0,
		Active = false,
		Position = data.Position,
		Rotation = p and data.Rotation or 0,
		Size = UDim2.fromOffset(data.Size.X, data.Size.Y),
		ZIndex = zIndex
	}, parent)

	if p then
		mk("UIStroke", { Color = colors.TapeDark, Thickness = 1, Transparency = 0.35 }, tape) -- inferred equivalent call
		mk("Frame", { -- inferred equivalent call
			Name = "Crease",
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = colors.TapeDark,
			BackgroundTransparency = 0.45,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.new(0.8, 0, 0, 0),
			Size = UDim2.new(0, 1, 1, 0),
			ZIndex = zIndex + 1
		}, tape)

		mk("Frame", { -- inferred equivalent call
			Name = "Fray",
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = colors.TapeDark,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 3, 0.7, 0),
			ZIndex = zIndex + 1
		}, tape)
	else
		mk("UICorner", { CornerRadius = UDim.new(0, 3) }, tape) -- inferred equivalent call
	end

	return tape
end

local function decorate(parent, random)
	local function edge(name, position, size, rotation, p)
		local parent2 = mk("Frame", { -- inferred equivalent call
			Name = name,
			BackgroundColor3 = colors.Black,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Active = false,
			Position = position,
			Size = size,
			ZIndex = 1
		}, parent)

		mk("UIGradient", { -- inferred equivalent call
			Rotation = rotation,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, p), NumberSequenceKeypoint.new(1, 1) })
		}, parent2)
	end
	edge("EdgeT", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 8), 90, 0.45)
	edge("EdgeB", UDim2.new(0, 0, 1, -8), UDim2.new(1, 0, 0, 8), 270, 0.4)
	edge("EdgeL", UDim2.new(0, 0, 0, 0), UDim2.new(0, 8, 1, 0), 0, 0.5)
	edge("EdgeR", UDim2.new(1, -8, 0, 0), UDim2.new(0, 8, 1, 0), 180, 0.5)

	mk("Frame", { -- inferred equivalent call
		Name = "BevelTop",
		BackgroundColor3 = colors.Edge,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.new(0, 2, 0, 1),
		Size = UDim2.new(1, -4, 0, 1),
		ZIndex = 1
	}, parent)

	for i = 1, 2 do
		local integer = random:NextInteger(24, 54)
		local parent2 = mk("Frame", { -- inferred equivalent call
			Name = "Stain" .. i,
			BackgroundColor3 = i == 1 and colors.Rust or colors.Black,
			BackgroundTransparency = 0.78 + random:NextNumber() * 0.08,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber() * 0.8, random:NextNumber() * 0.5),
			Size = UDim2.fromOffset(integer, (math.floor(integer * 0.6))),
			ZIndex = 1
		}, parent)

		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
	end

	for i = 1, 3 do
		mk("Frame", { -- inferred equivalent call
			Name = "Scratch" .. i,
			BackgroundColor3 = colors.Bone,
			BackgroundTransparency = 0.8 + random:NextNumber() * 0.08,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber() * 0.7, random:NextNumber()),
			Size = UDim2.fromOffset(random:NextInteger(16, 46), 1),
			Rotation = random:NextInteger(-30, 30),
			ZIndex = 1
		}, parent)
	end

	for i = 1, 14 do
		local v6 = random:NextNumber() > 0.4
		local integer = random:NextInteger(1, 2)
		mk("Frame", { -- inferred equivalent call
			Name = "Speck" .. i,
			BackgroundColor3 = v6 and colors.Bone or colors.Black,
			BackgroundTransparency = v6 and 0.8 + random:NextNumber() * 0.12 or 0.45 + random:NextNumber() * 0.25,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
			Size = UDim2.fromOffset(integer, integer),
			ZIndex = 1
		}, parent)
	end

	for i, v6 in ipairs({
		{ 0, 1, 7, -7 },
		{ 1, 1, -7, -7 }
	}) do
		local parent2 = mk("Frame", { -- inferred equivalent call
			Name = "Screw" .. i,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(110, 104, 92),
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.new(v6[1], v6[3], v6[2], v6[4]),
			Size = UDim2.fromOffset(7, 7),
			ZIndex = 1
		}, parent)

		mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
		mk("UIStroke", { Color = colors.Black, Thickness = 1.5, Transparency = 0.2 }, parent2) -- inferred equivalent call
		mk("Frame", { -- inferred equivalent call
			Name = "Slot",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = colors.Black,
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(5, 1),
			Rotation = random:NextInteger(-70, 70),
			ZIndex = 1
		}, parent2)
	end
end

function NoticeStyle.createCard(parent, data)
	local grunge = isGrunge() -- inferred equivalent call
	local oswald = grunge and Enum.Font.Oswald or Enum.Font.GothamBold
	local specialElite = grunge and Enum.Font.SpecialElite or Enum.Font.GothamMedium
	local kind = NoticeStyle.Kinds[data.kind] or NoticeStyle.Kinds.Global
	local random = Random.new(math.floor(os.clock() * 1000) % 100000)

	local card = { Compact = compact2, Closed = false, Kind = kind, Grunge = grunge }

	local v6 = {
		Name = "NoticeSlot",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		LayoutOrder = data.order or 0,
		Size = UDim2.fromOffset(0, 0)
	}
	local frame = Instance.new("Frame")

	local callbacks = {}

	for k, v7 in pairs(v6) do
		frame[k] = v7
	end

	frame.Parent = parent

	local holder = mk("CanvasGroup", { -- inferred equivalent call
		Name = "NoticeHolder",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Position = UDim2.fromOffset(0, -14),
		Size = UDim2.fromOffset(0, 0)
	}, frame)

	local uiPadding = mk("UIPadding", {}, holder) -- inferred equivalent call

	local card2 = mk("Frame", { -- inferred equivalent call
		Name = "NoticeCard",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = grunge and colors.Plate or colors.FlatBg,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Active = false,
		Size = UDim2.fromOffset(0, 0),
		ZIndex = 2
	}, holder)

	mk("UICorner", { -- inferred equivalent call
		CornerRadius = UDim.new(0, grunge and 2 or 6)
	}, card2)
	local parent2 = mk("UIStroke", { -- inferred equivalent call
		Color = grunge and colors.Stroke or colors.FlatBorder,
		Thickness = grunge and 2 or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, card2)

	if grunge then
		mk("UIGradient", { -- inferred equivalent call
			Rotation = random:NextInteger(0, 180),
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(215, 214, 208)),
				ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 158, 150))
			})
		}, card2)

		mk("UIGradient", { -- inferred equivalent call
			Rotation = random:NextInteger(0, 90),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.2, 0.15),
				NumberSequenceKeypoint.new(0.33, 0.85),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(0.72, 0.7),
				NumberSequenceKeypoint.new(0.88, 0.1),
				NumberSequenceKeypoint.new(1, 0)
			})
		}, parent2)

		decorate(card2, random)
	end

	local content = mk("Frame", { -- inferred equivalent call
		Name = "Content",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(0, 0),
		ZIndex = 3
	}, card2)

	local uiPadding2 = mk("UIPadding", {}, content) -- inferred equivalent call
	local uiSizeConstraint = mk("UISizeConstraint", {}, content) -- inferred equivalent call
	local uiListLayout = mk("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, content) -- inferred equivalent call

	local function textLabel(name, font, textColor, layoutOrder, value)
		local parent3 = mk("TextLabel", { -- inferred equivalent call
			Name = name,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = font,
			LayoutOrder = layoutOrder,
			Size = UDim2.fromOffset(0, 0),
			Text = value or "",
			TextColor3 = textColor,
			TextSize = 14,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 3
		}, content)

		return parent3, mk("UISizeConstraint", {}, parent3) -- inferred equivalent call
	end

	local body = nil
	local v7 = nil
	local title, v8

	if typeof(data.title) == "string" and data.title ~= "" then
		title, v8 = textLabel("Title", oswald, colors.Bone, 2, data.title)
	else
		title = nil
		v8 = nil
	end

	if typeof(data.body) == "string" and data.body ~= "" then
		body, v7 = textLabel("Body", specialElite, title and colors.BodySoft or colors.Bone, 3, data.body)
		body.RichText = data.richText == true
	end

	local time, v9 = textLabel("Time", oswald, kind.Accent, 4, "")
	time.Visible = false
	local v10

	if typeof(data.tag) == "string" then
		v10 = data.tag ~= ""
	else
		v10 = false
	end

	local tape = buildTape(holder, {
		Name = "TagTape",
		Color = kind.Tape,
		Rotation = -2.5,
		Position = UDim2.fromOffset(14, -10),
		Size = Vector2.new(60, 20),
		ZIndex = 8
	}, grunge)
	local textLabel2

	if v10 then
		local v11 = {
			Name = "Tag",
			BackgroundTransparency = 1,
			Font = oswald,
			Size = UDim2.fromScale(1, 1),
			Text = data.tag,
			TextColor3 = kind.Ink,
			TextSize = 13,
			ZIndex = 10
		}
		textLabel2 = Instance.new("TextLabel")

		for k, v12 in pairs(v11) do
			textLabel2[k] = v12
		end

		textLabel2.Parent = tape
	else
		textLabel2 = nil
	end

	local v11

	if grunge and not data.toast then
		v11 = buildTape(holder, {
			Name = "CornerTape",
			AnchorPoint = Vector2.new(1, 0),
			Color = colors.Tape,
			Rotation = 5,
			Position = UDim2.new(1, 4, 0, -7),
			Size = Vector2.new(34, 15),
			ZIndex = 8
		}, true)
	else
		v11 = nil
	end

	local function apply()
		local v12 = card.Compact and v2 or v
		local maxWidth = v12.maxWidth
		local v13 = math.max(180, (math.min(maxWidth, viewportWidth() - 60))) -- inferred equivalent call
		local v14 = v13 - v12.padSide * 2

		uiPadding.PaddingTop = UDim.new(0, v12.holderTop)
		uiPadding.PaddingBottom = UDim.new(0, 6)
		uiPadding.PaddingLeft = UDim.new(0, 10)
		uiPadding.PaddingRight = UDim.new(0, 10)

		uiPadding2.PaddingTop = UDim.new(0, data.toast and v12.toastPadTop or v12.padTop)
		uiPadding2.PaddingBottom = UDim.new(0, data.toast and v12.toastPadBottom or v12.padBottom)
		uiPadding2.PaddingLeft = UDim.new(0, v12.padSide)
		uiPadding2.PaddingRight = UDim.new(0, v12.padSide)
		uiListLayout.Padding = UDim.new(0, v12.gap)
		uiSizeConstraint.MinSize = Vector2.new(math.min(data.minWidth or v12.minWidth, v13), 0)
		uiSizeConstraint.MaxSize = Vector2.new(v13, 1e999)

		if title then
			title.TextSize = v12.titleSize
			v8.MaxSize = Vector2.new(v14, 1e999)
		end

		if body then
			body.TextSize = data.toast and v12.toastSize or title and v12.bodySize or v12.bodySoloSize
			v7.MaxSize = Vector2.new(v14, 1e999)
		end

		time.TextSize = v12.timeSize
		v9.MaxSize = Vector2.new(v14, 1e999)
		local v15, v16

		if v10 then
			v15 = v12.tagH
			v16 = TextService:GetTextSize(data.tag, v12.tagSize, oswald, Vector2.new(600, 60)).X + 22
			textLabel2.TextSize = v12.tagSize
		else
			v16 = v12.smallTape.X
			v15 = v12.smallTape.Y
		end

		tape.Size = UDim2.fromOffset(v16, v15)
		tape.Position = UDim2.fromOffset(v12.tapeX, -math.floor(v15 * 0.5))

		if v11 then
			v11.Visible = not card.Compact
		end
	end
	apply()

	card.Slot = frame
	card.Holder = holder
	card.Card = card2
	card.Content = content
	card.Title = title
	card.Body = body
	card.Time = time

	local function tweenHolder(goal, duration) -- 3 equivalent calls inferred from this helper
		TweenService:Create(holder, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
	end

	function card.SetCompact(compact)
		if card.Compact == compact then
			return
		end

		card.Compact = compact
		apply()

		if not card.Closed then
			tweenHolder({ -- inferred equivalent call
				GroupTransparency = compact and v2.transparency or v.transparency
			}, 0.2)
		end

		for _, v12 in ipairs(callbacks) do
			v12(compact)
		end
	end

	function card.OnCompact(callback)
		table.insert(callbacks, callback)
		callback(card.Compact)
	end

	function card.Dismiss()
		if card.Closed then
			return
		end

		card.Closed = true
		v4[card] = nil
		tweenHolder({ GroupTransparency = 1, Position = UDim2.fromOffset(0, -8.4) }, 0.22) -- inferred equivalent call
		task.delay(0.25, function()
			frame:Destroy()
		end)
	end

	function card.StartTimer(duration)
		TweenService:Create(mk("Frame", { -- inferred equivalent call
			Name = "Timer",
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = kind.Accent,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, 3),
			ZIndex = 5
		}, card2), TweenInfo.new(duration, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, 0, 3)
		}):Play()
		task.delay(duration, card.Dismiss)
	end

	v4[card] = true
	tweenHolder({ -- inferred equivalent call
		GroupTransparency = card.Compact and v2.transparency or v.transparency,
		Position = UDim2.fromOffset(0, 0)
	}, 0.22)

	return card
end

function NoticeStyle.MakeButton(parent, text, layoutOrder)
	local grunge = isGrunge() -- inferred equivalent call
	local button = mk("TextButton", { -- inferred equivalent call
		Name = "Option",
		AutoButtonColor = false,
		BackgroundColor3 = colors.ButtonBg,
		BorderSizePixel = 0,
		Font = grunge and Enum.Font.SpecialElite or Enum.Font.GothamMedium,
		LayoutOrder = layoutOrder,
		Selectable = false,
		Size = UDim2.new(1, 0, 0, v.buttonH),
		Text = text,
		TextColor3 = colors.Bone,
		TextSize = v.buttonSize,
		TextWrapped = true,
		ZIndex = 3
	}, parent)

	mk("UICorner", { -- inferred equivalent call
		CornerRadius = UDim.new(0, grunge and 2 or 6)
	}, button)
	local uiStroke = mk( -- inferred equivalent call
		"UIStroke",
		{ Color = colors.Stroke, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border },
		button
	)
	button.MouseEnter:Connect(function()
		if button.Active then
			button.BackgroundColor3 = colors.ButtonHover
			uiStroke.Color = colors.Edge
		end
	end)
	button.MouseLeave:Connect(function()
		if button.Active then
			button.BackgroundColor3 = colors.ButtonBg
			uiStroke.Color = colors.Stroke
		end
	end)
	return button
end

function NoticeStyle:SetButtonState(p)
	local uiStroke = self:FindFirstChildOfClass("UIStroke")

	if p == "selected" then
		self.BackgroundColor3 = colors.ButtonSelected
		self.TextColor3 = colors.Amber
		self.TextTransparency = 0

		if uiStroke then
			uiStroke.Color = colors.Amber
		end
	elseif p == "dim" then
		self.TextTransparency = 0.55
	end
end

function NoticeStyle:SizeButton(p)
	local v6 = p and v2 or v
	self.Size = UDim2.new(1, 0, 0, v6.buttonH)
	self.TextSize = v6.buttonSize
end

function NoticeStyle.MakeFooter(parent, layoutOrder)
	return mk("TextLabel", { -- inferred equivalent call
		Name = "Footer",
		BackgroundTransparency = 1,
		Font = isGrunge() and Enum.Font.SpecialElite or Enum.Font.GothamMedium, -- inferred equivalent call
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, 16),
		Text = "",
		TextColor3 = colors.Muted,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3
	}, parent)
end

function NoticeStyle.MakeProgress(parent, backgroundColor, layoutOrder)
	local parent2 = mk("Frame", { -- inferred equivalent call
		Name = "Track",
		BackgroundColor3 = colors.Black,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, 5),
		ZIndex = 3
	}, parent)

	return parent2, mk("Frame", { -- inferred equivalent call
		Name = "Fill",
		BackgroundColor3 = backgroundColor,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 4
	}, parent2)
end

return NoticeStyle