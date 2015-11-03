require "defines"
require "config"
require "prototypes.basic-lua-extensions"

local entityName = "rocketAutoStarter"

-- global data stored and used:
-- global.rocketAutoStarter.schedule[tick] = { idEntity(rocketAutoStarter), ... }

---------------------------------------------------
-- Loading
---------------------------------------------------
script.on_init(function()
	onLoad()
end)
script.on_load(function()
	onLoad()
end)

function onLoad()
	if not global then
		global = {}
		game.forces.player.reset_technologies()
		game.forces.player.reset_recipes()
	end
	debug("onload"..serpent.block(global.rocketAutoStarter))
	if not global.rocketAutoStarter then
		global.rocketAutoStarter = {}
		global.rocketAutoStarter.version = "0.1.0"
		global.rocketAutoStarter.schedule = {}
	end
	if not global.rocketAutoStarter.schedule then
		debug("initialized global.schedule")
		global.rocketAutoStarter.schedule = {}
	end
end

---------------------------------------------------
-- Tick
---------------------------------------------------
script.on_event(defines.events.on_tick, function(event)
	-- statistics about last sent rockets
	if messageForSentRockets and global.rocketAutoStarter.firstRocket then -- some rockets were already sent
		local ticksPerMinute = 60 * 60
		if game.tick > global.rocketAutoStarter.firstRocket + messageForSentRocketsEveryMinutes * ticksPerMinute then
			if global.rocketAutoStarter.rockets > 0 then
				playerPrint("Rockets automatically started in the last "..messageForSentRocketsEveryMinutes.." minutes: "..global.rocketAutoStarter.rockets)
				global.rocketAutoStarter.firstRocket = nil
				global.rocketAutoStarter.rockets = nil
			end
		end
	end
	
  -- if no updates are scheduled return
	if type(global.rocketAutoStarter.schedule[game.tick]) ~= "table" then
		return
	end
	for _,idEntity in pairs(global.rocketAutoStarter.schedule[game.tick]) do
		local entity = entityOfId(idEntity)
		if entity and entity.valid then
			local nextUpdateInXTicks, reasonMessage = runEntityInstructions(idEntity, entity)
			if reasonMessage ~= nil then
				debug(entityName.." at " .. entity.position.x .. ", " ..entity.position.y .. ": "..reasonMessage)
			end
			if nextUpdateInXTicks ~= nil then
				scheduleAdd(entity, game.tick + nextUpdateInXTicks)
			else
				-- if no more update is scheduled, remove it from memory
				-- nothing to be done here, the entity will just not be scheduled anymore
			end
		else
			-- if entity was removed, remove it from memory
			-- nothing to be done here, the entity will just not be scheduled anymore
		end
	end
	global.rocketAutoStarter.schedule[game.tick] = nil
end)

---------------------------------------------------
-- Building entities
---------------------------------------------------
script.on_event(defines.events.on_built_entity, function(event)
	if event.created_entity.name == entityName then
		entityBuilt(event.created_entity)
	end
end)
script.on_event(defines.events.on_robot_built_entity, function(event)
	if event.created_entity.name == entityName then
		entityBuilt(event.created_entity)
	end
end)

function entityBuilt(entity)
	debug("Entity built in tick "..game.tick.." and added it for update tick")
	scheduleAdd(entity, game.tick + updateEveryTicks)
end

---------------------------------------------------
-- Removal of entities
---------------------------------------------------
-- because no coordinate is passed for the following functions, we take care of this in the tick method
--[[
script.on_event(defines.events.on_player_mined_item, function(event)
	if event.item_stack.name == entityName then ... end
end)
script.on_event(defines.events.on_robot_mined, function(event)
	if event.item_stack.name == entityName then ... end
end)
script.on_event(defines.events.on_entity_died, function(event)
	if event.item_stack.name == entityName then ... end
end)
]]--

---------------------------------------------------
-- Utility methods
---------------------------------------------------
-- Adds new entry to the scheduling table
function scheduleAdd(entity, nextTick)
	if global.rocketAutoStarter.schedule[nextTick] == nil then
		global.rocketAutoStarter.schedule[nextTick] = {}
	end
	table.insert(global.rocketAutoStarter.schedule[nextTick],idOfEntity(entity))
end

function idOfEntity(entity)
	return string.format("%g_%g", entity.position.x, entity.position.y)
end
function entityOfId(id)
	local position = split(id,"_")
	local point = {tonumber(position[1]),tonumber(position[2])}
	local entities = game.surfaces.nauvis.find_entities{point,point}
	if entities == nil then return nil end
	if #entities == 0 then return nil end
	return entities[1]
end

---------------------------------------------------
-- Update methods
---------------------------------------------------

-- parameters: entity
-- return values: tickDelayForNextUpdate, reasonMessage
function runEntityInstructions(idOfEntity, entity)
	local pos = {x = entity.position.x, y = entity.position.y}
	
	local scan_coords = { -- Points to search
		{pos.x - 1, pos.y}, -- west
		{pos.x + 1, pos.y}, -- east
		{pos.x, pos.y - 1}, -- north
		{pos.x, pos.y + 1}, -- south
	}
	local rocketsStarted = 0
	for _,pointOfEntity in pairs(scan_coords) do
		local silos = entity.surface.find_entities_filtered{area = {pointOfEntity,pointOfEntity}, type = "rocket-silo"}
		if silos and #silos == 1 then
			local silo = silos[1]
			if silo.get_item_count("satellite") > 0 then
				silo.launch_rocket()
				rocketsStarted = rocketsStarted + 1
			end
		end
	end
	if rocketsStarted > 0 then
		if messageForSentRockets then
			if not global.rocketAutoStarter.firstRocket then -- no rockets sent yet
				global.rocketAutoStarter.firstRocket = game.tick
				global.rocketAutoStarter.rockets = rocketsStarted
			else -- add the current rockets to the statistics
				global.rocketAutoStarter.rockets = global.rocketAutoStarter.rockets + rocketsStarted
			end
		end
		return updateEveryTicks,"started "..rocketsStarted.." rockets."
	end
	return updateEveryTicks,"no actions taken"
end
