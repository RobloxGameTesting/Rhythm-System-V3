local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local color = Color3.fromRGB(18, 18, 20)
local color2 = Color3.fromRGB(235, 235, 238)
local color3 = Color3.fromRGB(232, 168, 52)

local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local promptHud = Instance.new("ScreenGui")
promptHud.Name = "PromptHud"
promptHud.ResetOnSpawn = false
promptHud.DisplayOrder = 30
promptHud.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
promptHud.Parent = PlayerGui

local container = Instance.new("Frame")
container.Name = "Container"
container.AnchorPoint = Vector2.new(1, 1)
container.AutomaticSize = Enum.AutomaticSize.XY
container.Size = UDim2.fromOffset(0, 0)
container.BackgroundColor3 = color
container.BackgroundTransparency = 1
container.Visible = false
container.Parent = promptHud
container:SetAttribute("NoNewUISkin", true)

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingLeft = UDim.new(0, 12)
uiPadding.PaddingRight = UDim.new(0, 12)
uiPadding.PaddingTop = UDim.new(0, 8)
uiPadding.PaddingBottom = UDim.new(0, 8)
uiPadding.Parent = container

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Vertical
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
uiListLayout.Padding = UDim.new(0, v and 6 or 4)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = container

local v2 = nil
local function place() -- 2 equivalent calls inferred from this helper
	local v3 = v and 150 or v2 and v2.Enabled and 58 or 16

	container.Position = UDim2.new(1, -16, 1, -v3)
end

place() -- inferred equivalent call
task.spawn(function()
	local liveStatsHUD = PlayerGui:WaitForChild("LiveStatsHUD", 15)

	if liveStatsHUD and liveStatsHUD:IsA("ScreenGui") then
		v2 = liveStatsHUD
		liveStatsHUD:GetPropertyChangedSignal("Enabled"):Connect(place)
		place() -- inferred equivalent call
	end
end)

local v3 = {}
local v4 = {}

local function hex(color4) -- 3 equivalent calls inferred from this helper
	return string.format(
		"#%02X%02X%02X",
		math.floor(color4.R * 255 + 0.5),
		math.floor(color4.G * 255 + 0.5),
		(math.floor(color4.B * 255 + 0.5))
	)
end

local function esc(p) -- 2 equivalent calls inferred from this helper
	return (tostring(p):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function rowText(instance)
	local v5 = esc(instance:GetAttribute("HudLabel") or instance.ActionText) -- inferred equivalent call

	if v then
		return string.format("<font color=\"%s\">%s</font>", hex(color2), v5) -- inferred equivalent call
	end

	local v6 = esc(UserInputService:GetStringForKeyCode(instance.KeyboardKeyCode)) -- inferred equivalent call
	return string.format(
		"<font color=\"%s\"><b>%s</b></font><font color=\"%s\">  -  %s</font>",
		hex(color3), -- inferred equivalent call
		v6,
		hex(color2), -- inferred equivalent call
		v5
	)
end

local function refreshContainer() -- 2 equivalent calls inferred from this helper
	container.Visible = next(v3) ~= nil
end

local function removeRow(p)
	local v5 = v3[p]

	if not v5 then
		return
	end

	v3[p] = nil

	for _, connection in ipairs(v5.connections) do
		connection:Disconnect()
	end

	v5.button:Destroy()

	for k, v6 in pairs(v4) do
		if v6 == p then
			v4[k] = nil
		end
	end

	refreshContainer() -- inferred equivalent call
end

local function addRow(instance)
	if v3[instance] then
		return
	end

	local row = Instance.new("TextButton")
	row.Name = "Row"
	row.AutoButtonColor = false
	row.BackgroundTransparency = 1
	row.AutomaticSize = Enum.AutomaticSize.XY
	row.Size = UDim2.fromOffset(0, v and 34 or 18)
	row.Font = Enum.Font.GothamMedium
	row.TextSize = v and 15 or 13
	row.RichText = true
	row.TextXAlignment = Enum.TextXAlignment.Left
	row.TextColor3 = color2
	row.TextStrokeColor3 = Color3.new(0, 0, 0)
	row.TextStrokeTransparency = 0.35
	row.Text = rowText(instance)
	row.LayoutOrder = instance:GetAttribute("HudOrder") or 100
	row.Parent = container

	local holdBar = Instance.new("Frame")
	holdBar.Name = "HoldBar"
	holdBar.AnchorPoint = Vector2.new(0, 1)
	holdBar.Position = UDim2.new(0, 0, 1, 0)
	holdBar.Size = UDim2.new(0, 0, 0, 2)
	holdBar.BackgroundColor3 = color3
	holdBar.BorderSizePixel = 0
	holdBar.Parent = row

	local connections = {}
	local function track(object, fn) -- 3 equivalent calls inferred from this helper
		connections[#connections + 1] = object:Connect(fn)
	end

	local inputBegan = row.InputBegan
	connections[#connections + 1] = inputBegan:Connect(function(p)
		if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
			instance:InputHoldBegin()
		end
	end)
	local inputEnded = row.InputEnded
	connections[#connections + 1] = inputEnded:Connect(function(p)
		if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
			instance:InputHoldEnd()
		end
	end)

	local function fn()
		if instance.HoldDuration > 0 then
			holdBar.Size = UDim2.new(0, 0, 0, 2)
			TweenService:Create(holdBar, TweenInfo.new(instance.HoldDuration, Enum.EasingStyle.Linear), {
				Size = UDim2.new(1, 0, 0, 2)
			}):Play()
		end
	end

	track(instance.PromptButtonHoldBegan, fn) -- inferred equivalent call

	local promptButtonHoldEnded = instance.PromptButtonHoldEnded
	connections[#connections + 1] = promptButtonHoldEnded:Connect(function()
		holdBar.Size = UDim2.new(0, 0, 0, 2)
	end)

	local function fn2()
		row.Text = rowText(instance)
	end

	track(instance:GetAttributeChangedSignal("HudLabel"), fn2) -- inferred equivalent call

	local function fn3()
		row.Text = rowText(instance)
	end

	track(instance:GetPropertyChangedSignal("KeyboardKeyCode"), fn3) -- inferred equivalent call

	v3[instance] = { button = row, bar = holdBar, connections = connections }
	refreshContainer() -- inferred equivalent call
end

ProximityPromptService.PromptShown:Connect(function(instance)
	if instance:GetAttribute("HudLabel") then
		addRow(instance)
	end
end)

ProximityPromptService.PromptHidden:Connect(function(p)
	removeRow(p)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	for k in pairs(v3) do
		local v5

		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == k.KeyboardKeyCode then
			v5 = true
		elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
			v5 = input.KeyCode == k.GamepadKeyCode
		else
			v5 = false
		end

		if not v5 or v4[input.KeyCode] then
			continue
		end

		v4[input.KeyCode] = k
		k:InputHoldBegin()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	local v5 = v4[input.KeyCode]

	if v5 then
		v4[input.KeyCode] = nil
		v5:InputHoldEnd()
	end
end)