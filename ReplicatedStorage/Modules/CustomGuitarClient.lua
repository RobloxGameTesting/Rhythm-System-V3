local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CustomGuitarConfig = require(script.Parent:WaitForChild("CustomGuitarConfig"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local CustomGuitarGetState = RemoteEvents:WaitForChild("CustomGuitarGetState")
local CustomGuitarSave = RemoteEvents:WaitForChild("CustomGuitarSave")
local CustomGuitarDelete = RemoteEvents:WaitForChild("CustomGuitarDelete")
local CustomGuitarStateUpdate = RemoteEvents:WaitForChild("CustomGuitarStateUpdate")

local CustomGuitarClient = {}

local v = {}
local bindableEvent = Instance.new("BindableEvent")
CustomGuitarClient.Changed = bindableEvent.Event
CustomGuitarClient.Ready = false

local function applyState(result)
	v = {}

	if typeof(result) == "table" and typeof(result.Slots) == "table" then
		for i = 1, CustomGuitarConfig.MAX_SLOTS do
			local v2 = CustomGuitarConfig.Sanitize(result.Slots[tostring(i)])

			if v2 then
				v[i] = v2
			end
		end
	end

	bindableEvent:Fire()
end

function CustomGuitarClient.GetDesign(p)
	return v[p]
end

function CustomGuitarClient.CountUsed()
	local count = 0

	for _ in pairs(v) do
		count += 1
	end

	return count
end

function CustomGuitarClient.Save(p, p2)
	local success, result = pcall(function()
		return CustomGuitarSave:InvokeServer(p, p2)
	end)

	return success and result == true
end

function CustomGuitarClient.Delete(p)
	local success, result = pcall(function()
		return CustomGuitarDelete:InvokeServer(p)
	end)

	return success and result == true
end

CustomGuitarStateUpdate.OnClientEvent:Connect(applyState)

task.spawn(function()
	for i = 1, 5 do
		local success, result = pcall(function()
			return CustomGuitarGetState:InvokeServer()
		end)

		if success then
			CustomGuitarClient.Ready = true
			applyState(result)
			return
		end

		task.wait(i)
	end

	warn("[CustomGuitarClient] Gagal mengambil gitar custom dari server")
end)

return CustomGuitarClient