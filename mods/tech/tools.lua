
------------------------------------
--TOOL CRAFTS

--[[
Tool values based on multipliers from hand values
Tools can dig even unsuitable types, if you would use it if you were desperate.
Tools get increased wear on unsuitable tasks (e.g. chopping wood with a sword would ruin the sword)
Therefore many tools can be used by the player as multi-purpose,
which should be useful given the limits on resources and space they face.


]]

-- Internationalization
local S = tech.S

local base_use = 500
local base_punch_int = minimal.hand_punch_int

-----------------------------------

--Till soil
local function till_soil(itemstack, placer, pointed_thing, uses)
	--agriculture
	if pointed_thing.type ~= "node" then
		return
	end

	local under = minetest.get_node(pointed_thing.under)
	-- am I clicking on something with existing on_rightclick function?
	local def = minetest.registered_nodes[under.name]
	if def and def.on_rightclick then
		return def.on_rightclick(pointed_thing.under, under, placer, itemstack)
	end

	local p = {x=pointed_thing.under.x, y=pointed_thing.under.y+1, z=pointed_thing.under.z}
	local above = minetest.get_node(p)

	-- return if any of the nodes is not registered
	local node_name = under.name
	local nodedef = minetest.registered_nodes[node_name]

	if not nodedef then
		return
	end
	if not minetest.registered_nodes[above.name] then
		return
	end

	-- check if the node above the pointed thing is air
	if above.name ~= "air" then
		return
	end

	--living surface level sediment

	if minetest.get_item_group(node_name, "spreading") ~= 0 then

		--figure out what soil it is from dropped
		local ag_soil = nodedef._ag_soil

		minetest.swap_node(pointed_thing.under, {name = ag_soil})
		minetest.sound_play("nodes_nature_dig_crumbly", {pos = pointed_thing.under, gain = 0.5,})


		itemstack:add_wear(65535/(uses-1))

		return itemstack
	end



end

--Hammers

--Places hammer
local function place_tool(itemstack, placer, pointed_thing, placed_name)
    local place_item = ItemStack(placed_name)
    local above = minetest.get_node(pointed_thing.above)
    local under = minetest.get_node(pointed_thing.under)
    local under_front_pos = {x = pointed_thing.above.x,
                             y = pointed_thing.above.y - 1,
                             z = pointed_thing.above.z}
    local under_front = minetest.get_node(under_front_pos)
    -- check if not walkable - there's empty space over the node (air, water, etc.)
    if not minetest.registered_nodes[above.name].walkable and
        -- check if walkable below to avoid throwing tools into abyss
        minetest.registered_nodes[under_front.name].walkable then
        -- check if the pointed item has on_rightclick ...
        if not minetest.registered_nodes[under.name].on_rightclick then
            local wear = itemstack:get_wear()
            -- place if not
            itemstack:take_item(1)
            minetest.item_place_node(place_item, placer, pointed_thing)
            local meta = minetest.get_meta(pointed_thing.above)
            meta:set_int("wear", wear)
            return itemstack
        else
            -- if yes use the on_rightclick of the pointed thing instead
            return minetest.registered_nodes[under.name].on_rightclick(pointed_thing.under, under, placer, itemstack, pointed_thing)
        end
    end
end

local function on_dig_tool(pos, node, digger, name)
    local meta = minetest.get_meta(pos)
    local wear = meta:get_int("wear")
    local stack = ItemStack(name)
    stack:set_wear(wear)
    minetest.remove_node(pos)
    local player_inv = digger:get_inventory()
    if player_inv:room_for_item("main", stack) then
        player_inv:add_item("main", stack)
    else
        minetest.add_item(pos, stack) -- drop item if inventory full
    end
end

-- opens the hammering spot GUI
local open_hammering_spot = crafting.make_on_rightclick("hammer", 2, { x = 8, y = 3 })

-- opens the chopping spot GUI
local open_chopping_spot = crafting.make_on_rightclick({"axe","axe_mixing"}, 2, { x = 8, y = 3 })

local open_knife = crafting.make_on_rightclick({"knife",'knife_mixing'}, 2, { x = 8, y = 3 })


-- checks if the node has one of the groups from good_on
local function is_spot_valid(node, good_on)
    for i in ipairs(good_on) do
        local group = good_on[i][1]
        local num = good_on[i][2]
        if minetest.get_item_group(node.name, group) == num then
            return true
        end
    end
    return false
end

-- opens the hammering spot GUI if the hammer is placed on a solid node
local function open_hammering_spot_if_valid(pos, node, clicker, itemstack, pointed_thing)
    local good_on = {{"stone", 1}, {"masonry", 1}, {"boulder", 1}, {"soft_stone", 1}, {"tree", 1}, {"log", 1}}
    local pos_under = {x = pos.x, y = pos.y - 1, z = pos.z}
    local ground = minetest.get_node(pos_under)
    if is_spot_valid(ground, good_on) then
        open_hammering_spot(pos, node, clicker, itemstack, pointed_thing)
    else
        minetest.chat_send_player(
            clicker:get_player_name(),
            "Can't do hammering here! Needs: stone, masonry, tree, or a log.")
    end
end

-- opens the chopping spot GUI if the hammer is placed on a solid node
local function open_chopping_spot_if_valid(pos, node, clicker, itemstack, pointed_thing)
    local good_on = {{"stone", 1}, {"masonry", 1}, {"soft_stone", 1}, {"tree", 1}, {"log", 1}}
    local pos_under = {x = pos.x, y = pos.y - 1, z = pos.z}
    local ground = minetest.get_node(pos_under)
    if is_spot_valid(ground, good_on) then
        open_chopping_spot(pos, node, clicker, itemstack, pointed_thing)
    else
        minetest.chat_send_player(
            clicker:get_player_name(),
            "Can't chop here! Needs: stone, masonry, tree, or a log.")
    end
end

---------------------------------------
--Tools


--------------------------
--1st level
--Crude emergency tools

local hand_max_lvl = minimal.hand_max_lvl
local crude = 0.8
--local crude_use = base_use
local crude_max_lvl = hand_max_lvl

--damage
local crude_dmg = minimal.hand_dmg * 2
--snappy
local crude_snap3 = minimal.hand_snap * crude
local crude_snap2 = crude_snap3 * minimal.t_scale2
local crude_snap1 = crude_snap3 * minimal.t_scale1
local crude_snap0 = 100 -- really long dig time - effectively disabled
--crumbly
local crude_crum3 = minimal.hand_crum * crude
local crude_crum2 = crude_crum3 * minimal.t_scale2
local crude_crum1 = crude_crum3 * minimal.t_scale1
local crude_crum0 = 100 -- really long dig time - effectively disabled
--choppy
local crude_chop3 = minimal.hand_chop * crude
local crude_chop2 = crude_chop3 * minimal.t_scale2
--cracky
--none at this level



--
-- Multitool
--

--a crude chipped stone: 1.snap. 2. chop 3.crum
minetest.register_tool("tech:stone_chopper", {
	description = S("Stone Knife"),
	inventory_image = "tech_tool_stone_chopper.png",
	tool_capabilities = {
		full_punch_interval = base_punch_int,
		groupcaps={
			choppy = {times={[3]=crude_chop0}, uses=base_use*0.75, maxlevel=crude_max_lvl},
			snappy= {times={[1]=crude_snap1, [2]=crude_snap2, [3]=crude_snap3}, uses=base_use, maxlevel=crude_max_lvl},
			crumbly = {times={[3]=crude_crum0}, uses=base_use*0.5, maxlevel=crude_max_lvl}
		},
		damage_groups = {fleshy= crude_dmg},
	},
	groups = {knife = 1, craftedby = 1},
	sound = {breaks = "tech_tool_breaks"},
        on_place = function(itemstack, placer, pointed_thing)
            return place_tool(itemstack, placer, pointed_thing, "tech:stone_knife_placed")
        end,
})

-- Placed stone knife
minetest.register_node(
    "tech:stone_knife_placed", {
        description = S("Placed Stone Knife"),
        drawtype = "mesh",
        mesh = "stone_knife_placed.obj",
        tiles = {name = "tech_stone_knife_placed.png"},
        paramtype = "light",
        paramtype2 = "facedir",
        sounds = nodes_nature.node_sound_stone_defaults(),
        groups = {dig_immediate = 3, temp_pass = 1, falling_node = 1, not_in_creative_inventory = 1},
        selection_box = {
            type = "fixed",
            fixed = {-4/16, -8/16, -4/16, 4/16, -7/16, 4/16},
        },
        collision_box = {
            type = "fixed",
            fixed = {-4/16, -8/16, -4/16, 4/16, -7/16, 4/16},
        },
        on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
            open_knife(pos, node, clicker, itemstack, pointed_thing)
        end,
        on_dig = function(pos, node, digger)
            on_dig_tool(pos, node, digger, "tech:stone_chopper")
        end,
})

--
-- Crumbly
--

-- digging stick... specialist for digging. Can also till
local digging_stick_crafting = crafting.make_on_place({"threshing_spot","soil_mixing"}, 2, { x = 8, y = 3 })
minetest.register_tool("tech:digging_stick", {
	description = S("Digging Stick"),
	inventory_image = "tech_tool_digging_stick.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = base_punch_int*1.1,
		groupcaps={
			crumbly = {times= {[1]=crude_crum1, [2]=crude_crum2, [3]=crude_crum3}, uses=base_use, maxlevel=crude_max_lvl}
		},
		damage_groups = {fleshy= crude_dmg},
	},
	groups = {shovel = 1, craftedby = 1},
	sound = {breaks = "tech_tool_breaks"},
	on_place = function(itemstack, placer, pointed_thing)
		if not till_soil(itemstack, placer, pointed_thing, base_use) then
			digging_stick_crafting(itemstack, placer, pointed_thing) 
		end
	end
})



--------------------------
--2nd level
--polished stone tools. Sophisticated stone age tools

--[[
note: we have multiple rock types
Granite is harder than basalt.
]]--

local stone = 0.8
local stone_use = base_use * 2
local stone_max_lvl = hand_max_lvl

--damage
local stone_dmg = crude_dmg * 2
--snappy
local stone_snap3 = crude_snap3 * stone
local stone_snap2 = crude_snap2 * stone
local stone_snap1 = crude_snap1 * stone
--crumbly
local stone_crum3 = crude_crum3 * stone
local stone_crum2 = crude_crum2 * stone
local stone_crum1 = crude_crum1 * stone
--choppy
local stone_chop3 = crude_chop3 * stone
local stone_chop2 = crude_chop2 * stone
--cracky
--none at this level


--
-- multitool
--

--stone adze. best for chopping
minetest.register_tool("tech:adze_granite", {
	description = S("Granite Adze"),
	inventory_image = "tech_tool_adze_granite.png",
	tool_capabilities = {
		full_punch_interval = base_punch_int * 1.1,
		groupcaps={
			choppy = {times={[2]=stone_chop2, [3]=stone_chop3}, uses=stone_use, maxlevel=stone_max_lvl},
			snappy={times={[1]=stone_snap1, [2]=stone_snap2, [3]=stone_snap3}, uses=stone_use *0.8, maxlevel=stone_max_lvl},
			crumbly = {times={[3]=crude_crum3}, uses=base_use, maxlevel=crude_max_lvl},
		},
		damage_groups = {fleshy = stone_dmg},
	},
	on_place = crafting.make_on_place({"axe","axe_mixing"}, 2, { x = 8, y = 3 }),
	groups = {axe = 1,craftedby = 1},
	sound = {breaks = "tech_tool_breaks"},
        on_place = function(itemstack, placer, pointed_thing)
            return place_tool(itemstack, placer, pointed_thing, "tech:adze_granite_placed")
        end,
})

-- Placed granite adze
minetest.register_node(
    "tech:adze_granite_placed", {
        description = S("Placed Granite Adze"),
        drawtype = "mesh",
        mesh = "adze_placed.obj",
        tiles = {name = "tech_adze_granite_placed.png"},
        paramtype = "light",
        paramtype2 = "facedir",
        sounds = nodes_nature.node_sound_stone_defaults(),
        groups = {dig_immediate = 3, temp_pass = 1, falling_node = 1, not_in_creative_inventory = 1},
        node_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, -0.45, 0.5},
        },
	selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
        },
        on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
            open_chopping_spot_if_valid(pos, node, clicker, itemstack, pointed_thing)
        end,
        on_dig = function(pos, node, digger)
            on_dig_tool(pos, node, digger, "tech:adze_granite")
        end,
})

--less uses than granite bc softer stone
minetest.register_tool("tech:adze_basalt", {
	description = S("Basalt Adze"),
	inventory_image = "tech_tool_adze_basalt.png",
	tool_capabilities = {
		full_punch_interval = base_punch_int * 1.1,
		groupcaps={
			choppy = {times={[2]=stone_chop2, [3]=stone_chop3}, uses=stone_use *0.9, maxlevel=stone_max_lvl},
			snappy= {times={[1]=stone_snap1, [2]=stone_snap2, [3]=stone_snap3}, uses=stone_use *0.7, maxlevel=stone_max_lvl},
			crumbly = {times={[3]=crude_crum3}, uses=base_use*0.9, maxlevel=crude_max_lvl},
		},
		damage_groups = {fleshy = stone_dmg},
	},
	on_place = crafting.make_on_place({"axe","axe_mixing"}, 2, { x = 8, y = 3 }),
	groups = {axe = 1, craftedby = 1},
	sound = {breaks = "tech_tool_breaks"},
        on_place = function(itemstack, placer, pointed_thing)
            return place_tool(itemstack, placer, pointed_thing, "tech:adze_basalt_placed")
        end,
})

-- Placed basalt adze
minetest.register_node(
    "tech:adze_basalt_placed", {
        description = S("Placed Basalt Adze"),
        drawtype = "mesh",
        mesh = "adze_placed.obj",
        tiles = {name = "tech_adze_basalt_placed.png"},
        paramtype = "light",
        paramtype2 = "facedir",
        sounds = nodes_nature.node_sound_stone_defaults(),
        groups = {dig_immediate = 3, temp_pass = 1, falling_node = 1, not_in_creative_inventory = 1},
        node_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, -0.45, 0.5},
        },
	selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
        },
        on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
            open_chopping_spot_if_valid(pos, node, clicker, itemstack, pointed_thing)
        end,
        on_dig = function(pos, node, digger)
            on_dig_tool(pos, node, digger, "tech:adze_basalt")
        end,
})

--many more uses than granite.
minetest.register_tool("tech:adze_jade", {
	description = S("Jade Adze"),
	inventory_image = "tech_tool_adze_jade.png",
	tool_capabilities = {
		full_punch_interval = base_punch_int * 1.1,
		groupcaps={
			choppy = {times={[2]=stone_chop2, [3]=stone_chop3}, uses=stone_use * 1.5, maxlevel=stone_max_lvl},
			snappy={times={[1]=stone_snap1, [2]=stone_snap2, [3]=stone_snap3}, uses=stone_use, maxlevel=stone_max_lvl},
			crumbly = {times={[3]=crude_crum3}, uses=base_use, maxlevel=crude_max_lvl},
		},
		damage_groups = {fleshy = stone_dmg},
	},
	on_place = crafting.make_on_place({"axe","axe_mixing"}, 2, { x = 8, y = 3 }),
	groups = {axe = 1, craftedby = 1},
	sound = {breaks = "tech_tool_breaks"},
        on_place = function(itemstack, placer, pointed_thing)
            return place_tool(itemstack, placer, pointed_thing, "tech:adze_jade_placed")
        end,
})

-- Placed jade adze
minetest.register_node(
    "tech:adze_jade_placed", {
        description = S("Placed Jade Adze"),
        drawtype = "mesh",
        mesh = "adze_placed.obj",
        tiles = {name = "tech_adze_jade_placed.png"},
        paramtype = "light",
        paramtype2 = "facedir",
        sounds = nodes_nature.node_sound_stone_defaults(),
        groups = {dig_immediate = 3, temp_pass = 1, falling_node = 1, not_in_creative_inventory = 1},
        node_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, -0.45, 0.5},
        },
	selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
        },
        on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
            open_chopping_spot_if_valid(pos, node, clicker, itemstack, pointed_thing)
        end,
        on_dig = function(pos, node, digger)
            on_dig_tool(pos, node, digger, "tech:adze_jade")
        end,
})

--stone club. A weapon. Not very good for anything else
--can stun catch animals
minetest.register_tool("tech:stone_club", {
	description = S("Stone Club"),
	inventory_image = "tech_tool_stone_club.png",
	tool_capabilities = {
		full_punch_interval = base_punch_int * 1.2,
		groupcaps={
			choppy = {times={[3]=crude_chop3}, uses=base_use*0.5, maxlevel=crude_max_lvl},
			snappy = {times={[3]=crude_snap3}, uses=base_use*0.5, maxlevel=crude_max_lvl},
			crumbly = {times= {[3]=crude_crum3}, uses=base_use*0.5, maxlevel=crude_max_lvl}
		},
		damage_groups = {fleshy=stone_dmg*2},
	},
	groups = {club = 1, craftedby = 1},
	sound = {breaks = "tech_tool_breaks"},
})




--------------------------
--3rd level
--iron tools.



local iron = 0.9
local iron_use = base_use * 4
local iron_max_lvl = hand_max_lvl + 1

--damage
local iron_dmg = stone_dmg * 2
--snappy
local iron_snap3 = stone_snap3 * iron
local iron_snap2 = stone_snap2 * iron
local iron_snap1 = stone_snap1 * iron
--crumbly
local iron_crum3 = stone_crum3 * iron
local iron_crum2 = stone_crum2 * iron
local iron_crum1 = stone_crum1 * iron
--choppy
local iron_chop3 = stone_chop3 * iron
local iron_chop2 = stone_chop2 * iron
local iron_chop1 = (minimal.hand_chop * minimal.t_scale1) * crude * stone * iron
--cracky
local iron_crac3 = minimal.hand_crac * crude * stone * iron
local iron_crac2 = (minimal.hand_crac * minimal.t_scale2) * crude * stone * iron
--local iron_crac1 = (minimal.hand_crac * minimal.t_scale1) * crude * stone * iron




--Axe. best for chopping, snappy
minetest.register_tool("tech:axe_iron", {
	description = S("Iron Axe"),
	inventory_image = "tech_tool_axe_iron.png",
	tool_capabilities = {
		full_punch_interval = base_punch_int * 1.1,
		groupcaps={
			choppy = {times={[1]=iron_chop1, [2]=iron_chop2, [3]=iron_chop3}, uses=iron_use, maxlevel=iron_max_lvl},
			snappy = {times={[1]=iron_snap1, [2]=iron_snap2, [3]=iron_snap3}, uses=iron_use, maxlevel=iron_max_lvl},
			crumbly = {times={[3]=crude_crum3}, uses= stone_use, maxlevel=stone_max_lvl},
		},
		damage_groups = {fleshy = iron_dmg},
	},
	on_place = crafting.make_on_place({"axe","axe_mixing"}, 2, { x = 8, y = 3 }),
	groups = {axe = 1, craftedby = 1},
	sound = {breaks = "tech_tool_breaks"},
        on_place = function(itemstack, placer, pointed_thing)
            return place_tool(itemstack, placer, pointed_thing, "tech:axe_iron_placed")
        end,
})

-- Placed iron axe
minetest.register_node(
    "tech:axe_iron_placed", {
        description = S("Placed Iron Axe"),
        drawtype = "mesh",
        mesh = "axe_placed.obj",
        tiles = {name = "tech_axe_iron_placed.png"},
        paramtype = "light",
        paramtype2 = "facedir",
        sounds = nodes_nature.node_sound_stone_defaults(),
        groups = {dig_immediate = 3, temp_pass = 1, falling_node = 1, not_in_creative_inventory = 1},
        node_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, -0.45, 0.5},
        },
	selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
        },
        on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
            open_chopping_spot_if_valid(pos, node, clicker, itemstack, pointed_thing)
        end,
        on_dig = function(pos, node, digger)
            on_dig_tool(pos, node, digger, "tech:axe_iron")
        end,
})


-- shovel... best for digging. Can also till
minetest.register_tool("tech:shovel_iron", {
	description = S("Iron Shovel"),
	inventory_image = "tech_tool_shovel_iron.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = base_punch_int*1.1,
		groupcaps={
			crumbly = {times= {[1]=iron_crum1, [2]=iron_crum2, [3]=iron_crum3}, uses=iron_use, maxlevel=iron_max_lvl},
			snappy = {times= {[3]=stone_snap3}, uses=iron_use *0.8, maxlevel=iron_max_lvl},
		},
		damage_groups = {fleshy= iron_dmg},
	},
	groups = {shovel = 1, craftedby = 1},
	sound = {breaks = "tech_tool_breaks"},
	on_place = function(itemstack, placer, pointed_thing)
		if not till_soil(itemstack, placer, pointed_thing, iron_use) then
			digging_stick_crafting(itemstack, placer, pointed_thing) 
		end
	end
})


--Mace.  A weapon. Not very good for anything else
--can stun catch animals
minetest.register_tool("tech:mace_iron", {
	description = S("Iron Mace"),
	inventory_image = "tech_tool_mace_iron.png",
	tool_capabilities = {
		full_punch_interval = base_punch_int * 1.2,
		groupcaps={
			choppy = {times={[3]=crude_chop3}, uses=base_use*0.5, maxlevel=crude_max_lvl},
			snappy = {times={[3]=crude_snap3}, uses=base_use*0.5, maxlevel=crude_max_lvl},
			crumbly = {times= {[3]=crude_crum3}, uses=base_use*0.5, maxlevel=crude_max_lvl},
		},
		damage_groups = {fleshy=iron_dmg*2},
	},
	groups = {club = 1, craftedby = 1},
	sound = {breaks = "tech_tool_breaks"},
})


--Pick Axe. mining, digging
minetest.register_tool("tech:pickaxe_iron", {
	description = S("Iron Pickaxe"),
	inventory_image = "tech_tool_pickaxe_iron.png",
	tool_capabilities = {
		full_punch_interval = base_punch_int * 1.1,
		groupcaps={
			choppy = {times={[3]=stone_chop3}, uses=iron_use *0.8, maxlevel=iron_max_lvl},
			snappy = {times={[3]=stone_snap3}, uses=iron_use *0.8, maxlevel=iron_max_lvl},
			crumbly = {times={[2]=stone_crum2, [3]=stone_crum3}, uses= iron_use, maxlevel=iron_max_lvl},
			cracky = {times= {[2]=iron_crac2, [3]=iron_crac3}, uses=iron_use, maxlevel=iron_max_lvl},
		},
		damage_groups = {fleshy = iron_dmg},
	},
	groups = {pickaxe = 1, craftedby = 1},
	sound = {breaks = "tech_tool_breaks"},
})



---------------------------------------
--Recipes

--
--Hand crafts (inv)
--

----craft stone chopper from gravel
crafting.register_recipe({
	type = "crafting_spot",
	output = "tech:stone_chopper 1",
	items = {"nodes_nature:gravel"},
	level = 1,
	always_known = true,
})

----digging stick from sticks
crafting.register_recipe({
	type = "crafting_spot",
	output = "tech:digging_stick 1",
	items = {"tech:stick 2"},
	level = 1,
	always_known = true,
})


--
--Polished Stone
--

--grind adze
crafting.register_recipe({
	type = "grinding_stone",
	output = "tech:adze_granite",
	items = {"group:granite_cobble", 'tech:stick', 'group:fibrous_plant 4', 'nodes_nature:sand'},
	level = 1,
	always_known = true,
})

crafting.register_recipe({
	type = "grinding_stone",
	output = "tech:adze_jade",
	items = {"group:jade_cobble", 'tech:stick', 'group:fibrous_plant 4', 'nodes_nature:sand'},
	level = 1,
	always_known = true,
})

crafting.register_recipe({
	type = "grinding_stone",
	output = "tech:adze_basalt",
	items = {"group:basalt_cobble", 'tech:stick', 'group:fibrous_plant 4', 'nodes_nature:sand'},
	level = 1,
	always_known = true,
})


--grind club
crafting.register_recipe({
	type = "grinding_stone",
	output = "tech:stone_club",
	items = {"group:granite_cobble", 'nodes_nature:sand'},
	level = 1,
	always_known = true,
})




--
--Iron tools
--

--axe
crafting.register_recipe({
	type = "anvil",
	output = "tech:axe_iron",
	items = {'tech:iron_ingot', 'tech:stick'},
	level = 1,
	always_known = true,
})

--shovel
crafting.register_recipe({
	type = "anvil",
	output = "tech:shovel_iron",
	items = {'tech:iron_ingot', 'tech:stick'},
	level = 1,
	always_known = true,
})

--mace
crafting.register_recipe({
	type = "anvil",
	output = "tech:mace_iron",
	items = {'tech:iron_ingot 2'},
	level = 1,
	always_known = true,
})

--pickaxe
crafting.register_recipe({
	type = "anvil",
	output = "tech:pickaxe_iron",
	items = {'tech:iron_ingot 2', 'tech:stick'},
	level = 1,
	always_known = true,
})


--Hammers

--Places hammer
local function place_hammer(itemstack, placer, pointed_thing, placed_name)
    local place_item = ItemStack(placed_name)
    itemstack:take_item(1)
    minetest.item_place_node(place_item, placer, pointed_thing)
    return itemstack
end

-- opens the hammering spot GUI if the hammer is placed on a solid node
local function open_hammering_spot_if_valid(pos, node, clicker, itemstack, pointed_thing)
    local good_on = {{"stone", 1}, {"masonry", 1}, {"boulder", 1}, {"soft_stone", 1}, {"tree", 1}, {"log", 1}}
    local pos_under = {x = pos.x, y = pos.y - 1, z = pos.z}
    local ground = minetest.get_node(pos_under)
    local is_good_for_hammering = false
    for i in ipairs(good_on) do
        local group = good_on[i][1]
        local num = good_on[i][2]
        if minetest.get_item_group(ground.name, group) == num then
            is_good_for_hammering = true
            break
        end
    end
    if is_good_for_hammering then
        open_hammering_spot(pos, node, clicker, itemstack, pointed_thing)
    else
        minetest.chat_send_player(
            clicker:get_player_name(),
            "Can't do hammering here! Needs: stone, masonry, tree, or a log.")
    end
end

-- Granite hammer
minetest.register_tool(
    "tech:hammer_granite", {
        description = S("Granite Hammer"),
        inventory_image = "tech_tool_hammer_granite.png",
        tool_capabilities = {
            full_punch_interval = base_punch_int * 1.2,
            groupcaps={
                choppy = {times={[3]=crude_chop3}, uses=base_use*0.5, maxlevel=crude_max_lvl},
                snappy = {times={[3]=crude_snap3}, uses=base_use*0.5, maxlevel=crude_max_lvl},
                crumbly = {times= {[3]=crude_crum3}, uses=base_use*0.5, maxlevel=crude_max_lvl}
            },
            damage_groups = {fleshy=iron_dmg},
        },
        on_place = function(itemstack, placer, pointed_thing)
            return place_tool(itemstack, placer, pointed_thing, "tech:hammer_granite_placed")
        end,
        groups = {club = 1, craftedby = 1},
        sound = {breaks = "tech_tool_breaks"},
})

crafting.register_recipe({
	type = "grinding_stone",
	output = "tech:hammer_granite",
	items = {"group:granite_cobble", 'tech:stick', 'group:fibrous_plant 4', 'nodes_nature:sand'},
	level = 1,
	always_known = true,
})

minetest.register_node(
    "tech:hammer_granite_placed", {
        description = S("Placed Granite Hammer"),
        drawtype = "mesh",
        mesh = "hammer_placed.obj",
        tiles = {name = "tech_hammer_granite_placed.png"},
        paramtype = "light",
        paramtype2 = "facedir",
        sounds = nodes_nature.node_sound_stone_defaults(),
        groups = {dig_immediate = 3, temp_pass = 1, falling_node = 1, not_in_creative_inventory = 1},
        node_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, -0.45, 0.5},
        },
	selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
        },
        on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
            open_hammering_spot_if_valid(pos, node, clicker, itemstack, pointed_thing)
        end,
        on_dig = function(pos, node, digger)
            on_dig_tool(pos, node, digger, "tech:hammer_granite")
        end,
})

-- Basalt hammer
minetest.register_tool(
    "tech:hammer_basalt", {
        description = S("Basalt Hammer"),
        inventory_image = "tech_tool_hammer_basalt.png",
        tool_capabilities = {
            full_punch_interval = base_punch_int * 1.2,
            groupcaps={
                choppy = {times={[3]=crude_chop3}, uses=base_use*0.5, maxlevel=crude_max_lvl},
                snappy = {times={[3]=crude_snap3}, uses=base_use*0.5, maxlevel=crude_max_lvl},
                crumbly = {times= {[3]=crude_crum3}, uses=base_use*0.5, maxlevel=crude_max_lvl}
            },
            damage_groups = {fleshy=iron_dmg},
        },
        on_place = function(itemstack, placer, pointed_thing)
            return place_tool(itemstack, placer, pointed_thing, "tech:hammer_basalt_placed")
        end,
        groups = {club = 1, craftedby = 1},
        sound = {breaks = "tech_tool_breaks"},
})

crafting.register_recipe({
	type = "grinding_stone",
	output = "tech:hammer_basalt",
	items = {"group:basalt_cobble", 'tech:stick', 'group:fibrous_plant 4', 'nodes_nature:sand'},
	level = 1,
	always_known = true,
})

minetest.register_node(
    "tech:hammer_basalt_placed", {
        description = S("Placed Basalt Hammer"),
        drawtype = "mesh",
        mesh = "hammer_placed.obj",
        tiles = {name = "tech_hammer_basalt_placed.png"},
        paramtype = "light",
        paramtype2 = "facedir",
        sounds = nodes_nature.node_sound_stone_defaults(),
        groups = {dig_immediate = 3, temp_pass = 1, falling_node = 1, not_in_creative_inventory = 1},
	node_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, -0.45, 0.5},
        },
	selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
        },
        on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
            open_hammering_spot_if_valid(pos, node, clicker, itemstack, pointed_thing)
        end,
        on_dig = function(pos, node, digger)
            on_dig_tool(pos, node, digger, "tech:hammer_basalt")
        end,
})

--[[
--would be nice to have,
--but hard to do without either spamming with crafts,
--or having illogical mass balance (e.g. anvil = 1 ingot and axe = 1 ingot)
crafting.register_recipe({
	type = "anvil",
	output = "tech:iron_ingot",
	items = {'group:iron 2'},
	level = 1,
	always_known = true,
})
]]

-- Register knife craft recipies after all modules loaded
minetest.register_on_mods_loaded(function()
	crafting.register_recipe({
		type = "knife",
		output = "tech:stick 2",
		items = {"group:woody_plant"},
		level = 1,
		always_known = true,
	})
	--Bulk sticks from woody plants
	crafting.register_recipe({
		type = "knife",
		output = "tech:stick 24",
		items = {"group:woody_plant 12"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "knife",
		output = "tech:torch 1",
		items = {"tech:stick 1", "group:fibrous_plant 4"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "knife",
		output = "tech:peeled_anperla",
		items = {"nodes_nature:anperla_seed"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "knife",
		output = "tech:small_wood_fire_unlit",
		items = {"tech:stick 6", "group:fibrous_plant 1"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "knife",
		output = "tech:large_wood_fire_unlit",
		items = {"tech:stick 12", "group:fibrous_plant 2"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "knife",
		output = "tech:wattle_loose",
		items = {"tech:stick 3"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "knife",
		output = "tech:wattle",
		items = {"tech:stick 6"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "knife",
		output = "tech:wattle_door_frame",
		items = {"tech:stick 6"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "knife",
		output = "doors:door_wattle",
		items = {"tech:wattle 2", "group:fibrous_plant 2", "tech:stick 2"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "knife",
		output = "tech:trapdoor_wattle",
		items = {"tech:wattle", "group:fibrous_plant", "tech:stick"},
		level = 1,
		always_known = true,
	})
	-- Axe Crafting
	crafting.register_recipe({
		type   = "axe",
		output = "tech:chopping_block",
		items  = {'group:log'},
		level  = 1,
		always_known = true,
		})
	crafting.register_recipe({
		type   = "axe",
		output = "tech:brick_makers_bench",
		items  = {'tech:stick 24'},
		level  = 1,
		always_known = true,
		})
	crafting.register_recipe({
		type   = "axe",
		output = "tech:carpentry_bench",
		items  = {'tech:iron_ingot 4', 'nodes_nature:maraka_log 2'},
		level  = 1,
		always_known = true,
		})
	crafting.register_recipe({
		type = "axe",
		output = "canoe:canoe",
		items = {"group:log 6"},
		level = 1,
		always_known = true,
	})
	--Sticks from woody plants
	crafting.register_recipe({
		type = "axe",
		output = "tech:stick 2",
		items = {"group:woody_plant"},
		level = 1,
		always_known = true,
	})
	--Bulk sticks from woody plants
	crafting.register_recipe({
		type = "axe",
		output = "tech:stick 24",
		items = {"group:woody_plant 12"},
		level = 1,
		always_known = true,
	})
	--sticks from tree
	crafting.register_recipe({
		type = "axe",
		output = "tech:stick 24",
		items = {"group:log"},
		level = 1,
		always_known = true,
	})

	--sticks from log slabs
	crafting.register_recipe({
		type = "axe",
		output = "tech:stick 12",
		items = {"group:woodslab"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "axe",
		output = "tech:large_wood_fire_unlit",
		items = {"tech:stick 12", "group:fibrous_plant 2"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "axe",
		output = "tech:large_wood_fire_unlit 2",
		items = {"group:log", "group:fibrous_plant 4"},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "axe",
		output = "tech:primitive_wooden_chest",
		items = {'group:log 4'},
		level = 1,
		always_known = true,
	})
	crafting.register_recipe({
		type = "axe",
		output = "tech:wooden_water_pot",
		items = {'group:log 2'},
		level = 1,
		always_known = true,
	})
end)


