local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local AudioSpatialMode = require(ReplicatedStorage.Modules:WaitForChild("AudioSpatialMode"))

local v = {
	Climbing = true,
	Running = true,
	Jumping = true,
	Landing = true,
	Splash = true,
	Swimming = true,
	FreeFalling = true,
	GettingUp = true
}

local object = setmetatable({}, { __mode = "k" })

local function shouldSkip(sound): boolean -- 1 equivalent call inferred from this helper
	return sound:GetAttribute("AlwaysSpatial3D") == true or v[sound.Name] == true
end

local function track(sound) -- 2 equivalent calls inferred from this helper
	if not sound:IsA("Sound") or shouldSkip(sound) then -- inferred equivalent call
		return
	end

	object[sound] = true
	AudioSpatialMode.ApplyToSound(sound)
end

for _, sound in ipairs(Workspace:GetDescendants()) do
	if sound:IsA("Sound") then
		track(sound) -- inferred equivalent call
	end
end

Workspace.DescendantAdded:Connect(function(sound)
	if sound:IsA("Sound") then
		track(sound) -- inferred equivalent call
	end
end)

AudioSpatialMode.OnChanged(function()
	for k in pairs(object) do
		if k.Parent then
			AudioSpatialMode.ApplyToSound(k)
		end
	end
end)