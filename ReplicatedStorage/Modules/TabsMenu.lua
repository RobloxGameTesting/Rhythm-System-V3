local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local TabsSkin = require(script.Parent.TabsSkin)

local TabsMenu = {}

local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local Dark = TabsSkin.Palettes.Dark
local v2 = v and 156 or 176
local v3 = v and 34 or 36

local function lazyModule(childName)
	local success, result = pcall(function()
		return require(script.Parent:WaitForChild(childName, 5))
	end)

	if success then
		return result
	end

	warn("[MENU] gagal memuat " .. childName .. ":", result)
	return nil
end

local v4 = {
	{
		Id = "TABS",
		Text = "TABS",
		Icon = "note",
		IsOpen = function()
			local v4
			v4 = "TabsUI"
			local success, result = pcall(function()
				return require(script.Parent:WaitForChild(v4, 5))
			end)

			if not success then
				warn("[MENU] gagal memuat TabsUI:", result)
				result = nil
			end

			return result ~= nil and result.IsOpen()
		end,
		Run = function()
			local v4
			v4 = "TabsUI"
			local success, result = pcall(function()
				return require(script.Parent:WaitForChild(v4, 5))
			end)

			if not success then
				warn("[MENU] gagal memuat TabsUI:", result)
				result = nil
			end

			if result then
				result.Toggle()
			end
		end
	},
	{
		Id = "NOTE",
		Text = "NOTE",
		Icon = "lines",
		IsOpen = function()
			local v4
			v4 = "NotePadUI"
			local success, result = pcall(function()
				return require(script.Parent:WaitForChild(v4, 5))
			end)

			if not success then
				warn("[MENU] gagal memuat NotePadUI:", result)
				result = nil
			end

			return result ~= nil and result.IsOpen()
		end,
		Run = function()
			local v4
			v4 = "NotePadUI"
			local success, result = pcall(function()
				return require(script.Parent:WaitForChild(v4, 5))
			end)

			if not success then
				warn("[MENU] gagal memuat NotePadUI:", result)
				result = nil
			end

			if not result then
				return
			end

			if result.IsOpen() then
				result.Flash()
			else
				result.Open()
			end
		end
	}
}

local flag = false
local freePlayMenuGui = nil
local menu = nil
local uiListLayout = nil
local rows = {}
local v5 = 0
local v6 = nil
local renderSteppedConnection = nil

local function paintRow(data) -- 3 equivalent calls inferred from this helper
	local hover = data.Button:GetAttribute("Hover") == true
	data.Button.BackgroundColor3 = hover and Dark.ButtonHi or Dark.Button
	local visible

	if data.Item.IsOpen then
		local success, result = pcall(data.Item.IsOpen)
		visible = success and result == true
	else
		visible = false
	end

	data.Dot.Visible = visible
end

local function refreshRows() -- 2 equivalent calls inferred from this helper
	for _, v7 in ipairs(rows) do
		paintRow(v7) -- inferred equivalent call
	end
end

local function isShown(instance)
	while instance and instance ~= game do
		if instance:IsA("GuiObject") and not instance.Visible then
			return false
		end

		if instance:IsA("LayerCollector") then
			return instance.Enabled
		end

		instance = instance.Parent
	end

	return false
end

function TabsMenu.Hide()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	v6 = nil

	if menu then
		menu.Visible = false
	end
end

function TabsMenu.IsOpen()
	return menu ~= nil and menu.Visible
end

local function reposition()
	if not (v6 and v6.Parent) then
		return
	end

	local absolutePosition = v6.AbsolutePosition
	local absoluteSize = v6.AbsoluteSize
	local absolutePosition2 = freePlayMenuGui.AbsolutePosition
	local absoluteSize2 = freePlayMenuGui.AbsoluteSize
	local v7 = absolutePosition.X - absolutePosition2.X
	local v8 = absolutePosition.Y - absolutePosition2.Y
	local v9 = math.clamp(v7, 4, (math.max(4, absoluteSize2.X - v2 - 12 - 4)))
	local v10 = absoluteSize2.Y - (v8 + absoluteSize.Y)
	local v11

	if v5 + 8 <= v10 then
		v11 = v8 + absoluteSize.Y + 4
	else
		v11 = v8 - v5 - 4
	end

	menu.Position = UDim2.fromOffset(v9, (math.max(4, v11)))
end

local function populate(list)
	for _, v7 in ipairs(rows) do
		v7.Button:Destroy()
	end

	rows = {}

	for i, item in ipairs(list) do
		local textButton = Instance.new("TextButton")
		textButton.Name = "Item_" .. tostring(item.Id or i)
		textButton.LayoutOrder = i
		textButton.AutoButtonColor = false
		textButton.BorderSizePixel = 0
		textButton.BackgroundColor3 = Dark.Button
		textButton.Size = UDim2.new(1, 0, 0, v3)
		textButton.Font = TabsSkin.FontLabel
		textButton.TextSize = v and 16 or 17
		textButton.TextColor3 = Dark.Text
		textButton.Text = item.Text
		textButton.TextXAlignment = Enum.TextXAlignment.Left
		textButton.Parent = menu
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingLeft = UDim.new(0, 36)
		uiPadding.Parent = textButton
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 2)
		uiCorner.Parent = textButton
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = 1
		uiStroke.Transparency = 0.3
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Color = Dark.Border
		uiStroke.Parent = textButton
		local icon = TabsSkin.icon(textButton, item.Icon, 16, Dark.Text)

		if icon then
			icon.AnchorPoint = Vector2.new(0, 0.5)
			icon.Position = UDim2.new(0, -26, 0.5, 0)
		end

		local openDot = Instance.new("Frame")
		openDot.Name = "OpenDot"
		openDot.AnchorPoint = Vector2.new(1, 0.5)
		openDot.Position = UDim2.new(1, -8, 0.5, 0)
		openDot.Size = UDim2.fromOffset(8, 8)
		openDot.BackgroundColor3 = Dark.Accent
		openDot.BorderSizePixel = 0
		openDot.Visible = false
		openDot.Parent = textButton
		local uiCorner2 = Instance.new("UICorner")
		uiCorner2.CornerRadius = UDim.new(1, 0)
		uiCorner2.Parent = openDot

		local v7 = { Item = item, Button = textButton, Dot = openDot }
		rows[#rows + 1] = v7

		if UserInputService.MouseEnabled then
			textButton.MouseEnter:Connect(function()
				textButton:SetAttribute("Hover", true)
				paintRow(v7) -- inferred equivalent call
			end)
			textButton.MouseLeave:Connect(function()
				textButton:SetAttribute("Hover", false)
				paintRow(v7) -- inferred equivalent call
			end)
		end

		textButton.Activated:Connect(function()
			TabsMenu.Hide()
			local success, result = pcall(item.Run)

			if not success then
				warn("[MENU] item " .. tostring(item.Id) .. " error:", result)
			end
		end)
	end

	v5 = #list * v3 + math.max(0, #list - 1) * 4 + 12
	menu.Size = UDim2.fromOffset(v2 + 12, v5)
end

local function build()
	if flag then
		return
	end

	flag = true

	freePlayMenuGui = Instance.new("ScreenGui")
	freePlayMenuGui.Name = "FreePlayMenuGui"
	freePlayMenuGui.ResetOnSpawn = false
	freePlayMenuGui.IgnoreGuiInset = true
	freePlayMenuGui.DisplayOrder = 60
	freePlayMenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	freePlayMenuGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	menu = Instance.new("Frame")
	menu.Name = "Menu"
	menu.Visible = false
	menu.BackgroundColor3 = Dark.Panel
	menu.BorderSizePixel = 0
	menu.Active = true
	menu.Size = UDim2.fromOffset(v2 + 12, 40)
	menu.Parent = freePlayMenuGui
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 3)
	uiCorner.Parent = menu
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 2
	uiStroke.Color = Dark.Stroke
	uiStroke.Parent = menu
	local uiPadding = Instance.new("UIPadding")
	local udim = UDim.new(0, 6)
	local udim2 = UDim.new(0, 6)
	uiPadding.PaddingLeft = udim
	uiPadding.PaddingRight = udim2
	local udim3 = UDim.new(0, 6)
	local udim4 = UDim.new(0, 6)
	uiPadding.PaddingTop = udim3
	uiPadding.PaddingBottom = udim4
	uiPadding.Parent = menu
	uiListLayout = Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 4)
	uiListLayout.Parent = menu

	UserInputService.InputBegan:Connect(function(input)
		if not menu.Visible then
			return
		end

		if input.KeyCode == Enum.KeyCode.Escape then
			TabsMenu.Hide()
			return
		end

		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

		if not playerGui then
			return
		end

		local guiObjectsAtPosition = playerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)

		for _, v7 in ipairs(guiObjectsAtPosition) do
			if v7 == menu or v7:IsDescendantOf(menu) or v6 and (v7 == v6 or v7:IsDescendantOf(v6)) then
				return
			end
		end

		TabsMenu.Hide()
	end)
end

function TabsMenu.Show(p, p2)
	if not p then
		return
	end

	build()
	v6 = p
	populate(p2 or v4)
	refreshRows() -- inferred equivalent call
	menu.Visible = true
	reposition()

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if not (v6 and v6.Parent and isShown(v6)) then
			TabsMenu.Hide()
			return
		end

		reposition()
		refreshRows() -- inferred equivalent call
	end)
end

function TabsMenu.Toggle(p, p2)
	build()

	if menu.Visible and v6 == p then
		TabsMenu.Hide()
	else
		TabsMenu.Show(p, p2)
	end
end

function TabsMenu._debug()
	return { gui = freePlayMenuGui, menu = menu, rows = rows }
end

return TabsMenu