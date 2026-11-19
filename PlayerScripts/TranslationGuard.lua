local Players = game:GetService("Players")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local v = {
	ScoreDisplayUI = true,
	LiveStatsHUD = true,
	BandScoreUI = true,
	BandGui = true,
	RockMeterUI = true,
	RhythmVibratoHUD = true,
	InstrumentHUD = true,
	PerfStatsHUD = true,
	ViewerCountHUD = true,
	RoomHudGui = true,
	DrumFreePlayUI = true,
	PianoFreePlayUI = true,
	VirtualKeyboardUI = true,
	RadioSongListGui = true,
	RadioAccessHUD = true,
	SongListToastGui = true,
	GCamHUD = true,
	BandCameraTuner = true,
	BandCameraFxPanelGui = true
}

local function protectRoot(layerCollector) -- 3 equivalent calls inferred from this helper
	if v[layerCollector.Name] and layerCollector:IsA("LayerCollector") and layerCollector.AutoLocalize then
		layerCollector.AutoLocalize = false
	end
end

local function isNumericOnly(text): boolean -- 1 equivalent call inferred from this helper
	return text ~= "" and string.find(text, "%d") ~= nil and string.find(text, "%a") == nil
end

local function scanGui(folder)
	protectRoot(folder) -- inferred equivalent call

	if not folder.AutoLocalize then
		return
	end

	local count = 0

	for _, guiObject in ipairs(folder:GetDescendants()) do
		count += 1

		if count % 400 == 0 then
			task.wait()
		end

		if not ((guiObject:IsA("TextLabel") or guiObject:IsA("TextButton")) and guiObject.AutoLocalize and isNumericOnly(guiObject.Text)) then -- inferred equivalent call
			continue
		end

		guiObject.AutoLocalize = false
	end
end

local function scanAll()
	for _, layerCollector in ipairs(PlayerGui:GetChildren()) do
		if not layerCollector:IsA("LayerCollector") then
			continue
		end

		scanGui(layerCollector)
		task.wait()
	end
end

local v2 = { 8, 20, 45 }

for _, child in ipairs(PlayerGui:GetChildren()) do
	protectRoot(child) -- inferred equivalent call
end

PlayerGui.ChildAdded:Connect(function(layerCollector)
	protectRoot(layerCollector) -- inferred equivalent call
	task.delay(3, function()
		if layerCollector.Parent == PlayerGui and layerCollector:IsA("LayerCollector") then
			scanGui(layerCollector)
		end
	end)
end)

task.spawn(function()
	local v3 = 0

	for _, v4 in ipairs(v2) do
		task.wait(v4 - v3)

		scanAll()
		v3 = v4
	end
end)