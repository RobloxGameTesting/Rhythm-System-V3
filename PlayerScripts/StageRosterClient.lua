local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local StageRosterHUD = require(ReplicatedStorage.Modules.StageRosterHUD)
local SongConfig = require(ReplicatedStorage.Modules.SongConfig)
local StageNames = require(ReplicatedStorage.Modules.StageNames)
local SongConfigAdapter = require(ReplicatedStorage.Modules.SongConfigAdapter)

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local MyStudioIdUpdate = RemoteEvents:WaitForChild("MyStudioIdUpdate")
local StageRosterUpdate = RemoteEvents:WaitForChild("StageRosterUpdate")
local StudioSessionUpdate = RemoteEvents:WaitForChild("StudioSessionUpdate")
local MicStateUpdate = RemoteEvents:WaitForChild("MicStateUpdate")
local InvitePartyUpdate = RemoteEvents:WaitForChild("InvitePartyUpdate")
local RoomStateUpdate = RemoteEvents:WaitForChild("RoomStateUpdate")
local StageRoomSnapshot = RemoteEvents:WaitForChild("StageRoomSnapshot")
local StageRosterRequest = RemoteEvents:WaitForChild("StageRosterRequest")
local StageLastReportInfo = RemoteEvents:WaitForChild("StageLastReportInfo")
local StageLastReportRequest = RemoteEvents:WaitForChild("StageLastReportRequest")

local LocalPlayer = Players.LocalPlayer

local v = {
	GuitarRhythm = "Rhythm Guitar",
	GuitarLead = "Lead Guitar",
	Bass = "Bass",
	Drum = "Drum",
	Keyboard = "Keyboard",
	Piano = "Piano"
}

local v2 = { "GuitarRhythm", "GuitarLead", "Drum", "Bass", "Keyboard", "Piano" }

local v3 = nil

local v4 = nil

local v5 = {}

local v6 = {}

local vocalistNames = {}

local v7 = nil

local v8 = {}

local v9 = {}

local displays = {}
local function getStageName(viewStudioId)
	local v10 = displays[viewStudioId]

	if v10 then
		return v10
	end

	local map = Workspace:FindFirstChild("Map")

	if not map then
		return "STAGE"
	end

	for _, child in ipairs(map:GetChildren()) do
		if child:GetAttribute("StudioId") == viewStudioId then
			local display = StageNames.Display(child.Name)
			displays[viewStudioId] = display
			return display
		end
	end

	return "STAGE"
end

local function getRoomEntry(p) -- 2 equivalent calls inferred from this helper
	local roomEntry = v8[p]

	if not roomEntry then
		roomEntry = { admin = nil, statuses = {} }
		v8[p] = roomEntry
	end

	return roomEntry
end

local function getViewStudioId() -- 8 equivalent calls inferred from this helper
	return v3 or v7 or v4
end

local function buildRoomStatus(viewStudioId, p, p2)
	local v10 = v8[viewStudioId]

	if not (v10 and v10.admin) then
		return nil
	end

	local status = v10.statuses[p]

	if status == "invited" then
		return string.format(
			"<font color=\"#%s\">Invited to @%s's room</font>",
			StageRosterHUD.AccentColorHex,
			v10.admin
		)
	elseif status == "ready" then
		return string.format(
			"in @%s's room - <font color=\"#%s\">Ready</font>",
			v10.admin,
			StageRosterHUD.ReadyColorHex
		)
	end

	if status then
		return string.format(
			"in @%s's room - <font color=\"#%s\">Not ready</font>",
			v10.admin,
			StageRosterHUD.NotReadyColorHex
		)
	end

	return if p2 == v10.admin then "Room host" else nil
end

local function getSongDisplayName(p)
	if not p then
		return nil
	end

	local song = SongConfig.Songs[p]
	return song and song.DisplayName or p
end

local function render()
	local viewStudioId = getViewStudioId() -- inferred equivalent call

	if not viewStudioId then
		StageRosterHUD.Hide()
		return
	end

	local v10 = v5[viewStudioId] or {}
	local v11 = v6[viewStudioId] or {}

	local function findPlayingSong(p, p2) -- 2 equivalent calls inferred from this helper
		for k, v12 in pairs(v11) do
			local v13 = v12[p]

			if v13 and v13.PlayerName == p2 then
				return k
			end
		end

		return nil
	end

	local v12 = {}

	for _, instrument in ipairs(v2) do
		local v13 = v10[instrument]

		if not v13 then
			continue
		end

		local v14 = v[instrument] or instrument
		local text = string.format("%s - @%s", v14, v13)
		local child = Players:FindFirstChild(v13)

		if child and child:GetAttribute("FreePlayMode") == true then
			text ..= " - freeplay"
		end

		local playingSong = findPlayingSong(instrument, v13) -- inferred equivalent call
		local dot = nil

		if playingSong then
			local accentColorHex = StageRosterHUD.AccentColorHex
			local v15

			if playingSong then
				local song = SongConfig.Songs[playingSong]

				if song then
					v15 = song.DisplayName or playingSong
				else
					v15 = playingSong
				end
			end

			text ..= string.format(" - <font color=\"#%s\">%s</font>", accentColorHex, v15)

			dot = SongConfigAdapter.GetInstrumentTier(playingSong, instrument)
		else
			local roomStatus = buildRoomStatus(viewStudioId, instrument, v13)

			if roomStatus then
				text ..= " - " .. roomStatus
			end
		end

		table.insert(v12, { text = text, dot = dot, instrument = instrument })
	end

	local v13 = vocalistNames[viewStudioId]

	if v13 then
		table.insert(v12, string.format("Vocalist - @%s", v13))
	end

	if #v12 == 0 then
		StageRosterHUD.Hide()
		return
	end

	StageRosterHUD.SetEntries(v12)
	local v14 = false

	for k, v15 in pairs(v10) do
		if v15 == LocalPlayer.Name and findPlayingSong(k, v15) then -- inferred equivalent call
			v14 = true
			break
		end
	end

	if not v14 and v7 == viewStudioId and next(v11) ~= nil or v14 then
		StageRosterHUD.SetReportButton(nil)
	else
		StageRosterHUD.SetReportButton(string.upper(getStageName(viewStudioId)), v9[viewStudioId] ~= nil, function()
			StageLastReportRequest:FireServer(viewStudioId)
		end)
	end

	StageRosterHUD.Show()
end

local function watchPlayerFreePlayMode(object) -- 1 equivalent call inferred from this helper
	object:GetAttributeChangedSignal("FreePlayMode"):Connect(render)
end

for _, v10 in ipairs(Players:GetPlayers()) do
	watchPlayerFreePlayMode(v10) -- inferred equivalent call
end

Players.PlayerAdded:Connect(watchPlayerFreePlayMode)

MyStudioIdUpdate.OnClientEvent:Connect(function(p)
	v3 = p
	render()
end)

StageRosterUpdate.OnClientEvent:Connect(function(p, options)
	v5[p] = options or {}

	if p == getViewStudioId() then -- inferred equivalent call
		render()
	end
end)

StudioSessionUpdate.OnClientEvent:Connect(function(p, p2, items)
	if p2 then
		local v10 = v6[p]

		if items and next(items) ~= nil then
			if not v10 then
				v10 = {}
				v6[p] = v10
			end

			v10[p2] = items
		elseif v10 then
			v10[p2] = nil

			if next(v10) == nil then
				v6[p] = nil
			end
		end
	end

	if p == getViewStudioId() then -- inferred equivalent call
		render()
	end
end)

InvitePartyUpdate.OnClientEvent:Connect(function(p, p2, p3, _, admin)
	local roomEntry = getRoomEntry(p) -- inferred equivalent call
	roomEntry.statuses[p2] = p3

	if p3 and admin then
		roomEntry.admin = admin
	end

	if p == getViewStudioId() then -- inferred equivalent call
		render()
	end
end)

RoomStateUpdate.OnClientEvent:Connect(function(p, admin)
	if admin then
		local roomEntry = getRoomEntry(p) -- inferred equivalent call
		roomEntry.admin = admin
	else
		v8[p] = nil
	end

	if p == getViewStudioId() then -- inferred equivalent call
		render()
	end
end)

StageRoomSnapshot.OnClientEvent:Connect(function(p, admin, options)
	if admin then
		v8[p] = {
			admin = admin,
			statuses = options or {}
		}
	else
		v8[p] = nil
	end

	if p == getViewStudioId() then -- inferred equivalent call
		render()
	end
end)

MicStateUpdate.OnClientEvent:Connect(function(p, p2)
	vocalistNames[p] = p2.VocalistName
	local v10 = v7 == p

	if p2.VocalistUserId == LocalPlayer.UserId then
		v7 = p
	elseif v10 then
		v7 = nil
	end

	if p == getViewStudioId() or v10 then -- inferred equivalent call
		render()
	end
end)

StageLastReportInfo.OnClientEvent:Connect(function(p, p2)
	v9[p] = p2

	if p == getViewStudioId() then -- inferred equivalent call
		render()
	end
end)

local function computeZoneStudioId(map)
	local character = LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil
	end

	for _, child in ipairs(map:GetChildren()) do
		local stageZone = child:FindFirstChild("StageZone")
		local studioId = child:GetAttribute("StudioId")

		if not (studioId and stageZone and stageZone:IsA("BasePart")) then
			continue
		end

		local pointToObjectSpace = stageZone.CFrame:PointToObjectSpace(humanoidRootPart.Position)
		local v10 = stageZone.Size * 0.5

		if
			math.abs(pointToObjectSpace.X) <= v10.X + 0
			and math.abs(pointToObjectSpace.Y) <= v10.Y + 0
			and math.abs(pointToObjectSpace.Z) <= v10.Z + 0
		then
			return studioId
		end
	end

	return nil
end

local viewerCountChangedConnection = nil
local v10 = nil

local success, result = pcall(function()
	return require(ReplicatedStorage.Modules:WaitForChild("BandCamera"):WaitForChild("BandCameraController"))
end)

if not success then
	warn("[StageRosterClient] BandCameraController tidak bisa dimuat (label viewer tidak akan tampil): " .. tostring(result))
	result = nil
end

local function dynamicCamActive()
	if not result then
		return false
	end

	local success2, uiState = pcall(result.GetUIState)

	if success2 then
		if type(uiState) == "table" then
			success2 = uiState.running == true
		else
			success2 = false
		end
	end

	return success2
end

local function findStageFolder(instance, p)
	for _, child in ipairs(instance:GetChildren()) do
		if child:GetAttribute("StudioId") == p then
			return child
		end
	end

	return nil
end

local function refreshViewerCount()
	if v10 then
		local success2

		if result then
			local uiState
			success2, uiState = pcall(result.GetUIState)

			if success2 then
				if type(uiState) == "table" then
					success2 = uiState.running == true
				else
					success2 = false
				end
			end
		else
			success2 = false
		end

		if success2 then
			local viewerCount = v10:GetAttribute("ViewerCount")
			StageRosterHUD.SetViewerCount(typeof(viewerCount) == "number" and viewerCount or 0)
			return
		end
	end

	StageRosterHUD.SetViewerCount(nil)
end

if result then
	result.OnChanged(refreshViewerCount)
end

local function bindViewerStage(p)
	if viewerCountChangedConnection then
		viewerCountChangedConnection:Disconnect()
		viewerCountChangedConnection = nil
	end

	v10 = v4 and findStageFolder(p, v4) or nil

	if v10 then
		viewerCountChangedConnection = v10:GetAttributeChangedSignal("ViewerCount"):Connect(refreshViewerCount)
	end

	if v10 then
		local success2

		if result then
			local uiState
			success2, uiState = pcall(result.GetUIState)

			if success2 then
				if type(uiState) == "table" then
					success2 = uiState.running == true
				else
					success2 = false
				end
			end
		else
			success2 = false
		end

		if success2 then
			local viewerCount = v10:GetAttribute("ViewerCount")
			StageRosterHUD.SetViewerCount(typeof(viewerCount) == "number" and viewerCount or 0)

			return
		end
	end

	StageRosterHUD.SetViewerCount(nil)
end

task.spawn(function()
	local map = Workspace:WaitForChild("Map")
	StageRosterRequest:FireServer()

	while true do
		local v11 = computeZoneStudioId(map)

		if v11 ~= v4 then
			v4 = v11

			if viewerCountChangedConnection then
				viewerCountChangedConnection:Disconnect()
				viewerCountChangedConnection = nil
			end

			local v12

			if v4 then
				v12 = findStageFolder(map, v4) or nil
			end

			v10 = v12

			if v10 then
				viewerCountChangedConnection = v10:GetAttributeChangedSignal("ViewerCount"):Connect(refreshViewerCount)
			end

			if v10 then
				local success2

				if result then
					local uiState
					success2, uiState = pcall(result.GetUIState)
					local viewerCount

					if success2 then
						if type(uiState) == "table" then
							success2 = uiState.running == true

							if success2 then
								viewerCount = v10:GetAttribute("ViewerCount")
								StageRosterHUD.SetViewerCount(typeof(viewerCount) == "number" and viewerCount or 0)
							else
								StageRosterHUD.SetViewerCount(nil)
							end
						else
							success2 = false
							StageRosterHUD.SetViewerCount(nil)
						end
					elseif success2 then
						viewerCount = v10:GetAttribute("ViewerCount")
						StageRosterHUD.SetViewerCount(typeof(viewerCount) == "number" and viewerCount or 0)
					else
						StageRosterHUD.SetViewerCount(nil)
					end
				else
					success2 = false
					StageRosterHUD.SetViewerCount(nil)
				end
			else
				StageRosterHUD.SetViewerCount(nil)
			end

			if v11 then
				StageRosterRequest:FireServer()
			end

			render()
		end

		if v10 then
			local success2

			if result then
				local uiState
				success2, uiState = pcall(result.GetUIState)

				if success2 then
					if type(uiState) == "table" then
						success2 = uiState.running == true
					else
						success2 = false
						StageRosterHUD.SetViewerCount(nil)

						task.wait(0.25)
						continue
					end
				end

				if success2 then
					local viewerCount = v10:GetAttribute("ViewerCount")
					StageRosterHUD.SetViewerCount(typeof(viewerCount) == "number" and viewerCount or 0)

					task.wait(0.25)
					continue
				end
			else
				success2 = false
			end
		end

		StageRosterHUD.SetViewerCount(nil)

		task.wait(0.25)
	end
end)