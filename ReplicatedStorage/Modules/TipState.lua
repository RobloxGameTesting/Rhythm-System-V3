local TipState = {}
TipState.__index = TipState

function TipState.new(player, write, p)
	local object = setmetatable({}, TipState)
	object._player = player
	object._write = write
	object._clock = p or os.clock
	object._local = {}
	object._lastShownAt = -1000000000
	object.CooldownSeconds = 45

	if player and player.GetAttributeChangedSignal then
		player:GetAttributeChangedSignal("TipsSeen"):Connect(function()
			if player:GetAttribute("TipsSeen") == "" then
				object._local = {}
			end
		end)
	end

	return object
end

function TipState:_serverSet()
	local tipsSeen = self._player and self._player:GetAttribute("TipsSeen")

	if tipsSeen == nil then
		return nil
	end

	local result = {}

	for k in tostring(tipsSeen):gmatch("[^,]+") do
		result[k] = true
	end

	return result
end

function TipState:IsSeen(p): nil | boolean
	if self._local[p] then
		return true
	end

	local serverSet = self:_serverSet()

	if serverSet == nil then
		return nil
	end

	return serverSet[p] == true or serverSet.ALL == true
end

function TipState:MarkSeen(p)
	if self._local[p] then
		return
	end

	self._local[p] = true
	local v = self:_serverSet() or {}

	if v.ALL then
		return
	end

	local set = {}

	for k in pairs(v) do
		set[k] = true
	end

	for k in pairs(self._local) do
		set[k] = true
	end

	self._write(set)
end

function TipState:CanShowNow(): boolean
	return self._clock() - self._lastShownAt >= self.CooldownSeconds
end

function TipState:NoteShown()
	self._lastShownAt = self._clock()
end

local v = nil
function TipState.ForLocalPlayer()
	if not v then
		local Players = game:GetService("Players")
		local SettingsState = require(script.Parent:WaitForChild("SettingsState"))
		v = TipState.new(Players.LocalPlayer, function(p)
			SettingsState.SetField("TipsSeen", p, true)
		end)
	end

	return v
end

return TipState