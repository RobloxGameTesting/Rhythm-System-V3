local color = Color3.fromRGB(236, 180, 72)
local color2 = Color3.fromRGB(104, 178, 112)

local DifficultyTip = {}
DifficultyTip.__index = DifficultyTip

local v = {
	CONSEC_MISSES = 8,
	MIN_SECONDS = 25,
	MIN_JUDGED = 20,
	MIN_HIT_RATIO = 0.5,
	MAX_PER_SESSION = 3,
	AUTO_HIDE = 30,
	DONE_MESSAGE_SECONDS = 3.5,
	POLL = 0.2
}

function DifficultyTip.new(spot, ctx, options)
	local object = setmetatable({}, DifficultyTip)
	object._spot = spot
	object._ctx = ctx
	object._cfg = setmetatable(options or {}, { __index = v })
	object._state = "Idle"
	object._playing = false
	object._songStart = 0
	object._judged = 0
	object._misses = 0
	object._consec = 0
	object._shownThisSong = false
	object._shownCount = 0
	object._shownAt = 0
	object._pollToken = 0
	object._done = false

	if ctx.onDifficultyChanged then
		ctx.onDifficultyChanged(function()
			object:_tick()
		end)
	end

	return object
end

function DifficultyTip:GetState()
	return self._state
end

function DifficultyTip:Reset()
	self._done = false
	self._shownCount = 0
	self._shownThisSong = false
	self:_hide()
end

function DifficultyTip:OnVisibility(p)
	if p then
		self._playing = true
		self._songStart = os.clock()
		self._judged = 0
		self._misses = 0
		self._consec = 0
		self._shownThisSong = false
	else
		self._playing = false

		if self._state ~= "Idle" then
			self:_hide()
		end
	end
end

function DifficultyTip:OnJudgment(p, p2)
	if p2 or not self._playing then
		return
	end

	self._judged += 1

	if p == "Miss" then
		self._misses += 1
		self._consec += 1
	else
		self._consec = 0
	end

	self:_evaluate()
end

function DifficultyTip:_isStruggling(): boolean
	local cfg = self._cfg

	if self._consec >= cfg.CONSEC_MISSES then
		return true
	end

	if os.clock() - self._songStart >= cfg.MIN_SECONDS and self._judged >= cfg.MIN_JUDGED then
		return (self._judged - self._misses) / self._judged < cfg.MIN_HIT_RATIO
	end

	return false
end

function DifficultyTip:_evaluate()
	local ctx = self._ctx

	if self._state ~= "Idle" or self._shownThisSong or not self:_isStruggling() then
		return
	end

	if ctx.onStruggle and ctx.onStruggle() then
		self._shownThisSong = true
		return
	end

	if self._done or self._shownCount >= self._cfg.MAX_PER_SESSION or not (ctx.isArmed() and ctx.isNatural()) then
		return
	end

	self._shownThisSong = true
	self._shownCount += 1
	self:_enterButton()
	self:_startPoll()
end

function DifficultyTip:_enterButton()
	local ctx = self._ctx

	if ctx.ensureHudVisible then
		ctx.ensureHudVisible()
	end

	self._state = "Button"
	self._shownAt = os.clock()
	self._spot:Show({
		target = ctx.getDifficultyButton,
		title = "Struggling? Make it easier!",
		body = "Tap <b>Difficulty</b>, then pick <b>Medium</b>, <b>Easy</b> or <b>Baby</b>. You can change it anytime.",
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

function DifficultyTip:_enterPanel()
	local ctx = self._ctx
	self._state = "Panel"
	self._spot:Show({
		target = ctx.getDifficultyPanel,
		title = "Pick anything below Natural",
		body = "<b>Medium</b>, <b>Easy</b> or <b>Baby</b> — the notes adjust live, no restart needed.",
		tag = "TIP",
		accent = color2,
		dim = false,
		block = false,
		padding = 6,
		side = "left",
		onTargetLost = function()
			self:_enterButtonOrHide()
		end
	})
end

function DifficultyTip:_enterButtonOrHide()
	if self._state == "Idle" then
		return
	end

	if self._ctx.isNatural() then
		self:_enterButton()
	else
		self:_complete()
	end
end

function DifficultyTip:_hide()
	self._pollToken += 1
	self._state = "Idle"
	self._spot:Hide()
end

function DifficultyTip:_complete()
	self._done = true
	self._ctx.markDone()
	self:_hide()

	local ctx = self._ctx
	self._spot:Show({
		target = ctx.getDifficultyButton,
		title = "Nice! Much better.",
		body = "You can change the difficulty anytime from this button.",
		tag = "TIP",
		accent = color2,
		dim = false,
		block = false,
		padding = 6,
		side = "below",
		onTargetLost = function()
			self._spot:Hide()
		end
	})

	local pollToken = self._pollToken
	task.delay(self._cfg.DONE_MESSAGE_SECONDS, function()
		if self._pollToken == pollToken and self._state == "Idle" then
			self._spot:Hide()
		end
	end)
end

function DifficultyTip:_startPoll()
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
				warn("[DifficultyTip] tick error:", result)
			end
		end
	end)
end

function DifficultyTip:_tick()
	local ctx = self._ctx
	local state = self._state

	if state == "Idle" then
		return
	end

	if not self._playing then
		self:_hide()
		return
	end

	if not ctx.isNatural() then
		self:_complete()
		return
	end

	local morePanelOpen = ctx.isMorePanelOpen()

	if state == "More" then
		if not morePanelOpen then
			self:_enterButton()
		end
	elseif morePanelOpen then
		self._state = "More"
		self._spot:Hide()
	else
		local difficultyPanel = ctx.getDifficultyPanel()
		local v2

		if difficultyPanel == nil then
			v2 = false
		else
			v2 = self._spot.IsShown(difficultyPanel)
		end

		if state == "Button" then
			if v2 then
				self:_enterPanel()
			elseif os.clock() - self._shownAt >= self._cfg.AUTO_HIDE then
				self:_hide()
			end
		elseif state == "Panel" and not v2 then
			self:_enterButton()
		end
	end
end

return DifficultyTip