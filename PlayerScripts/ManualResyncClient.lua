local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local RequestManualResync = RemoteEvents:WaitForChild("RequestManualResync")
local ManualResyncResult = RemoteEvents:WaitForChild("ManualResyncResult")
local SongSessionStatusUpdate = RemoteEvents:WaitForChild("SongSessionStatusUpdate")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local color = Color3.fromRGB(150, 150, 155)

local v = false

local manualResyncClient = Instance.new("ScreenGui")
manualResyncClient.Name = "ManualResyncClient"
manualResyncClient.ResetOnSpawn = false
manualResyncClient.Parent = PlayerGui

local textLabel = Instance.new("TextLabel")
textLabel.AnchorPoint = Vector2.new(0.5, 0)
textLabel.Position = UDim2.new(0.5, 0, 0, 8)
textLabel.Size = UDim2.new(0, 380, 0, 18)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = color
textLabel.Font = Enum.Font.Gotham
textLabel.TextSize = 12
textLabel.Text = "(If audio is delayed or out of sync, press R)"
textLabel.Visible = false
textLabel.Parent = manualResyncClient

local textLabel2 = Instance.new("TextLabel")
textLabel2.AnchorPoint = Vector2.new(0.5, 1)
textLabel2.Position = UDim2.new(0.5, 0, 1, -160)
textLabel2.Size = UDim2.new(0, 160, 0, 20)
textLabel2.BackgroundTransparency = 1
textLabel2.TextColor3 = color
textLabel2.Font = Enum.Font.GothamMedium
textLabel2.TextSize = 12
textLabel2.Text = "Resyncing..."
textLabel2.Visible = false
textLabel2.Parent = manualResyncClient

local count = 0
local function showFeedback(text) -- 2 equivalent calls inferred from this helper
	count += 1
	local v2 = count
	textLabel2.Text = text
	textLabel2.Visible = true
	task.delay(1.5, function()
		if v2 == count then
			textLabel2.Visible = false
		end
	end)
end

local function doResync() -- 1 equivalent call inferred from this helper
	RequestManualResync:FireServer()
end

ManualResyncResult.OnClientEvent:Connect(function(p, p2, value)
	if p then
		showFeedback("Resynced") -- inferred equivalent call
	elseif p2 == "cooldown" then
		showFeedback(string.format("Wait %.0fs before resyncing again", value or 0)) -- inferred equivalent call
	end
end)

local v2 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.R and v then
		doResync() -- inferred equivalent call
	end
end)

SongSessionStatusUpdate.OnClientEvent:Connect(function(p, _)
	v = p

	textLabel.Visible = p and not v2
end)