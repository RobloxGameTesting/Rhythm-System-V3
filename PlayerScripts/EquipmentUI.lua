local result = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local SkinConfig = require(ReplicatedStorage.Modules.SkinConfig)

local SettingsState = require(ReplicatedStorage.Modules.SettingsState)
local HighwaySkins = require(ReplicatedStorage.Modules.HighwaySkins)
local SessionCameraSettings = require(ReplicatedStorage.Modules.SessionCameraSettings)
local ThemeSwitchToast = require(ReplicatedStorage.Modules.ThemeSwitchToast)

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local SongSessionStatusUpdate = RemoteEvents:WaitForChild("SongSessionStatusUpdate")
local SetEquippedSkin = RemoteEvents:WaitForChild("SetEquippedSkin")
local SkinStateUpdate = RemoteEvents:WaitForChild("SkinStateUpdate")
local GetEquippedSkins = RemoteEvents:WaitForChild("GetEquippedSkins")
local GetPlayerSessionInfo = RemoteEvents:WaitForChild("GetPlayerSessionInfo")
local InstrumentTemplates = ReplicatedStorage:WaitForChild("InstrumentTemplates")

local CustomGuitarConfig = require(ReplicatedStorage.Modules.CustomGuitarConfig)
local CustomGuitarBuilder = require(ReplicatedStorage.Modules.CustomGuitarBuilder)
local CustomGuitarClient = require(ReplicatedStorage.Modules.CustomGuitarClient)
local UIPanelGate = require(ReplicatedStorage.Modules:WaitForChild("UIPanelGate"))

local localPlayer = result.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local StyledTheme = require(ReplicatedStorage.Modules.SongListUI.StyledTheme)
local Settings = StyledTheme.Settings

local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo3 = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function create(className, items, parent) -- 67 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function addCorner(parent, value) -- 5 equivalent calls inferred from this helper
	return create("UICorner", { -- inferred equivalent call
		CornerRadius = UDim.new(0, value or 8)
	}, parent)
end

local function addStroke(parent, color, transparency, thickness) -- 10 equivalent calls inferred from this helper
	return create( -- inferred equivalent call
		"UIStroke",
		{
			Color = color,
			Transparency = transparency,
			Thickness = thickness,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		},
		parent
	)
end

local function tween(instance, tweenInfo4, goal) -- 2 equivalent calls inferred from this helper
	local tween2 = TweenService:Create(instance, tweenInfo4, goal)
	tween2:Play()
	return tween2
end

local function getTopbarInset() -- 7 equivalent calls inferred from this helper
	return GuiService:GetGuiInset().Y
end

local function getViewportSize() -- 1 equivalent call inferred from this helper
	local currentCamera = Workspace.CurrentCamera
	return currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
end

local function getButtonCenterY()
	return getTopbarInset() / 2 + 30 + 6 -- inferred equivalent call
end

local function getPanelTop()
	return getTopbarInset() / 2 + 30 + 6 + 15 + 6 -- inferred equivalent call
end

local function computeScale() -- 1 equivalent call inferred from this helper
	local viewportSize = getViewportSize() -- inferred equivalent call
	local v = viewportSize.X - 24
	local v2 = viewportSize.Y - (getTopbarInset() / 2 + 30 + 6 + 15 + 6) - 8 -- inferred equivalent call
	return (math.clamp(math.min(v / 594, v2 / 380), 0.5, 1.25))
end

local v = {
	Name = "EquipmentUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 99,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}
local screenGui = Instance.new("ScreenGui")
local v2 = nil
local v3 = nil
local v4 = {}
local v5 = "All"
local v6 = "Instruments"
local flag = false
local v7 = "skin"
local flag2 = false
local count = 0
local v8 = false
local v9 = false
local v10 = false
local flag3 = false
local count2 = 0

for k, v11 in pairs(v) do
	screenGui[k] = v11
end

screenGui.Parent = playerGui

local v11 = ThemeSwitchToast.new(screenGui)

local textButton = create("TextButton", { -- inferred equivalent call
	Name = "Catcher",
	Text = "",
	AutoButtonColor = false,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	Visible = false,
	ZIndex = 1
}, screenGui)
local textButton2 = create("TextButton", { -- inferred equivalent call
	Name = "EquipmentButton",
	Text = "Equipment",
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	TextColor3 = Color3.fromRGB(245, 245, 247),
	AutoButtonColor = false,
	BackgroundColor3 = Color3.fromRGB(23, 23, 27),
	BackgroundTransparency = 0.25,
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -12, 0, getTopbarInset() / 2 + 30 + 6), -- inferred equivalent call
	Size = UDim2.new(0, 70, 0, 30),
	Visible = true,
	ZIndex = 20
}, screenGui)
addCorner(textButton2) -- inferred equivalent call
local v12 = addStroke(textButton2, Color3.fromRGB(60, 60, 70), 1, 1) -- inferred equivalent call
local frame = create("Frame", { -- inferred equivalent call
	Name = "Root",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -12, 0, getTopbarInset() / 2 + 30 + 6 + 15 + 6), -- inferred equivalent call
	Size = UDim2.new(0, 594, 0, 380),
	Visible = false,
	ZIndex = 5
}, screenGui)

local uiScale = create("UIScale", { Scale = 1 }, frame) -- inferred equivalent call

local parent2 = create("Frame", { -- inferred equivalent call
	Name = "ListPanel",
	BackgroundColor3 = Settings.BG,
	BackgroundTransparency = 0.12,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, 0, 0, 0),
	Size = UDim2.new(0, 340, 0, 380),
	ClipsDescendants = true,
	Active = true,
	ZIndex = 6
}, frame)
create("UICorner", { CornerRadius = UDim.new(0, 12) }, parent2) -- inferred equivalent call

addStroke(parent2, Settings.BORDER, 0.2, 1) -- inferred equivalent call

create("TextLabel", { -- inferred equivalent call
	Name = "Title",
	Text = "Equipment",
	Font = Enum.Font.GothamBold,
	TextSize = 15,
	TextColor3 = Settings.TEXT,
	TextXAlignment = Enum.TextXAlignment.Left,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 14, 0, 10),
	Size = UDim2.new(1, -60, 0, 24),
	ZIndex = 7
}, parent2)

local parent3 = create("TextButton", { -- inferred equivalent call
	Name = "Close",
	Text = "X",
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextColor3 = Settings.TEXT_DIM,
	AutoButtonColor = false,
	BackgroundColor3 = Settings.CARD,
	BackgroundTransparency = 0.3,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -10, 0, 10),
	Size = UDim2.new(0, 24, 0, 24),
	ZIndex = 8
}, parent2)
create("UICorner", { CornerRadius = UDim.new(0, 6) }, parent3) -- inferred equivalent call

local parent4 = create("Frame", { -- inferred equivalent call
	Name = "TabRow",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 12, 0, 40),
	Size = UDim2.new(1, -24, 0, 24),
	ZIndex = 7
}, parent2)

create( -- inferred equivalent call
	"UIListLayout",
	{
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder
	},
	parent4
)

local v13 = {}

for i, text in ipairs({ "Instruments", "Highways" }) do
	local v14 = create("TextButton", { -- inferred equivalent call
		Name = "Tab_" .. text,
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Settings.TEXT_DIM,
		AutoButtonColor = false,
		BackgroundColor3 = Settings.CARD,
		BackgroundTransparency = 0.2,
		LayoutOrder = i,
		Size = UDim2.new(0, text == "Instruments" and 100 or 88, 1, 0),
		ZIndex = 8
	}, parent4)
	addCorner(v14) -- inferred equivalent call
	local v15 = {
		Color = Settings.BORDER,
		Transparency = 0.5,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}
	local uiStroke = Instance.new("UIStroke")

	local v16 = { Button = v14, Stroke = 0 }

	for k, v17 in pairs(v15) do
		uiStroke[k] = v17
	end

	uiStroke.Parent = v14

	v16.Stroke = uiStroke
	v13[text] = v16
end

local parent5 = create("Frame", { -- inferred equivalent call
	Name = "FilterRow",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 12, 0, 72),
	Size = UDim2.new(1, -24, 0, 24),
	ZIndex = 7
}, parent2)

create( -- inferred equivalent call
	"UIListLayout",
	{
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder
	},
	parent5
)

local v14 = {}

for i, v15 in ipairs({ "All", "Guitar", "Bass", "Custom" }) do
	local v16 = create("TextButton", { -- inferred equivalent call
		Name = "Filter_" .. v15,
		Text = v15 == "All" and "All" or v15 == "Custom" and "Custom" or v15 .. " only",
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = Settings.TEXT_DIM,
		AutoButtonColor = false,
		BackgroundColor3 = Settings.CARD,
		BackgroundTransparency = 0.2,
		LayoutOrder = i,
		Size = UDim2.new(0, v15 == "All" and 48 or v15 == "Custom" and 62 or 86, 1, 0),
		ZIndex = 8
	}, parent5)
	create("UICorner", { CornerRadius = UDim.new(0, 12) }, v16) -- inferred equivalent call

	local v17 = {
		Color = Settings.BORDER,
		Transparency = 0.5,
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
	v14[v15] = v18
end

local parent6 = create("ScrollingFrame", { -- inferred equivalent call
	Name = "Grid",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 12, 0, 104),
	Size = UDim2.new(1, -24, 1, -116),
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = Settings.BORDER,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ZIndex = 7
}, parent2)

create( -- inferred equivalent call
	"UIGridLayout",
	{
		CellSize = UDim2.new(0, 98, 0, 126),
		CellPadding = UDim2.new(0, 8, 0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Left
	},
	parent6
)

create( -- inferred equivalent call
	"UIPadding",
	{ PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) },
	parent6
)

local parent7 = create("ScrollingFrame", { -- inferred equivalent call
	Name = "HighwayGrid",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 12, 0, 74),
	Size = UDim2.new(1, -24, 1, -86),
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = Settings.BORDER,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	Visible = false,
	ZIndex = 7
}, parent2)

create( -- inferred equivalent call
	"UIGridLayout",
	{
		CellSize = UDim2.new(0, 98, 0, 126),
		CellPadding = UDim2.new(0, 8, 0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Left
	},
	parent7
)

create( -- inferred equivalent call
	"UIPadding",
	{ PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) },
	parent7
)
local success
success, result = pcall(function()
	parent7.Position = UDim2.new(0, 12, 0, 104)
	parent7.Size = UDim2.new(1, -24, 1, -116)
	local parent = create("Frame", { -- inferred equivalent call
		Name = "RailHudRow",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 72),
		Size = UDim2.new(1, -24, 0, 26),
		Visible = false,
		ZIndex = 7
	}, parent2)
	local parent8 = create("TextButton", { -- inferred equivalent call
		Name = "RailHudToggle",
		AutoButtonColor = false,
		BackgroundColor3 = Settings.CARD,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 168, 1, 0),
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = Settings.TEXT,
		Text = "",
		ZIndex = 8
	}, parent)
	create("UICorner", { CornerRadius = UDim.new(0, 6) }, parent8) -- inferred equivalent call
	local uiStroke = create( -- inferred equivalent call
		"UIStroke",
		{ Color = Settings.BORDER, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border },
		parent8
	)
	create("TextLabel", { -- inferred equivalent call
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 176, 0, 0),
		Size = UDim2.new(1, -176, 1, 0),
		Font = Enum.Font.Gotham,
		TextSize = 10,
		TextColor3 = Settings.TEXT_DIM,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Text = "HUD 3D di rail: Rock Meter, Star Power, multiplier",
		ZIndex = 8
	}, parent)
	local function refreshRail() -- 2 equivalent calls inferred from this helper
		local railHud3D = SettingsState.GetRailHud3D()
		parent8.Text = "Rail HUD (3D): " .. (railHud3D and "ON" or "OFF")
		parent8.BackgroundColor3 = railHud3D and Settings.ACCENT or Settings.CARD
		parent8.TextColor3 = railHud3D and Settings.INPUT or Settings.TEXT
		uiStroke.Transparency = railHud3D and 1 or 0.4
	end
	parent8.MouseButton1Click:Connect(function()
		SettingsState.SetRailHud3D(not SettingsState.GetRailHud3D())
		refreshRail() -- inferred equivalent call
	end)
	SettingsState.OnChanged(refreshRail)
	refreshRail() -- inferred equivalent call
end)

if not success then
	warn("[EquipmentUI] Toggle Rail HUD gagal dibuat:", result)
end

local frame2 = create("Frame", { -- inferred equivalent call
	Name = "CardPanel",
	BackgroundColor3 = Settings.BG,
	BackgroundTransparency = 0.12,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -350, 0, 0),
	Size = UDim2.new(0, 244, 0, 0),
	ClipsDescendants = true,
	Active = true,
	Visible = false,
	ZIndex = 6
}, frame)
create("UICorner", { CornerRadius = UDim.new(0, 12) }, frame2) -- inferred equivalent call

addStroke(frame2, Settings.BORDER, 0.2, 1) -- inferred equivalent call

local parent8 = create("Frame", { -- inferred equivalent call
	Name = "ThumbBg",
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0,
	ClipsDescendants = true,
	Position = UDim2.new(0, 12, 0, 12),
	Size = UDim2.new(1, -24, 0, 140),
	ZIndex = 7
}, frame2)
create("UICorner", { CornerRadius = UDim.new(0, 10) }, parent8) -- inferred equivalent call

local v15 = addStroke(parent8, Settings.BORDER, 0.4, 1) -- inferred equivalent call
local uiGradient = create( -- inferred equivalent call
	"UIGradient",
	{
		Rotation = 125,
		Color = ColorSequence.new(Color3.fromRGB(62, 37, 89), Color3.fromRGB(10, 8, 18))
	},
	parent8
)

local imageLabel = create("ImageLabel", { -- inferred equivalent call
	Name = "BgImage",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	ScaleType = Enum.ScaleType.Crop,
	Image = "",
	Visible = false,
	ZIndex = 7
}, parent8)

local v16 = {}
local v17 = {}

for i, v18 in ipairs({
	{ 176, 0.9 },
	{ 124, 0.84 },
	{ 76, 0.76 }
}) do
	local parent = create("Frame", { -- inferred equivalent call
		Name = "Glow" .. i,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.52, 0),
		Size = UDim2.new(0, v18[1], 0, v18[1]),
		BackgroundColor3 = Settings.ACCENT,
		BackgroundTransparency = v18[2],
		BorderSizePixel = 0,
		ZIndex = 7
	}, parent8)

	create("UICorner", { CornerRadius = UDim.new(0.5, 0) }, parent) -- inferred equivalent call
	table.insert(v16, parent)
	table.insert(v17, parent)
end

local v18 = {}

for _, v19 in ipairs({
	{ 0.3, 24, 12 },
	{ 0.62, 20, 8 },
	{ 0.8, 28, 6 }
}) do
	local parent = create("Frame", { -- inferred equivalent call
		Name = "Ray",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(v19[1], 0, 0.5, 0),
		Size = UDim2.new(0, v19[3], 0, 280),
		Rotation = v19[2],
		BackgroundColor3 = Settings.ACCENT,
		BorderSizePixel = 0,
		ZIndex = 7
	}, parent8)

	create("UIGradient", { -- inferred equivalent call
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.9),
			NumberSequenceKeypoint.new(1, 1)
		})
	}, parent)

	table.insert(v18, parent)
	table.insert(v17, parent)
end

for i, v19 in ipairs({
	{ 0.08, 0.14, 3, 0.35 },
	{ 0.2, 0.78, 2, 0.5 },
	{ 0.33, 0.3, 2, 0.4 },
	{ 0.46, 0.12, 3, 0.3 },
	{ 0.58, 0.85, 2, 0.5 },
	{ 0.7, 0.2, 2, 0.35 },
	{ 0.84, 0.1, 3, 0.3 },
	{ 0.9, 0.55, 2, 0.45 },
	{ 0.13, 0.5, 2, 0.55 },
	{ 0.78, 0.8, 3, 0.4 },
	{ 0.52, 0.62, 2, 0.6 },
	{ 0.95, 0.3, 2, 0.5 }
}) do
	local frame3 = create("Frame", { -- inferred equivalent call
		Name = "Star",
		Position = UDim2.new(v19[1], 0, v19[2], 0),
		Size = UDim2.new(0, v19[3], 0, v19[3]),
		Rotation = 45,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = v19[4],
		BorderSizePixel = 0,
		ZIndex = 7
	}, parent8)

	TweenService:Create(
		frame3,
		TweenInfo.new(1.2 + i % 4 * 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, i % 5 * 0.25),
		{
			BackgroundTransparency = math.min(v19[4] + 0.45, 0.95)
		}
	):Play()
	table.insert(v17, frame3)
end

local parent9 = create("Frame", { -- inferred equivalent call
	Name = "Vignette",
	BackgroundColor3 = Color3.new(0, 0, 0),
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 1, 0),
	ZIndex = 7
}, parent8)

create("UIGradient", { -- inferred equivalent call
	Rotation = 90,
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.55),
		NumberSequenceKeypoint.new(0.35, 1),
		NumberSequenceKeypoint.new(0.7, 1),
		NumberSequenceKeypoint.new(1, 0.3)
	})
}, parent9)

local function applyCardDecoration(p, p2)
	local backgroundColor = p2 or SkinConfig.GetRarityColor(p)
	uiGradient.Color = ColorSequence.new(
		backgroundColor:Lerp(Color3.fromRGB(14, 10, 24), 0.72),
		Color3.fromRGB(10, 8, 18)
	)

	for _, v19 in ipairs(v16) do
		v19.BackgroundColor3 = backgroundColor
	end

	for _, v19 in ipairs(v18) do
		v19.BackgroundColor3 = backgroundColor:Lerp(Color3.new(1, 1, 1), 0.35)
	end

	local image = not p2 and SkinConfig.GetCardBackground(p) or nil

	if image then
		imageLabel.Image = image
		imageLabel.Visible = true
	else
		imageLabel.Image = ""
		imageLabel.Visible = false
	end

	for _, v19 in ipairs(v17) do
		v19.Visible = image == nil
	end
end

local viewportFrame = create("ViewportFrame", { -- inferred equivalent call
	Name = "Thumb",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, 0, 1, 0),
	Ambient = Color3.fromRGB(175, 175, 185),
	LightColor = Color3.fromRGB(255, 255, 255),
	ZIndex = 8
}, parent8)

local parent10 = create("ImageLabel", { -- inferred equivalent call
	Name = "HighwayImage",
	BackgroundColor3 = Color3.fromRGB(10, 10, 12),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 64, 1, -16),
	ScaleType = Enum.ScaleType.Crop,
	Image = "",
	Visible = false,
	ZIndex = 8
}, parent8)
create("UICorner", { CornerRadius = UDim.new(0, 6) }, parent10) -- inferred equivalent call

addStroke(parent10, Settings.BORDER, 0.3, 1) -- inferred equivalent call

local textLabel = create("TextLabel", { -- inferred equivalent call
	Name = "Name",
	Text = "",
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	TextColor3 = Settings.TEXT,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 14, 0, 160),
	Size = UDim2.new(1, -28, 0, 22),
	ZIndex = 7
}, frame2)

local parent11 = create("TextLabel", { -- inferred equivalent call
	Name = "Rarity",
	Text = "",
	Font = Enum.Font.GothamBold,
	TextSize = 10,
	TextColor3 = Settings.TEXT,
	BackgroundColor3 = Settings.CARD,
	BackgroundTransparency = 0.2,
	Position = UDim2.new(0, 14, 0, 186),
	Size = UDim2.new(0, 64, 0, 20),
	ZIndex = 7
}, frame2)
create("UICorner", { CornerRadius = UDim.new(0, 6) }, parent11) -- inferred equivalent call

local v19 = addStroke(parent11, Settings.BORDER, 0.2, 1) -- inferred equivalent call

local textLabel2 = create("TextLabel", { -- inferred equivalent call
	Name = "Category",
	Text = "",
	Font = Enum.Font.GothamMedium,
	TextSize = 10,
	TextColor3 = Settings.TEXT_DIM,
	TextXAlignment = Enum.TextXAlignment.Left,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 86, 0, 186),
	Size = UDim2.new(1, -100, 0, 20),
	ZIndex = 7
}, frame2)

local textLabel3 = create("TextLabel", { -- inferred equivalent call
	Name = "Description",
	Text = "",
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextColor3 = Settings.TEXT_DIM,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 14, 0, 214),
	Size = UDim2.new(1, -28, 0, 70),
	ZIndex = 7
}, frame2)

local parent12 = create("TextButton", { -- inferred equivalent call
	Name = "Unequip",
	Text = "Unequip",
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	AutoButtonColor = false,
	BackgroundColor3 = Settings.LIGHT,
	Position = UDim2.new(0, 14, 0, 296),
	Size = UDim2.new(1, -28, 0, 32),
	ZIndex = 8
}, frame2)
addCorner(parent12) -- inferred equivalent call
local v20 = addStroke(parent12, Settings.BORDER, 0.2, 1) -- inferred equivalent call

local parent13 = create("TextButton", { -- inferred equivalent call
	Name = "Equip",
	Text = "Equip",
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	AutoButtonColor = false,
	BackgroundColor3 = Settings.ACCENT,
	Position = UDim2.new(0, 14, 0, 336),
	Size = UDim2.new(1, -28, 0, 32),
	ZIndex = 8
}, frame2)
addCorner(parent13) -- inferred equivalent call
local v21 = addStroke(parent13, Settings.BORDER, 0.2, 1) -- inferred equivalent call

local function clearViewport(instance)
	for _, model in ipairs(instance:GetChildren()) do
		if model:IsA("Model") then
			model:Destroy()
		end
	end
end

local function mountModel(parent, data)
	clearViewport(parent)
	local folder

	if data.IsCustom then
		local design = CustomGuitarClient.GetDesign(data.Slot)
		folder = design and CustomGuitarBuilder.Build(design, "GuitarRhythm")

		if not folder then
			return
		end
	else
		local child = InstrumentTemplates:FindFirstChild(data.PreviewTemplate)

		if child then
			folder = child:Clone()
		else
			warn("[EquipmentUI] Template preview tidak ditemukan:", data.PreviewTemplate)
			return
		end
	end

	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end

	folder:PivotTo(CFrame.new())
	folder.Parent = parent

	local currentCamera = parent.CurrentCamera

	if not currentCamera then
		currentCamera = Instance.new("Camera")
		currentCamera.Parent = parent
		parent.CurrentCamera = currentCamera
	end

	local boundingBox, v22 = folder:GetBoundingBox()
	local position = boundingBox.Position

	local v23 = v22.Magnitude / 2 / 0.20791169081775934
	local unit = (data.PreviewFront or Vector3.new(0, 0, 1)).Unit

	currentCamera.FieldOfView = 24
	currentCamera.CFrame = CFrame.lookAt(position + unit * v23, position, Vector3.new(0, 1, 0)) * CFrame.Angles(0, 0, 0.3839724354387525)
	parent.LightDirection = -unit + Vector3.new(0.4, -0.7, 0)
end

local function displayName(data) -- 5 equivalent calls inferred from this helper
	if not data.IsCustom then
		return data.Name
	end

	local design = CustomGuitarClient.GetDesign(data.Slot)
	return design and design.Name or data.Name
end

local function displayDescription(data) -- 1 equivalent call inferred from this helper
	if not data.IsCustom then
		return data.Description
	end

	local design = CustomGuitarClient.GetDesign(data.Slot)
	local v22 = design and CustomGuitarConfig.GetFamily(design.Family)

	if v22 then
		return v22.Name .. " - " .. design.Finish .. " finish\nBuilt in Custom Guitar. Talk to the dummy to edit it."
	end

	return data.Description
end

local v22 = {}

local function createCell(data, i)
	local rarityColor = SkinConfig.GetRarityColor(data.Rarity)

	local button = create("TextButton", { -- inferred equivalent call
		Name = "Skin_" .. data.Id,
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Settings.CARD,
		BackgroundTransparency = 0.1,
		LayoutOrder = i,
		ZIndex = 8
	}, parent6)
	create("UICorner", { CornerRadius = UDim.new(0, 10) }, button) -- inferred equivalent call

	local stroke = addStroke(button, Settings.BORDER, 0.3, 1) -- inferred equivalent call

	local viewport = create("ViewportFrame", { -- inferred equivalent call
		Name = "Thumb",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 4, 0, 4),
		Size = UDim2.new(1, -8, 0, 84),
		Ambient = Color3.fromRGB(175, 175, 185),
		LightColor = Color3.fromRGB(255, 255, 255),
		ZIndex = 9
	}, button)

	create("TextLabel", { -- inferred equivalent call
		Name = "Name",
		Text = displayName(data), -- inferred equivalent call
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = Settings.TEXT,
		TextWrapped = true,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 5, 0, 90),
		Size = UDim2.new(1, -10, 0, 28),
		ZIndex = 9
	}, button)

	local parent = create("Frame", { -- inferred equivalent call
		Name = "RarityBar",
		BackgroundColor3 = rarityColor,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 1, -6),
		Size = UDim2.new(0.6, 0, 0, 3),
		ZIndex = 9
	}, button)
	create("UICorner", { CornerRadius = UDim.new(0, 2) }, parent) -- inferred equivalent call

	local badge = create("TextLabel", { -- inferred equivalent call
		Name = "EquippedBadge",
		Text = "EQUIPPED",
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		TextColor3 = Settings.INPUT,
		BackgroundColor3 = Settings.ACCENT,
		Position = UDim2.new(0, 7, 0, 7),
		Size = UDim2.new(0, 50, 0, 13),
		Visible = false,
		ZIndex = 11
	}, button)
	create("UICorner", { CornerRadius = UDim.new(0, 4) }, badge) -- inferred equivalent call

	button.MouseEnter:Connect(function()
		if v2 ~= data.Id then
			TweenService:Create(button, tweenInfo3, { BackgroundColor3 = Settings.CARD_ACTIVE }):Play()
		end
	end)
	button.MouseLeave:Connect(function()
		if v2 ~= data.Id then
			TweenService:Create(button, tweenInfo3, { BackgroundColor3 = Settings.CARD }):Play()
		end
	end)

	v22[data.Id] = { Button = button, Stroke = stroke, Viewport = viewport, Badge = badge }
end

for i, v23 in ipairs(SkinConfig.Order) do
	local v24 = SkinConfig.Get(v23)

	if v24 then
		createCell(v24, i)
	end
end

local v23 = {}

local function createHighwayCell(data, i)
	local button = create("TextButton", { -- inferred equivalent call
		Name = "Highway_" .. data.Id,
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Settings.CARD,
		BackgroundTransparency = 0.1,
		LayoutOrder = i,
		ZIndex = 8
	}, parent7)
	create("UICorner", { CornerRadius = UDim.new(0, 10) }, button) -- inferred equivalent call

	local stroke = addStroke(button, Settings.BORDER, 0.3, 1) -- inferred equivalent call

	local parent = create("ImageLabel", { -- inferred equivalent call
		Name = "Thumb",
		BackgroundColor3 = data.PlateColor or Color3.fromRGB(10, 10, 12),
		Image = data.Image,
		ScaleType = Enum.ScaleType.Crop,
		Position = UDim2.new(0, 4, 0, 4),
		Size = UDim2.new(1, -8, 0, 84),
		ZIndex = 9
	}, button)
	addCorner(parent) -- inferred equivalent call

	if data.IsRandom then
		parent.ImageTransparency = 0.7
		create("TextLabel", { -- inferred equivalent call
			Name = "RandomMark",
			Text = "?",
			Font = Enum.Font.GothamBlack,
			TextSize = 44,
			TextColor3 = Settings.ACCENT,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 10
		}, parent)
	end

	create("TextLabel", { -- inferred equivalent call
		Name = "Name",
		Text = data.Name,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = Settings.TEXT,
		TextWrapped = true,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 5, 0, 90),
		Size = UDim2.new(1, -10, 0, 28),
		ZIndex = 9
	}, button)

	local badge = create("TextLabel", { -- inferred equivalent call
		Name = "EquippedBadge",
		Text = "EQUIPPED",
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		TextColor3 = Settings.INPUT,
		BackgroundColor3 = Settings.ACCENT,
		Position = UDim2.new(0, 7, 0, 7),
		Size = UDim2.new(0, 50, 0, 13),
		Visible = false,
		ZIndex = 11
	}, button)
	create("UICorner", { CornerRadius = UDim.new(0, 4) }, badge) -- inferred equivalent call

	button.MouseEnter:Connect(function()
		if v3 ~= data.Id then
			TweenService:Create(button, tweenInfo3, { BackgroundColor3 = Settings.CARD_ACTIVE }):Play()
		end
	end)
	button.MouseLeave:Connect(function()
		if v3 ~= data.Id then
			TweenService:Create(button, tweenInfo3, { BackgroundColor3 = Settings.CARD }):Play()
		end
	end)

	v23[data.Id] = { Button = button, Stroke = stroke, Badge = badge }
end

for i, v24 in ipairs(HighwaySkins.GetAll()) do
	createHighwayCell(v24, i)
end

local function isEquipped(p): boolean -- 4 equivalent calls inferred from this helper
	local v24 = SkinConfig.Get(p)
	return v24 ~= nil and v4[v24.Category] == v24.Id
end

local function refreshFilters()
	for k, v24 in pairs(v14) do
		local v25 = k == v5
		v24.Button.BackgroundColor3 = v25 and Settings.CARD_ACTIVE or Settings.CARD
		v24.Button.TextColor3 = v25 and Settings.ACCENT or Settings.TEXT_DIM
		v24.Stroke.Color = v25 and Settings.ACCENT or Settings.BORDER
		v24.Stroke.Transparency = v25 and 0.2 or 0.5
	end
end

local function refreshCells()
	for k, v24 in pairs(v22) do
		local v25 = SkinConfig.Get(k)

		if v25.IsCustom then
			local button = v24.Button
			button.Visible = CustomGuitarClient.GetDesign(v25.Slot) ~= nil
				and (v5 == "All" or v5 == "Guitar" or v5 == "Custom")
		else
			v24.Button.Visible = v5 == "All" or v25.Category == v5
		end

		local badge = v24.Badge
		badge.Visible = isEquipped(k) -- inferred equivalent call
		local v26 = v2 == k
		v24.Stroke.Color = v26 and SkinConfig.GetRarityColor(v25.Rarity) or Settings.BORDER
		v24.Stroke.Thickness = v26 and 2 or 1
		v24.Stroke.Transparency = v26 and 0 or 0.3
		v24.Button.BackgroundColor3 = v26 and Settings.CARD_ACTIVE or Settings.CARD
	end
end

local function styleActionButton(p, p2, active, backgroundColor, input) -- 4 equivalent calls inferred from this helper
	p.Active = active
	p.AutoButtonColor = false

	if active then
		p.BackgroundColor3 = backgroundColor
		p.BackgroundTransparency = 0
		p.TextColor3 = input
		p2.Transparency = 1
	else
		p.BackgroundColor3 = Settings.CARD
		p.BackgroundTransparency = 0.5
		p.TextColor3 = Settings.TEXT_DIM
		p2.Transparency = 0.3
	end
end

local function refreshCard()
	local v24 = v2 and SkinConfig.Get(v2)

	if not v24 then
		return
	end

	local rarityColor = SkinConfig.GetRarityColor(v24.Rarity)
	textLabel.Text = displayName(v24) -- inferred equivalent call
	parent11.Text = string.upper(v24.Rarity)
	parent11.TextColor3 = rarityColor
	v19.Color = rarityColor
	textLabel2.Text = v24.Category
	textLabel3.Text = displayDescription(v24) -- inferred equivalent call
	applyCardDecoration(v24.Rarity)
	v15.Color = rarityColor
	v15.Transparency = 0.45

	local equipped = isEquipped(v24.Id) -- inferred equivalent call
	styleActionButton(parent12, v20, equipped, Settings.LIGHT, Settings.INPUT) -- inferred equivalent call
	styleActionButton(parent13, v21, not equipped, Settings.ACCENT, Settings.INPUT) -- inferred equivalent call
	parent13.Text = equipped and "Equipped" or "Equip"
end

local function currentHighwayId() -- 4 equivalent calls inferred from this helper
	return HighwaySkins.Get(SettingsState.GetHighwaySkin()).Id
end

local function refreshTabs()
	for k, v24 in pairs(v13) do
		local v25 = k == v6
		v24.Button.BackgroundColor3 = v25 and Settings.ACCENT or Settings.CARD
		v24.Button.BackgroundTransparency = v25 and 0 or 0.2
		v24.Button.TextColor3 = v25 and Settings.INPUT or Settings.TEXT_DIM
		v24.Stroke.Transparency = v25 and 1 or 0.5
	end

	local visible = v6 == "Instruments"
	parent5.Visible = visible
	parent6.Visible = visible
	parent7.Visible = not visible
	local railHudRow = parent2:FindFirstChild("RailHudRow")

	if railHudRow then
		railHudRow.Visible = not visible
	end
end

local function refreshHighwayCells()
	local id = currentHighwayId() -- inferred equivalent call

	for k, v24 in pairs(v23) do
		local v25 = v3 == k
		v24.Badge.Visible = k == id
		v24.Stroke.Color = v25 and Settings.ACCENT or Settings.BORDER
		v24.Stroke.Thickness = v25 and 2 or 1
		v24.Stroke.Transparency = v25 and 0 or 0.3
		v24.Button.BackgroundColor3 = v25 and Settings.CARD_ACTIVE or Settings.CARD
	end
end

local function refreshHighwayCard()
	local v24 = v3 and HighwaySkins.IsValid(v3) and HighwaySkins.Get(v3)

	if not v24 then
		return
	end

	textLabel.Text = v24.Name
	textLabel2.Text = "3D Highway"
	textLabel3.Text = v24.IsRandom
		and "A different highway every song, picked automatically.\nOnly shown with the 3D highway theme."
		or "Changes the look of your note highway.\nOnly shown with the 3D highway theme."

	applyCardDecoration(nil, Settings.ACCENT)
	v15.Color = Settings.ACCENT
	v15.Transparency = 0.45
	parent10.Image = v24.Image
	parent10.ImageTransparency = v24.IsRandom and 0.7 or 0
	parent10.BackgroundColor3 = v24.PlateColor or Color3.fromRGB(10, 10, 12)

	local v25 = v24.Id == currentHighwayId() -- inferred equivalent call
	styleActionButton(parent12, v20, v25 and v24.Id ~= HighwaySkins.DefaultId, Settings.LIGHT, Settings.INPUT) -- inferred equivalent call
	styleActionButton(parent13, v21, not v25, Settings.ACCENT, Settings.INPUT) -- inferred equivalent call
	parent13.Text = v25 and "Equipped" or "Equip"
end

local function refreshAll() -- 12 equivalent calls inferred from this helper
	refreshTabs()
	refreshFilters()
	refreshCells()
	refreshHighwayCells()

	if flag then
		if v7 == "highway" then
			refreshHighwayCard()
		else
			refreshCard()
		end
	end
end

local function ensureThumbnails()
	if flag2 then
		return
	end

	flag2 = true

	for k, v24 in pairs(v22) do
		local v25 = SkinConfig.Get(k)
		local success2, result2 = pcall(mountModel, v24.Viewport, v25)

		if not success2 then
			warn("[EquipmentUI] Gagal membuat thumbnail " .. k .. ": " .. tostring(result2))
		end
	end
end

local function setCardMode(p)
	v7 = p
	local visible = p == "highway"
	viewportFrame.Visible = not visible
	parent10.Visible = visible
	parent11.Visible = not visible
	textLabel2.Position = visible and UDim2.new(0, 14, 0, 186) or UDim2.new(0, 86, 0, 186)
	parent12.Text = visible and "Reset to Default" or "Unequip"
end

local function showCard(k)
	local v24 = SkinConfig.Get(k)

	if not v24 then
		return
	end

	v2 = k
	v3 = nil
	v7 = "skin"

	viewportFrame.Visible = true
	parent10.Visible = false
	parent11.Visible = true
	textLabel2.Position = UDim2.new(0, 86, 0, 186)
	parent12.Text = "Unequip"

	count += 1

	local success2, result2 = pcall(mountModel, viewportFrame, v24)

	if not success2 then
		warn("[EquipmentUI] Gagal membuat preview card: " .. tostring(result2))
	end

	if not flag then
		flag = true
		frame2.Size = UDim2.new(0, 244, 0, 0)
		frame2.Visible = true
		TweenService:Create(frame2, tweenInfo, { Size = UDim2.new(0, 244, 0, 380) }):Play()
	end

	refreshAll() -- inferred equivalent call
end

local function showHighwayCard(k)
	if not HighwaySkins.IsValid(k) then
		return
	end

	v2 = nil
	v3 = k
	v7 = "highway"

	viewportFrame.Visible = false
	parent10.Visible = true
	parent11.Visible = false
	textLabel2.Position = UDim2.new(0, 14, 0, 186) or UDim2.new(0, 86, 0, 186)
	parent12.Text = "Reset to Default"

	count += 1

	if not flag then
		flag = true
		frame2.Size = UDim2.new(0, 244, 0, 0)
		frame2.Visible = true
		TweenService:Create(frame2, tweenInfo, { Size = UDim2.new(0, 244, 0, 380) }):Play()
	end

	refreshAll() -- inferred equivalent call
end

local function hideCard(p)
	v2 = nil
	v3 = nil
	count += 1
	local v24 = count

	if flag then
		flag = false

		if p then
			frame2.Visible = false
			frame2.Size = UDim2.new(0, 244, 0, 0)
		else
			tween(frame2, tweenInfo2, { Size = UDim2.new(0, 244, 0, 0) }).Completed:Connect(function() -- inferred equivalent call
				if v24 == count and not flag then
					frame2.Visible = false
				end
			end)
		end
	end

	refreshCells()
	refreshHighwayCells()
end

local function refreshCustomCells()
	for k, v24 in pairs(v22) do
		local v25 = SkinConfig.Get(k)

		if not (v25 and v25.IsCustom) then
			continue
		end

		local design = CustomGuitarClient.GetDesign(v25.Slot)
		local signature = design and CustomGuitarConfig.Signature(design) .. "|" .. design.Name or "empty"

		if v24.Signature == signature then
			continue
		end

		v24.Signature = signature
		local name = v24.Button:FindFirstChild("Name")

		if name then
			name.AutoLocalize = false
			name.Text = displayName(v25) -- inferred equivalent call
		end

		if design then
			if flag2 then
				pcall(mountModel, v24.Viewport, v25)
			end
		else
			clearViewport(v24.Viewport)
		end

		if v2 ~= k then
			continue
		end

		if design then
			pcall(mountModel, viewportFrame, v25)
		else
			v2 = nil
			v3 = nil
			count += 1

			if flag then
				flag = false

				frame2.Visible = false
				frame2.Size = UDim2.new(0, 244, 0, 0)
			end

			refreshCells()
			refreshHighwayCells()
		end
	end

	refreshAll() -- inferred equivalent call
end

CustomGuitarClient.Changed:Connect(refreshCustomCells)

local v24 = {
	"SongListScreenGui",
	"ResultsScreenUI",
	"AmpSettingsUI",
	"MicSettingsUI",
	"LayoutEditorUI",
	"AudioCalibrateUI",
	"NewbieModePanelScreenGui",
	"CustomGuitarShopUI"
}

local function isBlockingMenuVisible(): boolean
	for _, childName in ipairs(v24) do
		local screenGui2 = playerGui:FindFirstChild(childName)

		if screenGui2 and screenGui2:IsA("ScreenGui") and screenGui2.Enabled then
			return true
		end
	end

	return false
end

local function shouldShowButton(): boolean -- 2 equivalent calls inferred from this helper
	return not (v8 or v9 or v10 or isBlockingMenuVisible())
end

local closePanel

local function updateButtonVisibility() -- 5 equivalent calls inferred from this helper
	local visible = shouldShowButton() -- inferred equivalent call
	textButton2.Visible = visible

	if not visible and flag3 then
		closePanel(true)
	end
end

local function layoutForViewport()
	textButton2.Position = UDim2.new(1, -12, 0, getTopbarInset() / 2 + 30 + 6) -- inferred equivalent call
	frame.Position = UDim2.new(1, -12, 0, getTopbarInset() / 2 + 30 + 6 + 15 + 6) -- inferred equivalent call
	uiScale.Scale = computeScale() -- inferred equivalent call
end

local function openPanel()
	if flag3 or v8 or v9 or v10 or isBlockingMenuVisible() then
		return
	end

	if not UIPanelGate.Request("Equipment") then
		return
	end

	flag3 = true
	count2 += 1
	SessionCameraSettings.SetMenuOpen(true)
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default

	layoutForViewport()
	ensureThumbnails()
	refreshAll() -- inferred equivalent call
	textButton.Visible = true
	frame.Visible = true
	parent2.Size = UDim2.new(0, 340, 0, 0)
	parent2.BackgroundTransparency = 1
	TweenService:Create(parent2, tweenInfo, {
		Size = UDim2.new(0, 340, 0, 380),
		BackgroundTransparency = 0.12
	}):Play()
	TweenService:Create(textButton2, tweenInfo3, { BackgroundColor3 = Color3.fromRGB(50, 50, 58) }):Play()
	v12.Color = Settings.ACCENT
	v12.Transparency = 0.5
end

closePanel = function(p)
	if not flag3 then
		return
	end

	flag3 = false
	UIPanelGate.Release("Equipment")
	count2 += 1
	local v25 = count2
	v2 = nil
	v3 = nil
	count += 1

	if flag then
		flag = false

		frame2.Visible = false
		frame2.Size = UDim2.new(0, 244, 0, 0)
	end

	refreshCells()
	refreshHighwayCells()

	textButton.Visible = false
	SessionCameraSettings.SetMenuOpen(false)

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	TweenService:Create(textButton2, tweenInfo3, { BackgroundColor3 = Color3.fromRGB(23, 23, 27) }):Play()
	v12.Color = Color3.fromRGB(60, 60, 70)
	v12.Transparency = 1

	if p then
		frame.Visible = false
		return
	end

	tween(parent2, tweenInfo2, { Size = UDim2.new(0, 340, 0, 0), BackgroundTransparency = 1 }).Completed:Connect(function() -- inferred equivalent call
		if v25 == count2 and not flag3 then
			frame.Visible = false
		end
	end)
end

UIPanelGate.Register("Equipment", {
	Close = function()
		closePanel(true)
	end,
	IsOpen = function()
		return flag3
	end
})

textButton2.MouseButton1Click:Connect(function()
	if flag3 then
		closePanel()
	else
		openPanel()
	end
end)

textButton2.MouseEnter:Connect(function()
	if not flag3 then
		TweenService:Create(textButton2, tweenInfo3, {
			BackgroundColor3 = Color3.fromRGB(50, 50, 58)
		}):Play()
	end
end)
textButton2.MouseLeave:Connect(function()
	if not flag3 then
		TweenService:Create(textButton2, tweenInfo3, {
			BackgroundColor3 = Color3.fromRGB(23, 23, 27)
		}):Play()
	end
end)

parent3.MouseButton1Click:Connect(function()
	closePanel()
end)

textButton.MouseButton1Click:Connect(function()
	closePanel()
end)

for k, v25 in pairs(v14) do
	v25.Button.MouseButton1Click:Connect(function()
		v5 = k
		refreshAll() -- inferred equivalent call
	end)
end

for k, v25 in pairs(v22) do
	v25.Button.MouseButton1Click:Connect(function()
		if flag and v2 == k then
			hideCard()
		else
			showCard(k)
		end
	end)
end

for k, v25 in pairs(v23) do
	v25.Button.MouseButton1Click:Connect(function()
		if flag and v7 == "highway" and v3 == k then
			hideCard()
		else
			showHighwayCard(k)
		end
	end)
end

for k, v25 in pairs(v13) do
	v25.Button.MouseButton1Click:Connect(function()
		if v6 == k then
			return
		end

		v2 = nil
		v3 = nil
		count += 1

		if flag then
			flag = false

			frame2.Visible = false
			frame2.Size = UDim2.new(0, 244, 0, 0)
		end

		refreshCells()
		refreshHighwayCells()

		v6 = k
		refreshAll() -- inferred equivalent call
	end)
end

parent13.MouseButton1Click:Connect(function()
	if v7 == "highway" then
		local v25 = v3 and HighwaySkins.IsValid(v3) and HighwaySkins.Get(v3)

		if v25 and v25.Id ~= currentHighwayId() then -- inferred equivalent call
			SettingsState.SetHighwaySkin(v25.Id)
			refreshAll() -- inferred equivalent call
			v11:Show(v25.Name .. " highway equipped")
		end
	else
		local v25 = v2 and SkinConfig.Get(v2)

		if v25 and not isEquipped(v25.Id) then -- inferred equivalent call
			v4[v25.Category] = v25.Id
			SetEquippedSkin:FireServer(v25.Id, true)
			refreshAll() -- inferred equivalent call
			v11:Show(displayName(v25) .. " equipped") -- inferred equivalent call
		end
	end
end)

parent12.MouseButton1Click:Connect(function()
	if v7 == "highway" then
		if currentHighwayId() ~= HighwaySkins.DefaultId then -- inferred equivalent call
			SettingsState.SetHighwaySkin(HighwaySkins.DefaultId)
			refreshAll() -- inferred equivalent call
			v11:Show("Highway reset to default")
		end
	else
		local v25 = v2 and SkinConfig.Get(v2)

		if v25 and isEquipped(v25.Id) then -- inferred equivalent call
			v4[v25.Category] = nil
			SetEquippedSkin:FireServer(v25.Id, false)
			refreshAll() -- inferred equivalent call
			v11:Show(displayName(v25) .. " unequipped (default skin)") -- inferred equivalent call
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.Escape and flag3 then
		closePanel()
	end
end)

RunService:BindToRenderStep("EquipmentMouseOverride", Enum.RenderPriority.Camera.Value + 50, function()
	if not flag3 or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		return
	end

	if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end)

local function applyServerState(result2)
	v4 = {}

	if typeof(result2) == "table" then
		for _, category in ipairs(SkinConfig.Categories) do
			if type(result2[category]) == "string" then
				v4[category] = result2[category]
			end
		end
	end

	refreshAll() -- inferred equivalent call
end

SkinStateUpdate.OnClientEvent:Connect(applyServerState)

task.spawn(function()
	for i = 1, 5 do
		local success2, result2 = pcall(function()
			return GetEquippedSkins:InvokeServer()
		end)

		if success2 then
			applyServerState(result2)
			return
		end

		task.wait(i)
	end

	warn("[EquipmentUI] Gagal mengambil state skin dari server")
end)

local count3 = 0

local function startSessionVerification() -- 1 equivalent call inferred from this helper
	count3 += 1
	local v25 = count3
	task.spawn(function()
		local v26 = 0

		while v8 and v25 == count3 do
			task.wait(3)

			if not v8 or v25 ~= count3 then
				break
			end

			local success2, result2 = pcall(function()
				return GetPlayerSessionInfo:InvokeServer(localPlayer)
			end)

			if not success2 then
				continue
			end

			v26 = result2 ~= nil and 0 or v26 + 1

			if v26 >= 2 and v8 and v25 == count3 then
				v8 = false
				updateButtonVisibility() -- inferred equivalent call
				break
			end
		end
	end)
end

SongSessionStatusUpdate.OnClientEvent:Connect(function(p)
	v8 = p == true

	if v8 then
		startSessionVerification() -- inferred equivalent call
	else
		count3 += 1
	end

	updateButtonVisibility() -- inferred equivalent call
end)
local success2
success2, result = pcall(function()
	return require(ReplicatedStorage.Modules.LaptopUI.LaptopClientController)
end)

if success2 and result then
	result.OnEnter(function()
		v9 = true
		updateButtonVisibility() -- inferred equivalent call
	end)
	result.OnExit(function()
		v9 = false
		updateButtonVisibility() -- inferred equivalent call
	end)
else
	warn("[EquipmentUI] LaptopClientController tidak bisa di-require, deteksi Laptop dilewati")
end

local screenGuiSet = {}
local function watchBlockingGui(screenGui2)
	if screenGuiSet[screenGui2] or not screenGui2:IsA("ScreenGui") then
		return
	end

	for _, v25 in ipairs(v24) do
		if screenGui2.Name == v25 then
			screenGuiSet[screenGui2] = true
			screenGui2:GetPropertyChangedSignal("Enabled"):Connect(updateButtonVisibility)
			break
		end
	end
end

for _, child in ipairs(playerGui:GetChildren()) do
	watchBlockingGui(child)
end

playerGui.ChildAdded:Connect(watchBlockingGui)

task.spawn(function()
	local settingsMenuUI = playerGui:WaitForChild("SettingsMenuUI", 30)
	local dropdown = settingsMenuUI and settingsMenuUI:WaitForChild("Dropdown", 30)

	if not dropdown then
		warn("[EquipmentUI] SettingsMenuUI.Dropdown tidak ditemukan, sinkron dgn Settings dilewati")
		return
	end

	local function sync() -- 1 equivalent call inferred from this helper
		v10 = dropdown.Visible
		updateButtonVisibility() -- inferred equivalent call
	end
	dropdown:GetPropertyChangedSignal("Visible"):Connect(sync)
	sync() -- inferred equivalent call
end)

local function watchViewport(instance) -- 2 equivalent calls inferred from this helper
	if instance then
		instance:GetPropertyChangedSignal("ViewportSize"):Connect(layoutForViewport)
	end
end
result = Workspace.CurrentCamera
watchViewport(result) -- inferred equivalent call
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	watchViewport(Workspace.CurrentCamera) -- inferred equivalent call
	layoutForViewport()
end)

SettingsState.OnChanged(function()
	refreshHighwayCells()

	if flag and v7 == "highway" then
		refreshHighwayCard()
	end
end)

layoutForViewport()
refreshAll() -- inferred equivalent call
result = shouldShowButton() -- inferred equivalent call
textButton2.Visible = result

if not result and flag3 then
	closePanel(true)
end

local UISkin = require(ReplicatedStorage.Modules.SongListUI.UISkin)
UISkin.AddRoot(screenGui)