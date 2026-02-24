local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath
--local previewer = require(scriptPath.."weaponPreview/api")

local writepath = "img/units/aliens/"
local readpath = resourcePath .. writepath
local imagepath = writepath:sub(5,-1)
local a = ANIMS

local function IsTipImage()
	return Board:GetSize() == Point(6,6)
end

-------------
--   Art   --
-------------

local name = "pylongoo" 

modApi:appendAsset(writepath..name..".png", readpath..name..".png")
modApi:appendAsset(writepath..name.."2.png", readpath..name.."2.png")
modApi:appendAsset(writepath.."pylon.png", readpath.."pylon.png")
modApi:appendAsset(writepath.."pylond.png", readpath.."pylond.png")
modApi:appendAsset(writepath.."pylone.png", readpath.."pylone.png")
modApi:appendAsset(writepath.."pylonw.png", readpath.."pylonw.png")

-- modApi:appendAsset(writepath..name.."a.png", readpath..name.."a.png")
-- modApi:appendAsset(writepath.."emergegoo.png", readpath.."emergegoo.png")
-- modApi:appendAsset(writepath..name.."_death.png", readpath..name.."_death.png")

local base = a.EnemyUnit:new{Image = imagepath .. name..".png", PosX = -20, PosY = 5, Height = 1}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "emergegoobig.png", PosX = -20, PosY = 5, NumFrames = 12, Height = 1}

a.Meta_pylongoo = base
a.Meta_pylongooe = baseEmerge
a.Meta_pylongooa = base:new{ Image = imagepath..name..".png", NumFrames = 1 }
a.Meta_pylongood = base:new{ Image = imagepath.."deathgoobig.png", PosX = -23, PosY = 5, NumFrames = 7, Loop = false }

a.Meta_pylongoo2 = a.EnemyUnit:new{Image = imagepath .. name.."2.png", PosX = -25, PosY = -10, Height = 1}
a.Meta_pylongoo2e = a.BaseEmerge:new{Image = imagepath .. "emergegoohuge.png", PosX = -23, PosY = -5, NumFrames = 14, Height = 1}
a.Meta_pylongoo2a = base:new{ Image = imagepath..name.."2.png", PosX = -25, PosY = -10, NumFrames = 1 }
a.Meta_pylongoo2d = base:new{ Image = imagepath.."deathgoohuge.png", PosX = -23, PosY = -5, NumFrames = 7, Loop = false }

a.Meta_pylon = a.EnemyUnit:new{Image = imagepath .. "pylon.png", PosX = -13, PosY = 0, Height = 1}
a.Meta_pylone = a.BaseEmerge:new{Image = imagepath.. "pylone.png", PosX = -13, PosY = 5, NumFrames = 10, Height = 1}
a.Meta_pylona = a.Meta_pylon:new{ Image = imagepath.."pylon.png", NumFrames = 1 }
a.Meta_pylonw = a.Meta_pylon:new{ Image = imagepath.."pylonw.png", NumFrames = 1, PosY = 5 }
a.Meta_pylond = a.Meta_pylon:new{ Image = imagepath.."pylond.png", NumFrames = 12, Loop = false }


-------------
-- Weapons --
-------------

Meta_pylongooAtk1 = Laser_Base:new{
	Name = "Discharge",
	Description = "Fires a beam of electricity.",
	Class = "Enemy",
	SoundBase = "/enemy/scarab_1",
	LaserArt = "effects/laser_elec",
	Icon = "weapons/enemy_centipede1.png",
	PathSize = 1,
	Damage = 2,
	SelfDamage = 1,
	Range = 1,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy1 = Point(2,2),
		Enemy2 = Point(2,1),
		Building = Point(2,0),
		CustomPawn = "Meta_pylongoo1",
	}
}

function Meta_pylongooAtk1:GetTargetArea(point)
	local ret = PointList()
	for i = DIR_START, DIR_END do
		ret:push_back(point + DIR_VECTORS[i])
	end
	return ret
end

function Meta_pylongooAtk1:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local target = p1 + DIR_VECTORS[direction]
	
	local blob = Board:GetPawn(p1)
	if not blob then return ret end
	--check for adjacent gunk to eat unqueued, used on all goos
	for i = DIR_START, DIR_END do
		local curr = p1 + DIR_VECTORS[i]
		local gunkedPawn = Board:GetPawn(curr)
		if gunkedPawn and Status.GetStatus(gunkedPawn:GetId(), "Gunk") then
			ret:AddScript(string.format("Status.HealFromGunk(%s)", blob:GetId()))
			ret:AddScript(string.format("Status.RemoveStatus(%s, Gunk)", gunkedPawn:GetId()))
		end
	end
	
	ret:AddQueuedDamage(SpaceDamage(p1, self.SelfDamage))
	self:AddQueuedLaser(ret, target, direction)
	return ret
end

Meta_pylongooAtk2 = Meta_pylongooAtk1:new{
	Name = "Discharge",
	Description = "Fires a beam of electricity.",
	Class = "Enemy",
	SoundBase = "/enemy/scarab_1",
	LaserArt = "effects/laser_elec",
	Icon = "weapons/enemy_centipede1.png",
	PathSize = 1,
	Damage = 3,
	SelfDamage = 1,
	Range = 1,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy1 = Point(2,2),
		Enemy2 = Point(2,1),
		Building = Point(2,0),
		CustomPawn = "Meta_pylongoo1",
	}
}

-----------
-- Pawns --
-----------


Meta_pylongoo1 = Pawn:new{
	Name = "Pylon Goo",
	Health = 2,
	MoveSpeed = 3,
	Image = "Meta_pylongoo",
	Ranged = 1,
	SkillList = { "Meta_pylongooAtk1" },
	SoundLocation = "/enemy/goo_boss/",
	Portrait = "enemy/BlobBoss",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB,
	IsDeathEffect = true,
	OnAppliedGunk = Status.HealFromGunk,
}
AddPawn("Meta_pylongoo1")

function Meta_pylongoo1:GetDeathEffect(point)
	local ret = SkillEffect()
	if not Board:IsBlocked(point, PATH_MASSIVE) then --prevents spawning on chasms/units
		if Board:GetTerrain(point) == TERRAIN_WATER then 
			ret:AddScript(string.format("Board:AddPawn(%q, %s)", "Meta_pylon", point:GetString()))
		else
			ret:AddScript(string.format("Board:SpawnPawn(%q, %s)", "Meta_pylon", point:GetString()))
		end
	end
	return ret
end

Meta_pylon = Pawn:new{
	Name = "Pylon",
	Neutral = true,
	Health = 1,
	MoveSpeed = 0,
	Image = "Meta_pylon",
	IgnoreFire = true,
	Pushable = false,
	SkillList = { },
	IsPortrait = false,
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
	IsDeathEffect = true,
}
AddPawn("Meta_pylongoo1")

function Meta_pylon:GetDeathEffect(point)
	Game:ModifyPowerGrid(-1)
	return SkillEffect()
end

Meta_pylongoo2 = Meta_pylongoo1:new{
	Name = "Alpha Pylon Goo",
	Health = 4,
	MoveSpeed = 3,
	Image = "Meta_pylongoo2",
	Ranged = 1,
	SkillList = { "Meta_pylongooAtk2" },
	SoundLocation = "/enemy/goo_boss/",
	Portrait = "enemy/BlobBoss",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB,
	Tier = TIER_ALPHA,
	IsDeathEffect = true,
	OnAppliedGunk = Status.HealFromGunk,
}
AddPawn("Meta_pylongoo2")

function Meta_pylongoo2:GetDeathEffect(point)
	local ret = SkillEffect()
	if not Board:IsBlocked(point, PATH_MASSIVE) then --prevents spawning on chasms/units
		if Board:GetTerrain(point) == TERRAIN_WATER then 
			ret:AddScript(string.format("Board:AddPawn(%q, %s)", "Meta_pylon", point:GetString()))
		else
			ret:AddScript(string.format("Board:SpawnPawn(%q, %s)", "Meta_pylon", point:GetString()))
		end
	end
	return ret
end

