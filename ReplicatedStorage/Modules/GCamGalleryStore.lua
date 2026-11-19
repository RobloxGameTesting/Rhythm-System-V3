local GCamConfig = require(script.Parent.GCamConfig)

local GCamGalleryStore = {}

local all = {}
local permanent = {}
local v = true
local id2 = 1
local v2 = {}

local function notify(p, p2)
	for _, callback in ipairs(v2) do
		local success, result = pcall(callback, p, p2)

		if not success then
			warn("[GCamGalleryStore] listener error:", result)
		end
	end
end

function GCamGalleryStore.OnChanged(p)
	table.insert(v2, p)
end

function GCamGalleryStore.GetAll()
	return all
end

function GCamGalleryStore.Count()
	return #all
end

function GCamGalleryStore.GetById(p)
	for _, v3 in ipairs(all) do
		if v3.id == p then
			return v3
		end
	end

	for i = 1, GCamConfig.PERMANENT_SLOTS do
		if permanent[i] and permanent[i].id == p then
			return permanent[i]
		end
	end

	return nil
end

function GCamGalleryStore.NewId()
	local id = id2
	id2 += 1
	return id
end

function GCamGalleryStore.GetPermanent()
	return permanent
end

function GCamGalleryStore.IsPermanentAvailable()
	return v
end

function GCamGalleryStore.SetPermanentAvailable(p)
	v = p == true
	notify("permanent", nil)
end

function GCamGalleryStore.SetPermanent(slot, p)
	permanent[slot] = p

	if p then
		p.slot = slot
	end

	notify("permanent", p)
end

function GCamGalleryStore:Add()
	self.id = id2
	id2 += 1
	table.insert(all, 1, self)
	local v3 = false

	while #all > GCamConfig.MAX_PHOTOS do
		notify("removed", table.remove(all))
		v3 = true
	end

	notify("added", self)
	return self, v3
end

function GCamGalleryStore.Remove(p): boolean
	for i, v3 in ipairs(all) do
		if v3.id == p then
			table.remove(all, i)
			notify("removed", v3)
			return true
		end
	end

	return false
end

function GCamGalleryStore.SetDeveloped(p, content)
	local v3 = GCamGalleryStore.GetById(p)

	if v3 then
		v3.content = content
		v3.undeveloped = nil
		v3.failed = content == nil or nil
		notify("updated", v3)
	end
end

return GCamGalleryStore