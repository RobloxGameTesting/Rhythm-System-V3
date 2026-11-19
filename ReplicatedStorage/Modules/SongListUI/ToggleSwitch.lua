local TweenService = game:GetService("TweenService")
local StyledTheme = require(script.Parent.StyledTheme)

local ToggleSwitch = {}
ToggleSwitch.__index = ToggleSwitch

function ToggleSwitch.new(parent, options)
	local v = options or {}

	local toggleSwitch = Instance.new("Frame")
	toggleSwitch.Name = "ToggleSwitch"
	toggleSwitch.BackgroundTransparency = 1
	toggleSwitch.AutomaticSize = Enum.AutomaticSize.X
	toggleSwitch.Size = UDim2.new(0, 0, 0, 22)
	toggleSwitch.LayoutOrder = v.layoutOrder or 0
	toggleSwitch.Parent = parent

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.Padding = UDim.new(0, StyledTheme.Spacing.S)
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = toggleSwitch

	if v.prefixLabel then
		local prefixLabel = Instance.new("TextLabel")
		prefixLabel.Name = "PrefixLabel"
		prefixLabel.BackgroundTransparency = 1
		prefixLabel.AutomaticSize = Enum.AutomaticSize.X
		prefixLabel.Size = UDim2.new(0, 0, 1, 0)
		prefixLabel.Font = StyledTheme.Fonts.Medium
		prefixLabel.TextSize = StyledTheme.TextSize.S
		prefixLabel.TextColor3 = StyledTheme.Colors.TextSecondary
		prefixLabel.Text = v.prefixLabel
		prefixLabel.LayoutOrder = 0
		prefixLabel.Parent = toggleSwitch
	end

	local offLabel = Instance.new("TextLabel")
	offLabel.Name = "OffLabel"
	offLabel.BackgroundTransparency = 1
	offLabel.AutomaticSize = Enum.AutomaticSize.X
	offLabel.Size = UDim2.new(0, 0, 1, 0)
	offLabel.Font = StyledTheme.Fonts.Medium
	offLabel.TextSize = StyledTheme.TextSize.S
	offLabel.Text = v.offLabel or ""
	offLabel.LayoutOrder = 1
	offLabel.Visible = v.offLabel ~= nil
	offLabel.Parent = toggleSwitch

	local track = Instance.new("TextButton")
	track.Name = "Track"
	track.Text = ""
	track.AutoButtonColor = false
	track.Size = UDim2.new(0, 44, 0, 22)
	track.BackgroundColor3 = StyledTheme.Colors.Surface
	track.LayoutOrder = 2
	track.Parent = toggleSwitch

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = StyledTheme.Radius.Pill
	uiCorner.Parent = track

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = StyledTheme.Stroke.Thickness
	uiStroke.Color = StyledTheme.Colors.Border
	uiStroke.Transparency = StyledTheme.Stroke.TransparencyDefault
	uiStroke.Parent = track

	local thumb = Instance.new("Frame")
	thumb.Name = "Thumb"
	thumb.Size = UDim2.new(0, 18, 0, 18)
	thumb.Position = UDim2.new(0, 2, 0.5, -9)
	thumb.BackgroundColor3 = StyledTheme.Colors.Accent
	thumb.BorderSizePixel = 0
	thumb.Parent = track

	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = StyledTheme.Radius.Pill
	uiCorner2.Parent = thumb

	local onLabel = Instance.new("TextLabel")
	onLabel.Name = "OnLabel"
	onLabel.BackgroundTransparency = 1
	onLabel.AutomaticSize = Enum.AutomaticSize.X
	onLabel.Size = UDim2.new(0, 0, 1, 0)
	onLabel.Font = StyledTheme.Fonts.Medium
	onLabel.TextSize = StyledTheme.TextSize.S
	onLabel.Text = v.onLabel or ""
	onLabel.LayoutOrder = 3
	onLabel.Visible = v.onLabel ~= nil
	onLabel.Parent = toggleSwitch

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Parent = toggleSwitch

	local object = setmetatable({
		Instance = toggleSwitch,
		Toggled = bindableEvent.Event,
		_toggledEvent = bindableEvent,
		_track = track,
		_thumb = thumb,
		_offLabel = offLabel,
		_onLabel = onLabel,
		_isOn = v.initial or false
	}, ToggleSwitch)

	local function refresh()
		local tweenInfo = TweenInfo.new(
			StyledTheme.Animation.Normal,
			StyledTheme.Animation.EasingStyle,
			StyledTheme.Animation.EasingDirection
		)
		local v2 = object._isOn and 24 or 2

		TweenService:Create(thumb, tweenInfo, { Position = UDim2.new(0, v2, 0.5, -9) }):Play()
		TweenService:Create(track, tweenInfo, {
			BackgroundColor3 = object._isOn and StyledTheme.Colors.SurfaceSelected or StyledTheme.Colors.Surface
		}):Play()

		offLabel.TextColor3 = object._isOn and StyledTheme.Colors.TextDisabled or StyledTheme.Colors.TextPrimary
		onLabel.TextColor3 = object._isOn and StyledTheme.Colors.TextPrimary or StyledTheme.Colors.TextDisabled
	end
	object._refresh = refresh
	refresh()

	track.MouseButton1Click:Connect(function()
		object._isOn = not object._isOn
		refresh()
		bindableEvent:Fire(object._isOn)
	end)

	return object
end

function ToggleSwitch:GetState()
	return self._isOn
end

function ToggleSwitch:SetState(isOn, p)
	if self._isOn == isOn then
		return
	end

	self._isOn = isOn
	self._refresh()

	if not p then
		self._toggledEvent:Fire(isOn)
	end
end

function ToggleSwitch:Destroy()
	self.Instance:Destroy()
end

return ToggleSwitch