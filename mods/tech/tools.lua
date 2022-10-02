
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



---------------------------------------
--Tools


--------------------------
--1st level
--Crude emergency tools

local crude = 0.8
--local crude_use = base_use
local crude_max_lvl = minimal.hand_max_lvl

--damage
local crude_dmg = minimal.hand_dmg * 2
--snappy
local crude_snap3 = minimal.hand_snap * crude
local crude_snap2 = (minimal.hand_snap * minimal.t_scale2) * crude
local crude_snap1 = (minimal.hand_snap * minimal.t_scale1) * crude
local crude_snap0 = 100 -- really long dig time - effectively disabled
--crumbly
local crude_crum3 = minimal.hand_crum * crude
local crude_crum2 = (minimal.hand_crum * minimal.t_scale2) * crude
local crude_crum1 = (minimal.hand_crum * minimal.t_scale1) * crude
local crude_crum0 = 100 -- really long dig time - effectively disabled
--choppy
local crude_chop3 = minimal.hand_chop * crude
local crude_chop2 = (minimal.hand_chop * minimal.t_scale2) * crude
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
		max_drop_level = crude_max_lvl,
		groupcaps={
			choppy = {times={[3]=crude_chop0}, uses=base_use*0.75, maxlevel=crude_max_lvl},
			snappy= {times={[1]=crude_snap1, [2]=crude_snap2, [3]=crude_snap3}, uses=base_use, maxlevel=crude_max_lvl},
			crumbly = {times={[3]=crude_crum0}, uses=base_use*0.5, maxlevel=crude_max_lvl}
		},
		damage_groups = {fleshy= crude_dmg},
	},
	--groups = {},
	sound = {breaks = "tech_tool_breaks"},
})



--
-- Crumbly
--

-- digging stick... specialist for digging. Can also till
minetest.register_tool("tech:digging_stick", {
	description = S("Digging Stick"),
	inventory_image = "tech_tool_digging_stick.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = base_punch_int*1.1,
		max_drop_level = crude_max_lvl,
		groupcaps={
			crumbly = {times= {[1]=crude_crum1, [2]=crude_crum2, [3]=crude_crum3}, uses=base_use, maxlevel=crude_max_lvl}
		},
		damage_groups = {fleshy= crude_dmg},
	},
	--groups = {flammable = 1},
	sound = {breaks = "tech_tool_breaks"},
	on_place = function(itemstack, placer, pointed_thing)
		return till_soil(itemstack, placer, pointed_thing, base_use)
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
local stone_max_lvl = crude_max_lvl

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
		max_drop_level = stone_max_lvl,
		groupcaps={
			choppy = {times={[2]=stone_chop2, [3]=stone_chop3}, uses=stone_use, maxlevel=stone_max_lvl},
			snappy={times={[1]=stone_snap1, [2]=stone_snap2, [3]=stone_snap3}, uses=stone_use *0.8, maxlevel=stone_max_lvl},
			crumbly = {times={[3]=crude_crum3}, uses=base_use, maxlevel=crude_max_lvl},
		},
		damage_groups = {fleshy = stone_dmg},
	},
	groups = {axe = 1},
	sound = {breaks = "tech_tool_breaks"},
})

--less uses than granite bc softer stone
minetest.register_tool("tech:adze_basalt", {
	description = S("Basalt Adze"),
	inventory_image = "tech_tool_adze_basalt.png",
	tool_capabilities = {
		full_punch_interval = base_punch_int * 1.1,
		max_drop_level = stone_max_lvl,
		groupcaps={
			choppy = {times={[2]=stone_chop2, [3]=stone_chop3}, uses=stone_use *0.9, maxlevel=stone_max_lvl},
			snappy= {times={[1]=stone_snap1, [2]=stone_snap2, [3]=stone_snap3}, uses=stone_use *0.7, maxlevel=stone_max_lvl},
			crumbly = {times={[3]=crude_crum3}, uses=base_use*0.9, maxlevel=crude_max_lvl},
		},
		damage_groups = {fleshy = stone_dmg},
	},
	groups = {axe = 1},
	sound = {breaks = "tech_tool_breaks"},
})


--many more uses than granite.
minetest.register_tool("tech:adze_jade", {
	description = S("Jade Adze"),
	inventory_image = "tech_tool_adze_jade.png",
	tool_capabilities = {
		full_punch_interval = base_punch_int * 1.1,
		max_drop_level = stone_max_lvl,
		groupcaps={
			choppy = {times={[2]=stone_chop2, [3]=stone_chop3}, uses=stone_use * 1.5, maxlevel=stone_max_lvl},
			snappy={times={[1]=stone_snap1, [2]=stone_snap2, [3]=stone_snap3}, uses=stone_use, maxlevel=stone_max_lvl},
			crumbly = {times={[3]=crude_crum3}, uses=base_use, maxlevel=crude_max_lvl},
		},
		damage_groups = {fleshy = stone_dmg},
	},
	groups = {axe = 1},
	sound = {breaks = "tech_tool_breaks"},
})


--stone club. A weapon. Not very good for anything else
--can stun catch animals
minetest.register_tool("tech:stone_club", {
	description = S("Stone Club"),
	inventory_image = "tech_tool_stone_club.png",
	tool_capabilities = {
		full_punch_interval = base_punch_int * 1.2,
		max_drop_level = stone_max_lvl,
		groupcaps={
			choppy = {times={[3]=crude_chop3}, uses=base_use*0.5, maxlevel=crude_max_lvl},
			snappy = {times={[3]=crude_snap3}, uses=base_use*0.5, maxlevel=crude_max_lvl},
			crumbly = {times= {[3]=crude_crum3}, uses=base_use*0.5, maxlevel=crude_max_lvl}
		},
		damage_groups = {fleshy=stone_dmg*2},
	},
	groups = {club = 1},
	sound = {breaks = "tech_tool_breaks"},
})




--------------------------
--3rd level
--iron tools.



local iron = 0.9
local iron_use = base_use * 4
local iron_max_lvl = crude_max_lvl + 1

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
		max_drop_level = iron_max_lvl,
		groupcaps={
			choppy = {times={[1]=iron_chop1, [2]=iron_chop2, [3]=iron_chop3}, uses=iron_use, maxlevel=iron_max_lvl},
			snappy = {times={[1]=iron_snap1, [2]=iron_snap2, [3]=iron_snap3}, uses=iron_use, maxlevel=iron_max_lvl},
			crumbly = {times={[3]=crude_crum3}, uses= stone_use, maxlevel=stone_max_lvl},
		},
		damage_groups = {fleshy = iron_dmg},
	},
	groups = {axe = 1},
	sound = {breaks = "tech_tool_breaks"},
})


-- shovel... best for digging. Can also till
minetest.register_tool("tech:shovel_iron", {
	description = S("Iron Shovel"),
	inventory_image = "tech_tool_shovel_iron.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = base_punch_int*1.1,
		max_drop_level = iron_max_lvl,
		groupcaps={
			crumbly = {times= {[1]=iron_crum1, [2]=iron_crum2, [3]=iron_crum3}, uses=iron_use, maxlevel=iron_max_lvl},
			snappy = {times= {[3]=stone_snap3}, uses=iron_use *0.8, maxlevel=iron_max_lvl},
		},
		damage_groups = {fleshy= iron_dmg},
	},
	--groups = {flammable = 1},
	sound = {breaks = "tech_tool_breaks"},
	on_place = function(itemstack, placer, pointed_thing)
		return till_soil(itemstack, placer, pointed_thing, iron_use)
	end
})


--Mace.  A weapon. Not very good for anything else
--can stun catch animals
minetest.register_tool("tech:mace_iron", {
	description = S("Iron Mace"),
	inventory_image = "tech_tool_mace_iron.png",
	tool_capabilities = {
		full_punch_interval = base_punch_int * 1.2,
		max_drop_level = iron_max_lvl,
		groupcaps={
			choppy = {times={[3]=crude_chop3}, uses=base_use*0.5, maxlevel=crude_max_lvl},
			snappy = {times={[3]=crude_snap3}, uses=base_use*0.5, maxlevel=crude_max_lvl},
			crumbly = {times= {[3]=crude_crum3}, uses=base_use*0.5, maxlevel=crude_max_lvl},
		},
		damage_groups = {fleshy=iron_dmg*2},
	},
	groups = {club = 1},
	sound = {breaks = "tech_tool_breaks"},
})


--Pick Axe. mining, digging
minetest.register_tool("tech:pickaxe_iron", {
	description = S("Iron Pickaxe"),
	inventory_image = "tech_tool_pickaxe_iron.png",
	tool_capabilities = {
		full_punch_interval = base_punch_int * 1.1,
		max_drop_level = iron_max_lvl,
		groupcaps={
			choppy = {times={[3]=stone_chop3}, uses=iron_use *0.8, maxlevel=iron_max_lvl},
			snappy = {times={[3]=stone_snap3}, uses=iron_use *0.8, maxlevel=iron_max_lvl},
			crumbly = {times={[2]=stone_crum2, [3]=stone_crum3}, uses= iron_use, maxlevel=iron_max_lvl},
			cracky = {times= {[2]=iron_crac2, [3]=iron_crac3}, uses=iron_use, maxlevel=iron_max_lvl},
		},
		damage_groups = {fleshy = iron_dmg},
	},
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
