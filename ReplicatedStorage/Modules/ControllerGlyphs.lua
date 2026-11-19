local UserInputService = game:GetService("UserInputService")

local ControllerGlyphs = {}

local v = {
	ButtonA = "A",
	ButtonB = "B",
	ButtonX = "X",
	ButtonY = "Y",
	ButtonL1 = "LB",
	ButtonR1 = "RB",
	ButtonL2 = "LT",
	ButtonR2 = "RT",
	ButtonL3 = "LS",
	ButtonR3 = "RS",
	ButtonSelect = "VIEW",
	ButtonStart = "MENU",
	DPadUp = "D-UP",
	DPadDown = "D-DN",
	DPadLeft = "D-LT",
	DPadRight = "D-RT"
}

local v2 = {
	ButtonA = "✕",
	ButtonB = "○",
	ButtonX = "□",
	ButtonY = "△",
	ButtonL1 = "L1",
	ButtonR1 = "R1",
	ButtonL2 = "L2",
	ButtonR2 = "R2",
	ButtonL3 = "L3",
	ButtonR3 = "R3",
	ButtonSelect = "SHARE",
	ButtonStart = "OPT",
	DPadUp = "D-UP",
	DPadDown = "D-DN",
	DPadLeft = "D-LT",
	DPadRight = "D-RT"
}

local function settingsStyle()
	local success, result = pcall(function()
		return require(script.Parent:WaitForChild("SettingsState", 2))
	end)

	if success and result and result.GetControllerGlyphStyle then
		return result.GetControllerGlyphStyle()
	end

	return "Auto"
end

local function detectStyle(): string
	local success, result = pcall(function()
		return UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonA)
	end)

	if success and type(result) == "string" then
		local v3 = string.lower(result)

		if
			string.find(v3, "ps4", 1, true)
			or string.find(v3, "ps5", 1, true)
			or string.find(v3, "playstation", 1, true)
			or string.find(v3, "dualshock", 1, true)
			or string.find(v3, "dualsense", 1, true)
		then
			return "PlayStation"
		end
	end

	return "Xbox"
end

function ControllerGlyphs.GetStyle()
	local success, result = pcall(function()
		return require(script.Parent:WaitForChild("SettingsState", 2))
	end)

	local v3 = not (success and result and result.GetControllerGlyphStyle) and "Auto"
		or result.GetControllerGlyphStyle()

	if v3 == "Xbox" or v3 == "PlayStation" then
		return v3
	end

	return detectStyle()
end

function ControllerGlyphs.IsPadKeyName(value): boolean
	return type(value) == "string" and v[value] ~= nil
end

function ControllerGlyphs.LabelFromName(p)
	return (ControllerGlyphs.GetStyle() == "PlayStation" and v2 or v)[p]
end

function ControllerGlyphs.Label(p)
	if typeof(p) == "EnumItem" then
		return ControllerGlyphs.LabelFromName(p.Name)
	end

	return nil
end

function ControllerGlyphs.Display(p)
	if typeof(p) == "EnumItem" then
		return ControllerGlyphs.Label(p) or p.Name
	end

	return "?"
end

return ControllerGlyphs