local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local notePadShareOffer = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("NotePadShareOffer")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local TabsSkin = require(Modules:WaitForChild("TabsSkin"))
local Dark = TabsSkin.Palettes.Dark

local Panel = Dark.Panel
local Button = Dark.Button
local Text = Dark.Text
local Dim = Dark.Dim
local Accent = Dark.Accent
local Stroke = Dark.Stroke
local Warn = Dark.Warn
local FontLabel = TabsSkin.FontLabel

local notePadShareGui = Instance.new("ScreenGui")
notePadShareGui.Name = "NotePadShareGui"
notePadShareGui.ResetOnSpawn = false
notePadShareGui.DisplayOrder = 46
notePadShareGui.IgnoreGuiInset = true
notePadShareGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
notePadShareGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.Position = UDim2.new(0, 12, 0, 150)
frame.Size = UDim2.fromOffset(340, 0)
frame.AutomaticSize = Enum.AutomaticSize.Y
frame.Parent = notePadShareGui
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 6)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = frame

local v = 0
local count = 0

local function label(frame2, text, textSize, textColor, p)
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Font = FontLabel
	textLabel.Text = text
	textLabel.TextSize = textSize
	textLabel.TextColor3 = textColor
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel.Position = UDim2.fromOffset(10, p)
	textLabel.Size = UDim2.new(1, -20, 0, textSize + 4)
	textLabel.Parent = frame2
	return textLabel
end

local function button(frame2, text, p, p2, backgroundColor, textColor)
	local textButton = Instance.new("TextButton")
	textButton.AutoButtonColor = false
	textButton.Font = FontLabel
	textButton.Text = text
	textButton.TextSize = 15
	textButton.TextColor3 = textColor
	textButton.BackgroundColor3 = backgroundColor
	textButton.BorderSizePixel = 0
	textButton.Position = UDim2.fromOffset(p, 62)
	textButton.Size = UDim2.fromOffset(p2, 26)
	textButton.Parent = frame2
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 3)
	uiCorner.Parent = textButton
	return textButton
end

local function getPad()
	local success, result = pcall(function()
		return require(Modules:WaitForChild("NotePadUI", 10))
	end)

	return success and result or nil
end

local function addOffer(data)
	if type(data) ~= "table" or type(data.Id) ~= "string" then
		return
	end

	if v >= 3 then
		local success, result = pcall(function()
			return require(Modules:WaitForChild("NotePadUI", 10))
		end)
		local v2 = success and result or nil

		if v2 then
			v2.DeclineOffer(data)
		end
	else
		v += 1
		count += 1

		local frame2 = Instance.new("Frame")
		frame2.BackgroundColor3 = Panel
		frame2.BorderSizePixel = 0
		frame2.Size = UDim2.new(1, 0, 0, 98)
		frame2.LayoutOrder = count
		frame2.Parent = frame
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 3)
		uiCorner.Parent = frame2
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = 2
		uiStroke.Color = Stroke
		uiStroke.Parent = frame2

		label(frame2, tostring(data.From) .. " sent you a note", 17, Accent, 6)
		local label_2 = label(
			frame2,
			tostring(data.Title) .. "   [" .. tostring(data.Chars) .. " characters]",
			15,
			Text,
			30
		)
		label_2.Font = TabsSkin.FontBody
		TabsSkin.tape(
			frame2,
			"NewUIDecorTape",
			UDim2.new(1, -96, 0, -9),
			UDim2.fromOffset(86, 18),
			3,
			Dark.Tape,
			6,
			nil,
			"NEW NOTE!",
			Dark.Ink
		)
		TabsSkin.tape(
			frame2,
			"NewUIDecorTape2",
			UDim2.new(0, -12, 1, -14),
			UDim2.fromOffset(40, 13),
			40,
			Dark.Tape,
			6,
			nil,
			nil,
			Dark.Ink
		)
		local v2 = label(frame2, "", 13, Dim, 66)
		v2.Visible = false

		local parent = button(frame2, "ACCEPT", 10, 90, Accent, Stroke)
		local parent2 = button(frame2, "DECLINE", 106, 90, Button, Text)

		local flag = false
		local function close() -- 1 equivalent call inferred from this helper
			if flag then
				return
			end

			flag = true
			v -= 1
			frame2:Destroy()
		end

		parent.Activated:Connect(function()
			if flag or parent.Text == "..." then
				return
			end

			parent.Text = "..."
			local success, result = pcall(function()
				return require(Modules:WaitForChild("NotePadUI", 10))
			end)
			local v3 = success and result or nil

			if not v3 then
				parent.Text = "ACCEPT"
				return
			end

			local acceptOffer, v4, _ = v3.AcceptOffer(data)

			if flag then
				return
			end

			if acceptOffer then
				parent.Visible = false
				parent2.Visible = false
				v2.Visible = true
				v2.TextColor3 = Text
				v2.Text = "Saved to NOTE page " .. tostring(v4)
				task.delay(4, close)
			else
				parent.Text = "ACCEPT"
				v2.Visible = true
				v2.TextColor3 = Warn
				v2.Text = tostring(v4 or "Could not save")
			end
		end)

		parent2.Activated:Connect(function()
			if flag then
				return
			end

			local success, result = pcall(function()
				return require(Modules:WaitForChild("NotePadUI", 10))
			end)
			local v3 = success and result or nil

			if v3 then
				v3.DeclineOffer(data)
			end

			close() -- inferred equivalent call
		end)

		task.delay(math.min(tonumber(data.Ttl) or 60, 60), close)
	end
end

notePadShareOffer.OnClientEvent:Connect(addOffer)