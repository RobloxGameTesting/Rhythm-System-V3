local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Theme = require(script.Parent.Theme)
local Retro = require(script.Parent.Retro)
local PrivateStudio = ReplicatedStorage.Modules:WaitForChild("PrivateStudio")
local PStudioConfig = require(PrivateStudio:WaitForChild("PStudioConfig"))
local PStudioState = require(PrivateStudio:WaitForChild("PStudioState"))

local Colors = Theme.Colors
local text = PStudioConfig.TEXT
local LocalPlayer = Players.LocalPlayer

local child = ReplicatedStorage:WaitForChild(PStudioConfig.REMOTES_FOLDER, 10)
local kick = child and child:FindFirstChild("Kick")
local leave = child and child:FindFirstChild("Leave")
local invite = child and child:FindFirstChild("Invite")
local getInvitable = child and child:FindFirstChild("GetInvitable")

local LaptopStudioPanel = {}

local function esc(value) -- 4 equivalent calls inferred from this helper
	return (tostring(value or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function hex(data) -- 4 equivalent calls inferred from this helper
	return string.format(
		"#%02X%02X%02X",
		math.floor(data.R * 255 + 0.5),
		math.floor(data.G * 255 + 0.5),
		(math.floor(data.B * 255 + 0.5))
	)
end

local function newLabel(parent, text2, options)
	local v = options or {}
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Font = v.font or Theme.Fonts.Regular
	textLabel.TextSize = v.size or 11
	textLabel.TextColor3 = v.color or Colors.TextPrimary
	textLabel.TextXAlignment = v.xAlign or Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.RichText = v.rich == true
	textLabel.TextTruncate = v.truncate and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None
	textLabel.Text = text2
	textLabel.Size = v.sizeUDim or UDim2.new(1, 0, 1, 0)
	textLabel.Parent = parent
	return textLabel
end

local function clearRows(stu)
	for _, frame in ipairs(stu.list:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
end

local function resetConfirm(p) -- 6 equivalent calls inferred from this helper
	p.confirmKey = nil
	p.confirmAt = 0
	local leaveItem = p.leaveItem

	if leaveItem and leaveItem.setText then
		leaveItem.setText(text.LeaveStudio)
	end
end

local function armConfirm(p, confirmKey) -- 1 equivalent call inferred from this helper
	local stu = p.stu
	stu.confirmKey = confirmKey
	stu.confirmAt = os.clock()
	local confirmAt = stu.confirmAt
	task.delay(2.55, function()
		if p.stu == stu and stu.confirmKey == confirmKey and stu.confirmAt == confirmAt then
			resetConfirm(stu) -- inferred equivalent call
			LaptopStudioPanel._render(p)
		end
	end)
end

local function isConfirmed(p, p2): boolean -- 3 equivalent calls inferred from this helper
	return p.confirmKey == p2 and os.clock() - p.confirmAt <= 2.5
end

local function fetchInvitable(p) -- 2 equivalent calls inferred from this helper
	local stu = p.stu

	if stu and getInvitable and not stu.fetching then
		stu.fetching = true
		task.spawn(function()
			local success, result = pcall(function()
				return getInvitable:InvokeServer()
			end)

			stu.fetching = false

			if success and type(result) == "table" and p.stu == stu and stu.mode == "invite" then
				stu.invitable = result
				LaptopStudioPanel._render(p)
			end
		end)
	end
end

local function addInfoRow(stu, text2)
	local info = Instance.new("Frame")
	info.Name = "Info"
	info.BackgroundTransparency = 1
	info.BorderSizePixel = 0
	info.Size = UDim2.new(1, -8, 0, 26)
	info.ZIndex = 17
	info.Parent = stu.list
	local newLabel_2 = newLabel(info, text2, {
		font = Theme.Fonts.Regular,
		size = 10,
		color = Colors.TextSecondary,
		xAlign = Enum.TextXAlignment.Center
	})
	newLabel_2.ZIndex = 18
end

local function renderInvite(p)
	local stu = p.stu
	stu.header.Text = text.InviteHeader
	local invitable = stu.invitable

	if invitable == nil then
		addInfoRow(stu, text.InviteLoading)
		return
	end

	if #invitable == 0 then
		addInfoRow(stu, text.NoInvitable)
		return
	end

	for i, v in ipairs(invitable) do
		local frame = Instance.new("Frame")
		frame.Name = "Invitable_" .. v.userId
		frame.BackgroundColor3 = Colors.Surface
		frame.BorderSizePixel = 0
		frame.LayoutOrder = i
		frame.Size = UDim2.new(1, -8, 0, 26)
		frame.ZIndex = 17
		frame.Parent = stu.list
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = Theme.Radius.Small
		uiCorner.Parent = frame

		local displayName = v.displayName and v.displayName ~= "" and v.displayName or v.name
		local v2 = newLabel(
			frame,
			string.format(
				"<b>%s</b>  <font color=\"%s\">@%s</font>",
				esc(displayName), -- inferred equivalent call
				hex(Colors.TextSecondary), -- inferred equivalent call
				esc(v.name) -- inferred equivalent call
			),
			{
				font = Theme.Fonts.Regular,
				size = 10,
				rich = true,
				truncate = true,
				sizeUDim = UDim2.new(1, -60, 1, 0)
			}
		)

		v2.Position = UDim2.new(0, 6, 0, 0)
		v2.ZIndex = 18

		local invited = v.invited == true
		local inviteButton = Instance.new("TextButton")
		inviteButton.Name = "InviteButton"
		inviteButton.AutoButtonColor = false
		inviteButton.BackgroundColor3 = invited and Colors.Surface or Colors.Accent
		inviteButton.BorderSizePixel = 0
		inviteButton.Font = Theme.Fonts.Label
		inviteButton.TextSize = 9
		inviteButton.TextColor3 = invited and Colors.TextSecondary or Colors.AccentText
		inviteButton.Text = invited and text.InviteSent or text.InviteAction
		inviteButton.AnchorPoint = Vector2.new(1, 0.5)
		inviteButton.Position = UDim2.new(1, -4, 0.5, 0)
		inviteButton.Size = UDim2.new(0, 46, 0, 18)
		inviteButton.ZIndex = 19
		inviteButton.Parent = frame
		local uiCorner2 = Instance.new("UICorner")
		uiCorner2.CornerRadius = Theme.Radius.Small
		uiCorner2.Parent = inviteButton

		if not invited then
			inviteButton.Activated:Connect(function()
				if v.invited then
					return
				end

				v.invited = true

				if invite then
					invite:FireServer(v.userId)
				end

				LaptopStudioPanel._render(p)
				task.delay(0.5, function()
					local v3 = p
					local stu2 = v3.stu

					if stu2 and getInvitable then
						if stu2.fetching then
							return
						end

						stu2.fetching = true
						task.spawn(function()
							local success, result = pcall(function()
								return getInvitable:InvokeServer()
							end)

							stu2.fetching = false

							if success and type(result) == "table" and v3.stu == stu2 and stu2.mode == "invite" then
								stu2.invitable = result
								LaptopStudioPanel._render(v3)
							end
						end)
					end
				end)
			end)
		end
	end
end

local function setMode(p, mode) -- 2 equivalent calls inferred from this helper
	local stu = p.stu

	if stu.mode == mode then
		return
	end

	stu.mode = mode

	if stu.inviteItem and stu.inviteItem.setText then
		stu.inviteItem.setText(mode == "invite" and text.BackButton or text.InviteButton)
	end

	stu.list.CanvasPosition = Vector2.zero

	if mode == "invite" then
		stu.invitable = nil
		fetchInvitable(p) -- inferred equivalent call
	end

	LaptopStudioPanel._render(p)
end

function LaptopStudioPanel._toggleInvite(p)
	local stu = p.stu

	if stu then
		setMode(p, stu.mode == "invite" and "players" or "invite")
	end
end

function LaptopStudioPanel._render(p)
	local stu = p.stu

	if not stu then
		return
	end

	clearRows(stu)
	local v = PStudioState.Get()

	if v then
		local success = v.isPublic and Colors.Success or Colors.Accent
		stu.status.Text = string.format(
			"%s  %d/%d",
			v.isPublic and text.Public or text.Private,
			#v.members,
			v.maxPlayers
		)
		stu.status.TextColor3 = success
		stu.nameLabel.Text = v.name

		local visible = v.ownerId == LocalPlayer.UserId

		if stu.inviteItem and stu.inviteItem.button then
			stu.inviteItem.button.Visible = visible
		end

		if not visible and stu.mode == "invite" then
			stu.mode = "players"
		end

		if stu.mode == "invite" then
			renderInvite(p)
			return
		end

		stu.header.Text = text.PlayersHeader

		for i, member in ipairs(v.members) do
			local frame = Instance.new("Frame")
			frame.Name = "Member_" .. member.userId
			frame.BackgroundColor3 = Colors.Surface
			frame.BorderSizePixel = 0
			frame.LayoutOrder = i
			frame.Size = UDim2.new(1, -8, 0, 26)
			frame.ZIndex = 17
			frame.Parent = stu.list
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = Theme.Radius.Small
			uiCorner.Parent = frame

			local displayName = member.displayName and member.displayName ~= "" and member.displayName or member.name
			local v2

			if member.isOwner then
				v2 = string.format("  <font color=\"%s\">%s</font>", hex(Colors.Accent), text.Owner) -- inferred equivalent call
			else
				v2 = ""
			end

			if member.userId == LocalPlayer.UserId then
				v2 ..= string.format("  <font color=\"%s\">%s</font>", hex(Colors.TextSecondary), text.You) -- inferred equivalent call
			end

			local v3 = newLabel(
				frame,
				string.format(
					"<b>%s</b>  <font color=\"%s\">@%s</font>%s",
					esc(displayName), -- inferred equivalent call
					hex(Colors.TextSecondary), -- inferred equivalent call
					esc(member.name), -- inferred equivalent call
					v2
				),
				{
					font = Theme.Fonts.Regular,
					size = 10,
					rich = true,
					truncate = true,
					sizeUDim = UDim2.new(1, -(visible and not member.isOwner and 56 or 6), 1, 0)
				}
			)

			v3.Position = UDim2.new(0, 6, 0, 0)
			v3.ZIndex = 18

			if not (visible and member.userId ~= LocalPlayer.UserId) then
				continue
			end

			local confirmKey = "kick:" .. member.userId
			local confirmed = isConfirmed(stu, confirmKey) -- inferred equivalent call
			local kick2 = Instance.new("TextButton")
			kick2.Name = "Kick"
			kick2.AutoButtonColor = false
			kick2.BackgroundColor3 = confirmed and Colors.Danger or Colors.SurfaceHover
			kick2.BorderSizePixel = 0
			kick2.Font = Theme.Fonts.Label
			kick2.TextSize = 9
			kick2.TextColor3 = Colors.TextPrimary
			kick2.Text = confirmed and text.KickConfirm or text.Kick
			kick2.AnchorPoint = Vector2.new(1, 0.5)
			kick2.Position = UDim2.new(1, -4, 0.5, 0)
			kick2.Size = UDim2.new(0, 46, 0, 18)
			kick2.ZIndex = 19
			kick2.Parent = frame
			local uiCorner2 = Instance.new("UICorner")
			uiCorner2.CornerRadius = Theme.Radius.Small
			uiCorner2.Parent = kick2
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Thickness = 1
			uiStroke.Color = confirmed and Colors.TextPrimary or Colors.Danger
			uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			uiStroke.Parent = kick2
			kick2.Activated:Connect(function()
				if isConfirmed(stu, confirmKey) then -- inferred equivalent call
					resetConfirm(stu) -- inferred equivalent call

					if kick then
						kick:FireServer(member.userId)
					end
				else
					armConfirm(p, confirmKey) -- inferred equivalent call
					LaptopStudioPanel._render(p)
				end
			end)
		end
	else
		stu.status.Text = ""
		stu.nameLabel.Text = "Not in a studio"
	end
end

local function setSongListHidden(p, visible)
	local stu = p.stu
	local laptopSongListUI = p.gui and p.gui:FindFirstChild("LaptopSongListUI")

	if visible then
		if not stu.songHidden then
			stu.songHidden = true
			stu.songWasVisible = laptopSongListUI ~= nil and laptopSongListUI.Visible
		end

		if laptopSongListUI then
			laptopSongListUI.Visible = false

			if not stu.songConn then
				stu.songConn = laptopSongListUI:GetPropertyChangedSignal("Visible"):Connect(function()
					if stu.songHidden and laptopSongListUI.Visible then
						laptopSongListUI.Visible = false
					end
				end)
			end
		end
	elseif stu.songHidden then
		stu.songHidden = false

		if stu.songConn then
			stu.songConn:Disconnect()
			stu.songConn = nil
		end

		if laptopSongListUI and stu.songWasVisible then
			laptopSongListUI.Visible = true
		end
	end
end

local function releaseSongListGuard(p) -- 1 equivalent call inferred from this helper
	local stu = p.stu
	stu.songHidden = false

	if stu.songConn then
		stu.songConn:Disconnect()
		stu.songConn = nil
	end
end

function LaptopStudioPanel:Build(parent, p)
	local v

	if p == nil then
		v = false
	else
		v = p.windowMode == true
	end

	local stu2 = {
		confirmKey = nil,
		confirmAt = 0,
		mode = "players",
		invitable = nil,
		fetching = false
	}
	self.stu = stu2

	local studioPanel_Local = Instance.new("Frame")
	studioPanel_Local.Name = "StudioPanel_Local"
	studioPanel_Local.BackgroundColor3 = Colors.Background
	studioPanel_Local.BorderSizePixel = 0
	studioPanel_Local.Position = UDim2.new(0, 0, 0, 0)
	studioPanel_Local.Size = UDim2.new(1, 0, 1, 0)
	studioPanel_Local.ZIndex = 15
	studioPanel_Local.Active = true
	studioPanel_Local.ClipsDescendants = true
	studioPanel_Local.Visible = false
	studioPanel_Local.Parent = parent
	Retro.AttachScreenFrame(studioPanel_Local)

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1, 0, 1, 0)
	content.Parent = studioPanel_Local
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 10)
	uiPadding.PaddingRight = UDim.new(0, 12)
	uiPadding.PaddingTop = UDim.new(0, v and 8 or 26)
	uiPadding.PaddingBottom = UDim.new(0, 10)
	uiPadding.Parent = content

	Retro.AddTitle(content, text.PanelTitle, {
		size = 15,
		sizeUDim = UDim2.new(1, -38, 0, 25),
		z = 2
	})
	stu2.status = newLabel(content, "", {
		font = Theme.Fonts.Label,
		size = 9,
		color = Colors.TextSecondary,
		xAlign = Enum.TextXAlignment.Right,
		sizeUDim = UDim2.new(0, 110, 0, 14)
	})

	stu2.status.AnchorPoint = Vector2.new(1, 0)
	stu2.status.Position = UDim2.new(1, -40, 0, 3)

	stu2.nameLabel = newLabel(content, "", {
		font = Theme.Fonts.Medium,
		size = 12,
		color = Colors.Accent,
		truncate = true,
		sizeUDim = UDim2.new(1, -4, 0, 16)
	})

	stu2.nameLabel.Position = UDim2.new(0, 2, 0, 28)

	local header = newLabel(content, text.PlayersHeader, {
		font = Theme.Fonts.Label,
		size = 8,
		color = Colors.TextSecondary,
		sizeUDim = UDim2.new(1, 0, 0, 10)
	})

	header.Position = UDim2.new(0, 2, 0, 48)
	stu2.header = header

	local memberList = Instance.new("ScrollingFrame")
	memberList.Name = "MemberList"
	memberList.BackgroundTransparency = 1
	memberList.BorderSizePixel = 0
	memberList.Position = UDim2.new(0, 0, 0, 60)
	memberList.Size = UDim2.new(1, 0, 0, 104)
	memberList.ScrollBarThickness = 5
	memberList.ScrollBarImageColor3 = Colors.TextSecondary
	memberList.ScrollBarImageTransparency = 0.15
	memberList.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	memberList.ScrollingDirection = Enum.ScrollingDirection.Y
	memberList.CanvasSize = UDim2.new()
	memberList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	memberList.Active = true
	memberList.Parent = content
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Padding = UDim.new(0, 3)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = memberList
	stu2.list = memberList

	local _, v2 = Retro.AddHintBar(content, {
		{
			name = "leave",
			text = text.LeaveStudio,
			variant = "danger",
			side = "left",
			onClick = function()
				if isConfirmed(stu2, "leave") then -- inferred equivalent call
					resetConfirm(stu2) -- inferred equivalent call

					if leave then
						leave:FireServer()
					end
				else
					local v2 = self
					local stu = v2.stu
					stu.confirmKey = "leave"
					stu.confirmAt = os.clock()
					local confirmAt = stu.confirmAt
					local v3 = "leave"
					task.delay(2.55, function()
						if v2.stu == stu and stu.confirmKey == v3 and stu.confirmAt == confirmAt then
							resetConfirm(stu) -- inferred equivalent call
							LaptopStudioPanel._render(v2)
						end
					end)

					if stu2.leaveItem and stu2.leaveItem.setText then
						stu2.leaveItem.setText(text.LeaveConfirm)
					end
				end
			end
		},
		{
			name = "invite",
			text = text.InviteButton,
			alt = text.BackButton,
			variant = "primary",
			side = "left",
			onClick = function()
				LaptopStudioPanel._toggleInvite(self)
			end
		},
		{ name = "exit", keycap = "Backspace", text = "Exit", side = "right" }
	}, { z = 2 })
	stu2.leaveItem = v2.leave
	stu2.inviteItem = v2.invite

	for _, guiObject in ipairs(studioPanel_Local:GetDescendants()) do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex += 16
		end
	end

	studioPanel_Local:GetPropertyChangedSignal("Visible"):Connect(function()
		setSongListHidden(self, studioPanel_Local.Visible)
	end)

	PStudioState.Changed:Connect(function()
		LaptopStudioPanel._render(self)
	end)

	task.spawn(function()
		while studioPanel_Local.Parent do
			task.wait(PStudioConfig.INVITE_REFRESH or 3)

			if studioPanel_Local.Visible and stu2.mode == "invite" then
				fetchInvitable(self) -- inferred equivalent call
			end
		end
	end)
	LaptopStudioPanel._render(self)
	return studioPanel_Local
end

function LaptopStudioPanel.Enter(p)
	local stu = p.stu

	if not stu then
		return
	end

	resetConfirm(stu) -- inferred equivalent call
	setMode(p, "players") -- inferred equivalent call
	stu.list.CanvasPosition = Vector2.zero
	LaptopStudioPanel._render(p)
end

function LaptopStudioPanel.ReleaseFocus(p)
	local stu = p.stu

	if stu then
		releaseSongListGuard(p) -- inferred equivalent call
		resetConfirm(stu) -- inferred equivalent call
		setMode(p, "players") -- inferred equivalent call
		LaptopStudioPanel._render(p)
	end
end

return LaptopStudioPanel