local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalEventBus = require(ReplicatedStorage.Modules.SongListUI.GlobalEventBus)
local RecentlyPlayedRemotes = require(ReplicatedStorage.Modules.RecentlyPlayedSystem.RecentlyPlayedRemotes)

local flag = false
local child = nil
local RecentlyPlayedClient = {}

function RecentlyPlayedClient.Init()
	if flag then
		return
	end

	flag = true

	local child2 = ReplicatedStorage:WaitForChild(RecentlyPlayedRemotes.FolderName)
	child = child2:WaitForChild(RecentlyPlayedRemotes.RecordPlayed)
	local child3 = child2:WaitForChild(RecentlyPlayedRemotes.RecentlyPlayedLoaded)
	local child4 = child2:WaitForChild(RecentlyPlayedRemotes.RecentlyPlayedUpdated)

	child3.OnClientEvent:Connect(function(p)
		GlobalEventBus:Publish("RecentlyPlayed:Changed", p)
	end)
	child4.OnClientEvent:Connect(function(p)
		GlobalEventBus:Publish("RecentlyPlayed:Changed", p)
	end)
end

function RecentlyPlayedClient.RecordPlayed(p)
	if child then
		child:FireServer(p)
	else
		warn("[RecentlyPlayedClient] RecordPlayed dipanggil sebelum Init().")
	end
end

return RecentlyPlayedClient