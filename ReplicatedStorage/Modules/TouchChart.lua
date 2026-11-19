local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TouchChart = {}

local v = {
	Perfect = 4,
	Great = 3,
	Good = 2,
	OK = 1,
	Miss = 0
}

local v2 = nil
local v3 = nil

function TouchChart.IsDeviceEligible()
	if RunService:IsStudio() then
		local localPlayer = Players.LocalPlayer

		if localPlayer and localPlayer:GetAttribute("TouchChartStudioForce") == true then
			return true
		end
	end

	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function TouchChart.IsActive()
	if not TouchChart.IsDeviceEligible() then
		return false
	end

	local SettingsState = require(ReplicatedStorage.Modules.SettingsState)
	return SettingsState.GetTouchChartEnabled()
end

local function clearNote(p) -- 1 equivalent call inferred from this helper
	p._hidden = nil
	p._partners = nil
	p._followers = nil
	p._tcResult = nil
	p._tcHoldWait = nil
	p._tcHoldFailed = nil
	p._tcHoldEnded = nil
	p._tcHoldResult = nil
end

local function assignGroup(list, p, p2)
	local laneSet = {}
	local v4 = 1e999
	local v5 = -1e999
	local count = 0

	for i = p, p2 do
		local lane = list[i].Lane

		if not laneSet[lane] then
			laneSet[lane] = true
			count += 1
		end

		if lane < v4 then
			v4 = lane
		end

		if v5 < lane then
			v5 = lane
		end
	end

	if count < 3 then
		return
	end

	local v6 = nil
	local v7 = nil

	for i = p, p2 do
		local item = list[i]

		if v6 or item.Lane ~= v4 then
			if not v7 and item.Lane == v5 then
				v7 = item
			end
		else
			v6 = item
		end
	end

	if not (v6 and v7) then
		return
	end

	local partners = { v6, v7 }
	local followers = {}

	for i = p, p2 do
		local item = list[i]

		if not (item ~= v6 and item ~= v7) then
			continue
		end

		item._hidden = true
		item._partners = partners
		table.insert(followers, item)
	end

	v6._followers = followers
	v7._followers = followers
end

function TouchChart.Apply(list)
	if not list then
		return
	end

	local isActive = TouchChart.IsActive()
	v2 = isActive
	v3 = list

	local v4 = table.create(#list)

	for i, item in ipairs(list) do
		v4[i] = item
	end

	table.sort(v4, function(a, b): boolean
		return a.Time < b.Time
	end)

	local count = #v4
	local v5 = 1

	while v5 <= count do
		local time = v4[v5].Time
		local v6 = v5

		while v6 < count and v4[v6 + 1].Time - time <= 0.03 do
			v6 += 1
		end

		local v7 = false

		for i = v5, v6 do
			local v8 = v4[i]

			if v8._judged or v8._holding then
				v7 = true
				break
			end
		end

		if not v7 then
			for i = v5, v6 do
				clearNote(v4[i]) -- inferred equivalent call
			end

			if isActive and v6 - v5 + 1 >= 3 then
				assignGroup(v4, v5, v6)
			end
		end

		v5 = v6 + 1
	end
end

function TouchChart.Refresh(p)
	if not p then
		return
	end

	if v3 ~= p or v2 ~= TouchChart.IsActive() then
		TouchChart.Apply(p)
	end
end

function TouchChart:OnJudged(tcResult, data, p)
	local followers = self._followers

	if not followers then
		return
	end

	self._tcResult = tcResult

	for _, follower in ipairs(followers) do
		if follower._judged then
			continue
		end

		local tcResult3 = nil
		local flag = true

		for _, partner in ipairs(follower._partners) do
			local _tcResult = partner._tcResult

			if _tcResult then
				if tcResult3 == nil or (v[_tcResult] or 0) < (v[tcResult3] or 0) then
					tcResult3 = _tcResult
				end
			else
				flag = false
				break
			end
		end

		if not flag then
			continue
		end

		follower._judged = true
		follower._tcResult = tcResult3

		local count = 0
		local flag2 = false
		local v4

		if tcResult3 == "Miss" then
			v4 = false
		else
			v4 = (follower.Duration or 0) > 0
		end

		if v4 then
			for _, partner in ipairs(follower._partners) do
				if not ((partner.Duration or 0) > 0 and partner._tcResult ~= "Miss") then
					continue
				end

				if partner._tcHoldResult == "bad" then
					flag2 = true
				elseif partner._tcHoldResult == nil then
					count += 1
				end
			end
		end

		data.apply(tcResult3, follower.Lane, p, true)

		if tcResult3 ~= "Miss" then
			data.perf(count > 0 and "HoldStart" or "Hit", follower, tcResult3)
		end

		if not v4 then
			continue
		end

		if flag2 then
			follower._tcHoldFailed = true
		elseif count == 0 then
			data.holdBonus()
		else
			follower._tcHoldWait = count
		end
	end
end

function TouchChart:OnHoldReleased(p, p2)
	local followers = self._followers

	if not followers then
		return
	end

	self._tcHoldResult = p and "ok" or "bad"

	for _, follower in ipairs(followers) do
		if not follower._tcHoldWait or not (follower._tcHoldWait > 0) or follower._tcHoldFailed then
			continue
		end

		if p then
			follower._tcHoldWait -= 1

			if follower._tcHoldWait == 0 then
				p2.holdBonus()
			end
		else
			follower._tcHoldFailed = true
		end

		if follower._tcHoldEnded or not (follower._tcHoldWait == 0 or follower._tcHoldFailed) then
			continue
		end

		follower._tcHoldEnded = true
		p2.perf("HoldEnd", follower, nil)
	end
end

function TouchChart:OnSkipped()
	local followers = self._followers

	if not followers then
		return 0
	end

	local count = 0

	for _, follower in ipairs(followers) do
		if follower._judged then
			continue
		end

		follower._judged = true
		follower._skipped = true
		count += 1
	end

	return count
end

return TouchChart