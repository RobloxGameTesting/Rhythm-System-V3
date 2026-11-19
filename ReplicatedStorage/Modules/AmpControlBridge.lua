local v = {}
local AmpControlBridge = {}
AmpControlBridge.GetCurrentAmp = nil

function AmpControlBridge.OnAmpParameterChanged(p)
	table.insert(v, p)
end

function AmpControlBridge.FireAmpParameterChanged(p, p2)
	for _, v2 in ipairs(v) do
		v2(p, p2)
	end
end

local v2 = {}
local v3 = {}

function AmpControlBridge.OnRemoteAmpParameter(p)
	table.insert(v2, p)
end

function AmpControlBridge.FireRemoteAmpParameter(p, p2)
	for _, v4 in ipairs(v2) do
		v4(p, p2)
	end
end

function AmpControlBridge.OnRemoteAmpRestore(p)
	table.insert(v3, p)
end

function AmpControlBridge.FireRemoteAmpRestore()
	for _, v4 in ipairs(v3) do
		v4()
	end
end

return AmpControlBridge