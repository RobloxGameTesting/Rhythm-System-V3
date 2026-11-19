local NewbieModeState = {}

local v = {
	Enabled = false,
	NoteSpeed = nil,
	NoteDensity = 0,
	PatternComplexity = 0,
	LaneCount = nil
}

local clone = table.clone(v)
local v2 = {}
local v3 = {}
local v4 = {}

local function notify()
	for _, callback in ipairs(v2) do
		local success, result = pcall(callback, clone)

		if not success then
			warn("[NewbieModeState] Error pada listener:", result)
		end
	end
end

local function notifyStructural()
	for _, callback in ipairs(v3) do
		local success, result = pcall(callback, clone)

		if not success then
			warn("[NewbieModeState] Error pada structural listener:", result)
		end
	end
end

local function recomputeEnabled() -- 6 equivalent calls inferred from this helper
	clone.Enabled = clone.NoteDensity > 0 or clone.PatternComplexity > 0 or clone.LaneCount ~= nil
end

function NewbieModeState.OnChanged(p)
	table.insert(v2, p)
end

function NewbieModeState.OnStructuralChanged(p)
	table.insert(v3, p)
end

function NewbieModeState.OnApplyRequested(p)
	table.insert(v4, p)
end

function NewbieModeState.RequestApply()
	for _, callback in ipairs(v4) do
		local success, result = pcall(callback)

		if not success then
			warn("[NewbieModeState] Error pada apply listener:", result)
		end
	end
end

function NewbieModeState.IsEnabled(): boolean
	return clone.Enabled == true
end

function NewbieModeState.GetConfig()
	return table.clone(clone)
end

function NewbieModeState.SetNoteSpeed(noteSpeed)
	clone.NoteSpeed = noteSpeed
	notify()
end

function NewbieModeState.SetNoteDensity(p)
	clone.NoteDensity = math.clamp(math.floor((tonumber(p) or 0) + 0.5), 0, 10)
	recomputeEnabled() -- inferred equivalent call
	notify()
	notifyStructural()
end

function NewbieModeState.SetPatternComplexity(p)
	clone.PatternComplexity = math.clamp(math.floor((tonumber(p) or 0) + 0.5), 0, 10)
	recomputeEnabled() -- inferred equivalent call
	notify()
	notifyStructural()
end

function NewbieModeState.SetLaneCount(laneCount)
	clone.LaneCount = laneCount
	recomputeEnabled() -- inferred equivalent call
	notify()
	notifyStructural()
end

function NewbieModeState.ApplyPreset()
	clone.NoteDensity = 5
	clone.PatternComplexity = 5
	recomputeEnabled() -- inferred equivalent call
	notify()
	notifyStructural()
end

function NewbieModeState.ClearPreset()
	clone.NoteDensity = 0
	clone.PatternComplexity = 0
	recomputeEnabled() -- inferred equivalent call
	notify()
	notifyStructural()
end

function NewbieModeState.SetAll(data)
	clone.NoteSpeed = data.NoteSpeed
	clone.NoteDensity = math.clamp(math.floor((tonumber(data.NoteDensity) or 0) + 0.5), 0, 10)
	clone.PatternComplexity = math.clamp(math.floor((tonumber(data.PatternComplexity) or 0) + 0.5), 0, 10)
	clone.LaneCount = data.LaneCount
	recomputeEnabled() -- inferred equivalent call
	notify()
	notifyStructural()
end

function NewbieModeState.Disable()
	clone = table.clone(v)
	notify()
	notifyStructural()
end

function NewbieModeState.GetNoteSpeedOverride()
	return clone.NoteSpeed
end

NewbieModeState.Presets = {
	{ Label = "Medium", NoteSpeed = 0.85, Density = 3, Complexity = 3 },
	{ Label = "Easy", NoteSpeed = 0.85, Density = 6, Complexity = 6 },
	{ Label = "Baby", NoteSpeed = 0.55, Density = 9, Complexity = 9 }
}

local v5 = { Label = "Natural", NoteSpeed = nil, Density = 0, Complexity = 0 }

function NewbieModeState.GetMatchingPresetName()
	if
		clone.NoteSpeed == v5.NoteSpeed
		and (clone.NoteDensity or 0) == v5.Density
		and (clone.PatternComplexity or 0) == v5.Complexity
	then
		return v5.Label
	end

	for _, preset in ipairs(NewbieModeState.Presets) do
		if
			clone.NoteSpeed == preset.NoteSpeed
			and (clone.NoteDensity or 0) == preset.Density
			and (clone.PatternComplexity or 0) == preset.Complexity
		then
			return preset.Label
		end
	end

	return nil
end

function NewbieModeState.ApplyPresetByName(p): boolean
	local v6 = nil

	if p == v5.Label then
		v6 = v5
	else
		for _, preset in ipairs(NewbieModeState.Presets) do
			if preset.Label == p then
				v6 = preset
				break
			end
		end
	end

	if not v6 then
		return false
	end

	NewbieModeState.SetAll({
		NoteSpeed = v6.NoteSpeed,
		NoteDensity = v6.Density,
		PatternComplexity = v6.Complexity,
		LaneCount = clone.LaneCount
	})

	return true
end

return NewbieModeState