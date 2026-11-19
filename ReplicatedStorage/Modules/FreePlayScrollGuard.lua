local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local SessionCameraSettings = require(script.Parent:WaitForChild("SessionCameraSettings"))

local v = {}
local v2 = false
local v3 = false

local function isShown(guiObject, screenGui): boolean
	while guiObject and guiObject ~= screenGui do
		if guiObject:IsA("GuiObject") and not guiObject.Visible then
			return false
		end

		guiObject = guiObject.Parent
	end

	return guiObject == screenGui
end

local function isHovering(): boolean
	if not UserInputService.MouseEnabled then
		return false
	end

	local mouseLocation = UserInputService:GetMouseLocation()
	local guiInset = GuiService:GetGuiInset()

	for _, v4 in ipairs(v) do
		local screenGui = v4.ScreenGui

		if not (screenGui.Parent and screenGui.Enabled) then
			continue
		end

		local v5 = screenGui.IgnoreGuiInset and mouseLocation or mouseLocation - guiInset
		local success, objects = pcall(v4.GetObjects)

		if not (success and objects) then
			continue
		end

		for _, object in ipairs(objects) do
			if not (object.Parent and isShown(object, screenGui)) then
				continue
			end

			local absolutePosition = object.AbsolutePosition
			local absoluteSize = object.AbsoluteSize

			if
				v5.X >= absolutePosition.X
				and v5.X <= absolutePosition.X + absoluteSize.X
				and v5.Y >= absolutePosition.Y
				and v5.Y <= absolutePosition.Y + absoluteSize.Y
			then
				return true
			end
		end
	end

	return false
end

local function step()
	local hovering = isHovering()

	if hovering ~= v2 then
		v2 = hovering
		SessionCameraSettings.SetScrollBlocked(hovering)
	end
end

return {
	Attach = function(screenGui, getObjects)
		table.insert(v, { ScreenGui = screenGui, GetObjects = getObjects })

		if not v3 then
			v3 = true

			RunService:BindToRenderStep("FreePlayScrollGuard", Enum.RenderPriority.First.Value - 1, step)
		end
	end
}