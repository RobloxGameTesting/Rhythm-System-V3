local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModeManager = require(ReplicatedStorage.Modules.ModeManager)
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local InstrumentHUDUpdate = RemoteEvents:WaitForChild("InstrumentHUDUpdate")
local FreePlayModeReport = RemoteEvents:WaitForChild("FreePlayModeReport")

local v = false
local v2 = false

local function report()
	local v3 = v and ModeManager.IsFreePlay()

	if v3 ~= v2 then
		v2 = v3
		FreePlayModeReport:FireServer(v3)
	end
end

InstrumentHUDUpdate.OnClientEvent:Connect(function(p)
	v = p == true

	task.defer(report)
end)

ModeManager.OnChanged(report)