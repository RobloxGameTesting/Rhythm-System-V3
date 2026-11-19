local SongConfig = require(script.Parent.SongConfig)
local ChartDifficultyRatings = require(script.Parent.ChartDifficultyRatings)

local SongConfigAdapter = {}

local v = { "GuitarRhythm", "GuitarLead", "Bass", "Drum", "Keyboard", "Piano" }

function SongConfigAdapter.GetSongId(p)
	local song = SongConfig.Songs[p]
	return if song and song.Id then song.Id else p
end

local v2 = nil

local function ensureReverseLookup()
	if v2 then
		return
	end

	v2 = {}

	for k in pairs(SongConfig.Songs) do
		local songId = SongConfigAdapter.GetSongId(k)

		if v2[songId] then
			warn(string.format(
				"[SongConfigAdapter] songId duplikat: '%s' dipakai oleh '%s' DAN '%s' -- salah satu tidak akan bisa diakses lewat GetRawKey()",
				songId,
				v2[songId],
				k
			))
		end

		v2[songId] = k
	end
end

function SongConfigAdapter.GetRawKey(p)
	ensureReverseLookup()
	return v2[p]
end

local function deriveInstrumentAvailability(data)
	local instrumentAvailability = {}

	for _, v3 in ipairs(v) do
		instrumentAvailability[v3] = data.Stems[v3] ~= nil
	end

	return instrumentAvailability
end

local function tierForInstrument(p, song, p2) -- 1 equivalent call inferred from this helper
	if not song.Difficulty then
		return ChartDifficultyRatings.GetChartTier(p, p2)
	end

	return if song.Stems[p2] ~= nil then song.Difficulty else nil
end

local function deriveInstrumentDifficulty(p, data)
	local instrumentDifficulty = {}

	for _, v3 in ipairs(v) do
		instrumentDifficulty[v3] = tierForInstrument(p, data, v3) -- inferred equivalent call
	end

	return instrumentDifficulty
end

function SongConfigAdapter.ToRecord(p, data)
	return {
		songId = SongConfigAdapter.GetSongId(p),
		displayName = data.DisplayName or p,
		artist = data.Artist,
		genre = data.Genre,
		bpm = data.BPM,
		duration = data.Duration,
		difficulty = data.Difficulty or ChartDifficultyRatings.GetSongTier(p),
		instrumentDifficulty = deriveInstrumentDifficulty(p, data),
		recommendedPlayers = data.RecommendedPlayers,
		isFavorite = false,
		instrumentAvailability = deriveInstrumentAvailability(data)
	}
end

function SongConfigAdapter.GetInstrumentTier(p, p2)
	local song = SongConfig.Songs[p]

	if song then
		return tierForInstrument(p, song, p2)
	end

	return nil
end

function SongConfigAdapter.GetAllSongs()
	local allSongs = {}

	for k, song in pairs(SongConfig.Songs) do
		table.insert(allSongs, SongConfigAdapter.ToRecord(k, song))
	end

	return allSongs
end

function SongConfigAdapter.GetSong(p)
	local rawKey = SongConfigAdapter.GetRawKey(p)

	if rawKey then
		return SongConfigAdapter.ToRecord(rawKey, SongConfig.Songs[rawKey])
	end

	return nil
end

function SongConfigAdapter.GetPreviewStems(p)
	local rawKey = SongConfigAdapter.GetRawKey(p)

	if not rawKey then
		return {}
	end

	local song = SongConfig.Songs[rawKey]
	local result = {}

	for _, instrumentType in ipairs(v) do
		local stem = song.Stems[instrumentType]

		if stem then
			table.insert(result, {
				instrumentType = instrumentType,
				assetId = stem,
				relativeVolume = song.DefaultVolumes and song.DefaultVolumes[instrumentType] or 1
			})
		end
	end

	return result
end

return SongConfigAdapter