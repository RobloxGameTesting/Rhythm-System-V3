local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ToastStyle = require(ReplicatedStorage.Modules.SongListUI.ToastStyle)
local mk = ToastStyle.mk

local VoteKickUI = {}

local v = {
	{ Id = "Griefing", Label = "Griefing" },
	{ Id = "Noise", Label = "Spam noise" },
	{ Id = "Blocking", Label = "Blocking / AFK" }
}

local voteKickPickerGui = nil
local panel = nil
local v2 = nil
local v3 = nil
local v4 = {}
local id = nil
local v5 = nil

local function escapeRichText(displayName) -- 1 equivalent call inferred from this helper
	return (tostring(displayName):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function refresh()
	for k, v6 in pairs(v4) do
		local v7 = k == id
		v6.BackgroundColor3 = v7 and ToastStyle.AMBER or ToastStyle.PLATE_LIGHT
		v6.TextColor3 = v7 and ToastStyle.DARK or ToastStyle.INK
	end

	v3.BackgroundColor3 = id and ToastStyle.RED or ToastStyle.PLATE_LIGHT
	v3.TextColor3 = id and ToastStyle.WHITE or ToastStyle.GRAY
end

local function close() -- 1 equivalent call inferred from this helper
	if voteKickPickerGui then
		voteKickPickerGui.Enabled = false
	end

	v5 = nil
end
VoteKickUI.Close = close

local function build()
	if voteKickPickerGui then
		return
	end

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	voteKickPickerGui = Instance.new("ScreenGui")
	voteKickPickerGui.Name = "VoteKickPickerGui"
	voteKickPickerGui.ResetOnSpawn = false
	voteKickPickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	voteKickPickerGui.DisplayOrder = 57
	voteKickPickerGui.Enabled = false
	voteKickPickerGui:SetAttribute("NoNewUISkin", true)
	voteKickPickerGui.Parent = playerGui

	mk("TextButton", {
		Name = "Catcher",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 1
	}, voteKickPickerGui).Activated:Connect(close)

	panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.fromOffset(208, 178)
	panel.BackgroundColor3 = ToastStyle.PLATE
	panel.BackgroundTransparency = 0.02
	panel.BorderSizePixel = 0
	panel.ZIndex = 2
	panel:SetAttribute("NoNewUISkin", true)
	panel.Parent = voteKickPickerGui
	mk("UICorner", { CornerRadius = UDim.new(0, 6) }, panel)
	mk("UIStroke", { Color = ToastStyle.RED, Thickness = 1, Transparency = 0.5 }, panel)
	mk(
		"UIPadding",
		{
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 9)
		},
		panel
	)

	mk("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }, panel)

	mk("Frame", {
		Name = "Stripe",
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = ToastStyle.RED,
		BorderSizePixel = 0,
		ZIndex = 3
	}, panel)

	v2 = mk("TextLabel", {
		Name = "Title",
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		RichText = true,
		Font = Enum.Font.SpecialElite,
		TextSize = 13,
		TextColor3 = ToastStyle.INK,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = "",
		ZIndex = 3
	}, panel)

	mk("TextLabel", {
		Name = "Hint",
		LayoutOrder = 3,
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = ToastStyle.GRAY,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = "Players holding an instrument vote for 25s.",
		ZIndex = 3
	}, panel)

	for i, v6 in ipairs(v) do
		local v7 = mk("TextButton", {
			Name = "Chip_" .. v6.Id,
			LayoutOrder = 3 + i,
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundColor3 = ToastStyle.PLATE_LIGHT,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Enum.Font.SpecialElite,
			TextSize = 13,
			TextColor3 = ToastStyle.INK,
			Text = v6.Label,
			ZIndex = 3
		}, panel)

		mk("UICorner", { CornerRadius = UDim.new(0, 4) }, v7)
		v7.Activated:Connect(function()
			id = v6.Id
			refresh()
		end)
		v4[v6.Id] = v7
	end

	local v6 = mk("Frame", {
		Name = "Buttons",
		LayoutOrder = 10,
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		ZIndex = 3
	}, panel)
	local v7 = mk("TextButton", {
		Name = "Cancel",
		Size = UDim2.new(0.5, -3, 1, 0),
		BackgroundColor3 = ToastStyle.PLATE_LIGHT,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.PermanentMarker,
		TextSize = 13,
		TextColor3 = ToastStyle.GRAY,
		Text = "Cancel",
		ZIndex = 3
	}, v6)

	mk("UICorner", { CornerRadius = UDim.new(0, 4) }, v7)
	v7.Activated:Connect(close)

	v3 = mk("TextButton", {
		Name = "Start",
		Position = UDim2.new(0.5, 3, 0, 0),
		Size = UDim2.new(0.5, -3, 1, 0),
		BackgroundColor3 = ToastStyle.PLATE_LIGHT,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.PermanentMarker,
		TextSize = 13,
		TextColor3 = ToastStyle.GRAY,
		Text = "Start vote",
		ZIndex = 3
	}, v6)

	mk("UICorner", { CornerRadius = UDim.new(0, 4) }, v3)
	v3.Activated:Connect(function()
		if not (id and v5) then
			return
		end

		local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
		local voteKickStart = remoteEvents and remoteEvents:FindFirstChild("VoteKickStart")

		if voteKickStart then
			voteKickStart:FireServer(v5.UserId, id)
		end

		close() -- inferred equivalent call
	end)
end

function VoteKickUI.OpenPicker(p, p2)
	if not p2 or p2 == Players.LocalPlayer then
		return
	end

	build()
	v5 = p2
	id = nil
	v2.Text = string.format("Remove <b>%s</b> from the stage?", escapeRichText(p2.DisplayName)) -- inferred equivalent call
	refresh()

	local currentCamera = workspace.CurrentCamera
	local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
	local absolutePosition = p.AbsolutePosition
	local absoluteSize = p.AbsoluteSize
	local v6 = math.clamp(absolutePosition.X, 8, (math.max(8, viewportSize.X - 208 - 8)))
	local v7 = absolutePosition.Y + absoluteSize.Y + 4 + 178 <= viewportSize.Y - 8
		and absolutePosition.Y + absoluteSize.Y + 4
		or math.max(8, absolutePosition.Y - 178 - 4)
	panel.Position = UDim2.fromOffset(v6, v7)
	voteKickPickerGui.Enabled = true
end

local v6 = {
	Drum = "DRUMS",
	GuitarRhythm = "RHYTHM",
	GuitarLead = "LEAD",
	Bass = "BASS",
	Keyboard = "KEYS",
	Piano = "PIANO"
}

local v7 = {
	{ Id = "Griefing", Label = "Griefing" },
	{ Id = "Noise", Label = "Noise" },
	{ Id = "Blocking", Label = "AFK" }
}

function VoteKickUI.GetTargets()
	local localPlayer = Players.LocalPlayer
	local voteKickStageId = localPlayer:GetAttribute("VoteKickStageId")
	local targets = {}

	if voteKickStageId == nil then
		return targets
	end

	for _, v8 in ipairs(Players:GetPlayers()) do
		if v8 ~= localPlayer and v8:GetAttribute("VoteKickStageId") == voteKickStageId then
			table.insert(targets, v8)
		end
	end

	table.sort(targets, function(a, b): boolean
		return string.lower(a.DisplayName) < string.lower(b.DisplayName)
	end)

	return targets
end

local voteKickMenuGui = nil
local panel2 = nil
local v8 = nil
local v9 = nil
local v10 = {}
local v11 = {}
local v12 = {}
local v13 = nil
local id2 = nil

local function menuRefresh()
	for k, v14 in pairs(v11) do
		local v15 = k == v13
		v14.BackgroundColor3 = v15 and ToastStyle.AMBER or ToastStyle.PLATE_LIGHT
		local v16 = v12[k]

		if not v16 then
			continue
		end

		v16.name.TextColor3 = v15 and ToastStyle.DARK or ToastStyle.INK
		v16.instr.TextColor3 = v15 and ToastStyle.DARK or ToastStyle.GRAY
	end

	for k, v14 in pairs(v10) do
		local v15 = k == id2
		v14.BackgroundColor3 = v15 and ToastStyle.AMBER or ToastStyle.PLATE_LIGHT
		v14.TextColor3 = v15 and ToastStyle.DARK or ToastStyle.INK
	end

	local v14

	if v13 == nil then
		v14 = false
	else
		v14 = id2 ~= nil
	end

	v9.BackgroundColor3 = v14 and ToastStyle.RED or ToastStyle.PLATE_LIGHT
	v9.TextColor3 = v14 and ToastStyle.WHITE or ToastStyle.GRAY
end

local function menuClose() -- 1 equivalent call inferred from this helper
	if voteKickMenuGui then
		voteKickMenuGui.Enabled = false
	end

	v13 = nil
	id2 = nil
end
VoteKickUI.CloseMenu = menuClose

local function buildMenu()
	if voteKickMenuGui then
		return
	end

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	voteKickMenuGui = Instance.new("ScreenGui")
	voteKickMenuGui.Name = "VoteKickMenuGui"
	voteKickMenuGui.ResetOnSpawn = false
	voteKickMenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	voteKickMenuGui.DisplayOrder = 57
	voteKickMenuGui.Enabled = false
	voteKickMenuGui:SetAttribute("NoNewUISkin", true)
	voteKickMenuGui.Parent = playerGui

	mk("TextButton", {
		Name = "Catcher",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 1
	}, voteKickMenuGui).Activated:Connect(menuClose)

	panel2 = Instance.new("Frame")
	panel2.Name = "Panel"
	panel2.Size = UDim2.fromOffset(216, 200)
	panel2.BackgroundColor3 = ToastStyle.PLATE
	panel2.BackgroundTransparency = 0.02
	panel2.BorderSizePixel = 0
	panel2.ZIndex = 2
	panel2:SetAttribute("NoNewUISkin", true)
	panel2.Parent = voteKickMenuGui
	mk("UICorner", { CornerRadius = UDim.new(0, 6) }, panel2)
	mk("UIStroke", { Color = ToastStyle.RED, Thickness = 1, Transparency = 0.5 }, panel2)
	mk(
		"UIPadding",
		{
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 9)
		},
		panel2
	)

	mk("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) }, panel2)

	mk("Frame", {
		Name = "Stripe",
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = ToastStyle.RED,
		BorderSizePixel = 0,
		ZIndex = 3
	}, panel2)
	mk("TextLabel", {
		Name = "Title",
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.SpecialElite,
		TextSize = 13,
		TextColor3 = ToastStyle.INK,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "Kick who?",
		ZIndex = 3
	}, panel2)

	v8 = mk("Frame", {
		Name = "List",
		LayoutOrder = 3,
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		ZIndex = 3
	}, panel2)
	mk("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3) }, v8)

	local v14 = mk("Frame", {
		Name = "Reasons",
		LayoutOrder = 4,
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		ZIndex = 3
	}, panel2)
	mk(
		"UIListLayout",
		{
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4)
		},
		v14
	)

	for i, v15 in ipairs(v7) do
		local v16 = mk("TextButton", {
			Name = "Reason_" .. v15.Id,
			LayoutOrder = i,
			Size = UDim2.new(1 / 3, -3, 1, 0),
			BackgroundColor3 = ToastStyle.PLATE_LIGHT,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Enum.Font.SpecialElite,
			TextSize = 11,
			TextColor3 = ToastStyle.INK,
			Text = v15.Label,
			ZIndex = 3
		}, v14)

		mk("UICorner", { CornerRadius = UDim.new(0, 4) }, v16)
		v16.Activated:Connect(function()
			id2 = v15.Id
			menuRefresh()
		end)
		v10[v15.Id] = v16
	end

	local v15 = mk("Frame", {
		Name = "Buttons",
		LayoutOrder = 5,
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		ZIndex = 3
	}, panel2)
	local v16 = mk("TextButton", {
		Name = "Cancel",
		Size = UDim2.new(0.5, -3, 1, 0),
		BackgroundColor3 = ToastStyle.PLATE_LIGHT,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.PermanentMarker,
		TextSize = 13,
		TextColor3 = ToastStyle.GRAY,
		Text = "Cancel",
		ZIndex = 3
	}, v15)

	mk("UICorner", { CornerRadius = UDim.new(0, 4) }, v16)
	v16.Activated:Connect(menuClose)

	v9 = mk("TextButton", {
		Name = "Start",
		Position = UDim2.new(0.5, 3, 0, 0),
		Size = UDim2.new(0.5, -3, 1, 0),
		BackgroundColor3 = ToastStyle.PLATE_LIGHT,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.PermanentMarker,
		TextSize = 13,
		TextColor3 = ToastStyle.GRAY,
		Text = "Start vote",
		ZIndex = 3
	}, v15)

	mk("UICorner", { CornerRadius = UDim.new(0, 4) }, v9)
	v9.Activated:Connect(function()
		if not (v13 and id2) then
			return
		end

		local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
		local voteKickStart = remoteEvents and remoteEvents:FindFirstChild("VoteKickStart")

		if voteKickStart then
			voteKickStart:FireServer(v13.UserId, id2)
		end

		menuClose() -- inferred equivalent call
	end)
end

function VoteKickUI.OpenMenu(p, p2)
	local targets = VoteKickUI.GetTargets()

	if #targets == 0 then
		return
	end

	buildMenu()

	for _, v14 in pairs(v11) do
		v14:Destroy()
	end

	v11 = {}
	v12 = {}
	v13 = nil
	id2 = nil

	local v14 = math.min(#targets, 8)

	for i = 1, v14 do
		local target = targets[i]
		local v15 = mk("TextButton", {
			Name = "Row_" .. tostring(target.UserId),
			LayoutOrder = i,
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundColor3 = ToastStyle.PLATE_LIGHT,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
			ZIndex = 3
		}, v8)

		mk("UICorner", { CornerRadius = UDim.new(0, 4) }, v15)
		local name = mk("TextLabel", {
			Name = "PlayerName",
			Position = UDim2.fromOffset(8, 0),
			Size = UDim2.new(1, -66, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.SpecialElite,
			TextSize = 13,
			TextColor3 = ToastStyle.INK,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = target.DisplayName,
			ZIndex = 4
		}, v15)

		local instr = mk("TextLabel", {
			Name = "Instr",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.fromOffset(52, 14),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 10,
			TextColor3 = ToastStyle.GRAY,
			TextXAlignment = Enum.TextXAlignment.Right,
			Text = v6[target:GetAttribute("EquippedInstrumentType")] or "",
			ZIndex = 4
		}, v15)

		v15.Activated:Connect(function()
			v13 = target
			menuRefresh()
		end)
		v11[target] = v15
		v12[target] = { name = name, instr = instr }
	end

	if v14 == 1 then
		v13 = targets[1]
	end

	menuRefresh()

	local v15 = v14 * 24 + (v14 - 1) * 3
	v8.Size = UDim2.new(1, 0, 0, v15)
	local v16 = v15 + 105
	panel2.Size = UDim2.fromOffset(216, v16)

	local currentCamera = workspace.CurrentCamera
	local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
	local v17 = p2 or p
	local absolutePosition = v17.AbsolutePosition
	local absoluteSize = v17.AbsoluteSize
	local v18

	if absolutePosition.X - 216 - 10 >= 8 then
		v18 = absolutePosition.X - 216 - 10
	elseif absolutePosition.X + absoluteSize.X + 10 + 216 <= viewportSize.X - 8 then
		v18 = absolutePosition.X + absoluteSize.X + 10
	else
		v18 = math.clamp(absolutePosition.X, 8, (math.max(8, viewportSize.X - 216 - 8)))
	end

	local v19 = math.clamp(absolutePosition.Y + absoluteSize.Y - v16, 8, (math.max(8, viewportSize.Y - v16 - 8)))
	panel2.Position = UDim2.fromOffset(v18, v19)
	voteKickMenuGui.Enabled = true
end

return VoteKickUI