local v = {}
local v2 = {}
local v3 = {}

local function fire()
	for _, callback in ipairs(v3) do
		local success, result = pcall(callback)

		if not success then
			warn("[BandCameraFocus] listener error:", result)
		end
	end
end

local BandCameraFocus = {}

function BandCameraFocus.OnChanged(p)
	table.insert(v3, p)
end

function BandCameraFocus.IsFocused(p): boolean
	return v[p] == true
end

function BandCameraFocus.Toggle(p, p2): boolean
	if p == nil then
		return false
	end

	if p2 ~= nil and v2[p] == nil then
		v2[p] = p2
	end

	if v[p] then
		v[p] = nil
	else
		v[p] = true
	end

	fire()
	return v[p] == true
end

function BandCameraFocus.SetPresent(items)
	local flag = false

	for k in pairs(v) do
		if items[k] ~= nil then
			continue
		end

		v[k] = nil
		flag = true
	end

	for k, item in pairs(items) do
		if v[k] and v2[k] ~= item then
			flag = true
		end
	end

	v2 = items

	if flag then
		fire()
	end
end

function BandCameraFocus.GetInstruments()
	local set = {}
	local instruments = {}

	for k in pairs(v) do
		local v4 = v2[k]

		if not v4 or set[v4] then
			continue
		end

		set[v4] = true
		instruments[#instruments + 1] = v4
	end

	table.sort(instruments)
	return instruments
end

function BandCameraFocus.Count()
	local count = 0

	for _ in pairs(v) do
		count += 1
	end

	return count
end

function BandCameraFocus.Reset()
	if next(v) ~= nil then
		v = {}
		fire()
	end
end

return BandCameraFocus