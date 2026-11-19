local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PedalNodeTypeRegistry = require(ReplicatedStorage.Modules.PedalNodeTypeRegistry)

local PedalboardRegistry = {}

local v = {}
local function deepFreeze(list)
	if type(list) ~= "table" then
		return list
	end

	for _, item in pairs(list) do
		deepFreeze(item)
	end

	table.freeze(list)
	return list
end

local function computeChainOrder(list, p)
	if #list == 0 then
		return {}
	end

	local v2 = {}

	for _, item in ipairs(list) do
		if not item.Id or item.Id == "" then
			return nil, string.format("%s: ada node tanpa Id", p)
		end

		if v2[item.Id] then
			return nil, string.format("%s: Id duplikat '%s'", p, item.Id)
		end

		if not PedalNodeTypeRegistry.Get(item.Id) then
			return nil, string.format("%s: Id '%s' belum terdaftar di PedalNodeTypeRegistry", p, item.Id)
		end

		v2[item.Id] = item
	end

	local idsByInputFrom = {}
	local v3 = nil

	for _, item in ipairs(list) do
		if item.InputFrom == nil then
			if v3 then
				return nil, string.format("%s: lebih dari satu head (InputFrom=nil): '%s' dan '%s'", p, v3, item.Id)
			end

			v3 = item.Id
		else
			if not v2[item.InputFrom] then
				return
					nil,
					string.format("%s: node '%s' InputFrom mengarah ke '%s' yang tidak ada", p, item.Id, item.InputFrom)
			end

			if idsByInputFrom[item.InputFrom] then
				return
					nil,
					string.format(
						"%s: node '%s' dipakai sebagai InputFrom oleh lebih dari satu node ('%s' dan '%s') - percabangan tidak didukung",
						p,
						item.InputFrom,
						idsByInputFrom[item.InputFrom],
						item.Id
					)
			end

			idsByInputFrom[item.InputFrom] = item.Id
		end
	end

	if not v3 then
		return nil, string.format("%s: tidak ada node dengan InputFrom=nil (head)", p)
	end

	local v4 = { [v3] = true }
	local result = { v3 }

	while idsByInputFrom[v3] do
		v3 = idsByInputFrom[v3]

		if v4[v3] then
			return nil, string.format("%s: cycle terdeteksi melibatkan '%s'", p, v3)
		end

		v4[v3] = true
		table.insert(result, v3)
	end

	if #result == #list then
		return result
	end

	return
		nil,
		string.format(
			"%s: ada node yang tidak tersambung ke chain utama (orphan) - %d node di definition, %d node tersambung",
			p,
			#list,
			#result
		)
end

function PedalboardRegistry.Register(data)
	if not data.Family or data.Family == "" then
		error("[PedalboardRegistry] Register ditolak: Family kosong")
	end

	if v[data.Family] then
		error(string.format("[PedalboardRegistry] Register ditolak: Family '%s' sudah terdaftar", data.Family))
	end

	local preAmpNodes = data.PreAmpNodes or {}
	local postAmpNodes = data.PostAmpNodes or {}

	local preAmpOrder, v2 = computeChainOrder(preAmpNodes, "PreAmpNodes")

	if not preAmpOrder then
		error(string.format("[PedalboardRegistry] Register '%s' ditolak: %s", data.Family, v2))
	end

	local postAmpOrder, v3 = computeChainOrder(postAmpNodes, "PostAmpNodes")

	if not postAmpOrder then
		error(string.format("[PedalboardRegistry] Register '%s' ditolak: %s", data.Family, v3))
	end

	local set = {}

	for _, v4 in ipairs(preAmpOrder) do
		set[v4] = true
	end

	for _, v4 in ipairs(postAmpOrder) do
		if set[v4] then
			error(string.format(
				"[PedalboardRegistry] Register '%s' ditolak: Id '%s' muncul di PreAmpNodes DAN PostAmpNodes",
				data.Family,
				v4
			))
		end
	end

	local v4 = {
		Family = data.Family,
		PreAmpNodes = preAmpNodes,
		PostAmpNodes = postAmpNodes,
		PreAmpOrder = preAmpOrder,
		PostAmpOrder = postAmpOrder
	}

	v[data.Family] = deepFreeze(v4)
end

function PedalboardRegistry.Get(p)
	return v[p]
end

function PedalboardRegistry.Has(p): boolean
	return v[p] ~= nil
end

function PedalboardRegistry.GetAll()
	local all = {}

	for k, v2 in pairs(v) do
		all[k] = v2
	end

	return all
end

return PedalboardRegistry