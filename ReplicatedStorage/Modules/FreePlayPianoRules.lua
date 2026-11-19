local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local FreePlayPianoRules = {
	VOLUME = 2,
	MAX_VOICES = 28,
	RELEASE_FADE = 0.28,
	PEDAL_UP_FADE = 0.35,
	RETRIGGER_FADE = 0.05,
	STEAL_FADE = 0.12,
	MUTE_FADE = 0.2,
	NOTE_MAX_LIFETIME = 11,
	NewState = function()
		return {
			Latest = {},
			Held = {},
			Live = {},
			Sustained = {},
			Fading = {},
			PedalDown = false
		}
	end
}

local function removeFromLive(data, instance) -- 3 equivalent calls inferred from this helper
	local index = table.find(data.Live, instance)

	if index then
		table.remove(data.Live, index)
	end

	data.Sustained[instance] = nil
	data.Fading[instance] = nil
end

local function fadeOut(data, instance, duration)
	if not instance or not instance.Parent or data.Fading[instance] then
		return
	end

	data.Fading[instance] = true
	data.Sustained[instance] = nil
	local tween = TweenService:Create(
		instance,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Volume = 0 }
	)
	tween.Completed:Once(function()
		removeFromLive(data, instance) -- inferred equivalent call
		instance:Destroy()
	end)
	tween:Play()
end
FreePlayPianoRules.FadeOut = fadeOut

function FreePlayPianoRules.OnPlay(data, instance, p, p2)
	local v = data.Latest[p]

	if v and v ~= instance then
		fadeOut(data, v, FreePlayPianoRules.RETRIGGER_FADE)
	end

	data.Latest[p] = instance
	data.Held[p] = true

	table.insert(data.Live, instance)
	local v2 = 0

	for _, v3 in ipairs(data.Live) do
		if not data.Fading[v3] then
			v2 += 1
		end
	end

	if FreePlayPianoRules.MAX_VOICES < v2 then
		for _, v3 in ipairs(data.Live) do
			if v2 <= FreePlayPianoRules.MAX_VOICES then
				break
			end

			if v3 == instance or data.Fading[v3] then
				continue
			end

			fadeOut(data, v3, FreePlayPianoRules.STEAL_FADE)
			v2 -= 1
		end
	end

	if p2 then
		instance.Destroying:Once(function()
			removeFromLive(data, instance) -- inferred equivalent call

			if data.Latest[p] == instance then
				data.Latest[p] = nil
			end
		end)
	else
		instance.Ended:Once(function()
			removeFromLive(data, instance) -- inferred equivalent call

			if data.Latest[p] == instance then
				data.Latest[p] = nil
			end

			instance:Destroy()
		end)
	end

	Debris:AddItem(instance, FreePlayPianoRules.NOTE_MAX_LIFETIME)
end

function FreePlayPianoRules.OnRelease(data, p)
	data.Held[p] = nil
	local v = data.Latest[p]

	if not v or not v.Parent or data.Fading[v] then
		return
	end

	v:SetAttribute("FPKeyUp", true)

	if data.PedalDown then
		data.Sustained[v] = true
	else
		fadeOut(data, v, FreePlayPianoRules.RELEASE_FADE)
	end
end

function FreePlayPianoRules:SetPedal(p)
	local pedalDown = p == true

	if self.PedalDown == pedalDown then
		return
	end

	self.PedalDown = pedalDown

	if not pedalDown then
		local v = {}

		for k in pairs(self.Sustained) do
			v[#v + 1] = k
		end

		for _, v2 in ipairs(v) do
			fadeOut(self, v2, FreePlayPianoRules.PEDAL_UP_FADE)
		end

		self.Sustained = {}
	end
end

function FreePlayPianoRules:MuteAll(p)
	local clone = table.clone(self.Live)

	for _, v in ipairs(clone) do
		fadeOut(self, v, p or FreePlayPianoRules.MUTE_FADE)
	end

	self.Held = {}
	self.Latest = {}
	self.Sustained = {}
end

return FreePlayPianoRules