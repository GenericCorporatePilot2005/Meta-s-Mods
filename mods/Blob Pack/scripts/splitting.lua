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

local name = "splittinggoo" 

modApi:appendAsset(writepath..name..".png", readpath..name..".png")
modApi:appendAsset(writepath..name.."2.png", readpath..name.."2.png")

-- modApi:appendAsset(writepath..name.."a.png", readpath..name.."a.png")
-- modApi:appendAsset(writepath.."emergegoo.png", readpath.."emergegoo.png")
-- modApi:appendAsset(writepath..name.."_death.png", readpath..name.."_death.png")

a.Meta_splittinggoo = a.EnemyUnit:new{Image = imagepath .. name..".png", PosX = -23, PosY = -8, Height = 1}
a.Meta_splittinggooe = a.BaseEmerge:new{Image = imagepath .. "emergegoo.png", PosX = -23, PosY = -5, NumFrames = 10, Height = 1}
a.Meta_splittinggood = a.BaseEmerge:new{Image = imagepath .. "deathgoo.png", PosX = -23, PosY = 7, NumFrames = 7, Height = 1}
a.Meta_splittinggooa = a.Meta_splittinggoo:new{ Image = imagepath..name..".png", NumFrames = 1 }

a.Meta_splittinggoo2 = a.EnemyUnit:new{Image = imagepath .. name.."2.png", PosX = -23, PosY = -10, Height = 1}
a.Meta_splittinggoo2e = a.BaseEmerge:new{Image = imagepath .. "emergegoobig.png", PosX = -23, PosY = -5, NumFrames = 12, Height = 1}
a.Meta_splittinggoo2d = a.BaseEmerge:new{Image = imagepath .. "deathgoobig.png", PosX = -23, PosY = 5, NumFrames = 7, Height = 1}
a.Meta_splittinggoo2a = a.Meta_splittinggoo:new{ Image = imagepath..name.."2.png", NumFrames = 1 }


-------------
-- Weapons --
-------------

Meta_splittinggooAtk1 = Skill:new{
	Name = "Splitting Leap",
	Description = "Leaps to a target location, splitting into as many blobs as this unit had HP left. On the last turn, spawns a single blob.",
	Class = "Enemy",
	SoundBase = "/enemy/blobber_1",
	Icon = "weapons/enemy_blobber1.png",
	PathSize = 8,
	Damage = 0,
	Range = 8,
	TipImage = {
		Unit = Point(2,4),
		Target = Point(2,2),
		Enemy1 = Point(1,2),
		Enemy2 = Point(3,2),
		Building1 = Point(3,3),
		Building2 = Point(2,1),
		Building3 = Point(2,3),
		CustomPawn = "Meta_splittinggoo1",
	}
}

function Meta_splittinggooAtk1:GetTargetArea(point)
	ret = PointList()
	for i = DIR_START, DIR_END do
		for j = 2, 8 do
			local curr = point + DIR_VECTORS[i] * j
			if not Board:IsBlocked(curr, PATH_GROUND) then ret:push_back(curr) end
		end
	end
	return ret
end

SkillEffect["AddQueuedArtilleryFromLoc"] = function(self, origin, damage, graphics, delay) 
-- add our own queued artillery that can start from anywhere
	local fx = SkillEffect()
	fx["AddArtillery"](fx, origin, damage, graphics, delay)
	self.q_effect:AppendAll(fx.effect)
end

function Meta_splittinggooAtk1:GetSkillEffect(p1,p2)
	ret = SkillEffect()
	local vicinity = extract_table(general_DiamondTarget(p2,4))
	local nearbySpawnPoints = {}
	local spawnPoints = {}
	local backup = {}
	
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
	
	local spawn_amount = blob:GetHealth()
	if Board:GetItem(p2) == "Meta_BlobGunk" then spawn_amount = spawn_amount + 1 end
	for _,v in ipairs(vicinity) do
		if not Board:IsBlocked(v,PATH_GROUND) and v ~= p2 then
			local adjacent = false
			for k = 1, #nearbySpawnPoints do
				if v:Manhattan(nearbySpawnPoints[k]) == 1 then adjacent = true end
			end
			for k = 1, #spawnPoints do
				if v:Manhattan(spawnPoints[k]) == 1 then adjacent = true end
			end
			-- we don't iterate on backup, because those will be spawned last, so they'll act after the good ones
			if p2:Manhattan(v) <= 2 and Board:GetDistanceToBuilding(v) == 1 and not adjacent then
				nearbySpawnPoints[#nearbySpawnPoints + 1] = v
			elseif Board:GetDistanceToBuilding(v) == 1 and not adjacent then
				spawnPoints[#spawnPoints + 1] = v
			elseif not adjacent then
				backup[#backup + 1] = v
			end
		end
	end

	ret:AddQueuedScript(string.format([[
		local leap = PointList();
		leap:push_back(%s);
		leap:push_back(%s);
		fx = SkillEffect();
		fx:AddLeap(leap, FULL_DELAY);
		Board:AddEffect(fx);
	]], p1:GetString(), p2:GetString()))
	ret:AddQueuedDelay(1)
	
	for i = 1, spawn_amount do
		local damage = SpaceDamage(0)
		if #spawnPoints ~= 0 then
			damage.loc = random_removal(spawnPoints)
		elseif #nearbySpawnPoints ~= 0 then
			damage.loc = random_removal(nearbySpawnPoints)
		elseif #backup ~= 0 then
			damage.loc = random_removal(backup)
		else
			break
		end
		
		damage.sPawn = "Blob2"
		damage.sSound = '/impact/generic/blob'
		damage.bHide = true
		ret:AddQueuedArtilleryFromLoc(p2,damage,"effects/shotup_blobber2.png",NO_DELAY)
	end
	ret:AddQueuedDamage(SpaceDamage(p2, spawn_amount))
	ret:AddQueuedArtillery(SpaceDamage(p2, 0),"effects/nothing.png",NO_DELAY)	
	--this is just for the preview
	if IsTipImage() then ret:AddQueuedDelay(1.5) end
	--otherwise you don't see the blobs properly in the tooltip
	return ret
end

function Meta_splittinggooAtk1:GetTargetScore(p1, p2)
	if Board:IsBlocked(p2, PATH_GROUND) then return 0 end
	if Game:GetTurnCount() == GetCurrentMission().TurnLimit then
		local score = 0
		for i = DIR_START, DIR_END do
			local curr = p2 + DIR_VECTORS[i]
			if Board:IsBuilding(curr) or Board:GetPawn(curr) and Board:GetPawn(curr):GetTeam() == TEAM_PLAYER then score = score + 1 end
			if Board:GetPawn(curr) and Board:GetPawn(curr):GetTeam() == TEAM_ENEMY then score = score - 1 end
		end
		return score
	else
		local buildingsInFourTiles = extract_table(Board:GetTiles(function(p)
			return Board:IsBuilding(p) and p2:Manhattan(p) <= 4
		end))
		return #buildingsInFourTiles
	end
end

-----------
-- Pawns --
-----------

Meta_splittinggoo1 = Pawn:new{
	Name = "Splitting Goo",
	Health = 2,
	MoveSpeed = 3,
	Image = "Meta_splittinggoo",
	Ranged = 1,
	SkillList = { "Meta_splittinggooAtk1", "BlobberAtk2" },
	SoundLocation = "/enemy/goo_boss/",
	Portrait = "enemy/BlobBoss",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB,
}
AddPawn("Meta_splittinggoo1")

function Meta_splittinggoo1:GetWeapon(point)
	LOG(Game:GetTurnCount(), GetCurrentMission().TurnLimit)
	if Game:GetTurnCount() ~= GetCurrentMission().TurnLimit - 1 then return 1 else return 2 end
end

Meta_splittinggoo2 = Pawn:new{
	Name = "Alpha Splitting Goo",
	Health = 4,
	MoveSpeed = 3,
	Image = "Meta_splittinggoo2",
	Ranged = 1,
	SkillList = { "Meta_splittinggooAtk1", "BlobberAtk2" },
	SoundLocation = "/enemy/goo_boss/",
	Portrait = "enemy/BlobBoss",
	DefaultTeam = TEAM_ENEMY,
	ImpactMaterial = IMPACT_BLOB,
	Tier = TIER_ALPHA,
}
AddPawn("Meta_splittinggoo2")

function Meta_splittinggoo2:GetWeapon(point)
	LOG(Game:GetTurnCount(), GetCurrentMission().TurnLimit)
	if Game:GetTurnCount() ~= GetCurrentMission().TurnLimit - 1 then return 1 else return 2 end
end

