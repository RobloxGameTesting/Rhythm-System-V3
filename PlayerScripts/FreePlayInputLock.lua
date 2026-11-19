local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")

local ModeManager = require(ReplicatedStorage.Modules.ModeManager)
local InstrumentConfig = require(ReplicatedStorage.Modules.InstrumentConfig)

local instrumentHUDUpdate = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InstrumentHUDUpdate")

local LocalPlayer = Players.LocalPlayer

local walkSpeed = nil
local flag = false

local function getHumanoid() -- 2 equivalent calls inferred from this helper
	local character = LocalPlayer.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

local v = { Enum.KeyCode.I, Enum.KeyCode.O }

local function sinkHandler()
	return Enum.ContextActionResult.Sink
end

local flag2 = false

local function lockCameraZoomKeys() -- 1 equivalent call inferred from this helper
	if flag2 then
		return
	end

	flag2 = true
	ContextActionService:BindActionAtPriority(
		"FreePlayInputLock_CameraZoomSink",
		sinkHandler,
		false,
		Enum.ContextActionPriority.High.Value + 1,
		table.unpack(v)
	)
end

local function unlockCameraZoomKeys() -- 2 equivalent calls inferred from this helper
	if not flag2 then
		return
	end

	flag2 = false
	ContextActionService:UnbindAction("FreePlayInputLock_CameraZoomSink")
end

local function lockShiftLock()
	pcall(function()
		StarterPlayer.EnableMouseLockOption = false
	end)
end

local function unlockShiftLock()
	pcall(function()
		StarterPlayer.EnableMouseLockOption = false
	end)
end

local function getMouseLockBoundKeysValue()
	local success, result = pcall(function()
		return LocalPlayer.PlayerScripts.PlayerModule.CameraModule.MouseLockController.BoundKeys
	end)
	return if success then result else nil
end

local function lockShiftLockBoundKeys()
	local success, result = pcall(function()
		return LocalPlayer.PlayerScripts.PlayerModule.CameraModule.MouseLockController.BoundKeys
	end)

	if not success then
		result = nil
	end

	if result then
		pcall(function()
			result.Value = ""
		end)
	end
end

local function unlockShiftLockBoundKeys()
	local success, result = pcall(function()
		return LocalPlayer.PlayerScripts.PlayerModule.CameraModule.MouseLockController.BoundKeys
	end)

	if not success then
		result = nil
	end

	if result then
		pcall(function()
			result.Value = ""
		end)
	end
end

local v2 = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.RightShift and v2 then
		ModeManager.Toggle()
	end
end)

local function lockEmoteWheel()
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
	end)
end

local function unlockEmoteWheel()
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
	end)
end

local function getChatInputBarConfig() -- 5 equivalent calls inferred from this helper
	local TextChatService = game:GetService("TextChatService")
	return TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")
end

local function lockChat()
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	end)
	local chatInputBarConfig = getChatInputBarConfig() -- inferred equivalent call

	if chatInputBarConfig then
		chatInputBarConfig.Enabled = false
	end
end

local function unlockChat()
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	end)
	local chatInputBarConfig = getChatInputBarConfig() -- inferred equivalent call

	if chatInputBarConfig then
		chatInputBarConfig.Enabled = true
	end
end

local function lockMovement() -- 1 equivalent call inferred from this helper
	if flag then
		return
	end

	local humanoid = getHumanoid() -- inferred equivalent call

	if not humanoid then
		return
	end

	flag = true
	walkSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = 0
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
end

local function unlockMovement() -- 2 equivalent calls inferred from this helper
	if not flag then
		return
	end

	flag = false
	local humanoid = getHumanoid() -- inferred equivalent call

	if humanoid then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)

		if v2 and walkSpeed then
			humanoid.WalkSpeed = walkSpeed
		elseif not v2 then
			humanoid.WalkSpeed = InstrumentConfig.NormalWalkSpeed
		end
	end

	walkSpeed = nil
end

instrumentHUDUpdate.OnClientEvent:Connect(function(p)
	v2 = p

	local function fn()
		return LocalPlayer.PlayerScripts.PlayerModule.CameraModule.MouseLockController.BoundKeys
	end

	if p then
		pcall(function()
			StarterPlayer.EnableMouseLockOption = false
		end)

		local success, result = pcall(fn)

		if not success then
			result = nil
		end

		if result then
			pcall(function()
				result.Value = ""
			end)
		end
	else
		unlockMovement() -- inferred equivalent call
		unlockCameraZoomKeys() -- inferred equivalent call
		pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
		end)

		pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
		end)
		local chatInputBarConfig = getChatInputBarConfig() -- inferred equivalent call

		if chatInputBarConfig then
			chatInputBarConfig.Enabled = true
		end

		pcall(function()
			StarterPlayer.EnableMouseLockOption = false
		end)

		local success, result = pcall(fn)

		if not success then
			result = nil
		end

		if result then
			pcall(function()
				result.Value = ""
			end)
		end
	end
end)

local clone = nil

task.spawn(function()
	for _ = 1, 100 do
		local freecam = LocalPlayer.PlayerGui:FindFirstChild("Freecam")

		if freecam then
			clone = freecam:Clone()
			break
		end

		task.wait(0.1)
	end
end)

local function lockFreecam()
	local freecam = LocalPlayer.PlayerGui:FindFirstChild("Freecam")

	if freecam then
		freecam:Destroy()
	end

	pcall(function()
		ContextActionService:UnbindAction("FreecamToggle")
	end)
end

local function unlockFreecam() -- 1 equivalent call inferred from this helper
	if LocalPlayer.PlayerGui:FindFirstChild("Freecam") then
		return
	end

	if clone then
		local clone_2 = clone:Clone()
		clone_2.Parent = LocalPlayer.PlayerGui
	end
end

ModeManager.OnChanged(function(p)
	if p == ModeManager.FreePlay then
		lockMovement() -- inferred equivalent call
		lockCameraZoomKeys() -- inferred equivalent call
		pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
		end)

		pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
		end)
		local chatInputBarConfig = getChatInputBarConfig() -- inferred equivalent call

		if chatInputBarConfig then
			chatInputBarConfig.Enabled = false
		end

		local freecam = LocalPlayer.PlayerGui:FindFirstChild("Freecam")

		if freecam then
			freecam:Destroy()
		end

		pcall(function()
			ContextActionService:UnbindAction("FreecamToggle")
		end)
	else
		unlockMovement() -- inferred equivalent call
		unlockCameraZoomKeys() -- inferred equivalent call
		pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
		end)

		pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
		end)
		local chatInputBarConfig = getChatInputBarConfig() -- inferred equivalent call

		if chatInputBarConfig then
			chatInputBarConfig.Enabled = true
		end

		unlockFreecam() -- inferred equivalent call
	end
end)