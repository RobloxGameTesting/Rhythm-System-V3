local color = Color3.fromRGB(236, 180, 72)
local color2 = Color3.fromRGB(104, 178, 112)
local color3 = Color3.fromRGB(14, 13, 12)

local FillTutorial = {}
FillTutorial.__index = FillTutorial

local v = { POLL = 0.15, INVITE_WAIT = 10 }

function FillTutorial.new(spot, ctx, p)
	local object = setmetatable({}, FillTutorial)
	object._spot = spot
	object._ctx = ctx
	object._timing = p or v
	object._state = "Idle"
	object._songId = nil
	object._token = 0
	object._pollToken = 0
	object._holders = {}
	object._inviteKey = nil
	object._waitStart = 0

	if ctx.onFillToggled then
		ctx.onFillToggled(function()
			if object._state == "Fill" or object._state == "Play" then
				object:_tick()
			end
		end)
	end

	return object
end

function FillTutorial:GetState()
	return self._state
end

function FillTutorial:IsActive(): boolean
	return self._state ~= "Idle"
end

function FillTutorial:OnPlayRequested(songId, p): boolean
	local ctx = self._ctx

	if self._state == "Play" and p and songId == self._songId then
		self:_complete()
		return false
	end

	if self._state ~= "Idle" then
		return true
	end

	if not (ctx.getFlag() == false and ctx.isFreshPlay(songId)) then
		return false
	end

	if p then
		ctx.markFillDone()
		return false
	end

	if ctx.inRoom() then
		return false
	end

	self._state = "Checking"
	self._songId = songId
	self._token += 1
	local token = self._token
	task.spawn(function()
		local success, result = pcall(ctx.queryContext)

		if self._token ~= token or self._state ~= "Checking" then
			return
		end

		if success and result and result.OthersPlaying ~= true then
			local holders = {}

			for _, v2 in ipairs(result.Idle or {}) do
				if ctx.isRowAvailable(v2.Instrument) then
					table.insert(holders, v2)
				end
			end

			self._holders = holders
			self:_startPoll()

			if #holders > 0 then
				self:_enterInvite()
			else
				self:_enterFill()
			end
		else
			self._state = "Idle"
			ctx.proceed(songId, false)
		end
	end)
	return true
end

function FillTutorial:Cancel()
	self._token += 1
	self._pollToken += 1
	self._state = "Idle"
	self._songId = nil
	self._spot:Hide()
end

function FillTutorial:_finishWithoutTutorial()
	local songId = self._songId
	self:Cancel()

	if songId then
		self._ctx.proceed(songId, false)
	end
end

function FillTutorial:_complete()
	self._ctx.markFillDone()
	self:Cancel()
end

function FillTutorial:_startPoll()
	self._pollToken += 1
	local pollToken = self._pollToken
	task.spawn(function()
		while self._pollToken == pollToken and self._state ~= "Idle" do
			task.wait(self._timing.POLL)

			if self._pollToken ~= pollToken then
				break
			end

			local success, result = pcall(self._tick, self)

			if not success then
				warn("[FillTutorial] tick error:", result)
			end
		end
	end)
end

function FillTutorial:_tick()
	local ctx = self._ctx
	local state = self._state

	if state == "Idle" or state == "Checking" then
		return
	end

	if
		not ctx.isMenuOpen()
		or not ctx.isEquipped()
		or ctx.getSelectedSongId() ~= self._songId
		or not ctx.isFreshPlay(self._songId)
	then
		self:Cancel()
	elseif state == "Invite" then
		if ctx.getPartyStatus(self._inviteKey) then
			self:_enterInviteWait()
		end
	elseif state == "InviteWait" then
		local partyStatus = ctx.getPartyStatus(self._inviteKey)

		if partyStatus == "loading" or partyStatus == "joined" or partyStatus == "ready" then
			self:Cancel()
			return
		end

		if not partyStatus then
			self:_enterFill()
			return
		end

		local v2 = self._timing.INVITE_WAIT - (os.clock() - self._waitStart)

		if v2 <= 0 then
			ctx.cancelInvite(self._inviteKey)
			self:_enterFill()
		else
			self._spot:SetBody(self:_waitBody((math.ceil(v2))))
		end
	elseif state == "Fill" then
		if ctx.partyFormed() then
			self:Cancel()
		elseif ctx.isFillLocked() then
			self:_finishWithoutTutorial()
		elseif ctx.isFillOn() then
			self:_enterPlay()
		end
	elseif state == "Play" then
		if ctx.partyFormed() then
			self:Cancel()
		elseif not ctx.isFillOn() then
			self:_enterFill()
		end
	end
end

function FillTutorial:_esc(p)
	return self._spot.Escape(p)
end

function FillTutorial:_enterInvite()
	local ctx = self._ctx
	local holder = self._holders[1]
	self._state = "Invite"
	self._inviteKey = holder.Instrument
	local instrument = holder.Instrument
	self._spot:Show({
		target = function()
			return ctx.getInviteButton(instrument)
		end,
		title = "Jam together first?",
		body = string.format(
			"<b>@%s</b> is holding <b>%s</b>. Press <b>+invite</b> to play together, or skip and let the backing track fill in.",
			self:_esc(holder.Name),
			self:_esc(ctx.getInstrumentName(instrument))
		),
		tag = "TUTORIAL",
		accent = color2,
		padding = 6,
		side = "auto",
		buttons = {
			{
				text = "USE BACKING TRACK",
				color = color,
				textColor = color3,
				onClick = function()
					self:_enterFill()
				end
			}
		},
		onTargetLost = function()
			if self._state == "Invite" then
				self:_enterFill()
			else
				self:Cancel()
			end
		end
	})
end

function FillTutorial:_waitBody(p)
	local holder = self._holders[1]
	return string.format(
		"Waiting for <b>@%s</b> to answer (%ds). If they accept, you play together. If not, we switch to the backing track.",
		self:_esc(holder.Name),
		p
	)
end

function FillTutorial:_enterInviteWait()
	local ctx = self._ctx
	local inviteKey = self._inviteKey
	self._state = "InviteWait"
	self._waitStart = os.clock()
	self._spot:Show({
		target = function()
			return ctx.getInviteButton(inviteKey)
		end,
		title = "Invite sent!",
		body = self:_waitBody((math.ceil(self._timing.INVITE_WAIT))),
		tag = "TUTORIAL",
		accent = color2,
		padding = 6,
		side = "auto",
		buttons = {
			{
				text = "USE BACKING TRACK",
				color = color,
				textColor = color3,
				onClick = function()
					ctx.cancelInvite(inviteKey)
					self:_enterFill()
				end
			}
		},
		onTargetLost = function()
			self:Cancel()
		end
	})
end

function FillTutorial:_enterFill()
	local ctx = self._ctx

	if ctx.isFillLocked() then
		self:_finishWithoutTutorial()
		return
	end

	self._state = "Fill"

	if ctx.isFillOn() then
		self:_enterPlay()
	else
		self._spot:Show({
			target = ctx.getFillRow,
			title = "Playing solo? Turn on Fill Backing Track!",
			body = "Tick this box so the band plays the instruments nobody is holding. Without it, only your own instrument will make sound.",
			tag = "TUTORIAL 1/2",
			accent = color,
			padding = 8,
			side = "auto",
			onTargetLost = function()
				self:_finishWithoutTutorial()
			end
		})
	end
end

function FillTutorial:_enterPlay()
	local ctx = self._ctx
	self._state = "Play"
	self._spot:Show({
		target = ctx.getPlayButton,
		title = "Great! Now press Play.",
		body = "The band covers every other instrument. Just play your part and have fun!",
		tag = "TUTORIAL 2/2",
		accent = color2,
		padding = 8,
		side = "auto",
		onTargetLost = function()
			self:Cancel()
		end
	})
end

return FillTutorial