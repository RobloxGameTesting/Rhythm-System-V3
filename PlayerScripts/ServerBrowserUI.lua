local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 30)
local serverBrowserQuery = RemoteEvents and RemoteEvents:WaitForChild("ServerBrowserQuery", 30)

if not serverBrowserQuery then
	warn("[ServerBrowserUI] ServerBrowserQuery tidak ditemukan - Server Browser dinonaktifkan.")
	return
end

local success, result = pcall(function()
	local StyledTheme = require(ReplicatedStorage.Modules.SongListUI.StyledTheme)
	return StyledTheme.Settings
end)

local v = (not success or typeof(result) ~= "table" or not result) and {} or result
local function color(p, p2)
	return v[p] or p2
end

local v2 = {
	BG = Color3.fromRGB(18, 18, 22),
	CARD = Color3.fromRGB(32, 32, 38),
	CARD_ACTIVE = Color3.fromRGB(52, 52, 62),
	BORDER = Color3.fromRGB(70, 70, 80),
	TEXT = Color3.fromRGB(245, 245, 247),
	TEXT_DIM = Color3.fromRGB(160, 160, 170),
	ACCENT = Color3.fromRGB(255, 170, 60),
	DARKTEXT = Color3.fromRGB(20, 18, 14),
	BTN = Color3.fromRGB(48, 48, 56),
	DANGER = Color3.fromRGB(190, 60, 60)
}

local object = setmetatable({}, {
	__index = function(_, p)
		return v[p] or v2[p]
	end
})

local v3 = {
	AS = {
		AS = 70,
		EU = 180,
		NA = 190,
		SA = 300,
		AF = 200,
		OC = 110
	},
	EU = {
		EU = 30,
		NA = 100,
		SA = 200,
		AF = 120,
		OC = 280
	},
	NA = { NA = 50, SA = 150, AF = 220, OC = 180 },
	SA = { SA = 60, AF = 280, OC = 280 },
	AF = { AF = 90, OC = 330 },
	OC = { OC = 40 }
}

local function estimatePing(p, p2)
	if not (p and p2) then
		return nil
	end

	local v4 = v3[p]
	local v5 = v4 and v4[p2]

	if not v5 then
		local v6 = v3[p2]
		return v6 and v6[p]
	end

	return v5
end

local function getRealPing()
	local success2, result2 = pcall(function()
		return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
	end)

	if success2 and typeof(result2) == "number" and result2 > 0 then
		return (math.floor(result2 + 0.5))
	end

	return nil
end

local function pingColor(p)
	if p < 100 then
		return Color3.fromRGB(110, 210, 120)
	end

	if p < 200 then
		return Color3.fromRGB(240, 200, 80)
	end

	return Color3.fromRGB(235, 100, 90)
end

local function make(className, items, parent) -- 39 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function round(parent, value) -- 8 equivalent calls inferred from this helper
	make("UICorner", { -- inferred equivalent call
		CornerRadius = UDim.new(0, value or 8)
	}, parent)
end

local function topInset()
	local success2, result2 = pcall(function()
		return GuiService:GetGuiInset()
	end)

	local y = success2 and result2 and result2.Y or 0
	return y > 0 and y or 36
end

local v4 = {
	Name = "ServerBrowserUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 101,
	IgnoreGuiInset = true
}
local screenGui = Instance.new("ScreenGui")
local v5 = {
	{ "ALL", "All" },
	{ "FRIENDS", "Friends" },
	{ "AS", "Asia" },
	{ "EU", "Europe" },
	{ "NA", "N. America" },
	{ "SA", "S. America" },
	{ "AF", "Africa" },
	{ "OC", "Oceania" }
}

local v6 = {
	AS = "Asia",
	EU = "Europe",
	NA = "North America",
	SA = "South America",
	AF = "Africa",
	OC = "Oceania",
	ZZ = "Unknown region"
}

for k, v7 in pairs(v4) do
	screenGui[k] = v7
end

screenGui.Parent = PlayerGui

local serversButton = {
	Name = "ServersButton",
	AnchorPoint = Vector2.new(1, 0.5),
	Size = UDim2.new(0, 70, 0, 30),
	Position = 0,
	BackgroundColor3 = 0,
	Text = "Servers",
	TextSize = 11,
	TextColor3 = 0,
	Font = 0,
	ZIndex = 10
}
local success2, result2 = pcall(function()
	return GuiService:GetGuiInset()
end)

local y = success2 and result2 and result2.Y or 0
serversButton.Position = UDim2.new(1, -246, 0, (y > 0 and y or 36) / 2)
serversButton.BackgroundColor3 = Color3.fromRGB(23, 23, 27)

serversButton.TextColor3 = Color3.fromRGB(245, 245, 247)
serversButton.Font = Enum.Font.GothamBold
local textButton = make("TextButton", serversButton, screenGui) -- inferred equivalent call
round(textButton) -- inferred equivalent call
textButton:SetAttribute("NoNewUISkin", true)
local parent = make("Frame", { -- inferred equivalent call
	Name = "FriendDot",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(1, -4, 0, 4),
	Size = UDim2.new(0, 10, 0, 10),
	BackgroundColor3 = object.ACCENT,
	Visible = false,
	ZIndex = 12
}, textButton)

make("UICorner", { CornerRadius = UDim.new(1, 0) }, parent) -- inferred equivalent call
make("UIStroke", { Color = Color3.fromRGB(23, 23, 27), Thickness = 1.5 }, parent) -- inferred equivalent call
make("UIStroke", { Color = Color3.fromRGB(60, 60, 70), Transparency = 0.5, Thickness = 1 }, textButton) -- inferred equivalent call

task.spawn(function()
	local settingsMenuUI = PlayerGui:WaitForChild("SettingsMenuUI", 15)
	local gearButton = settingsMenuUI and settingsMenuUI:WaitForChild("GearButton", 15)

	if not gearButton then
		return
	end

	local function sync() -- 1 equivalent call inferred from this helper
		textButton.Position = UDim2.new(1, -246, gearButton.Position.Y.Scale, gearButton.Position.Y.Offset)
	end

	sync() -- inferred equivalent call
	gearButton:GetPropertyChangedSignal("Position"):Connect(sync)
end)

local textButton2 = make("TextButton", { -- inferred equivalent call
	Name = "Overlay",
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.5,
	AutoButtonColor = false,
	Text = "",
	Visible = false,
	ZIndex = 20
}, screenGui)

local parent2 = make("Frame", { -- inferred equivalent call
	Name = "Panel",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0.92, 0, 0.8, 0),
	BackgroundColor3 = object.BG,
	BackgroundTransparency = 0.05,
	ZIndex = 21,
	Active = true
}, textButton2)
make("UICorner", { CornerRadius = UDim.new(0, 12) }, parent2) -- inferred equivalent call

make("UISizeConstraint", { MinSize = Vector2.new(260, 300), MaxSize = Vector2.new(420, 560) }, parent2) -- inferred equivalent call
make("UIStroke", { Color = object.BORDER, Transparency = 0.4, Thickness = 1 }, parent2) -- inferred equivalent call

make("TextLabel", { -- inferred equivalent call
	Name = "Title",
	Position = UDim2.new(0, 14, 0, 10),
	Size = UDim2.new(1, -60, 0, 20),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	TextColor3 = object.ACCENT,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "Server Browser",
	ZIndex = 22
}, parent2)

local textButton3 = make("TextButton", { -- inferred equivalent call
	Name = "Close",
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -10, 0, 8),
	Size = UDim2.new(0, 30, 0, 26),
	BackgroundColor3 = object.BTN,
	Text = "X",
	TextColor3 = object.TEXT,
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	ZIndex = 22
}, parent2)
round(textButton3) -- inferred equivalent call
local textLabel = make("TextLabel", { -- inferred equivalent call
	Name = "Here",
	Position = UDim2.new(0, 14, 0, 32),
	Size = UDim2.new(1, -28, 0, 14),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextColor3 = object.TEXT_DIM,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Text = "Loading...",
	ZIndex = 22
}, parent2)

local parent3 = make("ScrollingFrame", { -- inferred equivalent call
	Name = "Filters",
	Position = UDim2.new(0, 10, 0, 52),
	Size = UDim2.new(1, -20, 0, 30),
	BackgroundTransparency = 1,
	ScrollBarThickness = 0,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.X,
	ScrollingDirection = Enum.ScrollingDirection.X,
	ZIndex = 22
}, parent2)

make( -- inferred equivalent call
	"UIListLayout",
	{
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 4),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder
	},
	parent3
)

local scrollingFrame = make("ScrollingFrame", { -- inferred equivalent call
	Name = "List",
	Position = UDim2.new(0, 10, 0, 88),
	Size = UDim2.new(1, -20, 1, -214),
	BackgroundTransparency = 1,
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = object.TEXT_DIM,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ZIndex = 22
}, parent2)

make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, scrollingFrame) -- inferred equivalent call
make("UIPadding", { PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) }, scrollingFrame) -- inferred equivalent call

local textLabel2 = make("TextLabel", { -- inferred equivalent call
	Name = "Empty",
	Position = UDim2.new(0, 14, 0, 100),
	Size = UDim2.new(1, -28, 0, 60),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextColor3 = object.TEXT_DIM,
	TextWrapped = true,
	Text = "",
	Visible = false,
	ZIndex = 22
}, parent2)

local textLabel3 = make("TextLabel", { -- inferred equivalent call
	Name = "Status",
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 14, 1, -86),
	Size = UDim2.new(1, -28, 0, 38),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextColor3 = object.TEXT_DIM,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Bottom,
	Text = "",
	ZIndex = 22
}, parent2)

local parent4 = make("Frame", { -- inferred equivalent call
	Name = "Footer",
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 10, 1, -8),
	Size = UDim2.new(1, -20, 0, 34),
	BackgroundTransparency = 1,
	ZIndex = 22
}, parent2)

make( -- inferred equivalent call
	"UIListLayout",
	{
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	},
	parent4
)

local textButton4 = make("TextButton", { -- inferred equivalent call
	Name = "Refresh",
	LayoutOrder = 1,
	Size = UDim2.new(0.4, -4, 1, 0),
	BackgroundColor3 = object.BTN,
	Text = "Refresh",
	TextColor3 = object.TEXT,
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	ZIndex = 22
}, parent4)
round(textButton4) -- inferred equivalent call
local textButton5 = make("TextButton", { -- inferred equivalent call
	Name = "CreateServer",
	LayoutOrder = 2,
	Size = UDim2.new(0.6, -4, 1, 0),
	BackgroundColor3 = object.ACCENT,
	Text = "New Server (near me)",
	TextColor3 = object.DARKTEXT,
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	ZIndex = 22
}, parent4)
round(textButton5) -- inferred equivalent call
local textButton6 = make("TextButton", { -- inferred equivalent call
	Name = "CreateReservedServer",
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 10, 1, -48),
	Size = UDim2.new(1, -20, 0, 34),
	BackgroundColor3 = object.BTN,
	Text = "Create New Server",
	TextColor3 = object.ACCENT,
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	ZIndex = 22
}, parent2)
round(textButton6) -- inferred equivalent call
local v7 = {}
local v8 = nil
local v9 = "ALL"
local flag = false
local v10 = false
local id = nil
local count = 0
local flag2 = false
local count2 = 0
local flag3 = false
local count3 = 0
local v11 = {}

local function disarmCreates() -- 2 equivalent calls inferred from this helper
	flag2 = false
	flag3 = false
	textButton5.Text = "New Server (near me)"
	textButton6.Text = "Create New Server"
end

local function setStatus(value, p) -- 7 equivalent calls inferred from this helper
	textLabel3.Text = value or ""
	textLabel3.TextColor3 = p and object.DANGER or object.TEXT_DIM
end

local function countFor(p)
	if p == "ALL" then
		return #v7
	end

	local count4 = 0

	for _, v12 in ipairs(v7) do
		if v12.continent == p or p == "FRIENDS" and (v12.friendCount or 0) > 0 then
			count4 += 1
		end
	end

	return count4
end

local function refreshChips()
	for _, v12 in ipairs(v5) do
		local v13 = v11[v12[1]]

		if not v13 then
			continue
		end

		local v14 = v12[1] == v9
		v13.Text = string.format("%s (%d)", v12[2], countFor(v12[1]))
		v13.BackgroundColor3 = v14 and object.ACCENT or object.CARD
		v13.TextColor3 = v14 and object.DARKTEXT or object.TEXT_DIM
	end
end

local function makeRow(data, count4)
	local parent5 = make("Frame", { -- inferred equivalent call
		Name = "Row",
		LayoutOrder = count4,
		Size = UDim2.new(1, 0, 0, (data.friendCount or 0) > 0 and 70 or 54),
		BackgroundColor3 = data.isCurrent and object.CARD_ACTIVE or object.CARD,
		BackgroundTransparency = 0.15,
		ZIndex = 22
	}, scrollingFrame)
	round(parent5) -- inferred equivalent call
	make("TextLabel", { -- inferred equivalent call
		Position = UDim2.new(0, 10, 0, 8),
		Size = UDim2.new(1, -96, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = object.TEXT,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = data.location or v6[data.continent] or "Unknown region",
		ZIndex = 23
	}, parent5)

	local v12 = data.reserved and "  |  Created server" or ""
	local v13, v14

	if data.isCurrent then
		local success3, result3 = pcall(function()
			return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		end)

		if success3 and typeof(result3) == "number" and result3 > 0 then
			v13 = math.floor(result3 + 0.5)
		end

		if v13 then
			v14 = v13 .. " ms" or nil
		end
	else
		local v15 = v8
		local continent = data.continent

		if v15 and continent then
			local v16 = v3[v15]
			v13 = v16 and v16[continent]

			if not v13 then
				local v17 = v3[continent]
				v13 = v17 and v17[v15]
			end
		end

		if v13 then
			v14 = "~" .. v13 .. " ms" or nil
		end
	end

	local v15

	if v13 and v14 then
		local v16 = pingColor(v13)
		v15 = string.format(
			"  |  <font color=\"rgb(%d,%d,%d)\"><b>%s</b></font>",
			math.floor(v16.R * 255),
			math.floor(v16.G * 255),
			math.floor(v16.B * 255),
			v14
		)
	else
		v15 = ""
	end

	make("TextLabel", { -- inferred equivalent call
		Position = UDim2.new(0, 10, 0, 28),
		Size = UDim2.new(1, -96, 0, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 10,
		TextColor3 = object.TEXT_DIM,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		RichText = true,
		Text = string.format(
			"%s  |  %d/%d%s%s",
			v6[data.continent] or "Unknown region",
			data.players,
			data.maxPlayers,
			v15,
			v12
		),
		ZIndex = 23
	}, parent5)

	local friendCount = data.friendCount or 0

	if friendCount > 0 and typeof(data.friends) == "table" then
		local v16 = table.concat(data.friends, ", ")

		if #data.friends < friendCount then
			v16 ..= string.format(" +%d", friendCount - #data.friends)
		end

		make("TextLabel", { -- inferred equivalent call
			Name = "Friends",
			Position = UDim2.new(0, 10, 0, 48),
			Size = UDim2.new(1, -96, 0, 14),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 10,
			TextColor3 = object.ACCENT,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = string.format("%s here: %s", friendCount == 1 and "1 friend" or friendCount .. " friends", v16),
			ZIndex = 23
		}, parent5)
	end

	local v16

	if data.maxPlayers > 0 then
		v16 = data.players >= data.maxPlayers
	else
		v16 = false
	end

	local textButton7 = make("TextButton", { -- inferred equivalent call
		Name = "Action",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0, 72, 0, 34),
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		ZIndex = 23
	}, parent5)
	round(textButton7) -- inferred equivalent call

	local function paint()
		if data.isCurrent then
			textButton7.Text = "You're here"
			textButton7.TextSize = 10
			textButton7.BackgroundTransparency = 1
			textButton7.TextColor3 = object.ACCENT
			textButton7.AutoButtonColor = false
		elseif v16 then
			textButton7.Text = "Full"
			textButton7.BackgroundColor3 = object.BTN
			textButton7.TextColor3 = object.TEXT_DIM
			textButton7.AutoButtonColor = false
		elseif id == data.id then
			textButton7.Text = "Confirm?"
			textButton7.BackgroundColor3 = object.ACCENT
			textButton7.TextColor3 = object.DARKTEXT
		else
			textButton7.Text = "Join"
			textButton7.BackgroundColor3 = object.BTN
			textButton7.TextColor3 = object.TEXT
		end
	end
	paint()

	if not (data.isCurrent or v16) then
		textButton7.MouseButton1Click:Connect(function()
			if flag then
				return
			end

			if id == data.id then
				id = nil
				flag = true
				textLabel3.Text = "Teleporting..."
				textLabel3.TextColor3 = object.TEXT_DIM

				local success3, result3 = pcall(function()
					return serverBrowserQuery:InvokeServer("Join", data.id)
				end)

				if success3 and typeof(result3) == "table" and result3.ok then
					textLabel3.Text = "Teleporting... please wait."
					textLabel3.TextColor3 = object.TEXT_DIM

					task.delay(12, function()
						flag = false
					end)
				else
					flag = false
					setStatus( -- inferred equivalent call
						success3 and typeof(result3) == "table" and result3.reason or "Couldn't reach the server.",
						true
					)
				end
			else
				id = data.id
				count += 1
				local v17 = count
				disarmCreates() -- inferred equivalent call

				for _, frame in ipairs(scrollingFrame:GetChildren()) do
					if not frame:IsA("Frame") then
						continue
					end

					local action = frame:FindFirstChild("Action")

					if not (action and action.Text == "Confirm?") then
						continue
					end

					action.Text = "Join"
					action.BackgroundColor3 = object.BTN
					action.TextColor3 = object.TEXT
				end

				paint()
				setStatus("Tap again to leave this server and join " .. (data.location or "that server") .. ".", false) -- inferred equivalent call
				task.delay(4, function()
					if count == v17 and id == data.id then
						id = nil

						if textButton7.Parent then
							paint()
						end

						textLabel3.Text = ""
						textLabel3.TextColor3 = object.TEXT_DIM
					end
				end)
			end
		end)
	end
end

local function render()
	for _, frame in ipairs(scrollingFrame:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	refreshChips()
	local count4 = 0

	for _, v12 in ipairs(v7) do
		if not (v9 == "ALL" or v12.continent == v9 or v9 == "FRIENDS" and (v12.friendCount or 0) > 0) then
			continue
		end

		count4 += 1
		makeRow(v12, count4)
	end

	if count4 ~= 0 then
		textLabel2.Visible = false

		return
	end

	if v9 == "ALL" then
		textLabel2.Text = "No servers found right now. Try refreshing."
	elseif v9 == "FRIENDS" then
		textLabel2.Text = "None of your friends are in a server right now."
	else
		textLabel2.Text = "No active servers in this region right now.\nServers appear when players from that region are online."
	end

	textLabel2.Visible = true
end

local function describeHere()
	for _, v12 in ipairs(v7) do
		if v12.isCurrent then
			local success3, result3 = pcall(function()
				return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			local v13

			if success3 and typeof(result3) == "number" and result3 > 0 then
				v13 = math.floor(result3 + 0.5)
			end

			textLabel.Text = string.format(
				"You're in: %s  |  %s%s",
				v12.location or "unknown location",
				v6[v12.continent] or "Unknown region",
				v13 and "  |  " .. v13 .. " ms" or ""
			)
			return
		end
	end

	textLabel.Text = ""
end

local function updateFriendDot()
	local visible = false

	for _, v12 in ipairs(v7) do
		if not v12.isCurrent and (v12.friendCount or 0) > 0 then
			visible = true
			break
		end
	end

	parent.Visible = visible
end

local lastTime = 0

local function fetch(p, p2)
	if flag or not (v10 or p2) then
		return
	end

	if os.clock() - lastTime < 3 then
		if not p then
			textLabel3.Text = "Refreshing too fast, wait a moment."
			textLabel3.TextColor3 = object.TEXT_DIM
		end
	else
		lastTime = os.clock()

		if not p then
			textLabel3.Text = "Refreshing..."
			textLabel3.TextColor3 = object.TEXT_DIM
		end

		task.spawn(function()
			local success3, result3 = pcall(function()
				return serverBrowserQuery:InvokeServer("List")
			end)

			if success3 and typeof(result3) == "table" and result3.ok and typeof(result3.servers) == "table" then
				v7 = result3.servers
				local v12

				if typeof(result3.yourContinent) == "string" then
					v12 = result3.yourContinent or nil
				end

				v8 = v12
				updateFriendDot()

				if not v10 then
					return
				end

				describeHere()
				render()
				local v13 = false

				for _, v14 in ipairs(v7) do
					if v14.isCurrent and v14.reserved then
						v13 = true
						break
					end
				end

				setStatus( -- inferred equivalent call
					result3.studio and "Studio: sample data, Join is disabled." or v13 and "This server isn't public: friends and other players can only join it from the Server Browser in the main server." or "",
					false
				)
			elseif success3 and typeof(result3) == "table" and result3.retry then
				textLabel3.Text = ""
				textLabel3.TextColor3 = object.TEXT_DIM
			else
				textLabel3.Text = "Couldn't load the server list. Try again."
				textLabel3.TextColor3 = object.DANGER or object.TEXT_DIM
			end
		end)
	end
end

for i, v12 in ipairs(v5) do
	local parent5 = make("TextButton", { -- inferred equivalent call
		Name = "Chip_" .. v12[1],
		LayoutOrder = i,
		Size = UDim2.new(0, 0, 1, -4),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = object.CARD,
		Text = v12[2],
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = object.TEXT_DIM,
		ZIndex = 22
	}, parent3)
	round(parent5) -- inferred equivalent call
	make("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, parent5) -- inferred equivalent call
	v11[v12[1]] = parent5
	parent5.MouseButton1Click:Connect(function()
		v9 = v12[1]
		id = nil
		render()
	end)
end

textButton4.MouseButton1Click:Connect(function()
	fetch(false)
end)

textButton5.MouseButton1Click:Connect(function()
	if flag then
		return
	end

	if flag2 then
		flag2 = false
		textButton5.Text = "New Server (near me)"
		flag = true
		textLabel3.Text = "Creating server..."
		textLabel3.TextColor3 = object.TEXT_DIM

		local success3, result3 = pcall(function()
			return serverBrowserQuery:InvokeServer("Create")
		end)

		if success3 and typeof(result3) == "table" and result3.ok then
			textLabel3.Text = "Teleporting... please wait."
			textLabel3.TextColor3 = object.TEXT_DIM

			task.delay(12, function()
				flag = false
			end)
		else
			flag = false
			setStatus(success3 and typeof(result3) == "table" and result3.reason or "Couldn't reach the server.", true) -- inferred equivalent call
		end
	else
		flag2 = true
		flag3 = false
		textButton6.Text = "Create New Server"
		id = nil
		count2 += 1
		local v12 = count2
		textButton5.Text = "Tap again to confirm"
		textLabel3.Text = "Moves you to a public server close to you. Friends and other players can join it from this list or the friend list."
		textLabel3.TextColor3 = object.TEXT_DIM

		task.delay(4, function()
			if count2 == v12 and flag2 then
				flag2 = false
				textButton5.Text = "New Server (near me)"
				textLabel3.Text = ""
				textLabel3.TextColor3 = object.TEXT_DIM
			end
		end)
	end
end)

textButton6.MouseButton1Click:Connect(function()
	if flag then
		return
	end

	if flag3 then
		flag3 = false
		textButton6.Text = "Create New Server"
		flag = true
		textLabel3.Text = "Creating server..."
		textLabel3.TextColor3 = object.TEXT_DIM

		local success3, result3 = pcall(function()
			return serverBrowserQuery:InvokeServer("CreateReserved")
		end)

		if success3 and typeof(result3) == "table" and result3.ok then
			textLabel3.Text = "Teleporting... please wait."
			textLabel3.TextColor3 = object.TEXT_DIM

			task.delay(12, function()
				flag = false
			end)
		else
			flag = false
			setStatus(success3 and typeof(result3) == "table" and result3.reason or "Couldn't reach the server.", true) -- inferred equivalent call
		end
	else
		flag3 = true
		flag2 = false
		textButton5.Text = "New Server (near me)"
		id = nil
		count3 += 1
		local v12 = count3
		textButton6.Text = "Tap again to confirm"
		textLabel3.Text = "New empty server near you. It is NOT in Roblox's public server list and friends can't join it from the friend list. Others can only join from this Server Browser, in the main server."
		textLabel3.TextColor3 = object.TEXT_DIM

		task.delay(9, function()
			if count3 == v12 and flag3 then
				flag3 = false
				textButton6.Text = "Create New Server"
				textLabel3.Text = ""
				textLabel3.TextColor3 = object.TEXT_DIM
			end
		end)
	end
end)

local function setOpen(visible) -- 5 equivalent calls inferred from this helper
	v10 = visible
	textButton2.Visible = visible

	if visible then
		textLabel3.Text = ""
		textLabel3.TextColor3 = object.TEXT_DIM

		lastTime = 0
		fetch(false)
	else
		id = nil
		disarmCreates() -- inferred equivalent call
	end
end

textButton.MouseButton1Click:Connect(function()
	setOpen(not v10) -- inferred equivalent call
end)
textButton3.MouseButton1Click:Connect(function()
	setOpen(false) -- inferred equivalent call
end)
textButton2.MouseButton1Click:Connect(function()
	setOpen(false) -- inferred equivalent call
end)

UserInputService.InputBegan:Connect(function(input, _)
	if v10 and input.KeyCode == Enum.KeyCode.Escape then
		setOpen(false) -- inferred equivalent call
	end
end)

local v12 = false
local keyModeToggleUI = nil

local function updateButtonVisibility() -- 2 equivalent calls inferred from this helper
	local v13 = keyModeToggleUI ~= nil and keyModeToggleUI.Enabled
	local visible = not (v12 or v13)
	textButton.Visible = visible

	if not visible and v10 then
		setOpen(false) -- inferred equivalent call
	end
end

task.spawn(function()
	local songSessionStatusUpdate = RemoteEvents:WaitForChild("SongSessionStatusUpdate", 30)

	if songSessionStatusUpdate then
		songSessionStatusUpdate.OnClientEvent:Connect(function(p)
			v12 = p and true or false
			updateButtonVisibility() -- inferred equivalent call
		end)
	end
end)

task.spawn(function()
	keyModeToggleUI = PlayerGui:WaitForChild("KeyModeToggleUI", 30)

	if keyModeToggleUI then
		keyModeToggleUI:GetPropertyChangedSignal("Enabled"):Connect(updateButtonVisibility)
		updateButtonVisibility() -- inferred equivalent call
	end
end)

task.spawn(function()
	while true do
		task.wait(10)

		if not v10 or flag or not v10 or os.clock() - lastTime < 3 then
			continue
		end

		lastTime = os.clock()

		task.spawn(function()
			local success3, result3 = pcall(function()
				return serverBrowserQuery:InvokeServer("List")
			end)

			if success3 and typeof(result3) == "table" and result3.ok and typeof(result3.servers) == "table" then
				v7 = result3.servers
				local v13

				if typeof(result3.yourContinent) == "string" then
					v13 = result3.yourContinent or nil
				end

				v8 = v13
				updateFriendDot()

				if not v10 then
					return
				end

				describeHere()
				render()
				local v14 = false

				for _, v15 in ipairs(v7) do
					if v15.isCurrent and v15.reserved then
						v14 = true
						break
					end
				end

				setStatus( -- inferred equivalent call
					result3.studio and "Studio: sample data, Join is disabled." or v14 and "This server isn't public: friends and other players can only join it from the Server Browser in the main server." or "",
					false
				)
			elseif success3 and typeof(result3) == "table" and result3.retry then
				textLabel3.Text = ""
				textLabel3.TextColor3 = object.TEXT_DIM
			else
				textLabel3.Text = "Couldn't load the server list. Try again."
				textLabel3.TextColor3 = object.DANGER or object.TEXT_DIM
			end
		end)
	end
end)

task.spawn(function()
	task.wait(10)

	while true do
		if textButton.Visible and not (v10 or flag or flag) and not (os.clock() - lastTime < 3) then
			lastTime = os.clock()

			task.spawn(function()
				local success3, result3 = pcall(function()
					return serverBrowserQuery:InvokeServer("List")
				end)

				if success3 and typeof(result3) == "table" and result3.ok and typeof(result3.servers) == "table" then
					v7 = result3.servers
					local v13

					if typeof(result3.yourContinent) == "string" then
						v13 = result3.yourContinent or nil
					end

					v8 = v13
					updateFriendDot()

					if not v10 then
						return
					end

					describeHere()
					render()
					local v14 = false

					for _, v15 in ipairs(v7) do
						if v15.isCurrent and v15.reserved then
							v14 = true
							break
						end
					end

					setStatus( -- inferred equivalent call
						result3.studio and "Studio: sample data, Join is disabled." or v14 and "This server isn't public: friends and other players can only join it from the Server Browser in the main server." or "",
						false
					)
				elseif success3 and typeof(result3) == "table" and result3.retry then
					textLabel3.Text = ""
					textLabel3.TextColor3 = object.TEXT_DIM
				else
					textLabel3.Text = "Couldn't load the server list. Try again."
					textLabel3.TextColor3 = object.DANGER or object.TEXT_DIM
				end
			end)
		end

		task.wait(60)
	end
end)

refreshChips()

task.spawn(function()
	local success3, result3 = pcall(function()
		return serverBrowserQuery:InvokeServer("Info")
	end)

	if not success3 or typeof(result3) ~= "table" or not result3.reservedNotice then
		return
	end

	local reservedNotice = {
		Name = "ReservedNotice",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = 0,
		Size = 0,
		AutomaticSize = 0,
		BackgroundColor3 = 0,
		BackgroundTransparency = 0.08,
		AutoButtonColor = false,
		Text = "",
		ZIndex = 30
	}
	local success4, result4 = pcall(function()
		return GuiService:GetGuiInset()
	end)

	local y2 = success4 and result4 and result4.Y or 0
	reservedNotice.Position = UDim2.new(0.5, 0, 0, (y2 > 0 and y2 or 36) + 10)
	reservedNotice.Size = UDim2.new(0.92, 0, 0, 0)
	reservedNotice.AutomaticSize = Enum.AutomaticSize.Y
	reservedNotice.BackgroundColor3 = object.CARD
	local parent5 = make("TextButton", reservedNotice, screenGui) -- inferred equivalent call
	make("UICorner", { CornerRadius = UDim.new(0, 10) }, parent5) -- inferred equivalent call

	make("UISizeConstraint", { MaxSize = Vector2.new(380, 1000) }, parent5) -- inferred equivalent call
	make("UIStroke", { Color = object.ACCENT, Transparency = 0.3, Thickness = 1 }, parent5) -- inferred equivalent call
	make( -- inferred equivalent call
		"UIPadding",
		{
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12)
		},
		parent5
	)

	make("TextLabel", { -- inferred equivalent call
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = object.TEXT,
		TextWrapped = true,
		RichText = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "<b>Private-link server</b>\nThis server isn't in Roblox's public server list and can't be joined from the friend list. Others can only join from the <b>Servers</b> panel (Server Browser) in the main server.",
		ZIndex = 31
	}, parent5)

	parent5.MouseButton1Click:Connect(function()
		parent5:Destroy()
	end)
	task.delay(20, function()
		if parent5.Parent then
			parent5:Destroy()
		end
	end)
end)

task.spawn(function()
	local success3, result3 = pcall(function()
		return require(ReplicatedStorage.Modules.SongListUI.UISkin)
	end)

	if success3 and result3 then
		result3.AddRoot(screenGui)
	else
		warn("[ServerBrowserUI] UISkin tidak bisa dimuat: " .. tostring(result3))
	end
end)