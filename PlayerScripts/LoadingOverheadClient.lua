local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local udim = UDim2.fromOffset(150, 18)

local Gotham = Enum.Font.Gotham

local color = Color3.fromRGB(210, 200, 180)

local color2 = Color3.fromRGB(8, 8, 9)

local v = {}

local function findHead(character) -- 1 equivalent call inferred from this helper
	return character and character:FindFirstChild("Head") or nil
end

local function removeIndicator(player) -- 1 equivalent call inferred from this helper
	local v2 = v[player]

	if v2 then
		v[player] = nil
		v2:Destroy()
	end
end

local function createBillboard()
	local loadingOverhead = Instance.new("BillboardGui")
	loadingOverhead.Name = "LoadingOverhead"
	loadingOverhead.Size = udim
	loadingOverhead.StudsOffset = Vector3.new(0, 1.9, 0)
	loadingOverhead.AlwaysOnTop = true
	loadingOverhead.MaxDistance = 35
	loadingOverhead.ResetOnSpawn = false
	loadingOverhead.Enabled = false

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
	label.Text = ""
	label.Parent = loadingOverhead

	loadingOverhead.Parent = LocalPlayer:WaitForChild("PlayerGui")
	return loadingOverhead
end

local function currentText(player): nil | string
	if player:GetAttribute("IsLoading") == true then
		return "Loading..."
	end

	if player:GetAttribute("IsAutoClicker") == true then
		return "*Auto Clicker*"
	end

	if player:GetAttribute("IsOpeningLaptop") == true then
		return "Using laptop..."
	end

	if player:GetAttribute("IsViewingResults") == true then
		return "Viewing Results"
	end

	if player:GetAttribute("IsBrowsingSongList") == true then
		return "Browsing songs..."
	end

	if player:GetAttribute("IsInMicSettings") == true then
		return "Adjusting mic..."
	end

	local tabsEditState = player:GetAttribute("TabsEditState")

	if tabsEditState == "Recording" then
		return "Recording tabs"
	elseif tabsEditState == "Creating" then
		return "Creating a tab.."
	end

	if player:GetAttribute("IsPlayingTabs") == true then
		return "Playing tabs..."
	end

	return nil
end

local function refresh(player) -- 10 equivalent calls inferred from this helper
	local text = currentText(player)

	if text then
		local v2 = v[player]

		if not v2 then
			v2 = createBillboard()
			v[player] = v2
		end

		v2.Label.Text = text
		local head = findHead(player.Character) -- inferred equivalent call
		v2.Adornee = head
		v2.Enabled = head ~= nil
	else
		removeIndicator(player) -- inferred equivalent call
	end
end

local function watchPlayer(object)
	object:GetAttributeChangedSignal("IsLoading"):Connect(function()
		refresh(object) -- inferred equivalent call
	end)
	object:GetAttributeChangedSignal("IsBrowsingSongList"):Connect(function()
		refresh(object) -- inferred equivalent call
	end)
	object:GetAttributeChangedSignal("IsViewingResults"):Connect(function()
		refresh(object) -- inferred equivalent call
	end)
	object:GetAttributeChangedSignal("IsOpeningLaptop"):Connect(function()
		refresh(object) -- inferred equivalent call
	end)
	object:GetAttributeChangedSignal("IsPlayingTabs"):Connect(function()
		refresh(object) -- inferred equivalent call
	end)
	object:GetAttributeChangedSignal("TabsEditState"):Connect(function()
		refresh(object) -- inferred equivalent call
	end)
	object:GetAttributeChangedSignal("IsInMicSettings"):Connect(function()
		refresh(object) -- inferred equivalent call
	end)
	object:GetAttributeChangedSignal("IsAutoClicker"):Connect(function()
		refresh(object) -- inferred equivalent call
	end)

	object.CharacterAdded:Connect(function(character)
		task.spawn(function()
			character:WaitForChild("Head", 5)

			if v[object] then
				refresh(object) -- inferred equivalent call
			end
		end)
	end)
	refresh(object) -- inferred equivalent call
end

for _, v2 in ipairs(Players:GetPlayers()) do
	watchPlayer(v2)
end

Players.PlayerAdded:Connect(watchPlayer)
Players.PlayerRemoving:Connect(removeIndicator)