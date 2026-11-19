local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ResultsTipsTelemetry = {}

if not RunService:IsClient() then
	return ResultsTipsTelemetry
end

local LocalPlayer = Players.LocalPlayer

local success, result = pcall(function()
	return require(ReplicatedStorage.Modules.SettingsState)
end)

if not success then
	result = nil
end

local flag = false
local v = 0
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil

local now = nil
local v6 = nil
local v7 = nil
local total = 0

local function freshData() -- 1 equivalent call inferred from this helper
	return {
		TypingSeconds = 0,
		ChatMessages = 0,
		MoveSeconds = 0,
		MoveDistance = 0,
		Jumps = 0,
		VibratoPresses = 0,
		VibratoHeldSeconds = 0,
		LongestIdle = 0,
		InputCount = 0,
		Duration = 0
	}
end

local function counting() -- 4 equivalent calls inferred from this helper
	local v8 = flag

	if not v8 then
		return v8
	end

	if v3 == nil then
		return false
	else
		local now2 = os.clock()
		return v <= now2
	end
end

local function closeOpenIntervals(now2) -- 1 equivalent call inferred from this helper
	if now then
		v3.TypingSeconds += math.max(0, now2 - math.max(now, v))
		now = nil
	end

	if v6 then
		v3.VibratoHeldSeconds += math.max(0, now2 - math.max(v6, v))
		v6 = nil
	end
end

local function startSession(p, p2) -- 1 equivalent call inferred from this helper
	flag = true
	v2 = p
	v3 = freshData() -- inferred equivalent call
	now = nil
	v6 = nil
	v7 = nil
	total = 0
	v = os.clock() + math.max(0, tonumber(p2) or 0)
end

local function stopSession() -- 2 equivalent calls inferred from this helper
	if not (flag and v3) then
		flag = false
		return
	end

	local now2 = os.clock()
	closeOpenIntervals(now2) -- inferred equivalent call
	v3.Duration = math.max(0, now2 - v)

	v4 = v3
	v3 = nil
	flag = false
end

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

task.spawn(function()
	local songSessionStatusUpdate = RemoteEvents:WaitForChild("SongSessionStatusUpdate", 30)

	if not songSessionStatusUpdate then
		return
	end

	songSessionStatusUpdate.OnClientEvent:Connect(function(p, p2, p3)
		if p then
			if not flag or p2 ~= nil and p2 ~= v2 then
				if flag then
					stopSession() -- inferred equivalent call
				end

				startSession(p2, p3) -- inferred equivalent call
			end
		else
			stopSession() -- inferred equivalent call
		end
	end)
end)

task.spawn(function()
	local resultsTipsContext = RemoteEvents:WaitForChild("ResultsTipsContext", 30)

	if not resultsTipsContext then
		return
	end

	resultsTipsContext.OnClientEvent:Connect(function(p)
		if typeof(p) == "table" then
			v5 = {
				Humans = tonumber(p.Humans) or 1,
				Autos = tonumber(p.Autos) or 0
			}
		end
	end)
end)

local function isRealInput(input): boolean -- 1 equivalent call inferred from this helper
	local userInputType = input.UserInputType
	return userInputType == Enum.UserInputType.Keyboard
		or userInputType == Enum.UserInputType.MouseButton1
		or userInputType == Enum.UserInputType.MouseButton2
		or userInputType == Enum.UserInputType.Touch
		or userInputType == Enum.UserInputType.Gamepad1
end

local function matchesVibrato(input) -- 2 equivalent calls inferred from this helper
	if not result or typeof(result.MatchesVibratoInput) ~= "function" then
		return false
	end

	local success2, result2 = pcall(result.MatchesVibratoInput, input)
	return success2 and result2 == true
end

UserInputService.InputBegan:Connect(function(input)
	if counting() and isRealInput(input) then -- inferred equivalent call
		local now2 = os.clock()
		v3.InputCount += 1

		if v7 then
			v3.LongestIdle = math.max(v3.LongestIdle, now2 - v7)
		end

		v7 = now2

		if matchesVibrato(input) then -- inferred equivalent call
			v3.VibratoPresses += 1
			v6 = v6 or now2
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if not v3 then
		return
	end

	if v6 and matchesVibrato(input) then -- inferred equivalent call
		v3.VibratoHeldSeconds += math.max(0, os.clock() - math.max(v6, v))
		v6 = nil
	end
end)

UserInputService.TextBoxFocused:Connect(function()
	if counting() then -- inferred equivalent call
		now = os.clock()
	end
end)

UserInputService.TextBoxFocusReleased:Connect(function()
	if v3 and now then
		v3.TypingSeconds += math.max(0, os.clock() - math.max(now, v))
		now = nil
	end
end)

task.spawn(function()
	pcall(function()
		local TextChatService = game:GetService("TextChatService")
		TextChatService.MessageReceived:Connect(function(p)
			local textSource = p.TextSource
			local v8 = flag

			if v8 then
				if v3 == nil then
					v8 = false
				else
					local now2 = os.clock()
					v8 = v <= now2
				end
			end

			if v8 and textSource and textSource.UserId == LocalPlayer.UserId then
				v3.ChatMessages += 1
			end
		end)
	end)
end)

local v8 = nil
local v9 = nil

local function hookHumanoid(humanoid) -- 1 equivalent call inferred from this helper
	if v9 == humanoid then
		return
	end

	v9 = humanoid
	humanoid.StateChanged:Connect(function(_, p)
		if p == Enum.HumanoidStateType.Jumping and counting() then -- inferred equivalent call
			v3.Jumps += 1
		end
	end)
end

RunService.Heartbeat:Connect(function(dt)
	if not counting() then -- inferred equivalent call
		v8 = nil
		return
	end

	total += dt

	if total < 0.25 then
		return
	end

	local v10 = total
	total = 0

	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (humanoid and humanoidRootPart) then
		v8 = nil
		return
	end

	hookHumanoid(humanoid) -- inferred equivalent call
	local vector3 = Vector3.new(humanoidRootPart.Position.X, 0, humanoidRootPart.Position.Z)

	if v8 then
		local magnitude = (vector3 - v8).Magnitude

		if magnitude > 0.4 and magnitude < 30 then
			v3.MoveDistance += magnitude
			v3.MoveSeconds += v10
		end
	end

	v8 = vector3
end)

function ResultsTipsTelemetry.GetLast()
	if v4 then
		return table.clone(v4)
	end

	return nil
end

function ResultsTipsTelemetry.GetContext()
	if v5 then
		return table.clone(v5)
	end

	return nil
end

return ResultsTipsTelemetry