local AssetService = game:GetService("AssetService")
local CollectionService = game:GetService("CollectionService")

local v = {
	red = Color3.fromRGB(160, 36, 34),
	black = Color3.fromRGB(44, 42, 44),
	dark = Color3.fromRGB(96, 90, 80),
	grey = Color3.fromRGB(150, 142, 122),
	cream = Color3.fromRGB(206, 190, 150)
}

local v2 = {}
local flag = true

local function clamp01(p) -- 2 equivalent calls inferred from this helper
	if p < 0 then
		return 0
	end

	return if p > 1 then 1 else p
end

local function generate(tapeKind, p, p2, p3)
	local success, result = pcall(function()
		return AssetService:CreateEditableImage({ Size = Vector2.new(p, p2) })
	end)

	if not (success and result) then
		return nil
	end

	local random = Random.new(p3)
	local v3 = v[tapeKind] or v.dark
	local v4 = v3.R * 255
	local v5 = v3.G * 255
	local v6 = v3.B * 255
	local v7 = tapeKind == "cream" and 0.9 or 0.96

	local v8 = math.max(3, ((math.floor)(p2 * 0.16)))
	local v9 = p2 / 3.4 * 1.414

	local number = random:NextNumber()
	local number2 = random:NextNumber()
	local integer = random:NextInteger(2, p2 - 4)
	local integer2 = random:NextInteger(0, 1)
	local v10 = {}
	local v11 = {}

	for i = 0, p2 - 1 do
		local v12 = math.abs((i / v9 + number) % 1 * 2 - 1)
		local v13 = math.abs((i / v9 + number2) % 1 * 2 - 1)
		local v14 = v12 * v8 + random:NextNumber(-0.7, 0.7)
		local v15 = p - 1 - v13 * v8 + random:NextNumber(-0.7, 0.7)

		if random:NextNumber() < 0.12 then
			v14 += 1.5
		end

		if random:NextNumber() < 0.12 then
			v15 -= 1.5
		end

		if math.abs(i - integer) <= 2 then
			if integer2 == 0 then
				v14 += 2
			else
				v15 -= 2
			end
		end

		v10[i] = v14
		v11[i] = v15
	end

	local v12 = {}

	for i = 1, random:NextInteger(1, 2) do
		v12[i] = random:NextNumber(v8 + 5, p - v8 - 5)
	end

	local v13 = {}

	for _ = 1, random:NextInteger(3, 5) do
		local number3 = random:NextNumber(p * 0.08, p * 0.26)
		local number4 = random:NextNumber(v8 + 2, p - v8 - number3 - 2)
		local number5 = random:NextNumber(3, p2 - 4)
		local number6 = random:NextNumber(-0.12, 0.12)
		local v14 = random:NextNumber() > 0.5 and 1 or -1

		for i = 0, math.floor(number3) do
			local v15 = math.floor(number4 + i)
			local v16 = math.floor(number5 + number6 * i)

			if v16 >= 0 and v16 < p2 then
				v13[v16 * p + v15] = v14
			end
		end
	end

	local set = {}

	for _ = 1, random:NextInteger(5, 9) do
		set[math.floor((random:NextNumber(v8, p - v8))) + math.floor((random:NextNumber(2, p2 - 2))) * p] = true
	end

	local number3 = random:NextNumber(v8 + 4, p * 0.3)
	local number4 = random:NextNumber(5, 9)

	local buf = buffer.create(p * p2 * 4)

	for i = 0, p2 - 1 do
		local v14 = 1.1 - i / (math.max)(p2 - 1, 1) * 0.32

		if i % 4 == 1 then
			v14 *= 0.93
		end

		if i == 0 or i == p2 - 1 then
			v14 *= 0.68
		elseif i == 1 or i == p2 - 2 then
			v14 *= 0.88
		end

		for j = 0, p - 1 do
			local v15 = clamp01(j + 1 - v10[i]) * clamp01(v11[i] + 1 - j) -- inferred equivalent call
			local v16 = (i * p + j) * 4

			if not (v15 > 0) then
				continue
			end

			local v17 = v14 * (1 + (random:NextNumber() - 0.5) * 0.1)
			local v18 = v4 * v17
			local v19 = v5 * v17
			local v20 = v6 * v17

			for _, v21 in ipairs(v12) do
				if not (math.abs(j - v21) < 0.7) then
					continue
				end

				v18 += (255 - v18) * 0.22
				v19 += (255 - v19) * 0.22
				v20 += (255 - v20) * 0.22
			end

			local v21 = v13[i * p + j]

			if v21 == 1 then
				v18 += (214 - v18) * 0.45
				v19 += (206 - v19) * 0.45
				v20 += (188 - v20) * 0.45
			elseif v21 == -1 then
				v18 *= 0.55
				v19 *= 0.55
				v20 *= 0.55
			end

			if set[i * p + j] then
				v18 *= 0.45
				v19 *= 0.42
				v20 *= 0.4
			end

			local v22 = math.abs(j - number3) / number4

			if v22 < 1 then
				local v23 = 1 - (1 - v22) * 0.28
				v18 *= v23
				v19 *= v23 * 0.97
				v20 *= v23 * 0.9
			end

			buffer.writeu8(buf, v16, (math.clamp(math.floor(v18 + 0.5), 0, 255)))
			buffer.writeu8(buf, v16 + 1, (math.clamp(math.floor(v19 + 0.5), 0, 255)))
			buffer.writeu8(buf, v16 + 2, (math.clamp(math.floor(v20 + 0.5), 0, 255)))
			buffer.writeu8(buf, v16 + 3, (math.floor(255 * v15 * v7 + 0.5)))
		end
	end

	if pcall(function()
		result:WritePixelsBuffer(Vector2.zero, Vector2.new(p, p2), buf)
	end) then
		return result
	end

	result:Destroy()
	return nil
end

local function fallback(part) -- 1 equivalent call inferred from this helper
	local origColor = part:GetAttribute("OrigColor")

	if typeof(origColor) == "Color3" then
		part.Color = origColor
	end

	part.Transparency = tonumber(part:GetAttribute("OrigTransparency")) or 0
end

local partSet = {}

local function apply(part)
	if not part:IsA("BasePart") or part:FindFirstChild("TapeDecal") or partSet[part] then
		return
	end

	partSet[part] = true

	if flag then
		local tapeKind = part:GetAttribute("TapeKind") or "dark"
		local tapeSeed = tonumber(part:GetAttribute("TapeSeed")) or 1
		local v3 = math.clamp(math.floor(part.Size.X / part.Size.Y * 40 / 6 + 0.5) * 6, 24, 200)
		local v4 = tapeSeed % 2
		local v5 = tapeKind .. "|" .. v3 .. "|" .. v4
		local v6 = v2[v5]

		if v6 == nil then
			v6 = generate(tapeKind, v3, 40, v4 * 7919 + v3 * 31 + #tapeKind * 101)
			v2[v5] = v6 or false

			if not v6 then
				flag = false
			end

			task.wait()
		end

		if v6 then
			local tapeDecal = Instance.new("Decal")
			tapeDecal.Name = "TapeDecal"
			tapeDecal.Face = Enum.NormalId.Front
			tapeDecal.TextureContent = Content.fromObject(v6)
			tapeDecal.Parent = part
			part.Transparency = 1
			return
		end
	end

	fallback(part) -- inferred equivalent call
end

for _, v3 in ipairs(CollectionService:GetTagged("BoardTape")) do
	task.spawn(apply, v3)
end

CollectionService:GetInstanceAddedSignal("BoardTape"):Connect(function(p)
	task.spawn(apply, p)
end)