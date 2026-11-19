local PlaybackController = {
	State = { STOPPED = "STOPPED", PLAYING = "PLAYING", PAUSED = "PAUSED", DESTROYED = "DESTROYED" },
	CorrectionMode = { SNAP = "SNAP", NUDGE = "NUDGE" },
	RequiredMethods = {
		"Play",
		"Pause",
		"Resume",
		"Stop",
		"SyncToElapsed",
		"Destroy",
		"SetVolume",
		"SetPlaybackSpeed",
		"GetLength",
		"GetCurrentTime",
		"GetState",
		"IsAlive",
		"GetDebugInfo"
	}
}

function PlaybackController.Implements(p): boolean
	if typeof(p) ~= "table" then
		return false
	end

	for _, requiredMethod in ipairs(PlaybackController.RequiredMethods) do
		if typeof(p[requiredMethod]) ~= "function" then
			return false
		end
	end

	return true
end

return PlaybackController