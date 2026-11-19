local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ThemeState = require(ReplicatedStorage.Modules.ThemeState)
local ThemePreferenceRemotes = require(ReplicatedStorage.Modules.ThemeSystem.ThemePreferenceRemotes)

local flag = false
local child = nil
local ThemePreferenceClient = {}

function ThemePreferenceClient.Init()
	if flag then
		return
	end

	flag = true

	local child2 = ReplicatedStorage:WaitForChild(ThemePreferenceRemotes.FolderName)
	child = child2:WaitForChild(ThemePreferenceRemotes.SetThemePreference)
	child2:WaitForChild(ThemePreferenceRemotes.ThemePreferenceLoaded).OnClientEvent:Connect(function(p)
		ThemeState.Set(p)
	end)
end

function ThemePreferenceClient.SetAndPersist(p)
	ThemeState.Set(p)

	if child then
		child:FireServer(p)
	else
		warn("[ThemePreferenceClient] SetAndPersist dipanggil sebelum Init() -- perubahan TIDAK tersimpan ke server.")
	end
end

return ThemePreferenceClient