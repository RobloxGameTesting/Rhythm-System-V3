local CabinetChain = {}

function CabinetChain.Build(rig, soundInstance, value)
	return {
		rig = rig,
		soundInstance = soundInstance,
		effect = nil,
		nextPriority = value or 0
	}
end

function CabinetChain.Update(_, p)
	if p and p.Cabinet then
	end
end

function CabinetChain:Destroy()
	if self.effect then
		self.effect:Destroy()
	end
end

return CabinetChain