local v = {
	FirstPersonFOV = 90,
	IsFirstPerson = false,
	IsDrumFirstPersonGoPro = false,
	DrumGoProHeadDelta = CFrame.new(),
	DrumCameraShakeOffset = Vector3.new(0, 0, 0),
	IsCinematicActive = false
}

local v2 = 0

local v3 = {}
local SessionCameraSettings = {}

function SessionCameraSettings.OnChanged(p)
	table.insert(v3, p)
end

local function notify()
	for _, callback in ipairs(v3) do
		local success, result = pcall(callback, v)

		if not success then
			warn("[SessionCameraSettings] Error pada listener:", result)
		end
	end
end

function SessionCameraSettings.GetFirstPersonFOV()
	return v.FirstPersonFOV
end

local RunService = game:GetService("RunService")
local v4 = nil

local function getSettingsState()
	if v4 ~= nil then
		return v4 or nil
	end

	v4 = false

	if RunService:IsClient() then
		local success, result = pcall(function()
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			return require(ReplicatedStorage.Modules.SettingsState)
		end)

		if success then
			v4 = result
		end
	end

	return v4 or nil
end

function SessionCameraSettings.SetFirstPersonFOV(firstPersonFOV)
	v.FirstPersonFOV = firstPersonFOV
	notify()

	if v4 == nil then
		v4 = false

		if RunService:IsClient() then
			local success, result = pcall(function()
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				return require(ReplicatedStorage.Modules.SettingsState)
			end)

			if success then
				v4 = result
			end
		end
	end

	local v5 = v4 or nil

	if v5 then
		v5.SetFirstPersonFOVPref(firstPersonFOV)
	end
end

if RunService:IsClient() then
	task.defer(function()
		if v4 == nil then
			v4 = false

			if RunService:IsClient() then
				local success, result = pcall(function()
					local ReplicatedStorage = game:GetService("ReplicatedStorage")
					return require(ReplicatedStorage.Modules.SettingsState)
				end)

				if success then
					v4 = result
				end
			end
		end

		local v5 = v4 or nil

		if not v5 then
			return
		end

		local function applySaved() -- 1 equivalent call inferred from this helper
			local firstPersonFOVPref = v5.GetFirstPersonFOVPref()

			if
				firstPersonFOVPref
				and firstPersonFOVPref ~= v.FirstPersonFOV
				and not v5.HasPending("FirstPersonFOVPref")
			then
				v.FirstPersonFOV = firstPersonFOVPref
				notify()
			end
		end
		v5.OnChanged(applySaved)
		applySaved() -- inferred equivalent call
	end)
end

function SessionCameraSettings.GetIsFirstPerson()
	return v.IsFirstPerson
end

local v5 = {}

function SessionCameraSettings.OnFirstPersonChanged(p)
	table.insert(v5, p)
end

function SessionCameraSettings.SetIsFirstPerson(isFirstPerson)
	local v6 = v.IsFirstPerson ~= isFirstPerson
	v.IsFirstPerson = isFirstPerson

	if v6 then
		for _, callback in ipairs(v5) do
			pcall(callback, isFirstPerson)
		end
	end
end

local v6 = nil

function SessionCameraSettings.SetFPPToggleHandler(p)
	v6 = p
end

function SessionCameraSettings.RequestFPPToggle(): boolean
	if not v6 then
		return false
	end

	v6()
	return true
end

function SessionCameraSettings.GetIsMenuOpen(): boolean
	return v2 > 0
end

function SessionCameraSettings.SetMenuOpen(p)
	if p then
		v2 += 1
	else
		v2 = math.max(0, v2 - 1)
	end

	notify()
end

local v7 = 0

function SessionCameraSettings.GetIsScrollBlocked(): boolean
	return v7 > 0
end

function SessionCameraSettings.SetScrollBlocked(p)
	if p then
		v7 += 1
	else
		v7 = math.max(0, v7 - 1)
	end
end

function SessionCameraSettings.GetIsDrumFirstPersonGoPro()
	return v.IsDrumFirstPersonGoPro
end

function SessionCameraSettings.SetIsDrumFirstPersonGoPro(isDrumFirstPersonGoPro)
	v.IsDrumFirstPersonGoPro = isDrumFirstPersonGoPro
end

function SessionCameraSettings.GetDrumGoProHeadDelta()
	return v.DrumGoProHeadDelta
end

function SessionCameraSettings.SetDrumGoProHeadDelta(drumGoProHeadDelta)
	v.DrumGoProHeadDelta = drumGoProHeadDelta
end

function SessionCameraSettings.GetDrumCameraShakeOffset()
	return v.DrumCameraShakeOffset
end

function SessionCameraSettings.SetDrumCameraShakeOffset(drumCameraShakeOffset)
	v.DrumCameraShakeOffset = drumCameraShakeOffset
end

function SessionCameraSettings.GetIsCinematicActive()
	return v.IsCinematicActive
end

function SessionCameraSettings.SetIsCinematicActive(p)
	v.IsCinematicActive = p == true
end

local v8 = {}

function SessionCameraSettings.RequestDrumGlance(p, value)
	if #v8 >= 24 then
		table.remove(v8, 1)
	end

	table.insert(v8, {
		type = p,
		at = os.clock() + (value or 0)
	})
end

function SessionCameraSettings.DrainDrumGlanceRequests()
	if #v8 == 0 then
		return nil
	end

	local v9 = v8
	v8 = {}
	return v9
end

return SessionCameraSettings