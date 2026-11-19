local statsRow = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local StyledTheme = require(ReplicatedStorage.Modules.SongListUI.StyledTheme)
local UISkin = require(ReplicatedStorage.Modules.SongListUI.UISkin)
local StarConfig = require(ReplicatedStorage.Modules.StarConfig)
local StreakTierColors = require(ReplicatedStorage.Modules.StreakTierColors)

local SessionCameraSettings = require(ReplicatedStorage.Modules.SessionCameraSettings)
local SettingsState = require(ReplicatedStorage.Modules.SettingsState)

local success, result = pcall(function()
	require(ReplicatedStorage.Modules.ResultsTipsTelemetry)
	return require(ReplicatedStorage.Modules.ResultsTipsEngine)
end)

local success2, result2 = pcall(function()
	return require(ReplicatedStorage.Modules.ResultHistoryBridge)
end)

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ShowSongResults = RemoteEvents:WaitForChild("ShowSongResults")

local localPlayer = statsRow.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

statsRow = v and Vector2.new(0.5, 0) or Vector2.new(0, 0.5)
local categorySelector = v and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 90, 0.5, 0)

local statsRowHolder = v and Vector2.new(0, 0) or Vector2.new(0, 0.5)

local udim = v and UDim2.new(0, 0, 0, 340) or UDim2.new(0, 354, 0.5, 0)

local udim2 = v and UDim2.new(1, 0, 0, 318) or UDim2.new(1, -354, 0, 318)

local v2 = {
	Perfect = StyledTheme.Colors.Accent,
	Great = StyledTheme.Colors.Success,
	Good = Color3.fromRGB(120, 170, 220),
	OK = Color3.fromRGB(190, 150, 90),
	Miss = StyledTheme.Colors.Danger,
	Wrong = Color3.fromRGB(125, 60, 125)
}

local v3 = {
	S = { "Absolutely unreal.", "That was a whole performance.", "Certified stage legend." },
	A = { "Solid work, keep it up!", "Your bandmates are lucky to have you.", "That's real stage-quality stuff." },
	B = {
		"Pretty good, and you're only getting better.",
		"Clean run, keep sharpening it.",
		"Getting closer every time."
	},
	C = {
		"Decent effort out there, keep going.",
		"Warming up nicely - onwards!",
		"Not quite there yet, but you're building it."
	},
	D = {
		"Rough patch, but hey, that's how you learn.",
		"Off night - everyone gets one of those.",
		"A little shaky, but you stuck with it. That counts."
	},
	F = {
		"Tough round, but you showed up - that matters.",
		"Everyone bombs one sometimes, shake it off.",
		"Not your night, but you finished it. Next one's yours."
	}
}

local v4 = {
	Drum = {
		"That snare's been sweating tonight - respect the grind.",
		"Somewhere, a cymbal is still ringing from that one.",
		"Drum kit's tired, but it's a happy tired."
	},
	GuitarRhythm = {
		"Your pick's got a whole story to tell after that.",
		"That riff had range - respect.",
		"Somewhere, an amp is nodding along."
	},
	GuitarLead = {
		"Fretboard's warm, in a good way.",
		"That solo had main-character energy.",
		"Somewhere, a guitar hero took notes."
	},
	Bass = {
		"Low end held it down, as usual.",
		"That groove snuck up on everyone.",
		"Bass cab's still humming from that one."
	},
	Keyboard = {
		"Your keys put in real work tonight.",
		"Somewhere, a synth is feeling pretty good about itself.",
		"That was a whole vibe, played live."
	},
	Piano = {
		"Those keys earned a little rest after that.",
		"Somewhere, a piano tuner is smiling.",
		"The ivories had a whole journey tonight."
	}
}

local function pickResultComment(grade, instrument)
	local v5 = {}

	for _, v6 in ipairs(v3[grade] or {}) do
		table.insert(v5, v6)
	end

	for _, v6 in ipairs(v4[instrument] or {}) do
		table.insert(v5, v6)
	end

	if #v5 == 0 then
		return ""
	end

	return v5[math.random(1, #v5)]
end

local function computeBadge(data): nil | string
	if data.IsAutoPlayed then
		return nil
	end

	local judgements = data.Judgements or {}
	local v5 = (data.HitCount or 0) + (judgements.Miss or 0)

	if data.IsNewPersonalBest then
		return "RECORD BREAKER"
	end

	if v5 > 0 and (judgements.Perfect or 0) / v5 > 0.8 then
		return "PRECISION MACHINE"
	end

	if (data.TotalNotes or 0) > 0 and (data.MaxCombo or 0) >= data.TotalNotes * 0.9 then
		return "UNSTOPPABLE"
	end

	return if (data.Wrong or 0) > 15 then "BUTTON MASHER" else nil
end

local function buildRivalCompareText(playerResults, p, p2)
	if p.IsAutoPlayed then
		return ""
	end

	local v5 = {}

	for _, item in ipairs(playerResults) do
		if not item.IsAutoPlayed then
			table.insert(v5, item)
		end
	end

	if #v5 < 2 then
		return ""
	end

	local function rating(p3) -- 4 equivalent calls inferred from this helper
		return p3.Accuracy
	end

	if p2 == 1 then
		local v6 = v5[2]
		return string.format("Ahead of #2 @%s by %.1f pts", v6.PlayerName, rating(p) - rating(v6)) -- inferred equivalent call
	end

	local v6 = v5[p2 - 1]

	if v6 then
		return string.format("Behind #%d @%s by %.1f pts", p2 - 1, v6.PlayerName, rating(v6) - rating(p)) -- inferred equivalent call
	end

	return ""
end

local function getJudgmentColor(p) -- 4 equivalent calls inferred from this helper
	return SettingsState.GetRhythmJudgmentColor(p) or v2[p]
end

local function corner(parent, p) -- 11 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = p or StyledTheme.Radius.Medium
	uiCorner.Parent = parent
	return uiCorner
end

local function stroke(parent, p, p2, p3) -- 1 equivalent call inferred from this helper
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = p or StyledTheme.Colors.Border
	uiStroke.Thickness = p2 or StyledTheme.Stroke.Thickness
	uiStroke.Transparency = p3 or StyledTheme.Stroke.TransparencyDefault
	uiStroke.Parent = parent
	return uiStroke
end

local function makeLabel(instance)
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Font = instance.Font or StyledTheme.Fonts.Regular
	textLabel.TextColor3 = instance.Color or StyledTheme.Colors.TextPrimary
	textLabel.TextSize = instance.TextSize or StyledTheme.TextSize.M
	textLabel.Text = instance.Text or ""
	textLabel.TextXAlignment = instance.XAlign or Enum.TextXAlignment.Center
	textLabel.TextYAlignment = instance.YAlign or Enum.TextYAlignment.Center
	textLabel.Size = instance.Size or UDim2.new(1, 0, 0, 20)
	textLabel.Position = instance.Position or UDim2.new(0, 0, 0, 0)
	textLabel.AnchorPoint = instance.AnchorPoint or Vector2.new(0, 0)
	textLabel.TextWrapped = instance.Wrapped or false
	textLabel.TextTruncate = instance.Truncate or Enum.TextTruncate.None
	textLabel.ZIndex = instance.ZIndex or 1
	textLabel.LayoutOrder = instance.LayoutOrder or 0
	textLabel.Parent = instance.Parent
	return textLabel
end

local resultsScreenUI = Instance.new("ScreenGui")
resultsScreenUI.Name = "ResultsScreenUI"
resultsScreenUI.ResetOnSpawn = false
resultsScreenUI.IgnoreGuiInset = true
resultsScreenUI.DisplayOrder = 50
resultsScreenUI.Enabled = false
resultsScreenUI.Parent = playerGui

local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(8, 8, 9)
overlay.BackgroundTransparency = 1
overlay.BorderSizePixel = 0
overlay.ZIndex = 1

overlay.Active = true
overlay.Parent = resultsScreenUI

local panel = Instance.new("ScrollingFrame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.new(0.5, 0, 0.5, 0)
panel.Size = UDim2.new(0.92, 0, 0.88, 0)
panel.BackgroundColor3 = StyledTheme.Colors.Background
panel.BackgroundTransparency = 0.3
panel.BorderSizePixel = 0
panel.ScrollBarThickness = StyledTheme.Sizes.ScrollBarThickness
panel.ScrollBarImageColor3 = StyledTheme.Colors.Accent
panel.CanvasSize = UDim2.new(0, 0, 0, 0)
panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
panel.ZIndex = 1

panel.Active = true
panel.Parent = overlay
local playerCard = StyledTheme.Radius.Large
local uiCorner3 = corner(panel, playerCard) -- inferred equivalent call
playerCard = StyledTheme.Colors.Border
uiCorner3 = Instance.new("UIStroke")
uiCorner3.Color = playerCard or StyledTheme.Colors.Border
uiCorner3.Thickness = 1
uiCorner3.Transparency = 0.3
uiCorner3.Parent = panel

playerCard = Instance.new("UIPadding")
playerCard.PaddingTop = UDim.new(0, StyledTheme.Spacing.XL)
playerCard.PaddingBottom = UDim.new(0, StyledTheme.Spacing.XXL)
playerCard.PaddingLeft = UDim.new(0, StyledTheme.Spacing.XL)
playerCard.PaddingRight = UDim.new(0, StyledTheme.Spacing.XL)
playerCard.Parent = panel

playerCard = Instance.new("UIListLayout")
playerCard.FillDirection = Enum.FillDirection.Vertical
playerCard.HorizontalAlignment = Enum.HorizontalAlignment.Center
playerCard.SortOrder = Enum.SortOrder.LayoutOrder
playerCard.Padding = UDim.new(0, StyledTheme.Spacing.XXL)
playerCard.Parent = panel

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.AnchorPoint = Vector2.new(1, 0)

closeButton.Position = UDim2.new(1, -52, 0, 76)
closeButton.Size = UDim2.new(0, StyledTheme.Sizes.ControlHeightL, 0, StyledTheme.Sizes.ControlHeightL)
closeButton.BackgroundColor3 = StyledTheme.Colors.Surface

closeButton.BackgroundTransparency = 0.15
closeButton.Text = "X"
closeButton.Font = StyledTheme.Fonts.Bold
closeButton.TextSize = 18
closeButton.TextColor3 = StyledTheme.Colors.TextPrimary
closeButton.AutoButtonColor = false
closeButton.ZIndex = 5
closeButton.Parent = overlay
playerCard = StyledTheme.Radius.Pill
uiCorner3 = Instance.new("UICorner")
uiCorner3.CornerRadius = playerCard or StyledTheme.Radius.Medium
uiCorner3.Parent = closeButton

playerCard = StyledTheme.Colors.Border
uiCorner3 = Instance.new("UIStroke")
uiCorner3.Color = playerCard or StyledTheme.Colors.Border
uiCorner3.Thickness = 1
uiCorner3.Transparency = 0.3
uiCorner3.Parent = closeButton

local label = makeLabel({
	Parent = overlay,
	Text = "ENTER TO CLOSE",
	Font = StyledTheme.Fonts.Medium,
	TextSize = StyledTheme.TextSize.S,
	Color = StyledTheme.Colors.TextDisabled,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -92, 0, 86),
	Size = UDim2.new(0, 160, 0, 16),
	XAlign = Enum.TextXAlignment.Right,
	ZIndex = 5
})

label.Visible = UserInputService.KeyboardEnabled

local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundTransparency = 1
header.Size = UDim2.new(1, 0, 0, 60)
header.LayoutOrder = 1
header.Parent = panel

makeLabel({
	Parent = header,
	Text = "RESULTS",
	Font = StyledTheme.Fonts.Bold,
	TextSize = 28,
	Color = StyledTheme.Colors.Accent,
	Size = UDim2.new(1, 0, 0, 32),
	Position = UDim2.new(0, 0, 0, 0)
})

local label2 = makeLabel({
	Parent = header,
	Text = "",
	Font = StyledTheme.Fonts.Medium,
	TextSize = StyledTheme.TextSize.XL,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, 0, 0, 22),
	Position = UDim2.new(0, 0, 0, 34)
})

local function formatDifficultyTimeline(difficultyTimeline)
	local lanesSet = {}
	local count = 0
	local v5 = nil

	for _, item in ipairs(difficultyTimeline) do
		if not item.lanes or lanesSet[item.lanes] then
			continue
		end

		lanesSet[item.lanes] = true
		count += 1
		v5 = v5 or item.lanes
	end

	local v6 = count > 1
	local v7 = count == 1 and string.format("  ·  %d Lanes", v5) or ""

	if #difficultyTimeline == 1 then
		return (difficultyTimeline[1].tier == "Normal" and "Natural" or difficultyTimeline[1].tier) .. v7
	end

	local v8 = {}

	for i = 1, math.min(#difficultyTimeline, 6) do
		local item = difficultyTimeline[i]
		local v9 = math.max(0, (math.floor(item.t + 0.5)))
		local v10 = math.floor(v9 / 60)
		local v11 = v9 % 60
		local v12 = item.tier == "Normal" and "Natural" or item.tier

		if v6 and item.lanes then
			v12 = string.format("%s, %d Lanes", v12, item.lanes)
		end

		table.insert(v8, string.format("%d:%02d (%s)", v10, v11, v12))
	end

	local v9 = table.concat(v8, "  ")

	if #difficultyTimeline > 6 then
		v9 ..= string.format("  +%d more", #difficultyTimeline - 6)
	end

	return v9 .. v7
end

local topRow = Instance.new("Frame")
topRow.Name = "TopRow"
topRow.BackgroundTransparency = 1
topRow.Size = UDim2.new(1, 0, 0, v and 658 or 316)
topRow.LayoutOrder = 2
topRow.Parent = panel

playerCard = Instance.new("Frame")
playerCard.Name = "PlayerCard"
playerCard.AnchorPoint = statsRow
playerCard.Position = categorySelector
playerCard.Size = UDim2.new(0, 240, 0, 316)
playerCard.BackgroundColor3 = StyledTheme.Colors.Surface
playerCard.BackgroundTransparency = 1
playerCard.ZIndex = 5
playerCard.Parent = topRow
statsRow = StyledTheme.Radius.Medium
categorySelector = Instance.new("UICorner")
categorySelector.CornerRadius = statsRow or StyledTheme.Radius.Medium
categorySelector.Parent = playerCard

statsRow = StyledTheme.Colors.Border
categorySelector = Instance.new("UIStroke")
categorySelector.Color = statsRow or StyledTheme.Colors.Border
categorySelector.Thickness = 0
categorySelector.Transparency = 0
categorySelector.Parent = playerCard

local label3 = makeLabel({
	Parent = playerCard,
	Text = "#-",
	Font = StyledTheme.Fonts.Bold,
	TextSize = 20,
	Color = StyledTheme.Colors.Accent,
	Size = UDim2.new(0.5, 0, 0, 28),
	Position = UDim2.new(0, 14, 0, 12),
	XAlign = Enum.TextXAlignment.Left,
	ZIndex = 6
})

local label4 = makeLabel({
	Parent = playerCard,
	Text = "-",
	Font = StyledTheme.Fonts.Medium,
	TextSize = 16,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(0.5, -14, 0, 28),
	Position = UDim2.new(0.5, 0, 0, 12),
	XAlign = Enum.TextXAlignment.Right,
	ZIndex = 6
})

local avatar = Instance.new("ImageLabel")
avatar.Name = "Avatar"
avatar.AnchorPoint = Vector2.new(0.5, 0)
avatar.Position = UDim2.new(0.5, 0, 0, 46)
avatar.Size = UDim2.new(0, 120, 0, 120)
avatar.BackgroundColor3 = StyledTheme.Colors.Background
avatar.BackgroundTransparency = 0.35
avatar.ScaleType = Enum.ScaleType.Crop
avatar.ZIndex = 6
avatar.Parent = playerCard
statsRow = StyledTheme.Radius.Medium
categorySelector = Instance.new("UICorner")
categorySelector.CornerRadius = statsRow or StyledTheme.Radius.Medium
categorySelector.Parent = avatar

statsRow = StyledTheme.Colors.Border
categorySelector = Instance.new("UIStroke")
categorySelector.Color = statsRow or StyledTheme.Colors.Border
categorySelector.Thickness = 1
categorySelector.Transparency = 0.3
categorySelector.Parent = avatar

local label5 = makeLabel({
	Parent = playerCard,
	Text = "-",
	Font = StyledTheme.Fonts.Bold,
	TextSize = 16,
	Color = StyledTheme.Colors.TextPrimary,
	Size = UDim2.new(1, -20, 0, 22),
	Position = UDim2.new(0, 10, 0, 174),
	Truncate = Enum.TextTruncate.AtEnd,
	ZIndex = 6
})

local label6 = makeLabel({
	Parent = playerCard,
	Text = "",
	Font = StyledTheme.Fonts.Bold,
	TextSize = 12,
	Color = StyledTheme.Colors.Accent,
	Size = UDim2.new(1, -20, 0, 16),
	Position = UDim2.new(0, 10, 0, 198),
	Truncate = Enum.TextTruncate.AtEnd,
	ZIndex = 6
})

local label7 = makeLabel({
	Parent = playerCard,
	Text = "0.0%",
	Font = StyledTheme.Fonts.Bold,
	TextSize = 24,
	Color = StyledTheme.Colors.Accent,
	Size = UDim2.new(1, -20, 0, 28),
	Position = UDim2.new(0, 10, 0, 222),
	ZIndex = 6
})

local label8 = makeLabel({
	Parent = playerCard,
	Text = "PERSONAL BEST",
	Font = StyledTheme.Fonts.Medium,
	TextSize = 12,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, -20, 0, 14),
	Position = UDim2.new(0, 10, 0, 264),
	ZIndex = 6
})

local label9 = makeLabel({
	Parent = playerCard,
	Text = "-",
	Font = StyledTheme.Fonts.Bold,
	TextSize = 15,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, -20, 0, 20),
	Position = UDim2.new(0, 10, 0, 282),
	Truncate = Enum.TextTruncate.AtEnd,
	ZIndex = 6
})

local label10 = makeLabel({
	Parent = playerCard,
	Text = "",
	Font = StyledTheme.Fonts.Medium,
	TextSize = 12,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, -20, 0, 14),
	Position = UDim2.new(0, 10, 0, 302),
	Truncate = Enum.TextTruncate.AtEnd,
	ZIndex = 6
})

label10.Visible = false

local centerStats = Instance.new("Frame")
centerStats.Name = "CenterStats"
centerStats.BackgroundTransparency = 1
centerStats.AnchorPoint = statsRowHolder

centerStats.Position = udim
centerStats.Size = udim2
centerStats.Parent = topRow

local label11 = makeLabel({
	Parent = centerStats,
	Text = "-",
	Font = StyledTheme.Fonts.Bold,
	TextSize = 72,
	Color = StyledTheme.Colors.Accent,
	Size = UDim2.new(1, 0, 0, 84),
	Position = UDim2.new(0, 0, 0, 0)
})

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = label11

local label12 = makeLabel({
	Parent = centerStats,
	Text = "",
	Font = StyledTheme.Fonts.Medium,
	TextSize = 16,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, 0, 0, 18),
	Position = UDim2.new(0, 0, 0, 88)
})

local label13 = makeLabel({
	Parent = centerStats,
	Text = "",
	Font = StyledTheme.Fonts.Bold,
	TextSize = 24,
	Color = StyledTheme.Colors.Accent,
	Size = UDim2.new(1, 0, 0, 28),
	Position = UDim2.new(0, 0, 0, 108)
})

label13.RichText = true

local label14 = makeLabel({
	Parent = centerStats,
	Text = "0.00%",
	Font = StyledTheme.Fonts.Bold,
	TextSize = 34,
	Color = StyledTheme.Colors.TextPrimary,
	Size = UDim2.new(1, 0, 0, 40),
	Position = UDim2.new(0, 0, 0, 140)
})

makeLabel({
	Parent = centerStats,
	Text = "ACCURACY",
	Font = StyledTheme.Fonts.Medium,
	TextSize = StyledTheme.TextSize.M,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.new(0, 0, 0, 180)
})

statsRow = Instance.new("Frame")
statsRow.Name = "StatsRow"
statsRow.BackgroundTransparency = 1
statsRow.Size = UDim2.new(1, 0, 0, 60)
statsRow.Position = UDim2.new(0, 0, 0, 178)
statsRow.Parent = centerStats

categorySelector = Instance.new("Frame")
categorySelector.BackgroundTransparency = 1
categorySelector.Size = UDim2.new(0.5, 0, 1, 0)
categorySelector.Parent = statsRow

local label15 = makeLabel({
	Parent = centerStats,
	Text = "",
	Font = StyledTheme.Fonts.Medium,
	TextSize = 16,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, 0, 0, 20),
	Position = UDim2.new(0, 0, 0, 242)
})

local label16 = makeLabel({
	Parent = centerStats,
	Text = "",
	Font = StyledTheme.Fonts.Medium,
	TextSize = StyledTheme.TextSize.M,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.new(0, 0, 0, 266)
})

local statsStack = Instance.new("Frame")
statsStack.Name = "StatsStack"
statsStack.BackgroundTransparency = 1
statsStack.Position = UDim2.new(0, 0, 0, 198)
statsStack.Size = UDim2.new(1, 0, 0, 0)
statsStack.AutomaticSize = Enum.AutomaticSize.Y
statsStack.Parent = centerStats

statsRowHolder = Instance.new("UIListLayout")
statsRowHolder.FillDirection = Enum.FillDirection.Vertical
statsRowHolder.SortOrder = Enum.SortOrder.LayoutOrder
statsRowHolder.Padding = UDim.new(0, 4)
statsRowHolder.Parent = statsStack

local label17 = makeLabel({
	Parent = statsStack,
	Text = "",
	Wrapped = true,
	Font = StyledTheme.Fonts.Medium,
	TextSize = StyledTheme.TextSize.M,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, 0, 0, 18),
	LayoutOrder = 1,
	YAlign = Enum.TextYAlignment.Top
})

label17.AutomaticSize = Enum.AutomaticSize.Y
label17.Visible = false

local label18 = makeLabel({
	Parent = statsStack,
	Text = "",
	Wrapped = true,
	Font = StyledTheme.Fonts.Medium,
	TextSize = StyledTheme.TextSize.M,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, 0, 0, 18),
	LayoutOrder = 0,
	YAlign = Enum.TextYAlignment.Top
})

label18.AutomaticSize = Enum.AutomaticSize.Y
label18.Visible = false

local label19 = makeLabel({
	Parent = statsStack,
	Text = "",
	Wrapped = true,
	Font = StyledTheme.Fonts.Medium,
	TextSize = StyledTheme.TextSize.M,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, 0, 0, 18),
	LayoutOrder = -1,
	YAlign = Enum.TextYAlignment.Top
})

label19.AutomaticSize = Enum.AutomaticSize.Y
label19.Visible = false

statsRowHolder = Instance.new("Frame")
statsRowHolder.Name = "StatsRowHolder"
statsRowHolder.BackgroundTransparency = 1
statsRowHolder.Size = UDim2.new(1, 0, 0, 68)
statsRowHolder.LayoutOrder = 2
statsRowHolder.Parent = statsStack
statsRow.Position = UDim2.new(0, 0, 0, 8)
statsRow.Parent = statsRowHolder

local label20 = makeLabel({
	Parent = statsStack,
	Text = "",
	Font = StyledTheme.Fonts.Bold,
	TextSize = 17,
	Color = StyledTheme.Colors.Accent,
	Size = UDim2.new(1, 0, 0, 22),
	LayoutOrder = 3
})

label20.Visible = false

label15.Position = UDim2.new(0, 0, 0, 0)
label15.LayoutOrder = 4
label15.Parent = statsStack

label16.Position = UDim2.new(0, 0, 0, 0)
label16.LayoutOrder = 5
label16.Parent = statsStack

local label21 = makeLabel({
	Parent = statsStack,
	Text = "",
	Font = StyledTheme.Fonts.Medium,
	TextSize = 16,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, 0, 0, 16),
	LayoutOrder = 6
})

label21.Visible = false

local function escapeRichText(p) -- 2 equivalent calls inferred from this helper
	return (tostring(p):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local label22 = makeLabel({
	Parent = statsStack,
	Text = "",
	Wrapped = true,
	Font = StyledTheme.Fonts.Medium,
	TextSize = 16,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, 0, 0, 18),
	LayoutOrder = 7,
	YAlign = Enum.TextYAlignment.Top
})

label22.RichText = true
label22.AutomaticSize = Enum.AutomaticSize.Y
label22.Visible = false

statsRowHolder = Instance.new("UIPadding")
statsRowHolder.PaddingTop = UDim.new(0, 6)
statsRowHolder.Parent = label22

local label23 = makeLabel({
	Parent = panel,
	Text = "",
	Wrapped = true,
	Font = StyledTheme.Fonts.Regular,
	TextSize = StyledTheme.TextSize.S,
	Color = StyledTheme.Colors.TextDisabled,
	Size = UDim2.new(1, 0, 0, 16),
	LayoutOrder = 100
})

label23.AutomaticSize = Enum.AutomaticSize.Y
label23.Visible = false

local label24 = makeLabel({
	Parent = panel,
	Text = "",
	Font = StyledTheme.Fonts.Medium,
	TextSize = StyledTheme.TextSize.S,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, 0, 0, 16),
	LayoutOrder = 101
})

label24.Visible = false

local function syncCenterHeight()
	local v5 = math.max(318, 198 + statsStack.AbsoluteSize.Y + 8)

	centerStats.Size = v and UDim2.new(1, 0, 0, v5) or UDim2.new(1, -354, 0, v5)
	topRow.Size = UDim2.new(1, 0, 0, v and v5 + 340 or math.max(316, v5))
end
statsStack:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncCenterHeight)

local label25 = makeLabel({
	Parent = categorySelector,
	Text = "0",
	Font = StyledTheme.Fonts.Bold,
	TextSize = 26,
	Color = StyledTheme.Colors.TextPrimary,
	Size = UDim2.new(1, 0, 0, 30)
})

makeLabel({
	Parent = categorySelector,
	Text = "SCORE",
	Font = StyledTheme.Fonts.Medium,
	TextSize = StyledTheme.TextSize.S,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.new(0, 0, 0, 32)
})

local frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.Size = UDim2.new(0.5, 0, 1, 0)
frame.Position = UDim2.new(0.5, 0, 0, 0)
frame.Parent = statsRow

local label26 = makeLabel({
	Parent = frame,
	Text = "0",
	Font = StyledTheme.Fonts.Bold,
	TextSize = 26,
	Color = StyledTheme.Colors.TextPrimary,
	Size = UDim2.new(1, 0, 0, 30)
})

local comboTierBox = Instance.new("CanvasGroup")
comboTierBox.Name = "ComboTierBox"
comboTierBox.AnchorPoint = Vector2.new(0.5, 0.5)
comboTierBox.Position = UDim2.new(0.5, 0, 0, 15)
comboTierBox.Size = UDim2.fromOffset(0, 0)
comboTierBox.BackgroundColor3 = Color3.fromHex("#BFC3C9")
comboTierBox.BackgroundTransparency = 0
comboTierBox.GroupTransparency = 1
comboTierBox.BorderSizePixel = 0
comboTierBox.Visible = false
comboTierBox.ZIndex = 1

statsRow = Instance.new("UICorner")
statsRow.CornerRadius = UDim.new(0, 3)
statsRow.Parent = comboTierBox

statsRow = Instance.new("UIGradient")
statsRow.Rotation = 90
statsRow.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromHex("#D3D7DC")),
	ColorSequenceKeypoint.new(0.5, Color3.fromHex("#BFC3C9")),
	ColorSequenceKeypoint.new(1, Color3.fromHex("#A3A8AF"))
})

statsRow.Parent = comboTierBox

statsRow = Instance.new("UIStroke")
statsRow.Color = Color3.fromHex("#4A4E54")
statsRow.Thickness = 1
statsRow.Transparency = 0.1
statsRow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
statsRow.Parent = comboTierBox

local function plateLine(data)
	local frame2 = Instance.new("Frame")
	frame2.AnchorPoint = data.Anchor or Vector2.new(0.5, 0.5)
	frame2.Position = data.Position
	frame2.Size = data.Size
	frame2.Rotation = data.Rotation or 0
	frame2.BackgroundColor3 = data.Color
	frame2.BackgroundTransparency = data.Transparency
	frame2.BorderSizePixel = 0
	frame2.ZIndex = 1
	frame2.Parent = comboTierBox
	return frame2
end

plateLine({
	Anchor = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 1),
	Size = UDim2.new(1, -6, 0, 1),
	Color = Color3.fromHex("#FFFFFF"),
	Transparency = 0.45
})
plateLine({
	Anchor = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -1),
	Size = UDim2.new(1, -6, 0, 1),
	Color = Color3.fromHex("#3A3D42"),
	Transparency = 0.6
})
statsRow = { "Perfect", "Great", "Good", "OK", "Miss", "Wrong" }

for _, v5 in ipairs({
	{ 0.14, 0.3, 14, -8, false },
	{ 0.36, 0.8, 11, 6, true },
	{ 0.64, 0.2, 16, 12, false },
	{ 0.82, 0.7, 12, -10, true },
	{ 0.5, 0.55, 9, -4, false },
	{ 0.91, 0.28, 8, 15, true },
	{ 0.26, 0.58, 7, 20, false }
}) do
	plateLine({
		Position = UDim2.new(v5[1], 0, v5[2], 0),
		Size = UDim2.fromOffset(v5[3], 1),
		Rotation = v5[4],
		Color = v5[5] and Color3.fromHex("#FFFFFF") or Color3.fromHex("#34373C"),
		Transparency = v5[5] and 0.4 or 0.7
	})
end

local function bolt(p, p2, p3, p4)
	local frame2 = Instance.new("Frame")
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.Position = UDim2.new(p, p3, p2, p4)
	frame2.Size = UDim2.fromOffset(6, 6)
	frame2.BackgroundColor3 = Color3.fromHex("#575B61")
	frame2.BorderSizePixel = 0
	frame2.ZIndex = 1
	frame2.Parent = comboTierBox
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = frame2
	local frame3 = Instance.new("Frame")
	frame3.AnchorPoint = Vector2.new(0.5, 0.5)
	frame3.Position = UDim2.new(0.4, 0, 0.4, 0)
	frame3.Size = UDim2.fromOffset(3, 3)
	frame3.BackgroundColor3 = Color3.fromHex("#C9CDD2")
	frame3.BorderSizePixel = 0
	frame3.ZIndex = 1
	frame3.Parent = frame2
	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = UDim.new(1, 0)
	uiCorner2.Parent = frame3
	local frame4 = Instance.new("Frame")
	frame4.AnchorPoint = Vector2.new(0.5, 0.5)
	frame4.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame4.Size = UDim2.fromOffset(5, 1)
	frame4.Rotation = 35
	frame4.BackgroundColor3 = Color3.fromHex("#2B2E32")
	frame4.BackgroundTransparency = 0.2
	frame4.BorderSizePixel = 0
	frame4.ZIndex = 1
	frame4.Parent = frame2
end
bolt(0, 0, 5, 5)
bolt(1, 0, -5, 5)
bolt(0, 1, 5, -5)
bolt(1, 1, -5, -5)

comboTierBox.Parent = frame
label26.ZIndex = 2

makeLabel({
	Parent = frame,
	Text = "MAX COMBO",
	Font = StyledTheme.Fonts.Medium,
	TextSize = StyledTheme.TextSize.S,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.new(0, 0, 0, 32)
})

local judgements = Instance.new("Frame")
judgements.Name = "Judgements"
judgements.BackgroundColor3 = StyledTheme.Colors.Surface
judgements.BackgroundTransparency = 1

judgements.Size = UDim2.new(
	1,
	0,
	0,
	#statsRow * 24 + (#statsRow - 1) * StyledTheme.Spacing.S + 2 * StyledTheme.Spacing.L
)
judgements.LayoutOrder = 3
judgements.Parent = panel
categorySelector = StyledTheme.Radius.Medium
statsRowHolder = Instance.new("UICorner")
statsRowHolder.CornerRadius = categorySelector or StyledTheme.Radius.Medium
statsRowHolder.Parent = judgements

categorySelector = StyledTheme.Colors.Border
statsRowHolder = Instance.new("UIStroke")
statsRowHolder.Color = categorySelector or StyledTheme.Colors.Border
statsRowHolder.Thickness = 1
statsRowHolder.Transparency = 0.3
statsRowHolder.Parent = judgements

categorySelector = Instance.new("UIPadding")
categorySelector.PaddingTop = UDim.new(0, StyledTheme.Spacing.L)
categorySelector.PaddingBottom = UDim.new(0, StyledTheme.Spacing.L)
categorySelector.PaddingLeft = UDim.new(0, StyledTheme.Spacing.L)
categorySelector.PaddingRight = UDim.new(0, StyledTheme.Spacing.L)
categorySelector.Parent = judgements

local judgementsList = Instance.new("Frame")
judgementsList.Name = "JudgementsList"
judgementsList.BackgroundTransparency = 1
judgementsList.Size = UDim2.new(0.5, 0, 1, 0)
judgementsList.Parent = judgements

categorySelector = Instance.new("UIListLayout")
categorySelector.FillDirection = Enum.FillDirection.Vertical
categorySelector.SortOrder = Enum.SortOrder.LayoutOrder
categorySelector.Padding = UDim.new(0, StyledTheme.Spacing.S)
categorySelector.Parent = judgementsList

local v5 = {}
local v6 = {}

for i, v7 in ipairs(statsRow) do
	local frame2 = Instance.new("Frame")
	frame2.BackgroundTransparency = 1
	frame2.Size = UDim2.new(1, 0, 0, 24)
	frame2.LayoutOrder = i
	frame2.Parent = judgementsList

	local frame3 = Instance.new("Frame")
	frame3.Size = UDim2.new(0, 10, 0, 10)
	frame3.Position = UDim2.new(0, 0, 0.5, -5)
	frame3.BackgroundColor3 = getJudgmentColor(v7) -- inferred equivalent call
	frame3.BorderSizePixel = 0
	frame3.Parent = frame2
	corner(frame3, StyledTheme.Radius.Pill) -- inferred equivalent call
	v5[v7] = frame3

	makeLabel({
		Parent = frame2,
		Text = string.upper(v7),
		Font = StyledTheme.Fonts.Medium,
		TextSize = StyledTheme.TextSize.L,
		Color = StyledTheme.Colors.TextPrimary,
		Size = UDim2.new(0.6, 0, 1, 0),
		Position = UDim2.new(0, 20, 0, 0),
		XAlign = Enum.TextXAlignment.Left
	})

	v6[v7] = makeLabel({
		Parent = frame2,
		Text = "× 0",
		Font = StyledTheme.Fonts.Bold,
		TextSize = StyledTheme.TextSize.L,
		Color = getJudgmentColor(v7), -- inferred equivalent call
		Size = UDim2.new(0.4, -20, 1, 0),
		Position = UDim2.new(0.6, 0, 0, 0),
		XAlign = Enum.TextXAlignment.Right
	})
end

local function commas(value) -- 3 equivalent calls inferred from this helper
	return (tostring((math.floor((value or 0) + 0.5))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

local v7 = {
	{
		Key = "Score",
		Caption = "TOTAL SCORE",
		Format = function(value)
			return "+" .. commas(value) -- inferred equivalent call
		end
	},
	{
		Key = "PeakAccuracy",
		Caption = "PEAK ACCURACY",
		Format = function(p)
			return string.format("%.2f%%", p)
		end
	},
	{
		Key = "Gigs",
		Compact = true,
		NoCount = true,
		Format = function(value)
			return "+" .. commas(value) .. " GIGS PLAYED" -- inferred equivalent call
		end,
		Sub = function(p)
			local title = p.Extras and p.Extras.Title

			if type(title) ~= "table" then
				return nil
			end

			if title.NewTitle and title.Title then
				return "NEW TITLE  ·  " .. tostring(title.Title), true
			end

			if type(title.ToNext) == "number" and title.NextTitle then
				return
					string.format(
						"%d %s to %s",
						title.ToNext,
						title.ToNext == 1 and "gig" or "gigs",
						(tostring(title.NextTitle))
					),
					false
			end

			return nil
		end
	},
	{
		Key = "Popularity",
		Compact = true,
		NoCount = true,
		Format = function(value)
			return "+" .. commas(value) .. " POPULARITY" -- inferred equivalent call
		end
	}
}

local rewards = Instance.new("Frame")
rewards.Name = "Rewards"
rewards.BackgroundTransparency = 1
rewards.AnchorPoint = Vector2.new(1, 0.5)
rewards.Position = UDim2.new(1, 0, 0.5, 0)
rewards.Size = UDim2.new(0.44, 0, 1, 0)
rewards.Visible = false
rewards.Parent = judgements

local content = Instance.new("Frame")
content.Name = "Content"
content.BackgroundTransparency = 1
content.AnchorPoint = Vector2.new(0.5, 0.5)
content.Position = UDim2.new(0.5, 0, 0.5, 0)
content.Size = UDim2.new(1, 0, 1, 0)
content.Parent = rewards

local uiScale2 = Instance.new("UIScale")
uiScale2.Parent = content

statsRow = Instance.new("UIListLayout")
statsRow.FillDirection = Enum.FillDirection.Vertical
statsRow.HorizontalAlignment = Enum.HorizontalAlignment.Center
statsRow.VerticalAlignment = Enum.VerticalAlignment.Center
statsRow.SortOrder = Enum.SortOrder.LayoutOrder
statsRow.Padding = UDim.new(0, 4)
statsRow.Parent = content
local v8 = { Rows = {} }

for i, v9 in ipairs(v7) do
	local frame2 = Instance.new("Frame")
	frame2.Name = "Reward_" .. v9.Key
	frame2.BackgroundTransparency = 1
	frame2.Size = UDim2.new(1, 0, 0, v9.Info and 20 or v9.Compact and 24 or 72)
	frame2.LayoutOrder = i
	frame2.Visible = false
	frame2.Parent = content

	local uiScale3 = Instance.new("UIScale")
	uiScale3.Parent = frame2

	if v9.Info then
		local label27 = makeLabel({
			Parent = frame2,
			Text = "",
			Font = StyledTheme.Fonts.Medium,
			TextSize = 15,
			Color = StyledTheme.Colors.TextSecondary,
			Size = UDim2.new(1, 0, 1, 0)
		})

		v8.Rows[v9.Key] = { Row = frame2, Value = label27, Scale = uiScale3 }
	elseif v9.Compact then
		local label27 = makeLabel({
			Parent = frame2,
			Text = v9.Format(1),
			Font = StyledTheme.Fonts.Bold,
			TextSize = 17,
			Color = StyledTheme.Colors.Accent,
			Size = UDim2.new(1, 0, 0, 24)
		})
		local sub

		if v9.Sub then
			sub = makeLabel({
				Parent = frame2,
				Text = "",
				Font = StyledTheme.Fonts.Medium,
				TextSize = 13,
				Color = StyledTheme.Colors.TextSecondary,
				Size = UDim2.new(1, 0, 0, 15),
				Position = UDim2.new(0, 0, 0, 24)
			})

			sub.Visible = false
		end

		v8.Rows[v9.Key] = { Row = frame2, Value = label27, Sub = sub, Scale = uiScale3 }
	else
		local parent = makeLabel({
			Parent = frame2,
			Text = "NEW",
			Font = StyledTheme.Fonts.Bold,
			TextSize = 12,
			Color = StyledTheme.Colors.Accent,
			Size = UDim2.new(0, 44, 0, 18),
			Position = UDim2.new(0.5, 0, 0, 0),
			AnchorPoint = Vector2.new(0.5, 0)
		})

		parent.BackgroundColor3 = StyledTheme.Colors.Accent
		parent.BackgroundTransparency = 0.8
		parent.Rotation = -3
		local v10 = UDim.new(0, 4)
		local uiCorner = corner(parent, v10) -- inferred equivalent call
		v10 = StyledTheme.Colors.Accent
		uiCorner = Instance.new("UIStroke")
		uiCorner.Color = v10 or StyledTheme.Colors.Border
		uiCorner.Thickness = 1
		uiCorner.Transparency = 0.5
		uiCorner.Parent = parent

		uiCorner.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		parent = makeLabel({
			Parent = frame2,
			Text = v9.Format(0),
			Font = StyledTheme.Fonts.Bold,
			TextSize = 28,
			Color = StyledTheme.Colors.Accent,
			Size = UDim2.new(1, 0, 0, 34),
			Position = UDim2.new(0, 0, 0, 20)
		})

		makeLabel({
			Parent = frame2,
			Text = v9.Caption,
			Font = StyledTheme.Fonts.Medium,
			TextSize = 16,
			Color = StyledTheme.Colors.TextSecondary,
			Size = UDim2.new(1, 0, 0, 16),
			Position = UDim2.new(0, 0, 0, 56)
		})

		v8.Rows[v9.Key] = { Row = frame2, Value = parent, Scale = uiScale3 }
	end
end

local count = 0
local v9 = nil

local function refit()
	local total = 0
	local count2 = 0

	for _, v10 in ipairs(v7) do
		local row = v8.Rows[v10.Key]

		if not (row and row.Row.Visible) then
			continue
		end

		total += row.Row.Size.Y.Offset
		count2 += 1
	end

	if count2 > 1 then
		total += (count2 - 1) * 4
	end

	local v10 = math.max(judgements.Size.Y.Offset - 2 * StyledTheme.Spacing.L, 1)
	uiScale2.Scale = v10 < total and math.max(v10 / total, 0.5) or 1
end

local function popIn(p, scale)
	p.Scale.Scale = scale
	TweenService:Create(p.Scale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
end

local function present(data, data2, p, p2, p3)
	data2.Row.Visible = true
	popIn(data2, 0.6)

	if data.Sub and data2.Sub then
		local success3, result3, v10 = pcall(data.Sub, p2)

		if success3 and type(result3) == "string" and result3 ~= "" then
			data2.Sub.Text = result3
			data2.Sub.TextColor3 = v10 and StyledTheme.Colors.Accent or StyledTheme.Colors.TextSecondary
			data2.Sub.Visible = true
			data2.Row.Size = UDim2.new(1, 0, 0, 42)
		else
			data2.Sub.Text = ""
			data2.Sub.Visible = false
			data2.Row.Size = UDim2.new(1, 0, 0, 24)
		end
	end

	if data.NoCount then
		data2.Value.Text = data.Format(p)
		return
	end

	data2.Value.Text = data.Format(0)
	task.spawn(function()
		task.wait(0.35)
		local lastTime = os.clock()

		while p3 == count do
			local v10 = math.clamp((os.clock() - lastTime) / 0.9, 0, 1)
			local v11 = 1 - (1 - v10) ^ 3
			data2.Value.Text = data.Format(p * v11)

			if v10 >= 1 then
				break
			end

			RunService.RenderStepped:Wait()
		end

		if p3 == count then
			data2.Value.Text = data.Format(p)
		end
	end)
end

function v8.Apply(p)
	count += 1
	local v10 = count
	v9 = p
	local rewards2 = p and p.Rewards
	local isAutoPlayed = p and p.IsAutoPlayed
	local visible = false

	for _, v11 in ipairs(v7) do
		local row = v8.Rows[v11.Key]

		if v11.Info then
			local text = nil
			local v12 = false

			if p and not isAutoPlayed then
				local success3, result3, v13 = pcall(v11.Info, p)

				if success3 then
					v12 = v13
					text = result3
				end
			end

			if type(text) == "string" and text ~= "" then
				row.Row.Visible = true
				row.Value.Text = text
				row.Value.TextColor3 = v12 and StyledTheme.Colors.Accent or StyledTheme.Colors.TextSecondary
				popIn(row, 0.8)
				visible = true
			else
				row.Row.Visible = false
			end
		else
			local v12

			if type(rewards2) == "table" then
				v12 = rewards2[v11.Key] or nil
			end

			if type(v12) == "number" and v12 > 0 and not isAutoPlayed then
				present(v11, row, v12, p, v10)
				visible = true
			else
				row.Row.Visible = false
			end
		end
	end

	rewards.Visible = visible
	refit()
end

function v8.AddLate(p, value)
	local v10 = v9

	if not v10 or v10.IsAutoPlayed or type(value) ~= "number" or value <= 0 then
		return
	end

	for _, v11 in ipairs(v7) do
		if v11.Key == p and not v11.Info then
			v10.Rewards = type(v10.Rewards) == "table" and v10.Rewards or {}
			v10.Rewards[p] = value
			present(v11, v8.Rows[p], value, v10, count)
			rewards.Visible = true
			refit()
			break
		end
	end
end

local timeline = Instance.new("Frame")
timeline.Name = "Timeline"
timeline.BackgroundColor3 = StyledTheme.Colors.Surface
timeline.BackgroundTransparency = 1
timeline.Size = UDim2.new(1, 0, 0, 140)
timeline.LayoutOrder = 4
timeline.Parent = panel
statsRow = StyledTheme.Radius.Medium
categorySelector = Instance.new("UICorner")
categorySelector.CornerRadius = statsRow or StyledTheme.Radius.Medium
categorySelector.Parent = timeline

statsRow = StyledTheme.Colors.Border
categorySelector = Instance.new("UIStroke")
categorySelector.Color = statsRow or StyledTheme.Colors.Border
categorySelector.Thickness = 1
categorySelector.Transparency = 0.3
categorySelector.Parent = timeline

makeLabel({
	Parent = timeline,
	Text = "PERFORMANCE TIMELINE",
	Font = StyledTheme.Fonts.Bold,
	TextSize = StyledTheme.TextSize.M,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, -StyledTheme.Spacing.L * 2, 0, 18),
	Position = UDim2.new(0, StyledTheme.Spacing.L, 0, StyledTheme.Spacing.M),
	XAlign = Enum.TextXAlignment.Left
})

local graphArea = Instance.new("Frame")
graphArea.Name = "GraphArea"
graphArea.BackgroundTransparency = 1
graphArea.Size = UDim2.new(1, -StyledTheme.Spacing.L * 2, 0, 70)
graphArea.Position = UDim2.new(0, StyledTheme.Spacing.L, 0, 36)
graphArea.Parent = timeline

local label27 = makeLabel({
	Parent = timeline,
	Text = "",
	Font = StyledTheme.Fonts.Medium,
	TextSize = StyledTheme.TextSize.S,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, -StyledTheme.Spacing.L * 2, 0, 16),
	Position = UDim2.new(0, StyledTheme.Spacing.L, 0, 112),
	XAlign = Enum.TextXAlignment.Left
})

local rankings = Instance.new("Frame")
rankings.Name = "Rankings"
rankings.BackgroundColor3 = StyledTheme.Colors.Surface
rankings.BackgroundTransparency = 1
rankings.AutomaticSize = Enum.AutomaticSize.Y
rankings.Size = UDim2.new(1, 0, 0, 0)
rankings.LayoutOrder = 5
rankings.Parent = panel
statsRow = StyledTheme.Radius.Medium
categorySelector = Instance.new("UICorner")
categorySelector.CornerRadius = statsRow or StyledTheme.Radius.Medium
categorySelector.Parent = rankings

statsRow = StyledTheme.Colors.Border
categorySelector = Instance.new("UIStroke")
categorySelector.Color = statsRow or StyledTheme.Colors.Border
categorySelector.Thickness = 1
categorySelector.Transparency = 0.3
categorySelector.Parent = rankings

statsRow = Instance.new("UIPadding")
statsRow.PaddingTop = UDim.new(0, StyledTheme.Spacing.L)
statsRow.PaddingBottom = UDim.new(0, StyledTheme.Spacing.L)
statsRow.PaddingLeft = UDim.new(0, StyledTheme.Spacing.L)
statsRow.PaddingRight = UDim.new(0, StyledTheme.Spacing.L)
statsRow.Parent = rankings

statsRow = Instance.new("UIListLayout")
statsRow.FillDirection = Enum.FillDirection.Vertical
statsRow.SortOrder = Enum.SortOrder.LayoutOrder
statsRow.Padding = UDim.new(0, StyledTheme.Spacing.S)
statsRow.Parent = rankings

makeLabel({
	Parent = rankings,
	Text = "SESSION RANKINGS",
	Font = StyledTheme.Fonts.Bold,
	TextSize = StyledTheme.TextSize.M,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, 0, 0, 18),
	LayoutOrder = 0,
	XAlign = Enum.TextXAlignment.Left
})

local function renderTimelineLegacy(list)
	for _, child in ipairs(graphArea:GetChildren()) do
		child:Destroy()
	end

	if list and #list ~= 0 then
		local frame2 = Instance.new("Frame")
		frame2.BackgroundTransparency = 1
		frame2.Size = UDim2.new(1, 0, 1, 0)
		frame2.Parent = graphArea

		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uiListLayout.Padding = UDim.new(0, 2)
		uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uiListLayout.Parent = frame2
		local v10 = nil
		local v11 = nil

		for i, item in ipairs(list) do
			if not (not v10 or item.Accuracy > v10.Accuracy) then
				continue
			end

			v11 = i
			v10 = item
		end

		for i, item in ipairs(list) do
			local v12 = math.clamp(item.Accuracy, 0.05, 1)
			local frame3 = Instance.new("Frame")
			frame3.LayoutOrder = i
			frame3.Size = UDim2.new(1 / #list, -2, v12, 0)
			frame3.BackgroundColor3 = i == v11 and StyledTheme.Colors.Accent or StyledTheme.Colors.Success
			frame3.BackgroundTransparency = i == v11 and 0 or 0.25
			frame3.BorderSizePixel = 0
			frame3.Parent = frame2
			corner(frame3, UDim.new(0, 2)) -- inferred equivalent call
		end

		if not v10 then
			label27.Text = ""

			return
		end

		local function formatTime(elapsed)
			local v12 = math.max(0, (math.floor(elapsed)))
			return string.format("%d:%02d", math.floor(v12 / 60), v12 % 60)
		end

		label27.Text = string.format("PEAK PERFORMANCE  %.1f%%  (%s)", v10.Accuracy * 100, formatTime(v10.Elapsed))
	else
		makeLabel({
			Parent = graphArea,
			Text = "No data yet",
			Font = StyledTheme.Fonts.Regular,
			TextSize = StyledTheme.TextSize.S,
			Color = StyledTheme.Colors.TextDisabled,
			Size = UDim2.new(1, 0, 1, 0)
		})

		label27.Text = ""
	end
end

local l = StyledTheme.Spacing.L

local v10 = { "Perfect", "Great", "Good", "OK", "Miss", "Wrong" }

local v11 = { 6, 6, 6, 6, 10, 8 }
local v12 = { 1, 0.85, 0.6, 0.35, 0 }

local color = Color3.fromRGB(206, 190, 150)
local color2 = Color3.fromRGB(96, 90, 80)
local color3 = Color3.fromRGB(14, 13, 12)
local color4 = Color3.fromRGB(17, 16, 15)
local color5 = Color3.fromRGB(64, 58, 50)
local color6 = Color3.fromRGB(30, 28, 26)
local color7 = Color3.fromRGB(226, 184, 72)
local color8 = Color3.fromRGB(118, 200, 240)
local color9 = Color3.fromRGB(222, 208, 176)
local color10 = Color3.fromRGB(150, 34, 30)

local v13 = {
	{ 0, Color3.fromRGB(150, 36, 40) },
	{ 0.35, Color3.fromRGB(206, 104, 48) },
	{ 0.6, Color3.fromRGB(214, 172, 66) },
	{ 0.8, Color3.fromRGB(122, 168, 76) },
	{ 1, Color3.fromRGB(56, 150, 92) }
}

local function heatColor(value)
	local v14 = math.clamp(value, 0, 1)

	for i = 2, #v13 do
		local v15 = v13[i - 1]
		local v16 = v13[i]

		if v14 <= v16[1] then
			return v15[2]:Lerp(v16[2], (v14 - v15[1]) / (v16[1] - v15[1]))
		end
	end

	return v13[#v13][2]
end

local function fmtTime(p) -- 2 equivalent calls inferred from this helper
	local v14 = math.max(0, (math.floor(p)))
	return string.format("%d:%02d", math.floor(v14 / 60), v14 % 60)
end

local function mk(className, parent, items) -- 28 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	if instance:IsA("GuiObject") then
		instance.BorderSizePixel = 0
	end

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function borderStroke(parent, p, p2, p3)
	local uiStroke = stroke(parent, p, p2, p3) -- inferred equivalent call
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	return uiStroke
end

local function fn(performanceTimeline, data)
	for _, child in ipairs(timeline:GetChildren()) do
		if child.Name == "TimelineV2" then
			child:Destroy()
		end
	end

	local timelineData = data and data.TimelineData
	local codes = timelineData and timelineData.Codes
	local v14 = typeof(codes) == "string" and #codes or 0

	if timelineData and v14 ~= 0 then
		graphArea.Visible = false
		label27.Visible = false
		timeline.Size = UDim2.new(1, 0, 0, 348)

		for _, label28 in ipairs(timeline:GetChildren()) do
			if not (label28:IsA("TextLabel") and label28.Text == "PERFORMANCE TIMELINE") then
				continue
			end

			label28.Font = StyledTheme.Fonts.Medium
			label28.TextSize = 19
			label28.Size = UDim2.new(1, -l * 2, 0, 24)
			label28.Position = UDim2.new(0, l, 0, 10)
		end

		local v15 = {}
		local v16 = {}

		for i = 1, v14 do
			v15[i] = (timelineData.Times and timelineData.Times[i] or 0) / 100
			v16[i] = math.clamp((string.byte(codes, i) or 52) - 48, 1, 6)
		end

		local v17 = math.max(data.SongDuration or 0, v15[v14] + 2, 10)

		local zIndex = timeline.ZIndex
		local random = Random.new(math.floor(v17) * 31 + v14)

		local parent = mk("Frame", timeline, { -- inferred equivalent call
			Name = "TimelineV2",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = zIndex + 1
		})

		local parent2 = mk("Frame", parent, { -- inferred equivalent call
			Name = "Chart",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, l + 104, 0, 42),
			Size = UDim2.new(1, -(l * 2 + 104), 0, 270),
			ZIndex = zIndex + 1
		})

		local parent3 = mk("Frame", parent2, { -- inferred equivalent call
			Name = "Plot",
			BackgroundColor3 = color4,
			BackgroundTransparency = 0.04,
			Position = UDim2.new(0, 0, 0, 42),
			Size = UDim2.new(1, 0, 0, 176),
			ClipsDescendants = true,
			ZIndex = zIndex + 2
		})
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = color5 or StyledTheme.Colors.Border
		uiStroke.Thickness = 2
		uiStroke.Transparency = 0
		uiStroke.Parent = parent3

		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local v18 = {}

		for i, v19 in ipairs(v10) do
			v18[i] = getJudgmentColor(v19) -- inferred equivalent call
			local v20 = 84 + (i - 0.5) / 6 * 176
			mk("Frame", parent, { -- inferred equivalent call
				BackgroundColor3 = v18[i],
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, l, 0, v20),
				Size = UDim2.new(0, 18, 0, 5),
				ZIndex = zIndex + 3
			})

			local label = makeLabel({
				Parent = parent,
				Text = string.upper(v19),
				Font = StyledTheme.Fonts.Medium,
				TextSize = 14,
				Color = StyledTheme.Colors.TextSecondary,
				Size = UDim2.new(0, 74, 0, 18),
				Position = UDim2.new(0, l + 24, 0, v20 - 9),
				XAlign = Enum.TextXAlignment.Left
			})

			label.ZIndex = zIndex + 3
		end

		local label_2 = makeLabel({
			Parent = parent,
			Text = "ACCURACY",
			Font = StyledTheme.Fonts.Medium,
			TextSize = 14,
			Color = StyledTheme.Colors.TextSecondary,
			Size = UDim2.new(0, 96, 0, 18),
			Position = UDim2.new(0, l, 0, 269),
			XAlign = Enum.TextXAlignment.Left
		})

		label_2.ZIndex = zIndex + 3

		for i = 1, 6 do
			local v19 = (i - 0.5) / 6

			if i == 4 then
				mk("Frame", parent3, { -- inferred equivalent call
					BackgroundColor3 = color,
					BackgroundTransparency = 0.55,
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 0, v19, 0),
					Size = UDim2.new(1, 0, 0, 1),
					ZIndex = zIndex + 3
				})
			else
				mk("TextLabel", parent3, { -- inferred equivalent call
					BackgroundTransparency = 1,
					Text = string.rep("- ", 500),
					Font = StyledTheme.Fonts.Regular,
					TextSize = 12,
					TextColor3 = color,
					TextTransparency = 0.82,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = false,
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 0, v19, 0),
					Size = UDim2.new(1, 0, 0, 14),
					ZIndex = zIndex + 3
				})
			end
		end

		local v19 = v17 <= 150 and 30 or v17 <= 360 and 60 or 120
		local total = 0

		while total <= v17 do
			local v20 = total / v17

			if total > 0 then
				mk("Frame", parent3, { -- inferred equivalent call
					BackgroundColor3 = color,
					BackgroundTransparency = 0.9,
					Position = UDim2.new(v20, 0, 0, 0),
					Size = UDim2.new(0, 1, 1, 0),
					ZIndex = zIndex + 3
				})
			end

			local label28 = makeLabel({
				Parent = parent2,
				Text = fmtTime(total), -- inferred equivalent call
				Font = StyledTheme.Fonts.Medium,
				TextSize = 14,
				Color = StyledTheme.Colors.TextSecondary,
				Size = UDim2.new(0, 60, 0, 18),
				Position = UDim2.new(v20, 0, 0, 250),
				XAlign = total == 0 and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
			})

			label28.AnchorPoint = Vector2.new(total == 0 and 0 or 0.5, 0)
			label28.ZIndex = zIndex + 3
			total += v19
		end

		for _, v20 in ipairs(timelineData.Stars or {}) do
			local v21 = math.clamp((v20[1] or 0) / 100 / v17, 0, 1)

			local v22 = math.clamp(
				(type(v20[3]) == "number" and v20[3] / 100 or timelineData.StarDuration or 8) / v17,
				0,
				1 - v21
			)
			mk("Frame", parent3, { -- inferred equivalent call
				BackgroundColor3 = color8,
				BackgroundTransparency = 0.88,
				Position = UDim2.new(v21, 0, 0, 0),
				Size = UDim2.new(v22, 0, 1, 0),
				ZIndex = zIndex + 3
			})

			mk("Frame", parent3, { -- inferred equivalent call
				BackgroundColor3 = color8,
				BackgroundTransparency = 0.45,
				Position = UDim2.new(v21, 0, 0, 0),
				Size = UDim2.new(0, 2, 1, 0),
				ZIndex = zIndex + 3
			})
		end

		if timelineData.StarCount ~= nil then
			local starCount = tonumber(timelineData.StarCount) or 0
			local starSeconds = tonumber(timelineData.StarSeconds) or 0
			local starBonusScore = tonumber(timelineData.StarBonusScore) or 0
			local text

			if starCount > 0 then
				local v20 = math.clamp(starSeconds / v17 * 100, 0, 100)
				local v21 = tostring((math.floor(starBonusScore + 0.5)))

				repeat
					local v22
					v21, v22 = string.gsub(v21, "^(-?%d+)(%d%d%d)", "%1,%2")
				until v22 == 0

				text = string.format("STAR POWER  %d%% UPTIME  |  +%s PTS", math.floor(v20 + 0.5), v21)
			else
				text = "STAR POWER  NOT USED"
			end

			local label28 = makeLabel({
				Parent = parent,
				Text = text,
				Font = StyledTheme.Fonts.Medium,
				TextSize = 14,
				Color = starCount > 0 and color8 or StyledTheme.Colors.TextDisabled,
				Size = UDim2.new(0.55, -l, 0, 20),
				Position = UDim2.new(1, -l, 0, 13),
				XAlign = Enum.TextXAlignment.Right
			})

			label28.AnchorPoint = Vector2.new(1, 0)
			label28.ZIndex = zIndex + 4
		end

		for _ = 1, 70 do
			mk("Frame", parent3, { -- inferred equivalent call
				BackgroundColor3 = color,
				BackgroundTransparency = random:NextNumber(0.65, 0.9),
				Position = UDim2.new(random:NextNumber(), 0, random:NextNumber(), 0),
				Size = UDim2.new(0, random:NextInteger(1, 2), 0, random:NextInteger(1, 2)),
				ZIndex = zIndex + 3
			})
		end

		for _ = 1, 3 do
			local integer = random:NextInteger(16, 36)
			corner(mk("Frame", parent3, { -- inferred equivalent call
				BackgroundColor3 = color10,
				BackgroundTransparency = random:NextNumber(0.74, 0.86),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(random:NextNumber(0.05, 0.95), 0, random:NextNumber(0.1, 0.9), 0),
				Size = UDim2.new(0, integer, 0, (math.floor(integer * random:NextNumber(0.6, 1)))),
				ZIndex = zIndex + 3
			}), UDim.new(1, 0))
		end

		local v20 = v14 > 1800

		for i = 1, v14 do
			local v21 = v16[i]
			local v22 = math.clamp(v15[i] / v17, 0, 1)
			local v23 = (v21 - 0.5) / 6
			local backgroundColor = v18[v21]

			if v21 ~= 4 and not (v20 and v21 <= 2) then
				mk("Frame", parent3, { -- inferred equivalent call
					BackgroundColor3 = backgroundColor,
					BackgroundTransparency = v21 <= 2 and 0.72 or 0.6,
					AnchorPoint = Vector2.new(0.5, v21 < 4 and 1 or 0),
					Position = UDim2.new(v22, 0, 7 / 12, 0),
					Size = UDim2.new(0, 1, math.abs(v23 - 7 / 12), 0),
					ZIndex = zIndex + 4
				})
			end

			local v24 = v11[v21]
			local parent4 = mk("Frame", parent3, { -- inferred equivalent call
				BackgroundColor3 = backgroundColor,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(v22, 0, v23, 0),
				Size = UDim2.new(0, v24, 0, v24),
				ZIndex = zIndex + 5
			})

			if v21 == 6 then
				parent4.Rotation = 45
			else
				corner(parent4, UDim.new(1, 0)) -- inferred equivalent call
			end
		end

		local function accY(accuracy) -- 2 equivalent calls inferred from this helper
			return (1 - math.clamp((accuracy - 0.5) / 0.5, 0, 1)) * 0.92 + 0.04
		end

		if performanceTimeline and #performanceTimeline >= 2 then
			local color11 = Color3.fromRGB(238, 228, 202)

			for i = 1, #performanceTimeline - 1 do
				local v21 = math.clamp(performanceTimeline[i].Elapsed / v17, 0, 1)
				local v22 = math.clamp(performanceTimeline[i + 1].Elapsed / v17, 0, 1)
				local v23 = accY(performanceTimeline[i].Accuracy) -- inferred equivalent call
				local v24 = accY(performanceTimeline[i + 1].Accuracy) -- inferred equivalent call
				mk("Frame", parent3, { -- inferred equivalent call
					BackgroundColor3 = color11,
					BackgroundTransparency = 0.3,
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(v21, 0, v23, 0),
					Size = UDim2.new(math.max(0, v22 - v21), 0, 0, 2),
					ZIndex = zIndex + 6
				})

				mk("Frame", parent3, { -- inferred equivalent call
					BackgroundColor3 = color11,
					BackgroundTransparency = 0.3,
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(v22, 0, math.min(v23, v24), 0),
					Size = UDim2.new(0, 2, math.abs(v24 - v23), 2),
					ZIndex = zIndex + 6
				})
			end
		end

		for _ = 1, 6 do
			mk("Frame", parent3, { -- inferred equivalent call
				BackgroundColor3 = color3,
				BackgroundTransparency = random:NextNumber(0.55, 0.78),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(random:NextNumber(), 0, random:NextNumber(), 0),
				Size = UDim2.new(0, random:NextInteger(60, 160), 0, 1),
				Rotation = random:NextInteger(-35, 35),
				ZIndex = zIndex + 7
			})
		end

		local parent4 = mk("Frame", parent2, { -- inferred equivalent call
			Name = "Heat",
			BackgroundColor3 = color6,
			Position = UDim2.new(0, 0, 0, 226),
			Size = UDim2.new(1, 0, 0, 20),
			ClipsDescendants = true,
			ZIndex = zIndex + 2
		})
		local uiStroke2 = Instance.new("UIStroke")
		uiStroke2.Color = color5 or StyledTheme.Colors.Border
		uiStroke2.Thickness = 2
		uiStroke2.Transparency = 0
		uiStroke2.Parent = parent4

		uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local v21 = math.clamp(math.floor(v17 / 2), 24, 180)
		local v22 = table.create(v21, 0)
		local v23 = table.create(v21, 0)

		for i = 1, v14 do
			local v24 = v12[v16[i]]

			if not v24 then
				continue
			end

			local v25 = math.clamp(math.floor(v15[i] / v17 * v21) + 1, 1, v21)
			v22[v25] += v24
			v23[v25] += 1
		end

		for i = 1, v21 do
			if v23[i] > 0 then
				mk("Frame", parent4, { -- inferred equivalent call
					BackgroundColor3 = heatColor(v22[i] / v23[i]),
					Position = UDim2.new((i - 1) / v21, 0, 0, 0),
					Size = UDim2.new(1 / v21, 1, 1, 0),
					ZIndex = zIndex + 3
				})
			end
		end

		for _ = 1, 46 do
			mk("Frame", parent4, { -- inferred equivalent call
				BackgroundColor3 = color3,
				BackgroundTransparency = random:NextNumber(0.6, 0.82),
				Position = UDim2.new(random:NextNumber(), 0, 0, 0),
				Size = UDim2.new(0, random:NextInteger(1, 2), 1, 0),
				ZIndex = zIndex + 4
			})
		end

		local parent5 = mk("Frame", parent2, { -- inferred equivalent call
			Name = "Tip",
			BackgroundColor3 = color3,
			BackgroundTransparency = 0.03,
			AutomaticSize = Enum.AutomaticSize.XY,
			Size = UDim2.new(0, 0, 0, 0),
			Visible = false,
			ZIndex = zIndex + 40
		})

		local accent = StyledTheme.Colors.Accent
		local uiStroke3 = Instance.new("UIStroke")
		uiStroke3.Color = accent or StyledTheme.Colors.Border
		uiStroke3.Thickness = 1.5
		uiStroke3.Transparency = 0.15
		uiStroke3.Parent = parent5

		uiStroke3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		corner(parent5, UDim.new(0, 4)) -- inferred equivalent call
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingLeft = UDim.new(0, 10)
		uiPadding.PaddingRight = UDim.new(0, 10)
		uiPadding.PaddingTop = UDim.new(0, 5)
		uiPadding.PaddingBottom = UDim.new(0, 5)
		uiPadding.Parent = parent5
		local label28 = makeLabel({
			Parent = parent5,
			Text = "",
			Font = StyledTheme.Fonts.Medium,
			TextSize = 16,
			Color = StyledTheme.Colors.TextPrimary,
			Size = UDim2.new(0, 0, 0, 20),
			XAlign = Enum.TextXAlignment.Left
		})

		label28.AutomaticSize = Enum.AutomaticSize.X
		label28.ZIndex = zIndex + 41
		local function showTip(text, p, p2) -- 3 equivalent calls inferred from this helper
			label28.Text = text
			parent5.AnchorPoint = Vector2.new(p < 0.18 and 0 or p > 0.82 and 1 or 0.5, 0)
			parent5.Position = UDim2.new(p, 0, 0, p2)
			parent5.Visible = true
		end

		local frame2 = mk("Frame", parent3, { -- inferred equivalent call
			BackgroundColor3 = color,
			BackgroundTransparency = 0.35,
			Size = UDim2.new(0, 1, 1, 0),
			Visible = false,
			ZIndex = zIndex + 12
		})

		local parent6 = mk("Frame", parent3, { -- inferred equivalent call
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(0, 18, 0, 18),
			Visible = false,
			ZIndex = zIndex + 13
		})

		corner(parent6, UDim.new(1, 0)) -- inferred equivalent call
		local uiStroke4 = Instance.new("UIStroke")
		uiStroke4.Color = color or StyledTheme.Colors.Border
		uiStroke4.Thickness = 2
		uiStroke4.Transparency = 0
		uiStroke4.Parent = parent6

		uiStroke4.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local frame3 = mk("Frame", parent3, { -- inferred equivalent call
			Name = "Hit",
			BackgroundTransparency = 1,
			Active = true,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = zIndex + 14
		})

		local function nearestIndex(p)
			local v24 = v14
			local v25 = 1

			while v25 < v24 do
				local v26 = (v25 + v24) // 2

				if v15[v26] < p then
					v25 = v26 + 1
				else
					v24 = v26
				end
			end

			if v25 > 1 and math.abs(v15[v25 - 1] - p) <= math.abs(v15[v25] - p) then
				return v25 - 1
			end

			return v25
		end

		local function accuracyAt(p) -- 1 equivalent call inferred from this helper
			local accuracy = nil

			if not performanceTimeline then
				return accuracy
			end

			for _, item in ipairs(performanceTimeline) do
				if item.Elapsed <= p then
					accuracy = item.Accuracy
				else
					break
				end
			end

			return accuracy
		end

		local function hidePlotHover() -- 1 equivalent call inferred from this helper
			frame2.Visible = false
			parent6.Visible = false
			parent5.Visible = false
		end
		local function updateFromX(x)
			local x2 = parent3.AbsoluteSize.X

			if x2 <= 0 then
				return
			end

			local v24 = nearestIndex(math.clamp((x - parent3.AbsolutePosition.X) / x2, 0, 1) * v17)
			local v25 = math.clamp(v15[v24] / v17, 0, 1)
			frame2.Position = UDim2.new(v25, 0, 0, 0)
			frame2.Visible = true
			parent6.Position = UDim2.new(v25, 0, (v16[v24] - 0.5) / 6, 0)
			parent6.Visible = true
			local accuracy = accuracyAt(v15[v24]) -- inferred equivalent call
			local v26 = accuracy and string.format("  ·  %.1f%%", accuracy * 100) or ""
			showTip(string.format("%s  ·  %s%s", fmtTime(v15[v24]), string.upper(v10[v16[v24]]), v26), v25, 48) -- inferred equivalent call
		end
		local function isPointer(input): boolean -- 2 equivalent calls inferred from this helper
			return input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
				or input.UserInputType == Enum.UserInputType.MouseButton1
		end

		frame3.InputBegan:Connect(function(input)
			if isPointer(input) then -- inferred equivalent call
				updateFromX(input.Position.X)
			end
		end)
		frame3.InputChanged:Connect(function(input)
			if isPointer(input) then -- inferred equivalent call
				updateFromX(input.Position.X)
			end
		end)
		frame3.MouseLeave:Connect(hidePlotHover)
		local count2 = 0
		frame3.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				count2 += 1
				local v24 = count2
				task.delay(2.5, function()
					if count2 == v24 then
						hidePlotHover() -- inferred equivalent call
					end
				end)
			end
		end)

		local v24 = {}

		if (timelineData.BestCombo or 0) >= 10 then
			local v25 = (timelineData.BestComboTime or 0) / 100
			local maxCombo = data.MaxCombo and data.MaxCombo > 0 and data.MaxCombo or timelineData.BestCombo
			table.insert(v24, {
				prio = 1,
				t = v25,
				glyph = "★",
				color = color7,
				size = 19,
				tip = string.format("Longest streak: %d notes  ·  %s", maxCombo, fmtTime(v25))
			})
		end

		for _, v25 in ipairs(timelineData.Stars or {}) do
			local v26 = (v25[1] or 0) / 100
			table.insert(v24, {
				prio = 2,
				t = v26,
				glyph = "⚡",
				color = color8,
				size = 19,
				tip = string.format("Star Power used (level %d)  ·  %s", v25[2] or 1, fmtTime(v26))
			})
		end

		local set = {}

		for _, v25 in ipairs(timelineData.Mults or {}) do
			local v26 = (v25[1] or 0) / 100
			local v27 = not set[v25[2]]
			set[v25[2]] = true
			table.insert(v24, {
				prio = v27 and 3 or 4,
				t = v26,
				glyph = "×" .. tostring(v25[2]),
				color = color9,
				size = 15,
				tip = string.format("Multiplier ×%d reached  ·  %s", v25[2] or 2, fmtTime(v26))
			})
		end

		table.sort(v24, function(a, b): boolean
			if a.prio == b.prio then
				return a.t < b.t
			end

			return a.prio < b.prio
		end)

		local v25 = 38 / math.max(
			(timeline.AbsoluteSize.X > 0 and timeline.AbsoluteSize.X or 1200) - (l * 2 + 104),
			300
		)
		local v26 = {}

		for _, v27 in ipairs(v24) do
			local v28 = math.clamp(v27.t / v17, 0.014, 0.986)
			local flag = true

			for _, v29 in ipairs(v26) do
				if math.abs(v29.f - v28) < v25 then
					flag = false
					break
				end
			end

			if not flag then
				continue
			end

			v27.f = v28
			table.insert(v26, v27)
		end

		local count3 = 0

		for _, v27 in ipairs(v26) do
			mk("Frame", parent2, { -- inferred equivalent call
				BackgroundColor3 = v27.color,
				BackgroundTransparency = 0.6,
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(v27.f, 0, 0, 32),
				Size = UDim2.new(0, 1, 0, 186),
				ZIndex = zIndex + 6
			})

			local parent7 = mk("TextButton", parent2, { -- inferred equivalent call
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(v27.f, 0, 0, 0),
				Size = UDim2.new(0, 32, 0, 32),
				BackgroundColor3 = color3,
				BackgroundTransparency = 0.04,
				AutoButtonColor = false,
				Text = v27.glyph,
				Font = StyledTheme.Fonts.Bold,
				TextSize = v27.size,
				TextColor3 = v27.color,
				ZIndex = zIndex + 20
			})

			corner(parent7, UDim.new(1, 0)) -- inferred equivalent call
			local color11 = v27.color
			local uiStroke5 = Instance.new("UIStroke")
			uiStroke5.Color = color11 or StyledTheme.Colors.Border
			uiStroke5.Thickness = 1.5
			uiStroke5.Transparency = 0.15
			uiStroke5.Parent = parent7

			uiStroke5.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			parent7.MouseEnter:Connect(function()
				showTip(v27.tip, v27.f, 36) -- inferred equivalent call
			end)
			parent7.MouseLeave:Connect(function()
				parent5.Visible = false
			end)
			parent7.Activated:Connect(function()
				showTip(v27.tip, v27.f, 36) -- inferred equivalent call
				count3 += 1
				local v28 = count3
				task.delay(2.5, function()
					if count3 == v28 then
						parent5.Visible = false
					end
				end)
			end)
		end

		local v27 = nil

		for _, v28 in ipairs(performanceTimeline or {}) do
			if not v27 or v28.Accuracy > v27.Accuracy then
				v27 = v28
			end
		end

		local text = v27
			and string.format("PEAK PERFORMANCE  %.1f%%  (%s)", v27.Accuracy * 100, fmtTime(v27.Elapsed))
			or ""

		local label_3 = makeLabel({
			Parent = parent,
			Text = text,
			Font = StyledTheme.Fonts.Medium,
			TextSize = 15,
			Color = StyledTheme.Colors.TextSecondary,
			Size = UDim2.new(0, 330, 0, 20),
			Position = UDim2.new(0, l, 0, 318),
			XAlign = Enum.TextXAlignment.Left
		})

		label_3.ZIndex = zIndex + 3
		local label29 = makeLabel({
			Parent = parent,
			Text = "Hover or tap a dot for details   ·   ★ streak   ⚡ Star Power   ×N multiplier   ·   ─ accuracy",
			Font = StyledTheme.Fonts.Regular,
			TextSize = 14,
			Color = StyledTheme.Colors.TextDisabled,
			Size = UDim2.new(1, -(l * 2 + 340), 0, 20),
			Position = UDim2.new(0, l + 340, 0, 318),
			XAlign = Enum.TextXAlignment.Right
		})

		label29.TextTruncate = Enum.TextTruncate.AtEnd
		label29.ZIndex = zIndex + 3

		local function addTape(position, size, rotation, color11, backgroundTransparency)
			local parent7 = mk("Frame", parent, { -- inferred equivalent call
				Name = "Tape",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = position,
				Size = size,
				Rotation = rotation,
				BackgroundColor3 = color11,
				BackgroundTransparency = backgroundTransparency,
				ZIndex = zIndex + 45
			})

			mk("Frame", parent7, { -- inferred equivalent call
				BackgroundColor3 = Color3.fromRGB(70, 56, 38),
				BackgroundTransparency = 0.68,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0.1, 0, 0.62, 0),
				Size = UDim2.new(0.55, 0, 0, 2),
				ZIndex = zIndex + 46
			})

			corner(mk("Frame", parent7, { -- inferred equivalent call
				BackgroundColor3 = Color3.fromRGB(52, 40, 28),
				BackgroundTransparency = 0.6,
				Position = UDim2.new(0.7, 0, 0.2, 0),
				Size = UDim2.new(0, 5, 0, 4),
				ZIndex = zIndex + 46
			}), UDim.new(1, 0))
		end
		addTape(UDim2.new(1, -64, 0, 4), UDim2.new(0, 74, 0, 18), 9, color, 0.12)
		addTape(UDim2.new(1, -52, 1, -4), UDim2.new(0, 82, 0, 18), 12, color2, 0.16)
	else
		timeline.Size = UDim2.new(1, 0, 0, 140)
		graphArea.Visible = true
		label27.Visible = true
		renderTimelineLegacy(performanceTimeline)
	end
end

local function countUpNumber(label28, accuracy, value, value2, value3) -- 1 equivalent call inferred from this helper
	local v14 = value or 0
	local v15 = value2 or ""
	local v16 = value3 or 0.6
	local lastTime = os.clock()
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local v17 = math.clamp((os.clock() - lastTime) / v16, 0, 1)
		local v18 = accuracy * (1 - (1 - v17) ^ 3)

		if v14 > 0 then
			label28.Text = string.format("%." .. v14 .. "f", v18) .. v15
		else
			label28.Text = string.format("%d", (math.floor(v18 + 0.5))) .. v15
		end

		if v17 >= 1 then
			renderSteppedConnection:Disconnect()
		end
	end)
end

local flag = false
local inputBeganConnection = nil

local uiScale3 = Instance.new("UIScale")
uiScale3.Parent = panel
local count2 = 0
local playerResultsViewingChanged = nil

local udim3 = UDim2.new(0.5, 0, 0.5, 0)

local function getDecor() -- 1 equivalent call inferred from this helper
	local newUIDecorFront = overlay:FindFirstChild("NewUIDecorFront")

	if not (newUIDecorFront and newUIDecorFront:IsA("GuiObject")) then
		return nil, nil
	end

	local flyScale = newUIDecorFront:FindFirstChild("FlyScale")

	if not flyScale then
		flyScale = Instance.new("UIScale")
		flyScale.Name = "FlyScale"
		flyScale.Parent = newUIDecorFront
	end

	return newUIDecorFront, flyScale
end

local function applyPose(position, scale) -- 3 equivalent calls inferred from this helper
	panel.Position = position
	uiScale3.Scale = scale
	local decor, flyScale = getDecor() -- inferred equivalent call

	if decor then
		decor.Position = position
		flyScale.Scale = scale
	end
end

local v14 = nil

local function collectFade()
	if v14 then
		return
	end

	v14 = {}
	local function push(p, p2) -- 5 equivalent calls inferred from this helper
		local v15 = p[p2]

		if v15 < 0.99 then
			table.insert(v14, { p, p2, v15 })
		end
	end
	local function add(folder)
		local descendants = folder:GetDescendants()
		table.insert(descendants, folder)

		for _, instance in ipairs(descendants) do
			if instance:IsA("UIStroke") then
				push(instance, "Transparency") -- inferred equivalent call
			elseif instance:IsA("GuiObject") then
				local absoluteSize = instance.AbsoluteSize

				if absoluteSize.X > 4 or absoluteSize.Y > 4 then
					push(instance, "BackgroundTransparency") -- inferred equivalent call

					if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
						if instance.Text ~= "" then
							push(instance, "TextTransparency") -- inferred equivalent call
						end
					elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
						push(instance, "ImageTransparency") -- inferred equivalent call
					end
				end
			end
		end
	end
	add(panel)
	local newUIDecorFront = overlay:FindFirstChild("NewUIDecorFront")

	if newUIDecorFront and newUIDecorFront:IsA("GuiObject") then
		if not newUIDecorFront:FindFirstChild("FlyScale") then
			local flyScale = Instance.new("UIScale")
			flyScale.Name = "FlyScale"
			flyScale.Parent = newUIDecorFront
		end
	else
		newUIDecorFront = nil
	end

	if newUIDecorFront then
		add(newUIDecorFront)
	end

	push(panel, "ScrollBarImageTransparency") -- inferred equivalent call
end

local function setFade(p)
	if not v14 then
		return
	end

	local v15 = 1 - p

	for _, v16 in ipairs(v14) do
		v16[1][v16[2]] = 1 - (1 - v16[3]) * v15
	end
end

local function restoreFade()
	if not v14 then
		return
	end

	for _, v15 in ipairs(v14) do
		pcall(function()
			v15[1][v15[2]] = v15[3]
		end)
	end
end

local function impactBurst(p)
	local resultsImpactFx = Instance.new("ScreenGui")
	resultsImpactFx.Name = "ResultsImpactFx"
	resultsImpactFx.IgnoreGuiInset = true
	resultsImpactFx.ResetOnSpawn = false
	resultsImpactFx.DisplayOrder = 60
	resultsImpactFx.Parent = playerGui
	local accent = StyledTheme.Colors.Accent
	local tweenInfo = TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local frame2 = Instance.new("Frame")
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.Position = UDim2.fromOffset(p.X, p.Y)
	frame2.Size = UDim2.fromOffset(20, 20)
	frame2.BackgroundTransparency = 1
	frame2.BorderSizePixel = 0
	frame2.Parent = resultsImpactFx
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = frame2
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = accent
	uiStroke.Thickness = 4
	uiStroke.Parent = frame2
	TweenService:Create(frame2, tweenInfo, { Size = UDim2.fromOffset(150, 150) }):Play()
	TweenService:Create(uiStroke, tweenInfo, { Transparency = 1, Thickness = 1 }):Play()

	for i = 1, 10 do
		local v15 = i / 10 * 3.141592653589793 * 2 + math.random() * 0.4
		local vector2 = Vector2.new(math.cos(v15), (math.sin(v15)))
		local v16 = math.random(60, 110)
		local frame3 = Instance.new("Frame")
		frame3.AnchorPoint = Vector2.new(0.5, 0.5)
		frame3.Position = UDim2.fromOffset(p.X + vector2.X * 14, p.Y + vector2.Y * 14)
		frame3.Size = UDim2.fromOffset(math.random(12, 22), 3)
		frame3.Rotation = math.deg(v15)
		frame3.BackgroundColor3 = i % 2 == 0 and accent or Color3.fromRGB(235, 225, 200)
		frame3.BorderSizePixel = 0
		frame3.Parent = resultsImpactFx
		TweenService:Create(frame3, tweenInfo, {
			Position = UDim2.fromOffset(p.X + vector2.X * v16, p.Y + vector2.Y * v16),
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(4, 2)
		}):Play()
	end

	task.delay(0.4, function()
		resultsImpactFx:Destroy()
	end)
end

local function reportViewing(p) -- 2 equivalent calls inferred from this helper
	task.spawn(function()
		if not playerResultsViewingChanged then
			local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
			playerResultsViewingChanged = remoteEvents
				and remoteEvents:WaitForChild("PlayerResultsViewingChanged", 5)
				or nil
		end

		if playerResultsViewingChanged then
			playerResultsViewingChanged:FireServer(p)
		end
	end)
end

local function closeResults()
	if not flag then
		return
	end

	flag = false

	SessionCameraSettings.SetMenuOpen(false)

	if inputBeganConnection then
		inputBeganConnection:Disconnect()
		inputBeganConnection = nil
	end

	reportViewing(false) -- inferred equivalent call
	count2 += 1
	local v15 = count2
	local v16

	if resultsScreenUI:GetAttribute("StageReportMode") == true or not success2 then
		v16 = nil
	else
		v16 = result2.GetCard() or nil
	end

	local success3, result3 = pcall(function()
		return SettingsState.GetReduceMotionEnabled()
	end)
	local v17 = success3 and result3 == true
	local v18 = false

	local function runPhase(p, fn2)
		local lastTime = os.clock()

		while true do
			RunService.RenderStepped:Wait()

			if v15 ~= count2 then
				return false
			end

			local v19 = math.clamp((os.clock() - lastTime) / p, 0, 1)
			fn2(v19)

			if v19 >= 1 then
				return true
			end
		end
	end

	if v17 then
		local tween = TweenService:Create(
			overlay,
			TweenInfo.new(
				StyledTheme.Animation.Slow,
				StyledTheme.Animation.EasingStyle,
				StyledTheme.Animation.EasingDirection
			),
			{ BackgroundTransparency = 1 }
		)

		tween:Play()
		tween.Completed:Wait()

		if v16 then
			v18 = pcall(v16.ShowOwn)
		end
	else
		local _ = { Fly = 0.4, FadeStart = 0.3 }
		closeButton.Visible = false
		label.Visible = false
		resultsScreenUI.DisplayOrder = 51
		collectFade()

		if v16 then
			v18 = pcall(v16.ShowOwn, true)
		end

		local halfAbsoluteSize = overlay.AbsoluteSize / 2
		local backgroundTransparency = overlay.BackgroundTransparency
		local v19 = halfAbsoluteSize
		local v20

		if v16 == nil then
			v20 = false
		else
			v20 = v18
		end

		local v21 = v20 and 0.1 or 0.88

		if not runPhase(0.4, function(p)
			if v20 then
				local success4, buttonCenter = pcall(v16.GetButtonCenter)

				if success4 and typeof(buttonCenter) == "Vector2" and (buttonCenter.X > 1 or buttonCenter.Y > 1) then
					v19 = buttonCenter
				end
			end

			local v22 = p * p * (3 - 2 * p)
			local lerped = halfAbsoluteSize:Lerp(v19, v22)
			applyPose(UDim2.fromOffset(lerped.X, lerped.Y), 1 + (v21 - 1) * v22) -- inferred equivalent call
			overlay.BackgroundTransparency = backgroundTransparency + (1 - backgroundTransparency) * p
			setFade(math.clamp((p - 0.3) / 0.7, 0, 1))
		end) then
			return
		end
	end

	if v15 ~= count2 then
		return
	end

	resultsScreenUI.Enabled = false
	restoreFade()
	applyPose(udim3, 1) -- inferred equivalent call
	closeButton.Visible = true
	label.Visible = UserInputService.KeyboardEnabled
	resultsScreenUI.DisplayOrder = 50

	if v16 and v18 then
		pcall(v16.Pulse)
		pcall(v16.ArmAutoClose, 3)
	end
end

closeButton.MouseButton1Click:Connect(closeResults)

local v15 = {
	Normal = StyledTheme.Colors.TextSecondary,
	Medium = Color3.fromRGB(240, 180, 70),
	Easy = Color3.fromRGB(88, 210, 150),
	Baby = Color3.fromRGB(120, 180, 255)
}

local color11 = Color3.fromRGB(200, 140, 255)

local v16 = {
	MVP = { Text = "MVP", Color = StyledTheme.Colors.Accent },
	BestAccuracy = {
		Text = "BEST ACCURACY",
		Color = StyledTheme.Colors.Success or Color3.fromRGB(88, 210, 150)
	},
	BestCombo = { Text = "BEST COMBO", Color = Color3.fromRGB(120, 180, 255) },
	HardestChart = {
		Text = "HARDEST CHART",
		Color = StyledTheme.Colors.Danger or Color3.fromRGB(235, 100, 100)
	}
}

local function makeChip(tags, text, p, layoutOrder)
	local chip = Instance.new("TextLabel")
	chip.Name = "Chip"
	chip.BackgroundColor3 = p
	chip.BackgroundTransparency = 0.8
	chip.BorderSizePixel = 0
	chip.AutomaticSize = Enum.AutomaticSize.X
	chip.Size = UDim2.new(0, 0, 0, 28)
	chip.Font = StyledTheme.Fonts.Bold
	chip.TextSize = 19
	chip.TextColor3 = p
	chip.Text = text
	chip.LayoutOrder = layoutOrder
	chip.Parent = tags

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 4)
	uiCorner.Parent = chip

	local uiStroke = Instance.new("UIStroke")
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Color = p
	uiStroke.Transparency = 0.6
	uiStroke.Thickness = 1
	uiStroke.Parent = chip

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 9)
	uiPadding.PaddingRight = UDim.new(0, 9)
	uiPadding.Parent = chip

	return chip
end

local function difficultyChipInfo(data)
	local difficultyTier = data.DifficultyTier or "Normal"
	local v17 = data.DifficultyMixed and "MIXED"
		or string.upper(difficultyTier == "Normal" and "Natural" or difficultyTier)
	local difficultyLanes = data.DifficultyLanes
	local nativeLanes = data.NativeLanes

	if difficultyLanes and nativeLanes and difficultyLanes < nativeLanes and not data.DifficultyMixed then
		v17 ..= string.format(" · %d-KEY", difficultyLanes)
	end

	local difficultyFactor = data.DifficultyFactor or 1

	if difficultyFactor < 0.995 then
		v17 ..= string.format("  ×%.2f", difficultyFactor)
	end

	return v17, data.DifficultyMixed and color11 or v15[difficultyTier] or StyledTheme.Colors.TextSecondary
end

statsRow = {
	{ Key = "Overall", Label = "OVERALL" },
	{ Key = "Accuracy", Label = "ACCURACY" },
	{ Key = "MaxCombo", Label = "MAX COMBO" },
	{ Key = "Perfect", Label = "PERFECT" },
	{ Key = "Miss", Label = "FEWEST MISS" },
	{ Key = "Wrong", Label = "FEWEST WRONG" }
}

local labels = {}
local v17 = { Selected = "Overall", Render = nil }
local v18 = { "BestAccuracy", "BestCombo", "HardestChart" }

for _, v19 in ipairs(statsRow) do
	labels[v19.Key] = v19.Label
end

local v19 = { Miss = true, Wrong = true }

local function withCommas(score) -- 2 equivalent calls inferred from this helper
	return (tostring((math.floor((score or 0) + 0.5))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

local function judgedCountOf(p) -- 3 equivalent calls inferred from this helper
	local judgements2 = p.Judgements or {}
	return (p.HitCount or 0) + (judgements2.Miss or 0)
end

local function categoryValue(data, p)
	local judgements2 = data.Judgements or {}

	if p == "Overall" or p == "Score" then
		return data.Score or 0
	end

	if type(data.Coverage) == "number" and data.Coverage < 0.9 then
		return nil
	end

	if p == "Accuracy" then
		return data.Accuracy
	elseif p == "MaxCombo" then
		return data.MaxCombo or 0
	elseif p == "Perfect" then
		return judgements2.Perfect or 0
	end

	if p == "Miss" then
		if judgedCountOf(data) == 0 then -- inferred equivalent call
			return nil
		end

		return judgements2.Miss or 0
	end

	if p ~= "Wrong" then
		return data.Accuracy
	end

	if judgedCountOf(data) == 0 then -- inferred equivalent call
		return nil
	end

	return data.Wrong or 0
end

local function formatCategoryValue(data, p)
	if categoryValue(data, p) == nil then
		return "-"
	end

	if p == "Overall" or p == "Score" then
		return withCommas(data.Score) -- inferred equivalent call
	end

	if p == "Accuracy" then
		return string.format("%.1f%%", data.Accuracy or 0)
	elseif p == "MaxCombo" then
		return string.format("%d", data.MaxCombo or 0)
	end

	return "× " .. tostring(categoryValue(data, p))
end

local function orderResults(list, p)
	local v20 = {}
	local v21 = {}
	local v22 = {}

	for i, item in ipairs(list) do
		if item.IsAutoPlayed then
			table.insert(v20, item)
		else
			local v23 = categoryValue(item, p)

			if v23 == nil then
				table.insert(v22, item)
			else
				table.insert(v21, { r = item, v = v23, idx = i })
			end
		end
	end

	local v23 = v19[p] == true
	table.sort(v21, function(a, b): boolean
		if a.v == b.v then
			return a.idx < b.idx
		end

		if v23 then
			return a.v < b.v
		end

		return a.v > b.v
	end)

	local v24 = v21[1] and v21[1].v
	local result3 = {}
	local playerNames = {}

	for _, v25 in ipairs(v21) do
		table.insert(result3, v25.r)

		if p ~= "Overall" and v25.v == v24 then
			table.insert(playerNames, v25.r.PlayerName or "?")
		end
	end

	local v25 = p == "Overall" and v21[1] and { v21[1].r.PlayerName or "?" } or playerNames

	for _, v26 in ipairs(v22) do
		table.insert(result3, v26)
	end

	for _, v26 in ipairs(v20) do
		table.insert(result3, v26)
	end

	return result3, v25, v21[1] and v21[1].r, #v21 + #v22
end

local mvpBanner = Instance.new("TextLabel")
mvpBanner.Name = "MvpBanner"
mvpBanner.AutoLocalize = false
mvpBanner.BackgroundColor3 = StyledTheme.Colors.Accent
mvpBanner.BackgroundTransparency = 0.85
mvpBanner.BorderSizePixel = 0
mvpBanner.Size = UDim2.new(1, 0, 0, 40)
mvpBanner.Font = StyledTheme.Fonts.Medium
mvpBanner.TextSize = 19
mvpBanner.TextColor3 = StyledTheme.Colors.TextPrimary
mvpBanner.RichText = true
mvpBanner.TextTruncate = Enum.TextTruncate.AtEnd
mvpBanner.TextXAlignment = Enum.TextXAlignment.Left
mvpBanner.Text = ""
mvpBanner.LayoutOrder = 1
mvpBanner.Parent = rankings
categorySelector = StyledTheme.Radius.Medium
statsRowHolder = Instance.new("UICorner")
statsRowHolder.CornerRadius = categorySelector or StyledTheme.Radius.Medium
statsRowHolder.Parent = mvpBanner

categorySelector = StyledTheme.Colors.Accent
statsRowHolder = Instance.new("UIStroke")
statsRowHolder.Color = categorySelector or StyledTheme.Colors.Border
statsRowHolder.Thickness = 1
statsRowHolder.Transparency = 0.6
statsRowHolder.Parent = mvpBanner

statsRowHolder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
categorySelector = Instance.new("UIPadding")
categorySelector.PaddingLeft = UDim.new(0, 12)
categorySelector.PaddingRight = UDim.new(0, 12)
categorySelector.Parent = mvpBanner

local function escapeRich(p) -- 1 equivalent call inferred from this helper
	return (tostring(p):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function updateMvpBanner(p, list, p2)
	local v20 = labels[p] or p
	local hex = StyledTheme.Colors.Accent:ToHex()
	local hex2 = StyledTheme.Colors.TextSecondary:ToHex()

	if not p2 or #list == 0 then
		mvpBanner.Text = string.format(
			"<font color=\"#%s\"><b>MVP · %s</b></font>   No MVP for this category",
			hex,
			v20
		)
		return
	end

	local v21 = {}

	for i = 1, math.min(#list, 3) do
		v21[i] = escapeRich(list[i]) -- inferred equivalent call
	end

	local v22 = table.concat(v21, " & ")

	if #list > 3 then
		v22 ..= string.format(" +%d", #list - 3)
	end

	mvpBanner.Text = string.format(
		"<font color=\"#%s\"><b>MVP · %s</b></font>   <b>%s</b>   <font color=\"#%s\">%s</font>",
		hex,
		v20,
		v22,
		hex2,
		formatCategoryValue(p2, p)
	)
end

categorySelector = Instance.new("Frame")
categorySelector.Name = "CategorySelector"
categorySelector.BackgroundTransparency = 1
categorySelector.AutomaticSize = Enum.AutomaticSize.Y
categorySelector.Size = UDim2.new(1, 0, 0, 0)
categorySelector.LayoutOrder = 100000
categorySelector.Parent = rankings

statsRowHolder = Instance.new("UIListLayout")
statsRowHolder.FillDirection = Enum.FillDirection.Vertical
statsRowHolder.HorizontalAlignment = Enum.HorizontalAlignment.Center
statsRowHolder.SortOrder = Enum.SortOrder.LayoutOrder
statsRowHolder.Padding = UDim.new(0, 8)
statsRowHolder.Parent = categorySelector

statsRowHolder = Instance.new("UIPadding")
statsRowHolder.PaddingTop = UDim.new(0, 8)
statsRowHolder.Parent = categorySelector

makeLabel({
	Parent = categorySelector,
	Text = "SORT THE LIST BY",
	Font = StyledTheme.Fonts.Bold,
	TextSize = 14,
	Color = StyledTheme.Colors.TextDisabled,
	Size = UDim2.new(1, 0, 0, 18),
	LayoutOrder = 1
})

local pills = Instance.new("Frame")
pills.Name = "Pills"
pills.BackgroundTransparency = 1
pills.AutomaticSize = Enum.AutomaticSize.Y
pills.Size = UDim2.new(1, 0, 0, 0)
pills.LayoutOrder = 2
pills.Parent = categorySelector

statsRowHolder = Instance.new("UIListLayout")
statsRowHolder.FillDirection = Enum.FillDirection.Horizontal
statsRowHolder.HorizontalAlignment = Enum.HorizontalAlignment.Center
statsRowHolder.VerticalAlignment = Enum.VerticalAlignment.Center
statsRowHolder.Wraps = true
statsRowHolder.SortOrder = Enum.SortOrder.LayoutOrder
statsRowHolder.Padding = UDim.new(0, 8)
statsRowHolder.Parent = pills

local v20 = {}
local v21 = {}
local function refreshPills()
	for k, instance in pairs(v20) do
		local v22 = k == v17.Selected
		TweenService:Create(instance, TweenInfo.new(0.15), {
			BackgroundColor3 = v22 and StyledTheme.Colors.Accent or StyledTheme.Colors.Surface,
			BackgroundTransparency = v22 and 0 or 0.15,
			TextColor3 = v22 and StyledTheme.Colors.Background or StyledTheme.Colors.TextSecondary
		}):Play()
		v21[k].Color = v22 and StyledTheme.Colors.Accent or StyledTheme.Colors.Border
		v21[k].Transparency = v22 and 0 or 0.3
		instance.Font = v22 and StyledTheme.Fonts.Bold or StyledTheme.Fonts.Medium
	end
end

for i, v22 in ipairs(statsRow) do
	local textButton = Instance.new("TextButton")
	textButton.Name = "Pill_" .. v22.Key
	textButton.AutoButtonColor = false
	textButton.AutomaticSize = Enum.AutomaticSize.X
	textButton.Size = UDim2.new(0, 0, 0, 36)
	textButton.BackgroundColor3 = StyledTheme.Colors.Surface
	textButton.BackgroundTransparency = 0.15
	textButton.Font = StyledTheme.Fonts.Medium
	textButton.TextSize = 16
	textButton.TextColor3 = StyledTheme.Colors.TextSecondary
	textButton.Text = v22.Label
	textButton.LayoutOrder = i
	textButton.ZIndex = 5
	textButton.Parent = pills
	local v23 = StyledTheme.Radius.Pill
	local uiCorner = corner(textButton, v23) -- inferred equivalent call
	v23 = v22.Key
	uiCorner = StyledTheme.Colors.Border
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = uiCorner or StyledTheme.Colors.Border
	uiStroke.Thickness = 1
	uiStroke.Transparency = 0.3
	uiStroke.Parent = textButton

	v21[v23] = uiStroke
	v21[v22.Key].ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	v23 = Instance.new("UIPadding")
	v23.PaddingLeft = UDim.new(0, 14)
	v23.PaddingRight = UDim.new(0, 14)
	v23.Parent = textButton
	v20[v22.Key] = textButton

	textButton.MouseEnter:Connect(function()
		if v17.Selected ~= v22.Key then
			TweenService:Create(textButton, TweenInfo.new(0.12), {
				BackgroundTransparency = 0,
				TextColor3 = StyledTheme.Colors.TextPrimary
			}):Play()
		end
	end)
	textButton.MouseLeave:Connect(function()
		if v17.Selected ~= v22.Key then
			TweenService:Create(textButton, TweenInfo.new(0.12), {
				BackgroundTransparency = 0.15,
				TextColor3 = StyledTheme.Colors.TextSecondary
			}):Play()
		end
	end)
	textButton.MouseButton1Click:Connect(function()
		if v17.Selected == v22.Key then
			return
		end

		v17.Selected = v22.Key
		refreshPills()

		if v17.Render then
			v17.Render(v22.Key)
		end
	end)
end

local color12 = Color3.fromRGB(206, 190, 150)
local color13 = Color3.fromRGB(96, 90, 80)

local function addTape(avatarPhoto, position, size, rotation, backgroundColor, backgroundTransparency, zIndex)
	local tape = Instance.new("Frame")
	tape.Name = "Tape"
	tape.AnchorPoint = Vector2.new(0.5, 0.5)
	tape.Position = position
	tape.Size = size
	tape.Rotation = rotation
	tape.BackgroundColor3 = backgroundColor
	tape.BackgroundTransparency = backgroundTransparency
	tape.BorderSizePixel = 0
	tape.ZIndex = zIndex
	tape.Parent = avatarPhoto

	local frame2 = Instance.new("Frame")
	frame2.BackgroundColor3 = Color3.fromRGB(70, 56, 38)
	frame2.BackgroundTransparency = 0.68
	frame2.BorderSizePixel = 0
	frame2.AnchorPoint = Vector2.new(0, 0.5)
	frame2.Position = UDim2.new(0.1, 0, 0.62, 0)
	frame2.Size = UDim2.new(0.55, 0, 0, 2)
	frame2.ZIndex = zIndex + 1
	frame2.Parent = tape
	local frame3 = Instance.new("Frame")
	frame3.BackgroundColor3 = Color3.fromRGB(52, 40, 28)
	frame3.BackgroundTransparency = 0.6
	frame3.BorderSizePixel = 0
	frame3.Position = UDim2.new(0.68, 0, 0.2, 0)
	frame3.Size = UDim2.new(0, 5, 0, 4)
	frame3.ZIndex = zIndex + 1
	frame3.Parent = tape
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = frame3
	return tape
end

local function buildAvatar(parent, p, p2, p3)
	local zIndex = rankings.ZIndex
	local userId = p.UserId

	if not userId and typeof(p.Player) == "Instance" then
		userId = p.Player.UserId
	end

	local random = Random.new((userId or 0) + p3 * 31)

	local avatarPhoto = Instance.new("Frame")
	avatarPhoto.Name = "AvatarPhoto"
	avatarPhoto.AnchorPoint = Vector2.new(0.5, 0.5)
	avatarPhoto.Position = UDim2.new(0, -41, 0, 35)
	avatarPhoto.Size = UDim2.new(0, 62, 0, 62)
	avatarPhoto.Rotation = random:NextInteger(-4, 4)
	avatarPhoto.BackgroundColor3 = Color3.fromRGB(186, 176, 152)
	avatarPhoto.BorderSizePixel = 0
	avatarPhoto.ZIndex = zIndex + 1
	avatarPhoto.Parent = parent
	local accent = p2 and StyledTheme.Colors.Accent or Color3.fromRGB(28, 25, 22)
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = accent or StyledTheme.Colors.Border
	uiStroke.Thickness = p2 and 2 or 1.5 or StyledTheme.Stroke.Thickness
	uiStroke.Transparency = 0
	uiStroke.Parent = avatarPhoto

	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local photo = Instance.new("ImageLabel")
	photo.Name = "Photo"
	photo.BackgroundColor3 = Color3.fromRGB(30, 28, 26)
	photo.BorderSizePixel = 0
	photo.Position = UDim2.new(0, 3, 0, 3)
	photo.Size = UDim2.new(1, -6, 1, -6)
	photo.ScaleType = Enum.ScaleType.Crop
	photo.ImageColor3 = Color3.fromRGB(206, 198, 182)
	photo.ClipsDescendants = true
	photo.ZIndex = zIndex + 2
	photo.Parent = avatarPhoto

	if userId then
		photo.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=150&h=150"
	else
		makeLabel({
			Parent = photo,
			Text = "?",
			Font = StyledTheme.Fonts.Bold,
			TextSize = 26,
			Color = StyledTheme.Colors.TextDisabled,
			Size = UDim2.new(1, 0, 1, 0)
		})
	end

	local frame2 = Instance.new("Frame")
	frame2.BackgroundColor3 = Color3.fromRGB(8, 6, 4)
	frame2.BorderSizePixel = 0
	frame2.Size = UDim2.new(1, 0, 1, 0)
	frame2.ZIndex = zIndex + 3
	frame2.Parent = photo
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = 90
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.92),
		NumberSequenceKeypoint.new(0.6, 0.72),
		NumberSequenceKeypoint.new(1, 0.38)
	})

	uiGradient.Parent = frame2

	for _ = 1, 3 do
		local frame3 = Instance.new("Frame")
		frame3.BackgroundColor3 = Color3.fromRGB(14, 12, 10)
		frame3.BackgroundTransparency = random:NextNumber(0.55, 0.82)
		frame3.BorderSizePixel = 0
		frame3.Size = UDim2.new(0, random:NextInteger(18, 40), 0, 1)
		frame3.Position = UDim2.new(0, random:NextInteger(-6, 22), 0, random:NextInteger(4, 40))
		frame3.Rotation = random:NextInteger(-55, 55)
		frame3.ZIndex = zIndex + 4
		frame3.Parent = photo
	end

	for _ = 1, 2 do
		local frame3 = Instance.new("Frame")
		frame3.BackgroundColor3 = Color3.fromRGB(40, 30, 20)
		frame3.BackgroundTransparency = random:NextNumber(0.72, 0.86)
		frame3.BorderSizePixel = 0
		frame3.Size = UDim2.new(0, random:NextInteger(10, 18), 0, random:NextInteger(7, 12))
		frame3.Position = UDim2.new(0, random:NextInteger(0, 30), 0, random:NextInteger(0, 34))
		frame3.Rotation = random:NextInteger(-30, 30)
		frame3.ZIndex = zIndex + 4
		frame3.Parent = photo
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = frame3
	end

	addTape(
		avatarPhoto,
		UDim2.new(0.5, random:NextInteger(-7, 7), 0, 1),
		UDim2.new(0, 26, 0, 9),
		random:NextInteger(-14, 14),
		color12,
		0.14,
		zIndex + 6
	)
	addTape(
		avatarPhoto,
		UDim2.new(1, -2, 1, -3),
		UDim2.new(0, 20, 0, 8),
		p3 % 2 == 0 and 38 or -38,
		p3 % 2 == 0 and color13 or color12,
		0.18,
		zIndex + 6
	)
	return avatarPhoto
end

local UserInputService2 = game:GetService("UserInputService")

local isCompact = UserInputService2.TouchEnabled and not UserInputService2.KeyboardEnabled

local function columnText(data, p)
	local judgements2 = data.Judgements or {}

	if p == "Accuracy" then
		return string.format("%.1f%%", data.Accuracy or 0)
	elseif p == "Score" then
		return withCommas(data.Score) -- inferred equivalent call
	elseif p == "MaxCombo" then
		return string.format("%d", data.MaxCombo or 0)
	elseif p == "Perfect" then
		return string.format("%d", judgements2.Perfect or 0)
	elseif p == "Miss" then
		return string.format("%d", judgements2.Miss or 0)
	elseif p == "Wrong" then
		return string.format("%d", data.Wrong or judgements2.Wrong or 0)
	end

	return "-"
end

local function sortedColumnOf(p) -- 2 equivalent calls inferred from this helper
	return if p == "Overall" then "Score" else p
end

local columnHeader = Instance.new("Frame")
columnHeader.Name = "ColumnHeader"
columnHeader.BackgroundTransparency = 1
columnHeader.Size = UDim2.new(1, 0, 0, 26)
columnHeader.LayoutOrder = 2
columnHeader.Parent = rankings
statsRow = Instance.new("UIPadding")
statsRow.PaddingLeft = UDim.new(0, 76)
statsRow.Parent = columnHeader
local cols = isCompact and {
	Name = { X = 0, W = 0.26 },
	Instrument = { X = 0.26, W = 0 },
	Grade = { X = 0.26, W = 0.07 },
	Accuracy = { X = 0.33, W = 0.13 },
	Score = { X = 0.46, W = 0.17 },
	MaxCombo = { X = 0.63, W = 0.11 },
	Perfect = { X = 0.74, W = 0.1 },
	Miss = { X = 0.84, W = 0.08 },
	Wrong = { X = 0.92, W = 0.08 }
} or {
	Name = { X = 0, W = 0.25 },
	Instrument = { X = 0.25, W = 0.1 },
	Grade = { X = 0.35, W = 0.06 },
	Accuracy = { X = 0.41, W = 0.1 },
	Score = { X = 0.51, W = 0.14 },
	MaxCombo = { X = 0.65, W = 0.09 },
	Perfect = { X = 0.74, W = 0.09 },
	Miss = { X = 0.83, W = 0.08 },
	Wrong = { X = 0.91, W = 0.09 }
}

local v22 = {}
local v23 = { "Accuracy", "Score", "MaxCombo", "Perfect", "Miss", "Wrong" }

for _, v24 in ipairs({
	{ Key = "Name", Long = "PLAYER", Short = "PLAYER" },
	{ Key = "Instrument", Long = "INSTRUMENT", Short = "" },
	{ Key = "Grade", Long = "GRADE", Short = "GRD" },
	{ Key = "Accuracy", Long = "ACCURACY", Short = "ACC" },
	{ Key = "Score", Long = "SCORE", Short = "SCORE" },
	{ Key = "MaxCombo", Long = "MAX COMBO", Short = "COMBO" },
	{ Key = "Perfect", Long = "PERFECT", Short = "PERF" },
	{ Key = "Miss", Long = "MISS", Short = "MISS" },
	{ Key = "Wrong", Long = "WRONG", Short = "WRONG" }
}) do
	local v25 = cols[v24.Key]
	v22[v24.Key] = makeLabel({
		Parent = columnHeader,
		Text = isCompact and v24.Short or v24.Long,
		Font = StyledTheme.Fonts.Bold,
		TextSize = 13,
		Color = StyledTheme.Colors.TextDisabled,
		Size = UDim2.new(v25.W, 0, 1, -3),
		Position = UDim2.new(v25.X, 0, 0, 0),
		XAlign = v24.Key == "Name" and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
	})
end

statsRow = Instance.new("Frame")
statsRow.BackgroundColor3 = StyledTheme.Colors.Border
statsRow.BackgroundTransparency = 0.45
statsRow.BorderSizePixel = 0
statsRow.AnchorPoint = Vector2.new(0, 1)
statsRow.Position = UDim2.new(0, 0, 1, 0)
statsRow.Size = UDim2.new(1, 0, 0, 1)
statsRow.Parent = columnHeader

local function highlightHeader(p)
	local v24 = sortedColumnOf(p) -- inferred equivalent call

	for k, v25 in pairs(v22) do
		v25.TextColor3 = k == v24 and StyledTheme.Colors.Accent or StyledTheme.Colors.TextDisabled
	end
end

local function addStatColumns(parent, p, p2)
	local v24 = sortedColumnOf(p2) -- inferred equivalent call

	for _, v25 in ipairs(v23) do
		local v26 = cols[v25]
		makeLabel({
			Parent = parent,
			Text = columnText(p, v25),
			Font = StyledTheme.Fonts.Medium,
			TextSize = 19,
			Color = v25 == v24 and StyledTheme.Colors.Accent or StyledTheme.Colors.TextPrimary,
			Size = UDim2.new(v26.W, 0, 1, 0),
			Position = UDim2.new(v26.X, 0, 0, 0),
			XAlign = Enum.TextXAlignment.Center
		})
	end
end

statsRow = makeLabel({
	Parent = categorySelector,
	Wrapped = true,
	Text = "<b>OVERALL</b> final score (accuracy, combo, difficulty, part size)  ·  <b>ACCURACY</b> hit accuracy  ·  <b>MAX COMBO</b> longest hit streak  ·  <b>PERFECT</b> perfect-timing hits  ·  <b>MISS</b> notes missed  ·  <b>WRONG</b> key presses with no note  ·  Joined late (under 90% of the song): ranked in OVERALL only",
	Font = StyledTheme.Fonts.Regular,
	TextSize = 14,
	Color = StyledTheme.Colors.TextSecondary,
	Size = UDim2.new(1, 0, 0, 16),
	LayoutOrder = 4,
	XAlign = Enum.TextXAlignment.Center,
	YAlign = Enum.TextYAlignment.Top
})

statsRow.RichText = true
statsRow.AutomaticSize = Enum.AutomaticSize.Y

local v24 = {
	{
		Key = "Accuracy",
		Nick = "PRECISION MACHINE",
		Ok = function(p): boolean
			return (p.Accuracy or 0) >= 90
		end
	},
	{
		Key = "Score",
		Nick = "SCORE HUNTER",
		Ok = function(p): boolean
			return (p.Accuracy or 0) >= 85
		end
	},
	{
		Key = "MaxCombo",
		Nick = "COMBO MONSTER",
		Ok = function(p): boolean
			return (p.TotalNotes or 0) > 0 and (p.MaxCombo or 0) / p.TotalNotes >= 0.5
		end
	},
	{
		Key = "Perfect",
		Nick = "PERFECTIONIST",
		Ok = function(p): boolean
			local totalNotes = p.TotalNotes or 0
			return totalNotes > 0 and ((p.Judgements or {}).Perfect or 0) / totalNotes >= 0.5
		end
	},
	{
		Key = "Miss",
		Nick = "IRON HANDS",
		Ok = function(p): boolean
			local v24 = judgedCountOf(p) -- inferred equivalent call
			return v24 > 0 and ((p.Judgements or {}).Miss or 0) / v24 <= 0.05
		end
	},
	{
		Key = "Wrong",
		Nick = "CLEAN FINGERS",
		Ok = function(p): boolean
			return (p.Wrong or 0) <= 5 and (p.Accuracy or 0) >= 80
		end
	}
}

local function computeNicknames(list)
	local v25 = {}

	for _, item in ipairs(list) do
		if not item.IsAutoPlayed then
			table.insert(v25, item)
		end
	end

	local v26 = {}

	for _, v27 in ipairs(v25) do
		v26[v27] = {}
	end

	for _, v27 in ipairs(v24) do
		local v28 = v19[v27.Key] == true

		for _, v29 in ipairs(v25) do
			local v30 = categoryValue(v29, v27.Key)

			if v30 == nil then
				continue
			end

			local v31 = 1

			for _, v32 in ipairs(v25) do
				local v36 = categoryValue(v32, v27.Key)

				if v36 ~= nil and (v28 and v36 < v30 or not v28 and v30 < v36) then
					v31 += 1
				end
			end

			v26[v29][v27.Key] = v31
		end
	end

	local nickSet = {}
	local nicknames = {}

	for i = 1, math.max(1, #v25) do
		for _, v27 in ipairs(v24) do
			if nickSet[v27.Nick] then
				continue
			end

			for _, v28 in ipairs(v25) do
				if not nicknames[v28] and v26[v28][v27.Key] == i and v27.Ok(v28) then
					nicknames[v28] = v27.Nick
					nickSet[v27.Nick] = true
					break
				end
			end
		end
	end

	for _, v27 in ipairs(v25) do
		if nicknames[v27] then
			continue
		end

		local accuracy = v27.Accuracy or 0

		if accuracy >= 90 then
			nicknames[v27] = "STEADY HANDS"
		elseif accuracy >= 80 then
			nicknames[v27] = "RISING STAR"
		elseif accuracy >= 65 then
			nicknames[v27] = "STILL WARMING UP"
		else
			nicknames[v27] = "FEARLESS ROOKIE"
		end
	end

	return nicknames
end

v17.Cols = cols
v17.IsCompact = isCompact
v17.AddStatColumns = addStatColumns
v17.HighlightHeader = highlightHeader
v17.HeaderRow = columnHeader
v17.ComputeNicknames = computeNicknames

v17.BuildAvatar = buildAvatar
v17.Order = orderResults
v17.UpdateBanner = updateMvpBanner
v17.FormatValue = formatCategoryValue
v17.Refresh = refreshPills
v17.SelectorFrame = categorySelector
v17.Banner = mvpBanner

local function openResults(data)
	if flag then
		return
	end

	local v25 = nil
	local v26 = nil

	for i, playerResult in ipairs(data.PlayerResults) do
		if playerResult.Player == localPlayer then
			v26 = i
			v25 = playerResult
			break
		end
	end

	local stageReport = data.StageReport == true

	if stageReport then
		for i, playerResult in ipairs(data.PlayerResults) do
			if not playerResult.IsAutoPlayed then
				v26 = i
				v25 = playerResult
				break
			end
		end

		v25 = v25 or data.PlayerResults[1]
		v26 = v26 or 1
	end

	if not v25 then
		return
	end

	resultsScreenUI:SetAttribute("StageReportMode", stageReport)

	local early = data.Early == true

	flag = true

	SessionCameraSettings.SetMenuOpen(true)

	label2.AutoLocalize = false
	label2.Text = string.format("%s · %s", string.upper(data.SongName or "-"), string.upper(v25.Instrument or "-"))

	if v25.DifficultyTimeline then
		local v27 = not ((v25.DifficultyFactor or 1) < 0.995) and ""
			or string.format("  ·  rating ×%.2f", v25.DifficultyFactor)

		label17.Text = "Difficulty: " .. formatDifficultyTimeline(v25.DifficultyTimeline) .. v27
		label17.Visible = true
	else
		label17.Text = ""
		label17.Visible = false
	end

	local chartWeight = v25.ChartWeight

	if type(chartWeight) == "number" and chartWeight < 0.995 and not v25.IsAutoPlayed then
		label18.Text = string.format(
			"Part weight ×%.2f  ·  this part covers less of the song than the others, so score is scaled",
			chartWeight
		)

		label18.Visible = true
	else
		label18.Text = ""
		label18.Visible = false
	end

	local coverage = v25.Coverage

	if type(coverage) == "number" and coverage < 0.9 and not v25.IsAutoPlayed then
		local v27 = math.floor((v25.JoinElapsed or 0) + 0.5)
		label19.Text = string.format(
			"Joined late at %d:%02d  ·  you played %d%% of this part, so score is scaled (accuracy covers only the notes you played)",
			v27 // 60,
			v27 % 60,
			(math.floor(coverage * 100 + 0.5))
		)

		label19.Visible = true
	else
		label19.Text = ""
		label19.Visible = false
	end

	label11.Text = v25.IsAutoPlayed and "AUTO" or v25.Grade or "-"

	label12.Text = v25.IsAutoPlayed and "" or pickResultComment(v25.Grade, v25.Instrument)

	if v25.IsAutoPlayed then
		label13.Text = ""
	else
		local hex = StyledTheme.Colors.Accent:ToHex()
		label13.Text = StarConfig.RichText(
			StarConfig.FromGrade(v25.Grade),
			hex,
			StyledTheme.Colors.TextSecondary:ToHex()
		) .. ((type(v25.SongStars) ~= "number" or type(v25.PreviousSongStars) ~= "number" or not (v25.SongStars > v25.PreviousSongStars)) and "" or string.format(
			"  <font color=\"#%s\" size=\"14\"><b>NEW</b></font>",
			hex
		))
	end

	label22.Visible = false
	label23.Visible = false

	if success then
		local peakNudge = v25.PeakNudge

		if v25.IsAutoPlayed or type(peakNudge) ~= "table" or type(peakNudge.Target) ~= "number" then
			if not v25.IsAutoPlayed then
				local success3, result3, v27 = pcall(result.Pick, v25, {
					PlayerCount = #data.PlayerResults,
					IsEarly = early
				})

				if success3 and result3 then
					local v28 = v27 == "tip" and "TIP" or "BACKSTAGE"
					label22.Text = string.format(
						"<font color=\"#%s\"><b>%s</b></font>  %s",
						StyledTheme.Colors.Accent:ToHex(),
						v28,
						escapeRichText(result3) -- inferred equivalent call
					)

					label22.Visible = true
				end
			end
		else
			label22.Text = string.format(
				"<font color=\"#%s\"><b>PLAYER CARD</b></font>  %s",
				StyledTheme.Colors.Accent:ToHex(),
				escapeRichText(string.format( -- inferred equivalent call
					"So close - reach %d%% on this song to show it on your Player Card (you got %.1f%%).",
					peakNudge.Target,
					tonumber(v25.Accuracy) or 0
				))
			)

			label22.Visible = true
		end

		local success3, result3 = pcall(result.PickGeneral)

		if success3 and result3 then
			label23.Text = "TIP · " .. result3
			label23.Visible = true
		end
	end

	label11.TextTransparency = 0

	if v25.IsAutoPlayed then
		uiScale.Scale = 1
	elseif v25.Grade == "S" or v25.Grade == "A" then
		uiScale.Scale = 0.4
		TweenService:Create(uiScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
	elseif v25.Grade == "F" then
		uiScale.Scale = 1
		label11.TextTransparency = 1
		TweenService:Create(label11, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			TextTransparency = 0
		}):Play()
	else
		uiScale.Scale = 0.85
		TweenService:Create(uiScale, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
	end

	label3.Text = (early or v25.IsAutoPlayed) and "-" or "#" .. tostring(v26 or "-")
	label4.Text = string.upper(v25.Instrument or "-")
	avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(localPlayer.UserId) .. "&w=150&h=150"
	label5.AutoLocalize = false
	label5.Text = v25.PlayerName or localPlayer.Name
	label7.Text = string.format("%.1f%%", v25.Accuracy)

	label6.Text = computeBadge(v25) or ""

	if v25.PersonalBest then
		if v25.IsNewPersonalBest then
			label9.Text = string.format("%.1f%%  (NEW!)", v25.PersonalBest.Accuracy)
			label9.TextColor3 = StyledTheme.Colors.Accent
		else
			label9.Text = string.format("%.1f%%", v25.PersonalBest.Accuracy)
			label9.TextColor3 = StyledTheme.Colors.TextSecondary
		end
	else
		label9.Text = "-"
		label9.TextColor3 = StyledTheme.Colors.TextSecondary
	end

	local accuracyDelta = v25.Extras and v25.Extras.AccuracyDelta
	local v27, v28

	if v25.IsAutoPlayed or type(accuracyDelta) ~= "number" or not (math.abs(accuracyDelta) >= 0.05) then
		v28 = false
	else
		v27 = string.format("%s%.1f%% vs your best", accuracyDelta > 0 and "+" or "-", (math.abs(accuracyDelta)))
		v28 = accuracyDelta > 0
	end

	local v29

	if v25.PersonalBest == nil then
		v29 = v27 ~= nil
	else
		v29 = false
	end

	label8.Visible = not v29
	label9.Visible = not v29
	label10.Position = UDim2.new(0, 10, 0, v29 and 276 or 302)
	label10.Text = v27 or ""
	label10.TextColor3 = v28 and StyledTheme.Colors.Accent or StyledTheme.Colors.TextSecondary
	label10.Visible = v27 ~= nil

	label15.Text = string.format(
		"%d / %d NOTES HIT  ·  %d WRONG",
		v25.HitCount or 0,
		v25.TotalNotes or 0,
		v25.Wrong or 0
	)

	label16.AutoLocalize = false
	label16.Text = early and "" or buildRivalCompareText(data.PlayerResults, v25, v26)

	local totalCrowd = v25.TotalCrowd

	if type(totalCrowd) ~= "number" then
		totalCrowd = nil

		for _, playerResult in ipairs(data.PlayerResults) do
			if type(playerResult.TotalCrowd) == "number" then
				totalCrowd = playerResult.TotalCrowd
				break
			end
		end
	end

	if totalCrowd then
		label21.Text = string.format("total crowd : %d", totalCrowd)
		label21.Visible = true
		label24.Text = string.format("total crowd : %d", totalCrowd)
		label24.Visible = true
	else
		label21.Text = ""
		label21.Visible = false
		label24.Text = ""
		label24.Visible = false
	end

	for k, v30 in pairs(v6) do
		v30.Text = "× " .. tostring(v25.Judgements[k] or 0)
		local judgmentColor = getJudgmentColor(k) -- inferred equivalent call
		v30.TextColor3 = judgmentColor

		if v5[k] then
			v5[k].BackgroundColor3 = judgmentColor
		end
	end

	v8.Apply(v25)

	local function thousands(value) -- 4 equivalent calls inferred from this helper
		return (tostring((math.floor((value or 0) + 0.5))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
	end

	local v30 = nil
	local v31 = false
	local extras = v25.Extras

	if type(extras) == "table" and not v25.IsAutoPlayed then
		local songBest = extras.SongBest

		if extras.FirstClear == true then
			v30 = "FIRST CLEAR"
			v31 = true
		elseif
			type(songBest) == "table"
			and type(songBest.Previous) == "number"
			and type(songBest.Score) == "number"
		then
			if songBest.Improved then
				v30 = string.format("NEW SONG BEST  %s → %s", thousands(songBest.Previous), thousands(songBest.Score)) -- inferred equivalent call
				v31 = true
			else
				v30 = string.format(
					"SONG BEST %s  ·  %s TO BEAT",
					thousands(songBest.Previous), -- inferred equivalent call
					thousands(songBest.Previous - songBest.Score + 1) -- inferred equivalent call
				)
			end
		end
	end

	label20.Text = v30 or ""
	label20.TextColor3 = v31 and StyledTheme.Colors.Accent or StyledTheme.Colors.TextSecondary
	label20.Visible = v30 ~= nil

	fn(v25.PerformanceTimeline, v25)

	for _, child in ipairs(rankings:GetChildren()) do
		if child.Name == "RankRow" then
			child:Destroy()
		end
	end

	topRow.Visible = not stageReport
	judgements.Visible = not stageReport
	timeline.Visible = not stageReport

	if stageReport then
		label22.Visible = false
		label23.Visible = false
		label2.AutoLocalize = false
		label2.Text = string.upper(data.SongName or "-") .. (totalCrowd and string.format("  ·  total crowd : %d", totalCrowd) or "")
	end

	for _, label28 in ipairs(header:GetChildren()) do
		if label28:IsA("TextLabel") and label28 ~= label2 then
			label28.Text = stageReport and string.format("%s · LAST REPORT", string.upper(data.StageName or "STAGE"))
				or "RESULTS"
		end
	end

	rankings.Visible = not early

	local function renderRankRows(p)
		for _, child in ipairs(rankings:GetChildren()) do
			if child.Name == "RankRow" then
				child:Destroy()
			end
		end

		local order, v32, v37, v38 = v17.Order(data.PlayerResults, p)
		v17.UpdateBanner(p, v32, v37)
		v17.Banner.Visible = v38 >= 1
		v17.HeaderRow.Visible = v38 >= 1
		v17.HighlightHeader(p)
		local nicknames = v17.ComputeNicknames(data.PlayerResults)
		v17.SelectorFrame.Visible = v38 >= 1
		local count3 = 0

		for i, v39 in ipairs(order) do
			local rankRow = Instance.new("Frame")
			rankRow.Name = "RankRow"
			rankRow.BackgroundTransparency = 1
			rankRow.Size = UDim2.new(1, 0, 0, 28)
			rankRow.AutomaticSize = Enum.AutomaticSize.Y
			rankRow.LayoutOrder = i + 2
			rankRow.Parent = rankings

			local uiListLayout = Instance.new("UIListLayout")
			uiListLayout.FillDirection = Enum.FillDirection.Vertical
			uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			uiListLayout.Padding = UDim.new(0, 10)
			uiListLayout.Parent = rankRow

			local row = Instance.new("Frame")
			row.Name = "Row"
			row.BackgroundTransparency = 1
			row.Size = UDim2.new(1, 0, 0, 28)
			row.LayoutOrder = 1
			row.Parent = rankRow
			local v40

			if v39.Player == localPlayer then
				v40 = true
			elseif v39.UserId == nil then
				v40 = false
			else
				v40 = v39.UserId == localPlayer.UserId
			end

			rankRow:SetAttribute("IsMe", v40)

			if v39.IsAutoPlayed then
				makeLabel({
					Parent = row,
					AutoLocalize = false,
					Text = string.format("%s - autoplay", v39.PlayerName),
					Font = StyledTheme.Fonts.Regular,
					TextSize = StyledTheme.TextSize.M,
					Color = StyledTheme.Colors.TextSecondary,
					Size = UDim2.new(1, 0, 1, 0),
					XAlign = Enum.TextXAlignment.Left,
					Truncate = Enum.TextTruncate.AtEnd
				})
			else
				count3 += 1

				local uiPadding = Instance.new("UIPadding")
				uiPadding.PaddingLeft = UDim.new(0, 76)
				uiPadding.Parent = rankRow
				local uiSizeConstraint = Instance.new("UISizeConstraint")
				uiSizeConstraint.MinSize = Vector2.new(0, 72)
				uiSizeConstraint.Parent = rankRow
				v17.BuildAvatar(row, v39, count3 == 1, i)
				makeLabel({
					Parent = row,
					AutoLocalize = false,
					Text = string.format("#%d  %s", count3, v39.PlayerName),
					Font = StyledTheme.Fonts.Medium,
					TextSize = 20,
					Color = v40 and StyledTheme.Colors.Accent or StyledTheme.Colors.TextPrimary,
					Size = UDim2.new(v17.Cols.Name.W, 0, 1, 0),
					XAlign = Enum.TextXAlignment.Left,
					Truncate = Enum.TextTruncate.AtEnd
				})

				makeLabel({
					Parent = row,
					Text = v17.IsCompact and "" or string.upper(v39.Instrument or "-"),
					Font = StyledTheme.Fonts.Regular,
					TextSize = 17,
					Color = StyledTheme.Colors.TextSecondary,
					Size = UDim2.new(v17.Cols.Instrument.W, 0, 1, 0),
					Position = UDim2.new(v17.Cols.Instrument.X, 0, 0, 0),
					XAlign = Enum.TextXAlignment.Center
				})

				makeLabel({
					Parent = row,
					Text = v39.Grade or "-",
					Font = StyledTheme.Fonts.Bold,
					TextSize = 24,
					Color = StyledTheme.Colors.Accent,
					Size = UDim2.new(v17.Cols.Grade.W, 0, 1, 0),
					Position = UDim2.new(v17.Cols.Grade.X, 0, 0, 0),
					XAlign = Enum.TextXAlignment.Center
				})

				v17.AddStatColumns(row, v39, p)

				local tags = Instance.new("Frame")
				tags.Name = "Tags"
				tags.BackgroundTransparency = 1
				tags.Size = UDim2.new(1, 0, 0, 28)
				tags.AutomaticSize = Enum.AutomaticSize.Y
				tags.LayoutOrder = 2
				tags.Parent = rankRow

				local uiListLayout2 = Instance.new("UIListLayout")
				uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
				uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
				uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
				uiListLayout2.Wraps = true
				uiListLayout2.Padding = UDim.new(0, 8)
				uiListLayout2.Parent = tags

				local uiPadding2 = Instance.new("UIPadding")
				uiPadding2.PaddingLeft = UDim.new(0, 12)
				uiPadding2.Parent = tags

				local set = {}

				for _, v41 in ipairs(v39.Awards or {}) do
					set[v41] = true
				end

				local nickname = nicknames[v39]

				if nickname then
					local label28 = makeLabel({
						Parent = tags,
						Text = "“" .. nickname .. "”",
						Font = StyledTheme.Fonts.Medium,
						TextSize = 18,
						Color = StyledTheme.Colors.Accent,
						Size = UDim2.new(0, 0, 0, 24),
						LayoutOrder = 0,
						XAlign = Enum.TextXAlignment.Left
					})

					label28.AutomaticSize = Enum.AutomaticSize.X
					local uiPadding3 = Instance.new("UIPadding")
					uiPadding3.PaddingRight = UDim.new(0, 6)
					uiPadding3.Parent = label28
				end

				local count4 = 0
				local function addChip(text, p2) -- 4 equivalent calls inferred from this helper
					count4 += 1
					makeChip(tags, text, p2, count4)
				end

				if set.MVP then
					addChip(v16.MVP.Text, v16.MVP.Color) -- inferred equivalent call
				end

				local text, v42 = difficultyChipInfo(v39)
				addChip(text, v42) -- inferred equivalent call

				if type(v39.Coverage) == "number" and v39.Coverage < 0.9 then
					addChip( -- inferred equivalent call
						string.format("JOINED LATE · %d%%", (math.floor(v39.Coverage * 100 + 0.5))),
						StyledTheme.Colors.TextSecondary
					)
				end

				for _, v43 in ipairs(v18) do
					if set[v43] then
						addChip(v16[v43].Text, v16[v43].Color) -- inferred equivalent call
					end
				end

				if v39.DifficultyTimeline and v39.DifficultyMixed then
					local label28 = makeLabel({
						Parent = rankRow,
						Wrapped = true,
						Text = "Difficulty: " .. formatDifficultyTimeline(v39.DifficultyTimeline),
						Font = StyledTheme.Fonts.Regular,
						TextSize = StyledTheme.TextSize.M,
						Color = StyledTheme.Colors.TextSecondary,
						Size = UDim2.new(1, 0, 0, 16),
						LayoutOrder = 3,
						XAlign = Enum.TextXAlignment.Left,
						YAlign = Enum.TextYAlignment.Top
					})

					label28.AutomaticSize = Enum.AutomaticSize.Y
					local uiPadding3 = Instance.new("UIPadding")
					uiPadding3.PaddingLeft = UDim.new(0, 12)
					uiPadding3.Parent = label28
				end
			end
		end
	end

	v17.Selected = "Overall"
	v17.Refresh()
	function v17.Render(...)
		v14 = nil
		local v32 = renderRankRows(...)
		task.delay(0.6, function()
			if flag and not v14 then
				pcall(collectFade)
			end
		end)
		return v32
	end

	renderRankRows("Overall")

	label25.Text = "0"
	label26.Text = "0"
	label26.TextColor3 = StyledTheme.Colors.TextPrimary
	local comboTierBox2 = frame:FindFirstChild("ComboTierBox")

	if comboTierBox2 then
		comboTierBox2.Visible = false
		comboTierBox2.GroupTransparency = 1
	end

	label14.Text = "0.00%"
	overlay.BackgroundTransparency = 1
	panel.CanvasPosition = Vector2.new(0, 0)

	count2 += 1
	restoreFade()
	v14 = nil
	applyPose(udim3, 1) -- inferred equivalent call
	closeButton.Visible = true
	label.Visible = UserInputService.KeyboardEnabled
	resultsScreenUI.DisplayOrder = 50
	reportViewing(true) -- inferred equivalent call
	task.delay(1.6, function()
		if flag and not v14 then
			pcall(collectFade)
		end
	end)

	resultsScreenUI.Enabled = true
	TweenService:Create(
		overlay,
		TweenInfo.new(
			StyledTheme.Animation.Slow,
			StyledTheme.Animation.EasingStyle,
			StyledTheme.Animation.EasingDirection
		),
		{ BackgroundTransparency = 0.6 }
	):Play()

	countUpNumber(label14, v25.Accuracy, 2, "%", 0.7) -- inferred equivalent call

	if v25.IsAutoPlayed then
		label25.Text = "AUTO"
	else
		local v32 = label25
		local score = v25.Score
		local v37 = 0
		local v38 = ""
		local v39 = 0.9 or 0.6
		local lastTime = os.clock()
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local v40 = math.clamp((os.clock() - lastTime) / v39, 0, 1)
			local v42 = score * (1 - (1 - v40) ^ 3)

			if v37 > 0 then
				v32.Text = string.format("%." .. v37 .. "f", v42) .. v38
			else
				v32.Text = string.format("%d", (math.floor(v42 + 0.5))) .. v38
			end

			if v40 >= 1 then
				renderSteppedConnection:Disconnect()
			end
		end)
	end

	task.delay(0.15, function()
		local color3_2 = StreakTierColors.GetColor3(v25.MaxCombo)

		if color3_2 then
			label26.TextColor3 = color3_2

			local comboTierBox3 = frame:FindFirstChild("ComboTierBox")

			if comboTierBox3 and StreakTierColors.NeedsBackdrop(v25.MaxCombo) then
				local text = string.format("%d", v25.MaxCombo)
				local v32 = #text * 17
				pcall(function()
					local getTextBoundsParams = Instance.new("GetTextBoundsParams")
					getTextBoundsParams.Text = text
					getTextBoundsParams.Font = label26.FontFace
					getTextBoundsParams.Size = label26.TextSize
					getTextBoundsParams.Width = 1000
					local TextService = game:GetService("TextService")
					v32 = TextService:GetTextBoundsAsync(getTextBoundsParams).X
				end)
				comboTierBox3.Size = UDim2.fromOffset(math.ceil(v32) + 20, 32)
				comboTierBox3.GroupTransparency = 1
				comboTierBox3.Visible = true
				TweenService:Create(comboTierBox3, TweenInfo.new(0.3), { GroupTransparency = 0 }):Play()
			end
		end

		local v32 = label26
		local maxCombo = v25.MaxCombo
		local v37 = 0
		local v38 = ""
		local v39 = 0.5 or 0.6
		local lastTime = os.clock()
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local v40 = math.clamp((os.clock() - lastTime) / v39, 0, 1)
			local v42 = maxCombo * (1 - (1 - v40) ^ 3)

			if v37 > 0 then
				v32.Text = string.format("%." .. v37 .. "f", v42) .. v38
			else
				v32.Text = string.format("%d", (math.floor(v42 + 0.5))) .. v38
			end

			if v40 >= 1 then
				renderSteppedConnection:Disconnect()
			end
		end)
	end)

	inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
			closeResults()
		end
	end)
end

UISkin.AddRoot(resultsScreenUI)

ShowSongResults.OnClientEvent:Connect(function(p)
	openResults(p)
end)

task.spawn(function()
	local resultsPopularityGain = RemoteEvents:WaitForChild("ResultsPopularityGain", 30)

	if not resultsPopularityGain then
		return
	end

	resultsPopularityGain.OnClientEvent:Connect(function(p)
		if not flag or resultsScreenUI:GetAttribute("StageReportMode") == true then
			return
		end

		local success3, result3 = pcall(v8.AddLate, "Popularity", p)

		if not success3 then
			warn("[ResultsScreenUI] Popularity late gagal: " .. tostring(result3))
		end
	end)
end)

RemoteEvents:WaitForChild("StageLastReportData").OnClientEvent:Connect(function(p, p2)
	if typeof(p2) ~= "table" or typeof(p2.PlayerResults) ~= "table" or #p2.PlayerResults == 0 then
		return
	end

	local v25 = {
		SongName = p2.SongName,
		PlayerResults = p2.PlayerResults,
		StageReport = true,
		StageName = 0
	}

	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	v25.StageName = require(ReplicatedStorage2.Modules.StageNames).Display(p)
	openResults(v25)
end)