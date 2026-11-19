local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StyledTheme = require(ReplicatedStorage.Modules.SongListUI.StyledTheme)

local v = nil

local function build()
	local chartUnavailableNotice = Instance.new("ScreenGui")
	chartUnavailableNotice.Name = "ChartUnavailableNotice"
	chartUnavailableNotice.ResetOnSpawn = false
	chartUnavailableNotice.IgnoreGuiInset = true
	chartUnavailableNotice.DisplayOrder = 50
	chartUnavailableNotice.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local pill = Instance.new("Frame")
	pill.Name = "Pill"
	pill.AnchorPoint = Vector2.new(0.5, 0.5)
	pill.Position = UDim2.fromScale(0.5, 0.42)
	pill.AutomaticSize = Enum.AutomaticSize.XY
	pill.Size = UDim2.fromOffset(0, 0)
	pill.BackgroundColor3 = StyledTheme.Colors.Surface
	pill.BackgroundTransparency = 0.15
	pill.BorderSizePixel = 0
	pill.Active = false
	pill.Parent = chartUnavailableNotice

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 10)
	uiCorner.Parent = pill

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1.5
	uiStroke.Color = StyledTheme.Colors.Danger
	uiStroke.Parent = pill

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 12)
	uiPadding.PaddingBottom = UDim.new(0, 12)
	uiPadding.PaddingLeft = UDim.new(0, 20)
	uiPadding.PaddingRight = UDim.new(0, 20)
	uiPadding.Parent = pill

	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MaxSize = Vector2.new(560, 1e999)
	uiSizeConstraint.Parent = pill

	local message = Instance.new("TextLabel")
	message.Name = "Message"
	message.BackgroundTransparency = 1
	message.AutomaticSize = Enum.AutomaticSize.Y
	message.Size = UDim2.new(0, 520, 0, 0)
	message.Font = StyledTheme.Fonts.Regular
	message.TextSize = 20
	message.TextColor3 = StyledTheme.Colors.TextPrimary or Color3.new(1, 1, 1)
	message.TextWrapped = true
	message.Text = "Sorry, the chartdata is not yet available;( please check back later."
	message.Active = false
	message.Parent = pill

	return chartUnavailableNotice
end

local ChartUnavailableNotice = {}

function ChartUnavailableNotice.Show()
	if v and v.Parent then
		v.Enabled = true
		return
	end

	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	v = build()
	v.Parent = playerGui
end

function ChartUnavailableNotice.Hide()
	if v then
		v.Enabled = false
	end
end

return ChartUnavailableNotice