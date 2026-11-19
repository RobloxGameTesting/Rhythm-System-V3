local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToastStyle = require(ReplicatedStorage.Modules.SongListUI.ToastStyle)
local PStudioConfig = require(script.Parent.PStudioConfig)

local PStudioToasts = {}

local parent = nil
local v = {}
local v2 = {}
local v3 = {}

function PStudioToasts.Escape(value)
	return (tostring(value or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

function PStudioToasts.Init(p)
	parent = p
end

local function relayout()
	if not parent then
		return
	end

	local v4 = ToastStyle.TopYFor(parent) + 6
	local voteBottom = ToastStyle.VoteBottom()

	if voteBottom > 0 then
		v4 = math.max(v4, voteBottom + 14)
	end

	for _, v5 in ipairs(v) do
		v5.Card.Position = UDim2.new(0.5, ToastStyle.ColumnX() + 10, 0, v4)
		v4 += v5.height + 12
	end
end

local function insertItem(p, p2) -- 3 equivalent calls inferred from this helper
	if p2 then
		table.insert(v, 1, p)
	else
		table.insert(v, p)
	end

	relayout()
end

local function removeItem(p) -- 4 equivalent calls inferred from this helper
	local index = table.find(v, p)

	if index then
		table.remove(v, index)
	end

	if p.Card then
		p.Card:Destroy()
	end

	relayout()
end

local function makeLabel(content, layoutOrder)
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.RichText = true
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Size = UDim2.new(0, 0, 1, 0)
	label.Font = Enum.Font.SpecialElite
	label.TextSize = 14
	label.TextColor3 = ToastStyle.INK
	label.TextStrokeTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Text = ""
	label.LayoutOrder = layoutOrder
	label.ZIndex = ToastStyle.Z + 4
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = content
	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MaxSize = Vector2.new(ToastStyle.LabelMax(190), 1e999)
	uiSizeConstraint.Parent = label
	return label
end

function PStudioToasts.ShowRequest(data, callback, callback2)
	if not parent or v2[data.id] then
		return
	end

	local card = ToastStyle.buildCard({
		name = "PStudioRequest",
		height = ToastStyle.AvatarCardHeight(42),
		rotation = -0.5,
		accent = ToastStyle.AMBER,
		tape = "both",
		tag = PStudioConfig.TEXT.RequestTag,
		tagX = 40,
		minWidth = 380,
		seed = 7100 + data.id % 50,
		padL = 16,
		padR = 14,
		gap = 8
	})

	card.Icon = ToastStyle.makeIcon(card.Content, "+", ToastStyle.AMBER, 1)
	local label = makeLabel(card.Content, 2)
	local displayName = data.displayName and data.displayName ~= "" and data.displayName or data.name
	label.Text = string.format(
		PStudioConfig.TEXT.RequestLine,
		PStudioToasts.Escape(displayName),
		PStudioToasts.Escape(data.studioName)
	)
	card.Scribble = ToastStyle.makeScribble(label, ToastStyle.AMBER, 10)
	ToastStyle.attachAvatar(
		card,
		{ userId = data.requesterId, name = data.name },
		ToastStyle.AvatarCardHeight(42),
		true
	)
	local acceptButton = ToastStyle.makeButton(
		card.Content,
		PStudioConfig.TEXT.Accept,
		nil,
		3,
		ToastStyle.GREEN,
		ToastStyle.DARK,
		0,
		24
	)
	acceptButton.Name = "AcceptButton"
	local denyButton = ToastStyle.makeButton(
		card.Content,
		PStudioConfig.TEXT.Deny,
		nil,
		4,
		ToastStyle.RED,
		ToastStyle.WHITE,
		0,
		24
	)
	denyButton.Name = "DenyButton"

	card.Card.AnchorPoint = Vector2.new(0, 0)
	card.Card.Parent = parent
	local v4 = {
		Card = card.Card,
		height = ToastStyle.AvatarCardHeight(42),
		handle = card
	}
	v2[data.id] = v4
	insertItem(v4, false) -- inferred equivalent call
	ToastStyle.popIn(card)
	card.Flash()

	acceptButton.MouseButton1Click:Connect(function()
		callback()
	end)
	denyButton.MouseButton1Click:Connect(function()
		callback2()
	end)

	task.delay((data.timeout or PStudioConfig.REQUEST_TIMEOUT) + 2, function()
		PStudioToasts.RemoveRequest(data.id)
	end)
end

function PStudioToasts.RemoveRequest(p)
	local v4 = v2[p]

	if v4 then
		v2[p] = nil
		removeItem(v4) -- inferred equivalent call
	end
end

local v4 = {}

function PStudioToasts.ShowInvite(data, callback, callback2)
	pcall(function()
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		require(ReplicatedStorage2.Modules.HapticFx).Play("Invite")
	end)

	if not parent or v4[data.id] then
		return
	end

	local card = ToastStyle.buildCard({
		name = "PStudioInvite",
		height = ToastStyle.AvatarCardHeight(42),
		rotation = 0.5,
		accent = ToastStyle.GREEN,
		tape = "both",
		tag = PStudioConfig.TEXT.InviteTag,
		tagX = 40,
		minWidth = 400,
		seed = 7400 + data.id % 50,
		padL = 16,
		padR = 14,
		gap = 8
	})

	card.Icon = ToastStyle.makeIcon(card.Content, "+", ToastStyle.GREEN, 1)
	local label = makeLabel(card.Content, 2)
	local ownerDisplayName = data.ownerDisplayName and data.ownerDisplayName ~= "" and data.ownerDisplayName
		or data.ownerName
	label.Text = string.format(
		PStudioConfig.TEXT.InviteLine,
		PStudioToasts.Escape(ownerDisplayName),
		PStudioToasts.Escape(data.studioName)
	)
	card.Scribble = ToastStyle.makeScribble(label, ToastStyle.GREEN, 10)
	ToastStyle.attachAvatar(card, { name = data.ownerName }, ToastStyle.AvatarCardHeight(42), true)
	local joinButton = ToastStyle.makeButton(
		card.Content,
		PStudioConfig.TEXT.JoinInvite,
		nil,
		3,
		ToastStyle.GREEN,
		ToastStyle.DARK,
		0,
		24
	)
	joinButton.Name = "JoinButton"
	local declineButton = ToastStyle.makeButton(
		card.Content,
		PStudioConfig.TEXT.DeclineInvite,
		nil,
		4,
		ToastStyle.RED,
		ToastStyle.WHITE,
		0,
		24
	)
	declineButton.Name = "DeclineButton"

	card.Card.AnchorPoint = Vector2.new(0, 0)
	card.Card.Parent = parent
	local v5 = {
		Card = card.Card,
		height = ToastStyle.AvatarCardHeight(42),
		handle = card
	}
	v4[data.id] = v5
	insertItem(v5, false) -- inferred equivalent call
	ToastStyle.popIn(card)
	card.Flash()

	joinButton.MouseButton1Click:Connect(function()
		callback()
	end)
	declineButton.MouseButton1Click:Connect(function()
		callback2()
	end)

	task.delay((data.timeout or PStudioConfig.INVITE_TIMEOUT) + 2, function()
		PStudioToasts.RemoveInvite(data.id)
	end)
end

function PStudioToasts.RemoveInvite(p)
	local v5 = v4[p]

	if v5 then
		v4[p] = nil
		removeItem(v5) -- inferred equivalent call
	end
end

function PStudioToasts.Notice(p, p2, p3)
	if not parent then
		return
	end

	local accent = p2 == "ok" and ToastStyle.GREEN

	if not accent then
		accent = p2 == "error" and ToastStyle.RED or ToastStyle.AMBER
	end

	while #v3 >= 3 do
		removeItem(table.remove(v3, 1)) -- inferred equivalent call
	end

	local card = ToastStyle.buildCard({
		name = "PStudioNotice",
		height = p3 and ToastStyle.AvatarCardHeight(36) or 36,
		rotation = 0.4,
		accent = accent,
		tape = "tr",
		tag = PStudioConfig.TEXT.HudTag,
		tagX = 40,
		minWidth = 260,
		seed = #v3 * 3 + 7200,
		padL = 16,
		padR = 14,
		gap = 8
	})

	local label = makeLabel(card.Content, 1)
	label.Text = PStudioToasts.Escape(p)
	card.Scribble = ToastStyle.makeScribble(label, accent, 8)

	if p3 then
		ToastStyle.attachAvatar(card, p3, ToastStyle.AvatarCardHeight(36))
	end

	card.Card.AnchorPoint = Vector2.new(0, 0)
	card.Card.Parent = parent
	local v5 = {
		Card = card.Card,
		height = p3 and ToastStyle.AvatarCardHeight(36) or 36,
		handle = card
	}
	table.insert(v3, v5)
	insertItem(v5, false) -- inferred equivalent call
	ToastStyle.popIn(card)
	card.Flash()
	task.delay(4, function()
		local index = table.find(v3, v5)

		if index then
			table.remove(v3, index)
			removeItem(v5) -- inferred equivalent call
		end
	end)
end

return PStudioToasts