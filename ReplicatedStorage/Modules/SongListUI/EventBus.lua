local EventBus = {}
EventBus.__index = EventBus

function EventBus.new()
	return (setmetatable({ _listeners = {} }, EventBus))
end

function EventBus:Subscribe(p, p2)
	local v = self._listeners[p]

	if not v then
		v = {}
		self._listeners[p] = v
	end

	table.insert(v, p2)

	local flag = false
	return {
		Disconnect = function()
			if flag then
				return
			end

			flag = true
			local listener = self._listeners[p]

			if not listener then
				return
			end

			for i, v2 in ipairs(listener) do
				if v2 == p2 then
					table.remove(listener, i)
					break
				end
			end
		end
	}
end

function EventBus:Publish(p, ...)
	local listener = self._listeners[p]

	if not listener then
		return
	end

	for _, v in ipairs(table.clone(listener)) do
		v(...)
	end
end

function EventBus:Destroy()
	self._listeners = {}
end

return EventBus