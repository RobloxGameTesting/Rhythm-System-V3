local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SettingsState = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SettingsState"))
local HudOpacity = {}

function HudOpacity.Get(p)
	return SettingsState.GetOpacity(p)
end

function HudOpacity.GetContent(p)
	return SettingsState.GetContentOpacity(p)
end

function HudOpacity.Apply(p, p2)
	return 1 - (1 - p) * SettingsState.GetOpacity(p2)
end

return HudOpacity