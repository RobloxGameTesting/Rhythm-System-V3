local success, result = pcall(function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DrumStrokeSolver"))
end)

if not success then
	warn("[DrumSolverBootstrap] " .. tostring(result))
end