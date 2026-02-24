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

local name = "shapeshifter" 

modApi:appendAsset(writepath..name..".png", readpath..name..".png")
-- modApi:appendAsset(writepath..name.."a.png", readpath..name.."a.png")
modApi:appendAsset(writepath.."emergegoo.png", readpath.."emergegoo.png")
modApi:appendAsset(writepath.."emergegoobig.png", readpath.."emergegoobig.png")
modApi:appendAsset(writepath.."emergegoohuge.png", readpath.."emergegoohuge.png")
modApi:appendAsset(writepath.."deathgoo.png", readpath.."deathgoo.png")
modApi:appendAsset(writepath.."deathgoobig.png", readpath.."deathgoobig.png")
modApi:appendAsset(writepath.."deathgoohuge.png", readpath.."deathgoohuge.png")
-- modApi:appendAsset(writepath..name.."_death.png", readpath..name.."_death.png")
modApi:appendAsset("img/effects/goomosquito_D.png", resourcePath.."img/effects/goomosquito_D.png")
modApi:appendAsset("img/effects/goomosquito_L.png", resourcePath.."img/effects/goomosquito_L.png")
modApi:appendAsset("img/effects/goomosquito_R.png", resourcePath.."img/effects/goomosquito_R.png")
modApi:appendAsset("img/effects/goomosquito_U.png", resourcePath.."img/effects/goomosquito_U.png")

modApi:appendAsset("img/effects/goostarfish_D.png", resourcePath.."img/effects/goostarfish_D.png")
modApi:appendAsset("img/effects/goostarfish_L.png", resourcePath.."img/effects/goostarfish_L.png")
modApi:appendAsset("img/effects/goostarfish_R.png", resourcePath.."img/effects/goostarfish_R.png")
modApi:appendAsset("img/effects/goostarfish_U.png", resourcePath.."img/effects/goostarfish_U.png")

modApi:appendAsset("img/portraits/enemy/Goo.png", resourcePath.."img/portraits/enemy/Goo.png")

modApi:appendAsset(writepath..name.."_centipedea.png", readpath..name.."_centipedea.png")
modApi:appendAsset(writepath..name.."_centipeded.png", readpath..name.."_centipeded.png")
modApi:appendAsset(writepath..name.."_centipedee.png", readpath..name.."_centipedee.png")
modApi:appendAsset(writepath..name.."_starfisha.png", readpath..name.."_starfisha.png")
modApi:appendAsset(writepath..name.."_starfishd.png", readpath..name.."_starfishd.png")
modApi:appendAsset(writepath..name.."_starfishe.png", readpath..name.."_starfishe.png")

local base = a.EnemyUnit:new{Image = imagepath .. name..".png", PosX = -23, PosY = -5, Height = 1}
local baseEmerge = a.BaseEmerge:new{Image = imagepath .. "emergegoo.png", PosX = -23, PosY = -5, NumFrames = 10, Height = 1}


a.Meta_shapeshifter = base
a.Meta_shapeshifter_centipede = base
a.Meta_shapeshifter_starfish = base
a.Meta_shapeshiftere = baseEmerge
a.Meta_shapeshiftera = base:new{ Image = imagepath.."shapeshifter_centipedea.png", NumFrames = 4, PosY = 10 }
-- a.Meta_shapeshifterd = base:new{ Image = imagepath..name.."_death.png", Loop = false, NumFrames = 8, Time = .15 }
a.Meta_shapeshifter_centipedee = base:new{ Image = imagepath.."shapeshifter_centipedee.png", NumFrames = 10 }
a.Meta_shapeshifter_centipedea = base:new{ Image = imagepath.."shapeshifter_centipedea.png", NumFrames = 4, PosY = 10 }
a.Meta_shapeshifter_centipeded = base:new{ Image = imagepath.."shapeshifter_centipeded.png", Loop = false, NumFrames = 8, Time = .15 }
a.Meta_shapeshifter_starfishe = base:new{ Image = imagepath.."shapeshifter_starfishe.png", NumFrames = 10 }
a.Meta_shapeshifter_starfisha = base:new{ Image = imagepath.."shapeshifter_starfisha.png", NumFrames = 4, PosX = -25, PosY = 0 }
a.Meta_shapeshifter_starfishd = base:new{ Image = imagepath.."shapeshifter_starfishd.png", Loop = false, NumFrames = 8, Time = .15 }


a.explogoomosquito_0 = Animation:new{
	Image = "effects/goomosquito_U.png",
	NumFrames = 7,
	Time = 0.1,
	PosX = -23,
	PosY = 5
}
a.explogoomosquito_1 = a.explogoomosquito_0:new{
	Image = "effects/goomosquito_R.png",
	PosX = -20,
	PosY = -3
}
a.explogoomosquito_2 = a.explogoomosquito_0:new{
	Image = "effects/goomosquito_D.png",
	PosX = -2,
	PosY = -3
}
a.explogoomosquito_3 = a.explogoomosquito_0:new{
	Image = "effects/goomosquito_L.png",
	PosX = -10,
	PosY = 5
}
a.explogoostarfish_0 = Animation:new{
	Image = "effects/goostarfish_R.png",
	NumFrames = 7,
	Time = 0.1,
	PosX = -35,
	PosY = -1,
}
a.explogoostarfish_1 = a.explogoostarfish_0:new{
	Image = "effects/goostarfish_D.png",
	PosX = -10,
	PosY = -3
}
a.explogoostarfish_2 = a.explogoostarfish_0:new{
	Image = "effects/goostarfish_L.png",
	PosX = 5,
	PosY = -1,
}
a.explogoostarfish_3 = a.explogoostarfish_0:new{
	Image = "effects/goostarfish_U.png",
	PosX = -6,
	PosY = 19
}


-------------
-- Weapons --
-------------

Meta_shapeshifterAtkC1 = Skill:new{
	Name = "Shapeshift",
	Description = "Turn into either a Centipede or a Starfish, then respectively launch a mass of goo, dealing damage and applying gunk on adjacent tiles, or deal damage to four oblique tiles.",
	Class = "Enemy",
	Damage = 1,
	PathSize = 1,
	Range = RANGE_PROJECTILE,
	Push = 0,
	Fire = 0,
	Freeze = 0,
	Acid = 1,
	Icon = "weapons/enemy_firefly1.png",
	Explosion = "ExploFirefly2",
	ImpactSound = "/impact/dynamic/enemy_projectile",
	Projectile = "effects/shot_firefly2",
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Target = Point(2,2),
		CustomPawn = "Centipede1"
	}
}

function Meta_shapeshifterAtkC1:GetTargetScore(p1,p2)
	local effect = SkillEffect()
	if Board:GetPawnTeam(p2) == TEAM_ENEMY then return -10 end
	return self:ScoreList(self:GetSkillEffect(p1,p2).q_effect, true)
end

function Meta_shapeshifterAtkC1:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local dir = GetDirection(p2 - p1)
	local target = GetProjectileEnd(p1,p2)  
	
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
	
	local damage1 = SpaceDamage(target, self.Damage)
	local damage2 = SpaceDamage(target + DIR_VECTORS[(dir + 1)% 4], self.Damage)
	local damage3 = SpaceDamage(target + DIR_VECTORS[(dir - 1)% 4], self.Damage)
	damage1.sItem = "Meta_BlobGunk"
	damage2.sItem = "Meta_BlobGunk"
	damage3.sItem = "Meta_BlobGunk"
	ret:AddQueuedProjectile(damage1,self.Projectile)
	ret:AddQueuedDamage(damage2)
	ret:AddQueuedDamage(damage3)
	return ret
end


Meta_shapeshifterAtkS1_StarfishAtk = Skill:new{
--name is dumb but it's necessary for ItB to have diagonal targeting arrow on queued tiles -_-
	Name = "Shapeshift",
	Description = "Use the Starfish's attack.",
	Damage = 1, 
	Class = "Enemy",
	Explosion = "",
	LaunchSound = "",
	SoundBase = "/enemy/starfish_1",
	TipImage = {
		Unit = Point(2,2),
		Target = Point(2,2),
		Enemy = Point(3,3),
		Enemy2 = Point(1,3),
		Building = Point(3,1),
		CustomPawn = "Starfish1"
	}
}

function Meta_shapeshifterAtkS1_StarfishAtk:GetTargetArea(p1)
	local ret = PointList()
	ret:push_back(p1)
	return ret
end

function Meta_shapeshifterAtkS1_StarfishAtk:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	
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
	
	for dir = DIR_START, DIR_END do 
		local curr = p1 + DIR_VECTORS[dir] + DIR_VECTORS[(dir+1)%4]
		local damage = SpaceDamage(curr,self.Damage)
		damage.sAnimation = "explogoostarfish_"..dir
		damage.sSound = self.SoundBase.."/attack"
		local gunkedPawn = Board:GetPawn(curr)
		if gunkedPawn and Status.GetStatus(gunkedPawn:GetId(), "Gunk") then
			ret:AddQueuedScript(string.format("Status.HealFromGunk(%s)", blob:GetId()))
			ret:AddQueuedScript(string.format("Status.RemoveStatus(%s, Gunk)", gunkedPawn:GetId()))
		end
		ret:AddQueuedDamage(damage)
	end
	return ret
end

Meta_shapeshifterAtkC2 = Meta_shapeshifterAtkC1:new{
	Name = "Shapeshift",
	Description = "Turn into either a Centipede or a Starfish, then respectively launch a mass of goo, dealing damage and applying gunk on adjacent tiles, or deal damage to four oblique tiles.",
	Class = "Enemy",
	Damage = 2,
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(2,1),
		Target = Point(2,2),
		CustomPawn = "Centipede2"
	}
}

Meta_shapeshifterAtkS2_StarfishAtk = Meta_shapeshifterAtkS1_StarfishAtk:new{
	Name = "Shapeshift",
	Description = "Use the Starfish's attack.",
	Damage = 2, 
	Class = "Enemy",
	TipImage = {
		Unit = Point(2,2),
		Target = Point(2,2),
		Enemy = Point(3,3),
		Enemy2 = Point(1,3),
		Building = Point(3,1),
		CustomPawn = "Starfish2"
	}
}

-----------
-- Pawns --
-----------

function ShapeshifterAI()
	local p1 = Pawn:GetSpace()
	--get all walkable spaces
	--for each, check value for both weapons, store best weapon and best score
	local area = Board:GetSimpleReachable(p1, Pawn:GetMoveSpeed(), false)
	local bestWeapon = 1
	local bestScore = 0
	local mission = GetCurrentMission()
	if mission.Meta_GooAnims == nil then mission.Meta_GooAnims = {} end
	for _, tile in ipairs(extract_table(area)) do
		for i = DIR_START, DIR_END do
			local curr = tile + DIR_VECTORS[i]
			local score = _G[_G[Pawn:GetType()].SkillList[1]]:GetTargetScore(tile, curr) + ScorePositioning(tile, Pawn)	
			--check centipede weapon for all directions
			if score > bestScore then bestScore = score bestWeapon = 1 end
		end
		local score = _G[_G[Pawn:GetType()].SkillList[2]]:GetTargetScore(tile, tile) + ScorePositioning(tile, Pawn)		
		--check starfish weapon
		if score >= bestScore then bestScore = score bestWeapon = 2 end
	end
	if bestWeapon == 1 then 
		Pawn:SetCustomAnim("Meta_shapeshifter_centipede") 
		mission.Meta_GooAnims[Pawn:GetId()] = "Meta_shapeshifter_centipede"
	else 
		Pawn:SetCustomAnim("Meta_shapeshifter_starfish") 
		mission.Meta_GooAnims[Pawn:GetId()] = "Meta_shapeshifter_starfish"
	end
	--we could set anim in the SkillEffect, but this way it switches before moving, which I think is cooler
	return bestWeapon
end

Meta_shapeshifter1 = Pawn:new{
	Name = "Shapeshifter Goo",
	Health = 3,
	MoveSpeed = 3,
	Image = "Meta_shapeshifter",
	Ranged = 1,
	SkillList = { "Meta_shapeshifterAtkC1", "Meta_shapeshifterAtkS1_StarfishAtk" },
	SoundLocation = "/enemy/goo_boss/",
	Portrait = "enemy/Goo",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB,
	GetWeapon = ShapeshifterAI,
}
AddPawn("Meta_shapeshifter1")

Meta_shapeshifter2 = Pawn:new{
	Name = "Alpha Shapeshifter Goo",
	Health = 5,
	MoveSpeed = 3,
	Image = "Meta_shapeshifter",
	Ranged = 1,
	SkillList = { "Meta_shapeshifterAtkC2", "Meta_shapeshifterAtkS2_StarfishAtk" },
	SoundLocation = "/enemy/goo_boss/",
	Portrait = "enemy/Goo",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB,
	Tier = TIER_ALPHA,
	GetWeapon = ShapeshifterAI,
}
AddPawn("Meta_shapeshifter2")

