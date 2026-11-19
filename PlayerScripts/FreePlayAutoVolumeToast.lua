local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ModeManager = require(Modules:WaitForChild("ModeManager"))
local FreePlayAutoVolume = require(Modules:WaitForChild("FreePlayAutoVolume"))
local ThemeSwitchToast = require(Modules:WaitForChild("ThemeSwitchToast"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local attribute = FreePlayAutoVolume.ATTRIBUTE

local freePlayAutoVolumeToastGui = Instance.new("ScreenGui")
freePlayAutoVolumeToastGui.Name = "FreePlayAutoVolumeToastGui"
freePlayAutoVolumeToastGui.ResetOnSpawn = false
freePlayAutoVolumeToastGui.IgnoreGuiInset = true
freePlayAutoVolumeToastGui.DisplayOrder = 95
freePlayAutoVolumeToastGui.Parent = PlayerGui

local v = ThemeSwitchToast.new(freePlayAutoVolumeToastGui)

local v2 = false
local lastTime = -1e999

local function evaluate()
	local v3

	if typeof((LocalPlayer:GetAttribute(attribute))) == "number" then
		v3 = ModeManager.IsFreePlay()
	else
		v3 = false
	end

	if v3 and not v2 then
		v2 = true

		if os.clock() - lastTime >= 8 then
			lastTime = os.clock()
			v:Show("Auto volume ON - amp volume follows the song mix")
		end
	elseif not v3 then
		v2 = false
	end
end

LocalPlayer:GetAttributeChangedSignal(attribute):Connect(evaluate)
ModeManager.OnChanged(evaluate)
evaluate()