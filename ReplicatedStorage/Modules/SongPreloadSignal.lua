local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StemCache = require(ReplicatedStorage.Modules.StemCache)

local requestSongPreload = nil
local count = 0
local nows = {}

local function getRemote() -- 1 equivalent call inferred from this helper
	if requestSongPreload and requestSongPreload.Parent then
		return requestSongPreload
	end

	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	requestSongPreload = remoteEvents and remoteEvents:FindFirstChild("RequestSongPreload") or nil
	return requestSongPreload
end

local function send(value, p, p2)
	local success, result = pcall(StemCache.RequestSong, value, p == "hard" and "high" or "low")

	if not success then
		warn("[SongPreloadSignal] StemCache.RequestSong gagal: " .. tostring(result))
	end

	local v = value .. "|" .. p
	local now = os.clock()

	if nows[v] and now - nows[v] < 20 then
		return
	end

	nows[v] = now
	local remote = getRemote() -- inferred equivalent call

	if remote then
		pcall(function()
			remote:FireServer(value, p, p2)
		end)
	end
end

local SongPreloadSignal = {}

function SongPreloadSignal.NotifySelected(value, p)
	count += 1
	local v = count

	if type(value) ~= "string" then
		return
	end

	task.delay(2.5, function()
		if v ~= count then
			return
		end

		send(value, "soft", p)
	end)
end

function SongPreloadSignal.CancelSelected()
	count += 1
end

function SongPreloadSignal.NotifyCommit(value, p)
	count += 1

	if type(value) ~= "string" then
		return
	end

	send(value, "hard", p)
end

return SongPreloadSignal