backpacks = {}

-- Internationalization
local S = minetest.get_translator("backpacks")

local function get_formspec(pos, w, h)
	local meta = minetest.get_meta(pos)
	local creator = meta:get_string('creator')
	local label = meta:get_string('label')

	local formspec_size_h = 3.85 + h
	local main_offset = 1.85 + h
	local label_offset = 0.85 + h
	local creator_offset_x =  (3*(30-string.len(creator))/30/2) + 5
	local craftedby_offset_x = 6.05 -- 3*(30-string.len('crafted by'))/30/2 + 5

	local formspec = {
		"size[8,"..formspec_size_h.."]",
		"list[current_name;main;0,0.3;"..w..","..h.."]",
		"field[0.5,"..label_offset..";5,1;label;Label:;"..label.."]",
		"field_close_on_enter[label;false]",
		"label["..craftedby_offset_x..","..(label_offset-.35)..";Crafted by:]",
		"label["..creator_offset_x..","..label_offset..";"..creator.."]",
		"list[current_player;main;0,"..main_offset..";8,2]",
		"listring[current_name;main]",
		"listring[current_player;main]",
	}
	minimal.infotext_merge(pos,'Label: '..label, meta)
	return table.concat(formspec, "")
end

function get_description(node,meta)
	local desc = minetest.registered_nodes[node.name].description
	local label = meta:get_string('label')
	if label ~= '' then
		desc = desc.." - "..label
	end
	return desc
end

local on_construct = function(pos, width, height)
	local meta = minetest.get_meta(pos)
	local form = get_formspec(pos, width, height)
	meta:set_string("formspec", form)
	local inv = meta:get_inventory()
	inv:set_size("main", width*height)
end

local after_place_node = function(pos, placer, itemstack, pointed_thing)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local imeta = itemstack:get_meta()

	-- Load inventory
	local inv_main = imeta:get_string('inv_main')
	local inv=meta:get_inventory()
	-- compatability for worlds created earlier then v0.3.9
	-- minetest.get_metadata() depricated but old maps used it
	-- causes contents of backpacks stored in inventory to be forgotton
	local stuff = minetest.deserialize(itemstack:get_metadata())
	if stuff then
		local depricated_inventory = stuff.inventory.main 
		-- old data in get_metadata(), recover inventory

print('STUFF: '..dump(depricated_inventory))
	-- inv_main shouldn't contain anything
	inv_main = minetest.serialize(depricated_inventory)
	end

print ('INV_MAIN: '..inv_main)
	if inv_main then
		inv:set_list('main',minetest.deserialize(inv_main))
	end
	-- set color
	if minetest.is_player(placer) == true then
	   local face = { x = 0, y = 0, z = 1}
	   local axis = { x = 0, y = 1, z = 0}
	   local ldir = placer:get_look_horizontal()
	   ldir = vector.rotate_around_axis(face, axis, ldir)
	   local ndir = minetest.dir_to_wallmounted(ldir)
	   local color = minetest.strip_param2_color(node.param2,
						     "colorwallmounted")
	   node.param2 = color + ndir
	   minetest.swap_node(pos, node)
	end
	itemstack:take_item()
end

local preserve_metadata = function(pos, oldnode, oldmeta, drops,width,height)
	local item = drops[1]
	local imeta = item:get_meta()
	-- Transfer inventory to item
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local list = {}
	for i, stack in ipairs(inv:get_list("main")) do
		if stack:get_name() == "" then
			list[i] = ""
		else
			list[i] = stack:to_string()
		end
	end
	imeta:set_string('inv_main', minetest.serialize(list))
	-- Set color
	local color = minetest.strip_param2_color(oldnode.param2,
						  "colorwallmounted")
	imeta:set_int('palette_index', color)
	-- Set Description
	imeta:set_string('description', get_description(oldnode,meta))
	-- Set Formspec
	imeta:set_string('formspec', get_formspec(pos,width,height))
end

local on_dig = function(pos, node, digger, width, height)
	if minetest.is_protected(pos, digger:get_player_name()) then
		return false
	end
	local player_inv = digger:get_inventory()
	-- See if it fits in invenotry
	local new = ItemStack(node)
	if player_inv:room_for_item("main", new) then
		--Call default node_dig() to remove node and make item
		--Causes preserve_metadata() to be called. 
		return minetest.node_dig(pos, node, digger)
	end
	return false
end
local on_receive_fields = function (pos, formname, fields, sender, width, height)
	local label = fields.label
	if label then
		local meta = minetest.get_meta(pos)
		meta:set_string('label', label)
		on_construct(pos, width, height)
	end
end

local allow_metadata_inventory_put = function(pos, listname, index, stack, player)
	if not string.match(stack:get_name(), "backpacks:") then
		return stack:get_count()
	else
		return 0
	end
end

wallmount_box = {
   type = "fixed",
   fixed = {
      {-0.4375, -0.375, -0.5, 0.4375, 0.375, 0.5}, -- NodeBox1
      {0.125, -0.5, -0.375, 0.375, -0.4375, 0.3125}, -- NodeBox2
      {-0.375, -0.5, -0.375, -0.125, -0.4375, 0.3125}, -- NodeBox3
      {0.125, -0.4375, 0.1875, 0.375, -0.375, 0.375}, -- NodeBox4
      {-0.375, -0.4375, 0.1875, -0.125, -0.375, 0.375}, -- NodeBox5
      {0.125, -0.4375, -0.375, 0.375, -0.375, -0.25}, -- NodeBox6
      {-0.375, -0.4375, -0.375, -0.125, -0.375, -0.25}, -- NodeBox7
      {-0.3125, 0.375, -0.375, 0.3125, 0.4375, 0.1875}, -- NodeBox8
      {-0.25, 0.4375, -0.315, 0.25, 0.5, 0.125}, -- NodeBox9
   }
}


-- backpacks
function backpacks.register_backpack(name, desc, texture, width, height, groups, sounds)

	minetest.register_node(":backpacks:backpack_"..name, {
		description = desc,
		tiles = { -- rotated onto its back for correct wallmounted dirs
		   texture.."^backpacks_backpack_front.png",     -- Front
		   texture.."^backpacks_backpack_back.png",      -- Back
		   texture.."^backpacks_backpack_sides-rotated.png",-- Right Side
		   texture.."^backpacks_backpack_sides-rotated.png",-- Left Side
		   texture.."^backpacks_backpack_topbottom.png", -- Top
		   texture.."^backpacks_backpack_topbottom.png", -- Bottom
		},
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "colorwallmounted",
		palette = "natural_dyes.png",
		node_box = wallmount_box,
		groups = groups,
		stack_max = 1,
		sounds = sounds,
		on_construct = function(pos)
			on_construct(pos, width, height)
		end,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			after_place_node(pos, placer, itemstack, pointed_thing)
			on_construct(pos, width, height)
		end,
		on_dig = function(pos, node, digger)
			on_dig(pos, node, digger, width, height)
		end,
		preserve_metadata = function(pos, oldnode, oldmeta, drops)
			preserve_metadata(pos, oldnode, oldmeta, drops, width, height)
		end,
		on_receive_fields = function(pos, formname, fields, sender)
			on_receive_fields(pos, formname, fields, sender, width, height)
		end,

		allow_metadata_inventory_put = function(pos, listname, index, stack, player)
			return allow_metadata_inventory_put(pos, listname, index, stack, player)
		end,
	})
end
