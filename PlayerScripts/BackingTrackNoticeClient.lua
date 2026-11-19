local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local BackingTrackNotice = RemoteEvents:WaitForChild("BackingTrackNotice")
local StopOrphanBackingTrack = RemoteEvents:WaitForChild("StopOrphanBackingTrack")
local SongSessionStatusUpdate = RemoteEvents:WaitForChild("SongSessionStatusUpdate")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local BackingTrackNoticeUI = require(Modules:WaitForChild("BackingTrackNoticeUI"))
local SongConfigAdapter = require(Modules:WaitForChild("SongConfigAdapter"))

local success, result = pcall(function()
	return require(Modules:WaitForChild("SongListUI"):WaitForChild("InstrumentList"))
end)

local backingTrackNoticeGui = Instance.new("ScreenGui")
backingTrackNoticeGui.Name = "BackingTrackNoticeGui"
backingTrackNoticeGui.ResetOnSpawn = false
backingTrackNoticeGui.IgnoreGuiInset = true
backingTrackNoticeGui.DisplayOrder = 60
backingTrackNoticeGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
backingTrackNoticeGui.Parent = PlayerGui

local v = BackingTrackNoticeUI.new(backingTrackNoticeGui)

local BackingTrackJoinRequest = ReplicatedStorage:WaitForChild("BackingTrackJoinRequest")
local v2 = nil
local v3 = nil

local function songTitle(p) -- 2 equivalent calls inferred from this helper
	local song = SongConfigAdapter.GetSong(SongConfigAdapter.GetSongId(p))
	local v4 = song and song.displayName or tostring(p)

	if song and song.artist and song.artist ~= "" then
		return song.artist .. " - " .. v4
	end

	return v4
end

local function instrumentName(p) -- 1 equivalent call inferred from this helper
	if success and result and result.DefaultNames and result.DefaultNames[p] then
		return result.DefaultNames[p]
	end

	return (tostring(p))
end

BackingTrackNotice.OnClientEvent:Connect(function(p, p2, p3)
	if p == "StillPlaying" then
		v:ShowStillPlaying(songTitle(p3)) -- inferred equivalent call
	elseif p == "PressPlay" then
		v2 = p2
		v:ShowPressPlay(instrumentName(p3)) -- inferred equivalent call
	elseif p == "Ended" then
		v:HideStillPlaying()
	elseif p == "WrongSong" then
		v3 = p2
		v:ShowWrongSong(songTitle(p2)) -- inferred equivalent call
	elseif p == "WrongSongClear" then
		v3 = nil
		v:HideWrongSong()
	end
end)

v.StopClicked:Connect(function()
	v:HideStillPlaying()
	StopOrphanBackingTrack:FireServer()
end)

v.JoinClicked:Connect(function()
	local v4 = v2
	v2 = nil
	v:HidePressPlay()

	if v4 then
		BackingTrackJoinRequest:Fire(v4)
	end
end)

v.DismissClicked:Connect(function()
	v:HideStillPlaying()
end)

v.WrongJoinClicked:Connect(function()
	local v4 = v3
	v3 = nil
	v:HideWrongSong()

	if v4 then
		BackingTrackJoinRequest:Fire(v4)
	end
end)

v.WrongDismissClicked:Connect(function()
	v3 = nil
	v:HideWrongSong()
end)

LocalPlayer:GetAttributeChangedSignal("EquippedInstrumentType"):Connect(function()
	if LocalPlayer:GetAttribute("EquippedInstrumentType") ~= nil then
		v:HideStillPlaying()
	end
end)

SongSessionStatusUpdate.OnClientEvent:Connect(function(p)
	if p then
		v:HidePressPlay()
		v:HideStillPlaying()
	else
		v3 = nil
		v:HideWrongSong()
	end
end)