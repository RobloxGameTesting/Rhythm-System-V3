local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DrumKeybindRules = require(ReplicatedStorage.Modules.DrumKeybindRules)

local KeybindShare = {}
KeybindShare.RHYTHM_ATTRIBUTE = "RhythmKeybinds"
KeybindShare.DRUM_ATTRIBUTE = "DrumKeybinds"
KeybindShare.RHYTHM_PAD_ATTRIBUTE = "RhythmKeybindsPad"
KeybindShare.INPUT_MODE_ATTRIBUTE = "SharedInputMode"
KeybindShare.RhythmDefaults = {
	Five = { "X", "C", "V", "B", "N" },
	Two = { "X", "C" },
	Pedal = "Z",
	PedalFlip = "M",
	Vibrato = "LeftControl",
	StarPower = "Space"
}

KeybindShare.RhythmDefaultsPad = {
	Five = { "ButtonL2", "ButtonL1", "ButtonR1", "ButtonR2", "ButtonB" },
	Two = { "ButtonL1", "ButtonR1" },
	Pedal = "ButtonA",
	PedalFlip = "ButtonX",
	Vibrato = "LeftControl",
	StarPower = "ButtonSelect"
}

KeybindShare.DrumLaneLabels = {
	"High Crash",
	"Splash",
	"Medium Crash",
	"Foot Hi-Hat 1",
	"Foot Hi-Hat 2",
	"High Tom 1",
	"High Tom 2",
	"Mid Tom 1",
	"Mid Tom 2",
	"Ride",
	"Ride Bell",
	"Open Hi-Hat 1",
	"Open Hi-Hat 2",
	"Snare 1",
	"Snare 2",
	"Side Stick",
	"Bass Drum 1",
	"Bass Drum 2",
	"Floor Tom 1",
	"Floor Tom 2",
	"China",
	"Cowbell"
}

function KeybindShare.CopyRhythmDefaults()
	local rhythmDefaults = KeybindShare.RhythmDefaults
	return {
		Five = table.clone(rhythmDefaults.Five),
		Two = table.clone(rhythmDefaults.Two),
		Pedal = rhythmDefaults.Pedal,
		PedalFlip = rhythmDefaults.PedalFlip,
		Vibrato = rhythmDefaults.Vibrato,
		StarPower = rhythmDefaults.StarPower
	}
end

function KeybindShare.CopyRhythmDefaultsPad()
	local rhythmDefaultsPad = KeybindShare.RhythmDefaultsPad
	return {
		Five = table.clone(rhythmDefaultsPad.Five),
		Two = table.clone(rhythmDefaultsPad.Two),
		Pedal = rhythmDefaultsPad.Pedal,
		PedalFlip = rhythmDefaultsPad.PedalFlip,
		Vibrato = rhythmDefaultsPad.Vibrato,
		StarPower = rhythmDefaultsPad.StarPower
	}
end

local function isKeyName(value, p) -- 3 equivalent calls inferred from this helper
	if typeof(value) ~= "string" or #value == 0 or #value > 32 or value == "Unknown" or value == "None" then
		return false
	end

	if p and (value == "MouseButton2" or value == "MouseButton3") then
		return true
	end

	local success, result = pcall(function()
		return Enum.KeyCode[value]
	end)

	return success and result ~= nil
end

KeybindShare.IsKeyName = isKeyName

function KeybindShare.NormalizeRhythm(data)
	if typeof(data) ~= "table" then
		return nil
	end

	local rhythmDefaults = KeybindShare.RhythmDefaults
	local v = { Five = {}, Two = {} }

	for _, v2 in ipairs({
		{ "Five", 5 },
		{ "Two", 2 }
	}) do
		local v3 = v2[1]
		local v4 = v2[2]
		local v5 = data[v3]

		if typeof(v5) ~= "table" then
			return nil
		end

		for i = 1, v4 do
			local v6 = v5[i]

			if v6 == nil then
				v6 = rhythmDefaults[v3][i]
			end

			if not isKeyName(v6, false) then -- inferred equivalent call
				return nil
			end

			v[v3][i] = v6
		end
	end

	if not isKeyName(data.Pedal, false) then -- inferred equivalent call
		return nil
	end

	if not isKeyName(data.PedalFlip, false) then -- inferred equivalent call
		return nil
	end

	if not (isKeyName(data.Vibrato, true) and isKeyName(data.StarPower, true)) then
		return nil
	end

	v.Pedal = data.Pedal
	v.PedalFlip = data.PedalFlip
	v.Vibrato = data.Vibrato
	v.StarPower = data.StarPower
	return v
end

function KeybindShare.EncodeRhythm(data)
	local v = {
		Five = data.KeybindFiveKey,
		Two = data.KeybindTwoKey,
		Pedal = data.KeybindDoublePedalNormal,
		PedalFlip = data.KeybindDoublePedalFlipped,
		Vibrato = data.KeybindVibratoRhythm,
		StarPower = data.KeybindStarPower
	}

	return HttpService:JSONEncode(KeybindShare.NormalizeRhythm(v) or KeybindShare.CopyRhythmDefaults())
end

function KeybindShare.EncodeRhythmPad(data)
	local v = {
		Five = data.KeybindFiveKeyPad,
		Two = data.KeybindTwoKeyPad,
		Pedal = data.KeybindDoublePedalNormalPad,
		PedalFlip = data.KeybindDoublePedalFlippedPad,
		Vibrato = data.KeybindVibratoRhythm,
		StarPower = data.KeybindStarPowerPad
	}

	return HttpService:JSONEncode(KeybindShare.NormalizeRhythm(v) or KeybindShare.CopyRhythmDefaultsPad())
end

function KeybindShare.DecodeRhythm(json)
	if typeof(json) ~= "string" then
		return nil
	end

	local success, result = pcall(function()
		return HttpService:JSONDecode(json)
	end)

	if success then
		return KeybindShare.NormalizeRhythm(result)
	end

	return nil
end

function KeybindShare.DecodeDrum(json)
	if typeof(json) ~= "string" then
		return nil
	end

	local success, result = pcall(function()
		return HttpService:JSONDecode(json)
	end)

	if not (success and DrumKeybindRules.Validate(result)) then
		return nil
	end

	local result2 = {}

	for i = 1, DrumKeybindRules.LANE_COUNT do
		result2[i] = result[i]
	end

	return result2
end

function KeybindShare.RhythmEqual(data, data2): boolean
	if not (data and data2) then
		return false
	end

	for i = 1, 5 do
		if data.Five[i] ~= data2.Five[i] then
			return false
		end
	end

	if not (data.Two[1] == data2.Two[1] and data.Two[2] == data2.Two[2]) then
		return false
	end

	return data.Pedal == data2.Pedal
		and data.PedalFlip == data2.PedalFlip
		and data.Vibrato == data2.Vibrato
		and data.StarPower == data2.StarPower
end

function KeybindShare.DrumEqual(list, list2): boolean
	if not (list and list2) then
		return false
	end

	for i = 1, DrumKeybindRules.LANE_COUNT do
		if list[i] ~= list2[i] then
			return false
		end
	end

	return true
end

local v = {
	LeftControl = "L Ctrl",
	RightControl = "R Ctrl",
	LeftShift = "L Shift",
	RightShift = "R Shift",
	LeftAlt = "L Alt",
	RightAlt = "R Alt",
	Space = "Space",
	CapsLock = "Caps",
	MouseButton2 = "R-Click",
	MouseButton3 = "M-Click"
}

function KeybindShare.DisplayKey(value)
	if typeof(value) ~= "string" then
		return "?"
	end

	if v[value] then
		return v[value]
	end

	if string.sub(value, 1, 6) ~= "Button" and string.sub(value, 1, 4) ~= "DPad" then
		return DrumKeybindRules.DisplayName(value)
	end

	local success, result = pcall(function()
		local ControllerGlyphs = require(ReplicatedStorage.Modules.ControllerGlyphs)
		return ControllerGlyphs.LabelFromName(value)
	end)
	return if success and result then result else value
end

return KeybindShare