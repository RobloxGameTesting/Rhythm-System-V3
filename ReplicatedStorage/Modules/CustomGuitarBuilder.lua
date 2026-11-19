local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CustomGuitarConfig = require(script.Parent:WaitForChild("CustomGuitarConfig"))

local CustomGuitarBuilder = {}

local function collectParts(folder, value)
	local parts = {}

	if string.sub(value, 1, 1) == "@" then
		local v = string.sub(value, 2)

		for _, part in ipairs(folder:GetChildren()) do
			if part.Name ~= v then
				continue
			end

			if part:IsA("BasePart") then
				table.insert(parts, part)
			end

			for _, part2 in ipairs(part:GetDescendants()) do
				if part2:IsA("BasePart") then
					table.insert(parts, part2)
				end
			end
		end

		return parts
	end

	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") and part.Name == value then
			table.insert(parts, part)
		end
	end

	return parts
end

function CustomGuitarBuilder.Apply(p, data)
	local family = CustomGuitarConfig.GetFamily(data and data.Family)

	if not family then
		return p
	end

	local v = CustomGuitarConfig.Finishes[data.Finish or CustomGuitarConfig.DEFAULT_FINISH]
		or CustomGuitarConfig.Finishes[CustomGuitarConfig.DEFAULT_FINISH]

	for k, list in pairs(family.Slots) do
		local color = CustomGuitarConfig.GetColor(data.Colors and data.Colors[k])
			or CustomGuitarConfig.GetColor(family.Defaults[k])
			or CustomGuitarConfig.Palette[1].Color

		for _, item in ipairs(list) do
			for _, part in ipairs(collectParts(p, item)) do
				part.Color = color

				if part:IsA("MeshPart") then
					part.TextureID = ""
				end

				for _, surfaceAppearance in ipairs(part:GetChildren()) do
					if surfaceAppearance:IsA("SurfaceAppearance") then
						surfaceAppearance:Destroy()
					end
				end

				if k == "Body" then
					part.Material = v.Material
				end
			end
		end
	end

	return p
end

function CustomGuitarBuilder.Build(p, value)
	local family = CustomGuitarConfig.GetFamily(p and p.Family)

	if not family then
		return nil
	end

	local instrumentTemplates = ReplicatedStorage:FindFirstChild("InstrumentTemplates")
	local template = family.Templates[value or "GuitarRhythm"]
	local child = instrumentTemplates and template and instrumentTemplates:FindFirstChild(template)

	if not child then
		warn("[CustomGuitarBuilder] Template polos tidak ditemukan:", (tostring(template)))
		return nil
	end

	local clone = child:Clone()
	CustomGuitarBuilder.Apply(clone, p)
	return clone
end

return CustomGuitarBuilder