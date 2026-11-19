local ChartDifficultyRatings = {}

ChartDifficultyRatings.Order = { "EASY", "MEDIUM", "HARD", "INSANE" }

ChartDifficultyRatings.Thresholds = { MEDIUM = 56, HARD = 87, INSANE = 124 }

ChartDifficultyRatings.Labels = {
	EASY = "Easy",
	MEDIUM = "Medium",
	HARD = "Hard",
	INSANE = "Insane"
}

ChartDifficultyRatings.Colors = {
	EASY = Color3.fromRGB(76, 200, 108),
	MEDIUM = Color3.fromRGB(246, 158, 48),
	HARD = Color3.fromRGB(232, 64, 60),
	INSANE = Color3.fromRGB(158, 86, 224)
}

ChartDifficultyRatings.InkColors = {
	EASY = Color3.fromRGB(60, 138, 76),
	MEDIUM = Color3.fromRGB(214, 120, 28),
	HARD = Color3.fromRGB(190, 40, 40),
	INSANE = Color3.fromRGB(122, 64, 172)
}

ChartDifficultyRatings.Levels = { EASY = 1, MEDIUM = 2, HARD = 3, INSANE = 4 }

local v = { "GuitarRhythm", "GuitarLead", "Bass", "Drum", "Keyboard", "Piano" }

ChartDifficultyRatings.Overrides = {}

local v2 = {
	["A Little Piece Of Heaven"] = {
		GuitarRhythm = 58,
		GuitarLead = 45,
		Bass = 56,
		Drum = 98,
		Keyboard = 61,
		Piano = 67
	},
	["A Miserable"] = { GuitarRhythm = 45, GuitarLead = 45, Bass = 56, Drum = 56 },
	Always = {
		GuitarRhythm = 21,
		GuitarLead = 37,
		Bass = 36,
		Drum = 54,
		Keyboard = 16,
		Piano = 43
	},
	["Be Gone!"] = { GuitarRhythm = 76, GuitarLead = 75, Bass = 63, Drum = 136 },
	["Bohemian Rhapsody"] = {
		GuitarRhythm = 37,
		GuitarLead = 35,
		Bass = 40,
		Drum = 57,
		Keyboard = 39,
		Piano = 59
	},
	Breed = { GuitarRhythm = 119, GuitarLead = 119, Bass = 49, Drum = 94 },
	["Canon Rock"] = {
		GuitarRhythm = 88,
		GuitarLead = 106,
		Bass = 74,
		Drum = 73,
		Keyboard = 14,
		Piano = 116
	},
	["Come As You Are"] = { GuitarRhythm = 60, GuitarLead = 60, Bass = 42, Drum = 67 },
	Creep = {
		GuitarRhythm = 60,
		GuitarLead = 108,
		Bass = 32,
		Drum = 58,
		Piano = 25
	},
	Cry = { GuitarRhythm = 33, Bass = 26, Drum = 31, Keyboard = 6 },
	["Demolition Lovers"] = { GuitarRhythm = 94, GuitarLead = 100, Bass = 73, Drum = 90 },
	Dewi = { GuitarRhythm = 74, GuitarLead = 73, Bass = 54, Drum = 132 },
	["Don't Look Back In Anger"] = {
		GuitarRhythm = 60,
		GuitarLead = 41,
		Bass = 41,
		Drum = 55,
		Keyboard = 21,
		Piano = 41
	},
	Duality = {
		GuitarRhythm = 108,
		GuitarLead = 102,
		Bass = 54,
		Drum = 103,
		Piano = 12
	},
	["Eruption (Guitar Tes)"] = { GuitarRhythm = 184, GuitarLead = 184 },
	Eyeless = {
		GuitarRhythm = 80,
		GuitarLead = 97,
		Bass = 77,
		Drum = 142,
		Keyboard = 74
	},
	["Final Duet"] = { Keyboard = 25, Piano = 67 },
	Floods = { GuitarRhythm = 60, GuitarLead = 54, Bass = 38, Drum = 55 },
	["Flower Dance"] = { GuitarRhythm = 82, GuitarLead = 88, Bass = 72, Drum = 110 },
	["Golden Brown"] = {
		GuitarRhythm = 42,
		GuitarLead = 42,
		Bass = 14,
		Drum = 36,
		Keyboard = 75,
		Piano = 27
	},
	Helena = {
		GuitarRhythm = 98,
		GuitarLead = 94,
		Bass = 80,
		Drum = 94,
		Keyboard = 23
	},
	Hysteria = { GuitarLead = 61, Bass = 72, Drum = 83 },
	Introvert = { GuitarRhythm = 93, GuitarLead = 65, Bass = 70, Drum = 86 },
	["Join Me"] = {
		GuitarRhythm = 23,
		GuitarLead = 48,
		Bass = 39,
		Drum = 52,
		Keyboard = 6,
		Piano = 21
	},
	["Keong Rock"] = { GuitarRhythm = 74, GuitarLead = 76, Bass = 61, Drum = 93 },
	["Negri Ngeri"] = { GuitarRhythm = 88, GuitarLead = 61, Bass = 65, Drum = 93 },
	["Nenekku Pahlawanku"] = {
		GuitarRhythm = 40,
		GuitarLead = 46,
		Bass = 38,
		Drum = 51,
		Keyboard = 43
	},
	["Please '' Let Me Get What I Want"] = {
		GuitarRhythm = 48,
		GuitarLead = 149,
		Bass = 36,
		Drum = 62
	},
	["Pretty Fly (for a White Guy)"] = { GuitarRhythm = 43, GuitarLead = 58, Bass = 43, Drum = 61 },
	Psychosocial = {
		GuitarRhythm = 92,
		GuitarLead = 87,
		Bass = 62,
		Drum = 102,
		Keyboard = 41
	},
	["Quiero Sentir tu"] = { GuitarRhythm = 120, GuitarLead = 113, Bass = 103, Drum = 152 },
	["Seize The Day"] = {
		GuitarRhythm = 60,
		GuitarLead = 103,
		Bass = 52,
		Drum = 62,
		Keyboard = 13,
		Piano = 48
	},
	Seventeen = { GuitarRhythm = 88, GuitarLead = 77, Bass = 71, Drum = 100 },
	["Smell Then"] = { GuitarRhythm = 64, GuitarLead = 64, Bass = 42, Drum = 77 },
	Solfeggietto = { GuitarRhythm = 130, GuitarLead = 130 },
	["Still Loving You"] = { GuitarRhythm = 36, GuitarLead = 60, Bass = 25, Drum = 46 },
	["Summon Of Baekdu"] = { GuitarRhythm = 165, GuitarLead = 129, Bass = 101, Drum = 147 },
	["Sweet Child O' Mine"] = { GuitarRhythm = 60, GuitarLead = 64, Bass = 42, Drum = 59 },
	["Tafsir Mistik"] = { GuitarRhythm = 68, GuitarLead = 59, Bass = 47, Drum = 74 },
	Tersimpan = { GuitarRhythm = 83, GuitarLead = 65, Bass = 65, Drum = 86 },
	["The Burden"] = { GuitarRhythm = 123, GuitarLead = 118, Bass = 103, Drum = 176 },
	["The Winner Takes It All"] = {
		GuitarRhythm = 60,
		GuitarLead = 60,
		Bass = 41,
		Drum = 61,
		Keyboard = 23,
		Piano = 53
	},
	["Through the Fire and Flames"] = {
		GuitarRhythm = 182,
		GuitarLead = 194,
		Bass = 103,
		Drum = 176,
		Keyboard = 81
	},
	["Time Bomb"] = {
		GuitarRhythm = 77,
		GuitarLead = 68,
		Bass = 60,
		Drum = 75,
		Keyboard = 84
	},
	["Tourette's"] = { GuitarRhythm = 80, GuitarLead = 80, Bass = 60, Drum = 86 },
	["Unholy Confessions"] = { GuitarRhythm = 76, GuitarLead = 77, Bass = 63, Drum = 112 },
	Virus = {
		GuitarRhythm = 67,
		GuitarLead = 110,
		Bass = 60,
		Drum = 81,
		Keyboard = 81,
		Piano = 71
	},
	["Wanita Masih Banyak"] = { GuitarRhythm = 74, GuitarLead = 59, Bass = 56, Drum = 76 },
	["Welcome To The Jungle"] = { GuitarRhythm = 78, GuitarLead = 72, Bass = 76, Drum = 93 },
	Yank = {
		GuitarRhythm = 60,
		GuitarLead = 98,
		Bass = 29,
		Drum = 60,
		Keyboard = 49,
		Piano = 51
	},
	["drum tes 2"] = { Drum = 85 }
}

local v3 = {
	["A Little Piece Of Heaven"] = "Bass=1124:249017808,Drum=2570:203088876,GuitarLead=519:1209291092,GuitarRhythm=642:1469928312,Keyboard=1144:462416739,Piano=2346:176350727,PianoMIDI=4703:1459407058",
	["A Miserable"] = "Bass=1259:1337841086,Drum=1071:1538514277,GuitarLead=564:434374897,GuitarRhythm=996:151049550",
	Always = "Bass=513:2055296301,Drum=1365:1379328242,GuitarLead=389:1331064484,GuitarRhythm=261:1409144961,Keyboard=374:1427784151,Piano=1311:1852424724",
	["Be Gone!"] = "Bass=295:1508748779,Drum=769:491948747,GuitarLead=385:189532205,GuitarRhythm=368:1799714000",
	["Bohemian Rhapsody"] = "Bass=386:1795356105,Drum=887:1880554559,GuitarLead=197:1718721797,GuitarRhythm=267:1655323055,Keyboard=480:1857684739,Piano=1396:681442524,PianoMIDI=2261:1435412449",
	Breed = "Bass=674:649297699,Drum=1388:2072231080,GuitarLead=1777:1766773376,GuitarRhythm=1777:1766773376",
	["Canon Rock"] = "Bass=1178:1192810299,Drum=1691:1921388297,GuitarLead=1401:1199579377,GuitarRhythm=1223:1813016555,Keyboard=418:574175728,Piano=2206:1028086328,PianoMIDI=3758:256768066",
	["Come As You Are"] = "Bass=700:703259839,Drum=1358:881428,GuitarLead=938:1297369351,GuitarRhythm=938:1297369351",
	Creep = "Bass=453:611931432,Drum=1327:1525757199,GuitarLead=595:1808336552,GuitarRhythm=734:1105755212,Piano=59:542734542,PianoMIDI=77:1421245495",
	Cry = "Bass=572:132415374,Drum=770:1365518638,GuitarRhythm=716:833299922,Keyboard=146:100498931",
	["Demolition Lovers"] = "Bass=1317:1730131568,Drum=2406:1073107173,GuitarLead=2315:107641010,GuitarRhythm=2447:685119684",
	Dewi = "Bass=664:1853363644,Drum=1778:1522456793,GuitarLead=1397:379412779,GuitarRhythm=1901:681675040",
	["Don't Look Back In Anger"] = "Bass=790:1486366162,Drum=1494:411460813,GuitarLead=414:1595431392,GuitarRhythm=962:1830548661,Keyboard=328:1585262233,Piano=1392:820730194,PianoMIDI=2049:512178065",
	["Drum Animation Test"] = "Drum=257:1867022380",
	Duality = "Bass=806:558380749,Drum=1907:1941586677,GuitarLead=1370:612990212,GuitarRhythm=1574:1488172117,Piano=32:963555333,PianoMIDI=32:1508574682",
	["Eruption (Guitar Tes)"] = "GuitarLead=729:706316564,GuitarRhythm=729:706316564",
	Eyeless = "Bass=955:1163817840,Drum=2425:2097068105,GuitarLead=1854:154397256,GuitarRhythm=968:1423905377,Keyboard=425:828032918",
	["Final Duet"] = "Keyboard=123:1804078714,Piano=546:1862030647",
	Floods = "Bass=773:1296424755,Drum=1601:1039665801,GuitarLead=658:1777080366,GuitarRhythm=1322:227975787",
	["Flower Dance"] = "Bass=1068:1854227318,Drum=1642:391959010,GuitarLead=1125:217244293,GuitarRhythm=1010:1417952140",
	["Golden Brown"] = "Bass=163:1004153855,Drum=338:1786842684,GuitarLead=234:1060888498,GuitarRhythm=234:1060888498,Keyboard=1072:1438193990,Piano=608:1152635343,PianoMIDI=612:1104711982",
	Helena = "Bass=978:1057885427,Drum=1365:2109527860,GuitarLead=1298:738991217,GuitarRhythm=1621:2048683334,Keyboard=126:1542190723",
	Hysteria = "Bass=1422:952073069,Drum=1752:466921732,GuitarLead=573:477491789",
	Introvert = "Bass=829:621420673,Drum=1439:741396591,GuitarLead=471:1861237565,GuitarRhythm=1538:672290315",
	["Join Me"] = "Bass=549:1638485851,Drum=998:1299083822,GuitarLead=763:1485997028,GuitarRhythm=183:1964262978,Keyboard=112:928839504,Piano=286:807405133,PianoMIDI=295:1554941573",
	["Keong Rock"] = "Bass=1134:374102097,Drum=1998:1731000730,GuitarLead=1033:611001328,GuitarRhythm=1143:887312322",
	["Negri Ngeri"] = "Bass=1411:953425022,Drum=2497:158471671,GuitarLead=1028:602638042,GuitarRhythm=2766:2002895595",
	["Nenekku Pahlawanku"] = "Bass=668:2082732991,Drum=1093:1814796454,GuitarLead=470:1193842488,GuitarRhythm=818:1455453154,Keyboard=619:1513319638",
	["Please '' Let Me Get What I Want"] = "Bass=282:1158360327,Drum=586:1786667763,GuitarLead=672:58120961,GuitarRhythm=581:556155477",
	["Pretty Fly (for a White Guy)"] = "Bass=539:676301055,Drum=1103:1659618937,GuitarLead=849:163095149,GuitarRhythm=461:1959465139",
	Psychosocial = "Bass=1141:1479016727,Drum=2217:1021334910,GuitarLead=1268:119506907,GuitarRhythm=1851:984353501,Keyboard=281:1054511729",
	["Quiero Sentir tu"] = "Bass=923:1453356346,Drum=1939:71343317,GuitarLead=1157:660972580,GuitarRhythm=1303:1305161847",
	["Seize The Day"] = "Bass=1077:1906600577,Drum=1476:1019651985,GuitarLead=840:557456286,GuitarRhythm=1131:203067416,Keyboard=198:1404095087,Piano=862:1475157514,PianoMIDI=1185:1643427780",
	Seventeen = "Bass=879:1646048159,Drum=1601:2113977635,GuitarLead=867:2067895012,GuitarRhythm=1083:2120701220",
	["Smell Then"] = "Bass=1022:1181266415,Drum=2063:479151247,GuitarLead=1447:1352558472,GuitarRhythm=1447:1352558472",
	Solfeggietto = "GuitarLead=521:1444324870,GuitarRhythm=521:1444324870",
	["Still Loving You"] = "Bass=363:2086522055,Drum=1032:372128794,GuitarLead=849:265914617,GuitarRhythm=674:927701065",
	["Summon Of Baekdu"] = "Bass=712:975161050,Drum=1466:880751092,GuitarLead=1644:210506260,GuitarRhythm=1704:122691712",
	["Sweet Child O' Mine"] = "Bass=1037:349255580,Drum=2289:391991320,GuitarLead=1087:813435019,GuitarRhythm=1650:1873745639",
	["Tafsir Mistik"] = "Bass=589:1841029846,Drum=1289:951886574,GuitarLead=443:1238017473,GuitarRhythm=991:495749001",
	Tersimpan = "Bass=950:1766849356,Drum=1731:2057101236,GuitarLead=653:1081460615,GuitarRhythm=1798:1842237517",
	["The Burden"] = "Bass=1541:1805531703,Drum=2544:1648205040,GuitarLead=763:1479775402,GuitarRhythm=2072:2085961537",
	["The Winner Takes It All"] = "Bass=581:1471565448,Drum=1435:2110878585,GuitarLead=861:1550440279,GuitarRhythm=861:1550440279,Keyboard=556:1976196351,Piano=1319:1142475982,PianoMIDI=1402:596085781",
	["Through the Fire and Flames"] = "Bass=2593:100317421,Drum=5498:743036416,GuitarLead=3802:1248756070,GuitarRhythm=3605:1822675497,Keyboard=1139:1882337820",
	["Time Bomb"] = "Bass=597:126166405,Drum=987:339272375,GuitarLead=920:2082595409,GuitarRhythm=966:106589300,Keyboard=1051:1230382797",
	["Tourette's"] = "Bass=319:2024134737,Drum=563:1418263659,GuitarLead=827:1939467965,GuitarRhythm=827:1939467965",
	["Unholy Confessions"] = "Bass=866:1172034106,Drum=2073:1960680644,GuitarLead=1244:1537444161,GuitarRhythm=1326:1745529857",
	Virus = "Bass=784:583465066,Drum=1509:355711794,GuitarLead=1010:610010518,GuitarRhythm=972:542770038,Keyboard=754:366524096,Piano=1126:715724785,PianoMIDI=1467:1975450246",
	["Wanita Masih Banyak"] = "Bass=947:676246161,Drum=1617:1724512052,GuitarLead=729:2126938975,GuitarRhythm=1820:446255314",
	["Welcome To The Jungle"] = "Bass=1077:1280266893,Drum=1716:2079016532,GuitarLead=624:1431574643,GuitarRhythm=1287:131163665",
	Yank = "Bass=498:1767200636,Drum=1315:2089033129,GuitarLead=714:605408137,GuitarRhythm=1240:1735866778,Keyboard=304:418647821,Piano=851:887736767,PianoMIDI=978:1729000080",
	["drum tes 2"] = "Drum=228:1898104299"
}

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local v4 = nil

local function applyRuntime(runtimeScores) -- 2 equivalent calls inferred from this helper
	local value = runtimeScores.Value

	if value == "" then
		return
	end

	local success, result = pcall(HttpService.JSONDecode, HttpService, value)

	if success and type(result) == "table" then
		v4 = result
	end
end

ChartDifficultyRatings.RuntimeWaitedSeconds = 0

if RunService:IsRunning() and RunService:IsClient() and not RunService:IsServer() then
	local lastTime = os.clock()
	local runtimeScores = script:WaitForChild("RuntimeScores", 8)

	if runtimeScores then
		while runtimeScores.Value == "" and os.clock() - lastTime < 8 do
			task.wait(0.1)
		end
	end

	ChartDifficultyRatings.RuntimeWaitedSeconds = os.clock() - lastTime
end

local RuntimeScores = script:FindFirstChild("RuntimeScores")

if RuntimeScores and RuntimeScores:IsA("StringValue") then
	applyRuntime(RuntimeScores) -- inferred equivalent call
	RuntimeScores:GetPropertyChangedSignal("Value"):Connect(function()
		applyRuntime(RuntimeScores) -- inferred equivalent call
	end)
end

local function songScores(p) -- 2 equivalent calls inferred from this helper
	if v4 then
		local v5 = v4[p]

		if v5 ~= nil then
			return v5
		end
	end

	return v2[p]
end

function ChartDifficultyRatings.GetStaticSignature(p)
	return v3[p]
end

function ChartDifficultyRatings.TierFor(value): nil | string
	if type(value) ~= "number" then
		return nil
	end

	local thresholds = ChartDifficultyRatings.Thresholds

	if thresholds.INSANE <= value then
		return "INSANE"
	end

	if thresholds.HARD <= value then
		return "HARD"
	end

	return if thresholds.MEDIUM <= value then "MEDIUM" else "EASY"
end

function ChartDifficultyRatings.GetChartScore(p, p2)
	local v5 = songScores(p) -- inferred equivalent call
	return v5 and v5[p2] or nil
end

local function overrideTier(p, p2) -- 1 equivalent call inferred from this helper
	local override = ChartDifficultyRatings.Overrides[p]
	local v5 = override and override[p2]

	if type(v5) == "string" then
		local v6 = string.upper(v5)

		if ChartDifficultyRatings.Levels[v6] then
			return v6
		end
	end

	return nil
end

function ChartDifficultyRatings.GetChartTier(p, p2)
	return overrideTier(p, p2) or ChartDifficultyRatings.TierFor(ChartDifficultyRatings.GetChartScore(p, p2)) -- inferred equivalent call
end

function ChartDifficultyRatings.GetSongScore(p)
	local v5 = songScores(p) -- inferred equivalent call

	if not v5 then
		return nil
	end

	local v6 = nil

	for _, v7 in pairs(v5) do
		if type(v7) == "number" and (not v6 or v6 < v7) then
			v6 = v7
		end
	end

	return v6
end

function ChartDifficultyRatings.GetSongTier(p)
	local v5 = 0
	local songTier = nil

	for _, v6 in ipairs(v) do
		local chartTier = ChartDifficultyRatings.GetChartTier(p, v6)
		local v7 = chartTier and ChartDifficultyRatings.Levels[chartTier]

		if not (v7 and v5 < v7) then
			continue
		end

		songTier = chartTier
		v5 = v7
	end

	return songTier
end

return ChartDifficultyRatings