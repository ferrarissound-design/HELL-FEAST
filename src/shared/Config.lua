local Config = {}

Config.RunDuration = 10 * 60
Config.BossWindow = 90
Config.DecisionDuration = 20
Config.IntermissionDuration = 15
Config.MaxCircle = 3

Config.Hunger = {
	Max = 100,
	-- Base body reaches 0 in roughly seven minutes. Grafts increase fuel use.
	BaseDrainPerSecond = 100 / (7 * 60),
	StarvationGraceSeconds = 30,
	StarvationDamagePerSecond = 7,
	DescendRestore = 28,
}

Config.Combat = {
	BaseDamage = 28,
	AttackRange = 9,
	AttackCooldown = 0.55,
	AssistAngleDegrees = 105,
	CloseAssistRange = 5.5,
	AssistFacingWeight = 4.0,
	AttackLungeSpeed = 10,
}

Config.Movement = {
	DashSpeed = 58,
	DashCooldown = 2.8,
	DashHungerCost = 2.5,
}


Config.DemonMovement = {
	ObstacleProbeDistance = 7,
	AvoidAngleDegrees = 52,
	AvoidProbeDistance = 6,
}

Config.Butcher = {
	PhaseTwoHealthRatio = 0.67,
	PhaseThreeHealthRatio = 0.34,
	PhaseTwoSpeedMultiplier = 1.18,
	PhaseThreeSpeedMultiplier = 1.40,
	PhaseTwoSlamCooldown = 6.0,
	PhaseThreeSlamCooldown = 4.8,
	CrossCutCooldown = 10,
	FrenzyCrossCutCooldown = 7,
	CrossCutRange = 27,
	CrossCutWidth = 4.2,
	CrossCutDamageMultiplier = 0.62,
}

Config.Circle = {
	HealthMultiplierPerCircle = 0.28,
	DamageMultiplierPerCircle = 0.18,
	SpawnSpeedPerCircle = 0.12,
	DNARewardMultiplierPerCircle = 0.55,
}

Config.Spawning = {
	DemonInterval = 7,
	MaxDemons = 14,
	SoulInterval = 11,
	MaxSouls = 8,
	SpawnRadiusMin = 55,
	SpawnRadiusMax = 135,
}


Config.Director = {
	TickSeconds = 2,
	BasePressure = 0.46,
	MinPressure = 0.18,
	MaxPressure = 1.0,
	LateRunBoost = 0.24,
	CircleBoost = 0.09,
	ExtraPlayerBoost = 0.07,
	PowerBoost = 0.14,
	LowHealthRelief = 0.22,
	LowHungerRelief = 0.18,
	SpawnIntervalFast = 2.8,
	SpawnIntervalSlow = 8.5,
	BaseDemonCap = 7,
	DemonCapPerPlayer = 3,
	DemonCapPerCircle = 2,
	MaxExtraPressureCap = 5,
	SoulFloorPerPlayer = 2,
	EmergencySoulHungerRatio = 0.24,
	EmergencySoulCooldown = 28,
}


Config.Regions = {
	AshFields = {
		DisplayName = "ASH FIELDS",
		Center = Vector3.new(-82, 0, -34),
		Radius = 48,
		Color = Color3.fromRGB(72, 58, 58),
		PrimaryDemon = "Imp",
	},
	BoneYard = {
		DisplayName = "BONE YARD",
		Center = Vector3.new(-78, 0, 72),
		Radius = 46,
		Color = Color3.fromRGB(76, 72, 62),
		PrimaryDemon = "Brute",
	},
	CinderRun = {
		DisplayName = "CINDER RUN",
		Center = Vector3.new(82, 0, 72),
		Radius = 46,
		Color = Color3.fromRGB(86, 48, 34),
		PrimaryDemon = "FurnaceHound",
	},
	SoulPens = {
		DisplayName = "SOUL PENS",
		Center = Vector3.new(84, 0, -34),
		Radius = 48,
		Color = Color3.fromRGB(58, 50, 82),
		PrimaryDemon = "Watcher",
	},
}

Config.Navigation = {
	KitchenPosition = Vector3.new(0, 3, 0),
	BossPosition = Vector3.new(0, 6, -108),
	LowHungerThreshold = 35,
	CriticalHungerThreshold = 15,
}

Config.Hazards = {
	LavaDamage = 12,
	LavaCooldown = 1.1,
}


Config.Safety = {
	SanctuaryRadius = 31,
	SanctuaryDemonBuffer = 3,
	ArrivalGraceSeconds = 6,
	RecoveryMinY = -18,
	RecoveryMaxAbsX = 174,
	RecoveryMaxAbsZ = 174,
	RecoveryCooldown = 4,
}


Config.Persistence = {
	AutoSaveSeconds = 120,
}


Config.HellBook = {
	DemonOrder = {"Imp", "Brute", "Watcher", "FurnaceHound", "Crawler", "Butcher"},
	PartOrder = {"ImpLegs", "BruteArm", "WatcherEye", "DemonHorn", "DemonWings", "ClawArm", "ButcherArm"},
	DemonNotes = {
		Imp = "ASH FIELDS • Fast, weak, and usually the first meal-ticket of a run.",
		Brute = "BONE YARD • Slow heavy hitter. Its slam can launch careless hunters.",
		Watcher = "SOUL PENS • Marks the ground before striking from range.",
		FurnaceHound = "CINDER RUN • Fast predator with a telegraphed charge.",
		Crawler = "BONE YARD • Tears into both health and hunger.",
		Butcher = "SLAUGHTER PIT • Three-phase boss. Survive the frenzy to leave the circle.",
	},
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
		DNA = 1,
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
		DNA = 3,
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
		DNA = 2,
	},
	FurnaceHound = {
		DisplayName = "Furnace Hound",
		MaxHealth = 120,
		WalkSpeed = 21,
		Damage = 14,
		AttackRange = 5,
		AttackCooldown = 0.95,
		BodyScale = Vector3.new(3.4, 2.8, 5.0),
		PartDrop = "DemonHorn",
		DNA = 3,
		MinimumCircle = 2,
	},
	Crawler = {
		DisplayName = "Bone Crawler",
		MaxHealth = 145,
		WalkSpeed = 16,
		Damage = 17,
		AttackRange = 5.5,
		AttackCooldown = 1.15,
		BodyScale = Vector3.new(4.2, 2.2, 4.2),
		PartDrop = "ClawArm",
		DNA = 4,
		MinimumCircle = 3,
	},
	Butcher = {
		DisplayName = "THE BUTCHER",
		MaxHealth = 1100,
		WalkSpeed = 9,
		Damage = 32,
		AttackRange = 7,
		AttackCooldown = 1.45,
		BodyScale = Vector3.new(8.5, 11.5, 6.5),
		PartDrop = "ButcherArm",
		DNA = 25,
		IsBoss = true,
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
	ButcherArm = {
		DisplayName = "Butcher Arm",
		Slot = "LEFT_ARM",
		DamageMultiplier = 1.55,
		WalkSpeedBonus = -1,
		HungerMultiplier = 1.20,
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

Config.Upgrades = {
	Vitality = {
		DisplayName = "VITALITY",
		BaseCost = 35,
		CostStep = 30,
		MaxLevel = 10,
		MaxHealthPerLevel = 6,
	},
	Metabolism = {
		DisplayName = "METABOLISM",
		BaseCost = 45,
		CostStep = 35,
		MaxLevel = 8,
		MaxHungerPerLevel = 5,
	},
	Butchery = {
		DisplayName = "BUTCHERY",
		BaseCost = 55,
		CostStep = 40,
		MaxLevel = 8,
		DamagePerLevel = 0.05,
	},
}

return Config
