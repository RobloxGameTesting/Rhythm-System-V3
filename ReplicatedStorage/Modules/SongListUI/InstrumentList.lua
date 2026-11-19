local StyledTheme = require(script.Parent.StyledTheme)
local PrimaryButton = require(script.Parent.PrimaryButton)
local TextService = game:GetService("TextService")
local StarConfig = require(script.Parent.Parent:WaitForChild("StarConfig"))
local InstrumentIcons = require(script.Parent.InstrumentIcons)

local InstrumentList = {}
InstrumentList.__index = InstrumentList

local defaultOrder = { "GuitarRhythm", "GuitarLead", "Bass", "Drum", "Keyboard", "Piano" }
local defaultNames = {
	GuitarRhythm = "Rhythm Guitar",
	GuitarLead = "Lead Guitar",
	Bass = "Bass",
	Drum = "Drum",
	Keyboard = "Keyboard",
	Piano = "Piano"
}

InstrumentList.DefaultOrder = defaultOrder
InstrumentList.DefaultNames = defaultNames

local v = math.ceil(TextService:GetTextSize(
	StarConfig.PlainText(),
	StyledTheme.TextSize.S,
	StyledTheme.Fonts.Regular,
	Vector2.new(1000, 40)
).X) + 4

local v2 = { invited = "Invited...", loading = "Loading...", joined = "Joined", ready = "Ready ✓" }

local SurfaceHover = StyledTheme.Colors.SurfaceHover
local TextSecondary = StyledTheme.Colors.TextSecondary

local color = Color3.fromRGB(20, 20, 22)

local color2 = Color3.fromRGB(240, 140, 50)

local color3 = Color3.fromRGB(90, 160, 230)

local function renderRow(row)
	local label = row.label

	local v3 = row.baseName

	if row.partPercent then
		v3 = string.format("%s (max %d%% score)", row.baseName, row.partPercent)
	end

	label.AutoLocalize = row.occupant == nil and row.rawOccupant == nil and row.partPercent == nil
	row.starLabel.AutoLocalize = false

	if row.occupant then
		label.TextColor3 = StyledTheme.Colors.Success

		if row.percent and row.percent < 100 then
			label.Text = string.format("%s %s — @%s (%d%%)", StyledTheme.Icons.Check, v3, row.occupant, row.percent)
		else
			label.Text = string.format("%s %s — @%s", StyledTheme.Icons.Check, v3, row.occupant)
		end
	elseif row.rawOccupant then
		label.TextColor3 = StyledTheme.Colors.TextPrimary
		label.Text = string.format("%s %s — @%s", StyledTheme.Icons.Check, v3, row.rawOccupant)
	elseif row.available then
		label.TextColor3 = StyledTheme.Colors.TextPrimary
		label.Text = StyledTheme.Icons.Check .. " " .. v3
	else
		label.TextColor3 = StyledTheme.Colors.TextDisabled
		label.Text = StyledTheme.Icons.Dash .. " " .. v3
	end

	row.rowFrame.Visible = row.available

	local button = row.button

	local v4 = row.available

	if v4 then
		if row.rawOccupant == nil then
			v4 = false
		else
			v4 = not (row.isMine or row.isHost)
		end
	end

	if row.partyStatus then
		button:SetText(v2[row.partyStatus] or "+invite")

		if row.partyStatus == "ready" then
			button.Instance.BackgroundColor3 = StyledTheme.Colors.Success
			button.Instance.TextColor3 = color
		elseif row.partyStatus == "joined" then
			button.Instance.BackgroundColor3 = color2
			button.Instance.TextColor3 = color
		elseif row.partyStatus == "loading" then
			button.Instance.BackgroundColor3 = color3
			button.Instance.TextColor3 = color
		else
			button.Instance.BackgroundColor3 = SurfaceHover
			button.Instance.TextColor3 = TextSecondary
		end

		button:SetDisabled(true)
	elseif row.isHost and not row.isMine then
		button:SetText("Host")
		button.Instance.BackgroundColor3 = SurfaceHover
		button.Instance.TextColor3 = TextSecondary
		button:SetDisabled(true)
	elseif v4 then
		button:SetText("+invite")
		button.Instance.BackgroundColor3 = StyledTheme.Colors.Accent
		button.Instance.TextColor3 = StyledTheme.Colors.AccentText
		button:SetDisabled(false)
	else
		button:SetText("+invite")
		button.Instance.BackgroundColor3 = SurfaceHover
		button.Instance.TextColor3 = TextSecondary
		button:SetDisabled(true)
	end

	local actionKind = row.hostControls and row.partyStatus and (row.partyStatus == "invited" and "cancel" or "kick")
		or nil

	row.actionKind = actionKind

	local actionButton = row.actionButton

	if actionKind == "cancel" then
		actionButton:SetText("Cancel")
		actionButton.Instance.BackgroundColor3 = SurfaceHover
		actionButton.Instance.TextColor3 = StyledTheme.Colors.TextPrimary
		actionButton:SetDisabled(false)
	elseif actionKind == "kick" then
		actionButton:SetText("Kick")
		actionButton.Instance.BackgroundColor3 = StyledTheme.Colors.Danger
		actionButton.Instance.TextColor3 = color
		actionButton:SetDisabled(false)
	end

	actionButton.Instance.Visible = actionKind ~= nil
	local v5 = actionKind and 152 or 90
	row.starLabel.Position = UDim2.new(1, -v5, 0, 0)
	row.starLabel.Text = StarConfig.RichText(
		row.stars or 0,
		StyledTheme.Colors.Accent:ToHex(),
		StyledTheme.Colors.TextSecondary:ToHex()
	)
	row.label.Size = UDim2.new(1, -(v5 + v + 6 + (row.iconOffset or 0)), 1, 0)
end

function InstrumentList.new(parent, options)
	local v3 = options or {}
	local order = v3.order or defaultOrder
	local displayNames = v3.displayNames or defaultNames

	local instrumentList = Instance.new("Frame")
	instrumentList.Name = "InstrumentList"
	instrumentList.BackgroundTransparency = 1
	instrumentList.AutomaticSize = Enum.AutomaticSize.Y
	instrumentList.Size = v3.size or UDim2.new(1, 0, 0, 0)
	instrumentList.LayoutOrder = v3.layoutOrder or 0
	instrumentList.Parent = parent

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Vertical
	uiListLayout.Padding = UDim.new(0, StyledTheme.Spacing.XS)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = instrumentList

	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")
	local bindableEvent3 = Instance.new("BindableEvent")
	local rows = {}

	for i, name in ipairs(order) do
		local frame = Instance.new("Frame")
		frame.Name = name
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.new(1, 0, 0, StyledTheme.Sizes.ControlHeightS)
		frame.LayoutOrder = i
		frame.Parent = instrumentList

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(1, -90, 1, 0)
		label.Font = StyledTheme.Fonts.Regular
		label.TextSize = StyledTheme.TextSize.M
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextWrapped = true
		label.TextColor3 = StyledTheme.Colors.TextDisabled
		label.Text = StyledTheme.Icons.Dash .. " " .. (displayNames[name] or name)
		label.Parent = frame

		local image = InstrumentIcons.Get(name)
		local icon, iconOffset

		if image then
			icon = Instance.new("ImageLabel")
			icon.Name = "Icon"
			icon.BackgroundTransparency = 1
			icon.BorderSizePixel = 0
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.Position = UDim2.new(0, 10, 0.5, 0)
			local size = InstrumentIcons.GetSize(name, 20)
			icon.Size = UDim2.fromOffset(size.X, size.Y)
			icon.ScaleType = Enum.ScaleType.Crop
			icon.Image = image
			icon.Parent = frame

			iconOffset = 26
			label.Position = UDim2.new(0, iconOffset, 0, 0)
		else
			iconOffset = 0
		end

		local stars = Instance.new("TextLabel")
		stars.Name = "Stars"
		stars.BackgroundTransparency = 1
		stars.AnchorPoint = Vector2.new(1, 0)
		stars.Position = UDim2.new(1, -90, 0, 0)
		stars.Size = UDim2.new(0, v, 1, 0)
		stars.Font = StyledTheme.Fonts.Regular
		stars.TextSize = StyledTheme.TextSize.S
		stars.RichText = true
		stars.TextWrapped = false
		stars.TextXAlignment = Enum.TextXAlignment.Right
		stars.Parent = frame

		local button = PrimaryButton.new(frame, { text = "+invite", size = UDim2.new(0, 84, 1, 0) })

		button.Instance.Position = UDim2.new(1, -84, 0, 0)
		button.Instance.TextSize = StyledTheme.TextSize.S
		button:SetDisabled(true)

		button.Clicked:Connect(function()
			bindableEvent:Fire(name)
		end)

		local actionButton = PrimaryButton.new(frame, {
			text = "Kick",
			size = UDim2.new(0, 58, 1, 0)
		})

		actionButton.Instance.Name = "ActionButton"
		actionButton.Instance.Position = UDim2.new(1, -146, 0, 0)
		actionButton.Instance.TextSize = StyledTheme.TextSize.S
		actionButton.Instance.Visible = false
		actionButton.Clicked:Connect(function()
			local v4 = rows[name]

			if v4.actionKind == "cancel" then
				bindableEvent2:Fire(name)
			elseif v4.actionKind == "kick" then
				bindableEvent3:Fire(name)
			end
		end)

		rows[name] = {
			rowFrame = frame,
			label = label,
			starLabel = stars,
			stars = nil,
			button = button,
			actionButton = actionButton,
			actionKind = nil,
			hostControls = false,
			baseName = displayNames[name] or name,
			iconOffset = iconOffset,
			iconLabel = icon,
			available = false,
			occupant = nil,
			percent = nil,
			isMine = false,
			isHost = false,
			rawOccupant = nil,
			partyStatus = nil,
			partPercent = nil
		}
	end

	return (setmetatable({
		Instance = instrumentList,
		rows = rows,
		InviteClicked = bindableEvent.Event,
		CancelClicked = bindableEvent2.Event,
		KickClicked = bindableEvent3.Event,
		_inviteClickedEvent = bindableEvent,
		_cancelClickedEvent = bindableEvent2,
		_kickClickedEvent = bindableEvent3
	}, InstrumentList))
end

function InstrumentList.SetAvailable(p, p2, available)
	local row = p.rows[p2]

	if not row then
		return
	end

	row.available = available
	renderRow(row)
end

function InstrumentList.SetOccupant(p, p2, occupant, percent)
	local row = p.rows[p2]

	if not row then
		return
	end

	row.occupant = occupant
	row.percent = percent
	renderRow(row)
end

function InstrumentList.SetIsMine(p, p2, isMine)
	local row = p.rows[p2]

	if not row then
		return
	end

	row.isMine = isMine
	renderRow(row)
end

function InstrumentList.SetIsHost(p, p2, isHost)
	local row = p.rows[p2]

	if not row then
		return
	end

	row.isHost = isHost
	renderRow(row)
end

function InstrumentList.SetRawOccupant(p, p2, rawOccupant)
	local row = p.rows[p2]

	if not row then
		return
	end

	row.rawOccupant = rawOccupant
	renderRow(row)
end

function InstrumentList.SetPartyStatus(p, p2, partyStatus)
	local row = p.rows[p2]

	if not row then
		return
	end

	row.partyStatus = partyStatus
	renderRow(row)
end

function InstrumentList.SetHostControls(p, p2)
	for _, row in pairs(p.rows) do
		row.hostControls = p2 == true
		renderRow(row)
	end
end

function InstrumentList.SetPartPercent(p, p2, value)
	local row = p.rows[p2]

	if not row then
		return
	end

	local partPercent

	if type(value) == "number" and value < 100 then
		partPercent = math.floor(value) or nil
	end

	row.partPercent = partPercent
	renderRow(row)
end

function InstrumentList.SetStates(p, p2)
	for k, row in pairs(p.rows) do
		if row.iconLabel then
			row.iconLabel.ImageColor3 = InstrumentIcons.GetStateColor(p2 and p2[k])
		end
	end
end

function InstrumentList.SetStars(p, p2, value)
	local row = p.rows[p2]

	if not row then
		return
	end

	if type(value) == "number" then
		row.stars = math.clamp(math.floor(value), 0, StarConfig.MaxStars)
	else
		row.stars = nil
	end

	renderRow(row)
end

function InstrumentList.IsFull(p)
	local v3 = false

	for _, row in pairs(p.rows) do
		if not row.available then
			continue
		end

		if row.occupant or row.rawOccupant or row.isMine then
			v3 = true
		else
			return false
		end
	end

	return v3
end

function InstrumentList.Reset(p)
	for _, row in pairs(p.rows) do
		row.available = false
		row.occupant = nil
		row.percent = nil
		row.partPercent = nil
		row.stars = nil

		renderRow(row)
	end
end

function InstrumentList:Destroy()
	self._inviteClickedEvent:Destroy()
	self._cancelClickedEvent:Destroy()
	self._kickClickedEvent:Destroy()

	for _, row in pairs(self.rows) do
		row.button:Destroy()
		row.actionButton:Destroy()
	end

	self.Instance:Destroy()
end

return InstrumentList