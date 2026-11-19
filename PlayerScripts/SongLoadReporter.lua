local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientSongPreloader = require(ReplicatedStorage.Modules.ClientSongPreloader)

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local SongSessionStatusUpdate = RemoteEvents:WaitForChild("SongSessionStatusUpdate")
local ReportLoadProgress = RemoteEvents:WaitForChild("ReportLoadProgress")

local count = 0

SongSessionStatusUpdate.OnClientEvent:Connect(function(p, p2)
	count += 1
	local v = count

	if p and p2 then
		task.spawn(function()
			ClientSongPreloader.PreloadSongStems(p2, function(p3)
				if v == count then
					ReportLoadProgress:FireServer(p3)
				end
			end)
		end)
	end
end)