local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

if not RunService:IsStudio() then
	return
end

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local passed = 0
local failed = 0

Workspace:SetAttribute("QAStatus", "RUNNING")
Workspace:SetAttribute("QAPassed", 0)
Workspace:SetAttribute("QAFailed", 0)

local function check(condition, message)
	if condition then
		passed += 1
		print("[HELL FEAST QA] PASS • " .. message)
	else
		failed += 1
		warn("[HELL FEAST QA] FAIL • " .. message)
	end
end

task.wait(1)

check(type(Config.BuildId) == "string" and Config.BuildId ~= "", "release build ID exists")
check(Workspace:GetAttribute("BuildId") == Config.BuildId, "Workspace build ID matches Config")
check(type(Workspace:GetAttribute("WatchdogRecoveries")) == "number", "watchdog recovery telemetry exists")
check(type(Workspace:GetAttribute("SecurityRejects")) == "number", "security rejection telemetry exists")

for demonKey, demon in pairs(Config.Demons) do
	check(type(demon.DisplayName) == "string" and demon.DisplayName ~= "", demonKey .. " has DisplayName")
	check(type(demon.MaxHealth) == "number" and demon.MaxHealth > 0, demonKey .. " has valid health")
	check(type(demon.Damage) == "number" and demon.Damage >= 0, demonKey .. " has valid damage")
	check(Config.Parts[demon.PartDrop] ~= nil, demonKey .. " drop exists: " .. tostring(demon.PartDrop))
end

for _, key in ipairs(Config.HellBook.DemonOrder) do
	check(Config.Demons[key] ~= nil, "HELL BOOK demon exists: " .. key)
end

for _, key in ipairs(Config.HellBook.PartOrder) do
	check(Config.Parts[key] ~= nil, "HELL BOOK graft exists: " .. key)
end

for regionKey, region in pairs(Config.Regions) do
	check(typeof(region.Center) == "Vector3", regionKey .. " has region center")
	check(type(region.Radius) == "number" and region.Radius > 0, regionKey .. " has region radius")
	if region.PrimaryDemon then
		check(Config.Demons[region.PrimaryDemon] ~= nil, regionKey .. " primary demon exists")
	end
end

for recipeKey, recipe in pairs(Config.Recipes) do
	check(type(recipe.SoulCost) == "number" and recipe.SoulCost >= 1, recipeKey .. " has valid Soul cost")
	check(type(recipe.HungerRestore) == "number" and recipe.HungerRestore >= 0, recipeKey .. " has valid hunger restore")
end

for upgradeKey, upgrade in pairs(Config.Upgrades) do
	check(type(upgrade.DisplayName) == "string" and upgrade.DisplayName ~= "", upgradeKey .. " has DisplayName")
	check(type(upgrade.BaseCost) == "number" and upgrade.BaseCost > 0, upgradeKey .. " has valid base DNA cost")
	check(type(upgrade.CostStep) == "number" and upgrade.CostStep >= 0, upgradeKey .. " has valid cost step")
	check(type(upgrade.MaxLevel) == "number" and upgrade.MaxLevel >= 1, upgradeKey .. " has valid max level")
end

check(type(Config.Combat.AssistAngleDegrees) == "number" and Config.Combat.AssistAngleDegrees > 0 and Config.Combat.AssistAngleDegrees <= 180, "melee assist angle is valid")
check(type(Config.Combat.CloseAssistRange) == "number" and Config.Combat.CloseAssistRange > 0 and Config.Combat.CloseAssistRange <= Config.Combat.AttackRange, "melee close-assist range is valid")
check(type(Config.Combat.AttackLungeSpeed) == "number" and Config.Combat.AttackLungeSpeed >= 0, "melee lunge speed is valid")

check(type(Config.DemonMovement.ObstacleProbeDistance) == "number" and Config.DemonMovement.ObstacleProbeDistance > 0, "demon obstacle probe is valid")
check(type(Config.DemonMovement.AvoidAngleDegrees) == "number" and Config.DemonMovement.AvoidAngleDegrees > 20 and Config.DemonMovement.AvoidAngleDegrees < 90, "demon avoid angle is valid")
check(type(Config.DemonMovement.AvoidProbeDistance) == "number" and Config.DemonMovement.AvoidProbeDistance > 0, "demon avoid probe is valid")

check(type(Config.Persistence.AutoSaveSeconds) == "number" and Config.Persistence.AutoSaveSeconds >= 60, "autosave interval is valid")


check(type(Config.Security.DashRemoteMinInterval) == "number" and Config.Security.DashRemoteMinInterval > 0, "dash remote rate guard is valid")
check(type(Config.Security.DecisionRemoteMinInterval) == "number" and Config.Security.DecisionRemoteMinInterval > 0, "decision remote rate guard is valid")
check(type(Config.Security.DebugRemoteMinInterval) == "number" and Config.Security.DebugRemoteMinInterval > 0, "debug remote rate guard is valid")
check(type(Config.Security.MaxClientDirectionMagnitude) == "number" and Config.Security.MaxClientDirectionMagnitude >= 1, "client direction magnitude limit is valid")

check(type(Config.Watchdog.TickSeconds) == "number" and Config.Watchdog.TickSeconds > 0, "watchdog tick is valid")
check(type(Config.Watchdog.BossMissingGraceSeconds) == "number" and Config.Watchdog.BossMissingGraceSeconds >= Config.Watchdog.TickSeconds, "watchdog boss grace is valid")
check(type(Config.Watchdog.EmptyRunGraceSeconds) == "number" and Config.Watchdog.EmptyRunGraceSeconds >= Config.Watchdog.TickSeconds, "watchdog empty-run grace is valid")
check(type(Config.Watchdog.DecisionOvertimeSeconds) == "number" and Config.Watchdog.DecisionOvertimeSeconds > 0, "watchdog decision overtime is valid")
check(type(Config.Watchdog.RecoveryCooldownSeconds) == "number" and Config.Watchdog.RecoveryCooldownSeconds > 0, "watchdog recovery cooldown is valid")

check(type(Config.Safety.SanctuaryRadius) == "number" and Config.Safety.SanctuaryRadius > 20, "sanctuary radius is valid")
check(type(Config.Safety.ArrivalGraceSeconds) == "number" and Config.Safety.ArrivalGraceSeconds >= 3, "arrival grace is valid")
check(Config.Safety.RecoveryMinY < 0, "out-of-bounds Y threshold is valid")
check(Config.Safety.RecoveryMaxAbsX > 160 and Config.Safety.RecoveryMaxAbsZ > 160, "arena recovery bounds are valid")

check(type(Config.Director.TickSeconds) == "number" and Config.Director.TickSeconds > 0, "Hell Director tick is valid")
check(Config.Director.SpawnIntervalFast < Config.Director.SpawnIntervalSlow, "Hell Director spawn interval range is ordered")
check(Config.Director.MinPressure < Config.Director.MaxPressure, "Hell Director pressure range is ordered")
check(Config.Director.EmergencySoulHungerRatio > 0 and Config.Director.EmergencySoulHungerRatio < 1, "Hell Director emergency hunger threshold is valid")

local world = Workspace:WaitForChild("HellFeastWorld", 10)
check(world ~= nil, "HellFeastWorld exists")

if world then
	for _, folderName in ipairs({"Demons", "LostSouls", "Drops", "Hazards", "HellKitchen", "Regions"}) do
		check(world:FindFirstChild(folderName) ~= nil, "world contains " .. folderName)
	end

	local kitchen = world:FindFirstChild("HellKitchen")
	check(kitchen and kitchen:FindFirstChild("SanctuaryBoundary") ~= nil, "HELL KITCHEN sanctuary boundary exists")
end

local remotes = ReplicatedStorage:WaitForChild("HellFeastRemotes", 10)
check(remotes ~= nil, "remote folder exists")
if remotes then
	for _, remoteName in ipairs({"Notify", "Feedback", "Dash", "DecisionVote", "DebugCommand"}) do
		check(remotes:FindFirstChild(remoteName) ~= nil, "remote exists: " .. remoteName)
	end
end

Workspace:SetAttribute("QAPassed", passed)
Workspace:SetAttribute("QAFailed", failed)
Workspace:SetAttribute("QAStatus", failed == 0 and "PASS" or "FAIL")
Workspace:SetAttribute("QASummary", string.format("%d passed • %d failed", passed, failed))

if failed == 0 then
	print(string.format("[HELL FEAST QA] ALL CHECKS PASSED • %d checks • %s", passed, Config.BuildId))
else
	warn(string.format("[HELL FEAST QA] COMPLETE • %d passed • %d failed • %s", passed, failed, Config.BuildId))
end
