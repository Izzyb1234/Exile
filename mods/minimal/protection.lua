-- minimal/protection.lua
--
-- This may need to moved someplace else eventually.

S=minimal.S
local __nail_use_count = 3 

function minimal.protection_nail_use( itemstack, user, pointed_thing )
	local owner = user:get_player_name()
	if pointed_thing.type == 'node' then 
		local pt_pos=minetest.get_pointed_thing_position(pointed_thing,false)
		if minimal.click_count_ready(owner, pt_pos, __nail_use_count) then 
			local pt_node=minetest.get_node(pt_pos)
			if not (pt_node.name == 'tech:stick' 
				or minetest.get_item_group(pt_node.name, 'flora') > 0
			) then
				local pt_meta=minetest.get_meta(pt_pos)
				if not pt_meta:contains('owner') then
					pt_meta:set_string("owner", owner)
					pt_meta:set_string('nailed', owner)
					itemstack:take_item()
					minimal.infotext_merge(pt_pos, nil, pt_meta)
				end
			end
		else
			-- play hammering sound
		end
	end
	return itemstack
end


-- Set owner for protected items.
function minimal.protection_after_place_node( pos, placer, itemstack, pointed_thing )
	local pn = placer:get_player_name()
	local meta = minetest.get_meta(pos)
	meta:set_string("owner", pn)
	minimal.infotext_merge(pos,nil,meta)
	return (creative and creative.is_enabled_for and creative.is_enabled_for(pn))
end

function minimal.protection_on_dig(pos,oldnode,digger)
	local meta = minetest.get_meta(pos)
	if meta:contains('nailed') then
		local owner = meta:get_string('owner')
		if owner == digger:get_player_name() then
			--give digger back the nails
			inv = digger:get_inventory()
			if inv:room_for_item("main", 'tech:nails') then
				inv:add_item("main",'tech:nails')
			else
				minetest.chat_send_player(digger, "No room in inventory!")
				minetest.add_item(pos, 'tech:nails')
			end
			meta:set_string('nailed', "")
		end
	end
end


