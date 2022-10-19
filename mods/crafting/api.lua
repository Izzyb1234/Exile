-- Crafting Mod - semi-realistic crafting in minetest
-- Copyright (C) 2018 rubenwardy <rw@rubenwardy.com>
--
-- This library is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- This library is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA


crafting = {
	recipes = {},
	tab_labels = {},
	recipes_by_id = {},
	recipes_by_output = {},
	registered_on_crafts = {},
}

function crafting.register_type(name, label)
	crafting.recipes[name] = {}
	-- add a label for tabs - default to the name
	crafting.tab_labels[name] = (label or name)
end

local recipe_counter = 0
function crafting.register_recipe(def)
	assert(def.output, "Output needed in recipe definition")
	assert(def.type,   "Type needed in recipe definition")
	assert(def.items,  "Items needed in recipe definition")

	def.level = def.level or 1
	-- Can be more then one craft station for a recipe
	-- Need to store as a table.
	if type(def.type) == 'string' then
		def.type = { def.type } 
	end
	-- Support multiple output items via a serialzed string
	output = def.output
	if type(def.output) == 'table' then
		output = minetest.serialize(def.output)
	end
	local recipes = crafting.recipes_by_id
	local by_output = crafting.recipes_by_output
	--if by_output[output] then
	--	local orig = by_output[output]
--print ("!!!OUTPUT EXISTS!!!"..output)
		--XXX Already exists
		-- check if same recipe
		-- check if adding new craft stations
--		def.id = by_output[output].id
--	else
		def.id = #crafting.recipes_by_id + 1
--	end
	crafting.recipes_by_output[output] = def
	crafting.recipes_by_id[def.id] = def
	-- add it to the craft station lists
	for _,ctype in ipairs(def.type) do
		local tab = crafting.recipes[ctype]
		assert(tab,        "Unknown craft type " .. ctype)
		tab[#tab + 1] = def
	end
	return def.id
end

local unlocked_cache = {}
function crafting.get_unlocked(name)
	local player = minetest.get_player_by_name(name)
	if not player then
		minetest.log("warning", "Crafting doesn't support getting unlocks for offline players")
		return {}
	end

	local retval = unlocked_cache[name]
	if not retval then
		retval = minetest.parse_json(
			player:get_meta():get("crafting:unlocked") or "{}")
		unlocked_cache[name] = retval
	end

	assert(retval)

	return retval
end

if minetest then
	minetest.register_on_leaveplayer(function(player)
		unlocked_cache[player:get_player_name()] = nil
	end)
end

local function write_json_dictionary(value)
	if next(value) then
		return minetest.write_json(value)
	else
		return "{}"
	end
end

function crafting.lock_all(name)
	local player = minetest.get_player_by_name(name)
	if not player then
		minetest.log("warning", "Crafting doesn't support setting unlocks for offline players")
		return {}
	end

	local unlocked = crafting.get_unlocked(name)

	for key, _ in pairs(unlocked) do
		unlocked[key] = nil
	end

	unlocked_cache[name] = unlocked

	player:get_meta():set_string("crafting:unlocked", write_json_dictionary(unlocked))
end

function crafting.unlock(name, output)
	local player = minetest.get_player_by_name(name)
	if not player then
		minetest.log("warning", "Crafting doesn't support setting unlocks for offline players")
		return {}
	end

	local unlocked = crafting.get_unlocked(name)

	if type(output) == "table" then
		for i=1, #output do
			unlocked[output[i]] = true
			minetest.chat_send_player(name, "You've unlocked " .. output[i])
		end
	else
		unlocked[output] = true
		minetest.chat_send_player(name, "You've unlocked " .. output)
	end

	unlocked_cache[name] = unlocked
	player:get_meta():set_string("crafting:unlocked", write_json_dictionary(unlocked))
end

function crafting.get_recipe(id)
	return crafting.recipes_by_id[id]
end

function crafting.get_all(type, level, item_hash, unlocked)
	assert(crafting.recipes[type], "No such craft type!")

	local results = {}
	for _, recipe in pairs(crafting.recipes[type]) do
		local craftable = true

		if recipe.level <= level and (recipe.always_known or unlocked[recipe.output]) then
			-- Check all ingredients are available
			local items = {}
			for _, item in pairs(recipe.items) do
				item = ItemStack(item)
				local needed_count = item:get_count()

				local available_count = item_hash[item:get_name()] or 0
				if available_count < needed_count then
					craftable = false
				end

				items[#items + 1] = {
					name = item:get_name(),
					have = available_count,
					need = needed_count,
				}
			end

			results[#results + 1] = {
				recipe    = recipe,
				items     = items,
				craftable = craftable,
			}
		end
	end

	return results
end

function crafting.set_item_hashes_from_list(inv, listname, item_hash)
	for _, stack in pairs(inv:get_list(listname)) do
		if not stack:is_empty() then
			local itemname = stack:get_name()
			item_hash[itemname] = (item_hash[itemname] or 0) + stack:get_count()

			local def = minetest.registered_items[itemname]
			if def and def.groups then
				for groupname, _ in pairs(def.groups) do
					local group = "group:" .. groupname
					item_hash[group] = (item_hash[group] or 0) + stack:get_count()
				end
			end
		end
	end
end

function crafting.get_all_for_player(player, type, level)
	local unlocked = crafting.get_unlocked(player:get_player_name())

	-- Get items hashed
	local item_hash = {}
	crafting.set_item_hashes_from_list(player:get_inventory(), "main", item_hash)

	return crafting.get_all(type, level, item_hash, unlocked)
end

function crafting.can_craft(name, ctype, level, recipe)
	local unlocked = crafting.get_unlocked(name)
	if type(ctype) == 'string' then
		ctype = { ctype }
	end
	rtypes = recipe.type
	if type(recipe.type) == 'string' then
		rtypes = { recipe.type }
	end
print (dump({name,ctype,level,recipe}))
	for _,station in ipairs(ctype) do
		for _,rec_type in ipairs(rtypes) do
			if  rec_type == station and recipe.level <= level and
					(recipe.always_known or unlocked[recipe.output]) then
				return true
			end
		end
	end
	return false
end	

local function give_all_to_player(inv, list)
	for _, item in pairs(list) do
		inv:add_item("main", item)
	end
end

function crafting.find_required_items(inv, listname, recipe)
	local items = {}
	for _, item in pairs(recipe.items) do
		item = ItemStack(item)

		local itemname = item:get_name()
		if item:get_name():sub(1, 6) == "group:" then
			local groupname = itemname:sub(7, #itemname)
			local required = item:get_count()

			-- Find stacks in group
			for i = 1, inv:get_size(listname) do
				local stack = inv:get_stack(listname, i)

				-- Is it in group?
				local def = minetest.registered_items[stack:get_name()]
				if def and def.groups and def.groups[groupname] then
					stack = ItemStack(stack)
					if stack:get_count() > required then
						stack:set_count(required)
					end
					items[#items + 1] = stack

					required = required - stack:get_count()

					if required == 0 then
						break
					end
				end
			end

			if required > 0 then
				return nil
			end
		else
			if inv:contains_item(listname, item) then
				items[#items + 1] = item
			else
				return nil
			end
		end
	end

	return items
end

function crafting.has_required_items(inv, listname, recipe)
	return crafting.find_required_items(inv, listname, recipe) ~= nil
end

function crafting.register_on_craft(func)
	table.insert(crafting.registered_on_crafts, func)
end

function crafting.perform_craft(name, inv, listname, outlistname, recipe)
	local items = crafting.find_required_items(inv, listname, recipe)
	if not items then
		return false
	end

	-- Take items
	local taken = {}
	for _, item in pairs(items) do
		item = ItemStack(item)

		local took = inv:remove_item(listname, item)
		taken[#taken + 1] = took
		if took:get_count() ~= item:get_count() then
			minetest.log("error", "Unexpected lack of items in inventory")
			give_all_to_player(inv, taken)
			return false
		end
	end

	for i=1, #crafting.registered_on_crafts do
		crafting.registered_on_crafts[i](name, recipe)
	end
	-- create item - set creator
	local itemstack=ItemStack(recipe.output)
	if minetest.get_item_group(recipe.output, 'craftedby') > 0 then
		local imeta=itemstack:get_meta()
		imeta:set_string('creator', name)
	end
	-- Add output
	if inv:room_for_item("main", itemstack) then
	   inv:add_item(outlistname, itemstack)
	else
	   local pos = minetest.get_player_by_name(name):get_pos()
	   minetest.chat_send_player(name, "No room in inventory!")
	   minetest.add_item(pos, itemstack)
	end
	return true
end

local function to_hex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

function crafting.calc_inventory_list_hash(inv, listname)
	local str = ""
	for _, stack in pairs(inv:get_list(listname)) do
		str = str .. stack:get_name() .. stack:get_count()
	end
	return minetest.sha1(to_hex(str))
end
