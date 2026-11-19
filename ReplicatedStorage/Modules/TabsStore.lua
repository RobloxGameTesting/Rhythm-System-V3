local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TabsSong = require(script.Parent.TabsSong)

local TabsStore = {}
TabsStore.MAX_SLOTS = 30
TabsStore.MAX_TITLE = 24
TabsStore.RES = 96

local function getRemote() -- 1 equivalent call inferred from this helper
	local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
	return remoteEvents and remoteEvents:WaitForChild("TabsRequest", 10)
end

local function call(...)
	local remote = getRemote() -- inferred equivalent call

	if not remote then
		return { ok = false, err = "Not connected" }
	end

	local v = table.pack(...)
	local success, result = pcall(function()
		return remote:InvokeServer(table.unpack(v, 1, v.n))
	end)

	if success and type(result) == "table" then
		return result
	end

	return { ok = false, err = "Connection error, try again" }
end

local function b36(p)
	if p == 0 then
		return "0"
	end

	local v = ""

	while p > 0 do
		local v2 = p % 36
		v = string.sub("0123456789abcdefghijklmnopqrstuvwxyz", v2 + 1, v2 + 1) .. v
		p = (p - v2) // 36
	end

	return v
end

function TabsStore.Encode(p)
	local clone = table.clone(p)
	table.sort(clone, function(a, b): boolean
		if a.t == b.t then
			return a.lane < b.lane
		end

		return a.t < b.t
	end)

	local v = table.create(#clone)
	local v2 = 0

	for i, v3 in ipairs(clone) do
		v[i] = b36(v3.t - v2) .. "," .. b36(math.max(1, v3.d)) .. "," .. b36(v3.lane) .. (v3.k and "," .. v3.k or "")
		v2 = v3.t
	end

	return table.concat(v, ";")
end

function TabsStore.Decode(value)
	local decoded, v, v2, v3, v4 = TabsSong._decode(value or "")
	local result = table.create(v3)

	for i = 1, v3 do
		result[i] = { t = decoded[i], d = v[i], lane = v2[i], k = v4[i] }
	end

	return result
end

function TabsStore.ToTrack(data, instrument, p)
	return TabsSong.BuildTrack({
		SongId = "MyTabs",
		TrackId = tostring(p),
		Name = data.Title,
		Title = data.Title,
		Author = data.Author,
		Instrument = instrument,
		Bpm = data.Bpm,
		BeatsPerBar = data.BeatsPerBar,
		Bars = data.Bars,
		Sections = data.Sections,
		Changes = data.Changes,
		Tones = data.Tones
	}, data.Raw)
end

function TabsStore.List(p)
	local v = call("List", p)

	if not v.ok or type(v.slots) ~= "table" then
		return v
	end

	local slots = {}

	for k, slot in pairs(v.slots) do
		slots[tonumber(k) or k] = slot
	end

	v.slots = slots

	return v
end

function TabsStore.Get(p, p2)
	return call("Get", p, p2)
end

function TabsStore.Save(p, p2, data)
	return call("Save", p, p2, {
		Title = data.Title,
		Bpm = data.Bpm,
		BeatsPerBar = data.BeatsPerBar,
		Bars = data.Bars,
		Sections = data.Sections,
		Changes = data.Changes,
		Tones = data.Tones,
		Raw = TabsStore.Encode(data.Notes)
	})
end

function TabsStore.Rename(p, p2, p3)
	return call("Rename", p, p2, p3)
end

function TabsStore.Delete(p, p2)
	return call("Delete", p, p2)
end

function TabsStore.ShareSend(p, p2, p3)
	return call("ShareSend", p, p2, p3)
end

function TabsStore.ShareAccept(p, p2)
	return call("ShareAccept", p, p2)
end

function TabsStore.ShareDecline(p, p2)
	return call("ShareDecline", p, p2)
end

function TabsStore.Publish(p, p2)
	return call("Publish", p, p2)
end

function TabsStore.Unpublish(p, p2)
	return call("Unpublish", p, p2)
end

function TabsStore.PubList(p)
	return call("PubList", p)
end

function TabsStore.PubGet(p, p2)
	return call("PubGet", p, p2)
end

function TabsStore.PubCopy(p, p2)
	return call("PubCopy", p, p2)
end

function TabsStore.Report(p, p2)
	return call("Report", p, p2)
end

function TabsStore.PubToTrack(data, instrument, trackId)
	local track = TabsSong.BuildTrack({
		SongId = "Community",
		TrackId = trackId,
		Name = data.Title,
		Title = data.Title,
		Artist = data.Author or "",
		Author = data.Author,
		Instrument = instrument,
		Bpm = data.Bpm,
		BeatsPerBar = data.BeatsPerBar,
		Bars = data.Bars,
		Sections = data.Sections,
		Changes = data.Changes,
		Tones = data.Tones
	}, data.Raw)
	track.IsUser = false
	return track
end

function TabsStore.DraftSave(p, data)
	return call("DraftSave", p, {
		Title = data.Title,
		Bpm = data.Bpm,
		BeatsPerBar = data.BeatsPerBar,
		Bars = data.Bars,
		Sections = data.Sections,
		Changes = data.Changes,
		Tones = data.Tones,
		Raw = TabsStore.Encode(data.Notes)
	})
end

function TabsStore.DraftGet(p)
	return call("DraftGet", p)
end

function TabsStore.DraftClear(p)
	return call("DraftClear", p)
end

return TabsStore