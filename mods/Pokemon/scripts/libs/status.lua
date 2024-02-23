
---------------------------------------------------------------------
-- Status effects v1.0 - code library
---------------------------------------------------------------------
-- A library that adds status effects to the game. Weapons and pilot skills can apply status effects.
-- See the wiki for info: https://github.com/Metalocif/Meta-s-Mods/wiki/Status-Library

-- We start by adding the status icons and animations.
-- Then, we overwrite scoring functions for Vek so that Blind/Confusion/Alluring/Targeted/Bloodthirsty can affect them.
-- Afterwards, we create the functions that apply each given status.
-- These typically check whether a pawn with the given ID exists and whether a mission is ongoing, then adds the ID to the status' table and an animation.
-- These tables are checked when relevant in the hooks below.

local path = mod_loader.mods[modApi.currentMod].resourcePath
Status = {}

modApi:appendAssets("img/libs/status/", "img/libs/status/")

ANIMS.StatusAlluring = Animation:new{ Image = "libs/status/alluring.png", PosX = 0, PosY = 0, NumFrames = 4, Time = 0.3, Loop = true}
ANIMS.StatusBlind = Animation:new{ Image = "libs/status/blind.png", PosX = 0, PosY = 0, NumFrames = 1, Time = 1, Loop = true}
ANIMS.StatusBloodthirsty = Animation:new{ Image = "libs/status/bloodthirsty.png", PosX = 0, PosY = 0, NumFrames = 1, Time = 1, Loop = true}
ANIMS.StatusBonded = Animation:new{ Image = "libs/status/bonded.png", PosX = 0, PosY = 0, NumFrames = 1, Time = 1, Loop = true}
ANIMS.StatusBondedOff = Animation:new{ Image = "libs/status/bonded_off.png", PosX = 0, PosY = 0, NumFrames = 1, Time = 1, Loop = true}
ANIMS.StatusChill = Animation:new{ Image = "libs/status/chill.png", PosX = -10, PosY = 0, NumFrames = 1, Time = 1, Loop = true}
ANIMS.StatusConfusion = Animation:new{ Image = "libs/status/confusion.png", PosX = 0, PosY = 0, NumFrames = 2, Time = 0.5, Loop = true}
ANIMS.StatusDreadful = Animation:new{ Image = "libs/status/dreadful.png", PosX = 0, PosY = 0, NumFrames = 1, Time = 1, Loop = true}
ANIMS.StatusDry = Animation:new{ Image = "libs/status/dry.png", PosX = 0, PosY = 0, NumFrames = 3, Time = 0.3, Loop = true}
ANIMS.StatusDoomed = Animation:new{ Image = "combat/icons/icon_tentacle.png", PosX = 0, PosY = 0, NumFrames = 1, Time = 1, Loop = true}
ANIMS.StatusGlory = Animation:new{ Image = "libs/status/glory.png", PosX = -5, PosY = 0, NumFrames = 1, Time = 1, Loop = true}
ANIMS.StatusHemorrhage = Animation:new{ Image = "libs/status/hemorrhage.png", PosX = -5, PosY = 10, NumFrames = 6, Time = 0.2, Loop = true}
ANIMS.StatusLeechSeed = Animation:new{ Image = "libs/status/leechseed.png", PosX = -5, PosY = 5, NumFrames = 1, Time = 1, Loop = true}
ANIMS.StatusNecrosis = Animation:new{ Image = "libs/status/necrosis.png", PosX = 0, PosY = 0, NumFrames = 1, Time = 1, Loop = true}
ANIMS.StatusShatterburst = Animation:new{ Image = "libs/status/shatterburst.png", PosX = 0, PosY = 0, NumFrames = 1, Time = 1, Loop = true}
ANIMS.StatusShocked = Animation:new{ Image = "libs/status/shocked.png", PosX = -5, PosY = 0, NumFrames = 4, Time = 0.15, Loop = true}
ANIMS.StatusSleep = Animation:new{ Image = "libs/status/sleep.png", PosX = -30, PosY = -20, NumFrames = 7, Time = 0.3, Loop = true}
ANIMS.StatusPowder = Animation:new{ Image = "libs/status/powder.png", PosX = -5, PosY = 0, NumFrames = 1, Time = 1, Loop = true}
ANIMS.StatusRegen = Animation:new{ Image = "combat/icons/icon_regen.png", PosX = 0, PosY = 0, NumFrames = 1, Time = 1, Loop = true}
ANIMS.StatusReactive = Animation:new{ Image = "libs/status/reactive.png", PosX = -7, PosY = 15, NumFrames = 1, Time = 1, Loop = true}
ANIMS.StatusRooted = Animation:new{ Image = "libs/status/rooted.png", PosX = -7, PosY = 15, NumFrames = 1, Time = 1, Loop = true}
ANIMS.StatusTargeted = Animation:new{ Image = "libs/status/targeted.png", PosX = 0, PosY = 0, NumFrames = 1, Time = 1, Loop = true}
ANIMS.StatusToxin = Animation:new{ Image = "libs/status/toxin.png", PosX = 0, PosY = 0, NumFrames = 6, Time = 0.15, Loop = true}
ANIMS.StatusWeaken = Animation:new{ Image = "libs/status/weaken.png", PosX = -15, PosY = 0, NumFrames = 6, Time = 0.1, Loop = true}
ANIMS.StatusWet = Animation:new{ Image = "libs/status/wet.png", PosX = -5, PosY = 10, NumFrames = 6, Time = 0.2, Loop = true}




local oldScorePositioning = ScorePositioning
function ScorePositioning(point, pawn)
	local mission = GetCurrentMission()
	if mission.BlindTable[pawn:GetId()] and point:Manhattan(pawn:GetSpace()) > 2 then return -100 end
	--if the pawn is blind, don't move beyond 2 spaces
	return oldScorePositioning(point, pawn) + (mission.AdjScoreTable[point:GetString()] or 0)
	--nil check for Vek outside the board
end

function Skill:ScoreList(list, queued)
	local mission = GetCurrentMission()
	local id = Pawn:GetId()
	local pos = Pawn:GetSpace()
	local score = 0
	local posScore = 0
	
	if not mission then
		for i = 1, list:size() do
			local spaceDamage = list:index(i)
			local target = spaceDamage.loc
			local damage = spaceDamage.iDamage 
			local moving = spaceDamage:IsMovement() and spaceDamage:MoveStart() == Pawn:GetSpace()
			if Board:IsValid(target) or moving then	
				if spaceDamage:IsMovement() then
					posScore = posScore + ScorePositioning(spaceDamage:MoveEnd(), Pawn)
				elseif Board:IsPawnSpace(target) and Board:GetPawn(target):IsNonGridStructure() then
					score = score + self.ScoreBuilding
				elseif Board:GetPawnTeam(target) == Pawn:GetTeam() and damage > 0 then
					if Board:IsFrozen(target) and not Board:IsTargeted(target) then
						score = score + self.ScoreEnemy
					else
						score = score + self.ScoreFriendlyDamage
					end
				elseif isEnemy(Board:GetPawnTeam(target),Pawn:GetTeam()) then
						if Board:GetPawn(target):IsDead() or Board:GetPawn(target):IsTempUnit() then 
							score = self.ScoreNothing
						else
							score = score + self.ScoreEnemy
						end
				elseif Board:IsBuilding(target) and Board:IsPowered(target) and damage > 0 then
					score = score + self.ScoreBuilding
				elseif Board:IsPod(target) and not queued and (damage > 0 or spaceDamage.sPawn ~= "") then
					return -100
				else
					score = score + self.ScoreNothing
				end
			end
		end
	else
		for i = 1, list:size() do
			local spaceDamage = list:index(i)
			local target = spaceDamage.loc
			if mission.BlindTable[id] == nil or pos:Manhattan(target) <= 2 then
				local damage = spaceDamage.iDamage 
				local moving = spaceDamage:IsMovement() and spaceDamage:MoveStart() == Pawn:GetSpace()
				
				if Board:IsValid(target) or moving then	
					local foundPawn = Board:GetPawn(target)
					if spaceDamage:IsMovement() then
						posScore = posScore + ScorePositioning(spaceDamage:MoveEnd(), Pawn)
					elseif foundPawn and foundPawn:IsNonGridStructure() then
						score = score + self.ScoreBuilding
					elseif Board:GetPawnTeam(target) == Pawn:GetTeam() and damage > 0 then
						if Board:IsFrozen(target) and not Board:IsTargeted(target) then
							score = score + self.ScoreEnemy
						else
							score = score + self.ScoreFriendlyDamage
						end
					elseif isEnemy(Board:GetPawnTeam(target),Pawn:GetTeam()) then
						if foundPawn:IsDead() or foundPawn:IsTempUnit() then 
							score = self.ScoreNothing
						else
							score = score + self.ScoreEnemy
							if mission.BloodthirstyTable[Pawn:GetId()] then score = score + mission.BloodthirstyTable[Pawn:GetId()] end
						end
					elseif Board:IsBuilding(target) and Board:IsPowered(target) and damage > 0 then
						score = score + self.ScoreBuilding
					elseif Board:IsPod(target) and not queued and (damage > 0 or spaceDamage.sPawn ~= "") then
						return -100
					else
						score = score + self.ScoreNothing
					end
					if Board:IsPawnSpace(target) and mission.TargetedTable[Board:GetPawn(target):GetId()] then score = score + mission.TargetedTable[foundPawn:GetId()] end
				end
			end
		end
	end
	if mission.ConfusionTable[Pawn:GetId()] ~= nil then 
		if posScore > -50 then posScore = -posScore end	--don't get confused into stepping on pods/ignoring blindness range restriction
		if score > -50 then score = -score end			--don't get confused into spawning unqueued stuff on top of pods
	end
	if posScore < -5 then return posScore end
	return score
end



function Status.ApplyAlluring(id, amount)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].AlluringImmune then return end
	amount = amount or 10
	if amount == 0 then return end
	mission.AlluringTable[id] = amount
	CustomAnim:add(id, "StatusTargeted")
end

function Status.ApplyBlind(id, turns, addTurns)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].BlindImmune then return end
	turns = turns or 1
	if addTurns and mission.BlindTable[id] then 
		mission.BlindTable[id] = mission.BlindTable[id] + turns
	else
		mission.BlindTable[id] = turns
	end
	CustomAnim:add(id, "StatusBlind")
end

function Status.ApplyBloodthirsty(id, amount)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].BloodthirstyImmune then return end
	amount = amount or 10
	mission.BloodthirstyTable[id] = amount
	CustomAnim:add(id, "StatusBloodthirsty")
end

function Status.ApplyBonded(id)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].BondedImmune then return end
	mission.BondedTable[id] = true
	CustomAnim:add(id, "StatusBonded")
	CustomAnim:rem(id, "StatusBondedOff")	--that way applying the status refreshes it
end

function Status.ApplyChill(id, clearQueued)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].ChillImmune then return end
	if pawn:IsFire() then CustomAnim:rem(id, "StatusChill") return end
	if CustomAnim:get(id, "StatusChill") then
		CustomAnim:rem(id, "StatusChill")
		pawn:SetFrozen(true)
	elseif CustomAnim:get(id, "StatusWet") then
		CustomAnim:rem(id, "StatusChill")
		pawn:SetFrozen(true)
	else
		CustomAnim:add(id, "StatusChill")
		mission.ChillTable[id] = true
	end
	if clearQueued then pawn:ClearQueued() end
end

function Status.ApplyConfusion(id, turns)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].ConfusionImmune then return end
	turns = turns or 1
	mission.ConfusionTable[id] = turns
	CustomAnim:add(id, "StatusConfusion")
end

function Status.ApplyDoomed(id, source)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].DoomedImmune then return end
	source = source or -1
	mission.DoomedTable[id] = source
	CustomAnim:add(id, "StatusDoomed")
end

function Status.ApplyDreadful(id, amount)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].DreadfulImmune then return end
	amount = amount or -10
	mission.DreadfulTable[id] = amount
	CustomAnim:add(id, "StatusDreadful")
end

function Status.ApplyDry(id)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].DryImmune then return end
	if CustomAnim:get(id, "StatusWet") then
		Status.RemoveStatus(id, "Wet")
	else
		mission.DryTable[id] = true
		CustomAnim:add(id, "StatusDry")
	end
end

function Status.ApplyGlory(id, turns)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].GloryImmune then return end
	turns = turns or 1
	if mission.GloryTable[id] ~= nil then
		mission.GloryTable[id].turns = mission.GloryTable[id].turns + turns
	else
		mission.GloryTable[id] = {turns=turns,weapons = pawn:GetEquippedWeapons()}
		CustomAnim:add(id, "StatusGlory")
		Board:Ping(pawn:GetSpace(), GL_Color(255, 255, 100))
		for i = pawn:GetWeaponCount(), 1, -1 do
			local weapon = pawn:GetWeaponBaseType(pawn:GetWeaponCount())
			pawn:RemoveWeapon(pawn:GetWeaponCount())
			if _G[weapon].Upgrades == 2 and _G[weapon.."_AB"] ~= nil then
				weapon = weapon.."_AB"
			elseif _G[weapon].Upgrades == 1 and _G[weapon.."_A"] ~= nil then
				weapon = weapon.."_A"
			elseif _G[weapon].Class == "Enemy" then
				if _G[string.sub(weapon, 1, -2).."B"] ~= nil then 
					weapon = string.sub(weapon, 1, -2).."B"
				elseif _G[string.sub(weapon, 1, -2).."2"] ~= nil then 
					weapon = string.sub(weapon, 1, -2).."B"
				end
			end
			pawn:AddWeapon(weapon, true)
		end
	end
end

function Status.ApplyHemorrhage(id, turns)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].HemorrhageImmune then return end
	turns = turns or 1
	mission.HemorrhageTable[id] = turns
	CustomAnim:add(id, "StatusHemorrhage")
end

function Status.ApplyInfested(id, turns)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].InfestedImmune then return end
	turns = turns or 1
	mission.InfestedTable[id] = turns
	pawn:SetInfected(true)
end

function Status.ApplyLeechSeed(id, source)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	if pawn:IsFire() then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].LeechSeedImmune then return end
	if Pawn then source = source or Pawn:GetId() end
	if not source then return end
	mission.LeechSeedTable[id] = source
	CustomAnim:add(id, "StatusLeechSeed")
end

function Status.ApplyNecrosis(id)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].NecrosisImmune then return end
	mission.NecrosisTable[id] = true
	CustomAnim:add(id, "StatusNecrosis")
end

function Status.ApplyPowder(id)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].PowderImmune then return end
	if mission.WetTable[id] then return end
	mission.PowderTable[id] = true
	CustomAnim:add(id, "StatusPowder")
end

function Status.ApplySleep(id, turns, addTurns)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].SleepImmune then return end
	turns = turns or 1
	if turns > 0 then
		pawn:SetPowered(false)
		pawn:ClearQueued()
		if ANIMS[pawn:GetCustomAnim().."_sleep"] ~= nil then
			pawn:SetCustomAnim(_G[pawn:GetType()].Image.."_sleep")
		elseif not CustomAnim:get(id, "StatusSleep") then
			CustomAnim:add(id, "StatusSleep")
		end
		if addTurns and not mission.SleepTable[id] then 
			mission.SleepTable[id] = mission.SleepTable[id] + turns
		else
			mission.SleepTable[id] = turns
		end
	elseif turns < 0 and addTurns and mission.SleepTable[id] then
		mission.SleepTable[id] = mission.SleepTable[id] + turns
		if mission.SleepTable[id] < 0 then 
			Status.RemoveStatus(id, "Sleep")
		end
	end
end

function Status.ApplyShatterburst(id)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].ShatterburstImmune then return end
	mission.ShatterburstTable[id] = true
	CustomAnim:add(id, "StatusShatterburst")
end

function Status.ApplyShocked(id)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].ShockedImmune then return end
	if Status.GetStatus(id, "Shocked") or Status.GetStatus(id, "Wet") then 
		pawn:ClearQueued()
		Board:AddAnimation(pawn:GetSpace(),"Lightning_Hit",1)
	else
		CustomAnim:add(id, "StatusShocked")
		mission.ShockedTable[id] = true
	end
end

function Status.ApplyRegen(id, amount)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].RegenImmune then return end
	amount = amount or 1
	if amount <= 0 then return end
	mission.RegenTable[id] = amount
	CustomAnim:add(id, "StatusRegen")
end

function Status.ApplyReactive(id)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].ReactiveImmune then return end
	mission.ReactiveTable[id] = true
	CustomAnim:add(id, "StatusReactive")
end

function Status.ApplyRooted(id, amount)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	if pawn:IsFire() or Board:IsFire(pawn:GetSpace()) then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].RootedImmune then return end
	amount = amount or 0
	mission.RootedTable[id] = {amount = amount, wasPushable = not pawn:IsGuarding(), oldMoveSpeed = pawn:GetMoveSpeed()}
	CustomAnim:add(id, "StatusRooted")
	pawn:SetPushable(false)
	pawn:SetMoveSpeed(0)
end

function Status.ApplyTargeted(id, amount)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].TargetedImmune then return end
	amount = amount or 10
	if amount == 0 then return end
	mission.TargetedTable[id] = amount
	CustomAnim:add(id, "StatusTargeted")
end

function Status.ApplyToxin(id)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].ToxinImmune then return end
	mission.ToxinTable[id] = true
	CustomAnim:add(id, "StatusToxin")
end

function Status.ApplyWeaken(id, amount, recoverPerTurn)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	if pawn:GetTeam() ~= TEAM_ENEMY then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].WeakenImmune then return end
	recoverPerTurn = recoverPerTurn or 0
	amount = amount or 1
	if amount == 0 then return end
	for i = pawn:GetWeaponCount(), 1, -1 do
		local weapon = pawn:GetWeaponBaseType(i)
		if string.match(weapon, "^%dweaker") then
			amount = amount + tonumber(string.sub(weapon,1,1))
			weapon = string.sub(weapon, 8)
		end
		if amount > _G[pawn:GetWeaponBaseType(i)].Damage then amount = _G[weapon].Damage end
		local newWeapon = amount.."weaker"..weapon
		if amount <= 0 then newWeapon = weapon end
		pawn:RemoveWeapon(i)
		pawn:AddWeapon(newWeapon)
	end
	CustomAnim:add(id, "StatusWeaken")
	if mission.WeakenTable[id] == nil then mission.WeakenTable[id] = 0 end
	mission.WeakenTable[id] = mission.WeakenTable[id] + recoverPerTurn
	if mission.WeakenTable[id] == 0 then mission.WeakenTable[id] = nil end
end	

function Status.ApplyWet(id)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	if _G[pawn:GetType()].WetImmune then return end
	if pawn:IsFire() then
		pawn:SetFire(false)
	elseif CustomAnim:get(id, "StatusChill") then
		pawn:SetFrozen(true)
	elseif CustomAnim:get(id, "StatusDry") then
		Status.RemoveStatus(id, "Dry")
	else
		mission.WetTable[id] = true
		CustomAnim:add(id, "StatusWet")
		Status.RemoveStatus(id, "Powder")
	end
end


function Status.RemoveStatus(id, status)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	CustomAnim:rem(id, "Status"..status)
	local mission = GetCurrentMission()
	if not mission then return end
	if not mission[status.."Table"][id] then return end
	if status == "Rooted" then 
		pawn:SetPushable(mission["RootedTable"][id].wasPushable) 
		pawn:SetMoveSpeed(mission["RootedTable"][id].oldMoveSpeed)
	end
	if status == "Sleep" then
		pawn:SetPowered(true)
		if pawn:GetCustomAnim():sub(-6, -1) == "_sleep" then
			if pawn:GetCustomAnim():sub(-13, -1) == "special_sleep" then
				pawn:SetCustomAnim(pawn:GetCustomAnim():sub(1, -14))
			else
				pawn:SetCustomAnim(pawn:GetCustomAnim():sub(1, -7))
			end
		else
			CustomAnim:rem(id, "StatusSleep")
		end
		mission.SleepTable[id] = nil
	elseif status == "Glory" then
		for i = pawn:GetWeaponCount(), 1, -1 do
			pawn:RemoveWeapon(i)
		end
		local weaponCount = #mission.GloryTable[id].weapons
		for i = 1, weaponCount do
			pawn:AddWeapon(mission.GloryTable[id].weapons[i], true)
		end
		CustomAnim:rem(id, "StatusGlory")
		mission["GloryTable"][id] = nil 
	else
		CustomAnim:rem(id, "Status"..status)
		mission[status.."Table"][id] = nil 
	end
end

function Status.GetStatus(id, status)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	return mission[status.."Table"][id] or false
end

function Status.List()
	return {"Alluring","Blind","Bloodthirsty","Bonded","Chill","Confusion","Doomed","Dreadful","Dry","Glory","Hemorrhage","Infested","LeechSeed","Necrosis","Powder","Reactive","Regen","Rooted","Shatterburst","Shocked","Sleep","Targeted","Toxin","Weaken","Wet"}
end

function Status.Count(id)
	local pawn = Board:GetPawn(id)
	if not pawn then return end
	local mission = GetCurrentMission()
	if not mission then return end
	local count = 0
	for _, status in Status.List() do
		if mission[status.."Table"][id] ~= nil then count = count + 1 end
	end
	return count
end


local function getWeaponKey(id, key)		--helper function to generate the extra Weaken weapons
	Assert.Equals("string", type(id), "ID must be a string")
	Assert.Equals("string", type(key), "Key must be a string")
	local textId = id .. "_" .. key
	if IsLocalizedText(textId) then
		return GetLocalizedText(textId)
	end
	return _G[id] and _G[id][key] or id
end

local function GenerateWeakenWeapons()
	for id, weapon in pairs(_G) do
		if weapon and type(weapon) == "table" and weapon.Damage and weapon.Class and weapon.Damage > 0 and weapon.Class == "Enemy" and weapon.Original == nil then
			local i = 1
			local amount = 1
			if weapon.Damage == DAMAGE_DEATH then amount = 991 end
			repeat
				--for an alpha firefly's weapon weakened 3 times, its ID is 3weakerFireflyAtk2
				_G[i.."weaker"..id] =  _G[id]:new{ Damage = _G[id].Damage - amount, Original = id, }
				_G[i.."weaker"..id].GetName = function(self) return getWeaponKey(self.Original, "Name") end
				_G[i.."weaker"..id].GetDescription = function(self) return getWeaponKey(self.Original, "Description") end
				_G[i.."weaker"..id].GetIcon = function(self) return "weapons/enemy_scorpion1.png" end
				_G[i.."weaker"..id].GetClass = function(self) return "Enemy" end
				setmetatable(_G[i.."weaker"..id], {__index = _G[id]})
				--no idea why we need both that and the rest but we do
				i = i + 1
				amount = amount + 1
			until weapon.Damage - amount < 0 or i > 9
		end
	end
end

local function PrepareTables()						--setup all status tables here so we don't need to check everywhere
	modApi:conditionalHook(function()			--we need the conditional hook for some reason
		return true and Game ~= nil and GAME ~= nil and (GetCurrentMission() ~= nil or IsTestMechScenario())
	end, 
	function()
		local mission = GetCurrentMission()
		-- if mission == nil then return end
		LOG("status tables are ready")
		-- local tablesList = merge_table(Status.List(), {"AdjScore"})
		local tablesList = Status.List()
		for i = 1, #tablesList do
			mission[tablesList[i].."Table"] = {}
		end
		mission["AdjScoreTable"] = {}
	end)
end


local function EVENT_onModsLoaded()
	modapiext:addPawnHealedHook(function(mission, pawn, healingTaken)	--necrosis/hemorrhage/toxin
		local id = pawn:GetId()
		if mission.NecrosisTable[id] then
			if pawn:GetHealth() - healingTaken <= 0 then 
				pawn:Kill(false)
			else
				pawn:SetHealth(pawn:GetHealth() - healingTaken)
			end
		elseif mission.HemorrhageTable[id] then
			pawn:SetHealth(pawn:GetHealth() - healingTaken * 2)
		elseif mission.ToxinTable[id] then		--only get cured if healing was not prevented
			Status.RemoveStatus(id, "Toxin")
		end
	end)
	modapiext:addPawnIsFireHook(function(mission, pawn, isFire)			--powder/dry/wet, remove chill/hemorrhage/roots/leechseed
		if not (mission and pawn and isFire) then return end
		local id = pawn:GetId()
		if mission.WetTable[id] ~= nil then
			pawn:SetFire(false)
			Status.RemoveStatus(id, "Wet")
		end
		if mission.PowderTable[id] then
			Status.RemoveStatus(id, "Powder")
			local point = pawn:GetSpace()
			local amount = 1
			if mission.DryTable[id] ~= nil then
				amount = 2
				Status.RemoveStatus(id, "Dry")
			end
			Board:DamageSpace(point, amount)
			Board:AddAnimation(point, "ExploAir"..amount, 1)
			for i = DIR_START, DIR_END do
				Board:DamageSpace(point + DIR_VECTORS[i], 1)
				Board:AddAnimation(point, "explopush"..amount.."_"..i, 1)
			end
		elseif mission.DryTable[id] ~= nil then
			Board:DamageSpace(point, 1)
			Status.RemoveStatus(id, "Dry")
		end
		Status.RemoveStatus(id, "Hemorrhage")
		Status.RemoveStatus(id, "Chill")
		Status.RemoveStatus(id, "Rooted")
		Status.RemoveStatus(id, "LeechSeed")
	end)
	modapiext:addPawnIsAcidHook(function(mission, pawn, isAcid)			--reactive, remove toxin
		if not (mission and pawn and isAcid) then return end
		local id = pawn:GetId()
		if mission.ReactiveTable[id] then
			Status.RemoveStatus(id, "Reactive")
			local point = pawn:GetSpace()
			for i = DIR_START, DIR_END do
				local damage = SpaceDamage(point + DIR_VECTORS[i])
				damage.iSmoke = 1
				Board:DamageSpace(damage)
			end
		end
		Status.RemoveStatus(id, "Toxin")
	end)
	modapiext:addPawnIsFrozenHook(function(mission, pawn, isFrozen)		--shatterburst, remove chill
		if not (mission and pawn and isFrozen) then return end
		local id = pawn:GetId()
		Status.RemoveStatus(id, "Chill")
		if mission.ShatterburstTable[id] then
			Status.RemoveStatus(id, "Shatterburst")
			local point = pawn:GetSpace()
			Board:DamageSpace(point, 1)
			Board:AddAnimation(point, "ExplIce1", 1)
			for i = DIR_START, DIR_END do
				Board:DamageSpace(point + DIR_VECTORS[i], 1)
			end
		end
	end)
	modapiext:addPawnDamagedHook(function(mission, pawn, damageTaken)	--bonded/shocked, remove sleep
		if not (mission and pawn) then return end
		local id = pawn:GetId()
		if Status.GetStatus(id, "Bonded") and not CustomAnim:get(id, "StatusBondedOff") then
			for bonded, _ in pairs(mission.BondedTable) do
				if bonded ~= id and CustomAnim:get(bonded, "StatusBonded") and not CustomAnim:get(bonded, "StatusBondedOff") then
					modApi:runLater(function() Board:GetPawn(bonded):ApplyDamage(SpaceDamage(Board:GetPawn(bonded):GetSpace(), 1)) end)
					CustomAnim:add(bonded, "StatusBondedOff")
				end
			end
			CustomAnim:add(id, "StatusBondedOff")
		end
		if Status.GetStatus(id, "Shocked") then pawn:ApplyDamage(SpaceDamage(pawn:GetSpace(), 0, DIR_FLIP)) end
		Status.RemoveStatus(id, "Sleep")
	end)
	modapiext:addPawnKilledHook(function(mission, pawn)					--doomed
		if not (mission and pawn) then return end
		local id = pawn:GetId()
		if mission.DoomedTable[id] then
			Board:AddAnimation(pawn:GetSpace(), "Tentacle_Grab", ANIM_NO_DELAY)
			Board:AddAnimation(pawn:GetSpace(), "Tentacle_Grab_Front", ANIM_NO_DELAY)
			Board:SetTerrain(pawn:GetSpace(), TERRAIN_LAVA)
		end
		for doomedID, source in pairs(mission.DoomedTable) do
			if id == source then Status.RemoveStatus(doomedID, "Doomed") end
		end
		
	end)
	modApi:addPostStartGameHook(GenerateWeakenWeapons)					--generate the weapons Weaken replaces Vek weapons by
	modApi:addPreLoadGameHook(GenerateWeakenWeapons)					--also do it on reload otherwise the game is not happy
	modApi:addMissionStartHook(PrepareTables)							--create tables for all statuses so we don't have to check everywhere
	modApi:addMissionNextPhaseCreatedHook(PrepareTables)				--also do it on next phase otherwise it won't work
	modApi:addPreEnvironmentHook(function(mission)						--this is for status that triggers before Vek actions
		for _, p in ipairs(Board) do
			mission.AdjScoreTable[p:GetString()] = 0
		end
		--we reset the entire table every turn, then reload it with alluring/dreadful pawns
		--it's used in the scoring functions
		for id, score in pairs(mission.AlluringTable) do
			local pawn = Board:GetPawn(id)
			if pawn then
				local tile = pawn:GetSpace()
				for i = DIR_START, DIR_END do
					local curr = tile + DIR_VECTORS[i]
					mission.AdjScoreTable[curr:GetString()] = mission.AdjScoreTable[curr:GetString()] + score
				end
			end
		end
		for id, score in pairs(mission.DreadfulTable) do
			local pawn = Board:GetPawn(id)
			if pawn then
				local tile = pawn:GetSpace()
				for i = DIR_START, DIR_END do
					local curr = tile + DIR_VECTORS[i]
					mission.AdjScoreTable[curr:GetString()] = mission.AdjScoreTable[curr:GetString()] + score
					if Board:GetPawn(curr) then Board:GetPawn(curr):ClearQueued() end
				end
			end
		end
		for id, source in pairs(mission.DoomedTable) do
			local pawn = Board:GetPawn(id)
			if not Board:GetPawn(source) then			--doublechecking with pawnIsKilled, but something could have removed the pawn without killing
				Status.RemoveStatus(id, "Doomed")
			elseif pawn then
				local damage = SpaceDamage(pawn:GetSpace(), 1)
				damage.sAnimation = "PsionAttack_Back"
				Board:Ping(Board:GetPawn(source):GetSpace(), GL_Color(100, 100, 0))		--here to let the player visualise the source of the effect
				Board:AddAnimation(pawn:GetSpace(), "PsionAttack_Front", ANIM_NO_DELAY)
				pawn:ApplyDamage(damage)
			end
		end
		for id, sleepTurnsLeft in pairs(mission.SleepTable) do
			local pawn = Board:GetPawn(id)
			if pawn then
				LOG(pawn:GetType().." has "..sleepTurnsLeft)
				if sleepTurnsLeft <= 1 then 
					--delete the anims a turn early to make it clear the pawn is waking up soon
					if pawn:GetCustomAnim():sub(-6, -1) == "_sleep" then
						if pawn:GetCustomAnim():sub(-13, -1) == "special_sleep" then
						--this lets pawns have two different anims for sleeping
							pawn:SetCustomAnim(pawn:GetCustomAnim():sub(1, -14))
						else
							pawn:SetCustomAnim(pawn:GetCustomAnim():sub(1, -7))
						end
					else
						CustomAnim:rem(id, "StatusSleep")
					end
				end
				mission.SleepTable[id] = sleepTurnsLeft - 1
				if sleepTurnsLeft < 0 then 
					pawn:SetPowered(true) 
					mission.SleepTable[id] = nil
				end
				
			end
		end
		local fx = SkillEffect()
		for id, leecherId in pairs(mission.LeechSeedTable) do
			local pawn = Board:GetPawn(id)
			local leecher = Board:GetPawn(leecherId)
			if pawn and leecher and id ~= leecherId then
				fx:AddSafeDamage(SpaceDamage(pawn:GetSpace(), 1))
				fx:AddArtillery(pawn:GetSpace(), SpaceDamage(leecher:GetSpace(), -1), "effects/shotup_grid.png", NO_DELAY)
			end
		end
		Board:AddEffect(fx)
		for id, blindTurns in pairs(mission.BlindTable) do
			local pawn = Board:GetPawn(id)
			if pawn then mission.BlindTable[id] = blindTurns - 1 end
			if mission.BlindTable[id] < 0 then Status.RemoveStatus(id, "Blind") end
		end
		for id, confusionTurns in pairs(mission.ConfusionTable) do
			local pawn = Board:GetPawn(id)
			if pawn then mission.ConfusionTable[id] = confusionTurns - 1 end
			if mission.ConfusionTable[id] < 0 then Status.RemoveStatus(id, "Confusion") end
		end
		-- for id, virusTurns in pairs(mission.VirusTable) do
			-- local pawn = Board:GetPawn(id)
			-- if pawn then
				-- mission.VirusTable[id] = virusTurns - 1 end
				-- if mission.VirusTable[id] < 0 then 
					-- Status.RemoveStatus(id, "Virus")
				-- else
					-- pawn:SetHealth(pawn:GetHealth() - 1)
					-- Board:Ping(pawn:GetSpace(), GL_Color(150, 50, 150))
					-- for i = DIR_START, DIR_END do
						-- local curr = pawn:GetSpace() + DIR_VECTORS[i]
						-- if Board:GetPawn(curr) and not mission.VirusTable[Board:GetPawn(curr):GetId()] then 
							-- modApi:runLater(function() mission.VirusTable[Board:GetPawn(curr):GetId()] = 1 end)
							-- CustomAnim:add(Board:GetPawn(curr):GetId(), "StatusVirus")
						-- end	
					-- end
				-- end
			-- end
		-- end
		-- for id, _ in pairs(mission.PoisonTable) do
			-- local pawn = Board:GetPawn(id)
			-- if pawn then
				-- pawn:SetHealth(pawn:GetHealth() - mission.PoisonTable[id])
				-- Board:Ping(pawn:GetSpace(), GL_Color(50, 150, 50))
				-- CustomAnim:rem(id, "StatusPoison"..mission.PoisonTable[id])
				-- mission.PoisonTable[id] = mission.PoisonTable[id] + 1
				-- CustomAnim:add(id, "StatusPoison"..mission.PoisonTable[id])	
			-- end
		-- end
		for id, info in pairs(mission.RootedTable) do
			local pawn = Board:GetPawn(id)
			if pawn and info.amount ~= 0 then pawn:ApplyDamage(SpaceDamage(pawn:GetSpace(), info.amount)) end
		end
		for id, _ in pairs(mission.RegenTable) do
			local pawn = Board:GetPawn(id)
			if pawn then pawn:ApplyDamage(SpaceDamage(pawn:GetSpace(), -1)) end
		end
		for id, _ in pairs(mission.InfestedTable) do
			local pawn = Board:GetPawn(id)
			if pawn then
				if not pawn:IsInfected() then
					mission.InfestedTable[id] = nil
				elseif mission.InfestedTable[id] > 0 then
					mission.InfestedTable[id] = mission.InfestedTable[id] - 1
				elseif mission.InfestedTable[id] <= 0 then
					pawn:Kill(false)
					Board:AddBurst(pawn:GetSpace(), "Emitter_Infected", DIR_NONE)
					Board:AddBurst(pawn:GetSpace(), "Emitter_Infected", DIR_NONE)
					Board:AddBurst(pawn:GetSpace(), "Emitter_Infected", DIR_NONE)
					mission.InfestedTable[id] = nil
				end
			end
		end
	end)
	modApi:addNextTurnHook(function(mission)							--this is for status that triggers each turn/after Vek actions
		for id, _ in pairs(mission.NecrosisTable) do
			local pawn = Board:GetPawn(id)
			if pawn and not pawn:IsDead() then pawn:SetMaxHealth(pawn:GetHealth()) end
		end
		for id, _ in pairs(mission.BondedTable) do
			local pawn = Board:GetPawn(id)
			if pawn then CustomAnim:rem(id, "StatusBondedOff") end
		end
		for id, gloryInfo in pairs(mission.GloryTable) do				--must happen after Vek performed queued actions
			local pawn = Board:GetPawn(id)
			if pawn and Game:GetTeamTurn() == pawn:GetTeam() then mission.GloryTable[id].turns = mission.GloryTable[id].turns - 1 end
			if mission.GloryTable[id].turns < 0 then Status.RemoveStatus(id, "Glory") end
		end
		if Game:GetTeamTurn() == TEAM_PLAYER then						--do confusion on player mechs: they move somewhere random
			for i = 0, 2 do
				local pawn = Board:GetPawn(i)
				if mission.ConfusionTable[i] ~= nil and pawn and not pawn:IsDead() then
					local targets = extract_table(Board:GetReachable(pawn:GetSpace(), pawn:GetMoveSpeed(), pawn:GetPathProf()))
					local target = random_removal(targets)
					if target == pawn:GetSpace() and #targets > 0 then target = random_removal(targets) end
					--try to force actual movement if possible
					if target ~= pawn:GetSpace() then
						local ret = SkillEffect()
						ret:AddMove(Board:GetPath(pawn:GetSpace(), target, pawn:GetPathProf()), FULL_DELAY)
						Board:AddEffect(ret)
						pawn:SetMovementSpent(true)
					end
				end
			end
		else															--do toxin check to propagate it		
			for id, _ in pairs(mission.ToxinTable) do
				local pawn = Board:GetPawn(id)
				if (not pawn) or pawn:IsDead() then
					mission.ToxinTable[id] = nil
				elseif pawn:IsDamaged() then
					local damage = SpaceDamage(pawn:GetSpace(), pawn:GetMaxHealth() - pawn:GetHealth())
					if Board:IsDeadly(damage, pawn) then
						Board:Ping(pawn:GetSpace(), GL_Color(100, 200, 100))
						CustomAnim:rem(id, "StatusToxin")				--anim disappears after Vek emerge otherwise, which looks weird
						for i = DIR_START, DIR_END do
							local curr = pawn:GetSpace() + DIR_VECTORS[i]
							local spreadTo = Board:GetPawn(curr)
							if spreadTo then 
								CustomAnim:add(spreadTo:GetId(), "StatusToxin") --for some reason anim doesn't get added even though status does
								modApi:runLater(function() Status.ApplyToxin(spreadTo:GetId()) end)
							end
							
						end
					else
						Status.RemoveStatus(id, "Toxin")
					end
					Board:DamageSpace(damage)
				end
			end
		end
		for id, recoverPerTurn in pairs(mission.WeakenTable) do
			local pawn = Board:GetPawn(id)
			if pawn and Game:GetTeamTurn() == pawn:GetTeam() and recoverPerTurn ~= 0 then
				local hasWeakenedWeapon = false
				for i = pawn:GetWeaponCount(), 1, -1 do
					local weapon = pawn:GetWeaponBaseType(i)
					if string.match(weapon, "^%dweaker") then 
						local baseWeapon = _G[weapon].Original
						local amount = tonumber(string.sub(weapon,1,1)) - recoverPerTurn
						local newWeapon
						if amount <= 0 then 
							newWeapon = baseWeapon 
						else 
							newWeapon = amount.."weaker"..baseWeapon 
							hasWeakenedWeapon = true
						end
						local target = pawn:GetQueuedTarget()
						local indexQueued = pawn:GetQueuedWeaponId()
						pawn:RemoveWeapon(i)
						pawn:AddWeapon(newWeapon)
						pawn:FireWeapon(target, indexQueued)
					end
				end
				if not hasWeakenedWeapon then CustomAnim:rem(id, "StatusWeaken") end
			end
		end
	end)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

return true