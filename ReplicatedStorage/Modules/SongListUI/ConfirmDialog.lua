local StyledTheme = require(script.Parent.StyledTheme)

local ConfirmDialog = {}
ConfirmDialog.__index = ConfirmDialog

function ConfirmDialog.new(parent, options)
	local v = options or {}

	local confirmDialogOverlay = Instance.new("Frame")
	confirmDialogOverlay.Name = "ConfirmDialogOverlay"
	confirmDialogOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
	confirmDialogOverlay.BackgroundTransparency = 0.45
	confirmDialogOverlay.Size = UDim2.new(1, 0, 1, 0)
	confirmDialogOverlay.ZIndex = StyledTheme.ZIndex.Modal
	confirmDialogOverlay.Visible = false
	confirmDialogOverlay.Parent = parent

	local card = Instance.new("Frame")
	card.Name = "Card"
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.new(0.5, 0, 0.5, 0)
	card.Size = UDim2.new(0, 340, 0, 0)
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.BackgroundColor3 = StyledTheme.Colors.Surface
	card.ZIndex = StyledTheme.ZIndex.Modal + 1
	card.Parent = confirmDialogOverlay

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = StyledTheme.Radius.Large
	uiCorner.Parent = card

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = StyledTheme.Stroke.Thickness
	uiStroke.Color = StyledTheme.Colors.Border
	uiStroke.Transparency = StyledTheme.Stroke.TransparencyDefault
	uiStroke.Parent = card

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, StyledTheme.Spacing.XL)
	uiPadding.PaddingRight = UDim.new(0, StyledTheme.Spacing.XL)
	uiPadding.PaddingTop = UDim.new(0, StyledTheme.Spacing.XL)
	uiPadding.PaddingBottom = UDim.new(0, StyledTheme.Spacing.XL)
	uiPadding.Parent = card

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Vertical
	uiListLayout.Padding = UDim.new(0, StyledTheme.Spacing.L)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = card

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0, StyledTheme.TextSize.XXL + StyledTheme.Spacing.XS)
	title.Font = StyledTheme.Fonts.Bold
	title.TextSize = StyledTheme.TextSize.XXL
	title.TextColor3 = StyledTheme.Colors.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = v.title or ""
	title.LayoutOrder = 1
	title.ZIndex = StyledTheme.ZIndex.Modal + 2
	title.Parent = card

	local message = Instance.new("TextLabel")
	message.Name = "Message"
	message.BackgroundTransparency = 1
	message.AutomaticSize = Enum.AutomaticSize.Y
	message.Size = UDim2.new(1, 0, 0, 0)
	message.Font = StyledTheme.Fonts.Regular
	message.TextSize = StyledTheme.TextSize.L
	message.TextColor3 = StyledTheme.Colors.TextSecondary
	message.TextXAlignment = Enum.TextXAlignment.Left
	message.TextWrapped = true
	message.Text = v.message or ""
	message.LayoutOrder = 2
	message.ZIndex = StyledTheme.ZIndex.Modal + 2
	message.Parent = card

	local buttons = Instance.new("Frame")
	buttons.Name = "Buttons"
	buttons.BackgroundTransparency = 1
	buttons.Size = UDim2.new(1, 0, 0, StyledTheme.Sizes.ControlHeightL)
	buttons.LayoutOrder = 3
	buttons.ZIndex = StyledTheme.ZIndex.Modal + 2
	buttons.Parent = card

	local uiListLayout2 = Instance.new("UIListLayout")
	uiListLayout2.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout2.Padding = UDim.new(0, StyledTheme.Spacing.M)
	uiListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Right
	uiListLayout2.Parent = buttons

	local cancelButton = Instance.new("TextButton")
	cancelButton.Name = "CancelButton"
	cancelButton.BackgroundColor3 = StyledTheme.Colors.Surface
	cancelButton.Size = UDim2.new(0, 110, 1, 0)
	cancelButton.AutoButtonColor = false
	cancelButton.Font = StyledTheme.Fonts.Medium
	cancelButton.TextSize = StyledTheme.TextSize.L
	cancelButton.TextColor3 = StyledTheme.Colors.TextSecondary
	cancelButton.Text = v.cancelText or "Cancel"
	cancelButton.LayoutOrder = 1
	cancelButton.ZIndex = StyledTheme.ZIndex.Modal + 3
	cancelButton.Parent = buttons

	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = StyledTheme.Radius.Medium
	uiCorner2.Parent = cancelButton

	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.Thickness = StyledTheme.Stroke.Thickness
	uiStroke2.Color = StyledTheme.Colors.Border
	uiStroke2.Transparency = StyledTheme.Stroke.TransparencyDefault
	uiStroke2.Parent = cancelButton

	local confirmButton = Instance.new("TextButton")
	confirmButton.Name = "ConfirmButton"
	confirmButton.BackgroundColor3 = StyledTheme.Colors.Accent
	confirmButton.Size = UDim2.new(0, 110, 1, 0)
	confirmButton.AutoButtonColor = false
	confirmButton.Font = StyledTheme.Fonts.Bold
	confirmButton.TextSize = StyledTheme.TextSize.L
	confirmButton.TextColor3 = StyledTheme.Colors.AccentText
	confirmButton.Text = v.confirmText or "Confirm"
	confirmButton.LayoutOrder = 2
	confirmButton.ZIndex = StyledTheme.ZIndex.Modal + 3
	confirmButton.Parent = buttons

	local uiCorner3 = Instance.new("UICorner")
	uiCorner3.CornerRadius = StyledTheme.Radius.Medium
	uiCorner3.Parent = confirmButton

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Parent = confirmDialogOverlay
	local bindableEvent2 = Instance.new("BindableEvent")
	bindableEvent2.Parent = confirmDialogOverlay

	local object = setmetatable({
		Instance = confirmDialogOverlay,
		Confirmed = bindableEvent.Event,
		Cancelled = bindableEvent2.Event,
		_titleLabel = title,
		_messageLabel = message
	}, ConfirmDialog)

	confirmButton.MouseButton1Click:Connect(function()
		object:Hide()
		bindableEvent:Fire()
	end)

	cancelButton.MouseButton1Click:Connect(function()
		object:Hide()
		bindableEvent2:Fire()
	end)

	return object
end

function ConfirmDialog:Show(text, text2)
	if text then
		self._titleLabel.Text = text
	end

	if text2 then
		self._messageLabel.Text = text2
	end

	self.Instance.Visible = true

	task.defer(function()
		self.Instance.Visible = false
		self.Instance.Visible = true
	end)
end

function ConfirmDialog:Hide()
	self.Instance.Visible = false
end

function ConfirmDialog:Destroy()
	self.Instance:Destroy()
end

return ConfirmDialog