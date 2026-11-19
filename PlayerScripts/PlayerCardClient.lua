local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local InstrumentTitleConfig = require(ReplicatedStorage.Modules.InstrumentTitleConfig)
local GenreColorConfig = require(ReplicatedStorage.Modules.GenreColorConfig)
local GenreCatalog = require(ReplicatedStorage.Modules.GenreCatalog)
local Theme = require(ReplicatedStorage.Modules.SongListUI.Theme)
local SessionCameraSettings = require(ReplicatedStorage.Modules.SessionCameraSettings)
local NoteLaneUI = require(ReplicatedStorage.Modules.NoteLaneUI)
local NoteLaneUI3D = require(ReplicatedStorage.Modules.NoteLaneUI3D)
local ModeManager = require(ReplicatedStorage.Modules.ModeManager)

local LocalPlayer = Players.LocalPlayer
local result = LocalPlayer:WaitForChild("PlayerGui")

local SetPlayerProfile = ReplicatedStorage.RemoteEvents:WaitForChild("SetPlayerProfile")

local GetPlayerSessionInfo = ReplicatedStorage.RemoteEvents:WaitForChild("GetPlayerSessionInfo")
local RequestJoinSession = ReplicatedStorage.RemoteEvents:WaitForChild("RequestJoinSession")
local v = ReplicatedStorage.RemoteEvents:WaitForChild("JoinSessionResult")
local v2 = ReplicatedStorage.RemoteEvents:WaitForChild("StudioSessionUpdate")
local v3 = ReplicatedStorage.RemoteEvents:WaitForChild("MyStudioIdUpdate")
local v4 = ReplicatedStorage.RemoteEvents:WaitForChild("SongSessionStatusUpdate")

local caption = require(ReplicatedStorage.Modules.ThemeSwitchToast)

local success, result2 = pcall(function()
	return require(ReplicatedStorage.Modules.ResultHistoryUI)
end)

local success2, result3 = pcall(function()
	return require(ReplicatedStorage.Modules.ResultHistoryBridge)
end)

local v5 = nil
local v6 = nil

v3.OnClientEvent:Connect(function(p)
	v5 = p
end)

v4.OnClientEvent:Connect(function(p, p2)
	v6 = p and p2 or nil
end)

local visible = false

local player = nil

local v7 = false

local v8 = {
	OpenStuds = 10,
	CloseStuds = 13,
	HitsOpen = false,
	ReportOpen = false,
	KeybindOpen = false,
	CloseKeybind = function() end,
	SetKeybindTarget = function() end
}

local onMouseButton1Click
local onMouseButton1Click2

local flag = false

local function lockCameraZoom()
	if flag then
		return
	end

	flag = true
	SessionCameraSettings.SetMenuOpen(true)
end

local function unlockCameraZoom() -- 4 equivalent calls inferred from this helper
	if not flag then
		return
	end

	flag = false
	SessionCameraSettings.SetMenuOpen(false)
end

local function addCorner(parent, cornerRadius) -- 6 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = cornerRadius
	uiCorner.Parent = parent
	return uiCorner
end

local function addStroke(parent, border, transparency, p) -- 3 equivalent calls inferred from this helper
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = border
	uiStroke.Transparency = transparency
	uiStroke.Thickness = p or Theme.Stroke.Thickness
	uiStroke.Parent = parent
	return uiStroke
end

local function addPadding(parent, value, value2, value3, value4)
	local uiPadding = Instance.new("UIPadding")

	uiPadding.PaddingLeft = UDim.new(0, value or 0)
	uiPadding.PaddingRight = UDim.new(0, value2 or 0)
	uiPadding.PaddingTop = UDim.new(0, value3 or 0)
	uiPadding.PaddingBottom = UDim.new(0, value4 or 0)

	uiPadding.Parent = parent

	return uiPadding
end

local function makeLabel(parent, name, size, font, textSize, textColor) -- 20 equivalent calls inferred from this helper
	local textLabel = Instance.new("TextLabel")

	textLabel.Name = name
	textLabel.BackgroundTransparency = 1
	textLabel.Size = size
	textLabel.Font = font
	textLabel.TextSize = textSize
	textLabel.TextColor3 = textColor
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Text = ""
	textLabel.Parent = parent

	return textLabel
end

local function colorizeGenre(value) -- 2 equivalent calls inferred from this helper
	if typeof(value) == "string" and value ~= "" then
		return string.format("<font color=\"#%s\">%s</font>", GenreColorConfig.GetColor(value), value)
	end

	return nil
end

local function colorizeGenreList(favoriteGenres)
	if typeof(favoriteGenres) ~= "string" or favoriteGenres == "" then
		return nil
	end

	local v9 = {}

	for k in string.gmatch(favoriteGenres, "[^,]+") do
		local v10 = colorizeGenre(string.match(k, "^%s*(.-)%s*$")) -- inferred equivalent call

		if v10 then
			table.insert(v9, v10)
		end
	end

	if #v9 == 0 then
		return nil
	end

	return table.concat(v9, "  •  ")
end

local function formatPlaytime(totalPlaytimeSeconds)
	if typeof(totalPlaytimeSeconds) ~= "number" then
		return "0m"
	end

	local v9 = math.floor(totalPlaytimeSeconds / 3600)
	local v10 = math.floor(totalPlaytimeSeconds % 3600 / 60)

	if v9 > 0 then
		return string.format("%dh %dm", v9, v10)
	end

	return string.format("%dm", v10)
end

do
	local function formatMemberSince(firstJoinedTimestamp) -- 1 equivalent call inferred from this helper
		if typeof(firstJoinedTimestamp) ~= "number" then
			return nil
		end

		local success3, result4 = pcall(function()
			return DateTime.fromUnixTimestamp(firstJoinedTimestamp):FormatLocalTime("MMM D, YYYY", "en-us")
		end)

		return success3 and result4 or nil
	end
end

local v9 = {
	Roadie = "Roadie",
	Garage = "Garage Band",
	Punk = "Punk Rocker",
	Shred = "Shred Master",
	Thrash = "Thrash Fiend",
	Sludge = "Sludge Lord",
	Doom = "Doom Bringer",
	Riff = "Riff Lord",
	Mosher = "Pit Mosher",
	Loud = "Loud & Proud",
	Feral = "Feral Soul",
	Savage = "Savage Beast",
	Brutal = "Brutal Force",
	Riot = "Riot Starter",
	Chaos = "Chaos Bringer",
	Molten = "Molten Core",
	Idol = "Rock Idol",
	Iconic = "Iconic Act",
	Encore = "Encore King",
	Mythic = "Mythic Force",
	Legend = "Living Legend",
	Anthem = "Anthem Maker",
	Apex = "Apex Predator"
}

do
	local function formatTitleDisplay(value) -- 1 equivalent call inferred from this helper
		if typeof(value) == "string" then
			return v9[value] or value
		end

		return "???"
	end
end

local playerCardGui = Instance.new("ScreenGui")
playerCardGui.Name = "PlayerCardGui"
playerCardGui.ResetOnSpawn = false
playerCardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
playerCardGui.DisplayOrder = 50
playerCardGui.Parent = result

local playerCard = Instance.new("CanvasGroup")
playerCard.Name = "PlayerCard"

playerCard.AnchorPoint = Vector2.new(0, 1)
playerCard.Position = UDim2.new(0, 24, 1, -24)

playerCard.AutomaticSize = Enum.AutomaticSize.Y
playerCard.Size = UDim2.fromOffset(348, 0)

playerCard.BackgroundColor3 = Theme.Colors.Surface
playerCard.GroupTransparency = 1
playerCard.Visible = false
playerCard.ZIndex = Theme.ZIndex.Overlay
playerCard.Parent = playerCardGui

v3 = Theme.Radius.Large
v4 = Instance.new("UICorner")
v4.CornerRadius = v3
v4.Parent = playerCard

v3 = Theme.Colors.Border
v4 = Theme.Stroke.TransparencyDefault
local bar1 = addStroke(playerCard, v3, v4) -- inferred equivalent call
playerCard.MouseEnter:Connect(lockCameraZoom)
playerCard.MouseLeave:Connect(unlockCameraZoom)

playerCard:GetPropertyChangedSignal("Visible"):Connect(function()
	if not playerCard.Visible then
		unlockCameraZoom() -- inferred equivalent call
		onMouseButton1Click()
		v8.CloseHits(true)
		v8.CloseReport(true)
		v8.CloseKeybind(true)
		onMouseButton1Click2()
	end
end)

addPadding(playerCard, Theme.Spacing.M, Theme.Spacing.M, Theme.Spacing.M, Theme.Spacing.M)

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Vertical
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, Theme.Spacing.S)
uiListLayout.Parent = playerCard

v3 = Instance.new("Frame")
v3.Name = "Header"
v3.LayoutOrder = 1
v3.BackgroundTransparency = 1
v3.Size = UDim2.new(1, 0, 0, 64)
v3.Parent = playerCard

v4 = Instance.new("Frame")
v4.Name = "AvatarShell"
v4.Size = UDim2.fromOffset(60, 60)
v4.Position = UDim2.fromOffset(0, 2)
v4.BackgroundColor3 = Theme.Colors.SurfaceHover
v4.Parent = v3

bar1 = Theme.Radius.Pill
local bar2 = addCorner(v4, bar1) -- inferred equivalent call
local avatar = Instance.new("ImageLabel")
avatar.Name = "Avatar"
avatar.Size = UDim2.new(1, -4, 1, -4)
avatar.Position = UDim2.fromOffset(2, 2)
avatar.BackgroundTransparency = 1
avatar.Image = ""
avatar.Parent = v4

bar1 = Theme.Radius.Pill
bar2 = Instance.new("UICorner")
bar2.CornerRadius = bar1
bar2.Parent = avatar

bar1 = Theme.Colors.Border
bar2 = Instance.new("UIStroke")
bar2.Color = bar1
bar2.Transparency = 0.15
bar2.Thickness = 1
bar2.Parent = v4

v4 = Instance.new("Frame")
v4.Name = "Identity"
v4.BackgroundTransparency = 1
v4.Position = UDim2.fromOffset(76, 0)
v4.Size = UDim2.new(1, -76, 1, 0)
v4.Parent = v3

bar1 = UDim2.new(1, 0, 0, 27)
bar2 = Theme.Fonts.Bold
local textColor2 = Theme.TextSize.XL
local caption2 = Theme.Colors.TextPrimary
local label = makeLabel(v4, "NameLabel", bar1, bar2, textColor2, caption2) -- inferred equivalent call
label.TextYAlignment = Enum.TextYAlignment.Center

bar1 = UDim2.new(1, 0, 0, 18)
bar2 = Theme.Fonts.Medium
textColor2 = Theme.TextSize.S
caption2 = Theme.Colors.Accent
local label2 = makeLabel(v4, "SubtitleLabel", bar1, bar2, textColor2, caption2) -- inferred equivalent call
label2.Position = UDim2.fromOffset(0, 30)

do
	local pingRow = Instance.new("Frame")
	pingRow.Name = "PingRow"
	pingRow.BackgroundTransparency = 1
	pingRow.Position = UDim2.fromOffset(0, 49)
	pingRow.Size = UDim2.new(1, 0, 0, 14)
	pingRow.Visible = false
	pingRow.Parent = v4

	local dot = Instance.new("Frame")
	dot.Name = "Dot"
	dot.AnchorPoint = Vector2.new(0, 0.5)
	dot.Position = UDim2.new(0, 1, 0.5, 0)
	dot.Size = UDim2.fromOffset(5, 5)
	dot.BackgroundColor3 = Theme.Colors.TextDisabled
	dot.BorderSizePixel = 0
	dot.Parent = pingRow
	v4 = Theme.Radius.Pill
	bar1 = Instance.new("UICorner")
	bar1.CornerRadius = v4
	bar1.Parent = dot

	v4 = UDim2.new(1, -12, 1, 0)
	bar1 = Theme.Fonts.Medium
	bar2 = Theme.TextSize.XS - 1
	textColor2 = Theme.Colors.TextDisabled
	local label3 = makeLabel(pingRow, "PingLabel", v4, bar1, bar2, textColor2) -- inferred equivalent call
	label3.Position = UDim2.fromOffset(12, 0)
	label3.TextYAlignment = Enum.TextYAlignment.Center
	label3.TextTransparency = 0.2

	label3.TextScaled = true
	v4 = Instance.new("UITextSizeConstraint")
	v4.MaxTextSize = 9
	v4.MinTextSize = 6
	v4.Parent = label3

	local function render(instance)
		local pingMs = instance:GetAttribute("PingMs")

		if typeof(pingMs) ~= "number" then
			pingRow.Visible = false
			return
		end

		local success3 = pingMs < 100 and Theme.Colors.Success
			or pingMs < 200 and Theme.Colors.Accent
			or Theme.Colors.Danger
		dot.BackgroundColor3 = success3

		label3.Text = string.format("%d ms", pingMs)
		pingRow.Visible = true
	end

	local pingMsChangedConnection = nil

	function v8.RefreshPing(object)
		if pingMsChangedConnection then
			pingMsChangedConnection:Disconnect()
			pingMsChangedConnection = nil
		end

		render(object)
		pingMsChangedConnection = object:GetAttributeChangedSignal("PingMs"):Connect(function()
			if player == object then
				render(object)
			end
		end)
	end
end

v4 = Instance.new("TextButton")
v4.Name = "CloseCardButton"
v4.AnchorPoint = Vector2.new(1, 0)
v4.Position = UDim2.new(1, 0, 0, 0)
v4.Size = UDim2.fromOffset(20, 20)
v4.BackgroundTransparency = 1
v4.Text = ""
v4.AutoButtonColor = false
v4.Parent = v3

bar1 = Instance.new("Frame")
bar1.Name = "Bar1"
bar1.AnchorPoint = Vector2.new(0.5, 0.5)
bar1.Position = UDim2.new(0.5, 0, 0.5, 0)
bar1.Size = UDim2.new(0, 10, 0, 2)
bar1.Rotation = 45
bar1.BackgroundColor3 = Theme.Colors.TextSecondary
bar1.BorderSizePixel = 0
bar1.Parent = v4

bar2 = Theme.Radius.Pill
textColor2 = Instance.new("UICorner")
textColor2.CornerRadius = bar2
textColor2.Parent = bar1

bar2 = bar1:Clone()
bar2.Name = "Bar2"
bar2.Rotation = -45
bar2.Parent = v4

local joinSessionButton = Instance.new("TextButton")
joinSessionButton.Name = "JoinSessionButton"
joinSessionButton.AnchorPoint = Vector2.new(1, 1)
joinSessionButton.Position = UDim2.new(1, 0, 1, 0)
joinSessionButton.AutomaticSize = Enum.AutomaticSize.X
joinSessionButton.Size = UDim2.fromOffset(0, 20)
joinSessionButton.BackgroundColor3 = Theme.Colors.Accent
joinSessionButton.Font = Theme.Fonts.Bold
joinSessionButton.TextSize = Theme.TextSize.XS
joinSessionButton.TextColor3 = Theme.Colors.AccentText
joinSessionButton.Text = "Join Session"
joinSessionButton.AutoButtonColor = false
joinSessionButton.Visible = false
joinSessionButton.Parent = v3

v3 = Theme.Radius.Small
bar1 = Instance.new("UICorner")
bar1.CornerRadius = v3
bar1.Parent = joinSessionButton

addPadding(joinSessionButton, Theme.Spacing.S, Theme.Spacing.S, 0, 0)

do
	local function joinSessionBaseColor() -- 3 equivalent calls inferred from this helper
		local StyledTheme = require(ReplicatedStorage.Modules.SongListUI.StyledTheme)
		return StyledTheme.Colors.Accent
	end
end

joinSessionButton.MouseEnter:Connect(function()
	joinSessionButton.BackgroundColor3 = joinSessionBaseColor():Lerp(Color3.new(1, 1, 1), 0.12) -- inferred equivalent call
end)
joinSessionButton.MouseLeave:Connect(function()
	joinSessionButton.BackgroundColor3 = joinSessionBaseColor() -- inferred equivalent call
end)
joinSessionButton.MouseButton1Down:Connect(function()
	joinSessionButton.BackgroundColor3 = joinSessionBaseColor():Lerp(Color3.new(0, 0, 0), 0.12) -- inferred equivalent call
end)

v3 = Instance.new("Frame")
v3.Name = "HeaderDivider"
v3.LayoutOrder = 2
v3.Size = UDim2.new(1, 0, 0, 1)
v3.BackgroundColor3 = Theme.Colors.Border
v3.BackgroundTransparency = 0.35
v3.BorderSizePixel = 0
v3.Parent = playerCard

do
	local body = Instance.new("ScrollingFrame")
	body.Name = "Body"
	body.LayoutOrder = 3
	body.BackgroundTransparency = 1
	body.BorderSizePixel = 0
	body.Size = UDim2.new(1, 0, 0, 0)
	body.AutomaticSize = Enum.AutomaticSize.None
	body.CanvasSize = UDim2.new()
	body.AutomaticCanvasSize = Enum.AutomaticSize.Y
	body.ScrollingDirection = Enum.ScrollingDirection.Y
	body.ScrollBarThickness = 3
	body.ScrollBarImageColor3 = Theme.Colors.Border
	body.ScrollBarImageTransparency = 0.2
	body.VerticalScrollBarInset = Enum.ScrollBarInset.None
	body.ElasticBehavior = Enum.ElasticBehavior.Never
	body.Parent = playerCard

	local uiListLayout2 = Instance.new("UIListLayout")
	uiListLayout2.FillDirection = Enum.FillDirection.Vertical
	uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout2.Padding = uiListLayout.Padding
	uiListLayout2.Parent = body

	local v10 = 10000
	local function resizeBody() -- 1 equivalent call inferred from this helper
		body.Size = UDim2.new(1, 0, 0, (math.min(uiListLayout2.AbsoluteContentSize.Y, v10)))
	end
	uiListLayout2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resizeBody)

	v8.Body = body

	function v8.UpdateBodyLimit()
		local currentCamera = workspace.CurrentCamera
		local y = currentCamera and currentCamera.ViewportSize.Y or 720
		local v11 = 65 + Theme.Spacing.M * 2 + uiListLayout.Padding.Offset * 2
		v10 = math.max(120, y - 88 - v11)
		resizeBody() -- inferred equivalent call
	end
end

v8.UpdateBodyLimit()

v3 = workspace.CurrentCamera

if v3 then
	v3:GetPropertyChangedSignal("ViewportSize"):Connect(v8.UpdateBodyLimit)
end

function v8.FormatScore(value)
	if typeof(value) ~= "number" or value ~= value or value < 0 then
		return "0"
	end

	local v10 = math.floor(value + 0.5)

	if v10 >= 1000000000 then
		return string.format("%.1fB", v10 / 1000000000)
	end

	if v10 >= 10000000 then
		return string.format("%.1fM", v10 / 1000000)
	end

	local v11 = tostring(v10)
	local v12 = string.reverse(string.gsub(string.reverse(v11), "(%d%d%d)", "%1,"))
	return (string.gsub(v12, "^,", ""))
end

local stats = Instance.new("Frame")
stats.Name = "Stats"
stats.LayoutOrder = 3
stats.BackgroundTransparency = 1
stats.Size = UDim2.new(1, 0, 0, 50)
stats.Parent = v8.Body

v3 = Instance.new("UIListLayout")
v3.FillDirection = Enum.FillDirection.Horizontal
v3.SortOrder = Enum.SortOrder.LayoutOrder
v3.HorizontalAlignment = Enum.HorizontalAlignment.Center
v3.VerticalAlignment = Enum.VerticalAlignment.Center
v3.Padding = UDim.new(0, Theme.Spacing.S)
v3.Parent = stats

local function createStatBox(name, layoutOrder)
	local textButton = Instance.new("TextButton")

	textButton.Name = name
	textButton.LayoutOrder = layoutOrder
	textButton.Size = UDim2.new(1 / 3, -math.ceil(2 * Theme.Spacing.S / 3), 1, 0)
	textButton.BackgroundColor3 = Theme.Colors.SurfaceHover
	textButton.Text = ""
	textButton.AutoButtonColor = false
	textButton.Parent = stats

	addCorner(textButton, Theme.Radius.Medium) -- inferred equivalent call

	return textButton
end

local statBox = createStatBox("SongsStat", 1)
local statBox2 = createStatBox("GigsStat", 2)

v3 = UDim2.new(1, 0, 0, 24)
bar1 = Theme.Fonts.Bold
bar2 = Theme.TextSize.L
textColor2 = Theme.Colors.TextPrimary
local label3 = makeLabel(statBox, "Value", v3, bar1, bar2, textColor2) -- inferred equivalent call
label3.TextXAlignment = Enum.TextXAlignment.Center
label3.TextYAlignment = Enum.TextYAlignment.Bottom

v3 = UDim2.new(1, 0, 0, 17)
bar1 = Theme.Fonts.Regular
bar2 = Theme.TextSize.XS
textColor2 = Theme.Colors.TextDisabled
caption2 = Instance.new("TextLabel")

caption2.Name = "Caption"
caption2.BackgroundTransparency = 1
caption2.Size = v3
caption2.Font = bar1
caption2.TextSize = bar2
caption2.TextColor3 = textColor2
caption2.TextXAlignment = Enum.TextXAlignment.Left
caption2.Text = ""
caption2.Parent = statBox

caption2.Position = UDim2.fromOffset(0, 27)
caption2.Text = "SONGS PLAYED"
caption2.TextXAlignment = Enum.TextXAlignment.Center

v3 = UDim2.new(1, 0, 0, 24)
bar1 = Theme.Fonts.Bold
bar2 = Theme.TextSize.L
textColor2 = Theme.Colors.TextPrimary
local label4 = makeLabel(statBox2, "Value", v3, bar1, bar2, textColor2) -- inferred equivalent call
label4.TextXAlignment = Enum.TextXAlignment.Center
label4.TextYAlignment = Enum.TextYAlignment.Bottom

v3 = UDim2.new(1, 0, 0, 17)
bar1 = Theme.Fonts.Regular
bar2 = Theme.TextSize.XS
textColor2 = Theme.Colors.TextDisabled
caption2 = Instance.new("TextLabel")

caption2.Name = "Caption"
caption2.BackgroundTransparency = 1
caption2.Size = v3
caption2.Font = bar1
caption2.TextSize = bar2
caption2.TextColor3 = textColor2
caption2.TextXAlignment = Enum.TextXAlignment.Left
caption2.Text = ""
caption2.Parent = statBox2

caption2.Position = UDim2.fromOffset(0, 27)
caption2.Text = "GIGS PLAYED"
caption2.TextXAlignment = Enum.TextXAlignment.Center

v3 = createStatBox("ScoreStat", 3)

bar1 = UDim2.new(1, 0, 0, 24)
bar2 = Theme.Fonts.Bold
textColor2 = Theme.TextSize.L
caption2 = Theme.Colors.TextPrimary

do
	local label5 = makeLabel(v3, "Value", bar1, bar2, textColor2, caption2) -- inferred equivalent call
	label5.TextXAlignment = Enum.TextXAlignment.Center
	label5.TextYAlignment = Enum.TextYAlignment.Bottom
	label5.TextScaled = true

	bar1 = Instance.new("UITextSizeConstraint")
	bar1.MaxTextSize = 19
	bar1.MinTextSize = 9
	bar1.Parent = label5

	addPadding(label5, 4, 4, 0, 0)

	bar1 = UDim2.new(1, 0, 0, 17)
	bar2 = Theme.Fonts.Regular
	textColor2 = Theme.TextSize.XS
	caption2 = Theme.Colors.TextDisabled
	local label6 = makeLabel(v3, "Caption", bar1, bar2, textColor2, caption2) -- inferred equivalent call
	label6.Position = UDim2.fromOffset(0, 27)
	label6.Text = "TOTAL SCORE"
	label6.TextXAlignment = Enum.TextXAlignment.Center

	v8.ScoreStat = v3
	v8.ScoreValue = label5
end

local statTooltipGui = Instance.new("ScreenGui")
statTooltipGui.Name = "StatTooltipGui"
statTooltipGui.ResetOnSpawn = false
statTooltipGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
statTooltipGui.DisplayOrder = 58
statTooltipGui.Enabled = false
statTooltipGui.Parent = result

v3 = Instance.new("ScreenGui")
v3.Name = "JoinSessionToastGui"
v3.ResetOnSpawn = false
v3.DisplayOrder = 60
v3.Parent = result

do
	local v10 = caption.new(v3)

	v3 = Instance.new("TextButton")
	v3.Name = "Catcher"
	v3.Size = UDim2.fromScale(1, 1)
	v3.BackgroundTransparency = 1
	v3.Text = ""
	v3.AutoButtonColor = false
	v3.ZIndex = Theme.ZIndex.Overlay
	v3.Parent = statTooltipGui

	local tooltipBubble = Instance.new("Frame")
	tooltipBubble.Name = "TooltipBubble"
	tooltipBubble.Size = UDim2.fromOffset(220, 0)
	tooltipBubble.AutomaticSize = Enum.AutomaticSize.Y
	tooltipBubble.BackgroundColor3 = Theme.Colors.Surface
	tooltipBubble.ZIndex = Theme.ZIndex.Overlay + 1
	tooltipBubble.Parent = statTooltipGui

	caption = Theme.Radius.Medium
	bar1 = Instance.new("UICorner")
	bar1.CornerRadius = caption
	bar1.Parent = tooltipBubble

	tooltipBubble.BackgroundTransparency = 0.12
	caption = Theme.Colors.Border
	bar1 = Instance.new("UIStroke")
	bar1.Color = caption
	bar1.Transparency = 0.6
	bar1.Thickness = 1
	bar1.Parent = tooltipBubble

	addPadding(tooltipBubble, Theme.Spacing.S, Theme.Spacing.S, Theme.Spacing.S, Theme.Spacing.S)

	caption = Instance.new("UIListLayout")
	caption.FillDirection = Enum.FillDirection.Vertical
	caption.SortOrder = Enum.SortOrder.LayoutOrder
	caption.Padding = UDim.new(0, 4)
	caption.Parent = tooltipBubble

	caption = UDim2.new(1, 0, 0, 14)
	bar1 = Theme.Fonts.Bold
	bar2 = Theme.TextSize.XS
	textColor2 = Theme.Colors.Accent
	local label5 = makeLabel(tooltipBubble, "TooltipTitle", caption, bar1, bar2, textColor2) -- inferred equivalent call
	label5.LayoutOrder = 1

	caption = UDim2.new(1, 0, 0, 0)
	bar1 = Theme.Fonts.Regular
	bar2 = Theme.TextSize.S
	textColor2 = Theme.Colors.TextSecondary
	local label6 = makeLabel(tooltipBubble, "TooltipBody", caption, bar1, bar2, textColor2) -- inferred equivalent call
	label6.LayoutOrder = 2
	label6.AutomaticSize = Enum.AutomaticSize.Y
	label6.TextWrapped = true

	local count = 0

	onMouseButton1Click2 = function()
		statTooltipGui.Enabled = false
	end

	local function showStatTooltip(p, text, text2)
		count += 1
		local v11 = count

		label5.Text = text
		label6.Text = text2

		task.defer(function()
			if v11 ~= count then
				return
			end

			local currentCamera = workspace.CurrentCamera
			local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)

			local absolutePosition = p.AbsolutePosition
			local absoluteSize = p.AbsoluteSize
			local x = tooltipBubble.AbsoluteSize.X
			local y = tooltipBubble.AbsoluteSize.Y

			local v12 = math.clamp(
				absolutePosition.X + absoluteSize.X / 2 - x / 2,
				8,
				(math.max(8, viewportSize.X - x - 8))
			)

			local v13 = absolutePosition.Y - 8 - y >= 8 and absolutePosition.Y - y - 8
				or absolutePosition.Y + absoluteSize.Y + 8

			tooltipBubble.Position = UDim2.fromOffset(v12, v13)
			statTooltipGui.Enabled = true
		end)

		task.delay(5, function()
			if v11 == count then
				onMouseButton1Click2()
			end
		end)
	end

	v3.MouseButton1Click:Connect(onMouseButton1Click2)

	statBox.Activated:Connect(function()
		showStatTooltip(
			statBox,
			"SONGS PLAYED",
			"Every song you've played from the first note to the last - solo or with a crew. Pure mileage: this is how many times you've plugged in and played it out."
		)
	end)

	statBox2.Activated:Connect(function()
		showStatTooltip(
			statBox2,
			"GIGS PLAYED",
			"A real gig: a full band (3+ musicians) playing the song straight through, start to finish. Solo runs and quick warm-ups don't count - this is the real deal."
		)
	end)

	v8.ScoreStat.Activated:Connect(function()
		showStatTooltip(
			v8.ScoreStat,
			"TOTAL SCORE",
			"All the score you've stacked up from every song you've played to the end. Autoplay runs don't count - only the ones you played yourself."
		)
	end)

	local function createSection(name, layoutOrder) -- 3 equivalent calls inferred from this helper
		local frame = Instance.new("Frame")

		frame.Name = name
		frame.LayoutOrder = layoutOrder
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.new(1, 0, 0, 0)
		frame.AutomaticSize = Enum.AutomaticSize.Y
		frame.Visible = false
		frame.Parent = v8.Body

		return frame
	end

	local function createSectionTitle(section, value)
		local label7 = makeLabel( -- inferred equivalent call
			section,
			"SectionTitle",
			UDim2.new(1, 0, 0, 16),
			Theme.Fonts.Bold,
			Theme.TextSize.XS,
			Theme.Colors.TextDisabled
		)

		label7.Text = string.upper(value)
		label7.TextYAlignment = Enum.TextYAlignment.Center

		return label7
	end

	local section = createSection("FavoriteGenres", 6) -- inferred equivalent call
	createSectionTitle(section, "Favorite Genres")

	v3 = Instance.new("Frame")
	v3.Name = "Content"
	v3.Position = UDim2.fromOffset(0, 20)
	v3.Size = UDim2.new(1, 0, 0, 0)
	v3.AutomaticSize = Enum.AutomaticSize.Y
	v3.BackgroundTransparency = 1
	v3.Parent = section

	caption = UDim2.new(1, -66, 0, 0)
	bar1 = Theme.Fonts.Medium
	bar2 = Theme.TextSize.S
	textColor2 = Theme.Colors.TextSecondary
	local label7 = makeLabel(v3, "FavoriteGenresLabel", caption, bar1, bar2, textColor2) -- inferred equivalent call
	label7.AutomaticSize = Enum.AutomaticSize.Y
	label7.TextWrapped = true
	label7.RichText = true

	local changeGenresButton = Instance.new("TextButton")
	changeGenresButton.Name = "ChangeGenresButton"
	changeGenresButton.AnchorPoint = Vector2.new(1, 0)

	changeGenresButton.Position = UDim2.new(1, -2, 0, 0)
	changeGenresButton.Size = UDim2.fromOffset(60, 22)
	changeGenresButton.BackgroundColor3 = Theme.Colors.SurfaceHover
	changeGenresButton.Font = Theme.Fonts.Medium
	changeGenresButton.TextSize = Theme.TextSize.XS
	changeGenresButton.TextColor3 = Theme.Colors.Accent
	changeGenresButton.Text = "Change"
	changeGenresButton.AutoButtonColor = false
	changeGenresButton.Visible = false
	changeGenresButton.Parent = v3

	v3 = Theme.Radius.Small
	caption = Instance.new("UICorner")
	caption.CornerRadius = v3
	caption.Parent = changeGenresButton
	local section2 = createSection("MostlyPlays", 7) -- inferred equivalent call
	createSectionTitle(section2, "Mostly Plays")

	v3 = UDim2.new(1, 0, 0, 0)
	caption = Theme.Fonts.Medium
	bar1 = Theme.TextSize.S
	bar2 = Theme.Colors.TextSecondary
	local label8 = makeLabel(section2, "MostlyPlaysLabel", v3, caption, bar1, bar2) -- inferred equivalent call
	label8.Position = UDim2.fromOffset(0, 20)
	label8.AutomaticSize = Enum.AutomaticSize.Y
	label8.TextWrapped = true
	label8.RichText = true
	local section3 = createSection("Bio", 8) -- inferred equivalent call
	createSectionTitle(section3, "About")

	local bioDisplayButton = Instance.new("TextButton")
	bioDisplayButton.Name = "BioDisplayButton"
	bioDisplayButton.Position = UDim2.fromOffset(0, 20)
	bioDisplayButton.Size = UDim2.new(1, 0, 0, 0)
	bioDisplayButton.AutomaticSize = Enum.AutomaticSize.Y
	bioDisplayButton.BackgroundColor3 = Theme.Colors.SurfaceHover
	bioDisplayButton.BackgroundTransparency = 0.35
	bioDisplayButton.Font = Theme.Fonts.Regular
	bioDisplayButton.TextSize = Theme.TextSize.S
	bioDisplayButton.TextColor3 = Theme.Colors.TextSecondary
	bioDisplayButton.TextXAlignment = Enum.TextXAlignment.Left
	bioDisplayButton.TextYAlignment = Enum.TextYAlignment.Top
	bioDisplayButton.TextWrapped = true
	bioDisplayButton.RichText = true
	bioDisplayButton.AutoButtonColor = false
	bioDisplayButton.Text = ""
	bioDisplayButton.Visible = false
	bioDisplayButton.Parent = section3

	v3 = Theme.Radius.Medium
	caption = Instance.new("UICorner")
	caption.CornerRadius = v3
	caption.Parent = bioDisplayButton

	addPadding(bioDisplayButton, Theme.Spacing.S, Theme.Spacing.S, Theme.Spacing.S, Theme.Spacing.S)

	local bioEditRow = Instance.new("Frame")
	bioEditRow.Name = "BioEditRow"
	bioEditRow.Position = UDim2.fromOffset(0, 20)
	bioEditRow.Size = UDim2.new(1, 0, 0, 64)
	bioEditRow.BackgroundTransparency = 1
	bioEditRow.Visible = false
	bioEditRow.Parent = section3

	local bioTextBox = Instance.new("TextBox")
	bioTextBox.Name = "BioTextBox"
	bioTextBox.Size = UDim2.new(1, 0, 0, 42)
	bioTextBox.BackgroundColor3 = Theme.Colors.SurfaceHover
	bioTextBox.Font = Theme.Fonts.Regular
	bioTextBox.TextSize = Theme.TextSize.S
	bioTextBox.TextColor3 = Theme.Colors.TextPrimary
	bioTextBox.PlaceholderText = "Say something about yourself..."
	bioTextBox.PlaceholderColor3 = Theme.Colors.TextDisabled
	bioTextBox.Text = ""
	bioTextBox.TextXAlignment = Enum.TextXAlignment.Left
	bioTextBox.TextYAlignment = Enum.TextYAlignment.Top
	bioTextBox.TextWrapped = true
	bioTextBox.MultiLine = true
	bioTextBox.ClearTextOnFocus = false
	bioTextBox.Parent = bioEditRow

	v3 = Theme.Radius.Medium
	caption = Instance.new("UICorner")
	caption.CornerRadius = v3
	caption.Parent = bioTextBox

	v3 = Theme.Colors.Border
	caption = Instance.new("UIStroke")
	caption.Color = v3
	caption.Transparency = 0.25
	caption.Thickness = 1
	caption.Parent = bioTextBox

	addPadding(bioTextBox, Theme.Spacing.S, Theme.Spacing.S, Theme.Spacing.XS, Theme.Spacing.XS)

	v3 = Instance.new("TextButton")
	v3.Name = "BioSaveButton"
	v3.AnchorPoint = Vector2.new(1, 0)
	v3.Position = UDim2.new(1, 0, 0, 46)
	v3.Size = UDim2.fromOffset(58, 18)
	v3.BackgroundColor3 = Theme.Colors.Accent
	v3.Font = Theme.Fonts.Medium
	v3.TextSize = Theme.TextSize.XS
	v3.TextColor3 = Theme.Colors.AccentText
	v3.Text = "SAVE"
	v3.AutoButtonColor = false
	v3.Parent = bioEditRow

	caption = Theme.Radius.Small
	bar1 = Instance.new("UICorner")
	bar1.CornerRadius = caption
	bar1.Parent = v3

	local v11 = nil

	local function refreshJoinSessionButton()
		if visible or not player then
			joinSessionButton.Visible = false
			v11 = nil
		else
			local v12 = player
			local v13, v14, v15 = GetPlayerSessionInfo:InvokeServer(v12)

			if player ~= v12 then
				return
			end

			v11 = v13

			if not v13 or not v5 or v14 ~= v5 then
				joinSessionButton.Visible = false
				return
			end

			local equippedInstrumentType = LocalPlayer:GetAttribute("EquippedInstrumentType")

			if not equippedInstrumentType then
				joinSessionButton.Visible = false
				return
			end

			local v16 = v15 and v15[equippedInstrumentType]

			if v16 and v16.PlayerName ~= LocalPlayer.Name and v16.PlayerName ~= "Admin" then
				joinSessionButton.Visible = false
			else
				joinSessionButton.Visible = true
			end
		end
	end

	v2.OnClientEvent:Connect(function()
		if player and not visible and playerCard.Visible then
			refreshJoinSessionButton()
		end
	end)

	joinSessionButton.MouseButton1Click:Connect(function()
		if visible or not player then
			return
		end

		local v12 = player

		if v6 and v11 and v6 ~= v11 then
			v10:Show(string.format("Switching to %s's session...", v12.DisplayName))
		end

		RequestJoinSession:FireServer(v12)
	end)

	local v12 = {
		target_not_playing = "They're not playing right now.",
		different_studio = "You need to be at the same stage to join.",
		instrument_taken = "Someone else already has that instrument in their session.",
		party_not_ready = "Their stage isn't ready yet - try again in a moment.",
		join_failed = "Couldn't join - try again."
	}

	v.OnClientEvent:Connect(function(p, p2)
		if p then
			return
		end

		v10:Show(v12[p2] or "Couldn't join - try again.")
		refreshJoinSessionButton()
	end)

	local footerDivider = Instance.new("Frame")
	footerDivider.Name = "FooterDivider"
	footerDivider.LayoutOrder = 98
	footerDivider.Size = UDim2.new(1, 0, 0, 1)
	footerDivider.BackgroundColor3 = Theme.Colors.Border
	footerDivider.BackgroundTransparency = 0.55
	footerDivider.BorderSizePixel = 0
	footerDivider.Parent = v8.Body

	local footerLabel = Instance.new("TextLabel")
	footerLabel.Name = "FooterLabel"
	footerLabel.LayoutOrder = 100
	footerLabel.BackgroundTransparency = 1
	footerLabel.Size = UDim2.new(1, 0, 0, 0)
	footerLabel.AutomaticSize = Enum.AutomaticSize.Y
	footerLabel.Font = Theme.Fonts.Regular
	footerLabel.TextSize = Theme.TextSize.XS
	footerLabel.TextColor3 = Theme.Colors.TextDisabled
	footerLabel.TextXAlignment = Enum.TextXAlignment.Left
	footerLabel.TextWrapped = true
	footerLabel.Text = ""
	footerLabel.Visible = false
	footerLabel.Parent = v8.Body

	v = Instance.new("Frame")
	v.Name = "ResultHistoryRow"
	v.LayoutOrder = 97
	v.BackgroundTransparency = 1
	v.Size = UDim2.new(1, 0, 0, 0)
	v.AutomaticSize = Enum.AutomaticSize.Y
	v.Parent = v8.Body

	v2 = Instance.new("UIListLayout")
	v2.FillDirection = Enum.FillDirection.Vertical
	v2.SortOrder = Enum.SortOrder.LayoutOrder
	v2.Padding = UDim.new(0, 4)
	v2.Parent = v

	local resultHistoryButton = Instance.new("TextButton")
	resultHistoryButton.Name = "ResultHistoryButton"
	resultHistoryButton.LayoutOrder = 1
	resultHistoryButton.Size = UDim2.new(1, 0, 0, 30)
	resultHistoryButton.BackgroundColor3 = Theme.Colors.SurfaceHover
	resultHistoryButton.Font = Theme.Fonts.Bold
	resultHistoryButton.TextSize = Theme.TextSize.S
	resultHistoryButton.TextColor3 = Theme.Colors.TextPrimary
	resultHistoryButton.Text = "RESULT HISTORY"
	resultHistoryButton.AutoButtonColor = false
	resultHistoryButton.Parent = v
	v2 = Theme.Radius.Small
	caption = Instance.new("UICorner")
	caption.CornerRadius = v2
	caption.Parent = resultHistoryButton

	v2 = Theme.Colors.Border
	caption = Theme.Stroke.TransparencyDefault
	bar1 = Instance.new("UIStroke")
	bar1.Color = v2
	bar1.Transparency = caption
	bar1.Thickness = Theme.Stroke.Thickness
	bar1.Parent = resultHistoryButton

	local uiScale = Instance.new("UIScale")
	uiScale.Parent = resultHistoryButton

	local resultHistoryCaption = Instance.new("TextLabel")
	resultHistoryCaption.Name = "ResultHistoryCaption"
	resultHistoryCaption.LayoutOrder = 2
	resultHistoryCaption.BackgroundTransparency = 1
	resultHistoryCaption.Size = UDim2.new(1, 0, 0, 0)
	resultHistoryCaption.AutomaticSize = Enum.AutomaticSize.Y
	resultHistoryCaption.Font = Theme.Fonts.Regular
	resultHistoryCaption.TextSize = Theme.TextSize.XS
	resultHistoryCaption.TextColor3 = Theme.Colors.TextDisabled
	resultHistoryCaption.TextXAlignment = Enum.TextXAlignment.Left
	resultHistoryCaption.TextWrapped = true
	resultHistoryCaption.Text = ""
	resultHistoryCaption.Visible = false
	resultHistoryCaption.Parent = v

	local success3, result4 = pcall(function()
		return require(ReplicatedStorage.Modules:WaitForChild("GCamGalleryUI", 5))
	end)

	local success4, result5 = pcall(function()
		return require(ReplicatedStorage.Modules:WaitForChild("GCamGalleryStore", 5))
	end)

	local photoGalleryButton = Instance.new("TextButton")
	photoGalleryButton.Name = "PhotoGalleryButton"
	photoGalleryButton.LayoutOrder = 3
	photoGalleryButton.Size = UDim2.new(1, 0, 0, 30)
	photoGalleryButton.BackgroundColor3 = Theme.Colors.SurfaceHover
	photoGalleryButton.Font = Theme.Fonts.Bold
	photoGalleryButton.TextSize = Theme.TextSize.S
	photoGalleryButton.TextColor3 = Theme.Colors.TextPrimary
	photoGalleryButton.Text = "PHOTO GALLERY"
	photoGalleryButton.AutoButtonColor = false
	photoGalleryButton.Visible = false
	photoGalleryButton.Parent = v
	v = Theme.Radius.Small
	v2 = Instance.new("UICorner")
	v2.CornerRadius = v
	v2.Parent = photoGalleryButton

	v = Theme.Colors.Border
	v2 = Theme.Stroke.TransparencyDefault
	caption = Instance.new("UIStroke")
	caption.Color = v
	caption.Transparency = v2
	caption.Thickness = Theme.Stroke.Thickness
	caption.Parent = photoGalleryButton

	photoGalleryButton.MouseEnter:Connect(function()
		photoGalleryButton.BackgroundColor3 = Theme.Colors.SurfaceSelected
	end)
	photoGalleryButton.MouseLeave:Connect(function()
		photoGalleryButton.BackgroundColor3 = Theme.Colors.SurfaceHover
	end)
	photoGalleryButton.MouseButton1Click:Connect(function()
		if success3 then
			result4.Open()
		end
	end)

	local function refreshCount() -- 1 equivalent call inferred from this helper
		if success4 then
			local count2 = result5.Count()
			photoGalleryButton.Text = count2 > 0 and string.format("PHOTO GALLERY  (%d)", count2) or "PHOTO GALLERY"
		end
	end

	if success4 then
		result5.OnChanged(refreshCount)
	end

	function v8.RefreshGallery(p)
		photoGalleryButton.Visible = (success3 and p) == true
		refreshCount() -- inferred equivalent call
	end

	local resultHistoryHiddenChangedConnection = nil
	local function refreshHistoryRow(player2)
		local v13 = player2 == LocalPlayer
		local visible2 = player2:GetAttribute("ResultHistoryHidden") == true and not v13

		resultHistoryButton.Text = visible2 and "🔒  RESULT HISTORY" or "RESULT HISTORY"
		resultHistoryButton.TextColor3 = visible2 and Theme.Colors.TextDisabled or Theme.Colors.TextPrimary
		resultHistoryButton.BackgroundTransparency = visible2 and 0.5 or 0

		resultHistoryCaption.Visible = visible2

		if visible2 then
			resultHistoryCaption.Text = string.format(
				"%s chose to hide their Result History, so it's locked.",
				player2.DisplayName
			)
		end

		if resultHistoryHiddenChangedConnection then
			resultHistoryHiddenChangedConnection:Disconnect()
		end

		resultHistoryHiddenChangedConnection = player2:GetAttributeChangedSignal("ResultHistoryHidden"):Connect(function()
			if player == player2 then
				refreshHistoryRow(player2)
			end
		end)
	end

	resultHistoryButton.MouseEnter:Connect(function()
		resultHistoryButton.BackgroundColor3 = Theme.Colors.SurfaceSelected
	end)
	resultHistoryButton.MouseLeave:Connect(function()
		resultHistoryButton.BackgroundColor3 = Theme.Colors.SurfaceHover
	end)

	resultHistoryButton.MouseButton1Click:Connect(function()
		local v13 = player

		if not v13 then
			return
		end

		local v14

		if v13:GetAttribute("ResultHistoryHidden") == true then
			v14 = v13 ~= LocalPlayer
		else
			v14 = false
		end

		if v14 then
			resultHistoryCaption.TextColor3 = Theme.Colors.TextPrimary
			task.delay(0.6, function()
				resultHistoryCaption.TextColor3 = Theme.Colors.TextDisabled
			end)
		elseif success then
			result2.Open(v13)
		end
	end)

	local count2 = 0

	local v13 = false

	local function isMouseOverGui(playerCard2, p): boolean
		if not playerCard2.Visible then
			return false
		end

		local mouseLocation = UserInputService:GetMouseLocation()
		local v14 = playerCardGui.IgnoreGuiInset and Vector2.zero

		if not v14 then
			local GuiService = game:GetService("GuiService")
			v14 = GuiService:GetGuiInset()
		end

		local v15 = playerCard2.AbsolutePosition + v14
		local absoluteSize = playerCard2.AbsoluteSize
		return mouseLocation.X >= v15.X - p
			and mouseLocation.X <= v15.X + absoluteSize.X + p
			and mouseLocation.Y >= v15.Y - p
			and mouseLocation.Y <= v15.Y + absoluteSize.Y + p
	end

	local v14 = -1
	local lastTime = 0

	local function isHoldingCardOpen() -- 1 equivalent call inferred from this helper
		if UserInputService.MouseEnabled then
			return v13 or isMouseOverGui(playerCard, 4)
		end

		return false
	end

	local function fadeCard(groupTransparency, duration)
		TweenService:Create(playerCard, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			GroupTransparency = groupTransparency
		}):Play()
	end

	local function fn(p, duration)
		task.delay(duration, function()
			if p ~= count2 or not playerCard.Visible or bioEditRow.Visible then
				return
			end

			if v7 or v8.HitsOpen or v8.ReportOpen or v8.KeybindOpen then
				return
			end

			if isHoldingCardOpen() then -- inferred equivalent call
				v14 = p
				lastTime = os.clock()
				fn(p, 0.4)
			else
				if v14 == p then
					local v15 = 2 - (os.clock() - lastTime)

					if v15 > 0.05 then
						fn(p, v15)
						return
					end
				end

				fadeCard(1, Theme.Animation.Slow)

				task.delay(Theme.Animation.Slow, function()
					if p == count2 then
						playerCard.Visible = false
					end
				end)
			end
		end)
	end

	playerCard.MouseEnter:Connect(function()
		v13 = true
	end)

	playerCard.MouseLeave:Connect(function()
		v13 = false

		if playerCard.Visible and playerCard.GroupTransparency < 0.5 then
			fn(count2, 2)
		end
	end)

	playerCard:GetPropertyChangedSignal("Visible"):Connect(function()
		if not playerCard.Visible then
			v13 = false
		end
	end)

	local function refreshFavoriteGenresDisplay(instance) -- 2 equivalent calls inferred from this helper
		local text = colorizeGenreList(instance:GetAttribute("FavoriteGenres"))

		if text then
			label7.Text = text
		elseif visible then
			label7.Text = "No data yet"
		else
			label7.Text = ""
		end

		changeGenresButton.Visible = visible

		section.Visible = text ~= nil or visible
	end

	local function refreshBioDisplay(instance) -- 2 equivalent calls inferred from this helper
		local bio = instance:GetAttribute("Bio")
		local v15

		if typeof(bio) == "string" then
			v15 = bio ~= ""
		else
			v15 = false
		end

		if v15 then
			bioDisplayButton.Text = string.format("\"%s\"", bio)
		elseif visible then
			bioDisplayButton.Text = "Add a bio..."
		end

		bioDisplayButton.Visible = v15 or visible

		section3.Visible = v15 or visible

		bioEditRow.Visible = false
	end

	local function showCard(player2)
		count2 += 1
		local v15 = count2

		visible = player2 == LocalPlayer
		player = player2
		pcall(function()
			LocalPlayer:SetAttribute("PopularityViewedUserId", player2.UserId)
		end)

		refreshJoinSessionButton()
		refreshHistoryRow(player2)

		if v8.RefreshGallery then
			v8.RefreshGallery(visible)
		end

		v8.CloseHits(true)
		v8.SetReportTarget(player2)
		v8.RefreshPing(player2)
		v8.SetKeybindTarget(player2)

		label.AutoLocalize = false
		label.Text = player2.DisplayName

		local leaderstats = player2:FindFirstChild("leaderstats")
		local title = leaderstats and leaderstats:FindFirstChild("Title")
		local gigsPlayed = leaderstats and leaderstats:FindFirstChild("Gigs Played")

		local value = title and title.Value or "???"
		local value2 = gigsPlayed and gigsPlayed.Value or 0

		label2.Text = formatTitleDisplay(value) -- inferred equivalent call

		local totalSongsPlayed = player2:GetAttribute("TotalSongsPlayed") or 0

		label3.Text = tostring(totalSongsPlayed)
		label4.Text = tostring(value2)
		v8.ScoreValue.Text = v8.FormatScore(player2:GetAttribute("TotalScore"))

		v8.UpdateBodyLimit()
		v8.Body.CanvasPosition = Vector2.zero

		v8.RefreshHits(player2)

		v8.RefreshPeak(player2)

		v8.RefreshStars(player2)
		refreshFavoriteGenresDisplay(player2) -- inferred equivalent call
		local v16 = colorizeGenre(player2:GetAttribute("MostlyGenre")) -- inferred equivalent call

		local mostlyInstrument = player2:GetAttribute("MostlyInstrument")

		local v17 = mostlyInstrument and InstrumentTitleConfig.GetRole(mostlyInstrument)

		local v18 = v17 and string.format("<font color=\"#%s\">%s</font>", v17.Color, v17.Title)

		if v16 or v18 then
			label8.Text = string.format("%s  •  %s", v16 or "No data yet", v18 or "No data yet")

			section2.Visible = true
		else
			label8.Text = ""
			section2.Visible = false
		end

		refreshBioDisplay(player2) -- inferred equivalent call
		local v19 = formatPlaytime(player2:GetAttribute("TotalPlaytimeSeconds"))

		local v20 = formatMemberSince(player2:GetAttribute("FirstJoinedTimestamp")) -- inferred equivalent call

		if v20 then
			footerLabel.Text = string.format("Member since %s   •   %s played", v20, v19)

			footerLabel.Visible = true
			footerDivider.Visible = true
		else
			footerLabel.Visible = false
			footerDivider.Visible = false
		end

		avatar.Image = ""

		task.spawn(function()
			local success5, result6 = pcall(function()
				return Players:GetUserThumbnailAsync(
					player2.UserId,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size100x100
				)
			end)

			if success5 and v15 == count2 then
				avatar.Image = result6
			end
		end)

		playerCard.Visible = true

		fadeCard(0, Theme.Animation.Slow)

		fn(v15, 6)
	end

	local function closeCardNow()
		count2 += 1
		fadeCard(1, 0.15)
		task.delay(0.15, function()
			playerCard.Visible = false
		end)
	end

	v4.MouseButton1Click:Connect(closeCardNow)

	local v15 = false

	UserInputService.InputBegan:Connect(function(input)
		if
			not (v15 and playerCard.Visible)
			or input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		local absolutePosition = playerCard.AbsolutePosition
		local absoluteSize = playerCard.AbsoluteSize
		local position = input.Position

		if
			position.X >= absolutePosition.X
			and position.X <= absolutePosition.X + absoluteSize.X
			and position.Y >= absolutePosition.Y
			and position.Y <= absolutePosition.Y + absoluteSize.Y
		then
			v15 = false
			count2 += 1
			fn(count2, 6)
		end
	end)

	if success2 then
		local position = playerCard.Position
		result3.RegisterCard({
			ShowOwn = function(p)
				if playerCard.Visible and player == LocalPlayer and playerCard.GroupTransparency < 0.5 then
					return resultHistoryButton
				end

				if p then
					playerCard.Position = position - UDim2.fromOffset(400, 0)
				end

				showCard(LocalPlayer)

				if p then
					fadeCard(0, 0.08)
					TweenService:Create(
						playerCard,
						TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{ Position = position }
					):Play()
				end

				return resultHistoryButton
			end,
			GetButtonCenter = function()
				local v16 = playerCardGui.IgnoreGuiInset and Vector2.zero

				if not v16 then
					local GuiService = game:GetService("GuiService")
					v16 = GuiService:GetGuiInset()
				end

				return resultHistoryButton.AbsolutePosition + resultHistoryButton.AbsoluteSize / 2 + v16
			end,
			Pulse = function()
				uiScale.Scale = 1
				local tween = TweenService:Create(
					uiScale,
					TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Scale = 1.12 }
				)

				tween:Play()
				tween.Completed:Once(function()
					TweenService:Create(uiScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Scale = 1
					}):Play()
				end)
				resultHistoryButton.BackgroundColor3 = Theme.Colors.Accent
				resultHistoryButton.TextColor3 = Theme.Colors.AccentText
				task.delay(0.7, function()
					resultHistoryButton.BackgroundColor3 = Theme.Colors.SurfaceHover
					resultHistoryButton.TextColor3 = Theme.Colors.TextPrimary
				end)
			end,
			ArmAutoClose = function(p)
				v15 = true
				count2 += 1
				fn(count2, p)
			end
		})
	end

	playerCard:GetPropertyChangedSignal("Visible"):Connect(function()
		if not playerCard.Visible then
			v15 = false
		end
	end)

	local function isPlayingFreePlay() -- 2 equivalent calls inferred from this helper
		return ModeManager.IsFreePlay() and LocalPlayer:GetAttribute("EquippedInstrumentType") ~= nil
	end

	ModeManager.OnChanged(function()
		if isPlayingFreePlay() and playerCard.Visible then -- inferred equivalent call
			count2 += 1
			fadeCard(1, 0.15)
			task.delay(0.15, function()
				playerCard.Visible = false
			end)
		end
	end)

	function v8.DistanceTo(player2)
		local character = LocalPlayer.Character
		local character2 = player2.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

		if
			humanoidRootPart
			and humanoidRootPart2
			and humanoidRootPart:IsA("BasePart")
			and humanoidRootPart2:IsA("BasePart")
		then
			return (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude
		end

		return nil
	end

	v = game:GetService("RunService")
	local total = 0

	v.Heartbeat:Connect(function(dt)
		total += dt

		if total < 0.25 then
			return
		end

		total = 0

		local v16 = player

		if not v16 or v16 == LocalPlayer or not playerCard.Visible or playerCard.GroupTransparency > 0.9 then
			return
		end

		local v17 = v16.Parent == Players and v8.DistanceTo(v16) or nil

		if not v17 or v8.CloseStuds < v17 then
			count2 += 1
			fadeCard(1, 0.15)
			task.delay(0.15, function()
				playerCard.Visible = false
			end)
		end
	end)

	local function findPlayerHeadAt(p)
		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return nil
		end

		local cframe = currentCamera.CFrame
		local v16 = 1e999
		local v17 = nil

		for _, v18 in ipairs(Players:GetPlayers()) do
			local character = v18.Character
			local head = character and character:FindFirstChild("Head")

			local upperTorso = character
				and (character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"))

			if not (v18 ~= LocalPlayer or not (head and head:IsA("BasePart") and (SessionCameraSettings.GetIsFirstPerson() or (head.Position - cframe.Position).Magnitude < 2))) then
				continue
			end

			if v18 ~= LocalPlayer then
				local distanceTo = v8.DistanceTo(v18)

				if not distanceTo or v8.OpenStuds < distanceTo then
					continue
				end
			end

			for _, part in ipairs({ head, upperTorso }) do
				if not (part and part:IsA("BasePart") and (part.Position - cframe.Position).Magnitude <= 120) then
					continue
				end

				local worldToViewportPoint, v19 = currentCamera:WorldToViewportPoint(part.Position)

				if not v19 then
					continue
				end

				local vector2 = Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y)

				local worldToViewportPoint2 = currentCamera:WorldToViewportPoint(part.Position + cframe.UpVector * (part.Size.Y / 2))

				local v20 = math.max(
					(Vector2.new(worldToViewportPoint2.X, worldToViewportPoint2.Y) - vector2).Magnitude * (part == head and 1.35 or 1),
					26
				)

				local magnitude = (vector2 - p).Magnitude

				if not (magnitude <= v20 and magnitude < v16) then
					continue
				end

				local raycastParams = RaycastParams.new()
				raycastParams.RespectCanCollide = true

				if v18 ~= LocalPlayer and LocalPlayer.Character then
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					raycastParams.FilterDescendantsInstances = { LocalPlayer.Character }
				end

				local raycastResult = workspace:Raycast(cframe.Position, part.Position - cframe.Position, raycastParams)

				if not (not raycastResult or raycastResult.Instance:IsDescendantOf(character)) then
					continue
				end

				v17 = v18
				v16 = magnitude
			end
		end

		return v17
	end

	local function tryShowCardAt(pos)
		if
			isPlayingFreePlay() -- inferred equivalent call
			or LocalPlayer:GetAttribute("GCamAiming") == true
			or (NoteLaneUI.IsVisible() or NoteLaneUI3D.IsVisible())
		then
			return
		end

		local playerHeadAt = findPlayerHeadAt(pos)

		if not playerHeadAt then
			return
		end

		if not playerCard.Visible or player ~= playerHeadAt then
			showCard(playerHeadAt)
			return
		end

		count2 += 1
		fadeCard(1, 0.15)
		task.delay(0.15, function()
			playerCard.Visible = false
		end)
	end

	local v16 = {}
	local v17 = nil

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			v17 = {
				pos = UserInputService:GetMouseLocation(),
				time = os.clock()
			}
		elseif
			input.UserInputType == Enum.UserInputType.Touch
			and input.UserInputState == Enum.UserInputState.Begin
		then
			if next(v16) == nil then
				v16[input] = {
					pos = Vector2.new(input.Position.X, input.Position.Y),
					time = os.clock()
				}
			else
				table.clear(v16)
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		local v18 = nil
		local v19 = nil

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			v18 = v17
			v17 = nil
			v19 = UserInputService:GetMouseLocation()
		elseif input.UserInputType == Enum.UserInputType.Touch then
			v18 = v16[input]
			v16[input] = nil
			v19 = Vector2.new(input.Position.X, input.Position.Y)
		end

		if not v18 or os.clock() - v18.time > 0.35 or (v19 - v18.pos).Magnitude > 14 then
			return
		end

		tryShowCardAt(v18.pos)
	end)

	local function commitBio()
		if not bioEditRow.Visible then
			return
		end

		SetPlayerProfile:FireServer({ Bio = bioTextBox.Text })

		bioEditRow.Visible = false
		bioDisplayButton.Visible = true

		if bioTextBox.Text == "" then
			bioDisplayButton.Text = "Add a bio..."
		else
			bioDisplayButton.Text = string.format("\"%s\"", bioTextBox.Text)
		end
	end

	bioDisplayButton.MouseButton1Click:Connect(function()
		if not visible then
			return
		end

		bioTextBox.Text = LocalPlayer:GetAttribute("Bio") or ""

		bioDisplayButton.Visible = false
		bioEditRow.Visible = true

		bioTextBox:CaptureFocus()
	end)

	v3.MouseButton1Click:Connect(commitBio)

	bioTextBox.FocusLost:Connect(commitBio)

	bioTextBox:GetPropertyChangedSignal("Text"):Connect(function()
		if #bioTextBox.Text > 150 then
			bioTextBox.Text = string.sub(bioTextBox.Text, 1, 150)
		end
	end)

	local favoriteGenresDropdownGui = Instance.new("ScreenGui")
	favoriteGenresDropdownGui.Name = "FavoriteGenresDropdownGui"
	favoriteGenresDropdownGui.ResetOnSpawn = false
	favoriteGenresDropdownGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	favoriteGenresDropdownGui.DisplayOrder = 55
	favoriteGenresDropdownGui.Enabled = false
	favoriteGenresDropdownGui.Parent = result

	v = Instance.new("TextButton")
	v.Name = "Catcher"
	v.Size = UDim2.fromScale(1, 1)
	v.BackgroundTransparency = 1
	v.Text = ""
	v.AutoButtonColor = false
	v.ZIndex = Theme.ZIndex.Overlay
	v.Parent = favoriteGenresDropdownGui

	local dropdownPanel = Instance.new("Frame")
	dropdownPanel.Name = "DropdownPanel"
	dropdownPanel.Size = UDim2.fromOffset(210, 238)
	dropdownPanel.BackgroundColor3 = Theme.Colors.Surface
	dropdownPanel.ZIndex = Theme.ZIndex.Overlay + 1
	dropdownPanel.Parent = favoriteGenresDropdownGui

	v2 = Theme.Radius.Medium
	v3 = Instance.new("UICorner")
	v3.CornerRadius = v2
	v3.Parent = dropdownPanel

	v2 = Theme.Colors.Border
	v3 = Theme.Stroke.TransparencyDefault
	v4 = Instance.new("UIStroke")
	v4.Color = v2
	v4.Transparency = v3
	v4.Thickness = Theme.Stroke.Thickness
	v4.Parent = dropdownPanel

	addPadding(dropdownPanel, Theme.Spacing.S, Theme.Spacing.S, Theme.Spacing.S, Theme.Spacing.S)

	dropdownPanel.MouseEnter:Connect(lockCameraZoom)
	dropdownPanel.MouseLeave:Connect(unlockCameraZoom)

	favoriteGenresDropdownGui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not favoriteGenresDropdownGui.Enabled then
			unlockCameraZoom() -- inferred equivalent call
		end
	end)

	v2 = UDim2.new(1, 0, 0, 16)
	v3 = Theme.Fonts.Bold
	v4 = Theme.TextSize.XS
	caption = Theme.Colors.TextDisabled
	success2 = Instance.new("TextLabel")

	success2.Name = "Title"
	success2.BackgroundTransparency = 1
	success2.Size = v2
	success2.Font = v3
	success2.TextSize = v4
	success2.TextColor3 = caption
	success2.TextXAlignment = Enum.TextXAlignment.Left
	success2.Text = ""
	success2.Parent = dropdownPanel

	success2.Text = "FAVORITE GENRES"

	v2 = UDim2.new(1, 0, 0, 16)
	v3 = Theme.Fonts.Regular
	v4 = Theme.TextSize.XS
	caption = Theme.Colors.TextDisabled
	success2 = Instance.new("TextLabel")

	success2.Name = "Hint"
	success2.BackgroundTransparency = 1
	success2.Size = v2
	success2.Font = v3
	success2.TextSize = v4
	success2.TextColor3 = caption
	success2.TextXAlignment = Enum.TextXAlignment.Left
	success2.Text = ""
	success2.Parent = dropdownPanel

	success2.Position = UDim2.fromOffset(0, 17)
	success2.Text = "Choose up to 3"

	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchBox"
	searchBox.Position = UDim2.fromOffset(0, 39)
	searchBox.Size = UDim2.new(1, 0, 0, 28)
	searchBox.BackgroundColor3 = Theme.Colors.SurfaceHover
	searchBox.Font = Theme.Fonts.Regular
	searchBox.TextSize = Theme.TextSize.S
	searchBox.TextColor3 = Theme.Colors.TextPrimary
	searchBox.PlaceholderText = "Search genres..."
	searchBox.PlaceholderColor3 = Theme.Colors.TextDisabled
	searchBox.Text = ""
	searchBox.ClearTextOnFocus = false
	searchBox.Parent = dropdownPanel

	v2 = Theme.Radius.Small
	v3 = Instance.new("UICorner")
	v3.CornerRadius = v2
	v3.Parent = searchBox

	v2 = Theme.Colors.Border
	v3 = Instance.new("UIStroke")
	v3.Color = v2
	v3.Transparency = 0.45
	v3.Thickness = 1
	v3.Parent = searchBox

	addPadding(searchBox, Theme.Spacing.S, Theme.Spacing.S, 0, 0)

	local genreListScroll = Instance.new("ScrollingFrame")
	genreListScroll.Name = "GenreListScroll"
	genreListScroll.Position = UDim2.fromOffset(0, 73)
	genreListScroll.Size = UDim2.new(1, 0, 1, -73)
	genreListScroll.BackgroundTransparency = 1
	genreListScroll.BorderSizePixel = 0
	genreListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	genreListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	genreListScroll.ScrollBarThickness = 3
	genreListScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	genreListScroll.Parent = dropdownPanel

	v2 = Instance.new("UIListLayout")
	v2.FillDirection = Enum.FillDirection.Vertical
	v2.SortOrder = Enum.SortOrder.LayoutOrder
	v2.Padding = UDim.new(0, 2)
	v2.Parent = genreListScroll

	local favoriteGenres2 = {}
	local v18 = {}

	local function isGenreSelected(p): boolean -- 2 equivalent calls inferred from this helper
		for _, v19 in ipairs(favoriteGenres2) do
			if v19 == p then
				return true
			end
		end

		return false
	end

	local function refreshGenreRowVisual(p) -- 2 equivalent calls inferred from this helper
		local v19 = v18[p]

		if not v19 then
			return
		end

		local genreSelected = isGenreSelected(p) -- inferred equivalent call
		v19.BackgroundTransparency = genreSelected and 0.78 or 1

		local selectedIndicator = v19:FindFirstChild("SelectedIndicator")

		if selectedIndicator then
			selectedIndicator.Visible = genreSelected
		end
	end

	local function applyFavoriteGenresChange()
		SetPlayerProfile:FireServer({ FavoriteGenres = favoriteGenres2 })

		local v19 = {}

		for _, v20 in ipairs(favoriteGenres2) do
			table.insert(v19, colorizeGenre(v20))
		end

		label7.Text = "" .. (#v19 > 0 and table.concat(v19, "  •  ") or "No data yet")
	end

	local function onGenreRowClicked(p)
		if isGenreSelected(p) then -- inferred equivalent call
			for i, v19 in ipairs(favoriteGenres2) do
				if v19 == p then
					table.remove(favoriteGenres2, i)
					break
				end
			end
		elseif #favoriteGenres2 >= 3 then
			return
		else
			table.insert(favoriteGenres2, p)
		end

		refreshGenreRowVisual(p) -- inferred equivalent call
		applyFavoriteGenresChange()
	end

	local function buildGenreRows()
		for i, text in ipairs(GenreCatalog.GetAllGenres()) do
			local color = Color3.fromHex("#" .. GenreColorConfig.GetColor(text))

			local textButton = Instance.new("TextButton")
			textButton.Name = "Row_" .. text
			textButton.LayoutOrder = i
			textButton.Size = UDim2.new(1, 0, 0, 25)
			textButton.BackgroundColor3 = color
			textButton.BackgroundTransparency = 1
			textButton.Font = Theme.Fonts.Medium
			textButton.TextSize = Theme.TextSize.S
			textButton.TextColor3 = color
			textButton.Text = text
			textButton.TextXAlignment = Enum.TextXAlignment.Left
			textButton.AutoButtonColor = false
			textButton.Parent = genreListScroll

			addCorner(textButton, Theme.Radius.Small) -- inferred equivalent call

			addPadding(textButton, Theme.Spacing.S, Theme.Spacing.S, 0, 0)

			local selectedIndicator = Instance.new("TextLabel")
			selectedIndicator.Name = "SelectedIndicator"
			selectedIndicator.AnchorPoint = Vector2.new(1, 0.5)
			selectedIndicator.Position = UDim2.new(1, -6, 0.5, 0)
			selectedIndicator.Size = UDim2.fromOffset(18, 18)
			selectedIndicator.BackgroundTransparency = 1
			selectedIndicator.Font = Theme.Fonts.Bold
			selectedIndicator.TextSize = Theme.TextSize.S
			selectedIndicator.TextColor3 = color
			selectedIndicator.Text = "✓"
			selectedIndicator.Visible = false
			selectedIndicator.Parent = textButton

			v18[text] = textButton

			textButton.MouseButton1Click:Connect(function()
				onGenreRowClicked(text)
			end)
		end
	end

	buildGenreRows()

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = string.lower(searchBox.Text)

		for k, v19 in pairs(v18) do
			v19.Visible = text == "" or string.find(string.lower(k), text, 1, true) ~= nil
		end
	end)

	local function openGenreDropdown()
		favoriteGenres2 = {}

		local favoriteGenres = LocalPlayer:GetAttribute("FavoriteGenres")

		if typeof(favoriteGenres) == "string" then
			for k in string.gmatch(favoriteGenres, "[^,]+") do
				local v19 = string.match(k, "^%s*(.-)%s*$")

				if v18[v19] and #favoriteGenres2 < 3 then
					table.insert(favoriteGenres2, v19)
				end
			end
		end

		for k in pairs(v18) do
			refreshGenreRowVisual(k) -- inferred equivalent call
		end

		searchBox.Text = ""

		local currentCamera = workspace.CurrentCamera

		local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)

		local offset = dropdownPanel.Size.X.Offset

		local offset2 = dropdownPanel.Size.Y.Offset

		local absolutePosition = changeGenresButton.AbsolutePosition

		local absoluteSize = changeGenresButton.AbsoluteSize

		local v19 = math.clamp(
			absolutePosition.X + absoluteSize.X - offset,
			8,
			(math.max(8, viewportSize.X - offset - 8))
		)
		local v20

		if absolutePosition.Y + absoluteSize.Y + 4 + offset2 <= viewportSize.Y - 8 then
			v20 = absolutePosition.Y + absoluteSize.Y + 4
		else
			v20 = absolutePosition.Y - offset2 - 4
		end

		dropdownPanel.Position = UDim2.fromOffset(v19, v20)

		v7 = true
		favoriteGenresDropdownGui.Enabled = true
	end

	onMouseButton1Click = function()
		favoriteGenresDropdownGui.Enabled = false
		v7 = false
	end

	changeGenresButton.MouseButton1Click:Connect(function()
		if favoriteGenresDropdownGui.Enabled then
			onMouseButton1Click()
		else
			openGenreDropdown()
		end
	end)

	v.MouseButton1Click:Connect(onMouseButton1Click)

	local v19 = {
		{
			Label = "Guitar",
			Types = { "GuitarLead", "GuitarRhythm" },
			ColorType = "GuitarLead"
		},
		{
			Label = "Bass",
			Types = { "Bass" },
			ColorType = "Bass"
		},
		{
			Label = "Drum",
			Types = { "Drum" },
			ColorType = "Drum"
		},
		{
			Label = "Piano",
			Types = { "Piano" },
			ColorType = "Piano"
		},
		{
			Label = "Keyboard",
			Types = { "Keyboard" },
			ColorType = "Keyboard"
		}
	}

	local v20 = Theme.Spacing.S * 2 + 16 + #v19 * 26

	local function formatCount(total2)
		local v21 = string.reverse((tostring((math.floor(total2)))))
		local v22 = string.gsub(v21, "(%d%d%d)", "%1,")
		local v23 = string.reverse(v22)

		if string.sub(v23, 1, 1) == "," then
			return (string.sub(v23, 2))
		end

		return v23
	end

	local function groupColor(p)
		local success5, role = pcall(InstrumentTitleConfig.GetRole, p.ColorType)

		if success5 and role and typeof(role.Color) == "string" then
			local success6, result6 = pcall(Color3.fromHex, "#" .. role.Color)

			if success6 then
				return result6
			end
		end

		return Theme.Colors.TextSecondary
	end

	local freePlayHitsRow = Instance.new("TextButton")
	freePlayHitsRow.Name = "FreePlayHitsRow"
	freePlayHitsRow.LayoutOrder = 4
	freePlayHitsRow.Size = UDim2.new(1, 0, 0, 30)
	freePlayHitsRow.BackgroundColor3 = Theme.Colors.SurfaceHover
	freePlayHitsRow.Text = ""
	freePlayHitsRow.AutoButtonColor = false
	freePlayHitsRow.Parent = v8.Body

	v = Theme.Radius.Medium
	v2 = Instance.new("UICorner")
	v2.CornerRadius = v
	v2.Parent = freePlayHitsRow

	addPadding(freePlayHitsRow, Theme.Spacing.S, Theme.Spacing.S, 0, 0)

	v = UDim2.new(0.5, 0, 1, 0)
	v2 = Theme.Fonts.Bold
	v3 = Theme.TextSize.XS
	v4 = Theme.Colors.TextDisabled
	caption = Instance.new("TextLabel")

	caption.Name = "Caption"
	caption.BackgroundTransparency = 1
	caption.Size = v
	caption.Font = v2
	caption.TextSize = v3
	caption.TextColor3 = v4
	caption.TextXAlignment = Enum.TextXAlignment.Left
	caption.Text = ""
	caption.Parent = freePlayHitsRow

	caption.Text = "FREEPLAY HITS"
	caption.TextYAlignment = Enum.TextYAlignment.Center

	local chevron = Instance.new("Frame")
	chevron.Name = "Chevron"
	chevron.AnchorPoint = Vector2.new(1, 0.5)
	chevron.Position = UDim2.new(1, 0, 0.5, 0)
	chevron.Size = UDim2.fromOffset(12, 8)
	chevron.BackgroundTransparency = 1
	chevron.Parent = freePlayHitsRow

	for _, v21 in ipairs({
		{ 3.5, 45 },
		{ 8.5, -45 }
	}) do
		local bar = Instance.new("Frame")
		bar.Name = "Bar"
		bar.AnchorPoint = Vector2.new(0.5, 0.5)
		bar.Position = UDim2.fromOffset(v21[1], 4)
		bar.Size = UDim2.fromOffset(7, 2)
		bar.Rotation = v21[2]
		bar.BackgroundColor3 = Theme.Colors.TextSecondary
		bar.BorderSizePixel = 0
		bar.Parent = chevron
		addCorner(bar, Theme.Radius.Pill) -- inferred equivalent call
	end

	v = UDim2.new(0.5, -20, 1, 0)
	v2 = Theme.Fonts.Bold
	v3 = Theme.TextSize.S
	v4 = Theme.Colors.TextPrimary
	local label9 = makeLabel(freePlayHitsRow, "Value", v, v2, v3, v4) -- inferred equivalent call
	label9.Position = UDim2.new(0.5, 0, 0, 0)
	label9.TextXAlignment = Enum.TextXAlignment.Right
	label9.TextYAlignment = Enum.TextYAlignment.Center
	label9.Text = "0"

	local freePlayHitsDropdownGui = Instance.new("ScreenGui")
	freePlayHitsDropdownGui.Name = "FreePlayHitsDropdownGui"
	freePlayHitsDropdownGui.ResetOnSpawn = false
	freePlayHitsDropdownGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	freePlayHitsDropdownGui.DisplayOrder = 55
	freePlayHitsDropdownGui.Enabled = false
	freePlayHitsDropdownGui.Parent = result

	v = Instance.new("TextButton")
	v.Name = "Catcher"
	v.Size = UDim2.fromScale(1, 1)
	v.BackgroundTransparency = 1
	v.Text = ""
	v.AutoButtonColor = false
	v.ZIndex = Theme.ZIndex.Overlay
	v.Parent = freePlayHitsDropdownGui

	local hitsPanel = Instance.new("Frame")
	hitsPanel.Name = "HitsPanel"
	hitsPanel.Size = UDim2.fromOffset(210, v20)
	hitsPanel.BackgroundColor3 = Theme.Colors.Surface
	hitsPanel.ZIndex = Theme.ZIndex.Overlay + 1
	hitsPanel.Parent = freePlayHitsDropdownGui

	v2 = Theme.Radius.Medium
	v3 = Instance.new("UICorner")
	v3.CornerRadius = v2
	v3.Parent = hitsPanel

	v2 = Theme.Colors.Border
	v3 = Theme.Stroke.TransparencyDefault
	v4 = Instance.new("UIStroke")
	v4.Color = v2
	v4.Transparency = v3
	v4.Thickness = Theme.Stroke.Thickness
	v4.Parent = hitsPanel

	addPadding(hitsPanel, Theme.Spacing.S, Theme.Spacing.S, Theme.Spacing.S, Theme.Spacing.S)

	v2 = Instance.new("UIListLayout")
	v2.FillDirection = Enum.FillDirection.Vertical
	v2.SortOrder = Enum.SortOrder.LayoutOrder
	v2.Padding = UDim.new(0, 2)
	v2.Parent = hitsPanel

	hitsPanel.MouseEnter:Connect(lockCameraZoom)
	hitsPanel.MouseLeave:Connect(unlockCameraZoom)

	freePlayHitsDropdownGui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not freePlayHitsDropdownGui.Enabled then
			unlockCameraZoom() -- inferred equivalent call
		end
	end)

	v2 = UDim2.new(1, 0, 0, 16)
	v3 = Theme.Fonts.Bold
	v4 = Theme.TextSize.XS
	caption = Theme.Colors.TextDisabled
	success2 = Instance.new("TextLabel")

	success2.Name = "Title"
	success2.BackgroundTransparency = 1
	success2.Size = v2
	success2.Font = v3
	success2.TextSize = v4
	success2.TextColor3 = caption
	success2.TextXAlignment = Enum.TextXAlignment.Left
	success2.Text = ""
	success2.Parent = hitsPanel

	success2.LayoutOrder = 0
	success2.Text = "FREEPLAY HITS"

	local v21 = {}

	for i, v22 in ipairs(v19) do
		local frame = Instance.new("Frame")
		frame.Name = "Row_" .. v22.Label
		frame.LayoutOrder = i
		frame.Size = UDim2.new(1, 0, 0, 24)
		frame.BackgroundTransparency = 1
		frame.Parent = hitsPanel

		local v23 = makeLabel(
			frame,
			"Name",
			UDim2.new(0.5, 0, 1, 0),
			Theme.Fonts.Medium,
			Theme.TextSize.S,
			groupColor(v22)
		)

		v23.Text = v22.Label
		v23.TextYAlignment = Enum.TextYAlignment.Center

		v23 = makeLabel(
			frame,
			"Value",
			UDim2.new(0.5, 0, 1, 0),
			Theme.Fonts.Bold,
			Theme.TextSize.S,
			Theme.Colors.TextPrimary
		)

		v23.Position = UDim2.new(0.5, 0, 0, 0)
		v23.TextXAlignment = Enum.TextXAlignment.Right
		v23.TextYAlignment = Enum.TextYAlignment.Center
		v23.Text = "0 hit"

		v21[v22.Label] = v23
	end

	local function updateTexts(instance)
		local total2 = 0

		for _, v22 in ipairs(v19) do
			local total3 = 0

			for _, kind in ipairs(v22.Types) do
				local attribute = instance:GetAttribute("FPHits_" .. kind)

				if typeof(attribute) == "number" then
					total3 += attribute
				end
			end

			total2 += total3
			v21[v22.Label].Text = formatCount(total3) .. " hit"
		end

		label9.Text = formatCount(total2)
	end

	local v22 = nil
	local freePlayHitsTotalChangedConnection = nil

	function v8.RefreshHits(object)
		if v22 ~= object then
			if freePlayHitsTotalChangedConnection then
				freePlayHitsTotalChangedConnection:Disconnect()
			end

			v22 = object
			freePlayHitsTotalChangedConnection = object:GetAttributeChangedSignal("FreePlayHitsTotal"):Connect(function()
				updateTexts(object)
			end)
		end

		updateTexts(object)
	end

	function v8.CloseHits(p)
		local hitsOpen = v8.HitsOpen

		freePlayHitsDropdownGui.Enabled = false
		v8.HitsOpen = false
		chevron.Rotation = 0

		if hitsOpen and not p and playerCard.Visible and playerCard.GroupTransparency < 0.5 then
			count2 += 1
			fn(count2, 6)
		end
	end

	local function openHits()
		if not player then
			return
		end

		onMouseButton1Click()
		updateTexts(player)

		local currentCamera = workspace.CurrentCamera
		local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)

		local absolutePosition = freePlayHitsRow.AbsolutePosition
		local absoluteSize = freePlayHitsRow.AbsoluteSize

		local v23 = math.clamp(absolutePosition.X + absoluteSize.X - 210, 8, (math.max(8, viewportSize.X - 210 - 8)))

		local v24 = absolutePosition.Y + absoluteSize.Y + 4 + v20 <= viewportSize.Y - 8
			and absolutePosition.Y + absoluteSize.Y + 4
			or absolutePosition.Y - v20 - 4

		hitsPanel.Position = UDim2.fromOffset(v23, v24)

		v8.HitsOpen = true
		chevron.Rotation = 180
		freePlayHitsDropdownGui.Enabled = true
	end

	freePlayHitsRow.MouseButton1Click:Connect(function()
		if freePlayHitsDropdownGui.Enabled then
			v8.CloseHits()
		else
			openHits()
		end
	end)

	v.MouseButton1Click:Connect(function()
		v8.CloseHits()
	end)

	local UISkin = require(ReplicatedStorage.Modules.SongListUI.UISkin)
	UISkin.AddRoot(freePlayHitsDropdownGui)

	local v23 = {
		GuitarLead = "Lead Guitar",
		GuitarRhythm = "Rhythm Guitar",
		Bass = "Bass",
		Drum = "Drum",
		Piano = "Piano",
		Keyboard = "Keyboard"
	}

	local peakAccuracyRow = Instance.new("TextButton")
	peakAccuracyRow.Name = "PeakAccuracyRow"
	peakAccuracyRow.LayoutOrder = 5

	peakAccuracyRow.Size = UDim2.new(1, 0, 0, 18)
	peakAccuracyRow.BackgroundTransparency = 1
	peakAccuracyRow.Text = ""
	peakAccuracyRow.AutoButtonColor = false
	peakAccuracyRow.Parent = v8.Body

	v = UDim2.new(0, 0, 0, 18)
	v2 = Theme.Fonts.Bold
	v3 = Theme.TextSize.XS
	v4 = Theme.Colors.TextDisabled
	local label10 = makeLabel(peakAccuracyRow, "Caption", v, v2, v3, v4) -- inferred equivalent call
	label10.Text = "PEAK ACCURACY"
	label10.TextWrapped = false
	label10.AutomaticSize = Enum.AutomaticSize.X
	label10.TextYAlignment = Enum.TextYAlignment.Center

	v = UDim2.new(1, 0, 0, 18)
	v2 = Theme.Fonts.Medium
	v3 = Theme.TextSize.S
	v4 = Theme.Colors.TextSecondary
	local label11 = makeLabel(peakAccuracyRow, "Value", v, v2, v3, v4) -- inferred equivalent call
	label11.TextXAlignment = Enum.TextXAlignment.Left
	label11.TextYAlignment = Enum.TextYAlignment.Center
	label11.TextWrapped = false
	label11.TextTruncate = Enum.TextTruncate.AtEnd
	label11.Text = "--"

	local function layoutPeakValue()
		local v24 = label10.AbsoluteSize.X + 6
		label11.Position = UDim2.fromOffset(v24, 0)
		label11.Size = UDim2.new(1, -v24, 0, 18)
	end

	label10:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutPeakValue)
	v = label10.AbsoluteSize.X + 6
	label11.Position = UDim2.fromOffset(v, 0)
	label11.Size = UDim2.new(1, -v, 0, 18)

	local v24 = nil
	local connections = {}

	local function peakWhereText(instance) -- 1 equivalent call inferred from this helper
		local peakAccuracySong = instance:GetAttribute("PeakAccuracySong")

		if typeof(peakAccuracySong) ~= "string" or peakAccuracySong == "" then
			return ""
		end

		local peakAccuracyInstrument = instance:GetAttribute("PeakAccuracyInstrument")
		local v25

		if typeof(peakAccuracyInstrument) == "string" then
			v25 = v23[peakAccuracyInstrument] or nil
		end

		if v25 then
			return peakAccuracySong .. " - " .. v25
		end

		return peakAccuracySong
	end

	local function updatePeak(instance)
		local peakAccuracy = instance:GetAttribute("PeakAccuracy")

		if typeof(peakAccuracy) ~= "number" then
			label11.Text = "--"

			return
		end

		local text = string.format("%.2f%%", peakAccuracy)
		local v25 = peakWhereText(instance) -- inferred equivalent call

		if v25 ~= "" then
			text ..= " - ( " .. v25 .. " )"
		end

		label11.Text = text
	end

	function v8.RefreshPeak(object)
		if v24 ~= object then
			for _, connection in ipairs(connections) do
				connection:Disconnect()
			end

			table.clear(connections)

			v24 = object

			for _, v25 in ipairs({ "PeakAccuracy", "PeakAccuracySong", "PeakAccuracyInstrument" }) do
				table.insert(connections, object:GetAttributeChangedSignal(v25):Connect(function()
					updatePeak(object)
				end))
			end
		end

		updatePeak(object)
	end

	peakAccuracyRow.Activated:Connect(function()
		local v25 = v24

		if not v25 then
			return
		end

		showStatTooltip(
			peakAccuracyRow,
			"PEAK ACCURACY",
			typeof(v25:GetAttribute("PeakAccuracy")) == "number" and "Best accuracy on the hardest song you cleared at 90%+ on natural difficulty. A harder song replaces it - an easier one never does." or "Clear a full song with 90%+ accuracy on natural difficulty to set it. The hardest song you clear is the one shown."
		)
	end)

	local songStarsRow = Instance.new("TextButton")
	songStarsRow.Name = "SongStarsRow"

	songStarsRow.LayoutOrder = 5
	songStarsRow.Size = UDim2.new(1, 0, 0, 18)
	songStarsRow.BackgroundTransparency = 1
	songStarsRow.Text = ""
	songStarsRow.AutoButtonColor = false
	songStarsRow.Parent = v8.Body

	v = UDim2.new(0, 0, 0, 18)
	v2 = Theme.Fonts.Bold
	v3 = Theme.TextSize.XS
	v4 = Theme.Colors.TextDisabled
	local label12 = makeLabel(songStarsRow, "Caption", v, v2, v3, v4) -- inferred equivalent call
	label12.Text = "SONG STARS"
	label12.TextWrapped = false
	label12.AutomaticSize = Enum.AutomaticSize.X
	label12.TextYAlignment = Enum.TextYAlignment.Center

	v = UDim2.new(1, 0, 0, 18)
	v2 = Theme.Fonts.Medium
	v3 = Theme.TextSize.S
	v4 = Theme.Colors.TextSecondary
	local label13 = makeLabel(songStarsRow, "Value", v, v2, v3, v4) -- inferred equivalent call
	label13.RichText = true
	label13.TextXAlignment = Enum.TextXAlignment.Left
	label13.TextYAlignment = Enum.TextYAlignment.Center
	label13.TextWrapped = false
	label13.Text = "--"

	local function layoutStarsValue()
		local v25 = label12.AbsoluteSize.X + 6
		label13.Position = UDim2.fromOffset(v25, 0)
		label13.Size = UDim2.new(1, -v25, 0, 18)
	end

	label12:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutStarsValue)
	v = label12.AbsoluteSize.X + 6
	label13.Position = UDim2.fromOffset(v, 0)
	label13.Size = UDim2.new(1, -v, 0, 18)

	local v25 = nil
	local connections2 = {}

	local function updateStars(instance)
		local totalStars = instance:GetAttribute("TotalStars")
		local totalStarsMax = instance:GetAttribute("TotalStarsMax")

		if typeof(totalStars) == "number" and typeof(totalStarsMax) == "number" and totalStarsMax > 0 then
			label13.Text = string.format(
				"<font color=\"#%s\">★</font> %d / %d",
				Theme.Colors.Accent:ToHex(),
				totalStars,
				totalStarsMax
			)
		else
			label13.Text = "--"
		end
	end

	function v8.RefreshStars(object)
		if v25 ~= object then
			for _, connection in ipairs(connections2) do
				connection:Disconnect()
			end

			table.clear(connections2)

			v25 = object

			for _, v26 in ipairs({ "TotalStars", "TotalStarsMax" }) do
				table.insert(connections2, object:GetAttributeChangedSignal(v26):Connect(function()
					updateStars(object)
				end))
			end
		end

		updateStars(object)
	end

	songStarsRow.Activated:Connect(function()
		local v26 = v25

		if not v26 then
			return
		end

		showStatTooltip(
			songStarsRow,
			"SONG STARS",
			typeof(v26:GetAttribute("TotalStars")) == "number" and "Every song earns up to 5 stars from your best grade on it (S = 5, A = 4, B = 3, C = 2, D = 1), counting your best instrument. This is the total across the whole song list - beat your own rating to climb." or "Finish songs to start collecting stars. Better grades earn more stars, up to 5 per song."
		)
	end)

	v = {
		16,
		18,
		26,
		26,
		26,
		26,
		56,
		16,
		28
	}
	local v26 = Theme.Spacing.S * 2 + 4 * (#v - 1)

	for _, v27 in ipairs(v) do
		v26 += v27
	end

	local Accent = Theme.Colors.Accent
	v = Theme.Colors.Danger

	local reportRow = Instance.new("Frame")
	reportRow.Name = "ReportRow"
	reportRow.LayoutOrder = 101
	reportRow.BackgroundTransparency = 1
	reportRow.Size = UDim2.new(1, 0, 0, 22)
	reportRow.Visible = false
	reportRow.Parent = v8.Body

	local reportButton = Instance.new("TextButton")
	reportButton.Name = "ReportButton"
	reportButton.AnchorPoint = Vector2.new(1, 0)
	reportButton.Position = UDim2.new(1, 0, 0, 0)
	reportButton.Size = UDim2.new(0, 0, 1, 0)
	reportButton.AutomaticSize = Enum.AutomaticSize.X
	reportButton.BackgroundTransparency = 1
	reportButton.AutoButtonColor = false
	reportButton.Font = Theme.Fonts.Medium
	reportButton.TextSize = Theme.TextSize.XS
	reportButton.TextColor3 = Theme.Colors.TextDisabled
	reportButton.Text = "Report"
	reportButton.Parent = reportRow
	addPadding(reportButton, 6, 6, 0, 0)

	reportButton.MouseEnter:Connect(function()
		reportButton.TextColor3 = Theme.Colors.TextSecondary
	end)
	reportButton.MouseLeave:Connect(function()
		reportButton.TextColor3 = Theme.Colors.TextDisabled
	end)

	local reportPlayerGui = Instance.new("ScreenGui")
	reportPlayerGui.Name = "ReportPlayerGui"
	reportPlayerGui.ResetOnSpawn = false
	reportPlayerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	reportPlayerGui.DisplayOrder = 56
	reportPlayerGui.Enabled = false
	reportPlayerGui.Parent = result

	result = Instance.new("TextButton")
	result.Name = "Catcher"
	result.Size = UDim2.fromScale(1, 1)
	result.BackgroundTransparency = 1
	result.Text = ""
	result.AutoButtonColor = false
	result.ZIndex = Theme.ZIndex.Overlay
	result.Parent = reportPlayerGui

	local reportPanel = Instance.new("Frame")
	reportPanel.Name = "ReportPanel"
	reportPanel.Size = UDim2.fromOffset(250, v26)
	reportPanel.BackgroundColor3 = Theme.Colors.Surface
	reportPanel.ZIndex = Theme.ZIndex.Overlay + 1
	reportPanel.Parent = reportPlayerGui

	v2 = Theme.Radius.Medium
	v3 = Instance.new("UICorner")
	v3.CornerRadius = v2
	v3.Parent = reportPanel

	v2 = Theme.Colors.Border
	v3 = Theme.Stroke.TransparencyDefault
	v4 = Instance.new("UIStroke")
	v4.Color = v2
	v4.Transparency = v3
	v4.Thickness = Theme.Stroke.Thickness
	v4.Parent = reportPanel

	addPadding(reportPanel, Theme.Spacing.S, Theme.Spacing.S, Theme.Spacing.S, Theme.Spacing.S)

	v2 = Instance.new("UIListLayout")
	v2.FillDirection = Enum.FillDirection.Vertical
	v2.SortOrder = Enum.SortOrder.LayoutOrder
	v2.Padding = UDim.new(0, 4)
	v2.Parent = reportPanel

	reportPanel.MouseEnter:Connect(lockCameraZoom)
	reportPanel.MouseLeave:Connect(unlockCameraZoom)

	reportPlayerGui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not reportPlayerGui.Enabled then
			unlockCameraZoom() -- inferred equivalent call
		end
	end)

	v2 = UDim2.new(1, 0, 0, 16)
	v3 = Theme.Fonts.Bold
	v4 = Theme.TextSize.XS
	caption = Theme.Colors.TextDisabled
	success2 = Instance.new("TextLabel")

	success2.Name = "Title"
	success2.BackgroundTransparency = 1
	success2.Size = v2
	success2.Font = v3
	success2.TextSize = v4
	success2.TextColor3 = caption
	success2.TextXAlignment = Enum.TextXAlignment.Left
	success2.Text = ""
	success2.Parent = reportPanel

	success2.LayoutOrder = 1
	success2.Text = "REPORT PLAYER"

	v2 = UDim2.new(1, 0, 0, 18)
	v3 = Theme.Fonts.Medium
	v4 = Theme.TextSize.S
	caption = Theme.Colors.TextPrimary
	local label14 = makeLabel(reportPanel, "Target", v2, v3, v4, caption) -- inferred equivalent call
	label14.LayoutOrder = 2
	label14.TextTruncate = Enum.TextTruncate.AtEnd

	local id = nil

	local v27 = {}

	local function renderSelection()
		for k, v28 in pairs(v27) do
			local visible2 = k == id
			v28.Fill.Visible = visible2
			v28.Ring.Color = visible2 and Accent or Theme.Colors.Border
			v28.Row.BackgroundColor3 = visible2 and Theme.Colors.SurfaceSelected or Theme.Colors.SurfaceHover
		end
	end

	local flag2 = false
	local count3 = 0
	local userId = nil

	for i, v28 in ipairs({
		{ Id = "Spam", Label = "Spam / Disruptive" },
		{ Id = "Cheating", Label = "Cheating / Exploit" },
		{ Id = "Griefing", Label = "Griefing" },
		{ Id = "Other", Label = "Other" }
	}) do
		local textButton = Instance.new("TextButton")
		textButton.Name = "Category_" .. v28.Id
		textButton.LayoutOrder = 2 + i
		textButton.Size = UDim2.new(1, 0, 0, 26)
		textButton.BackgroundColor3 = Theme.Colors.SurfaceHover
		textButton.Text = ""
		textButton.AutoButtonColor = false
		textButton.Parent = reportPanel
		addCorner(textButton, Theme.Radius.Small)
		addPadding(textButton, 8, 8, 0, 0)

		local circle = Instance.new("Frame")
		circle.Name = "Circle"
		circle.AnchorPoint = Vector2.new(0, 0.5)
		circle.Position = UDim2.new(0, 0, 0.5, 0)
		circle.Size = UDim2.fromOffset(14, 14)
		circle.BackgroundTransparency = 1
		circle.Parent = textButton
		addCorner(circle, Theme.Radius.Pill)
		local ring = addStroke(circle, Theme.Colors.Border, 0)

		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.AnchorPoint = Vector2.new(0.5, 0.5)
		fill.Position = UDim2.fromScale(0.5, 0.5)
		fill.Size = UDim2.fromOffset(8, 8)
		fill.BackgroundColor3 = Accent
		fill.BorderSizePixel = 0
		fill.Visible = false
		fill.Parent = circle
		addCorner(fill, Theme.Radius.Pill)

		circle = makeLabel(
			textButton,
			"Name",
			UDim2.new(1, -24, 1, 0),
			Theme.Fonts.Medium,
			Theme.TextSize.S,
			Theme.Colors.TextPrimary
		)

		circle.Position = UDim2.new(0, 24, 0, 0)
		circle.TextYAlignment = Enum.TextYAlignment.Center
		circle.Text = v28.Label

		v27[v28.Id] = { Row = textButton, Fill = fill, Ring = ring }

		textButton.MouseButton1Click:Connect(function()
			if flag2 then
				return
			end

			id = v28.Id
			renderSelection()
		end)
	end

	local note = Instance.new("TextBox")
	note.Name = "Note"
	note.LayoutOrder = 7
	note.Size = UDim2.new(1, 0, 0, 56)
	note.BackgroundColor3 = Theme.Colors.Background
	note.Font = Theme.Fonts.Regular
	note.TextSize = Theme.TextSize.S
	note.TextColor3 = Theme.Colors.TextPrimary
	note.PlaceholderColor3 = Theme.Colors.TextDisabled
	note.PlaceholderText = "Add a note (optional, max 150 characters)"
	note.Text = ""
	note.ClearTextOnFocus = false
	note.MultiLine = true
	note.TextWrapped = true
	note.TextXAlignment = Enum.TextXAlignment.Left
	note.TextYAlignment = Enum.TextYAlignment.Top
	note.Parent = reportPanel
	addCorner(note, Theme.Radius.Small)
	addStroke(note, Theme.Colors.Border, Theme.Stroke.TransparencyDefault)
	addPadding(note, 8, 8, 6, 6)

	note:GetPropertyChangedSignal("Text"):Connect(function()
		local text = note.Text
		local v28 = utf8.len(text)

		if v28 and v28 > 150 then
			note.Text = string.sub(text, 1, utf8.offset(text, 151) - 1)
		end
	end)

	local label15 = makeLabel(reportPanel, "Status", UDim2.new(1, 0, 0, 16), Theme.Fonts.Regular, Theme.TextSize.XS, v)

	label15.LayoutOrder = 8
	label15.TextTruncate = Enum.TextTruncate.AtEnd

	local function setStatus(value) -- 3 equivalent calls inferred from this helper
		label15.Text = value or ""
	end

	local buttons = Instance.new("Frame")
	buttons.Name = "Buttons"
	buttons.LayoutOrder = 9
	buttons.Size = UDim2.new(1, 0, 0, 28)
	buttons.BackgroundTransparency = 1
	buttons.Parent = reportPanel

	local function makeButton(name, text, position, textColor)
		local textButton = Instance.new("TextButton")
		textButton.Name = name
		textButton.Position = position
		textButton.Size = UDim2.new(0.5, -3, 1, 0)
		textButton.BackgroundColor3 = Theme.Colors.SurfaceHover
		textButton.Font = Theme.Fonts.Bold
		textButton.TextSize = Theme.TextSize.S
		textButton.TextColor3 = textColor
		textButton.Text = text
		textButton.AutoButtonColor = false
		textButton.Parent = buttons
		addCorner(textButton, Theme.Radius.Small) -- inferred equivalent call
		addStroke(textButton, Theme.Colors.Border, Theme.Stroke.TransparencyDefault) -- inferred equivalent call
		return textButton
	end

	v = makeButton("Cancel", "Cancel", UDim2.new(0, 0, 0, 0), Theme.Colors.TextSecondary)
	local button = makeButton("Send", "Send", UDim2.new(0.5, 3, 0, 0), Accent)

	function v8.CloseReport(p)
		local reportOpen = v8.ReportOpen

		reportPlayerGui.Enabled = false
		v8.ReportOpen = false
		flag2 = false
		count3 += 1
		button.Text = "Send"

		if reportOpen and not p and playerCard.Visible and playerCard.GroupTransparency < 0.5 then
			count2 += 1
			fn(count2, 6)
		end
	end

	local function openReport()
		local v28 = player

		if not v28 or v28 == LocalPlayer then
			return
		end

		onMouseButton1Click()
		v8.CloseHits(true)

		userId = v28.UserId
		id = nil
		flag2 = false
		note.Text = ""
		setStatus() -- inferred equivalent call
		button.Text = "Send"
		label14.Text = "Reporting " .. v28.DisplayName
		renderSelection()

		local currentCamera = workspace.CurrentCamera
		local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)

		local absolutePosition = reportButton.AbsolutePosition
		local absoluteSize = reportButton.AbsoluteSize

		local v29 = math.clamp(absolutePosition.X + absoluteSize.X - 250, 8, (math.max(8, viewportSize.X - 250 - 8)))

		local v30 = absolutePosition.Y + absoluteSize.Y + 4 + v26 <= viewportSize.Y - 8
			and absolutePosition.Y + absoluteSize.Y + 4
			or math.max(8, absolutePosition.Y - v26 - 4)

		reportPanel.Position = UDim2.fromOffset(v29, v30)

		v8.ReportOpen = true
		reportPlayerGui.Enabled = true
	end

	function v8.SetReportTarget(p)
		reportRow.Visible = p ~= LocalPlayer
		v8.CloseReport(true)
	end

	reportButton.MouseButton1Click:Connect(function()
		if reportPlayerGui.Enabled then
			v8.CloseReport()
		else
			openReport()
		end
	end)

	result.MouseButton1Click:Connect(function()
		v8.CloseReport()
	end)

	v.MouseButton1Click:Connect(function()
		v8.CloseReport()
	end)

	button.MouseButton1Click:Connect(function()
		if flag2 then
			return
		end

		if not id then
			label15.Text = "Choose a reason first."

			return
		end

		if not (userId and Players:GetPlayerByUserId(userId)) then
			label15.Text = "That player already left."

			return
		end

		local v28 = string.gsub(string.gsub(note.Text, "^%s+", ""), "%s+$", "")

		if id == "Other" and #v28 < 3 then
			label15.Text = "Please describe the problem."

			return
		end

		local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
		local submitPlayerReport = remoteEvents and remoteEvents:FindFirstChild("SubmitPlayerReport")

		if not submitPlayerReport then
			label15.Text = "Reporting isn't available right now."

			return
		end

		flag2 = true
		count3 += 1
		local v29 = count3
		button.Text = "Sending..."
		setStatus() -- inferred equivalent call
		submitPlayerReport:FireServer(userId, id, v28)

		task.delay(8, function()
			if flag2 and count3 == v29 then
				flag2 = false
				button.Text = "Send"
				label15.Text = "No response. Please try again."
			end
		end)
	end)

	task.spawn(function()
		local playerReportResult = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PlayerReportResult", 30)

		if not playerReportResult then
			return
		end

		playerReportResult.OnClientEvent:Connect(function(p, value)
			local v28 = typeof(value) == "string" and value or p and "Report sent." or "Couldn't send the report."

			if flag2 then
				flag2 = false
				button.Text = "Send"
			end

			if p then
				v8.CloseReport()
				v10:Show(v28)
			elseif v8.ReportOpen then
				setStatus(v28) -- inferred equivalent call
			else
				v10:Show(v28)
			end
		end)
	end)

	local UISkin2 = require(ReplicatedStorage.Modules.SongListUI.UISkin)
	UISkin2.AddRoot(reportPlayerGui)

	local VoteKickUI = require(ReplicatedStorage.Modules.VoteKickUI)
	result = v8.Body:FindFirstChild("ReportRow")

	if result then
		local voteKickButton = Instance.new("TextButton")
		voteKickButton.Name = "VoteKickButton"
		voteKickButton.AnchorPoint = Vector2.new(0, 0)
		voteKickButton.Position = UDim2.new(0, 0, 0, 0)
		voteKickButton.Size = UDim2.new(0, 0, 1, 0)
		voteKickButton.AutomaticSize = Enum.AutomaticSize.X
		voteKickButton.BackgroundTransparency = 1
		voteKickButton.AutoButtonColor = false
		voteKickButton.Font = Theme.Fonts.Medium
		voteKickButton.TextSize = Theme.TextSize.XS
		voteKickButton.TextColor3 = Theme.Colors.TextDisabled
		voteKickButton.Text = "Vote Kick"
		voteKickButton.Visible = false
		voteKickButton.Parent = result
		addPadding(voteKickButton, 6, 6, 0, 0)

		voteKickButton.MouseEnter:Connect(function()
			voteKickButton.TextColor3 = Theme.Colors.Danger
		end)
		voteKickButton.MouseLeave:Connect(function()
			voteKickButton.TextColor3 = Theme.Colors.TextDisabled
		end)

		local v28 = nil
		local voteKickStageIdChangedConnection = nil

		local function refreshVoteKickButton() -- 1 equivalent call inferred from this helper
			local voteKickStageId = LocalPlayer:GetAttribute("VoteKickStageId")
			voteKickButton.Visible = v28 ~= nil
				and v28 ~= LocalPlayer
				and v28.Parent == Players
				and voteKickStageId ~= nil
				and v28:GetAttribute("VoteKickStageId") == voteKickStageId
		end

		local setReportTarget = v8.SetReportTarget
		function v8.SetReportTarget(object)
			if setReportTarget then
				setReportTarget(object)
			end

			if voteKickStageIdChangedConnection then
				voteKickStageIdChangedConnection:Disconnect()
				voteKickStageIdChangedConnection = nil
			end

			v28 = object

			if object and object ~= LocalPlayer then
				voteKickStageIdChangedConnection = object:GetAttributeChangedSignal("VoteKickStageId"):Connect(refreshVoteKickButton)
			end

			refreshVoteKickButton() -- inferred equivalent call
		end

		LocalPlayer:GetAttributeChangedSignal("VoteKickStageId"):Connect(refreshVoteKickButton)

		voteKickButton.MouseButton1Click:Connect(function()
			if not v28 or v28 == LocalPlayer then
				return
			end

			if v8.CloseReport then
				v8.CloseReport(true)
			end

			VoteKickUI.OpenPicker(voteKickButton, v28)
		end)
	end

	local success5
	success5, result = pcall(function()
		return require(ReplicatedStorage.Modules.KeybindPanelUI)
	end)

	if success5 then
		if UserInputService.KeyboardEnabled then
			local keybindRow = Instance.new("TextButton")
			keybindRow.Name = "KeybindRow"
			keybindRow.LayoutOrder = 96
			keybindRow.Size = UDim2.new(1, 0, 0, 26)
			keybindRow.BackgroundColor3 = Theme.Colors.SurfaceHover
			keybindRow.Text = ""
			keybindRow.AutoButtonColor = false
			keybindRow.Parent = v8.Body

			local v28 = Theme.Radius.Small
			local uiCorner = addCorner(keybindRow, v28) -- inferred equivalent call
			addPadding(keybindRow, Theme.Spacing.S, Theme.Spacing.S, 0, 0)
			v28 = Theme.Colors.Border
			uiCorner = Theme.Stroke.TransparencyDefault
			local uiStroke = addStroke(keybindRow, v28, uiCorner) -- inferred equivalent call
			v28 = UDim2.new(0.5, 0, 1, 0)
			uiCorner = Theme.Fonts.Bold
			uiStroke = Theme.TextSize.XS
			local v29 = Theme.Colors.TextDisabled
			local label16 = makeLabel(keybindRow, "Caption", v28, uiCorner, uiStroke, v29) -- inferred equivalent call
			label16.Text = "KEYBIND"
			label16.TextYAlignment = Enum.TextYAlignment.Center

			v28 = UDim2.new(0.5, 0, 1, 0)
			uiCorner = Theme.Fonts.Medium
			uiStroke = Theme.TextSize.XS
			v29 = Theme.Colors.TextSecondary
			local label17 = makeLabel(keybindRow, "Hint", v28, uiCorner, uiStroke, v29) -- inferred equivalent call
			label17.Position = UDim2.new(0.5, 0, 0, 0)
			label17.TextXAlignment = Enum.TextXAlignment.Right
			label17.TextYAlignment = Enum.TextYAlignment.Center
			label17.Text = "View / Copy"

			local v30 = result.Init({
				Card = playerCard,
				GetPlayer = function()
					return player
				end,
				LockZoom = lockCameraZoom,
				UnlockZoom = unlockCameraZoom,
				Toast = function(p)
					v10:Show(p)
				end,
				OnOpenChanged = function(keybindOpen, p)
					v8.KeybindOpen = keybindOpen

					if not keybindOpen and not p and playerCard.Visible and playerCard.GroupTransparency < 0.5 then
						count2 += 1
						fn(count2, 6)
					end
				end
			})

			function v8.CloseKeybind(p)
				v30.Close(p)
			end

			function v8.SetKeybindTarget(p)
				v30.Close(true)
				label17.Text = p == LocalPlayer and "Edit" or "View / Copy"
			end

			keybindRow.MouseButton1Click:Connect(function()
				v30.Toggle()
			end)
		end
	else
		warn("[PlayerCardClient] KeybindPanelUI gagal dimuat:", result)
	end

	LocalPlayer:GetAttributeChangedSignal("Bio"):Connect(function()
		if visible and not bioEditRow.Visible then
			refreshBioDisplay(LocalPlayer) -- inferred equivalent call
		end
	end)

	LocalPlayer:GetAttributeChangedSignal("FavoriteGenres"):Connect(function()
		if visible then
			refreshFavoriteGenresDisplay(LocalPlayer) -- inferred equivalent call
		end
	end)

	result = require(ReplicatedStorage.Modules.SongListUI.UISkin)
	result.AddRoot(playerCardGui)
	result.AddRoot(favoriteGenresDropdownGui)
end

result.AddRoot(statTooltipGui)