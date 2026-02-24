local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath
--local previewer = require(scriptPath.."weaponPreview/api")
local customAnim = require(mod_loader.mods[modApi.currentMod].scriptPath .."libs/customAnim")
local BoardEvents = require(mod_loader.mods[modApi.currentMod].scriptPath .."libs/boardEvents")

local writepath = "img/units/aliens/"
local readpath = resourcePath .. writepath
local imagepath = writepath:sub(5,-1)
local a = ANIMS

local function IsTipImage()
	return Board:GetSize() == Point(6,6)
end

--Design notes:
--I wanted gunk to be something annoying to the player but often the least-bad option so it would actually happen
--With this implementation, players will bodyblock charges, sludges stay alive, and keep applying gunk on the board/units

-------------
--   Art   --
-------------

local name = "sludge" 

modApi:appendAsset(writepath..name..".png", readpath..name..".png")
modApi:appendAsset(writepath..name.."a.png", readpath..name.."a.png")
-- modApi:appendAsset(writepath..name.."2.png", readpath..name.."2.png")
modApi:appendAsset("img/effects/gunk.png", resourcePath.."img/effects/gunk.png")

-- modApi:appendAsset(writepath..name.."a.png", readpath..name.."a.png")
-- modApi:appendAsset(writepath.."emergegoo.png", readpath.."emergegoo.png")
-- modApi:appendAsset(writepath..name.."_death.png", readpath..name.."_death.png")

a.Meta_sludgegoo = a.EnemyUnit:new{Image = imagepath .. name..".png", PosX = -20, PosY = -8, Height = 1}
a.Meta_sludgegooe = a.BaseEmerge:new{Image = imagepath .. "emergegoo.png", PosX = -23, PosY = -5, NumFrames = 10, Height = 1}
a.Meta_sludgegood = a.BaseEmerge:new{Image = imagepath .. "deathgoo.png", PosX = -23, PosY = 7, NumFrames = 7, Height = 1}
a.Meta_sludgegooa = a.Meta_sludgegoo:new{ Image = imagepath..name.."a.png", NumFrames = 8 }

-- a.Meta_sludgegoo2 = a.EnemyUnit:new{Image = imagepath .. name.."2.png", PosX = -23, PosY = -5, Height = 1}
-- a.Meta_sludgegoo2e = a.BaseEmerge:new{Image = imagepath .. "emergegoobig.png", PosX = -23, PosY = -5, NumFrames = 12, Height = 1}
-- a.Meta_sludgegoo2d = a.BaseEmerge:new{Image = imagepath .. "deathgoobig.png", PosX = -23, PosY = 5, NumFrames = 7, Height = 1}
-- a.Meta_sludgegoo2a = a.Meta_sludgegoo:new{ Image = imagepath..name.."2.png", NumFrames = 1 }



-------------
-- Weapons --
-------------

Meta_sludgegooAtk1 = Skill:new{
	Name = "Sludgy Dash",
	Description = "Dash to a target location, damaging it and applying gunk on it and every tile crossed. ",
	Class = "Enemy",
	SoundBase = "/enemy/blobber_1",
	Icon = "weapons/enemy_blobber1.png",
	PathSize = 8,
	Damage = 1,
	Range = 8,
	ScoreFriendly = 1,
	TipImage = {
		Unit = Point(2,4),
		Target = Point(2,1),
		Enemy = Point(2,1),
		CustomPawn = "Meta_sludgegoo1",
	}
}

function Meta_sludgegooAtk1:GetTargetArea(point)
	ret = PointList()
	for i = DIR_START, DIR_END do
		ret:push_back(point + DIR_VECTORS[i])
	end
	return ret
end

function Meta_sludgegooAtk1:GetSkillEffect(p1,p2)
	ret = SkillEffect()
	local direction = GetDirection(p2-p1)
	local target = GetProjectileEnd(p1,p2,PATH_GROUND)
	
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
	
	local doDamage = true
	if not Board:IsBlocked(target,PATH_GROUND) then -- dont attack an empty edge square, just run to the edge
		doDamage = false
		target = target + DIR_VECTORS[direction]
	end
	if not Board:IsPawnSpace(target) and (Board:GetTerrain(target) == TERRAIN_WATER or Board:GetTerrain(target) == TERRAIN_HOLE) then ---run into water/hole and die!
		doDamage = false
		target = target + DIR_VECTORS[direction]
	end
	ret:AddQueuedCharge(Board:GetSimplePath(p1, target - DIR_VECTORS[direction]), FULL_DELAY)
	local damage = SpaceDamage(target, self.Damage)
	if Board:GetPawn(target) then
		if Board:GetPawn(target):GetTeam() == TEAM_ENEMY then 
			damage.iDamage = self.Damage * -1 
		else 
			damage.iDamage = self.Damage - 1
			damage.sItem = "Meta_BlobGunk"
		end
	-- else
		-- damage.sScript = string.format("CustomAnim:add(%s, %q)", damage.loc:GetString(), "gunk")
	end
	if distance == 1 and doDamage then
		ret:AddQueuedMelee(p1,damage, NO_DELAY)
		if Board:GetPawn(p2) and Status.GetStatus(Board:GetPawn(p2):GetId(), "Gunk") then
			if Board:GetPawn(p1) and not Board:GetPawn(p1):IsDamaged() then
				ret:AddQueuedScript(string.format("Board:GetPawn(%s):SetHealth(%s)", p1:GetString(), Board:GetPawn(p1):GetHealth() + 1))
			end
			ret:AddQueuedDamage(SpaceDamage(p1, -1))
			ret:AddQueuedScript(string.format("Status.Remove(%s, %q)", Board:GetPawn(curr):GetId(), "Gunk"))
		end
	else
		local dest = target - DIR_VECTORS[direction]
		ret:AddQueuedCharge(Board:GetSimplePath(p1, dest), NO_DELAY)
		local temp = p1 
		while temp ~= target do 
			if temp:Manhattan(target) > 1 then ret:AddQueuedScript(string.format("Board:SetItem(%s, %q)", temp:GetString(), "Meta_BlobGunk")) end
			temp = temp + DIR_VECTORS[direction]
			if temp ~= target then
				ret:AddDelay(0.06)
			end
		end
		if doDamage then 
			ret:AddQueuedDamage(damage) 
			if Board:GetPawn(p2) and Status.GetStatus(Board:GetPawn(p2):GetId(), "Gunk") then
				if Board:GetPawn(dest) and not Board:GetPawn(dest):IsDamaged() then
					ret:AddQueuedScript(string.format("Board:GetPawn(%s):SetHealth(%s)", dest:GetString(), Board:GetPawn(dest):GetHealth() + 1))
				end
				ret:AddQueuedDamage(SpaceDamage(dest, -1))
			end
		end
	end
	
	return ret
end


-----------
-- Pawns --
-----------

Meta_sludgegoo1 = Pawn:new{
	Name = "Sludge Goo",
	Health = 2,
	MoveSpeed = 3,
	Image = "Meta_sludgegoo",
	Ranged = 1,
	SkillList = { "Meta_sludgegooAtk1" },
	SoundLocation = "/enemy/goo_boss/",
	Portrait = "enemy/BlobBoss",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB,
}
AddPawn("Meta_sludgegoo1")

Meta_sludgegoo2 = Pawn:new{
	Name = "Alpha Sludge Goo",
	Health = 4,
	MoveSpeed = 3,
	Image = "Meta_sludgegoo",
	Ranged = 1,
	SkillList = { "Meta_sludgegooAtk1" },
	SoundLocation = "/enemy/goo_boss/",
	Portrait = "enemy/BlobBoss",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB,
	Tier = TIER_ALPHA,
}
AddPawn("Meta_sludgegoo2")

