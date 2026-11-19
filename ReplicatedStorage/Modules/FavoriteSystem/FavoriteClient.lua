local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalEventBus = require(ReplicatedStorage.Modules.SongListUI.GlobalEventBus)
local FavoriteRemotes = require(ReplicatedStorage.Modules.FavoriteSystem.FavoriteRemotes)

local flag = false

local v = {}
return {
	Init = function()
		if flag then
			return
		end

		flag = true

		local child = ReplicatedStorage:WaitForChild(FavoriteRemotes.FolderName)
		local child2 = child:WaitForChild(FavoriteRemotes.ToggleFavoriteSong)
		child:WaitForChild(FavoriteRemotes.FavoriteSongUpdated).OnClientEvent:Connect(function(p, p2)
			v[p] = nil

			GlobalEventBus:Publish("Favorite:Changed", p, p2)

			GlobalEventBus:Publish(p2 and "Favorite:Added" or "Favorite:Removed", p)
		end)

		GlobalEventBus:Subscribe("Favorite:RequestToggle", function(value)
			if typeof(value) ~= "string" or value == "" or v[value] then
				return
			end

			v[value] = true
			child2:FireServer(value)
		end)
	end
}