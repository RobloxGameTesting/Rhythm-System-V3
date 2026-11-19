local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AudioRig = require(ReplicatedStorage.Modules.AudioRig)

local freePlayAmpSync = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("FreePlayAmpSync")

local function sendSnapshot(p)
	if not p.Amp then
		return
	end

	freePlayAmpSync:FireServer({
		Gain = p.Amp.Gain,
		Bass = p.Amp.Bass,
		Middle = p.Amp.Middle,
		Treble = p.Amp.Treble,
		Presence = p.Amp.Presence,
		Master = p.Amp.Master,
		Volume = p.Volume
	})
end

return {
	SetRig = function(p)
		if not p then
			return
		end

		sendSnapshot(p)

		AudioRig.OnChanged(p, function(p2, p3)
			if p2 ~= p then
				return
			end

			if p3 and (p3.Amp or p3.Volume) then
				sendSnapshot(p)
			end
		end)
	end
}