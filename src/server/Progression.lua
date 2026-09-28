local DataStoreService = game:GetService("DataStoreService")

local Progression = {}

local PROFILE_STORE = DataStoreService:GetDataStore("HellFeast_Profile_v2")
local LEGACY_DNA_STORE = DataStoreService:GetDataStore("HellFeast_DemonDNA_v1")

local SAVE_ATTEMPTS = 3
local SAVE_RETRY_SECONDS = 0.75

local DEMON_KEYS = {"Imp", "Brute", "Watcher", "FurnaceHound", "Crawler", "Butcher"}
local PART_KEYS = {"ImpLegs", "BruteArm", "ButcherArm", "WatcherEye", "DemonHorn", "DemonWings", "ClawArm"}

local DEFAULT_PROFILE = {
	DemonDNA = 0,
	BestCircle = 0,
	TotalRuns = 0,
	TotalKills = 0,
	TotalBossKills = 0,
	Upgrades = {
		Vitality = 0,
		Metabolism = 0,
		Butchery = 0,
	},
	Discovery = {
		Demons = {},
		Parts = {},
	},
}

local function cloneDefaults()
	return {
		DemonDNA = DEFAULT_PROFILE.DemonDNA,
		BestCircle = DEFAULT_PROFILE.BestCircle,
		TotalRuns = DEFAULT_PROFILE.TotalRuns,
		TotalKills = DEFAULT_PROFILE.TotalKills,
		TotalBossKills = DEFAULT_PROFILE.TotalBossKills,
		Upgrades = {
			Vitality = DEFAULT_PROFILE.Upgrades.Vitality,
			Metabolism = DEFAULT_PROFILE.Upgrades.Metabolism,
			Butchery = DEFAULT_PROFILE.Upgrades.Butchery,
		},
		Discovery = {
			Demons = {},
			Parts = {},
		},
	}
end

local function copyDiscovery(source, keys)
	local result = {}
	if type(source) ~= "table" then
		return result
	end

	for _, key in ipairs(keys) do
		result[key] = source[key] == true
	end
	return result
end

function Progression.Load(player, config)
	local profile = cloneDefaults()
	local loaded = false

	local ok, data = pcall(function()
		return PROFILE_STORE:GetAsync(tostring(player.UserId))
	end)

	local profileReadSucceeded = ok and (data == nil or type(data) == "table")

	if ok and type(data) == "table" then
		loaded = true
		profile.DemonDNA = tonumber(data.DemonDNA) or 0
		profile.BestCircle = tonumber(data.BestCircle) or 0
		profile.TotalRuns = tonumber(data.TotalRuns) or 0
		profile.TotalKills = tonumber(data.TotalKills) or 0
		profile.TotalBossKills = tonumber(data.TotalBossKills) or 0

		if type(data.Upgrades) == "table" then
			for key in pairs(profile.Upgrades) do
				profile.Upgrades[key] = math.max(0, math.floor(tonumber(data.Upgrades[key]) or 0))
			end
		end

		if type(data.Discovery) == "table" then
			profile.Discovery.Demons = copyDiscovery(data.Discovery.Demons, DEMON_KEYS)
			profile.Discovery.Parts = copyDiscovery(data.Discovery.Parts, PART_KEYS)
		end
	elseif ok and data == nil then
		local legacyOk, legacyDNA = pcall(function()
			return LEGACY_DNA_STORE:GetAsync(tostring(player.UserId))
		end)

		if legacyOk then
			profile.DemonDNA = tonumber(legacyDNA) or 0
		else
			profileReadSucceeded = false
		end
	end

	player:SetAttribute("ProfileReady", profileReadSucceeded)
	player:SetAttribute("ProgressionReadOnly", not profileReadSucceeded)
	player:SetAttribute("SaveFailureCount", 0)

	player:SetAttribute("DemonDNA", profile.DemonDNA)
	player:SetAttribute("BestCircle", profile.BestCircle)
	player:SetAttribute("TotalRuns", profile.TotalRuns)
	player:SetAttribute("TotalKills", profile.TotalKills)
	player:SetAttribute("TotalBossKills", profile.TotalBossKills)

	for key, level in pairs(profile.Upgrades) do
		local upgrade = config.Upgrades[key]
		if upgrade then
			level = math.clamp(level, 0, upgrade.MaxLevel)
		end
		player:SetAttribute("Upgrade_" .. key, level)
	end

	for _, key in ipairs(DEMON_KEYS) do
		player:SetAttribute("Book_Demon_" .. key, profile.Discovery.Demons[key] == true)
	end

	for _, key in ipairs(PART_KEYS) do
		player:SetAttribute("Book_Part_" .. key, profile.Discovery.Parts[key] == true)
	end

	return profile, profileReadSucceeded
end

function Progression.Save(player)
	if player:GetAttribute("ProgressionReadOnly") == true or player:GetAttribute("ProfileReady") ~= true then
		return false, "Profile load was not confirmed; save blocked to protect existing data."
	end
	local demons = {}
	local parts = {}

	for _, key in ipairs(DEMON_KEYS) do
		demons[key] = player:GetAttribute("Book_Demon_" .. key) == true
	end

	for _, key in ipairs(PART_KEYS) do
		parts[key] = player:GetAttribute("Book_Part_" .. key) == true
	end

	local data = {
		DemonDNA = player:GetAttribute("DemonDNA") or 0,
		BestCircle = player:GetAttribute("BestCircle") or 0,
		TotalRuns = player:GetAttribute("TotalRuns") or 0,
		TotalKills = player:GetAttribute("TotalKills") or 0,
		TotalBossKills = player:GetAttribute("TotalBossKills") or 0,
		Upgrades = {
			Vitality = player:GetAttribute("Upgrade_Vitality") or 0,
			Metabolism = player:GetAttribute("Upgrade_Metabolism") or 0,
			Butchery = player:GetAttribute("Upgrade_Butchery") or 0,
		},
		Discovery = {
			Demons = demons,
			Parts = parts,
		},
	}

	local lastError
	for attempt = 1, SAVE_ATTEMPTS do
		local ok, err = pcall(function()
			PROFILE_STORE:UpdateAsync(tostring(player.UserId), function()
				return data
			end)
		end)

		if ok then
			player:SetAttribute("SaveFailureCount", 0)
			player:SetAttribute("LastSaveFailed", false)
			player:SetAttribute("SaveWarningShown", false)
			return true
		end

		lastError = err
		player:SetAttribute("SaveFailureCount", attempt)
		player:SetAttribute("LastSaveFailed", true)

		if attempt < SAVE_ATTEMPTS then
			task.wait(SAVE_RETRY_SECONDS * attempt)
		end
	end

	return false, lastError
end

function Progression.Discover(player, category, key)
	local prefix
	if category == "Demon" then
		prefix = "Book_Demon_"
	elseif category == "Part" then
		prefix = "Book_Part_"
	else
		return false
	end

	local attribute = prefix .. key
	if player:GetAttribute(attribute) == true then
		return false
	end

	player:SetAttribute(attribute, true)
	return true
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
	if player:GetAttribute("ProgressionReadOnly") == true then
		return false, "Progression is temporarily read-only on this server."
	end

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
