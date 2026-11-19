local PlayerTitleConfig = {}

PlayerTitleConfig.Thresholds = {
	{ Title = "Apex", MinGigs = 1000 },
	{ Title = "Anthem", MinGigs = 965 },
	{ Title = "Legend", MinGigs = 870 },
	{ Title = "Mythic", MinGigs = 780 },
	{ Title = "Encore", MinGigs = 695 },
	{ Title = "Iconic", MinGigs = 615 },
	{ Title = "Idol", MinGigs = 540 },
	{ Title = "Molten", MinGigs = 470 },
	{ Title = "Chaos", MinGigs = 405 },
	{ Title = "Riot", MinGigs = 345 },
	{ Title = "Brutal", MinGigs = 290 },
	{ Title = "Savage", MinGigs = 240 },
	{ Title = "Feral", MinGigs = 195 },
	{ Title = "Loud", MinGigs = 155 },
	{ Title = "Mosher", MinGigs = 120 },
	{ Title = "Riff", MinGigs = 90 },
	{ Title = "Doom", MinGigs = 65 },
	{ Title = "Sludge", MinGigs = 45 },
	{ Title = "Thrash", MinGigs = 30 },
	{ Title = "Shred", MinGigs = 20 },
	{ Title = "Punk", MinGigs = 12 },
	{ Title = "Garage", MinGigs = 5 },
	{ Title = "Roadie", MinGigs = 0 }
}

function PlayerTitleConfig.GetTitle(p)
	for _, threshold in ipairs(PlayerTitleConfig.Thresholds) do
		if threshold.MinGigs <= p then
			return threshold.Title
		end
	end

	return "Roadie"
end

function PlayerTitleConfig.GetNext(p)
	local nextNode = nil

	for _, threshold in ipairs(PlayerTitleConfig.Thresholds) do
		if p < threshold.MinGigs then
			nextNode = threshold
		else
			break
		end
	end

	return nextNode
end

return PlayerTitleConfig