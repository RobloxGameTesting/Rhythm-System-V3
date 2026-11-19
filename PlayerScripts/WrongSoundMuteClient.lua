local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SettingsState = require(ReplicatedStorage.Modules.SettingsState)

local function tryMute(sound)
	if not (sound:IsA("Sound") and sound.Name:sub(1, 11) == "WrongSound_") then
		return
	end

	if not SettingsState.GetWrongSoundEnabled() then
		sound.Volume = 0
	end
end

game.DescendantAdded:Connect(tryMute)