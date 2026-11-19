local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SongConfig = require(ReplicatedStorage.Modules.SongConfig)
local StemCache = require(ReplicatedStorage.Modules.StemCache)

local SongAudioReady = script.Parent:WaitForChild("SongAudioReady")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local SongPreloadBroadcast = RemoteEvents:WaitForChild("SongPreloadBroadcast", 10)

if SongPreloadBroadcast then
	SongPreloadBroadcast.OnClientEvent:Connect(function(value, p)
		if typeof(value) ~= "string" or not SongConfig.Songs[value] then
			return
		end

		StemCache.RequestSong(value, p == "hard" and "high" or "low")
	end)
else
	warn("[AudioPreload] RemoteEvent SongPreloadBroadcast tidak ditemukan -- preload server-wide TIDAK aktif.")
end

StemCache.WaitForAssets("__priority_ui_sounds", { "rbxassetid://103312453495889", "rbxassetid://114999033488156" }, {
	Priority = "high",
	Permanent = true,
	MaxWaitSeconds = 20
})

local success, result = pcall(function()
	local getActiveSongsForPreload = RemoteEvents:WaitForChild("GetActiveSongsForPreload", 10)
	return getActiveSongsForPreload and getActiveSongsForPreload:InvokeServer() or nil
end)

if success and typeof(result) == "table" and #result > 0 then
	local v = os.clock() + 30
	local v2 = true

	for _, v3 in ipairs(result) do
		StemCache.RequestSong(v3, "high")
	end

	for _, v3 in ipairs(result) do
		local maxWaitSeconds = math.max(0, v - os.clock())
		local v4 = StemCache.WaitForSong(v3, { Priority = "high", MaxWaitSeconds = maxWaitSeconds })
		v2 = v2 and v4
	end

	print(("[AudioPreload] Prioritas: %d lagu yang sedang berjalan di map di-preload (%s)."):format(
		#result,
		v2 and "semua siap" or "sebagian masih dimuat -- retry jalan di latar belakang"
	))
end

SongAudioReady:Fire()