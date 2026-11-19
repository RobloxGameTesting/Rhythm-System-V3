local color = Color3.fromRGB(236, 180, 72)
local color2 = Color3.fromRGB(104, 178, 112)

local MobileKeyTip = {}
MobileKeyTip.__index = MobileKeyTip

local v = { POLL = 0.25, AUTO_HIDE = 30, DONE_SECONDS = 9 }

function MobileKeyTip.new(spot, ctx, tips, options)
	local self = setmetatable({}, MobileKeyTip)
	self._spot = spot
	self._ctx = ctx
	self._tips = tips
	self._cfg = setmetatable(options or {}, { __index = v })
	self._state = "Idle"
	self._playing = false
	self._shownAt = 0
	self._pollToken = 0
	return self
end

function MobileKeyTip:GetState()
	return self._state
end

function MobileKeyTip:OnVisibility(playing)
	self._playing = playing

	if not playing and self._state ~= "Idle" then
		self:_hide()
	end
end

function MobileKeyTip:Trigger(): boolean
	local ctx = self._ctx

	if self._state ~= "Idle" or not ctx.isMobile() or self._tips:IsSeen("mobile2key") ~= false then
		return false
	end

	local keyMode = ctx.getKeyMode()

	if keyMode == nil or keyMode == 2 or ctx.getKeyButton() == nil or ctx.anyShowing() then
		return false
	end

	self._tips:MarkSeen("mobile2key")
	self._tips:NoteShown()
	self:_enterButton()
	self:_startPoll()
	return true
end

function MobileKeyTip:_enterButton()
	local ctx = self._ctx
	self._state = "Button"
	self._shownAt = os.clock()
	self._spot:Show({
		target = ctx.getKeyButton,
		title = "Phone? Try 2-Key mode!",
		body = "Only two big buttons, much easier on a touchscreen. Tap <b>Key</b>, then pick <b>2-Key</b>.",
		tag = "TIP",
		accent = color,
		dim = false,
		block = false,
		padding = 6,
		side = "below",
		onTargetLost = function()
			self:_hide()
		end
	})
end

function MobileKeyTip:_enterPanel()
	local ctx = self._ctx
	self._state = "Panel"
	self._spot:Show({
		target = ctx.getKeyPanel,
		title = "Pick 2-Key",
		body = "Two big buttons, easy to hit. The notes adjust live, no restart needed.",
		tag = "TIP",
		accent = color2,
		dim = false,
		block = false,
		padding = 6,
		side = "left",
		onTargetLost = function()
			if self._state == "Panel" then
				self:_enterButton()
			end
		end
	})
end

function MobileKeyTip:_hide()
	self._pollToken += 1
	self._state = "Idle"
	self._spot:Hide()
end

function MobileKeyTip:_complete()
	self:_hide()
	self._spot:Show({
		target = nil,
		anchor = "top",
		title = "Nice! Easier already.",
		body = "Want bigger buttons too? Open <b>Settings</b> → <b>Gameplay</b> → <b>Mobile</b>.",
		tag = "TIP",
		accent = color2,
		autoHide = self._cfg.DONE_SECONDS
	})
end

function MobileKeyTip:_startPoll()
	self._pollToken += 1
	local pollToken = self._pollToken
	task.spawn(function()
		while self._pollToken == pollToken and self._state ~= "Idle" do
			task.wait(self._cfg.POLL)

			if self._pollToken ~= pollToken then
				break
			end

			local success, result = pcall(self._tick, self)

			if not success then
				warn("[MobileKeyTip] tick error:", result)
			end
		end
	end)
end

function MobileKeyTip:_tick()
	local ctx = self._ctx

	if self._state == "Idle" then
		return
	end

	if not self._playing then
		self:_hide()
		return
	end

	if ctx.getKeyMode() == 2 then
		self:_complete()
		return
	end

	local keyPanel = ctx.getKeyPanel()
	local v2

	if keyPanel == nil then
		v2 = false
	else
		v2 = self._spot.IsShown(keyPanel)
	end

	if self._state == "Button" then
		if v2 then
			self:_enterPanel()
		elseif os.clock() - self._shownAt >= self._cfg.AUTO_HIDE then
			self:_hide()
		end
	elseif self._state == "Panel" and not v2 then
		self:_enterButton()
	end
end

return MobileKeyTip