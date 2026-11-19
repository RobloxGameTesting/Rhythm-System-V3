local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local InputRouter = require(Modules:WaitForChild("InputRouter"))
local ModeManager = require(Modules:WaitForChild("ModeManager"))
local FreePlayController = require(Modules:WaitForChild("FreePlayController"))

local LocalPlayer = Players.LocalPlayer

local v = {}

local function getPianoModel(p)
	local displayModel = p.Parent and p.Parent:FindFirstChild("DisplayModel")

	if not displayModel then
		return nil
	end

	for _, model in ipairs(displayModel:GetChildren()) do
		if model:IsA("Model") and model:FindFirstChild("Keys") then
			return model
		end
	end

	return nil
end

local function getData(instance)
	local v2 = v[instance]

	if v2 then
		return v2
	end

	local v3 = { Keys = {}, Count = {} }
	local keys = instance:FindFirstChild("Keys")

	if keys then
		for i = 1, 61 do
			local v4 = math.floor((i - 1) / 12) + 1

			local child = keys:FindFirstChild((tostring(v4)))
			local child2 = child and child:FindFirstChild((tostring((i - 1) % 12 + 1)))
			local mesh = child2 and child2:FindFirstChild("Mesh")

			if mesh and mesh:IsA("DataModelMesh") then
				v3.Keys[i] = { Mesh = mesh, Base = mesh.Offset }
			end
		end
	end

	v[instance] = v3
	return v3
end

local function setKeyDown(p, p2, p3) -- 4 equivalent calls inferred from this helper
	local data = getData(p)
	local key = data.Keys[p2]

	if not key then
		return
	end

	local v2 = (data.Count[p2] or 0) + (p3 and 1 or -1)
	data.Count[p2] = math.max(0, v2)
	key.Mesh.Offset = data.Count[p2] > 0 and key.Base + Vector3.new(0, -0.05, 0) or key.Base
end

local function getSeatedStand()
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local v2 = humanoid and humanoid.SeatPart

	while v2 do
		if CollectionService:HasTag(v2, "InstrumentStand") then
			return v2
		end

		v2 = v2.Parent
	end

	return nil
end

local v2 = {}

local function releaseLocal(p) -- 2 equivalent calls inferred from this helper
	local v3 = v2[p]

	if v3 then
		v2[p] = nil
		setKeyDown(v3, p, false) -- inferred equivalent call
	end
end

InputRouter.OnLaneEvent(function(p, p2)
	if p2 then
		if FreePlayController.GetCurrentInstrumentType() ~= "Piano" or not ModeManager.IsFreePlay() or v2[p] then
			return
		end

		local seatedStand = getSeatedStand()
		local v3 = seatedStand and getPianoModel(seatedStand)

		if not v3 then
			return
		end

		v2[p] = v3
		setKeyDown(v3, p, true) -- inferred equivalent call
	else
		releaseLocal(p) -- inferred equivalent call
	end
end)

task.spawn(function()
	while true do
		task.wait(0.5)

		if not (next(v2) ~= nil and (FreePlayController.GetCurrentInstrumentType() ~= "Piano" or not ModeManager.IsFreePlay())) then
			continue
		end

		for k in pairs(table.clone(v2)) do
			releaseLocal(k) -- inferred equivalent call
		end
	end
end)

local function handleReplicatedSound(pianoModel, sound)
	if not sound:IsA("Sound") then
		return
	end

	local freePlayPresserUserId = sound:GetAttribute("FreePlayPresserUserId")
	local fpLane = sound:GetAttribute("FPLane")

	if type(fpLane) ~= "number" or freePlayPresserUserId == LocalPlayer.UserId then
		return
	end

	setKeyDown(pianoModel, fpLane, true) -- inferred equivalent call
	local flag = false
	local function keyUp() -- 2 equivalent calls inferred from this helper
		if flag then
			return
		end

		flag = true
		setKeyDown(pianoModel, fpLane, false) -- inferred equivalent call
	end

	if sound:GetAttribute("FPKeyUp") then
		keyUp() -- inferred equivalent call
	else
		sound:GetAttributeChangedSignal("FPKeyUp"):Connect(function()
			if sound:GetAttribute("FPKeyUp") then
				keyUp() -- inferred equivalent call
			end
		end)
		sound.Destroying:Once(keyUp)
		task.delay(12, keyUp)
	end
end

local v3 = {}

local function watchStand(instance)
	if v3[instance] or instance:GetAttribute("InstrumentType") ~= "Piano" then
		return
	end

	v3[instance] = true
	task.spawn(function()
		local soundAnchor = instance:WaitForChild("SoundAnchor", 15)
		local value = soundAnchor and soundAnchor.Value
		local pianoModel = getPianoModel(instance)

		if not (value and pianoModel) then
			v3[instance] = nil
			return
		end

		value.ChildAdded:Connect(function(child)
			handleReplicatedSound(pianoModel, child)
		end)

		for _, child in ipairs(value:GetChildren()) do
			handleReplicatedSound(pianoModel, child)
		end
	end)
end

CollectionService:GetInstanceAddedSignal("InstrumentStand"):Connect(watchStand)

for _, v4 in ipairs(CollectionService:GetTagged("InstrumentStand")) do
	if v3[v4] or v4:GetAttribute("InstrumentType") ~= "Piano" then
		continue
	end

	v3[v4] = true
	task.spawn(function()
		local soundAnchor = v4:WaitForChild("SoundAnchor", 15)
		local value = soundAnchor and soundAnchor.Value
		local pianoModel = getPianoModel(v4)

		if not (value and pianoModel) then
			v3[v4] = nil
			return
		end

		value.ChildAdded:Connect(function(child)
			handleReplicatedSound(pianoModel, child)
		end)

		for _, child in ipairs(value:GetChildren()) do
			handleReplicatedSound(pianoModel, child)
		end
	end)
end