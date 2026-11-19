local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local FreePlaySoundAdapter = require(script.Parent:WaitForChild("FreePlaySoundAdapter"))

local FreePlayAnimationAdapter = require(script.Parent:WaitForChild("FreePlayAnimationAdapter"))

local v = false
local v2 = nil

local function getRemote() -- 7 equivalent calls inferred from this helper
	if v2 then
		return v2
	end

	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	local freePlayReplication = remoteEvents and remoteEvents:FindFirstChild("FreePlayReplication")

	if freePlayReplication then
		v2 = freePlayReplication
		return v2
	end

	if not v then
		v = true
		warn("[FreePlayReplicationAdapter] RemoteEvent 'FreePlayReplication' belum ada di ReplicatedStorage.RemoteEvents - buat manual di Studio (lihat header modul ini)")
	end

	return nil
end

local FreePlayReplicationAdapter = {}

function FreePlayReplicationAdapter.ReplicatePress(_, p, p2, p3, p4, p5, p6, p7)
	local remote = getRemote() -- inferred equivalent call

	if remote then
		remote:FireServer(
			"Press",
			p,
			p2,
			p3,
			FreePlaySoundAdapter.GetLocalTuning() or FreePlaySoundAdapter.GetLocalDrumPayload(),
			tonumber(p4) or false,
			tonumber(p5) or false,
			p6 == true,
			Workspace:GetServerTimeNow(),
			FreePlayAnimationAdapter.ConsumeLastHand(),
			p7 == true
		)
	end
end

function FreePlayReplicationAdapter.ReplicateTremoloBpm(_, p)
	local remote = getRemote() -- inferred equivalent call

	if remote then
		remote:FireServer("TremoloBpm", p)
	end
end

function FreePlayReplicationAdapter.ReplicateTremoloStop(_)
	local remote = getRemote() -- inferred equivalent call

	if remote then
		remote:FireServer("TremoloStop")
	end
end

function FreePlayReplicationAdapter.ReplicateRelease(_, p, p2, p3, p4)
	local remote = getRemote() -- inferred equivalent call

	if remote then
		remote:FireServer("Release", p, p2, p3, p4)
	end
end

function FreePlayReplicationAdapter.ReplicateMute(_)
	local remote = getRemote() -- inferred equivalent call

	if remote then
		remote:FireServer("Mute")
	end
end

function FreePlayReplicationAdapter.ReplicateVibrato(_, p, p2, p3, value, p4, value2)
	local remote = getRemote() -- inferred equivalent call

	if remote then
		remote:FireServer("Vibrato", p == true, p2, p3, value or 0, p4 == true, value2 or 1)
	end
end

function FreePlayReplicationAdapter.ReplicatePedal(_, p)
	local remote = getRemote() -- inferred equivalent call

	if remote then
		remote:FireServer("Pedal", p == true)
	end
end

return FreePlayReplicationAdapter