local v = {}
local v2 = false

local function isActive(gui) -- 2 equivalent calls inferred from this helper
	if gui.Parent and gui.Visible then
		local screenGui = gui:FindFirstAncestorWhichIsA("ScreenGui")
		return screenGui == nil or screenGui.Enabled
	end

	return false
end

local function relayout()
	v2 = false
	table.sort(v, function(a, b): boolean
		return a.order < b.order
	end)
	local total = 16

	for _, v3 in ipairs(v) do
		local gui = v3.gui

		if not gui.Parent or not isActive(gui) or gui:GetAttribute("StackExempt") then -- inferred equivalent call
			continue
		end

		gui.AnchorPoint = Vector2.new(0, 1)
		gui.Position = UDim2.new(0, v3.x, 1, -total)
		total += gui.AbsoluteSize.Y + 6
	end
end

local function schedule() -- 2 equivalent calls inferred from this helper
	if not v2 then
		v2 = true
		task.defer(relayout)
	end
end

local BottomLeftStack = {}

function BottomLeftStack.GetTopAbsY()
	local topAbsY = nil

	for _, v3 in ipairs(v) do
		local gui = v3.gui

		if not gui.Parent or not isActive(gui) or gui:GetAttribute("StackExempt") or not (gui.AbsoluteSize.Y > 0) then -- inferred equivalent call
			continue
		end

		local y = gui.AbsolutePosition.Y

		if topAbsY == nil or y < topAbsY then
			topAbsY = y
		end
	end

	return topAbsY
end

function BottomLeftStack.Register(instance, order)
	local v3 = { gui = instance, order = order, x = instance.Position.X.Offset, enabledConn = nil }
	table.insert(v, v3)

	local function hookScreenGui() -- 2 equivalent calls inferred from this helper
		if v3.enabledConn then
			v3.enabledConn:Disconnect()
			v3.enabledConn = nil
		end

		local screenGui = instance:FindFirstAncestorWhichIsA("ScreenGui")

		if screenGui then
			v3.enabledConn = screenGui:GetPropertyChangedSignal("Enabled"):Connect(schedule)
		end
	end

	instance:GetPropertyChangedSignal("Visible"):Connect(schedule)
	instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(schedule)
	instance.AncestryChanged:Connect(function()
		hookScreenGui() -- inferred equivalent call
		schedule() -- inferred equivalent call
	end)
	hookScreenGui() -- inferred equivalent call
	schedule() -- inferred equivalent call
end

return BottomLeftStack