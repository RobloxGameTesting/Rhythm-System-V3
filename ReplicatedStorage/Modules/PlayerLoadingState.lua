local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PlayerLoadingState = {}

local v = 0
local v2 = {}
local flag = false
local v3 = false
local v4 = nil

local function flush() -- 2 equivalent calls inferred from this helper
	if v4 then
		v4:FireServer(flag)
	else
		task.spawn(function()
			local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
			local playerLoadingStateChanged = remoteEvents
				and remoteEvents:WaitForChild("PlayerLoadingStateChanged", 10)

			if playerLoadingStateChanged then
				v4 = playerLoadingStateChanged
				v4:FireServer(flag)
			end
		end)
	end
end

local function evaluate()
	if v > 0 then
		if not (flag or v3) then
			v3 = true
			task.delay(0.4, function()
				v3 = false

				if v > 0 and not flag then
					flag = true
					flush() -- inferred equivalent call
				end
			end)
		end
	elseif flag then
		flag = false
		flush() -- inferred equivalent call
	end
end

function PlayerLoadingState.Begin(reason)
	if RunService:IsServer() then
		return nil
	end

	local v5 = { reason = reason, startedAt = os.clock() }
	v2[v5] = true
	v += 1
	evaluate()
	task.delay(120, function()
		PlayerLoadingState.End(v5)
	end)
	return v5
end

function PlayerLoadingState.End(p)
	if p and v2[p] then
		v2[p] = nil
		v -= 1
		evaluate()
	end
end

function PlayerLoadingState.IsLoading(): boolean
	return v > 0
end

local v5 = false
local v6 = nil

function PlayerLoadingState.ReportSongListOpen(p)
	if RunService:IsServer() then
		return
	end

	v5 = p == true

	if v6 then
		v6:FireServer(v5)
	else
		task.spawn(function()
			local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
			local playerSongListStateChanged = remoteEvents
				and remoteEvents:WaitForChild("PlayerSongListStateChanged", 10)

			if playerSongListStateChanged then
				v6 = playerSongListStateChanged
				v6:FireServer(v5)
			end
		end)
	end
end

local v7 = false
local v8 = nil

function PlayerLoadingState.ReportMicSettingsOpen(p)
	if RunService:IsServer() then
		return
	end

	v7 = p == true

	if v8 then
		v8:FireServer(v7)
	else
		task.spawn(function()
			local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
			local playerMicSettingsStateChanged = remoteEvents
				and remoteEvents:WaitForChild("PlayerMicSettingsStateChanged", 10)

			if playerMicSettingsStateChanged then
				v8 = playerMicSettingsStateChanged
				v8:FireServer(v7)
			end
		end)
	end
end

local v9 = false
local v10 = nil

function PlayerLoadingState.ReportTabsPlaying(p)
	if RunService:IsServer() then
		return
	end

	local v11 = p == true

	if v11 == v9 and v10 then
		return
	end

	v9 = v11

	if v10 then
		v10:FireServer(v9)
	else
		task.spawn(function()
			local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
			local playerTabsStateChanged = remoteEvents and remoteEvents:WaitForChild("PlayerTabsStateChanged", 10)

			if playerTabsStateChanged then
				v10 = playerTabsStateChanged
				v10:FireServer(v9)
			end
		end)
	end
end

local v11 = nil
local v12 = nil

function PlayerLoadingState.ReportTabsEdit(p)
	if RunService:IsServer() then
		return
	end

	if p ~= "Creating" and p ~= "Recording" then
		p = nil
	end

	if p == v11 and v12 then
		return
	end

	v11 = p

	if v12 then
		v12:FireServer(v11)
	else
		task.spawn(function()
			local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
			local playerTabsEditStateChanged = remoteEvents
				and remoteEvents:WaitForChild("PlayerTabsEditStateChanged", 10)

			if playerTabsEditStateChanged then
				v12 = playerTabsEditStateChanged
				v12:FireServer(v11)
			end
		end)
	end
end

return PlayerLoadingState