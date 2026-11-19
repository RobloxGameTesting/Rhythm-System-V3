local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModeManager = {}
ModeManager.Rhythm = "Rhythm"
ModeManager.FreePlay = "FreePlay"
local mode = ModeManager.Rhythm

local v = {}

local function notifyChanged(mode2)
	for _, callback in ipairs(v) do
		local success, result = pcall(callback, mode2)

		if not success then
			warn("[ModeManager] Error pada change listener:", result)
		end
	end
end

local function setMode(p) -- 4 equivalent calls inferred from this helper
	if p == mode then
		return
	end

	mode = p
	notifyChanged(mode)
end

function ModeManager.GetMode()
	return mode
end

function ModeManager.IsFreePlay(): boolean
	return mode == ModeManager.FreePlay
end

function ModeManager.IsRhythm(): boolean
	return mode == ModeManager.Rhythm
end

function ModeManager.Toggle()
	setMode(mode == ModeManager.Rhythm and ModeManager.FreePlay or ModeManager.Rhythm) -- inferred equivalent call
	return mode
end

function ModeManager.SetMode(p)
	if p ~= ModeManager.Rhythm and p ~= ModeManager.FreePlay then
		warn("[ModeManager] SetMode dipanggil dengan mode tidak valid:", (tostring(p)))
		return
	end

	setMode(p) -- inferred equivalent call
end

function ModeManager.SetRhythm()
	setMode(ModeManager.Rhythm) -- inferred equivalent call
end

function ModeManager.SetFreePlay()
	setMode(ModeManager.FreePlay) -- inferred equivalent call
end

function ModeManager.OnChanged(p)
	table.insert(v, p)
end

ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InstrumentHUDUpdate").OnClientEvent:Connect(function(p, _, _)
	if p then
		ModeManager.SetRhythm()
	end
end)

return ModeManager