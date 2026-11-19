local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModeManager = require(ReplicatedStorage.Modules.ModeManager)
local MovementConflictGuard = require(ReplicatedStorage.Modules.MovementConflictGuard)

local InputRouter = {}

local v = nil
local v2 = nil

local v3 = nil

local v4 = {}

local v5 = false

local v6 = false
local v7 = false

local v8 = false

function InputRouter.SetInputCaptured(p)
	v8 = p == true
end

local v9 = {}

function InputRouter.OnLaneEvent(p)
	table.insert(v9, p)
end

local function fireLaneEvent(p, p2, now, p3)
	for _, v10 in ipairs(v9) do
		v10(p, p2, now, p3 == true)
	end
end

local v10 = {}

function InputRouter.OnMuteEvent(p)
	table.insert(v10, p)
end

function InputRouter.HandleMute()
	if not ModeManager.IsFreePlay() then
		return
	end

	if v2 and v2.Mute then
		v2.Mute()
	end

	for _, v11 in ipairs(v10) do
		v11()
	end
end

local v11 = {}
local v12 = false

function InputRouter.OnPedalEvent(p)
	table.insert(v11, p)
end

function InputRouter.HandlePedal(p)
	local v13 = p == true

	if v13 and not ModeManager.IsFreePlay() then
		return
	end

	if v2 and v2.Pedal then
		v2.Pedal(v13)
	end

	for _, v14 in ipairs(v11) do
		v14(v13)
	end
end

function InputRouter.HandlePedalLockToggle()
	if not ModeManager.IsFreePlay() then
		return
	end

	local v13

	if v2 and v2.PedalLockToggle then
		v13 = v2.PedalLockToggle()
	end

	if v13 == nil then
		return
	end

	for _, v14 in ipairs(v11) do
		v14(nil, v13)
	end
end

function InputRouter.SetRhythmHandlers(p)
	v = p
end

function InputRouter.SetFreePlayHandlers(p)
	v2 = p
end

function InputRouter.SetActiveBindings(p)
	v3 = p
end

function InputRouter.ClearActiveBindings()
	v3 = nil
end

function InputRouter.ToggleOctaveUp()
	v5 = not v5
	return v5
end

function InputRouter.SetOctaveUp(p)
	v5 = p == true
	return v5
end

function InputRouter.IsOctaveUpEnabled()
	return v5
end

local function getLaneForKey(keyCode, isKeyDown)
	if not v3 then
		return nil
	end

	for i, v13 in ipairs(v3) do
		if typeof(v13) == "EnumItem" then
			if v13 == keyCode then
				return i
			end
		elseif v13.KeyCode == keyCode and v13.RequiresShift == isKeyDown then
			return i
		end
	end

	return nil
end

local function getActiveHandlers() -- 2 equivalent calls inferred from this helper
	if ModeManager.IsFreePlay() then
		if not (v2 or v7) then
			v7 = true
			warn("[InputRouter] Mode FreePlay aktif tapi FreePlayController belum daftar handler")
		end

		return v2
	end

	if not (v or v6) then
		v6 = true
		warn("[InputRouter] Mode Rhythm aktif tapi RhythmInput belum daftar handler")
	end

	return v
end

function InputRouter.HandlePress(p)
	local now = os.clock()
	ModeManager.GetMode()
	local activeHandlers = getActiveHandlers() -- inferred equivalent call

	if activeHandlers and activeHandlers.Press then
		if ModeManager.IsFreePlay() then
			activeHandlers.Press(p, v5, true)
		else
			activeHandlers.Press(p, v5)
		end
	end

	fireLaneEvent(p, true, now, v5)
end

function InputRouter.HandleRelease(p)
	local now = os.clock()
	ModeManager.GetMode()
	local activeHandlers = getActiveHandlers() -- inferred equivalent call

	if activeHandlers and activeHandlers.Release then
		activeHandlers.Release(p, v5)
	end

	fireLaneEvent(p, false, now, v5)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if v8 then
		return
	end

	if ModeManager.IsFreePlay() then
		if UserInputService:GetFocusedTextBox() then
			return
		end
	elseif
		gameProcessed
		and (not MovementConflictGuard.IsLocked(input.KeyCode) or UserInputService:GetFocusedTextBox())
	then
		return
	end

	if input.KeyCode == Enum.KeyCode.CapsLock then
		InputRouter.ToggleOctaveUp()
		return
	end

	if
		(input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl)
		and ModeManager.IsFreePlay()
	then
		InputRouter.HandlePedalLockToggle()
	end

	if input.KeyCode == Enum.KeyCode.Space and ModeManager.IsFreePlay() then
		InputRouter.HandleMute()

		v12 = true
		InputRouter.HandlePedal(true)
	else
		local isKeyDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
		local laneForKey = getLaneForKey(input.KeyCode, isKeyDown)

		if laneForKey then
			v4[input.KeyCode] = laneForKey
			InputRouter.HandlePress(laneForKey)
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, _)
	if input.KeyCode == Enum.KeyCode.Space and v12 then
		v12 = false
		InputRouter.HandlePedal(false)
	end

	local v13 = v4[input.KeyCode]

	if v13 then
		v4[input.KeyCode] = nil
		InputRouter.HandleRelease(v13)
	end
end)

return InputRouter