local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local HallOfFameUI = {}
HallOfFameUI.__index = HallOfFameUI

HallOfFameUI.BannerCanvas = Vector2.new(1390, 260)
HallOfFameUI.DropCanvas = Vector2.new(720, 600)

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local color = Color3.fromRGB(247, 240, 212)
local color2 = Color3.fromRGB(225, 211, 170)
local color3 = Color3.fromRGB(26, 22, 20)
local color4 = Color3.fromRGB(78, 66, 56)
local color5 = Color3.fromRGB(176, 32, 36)
local color6 = Color3.fromRGB(66, 98, 168)
local color7 = Color3.fromRGB(46, 112, 64)
local color8 = Color3.fromRGB(198, 62, 62)
local color9 = Color3.fromRGB(120, 92, 52)
local color10 = Color3.fromRGB(252, 226, 116)
local color11 = Color3.fromRGB(190, 152, 48)
local color12 = Color3.fromRGB(218, 186, 140)
local color13 = Color3.fromRGB(110, 78, 40)
local color14 = Color3.fromRGB(34, 34, 38)
local color15 = Color3.fromRGB(132, 134, 140)
local color16 = Color3.fromRGB(250, 247, 238)

local success, result = pcall(function()
	return require(script.Parent:WaitForChild("SkinConfig", 3))
end)

local v = {
	Common = Color3.fromRGB(170, 170, 180),
	Rare = Color3.fromRGB(80, 160, 255),
	Epic = Color3.fromRGB(184, 108, 255),
	Legendary = Color3.fromRGB(255, 176, 48)
}

local function tierColor(p) -- 4 equivalent calls inferred from this helper
	local v2

	if p == 1 then
		v2 = "Legendary"
	elseif p and p <= 3 then
		v2 = "Epic"
	else
		v2 = if p and p <= 10 then "Rare" else "Common"
	end

	local v3 = success

	if v3 then
		if typeof(result) == "table" then
			v3 = result.Rarities and result.Rarities[v2]
		else
			v3 = false
		end
	end

	return v3 and v3.Color or v[v2]
end

local function pickFont(list, p)
	for _, item in ipairs(list) do
		local success2, result2 = pcall(function()
			return Enum.Font[item]
		end)

		if success2 and result2 then
			return result2
		end
	end

	return p
end

local font = pickFont({ "PermanentMarker", "Bangers" }, Enum.Font.GothamBlack)
local font2 = pickFont({ "Kalam", "PatrickHand", "IndieFlower" }, Enum.Font.SourceSansSemibold)

local function create(className, items, parent) -- 79 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function label(parent, items)
	local v2 = {
		BackgroundTransparency = 1,
		Font = font2,
		TextSize = 26,
		TextColor3 = color3,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd
	}

	for k, item in pairs(items) do
		v2[k] = item
	end

	return create("TextLabel", v2, parent) -- inferred equivalent call
end

local function formatNumber(score)
	local v2 = tostring((math.floor(tonumber(score) or 0)))

	local v3 = string.reverse(string.gsub(string.reverse(v2), "(%d%d%d)", "%1,"))

	if string.sub(v3, 1, 1) == "," then
		return (string.sub(v3, 2))
	end

	return v3
end

local function rankInk(rank) -- 1 equivalent call inferred from this helper
	if rank == 1 then
		return color5
	elseif rank == 2 then
		return color6
	elseif rank == 3 then
		return color7
	end

	return color4
end

local v2 = string.format(
	"#%02X%02X%02X",
	math.floor(color5.R * 255 + 0.5),
	math.floor(color5.G * 255 + 0.5),
	(math.floor(color5.B * 255 + 0.5))
)
local function red(p) -- 16 equivalent calls inferred from this helper
	return string.format("<font color=\"%s\">%s</font>", v2, p)
end

local v3 = {
	{ key = "Total", text = "TOTAL" },
	{ key = "Guitar", text = "GUITAR" },
	{ key = "Bass", text = "BASS" },
	{ key = "Drum", text = "DRUM" },
	{ key = "Piano", text = "PIANO" },
	{ key = "Keyboard", text = "KEYS" }
}

local v4 = {
	score = {
		Title = "TOTAL SCORE?",
		Sections = {
			{
				"WHAT IS IT?",
				"All your best song scores added together. Each song counts " .. red("once") .. ", using your highest score from any instrument." -- inferred equivalent call
			},
			{
				"HOW A SONG IS SCORED",
				"Up to " .. red("1,000,000") .. " per song: 85% accuracy + 15% longest combo. Accuracy pays Perfect " .. red("100%") .. ", Great " .. red("70%") .. ", Good " .. red("40%") .. ", OK " .. red("15%") .. ", Miss nothing. The points you see while playing are just for show. Your real score is worked out from your hits." -- inferred equivalent call
			},
			{
				"YOUR PART OF THE SONG",
				"A part that plays at least " .. red("70%") .. " as long as the busiest part in the song counts in full. A much shorter part (like a piano with only a few notes) counts for less, so it cannot beat a part that carries the whole song. Join late and you only get the notes left: join with a quarter of your part still to play and the score is " .. red("x0.25") .. "." -- inferred equivalent call
			},
			{
				"DIFFICULTY MATTERS",
				"Difficulty settings shrink it: Medium " .. red("x0.9") .. ", Easy " .. red("x0.75") .. ", Baby " .. red("x0.55") .. ". Every key you remove costs 4% (a 2-Key guitar = -12%, a 2-Key bass = -8%). They stack: Easy + 2-Key guitar = " .. red("x0.66") .. ". Natural with all keys = full value. If you change it mid-song, each setting counts for the time you used it. Note speed does not matter." -- inferred equivalent call
			},
			{
				"HOW TO RAISE IT",
				[[
- Play more songs, each new one adds up.
- Beat your best. Only a higher score counts and only the difference is added, so your total never drops.
- Play the whole song. Put your instrument back before your last note passes = no score.
- Autoplay never counts.]]
			},
			{
				"NEW HERE?",
				"You start at " .. red("1") .. " point, hit " .. red("10") .. " after 5 minutes online, then get +5 every 5 minutes. The timer restarts when you leave the server. Your song scores take over once they pass it." -- inferred equivalent call
			},
			{
				"GOOD TO KNOW",
				"Solo or with a band, both count. Touch Chart on mobile never changes your score. The board refreshes about once a minute."
			}
		}
	},
	freeplay = {
		Title = "FREEPLAY HITS?",
		Sections = {
			{
				"WHAT IS IT?",
				"Every note you play in Free Play, added together. Guitar, Bass, Drum, Piano and Keyboard all count."
			},
			{
				"WHAT IS A HIT?",
				"One key press on your instrument = " .. red("1 hit") .. ". Holding a guitar tremolo still counts as just 1 hit, for the press that starts it. Only presses you make yourself count: autoplay, recorded tabs and auto-clickers do not." -- inferred equivalent call
			},
			{
				"THE BUTTONS",
				red("TOTAL") .. " adds every instrument together. The other buttons rank you for one instrument only. Both guitars count as GUITAR." -- inferred equivalent call
			},
			{
				"HOW TO RAISE IT",
				[[
- Grab an instrument and play in Free Play.
- Songs and gigs do not add hits, only Free Play does.
- Hits only go up, so your count never drops.]]
			},
			{
				"GOOD TO KNOW",
				"Your hits reach the board every couple of minutes, and the board refreshes about once a minute."
			}
		}
	}
}

local function addTape(parent, p, p2, rotation, backgroundColor, value, value2, value3)
	local parent2 = create("Frame", { -- inferred equivalent call
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(p, p2),
		Size = UDim2.fromOffset(value or 96, value2 or 24),
		Rotation = rotation,
		BackgroundColor3 = backgroundColor,
		BackgroundTransparency = 0.06,
		BorderSizePixel = 0,
		ZIndex = value3 or 20
	}, parent)

	create("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Transparency = 0.6, Thickness = 1 }, parent2) -- inferred equivalent call
	return parent2
end

local v5 = { color14, color5, color15, Color3.fromRGB(70, 72, 78), color13 }
local function smallTape(parent, p, p2, p3, value) -- 4 equivalent calls inferred from this helper
	local backgroundColor = v5[p * 3 % #v5 + 1]
	return addTape(parent, p2, p3, p * 13 % 41 - 20, backgroundColor, 16 + p * 5 % 9, 6 + p * 3 % 3, value or 6)
end

local function avatarBustUrl(userId) -- 1 equivalent call inferred from this helper
	return string.format("rbxthumb://type=AvatarBust&id=%d&w=150&h=150", userId)
end

local function avatarUrl(userId) -- 1 equivalent call inferred from this helper
	return string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", userId)
end

local function coffeeRing(parent, p, p2, p3, value)
	local parent2 = create("Frame", { -- inferred equivalent call
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(p, p2),
		Size = UDim2.fromOffset(p3, p3),
		BackgroundTransparency = 1,
		ZIndex = value or 2
	}, parent)

	create("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
	create("UIStroke", { Color = Color3.fromRGB(150, 98, 52), Transparency = 0.62, Thickness = 5 }, parent2) -- inferred equivalent call
end

local function newRowFrame(parent, layoutOrder, p, p2, options)
	local v6 = options or {}
	return create("Frame", { -- inferred equivalent call
		Size = UDim2.fromOffset(p, p2),
		Position = v6.position or UDim2.new(),
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		Rotation = v6.rotation or 0
	}, parent)
end

local function populateRow(parent, data, p, p2, p3, p4, options)
	local v6 = options or {}

	if v6.special and data.Rank then
		local v7 = tierColor(data.Rank) -- inferred equivalent call
		local parent2 = create( -- inferred equivalent call
			"Frame",
			{
				Size = UDim2.new(1, 0, 1, -4),
				BackgroundColor3 = v7,
				BackgroundTransparency = 0.74,
				BorderSizePixel = 0
			},
			parent
		)

		create("UICorner", { CornerRadius = UDim.new(0, 4) }, parent2) -- inferred equivalent call
		create("UIStroke", { Color = v7, Transparency = 0.05, Thickness = 2.5 }, parent2) -- inferred equivalent call
		smallTape(parent, p + 7, 26, 2) -- inferred equivalent call
		smallTape(parent, p + 11, p2 - 46, p3 - 4) -- inferred equivalent call
	end

	if p4 then
		local parent2 = create( -- inferred equivalent call
			"Frame",
			{
				Size = UDim2.new(1, 0, 1, -4),
				BackgroundColor3 = color10,
				BackgroundTransparency = 0.38,
				BorderSizePixel = 0
			},
			parent
		)

		create("UICorner", { CornerRadius = UDim.new(0, 3) }, parent2) -- inferred equivalent call
		create("UIStroke", { Color = color5, Transparency = 0.2, Thickness = 1.5 }, parent2) -- inferred equivalent call
	end

	if v6.ruled then
		create("Frame", { -- inferred equivalent call
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 2),
			BackgroundColor3 = color6,
			BackgroundTransparency = 0.6,
			BorderSizePixel = 0
		}, parent)
	end

	local textSize = v6.textSize or 26
	local rankWidth = v6.rankWidth or 56
	local v7 = {
		Position = UDim2.fromOffset(4, 0),
		Size = UDim2.fromOffset(rankWidth, p3),
		Font = font,
		Text = (v6.rankPrefix or "") .. (data.Rank and tostring(data.Rank) or "100+"),
		AutoLocalize = false,
		TextSize = textSize + 8,
		TextColor3 = 0,
		TextXAlignment = 0,
		TextTruncate = 0
	}
	local textColor

	if data.Rank then
		textColor = rankInk(data.Rank) or color5 -- inferred equivalent call
	else
		textColor = color5
	end

	v7.TextColor3 = textColor
	v7.TextXAlignment = Enum.TextXAlignment.Center
	v7.TextTruncate = Enum.TextTruncate.None
	label(parent, v7, parent)

	local v8 = p3 - 4
	local v9 = math.floor(v8 * 0.75 + 0.5)
	local v10 = rankWidth + 10

	if data.UserId then
		local parent2 = create("Frame", { -- inferred equivalent call
			Name = "Photo",
			Position = UDim2.fromOffset(v10, 2),
			Size = UDim2.fromOffset(v9, v8),
			BackgroundColor3 = color16,
			BorderSizePixel = 0,
			Rotation = (p * 5 % 3 - 1) * 1.4
		}, parent)

		create("UIStroke", { Color = color3, Thickness = 1.5 }, parent2) -- inferred equivalent call
		local parent3 = create("ImageLabel", { -- inferred equivalent call
			Position = UDim2.fromOffset(3, 3),
			Size = UDim2.new(1, -6, 1, -6),
			BackgroundColor3 = tierColor(data.Rank), -- inferred equivalent call
			BorderSizePixel = 0,
			Image = avatarUrl(data.UserId), -- inferred equivalent call
			ScaleType = Enum.ScaleType.Crop
		}, parent2)

		create("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Transparency = 0.65, Thickness = 1 }, parent3) -- inferred equivalent call

		smallTape(parent2, p + (data.Rank or 0), v9 / 2, 0) -- inferred equivalent call

		if p % 2 == 0 then
			smallTape(parent2, p + 3, v9 - 2, v8 - 1) -- inferred equivalent call
		end
	end

	local v11 = v10 + v9 + 12
	local scoreWidth = v6.scoreWidth or 170
	label(parent, {
		Position = UDim2.fromOffset(v11, 0),
		Size = UDim2.new(1, -(v11 + scoreWidth + 12), 1, 0),
		Text = (data.Name or "Player") .. (p4 and "  (you)" or ""),
		AutoLocalize = false,
		TextSize = textSize,
		TextColor3 = p4 and color5 or color3
	}, parent)

	label(parent, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 0),
		Size = UDim2.fromOffset(scoreWidth, p3),
		Font = font,
		Text = formatNumber(data.Score),
		AutoLocalize = false,
		TextSize = textSize + 2,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = color3,
		TextTruncate = Enum.TextTruncate.None
	}, parent)

	return parent
end

local function buildRow(parent, p, i, p2, p3, p4, p5) -- 2 equivalent calls inferred from this helper
	local row = newRowFrame(parent, i, p2, p3, p5)
	populateRow(row, p, i, p2, p3, p4, p5)
	return row
end

function HallOfFameUI.new(bannerGui, dropGui, options)
	local v6 = options or {}
	local self = setmetatable({}, HallOfFameUI)
	self._bannerGui = bannerGui
	self._dropGui = dropGui
	self._dropPart = v6.dropPart
	self._onMore = v6.onMore
	self._onDropOpened = v6.onDropOpened
	self._onDropClosed = v6.onDropClosed
	self._destroyed = false
	self._hovered = {}
	self._hoverCount = 0
	self._top5 = {}
	self._top100 = {}
	self._you = nil
	self._dropOpen = false
	self._token = 0
	self._infoOpen = false
	self._infoToken = 0
	self._tab = "score"
	self._fpFilter = "Total"
	self._fp = {}
	self._onFreePlay = v6.onFreePlay

	self:_buildBanner()
	self:_buildDrop()
	self:_renderBanner()
	return self
end

function HallOfFameUI:_trackHover(p)
	p.MouseEnter:Connect(function()
		if not self._hovered[p] then
			self._hovered[p] = true
			self._hoverCount += 1
		end
	end)
	p.MouseLeave:Connect(function()
		if self._hovered[p] then
			self._hovered[p] = nil
			self._hoverCount = math.max(0, self._hoverCount - 1)
		end
	end)
end

local function paperBase(bannerGui, _, p, p2, p3, options)
	local parent = create("Frame", { -- inferred equivalent call
		Name = "Root",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ClipsDescendants = true
	}, bannerGui)

	create("UIGradient", { -- inferred equivalent call
		Rotation = 90,
		Color = ColorSequence.new(color, color2)
	}, parent)

	if p2 then
		for i = p2, p, p3 do
			create("Frame", { -- inferred equivalent call
				Position = UDim2.fromOffset(0, i),
				Size = UDim2.new(1, 0, 0, 2),
				BackgroundColor3 = color6,
				BackgroundTransparency = 0.72,
				BorderSizePixel = 0,
				ZIndex = 1
			}, parent)
		end
	end

	create("Frame", { -- inferred equivalent call
		Position = UDim2.fromOffset(46, 0),
		Size = UDim2.new(0, 3, 1, 0),
		BackgroundColor3 = color8,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		ZIndex = 1
	}, parent)

	for _, v6 in ipairs(options or {}) do
		local parent2 = create("Frame", { -- inferred equivalent call
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(22, v6),
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = Color3.fromRGB(70, 60, 50),
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			ZIndex = 1
		}, parent)

		create("UICorner", { CornerRadius = UDim.new(1, 0) }, parent2) -- inferred equivalent call
	end

	return parent
end

function HallOfFameUI:_buildBanner()
	local bannerRoot = paperBase(self._bannerGui, 1390, 260, 58, 47, { 56, 130, 204 })
	create("UIStroke", { Color = color9, Thickness = 3 }, bannerRoot) -- inferred equivalent call
	self._bannerRoot = bannerRoot

	label(bannerRoot, {
		Name = "Title",
		Position = UDim2.fromOffset(66, 8),
		Size = UDim2.fromOffset(520, 100),
		Font = font,
		Text = "NOISEMAKERS",
		TextSize = 76,
		TextColor3 = color3,
		TextTruncate = Enum.TextTruncate.None,
		Rotation = -1.6,
		ZIndex = 5
	}, bannerRoot)

	create("Frame", { -- inferred equivalent call
		Position = UDim2.fromOffset(72, 104),
		Size = UDim2.fromOffset(430, 6),
		BackgroundColor3 = color5,
		BorderSizePixel = 0,
		Rotation = -1.2,
		ZIndex = 5
	}, bannerRoot)

	create("Frame", { -- inferred equivalent call
		Position = UDim2.fromOffset(92, 116),
		Size = UDim2.fromOffset(300, 4),
		BackgroundColor3 = color5,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		Rotation = 0.8,
		ZIndex = 5
	}, bannerRoot)

	label(bannerRoot, {
		Name = "Subtitle",
		Position = UDim2.fromOffset(78, 122),
		Size = UDim2.fromOffset(420, 36),
		Font = font,
		Text = "NOISE WORSHIP",
		TextSize = 30,
		TextColor3 = color5,
		TextTruncate = Enum.TextTruncate.None,
		Rotation = -1.4,
		ZIndex = 5
	}, bannerRoot)

	label(bannerRoot, {
		Name = "Caption",
		Position = UDim2.fromOffset(80, 160),
		Size = UDim2.fromOffset(500, 26),
		Text = "total of everyone's best scores",
		TextSize = 22,
		TextColor3 = color4,
		Rotation = -0.6,
		ZIndex = 5
	}, bannerRoot)

	local parent = create("Frame", { -- inferred equivalent call
		Name = "YouSticky",
		Position = UDim2.fromOffset(74, 192),
		Size = UDim2.fromOffset(410, 50),
		BackgroundColor3 = color10,
		BorderSizePixel = 0,
		Rotation = 1.6,
		ZIndex = 6
	}, bannerRoot)

	create("UICorner", { CornerRadius = UDim.new(0, 3) }, parent) -- inferred equivalent call
	create("UIStroke", { Color = color11, Thickness = 1.5 }, parent) -- inferred equivalent call
	self._youLabel = label(parent, {
		Name = "You",
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -28, 1, 0),
		Font = font,
		Text = "",
		TextSize = 26,
		TextColor3 = color3,
		ZIndex = 7
	}, parent)

	addTape(parent, 34, 2, -9, color14, 70, 18, 8)
	addTape(parent, 398, 46, 24, color15, 40, 12, 8)

	local localPlayer = Players.LocalPlayer
	local parent2 = create("Frame", { -- inferred equivalent call
		Name = "YouPhoto",
		Position = UDim2.fromOffset(508, 98),
		Size = UDim2.fromOffset(78, 104),
		BackgroundColor3 = color16,
		BorderSizePixel = 0,
		Rotation = 4,
		ZIndex = 7
	}, bannerRoot)

	create("UIStroke", { Color = color3, Thickness = 2 }, parent2) -- inferred equivalent call
	local photo = {
		Name = "Photo",
		Position = UDim2.fromOffset(5, 5),
		Size = UDim2.new(1, -10, 1, -10),
		BackgroundColor3 = tierColor(), -- inferred equivalent call
		BorderSizePixel = 0,
		Image = 0,
		ScaleType = 0,
		ZIndex = 8
	}
	local image

	if localPlayer then
		image = avatarBustUrl(localPlayer.UserId) or "" -- inferred equivalent call
	else
		image = ""
	end

	photo.Image = image
	photo.ScaleType = Enum.ScaleType.Crop
	local youPhotoImage = create("ImageLabel", photo, parent2) -- inferred equivalent call
	create("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Transparency = 0.6, Thickness = 1 }, youPhotoImage) -- inferred equivalent call
	addTape(parent2, 40, 1, -5, color14, 56, 14, 10)
	addTape(parent2, 3, 6, -42, color5, 36, 11, 10)
	addTape(parent2, 75, 100, -38, color15, 38, 11, 10)
	addTape(parent2, 76, 4, 30, Color3.fromRGB(70, 72, 78), 26, 9, 10)
	self._youPhotoImage = youPhotoImage

	self._rows = create("Frame", { -- inferred equivalent call
		Name = "Rows",
		Position = UDim2.fromOffset(620, 16),
		Size = UDim2.fromOffset(640, 236),
		BackgroundTransparency = 1,
		ZIndex = 5
	}, bannerRoot)

	local moreButton = create("TextButton", { -- inferred equivalent call
		Name = "More",
		Position = UDim2.fromOffset(1276, 74),
		Size = UDim2.fromOffset(98, 112),
		BackgroundColor3 = color12,
		Text = "MORE\n>>",
		Font = font,
		TextSize = 26,
		TextColor3 = color3,
		AutoButtonColor = false,
		Rotation = 3,
		ZIndex = 8
	}, bannerRoot)

	create("UICorner", { CornerRadius = UDim.new(0, 3) }, moreButton) -- inferred equivalent call
	create("UIStroke", { Color = color13, Thickness = 1.5 }, moreButton) -- inferred equivalent call
	addTape(moreButton, 26, 2, -12, color14, 62, 16, 9)
	addTape(moreButton, 78, 110, 16, color5, 54, 14, 9)
	self:_trackHover(moreButton)
	moreButton.MouseEnter:Connect(function()
		TweenService:Create(moreButton, TweenInfo.new(0.12), {
			Rotation = 0,
			Size = UDim2.fromOffset(104, 118)
		}):Play()
	end)
	moreButton.MouseLeave:Connect(function()
		TweenService:Create(moreButton, TweenInfo.new(0.12), {
			Rotation = 3,
			Size = UDim2.fromOffset(98, 112)
		}):Play()
	end)
	moreButton.Activated:Connect(function()
		if self._onMore then
			self._onMore()
		end
	end)
	self._moreButton = moreButton

	addTape(bannerRoot, 590, 8, -6, color15, 96, 22, 9)
	addTape(bannerRoot, 1196, 3, -8, color5, 84, 18, 9)
	addTape(bannerRoot, 1368, 244, 31, color14, 78, 20, 9)
	coffeeRing(bannerRoot, 566, 232, 92, 2)

	addTape(bannerRoot, 60, 252, 18, color14, 44, 12, 9)
	addTape(bannerRoot, 506, 38, -35, color15, 46, 12, 9)
	addTape(bannerRoot, 598, 78, 70, color5, 34, 11, 9)
	addTape(bannerRoot, 598, 196, -62, color14, 38, 11, 9)
	addTape(bannerRoot, 1262, 252, 25, color15, 42, 12, 9)
	addTape(bannerRoot, 1318, 52, -15, color5, 36, 11, 9)
	addTape(bannerRoot, 1384, 132, 80, color14, 36, 11, 9)
	addTape(bannerRoot, 330, 8, 12, color5, 30, 10, 9)
	addTape(bannerRoot, 960, 254, -8, color13, 38, 11, 9)
	label(bannerRoot, {
		Position = UDim2.fromOffset(446, 124),
		Size = UDim2.fromOffset(60, 50),
		Font = font,
		Text = "!!",
		TextSize = 44,
		TextColor3 = color5,
		TextTruncate = Enum.TextTruncate.None,
		Rotation = 14,
		ZIndex = 5
	}, bannerRoot)
end

function HallOfFameUI:_renderBanner()
	for _, child in ipairs(self._rows:GetChildren()) do
		child:Destroy()
	end

	local userId = Players.LocalPlayer and Players.LocalPlayer.UserId
	local top5 = self._top5

	if #top5 == 0 then
		label(self._rows, {
			Size = UDim2.fromScale(1, 1),
			Font = font,
			Text = "No scores yet. Be the first on the board!",
			TextSize = 34,
			TextColor3 = color4,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextTruncate = Enum.TextTruncate.None
		}, self._rows)
	else
		for i = 1, math.min(#top5, 5) do
			local v6 = top5[i]
			buildRow(self._rows, v6, i, 640, 44, v6.UserId == userId, { -- inferred equivalent call
				position = UDim2.fromOffset(0, (i - 1) * 47),
				rotation = (i * 7 % 3 - 1) * 0.25,
				textSize = 26,
				scoreWidth = 190
			})
		end
	end

	local you = self._you

	if self._youPhotoImage then
		local youPhotoImage = self._youPhotoImage
		local v6

		if you then
			v6 = you.Rank or nil
		end

		youPhotoImage.BackgroundColor3 = tierColor(v6) -- inferred equivalent call
	end

	if you and (you.Score or 0) > 0 then
		self._youLabel.Text = string.format(
			"YOU  %s  -  %s",
			you.Rank and "#" .. you.Rank or "100+",
			formatNumber(you.Score)
		)
	else
		self._youLabel.Text = "play a song to get ranked"
	end
end

function HallOfFameUI:_buildDrop()
	local dropGui = self._dropGui
	local sheet = create("Frame", { -- inferred equivalent call
		Name = "Sheet",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromOffset(360, 0),
		Size = UDim2.fromOffset(720, 28),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Active = true
	}, dropGui)

	create("UIGradient", { -- inferred equivalent call
		Rotation = 90,
		Color = ColorSequence.new(color, color2)
	}, sheet)
	create("UIStroke", { Color = color9, Thickness = 3 }, sheet) -- inferred equivalent call
	self._sheet = sheet

	local dropContent = create( -- inferred equivalent call
		"Frame",
		{
			Name = "Content",
			Size = UDim2.fromOffset(720, 600),
			BackgroundTransparency = 1,
			Visible = false
		},
		sheet
	)

	self._dropContent = dropContent

	create("Frame", { -- inferred equivalent call
		Position = UDim2.fromOffset(46, 0),
		Size = UDim2.new(0, 3, 1, 0),
		BackgroundColor3 = color8,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0
	}, dropContent)

	for _, v6 in ipairs({ 120, 300, 480 }) do
		local parent = create("Frame", { -- inferred equivalent call
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(22, v6),
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = Color3.fromRGB(70, 60, 50),
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0
		}, dropContent)

		create("UICorner", { CornerRadius = UDim.new(1, 0) }, parent) -- inferred equivalent call
	end

	label(dropContent, {
		Position = UDim2.fromOffset(66, 10),
		Size = UDim2.fromOffset(420, 70),
		Font = font,
		Text = "TOP 100",
		TextSize = 60,
		TextTruncate = Enum.TextTruncate.None,
		Rotation = -1.5
	}, dropContent)

	create("Frame", { -- inferred equivalent call
		Position = UDim2.fromOffset(72, 76),
		Size = UDim2.fromOffset(300, 5),
		BackgroundColor3 = color5,
		BorderSizePixel = 0,
		Rotation = -1
	}, dropContent)

	self._dropSubtitle = label(dropContent, {
		Position = UDim2.fromOffset(74, 84),
		Size = UDim2.fromOffset(460, 24),
		Font = font,
		Text = "NOISEMAKERS",
		TextSize = 20,
		TextColor3 = color5,
		TextTruncate = Enum.TextTruncate.None
	}, dropContent)

	self:_buildTabs(dropContent)

	local dropList = create("ScrollingFrame", { -- inferred equivalent call
		Name = "List",
		Position = UDim2.fromOffset(60, 114),
		Size = UDim2.fromOffset(642, 394),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = color4,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.Never
	}, dropContent)

	create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, dropList) -- inferred equivalent call
	create("UIPadding", { PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 6) }, dropList) -- inferred equivalent call
	self._dropList = dropList
	dropList:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		self:_updateDropVirtual()
	end)

	self._youHolder = create("Frame", { -- inferred equivalent call
		Name = "YouHolder",
		Position = UDim2.fromOffset(60, 520),
		Size = UDim2.fromOffset(630, 58),
		BackgroundColor3 = color10,
		BorderSizePixel = 0,
		Rotation = -0.8
	}, dropContent)

	create("UICorner", { CornerRadius = UDim.new(0, 3) }, self._youHolder) -- inferred equivalent call
	create("UIStroke", { Color = color11, Thickness = 1.5 }, self._youHolder) -- inferred equivalent call
	addTape(self._youHolder, 30, 2, -8, color14, 66, 16, 5)
	addTape(self._youHolder, 616, 56, 14, color15, 40, 12, 5)

	local closeButton = create("TextButton", { -- inferred equivalent call
		Name = "Close",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(0, 702, 0, 16),
		Size = UDim2.fromOffset(54, 54),
		BackgroundColor3 = color8,
		Text = "X",
		Font = Enum.Font.GothamBlack,
		TextSize = 28,
		TextColor3 = Color3.fromRGB(244, 232, 200),
		AutoButtonColor = true,
		Rotation = 4,
		Visible = false,
		ZIndex = 31
	}, sheet)

	create("UICorner", { CornerRadius = UDim.new(0, 4) }, closeButton) -- inferred equivalent call
	create("UIStroke", { Color = color3, Thickness = 2 }, closeButton) -- inferred equivalent call
	self:_trackHover(closeButton)
	closeButton.Activated:Connect(function()
		self:CloseDrop()
	end)
	self._closeButton = closeButton

	local helpButton = create("TextButton", { -- inferred equivalent call
		Name = "Help",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(0, 636, 0, 18),
		Size = UDim2.fromOffset(50, 50),
		BackgroundColor3 = color12,
		Text = "?",
		Font = font,
		TextSize = 34,
		TextColor3 = color3,
		AutoButtonColor = false,
		Rotation = -5,
		Visible = false,
		ZIndex = 31
	}, sheet)

	create("UICorner", { CornerRadius = UDim.new(0, 3) }, helpButton) -- inferred equivalent call
	create("UIStroke", { Color = color13, Thickness = 2 }, helpButton) -- inferred equivalent call
	addTape(helpButton, 22, 2, -10, color14, 40, 12, 32)
	self:_trackHover(helpButton)
	helpButton.MouseEnter:Connect(function()
		TweenService:Create(helpButton, TweenInfo.new(0.12), {
			Rotation = 0,
			Size = UDim2.fromOffset(54, 54)
		}):Play()
	end)
	helpButton.MouseLeave:Connect(function()
		TweenService:Create(helpButton, TweenInfo.new(0.12), {
			Rotation = -5,
			Size = UDim2.fromOffset(50, 50)
		}):Play()
	end)
	helpButton.Activated:Connect(function()
		self:_setInfo(not self._infoOpen)
	end)
	self._helpButton = helpButton

	self._infoPos = UDim2.fromOffset(360, 342)

	local infoDim = create("TextButton", { -- inferred equivalent call
		Name = "InfoDim",
		Position = UDim2.fromOffset(0, 86),
		Size = UDim2.new(1, 0, 1, -86),
		BackgroundColor3 = Color3.fromRGB(20, 16, 12),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		ZIndex = 36
	}, sheet)

	self:_trackHover(infoDim)
	infoDim.Activated:Connect(function()
		self:_setInfo(false)
	end)
	self._infoDim = infoDim

	local infoPaper = create("Frame", { -- inferred equivalent call
		Name = "InfoPaper",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = self._infoPos,
		Size = UDim2.fromOffset(640, 480),
		BackgroundColor3 = color12,
		BorderSizePixel = 0,
		Rotation = -1.3,
		Visible = false,
		Active = true,
		ZIndex = 38
	}, sheet)

	create("UICorner", { CornerRadius = UDim.new(0, 3) }, infoPaper) -- inferred equivalent call
	create("UIStroke", { Color = color13, Thickness = 2.5 }, infoPaper) -- inferred equivalent call
	create( -- inferred equivalent call
		"UIGradient",
		{
			Rotation = 90,
			Color = ColorSequence.new(Color3.fromRGB(230, 202, 154), color12)
		},
		infoPaper
	)
	self:_trackHover(infoPaper)
	self._infoPaper = infoPaper

	self._infoTitle = label(infoPaper, {
		Position = UDim2.fromOffset(26, 8),
		Size = UDim2.fromOffset(460, 50),
		Font = font,
		Text = "TOTAL SCORE?",
		TextSize = 42,
		TextTruncate = Enum.TextTruncate.None,
		Rotation = -1
	}, infoPaper)

	create("Frame", { -- inferred equivalent call
		Position = UDim2.fromOffset(30, 58),
		Size = UDim2.fromOffset(300, 5),
		BackgroundColor3 = color5,
		BorderSizePixel = 0,
		Rotation = -0.8
	}, infoPaper)

	local infoClose = create("TextButton", { -- inferred equivalent call
		Name = "InfoClose",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(0, 626, 0, 10),
		Size = UDim2.fromOffset(40, 40),
		BackgroundColor3 = color8,
		Text = "X",
		Font = Enum.Font.GothamBlack,
		TextSize = 20,
		TextColor3 = Color3.fromRGB(244, 232, 200),
		AutoButtonColor = true,
		Rotation = 4,
		ZIndex = 6
	}, infoPaper)

	create("UICorner", { CornerRadius = UDim.new(0, 4) }, infoClose) -- inferred equivalent call
	create("UIStroke", { Color = color3, Thickness = 2 }, infoClose) -- inferred equivalent call
	self:_trackHover(infoClose)
	infoClose.Activated:Connect(function()
		self:_setInfo(false)
	end)
	self._infoClose = infoClose

	local infoScroll = create("ScrollingFrame", { -- inferred equivalent call
		Name = "InfoList",
		Position = UDim2.fromOffset(26, 72),
		Size = UDim2.fromOffset(588, 392),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = color4,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.Never,
		ZIndex = 2
	}, infoPaper)

	create("UIListLayout", { Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder }, infoScroll) -- inferred equivalent call
	create("UIPadding", { PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 6) }, infoScroll) -- inferred equivalent call
	self._infoScroll = infoScroll

	self:_fillInfo()

	addTape(infoPaper, 120, 2, -6, color14, 96, 20, 8)
	addTape(infoPaper, 490, 4, 7, color15, 96, 20, 8)
	addTape(infoPaper, 14, 470, 35, color5, 70, 18, 8)

	addTape(sheet, 90, 4, -6, color15, 110, 22, 32)
	addTape(sheet, 610, 2, 7, color14, 110, 22, 32)
	addTape(sheet, 70, 594, 12, color5, 96, 20, 32)
	addTape(sheet, 650, 596, -10, color14, 96, 20, 32)
	coffeeRing(dropContent, 600, 150, 84, 1)
	addTape(sheet, 14, 44, -40, color14, 34, 11, 32)
	addTape(sheet, 708, 300, 75, color5, 36, 11, 32)
	addTape(sheet, 12, 300, 62, color15, 32, 10, 32)
	addTape(sheet, 708, 470, -70, color14, 34, 11, 32)
	addTape(sheet, 360, 596, 4, color13, 40, 11, 32)
	addTape(closeButton, 6, 6, -35, color14, 24, 9, 32)

	dropGui.Enabled = false
	dropGui.Active = false
end

function HallOfFameUI:_updateDropVirtual()
	local dropRows = self._dropRows
	local dropList = self._dropList

	if not (dropRows and dropList) then
		return
	end

	local y = dropList.CanvasPosition.Y
	local v6 = y - 300
	local v7 = y + 394 + 300

	for _, dropRow in ipairs(dropRows) do
		local shown

		if v6 < dropRow.top + dropRow.height then
			shown = dropRow.top < v7
		else
			shown = false
		end

		if shown == dropRow.shown then
			continue
		end

		dropRow.shown = shown

		if shown then
			if dropRow.built then
				for _, kid in ipairs(dropRow.kids) do
					kid.Visible = true
				end
			else
				dropRow.built = true
				populateRow(
					dropRow.frame,
					dropRow.entry,
					dropRow.index,
					dropRow.width,
					dropRow.height,
					dropRow.isYou,
					dropRow.opts
				)
				dropRow.kids = {}

				for _, guiObject in ipairs(dropRow.frame:GetChildren()) do
					if guiObject:IsA("GuiObject") then
						table.insert(dropRow.kids, guiObject)
					end
				end
			end
		elseif dropRow.built then
			for _, kid in ipairs(dropRow.kids) do
				kid.Visible = false
			end
		end
	end
end

function HallOfFameUI:_renderDrop()
	self._dropRows = {}

	for _, frame in ipairs(self._dropList:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	for _, label2 in ipairs(self._youHolder:GetChildren()) do
		if label2:IsA("TextLabel") or label2.Name == "YouRow" then
			label2:Destroy()
		end
	end

	local userId = Players.LocalPlayer and Players.LocalPlayer.UserId
	local v6 = self._tab == "freeplay"
	local v7 = nil
	local v8, you, v9

	if v6 then
		local v10 = self._fp[self._fpFilter]
		v8 = v10 and v10.Top or {}
		you = v10 and v10.You
		v9 = v10 ~= nil

		if v10 == nil then
			v7 = false
		else
			v7 = v10.Failed == true
		end
	else
		v8 = self._top100
		you = self._you
		v9 = true
	end

	local text = v6 and (v9 and (v7 and "Couldn't load. Tap a button to retry." or "No hits yet.") or "Loading...")
		or "No scores yet."

	if #v8 == 0 then
		local frame = create( -- inferred equivalent call
			"Frame",
			{ Size = UDim2.new(1, 0, 0, 120), BackgroundTransparency = 1, LayoutOrder = 1 },
			self._dropList
		)
		label(frame, {
			Size = UDim2.fromScale(1, 1),
			Font = font,
			Text = text,
			TextSize = 32,
			TextColor3 = color4,
			TextXAlignment = Enum.TextXAlignment.Center
		}, frame)
	else
		local top = 0

		for i, entry in ipairs(v8) do
			local special = v6 and i <= 5
			local height = special and 56 or 44
			local opts = {
				textSize = special and 28 or 24,
				scoreWidth = special and 190 or 170,
				ruled = true,
				special = special
			}

			self._dropRows[i] = {
				frame = newRowFrame(self._dropList, i, 630, height, opts),
				entry = entry,
				index = i,
				width = 630,
				height = height,
				isYou = entry.UserId == userId,
				opts = opts,
				top = top,
				built = false,
				shown = false
			}

			top = top + height + 2
		end

		self:_updateDropVirtual()
	end

	if not (you and (you.Score or 0) > 0) then
		label(self._youHolder, {
			Size = UDim2.fromScale(1, 1),
			Font = font,
			Text = v6 and "Play Free Play to get ranked." or "Play a song to get ranked.",
			TextSize = 26,
			TextXAlignment = Enum.TextXAlignment.Center
		}, self._youHolder)

		return
	end

	local localPlayer = Players.LocalPlayer
	local youRow = buildRow(self._youHolder, { -- inferred equivalent call
		Rank = you.Rank,
		UserId = userId,
		Name = localPlayer and (localPlayer.DisplayName ~= "" and localPlayer.DisplayName or localPlayer.Name or "You") or "You",
		Score = you.Score
	}, 1, 630, 58, false, {
		textSize = 26,
		rankWidth = 76,
		rankPrefix = you.Rank and "#" or "",
		scoreWidth = 190
	})

	youRow.Name = "YouRow"
	youRow.Position = UDim2.fromOffset(0, 0)
end

HallOfFameUI.MoreUnlockPlayers = 100

function HallOfFameUI.SetRankedCount(_, _) end

function HallOfFameUI:SetTop5(p)
	self._top5 = typeof(p) == "table" and p or {}
	self:_renderBanner()
end

function HallOfFameUI:SetYou(p)
	self._you = typeof(p) == "table" and p or nil
	self:_renderBanner()

	if self._dropOpen and self._tab == "score" then
		self:_renderDrop()
	end
end

function HallOfFameUI:SetTop100(p, you)
	self._top100 = typeof(p) == "table" and p or {}

	if typeof(you) == "table" then
		self._you = you
		self:_renderBanner()
	end

	if self._dropOpen and self._tab == "score" then
		self:_renderDrop()
	end
end

function HallOfFameUI:GetTab()
	return self._tab
end

function HallOfFameUI:GetFreePlayFilter()
	return self._fpFilter
end

function HallOfFameUI:_clearHover(p)
	if p and self._hovered[p] then
		self._hovered[p] = nil
		self._hoverCount = math.max(0, self._hoverCount - 1)
	end
end

function HallOfFameUI:_buildTabs(parent)
	self._tabs = {}
	local function makeTab(p, text, p2, width, tilt)
		local button = create("TextButton", { -- inferred equivalent call
			Name = "Tab_" .. p,
			Position = UDim2.fromOffset(p2, 12),
			Size = UDim2.fromOffset(width, 50),
			BackgroundColor3 = color12,
			Text = text,
			Font = Enum.Font.Gotham,
			TextSize = 20,
			TextColor3 = color3,
			AutoButtonColor = false,
			ZIndex = 12
		}, parent)

		create("UICorner", { CornerRadius = UDim.new(0, 3) }, button) -- inferred equivalent call
		local stroke = create("UIStroke", { Color = color13, Thickness = 1.5 }, button) -- inferred equivalent call
		addTape(button, width / 2, 1, tilt * 2, color14, 40, 11, 13)
		self:_trackHover(button)
		button.Activated:Connect(function()
			self:SetTab(p)
		end)
		self._tabs[p] = {
			Button = button,
			Stroke = stroke,
			X = p2,
			Width = width,
			Tilt = tilt
		}
	end
	makeTab("score", "SCORE", 334, 108, -1.5)
	makeTab("freeplay", "FREEPLAY", 448, 120, 1.5)

	local chipRow = create("Frame", { -- inferred equivalent call
		Name = "FilterRow",
		Position = UDim2.fromOffset(264, 82),
		Size = UDim2.fromOffset(434, 28),
		BackgroundTransparency = 1,
		Visible = false
	}, parent)

	self._chipRow = chipRow
	self._chips = {}

	for i, v6 in ipairs(v3) do
		local button = create("TextButton", { -- inferred equivalent call
			Name = "Chip_" .. v6.key,
			Position = UDim2.fromOffset((i - 1) * 73, 0),
			Size = UDim2.fromOffset(68, 28),
			BackgroundColor3 = color12,
			Text = v6.text,
			Font = Enum.Font.Gotham,
			TextSize = 16,
			TextColor3 = color3,
			AutoButtonColor = false,
			Rotation = (i % 2 == 0 and 1 or -1) * 0.8,
			ZIndex = 12
		}, chipRow)

		create("UICorner", { CornerRadius = UDim.new(0, 3) }, button) -- inferred equivalent call
		local stroke = create("UIStroke", { Color = color13, Thickness = 1.5 }, button) -- inferred equivalent call
		self:_trackHover(button)
		button.Activated:Connect(function()
			self:SetFreePlayFilter(v6.key)
		end)
		self._chips[v6.key] = { Button = button, Stroke = stroke }
	end

	self:_applyTabStyle()
end

function HallOfFameUI:_applyTabStyle()
	local visible = self._tab == "freeplay"

	for k, v6 in pairs(self._tabs or {}) do
		local v7 = k == self._tab
		v6.Button.BackgroundColor3 = v7 and color12 or color2
		v6.Button.TextColor3 = color3
		v6.Button.Position = UDim2.fromOffset(v6.X, v7 and 12 or 22)
		v6.Button.Size = UDim2.fromOffset(v6.Width, v7 and 50 or 40)
		v6.Button.Rotation = v7 and 0 or v6.Tilt
		v6.Stroke.Color = v7 and color5 or color13
		v6.Stroke.Thickness = v7 and 3 or 1.5
	end

	if self._dropSubtitle then
		self._dropSubtitle.Text = visible and "FREEPLAY HITS" or "NOISEMAKERS"
	end

	if self._chipRow then
		self._chipRow.Visible = visible
	end

	for k, v6 in pairs(self._chips or {}) do
		local v7 = k == self._fpFilter
		v6.Button.BackgroundColor3 = v7 and color10 or color12
		v6.Button.TextColor3 = color3
		v6.Stroke.Color = v7 and color5 or color13
		v6.Stroke.Thickness = v7 and 2.5 or 1.5
	end
end

function HallOfFameUI:_requestFreePlay()
	if self._onFreePlay then
		self._onFreePlay(self._fpFilter)
	end
end

function HallOfFameUI:SetTab(tab)
	if self._destroyed or tab ~= "score" and tab ~= "freeplay" or self._tab == tab then
		return
	end

	self._tab = tab
	self:_setInfo(false, true)
	self:_fillInfo()

	if tab ~= "freeplay" then
		for _, v6 in pairs(self._chips or {}) do
			self:_clearHover(v6.Button)
		end
	end

	self:_applyTabStyle()
	self._dropList.CanvasPosition = Vector2.new(0, 0)
	self:_renderDrop()

	if tab == "freeplay" then
		self:_requestFreePlay()
	end
end

function HallOfFameUI:SetFreePlayFilter(fpFilter)
	if self._destroyed or not self._chips or not self._chips[fpFilter] or self._fpFilter == fpFilter then
		return
	end

	self._fpFilter = fpFilter
	self:_applyTabStyle()
	self._dropList.CanvasPosition = Vector2.new(0, 0)
	self:_renderDrop()
	self:_requestFreePlay()
end

function HallOfFameUI:SetFreePlay(value, top, p)
	if self._destroyed or type(value) ~= "string" then
		return
	end

	if typeof(top) == "table" then
		self._fp[value] = {
			Top = top,
			You = typeof(p) == "table" and p or nil
		}
	else
		self._fp[value] = { Top = {}, Failed = true }
	end

	if self._dropOpen and self._tab == "freeplay" and self._fpFilter == value then
		self:_renderDrop()
	end
end

function HallOfFameUI:_fillInfo()
	local infoScroll = self._infoScroll

	if not infoScroll then
		return
	end

	local v6 = v4[self._tab] or v4.score

	if self._infoTitle then
		self._infoTitle.Text = v6.Title
	end

	for _, label2 in ipairs(infoScroll:GetChildren()) do
		if label2:IsA("TextLabel") then
			label2:Destroy()
		end
	end

	infoScroll.CanvasPosition = Vector2.new(0, 0)
	local layoutOrder = 0

	for _, section in ipairs(v6.Sections) do
		local layoutOrder2 = layoutOrder + 1
		label(infoScroll, {
			Size = UDim2.new(1, 0, 0, 30),
			Font = font,
			Text = section[1],
			TextSize = 22,
			TextColor3 = color5,
			TextTruncate = Enum.TextTruncate.None,
			LayoutOrder = layoutOrder2,
			ZIndex = 3
		}, infoScroll)

		layoutOrder = layoutOrder2 + 1
		local parent = label(infoScroll, {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = section[2],
			TextSize = 20,
			TextWrapped = true,
			RichText = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextTruncate = Enum.TextTruncate.None,
			LayoutOrder = layoutOrder,
			ZIndex = 3
		}, infoScroll)

		create("UIPadding", { PaddingBottom = UDim.new(0, 8) }, parent) -- inferred equivalent call
	end
end

function HallOfFameUI:IsDropOpen()
	return self._dropOpen
end

function HallOfFameUI:_setInfo(infoOpen, p)
	if self._destroyed or not self._infoPaper or not p and infoOpen == self._infoOpen then
		return
	end

	self._infoOpen = infoOpen
	self._infoToken += 1
	local infoToken = self._infoToken
	local infoPaper = self._infoPaper
	local infoDim = self._infoDim

	for _, v6 in ipairs({ infoPaper, infoDim, self._infoClose }) do
		if not self._hovered[v6] then
			continue
		end

		self._hovered[v6] = nil
		self._hoverCount = math.max(0, self._hoverCount - 1)
	end

	if infoOpen then
		infoDim.Visible = true
		infoPaper.Visible = true
		infoDim.BackgroundTransparency = 1
		infoPaper.Position = self._infoPos + UDim2.fromOffset(0, 60)
		infoPaper.Rotation = 3
		self._infoScroll.CanvasPosition = Vector2.new(0, 0)
		TweenService:Create(infoDim, TweenInfo.new(0.2), { BackgroundTransparency = 0.45 }):Play()
		TweenService:Create(infoPaper, TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = self._infoPos,
			Rotation = -1.3
		}):Play()
	else
		local function hide() -- 2 equivalent calls inferred from this helper
			infoDim.Visible = false
			infoPaper.Visible = false
		end

		if p then
			hide() -- inferred equivalent call
		else
			TweenService:Create(infoDim, TweenInfo.new(0.18), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(infoPaper, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = self._infoPos + UDim2.fromOffset(0, 60),
				Rotation = 3
			}):Play()
			task.delay(0.2, function()
				if not self._destroyed and self._infoToken == infoToken and not self._infoOpen then
					hide() -- inferred equivalent call
				end
			end)
		end
	end
end

function HallOfFameUI:CloseInfo(): boolean
	if not self._infoOpen then
		return false
	end

	self:_setInfo(false)
	return true
end

function HallOfFameUI:IsInfoOpen()
	return self._infoOpen
end

function HallOfFameUI:OpenDrop()
	if self._dropOpen or self._destroyed then
		return
	end

	self._dropOpen = true
	self._token += 1
	local token = self._token

	self._sheet.Size = UDim2.fromOffset(720, 28)
	self._dropContent.Visible = false
	self._closeButton.Visible = false
	self._helpButton.Visible = false
	self:_setInfo(false, true)
	self._dropGui.Enabled = true
	self._dropGui.Active = true

	if self._dropPart then
		self._dropPart.CanQuery = true
	end

	self:_renderDrop()
	TweenService:Create(self._sheet, tweenInfo, { Size = UDim2.fromOffset(720, 600) }):Play()

	if self._onDropOpened then
		self._onDropOpened()
	end

	task.delay(0.22, function()
		if self._destroyed or self._token ~= token or not self._dropOpen then
			return
		end

		self._dropContent.Visible = true
		self._closeButton.Visible = true
		self._helpButton.Visible = true
	end)
end

function HallOfFameUI:CloseDrop(p)
	if not self._dropOpen then
		return
	end

	self._dropOpen = false
	self._token += 1
	local token = self._token
	self._dropContent.Visible = false
	self._closeButton.Visible = false
	self._helpButton.Visible = false
	self:_setInfo(false, true)
	self._dropGui.Active = false

	local function finish() -- 2 equivalent calls inferred from this helper
		self._dropGui.Enabled = false

		if self._dropPart then
			self._dropPart.CanQuery = false
		end
	end

	if p then
		self._sheet.Size = UDim2.fromOffset(720, 28)
		finish() -- inferred equivalent call
	else
		TweenService:Create(self._sheet, tweenInfo2, { Size = UDim2.fromOffset(720, 28) }):Play()
		task.delay(tweenInfo2.Time, function()
			if self._destroyed or self._token ~= token then
				return
			end

			finish() -- inferred equivalent call
		end)
	end

	self:ResetHover()

	if self._onDropClosed then
		self._onDropClosed(p == true)
	end
end

function HallOfFameUI:IsInteractiveHovered(): boolean
	return self._hoverCount > 0
end

function HallOfFameUI:ResetHover()
	self._hovered = {}
	self._hoverCount = 0
end

function HallOfFameUI:Destroy()
	self._destroyed = true

	if self._bannerRoot then
		self._bannerRoot:Destroy()
	end

	if self._sheet then
		self._sheet:Destroy()
	end
end

return HallOfFameUI