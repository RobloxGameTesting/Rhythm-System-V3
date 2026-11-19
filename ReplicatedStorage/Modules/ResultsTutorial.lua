local color = Color3.fromRGB(236, 180, 72)
local color2 = Color3.fromRGB(104, 178, 112)
local color3 = Color3.fromRGB(14, 13, 12)

local ResultsTutorial = {}
ResultsTutorial.__index = ResultsTutorial

local v = { SHOW_DELAY = 1.6, POLL = 0.25 }

function ResultsTutorial.new(spot, ctx, tips, options)
	local self = setmetatable({}, ResultsTutorial)
	self._spot = spot
	self._ctx = ctx
	self._tips = tips
	self._cfg = setmetatable(options or {}, { __index = v })
	self._token = 0
	self._step = 0
	return self
end

function ResultsTutorial:IsActive(): boolean
	return self._step > 0
end

function ResultsTutorial:OnShown()
	self._token += 1
	local token = self._token
	task.delay(self._cfg.SHOW_DELAY, function()
		if self._token ~= token or not self._ctx.isOpen() or self._step > 0 then
			return
		end

		self:_begin()
	end)
end

function ResultsTutorial:OnClosed()
	self._token += 1

	if self._step > 0 then
		self._step = 0
		self._spot:Hide()
	end
end

function ResultsTutorial:_begin()
	local tips = self._tips
	local ctx = self._ctx
	local isSeen = tips:IsSeen("results")
	local isSeen2 = tips:IsSeen("results_try1")

	if isSeen ~= false or isSeen2 == nil or ctx.anyShowing() then
		return
	end

	if isSeen2 then
		tips:MarkSeen("results")
	else
		tips:MarkSeen("results_try1")
	end

	tips:NoteShown()
	self._list = self:_activeSteps()
	self:_show(1)
	self:_startPoll()
end

function ResultsTutorial:_steps()
	return {
		{
			key = "grade",
			title = "Your grade & accuracy",
			body = "The big letter is your <b>grade</b>. <b>Accuracy</b> is how many notes you hit on time.",
			accent = color
		},
		{
			key = "judgements",
			title = "How each note went",
			body = "<b>Perfect</b> is the best, <b>Miss</b> hurts the most. Check which one you hit the most to see what to improve.",
			accent = color
		},
		{
			key = "timeline",
			optional = true,
			title = "Your performance timeline",
			body = "This chart traces your run from start to finish. Dips show the rough patches, so you know which part of the song to practice.",
			accent = color
		},
		{
			key = "rank",
			optional = true,
			title = "Your rank in the session",
			body = "Everyone who played is ranked here, and this is <b>your row</b>. Use <b>SORT THE LIST BY</b> to rank by other stats.",
			accent = color
		},
		{
			key = "close",
			title = "Ready for another one?",
			body = self._ctx.isMobile() and "Tap <b>X</b> to close this, then open the <b>Song List</b> to pick another song." or "Close this with <b>ENTER</b> or <b>X</b>, then press <b>G</b> to pick another song.",
			accent = color2
		}
	}
end

function ResultsTutorial:_activeSteps()
	local ctx = self._ctx
	local result = {}

	for _, v2 in ipairs(self:_steps()) do
		if not v2.optional or not ctx.isTargetShown or ctx.isTargetShown(v2.key) then
			table.insert(result, v2)
		end
	end

	return result
end

function ResultsTutorial:_show(step)
	local ctx = self._ctx
	local list = self._list or self:_steps()
	local item = list[step]

	if not item then
		self:_finish()
		return
	end

	self._step = step
	local v2 = step == #list
	self._spot:Show({
		target = function()
			return ctx.getTarget(item.key)
		end,
		title = item.title,
		body = item.body,
		tag = "RESULTS " .. step .. "/" .. #list,
		accent = item.accent,
		dim = true,
		block = false,
		padding = 8,
		side = "auto",
		buttons = {
			{
				text = v2 and "GOT IT" or "NEXT",
				color = v2 and color2 or color,
				textColor = color3,
				onClick = function()
					if v2 then
						self:_finish()
					else
						self:_show(step + 1)
					end
				end
			}
		},
		onTargetLost = function()
			if self._step == step then
				self:_show(step + 1)
			end
		end
	})
end

function ResultsTutorial:_finish()
	self._token += 1
	self._step = 0
	self._spot:Hide()
end

function ResultsTutorial:_startPoll()
	self._token += 1
	local token = self._token
	task.spawn(function()
		while self._token == token and self._step > 0 do
			task.wait(self._cfg.POLL)

			if self._token ~= token then
				break
			end

			if not self._ctx.isOpen() then
				self:OnClosed()
				break
			end
		end
	end)
end

return ResultsTutorial