local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local FreePlayVibrato = require(Modules:WaitForChild("FreePlayVibrato"))
local ModeManager = require(Modules:WaitForChild("ModeManager"))
local FreePlayController = require(Modules:WaitForChild("FreePlayController"))
local FreePlayAutoMuteConfig = require(Modules:WaitForChild("FreePlayAutoMuteConfig"))
local instrumentHUDUpdate = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InstrumentHUDUpdate")
local InstrumentLifecycleSignal = require(Modules:WaitForChild("InstrumentLifecycleSignal"))
local ChartLoader = require(Modules:WaitForChild("ChartLoader"))
local GuiFade = require(Modules:WaitForChild("GuiFade"))

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local v2 = v and 34 or 21
local scale = v and 5 / 7 or 15 / 14
local v3 = v and 104 or 0
local color = Color3.fromRGB(20, 20, 19)
local color2 = Color3.fromRGB(15, 15, 14)
local color3 = Color3.fromRGB(64, 62, 58)
local color4 = Color3.fromRGB(86, 84, 80)
local color5 = Color3.fromRGB(222, 220, 214)
local color6 = Color3.fromRGB(158, 156, 150)
local color7 = Color3.fromRGB(204, 162, 72)
local color8 = Color3.fromRGB(24, 22, 18)
local color9 = Color3.fromRGB(206, 190, 150)
local color10 = Color3.fromRGB(96, 90, 80)
local color11 = Color3.fromRGB(8, 8, 8)
local color12 = Color3.fromRGB(122, 120, 114)
local color13 = Color3.fromRGB(74, 42, 28)
local Oswald = Enum.Font.Oswald
local SpecialElite = Enum.Font.SpecialElite

local v4 = nil

local function isEligible() -- 1 equivalent call inferred from this helper
	local v5 = v4 or FreePlayController.GetCurrentInstrumentType()
	return v5 ~= nil and FreePlayAutoMuteConfig.IsAutoMuteInstrument(v5)
end

local rhythmVibratoHUD = Instance.new("ScreenGui")
rhythmVibratoHUD.Name = "RhythmVibratoHUD"
rhythmVibratoHUD.ResetOnSpawn = false
rhythmVibratoHUD.DisplayOrder = 15
rhythmVibratoHUD.ZIndexBehavior = Enum.ZIndexBehavior.Global
rhythmVibratoHUD.Parent = PlayerGui

local v5 = 50 + v2 + 8
local v6 = v5 + 32

local function mk(className, items, parent) -- 30 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local canvasGroup = mk("CanvasGroup", { -- inferred equivalent call
	Name = "Container",
	AnchorPoint = Vector2.new(0, 0.5),
	Size = UDim2.new(0, 172, 0, v6),
	Position = UDim2.new(1, -186, 0.5, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	GroupTransparency = 0.92,
	Visible = false,
	ZIndex = 1
}, rhythmVibratoHUD)

mk("UIScale", { Scale = scale }, canvasGroup) -- inferred equivalent call
GuiFade.Attach(canvasGroup, "Hud", 0.95, GuiFade.Presets.Vibrato)

local parent2 = mk("Frame", { -- inferred equivalent call
	Name = "Panel",
	Position = UDim2.new(0, 16, 0, 16),
	Size = UDim2.new(0, 140, 0, v5),
	BackgroundColor3 = color,
	BackgroundTransparency = 0.04,
	BorderSizePixel = 0,
	Active = true,
	ZIndex = 1
}, canvasGroup)

mk("UICorner", { CornerRadius = UDim.new(0, 3) }, parent2) -- inferred equivalent call
mk("UIStroke", { Color = color11, Thickness = 2 }, parent2) -- inferred equivalent call

local function isPress(p): boolean -- 6 equivalent calls inferred from this helper
	return p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch
end

local function markPointerDown(p)
	p.InputBegan:Connect(function(input)
		if isPress(input) then -- inferred equivalent call
			canvasGroup:SetAttribute("PointerDown", true)
		end
	end)
end

local function onInputBegan(p)
	if isPress(p) then -- inferred equivalent call
		canvasGroup:SetAttribute("PointerDown", true)
	end
end

parent2.InputBegan:Connect(onInputBegan)

UserInputService.InputEnded:Connect(function(input)
	if isPress(input) then -- inferred equivalent call
		canvasGroup:SetAttribute("PointerDown", false)
	end
end)

local function addWaveIcon(parent, p, p2, p3, p4, p5, color14, p6)
	local v7 = math.clamp(math.floor(p3 * 0.6), 14, 48)
	local vector2s = {}

	for i = 0, v7 do
		local v8 = i / v7
		vector2s[#vector2s + 1] = Vector2.new(
			v8 * p3,
			p4 / 2 + (p4 / 2 - p5 * 0.5) * math.sin(v8 * 3.141592653589793 * 2 * p6)
		)
	end

	for i = 1, v7 do
		local v8 = vector2s[i]
		local v9 = vector2s[i + 1]
		local v10 = v9 - v8
		local midpoint = (v8 + v9) / 2
		mk("Frame", { -- inferred equivalent call
			Name = "WaveSeg" .. i,
			BackgroundColor3 = color14,
			BorderSizePixel = 0,
			Active = false,
			ZIndex = 6,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(p + midpoint.X, p2 + midpoint.Y),
			Size = UDim2.fromOffset(v10.Magnitude + p5 * 0.7, p5),
			Rotation = math.deg((math.atan2(v10.Y, v10.X)))
		}, parent)
	end
end

local TextService = game:GetService("TextService")
local v7 = math.max(28, 124 - math.ceil(TextService:GetTextSize("VIBRATO", 17, Oswald, Vector2.new(1000, 100)).X) - 6)
addWaveIcon(parent2, 8, 10, v7, 12, 2, color7, v7 * 1.5 / 28)
mk("TextLabel", { -- inferred equivalent call
	Name = "Title",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, v7 + 8 + 6, 0, 8),
	Size = UDim2.new(0, 124 - v7 - 6, 0, 16),
	Font = Oswald,
	TextSize = 17,
	TextColor3 = color7,
	TextXAlignment = Enum.TextXAlignment.Right,
	Text = "VIBRATO",
	ZIndex = 5
}, parent2)

mk("Frame", { -- inferred equivalent call
	Name = "TitleLine",
	BackgroundColor3 = color4,
	BackgroundTransparency = 0.3,
	BorderSizePixel = 0,
	Active = false,
	Position = UDim2.new(0, 8, 0, 24),
	Size = UDim2.new(0, 124, 0, 1),
	ZIndex = 5
}, parent2)

local parent = mk("TextButton", { -- inferred equivalent call
	Name = "RateSlider",
	Position = UDim2.new(0, 8, 0, 28),
	Size = UDim2.new(0, 124, 0, 18),
	BackgroundColor3 = color2,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Text = "",
	ClipsDescendants = true,
	ZIndex = 5
}, parent2)

mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent) -- inferred equivalent call
mk( -- inferred equivalent call
	"UIStroke",
	{
		Color = color4,
		Thickness = 1,
		Transparency = 0.25,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	},
	parent
)

local frame = mk("Frame", { -- inferred equivalent call
	Name = "Fill",
	Size = UDim2.new(0, 0, 1, 0),
	BackgroundColor3 = color3,
	BorderSizePixel = 0,
	ZIndex = 6
}, parent)
local frame2 = mk("Frame", { -- inferred equivalent call
	Name = "Knob",
	Size = UDim2.new(0, 3, 1, -4),
	BackgroundColor3 = color7,
	BorderSizePixel = 0,
	ZIndex = 8
}, parent)
local textLabel = mk("TextLabel", { -- inferred equivalent call
	Name = "RateLabel",
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Font = SpecialElite,
	TextSize = 13,
	TextColor3 = color5,
	Text = "",
	ZIndex = 7
}, parent)
parent.InputBegan:Connect(onInputBegan)
local v8

if v then
	v8 = Instance.new("TextButton")

	for k, v9 in pairs({ AutoButtonColor = false, Text = "VIBRATO", TextSize = 18, Font = Oswald }) do
		v8[k] = v9
	end

	v8.Parent = parent2
else
	local v9 = UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local SettingsState = require(ReplicatedStorage2.Modules.SettingsState)
	local function padLabelText() -- 2 equivalent calls inferred from this helper
		local v10 = SettingsState.GetVibratoBindingName() == "LeftControl"

		if v9 and v10 then
			return "R-STICK (Vibrato)"
		end

		return SettingsState.GetVibratoKeyLabel() .. " (Vibrato)"
	end

	v8 = mk("TextLabel", { Text = padLabelText(), TextSize = 13, Font = SpecialElite }, parent2) -- inferred equivalent call

	SettingsState.OnChanged(function()
		v8.Text = padLabelText() -- inferred equivalent call
	end)
end

v8.Name = "VibratoMain"
v8.Position = UDim2.new(0, 8, 0, 50)
v8.Size = UDim2.new(0, 124, 0, v2)
v8.BackgroundColor3 = color2
v8.BorderSizePixel = 0
v8.TextColor3 = color6
v8.ZIndex = 5
mk("UICorner", { CornerRadius = UDim.new(0, 2) }, v8) -- inferred equivalent call
local uiStroke = mk( -- inferred equivalent call
	"UIStroke",
	{
		Color = color4,
		Thickness = 1,
		Transparency = 0.25,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	},
	v8
)

if v then
	v8.InputBegan:Connect(onInputBegan)
end

local folder = mk("Frame", { -- inferred equivalent call
	Name = "DecorFront",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Active = false,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, 0, 1, 0),
	ZIndex = 50
}, parent2)

local random = Random.new(23)

local function vignette(name, position, size, rotation, p)
	local parent3 = mk("Frame", { -- inferred equivalent call
		Name = name,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		Active = false,
		Position = position,
		Size = size
	}, folder)
	mk("UIGradient", { -- inferred equivalent call
		Rotation = rotation,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, p), NumberSequenceKeypoint.new(1, 1) })
	}, parent3)
end
vignette("VigTop", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 16), 90, 0.5)
vignette("VigBottom", UDim2.new(0, 0, 1, -16), UDim2.new(1, 0, 0, 16), 270, 0.5)
vignette("VigLeft", UDim2.new(0, 0, 0, 0), UDim2.new(0, 16, 1, 0), 0, 0.55)
vignette("VigRight", UDim2.new(1, -16, 0, 0), UDim2.new(0, 16, 1, 0), 180, 0.55)

for i = 1, 4 do
	local integer = random:NextInteger(30, 66)
	local parent3 = mk("Frame", { -- inferred equivalent call
		Name = "Stain" .. i,
		BackgroundColor3 = i % 2 == 0 and color13 or Color3.new(0, 0, 0),
		BackgroundTransparency = 0.9 + random:NextNumber() * 0.05,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.fromScale(random:NextNumber() * 0.8, random:NextNumber() * 0.8),
		Size = UDim2.new(0, integer, 0, (math.floor(integer * (0.35 + random:NextNumber() * 0.4))))
	}, folder)

	mk("UICorner", { CornerRadius = UDim.new(1, 0) }, parent3) -- inferred equivalent call
end

for i, v9 in ipairs({
	{ 0.08, 0.3, 56, 24 },
	{ 0.58, 0.46, 42, -31 },
	{ 0.28, 0.74, 70, 12 },
	{ 0.72, 0.18, 38, 40 }
}) do
	mk("Frame", { -- inferred equivalent call
		Name = "Scratch" .. i,
		BackgroundColor3 = color5,
		BackgroundTransparency = 0.93,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.fromScale(v9[1], v9[2]),
		Size = UDim2.new(0, v9[3], 0, 1),
		Rotation = v9[4]
	}, folder)
end

for i = 1, 3 do
	mk("Frame", { -- inferred equivalent call
		Name = "Scuff" .. i,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
		Size = UDim2.new(0, random:NextInteger(16, 38), 0, 1),
		Rotation = random:NextInteger(-60, 60)
	}, folder)
end

for i = 1, 22 do
	local v9 = random:NextNumber() > 0.35
	local integer = random:NextInteger(1, 2)
	mk("Frame", { -- inferred equivalent call
		Name = "Speck" .. i,
		BackgroundColor3 = v9 and color5 or Color3.new(0, 0, 0),
		BackgroundTransparency = v9 and 0.8 + random:NextNumber() * 0.12 or 0.45 + random:NextNumber() * 0.25,
		BorderSizePixel = 0,
		Active = false,
		Position = UDim2.fromScale(random:NextNumber(), random:NextNumber()),
		Size = UDim2.new(0, integer, 0, integer)
	}, folder)
end

local parent3 = mk("Frame", { -- inferred equivalent call
	Name = "EdgeWear",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Active = false,
	Position = UDim2.new(0, 3, 0, 3),
	Size = UDim2.new(1, -6, 1, -6)
}, folder)
mk("UIStroke", { Color = color12, Thickness = 1.5, Transparency = 0.55 }, parent3) -- inferred equivalent call
mk("UICorner", { CornerRadius = UDim.new(0, 2) }, parent3) -- inferred equivalent call

local function tape(name, position, size, rotation, color14, backgroundTransparency)
	local parent4 = mk("Frame", { -- inferred equivalent call
		Name = name,
		BackgroundColor3 = color14,
		BackgroundTransparency = backgroundTransparency,
		BorderSizePixel = 0,
		Active = false,
		Position = position,
		Size = size,
		Rotation = rotation,
		ZIndex = 52
	}, folder)
	mk("UIStroke", { Color = Color3.fromRGB(70, 62, 48), Thickness = 1, Transparency = 0.7 }, parent4) -- inferred equivalent call
end
tape("TapeTopRight", UDim2.new(1, -46, 0, -4), UDim2.new(0, 26, 0, 8), 7, color9, 0.22)
tape("TapeBottomLeft", UDim2.new(0, -5, 1, -10), UDim2.new(0, 22, 0, 8), 36, color10, 0.2)

for _, guiObject in ipairs(folder:GetDescendants()) do
	if guiObject:IsA("GuiObject") then
		guiObject.ZIndex = guiObject.Name:sub(1, 4) == "Tape" and 52 or 50
	end
end

local function isVibratoInUse() -- 2 equivalent calls inferred from this helper
	return FreePlayVibrato.IsActive() or FreePlayVibrato.IsWhammyActive()
end

local function refresh()
	local vibratoInUse = isVibratoInUse() -- inferred equivalent call
	v8.BackgroundColor3 = vibratoInUse and color7 or color2
	v8.TextColor3 = vibratoInUse and color8 or color6
	uiStroke.Color = vibratoInUse and color7 or color4

	local rate = FreePlayVibrato.GetRate()
	local v9 = math.clamp(
		(rate - FreePlayVibrato.MIN_RATE) / (FreePlayVibrato.MAX_RATE - FreePlayVibrato.MIN_RATE),
		0,
		1
	)
	frame.Size = UDim2.new(v9, 0, 1, 0)
	frame.BackgroundColor3 = vibratoInUse and color7 or color3
	frame2.AnchorPoint = Vector2.new(v9, 0.5)
	frame2.Position = UDim2.new(v9, 0, 0.5, 0)
	textLabel.Text = string.format("%.1f Hz", rate)
	textLabel.TextColor3 = vibratoInUse and color8 or color5
end

FreePlayVibrato.OnChanged(refresh)
refresh()

if v then
	v8.InputBegan:Connect(function(input)
		if isPress(input) then -- inferred equivalent call
			FreePlayVibrato.CtrlDown()
		end
	end)
	v8.InputEnded:Connect(function(input)
		if isPress(input) then -- inferred equivalent call
			FreePlayVibrato.CtrlUp()
		end
	end)
	v8.MouseLeave:Connect(function()
		FreePlayVibrato.CtrlUp()
	end)
end

local v9 = nil
local function setRateFromX(x) -- 2 equivalent calls inferred from this helper
	local x2 = parent.AbsoluteSize.X

	if x2 <= 0 then
		return
	end

	local v10 = math.clamp((x - parent.AbsolutePosition.X) / x2, 0, 1)
	FreePlayVibrato.SetRate(FreePlayVibrato.MIN_RATE + v10 * (FreePlayVibrato.MAX_RATE - FreePlayVibrato.MIN_RATE))
end

parent.InputBegan:Connect(function(input)
	if isPress(input) then -- inferred equivalent call
		v9 = input
		setRateFromX(input.Position.X) -- inferred equivalent call
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not v9 then
		return
	end

	if
		input == v9
		or v9.UserInputType == Enum.UserInputType.MouseButton1
		and input.UserInputType == Enum.UserInputType.MouseMovement
	then
		setRateFromX(input.Position.X) -- inferred equivalent call
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if
		v9
		and (input == v9 or v9.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1)
	then
		v9 = nil
	end
end)

local function findStarBar() -- 1 equivalent call inferred from this helper
	local starPowerUI = PlayerGui:FindFirstChild("StarPowerUI")
	local meterContainer = starPowerUI and starPowerUI:FindFirstChild("MeterContainer", true)

	if meterContainer and starPowerUI.Enabled and meterContainer.Visible and meterContainer.AbsoluteSize.X > 0 then
		return meterContainer
	end

	return nil
end

local function reposition()
	local absoluteSize = rhythmVibratoHUD.AbsoluteSize
	local absolutePosition = rhythmVibratoHUD.AbsolutePosition
	local starBar = findStarBar() -- inferred equivalent call

	if not starBar then
		canvasGroup.Position = UDim2.new(1, -(172 * scale + 14), 0.5, 0)
		return
	end

	local v10 = starBar.AbsolutePosition - absolutePosition
	local absoluteSize2 = starBar.AbsoluteSize
	local v11 = 140 * scale
	local v12 = v10.X + absoluteSize2.X + 22
	local noteLaneUI3D = rhythmVibratoHUD.Parent and rhythmVibratoHUD.Parent:FindFirstChild("NoteLaneUI3D")

	if v12 + v11 > absoluteSize.X - 6 and not (noteLaneUI3D and noteLaneUI3D.Enabled) then
		v12 = v10.X - 22 - v11
	end

	local v13 = math.clamp(v12, 6, (math.max(6, absoluteSize.X - v11 - 6 - v3)))
	local v14 = v10.Y + absoluteSize2.Y / 2
	local v15 = v5 * scale / 2 + 6
	local v16 = math.clamp(v14, v15, (math.max(v15, absoluteSize.Y - v15)))
	canvasGroup.Position = UDim2.fromOffset(math.floor(v13 - 16 * scale + 0.5), (math.floor(v16 + 0.5)))
end

local function isHovering(): boolean
	if not UserInputService.MouseEnabled then
		return false
	end

	local v10 = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	local absolutePosition = parent2.AbsolutePosition
	local absoluteSize = parent2.AbsoluteSize

	return v10.X >= absolutePosition.X - 6
		and v10.X <= absolutePosition.X + absoluteSize.X + 6
		and v10.Y >= absolutePosition.Y - 6
		and v10.Y <= absolutePosition.Y + absoluteSize.Y + 6
end

local total = 0.92
RunService.RenderStepped:Connect(function(dt)
	if not canvasGroup.Visible then
		return
	end

	reposition()

	local v10 = (canvasGroup:GetAttribute("PointerDown") == true or isHovering()) and 0.03
		or isVibratoInUse() and 0.66 -- inferred equivalent call
		or 0.92

	total += (v10 - total) * math.min(1, dt * 10)
	canvasGroup.GroupTransparency = total
	GuiFade.Refresh(canvasGroup)
end)

local v10 = false
local v11 = false
local v12 = {}

local function songHasHold(songName, instrumentType)
	if typeof(songName) ~= "string" or typeof(instrumentType) ~= "string" then
		return false
	end

	local v13 = songName .. "|" .. instrumentType

	if v12[v13] ~= nil then
		return v12[v13]
	end

	local v14 = false
	local success, chart = pcall(ChartLoader.GetChart, songName, instrumentType)

	if success and typeof(chart) == "table" then
		for _, v15 in ipairs(chart) do
			if typeof(v15) == "table" and typeof(v15.Duration) == "number" and v15.Duration > 0 then
				v14 = true
				break
			end
		end
	end

	v12[v13] = v14
	return v14
end

local function updateVisibility() -- 2 equivalent calls inferred from this helper
	local visible

	if v10 and v11 and ModeManager.IsRhythm() then
		visible = isEligible() or PlayerGui:GetAttribute("HudPreviewActive") == true -- inferred equivalent call
	else
		visible = PlayerGui:GetAttribute("HudPreviewActive") == true
	end

	if visible and not canvasGroup.Visible then
		total = 0.92
		canvasGroup.GroupTransparency = 0.92
		reposition()
	end

	canvasGroup.Visible = visible
end

InstrumentLifecycleSignal.Event:Connect(function(data)
	if typeof(data) ~= "table" then
		return
	end

	if data.Lifecycle == "SessionStart" then
		v10 = true
		v11 = songHasHold(data.SongName, data.InstrumentType)
	elseif data.Lifecycle == "SessionEnd" then
		v10 = false
		v11 = false
		FreePlayVibrato.ResetActive()
	end

	updateVisibility() -- inferred equivalent call
end)

ModeManager.OnChanged(updateVisibility)

instrumentHUDUpdate.OnClientEvent:Connect(function(p, p2)
	v4 = p and p2 or nil

	if not p then
		v10 = false
		v11 = false
	end

	updateVisibility() -- inferred equivalent call
end)

task.spawn(function()
	while true do
		local visible

		if v10 and v11 and ModeManager.IsRhythm() then
			local v13 = v4 or FreePlayController.GetCurrentInstrumentType()

			if v13 == nil then
				visible = false
			else
				visible = FreePlayAutoMuteConfig.IsAutoMuteInstrument(v13)

				if visible then
					if visible and not canvasGroup.Visible then
						total = 0.92
						canvasGroup.GroupTransparency = 0.92
						reposition()
					end

					canvasGroup.Visible = visible

					task.wait(0.5)
					continue
				end
			end
		end

		visible = PlayerGui:GetAttribute("HudPreviewActive") == true

		if visible and not canvasGroup.Visible then
			total = 0.92
			canvasGroup.GroupTransparency = 0.92
			reposition()
		end

		canvasGroup.Visible = visible

		task.wait(0.5)
	end
end)