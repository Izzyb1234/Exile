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

-- Soil related
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


