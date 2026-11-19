local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ModeratorQuery = RemoteEvents:WaitForChild("ModeratorQuery")
local AdminPanelAction = RemoteEvents:WaitForChild("AdminPanelAction")
local AdminPanelFeedback = RemoteEvents:WaitForChild("AdminPanelFeedback")
local AmpAdminModeSet = RemoteEvents:WaitForChild("AmpAdminModeSet")
local moderatorUI = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ModeratorUI")
local UIKit = require(moderatorUI:WaitForChild("UIKit"))
local Colors = UIKit.Colors

local success, result = pcall(function()
	return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SessionCameraSettings"))
end)

if not success then
	warn("[ModeratorPanel] SessionCameraSettings tidak ditemukan: scroll panel bisa mengubah zoom kamera")
	result = nil
end

local function fetchInit()
	local v = false
	local init = nil
	task.spawn(function()
		local success2, result2 = pcall(function()
			return ModeratorQuery:InvokeServer("Init")
		end)

		if success2 then
			init = result2
		end

		v = true
	end)
	local total = 0

	while not v and total < 10 do
		task.wait(0.25)
		total += 0.25
	end

	return init
end

local v = nil
local v2 = false

for _ = 1, 6 do
	v = fetchInit()

	if typeof(v) == "table" then
		break
	end

	task.wait(2)
end

if typeof(v) ~= "table" or (v.Tier or 0) < 1 and v.IsTester ~= true then
	return
end

local v3 = {
	{ Id = "Dashboard", Label = "Dashboard", Module = "DashboardPage", Scroll = true },
	{ Id = "Players", Label = "Players", Module = "PlayersPage", Scroll = false },
	{ Id = "Studio", Label = "Music & Studio", Module = "StudioPage", Scroll = true },
	{ Id = "Server", Label = "Server", Module = "ServerPage", Scroll = true },
	{ Id = "Announce", Label = "Announcements", Module = "AnnouncePage", Scroll = true },
	{ Id = "Polls", Label = "Polls", Module = "PollsPage", Scroll = true },
	{ Id = "ServerBoard", Label = "Server Board", Module = "ServerBoardPage", Scroll = true },
	{ Id = "Notes", Label = "Discussion", Module = "NotesPage", Scroll = false },
	{ Id = "Reports", Label = "Reports", Module = "ReportsPage", Scroll = false },
	{ Id = "Logs", Label = "Logs", Module = "LogsPage", Scroll = false }
}

if v.IsTester then
	local v4 = { Server = true, ServerBoard = true, Reports = true }

	for i = #v3, 1, -1 do
		if v4[v3[i].Id] then
			table.remove(v3, i)
		end
	end
end

local v4 = {}

for _, v5 in ipairs(v3) do
	v4[v5.Id] = v5
end

local flag = false
local v5 = false
local v6 = false
local v7 = 36
local v8 = nil
local v9 = {}
local v10 = {}

local v11 = { Unread = 0, Ids = {}, OnChange = nil }

local function updateNotesBadge() -- 3 equivalent calls inferred from this helper
	local notes = v10.Notes

	if notes then
		notes.Button.Text = v11.Unread > 0 and "DISCUSSION  (" .. v11.Unread .. ")" or "DISCUSSION"
	end

	if v11.OnChange then
		v11.OnChange()
	end
end

local v12 = { Open = 0, New = 0 }

local function updateReportsBadge() -- 3 equivalent calls inferred from this helper
	local reports = v10.Reports

	if reports then
		reports.Button.Text = v12.Open > 0 and "REPORTS  (" .. v12.Open .. ")" or "REPORTS"
	end

	if v11.OnChange then
		v11.OnChange()
	end
end

local screenGui = UIKit.new("ScreenGui", {
	Name = "ModeratorPanelUI",
	DisplayOrder = 100,
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PlayerGui)

local textButton = UIKit.new("TextButton", {
	Name = "Backdrop",
	AutoButtonColor = false,
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.5,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	Text = "",
	Visible = false,
	ZIndex = 5
}, screenGui)

local textButton2 = UIKit.new("TextButton", {
	Name = "ModeratorButton",
	AnchorPoint = Vector2.new(0, 0.5),
	AutoButtonColor = false,
	BackgroundColor3 = Color3.fromRGB(23, 23, 27),
	Font = Enum.Font.GothamBold,
	Size = UDim2.fromOffset(84, 30),
	Text = v.IsTester and "TEST" or "MODS",
	TextColor3 = Colors.Text,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 10
}, screenGui)

UIKit.padding(textButton2, 0, 0, 0, 24)
UIKit.new("UICorner", { CornerRadius = UDim.new(0, 8) }, textButton2)
local stroke = UIKit.stroke(textButton2, Colors.Border, 1, 1)
local dot = UIKit.dot(
	textButton2,
	v.IsTester and Color3.fromRGB(140, 140, 146) or v.Tier >= 2 and Colors.Accent or Colors.Danger,
	7
)
dot.AnchorPoint = Vector2.new(0, 0.5)

dot.Position = UDim2.new(0, -14, 0.5, 0)
dot.ZIndex = 11
local chevron = UIKit.chevron(textButton2, Colors.Muted)
chevron.AnchorPoint = Vector2.new(1, 0.5)
chevron.Position = UDim2.new(1, -10, 0.5, 0)
chevron.ZIndex = 11

local NoticeStyle = require(moderatorUI:WaitForChild("NoticeStyle"))
local Amber = NoticeStyle.Colors.Amber
local textLabel = UIKit.new("TextLabel", {
	Name = "UnreadBadge",
	AnchorPoint = Vector2.new(1, 0.5),
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundColor3 = Amber,
	BorderSizePixel = 0,
	Font = UIKit.FontBold,
	Position = UDim2.new(1, 2, 0, 3),
	Size = UDim2.fromOffset(0, 16),
	Text = "",
	TextColor3 = Color3.fromRGB(28, 22, 10),
	TextSize = 10,
	Visible = false,
	ZIndex = 12
}, textButton2)

UIKit.new("UICorner", { CornerRadius = UDim.new(0, 8) }, textLabel)
UIKit.padding(textLabel, 0, 4, 0, 4)
UIKit.new("UISizeConstraint", { MinSize = Vector2.new(16, 16) }, textLabel)
UIKit.stroke(textLabel, Color3.fromRGB(23, 23, 27), 0, 2)
local uiScale = UIKit.new("UIScale", { Scale = 1 }, textLabel)

local v13 = 0
function v11.OnChange()
	local v14 = v11.Unread + v12.New

	if v14 > 0 then
		textLabel.Text = v14 > 99 and "99+" or tostring(v14)
		textLabel.Visible = true

		if v13 < v14 then
			uiScale.Scale = 0.55
			UIKit.tween(uiScale, { Scale = 1 }, 0.18)
		end
	else
		textLabel.Visible = false
	end

	v13 = v14
end

local color = Color3.fromRGB(224, 212, 180)

local color2 = Color3.fromRGB(23, 23, 27)
local textButton3 = UIKit.new("TextButton", {
	Name = "AutoPlayButton",
	AnchorPoint = Vector2.new(0, 0.5),
	AutoButtonColor = false,
	BackgroundColor3 = color2,
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Size = UDim2.fromOffset(66, 30),
	Text = "AUTO",
	TextColor3 = color,
	TextSize = 11,
	TextTransparency = 1,
	TextXAlignment = Enum.TextXAlignment.Left,
	Visible = false,
	ZIndex = 10
}, screenGui)

UIKit.padding(textButton3, 0, 0, 0, 24)
UIKit.new("UICorner", { CornerRadius = UDim.new(0, 8) }, textButton3)
local stroke2 = UIKit.stroke(textButton3, color, 1, 1)
local dot2 = UIKit.dot(textButton3, color, 7)
dot2.AnchorPoint = Vector2.new(0, 0.5)
dot2.Position = UDim2.new(0, -14, 0.5, 0)
dot2.ZIndex = 11

local v14 = false
local v15 = nil
local lastTime = 0

local function setAutoButtonVisible(p)
	if p == v14 then
		return
	end

	v14 = p

	if p then
		textButton3.Visible = true
		UIKit.tween(textButton3, { BackgroundTransparency = 0, TextTransparency = 0 }, 0.18)
		UIKit.tween(stroke2, { Transparency = 0.7 }, 0.18)
		dot2.BackgroundTransparency = 0

		if v15 then
			v15:Cancel()
		end
	else
		if v15 then
			v15:Cancel()
			v15 = nil
		end

		UIKit.tween(textButton3, { BackgroundTransparency = 1, TextTransparency = 1 }, 0.15)
		UIKit.tween(stroke2, { Transparency = 1 }, 0.15)
		UIKit.tween(dot2, { BackgroundTransparency = 1 }, 0.15)
		task.delay(0.17, function()
			if not v14 then
				textButton3.Visible = false
			end
		end)
	end
end

textButton3.MouseEnter:Connect(function()
	UIKit.tween(textButton3, {
		BackgroundColor3 = color2:Lerp(Color3.new(1, 1, 1), 0.08)
	}, 0.1)
end)
textButton3.MouseLeave:Connect(function()
	UIKit.tween(textButton3, { BackgroundColor3 = color2 }, 0.1)
end)
textButton3.Activated:Connect(function()
	if not v14 or os.clock() - lastTime < 0.4 then
		return
	end

	lastTime = os.clock()
	AdminPanelAction:FireServer("AutoPlayToggle")
end)

setAutoButtonVisible(LocalPlayer:GetAttribute("AdminAutoPlay") == true)
LocalPlayer:GetAttributeChangedSignal("AdminAutoPlay"):Connect(function()
	setAutoButtonVisible(LocalPlayer:GetAttribute("AdminAutoPlay") == true)
end)

local canvasGroup = UIKit.new("CanvasGroup", {
	Name = "Window",
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Colors.Bg,
	BorderSizePixel = 0,
	GroupTransparency = 1,
	Size = UDim2.fromOffset(900, 560),
	Visible = false,
	ZIndex = 20
}, screenGui)

UIKit.corner(canvasGroup, 14)
UIKit.stroke(canvasGroup, Colors.Border, 0.2, 1)
local uiScale2 = UIKit.new("UIScale", { Scale = 1 }, canvasGroup)

canvasGroup.Active = true

local frame = UIKit.new(
	"Frame",
	{
		Name = "Header",
		BackgroundColor3 = Colors.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 58)
	},
	canvasGroup
)

UIKit.new("Frame", {
	AnchorPoint = Vector2.new(0, 1),
	BackgroundColor3 = Colors.Border,
	BackgroundTransparency = 0.4,
	BorderSizePixel = 0,
	Position = UDim2.fromScale(0, 1),
	Size = UDim2.new(1, 0, 0, 1)
}, frame)

local success2, result2 = pcall(function()
	return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("LaptopUI"):WaitForChild("Retro"))
end)

local v16 = v.IsTester and "TEST PANEL" or "MODERATOR PANEL"

if success2 then
	result2.AddTitle(frame, v16, {
		size = 22,
		z = 2,
		position = UDim2.fromOffset(18, 5),
		sizeUDim = UDim2.new(0.55, 0, 0, 32)
	})
else
	local label = UIKit.label(frame, v16, { bold = true, height = 24, textSize = 18 })
	label.Position = UDim2.fromOffset(18, 8)
end

local label = UIKit.label(frame, v.IsTester and "Test Panel" or v.Version or "", {
	color = Colors.Muted,
	height = 14,
	regular = true,
	textSize = 10
})
label.Position = UDim2.fromOffset(18, 40)
label.Size = UDim2.new(0.5, 0, 0, 14)

local button = UIKit.button(frame, "", {
	base = Colors.Surface2,
	radius = 9,
	sizeUDim = UDim2.fromOffset(32, 32)
})
button.AnchorPoint = Vector2.new(1, 0.5)
button.Position = UDim2.new(1, -14, 0.5, 0)
local cross = UIKit.cross(button, Colors.Muted)
cross.AnchorPoint = Vector2.new(0.5, 0.5)
cross.Position = UDim2.fromScale(0.5, 0.5)

local badge = UIKit.badge(
	frame,
	v.TierName or "Moderator",
	v.IsTester and Colors.Muted or v.Tier >= 2 and Colors.Accent or Colors.Info,
	1
)
badge.AnchorPoint = Vector2.new(1, 0.5)
badge.Position = UDim2.new(1, -58, 0.5, 0)

local scrollingFrame = UIKit.new("ScrollingFrame", {
	Name = "Tabs",
	BackgroundColor3 = Colors.Bg,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	ElasticBehavior = Enum.ElasticBehavior.Never,
	ScrollBarThickness = 0
}, canvasGroup)

local list = UIKit.list(scrollingFrame, 3)
UIKit.padding(scrollingFrame, 8, 8, 8, 8)

local success3, result3 = pcall(function()
	return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("LaptopUI"):WaitForChild("Retro"))
end)

if success3 then
	local menuStrip = result3.AddHeaderStrip(scrollingFrame, v.IsTester and "Test menu" or "Moderator menu", {
		sizeUDim = UDim2.new(1, 0, 0, 18)
	})
	menuStrip.Name = "MenuStrip"
	menuStrip.LayoutOrder = 0
end

local label2 = UIKit.label(canvasGroup, "Moderator panel", {
	color = Colors.Muted,
	height = 14,
	regular = true,
	textSize = 10
})
label2.Text = v.TierName or ""
label2.AnchorPoint = Vector2.new(0, 1)
label2.Position = UDim2.new(0, 18, 1, -30)
label2.Size = UDim2.fromOffset(152, 14)

local frame2 = UIKit.new(
	"Frame",
	{ Name = "Content", BackgroundTransparency = 1, ClipsDescendants = true },
	canvasGroup
)

local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local NoticeStyle2 = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("ModeratorUI"):WaitForChild("NoticeStyle"))
local v17 = "#" .. NoticeStyle2.Colors.Amber:ToHex()
local v18 = v.IsTester and "TEST:" or "MODS:"
local cards = {}
local count = 0

local function escapeRich(p) -- 1 equivalent call inferred from this helper
	return (tostring(p):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function fn(p, p2)
	if v5 then
		return
	end

	local stack = NoticeStyle2.GetStack(3)

	if not stack then
		return
	end

	count += 1
	local kind = (p2 == "ok" or p2 == "error" or p2 == "activity") and p2 or "info"
	local v19 = NoticeStyle2.IsGrunge() and " face=\"Oswald\"" or ""
	local card = NoticeStyle2.createCard(stack, {
		kind = kind,
		toast = true,
		richText = true,
		body = "<font" .. v19 .. " color=\"" .. v17 .. "\">" .. v18 .. "</font> " .. escapeRich(p), -- inferred equivalent call
		order = count + 1000,
		minWidth = 180
	})

	local isPlaying = NoticeStyle2.IsPlaying()

	local v20 = p2 == "activity" and (isPlaying and 3.2 or 4.5) or isPlaying and 2 or 2.8

	card.StartTimer(v20)

	table.insert(cards, card)

	for i = #cards, 1, -1 do
		if cards[i].Closed then
			table.remove(cards, i)
		end
	end

	local v21 = NoticeStyle2.IsPlaying() and 1 or 2

	while v21 < #cards do
		table.remove(cards, 1).Dismiss()
	end
end

AdminPanelFeedback.OnClientEvent:Connect(function(value, value2)
	if typeof(value) == "string" then
		fn(value, typeof(value2) == "string" and value2 or "info")
	end
end)

local bindableEvent = Instance.new("BindableEvent")
local selectPage

local v19 = {
	Kit = UIKit,
	Player = LocalPlayer,
	Tier = v.Tier,
	TierName = v.TierName,
	Version = v.Version,
	IsStudio = v.IsStudio,
	IsDeveloper = v.Tier >= 2,
	IsTester = v.IsTester == true,
	Role = v.Role,
	Permissions = v.Permissions or {},
	LayoutChanged = bindableEvent,
	Remotes = { AmpAdminModeSet = AmpAdminModeSet },
	Toast = fn
}

function v19.Can(p): boolean
	return v19.Permissions[p] == true
end

function v19.Query(p, p2)
	local success4, result4 = pcall(function()
		return ModeratorQuery:InvokeServer(p, p2)
	end)
	return if success4 then result4 else nil
end

function v19.Act(p, ...)
	AdminPanelAction:FireServer(p, ...)
end

function v19.Compact()
	return v6
end

function v19.Go(p, p2)
	selectPage(p, p2)
end

function v19.ReportQuery(p, p2)
	local moderatorReportQuery = RemoteEvents:FindFirstChild("ModeratorReportQuery")

	if not moderatorReportQuery then
		return nil
	end

	local success4, result4 = pcall(function()
		return moderatorReportQuery:InvokeServer(p, p2)
	end)
	return if success4 then result4 else nil
end

function v19.ReportAct(p, p2, p3)
	local moderatorReportAction = RemoteEvents:FindFirstChild("ModeratorReportAction")

	if moderatorReportAction then
		moderatorReportAction:FireServer(p, p2, p3)
	end
end

function v19.SetOpenReports(p)
	v12.Open = math.max(0, tonumber(p) or 0)
	updateReportsBadge() -- inferred equivalent call
end

local flag2 = false

local textButton4 = UIKit.new("TextButton", {
	Name = "ToolsMenuBackdrop",
	AutoButtonColor = false,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	Text = "",
	Visible = false,
	ZIndex = 6
}, screenGui)

local newbieModePanel = Instance.new("Frame")

local StyledTheme = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SongListUI"):WaitForChild("StyledTheme"))

local function corner(parent, cornerRadius) -- 5 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = cornerRadius
	uiCorner.Parent = parent
	return uiCorner
end

local function pillButton(parent, text, size, p) -- 3 equivalent calls inferred from this helper
	local textButton5 = Instance.new("TextButton")
	textButton5.AutoButtonColor = false
	textButton5.Size = size
	textButton5.BackgroundColor3 = p and StyledTheme.Colors.Accent or StyledTheme.Colors.Surface
	textButton5.Font = StyledTheme.Fonts.Bold
	textButton5.TextSize = StyledTheme.TextSize.S
	textButton5.TextColor3 = p and StyledTheme.Colors.AccentText or StyledTheme.Colors.TextPrimary
	textButton5.Text = text
	textButton5.Parent = parent
	corner(textButton5, StyledTheme.Radius.Pill) -- inferred equivalent call
	return textButton5
end

local function textLabel2(parent, text, font, textSize, textColor, layoutOrder) -- 4 equivalent calls inferred from this helper
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.BackgroundTransparency = 1
	textLabel3.Font = font
	textLabel3.TextSize = textSize
	textLabel3.TextColor3 = textColor
	textLabel3.TextXAlignment = Enum.TextXAlignment.Left
	textLabel3.Text = text
	textLabel3.LayoutOrder = layoutOrder
	textLabel3.Parent = parent
	return textLabel3
end

local moderatorMenuGui = Instance.new("ScreenGui")
moderatorMenuGui.Name = "ModeratorMenuGui"
moderatorMenuGui.DisplayOrder = 101
moderatorMenuGui.IgnoreGuiInset = true
moderatorMenuGui.ResetOnSpawn = false
moderatorMenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
moderatorMenuGui.Parent = PlayerGui

newbieModePanel.Name = "NewbieModePanel"
newbieModePanel.Size = UDim2.new(0, 250, 0, 0)
newbieModePanel.AutomaticSize = Enum.AutomaticSize.Y
newbieModePanel.BackgroundColor3 = StyledTheme.Colors.Background
newbieModePanel.BackgroundTransparency = 0.02
newbieModePanel.Active = true
newbieModePanel.Visible = false
newbieModePanel.Parent = moderatorMenuGui
corner(newbieModePanel, StyledTheme.Radius.Large) -- inferred equivalent call
local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = StyledTheme.Stroke.Thickness
uiStroke.Color = Color3.new(0, 0, 0)
uiStroke.Transparency = 0.2
uiStroke.Parent = newbieModePanel

local content = Instance.new("Frame")
content.Name = "Content"
content.BackgroundTransparency = 1
content.Size = UDim2.new(1, 0, 0, 0)
content.AutomaticSize = Enum.AutomaticSize.Y
content.Parent = newbieModePanel
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingLeft = UDim.new(0, 12)
uiPadding.PaddingRight = UDim.new(0, 12)
uiPadding.PaddingTop = UDim.new(0, 12)
uiPadding.PaddingBottom = UDim.new(0, 12)
uiPadding.Parent = content
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Vertical
uiListLayout.Padding = UDim.new(0, 6)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = content

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.BackgroundColor3 = StyledTheme.Colors.Surface
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.AnchorPoint = Vector2.new(1, 0)
closeButton.Position = UDim2.new(1, -12, 0, 12)
closeButton.Text = ""
closeButton.AutoButtonColor = false
closeButton.ZIndex = 3
closeButton.Parent = newbieModePanel
corner(closeButton, StyledTheme.Radius.Pill) -- inferred equivalent call
local frame3 = Instance.new("Frame")
frame3.AnchorPoint = Vector2.new(0.5, 0.5)
frame3.Position = UDim2.new(0.5, 0, 0.5, 0)
frame3.Size = UDim2.new(0, 12, 0, 2)
frame3.Rotation = 45
frame3.BackgroundColor3 = StyledTheme.Colors.TextSecondary
frame3.BorderSizePixel = 0
frame3.ZIndex = 4
frame3.Parent = closeButton
local clone = frame3:Clone()
clone.Rotation = -45
clone.Parent = closeButton
closeButton.Activated:Connect(function()
	if v19.CloseMenu then
		v19.CloseMenu()
	end
end)

local textLabel3 = textLabel2( -- inferred equivalent call
	content,
	v.IsTester and "TESTER MENU" or "MODERATOR MENU",
	StyledTheme.Fonts.Bold,
	StyledTheme.TextSize.XXL,
	StyledTheme.Colors.TextPrimary,
	1
)
textLabel3.Size = UDim2.new(1, -32, 0, 24)

local function makeSwitch(parent, p, fn2)
	local textButton5 = Instance.new("TextButton")
	textButton5.AnchorPoint = Vector2.new(1, 0.5)
	textButton5.Position = UDim2.new(1, 0, 0.5, 0)
	textButton5.Size = UDim2.fromOffset(42, 22)
	textButton5.AutoButtonColor = false
	textButton5.Text = ""
	textButton5.Parent = parent
	corner(textButton5, StyledTheme.Radius.Pill) -- inferred equivalent call
	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.Thickness = 1.5
	uiStroke2.Parent = textButton5
	local frame4 = Instance.new("Frame")
	frame4.AnchorPoint = Vector2.new(0, 0.5)
	frame4.Size = UDim2.fromOffset(16, 16)
	frame4.BorderSizePixel = 0
	frame4.Parent = textButton5
	corner(frame4, StyledTheme.Radius.Pill) -- inferred equivalent call
	local v20 = p
	local function render()
		textButton5.BackgroundColor3 = v20 and StyledTheme.Colors.Accent or StyledTheme.Colors.SurfaceHover
		uiStroke2.Color = v20 and StyledTheme.Colors.Accent or StyledTheme.Colors.BorderHover
		frame4.BackgroundColor3 = v20 and StyledTheme.Colors.AccentText or StyledTheme.Colors.TextPrimary
		frame4.Position = v20 and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
	end
	render()
	textButton5.Activated:Connect(function()
		v20 = not v20
		render()
		fn2(v20)
	end)
	return {
		SetState = function(p2)
			v20 = p2
			render()
		end
	}
end

local function toolRow(text, text2, layoutOrder)
	local frame4 = Instance.new("Frame")
	frame4.BackgroundTransparency = 1
	frame4.Size = UDim2.new(1, 0, 0, 34)
	frame4.LayoutOrder = layoutOrder
	frame4.Parent = content
	local textLabel4 = textLabel2( -- inferred equivalent call
		frame4,
		text,
		StyledTheme.Fonts.Medium,
		StyledTheme.TextSize.M,
		StyledTheme.Colors.TextPrimary,
		1
	)
	textLabel4.Position = UDim2.fromOffset(0, 1)
	textLabel4.Size = UDim2.new(1, -60, 0, 16)
	local textLabel5 = textLabel2( -- inferred equivalent call
		frame4,
		text2,
		StyledTheme.Fonts.Regular,
		StyledTheme.TextSize.S,
		StyledTheme.Colors.TextSecondary,
		2
	)
	textLabel5.Position = UDim2.fromOffset(0, 17)
	textLabel5.Size = UDim2.new(1, -60, 0, 14)
	return frame4
end

local can = v19.Can("AdminTools")
local can2 = v19.Can("AutoPlayToggle")

if can then
	local switch = makeSwitch(
		toolRow("Moderator Mode", "Free access in Amp", 2),
		LocalPlayer:GetAttribute("AmpAdminMode") == true,
		function(p)
			AmpAdminModeSet:FireServer(p)
		end
	)
	LocalPlayer:GetAttributeChangedSignal("AmpAdminMode"):Connect(function()
		switch.SetState(LocalPlayer:GetAttribute("AmpAdminMode") == true)
	end)
end

if can2 then
	local switch = makeSwitch(
		toolRow("Autoplay", "Auto-hit every song", 3),
		LocalPlayer:GetAttribute("AdminAutoPlay") == true,
		function()
			AdminPanelAction:FireServer("AutoPlayToggle")
		end
	)
	LocalPlayer:GetAttributeChangedSignal("AdminAutoPlay"):Connect(function()
		switch.SetState(LocalPlayer:GetAttribute("AdminAutoPlay") == true)
	end)
end

if v19.Can("GotoStage") then
	local textLabel4 = textLabel2( -- inferred equivalent call
		content,
		"Teleport to stage",
		StyledTheme.Fonts.Medium,
		StyledTheme.TextSize.M,
		StyledTheme.Colors.TextPrimary,
		5
	)
	textLabel4.Size = UDim2.new(1, 0, 0, 18)
	local frame4 = Instance.new("Frame")
	frame4.BackgroundTransparency = 1
	frame4.AutomaticSize = Enum.AutomaticSize.Y
	frame4.Size = UDim2.new(1, 0, 0, 0)
	frame4.LayoutOrder = 6
	frame4.Parent = content
	local uiGridLayout = Instance.new("UIGridLayout")
	uiGridLayout.CellPadding = UDim2.fromOffset(6, 6)
	uiGridLayout.CellSize = UDim2.new(0.5, -4, 0, 26)
	uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiGridLayout.Parent = frame4
	textLabel4.Visible = false
	frame4.Visible = false

	local v20 = nil
	local flag3 = false
	function v19.RefreshStageButtons()
		if flag3 then
			return
		end

		flag3 = true
		task.spawn(function()
			local query = v19.Query("Stages")
			flag3 = false

			if typeof(query) ~= "table" or typeof(query.Stages) ~= "table" then
				return
			end

			local names = {}

			for _, stage in ipairs(query.Stages) do
				table.insert(names, stage.Name)
			end

			local joined = table.concat(names, "|")

			if joined == v20 then
				return
			end

			v20 = joined

			for _, button2 in ipairs(frame4:GetChildren()) do
				if button2:IsA("TextButton") then
					button2:Destroy()
				end
			end

			for i, v21 in ipairs(names) do
				local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
				local parent = pillButton( -- inferred equivalent call
					frame4,
					string.upper(require(ReplicatedStorage3.Modules.StageNames).Display(v21)),
					UDim2.new(1, 0, 1, 0),
					false
				)
				parent.Name = "Teleport_" .. v21
				parent.LayoutOrder = i
				parent.Activated:Connect(function()
					AdminPanelAction:FireServer("GotoStage", v21)

					if v19.CloseMenu then
						v19.CloseMenu()
					end
				end)
			end

			frame4.Visible = #names > 0
			textLabel4.Visible = #names > 0
		end)
	end
	v19.RefreshStageButtons()
end

local thumbnailSceneButton = pillButton(content, "THUMBNAIL SCENE", UDim2.new(1, 0, 0, 30), false) -- inferred equivalent call
thumbnailSceneButton.Name = "ThumbnailSceneButton"
thumbnailSceneButton.TextSize = StyledTheme.TextSize.M
thumbnailSceneButton.LayoutOrder = 7
thumbnailSceneButton.Visible = false
local function refreshThumbnailButton() -- 1 equivalent call inferred from this helper
	thumbnailSceneButton.Visible = LocalPlayer:GetAttribute("ThumbnailDeveloper") == true
	thumbnailSceneButton.Text = LocalPlayer:GetAttribute("ThumbnailStatus") == "Busy" and "PREPARING..."
		or "THUMBNAIL SCENE"
end

refreshThumbnailButton() -- inferred equivalent call
LocalPlayer:GetAttributeChangedSignal("ThumbnailDeveloper"):Connect(refreshThumbnailButton)
LocalPlayer:GetAttributeChangedSignal("ThumbnailStatus"):Connect(refreshThumbnailButton)
thumbnailSceneButton.Activated:Connect(function()
	local thumbnailRequest = ReplicatedStorage:FindFirstChild("ThumbnailRequest")

	if thumbnailRequest and LocalPlayer:GetAttribute("ThumbnailDeveloper") == true then
		thumbnailRequest:Fire()
	end

	if v19.CloseMenu then
		v19.CloseMenu()
	end
end)

local parent = pillButton(content, "Open Panel", UDim2.new(1, 0, 0, 30), true) -- inferred equivalent call
parent.TextSize = StyledTheme.TextSize.M
parent.LayoutOrder = 8

local success4, result4 = pcall(function()
	return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SongListUI"):WaitForChild("UISkin"))
end)

if success4 and typeof(result4) == "table" and result4.AddRoot then
	pcall(result4.AddRoot, moderatorMenuGui)
end

local function createRoot(p)
	if p.Scroll then
		local scrollingFrame2 = UIKit.new("ScrollingFrame", {
			Name = p.Id,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			ElasticBehavior = Enum.ElasticBehavior.Never,
			ScrollBarImageColor3 = Colors.Border,
			ScrollBarThickness = 4,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Size = UDim2.fromScale(1, 1),
			Visible = false
		}, frame2)

		UIKit.padding(scrollingFrame2, 18, 18, 18, 18)
		UIKit.list(scrollingFrame2, 14)
		return scrollingFrame2
	else
		local frame4 = UIKit.new(
			"Frame",
			{
				Name = p.Id,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Visible = false
			},
			frame2
		)

		UIKit.padding(frame4, 18, 18, 18, 18)

		return frame4
	end
end

local function ensurePage(p)
	if v9[p] then
		return v9[p]
	end

	local v20 = v4[p]
	local v21 = { Root = createRoot(v20) }
	v9[p] = v21

	local child = moderatorUI:FindFirstChild(v20.Module)

	if not child then
		UIKit.emptyState(v21.Root, v20.Label .. " is being prepared", 1)
		return v21
	end

	local success5, result5 = pcall(require, child)

	if success5 then
		local success6, result6 = pcall(result5.new, v21.Root, v19)

		if success6 and typeof(result6) == "table" then
			v21.Page = result6
			return v21
		end

		warn("[ModeratorPanel] failed to build " .. v20.Module .. ": " .. tostring(result6))
		UIKit.emptyState(v21.Root, "Page failed to build: " .. tostring(result6), 1)
		return v21
	end

	warn("[ModeratorPanel] failed to load " .. v20.Module .. ": " .. tostring(result5))
	UIKit.emptyState(v21.Root, "Page failed to load: " .. tostring(result5), 1)
	return v21
end

local function renderTabs()
	for k, v20 in pairs(v10) do
		local visible = k == v8
		UIKit.setBase(v20.Button, visible and Colors.Selected or Colors.Surface)
		v20.Button.TextColor3 = visible and Colors.AccentText or Colors.Text
		v20.Bar.Visible = visible
	end
end

selectPage = function(p, p2)
	if not v4[p] then
		return
	end

	local v20 = v8 and v8 ~= p and v9[v8]

	if v20 then
		v20.Root.Visible = false

		if v20.Page and v20.Page.OnHide then
			pcall(v20.Page.OnHide)
		end
	end

	v8 = p

	if p == "Notes" then
		v11.Unread = 0
		v11.Ids = {}
		updateNotesBadge() -- inferred equivalent call
	end

	if p == "Reports" then
		v12.New = 0
		updateReportsBadge() -- inferred equivalent call
	end

	local page = ensurePage(p)
	page.Root.Visible = true

	if page.Page and page.Page.OnShow then
		local success5, result5 = pcall(page.Page.OnShow, p2)

		if not success5 then
			warn("[ModeratorPanel] OnShow " .. p .. " failed: " .. tostring(result5))
		end
	end

	renderTabs()
end

for i, v20 in ipairs(v3) do
	local button2 = UIKit.button(scrollingFrame, string.upper(v20.Label), {
		base = Colors.Surface,
		height = 34,
		order = i,
		radius = 2,
		stroke = false,
		textSize = 12
	})

	button2.Name = "Tab_" .. v20.Id
	button2.TextXAlignment = Enum.TextXAlignment.Left
	local padding = UIKit.padding(button2, 0, 8, 0, 14)
	local frame4 = UIKit.new(
		"Frame",
		{
			BackgroundColor3 = Colors.Glow,
			BackgroundTransparency = 0.1,
			BorderSizePixel = 0,
			Visible = false
		},
		button2
	)

	v10[v20.Id] = { Button = button2, Bar = frame4, Padding = padding }
	button2.Activated:Connect(function()
		selectPage(v20.Id)
	end)
end

local function getTopbarMetrics()
	local success5, result5 = pcall(function()
		return GuiService.TopbarInset
	end)

	if success5 and result5 and result5.Width > 0 then
		return result5.Min.X, result5.Height
	end

	local success6, result6 = pcall(function()
		return GuiService:GetGuiInset()
	end)

	return 0, not (success6 and result6 and result6.Y > 0) and 36 or result6.Y
end

local function layout()
	local topbarMetrics, v20 = getTopbarMetrics()
	v7 = v20
	textButton2.Position = UDim2.new(0, topbarMetrics + 8, 0, v20 / 2)
	local v21 = v5 and 0 or 90
	textButton3.Position = UDim2.new(0, topbarMetrics + 8 + v21, 0, v20 / 2)

	local currentCamera = workspace.CurrentCamera
	local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
	local v22 = v6
	v6 = viewportSize.X < 640

	newbieModePanel.Position = UDim2.new(0, topbarMetrics + 8, 0, v20 / 2 + 15 + 6)
	newbieModePanel.Size = UDim2.fromOffset(math.min(250, viewportSize.X - 24), 0)

	local v23 = math.min(940, viewportSize.X - 24)
	local v24 = math.min(590, viewportSize.Y - v7 - 24)
	canvasGroup.Size = UDim2.fromOffset(v23, v24)
	canvasGroup.Position = UDim2.new(0.5, 0, 0.5, (math.floor(v7 / 2)))

	if v6 then
		scrollingFrame.Position = UDim2.fromOffset(0, 58)
		scrollingFrame.Size = UDim2.new(1, 0, 0, 44)
		scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
		scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X
		scrollingFrame.CanvasSize = UDim2.new()
		list.FillDirection = Enum.FillDirection.Horizontal
		frame2.Position = UDim2.fromOffset(0, 102)
		frame2.Size = UDim2.new(1, 0, 1, -124)
		label2.Visible = false
	else
		scrollingFrame.Position = UDim2.fromOffset(0, 58)
		scrollingFrame.Size = UDim2.new(0, 176, 1, -80)
		scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
		scrollingFrame.CanvasSize = UDim2.new()
		list.FillDirection = Enum.FillDirection.Vertical
		frame2.Position = UDim2.fromOffset(176, 58)
		frame2.Size = UDim2.new(1, -176, 1, -80)
		label2.Visible = true
	end

	local menuStrip = scrollingFrame:FindFirstChild("MenuStrip")

	if menuStrip then
		menuStrip.Visible = not v6
	end

	for _, v25 in pairs(v10) do
		if v6 then
			v25.Button.AutomaticSize = Enum.AutomaticSize.X
			v25.Button.Size = UDim2.fromOffset(0, 32)
			v25.Padding.PaddingLeft = UDim.new(0, 14)
			v25.Padding.PaddingRight = UDim.new(0, 14)
		else
			v25.Button.AutomaticSize = Enum.AutomaticSize.None
			v25.Button.Size = UDim2.new(1, 0, 0, 34)
			v25.Padding.PaddingLeft = UDim.new(0, 14)
			v25.Padding.PaddingRight = UDim.new(0, 8)
		end

		v25.Bar.Position = UDim2.new(0, 0, 0, 0)
		v25.Bar.Size = UDim2.new(1, 0, 0, 1)
	end

	if v22 ~= v6 then
		bindableEvent:Fire()
	end
end

local function openWindow()
	if flag then
		return
	end

	flag = true

	if result and not v2 then
		v2 = true
		result.SetMenuOpen(true)
	end

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true

	RunService:BindToRenderStep("ModeratorPanelMouseOverride", Enum.RenderPriority.Camera.Value + 50, function()
		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			return
		end

		if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end

		if not UserInputService.MouseIconEnabled then
			UserInputService.MouseIconEnabled = true
		end
	end)
	layout()
	textButton.Visible = true

	canvasGroup.Visible = true
	canvasGroup.GroupTransparency = 0
	uiScale2.Scale = 1
	chevron.Rotation = 180
	stroke.Color = Colors.Accent
	stroke.Transparency = 0.3
	selectPage(v8 or "Dashboard")
end

local function closeWindow()
	if not flag then
		return
	end

	flag = false
	pcall(function()
		RunService:UnbindFromRenderStep("ModeratorPanelMouseOverride")
	end)

	if result and v2 then
		v2 = false
		result.SetMenuOpen(false)
	end

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	textButton.Visible = false
	canvasGroup.Visible = false
	chevron.Rotation = 0
	stroke.Color = Colors.Border
	stroke.Transparency = 1
	local v20 = v8 and v9[v8]

	if v20 and v20.Page and v20.Page.OnHide then
		pcall(v20.Page.OnHide)
	end
end

local v20 = false

local function openMenu()
	if flag2 or flag then
		return
	end

	flag2 = true

	if v19.RefreshStageButtons then
		v19.RefreshStageButtons()
	end

	if result and not v20 then
		v20 = true
		result.SetMenuOpen(true)
	end

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true
	pcall(function()
		RunService:UnbindFromRenderStep("ModeratorMenuMouseOverride")
	end)
	RunService:BindToRenderStep("ModeratorMenuMouseOverride", Enum.RenderPriority.Camera.Value + 50, function()
		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			return
		end

		if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end

		if not UserInputService.MouseIconEnabled then
			UserInputService.MouseIconEnabled = true
		end
	end)
	layout()
	textButton4.Visible = true
	newbieModePanel.Visible = true
	chevron.Rotation = 180
	stroke.Color = Colors.Accent
	stroke.Transparency = 0.3
end

local function closeMenu()
	if not flag2 then
		return
	end

	flag2 = false
	pcall(function()
		RunService:UnbindFromRenderStep("ModeratorMenuMouseOverride")
	end)

	if result and v20 then
		v20 = false
		result.SetMenuOpen(false)
	end

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	textButton4.Visible = false
	newbieModePanel.Visible = false
	chevron.Rotation = 0
	stroke.Color = Colors.Border
	stroke.Transparency = 1
end

v19.CloseMenu = closeMenu
textButton2.Activated:Connect(function()
	if flag then
		closeWindow()
	elseif flag2 then
		closeMenu()
	else
		openMenu()
	end
end)

parent.Activated:Connect(function()
	closeMenu()
	openWindow()
end)

local SettingsState = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SettingsState"))
local v21 = false

local function applyModsVisibility()
	if not v21 then
		textButton2.Visible = false
		return
	end

	local showModsButton = SettingsState.GetShowModsButton()
	v5 = not showModsButton
	textButton2.Visible = showModsButton

	if not showModsButton then
		closeMenu()
		closeWindow()
	end

	layout()
end

textButton2.Visible = false
SettingsState.OnChanged(function()
	v21 = true
	local showModsButton = SettingsState.GetShowModsButton()
	v5 = not showModsButton
	textButton2.Visible = showModsButton

	if not showModsButton then
		closeMenu()
		closeWindow()
	end

	layout()
end)
task.delay(10, function()
	if not v21 then
		v21 = true
		local showModsButton = SettingsState.GetShowModsButton()
		v5 = not showModsButton
		textButton2.Visible = showModsButton

		if not showModsButton then
			closeMenu()
			closeWindow()
		end

		layout()
	end
end)

local v22 = -1
local v23 = -2
newbieModePanel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v22 = os.clock()
	end
end)
textButton4.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v23 = os.clock()
	end
end)
textButton4.Activated:Connect(function()
	if math.abs(v23 - v22) < 0.1 then
		return
	end

	closeMenu()
end)
button.Activated:Connect(closeWindow)

local frame4 = UIKit.new("Frame", {
	Name = "FooterBar",
	BackgroundColor3 = Color3.fromRGB(6, 6, 6),
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 1, -22),
	Size = UDim2.new(1, 0, 0, 22),
	ZIndex = 3
}, canvasGroup)

UIKit.new("Frame", {
	BackgroundColor3 = Colors.Border,
	BackgroundTransparency = 0.3,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0, 1),
	ZIndex = 4
}, frame4)

local function footerItem(value, p, p2, onActivated)
	local new = UIKit.new
	local v24 = {
		AnchorPoint = Vector2.new(p2 and 1 or 0, 0),
		AutoButtonColor = nil,
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = UIKit.FontBold,
		Position = 0,
		Size = 0,
		Text = 0,
		TextColor3 = 0,
		TextSize = 12,
		ZIndex = 4
	}
	p = p2 and -p or p
	v24.Position = UDim2.new(p2 and 1 or 0, p, 0, 0)
	v24.Size = UDim2.new(0, 0, 1, 0)
	v24.Text = string.upper(value)
	v24.TextColor3 = Colors.Muted
	local v25 = new(onActivated and "TextButton" or "TextLabel", v24, frame4)

	UIKit.padding(v25, 0, 4, 0, 4)

	if onActivated then
		v25.Activated:Connect(onActivated)
		v25.MouseEnter:Connect(function()
			v25.TextColor3 = Colors.Text
		end)
		v25.MouseLeave:Connect(function()
			v25.TextColor3 = Colors.Muted
		end)
	end

	return v25
end

footerItem("Close", 10, false, closeWindow)
footerItem("Refresh", 70, false, function()
	local v24 = v8 and v9[v8]

	if v24 and v24.Page and v24.Page.Refresh then
		pcall(v24.Page.Refresh)
	end
end)
footerItem(v.TierName or "Moderator", 10, true, nil)

local v24 = -1
local v25 = -2
local function isPress(input): boolean -- 2 equivalent calls inferred from this helper
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

canvasGroup.InputBegan:Connect(function(input)
	if isPress(input) then -- inferred equivalent call
		v24 = os.clock()
	end
end)
textButton.InputBegan:Connect(function(input)
	if isPress(input) then -- inferred equivalent call
		v25 = os.clock()
	end
end)
textButton.Activated:Connect(function()
	if math.abs(v25 - v24) < 0.1 then
		return
	end

	closeWindow()
end)

task.spawn(function()
	while true do
		task.wait(2.5)

		if not (flag and v8) then
			continue
		end

		local v26 = v9[v8]

		if v26 and v26.Page and v26.Page.Refresh then
			pcall(v26.Page.Refresh)
		end
	end
end)

GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(layout)
local function watchCamera() -- 2 equivalent calls inferred from this helper
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)
	end
end

watchCamera() -- inferred equivalent call
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	watchCamera() -- inferred equivalent call
	layout()
end)

RemoteEvents:WaitForChild("ModeratorNotesEvent").OnClientEvent:Connect(function(data)
	if typeof(data) ~= "table" or typeof(data.Kind) ~= "string" then
		return
	end

	local notes = v9.Notes

	if notes and notes.Page and notes.Page.OnLive then
		pcall(notes.Page.OnLive, data)
	end

	local v26

	if data.Entry == nil then
		v26 = false
	else
		v26 = data.Entry.UserId ~= LocalPlayer.UserId
	end

	local v27 = flag and v8 == "Notes"

	if data.Kind == "ChatDeleted" or data.Kind == "NoteDeleted" then
		local ids = typeof(data.Ids) == "table" and data.Ids or { data.Id }
		local flag3 = false

		for _, id in ipairs(ids) do
			if not (id ~= nil and v11.Ids[id]) then
				continue
			end

			v11.Ids[id] = nil
			v11.Unread = math.max(0, v11.Unread - 1)
			flag3 = true
		end

		if flag3 then
			updateNotesBadge() -- inferred equivalent call
		end
	end

	if v26 and not v27 and (data.Kind == "Chat" or data.Kind == "Note") then
		local id = data.Entry.Id

		if id ~= nil and not v11.Ids[id] then
			v11.Ids[id] = true
			v11.Unread += 1
			updateNotesBadge() -- inferred equivalent call
		end

		local name = tostring(data.Entry.Name)

		if data.Kind == "Chat" then
			local v28 = tostring(data.Entry.Text or ""):gsub("%s+", " ")
			local v29 = utf8.len(v28)

			if v29 and v29 > 48 then
				v28 = string.sub(v28, 1, utf8.offset(v28, 49) - 1) .. "..."
			end

			fn("@" .. name .. ": " .. v28, "info")
		elseif data.Entry.ReplyTo then
			fn("New reply from @" .. name, "info")
		else
			fn("New note from @" .. name, "info")
		end
	end
end)

local id = nil
RemoteEvents:WaitForChild("ModeratorPollEvent").OnClientEvent:Connect(function(p)
	if typeof(p) ~= "table" or p.Kind ~= "PollUpdate" then
		return
	end

	local polls = v9.Polls

	if polls and polls.Page and polls.Page.OnLive then
		pcall(polls.Page.OnLive, p)
	end

	local poll = p.Poll

	if poll then
		id = poll.Id
	elseif id then
		id = nil
		fn("Poll finished. Results are in the Polls tab.", "ok")
	end
end)

task.spawn(function()
	if v.IsTester then
		return
	end

	local moderatorReportEvent = RemoteEvents:WaitForChild("ModeratorReportEvent", 30)

	if not moderatorReportEvent then
		return
	end

	local flag3 = false
	local function refreshCount(duration) -- 3 equivalent calls inferred from this helper
		if flag3 then
			return
		end

		flag3 = true
		task.delay(duration, function()
			flag3 = false
			local reportQuery = v19.ReportQuery("Count")

			if typeof(reportQuery) == "table" and typeof(reportQuery.OpenCount) == "number" then
				v19.SetOpenReports(reportQuery.OpenCount)
			end
		end)
	end

	moderatorReportEvent.OnClientEvent:Connect(function(p)
		if typeof(p) ~= "table" then
			return
		end

		local reports = v9.Reports

		if reports and reports.Page and reports.Page.OnLive then
			pcall(reports.Page.OnLive, p)
		end

		if p.Kind == "New" and typeof(p.Report) == "table" then
			local v26 = flag and v8 == "Reports"
			v12.Open += 1

			if not v26 then
				v12.New += 1
			end

			updateReportsBadge() -- inferred equivalent call
			fn("New report: @" .. tostring(p.Report.TargetName) .. " (" .. tostring(p.Report.Category) .. ")", "info")
			refreshCount(1.2) -- inferred equivalent call
		elseif p.Kind == "Status" then
			refreshCount(1.2) -- inferred equivalent call
		end
	end)
	refreshCount(0.5) -- inferred equivalent call
end)

layout()