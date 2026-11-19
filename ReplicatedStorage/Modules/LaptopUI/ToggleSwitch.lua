local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Theme)

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
	uiListLayout.Padding = UDim.new(0, Theme.Spacing.S)
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = toggleSwitch

	local offLabel = Instance.new("TextLabel")
	offLabel.Name = "OffLabel"
	offLabel.BackgroundTransparency = 1
	offLabel.AutomaticSize = Enum.AutomaticSize.X
	offLabel.Size = UDim2.new(0, 0, 1, 0)
	offLabel.Font = Theme.Fonts.Medium
	offLabel.TextSize = Theme.TextSize.S
	offLabel.Text = v.offLabel or ""
	offLabel.LayoutOrder = 1
	offLabel.Visible = v.offLabel ~= nil
	offLabel.Parent = toggleSwitch

	local track = Instance.new("TextButton")
	track.Name = "Track"
	track.Text = ""
	track.AutoButtonColor = false
	track.Size = UDim2.new(0, 44, 0, 22)
	track.BackgroundColor3 = Theme.Colors.Surface
	track.LayoutOrder = 2
	track.Parent = toggleSwitch

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = Theme.Radius.Small
	uiCorner.Parent = track

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = Theme.Stroke.Thickness
	uiStroke.Color = Theme.Colors.Border
	uiStroke.Transparency = Theme.Stroke.TransparencyDefault
	uiStroke.Parent = track

	local thumb = Instance.new("Frame")
	thumb.Name = "Thumb"
	thumb.Size = UDim2.new(0, 18, 0, 18)
	thumb.Position = UDim2.new(0, 2, 0.5, -9)
	thumb.BackgroundColor3 = Theme.Colors.Accent
	thumb.BorderSizePixel = 0
	thumb.Parent = track

	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = Theme.Radius.Small
	uiCorner2.Parent = thumb

	local onLabel = Instance.new("TextLabel")
	onLabel.Name = "OnLabel"
	onLabel.BackgroundTransparency = 1
	onLabel.AutomaticSize = Enum.AutomaticSize.X
	onLabel.Size = UDim2.new(0, 0, 1, 0)
	onLabel.Font = Theme.Fonts.Medium
	onLabel.TextSize = Theme.TextSize.S
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
			Theme.Animation.Normal,
			Theme.Animation.EasingStyle,
			Theme.Animation.EasingDirection
		)
		local v2 = object._isOn and 24 or 2

		TweenService:Create(thumb, tweenInfo, { Position = UDim2.new(0, v2, 0.5, -9) }):Play()
		TweenService:Create(track, tweenInfo, {
			BackgroundColor3 = object._isOn and Theme.Colors.SurfaceSelected or Theme.Colors.Surface
		}):Play()

		offLabel.TextColor3 = object._isOn and Theme.Colors.TextDisabled or Theme.Colors.TextPrimary
		onLabel.TextColor3 = object._isOn and Theme.Colors.TextPrimary or Theme.Colors.TextDisabled
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