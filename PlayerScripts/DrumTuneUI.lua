local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

if not (({ [8408487610] = true, [817083265] = true, [8783077524] = true })[LocalPlayer.UserId] or RunService:IsStudio()) then
	return
end

local DrumStrokeSolver = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DrumStrokeSolver"))
local DrumAnimator = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DrumAnimator"))
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
local drumTuneApplyAvatar = RemoteEvents and RemoteEvents:WaitForChild("DrumTuneApplyAvatar", 10)

local TuneDefaults = DrumStrokeSolver.TuneDefaults

local v = nil
pcall(function()
	local AvatarTypeVerify = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("AvatarTypeVerify"))
	v = AvatarTypeVerify
end)

if drumTuneApplyAvatar then
	drumTuneApplyAvatar.OnClientEvent:Connect(function(p, p2)
		if p == "done" and v then
			pcall(v.RefreshAvatarType, LocalPlayer)
			print(
				"[DrumTuneUI] avatar uji diterapkan:",
				tostring(p2),
				"-> kategori client:",
				(tostring(v.GetAvatarType(LocalPlayer)))
			)
		end
	end)
end

local v2 = {
	{ "Lift", 0.3, 1.6, "Tinggi ayunan (x)" },
	{ "AssistPitch", 0, 25, "Batas condong badan (deg)" },
	{ "AssistYaw", 0, 30, "Batas putar badan (deg)" },
	{ "BodyMul", 0, 2, "Hentakan badan (x)" },
	{ "LookMul", 0, 2, "Menoleh kepala/torso (x)" }
}

local v3 = {
	{ "ShoulderX", -60, 60, "Bahu X (deg)" },
	{ "ShoulderY", -60, 60, "Bahu Y (deg)" },
	{ "ShoulderZ", -60, 60, "Bahu Z (deg)" },
	{ "ElbowX", -60, 60, "Siku X (deg)" },
	{ "ElbowY", -60, 60, "Siku Y / puntir (deg)" },
	{ "WristX", -60, 60, "Pergelangan X (deg)" },
	{ "WristY", -60, 60, "Pergelangan Y (deg)" },
	{ "WristZ", -60, 60, "Pergelangan Z (deg)" }
}

local v4 = {
	{ "X", -1.5, 1.5, "Pose kontak: geser kanan (+), studs" },
	{ "Y", -1, 1, "Pose kontak: geser naik (+), studs" },
	{ "Z", -1.5, 1.5, "Pose kontak: geser mundur (+), studs" },
	{ "Pitch", -45, 45, "Pose kontak: putar stik (deg)" }
}

local TuneTypes = DrumStrokeSolver.TuneTypes

local v5 = {
	{ "lambat", 0.9 },
	{ "sedang", 0.5 },
	{ "cepat", 0.25 }
}

local v6 = "Snare"
local v7 = "Left"

local function fmt(attribute) -- 1 equivalent call inferred from this helper
	return string.format("%.2f", attribute)
end

local function attrName(p) -- 4 equivalent calls inferred from this helper
	if p.kind == "global" then
		return "DrumTune_" .. p.name
	end

	return "DrumTune_" .. v6 .. "_" .. v7 .. "_" .. p.name
end

local function hasAttr(p): boolean -- 2 equivalent calls inferred from this helper
	return LocalPlayer:GetAttribute(attrName(p)) ~= nil -- inferred equivalent call
end

local drumTuneUI = Instance.new("ScreenGui")
drumTuneUI.Name = "DrumTuneUI"
drumTuneUI.ResetOnSpawn = false
drumTuneUI.DisplayOrder = 50
drumTuneUI.Enabled = false
drumTuneUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 330, 1, -24)
frame.Position = UDim2.fromOffset(12, 12)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
frame.BackgroundTransparency = 0.08
frame.BorderSizePixel = 0
frame.Parent = drumTuneUI
local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(0, 8)

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, -12, 0, 24)
textLabel.Position = UDim2.fromOffset(8, 4)
textLabel.BackgroundTransparency = 1
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.Font = Enum.Font.GothamBold
textLabel.TextSize = 14
textLabel.TextColor3 = Color3.new(1, 1, 1)
textLabel.Text = "Tuning Drum  (F7 atau /tunedrum)"
textLabel.Parent = frame

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -8, 1, -32)
scrollingFrame.Position = UDim2.fromOffset(4, 30)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.Parent = frame

local function label(parent, text, p, p2, p3, p4, p5)
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Size = UDim2.fromOffset(p3, p4)
	textLabel2.Position = UDim2.fromOffset(p, p2)
	textLabel2.BackgroundTransparency = 1
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.Font = p5 and Enum.Font.GothamBold or Enum.Font.GothamMedium
	textLabel2.TextSize = 12
	textLabel2.TextColor3 = p5 and Color3.fromRGB(255, 190, 70) or Color3.fromRGB(220, 220, 230)
	textLabel2.Text = text
	textLabel2.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel2.Parent = parent
	return textLabel2
end

local function button(scrollingFrame2, text, p, p2, p3, p4, onMouseButton1Click)
	local textButton = Instance.new("TextButton")
	textButton.Size = UDim2.fromOffset(p3, p4)
	textButton.Position = UDim2.fromOffset(p, p2)
	textButton.BackgroundColor3 = Color3.fromRGB(52, 52, 68)
	textButton.TextColor3 = Color3.new(1, 1, 1)
	textButton.Font = Enum.Font.GothamMedium
	textButton.TextSize = 11
	textButton.AutoButtonColor = true
	textButton.Text = text
	textButton.Parent = scrollingFrame2
	local uiCorner = Instance.new("UICorner", textButton)
	uiCorner.CornerRadius = UDim.new(0, 4)
	textButton.MouseButton1Click:Connect(onMouseButton1Click)
	return textButton
end

local function mark(p, p2)
	p.BackgroundColor3 = p2 and Color3.fromRGB(255, 190, 70) or Color3.fromRGB(52, 52, 68)
	p.TextColor3 = p2 and Color3.fromRGB(20, 20, 26) or Color3.new(1, 1, 1)
end

local v8 = 4

local v9 = label(scrollingFrame, "Kategori terdeteksi: -", 6, v8, 306, 16, true)
local v10 = v8 + 18
label(scrollingFrame, "Avatar uji (ganti bundle lalu Equip ulang):", 6, v10, 306, 14)
local v11 = v10 + 16
local v12 = {}
local v13 = false
local v14 = 2
local v15 = "Sendi"
local v16 = nil

for i, v17 in ipairs({
	{ "Woman", "Woman" },
	{ "Man", "Man" },
	{ "XBOX_M", "XBOX_M" },
	{ "Masculine", "Kotak" }
}) do
	v12[v17[1]] = button(scrollingFrame, v17[2], 6 + (i - 1) * 78, v11, 74, 22, function()
		if not drumTuneApplyAvatar then
			warn("[DrumTuneUI] DrumTuneAvatarServer tidak ditemukan")

			return
		end

		drumTuneApplyAvatar:FireServer(v17[1])
		print("[DrumTuneUI] meminta avatar uji:", v17[1])
	end)
end

local v17 = v11 + 26
button(scrollingFrame, "Pasang ulang stik (kalau hilang)", 6, v17, 230, 22, function()
	if drumTuneApplyAvatar then
		drumTuneApplyAvatar:FireServer("Reequip")
	end
end)
local v18 = v17 + 30

local v19 = label(scrollingFrame, "", 6, v18, 306, 16, true)
local v20 = v18 + 18
local v21 = {}
local v22 = {}
local v23 = nil
local function refreshSelection()
	for k, v24 in pairs(v21) do
		mark(v24, k == v6)
	end

	v19.Text = "Uji pukul & tuning: " .. v6 .. " " .. (v7 == "Left" and "KIRI" or "KANAN")

	if v23 then
		v23()
	end
end

for i, tuneType in ipairs(TuneTypes) do
	local v24 = (i - 1) % 4
	local v25 = math.floor((i - 1) / 4)
	v21[tuneType] = button(scrollingFrame, tuneType, 6 + v24 * 78, v20 + v25 * 26, 74, 22, function()
		v6 = tuneType
		refreshSelection()
	end)
end

local v24 = v20 + 54
local v25 = {}
local function refreshHandButtons() -- 3 equivalent calls inferred from this helper
	for k, v26 in pairs(v25) do
		mark(v26, k == v7)
	end
end
v25.Left = button(scrollingFrame, "Kiri", 6, v24, 50, 22, function()
	v7 = "Left"
	refreshHandButtons() -- inferred equivalent call
	refreshSelection()
end)
v25.Right = button(scrollingFrame, "Kanan", 60, v24, 50, 22, function()
	v7 = "Right"
	refreshHandButtons() -- inferred equivalent call
	refreshSelection()
end)
button(scrollingFrame, "Pukul 1x", 116, v24, 66, 22, function()
	if LocalPlayer.Character then
		DrumAnimator.PreviewHit(LocalPlayer.Character, v6, v7, 0.25)
	end
end)
local v26 = button(scrollingFrame, "Loop: mati", 186, v24, 66, 22, function() end)
local v27 = button(scrollingFrame, "", 256, v24, 62, 22, function() end)
local function refreshLoop() -- 3 equivalent calls inferred from this helper
	v26.Text = v13 and "Loop: HIDUP" or "Loop: mati"
	mark(v26, v13)
	v27.Text = "Tempo: " .. v5[v14][1]
end
v26.MouseButton1Click:Connect(function()
	v13 = not v13
	refreshLoop() -- inferred equivalent call
end)
v27.MouseButton1Click:Connect(function()
	v14 = v14 % #v5 + 1
	refreshLoop() -- inferred equivalent call
end)
local v28 = v24 + 30

task.spawn(function()
	while true do
		if v13 and LocalPlayer.Character then
			pcall(DrumAnimator.PreviewHit, LocalPlayer.Character, v6, v7, 0.25)
		end

		task.wait(v5[v14][2])
	end
end)

local v29 = {}
local function refreshTabs() -- 1 equivalent call inferred from this helper
	for k, v30 in pairs(v29) do
		mark(v30, k == v15)
	end
end
local v30 = v28 + 30

local frame2 = Instance.new("Frame")
frame2.BackgroundTransparency = 1
frame2.Position = UDim2.fromOffset(0, v30)
frame2.Size = UDim2.fromOffset(318, (#v3 + #v4) * 42 + 6)
frame2.Parent = scrollingFrame
local frame3 = Instance.new("Frame")
frame3.BackgroundTransparency = 1
frame3.Position = UDim2.fromOffset(0, v30)
frame3.Size = UDim2.fromOffset(318, #v2 * 42 + 6)
frame3.Parent = scrollingFrame

local function makeRow(frame4, list, p, kind)
	local item = list[1]
	local item2 = list[2]
	local item3 = list[3]
	local item4 = list[4]
	local v31 = { name = item, lo = item2, hi = item3, kind = kind }
	v31.holder = Instance.new("Frame")
	v31.holder.BackgroundTransparency = 1
	v31.holder.Position = UDim2.fromOffset(0, p)
	v31.holder.Size = UDim2.fromOffset(318, 42)
	v31.holder.Parent = frame4
	local holder = v31.holder
	label(holder, item4, 6, 0, 230, 16)
	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.fromOffset(60, 18)
	textBox.Position = UDim2.fromOffset(248, -1)
	textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
	textBox.TextColor3 = Color3.new(1, 1, 1)
	textBox.Font = Enum.Font.Gotham
	textBox.TextSize = 12
	textBox.ClearTextOnFocus = false
	textBox.Text = "0.00"
	textBox.Parent = holder
	local frame5 = Instance.new("Frame")
	frame5.Size = UDim2.fromOffset(294, 6)
	frame5.Position = UDim2.fromOffset(10, 24)
	frame5.BackgroundColor3 = Color3.fromRGB(60, 60, 76)
	frame5.BorderSizePixel = 0
	frame5.Parent = holder
	local uiCorner = Instance.new("UICorner", frame5)
	uiCorner.CornerRadius = UDim.new(1, 0)
	local frame6 = Instance.new("Frame")
	frame6.Size = UDim2.fromOffset(14, 14)
	frame6.AnchorPoint = Vector2.new(0.5, 0.5)
	frame6.Position = UDim2.fromScale(0, 0.5)
	frame6.BackgroundColor3 = Color3.fromRGB(255, 190, 70)
	frame6.BorderSizePixel = 0
	frame6.Parent = frame5
	local uiCorner_2 = Instance.new("UICorner", frame6)
	uiCorner_2.CornerRadius = UDim.new(1, 0)
	v31.box = textBox
	v31.knob = frame6
	v31.track = frame5
	textBox.FocusLost:Connect(function()
		local text = tonumber(textBox.Text)

		if text and hasAttr(v31) then -- inferred equivalent call
			LocalPlayer:SetAttribute(attrName(v31), text) -- inferred equivalent call
		end
	end)
	frame5.InputBegan:Connect(function(input)
		if
			(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
			and hasAttr(v31) -- inferred equivalent call
		then
			v16 = v31
		end
	end)
	table.insert(v22, v31)
end

for i, v31 in ipairs(v3) do
	makeRow(frame2, v31, (i - 1) * 42 + 2, "joint")
end

for i, v31 in ipairs(v4) do
	makeRow(frame2, v31, (#v3 + i - 1) * 42 + 2, "pose")
end

for i, v31 in ipairs(v2) do
	makeRow(frame3, v31, (i - 1) * 42 + 2, "global")
end

local function refresh()
	for _, v31 in ipairs(v22) do
		local attribute = LocalPlayer:GetAttribute(attrName(v31)) -- inferred equivalent call

		if v31.kind == "pose" then
			v31.holder.Visible = attribute ~= nil
		end

		if type(attribute) ~= "number" then
			continue
		end

		if not v31.box:IsFocused() then
			v31.box.Text = fmt(attribute) -- inferred equivalent call
		end

		v31.knob.Position = UDim2.fromScale(math.clamp((attribute - v31.lo) / (v31.hi - v31.lo), 0, 1), 0.5)
	end

	local drumTuneCategory = tostring(LocalPlayer:GetAttribute("DrumTuneCategory") or "-")
	v9.Text = "Kategori terdeteksi: " .. drumTuneCategory

	for k, v31 in pairs(v12) do
		mark(v31, k == drumTuneCategory)
	end
end
v23 = refresh

local function applyTabVisibility() -- 3 equivalent calls inferred from this helper
	frame2.Visible = v15 == "Sendi"
	frame3.Visible = v15 == "Global"
	refreshTabs() -- inferred equivalent call
end
v29.Sendi = button(scrollingFrame, "Sendi (bahu/siku/pergelangan)", 6, v28, 180, 24, function()
	v15 = "Sendi"
	applyTabVisibility() -- inferred equivalent call
end)
v29.Global = button(scrollingFrame, "Global", 190, v28, 80, 24, function()
	v15 = "Global"
	applyTabVisibility() -- inferred equivalent call
end)
local v31 = v30 + math.max((#v3 + #v4) * 42 + 6, #v2 * 42 + 6) + 8

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.fromOffset(306, 170)
textBox.Position = UDim2.fromOffset(6, v31 + 28)
textBox.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
textBox.TextColor3 = Color3.fromRGB(200, 255, 200)
textBox.Font = Enum.Font.Code
textBox.TextSize = 11
textBox.TextWrapped = true
textBox.MultiLine = true
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextYAlignment = Enum.TextYAlignment.Top
textBox.ClearTextOnFocus = false
textBox.TextEditable = true
textBox.Text = ""
textBox.Parent = scrollingFrame

local function buildBlock()
	local drumTuneCategory = tostring(LocalPlayer:GetAttribute("DrumTuneCategory") or "?")
	local v32 = {}

	for _, tuneField in ipairs(DrumStrokeSolver.TuneFields) do
		local attribute = LocalPlayer:GetAttribute("DrumTune_" .. tuneField)

		if not (type(attribute) == "number" and math.abs(attribute - (TuneDefaults[tuneField] or 0)) > 0.0049) then
			continue
		end

		table.insert(v32, string.format("%s = %s", tuneField, fmt(attribute)))
	end

	if #v32 == 0 then
		return drumTuneCategory .. " = { }, -- semua default"
	end

	return drumTuneCategory .. " = { " .. table.concat(v32, ", ") .. " },"
end

button(scrollingFrame, "Salin nilai (tampilkan baris tabel)", 6, v31, 200, 24, function()
	local block = buildBlock()
	textBox.Text = block
	print("[DrumTuneUI] " .. block)
end)
button(scrollingFrame, "Reset kategori", 212, v31, 100, 24, function()
	for _, tuneField in ipairs(DrumStrokeSolver.TuneFields) do
		LocalPlayer:SetAttribute("DrumTune_" .. tuneField, TuneDefaults[tuneField])
	end

	print("[DrumTuneUI] semua nilai kategori ini dikembalikan ke default")
end)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, v31 + 28 + 170 + 12)

UserInputService.InputChanged:Connect(function(input)
	if
		v16
		and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
	then
		local v32 = v16
		local v33 = math.clamp((input.Position.X - v32.track.AbsolutePosition.X) / v32.track.AbsoluteSize.X, 0, 1)
		local v34 = v32.lo + (v32.hi - v32.lo) * v33
		local v35 = v32.kind == "joint" and 1 or 100
		LocalPlayer:SetAttribute(attrName(v32), math.floor(v34 * v35 + 0.5) / v35) -- inferred equivalent call
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v16 = nil
	end
end)

for _, tuneField in ipairs(DrumStrokeSolver.TuneFields) do
	LocalPlayer:GetAttributeChangedSignal("DrumTune_" .. tuneField):Connect(refresh)
end

LocalPlayer:GetAttributeChangedSignal("DrumTuneCategory"):Connect(refresh)
refreshHandButtons() -- inferred equivalent call
refreshSelection()
refreshLoop() -- inferred equivalent call
applyTabVisibility() -- inferred equivalent call
task.spawn(function()
	while true do
		if LocalPlayer.Character then
			pcall(DrumStrokeSolver.PublishTune, LocalPlayer.Character)
		end

		task.wait(1)
	end
end)

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F7 and not UserInputService:GetFocusedTextBox() then
		drumTuneUI.Enabled = not drumTuneUI.Enabled
	end
end)

task.spawn(function()
	local TextChatService = game:GetService("TextChatService")
	local textChatCommands = TextChatService:WaitForChild("TextChatCommands", 10)

	if textChatCommands and not textChatCommands:FindFirstChild("DrumTuneCommand") then
		local drumTuneCommand = Instance.new("TextChatCommand")
		drumTuneCommand.Name = "DrumTuneCommand"
		drumTuneCommand.PrimaryAlias = "/tunedrum"
		drumTuneCommand.Parent = textChatCommands
		drumTuneCommand.Triggered:Connect(function()
			drumTuneUI.Enabled = not drumTuneUI.Enabled
		end)
	end
end)