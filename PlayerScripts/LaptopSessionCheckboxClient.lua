local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local LaptopToggleAutoInstrumentMute = RemoteEvents:WaitForChild("LaptopToggleAutoInstrumentMute")
local LaptopAdjustAutoInstrumentVolume = RemoteEvents:WaitForChild("LaptopAdjustAutoInstrumentVolume")

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

local function hookRow(frame, studioId)
	local muteCheckboxHolder = frame:WaitForChild("MuteCheckboxHolder")
	local muteCheckbox = muteCheckboxHolder:WaitForChild("MuteCheckbox")
	local checkIcon = muteCheckbox:WaitForChild("CheckIcon")

	local instrumentType = frame:GetAttribute("InstrumentType")

	if typeof(instrumentType) ~= "string" then
		return
	end

	muteCheckbox.MouseButton1Click:Connect(function()
		local visible = checkIcon.Visible == true
		LaptopToggleAutoInstrumentMute:FireServer(studioId, instrumentType, visible)
	end)

	local volumeControls = muteCheckboxHolder:WaitForChild("VolumeControls", 10)

	if volumeControls then
		local volumeMinus = volumeControls:WaitForChild("VolumeMinus", 10)
		local volumePlus = volumeControls:WaitForChild("VolumePlus", 10)

		if volumeMinus then
			volumeMinus.MouseButton1Click:Connect(function()
				LaptopAdjustAutoInstrumentVolume:FireServer(studioId, instrumentType, -1)
			end)
		end

		if volumePlus then
			volumePlus.MouseButton1Click:Connect(function()
				LaptopAdjustAutoInstrumentVolume:FireServer(studioId, instrumentType, 1)
			end)
		end
	end
end

local function waitForChildPatient(instance, childName)
	while true do
		local child = instance:WaitForChild(childName, 10)

		if child then
			return child
		end

		if not instance:IsDescendantOf(game) then
			return nil
		end
	end
end

local function hookLaptop(p)
	local v = p
	local studioId

	while true do
		if not v then
			studioId = nil
			break
		end

		studioId = v:GetAttribute("StudioId")

		if studioId then
			break
		end

		v = v.Parent
	end

	if not studioId then
		return
	end

	local v2 = waitForChildPatient(p, "Screen")
	local v3 = v2 and waitForChildPatient(v2, "GuiAnchor")
	local v4 = v3 and waitForChildPatient(v3, "LaptopScreen")
	local v5 = v4 and waitForChildPatient(v4, "Background")
	local v6 = v5 and waitForChildPatient(v5, "SessionPanel")
	local v7 = v6 and waitForChildPatient(v6, "ContentColumn")
	local v8 = v7 and waitForChildPatient(v7, "InstrumentScroll")

	if not v8 then
		return
	end

	for _, frame in ipairs(v8:GetChildren()) do
		if frame:IsA("Frame") and frame.Name == "InstrumentRow" then
			hookRow(frame, studioId)
		end
	end

	v8.ChildAdded:Connect(function(frame)
		if frame:IsA("Frame") and frame.Name == "InstrumentRow" then
			hookRow(frame, studioId)
		end
	end)
end

for _, v in ipairs(CollectionService:GetTagged("Laptop")) do
	task.spawn(hookLaptop, v)
end

CollectionService:GetInstanceAddedSignal("Laptop"):Connect(hookLaptop)