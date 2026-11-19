local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

local DifficultyBadge = require(script.Parent.SongListUI.DifficultyBadge)

local CatalogBoardUI = {}
CatalogBoardUI.__index = CatalogBoardUI

CatalogBoardUI.CanvasSize = Vector2.new(700, 990)

CatalogBoardUI.Layout = {
	ListY = 166,
	ListH = 798,
	RowH = 116,
	DefaultScrollPadding = 30,
	WrapW = 448,
	WrapH = 418
}

local color = Color3.fromRGB(247, 240, 212)
local color2 = Color3.fromRGB(225, 211, 170)
local color3 = Color3.fromRGB(26, 22, 20)
local color4 = Color3.fromRGB(78, 66, 56)
local color5 = Color3.fromRGB(176, 32, 36)
local color6 = Color3.fromRGB(66, 98, 168)
local color7 = Color3.fromRGB(198, 62, 62)
local color8 = Color3.fromRGB(214, 28, 44)
local color9 = Color3.fromRGB(96, 10, 20)
local color10 = Color3.fromRGB(240, 230, 198)
local color11 = Color3.fromRGB(252, 226, 116)

local function pickFont(list, p)
	for _, item in ipairs(list) do
		local success, result = pcall(function()
			return Enum.Font[item]
		end)

		if success and result then
			return result
		end
	end

	return p
end

local font = pickFont({ "PermanentMarker", "Bangers" }, Enum.Font.GothamBlack)
local font2 = pickFont({ "Kalam", "PatrickHand", "IndieFlower" }, Enum.Font.SourceSansSemibold)
local SourceSansBold = Enum.Font.SourceSansBold

local v = {
	GuitarRhythm = "Rhythm Guitar",
	GuitarLead = "Lead Guitar",
	Bass = "Bass",
	Drum = "Drum",
	Keyboard = "Keyboard",
	Piano = "Piano"
}

local function create(className, items, parent) -- 70 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function makeLabel(parent, items)
	local v2 = {
		BackgroundTransparency = 1,
		Font = font2,
		TextSize = 20,
		TextColor3 = color3,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd
	}

	for k, item in pairs(items) do
		v2[k] = item
	end

	return create("TextLabel", v2, parent) -- inferred equivalent call
end

local getTextBoundsParams = Instance.new("GetTextBoundsParams")

local function measureWidth(text, p, size)
	local success, result = pcall(function()
		getTextBoundsParams.Text = text
		getTextBoundsParams.Font = Font.fromEnum(p)
		getTextBoundsParams.Size = size
		getTextBoundsParams.Width = 10000
		return TextService:GetTextBoundsAsync(getTextBoundsParams)
	end)

	if success and result then
		return result.X
	end

	return #text * size * 0.55
end

local function formatDuration(duration) -- 1 equivalent call inferred from this helper
	if typeof(duration) ~= "number" then
		return nil
	end

	local v2 = math.max(0, (math.floor(duration + 0.5)))
	return string.format("%d:%02d minutes", v2 // 60, v2 % 60)
end

local function formatNumber(p)
	local v2 = tostring(((math.floor)(p)))
	local v3 = string.reverse(v2)
	local v4 = string.gsub(v3, "(%d%d%d)", "%1,")
	local v5 = string.reverse(v4)
	return (string.gsub(v5, "^,", ""))
end

local function instrumentLabel(instrument) -- 3 equivalent calls inferred from this helper
	return v[instrument] or tostring(instrument or "?")
end

local function buildInfoText(data)
	local v2 = { data.artist or "Unknown Artist" }
	local v3 = formatDuration(data.duration) -- inferred equivalent call

	if v3 then
		table.insert(v2, v3)
	end

	if typeof(data.bpm) == "number" then
		table.insert(v2, string.format("%d BPM", data.bpm))
	end

	if data.genre and data.genre ~= "" then
		table.insert(v2, data.genre)
	end

	return table.concat(v2, ", ")
end

local function favoritesText(p) -- 1 equivalent call inferred from this helper
	return string.format("%s %s", formatNumber(p), p == 1 and "Favorite" or "Favorites")
end

local function topScoreText(data) -- 1 equivalent call inferred from this helper
	if not data then
		return "Top score: -  nobody yet, go claim it", true
	end

	return
		string.format(
			"Top score: %s - %s (%s)",
			formatNumber(data.Score or 0),
			tostring(data.Name or "?"),
			instrumentLabel(data.Instrument) -- inferred equivalent call
		),
		false
end

local function buildDropdown(object, p, dropdownSurface)
	object._dropTweens = {}

	object._dropSeparate = dropdownSurface ~= nil

	local v2 = {
		Name = "DropWrap",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = UDim2.fromOffset(448, 418),
		Visible = false,
		ZIndex = 20
	}
	local frame = Instance.new("Frame")

	for k, v3 in pairs(v2) do
		frame[k] = v3
	end

	frame.Parent = dropdownSurface or p

	local dropShadow = create("Frame", { -- inferred equivalent call
		Name = "DropShadow",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(420, 376),
		Position = UDim2.fromOffset(20, 26),
		Rotation = 1
	}, frame)

	create("UICorner", { CornerRadius = UDim.new(0, 4) }, dropShadow) -- inferred equivalent call

	local drop = create("TextButton", { -- inferred equivalent call
		Name = "Dropdown",
		AutoButtonColor = false,
		Text = "",
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.fromOffset(420, 376),
		Position = UDim2.fromOffset(14, 18),
		Rotation = 1
	}, frame)

	create("UICorner", { CornerRadius = UDim.new(0, 4) }, drop) -- inferred equivalent call
	create("UIStroke", { Color = Color3.fromRGB(110, 84, 48), Thickness = 2, Transparency = 0.35 }, drop) -- inferred equivalent call
	create( -- inferred equivalent call
		"UIGradient",
		{
			Rotation = 90,
			Color = ColorSequence.new(Color3.fromRGB(255, 250, 232), Color3.fromRGB(240, 229, 196))
		},
		drop
	)

	local dropScale = create("UIScale", { Scale = 1 }, drop) -- inferred equivalent call

	create("Frame", { -- inferred equivalent call
		Name = "Margin",
		BackgroundColor3 = color7,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(52, 56),
		Size = UDim2.fromOffset(2, 228)
	}, drop)

	create("Frame", { -- inferred equivalent call
		Name = "Tape",
		BackgroundColor3 = Color3.fromRGB(34, 34, 38),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(166, -10),
		Size = UDim2.fromOffset(88, 22),
		Rotation = -4
	}, drop)

	makeLabel(drop, {
		Name = "TitleShadow",
		Position = UDim2.fromOffset(20, 10),
		Size = UDim2.fromOffset(100, 44),
		Font = font,
		Text = "Top 5",
		TextSize = 36,
		TextColor3 = color5,
		TextTransparency = 0.12
	})

	makeLabel(drop, {
		Name = "Title",
		Position = UDim2.fromOffset(17, 7),
		Size = UDim2.fromOffset(100, 44),
		Font = font,
		Text = "Top 5",
		TextSize = 36
	})

	object._dropSub = makeLabel(drop, {
		Name = "SongName",
		AutoLocalize = false,
		Position = UDim2.fromOffset(122, 22),
		Size = UDim2.fromOffset(242, 26),
		Text = "",
		TextSize = 20,
		TextColor3 = color4
	})

	create("Frame", { -- inferred equivalent call
		Name = "Underline",
		BackgroundColor3 = color5,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(18, 52),
		Size = UDim2.fromOffset(300, 4),
		Rotation = -1.2
	}, drop)

	local parent = create("TextButton", { -- inferred equivalent call
		Name = "CloseButton",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 6),
		Size = UDim2.fromOffset(36, 36),
		BackgroundColor3 = color7,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBlack,
		Text = "X",
		TextSize = 20,
		TextColor3 = Color3.fromRGB(244, 232, 200),
		Rotation = 4
	}, drop)

	create("UICorner", { CornerRadius = UDim.new(0, 4) }, parent) -- inferred equivalent call
	create("UIStroke", { Color = color3, Thickness = 2 }, parent) -- inferred equivalent call
	local uiScale = create("UIScale", { Scale = 1 }, parent) -- inferred equivalent call
	parent.MouseEnter:Connect(function()
		object._hoverCount += 1
		TweenService:Create(uiScale, TweenInfo.new(0.12), { Scale = 1.12 }):Play()
	end)
	parent.MouseLeave:Connect(function()
		object._hoverCount = math.max(0, object._hoverCount - 1)
		TweenService:Create(uiScale, TweenInfo.new(0.12), { Scale = 1 }):Play()
	end)
	parent.MouseButton1Click:Connect(function()
		uiScale.Scale = 0.85
		TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
		object:CloseDropdown()
	end)

	object._dropEntries = create("Frame", { -- inferred equivalent call
		Name = "Entries",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 60),
		Size = UDim2.new(1, 0, 0, 220)
	}, drop)

	local parent2 = create("Frame", { -- inferred equivalent call
		Name = "Divider",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(10, 282),
		Size = UDim2.new(1, -20, 0, 16)
	}, drop)

	create("TextLabel", { -- inferred equivalent call
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 1000, 1, 0),
		Font = Enum.Font.Code,
		Text = string.rep("- ", 120),
		TextSize = 18,
		TextColor3 = color6,
		TextTransparency = 0.35,
		TextXAlignment = Enum.TextXAlignment.Left
	}, parent2)

	object._dropYou = create("Frame", { -- inferred equivalent call
		Name = "You",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 298),
		Size = UDim2.new(1, 0, 0, 64)
	}, drop)

	object._dropWrap = frame
	object._drop = drop
	object._dropShadow = dropShadow
	object._dropScale = dropScale
end

local function clearChildren(instance) -- 2 equivalent calls inferred from this helper
	for _, child in ipairs(instance:GetChildren()) do
		child:Destroy()
	end
end

local function renderDropdown(object, record, data)
	clearChildren(object._dropEntries) -- inferred equivalent call
	clearChildren(object._dropYou) -- inferred equivalent call
	object._dropSub.Text = record.displayName

	if data == nil or data == false then
		makeLabel(object._dropEntries, {
			Position = UDim2.fromOffset(20, 0),
			Size = UDim2.new(1, -40, 1, 0),
			Text = data == nil and "flipping through the records..." or "couldn't load the scores. Press X to close this, then try again.",
			TextSize = 22,
			TextColor3 = color4,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.None
		})

		return
	end

	local top = data.Top or {}

	for i = 1, 5 do
		local v2 = top[i]
		local parent = create("Frame", { -- inferred equivalent call
			Name = "Slot" .. i,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, (i - 1) * 44),
			Size = UDim2.new(1, 0, 0, 44)
		}, object._dropEntries)

		if v2 and v2.IsYou then
			create("Frame", { -- inferred equivalent call
				Name = "YouHighlight",
				BackgroundColor3 = color11,
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(8, 2),
				Size = UDim2.new(1, -16, 1, -4)
			}, parent)
		end

		makeLabel(parent, {
			Name = "Rank",
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.fromOffset(38, 44),
			Font = font,
			Text = tostring(i) .. ".",
			AutoLocalize = false,
			TextSize = 28,
			TextColor3 = i == 1 and color5 or color3,
			TextTransparency = v2 and 0 or 0.55,
			TextXAlignment = Enum.TextXAlignment.Right
		})

		if v2 then
			makeLabel(parent, {
				Name = "PlayerName",
				Position = UDim2.fromOffset(62, 3),
				Size = UDim2.fromOffset(208, 24),
				Text = tostring(v2.Name or "?"),
				AutoLocalize = false,
				TextSize = 22
			})

			makeLabel(parent, {
				Name = "Instrument",
				Position = UDim2.fromOffset(62, 24),
				Size = UDim2.fromOffset(208, 18),
				Text = "(" .. instrumentLabel(v2.Instrument) .. ")", -- inferred equivalent call
				AutoLocalize = false,
				TextSize = 16,
				TextColor3 = color4
			})

			makeLabel(parent, {
				Name = "Score",
				Position = UDim2.fromOffset(268, 0),
				Size = UDim2.fromOffset(138, 44),
				Font = font,
				Text = formatNumber(v2.Score or 0),
				AutoLocalize = false,
				TextSize = 24,
				TextXAlignment = Enum.TextXAlignment.Right
			})
		else
			makeLabel(parent, {
				Name = "Empty",
				Position = UDim2.fromOffset(62, 0),
				Size = UDim2.fromOffset(200, 44),
				Text = "- - -",
				TextSize = 22,
				TextColor3 = color4,
				TextTransparency = 0.55
			})
		end
	end

	local you = data.You
	local text, text2, text3

	if you then
		if you.Rank then
			text = "#" .. tostring(you.Rank)
		else
			text = tostring(data.Total or 100) .. "+"
		end

		text2 = formatNumber(you.Score or 0)
		text3 = "(" .. instrumentLabel(you.Instrument) .. ")" -- inferred equivalent call
	else
		text = "-"
		text2 = "no score yet"
		text3 = ""
	end

	makeLabel(object._dropYou, {
		Name = "YourRank",
		Position = UDim2.fromOffset(10, 4),
		Size = UDim2.fromOffset(96, 56),
		Font = font,
		Text = text,
		AutoLocalize = false,
		TextSize = 36,
		TextColor3 = color5,
		TextXAlignment = Enum.TextXAlignment.Center
	})

	makeLabel(object._dropYou, {
		Name = "YourScoreCaption",
		Position = UDim2.fromOffset(114, 4),
		Size = UDim2.fromOffset(220, 22),
		Text = "your score",
		TextSize = 20,
		TextColor3 = color4
	})

	makeLabel(object._dropYou, {
		Name = "YourScore",
		Position = UDim2.fromOffset(114, 24),
		Size = UDim2.fromOffset(190, 34),
		Font = you and font or font2,
		Text = text2,
		AutoLocalize = you == nil,
		TextSize = you and 28 or 22,
		TextColor3 = you and color3 or color4
	})

	makeLabel(object._dropYou, {
		Name = "YourInstrument",
		Position = UDim2.fromOffset(256, 34),
		Size = UDim2.fromOffset(150, 22),
		Text = text3,
		AutoLocalize = false,
		TextSize = 18,
		TextColor3 = color4,
		TextXAlignment = Enum.TextXAlignment.Right
	})
end

function CatalogBoardUI.new(gui, options)
	local v2 = options or {}
	local object = setmetatable({}, CatalogBoardUI)
	object._gui = gui
	object._onFavoriteClicked = v2.onFavoriteClicked
	object._onRequestLeaderboard = v2.onRequestLeaderboard
	object._onDropdownOpened = v2.onDropdownOpened
	object._onDropdownClosed = v2.onDropdownClosed
	object._rows = {}
	object._favorites = {}
	object._counts = {}
	object._top = {}
	object._destroyed = false
	object._dropToken = 0
	object._dropSongId = nil
	object._dropScrollY = 0
	object._hoverCount = 0

	local root = create( -- inferred equivalent call
		"Frame",
		{
			Name = "CatalogRoot",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0
		},
		gui
	)

	object._root = root

	local parent = create("Frame", { -- inferred equivalent call
		Name = "Paper",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ClipsDescendants = true
	}, root)

	create("UIGradient", { -- inferred equivalent call
		Rotation = 90,
		Color = ColorSequence.new(color, color2)
	}, parent)

	create("UICorner", { CornerRadius = UDim.new(0, 10) }, parent) -- inferred equivalent call
	create("UIStroke", { Color = Color3.fromRGB(120, 92, 52), Thickness = 6, Transparency = 0.6 }, parent) -- inferred equivalent call

	local parent2 = create("Frame", { -- inferred equivalent call
		Name = "CoffeeRing",
		BackgroundColor3 = Color3.fromRGB(190, 148, 86),
		BackgroundTransparency = 0.9,
		Size = UDim2.fromOffset(170, 170),
		Position = UDim2.fromOffset(470, 720),
		BorderSizePixel = 0
	}, parent)

	create("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
	create("UIStroke", { Color = Color3.fromRGB(122, 82, 40), Thickness = 8, Transparency = 0.72 }, parent2) -- inferred equivalent call

	local parent3 = create("Frame", { -- inferred equivalent call
		Name = "Stain",
		BackgroundColor3 = Color3.fromRGB(150, 112, 62),
		BackgroundTransparency = 0.88,
		Size = UDim2.fromOffset(64, 64),
		Position = UDim2.fromOffset(110, 430),
		BorderSizePixel = 0
	}, parent)

	create("UICorner", { CornerRadius = UDim.new(1, 0) }, parent3) -- inferred equivalent call

	create("Frame", { -- inferred equivalent call
		Name = "MarginLine",
		BackgroundColor3 = color7,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(62, -10),
		Size = UDim2.fromOffset(3, 1010),
		Rotation = 0.2
	}, parent)

	create("Frame", { -- inferred equivalent call
		Name = "MarginLine2",
		BackgroundColor3 = color7,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(70, -10),
		Size = UDim2.fromOffset(2, 1010),
		Rotation = 0.2
	}, parent)

	for _, v3 in ipairs({ 190, 495, 800 }) do
		local parent4 = create("Frame", { -- inferred equivalent call
			Name = "Hole",
			BackgroundColor3 = Color3.fromRGB(46, 38, 32),
			Size = UDim2.fromOffset(26, 26),
			Position = UDim2.fromOffset(16, v3),
			BorderSizePixel = 0
		}, parent)

		create("UICorner", { CornerRadius = UDim.new(1, 0) }, parent4) -- inferred equivalent call
		create("UIStroke", { -- inferred equivalent call
			Color = Color3.fromRGB(150, 128, 92),
			Thickness = 2,
			Transparency = 0.2
		}, parent4)
	end

	local parent4 = create("Frame", { -- inferred equivalent call
		Name = "Header",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 158),
		BorderSizePixel = 0
	}, root)

	create("UITextSizeConstraint", { MaxTextSize = 68, MinTextSize = 20 }, create("TextLabel", { -- inferred equivalent call
		Name = "TitleShadow",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(114, 38),
		Size = UDim2.fromOffset(520, 84),
		Font = font,
		Text = "Song Catalog:",
		TextScaled = true,
		TextColor3 = color5,
		TextTransparency = 0.12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Rotation = -2
	}, parent4))

	create("UITextSizeConstraint", { MaxTextSize = 68, MinTextSize = 20 }, create("TextLabel", { -- inferred equivalent call
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(110, 34),
		Size = UDim2.fromOffset(520, 84),
		Font = font,
		Text = "Song Catalog:",
		TextScaled = true,
		TextColor3 = color3,
		TextXAlignment = Enum.TextXAlignment.Left,
		Rotation = -2
	}, parent4))

	create("Frame", { -- inferred equivalent call
		Name = "Scribble1",
		BackgroundColor3 = color5,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(112, 124),
		Size = UDim2.fromOffset(440, 5),
		Rotation = -1.4
	}, parent4)

	create("Frame", { -- inferred equivalent call
		Name = "Scribble2",
		BackgroundColor3 = color3,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(138, 135),
		Size = UDim2.fromOffset(370, 3),
		Rotation = 0.9
	}, parent4)

	object._songCountLabel = create("TextLabel", { -- inferred equivalent call
		Name = "SongCount",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -28, 0, 108),
		Size = UDim2.fromOffset(130, 24),
		Font = font2,
		Text = "",
		TextSize = 22,
		TextColor3 = color6,
		TextXAlignment = Enum.TextXAlignment.Right,
		Rotation = -4
	}, parent4)

	create("TextLabel", { -- inferred equivalent call
		Name = "ScrollHint",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -28, 0, 130),
		Size = UDim2.fromOffset(130, 22),
		Font = font2,
		Text = "scroll down",
		TextSize = 18,
		TextColor3 = color6,
		TextTransparency = 0.25,
		TextXAlignment = Enum.TextXAlignment.Right,
		Rotation = -4
	}, parent4)

	create("Frame", { -- inferred equivalent call
		Name = "HeaderRule",
		BackgroundColor3 = color3,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(76, 158),
		Size = UDim2.fromOffset(602, 3),
		Rotation = -0.3
	}, root)

	local list = create("ScrollingFrame", { -- inferred equivalent call
		Name = "SongList",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(76, 166),
		Size = UDim2.fromOffset(610, 798),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 7,
		ScrollBarImageColor3 = color3,
		ScrollBarImageTransparency = 0.25,
		ElasticBehavior = Enum.ElasticBehavior.Never,
		ClipsDescendants = true
	}, root)

	object._list = list
	create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0) }, list) -- inferred equivalent call

	object._listPadding = create("UIPadding", { -- inferred equivalent call
		PaddingRight = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 30)
	}, list)

	local parent5 = create("Frame", { -- inferred equivalent call
		Name = "FadeTop",
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(76, 166),
		Size = UDim2.fromOffset(600, 20),
		Active = false
	}, root)

	create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(0, 1) }, parent5) -- inferred equivalent call

	local parent6 = create("Frame", { -- inferred equivalent call
		Name = "FadeBottom",
		BackgroundColor3 = color2,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(76, 938),
		Size = UDim2.fromOffset(600, 26),
		Active = false
	}, root)

	create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }, parent6) -- inferred equivalent call

	buildDropdown(object, root, v2.dropdownSurface)

	list:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		object:_updateVirtual()
	end)

	list:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if object._dropSongId and math.abs(list.CanvasPosition.Y - object._dropScrollY) > 4 then
			object:CloseDropdown()
		end
	end)

	return object
end

local function renderHeart(p, p2) -- 3 equivalent calls inferred from this helper
	p.heart.TextColor3 = p2 and color8 or color10
	p.heartStroke.Color = p2 and color9 or color3
	p.heartStroke.Thickness = p2 and 2 or 2.5
end

local function layoutInfoLine(data)
	local text = data.countLabel.Text
	local font3 = font
	local size = 23
	local success, result = pcall(function()
		getTextBoundsParams.Text = text
		getTextBoundsParams.Font = Font.fromEnum(font3)
		getTextBoundsParams.Size = size
		getTextBoundsParams.Width = 10000
		return TextService:GetTextBoundsAsync(getTextBoundsParams)
	end)
	local v2

	if success and result then
		v2 = result.X
	else
		v2 = #text * 23 * 0.55
	end

	local v3 = math.ceil(v2) + 6
	local v4 = 548 - v3
	local v5 = math.max(60, v4 - 40 - 8)
	local v6 = math.min(data.infoNaturalWidth, v5)

	data.info.Size = UDim2.new(0, v6, 1, 0)
	data.countLabel.Position = UDim2.new(0, v4, 0, 0)
	data.countLabel.Size = UDim2.new(0, v3, 1, 0)

	local v7 = v6 + 8
	data.leader.Position = UDim2.new(0, v7, 0, 0)
	data.leader.Size = UDim2.new(0, math.max(0, v4 - 8 - v7), 1, 0)
end

local function refreshRow(data, data2)
	local songId = data2.songId

	local text = favoritesText(data._counts[songId] or 0) -- inferred equivalent call

	if data2.countLabel.Text ~= text then
		data2.countLabel.Text = text
		layoutInfoLine(data2)
	end

	local text2, v2 = topScoreText(data._top[songId]) -- inferred equivalent call

	if data2.topLabel.Text ~= text2 then
		data2.topLabel.Text = text2
	end

	data2.topLabel.TextColor3 = v2 and color4 or color5
	data2.topLabel.TextTransparency = v2 and 0.35 or 0

	renderHeart(data2, data._favorites[songId] == true) -- inferred equivalent call
end

local function styleScoreButton(data) -- 3 equivalent calls inferred from this helper
	local scoreActive = data.scoreActive
	local scoreHover = data.scoreHover
	data.scoreStroke.Transparency = scoreActive and 0.15 or scoreHover and 0.35 or 0.72
	data.scoreStroke.Color = scoreActive and color5 or color4
	data.scoreButton.TextColor3 = scoreActive and color5 or scoreHover and color3 or color4
	data.scoreButton.TextTransparency = (scoreActive or scoreHover) and 0 or 0.12
end

local function createRow(object, record, i)
	local row = create("Frame", { -- inferred equivalent call
		Name = "Row_" .. record.songId,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 116),
		LayoutOrder = i,
		BorderSizePixel = 0
	}, object._list)

	local rotation = (i * 37 % 11 - 5) / 12

	local willRender = DifficultyBadge.WillRender(record.difficulty)

	create("TextLabel", { -- inferred equivalent call
		Name = "SongName",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(4, 0),
		Size = UDim2.new(1, -(8 + (willRender and 40 or 0)), 0, 46),
		Font = font,
		Text = record.displayName,
		AutoLocalize = false,
		TextSize = 40,
		TextColor3 = color3,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Rotation = rotation
	}, row)

	if willRender then
		local difficultyDot = DifficultyBadge.Create(row, record.difficulty, 0, 26)
		difficultyDot.Name = "DifficultyDot"
		difficultyDot.AnchorPoint = Vector2.new(1, 0.5)
		difficultyDot.Position = UDim2.new(1, -8, 0, 26)
	end

	local parent = create("Frame", { -- inferred equivalent call
		Name = "InfoLine",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(4, 42),
		Size = UDim2.new(0, 590, 0, 32),
		BorderSizePixel = 0
	}, row)

	local infoText = buildInfoText(record)
	local info = create("TextLabel", { -- inferred equivalent call
		Name = "Info",
		BackgroundTransparency = 1,
		Font = font2,
		Text = infoText,
		AutoLocalize = false,
		TextSize = 23,
		TextColor3 = color4,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, 0, 1, 0)
	}, parent)

	local leader = create( -- inferred equivalent call
		"Frame",
		{
			Name = "Leader",
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			BorderSizePixel = 0
		},
		parent
	)

	create("TextLabel", { -- inferred equivalent call
		Name = "Dots",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, -3),
		Size = UDim2.new(0, 1400, 1, 0),
		Font = font2,
		Text = string.rep(". ", 140),
		AutoLocalize = false,
		TextSize = 23,
		TextColor3 = color3,
		TextTransparency = 0.4,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Bottom
	}, leader)
	local countLabel = create("TextLabel", { -- inferred equivalent call
		Name = "FavoriteCount",
		BackgroundTransparency = 1,
		Font = font,
		Text = string.format("%s %s", formatNumber(0), "Favorites"),
		AutoLocalize = false,
		TextSize = 23,
		TextColor3 = color3,
		TextXAlignment = Enum.TextXAlignment.Right
	}, parent)

	local heart = create("TextButton", { -- inferred equivalent call
		Name = "FavoriteButton",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(32, 32),
		Font = SourceSansBold,
		Text = "♥",
		TextSize = 31,
		TextColor3 = color10,
		AutoButtonColor = false
	}, parent)

	local heartStroke = create( -- inferred equivalent call
		"UIStroke",
		{ Color = color3, Thickness = 2.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual },
		heart
	)

	local heartScale = create("UIScale", { Scale = 1 }, heart) -- inferred equivalent call

	local topLabel = create("TextLabel", { -- inferred equivalent call
		Name = "TopScore",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(4, 74),
		Size = UDim2.new(0, 484, 0, 24),
		Font = font2,
		Text = "",
		AutoLocalize = false,
		TextSize = 21,
		TextColor3 = color5,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Rotation = -rotation * 0.6
	}, row)

	local scoreButton = create("TextButton", { -- inferred equivalent call
		Name = "YourScoreButton",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromOffset(592, 75),
		Size = UDim2.fromOffset(94, 22),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = font2,
		Text = "your score",
		TextSize = 18,
		TextColor3 = color4,
		TextTransparency = 0.12
	}, row)

	create("UICorner", { CornerRadius = UDim.new(1, 0) }, scoreButton) -- inferred equivalent call
	local scoreStroke = create("UIStroke", { Color = color4, Thickness = 1, Transparency = 0.72 }, scoreButton) -- inferred equivalent call
	local uiScale = create("UIScale", { Scale = 1 }, scoreButton) -- inferred equivalent call

	local parent2 = create("Frame", { -- inferred equivalent call
		Name = "Divider",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.fromOffset(0, 99),
		Size = UDim2.new(1, 0, 0, 16),
		BorderSizePixel = 0
	}, row)

	create("TextLabel", { -- inferred equivalent call
		Name = "Dashes",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 1600, 1, 0),
		Font = Enum.Font.Code,
		Text = string.rep("- ", 200),
		AutoLocalize = false,
		TextSize = 18,
		TextColor3 = color6,
		TextTransparency = 0.4,
		TextXAlignment = Enum.TextXAlignment.Left
	}, parent2)

	local v2 = {
		songId = record.songId,
		record = record,
		order = i,
		row = row,
		info = info,
		leader = leader,
		countLabel = countLabel,
		topLabel = topLabel,
		heart = heart,
		heartStroke = heartStroke,
		heartScale = heartScale,
		scoreButton = scoreButton,
		scoreStroke = scoreStroke,
		scoreHover = false,
		scoreActive = false,
		infoNaturalWidth = 0
	}

	local font3 = font2
	local size = 23
	local success, result = pcall(function()
		getTextBoundsParams.Text = infoText
		getTextBoundsParams.Font = Font.fromEnum(font3)
		getTextBoundsParams.Size = size
		getTextBoundsParams.Width = 10000
		return TextService:GetTextBoundsAsync(getTextBoundsParams)
	end)
	local v3

	if success and result then
		v3 = result.X
	else
		v3 = #infoText * 23 * 0.55
	end

	v2.infoNaturalWidth = math.ceil(v3) + 6

	layoutInfoLine(v2)

	v2.shown = true
	v2.kids = {}

	for _, guiObject in ipairs(row:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			table.insert(v2.kids, guiObject)
		end
	end

	heart.MouseButton1Click:Connect(function()
		heartScale.Scale = 0.8
		TweenService:Create(heartScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()

		if object._onFavoriteClicked then
			object._onFavoriteClicked(record.songId)
		end
	end)
	heart.MouseEnter:Connect(function()
		object._hoverCount += 1
		TweenService:Create(heartScale, TweenInfo.new(0.12), { Scale = 1.18 }):Play()
	end)
	heart.MouseLeave:Connect(function()
		object._hoverCount = math.max(0, object._hoverCount - 1)
		TweenService:Create(heartScale, TweenInfo.new(0.12), { Scale = 1 }):Play()
	end)

	scoreButton.MouseButton1Click:Connect(function()
		uiScale.Scale = 0.9
		TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
		object:_toggleDropdown(record.songId)
	end)
	scoreButton.MouseEnter:Connect(function()
		object._hoverCount += 1
		v2.scoreHover = true
		styleScoreButton(v2) -- inferred equivalent call
	end)
	scoreButton.MouseLeave:Connect(function()
		object._hoverCount = math.max(0, object._hoverCount - 1)
		v2.scoreHover = false
		styleScoreButton(v2) -- inferred equivalent call
	end)

	object._rows[record.songId] = v2
	refreshRow(object, v2)
end

local function applyDropOrientation(data, p)
	local dropWrap = data._dropWrap
	local drop = data._drop
	local dropShadow = data._dropShadow

	if p == "up" then
		dropWrap.AnchorPoint = Vector2.new(0, 1)
		drop.AnchorPoint = Vector2.new(0, 1)
		drop.Position = UDim2.new(0, 14, 1, -24)
		dropShadow.AnchorPoint = Vector2.new(0, 1)
		dropShadow.Position = UDim2.new(0, 20, 1, -16)
	else
		dropWrap.AnchorPoint = Vector2.new(0, 0)
		drop.AnchorPoint = Vector2.new(0, 0)
		drop.Position = UDim2.fromOffset(14, 18)
		dropShadow.AnchorPoint = Vector2.new(0, 0)
		dropShadow.Position = UDim2.fromOffset(20, 26)
	end
end

local function playTween(object, instance, tweenInfo, goal) -- 8 equivalent calls inferred from this helper
	local tween = TweenService:Create(instance, tweenInfo, goal)
	table.insert(object._dropTweens, tween)
	tween:Play()
	return tween
end

local function setScoreButtonActive(object, dropSongId, scoreActive) -- 3 equivalent calls inferred from this helper
	local v2 = dropSongId and object._rows[dropSongId]

	if v2 then
		v2.scoreActive = scoreActive
		styleScoreButton(v2) -- inferred equivalent call
	end
end

function CatalogBoardUI:_cancelDropTweens()
	for _, v2 in ipairs(self._dropTweens or {}) do
		v2:Cancel()
	end

	self._dropTweens = {}
end

function CatalogBoardUI:_positionDropdown(p)
	local scoreButton = p.scoreButton
	local v2, v3, v4, v5

	if scoreButton.AbsoluteSize.X > 0 then
		local v6 = scoreButton.AbsolutePosition - self._root.AbsolutePosition
		v2 = v6.X
		v3 = v6.Y
		v4 = scoreButton.AbsoluteSize.X
		v5 = scoreButton.AbsoluteSize.Y
	else
		v3 = 166 + (p.order - 1) * 116 + 74 + 1 - self._list.CanvasPosition.Y
		v2 = 578
		v4 = 94
		v5 = 22
	end

	local v6 = math.clamp(v2 + v4 - 420, 8, 272)
	local v7 = v3 + v5 + 8

	local visibleBottom = self._visibleBottom or 960
	local direction

	if visibleBottom < v7 + 376 then
		v7 = v3 - 376 - 8
		direction = "up"
	else
		direction = "down"
	end

	local v8 = math.clamp(v7, 168, (math.max(168, visibleBottom - 376)))

	applyDropOrientation(self, direction)
	local wrapX = v6 - 14
	local wrapY = v8 - 18

	if self._dropSeparate then
		self._dropWrap.Position = direction == "up" and UDim2.fromOffset(0, 418) or UDim2.fromOffset(0, 0)
	else
		self._dropWrap.Position = direction == "up" and UDim2.fromOffset(wrapX, v8 + 376 + 24)
			or UDim2.fromOffset(wrapX, wrapY)
	end

	self._dropRect = {
		X = v6,
		Y = v8,
		W = 420,
		H = 376,
		WrapX = wrapX,
		WrapY = wrapY,
		WrapW = 448,
		WrapH = 418,
		Direction = direction
	}
end

function CatalogBoardUI:_playOpen(p)
	self:_cancelDropTweens()
	local dropWrap = self._dropWrap
	local drop = self._drop
	local dropShadow = self._dropShadow
	local dropScale = self._dropScale
	dropWrap.Visible = true

	if p then
		dropWrap.Size = UDim2.fromOffset(448, 418)
		drop.Rotation = 1
		dropShadow.Rotation = 1
		dropScale.Scale = 1
		dropShadow.BackgroundTransparency = 0.7
	else
		dropWrap.Size = UDim2.fromOffset(448, 0)
		drop.Rotation = 5
		dropScale.Scale = 0.92
		dropShadow.BackgroundTransparency = 1
		playTween(self, dropWrap, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { -- inferred equivalent call
			Size = UDim2.fromOffset(448, 418)
		})
		playTween(self, drop, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { -- inferred equivalent call
			Rotation = 1
		})
		playTween(self, dropScale, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { -- inferred equivalent call
			Scale = 1
		})
		playTween(self, dropShadow, TweenInfo.new(0.35), { BackgroundTransparency = 0.7 }) -- inferred equivalent call
	end
end

function CatalogBoardUI:_playClose(p)
	self:_cancelDropTweens()
	local dropWrap = self._dropWrap
	local drop = self._drop
	local dropShadow = self._dropShadow
	local dropScale = self._dropScale
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local tween = playTween(self, dropWrap, tweenInfo, { Size = UDim2.fromOffset(448, 0) }) -- inferred equivalent call
	playTween(self, drop, tweenInfo, { Rotation = -3 }) -- inferred equivalent call
	playTween(self, dropScale, tweenInfo, { Scale = 0.94 }) -- inferred equivalent call
	playTween(self, dropShadow, TweenInfo.new(0.25), { BackgroundTransparency = 1 }) -- inferred equivalent call
	tween.Completed:Connect(function(p2)
		if p2 == Enum.PlaybackState.Completed and self._dropToken == p and not self._destroyed then
			dropWrap.Visible = false
		end
	end)
end

function CatalogBoardUI:SetViewport(visibleBottom, value)
	self:CloseDropdown(true)
	self._visibleBottom = visibleBottom
	self._listPadding.PaddingBottom = UDim.new(0, value or 30)
	self:_updateVirtual()
end

function CatalogBoardUI:_updateVirtual()
	local list = self._list

	if self._destroyed or not list then
		return
	end

	local y = list.CanvasPosition.Y
	local v2 = y - 232
	local v3 = y + 798 + 232

	for _, row in pairs(self._rows) do
		local v4 = (row.order - 1) * 116
		local v5

		if v2 < v4 + 116 then
			v5 = v4 < v3
		else
			v5 = false
		end

		if row.shown == v5 then
			continue
		end

		row.shown = v5

		for _, kid in ipairs(row.kids) do
			if kid.Parent then
				kid.Visible = v5
			end
		end
	end
end

function CatalogBoardUI:IsInteractiveHovered(): boolean
	return self._hoverCount > 0
end

function CatalogBoardUI:ResetHover()
	self._hoverCount = 0
end

function CatalogBoardUI:IsDropdownOpen(): boolean
	return self._dropSongId ~= nil
end

function CatalogBoardUI:GetDropdownRect()
	return self._dropRect
end

function CatalogBoardUI:CloseDropdown(p)
	local dropSongId = self._dropSongId

	if dropSongId then
		self._dropToken += 1
		local dropToken = self._dropToken
		self._dropSongId = nil
		setScoreButtonActive(self, dropSongId, false) -- inferred equivalent call

		if p then
			self:_cancelDropTweens()
			self._dropWrap.Visible = false
		else
			self:_playClose(dropToken)
		end

		if self._onDropdownClosed then
			pcall(self._onDropdownClosed, p == true)
		end
	elseif p and self._dropWrap and self._dropWrap.Visible then
		self:_cancelDropTweens()
		self._dropWrap.Visible = false
	end
end

function CatalogBoardUI:ShowLeaderboard(dropSongId, p, p2)
	local row = self._rows[dropSongId]

	if not row or self._destroyed then
		return
	end

	local v2 = self._dropSongId == dropSongId and self._dropWrap.Visible

	if self._dropSongId and self._dropSongId ~= dropSongId then
		setScoreButtonActive(self, self._dropSongId, false) -- inferred equivalent call
	end

	self._dropSongId = dropSongId
	self._dropScrollY = self._list.CanvasPosition.Y
	renderDropdown(self, row.record, p)
	setScoreButtonActive(self, dropSongId, true) -- inferred equivalent call

	if v2 then
		return
	end

	self:_positionDropdown(row)
	self:_playOpen(p2)

	if self._onDropdownOpened then
		pcall(self._onDropdownOpened, self._dropRect)
	end
end

function CatalogBoardUI:_toggleDropdown(p)
	if self._dropSongId == p then
		self:CloseDropdown()
		return
	end

	self._dropToken += 1
	local dropToken = self._dropToken
	self:ShowLeaderboard(p, nil)

	if self._onRequestLeaderboard then
		task.spawn(function()
			local success, result = pcall(self._onRequestLeaderboard, p)

			if self._destroyed or self._dropToken ~= dropToken or self._dropSongId ~= p then
				return
			end

			if not success or typeof(result) ~= "table" or not result then
				result = false
			end

			self:ShowLeaderboard(p, result)
		end)
	else
		self:ShowLeaderboard(p, false)
	end
end

function CatalogBoardUI:SetSongs(p)
	self:CloseDropdown(true)
	self._hoverCount = 0

	for _, row in pairs(self._rows) do
		row.row:Destroy()
	end

	self._rows = {}

	local clone = table.clone(p)
	table.sort(clone, function(a, b): boolean
		local displayName = string.lower(a.displayName)
		local displayName2 = string.lower(b.displayName)

		if displayName == displayName2 then
			return a.songId < b.songId
		end

		return displayName < displayName2
	end)

	self._songCountLabel.Text = string.format("%d songs", #clone)

	for i, v2 in ipairs(clone) do
		if self._destroyed then
			return
		end

		createRow(self, v2, i)
	end

	self:_updateVirtual()
end

function CatalogBoardUI:SetStats(p)
	self._counts = p.Favorites or {}
	self._top = p.TopScores or {}

	for _, row in pairs(self._rows) do
		refreshRow(self, row)
	end
end

function CatalogBoardUI:SetMyFavorites(items)
	self._favorites = {}

	for k, item in pairs(items) do
		if item then
			self._favorites[k] = true
		end
	end

	for _, row in pairs(self._rows) do
		renderHeart(row, self._favorites[row.songId] == true) -- inferred equivalent call
	end
end

function CatalogBoardUI:SetFavorite(p, p2)
	self._favorites[p] = p2 and true or nil
	local row = self._rows[p]

	if row then
		renderHeart(row, p2 == true) -- inferred equivalent call
	end
end

function CatalogBoardUI:Destroy()
	self._destroyed = true
	self:_cancelDropTweens()

	if self._root then
		self._root:Destroy()
		self._root = nil
	end

	self._rows = {}
end

return CatalogBoardUI