data:extend({
 {
    type = "container",
    name = "rocketAutoStarter",
    icon = "__rocketAutoStarter__/graphics/icons/rocketAutoStarter.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 2, result = "rocketAutoStarter"},
		max_health = 300,
		corpse = "small-remnants",
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		inventory_size = 0,
    open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" },
    close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" },
    vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 },
    picture =
    {
      filename = "__rocketAutoStarter__/graphics/entity/rocketAutoStarter.png",
			priority = "extra-high",
      width = 136,
			height = 132,
			shift = {0.875, -1},
    },
  },
	--[[
	{
		type = "radar",
		name = "rocketAutoStarter",
		icon = "__rocketAutoStarter__/graphics/icons/rocketAutoStarter.png",
		flags = {"placeable-player", "player-creation"},
		minable = {hardness = 0.2, mining_time = 2, result = "rocketAutoStarter"},
		max_health = 300,
		corpse = "big-remnants",
		resistances = {
			{
				type = "fire",
				percent = 70
			}
		},
		collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		energy_per_sector = "10MJ",
		max_distance_of_sector_revealed = 0,
		max_distance_of_nearby_sector_revealed = 0,
		energy_per_nearby_scan = "250kJ",
		energy_source = {
			type = "electric",
			usage_priority = "secondary-input"
		},
		energy_usage = "50kW",
		pictures = {
			filename = "__rocketAutoStarter__/graphics/entity/rocketAutoStarter.png",
			priority = "high",
			width = 136,
			height = 132,
			apply_projection = false,
			direction_count = 1,
			line_length = 1,
			shift = {0.875, -0.35},
			tint = {r=.9,g=.7,b=.7,a=1}
		},
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		working_sound = {
			sound = {
				{ filename = "__base__/sound/radar.ogg" }
			},
			apparent_volume = 2,
		}
	}
	]]--
})