local FreePlayAutoMuteConfig = {}
FreePlayAutoMuteConfig.AUTO_MUTE_FADE_DURATION = 0.15
FreePlayAutoMuteConfig.NORMAL_FADE_START = 3
FreePlayAutoMuteConfig.NORMAL_FADE_DURATION = 1
FreePlayAutoMuteConfig.SUSTAIN_FACTORS = { 2, 3, 4, 5 }
FreePlayAutoMuteConfig.DEFAULT_SUSTAIN_FACTOR = 3
FreePlayAutoMuteConfig.MUTE_FADE_DURATION = FreePlayAutoMuteConfig.AUTO_MUTE_FADE_DURATION
FreePlayAutoMuteConfig.MUTE_EASING_STYLE = Enum.EasingStyle.Linear
FreePlayAutoMuteConfig.MUTE_EASING_DIRECTION = Enum.EasingDirection.Out

FreePlayAutoMuteConfig.TREMOLO_MIN_BPM = 60

FreePlayAutoMuteConfig.TREMOLO_MAX_BPM = 180
FreePlayAutoMuteConfig.TREMOLO_DEFAULT_BPM = 120
FreePlayAutoMuteConfig.TREMOLO_PICKS_PER_BEAT = 4

FreePlayAutoMuteConfig.TREMOLO_PICK_LIFETIME = 2

FreePlayAutoMuteConfig.TREMOLO_BPM_SYNC_INTERVAL = 0.1
FreePlayAutoMuteConfig.TREMOLO_KEEPALIVE_INTERVAL = 1
FreePlayAutoMuteConfig.TREMOLO_KEEPALIVE_TIMEOUT = 3.5

FreePlayAutoMuteConfig.TREMOLO_SERVER_SMOOTH_SPEED = 14

FreePlayAutoMuteConfig.TREMOLO_MAX_LANES = 8

FreePlayAutoMuteConfig.OVERLAP_MAX_VOICES = 24
FreePlayAutoMuteConfig.OVERLAP_CAP_FADE = 0.12
FreePlayAutoMuteConfig.OVERLAP_TREMOLO_PICK_FADE = 0.3

function FreePlayAutoMuteConfig.ToTremoloBpm(value)
	if type(value) == "number" and value == value and value ~= 1e999 and value ~= -1e999 then
		return (math.clamp(
			math.floor(value + 0.5),
			FreePlayAutoMuteConfig.TREMOLO_MIN_BPM,
			FreePlayAutoMuteConfig.TREMOLO_MAX_BPM
		))
	end

	return nil
end

function FreePlayAutoMuteConfig.TremoloInterval(p)
	return 60 / (p * FreePlayAutoMuteConfig.TREMOLO_PICKS_PER_BEAT)
end

function FreePlayAutoMuteConfig.ToSustainFactor(value)
	if type(value) ~= "number" then
		return nil
	end

	for _, v in ipairs(FreePlayAutoMuteConfig.SUSTAIN_FACTORS) do
		if v == value then
			return v
		end
	end

	return nil
end

FreePlayAutoMuteConfig.DISTORTION = {
	TONE_NAME = "Distortion",
	STRING_TRIM = { 1, 1, 1, 0.88, 0.62, 0.72 },
	POLY_WINDOW = 1.2,
	POLY_POWER = 0.5,
	NORMAL_FADE_START = 1,
	NORMAL_FADE_DURATION = 0.5,
	HELD_DECAY_START = 0.6,
	HELD_DECAY_TIME = 3,
	HELD_FLOOR = 0.35
}

function FreePlayAutoMuteConfig.IsDistortionTone(p, p2): boolean
	if p == "GuitarLead" or p == "GuitarRhythm" then
		return p2 == nil or p2 == FreePlayAutoMuteConfig.DISTORTION.TONE_NAME
	end

	return false
end

function FreePlayAutoMuteConfig.DistortionNoteGain(p, p2)
	local distortion = FreePlayAutoMuteConfig.DISTORTION
	return (distortion.STRING_TRIM[p] or 1) * (math.max(0, p2) + 1) ^ (-distortion.POLY_POWER)
end

local v = { GuitarLead = true, GuitarRhythm = true, Bass = true }

function FreePlayAutoMuteConfig.IsAutoMuteInstrument(p): boolean
	return v[p] == true
end

return FreePlayAutoMuteConfig