local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local BandLiveConfig = require(Modules:WaitForChild("BandLiveConfig"))
local BandScoreUI = require(Modules:WaitForChild("BandScoreUI"))
local BroadcastStreakNotice = RemoteEvents:WaitForChild("BroadcastStreakNotice")

local success, result = pcall(function()
	return require(Modules:WaitForChild("BandCamera", 10):WaitForChild("BandCameraController", 10))
end)

local Attribute = BandLiveConfig.Attribute

local v = {}
local v2 = nil

local function listStages()
	local map = Workspace:FindFirstChild("Map")
	local children = {}

	if map then
		for _, child in ipairs(map:GetChildren()) do
			if child:GetAttribute("StudioId") ~= nil then
				table.insert(children, child)
			end
		end
	end

	return children
end

local function decodeAttribute(instance, attributeName)
	local attribute = instance:GetAttribute(attributeName)

	if typeof(attribute) ~= "string" then
		return nil
	end

	local v3 = v[instance]

	if attributeName == Attribute then
		if v3 and v3.raw == attribute then
			return v3.data
		end

		local success2, result2 = pcall(HttpService.JSONDecode, HttpService, attribute)

		if not success2 or type(result2) ~= "table" then
			return nil
		end

		v[instance] = { raw = attribute, data = result2 }
		return result2
	else
		local success2, result2 = pcall(HttpService.JSONDecode, HttpService, attribute)

		if not success2 or type(result2) ~= "table" or not result2 then
			result2 = nil
		end

		return result2
	end
end

local function payloadHasUser(p, userId): boolean -- 3 equivalent calls inferred from this helper
	if type(p) ~= "table" or type(p.p) ~= "table" then
		return false
	end

	for _, v3 in ipairs(p.p) do
		if v3.u == userId then
			return true
		end
	end

	return false
end

local function findMyPayload()
	for _, v3 in ipairs(listStages()) do
		local v4 = decodeAttribute(v3, Attribute)

		if not (v4 and type(v4.s) == "table") then
			continue
		end

		for _, v5 in pairs(v4.s) do
			if payloadHasUser(v5, LocalPlayer.UserId) then -- inferred equivalent call
				return v5
			end
		end
	end

	return nil
end

local function findWatchPayload()
	if not success or type(result.GetWatchStageId) ~= "function" then
		return nil, false
	end

	local watchStageId = result.GetWatchStageId()

	if not watchStageId then
		return nil, false
	end

	for _, v3 in ipairs(listStages()) do
		if v3:GetAttribute("StudioId") == watchStageId then
			local v4 = decodeAttribute(v3, Attribute)
			local v5 = decodeAttribute(v3, "CamTarget")

			if not v5 or v5.session == nil then
				return nil, false
			end

			local v6 = v4 and type(v4.s) == "table" and v4.s[tostring(v5.session)]

			if v6 then
				return v6, false
			end

			if v3:GetAttribute("CamSim") == true and PlayerGui:GetAttribute("BandSimHudOff") ~= true then
				local v7 = decodeAttribute(v3, "BandLiveSim")

				if v7 and type(v7.s) == "table" and v7.s[tostring(v5.session)] then
					return v7.s[tostring(v5.session)], true
				end
			end

			return nil, false
		end
	end

	return nil, false
end

local v3 = {}
local v4 = nil

local function simFeedReset() -- 2 equivalent calls inferred from this helper
	if next(v3) ~= nil then
		v3 = {}
	end

	v4 = nil
end

local function simFeedTick(watchPayload)
	if type(watchPayload) ~= "table" or type(watchPayload.p) ~= "table" or #watchPayload.p == 0 then
		return
	end

	local now = os.clock()
	v4 = v4 or now + 25

	for _, v5 in ipairs(watchPayload.p) do
		local c = tonumber(v5.c) or 0
		local v6 = math.floor(c / 25) * 25

		if c < 25 then
			v3[v5.u] = 0
		elseif (v3[v5.u] or 0) < v6 then
			v3[v5.u] = v6
			BandScoreUI.PushFeed(tostring(v5.n or "?"), v6, false, v5.u)
		end
	end

	if v4 <= now then
		v4 = now + 35 + math.random() * 30
		local v5 = watchPayload.p[math.random(1, #watchPayload.p)]
		local v6 = math.random(1, 3)
		BandScoreUI.PushMoment(tostring(v5.n or "?"), "STAR POWER LV" .. tostring(v6), "star", v5.u, 2 + v6)
	end
end

local v5 = nil
local function ensureMode(p) -- 2 equivalent calls inferred from this helper
	if not BandScoreUI.IsShown() or v5 ~= p then
		BandScoreUI.Show(p)
		v5 = p
	end
end

local function laneUiOn() -- 1 equivalent call inferred from this helper
	local noteLaneUI = PlayerGui:FindFirstChild("NoteLaneUI")

	if noteLaneUI ~= nil and noteLaneUI.Enabled then
		return true
	end

	local noteLaneUI3D = PlayerGui:FindFirstChild("NoteLaneUI3D")
	return noteLaneUI3D ~= nil and noteLaneUI3D.Enabled
end

local function evaluate()
	if PlayerGui:GetAttribute("HudPreviewActive") == true then
		return
	end

	local myPayload = findMyPayload()

	if myPayload then
		if laneUiOn() then -- inferred equivalent call
			v2 = myPayload
			ensureMode("hud") -- inferred equivalent call
			BandScoreUI.SetPayload(myPayload, LocalPlayer.UserId)
		else
			v2 = nil
			v5 = nil

			if BandScoreUI.IsShown() then
				BandScoreUI.Hide()
			end
		end
	else
		local watchPayload, v6 = findWatchPayload()

		if watchPayload then
			v2 = watchPayload
			ensureMode("screen") -- inferred equivalent call
			BandScoreUI.SetPayload(watchPayload, nil)

			if v6 then
				simFeedTick(watchPayload)
				return
			end

			simFeedReset() -- inferred equivalent call
		else
			simFeedReset() -- inferred equivalent call
			v2 = nil
			v5 = nil

			if BandScoreUI.IsShown() then
				BandScoreUI.Hide()
			end
		end
	end
end

task.spawn(function()
	while true do
		task.wait(0.2)
		local success2, result2 = pcall(evaluate)

		if not success2 then
			warn("[BandScoreClient] evaluate gagal: " .. tostring(result2))
		end
	end
end)

BroadcastStreakNotice.OnClientEvent:Connect(function(player, p, p2)
	if p ~= "Streak" or typeof(player) ~= "Instance" or not player:IsA("Player") then
		return
	end

	if BandScoreUI.IsShown() and payloadHasUser(v2, player.UserId) then -- inferred equivalent call
		local v6 = player == LocalPlayer
		BandScoreUI.PushFeed(v6 and "YOU" or player.Name, p2, v6, player.UserId)
	end
end)

local BroadcastStarPowerActivation = RemoteEvents:FindFirstChild("BroadcastStarPowerActivation")

if BroadcastStarPowerActivation then
	BroadcastStarPowerActivation.OnClientEvent:Connect(function(player, value)
		if typeof(player) ~= "Instance" or not player:IsA("Player") or typeof(value) ~= "number" then
			return
		end

		if BandScoreUI.IsShown() and payloadHasUser(v2, player.UserId) then -- inferred equivalent call
			local v6 = player == LocalPlayer and "YOU" or player.Name
			local v7 = math.clamp(math.floor(value), 1, 3)
			BandScoreUI.PushMoment(v6, "STAR POWER LV" .. tostring(v7), "star", player.UserId, v7 + 2)
		end
	end)
end