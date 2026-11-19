local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local StyledTheme = require(script.Parent.StyledTheme)
local ToastStyle = require(script.Parent.ToastStyle)

local z = ToastStyle.Z

local hex = ToastStyle.hex(ToastStyle.AMBER)
local hex2 = ToastStyle.hex(ToastStyle.WHITE)

local function formatPlayerName(p) -- 3 equivalent calls inferred from this helper
	return string.format("<font color=\"%s\"><b>%s</b></font>", hex, p)
end

local function formatSongTitle(p)
	return string.format("<font color=\"%s\"><b>\"%s\"</b></font>", hex2, p)
end

local v = {
	request = { tag = "SONG REQUEST", glyph = "♪", color = ToastStyle.AMBER },
	switch = { tag = "SWITCHED", glyph = "»", color = ToastStyle.AMBER },
	joined = { tag = "JOINED", glyph = "+", color = ToastStyle.GREEN },
	ready = { tag = "READY", glyph = StyledTheme.Icons.Check, color = ToastStyle.GREEN },
	left = { tag = "LEFT", glyph = "«", color = ToastStyle.GRAY },
	requested = { tag = "REQUEST", glyph = "♪", color = ToastStyle.AMBER },
	backing = { tag = "BACKING TRACK", glyph = "♪", color = ToastStyle.AMBER },
	kicked = { tag = "KICKED", glyph = "×", color = ToastStyle.RED },
	removed = { tag = "REMOVED", glyph = "×", color = ToastStyle.RED },
	cancelled = { tag = "CANCELLED", glyph = "×", color = ToastStyle.RED },
	closed = { tag = "ROOM CLOSED", glyph = "×", color = ToastStyle.RED }
}

local SongMoveToast = {}
SongMoveToast.__index = SongMoveToast

function SongMoveToast.new(parent)
	local songMoveToastContainer = Instance.new("Frame")
	songMoveToastContainer.Name = "SongMoveToastContainer"
	songMoveToastContainer.AnchorPoint = Vector2.new(0, 0)
	local topYFor = ToastStyle.TopYFor(parent)
	songMoveToastContainer.Position = UDim2.new(0.5, ToastStyle.ColumnX(), 0, topYFor - 3)
	songMoveToastContainer.AutomaticSize = Enum.AutomaticSize.XY
	songMoveToastContainer.Size = UDim2.new(0, 0, 0, 0)
	songMoveToastContainer.BackgroundTransparency = 1
	songMoveToastContainer.Parent = parent

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Vertical
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	uiListLayout.Padding = UDim.new(0, 0)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = songMoveToastContainer

	return (setmetatable({
		Instance = songMoveToastContainer,
		_container = songMoveToastContainer,
		_topY = topYFor,
		_slots = {},
		_nextLayoutOrder = 0
	}, SongMoveToast))
end

local function createSlotFrame(container, nextLayoutOrder, data, p)
	local toastSlot = Instance.new("CanvasGroup")
	toastSlot.Name = "ToastSlot"
	toastSlot.LayoutOrder = nextLayoutOrder
	toastSlot.AutomaticSize = Enum.AutomaticSize.XY
	toastSlot.Size = UDim2.new(0, 0, 0, 0)
	toastSlot.BackgroundTransparency = 1
	toastSlot.GroupTransparency = 0
	toastSlot.ZIndex = z
	toastSlot:SetAttribute("NoNewUISkin", true)

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 10)
	uiPadding.PaddingRight = UDim.new(0, 10)
	uiPadding.PaddingTop = UDim.new(0, 9)
	uiPadding.PaddingBottom = UDim.new(0, 5)
	uiPadding.Parent = toastSlot

	local height = p and ToastStyle.AvatarCardHeight(34) or 34
	local card = ToastStyle.buildCard({
		name = "ToastCard",
		height = height,
		rotation = nextLayoutOrder % 2 == 0 and 0.7 or -0.7,
		accent = data.color,
		tape = "tr",
		tag = data.tag,
		tagX = 30,
		minWidth = 380,
		seed = nextLayoutOrder * 7 + 3,
		parent = toastSlot
	})

	card.Icon = ToastStyle.makeIcon(card.Content, data.glyph, data.color, 1)

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Size = UDim2.new(0, 0, 1, 0)
	label.Font = Enum.Font.SpecialElite
	label.TextSize = 14
	label.TextColor3 = ToastStyle.INK
	label.TextStrokeColor3 = ToastStyle.DARK
	label.TextStrokeTransparency = 1
	label.RichText = true
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Text = ""
	label.LayoutOrder = 2
	label.ZIndex = z + 4
	label.Parent = card.Content
	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MaxSize = Vector2.new(ToastStyle.LabelMax(190), 1e999)
	uiSizeConstraint.Parent = label

	card.Scribble = ToastStyle.makeScribble(label, data.color, 9)

	if p then
		ToastStyle.attachAvatar(card, p, height, data == v.request)
	end

	local moveButton = ToastStyle.makeButton(card.Content, "MOVE", nil, 3, ToastStyle.AMBER, ToastStyle.DARK, 0, 22)
	moveButton.Name = "MoveButton"
	moveButton.Visible = false
	local dismissButton = ToastStyle.makeButton(
		card.Content,
		"DISMISS",
		nil,
		4,
		ToastStyle.PLATE_LIGHT,
		ToastStyle.INK,
		0,
		22
	)
	dismissButton.Name = "DismissButton"
	dismissButton.Visible = false

	toastSlot.Parent = container
	return toastSlot, label, moveButton, dismissButton, card
end

local function topRowBottom()
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChild("PlayerGui")

	if not playerGui then
		return 0
	end

	local maxValue = 0
	local songListToastGui = playerGui:FindFirstChild("SongListToastGui")

	if songListToastGui then
		for _, guiObject in ipairs(songListToastGui:GetChildren()) do
			if not ((guiObject.Name == "InviteResponseBar" or guiObject.Name == "LoadingToast") and guiObject:IsA("GuiObject") and guiObject.Visible) then
				continue
			end

			maxValue = math.max(maxValue, guiObject.Position.Y.Offset + guiObject.AbsoluteSize.Y)
		end
	end

	local laptopVoteToastGui = playerGui:FindFirstChild("LaptopVoteToastGui")
	local voteBar = laptopVoteToastGui and laptopVoteToastGui:FindFirstChild("VoteBar")

	if voteBar and voteBar.Visible then
		maxValue = math.max(maxValue, voteBar.Position.Y.Offset + voteBar.AbsoluteSize.Y - 5)
	end

	return maxValue
end

local function updateContainerY(state) -- 2 equivalent calls inferred from this helper
	local v2 = topRowBottom()
	local v3 = v2 > 0 and math.max(state._topY - 3, v2 + 3) or state._topY - 3
	state._container.Position = UDim2.new(0.5, ToastStyle.ColumnX(), 0, v3)
end

local function destroySlot(data)
	if data.autoHideThread then
		task.cancel(data.autoHideThread)
	end

	if data.moveConnection then
		data.moveConnection:Disconnect()
	end

	if data.dismissConnection then
		data.dismissConnection:Disconnect()
	end

	data.instance.Active = false
	local tween = TweenService:Create(
		data.instance,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ GroupTransparency = 1 }
	)

	tween.Completed:Connect(function()
		data.instance:Destroy()
	end)
	tween:Play()
end

local function removeSlotFromList(state, p)
	for i, slot in ipairs(state._slots) do
		if slot == p then
			table.remove(state._slots, i)
			break
		end
	end

	destroySlot(p)
end

local function addSlot(state, p, text, callback, p2, p3)
	if #state._slots >= 3 then
		destroySlot(table.remove(state._slots, 1))
	end

	state._nextLayoutOrder += 1
	local slotFrame, v2, v3, v4, v5 = createSlotFrame(
		state._container,
		state._nextLayoutOrder,
		v[p2] or v.requested,
		p3
	)
	v2.Text = text
	ToastStyle.popIn(v5)

	local v6 = { instance = slotFrame }

	local function removeSelf() -- 2 equivalent calls inferred from this helper
		removeSlotFromList(state, v6)
	end

	if p == "request" then
		v3.Visible = true
		v4.Visible = true
		v6.moveConnection = v3.MouseButton1Click:Connect(function()
			removeSelf() -- inferred equivalent call

			if callback then
				callback()
			end
		end)
		v6.dismissConnection = v4.MouseButton1Click:Connect(removeSelf)
	end

	if p ~= "request" then
		v6.autoHideThread = task.delay(5, function()
			v6.autoHideThread = nil
			removeSelf() -- inferred equivalent call
		end)
	end

	table.insert(state._slots, v6)
	updateContainerY(state) -- inferred equivalent call

	if not state._pollThread then
		state._pollThread = task.spawn(function()
			while #state._slots > 0 and state._container.Parent do
				updateContainerY(state) -- inferred equivalent call
				task.wait(0.2)
			end

			state._pollThread = nil
		end)
	end

	return v6
end

function SongMoveToast.ShowRequest(p, p2, p3, p4)
	addSlot(
		p,
		"request",
		string.format("%s requested %s", formatPlayerName(p2), formatSongTitle(p3)), -- inferred equivalent call
		p4,
		"request",
		p2
	)
end

function SongMoveToast.ShowSwitch(p, p2)
	addSlot(p, "info", string.format("Song switched to %s", formatSongTitle(p2)), nil, "switch")
end

function SongMoveToast.ShowPlayerJoined(p, p2)
	addSlot(p, "info", string.format("%s joined the room", formatPlayerName(p2)), nil, "joined", p2)
end

function SongMoveToast.ShowPlayerReady(p, p2)
	addSlot(p, "info", string.format("%s is ready", formatPlayerName(p2)), nil, "ready", p2)
end

function SongMoveToast.ShowPlayerLeft(p, p2)
	addSlot(p, "info", string.format("%s left the room", formatPlayerName(p2)), nil, "left", p2)
end

function SongMoveToast.ShowSongRequested(p, p2, p3)
	addSlot(
		p,
		"info",
		string.format("%s has requested %s", formatPlayerName(p2), formatSongTitle(p3)), -- inferred equivalent call
		nil,
		"requested",
		p2
	)
end

function SongMoveToast.ShowBackingTrackStarted(p, p2, p3)
	addSlot(
		p,
		"info",
		string.format("%s started backing track %s", formatPlayerName(p2), formatSongTitle(p3)), -- inferred equivalent call
		nil,
		"backing",
		p2
	)
end

function SongMoveToast.ShowPlayerKicked(p, p2)
	local addSlot_2 = addSlot(
		p,
		"info",
		string.format("%s was kicked from the room", formatPlayerName(p2)),
		nil,
		"kicked",
		p2
	)

	addSlot_2.survivesHide = true
end

function SongMoveToast.ShowKicked(p, p2)
	local addSlot_2 = addSlot(
		p,
		"info",
		string.format("%s removed you from the room", formatPlayerName(p2)),
		nil,
		"removed",
		p2
	)
	addSlot_2.survivesHide = true
end

function SongMoveToast.ShowInviteCancelled(p, p2)
	local addSlot_2 = addSlot(
		p,
		"info",
		string.format("%s cancelled the invite", formatPlayerName(p2)),
		nil,
		"cancelled",
		p2
	)
	addSlot_2.survivesHide = true
end

function SongMoveToast.ShowRoomClosed(p, p2)
	local addSlot_2 = addSlot(p, "info", string.format("%s closed the room", formatPlayerName(p2)), nil, "closed", p2)
	addSlot_2.survivesHide = true
end

function SongMoveToast:Hide()
	local slots = {}

	for _, slot in ipairs(self._slots) do
		if slot.survivesHide then
			table.insert(slots, slot)
		else
			destroySlot(slot)
		end
	end

	self._slots = slots
end

function SongMoveToast:Destroy()
	self:Hide()
	self._container:Destroy()
end

return SongMoveToast