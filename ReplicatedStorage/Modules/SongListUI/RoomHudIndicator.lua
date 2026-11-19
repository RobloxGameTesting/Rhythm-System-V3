local StyledTheme = require(script.Parent.StyledTheme)

local RoomHudIndicator = {}
RoomHudIndicator.__index = RoomHudIndicator

function RoomHudIndicator.new(parent)
	local roomHudIndicator = Instance.new("TextLabel")
	roomHudIndicator.Name = "RoomHudIndicator"
	roomHudIndicator.AnchorPoint = Vector2.new(0, 1)
	roomHudIndicator.Position = UDim2.new(
		0,
		StyledTheme.Spacing.XL,
		1,
		-(StyledTheme.Spacing.XL + StyledTheme.Sizes.ControlHeightL + StyledTheme.Spacing.S)
	)
	roomHudIndicator.AutomaticSize = Enum.AutomaticSize.XY
	roomHudIndicator.Size = UDim2.new(0, 0, 0, 0)
	roomHudIndicator.BackgroundColor3 = StyledTheme.Colors.Surface
	roomHudIndicator.BackgroundTransparency = 0.25
	roomHudIndicator.Font = StyledTheme.Fonts.Regular
	roomHudIndicator.TextSize = StyledTheme.TextSize.XS
	roomHudIndicator.TextColor3 = StyledTheme.Colors.TextSecondary
	roomHudIndicator.Text = ""
	roomHudIndicator.Visible = false
	roomHudIndicator.ZIndex = StyledTheme.ZIndex.Overlay
	roomHudIndicator.Parent = parent
	local BottomLeftStack = require(script.Parent.Parent.BottomLeftStack)
	BottomLeftStack.Register(roomHudIndicator, 3)

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, StyledTheme.Spacing.S)
	uiPadding.PaddingRight = UDim.new(0, StyledTheme.Spacing.S)
	uiPadding.PaddingTop = UDim.new(0, StyledTheme.Spacing.XS)
	uiPadding.PaddingBottom = UDim.new(0, StyledTheme.Spacing.XS)
	uiPadding.Parent = roomHudIndicator

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = StyledTheme.Radius.Small
	uiCorner.Parent = roomHudIndicator

	return (setmetatable({ Instance = roomHudIndicator }, RoomHudIndicator))
end

function RoomHudIndicator.SetAdminName(p, p2)
	if p2 and p2 ~= "" then
		p.Instance.Text = string.format("in \"%s\"'s room", p2)
		p.Instance.Visible = true
	else
		p.Instance.Text = ""
		p.Instance.Visible = false
	end
end

function RoomHudIndicator:Destroy()
	self.Instance:Destroy()
end

return RoomHudIndicator