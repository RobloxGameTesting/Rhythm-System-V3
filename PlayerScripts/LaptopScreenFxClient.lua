local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LaptopScreenFx = require(ReplicatedStorage.Modules:WaitForChild("LaptopUI"):WaitForChild("LaptopScreenFx"))
local Map = Workspace:WaitForChild("Map")

local function consider(surfaceGui) -- 1 equivalent call inferred from this helper
	if surfaceGui:IsA("SurfaceGui") and surfaceGui.Name == "LaptopScreen" then
		LaptopScreenFx.Attach(surfaceGui)
	end
end

for _, descendant in ipairs(Map:GetDescendants()) do
	consider(descendant) -- inferred equivalent call
end

Map.DescendantAdded:Connect(consider)