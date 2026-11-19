local SongConfig = {}

local songs = {
	Territorial = {
		DisplayName = "Territorial",
		Artist = "Nirvana",
		Duration = 139,
		Mood = "Fast",
		Genre = "Punk",
		BPM = 184,
		RecommendedPlayers = 4,
		DefaultVolumes = { Drum = 2, Bass = 1, GuitarLead = 1, GuitarRhythm = 2 },
		Stems = {
			GuitarLead = "rbxassetid://124347293134092",
			GuitarRhythm = "rbxassetid://81217080376978",
			Bass = "rbxassetid://124007488710467",
			Drum = "rbxassetid://130467397429156"
		}
	},
	["Drum Animation Test"] = {
		DisplayName = "Drum Animation Test",
		Duration = 5,
		Mood = "Fast",
		Genre = "Punk",
		BPM = 1,
		RecommendedPlayers = 1,
		DefaultVolumes = { Drum = 3 },
		Stems = { Drum = "rbxassetid://102093004175703" }
	},
	["drum tes 2"] = {
		DisplayName = "drum tes 2",
		Duration = 48,
		Mood = "Fast",
		Genre = "Punk",
		BPM = 120,
		Offset = -0.3,
		InstrumentOffsets = { Drum = 0.22 },
		RecommendedPlayers = 1,
		DefaultVolumes = { Drum = 3 },
		Stems = { Drum = "rbxassetid://81018532474816" }
	},
	Creep = {
		DisplayName = "Creep",
		Artist = "Radiohead",
		Duration = 238,
		Mood = "Chill",
		Genre = "Alternative Rock",
		BPM = 93,
		Offset = -0.3,
		InstrumentOffsets = {
			Drum = 0.18,
			Bass = 0.1,
			Piano = -0,
			PianoMIDI = 0.3,
			GuitarRhythm = 0.22,
			GuitarLead = 0.13,
			Keyboard = 0
		},
		DefaultVolumes = {
			Drum = 2,
			Bass = 0.7,
			Piano = 0.5,
			Keyboard = 1,
			GuitarLead = 1,
			GuitarRhythm = 1
		},
		Stems = {
			GuitarLead = "rbxassetid://117079641996061",
			GuitarRhythm = "rbxassetid://86751351183995",
			Bass = "rbxassetid://97080388582063",
			Drum = "rbxassetid://132048690619356",
			Piano = "rbxassetid://99706721372522"
		}
	},
	["Please '' Let Me Get What I Want"] = {
		DisplayName = "Please '' Let Me Get What I Want",
		Artist = "Deftones",
		Duration = 117,
		Mood = "Chill",
		Genre = "Shoegaze",
		BPM = 184,
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.23, GuitarRhythm = 0.23, Drum = 0.23, Bass = 0.21 },
		DefaultVolumes = { Drum = 1, Bass = 1, GuitarLead = 1, GuitarRhythm = 1 },
		Stems = {
			GuitarLead = "rbxassetid://135872433063491",
			GuitarRhythm = "rbxassetid://86142443701385",
			Bass = "rbxassetid://76002519054917",
			Drum = "rbxassetid://105442995566021"
		}
	},
	["A Miserable"] = {
		DisplayName = "A Miserable",
		Artist = "Decalius",
		Duration = 255,
		Mood = "Chill",
		Genre = "Black Metal - DSBM",
		BPM = 65,
		Offset = -0.3,
		InstrumentOffsets = { Drum = 0, Bass = 0, GuitarRhythm = 0, GuitarLead = 0.28 },
		RecommendedPlayers = 4,
		DefaultVolumes = { Drum = 2.5, Bass = 1, GuitarLead = 1, GuitarRhythm = 2 },
		Stems = {
			GuitarLead = "rbxassetid://115677096519590",
			GuitarRhythm = "rbxassetid://110252525186647",
			Bass = "rbxassetid://77103326589346",
			Drum = "rbxassetid://135668582252862"
		}
	},
	Hysteria = {
		DisplayName = "Hysteria",
		Artist = "Muse",
		Duration = 230,
		Mood = "Fast",
		Genre = "Alternative Rock",
		RecommendedPlayers = 4,
		BPM = 93,
		Offset = -0.3,
		InstrumentOffsets = { Drum = 0.28, Bass = 0.27, GuitarRhythm = 0.28, GuitarLead = 0.28 },
		DefaultVolumes = { Drum = 1, Bass = 1, GuitarLead = 1, GuitarRhythm = 1 },
		Stems = {
			GuitarLead = "rbxassetid://107019075408424",
			GuitarRhythm = "rbxassetid://97538403234060",
			Bass = "rbxassetid://113926765281300",
			Drum = "rbxassetid://76275887563654"
		}
	},
	["Pretty Fly (for a White Guy)"] = {
		DisplayName = "Pretty Fly (for a White Guy)",
		Artist = "The Offspring",
		Duration = 185,
		Mood = "Fast",
		Genre = "Alternative Rock",
		BPM = 144,
		Offset = -0.3,
		InstrumentOffsets = { Drum = 0.26, Bass = 0.24, GuitarRhythm = 0.25, GuitarLead = 0.26 },
		RecommendedPlayers = 3,
		DefaultVolumes = { Drum = 2, Bass = 1, GuitarLead = 1.5, GuitarRhythm = 1.5 },
		Stems = {
			GuitarLead = "rbxassetid://101535200761922",
			GuitarRhythm = "rbxassetid://78061129454078",
			Bass = "rbxassetid://86382050413482",
			Drum = "rbxassetid://117446121363273"
		}
	},
	Floods = {
		DisplayName = "Floods",
		Artist = "Pantera",
		Duration = 420,
		Mood = "Hardcore",
		Genre = "Metal - Groove",
		BPM = 118,
		Offset = -0.3,
		InstrumentOffsets = { Drum = 4.7, Bass = 0.23, GuitarRhythm = 4.53, GuitarLead = 4.75 },
		RecommendedPlayers = 5,
		DefaultVolumes = { Drum = 1.3, Bass = 1, GuitarLead = 1.2, GuitarRhythm = 1 },
		Stems = {
			GuitarLead = "rbxassetid://81003011038179",
			GuitarRhythm = "rbxassetid://71588247050078",
			Bass = "rbxassetid://103791050928579",
			Drum = "rbxassetid://76330706297659"
		}
	},
	["Seize The Day"] = {
		DisplayName = "Seize The Day",
		Artist = "Avenged Sevenfold",
		Duration = 340,
		Mood = "Hardcore",
		Genre = "Metal - Heavy",
		BPM = 140,
		RecommendedPlayers = 6,
		Offset = -0.3,
		InstrumentOffsets = {
			Drum = -0.08,
			Bass = -0.1,
			Piano = -0.08,
			PianoMIDI = 0.11,
			GuitarRhythm = 0.18,
			GuitarLead = -0.08,
			Keyboard = 0.08
		},
		DefaultVolumes = {
			Drum = 1,
			Bass = 1,
			Piano = 1,
			Keyboard = 1,
			GuitarLead = 1,
			GuitarRhythm = 1.5
		},
		Stems = {
			GuitarLead = "rbxassetid://135772002001054",
			GuitarRhythm = "rbxassetid://137833894398255",
			Bass = "rbxassetid://90434500600607",
			Drum = "rbxassetid://115014372645000",
			Keyboard = "rbxassetid://109689656749444",
			Piano = "rbxassetid://119421942849819"
		}
	},
	["A Little Piece Of Heaven"] = {
		DisplayName = "A Little Piece Of Heaven",
		Artist = "Avenged Sevenfold",
		Duration = 415,
		Mood = "Hardcore",
		Genre = "Metal - Heavy",
		BPM = 145,
		RecommendedPlayers = 6,
		Offset = -0.3,
		InstrumentOffsets = {
			Drum = 0.23,
			Bass = 0.24,
			Piano = 0.23,
			PianoMIDI = 0.3,
			GuitarRhythm = 0.24,
			GuitarLead = 0.23,
			Keyboard = 0.23
		},
		DefaultVolumes = {
			Drum = 2,
			Bass = 2.5,
			Piano = 1,
			Keyboard = 1,
			GuitarLead = 2,
			GuitarRhythm = 2
		},
		Stems = {
			GuitarLead = "rbxassetid://140423060012125",
			GuitarRhythm = "rbxassetid://109006451638921",
			Bass = "rbxassetid://138954297727706",
			Drum = "rbxassetid://73064654109498",
			Keyboard = "rbxassetid://108925263858976",
			Piano = "rbxassetid://133934165363518"
		}
	},
	Eyeless = {
		DisplayName = "Eyeless",
		Artist = "Slipknot",
		Duration = 236,
		Mood = "Hardcore",
		Genre = "Metal - Nu",
		BPM = 192,
		RecommendedPlayers = 5,
		Offset = -0.3,
		InstrumentOffsets = {
			Drum = 0.23,
			GuitarRhythm = 0.23,
			GuitarLead = 0.23,
			Bass = 0.23,
			Keyboard = 0.23
		},
		DefaultVolumes = {
			Drum = 4,
			Bass = 2,
			Keyboard = 2,
			GuitarLead = 3,
			GuitarRhythm = 4
		},
		Stems = {
			GuitarLead = "rbxassetid://134987202116565",
			GuitarRhythm = "rbxassetid://125485981415376",
			Bass = "rbxassetid://87890600051730",
			Drum = "rbxassetid://102093004175703",
			Keyboard = "rbxassetid://139928930647328"
		}
	},
	["Canon Rock"] = {
		DisplayName = "Canon Rock",
		Artist = "JerryC",
		Duration = 353,
		Mood = "Hardcore",
		Genre = "Rock - Neoclassical",
		BPM = 180,
		RecommendedPlayers = 6,
		Offset = -0.3,
		InstrumentOffsets = {
			Drum = 0.18,
			Bass = 0.1,
			Piano = 0.2,
			PianoMIDI = -0.9,
			GuitarRhythm = 0.25,
			GuitarLead = 0.07,
			Keyboard = 0.23
		},
		DefaultVolumes = {
			Drum = 2,
			Bass = 1,
			Piano = 3,
			GuitarRhythm = 1,
			Keyboard = 2,
			GuitarLead = 2
		},
		Stems = {
			GuitarLead = "rbxassetid://124866996224091",
			GuitarRhythm = "rbxassetid://112050889382301",
			Bass = "rbxassetid://72455311331014",
			Drum = "rbxassetid://92957048951042",
			Keyboard = "rbxassetid://132843100262676",
			Piano = "rbxassetid://124695677377116"
		}
	},
	["Sweet Child O' Mine"] = {
		DisplayName = "Sweet Child O' Mine",
		Artist = "Guns N' Roses",
		Duration = 360,
		Mood = "Hardcore",
		Genre = "Rock",
		BPM = 123,
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { Drum = 0.23, GuitarRhythm = 0.25, GuitarLead = 0.25, Bass = 0.25 },
		DefaultVolumes = { Drum = 2, Bass = 1.5, GuitarLead = 1, GuitarRhythm = 2 },
		Stems = {
			GuitarLead = "rbxassetid://128229951148776",
			GuitarRhythm = "rbxassetid://83492424656427",
			Bass = "rbxassetid://138595101049084",
			Drum = "rbxassetid://108501973757284"
		}
	},
	["Don't Look Back In Anger"] = {
		DisplayName = "Don't Look Back In Anger",
		Artist = "Oasis",
		Duration = 290,
		Mood = "Chill",
		Genre = "Rock - Britpop",
		BPM = 81,
		KeyAuraStyle = "Warm",
		RecommendedPlayers = 6,
		Offset = -0.3,
		InstrumentOffsets = {
			Drum = 0.22,
			Bass = 0.22,
			Piano = 0.21,
			PianoMIDI = 0.3,
			Keyboard = 0.22,
			GuitarRhythm = 0.22,
			GuitarLead = 0.21
		},
		DefaultVolumes = {
			Drum = 1.5,
			Bass = 2,
			Piano = 1.5,
			Keyboard = 1.5,
			GuitarLead = 1,
			GuitarRhythm = 2
		},
		Stems = {
			GuitarLead = "rbxassetid://86579281800136",
			GuitarRhythm = "rbxassetid://86737305731946",
			Bass = "rbxassetid://83631875448413",
			Drum = "rbxassetid://133306473934862",
			Keyboard = "rbxassetid://76049918398614",
			Piano = "rbxassetid://135400184688628"
		}
	},
	["Welcome To The Jungle"] = {
		DisplayName = "Welcome To The Jungle",
		Artist = "Guns N' Roses",
		Duration = 274,
		Mood = "Hardcore",
		Genre = "Rock",
		BPM = 125,
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { Drum = 0.23, Bass = 0.24, GuitarRhythm = 0.25, GuitarLead = 0.25 },
		DefaultVolumes = { Drum = 2, Bass = 1, GuitarLead = 1, GuitarRhythm = 2 },
		Stems = {
			GuitarLead = "rbxassetid://91818850115729",
			GuitarRhythm = "rbxassetid://93308342432794",
			Bass = "rbxassetid://104671624607873",
			Drum = "rbxassetid://83616096069478"
		}
	},
	["Join Me"] = {
		DisplayName = "Join Me",
		Artist = "HIM",
		Duration = 220,
		Mood = "Chill",
		BPM = 113,
		Genre = "Rock - Gothic",
		RecommendedPlayers = 6,
		Offset = -0.3,
		InstrumentOffsets = {
			Drum = 0.24,
			Piano = 0.22,
			PianoMIDI = 0.15,
			Keyboard = 0.23,
			GuitarRhythm = 0.05,
			GuitarLead = 0.05,
			Bass = 0.23
		},
		DefaultVolumes = {
			Drum = 2,
			Bass = 1.5,
			Piano = 1,
			Keyboard = 1.3,
			GuitarLead = 2,
			GuitarRhythm = 1.3
		},
		Stems = {
			GuitarLead = "rbxassetid://131979626255081",
			GuitarRhythm = "rbxassetid://91803389590974",
			Bass = "rbxassetid://132134283904654",
			Drum = "rbxassetid://71406113169361",
			Keyboard = "rbxassetid://122255984413589",
			Piano = "rbxassetid://99684950772046"
		}
	},
	Yank = {
		DisplayName = "Yank",
		Artist = "Wali",
		Duration = 278,
		Mood = "Chill",
		BPM = 130,
		Genre = "Pop - Indo",
		RecommendedPlayers = 6,
		Offset = -0.3,
		InstrumentOffsets = {
			Drum = 0.21,
			Piano = 0.21,
			PianoMIDI = 0.3,
			Bass = 0.21,
			Keyboard = 0.21,
			GuitarRhythm = 0.23,
			GuitarLead = 0.21
		},
		DefaultVolumes = {
			Drum = 2,
			Bass = 1.5,
			Piano = 2,
			Keyboard = 1,
			GuitarLead = 1,
			GuitarRhythm = 1.5
		},
		Stems = {
			GuitarLead = "rbxassetid://129413492959567",
			GuitarRhythm = "rbxassetid://114100645247002",
			Bass = "rbxassetid://122199852870521",
			Drum = "rbxassetid://93581479395632",
			Keyboard = "rbxassetid://81651959040250",
			Piano = "rbxassetid://112151468430502"
		}
	},
	["Tafsir Mistik"] = {
		DisplayName = "Tafsir Mistik",
		Artist = "The Panturas",
		Duration = 213,
		Mood = "Chill",
		BPM = 115,
		Genre = "Rock - Surf - Indo",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = {
			Drum = 0.22,
			Piano = 0.21,
			Keyboard = 0,
			GuitarRhythm = 0.29,
			GuitarLead = 0.24,
			Bass = 0.22
		},
		DefaultVolumes = {
			Drum = 2,
			Bass = 1.5,
			Piano = 2,
			Keyboard = 1,
			GuitarLead = 1,
			GuitarRhythm = 1.5
		},
		Stems = {
			GuitarLead = "rbxassetid://115018602425760",
			GuitarRhythm = "rbxassetid://113020094707000",
			Bass = "rbxassetid://123356527884954",
			Drum = "rbxassetid://78603801544349",
			BVocal = "rbxassetid://87463081742963"
		}
	},
	Seventeen = {
		DisplayName = "Seventeen",
		Artist = "Boedak Korporat",
		Duration = 188,
		Mood = "Fast",
		BPM = 240,
		Genre = "Pop - Punk - Indo",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { Drum = 0.25, Bass = 0.25, GuitarRhythm = 0.25, GuitarLead = 0.25 },
		DefaultVolumes = { Drum = 2, Bass = 1.5, GuitarLead = 1, GuitarRhythm = 1.5 },
		Stems = {
			GuitarLead = "rbxassetid://103534114398761",
			GuitarRhythm = "rbxassetid://109006285854768",
			Bass = "rbxassetid://85754340206603",
			Drum = "rbxassetid://126391441618019",
			BVocal = "rbxassetid://129199969717146"
		}
	},
	["Keong Rock"] = {
		DisplayName = "Keong Rock",
		Duration = 275,
		Mood = "Fast",
		BPM = 167,
		Genre = "Pop - Rock - Indo",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { Drum = 0.24, GuitarRhythm = 0.23, GuitarLead = 0.23, Bass = 0.23 },
		DefaultVolumes = { Drum = 3, Bass = 2, GuitarLead = 1.5, GuitarRhythm = 3.5 },
		Stems = {
			GuitarLead = "rbxassetid://91457507571082",
			GuitarRhythm = "rbxassetid://129884133043292",
			Bass = "rbxassetid://136052738651931",
			Drum = "rbxassetid://112656289785962"
		}
	},
	["Nenekku Pahlawanku"] = {
		DisplayName = "Nenekku Pahlawanku",
		Artist = "Wali",
		Duration = 260,
		Mood = "Chill",
		BPM = 60,
		Genre = "Pop - Indo",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = {
			Drum = 0.22,
			Keyboard = 0.21,
			GuitarRhythm = 0.28,
			GuitarLead = 0.21,
			Bass = 0.23
		},
		DefaultVolumes = {
			Drum = 2.5,
			Bass = 1.5,
			Keyboard = 2,
			GuitarLead = 1,
			GuitarRhythm = 1
		},
		Stems = {
			GuitarLead = "rbxassetid://97595852701940",
			GuitarRhythm = "rbxassetid://124501260710411",
			Bass = "rbxassetid://98406936238327",
			Drum = "rbxassetid://90907881465846",
			Keyboard = "rbxassetid://101602099813511",
			BVocal = "rbxassetid://97689551111680"
		}
	},
	["Wanita Masih Banyak"] = {
		DisplayName = "Wanita Masih Banyak",
		Artist = "Stand Here Alone",
		Duration = 235,
		Mood = "Fast",
		BPM = 170,
		Genre = "Pop - Punk - Indo",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { Drum = 0.22, GuitarRhythm = 0.22, GuitarLead = 0.22, Bass = 0.21 },
		DefaultVolumes = {
			Drum = 2,
			Bass = 1.4,
			GuitarLead = 1,
			GuitarRhythm = 2,
			BVocalOnPercent = 20
		},
		Stems = {
			GuitarLead = "rbxassetid://82564135075451",
			GuitarRhythm = "rbxassetid://83277883167344",
			Bass = "rbxassetid://97774369122194",
			Drum = "rbxassetid://81545530305640",
			BVocal = "rbxassetid://121784662344973"
		}
	},
	Cry = {
		DisplayName = "Cry",
		Artist = "CAS",
		Duration = 262,
		Mood = "Slow",
		BPM = 70,
		Genre = "Pop",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { Drum = 0.23, Keyboard = 0.23, GuitarRhythm = 0.23, Bass = 0.23 },
		DefaultVolumes = {
			Drum = 2,
			Bass = 1.4,
			Keyboard = 1,
			GuitarRhythm = 1.3,
			BVocalOnPercent = 20
		},
		Stems = {
			Keyboard = "rbxassetid://82142520678542",
			GuitarRhythm = "rbxassetid://136316336082370",
			Bass = "rbxassetid://74232687555902",
			Drum = "rbxassetid://103403110375480",
			BVocal = "rbxassetid://103403812218763"
		}
	},
	Introvert = {
		DisplayName = "Introvert",
		Artist = "Stand Here Alone",
		Duration = 195,
		Mood = "Fast",
		BPM = 200,
		Genre = "Pop - Punk - Indo",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { Drum = 0.21, GuitarRhythm = 0.21, GuitarLead = 0.21, Bass = 0.21 },
		DefaultVolumes = { Drum = 2, Bass = 1.4, GuitarLead = 1.5, GuitarRhythm = 2.5 },
		Stems = {
			GuitarLead = "rbxassetid://105278935027288",
			GuitarRhythm = "rbxassetid://78472948610950",
			Bass = "rbxassetid://82253833728599",
			Drum = "rbxassetid://114666020218669"
		}
	},
	Dewi = {
		DisplayName = "Dewi",
		Artist = "Threesixty Skatepunk",
		Duration = 256,
		Mood = "Fast",
		BPM = 100,
		Genre = "Pop - Punk - Indo",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { Drum = 0.23, Bass = 0.23, GuitarRhythm = 0.23, GuitarLead = 0.23 },
		DefaultVolumes = {
			Drum = 2.5,
			Bass = 2,
			GuitarLead = 1,
			GuitarRhythm = 1.4,
			BVocalOnPercent = 20
		},
		Stems = {
			GuitarLead = "rbxassetid://89291045043683",
			GuitarRhythm = "rbxassetid://122236335709571",
			Bass = "rbxassetid://125526843763712",
			Drum = "rbxassetid://135243239695482",
			BVocal = "rbxassetid://88875415077599"
		}
	},
	["Bohemian Rhapsody"] = {
		DisplayName = "Bohemian Rhapsody",
		Artist = "Queen",
		Duration = 354,
		Mood = "Chill",
		BPM = 72,
		Genre = "Rock",
		RecommendedPlayers = 6,
		Offset = -0.3,
		InstrumentOffsets = {
			Drum = 0.23,
			Keyboard = 0.23,
			GuitarRhythm = 0.24,
			GuitarLead = 0.23,
			Bass = 0.23,
			Piano = 0.23,
			PianoMIDI = 0.3
		},
		DefaultVolumes = {
			Drum = 2,
			Bass = 1.5,
			Keyboard = 1.5,
			GuitarLead = 1.3,
			GuitarRhythm = 2,
			Piano = 1,
			BVocalOnPercent = 20
		},
		Stems = {
			GuitarLead = "rbxassetid://139143453846630",
			GuitarRhythm = "rbxassetid://106301136934693",
			Bass = "rbxassetid://87123211637532",
			Drum = "rbxassetid://114065673261278",
			Keyboard = "rbxassetid://107774771718435",
			Piano = "rbxassetid://85106361170332",
			BVocal = "rbxassetid://94500626093710"
		}
	},
	["The Winner Takes It All"] = {
		DisplayName = "The Winner Takes It All",
		Artist = "ABBA",
		Duration = 300,
		Mood = "Chill",
		BPM = 72,
		Genre = "Pop",
		RecommendedPlayers = 5,
		Offset = -0.3,
		InstrumentOffsets = {
			Drum = 0.23,
			Keyboard = 0.24,
			GuitarRhythm = 0.23,
			GuitarLead = 0.23,
			Piano = 0.23,
			PianoMIDI = 0.3,
			Bass = 0.23
		},
		DefaultVolumes = {
			Drum = 2,
			Bass = 1,
			Keyboard = 0.7,
			GuitarLead = 0.5,
			GuitarRhythm = 0.5,
			Piano = 1,
			BVocalOnPercent = 20
		},
		Stems = {
			GuitarLead = "rbxassetid://98648749958663",
			GuitarRhythm = "rbxassetid://98648749958663",
			Bass = "rbxassetid://107042168165708",
			Drum = "rbxassetid://118602358518974",
			Keyboard = "rbxassetid://75915524175404",
			Piano = "rbxassetid://107607877688118",
			BVocal = "rbxassetid://115751802588393"
		}
	},
	Helena = {
		DisplayName = "Helena",
		Artist = "My Chemical Romance",
		Duration = 210,
		Mood = "Fast",
		BPM = 126,
		Genre = "Emo",
		RecommendedPlayers = 5,
		Offset = -0.3,
		InstrumentOffsets = {
			Drum = 0.24,
			Keyboard = 0.22,
			GuitarRhythm = 0.22,
			GuitarLead = 0.22,
			Bass = 0.22
		},
		DefaultVolumes = {
			Drum = 1,
			Bass = 1,
			Keyboard = 1,
			GuitarLead = 1,
			GuitarRhythm = 1.5,
			BVocalOnPercent = 20
		},
		Stems = {
			GuitarLead = "rbxassetid://100473891019797",
			GuitarRhythm = "rbxassetid://130919518845760",
			Bass = "rbxassetid://98166471098210",
			Drum = "rbxassetid://135677014870941",
			Keyboard = "rbxassetid://132472620221864",
			BVocal = "rbxassetid://78932604427636"
		}
	},
	["Demolition Lovers"] = {
		DisplayName = "Demolition Lovers",
		Artist = "My Chemical Romance",
		Duration = 372,
		Mood = "Fast",
		BPM = 94,
		Genre = "Emo",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = {
			Drum = 0.23,
			Keyboard = 0.23,
			GuitarRhythm = 0.23,
			GuitarLead = 0.23,
			Piano = 0.23,
			Bass = 0.23
		},
		DefaultVolumes = { Drum = 2, Bass = 1, GuitarLead = 1, GuitarRhythm = 1.5 },
		Stems = {
			GuitarLead = "rbxassetid://129098147071949",
			GuitarRhythm = "rbxassetid://110733376342588",
			Bass = "rbxassetid://135735987737363",
			Drum = "rbxassetid://118662786266413"
		}
	},
	["Unholy Confessions"] = {
		DisplayName = "Unholy Confessions",
		Artist = "Avenged Sevenfold",
		Duration = 281,
		Mood = "Fast",
		BPM = 95,
		Genre = "Metal",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { Drum = 0.23, GuitarRhythm = 0.23, GuitarLead = 0.23, Bass = 0.23 },
		DefaultVolumes = { Drum = 1.5, Bass = 1, GuitarLead = 1, GuitarRhythm = 2 },
		Stems = {
			GuitarLead = "rbxassetid://88440444019063",
			GuitarRhythm = "rbxassetid://113523091019062",
			Bass = "rbxassetid://72662156214450",
			Drum = "rbxassetid://78476721916713"
		}
	},
	["Quiero Sentir tu"] = {
		DisplayName = "Quiero Sentir tu",
		Duration = 173,
		Mood = "Fast",
		BPM = 95,
		Genre = "Grindcore",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { Drum = 0.23, GuitarRhythm = 0.23, GuitarLead = 0.23, Bass = 0.23 },
		DefaultVolumes = { Drum = 1, Bass = 1, GuitarLead = 1, GuitarRhythm = 1 },
		Stems = {
			GuitarLead = "rbxassetid://123363985677962",
			GuitarRhythm = "rbxassetid://121694532376779",
			Bass = "rbxassetid://90883565784782",
			Drum = "rbxassetid://101060304783923"
		}
	},
	Psychosocial = {
		DisplayName = "Psychosocial",
		Artist = "Slipknot",
		Duration = 282,
		Mood = "Fast",
		BPM = 135,
		Genre = "Metal",
		RecommendedPlayers = 5,
		Offset = -0.3,
		InstrumentOffsets = {
			Drum = 0.23,
			GuitarRhythm = 0.23,
			GuitarLead = 0.23,
			Bass = 0.23,
			Keyboard = 0.23
		},
		DefaultVolumes = {
			Drum = 2,
			Bass = 2,
			GuitarLead = 1,
			GuitarRhythm = 2,
			Keyboard = 1
		},
		Stems = {
			GuitarLead = "rbxassetid://131831562382412",
			GuitarRhythm = "rbxassetid://130871170312037",
			Bass = "rbxassetid://89124027764741",
			Drum = "rbxassetid://126902677725212",
			Keyboard = "rbxassetid://125955282740339"
		}
	},
	Duality = {
		DisplayName = "Duality",
		Artist = "Slipknot",
		Duration = 251,
		Mood = "Fast",
		BPM = 145,
		Genre = "Metal - Nu",
		RecommendedPlayers = 5,
		Offset = -0.3,
		InstrumentOffsets = {
			Drum = 0.23,
			GuitarRhythm = 0.23,
			GuitarLead = 0.23,
			Bass = 0.23,
			Piano = 0.23,
			PianoMIDI = 0.3
		},
		DefaultVolumes = {
			Drum = 1,
			Bass = 1,
			GuitarLead = 1,
			GuitarRhythm = 1,
			Piano = 1
		},
		Stems = {
			GuitarLead = "rbxassetid://97729726437854",
			GuitarRhythm = "rbxassetid://78410867304020",
			Bass = "rbxassetid://97319813189044",
			Drum = "rbxassetid://131616160845482",
			Piano = "rbxassetid://75334229956170"
		}
	},
	["Be Gone!"] = {
		DisplayName = "Be Gone!",
		Artist = "Defy",
		Duration = 108,
		Mood = "Fast",
		BPM = 90,
		Genre = "Punk",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { Drum = 0.23, GuitarRhythm = 0.23, GuitarLead = 0.23, Bass = 0.23 },
		DefaultVolumes = { Drum = 2, Bass = 1, GuitarLead = 1, GuitarRhythm = 2 },
		Stems = {
			GuitarLead = "rbxassetid://138697327464796",
			GuitarRhythm = "rbxassetid://133597042233567",
			Bass = "rbxassetid://111815292547124",
			Drum = "rbxassetid://93638092670350"
		}
	},
	Eruption = {
		DisplayName = "Eruption",
		Artist = "Eddie Van Halen",
		Duration = 106,
		Mood = "Fast",
		BPM = 85,
		Genre = "Solo",
		RecommendedPlayers = 1,
		Offset = -0.3,
		InstrumentOffsets = { GuitarRhythm = 0.26, GuitarLead = 0.26 },
		DefaultVolumes = { GuitarLead = 0.6, GuitarRhythm = 1.1, Bass = 2, Drum = 2 },
		Stems = {
			GuitarLead = "rbxassetid://113512060463810",
			GuitarRhythm = "rbxassetid://113512060463810",
			Drum = "rbxassetid://138164978161481",
			Bass = "rbxassetid://137503625327003"
		}
	},
	["Flower Dance"] = {
		DisplayName = "Flower Dance",
		Duration = 205,
		Mood = "Rock",
		BPM = 105,
		Genre = "Punk",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { Drum = 0.23, GuitarRhythm = 0.23, GuitarLead = 0.23, Bass = 0.23 },
		DefaultVolumes = { Drum = 1, Bass = 1, GuitarLead = 0.5, GuitarRhythm = 0.7 },
		Stems = {
			GuitarLead = "rbxassetid://84623172721371",
			GuitarRhythm = "rbxassetid://137829513231658",
			Bass = "rbxassetid://127540900728160",
			Drum = "rbxassetid://100922015710232"
		}
	},
	["Golden Brown"] = {
		DisplayName = "Golden Brown",
		Artist = "The Stranglers",
		Duration = 161,
		Mood = "Rock",
		BPM = 105,
		Genre = "New wave",
		KeyAuraStyle = "Warm",
		RecommendedPlayers = 6,
		Offset = -0.3,
		InstrumentOffsets = {
			Drum = 0.23,
			GuitarRhythm = 0.23,
			GuitarLead = 0.23,
			Bass = 0.23,
			Piano = 0.23,
			PianoMIDI = 0.3,
			Keyboard = 0.23
		},
		DefaultVolumes = {
			Drum = 2,
			Bass = 1,
			GuitarLead = 1,
			GuitarRhythm = 1,
			Piano = 1,
			Keyboard = 2
		},
		Stems = {
			GuitarLead = "rbxassetid://113812997600594",
			GuitarRhythm = "rbxassetid://113812997600594",
			Bass = "rbxassetid://95056176569523",
			Drum = "rbxassetid://85589664674598",
			Piano = "rbxassetid://116689723606856",
			Keyboard = "rbxassetid://78016695609482"
		}
	},
	Virus = {
		DisplayName = "Virus",
		Duration = 227,
		Mood = "Rock",
		BPM = 160,
		Genre = "Rock",
		RecommendedPlayers = 6,
		Offset = -0.3,
		InstrumentOffsets = {
			Drum = 0.23,
			GuitarRhythm = 0.23,
			GuitarLead = 0.23,
			Bass = 0.23,
			Piano = 0.23,
			PianoMIDI = 0.3,
			Keyboard = 0.23
		},
		DefaultVolumes = {
			Drum = 1.5,
			Bass = 1,
			GuitarLead = 1.5,
			GuitarRhythm = 1.6,
			Piano = 1.5,
			Keyboard = 0.95
		},
		Stems = {
			GuitarLead = "rbxassetid://83433921205788",
			GuitarRhythm = "rbxassetid://134590182427887",
			Bass = "rbxassetid://85727101038593",
			Drum = "rbxassetid://95150622629408",
			Piano = "rbxassetid://112558746702088",
			Keyboard = "rbxassetid://78936188292075"
		}
	},
	["Final Duet"] = {
		DisplayName = "Final Duet",
		Artist = "Omori",
		Duration = 130,
		Mood = "Rock",
		BPM = 165,
		Genre = "classical - Waltz",
		KeyAuraStyle = "Warm",
		RecommendedPlayers = 2,
		Offset = -0.3,
		InstrumentOffsets = { Piano = 0.23, Keyboard = 0.23 },
		DefaultVolumes = { Piano = 1, Keyboard = 0.8 },
		Stems = {
			Piano = "rbxassetid://124617225323342",
			Keyboard = "rbxassetid://103632281968458"
		}
	},
	["Smell Then"] = {
		DisplayName = "Smell Then",
		Artist = "Nirvana",
		Duration = 298,
		Mood = "Rock",
		BPM = 113,
		Genre = "Rock - Grunge",
		RecommendedPlayers = 3,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.24, GuitarRhythm = 0.24, Drum = 0.24, Bass = 0.21 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1, Drum = 1.5, Bass = 2 },
		Stems = {
			GuitarLead = "rbxassetid://140450436504946",
			GuitarRhythm = "rbxassetid://140450436504946",
			Bass = "rbxassetid://86169906497063",
			Drum = "rbxassetid://130790117892605"
		}
	},
	Breed = {
		DisplayName = "Breed",
		Artist = "Nirvana",
		Duration = 186,
		Mood = "Rock",
		BPM = 159,
		Genre = "Rock - Grunge",
		RecommendedPlayers = 3,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.23, GuitarRhythm = 0.23, Drum = 0.23, Bass = 0.23 },
		DefaultVolumes = { GuitarLead = 1.5, GuitarRhythm = 1.5, Drum = 3, Bass = 4 },
		Stems = {
			GuitarLead = "rbxassetid://104747332059699",
			GuitarRhythm = "rbxassetid://104747332059699",
			Bass = "rbxassetid://130618422006399",
			Drum = "rbxassetid://117791699390495"
		}
	},
	["Come As You Are"] = {
		DisplayName = "Come As You Are",
		Artist = "Nirvana",
		Duration = 217,
		Mood = "Rock",
		BPM = 120,
		Genre = "Rock - Grunge",
		RecommendedPlayers = 3,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.23, GuitarRhythm = 0.23, Drum = 0.23, Bass = 0.23 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1, Drum = 3, Bass = 2 },
		Stems = {
			GuitarLead = "rbxassetid://73360958794677",
			GuitarRhythm = "rbxassetid://73360958794677",
			Bass = "rbxassetid://78864344324981",
			Drum = "rbxassetid://80759480963456"
		}
	},
	["Time Bomb"] = {
		DisplayName = "Time Bomb",
		Artist = "Rancid",
		Duration = 146,
		Mood = "Punk",
		BPM = 83,
		Genre = "Punk - SKA",
		RecommendedPlayers = 5,
		Offset = -0.3,
		InstrumentOffsets = {
			GuitarLead = 0.25,
			GuitarRhythm = 0.25,
			Drum = 0.25,
			Bass = 0.25,
			Keyboard = 0.25
		},
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1, Drum = 1, Bass = 1 },
		Stems = {
			GuitarLead = "rbxassetid://89310616174075",
			GuitarRhythm = "rbxassetid://108186926569063",
			Bass = "rbxassetid://120624024976849",
			Drum = "rbxassetid://84220963585525",
			Keyboard = "rbxassetid://138698979356860"
		}
	},
	["Negri Ngeri"] = {
		DisplayName = "Negri Ngeri",
		Artist = "Marjinal",
		Duration = 283,
		Mood = "Punk",
		BPM = 140,
		Genre = "Rock - Rock - Indo",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.23, GuitarRhythm = 0.21, Drum = 0.25, Bass = 0.21 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 2.5, Drum = 1, Bass = 1 },
		Stems = {
			GuitarLead = "rbxassetid://124117599490564",
			GuitarRhythm = "rbxassetid://84865539405700",
			Bass = "rbxassetid://108020524362282",
			Drum = "rbxassetid://86095907969849"
		}
	},
	Tersimpan = {
		DisplayName = "Tersimpan",
		Artist = "Our Story",
		Duration = 248,
		Mood = "Punk",
		BPM = 230,
		Genre = "Punk - Pop - Indo",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.24, GuitarRhythm = 0.24, Drum = 0.24, Bass = 0.24 },
		DefaultVolumes = {
			GuitarLead = 1,
			GuitarRhythm = 2.5,
			Drum = 1,
			Bass = 1,
			BVocal = 1
		},
		Stems = {
			GuitarLead = "rbxassetid://125501899941465",
			GuitarRhythm = "rbxassetid://90734557215614",
			Bass = "rbxassetid://74718899577134",
			Drum = "rbxassetid://128629059410319",
			BVocal = "rbxassetid://128567626009737"
		}
	},
	["Tourette's"] = {
		DisplayName = "Tourette's",
		Artist = "Nirvana",
		Duration = 92,
		Mood = "Rock",
		BPM = 173,
		Genre = "Rock - Grunge",
		RecommendedPlayers = 3,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.23, GuitarRhythm = 0.23, Drum = 0.24, Bass = 0.23 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1, Drum = 2, Bass = 2 },
		Stems = {
			GuitarLead = "rbxassetid://127228129026125",
			GuitarRhythm = "rbxassetid://127228129026125",
			Bass = "rbxassetid://87879148176623",
			Drum = "rbxassetid://77061591408617"
		}
	},
	Solfeggietto = {
		DisplayName = "Solfeggietto",
		Artist = "At Vance",
		Duration = 60,
		Mood = "Rock",
		BPM = 140,
		Genre = "Rock - Classical",
		RecommendedPlayers = 1,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.23, GuitarRhythm = 0.23 },
		DefaultVolumes = { GuitarLead = 0.5, GuitarRhythm = 1 },
		Stems = {
			GuitarLead = "rbxassetid://132380262823282",
			GuitarRhythm = "rbxassetid://132380262823282"
		}
	},
	["Through the Fire and Flames"] = {
		DisplayName = "Through the Fire and Flames",
		Artist = "DragonForce",
		Duration = 441.84,
		Genre = "Metal",
		RecommendedPlayers = 5,
		Offset = -0.3,
		InstrumentOffsets = {
			GuitarLead = 0.25,
			GuitarRhythm = 0.25,
			Bass = 0.23,
			Drum = 0.23,
			Keyboard = 0.23
		},
		DefaultVolumes = {
			GuitarLead = 1.2,
			GuitarRhythm = 1.2,
			Bass = 1.2,
			Drum = 1.7,
			Keyboard = 1.2
		},
		Stems = {
			GuitarLead = "rbxassetid://133978330337478",
			GuitarRhythm = "rbxassetid://80933436305260",
			Bass = "rbxassetid://95308509261485",
			Drum = "rbxassetid://115619577897402",
			Keyboard = "rbxassetid://89837748055060"
		},
		Segments = {
			GuitarLead = {
				PartA = "rbxassetid://133978330337478",
				PartB = "rbxassetid://120634058553146",
				SplicePoint = 145.032
			},
			GuitarRhythm = {
				PartA = "rbxassetid://80933436305260",
				PartB = "rbxassetid://91068164146238",
				SplicePoint = 145.032
			},
			Bass = {
				PartA = "rbxassetid://95308509261485",
				PartB = "rbxassetid://95791142303491",
				SplicePoint = 145.032
			},
			Drum = {
				PartA = "rbxassetid://115619577897402",
				PartB = "rbxassetid://111250858842801",
				SplicePoint = 145.032
			},
			Keyboard = {
				PartA = "rbxassetid://89837748055060",
				PartB = "rbxassetid://81248576123220",
				SplicePoint = 145.032
			}
		}
	},
	["Universal Mind / YYZ"] = {
		DisplayName = "Universal Mind / YYZ",
		Artist = "Liquid Tension Experiment",
		Duration = 469,
		Mood = "Fast",
		BPM = 157,
		Genre = "Metal - Progressive",
		RecommendedPlayers = 6,
		Offset = -0.3,
		InstrumentOffsets = {
			GuitarLead = 0.25,
			GuitarRhythm = 0.25,
			Bass = 0.23,
			Drum = 0.23,
			Keyboard = 0.23,
			Piano = 0.23
		},
		DefaultVolumes = {
			GuitarLead = 1.2,
			GuitarRhythm = 1.4,
			Bass = 1.2,
			Drum = 1.3,
			Keyboard = 1.4,
			Piano = 1.2
		},
		Stems = {
			GuitarLead = "rbxassetid://98264829764422",
			GuitarRhythm = "rbxassetid://96283657245381",
			Bass = "rbxassetid://98845268217538",
			Drum = "rbxassetid://106071493486981",
			Keyboard = "rbxassetid://86271324513732",
			Piano = "rbxassetid://86277096670370"
		},
		Segments = {
			GuitarLead = {
				PartA = "rbxassetid://98264829764422",
				PartB = "rbxassetid://140405314125823",
				SplicePoint = 242.96417
			},
			GuitarRhythm = {
				PartA = "rbxassetid://96283657245381",
				PartB = "rbxassetid://134915796201631",
				SplicePoint = 242.96417
			},
			Bass = {
				PartA = "rbxassetid://98845268217538",
				PartB = "rbxassetid://112351920218052",
				SplicePoint = 242.96417
			},
			Drum = {
				PartA = "rbxassetid://106071493486981",
				PartB = "rbxassetid://103666023015415",
				SplicePoint = 242.96417
			},
			Keyboard = {
				PartA = "rbxassetid://86271324513732",
				PartB = "rbxassetid://110404128102298",
				SplicePoint = 242.96417
			},
			Piano = {
				PartA = "rbxassetid://86277096670370",
				PartB = "rbxassetid://103648775976868",
				SplicePoint = 242.96417
			}
		}
	},
	Freebird = {
		DisplayName = "Freebird",
		Artist = "Lynyrd Skynyrd",
		Duration = 605,
		Mood = "Rock",
		BPM = 56,
		Genre = "Rock - Southern",
		RecommendedPlayers = 6,
		Offset = -0.3,
		InstrumentOffsets = {
			GuitarLead = 0.25,
			GuitarRhythm = 0.25,
			Bass = 0.25,
			Drum = 0.25,
			Keyboard = 0.25,
			Piano = 0.25
		},
		DefaultVolumes = {
			GuitarLead = 1.3,
			GuitarRhythm = 1.5,
			Bass = 1.3,
			Drum = 1.4,
			Keyboard = 1.2,
			Piano = 1.2
		},
		Stems = {
			GuitarLead = "rbxassetid://109591637903711",
			GuitarRhythm = "rbxassetid://71001753728670",
			Bass = "rbxassetid://108714724935819",
			Drum = "rbxassetid://129763665561987",
			Keyboard = "rbxassetid://128685856931244",
			Piano = "rbxassetid://124759961697125"
		},
		Segments = {
			GuitarLead = {
				PartA = "rbxassetid://109591637903711",
				PartB = "rbxassetid://74417393956490",
				SplicePoint = 295.69057
			},
			GuitarRhythm = {
				PartA = "rbxassetid://71001753728670",
				PartB = "rbxassetid://75889620971704",
				SplicePoint = 295.69057
			},
			Bass = {
				PartA = "rbxassetid://108714724935819",
				PartB = "rbxassetid://90848569385710",
				SplicePoint = 295.69057
			},
			Drum = {
				PartA = "rbxassetid://129763665561987",
				PartB = "rbxassetid://114293171947543",
				SplicePoint = 295.69057
			},
			Keyboard = {
				PartA = "rbxassetid://128685856931244",
				PartB = "rbxassetid://75046387290143",
				SplicePoint = 295.69057
			},
			Piano = {
				PartA = "rbxassetid://124759961697125",
				PartB = "rbxassetid://132313225353683",
				SplicePoint = 295.69057
			}
		}
	},
	Always = {
		DisplayName = "Always",
		Artist = "Bon Jovi",
		Duration = 340,
		Mood = "Slow",
		BPM = 72,
		Genre = "Rock - Soft",
		RecommendedPlayers = 6,
		Offset = -0.3,
		InstrumentOffsets = {
			GuitarLead = 0.24,
			GuitarRhythm = 0.23,
			Drum = 0.23,
			Bass = 0.24,
			Piano = 0.24,
			Keyboard = 0.24
		},
		DefaultVolumes = {
			GuitarLead = 1,
			GuitarRhythm = 1,
			Drum = 5,
			Bass = 0.9,
			Keyboard = 1.2,
			Piano = 0.9
		},
		Stems = {
			GuitarLead = "rbxassetid://117140425139337",
			GuitarRhythm = "rbxassetid://71787060366236",
			Bass = "rbxassetid://87999128133659",
			Drum = "rbxassetid://99178935353543",
			Keyboard = "rbxassetid://86123876352747",
			Piano = "rbxassetid://128193931481974"
		}
	},
	["Cliffs Of Dover"] = {
		DisplayName = "Cliffs Of Dover",
		Artist = "Eric Johnson",
		Duration = 243,
		Mood = "Rock",
		BPM = 173,
		Genre = "Rock - Instrumental",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.23, GuitarRhythm = 0.23, Drum = 0.24, Bass = 0.23 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1, Drum = 1, Bass = 1 },
		Stems = {
			GuitarLead = "rbxassetid://115893023135154",
			GuitarRhythm = "rbxassetid://115893023135154",
			Bass = "rbxassetid://100717750415283",
			Drum = "rbxassetid://136607698947606"
		}
	},
	["The World Is Mine"] = {
		DisplayName = "The World Is Mine",
		Artist = "KnuckleSandwich & ABOMINATE",
		Duration = 209,
		Mood = "Fast",
		BPM = 140,
		Genre = "Metal - Hardcore",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.23, GuitarRhythm = 0.23, Drum = 0.24, Bass = 0.23 },
		DefaultVolumes = { GuitarLead = 1.2, GuitarRhythm = 1, Drum = 1.2, Bass = 1 },
		Stems = {
			GuitarLead = "rbxassetid://114032151914310",
			GuitarRhythm = "rbxassetid://114032151914310",
			Bass = "rbxassetid://123598709746289",
			Drum = "rbxassetid://79609657470700"
		}
	},
	["Summon Of Baekdu"] = {
		DisplayName = "Summon Of Baekdu",
		Artist = "구룡 (Kuryong)",
		Duration = 208,
		Mood = "Fast",
		BPM = 180,
		Genre = "Black Metal - Raw",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.24, GuitarRhythm = 0.24, Drum = 0.24, Bass = 0.24 },
		DefaultVolumes = { GuitarLead = 1.5, GuitarRhythm = 2.5, Drum = 1, Bass = 1.9 },
		Stems = {
			GuitarLead = "rbxassetid://76679403839038",
			GuitarRhythm = "rbxassetid://75932386827465",
			Bass = "rbxassetid://74509805002213",
			Drum = "rbxassetid://140668881713160"
		}
	},
	["Still Loving You"] = {
		DisplayName = "Still Loving You",
		Artist = "Scorpions",
		Duration = 410,
		Mood = "Slow",
		BPM = 103,
		Genre = "Rock - Hard",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.25, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1, Drum = 1, Bass = 1 },
		Stems = {
			GuitarLead = "rbxassetid://78437105834159",
			GuitarRhythm = "rbxassetid://132455776799911",
			Bass = "rbxassetid://107571935774900",
			Drum = "rbxassetid://130590261715381"
		}
	},
	["The Burden"] = {
		DisplayName = "The Burden",
		Artist = "ENCRYPTED*",
		Duration = 225,
		Mood = "Fast",
		BPM = 144,
		Genre = "Metal - thrash",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.26, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1.4, Drum = 1, Bass = 1 },
		Stems = {
			GuitarLead = "rbxassetid://115493631356778",
			GuitarRhythm = "rbxassetid://124712245917613",
			Bass = "rbxassetid://136272074997758",
			Drum = "rbxassetid://129071443719580"
		}
	},
	["Where Dead Angels Lie"] = {
		DisplayName = "Where Dead Angels Lie",
		Artist = "Dissection",
		Duration = 363,
		Mood = "Fast",
		BPM = 80,
		Genre = "Black Metal - Melodic",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.26, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1, Drum = 1, Bass = 1 },
		Stems = {
			GuitarLead = "rbxassetid://103984852354164",
			GuitarRhythm = "rbxassetid://101016613410431",
			Bass = "rbxassetid://118518419009130",
			Drum = "rbxassetid://101451467790564"
		}
	},
	["Siege Tower"] = {
		DisplayName = "Siege Tower",
		Artist = "Curta'n Wall",
		Duration = 163,
		Mood = "Fast",
		BPM = 125,
		Genre = "Black Metal - Raw",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.26, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 2, Drum = 1.5, Bass = 1 },
		Stems = {
			GuitarLead = "rbxassetid://101715212780218",
			GuitarRhythm = "rbxassetid://93436230425791",
			Bass = "rbxassetid://122750629551463",
			Drum = "rbxassetid://79748825666227"
		}
	},
	["Roots Bloody Roots"] = {
		DisplayName = "Roots Bloody Roots",
		Artist = "Sepultura",
		Duration = 210,
		Mood = "Fast",
		BPM = 120,
		Genre = "Metal - Groove",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.26, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1.5, Drum = 1, Bass = 1 },
		Stems = {
			GuitarLead = "rbxassetid://101324642165798",
			GuitarRhythm = "rbxassetid://102288407612656",
			Bass = "rbxassetid://82380729237423",
			Drum = "rbxassetid://82840394742206"
		}
	},
	Necrolus = {
		DisplayName = "Necrolus",
		Artist = "Mayhem",
		Duration = 233,
		Mood = "Fast",
		BPM = 101,
		Genre = "Black Metal",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.26, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1, Drum = 1, Bass = 1 },
		Stems = {
			GuitarLead = "rbxassetid://93478905108540",
			GuitarRhythm = "rbxassetid://0",
			Bass = "rbxassetid://114955093873821",
			Drum = "rbxassetid://130752544396173"
		}
	},
	["Lost Wisdom"] = {
		DisplayName = "Lost Wisdom",
		Artist = "Burzum",
		Duration = 273,
		Mood = "Fast",
		BPM = 138,
		Genre = "Black Metal",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.26, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1.5, Drum = 1.2, Bass = 1.2 },
		Stems = {
			GuitarLead = "rbxassetid://123677867479703",
			GuitarRhythm = "rbxassetid://136247522432838",
			Bass = "rbxassetid://87354062203290",
			Drum = "rbxassetid://131146034913120"
		}
	},
	["Freezing Moon"] = {
		DisplayName = "Freezing Moon",
		Artist = "Mayhem",
		Duration = 387,
		Mood = "Fast",
		BPM = 98,
		Genre = "Black Metal",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.26, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1.5, Drum = 1, Bass = 1 },
		Stems = {
			GuitarLead = "rbxassetid://124995655365968",
			GuitarRhythm = "rbxassetid://138561865905921",
			Bass = "rbxassetid://123945027524147",
			Drum = "rbxassetid://83265776425887"
		}
	},
	["Fear Of God"] = {
		DisplayName = "Fear Of God",
		Artist = "Curta'n Wall",
		Duration = 131,
		Mood = "Fast",
		BPM = 115,
		Genre = "Black Metal - Raw",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = {
			GuitarLead = 0.26,
			GuitarRhythm = 0.25,
			Drum = 0.25,
			Bass = 0.25,
			Keyboard = 1
		},
		DefaultVolumes = {
			GuitarLead = 1,
			GuitarRhythm = 1.5,
			Drum = 1.5,
			Bass = 1,
			Keyboard = 1
		},
		Stems = {
			GuitarLead = "rbxassetid://113834031023760",
			GuitarRhythm = "rbxassetid://113834031023760",
			Bass = "rbxassetid://134828224141099",
			Drum = "rbxassetid://138475037480243",
			Keyboard = "rbxassetid://86550514909304"
		}
	},
	["Follow The Signs"] = {
		DisplayName = "Follow The Signs",
		Artist = "Born of Osiris",
		Duration = 234,
		Mood = "Fast",
		BPM = 240,
		Genre = "Deathcore - Progressive",
		RecommendedPlayers = 5,
		Offset = -0.3,
		InstrumentOffsets = {
			GuitarLead = 0.26,
			GuitarRhythm = 0.25,
			Drum = 0.25,
			Bass = 0.25,
			Keyboard = 1
		},
		DefaultVolumes = {
			GuitarLead = 1,
			GuitarRhythm = 1,
			Drum = 1,
			Bass = 1,
			Keyboard = 1
		},
		Stems = {
			GuitarLead = "rbxassetid://126115846389219",
			GuitarRhythm = "rbxassetid://131284639990344",
			Bass = "rbxassetid://128240968471623",
			Drum = "rbxassetid://115092308348545",
			Keyboard = "rbxassetid://97432863811507"
		}
	},
	["7 Words"] = {
		DisplayName = "7 Words",
		Artist = "Defones",
		Duration = 235,
		Mood = "Fast",
		BPM = 114,
		Genre = "Metal - Nu",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.26, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 0.8, GuitarRhythm = 1.5, Drum = 1, Bass = 1 },
		Stems = {
			GuitarLead = "rbxassetid://101864334882668",
			GuitarRhythm = "rbxassetid://101864334882668",
			Bass = "rbxassetid://84567161825244",
			Drum = "rbxassetid://97266193656030"
		}
	},
	Thunderstruck = {
		DisplayName = "Thunderstruck",
		Artist = "AC/DC",
		Duration = 296,
		Mood = "Fast",
		BPM = 134,
		Genre = "Rock - Hard",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.26, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1, Drum = 1, Bass = 1 },
		Stems = {
			GuitarLead = "rbxassetid://105599134222331",
			GuitarRhythm = "rbxassetid://118266616320593",
			Bass = "rbxassetid://97059469147955",
			Drum = "rbxassetid://97509011711969"
		}
	},
	["Always Somewhere"] = {
		DisplayName = "Always Somewhere",
		Artist = "Scorpions",
		Duration = 290,
		Mood = "Slow",
		BPM = 138,
		Genre = "Rock - Ballad",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.26, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1, Drum = 1, Bass = 1 },
		Stems = {
			GuitarLead = "rbxassetid://93735844481907",
			GuitarRhythm = "rbxassetid://90858591705966",
			Bass = "rbxassetid://99016655556653",
			Drum = "rbxassetid://0"
		}
	},
	American = {
		DisplayName = "American",
		Artist = "Greenday",
		Duration = 177,
		Mood = "Fast",
		BPM = 186,
		Genre = "Punk - POP",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.26, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1, Drum = 1, Bass = 1 },
		Stems = {
			GuitarLead = "rbxassetid://109422333430504",
			GuitarRhythm = "rbxassetid://98310159145172",
			Bass = "rbxassetid://116377736154201",
			Drum = "rbxassetid://96389089876106"
		}
	},
	["Basket Case"] = {
		DisplayName = "Basket Case",
		Artist = "Greenday",
		Duration = 179,
		Mood = "Fast",
		BPM = 186,
		Genre = "Punk - POP",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.26, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 0.5, GuitarRhythm = 1, Drum = 1, Bass = 1 },
		Stems = {
			GuitarLead = "rbxassetid://94253652162855",
			GuitarRhythm = "rbxassetid://94253652162855",
			Bass = "rbxassetid://93142597055993",
			Drum = "rbxassetid://72494719620387"
		}
	},
	["Caprici Di Diablo"] = {
		DisplayName = "Caprici Di Diablo",
		Artist = "Yngwie Malmsteen",
		Duration = 272,
		Mood = "Fast",
		BPM = 160,
		Genre = "Rock - Classical",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.26, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = {
			GuitarLead = 1,
			GuitarRhythm = 1.4,
			Drum = 1,
			Bass = 1.5,
			Keyboard = 2
		},
		Stems = {
			GuitarLead = "rbxassetid://128011279528959",
			GuitarRhythm = "rbxassetid://128011279528959",
			Bass = "rbxassetid://120629112748982",
			Drum = "rbxassetid://98187042067435",
			Keyboard = "rbxassetid://111821471760408"
		}
	},
	["Smells teen (Live At Reading)"] = {
		DisplayName = "Smells teen (Live At Reading)",
		Artist = "Nirvana",
		Duration = 332,
		Mood = "Fast",
		BPM = 125,
		Genre = "Punk",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.26, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 0.8, GuitarRhythm = 1.3, Drum = 1.3, Bass = 1.3 },
		Stems = {
			GuitarLead = "rbxassetid://133519452226436",
			GuitarRhythm = "rbxassetid://133519452226436",
			Bass = "rbxassetid://130548441032731",
			Drum = "rbxassetid://117714000715054"
		}
	},
	["Cherry Waves"] = {
		DisplayName = "Cherry Waves",
		Artist = "Deftones",
		Duration = 319,
		Mood = "Fast",
		BPM = 138,
		Genre = "shoegaze",
		RecommendedPlayers = 5,
		Offset = -0.3,
		InstrumentOffsets = {
			GuitarLead = 0.26,
			GuitarRhythm = 0.25,
			Drum = 0.25,
			Bass = 0.25,
			Keyboard = 0.25
		},
		DefaultVolumes = {
			GuitarLead = 1,
			GuitarRhythm = 1,
			Drum = 1,
			Bass = 1,
			Keyboard = 1
		},
		Stems = {
			GuitarLead = "rbxassetid://72055592268039",
			GuitarRhythm = "rbxassetid://105141711466260",
			Bass = "rbxassetid://116323478474055",
			Drum = "rbxassetid://0",
			Keyboard = "rbxassetid://118023419531897"
		}
	},
	["El Guardián de la Luz"] = {
		DisplayName = "El Guardián de la Luz",
		Artist = "Rata Blanca",
		Duration = 372,
		Mood = "Fast",
		BPM = 143,
		Genre = "Metal - Heavy",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = {
			GuitarLead = 0.25,
			GuitarRhythm = 0.25,
			Drum = 0.25,
			Bass = 0.25,
			Keyboard = 0.25
		},
		DefaultVolumes = {
			GuitarLead = 1,
			GuitarRhythm = 1,
			Drum = 1,
			Bass = 1,
			Keyboard = 1
		},
		Stems = {
			GuitarLead = "rbxassetid://90858794760799",
			GuitarRhythm = "rbxassetid://0",
			Bass = "rbxassetid://100168657697119",
			Drum = "rbxassetid://0",
			Keyboard = "rbxassetid://115571012584212"
		}
	},
	Attitude = {
		DisplayName = "Attitude",
		Artist = "Sepultura",
		Duration = 262,
		Mood = "Fast",
		BPM = 150,
		Genre = "Metal - Groove",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = {
			GuitarLead = 0.26,
			GuitarRhythm = 0.25,
			Drum = 0.25,
			Bass = 0.25,
			Keyboard = 0.25
		},
		DefaultVolumes = {
			GuitarLead = 1,
			GuitarRhythm = 1,
			Drum = 1,
			Bass = 1,
			Keyboard = 1
		},
		Stems = {
			GuitarLead = "rbxassetid://0",
			GuitarRhythm = "rbxassetid://112012233007461",
			Bass = "rbxassetid://78656042041393",
			Drum = "rbxassetid://117341162946291",
			Keyboard = "rbxassetid://0"
		}
	},
	["B.Y.O.B"] = {
		DisplayName = "B.Y.O.B",
		Artist = "System Of A Down",
		Duration = 263,
		Mood = "Fast",
		BPM = 162,
		Genre = "Metal - Nu",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.26, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 1.4, GuitarRhythm = 1.5, Drum = 1.4, Bass = 1.3 },
		Stems = {
			GuitarLead = "rbxassetid://124324756460405",
			GuitarRhythm = "rbxassetid://124324756460405",
			Bass = "rbxassetid://88435854777800",
			Drum = "rbxassetid://115395421817824"
		}
	},
	Domination = {
		DisplayName = "Domination",
		Artist = "Pantera",
		Duration = 308,
		Mood = "Fast",
		BPM = 140,
		Genre = "Metal - Groove",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.26, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 2, GuitarRhythm = 2.3, Drum = 1.3, Bass = 2 },
		Stems = {
			GuitarLead = "rbxassetid://71886314377714",
			GuitarRhythm = "rbxassetid://134549038285186",
			Bass = "rbxassetid://105870622147964",
			Drum = "rbxassetid://133814130422570"
		}
	},
	Eeyore = {
		DisplayName = "Eeyore",
		Artist = "Slipknot",
		Duration = 158,
		Mood = "Fast",
		BPM = 244,
		Genre = "Metal - Nu",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.26, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 1.2, GuitarRhythm = 1.3, Drum = 1.3, Bass = 1.3 },
		Stems = {
			GuitarLead = "rbxassetid://93090448072897",
			GuitarRhythm = "rbxassetid://95974957381065",
			Bass = "rbxassetid://140323940962726",
			Drum = "rbxassetid://94493932231670"
		}
	},
	["Enter Sandman"] = {
		DisplayName = "Enter Sandman",
		Artist = "Metallica",
		Duration = 343,
		Mood = "Fast",
		BPM = 123,
		Genre = "Metal - Heavy",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.25, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 1.2, GuitarRhythm = 1.2, Drum = 1, Bass = 1.2 },
		Stems = {
			GuitarLead = "rbxassetid://94519201109669",
			GuitarRhythm = "rbxassetid://80672339935827",
			Bass = "rbxassetid://83925936638788",
			Drum = "rbxassetid://106479883415046"
		}
	},
	["Goo Goo Muck"] = {
		DisplayName = "Goo Goo Muck",
		Artist = "The Cramps",
		Duration = 186,
		Mood = "Fast",
		BPM = 142,
		Genre = "Punk - Horror",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.25, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 1.1, GuitarRhythm = 1.2, Drum = 1.2 },
		Stems = {
			GuitarLead = "rbxassetid://72895340517615",
			GuitarRhythm = "rbxassetid://79213325470417",
			Drum = "rbxassetid://83332241065557"
		}
	},
	["Hotel California"] = {
		DisplayName = "Hotel California",
		Artist = "Eagles",
		Duration = 403,
		Mood = "Fast",
		BPM = 73,
		Genre = "Rock - Soft",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.26, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 0.85, GuitarRhythm = 1.2, Drum = 1.2, Bass = 1.2 },
		Stems = {
			GuitarLead = "rbxassetid://93298406586716",
			GuitarRhythm = "rbxassetid://95425155160272",
			Bass = "rbxassetid://102205907578987",
			Drum = "rbxassetid://75489670353434"
		}
	},
	Ignorance = {
		DisplayName = "Ignorance",
		Artist = "Paramore",
		Duration = 233,
		Mood = "Fast",
		BPM = 171,
		Genre = "Punk - Pop",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.25, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 0.9, GuitarRhythm = 1.2, Drum = 1.2, Bass = 1.2 },
		Stems = {
			GuitarLead = "rbxassetid://86313850998157",
			GuitarRhythm = "rbxassetid://85643876080008",
			Bass = "rbxassetid://82332451198396",
			Drum = "rbxassetid://114015851210981"
		}
	},
	["Lepaskan Diriku"] = {
		DisplayName = "Lepaskan Diriku",
		Artist = "J-ROCK",
		Duration = 240,
		Mood = "Fast",
		BPM = 160,
		Genre = "Rock - Pop",
		RecommendedPlayers = 5,
		Offset = -0.3,
		InstrumentOffsets = {
			GuitarLead = 0.25,
			GuitarRhythm = 0.25,
			Drum = 0.25,
			Bass = 0.25,
			Keyboard = 0.25
		},
		DefaultVolumes = {
			GuitarLead = 1,
			GuitarRhythm = 1.3,
			Drum = 1.2,
			Bass = 1,
			BVocalOnPercent = 20,
			Keyboard = 1.1
		},
		Stems = {
			GuitarLead = "rbxassetid://87545606777950",
			GuitarRhythm = "rbxassetid://92140343485155",
			Bass = "rbxassetid://91257107496467",
			Drum = "rbxassetid://106169905048204",
			Keyboard = "rbxassetid://111175156478842",
			BVocal = "rbxassetid://134138041420917"
		}
	},
	["Misery Business"] = {
		DisplayName = "Misery Business",
		Artist = "Paramore",
		Duration = 203,
		Mood = "Fast",
		BPM = 173,
		Genre = "Punk - Pop",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.25, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1, Drum = 1, Bass = 1 },
		Stems = {
			GuitarLead = "rbxassetid://124324756460405",
			GuitarRhythm = "rbxassetid://81001582621171",
			Bass = "rbxassetid://102436887459821",
			Drum = "rbxassetid://115395421817824"
		}
	},
	["Moonlight Sonata - 3rd Movement"] = {
		DisplayName = "Moonlight Sonata - 3rd Movement",
		Artist = "Beethoven",
		Duration = 359,
		Mood = "Fast",
		BPM = 174,
		Genre = "Rock - Classical",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.25, GuitarRhythm = 0.25, Drum = 0.25, Bass = 0.25 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1.3, Drum = 1, Bass = 1.3 },
		Stems = {
			GuitarLead = "rbxassetid://134067575646166",
			GuitarRhythm = "rbxassetid://129872168672357",
			Bass = "rbxassetid://99091762810761",
			Drum = "rbxassetid://80401445957141"
		}
	},
	["My Own Summer (Shove It)"] = {
		DisplayName = "My Own Summer (Shove It)",
		Artist = "Deftones",
		Duration = 221,
		Mood = "Fast",
		BPM = 72,
		Genre = "Metal - Nu",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = {
			GuitarLead = 0.26,
			GuitarRhythm = 0.25,
			Drum = 0.25,
			Bass = 0.25,
			Keyboard = 0.25
		},
		DefaultVolumes = {
			GuitarLead = 1.2,
			GuitarRhythm = 1.2,
			Drum = 1.2,
			Bass = 1.2,
			Keyboard = 1
		},
		Stems = {
			GuitarLead = "rbxassetid://127768193545555",
			GuitarRhythm = "rbxassetid://109184846560730",
			Bass = "rbxassetid://79686173352795",
			Drum = "rbxassetid://102105932842311",
			Keyboard = "rbxassetid://108430313959841"
		}
	},
	Pandora = {
		DisplayName = "Pandora",
		Artist = "Wisp",
		Duration = 229,
		Mood = "Fast",
		BPM = 72,
		Genre = "Shoegaze",
		RecommendedPlayers = 5,
		Offset = -0.3,
		InstrumentOffsets = {
			GuitarLead = 0.26,
			GuitarRhythm = 0.25,
			Drum = 0.25,
			Bass = 0.25,
			Keyboard = 0.25
		},
		DefaultVolumes = {
			GuitarLead = 0.7,
			GuitarRhythm = 1,
			Drum = 1,
			Bass = 1,
			Keyboard = 0.7
		},
		Stems = {
			GuitarLead = "rbxassetid://102134728648306",
			GuitarRhythm = "rbxassetid://79867040786951",
			Bass = "rbxassetid://139414811323459",
			Drum = "rbxassetid://114605309541537",
			Keyboard = "rbxassetid://92067527638682"
		}
	},
	["Handel's Passacaglia"] = {
		DisplayName = "Handel's Passacaglia",
		Artist = "George Frideric Handel",
		Duration = 311,
		Mood = "Fast",
		BPM = 110,
		Genre = "Rock - Classical",
		RecommendedPlayers = 5,
		Offset = -0.3,
		InstrumentOffsets = {
			GuitarLead = 0.26,
			GuitarRhythm = 0.25,
			Drum = 0.25,
			Bass = 0.25,
			Keyboard = 0.25
		},
		DefaultVolumes = {
			GuitarLead = 1.1,
			GuitarRhythm = 1.3,
			Drum = 1,
			Bass = 1,
			Keyboard = 0.4
		},
		Stems = {
			GuitarLead = "rbxassetid://91975594857563",
			GuitarRhythm = "rbxassetid://137558760486026",
			Bass = "rbxassetid://132886964163749",
			Drum = "rbxassetid://75402535005320",
			Keyboard = "rbxassetid://95306135177355"
		}
	},
	SIC = {
		DisplayName = "SIC",
		Artist = "Slipknot",
		Duration = 203,
		Mood = "Fast",
		BPM = 192,
		Genre = "Metal - Nu",
		RecommendedPlayers = 5,
		Offset = -0.3,
		InstrumentOffsets = {
			GuitarLead = 0.26,
			GuitarRhythm = 0.25,
			Drum = 0.25,
			Bass = 0.25,
			Keyboard = 0.25
		},
		DefaultVolumes = {
			GuitarLead = 1,
			GuitarRhythm = 1,
			Drum = 1,
			Bass = 1,
			Keyboard = 0.7
		},
		Stems = {
			GuitarLead = "rbxassetid://93332439422140",
			GuitarRhythm = "rbxassetid://0",
			Bass = "rbxassetid://133587438389942",
			Drum = "rbxassetid://109308937701765",
			Keyboard = "rbxassetid://106931139100842"
		}
	},
	["Stand By Me"] = {
		DisplayName = "Stand By Me",
		Artist = "Oasis",
		Duration = 356,
		Mood = "Slow",
		BPM = 72,
		Genre = "Rock - BritPop",
		RecommendedPlayers = 5,
		Offset = -0.3,
		InstrumentOffsets = {
			GuitarLead = 0.26,
			GuitarRhythm = 0.25,
			Drum = 0.25,
			Bass = 0.25,
			Keyboard = 0.25,
			Piano = 0.25
		},
		DefaultVolumes = {
			GuitarLead = 1,
			GuitarRhythm = 1,
			Drum = 1,
			Bass = 1,
			Keyboard = 1,
			Piano = 1
		},
		Stems = {
			GuitarLead = "rbxassetid://86781570383919",
			GuitarRhythm = "rbxassetid://0",
			Bass = "rbxassetid://75035582524492",
			Drum = "rbxassetid://93419671918584",
			Keyboard = "rbxassetid://134205149968634",
			Piano = "rbxassetid://105431682377268"
		}
	},
	Passacaglia = {
		DisplayName = "Passacaglia",
		Artist = "George Frideric Handel",
		Duration = 116,
		Mood = "Fast",
		BPM = 160,
		Genre = "Rock - Classical",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.25, GuitarRhythm = 0.25, Bass = 0.25, Keyboard = 0.25 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1.1, Bass = 1.2, Keyboard = 0.7 },
		Stems = {
			GuitarLead = "rbxassetid://78769224522755",
			GuitarRhythm = "rbxassetid://119600551663559",
			Bass = "rbxassetid://108467431807569",
			Keyboard = "rbxassetid://85796519392859"
		}
	},
	Propaganda = {
		DisplayName = "Propaganda",
		Artist = "Sepultura",
		Duration = 213,
		Mood = "Fast",
		BPM = 102,
		Genre = "Metal - Groove",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.25, GuitarRhythm = 0.25, Bass = 0.25, Drum = 0.25 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1.2, Bass = 1, Drum = 1 },
		Stems = {
			GuitarLead = "rbxassetid://75210211345244",
			GuitarRhythm = "rbxassetid://128447738524879",
			Bass = "rbxassetid://87097947608572",
			Drum = "rbxassetid://83318680203956"
		}
	},
	["Refuse / Resist"] = {
		DisplayName = "Refuse / Resist",
		Artist = "Sepultura",
		Duration = 193,
		Mood = "Fast",
		BPM = 120,
		Genre = "Metal - Groove",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.25, GuitarRhythm = 0.25, Bass = 0.25, Drum = 0.25 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1.3, Bass = 1, Drum = 1 },
		Stems = {
			GuitarLead = "rbxassetid://94995789912931",
			GuitarRhythm = "rbxassetid://88658322625548",
			Bass = "rbxassetid://86943642844367",
			Drum = "rbxassetid://73439457217946"
		}
	},
	["The Devil Went Down to Georgia"] = {
		DisplayName = "The Devil Went Down to Georgia",
		Artist = "Steve Ouimette",
		Duration = 371,
		Mood = "Fast",
		BPM = 300,
		Genre = "Metal - Speed",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.25, GuitarRhythm = 0.25, Bass = 0.25, Drum = 0.25 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1.2, Bass = 1, Drum = 1 },
		Stems = {
			GuitarLead = "rbxassetid://100036411732867",
			GuitarRhythm = "rbxassetid://111343076721180",
			Bass = "rbxassetid://0",
			Drum = "rbxassetid://111734674261213"
		}
	},
	["The Devil In I"] = {
		DisplayName = "The Devil In I",
		Artist = "Slipknot",
		Duration = 361,
		Mood = "Fast",
		BPM = 102,
		Genre = "Metal - Nu",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.25, GuitarRhythm = 0.25, Bass = 0.25, Drum = 0.25 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1.3, Bass = 1.1, Drum = 1 },
		Stems = {
			GuitarLead = "rbxassetid://136842417923101",
			GuitarRhythm = "rbxassetid://106377487450452",
			Bass = "rbxassetid://88783208694535",
			Drum = "rbxassetid://85618069352134"
		}
	},
	["Your Face"] = {
		DisplayName = "Your Face",
		Artist = "Wisp",
		Duration = 361,
		Mood = "Fast",
		BPM = 102,
		Genre = "Soegaze",
		RecommendedPlayers = 4,
		Offset = -0.3,
		InstrumentOffsets = { GuitarLead = 0.25, GuitarRhythm = 0.25, Bass = 0.25, Drum = 0.25 },
		DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1.3, Bass = 1.1, Drum = 1 },
		Stems = {
			GuitarLead = "rbxassetid://136842417923101",
			GuitarRhythm = "rbxassetid://106377487450452",
			Bass = "rbxassetid://88783208694535",
			Drum = "rbxassetid://85618069352134"
		}
	}
}

songs["The Devil In I"] = {
	DisplayName = "The Devil In I",
	Artist = "Slipknot",
	Duration = 361,
	Mood = "Fast",
	BPM = 102,
	Genre = "Metal - Nu",
	RecommendedPlayers = 4,
	Offset = -0.3,
	InstrumentOffsets = { GuitarLead = 0.25, GuitarRhythm = 0.25, Bass = 0.25, Drum = 0.25 },
	DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1.3, Bass = 1.1, Drum = 1 },
	Stems = {
		GuitarLead = "rbxassetid://136842417923101",
		GuitarRhythm = "rbxassetid://106377487450452",
		Bass = "rbxassetid://88783208694535",
		Drum = "rbxassetid://85618069352134"
	}
}

songs["Your Face"] = {
	DisplayName = "Your Face",
	Artist = "Wisp",
	Duration = 231,
	Mood = "Slow",
	BPM = 134,
	Genre = "Shoegaze",
	RecommendedPlayers = 4,
	Offset = -0.3,
	InstrumentOffsets = { GuitarLead = 0.25, GuitarRhythm = 0.25, Bass = 0.25, Drum = 0.25 },
	DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 1, Bass = 1, Drum = 1 },
	Stems = {
		GuitarLead = "rbxassetid://93205855419701",
		GuitarRhythm = "rbxassetid://79359835427602",
		Bass = "rbxassetid://115826021585440",
		Drum = "rbxassetid://96484986154886"
	}
}

songs.Zombie = {
	DisplayName = "Zombie",
	Artist = "The Cranberries",
	Duration = 309,
	Mood = "Slow",
	BPM = 72,
	Genre = "Rock - Alternative",
	RecommendedPlayers = 4,
	Offset = -0.3,
	InstrumentOffsets = { GuitarLead = 0.25, GuitarRhythm = 0.25, Bass = 0.25, Drum = 0.25 },
	DefaultVolumes = { GuitarLead = 1, GuitarRhythm = 2, Bass = 2, Drum = 1 },
	Stems = {
		GuitarLead = "rbxassetid://117065850001120",
		GuitarRhythm = "rbxassetid://117039202765438",
		Bass = "rbxassetid://111699917132146",
		Drum = "rbxassetid://121196388199725"
	}
}
SongConfig.Songs = songs

return SongConfig