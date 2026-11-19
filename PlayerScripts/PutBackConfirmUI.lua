local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PutBackInstrument = RemoteEvents:WaitForChild("PutBackInstrument")
local SongSessionStatusUpdate = RemoteEvents:WaitForChild("SongSessionStatusUpdate")
local InstrumentHUDUpdate = RemoteEvents:WaitForChild("InstrumentHUDUpdate")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local PutBackHoldStart = script.Parent:WaitForChild("PutBackHoldStart")
local PutBackHoldCancel = script.Parent:WaitForChild("PutBackHoldCancel")

local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local v2 = false
local flag = false
local lastTime = nil

local putBackConfirmUI = Instance.new("ScreenGui")
putBackConfirmUI.Name = "PutBackConfirmUI"
putBackConfirmUI.ResetOnSpawn = false
putBackConfirmUI.Parent = PlayerGui

local putBackHint = Instance.new("TextLabel")
putBackHint.Name = "PutBackHint"
putBackHint.AnchorPoint = Vector2.new(0.5, 1)
putBackHint.Position = UDim2.new(0.5, 0, 1, -140)
putBackHint.Size = UDim2.new(0, 300, 0, 20)
putBackHint.BackgroundTransparency = 1
putBackHint.TextColor3 = Color3.fromRGB(255, 120, 120)
putBackHint.Font = Enum.Font.GothamBold
putBackHint.TextSize = 14
putBackHint.Text = v and "Holding Unequip..." or "Hold [Backspace] to leave session..."
putBackHint.Visible = false
putBackHint.Parent = putBackConfirmUI

local putBackProgressBackground = Instance.new("Frame")
putBackProgressBackground.Name = "PutBackProgressBackground"
putBackProgressBackground.AnchorPoint = Vector2.new(0.5, 1)
putBackProgressBackground.Position = UDim2.new(0.5, 0, 1, -125)
putBackProgressBackground.Size = UDim2.new(0, 300, 0, 6)
putBackProgressBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
putBackProgressBackground.Visible = false
putBackProgressBackground.Parent = putBackConfirmUI

local putBackProgressFill = Instance.new("Frame")
putBackProgressFill.Name = "PutBackProgressFill"
putBackProgressFill.Size = UDim2.new(0, 0, 1, 0)
putBackProgressFill.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
putBackProgressFill.BorderSizePixel = 0
putBackProgressFill.Parent = putBackProgressBackground

local function resetProgressBar() -- 2 equivalent calls inferred from this helper
	putBackProgressFill.Size = UDim2.new(0, 0, 1, 0)
end

local function hideHoldUI() -- 2 equivalent calls inferred from this helper
	putBackHint.Visible = false
	putBackProgressBackground.Visible = false
	resetProgressBar() -- inferred equivalent call
end

local function startHold() -- 1 equivalent call inferred from this helper
	if not v2 then
		PutBackInstrument:FireServer()
		return
	end

	if flag then
		return
	end

	flag = true
	lastTime = os.clock()
	putBackHint.Visible = true
	putBackProgressBackground.Visible = true
	resetProgressBar() -- inferred equivalent call
end

local function cancelHold() -- 3 equivalent calls inferred from this helper
	if not flag then
		return
	end

	flag = false
	lastTime = nil
	hideHoldUI() -- inferred equivalent call
end

local function confirmPutBack() -- 1 equivalent call inferred from this helper
	flag = false
	lastTime = nil
	hideHoldUI() -- inferred equivalent call
	PutBackInstrument:FireServer()
end

RunService.Heartbeat:Connect(function()
	if not (flag and lastTime) then
		return
	end

	local v3 = math.min((os.clock() - lastTime) / 0.8, 1)
	putBackProgressFill.Size = UDim2.new(v3, 0, 1, 0)

	if v3 >= 1 then
		confirmPutBack() -- inferred equivalent call
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.Backspace then
		startHold() -- inferred equivalent call
	end
end)

UserInputService.InputEnded:Connect(function(input, _)
	if input.KeyCode == Enum.KeyCode.Backspace then
		cancelHold() -- inferred equivalent call
	end
end)

PutBackHoldStart.Event:Connect(startHold)
PutBackHoldCancel.Event:Connect(cancelHold)

SongSessionStatusUpdate.OnClientEvent:Connect(function(p, _)
	v2 = p

	if not p then
		cancelHold() -- inferred equivalent call
	end
end)

InstrumentHUDUpdate.OnClientEvent:Connect(function(p, _, _)
	if not p then
		cancelHold() -- inferred equivalent call
	end
end)