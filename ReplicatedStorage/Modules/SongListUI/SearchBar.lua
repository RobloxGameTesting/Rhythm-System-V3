local TweenService = game:GetService("TweenService")
local StyledTheme = require(script.Parent.StyledTheme)

local SearchBar = {}
SearchBar.__index = SearchBar

function SearchBar.new(parent, options)
	local v = options or {}

	local iconButtonSize = StyledTheme.Sizes.IconButtonSize
	local s = StyledTheme.Spacing.S
	local m = StyledTheme.Spacing.M

	local searchBar = Instance.new("Frame")
	searchBar.Name = "SearchBar"
	searchBar.BackgroundColor3 = StyledTheme.Colors.Surface
	searchBar.Size = v.size or UDim2.new(1, 0, 0, StyledTheme.Sizes.ControlHeightL)
	searchBar.LayoutOrder = v.layoutOrder or 0
	searchBar.Parent = parent

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = StyledTheme.Radius.Medium
	uiCorner.Parent = searchBar

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = StyledTheme.Stroke.Thickness
	uiStroke.Color = StyledTheme.Colors.Border
	uiStroke.Transparency = StyledTheme.Stroke.TransparencyDefault
	uiStroke.Parent = searchBar

	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.BackgroundTransparency = 1
	icon.Size = UDim2.new(0, iconButtonSize, 1, 0)
	icon.Position = UDim2.new(0, m, 0, 0)
	icon.Font = StyledTheme.Fonts.Bold
	icon.TextSize = StyledTheme.TextSize.XL
	icon.TextColor3 = StyledTheme.Colors.TextSecondary
	icon.Text = StyledTheme.Icons.Search
	icon.Parent = searchBar

	local input = Instance.new("TextBox")
	input.Name = "Input"
	input.BackgroundTransparency = 1
	input.Position = UDim2.new(0, m + iconButtonSize, 0, 0)
	input.Size = UDim2.new(1, -(m + iconButtonSize + iconButtonSize + s), 1, 0)
	input.Font = StyledTheme.Fonts.Regular
	input.TextSize = StyledTheme.TextSize.L
	input.TextColor3 = StyledTheme.Colors.TextPrimary
	input.PlaceholderText = v.placeholder or "Search..."
	input.PlaceholderColor3 = StyledTheme.Colors.TextSecondary
	input.Text = ""
	input.ClearTextOnFocus = false
	input.TextXAlignment = Enum.TextXAlignment.Left
	input.Parent = searchBar

	local clear = Instance.new("TextButton")
	clear.Name = "Clear"
	clear.BackgroundTransparency = 1
	clear.Size = UDim2.new(0, iconButtonSize, 0, iconButtonSize)
	clear.Position = UDim2.new(1, -(iconButtonSize + s), 0.5, -(iconButtonSize / 2))
	clear.Text = ""
	clear.Visible = false
	clear.Parent = searchBar

	local v2 = iconButtonSize * 0.4
	local bar1 = Instance.new("Frame")
	bar1.Name = "Bar1"
	bar1.AnchorPoint = Vector2.new(0.5, 0.5)
	bar1.Position = UDim2.new(0.5, 0, 0.5, 0)
	bar1.Size = UDim2.new(0, v2, 0, 2)
	bar1.Rotation = 45
	bar1.BackgroundColor3 = StyledTheme.Colors.TextSecondary
	bar1.BorderSizePixel = 0
	bar1.Parent = clear

	local bar2 = bar1:Clone()
	bar2.Name = "Bar2"
	bar2.Rotation = -45
	bar2.Parent = clear

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Parent = searchBar

	local function updateClearVisibility() -- 1 equivalent call inferred from this helper
		clear.Visible = input.Text ~= ""
	end

	input:GetPropertyChangedSignal("Text"):Connect(function()
		updateClearVisibility() -- inferred equivalent call
		bindableEvent:Fire(input.Text)
	end)

	clear.MouseButton1Click:Connect(function()
		input.Text = ""
		input:ReleaseFocus()
	end)

	input.Focused:Connect(function()
		TweenService:Create(
			uiStroke,
			TweenInfo.new(
				StyledTheme.Animation.Normal,
				StyledTheme.Animation.EasingStyle,
				StyledTheme.Animation.EasingDirection
			),
			{
				Color = StyledTheme.Colors.Accent,
				Transparency = StyledTheme.Stroke.TransparencyActive
			}
		):Play()
	end)

	input.FocusLost:Connect(function()
		TweenService:Create(
			uiStroke,
			TweenInfo.new(
				StyledTheme.Animation.Normal,
				StyledTheme.Animation.EasingStyle,
				StyledTheme.Animation.EasingDirection
			),
			{
				Color = StyledTheme.Colors.Border,
				Transparency = StyledTheme.Stroke.TransparencyDefault
			}
		):Play()
	end)

	return (setmetatable({ Instance = searchBar, Changed = bindableEvent.Event, _input = input }, SearchBar))
end

function SearchBar:GetText()
	return self._input.Text
end

function SearchBar:SetText(text)
	self._input.Text = text
end

function SearchBar:Destroy()
	self.Instance:Destroy()
end

return SearchBar