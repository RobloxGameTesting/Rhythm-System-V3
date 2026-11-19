local AudioSpatialMode = {}

local Inverse = Enum.RollOffMode.Inverse

local Linear = Enum.RollOffMode.Linear

local mode = "3D"
local v = {}

function AudioSpatialMode.GetMode()
	return mode
end

function AudioSpatialMode.IsMono(): boolean
	return mode == "Mono"
end

function AudioSpatialMode.OnChanged(p)
	table.insert(v, p)
end

local function notify()
	for _, callback in ipairs(v) do
		local success, result = pcall(callback, mode)

		if not success then
			warn("[AudioSpatialMode] Listener error:", result)
		end
	end
end

function AudioSpatialMode:ApplyToSound()
	if not (self and self:IsA("Sound")) then
		return
	end

	if mode == "Mono" then
		self.EmitterSize = 10000
		self.RollOffMinDistance = 100000
		self.RollOffMaxDistance = 200000
		self.RollOffMode = Linear
	else
		self.EmitterSize = 10
		self.RollOffMinDistance = 10
		self.RollOffMaxDistance = 10000
		self.RollOffMode = Inverse
	end
end

function AudioSpatialMode.SetMode(p)
	if p ~= "3D" and p ~= "Mono" or p == mode then
		return
	end

	mode = p
	notify()
end

function AudioSpatialMode.Toggle()
	AudioSpatialMode.SetMode(mode == "3D" and "Mono" or "3D")
	return mode
end

AudioSpatialMode.MODE_3D = "3D"
AudioSpatialMode.MODE_MONO = "Mono"

return AudioSpatialMode