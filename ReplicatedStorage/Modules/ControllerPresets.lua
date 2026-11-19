local ControllerPresets = {}

ControllerPresets.Order = { "Gamepad", "Guitar", "Drums" }

ControllerPresets.DisplayNames = { Gamepad = "Gamepad", Guitar = "Guitar", Drums = "Drum Kit" }

ControllerPresets.Descriptions = {
	Gamepad = "Standard Xbox / PlayStation pad: triggers and bumpers for lanes.",
	Guitar = "Guitar controller: colored frets A / B / Y / X + LB (orange).",
	Drums = "Drum kit (gamepad type): Kick pedal + red / yellow / blue / green pads. Remap with Quick Setup if your kit differs."
}

ControllerPresets.Data = {
	Gamepad = {
		Five = { "ButtonL2", "ButtonL1", "ButtonR1", "ButtonR2", "ButtonB" },
		Two = { "ButtonL1", "ButtonR1" },
		Pedal = "ButtonA",
		PedalFlip = "ButtonX",
		StarPower = "ButtonSelect"
	},
	Guitar = {
		Five = { "ButtonA", "ButtonB", "ButtonY", "ButtonX", "ButtonL1" },
		Two = { "ButtonA", "ButtonB" },
		Pedal = "ButtonL2",
		PedalFlip = "ButtonR2",
		StarPower = "ButtonSelect"
	},
	Drums = {
		Five = { "ButtonR1", "ButtonB", "ButtonY", "ButtonX", "ButtonA" },
		Two = { "ButtonR1", "ButtonB" },
		Pedal = "ButtonL1",
		PedalFlip = "ButtonL2",
		StarPower = "ButtonSelect"
	}
}

function ControllerPresets.IsValid(p): boolean
	return ControllerPresets.Data[p] ~= nil
end

function ControllerPresets.Apply(p, controllerType): boolean
	local v = ControllerPresets.Data[controllerType]

	if not v then
		return false
	end

	p.SetFields({
		ControllerType = controllerType,
		KeybindFiveKeyPad = table.clone(v.Five),
		KeybindTwoKeyPad = table.clone(v.Two),
		KeybindDoublePedalNormalPad = v.Pedal,
		KeybindDoublePedalFlippedPad = v.PedalFlip,
		KeybindStarPowerPad = v.StarPower
	})

	return true
end

return ControllerPresets