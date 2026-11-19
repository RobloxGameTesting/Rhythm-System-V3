local v = {
	{ Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D },
	{ Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Left, Enum.KeyCode.Right }
}

local v2 = {
	Enum.KeyCode.G,
	Enum.KeyCode.T,
	Enum.KeyCode.U,
	Enum.KeyCode.R,
	Enum.KeyCode.E,
	Enum.KeyCode.Backspace,
	Enum.KeyCode.Backquote
}

local v3 = { Enum.KeyCode.Space }

local v4 = true
local v5 = false

local v6 = {}
local v7 = {}

local function fireChanged()
	for _, callback in ipairs(v6) do
		local success, result = pcall(callback, v5, v4)

		if not success then
			warn("[MovementLockState] listener error:", result)
		end
	end
end

local MovementLockState = {}

function MovementLockState.IsEnabled()
	return v4
end

function MovementLockState.IsApplicable()
	return v5
end

function MovementLockState.OnChanged(p)
	table.insert(v6, p)
end

function MovementLockState.OnEnabledChanged(p)
	table.insert(v7, p)
end

function MovementLockState.SetEnabled(p)
	local v8 = p and true or false

	if v8 == v4 then
		return
	end

	v4 = v8
	fireChanged()

	for _, callback in ipairs(v7) do
		local success, result = pcall(callback)

		if not success then
			warn("[MovementLockState] enabled listener error:", result)
		end
	end
end

function MovementLockState.Resolve(list)
	local set = {}

	if list then
		for _, item in ipairs(list) do
			set[item] = true
		end
	end

	local set2 = {}
	local v8 = false

	for _, list2 in ipairs(v) do
		local flag = false

		for _, item in ipairs(list2) do
			if set[item] then
				flag = true
				break
			end
		end

		if not flag then
			continue
		end

		v8 = true

		for _, item in ipairs(list2) do
			set2[item] = true
		end
	end

	for _, v9 in ipairs(v2) do
		if not set[v9] then
			continue
		end

		set2[v9] = true
		v8 = true
	end

	if list == nil then
		v8 = false
	end

	if v8 ~= v5 then
		v5 = v8

		if v5 then
			v4 = true
		end

		fireChanged()
	end

	local result = {}

	if v5 and v4 then
		for k in pairs(set2) do
			table.insert(result, k)
		end
	end

	if list == nil then
		return result
	end

	for _, v9 in ipairs(v3) do
		if not set[v9] or set2[v9] then
			continue
		end

		table.insert(result, v9)
	end

	return result
end

return MovementLockState