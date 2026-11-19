local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local NoteBoardUI = {}
NoteBoardUI.__index = NoteBoardUI

local class = {}
class.__index = class

NoteBoardUI.CanvasSize = Vector2.new(700, 990)

NoteBoardUI.MaxLength = 200
NoteBoardUI.MaxReplyLength = 200

NoteBoardUI.Layout = { ListY = 168, ListH = 798, RowH = 150, DefaultScrollPadding = 30 }

local color = Color3.fromRGB(247, 240, 212)
local color2 = Color3.fromRGB(225, 211, 170)
local color3 = Color3.fromRGB(26, 22, 20)
local color4 = Color3.fromRGB(78, 66, 56)
local color5 = Color3.fromRGB(176, 32, 36)
local color6 = Color3.fromRGB(66, 98, 168)
local color7 = Color3.fromRGB(198, 62, 62)
local color8 = Color3.fromRGB(34, 34, 38)
local color9 = Color3.fromRGB(244, 232, 200)

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

local v = {}

for _, v2 in ipairs({ "Kalam", "PatrickHand", "IndieFlower" }) do
	local success, result = pcall(function()
		return Enum.Font[v2]
	end)

	if success and result then
		table.insert(v, result)
	end
end

local v2 = #v == 0 and { Enum.Font.SourceSansSemibold } or v

local v3 = {
	{
		paper = Color3.fromRGB(252, 226, 116),
		shade = Color3.fromRGB(238, 202, 86),
		edge = Color3.fromRGB(190, 152, 48)
	},
	{
		paper = Color3.fromRGB(255, 252, 240),
		shade = Color3.fromRGB(234, 226, 198),
		edge = Color3.fromRGB(120, 92, 52),
		lined = true
	},
	{
		paper = Color3.fromRGB(246, 198, 204),
		shade = Color3.fromRGB(230, 168, 178),
		edge = Color3.fromRGB(160, 84, 96)
	},
	{
		paper = Color3.fromRGB(192, 218, 240),
		shade = Color3.fromRGB(160, 192, 222),
		edge = Color3.fromRGB(70, 100, 150)
	},
	{
		paper = Color3.fromRGB(218, 186, 140),
		shade = Color3.fromRGB(192, 156, 106),
		edge = Color3.fromRGB(110, 78, 40)
	}
}

NoteBoardUI.StyleCount = #v3

local function create(className, items, parent) -- 150 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function makeLabel(parent, items)
	local v4 = {
		BackgroundTransparency = 1,
		Font = font2,
		TextSize = 20,
		TextColor3 = color3,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd
	}

	for k, item in pairs(items) do
		v4[k] = item
	end

	return create("TextLabel", v4, parent) -- inferred equivalent call
end

local function hashString(id) -- 2 equivalent calls inferred from this helper
	local v4 = 5381

	for i = 1, #id do
		v4 = (v4 * 33 + string.byte(id, i)) % 2147483647
	end

	return v4
end

local function makeRng(p) -- 1 equivalent call inferred from this helper
	local v4 = p % 2147483647
	local v5 = v4 <= 0 and 1 or v4

	return function()
		v5 = v5 * 48271 % 2147483647
		return v5 / 2147483647
	end
end

local getTextBoundsParams = Instance.new("GetTextBoundsParams")

local function measureText(text, p, size, width)
	local success, result = pcall(function()
		getTextBoundsParams.Text = text
		getTextBoundsParams.Font = Font.fromEnum(p)
		getTextBoundsParams.Size = size
		getTextBoundsParams.Width = width
		return TextService:GetTextBoundsAsync(getTextBoundsParams)
	end)

	if success and result then
		return result
	end

	local v4 = math.max(1, (math.floor(width / (size * 0.5))))
	local v5 = math.max(1, (math.ceil(#text / v4)))
	return Vector2.new(width, v5 * size * 1.25)
end

local function relativeTime(time)
	local serverTimeNow = Workspace:GetServerTimeNow()
	local v4 = math.max(0, serverTimeNow - (tonumber(time) or serverTimeNow))

	if v4 < 60 then
		return "now"
	end

	if v4 < 3600 then
		return string.format("%dm ago", (math.floor(v4 / 60)))
	end

	if v4 < 86400 then
		return string.format("%dh ago", (math.floor(v4 / 3600)))
	end

	return string.format("%dd ago", (math.floor(v4 / 86400)))
end

local function sortNotes(list)
	table.sort(list, function(a, b): boolean
		if a.Time == b.Time then
			return tostring(a.Id) > tostring(b.Id)
		end

		return (a.Time or 0) > (b.Time or 0)
	end)
end

function NoteBoardUI.new(gui, options)
	local v4 = options or {}
	local object = setmetatable({}, NoteBoardUI)
	object._gui = gui
	object._onWriteClicked = v4.onWriteClicked
	object._onDeleteClicked = v4.onDeleteClicked
	object._localUserId = v4.localUserId
	object._onRequestReplies = v4.onRequestReplies
	object._onReplyClicked = v4.onReplyClicked
	object._onDeleteReply = v4.onDeleteReply
	object._openState = nil
	object._opening = false
	object._scraps = {}
	object._order = {}
	object._queue = {}
	object._running = false
	object._destroyed = false
	object._loaded = false
	object._canModerate = false
	object._hoverCount = 0
	object._contentH = 22
	object._bottomPad = 30

	local root = create( -- inferred equivalent call
		"Frame",
		{
			Name = "NoteBoardRoot",
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
		Size = UDim2.fromOffset(150, 150),
		Position = UDim2.fromOffset(60, 760),
		BorderSizePixel = 0
	}, parent)

	create("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
	create("UIStroke", { Color = Color3.fromRGB(122, 82, 40), Thickness = 8, Transparency = 0.72 }, parent2) -- inferred equivalent call

	local parent3 = create("Frame", { -- inferred equivalent call
		Name = "Stain",
		BackgroundColor3 = Color3.fromRGB(150, 112, 62),
		BackgroundTransparency = 0.88,
		Size = UDim2.fromOffset(58, 58),
		Position = UDim2.fromOffset(560, 330),
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

	for _, v5 in ipairs({ 190, 495, 800 }) do
		local parent4 = create("Frame", { -- inferred equivalent call
			Name = "Hole",
			BackgroundColor3 = Color3.fromRGB(46, 38, 32),
			Size = UDim2.fromOffset(26, 26),
			Position = UDim2.fromOffset(16, v5),
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
		Size = UDim2.fromOffset(300, 84),
		Font = font,
		Text = "Notes:",
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
		Size = UDim2.fromOffset(300, 84),
		Font = font,
		Text = "Notes:",
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
		Size = UDim2.fromOffset(262, 5),
		Rotation = -1.4
	}, parent4)

	create("Frame", { -- inferred equivalent call
		Name = "Scribble2",
		BackgroundColor3 = color3,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(138, 135),
		Size = UDim2.fromOffset(204, 3),
		Rotation = 0.9
	}, parent4)

	object._countLabel = create("TextLabel", { -- inferred equivalent call
		Name = "NoteCount",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -40, 0, 128),
		Size = UDim2.fromOffset(230, 24),
		Font = font2,
		Text = "",
		TextSize = 21,
		TextColor3 = color6,
		TextXAlignment = Enum.TextXAlignment.Right,
		Rotation = -2
	}, parent4)

	local parent5 = create("TextButton", { -- inferred equivalent call
		Name = "WriteButton",
		AutoButtonColor = false,
		Text = "",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -58, 0, 58),
		Size = UDim2.fromOffset(206, 68),
		Rotation = 3
	}, parent4)

	local uiScale = create("UIScale", { Scale = 1 }, parent5) -- inferred equivalent call
	local parent6 = create("Frame", { -- inferred equivalent call
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(4, 5),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1
	}, parent5)

	create("UICorner", { CornerRadius = UDim.new(0, 3) }, parent6) -- inferred equivalent call
	local parent7 = create( -- inferred equivalent call
		"Frame",
		{
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2
		},
		parent5
	)

	create("UICorner", { CornerRadius = UDim.new(0, 3) }, parent7) -- inferred equivalent call
	create("UIGradient", { -- inferred equivalent call
		Rotation = 90,
		Color = ColorSequence.new(v3[1].paper, v3[1].shade)
	}, parent7)

	local uiStroke = create("UIStroke", { Color = v3[1].edge, Thickness = 2, Transparency = 0.35 }, parent7) -- inferred equivalent call
	create("Frame", { -- inferred equivalent call
		Name = "Tape",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, 2),
		Size = UDim2.fromOffset(70, 17),
		BackgroundColor3 = color8,
		BorderSizePixel = 0,
		Rotation = -4,
		ZIndex = 4
	}, parent7)

	create("UITextSizeConstraint", { MaxTextSize = 28, MinTextSize = 12 }, makeLabel(parent7, { -- inferred equivalent call
		Name = "Label",
		Position = UDim2.fromOffset(10, 9),
		Size = UDim2.new(1, -20, 0, 35),
		Font = font,
		Text = "+ Write a note",
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.None,
		ZIndex = 3
	}))
	makeLabel(parent7, {
		Name = "Sub",
		Position = UDim2.fromOffset(10, 43),
		Size = UDim2.new(1, -20, 0, 20),
		Text = "for anyone to read",
		TextSize = 17,
		TextColor3 = color4,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 3
	})

	local flag = false
	parent5.MouseEnter:Connect(function()
		if object:_isBlocked() then
			return
		end

		flag = true
		object._hoverCount += 1
		uiStroke.Transparency = 0.1
		TweenService:Create(uiScale, TweenInfo.new(0.12), { Scale = 1.06 }):Play()
	end)
	parent5.MouseLeave:Connect(function()
		if flag then
			flag = false
			object._hoverCount = math.max(0, object._hoverCount - 1)
		end

		uiStroke.Transparency = 0.35
		TweenService:Create(uiScale, TweenInfo.new(0.12), { Scale = 1 }):Play()
	end)
	parent5.MouseButton1Click:Connect(function()
		if object:_isBlocked() then
			return
		end

		uiScale.Scale = 0.92
		TweenService:Create(uiScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1.06
		}):Play()

		if object._onWriteClicked then
			object._onWriteClicked()
		end
	end)

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
		Name = "NotePile",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(50, 168),
		Size = UDim2.fromOffset(642, 798),
		CanvasSize = UDim2.new(0, 0, 0, 798),
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 7,
		ScrollBarImageColor3 = color3,
		ScrollBarImageTransparency = 0.25,
		ElasticBehavior = Enum.ElasticBehavior.Never,
		ClipsDescendants = true
	}, root)

	object._list = list
	list:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		object:_updateVirtual()
	end)

	local parent8 = create("Frame", { -- inferred equivalent call
		Name = "FadeTop",
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(50, 168),
		Size = UDim2.fromOffset(632, 14),
		Active = false,
		ZIndex = 200
	}, root)

	create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(0, 1) }, parent8) -- inferred equivalent call

	local parent9 = create("Frame", { -- inferred equivalent call
		Name = "FadeBottom",
		BackgroundColor3 = color2,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(50, 940),
		Size = UDim2.fromOffset(632, 26),
		Active = false,
		ZIndex = 200
	}, root)

	create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }, parent9) -- inferred equivalent call

	object._emptyLabel = create("TextLabel", { -- inferred equivalent call
		Name = "EmptyState",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(110, 318),
		Size = UDim2.fromOffset(522, 140),
		Font = font2,
		Text = "pinning up the notes...",
		TextSize = 32,
		TextColor3 = color6,
		TextWrapped = true,
		TextTransparency = 0.1,
		Rotation = -3,
		ZIndex = 150
	}, root)

	return object
end

local function setHover(object, p) -- 8 equivalent calls inferred from this helper
	object._hoverCount = math.max(0, object._hoverCount + p)
end

local function buildScrap(object, note)
	local rng = makeRng(hashString(tostring(note.Id))) -- inferred equivalent call
	local v4 = v3[note.Style] or v3[1]
	local text = tostring(note.Text or "")

	local v5 = math.floor(rng() * 34) + 228
	local useMarker = (utf8.len(text) or #text) <= 34 and rng() < 0.55
	local font3 = useMarker and font or v2[math.floor(rng() * #v2) + 1]
	local textSize = useMarker and 27 or 23
	local rotation = (rng() - 0.5) * 14
	local jx = (rng() - 0.5) * 18
	local jy = (rng() - 0.5) * 10
	local overlap = 2 + rng() * 10
	local rotation2 = (rng() - 0.5) * 1.8
	local v6 = rng()
	local v7 = (rng() - 0.5) * 60
	local rotation3 = (rng() - 0.5) * 18
	local v8 = math.floor(rng() * 10) + 1

	local v9 = v4.lined and 32 or 16
	local width = v5 - v9 - 14
	local v10 = math.ceil(measureText(text, font3, textSize, width).Y) + 4
	local v11 = v10 + 24 + 6 + 20 + 14

	local wrapper = create("TextButton", { -- inferred equivalent call
		Name = "Note_" .. tostring(note.Id),
		AutoButtonColor = false,
		Text = "",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(v5, v11),
		Rotation = rotation,
		ZIndex = v8
	}, object._list)
	local scale = create("UIScale", { Scale = 1 }, wrapper) -- inferred equivalent call

	local parent = create("Frame", { -- inferred equivalent call
		Name = "Shadow",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(4, 5),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1
	}, wrapper)

	create("UICorner", { CornerRadius = UDim.new(0, 3) }, parent) -- inferred equivalent call

	local parent2 = create("Frame", { -- inferred equivalent call
		Name = "ScrapPaper",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2
	}, wrapper)

	create("UICorner", { CornerRadius = UDim.new(0, 3) }, parent2) -- inferred equivalent call
	create("UIStroke", { Color = v4.edge, Thickness = 1.5, Transparency = 0.45 }, parent2) -- inferred equivalent call
	create("UIGradient", { -- inferred equivalent call
		Rotation = 90,
		Color = ColorSequence.new(v4.paper, v4.shade)
	}, parent2)

	if v4.lined then
		create("Frame", { -- inferred equivalent call
			Name = "Margin",
			BackgroundColor3 = color7,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(24, 0),
			Size = UDim2.new(0, 2, 1, 0),
			ZIndex = 2
		}, parent2)

		for _, v12 in ipairs({ 0.3, 0.72 }) do
			local parent3 = create("Frame", { -- inferred equivalent call
				Name = "Hole",
				BackgroundColor3 = Color3.fromRGB(46, 38, 32),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 7, v12, 0),
				Size = UDim2.fromOffset(10, 10),
				BorderSizePixel = 0,
				ZIndex = 2
			}, parent2)

			create("UICorner", { CornerRadius = UDim.new(1, 0) }, parent3) -- inferred equivalent call
		end
	end

	if v6 < 0.55 then
		create("Frame", { -- inferred equivalent call
			Name = "Tape",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, v7 * 0.5, 0, 2),
			Size = UDim2.fromOffset(62, 16),
			BackgroundColor3 = color8,
			BackgroundTransparency = 0.04,
			BorderSizePixel = 0,
			Rotation = rotation3,
			ZIndex = 4
		}, parent2)
	elseif v6 < 0.8 then
		local parent3 = create("Frame", { -- inferred equivalent call
			Name = "Pin",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, v7, 0, 8),
			Size = UDim2.fromOffset(18, 18),
			BackgroundColor3 = Color3.fromRGB(190, 38, 44),
			BorderSizePixel = 0,
			ZIndex = 4
		}, parent2)

		create("UICorner", { CornerRadius = UDim.new(1, 0) }, parent3) -- inferred equivalent call
		create("UIStroke", { -- inferred equivalent call
			Color = Color3.fromRGB(70, 10, 16),
			Thickness = 1.5,
			Transparency = 0.2
		}, parent3)
		local parent4 = create("Frame", { -- inferred equivalent call
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.45,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(4, 3),
			Size = UDim2.fromOffset(6, 6),
			ZIndex = 5
		}, parent3)

		create("UICorner", { CornerRadius = UDim.new(1, 0) }, parent4) -- inferred equivalent call
	end

	makeLabel(parent2, {
		Name = "Text",
		Position = UDim2.fromOffset(v9, 24),
		Size = UDim2.fromOffset(width, v10),
		Font = font3,
		Text = text,
		TextSize = textSize,
		TextColor3 = color3,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextTruncate = Enum.TextTruncate.None,
		Rotation = rotation2,
		ZIndex = 3
	})
	local v12

	if object._localUserId == nil then
		v12 = false
	else
		v12 = note.UserId == object._localUserId
	end

	local v13 = v10 + 24 + 6
	makeLabel(parent2, {
		Name = "Author",
		Position = UDim2.fromOffset(v9, v13),
		Size = UDim2.fromOffset(width - 66 - 4, 20),
		Font = v2[1],
		Text = "- " .. tostring(note.Name or "?") .. (v12 and " (you)" or ""),
		TextSize = 17,
		TextColor3 = color4,
		ZIndex = 3
	})

	local label = makeLabel(parent2, {
		AutoLocalize = false,
		Name = "Time",
		Position = UDim2.fromOffset(v5 - 14 - 66, v13 + 1),
		Size = UDim2.fromOffset(66, 20),
		Font = v2[1],
		Text = relativeTime(note.Time),
		TextSize = 15,
		TextColor3 = color4,
		TextTransparency = 0.25,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 3
	})

	if v12 or object._canModerate then
		local parent3 = create("TextButton", { -- inferred equivalent call
			Name = "TearOff",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, -6, 0, 8),
			Size = UDim2.fromOffset(26, 26),
			BackgroundColor3 = color7,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Enum.Font.GothamBlack,
			Text = "X",
			TextSize = 15,
			TextColor3 = color9,
			Rotation = 6,
			ZIndex = 8
		}, parent2)

		create("UICorner", { CornerRadius = UDim.new(0, 3) }, parent3) -- inferred equivalent call
		create("UIStroke", { Color = color3, Thickness = 1.5 }, parent3) -- inferred equivalent call
		local uiScale = create("UIScale", { Scale = 1 }, parent3) -- inferred equivalent call
		local flag = false
		parent3.MouseEnter:Connect(function()
			if object:_isBlocked() then
				return
			end

			flag = true
			setHover(object, 1) -- inferred equivalent call
			TweenService:Create(uiScale, TweenInfo.new(0.12), { Scale = 1.15 }):Play()
		end)
		parent3.MouseLeave:Connect(function()
			if flag then
				flag = false
				setHover(object, -1) -- inferred equivalent call
			end

			TweenService:Create(uiScale, TweenInfo.new(0.12), { Scale = 1 }):Play()
		end)
		parent3.MouseButton1Click:Connect(function()
			if object:_isBlocked() then
				return
			end

			uiScale.Scale = 0.85
			TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Scale = 1
			}):Play()

			if object._onDeleteClicked then
				object:_confirmDelete({
					title = "Tear it off?",
					preview = tostring(note.Text or ""),
					author = tostring(note.Name or "?"),
					noteId = note.Id,
					onConfirm = function()
						if object._onDeleteClicked then
							object._onDeleteClicked(note.Id)
						end
					end
				})
			end
		end)
	end

	local replyCount = tonumber(note.ReplyCount) or 0
	local badge = create("Frame", { -- inferred equivalent call
		Name = "ReplyBadge",
		Position = UDim2.fromOffset(6, 2),
		Size = UDim2.fromOffset(44, 20),
		BackgroundColor3 = color6,
		BorderSizePixel = 0,
		Rotation = -5,
		Visible = replyCount > 0,
		ZIndex = 6
	}, parent2)

	create("UICorner", { CornerRadius = UDim.new(0, 10) }, badge) -- inferred equivalent call
	create("UIStroke", { Color = Color3.fromRGB(28, 40, 90), Thickness = 1.5, Transparency = 0.2 }, badge) -- inferred equivalent call
	local label2 = makeLabel(badge, {
		Name = "Count",
		Size = UDim2.fromScale(1, 1),
		Font = font,
		Text = "re:" .. tostring(replyCount),
		TextSize = 14,
		TextColor3 = color9,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 7
	})

	wrapper.MouseButton1Click:Connect(function()
		if object:_isBlocked() then
			return
		end

		object:OpenNote(note.Id)
	end)

	wrapper.MouseEnter:Connect(function()
		if object:_isBlocked() then
			return
		end

		wrapper.ZIndex = 60
		TweenService:Create(scale, TweenInfo.new(0.12), { Scale = 1.05 }):Play()
	end)
	wrapper.MouseLeave:Connect(function()
		wrapper.ZIndex = v8
		TweenService:Create(scale, TweenInfo.new(0.12), { Scale = 1 }):Play()
	end)

	return {
		id = note.Id,
		note = note,
		wrapper = wrapper,
		baseZ = v8,
		scale = scale,
		timeLabel = label,
		badge = badge,
		badgeText = label2,
		font = font3,
		useMarker = useMarker,
		w = v5,
		h = v11,
		jx = jx,
		jy = jy,
		overlap = overlap,
		placed = false
	}
end

function NoteBoardUI:_applyCanvas()
	local v4 = math.max(798, self._contentH + self._bottomPad)
	self._list.CanvasSize = UDim2.new(0, 0, 0, v4)
end

function NoteBoardUI:_layout(p, p2)
	local v4 = { 22, 52 }

	for _, v5 in ipairs(self._order) do
		local v6 = v4[1] <= v4[2] and 1 or 2
		local v7 = 30 + (v6 - 1) * 297 + (297 - v5.w) / 2 + v5.jx
		local v8 = v4[v6] + v5.jy
		v4[v6] = v4[v6] + v5.h - v5.overlap

		v5.posY = math.floor(v8)
		local udim = UDim2.fromOffset(math.floor(v7), (math.floor(v8)))

		if p and v5 ~= p2 and v5.placed then
			TweenService:Create(v5.wrapper, TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = udim
			}):Play()
		else
			v5.wrapper.Position = udim
		end

		v5.placed = true
	end

	self._contentH = math.max(v4[1], v4[2]) + 16
	self:_applyCanvas()
	self:_updateVirtual()
end

function NoteBoardUI:_updateVirtual()
	if self._destroyed or not self._list then
		return
	end

	local y = self._list.CanvasPosition.Y
	local v4 = y - 320
	local v5 = y + 798 + 320

	for _, scrap in pairs(self._scraps) do
		local posY = scrap.posY

		if not (posY and scrap.wrapper.Parent) then
			continue
		end

		local v6

		if v4 < posY + scrap.h then
			v6 = posY < v5
		else
			v6 = false
		end

		if scrap.shown == nil then
			scrap.shown = true
		end

		if scrap.shown == v6 then
			continue
		end

		scrap.shown = v6

		if not v6 then
			scrap.wrapper.ZIndex = scrap.baseZ
			scrap.scale.Scale = 1
		end

		scrap.wrapper.Visible = v6
	end
end

function NoteBoardUI:_refreshStatus()
	local count = #self._order

	if count == 0 then
		self._countLabel.Text = ""
	else
		self._countLabel.Text = string.format(
			"%d %s%s",
			count,
			count == 1 and "note" or "notes",
			count > 0 and ", tap one to open" or ""
		)
	end

	if self._loaded then
		if count ~= 0 then
			self._emptyLabel.Visible = false

			return
		end

		self._emptyLabel.Visible = true
		self._emptyLabel.Text = "nothing here yet. Be the first to stick a note!"
	else
		self._emptyLabel.Visible = true
		self._emptyLabel.Text = "pinning up the notes..."
	end
end

function NoteBoardUI:_enqueue(p)
	table.insert(self._queue, p)

	if self._running then
		return
	end

	self._running = true
	task.spawn(function()
		while #self._queue > 0 and not self._destroyed do
			local success, result = pcall((table.remove(self._queue, 1)))

			if not success then
				warn("[NoteBoardUI] " .. tostring(result))
			end
		end

		self._running = false
	end)
end

local function insertSorted(order, scrap)
	for i, item in ipairs(order) do
		local note = scrap.note
		local note2 = item.note
		local v4

		if (note.Time or 0) > (note2.Time or 0) then
			v4 = true
		elseif (note.Time or 0) == (note2.Time or 0) then
			v4 = tostring(note.Id) > tostring(note2.Id)
		else
			v4 = false
		end

		if v4 then
			table.insert(order, i, scrap)
			return
		end
	end

	table.insert(order, scrap)
end

function NoteBoardUI:SetNotes(options, p)
	local clone = table.clone(options or {})
	self:_enqueue(function()
		self._canModerate = p == true
		self._hoverCount = 0

		for _, scrap in pairs(self._scraps) do
			scrap.wrapper:Destroy()
		end

		self._scraps = {}
		self._order = {}
		table.sort(clone, function(a, b): boolean
			if a.Time == b.Time then
				return tostring(a.Id) > tostring(b.Id)
			end

			return (a.Time or 0) > (b.Time or 0)
		end)

		for _, v4 in ipairs(clone) do
			if self._destroyed then
				return
			end

			if self._scraps[v4.Id] then
				continue
			end

			local scrap = buildScrap(self, v4)
			self._scraps[v4.Id] = scrap
			table.insert(self._order, scrap)
		end

		self._loaded = true
		self:_layout(false)
		self:_refreshStatus()

		if self._openState and not self._scraps[self._openState.noteId] then
			self:CloseNote(true)
		end
	end)
end

function NoteBoardUI:AddNote(p, p2)
	self:_enqueue(function()
		if self._scraps[p.Id] then
			return
		end

		local scrap = buildScrap(self, p)

		if self._destroyed then
			scrap.wrapper:Destroy()
			return
		end

		self._scraps[p.Id] = scrap
		insertSorted(self._order, scrap)
		self._loaded = true
		self:_layout(p2 == true, scrap)
		self:_refreshStatus()

		if p2 then
			local position = scrap.wrapper.Position
			local rotation = scrap.wrapper.Rotation
			scrap.wrapper.Position = position - UDim2.fromOffset(0, 70)
			scrap.wrapper.Rotation = rotation + (rotation >= 0 and 16 or -16)
			scrap.scale.Scale = 0.3
			local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			TweenService:Create(scrap.wrapper, tweenInfo, {
				Position = position,
				Rotation = rotation
			}):Play()
			TweenService:Create(scrap.scale, tweenInfo, { Scale = 1 }):Play()
		end
	end)
end

function NoteBoardUI:RemoveNote(p)
	self:_enqueue(function()
		local scrap = self._scraps[p]

		if not scrap then
			return
		end

		self._scraps[p] = nil

		if self._confirm and self._confirm.noteId == p then
			self:_closeConfirm(true)
		end

		if self._openState and self._openState.noteId == p then
			self:CloseNote()
		end

		for i, v4 in ipairs(self._order) do
			if v4 == scrap then
				table.remove(self._order, i)
				break
			end
		end

		self._hoverCount = 0

		local tweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		TweenService:Create(scrap.scale, tweenInfo, { Scale = 0 }):Play()
		TweenService:Create(scrap.wrapper, tweenInfo, {
			Rotation = scrap.wrapper.Rotation + 24
		}):Play()
		task.delay(0.3, function()
			scrap.wrapper:Destroy()
		end)

		self:_layout(true)
		self:_refreshStatus()
	end)
end

function NoteBoardUI:ScrollToTop()
	if self._list then
		self._list.CanvasPosition = Vector2.new(0, 0)
	end
end

function NoteBoardUI:RefreshTimes()
	for _, scrap in pairs(self._scraps) do
		scrap.timeLabel.Text = relativeTime(scrap.note.Time)
	end
end

function NoteBoardUI:SetViewport(_, value)
	self._bottomPad = value or 30
	self:_applyCanvas()
end

function NoteBoardUI:IsInteractiveHovered(): boolean
	return self._hoverCount > 0
end

function NoteBoardUI:ResetHover()
	self._hoverCount = 0
end

function NoteBoardUI:Destroy()
	self:_closeConfirm(true)
	self:CloseNote(true)
	self._destroyed = true
	self._queue = {}

	if self._root then
		self._root:Destroy()
		self._root = nil
	end

	self._scraps = {}
	self._order = {}
end

local function addDashes(parent, size, value)
	local frame = Instance.new("Frame")

	for k, v4 in pairs({
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		BorderSizePixel = 0,
		Size = size,
		LayoutOrder = value or 0,
		ZIndex = 3
	}) do
		frame[k] = v4
	end

	frame.Parent = parent

	create("TextLabel", { -- inferred equivalent call
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 1400, 1, 0),
		Font = Enum.Font.Code,
		Text = string.rep("- ", 160),
		TextSize = 18,
		TextColor3 = color6,
		TextTransparency = 0.4,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3
	}, frame)

	return frame
end

local function makeSticker(object, parent, items)
	local v4 = {
		BackgroundColor3 = color7,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBlack,
		Text = "X",
		TextColor3 = color9
	}

	for k, item in pairs(items) do
		v4[k] = item
	end

	local sticker = create("TextButton", v4, parent) -- inferred equivalent call
	create("UICorner", { CornerRadius = UDim.new(0, 3) }, sticker) -- inferred equivalent call
	create("UIStroke", { Color = color3, Thickness = 1.5 }, sticker) -- inferred equivalent call
	local uiScale = create("UIScale", { Scale = 1 }, sticker) -- inferred equivalent call
	local flag = false
	sticker.MouseEnter:Connect(function()
		if object:_isForeBlocked() then
			return
		end

		flag = true
		setHover(object, 1) -- inferred equivalent call
		TweenService:Create(uiScale, TweenInfo.new(0.12), { Scale = 1.15 }):Play()
	end)
	sticker.MouseLeave:Connect(function()
		if flag then
			flag = false
			setHover(object, -1) -- inferred equivalent call
		end

		TweenService:Create(uiScale, TweenInfo.new(0.12), { Scale = 1 }):Play()
	end)
	sticker.MouseButton1Down:Connect(function()
		uiScale.Scale = 0.85
		TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
	end)
	return sticker
end

local function buildReplyEntry(object, data, data2, order)
	local v4

	if object._localUserId == nil then
		v4 = false
	else
		v4 = data2.UserId == object._localUserId
	end

	local v5 = object._localUserId ~= nil and data.note.UserId == object._localUserId
	local v6 = v4 or v5 or object._canModerate

	local replyEntry = create("Frame", { -- inferred equivalent call
		Name = "Reply_" .. tostring(data2.Id),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -4, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order
	}, data.list)
	create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 1) }, replyEntry) -- inferred equivalent call

	local parent = create("Frame", { -- inferred equivalent call
		Name = "Head",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 26),
		LayoutOrder = 1
	}, replyEntry)

	makeLabel(parent, {
		Name = "Author",
		Size = UDim2.new(1, -130, 1, 0),
		Font = font,
		Text = tostring(data2.Name or "?") .. (v4 and " (you)" or ""),
		TextSize = 20,
		TextColor3 = color5
	})

	makeLabel(parent, {
		Name = "Time",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, v6 and -34 or -6, 0, 3),
		Size = UDim2.fromOffset(90, 20),
		Text = relativeTime(data2.Time),
		TextSize = 16,
		TextColor3 = color4,
		TextTransparency = 0.25,
		TextXAlignment = Enum.TextXAlignment.Right
	})

	if v6 then
		makeSticker(object, parent, {
			Name = "TearOff",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -4, 0.5, 0),
			Size = UDim2.fromOffset(22, 22),
			TextSize = 13,
			Rotation = 5,
			ZIndex = 5
		}).MouseButton1Click:Connect(function()
			if object:_isForeBlocked() then
				return
			end

			if object._onDeleteReply then
				object:_confirmDelete({
					title = "Tear it off?",
					preview = tostring(data2.Text or ""),
					author = tostring(data2.Name or "?"),
					noteId = data.noteId,
					replyId = data2.Id,
					onConfirm = function()
						if object._onDeleteReply then
							object._onDeleteReply(data.noteId, data2.Id)
						end
					end
				})
			end
		end)
	end

	create("TextLabel", { -- inferred equivalent call
		Name = "Body",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -8, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = font2,
		Text = tostring(data2.Text or ""),
		TextSize = 23,
		TextColor3 = color3,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		LayoutOrder = 2
	}, replyEntry)

	addDashes(replyEntry, UDim2.new(1, 0, 0, 16), 3)
	return replyEntry
end

function NoteBoardUI:_refreshOpenState(data)
	if not data.countLabel.Parent then
		return
	end

	local shown = data.replies ~= nil and data.shown or tonumber(data.note.ReplyCount) or 0
	data.countLabel.Text = string.format("(%d)", shown)

	if data.failed then
		data.stateLabel.Visible = true
		data.stateLabel.Text = "couldn't open the replies. Close this note and try again."
	elseif data.replies == nil then
		data.stateLabel.Visible = true
		data.stateLabel.Text = "flipping through the replies..."
	else
		if data.shown ~= 0 then
			data.stateLabel.Visible = false

			return
		end

		data.stateLabel.Visible = true
		data.stateLabel.Text = "no replies yet. Say something!"
	end
end

function NoteBoardUI:_addReplyEntry(state, p)
	if state.entries[p.Id] then
		return
	end

	state.order += 1
	state.shown += 1
	state.entries[p.Id] = buildReplyEntry(self, state, p, state.order)
end

local function scrapCenter(p, p2) -- 3 equivalent calls inferred from this helper
	if p2 and p2.wrapper.Parent and p._root and p2.wrapper.AbsoluteSize.X > 0 and p._root.AbsoluteSize.X > 0 then
		return p2.wrapper.AbsolutePosition + p2.wrapper.AbsoluteSize / 2 - p._root.AbsolutePosition
	end

	return nil
end

function NoteBoardUI:_buildOpen(data)
	local note = data.note
	local v4 = v3[note.Style] or v3[1]
	local textSize = data.useMarker and 38 or 31

	local v5 = measureText(tostring(note.Text or ""), data.font, textSize, 532)

	if self._destroyed or not self._root or self._openState then
		return
	end

	local v6 = math.ceil(v5.Y) + 6

	local v7 = v6 + 44 + 8
	local v8 = v7 + 36
	local v9 = v8 + 22
	local v10 = v9 + 52
	local v11 = 750 - v10
	local rotation = (hashString(tostring(note.Id)) % 30 - 15) / 10 -- inferred equivalent call
	local v12

	if self._localUserId == nil then
		v12 = false
	else
		v12 = note.UserId == self._localUserId
	end

	local openState = {
		noteId = note.Id,
		note = note,
		entries = {},
		order = 0,
		shown = 0,
		replies = nil,
		failed = false
	}

	local dim = create("TextButton", { -- inferred equivalent call
		Name = "OpenDim",
		AutoButtonColor = false,
		Text = "",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 300
	}, self._root)
	create("UICorner", { CornerRadius = UDim.new(0, 10) }, dim) -- inferred equivalent call
	dim.MouseButton1Click:Connect(function()
		self:CloseNote()
	end)
	TweenService:Create(dim, TweenInfo.new(0.3), { BackgroundTransparency = 0.45 }):Play()

	local v13 = scrapCenter(self, data) or Vector2.new(350, 495) -- inferred equivalent call
	local holder = create("Frame", { -- inferred equivalent call
		Name = "OpenNote",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(v13.X, v13.Y),
		Size = UDim2.fromOffset(600, 850),
		Rotation = data.wrapper.Rotation,
		ZIndex = 301
	}, self._root)
	local scale = create("UIScale", { Scale = 0.3 }, holder) -- inferred equivalent call
	openState.holder = holder
	openState.dim = dim
	openState.scale = scale

	local parent = create("Frame", { -- inferred equivalent call
		Name = "Shadow",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.65,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(9, 11),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1
	}, holder)

	create("UICorner", { CornerRadius = UDim.new(0, 5) }, parent) -- inferred equivalent call

	local parent2 = create("TextButton", { -- inferred equivalent call
		Name = "Card",
		AutoButtonColor = false,
		Text = "",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2
	}, holder)

	create("UICorner", { CornerRadius = UDim.new(0, 5) }, parent2) -- inferred equivalent call
	create("UIStroke", { Color = v4.edge, Thickness = 2.5, Transparency = 0.35 }, parent2) -- inferred equivalent call
	create("UIGradient", { -- inferred equivalent call
		Rotation = 90,
		Color = ColorSequence.new(v4.paper, v4.shade)
	}, parent2)

	if v4.lined then
		create("Frame", { -- inferred equivalent call
			Name = "Margin",
			BackgroundColor3 = color7,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(22, 0),
			Size = UDim2.new(0, 2, 1, 0)
		}, parent2)
	end

	create("Frame", { -- inferred equivalent call
		Name = "Tape",
		BackgroundColor3 = color8,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(238, -13),
		Size = UDim2.fromOffset(124, 28),
		Rotation = -3,
		ZIndex = 8
	}, parent2)

	makeLabel(parent2, {
		Name = "Text",
		Position = UDim2.fromOffset(34, 44),
		Size = UDim2.fromOffset(532, v6),
		Font = data.font,
		Text = tostring(note.Text or ""),
		TextSize = textSize,
		TextColor3 = color3,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextTruncate = Enum.TextTruncate.None,
		ZIndex = 3
	})

	makeLabel(parent2, {
		Name = "Author",
		Position = UDim2.fromOffset(34, v7),
		Size = UDim2.fromOffset(402, 28),
		Font = v2[1],
		Text = "- " .. tostring(note.Name or "?") .. (v12 and " (you)" or ""),
		TextSize = 24,
		TextColor3 = color4,
		ZIndex = 3
	})

	makeLabel(parent2, {
		Name = "Time",
		Position = UDim2.fromOffset(446, v7 + 4),
		Size = UDim2.fromOffset(120, 22),
		Font = v2[1],
		Text = relativeTime(note.Time),
		TextSize = 18,
		TextColor3 = color4,
		TextTransparency = 0.2,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 3
	})

	local addDashes_2 = addDashes(parent2, UDim2.fromOffset(532, 16))
	addDashes_2.Position = UDim2.fromOffset(34, v8)

	makeLabel(parent2, {
		Name = "RepliesShadow",
		Position = UDim2.fromOffset(37, v9 + 3),
		Size = UDim2.fromOffset(170, 44),
		Font = font,
		Text = "Replies",
		TextSize = 34,
		TextColor3 = color5,
		TextTransparency = 0.12,
		ZIndex = 3
	})

	makeLabel(parent2, {
		Name = "Replies",
		Position = UDim2.fromOffset(34, v9),
		Size = UDim2.fromOffset(170, 44),
		Font = font,
		Text = "Replies",
		TextSize = 34,
		ZIndex = 4
	})

	openState.countLabel = makeLabel(parent2, {
		Name = "ReplyCount",
		Position = UDim2.fromOffset(184, v9 + 10),
		Size = UDim2.fromOffset(80, 28),
		Text = "(0)",
		TextSize = 24,
		TextColor3 = color6,
		ZIndex = 3
	})

	create("Frame", { -- inferred equivalent call
		Name = "Underline",
		BackgroundColor3 = color5,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(34, v9 + 44),
		Size = UDim2.fromOffset(150, 4),
		Rotation = -1.2,
		ZIndex = 3
	}, parent2)

	local list = create("ScrollingFrame", { -- inferred equivalent call
		Name = "ReplyList",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(28, v10),
		Size = UDim2.fromOffset(544, v11),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = color3,
		ScrollBarImageTransparency = 0.25,
		ElasticBehavior = Enum.ElasticBehavior.Never,
		ClipsDescendants = true,
		ZIndex = 3
	}, parent2)

	create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }, list) -- inferred equivalent call
	create( -- inferred equivalent call
		"UIPadding",
		{
			PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 8)
		},
		list
	)
	openState.list = list

	openState.stateLabel = makeLabel(parent2, {
		Name = "StateLabel",
		Position = UDim2.fromOffset(34, v10 + 12),
		Size = UDim2.fromOffset(532, 70),
		Text = "flipping through the replies...",
		TextSize = 26,
		TextColor3 = color6,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.None,
		TextYAlignment = Enum.TextYAlignment.Top,
		Rotation = -1.5,
		ZIndex = 3
	})

	makeSticker(self, parent2, {
		Name = "CloseButton",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 12),
		Size = UDim2.fromOffset(38, 38),
		TextSize = 21,
		Rotation = 4,
		ZIndex = 9
	}).MouseButton1Click:Connect(function()
		if self:_isForeBlocked() then
			return
		end

		self:CloseNote()
	end)

	local parent3 = create("TextButton", { -- inferred equivalent call
		Name = "ReplyButton",
		AutoButtonColor = false,
		Text = "",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -28, 1, -22),
		Size = UDim2.fromOffset(200, 62),
		Rotation = -2,
		ZIndex = 9
	}, parent2)

	local uiScale = create("UIScale", { Scale = 1 }, parent3) -- inferred equivalent call
	local parent4 = create("Frame", { -- inferred equivalent call
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(4, 5),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1
	}, parent3)

	create("UICorner", { CornerRadius = UDim.new(0, 3) }, parent4) -- inferred equivalent call
	local parent5 = create( -- inferred equivalent call
		"Frame",
		{
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2
		},
		parent3
	)

	create("UICorner", { CornerRadius = UDim.new(0, 3) }, parent5) -- inferred equivalent call
	create("UIGradient", { -- inferred equivalent call
		Rotation = 90,
		Color = ColorSequence.new(v3[1].paper, v3[1].shade)
	}, parent5)

	local uiStroke = create("UIStroke", { Color = v3[1].edge, Thickness = 2, Transparency = 0.35 }, parent5) -- inferred equivalent call
	create("Frame", { -- inferred equivalent call
		Name = "Tape",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, 2),
		Size = UDim2.fromOffset(64, 16),
		BackgroundColor3 = color8,
		BorderSizePixel = 0,
		Rotation = 4,
		ZIndex = 4
	}, parent5)

	makeLabel(parent5, {
		Name = "Label",
		Position = UDim2.fromOffset(8, 12),
		Size = UDim2.new(1, -16, 1, -18),
		Font = font,
		Text = "+ Reply",
		TextSize = 30,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.None,
		ZIndex = 3
	})

	local flag = false
	parent3.MouseEnter:Connect(function()
		if self:_isForeBlocked() then
			return
		end

		flag = true
		setHover(self, 1) -- inferred equivalent call
		uiStroke.Transparency = 0.1
		TweenService:Create(uiScale, TweenInfo.new(0.12), { Scale = 1.06 }):Play()
	end)
	parent3.MouseLeave:Connect(function()
		if flag then
			flag = false
			setHover(self, -1) -- inferred equivalent call
		end

		uiStroke.Transparency = 0.35
		TweenService:Create(uiScale, TweenInfo.new(0.12), { Scale = 1 }):Play()
	end)
	parent3.MouseButton1Click:Connect(function()
		if self:_isForeBlocked() then
			return
		end

		uiScale.Scale = 0.92
		TweenService:Create(uiScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1.06
		}):Play()

		if self._onReplyClicked then
			self._onReplyClicked(note)
		end
	end)

	makeLabel(parent2, {
		Name = "CloseHint",
		Position = UDim2.fromOffset(34, 798),
		Size = UDim2.fromOffset(250, 24),
		Text = "tap outside to close",
		TextSize = 18,
		TextColor3 = color6,
		TextTransparency = 0.25,
		ZIndex = 3
	})

	self._openState = openState
	self:_applyInputBlock()

	for _, scrap in pairs(self._scraps) do
		if scrap.baseZ then
			scrap.wrapper.ZIndex = scrap.baseZ
		end

		scrap.scale.Scale = 1
	end

	self:_refreshOpenState(openState)

	local tweenInfo = TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	TweenService:Create(holder, tweenInfo, {
		Position = UDim2.fromOffset(350, 501),
		Rotation = rotation
	}):Play()
	TweenService:Create(scale, tweenInfo, { Scale = 1 }):Play()

	task.delay(0.46, function()
		self:_hideCoveredScraps(openState)
	end)

	task.spawn(function()
		local replies = nil

		if self._onRequestReplies then
			local success, result = pcall(self._onRequestReplies, note.Id)

			if success and typeof(result) == "table" then
				replies = result
			end
		end

		if self._openState ~= openState or self._destroyed then
			return
		end

		if replies then
			table.sort(replies, function(a, b): boolean
				if a.Time == b.Time then
					return tostring(a.Id) < tostring(b.Id)
				end

				return (a.Time or 0) < (b.Time or 0)
			end)

			openState.replies = replies

			for _, v14 in ipairs(replies) do
				self:_addReplyEntry(openState, v14)
			end
		else
			openState.failed = true
		end

		self:_refreshOpenState(openState)
	end)
end

function NoteBoardUI:OpenNote(p)
	if self._destroyed or self._opening then
		return
	end

	local scrap = self._scraps[p]

	if not scrap then
		return
	end

	if self._openState then
		if self._openState.noteId == p then
			return
		end

		self:CloseNote(true)
	end

	self._opening = true
	self:_applyInputBlock()
	task.spawn(function()
		local success, result = pcall(function()
			self:_buildOpen(scrap)
		end)
		self._opening = false

		if not self._destroyed then
			self:_applyInputBlock()
		end

		if not success then
			warn("[NoteBoardUI] open note: " .. tostring(result))
		end
	end)
end

function NoteBoardUI:CloseNote(p)
	local openState = self._openState

	if not openState then
		return
	end

	self._openState = nil
	self._hoverCount = 0
	self:_applyInputBlock()

	if openState.hiddenScraps then
		for _, hiddenScrap in ipairs(openState.hiddenScraps) do
			if hiddenScrap.Parent then
				hiddenScrap.Visible = true
			end
		end

		openState.hiddenScraps = nil
	end

	local holder = openState.holder
	local dim = openState.dim

	if p or not holder.Parent then
		holder:Destroy()
		dim:Destroy()
	else
		local tweenInfo = TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		local v4 = {
			Rotation = holder.Rotation + 4
		}
		local v5 = scrapCenter(self, self._scraps[openState.noteId]) -- inferred equivalent call

		if v5 then
			v4.Position = UDim2.fromOffset(v5.X, v5.Y)
		end

		TweenService:Create(holder, tweenInfo, v4):Play()
		TweenService:Create(openState.scale, tweenInfo, { Scale = 0.3 }):Play()
		TweenService:Create(dim, TweenInfo.new(0.24), { BackgroundTransparency = 1 }):Play()
		task.delay(0.28, function()
			holder:Destroy()
			dim:Destroy()
		end)
	end
end

function NoteBoardUI:_hideCoveredScraps(p)
	if self._destroyed or self._openState ~= p or not self._root then
		return
	end

	local v4 = self._root.AbsoluteSize.X / 700

	if v4 <= 0 then
		return
	end

	local v5 = 74 * v4
	local v6 = 626 * v4
	local v7 = 100 * v4
	local v8 = 902 * v4
	local v9 = 16 * v4

	local wrappers = {}

	for _, scrap in pairs(self._scraps) do
		local wrapper = scrap.wrapper

		if not (wrapper.Parent and wrapper.Visible) then
			continue
		end

		local v10 = scrapCenter(self, scrap) -- inferred equivalent call

		if not v10 then
			continue
		end

		local rotation = math.rad(wrapper.Rotation)
		local v11 = math.abs((math.cos(rotation)))
		local v12 = math.abs((math.sin(rotation)))
		local absoluteSize = wrapper.AbsoluteSize
		local v13 = (v11 * absoluteSize.X + v12 * absoluteSize.Y) / 2 + v9
		local v14 = (v12 * absoluteSize.X + v11 * absoluteSize.Y) / 2 + v9

		if not (v5 <= v10.X - v13 and v10.X + v13 <= v6 and v7 <= v10.Y - v14 and v10.Y + v14 <= v8) then
			continue
		end

		wrapper.Visible = false
		table.insert(wrappers, wrapper)
	end

	p.hiddenScraps = wrappers
end

function NoteBoardUI:IsNoteOpen(): boolean
	return self._openState ~= nil
end

function NoteBoardUI:_isBlocked(): boolean
	return self._destroyed == true
		or self._openState ~= nil
		or self._opening == true
		or self._inputBlocked == true
		or self._confirm ~= nil
end

function NoteBoardUI:_isForeBlocked(): boolean
	return self._destroyed == true or self._confirm ~= nil or self._inputBlocked == true
end

function NoteBoardUI:_confirmDelete(options)
	if self._destroyed or self._confirm or not self._root then
		return
	end

	local v4 = options or {}
	local lastTime = os.clock()
	local confirm = { noteId = v4.noteId, replyId = v4.replyId, armed = false, done = false }
	self._confirm = confirm
	self._hoverCount = 0
	self:_applyInputBlock()

	local dim = create("TextButton", { -- inferred equivalent call
		Name = "ConfirmDim",
		AutoButtonColor = false,
		Text = "",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 400
	}, self._root)
	create("UICorner", { CornerRadius = UDim.new(0, 10) }, dim) -- inferred equivalent call
	TweenService:Create(dim, TweenInfo.new(0.2), { BackgroundTransparency = 0.4 }):Play()
	dim.MouseButton1Click:Connect(function()
		if os.clock() - lastTime < 0.4 then
			return
		end

		self:_closeConfirm()
	end)

	local holder = create("Frame", { -- inferred equivalent call
		Name = "ConfirmCard",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(350, 495),
		Size = UDim2.fromOffset(470, 300),
		Rotation = -5,
		ZIndex = 401
	}, self._root)
	local scale = create("UIScale", { Scale = 0.6 }, holder) -- inferred equivalent call
	confirm.dim = dim
	confirm.holder = holder
	confirm.scale = scale

	local parent = create("Frame", { -- inferred equivalent call
		Name = "Shadow",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(8, 10),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1
	}, holder)

	create("UICorner", { CornerRadius = UDim.new(0, 5) }, parent) -- inferred equivalent call

	local parent2 = create("TextButton", { -- inferred equivalent call
		Name = "Card",
		AutoButtonColor = false,
		Text = "",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2
	}, holder)

	create("UICorner", { CornerRadius = UDim.new(0, 5) }, parent2) -- inferred equivalent call
	create("UIStroke", { Color = Color3.fromRGB(110, 84, 48), Thickness = 2.5, Transparency = 0.3 }, parent2) -- inferred equivalent call
	create( -- inferred equivalent call
		"UIGradient",
		{
			Rotation = 90,
			Color = ColorSequence.new(Color3.fromRGB(255, 250, 232), Color3.fromRGB(240, 229, 196))
		},
		parent2
	)

	create("Frame", { -- inferred equivalent call
		Name = "Margin",
		BackgroundColor3 = color7,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(0, 2, 1, 0),
		ZIndex = 3
	}, parent2)

	create("Frame", { -- inferred equivalent call
		Name = "Tape",
		BackgroundColor3 = color8,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(191, -10),
		Size = UDim2.fromOffset(88, 22),
		Rotation = -4,
		ZIndex = 8
	}, parent2)

	makeLabel(parent2, {
		Name = "TitleShadow",
		Position = UDim2.fromOffset(33, 17),
		Size = UDim2.fromOffset(410, 46),
		Font = font,
		Text = v4.title or "Tear it off?",
		TextSize = 38,
		TextColor3 = color5,
		TextTransparency = 0.12,
		TextTruncate = Enum.TextTruncate.None,
		ZIndex = 4
	})

	makeLabel(parent2, {
		Name = "Title",
		Position = UDim2.fromOffset(30, 14),
		Size = UDim2.fromOffset(410, 46),
		Font = font,
		Text = v4.title or "Tear it off?",
		TextSize = 38,
		TextTruncate = Enum.TextTruncate.None,
		ZIndex = 5
	})

	create("Frame", { -- inferred equivalent call
		Name = "Underline",
		BackgroundColor3 = color5,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(32, 64),
		Size = UDim2.fromOffset(180, 4),
		Rotation = -1.2,
		ZIndex = 4
	}, parent2)

	local v5 = tostring(v4.preview or "")

	if (utf8.len(v5) or #v5) > 90 then
		local v6 = utf8.offset(v5, 88)
		v5 = (v6 and string.sub(v5, 1, v6 - 1) or string.sub(v5, 1, 88)) .. "..."
	end

	makeLabel(parent2, {
		Name = "Preview",
		Position = UDim2.fromOffset(30, 80),
		Size = UDim2.fromOffset(410, 72),
		Text = "\"" .. v5 .. "\"",
		TextSize = 25,
		TextColor3 = color3,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 4
	})

	makeLabel(parent2, {
		Name = "Author",
		Position = UDim2.fromOffset(30, 156),
		Size = UDim2.fromOffset(410, 24),
		Text = "- " .. tostring(v4.author or "?"),
		TextSize = 21,
		TextColor3 = color4,
		ZIndex = 4
	})

	makeLabel(parent2, {
		Name = "Warning",
		Position = UDim2.fromOffset(30, 184),
		Size = UDim2.fromOffset(410, 24),
		Text = "this can't be undone",
		TextSize = 21,
		TextColor3 = color6,
		ZIndex = 4
	})

	local function hoverFx(p, instance, callback)
		local flag = false
		p.MouseEnter:Connect(function()
			if self._confirm ~= confirm or callback and not callback() then
				return
			end

			flag = true
			setHover(self, 1) -- inferred equivalent call
			TweenService:Create(instance, TweenInfo.new(0.12), { Scale = 1.06 }):Play()
		end)
		p.MouseLeave:Connect(function()
			if flag then
				flag = false
				setHover(self, -1) -- inferred equivalent call
			end

			TweenService:Create(instance, TweenInfo.new(0.12), { Scale = 1 }):Play()
		end)
	end

	local parent3 = create("TextButton", { -- inferred equivalent call
		Name = "KeepIt",
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(26, 26, 28),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(28, 226),
		Size = UDim2.fromOffset(190, 50),
		Font = Enum.Font.GothamBlack,
		Text = "KEEP IT",
		TextSize = 20,
		TextColor3 = color9,
		Rotation = -1.5,
		ZIndex = 6
	}, parent2)

	create("UICorner", { CornerRadius = UDim.new(0, 4) }, parent3) -- inferred equivalent call
	create("UIStroke", { Color = Color3.fromRGB(190, 40, 44), Thickness = 2.5 }, parent3) -- inferred equivalent call
	hoverFx(parent3, create("UIScale", { Scale = 1 }, parent3)) -- inferred equivalent call
	parent3.MouseButton1Click:Connect(function()
		if self._confirm ~= confirm then
			return
		end

		self:_closeConfirm()
	end)

	local parent4 = create("TextButton", { -- inferred equivalent call
		Name = "TearOff",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(150, 140, 128),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -28, 0, 226),
		Size = UDim2.fromOffset(190, 50),
		Font = Enum.Font.GothamBlack,
		Text = "WAIT...",
		TextSize = 20,
		TextColor3 = color9,
		Rotation = 1.5,
		ZIndex = 6
	}, parent2)

	create("UICorner", { CornerRadius = UDim.new(0, 4) }, parent4) -- inferred equivalent call
	create("UIStroke", { Color = color3, Thickness = 2 }, parent4) -- inferred equivalent call
	hoverFx(parent4, create("UIScale", { Scale = 1 }, parent4), function() -- inferred equivalent call
		return confirm.armed
	end)

	parent4.MouseButton1Click:Connect(function()
		if not confirm.armed or confirm.done or self._confirm ~= confirm then
			return
		end

		confirm.done = true
		local onConfirm = v4.onConfirm
		self:_closeConfirm()

		if onConfirm then
			task.spawn(onConfirm)
		end
	end)

	task.delay(0.7, function()
		if self._confirm == confirm and parent4.Parent then
			confirm.armed = true
			parent4.Text = "TEAR OFF"
			TweenService:Create(parent4, TweenInfo.new(0.15), { BackgroundColor3 = color7 }):Play()
		end
	end)

	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	TweenService:Create(scale, tweenInfo, { Scale = 1 }):Play()
	TweenService:Create(holder, tweenInfo, { Rotation = -1.5 }):Play()
end

function NoteBoardUI:_closeConfirm(p): boolean
	local confirm = self._confirm

	if not confirm then
		return false
	end

	self._confirm = nil
	self._hoverCount = 0
	self:_applyInputBlock()
	local dim = confirm.dim
	local holder = confirm.holder

	if p or not (holder and holder.Parent) then
		if holder then
			holder:Destroy()
		end

		if dim then
			dim:Destroy()
		end
	else
		TweenService:Create(confirm.scale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Scale = 0.6
		}):Play()
		TweenService:Create(dim, TweenInfo.new(0.18), { BackgroundTransparency = 1 }):Play()
		task.delay(0.2, function()
			holder:Destroy()
			dim:Destroy()
		end)
	end

	return true
end

function NoteBoardUI:CloseConfirm(p)
	return self:_closeConfirm(p)
end

function NoteBoardUI:IsConfirmOpen(): boolean
	return self._confirm ~= nil
end

function NoteBoardUI:_applyInputBlock()
	local list = self._list

	if list and list.Parent then
		list.ScrollingEnabled = not self:_isBlocked()
	end
end

function NoteBoardUI:SetInputBlocked(p)
	self._inputBlocked = p == true

	if self._inputBlocked then
		self._hoverCount = 0
	end

	self:_applyInputBlock()
end

function NoteBoardUI:_setReplyCount(p, p2)
	local replyCount = tonumber(p2) or 0
	local scrap = self._scraps[p]

	if scrap then
		scrap.note.ReplyCount = replyCount
		scrap.badge.Visible = replyCount > 0
		scrap.badgeText.Text = "re:" .. tostring(replyCount)
	end

	local openState = self._openState

	if openState and openState.noteId == p then
		openState.note.ReplyCount = replyCount
	end
end

function NoteBoardUI:ReplyAdded(p, p2, p3)
	self:_setReplyCount(p, p3)
	local openState = self._openState

	if openState and openState.noteId == p and openState.replies ~= nil and typeof(p2) == "table" then
		self:_addReplyEntry(openState, p2)
		self:_refreshOpenState(openState)

		task.defer(function()
			if openState.list.Parent then
				local v4 = math.max(0, openState.list.AbsoluteCanvasSize.Y - openState.list.AbsoluteSize.Y)
				openState.list.CanvasPosition = Vector2.new(0, v4)
			end
		end)
	end
end

function NoteBoardUI:ReplyRemoved(p, p2, p3)
	if self._confirm and self._confirm.replyId == p2 then
		self:_closeConfirm(true)
	end

	self:_setReplyCount(p, p3)
	local openState = self._openState

	if openState and openState.noteId == p then
		local entry = openState.entries[p2]

		if entry then
			entry:Destroy()
			openState.entries[p2] = nil
			openState.shown = math.max(0, openState.shown - 1)
			self._hoverCount = 0
		end

		self:_refreshOpenState(openState)
	end
end

local function trimText(text) -- 1 equivalent call inferred from this helper
	return string.match(text, "^%s*(.-)%s*$") or ""
end

function NoteBoardUI.newComposer(parent, options)
	local v4 = options or {}
	local object = setmetatable({}, class)
	object._onSubmit = v4.onSubmit
	object._onOpenChanged = v4.onOpenChanged
	object._open = false
	object._busy = false
	object._token = 0
	object._style = 1
	object._swatches = {}
	object._mode = "note"
	object._maxLength = 200
	object._drafts = { note = "", reply = "" }
	object._submitFn = nil

	local gui = create("ScreenGui", { -- inferred equivalent call
		Name = "NoteBoardComposer",
		ResetOnSpawn = false,
		DisplayOrder = 61,
		IgnoreGuiInset = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Enabled = false
	}, parent)

	object._gui = gui

	object._dim = create("TextButton", { -- inferred equivalent call
		Name = "Dim",
		AutoButtonColor = false,
		Text = "",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1
	}, gui)

	local holder = create("Frame", { -- inferred equivalent call
		Name = "Holder",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 16),
		Size = UDim2.fromOffset(460, 378),
		Rotation = -1.2,
		ZIndex = 2
	}, gui)

	object._holder = holder
	object._scale = create("UIScale", { Scale = 1 }, holder) -- inferred equivalent call

	local parent2 = create("Frame", { -- inferred equivalent call
		Name = "Shadow",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.65,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(7, 9),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1
	}, holder)

	create("UICorner", { CornerRadius = UDim.new(0, 5) }, parent2) -- inferred equivalent call

	local parent3 = create("TextButton", { -- inferred equivalent call
		Name = "Card",
		AutoButtonColor = false,
		Text = "",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2
	}, holder)

	create("UICorner", { CornerRadius = UDim.new(0, 5) }, parent3) -- inferred equivalent call
	create("UIStroke", { Color = Color3.fromRGB(110, 84, 48), Thickness = 2, Transparency = 0.35 }, parent3) -- inferred equivalent call
	create( -- inferred equivalent call
		"UIGradient",
		{
			Rotation = 90,
			Color = ColorSequence.new(Color3.fromRGB(255, 250, 232), Color3.fromRGB(240, 229, 196))
		},
		parent3
	)

	create("Frame", { -- inferred equivalent call
		Name = "Margin",
		BackgroundColor3 = color7,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(0, 2, 1, 0)
	}, parent3)

	create("Frame", { -- inferred equivalent call
		Name = "Tape",
		BackgroundColor3 = color8,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(186, -10),
		Size = UDim2.fromOffset(88, 22),
		Rotation = -4,
		ZIndex = 6
	}, parent3)

	object._titleShadow = makeLabel(parent3, {
		Name = "TitleShadow",
		Position = UDim2.fromOffset(33, 14),
		Size = UDim2.fromOffset(190, 44),
		Font = font,
		Text = "New note",
		TextSize = 36,
		TextColor3 = color5,
		TextTransparency = 0.12
	})

	object._titleLabel = makeLabel(parent3, {
		Name = "Title",
		Position = UDim2.fromOffset(30, 11),
		Size = UDim2.fromOffset(190, 44),
		Font = font,
		Text = "New note",
		TextSize = 36
	})

	object._subtitleLabel = makeLabel(parent3, {
		Name = "Subtitle",
		Position = UDim2.fromOffset(222, 26),
		Size = UDim2.fromOffset(170, 26),
		Text = "everyone can read it",
		TextSize = 19,
		TextColor3 = color6
	})

	create("Frame", { -- inferred equivalent call
		Name = "Underline",
		BackgroundColor3 = color5,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(32, 58),
		Size = UDim2.fromOffset(190, 4),
		Rotation = -1.2
	}, parent3)

	local parent4 = create("TextButton", { -- inferred equivalent call
		Name = "CloseButton",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 8),
		Size = UDim2.fromOffset(36, 36),
		BackgroundColor3 = color7,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBlack,
		Text = "X",
		TextSize = 20,
		TextColor3 = color9,
		Rotation = 4,
		ZIndex = 5
	}, parent3)

	create("UICorner", { CornerRadius = UDim.new(0, 4) }, parent4) -- inferred equivalent call
	create("UIStroke", { Color = color3, Thickness = 2 }, parent4) -- inferred equivalent call
	local uiScale = create("UIScale", { Scale = 1 }, parent4) -- inferred equivalent call
	parent4.MouseEnter:Connect(function()
		TweenService:Create(uiScale, TweenInfo.new(0.12), { Scale = 1.12 }):Play()
	end)
	parent4.MouseLeave:Connect(function()
		TweenService:Create(uiScale, TweenInfo.new(0.12), { Scale = 1 }):Play()
	end)
	parent4.MouseButton1Click:Connect(function()
		object:Close()
	end)

	local parent5 = create("Frame", { -- inferred equivalent call
		Name = "WritingPad",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(28, 74),
		Size = UDim2.fromOffset(412, 176),
		Rotation = 0.6
	}, parent3)

	create("UICorner", { CornerRadius = UDim.new(0, 3) }, parent5) -- inferred equivalent call
	object._padStroke = create("UIStroke", { -- inferred equivalent call
		Color = v3[1].edge,
		Thickness = 1.5,
		Transparency = 0.4
	}, parent5)
	object._padGradient = create( -- inferred equivalent call
		"UIGradient",
		{
			Rotation = 90,
			Color = ColorSequence.new(v3[1].paper, v3[1].shade)
		},
		parent5
	)

	local textBox = create("TextBox", { -- inferred equivalent call
		Name = "NoteText",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(12, 8),
		Size = UDim2.new(1, -24, 1, -34),
		Font = font2,
		Text = "",
		PlaceholderText = "write something for whoever finds this...",
		PlaceholderColor3 = color4,
		TextSize = 24,
		TextColor3 = color3,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		MultiLine = true,
		ClearTextOnFocus = false,
		ZIndex = 3
	}, parent5)

	object._textBox = textBox

	object._counter = makeLabel(parent5, {
		Name = "Counter",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -10, 1, -6),
		Size = UDim2.fromOffset(80, 20),
		Text = "0/" .. 200,
		TextSize = 17,
		TextColor3 = color4,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 3
	})

	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = textBox.Text
		local maxLength = object._maxLength

		if string.find(text, "[\r\n]") then
			textBox.Text = string.gsub(text, "[\r\n]+", " ")
			return
		end

		local v5 = utf8.len(text) or #text

		if maxLength < v5 then
			local v6 = utf8.offset(text, maxLength + 1)
			textBox.Text = v6 and string.sub(text, 1, v6 - 1) or string.sub(text, 1, maxLength)
		else
			object._drafts[object._mode] = text
			object._counter.Text = string.format("%d/%d", v5, maxLength)
			object._counter.TextColor3 = maxLength - 10 <= v5 and color5 or color4

			if object._status.Text ~= "" and not object._busy then
				object._status.Text = ""
			end
		end
	end)

	object._paperLabel = makeLabel(parent3, {
		Name = "PaperLabel",
		Position = UDim2.fromOffset(28, 264),
		Size = UDim2.fromOffset(62, 30),
		Text = "paper:",
		TextSize = 21,
		TextColor3 = color4
	})

	for i, v5 in ipairs(v3) do
		local button = create("TextButton", { -- inferred equivalent call
			Name = "Swatch" .. i,
			AutoButtonColor = false,
			Text = "",
			BackgroundColor3 = v5.paper,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(96 + (i - 1) * 42, 265),
			Size = UDim2.fromOffset(30, 30),
			ZIndex = 4
		}, parent3)

		create("UICorner", { CornerRadius = UDim.new(1, 0) }, button) -- inferred equivalent call
		local stroke = create("UIStroke", { Color = v5.edge, Thickness = 1.5, Transparency = 0.3 }, button) -- inferred equivalent call
		local scale = create("UIScale", { Scale = 1 }, button) -- inferred equivalent call
		object._swatches[i] = { button = button, stroke = stroke, scale = scale }
		button.MouseButton1Click:Connect(function()
			object:_setStyle(i)
		end)
	end

	object._hintLabel = makeLabel(parent3, {
		Name = "ReplyHint",
		Position = UDim2.fromOffset(28, 262),
		Size = UDim2.fromOffset(404, 34),
		Text = "anyone who opens this note can read your reply",
		TextSize = 18,
		TextColor3 = color6,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.None,
		Visible = false
	})

	object._status = makeLabel(parent3, {
		Name = "Status",
		Position = UDim2.fromOffset(28, 302),
		Size = UDim2.fromOffset(404, 22),
		Text = "",
		TextSize = 19,
		TextColor3 = color5
	})

	local textButton = create("TextButton", { -- inferred equivalent call
		Name = "Cancel",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(26, 326),
		Size = UDim2.fromOffset(100, 38),
		Font = font2,
		Text = "cancel",
		TextSize = 24,
		TextColor3 = color4,
		ZIndex = 4
	}, parent3)

	textButton.MouseEnter:Connect(function()
		textButton.TextColor3 = color3
	end)
	textButton.MouseLeave:Connect(function()
		textButton.TextColor3 = color4
	end)
	textButton.MouseButton1Click:Connect(function()
		object:Close()
	end)

	local stick = create("TextButton", { -- inferred equivalent call
		Name = "StickIt",
		AutoButtonColor = true,
		BackgroundColor3 = Color3.fromRGB(26, 26, 28),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -22, 0, 322),
		Size = UDim2.fromOffset(200, 46),
		Font = Enum.Font.GothamBlack,
		Text = "STICK IT",
		TextSize = 20,
		TextColor3 = color9,
		Rotation = -1.5,
		ZIndex = 4
	}, parent3)

	create("UICorner", { CornerRadius = UDim.new(0, 4) }, stick) -- inferred equivalent call
	create("UIStroke", { Color = Color3.fromRGB(190, 40, 44), Thickness = 2.5 }, stick) -- inferred equivalent call
	object._stick = stick
	stick.MouseButton1Click:Connect(function()
		object:_submit()
	end)

	object:_setStyle(1)
	return object
end

function class:_applyPadStyle(p)
	local v4 = v3[p] or v3[1]
	self._padGradient.Color = ColorSequence.new(v4.paper, v4.shade)
	self._padStroke.Color = v4.edge
end

function class:_setStyle(style)
	self._style = style
	self:_applyPadStyle(style)

	for i, swatch in ipairs(self._swatches) do
		local v4 = i == style
		swatch.stroke.Color = v4 and color3 or v3[i].edge
		swatch.stroke.Thickness = v4 and 3 or 1.5
		TweenService:Create(swatch.scale, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = v4 and 1.15 or 1
		}):Play()
	end
end

function class:_updateScale()
	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local viewportSize = currentCamera.ViewportSize
	local v4 = math.min((viewportSize.X - 24) / 460, (viewportSize.Y - 40) / 378, 1.25)
	self._scale.Scale = math.clamp(v4, 0.5, 1.25)
end

function class:_submit()
	if self._busy or not self._open then
		return
	end

	local v4 = trimText(self._textBox.Text) -- inferred equivalent call

	if v4 == "" then
		self._status.Text = "write something first!"
		return
	end

	if not self._submitFn then
		return
	end

	self._busy = true
	self._status.Text = ""
	self._stick.Text = "STICKING..."
	task.spawn(function()
		local success, result, v5 = pcall(self._submitFn, v4, self._style)
		self._busy = false
		self._stick.Text = "STICK IT"

		if not (success and result) then
			self._status.Text = (not success or typeof(v5) ~= "string" or not v5) and "couldn't stick it, try again"
				or v5

			return
		end

		self._drafts[self._mode] = ""
		self._textBox.Text = ""
		self._status.Text = ""
		self:Close()
	end)
end

function class:IsOpen()
	return self._open
end

function class:Open(options)
	local v4 = options or {}

	if self._open then
		return
	end

	local visible = v4.mode == "reply"
	self._open = true
	self._token += 1

	if self._onOpenChanged then
		pcall(self._onOpenChanged, true)
	end

	self._mode = visible and "reply" or "note"
	self._maxLength = 200
	self._submitFn = v4.onSubmit or self._onSubmit
	local text = visible and "Reply" or "New note"
	self._titleLabel.Text = text
	self._titleShadow.Text = text
	self._subtitleLabel.Text = visible and (v4.subtitle or "visible once the note is opened") or "everyone can read it"
	self._paperLabel.Visible = not visible

	for _, swatch in ipairs(self._swatches) do
		swatch.button.Visible = not visible
	end

	self._hintLabel.Visible = visible
	self:_applyPadStyle(visible and 2 or self._style)

	self._textBox.Text = self._drafts[self._mode] or ""
	local v5 = utf8.len(self._textBox.Text) or #self._textBox.Text
	self._counter.Text = string.format("%d/%d", v5, self._maxLength)

	self:_updateScale()
	self._status.Text = ""
	self._gui.Enabled = true

	self._holder.Position = UDim2.new(0.5, 0, 0, -378)
	self._holder.Rotation = -7
	TweenService:Create(self._holder, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0, 16),
		Rotation = -1.2
	}):Play()
	TweenService:Create(self._dim, TweenInfo.new(0.3), { BackgroundTransparency = 0.5 }):Play()

	local token = self._token
	task.delay(0.12, function()
		if self._open and self._token == token then
			self._textBox:CaptureFocus()
		end
	end)
end

function class:Close(p)
	if not self._open then
		return
	end

	self._open = false
	self._token += 1
	local token = self._token

	if self._onOpenChanged then
		pcall(self._onOpenChanged, false)
	end

	if self._textBox:IsFocused() then
		self._textBox:ReleaseFocus()
	end

	if p then
		self._gui.Enabled = false
		self._dim.BackgroundTransparency = 1
	else
		TweenService:Create(self._holder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(0.5, 0, 0, -378),
			Rotation = 5
		}):Play()
		TweenService:Create(self._dim, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
		task.delay(0.32, function()
			if not self._open and self._token == token then
				self._gui.Enabled = false
			end
		end)
	end
end

function class:Destroy()
	self._open = false

	if self._gui then
		self._gui:Destroy()
		self._gui = nil
	end
end

return NoteBoardUI