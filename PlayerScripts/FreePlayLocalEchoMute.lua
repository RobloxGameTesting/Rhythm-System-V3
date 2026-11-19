local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local function tryMute(sound)
	if not sound:IsA("Sound") then
		return
	end

	if sound:GetAttribute("FreePlayPresserUserId") == LocalPlayer.UserId then
		sound.Volume = 0

		sound:GetPropertyChangedSignal("Volume"):Connect(function()
			if sound.Volume ~= 0 then
				sound.Volume = 0
			end
		end)
	end
end

for _, descendant in ipairs(Workspace:GetDescendants()) do
	tryMute(descendant)
end

Workspace.DescendantAdded:Connect(tryMute)