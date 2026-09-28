local DataStoreService = game:GetService("DataStoreService")

local Progression = {}

local PROFILE_STORE = DataStoreService:GetDataStore("HellFeast_Profile_v2")
local LEGACY_DNA_STORE = DataStoreService:GetDataStore("HellFeast_DemonDNA_v1")

local DEFAULT_PROFILE = {
	DemonDNA = 0,
	BestCircle = 0,
	Upgrades = {
		Vitality = 0,
		Metabolism = 0,
		Butchery = 0,
	},
}

local function cloneDefaults()
	return {
		DemonDNA = DEFAULT_PROFILE.DemonDNA,
		BestCircle = DEFAULT_PROFILE.BestCircle,
		Upgrades = {
			Vitality = DEFAULT_PROFILE.Upgrades.Vitality,
			Metabolism = DEFAULT_PROFILE.Upgrades.Metabolism,
			Butchery = DEFAULT_PROFILE.Upgrades.Butchery,
		},
	}
end

function Progression.Load(player, config)
	local profile = cloneDefaults()
	local loaded = false

	local ok, data = pcall(function()
		return PROFILE_STORE:GetAsync(tostring(player.UserId))
	end)

	if ok and type(data) == "table" then
		loaded = true
		profile.DemonDNA = tonumber(data.DemonDNA) or 0
		profile.BestCircle = tonumber(data.BestCircle) or 0

		if type(data.Upgrades) == "table" then
			for key in pairs(profile.Upgrades) do
				profile.Upgrades[key] = math.max(0, math.floor(tonumber(data.Upgrades[key]) or 0))
			end
		end
	end

	if not loaded then
		pcall(function()
			profile.DemonDNA = tonumber(LEGACY_DNA_STORE:GetAsync(tostring(player.UserId))) or 0
		end)
	end

	player:SetAttribute("DemonDNA", profile.DemonDNA)
	player:SetAttribute("BestCircle", profile.BestCircle)

	for key, level in pairs(profile.Upgrades) do
		local upgrade = config.Upgrades[key]
		if upgrade then
			level = math.clamp(level, 0, upgrade.MaxLevel)
		end
		player:SetAttribute("Upgrade_" .. key, level)
	end

	return profile
end

function Progression.Save(player)
	local data = {
		DemonDNA = player:GetAttribute("DemonDNA") or 0,
		BestCircle = player:GetAttribute("BestCircle") or 0,
		Upgrades = {
			Vitality = player:GetAttribute("Upgrade_Vitality") or 0,
			Metabolism = player:GetAttribute("Upgrade_Metabolism") or 0,
			Butchery = player:GetAttribute("Upgrade_Butchery") or 0,
		},
	}

	local ok, err = pcall(function()
		PROFILE_STORE:SetAsync(tostring(player.UserId), data)
	end)

	return ok, err
end

function Progression.GetUpgradeCost(player, config, key)
	local upgrade = config.Upgrades[key]
	if not upgrade then
		return nil
	end

	local level = player:GetAttribute("Upgrade_" .. key) or 0
	if level >= upgrade.MaxLevel then
		return nil
	end

	return upgrade.BaseCost + upgrade.CostStep * level
end

function Progression.TryUpgrade(player, config, key)
	local upgrade = config.Upgrades[key]
	if not upgrade then
		return false, "Unknown upgrade."
	end

	local level = player:GetAttribute("Upgrade_" .. key) or 0
	if level >= upgrade.MaxLevel then
		return false, upgrade.DisplayName .. " is already maxed."
	end

	local cost = Progression.GetUpgradeCost(player, config, key)
	local dna = player:GetAttribute("DemonDNA") or 0

	if dna < cost then
		return false, string.format("%s needs %d Demon DNA.", upgrade.DisplayName, cost)
	end

	player:SetAttribute("DemonDNA", dna - cost)
	player:SetAttribute("Upgrade_" .. key, level + 1)

	return true, string.format("%s upgraded to Lv.%d.", upgrade.DisplayName, level + 1)
end

return Progression
