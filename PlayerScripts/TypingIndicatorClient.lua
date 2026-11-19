local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local TypingIndicatorConfig = require(ReplicatedStorage.Modules.TypingIndicatorSystem.TypingIndicatorConfig)

local PlayerTypingStateChanged = ReplicatedStorage.RemoteEvents:WaitForChild("PlayerTypingStateChanged")

local LocalPlayer = Players.LocalPlayer

local v = {}

local function buildDotsText(p) -- 1 equivalent call inferred from this helper
	local DOT_CHARs = table.create(p)

	for i = 1, p do
		DOT_CHARs[i] = TypingIndicatorConfig.DOT_CHAR
	end

	return table.concat(DOT_CHARs, TypingIndicatorConfig.DOT_SEPARATOR)
end

local function findHead(character) -- 1 equivalent call inferred from this helper
	if character then
		return character:FindFirstChild("Head")
	end

	return nil
end

local function createIndicatorInstances()
	local typingIndicator = Instance.new("BillboardGui")
	typingIndicator.Name = "TypingIndicator"
	typingIndicator.Size = TypingIndicatorConfig.BILLBOARD_SIZE
	typingIndicator.StudsOffset = TypingIndicatorConfig.STUDS_OFFSET
	typingIndicator.AlwaysOnTop = TypingIndicatorConfig.ALWAYS_ON_TOP
	typingIndicator.MaxDistance = TypingIndicatorConfig.MAX_VIEW_DISTANCE
	typingIndicator.Enabled = false
	typingIndicator.Adornee = nil

	local dotsLabel = Instance.new("TextLabel")
	dotsLabel.Name = "DotsLabel"
	dotsLabel.Size = UDim2.fromScale(1, 1)
	dotsLabel.BackgroundTransparency = 1
	dotsLabel.Font = TypingIndicatorConfig.FONT
	dotsLabel.TextSize = TypingIndicatorConfig.TEXT_SIZE
	dotsLabel.TextColor3 = TypingIndicatorConfig.TEXT_COLOR
	dotsLabel.TextTransparency = TypingIndicatorConfig.TEXT_TRANSPARENCY
	dotsLabel.TextStrokeColor3 = TypingIndicatorConfig.TEXT_STROKE_COLOR
	dotsLabel.TextStrokeTransparency = TypingIndicatorConfig.TEXT_STROKE_TRANSPARENCY
	dotsLabel.Text = ""
	dotsLabel.Parent = typingIndicator

	return typingIndicator, dotsLabel
end

local function getOrCreateIndicator(player)
	local v2 = v[player]

	if v2 then
		return v2
	end

	local indicatorInstances, label = createIndicatorInstances()
	indicatorInstances.Parent = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui")

	local v3 = { Billboard = indicatorInstances, Label = label, Character = player.Character }

	v[player] = v3
	return v3
end

local function destroyIndicator(player) -- 2 equivalent calls inferred from this helper
	local v2 = v[player]

	if not v2 then
		return
	end

	v[player] = nil

	if v2.Billboard then
		v2.Billboard:Destroy()
	end
end

local function setPlayerTyping(player, p)
	if p then
		local indicator = getOrCreateIndicator(player)
		indicator.Character = player.Character
		local billboard = indicator.Billboard
		billboard.Adornee = findHead(player.Character) -- inferred equivalent call
		indicator.Billboard.Enabled = indicator.Billboard.Adornee ~= nil
		local label = indicator.Label
		local DOT_CHARs = table.create(1)

		DOT_CHARs[1] = TypingIndicatorConfig.DOT_CHAR

		label.Text = table.concat(DOT_CHARs, TypingIndicatorConfig.DOT_SEPARATOR)
	else
		destroyIndicator(player) -- inferred equivalent call
	end
end

local function setupSender()
	local chatInputBarConfiguration = TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")
		or TextChatService:WaitForChild("ChatInputBarConfiguration", 10)

	if not chatInputBarConfiguration then
		warn("[TypingIndicatorClient] ChatInputBarConfiguration tidak ditemukan - fitur typing indicator dilewati")
		return
	end

	local v2 = nil
	local function reportState() -- 1 equivalent call inferred from this helper
		local isFocused = chatInputBarConfiguration.IsFocused

		if isFocused == v2 then
			return
		end

		v2 = isFocused

		setPlayerTyping(LocalPlayer, isFocused)
		PlayerTypingStateChanged:FireServer(isFocused)
	end

	chatInputBarConfiguration:GetPropertyChangedSignal("IsFocused"):Connect(reportState)
	reportState() -- inferred equivalent call
end

local function watchCharacterChanges(p) -- 1 equivalent call inferred from this helper
	p.CharacterAdded:Connect(function(character)
		local v2 = v[p]

		if not v2 then
			return
		end

		v2.Character = character
		local head = character:WaitForChild("Head", 5)
		v2.Billboard.Adornee = head
		v2.Billboard.Enabled = head ~= nil
	end)
end

for _, v2 in ipairs(Players:GetPlayers()) do
	watchCharacterChanges(v2) -- inferred equivalent call
end

Players.PlayerAdded:Connect(watchCharacterChanges)

Players.PlayerRemoving:Connect(function(player)
	destroyIndicator(player) -- inferred equivalent call
end)

PlayerTypingStateChanged.OnClientEvent:Connect(function(player, p)
	if typeof(player) ~= "Instance" or not player:IsA("Player") or typeof(p) ~= "boolean" then
		return
	end

	setPlayerTyping(player, p)
end)

local function stepAnimation()
	if next(v) == nil then
		return
	end

	local v2 = TypingIndicatorConfig.MAX_DOTS * TypingIndicatorConfig.DOT_STEP_DURATION
	local dotsText = buildDotsText(math.floor(os.clock() % v2 / TypingIndicatorConfig.DOT_STEP_DURATION) + 1) -- inferred equivalent call

	for _, v3 in pairs(v) do
		if v3.Label.Text ~= dotsText then
			v3.Label.Text = dotsText
		end
	end
end

RunService.Heartbeat:Connect(stepAnimation)

setupSender()