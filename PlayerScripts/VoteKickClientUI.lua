local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local VoteKickUpdate = RemoteEvents:WaitForChild("VoteKickUpdate")
local VoteKickCast = RemoteEvents:WaitForChild("VoteKickCast")

local StyledTheme = require(ReplicatedStorage.Modules.SongListUI.StyledTheme)
local ToastStyle = require(ReplicatedStorage.Modules.SongListUI.ToastStyle)
local StageNames = require(ReplicatedStorage.Modules.StageNames)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local avatarCardHeight = ToastStyle.AvatarCardHeight(36)

local f1 = Enum.KeyCode.F1
local f2 = Enum.KeyCode.F2
local KeyboardEnabled = UserInputService.KeyboardEnabled
local v = KeyboardEnabled and " <font size=\"10\">F1</font>" or ""
local v2 = KeyboardEnabled and " <font size=\"10\">F2</font>" or ""
local hex = ToastStyle.hex(ToastStyle.GRAY)
local hex2 = ToastStyle.hex(ToastStyle.AMBER)

local function escapeRichText(p) -- 8 equivalent calls inferred from this helper
	return (tostring(p):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local v3 = {}
local function stageNameFor(studioId)
	local v4 = v3[studioId]

	if v4 then
		return v4
	end

	local map = Workspace:FindFirstChild("Map")

	if not map then
		return "this stage"
	end

	for _, child in ipairs(map:GetChildren()) do
		if child:GetAttribute("StudioId") == studioId then
			local success, result = pcall(StageNames.Display, child.Name)

			if not success or type(result) ~= "string" or not result then
				result = child.Name
			end

			v3[studioId] = result
			return result
		end
	end

	return "this stage"
end

local function formatClock(p)
	local v4 = math.max(0, (math.floor(p + 0.5)))
	return string.format("%d:%02d", v4 // 60, v4 % 60)
end

local count = 0
local id = nil
local v4 = nil
local v5 = 0
local v6 = 0
local v7 = 0
local v8 = 0
local v9 = ""
local v10 = ""
local v11 = 0

local voteKickToastGui = nil
local voteKickBar = nil
local v12 = nil
local label = nil
local uiSizeConstraint = nil
local timerLabel = nil
local v13 = nil
local v14 = nil
local v15 = nil

local function refreshLabel() -- 3 equivalent calls inferred from this helper
	if not label then
		return
	end

	label.Text = string.format(
		"Remove <font color=\"%s\"><b>%s</b></font>?  <font color=\"%s\" size=\"12\">%s</font>",
		hex2,
		escapeRichText(v9), -- inferred equivalent call
		hex,
		escapeRichText(v10) -- inferred equivalent call
	)
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
	if not v13 then
		return
	end

	local v16 = string.format("Yes %d/%d", v5, v7)
	local v17 = string.format("No %d", v6)

	if v4 == true then
		v16 = StyledTheme.Icons.Check .. " " .. v16
	elseif v4 == false then
		v17 = StyledTheme.Icons.Check .. " " .. v17
	end

	styleChoiceButton(v13, ToastStyle.GREEN, v16 .. v, v4 == false) -- inferred equivalent call
	styleChoiceButton(v14, ToastStyle.RED, v17 .. v2, v4 == true) -- inferred equivalent call
end

local function applyLabelMaxWidth(p) -- 2 equivalent calls inferred from this helper
	local currentCamera = Workspace.CurrentCamera
	local x = currentCamera and currentCamera.ViewportSize.X or 800
	uiSizeConstraint.MaxSize = Vector2.new(math.max(90, math.min(620, x - 180) - p), 1e999)
end

local function placeBar()
	local v16 = ToastStyle.TopYFor(voteKickToastGui) - 3
	local laptopVoteToastGui = PlayerGui:FindFirstChild("LaptopVoteToastGui")
	local voteBar = laptopVoteToastGui and laptopVoteToastGui:FindFirstChild("VoteBar")

	if voteBar and voteBar:IsA("GuiObject") and voteBar.Visible then
		v16 = math.max(v16, voteBar.Position.Y.Offset + voteBar.AbsoluteSize.Y - 5)
	end

	voteKickBar.Position = UDim2.new(0.5, ToastStyle.ColumnX(), 0, v16)
end

local function castVote(p)
	if not id or v4 == p then
		return
	end

	v4 = p
	refreshButtons()
	VoteKickCast:FireServer(id, p)
end

local function ensureGui()
	if voteKickToastGui then
		return
	end

	voteKickToastGui = Instance.new("ScreenGui")
	voteKickToastGui.Name = "VoteKickToastGui"
	voteKickToastGui.ResetOnSpawn = false
	voteKickToastGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	voteKickToastGui.DisplayOrder = 97
	voteKickToastGui.Parent = PlayerGui

	voteKickBar = Instance.new("CanvasGroup")
	voteKickBar.Name = "VoteKickBar"
	voteKickBar.AnchorPoint = Vector2.new(0, 0)
	voteKickBar.Position = UDim2.new(0.5, ToastStyle.ColumnX(), 0, ToastStyle.TopYFor(voteKickToastGui) - 3)
	voteKickBar.Size = UDim2.new(0, 0, 0, 0)
	voteKickBar.AutomaticSize = Enum.AutomaticSize.XY
	voteKickBar.BackgroundTransparency = 1
	voteKickBar.Visible = false
	voteKickBar.ZIndex = StyledTheme.ZIndex.Toast
	voteKickBar:SetAttribute("NoNewUISkin", true)
	voteKickBar.Parent = voteKickToastGui

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 10)
	uiPadding.PaddingRight = UDim.new(0, 10)
	uiPadding.PaddingTop = UDim.new(0, 9)
	uiPadding.PaddingBottom = UDim.new(0, 5)
	uiPadding.Parent = voteKickBar

	v12 = ToastStyle.buildCard({
		name = "VoteKickCard",
		height = avatarCardHeight,
		rotation = 0.6,
		accent = ToastStyle.RED,
		tape = "tr",
		tag = "KICK VOTE",
		tagX = 30,
		minWidth = 300,
		seed = 31,
		padL = 16,
		padR = 14,
		gap = 8,
		parent = voteKickBar
	})

	v12.Icon = ToastStyle.makeIcon(v12.Content, StyledTheme.Icons.Clear, ToastStyle.RED, 1)

	label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.RichText = true
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Size = UDim2.new(0, 0, 1, 0)
	label.Font = Enum.Font.SpecialElite
	label.TextSize = 14
	label.TextColor3 = ToastStyle.INK
	label.TextStrokeTransparency = 1
	label.TextWrapped = false
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Text = ""
	label.LayoutOrder = 2
	label.ZIndex = StyledTheme.ZIndex.Toast + 4
	label.Parent = v12.Content

	uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MaxSize = Vector2.new(300, 1e999)
	uiSizeConstraint.Parent = label

	v12.Scribble = ToastStyle.makeScribble(label, ToastStyle.RED, 9)

	timerLabel = Instance.new("TextLabel")
	timerLabel.Name = "TimerLabel"
	timerLabel.BackgroundTransparency = 1
	timerLabel.Size = UDim2.new(0, 32, 1, 0)
	timerLabel.Font = Enum.Font.PermanentMarker
	timerLabel.TextSize = 16
	timerLabel.TextColor3 = ToastStyle.GRAY
	timerLabel.TextStrokeTransparency = 1
	timerLabel.Text = ""
	timerLabel.LayoutOrder = 3
	timerLabel.ZIndex = StyledTheme.ZIndex.Toast + 4
	timerLabel.Parent = v12.Content

	local function makeChoiceButton(name, p, p2, p3)
		local button = ToastStyle.makeButton(v12.Content, "", nil, p, p2, ToastStyle.DARK, p3, 24)
		button.Name = name
		button.RichText = true
		local uiSizeConstraint2 = Instance.new("UISizeConstraint")
		uiSizeConstraint2.MinSize = Vector2.new(52, 0)
		uiSizeConstraint2.Parent = button
		return button
	end

	v13 = makeChoiceButton("YesButton", 4, ToastStyle.GREEN, -2)
	v14 = makeChoiceButton("NoButton", 5, ToastStyle.RED, 1.8)
	v13.Activated:Connect(function()
		if id then
			if v4 == true then
				return
			end

			v4 = true
			refreshButtons()
			VoteKickCast:FireServer(id, true)
		end
	end)
	v14.Activated:Connect(function()
		if id then
			if v4 == false then
				return
			end

			v4 = false
			refreshButtons()
			VoteKickCast:FireServer(id, false)
		end
	end)

	ToastStyle.attachAvatar(v12, nil, avatarCardHeight, false)
end

local function popIn() -- 2 equivalent calls inferred from this helper
	if v15 then
		v15:Cancel()
		v15 = nil
	end

	placeBar()
	voteKickBar.Visible = true
	voteKickBar.GroupTransparency = 0
	ToastStyle.popIn(v12)
	v12.Flash()
end

local function fadeOut(p)
	if not (voteKickBar and voteKickBar.Visible) then
		return
	end

	v13.Interactable = false
	v14.Interactable = false
	local tween = TweenService:Create(
		voteKickBar,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ GroupTransparency = 1 }
	)
	v15 = tween
	tween.Completed:Connect(function()
		if p == count then
			voteKickBar.Visible = false
		end
	end)
	tween:Play()
end

local function showMessage(text, p, text2, text3, p2, duration)
	ensureGui()
	count += 1
	local v16 = count
	id = nil

	v12.SetAccent(p)
	v12.Plate.Rotation = v12.BaseRotation
	v12.Tag.Text = text
	v12.Icon.Text = text2
	timerLabel.Visible = false
	v13.Visible = false
	v14.Visible = false
	v12.Avatar.Set(p2 or LocalPlayer.UserId)
	applyLabelMaxWidth(150) -- inferred equivalent call
	label.Text = text3
	popIn() -- inferred equivalent call
	task.delay(duration, function()
		if v16 == count then
			fadeOut(v16)
		end
	end)
end

local function runCountdown(p) -- 1 equivalent call inferred from this helper
	task.spawn(function()
		while p == count and id do
			local v16 = math.max(0, (math.ceil(v11 - os.clock())))
			timerLabel.Text = v16 .. "s"
			local v17 = v16 <= 5
			timerLabel.TextColor3 = v17 and ToastStyle.RED or ToastStyle.GRAY

			if v17 then
				v12.Plate.Rotation = v12.BaseRotation + (math.floor(os.clock() * 5) % 2 == 0 and 0.9 or -0.9)
			end

			if v16 <= 0 then
				break
			end

			task.wait(0.2)
		end
	end)
end

local function onStart(data)
	ensureGui()
	count += 1
	local v16 = count

	id = data.Id
	v4 = data.MyChoice
	v5 = data.Yes or 0
	v6 = data.No or 0
	v7 = data.Need or 0
	v8 = data.Total or 0
	v9 = tostring(data.TargetName or "")
	v10 = tostring(data.Reason or "")
	v11 = os.clock() + (tonumber(data.Seconds) or 25)

	v12.SetAccent(ToastStyle.RED)
	v12.Plate.Rotation = v12.BaseRotation
	v12.Tag.Text = "KICK VOTE"
	v12.Icon.Text = StyledTheme.Icons.Clear
	timerLabel.Visible = true
	v13.Visible = true
	v14.Visible = true
	v13.Interactable = true
	v14.Interactable = true
	v12.Avatar.Set(data.TargetUserId)
	applyLabelMaxWidth(310) -- inferred equivalent call
	refreshLabel() -- inferred equivalent call
	refreshButtons()
	popIn() -- inferred equivalent call
	runCountdown(v16) -- inferred equivalent call
	task.delay((tonumber(data.Seconds) or 25) + 5, function()
		if v16 == count and id == data.Id then
			id = nil
			fadeOut(v16)
		end
	end)
end

local function onTally(data)
	if not id or data.Id ~= id then
		return
	end

	v5 = data.Yes or 0
	v6 = data.No or 0
	v7 = data.Need or v7
	v8 = data.Total or v8
	refreshLabel() -- inferred equivalent call
	refreshButtons()
end

local function onResult(data)
	if not id or data.Id ~= id then
		return
	end

	local v16 = escapeRichText(data.TargetName or "") -- inferred equivalent call
	local v17 = escapeRichText(stageNameFor(data.StudioId)) -- inferred equivalent call

	if data.Outcome == "pass" then
		showMessage(
			"PASSED",
			ToastStyle.GREEN,
			StyledTheme.Icons.Check,
			string.format("<b>%s</b> was removed from <font color=\"%s\">%s</font>", v16, hex2, v17),
			data.TargetUserId,
			3.5
		)
	elseif data.Outcome == "fail" then
		showMessage(
			"FAILED",
			ToastStyle.RED,
			StyledTheme.Icons.Clear,
			string.format("Vote failed %s <b>%s</b> stays", StyledTheme.Icons.Dash, v16),
			data.TargetUserId,
			3.5
		)
	else
		showMessage(
			"CANCELLED",
			ToastStyle.GRAY,
			StyledTheme.Icons.Dash,
			escapeRichText(data.Message or "Vote cancelled."), -- inferred equivalent call
			data.TargetUserId,
			3.5
		)
	end
end

UserInputService.InputBegan:Connect(function(input)
	if not id or UserInputService:GetFocusedTextBox() then
		return
	end

	if input.KeyCode == f1 then
		if id then
			if v4 == true then
				return
			end

			v4 = true
			refreshButtons()
			VoteKickCast:FireServer(id, true)
		end
	elseif input.KeyCode == f2 and id then
		if v4 == false then
			return
		end

		v4 = false
		refreshButtons()
		VoteKickCast:FireServer(id, false)
	end
end)

VoteKickUpdate.OnClientEvent:Connect(function(p, data)
	if typeof(data) ~= "table" then
		return
	end

	if p == "Start" then
		onStart(data)
	elseif p == "Tally" then
		if id then
			if data.Id ~= id then
				return
			end

			v5 = data.Yes or 0
			v6 = data.No or 0
			v7 = data.Need or v7
			v8 = data.Total or v8
			refreshLabel() -- inferred equivalent call
			refreshButtons()
		end
	elseif p == "Result" then
		onResult(data)
	elseif p == "Notice" then
		if not id then
			showMessage("VOTE KICK", ToastStyle.AMBER, "!", escapeRichText(tostring(data.Text or "")), nil, 3.5) -- inferred equivalent call
		end
	elseif p == "Removed" then
		showMessage(
			"REMOVED",
			ToastStyle.RED,
			StyledTheme.Icons.Clear,
			string.format(
				"You were removed from <font color=\"%s\">%s</font> by vote. Back in %s",
				hex2,
				escapeRichText(stageNameFor(data.StudioId)), -- inferred equivalent call
				formatClock(tonumber(data.Seconds) or 0)
			),
			nil,
			5
		)
	elseif p == "Blocked" and not id then
		showMessage(
			"BLOCKED",
			ToastStyle.RED,
			StyledTheme.Icons.Clear,
			string.format(
				"You can't use <font color=\"%s\">%s</font> for %s (vote kick)",
				hex2,
				escapeRichText(stageNameFor(data.StudioId)), -- inferred equivalent call
				formatClock(tonumber(data.Remaining) or 0)
			),
			nil,
			3.5
		)
	end
end)