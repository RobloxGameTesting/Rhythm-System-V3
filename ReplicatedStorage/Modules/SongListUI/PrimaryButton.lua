local TweenService = game:GetService("TweenService")
local StyledTheme = require(script.Parent.StyledTheme)

local PrimaryButton = {}
PrimaryButton.__index = PrimaryButton

function PrimaryButton.new(parent, options)
	local v = options or {}

	local primaryButton = Instance.new("TextButton")
	primaryButton.Name = "PrimaryButton"
	primaryButton.BackgroundColor3 = StyledTheme.Colors.Accent
	primaryButton.Size = v.size or UDim2.new(1, 0, 0, StyledTheme.Sizes.ControlHeightL)
	primaryButton.LayoutOrder = v.layoutOrder or 0
	primaryButton.AutoButtonColor = false
	primaryButton.Font = StyledTheme.Fonts.Bold
	primaryButton.TextSize = StyledTheme.TextSize.L
	primaryButton.TextColor3 = StyledTheme.Colors.AccentText
	primaryButton.Text = (v.icon and v.icon .. "  " or "") .. (v.text or "")
	primaryButton.Parent = parent

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = StyledTheme.Radius.Medium
	uiCorner.Parent = primaryButton

	local uiScale = Instance.new("UIScale")
	uiScale.Parent = primaryButton

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Parent = primaryButton

	local _accent = StyledTheme.Colors.Accent
	local _accent2 = StyledTheme.Colors.Accent
	local hoverState = { isHovering = false }

	local function refresh()
		TweenService:Create(
			primaryButton,
			TweenInfo.new(
				StyledTheme.Animation.Fast,
				StyledTheme.Animation.EasingStyle,
				StyledTheme.Animation.EasingDirection
			),
			{
				BackgroundTransparency = primaryButton.Active and (hoverState.isHovering and 0.1 or 0) or 0.5
			}
		):Play()
	end

	primaryButton.MouseEnter:Connect(function()
		if not primaryButton.Active then
			return
		end

		hoverState.isHovering = true
		refresh()
	end)
	primaryButton.MouseLeave:Connect(function()
		if not primaryButton.Active then
			return
		end

		hoverState.isHovering = false
		refresh()
	end)

	primaryButton.Activated:Connect(function()
		if not primaryButton.Active then
			return
		end

		uiScale.Scale = StyledTheme.Animation.PressScale
		TweenService:Create(
			uiScale,
			TweenInfo.new(
				StyledTheme.Animation.Normal,
				StyledTheme.Animation.BounceStyle,
				StyledTheme.Animation.BounceDirection
			),
			{ Scale = 1 }
		):Play()
		bindableEvent:Fire()
	end)

	return (setmetatable({
		Instance = primaryButton,
		Clicked = bindableEvent.Event,
		_icon = v.icon,
		_hoverState = hoverState,
		_refresh = refresh
	}, PrimaryButton))
end

function PrimaryButton:SetText(p)
	self.Instance.Text = (self._icon and self._icon .. "  " or "") .. p
end

function PrimaryButton:SetDisabled(p)
	self.Instance.Active = not p
	self._hoverState.isHovering = false
	self._refresh()
end

function PrimaryButton:Destroy()
	self.Instance:Destroy()
end

return PrimaryButton