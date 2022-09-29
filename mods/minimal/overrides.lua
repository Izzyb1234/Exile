--overrides.lua
--Alters base minetest functions for:
--item_place
--is_protected
--fall damage

local fall_damage_multiplier = 1.5

--A new item_place that allows disabling sneak-rightclick behavior for nodes
--Needed for tech:stick
function core.item_place(itemstack, placer, pointed_thing, param2)
        -- Call on_rightclick if the pointed node defines it
        if pointed_thing.type == "node" and placer then
                local node = core.get_node( pointed_thing.under )
                local ndef = core.registered_nodes[ node.name ]

                if ndef and ndef.on_rightclick and ( ndef.override_sneak == true or not placer:get_player_control( ).sneak ) then
                        return ndef.on_rightclick( pointed_thing.under, node, placer, itemstack, pointed_thing ) or itemstack, nil
                end
        end

        if itemstack:get_definition( ).type == "node" then
                return core.item_place_node( itemstack, placer, pointed_thing, param2 )
        end
        return itemstack, nil
end


--Basic protection support
local old_is_protected = minetest.is_protected
function minetest.is_protected(pos, name)
   local owner = minetest.get_meta(pos):get_string("owner")
   local bypass = minetest.check_player_privs(name, "protection_bypass")
   if not ( owner == "" or owner == name or
	    minetest.check_player_privs(name, "protection_bypass") ) then
      return true
   end
   return old_is_protected(pos, name)
end

-- Return protection nail if node was nailed
local old_node_dig = minetest.node_dig
function minetest.node_dig(pos, node, digger)
	minimal.protection_on_dig(pos,node,digger)
	return old_node_dig(pos, node, digger)
end

-- Transfer metadata from node to item and back.
minetest.register_on_mods_loaded(function()
	-- Add a preserve_metadata callback to all nodes
	for oName, override in pairs( minetest.registered_nodes ) do
		local old_preserve_metadata = override.preserve_metadata
		minetest.override_item(oName, {
			preserve_metadata = function(pos, oldNode, oldmeta, drops)
				if drops[1] then
					local imeta=drops[1]:get_meta()
					minimal.metadata.preserve_metadata(imeta,oldmeta)
					if type(old_preserve_metadata) == 'function' then
						old_preserve_metadata(pos, oldNode, oldmeta, drops)
					end
				end

			end,
		})
		local old_after_place_node = override.after_place_node
		minetest.override_item(oName, {
			after_place_node = function(pos, placer, itemstack, pointed_thing)
				local imeta = itemstack:get_meta()
				local meta = minetest.get_meta(pos)
				minimal.metadata.after_place_node(imeta,meta)
				if type(old_after_place_node) == 'function' then
					old_after_place_node(pos, placer, itemstack, pointed_thing)
				end
			end,
		})
	end

end)

--Increase fall damage
minetest.register_on_player_hpchange(function(player, hp_change, reason)
	if reason.type == "fall" then
		hp_change = hp_change*fall_damage_multiplier
	end
	return hp_change
end, true)



