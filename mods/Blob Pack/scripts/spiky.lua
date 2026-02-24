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

local name = "spikygoo" 

modApi:appendAsset(writepath..name..".png", readpath..name..".png")
modApi:appendAsset(writepath..name.."2.png", readpath..name.."2.png")

-- modApi:appendAsset(writepath..name.."a.png", readpath..name.."a.png")
-- modApi:appendAsset(writepath.."emergegoo.png", readpath.."emergegoo.png")
-- modApi:appendAsset(writepath..name.."_death.png", readpath..name.."_death.png")

modApi:appendAsset("img/effects/shotup_goospikes.png", resourcePath.."img/effects/shotup_goospikes.png")
modApi:appendAsset("img/effects/goorocker_D.png", resourcePath.."img/effects/goorocker_D.png")
modApi:appendAsset("img/effects/goorocker_U.png", resourcePath.."img/effects/goorocker_U.png")
modApi:appendAsset("img/effects/goorocker_R.png", resourcePath.."img/effects/goorocker_R.png")
modApi:appendAsset("img/effects/goorocker_L.png", resourcePath.."img/effects/goorocker_L.png")

a.Meta_spikygoo = a.EnemyUnit:new{Image = imagepath .. name..".png", PosX = -20, PosY = -5, Height = 1}
a.Meta_spikygooe = a.BaseEmerge:new{Image = imagepath .. "emergegoo.png", PosX = -23, PosY = -5, NumFrames = 10, Height = 1}
a.Meta_spikygooa = a.Meta_spikygoo:new{ Image = imagepath..name..".png", NumFrames = 1 }
a.Meta_spikygood = a.Meta_spikygoo:new{ Image = imagepath.."deathgoo.png", NumFrames = 7, Loop = false }

a.Meta_spikygoo2 = a.EnemyUnit:new{Image = imagepath .. name.."2.png", PosX = -20, PosY = -10, Height = 1}
a.Meta_spikygoo2e = a.BaseEmerge:new{Image = imagepath .. "emergegoobig.png", PosX = -23, PosY = 5, NumFrames = 12, Height = 1}
a.Meta_spikygoo2a = a.Meta_spikygoo2:new{ Image = imagepath..name.."2.png", NumFrames = 1 }
a.Meta_spikygoo2d = a.Meta_spikygoo2:new{ Image = imagepath.."deathgoobig.png", NumFrames = 7, Loop = false }


a.gooRocker_0 = Animation:new{
	Image = "effects/goorocker_U.png",
	NumFrames = 11,
	Lengths = {0.06,0.06,0.06,0.06,1.0,0.06,0.06,0.06,0.06,0.06,0.06},
	PosX = -20,
	PosY = 8
}

a.gooRocker_1 = a.gooRocker_0:new{
	Image = "effects/goorocker_R.png",
	PosX = -23,
	PosY = -2
}

a.gooRocker_2 = a.gooRocker_0:new{
	Image = "effects/goorocker_D.png",
	PosX = -16,
	PosY = -3
}

a.gooRocker_3 = a.gooRocker_0:new{
	Image = "effects/goorocker_L.png",
	PosX = -16,
	PosY = 11
}


-------------
-- Weapons --
-------------

Meta_spikygooAtk1 = Skill:new{
	Name = "Spike Toss",
	Description = "Tosses a bundle of spikes at an empty tile. If not intercepted, it will explode, damaging adjacent tiles. If intercepted, it will damage the target and injure it, causing it to lose health when moved.",
	Class = "Enemy",
	SoundBase = "/enemy/scarab_1",
	Icon = "weapons/enemy_centipede1.png",
	PathSize = 8,
	Damage = 1,
	Range = 8,
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,2),
		Enemy1 = Point(1,2),
		Enemy2 = Point(3,2),
		CustomPawn = "Meta_spikygoo1",
	}
}

function Meta_spikygooAtk1:GetTargetArea(point)
	ret = PointList()
	for i = DIR_START, DIR_END do
		for j = 2, 8 do
			local curr = point + DIR_VECTORS[i] * j
			-- if not Board:IsBlocked(curr, PATH_PROJECTILE) then ret:push_back(curr) end
			ret:push_back(curr)
		end
	end
	return ret
end

function Meta_spikygooAtk1:GetSkillEffect(p1,p2)
	ret = SkillEffect()
	
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
	
	if Board:IsBlocked(p2, PATH_PROJECTILE) then
		local injuryDamage = SpaceDamage(p2, self.Damage)
		injuryDamage.iInjure = 1
		ret:AddQueuedArtillery(injuryDamage, "effects/shotup_goospikes.png", PROJ_DELAY)
	else
		ret:AddQueuedArtillery(SpaceDamage(p2, 0), "effects/shotup_goospikes.png", PROJ_DELAY)
		for i = DIR_START, DIR_END do
			local damage = SpaceDamage(p2 + DIR_VECTORS[i], self.Damage)
			damage.sAnimation = "gooRocker_"..i
			ret:AddQueuedDamage(damage)
		end
	end
	return ret
end

function Meta_spikygooAtk1:GetTargetScore(p1, p2)
	if Board:IsBlocked(p2, PATH_PROJECTILE) then return -100 end
	return self:ScoreList(self:GetSkillEffect(p1,p2).q_effect, true)
end

Meta_spikygooAtk2 = Meta_spikygooAtk1:new{
	Name = "Spike Hurl",
	Description = "Tosses a bundle of spikes at an empty tile. If not intercepted, it will explode, damaging adjacent tiles. If intercepted, it will damage the target and injure it, causing it to lose health when moved.",
	Damage = 2,
}

-----------
-- Pawns --
-----------


Meta_spikygoo1 = Pawn:new{
	Name = "Spiky Goo",
	Health = 2,
	MoveSpeed = 3,
	Image = "Meta_spikygoo",
	Ranged = 1,
	SkillList = { "Meta_spikygooAtk1" },
	SoundLocation = "/enemy/goo_boss/",
	Portrait = "enemy/BlobBoss",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB,
}
AddPawn("Meta_spikygoo1")

Meta_spikygoo2 = Pawn:new{
	Name = "Alpha Spiky Goo",
	Health = 4,
	MoveSpeed = 3,
	Image = "Meta_spikygoo2",
	Ranged = 1,
	SkillList = { "Meta_spikygooAtk2" },
	SoundLocation = "/enemy/goo_boss/",
	Portrait = "enemy/BlobBoss",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB,
	Tier = TIER_ALPHA,
}
AddPawn("Meta_spikygoo2")

