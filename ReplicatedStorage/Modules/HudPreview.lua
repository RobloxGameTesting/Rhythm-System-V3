local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local parent = script.Parent
local ColorsPreview = require(parent:WaitForChild("ColorsPreview"))
local NoteLaneUI = require(parent:WaitForChild("NoteLaneUI"))
local RockMeterUI = require(parent:WaitForChild("RockMeterUI"))
local ScoreDisplayUI = require(parent:WaitForChild("ScoreDisplayUI"))
local StarPowerUI = require(parent:WaitForChild("StarPowerUI"))
local BandScoreUI = require(parent:WaitForChild("BandScoreUI"))
local RhythmEngineConfig = require(parent:WaitForChild("RhythmEngineConfig"))

local v = {}
local HudPreview = {}

for _, v2 in ipairs({
	{ "Perfect", 12 },
	{ "Great", 4 },
	{ "Good", 2 },
	{ "Miss", 12 },
	{ "Perfect", 8 },
	{ "Great", 4 },
	{ "OK", 2 }
}) do
	for _ = 1, v2[2] do
		v[#v + 1] = v2[1]
	end
end

local flag = false
local flag2 = false
local heartbeatConnection = nil
local v2 = {}

local lastTime = 0
local total = 0
local v3 = 0
local v4 = 0
local v5 = 0
local count = 0
local count2 = 0
local total2 = 0
local v6 = false
local v7 = { nil, nil }
v7[1], v7[2] = 0, 0

local function playerGui() -- 2 equivalent calls inferred from this helper
	local localPlayer = Players.LocalPlayer
	return localPlayer and localPlayer:FindFirstChild("PlayerGui")
end

local function buildPayload(p)
	local localPlayer = Players.LocalPlayer
	local userId = localPlayer and localPlayer.UserId or 1
	local ht = math.sin(p / 5.5) * 0.3 + 0.62
	local gr

	if ht > 0.88 then
		gr = "S"
	elseif ht > 0.74 then
		gr = "A"
	else
		gr = if ht > 0.56 then "B" else "C"
	end

	return {
		p = {
			{
				u = userId,
				n = localPlayer and localPlayer.DisplayName or "You",
				i = "GuitarRhythm",
				s = total2,
				c = count2,
				a = 96.4,
				d = "Normal",
				k = 5,
				mv = 1,
				au = 0
			},
			{
				u = -101,
				n = "Alex",
				i = "Bass",
				s = v7[1],
				c = math.floor(count2 * 0.7),
				a = 92.1,
				d = "Medium",
				k = 5,
				mv = 0,
				au = 0
			},
			{
				u = -102,
				n = "Sam",
				i = "Drum",
				s = v7[2],
				c = math.floor(count2 * 0.5),
				a = 88.7,
				d = "Easy",
				k = 2,
				mv = 0,
				au = 0
			}
		},
		band = {
			sc = total2 + v7[1] + v7[2],
			ht = ht,
			gr = gr
		}
	}
end

local function step()
	if not flag then
		return
	end

	local v8 = os.clock() - lastTime

	while total <= v8 do
		total += 0.45
		count += 1
		local v9 = v[(count - 1) % #v + 1]

		if v9 == "Miss" or v9 == "Wrong" then
			count2 = 0
		else
			count2 += 1
			total2 += math.min(4, math.floor(count2 / 10) + 1) * 100
			v7[1] += 85
			v7[2] += 70
		end

		pcall(RockMeterUI.OnJudgment, v9, false)
		pcall(ScoreDisplayUI.SetState, total2, count2)
	end

	local v9 = v8 % 16 / 16
	local v10 = 0.05 + 0.95 * (v9 < 0.5 and v9 * 2 or (1 - v9) * 2)
	pcall(StarPowerUI.SetMeter, v10, 0.5)

	if v3 <= v8 then
		v3 = v8 + 0.5
		pcall(BandScoreUI.SetPayload, buildPayload(v8), Players.LocalPlayer and Players.LocalPlayer.UserId or nil)
	end

	if v4 <= v8 then
		v4 = v8 + 4.5
		local localPlayer = Players.LocalPlayer

		if v6 then
			pcall(BandScoreUI.PushFeed, "Alex", 100, false, -101)
		else
			pcall(BandScoreUI.PushFeed, "YOU", math.max(count2, 50), true, localPlayer and localPlayer.UserId or nil)
		end

		v6 = not v6
	end

	if v5 <= v8 then
		v5 = v8 + 9

		if math.floor(v8 / 9) % 2 == 0 then
			pcall(NoteLaneUI.ShowStreakNotice, "Streak", 50)
		else
			pcall(NoteLaneUI.ShowStreakNotice, "StarPower")
		end
	end
end

function HudPreview.IsActive()
	return flag
end

function HudPreview.CanStart()
	return flag or ColorsPreview.CanStart()
end

function HudPreview.Start(): boolean
	if flag then
		return true
	end

	if not (ColorsPreview.CanStart() and ColorsPreview.Start(5, NoteLaneUI)) then
		return false
	end

	flag2 = true
	flag = true
	local v8 = playerGui() -- inferred equivalent call

	if v8 then
		v8:SetAttribute("HudPreviewActive", true)
	end

	count = 0
	count2 = 0
	total2 = 0
	v7 = { 0, 0 }
	v6 = false
	lastTime = os.clock()
	total = 0
	v3 = 0
	v4 = 1
	v5 = 2.5

	pcall(RockMeterUI.Reset)
	pcall(ScoreDisplayUI.Reset)
	pcall(function()
		local v9 = NoteLaneUI.GetTrackWidth and NoteLaneUI.GetTrackWidth(5) or nil
		local v10 = NoteLaneUI.GetTrackHeight and NoteLaneUI.GetTrackHeight() or nil
		StarPowerUI.Show(v9, v10, RhythmEngineConfig.StarPowerThresholds, nil, nil)
		StarPowerUI.SetMeter(0.05, 0.5)
	end)
	pcall(BandScoreUI.Show, "bar")

	heartbeatConnection = RunService.Heartbeat:Connect(step)
	return true
end

function HudPreview.Stop()
	if not flag then
		return
	end

	flag = false

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	pcall(StarPowerUI.SetMeter, 0, 0.5)
	pcall(StarPowerUI.Hide)
	pcall(BandScoreUI.Hide)
	pcall(RockMeterUI.Reset)
	pcall(ScoreDisplayUI.Reset)
	local v8 = playerGui() -- inferred equivalent call

	if v8 then
		v8:SetAttribute("HudPreviewActive", nil)
	end

	if flag2 then
		flag2 = false
		ColorsPreview.Stop()
	end

	for _, callback in ipairs(v2) do
		task.spawn(callback)
	end
end

function HudPreview.OnStopped(p)
	table.insert(v2, p)
end

ColorsPreview.OnStopped(function()
	if flag then
		HudPreview.Stop()
	end
end)

return HudPreview