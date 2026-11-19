local KeyCode = Enum.KeyCode

local v = {
	Row1 = {
		Keys = {
			KeyCode.Backquote,
			KeyCode.One,
			KeyCode.Two,
			KeyCode.Three,
			KeyCode.Four,
			KeyCode.Five,
			KeyCode.Six,
			KeyCode.Seven,
			KeyCode.Eight,
			KeyCode.Nine,
			KeyCode.Zero,
			KeyCode.Minus,
			KeyCode.Equals
		},
		RequiresShift = {
			true,
			true,
			true,
			true,
			true,
			true,
			true,
			true,
			true,
			true,
			true,
			true,
			true
		}
	},
	Row2 = {
		Keys = {
			KeyCode.Q,
			KeyCode.W,
			KeyCode.E,
			KeyCode.R,
			KeyCode.T,
			KeyCode.Y,
			KeyCode.U,
			KeyCode.I,
			KeyCode.O,
			KeyCode.P,
			KeyCode.LeftBracket,
			KeyCode.RightBracket,
			KeyCode.BackSlash
		},
		RequiresShift = {
			true,
			true,
			true,
			true,
			true,
			true,
			true,
			true,
			true,
			true,
			true,
			true,
			true
		}
	},
	Row3 = {
		Keys = {
			KeyCode.Backquote,
			KeyCode.One,
			KeyCode.Two,
			KeyCode.Three,
			KeyCode.Four,
			KeyCode.Five,
			KeyCode.Six,
			KeyCode.Seven,
			KeyCode.Eight,
			KeyCode.Nine,
			KeyCode.Zero,
			KeyCode.Minus,
			KeyCode.Equals
		},
		RequiresShift = {
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			false
		}
	},
	Row4 = {
		Keys = {
			KeyCode.Q,
			KeyCode.W,
			KeyCode.E,
			KeyCode.R,
			KeyCode.T,
			KeyCode.Y,
			KeyCode.U,
			KeyCode.I,
			KeyCode.O,
			KeyCode.P,
			KeyCode.LeftBracket,
			KeyCode.RightBracket,
			KeyCode.BackSlash
		},
		RequiresShift = {
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			false
		}
	},
	Row5 = {
		Keys = {
			KeyCode.A,
			KeyCode.S,
			KeyCode.D,
			KeyCode.F,
			KeyCode.G,
			KeyCode.H,
			KeyCode.J,
			KeyCode.K,
			KeyCode.L,
			KeyCode.Semicolon,
			KeyCode.Quote,
			KeyCode.Semicolon,
			KeyCode.Quote
		},
		RequiresShift = {
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			true,
			true
		}
	},
	Row6 = {
		Keys = {
			KeyCode.Z,
			KeyCode.X,
			KeyCode.C,
			KeyCode.V,
			KeyCode.B,
			KeyCode.N,
			KeyCode.M,
			KeyCode.Comma,
			KeyCode.Period,
			KeyCode.Slash,
			KeyCode.Comma,
			KeyCode.Period,
			KeyCode.Slash
		},
		RequiresShift = {
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			false,
			true,
			true,
			true
		}
	}
}

local function buildBindingsFromRows(list)
	local bindingsFromRows = {}

	for i, item in ipairs(list) do
		local v2 = v[item]

		for j = 1, 13 do
			local v3 = j - 1
			bindingsFromRows[(i - 1) * 13 + v3 + 1] = {
				KeyCode = v2.Keys[j],
				RequiresShift = v2.RequiresShift[j]
			}
		end
	end

	return bindingsFromRows
end

local v2 = {
	["1"] = KeyCode.One,
	["2"] = KeyCode.Two,
	["3"] = KeyCode.Three,
	["4"] = KeyCode.Four,
	["5"] = KeyCode.Five,
	["6"] = KeyCode.Six,
	["7"] = KeyCode.Seven,
	["8"] = KeyCode.Eight,
	["9"] = KeyCode.Nine,
	["0"] = KeyCode.Zero
}

local v3 = {
	["!"] = KeyCode.One,
	["@"] = KeyCode.Two,
	["$"] = KeyCode.Four,
	["%"] = KeyCode.Five,
	["^"] = KeyCode.Six,
	["*"] = KeyCode.Eight,
	["("] = KeyCode.Nine
}

local function buildPianoBindings()
	local pianoBindings = {}

	for i = 1, 61 do
		local v4 = ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):sub(i, i)

		if v2[v4] then
			pianoBindings[i] = { KeyCode = v2[v4], RequiresShift = false }
		elseif v3[v4] then
			pianoBindings[i] = { KeyCode = v3[v4], RequiresShift = true }
		else
			local upper = v4:upper()
			pianoBindings[i] = {
				KeyCode = KeyCode[upper],
				RequiresShift = v4 == upper
			}
		end
	end

	return pianoBindings
end

return {
	GuitarLead = buildBindingsFromRows({ "Row1", "Row2", "Row3", "Row4", "Row5", "Row6" }),
	GuitarRhythm = buildBindingsFromRows({ "Row1", "Row2", "Row3", "Row4", "Row5", "Row6" }),
	Bass = buildBindingsFromRows({ "Row3", "Row4", "Row5", "Row6" }),
	Drum = {
		Enum.KeyCode.E,
		Enum.KeyCode.W,
		Enum.KeyCode.R,
		Enum.KeyCode.M,
		Enum.KeyCode.X,
		Enum.KeyCode.D,
		Enum.KeyCode.F,
		Enum.KeyCode.G,
		Enum.KeyCode.H,
		Enum.KeyCode.U,
		Enum.KeyCode.I,
		Enum.KeyCode.Comma,
		Enum.KeyCode.Z,
		Enum.KeyCode.C,
		Enum.KeyCode.V,
		Enum.KeyCode.S,
		Enum.KeyCode.B,
		Enum.KeyCode.N,
		Enum.KeyCode.J,
		Enum.KeyCode.K,
		Enum.KeyCode.O,
		Enum.KeyCode.A
	},
	Piano = buildPianoBindings()
}