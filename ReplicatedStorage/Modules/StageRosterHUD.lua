local Players = game:GetService("Players")

local DifficultyBadge = require(script.Parent.SongListUI.DifficultyBadge)

local InstrumentIcons = require(script.Parent.SongListUI.InstrumentIcons)

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local color = Color3.fromRGB(18, 18, 20)
local color2 = Color3.fromRGB(180, 180, 185)
local color3 = Color3.fromRGB(190, 150, 80)

local color4 = Color3.fromRGB(88, 210, 150)
local color5 = Color3.fromRGB(235, 90, 90)

local stageRosterHUD = Instance.new("ScreenGui")
stageRosterHUD.Name = "StageRosterHUD"
stageRosterHUD.ResetOnSpawn = false
stageRosterHUD.Enabled = false
stageRosterHUD.Parent = PlayerGui

local container = Instance.new("Frame")
container.Name = "Container"
container.AnchorPoint = Vector2.new(0, 1)
container.Position = UDim2.new(0, 16, 1, -16)

container.Size = UDim2.new(0, 0, 0, 0)
container.AutomaticSize = Enum.AutomaticSize.XY
container.BackgroundColor3 = color
container.BackgroundTransparency = 0.45
container.ClipsDescendants = true
container.Parent = stageRosterHUD
local BottomLeftStack = require(script.Parent.BottomLeftStack)
BottomLeftStack.Register(container, 2)

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = container

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingLeft = UDim.new(0, 8)
uiPadding.PaddingRight = UDim.new(0, 8)
uiPadding.PaddingTop = UDim.new(0, 4)
uiPadding.PaddingBottom = UDim.new(0, 4)
uiPadding.Parent = container

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Vertical
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 1)
uiListLayout.Parent = container

local v = {}
local v2 = {}
local StageRosterHUD = {}

local v3 = {}
local v4 = {}

for i = 1, 8 do
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Row" .. i
	textLabel.LayoutOrder = i
	textLabel.Size = UDim2.new(0, 0, 0, 16)
	textLabel.AutomaticSize = Enum.AutomaticSize.X
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamMedium
	textLabel.TextSize = 11
	textLabel.TextColor3 = color2
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel.RichText = true
	textLabel.AutoLocalize = false
	textLabel.Text = ""
	textLabel.Visible = false

	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MaxSize = Vector2.new(460, 1e999)
	uiSizeConstraint.Parent = textLabel

	local uiPadding2 = Instance.new("UIPadding")
	uiPadding2.Parent = textLabel
	v[i] = uiPadding2

	textLabel.Parent = container
	table.insert(v2, textLabel)
end

StageRosterHUD.ReadyColorHex = string.format("%02X%02X%02X", color4.R * 255, color4.G * 255, color4.B * 255)
StageRosterHUD.NotReadyColorHex = string.format("%02X%02X%02X", color5.R * 255, color5.G * 255, color5.B * 255)

StageRosterHUD.AccentColorHex = string.format("%02X%02X%02X", color3.R * 255, color3.G * 255, color3.B * 255)

local StageReportButtonStyle = require(script.Parent.StageReportButtonStyle)
local v5 = StageReportButtonStyle.Build(stageRosterHUD)
local root = v5.Root
local BottomLeftStack2 = require(script.Parent.BottomLeftStack)
BottomLeftStack2.Register(root, 2.5)

local v6 = false
local v7 = false
local v8 = nil

local function updateReportButton() -- 1 equivalent call inferred from this helper
	root.Visible = v6 and container.Visible
end
container:GetPropertyChangedSignal("Visible"):Connect(updateReportButton)

v5.Button.Activated:Connect(function()
	if v7 and v8 then
		v8()
	end
end)

function StageRosterHUD.SetReportButton(p, p2, p3)
	if p then
		v6 = true
		v7 = p2 == true
		v8 = p3

		if v7 then
			v5.SetState("last report", true)
		else
			v5.SetState("no report", false)
		end
	else
		v6 = false
		v8 = nil
	end

	updateReportButton() -- inferred equivalent call
end

function StageRosterHUD.Show()
	stageRosterHUD.Enabled = true
end

function StageRosterHUD.Hide()
	stageRosterHUD.Enabled = false
end

local function setRowDot(i, p, dot)
	local v9 = v3[i]

	if dot and DifficultyBadge.WillRender(dot) then
		if v9 then
			DifficultyBadge.Update(v9, dot)
		else
			v9 = DifficultyBadge.Create(p, dot, 0, 9)
			v9.AnchorPoint = Vector2.new(0, 0.5)

			v9.Position = UDim2.new(0, -13, 0.5, 0)
			v3[i] = v9
		end

		v9.Visible = true
	elseif v9 then
		v9.Visible = false
	end
end

local function setRowIcon(i, parent, instrument, p)
	local image = instrument and InstrumentIcons.Get(instrument)
	local instrumentIcon = v4[i]

	if image then
		if not instrumentIcon then
			instrumentIcon = Instance.new("ImageLabel")
			instrumentIcon.Name = "InstrumentIcon"
			instrumentIcon.BackgroundTransparency = 1
			instrumentIcon.BorderSizePixel = 0
			instrumentIcon.AnchorPoint = Vector2.new(0.5, 0.5)
			instrumentIcon.ScaleType = Enum.ScaleType.Crop
			instrumentIcon.Parent = parent
			v4[i] = instrumentIcon
		end

		local size = InstrumentIcons.GetSize(instrument, 15)
		instrumentIcon.Image = image
		instrumentIcon.Size = UDim2.fromOffset(size.X, size.Y)
		instrumentIcon.Position = UDim2.new(0, -((p and 13 or 0) + 4 + 7.5), 0.5, 0)
		instrumentIcon.Visible = true
	elseif instrumentIcon then
		instrumentIcon.Visible = false
	end
end

function StageRosterHUD.SetEntries(list)
	container.Visible = #list > 0
	local v9 = false
	local v10 = false

	for _, item in ipairs(list) do
		v10 = type(item) == "table" and item.dot and DifficultyBadge.WillRender(item.dot) and true or v10

		if not (type(item) == "table" and item.instrument and InstrumentIcons.Get(item.instrument)) then
			continue
		end

		v9 = true
	end

	for i, v11 in ipairs(v2) do
		local item = list[i]

		if item then
			local v12, dot, instrument

			if type(item) == "table" then
				v12 = item.text
				dot = item.dot
				instrument = item.instrument
			else
				v12 = item
			end

			v11.Text = v12 or ""
			v11.Visible = true

			v[i].PaddingLeft = UDim.new(0, (v9 and 19 or 0) + (v10 and 13 or 0))
			setRowDot(i, v11, dot)
			setRowIcon(i, v11, instrument, v10)
		else
			v11.Text = ""
			v11.Visible = false
			local v12 = v3[i]

			if v12 then
				v12.Visible = false
			end

			local v13 = v4[i]

			if v13 then
				v13.Visible = false
			end
		end
	end
end

local viewerCountHUD = Instance.new("ScreenGui")
viewerCountHUD.Name = "ViewerCountHUD"
viewerCountHUD.ResetOnSpawn = false
viewerCountHUD.Parent = PlayerGui

local viewerCount = Instance.new("TextLabel")
viewerCount.Name = "ViewerCount"
viewerCount.AnchorPoint = Vector2.new(0, 1)

viewerCount.Position = UDim2.new(0, 24, 1, -16)
viewerCount.Size = UDim2.new(0, 0, 0, 13)
viewerCount.AutomaticSize = Enum.AutomaticSize.X
viewerCount.BackgroundTransparency = 1
viewerCount.Font = Enum.Font.GothamMedium
viewerCount.TextSize = 11
viewerCount.TextColor3 = color2
viewerCount.TextTransparency = 0.45
viewerCount.TextStrokeColor3 = Color3.new(0, 0, 0)
viewerCount.TextStrokeTransparency = 0.8
viewerCount.TextXAlignment = Enum.TextXAlignment.Left
viewerCount.Text = ""
viewerCount.Visible = false
viewerCount.Parent = viewerCountHUD
local BottomLeftStack3 = require(script.Parent.BottomLeftStack)
BottomLeftStack3.Register(viewerCount, 2.2)

function StageRosterHUD.SetViewerCount(value)
	if typeof(value) ~= "number" then
		viewerCount.Visible = false
		return
	end

	viewerCount.Text = string.format("CROWD : %d", value)
	viewerCount.Visible = true
end

return StageRosterHUD