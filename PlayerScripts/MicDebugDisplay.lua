local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local micDebugUpdate = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("MicDebugUpdate")

local micDebugBillboard = nil
local textLabel = nil

local function findPromptAnchor()
	local map = Workspace:FindFirstChild("Map")
	local STAGE1 = map and map:FindFirstChild("STAGE 1")
	local microphone = STAGE1 and STAGE1:FindFirstChild("Microphone")
	local microphone2 = microphone and microphone:FindFirstChild("Microphone")
	return microphone2 and microphone2:FindFirstChild("PromptAnchor")
end

local function ensureBillboard()
	if micDebugBillboard and micDebugBillboard.Parent then
		return
	end

	local promptAnchor = findPromptAnchor()

	if not promptAnchor then
		return
	end

	micDebugBillboard = Instance.new("BillboardGui")
	micDebugBillboard.Name = "MicDebugBillboard"
	micDebugBillboard.Size = UDim2.new(0, 260, 0, 190)
	micDebugBillboard.StudsOffset = Vector3.new(0, 3, 0)
	micDebugBillboard.AlwaysOnTop = true
	micDebugBillboard.Adornee = promptAnchor
	micDebugBillboard.Parent = promptAnchor

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 0.35
	frame.BorderSizePixel = 0
	frame.Parent = micDebugBillboard

	textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, -10, 1, -10)
	textLabel.Position = UDim2.new(0, 5, 0, 5)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.Code
	textLabel.TextSize = 14
	textLabel.TextColor3 = Color3.fromRGB(120, 255, 140)
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.Text = "Menunggu data..."
	textLabel.Parent = frame
end

micDebugUpdate.OnClientEvent:Connect(function(p, data)
	ensureBillboard()

	if not textLabel then
		return
	end

	local axes = data.Axes
	local v = {
		("Stage: %s"):format((tostring(p))),
		("Nearest: %s"):format(data.PlayerName or "-- (tidak ada di StageManager?)"),
		("Distance: %s"):format(data.Distance and string.format("%.2f", data.Distance) or "-"),
		("Dot (dipakai skrg): %s"):format(data.Dot and string.format("%.2f", data.Dot) or "-"),
		("Strength: %s"):format(string.format("%.2f", data.Strength or 0)),
		"--- kandidat sumbu (cari yg ~1.0 pas di depan) ---",
		("Look : %s"):format(axes and string.format("%.2f", axes.Look) or "-"),
		("Right: %s"):format(axes and string.format("%.2f", axes.Right) or "-"),
		("Up   : %s"):format(axes and string.format("%.2f", axes.Up) or "-"),
		("Singer aktif: %s"):format(data.Singer or "-- (belum ada)"),
		("GainVolume: %s"):format(string.format("%.2f", data.GainVolume or 0)),
		("PlayersInStage: %s"):format((tostring(data.PlayersInStage)))
	}

	textLabel.Text = table.concat(v, "\n")
end)

task.spawn(ensureBillboard)