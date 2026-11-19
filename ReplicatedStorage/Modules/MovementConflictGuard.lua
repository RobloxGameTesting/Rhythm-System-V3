local ContextActionService = game:GetService("ContextActionService")

local MovementConflictGuard = {}

local set = {
	[Enum.KeyCode.W] = true,
	[Enum.KeyCode.A] = true,
	[Enum.KeyCode.S] = true,
	[Enum.KeyCode.D] = true,
	[Enum.KeyCode.Up] = true,
	[Enum.KeyCode.Down] = true,
	[Enum.KeyCode.Left] = true,
	[Enum.KeyCode.Right] = true,
	[Enum.KeyCode.Space] = true,
	[Enum.KeyCode.G] = true,
	[Enum.KeyCode.T] = true,
	[Enum.KeyCode.U] = true,
	[Enum.KeyCode.R] = true,
	[Enum.KeyCode.E] = true,
	[Enum.KeyCode.Backspace] = true,
	[Enum.KeyCode.Backquote] = true,
	[Enum.KeyCode.ButtonA] = true,
	[Enum.KeyCode.ButtonB] = true,
	[Enum.KeyCode.ButtonX] = true,
	[Enum.KeyCode.ButtonY] = true,
	[Enum.KeyCode.ButtonL1] = true,
	[Enum.KeyCode.ButtonR1] = true,
	[Enum.KeyCode.ButtonL2] = true,
	[Enum.KeyCode.ButtonR2] = true,
	[Enum.KeyCode.ButtonL3] = true,
	[Enum.KeyCode.ButtonR3] = true,
	[Enum.KeyCode.DPadUp] = true,
	[Enum.KeyCode.DPadDown] = true,
	[Enum.KeyCode.DPadLeft] = true,
	[Enum.KeyCode.DPadRight] = true
}

local v = {}

local function actionNameFor(k) -- 1 equivalent call inferred from this helper
	return "JammbloxMovementLock_" .. k.Name
end

local function sinkHandler()
	return Enum.ContextActionResult.Sink
end

function MovementConflictGuard.SetLockedKeys(list)
	local set2 = {}

	for _, item in ipairs(list) do
		if item and set[item] then
			set2[item] = true
		end
	end

	for k, v2 in pairs(v) do
		if set2[k] then
			continue
		end

		ContextActionService:UnbindAction(v2)
		v[k] = nil
	end

	for k in pairs(set2) do
		if v[k] then
			continue
		end

		local v2 = actionNameFor(k) -- inferred equivalent call
		ContextActionService:BindActionAtPriority(v2, sinkHandler, false, Enum.ContextActionPriority.High.Value + 1, k)

		v[k] = v2
	end
end

function MovementConflictGuard.UnlockAll()
	MovementConflictGuard.SetLockedKeys({})
end

function MovementConflictGuard.IsLocked(p): boolean
	return v[p] ~= nil
end

return MovementConflictGuard