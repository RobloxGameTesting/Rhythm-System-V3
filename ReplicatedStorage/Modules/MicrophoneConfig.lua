local StudioSlotConfig = require(script.Parent.StudioSlotConfig)
local MicrophoneConfig = {}

MicrophoneConfig.STAGE_STUDIO_IDS = { "STAGE1", "STAGE2", "STAGE3", "STAGE4" }

for _, v in ipairs(StudioSlotConfig.AllStudioIds()) do
	table.insert(MicrophoneConfig.STAGE_STUDIO_IDS, v)
end

MicrophoneConfig.MICROPHONE_FOLDER_NAME = "Microphone"
MicrophoneConfig.MICROPHONE_MODEL_NAME = "Microphone"
MicrophoneConfig.SPEAKER_1_NAME = "Speaker 1"
MicrophoneConfig.SPEAKER_2_NAME = "Speaker 2"

MicrophoneConfig.STAGE_SPOT_ATTACHMENT_NAME = "MicrophoneStageSpot"

MicrophoneConfig.PLACEMENT_TWEEN_TIME = 0.6

MicrophoneConfig.PROMPT_MAX_ACTIVATION_DISTANCE = 4

MicrophoneConfig.BLOCKED_INSTRUMENT_TYPES = { Keyboard = true, Piano = true }

MicrophoneConfig.PICKUP_MAX_DISTANCE = 10
MicrophoneConfig.PICKUP_FULL_DISTANCE = 4
MicrophoneConfig.FRONT_CONE_DOT_MIN = -0.5
MicrophoneConfig.FRONT_CONE_DOT_FULL = 0.1

MicrophoneConfig.MIN_PICKUP_STRENGTH_TO_ACTIVATE = 0.05
MicrophoneConfig.SWITCH_HYSTERESIS = 0.08
MicrophoneConfig.PICKUP_TICK_INTERVAL = 0.1
MicrophoneConfig.PICKUP_SMOOTH_TIME = 0.35

MicrophoneConfig.PA_BASE_GAIN = 3

MicrophoneConfig.REVERB = {
	DecayTime = 0.7,
	DecayRatio = 0.55,
	Density = 0.55,
	Diffusion = 0.65,
	EarlyDelayTime = 0.015,
	LateDelayTime = 0.02,
	DryLevel = 0,
	WetLevel = -16,
	HighCutFrequency = 9000,
	ReferenceFrequency = 5000,
	LowShelfFrequency = 250,
	LowShelfGain = 0
}

MicrophoneConfig.ECHO = {
	DelayTime = 0.09,
	Feedback = 0.12,
	DryLevel = 0,
	WetLevel = -20,
	RampTime = 0.05
}

MicrophoneConfig.REVERB_WET_MIN_DB = -40
MicrophoneConfig.REVERB_WET_MAX_DB = 0
MicrophoneConfig.DEFAULT_REVERB_PERCENT_ON_MIC_ON = 0

MicrophoneConfig.ECHO_WET_MIN_DB = -40
MicrophoneConfig.ECHO_WET_MAX_DB = 0
MicrophoneConfig.DEFAULT_ECHO_PERCENT_ON_MIC_ON = 100

function MicrophoneConfig.PercentToReverbWetDb(value)
	local v = math.clamp(value, 0, 100)
	return MicrophoneConfig.REVERB_WET_MIN_DB + v / 100 * (MicrophoneConfig.REVERB_WET_MAX_DB - MicrophoneConfig.REVERB_WET_MIN_DB)
end

function MicrophoneConfig.PercentToEchoWetDb(value)
	local v = math.clamp(value, 0, 100)
	return MicrophoneConfig.ECHO_WET_MIN_DB + v / 100 * (MicrophoneConfig.ECHO_WET_MAX_DB - MicrophoneConfig.ECHO_WET_MIN_DB)
end

MicrophoneConfig.MIN_VOLUME_PERCENT = 20
MicrophoneConfig.MAX_VOLUME_PERCENT = 150
MicrophoneConfig.DEFAULT_VOLUME_PERCENT = 150

MicrophoneConfig.Debug = false

MicrophoneConfig.DEBUG_BYPASS_EFFECTS = false

function MicrophoneConfig.VolumePercentToMultiplier(value)
	return math.clamp(value, MicrophoneConfig.MIN_VOLUME_PERCENT, MicrophoneConfig.MAX_VOLUME_PERCENT) / 100
end

MicrophoneConfig.BVOCAL_MIN_VOLUME_PERCENT = 0
MicrophoneConfig.BVOCAL_MAX_VOLUME_PERCENT = 100
MicrophoneConfig.BVOCAL_DEFAULT_ON_VOLUME_PERCENT = 50
MicrophoneConfig.BVOCAL_RAW_VOLUME_AT_100_PERCENT = 3

function MicrophoneConfig.BVocalPercentToRaw(value)
	return math.clamp(value, MicrophoneConfig.BVOCAL_MIN_VOLUME_PERCENT, MicrophoneConfig.BVOCAL_MAX_VOLUME_PERCENT) / 100 * MicrophoneConfig.BVOCAL_RAW_VOLUME_AT_100_PERCENT
end

MicrophoneConfig.VOCALIST_SYNC_OVERHEAD_SECONDS = 0.5
MicrophoneConfig.VOCALIST_SYNC_MIN_OFFSET_SECONDS = 0.1
MicrophoneConfig.VOCALIST_SYNC_MAX_OFFSET_SECONDS = 3
MicrophoneConfig.VOCALIST_SYNC_PING_POLL_INTERVAL_SECONDS = 1.5

return MicrophoneConfig