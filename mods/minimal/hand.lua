-- The hand
minetest.register_item(":", {
	type = "none",
	wield_image = "wieldhand.png",
	wield_scale = {x=1,y=1,z=2.5},
	liquids_pointable = true,
	tool_capabilities = {
		full_punch_interval = minimal.hand_punch_int,
		max_drop_level = minimal.hand_max_lvl,
		groupcaps = {
			choppy = {times={[3]=minimal.hand_chop}, uses=0, maxlevel=minimal.hand_max_lvl},
			crumbly = {times={[3]=minimal.hand_crum}, uses=0, maxlevel=minimal.hand_max_lvl},
			snappy = {times={[3]=minimal.hand_snap}, uses=0, maxlevel=minimal.hand_max_lvl},
			oddly_breakable_by_hand = {
				times={
					[1]=minimal.hand_crum*minimal.t_scale1,
					[2]=minimal.hand_crum*minimal.t_scale2,
					[3]=minimal.hand_crum}, uses=0
				},
			},
		damage_groups = {fleshy=minimal.hand_dmg},
	},
	on_place = crafting.make_on_place(
		{"hand", "hand_pottery", "hand_wattle", "hand_mixing"},
		2, { x = 8, y = 3 }),
})


-- Register craft recipes once all modules loaded
minetest.register_on_mods_loaded(function()
	-- hand General
	crafting.register_recipe({
		type = "hand",
		output = "tech:sleeping_spot",
		items = {},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand",
		output = "tech:stick 2",
		items = {"group:woody_plant"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand",
		output = "tech:digging_stick 1",
		items = {"tech:stick 2"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand",
		output = "tech:small_wood_fire_unlit",
		items = {"tech:stick 6", "group:fibrous_plant 1"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand",
		output = "tech:large_wood_fire_unlit",
		items = {"tech:stick 12", "group:fibrous_plant 2"},
		level = 1,
		always_known = true,
	})

	crafting.register_recipe({
		type = "hand",
		output = "tech:stone_chopper 1",
		items = {"nodes_nature:gravel"},
		level = 1,
		always_known = true,
	})
	----craft drystack from gravel
	crafting.register_recipe({
		type = "hand",
		output = "tech:drystack 2",
		items = {"nodes_nature:gravel 3"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({ 
		type   = "hand",
		output = "tech:weaving_frame",
		items  = {'tech:stick 6', 'group:fibrous_plant 4'},
		level  = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type   = "hand",
		output = "tech:chopping_block",
		items  = {'group:log'},
		level  = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand",
		output = "ncrafting:dye_pot 1",
		items = {"tech:clay_water_pot 1", "tech:stick 1"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand",
		output = "ncrafting:dye_table 1",
		items = {"tech:stick 12"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type   = "hand",
		output = "tech:carpentry_bench",
		items  = {'tech:iron_ingot 4', 'nodes_nature:maraka_log 2'},
		level  = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type   = "hand",
		output = "tech:brick_makers_bench",
		items  = {'tech:stick 24'},
		level  = 1,
		always_known = true,
	})
	-- Pottery
	crafting.register_recipe({
		type = "hand_pottery",
		output = "tech:clay_water_pot_unfired 1",
		items = {"nodes_nature:clay_wet 4"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_pottery",
		output = "tech:clay_storage_pot_unfired 1",
		items = {"nodes_nature:clay_wet 6"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_pottery",
		output = "tech:clay_oil_lamp_unfired 1",
		items = {"nodes_nature:clay_wet"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_pottery",
		output = "tech:cooking_pot_unfired 1",
		items = {"nodes_nature:clay_wet 4"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_pottery",
		output = "nodes_nature:clay 4",
		items = {"tech:clay_water_pot_unfired 1"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_pottery",
		output = "nodes_nature:clay 6",
		items = {"tech:clay_storage_pot_unfired 1"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_pottery",
		output = "nodes_nature:clay",
		items = {"tech:clay_oil_lamp_unfired 1"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_pottery",
		output = "tech:broken_pottery",
		items = {"group:pottery"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_pottery",
		output = "tech:broken_pottery_block",
		items = {"tech:broken_pottery 2"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_pottery",
		output = "tech:broken_pottery 2",
		items = {"tech:broken_pottery_block"},
		level = 1,
		always_known = true,
	})
	-- hand_wattle
	crafting.register_recipe({
		type = "hand_wattle",
		output = "doors:door_wattle",
		items = {"tech:wattle 2", "group:fibrous_plant 2", "tech:stick 2"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_wattle",
		output = "tech:trapdoor_wattle",
		items = {"tech:wattle", "group:fibrous_plant", "tech:stick"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_wattle",
		output = "tech:wattle_loose",
		items = {"tech:stick 3"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_wattle",
		output = "tech:wattle",
		items = {"tech:stick 6"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_wattle",
		output = "tech:wattle_door_frame",
		items = {"tech:stick 6"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_wattle",
		output = "tech:wattle 2",
		items = {"doors:door_wattle"},
		level = 1,
		always_known = true,
	})

	crafting.register_recipe({
		type = "hand_wattle",
		output = "tech:wattle",
		items = {"tech:trapdoor_wattle"},
		level = 1,
		always_known = true,
	})
	-- hand_mixing
	crafting.register_recipe({
		type = "hand_mixing",
		output = "nodes_nature:snow_block",
		items = {"nodes_nature:snow 2"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_mixing",
		output = "nodes_nature:snow 2",
		items = {"nodes_nature:snow_block"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_mixing",
		output = "nodes_nature:snow_block 2",
		items = {"nodes_nature:ice"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_mixing",
		output = "nodes_nature:ice",
		items = {"nodes_nature:snow_block 2"},
		level = 1,
		always_known = true,
	})
	--recycle drystack with some loss
	crafting.register_recipe({
		type = "hand_mixing",
		output = "nodes_nature:gravel",
		items = {"tech:drystack"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_mixing",
		output = "tech:wood_ash 2",
		items = {"tech:wood_ash_block"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_mixing",
		output = "tech:wood_ash_block",
		items = {"tech:wood_ash 2"},
		level = 1,
		always_known = true,
	})
end)


-- knife_mixing
minetest.register_on_mods_loaded(function()
	crafting.register_recipe({
		type = "knife_mixing",
		output = "tech:wood_ash 2",
		items = {"tech:wood_ash_block"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "knife_mixing",
		output = "tech:wood_ash_block",
		items = {"tech:wood_ash 2"},
		level = 1,
		always_known = true,
	})
end)

-- Soil related
minetest.register_on_mods_loaded(function()
	crafting.register_recipe({
		type = "soil_mixing",
		output = "nodes_nature:loam 3",
		items = {"nodes_nature:clay 1","nodes_nature:silt 1","nodes_nature:sand 1"},
		level = 1,
		always_known = true,
	})

	crafting.register_recipe({
		type = "soil_mixing",
		output = "nodes_nature:loam_wet 3",
		items = {"nodes_nature:clay_wet 1","nodes_nature:silt_wet 1","nodes_nature:sand_wet 1"},
		level = 1,
		always_known = true,
	})
end)


