local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local FreePlaySoundAdapter = require(ReplicatedStorage.Modules.FreePlaySoundAdapter)

local FreePlayAutoMuteConfig = require(ReplicatedStorage.Modules.FreePlayAutoMuteConfig)

local FreePlayVibrato = require(ReplicatedStorage.Modules.FreePlayVibrato)

local FreePlayController = {}

local v = true
local currentInstrumentType = nil
local currentTone = nil
local v2 = {}

local autoMute = false

local sustain = false

local sustainFactor = FreePlayAutoMuteConfig.DEFAULT_SUSTAIN_FACTOR

local overlap = false

local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil

local v7 = false
local currentInstrumentTypeSet = {}
local v8 = false

local tremolo = false
local tremoloBpm = FreePlayAutoMuteConfig.TREMOLO_DEFAULT_BPM
local v9 = {}
local heartbeatConnection = nil
local v10 = nil
local v11 = 0

local function disconnectTremoloStepIfIdle() -- 4 equivalent calls inferred from this helper
	if heartbeatConnection and next(v9) == nil then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

local function stopTremoloLoop(p) -- 1 equivalent call inferred from this helper
	local v12 = v9[p]

	if v12 then
		v9[p] = nil
		disconnectTremoloStepIfIdle() -- inferred equivalent call
	end

	return v12
end

local function stopAllTremoloLoops(p, p2)
	local v12 = next(v9) ~= nil

	for k, v13 in pairs(v9) do
		v9[k] = nil

		if p and v4 and v4.StopTremoloLane then
			v4:StopTremoloLane(v13.Action, v13.OctaveUp)
		end
	end

	disconnectTremoloStepIfIdle() -- inferred equivalent call

	if v12 and p2 and v6 and v6.ReplicateTremoloStop then
		v6:ReplicateTremoloStop()
	end
end

local function disableTremolo() -- 3 equivalent calls inferred from this helper
	if tremolo then
		tremolo = false
		stopAllTremoloLoops(true, true)
	end
end

local function stepTremolo()
	local now = os.clock()
	local tremoloInterval = FreePlayAutoMuteConfig.TremoloInterval(tremoloBpm)

	for k, v12 in pairs(v9) do
		if v and v4 and v12.Instrument == currentInstrumentType then
			local v13 = v12.LastPick + tremoloInterval

			if v13 <= now then
				v4:PlayAction(v12.Action, v12.Instrument, v12.OctaveUp, v12.Tone, false, true, v12.Overlap == true)

				if v5 and v5.PlayTremoloPick then
					v5:PlayTremoloPick(k)
				end

				v12.LastPick = tremoloInterval < now - v13 and now or v13
			end
		else
			v9[k] = nil

			if v4 and v4.StopTremoloLane then
				v4:StopTremoloLane(v12.Action, v12.OctaveUp)
			end
		end
	end

	if next(v9) == nil then
		disconnectTremoloStepIfIdle() -- inferred equivalent call
	elseif v6 and v6.ReplicateTremoloBpm then
		local v12 = now - v11

		if
			tremoloBpm ~= v10 and FreePlayAutoMuteConfig.TREMOLO_BPM_SYNC_INTERVAL <= v12
			or FreePlayAutoMuteConfig.TREMOLO_KEEPALIVE_INTERVAL <= v12
		then
			v10 = tremoloBpm
			v11 = now
			v6:ReplicateTremoloBpm(tremoloBpm)
		end
	end
end

function FreePlayController.SetProfileProvider(p)
	v3 = p
end

function FreePlayController.SetSoundAdapter(p)
	v4 = p
end

function FreePlayController.SetAnimationAdapter(p)
	v5 = p
end

function FreePlayController.SetReplicationAdapter(p)
	v6 = p
end

local v12 = { Physical = false, Locked = false, Applied = false, SentAt = 0 }

local function pianoPedalEffective(): boolean -- 3 equivalent calls inferred from this helper
	return v12.Physical ~= v12.Locked
end

local function applyPianoPedal(p)
	local applied = pianoPedalEffective() -- inferred equivalent call

	if applied == v12.Applied and not p then
		return
	end

	v12.Applied = applied

	if v4 and v4.SetPedal then
		v4:SetPedal(applied)
	end

	if v6 and v6.ReplicatePedal then
		v6:ReplicatePedal(applied)
		v12.SentAt = os.clock()
	end
end

local function syncPianoPedal()
	local applied = pianoPedalEffective() -- inferred equivalent call

	if v4 and v4.SetPedal then
		v4:SetPedal(applied)
	end

	if applied and v6 and v6.ReplicatePedal and os.clock() - v12.SentAt > 1.5 then
		v6:ReplicatePedal(true)
		v12.SentAt = os.clock()
	end

	v12.Applied = applied
end

function FreePlayController.SetInstrument(p)
	currentInstrumentType = p
	local v13

	if p then
		v13 = FreePlaySoundAdapter.GetAvailableTones(p) or nil
	end

	currentTone = v13 and v13[1] or nil

	autoMute = false
	sustain = false
	overlap = p == "Drum"

	tremolo = false
	stopAllTremoloLoops(true, true)

	FreePlayVibrato.ResetActive()

	v12.Physical = false
	v12.Locked = p == "Piano"

	if v12.Applied then
		v12.Applied = false

		if v4 and v4.SetPedal then
			v4:SetPedal(false)
		end

		if v6 and v6.ReplicatePedal then
			v6:ReplicatePedal(false)
		end
	end

	if p == "Piano" and v then
		applyPianoPedal()
	end
end

function FreePlayController.GetAutoMute()
	return autoMute
end

function FreePlayController.SetAutoMute(p)
	autoMute = p == true

	if autoMute then
		sustain = false
		disableTremolo() -- inferred equivalent call
	end
end

function FreePlayController.GetSustain()
	return sustain
end

function FreePlayController.SetSustain(p)
	sustain = p == true

	if sustain then
		autoMute = false
		disableTremolo() -- inferred equivalent call
	end
end

function FreePlayController.GetTremolo()
	return tremolo
end

function FreePlayController.SetTremolo(p)
	if p == true then
		autoMute = false
		sustain = false
		tremolo = true
	else
		disableTremolo() -- inferred equivalent call
	end
end

function FreePlayController.GetTremoloBpm()
	return tremoloBpm
end

function FreePlayController.SetTremoloBpm(p)
	local tremoloBpm2 = FreePlayAutoMuteConfig.ToTremoloBpm(p)

	if not tremoloBpm2 then
		return false
	end

	tremoloBpm = tremoloBpm2
	return tremoloBpm2
end

function FreePlayController.StopAllTremolo()
	stopAllTremoloLoops(true, true)
end

function FreePlayController.GetSustainFactor()
	return sustainFactor
end

function FreePlayController.SetSustainFactor(p): boolean
	local sustainFactor2 = FreePlayAutoMuteConfig.ToSustainFactor(p)

	if not sustainFactor2 then
		return false
	end

	sustainFactor = sustainFactor2
	return true
end

function FreePlayController.GetOverlap()
	return overlap
end

function FreePlayController.SetOverlap(p)
	overlap = p == true
end

function FreePlayController.CycleTone()
	if not currentInstrumentType then
		return nil
	end

	local availableTones = FreePlaySoundAdapter.GetAvailableTones(currentInstrumentType)

	if not availableTones or #availableTones == 0 then
		return nil
	end

	currentTone = availableTones[(table.find(availableTones, currentTone) or 0) % #availableTones + 1]
	return currentTone
end

function FreePlayController.GetCurrentTone()
	return currentTone
end

function FreePlayController.SetTone(p)
	if not currentInstrumentType then
		return nil
	end

	local availableTones = FreePlaySoundAdapter.GetAvailableTones(currentInstrumentType)

	if not (availableTones and table.find(availableTones, p)) then
		return nil
	end

	local v13 = currentTone ~= p
	currentTone = p

	if v13 then
		for _, callback in ipairs(v2) do
			pcall(callback, p)
		end
	end

	return currentTone
end

function FreePlayController.OnToneChanged(p)
	table.insert(v2, p)
end

function FreePlayController.GetCurrentInstrumentType()
	return currentInstrumentType
end

function FreePlayController.SetEnabled(p)
	v = p

	if v and currentInstrumentType == "Piano" then
		applyPianoPedal()
	end

	if not v then
		stopAllTremoloLoops(true, true)
		FreePlayVibrato.ResetActive()
	end
end

local function getActiveProfile()
	if not currentInstrumentType then
		return nil
	end

	if v3 then
		local v13 = v3(currentInstrumentType)

		if not (v13 or currentInstrumentTypeSet[currentInstrumentType]) then
			currentInstrumentTypeSet[currentInstrumentType] = true
			warn("[FreePlayController] ProfileProvider tidak mengembalikan profile untuk:", currentInstrumentType)
		end

		return v13
	end

	if not v7 then
		v7 = true
		warn("[FreePlayController] ProfileProvider belum di-set (SetProfileProvider)")
	end

	return nil
end

function FreePlayController.Press(p, octaveUp, p2)
	if not v then
		return
	end

	local activeProfile = getActiveProfile()

	if not activeProfile then
		return
	end

	local laneAction = activeProfile:GetLaneAction(p)

	if not laneAction then
		return
	end

	local v13 = tremolo and FreePlayAutoMuteConfig.IsAutoMuteInstrument(currentInstrumentType)

	local overlap2 = overlap
		and (FreePlayAutoMuteConfig.IsAutoMuteInstrument(currentInstrumentType) or currentInstrumentType == "Drum")

	if currentInstrumentType == "Piano" then
		syncPianoPedal()
	end

	if v4 then
		v4:PlayAction(
			laneAction,
			currentInstrumentType,
			octaveUp,
			currentTone,
			sustain and sustainFactor or false,
			v13,
			overlap2
		)
	elseif not v8 then
		v8 = true
		warn("[FreePlayController] SoundAdapter belum di-set (SetSoundAdapter)")
	end

	if v5 then
		v5:PlayLane(p)
	end

	if v6 then
		v6:ReplicatePress(
			p,
			octaveUp,
			currentTone,
			sustain and sustainFactor or false,
			v13 and tremoloBpm or false,
			overlap2,
			p2 == true
		)
	end

	if v13 and v4 then
		local now = os.clock()
		v10 = tremoloBpm
		v11 = now
		v9[p] = {
			Action = laneAction,
			Instrument = currentInstrumentType,
			OctaveUp = octaveUp,
			Tone = currentTone,
			LastPick = now,
			Overlap = overlap2
		}

		if not heartbeatConnection then
			heartbeatConnection = RunService.Heartbeat:Connect(stepTremolo)
		end
	end
end

function FreePlayController.MuteAll()
	if
		not v
		or not FreePlayAutoMuteConfig.IsAutoMuteInstrument(currentInstrumentType) and currentInstrumentType ~= "Drum"
	then
		return
	end

	local _ = next(v9) ~= nil

	for k, _ in pairs(v9) do
		v9[k] = nil
	end

	disconnectTremoloStepIfIdle() -- inferred equivalent call

	if v4 and v4.MuteAll then
		v4:MuteAll()
	end

	if v6 and v6.ReplicateMute then
		v6:ReplicateMute()
	end
end

function FreePlayController:SetPedal()
	if not v or currentInstrumentType ~= "Piano" then
		return
	end

	v12.Physical = self == true
	applyPianoPedal()
end

function FreePlayController.SetPedalLock(p)
	if not v or currentInstrumentType ~= "Piano" then
		return false
	end

	v12.Locked = p == true
	applyPianoPedal()
	return v12.Locked
end

function FreePlayController.IsPedalLocked()
	return v12.Locked
end

function FreePlayController.TogglePedalLock()
	if v and currentInstrumentType == "Piano" then
		return FreePlayController.SetPedalLock(not v12.Locked)
	end

	return nil
end

function FreePlayController.IsPedalDown()
	return pianoPedalEffective() -- inferred equivalent call
end

function FreePlayController.Release(p, p2)
	if not v then
		return
	end

	local v13 = stopTremoloLoop(p) -- inferred equivalent call

	if v13 and v4 and v4.StopTremoloLane then
		v4:StopTremoloLane(v13.Action, p2)
	end

	if
		v4
		and v4.ReleaseAction
		and (FreePlayAutoMuteConfig.IsAutoMuteInstrument(currentInstrumentType) or currentInstrumentType == "Piano")
	then
		local activeProfile = getActiveProfile()
		local laneAction = activeProfile and activeProfile:GetLaneAction(p)

		if laneAction then
			v4:ReleaseAction(laneAction, currentInstrumentType, p2, autoMute)
		end
	end

	if v5 and v5.ReleaseLane then
		v5:ReleaseLane(p)
	end

	if v6 then
		v6:ReplicateRelease(p, p2, currentTone, autoMute)
	end
end

return FreePlayController