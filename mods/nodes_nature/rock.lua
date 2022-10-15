---------------------------------------------------------
--STONE

-- Internationalization
local S = nodes_nature.S

-- Load tables from data_rock.lua
stone_list = stone_list
rock_list  = rock_list

function cobble_on_place(itemstack, placer, pointed_thing, name)
	local pt_pos = minetest.get_pointed_thing_position(pointed_thing)
	local pt_node=minetest.get_node(pt_pos)
	if pt_node and  minetest.registered_nodes[pt_node.name].on_rightclick then
		return minetest.registered_nodes[pt_node.name].on_rightclick(pt_pos,pt_node,placer,itemstack,pointed_thing)
	end
	local cobble_nr = math.random(1,3)
	local param2 = math.random(0,3)
	local place_item = ItemStack("nodes_nature:"..name.."_cobble"..cobble_nr)
	itemstack:take_item(1)
	minetest.item_place_node(place_item, placer, pointed_thing, param2)
	return itemstack
end



for i in ipairs(stone_list) do
	local name = stone_list[i][1]
	local desc = stone_list[i][2]
	local hardness = stone_list[i][3]
	local type = stone_list[i][4]
	local sediment = stone_list[i][5]




	g = {cracky = hardness, crumbly = 1, soft_stone = 1}
	dropped = { max_items = 1,
		    items = {
		       { tools = { "artifacts:antiquorium_chisel" },
			 items = { "nodes_nature:"..name.."_block" } },
		       { items = { sediment } }
		    }
	}
	s = nodes_nature.node_sound_gravel_defaults({footstep = {name = "nodes_nature_hard_footstep", gain = 0.25},})

	--register raw
	minetest.register_node("nodes_nature:"..name, {
		description = desc,
		tiles = {"nodes_nature_"..name..".png"},
		stack_max = minimal.stack_max_bulky,
		groups = g,
		drop = dropped,
		sounds = s,
	})

	--blocks and bricks
	--drystone construction. (see tech for the mortared version)
	--Bricks are more portable.
	minetest.register_node("nodes_nature:"..name.."_brick", {
				  description = S("@1 Brick", desc),
				  tiles = {"nodes_nature_"..name.."_brick.png"},
				  paramtype2 = "facedir",
				  stack_max = minimal.stack_max_bulky *3,
				  groups = {cracky = hardness, falling_node = 1,  oddly_breakable_by_hand = 1, masonry = 1},
				  sounds = nodes_nature.node_sound_stone_defaults(),
	})

	--block is cut from stone with a chisel, can be masonry'd to brick
	minetest.register_node("nodes_nature:"..name.."_block", {
				  description = S("@1 Block", desc),
				  tiles = {"nodes_nature_"..name.."_block.png"},
				  stack_max = minimal.stack_max_bulky *2,
				  groups = {cracky = hardness, falling_node = 1, oddly_breakable_by_hand = 1, masonry = 1},
				  sounds = nodes_nature.node_sound_stone_defaults(),
	})

		--brick
		stairs.register_stair_and_slab(
			name.."_brick",
			"nodes_nature:"..name.."_brick",
			"masonry_bench",
			"true",
			{cracky = hardness, falling_node = 1, oddly_breakable_by_hand = 1},
			{"nodes_nature_"..name.."_brick.png" },
			desc.." Brick Stair",
			desc.." Brick Slab",
			minimal.stack_max_bulky * 6,
			nodes_nature.node_sound_stone_defaults()
		)

	crafting.register_recipe({
	      type = "masonry_bench",
	      output = "nodes_nature:"..name.."_brick",
	      items = {"nodes_nature:"..name.."_block"},
	      level = 1,
	      always_known = true,
	})
end


for i in ipairs(rock_list) do
	local name = rock_list[i][1]
	local desc = rock_list[i][2]
	local hardness = rock_list[i][3]



	--harder rocks drop boulders
	local g = {cracky = hardness, stone = 1}
	local dropped = "nodes_nature:"..name.."_boulder"
	local s = nodes_nature.node_sound_stone_defaults()




	--register raw
	minetest.register_node("nodes_nature:"..name, {
		description = desc,
		tiles = {"nodes_nature_"..name..".png"},
		stack_max = minimal.stack_max_bulky,
		groups = g,
		drop = dropped,
		sounds = s,
	})



		--boulder
		minetest.register_node("nodes_nature:"..name.."_boulder",{
			description = S("@1 Boulder", desc),
			drawtype = "mesh",
			mesh = "nodes_nature_boulder.obj",
			tiles = {"nodes_nature_"..name..".png"},
			stack_max = minimal.stack_max_bulky,
			paramtype = "light",
			paramtype2 = "facedir",
			groups = {cracky = hardness, falling_node = 1, oddly_breakable_by_hand = 1, boulder = 1},
			selection_box = {
				type = "fixed",
				fixed = {-7/16, -8/16, -7/16, 7/16, 7/16, 7/16},
			},
			collision_box = {
				type = "fixed",
				fixed = {-7/16, -8/16, -7/16, 7/16, 7/16, 7/16},
			},
			sounds = nodes_nature.node_sound_stone_defaults(),
		})


		--blocks and bricks
		--drystone construction. (see tech for the mortared version)
		--Bricks are more portable.
		minetest.register_node("nodes_nature:"..name.."_brick", {
			description = S("@1 Brick", desc),
			tiles = {"nodes_nature_"..name.."_brick.png"},
			paramtype2 = "facedir",
			stack_max = minimal.stack_max_bulky *3,
			groups = {cracky = hardness, falling_node = 1,  oddly_breakable_by_hand = 1, masonry = 1},
			sounds = nodes_nature.node_sound_stone_defaults(),
		})

		--block is a shaped boulder, so has similar properties
		minetest.register_node("nodes_nature:"..name.."_block", {
			description = S("@1 Block", desc),
			tiles = {"nodes_nature_"..name.."_block.png"},
			--drawtype = "nodebox",
			--paramtype = "light",
			--[[...fancy block
			node_box = {
				type = "fixed",
				fixed = {
					{-0.375, -0.5, -0.375, 0.375, 0.5, 0.375},
					{-0.375, -0.5, 0.375, 0.375, 0.5, 0.5},
					{-0.375, -0.5, -0.5, 0.375, 0.5, -0.375},
					{0.375, -0.5, -0.375, 0.5, 0.5, 0.375},
					{-0.5, -0.5, -0.375, -0.375, 0.5, 0.375},
					{-0.5, -0.375, -0.5, -0.375, 0.375, -0.375},
					{0.375, -0.375, -0.5, 0.5, 0.375, -0.375},
					{0.375, -0.375, 0.375, 0.5, 0.375, 0.5},
					{-0.5, -0.375, 0.375, -0.375, 0.375, 0.5},
				}
			},]]
			stack_max = minimal.stack_max_bulky *2,
			groups = {cracky = hardness, falling_node = 1, oddly_breakable_by_hand = 1, masonry = 1},
			sounds = nodes_nature.node_sound_stone_defaults(),
		})

		--hammer out blocks etc from boulder
		crafting.register_recipe({
			type = "hammering_block",
			output = "nodes_nature:"..name.."_block",
			items = {"nodes_nature:"..name.."_boulder"},
			level = 1,
			always_known = true,
		})

                crafting.register_recipe({
                      type = "hammering_block",
                      output = "nodes_nature:"..name.."_cobble1 8",
                      items = {"nodes_nature:"..name.."_boulder"},
                      level = 1,
                      always_known = true,
		})

		crafting.register_recipe({
			type = "masonry_bench",
			output = "nodes_nature:"..name.."_block",
			items = {"nodes_nature:"..name.."_boulder"},
			level = 1,
			always_known = true,
		})

		crafting.register_recipe({
			type = "masonry_bench_mixing",
			output = "nodes_nature:"..name.."_brick",
			items = {"nodes_nature:"..name.."_boulder"},
			level = 1,
			always_known = true,
		})

		-- hand_mixing doesn't exist yet; wait till all mods loaded
		minetest.register_on_mods_loaded(function()
			--recycle block (e.g. so can get iron ore)
			crafting.register_recipe({
				type = "hammer_mixing",
				output = "nodes_nature:"..name.."_boulder",
				items = {"nodes_nature:"..name.."_block"},
				level = 1,
				always_known = true,
			})
		end)

		--stairs and slabs

		--brick
		stairs.register_stair_and_slab(
			name.."_brick",
			"nodes_nature:"..name.."_brick",
			"masonry_bench",
			"true",
			{cracky = hardness, falling_node = 1, oddly_breakable_by_hand = 1},
			{"nodes_nature_"..name.."_brick.png" },
			desc.." Brick Stair",
			desc.." Brick Slab",
			minimal.stack_max_bulky * 6,
			nodes_nature.node_sound_stone_defaults()
		)

		--block
		stairs.register_stair_and_slab(
			name.."_block",
			"nodes_nature:"..name.."_block",
			"masonry_bench",
			"false",
			{cracky = hardness, falling_node = 1, oddly_breakable_by_hand = 1},
			{"nodes_nature_"..name.."_block.png" },
			desc.." Block Stair",
			desc.." Block Slab",
			minimal.stack_max_bulky * 4,
			nodes_nature.node_sound_stone_defaults()
		)

                local cobble_groups = {cracky = hardness,
                                       falling_node = 1,
                                       oddly_breakable_by_hand = 3,}
                cobble_groups[name.."_cobble"] = 1

                -- cobbles
                for cobble_nr = 1, 3 do
                   minetest.register_node(
                      "nodes_nature:"..name.."_cobble"..cobble_nr,{
                         description = S("@1 Cobble", desc),
                         drawtype = "mesh",
                         mesh = "nodes_nature_cobble"..cobble_nr..".obj",
                         tiles = {"nodes_nature_"..name..".png"},
                         stack_max = minimal.stack_max_bulky * 8,
                         paramtype = "light",
                         paramtype2 = "facedir",
                         groups = cobble_groups,
			 drop = "nodes_nature:"..name.."_cobble1",
			 on_place = function(itemstack, placer, pointed_thing)
				 return cobble_on_place(itemstack, placer, pointed_thing, name)
			 end,
			 on_rightclick = crafting.make_on_rightclick("grinding_stone", 2, { x = 8, y = 3 }),
                         selection_box = {
                            type = "fixed",
                            fixed = {-5/16, -8/16, -5/16, 5/16, -4/16, 5/16},
                         },
                         collision_box = {
                            type = "fixed",
                            fixed = {-5/16, -8/16, -5/16, 5/16, -4/16, 5/16},
                         },
                         sounds = nodes_nature.node_sound_stone_defaults(),
                   })
                end

end

------------------------------------------------------------------
--Special features
