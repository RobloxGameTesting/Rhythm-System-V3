local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ProximityPromptService = game:GetService("ProximityPromptService")

local CustomGuitarConfig = require(ReplicatedStorage.Modules.CustomGuitarConfig)
local CustomGuitarBuilder = require(ReplicatedStorage.Modules.CustomGuitarBuilder)
local CustomGuitarClient = require(ReplicatedStorage.Modules.CustomGuitarClient)
local CustomGuitarCelebration = require(ReplicatedStorage.Modules.CustomGuitarCelebration)
local setEquippedSkin = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SetEquippedSkin")
local UIPanelGate = require(ReplicatedStorage.Modules:WaitForChild("UIPanelGate"))
local SessionCameraSettings = require(ReplicatedStorage.Modules.SessionCameraSettings)
local ThemeSwitchToast = require(ReplicatedStorage.Modules.ThemeSwitchToast)
local StyledTheme = require(ReplicatedStorage.Modules.SongListUI.StyledTheme)
local Settings = StyledTheme.Settings

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function create(className, items, parent) -- 36 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function addCorner(parent, value) -- 2 equivalent calls inferred from this helper
	return create("UICorner", { -- inferred equivalent call
		CornerRadius = UDim.new(0, value or 8)
	}, parent)
end

local function addStroke(parent, border, transparency, thickness) -- 5 equivalent calls inferred from this helper
	return create( -- inferred equivalent call
		"UIStroke",
		{
			Color = border,
			Transparency = transparency,
			Thickness = thickness,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		},
		parent
	)
end

local function tween(instance, goal)
	TweenService:Create(instance, tweenInfo, goal):Play()
end

local function makeButton(parent, text, items)
	local result = create("TextButton", { -- inferred equivalent call
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = Settings.TEXT,
		AutoButtonColor = false,
		BackgroundColor3 = Settings.CARD,
		BackgroundTransparency = 0.1,
		ZIndex = 8
	}, parent)

	for k, item in pairs(items) do
		result[k] = item
	end

	addCorner(result) -- inferred equivalent call
	return result, addStroke(result, Settings.BORDER, 0.3, 1) -- inferred equivalent call
end

local function makeLabel(parent, text, options)
	local label = create("TextLabel", { -- inferred equivalent call
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Settings.TEXT,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		ZIndex = 8
	}, parent)

	for k, v in pairs(options or {}) do
		label[k] = v
	end

	return label
end

local function newPreview(parent)
	local camera = Instance.new("Camera")
	camera.FieldOfView = 24
	camera.Parent = parent
	parent.CurrentCamera = camera

	local preview = {
		Viewport = parent,
		Yaw = 0,
		Center = Vector3.new(0, 0, 0),
		Distance = 10,
		Front = Vector3.new(0, 0, 1)
	}

	function preview.Update()
		local vectorToWorldSpace = CFrame.Angles(0, preview.Yaw, 0):VectorToWorldSpace(preview.Front)
		camera.CFrame = CFrame.lookAt(
			preview.Center + vectorToWorldSpace * preview.Distance,
			preview.Center,
			Vector3.new(0, 1, 0)
		) * CFrame.Angles(0, 0, 0.3839724354387525)
		parent.LightDirection = -vectorToWorldSpace + Vector3.new(0.4, -0.7, 0)
	end

	function preview.Set(p)
		for _, model in ipairs(parent:GetChildren()) do
			if model:IsA("Model") then
				model:Destroy()
			end
		end

		if not p then
			return
		end

		local folder = CustomGuitarBuilder.Build(p, "GuitarRhythm")

		if not folder then
			return
		end

		for _, part in ipairs(folder:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end

		folder:PivotTo(CFrame.new())
		folder.Parent = parent

		local family = CustomGuitarConfig.GetFamily(p.Family)
		preview.Front = (family and family.PreviewFront or Vector3.new(0, 0, 1)).Unit
		local boundingBox, v = folder:GetBoundingBox()
		preview.Center = boundingBox.Position
		preview.Distance = v.Magnitude / 2 / math.sin((math.rad(camera.FieldOfView / 2)))
		preview.Update()
	end

	return preview
end

local function newViewport(parent, options)
	local viewport = create( -- inferred equivalent call
		"ViewportFrame",
		{
			BackgroundTransparency = 1,
			Ambient = Color3.fromRGB(175, 175, 185),
			LightColor = Color3.fromRGB(255, 255, 255),
			ZIndex = 9
		},
		parent
	)

	for k, v in pairs(options or {}) do
		viewport[k] = v
	end

	return viewport
end

local parent2 = create("ScreenGui", { -- inferred equivalent call
	Name = "CustomGuitarShopUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 101,
	Enabled = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PlayerGui)

local screenGui = create("ScreenGui", { -- inferred equivalent call
	Name = "CustomGuitarShopToast",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 102,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PlayerGui)

local v = ThemeSwitchToast.new(screenGui)

create("TextButton", { -- inferred equivalent call
	Name = "Backdrop",
	Text = "",
	AutoButtonColor = false,
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.5,
	Size = UDim2.new(1, 0, 1, 0),
	ZIndex = 1
}, parent2)

local parent3 = create("Frame", { -- inferred equivalent call
	Name = "Window",
	BackgroundColor3 = Settings.BG,
	BackgroundTransparency = 0.05,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 680, 0, 440),
	Active = true,
	ZIndex = 5
}, parent2)
create("UICorner", { CornerRadius = UDim.new(0, 14) }, parent3) -- inferred equivalent call

addStroke(parent3, Settings.BORDER, 0.2, 1) -- inferred equivalent call
local uiScale = create("UIScale", { Scale = 1 }, parent3) -- inferred equivalent call

local function layoutForViewport() -- 2 equivalent calls inferred from this helper
	local currentCamera = Workspace.CurrentCamera
	local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
	local v2 = math.min((viewportSize.X - 24) / 680, (viewportSize.Y - 24) / 440)
	uiScale.Scale = math.clamp(v2, 0.45, 1.2)
end

makeLabel(parent3, "Custom Guitar", {
	Position = UDim2.new(0, 18, 0, 10),
	Size = UDim2.new(1, -80, 0, 26),
	TextSize = 17
})
makeLabel(parent3, "Design your own guitar. Built guitars appear in Equipment > Custom.", {
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextColor3 = Settings.TEXT_DIM,
	Position = UDim2.new(0, 18, 0, 36),
	Size = UDim2.new(1, -80, 0, 18)
})

local button = makeButton(parent3, "X", {
	Name = "Close",
	TextSize = 13,
	TextColor3 = Settings.TEXT_DIM,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -14, 0, 14),
	Size = UDim2.new(0, 28, 0, 28),
	BackgroundTransparency = 0.3
})

local parent4 = create("Frame", { -- inferred equivalent call
	Name = "ShopScreen",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 64),
	Size = UDim2.new(1, 0, 0, 376),
	ZIndex = 6
}, parent3)

local parent5 = create("Frame", { -- inferred equivalent call
	Name = "EditorScreen",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 64),
	Size = UDim2.new(1, 0, 0, 376),
	Visible = false,
	ZIndex = 6
}, parent3)

local v2 = math.floor((644 - 14 * (CustomGuitarConfig.MAX_SLOTS - 1)) / CustomGuitarConfig.MAX_SLOTS)

local v3 = {}
local v4 = nil

local function refreshDeleteButtons()
	for k, v5 in pairs(v3) do
		local v6 = v4 == k
		v5.Delete.Text = v6 and "Confirm delete?" or "Delete"
		v5.Delete.TextColor3 = v6 and Color3.fromRGB(255, 120, 120) or Settings.TEXT_DIM
	end
end

local showEditor
local count = 0
local closeShop

for i = 1, CustomGuitarConfig.MAX_SLOTS do
	local parent = create("Frame", { -- inferred equivalent call
		Name = "Slot" .. i,
		BackgroundColor3 = Settings.CARD,
		BackgroundTransparency = 0.12,
		Position = UDim2.new(0, (i - 1) * (v2 + 14) + 18, 0, 4),
		Size = UDim2.new(0, v2, 0, 348),
		ZIndex = 7
	}, parent4)
	create("UICorner", { CornerRadius = UDim.new(0, 12) }, parent) -- inferred equivalent call

	addStroke(parent, Settings.BORDER, 0.3, 1) -- inferred equivalent call

	local parent6 = create("Frame", { -- inferred equivalent call
		BackgroundColor3 = Color3.fromRGB(18, 14, 28),
		Position = UDim2.new(0, 8, 0, 8),
		Size = UDim2.new(1, -16, 0, 180),
		ClipsDescendants = true,
		ZIndex = 8
	}, parent)
	create("UICorner", { CornerRadius = UDim.new(0, 10) }, parent6) -- inferred equivalent call

	create( -- inferred equivalent call
		"UIGradient",
		{
			Rotation = 125,
			Color = ColorSequence.new(Color3.fromRGB(62, 37, 89), Color3.fromRGB(10, 8, 18))
		},
		parent6
	)

	local v5 = newViewport(parent6, { Size = UDim2.new(1, 0, 1, 0) })
	local label = makeLabel(parent6, "+", {
		Font = Enum.Font.GothamBold,
		TextSize = 44,
		TextColor3 = Settings.TEXT_DIM,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 10
	})

	local label2 = makeLabel(parent, "", {
		TextSize = 14,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.new(0, 12, 0, 196),
		Size = UDim2.new(1, -24, 0, 20)
	})

	local label3 = makeLabel(parent, "", {
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = Settings.TEXT_DIM,
		Position = UDim2.new(0, 12, 0, 218),
		Size = UDim2.new(1, -24, 0, 16)
	})

	local button2 = makeButton(parent, "Build New", {
		BackgroundColor3 = Settings.ACCENT,
		BackgroundTransparency = 0,
		TextColor3 = Settings.INPUT,
		Position = UDim2.new(0, 12, 0, 246),
		Size = UDim2.new(1, -24, 0, 32)
	})

	local button3 = makeButton(parent, "Delete", {
		TextSize = 11,
		TextColor3 = Settings.TEXT_DIM,
		Position = UDim2.new(0, 12, 0, 286),
		Size = UDim2.new(1, -24, 0, 26)
	})

	v3[i] = {
		Preview = newPreview(v5),
		Plus = label,
		Name = label2,
		Sub = label3,
		Primary = button2,
		Delete = button3,
		Signature = nil
	}

	button2.MouseButton1Click:Connect(function()
		v4 = nil
		refreshDeleteButtons()
		showEditor(i)
	end)

	button3.MouseButton1Click:Connect(function()
		if not CustomGuitarClient.GetDesign(i) then
			return
		end

		if v4 == i then
			v4 = nil
			refreshDeleteButtons()
			v:Show(CustomGuitarClient.Delete(i) and "Guitar deleted" or "Couldn't delete. Try again.")
		else
			v4 = i
			count += 1
			local v6 = count
			refreshDeleteButtons()
			task.delay(3, function()
				if v6 == count and v4 == i then
					v4 = nil
					refreshDeleteButtons()
				end
			end)
		end
	end)
end

local function refreshShop()
	for k, v5 in pairs(v3) do
		local design = CustomGuitarClient.GetDesign(k)
		local signature = design and CustomGuitarConfig.Signature(design) .. "|" .. design.Name or "empty"

		if v5.Signature ~= signature then
			v5.Signature = signature
			v5.Preview.Set(design)
		end

		v5.Plus.Visible = design == nil

		if design then
			local family = CustomGuitarConfig.GetFamily(design.Family)
			v5.Name.Text = design.Name
			v5.Sub.Text = (family and family.Name or "Guitar") .. " - " .. design.Finish
			v5.Primary.Text = "Edit"
		else
			v5.Name.Text = "Empty slot " .. k
			v5.Sub.Text = "Build a new guitar here"
			v5.Primary.Text = "Build New"
		end

		v5.Delete.Visible = design ~= nil
	end

	refreshDeleteButtons()
end

local parent6 = create("Frame", { -- inferred equivalent call
	Name = "PreviewFrame",
	BackgroundColor3 = Color3.fromRGB(18, 14, 28),
	Position = UDim2.new(0, 18, 0, 4),
	Size = UDim2.new(0, 268, 0, 348),
	ClipsDescendants = true,
	ZIndex = 7
}, parent5)
create("UICorner", { CornerRadius = UDim.new(0, 12) }, parent6) -- inferred equivalent call

addStroke(parent6, Settings.BORDER, 0.3, 1) -- inferred equivalent call
create( -- inferred equivalent call
	"UIGradient",
	{
		Rotation = 125,
		Color = ColorSequence.new(Color3.fromRGB(62, 37, 89), Color3.fromRGB(10, 8, 18))
	},
	parent6
)

local v5 = newViewport(parent6, { Size = UDim2.new(1, 0, 1, 0), Active = true })
local v6 = newPreview(v5)

makeLabel(parent6, "Drag to rotate", {
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextColor3 = Settings.TEXT_DIM,
	TextXAlignment = Enum.TextXAlignment.Center,
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -6),
	Size = UDim2.new(1, 0, 0, 14),
	ZIndex = 10
})

local v7 = false
local v8 = 0
v5.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v7 = true
		v8 = input.Position.X
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if not v7 then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		local v9 = input.Position.X - v8
		v8 = input.Position.X
		v6.Yaw -= v9 * 0.012
		v6.Update()
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v7 = false
	end
end)

local parent7 = create("ScrollingFrame", { -- inferred equivalent call
	Name = "Controls",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 302, 0, 4),
	Size = UDim2.new(0, 360, 0, 302),
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = Settings.BORDER,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ZIndex = 7
}, parent5)

create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder }, parent7) -- inferred equivalent call

create( -- inferred equivalent call
	"UIPadding",
	{
		PaddingLeft = UDim.new(0, 5),
		PaddingTop = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 6)
	},
	parent7
)

local parent8 = create("Frame", { -- inferred equivalent call
	Name = "ControlsFade",
	BackgroundColor3 = Settings.BG,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 302, 0, 280),
	Size = UDim2.new(0, 352, 0, 26),
	ZIndex = 9
}, parent5)

create("UIGradient", { -- inferred equivalent call
	Rotation = 90,
	Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.03) })
}, parent8)

local button2 = makeButton(parent5, "Back", {
	Position = UDim2.new(0, 302, 0, 318),
	Size = UDim2.new(0, 96, 0, 34)
})

local button3 = makeButton(parent5, "Build Guitar", {
	BackgroundColor3 = Settings.ACCENT,
	BackgroundTransparency = 0,
	TextColor3 = Settings.INPUT,
	Position = UDim2.new(0, 408, 0, 318),
	Size = UDim2.new(0, 254, 0, 34)
})

local v9 = nil
local flag = false

local function copyDesign(design)
	local v10 = { Family = design.Family, Name = design.Name, Finish = design.Finish, Colors = {} }

	for k, color in pairs(design.Colors) do
		v10.Colors[k] = color
	end

	return v10
end

local function updatePreview() -- 4 equivalent calls inferred from this helper
	if v9 then
		v6.Set(v9.Design)
	end
end

local function makePills(parent, list, fn, fn2, value)
	local pills = create("Frame", { -- inferred equivalent call
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 26),
		ZIndex = 8
	}, parent)

	create( -- inferred equivalent call
		"UIListLayout",
		{
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder
		},
		pills
	)

	local v10 = {}
	local function refresh()
		for _, v11 in ipairs(v10) do
			local v12 = fn(v11.Id)
			v11.Button.BackgroundColor3 = v12 and Settings.CARD_ACTIVE or Settings.CARD
			v11.Button.TextColor3 = v12 and Settings.ACCENT or Settings.TEXT_DIM
			v11.Stroke.Color = v12 and Settings.ACCENT or Settings.BORDER
			v11.Stroke.Transparency = v12 and 0.2 or 0.5
		end
	end

	for i, item in ipairs(list) do
		local button4, stroke = makeButton(pills, item.Label, {
			TextSize = 11,
			LayoutOrder = i,
			Size = UDim2.new(0, value or 88, 1, 0)
		})

		table.insert(v10, { Id = item.Id, Button = button4, Stroke = stroke })
		button4.MouseButton1Click:Connect(function()
			fn2(item.Id)
			refresh()
		end)
	end

	refresh()
	return pills
end

local function addSection(text, layoutOrder)
	local parent = create("Frame", { -- inferred equivalent call
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = layoutOrder,
		ZIndex = 8
	}, parent7)

	create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, parent) -- inferred equivalent call
	return
		parent,
		makeLabel(parent, text, {
			TextSize = 11,
			TextColor3 = Settings.TEXT_DIM,
			Size = UDim2.new(1, 0, 0, 16),
			LayoutOrder = 0
		})
end

local function rebuildControls()
	for _, child in ipairs(parent7:GetChildren()) do
		if not (child:IsA("UIListLayout") or child:IsA("UIPadding")) then
			child:Destroy()
		end
	end

	if not v9 then
		return
	end

	local design = v9.Design
	local family = CustomGuitarConfig.GetFamily(design.Family)

	local parent = addSection("BASE MODEL", 1)
	local v10 = {}

	for _, id in ipairs(CustomGuitarConfig.FamilyOrder) do
		table.insert(v10, { Id = id, Label = CustomGuitarConfig.Families[id].Name })
	end

	local pills = makePills(parent, v10, function(p): boolean
		return design.Family == p
	end, function(p)
		if design.Family == p then
			return
		end

		local design2 = CustomGuitarConfig.NewDesign(p)
		design2.Name = design.Name
		design2.Finish = design.Finish

		for k in pairs(design2.Colors) do
			if design.Colors[k] then
				design2.Colors[k] = design.Colors[k]
			end
		end

		v9.Design = design2
		updatePreview() -- inferred equivalent call
		task.defer(rebuildControls)
	end, 120)
	pills.LayoutOrder = 1

	local parent9 = addSection("NAME", 2)
	local parent10 = create("TextBox", { -- inferred equivalent call
		Text = design.Name,
		PlaceholderText = CustomGuitarConfig.DEFAULT_NAME,
		PlaceholderColor3 = Settings.TEXT_DIM,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = Settings.TEXT,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		BackgroundColor3 = Settings.INPUT,
		BackgroundTransparency = 0.1,
		Size = UDim2.new(1, 0, 0, 30),
		LayoutOrder = 1,
		ZIndex = 8
	}, parent9)
	addCorner(parent10) -- inferred equivalent call
	addStroke(parent10, Settings.BORDER, 0.4, 1) -- inferred equivalent call
	create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, parent10) -- inferred equivalent call
	parent10:GetPropertyChangedSignal("Text"):Connect(function()
		if #parent10.Text > CustomGuitarConfig.NAME_MAX then
			parent10.Text = string.sub(parent10.Text, 1, CustomGuitarConfig.NAME_MAX)
		end
	end)
	parent10.FocusLost:Connect(function()
		local v11 = string.gsub(parent10.Text, "^%s+", "")
		local v12 = string.gsub(v11, "%s+$", "")

		if v12 == "" then
			v12 = CustomGuitarConfig.DEFAULT_NAME
		end

		parent10.Text = v12

		if v9 then
			v9.Design.Name = v12
		end
	end)

	local parent11 = addSection("BODY FINISH", 3)
	local v11 = {}

	for _, id in ipairs(CustomGuitarConfig.FinishOrder) do
		table.insert(v11, { Id = id, Label = CustomGuitarConfig.Finishes[id].Label })
	end

	local pills_2 = makePills(parent11, v11, function(p): boolean
		return design.Finish == p
	end, function(finish)
		design.Finish = finish
		updatePreview() -- inferred equivalent call
	end, 76)
	pills_2.LayoutOrder = 1

	for i, v12 in ipairs(CustomGuitarConfig.GetSlotList(family)) do
		local parent12, v13 = addSection("", 10 + i)
		local function refreshHeader() -- 2 equivalent calls inferred from this helper
			local v14 = CustomGuitarConfig.Palette[design.Colors[v12]]
			v13.Text = string.upper(CustomGuitarConfig.SlotLabels[v12] or v12) .. "  -  " .. (v14 and v14.Name or "")
		end

		refreshHeader() -- inferred equivalent call
		local parent13 = create("Frame", { -- inferred equivalent call
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			LayoutOrder = 1,
			ZIndex = 8
		}, parent12)

		create( -- inferred equivalent call
			"UIGridLayout",
			{
				CellSize = UDim2.new(0, 24, 0, 24),
				CellPadding = UDim2.new(0, 5, 0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder
			},
			parent13
		)

		local v14 = {}
		local function refreshSwatches()
			for k, v15 in pairs(v14) do
				local v16 = design.Colors[v12] == k
				v15.Stroke.Color = v16 and Settings.ACCENT or Settings.BORDER
				v15.Stroke.Thickness = v16 and 2 or 1
				v15.Stroke.Transparency = v16 and 0 or 0.4
			end
		end

		for j, v15 in ipairs(CustomGuitarConfig.Palette) do
			local v16 = create("TextButton", { -- inferred equivalent call
				Text = "",
				AutoButtonColor = false,
				BackgroundColor3 = v15.Color,
				LayoutOrder = j,
				ZIndex = 9
			}, parent13)
			create("UICorner", { CornerRadius = UDim.new(0, 6) }, v16) -- inferred equivalent call

			local v17 = {
				Color = Settings.BORDER,
				Transparency = 0.4,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}
			local uiStroke = Instance.new("UIStroke")

			local v18 = { Button = v16, Stroke = 0 }

			for k, v19 in pairs(v17) do
				uiStroke[k] = v19
			end

			uiStroke.Parent = v16

			v18.Stroke = uiStroke
			v14[j] = v18
			local v19 = j
			v16.MouseButton1Click:Connect(function()
				design.Colors[v12] = v19
				refreshHeader() -- inferred equivalent call
				refreshSwatches()
				updatePreview() -- inferred equivalent call
			end)
		end

		refreshSwatches()
	end
end

local function designKey(design) -- 2 equivalent calls inferred from this helper
	return CustomGuitarConfig.Signature(design) .. "|" .. design.Name
end

local v10 = false
local count2 = 0

local function resetDiscard() -- 5 equivalent calls inferred from this helper
	v10 = false
	count2 += 1
	button2.Text = "Back"
end

showEditor = function(i)
	local design = CustomGuitarClient.GetDesign(i)
	v9 = {
		Slot = i,
		IsNew = design == nil,
		Design = design and copyDesign(design) or CustomGuitarConfig.NewDesign(CustomGuitarConfig.FamilyOrder[1])
	}

	v9.OriginalKey = designKey(v9.Design) -- inferred equivalent call
	resetDiscard() -- inferred equivalent call
	button3.Text = v9.IsNew and "Build Guitar" or "Save Changes"
	flag = false
	parent4.Visible = false
	parent5.Visible = true
	v6.Yaw = 0
	rebuildControls()
	updatePreview() -- inferred equivalent call
end

local function showShop() -- 2 equivalent calls inferred from this helper
	v9 = nil
	resetDiscard() -- inferred equivalent call
	v4 = nil
	parent5.Visible = false
	parent4.Visible = true
	refreshShop()
end

local function attemptLeave(p)
	if flag then
		return
	end

	if v9 and not v10 and designKey(v9.Design) ~= v9.OriginalKey then -- inferred equivalent call
		v10 = true
		count2 += 1
		local v11 = count2
		button2.Text = "Discard?"
		v:Show("Unsaved changes. Press again to discard them.")
		task.delay(3, function()
			if v11 == count2 and v10 then
				resetDiscard() -- inferred equivalent call
			end
		end)
		return
	end

	resetDiscard() -- inferred equivalent call

	if p then
		closeShop()
		return
	end

	showShop() -- inferred equivalent call
end

button2.MouseButton1Click:Connect(function()
	attemptLeave(false)
end)

button3.MouseButton1Click:Connect(function()
	if flag or not v9 then
		return
	end

	flag = true
	button3.Text = "Building..."
	local slot = v9.Slot
	local isNew = v9.IsNew
	local design = v9.Design

	if CustomGuitarClient.Save(slot, design) then
		local design2 = CustomGuitarClient.GetDesign(slot) or design

		local v11 = CustomGuitarCelebration.Play({
			Design = design2,
			IsNew = isNew,
			OnCovered = function()
				flag = false
				closeShop()
			end
		})

		flag = false
		closeShop()

		if v11 == "equip" then
			setEquippedSkin:FireServer(CustomGuitarConfig.SkinIdForSlot(slot), true)
			v:Show(design2.Name .. " equipped")
		end
	else
		flag = false
		button3.Text = isNew and "Build Guitar" or "Save Changes"
		v:Show("Couldn't save. Try again.")
	end
end)

local flag2 = false

closeShop = function()
	if not flag2 then
		return
	end

	flag2 = false
	UIPanelGate.Release("GuitarShop")
	v9 = nil
	resetDiscard() -- inferred equivalent call
	v7 = false
	parent2.Enabled = false
	SessionCameraSettings.SetMenuOpen(false)
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

local function openShop()
	if flag2 then
		return
	end

	if not CustomGuitarClient.Ready then
		v:Show("Still loading your guitars. Try again in a moment.")
		return
	end

	if not UIPanelGate.Request("GuitarShop") then
		return
	end

	flag2 = true
	SessionCameraSettings.SetMenuOpen(true)
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	layoutForViewport() -- inferred equivalent call
	showShop() -- inferred equivalent call
	parent2.Enabled = true
end

button.MouseButton1Click:Connect(function()
	attemptLeave(true)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not flag2 or flag then
		return
	end

	if input.KeyCode == Enum.KeyCode.Escape then
		attemptLeave(v9 == nil)
	end
end)

UIPanelGate.Register("GuitarShop", {
	Close = closeShop,
	IsOpen = function()
		return flag2
	end,
	CanClose = function(): boolean
		return not flag
	end
})

local v11 = 16
pcall(function()
	local PStudioConfig = require(ReplicatedStorage.Modules.PrivateStudio.PStudioConfig)
	v11 = PStudioConfig.PANEL_CLOSE_DISTANCE or v11
end)
local total = 0
local v12 = nil
RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < 0.5 then
		return
	end

	total = 0

	if not flag2 or flag then
		return
	end

	local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not (v12 and v12:IsDescendantOf(Workspace)) then
		closeShop()
	elseif humanoidRootPart then
		local magnitude = (humanoidRootPart.Position - v12.Position).Magnitude

		if v11 < magnitude then
			closeShop()
		end
	end
end)
LocalPlayer.CharacterRemoving:Connect(function()
	if flag2 and not flag then
		closeShop()
	end
end)

RunService:BindToRenderStep("CustomGuitarShopMouseOverride", Enum.RenderPriority.Camera.Value + 50, function()
	if not flag2 or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		return
	end

	if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end)

CustomGuitarClient.Changed:Connect(function()
	if flag2 and not v9 then
		refreshShop()
	end
end)

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
local CurrentCamera = Workspace.CurrentCamera
local viewportSize = CurrentCamera and CurrentCamera.ViewportSize or Vector2.new(1280, 720)
uiScale.Scale = math.clamp(math.min((viewportSize.X - 24) / 680, (viewportSize.Y - 24) / 440), 0.45, 1.2)

ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
	if player ~= LocalPlayer or prompt.Name ~= "GuitarShopPrompt" then
		return
	end

	local parent = prompt.Parent

	if not (parent and parent:IsA("BasePart")) then
		return
	end

	v12 = parent

	if flag2 then
		attemptLeave(true)
	else
		openShop()
	end
end)

local success, result = pcall(function()
	return require(ReplicatedStorage.Modules.SongListUI.UISkin)
end)

if success and result and result.AddRoot then
	pcall(result.AddRoot, parent2)
end