local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local udim = UDim2.fromOffset(130, 18)

local Gotham = Enum.Font.Gotham

local color = Color3.fromRGB(210, 200, 180)

local color2 = Color3.fromRGB(8, 8, 9)

local v = nil
pcall(function()
	local BandCameraController = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BandCamera"):WaitForChild("BandCameraController"))
	v = BandCameraController
end)

local function isDynamicCamActive()
	if not v then
		return false
	end

	local success, uiState = pcall(v.GetUIState)

	if success then
		if type(uiState) == "table" then
			success = uiState.running == true
		else
			success = false
		end
	end

	return success
end

local v2 = {}
local v3 = false

local function removeIndicator(player) -- 2 equivalent calls inferred from this helper
	local v4 = v2[player]

	if v4 then
		v2[player] = nil
		v4:Destroy()
	end
end

local function createBillboard()
	local watchingBandOverhead = Instance.new("BillboardGui")
	watchingBandOverhead.Name = "WatchingBandOverhead"
	watchingBandOverhead.Size = udim
	watchingBandOverhead.StudsOffset = Vector3.new(0, 1.9, 0)
	watchingBandOverhead.AlwaysOnTop = true
	watchingBandOverhead.MaxDistance = 35
	watchingBandOverhead.ResetOnSpawn = false
	watchingBandOverhead.Enabled = false

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Gotham
	label.TextSize = 14
	label.TextColor3 = color
	label.TextTransparency = 0.35
	label.TextStrokeColor3 = color2
	label.TextStrokeTransparency = 0.6
	label.Text = "Watching.."
	label.Parent = watchingBandOverhead

	watchingBandOverhead.Parent = LocalPlayer:WaitForChild("PlayerGui")
	return watchingBandOverhead
end

local function refresh(player)
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	local v4 = not v3

	if v4 then
		if head == nil or character:GetAttribute("WatchingBand") ~= true then
			v4 = false
		else
			v4 = player ~= LocalPlayer
		end
	end

	if v4 then
		local v5 = v2[player]

		if not v5 then
			v5 = createBillboard()
			v2[player] = v5
		end

		v5.Adornee = head
		v5.Enabled = true
	else
		removeIndicator(player) -- inferred equivalent call
	end
end

local function refreshAll() -- 1 equivalent call inferred from this helper
	for _, v4 in ipairs(Players:GetPlayers()) do
		refresh(v4)
	end
end

local function watchCharacter(p, instance)
	instance:GetAttributeChangedSignal("WatchingBand"):Connect(function()
		refresh(p)
	end)
	instance:WaitForChild("Head", 5)
	refresh(p)
end

local function watchPlayer(player)
	player.CharacterAdded:Connect(function(character)
		task.spawn(watchCharacter, player, character)
	end)
	player.CharacterRemoving:Connect(function()
		removeIndicator(player) -- inferred equivalent call
	end)

	if player.Character then
		task.spawn(watchCharacter, player, player.Character)
	end
end

local function updateCamState() -- 1 equivalent call inferred from this helper
	local success

	if v then
		local uiState
		success, uiState = pcall(v.GetUIState)

		if success then
			if type(uiState) == "table" then
				success = uiState.running == true
			else
				success = false
			end
		end
	else
		success = false
	end

	if success ~= v3 then
		v3 = success
		refreshAll() -- inferred equivalent call
	end
end

if v then
	v.OnChanged(updateCamState)
end

task.spawn(function()
	while true do
		updateCamState() -- inferred equivalent call
		task.wait(0.2)
	end
end)

for _, v4 in ipairs(Players:GetPlayers()) do
	watchPlayer(v4)
end

Players.PlayerAdded:Connect(watchPlayer)
Players.PlayerRemoving:Connect(removeIndicator)