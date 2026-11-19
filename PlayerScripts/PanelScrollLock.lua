local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local success, result = pcall(function()
	return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SessionCameraSettings"))
end)

if not success then
	warn("[PanelScrollLock] SessionCameraSettings tidak bisa dimuat: " .. tostring(result))
	return
end

local v = {
	{ Gui = "ServerBrowserUI", Child = "Overlay" },
	{ Gui = "MicSettingsUI" },
	{ Gui = "NewbieModePanelScreenGui" },
	{ Gui = "AudioCalibrateUI" },
	{ Gui = "DrumTuneUI" },
	{ Gui = "PianoTuneUI" },
	{ Gui = "PStudioUI", Child = "Panel" },
	{ Gui = "PStudioManagerGui", Child = "Window" },
	{ Gui = "BandGui", Child = "Root" }
}

local v2 = false

local function isPanelShown(p)
	local screenGui = PlayerGui:FindFirstChild(p.Gui)

	if not (screenGui and screenGui:IsA("ScreenGui") and screenGui.Enabled) then
		return false
	end

	if not p.Child then
		return true
	end

	local guiObject = screenGui:FindFirstChild(p.Child)
	return guiObject ~= nil and guiObject:IsA("GuiObject") and guiObject.Visible
end

local function step()
	local v3 = false

	for _, v4 in ipairs(v) do
		if isPanelShown(v4) then
			v3 = true
			break
		end
	end

	if v3 ~= v2 then
		v2 = v3
		result.SetScrollBlocked(v3)
	end
end

RunService:BindToRenderStep("PanelScrollLock", Enum.RenderPriority.First.Value - 1, step)