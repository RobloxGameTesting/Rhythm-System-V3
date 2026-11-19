local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local AudioRigSaveRequest = RemoteEvents:WaitForChild("AudioRigSaveRequest")
local AudioRigSaveResult = RemoteEvents:WaitForChild("AudioRigSaveResult")
local AudioRigLoadRequest = RemoteEvents:WaitForChild("AudioRigLoadRequest")
local AudioRigLoadResult = RemoteEvents:WaitForChild("AudioRigLoadResult")

local AudioRigStore = {}

local v = {}
local v2 = {}

AudioRigSaveResult.OnClientEvent:Connect(function(p)
	local v3 = table.remove(v, 1)

	if v3 then
		local success, result = pcall(v3, p)

		if not success then
			warn("[AudioRigStore] Error pada callback Save:", result)
		end
	end
end)

AudioRigLoadResult.OnClientEvent:Connect(function(p)
	local v3 = table.remove(v2, 1)

	if v3 then
		local success, result = pcall(v3, p)

		if not success then
			warn("[AudioRigStore] Error pada callback Load:", result)
		end
	end
end)

function AudioRigStore.RequestSave(p, p2)
	if p2 then
		table.insert(v, p2)
	end

	AudioRigSaveRequest:FireServer(p)
end

function AudioRigStore.RequestLoad(p)
	table.insert(v2, p)
	AudioRigLoadRequest:FireServer()
end

return AudioRigStore