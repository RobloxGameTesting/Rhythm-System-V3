local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Modules = ReplicatedStorage.Modules
local InputRouter = require(Modules.InputRouter)
local ModeManager = require(Modules.ModeManager)
local FreePlayController = require(Modules.FreePlayController)
local FreePlayAssetPreloader = require(Modules.FreePlayAssetPreloader)
local FreePlaySoundAdapter = require(Modules.FreePlaySoundAdapter)
local ThemeSwitchToast = require(Modules.ThemeSwitchToast)
local FreePlayAutoMuteConfig = require(Modules.FreePlayAutoMuteConfig)
local FreePlayVibrato = require(Modules.FreePlayVibrato)

local SettingsState = require(Modules.SettingsState)

local instrumentHUDUpdate = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InstrumentHUDUpdate")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local refreshVisibility

local fn
local fn2

local v = {
	GuitarLead = {
		Key = "Guitar",
		Rows = { 1, 2, 3, 4, 5, 6 }
	},
	GuitarRhythm = {
		Key = "Guitar",
		Rows = { 1, 2, 3, 4, 5, 6 }
	},
	Bass = {
		Key = "Bass",
		Rows = { 3, 4, 5, 6 }
	}
}

local v2 = {
	{
		"~",
		"!",
		"@",
		"#",
		"$",
		"%",
		"^",
		"&",
		"*",
		"(",
		")",
		"_",
		"+"
	},
	{
		"Q",
		"W",
		"E",
		"R",
		"T",
		"Y",
		"U",
		"I",
		"O",
		"P",
		"{",
		"}",
		"|"
	},
	{
		"`",
		"1",
		"2",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
		"9",
		"0",
		"-",
		"="
	},
	{
		"q",
		"w",
		"e",
		"r",
		"t",
		"y",
		"u",
		"i",
		"o",
		"p",
		"[",
		"]",
		"\\"
	},
	{
		"a",
		"s",
		"d",
		"f",
		"g",
		"h",
		"j",
		"k",
		"l",
		";",
		"'",
		":",
		"\""
	},
	{
		"z",
		"x",
		"c",
		"v",
		"b",
		"n",
		"m",
		",",
		".",
		"/",
		"<",
		">",
		"?"
	}
}

local v3 = {
	Guitar = {
		{ Text = "PEDALS", Weight = 1, Color = Color3.fromRGB(96, 40, 150) },
		{ Text = "CAPS", Weight = 1, Color = Color3.fromRGB(45, 45, 48) },
		{ Text = "CTRL", Weight = 2.6, Color = Color3.fromRGB(45, 45, 48) }
	},
	Bass = {
		{ Text = "PEDALS", Weight = 1, Color = Color3.fromRGB(96, 40, 150) },
		{ Text = "CAPS", Weight = 1, Color = Color3.fromRGB(45, 45, 48) },
		{ Text = "CTRL", Weight = 2.6, Color = Color3.fromRGB(45, 45, 48) }
	}
}

local function computeGridHeight(count) -- 1 equivalent call inferred from this helper
	return 54 * count + 4 * (count - 1)
end

local virtualKeyboardUI = Instance.new("ScreenGui")
virtualKeyboardUI.Name = "VirtualKeyboardUI"
virtualKeyboardUI.ResetOnSpawn = false
virtualKeyboardUI.Enabled = false
virtualKeyboardUI.IgnoreGuiInset = true
virtualKeyboardUI.Parent = PlayerGui

local keyboardCanvas = Instance.new("Frame")
keyboardCanvas.Name = "KeyboardCanvas"
keyboardCanvas.AnchorPoint = Vector2.new(0.5, 1)
keyboardCanvas.Position = UDim2.new(0.5, 0, 1, -16)
keyboardCanvas.BackgroundTransparency = 1
keyboardCanvas.Parent = virtualKeyboardUI

task.spawn(function()
	local success, result = pcall(function()
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		return require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("FreePlayScrollGuard"))
	end)

	if success then
		result.Attach(virtualKeyboardUI, function()
			return { keyboardCanvas }
		end)
	else
		warn("[VirtualKeyboardUI] FreePlayScrollGuard gagal dimuat:", result)
	end
end)

local uiScale = Instance.new("UIScale")
uiScale.Parent = keyboardCanvas

local v4 = 0

local v5 = { Min = 0.5, Max = 1.5, Step = 0.1 }
local v6 = { Plus = nil, Minus = nil, Refresh = nil }

local function computeCanvasScaleFor(p)
	if v4 <= 0 then
		return nil
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return nil
	end

	local viewportSize = currentCamera.ViewportSize
	local v7 = viewportSize.X - 32
	local v8 = viewportSize.Y - 110 - 16

	if v7 <= 0 or v8 <= 0 then
		return nil
	end

	local v9 = math.min(v7 / 1726, v8 / v4)

	local v10 = math.min(v9, 1)
	return math.max(math.min(v10 * p, v9), 0.35), (math.max(v10, 0.35))
end

local function kbStepTarget(p)
	local v7, v8 = computeCanvasScaleFor(SettingsState.GetKeyboardScale())

	if not v7 then
		return nil
	end

	local v9 = math.clamp(math.floor((v7 / v8 + p) * 10 + 0.5) / 10, 0.5, 1.5)
	local v10 = computeCanvasScaleFor(v9)

	if p > 0 and v7 + 0.001 < v10 or p < 0 and v10 < v7 - 0.001 then
		return v9
	end

	return nil
end

local function updateCanvasScale() -- 3 equivalent calls inferred from this helper
	local scale = computeCanvasScaleFor(SettingsState.GetKeyboardScale())

	if scale then
		uiScale.Scale = scale
	end

	if v6.Refresh then
		v6.Refresh()
	end
end

SettingsState.OnChanged(function()
	updateCanvasScale() -- inferred equivalent call
end)

local function connectViewportListener() -- 2 equivalent calls inferred from this helper
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateCanvasScale)
	end
end

connectViewportListener() -- inferred equivalent call
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	connectViewportListener() -- inferred equivalent call
	updateCanvasScale() -- inferred equivalent call
end)

local function styleKey(parent, p)
	parent.BackgroundColor3 = p or Color3.fromRGB(45, 45, 48)
	parent.BorderSizePixel = 0
	parent.Font = Enum.Font.GothamBold
	parent.TextColor3 = Color3.fromRGB(235, 235, 235)
	parent.AutoButtonColor = false
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 6)
	uiCorner.Parent = parent
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(70, 70, 74)
	uiStroke.Thickness = 1
	uiStroke.Parent = parent
end

local chromeRow = Instance.new("Frame")
chromeRow.Name = "ChromeRow"
chromeRow.Position = UDim2.new(0, 144, 0, 0)
chromeRow.Size = UDim2.new(0, 1582, 0, 44)
chromeRow.BackgroundTransparency = 1
chromeRow.Parent = keyboardCanvas

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.Padding = UDim.new(0, 4)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = chromeRow

local function formatToneDisplayName(value) -- 2 equivalent calls inferred from this helper
	if value then
		return value:gsub("(%l)(%u)", "%1 %2"):upper()
	end

	return "-"
end

local v7 = {
	{ Text = "TUNING", Width = 160, Color = Color3.fromRGB(45, 45, 48), IsTuning = true },
	{ Text = "TONE: CHORUS CLEAN", Width = 220, Color = Color3.fromRGB(45, 45, 48), IsTone = true },
	{ Text = "VIBRATO: OFF", Width = 200, Color = Color3.fromRGB(45, 45, 48), IsVibrato = true },
	{ Text = "OVERLAP: OFF", Width = 170, Color = Color3.fromRGB(45, 45, 48), IsOverlap = true },
	{ Text = "MENU", Width = 90, Color = Color3.fromRGB(38, 120, 220), IsTabs = true },
	{ Text = "AUTO MUTE: OFF", Width = 190, Color = Color3.fromRGB(45, 45, 48), IsAutoMute = true },
	{ Text = "SUSTAINER: OFF", Width = 200, Color = Color3.fromRGB(45, 45, 48), IsSustain = true },
	{ Text = "TREMOLO: OFF", Width = 180, Color = Color3.fromRGB(45, 45, 48), IsTremolo = true },
	{ Text = "CLOSE", Width = 110, Color = Color3.fromRGB(200, 60, 60), IsClose = true }
}

local v8 = nil

local function refreshToneButtonText() -- 2 equivalent calls inferred from this helper
	if not v8 then
		return
	end

	v8.Text = "TONE: " .. formatToneDisplayName(FreePlayController.GetCurrentTone()) -- inferred equivalent call
end

FreePlayController.OnToneChanged(refreshToneButtonText)

local v9 = nil
local v10 = nil
local color = Color3.fromRGB(45, 45, 48)
local color2 = Color3.fromRGB(66, 200, 120)

local v11 = nil
local function showFreePlayToast(p) -- 15 equivalent calls inferred from this helper
	if not v11 then
		local freePlayToastGui = Instance.new("ScreenGui")
		freePlayToastGui.Name = "FreePlayToastGui"
		freePlayToastGui.ResetOnSpawn = false
		freePlayToastGui.IgnoreGuiInset = true
		freePlayToastGui.DisplayOrder = 100
		freePlayToastGui.Parent = PlayerGui
		v11 = ThemeSwitchToast.new(freePlayToastGui)
	end

	v11:Show(p)
end

local v12 = {}
local color3 = Color3.fromRGB(70, 110, 90)

local function refreshSustainBoxes()
	local sustainFactor = FreePlayController.GetSustainFactor()
	local sustain = FreePlayController.GetSustain()

	for k, v13 in pairs(v12) do
		if k == sustainFactor then
			v13.BackgroundColor3 = sustain and color2 or color3
			v13.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			v13.BackgroundColor3 = color
			v13.TextColor3 = Color3.fromRGB(170, 170, 175)
		end
	end
end

local function refreshSustainButton() -- 5 equivalent calls inferred from this helper
	if not v10 then
		return
	end

	local sustain = FreePlayController.GetSustain()
	v10.Text = sustain and "SUSTAINER: ON" or "SUSTAINER: OFF"
	v10.BackgroundColor3 = sustain and color2 or color
	refreshSustainBoxes()
end

local v13 = nil
local v14 = nil
local color4 = Color3.fromRGB(70, 110, 90)

local function refreshTremoloSlider()
	if not v14 then
		return
	end

	local TREMOLO_MIN_BPM = FreePlayAutoMuteConfig.TREMOLO_MIN_BPM
	local TREMOLO_MAX_BPM = FreePlayAutoMuteConfig.TREMOLO_MAX_BPM
	local tremoloBpm = FreePlayController.GetTremoloBpm()
	local v15 = math.clamp((tremoloBpm - TREMOLO_MIN_BPM) / (TREMOLO_MAX_BPM - TREMOLO_MIN_BPM), 0, 1)
	v14.Fill.Size = UDim2.new(v15, 0, 1, 0)

	v14.Knob.AnchorPoint = Vector2.new(v15, 0.5)
	v14.Knob.Position = UDim2.new(v15, 0, 0.5, 0)
	v14.Label.Text = "TREMOLO " .. tremoloBpm .. " BPM"
	local tremolo = FreePlayController.GetTremolo()
	v14.Fill.BackgroundColor3 = tremolo and color2 or color4
end

local function refreshTremoloButton() -- 4 equivalent calls inferred from this helper
	refreshTremoloSlider()

	if not v13 then
		return
	end

	local tremolo = FreePlayController.GetTremolo()
	v13.Text = tremolo and "TREMOLO: ON" or "TREMOLO: OFF"
	v13.BackgroundColor3 = tremolo and color2 or color
end

local v15 = nil
local function refreshOverlapButton() -- 6 equivalent calls inferred from this helper
	if not v15 then
		return
	end

	local overlap = FreePlayController.GetOverlap()
	v15.Text = overlap and "OVERLAP: ON" or "OVERLAP: OFF"
	v15.BackgroundColor3 = overlap and color2 or color
end

local function refreshAutoMuteButton() -- 1 equivalent call inferred from this helper
	refreshOverlapButton() -- inferred equivalent call
	refreshSustainButton() -- inferred equivalent call
	refreshTremoloButton() -- inferred equivalent call

	if not v9 then
		return
	end

	local autoMute = FreePlayController.GetAutoMute()
	v9.Text = autoMute and "AUTO MUTE: ON" or "AUTO MUTE: OFF"
	v9.BackgroundColor3 = autoMute and color2 or color
end

local v16 = nil
local v17 = nil
local v18 = nil
local color5 = Color3.fromRGB(38, 120, 220)

local function refreshVibratoUi()
	local isActive = FreePlayVibrato.IsActive()

	if v17 and v17.Parent then
		v17.BackgroundColor3 = isActive and color2 or color
	end

	if v16 then
		v16.Text = isActive and "VIBRATO: ON" or "VIBRATO: OFF"
		v16.BackgroundColor3 = isActive and color2 or color
	end

	local v19 = v18

	if not v19 then
		return
	end

	local mode = FreePlayVibrato.GetMode()
	v19.ModeBtn.Text = mode == "T" and "TOGGLE" or "HOLD"
	v19.ModeBtn.BackgroundColor3 = mode == "T" and color5 or color

	local direction = FreePlayVibrato.GetDirection()
	v19.SymBtn.BackgroundColor3 = direction == FreePlayVibrato.DIR_SYM and color2 or color
	v19.UpBtn.BackgroundColor3 = direction == FreePlayVibrato.DIR_UP and color2 or color

	local rate = FreePlayVibrato.GetRate()
	local v20 = math.clamp(
		(rate - FreePlayVibrato.MIN_RATE) / (FreePlayVibrato.MAX_RATE - FreePlayVibrato.MIN_RATE),
		0,
		1
	)
	v19.Fill.Size = UDim2.new(v20, 0, 1, 0)
	v19.Fill.BackgroundColor3 = isActive and color2 or color4
	v19.Knob.AnchorPoint = Vector2.new(v20, 0.5)
	v19.Knob.Position = UDim2.new(v20, 0, 0.5, 0)
	v19.Label.Text = string.format("VIBRATO %.1f Hz", rate)
end

FreePlayVibrato.OnChanged(refreshVibratoUi)

local v19 = nil

local function setVibratoRateFromX(x)
	local v20 = v18

	if not (v20 and v20.Track.Parent) then
		return
	end

	local x2 = v20.Track.AbsoluteSize.X

	if x2 <= 0 then
		return
	end

	local v21 = math.clamp((x - v20.Track.AbsolutePosition.X) / x2, 0, 1)
	FreePlayVibrato.SetRate(FreePlayVibrato.MIN_RATE + v21 * (FreePlayVibrato.MAX_RATE - FreePlayVibrato.MIN_RATE))
end

UserInputService.InputChanged:Connect(function(input)
	if not v19 then
		return
	end

	if
		input == v19
		or v19.UserInputType == Enum.UserInputType.MouseButton1
		and input.UserInputType == Enum.UserInputType.MouseMovement
	then
		setVibratoRateFromX(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if
		v19
		and (input == v19 or v19.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1)
	then
		v19 = nil
	end
end)

for i, v20 in ipairs(v7) do
	local textButton = Instance.new("TextButton")
	textButton.Name = "Chrome_" .. v20.Text:gsub("%s", ""):gsub(":", "")
	textButton.LayoutOrder = i
	textButton.Size = UDim2.new(0, v20.Width, 1, 0)
	textButton.Text = v20.Text
	textButton.TextSize = 15
	textButton.Parent = chromeRow
	styleKey(textButton, v20.Color)

	if v20.IsTone then
		v8 = textButton
		textButton.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				local cycleTone = FreePlayController.CycleTone()
				refreshToneButtonText() -- inferred equivalent call
				local currentInstrumentType = FreePlayController.GetCurrentInstrumentType()

				if currentInstrumentType and cycleTone then
					FreePlayAssetPreloader.EnsureLoaded(
						currentInstrumentType,
						cycleTone,
						"Loading " .. formatToneDisplayName(cycleTone) .. " assets..." -- inferred equivalent call
					)
				end

				refreshVisibility()
			end
		end)
	elseif v20.IsTabs then
		textButton.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				local success, result = pcall(function()
					local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
					return require(ReplicatedStorage2.Modules:WaitForChild("TabsMenu", 5))
				end)

				if success then
					result.Toggle(textButton)
				else
					warn("[MENU] gagal memuat TabsMenu:", result)
				end
			end
		end)
	elseif v20.IsOverlap then
		v15 = textButton
		refreshOverlapButton() -- inferred equivalent call
		textButton.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				local v21 = not FreePlayController.GetOverlap()
				FreePlayController.SetOverlap(v21)
				refreshOverlapButton() -- inferred equivalent call

				if not v11 then
					local freePlayToastGui = Instance.new("ScreenGui")
					freePlayToastGui.Name = "FreePlayToastGui"
					freePlayToastGui.ResetOnSpawn = false
					freePlayToastGui.IgnoreGuiInset = true
					freePlayToastGui.DisplayOrder = 100
					freePlayToastGui.Parent = PlayerGui
					v11 = ThemeSwitchToast.new(freePlayToastGui)
				end

				v11:Show(v21 and "Overlap ON" or "Overlap OFF")
			end
		end)
	elseif v20.IsAutoMute then
		v9 = textButton
		textButton.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				local sustain = FreePlayController.GetSustain()
				local tremolo = FreePlayController.GetTremolo()
				local v21 = not FreePlayController.GetAutoMute()
				FreePlayController.SetAutoMute(v21)
				refreshOverlapButton() -- inferred equivalent call
				refreshSustainButton() -- inferred equivalent call
				refreshTremoloButton() -- inferred equivalent call

				if v9 then
					local autoMute = FreePlayController.GetAutoMute()
					v9.Text = autoMute and "AUTO MUTE: ON" or "AUTO MUTE: OFF"
					v9.BackgroundColor3 = autoMute and color2 or color
				end

				if v21 and sustain then
					showFreePlayToast("Sustainer OFF - Auto Mute ON") -- inferred equivalent call
				elseif v21 and tremolo then
					showFreePlayToast("Tremolo OFF - Auto Mute ON") -- inferred equivalent call
				else
					showFreePlayToast(v21 and "Auto Mute ON" or "Auto Mute OFF") -- inferred equivalent call
				end
			end
		end)
	elseif v20.IsSustain then
		v10 = textButton

		local SUSTAIN_FACTORS = FreePlayAutoMuteConfig.SUSTAIN_FACTORS
		local v21 = #SUSTAIN_FACTORS * 44 + (#SUSTAIN_FACTORS - 1) * 6
		local v22 = math.floor((v20.Width - v21) / 2)

		for j, v23 in ipairs(SUSTAIN_FACTORS) do
			local textButton2 = Instance.new("TextButton")
			textButton2.Name = "SustainFactor_" .. v23 .. "x"
			textButton2.Size = UDim2.new(0, 44, 0, 26)
			textButton2.Position = UDim2.new(0, v22 + (j - 1) * 50, 0, -30)
			textButton2.Text = v23 .. "x"
			textButton2.TextSize = 14
			textButton2.Parent = textButton
			styleKey(textButton2, color)
			v12[v23] = textButton2
			local v24 = v23
			textButton2.InputBegan:Connect(function(input)
				if
					(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
					and FreePlayController.SetSustainFactor(v24)
				then
					refreshSustainButton() -- inferred equivalent call
					showFreePlayToast("Sustainer " .. v24 .. "x") -- inferred equivalent call
				end
			end)
		end

		refreshSustainBoxes()
		textButton.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				local autoMute = FreePlayController.GetAutoMute()
				local tremolo = FreePlayController.GetTremolo()
				local v23 = not FreePlayController.GetSustain()
				FreePlayController.SetSustain(v23)
				refreshOverlapButton() -- inferred equivalent call
				refreshSustainButton() -- inferred equivalent call
				refreshTremoloButton() -- inferred equivalent call

				if v9 then
					local autoMute2 = FreePlayController.GetAutoMute()
					v9.Text = autoMute2 and "AUTO MUTE: ON" or "AUTO MUTE: OFF"
					v9.BackgroundColor3 = autoMute2 and color2 or color
				end

				if v23 and autoMute then
					showFreePlayToast("Auto Mute OFF - Sustainer ON") -- inferred equivalent call
				elseif v23 and tremolo then
					showFreePlayToast("Tremolo OFF - Sustainer ON") -- inferred equivalent call
				else
					showFreePlayToast(v23 and "Sustainer ON" or "Sustainer OFF") -- inferred equivalent call
				end
			end
		end)
	elseif v20.IsTremolo then
		v13 = textButton

		local tremoloBpmSlider = Instance.new("TextButton")
		tremoloBpmSlider.Name = "TremoloBpmSlider"
		tremoloBpmSlider.Size = UDim2.new(0, v20.Width, 0, 26)
		tremoloBpmSlider.Position = UDim2.new(0, 0, 0, -30)
		tremoloBpmSlider.Text = ""
		tremoloBpmSlider.ClipsDescendants = true
		tremoloBpmSlider.Parent = textButton
		styleKey(tremoloBpmSlider, color)

		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.Size = UDim2.new(0, 0, 1, 0)
		fill.BackgroundColor3 = color4
		fill.BorderSizePixel = 0
		fill.ZIndex = 1
		fill.Parent = tremoloBpmSlider
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 6)
		uiCorner.Parent = fill

		local knob = Instance.new("Frame")
		knob.Name = "Knob"
		knob.Size = UDim2.new(0, 4, 1, -6)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.BorderSizePixel = 0
		knob.ZIndex = 3
		knob.Parent = tremoloBpmSlider
		local uiCorner2 = Instance.new("UICorner")
		uiCorner2.CornerRadius = UDim.new(0, 2)
		uiCorner2.Parent = knob

		local bpmLabel = Instance.new("TextLabel")
		bpmLabel.Name = "BpmLabel"
		bpmLabel.Size = UDim2.new(1, 0, 1, 0)
		bpmLabel.BackgroundTransparency = 1
		bpmLabel.Font = Enum.Font.GothamBold
		bpmLabel.TextSize = 13
		bpmLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		bpmLabel.Text = ""
		bpmLabel.ZIndex = 2
		bpmLabel.Parent = tremoloBpmSlider

		v14 = { Track = tremoloBpmSlider, Fill = fill, Knob = knob, Label = bpmLabel }
		refreshTremoloSlider()

		local tremoloBpmEditButton = Instance.new("TextButton")
		tremoloBpmEditButton.Name = "TremoloBpmEditButton"
		tremoloBpmEditButton.Size = UDim2.new(0, 44, 0, 22)
		tremoloBpmEditButton.Position = UDim2.new(0, v20.Width - 44, 0, -56)
		tremoloBpmEditButton.Text = "EDIT"
		tremoloBpmEditButton.TextSize = 12
		tremoloBpmEditButton.Parent = textButton
		styleKey(tremoloBpmEditButton, color)

		local tremoloBpmInput = Instance.new("TextBox")
		tremoloBpmInput.Name = "TremoloBpmInput"
		tremoloBpmInput.Size = tremoloBpmSlider.Size
		tremoloBpmInput.Position = tremoloBpmSlider.Position
		tremoloBpmInput.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
		tremoloBpmInput.BorderSizePixel = 0
		tremoloBpmInput.Font = Enum.Font.GothamBold
		tremoloBpmInput.TextSize = 15
		tremoloBpmInput.TextColor3 = Color3.fromRGB(255, 255, 255)
		tremoloBpmInput.PlaceholderText = FreePlayAutoMuteConfig.TREMOLO_MIN_BPM .. "-" .. FreePlayAutoMuteConfig.TREMOLO_MAX_BPM .. " BPM"
		tremoloBpmInput.PlaceholderColor3 = Color3.fromRGB(130, 130, 135)
		tremoloBpmInput.ClearTextOnFocus = false
		tremoloBpmInput.TextXAlignment = Enum.TextXAlignment.Center
		tremoloBpmInput.Text = ""
		tremoloBpmInput.Visible = false
		tremoloBpmInput.ZIndex = 10
		tremoloBpmInput.Parent = textButton
		local uiCorner3 = Instance.new("UICorner")
		uiCorner3.CornerRadius = UDim.new(0, 6)
		uiCorner3.Parent = tremoloBpmInput
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = color2
		uiStroke.Thickness = 1.5
		uiStroke.Parent = tremoloBpmInput

		tremoloBpmInput:GetPropertyChangedSignal("Text"):Connect(function()
			local text = tremoloBpmInput.Text:gsub("%D", ""):sub(1, 3)

			if text ~= tremoloBpmInput.Text then
				tremoloBpmInput.Text = text
			end
		end)

		local lastTime = 0
		tremoloBpmInput.FocusLost:Connect(function(_, p)
			tremoloBpmInput.Visible = false
			lastTime = os.clock()

			if p and p.KeyCode == Enum.KeyCode.Escape then
				return
			end

			local text = tonumber(tremoloBpmInput.Text)

			if not text then
				return
			end

			local v21 = FreePlayController.SetTremoloBpm(text)

			if v21 then
				refreshTremoloSlider()

				if v21 ~= text then
					showFreePlayToast("BPM limited to " .. FreePlayAutoMuteConfig.TREMOLO_MIN_BPM .. "-" .. FreePlayAutoMuteConfig.TREMOLO_MAX_BPM) -- inferred equivalent call
				end
			end
		end)

		tremoloBpmEditButton.Activated:Connect(function()
			if os.clock() - lastTime < 0.25 then
				return
			end

			tremoloBpmInput.Text = tostring(FreePlayController.GetTremoloBpm())
			tremoloBpmInput.Visible = true
			tremoloBpmInput:CaptureFocus()
			tremoloBpmInput.SelectionStart = 1
			tremoloBpmInput.CursorPosition = #tremoloBpmInput.Text + 1
		end)

		local v21 = nil
		local function setBpmFromX(x) -- 2 equivalent calls inferred from this helper
			local x2 = tremoloBpmSlider.AbsoluteSize.X

			if x2 <= 0 then
				return
			end

			local v22 = math.clamp((x - tremoloBpmSlider.AbsolutePosition.X) / x2, 0, 1)
			local TREMOLO_MIN_BPM = FreePlayAutoMuteConfig.TREMOLO_MIN_BPM
			local TREMOLO_MAX_BPM = FreePlayAutoMuteConfig.TREMOLO_MAX_BPM

			if FreePlayController.SetTremoloBpm(TREMOLO_MIN_BPM + v22 * (TREMOLO_MAX_BPM - TREMOLO_MIN_BPM)) then
				refreshTremoloSlider()
			end
		end

		tremoloBpmSlider.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				v21 = input
				setBpmFromX(input.Position.X) -- inferred equivalent call
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if not v21 then
				return
			end

			if
				input == v21
				or v21.UserInputType == Enum.UserInputType.MouseButton1
				and input.UserInputType == Enum.UserInputType.MouseMovement
			then
				setBpmFromX(input.Position.X) -- inferred equivalent call
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if
				v21
				and (input == v21 or v21.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1)
			then
				v21 = nil
			end
		end)

		UserInputService.WindowFocusReleased:Connect(function()
			FreePlayController.StopAllTremolo()
			v21 = nil
		end)

		textButton.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				local autoMute = FreePlayController.GetAutoMute()
				local sustain = FreePlayController.GetSustain()
				local v22 = not FreePlayController.GetTremolo()
				FreePlayController.SetTremolo(v22)
				refreshOverlapButton() -- inferred equivalent call
				refreshSustainButton() -- inferred equivalent call
				refreshTremoloButton() -- inferred equivalent call

				if v9 then
					local autoMute2 = FreePlayController.GetAutoMute()
					v9.Text = autoMute2 and "AUTO MUTE: ON" or "AUTO MUTE: OFF"
					v9.BackgroundColor3 = autoMute2 and color2 or color
				end

				if v22 and autoMute then
					showFreePlayToast("Auto Mute OFF - Tremolo ON") -- inferred equivalent call
				elseif v22 and sustain then
					showFreePlayToast("Sustainer OFF - Tremolo ON") -- inferred equivalent call
				else
					showFreePlayToast(v22 and "Tremolo ON - " .. FreePlayController.GetTremoloBpm() .. " BPM" or "Tremolo OFF") -- inferred equivalent call
				end
			end
		end)
	elseif v20.IsVibrato then
		v16 = textButton

		local vibratoRateSlider = Instance.new("TextButton")
		vibratoRateSlider.Name = "VibratoRateSlider"
		vibratoRateSlider.Size = UDim2.new(0, v20.Width, 0, 26)
		vibratoRateSlider.Position = UDim2.new(0, 0, 0, -30)
		vibratoRateSlider.Text = ""
		vibratoRateSlider.ClipsDescendants = true
		vibratoRateSlider.Parent = textButton
		styleKey(vibratoRateSlider, color)

		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.Size = UDim2.new(0, 0, 1, 0)
		fill.BackgroundColor3 = color4
		fill.BorderSizePixel = 0
		fill.ZIndex = 1
		fill.Parent = vibratoRateSlider
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 6)
		uiCorner.Parent = fill

		local knob = Instance.new("Frame")
		knob.Name = "Knob"
		knob.Size = UDim2.new(0, 4, 1, -6)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.BorderSizePixel = 0
		knob.ZIndex = 3
		knob.Parent = vibratoRateSlider
		local uiCorner2 = Instance.new("UICorner")
		uiCorner2.CornerRadius = UDim.new(0, 2)
		uiCorner2.Parent = knob

		local rateLabel = Instance.new("TextLabel")
		rateLabel.Name = "RateLabel"
		rateLabel.Size = UDim2.new(1, 0, 1, 0)
		rateLabel.BackgroundTransparency = 1
		rateLabel.Font = Enum.Font.GothamBold
		rateLabel.TextSize = 13
		rateLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		rateLabel.Text = ""
		rateLabel.ZIndex = 2
		rateLabel.Parent = vibratoRateSlider

		local v21 = v20.Width - 44
		local v22 = v21 - 4 - 62
		local v23 = v22 - 4 - 32

		local function makeSmallButton(name, text, p, p2)
			local textButton2 = Instance.new("TextButton")
			textButton2.Name = name
			textButton2.Size = UDim2.new(0, p2, 0, 22)
			textButton2.Position = UDim2.new(0, p, 0, -56)
			textButton2.Text = text
			textButton2.TextSize = 12
			textButton2.Parent = textButton
			styleKey(textButton2, color)
			return textButton2
		end

		local smallButton = makeSmallButton("VibratoDirSym", "SYM", v23 - 4 - 40, 40)
		local smallButton2 = makeSmallButton("VibratoDirUp", "UP", v23, 32)
		local smallButton3 = makeSmallButton("VibratoModeButton", "HOLD", v22, 62)
		local smallButton4 = makeSmallButton("VibratoRateEditButton", "EDIT", v21, 44)

		v18 = {
			Track = vibratoRateSlider,
			Fill = fill,
			Knob = knob,
			Label = rateLabel,
			ModeBtn = smallButton3,
			SymBtn = smallButton,
			UpBtn = smallButton2
		}

		refreshVibratoUi()

		smallButton.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				FreePlayVibrato.SetDirection(FreePlayVibrato.DIR_SYM)

				if not v11 then
					local freePlayToastGui = Instance.new("ScreenGui")
					freePlayToastGui.Name = "FreePlayToastGui"
					freePlayToastGui.ResetOnSpawn = false
					freePlayToastGui.IgnoreGuiInset = true
					freePlayToastGui.DisplayOrder = 100
					freePlayToastGui.Parent = PlayerGui
					v11 = ThemeSwitchToast.new(freePlayToastGui)
				end

				v11:Show("Vibrato: Symmetric (up & down)")
			end
		end)
		smallButton2.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				FreePlayVibrato.SetDirection(FreePlayVibrato.DIR_UP)

				if not v11 then
					local freePlayToastGui = Instance.new("ScreenGui")
					freePlayToastGui.Name = "FreePlayToastGui"
					freePlayToastGui.ResetOnSpawn = false
					freePlayToastGui.IgnoreGuiInset = true
					freePlayToastGui.DisplayOrder = 100
					freePlayToastGui.Parent = PlayerGui
					v11 = ThemeSwitchToast.new(freePlayToastGui)
				end

				v11:Show("Vibrato: Upward (bend-style)")
			end
		end)
		smallButton3.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				local v24 = FreePlayVibrato.ToggleMode() == "T" and "Vibrato: TOGGLE (press Ctrl to switch on/off)"
					or "Vibrato: HOLD (hold Ctrl)"

				if not v11 then
					local freePlayToastGui = Instance.new("ScreenGui")
					freePlayToastGui.Name = "FreePlayToastGui"
					freePlayToastGui.ResetOnSpawn = false
					freePlayToastGui.IgnoreGuiInset = true
					freePlayToastGui.DisplayOrder = 100
					freePlayToastGui.Parent = PlayerGui
					v11 = ThemeSwitchToast.new(freePlayToastGui)
				end

				v11:Show(v24)
			end
		end)

		local vibratoRateInput = Instance.new("TextBox")
		vibratoRateInput.Name = "VibratoRateInput"
		vibratoRateInput.Size = vibratoRateSlider.Size
		vibratoRateInput.Position = vibratoRateSlider.Position
		vibratoRateInput.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
		vibratoRateInput.BorderSizePixel = 0
		vibratoRateInput.Font = Enum.Font.GothamBold
		vibratoRateInput.TextSize = 15
		vibratoRateInput.TextColor3 = Color3.fromRGB(255, 255, 255)
		vibratoRateInput.PlaceholderText = string.format(
			"%.1f-%.1f Hz",
			FreePlayVibrato.MIN_RATE,
			FreePlayVibrato.MAX_RATE
		)
		vibratoRateInput.PlaceholderColor3 = Color3.fromRGB(130, 130, 135)
		vibratoRateInput.ClearTextOnFocus = false
		vibratoRateInput.TextXAlignment = Enum.TextXAlignment.Center
		vibratoRateInput.Text = ""
		vibratoRateInput.Visible = false
		vibratoRateInput.ZIndex = 10
		vibratoRateInput.Parent = textButton
		local uiCorner3 = Instance.new("UICorner")
		uiCorner3.CornerRadius = UDim.new(0, 6)
		uiCorner3.Parent = vibratoRateInput
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = color2
		uiStroke.Thickness = 1.5
		uiStroke.Parent = vibratoRateInput

		vibratoRateInput:GetPropertyChangedSignal("Text"):Connect(function()
			local v24 = vibratoRateInput.Text:gsub("[^%d%.]", "")
			local v25 = v24:find(".", 1, true)

			if v25 then
				v24 = v24:sub(1, v25) .. v24:sub(v25 + 1):gsub("%.", "")
			end

			local text = v24:sub(1, 4)

			if text ~= vibratoRateInput.Text then
				vibratoRateInput.Text = text
			end
		end)

		local lastTime = 0
		vibratoRateInput.FocusLost:Connect(function(_, p)
			vibratoRateInput.Visible = false
			lastTime = os.clock()

			if p and p.KeyCode == Enum.KeyCode.Escape then
				return
			end

			local text = tonumber(vibratoRateInput.Text)

			if not text then
				return
			end

			local v24 = FreePlayVibrato.SetRate(text)

			if v24 then
				if math.abs(v24 - text) > 0.05 then
					showFreePlayToast(string.format( -- inferred equivalent call
						"Vibrato rate limited to %.1f-%.1f Hz",
						FreePlayVibrato.MIN_RATE,
						FreePlayVibrato.MAX_RATE
					))
				end

				refreshVibratoUi()
			end
		end)

		smallButton4.Activated:Connect(function()
			if os.clock() - lastTime < 0.25 then
				return
			end

			vibratoRateInput.Text = string.format("%.1f", FreePlayVibrato.GetRate())
			vibratoRateInput.Visible = true
			vibratoRateInput:CaptureFocus()
			vibratoRateInput.SelectionStart = 1
			vibratoRateInput.CursorPosition = #vibratoRateInput.Text + 1
		end)

		vibratoRateSlider.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				v19 = input
				setVibratoRateFromX(input.Position.X)
			end
		end)

		textButton.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				FreePlayVibrato.CtrlDown()
			end
		end)
		textButton.InputEnded:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				FreePlayVibrato.CtrlUp()
			end
		end)
		textButton.MouseLeave:Connect(function()
			FreePlayVibrato.CtrlUp()
		end)
	elseif v20.IsTuning then
		textButton.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				textButton.BackgroundColor3 = Color3.fromRGB(90, 90, 96)
				task.delay(0.12, function()
					textButton.BackgroundColor3 = v20.Color
				end)

				if fn then
					fn()
				end
			end
		end)
	elseif v20.IsClose then
		textButton.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				ModeManager.SetRhythm()
			end
		end)
	end
end

local leftModifierColumn = Instance.new("Frame")
leftModifierColumn.Name = "LeftModifierColumn"
leftModifierColumn.Position = UDim2.new(0, 0, 0, 52)
leftModifierColumn.BackgroundTransparency = 1
leftModifierColumn.Parent = keyboardCanvas

local noteGrid = Instance.new("Frame")
noteGrid.Name = "NoteGrid"
noteGrid.Position = UDim2.new(0, 144, 0, 52)
noteGrid.Size = UDim2.new(0, 1582, 0, 0)
noteGrid.BackgroundTransparency = 1
noteGrid.Parent = keyboardCanvas

local bottomRow = Instance.new("Frame")
bottomRow.Name = "BottomRow"
bottomRow.Size = UDim2.new(0, 1726, 0, 54)
bottomRow.BackgroundTransparency = 1
bottomRow.Parent = keyboardCanvas

local FreePlaySyncState = require(Modules.FreePlaySyncState)
local FreePlaySyncStyle = require(Modules.FreePlaySyncStyle)

local modifier_SYNC = Instance.new("TextButton")
modifier_SYNC.Name = "Modifier_SYNC"
modifier_SYNC.Position = UDim2.new(0, 0, 0, 0)
modifier_SYNC.Size = UDim2.new(0, 140, 0, 44)
modifier_SYNC.Text = "SYNC: OFF"
modifier_SYNC.Parent = keyboardCanvas
FreePlaySyncStyle.StylePaperButton(modifier_SYNC, 11)

local function refreshSyncUi() -- 1 equivalent call inferred from this helper
	local isEnabled = FreePlaySyncState.IsEnabled()
	modifier_SYNC.Text = isEnabled and "SYNC: ON" or "SYNC: OFF"
	FreePlaySyncStyle.SetPaperButtonActive(modifier_SYNC, isEnabled)
end

FreePlaySyncState.OnChanged(refreshSyncUi)
refreshSyncUi() -- inferred equivalent call
modifier_SYNC.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local v20 = not FreePlaySyncState.IsEnabled()
		FreePlaySyncState.SetEnabled(v20)
		showFreePlayToast(v20 and "Sync ON - others delayed " .. FreePlaySyncState.GetDelayMs() .. " ms" or "Sync OFF") -- inferred equivalent call
	end
end)

local modifier_ALT = Instance.new("TextButton")
modifier_ALT.Name = "Modifier_ALT"
modifier_ALT.Position = UDim2.new(0, 0, 0, 0)
modifier_ALT.Size = UDim2.new(0, 140, 1, 0)
modifier_ALT.Text = "ALT"
modifier_ALT.TextSize = 16
modifier_ALT.Parent = bottomRow
styleKey(modifier_ALT)

local modifier_SPACE = Instance.new("TextButton")
modifier_SPACE.Name = "Modifier_SPACE"
modifier_SPACE.Position = UDim2.new(0, 144, 0, 0)
modifier_SPACE.Size = UDim2.new(0, 1474, 1, 0)
modifier_SPACE.Text = "SPACE (MUTE)"
modifier_SPACE.TextSize = 18
modifier_SPACE.Parent = bottomRow
styleKey(modifier_SPACE)

modifier_SPACE.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		InputRouter.HandleMute()
	end
end)

InputRouter.OnMuteEvent(function()
	modifier_SPACE.BackgroundColor3 = Color3.fromRGB(90, 90, 96)
	local TweenService = game:GetService("TweenService")
	TweenService:Create(
		modifier_SPACE,
		TweenInfo.new(FreePlayAutoMuteConfig.MUTE_FADE_DURATION, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{ BackgroundColor3 = Color3.fromRGB(45, 45, 48) }
	):Play()
end)

local function makeSizeButton(name, text, p)
	local textButton = Instance.new("TextButton")
	textButton.Name = name
	textButton.Position = UDim2.new(0, p, 0, 0)
	textButton.Size = UDim2.new(0, 50, 1, 0)
	textButton.Text = text
	textButton.TextSize = 26
	textButton.Parent = bottomRow
	styleKey(textButton)
	return textButton
end

local sizeButton = makeSizeButton("Modifier_SIZEMINUS", "-", 1622)
local sizeButton2 = makeSizeButton("Modifier_SIZEPLUS", "+", 1676)
v6.Minus = sizeButton
v6.Plus = sizeButton2

function v6.Refresh()
	local v20, v21 = computeCanvasScaleFor(SettingsState.GetKeyboardScale())
	local v22

	if v20 then
		v22 = math.clamp(math.floor((v20 / v21 + -0.1) * 10 + 0.5) / 10, v5.Min, v5.Max)

		if not (computeCanvasScaleFor(v22) < v20 - 0.001) then
			v22 = nil
		end
	end

	sizeButton.TextTransparency = v22 and 0 or 0.65
	local v23, v24 = computeCanvasScaleFor(SettingsState.GetKeyboardScale())
	local v25

	if v23 then
		v25 = math.clamp(math.floor((v23 / v24 + 0.1) * 10 + 0.5) / 10, v5.Min, v5.Max)
		local v26 = computeCanvasScaleFor(v25)

		if not (v23 + 0.001 < v26) then
			v25 = nil
		end
	end

	sizeButton2.TextTransparency = v25 and 0 or 0.65
end

local function stepSize(p)
	local v20 = kbStepTarget(p)

	if v20 then
		SettingsState.SetField("KeyboardScale", v20, true)
		showFreePlayToast("Keyboard size " .. math.floor(v20 * 100 + 0.5) .. "%") -- inferred equivalent call
	else
		showFreePlayToast(p > 0 and "Keyboard is already as large as the screen allows" or "Keyboard is already at its smallest size") -- inferred equivalent call
	end
end

local function onPointer(sizeButton3, p) -- 2 equivalent calls inferred from this helper
	sizeButton3.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			stepSize(p)
		end
	end)
end

onPointer(sizeButton, -0.1) -- inferred equivalent call
onPointer(sizeButton2, 0.1) -- inferred equivalent call
v6.Refresh()

local color6 = Color3.fromRGB(45, 45, 48)
local color7 = Color3.fromRGB(66, 200, 120)

local function buildVibratoPad(textButton)
	textButton.RichText = true
	textButton.TextSize = 20
	textButton.TextWrapped = true
	textButton.Text = "L CTRL\n<font size=\"14\" color=\"rgb(190,190,195)\">(Vibrato)</font>"
	v17 = textButton

	textButton.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			FreePlayVibrato.CtrlDown()
		end
	end)
	textButton.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			FreePlayVibrato.CtrlUp()
		end
	end)
	textButton.MouseLeave:Connect(function()
		FreePlayVibrato.CtrlUp()
	end)
	refreshVibratoUi()
end

local color8 = Color3.fromRGB(45, 45, 48)
local color9 = Color3.fromRGB(90, 90, 96)

local v20 = {}
local v21 = nil

local v22 = nil
local v23 = nil

local function buildGrid(key, rows)
	for _, v24 in pairs(v20) do
		v24:Destroy()
	end

	table.clear(v20)

	for _, child in ipairs(leftModifierColumn:GetChildren()) do
		child:Destroy()
	end

	local count = #rows
	local gridHeight = computeGridHeight(count) -- inferred equivalent call
	leftModifierColumn.Size = UDim2.new(0, 140, 0, gridHeight)
	noteGrid.Size = UDim2.new(0, 1582, 0, gridHeight)

	local v24 = 52 + gridHeight + 8 + 54
	keyboardCanvas.Size = UDim2.new(0, 1726, 0, v24)
	bottomRow.Position = UDim2.new(0, 0, 0, 52 + gridHeight + 8)
	v4 = v24
	updateCanvasScale() -- inferred equivalent call
	local v25 = v3[key]
	local v26 = #v25
	local total = 0

	for _, v27 in ipairs(v25) do
		total += v27.Weight
	end

	local v27 = gridHeight - (v26 - 1) * 4
	local total2 = 0
	v22 = nil

	for _, v28 in ipairs(v25) do
		local v29 = v27 * (v28.Weight / total)
		local textButton = Instance.new("TextButton")
		textButton.Name = "Modifier_" .. v28.Text
		textButton.Position = UDim2.new(0, 0, 0, total2)
		textButton.Size = UDim2.new(1, 0, 0, v29)
		textButton.Text = v28.Text
		textButton.TextSize = 16
		textButton.Parent = leftModifierColumn

		if v28.Text == "CAPS" then
			local isOctaveUpEnabled = InputRouter.IsOctaveUpEnabled()
			styleKey(textButton, isOctaveUpEnabled and color7 or color6)
			v22 = textButton
			v23 = isOctaveUpEnabled

			textButton.InputBegan:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					local v30 = InputRouter.ToggleOctaveUp()
					textButton.BackgroundColor3 = v30 and color7 or color6
					v23 = v30
				end
			end)
		elseif v28.Text == "CTRL" then
			styleKey(textButton, v28.Color)
			buildVibratoPad(textButton)
		else
			styleKey(textButton, v28.Color)
		end

		total2 += v29 + 4
	end

	for i = 1, count do
		local v28 = v2[rows[i]]

		for j = 0, 12 do
			local v29 = j + 1
			local v30 = (i - 1) * 13 + j + 1

			local textButton = Instance.new("TextButton")
			textButton.Name = string.format("Note_%s_S%d_F%d_Lane%d", key, i, j, v30)
			textButton.Position = UDim2.new(0, (v29 - 1) * 122, 0, (i - 1) * 58)

			textButton.Size = UDim2.new(0, 118, 0, 54)
			textButton.Text = v28[v29]
			textButton.TextSize = 22
			textButton.Parent = noteGrid
			styleKey(textButton)

			local flag = false

			local function pressNote() -- 1 equivalent call inferred from this helper
				if flag then
					return
				end

				flag = true
				textButton.BackgroundColor3 = color9
				InputRouter.HandlePress(v30)
			end

			local function releaseNote() -- 2 equivalent calls inferred from this helper
				if not flag then
					return
				end

				flag = false
				textButton.BackgroundColor3 = color8
				InputRouter.HandleRelease(v30)
			end

			textButton.InputBegan:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					pressNote() -- inferred equivalent call
				end
			end)

			textButton.InputEnded:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					releaseNote() -- inferred equivalent call
				end
			end)

			textButton.MouseLeave:Connect(function()
				releaseNote() -- inferred equivalent call
			end)

			v20[v30] = textButton
			textButton:SetAttribute("TabsLane", v30)
		end
	end

	v21 = key
end

InputRouter.OnLaneEvent(function(p, p2)
	local v24 = v20[p]

	if not v24 then
		return
	end

	v24.BackgroundColor3 = p2 and color9 or color8
end)

local v24 = false
local v25 = nil
local v26 = nil

refreshVisibility = function()
	local v27 = v26 and FreePlayAssetPreloader.IsPreloaded(v26, FreePlayController.GetCurrentTone())
	local enabled = v24

	if enabled then
		if v25 == nil then
			enabled = false
		else
			enabled = ModeManager.IsFreePlay() and v27 == true
		end
	end

	virtualKeyboardUI.Enabled = enabled

	if not virtualKeyboardUI.Enabled and fn2 then
		fn2()
	end

	refreshAutoMuteButton() -- inferred equivalent call
end

local TUNING_STEP_CENTS = FreePlaySoundAdapter.TUNING_STEP_CENTS
local TUNING_MAX_CENTS = FreePlaySoundAdapter.TUNING_MAX_CENTS

local v27 = {
	{ Label = "E", String = 6, OpenSemitone = 4 },
	{ Label = "A", String = 5, OpenSemitone = 9 },
	{ Label = "D", String = 4, OpenSemitone = 2 },
	{ Label = "G", String = 3, OpenSemitone = 7 },
	{ Label = "B", String = 2, OpenSemitone = 11 },
	{ Label = "e", String = 1, OpenSemitone = 4 }
}

local v28 = {
	{ Label = "E", String = 4, OpenSemitone = 4 },
	{ Label = "A", String = 3, OpenSemitone = 9 },
	{ Label = "D", String = 2, OpenSemitone = 2 },
	{ Label = "G", String = 1, OpenSemitone = 7 }
}

local v29 = v27

local v30 = {
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
local v31 = {
	"C",
	"Db",
	"D",
	"Eb",
	"E",
	"F",
	"Gb",
	"G",
	"Ab",
	"A",
	"Bb",
	"B"
}

local v32 = false

local color10 = Color3.fromRGB(235, 235, 235)
local color11 = Color3.fromRGB(150, 150, 156)
local color12 = Color3.fromRGB(66, 200, 120)
local color13 = Color3.fromRGB(28, 28, 30)
local color14 = Color3.fromRGB(38, 120, 220)

local function formatPitch(p, p2) -- 1 equivalent call inferred from this helper
	local v34 = math.round(p2 / TUNING_STEP_CENTS)
	local v35 = math.floor(v34 / 2)
	local v36 = v32 and v31 or v30
	local v37 = v36[(p.OpenSemitone + v35) % 12 + 1]

	if v34 % 2 == 0 then
		return v37
	end

	return v37 .. "-" .. v36[(p.OpenSemitone + v35 + 1) % 12 + 1]
end

local function readCentsByString()
	local localTuning = FreePlaySoundAdapter.GetLocalTuning()
	local centsByString = {}

	for i = 1, FreePlaySoundAdapter.TUNING_STRING_COUNT do
		centsByString[i] = localTuning and localTuning[i] or 0
	end

	return centsByString
end

local function onClick(p, fn3) -- 4 equivalent calls inferred from this helper
	p.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			fn3()
		end
	end)
end

local tuningPopup = Instance.new("Frame")
tuningPopup.Name = "TuningPopup"
tuningPopup.Position = UDim2.new(0, 144, 0, 52)
tuningPopup.Size = UDim2.new(0, 380, 0, 0)
tuningPopup.AutomaticSize = Enum.AutomaticSize.Y
tuningPopup.BackgroundColor3 = color13
tuningPopup.BorderSizePixel = 0
tuningPopup.Active = true
tuningPopup.ZIndex = 30
tuningPopup.Visible = false
tuningPopup.Parent = keyboardCanvas

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = tuningPopup
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(70, 70, 74)
uiStroke.Thickness = 1
uiStroke.Parent = tuningPopup
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 12)
uiPadding.PaddingBottom = UDim.new(0, 12)
uiPadding.PaddingLeft = UDim.new(0, 12)
uiPadding.PaddingRight = UDim.new(0, 12)
uiPadding.Parent = tuningPopup
local uiListLayout2 = Instance.new("UIListLayout")
uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout2.FillDirection = Enum.FillDirection.Vertical
uiListLayout2.Padding = UDim.new(0, 6)
uiListLayout2.Parent = tuningPopup

local tuningPresetsPanel = Instance.new("Frame")
tuningPresetsPanel.Name = "TuningPresetsPanel"
tuningPresetsPanel.Position = UDim2.new(0, 532, 0, 52)
tuningPresetsPanel.Size = UDim2.new(0, 220, 0, 0)
tuningPresetsPanel.AutomaticSize = Enum.AutomaticSize.Y
tuningPresetsPanel.BackgroundColor3 = color13
tuningPresetsPanel.BorderSizePixel = 0
tuningPresetsPanel.Active = true
tuningPresetsPanel.ZIndex = 30
tuningPresetsPanel.Visible = false
tuningPresetsPanel.Parent = keyboardCanvas

local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(0, 10)
uiCorner2.Parent = tuningPresetsPanel
local uiStroke2 = Instance.new("UIStroke")
uiStroke2.Color = Color3.fromRGB(70, 70, 74)
uiStroke2.Thickness = 1
uiStroke2.Parent = tuningPresetsPanel
local uiPadding2 = Instance.new("UIPadding")
uiPadding2.PaddingTop = UDim.new(0, 12)
uiPadding2.PaddingBottom = UDim.new(0, 12)
uiPadding2.PaddingLeft = UDim.new(0, 12)
uiPadding2.PaddingRight = UDim.new(0, 12)
uiPadding2.Parent = tuningPresetsPanel
local uiListLayout3 = Instance.new("UIListLayout")
uiListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout3.FillDirection = Enum.FillDirection.Vertical
uiListLayout3.Padding = UDim.new(0, 4)
uiListLayout3.Parent = tuningPresetsPanel

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 34)
header.BackgroundTransparency = 1
header.LayoutOrder = 0
header.Parent = tuningPopup

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, -34, 1, 0)
textLabel.BackgroundTransparency = 1
textLabel.Text = "TUNING"
textLabel.Font = Enum.Font.GothamBold
textLabel.TextSize = 18
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.TextColor3 = color10
textLabel.Parent = header

local tuningClose = Instance.new("TextButton")
tuningClose.Name = "TuningClose"
tuningClose.AnchorPoint = Vector2.new(1, 0.5)
tuningClose.Position = UDim2.new(1, 0, 0.5, 0)
tuningClose.Size = UDim2.new(0, 34, 0, 30)
tuningClose.Text = "X"
tuningClose.TextSize = 16
tuningClose.Parent = header
styleKey(tuningClose, Color3.fromRGB(200, 60, 60))

local v34 = {}

local function renderTuning()
	local v35 = readCentsByString()

	for i, v36 in ipairs(v29) do
		local v37 = v35[v36.String]
		local v38 = v34[i]
		local value = v38.Value
		value.Text = formatPitch(v36, v37) -- inferred equivalent call
		v38.Value.TextColor3 = v37 ~= 0 and color12 or color10
		v38.Plus.TextColor3 = TUNING_MAX_CENTS <= v37 and color11 or color10
		v38.Minus.TextColor3 = v37 <= -TUNING_MAX_CENTS and color11 or color10
	end
end

local function applyCentsByString(p) -- 2 equivalent calls inferred from this helper
	FreePlaySoundAdapter.SetLocalTuning(p)
	renderTuning()
end

local function stepString(p, p2) -- 2 equivalent calls inferred from this helper
	local v35 = readCentsByString()
	v35[p.String] = math.clamp(v35[p.String] + p2 * TUNING_STEP_CENTS, -TUNING_MAX_CENTS, TUNING_MAX_CENTS)
	v32 = false
	applyCentsByString(v35) -- inferred equivalent call
end

for i, v35 in ipairs(v27) do
	local frame = Instance.new("Frame")
	frame.Name = "Row_String" .. v35.String
	frame.Size = UDim2.new(1, 0, 0, 34)
	frame.BackgroundTransparency = 1
	frame.LayoutOrder = i
	frame.Parent = tuningPopup

	local stringLabel = Instance.new("TextLabel")
	stringLabel.Name = "StringLabel"
	stringLabel.Size = UDim2.new(0, 40, 1, 0)
	stringLabel.BackgroundTransparency = 1
	stringLabel.Text = v35.Label .. " :"
	stringLabel.Font = Enum.Font.GothamBold
	stringLabel.TextSize = 18
	stringLabel.TextXAlignment = Enum.TextXAlignment.Left
	stringLabel.TextColor3 = color11
	stringLabel.Parent = frame

	local value = Instance.new("TextLabel")
	value.Name = "Value"
	value.Position = UDim2.new(0, 46, 0, 0)
	value.Size = UDim2.new(1, -176, 1, 0)
	value.BackgroundTransparency = 1
	value.Text = ""
	value.Font = Enum.Font.GothamBold
	value.TextSize = 20
	value.TextXAlignment = Enum.TextXAlignment.Left
	value.TextColor3 = color10
	value.Parent = frame

	local minus = Instance.new("TextButton")
	minus.Name = "Minus"
	minus.AnchorPoint = Vector2.new(1, 0.5)
	minus.Position = UDim2.new(1, -66, 0.5, 0)
	minus.Size = UDim2.new(0, 60, 0, 30)
	minus.Text = "-"
	minus.TextSize = 22
	minus.Parent = frame
	styleKey(minus)

	local plus = Instance.new("TextButton")
	plus.Name = "Plus"
	plus.AnchorPoint = Vector2.new(1, 0.5)
	plus.Position = UDim2.new(1, 0, 0.5, 0)
	plus.Size = UDim2.new(0, 60, 0, 30)
	plus.Text = "+"
	plus.TextSize = 22
	plus.Parent = frame
	styleKey(plus)

	v34[i] = {
		Frame = frame,
		Label = stringLabel,
		Value = value,
		Plus = plus,
		Minus = minus
	}

	local function fn3()
		local v36 = v29[i]

		if v36 then
			stepString(v36, 1) -- inferred equivalent call
		end
	end

	onClick(plus, fn3) -- inferred equivalent call

	local function fn4()
		local v36 = v29[i]

		if v36 then
			stepString(v36, -1) -- inferred equivalent call
		end
	end

	onClick(minus, fn4) -- inferred equivalent call
end

local presetsButton = Instance.new("TextButton")
presetsButton.Name = "PresetsButton"
presetsButton.Size = UDim2.new(1, 0, 0, 34)
presetsButton.LayoutOrder = #v27 + 1
presetsButton.Text = "PRESETS >"
presetsButton.TextSize = 15
presetsButton.Parent = tuningPopup
styleKey(presetsButton, color14)

local function setPresetsOpen(visible) -- 3 equivalent calls inferred from this helper
	tuningPresetsPanel.Visible = visible
	presetsButton.Text = visible and "PRESETS <" or "PRESETS >"
end

for i, v35 in ipairs({
	{
		Name = "E Standard",
		Cents = { 0, 0, 0, 0, 0, 0 }
	},
	{
		Name = "Eb Standard",
		Cents = { -100, -100, -100, -100, -100, -100 },
		Flats = true
	},
	{
		Name = "B Standard",
		Cents = { -500, -500, -500, -500, -500, -500 }
	},
	{
		Name = "C Standard",
		Cents = { -400, -400, -400, -400, -400, -400 }
	},
	{
		Name = "C# Standard",
		Cents = { -300, -300, -300, -300, -300, -300 }
	},
	{
		Name = "Drop D",
		Cents = { -200, 0, 0, 0, 0, 0 }
	},
	{
		Name = "D Standard",
		Cents = { -200, -200, -200, -200, -200, -200 }
	},
	{
		Name = "Drop A",
		Cents = { -700, -500, -500, -500, -500, -500 }
	}
}) do
	local textButton = Instance.new("TextButton")
	textButton.Name = "Preset_" .. v35.Name
	textButton.Size = UDim2.new(1, 0, 0, 34)
	textButton.LayoutOrder = i
	textButton.Text = v35.Name
	textButton.TextSize = 15
	textButton.Parent = tuningPresetsPanel
	styleKey(textButton)

	local function fn3()
		local v36 = {}

		for j, v37 in ipairs(v29) do
			v36[v37.String] = v35.Cents[j]
		end

		v32 = v35.Flats == true
		applyCentsByString(v36) -- inferred equivalent call
		setPresetsOpen(false) -- inferred equivalent call
	end

	onClick(textButton, fn3) -- inferred equivalent call
end

local function fn3()
	setPresetsOpen(not tuningPresetsPanel.Visible) -- inferred equivalent call
end

presetsButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		fn3()
	end
end)

for _, folder in ipairs({ tuningPopup, tuningPresetsPanel }) do
	for _, guiObject in ipairs(folder:GetDescendants()) do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = 31
		end
	end
end

local function applyInstrumentRows()
	v29 = v26 == "Bass" and v28 or v27

	for k, v35 in pairs(v34) do
		local v36 = v29[k]
		v35.Frame.Visible = v36 ~= nil

		if v36 then
			v35.Label.Text = v36.Label .. " :"
		end
	end
end

fn2 = function()
	tuningPopup.Visible = false
	setPresetsOpen(false) -- inferred equivalent call
end

fn = function()
	if tuningPopup.Visible then
		fn2()
		return
	end

	if not FreePlaySoundAdapter.IsTunable(v26) then
		return
	end

	applyInstrumentRows()
	renderTuning()
	tuningPopup.Visible = true
end

local function fn4()
	fn2()
end

onClick(tuningClose, fn4) -- inferred equivalent call

local function fn5()
	v32 = false
	FreePlaySoundAdapter.SetLocalTuning(nil)
	fn2()
	applyInstrumentRows()
	renderTuning()
end

instrumentHUDUpdate.OnClientEvent:Connect(function(p, p2)
	v24 = p
	v26 = p and p2 or nil
	v25 = p and v[p2] or nil

	fn5()

	task.defer(refreshAutoMuteButton)

	if v25 and v25.Key ~= v21 then
		buildGrid(v25.Key, v25.Rows)
	end

	refreshToneButtonText() -- inferred equivalent call
	refreshVisibility()
end)

ModeManager.OnChanged(function()
	refreshVisibility()
end)

FreePlayAssetPreloader.OnPreloadComplete(function()
	refreshVisibility()
end)

RunService.Heartbeat:Connect(function()
	if not v22 then
		return
	end

	local isOctaveUpEnabled = InputRouter.IsOctaveUpEnabled()

	if isOctaveUpEnabled == v23 then
		return
	end

	v23 = isOctaveUpEnabled
	v22.BackgroundColor3 = isOctaveUpEnabled and color7 or color6
end)