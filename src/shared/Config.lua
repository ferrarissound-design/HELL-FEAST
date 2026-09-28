local Config = {}

Config.RunDuration = 10 * 60
Config.IntermissionDuration = 15

Config.Hunger = {
	Max = 100,
	-- A fresh player reaches 0 in roughly seven minutes before modifiers.
	BaseDrainPerSecond = 100 / (7 * 60),
	StarvationGraceSeconds = 30,
	StarvationDamagePerSecond = 7,
}

Config.Combat = {
	BaseDamage = 28,
	AttackRange = 9,
	AttackCooldown = 0.55,
}

Config.Spawning = {
	DemonInterval = 7,
	MaxDemons = 14,
	SoulInterval = 11,
	MaxSouls = 8,
	SpawnRadiusMin = 55,
	SpawnRadiusMax = 135,
}

Config.Demons = {
	Imp = {
		DisplayName = "Imp",
		MaxHealth = 70,
		WalkSpeed = 18,
		Damage = 8,
		AttackRange = 5,
		AttackCooldown = 1.2,
		BodyScale = Vector3.new(2.4, 3.6, 2.1),
		PartDrop = "ImpLegs",
	},
	Brute = {
		DisplayName = "Horned Brute",
		MaxHealth = 180,
		WalkSpeed = 10,
		Damage = 20,
		AttackRange = 6,
		AttackCooldown = 1.8,
		BodyScale = Vector3.new(4.5, 6.0, 3.5),
		PartDrop = "BruteArm",
	},
	Watcher = {
		DisplayName = "Watcher",
		MaxHealth = 95,
		WalkSpeed = 13,
		Damage = 12,
		AttackRange = 7,
		AttackCooldown = 1.5,
		BodyScale = Vector3.new(3.3, 4.0, 3.0),
		PartDrop = "WatcherEye",
	},
}

Config.Parts = {
	ImpLegs = {
		DisplayName = "Imp Legs",
		Slot = "LEGS",
		WalkSpeedBonus = 5,
		HungerMultiplier = 1.08,
	},
	BruteArm = {
		DisplayName = "Brute Arm",
		Slot = "LEFT_ARM",
		DamageMultiplier = 1.30,
		HungerMultiplier = 1.12,
	},
	WatcherEye = {
		DisplayName = "Watcher Eye",
		Slot = "EYE",
		DamageMultiplier = 1.08,
		HungerMultiplier = 1.05,
	},
	DemonHorn = {
		DisplayName = "Demon Horn",
		Slot = "HEAD",
		DamageMultiplier = 1.15,
		HungerMultiplier = 1.06,
	},
	DemonWings = {
		DisplayName = "Demon Wings",
		Slot = "BACK",
		WalkSpeedBonus = 3,
		HungerMultiplier = 1.10,
	},
	ClawArm = {
		DisplayName = "Claw Arm",
		Slot = "RIGHT_ARM",
		DamageMultiplier = 1.18,
		HungerMultiplier = 1.08,
	},
}

Config.Recipes = {
	HellPie = {
		DisplayName = "HELL PIE",
		SoulCost = 1,
		HungerRestore = 50,
		Heal = 0,
	},
	SoulBurger = {
		DisplayName = "SOUL BURGER",
		SoulCost = 1,
		HungerRestore = 30,
		Heal = 40,
	},
	SinnerStew = {
		DisplayName = "SINNER STEW",
		SoulCost = 2,
		HungerRestore = 25,
		Heal = 10,
		SlowHungerSeconds = 35,
	},
}

return Config
