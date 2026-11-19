local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local InputRouter = require(Modules:WaitForChild("InputRouter"))
local ModeManager = require(Modules:WaitForChild("ModeManager"))
local FreePlayController = require(Modules:WaitForChild("FreePlayController"))
local FreePlayAssetPreloader = require(Modules:WaitForChild("FreePlayAssetPreloader"))
local PianoTones = require(Modules:WaitForChild("PianoTones"))
local SettingsState = require(Modules:WaitForChild("SettingsState"))
local FreePlaySyncStyle = require(Modules:WaitForChild("FreePlaySyncStyle"))

local instrumentHUDUpdate = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InstrumentHUDUpdate")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local Palette = FreePlaySyncStyle.Palette
local Make = FreePlaySyncStyle.Make
local FONT_HEAD = FreePlaySyncStyle.FONT_HEAD

local LaneCount = PianoTones.LaneCount
local LowestMidi = PianoTones.LowestMidi

local color = Color3.fromRGB(30, 30, 32)
local color2 = Color3.fromRGB(58, 58, 62)
local color3 = Color3.fromRGB(122, 70, 176)
local color4 = Color3.fromRGB(184, 40, 40)
local color5 = Color3.fromRGB(235, 235, 235)

local color6 = Color3.fromRGB(255, 250, 238)
local color7 = Color3.fromRGB(246, 188, 56)
local color8 = Color3.fromRGB(40, 38, 40)
local color9 = Color3.fromRGB(222, 156, 40)
local color10 = Color3.fromRGB(20, 20, 22)

local function isPointerInput(input): boolean -- 2 equivalent calls inferred from this helper
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function getOpacity()
	local success, freePlayOpacity = pcall(SettingsState.GetFreePlayOpacity)

	if success and typeof(freePlayOpacity) == "number" then
		return (math.clamp(freePlayOpacity, 0.2, 1))
	end

	return 0.58
end

local function glassTransparency(): number -- 2 equivalent calls inferred from this helper
	return 0
end

local pianoFreePlayUI = Instance.new("ScreenGui")
pianoFreePlayUI.Name = "PianoFreePlayUI"
pianoFreePlayUI.ResetOnSpawn = false
pianoFreePlayUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pianoFreePlayUI.IgnoreGuiInset = false
pianoFreePlayUI.DisplayOrder = 20
pianoFreePlayUI.Enabled = false
pianoFreePlayUI.Parent = PlayerGui
local v = {
	[0] = true,
	[2] = true,
	[4] = true,
	[5] = true,
	[7] = true,
	[9] = true,
	[11] = true
}
local count = 0
local v2 = {
	"C",
	"C#",
	"D",
	"D#",
	"E",
	"F",
	"F#",
	"G",
	"G#",
	"A",
	"A#",
	"B"
}

for i = 1, LaneCount do
	if v[(LowestMidi + i - 1) % 12] then
		count += 1
	end
end

local v3 = count * 26
local v4 = v3 + 32

local make = Make("Frame", {
	Name = "Panel",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -10),
	Size = UDim2.fromOffset(v4, 224),
	BackgroundTransparency = 1,
	BorderSizePixel = 0
}, pianoFreePlayUI)

local make2 = Make("UIScale", {}, make)

local fn
local function layoutPanel() -- 3 equivalent calls inferred from this helper
	if fn then
		fn()
	end
end

layoutPanel() -- inferred equivalent call
local CurrentCamera = Workspace.CurrentCamera

if CurrentCamera then
	CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutPanel)
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	layoutPanel() -- inferred equivalent call
	local currentCamera = Workspace.CurrentCamera

	if currentCamera then
		currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutPanel)
	end
end)

local set = {}

local function plateGrime(p, p2)
	local random = Random.new(p2)

	for _ = 1, 5 do
		Make("Frame", {
			BackgroundColor3 = Color3.fromRGB(230, 230, 236),
			BackgroundTransparency = 0.8 + random:NextNumber() * 0.12,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber() * 0.85, random:NextNumber()),
			Size = UDim2.fromOffset(random:NextInteger(14, 70), 1),
			Rotation = random:NextInteger(-28, 28)
		}, p)
	end

	for i = 1, 5 do
		local integer = random:NextInteger(10, 28)
		local make3 = Make("Frame", {
			BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(104, 56, 30) or Color3.new(0, 0, 0),
			BackgroundTransparency = 0.78 + random:NextNumber() * 0.1,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.fromScale(random:NextNumber() * 0.9, random:NextNumber() * 0.7),
			Size = UDim2.fromOffset(integer, (math.floor(integer * 0.6)))
		}, p)

		Make("UICorner", { CornerRadius = UDim.new(1, 0) }, make3)
	end
end

local function styleGlass(button)
	button.AutoButtonColor = false
	button.BorderSizePixel = 0
	button.Font = FONT_HEAD
	button.TextSize = 15
	button.TextColor3 = color5
	button.BackgroundColor3 = color
	button.BackgroundTransparency = 0
	button.TextTruncate = Enum.TextTruncate.AtEnd
	Make("UICorner", { CornerRadius = UDim.new(0, 2) }, button)
	Make(
		"UIStroke",
		{
			Color = color2,
			Thickness = 1.5,
			Transparency = 0.1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		},
		button
	)

	Make(
		"UIGradient",
		{
			Rotation = 90,
			Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(176, 176, 182))
		},
		button
	)

	Make("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.82,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.new(0, 2, 0, 1),
		Size = UDim2.new(1, -4, 0, 1)
	}, button)

	plateGrime(button, #button.Name * 13 + 7)
	local v5 = glassTransparency() -- inferred equivalent call

	for i = 1, #button.Name do
		v5 = (v5 * 31 + string.byte(button.Name, i)) % 100003
	end

	local random = Random.new(v5 + 11)

	for _, v6 in ipairs({
		{ 0, 0 },
		{ 1, 0 },
		{ 0, 1 },
		{ 1, 1 }
	}) do
		if not (random:NextNumber() > 0.12) then
			continue
		end

		local integer = random:NextInteger(3, 5)
		local v7 = 3.5 + random:NextNumber() * 3 - 1.5
		local v8 = 3.5 + random:NextNumber() * 3 - 1.5
		local integer2 = random:NextInteger(60, 108)
		local v9 = random:NextNumber() > 0.6
		local make3 = Make("Frame", {
			AnchorPoint = Vector2.new(v6[1], v6[2]),
			Position = UDim2.new(v6[1], v6[1] == 0 and v7 or -v7, v6[2], v6[2] == 0 and v8 or -v8),
			Size = UDim2.fromOffset(integer, integer),
			BackgroundColor3 = v9 and Color3.fromRGB(
				integer2 + 34,
				math.floor(integer2 * 0.62),
				(math.floor(integer2 * 0.42))
			) or Color3.fromRGB(integer2, integer2, integer2 + 6),
			BorderSizePixel = 0,
			Active = false
		}, button)

		Make("UICorner", { CornerRadius = UDim.new(1, 0) }, make3)
		Make("UIStroke", {
			Color = Color3.fromRGB(14, 14, 16),
			Thickness = 1,
			Transparency = 0.1 + random:NextNumber() * 0.4
		}, make3)

		Make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(1, integer),
			BackgroundColor3 = Color3.fromRGB(10, 10, 12),
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			Active = false,
			Rotation = random:NextInteger(0, 170)
		}, make3)
	end

	set[button] = true
end

local make3 = Make("Frame", {
	Name = "Header",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 28)
}, make)

local make4 = Make("Frame", {
	Name = "Left",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, -80, 1, 0)
}, make3)

Make(
	"UIListLayout",
	{
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	},
	make4
)

local function makeButton(p, name, text, p2, layoutOrder)
	local button = Make(
		"TextButton",
		{ Name = name, Text = text, Size = UDim2.fromOffset(p2, 28), LayoutOrder = layoutOrder },
		p
	)

	styleGlass(button)
	return button
end

local button = makeButton(make4, "ToneButton", "TONE", 210, 1)
local button2 = makeButton(make4, "PedalButton", "SUSTAIN (Space)", 120, 2)
local button3 = makeButton(make4, "LockButton", "SUSTAIN LOCK: OFF", 140, 3)

local button4 = makeButton(make3, "CloseButton", "CLOSE", 72, 1)
button4.AnchorPoint = Vector2.new(1, 0)
button4.Position = UDim2.new(1, 0, 0, 0)
button4.BackgroundColor3 = color4

local function setButtonActive(button5, p) -- 2 equivalent calls inferred from this helper
	button5.BackgroundColor3 = p and color3 or color
	button5.TextColor3 = p and Color3.new(1, 1, 1) or color5
end

local function toneDisplayName(currentTone) -- 1 equivalent call inferred from this helper
	local tone = PianoTones.Tones[currentTone]
	return tone and tone.DisplayName or tostring(currentTone)
end

local function refreshToneButton() -- 4 equivalent calls inferred from this helper
	local currentTone = FreePlayController.GetCurrentTone()
	local text

	if currentTone then
		text = "TONE: " .. string.upper(toneDisplayName(currentTone)) or "TONE" -- inferred equivalent call
	else
		text = "TONE"
	end

	button.Text = text
end

button.Activated:Connect(function()
	local cycleTone = FreePlayController.CycleTone()

	if not cycleTone then
		return
	end

	refreshToneButton() -- inferred equivalent call

	if FreePlayAssetPreloader.IsPreloaded("Piano", cycleTone) ~= true then
		FreePlayAssetPreloader.EnsureLoaded("Piano", cycleTone, "Loading piano...")
	end
end)

local function refreshPedalButtons()
	setButtonActive(button2, FreePlayController.IsPedalDown()) -- inferred equivalent call
	local isPedalLocked = FreePlayController.IsPedalLocked()
	local compact = make:GetAttribute("Compact") == true
	button3.Text = (compact and "LOCK: " or "SUSTAIN LOCK: ") .. (isPedalLocked and "ON" or "OFF")
	setButtonActive(button3, isPedalLocked) -- inferred equivalent call
end

local v5 = {}

button2.InputBegan:Connect(function(input)
	if not isPointerInput(input) or v5[input] then -- inferred equivalent call
		return
	end

	v5[input] = true
	InputRouter.HandlePedal(true)
end)

button3.Activated:Connect(function()
	FreePlayController.SetPedalLock(not FreePlayController.IsPedalLocked())
	refreshPedalButtons()
end)

button4.Activated:Connect(function()
	ModeManager.SetRhythm()
end)

local make5 = Make("Frame", {
	Name = "Board",
	Position = UDim2.fromOffset(0, 38),
	Size = UDim2.new(1, 0, 0, 186),
	BackgroundColor3 = color10,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	ZIndex = 1
}, make)

Make("UICorner", { CornerRadius = UDim.new(0, 3) }, make5)
Make(
	"UIStroke",
	{
		Color = Color3.fromRGB(8, 8, 10),
		Thickness = 2,
		Transparency = 0.15,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	},
	make5
)

local random = Random.new(4242)
local make6 = Make("Frame", {
	Name = "Decor",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Active = false,
	Size = UDim2.fromScale(1, 1),
	ClipsDescendants = true,
	ZIndex = 1
}, make5)

local function rail(name, position, size, anchorPoint, rotation)
	local make7 = Make("Frame", {
		Name = name,
		BackgroundColor3 = Color3.fromRGB(32, 32, 35),
		BorderSizePixel = 0,
		Active = false,
		AnchorPoint = anchorPoint,
		Position = position,
		Size = size
	}, make6)

	Make(
		"UIGradient",
		{
			Rotation = rotation,
			Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(120, 120, 126))
		},
		make7
	)
end
rail("RailTop", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 18), Vector2.new(0, 0), 90)
rail("RailBottom", UDim2.new(0, 0, 1, 0), UDim2.new(1, 0, 0, 18), Vector2.new(0, 1), -90)
rail("RailLeft", UDim2.new(0, 0, 0, 0), UDim2.new(0, 16, 1, 0), Vector2.new(0, 0), 0)
rail("RailRight", UDim2.new(1, 0, 0, 0), UDim2.new(0, 16, 1, 0), Vector2.new(1, 0), 180)

local function box(p, p2, p3, p4, backgroundColor, backgroundTransparency, value)
	return Make("Frame", {
		BackgroundColor3 = backgroundColor,
		BackgroundTransparency = backgroundTransparency,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.fromScale(p, p2),
		Size = UDim2.fromOffset(p3, p4),
		Rotation = value or 0
	}, make6)
end

for _ = 1, 10 do
	local integer = random:NextInteger(60, 200)
	local v6 = box(
		random:NextNumber(),
		random:NextNumber(),
		integer,
		math.floor(integer * 0.35),
		Color3.new(0, 0, 0),
		0.78 + random:NextNumber() * 0.08,
		0
	)
	Make("UICorner", { CornerRadius = UDim.new(1, 0) }, v6)
end

for _ = 1, 70 do
	box(
		random:NextNumber(),
		random:NextNumber(),
		random:NextInteger(30, 300),
		1,
		Color3.fromRGB(215, 215, 224),
		0.86 + random:NextNumber() * 0.1,
		random:NextInteger(-30, 30)
	)
end

for _ = 1, 60 do
	local v6 = random:NextNumber() > 0.5
	local integer = random:NextInteger(2, 5)
	box(
		random:NextNumber(),
		random:NextNumber(),
		integer,
		integer,
		v6 and Color3.fromRGB(128, 66, 34) or Color3.fromRGB(200, 200, 206),
		v6 and 0.62 + random:NextNumber() * 0.2 or 0.82 + random:NextNumber() * 0.1,
		0
	)
end

for _, v6 in ipairs({ 0.03, 0.18, 0.36, 0.5, 0.64, 0.82, 0.97 }) do
	for _, v7 in ipairs({ 0, 1 }) do
		if not (random:NextNumber() > 0.1) then
			continue
		end

		local integer = random:NextInteger(6, 9)
		local v8 = v6 + (random:NextNumber() - 0.5) * 0.02
		local v9 = (random:NextNumber() - 0.5) * 3
		local integer2 = random:NextInteger(58, 104)
		local v10 = random:NextNumber() > 0.65
		local make7 = Make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(v8, 0, v7, (v7 == 0 and 9 or -9) + v9),
			Size = UDim2.fromOffset(integer, integer),
			BackgroundColor3 = v10 and Color3.fromRGB(
				integer2 + 34,
				math.floor(integer2 * 0.62),
				(math.floor(integer2 * 0.42))
			) or Color3.fromRGB(integer2, integer2, integer2 + 6),
			BorderSizePixel = 0,
			Active = false
		}, make6)

		Make("UICorner", { CornerRadius = UDim.new(1, 0) }, make7)
		Make("UIStroke", {
			Color = Color3.fromRGB(12, 12, 14),
			Thickness = 1.5,
			Transparency = 0.1 + random:NextNumber() * 0.4
		}, make7)
		Make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(1, integer),
			BackgroundColor3 = Color3.fromRGB(10, 10, 12),
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			Active = false,
			Rotation = random:NextInteger(0, 170)
		}, make7)
	end
end

FreePlaySyncStyle.AddTape(
	make5,
	"StrapTopLeft",
	UDim2.new(0, 16, 0, 26),
	UDim2.fromOffset(52, 15),
	-34,
	Color3.fromRGB(34, 34, 37),
	0.04,
	8
)
Make("TextLabel", {
	Name = "Crown",
	BackgroundTransparency = 1,
	Active = false,
	ZIndex = 8,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(1, -44, 1, -40),
	Size = UDim2.fromOffset(44, 44),
	Font = Enum.Font.SourceSansBold,
	TextSize = 40,
	Text = "♛",
	TextColor3 = Color3.fromRGB(205, 200, 190),
	TextTransparency = 0.35
}, make5)

local make7 = Make("Frame", {
	Name = "Keys",
	BackgroundColor3 = Color3.fromRGB(18, 14, 13),
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(16, 18),
	Size = UDim2.fromOffset(v3, 150),
	ClipsDescendants = true,
	ZIndex = 2
}, make5)

local parent = Make(
	"Frame",
	{ Name = "Canvas", BackgroundTransparency = 1, Size = UDim2.fromOffset(v3, 150), ZIndex = 1 },
	make7
)

local make8 = Make("Frame", {
	Name = "Shadow",
	BackgroundColor3 = Color3.new(0, 0, 0),
	BorderSizePixel = 0,
	Active = false,
	Size = UDim2.new(1, 0, 0, 16),
	ZIndex = 2
}, make7)

Make("UIGradient", {
	Rotation = 90,
	Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
}, make8)

Make("Frame", {
	Name = "Felt",
	BackgroundColor3 = Color3.fromRGB(34, 34, 38),
	BackgroundTransparency = 0.1,
	BorderSizePixel = 0,
	Active = false,
	Size = UDim2.new(1, 0, 0, 4),
	ZIndex = 3
}, make7)

local v6 = {}

local function setKeyVisual(data) -- 1 equivalent call inferred from this helper
	data.Button.BackgroundColor3 = data.Count > 0 and data.Pressed or data.Base
end

local function releaseHeldInput(k) -- 1 equivalent call inferred from this helper
	local v7 = v6[k]

	if not v7 then
		return
	end

	v6[k] = nil
	InputRouter.HandleRelease(v7.Lane)
end

local count2 = 0
local v7 = {}

for i = 1, LaneCount do
	local v8 = LowestMidi + i - 1
	local v9 = v8 % 12
	local v10 = math.floor(v8 / 12) - 1
	local v11 = v[v9] == true

	local textButton = Instance.new("TextButton")
	textButton.Name = "Key" .. i
	textButton.AutoButtonColor = false
	textButton.Text = ""
	textButton.BorderSizePixel = 0
	textButton.ClipsDescendants = true
	local v12

	if v11 then
		textButton.Position = UDim2.fromOffset(count2 * 26, -8)
		textButton.Size = UDim2.fromOffset(25, 158)
		textButton.BackgroundColor3 = color6
		textButton.ZIndex = 1
		count2 += 1
		Make("UICorner", { CornerRadius = UDim.new(0, 0) }, textButton)

		Make("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(168, 158, 138)),
				ColorSequenceKeypoint.new(0.3, Color3.fromRGB(236, 228, 208)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 202, 178))
			})
		}, textButton)

		local random2 = Random.new(i * 31)

		for _ = 1, 3 do
			local integer = random2:NextInteger(8, 20)
			local make9 = Make("Frame", {
				BackgroundColor3 = Color3.fromRGB(70, 56, 40),
				BackgroundTransparency = 0.9 + random2:NextNumber() * 0.06,
				BorderSizePixel = 0,
				Active = false,
				Position = UDim2.new(random2:NextNumber() * 0.5, 0, 0, random2:NextInteger(10, 120)),
				Size = UDim2.fromOffset(integer, integer + random2:NextInteger(0, 16))
			}, textButton)

			Make("UICorner", { CornerRadius = UDim.new(1, 0) }, make9)
		end

		for _ = 1, 2 do
			Make("Frame", {
				BackgroundColor3 = Color3.fromRGB(90, 80, 66),
				BackgroundTransparency = 0.78 + random2:NextNumber() * 0.1,
				BorderSizePixel = 0,
				Active = false,
				Rotation = random2:NextInteger(-6, 6),
				Position = UDim2.new(random2:NextNumber() * 0.8 + 0.1, 0, 0, random2:NextInteger(10, 90)),
				Size = UDim2.fromOffset(1, random2:NextInteger(20, 70))
			}, textButton)
		end

		v12 = { Button = textButton, Base = color6, Pressed = color7, Count = 0 }
	else
		textButton.Position = UDim2.fromOffset(count2 * 26 - 8, -8)
		textButton.Size = UDim2.fromOffset(16, 103)
		textButton.BackgroundColor3 = color8
		textButton.ZIndex = 3
		Make("UICorner", { CornerRadius = UDim.new(0, 0) }, textButton)
		Make(
			"UIStroke",
			{
				Color = Color3.new(0, 0, 0),
				Thickness = 1,
				Transparency = 0.2,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			},
			textButton
		)

		Make(
			"UIGradient",
			{
				Rotation = 90,
				Color = ColorSequence.new(Color3.fromRGB(110, 110, 110), Color3.fromRGB(255, 255, 255))
			},
			textButton
		)

		Make("Frame", {
			Name = "Gloss",
			BackgroundColor3 = Color3.fromRGB(170, 170, 178),
			BackgroundTransparency = 0.8,
			BorderSizePixel = 0,
			Active = false,
			Position = UDim2.new(0.16, 0, 0, 8),
			Size = UDim2.new(0, 2, 1, -44)
		}, textButton)

		v12 = { Button = textButton, Base = color8, Pressed = color9, Count = 0 }
	end

	textButton.Parent = parent

	local text = string.sub("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm", i, i)

	if v11 then
		Make("TextLabel", {
			Name = "KeyLabel",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -6),
			Size = UDim2.new(1, 0, 0, 22),
			Font = FONT_HEAD,
			TextSize = 19,
			Text = text,
			Visible = UserInputService.KeyboardEnabled,
			TextColor3 = Color3.fromRGB(34, 30, 26),
			ZIndex = textButton.ZIndex + 2
		}, textButton)
	else
		local make9 = Make("TextLabel", {
			Name = "KeyLabel",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -6),
			Size = UDim2.new(1, -2, 0, 22),
			BackgroundColor3 = Color3.fromRGB(24, 24, 26),
			BorderSizePixel = 0,
			Font = FONT_HEAD,
			TextSize = 17,
			Text = text,
			Visible = UserInputService.KeyboardEnabled,
			TextColor3 = Color3.fromRGB(235, 235, 238),
			ZIndex = textButton.ZIndex + 2
		}, textButton)

		Make("UICorner", { CornerRadius = UDim.new(0, 3) }, make9)
		Make("UIStroke", { Color = Color3.fromRGB(96, 96, 102), Thickness = 1, Transparency = 0.2 }, make9)
	end

	if v9 == 0 then
		Make("TextLabel", {
			Name = "NoteLabel",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -32),
			Size = UDim2.new(1, 0, 0, 14),
			Font = FONT_HEAD,
			TextSize = 13,
			Text = v2[v9 + 1] .. tostring(v10),
			TextColor3 = Color3.fromRGB(128, 118, 100),
			ZIndex = textButton.ZIndex + 1
		}, textButton)
	end

	v7[i] = v12

	textButton.InputBegan:Connect(function(input)
		if not isPointerInput(input) or v6[input] then -- inferred equivalent call
			return
		end

		v6[input] = { Lane = i }
		InputRouter.HandlePress(i)
	end)
end

UserInputService.InputEnded:Connect(function(input)
	local v8 = v6[input] and v6[input]

	if v8 then
		v6[input] = nil
		InputRouter.HandleRelease(v8.Lane)
	end

	if v5[input] then
		v5[input] = nil
		InputRouter.HandlePedal(false)
	end
end)

InputRouter.OnLaneEvent(function(p, p2)
	local v8 = v7[p]

	if not v8 then
		return
	end

	if p2 then
		v8.Count += 1
	else
		v8.Count = math.max(0, v8.Count - 1)
	end

	setKeyVisual(v8) -- inferred equivalent call
end)

InputRouter.OnPedalEvent(function()
	refreshPedalButtons()
end)

local function applyOpacity() -- 1 equivalent call inferred from this helper
	make5.BackgroundTransparency = 0
	local backgroundTransparency = glassTransparency() -- inferred equivalent call

	for k in pairs(set) do
		k.BackgroundTransparency = backgroundTransparency
	end
end
pcall(function()
	SettingsState.OnChanged(applyOpacity)
end)

local v8 = false
local v9 = nil

local function releaseAllHeld()
	for k in pairs(v6) do
		releaseHeldInput(k) -- inferred equivalent call
	end

	for k in pairs(v5) do
		v5[k] = nil
		InputRouter.HandlePedal(false)
	end
end

local function refreshVisibility()
	local v10

	if v9 == "Piano" then
		v10 = FreePlayAssetPreloader.IsPreloaded("Piano", FreePlayController.GetCurrentTone()) == true
	else
		v10 = false
	end

	local enabled = v8

	if enabled then
		if v9 == "Piano" then
			enabled = ModeManager.IsFreePlay() and v10 and pianoFreePlayUI:GetAttribute("HiddenByLaptop") ~= true
		else
			enabled = false
		end
	end

	if enabled and not pianoFreePlayUI.Enabled then
		layoutPanel() -- inferred equivalent call
		applyOpacity() -- inferred equivalent call
		refreshToneButton() -- inferred equivalent call
		refreshPedalButtons()
	end

	if not enabled then
		releaseAllHeld()
	end

	pianoFreePlayUI.Enabled = enabled
end

instrumentHUDUpdate.OnClientEvent:Connect(function(p, p2)
	v8 = p == true
	v9 = v8 and p2 or nil
	refreshVisibility()

	task.defer(function()
		refreshToneButton() -- inferred equivalent call
		refreshPedalButtons()
		refreshVisibility()
	end)
end)

ModeManager.OnChanged(function()
	refreshVisibility()
end)

FreePlayAssetPreloader.OnPreloadComplete(function()
	refreshVisibility()
end)

task.spawn(function()
	local success, result = pcall(function()
		return require(Modules:WaitForChild("LaptopUI", 10):WaitForChild("LaptopClientController", 10))
	end)

	if success and result then
		result.OnEnter(function()
			pianoFreePlayUI:SetAttribute("HiddenByLaptop", true)
			refreshVisibility()
		end)
		result.OnExit(function()
			pianoFreePlayUI:SetAttribute("HiddenByLaptop", nil)
			refreshVisibility()
		end)
	end
end)

local v10 = { Min = 0.5, Max = 1.5, Step = 0.1 }

local function computePianoLayout(p)
	local currentCamera = Workspace.CurrentCamera
	local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
	local v11 = viewportSize.X - 16
	local v12 = viewportSize.Y * 0.55 / 224
	local v13 = math.min(v11 / v4, v12)
	local v14 = viewportSize.Y * 0.8 / 224
	local compact = v13 < 0.85
	local base, scale, visible

	if compact then
		base = math.clamp(math.min(0.85, v12), 0.3, 0.85)
		local v15 = math.max(base, (math.min(v14, v11 / 214)))
		scale = math.clamp(base * p, 0.3, v15)
		visible = math.clamp(math.floor((v11 / scale - 32) / 26), 7, count)

		if p < 0.999 and count <= visible then
			compact = false
		end
	else
		base = math.clamp(v13, 0.3, 1.25)
		local v15 = math.max(base, (math.min(v11 / v4, v14)))
		scale = math.clamp(base * p, 0.3, v15)
		visible = count
	end

	return { Scale = scale, Base = base, Compact = compact, Visible = visible }
end

local function pianoStepTarget(p)
	local v11 = computePianoLayout(SettingsState.GetPianoScale())
	local v12 = math.clamp(math.floor((v11.Scale / v11.Base + p) * 10 + 0.5) / 10, 0.5, 1.5)
	local v13 = computePianoLayout(v12)

	if p > 0 and v13.Scale > v11.Scale + 0.001 or p < 0 and v13.Scale < v11.Scale - 0.001 then
		return v12
	end

	return nil
end

local v11 = nil
local function showPianoToast(p)
	if not v11 then
		local pianoFreePlayToastGui = Instance.new("ScreenGui")
		pianoFreePlayToastGui.Name = "PianoFreePlayToastGui"
		pianoFreePlayToastGui.ResetOnSpawn = false
		pianoFreePlayToastGui.IgnoreGuiInset = true
		pianoFreePlayToastGui.DisplayOrder = 100
		pianoFreePlayToastGui.Parent = PlayerGui
		local ThemeSwitchToast = require(Modules:WaitForChild("ThemeSwitchToast"))
		v11 = ThemeSwitchToast.new(pianoFreePlayToastGui)
	end

	v11:Show(p)
end

local make9 = Make("Frame", {
	Name = "Nav",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -150, 0, 0),
	Size = UDim2.fromOffset(64, 28),
	Visible = false
}, make3)

local button5 = makeButton(make9, "NavPrev", "<", 28, 1)
local button6 = makeButton(make9, "NavNext", ">", 28, 2)
button5.Position = UDim2.fromOffset(0, 0)
button6.Position = UDim2.fromOffset(34, 0)
button5.TextSize = 18
button6.TextSize = 18

local make10 = Make("Frame", {
	Name = "SizeControls",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -80, 0, 0),
	Size = UDim2.fromOffset(62, 28)
}, make3)

local button7 = makeButton(make10, "SizeMinus", "-", 28, 1)
local button8 = makeButton(make10, "SizePlus", "+", 28, 2)
button7.Position = UDim2.fromOffset(0, 0)
button8.Position = UDim2.fromOffset(34, 0)
button7.TextSize = 20
button8.TextSize = 20
local _ = { Minus = button7, Plus = button8 }

local function refreshSizeButtons()
	local v12 = computePianoLayout(SettingsState.GetPianoScale())
	local v13 = math.clamp(math.floor((v12.Scale / v12.Base + -0.1) * 10 + 0.5) / 10, v10.Min, v10.Max)

	if not (computePianoLayout(v13).Scale < v12.Scale - 0.001) then
		v13 = nil
	end

	button7.TextTransparency = v13 and 0 or 0.65
	local v14 = computePianoLayout(SettingsState.GetPianoScale())
	local v15 = math.clamp(math.floor((v14.Scale / v14.Base + 0.1) * 10 + 0.5) / 10, v10.Min, v10.Max)

	if not (computePianoLayout(v15).Scale > v14.Scale + 0.001) then
		v15 = nil
	end

	button8.TextTransparency = v15 and 0 or 0.65
end

local function stepPianoSize(p)
	local v12 = pianoStepTarget(p)

	if not v12 then
		showPianoToast(p > 0 and "Keyboard is already as large as the screen allows" or "Keyboard is already at its smallest size")
		return
	end

	SettingsState.SetField("PianoScale", v12, true)
	showPianoToast("Keyboard size " .. math.floor(v12 * 100 + 0.5) .. "%")
end
button7.Activated:Connect(function()
	local v12 = computePianoLayout(SettingsState.GetPianoScale())
	local v13 = math.clamp(math.floor((v12.Scale / v12.Base + -0.1) * 10 + 0.5) / 10, v10.Min, v10.Max)

	if not (computePianoLayout(v13).Scale < v12.Scale - 0.001) then
		v13 = nil
	end

	if not v13 then
		showPianoToast("Keyboard is already at its smallest size")
		return
	end

	SettingsState.SetField("PianoScale", v13, true)
	showPianoToast("Keyboard size " .. math.floor(v13 * 100 + 0.5) .. "%")
end)
button8.Activated:Connect(function()
	local v12 = computePianoLayout(SettingsState.GetPianoScale())
	local v13 = math.clamp(math.floor((v12.Scale / v12.Base + 0.1) * 10 + 0.5) / 10, v10.Min, v10.Max)

	if not (computePianoLayout(v13).Scale > v12.Scale + 0.001) then
		v13 = nil
	end

	if not v13 then
		showPianoToast("Keyboard is already as large as the screen allows")
		return
	end

	SettingsState.SetField("PianoScale", v13, true)
	showPianoToast("Keyboard size " .. math.floor(v13 * 100 + 0.5) .. "%")
end)

local v12 = count
local v13 = 14

local function applyWindow() -- 3 equivalent calls inferred from this helper
	v12 = math.clamp(v12, 1, count)
	v13 = math.clamp(v13, 0, count - v12)
	parent.Position = UDim2.fromOffset(-v13 * 26, 0)
	button5.TextTransparency = v13 > 0 and 0 or 0.65
	button6.TextTransparency = v13 < count - v12 and 0 or 0.65
end

button5.Activated:Connect(function()
	v13 -= 7
	applyWindow() -- inferred equivalent call
end)
button6.Activated:Connect(function()
	v13 += 7
	applyWindow() -- inferred equivalent call
end)

fn = function()
	local v14 = computePianoLayout(SettingsState.GetPianoScale())
	local compact = v14.Compact

	if compact then
		local scale = v14.Scale
		v12 = v14.Visible
		local v15 = v12 * 26
		make.Size = UDim2.fromOffset(v15 + 32, 224)
		make7.Size = UDim2.fromOffset(v15, 150)
		make2.Scale = scale
		button.Size = UDim2.fromOffset(150, 28)
		button2.Size = UDim2.fromOffset(84, 28)
		button3.Size = UDim2.fromOffset(92, 28)
	else
		v12 = count
		make.Size = UDim2.fromOffset(v4, 224)
		make7.Size = UDim2.fromOffset(v3, 150)
		make2.Scale = v14.Scale
		button.Size = UDim2.fromOffset(210, 28)
		button2.Size = UDim2.fromOffset(120, 28)
		button3.Size = UDim2.fromOffset(140, 28)
	end

	make:SetAttribute("Compact", compact)
	make9.Visible = compact

	local visible = (compact and v12 * 26 + 32 or v4) >= 560

	make10.Visible = visible
	local v15 = visible and 70 or 0
	make9.Position = UDim2.new(1, -(80 + v15), 0, 0)
	make4.Size = UDim2.new(1, compact and -(72 + v15 + 72 + 8) or -(v15 + 72 + 8), 1, 0)
	button2.Text = (compact or not UserInputService.KeyboardEnabled) and "SUSTAIN" or "SUSTAIN (Space)"
	applyWindow() -- inferred equivalent call
	refreshPedalButtons()
	button7.TextTransparency = pianoStepTarget(-v10.Step) and 0 or 0.65
	button8.TextTransparency = pianoStepTarget(v10.Step) and 0 or 0.65
end
fn()

pcall(function()
	SettingsState.OnChanged(function()
		if fn then
			fn()
		end
	end)
end)
refreshToneButton() -- inferred equivalent call
refreshPedalButtons()