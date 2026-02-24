local gooList = easyEdit.enemyList:add("Goos")
local gooListPlus = easyEdit.enemyList:add("Goos + Vanilla")
gooListPlus.name = "Goos + Vanilla"

local other_enemyList = easyEdit.enemyList:get("archive")
gooListPlus:copy(other_enemyList)

local lists = {gooList, gooListPlus}

for i, list in pairs(lists) do--the goos are being added to Goos and Goos + Vanilla
    list:addEnemy("Meta_sludgegoo","Core")
    list:addEnemy("Meta_nestedgoo","Core")
    list:addEnemy("Meta_splittinggoo","Core")
    list:addEnemy("Meta_shapeshifter","Unique")
    list:addEnemy("Meta_spikygoo","Unique")
    list:addEnemy("Meta_pylongoo","Unique")
end
--others
    gooList:addEnemy("Snowtank", "Bots")
    gooList:addEnemy("Snowart", "Bots")
    gooList:addEnemy("Snowlaser", "Bots")
    gooList:addEnemy("Jelly_Health", "Leaders")
    gooList:addEnemy("Jelly_Regen", "Leaders")
    gooList:addEnemy("Jelly_Armor", "Leaders")
    gooList:addEnemy("Jelly_Explode", "Leaders")
    gooList:addEnemy("Jelly_Spider", "Leaders")
    gooList:addEnemy("Jelly_Fire", "Leaders")
    gooList:addEnemy("Jelly_Boost", "Leaders")

--function to make exclusions
    local function makeExclusive(id1, id2)
        for _, list in ipairs(exclusiveElements) do
            for _, enemy in ipairs(list) do
                if enemy == id1 then
                    table.insert(list, id2)
                    break
                elseif enemy == id2 then
                    table.insert(list, id1)
                    break
                end
            end
        end

        table.insert(exclusiveElements, {id1, id2})
    end
-- Exclusions
	local NestedExc = {"Jelly_Spider","Starfish","DNT_Mantis"}
	for i, list in pairs(NestedExc) do--enemies that might get in the way of the spawn on death,
		makeExclusive("Meta_nestedgoo", list[i])-- or attack several tiles
	end
	local SludgeExc = {"Beetle","lmn_Beanstalker"}
	for i, list in pairs(SludgeExc) do--enemies that charge
		makeExclusive("Meta_sludgegoo", list[i])
	end
	local PylonExc = {"Jelly_Spider","Centipede","Jelly_Explode",
                    "DNT_Thunderbug","lmn_Cactus"},--enemies that might endarger the pylon too much
	for i, list in pairs(PylonExc) do
		makeExclusive("Meta_nestedgoo", list[i])
	end
	local ShapeshifterExc = {"Centipede","Starfish","lmn_Spitter","DNT_Mantis"}, 
	for i, list in pairs(ShapeshifterExc) do--the two forms shapeshifter can turn into
		makeExclusive("Meta_shapeshifter", list[i])--plus two enemies that are exclusive to originals
	end
	local SplittingExc = {"Spider","Jelly_Spider","Shaman", "Blobber","lmn_Bud",
                        "lmn_Floater","lmn_Blobberling","DNT_Anthill"},
	for i, list in pairs(SplittingExc) do--spawns stuff
		makeExclusive("Meta_splittinggoo", list[i])
	end
	local SpikyExc = {"Moth","Crab","Scarab","DNT_Cockroach","DNT_Pillbug"},
	for i, list in pairs(SpikyExc) do--artilleries
		makeExclusive("Meta_splittinggoo", list[i])
	end