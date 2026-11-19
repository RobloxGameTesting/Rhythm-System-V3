local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local TabsPlayer = require(script.Parent.TabsPlayer)

local v = nil
local session = nil
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = nil
local v6 = nil
local v7 = nil

local v8 = {
	lead = true,
	rhythm = true,
	rhythmic = true,
	guitar = true,
	gitar = true,
	bass = true,
	drum = true,
	drums = true,
	tab = true,
	tabs = true,
	solo = false
}

local function songKey(value)
	local v9 = string.gsub(tostring(value or ""), "[%c]", "")
	local v10 = string.lower(string.match(v9, "^%s*(.-)%s*$") or "")
	local v11 = string.gsub(v10, "%s+", " ")

	local v12 = string.gsub(v11, "%b()", " ")
	local v13 = string.gsub(v12, "%b[]", " ")
	local v14 = string.gsub(v13, "%b{}", " ")
	local v15 = string.gsub(v14, "%s+", " ")
	local selected = string.match(v15, "^[%s%-%–%—:]*(.-)[%s%-%–%—:]*$") or v15

	for _ = 1, 4 do
		local v16, v17 = string.match(selected, "^(.-)%s+([%a]+)$")

		if not v16 or v16 == "" or not v8[v17] then
			break
		end

		selected = string.match(v16, "^(.-)[%s%-%–%—:]*$") or v16
	end

	if #selected < 1 then
		selected = v11
	end

	if #selected < 1 or #selected > 60 then
		return nil
	end

	return selected
end

local function titleKey(title) -- 2 equivalent calls inferred from this helper
	return songKey(title) or ""
end

local function notify() -- 7 equivalent calls inferred from this helper
	for _, callback in ipairs(v3) do
		pcall(callback)
	end
end

local function say(p, p2)
	for _, callback in ipairs(v4) do
		pcall(callback, p, p2 == true)
	end
end

local function fire(...)
	if v then
		v:FireServer(...)
	end
end

local function restoreSpeed() -- 3 equivalent calls inferred from this helper
	if v6 then
		TabsPlayer.SetSpeed(v6)
		v6 = nil
	end
end

local function hideToast() -- 4 equivalent calls inferred from this helper
	if v7 then
		v7:Destroy()
		v7 = nil
	end
end

local function showToast(data)
	hideToast() -- inferred equivalent call
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	local tabsBandInvite = Instance.new("ScreenGui")
	tabsBandInvite.Name = "TabsBandInvite"
	tabsBandInvite.ResetOnSpawn = false
	tabsBandInvite.DisplayOrder = 50
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 0, 16)
	frame.Size = UDim2.fromOffset(340, 74)
	frame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
	frame.BackgroundTransparency = 0.08
	frame.BorderSizePixel = 0
	frame.Parent = tabsBandInvite
	local uiCorner = Instance.new("UICorner", frame)
	uiCorner.CornerRadius = UDim.new(0, 6)
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, -16, 0, 40)
	textLabel.Position = UDim2.fromOffset(8, 4)
	textLabel.Font = Enum.Font.Oswald
	textLabel.TextSize = 16
	textLabel.TextWrapped = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
	textLabel.Text = data.HostName .. " invites you to play \"" .. data.Title .. "\" together (" .. data.Instrument .. ")"
	textLabel.Parent = frame
	local function btn(text, p, p2, onActivated)
		local textButton = Instance.new("TextButton")
		textButton.Size = UDim2.fromOffset(p2, 24)
		textButton.Position = UDim2.fromOffset(p, 46)
		textButton.BackgroundColor3 = Color3.fromRGB(70, 70, 78)
		textButton.BorderSizePixel = 0
		textButton.Font = Enum.Font.Oswald
		textButton.TextSize = 15
		textButton.TextColor3 = Color3.fromRGB(240, 240, 240)
		textButton.Text = text
		textButton.Parent = frame
		local uiCorner = Instance.new("UICorner", textButton)
		uiCorner.CornerRadius = UDim.new(0, 4)
		textButton.Activated:Connect(onActivated)
	end
	btn("OPEN BAND MENU", 8, 150, function()
		hideToast() -- inferred equivalent call

		if v5 then
			v5()
		end
	end)
	btn("IGNORE", 166, 80, hideToast)
	tabsBandInvite.Parent = playerGui
	v7 = tabsBandInvite
	task.delay(25, function()
		if v7 == tabsBandInvite then
			hideToast() -- inferred equivalent call
		end
	end)
end

local function onEvent(p, data)
	if p == "Invite" then
		v2[data.Id] = data
		showToast(data)
		notify() -- inferred equivalent call
	elseif p == "InviteEnded" then
		v2[data.Id] = nil
		notify() -- inferred equivalent call
	elseif p == "Joined" then
		session = data
		session.IsHost = data.HostUserId == Players.LocalPlayer.UserId
		v2[data.Id] = nil
		hideToast() -- inferred equivalent call
		say(
			session.IsHost and "Band created - others can join from the BAND menu" or "Joined " .. data.HostName .. "'s band",
			false
		)
		notify() -- inferred equivalent call
	elseif p == "Members" then
		if session and session.Id == data.Id then
			local isHost = session.IsHost
			session = data
			session.IsHost = isHost
			notify() -- inferred equivalent call
		end
	elseif p == "Start" then
		if not session or session.Id ~= data.Id then
			return
		end

		local track = TabsPlayer.GetTrack()

		if track and titleKey(track.Title) == titleKey(data.Title) then -- inferred equivalent call
			local bpm = track.Bpm

			if math.abs(bpm - data.Bpm) > 0.5 then
				v6 = v6 or TabsPlayer.GetSpeed()
				TabsPlayer.SetSpeed(data.Bpm / bpm)
			else
				restoreSpeed() -- inferred equivalent call
			end

			local v9, v10 = TabsPlayer.PlayAtServerTime(data.StartAt, workspace:GetServerTimeNow())

			if v9 then
				say("Get ready - the song starts together in a moment", false)
			else
				say(tostring(v10), true)
			end

			session.Started = true
			notify() -- inferred equivalent call
			return
		end

		say("Band started but your loaded tab is not \"" .. data.Title .. "\"", true)
	elseif p == "Stop" then
		if session and session.Id == data.Id then
			TabsPlayer.Stop()
			restoreSpeed() -- inferred equivalent call
			session.Started = false
			say("The host stopped the band", false)
			notify() -- inferred equivalent call
		end
	elseif p == "Ended" then
		if session and session.Id == data.Id then
			session = nil
			TabsPlayer.Stop()
			restoreSpeed() -- inferred equivalent call
			say(tostring(data.Reason or "Band ended"), false)
			notify() -- inferred equivalent call
		end
	elseif p == "Error" then
		say(tostring(data), true)
	end
end

local TabsBand = {}
TabsBand.TitleKey = titleKey

function TabsBand.Init()
	if v then
		return
	end

	task.spawn(function()
		local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 30)
		local tabsBand = remoteEvents and remoteEvents:WaitForChild("TabsBand", 30)

		if tabsBand then
			v = tabsBand
			tabsBand.OnClientEvent:Connect(onEvent)
		end
	end)
end

function TabsBand.GetSession()
	return session
end

function TabsBand.GetInvites()
	local invites = {}

	for _, v9 in pairs(v2) do
		invites[#invites + 1] = v9
	end

	table.sort(invites, function(a, b): boolean
		return a.Id < b.Id
	end)

	return invites
end

function TabsBand.Host(data)
	if data then
		fire("Host", data.Title, data.Bpm, data.Instrument)
	else
		say("Load a tab first (SONGS)", true)
	end
end

function TabsBand.Join(p, p2)
	if p2 then
		fire("Join", p, p2.Instrument, p2.Title)
	else
		say("Load your own tab of that song first (SONGS)", true)
	end
end

function TabsBand.Start()
	if session and session.IsHost then
		fire("Start", session.Id)
	end
end

function TabsBand.StopAll()
	if session and session.IsHost then
		fire("Stop", session.Id)
	end
end

function TabsBand.Leave()
	if session then
		fire("Leave", session.Id)
	end
end

function TabsBand.OnChanged(p)
	table.insert(v3, p)
end

function TabsBand.OnMessage(p)
	table.insert(v4, p)
end

function TabsBand.SetOpenHandler(p)
	v5 = p
end

return TabsBand