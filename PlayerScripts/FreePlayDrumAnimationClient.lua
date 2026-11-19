local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local DrumAnimator = require(Modules:WaitForChild("DrumAnimator"))
local ModeManager = require(Modules:WaitForChild("ModeManager"))
local FreePlayController = require(Modules:WaitForChild("FreePlayController"))
local FreePlaySyncState = require(Modules:WaitForChild("FreePlaySyncState"))
local freePlayReplication = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("FreePlayReplication")

local LocalPlayer = Players.LocalPlayer

local function isSeatedAtKit(player): boolean -- 1 equivalent call inferred from this helper
	return DrumAnimator.ResolveInstrumentInstance(player) ~= nil
end

local function evaluatePlayer(localPlayer)
	local character = localPlayer.Character

	if not character then
		return
	end

	local v

	if localPlayer == LocalPlayer then
		v = ModeManager.IsFreePlay() and FreePlayController.GetCurrentInstrumentType() == "Drum"
	else
		v = localPlayer:GetAttribute("FPDrumMode") == true
	end

	local setFreePlayDrumMode = DrumAnimator.SetFreePlayDrumMode
	local v2

	if v then
		v2 = isSeatedAtKit(localPlayer) or false -- inferred equivalent call
	else
		v2 = false
	end

	setFreePlayDrumMode(character, v2)
end

ModeManager.OnChanged(function(p)
	freePlayReplication:FireServer("Mode", p == ModeManager.FreePlay)
	evaluatePlayer(LocalPlayer)
end)

if ModeManager.IsFreePlay() then
	freePlayReplication:FireServer("Mode", true)
end

task.spawn(function()
	while true do
		for _, v in ipairs(Players:GetPlayers()) do
			local success, result = pcall(evaluatePlayer, v)

			if not success then
				warn("[FreePlayDrumAnimationClient] evaluatePlayer gagal:", result)
			end
		end

		task.wait(0.2)
	end
end)

local function withinVisualRange(character): boolean -- 2 equivalent calls inferred from this helper
	local currentCamera = Workspace.CurrentCamera
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if currentCamera and humanoidRootPart then
		return (currentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude <= 200
	end

	return true
end

local function handleReplicatedSound(sound)
	if sound:GetAttribute("FPMirror") then
		return
	end

	local fpPad = sound:GetAttribute("FPPad")

	if type(fpPad) ~= "string" then
		return
	end

	local freePlayPresserUserId = sound:GetAttribute("FreePlayPresserUserId")

	if freePlayPresserUserId == nil or freePlayPresserUserId == LocalPlayer.UserId then
		return
	end

	local playerByUserId = Players:GetPlayerByUserId(freePlayPresserUserId)

	if not playerByUserId then
		return
	end

	local fpHand = sound:GetAttribute("FPHand")
	local v = 0

	if FreePlaySyncState.IsEnabled() then
		local fpPressTime = sound:GetAttribute("FPPressTime")

		if type(fpPressTime) == "number" then
			local delaySeconds = FreePlaySyncState.GetDelaySeconds()
			v = math.clamp(fpPressTime + delaySeconds - Workspace:GetServerTimeNow(), 0, delaySeconds + 0.25)
		end
	end

	local function fire() -- 1 equivalent call inferred from this helper
		local character = playerByUserId.Character

		if character and withinVisualRange(character) then -- inferred equivalent call
			local success, result = pcall(DrumAnimator.PlayFreePlayHit, playerByUserId, fpPad, fpHand)

			if not success then
				warn("[FreePlayDrumAnimationClient] PlayFreePlayHit gagal:", result)
			end
		end
	end

	if v > 0.004 then
		task.delay(v, fire)
		return
	end

	fire() -- inferred equivalent call
end

Workspace.DescendantAdded:Connect(function(sound)
	if sound:IsA("Sound") then
		handleReplicatedSound(sound)
	end
end)

local InputRouter = require(Modules:WaitForChild("InputRouter"))

InputRouter.OnMuteEvent(function()
	if FreePlayController.GetCurrentInstrumentType() == "Drum" then
		pcall(DrumAnimator.ChokeCymbals, LocalPlayer)
	end
end)

local function watchChoke(player) -- 1 equivalent call inferred from this helper
	if player == LocalPlayer then
		return
	end

	player:GetAttributeChangedSignal("FPChokeSeq"):Connect(function()
		local character = player.Character

		if character and withinVisualRange(character) then -- inferred equivalent call
			pcall(DrumAnimator.ChokeCymbals, player)
		end
	end)
end

for _, v in ipairs(Players:GetPlayers()) do
	watchChoke(v) -- inferred equivalent call
end

Players.PlayerAdded:Connect(watchChoke)