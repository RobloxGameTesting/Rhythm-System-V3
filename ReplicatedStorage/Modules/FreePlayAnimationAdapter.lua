local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ScreenShake = require(ReplicatedStorage.Modules.ScreenShake)

local v = nil
local lastTime = -1000000000

local v2 = {}
local function lazyRequire(p, fn)
	local v3 = v2[p]

	if v3 ~= nil then
		return v3 or nil
	end

	local success, result = pcall(function()
		return require(fn())
	end)
	v3 = success and result or false
	v2[p] = v3

	if not success then
		warn("[FreePlayAnimationAdapter] gagal memuat " .. p .. ":", result)
	end

	return v3 or nil
end

local function getDrumAnimator()
	return lazyRequire("DrumAnimator", function()
		return ReplicatedStorage.Modules.DrumAnimator
	end)
end

local function getController()
	return lazyRequire("FreePlayController", function()
		return ReplicatedStorage.Modules.FreePlayController
	end)
end

local function getProfileRegistry()
	return lazyRequire("FreePlayProfileRegistry", function()
		return ReplicatedStorage.Modules.FreePlayProfileRegistry
	end)
end

local FreePlayAnimationAdapter = {}

function FreePlayAnimationAdapter.ConsumeLastHand()
	local v3 = v
	local v4 = os.clock() - lastTime <= 0.25
	v = nil
	return if v4 then v3 else nil
end

local v3 = { GuitarLead = true, GuitarRhythm = true, Bass = true }

local function getGuitarAnimator()
	return lazyRequire("GuitarAnimator", function()
		return ReplicatedStorage.Modules.GuitarAnimator
	end)
end

local function getPianoAnimator()
	return lazyRequire("PianoAnimator", function()
		return ReplicatedStorage.Modules.PianoAnimator
	end)
end

local function playFretted(p, p2, p3)
	local v4 = lazyRequire("FreePlayProfileRegistry", function()
		return ReplicatedStorage.Modules.FreePlayProfileRegistry
	end)

	local v5 = v4 and v4.Get(p)
	local laneAction = v5 and v5:GetLaneAction(p2)
	local v6 = lazyRequire("GuitarAnimator", function()
		return ReplicatedStorage.Modules.GuitarAnimator
	end)

	if not (v6 and laneAction and laneAction.String and laneAction.Fret) then
		return
	end

	local v7

	if not p3 then
		v7 = "L" .. p2 or nil
	end

	local success, result = pcall(v6.PlayFreePlayNote, Players.LocalPlayer, laneAction.String, laneAction.Fret, v7)

	if not success then
		warn("[FreePlayAnimationAdapter] PlayFreePlayNote gagal:", result)
	end
end

function FreePlayAnimationAdapter.PlayLane(_, p)
	v = nil
	local v4 = lazyRequire("FreePlayController", function()
		return ReplicatedStorage.Modules.FreePlayController
	end)

	if v4 and v4.GetCurrentInstrumentType() == "Drum" then
		local v5 = lazyRequire("DrumAnimator", function()
			return ReplicatedStorage.Modules.DrumAnimator
		end)

		local v6 = lazyRequire("FreePlayProfileRegistry", function()
			return ReplicatedStorage.Modules.FreePlayProfileRegistry
		end)

		local drum = v6 and v6.Get("Drum")
		local laneAction = drum and drum:GetLaneAction(p)

		if v5 and laneAction and laneAction.Pad then
			local success, result = pcall(v5.PlayFreePlayHit, Players.LocalPlayer, laneAction.Pad)

			if success then
				if result then
					v = result
					lastTime = os.clock()
					return
				end
			else
				warn("[FreePlayAnimationAdapter] PlayFreePlayHit gagal:", result)
			end

			return
		end
	end

	local v5 = v4 and v4.GetCurrentInstrumentType()

	if v5 and v3[v5] then
		playFretted(v5, p, false)
	else
		local v6 = v5 == "Piano" and lazyRequire("PianoAnimator", function()
			return ReplicatedStorage.Modules.PianoAnimator
		end)

		if v6 then
			local success, result = pcall(v6.PlayFreePlayKey, Players.LocalPlayer, p, "L" .. p)

			if not success then
				warn("[FreePlayAnimationAdapter] PlayFreePlayKey gagal:", result)
			end
		end
	end

	ScreenShake.Add(ScreenShake.INTENSITY_LIGHT)
end

function FreePlayAnimationAdapter.ReleaseLane(_, p)
	local v4 = lazyRequire("FreePlayController", function()
		return ReplicatedStorage.Modules.FreePlayController
	end)

	local v5 = v4 and v4.GetCurrentInstrumentType()

	if v5 and v3[v5] then
		local v6 = lazyRequire("GuitarAnimator", function()
			return ReplicatedStorage.Modules.GuitarAnimator
		end)

		if v6 then
			pcall(v6.ReleaseFreePlayNote, Players.LocalPlayer, "L" .. p)
		end
	else
		local v6 = v5 == "Piano" and lazyRequire("PianoAnimator", function()
			return ReplicatedStorage.Modules.PianoAnimator
		end)

		if v6 then
			pcall(v6.ReleaseFreePlayKey, Players.LocalPlayer, "L" .. p)
		end
	end
end

function FreePlayAnimationAdapter.PlayTremoloPick(_, p)
	local v4 = lazyRequire("FreePlayController", function()
		return ReplicatedStorage.Modules.FreePlayController
	end)

	local v5 = v4 and v4.GetCurrentInstrumentType()

	if v5 and v3[v5] then
		playFretted(v5, p, true)
	end
end

return FreePlayAnimationAdapter