----------------------------------------------------------
--COOKING POT



----------------------------------------------------------
--[[
Food capacity

Display:
Food %
Cooking progress %

Click with food item to add to pot -> ^food vProgress

Heat to cook

Click with hand to eat -> vFood %


Save to inv meta

]]

-- Import Globals
food_table = food_table
bake_table = bake_table

-- Internationalization
local S = tech.S

local cook_time = 1
local cook_temp = { [""] = 101, ["Soup"] = 100 }
local portions = 10 -- TODO: is this sane? Can we adjust it based on contents?


---------------------
local pot_box = {
	{-0.375, -0.1875, -0.375, 0.375, -0.0625, 0.375}, -- NodeBox1
	{-0.3125, -0.3125, -0.3125, 0.3125, -0.1875, 0.3125}, -- NodeBox2
	{-0.25, -0.4375, -0.25, 0.25, -0.3125, 0.25}, -- NodeBox3
	{-0.3125, -0.0625, -0.3125, 0.3125, 0, 0.3125}, -- NodeBox4
	{-0.25, 0, -0.25, 0.25, 0.0625, 0.25}, -- NodeBox5
	{-0.125, 0.0625, -0.0625, -0.0625, 0.1875, 0.0625}, -- NodeBox6
	{0.0625, 0.0625, -0.0625, 0.125, 0.1875, 0.0625}, -- NodeBox7
	{-0.0625, 0.125, -0.0625, 0.0625, 0.1875, 0.0625}, -- NodeBox8
	{0.25, -0.4375, 0.25, 0.375, -0.3125, 0.375}, -- NodeBox9
	{0.25, -0.5, 0.25, 0.4375, -0.4375, 0.4375}, -- NodeBox10
	{0.25, -0.5, -0.4375, 0.4375, -0.4375, -0.25}, -- NodeBox11
	{-0.4375, -0.5, -0.4375, -0.25, -0.4375, -0.25}, -- NodeBox12
	{-0.4375, -0.5, 0.25, -0.25, -0.4375, 0.4375}, -- NodeBox13
	{0.25, -0.4375, -0.375, 0.375, -0.3125, -0.25}, -- NodeBox14
	{-0.375, -0.4375, -0.375, -0.25, -0.3125, -0.25}, -- NodeBox15
	{-0.375, -0.4375, 0.25, -0.25, -0.3125, 0.375}, -- NodeBox16
	{-0.4375, -0.0625, -0.0625, -0.3125, 0.0625, 0.0625}, -- NodeBox23
	{0.3125, -0.0625, -0.0625, 0.4375, 0.0625, 0.0625}, -- NodeBox24
}

local pot_formspec = "size[8,4.1]"..
   "list[current_name;main;0,0;8,2]"..
   "list[current_player;main;0,2.3;8,4]"..
   "listring[current_name;main]"..
   "listring[current_player;main]"

minetest.register_craftitem("tech:soup", {
	description = S("Soup"),
	inventory_image = "tech_soup.png",
	stack_max = minimal.stack_max_medium,
	on_use = function(itemstack, user, pointed_thing)
	   return exile_eatdrink_playermade(itemstack, user, pointed_thing)
	end
})

local function clear_pot(pos)
   local meta = minetest.get_meta(pos)
   minimal.infotext_set(pos,meta,
     "Status: Unprepared pot\nContents: <EMPTY>\nNote: Add water to pot to make soup")
   meta:set_string("formspec", "")
   meta:set_string("type", "")
   meta:set_string("status", "") -- "" = unprepared, "Cooking", "Finished"
   local inv = meta:get_inventory()
   inv:set_size("main", 8)
end

local function pot_rightclick(pos, node, clicker, itemstack, pointed_thing)
   local meta = minetest.get_meta(pos)
   local itemname = itemstack:get_name()
   local status = meta:get_string("status")
   if status == "" then  -- unprepared pot
      local liquid = liquid_store.contents(itemname)
      if liquid == "nodes_nature:freshwater_source" then
	 meta:set_string("type", "Soup")
	 minimal.infotext_set(pos,meta,
		"Status: Soup Pot\nContents: Water\n"
		.."Note: Add food to the pot to make soup")
	 meta:set_string("formspec", pot_formspec)
	 meta:set_int("baking", cook_time)
	 minetest.get_node_timer(pos):start(6)
	 if itemname ~= liquid then -- it's stored in a container
	    return liquid_store.drain_store(clicker, itemstack)
	 else
	    itemstack:take_item()
	 end
      end
      return itemstack
-- XXX Was going to add ability to take water out of a prepared pot but more complicated
-- then expected will try again later
--   elseif ptype == "Soup" then -- Pot has water, but not cooking

   end
   --TODO: use oil for fried food, saltwater for salted food (to preserve it)
end

local function pot_receive_fields(pos, formname, fields, sender)
   local meta = minetest.get_meta(pos)
   local inv = meta:get_inventory():get_list("main")
   local total = { 0, 0, 0, 0, 0 }
   if meta:get_string("status") == "finished" then -- reset the pot for next cook
      if meta:get_inventory():is_empty("main") then
	 clear_pot(pos)
      end
      return
   end
   local contents="" -- String containing list of pot contents
   if meta:get_string('type') == 'Soup' then
	   contents="Water, "
   end
   for i = 1, #inv do
      local fname = inv[i]:get_name()
      if fname ~= '' then
	      local fcount = inv[i]:get_count()
	      local fdesc = minetest.registered_nodes[fname].description
	      contents=contents..' '..fdesc..' ('..fcount..'), '
      end
      if food_table[fname] or food_table[fname.."_cooked"] then
	 local result = food_table[fname.."_cooked"]
	 if result == nil then -- prefer the cooked version, use raw if none
	    result = food_table[fname]
	 end
	 if result then
	    local count = inv[i]:get_count()
	    for j = 1, 5 do
	       total[j] = total[j] + result[j] * count
	    end
	 end
      end
   end
   contents=contents:sub(1, #contents - 2) -- take last ', ' from contents
   minimal.infotext_merge(pos, {
	   "Contents: "..contents,
	   "Note:",   -- Clear note about adding food
   }, meta)

   local length = meta:get_int("baking")
   if length <= (cook_time - 4) then
      length = length + 4 -- don't open a cooking pot, you'll let the heat out
      --TODO: Can we drain current temp while the formspec's open? Groups?
      meta:set_int("baking", length)
   end
   meta:set_string("pot_contents", minetest.serialize(total))
end

local function divide_portions(total)
   local result = total
   for i = 1, #total do
      result[i] = math.floor(total[i] / portions)
   end
   return result
end

local function pot_cook(pos, elapsed)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory():get_list("main")
	local total = ( minetest.deserialize(meta:get_string("pot_contents")) or
		      { 0, 0, 0, 0 } )
	local kind = meta:get_string("type")
	climate.heat_transfer(pos, "tech:cooking_pot")
	local temp = climate.get_point_temp(pos)
	local baking = meta:get_int("baking")
	local status = meta:get_string("status")
	if status == "finished" then
		-- Handle burning food here
	    --TODO: burned: reduce th value of pot_contents, emit more smoke
	else 
		if kind == "Soup" then -- or kind == "etc"; this only runs if we're cooking
		      if baking <= 0 then
			 local firstingr = inv[1]:get_description()
			 if firstingr then
			    firstingr = firstingr:gsub(" %(uncooked%)","")
			    firstingr = firstingr:gsub("Unbaked ","")
			    firstingr = firstingr:gsub(" Carcass","")
			    firstingr = firstingr.." "
			 end
			 for i = 1, #inv do
			    inv[i]:clear()
			 end
			 inv[1]:replace(ItemStack("tech:soup "..portions))
			 local imeta = inv[1]:get_meta()
			 local portion = divide_portions(total)
			 portion[2] = portion[2] + (100 / portions)
			 imeta:set_string("eat_value", minetest.serialize(portion))
			 imeta:set_string("description", S("@1 soup",firstingr))
			 meta:get_inventory(pos):set_list("main", inv)
			 minimal.infotext_merge(pos, {
				"Contents: "..S("@1 soup",firstingr),
				"Status: "..kind.." pot (finished)"
			}, meta)
			 meta:set_string("status", "finished")
			 return
		      elseif temp < cook_temp[kind] then
			      if status ~= 'cooling' then
				      meta:set_string("status", "cooling")
				      minimal.infotext_merge(pos, 'Status: '..kind.." pot", meta)
			      end
			      return
		      elseif temp >= cook_temp[kind] then
			 if meta:get_inventory():is_empty("main") then
			    return
			 end
			 if status ~= 'cooking' then
				 meta:set_string('status', 'cooking')
				 minimal.infotext_merge(pos, "Status: "..kind.." pot (cooking)", meta)
			 end
			 meta:set_int("baking", baking - 1)
		      end
		end -- Soup
	end -- status == finished
end

local function calc_baking_time(stack)
   local fname = stack:get_name()
   if not food_table[fname] then return 0 end -- removing finished, etc
   local time -- #TODO: Check if we're adding to a stack, don't alter
   if bake_table[fname] then
      time = bake_table[fname][2] -- using baking time
   elseif fname:gsub("_cooked","") ~= fname then
      time = 1 -- this is already cooked
   else -- use half of nutrition unit value
      time = 1 + math.floor(food_table[fname][3] / 2)
   end
   return time
end

minetest.register_node("tech:cooking_pot", {
	description = S("Cooking Pot"),
	tiles = {"tech_pottery.png",
	"tech_pottery.png",
	"tech_pottery.png",
	"tech_pottery.png",
	"tech_pottery.png"},
	drawtype = "nodebox",
	stack_max = minimal.stack_max_bulky,
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = pot_box,
	},
	groups = {dig_immediate = 3, pottery = 1},
	sounds = nodes_nature.node_sound_stone_defaults(),
	on_construct = function(pos)
	   clear_pot(pos)
	end,
	on_rightclick = function(...)
	   return pot_rightclick(...)
	end,
	on_dig = function(pos, node, digger)
	   local meta = minetest.get_meta(pos)
	   local inv = meta:get_inventory()
	   local ptype = meta:get_string("type")
	   if ( not inv:is_empty("main") 
	      or ptype ~= "") then -- type is empty on uprepared pot
	      return false
	   end
	   minetest.node_dig(pos, node, digger)
	end,
	on_receive_fields = function(...)
	   pot_receive_fields(...)
	end,
	on_timer = function(pos, elapsed)
	   pot_cook(pos, elapsed)
	   return true
	end,
	allow_metadata_inventory_put = function(
	      pos, listname, index, stack, player)
	   local fname = stack:get_name()
	   if not food_table[fname] and not bake_table[fname] then
	      return 0
	   end
	   local meta = minetest.get_meta(pos)
	   if meta:get_string("status") == "finished" then
		--prevent adding items after cooking is complete
		return 0
	   end
	   local inv = meta:get_inventory():get_list(listname)
	   local count = stack:get_count()
	   --if we put new items in during cook, extend "baking" time further
	   meta:set_int("baking", meta:get_int("baking")
			+ calc_baking_time(stack))
	   for i = 1, #inv do
	      -- Only allow one stack of a given item
	      if not (i == index) and inv[i]:get_name() == stack:get_name() then
		 return 0
	      end
	   end
	   return count
	end,
	allow_metadata_inventory_take = function(
	      pos, listname, index, stack, player)
	   local meta = minetest.get_meta(pos)
	   local status = meta:get_string("status")
	   --prevent removing items once cooking begins
	   if status ~= "" and status ~= "finished" then -- "" means cooking never started.
		return 0
	   end
	   meta:set_int("baking", meta:get_int("baking")
			- calc_baking_time(stack))
	   return stack:get_count()
	end,
})

minetest.register_node("tech:cooking_pot_unfired", {
	description = S("Cooking Pot (unfired)"),
	tiles = {"nodes_nature_clay.png",
		 "nodes_nature_clay.png",
		 "nodes_nature_clay.png",
		 "nodes_nature_clay.png",
		 "nodes_nature_clay.png",
		 "nodes_nature_clay.png"},
	drawtype = "nodebox",
	stack_max = minimal.stack_max_bulky,
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = pot_box,
	},
	groups = {dig_immediate=3, temp_pass = 1, falling_node = 1, heatable = 20},
	sounds = nodes_nature.node_sound_stone_defaults(),
	on_construct = function(pos)
	   ncrafting.set_firing(pos, ncrafting.base_firing, ncrafting.firing_int)
	end,
	on_timer = function(pos, elapsed)
		--finished product, length
		return ncrafting.fire_pottery(pos, "tech:cooking_pot_unfired", "tech:cooking_pot", ncrafting.base_firing)
	end,

})

crafting.register_recipe({
	type = {"crafting_spot","hand_pottery"},
	output = "tech:cooking_pot_unfired 1",
	items = {"nodes_nature:clay_wet 4"},
	level = 1,
	always_known = true,
})
crafting.register_recipe({
	type = {"mixing_spot","hand_pottery"},
	output = "nodes_nature:clay 4",
	items = {"tech:clay_water_pot_unfired 1"},
	level = 1,
	always_known = true,
})

