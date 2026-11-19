local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local function flag(attributeName): boolean -- 6 equivalent calls inferred from this helper
	return ReplicatedStorage:GetAttribute(attributeName) == true
end

local total = 0

while not flag("PopularityUi") and not flag("LikeUi") and total < 15 do -- inferred equivalent call
	task.wait(0.5)
	total += 0.5
end

if not (flag("PopularityUi") or flag("LikeUi")) then -- inferred equivalent call
	return
end

local PopularityRemotes = ReplicatedStorage:WaitForChild("PopularityRemotes", 10)

if not PopularityRemotes then
	return
end

local PopularityNotice = PopularityRemotes:WaitForChild("PopularityNotice", 10)
local PopularityLike = PopularityRemotes:WaitForChild("PopularityLike", 10)

if not (PopularityNotice and PopularityLike) then
	return
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local popularityToastGui = Instance.new("ScreenGui")
popularityToastGui.Name = "PopularityToastGui"
popularityToastGui.ResetOnSpawn = false
popularityToastGui.DisplayOrder = 40
popularityToastGui.Parent = PlayerGui

local holder = Instance.new("Frame")
holder.Name = "Holder"
holder.BackgroundTransparency = 1
holder.AnchorPoint = Vector2.new(0.5, 0)
holder.Position = UDim2.new(0.5, 0, 0, 80)
holder.Size = UDim2.new(0, 320, 0, 200)
holder.Parent = popularityToastGui

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 6)
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.Parent = holder

local count = 0

local function showToast(text, value)
	count += 1
	local frame = Instance.new("Frame")
	frame.Name = "Toast" .. count
	frame.LayoutOrder = count
	frame.Size = UDim2.new(1, 0, 0, 36)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = holder

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = frame

	local color = (value == "reward" or value == "like" or value == "like_ok") and Color3.fromRGB(255, 196, 61)
		or Color3.fromRGB(200, 200, 210)
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color
	uiStroke.Transparency = 1
	uiStroke.Thickness = 1
	uiStroke.Parent = frame

	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, -16, 1, 0)
	textLabel.Position = UDim2.new(0, 8, 0, 0)
	textLabel.Font = Enum.Font.GothamMedium
	textLabel.TextSize = 14
	textLabel.TextColor3 = color
	textLabel.TextTransparency = 1
	textLabel.TextWrapped = true
	textLabel.Text = text
	textLabel.Parent = frame

	local tweenInfo = TweenInfo.new(0.2)
	TweenService:Create(frame, tweenInfo, { BackgroundTransparency = 0.15 }):Play()
	TweenService:Create(uiStroke, tweenInfo, { Transparency = 0.4 }):Play()
	TweenService:Create(textLabel, tweenInfo, { TextTransparency = 0 }):Play()

	task.delay(3.5, function()
		local tweenInfo2 = TweenInfo.new(0.3)
		TweenService:Create(frame, tweenInfo2, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(uiStroke, tweenInfo2, { Transparency = 1 }):Play()
		TweenService:Create(textLabel, tweenInfo2, { TextTransparency = 1 }):Play()
		task.wait(0.35)
		frame:Destroy()
	end)
end

local set = {}
local popularityRow = nil
local popularityLabel = nil
local likeButton = nil
local playerCard = nil
local popularityChangedConnection = nil

local function viewedPlayer() -- 3 equivalent calls inferred from this helper
	if not playerCard then
		return nil
	end

	local popularityViewedUserId = LocalPlayer:GetAttribute("PopularityViewedUserId")

	if type(popularityViewedUserId) == "number" then
		return Players:GetPlayerByUserId(popularityViewedUserId)
	end

	return nil
end

local v = 0

local function fn()
	if not popularityRow then
		return
	end

	local v2 = viewedPlayer() -- inferred equivalent call

	if not (playerCard.Visible and v2) then
		popularityRow.Visible = false
		return
	end

	local popularity = v2:GetAttribute("Popularity")
	popularityLabel.Text = type(popularity) == "number" and "Popularity   " .. tostring((math.floor(popularity)))
		or "Popularity   -"
	popularityRow.Visible = flag("PopularityUi") -- inferred equivalent call
	likeButton.Visible = flag("LikeUi") and v2 ~= LocalPlayer -- inferred equivalent call
	local v3 = set[v2.UserId] == true
	likeButton.Text = v3 and "Liked" or "Like"
	likeButton.AutoButtonColor = not v3
	likeButton.BackgroundColor3 = v3 and Color3.fromRGB(70, 70, 76) or Color3.fromRGB(255, 196, 61)
	likeButton.TextColor3 = v3 and Color3.fromRGB(200, 200, 205) or Color3.fromRGB(25, 25, 25)
end

local function bindTarget()
	if popularityChangedConnection then
		popularityChangedConnection:Disconnect()
		popularityChangedConnection = nil
	end

	local v2 = viewedPlayer() -- inferred equivalent call

	if v2 then
		popularityChangedConnection = v2:GetAttributeChangedSignal("Popularity"):Connect(function()
			fn()
		end)
	end
end

local function buildRow()
	local playerCardGui = PlayerGui:WaitForChild("PlayerCardGui", 30)
	playerCard = playerCardGui and playerCardGui:WaitForChild("PlayerCard", 30)

	if not playerCard then
		return
	end

	popularityRow = Instance.new("Frame")
	popularityRow.Name = "PopularityRow"
	popularityRow.BackgroundTransparency = 1
	popularityRow.Size = UDim2.new(1, 0, 0, 30)
	popularityRow.LayoutOrder = 1
	popularityRow.Visible = false
	popularityRow.Parent = playerCard

	popularityLabel = Instance.new("TextLabel")
	popularityLabel.Name = "PopularityLabel"
	popularityLabel.BackgroundTransparency = 1
	popularityLabel.Size = UDim2.new(1, -90, 1, 0)
	popularityLabel.Font = Enum.Font.GothamMedium
	popularityLabel.TextSize = 14
	popularityLabel.TextXAlignment = Enum.TextXAlignment.Left
	popularityLabel.TextColor3 = Color3.fromRGB(235, 235, 240)
	popularityLabel.Text = "Popularity   -"
	popularityLabel.Parent = popularityRow

	likeButton = Instance.new("TextButton")
	likeButton.Name = "LikeButton"
	likeButton.AnchorPoint = Vector2.new(1, 0.5)
	likeButton.Position = UDim2.new(1, 0, 0.5, 0)
	likeButton.Size = UDim2.new(0, 80, 0, 26)
	likeButton.Font = Enum.Font.GothamBold
	likeButton.TextSize = 13
	likeButton.Text = "Like"
	likeButton.BorderSizePixel = 0
	likeButton.Visible = false
	likeButton.Parent = popularityRow
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 6)
	uiCorner.Parent = likeButton

	likeButton.Activated:Connect(function()
		local v2 = viewedPlayer() -- inferred equivalent call

		if not v2 or v2 == LocalPlayer or set[v2.UserId] or os.clock() < v then
			return
		end

		v = os.clock() + 2
		PopularityLike:FireServer(v2.UserId)
	end)

	playerCard:GetPropertyChangedSignal("Visible"):Connect(fn)
	LocalPlayer:GetAttributeChangedSignal("PopularityViewedUserId"):Connect(function()
		bindTarget()
		fn()
	end)
	bindTarget()
	fn()
end

PopularityNotice.OnClientEvent:Connect(function(value, value2, value3)
	if type(value) ~= "string" or type(value2) ~= "string" then
		return
	end

	if
		(value == "like_ok" or value == "like_fail")
		and type(value3) == "number"
		and (value == "like_ok" or string.find(value2, "already", 1, true))
	then
		set[value3] = true
	end

	showToast(value2, value)
	fn()
end)

task.spawn(buildRow)