local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SongConfig = require(ReplicatedStorage.Modules.SongConfig)

local FreePlayAutoVolume = {
	ATTRIBUTE = "FreePlayAutoVolume",
	AMP_BASE_OUTPUT = 0.7,
	TARGET_BOOST = 1.2,
	MIN_RATIO = 0.5,
	MAX_RATIO = 2,
	REFERENCE = {
		GuitarRhythm = 1.5,
		GuitarLead = 1,
		Bass = 1,
		Drum = 2,
		Keyboard = 1,
		Piano = 1
	}
}

function FreePlayAutoVolume.GetLevel(p, p2)
	local v = FreePlayAutoVolume.REFERENCE[p2]

	if not v then
		return nil
	end

	local songs = SongConfig.Songs
	local v2 = songs and songs[p]

	if typeof(v2) ~= "table" then
		return nil
	end

	local defaultVolumes = v2.DefaultVolumes
	local v3

	if typeof(defaultVolumes) == "table" then
		v3 = defaultVolumes[p2] or nil
	end

	if typeof(v3) ~= "number" or v3 <= 0 then
		v3 = v
	end

	return math.clamp(v3 / v, FreePlayAutoVolume.MIN_RATIO, FreePlayAutoVolume.MAX_RATIO) * FreePlayAutoVolume.TARGET_BOOST
end

function FreePlayAutoVolume.ToGroupVolume(p, p2)
	if p2 then
		return FreePlayAutoVolume.AMP_BASE_OUTPUT * p
	end

	return p
end

return FreePlayAutoVolume