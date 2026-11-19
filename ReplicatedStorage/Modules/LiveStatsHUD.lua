local Players = game:GetService("Players")

local HudOpacity = require(script.Parent:WaitForChild("HudOpacity"))
local SettingsState = require(script.Parent:WaitForChild("SettingsState"))

local LiveStatsHUD = {}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local color = Color3.fromRGB(18, 18, 20)
local color2 = Color3.fromRGB(180, 180, 185)
local color3 = Color3.fromRGB(190, 150, 80)

local liveStatsHUD = Instance.new("ScreenGui")
liveStatsHUD.Name = "LiveStatsHUD"
liveStatsHUD.ResetOnSpawn = false
liveStatsHUD.Enabled = false
liveStatsHUD.Parent = PlayerGui

local container = Instance.new("Frame")
container.Name = "Container"
container.AnchorPoint = Vector2.new(1, 1)

container.Position = UDim2.new(1, -16, 1, -16)
container.Size = UDim2.new(0, 160, 0, 34)
container.BackgroundColor3 = color

container.BackgroundTransparency = 0.45
container.ClipsDescendants = true
container.Parent = liveStatsHUD

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = container

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingLeft = UDim.new(0, 8)
uiPadding.PaddingRight = UDim.new(0, 8)
uiPadding.Parent = container

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Vertical
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.Padding = UDim.new(0, 1)
uiListLayout.Parent = container

local notesLabel = Instance.new("TextLabel")
notesLabel.Name = "NotesLabel"
notesLabel.Size = UDim2.new(1, 0, 0, 14)
notesLabel.BackgroundTransparency = 1
notesLabel.Font = Enum.Font.GothamMedium
notesLabel.TextSize = 11
notesLabel.TextScaled = true
notesLabel.TextColor3 = color2
notesLabel.TextXAlignment = Enum.TextXAlignment.Right
notesLabel.Text = "0 / 0 NOTES HIT"
notesLabel.Parent = container

local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
uiTextSizeConstraint.MaxTextSize = 11
uiTextSizeConstraint.MinTextSize = 6
uiTextSizeConstraint.Parent = notesLabel

local accuracyRow = Instance.new("Frame")
accuracyRow.Name = "AccuracyRow"
accuracyRow.Size = UDim2.new(1, 0, 0, 14)
accuracyRow.BackgroundTransparency = 1
accuracyRow.Parent = container

local uiListLayout2 = Instance.new("UIListLayout")
uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
uiListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Right
uiListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout2.Padding = UDim.new(0, 6)
uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout2.Parent = accuracyRow

local usernameLabel = Instance.new("TextLabel")
usernameLabel.Name = "UsernameLabel"
usernameLabel.LayoutOrder = 1
usernameLabel.AutomaticSize = Enum.AutomaticSize.X
usernameLabel.Size = UDim2.new(0, 0, 1, 0)
usernameLabel.BackgroundTransparency = 1
usernameLabel.Font = Enum.Font.GothamMedium
usernameLabel.TextSize = 11
usernameLabel.TextColor3 = color2
usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
usernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
usernameLabel.Text = LocalPlayer.Name
usernameLabel.Parent = accuracyRow

local uiSizeConstraint = Instance.new("UISizeConstraint")
uiSizeConstraint.MaxSize = Vector2.new(70, 1e999)
uiSizeConstraint.Parent = usernameLabel

local accuracyLabel = Instance.new("TextLabel")
accuracyLabel.Name = "AccuracyLabel"
accuracyLabel.LayoutOrder = 2
accuracyLabel.AutomaticSize = Enum.AutomaticSize.X
accuracyLabel.Size = UDim2.new(0, 0, 1, 0)
accuracyLabel.BackgroundTransparency = 1
accuracyLabel.Font = Enum.Font.GothamBold
accuracyLabel.TextSize = 12
accuracyLabel.TextColor3 = color3
accuracyLabel.TextXAlignment = Enum.TextXAlignment.Right
accuracyLabel.Text = "ACCURACY: 0%"
accuracyLabel.Parent = accuracyRow

local uiTextSizeConstraint2 = Instance.new("UITextSizeConstraint")
uiTextSizeConstraint2.MaxTextSize = 11
uiTextSizeConstraint2.MinTextSize = 6
uiTextSizeConstraint2.Parent = accuracyLabel

local function applyHudOpacity() -- 1 equivalent call inferred from this helper
	container.BackgroundTransparency = HudOpacity.Apply(0.45, "Hud")
	local textTransparency = HudOpacity.Apply(0, "Hud")
	notesLabel.TextTransparency = textTransparency
	usernameLabel.TextTransparency = textTransparency
	accuracyLabel.TextTransparency = textTransparency
end

applyHudOpacity() -- inferred equivalent call
SettingsState.OnChanged(applyHudOpacity)

local v = {}
local v2 = {}

function LiveStatsHUD.OnJudgment(p)
	table.insert(v, p)
end

function LiveStatsHUD.OnVisibilityChanged(p)
	table.insert(v2, p)
end

local function fireVisibility(p) -- 2 equivalent calls inferred from this helper
	for _, callback in ipairs(v2) do
		pcall(callback, p)
	end
end

function LiveStatsHUD.NotifyJudgment(p, p2)
	for _, callback in ipairs(v) do
		pcall(callback, p, p2)
	end
end

function LiveStatsHUD.Show()
	local v3 = not liveStatsHUD.Enabled
	liveStatsHUD.Enabled = true

	if v3 then
		fireVisibility(true) -- inferred equivalent call
	end
end

function LiveStatsHUD.Hide()
	local enabled = liveStatsHUD.Enabled
	liveStatsHUD.Enabled = false

	if enabled then
		fireVisibility(false) -- inferred equivalent call
	end
end

function LiveStatsHUD.SetStats(p, p2, p3, value)
	if p3 and p3 > 0 then
		notesLabel.Text = string.format("%d / %d NOTES HIT  ·  %d WRONG", p, p2, p3)
	else
		notesLabel.Text = string.format("%d / %d NOTES HIT", p, p2)
	end

	notesLabel.TextColor3 = color2

	accuracyLabel.Text = string.format("ACCURACY: %d%%", (math.floor((value or 0) + 0.5)))
end

return LiveStatsHUD