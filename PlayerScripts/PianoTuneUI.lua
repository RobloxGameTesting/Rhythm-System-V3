local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

if not ({ [8408487610] = true, [817083265] = true, [8783077524] = true })[LocalPlayer.UserId] then
	local RunService = game:GetService("RunService")

	if not RunService:IsStudio() then
		return
	end
end

local v = {
	{ "Drop", -1, 1, "Turun (+) / naik (-), studs" },
	{ "Forward", -1, 3, "Maju (+) / mundur (-), studs" },
	{ "Side", -1, 1, "Ke luar (+) / ke dalam (-), studs" },
	{ "PitchDeg", -90, 90, "Pergelangan: ujung jari maju (+) derajat" },
	{ "YawDeg", -90, 90, "Putar horizontal derajat" },
	{ "RollDeg", -90, 90, "Putar menyamping derajat" },
	{ "LeanDeg", 0, 40, "Condong badan tambahan derajat" },
	{ "SeatForward", -0.5, 2, "Pinggul/badan maju ke piano, studs" }
}

local pianoTuneUI = Instance.new("ScreenGui")
pianoTuneUI.Name = "PianoTuneUI"
pianoTuneUI.ResetOnSpawn = false
pianoTuneUI.DisplayOrder = 50
pianoTuneUI.Enabled = false
pianoTuneUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(300, #v * 46 + 40 + 90)
frame.Position = UDim2.new(0, 12, 0.5, -(#v * 46 + 40 + 90) / 2)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = pianoTuneUI
local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(0, 8)

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, -12, 0, 30)
textLabel.Position = UDim2.fromOffset(8, 4)
textLabel.BackgroundTransparency = 1
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.Font = Enum.Font.GothamBold
textLabel.TextSize = 14
textLabel.TextColor3 = Color3.new(1, 1, 1)
textLabel.Text = "Tuning Piano  (F6 sembunyikan)"
textLabel.Parent = frame

local function fmt(p) -- 2 equivalent calls inferred from this helper
	return string.format("%.2f", p)
end

local function setValue(p, p2) -- 2 equivalent calls inferred from this helper
	LocalPlayer:SetAttribute("PianoTune_" .. p, p2)
end

local v2 = {}
local v3 = nil

for i, v4 in ipairs(v) do
	local v5 = v4[1]
	local lo = v4[2]
	local hi = v4[3]
	local v6 = v4[4]
	local v7 = 38 + (i - 1) * 46
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Size = UDim2.new(1, -90, 0, 16)
	textLabel2.Position = UDim2.fromOffset(10, v7)
	textLabel2.BackgroundTransparency = 1
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.Font = Enum.Font.GothamMedium
	textLabel2.TextSize = 12
	textLabel2.TextColor3 = Color3.fromRGB(220, 220, 230)
	textLabel2.Text = v5 .. "  ·  " .. v6
	textLabel2.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel2.Parent = frame

	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.fromOffset(64, 18)
	textBox.Position = UDim2.new(1, -74, 0, v7 - 1)
	textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
	textBox.TextColor3 = Color3.new(1, 1, 1)
	textBox.Font = Enum.Font.Gotham
	textBox.TextSize = 12
	textBox.ClearTextOnFocus = false
	textBox.Text = "0.00"
	textBox.Parent = frame

	local frame2 = Instance.new("Frame")
	frame2.Size = UDim2.new(1, -24, 0, 6)
	frame2.Position = UDim2.fromOffset(12, v7 + 26)
	frame2.BackgroundColor3 = Color3.fromRGB(60, 60, 76)
	frame2.BorderSizePixel = 0
	frame2.Parent = frame
	local uiCorner_2 = Instance.new("UICorner", frame2)
	uiCorner_2.CornerRadius = UDim.new(1, 0)

	local frame3 = Instance.new("Frame")
	frame3.Size = UDim2.fromOffset(14, 14)
	frame3.AnchorPoint = Vector2.new(0.5, 0.5)
	frame3.Position = UDim2.fromScale(0, 0.5)
	frame3.BackgroundColor3 = Color3.fromRGB(255, 190, 70)
	frame3.BorderSizePixel = 0
	frame3.Parent = frame2
	local uiCorner_3 = Instance.new("UICorner", frame3)
	uiCorner_3.CornerRadius = UDim.new(1, 0)

	v2[v5] = {
		box = textBox,
		knob = frame3,
		lo = lo,
		hi = hi,
		track = frame2
	}

	textBox.FocusLost:Connect(function()
		local text = tonumber(textBox.Text)

		if text then
			setValue(v5, text) -- inferred equivalent call
		end
	end)

	frame2.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			v3 = v5
		end
	end)
end

UserInputService.InputChanged:Connect(function(input)
	if
		v3
		and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
	then
		local v4 = v2[v3]
		local v5 = math.clamp((input.Position.X - v4.track.AbsolutePosition.X) / v4.track.AbsoluteSize.X, 0, 1)
		setValue(v3, math.floor((v4.lo + (v4.hi - v4.lo) * v5) * 100 + 0.5) / 100) -- inferred equivalent call
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v3 = nil
	end
end)

local textLabel2 = Instance.new("TextLabel")
textLabel2.Size = UDim2.new(1, -20, 0, 16)
textLabel2.Position = UDim2.new(0, 10, 1, -84)
textLabel2.BackgroundTransparency = 1
textLabel2.TextXAlignment = Enum.TextXAlignment.Left
textLabel2.Font = Enum.Font.GothamBold
textLabel2.TextSize = 12
textLabel2.TextColor3 = Color3.fromRGB(255, 190, 70)
textLabel2.Text = "Kategori: -"
textLabel2.Parent = frame

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 0, 36)
textBox.Position = UDim2.new(0, 10, 1, -64)
textBox.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
textBox.TextColor3 = Color3.fromRGB(200, 255, 200)
textBox.Font = Enum.Font.Code
textBox.TextSize = 10
textBox.TextWrapped = true
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextYAlignment = Enum.TextYAlignment.Top
textBox.ClearTextOnFocus = false
textBox.TextEditable = false
textBox.Text = ""
textBox.Parent = frame

local textButton = Instance.new("TextButton")
textButton.Size = UDim2.new(1, -20, 0, 20)
textButton.Position = UDim2.new(0, 10, 1, -24)
textButton.BackgroundColor3 = Color3.fromRGB(255, 190, 70)
textButton.TextColor3 = Color3.fromRGB(20, 20, 26)
textButton.Font = Enum.Font.GothamBold
textButton.TextSize = 12
textButton.Text = "Salin nilai (tampilkan baris tabel)"
textButton.Parent = frame

textButton.MouseButton1Click:Connect(function()
	local v4 = {}

	for _, v5 in ipairs(v) do
		local attribute = LocalPlayer:GetAttribute("PianoTune_" .. v5[1])
		local v6 = v5[1]
		table.insert(v4, v6 .. " = " .. fmt(type(attribute) == "number" and attribute or 0)) -- inferred equivalent call
	end

	local text = tostring(LocalPlayer:GetAttribute("PianoTuneCategory") or "?") .. " = { " .. table.concat(v4, ", ") .. " },"
	textBox.Text = text
	print("[PianoTuneUI] " .. text)
end)

local function refresh()
	for k, v4 in pairs(v2) do
		local attribute = LocalPlayer:GetAttribute("PianoTune_" .. k)

		if type(attribute) ~= "number" then
			continue
		end

		if not v4.box:IsFocused() then
			v4.box.Text = fmt(attribute) -- inferred equivalent call
		end

		v4.knob.Position = UDim2.fromScale(math.clamp((attribute - v4.lo) / (v4.hi - v4.lo), 0, 1), 0.5)
	end

	textLabel2.Text = "Kategori: " .. tostring(LocalPlayer:GetAttribute("PianoTuneCategory") or "-")
end

for _, v4 in ipairs(v) do
	LocalPlayer:GetAttributeChangedSignal("PianoTune_" .. v4[1]):Connect(function()
		refresh()

		if not (v3 or v2[v4[1]].box:IsFocused()) then
			print(string.format(
				"[PianoTuneUI][DIAG] %s -> %s (bukan dari slider/ketik) t=%.1f",
				v4[1],
				tostring(LocalPlayer:GetAttribute("PianoTune_" .. v4[1])),
				os.clock()
			))
		end
	end)
end

LocalPlayer:GetAttributeChangedSignal("PianoTuneCategory"):Connect(refresh)
refresh()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.F6 then
		pianoTuneUI.Enabled = not pianoTuneUI.Enabled
	end
end)