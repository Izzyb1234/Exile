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
	on_place = crafting.make_on_place("hand", 2, { x = 8, y = 3 }),
})


-- Register craft recipes once all modules loaded
minetest.register_on_mods_loaded(function()
	-- hand crafts
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
		output = "tech:stone_chopper 1",
		items = {"nodes_nature:gravel"},
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
	-- hand_mixing
	crafting.register_recipe({
		type = "hand_mixing",
		output = "tech:stick 4",
		items = {"tech:wattle"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_mixing",
		output = "tech:stick 2",
		items = {"tech:wattle_loose"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_mixing",
		output = "tech:wattle 2",
		items = {"doors:door_wattle"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_mixing",
		output = "tech:wattle",
		items = {"tech:trapdoor_wattle"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_mixing",
		output = "tech:wattle",
		items = {"tech:wattle_loose 2"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_mixing",
		output = "tech:wattle_loose 2",
		items = {"tech:wattle"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_mixing",
		output = "tech:wattle_door_frame",
		items = {"tech:wattle"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "hand_mixing",
		output = "tech:wattle",
		items = {"tech:wattle_door_frame"},
		level = 1,
		always_known = true,
	})
end)


