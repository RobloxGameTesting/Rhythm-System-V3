local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SongConfig = require(ReplicatedStorage.Modules.SongConfig)
local GenreCatalog = {}

function GenreCatalog.GetAllGenres()
	local genreSet = {}

	for _, song in pairs(SongConfig.Songs) do
		if typeof(song.Genre) == "string" and song.Genre ~= "" then
			genreSet[song.Genre] = true
		end
	end

	local allGenres = {}

	for k in pairs(genreSet) do
		table.insert(allGenres, k)
	end

	table.sort(allGenres)
	return allGenres
end

function GenreCatalog.IsValidGenre(value): boolean
	if typeof(value) ~= "string" then
		return false
	end

	for _, song in pairs(SongConfig.Songs) do
		if song.Genre == value then
			return true
		end
	end

	return false
end

return GenreCatalog