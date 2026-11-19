local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local success, result = pcall(function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	return require(ReplicatedStorage:WaitForChild("Modules", 10):WaitForChild("ModeManager", 10))
end)

if not success then
	result = nil
end

local v = nil
task.spawn(function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
	local songSessionStatusUpdate = remoteEvents and remoteEvents:WaitForChild("SongSessionStatusUpdate", 10)

	if not songSessionStatusUpdate then
		return
	end

	songSessionStatusUpdate.OnClientEvent:Connect(function(p, _, p2)
		if p then
			v = os.clock() + (tonumber(p2) or 0)
		else
			v = nil
		end
	end)
end)

local function makeEmitter(name, breathAttachment, p, p2, p3)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = name
	particleEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particleEmitter.Rate = 0
	particleEmitter.Lifetime = NumberRange.new(1.8, 2.6)
	particleEmitter.Speed = NumberRange.new(0.6, 1)
	particleEmitter.EmissionDirection = Enum.NormalId.Front
	particleEmitter.SpreadAngle = Vector2.new(10, 10)
	particleEmitter.Acceleration = Vector3.new(0, 0.5, 0)
	particleEmitter.Drag = 3
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.RotSpeed = NumberRange.new(-25, 25)
	particleEmitter.LightEmission = 0.1
	particleEmitter.LightInfluence = 0.5
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15 * p3),
		NumberSequenceKeypoint.new(1, 0.85 * p3)
	})

	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, p),
		NumberSequenceKeypoint.new(0.4, p2),
		NumberSequenceKeypoint.new(1, 1)
	})

	particleEmitter.Color = ColorSequence.new(Color3.fromRGB(235, 245, 255))
	particleEmitter.Parent = breathAttachment
	return particleEmitter
end

local function setupBreath(instance)
	local head = instance:WaitForChild("Head", 5)
	local humanoid = instance:WaitForChild("Humanoid", 5)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 5)

	if not (head and humanoid and humanoidRootPart) or head:FindFirstChild("BreathAttachment") then
		return
	end

	local breathAttachment = Instance.new("Attachment")
	breathAttachment.Name = "BreathAttachment"
	breathAttachment.CFrame = CFrame.new(0, -head.Size.Y * 0.2, -head.Size.Z * 0.5)
	breathAttachment.Parent = head

	local emitter = makeEmitter("BreathEmitter", breathAttachment, 0.82, 0.9, 0.9)
	local emitter2 = makeEmitter("BreathEmitterFP", breathAttachment, 0.95, 0.98, 0.45)

	local emitter3 = makeEmitter("BreathEmitterPlay", breathAttachment, 0.62, 0.78, 1.1)
	local emitter4 = makeEmitter("BreathEmitterPlayFP", breathAttachment, 0.9, 0.96, 0.55)

	Players:GetPlayerFromCharacter(instance)

	local v2 = Players:GetPlayerFromCharacter(instance) == LocalPlayer

	task.spawn(function()
		while instance.Parent and humanoid.Health > 0 do
			local v3

			if humanoid.MoveDirection.Magnitude < 0.1 and humanoidRootPart.AssemblyLinearVelocity.Magnitude < 1.5 then
				v3 = humanoid.FloorMaterial ~= Enum.Material.Air
			else
				v3 = false
			end

			if v3 then
				local v4 = v2

				if v4 then
					if v == nil then
						v4 = false
					else
						local now = os.clock()

						if v <= now then
							v4 = result == nil or result.IsRhythm()
						else
							v4 = false
						end
					end
				end

				local v5

				if v2 then
					local currentCamera = Workspace.CurrentCamera

					if currentCamera == nil then
						v5 = false
					else
						v5 = (currentCamera.CFrame.Position - head.Position).Magnitude < 1
					end
				else
					v5 = false
				end

				local v6

				if v4 then
					v6 = v5 and emitter4 or emitter3
				else
					v6 = v5 and emitter2 or emitter
				end

				for _ = 1, 3 do
					v6:Emit(1)
					task.wait(0.18)
				end

				task.wait(4.5)
			else
				task.wait(0.25)
			end
		end
	end)
end

local function onPlayer(player) -- 1 equivalent call inferred from this helper
	player.CharacterAdded:Connect(setupBreath)

	if player.Character then
		task.spawn(setupBreath, player.Character)
	end
end

for _, v2 in ipairs(Players:GetPlayers()) do
	onPlayer(v2) -- inferred equivalent call
end

Players.PlayerAdded:Connect(onPlayer)