local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PerformanceEvent = Remotes:WaitForChild("PerformanceEvent")
local InstrumentLifecycleEvent = Remotes:WaitForChild("InstrumentLifecycleEvent")

local DrumAnimator = require(ReplicatedStorage.Modules.DrumAnimator)
local PianoAnimator = require(ReplicatedStorage.Modules.PianoAnimator)
local GuitarAnimator = require(ReplicatedStorage.Modules.GuitarAnimator)
local KeyboardAnimator = require(ReplicatedStorage.Modules.KeyboardAnimator)
local LocalPerformanceSignal = require(ReplicatedStorage.Modules.LocalPerformanceSignal)
local InstrumentLifecycleSignal = require(ReplicatedStorage.Modules.InstrumentLifecycleSignal)

local v = {
	Drum = DrumAnimator,
	Piano = PianoAnimator,
	GuitarRhythm = GuitarAnimator,
	GuitarLead = GuitarAnimator,
	Bass = GuitarAnimator,
	Keyboard = KeyboardAnimator
}

local function routePerformanceEvent(p, p2) -- 2 equivalent calls inferred from this helper
	local v2 = v[p2.InstrumentType]

	if v2 then
		v2.Handle(p, p2)
	end
end

PerformanceEvent.OnClientEvent:Connect(function(p, p2)
	if typeof(p2) ~= "table" then
		return
	end

	routePerformanceEvent(p, p2) -- inferred equivalent call
end)

LocalPerformanceSignal.Event:Connect(function(p)
	if typeof(p) ~= "table" then
		return
	end

	routePerformanceEvent(LocalPlayer, p) -- inferred equivalent call
end)

local function routeLifecycleEvent(player, data)
	local v2 = v[data.InstrumentType]

	if not (v2 and player.Character) then
		return
	end

	if data.Lifecycle == "SessionStart" or data.Lifecycle == "SessionEnd" then
		if v2.SetIdleActive then
			v2.SetIdleActive(player.Character, data.Lifecycle == "SessionStart")
		end

		if v2.SetChartSyncActive then
			v2.SetChartSyncActive(player.Character, data.Lifecycle == "SessionStart", data.SongName)
		end
	elseif data.Lifecycle == "ClickSchedule" then
		if v2.PlayCountInClicks then
			v2.PlayCountInClicks(player, data.BPM, data.FirstNoteTime, data.PreRollRemaining, data.Volume)
		end
	elseif data.Lifecycle == "ManualStickClick" and v2.PlayManualStickClick then
		v2.PlayManualStickClick(player)
	end
end

InstrumentLifecycleSignal.Event:Connect(function(p)
	if typeof(p) ~= "table" then
		return
	end

	routeLifecycleEvent(LocalPlayer, p)
end)

local v2 = {}

local function endApplied(player) -- 3 equivalent calls inferred from this helper
	local v3 = v2[player]
	v2[player] = nil

	if not v3 then
		return
	end

	local v4 = v[v3.InstrumentType]

	if v4 and v3.Character then
		if v4.SetIdleActive then
			pcall(v4.SetIdleActive, v3.Character, false)
		end

		if v4.SetChartSyncActive then
			pcall(v4.SetChartSyncActive, v3.Character, false)
		end
	end
end

local function isSeatedInstrument(ILC_InstrumentType): boolean -- 1 equivalent call inferred from this helper
	return ILC_InstrumentType == "Drum" or ILC_InstrumentType == "Piano"
end

local function syncRemotePlayer(player)
	if player == LocalPlayer then
		return
	end

	local ILC_InstrumentType = player:GetAttribute("ILC_InstrumentType")
	local ILC_SongName = player:GetAttribute("ILC_SongName")
	local v3 = v2[player]
	local character = player.Character
	local v4

	if ILC_InstrumentType == nil or ILC_SongName == nil then
		v4 = false
	else
		v4 = v[ILC_InstrumentType] ~= nil
	end

	if v4 then
		if v3 and (v3.Character ~= character or not v3.Character:IsDescendantOf(game)) then
			endApplied(player) -- inferred equivalent call
			v3 = nil
		end

		if
			not (character and character:IsDescendantOf(game))
			or v3 and v3.InstrumentType == ILC_InstrumentType and v3.SongName == ILC_SongName
		then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if not (humanoid and character:FindFirstChild("HumanoidRootPart")) then
			return
		end

		if isSeatedInstrument(ILC_InstrumentType) then -- inferred equivalent call
			local seatPart = humanoid.SeatPart

			if not (seatPart and seatPart:IsDescendantOf(workspace)) then
				return
			end
		end

		local now = os.clock()
		local v5 = v2[player]

		if not v5 then
			v2[player] = {
				Character = character,
				InstrumentType = ILC_InstrumentType,
				SongName = ILC_SongName,
				ReadySince = now,
				Started = false
			}
			v5 = v2[player]
		end

		if v5.Started and v5.InstrumentType == ILC_InstrumentType and v5.SongName == ILC_SongName then
			return
		end

		if v5.InstrumentType ~= ILC_InstrumentType or v5.SongName ~= ILC_SongName then
			endApplied(player) -- inferred equivalent call
			v2[player] = {
				Character = character,
				InstrumentType = ILC_InstrumentType,
				SongName = ILC_SongName,
				ReadySince = now,
				Started = false
			}
			v5 = v2[player]
		end

		if now - v5.ReadySince < 0.75 then
			return
		end

		v5.Started = true
		routeLifecycleEvent(player, {
			InstrumentType = ILC_InstrumentType,
			Lifecycle = "SessionStart",
			SongName = ILC_SongName
		})
	elseif v3 then
		endApplied(player) -- inferred equivalent call
	end
end

InstrumentLifecycleEvent.OnClientEvent:Connect(function(player, data)
	if typeof(data) ~= "table" then
		return
	end

	routeLifecycleEvent(player, data)

	if data.Lifecycle == "SessionStart" and player and player.Character and v[data.InstrumentType] then
		v2[player] = {
			Character = player.Character,
			InstrumentType = data.InstrumentType,
			SongName = data.SongName,
			ReadySince = os.clock(),
			Started = true
		}
	elseif data.Lifecycle == "SessionEnd" and player then
		v2[player] = nil
	end
end)

Players.PlayerRemoving:Connect(function(player)
	v2[player] = nil
end)

task.spawn(function()
	while true do
		task.wait(0.5)

		for _, v3 in ipairs(Players:GetPlayers()) do
			local success, result = pcall(syncRemotePlayer, v3)

			if not success then
				warn("[AnimationController] late-join sync gagal: " .. tostring(result))
			end
		end
	end
end)