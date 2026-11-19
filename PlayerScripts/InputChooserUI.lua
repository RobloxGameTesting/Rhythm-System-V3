local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local SettingsState = require(Modules:WaitForChild("SettingsState"))
local ToastStyle = require(Modules:WaitForChild("SongListUI"):WaitForChild("ToastStyle"))
local ControllerGlyphs = require(Modules:WaitForChild("ControllerGlyphs"))
local UserInputService = game:GetService("UserInputService")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local mk = ToastStyle.mk
local z = ToastStyle.Z
local flag = false

local function shouldShow() -- 1 equivalent call inferred from this helper
	return SettingsState.HasLoadedFromServer()
		and not SettingsState.HasChosenInputMode()
		and SettingsState.IsConsoleLikeDevice()
end

local function makeLabel(content, items)
	local v = {
		BackgroundTransparency = 1,
		TextColor3 = ToastStyle.INK,
		TextStrokeTransparency = 1,
		ZIndex = z + 4,
		TextWrapped = true,
		RichText = false
	}

	for k, item in pairs(items) do
		v[k] = item
	end

	return mk("TextLabel", v, content)
end

local function padIcon(item) -- 1 equivalent call inferred from this helper
	local success, result = pcall(function()
		return UserInputService:GetImageForKeyCode(item)
	end)

	if success and type(result) == "string" and result ~= "" then
		return result
	end

	return nil
end

local function makeChip(p, list, text, layoutOrder, value)
	local chip = mk("Frame", {
		Name = "Chip",
		BackgroundColor3 = ToastStyle.TAPE,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 30),
		Rotation = value or 0,
		LayoutOrder = layoutOrder,
		ZIndex = z + 3
	}, p)

	mk("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.12),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, 0.16)
		})
	}, chip)

	mk("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 12) }, chip)
	mk(
		"UIListLayout",
		{
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 5)
		},
		chip
	)
	local count = 0

	for _, item in ipairs(list) do
		count += 1
		local image = padIcon(item) -- inferred equivalent call

		if image then
			mk("ImageLabel", {
				Name = "PadIcon",
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(24, 24),
				Image = image,
				ImageColor3 = ToastStyle.DARK,
				ScaleType = Enum.ScaleType.Fit,
				LayoutOrder = count,
				ZIndex = z + 4
			}, chip)
		else
			mk("TextLabel", {
				Name = "PadGlyph",
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromOffset(0, 24),
				Font = Enum.Font.PermanentMarker,
				TextSize = 13,
				TextColor3 = ToastStyle.DARK,
				LayoutOrder = count,
				ZIndex = z + 4,
				Text = ControllerGlyphs.LabelFromName(item.Name) or item.Name
			}, chip)
		end
	end

	mk("TextLabel", {
		Name = "Text",
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 24),
		Font = Enum.Font.PermanentMarker,
		TextSize = 13,
		TextColor3 = ToastStyle.DARK,
		Text = text,
		LayoutOrder = count + 1,
		ZIndex = z + 4
	}, chip)

	return chip
end

local function show()
	if flag then
		return
	end

	flag = true

	local v = mk("ScreenGui", {
		Name = "InputChooserGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 250,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})

	local v2 = mk("Frame", {
		Name = "Overlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 1
	}, v)

	local parent = mk("Frame", {
		Name = "Holder",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(640, 406),
		BackgroundTransparency = 1,
		ZIndex = z
	}, v2)

	local v3 = mk("UIScale", { Name = "FitScale" }, parent)
	local function updateScale() -- 1 equivalent call inferred from this helper
		local currentCamera = workspace.CurrentCamera
		local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
		v3.Scale = math.clamp(math.min(viewportSize.X / 720, viewportSize.Y / 460), 0.55, 1.5)
	end

	updateScale() -- inferred equivalent call
	local card = ToastStyle.buildCard({
		name = "ChooserCard",
		width = 640,
		height = 406,
		rotation = -0.7,
		accent = ToastStyle.AMBER,
		tape = "both",
		tag = "INPUT CHECK",
		tagX = 46,
		seed = 7711,
		vertical = true,
		padL = 26,
		padR = 24,
		padT = 28,
		padB = 16,
		gap = 8,
		parent = parent
	})

	card.Card.Position = UDim2.fromScale(0, 0)

	local label = makeLabel(card.Content, {
		Name = "Title",
		Size = UDim2.new(1, 0, 0, 38),
		Font = Enum.Font.PermanentMarker,
		TextSize = 32,
		TextColor3 = ToastStyle.AMBER,
		Text = "PICK YOUR GEAR",
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 1,
		TextWrapped = false
	})

	card.Scribble = ToastStyle.makeScribble(label, ToastStyle.AMBER, 16)

	makeLabel(card.Content, {
		Name = "Subtitle",
		Size = UDim2.new(1, 0, 0, 34),
		Font = Enum.Font.SpecialElite,
		TextSize = 14,
		TextColor3 = ToastStyle.INK,
		Text = "Choose once, we'll remember it. Change it anytime in Settings > Controls.",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		LayoutOrder = 2
	})

	local parent2 = mk("Frame", {
		Name = "Options",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 214),
		LayoutOrder = 3,
		ZIndex = z + 2
	}, card.Content)
	mk("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 26)
	}, parent2)

	local v4 = {}
	local v5 = nil

	local function applySelection(p)
		v5 = p

		for k, v6 in pairs(v4) do
			local v7 = k == p
			v6.Handle.SetAccent(v7 and ToastStyle.AMBER or ToastStyle.GRAY)
			v6.Handle.Plate.BackgroundColor3 = v7 and ToastStyle.PLATE_LIGHT or Color3.fromRGB(40, 37, 33)
			v6.Title.TextColor3 = v7 and ToastStyle.AMBER or ToastStyle.INK
			v6.Icon.SetActive(v7)
			ToastStyle.tween(v6.Handle.Scale, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				Scale = v7 and 1.05 or 0.97
			})
			ToastStyle.tween(v6.Handle.Plate, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
				Rotation = v7 and 0 or v6.Handle.BaseRotation
			})
		end
	end

	local function closeChooser()
		GuiService.SelectedObject = nil
		ToastStyle.tween(v2, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
			BackgroundTransparency = 1
		})
		ToastStyle.tween(card.Scale, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In, {
			Scale = 0.85
		})
		task.delay(0.26, function()
			v:Destroy()
		end)
	end

	local function choose(p) -- 1 equivalent call inferred from this helper
		SettingsState.SetField("InputMode", p, true)
		SettingsState.SetField("InputModeChosen", true, true)
		closeChooser()
	end

	local function makeOption(p, layoutOrder, text, text2, rotation, image, seed)
		local card2 = ToastStyle.buildCard({
			name = p .. "Choice",
			class = "TextButton",
			width = 270,
			height = 210,
			rotation = rotation,
			accent = ToastStyle.GRAY,
			tape = "tr",
			seed = seed,
			vertical = true,
			padL = 16,
			padR = 14,
			padT = 18,
			padB = 12,
			gap = 4,
			parent = parent2
		})

		card2.Card.LayoutOrder = layoutOrder
		card2.Card.Selectable = true
		card2.Card.Active = true
		card2.Card.SelectionImageObject = mk("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1)
		})

		local v6 = mk("Frame", {
			Name = "IconHolder",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 84),
			LayoutOrder = 1,
			ZIndex = z + 3
		}, card2.Content)
		local v7 = mk("ImageLabel", {
			Name = "DeviceImage",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = image,
			ScaleType = Enum.ScaleType.Fit,
			ImageColor3 = Color3.fromRGB(150, 146, 138),
			ImageTransparency = 0.25,
			ZIndex = z + 4
		}, v6)

		local label2 = makeLabel(card2.Content, {
			Name = "Title",
			Size = UDim2.new(1, 0, 0, 30),
			Font = Enum.Font.PermanentMarker,
			TextSize = 24,
			Text = text,
			LayoutOrder = 2,
			TextWrapped = false
		})

		makeLabel(card2.Content, {
			Name = "Detail",
			Size = UDim2.new(1, 0, 0, 52),
			Font = Enum.Font.SpecialElite,
			TextSize = 13,
			TextColor3 = ToastStyle.GRAY,
			Text = text2,
			LayoutOrder = 3,
			TextYAlignment = Enum.TextYAlignment.Top
		})
		v4[p] = {
			Handle = card2,
			Title = label2,
			Icon = {
				SetActive = function(p2)
					v7.ImageColor3 = p2 and Color3.new(1, 1, 1) or Color3.fromRGB(150, 146, 138)
					v7.ImageTransparency = p2 and 0 or 0.25
				end
			}
		}

		card2.Card.SelectionGained:Connect(function()
			applySelection(p)
		end)
		card2.Card.MouseEnter:Connect(function()
			applySelection(p)
		end)
		card2.Card.Activated:Connect(function()
			choose(p) -- inferred equivalent call
		end)
		return card2
	end

	local option = makeOption(
		"Keyboard",
		1,
		"KEYBOARD",
		"Keys and mouse. The classic way to shred.",
		-1.4,
		"rbxassetid://121332782788896",
		5521
	)
	local option2 = makeOption(
		"Controller",
		2,
		"CONTROLLER",
		"Xbox, PlayStation or a guitar. Plug in and play.",
		1.2,
		"rbxassetid://12684121161",
		6632
	)

	local card2 = option.Card
	local card3 = option2.Card
	card2.NextSelectionRight = card3
	card3.NextSelectionLeft = card2
	card2.NextSelectionLeft = card2
	card3.NextSelectionRight = card3
	card2.NextSelectionUp = card2
	card2.NextSelectionDown = card2
	card3.NextSelectionUp = card3
	card3.NextSelectionDown = card3

	local v6 = mk("Frame", {
		Name = "Hints",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 32),
		LayoutOrder = 4,
		ZIndex = z + 2
	}, card.Content)
	mk("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 12)
	}, v6)

	makeChip(v6, { Enum.KeyCode.DPadLeft, Enum.KeyCode.DPadRight }, "MOVE", 1, -1.5)
	makeChip(v6, { Enum.KeyCode.ButtonA }, "SELECT", 2, 1)

	v.Parent = PlayerGui

	applySelection("Controller")
	GuiService.SelectedObject = option2.Card

	ToastStyle.popIn(card)

	for _, v7 in ipairs({ "Keyboard", "Controller" }) do
		v4[v7].Handle.Scale.Scale = 0.6
	end

	task.delay(0.12, function()
		applySelection(v5 or "Controller")
	end)
end

local function check() -- 1 equivalent call inferred from this helper
	if shouldShow() then -- inferred equivalent call
		show()
	end
end

SettingsState.OnChanged(check)
check() -- inferred equivalent call