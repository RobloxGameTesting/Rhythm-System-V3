local DataStoreService = game:GetService("DataStoreService")

local dataStore = DataStoreService:GetDataStore("AudioRigStore")

local function getKey(p) -- 2 equivalent calls inferred from this helper
	return "AudioRig_" .. tostring(p)
end

local function isValidRigPayload(p, data): boolean
	if type(data) ~= "table" then
		return false
	end

	return data.OwnerUserId == p and type(data.Instrument) == "string" and type(data.Version) == "number"
end

local AudioRigStoreServer = {}

function AudioRigStoreServer.Save(p, data)
	local v

	if type(data) == "table" and data.OwnerUserId == p and type(data.Instrument) == "string" then
		v = type(data.Version) == "number"
	else
		v = false
	end

	if not v then
		warn("[AudioRigStoreServer] Save ditolak - payload tidak valid untuk userId", p)
		return false
	end

	local success, result = pcall(function()
		dataStore:SetAsync(getKey(p), data) -- inferred equivalent call
	end)

	if not success then
		warn("[AudioRigStoreServer] Gagal SetAsync untuk userId", p, "-", result)
	end

	return success
end

function AudioRigStoreServer.Load(p)
	local success, result = pcall(function()
		return dataStore:GetAsync(getKey(p)) -- inferred equivalent call
	end)

	if success then
		return result
	end

	warn("[AudioRigStoreServer] Gagal GetAsync untuk userId", p, "-", result)
	return nil
end

return AudioRigStoreServer