local TabsIcons = {}

TabsIcons.ids = {
	slide = 83028199221650,
	hammer_on = 125197047779991,
	pull_off = 83736280617468,
	palm_mute = 79869432598745,
	bend = 102623056683388,
	let_ring = 85888513877489,
	vibrato = 88666481243110,
	dead_note = 77337592784629,
	tie = 98987202131808,
	step_size = 84770269312963,
	note_length = 109191831799981,
	beats_per_bar = 121064489940801,
	undo = 87592315313194,
	save = 87806775063726,
	saved_tabs = 74912923349826,
	close_editor = 88582570757387,
	record = 128390195443170,
	type_keys = 85261316000106,
	copy_bar = 84221470643149,
	paste_bar = 119377606962154,
	empty_bar = 131672043811931,
	rec_timing = 131703379629649,
	pick_notes = 107372513769401,
	section = 116374371444529,
	delete_note = 114149263093593,
	tempo_change = 126683870102537,
	sound_change = 134906549509751,
	frets_13_24 = 101333939317038,
	band = 101905189483727,
	join = 128458814246314,
	leave = 126695431242186
}

function TabsIcons.image(p)
	local id = TabsIcons.ids[p]
	return id and "rbxassetid://" .. id or nil
end

local flag = false
function TabsIcons.preload()
	if flag then
		return
	end

	flag = true
	local ContentProvider = game:GetService("ContentProvider")
	local v = {}

	for k in pairs(TabsIcons.ids) do
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Image = TabsIcons.image(k)
		v[#v + 1] = imageLabel
	end

	task.spawn(function()
		pcall(function()
			ContentProvider:PreloadAsync(v)
		end)

		for _, v2 in ipairs(v) do
			v2:Destroy()
		end
	end)
end

return TabsIcons