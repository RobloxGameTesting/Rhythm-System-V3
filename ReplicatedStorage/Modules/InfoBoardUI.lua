local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local InfoBoardUI = {}
InfoBoardUI.__index = InfoBoardUI

InfoBoardUI.CanvasSize = Vector2.new(700, 990)

InfoBoardUI.OpenRect = { X = 30, Y = 45, W = 640, H = 900 }

local tweenInfo = TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local color = Color3.fromRGB(247, 240, 212)
local color2 = Color3.fromRGB(225, 211, 170)
local color3 = Color3.fromRGB(26, 22, 20)
local color4 = Color3.fromRGB(78, 66, 56)
local color5 = Color3.fromRGB(176, 32, 36)
local color6 = Color3.fromRGB(66, 98, 168)
local color7 = Color3.fromRGB(198, 62, 62)
local color8 = Color3.fromRGB(34, 34, 38)
local color9 = Color3.fromRGB(244, 232, 200)
Color3.fromRGB(46, 112, 64)

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

local v = {
	map = {
		paper = Color3.fromRGB(252, 226, 116),
		edge = Color3.fromRGB(190, 152, 48),
		ink = color3
	},
	announce = {
		paper = Color3.fromRGB(246, 198, 204),
		edge = Color3.fromRGB(160, 84, 96),
		ink = color3
	},
	log = {
		paper = Color3.fromRGB(255, 252, 240),
		edge = Color3.fromRGB(120, 92, 52),
		ink = color3,
		lined = true
	},
	how = {
		paper = Color3.fromRGB(218, 186, 140),
		edge = Color3.fromRGB(110, 78, 40),
		ink = color3
	},
	gig = { paper = Color3.fromRGB(28, 26, 28), edge = Color3.fromRGB(176, 32, 36), ink = color9 }
}

local v2 = {
	{
		Id = "map",
		Title = "MAP INFO",
		X = 62,
		Y = 172,
		W = 292,
		H = 232,
		Rot = -2.6,
		Tapes = {
			{ 0.12, -3, 16 },
			{ 0.82, 8, 20 }
		}
	},
	{
		Id = "announce",
		Title = "ANNOUNCE!",
		X = 376,
		Y = 158,
		W = 288,
		H = 252,
		Rot = 2.3,
		Tapes = {
			{ 0.5, 4, 6 },
			{ 0.93, -12, 214 }
		}
	},
	{
		Id = "log",
		Title = "UPDATE LOG",
		X = 56,
		Y = 432,
		W = 304,
		H = 302,
		Rot = 1.7,
		Tapes = {
			{ 0.08, 10, 14 },
			{ 0.9, -5, 12 }
		}
	},
	{
		Id = "how",
		Title = "HOW TO PLAY",
		X = 382,
		Y = 444,
		W = 282,
		H = 262,
		Rot = -1.9,
		Tapes = {
			{ 0.3, -7, 8 },
			{ 0.78, 6, 10 }
		}
	},
	{
		Id = "gig",
		Title = "COMMUNITY GIG BOARD",
		X = 92,
		Y = 756,
		W = 506,
		H = 212,
		Rot = -1.1,
		Tapes = {
			{ 0.05, 12, 12 },
			{ 0.5, -2, 4 },
			{ 0.95, -9, 14 }
		}
	}
}

local v3 = {}

for _, v4 in ipairs(v2) do
	v3[v4.Id] = v4
end

local v4 = {
	{
		"1",
		"Grab an instrument",
		"Walk up to a free stand on any stage and use the prompt. The MAP INFO paper shows where there is room."
	},
	{
		"2",
		"Pick a song",
		"Press G to open the Song List, choose a song and press Play. Too hard? The Difficulty button has Medium, Easy and Baby."
	},
	{ "3", "Hit the notes", "Press X C V B N on the beat (Bass: X C V B). Hold the key on long notes." },
	{ "4", "Star Power", "When the meter is ready, press Space or H to activate it." },
	{ "5", "Just jam", "Right Shift = Free Play, no chart needed. Backspace puts the instrument back." }
}

local v5 = {
	{
		"GETTING STARTED",
		{
			"Every stage has six stands: Rhythm Guitar, Lead Guitar, Bass, Drums, Keyboard and Piano. Stages are MAIN STAGE, BASEMENT, OPEN GARAGE and ROOFTOP.",
			"Walk to a free stand and use the prompt to pick the instrument up. The MAP INFO paper shows how busy each stage is: MAIN STAGE 3/6 means 3 of the 6 instruments are taken.",
			"Press Backspace to put your instrument back."
		}
	},
	{
		"PLAYING A SONG",
		{
			"Hold an instrument and press G to open the Song List. Every song has a difficulty color.",
			"Notes fall down the lanes. Press the matching key when a note reaches the hit line.",
			"Keys: X C V B N for the 5 lanes (Green, Red, Yellow, Blue, Orange). Bass has 4 lanes: X C V B.",
			"Drums use the same keys for Kick, Snare, Hi-Hat, Perc and Cymbal. Double Pedal (Z, or M when flipped) is an optional drum setting.",
			"Long notes: keep the key held until the note ends.",
			"Your timing is judged Perfect, Great, Good or OK. A wrong press breaks your streak.",
			"Finish a song without a miss for a Full Combo. Chain Full Combos on the same song and you get a 2x, 3x... notice.",
			"When the Star Power meter is ready, press Space or H to activate it (the main key is changeable in Settings > Controls; on a controller it is SELECT).",
			"After the song you get a results screen. Your best scores appear on the Song Catalog board."
		}
	},
	{
		"TOO HARD?",
		{
			"Open the Difficulty button in the Song List header. Presets: Medium, Easy and Baby. You can also tune note speed, note density and lane count.",
			"Easier settings count for less in your total score (Medium x0.9, Easy x0.75, Baby x0.55).",
			"Five keys too much? Switch to a smaller key mode from the key-mode dropdown (2-Key uses X and C by default, changeable in Settings).",
			"On mobile, on-screen buttons replace the keyboard."
		}
	},
	{
		"FREE PLAY",
		{
			"Press Right Shift (or pick Free Play in the key-mode dropdown) to play freely without a chart.",
			"Guitars and Bass get a virtual fretboard mapped across your keyboard rows. Drums keep X C V B N."
		}
	},
	{
		"PLAYING TOGETHER",
		{
			"Players on the same stage form a band and play their own parts of the same song.",
			"Want a proper band? Open the Song List with an instrument in hand and invite the others on stage. They Join and Ready up, then the host presses Play.",
			"Empty parts can be covered by a backing track: tick Fill empty instruments with backing track in the Song List, or use the Backing Track button and the laptop on stage."
		}
	},
	{
		"STUDIOS",
		{
			"Want your own space? Use the Studio Hub prompt on the dummy sitting at the drums to create a Public or Private studio for up to 8 players.",
			"Private studios ask the owner before you can join. Owners can invite friends and manage the room from the Studio Manager button.",
			"Studios show up in the second half of the MAP INFO paper."
		}
	},
	{
		"LOOK AND PROFILE",
		{
			"The Equipment button (under Settings) lets you pick guitar and bass skins and your highway look.",
			"Click a player standing close to you to open their Player Card: songs played, total score, favorite genres and more."
		}
	},
	{
		"THE BOARD",
		{
			"NOISEMAKERS (top banner): the ranking of everyone's total best score. Tap MORE for the top 100.",
			"SONG CATALOG: every song with favorites and top scores. NOTES: leave a note for everyone and reply to others.",
			"BACKSTAGE: this paper. The yellow sticker shows how many players are online right now and today's peak.",
			"While looking at one paper, click another paper to jump straight to it.",
			"Press Q or Backspace, or the CLOSE button, to leave the board."
		}
	}
}

local function create(className, items, parent) -- 80 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function makeLabel(parent, items)
	local v6 = {
		BackgroundTransparency = 1,
		Font = font2,
		TextSize = 22,
		TextColor3 = color3,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextTruncate = Enum.TextTruncate.AtEnd
	}

	for k, item in pairs(items) do
		v6[k] = item
	end

	return create("TextLabel", v6, parent) -- inferred equivalent call
end

local function esc(p) -- 3 equivalent calls inferred from this helper
	return (string.gsub(tostring(p), "[&<>\"']", {
		["&"] = "&amp;",
		["<"] = "&lt;",
		[">"] = "&gt;",
		["\""] = "&quot;",
		["'"] = "&apos;"
	}))
end

local function hex(color10) -- 1 equivalent call inferred from this helper
	return string.format(
		"#%02X%02X%02X",
		math.floor(color10.R * 255 + 0.5),
		math.floor(color10.G * 255 + 0.5),
		(math.floor(color10.B * 255 + 0.5))
	)
end

local v6 = hex(color5) -- inferred equivalent call

local function formatCount(value)
	if type(value) ~= "number" or value ~= value then
		return "-"
	end

	local v7 = tostring((math.max(0, (math.floor(value + 0.5)))))
	local v8 = string.reverse(v7)
	local v9 = string.gsub(v8, "(%d%d%d)", "%1,")
	local v10 = string.reverse(v9)

	if string.sub(v10, 1, 1) == "," then
		return (string.sub(v10, 2))
	end

	return v10
end

local function shortDate(time) -- 1 equivalent call inferred from this helper
	local success, result = pcall(function()
		return os.date("!%b %d", tonumber(time) or 0)
	end)

	return success and result or ""
end

local function relativeTime(time)
	local v7 = math.max(0, Workspace:GetServerTimeNow() - (tonumber(time) or 0))

	if v7 < 60 then
		return "just now"
	end

	if v7 < 3600 then
		return string.format("%dm ago", (math.floor(v7 / 60)))
	end

	if v7 < 86400 then
		return string.format("%dh ago", (math.floor(v7 / 3600)))
	end

	return string.format("%dd ago", (math.floor(v7 / 86400)))
end

local function isNewSong(data): boolean -- 1 equivalent call inferred from this helper
	return data.Kind == "song" and Workspace:GetServerTimeNow() - (tonumber(data.Time) or 0) < 604800
end

local function addTape(parent, p, rotation, zIndex, p2)
	local parent2 = create("Frame", { -- inferred equivalent call
		Name = "Tape",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(p, 0, 0, -4),
		Size = UDim2.fromOffset(78, 18),
		Rotation = rotation,
		BackgroundColor3 = p2 and color5 or color8,
		BackgroundTransparency = 0.06,
		BorderSizePixel = 0,
		ZIndex = zIndex
	}, parent)

	create("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Transparency = 0.6, Thickness = 1 }, parent2) -- inferred equivalent call
	return parent2
end

function InfoBoardUI.new(gui, options)
	local v7 = options or {}
	local self = setmetatable({}, InfoBoardUI)
	self._gui = gui
	self._onOpened = v7.onOpened
	self._onClosed = v7.onClosed
	self._destroyed = false
	self._hoverCount = 0
	self._hovered = {}
	self._scraps = {}
	self._map = { Players = 0, MaxPlayers = 0, Stages = {} }
	self._board = {
		Announcements = {},
		Log = {},
		Gig = { EventTitle = "", EventText = "", Challenge = "" }
	}
	self._openId = nil
	self._opening = false
	self._howFull = false
	self._token = 0
	self._onlineValue = nil
	self._peakValue = nil

	self:_buildPaper()

	for _, v8 in ipairs(v2) do
		self:_buildScrap(v8)
	end

	self:_buildOverlay()
	self:_renderAllSmall()
	return self
end

function InfoBoardUI:_buildPaper()
	local root = create("Frame", { -- inferred equivalent call
		Name = "Root",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ClipsDescendants = true
	}, self._gui)
	self._root = root
	create("UIGradient", { -- inferred equivalent call
		Rotation = 90,
		Color = ColorSequence.new(color, color2)
	}, root)

	for i = 176, 974, 34 do
		create("Frame", { -- inferred equivalent call
			Position = UDim2.fromOffset(0, i),
			Size = UDim2.new(1, 0, 0, 2),
			BackgroundColor3 = color6,
			BackgroundTransparency = 0.72,
			BorderSizePixel = 0,
			ZIndex = 1
		}, root)
	end

	create("Frame", { -- inferred equivalent call
		Position = UDim2.fromOffset(46, 0),
		Size = UDim2.new(0, 3, 1, 0),
		BackgroundColor3 = color7,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		ZIndex = 1
	}, root)

	for _, v7 in ipairs({ 150, 495, 840 }) do
		local parent = create("Frame", { -- inferred equivalent call
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(22, v7),
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = Color3.fromRGB(70, 60, 50),
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			ZIndex = 1
		}, root)

		create("UICorner", { CornerRadius = UDim.new(1, 0) }, parent) -- inferred equivalent call
	end

	local parent = create("Frame", { -- inferred equivalent call
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(612, 596),
		Size = UDim2.fromOffset(96, 96),
		BackgroundTransparency = 1,
		ZIndex = 2
	}, root)

	create("UICorner", { CornerRadius = UDim.new(1, 0) }, parent) -- inferred equivalent call
	create("UIStroke", { Color = Color3.fromRGB(150, 98, 52), Transparency = 0.62, Thickness = 5 }, parent) -- inferred equivalent call

	makeLabel(root, {
		Name = "Title",
		Position = UDim2.fromOffset(64, 18),
		Size = UDim2.fromOffset(400, 88),
		Font = font,
		Text = "Backstage:",
		TextSize = 70,
		TextTruncate = Enum.TextTruncate.None,
		TextColor3 = color3,
		Rotation = -1.5,
		ZIndex = 3
	}, root)

	create("Frame", { -- inferred equivalent call
		Position = UDim2.fromOffset(70, 108),
		Size = UDim2.fromOffset(330, 6),
		BackgroundColor3 = color5,
		BorderSizePixel = 0,
		Rotation = -1.2,
		ZIndex = 3
	}, root)

	create("Frame", { -- inferred equivalent call
		Position = UDim2.fromOffset(88, 120),
		Size = UDim2.fromOffset(250, 4),
		BackgroundColor3 = color5,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		Rotation = 0.8,
		ZIndex = 3
	}, root)

	makeLabel(root, {
		Position = UDim2.fromOffset(404, 12),
		Size = UDim2.fromOffset(270, 34),
		Font = font,
		Text = "PLAY IT LOUD!!",
		TextSize = 30,
		TextColor3 = color5,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.None,
		Rotation = 4,
		ZIndex = 3
	}, root)

	makeLabel(root, {
		Position = UDim2.fromOffset(66, 128),
		Size = UDim2.fromOffset(420, 30),
		Text = "what's on, what's new, how to jam",
		TextSize = 22,
		TextColor3 = color4,
		Rotation = -0.8,
		ZIndex = 3
	}, root)

	local parent2 = create("Frame", { -- inferred equivalent call
		Name = "OnlineSticker",
		Position = UDim2.fromOffset(398, 50),
		Size = UDim2.fromOffset(292, 112),
		BackgroundColor3 = Color3.fromRGB(255, 214, 51),
		BorderSizePixel = 0,
		Rotation = -2.4,
		ZIndex = 4
	}, root)

	create("UICorner", { CornerRadius = UDim.new(0, 3) }, parent2) -- inferred equivalent call
	create("UIStroke", { Color = color3, Thickness = 2 }, parent2) -- inferred equivalent call

	local parent3 = create("Frame", { -- inferred equivalent call
		Position = UDim2.fromOffset(14, 15),
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = Color3.fromRGB(36, 176, 72),
		BorderSizePixel = 0,
		ZIndex = 5
	}, parent2)

	create("UICorner", { CornerRadius = UDim.new(1, 0) }, parent3) -- inferred equivalent call
	create("UITextSizeConstraint", { MinTextSize = 12, MaxTextSize = 23 }, makeLabel(parent2, { -- inferred equivalent call
		Position = UDim2.fromOffset(32, 8),
		Size = UDim2.fromOffset(112, 28),
		Text = "ONLINE NOW",
		TextScaled = true,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextColor3 = color3,
		TextTruncate = Enum.TextTruncate.None,
		ZIndex = 5
	}, parent2))
	self._onlineValue = makeLabel(parent2, {
		Position = UDim2.fromOffset(10, 38),
		Size = UDim2.fromOffset(132, 68),
		Font = font,
		Text = "-",
		AutoLocalize = false,
		TextScaled = true,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextColor3 = color3,
		TextTruncate = Enum.TextTruncate.None,
		ZIndex = 5
	}, parent2)

	create("UITextSizeConstraint", { MinTextSize = 20, MaxTextSize = 58 }, self._onlineValue) -- inferred equivalent call

	create("Frame", { -- inferred equivalent call
		Position = UDim2.fromOffset(148, 12),
		Size = UDim2.fromOffset(2, 88),
		BackgroundColor3 = color3,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		ZIndex = 5
	}, parent2)

	create("UITextSizeConstraint", { MinTextSize = 12, MaxTextSize = 23 }, makeLabel(parent2, { -- inferred equivalent call
		Position = UDim2.fromOffset(160, 8),
		Size = UDim2.fromOffset(126, 28),
		Text = "PEAK TODAY",
		TextScaled = true,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextColor3 = color3,
		TextTruncate = Enum.TextTruncate.None,
		ZIndex = 5
	}, parent2))
	self._peakValue = makeLabel(parent2, {
		Position = UDim2.fromOffset(158, 38),
		Size = UDim2.fromOffset(126, 68),
		Font = font,
		Text = "-",
		AutoLocalize = false,
		TextScaled = true,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextColor3 = color5,
		TextTruncate = Enum.TextTruncate.None,
		ZIndex = 5
	}, parent2)

	create("UITextSizeConstraint", { MinTextSize = 20, MaxTextSize = 58 }, self._peakValue) -- inferred equivalent call

	for _, v7 in ipairs({
		{ 12, 2, -30, Color3.fromRGB(196, 196, 202) },
		{ 282, 110, 24, Color3.fromRGB(186, 156, 108) }
	}) do
		create("Frame", { -- inferred equivalent call
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(v7[1], v7[2]),
			Size = UDim2.fromOffset(58, 18),
			Rotation = v7[3],
			BackgroundColor3 = v7[4],
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			ZIndex = 6
		}, parent2)
	end
end

function InfoBoardUI:_trackHover(p)
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

function InfoBoardUI:_buildScrap(data)
	local v7 = v[data.Id]
	local holder = create("Frame", { -- inferred equivalent call
		Name = "Scrap_" .. data.Id,
		Position = UDim2.fromOffset(data.X, data.Y),
		Size = UDim2.fromOffset(data.W, data.H),
		Rotation = data.Rot,
		BackgroundTransparency = 1,
		ZIndex = 5
	}, self._root)
	local scale = create("UIScale", { Scale = 1 }, holder) -- inferred equivalent call

	local parent = create("Frame", { -- inferred equivalent call
		Position = UDim2.fromOffset(6, 8),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.72,
		BorderSizePixel = 0,
		ZIndex = 1
	}, holder)

	create("UICorner", { CornerRadius = UDim.new(0, 3) }, parent) -- inferred equivalent call

	local parent2 = create("Frame", { -- inferred equivalent call
		Name = "Body",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = v7.paper,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 2
	}, holder)

	create("UICorner", { CornerRadius = UDim.new(0, 3) }, parent2) -- inferred equivalent call
	create("UIStroke", { -- inferred equivalent call
		Color = v7.edge,
		Thickness = data.Id == "gig" and 3 or 1.5
	}, parent2)

	if v7.lined then
		for i = 56, data.H, 28 do
			create("Frame", { -- inferred equivalent call
				Position = UDim2.fromOffset(0, i),
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = color6,
				BackgroundTransparency = 0.7,
				BorderSizePixel = 0,
				ZIndex = 2
			}, parent2)
		end

		create("Frame", { -- inferred equivalent call
			Position = UDim2.fromOffset(26, 0),
			Size = UDim2.new(0, 2, 1, 0),
			BackgroundColor3 = color7,
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			ZIndex = 2
		}, parent2)
	end

	local content = create( -- inferred equivalent call
		"Frame",
		{ Name = "Content", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 3 },
		parent2
	)

	for i, tape in ipairs(data.Tapes) do
		local v8 = tape[1]
		local rotation = tape[2]
		local v9

		if data.Id == "announce" and i == 2 then
			v9 = true
		elseif data.Id == "gig" then
			v9 = i == 2
		else
			v9 = false
		end

		local parent3 = addTape(holder, v8, rotation, 6, v9)

		if tape[3] and tape[3] > 100 then
			parent3.Position = UDim2.new(tape[1], 0, 1, 4)
		end
	end

	local click = create("TextButton", { -- inferred equivalent call
		Name = "Click",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 10
	}, holder)

	self:_trackHover(click)
	click.MouseEnter:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.12), { Scale = 1.035 }):Play()
		TweenService:Create(holder, TweenInfo.new(0.12), {
			Rotation = data.Rot * 0.5
		}):Play()
	end)
	click.MouseLeave:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.12), { Scale = 1 }):Play()
		TweenService:Create(holder, TweenInfo.new(0.12), { Rotation = data.Rot }):Play()
	end)
	click.Activated:Connect(function()
		self:Open(data.Id)
	end)

	self._scraps[data.Id] = { Holder = holder, Content = content, Scale = scale, Click = click }
end

local function clear(instance) -- 6 equivalent calls inferred from this helper
	for _, child in ipairs(instance:GetChildren()) do
		child:Destroy()
	end
end

local function smallTitle(content, text, p)
	return (makeLabel(content, {
		Name = "Title",
		Position = UDim2.fromOffset(16, 14),
		Size = UDim2.new(1, -32, 0, 36),
		Font = font,
		Text = text,
		TextSize = 30,
		TextColor3 = p or color3
	}, content))
end

function InfoBoardUI:_renderMapSmall()
	local content = self._scraps.map.Content
	clear(content) -- inferred equivalent call
	smallTitle(content, "MAP INFO")
	makeLabel(content, {
		Position = UDim2.fromOffset(18, 52),
		Size = UDim2.new(1, -36, 0, 28),
		Text = string.format("PLAYERS  %d / %d", self._map.Players or 0, self._map.MaxPlayers or 0),
		AutoLocalize = false,
		TextSize = 24,
		Font = font,
		TextColor3 = color5
	}, content)

	local v7 = {}

	for _, v8 in ipairs(self._map.Stages or {}) do
		if string.sub(string.upper((tostring(v8.Name))), 1, 6) == "STUDIO" then
			continue
		end

		table.insert(v7, v8)
	end

	local v8 = math.min(#v7, 3)

	for i = 1, v8 do
		local v9 = v7[i]
		local v10 = (i - 1) * 30 + 86
		makeLabel(content, {
			Position = UDim2.fromOffset(18, v10),
			Size = UDim2.fromOffset(190, 28),
			Text = tostring(v9.Name),
			AutoLocalize = false,
			TextSize = 23
		}, content)

		makeLabel(content, {
			Position = UDim2.new(1, -118, 0, v10),
			Size = UDim2.fromOffset(98, 28),
			Text = string.format("%d/%d", v9.Used or 0, v9.Cap or 0),
			AutoLocalize = false,
			TextSize = 25,
			Font = font,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextColor3 = (v9.Used or 0) > 0 and color5 or color4
		}, content)
	end

	if #v7 == 0 then
		makeLabel(
			content,
			{
				Position = UDim2.fromOffset(18, 92),
				Size = UDim2.new(1, -36, 0, 28),
				Text = "no stages found",
				TextColor3 = color4
			},
			content
		)
	end

	local count = 0
	local count2 = 0

	for _, v9 in ipairs(self._map.Stages or {}) do
		if string.sub(string.upper((tostring(v9.Name))), 1, 6) ~= "STUDIO" then
			continue
		end

		count += 1

		if (v9.Used or 0) > 0 then
			count2 += 1
		end
	end

	if count > 0 then
		makeLabel(content, {
			Position = UDim2.fromOffset(18, math.max(v8, 1) * 30 + 86),
			Size = UDim2.new(1, -36, 0, 22),
			Font = font,
			Text = count2 > 0 and string.format("STUDIOS  %d/%d busy", count2, count) or string.format("STUDIOS  all %d free", count),
			AutoLocalize = false,
			TextSize = 20,
			TextColor3 = count2 > 0 and color5 or color4
		}, content)
	end

	makeLabel(content, {
		Position = UDim2.new(0, 18, 1, -32),
		Size = UDim2.new(1, -36, 0, 24),
		Text = v8 < #v7 and string.format("+%d more  -  tap for all >", #v7 - v8) or "tap for all >",
		AutoLocalize = #v7 <= v8,
		TextSize = 19,
		TextColor3 = color4
	}, content)
end

function InfoBoardUI:_renderAnnounceSmall()
	local content = self._scraps.announce.Content
	clear(content) -- inferred equivalent call
	smallTitle(content, "ANNOUNCE!", color5)
	local announcement = self._board.Announcements[1]

	if not announcement then
		makeLabel(content, {
			Position = UDim2.fromOffset(18, 64),
			Size = UDim2.new(1, -36, 0, 120),
			Text = "Nothing posted. Stay loud.",
			TextSize = 26,
			TextWrapped = true,
			TextColor3 = color4
		}, content)

		return
	end

	local text = announcement.Title == "" and "ANNOUNCEMENT" or announcement.Title or "ANNOUNCEMENT"
	makeLabel(content, {
		Position = UDim2.fromOffset(18, 52),
		Size = UDim2.new(1, -36, 0, 28),
		Font = font,
		Text = text,
		TextSize = 23
	}, content)

	makeLabel(content, {
		Position = UDim2.fromOffset(18, 84),
		Size = UDim2.new(1, -36, 0, 120),
		Text = announcement.Text,
		TextSize = 22,
		TextWrapped = true
	}, content)

	local v7 = #self._board.Announcements > 1 and string.format("+%d more  ", #self._board.Announcements - 1) or ""
	makeLabel(content, {
		Position = UDim2.new(0, 18, 1, -34),
		Size = UDim2.new(1, -36, 0, 24),
		Text = v7 .. (announcement.Scope == "Server" and "this server" or "all servers"),
		TextSize = 19,
		TextColor3 = color4
	}, content)
end

local function logRichText(data)
	if data.Kind ~= "song" then
		return "- " .. esc(data.Text or "") -- inferred equivalent call
	end

	local v7 = string.format("<font color=\"%s\">[NEW SONG]</font> %s", v6, esc(data.Title)) -- inferred equivalent call

	if data.Artist and data.Artist ~= "" then
		v7 ..= " - " .. esc(data.Artist) -- inferred equivalent call
	end

	if isNewSong(data) then -- inferred equivalent call
		return v7 .. string.format(" <font color=\"%s\"><b>(NEW)</b></font>", v6)
	end

	return v7
end

function InfoBoardUI:_renderLogSmall()
	local content = self._scraps.log.Content
	clear(content) -- inferred equivalent call
	smallTitle(content, "UPDATE LOG")
	local log = self._board.Log

	if #log == 0 then
		makeLabel(content, {
			Position = UDim2.fromOffset(38, 64),
			Size = UDim2.new(1, -52, 0, 100),
			Text = "No updates yet.",
			TextSize = 24,
			TextColor3 = color4
		}, content)

		return
	end

	for i = 1, math.min(#log, 4) do
		makeLabel(content, {
			Position = UDim2.fromOffset(36, (i - 1) * 56 + 54),
			Size = UDim2.new(1, -50, 0, 52),
			Text = logRichText(log[i]),
			RichText = true,
			AutoLocalize = log[i].Kind ~= "song",
			TextSize = 20,
			TextWrapped = true
		}, content)
	end
end

function InfoBoardUI:_renderHowSmall()
	local content = self._scraps.how.Content
	clear(content) -- inferred equivalent call
	smallTitle(content, "HOW TO PLAY")

	for i, v7 in ipairs(v4) do
		makeLabel(content, {
			Position = UDim2.fromOffset(18, 50 + (i - 1) * 33),
			Size = UDim2.new(1, -34, 0, 30),
			Text = string.format("%s. %s", v7[1], v7[2]),
			TextSize = 23
		}, content)
	end

	makeLabel(content, {
		Position = UDim2.new(0, 18, 1, -34),
		Size = UDim2.new(1, -34, 0, 26),
		Font = font,
		Text = "tap for the full guide >",
		TextSize = 19,
		TextColor3 = color5
	}, content)
end

function InfoBoardUI:_renderGigSmall()
	local content = self._scraps.gig.Content
	clear(content) -- inferred equivalent call
	makeLabel(content, {
		Position = UDim2.fromOffset(18, 8),
		Size = UDim2.new(1, -36, 0, 38),
		Font = font,
		Text = "COMMUNITY GIG BOARD",
		TextSize = 31,
		TextColor3 = color9
	}, content)

	create( -- inferred equivalent call
		"Frame",
		{
			Position = UDim2.fromOffset(18, 48),
			Size = UDim2.new(1, -36, 0, 3),
			BackgroundColor3 = color5,
			BorderSizePixel = 0
		},
		content
	)

	local gig = self._board.Gig or {}
	local featured = gig.Featured
	makeLabel(content, {
		Position = UDim2.fromOffset(18, 60),
		Size = UDim2.fromOffset(220, 22),
		Font = font,
		Text = "FEATURED SONG",
		TextSize = 18,
		TextColor3 = Color3.fromRGB(226, 74, 78)
	}, content)

	if featured then
		makeLabel(content, {
			Position = UDim2.fromOffset(18, 84),
			Size = UDim2.fromOffset(224, 64),
			Text = featured.Title,
			AutoLocalize = false,
			TextSize = 26,
			Font = font,
			TextWrapped = true,
			TextColor3 = color9
		}, content)

		makeLabel(content, {
			Position = UDim2.fromOffset(18, 150),
			Size = UDim2.fromOffset(224, 24),
			Text = featured.Artist ~= "" and featured.Artist or featured.Auto and "crowd favorite" or "staff pick",
			AutoLocalize = featured.Artist == "",
			TextSize = 20,
			TextColor3 = Color3.fromRGB(190, 178, 150)
		}, content)
	else
		makeLabel(content, {
			Position = UDim2.fromOffset(18, 86),
			Size = UDim2.fromOffset(224, 60),
			Text = "Favorite a song to light it up here.",
			TextSize = 21,
			TextWrapped = true,
			TextColor3 = Color3.fromRGB(190, 178, 150)
		}, content)
	end

	create( -- inferred equivalent call
		"Frame",
		{
			Position = UDim2.fromOffset(256, 62),
			Size = UDim2.fromOffset(2, 120),
			BackgroundColor3 = Color3.fromRGB(90, 84, 80),
			BorderSizePixel = 0
		},
		content
	)

	local v7 = (gig.EventTitle or "") ~= "" or (gig.EventText or "") ~= ""
	local v8 = (gig.Challenge or "") ~= ""

	if v7 or v8 then
		makeLabel(content, {
			Position = UDim2.fromOffset(272, 60),
			Size = UDim2.new(1, -290, 0, 24),
			Font = font,
			Text = v7 and ((gig.EventTitle or "") == "" and "EVENT" or gig.EventTitle or "EVENT") or "WEEKLY CHALLENGE",
			TextSize = 21,
			TextColor3 = Color3.fromRGB(226, 74, 78)
		}, content)

		local v9 = {
			Position = UDim2.fromOffset(272, 88),
			Size = UDim2.new(1, -290, 0, 88),
			Text = 0,
			TextSize = 20,
			TextWrapped = true,
			TextColor3 = 0
		}
		local text

		if v7 then
			text = gig.EventText or ""
		else
			text = gig.Challenge or ""
		end

		v9.Text = text

		v9.TextColor3 = color9
		makeLabel(content, v9, content)
	else
		makeLabel(content, {
			Position = UDim2.fromOffset(272, 62),
			Size = UDim2.new(1, -290, 0, 110),
			Text = "No gig announced yet. Keep jamming, events land here.",
			TextSize = 21,
			TextWrapped = true,
			TextColor3 = Color3.fromRGB(190, 178, 150)
		}, content)
	end

	makeLabel(content, {
		Position = UDim2.new(0, 18, 1, -30),
		Size = UDim2.new(1, -36, 0, 22),
		Text = "tap to open",
		TextSize = 18,
		TextColor3 = Color3.fromRGB(150, 140, 120)
	}, content)
end

function InfoBoardUI:_renderSmall(p)
	if p == "map" then
		self:_renderMapSmall()
	elseif p == "announce" then
		self:_renderAnnounceSmall()
	elseif p == "log" then
		self:_renderLogSmall()
	elseif p == "how" then
		self:_renderHowSmall()
	elseif p == "gig" then
		self:_renderGigSmall()
	end
end

function InfoBoardUI:_renderAllSmall()
	for _, v7 in ipairs(v2) do
		self:_renderSmall(v7.Id)
	end
end

function InfoBoardUI:_buildOverlay()
	local backdrop = create("TextButton", { -- inferred equivalent call
		Name = "Backdrop",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		ZIndex = 40
	}, self._root)
	backdrop.Activated:Connect(function()
		self:Close()
	end)
	self._backdrop = backdrop

	local sheet = create("Frame", { -- inferred equivalent call
		Name = "Sheet",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(350, 495),
		Size = UDim2.fromOffset(640, 900),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Active = true,
		ClipsDescendants = true,
		Visible = false,
		ZIndex = 41
	}, self._root)
	create("UICorner", { CornerRadius = UDim.new(0, 4) }, sheet) -- inferred equivalent call
	self._sheetStroke = create("UIStroke", { Color = Color3.fromRGB(120, 92, 52), Thickness = 2.5 }, sheet) -- inferred equivalent call
	self._sheet = sheet

	self._header = makeLabel(sheet, {
		Name = "Header",
		Position = UDim2.fromOffset(30, 18),
		Size = UDim2.new(1, -110, 0, 64),
		Font = font,
		Text = "",
		TextSize = 50,
		ZIndex = 3
	}, sheet)

	self._underline = create("Frame", { -- inferred equivalent call
		Name = "Underline",
		Position = UDim2.fromOffset(32, 84),
		Size = UDim2.new(1, -150, 0, 5),
		BackgroundColor3 = color5,
		BorderSizePixel = 0,
		Rotation = -0.6,
		ZIndex = 3
	}, sheet)

	local parent = create("CanvasGroup", { -- inferred equivalent call
		Name = "ScrollClip",
		Position = UDim2.fromOffset(26, 102),
		Size = UDim2.new(1, -52, 1, -126),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 3
	}, sheet)

	local scroll = create("ScrollingFrame", { -- inferred equivalent call
		Name = "Scroll",
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = color4,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.Never,
		Visible = false,
		ZIndex = 3
	}, parent)

	create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder }, scroll) -- inferred equivalent call
	create("UIPadding", { PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 18) }, scroll) -- inferred equivalent call
	self._scroll = scroll

	self._sheetTapes = { addTape(sheet, 0.14, -5, 6, false), addTape(sheet, 0.86, 6, 6, true) }

	local parent2 = create("TextButton", { -- inferred equivalent call
		Name = "Close",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 20),
		Size = UDim2.fromOffset(52, 52),
		BackgroundColor3 = color7,
		Text = "X",
		Font = Enum.Font.GothamBlack,
		TextSize = 28,
		TextColor3 = color9,
		AutoButtonColor = true,
		Rotation = 4,
		ZIndex = 10
	}, sheet)

	create("UICorner", { CornerRadius = UDim.new(0, 4) }, parent2) -- inferred equivalent call
	create("UIStroke", { Color = color3, Thickness = 2 }, parent2) -- inferred equivalent call
	self:_trackHover(parent2)
	parent2.Activated:Connect(function()
		self:Close()
	end)
end

local function bodyLabel(parent, text, options)
	local v7 = {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = text,
		TextSize = 26,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.None,
		RichText = false
	}

	for k, v8 in pairs(options or {}) do
		v7[k] = v8
	end

	return (makeLabel(parent, v7))
end

local function sectionHeading(parent, text, layoutOrder, color10) -- 4 equivalent calls inferred from this helper
	return bodyLabel(parent, text, {
		Font = font,
		TextSize = 32,
		TextColor3 = color10 or color5,
		LayoutOrder = layoutOrder
	})
end

local function makeButton(parent, text, layoutOrder, onActivated, object)
	local button = create("TextButton", { -- inferred equivalent call
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = Color3.fromRGB(26, 26, 28),
		Text = text,
		Font = font,
		TextSize = 28,
		TextColor3 = color9,
		AutoButtonColor = true,
		LayoutOrder = layoutOrder,
		Rotation = -0.6
	}, parent)

	create("UICorner", { CornerRadius = UDim.new(0, 4) }, button) -- inferred equivalent call
	create("UIStroke", { Color = color5, Thickness = 2.5 }, button) -- inferred equivalent call
	button.Activated:Connect(onActivated)

	if object then
		object:_trackHover(button)
	end

	return button
end

local function mapSectionHeader(parent, layoutOrder, text, text2, color10, rotation)
	local parent2 = create( -- inferred equivalent call
		"Frame",
		{ Size = UDim2.new(1, 0, 0, 112), BackgroundTransparency = 1, LayoutOrder = layoutOrder },
		parent
	)

	create("Frame", { -- inferred equivalent call
		Position = UDim2.new(0.03, 4, 0, 22),
		Size = UDim2.new(0.94, 0, 0, 60),
		BackgroundColor3 = Color3.fromRGB(20, 14, 8),
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		Rotation = rotation
	}, parent2)

	local parent3 = create("Frame", { -- inferred equivalent call
		Position = UDim2.new(0.03, 0, 0, 18),
		Size = UDim2.new(0.94, 0, 0, 60),
		BackgroundColor3 = color10,
		BorderSizePixel = 0,
		Rotation = rotation
	}, parent2)

	create("UICorner", { CornerRadius = UDim.new(0, 2) }, parent3) -- inferred equivalent call

	for _, v7 in ipairs({ 5, 51 }) do
		create("Frame", { -- inferred equivalent call
			Position = UDim2.new(0, 10, 0, v7),
			Size = UDim2.new(1, -20, 0, 2),
			BackgroundColor3 = color9,
			BackgroundTransparency = 0.7,
			BorderSizePixel = 0
		}, parent3)
	end

	makeLabel(parent3, {
		Size = UDim2.fromScale(1, 1),
		Font = font,
		Text = text,
		TextSize = 42,
		TextColor3 = color9,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center
	}, parent3)

	for i, v7 in ipairs({
		{ 0, 24, -22 },
		{ 1, 74, 17 }
	}) do
		create("Frame", { -- inferred equivalent call
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(v7[1] == 0 and 0.03 or 0.97, 0, 0, v7[2]),
			Size = UDim2.fromOffset(64, 22),
			BackgroundColor3 = i == 1 and Color3.fromRGB(205, 205, 210) or Color3.fromRGB(190, 160, 110),
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			Rotation = v7[3]
		}, parent2)
	end

	makeLabel(parent2, {
		Position = UDim2.fromOffset(0, 84),
		Size = UDim2.new(1, 0, 0, 24),
		Text = text2,
		TextSize = 22,
		TextColor3 = color4,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Rotation = -rotation * 0.5
	}, parent2)

	create("Frame", { -- inferred equivalent call
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 108),
		Size = UDim2.new(0.38, 0, 0, 3),
		BackgroundColor3 = color5,
		BorderSizePixel = 0,
		Rotation = rotation * 0.8
	}, parent2)

	return parent2
end

function InfoBoardUI:_fillMapOpen(parent)
	local map = self._map
	bodyLabel(parent, "PLAYERS IN THIS SERVER", {
		Font = font,
		TextSize = 24,
		TextColor3 = color4,
		LayoutOrder = 1
	})
	bodyLabel(parent, string.format("%d / %d", map.Players or 0, map.MaxPlayers or 0), {
		AutoLocalize = false,
		Font = font,
		TextSize = 64,
		TextColor3 = color5,
		LayoutOrder = 2
	})

	local v7 = {}
	local v8 = {}
	local layoutOrder = 3

	for _, v9 in ipairs(map.Stages or {}) do
		if string.sub(string.upper((tostring(v9.Name))), 1, 6) == "STUDIO" then
			table.insert(v8, v9)
		else
			table.insert(v7, v9)
		end
	end

	local function buildRow(data)
		local used = data.Used or 0
		local cap = data.Cap or 0
		local parent2 = create("Frame", { -- inferred equivalent call
			Size = UDim2.new(1, 0, 0, data.Song and 146 or 120),
			BackgroundColor3 = Color3.fromRGB(255, 244, 170),
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			LayoutOrder = layoutOrder
		}, parent)

		create("UICorner", { CornerRadius = UDim.new(0, 3) }, parent2) -- inferred equivalent call
		create("UIStroke", { Color = Color3.fromRGB(190, 152, 48), Thickness = 1.5 }, parent2) -- inferred equivalent call
		makeLabel(parent2, {
			Position = UDim2.fromOffset(14, 8),
			Size = UDim2.new(0.55, 0, 0, 40),
			Font = font,
			Text = tostring(data.Name),
			AutoLocalize = false,
			TextSize = 34
		}, parent2)

		local v9 = used == 0 and "EMPTY" or cap <= used and "FULL!" or "JAMMING"
		makeLabel(parent2, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 0, 8),
			Size = UDim2.fromOffset(190, 40),
			Font = font,
			Text = string.format("%s  %d/%d", v9, used, cap),
			AutoLocalize = false,
			TextSize = 30,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextColor3 = used == 0 and color4 or color5
		}, parent2)

		local parent3 = create( -- inferred equivalent call
			"Frame",
			{
				Position = UDim2.fromOffset(14, 54),
				Size = UDim2.new(1, -28, 0, 24),
				BackgroundTransparency = 1
			},
			parent2
		)

		create( -- inferred equivalent call
			"UIListLayout",
			{
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder
			},
			parent3
		)

		for i = 1, cap do
			local v10 = i <= used
			local parent4 = create("Frame", { -- inferred equivalent call
				Size = UDim2.fromOffset(34, 22),
				BackgroundColor3 = v10 and color5 or Color3.fromRGB(255, 244, 170),
				BackgroundTransparency = v10 and 0 or 0.4,
				BorderSizePixel = 0,
				Rotation = i * 7 % 5 - 2,
				LayoutOrder = i
			}, parent3)

			create("UICorner", { CornerRadius = UDim.new(0, 2) }, parent4) -- inferred equivalent call
			create("UIStroke", { Color = color3, Thickness = 1.5 }, parent4) -- inferred equivalent call
		end

		local playing = data.Playing

		local text = (typeof(playing) ~= "table" or not (#playing > 0)) and "Nobody on an instrument yet"
			or "Playing: " .. table.concat(playing, ", ")

		makeLabel(parent2, {
			Position = UDim2.fromOffset(14, 86),
			Size = UDim2.new(1, -28, 0, 26),
			Text = text,
			AutoLocalize = typeof(playing) ~= "table" or not (#playing > 0),
			TextSize = 21,
			TextColor3 = typeof(playing) == "table" and #playing > 0 and color3 or color4,
			TextTruncate = Enum.TextTruncate.AtEnd
		}, parent2)

		if data.Song then
			makeLabel(parent2, {
				Position = UDim2.fromOffset(14, 114),
				Size = UDim2.new(1, -28, 0, 26),
				Font = font,
				Text = "NOW PLAYING: " .. tostring(data.Song),
				AutoLocalize = false,
				TextSize = 22,
				TextColor3 = color5,
				TextTruncate = Enum.TextTruncate.AtEnd
			}, parent2)
		end

		layoutOrder += 1
	end

	if #v7 > 0 then
		mapSectionHeader(parent, layoutOrder, "MAIN STAGES", "full band stages - 6 instruments each", color5, -1.4)
		layoutOrder += 1
	end

	for _, v9 in ipairs(v7) do
		buildRow(v9)
	end

	if #v8 > 0 then
		mapSectionHeader(parent, layoutOrder, "STUDIO ROOMS", "player-made rooms - public or private", color8, 1.3)
		layoutOrder += 1

		for _, v9 in ipairs(v8) do
			buildRow(v9)
		end
	end

	if #(map.Stages or {}) == 0 then
		bodyLabel(parent, "No stages found.", { TextColor3 = color4, LayoutOrder = layoutOrder })
		layoutOrder += 1
	end

	bodyLabel(parent, "Each box is one instrument. Filled = somebody is holding it. Grab a free one and jam!", {
		TextSize = 23,
		TextColor3 = color4,
		LayoutOrder = layoutOrder
	})
end

function InfoBoardUI:_fillAnnounceOpen(parent)
	local announcements = self._board.Announcements

	if #announcements == 0 then
		bodyLabel(parent, "Nothing posted right now.", {
			Font = font,
			TextSize = 34,
			TextColor3 = color4,
			LayoutOrder = 1
		})
		bodyLabel(parent, "When the crew has news, it lands here. Stay loud.", {
			TextColor3 = color4,
			LayoutOrder = 2
		})
	else
		for i, announcement in ipairs(announcements) do
			local parent2 = create("Frame", { -- inferred equivalent call
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Color3.fromRGB(255, 252, 240),
				BackgroundTransparency = 0.25,
				BorderSizePixel = 0,
				LayoutOrder = i
			}, parent)

			create("UICorner", { CornerRadius = UDim.new(0, 3) }, parent2) -- inferred equivalent call
			create("UIStroke", { Color = Color3.fromRGB(160, 84, 96), Thickness = 1.5 }, parent2) -- inferred equivalent call
			create( -- inferred equivalent call
				"UIPadding",
				{
					PaddingTop = UDim.new(0, 12),
					PaddingBottom = UDim.new(0, 14),
					PaddingLeft = UDim.new(0, 16),
					PaddingRight = UDim.new(0, 16)
				},
				parent2
			)
			create("UIListLayout", { -- inferred equivalent call
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder
			}, parent2)
			bodyLabel(parent2, announcement.Scope == "Server" and "THIS SERVER ONLY" or "ALL SERVERS", {
				Font = font,
				TextSize = 20,
				TextColor3 = color5,
				LayoutOrder = 1
			})
			bodyLabel(parent2, announcement.Title == "" and "ANNOUNCEMENT" or announcement.Title or "ANNOUNCEMENT", {
				Font = font,
				TextSize = 38,
				LayoutOrder = 2
			})
			bodyLabel(parent2, announcement.Text, { TextSize = 28, LayoutOrder = 3 })
			bodyLabel(parent2, "posted " .. relativeTime(announcement.Time), {
				TextSize = 20,
				TextColor3 = color4,
				LayoutOrder = 4
			})
		end
	end
end

function InfoBoardUI:_fillLogOpen(parent)
	local log = self._board.Log
	bodyLabel(parent, "New songs show up here once every chart is ready to play. NEW stays for 7 days.", {
		TextSize = 22,
		TextColor3 = color4,
		LayoutOrder = 1
	})

	if #log == 0 then
		bodyLabel(parent, "No updates yet.", {
			Font = font,
			TextSize = 34,
			TextColor3 = color4,
			LayoutOrder = 2
		})
		return
	end

	for i, v7 in ipairs(log) do
		local parent2 = create("Frame", { -- inferred equivalent call
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = i + 1
		}, parent)

		makeLabel(parent2, {
			Name = "Date",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 4),
			Size = UDim2.fromOffset(84, 24),
			Text = shortDate(v7.Time), -- inferred equivalent call
			AutoLocalize = false,
			TextSize = 20,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextColor3 = color4
		}, parent2)

		bodyLabel(parent2, logRichText(v7), {
			Size = UDim2.new(1, -96, 0, 0),
			RichText = true,
			TextSize = 25,
			AutoLocalize = v7.Kind ~= "song"
		})
		create("Frame", { -- inferred equivalent call
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = color6,
			BackgroundTransparency = 0.6,
			BorderSizePixel = 0
		}, parent2)
	end
end

function InfoBoardUI:_fillHowOpen(parent)
	if self._howFull then
		makeButton(parent, "<<  BACK", 0, function()
			self._howFull = false
			self:_refreshOpen(true)
		end, self)
		local layoutOrder = 1

		for _, v7 in ipairs(v5) do
			sectionHeading(parent, v7[1], layoutOrder) -- inferred equivalent call
			layoutOrder += 1

			for _, v8 in ipairs(v7[2]) do
				bodyLabel(parent, "- " .. v8, { TextSize = 24, LayoutOrder = layoutOrder })
				layoutOrder += 1
			end
		end

		makeButton(parent, "<<  BACK", layoutOrder, function()
			self._howFull = false
			self:_refreshOpen(true)
		end, self)
	else
		for i, v7 in ipairs(v4) do
			local parent2 = create( -- inferred equivalent call
				"Frame",
				{
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					LayoutOrder = i
				},
				parent
			)

			makeLabel(parent2, {
				Size = UDim2.fromOffset(52, 52),
				Font = font,
				Text = v7[1],
				TextSize = 52,
				TextColor3 = color5
			}, parent2)

			local parent3 = create( -- inferred equivalent call
				"Frame",
				{
					Position = UDim2.fromOffset(58, 0),
					Size = UDim2.new(1, -58, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1
				},
				parent2
			)

			create("UIListLayout", { -- inferred equivalent call
				Padding = UDim.new(0, 2),
				SortOrder = Enum.SortOrder.LayoutOrder
			}, parent3)
			bodyLabel(parent3, v7[2], { Font = font, TextSize = 32, LayoutOrder = 1 })
			bodyLabel(parent3, v7[3], { TextSize = 25, TextColor3 = color4, LayoutOrder = 2 })
		end

		makeButton(parent, "MORE  >>", #v4 + 1, function()
			self._howFull = true
			self:_refreshOpen(true)
		end, self)
	end
end

function InfoBoardUI:_fillGigOpen(parent)
	local gig = self._board.Gig or {}
	local layoutOrder = 1
	sectionHeading(parent, "FEATURED SONG", layoutOrder, Color3.fromRGB(226, 74, 78)) -- inferred equivalent call
	local layoutOrder2 = layoutOrder + 1
	local featured = gig.Featured

	if featured then
		bodyLabel(parent, featured.Title, {
			Font = font,
			TextSize = 44,
			TextColor3 = color9,
			LayoutOrder = layoutOrder2,
			AutoLocalize = false
		})
		layoutOrder2 += 1
		local v7 = featured.Artist == "" and "" or featured.Artist or ""
		bodyLabel(
			parent,
			v7 .. (v7 == "" and "" or "  -  ") .. (featured.Auto and "crowd favorite (most favorites)" or "staff pick"),
			{
				TextSize = 24,
				TextColor3 = Color3.fromRGB(190, 178, 150),
				LayoutOrder = layoutOrder2,
				AutoLocalize = false
			}
		)
	else
		bodyLabel(parent, "Nothing yet. Favorite a song on the Song Catalog and the crowd favorite shows up here.", {
			TextSize = 26,
			TextColor3 = Color3.fromRGB(190, 178, 150),
			LayoutOrder = layoutOrder2
		})
	end

	local layoutOrder3 = layoutOrder2 + 1

	sectionHeading(parent, "EVENT", layoutOrder3, Color3.fromRGB(226, 74, 78)) -- inferred equivalent call
	local layoutOrder4 = layoutOrder3 + 1

	if (gig.EventTitle or "") == "" and (gig.EventText or "") == "" then
		bodyLabel(parent, "No gig announced yet. Keep jamming, events land here.", {
			TextSize = 26,
			TextColor3 = Color3.fromRGB(190, 178, 150),
			LayoutOrder = layoutOrder4
		})
		layoutOrder4 += 1
	else
		if (gig.EventTitle or "") ~= "" then
			bodyLabel(parent, gig.EventTitle, {
				Font = font,
				TextSize = 38,
				TextColor3 = color9,
				LayoutOrder = layoutOrder4
			})
			layoutOrder4 += 1
		end

		if (gig.EventText or "") ~= "" then
			bodyLabel(parent, gig.EventText, {
				TextSize = 28,
				TextColor3 = color9,
				LayoutOrder = layoutOrder4
			})
			layoutOrder4 += 1
		end
	end

	sectionHeading(parent, "WEEKLY CHALLENGE", layoutOrder4, Color3.fromRGB(226, 74, 78)) -- inferred equivalent call
	local layoutOrder5 = layoutOrder4 + 1

	if (gig.Challenge or "") == "" then
		bodyLabel(parent, "No challenge this week.", {
			TextSize = 26,
			TextColor3 = Color3.fromRGB(190, 178, 150),
			LayoutOrder = layoutOrder5
		})
	else
		bodyLabel(parent, gig.Challenge, {
			TextSize = 28,
			TextColor3 = color9,
			LayoutOrder = layoutOrder5
		})
	end
end

local v7 = {
	map = "MAP INFO",
	announce = "ANNOUNCE!",
	log = "UPDATE LOG",
	how = "HOW TO PLAY",
	gig = "GIG BOARD"
}

function InfoBoardUI:_styleSheet(p)
	local v8 = v[p]
	self._sheet.BackgroundColor3 = v8.paper
	self._sheetStroke.Color = v8.edge
	self._header.TextColor3 = p == "gig" and color9 or color3
	self._header.Text = v7[p] or ""
	self._scroll.ScrollBarImageColor3 = p == "gig" and color9 or color4
end

function InfoBoardUI:_fillOpen(p)
	clear(self._scroll) -- inferred equivalent call
	create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder }, self._scroll) -- inferred equivalent call
	create("UIPadding", { PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 18) }, self._scroll) -- inferred equivalent call

	if p == "map" then
		self:_fillMapOpen(self._scroll)
	elseif p == "announce" then
		self:_fillAnnounceOpen(self._scroll)
	elseif p == "log" then
		self:_fillLogOpen(self._scroll)
	elseif p == "how" then
		self:_fillHowOpen(self._scroll)
	elseif p == "gig" then
		self:_fillGigOpen(self._scroll)
	end
end

function InfoBoardUI:_refreshOpen(p)
	if not self._openId or self._opening then
		return
	end

	local canvasPosition = self._scroll.CanvasPosition
	self:_fillOpen(self._openId)

	if p then
		self._scroll.CanvasPosition = Vector2.zero
	else
		self._scroll.CanvasPosition = canvasPosition
	end
end

local function scrapCenter(data) -- 2 equivalent calls inferred from this helper
	return UDim2.fromOffset(data.X + data.W / 2, data.Y + data.H / 2)
end

function InfoBoardUI:Open(openId)
	local v8 = v3[openId]

	if not v8 or self._openId or self._opening or self._destroyed then
		return
	end

	self._opening = true
	self._openId = openId
	self._howFull = false
	self._token += 1
	local token = self._token

	self:_styleSheet(openId)
	self._scroll.Visible = false
	self._header.Visible = false
	self._underline.Visible = false
	self._sheet.Position = scrapCenter(v8) -- inferred equivalent call
	self._sheet.Size = UDim2.fromOffset(v8.W, v8.H)
	self._sheet.Rotation = v8.Rot
	self._sheet.Visible = true
	self._backdrop.Visible = true
	self._backdrop.BackgroundTransparency = 1
	TweenService:Create(self._backdrop, tweenInfo, { BackgroundTransparency = 0.45 }):Play()
	TweenService:Create(self._sheet, tweenInfo, {
		Position = UDim2.fromOffset(350, 495),
		Size = UDim2.fromOffset(640, 900),
		Rotation = (#openId % 3 - 1) * 0.5
	}):Play()

	if self._onOpened then
		self._onOpened(InfoBoardUI.OpenRect, openId)
	end

	task.delay(0.22, function()
		if self._destroyed or self._token ~= token or self._openId ~= openId then
			return
		end

		self._opening = false
		self:_fillOpen(openId)
		self._scroll.CanvasPosition = Vector2.zero
		self._scroll.Visible = true
		self._header.Visible = true
		self._underline.Visible = true
	end)
end

function InfoBoardUI:IsOpen(): boolean
	return self._openId ~= nil
end

function InfoBoardUI:Close(p)
	if not self._openId then
		return
	end

	local v8 = v3[self._openId]
	self._openId = nil
	self._opening = false
	self._token += 1
	local token = self._token
	self._scroll.Visible = false
	self._header.Visible = false
	self._underline.Visible = false

	if p then
		self._sheet.Visible = false
		self._backdrop.Visible = false
		self._backdrop.BackgroundTransparency = 1
	else
		TweenService:Create(self._backdrop, tweenInfo2, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(self._sheet, tweenInfo2, {
			Position = scrapCenter(v8), -- inferred equivalent call
			Size = UDim2.fromOffset(v8.W, v8.H),
			Rotation = v8.Rot
		}):Play()
		task.delay(tweenInfo2.Time, function()
			if self._destroyed or self._token ~= token then
				return
			end

			self._sheet.Visible = false
			self._backdrop.Visible = false
		end)
	end

	self:ResetHover()

	if self._onClosed then
		self._onClosed(p == true)
	end
end

function InfoBoardUI:SetMap(map)
	if typeof(map) ~= "table" then
		return
	end

	self._map = map
	self:_renderMapSmall()

	if self._openId == "map" then
		self:_refreshOpen(false)
	end
end

function InfoBoardUI:SetBoard(data)
	if typeof(data) ~= "table" then
		return
	end

	self._board = {
		Announcements = data.Announcements or {},
		Log = data.Log or {},
		Gig = data.Gig or { EventTitle = "", EventText = "", Challenge = "" }
	}

	self:_renderAnnounceSmall()
	self:_renderLogSmall()
	self:_renderGigSmall()

	if self._openId == "announce" or self._openId == "log" or self._openId == "gig" then
		self:_refreshOpen(false)
	end
end

function InfoBoardUI:SetOnline(p)
	if typeof(p) ~= "table" then
		return
	end

	if self._onlineValue then
		self._onlineValue.Text = formatCount(p.Online)
	end

	if self._peakValue then
		self._peakValue.Text = formatCount(p.Peak)
	end
end

function InfoBoardUI:RefreshTimes()
	self:_renderLogSmall()

	if self._openId == "log" or self._openId == "announce" then
		self:_refreshOpen(false)
	end
end

function InfoBoardUI:IsInteractiveHovered(): boolean
	return self._hoverCount > 0
end

function InfoBoardUI:ResetHover()
	self._hovered = {}
	self._hoverCount = 0

	for _, scrap in pairs(self._scraps) do
		scrap.Scale.Scale = 1
	end

	for _, v8 in ipairs(v2) do
		self._scraps[v8.Id].Holder.Rotation = v8.Rot
	end
end

function InfoBoardUI:Destroy()
	self._destroyed = true

	if self._root then
		self._root:Destroy()
	end
end

return InfoBoardUI