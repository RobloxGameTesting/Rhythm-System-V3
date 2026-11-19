local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ThemeSwitchToast = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ThemeSwitchToast"))
local soundAdjustNotify = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SoundAdjustNotify")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local soundAdjustToastGui = Instance.new("ScreenGui")
soundAdjustToastGui.Name = "SoundAdjustToastGui"
soundAdjustToastGui.ResetOnSpawn = false
soundAdjustToastGui.IgnoreGuiInset = true
soundAdjustToastGui.DisplayOrder = 95
soundAdjustToastGui.Parent = PlayerGui

local v = ThemeSwitchToast.new(soundAdjustToastGui)

soundAdjustNotify.OnClientEvent:Connect(function(value, value2, value3)
	if type(value) ~= "string" or type(value2) ~= "string" then
		return
	end

	local v2 = string.sub(value2, 1, 30)
	local v3

	if value == "reset" then
		v3 = "Sound reset to default by " .. v2
	elseif value == "preset" and type(value3) == "string" then
		v3 = string.format("Sound preset: %s (by %s)", string.sub(value3, 1, 24), v2)
	else
		v3 = "Sound adjusted by " .. v2
	end

	v:Show(v3)
end)