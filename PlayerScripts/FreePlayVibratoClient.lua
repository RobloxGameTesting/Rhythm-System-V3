local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local FreePlayVibrato = require(Modules:WaitForChild("FreePlayVibrato"))
local RhythmVibratoFx = require(Modules:WaitForChild("RhythmVibratoFx"))
local ModeManager = require(Modules:WaitForChild("ModeManager"))
local FreePlayController = require(Modules:WaitForChild("FreePlayController"))
local FreePlayAutoMuteConfig = require(Modules:WaitForChild("FreePlayAutoMuteConfig"))
local FreePlayReplicationAdapter = require(Modules:WaitForChild("FreePlayReplicationAdapter"))
local InstrumentLifecycleSignal = require(Modules:WaitForChild("InstrumentLifecycleSignal"))
local VibratoWhammy = require(Modules:WaitForChild("VibratoWhammy"))
local SettingsState = require(Modules:WaitForChild("SettingsState"))
local instrumentHUDUpdate = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("InstrumentHUDUpdate")

local LocalPlayer = Players.LocalPlayer

local v = nil
local v2 = nil

instrumentHUDUpdate.OnClientEvent:Connect(function(p, p2, p3)
	if p then
		v = p2
		v2 = p3
	else
		v = nil
		v2 = nil
		FreePlayVibrato.ResetActive()
	end
end)

local function isEligible() -- 5 equivalent calls inferred from this helper
	local v3 = v or FreePlayController.GetCurrentInstrumentType()
	return v3 ~= nil and FreePlayAutoMuteConfig.IsAutoMuteInstrument(v3)
end

FreePlayVibrato.SetGateProvider(function()
	if ModeManager.IsRhythm() then
		return RhythmVibratoFx.IsHolding()
	end

	return true
end)

local function isVibratoInput(input) -- 1 equivalent call inferred from this helper
	if ModeManager.IsRhythm() then
		return SettingsState.MatchesVibratoInput(input)
	end

	return input.KeyCode == Enum.KeyCode.LeftControl
end

UserInputService.InputBegan:Connect(function(input)
	if not isVibratoInput(input) or UserInputService:GetFocusedTextBox() or not isEligible() then -- inferred equivalent call
		return
	end

	FreePlayVibrato.CtrlDown()
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftControl or SettingsState.MatchesVibratoInput(input) then
		FreePlayVibrato.CtrlUp()
	end
end)

UserInputService.WindowFocusReleased:Connect(function()
	FreePlayVibrato.CtrlUp()
end)

local function syncVibratoContext() -- 2 equivalent calls inferred from this helper
	FreePlayVibrato.SetContext(ModeManager.IsRhythm() and "Rhythm" or "FreePlay")
end

syncVibratoContext() -- inferred equivalent call
ModeManager.OnChanged(function()
	FreePlayVibrato.ResetActive()
	syncVibratoContext() -- inferred equivalent call
end)

local flag = false
local v3 = 0
local v4 = 0
local v5 = false
local v6 = false
local v7 = 0
local v8 = VibratoWhammy.new()

local function pointerOverVibratoHud() -- 1 equivalent call inferred from this helper
	local rhythmVibratoHUD = LocalPlayer.PlayerGui:FindFirstChild("RhythmVibratoHUD")
	local rhythmVibratoHUDContainer = rhythmVibratoHUD and rhythmVibratoHUD:FindFirstChild("Container")
	return rhythmVibratoHUDContainer ~= nil
		and rhythmVibratoHUDContainer.Visible
		and rhythmVibratoHUDContainer:GetAttribute("PointerDown") == true
end

local function releaseMouse() -- 3 equivalent calls inferred from this helper
	flag = false
	v3 = 0
end

local function whammyAllowed() -- 2 equivalent calls inferred from this helper
	return ModeManager.IsRhythm() and isEligible() and RhythmVibratoFx.IsHolding() -- inferred equivalent call
end

ContextActionService:BindActionAtPriority("FreePlayVibratoWhammyStick", function(_, _, p)
	local position = p.Position
	local x = math.abs(position.X) >= math.abs(position.Y) and position.X or position.Y
	local v9 = math.abs(x)

	if v9 < 0.14 then
		v7 = 0
	else
		v7 = math.sign(x) * (v9 - 0.14) / 0.86
	end

	if whammyAllowed() then -- inferred equivalent call
		return Enum.ContextActionResult.Sink
	end

	return Enum.ContextActionResult.Pass
end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.Thumbstick2)

RunService.Heartbeat:Connect(function(dt)
	local v9 = whammyAllowed() -- inferred equivalent call
	local isMouseButtonPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)

	if isMouseButtonPressed and not v5 then
		v6 = pointerOverVibratoHud() -- inferred equivalent call
	end

	v5 = isMouseButtonPressed

	if isMouseButtonPressed and not v6 and FreePlayVibrato.GetMouseEnabled() then
		if isEligible() then -- inferred equivalent call
			local mouseLocation = UserInputService:GetMouseLocation()

			if flag then
				local v10

				if UserInputService.MouseBehavior == Enum.MouseBehavior.Default then
					v10 = mouseLocation.X - v4
				else
					v10 = UserInputService:GetMouseDelta().X
				end

				v4 = mouseLocation.X

				if v9 then
					if v10 ~= 0 then
						v3 = math.clamp(v3 + v10 * 1.3, -FreePlayVibrato.BEND_MAX, FreePlayVibrato.BEND_MAX)
					end
				else
					v3 = 0
				end
			else
				flag = true
				v3 = 0
				v4 = mouseLocation.X
			end
		elseif flag then
			releaseMouse() -- inferred equivalent call
		end
	elseif flag then
		releaseMouse() -- inferred equivalent call
	end

	local v10

	if v9 then
		if v7 == 0 then
			v10 = v3
		else
			v10 = v7 * FreePlayVibrato.BEND_MAX
		end
	else
		v10 = 0
	end

	local v11, v12, v13, v14 = v8:Step(dt, v10, os.clock())
	FreePlayVibrato.SetBend(v11)
	FreePlayVibrato.SetWhammy(v12 and v9, v13, v14)
end)

UserInputService.WindowFocusReleased:Connect(releaseMouse)

FreePlayVibrato.OnChanged(function()
	if not FreePlayVibrato.GetMouseEnabled() then
		releaseMouse() -- inferred equivalent call
	end
end)

local v9 = {
	Active = false,
	Armed = false,
	Rate = 0,
	Dir = "",
	Bend = 0,
	Depth = 1,
	Time = 0
}

local function sendVibratoState(p)
	local eligible = isEligible() -- inferred equivalent call
	local sendState, rate, dir, depth = FreePlayVibrato.GetSendState()
	local active = eligible and sendState
	local armed = eligible and FreePlayVibrato.IsArmed()
	local bend = eligible and FreePlayVibrato.GetEffectiveBend() or 0

	if not p then
		if active == v9.Active and armed == v9.Armed then
			if bend == 0 then
				p = v9.Bend ~= 0
			else
				p = false
			end
		else
			p = true
		end
	end

	if
		not p
		and (not active or not (math.abs(rate - v9.Rate) >= 0.15) and dir == v9.Dir and not (math.abs(depth - v9.Depth) >= 0.05))
		and not (math.abs(bend - v9.Bend) >= 2)
	then
		return
	end

	local now = os.clock()

	if not p and now - v9.Time < 0.066 then
		return
	end

	v9.Active = active
	v9.Armed = armed
	v9.Rate = rate
	v9.Dir = dir
	v9.Bend = bend
	v9.Depth = depth
	v9.Time = now

	FreePlayReplicationAdapter:ReplicateVibrato(active, rate, dir, bend, armed, depth)
end

RunService.Heartbeat:Connect(function()
	sendVibratoState(false)
end)

instrumentHUDUpdate.OnClientEvent:Connect(function(p)
	if p then
		task.delay(0.6, function()
			local v10
			local v11 = v or FreePlayController.GetCurrentInstrumentType()

			if v11 == nil then
				v10 = false
			else
				v10 = FreePlayAutoMuteConfig.IsAutoMuteInstrument(v11)
			end

			local sendState, rate, dir, depth = FreePlayVibrato.GetSendState()
			local active = v10 and sendState
			local armed = v10 and FreePlayVibrato.IsArmed()
			local bend = v10 and FreePlayVibrato.GetEffectiveBend() or 0

			local now = os.clock()

			v9.Active = active
			v9.Armed = armed
			v9.Rate = rate
			v9.Dir = dir
			v9.Bend = bend
			v9.Depth = depth
			v9.Time = now

			FreePlayReplicationAdapter:ReplicateVibrato(active, rate, dir, bend, armed, depth)
		end)
	end
end)

InstrumentLifecycleSignal.Event:Connect(function(p)
	if typeof(p) == "table" and p.Lifecycle == "SessionStart" then
		task.delay(0.6, function()
			local v10
			local v11 = v or FreePlayController.GetCurrentInstrumentType()

			if v11 == nil then
				v10 = false
			else
				v10 = FreePlayAutoMuteConfig.IsAutoMuteInstrument(v11)
			end

			local sendState, rate, dir, depth = FreePlayVibrato.GetSendState()
			local active = v10 and sendState
			local armed = v10 and FreePlayVibrato.IsArmed()
			local bend = v10 and FreePlayVibrato.GetEffectiveBend() or 0

			local now = os.clock()

			v9.Active = active
			v9.Armed = armed
			v9.Rate = rate
			v9.Dir = dir
			v9.Bend = bend
			v9.Depth = depth
			v9.Time = now

			FreePlayReplicationAdapter:ReplicateVibrato(active, rate, dir, bend, armed, depth)
		end)
	end
end)

local function tryRegisterRemote(sound)
	if not sound:IsA("Sound") then
		return
	end

	local freePlayPresserUserId = sound:GetAttribute("FreePlayPresserUserId")

	if freePlayPresserUserId == nil or freePlayPresserUserId == LocalPlayer.UserId then
		return
	end

	FreePlayVibrato.Register(sound, sound.PlaybackSpeed, freePlayPresserUserId)
end

workspace.DescendantAdded:Connect(tryRegisterRemote)

local v10 = {}

local function collectAnchors(player)
	local anchors = {}
	local function add(part) -- 2 equivalent calls inferred from this helper
		if part and part:IsA("BasePart") then
			table.insert(anchors, part)
		end
	end

	if player == LocalPlayer and v2 then
		for _, childName in ipairs({ "SoundAnchor", "SecondarySoundAnchor" }) do
			local objectValue = v2:FindFirstChild(childName)

			if objectValue and objectValue:IsA("ObjectValue") then
				add(objectValue.Value) -- inferred equivalent call
			end
		end
	end

	if #anchors == 0 then
		for _, childName in ipairs({ "FPVibAnchor", "FPVibAnchor2" }) do
			local objectValue = player:FindFirstChild(childName)

			if objectValue and objectValue:IsA("ObjectValue") then
				add(objectValue.Value) -- inferred equivalent call
			end
		end
	end

	if #anchors ~= 0 then
		return anchors
	end

	local character = player.Character
	local v11 = character and character:FindFirstChildOfClass("Humanoid")

	if v11 then
		v11 = v11.SeatPart
	end

	while v11 do
		if CollectionService:HasTag(v11, "InstrumentStand") then
			local soundAnchor = v11:FindFirstChild("SoundAnchor")

			if not (soundAnchor and soundAnchor:IsA("ObjectValue")) then
				break
			end

			local value = soundAnchor.Value

			if value and value:IsA("BasePart") then
				table.insert(anchors, value)

				return anchors
			end

			break
		end

		v11 = v11.Parent
	end

	return anchors
end

local function ensureStemEffects(p)
	local userId

	if p ~= LocalPlayer then
		userId = p.UserId or nil
	end

	for _, v11 in ipairs(collectAnchors(p)) do
		for _, sound in ipairs(v11:GetChildren()) do
			if
				not sound:IsA("Sound")
				or sound:GetAttribute("FreePlayPresserUserId") ~= nil
				or sound:FindFirstChild("VibratoPitchShift")
			then
				continue
			end

			local vibratoPitchShift = Instance.new("PitchShiftSoundEffect")
			vibratoPitchShift.Name = "VibratoPitchShift"
			vibratoPitchShift.Octave = 1
			vibratoPitchShift.Enabled = false
			vibratoPitchShift.Parent = sound
			FreePlayVibrato.RegisterEffect(vibratoPitchShift, userId)
		end
	end
end

local function trackPlayer(instance)
	if instance == LocalPlayer then
		return
	end

	local function onAttr() -- 1 equivalent call inferred from this helper
		v10[instance.UserId] = true
	end
	instance:GetAttributeChangedSignal("FPVibActive"):Connect(onAttr)
	instance:GetAttributeChangedSignal("FPVibArmed"):Connect(onAttr)
	instance:GetAttributeChangedSignal("FPVibBend"):Connect(onAttr)

	if instance:GetAttribute("FPVibActive") ~= nil or instance:GetAttribute("FPVibArmed") ~= nil then
		onAttr() -- inferred equivalent call
	end
end

for _, v11 in ipairs(Players:GetPlayers()) do
	trackPlayer(v11)
end

Players.PlayerAdded:Connect(trackPlayer)
Players.PlayerRemoving:Connect(function(player)
	v10[player.UserId] = nil
end)

local v11 = 0
RunService.Heartbeat:Connect(function()
	local now = os.clock()

	if now - v11 < 0.3 then
		return
	end

	v11 = now

	if ModeManager.IsRhythm() and isEligible() then -- inferred equivalent call
		ensureStemEffects(LocalPlayer)
	end

	for k in pairs(v10) do
		local playerByUserId = Players:GetPlayerByUserId(k)

		if playerByUserId then
			ensureStemEffects(playerByUserId)
		else
			v10[k] = nil
		end
	end
end)