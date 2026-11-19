local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local GuitarAnimator = require(Modules:WaitForChild("GuitarAnimator"))
local PianoAnimator = require(Modules:WaitForChild("PianoAnimator"))
local ModeManager = require(Modules:WaitForChild("ModeManager"))
local FreePlayController = require(Modules:WaitForChild("FreePlayController"))
local FreePlaySyncState = require(Modules:WaitForChild("FreePlaySyncState"))

local LocalPlayer = Players.LocalPlayer

local v = { GuitarLead = true, GuitarRhythm = true, Bass = true }

local function activeInstrumentFor(player)
	if player == LocalPlayer then
		if not ModeManager.IsFreePlay() then
			return nil
		end

		local currentInstrumentType = FreePlayController.GetCurrentInstrumentType()

		if v[currentInstrumentType] or currentInstrumentType == "Piano" then
			return currentInstrumentType
		end

		return nil
	else
		local fpAnimMode = player:GetAttribute("FPAnimMode")

		if type(fpAnimMode) == "string" and (v[fpAnimMode] or fpAnimMode == "Piano") then
			return fpAnimMode
		end

		return nil
	end
end

local function evaluatePlayer(localPlayer) -- 1 equivalent call inferred from this helper
	local character = localPlayer.Character

	if not character then
		return
	end

	local v2 = activeInstrumentFor(localPlayer)
	GuitarAnimator.SetFreePlayMode(character, v2 ~= nil and v[v2] == true)
	PianoAnimator.SetFreePlayMode(character, v2 == "Piano")
end

ModeManager.OnChanged(function()
	evaluatePlayer(LocalPlayer) -- inferred equivalent call
end)

task.spawn(function()
	while true do
		for _, v2 in ipairs(Players:GetPlayers()) do
			local success, result = pcall(evaluatePlayer, v2)

			if not success then
				warn("[FreePlayInstrumentAnimationClient] evaluatePlayer gagal:", result)
			end
		end

		task.wait(0.2)
	end
end)

local function withinVisualRange(character): boolean -- 1 equivalent call inferred from this helper
	local currentCamera = Workspace.CurrentCamera
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if currentCamera and humanoidRootPart then
		return (currentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude <= 200
	end

	return true
end

local count = 0

local function handleReplicatedSound(sound)
	if sound:GetAttribute("FPMirror") then
		return
	end

	local freePlayPresserUserId = sound:GetAttribute("FreePlayPresserUserId")

	if freePlayPresserUserId == nil or freePlayPresserUserId == LocalPlayer.UserId then
		return
	end

	local fpString = sound:GetAttribute("FPString")
	local fpFret = sound:GetAttribute("FPFret")
	local fpLane = sound:GetAttribute("FPLane")
	local v2

	if type(fpString) == "number" then
		v2 = type(fpFret) == "number"
	else
		v2 = false
	end

	local v3 = not v2 and type(fpLane) == "number"

	if not (v2 or v3) then
		return
	end

	local playerByUserId = Players:GetPlayerByUserId(freePlayPresserUserId)

	if not playerByUserId then
		return
	end

	local v4 = 0

	if FreePlaySyncState.IsEnabled() then
		local fpPressTime = sound:GetAttribute("FPPressTime")

		if type(fpPressTime) == "number" then
			local delaySeconds = FreePlaySyncState.GetDelaySeconds()
			v4 = math.clamp(fpPressTime + delaySeconds - Workspace:GetServerTimeNow(), 0, delaySeconds + 0.25)
		end
	end

	count += 1
	local v5 = "S" .. tostring(freePlayPresserUserId) .. "_" .. tostring(count)
	local fpTremolo = sound:GetAttribute("FPTremolo") == true
	local flag = false
	local flag2 = false

	local function doRelease() -- 1 equivalent call inferred from this helper
		if v2 then
			if not fpTremolo then
				pcall(GuitarAnimator.ReleaseFreePlayNote, playerByUserId, v5)
			end
		else
			pcall(PianoAnimator.ReleaseFreePlayKey, playerByUserId, v5)
		end
	end

	local function fire()
		flag = true
		local character = playerByUserId.Character

		if character and withinVisualRange(character) then -- inferred equivalent call
			local success, result

			if v2 then
				if fpTremolo then
					success, result = pcall(GuitarAnimator.PlayFreePlayNote, playerByUserId, fpString, fpFret, nil, 0.4)
				else
					success, result = pcall(GuitarAnimator.PlayFreePlayNote, playerByUserId, fpString, fpFret, v5)
				end
			else
				success, result = pcall(PianoAnimator.PlayFreePlayKey, playerByUserId, fpLane, v5)
			end

			if not success then
				warn("[FreePlayInstrumentAnimationClient] animasi gagal:", result)
			end

			if flag2 then
				task.delay(0.1, doRelease)
			end
		end
	end

	local function release() -- 2 equivalent calls inferred from this helper
		if flag2 then
			return
		end

		flag2 = true

		if flag then
			doRelease() -- inferred equivalent call
		end
	end

	if v4 > 0.004 then
		task.delay(v4, fire)
	else
		fire()
	end

	if sound:GetAttribute("FPKeyUp") then
		release() -- inferred equivalent call
	else
		sound:GetAttributeChangedSignal("FPKeyUp"):Connect(function()
			if sound:GetAttribute("FPKeyUp") then
				release() -- inferred equivalent call
			end
		end)
	end

	sound.Destroying:Once(release)
	task.delay(12, release)
end

Workspace.DescendantAdded:Connect(function(sound)
	if sound:IsA("Sound") then
		handleReplicatedSound(sound)
	end
end)