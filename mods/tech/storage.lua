---------------------------------------------------
--Storage
--e.g. for chests, pots etc

-- Internationalization
local S = tech.S

---------------------------------------------------
local function get_storage_formspec(pos, w, h, meta)
print('-------------tech:storage:get_storage_formspec-----------------')
	local creator = meta:get_string('creator')
	local label = meta:get_string('label')
	minimal.infotext_merge(pos, 'Label: '..label, meta)
	local formspec_size_h = 3.85 + h
	local main_offset = 0.25 + h 
	local trash_offset = 0.45 + h + 2
	local label_offset = trash_offset + .35
	local creator_offset_x =  (3*(30-string.len(creator))/30/2) + 5
	local craftedby_offset_x = 6.05 -- 3*(30-string.len('crafted by'))/30/2 + 5

	local formspec = {
		"size[8,"..formspec_size_h.."]",
		"list[current_name;main;0,0;"..w..","..h.."]",
		"list[current_player;main;0,"..main_offset..";8,2]",
		"listring[current_name;main]",
		"listring[current_player;main]",
		"list[detached:creative_trash;main;0,"..trash_offset..";1,1;]",
		"image[0.05,"..(trash_offset+.10)..
		   ";0.8,0.8;creative_trash_icon.png]",
		"field[1.5,"..label_offset..";4,1;label;Label:;"..label.."]",
		"field_close_on_enter[label;false]",
		"label["..craftedby_offset_x..","..trash_offset..";Crafted by:]",
		"label["..creator_offset_x..","..(trash_offset+.35)..";"..creator.."]",
	}
	return table.concat(formspec, "")
end


local function is_owner(pos, name)
	local owner = minetest.get_meta(pos):get_string("owner")
	if owner == "" or owner == name or minetest.check_player_privs(name, "protection_bypass") then
		return true
	end
	return false
end




local on_construct = function(pos, width, height)
print("----------------Storage:on_construct-------------------")
	local meta = minetest.get_meta(pos)

	local form = get_storage_formspec(pos, width, height, meta)
	meta:set_string("formspec", form)

	local inv = meta:get_inventory()
	inv:set_size("main", width*height)

print(dump(meta:to_table()))
end

local on_receive_fields = function(pos, formname, fields, sender, width, height)
		local label = fields.label
		if label and label ~= '' then
			local meta = minetest.get_meta(pos)
			meta:set_string('label', label)
			minimal.infotext_merge(pos,'Label: '..label, meta)
			on_construct(pos, width, height)
		end
end


----------------------------------------------------
--Clay pot (see pottery for unfired version)
minetest.register_node("tech:clay_storage_pot", {
	description = S("Clay Storage Pot"),
	tiles = {"tech_pottery.png",
	"tech_pottery.png",
	"tech_pottery.png",
	"tech_pottery.png",
	"tech_pottery.png"},
	drawtype = "nodebox",
	stack_max = minimal.stack_max_bulky,
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
				{-0.375, -0.5, -0.375, 0.375, -0.375, 0.375},
				{-0.375, 0.375, -0.375, 0.375, 0.5, 0.375},
				{-0.4375, -0.375, -0.4375, 0.4375, -0.25, 0.4375},
				{-0.4375, 0.25, -0.4375, 0.4375, 0.375, 0.4375},
				{-0.5, -0.25, -0.5, 0.5, 0.25, 0.5},
			}
		},
	groups = {dig_immediate = 3, pottery = 1},
	sounds = nodes_nature.node_sound_stone_defaults(),

	on_construct = function(pos)
		on_construct(pos, 8, 4)
	end,

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		--Update formspec and infotext
		on_construct(pos, 8, 4)
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		on_receive_field(pos,formname,fields, sender, 8, 4)
	end,

	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		local name = ""
		if player then
			name = player:get_player_name()
		end
		return is_owner(pos, name) and inv:is_empty("main")
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if is_owner(pos, player:get_player_name()) then
			return count
		end
		return 0
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if is_owner(pos, player:get_player_name())
		and not string.match(stack:get_name(), "backpacks:") then
			return stack:get_count()
		end
		return 0
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if is_owner(pos, player:get_player_name()) then
			return stack:get_count()
		end
		return 0
	end,

	on_blast = function(pos)
	end,
})



----------------------------------------------------
--primitive wooden chest
minetest.register_node("tech:primitive_wooden_chest", {
	description = S("Primitive Wooden Chest"),
	tiles = {"tech_primitive_wood.png"},
	drawtype = "nodebox",
	stack_max = minimal.stack_max_bulky,
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
				{-0.375, -0.5, -0.375, 0.375, -0.375, 0.375},
				{-0.375, 0.375, -0.375, 0.375, 0.5, 0.375},
				{-0.4375, -0.375, -0.4375, 0.4375, -0.25, 0.4375},
				{-0.4375, 0.25, -0.4375, 0.4375, 0.375, 0.4375},
				{-0.5, -0.25, -0.5, 0.5, 0.25, 0.5},
			}
		},
	groups = {dig_immediate = 3},
	sounds = nodes_nature.node_sound_wood_defaults(),

	on_construct = function(pos)
		on_construct(pos, 8, 4)
	end,

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		--Update formspec and infotext
		on_construct(pos, 8, 4)
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		on_receive_fields(pos, formname, fields, sender, 8, 4)
	end,

	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		local name = ""
		if player then
			name = player:get_player_name()
		end
		return is_owner(pos, name) and inv:is_empty("main")
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if is_owner(pos, player:get_player_name()) then
			return count
		end
		return 0
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if is_owner(pos, player:get_player_name())
		and not string.match(stack:get_name(), "backpacks:") then
			return stack:get_count()
		end
		return 0
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if is_owner(pos, player:get_player_name()) then
			return stack:get_count()
		end
		return 0
	end,

	on_blast = function(pos)
	end,
})

----------------------------------------------------
--wicker basket
minetest.register_node("tech:wicker_storage_basket", {
	description = S("Wicker Storage Basket"),
	tiles = {"tech_wicker.png"},
	drawtype = "nodebox",
	stack_max = minimal.stack_max_bulky,
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
				{-0.375, -0.5, -0.375, 0.375, -0.375, 0.375},
				{-0.375, 0.375, -0.375, 0.375, 0.5, 0.375},
				{-0.4375, -0.375, -0.4375, 0.4375, -0.25, 0.4375},
				{-0.4375, 0.25, -0.4375, 0.4375, 0.375, 0.4375},
				{-0.5, -0.25, -0.5, 0.5, 0.25, 0.5},
			}
		},
	groups = {dig_immediate = 3},
	sounds = nodes_nature.node_sound_leaves_defaults(),

	on_construct = function(pos)
		on_construct(pos, 8, 4)
	end,

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		--Update formspec and infotext
		on_construct(pos, 8, 4)
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		on_receive_fields(pos, formname, fields, sender, 8, 4)
	end,

	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		local name = ""
		if player then
			name = player:get_player_name()
		end
		return is_owner(pos, name) and inv:is_empty("main")
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if is_owner(pos, player:get_player_name()) then
			return count
		end
		return 0
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if is_owner(pos, player:get_player_name())
		and not string.match(stack:get_name(), "backpacks:") then
			return stack:get_count()
		end
		return 0
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if is_owner(pos, player:get_player_name()) then
			return stack:get_count()
		end
		return 0
	end,

	on_blast = function(pos)
	end,
})

----------------------------------------------------
--woven basket
minetest.register_node("tech:woven_storage_basket", {
	description = S("Woven Storage Basket"),
	tiles = {"tech_woven.png"},
	drawtype = "nodebox",
	stack_max = minimal.stack_max_bulky,
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
				{-0.375, -0.5, -0.375, 0.375, -0.375, 0.375},
				{-0.375, 0.375, -0.375, 0.375, 0.5, 0.375},
				{-0.4375, -0.375, -0.4375, 0.4375, -0.25, 0.4375},
				{-0.4375, 0.25, -0.4375, 0.4375, 0.375, 0.4375},
				{-0.5, -0.25, -0.5, 0.5, 0.25, 0.5},
			}
		},
	groups = {dig_immediate = 3},
	sounds = nodes_nature.node_sound_leaves_defaults(),

	on_construct = function(pos)
		on_construct(pos, 8, 4)
	end,

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		--Update formspec and infotext
		on_construct(pos, 8, 4)
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		on_receive_fields(pos, formname, fields, sender, 8, 4)
	end,

	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		local name = ""
		if player then
			name = player:get_player_name()
		end
		return is_owner(pos, name) and inv:is_empty("main")
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if is_owner(pos, player:get_player_name()) then
			return count
		end
		return 0
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if is_owner(pos, player:get_player_name())
		and not string.match(stack:get_name(), "backpacks:") then
			return stack:get_count()
		end
		return 0
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if is_owner(pos, player:get_player_name()) then
			return stack:get_count()
		end
		return 0
	end,

	on_blast = function(pos)
	end,
})

----------------------------------------------------
--Wooden chest
minetest.register_node("tech:wooden_chest", {
	description = S("Wooden Chest"),
	tiles = {"tech_wooden_chest_top.png",
			"tech_wooden_chest_bottom.png",
			"tech_wooden_chest_side.png",
			"tech_wooden_chest_side.png",
			"tech_wooden_chest_back.png",
			"tech_wooden_chest_front.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	use_texture_alpha = "clip",
	stack_max = minimal.stack_max_bulky,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.375, -0.375, 0.4375, 0.375, 0.375}, -- NodeBox1
			{-0.5, 0.375, -0.4375, 0.5, 0.5, 0.4375}, -- NodeBox2
			{0.3125, -0.5, -0.4375, 0.5, -0.375, -0.25}, -- NodeBox3
			{0.3125, -0.5, 0.25, 0.5, -0.375, 0.4375}, -- NodeBox4
			{-0.5, -0.5, 0.25, -0.3125, -0.375, 0.4375}, -- NodeBox5
			{-0.5, -0.5, -0.4375, -0.3125, -0.375, -0.25}, -- NodeBox6
			{0.1875, 0.25, 0.375, 0.3125, 0.375, 0.4375}, -- NodeBox8
			{-0.3125, 0.25, 0.375, -0.1875, 0.375, 0.4375}, -- NodeBox9
			{-0.0625, 0.25, -0.4375, 0.0625, 0.375, -0.375}, -- NodeBox10
		}
	},
	groups = {dig_immediate = 3},
	sounds = nodes_nature.node_sound_wood_defaults(),

	on_construct = function(pos)
		on_construct(pos, 8, 8)
	end,

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		--Update formspec and infotext
		on_construct(pos, 8, 8)
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		on_receive_fields(pos, formname, fields, sender, 8, 8)
	end,

	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		local name = ""
		if player then
			name = player:get_player_name()
		end
		return is_owner(pos, name) and inv:is_empty("main")
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if is_owner(pos, player:get_player_name()) then
			return count
		end
		return 0
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if is_owner(pos, player:get_player_name())
		and not string.match(stack:get_name(), "backpacks:") then
			return stack:get_count()
		end
		return 0
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if is_owner(pos, player:get_player_name()) then
			return stack:get_count()
		end
		return 0
	end,

	on_blast = function(pos)
	end,
})

--iron chest
minetest.register_node("tech:iron_chest", {
	description = S("Iron Chest"),
	tiles = {"tech_iron_chest_top.png",
			"tech_iron_chest_bottom.png",
			"tech_iron_chest_side.png",
			"tech_iron_chest_side.png",
			"tech_iron_chest_back.png",
			"tech_iron_chest_front.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	use_texture_alpha = "clip",
	protected = true,
	stack_max = minimal.stack_max_bulky,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.375, -0.375, 0.4375, 0.375, 0.375}, -- NodeBox1
			{-0.5, 0.375, -0.4375, 0.5, 0.5, 0.4375}, -- NodeBox2
			{0.3125, -0.5, -0.4375, 0.5, -0.375, -0.25}, -- NodeBox3
			{0.3125, -0.5, 0.25, 0.5, -0.375, 0.4375}, -- NodeBox4
			{-0.5, -0.5, 0.25, -0.3125, -0.375, 0.4375}, -- NodeBox5
			{-0.5, -0.5, -0.4375, -0.3125, -0.375, -0.25}, -- NodeBox6
			{0.1875, 0.25, 0.375, 0.3125, 0.375, 0.4375}, -- NodeBox8
			{-0.3125, 0.25, 0.375, -0.1875, 0.375, 0.4375}, -- NodeBox9
			{-0.0625, 0.25, -0.4375, 0.0625, 0.375, -0.375}, -- NodeBox10
		}
	},
	groups = {dig_immediate = 3},
	sounds = nodes_nature.node_sound_wood_defaults(),

	on_construct = function(pos)
		on_construct(pos, 8, 8)
	end,

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		--Update formspec and infotext
		on_construct(pos, 8, 8)
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		on_receive_fields(pos, formname, fields, sender, 8, 8)
	end,

	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		local name = ""
		if player then
			name = player:get_player_name()
		end
		return is_owner(pos, name) and inv:is_empty("main")
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if is_owner(pos, player:get_player_name()) then
			return count
		end
		return 0
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if is_owner(pos, player:get_player_name())
		and not string.match(stack:get_name(), "backpacks:") then
			return stack:get_count()
		end
		return 0
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if is_owner(pos, player:get_player_name()) then
			return stack:get_count()
		end
		return 0
	end,

	on_blast = function(pos)
	end,
})
