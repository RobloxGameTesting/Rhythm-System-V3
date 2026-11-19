local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CaptureService = game:GetService("CaptureService")
local GuiService = game:GetService("GuiService")

local GCamConfig = require(script.Parent.GCamConfig)
local GCamGalleryStore = require(script.Parent.GCamGalleryStore)
local GCamDevelop = require(script.Parent.GCamDevelop)
local SessionCameraSettings = require(script.Parent.SessionCameraSettings)

local Colors = GCamConfig.Colors
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local GCamGalleryUI = {}

local gCamGalleryGui = nil
local board = nil
local parent2 = nil
local empty = nil
local count = nil
local viewer = nil
local imageLabel = nil
local caption = nil
local status = nil
local v = nil
local flag = false
local v2 = false
local v3 = nil
local flag2 = false
local v4 = false

local gCamFullscreenGui = nil
local imageLabel2 = nil
local v5 = nil
local v6 = nil
local inputBeganConnection = nil
local v7 = nil
local v8 = false

local gCamShareGui = nil
local scrollingFrame = nil
local v9 = nil
local v10 = nil
local v11 = {}
local lastTime = 0

local function corner(parent, value) -- 24 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, value or 4)
	uiCorner.Parent = parent
	return uiCorner
end

local function stroke(parent, color, value, value2) -- 20 equivalent calls inferred from this helper
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color
	uiStroke.Thickness = value or 1
	uiStroke.Transparency = value2 or 0
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = parent
	return uiStroke
end

local function label(parent, text, font, textSize, textColor, value)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = value or "Label"
	textLabel.BackgroundTransparency = 1
	textLabel.Font = font
	textLabel.TextSize = textSize
	textLabel.TextColor3 = textColor
	textLabel.Text = text
	textLabel.Parent = parent
	return textLabel
end

local function button(parent, text, backgroundColor, textColor, p)
	local textButton = Instance.new("TextButton")
	textButton.AutoButtonColor = false
	textButton.BackgroundColor3 = backgroundColor
	textButton.TextColor3 = textColor
	textButton.Font = Enum.Font.GothamBold
	textButton.TextSize = 12
	textButton.Text = text
	textButton.Size = p or UDim2.fromOffset(110, 32)
	textButton.Parent = parent
	corner(textButton, 3) -- inferred equivalent call
	textButton.MouseEnter:Connect(function()
		textButton.BackgroundColor3 = backgroundColor:Lerp(Color3.new(1, 1, 1), 0.14)
	end)
	textButton.MouseLeave:Connect(function()
		textButton.BackgroundColor3 = backgroundColor
	end)
	return textButton
end

local function formatTime(ts) -- 1 equivalent call inferred from this helper
	local success, result = pcall(function()
		return DateTime.fromUnixTimestamp(ts):FormatLocalTime("MMM DD YYYY  HH:mm", "en-us")
	end)

	return success and string.upper(result) or ""
end

local function photoCaption(data)
	local v12 = data.recipe and GCamConfig.GetFilterById(data.recipe.filter)
	local ts = data.ts or os.time()
	local success, result = pcall(function()
		return DateTime.fromUnixTimestamp(ts):FormatLocalTime("MMM DD YYYY  HH:mm", "en-us")
	end)

	local v13 = { success and string.upper(result) or "" }

	if v12 then
		table.insert(v13, v12.name)
	end

	if data.fromName then
		table.insert(v13, "FROM " .. string.upper(data.fromName))
	end

	return table.concat(v13, "  •  ")
end

local function bindFreeMouse(p)
	if p then
		RunService:BindToRenderStep("GCamGalleryMouse", Enum.RenderPriority.Camera.Value + 2, function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		end)
	else
		pcall(function()
			RunService:UnbindFromRenderStep("GCamGalleryMouse")
		end)
	end
end

local function lockMenu(p)
	if p and not v2 then
		v2 = true
		SessionCameraSettings.SetMenuOpen(true)
		RunService:BindToRenderStep("GCamGalleryMouse", Enum.RenderPriority.Camera.Value + 2, function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		end)
	elseif not p and v2 then
		v2 = false
		SessionCameraSettings.SetMenuOpen(false)
		pcall(function()
			RunService:UnbindFromRenderStep("GCamGalleryMouse")
		end)
	end
end

local function isGamepadInput(): boolean -- 7 equivalent calls inferred from this helper
	return string.sub(UserInputService:GetLastInputType().Name, 1, 7) == "Gamepad"
end

local function focusFirstButton(folder) -- 1 equivalent call inferred from this helper
	if not (isGamepadInput() and folder) then -- inferred equivalent call
		return
	end

	task.defer(function()
		local selectedObject = nil

		for _, button2 in ipairs(folder:GetDescendants()) do
			if not (button2:IsA("TextButton") and button2.Visible and button2.Selectable) then
				continue
			end

			if string.sub(button2.Name, 1, 6) == "Photo_" then
				GuiService.SelectedObject = button2
				return
			end

			selectedObject = selectedObject or button2
		end

		if selectedObject then
			GuiService.SelectedObject = selectedObject
		end
	end)
end

local gCamToastGui = nil
local frame = nil
local v12 = nil
local count2 = 0

function GCamGalleryUI.SetToastsMuted(p)
	v4 = p == true

	if v4 then
		count2 += 1

		if frame then
			frame.Position = UDim2.new(0.5, 0, 0, -60)
		end
	end
end

function GCamGalleryUI.Toast(text, p)
	if v4 or v8 then
		return
	end

	if not gCamToastGui then
		gCamToastGui = Instance.new("ScreenGui")
		gCamToastGui.Name = "GCamToastGui"
		gCamToastGui.ResetOnSpawn = false
		gCamToastGui.IgnoreGuiInset = true
		gCamToastGui.DisplayOrder = 650
		gCamToastGui.Parent = PlayerGui

		frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5, 0)
		frame.Position = UDim2.new(0.5, 0, 0, -60)
		frame.AutomaticSize = Enum.AutomaticSize.X
		frame.Size = UDim2.fromOffset(0, 38)
		frame.BackgroundColor3 = Colors.Ink
		frame.BackgroundTransparency = 0.08
		frame.Parent = gCamToastGui
		corner(frame, 3) -- inferred equivalent call
		stroke(frame, Colors.Paper, 1.5, 0.15) -- inferred equivalent call
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingLeft = UDim.new(0, 16)
		uiPadding.PaddingRight = UDim.new(0, 16)
		uiPadding.Parent = frame
		local parent = frame
		local gothamBold = Enum.Font.GothamBold
		local paper = Colors.Paper
		local text2 = Instance.new("TextLabel")
		text2.Name = "Text"
		text2.BackgroundTransparency = 1
		text2.Font = gothamBold
		text2.TextSize = 13
		text2.TextColor3 = paper
		text2.Text = ""
		text2.Parent = parent

		v12 = text2
		v12.AutomaticSize = Enum.AutomaticSize.X
		v12.Size = UDim2.fromScale(0, 1)
	end

	count2 += 1
	local v13 = count2
	v12.Text = text
	v12.TextColor3 = p and Colors.Red or Colors.Paper
	TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0, 22)
	}):Play()
	task.delay(2.6, function()
		if v13 == count2 then
			TweenService:Create(frame, TweenInfo.new(0.25), { Position = UDim2.new(0.5, 0, 0, -60) }):Play()
		end
	end)
end

local function shareRemote() -- 1 equivalent call inferred from this helper
	local gCamRemotes = ReplicatedStorage:FindFirstChild("GCamRemotes")
	return gCamRemotes and gCamRemotes:FindFirstChild("ShareSend")
end

local v13 = {}
local userIdSet = {}
local v14 = {}
local v15 = ""
local v16 = nil
local v17 = nil
local v18 = nil
local v19 = {}
local v20 = nil

local function nearbyPlayers()
	local result = {}
	local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return result
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then
			continue
		end

		local humanoidRootPart2 = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart2 then
			continue
		end

		local magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude

		if magnitude <= GCamConfig.SHARE_RANGE then
			table.insert(result, { player = player, distance = magnitude })
		end
	end

	table.sort(result, function(a, b): boolean
		return a.distance < b.distance
	end)

	return result
end

local success, result = pcall(function()
	return require(script.Parent:WaitForChild("SongListUI", 5):WaitForChild("Theme", 5))
end)

local v21 = (not success or typeof(result) ~= "table") and {
	Colors = {
		Background = Color3.fromRGB(18, 18, 20),
		Surface = Color3.fromRGB(28, 28, 31),
		SurfaceHover = Color3.fromRGB(36, 36, 40),
		SurfaceSelected = Color3.fromRGB(42, 39, 30),
		Border = Color3.fromRGB(50, 50, 55),
		BorderHover = Color3.fromRGB(70, 70, 76),
		TextPrimary = Color3.fromRGB(240, 240, 242),
		TextSecondary = Color3.fromRGB(150, 150, 155),
		TextDisabled = Color3.fromRGB(120, 120, 125),
		Accent = Color3.fromRGB(240, 180, 70),
		AccentText = Color3.fromRGB(25, 20, 10),
		Success = Color3.fromRGB(88, 210, 150),
		Danger = Color3.fromRGB(235, 90, 90)
	},
	Fonts = {
		Regular = Enum.Font.Gotham,
		Medium = Enum.Font.GothamMedium,
		Bold = Enum.Font.GothamBold
	}
} or result

local colors = v21.Colors
local fonts = v21.Fonts

local function styleThemedButton(instance, p, p2)
	if p == "primary" and p2 ~= false then
		instance.BackgroundColor3 = colors.Accent
		instance.TextColor3 = colors.AccentText
	else
		instance.BackgroundColor3 = colors.Surface
		instance.TextColor3 = p2 == false and colors.TextDisabled or colors.TextPrimary
	end

	instance:SetAttribute("BaseColor", instance.BackgroundColor3)
end

local function themedButton(parent, text, p, size)
	local textButton = Instance.new("TextButton")
	textButton.AutoButtonColor = false
	textButton.Text = text
	textButton.Font = fonts.Bold
	textButton.TextSize = 12
	textButton.Size = size
	textButton.BorderSizePixel = 0
	textButton.Parent = parent
	corner(textButton) -- inferred equivalent call
	local uiStroke = stroke(textButton, colors.Border, nil, 0.3) -- inferred equivalent call

	if p == "primary" then
		textButton.BackgroundColor3 = colors.Accent
		textButton.TextColor3 = colors.AccentText
	else
		textButton.BackgroundColor3 = colors.Surface
		textButton.TextColor3 = colors.TextPrimary
	end

	textButton:SetAttribute("BaseColor", textButton.BackgroundColor3)

	textButton.MouseEnter:Connect(function()
		local baseColor = textButton:GetAttribute("BaseColor") or textButton.BackgroundColor3
		textButton.BackgroundColor3 = baseColor:Lerp(Color3.new(1, 1, 1), 0.08)
		uiStroke.Color = colors.BorderHover
	end)
	textButton.MouseLeave:Connect(function()
		textButton.BackgroundColor3 = textButton:GetAttribute("BaseColor") or textButton.BackgroundColor3
		uiStroke.Color = colors.Border
	end)
	return textButton
end

local function refreshShareFooter(list)
	if not v16 then
		return
	end

	local v22 = v10 and v11[v10.id] or {}
	local count3 = 0
	local count4 = 0

	for _, item in ipairs(list) do
		local userId = item.player.UserId

		if v22[userId] then
			continue
		end

		count3 += 1

		if v13[userId] then
			count4 += 1
		end
	end

	v16.Text = count4 > 0 and "Send to " .. count4 or "Send"
	local v23 = v16
	local v24 = count4 > 0

	if v24 == false then
		v23.BackgroundColor3 = colors.Surface
		v23.TextColor3 = false == false and colors.TextDisabled or colors.TextPrimary
	else
		v23.BackgroundColor3 = colors.Accent
		v23.TextColor3 = colors.AccentText
	end

	v23:SetAttribute("BaseColor", v23.BackgroundColor3)

	v17.Text = count3 > 0 and count4 == count3 and "Select none" or "Select all"
	v17.Visible = count3 > 0
end

local function refreshShareList(p)
	if not scrollingFrame then
		return
	end

	local v22 = nearbyPlayers()
	v19 = v22
	local v23 = v10 and v11[v10.id] or {}

	local v24 = {}

	for _, v25 in ipairs(v22) do
		table.insert(v24, v25.player.UserId .. (v23[v25.player.UserId] and "s" or ""))
	end

	local joined = table.concat(v24, ",")

	if p or joined ~= v15 then
		v15 = joined

		for _, guiObject in ipairs(scrollingFrame:GetChildren()) do
			if guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end

		table.clear(v14)

		if #v22 == 0 then
			local textLabel = Instance.new("TextLabel")
			textLabel.BackgroundTransparency = 1
			textLabel.Size = UDim2.new(1, 0, 0, 90)
			textLabel.Font = fonts.Regular
			textLabel.TextSize = 13
			textLabel.TextWrapped = true
			textLabel.TextColor3 = colors.TextSecondary
			textLabel.Text = "Nobody is close enough.\nWalk up to a player to share this photo (within " .. GCamConfig.SHARE_RANGE .. " studs)."
			textLabel.Parent = scrollingFrame
			refreshShareFooter(v22)
		else
			for i, v25 in ipairs(v22) do
				local player = v25.player
				local userId = player.UserId

				if not userIdSet[userId] then
					userIdSet[userId] = true
					v13[userId] = true
				end

				local v26 = v23[userId] == true

				local textButton = Instance.new("TextButton")
				textButton.Name = "Row_" .. userId
				textButton.Text = ""
				textButton.AutoButtonColor = false
				textButton.LayoutOrder = i
				textButton.Size = UDim2.new(1, 0, 0, 46)
				textButton.BackgroundColor3 = colors.Surface
				textButton.BackgroundTransparency = v26 and 0.4 or 0
				textButton.BorderSizePixel = 0
				textButton.Parent = scrollingFrame
				corner(textButton) -- inferred equivalent call
				local uiStroke = stroke(textButton, colors.Border, nil, 0.3) -- inferred equivalent call

				local function paintRow(p2) -- 4 equivalent calls inferred from this helper
					local v27

					if v13[userId] == true then
						v27 = not v26
					else
						v27 = false
					end

					textButton.BackgroundColor3 = v27 and colors.SurfaceSelected
						or p2 and colors.SurfaceHover
						or colors.Surface
					uiStroke.Color = v27 and colors.Accent or p2 and colors.BorderHover or colors.Border
					uiStroke.Transparency = v27 and 0.35 or 0.3
				end

				local box = Instance.new("Frame")
				box.Name = "Box"
				box.Position = UDim2.fromOffset(12, 13)
				box.Size = UDim2.fromOffset(20, 20)
				box.BackgroundColor3 = colors.Background
				box.BorderSizePixel = 0
				box.Parent = textButton
				corner(box) -- inferred equivalent call
				local uiStroke2 = stroke(box, colors.BorderHover) -- inferred equivalent call

				local mark = Instance.new("Frame")
				mark.Name = "Mark"
				mark.BackgroundTransparency = 1
				mark.Size = UDim2.fromScale(1, 1)
				mark.Parent = box
				local function checkStroke(p2, p3, p4, rotation)
					local frame2 = Instance.new("Frame")
					frame2.AnchorPoint = Vector2.new(0.5, 0.5)
					frame2.Position = UDim2.fromOffset(p2, p3)
					frame2.Size = UDim2.fromOffset(2.5, p4)
					frame2.Rotation = rotation
					frame2.BackgroundColor3 = colors.AccentText
					frame2.BorderSizePixel = 0
					frame2.Parent = mark
					corner(frame2, 2) -- inferred equivalent call
				end
				checkStroke(6.6, 12.4, 6.5, -45)
				checkStroke(11.6, 9.8, 12, 45)

				local function paintBox() -- 2 equivalent calls inferred from this helper
					local visible

					if v13[userId] == true then
						visible = not v26
					else
						visible = false
					end

					mark.Visible = visible
					box.BackgroundColor3 = visible and colors.Accent or colors.Background
					uiStroke2.Color = visible and colors.Accent or colors.BorderHover
				end

				paintBox() -- inferred equivalent call
				paintRow(false) -- inferred equivalent call
				local imageLabel3 = Instance.new("ImageLabel")
				imageLabel3.BackgroundColor3 = colors.Background
				imageLabel3.Position = UDim2.fromOffset(44, 9)
				imageLabel3.Size = UDim2.fromOffset(28, 28)
				imageLabel3.Parent = textButton
				corner(imageLabel3, 14) -- inferred equivalent call
				task.spawn(function()
					local success2, result2 = pcall(function()
						return Players:GetUserThumbnailAsync(
							userId,
							Enum.ThumbnailType.HeadShot,
							Enum.ThumbnailSize.Size48x48
						)
					end)

					if success2 and imageLabel3.Parent then
						imageLabel3.Image = result2
					end
				end)

				local displayName = player.DisplayName
				local medium = fonts.Medium
				local textPrimary = colors.TextPrimary
				local name = Instance.new("TextLabel")
				name.Name = "Name"
				name.BackgroundTransparency = 1
				name.Font = medium
				name.TextSize = 13
				name.TextColor3 = textPrimary
				name.Text = displayName
				name.Parent = textButton

				name.TextXAlignment = Enum.TextXAlignment.Left
				name.TextTruncate = Enum.TextTruncate.AtEnd
				name.Position = UDim2.fromOffset(82, 6)
				name.Size = UDim2.new(1, -150, 0, 18)

				local text = string.format("%d studs away", (math.floor(v25.distance + 0.5)))
				local regular = fonts.Regular
				local textSecondary = colors.TextSecondary
				local distance = Instance.new("TextLabel")
				distance.Name = "Distance"
				distance.BackgroundTransparency = 1
				distance.Font = regular
				distance.TextSize = 11
				distance.TextColor3 = textSecondary
				distance.Text = text
				distance.Parent = textButton

				distance.TextXAlignment = Enum.TextXAlignment.Left
				distance.Position = UDim2.fromOffset(82, 24)
				distance.Size = UDim2.new(1, -150, 0, 14)

				if v26 then
					local bold = fonts.Bold
					local success2 = colors.Success
					local sent = Instance.new("TextLabel")
					sent.Name = "Sent"
					sent.BackgroundTransparency = 1
					sent.Font = bold
					sent.TextSize = 11
					sent.TextColor3 = success2
					sent.Text = "Sent"
					sent.Parent = textButton

					sent.AnchorPoint = Vector2.new(1, 0.5)
					sent.Position = UDim2.new(1, -12, 0.5, 0)
					sent.Size = UDim2.fromOffset(60, 16)
					sent.TextXAlignment = Enum.TextXAlignment.Right
				else
					textButton.MouseEnter:Connect(function()
						paintRow(true) -- inferred equivalent call
					end)
					textButton.MouseLeave:Connect(function()
						paintRow(false) -- inferred equivalent call
					end)
					textButton.MouseButton1Click:Connect(function()
						v13[userId] = not v13[userId]
						paintBox() -- inferred equivalent call
						paintRow(true) -- inferred equivalent call
						refreshShareFooter(v19)
					end)
				end

				v14[userId] = { distance = distance }
			end

			refreshShareFooter(v22)
		end
	else
		for _, v25 in ipairs(v22) do
			local v26 = v14[v25.player.UserId]

			if v26 then
				v26.distance.Text = string.format("%d studs away", (math.floor(v25.distance + 0.5)))
			end
		end

		refreshShareFooter(v22)
	end
end

local function buildShare()
	gCamShareGui = Instance.new("ScreenGui")
	gCamShareGui.Name = "GCamShareGui"
	gCamShareGui.ResetOnSpawn = false
	gCamShareGui.IgnoreGuiInset = true
	gCamShareGui.DisplayOrder = 560
	gCamShareGui.Enabled = false
	gCamShareGui.Parent = PlayerGui

	local textButton = Instance.new("TextButton")
	textButton.Text = ""
	textButton.AutoButtonColor = false
	textButton.Selectable = false
	textButton.Size = UDim2.fromScale(1, 1)
	textButton.BackgroundColor3 = Color3.new(0, 0, 0)
	textButton.BackgroundTransparency = 0.45
	textButton.Parent = gCamShareGui
	textButton.MouseButton1Click:Connect(function()
		GCamGalleryUI.CloseSharePicker()
	end)

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromOffset(360, 440)
	panel.BackgroundColor3 = colors.Background
	panel.BorderSizePixel = 0
	panel.Parent = gCamShareGui
	corner(panel, 8) -- inferred equivalent call
	stroke(panel, colors.Border) -- inferred equivalent call

	local bold = fonts.Bold
	local textPrimary = colors.TextPrimary
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Font = bold
	title.TextSize = 16
	title.TextColor3 = textPrimary
	title.Text = "Share photo"
	title.Parent = panel

	v9 = title
	v9.Size = UDim2.new(1, -60, 0, 22)
	v9.Position = UDim2.fromOffset(16, 14)
	v9.TextXAlignment = Enum.TextXAlignment.Left

	local text = "Players within " .. GCamConfig.SHARE_RANGE .. " studs. Untick to skip someone."
	local regular = fonts.Regular
	local textSecondary = colors.TextSecondary
	local hint = Instance.new("TextLabel")
	hint.Name = "Hint"
	hint.BackgroundTransparency = 1
	hint.Font = regular
	hint.TextSize = 11
	hint.TextColor3 = textSecondary
	hint.Text = text
	hint.Parent = panel

	v18 = hint
	v18.Size = UDim2.new(1, -32, 0, 28)
	v18.Position = UDim2.fromOffset(16, 38)
	v18.TextXAlignment = Enum.TextXAlignment.Left
	v18.TextYAlignment = Enum.TextYAlignment.Top
	v18.TextWrapped = true

	local v22 = themedButton(panel, "X", "secondary", UDim2.fromOffset(24, 24))
	v22.AnchorPoint = Vector2.new(1, 0)
	v22.Position = UDim2.new(1, -12, 0, 12)
	v22.TextSize = 12
	v22.MouseButton1Click:Connect(function()
		GCamGalleryUI.CloseSharePicker()
	end)

	local frame2 = Instance.new("Frame")
	frame2.BackgroundColor3 = colors.Border
	frame2.BorderSizePixel = 0
	frame2.Position = UDim2.fromOffset(0, 72)
	frame2.Size = UDim2.new(1, 0, 0, 1)
	frame2.Parent = panel

	scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.Position = UDim2.fromOffset(12, 84)
	scrollingFrame.Size = UDim2.new(1, -24, 1, -152)
	scrollingFrame.ScrollBarThickness = 3
	scrollingFrame.ScrollBarImageColor3 = colors.BorderHover
	scrollingFrame.CanvasSize = UDim2.new()
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.Parent = panel
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 6)
	uiListLayout.Parent = scrollingFrame

	local frame3 = Instance.new("Frame")
	frame3.BackgroundColor3 = colors.Border
	frame3.BorderSizePixel = 0
	frame3.AnchorPoint = Vector2.new(0, 1)
	frame3.Position = UDim2.new(0, 0, 1, -56)
	frame3.Size = UDim2.new(1, 0, 0, 1)
	frame3.Parent = panel

	v17 = themedButton(panel, "Select all", "secondary", UDim2.fromOffset(120, 34))
	v17.AnchorPoint = Vector2.new(0, 1)
	v17.Position = UDim2.new(0, 12, 1, -12)
	v17.MouseButton1Click:Connect(function()
		local v23 = v10 and v11[v10.id] or {}
		local v24 = true

		for _, v25 in ipairs(v19) do
			local userId = v25.player.UserId

			if not (v23[userId] or v13[userId]) then
				v24 = false
			end
		end

		for _, v25 in ipairs(v19) do
			local userId = v25.player.UserId

			if not v23[userId] then
				v13[userId] = not v24
			end
		end

		refreshShareList(true)
	end)

	v16 = themedButton(panel, "Send", "primary", UDim2.fromOffset(150, 34))
	v16.AnchorPoint = Vector2.new(1, 1)
	v16.Position = UDim2.new(1, -12, 1, -12)
	v16.MouseButton1Click:Connect(function()
		if not (v10 and v10.recipe) then
			GCamGalleryUI.Toast("Can't share this photo", true)
			return
		end

		v11[v10.id] = v11[v10.id] or {}
		local v23 = v11[v10.id]
		local userIds = {}

		for _, v24 in ipairs(v19) do
			local userId = v24.player.UserId

			if not v13[userId] or v23[userId] then
				continue
			end

			table.insert(userIds, userId)
		end

		if #userIds == 0 then
			GCamGalleryUI.Toast("Tick at least one player", true)
			return
		end

		if os.clock() - lastTime < GCamConfig.SHARE_COOLDOWN then
			GCamGalleryUI.Toast("Slow down - one photo at a time", true)
			return
		end

		local v24 = shareRemote() -- inferred equivalent call

		if not v24 then
			GCamGalleryUI.Toast("Can't share this photo", true)
			return
		end

		lastTime = os.clock()
		v20 = { photoId = v10.id, ids = userIds }
		v24:FireServer(userIds, v10.recipe)

		for _, v25 in ipairs(userIds) do
			v23[v25] = true
		end

		refreshShareList(true)
	end)

	local gCamRemotes = ReplicatedStorage:FindFirstChild("GCamRemotes")
	local shareResult = gCamRemotes and gCamRemotes:FindFirstChild("ShareResult")

	if shareResult then
		shareResult.OnClientEvent:Connect(function(list)
			local v23 = v20

			if not v23 or typeof(list) ~= "table" then
				return
			end

			v20 = nil
			local set = {}

			for _, item in ipairs(list) do
				set[item] = true
			end

			local v24 = v11[v23.photoId]

			if v24 then
				for _, id in ipairs(v23.ids) do
					if set[id] then
						continue
					end

					v24[id] = nil
					v13[id] = true
				end
			end

			if #list > 0 then
				GCamGalleryUI.Toast(#list == 1 and "Sent to 1 player" or "Sent to " .. #list .. " players")
			end

			refreshShareList(true)
		end)
	end

	task.spawn(function()
		while gCamShareGui and gCamShareGui.Parent do
			task.wait(0.6)

			if gCamShareGui.Enabled then
				refreshShareList(false)
			end
		end
	end)
end

function GCamGalleryUI.OpenSharePicker(p)
	if not p then
		return
	end

	if not gCamShareGui then
		buildShare()
	end

	v10 = p
	refreshShareList(true)
	gCamShareGui.Enabled = true

	if not v2 then
		v2 = true
		SessionCameraSettings.SetMenuOpen(true)
		RunService:BindToRenderStep("GCamGalleryMouse", Enum.RenderPriority.Camera.Value + 2, function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		end)
	end

	local folder = gCamShareGui

	if isGamepadInput() then -- inferred equivalent call
		if not folder then
			return
		end

		task.defer(function()
			local selectedObject = nil

			for _, button2 in ipairs(folder:GetDescendants()) do
				if not (button2:IsA("TextButton") and button2.Visible and button2.Selectable) then
					continue
				end

				if string.sub(button2.Name, 1, 6) == "Photo_" then
					GuiService.SelectedObject = button2
					return
				end

				selectedObject = selectedObject or button2
			end

			if selectedObject then
				GuiService.SelectedObject = selectedObject
			end
		end)
	end
end

function GCamGalleryUI.CloseSharePicker()
	if gCamShareGui then
		gCamShareGui.Enabled = false
	end

	v10 = nil

	if not flag then
		GCamGalleryUI.ReleaseMenuIfIdle()
	end
end

local v22 = false
function GCamGalleryUI.SetExternalHold(p)
	v22 = p
end

function GCamGalleryUI.ReleaseMenuIfIdle()
	if
		not (flag or gCamShareGui and gCamShareGui.Enabled)
		and not (gCamFullscreenGui and gCamFullscreenGui.Enabled)
		and v2
	then
		v2 = false
		SessionCameraSettings.SetMenuOpen(false)
		pcall(function()
			RunService:UnbindFromRenderStep("GCamGalleryMouse")
		end)
	end
end

local slotPicker = nil
local permanentStrip = nil
local v23 = {}

local function pickFont(p, p2) -- 2 equivalent calls inferred from this helper
	local success2, result2 = pcall(function()
		return Enum.Font[p]
	end)
	return success2 and result2 or p2
end

local GothamBold = Enum.Font.GothamBold
GothamBold = pickFont("PermanentMarker", GothamBold) -- inferred equivalent call
local Code = Enum.Font.Code
Code = pickFont("SpecialElite", Code) -- inferred equivalent call
local color = Color3.fromRGB(98, 70, 46)
local color2 = Color3.fromRGB(40, 26, 14)
local color3 = Color3.fromRGB(214, 198, 138)
local color4 = Color3.fromRGB(226, 182, 70)
local color5 = Color3.fromRGB(120, 124, 128)
local color6 = Color3.fromRGB(236, 230, 214)
local color7 = Color3.fromRGB(190, 176, 146)
local color8 = Color3.fromRGB(26, 22, 20)

local function rect(decor, p, p2, integer, p3, backgroundColor, value, value2) -- 8 equivalent calls inferred from this helper
	local frame2 = Instance.new("Frame")
	frame2.BackgroundColor3 = backgroundColor
	frame2.BackgroundTransparency = value or 0
	frame2.BorderSizePixel = 0
	frame2.Position = UDim2.fromOffset(p, p2)
	frame2.Size = UDim2.fromOffset(integer, p3)
	frame2.Rotation = value2 or 0
	frame2.Parent = decor
	return frame2
end

local function tape(parent, p, p2, p3, p4, value, p5, p6)
	local parent3 = rect(parent, p, p2, p3, p4, p6 or p5 and color5 or color3, 0.12, value) -- inferred equivalent call
	parent3.ZIndex = 9
	stroke(parent3, p5 and Color3.fromRGB(60, 62, 64) or Color3.fromRGB(150, 128, 80), nil, 0.55) -- inferred equivalent call
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.12),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(1, 0.2)
	})

	uiGradient.Parent = parent3
	return parent3
end

local function pushPin(parent, p, p2)
	local parent3 = rect(parent, p, p2, 18, 18, Color3.fromRGB(170, 36, 32), nil) -- inferred equivalent call
	parent3.ZIndex = 9
	corner(parent3, 9) -- inferred equivalent call
	stroke(parent3, Color3.fromRGB(60, 10, 10), 2, 0.1) -- inferred equivalent call
	local parent4 = rect(parent3, 4, 3, 5, 5, Color3.fromRGB(240, 150, 140), 0.2) -- inferred equivalent call
	parent4.ZIndex = 10
	corner(parent4, 3) -- inferred equivalent call
	return parent3
end

local function markLabel(parent, text, textSize, textColor, p) -- 19 equivalent calls inferred from this helper
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Font = p or GothamBold
	textLabel.TextSize = textSize
	textLabel.TextColor3 = textColor
	textLabel.Text = text
	textLabel.Parent = parent
	return textLabel
end

local function tapeButton(parent, text, p, backgroundColor, textColor)
	local textButton = Instance.new("TextButton")
	textButton.Text = text
	textButton.AutoButtonColor = false
	textButton.Font = GothamBold
	textButton.TextSize = 14
	textButton.TextColor3 = textColor
	textButton.BackgroundColor3 = backgroundColor
	textButton.BorderSizePixel = 0
	textButton.Size = UDim2.fromOffset(p, 32)
	textButton.Parent = parent
	corner(textButton, 1) -- inferred equivalent call
	stroke(textButton, Color3.fromRGB(70, 58, 34), nil, 0.5) -- inferred equivalent call
	textButton.MouseEnter:Connect(function()
		textButton.BackgroundColor3 = backgroundColor:Lerp(Color3.new(1, 1, 1), 0.18)
	end)
	textButton.MouseLeave:Connect(function()
		textButton.BackgroundColor3 = backgroundColor
	end)
	return textButton
end

local function permanentRemote() -- 2 equivalent calls inferred from this helper
	local gCamRemotes = ReplicatedStorage:FindFirstChild("GCamRemotes")
	return gCamRemotes and gCamRemotes:FindFirstChild("Permanent")
end

function GCamGalleryUI.SaveToSlot(data, p)
	local v24 = permanentRemote() -- inferred equivalent call

	if v24 and data and data.recipe then
		task.spawn(function()
			local success2, result2 = pcall(function()
				return v24:InvokeServer("Save", p, data.recipe, {
					fromName = data.fromName,
					ts = data.ts
				})
			end)

			if not success2 or typeof(result2) ~= "table" or not result2.ok then
				GCamGalleryUI.Toast(
					success2 and typeof(result2) == "table" and result2.message or "Couldn't save this photo",
					true
				)
				return
			end

			GCamGalleryStore.SetPermanent(p, {
				id = GCamGalleryStore.NewId(),
				content = data.content,
				recipe = data.recipe,
				ts = data.ts,
				fromName = data.fromName,
				undeveloped = data.content == nil or nil
			})

			GCamGalleryUI.Toast("Kept forever in slot " .. p)
		end)
	else
		GCamGalleryUI.Toast("Permanent photos aren't available", true)
	end
end

function GCamGalleryUI.RemoveSlot(p)
	local v24 = permanentRemote() -- inferred equivalent call

	if v24 then
		task.spawn(function()
			local success2, result2 = pcall(function()
				return v24:InvokeServer("Remove", p)
			end)

			if not success2 or typeof(result2) ~= "table" or not result2.ok then
				GCamGalleryUI.Toast(
					success2 and typeof(result2) == "table" and result2.message or "Couldn't remove this photo",
					true
				)
				return
			end

			GCamGalleryStore.SetPermanent(p, nil)
			GCamGalleryUI.Toast("Removed from slot " .. p)
		end)
	else
		GCamGalleryUI.Toast("Permanent photos aren't available", true)
	end
end

local function showViewer(p)
	local v24 = GCamGalleryStore.GetById(p)

	if v24 then
		v = p
		viewer.Visible = true
		local text = photoCaption(v24)

		if v24.slot then
			text = "PERMANENT  •  SLOT " .. v24.slot .. "  •  " .. text
		end

		caption.Text = text

		if v24.content then
			imageLabel.Image = v24.content
			status.Visible = false
		else
			imageLabel.Image = ""
			status.Visible = true
			status.Text = v24.failed and "lost in the post" or "developing..."
		end

		if v23.forever then
			v23.forever.Visible = v24.slot == nil
			v23.delete.Text = v24.slot and "REMOVE FROM SLOT" or "DELETE"
			v23.delete.Size = UDim2.fromOffset(v24.slot and 156 or 80, 32)
		end

		local folder = viewer

		if isGamepadInput() then -- inferred equivalent call
			if not folder then
				return
			end

			task.defer(function()
				local selectedObject = nil

				for _, button2 in ipairs(folder:GetDescendants()) do
					if not (button2:IsA("TextButton") and button2.Visible and button2.Selectable) then
						continue
					end

					if string.sub(button2.Name, 1, 6) == "Photo_" then
						GuiService.SelectedObject = button2
						return
					end

					selectedObject = selectedObject or button2
				end

				if selectedObject then
					GuiService.SelectedObject = selectedObject
				end
			end)
		end
	else
		viewer.Visible = false
		v = nil
	end
end

local function stepViewer(p)
	local all = GCamGalleryStore.GetAll()

	for i, v24 in ipairs(all) do
		if v24.id == v then
			local v25 = all[i + p]

			if v25 then
				showViewer(v25.id)
			end

			break
		end
	end
end

local function buildPicker()
	slotPicker = Instance.new("Frame")
	slotPicker.Name = "SlotPicker"
	slotPicker.Size = UDim2.fromScale(1, 1)
	slotPicker.BackgroundColor3 = Color3.new(0, 0, 0)
	slotPicker.BackgroundTransparency = 0.4
	slotPicker.BorderSizePixel = 0
	slotPicker.ZIndex = 40
	slotPicker.Visible = false
	slotPicker.Parent = board
	corner(slotPicker, 6) -- inferred equivalent call
	local textButton = Instance.new("TextButton")
	textButton.Text = ""
	textButton.AutoButtonColor = false
	textButton.Selectable = false
	textButton.BackgroundTransparency = 1
	textButton.Size = UDim2.fromScale(1, 1)
	textButton.ZIndex = 40
	textButton.Parent = slotPicker
	textButton.MouseButton1Click:Connect(function()
		slotPicker.Visible = false
	end)

	local note = Instance.new("Frame")
	note.Name = "Note"
	note.AnchorPoint = Vector2.new(0.5, 0.5)
	note.Position = UDim2.fromScale(0.5, 0.5)
	note.Size = UDim2.fromOffset(500, 250)
	note.BackgroundColor3 = colors.Background
	note.BorderSizePixel = 0
	note.ZIndex = 41
	note.Parent = slotPicker
	corner(note, 8) -- inferred equivalent call
	stroke(note, colors.Border) -- inferred equivalent call

	local title = markLabel(note, "Keep forever", 16, colors.TextPrimary, fonts.Bold) -- inferred equivalent call
	title.Name = "Title"
	title.Position = UDim2.fromOffset(18, 14)
	title.Size = UDim2.new(1, -36, 0, 22)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 42
	local sub = markLabel( -- inferred equivalent call
		note,
		"Pick a slot. The photo stays after you leave the server.",
		11,
		colors.TextSecondary,
		fonts.Regular
	)
	sub.Name = "Sub"
	sub.Position = UDim2.fromOffset(18, 38)
	sub.Size = UDim2.new(1, -36, 0, 16)
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.ZIndex = 42

	local frame2 = Instance.new("Frame")
	frame2.BackgroundColor3 = colors.Border
	frame2.BorderSizePixel = 0
	frame2.Position = UDim2.fromOffset(0, 62)
	frame2.Size = UDim2.new(1, 0, 0, 1)
	frame2.ZIndex = 42
	frame2.Parent = note

	local slots = Instance.new("Frame")
	slots.Name = "Slots"
	slots.BackgroundTransparency = 1
	slots.AnchorPoint = Vector2.new(0.5, 0)
	slots.Position = UDim2.new(0.5, 0, 0, 76)
	slots.Size = UDim2.fromOffset(464, 120)
	slots.ZIndex = 42
	slots.Parent = note
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.Padding = UDim.new(0, 10)
	uiListLayout.Parent = slots

	local v24 = themedButton(note, "Cancel", "secondary", UDim2.fromOffset(90, 30))
	v24.AnchorPoint = Vector2.new(1, 1)
	v24.Position = UDim2.new(1, -16, 1, -14)
	v24.ZIndex = 43
	v24.MouseButton1Click:Connect(function()
		slotPicker.Visible = false
	end)
end

local function fn(p)
	if not slotPicker then
		buildPicker()
	end

	local slots = slotPicker.Note.Slots

	for _, guiObject in ipairs(slots:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	if GCamGalleryStore.IsPermanentAvailable() then
		for i = 1, GCamConfig.PERMANENT_SLOTS do
			local v24 = GCamGalleryStore.GetPermanent()[i]
			local textButton = Instance.new("TextButton")
			textButton.Name = "Slot_" .. i
			textButton.Text = ""
			textButton.AutoButtonColor = false
			textButton.Size = UDim2.fromOffset(148, 118)
			textButton.BackgroundColor3 = colors.Surface
			textButton.BorderSizePixel = 0
			textButton.ZIndex = 43
			textButton.Parent = slots
			corner(textButton) -- inferred equivalent call
			local uiStroke = stroke(textButton, colors.Border, nil, 0.3) -- inferred equivalent call

			local imageLabel3 = Instance.new("ImageLabel")
			imageLabel3.Position = UDim2.fromOffset(6, 6)
			imageLabel3.Size = UDim2.new(1, -12, 0, 66)
			imageLabel3.BackgroundColor3 = colors.Background
			imageLabel3.BorderSizePixel = 0
			imageLabel3.ScaleType = Enum.ScaleType.Crop
			imageLabel3.Image = v24 and v24.content or ""
			imageLabel3.ZIndex = 44
			imageLabel3.Parent = textButton
			corner(imageLabel3, 3) -- inferred equivalent call

			if not v24 then
				local textLabel = markLabel(imageLabel3, "Empty", 12, colors.TextDisabled, fonts.Medium) -- inferred equivalent call
				textLabel.Size = UDim2.fromScale(1, 1)
				textLabel.ZIndex = 45
			end

			local textLabel2 = markLabel(textButton, "Slot " .. i, 12, colors.TextPrimary, fonts.Bold) -- inferred equivalent call
			textLabel2.Position = UDim2.fromOffset(10, 78)
			textLabel2.Size = UDim2.new(1, -20, 0, 16)
			textLabel2.TextXAlignment = Enum.TextXAlignment.Left
			textLabel2.ZIndex = 44
			local danger = v24 and colors.Danger or colors.TextSecondary
			local regular = fonts.Regular
			local textLabel = Instance.new("TextLabel")
			textLabel.BackgroundTransparency = 1
			textLabel.Font = regular or GothamBold
			textLabel.TextSize = 11
			textLabel.TextColor3 = danger
			textLabel.Text = v24 and "Replace current photo" or "Use this slot"
			textLabel.Parent = textButton

			textLabel.Position = UDim2.fromOffset(10, 95)
			textLabel.Size = UDim2.new(1, -20, 0, 14)
			textLabel.TextXAlignment = Enum.TextXAlignment.Left
			textLabel.ZIndex = 44

			textButton.MouseEnter:Connect(function()
				textButton.BackgroundColor3 = colors.SurfaceHover
				uiStroke.Color = colors.Accent
				uiStroke.Transparency = 0
			end)
			textButton.MouseLeave:Connect(function()
				textButton.BackgroundColor3 = colors.Surface
				uiStroke.Color = colors.Border
				uiStroke.Transparency = 0.3
			end)
			textButton.MouseButton1Click:Connect(function()
				slotPicker.Visible = false
				GCamGalleryUI.SaveToSlot(p, i)
			end)
		end
	else
		local textLabel = markLabel( -- inferred equivalent call
			slots,
			"Permanent photos are unavailable right now.\n(The saved-data service is offline.)",
			13,
			colors.TextSecondary,
			fonts.Regular
		)
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.ZIndex = 43
		textLabel.TextWrapped = true
	end

	slotPicker.Visible = true
	local folder = slotPicker

	if isGamepadInput() then -- inferred equivalent call
		if not folder then
			return
		end

		task.defer(function()
			local selectedObject = nil

			for _, button2 in ipairs(folder:GetDescendants()) do
				if not (button2:IsA("TextButton") and button2.Visible and button2.Selectable) then
					continue
				end

				if string.sub(button2.Name, 1, 6) == "Photo_" then
					GuiService.SelectedObject = button2
					return
				end

				selectedObject = selectedObject or button2
			end

			if selectedObject then
				GuiService.SelectedObject = selectedObject
			end
		end)
	end
end

local function buildViewer()
	viewer = Instance.new("Frame")
	viewer.Name = "Viewer"
	viewer.Size = UDim2.fromScale(1, 1)
	viewer.BackgroundColor3 = Color3.fromRGB(14, 9, 5)
	viewer.BackgroundTransparency = 0.25
	viewer.BorderSizePixel = 0
	viewer.ZIndex = 20
	viewer.Visible = false
	viewer.Parent = board
	corner(viewer, 6) -- inferred equivalent call
	local backdrop = Instance.new("TextButton")
	backdrop.Name = "Backdrop"
	backdrop.Text = ""
	backdrop.AutoButtonColor = false
	backdrop.Selectable = false
	backdrop.BackgroundTransparency = 1
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.ZIndex = 20
	backdrop.Parent = viewer
	backdrop.MouseButton1Click:Connect(function()
		viewer.Visible = false
		v = nil
	end)

	local frame2 = rect(viewer, 116, 26, 560, 440, Color3.new(0, 0, 0), 0.55, -1) -- inferred equivalent call
	frame2.ZIndex = 21
	local polaroid = Instance.new("Frame")
	polaroid.Name = "Polaroid"
	polaroid.AnchorPoint = Vector2.new(0.5, 0)
	polaroid.Position = UDim2.new(0.5, 0, 0, 20)
	polaroid.Size = UDim2.fromOffset(560, 440)
	polaroid.Rotation = -1
	polaroid.BackgroundColor3 = color6
	polaroid.BorderSizePixel = 0
	polaroid.ZIndex = 22
	polaroid.Parent = viewer
	corner(polaroid, 2) -- inferred equivalent call
	stroke(polaroid, Color3.fromRGB(60, 54, 44), nil, 0.5) -- inferred equivalent call
	tape(polaroid, -16, -8, 70, 20, -12)
	tape(polaroid, 506, -8, 70, 20, 10)

	imageLabel = Instance.new("ImageLabel")
	imageLabel.Position = UDim2.fromOffset(14, 16)
	imageLabel.Size = UDim2.new(1, -28, 1, -70)
	imageLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	imageLabel.BorderSizePixel = 0
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.ZIndex = 23
	imageLabel.Parent = polaroid

	status = markLabel(imageLabel, "developing...", 22, color6) -- inferred equivalent call
	status.Name = "Status"
	status.Size = UDim2.fromScale(1, 1)
	status.ZIndex = 24

	local fullscreenHit = Instance.new("TextButton")
	fullscreenHit.Name = "FullscreenHit"
	fullscreenHit.BackgroundTransparency = 1
	fullscreenHit.Text = ""
	fullscreenHit.Selectable = false
	fullscreenHit.Size = UDim2.fromScale(1, 1)
	fullscreenHit.ZIndex = 25
	fullscreenHit.Parent = imageLabel
	fullscreenHit.MouseButton1Click:Connect(function()
		local v24 = v and GCamGalleryStore.GetById(v)

		if v24 and v24.content then
			GCamGalleryUI.OpenFullscreen(v24)
		end
	end)

	caption = markLabel(polaroid, "", 15, color8) -- inferred equivalent call
	caption.Name = "Caption"
	caption.AnchorPoint = Vector2.new(0.5, 1)
	caption.Position = UDim2.new(0.5, 0, 1, -12)
	caption.Size = UDim2.new(1, -28, 0, 30)
	caption.TextTruncate = Enum.TextTruncate.AtEnd
	caption.ZIndex = 23

	local function arrow(text, p, p2, p3)
		local parent = tapeButton(viewer, text, 44, color3, color8)
		parent.AnchorPoint = Vector2.new(p2, 0.5)
		parent.Position = UDim2.new(0, p, 0, 240)
		parent.Size = UDim2.fromOffset(44, 80)
		parent.TextSize = 28
		parent.ZIndex = 26
		parent.MouseButton1Click:Connect(function()
			stepViewer(p3)
		end)
	end
	arrow("<", 38, 0.5, 1)
	arrow(">", 742, 0.5, -1)

	local buttonRow = Instance.new("Frame")
	buttonRow.Name = "ButtonRow"
	buttonRow.AnchorPoint = Vector2.new(0.5, 1)
	buttonRow.Position = UDim2.new(0.5, 0, 1, -14)
	buttonRow.Size = UDim2.fromOffset(740, 34)
	buttonRow.BackgroundTransparency = 1
	buttonRow.ZIndex = 26
	buttonRow.Parent = viewer
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.Padding = UDim.new(0, 8)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.Parent = buttonRow

	local full = tapeButton(buttonRow, "FULLSCREEN", 108, color3, color8)
	local save = tapeButton(buttonRow, "SAVE TO ROBLOX", 140, color3, color8)
	local shareButton = tapeButton(buttonRow, "SHARE", 80, Color3.fromRGB(170, 36, 32), color6)
	local foreverButton = tapeButton(buttonRow, "KEEP FOREVER", 128, color4, color8)
	local delete = tapeButton(buttonRow, "DELETE", 80, color5, Color3.fromRGB(40, 8, 8))
	local back = tapeButton(buttonRow, "BACK", 70, color7, color8)

	for i, v24 in ipairs({ full, save, shareButton, foreverButton, delete, back }) do
		v24.ZIndex = 27
		v24.LayoutOrder = i
	end

	v23 = {
		full = full,
		save = save,
		share = shareButton,
		forever = foreverButton,
		delete = delete,
		back = back
	}
	shareButton.Name = "ShareButton"
	foreverButton.Name = "ForeverButton"

	full.MouseButton1Click:Connect(function()
		local v24 = v and GCamGalleryStore.GetById(v)

		if v24 and v24.content then
			GCamGalleryUI.OpenFullscreen(v24)
		else
			GCamGalleryUI.Toast("This photo isn't ready yet", true)
		end
	end)

	back.MouseButton1Click:Connect(function()
		viewer.Visible = false
		v = nil
	end)

	delete.MouseButton1Click:Connect(function()
		local v24 = v and GCamGalleryStore.GetById(v)

		if not v24 then
			return
		end

		if v24.slot then
			GCamGalleryUI.RemoveSlot(v24.slot)
		else
			GCamGalleryStore.Remove(v24.id)
			GCamGalleryUI.Toast("Photo deleted")
		end

		viewer.Visible = false
		v = nil
	end)

	shareButton.MouseButton1Click:Connect(function()
		local v24 = v and GCamGalleryStore.GetById(v)

		if v24 then
			GCamGalleryUI.OpenSharePicker(v24)
		end
	end)

	foreverButton.MouseButton1Click:Connect(function()
		local v24 = v and GCamGalleryStore.GetById(v)

		if v24 then
			fn(v24)
		end
	end)

	save.MouseButton1Click:Connect(function()
		local v24 = v and GCamGalleryStore.GetById(v)

		if not (v24 and v24.content) then
			GCamGalleryUI.Toast("This photo isn't ready yet", true)
			return
		end

		local success2, result2 = pcall(function()
			CaptureService:PromptSaveCapturesToGallery({ v24.content }, function(options)
				local v25 = false

				for _, v26 in pairs(options or {}) do
					if v26 == Enum.CaptureSaveResult.Success then
						v25 = true
					end
				end

				GCamGalleryUI.Toast(v25 and "Saved to your Roblox gallery" or "Not saved", not v25)
			end)
		end)

		if not success2 then
			warn("[GCam] PromptSaveCapturesToGallery gagal:", result2)
			GCamGalleryUI.Toast("Saving isn't available here", true)
		end
	end)
end

local function buildPolaroid(frame2, data, rotation, p)
	local frame3 = Instance.new("Frame")
	frame3.BackgroundColor3 = Color3.new(0, 0, 0)
	frame3.BackgroundTransparency = 0.6
	frame3.BorderSizePixel = 0
	frame3.Position = UDim2.fromOffset(4, 6)
	frame3.Size = UDim2.fromScale(1, 1)
	frame3.ZIndex = 1
	frame3.Parent = frame2
	corner(frame3, 2) -- inferred equivalent call
	local textButton = Instance.new("TextButton")
	textButton.Name = "Photo_" .. data.id
	textButton.Text = ""
	textButton.AutoButtonColor = false
	textButton.BackgroundColor3 = color6
	textButton.BorderSizePixel = 0
	textButton.Size = UDim2.fromScale(1, 1)
	textButton.ZIndex = 2
	textButton.Parent = frame2
	corner(textButton, 2) -- inferred equivalent call
	local imageLabel3 = Instance.new("ImageLabel")
	imageLabel3.Position = UDim2.fromOffset(8, 8)
	imageLabel3.Size = UDim2.new(1, -16, 1, -36)
	imageLabel3.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	imageLabel3.BorderSizePixel = 0
	imageLabel3.ScaleType = Enum.ScaleType.Crop
	imageLabel3.Image = data.content or ""
	imageLabel3.ZIndex = 3
	imageLabel3.Parent = textButton

	if not data.content then
		local textLabel = markLabel(imageLabel3, data.failed and "lost in the post" or "developing...", 14, color6) -- inferred equivalent call
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.ZIndex = 4
	end

	local v24 = data.fromName and "from " .. data.fromName or formatTime(data.ts or os.time()) -- inferred equivalent call

	if p then
		v24 = "★ " .. v24
	end

	local textLabel = markLabel(textButton, v24, 12, color8) -- inferred equivalent call
	textLabel.AnchorPoint = Vector2.new(0.5, 1)
	textLabel.Position = UDim2.new(0.5, 0, 1, -4)
	textLabel.Size = UDim2.new(1, -12, 0, 20)
	textLabel.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel.ZIndex = 3

	if p then
		tape(frame2, 50, -10, 66, 20, data.id * 13 % 11 - 5, false, color4)
	elseif data.id % 2 == 0 then
		pushPin(frame2, 76, -8)
	else
		tape(frame2, 54, -10, 62, 20, data.id * 13 % 11 - 5)
	end

	textButton.MouseEnter:Connect(function()
		TweenService:Create(frame2, TweenInfo.new(0.12), { Rotation = 0 }):Play()
	end)
	textButton.MouseLeave:Connect(function()
		TweenService:Create(frame2, TweenInfo.new(0.12), { Rotation = rotation }):Play()
	end)
	textButton.MouseButton1Click:Connect(function()
		showViewer(data.id)
	end)
	return textButton
end

local function fn2()
	if not permanentStrip then
		return
	end

	local slots = permanentStrip:FindFirstChild("Slots")

	for _, guiObject in ipairs(slots:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for i = 1, GCamConfig.PERMANENT_SLOTS do
		local v24 = GCamGalleryStore.GetPermanent()[i]
		local frame2 = Instance.new("Frame")
		frame2.Name = "PermSlot_" .. i
		frame2.BackgroundTransparency = 1
		frame2.Position = UDim2.fromOffset((i - 1) * 186, 14)
		frame2.Size = UDim2.fromOffset(170, 112)
		frame2.Rotation = (i - 2) * 1.6
		frame2.Parent = slots

		if v24 then
			buildPolaroid(frame2, v24, frame2.Rotation, true)
		else
			local empty2 = Instance.new("Frame")
			empty2.Name = "Empty"
			empty2.Size = UDim2.fromScale(1, 1)
			empty2.BackgroundColor3 = Color3.fromRGB(30, 20, 12)
			empty2.BackgroundTransparency = 0.55
			empty2.BorderSizePixel = 0
			empty2.Parent = frame2
			corner(empty2, 2) -- inferred equivalent call
			local uiStroke = stroke(empty2, Color3.fromRGB(236, 224, 196), 2, 0.5) -- inferred equivalent call
			uiStroke.LineJoinMode = Enum.LineJoinMode.Miter

			local text = GCamGalleryStore.IsPermanentAvailable() and "SLOT " .. i .. "\nempty"
				or "SLOT " .. i .. "\nunavailable"

			local color9, v25 = Color3.fromRGB(236, 224, 196)
			local textLabel = markLabel(empty2, text, 16, color9, v25) -- inferred equivalent call
			textLabel.Size = UDim2.fromScale(1, 1)
			textLabel.TextTransparency = 0.35
		end
	end
end

local function fn3()
	if not parent2 then
		return
	end

	for _, guiObject in ipairs(parent2:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	local all = GCamGalleryStore.GetAll()
	count.Text = string.format("%d / %d", #all, GCamConfig.MAX_PHOTOS)
	empty.Visible = #all == 0

	for i, v24 in ipairs(all) do
		local rotation = (v24.id * 37 % 9 - 4) * 0.9

		local frame2 = Instance.new("Frame")
		frame2.Name = "Slot_" .. v24.id
		frame2.LayoutOrder = i
		frame2.BackgroundTransparency = 1
		frame2.Rotation = rotation
		frame2.Parent = parent2

		buildPolaroid(frame2, v24, rotation, false)
	end

	fn2()

	if viewer and viewer.Visible and v then
		showViewer(v)
	end
end

local function buildMain()
	gCamGalleryGui = Instance.new("ScreenGui")
	gCamGalleryGui.Name = "GCamGalleryGui"
	gCamGalleryGui.ResetOnSpawn = false
	gCamGalleryGui.IgnoreGuiInset = true
	gCamGalleryGui.DisplayOrder = 540
	gCamGalleryGui.Enabled = false
	gCamGalleryGui.Parent = PlayerGui

	local textButton = Instance.new("TextButton")
	textButton.Text = ""
	textButton.AutoButtonColor = false
	textButton.Selectable = false
	textButton.Size = UDim2.fromScale(1, 1)
	textButton.BackgroundColor3 = Color3.new(0, 0, 0)
	textButton.BackgroundTransparency = 0.45
	textButton.Parent = gCamGalleryGui

	board = Instance.new("Frame")
	board.Name = "Board"
	board.AnchorPoint = Vector2.new(0.5, 0.5)
	board.Position = UDim2.fromScale(0.5, 0.5)
	board.Size = UDim2.fromOffset(780, 560)
	board.BackgroundColor3 = color
	board.BorderSizePixel = 0
	board.Parent = gCamGalleryGui
	corner(board, 6) -- inferred equivalent call
	stroke(board, color2, 6) -- inferred equivalent call
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = board
	local function fit() -- 1 equivalent call inferred from this helper
		local viewportSize = workspace.CurrentCamera.ViewportSize
		uiScale.Scale = math.clamp(math.min(viewportSize.X / 860, viewportSize.Y / 620), 0.5, 1.15)
	end

	fit() -- inferred equivalent call
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)

	local decor = Instance.new("Frame")
	decor.Name = "Decor"
	decor.BackgroundTransparency = 1
	decor.Size = UDim2.fromScale(1, 1)
	decor.ZIndex = 1
	decor.ClipsDescendants = true
	decor.Parent = board

	local random = Random.new(11)

	for _ = 1, 190 do
		local integer = random:NextInteger(2, 5)

		rect( -- inferred equivalent call
			decor,
			random:NextInteger(4, 770),
			random:NextInteger(4, 550),
			integer,
			integer,
			random:NextInteger(0, 1) == 0 and Color3.fromRGB(60, 40, 24) or Color3.fromRGB(140, 108, 74),
			random:NextNumber(0.4, 0.75),
			nil
		)
	end

	for _ = 1, 8 do
		local integer = random:NextInteger(40, 130)
		rect(
			decor,
			random:NextInteger(0, 780 - integer),
			random:NextInteger(0, 560 - integer),
			integer,
			math.floor(integer * random:NextNumber(0.5, 1)),
			Color3.fromRGB(44, 28, 16),
			random:NextNumber(0.78, 0.9),
			random:NextInteger(0, 180)
		)
	end

	for _, v24 in ipairs({
		{ "KEEP IT LOUD", 30, 476, 44, -5, Color3.fromRGB(176, 40, 34), 0.55 },
		{ "NO FEAR", 518, 410, 38, 6, Color3.fromRGB(236, 224, 196), 0.78 },
		{ "X", 660, 250, 90, 8, Color3.fromRGB(236, 224, 196), 0.88 }
	}) do
		local textLabel = markLabel(decor, v24[1], v24[4], v24[6]) -- inferred equivalent call
		textLabel.Position = UDim2.fromOffset(v24[2], v24[3])
		textLabel.Size = UDim2.fromOffset(300, v24[4] + 8)
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextTransparency = v24[7]
		textLabel.Rotation = v24[5]
	end

	local textLabel = markLabel( -- inferred equivalent call
		rect(decor, 580, 482, 124, 44, Color3.fromRGB(206, 184, 130), 0.05, 7), -- inferred equivalent call
		"ADMIT ONE",
		14,
		Color3.fromRGB(60, 40, 20),
		Code
	)
	textLabel.Size = UDim2.fromScale(1, 1)

	for i = 1, 4 do
		local frame2 = Instance.new("Frame")
		frame2.BorderSizePixel = 0
		frame2.BackgroundColor3 = Color3.new(0, 0, 0)
		frame2.BackgroundTransparency = 0
		local uiGradient = Instance.new("UIGradient")
		uiGradient.Transparency = NumberSequence.new(0.62, 1)

		if i == 1 then
			frame2.Size = UDim2.new(1, 0, 0, 56)
			uiGradient.Rotation = 90
		elseif i == 2 then
			frame2.Size = UDim2.new(1, 0, 0, 70)
			frame2.Position = UDim2.new(0, 0, 1, -70)
			uiGradient.Rotation = 270
		elseif i == 3 then
			frame2.Size = UDim2.new(0, 40, 1, 0)
		else
			frame2.Size = UDim2.new(0, 40, 1, 0)
			frame2.Position = UDim2.new(1, -40, 0, 0)
			uiGradient.Rotation = 180
		end

		uiGradient.Parent = frame2
		frame2.Parent = decor
	end

	local parent = rect(board, 22, 14, 330, 50, color7, nil, -1.5) -- inferred equivalent call
	parent.ZIndex = 6
	stroke(parent, Color3.fromRGB(60, 50, 38), nil, 0.45) -- inferred equivalent call
	local textLabel2 = markLabel(parent, "PHOTO BOARD", 32, color8) -- inferred equivalent call
	textLabel2.Size = UDim2.fromScale(1, 1)
	textLabel2.ZIndex = 7
	tape(board, 6, 6, 70, 20, -12)
	tape(board, 306, 6, 70, 20, 8)

	local textLabel3 = markLabel( -- inferred equivalent call
		board,
		"SESSION PHOTOS VANISH WHEN YOU LEAVE.\nSAVE TO ROBLOX, OR KEEP FOREVER (3 SLOTS).",
		11,
		Color3.fromRGB(236, 224, 196),
		Code
	)
	textLabel3.Position = UDim2.fromOffset(372, 22)
	textLabel3.Size = UDim2.fromOffset(250, 34)
	textLabel3.TextXAlignment = Enum.TextXAlignment.Left
	textLabel3.ZIndex = 6

	local parent3 = board
	local color9, v24 = Color3.fromRGB(226, 84, 72)
	count = markLabel(parent3, "0 / 0", 24, color9, v24) -- inferred equivalent call
	count.Name = "Count"
	count.Position = UDim2.fromOffset(630, 22)
	count.Size = UDim2.fromOffset(84, 32)
	count.Rotation = 3
	count.ZIndex = 6

	local parent4 = tapeButton(board, "X", 36, Color3.fromRGB(170, 36, 32), color6)
	parent4.Position = UDim2.fromOffset(724, 20)
	parent4.Size = UDim2.fromOffset(36, 34)
	parent4.TextSize = 22
	parent4.Rotation = 3
	parent4.ZIndex = 8
	parent4.MouseButton1Click:Connect(function()
		GCamGalleryUI.Close()
	end)

	permanentStrip = Instance.new("Frame")
	permanentStrip.Name = "PermanentStrip"
	permanentStrip.BackgroundTransparency = 1
	permanentStrip.Position = UDim2.fromOffset(14, 74)
	permanentStrip.Size = UDim2.fromOffset(752, 152)
	permanentStrip.ZIndex = 4
	permanentStrip.Parent = board
	local textLabel4 = markLabel(permanentStrip, "KEPT FOREVER", 17, color4) -- inferred equivalent call
	textLabel4.Position = UDim2.fromOffset(18, -2)
	textLabel4.Size = UDim2.fromOffset(170, 22)
	textLabel4.TextXAlignment = Enum.TextXAlignment.Left
	textLabel4.ZIndex = 5
	local textLabel5 = markLabel( -- inferred equivalent call
		permanentStrip,
		"3 slots - they stay after you leave",
		11,
		Color3.fromRGB(236, 224, 196),
		Code
	)
	textLabel5.Position = UDim2.fromOffset(190, 2)
	textLabel5.Size = UDim2.fromOffset(240, 16)
	textLabel5.TextXAlignment = Enum.TextXAlignment.Left
	textLabel5.TextTransparency = 0.25
	textLabel5.ZIndex = 5

	local slots = Instance.new("Frame")
	slots.Name = "Slots"
	slots.BackgroundTransparency = 1
	slots.Position = UDim2.fromOffset(18, 26)
	slots.Size = UDim2.fromOffset(560, 124)
	slots.ZIndex = 4
	slots.Parent = permanentStrip

	local frame2 = Instance.new("Frame")
	frame2.BackgroundColor3 = color7
	frame2.BorderSizePixel = 0
	frame2.Position = UDim2.fromOffset(576, 38)
	frame2.Size = UDim2.fromOffset(160, 84)
	frame2.Rotation = 2
	frame2.ZIndex = 5
	frame2.Parent = permanentStrip
	stroke(frame2, Color3.fromRGB(60, 50, 38), nil, 0.45) -- inferred equivalent call
	tape(frame2, 50, -9, 60, 18, -3, false, color4)
	local textLabel6 = markLabel(frame2, "open any photo and press\nKEEP FOREVER", 12, color8) -- inferred equivalent call
	textLabel6.Size = UDim2.fromScale(1, 1)
	textLabel6.TextWrapped = true
	textLabel6.ZIndex = 6

	local frame3 = rect(board, 30, 230, 720, 2, Color3.fromRGB(236, 224, 196), 0.8) -- inferred equivalent call
	frame3.ZIndex = 4

	local scrollingFrame2 = Instance.new("ScrollingFrame")
	scrollingFrame2.BackgroundTransparency = 1
	scrollingFrame2.BorderSizePixel = 0
	scrollingFrame2.Position = UDim2.fromOffset(14, 238)
	scrollingFrame2.Size = UDim2.new(1, -28, 1, -252)
	scrollingFrame2.ScrollBarThickness = 5
	scrollingFrame2.ScrollBarImageColor3 = Color3.fromRGB(214, 198, 138)
	scrollingFrame2.CanvasSize = UDim2.new()
	scrollingFrame2.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame2.ZIndex = 3
	scrollingFrame2.Parent = board

	parent2 = scrollingFrame2
	local uiGridLayout = Instance.new("UIGridLayout")
	uiGridLayout.CellSize = UDim2.fromOffset(168, 148)
	uiGridLayout.CellPadding = UDim2.fromOffset(20, 26)
	uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiGridLayout.Parent = scrollingFrame2
	local uiPadding = Instance.new("UIPadding")
	local udim = UDim.new(0, 16)
	local udim2 = UDim.new(0, 20)
	uiPadding.PaddingLeft = udim
	uiPadding.PaddingTop = udim2
	uiPadding.Parent = scrollingFrame2

	empty = Instance.new("Frame")
	empty.Name = "Empty"
	empty.AnchorPoint = Vector2.new(0.5, 0.5)
	empty.Position = UDim2.fromScale(0.5, 0.74)
	empty.Size = UDim2.fromOffset(360, 120)
	empty.BackgroundColor3 = color7
	empty.BorderSizePixel = 0
	empty.Rotation = -2
	empty.ZIndex = 4
	empty.Parent = board
	stroke(empty, Color3.fromRGB(60, 50, 38), nil, 0.45) -- inferred equivalent call
	tape(empty, 150, -10, 70, 20, 3)
	local textLabel7 = markLabel(empty, [[
no photos yet.
grab the G-cam, right click to raise it,
left click to shoot.]], 17, color8) -- inferred equivalent call
	textLabel7.Size = UDim2.fromScale(1, 1)
	textLabel7.TextWrapped = true
	textLabel7.ZIndex = 5

	tape(board, -26, 14, 120, 26, -45, true)
	tape(board, 710, 66, 90, 24, 45, true)
	tape(board, -26, 520, 120, 26, 45, true)
	tape(board, 686, 520, 120, 26, -45, true)

	buildViewer()

	GCamGalleryStore.OnChanged(function()
		if flag then
			fn3()
		end
	end)
end

function GCamGalleryUI:DevelopPhoto()
	if self.content then
		return self.content
	end

	if self.failed or not self.recipe then
		return nil
	end

	local total = 0

	while (flag2 or GCamDevelop.IsBusy()) and total < 15 do
		task.wait(0.1)
		total += 0.1
	end

	if self.content then
		return self.content
	end

	if flag2 or GCamDevelop.IsBusy() or LocalPlayer:GetAttribute("EquippedInstrumentType") ~= nil then
		return nil
	end

	flag2 = true
	task.wait(0.05)
	local v24 = GCamDevelop.Run(self.recipe, v3)

	if not v24 then
		self.failed = true
	end

	GCamGalleryStore.SetDeveloped(self.id, v24)

	if not v24 then
		self.undeveloped = true
	end

	flag2 = false
	return v24
end

local gCamIncomingGui = nil
local frame2 = nil
local v24 = {}
local count3 = 0

local color9 = Color3.fromRGB(222, 198, 140)
local color10 = Color3.fromRGB(90, 86, 78)

local function lastInputIsGamepad(): boolean -- 1 equivalent call inferred from this helper
	return string.sub(UserInputService:GetLastInputType().Name, 1, 7) == "Gamepad"
end

local function bindIncomingMouse(p)
	if p then
		RunService:BindToRenderStep("GCamIncomingMouse", Enum.RenderPriority.Camera.Value + 2, function()
			if
				UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt)
				or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)
			then
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				UserInputService.MouseIconEnabled = true
			end
		end)
	else
		pcall(function()
			RunService:UnbindFromRenderStep("GCamIncomingMouse")
		end)
	end
end

local function removeIncoming(id, p)
	local v25 = v24[id]

	if not v25 then
		return
	end

	v24[id] = nil

	if next(v24) == nil then
		pcall(function()
			RunService:UnbindFromRenderStep("GCamIncomingMouse")
		end)
	end

	if p then
		v25.holder:Destroy()
		return
	end

	TweenService:Create(v25.card, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.fromOffset(280, 0),
		Rotation = 8
	}):Play()
	task.delay(0.24, function()
		v25.holder:Destroy()
	end)
end

local function newestIncoming() -- 1 equivalent call inferred from this helper
	local v25 = nil

	for _, v26 in pairs(v24) do
		if not v25 or v26.order > v25.order then
			v25 = v26
		end
	end

	return v25
end

local function buildIncoming()
	gCamIncomingGui = Instance.new("ScreenGui")
	gCamIncomingGui.Name = "GCamIncomingGui"
	gCamIncomingGui.ResetOnSpawn = false
	gCamIncomingGui.IgnoreGuiInset = true
	gCamIncomingGui.DisplayOrder = 535
	gCamIncomingGui.Parent = PlayerGui

	frame2 = Instance.new("Frame")
	frame2.AnchorPoint = Vector2.new(1, 0)
	frame2.Position = UDim2.new(1, -12, 0, 92)
	frame2.Size = UDim2.fromOffset(196, 0)
	frame2.AutomaticSize = Enum.AutomaticSize.Y
	frame2.BackgroundTransparency = 1
	frame2.Parent = gCamIncomingGui

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 14)
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	uiListLayout.Parent = frame2

	local uiScale = Instance.new("UIScale")
	uiScale.Parent = frame2
	local function fit() -- 1 equivalent call inferred from this helper
		local viewportSize = workspace.CurrentCamera.ViewportSize
		uiScale.Scale = math.clamp(viewportSize.Y / 700, 0.7, 1.05)

		frame2.Position = UDim2.new(1, -10, 0, viewportSize.Y < 500 and 56 or 92)
	end

	fit() -- inferred equivalent call
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)

	GCamGalleryStore.OnChanged(function(p, data)
		local v25 = data and v24[data.id]

		if not v25 then
			return
		end

		if p == "removed" then
			removeIncoming(data.id)
		elseif data.content then
			v25.image.Image = data.content
			v25.status.Visible = false
		elseif data.failed then
			v25.status.Text = "couldn't develop"
			v25.status.Visible = true
		end
	end)

	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Gamepad1 or UserInputService:GetFocusedTextBox() then
			return
		end

		local v25 = newestIncoming() -- inferred equivalent call

		if not v25 then
			return
		end

		if input.KeyCode == Enum.KeyCode.DPadLeft then
			v25.view()
		elseif input.KeyCode == Enum.KeyCode.DPadDown then
			v25.openGallery()
		elseif input.KeyCode == Enum.KeyCode.DPadUp then
			v25.dismiss()
		end
	end)
end

local function tapeStrip(card, p, p2, rotation)
	local tape2 = Instance.new("Frame")
	tape2.Name = "Tape"
	tape2.Position = UDim2.fromOffset(p, p2)
	tape2.Size = UDim2.fromOffset(48, 15)
	tape2.Rotation = rotation
	tape2.BackgroundColor3 = color9
	tape2.BackgroundTransparency = 0.18
	tape2.BorderSizePixel = 0
	tape2.ZIndex = 8
	tape2.Parent = card
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(150, 128, 80)
	uiStroke.Thickness = 1
	uiStroke.Transparency = 0.6
	uiStroke.Parent = tape2

	local uiGradient = Instance.new("UIGradient")
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(1, 0.2)
	})

	uiGradient.Parent = tape2
	return tape2
end

function GCamGalleryUI.ShowIncoming(data)
	if v4 or not data then
		return
	end

	if not gCamIncomingGui then
		buildIncoming()
	end

	if v24[data.id] then
		return
	end

	local count4 = 0
	local v25 = 1e999
	local v26 = nil

	for k, v27 in pairs(v24) do
		count4 += 1

		if not (v27.order < v25) then
			continue
		end

		v25 = v27.order
		v26 = k
	end

	local v27 = count4 >= 3 and v26 and v24[v26]

	if v27 then
		v24[v26] = nil

		if next(v24) == nil then
			pcall(function()
				RunService:UnbindFromRenderStep("GCamIncomingMouse")
			end)
		end

		v27.holder:Destroy()
	end

	count3 += 1
	local v28 = count3
	local v29 = lastInputIsGamepad() -- inferred equivalent call
	local v30 = UserInputService:GetLastInputType() == Enum.UserInputType.Touch

	local text2 = v29 and "D-PAD:  < VIEW   v GALLERY   ^ DISMISS"
		or not v30 and SessionCameraSettings.GetIsFirstPerson() and "hold ALT to use the cursor"
		or nil

	local frame3 = Instance.new("Frame")
	frame3.Name = "Holder_" .. data.id
	frame3.LayoutOrder = v28
	frame3.Size = UDim2.fromOffset(196, text2 and 170 or 154)
	frame3.BackgroundTransparency = 1
	frame3.Parent = frame2

	local card = Instance.new("Frame")
	card.Name = "Card"
	card.Size = UDim2.fromScale(1, 1)
	card.Position = UDim2.fromOffset(280, 0)
	card.Rotation = 8
	card.BackgroundColor3 = Colors.Paper
	card.BorderSizePixel = 0
	card.Parent = frame3
	corner(card, 2) -- inferred equivalent call
	stroke(card, Color3.fromRGB(60, 54, 44), nil, 0.55) -- inferred equivalent call
	tapeStrip(card, -14, -6, -11)
	tapeStrip(card, 164, -6, 9)

	local photoButton = Instance.new("TextButton")
	photoButton.Name = "PhotoButton"
	photoButton.Text = ""
	photoButton.AutoButtonColor = false
	photoButton.Position = UDim2.fromOffset(10, 14)
	photoButton.Size = UDim2.fromOffset(176, 96)
	photoButton.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	photoButton.BorderSizePixel = 0
	photoButton.Parent = card
	local uiStroke = stroke(photoButton, Colors.Ink, nil, 0.45) -- inferred equivalent call

	local imageLabel3 = Instance.new("ImageLabel")
	imageLabel3.BackgroundTransparency = 1
	imageLabel3.Size = UDim2.fromScale(1, 1)
	imageLabel3.ScaleType = Enum.ScaleType.Crop
	imageLabel3.Image = data.content or ""
	imageLabel3.Active = false
	imageLabel3.Parent = photoButton

	local permanentMarker = Enum.Font.PermanentMarker
	local paper = Colors.Paper
	local status2 = Instance.new("TextLabel")
	status2.Name = "Status"
	status2.BackgroundTransparency = 1
	status2.Font = permanentMarker
	status2.TextSize = 13
	status2.TextColor3 = paper
	status2.Text = "developing..."
	status2.Parent = photoButton

	status2.Size = UDim2.fromScale(1, 1)
	status2.ZIndex = 3
	status2.Visible = data.content == nil

	photoButton.MouseEnter:Connect(function()
		uiStroke.Transparency = 0
		uiStroke.Thickness = 2
	end)
	photoButton.MouseLeave:Connect(function()
		uiStroke.Transparency = 0.45
		uiStroke.Thickness = 1
	end)

	local text3 = "from " .. (data.fromName or "?")
	local permanentMarker2 = Enum.Font.PermanentMarker
	local ink = Colors.Ink
	local caption2 = Instance.new("TextLabel")
	caption2.Name = "Caption"
	caption2.BackgroundTransparency = 1
	caption2.Font = permanentMarker2
	caption2.TextSize = 13
	caption2.TextColor3 = ink
	caption2.Text = text3
	caption2.Parent = card

	caption2.Position = UDim2.fromOffset(12, 112)
	caption2.Size = UDim2.fromOffset(172, 18)
	caption2.TextXAlignment = Enum.TextXAlignment.Left
	caption2.TextTruncate = Enum.TextTruncate.AtEnd

	local function tapeButton2(text, p, p2, backgroundColor, textColor)
		local textButton = Instance.new("TextButton")
		textButton.Text = text
		textButton.AutoButtonColor = false
		textButton.Font = Enum.Font.PermanentMarker
		textButton.TextSize = 11
		textButton.TextColor3 = textColor
		textButton.BackgroundColor3 = backgroundColor
		textButton.BackgroundTransparency = 0.05
		textButton.BorderSizePixel = 0
		textButton.Position = UDim2.fromOffset(p, 132)
		textButton.Size = UDim2.fromOffset(p2, 20)
		textButton.Parent = card
		corner(textButton, 1) -- inferred equivalent call
		stroke(textButton, Color3.fromRGB(80, 68, 40), nil, 0.6) -- inferred equivalent call
		textButton.MouseEnter:Connect(function()
			textButton.BackgroundColor3 = backgroundColor:Lerp(Color3.new(1, 1, 1), 0.2)
		end)
		textButton.MouseLeave:Connect(function()
			textButton.BackgroundColor3 = backgroundColor
		end)
		return textButton
	end

	local parent = tapeButton2("OPEN GALLERY", 10, 106, color9, Colors.Ink)
	local parent3 = tapeButton2("DISMISS", 122, 64, Color3.fromRGB(214, 208, 192), Colors.Red)

	if text2 then
		local arcade = Enum.Font.Arcade
		local hint = Instance.new("TextLabel")
		hint.Name = "Hint"
		hint.BackgroundTransparency = 1
		hint.Font = arcade
		hint.TextSize = 9
		hint.TextColor3 = color10
		hint.Text = text2
		hint.Parent = card

		hint.Position = UDim2.fromOffset(10, 154)
		hint.Size = UDim2.fromOffset(176, 12)
		hint.TextXAlignment = Enum.TextXAlignment.Left
	end

	local timerBar = Instance.new("Frame")
	timerBar.Name = "TimerBar"
	timerBar.AnchorPoint = Vector2.new(0, 1)
	timerBar.Position = UDim2.fromScale(0, 1)
	timerBar.Size = UDim2.new(1, 0, 0, 3)
	timerBar.BackgroundColor3 = Colors.Red
	timerBar.BackgroundTransparency = 0.35
	timerBar.BorderSizePixel = 0
	timerBar.Parent = card

	local v31 = {
		holder = frame3,
		card = card,
		image = imageLabel3,
		status = status2,
		bar = timerBar,
		order = v28,
		hover = false
	}

	v24[data.id] = v31
	RunService:BindToRenderStep("GCamIncomingMouse", Enum.RenderPriority.Camera.Value + 2, function()
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt) then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		end
	end)

	local rotation = v28 % 2 == 0 and 1.4 or -1.4
	TweenService:Create(card, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromOffset(0, 0),
		Rotation = rotation
	}):Play()

	function v31.view()
		if data.failed then
			GCamGalleryUI.Toast("This photo couldn't be developed", true)
			return
		end

		status2.Visible = data.content == nil
		task.spawn(function()
			if data.content or GCamGalleryUI.DevelopPhoto(data) then
				removeIncoming(data.id)
				GCamGalleryUI.OpenFullscreen(data)
			else
				GCamGalleryUI.Toast("Put your instrument away to view this photo", true)
			end
		end)
	end
	function v31.openGallery()
		removeIncoming(data.id)
		GCamGalleryUI.Open()
	end
	function v31.dismiss()
		removeIncoming(data.id)
	end

	photoButton.MouseButton1Click:Connect(v31.view)
	parent.MouseButton1Click:Connect(v31.openGallery)
	parent3.MouseButton1Click:Connect(v31.dismiss)

	card.MouseEnter:Connect(function()
		v31.hover = true
	end)
	card.MouseLeave:Connect(function()
		v31.hover = false
	end)
	task.spawn(function()
		local total = 0

		while v24[data.id] == v31 and total < 5 do
			local v32 = task.wait(0.05)

			if not v31.hover then
				total += v32
			end

			timerBar.Size = UDim2.new(math.clamp(1 - total / 5, 0, 1), 0, 0, 3)
		end

		if v24[data.id] == v31 then
			removeIncoming(data.id)
		end
	end)

	task.spawn(function()
		local total = 0

		while v24[data.id] and not data.content and not data.failed and total < 4 do
			local gCamAiming = LocalPlayer:GetAttribute("GCamAiming") == true
			local v32 = LocalPlayer:GetAttribute("EquippedInstrumentType") ~= nil

			if gCamAiming or v32 or flag2 or GCamDevelop.IsBusy() or flag then
				task.wait(0.5)
				total += 0.5
			else
				task.wait(0.3)

				if v24[data.id] then
					GCamGalleryUI.DevelopPhoto(data)
				end

				break
			end
		end
	end)
end

function GCamGalleryUI.SetHeldHider(p)
	v3 = p
end

local function developPending()
	if flag2 then
		return
	end

	flag2 = true

	while flag do
		local v25 = nil

		for i = 1, GCamConfig.PERMANENT_SLOTS do
			local v26 = GCamGalleryStore.GetPermanent()[i]

			if v26 and v26.undeveloped and not v26.failed then
				v25 = v26
				break
			end
		end

		if not v25 then
			for _, v26 in ipairs(GCamGalleryStore.GetAll()) do
				if v26.undeveloped and not v26.failed then
					v25 = v26
					break
				end
			end
		end

		if not v25 then
			break
		end

		if LocalPlayer:GetAttribute("EquippedInstrumentType") ~= nil then
			GCamGalleryUI.Toast("Put your instrument away to develop received photos", true)
			break
		end

		gCamGalleryGui.Enabled = false

		if gCamShareGui then
			gCamShareGui.Enabled = false
		end

		task.wait(0.05)
		local v26 = GCamDevelop.Run(v25.recipe, v3)
		gCamGalleryGui.Enabled = flag

		if not v26 then
			v25.failed = true
		end

		GCamGalleryStore.SetDeveloped(v25.id, v26)

		if not v26 then
			v25.undeveloped = true
		end

		task.wait(0.15)
	end

	flag2 = false
end

local function buildFullscreen()
	gCamFullscreenGui = Instance.new("ScreenGui")
	gCamFullscreenGui.Name = "GCamFullscreenGui"
	gCamFullscreenGui.ResetOnSpawn = false
	gCamFullscreenGui.IgnoreGuiInset = true
	gCamFullscreenGui.DisplayOrder = 600
	gCamFullscreenGui.Enabled = false
	gCamFullscreenGui.Parent = PlayerGui

	local backdrop = Instance.new("TextButton")
	backdrop.Name = "Backdrop"
	backdrop.Text = ""
	backdrop.AutoButtonColor = false
	backdrop.Selectable = false
	backdrop.BorderSizePixel = 0
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
	backdrop.Parent = gCamFullscreenGui
	backdrop.MouseButton1Click:Connect(function()
		GCamGalleryUI.CloseFullscreen()
	end)

	imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.Size = UDim2.fromScale(1, 1)
	imageLabel2.ScaleType = Enum.ScaleType.Fit
	imageLabel2.Active = false
	imageLabel2.Parent = backdrop

	local arcade = Enum.Font.Arcade
	local paper = Colors.Paper
	local caption2 = Instance.new("TextLabel")
	caption2.Name = "Caption"
	caption2.BackgroundTransparency = 1
	caption2.Font = arcade
	caption2.TextSize = 16
	caption2.TextColor3 = paper
	caption2.Text = ""
	caption2.Parent = backdrop

	v5 = caption2
	v5.AnchorPoint = Vector2.new(0.5, 1)
	v5.Position = UDim2.new(0.5, 0, 1, -14)
	v5.Size = UDim2.new(1, -40, 0, 22)
	v5.ZIndex = 3
	stroke(v5, Color3.new(0, 0, 0), 1.5, 0.3) -- inferred equivalent call

	local arcade2 = Enum.Font.Arcade
	local dim = Colors.Dim
	local hint = Instance.new("TextLabel")
	hint.Name = "Hint"
	hint.BackgroundTransparency = 1
	hint.Font = arcade2
	hint.TextSize = 13
	hint.TextColor3 = dim
	hint.Text = "CLICK OR ESC TO CLOSE     <  >  BROWSE     G HIDE TEXT"
	hint.Parent = backdrop

	hint.AnchorPoint = Vector2.new(1, 0)
	hint.Position = UDim2.new(1, -16, 0, 12)
	hint.Size = UDim2.fromOffset(640, 18)
	hint.TextXAlignment = Enum.TextXAlignment.Right
	hint.ZIndex = 3
	v7 = hint

	if UserInputService.TouchEnabled then
		local function navButton(text, p, p2, onMouseButton1Click)
			local textButton = Instance.new("TextButton")
			textButton.Text = text
			textButton.AnchorPoint = Vector2.new(p, 0.5)
			textButton.Position = UDim2.new(p, p2, 0.5, 0)
			textButton.Size = UDim2.fromOffset(52, 84)
			textButton.BackgroundColor3 = Colors.Ink
			textButton.BackgroundTransparency = 0.35
			textButton.TextColor3 = Colors.Paper
			textButton.Font = Enum.Font.PermanentMarker
			textButton.TextSize = 30
			textButton.ZIndex = 4
			textButton.Selectable = false
			textButton.Parent = backdrop
			corner(textButton) -- inferred equivalent call
			textButton.MouseButton1Click:Connect(onMouseButton1Click)
			return textButton
		end

		navButton("<", 0, 10, function()
			GCamGalleryUI.BrowseFullscreen(1)
		end)
		navButton(">", 1, -10, function()
			GCamGalleryUI.BrowseFullscreen(-1)
		end)
		local v25 = navButton("TXT", 0, 10, function()
			GCamGalleryUI.ToggleFullscreenHud()
		end)
		v25.AnchorPoint = Vector2.new(0, 0)
		v25.Position = UDim2.fromOffset(10, 10)
		v25.Size = UDim2.fromOffset(60, 34)
		v25.TextSize = 14
	end
end

local function applyFullscreenHud() -- 3 equivalent calls inferred from this helper
	if v5 then
		v5.Visible = not v8
	end

	if v7 then
		v7.Visible = not v8
	end
end

function GCamGalleryUI.ToggleFullscreenHud()
	v8 = not v8
	applyFullscreenHud() -- inferred equivalent call
end

function GCamGalleryUI.BrowseFullscreen(p)
	if not (v6 and imageLabel2) then
		return
	end

	local all = GCamGalleryStore.GetAll()

	for i, v25 in ipairs(all) do
		if v25.id == v6.id then
			local v26 = i + p

			while all[v26] and not all[v26].content do
				v26 += p
			end

			local v27 = all[v26]

			if v27 then
				v6 = v27
				imageLabel2.Image = v27.content
				v5.Text = v27.caption or photoCaption(v27)
			end

			break
		end
	end
end

function GCamGalleryUI.IsFullscreenOpen()
	return gCamFullscreenGui ~= nil and gCamFullscreenGui.Enabled
end

function GCamGalleryUI.CloseFullscreen()
	if inputBeganConnection then
		inputBeganConnection:Disconnect()
		inputBeganConnection = nil
	end

	v8 = false
	applyFullscreenHud() -- inferred equivalent call

	if gCamFullscreenGui and gCamFullscreenGui.Enabled then
		gCamFullscreenGui.Enabled = false
		v6 = nil
		GCamGalleryUI.ReleaseMenuIfIdle()
	end
end

function GCamGalleryUI.OpenFullscreen(p)
	if not (p and p.content) then
		return
	end

	if not gCamFullscreenGui then
		buildFullscreen()
	end

	local function show(p2) -- 2 equivalent calls inferred from this helper
		v6 = p2
		imageLabel2.Image = p2.content
		v5.Text = p2.caption or photoCaption(p2)
	end

	show(p) -- inferred equivalent call
	v8 = false
	applyFullscreenHud() -- inferred equivalent call
	gCamFullscreenGui.Enabled = true

	if not v2 then
		v2 = true
		SessionCameraSettings.SetMenuOpen(true)
		RunService:BindToRenderStep("GCamGalleryMouse", Enum.RenderPriority.Camera.Value + 2, function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		end)
	end

	local lastInputType = UserInputService:GetLastInputType()

	if v7 then
		if isGamepadInput() then -- inferred equivalent call
			v7.Text = "B CLOSE     <  >  BROWSE     Y HIDE TEXT"
		elseif lastInputType == Enum.UserInputType.Touch then
			v7.Text = "TAP TO CLOSE"
		else
			v7.Text = "CLICK OR ESC TO CLOSE     <  >  BROWSE     G HIDE TEXT"
		end
	end

	if isGamepadInput() then -- inferred equivalent call
		GuiService.SelectedObject = nil
	end

	if not inputBeganConnection then
		inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
			local v25 = input.UserInputType == Enum.UserInputType.Gamepad1

			if input.UserInputType ~= Enum.UserInputType.Keyboard and not v25 then
				return
			end

			local keyCode = input.KeyCode

			if
				keyCode == Enum.KeyCode.Escape
				or v25 and (keyCode == Enum.KeyCode.ButtonB or keyCode == Enum.KeyCode.ButtonA)
			then
				GCamGalleryUI.CloseFullscreen()
			elseif keyCode == GCamConfig.Keys.HideHud or v25 and keyCode == Enum.KeyCode.ButtonY then
				GCamGalleryUI.ToggleFullscreenHud()
			elseif
				keyCode == Enum.KeyCode.Left
				or keyCode == Enum.KeyCode.Right
				or v25
				and (keyCode == Enum.KeyCode.DPadLeft or keyCode == Enum.KeyCode.DPadRight or keyCode == Enum.KeyCode.ButtonL1 or keyCode == Enum.KeyCode.ButtonR1)
			then
				local v26 = (keyCode == Enum.KeyCode.Left or keyCode == Enum.KeyCode.DPadLeft or keyCode == Enum.KeyCode.ButtonL1)
					and 1
					or -1
				local all = GCamGalleryStore.GetAll()

				for i, v27 in ipairs(all) do
					if v6 and v27.id == v6.id then
						local v28 = i + v26

						while all[v28] and not all[v28].content do
							v28 += v26
						end

						if not all[v28] then
							break
						end

						show(all[v28]) -- inferred equivalent call

						return
					end
				end
			end
		end)
	end
end

function GCamGalleryUI.IsOpen()
	return flag
end

function GCamGalleryUI.Open()
	if not gCamGalleryGui then
		buildMain()
	end

	if flag then
		return
	end

	flag = true
	viewer.Visible = false
	v = nil
	fn3()
	gCamGalleryGui.Enabled = true

	if not v2 then
		v2 = true
		SessionCameraSettings.SetMenuOpen(true)
		RunService:BindToRenderStep("GCamGalleryMouse", Enum.RenderPriority.Camera.Value + 2, function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		end)
	end

	focusFirstButton(gCamGalleryGui) -- inferred equivalent call
	task.spawn(developPending)
end

function GCamGalleryUI.Close()
	GCamGalleryUI.CloseFullscreen()

	if not flag then
		return
	end

	flag = false

	if gCamGalleryGui then
		gCamGalleryGui.Enabled = false
	end

	GCamGalleryUI.CloseSharePicker()

	if not v22 and v2 then
		v2 = false
		SessionCameraSettings.SetMenuOpen(false)
		pcall(function()
			RunService:UnbindFromRenderStep("GCamGalleryMouse")
		end)
	end
end

GCamGalleryStore.OnChanged(function(p, p2)
	if p == "added" and p2 and p2.undeveloped and flag then
		task.spawn(developPending)
	end
end)

UserInputService.InputBegan:Connect(function(input)
	if
		input.UserInputType ~= Enum.UserInputType.Gamepad1
		or input.KeyCode ~= Enum.KeyCode.ButtonB
		or GCamGalleryUI.IsFullscreenOpen()
	then
		return
	end

	if slotPicker and slotPicker.Visible then
		slotPicker.Visible = false
	elseif gCamShareGui and gCamShareGui.Enabled then
		GCamGalleryUI.CloseSharePicker()
	elseif viewer and viewer.Visible then
		viewer.Visible = false
		v = nil
		local folder = gCamGalleryGui

		if isGamepadInput() then -- inferred equivalent call
			if not folder then
				return
			end

			task.defer(function()
				local selectedObject = nil

				for _, button2 in ipairs(folder:GetDescendants()) do
					if not (button2:IsA("TextButton") and button2.Visible and button2.Selectable) then
						continue
					end

					if string.sub(button2.Name, 1, 6) == "Photo_" then
						GuiService.SelectedObject = button2
						return
					end

					selectedObject = selectedObject or button2
				end

				if selectedObject then
					GuiService.SelectedObject = selectedObject
				end
			end)
		end
	elseif flag then
		GCamGalleryUI.Close()
	end
end)

return GCamGalleryUI