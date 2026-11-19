local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local total = 0

while ReplicatedStorage:GetAttribute("BandUi") ~= true and total < 15 do
	task.wait(0.5)
	total += 0.5
end

if ReplicatedStorage:GetAttribute("BandUi") ~= true then
	return
end

local PopularityRemotes = ReplicatedStorage:WaitForChild("PopularityRemotes", 10)

if not PopularityRemotes then
	return
end

local BandAction = PopularityRemotes:WaitForChild("BandAction", 10)
local BandState = PopularityRemotes:WaitForChild("BandState", 10)

if not (BandAction and BandState) then
	return
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function safeRequire(callback)
	local success, result = pcall(function()
		return require(callback())
	end)

	if success then
		return result
	end

	warn("[BandClient] modul gagal dimuat: " .. tostring(result))
	return nil
end

local Modules = ReplicatedStorage:WaitForChild("Modules", 10)
local result

if Modules then
	local function fn()
		return Modules:WaitForChild("SongListUI", 10):WaitForChild("StyledTheme", 10)
	end

	local success
	success, result = pcall(function()
		return require(fn())
	end)

	if not success then
		warn("[BandClient] modul gagal dimuat: " .. tostring(result))
		result = nil
	end
else
	result = Modules
end

local result2

if Modules then
	local function fn()
		return Modules:WaitForChild("SongListUI", 10):WaitForChild("UISkin", 10)
	end

	local success
	success, result2 = pcall(function()
		return require(fn())
	end)

	if not success then
		warn("[BandClient] modul gagal dimuat: " .. tostring(result2))
		result2 = nil
	end
else
	result2 = Modules
end

local result3

if Modules then
	local function fn()
		return Modules:WaitForChild("UIPanelGate", 10)
	end

	local success
	success, result3 = pcall(function()
		return require(fn())
	end)

	if not success then
		warn("[BandClient] modul gagal dimuat: " .. tostring(result3))
		result3 = nil
	end
else
	result3 = Modules
end

local result4

if Modules then
	local function fn()
		return Modules:WaitForChild("SessionCameraSettings", 10)
	end

	local success
	success, result4 = pcall(function()
		return require(fn())
	end)

	if not success then
		warn("[BandClient] modul gagal dimuat: " .. tostring(result4))
		result4 = nil
	end
else
	result4 = Modules
end

local v = {
	BG = Color3.fromRGB(22, 22, 26),
	CARD = Color3.fromRGB(34, 34, 40),
	CARD_ACTIVE = Color3.fromRGB(50, 50, 58),
	TEXT = Color3.fromRGB(245, 245, 247),
	TEXT_DIM = Color3.fromRGB(160, 160, 170),
	ACCENT = Color3.fromRGB(88, 210, 150),
	WARNING = Color3.fromRGB(255, 190, 80),
	DANGER = Color3.fromRGB(144, 55, 47),
	BORDER = Color3.fromRGB(60, 60, 70),
	BUTTON = Color3.fromRGB(23, 23, 27),
	BTN = Color3.fromRGB(45, 45, 52),
	INPUT = Color3.fromRGB(18, 18, 22),
	DARKTEXT = Color3.fromRGB(18, 30, 24)
}

v = result and type(result.Settings) == "table" and result.Settings or v

local color = Color3.fromRGB(23, 23, 27)
local color2 = Color3.fromRGB(50, 50, 58)
local color3 = Color3.fromRGB(60, 60, 70)

local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo3 = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function create(className, items, parent) -- 25 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function addCorner(parent, value) -- 3 equivalent calls inferred from this helper
	return create("UICorner", { -- inferred equivalent call
		CornerRadius = UDim.new(0, value or 8)
	}, parent)
end

local function addStroke(parent, color4, transparency, thickness) -- 4 equivalent calls inferred from this helper
	return create( -- inferred equivalent call
		"UIStroke",
		{
			Color = color4,
			Transparency = transparency,
			Thickness = thickness,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		},
		parent
	)
end

local function tween(instance, tweenInfo4, goal) -- 1 equivalent call inferred from this helper
	local tween2 = TweenService:Create(instance, tweenInfo4, goal)
	tween2:Play()
	return tween2
end

local function getViewportSize() -- 1 equivalent call inferred from this helper
	local currentCamera = Workspace.CurrentCamera
	return currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
end

local function getButtonCenterY() -- 6 equivalent calls inferred from this helper
	return GuiService:GetGuiInset().Y / 2 + 30 + 6
end

local function getPanelTop()
	return getButtonCenterY() + 15 + 6 -- inferred equivalent call
end

local function computeScale() -- 1 equivalent call inferred from this helper
	local viewportSize = getViewportSize() -- inferred equivalent call
	local v2 = viewportSize.X - 24
	local v3 = viewportSize.Y - (getButtonCenterY() + 15 + 6) - 8 -- inferred equivalent call
	return (math.clamp(math.min(v2 / 594, v3 / 380), 0.5, 1.25))
end

local parent2 = create("ScreenGui", { -- inferred equivalent call
	Name = "BandGui",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 97,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

local textButton = create("TextButton", { -- inferred equivalent call
	Name = "Catcher",
	Text = "",
	AutoButtonColor = false,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	Visible = false,
	ZIndex = 1
}, parent2)

local parent3 = create("TextButton", { -- inferred equivalent call
	Name = "BandToggle",
	Text = "Band",
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	TextColor3 = Color3.fromRGB(245, 245, 247),
	AutoButtonColor = false,
	BackgroundColor3 = color,
	BackgroundTransparency = 0.25,
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -88, 0, getButtonCenterY()), -- inferred equivalent call
	Size = UDim2.new(0, 70, 0, 30),
	Visible = false,
	ZIndex = 20
}, parent2)

parent3:SetAttribute("NoNewUISkin", true)
addCorner(parent3) -- inferred equivalent call
local v2 = addStroke(parent3, color3, 1, 1) -- inferred equivalent call
local parent4 = create("Frame", { -- inferred equivalent call
	Name = "AttentionDot",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(1, -4, 0, 4),
	Size = UDim2.fromOffset(10, 10),
	BackgroundColor3 = v.ACCENT,
	Visible = false,
	ZIndex = 22
}, parent3)

create("UICorner", { CornerRadius = UDim.new(1, 0) }, parent4) -- inferred equivalent call
addStroke(parent4, color, 0, 1.5) -- inferred equivalent call
local frame = create("Frame", { -- inferred equivalent call
	Name = "Root",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -12, 0, getButtonCenterY() + 15 + 6), -- inferred equivalent call
	Size = UDim2.new(0, 340, 0, 380),
	Visible = false,
	ZIndex = 5
}, parent2)

local uiScale = create("UIScale", { Scale = 1 }, frame) -- inferred equivalent call

local parent5 = create("Frame", { -- inferred equivalent call
	Name = "ListPanel",
	BackgroundColor3 = v.BG,
	BackgroundTransparency = 0.12,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, 0, 0, 0),
	Size = UDim2.new(0, 340, 0, 380),
	ClipsDescendants = true,
	Active = true,
	ZIndex = 6
}, frame)
create("UICorner", { CornerRadius = UDim.new(0, 12) }, parent5) -- inferred equivalent call

addStroke(parent5, v.BORDER, 0.2, 1) -- inferred equivalent call

local textLabel = create("TextLabel", { -- inferred equivalent call
	Name = "Title",
	Text = "Band",
	Font = Enum.Font.GothamBold,
	TextSize = 15,
	TextColor3 = v.TEXT,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 14, 0, 10),
	Size = UDim2.new(1, -60, 0, 24),
	ZIndex = 7
}, parent5)

local parent6 = create("TextButton", { -- inferred equivalent call
	Name = "Close",
	Text = "X",
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextColor3 = v.TEXT_DIM,
	AutoButtonColor = false,
	BackgroundColor3 = v.CARD,
	BackgroundTransparency = 0.3,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -10, 0, 10),
	Size = UDim2.new(0, 24, 0, 24),
	ZIndex = 8
}, parent5)
create("UICorner", { CornerRadius = UDim.new(0, 6) }, parent6) -- inferred equivalent call

local parent7 = create("ScrollingFrame", { -- inferred equivalent call
	Name = "Content",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 12, 0, 44),
	Size = UDim2.new(1, -24, 1, -92),
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = v.BORDER,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ZIndex = 7
}, parent5)

create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }, parent7) -- inferred equivalent call

create("UIPadding", { PaddingRight = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }, parent7) -- inferred equivalent call

local textLabel2 = create("TextLabel", { -- inferred equivalent call
	Name = "Status",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 14, 1, -8),
	Size = UDim2.new(1, -28, 0, 34),
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Bottom,
	TextColor3 = v.ACCENT,
	Text = "",
	ZIndex = 7
}, parent5)

local count = 0
local v3 = 0
local v4 = nil
local v5 = 0
local flag = false
local count2 = 0
local v6 = nil
local fn
local closePanel

local function act(p, options) -- 13 equivalent calls inferred from this helper
	BandAction:FireServer(p, options or {})
end

local function newLabel(text, value, p, p2, value2)
	count += 1
	return create("TextLabel", { -- inferred equivalent call
		LayoutOrder = count,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, value or 18),
		Font = p2 and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextSize = value2 or 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = p or v.TEXT,
		Text = text
	}, parent7)
end

local function newHeading(text) -- 7 equivalent calls inferred from this helper
	return (newLabel(text, 18, v.TEXT_DIM, true, 12))
end

local function newRow(value, p)
	count += 1
	local row = create("Frame", { -- inferred equivalent call
		LayoutOrder = count,
		Size = UDim2.new(1, 0, 0, value or 32),
		BackgroundColor3 = p and v.INPUT or v.CARD,
		BackgroundTransparency = p and 0 or 0.2,
		BorderSizePixel = 0
	}, parent7)
	addCorner(row) -- inferred equivalent call
	addStroke(row, v.BORDER, p and 0.4 or 0.5, 1) -- inferred equivalent call
	return row
end

local function styleButton(p, p2) -- 2 equivalent calls inferred from this helper
	if p2 == "accent" then
		p.BackgroundColor3 = v.ACCENT
		p.TextColor3 = v.DARKTEXT
	else
		if p2 == "danger" then
			p.BackgroundColor3 = v.DANGER
		else
			p.BackgroundColor3 = v.BTN
		end

		p.TextColor3 = v.TEXT
	end
end

local function hoverable(instance)
	instance.MouseEnter:Connect(function()
		TweenService:Create(instance, tweenInfo3, { BackgroundTransparency = 0.2 }):Play()
	end)
	instance.MouseLeave:Connect(function()
		TweenService:Create(instance, tweenInfo3, { BackgroundTransparency = 0 }):Play()
	end)
end

local function makeButton(parent, text, p, callback)
	local button = create("TextButton", { -- inferred equivalent call
		Size = UDim2.new(0, 62, 0, 24),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		BackgroundTransparency = 0,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		Text = text
	}, parent)

	if p == "accent" then
		styleButton(button, "accent") -- inferred equivalent call
	else
		if p == "danger" then
			button.BackgroundColor3 = v.DANGER
		else
			button.BackgroundColor3 = v.BTN
		end

		button.TextColor3 = v.TEXT
	end

	create("UICorner", { CornerRadius = UDim.new(0, 6) }, button) -- inferred equivalent call

	hoverable(button)
	button.Activated:Connect(function()
		if os.clock() < v3 then
			return
		end

		v3 = os.clock() + 1
		callback()
	end)
	return button
end

local function textRowWithButtons(text, list)
	local parent = newRow(32)
	local count3 = #list
	create("TextLabel", { -- inferred equivalent call
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -(count3 * 66 + 18), 1, 0),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextColor3 = v.TEXT,
		Text = text
	}, parent)

	for i, item in ipairs(list) do
		local button = makeButton(parent, item[1], item[2], item[3])
		button.AnchorPoint = Vector2.new(1, 0.5)
		button.Position = UDim2.new(1, -4 - (count3 - i) * 66, 0.5, 0)
	end

	return parent
end

local function inputRow(placeholderText, text, fn2)
	local parent = newRow(32, true)
	local textBox = create("TextBox", { -- inferred equivalent call
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -88, 1, 0),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = v.TEXT,
		PlaceholderText = placeholderText,
		PlaceholderColor3 = v.TEXT_DIM,
		ClearTextOnFocus = false,
		Text = ""
	}, parent)

	local button = makeButton(parent, text, "accent", function()
		fn2(textBox.Text)
	end)
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -4, 0.5, 0)
	return parent
end

local function wideButton(text, p, onActivated)
	count += 1
	local textButton2 = create("TextButton", { -- inferred equivalent call
		LayoutOrder = count,
		Size = UDim2.new(1, 0, 0, 32),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		BackgroundTransparency = 0,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		Text = text
	}, parent7)

	if p == "accent" then
		styleButton(textButton2, "accent") -- inferred equivalent call
	else
		if p == "danger" then
			textButton2.BackgroundColor3 = v.DANGER
		else
			textButton2.BackgroundColor3 = v.BTN
		end

		textButton2.TextColor3 = v.TEXT
	end

	addCorner(textButton2) -- inferred equivalent call
	hoverable(textButton2)
	textButton2.Activated:Connect(onActivated)
	return textButton2
end

local function renderNotInBand(data)
	newLabel("You're not in a band.", 20, v.TEXT_DIM, false, 12)
	newHeading("Create a band") -- inferred equivalent call
	inputRow("Band name (3-20 characters)", "Create", function(name)
		act("Create", { Name = name }) -- inferred equivalent call
	end)
	newHeading("Join a band") -- inferred equivalent call
	inputRow("Exact band name", "Request", function(name)
		act("Request", { Name = name }) -- inferred equivalent call
	end)

	if #data.Invites > 0 then
		newHeading("Invites") -- inferred equivalent call

		for _, invite in ipairs(data.Invites) do
			textRowWithButtons(string.format("%s  (from %s)", tostring(invite.Name), (tostring(invite.From))), {
				{
					"Accept",
					"accent",
					function()
						act("AcceptInvite", { BandId = invite.BandId }) -- inferred equivalent call
					end
				},
				{
					"Decline",
					"neutral",
					function()
						act("DeclineInvite", { BandId = invite.BandId }) -- inferred equivalent call
					end
				}
			})
		end
	end
end

local function renderInBand(data)
	local band = data.Band
	textLabel.Text = band.Name
	newLabel(
		string.format("Popularity %d   |   Members %d/%d", math.floor(band.Popularity), band.Count, band.Capacity),
		20,
		v.ACCENT,
		true,
		13
	)

	if band.Review then
		newLabel("This band is under review. Some actions are paused.", 30, v.WARNING, false, 12)
	elseif band.Unverified then
		newLabel("Capacity check pending. New joins may take a moment.", 30, v.TEXT_DIM, false, 12)
	end

	newHeading("Members") -- inferred equivalent call
	local userIdSet = {}

	for _, member in ipairs(band.Members) do
		userIdSet[member.UserId] = true
		local text = string.format(
			"%s%s  -  %d",
			member.IsOwner and "* " or "",
			tostring(member.Name),
			(math.floor(member.Popularity))
		)

		if band.IsOwner and not member.IsOwner and member.UserId ~= LocalPlayer.UserId then
			textRowWithButtons(text, {
				{
					"Transfer",
					"neutral",
					function()
						act("Transfer", { UserId = member.UserId }) -- inferred equivalent call
					end
				},
				{
					"Kick",
					"danger",
					function()
						act("Kick", { UserId = member.UserId }) -- inferred equivalent call
					end
				}
			})
		else
			textRowWithButtons(text, {})
		end
	end

	if not band.IsOwner then
		wideButton("Leave band", "neutral", function()
			if os.clock() < v3 then
				return
			end

			v3 = os.clock() + 1
			act("Leave") -- inferred equivalent call
		end)

		return
	end

	if #band.Requests > 0 then
		newHeading("Join requests") -- inferred equivalent call

		for _, request in ipairs(band.Requests) do
			textRowWithButtons(tostring(request.Name), {
				{
					"Accept",
					"accent",
					function()
						act("AcceptRequest", { UserId = request.UserId }) -- inferred equivalent call
					end
				},
				{
					"Reject",
					"neutral",
					function()
						act("RejectRequest", { UserId = request.UserId }) -- inferred equivalent call
					end
				}
			})
		end
	end

	local v7 = {}

	for _, v8 in ipairs(Players:GetPlayers()) do
		if v8 == LocalPlayer or userIdSet[v8.UserId] then
			continue
		end

		table.insert(v7, v8)
	end

	if #v7 > 0 then
		newHeading("Invite players in this server") -- inferred equivalent call

		for _, v8 in ipairs(v7) do
			textRowWithButtons(v8.DisplayName, {
				{
					"Invite",
					"accent",
					function()
						act("Invite", { UserId = v8.UserId }) -- inferred equivalent call
					end
				}
			})
		end
	end

	newHeading("Rename band") -- inferred equivalent call
	inputRow("New band name", "Rename", function(name)
		act("Rename", { Name = name }) -- inferred equivalent call
	end)

	wideButton(os.clock() < v5 and "Tap again to confirm disband" or "Disband band", "danger", function()
		if os.clock() < v5 then
			v5 = 0
			act("Disband") -- inferred equivalent call
		else
			v5 = os.clock() + 4

			if v4 then
				fn(v4)
			end

			task.delay(4.1, function()
				if v4 and flag then
					fn(v4)
				end
			end)
		end
	end)
end

fn = function(data)
	for _, child in ipairs(parent7:GetChildren()) do
		if not (child:IsA("UIListLayout") or child:IsA("UIPadding")) then
			child:Destroy()
		end
	end

	count = 0
	textLabel.Text = "Band"
	textLabel2.Text = data.Notice or ""

	if data.InBand and data.Band then
		renderInBand(data)
	else
		renderNotInBand(data)
	end

	local v7 = #data.Invites > 0 or data.Band and data.Band.IsOwner and #data.Band.Requests > 0
	parent4.BackgroundColor3 = v.ACCENT
	parent4.Visible = v7 and true or false
end

local function placeToggle()
	if v6 then
		local position = v6.Position
		parent3.AnchorPoint = v6.AnchorPoint
		parent3.Size = UDim2.new(0, 70, 0, v6.Size.Y.Offset)
		parent3.Position = UDim2.new(
			position.X.Scale,
			position.X.Offset - v6.Size.X.Offset - 6,
			position.Y.Scale,
			position.Y.Offset
		)
	else
		parent3.AnchorPoint = Vector2.new(1, 0.5)
		parent3.Size = UDim2.new(0, 70, 0, 30)
		parent3.Position = UDim2.new(1, -88, 0, getButtonCenterY()) -- inferred equivalent call
	end
end

local function layoutForViewport() -- 3 equivalent calls inferred from this helper
	placeToggle()
	frame.Position = UDim2.new(1, -12, 0, getButtonCenterY() + 15 + 6) -- inferred equivalent call
	uiScale.Scale = computeScale() -- inferred equivalent call
end

local function updateVisibility() -- 2 equivalent calls inferred from this helper
	local visible = v6 == nil or v6.Visible
	parent3.Visible = visible

	if not visible and flag then
		closePanel(true)
	end
end

local function openPanel()
	if flag or not parent3.Visible or result3 and not result3.Request("Band") then
		return
	end

	flag = true
	count2 += 1

	if result4 then
		pcall(result4.SetMenuOpen, true)
	end

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	layoutForViewport() -- inferred equivalent call
	act("Refresh") -- inferred equivalent call

	if v4 then
		fn(v4)
	end

	textButton.Visible = true
	frame.Visible = true
	parent5.Size = UDim2.new(0, 340, 0, 0)
	parent5.BackgroundTransparency = 1
	TweenService:Create(parent5, tweenInfo, {
		Size = UDim2.new(0, 340, 0, 380),
		BackgroundTransparency = 0.12
	}):Play()
	TweenService:Create(parent3, tweenInfo3, { BackgroundColor3 = color2 }):Play()
	v2.Color = v.ACCENT
	v2.Transparency = 0.5
end

closePanel = function(p)
	if not flag then
		return
	end

	flag = false

	if result3 then
		result3.Release("Band")
	end

	count2 += 1
	local v7 = count2

	v5 = 0
	textButton.Visible = false

	if result4 then
		pcall(result4.SetMenuOpen, false)
	end

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	TweenService:Create(parent3, tweenInfo3, { BackgroundColor3 = color }):Play()
	v2.Color = color3
	v2.Transparency = 1

	if p then
		frame.Visible = false
		return
	end

	tween(parent5, tweenInfo2, { Size = UDim2.new(0, 340, 0, 0), BackgroundTransparency = 1 }).Completed:Connect(function() -- inferred equivalent call
		if v7 == count2 and not flag then
			frame.Visible = false
		end
	end)
end

if result3 then
	result3.Register("Band", {
		Close = function()
			closePanel(true)
		end,
		IsOpen = function()
			return flag
		end
	})
end

parent3.Activated:Connect(function()
	if flag then
		closePanel()
	else
		openPanel()
	end
end)

parent3.MouseEnter:Connect(function()
	if not flag then
		TweenService:Create(parent3, tweenInfo3, { BackgroundColor3 = color2 }):Play()
	end
end)
parent3.MouseLeave:Connect(function()
	if not flag then
		TweenService:Create(parent3, tweenInfo3, { BackgroundColor3 = color }):Play()
	end
end)

parent6.Activated:Connect(function()
	closePanel()
end)

textButton.Activated:Connect(function()
	closePanel()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.Escape and flag then
		closePanel()
	end
end)

RunService:BindToRenderStep("BandMouseOverride", Enum.RenderPriority.Camera.Value + 50, function()
	if not flag or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		return
	end

	if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end)

BandState.OnClientEvent:Connect(function(p)
	if type(p) ~= "table" or type(p.Invites) ~= "table" then
		return
	end

	v4 = p
	fn(p)
end)

local function onRosterChanged()
	if flag and v4 and v4.InBand then
		task.defer(fn, v4)
	end
end
Players.PlayerAdded:Connect(onRosterChanged)
Players.PlayerRemoving:Connect(onRosterChanged)

local function watchViewport(currentCamera) -- 2 equivalent calls inferred from this helper
	if currentCamera then
		currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutForViewport)
	end
end
watchViewport(Workspace.CurrentCamera) -- inferred equivalent call
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	watchViewport(Workspace.CurrentCamera) -- inferred equivalent call
	layoutForViewport() -- inferred equivalent call
end)

task.spawn(function()
	local equipmentUI = PlayerGui:WaitForChild("EquipmentUI", 15)
	local equipmentButton = equipmentUI and equipmentUI:WaitForChild("EquipmentButton", 5)

	if equipmentButton then
		v6 = equipmentButton
		equipmentButton:GetPropertyChangedSignal("Position"):Connect(placeToggle)
		equipmentButton:GetPropertyChangedSignal("Size"):Connect(placeToggle)
		equipmentButton:GetPropertyChangedSignal("Visible"):Connect(updateVisibility)
		placeToggle()
		updateVisibility() -- inferred equivalent call
	end
end)
layoutForViewport() -- inferred equivalent call
updateVisibility() -- inferred equivalent call
parent2.Parent = PlayerGui

if result2 and result2.AddRoot then
	local success, result5 = pcall(result2.AddRoot, parent2)

	if not success then
		warn("[BandClient] UISkin.AddRoot gagal: " .. tostring(result5))
	end
end