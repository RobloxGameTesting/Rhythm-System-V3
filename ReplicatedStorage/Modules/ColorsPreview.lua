local RunService = game:GetService("RunService")

local ColorsPreview = {}

local v = { "Perfect", "Great", "Good", "OK", "Miss", "Wrong" }

local flag = false
local v2 = nil
local v3 = nil
local connection = nil
local lastTime = 0
local v4 = {}
local v5 = 1
local v6 = {}
local v7 = {}
local count = 0
local v8 = {}
local v9 = {}
local v10 = {}

local function pickRenderer() -- 1 equivalent call inferred from this helper
	local ThemeState = require(script.Parent.ThemeState)

	if ThemeState.Get() == "3D" then
		return require(script.Parent.NoteLaneUI3D)
	end

	return require(script.Parent.NoteLaneUI)
end

local function layoutFor(p)
	local SettingsState = require(script.Parent.SettingsState)
	local RhythmEngineConfig = require(script.Parent.RhythmEngineConfig)

	if p == 2 then
		return "GuitarLead", SettingsState.GetKeybindTwoKey(), RhythmEngineConfig.TwoKeyLaneNames
	elseif p == 3 then
		return "GuitarLead", RhythmEngineConfig.GetNewbieKeybinds(3), RhythmEngineConfig.NewbieLaneNames[3]
	elseif p == 4 then
		return "Bass", SettingsState.GetKeybindFiveKey(), nil
	end

	return "GuitarLead", SettingsState.GetKeybindFiveKey(), nil
end

local function showTrack() -- 3 equivalent calls inferred from this helper
	local v11, v12, v13 = layoutFor(v2)
	v3.Show(v11, v2, v12, v13, nil)
end

local v11 = nil
local flag2 = false
local v12 = false

local function currentLayoutSignature()
	local SettingsState = require(script.Parent.SettingsState)
	local buttonGroupOffset = SettingsState.GetButtonGroupOffset()
	return string.format(
		"%.3f|%.3f|%.1f|%.1f|%.1f",
		SettingsState.GetButtonWidthMultiplier(),
		SettingsState.GetButtonHeightMultiplier(),
		SettingsState.GetButtonSpacingExtra(),
		buttonGroupOffset.X,
		buttonGroupOffset.Y
	)
end

local function hookLayoutChanges() -- 1 equivalent call inferred from this helper
	if flag2 then
		return
	end

	flag2 = true
	local SettingsState = require(script.Parent.SettingsState)
	SettingsState.OnChanged(function()
		if not flag or v12 or currentLayoutSignature() == v11 then
			return
		end

		v12 = true
		task.delay(0.08, function()
			v12 = false

			if flag and v3 and v3.IsVisible() then
				v11 = currentLayoutSignature()
				showTrack() -- inferred equivalent call
			end
		end)
	end)
end

local function resetPattern()
	v4 = {}
	v5 = 1
	v6 = {}
	v7 = {}
	count = 0
	v8 = {}
	v9 = {}
	lastTime = os.clock()
end

local function laneForBeat(p, p2) -- 1 equivalent call inferred from this helper
	if p2 <= 1 then
		return 1
	end

	local v13 = (p2 - 1) * 2
	local v14 = p % v13

	if v14 < p2 then
		return v14 + 1
	end

	return v13 - v14 + 1
end

local function generateUpTo(p)
	local v13 = v2

	while v5 * 0.5 <= p do
		local v14 = v5
		local time = v14 * 0.5

		if v14 % 8 == 6 then
			local lane = math.floor(v14 / 8) % v13 + 1
			table.insert(v4, { Time = time, Lane = lane, Duration = 1, Judgment = "Perfect" })
			v6[lane] = time + 1 + 0.5
		else
			local lane = laneForBeat(v14 - 1, v13) -- inferred equivalent call
			local v15 = v6[lane]

			if not (v15 and time <= v15) then
				local judgment = v[count % #v + 1]
				count += 1

				if judgment == "Wrong" then
					table.insert(v7, { Time = time, Lane = lane })
				else
					table.insert(v4, { Time = time, Lane = lane, Duration = 0, Judgment = judgment })
				end
			end
		end

		v5 += 1
	end
end

local function stopInternal(p)
	if not flag then
		return
	end

	flag = false

	if connection then
		connection:Disconnect()
		connection = nil
	end

	local v13 = v3
	v3 = nil

	if p and v13 then
		v13.Hide()
	end

	v4 = {}
	v6 = {}
	v7 = {}
	v8 = {}
	v9 = {}

	for _, callback in ipairs(v10) do
		local success, result = pcall(callback)

		if not success then
			warn("[ColorsPreview] listener error:", result)
		end
	end
end

local function step()
	if not flag then
		return
	end

	if not v3.IsVisible() then
		stopInternal(false)
		return
	end

	local v13 = os.clock() - lastTime
	generateUpTo(v13 + 5)

	for _, v14 in ipairs(v4) do
		if v14._judged then
			continue
		end

		if v14.Duration > 0 then
			if v14._holding or not (v14.Time <= v13) then
				if v14._holding and v14.Time + v14.Duration <= v13 then
					v14._holding = false
					v14._judged = true
					v9[v14.Lane] = nil
					v3.SetLanePressed(v14.Lane, false)
				end
			else
				v14._holding = true
				v9[v14.Lane] = true
				v3.SetLanePressed(v14.Lane, true)
				v3.ShowJudgment(v14.Lane, v14.Judgment, false, nil, true)
			end
		elseif v14.Judgment == "Miss" then
			if v14.Time + 0.15 <= v13 then
				v14._judged = true
				v3.ShowJudgment(v14.Lane, "Miss", false, nil, true)
			end
		elseif v14.Time <= v13 then
			v14._judged = true
			v3.SetLanePressed(v14.Lane, true)
			v3.ShowJudgment(v14.Lane, v14.Judgment, false, nil, true)
			v8[v14.Lane] = v13 + 0.12
		end
	end

	local v14 = 1

	while v14 <= #v7 do
		local v15 = v7[v14]

		if v15.Time <= v13 then
			table.remove(v7, v14)

			if not v9[v15.Lane] then
				v3.SetLanePressed(v15.Lane, true)
				v8[v15.Lane] = v13 + 0.12
			end

			v3.ShowJudgment(v15.Lane, "Wrong", false, nil, true)
		else
			v14 += 1
		end
	end

	for k, v15 in pairs(v8) do
		if not (v15 <= v13) then
			continue
		end

		v8[k] = nil

		if not v9[k] then
			v3.SetLanePressed(k, false)
		end
	end

	v3.SyncNotes(v4, v13)
	local v15 = 1

	while v15 <= #v4 do
		if v4[v15]._judged then
			table.remove(v4, v15)
		else
			v15 += 1
		end
	end
end

function ColorsPreview.IsActive()
	return flag
end

function ColorsPreview.CanStart(): boolean
	if flag then
		return true
	end

	local NoteLaneUI = require(script.Parent.NoteLaneUI)
	local NoteLaneUI3D = require(script.Parent.NoteLaneUI3D)
	return not (NoteLaneUI.IsVisible() or NoteLaneUI3D.IsVisible())
end

function ColorsPreview.Start(p, p2): boolean
	if flag then
		return true
	end

	if not (p2 or ColorsPreview.CanStart()) then
		return false
	end

	if not p2 then
		p2 = pickRenderer() -- inferred equivalent call
	end

	v3 = p2
	v2 = p
	resetPattern()
	v11 = currentLayoutSignature()
	hookLayoutChanges() -- inferred equivalent call
	showTrack() -- inferred equivalent call
	flag = true
	local success, result = pcall(function()
		return RunService.RenderStepped:Connect(step)
	end)

	connection = success and result or nil
	return true
end

function ColorsPreview.SetLaneCount(p)
	if not flag or p == v2 then
		return
	end

	v2 = p
	resetPattern()
	showTrack() -- inferred equivalent call
end

function ColorsPreview.Stop()
	stopInternal(true)
end

function ColorsPreview.OnStopped(p)
	table.insert(v10, p)
end

ColorsPreview._Step = step

return ColorsPreview