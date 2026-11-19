local FreePlaySyncState = {}
FreePlaySyncState.MIN_DELAY_MS = 80
FreePlaySyncState.MAX_DELAY_MS = 300
FreePlaySyncState.DEFAULT_DELAY_MS = 150
FreePlaySyncState.DELAY_STEP_MS = 5
local v = false
local delayMs = FreePlaySyncState.DEFAULT_DELAY_MS
local bindableEvent = Instance.new("BindableEvent")

local function fire() -- 2 equivalent calls inferred from this helper
	bindableEvent:Fire(v, delayMs)
end

function FreePlaySyncState.IsEnabled()
	return v
end

function FreePlaySyncState.GetDelayMs()
	return delayMs
end

function FreePlaySyncState.GetDelaySeconds()
	return delayMs / 1000
end

function FreePlaySyncState.SetEnabled(p)
	local v2 = p == true

	if v == v2 then
		return
	end

	v = v2
	fire() -- inferred equivalent call
end

function FreePlaySyncState.SetDelayMs(value)
	if typeof(value) ~= "number" or value ~= value then
		return delayMs
	end

	local DELAY_STEP_MS = FreePlaySyncState.DELAY_STEP_MS
	local v2 = math.clamp(
		math.round(value / DELAY_STEP_MS) * DELAY_STEP_MS,
		FreePlaySyncState.MIN_DELAY_MS,
		FreePlaySyncState.MAX_DELAY_MS
	)

	if v2 == delayMs then
		return delayMs
	end

	delayMs = v2
	fire() -- inferred equivalent call
	return delayMs
end

function FreePlaySyncState.OnChanged(onEvent)
	return bindableEvent.Event:Connect(onEvent)
end

return FreePlaySyncState