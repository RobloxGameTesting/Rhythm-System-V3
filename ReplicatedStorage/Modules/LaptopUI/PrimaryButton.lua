local TweenService = game:GetService("TweenService")
local Retro = require(script.Parent.Retro)
local Theme = require(script.Parent.Theme)

local PrimaryButton = {}
PrimaryButton.__index = PrimaryButton

function PrimaryButton.new(parent, options)
	local v = options or {}

	local primaryButton = Instance.new("TextButton")
	primaryButton.Name = "PrimaryButton"
	primaryButton.BackgroundColor3 = Theme.Colors.Accent
	primaryButton.Size = v.size or UDim2.new(1, 0, 0, Theme.Sizes.ControlHeightL)
	primaryButton.LayoutOrder = v.layoutOrder or 0
	primaryButton.AutoButtonColor = false
	primaryButton.Font = Theme.Fonts.Display
	primaryButton.TextSize = Theme.TextSize.XL
	primaryButton.TextColor3 = Theme.Colors.AccentText
	primaryButton.Text = (v.icon and v.icon .. "  " or "") .. (v.text or "")
	primaryButton.Parent = parent

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = Theme.Radius.Medium
	uiCorner.Parent = primaryButton

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1
	uiStroke.Color = Color3.fromRGB(128, 84, 18)
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = primaryButton
	Retro.AddGloss(primaryButton)

	local uiScale = Instance.new("UIScale")
	uiScale.Parent = primaryButton

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Parent = primaryButton

	local hoverState = { isHovering = false }

	local function refresh()
		TweenService:Create(
			primaryButton,
			TweenInfo.new(Theme.Animation.Fast, Theme.Animation.EasingStyle, Theme.Animation.EasingDirection),
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

		uiScale.Scale = Theme.Animation.PressScale
		TweenService:Create(
			uiScale,
			TweenInfo.new(Theme.Animation.Normal, Theme.Animation.BounceStyle, Theme.Animation.BounceDirection),
			{ Scale = 1 }
		):Play()

		primaryButton.BackgroundColor3 = Theme.Colors.TextPrimary
		TweenService:Create(primaryButton, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Theme.Colors.Accent
		}):Play()
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