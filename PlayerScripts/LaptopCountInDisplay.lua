local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local laptopCountInStarted = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("LaptopCountInStarted")

Color3.fromRGB(240, 180, 70)
local color = Color3.new(1, 1, 1)

local v = {}

local function findLaptopScreen(p)
	local map = workspace:FindFirstChild("Map")

	if not map then
		return nil
	end

	for _, child in ipairs(map:GetChildren()) do
		if child:GetAttribute("StudioId") == p then
			local laptop = child:FindFirstChild("Laptop")
			local laptop2 = laptop and laptop:FindFirstChild("Laptop")
			return laptop2 and laptop2:FindFirstChild("Screen")
		end
	end

	return nil
end

local function showCountdown(p, p2)
	local laptopScreen = findLaptopScreen(p)

	if not laptopScreen then
		warn("[LaptopCountInDisplay] Screen Laptop tidak ditemukan untuk", p)
		return
	end

	local v2 = (v[p] or 0) + 1
	v[p] = v2

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "LaptopCountInDisplay_" .. p
	billboardGui.Adornee = laptopScreen
	billboardGui.Size = UDim2.new(0, 24, 0, 16)
	billboardGui.StudsOffset = Vector3.new(0, 1.1, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.MaxDistance = 40

	billboardGui.Enabled = true
	billboardGui.Parent = PlayerGui

	local countdownLabel = Instance.new("TextLabel")
	countdownLabel.Name = "CountdownLabel"
	countdownLabel.BackgroundTransparency = 1
	countdownLabel.Size = UDim2.new(1, 0, 1, 0)
	countdownLabel.Font = Enum.Font.Gotham
	countdownLabel.TextScaled = true
	countdownLabel.TextColor3 = color
	countdownLabel.TextStrokeTransparency = 1
	countdownLabel.Text = ""
	countdownLabel.Parent = billboardGui

	for i = math.ceil(p2), 1, -1 do
		if v[p] == v2 then
			countdownLabel.Text = tostring(i)
			task.wait(1)
		else
			billboardGui:Destroy()
			return
		end
	end

	if v[p] == v2 then
		countdownLabel.Text = "GO"
		task.wait(0.5)
	end

	billboardGui:Destroy()
end

laptopCountInStarted.OnClientEvent:Connect(function(value, value2)
	if typeof(value) ~= "string" or typeof(value2) ~= "number" or value2 <= 0 then
		return
	end

	task.spawn(showCountdown, value, value2)
end)