local v = nil
local bindableEvent = Instance.new("BindableEvent")
local PStudioState = {}
PStudioState.Changed = bindableEvent.Event

function PStudioState.Get()
	return v
end

function PStudioState.Set(p)
	v = p
	bindableEvent:Fire(p)
end

return PStudioState