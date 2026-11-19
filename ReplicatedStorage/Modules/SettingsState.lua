local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local RhythmCustomizationConfig = require(ReplicatedStorage.Modules.RhythmCustomizationConfig)

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local SetSetting = RemoteEvents:WaitForChild("SetSetting")
local SettingsUpdate = RemoteEvents:WaitForChild("SettingsUpdate")

local SettingsState = {}

local v = {}
v.ButtonSizeMultiplier = 1
v.ButtonSpacingExtra = 0
v.ButtonOpacity = 0.55
v.ButtonPositions = {}
v.KeybindFiveKey = { "X", "C", "V", "B", "N" }
v.KeybindTwoKey = { "X", "C" }
v.KeybindDoublePedalNormal = "Z"
v.KeybindDoublePedalFlipped = "M"
v.KeybindVibratoRhythm = "LeftControl"
v.KeybindStarPower = "Space"

v.InputMode = "Auto"
v.InputModeChosen = false
v.KeybindFiveKeyPad = { "ButtonL2", "ButtonL1", "ButtonR1", "ButtonR2", "ButtonB" }
v.KeybindTwoKeyPad = { "ButtonL1", "ButtonR1" }
v.KeybindDoublePedalNormalPad = "ButtonA"
v.KeybindDoublePedalFlippedPad = "ButtonX"
v.KeybindStarPowerPad = "ButtonSelect"
v.VibrationEnabled = true
v.ControllerGlyphStyle = "Auto"
v.ControllerType = "Gamepad"
v.NoteSpeedMultiplier = 1
v.FirstPersonFOV = 80
v.AudioOffsetMs = 0
v.HasCalibratedAudioOffset = false
v.ShakeEnabled = true
v.HitEffectEnabled = true
v.HitSparkleEnabled = true
v.AutoStarPower = true
v.JudgmentPopEnabled = true
v.HideOwnJudgmentText = false
v.HideAllJudgmentText = false
v.WrongSoundEnabled = true
v.ReduceMotionEnabled = false
v.ShowPerfStats = true
v.ShowModsButton = true
v.UIStyle = "NewUI"

v.HudOpacity = 1
v.StarPowerBarOpacity = 1
v.BandFeedOpacity = 1
v.StreakNoticeOpacity = 1
v.HudOpacityLinked = false
v.HudOpacityAll = 1
v.HudKeepContentClear = true
v.HudContentOpacity = 1

v.FreePlayOpacity = 0.58

v.DrumPadScale = 1

v.KeyboardScale = 1
v.PianoScale = 1

v.RhythmShape = RhythmCustomizationConfig.DefaultShape
v.RhythmLaneColors = {}
v.RhythmJudgmentColors = {}
v.RhythmThemePreset = "Default"
v.HighwaySkin = "Random"
v.RailHud3D = true

v.HighwayCamElevation = 41
v.HighwayCamFov = 55
v.HighwayCamZoom = 0.62
v.HighwayCamHitY = 0.63
v.HighwayCamLength = 58
v.HighwayCamCustom = false

local v2 = {}
local v3 = {}

local v4 = {}
local v5 = false

function SettingsState.HasLoadedFromServer()
	return v5
end

function SettingsState.OnChanged(p)
	table.insert(v2, p)
end

local function notify()
	for _, callback in ipairs(v2) do
		local success, result = pcall(callback, v)

		if not success then
			warn("[SettingsState] Error pada listener:", result)
		end
	end
end

SettingsUpdate.OnClientEvent:Connect(function(p)
	v5 = true

	if next(v4) ~= nil then
		p = table.clone(p)

		for k, v6 in pairs(v4) do
			p[k] = v6
		end
	end

	v = p
	notify()
end)

local RunService = game:GetService("RunService")

if RunService:IsClient() then
	SetSetting:FireServer("RequestSync")
end

function SettingsState.GetButtonSizeMultiplier()
	return v.ButtonSizeMultiplier or 1
end

function SettingsState.GetButtonSpacingExtra()
	return v.ButtonSpacingExtra or 0
end

function SettingsState.GetButtonWidthMultiplier()
	return v.ButtonWidthMultiplier or v.ButtonSizeMultiplier or 1
end

function SettingsState.GetButtonHeightMultiplier()
	return v.ButtonHeightMultiplier or v.ButtonSizeMultiplier or 1
end

function SettingsState.GetButtonSizeLinked(): boolean
	return v.ButtonSizeLinked == nil or v.ButtonSizeLinked == true
end

function SettingsState.GetTouchChartEnabled(): boolean
	return v.TouchChartEnabled == nil or v.TouchChartEnabled == true
end

function SettingsState.SetTouchChartEnabled(p)
	SettingsState.SetField("TouchChartEnabled", p and true or false, true)
end

function SettingsState.GetButtonGroupOffset()
	return Vector2.new(v.ButtonGroupOffsetX or 0, v.ButtonGroupOffsetY or 0)
end

function SettingsState.GetButtonOpacity()
	return v.ButtonOpacity or 0.55
end

local v6 = {
	Hud = "HudOpacity",
	StarPower = "StarPowerBarOpacity",
	BandFeed = "BandFeedOpacity",
	StreakNotice = "StreakNoticeOpacity"
}

function SettingsState.GetHudKeepContentClear(): boolean
	return v.HudKeepContentClear ~= false
end

function SettingsState.GetHudContentOpacity()
	local hudContentOpacity = v.HudContentOpacity

	if typeof(hudContentOpacity) == "number" then
		return (math.clamp(hudContentOpacity, 0.1, 1))
	end

	return 1
end

function SettingsState.GetContentOpacity(p)
	if SettingsState.GetHudKeepContentClear() then
		return SettingsState.GetHudContentOpacity()
	end

	return SettingsState.GetOpacity(p)
end

function SettingsState.GetHudOpacityLinked(): boolean
	return v.HudOpacityLinked == true
end

function SettingsState.GetHudOpacityAll()
	local hudOpacityAll = v.HudOpacityAll

	if typeof(hudOpacityAll) == "number" then
		return (math.clamp(hudOpacityAll, 0.1, 1))
	end

	return 1
end

function SettingsState.GetOpacity(p)
	if v.HudOpacityLinked == true then
		return SettingsState.GetHudOpacityAll()
	end

	local v7 = v6[p]
	local v8 = v7 and v[v7]

	if typeof(v8) == "number" then
		return (math.clamp(v8, 0.1, 1))
	end

	return 1
end

function SettingsState.GetFreePlayOpacity()
	local freePlayOpacity = v.FreePlayOpacity

	if typeof(freePlayOpacity) == "number" then
		return (math.clamp(freePlayOpacity, 0.2, 1))
	end

	return 0.58
end

function SettingsState.GetDrumPadScale()
	local drumPadScale = v.DrumPadScale

	if typeof(drumPadScale) == "number" then
		return (math.clamp(drumPadScale, 0.5, 1.5))
	end

	return 1
end

function SettingsState.GetKeyboardScale()
	local keyboardScale = v.KeyboardScale

	if typeof(keyboardScale) == "number" then
		return (math.clamp(keyboardScale, 0.5, 1.5))
	end

	return 1
end

function SettingsState.GetPianoScale()
	local pianoScale = v.PianoScale

	if typeof(pianoScale) == "number" then
		return (math.clamp(pianoScale, 0.5, 1.5))
	end

	return 1
end

function SettingsState.GetNoteSpeedMultiplier()
	return v.NoteSpeedMultiplier or 1
end

function SettingsState.GetFirstPersonFOV()
	return v.FirstPersonFOV or 80
end

function SettingsState.GetAudioOffsetMs()
	return v.AudioOffsetMs or 0
end

function SettingsState.GetHasCalibratedAudioOffset(): boolean
	return v.HasCalibratedAudioOffset == true
end

function SettingsState.SetAudioOffsetMs(value)
	local v7 = math.clamp(value, -500, 500)
	SettingsState.SetField("AudioOffsetMs", v7, true)

	SettingsState.SetField("HasCalibratedAudioOffset", true, true)
end

function SettingsState.GetShakeEnabled()
	return v.ShakeEnabled == nil or v.ShakeEnabled
end

function SettingsState.SetShakeEnabled(p)
	SettingsState.SetField("ShakeEnabled", p and true or false, true)
end

function SettingsState.GetHitEffectEnabled()
	return v.HitEffectEnabled == nil or v.HitEffectEnabled
end

function SettingsState.SetHitEffectEnabled(p)
	SettingsState.SetField("HitEffectEnabled", p and true or false, true)
end

function SettingsState.GetHitSparkleEnabled()
	return v.HitSparkleEnabled == nil or v.HitSparkleEnabled
end

function SettingsState.SetHitSparkleEnabled(p)
	SettingsState.SetField("HitSparkleEnabled", p and true or false, true)
end

function SettingsState.GetAutoStarPower(): boolean
	return v.AutoStarPower == nil or v.AutoStarPower == true
end

function SettingsState.SetAutoStarPower(p)
	SettingsState.SetField("AutoStarPower", p and true or false, true)
end

function SettingsState.GetJudgmentPopEnabled()
	return v.JudgmentPopEnabled == nil or v.JudgmentPopEnabled
end

function SettingsState.SetJudgmentPopEnabled(p)
	SettingsState.SetField("JudgmentPopEnabled", p and true or false, true)
end

function SettingsState.GetHideOwnJudgmentText(): boolean
	return v.HideOwnJudgmentText == true
end

function SettingsState.SetHideOwnJudgmentText(p)
	SettingsState.SetField("HideOwnJudgmentText", p and true or false, true)
end

function SettingsState.GetHideAllJudgmentText(): boolean
	return v.HideAllJudgmentText == true
end

function SettingsState.SetHideAllJudgmentText(p)
	SettingsState.SetField("HideAllJudgmentText", p and true or false, true)
end

function SettingsState.GetWrongSoundEnabled()
	return v.WrongSoundEnabled == nil or v.WrongSoundEnabled
end

function SettingsState.SetWrongSoundEnabled(p)
	SettingsState.SetField("WrongSoundEnabled", p and true or false, true)
end

function SettingsState.GetReduceMotionEnabled(): boolean
	return v.ReduceMotionEnabled == true
end

function SettingsState.SetReduceMotionEnabled(p)
	SettingsState.SetField("ReduceMotionEnabled", p and true or false, true)
end

function SettingsState.GetShowPerfStats(): boolean
	return v.ShowPerfStats == nil or v.ShowPerfStats == true
end

function SettingsState.SetShowPerfStats(p)
	SettingsState.SetField("ShowPerfStats", p and true or false, true)
end

function SettingsState.GetShowModsButton(): boolean
	return v.ShowModsButton == nil or v.ShowModsButton == true
end

function SettingsState.SetShowModsButton(p)
	SettingsState.SetField("ShowModsButton", p and true or false, true)
end

function SettingsState.GetUIStyle(): string
	return if v.UIStyle == "Default" then "Default" else "NewUI"
end

function SettingsState.SetUIStyle(p)
	if p ~= "Default" and p ~= "NewUI" then
		return
	end

	SettingsState.SetField("UIStyle", p, true)
end

function SettingsState.GetStageLightingLiteDefault()
	local UserInputService2 = game:GetService("UserInputService")
	return UserInputService2.TouchEnabled and not UserInputService2.KeyboardEnabled
end

function SettingsState.GetStageLightingLite()
	if v.StageLightingLite == nil then
		return SettingsState.GetStageLightingLiteDefault()
	end

	return v.StageLightingLite == true
end

function SettingsState.SetStageLightingLite(p)
	SettingsState.SetField("StageLightingLite", p and true or false, true)
end

function SettingsState.GetStageLightingReduceFlash(): boolean
	return v.StageLightingReduceFlash == true
end

function SettingsState.SetStageLightingReduceFlash(p)
	SettingsState.SetField("StageLightingReduceFlash", p and true or false, true)
end

function SettingsState.GetRhythmShape()
	return v.RhythmShape or RhythmCustomizationConfig.DefaultShape
end

function SettingsState.GetFirstPersonFOVPref()
	local firstPersonFOVPref = v.FirstPersonFOVPref

	if typeof(firstPersonFOVPref) == "number" then
		return (math.clamp(firstPersonFOVPref, 30, 120))
	end

	return nil
end

function SettingsState.SetFirstPersonFOVPref(value)
	if typeof(value) ~= "number" then
		return
	end

	SettingsState.SetField("FirstPersonFOVPref", (math.clamp(value, 30, 120)))
end

SettingsState.CamDefaults = {
	HighwayCamElevation = 41,
	HighwayCamFov = 55,
	HighwayCamZoom = 0.62,
	HighwayCamHitY = 0.63,
	HighwayCamLength = 58
}
function SettingsState.GetHighwayCamCustom(): boolean
	return v.HighwayCamCustom == true
end
function SettingsState.GetHighwayCamValue(p)
	local camDefault = SettingsState.CamDefaults[p]

	if v.HighwayCamCustom == true then
		return v[p] or camDefault
	end

	return camDefault
end

function SettingsState.GetHighwayCamElevation()
	return SettingsState.GetHighwayCamValue("HighwayCamElevation")
end
function SettingsState.GetHighwayCamFov()
	return SettingsState.GetHighwayCamValue("HighwayCamFov")
end
function SettingsState.GetHighwayCamZoom()
	return SettingsState.GetHighwayCamValue("HighwayCamZoom")
end
function SettingsState.GetHighwayCamHitY()
	return SettingsState.GetHighwayCamValue("HighwayCamHitY")
end
function SettingsState.GetHighwayCamLength()
	return SettingsState.GetHighwayCamValue("HighwayCamLength")
end
function SettingsState.SetHighwayCam(p, value)
	local v7 = ({
		HighwayCamElevation = { 18, 50 },
		HighwayCamFov = { 25, 60 },
		HighwayCamZoom = { 0.5, 0.88 },
		HighwayCamHitY = { 0.2, 0.7 },
		HighwayCamLength = { 30, 60 }
	})[p]

	if not v7 or typeof(value) ~= "number" then
		return
	end

	local v8 = math.clamp(value, v7[1], v7[2])

	if v.HighwayCamCustom == true then
		SettingsState.SetField(p, v8)
		return
	end

	local v9 = { HighwayCamCustom = true }

	for k, camDefault in pairs(SettingsState.CamDefaults) do
		v9[k] = camDefault
	end

	v9[p] = v8
	SettingsState.SetFields(v9)
end

function SettingsState.GetHighwaySkin()
	return v.HighwaySkin or "Random"
end

function SettingsState.SetHighwaySkin(value)
	if type(value) ~= "string" then
		return
	end

	SettingsState.SetField("HighwaySkin", value, true)
end

function SettingsState.GetRailHud3D(): boolean
	return v.RailHud3D ~= false
end

function SettingsState.SetRailHud3D(p)
	SettingsState.SetField("RailHud3D", p == true, true)
end

function SettingsState.GetRhythmLaneColors(p)
	local v7 = v.RhythmLaneColors and v.RhythmLaneColors[tostring(p)]

	if not v7 then
		return nil
	end

	local result = {}
	local flag = false

	for i = 1, p do
		local v8 = v7[i]

		if not (v8 and v8 ~= false) then
			continue
		end

		result[i] = {
			NoteInner = RhythmCustomizationConfig.DeserializeColor(v8.NoteInner),
			NoteOuter = RhythmCustomizationConfig.DeserializeColor(v8.NoteOuter),
			ReceptorRing = RhythmCustomizationConfig.DeserializeColor(v8.ReceptorRing),
			ReceptorPress = RhythmCustomizationConfig.DeserializeColor(v8.ReceptorPress)
		}
		flag = true
	end

	return if flag then result else nil
end

function SettingsState.GetRhythmJudgmentColor(p)
	local v7 = v.RhythmJudgmentColors and v.RhythmJudgmentColors[p]

	if v7 and v7 ~= false then
		return RhythmCustomizationConfig.DeserializeColor(v7)
	end

	return nil
end

function SettingsState.GetRhythmThemePreset()
	return v.RhythmThemePreset or "Default"
end

function SettingsState.GetButtonPositionOffset(p)
	local v7 = v.ButtonPositions and v.ButtonPositions[tostring(p)]

	if v7 then
		return Vector2.new(v7.X or 0, v7.Y or 0)
	end

	return Vector2.new(0, 0)
end

local function stringToKeyCode(p)
	local success, result = pcall(function()
		return Enum.KeyCode[p]
	end)
	return if success and result then result else nil
end

local v7 = { "ButtonL2", "ButtonL1", "ButtonR1", "ButtonR2", "ButtonB" }
local v8 = { "ButtonL1", "ButtonR1" }

function SettingsState.GetInputModeSetting()
	local inputMode = v.InputMode

	if inputMode == "Keyboard" or inputMode == "Controller" then
		return inputMode
	end

	return "Auto"
end

function SettingsState.IsConsoleLikeDevice()
	local success, result = pcall(function()
		return UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled
	end)

	return success and result == true
end

function SettingsState.IsControllerMode()
	local inputModeSetting = SettingsState.GetInputModeSetting()

	if inputModeSetting == "Controller" then
		return true
	elseif inputModeSetting == "Keyboard" then
		return false
	end

	return SettingsState.IsConsoleLikeDevice()
end

function SettingsState.HasChosenInputMode(): boolean
	return v.InputModeChosen == true
end

function SettingsState.IsVibrationEnabled(): boolean
	return v.VibrationEnabled ~= false
end

function SettingsState.GetControllerType()
	local controllerType = v.ControllerType

	if controllerType == "Guitar" or controllerType == "Drums" then
		return controllerType
	end

	return "Gamepad"
end

function SettingsState.GetControllerGlyphStyle()
	local controllerGlyphStyle = v.ControllerGlyphStyle

	if controllerGlyphStyle == "Xbox" or controllerGlyphStyle == "PlayStation" then
		return controllerGlyphStyle
	end

	return "Auto"
end

function SettingsState.KeybindField(p)
	if SettingsState.IsControllerMode() and p ~= "KeybindVibratoRhythm" then
		return p .. "Pad"
	end

	return p
end

local function keyListFor(p, p2, p3, p4)
	local result = {}

	if SettingsState.IsControllerMode() then
		local v9 = v[p]

		if type(v9) ~= "table" or #v9 == 0 then
			v9 = p3
		end

		for i, v10 in ipairs(v9) do
			local success, result2 = pcall(function()
				return Enum.KeyCode[v10]
			end)
			local v11 = success and result2 or nil

			if not v11 then
				local v12 = p3[i]
				local success2, result3 = pcall(function()
					return Enum.KeyCode[v12]
				end)

				v11 = success2 and result3 or nil or Enum.KeyCode.ButtonA
			end

			result[i] = v11
		end

		return result
	end

	for i, v9 in ipairs(v[p2] or {}) do
		local success, result2 = pcall(function()
			return Enum.KeyCode[v9]
		end)

		result[i] = success and result2 or nil or p4
	end

	return result
end

function SettingsState.GetKeybindFiveKey()
	return keyListFor("KeybindFiveKeyPad", "KeybindFiveKey", v7, Enum.KeyCode.X)
end

function SettingsState.GetKeybindTwoKey()
	return keyListFor("KeybindTwoKeyPad", "KeybindTwoKey", v8, Enum.KeyCode.F)
end

function SettingsState.GetKeybindFirstN(p)
	local keybindFiveKey = SettingsState.GetKeybindFiveKey()
	local keybindFirstN = {}

	for i = 1, math.min(p, #keybindFiveKey) do
		keybindFirstN[i] = keybindFiveKey[i]
	end

	return keybindFirstN
end

function SettingsState.GetDoublePedalKeyNormal()
	if SettingsState.IsControllerMode() then
		local keybindDoublePedalNormalPad = v.KeybindDoublePedalNormalPad
		local success, result = pcall(function()
			return Enum.KeyCode[keybindDoublePedalNormalPad]
		end)

		return success and result or nil or Enum.KeyCode.ButtonA
	else
		local keybindDoublePedalNormal = v.KeybindDoublePedalNormal
		local success, result = pcall(function()
			return Enum.KeyCode[keybindDoublePedalNormal]
		end)

		return success and result or nil or Enum.KeyCode.Z
	end
end

function SettingsState.GetDoublePedalKeyFlipped()
	if SettingsState.IsControllerMode() then
		local keybindDoublePedalFlippedPad = v.KeybindDoublePedalFlippedPad
		local success, result = pcall(function()
			return Enum.KeyCode[keybindDoublePedalFlippedPad]
		end)

		return success and result or nil or Enum.KeyCode.ButtonX
	else
		local keybindDoublePedalFlipped = v.KeybindDoublePedalFlipped
		local success, result = pcall(function()
			return Enum.KeyCode[keybindDoublePedalFlipped]
		end)

		return success and result or nil or Enum.KeyCode.M
	end
end

local v9 = { MouseButton2 = true, MouseButton3 = true }

function SettingsState.GetVibratoBindingName()
	local keybindVibratoRhythm = v.KeybindVibratoRhythm

	if type(keybindVibratoRhythm) ~= "string" then
		return "LeftControl"
	end

	if v9[keybindVibratoRhythm] then
		return keybindVibratoRhythm
	end

	if keybindVibratoRhythm == "Unknown" or keybindVibratoRhythm == "None" then
		return "LeftControl"
	end

	local success, result = pcall(function()
		return Enum.KeyCode[keybindVibratoRhythm]
	end)

	return (success and result or nil) and keybindVibratoRhythm or "LeftControl"
end

function SettingsState.IsVibratoMouseBinding(): boolean
	return v9[SettingsState.GetVibratoBindingName()] == true
end

function SettingsState.GetVibratoKeyRhythm()
	local vibratoBindingName = SettingsState.GetVibratoBindingName()

	if v9[vibratoBindingName] then
		return Enum.KeyCode.Unknown
	end

	local success, result = pcall(function()
		return Enum.KeyCode[vibratoBindingName]
	end)

	return success and result or nil or Enum.KeyCode.LeftControl
end

function SettingsState.MatchesVibratoInput(p): boolean
	local vibratoBindingName = SettingsState.GetVibratoBindingName()

	if v9[vibratoBindingName] then
		return p.UserInputType == Enum.UserInputType[vibratoBindingName]
	end

	local keyCode = p.KeyCode
	local success, result = pcall(function()
		return Enum.KeyCode[vibratoBindingName]
	end)

	return keyCode == (success and result or nil or Enum.KeyCode.LeftControl)
end

local v10 = {
	LeftControl = "CTRL",
	RightControl = "R CTRL",
	LeftShift = "SHIFT",
	RightShift = "R SHIFT",
	LeftAlt = "ALT",
	RightAlt = "R ALT",
	Space = "SPACE",
	CapsLock = "CAPS",
	Tab = "TAB",
	Backquote = "`",
	MouseButton2 = "R-CLICK",
	MouseButton3 = "M-CLICK",
	ButtonA = "A",
	ButtonB = "B",
	ButtonX = "X",
	ButtonY = "Y",
	ButtonL1 = "L1",
	ButtonR1 = "R1",
	ButtonL2 = "L2",
	ButtonR2 = "R2",
	ButtonL3 = "L3",
	ButtonR3 = "R3",
	ButtonStart = "START",
	ButtonSelect = "SELECT",
	DPadUp = "D-UP",
	DPadDown = "D-DOWN",
	DPadLeft = "D-LEFT",
	DPadRight = "D-RIGHT"
}

function SettingsState.GetVibratoKeyLabel()
	local vibratoBindingName = SettingsState.GetVibratoBindingName()
	return v10[vibratoBindingName] or string.upper(vibratoBindingName)
end

local v11 = { MouseButton2 = "Right Click", MouseButton3 = "Middle Click" }

function SettingsState.GetVibratoBindingDisplay()
	local vibratoBindingName = SettingsState.GetVibratoBindingName()

	if v11[vibratoBindingName] then
		return v11[vibratoBindingName]
	end

	if string.sub(vibratoBindingName, 1, 6) == "Button" or string.sub(vibratoBindingName, 1, 4) == "DPad" then
		return "Pad " .. (v10[vibratoBindingName] or vibratoBindingName)
	end

	return vibratoBindingName
end

function SettingsState.GetStarPowerBindingName()
	if SettingsState.IsControllerMode() then
		local keybindStarPowerPad = v.KeybindStarPowerPad

		if type(keybindStarPowerPad) == "string" then
			local success, result = pcall(function()
				return Enum.KeyCode[keybindStarPowerPad]
			end)

			if success and result and keybindStarPowerPad ~= "Unknown" and keybindStarPowerPad ~= "None" then
				return keybindStarPowerPad
			end
		end

		return "ButtonSelect"
	else
		local keybindStarPower = v.KeybindStarPower

		if type(keybindStarPower) ~= "string" then
			return "Space"
		end

		if v9[keybindStarPower] then
			return keybindStarPower
		end

		if keybindStarPower == "Unknown" or keybindStarPower == "None" then
			return "Space"
		end

		local success, result = pcall(function()
			return Enum.KeyCode[keybindStarPower]
		end)

		return (success and result or nil) and keybindStarPower or "Space"
	end
end

function SettingsState.IsStarPowerMouseBinding(): boolean
	return v9[SettingsState.GetStarPowerBindingName()] == true
end

function SettingsState.GetStarPowerKey()
	local starPowerBindingName = SettingsState.GetStarPowerBindingName()

	if v9[starPowerBindingName] then
		return Enum.KeyCode.Unknown
	end

	local success, result = pcall(function()
		return Enum.KeyCode[starPowerBindingName]
	end)

	return success and result or nil or Enum.KeyCode.Space
end

function SettingsState.MatchesStarPowerInput(p): boolean
	local starPowerBindingName = SettingsState.GetStarPowerBindingName()

	if not (p.KeyCode ~= SettingsState.StarPowerAltKey and p.KeyCode ~= Enum.KeyCode.ButtonSelect) then
		return true
	end

	if v9[starPowerBindingName] then
		return p.UserInputType == Enum.UserInputType[starPowerBindingName]
	end

	local keyCode = p.KeyCode
	local success, result = pcall(function()
		return Enum.KeyCode[starPowerBindingName]
	end)

	return keyCode == (success and result or nil or Enum.KeyCode.Space)
end

SettingsState.StarPowerAltKey = Enum.KeyCode.H

function SettingsState.GetStarPowerHintText()
	local starPowerKeyLabel = SettingsState.GetStarPowerKeyLabel()

	if SettingsState.IsControllerMode() then
		return starPowerKeyLabel
	end

	if starPowerKeyLabel == "H" then
		return "H"
	end

	return starPowerKeyLabel .. " / H"
end

function SettingsState.GetStarPowerKeyLabel()
	local starPowerBindingName = SettingsState.GetStarPowerBindingName()

	if string.sub(starPowerBindingName, 1, 6) ~= "Button" and string.sub(starPowerBindingName, 1, 4) ~= "DPad" then
		return v10[starPowerBindingName] or string.upper(starPowerBindingName)
	end

	local success, result = pcall(function()
		local ControllerGlyphs = require(script.Parent.ControllerGlyphs)
		return ControllerGlyphs.LabelFromName(starPowerBindingName)
	end)

	if success and result then
		return result
	end

	return v10[starPowerBindingName] or string.upper(starPowerBindingName)
end

function SettingsState.GetStarPowerBindingDisplay()
	local starPowerBindingName = SettingsState.GetStarPowerBindingName()

	if v11[starPowerBindingName] then
		return v11[starPowerBindingName]
	end

	if string.sub(starPowerBindingName, 1, 6) == "Button" or string.sub(starPowerBindingName, 1, 4) == "DPad" then
		return "Pad " .. (v10[starPowerBindingName] or starPowerBindingName)
	end

	return starPowerBindingName
end

function SettingsState.SetField(value, p, p2)
	local v12 = string.sub(value, 1, 7) == "Keybind" or p2

	v = table.clone(v)
	v[value] = p
	notify()

	if v3[value] then
		task.cancel(v3[value])
		v3[value] = nil
	end

	if v12 then
		v4[value] = nil
		SetSetting:FireServer("SetField", value, p)
	else
		v4[value] = p
		v3[value] = task.delay(0.3, function()
			v3[value] = nil
			local v13 = v4[value]
			v4[value] = nil

			if v13 ~= nil then
				SetSetting:FireServer("SetField", value, v13)
			end
		end)
	end
end

function SettingsState.HasPending(p): boolean
	return v4[p] ~= nil
end

function SettingsState.SetFields(items)
	for k, v12 in pairs(v3) do
		if items[k] == nil then
			continue
		end

		task.cancel(v12)
		v3[k] = nil
	end

	for k in pairs(items) do
		v4[k] = nil
	end

	v = table.clone(v)

	for k, item in pairs(items) do
		v[k] = item
	end

	notify()
	SetSetting:FireServer("SetFields", items)
end

function SettingsState.FlushPending()
	for k, v12 in pairs(v3) do
		task.cancel(v12)
		v3[k] = nil
		local v13 = v4[k]
		v4[k] = nil

		if v13 ~= nil then
			SetSetting:FireServer("SetField", k, v13)
		end
	end
end

local RunService2 = game:GetService("RunService")

if RunService2:IsClient() then
	local UserInputService2 = game:GetService("UserInputService")
	UserInputService2.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			SettingsState.FlushPending()
		end
	end)
end

function SettingsState.SetButtonWidthMultiplier(value)
	local v12 = math.clamp(value, 0.5, 2.5)
	SettingsState.SetField("ButtonWidthMultiplier", v12)

	if SettingsState.GetButtonSizeLinked() then
		SettingsState.SetField("ButtonHeightMultiplier", v12)
	end
end

function SettingsState.SetButtonHeightMultiplier(value)
	local v12 = math.clamp(value, 0.5, 2.5)
	SettingsState.SetField("ButtonHeightMultiplier", v12)

	if SettingsState.GetButtonSizeLinked() then
		SettingsState.SetField("ButtonWidthMultiplier", v12)
	end
end

function SettingsState.SetButtonSizeLinked(p)
	local v12 = p and true or false
	SettingsState.SetField("ButtonSizeLinked", v12, true)

	if v12 then
		local buttonWidthMultiplier = SettingsState.GetButtonWidthMultiplier()
		SettingsState.SetFields({
			ButtonWidthMultiplier = buttonWidthMultiplier,
			ButtonHeightMultiplier = buttonWidthMultiplier
		})
	end
end

function SettingsState.SetButtonGroupOffset(value, value2)
	local v12 = math.clamp(value, -400, 400)
	local v13 = math.clamp(value2, -300, 300)
	SettingsState.SetField("ButtonGroupOffsetX", v12)
	SettingsState.SetField("ButtonGroupOffsetY", v13)
end

function SettingsState.SetButtonPositionOffset(p, p2)
	local clone = table.clone(v.ButtonPositions or {})
	clone[tostring(p)] = { X = p2.X, Y = p2.Y }
	SettingsState.SetField("ButtonPositions", clone)
end

function SettingsState.SetRhythmShape(p)
	if not RhythmCustomizationConfig.IsValidShape(p) then
		return
	end

	SettingsState.SetField("RhythmShape", p, true)

	if v.RhythmThemePreset ~= "Custom" then
		SettingsState.SetField("RhythmThemePreset", "Custom", true)
	end
end

function SettingsState.SetRhythmLaneColor(p, p2, p3, p4)
	if not RhythmCustomizationConfig.IsValidLaneCount(p) then
		return
	end

	local clone = table.clone(v.RhythmLaneColors or {})
	local v12 = tostring(p)
	local v13 = {}

	for i = 1, p do
		local v14

		if clone[v12] then
			v14 = clone[v12][i] or false
		else
			v14 = false
		end

		v13[i] = v14
	end

	local clone2 = v13[p2] and v13[p2] ~= false and table.clone(v13[p2]) or {}
	clone2[p3] = RhythmCustomizationConfig.SerializeColor(p4)
	v13[p2] = clone2
	clone[v12] = v13

	SettingsState.SetField("RhythmLaneColors", clone, true)

	if v.RhythmThemePreset ~= "Custom" then
		SettingsState.SetField("RhythmThemePreset", "Custom", true)
	end
end

function SettingsState.SetRhythmLaneColorSet(p, p2, p3)
	if not RhythmCustomizationConfig.IsValidLaneCount(p) then
		return
	end

	local clone = table.clone(v.RhythmLaneColors or {})
	local v12 = tostring(p)
	local v13 = {}

	for i = 1, p do
		local v14

		if clone[v12] then
			v14 = clone[v12][i] or false
		else
			v14 = false
		end

		v13[i] = v14
	end

	local v14 = {}

	for _, colorField in ipairs(RhythmCustomizationConfig.ColorFields) do
		if p3[colorField] then
			v14[colorField] = RhythmCustomizationConfig.SerializeColor(p3[colorField])
		end
	end

	v13[p2] = v14
	clone[v12] = v13

	SettingsState.SetField("RhythmLaneColors", clone, true)
end

function SettingsState.SetRhythmLaneColorsForBucket(p, list)
	if not RhythmCustomizationConfig.IsValidLaneCount(p) then
		return
	end

	local clone = table.clone(v.RhythmLaneColors or {})
	local v12 = {}

	for i = 1, p do
		local item = list[i]

		if item then
			local v13 = {}

			for _, colorField in ipairs(RhythmCustomizationConfig.ColorFields) do
				if item[colorField] then
					v13[colorField] = RhythmCustomizationConfig.SerializeColor(item[colorField])
				end
			end

			v12[i] = v13
		else
			v12[i] = false
		end
	end

	clone[tostring(p)] = v12
	SettingsState.SetFields({ RhythmLaneColors = clone })
end

function SettingsState.SetRhythmJudgmentColor(p, p2)
	if not RhythmCustomizationConfig.IsValidJudgmentType(p) then
		return
	end

	local clone = table.clone(v.RhythmJudgmentColors or {})
	clone[p] = RhythmCustomizationConfig.SerializeColor(p2)
	SettingsState.SetField("RhythmJudgmentColors", clone, true)

	if v.RhythmThemePreset ~= "Custom" then
		SettingsState.SetField("RhythmThemePreset", "Custom", true)
	end
end

function SettingsState.SetRhythmJudgmentColors(p)
	local rhythmJudgmentColors = {}

	for _, judgmentType in ipairs(RhythmCustomizationConfig.JudgmentTypes) do
		if p[judgmentType] then
			rhythmJudgmentColors[judgmentType] = RhythmCustomizationConfig.SerializeColor(p[judgmentType])
		end
	end

	SettingsState.SetFields({ RhythmJudgmentColors = rhythmJudgmentColors })
end

function SettingsState.SetRhythmThemePreset(p)
	if not RhythmCustomizationConfig.IsValidThemePresetName(p) then
		return
	end

	SettingsState.SetField("RhythmThemePreset", p, true)
end

function SettingsState.ResetRhythmLaneSet(p)
	SetSetting:FireServer("ResetRhythmLaneSet", p)
	v = table.clone(v)
	local clone = table.clone(v.RhythmLaneColors or {})
	clone[tostring(p)] = nil
	v.RhythmLaneColors = clone
	notify()
end

function SettingsState.ResetRhythmJudgment()
	SetSetting:FireServer("ResetRhythmJudgment")
	v = table.clone(v)
	v.RhythmJudgmentColors = {}
	notify()
end

function SettingsState.ResetRhythmShape()
	SetSetting:FireServer("ResetRhythmShape")
	v = table.clone(v)
	v.RhythmShape = RhythmCustomizationConfig.DefaultShape
	notify()
end

function SettingsState.ResetRhythmAll()
	SetSetting:FireServer("ResetRhythmAll")
	v = table.clone(v)
	v.RhythmShape = RhythmCustomizationConfig.DefaultShape
	v.RhythmLaneColors = {}
	v.RhythmJudgmentColors = {}
	v.RhythmThemePreset = "Default"
	notify()
end

function SettingsState.ResetLayout()
	for k, v12 in pairs(v3) do
		task.cancel(v12)
		v3[k] = nil
	end

	table.clear(v4)

	SetSetting:FireServer("ResetLayout")
	v = table.clone(v)
	local UserInputService2 = game:GetService("UserInputService")
	local v12 = UserInputService2.TouchEnabled and not UserInputService2.KeyboardEnabled
	v.ButtonSizeMultiplier = v12 and 1.36 or 1
	v.ButtonWidthMultiplier = nil
	v.ButtonHeightMultiplier = nil
	v.ButtonSizeLinked = nil
	v.ButtonGroupOffsetX = nil
	v.ButtonGroupOffsetY = v12 and 66 or nil
	v.ButtonSpacingExtra = v12 and 26 or 0
	v.ButtonOpacity = 0.55
	v.ButtonPositions = {}
	notify()
end

return SettingsState