local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LaptopClientController = require(ReplicatedStorage.Modules.LaptopUI.LaptopClientController)
local LaptopSongListController = require(ReplicatedStorage.Modules.LaptopUI.LaptopSongListController)
local LaptopStageLightPanel = require(ReplicatedStorage.Modules.LaptopUI.LaptopStageLightPanel)

local function getStudioId(instance)
	while instance do
		local studioId = instance:GetAttribute("StudioId")

		if studioId then
			return studioId
		end

		instance = instance.Parent
	end

	return nil
end

local function waitForChildPatient(instance, childName)
	local v = instance:FindFirstChild(childName)

	while not v do
		if not instance:IsDescendantOf(game) then
			return nil
		end

		v = instance:WaitForChild(childName, 15)
	end

	return v
end

local v = {}

local function registerLaptop(instance)
	if v[instance] then
		return
	end

	v[instance] = true
	instance.AncestryChanged:Connect(function(_, parent)
		if not parent then
			v[instance] = nil
		end
	end)

	task.spawn(function()
		local v2 = instance
		local studioId

		while true do
			if not v2 then
				studioId = nil
				break
			end

			studioId = v2:GetAttribute("StudioId")

			if studioId then
				break
			end

			v2 = v2.Parent
		end

		if not studioId then
			return
		end

		local part = waitForChildPatient(instance, "Screen")

		if not (part and part:IsA("BasePart")) then
			return
		end

		local program = part:FindFirstChild("Program")
		local face = program and program:IsA("Decal") and program.Face or Enum.NormalId.Front

		LaptopClientController.RegisterLaptop(studioId, part, face)
		LaptopSongListController.RegisterLaptop(studioId, part)
		LaptopStageLightPanel.RegisterLaptop(studioId, part)
	end)
end

for _, v2 in ipairs(CollectionService:GetTagged("Laptop")) do
	registerLaptop(v2)
end

CollectionService:GetInstanceAddedSignal("Laptop"):Connect(registerLaptop)

LaptopClientController.Start()
LaptopSongListController.Start()
LaptopStageLightPanel.Start()