require "config"
require "libs.functions"
require "libs.entities"

---------------------------------------------------
-- Loading
---------------------------------------------------
script.on_init(function()
	migration()
end)

script.on_configuration_changed(function()
	migration()
end)

script.on_load(function()
	info("version before: "..global.rocketAutoStarter.version)
end)

function migration()
	info("migration: "..serpent.block(global.rocketAutoStarter))
	if not global.rocketAutoStarter then
		global.rocketAutoStarter = {}
	elseif global.rocketAutoStarter == "0.1.0" then
		global.rocketAutoStarter.schedule = nil
	end
	global.rocketAutoStarter.version = "0.2.0"
	entities_init()
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
				libLog.PlayerPrint("Rockets automatically started in the last "..messageForSentRocketsEveryMinutes.." minutes: "..global.rocketAutoStarter.rockets)
				global.rocketAutoStarter.firstRocket = nil
				global.rocketAutoStarter.rockets = nil
			end
		end
	end
	
	entities_tick()
end)

---------------------------------------------------
-- Building entities
---------------------------------------------------
script.on_event(defines.events.on_built_entity, function(event)
	entities_build(event)
end)
script.on_event(defines.events.on_robot_built_entity, function(event)
	entities_build(event)
end)

---------------------------------------------------
-- Register entity
---------------------------------------------------

local rocketAutoStarter = {}
entities["rocketAutoStarter"] = rocketAutoStarter

rocketAutoStarter.build = function(entity)
	info("Entity built in tick "..game.tick.." and added it for update tick")
	scheduleAdd(entity, game.tick + updateEveryTicks)
	entity.operable = false
	entity.rotatable = false
	return {}
end

-- parameters: entity
-- return values: tickDelayForNextUpdate, reasonMessage
rocketAutoStarter.tick = function(entity,data)
	local pos = entity.position
	
	local scan_coords = { -- Points to search
		{pos.x - 1, pos.y}, -- west
		{pos.x + 1, pos.y}, -- east
		{pos.x, pos.y - 1}, -- north
		{pos.x, pos.y + 1}, -- south
	}
	local rocketsStarted = 0
	for _,pointOfEntity in pairs(scan_coords) do
		info("testing point: "..serpent.block(pointOfEntity))
		local silos = entity.surface.find_entities_filtered{position = pointOfEntity, type = "rocket-silo"}
		info("found silos: "..serpent.block(silos))
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
