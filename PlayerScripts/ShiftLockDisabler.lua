local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")

local LocalPlayer = Players.LocalPlayer

pcall(function()
	if StarterPlayer.EnableMouseLockOption then
		StarterPlayer.EnableMouseLockOption = false
	end
end)

local function findBoundKeys()
	local success, result = pcall(function()
		local playerScripts = LocalPlayer:WaitForChild("PlayerScripts", 30)
		local playerModule = playerScripts and playerScripts:WaitForChild("PlayerModule", 30)
		local cameraModule = playerModule and playerModule:WaitForChild("CameraModule", 30)
		local mouseLockController = cameraModule and cameraModule:WaitForChild("MouseLockController", 30)
		return mouseLockController and mouseLockController:WaitForChild("BoundKeys", 30)
	end)

	return success and result or nil
end

local success, result = pcall(function()
	local playerScripts = LocalPlayer:WaitForChild("PlayerScripts", 30)
	local playerModule = playerScripts and playerScripts:WaitForChild("PlayerModule", 30)
	local cameraModule = playerModule and playerModule:WaitForChild("CameraModule", 30)
	local mouseLockController = cameraModule and cameraModule:WaitForChild("MouseLockController", 30)
	return mouseLockController and mouseLockController:WaitForChild("BoundKeys", 30)
end)
local v = success and result or nil

if not v then
	warn("[ShiftLockDisabler] BoundKeys tidak ditemukan; hanya EnableMouseLockOption=false yang aktif")

	return
end

local function blank()
	if v.Value ~= "" then
		pcall(function()
			v.Value = ""
		end)
	end
end

if v.Value ~= "" then
	pcall(function()
		v.Value = ""
	end)
end

v:GetPropertyChangedSignal("Value"):Connect(blank)