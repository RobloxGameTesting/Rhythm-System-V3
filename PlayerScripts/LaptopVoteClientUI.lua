local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local LaptopVoteStarted = RemoteEvents:WaitForChild("LaptopVoteStarted")
local LaptopVoteTally = RemoteEvents:WaitForChild("LaptopVoteTally")
local LaptopVoteResult = RemoteEvents:WaitForChild("LaptopVoteResult")
local LaptopCastVote = RemoteEvents:WaitForChild("LaptopCastVote")

local StyledTheme = require(ReplicatedStorage.Modules.SongListUI.StyledTheme)
local ToastStyle = require(ReplicatedStorage.Modules.SongListUI.ToastStyle)

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

Color3.fromRGB(20, 20, 22)

local function toHex(data)
	return string.format(
		"#%02X%02X%02X",
		math.floor(data.R * 255 + 0.5),
		math.floor(data.G * 255 + 0.5),
		(math.floor(data.B * 255 + 0.5))
	)
end

local hex = ToastStyle.hex(ToastStyle.AMBER)
local hex2 = ToastStyle.hex(ToastStyle.GRAY)

local function escapeRichText(p) -- 2 equivalent calls inferred from this helper
	return (tostring(p):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local v = nil

local count = 0
local v2 = nil
local v3 = ""
local v4 = 0
local v5 = 0
local total = nil
local v6 = 0

local laptopVoteToastGui = nil
local voteBar = nil
local scale = nil
local icon = nil
local label = nil
local uiSizeConstraint = nil
local timerLabel = nil
local v7 = nil
local v8 = nil
local v9 = nil
local v10 = nil

local function refreshLabel() -- 2 equivalent calls inferred from this helper
	if not label then
		return
	end

	local text = string.format("Change track to <font color=\"%s\"><b>\"%s\"</b></font>?", hex, escapeRichText(v3)) -- inferred equivalent call

	if total then
		text ..= string.format(
			"  <font color=\"%s\" size=\"12\">%d %s</font>",
			hex2,
			total,
			total == 1 and "voter" or "voters"
		)
	end

	label.Text = text
end

local function styleChoiceButton(p, backgroundColor, text, p2) -- 2 equivalent calls inferred from this helper
	p.Text = text

	if p2 then
		p.BackgroundColor3 = ToastStyle.PLATE_LIGHT
		p.TextColor3 = ToastStyle.GRAY
	else
		p.BackgroundColor3 = backgroundColor
		p.TextColor3 = backgroundColor == ToastStyle.RED and ToastStyle.WHITE or ToastStyle.DARK
	end
end

local function refreshButtons()
	if not v7 then
		return
	end

	local v11 = string.format("Yes %d", v4)
	local v12 = string.format("No %d", v5)

	if v2 == true then
		v11 = StyledTheme.Icons.Check .. " " .. v11
	elseif v2 == false then
		v12 = StyledTheme.Icons.Check .. " " .. v12
	end

	styleChoiceButton(v7, ToastStyle.GREEN, v11, v2 == false) -- inferred equivalent call
	styleChoiceButton(v8, ToastStyle.RED, v12, v2 == true) -- inferred equivalent call
end

local function applyLabelMaxWidth() -- 1 equivalent call inferred from this helper
	local currentCamera = workspace.CurrentCamera
	local x = currentCamera and currentCamera.ViewportSize.X or 800
	uiSizeConstraint.MaxSize = Vector2.new(math.max(90, math.min(620, x - 180) - 230), 1e999)
end

local function castVote(p)
	if not v or v2 == p then
		return
	end

	v2 = p
	refreshButtons()
	LaptopCastVote:FireServer(v, p)
end

local function makeChoiceButton(content, name, p, p2, p3)
	local button = ToastStyle.makeButton(content, "", nil, p, p2, ToastStyle.DARK, p3, 24)
	button.Name = name
	button.RichText = false

	local uiSizeConstraint2 = Instance.new("UISizeConstraint")
	uiSizeConstraint2.MinSize = Vector2.new(44, 0)
	uiSizeConstraint2.Parent = button

	return button
end

local function ensureGui()
	if laptopVoteToastGui then
		return
	end

	laptopVoteToastGui = Instance.new("ScreenGui")
	laptopVoteToastGui.Name = "LaptopVoteToastGui"
	laptopVoteToastGui.ResetOnSpawn = false
	laptopVoteToastGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	laptopVoteToastGui.DisplayOrder = 96
	laptopVoteToastGui.Parent = PlayerGui

	voteBar = Instance.new("CanvasGroup")
	voteBar.Name = "VoteBar"
	voteBar.AnchorPoint = Vector2.new(0, 0)
	voteBar.Position = UDim2.new(0.5, ToastStyle.ColumnX(), 0, ToastStyle.TopYFor(laptopVoteToastGui) - 3)
	voteBar.Size = UDim2.new(0, 0, 0, 0)
	voteBar.AutomaticSize = Enum.AutomaticSize.XY
	voteBar.BackgroundTransparency = 1
	voteBar.Visible = false
	voteBar.ZIndex = StyledTheme.ZIndex.Toast
	voteBar:SetAttribute("NoNewUISkin", true)
	voteBar.Parent = laptopVoteToastGui

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 10)
	uiPadding.PaddingRight = UDim.new(0, 10)
	uiPadding.PaddingTop = UDim.new(0, 9)
	uiPadding.PaddingBottom = UDim.new(0, 5)
	uiPadding.Parent = voteBar

	v9 = ToastStyle.buildCard({
		name = "VoteCard",
		height = 40,
		rotation = -0.6,
		accent = ToastStyle.AMBER,
		tape = "tr",
		tag = "VOTE",
		tagX = 30,
		minWidth = 380,
		seed = 19,
		padL = 16,
		padR = 14,
		gap = 8,
		parent = voteBar
	})

	scale = v9.Scale

	icon = ToastStyle.makeIcon(v9.Content, "♪", ToastStyle.AMBER, 1)
	v9.Icon = icon

	label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.RichText = true
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Size = UDim2.new(0, 0, 1, 0)
	label.Font = Enum.Font.SpecialElite
	label.TextSize = 14
	label.TextColor3 = ToastStyle.INK
	label.TextStrokeColor3 = ToastStyle.DARK
	label.TextStrokeTransparency = 1
	label.TextWrapped = false
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Text = ""
	label.LayoutOrder = 2
	label.ZIndex = StyledTheme.ZIndex.Toast + 4
	label.Parent = v9.Content

	uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MaxSize = Vector2.new(300, 1e999)
	uiSizeConstraint.Parent = label

	v9.Scribble = ToastStyle.makeScribble(label, ToastStyle.AMBER, 9)

	timerLabel = Instance.new("TextLabel")
	timerLabel.Name = "TimerLabel"
	timerLabel.BackgroundTransparency = 1
	timerLabel.Size = UDim2.new(0, 32, 1, 0)
	timerLabel.Font = Enum.Font.PermanentMarker
	timerLabel.TextSize = 16
	timerLabel.TextColor3 = ToastStyle.GRAY
	timerLabel.TextStrokeColor3 = ToastStyle.DARK
	timerLabel.TextStrokeTransparency = 1
	timerLabel.Text = ""
	timerLabel.LayoutOrder = 3
	timerLabel.ZIndex = StyledTheme.ZIndex.Toast + 4
	timerLabel.Parent = v9.Content

	v7 = makeChoiceButton(v9.Content, "YesButton", 4, ToastStyle.GREEN, -2)
	v8 = makeChoiceButton(v9.Content, "NoButton", 5, ToastStyle.RED, 1.8)

	v7.Activated:Connect(function()
		if v then
			if v2 == true then
				return
			end

			v2 = true
			refreshButtons()
			LaptopCastVote:FireServer(v, true)
		end
	end)
	v8.Activated:Connect(function()
		if v then
			if v2 == false then
				return
			end

			v2 = false
			refreshButtons()
			LaptopCastVote:FireServer(v, false)
		end
	end)
end

local function popIn() -- 1 equivalent call inferred from this helper
	if v10 then
		v10:Cancel()
		v10 = nil
	end

	voteBar.Visible = true
	voteBar.GroupTransparency = 0
	ToastStyle.popIn(v9)
	v9.Flash()
end

local function fadeOut(p)
	if not (voteBar and voteBar.Visible) then
		return
	end

	v7.Interactable = false
	v8.Interactable = false
	local tween = TweenService:Create(voteBar, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		GroupTransparency = 1
	})

	v10 = tween
	tween.Completed:Connect(function()
		if p == count then
			voteBar.Visible = false
		end
	end)
	tween:Play()
end

local function runCountdown(p) -- 1 equivalent call inferred from this helper
	task.spawn(function()
		while p == count and v do
			local v11 = math.max(0, (math.ceil(v6 - os.clock())))
			timerLabel.Text = v11 .. "s"
			local v12 = v11 <= 5
			timerLabel.TextColor3 = v12 and ToastStyle.RED or ToastStyle.GRAY

			if v12 then
				if v9.Color ~= ToastStyle.RED then
					v9.SetAccent(ToastStyle.RED)
				end

				v9.Plate.Rotation = v9.BaseRotation + (math.floor(os.clock() * 5) % 2 == 0 and 0.9 or -0.9)
			end

			if v11 <= 0 then
				break
			end

			task.wait(0.2)
		end
	end)
end

LaptopVoteStarted.OnClientEvent:Connect(function(p, value, value2)
	ensureGui()
	count += 1
	local v11 = count

	v = p
	v2 = nil
	v3 = tostring(value or "")
	v4 = 0
	v5 = 0
	total = nil

	local v12 = (typeof(value2) ~= "number" or not (value2 > 0 and value2)) and 30 or value2
	v6 = os.clock() + v12

	v9.SetAccent(ToastStyle.AMBER)
	v9.Plate.Rotation = v9.BaseRotation
	v9.Tag.Text = "VOTE"
	icon.Text = "♪"
	timerLabel.Visible = true
	v7.Visible = true
	v8.Visible = true
	v7.Interactable = true
	v8.Interactable = true
	applyLabelMaxWidth() -- inferred equivalent call
	refreshLabel() -- inferred equivalent call
	refreshButtons()
	popIn() -- inferred equivalent call
	runCountdown(v11) -- inferred equivalent call
	task.delay(v12 + 4, function()
		if v11 == count and v == p then
			v = nil
			fadeOut(v11)
		end
	end)
end)

LaptopVoteTally.OnClientEvent:Connect(function(p, data)
	if p ~= v or typeof(data) ~= "table" then
		return
	end

	v3 = tostring(data.SongDisplayName or v3)
	v4 = data.Yes or 0
	v5 = data.No or 0
	total = data.Total
	refreshLabel() -- inferred equivalent call
	refreshButtons()
end)

LaptopVoteResult.OnClientEvent:Connect(function(p, p2)
	if p ~= v then
		return
	end

	v = nil
	count += 1
	local v11 = count
	local v12

	if typeof(p2) == "table" then
		v12 = p2.Passed == true
	else
		v12 = false
	end

	timerLabel.Visible = false
	v7.Visible = false
	v8.Visible = false
	v9.Plate.Rotation = v9.BaseRotation

	if v12 then
		v9.SetAccent(ToastStyle.GREEN)
		v9.Tag.Text = "PASSED"
		icon.Text = StyledTheme.Icons.Check
		local songDisplayName = typeof(p2) == "table" and p2.SongDisplayName or v3
		label.Text = string.format("Backing track changed to <b>\"%s\"</b>", escapeRichText(songDisplayName)) -- inferred equivalent call
	else
		v9.SetAccent(ToastStyle.RED)
		v9.Tag.Text = "FAILED"
		icon.Text = StyledTheme.Icons.Clear
		label.Text = string.format("Vote failed %s backing track not changed", StyledTheme.Icons.Dash)
	end

	task.delay(2.5, function()
		if v11 == count then
			fadeOut(v11)
		end
	end)
end)