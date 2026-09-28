local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

if not RunService:IsStudio() then
	return
end

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local passed = 0
local failed = 0

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
end

local remotes = ReplicatedStorage:WaitForChild("HellFeastRemotes", 10)
check(remotes ~= nil, "remote folder exists")
if remotes then
	for _, remoteName in ipairs({"Notify", "Feedback", "Dash", "DecisionVote", "DebugCommand"}) do
		check(remotes:FindFirstChild(remoteName) ~= nil, "remote exists: " .. remoteName)
	end
end

if failed == 0 then
	print(string.format("[HELL FEAST QA] ALL CHECKS PASSED • %d checks", passed))
else
	warn(string.format("[HELL FEAST QA] COMPLETE • %d passed • %d failed", passed, failed))
end
