local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local reportDevice = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ReportDevice")

local function detectDevice(): string
	if UserInputService.VREnabled then
		return "VR"
	end

	local success, result = pcall(function()
		return GuiService:IsTenFootInterface()
	end)

	if success and result then
		return "Console"
	end

	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		return "Mobile"
	end

	if UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
		return "Console"
	end

	return "Desktop"
end

local flag = false
reportDevice.OnClientEvent:Connect(function()
	flag = true
end)

local v = detectDevice()

for i = 1, 20 do
	if flag then
		break
	end

	reportDevice:FireServer(v)
	task.wait(i <= 6 and 1 or 3)
end