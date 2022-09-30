--restart.lua
--A chat command to allow users to start over

--Local table to store pending confirmations.  
local chat_confirm = {}
local timestamp = {}


local __stash_timeout = 60*60*24*14 -- keep for 2 weeks
local function stash_inventory(player, stash, list)
	local timeout = os.time() - __stash_timeout
	local pmeta = player:get_meta()
	local stash_table = {}
	-- Purge expired entries from the list
	if pmeta:contains(stash) then
		stash_table=minetest.deserialize(pmeta:get_string(stash))
		for i, stack in ipairs(stash_table) do
			if stack.epoch < timeout then
				stash_table[i] = nil -- expire old entries
			end
		end
	end
	-- Append new entries to the list
	for _, stack in ipairs(list) do
		stash_table:insert(stack)
	end
	-- save the stash to player meta
	pmeta:set_string(stash, minetest.serialize(stash_table))
end

local function killplayer(name)
   local player=minetest.get_player_by_name(name)
   local player_inv = player:get_inventory()
   local epoch=os.time()
   local restart_list = {}
   for _, list_name in ipairs({'main','craft','cloths'}) do
	if not player_inv:is_empty(list_name) then
		for _, stack in ipairs(inv:get_list(list_name)) do
			if stack:get_name() ~= "" then
				local meta=minetest.serialize(stack:get_meta():to_table())
				restart_list:insert({
					epoch=epoch,
					stack=stack:to_string(),
					meta=meta
				})
			end
		end
		player_inv:set_list(list_name,{}) -- delete the inventory.
	end
   end
   stash_inventory(player,'restart_list',restart_list)
   -- Disable effects of clothes
   clothing:update_temp(player)
   player:set_hp(0)
end

local function restart_confirm (name, message)
	if (chat_confirm[name] == 'restart') then
		if message == 'Yes' or message == "yes" then
			minetest.log("action", name .. " gave up the ghost.")
			timestamp[name] = minetest.get_gametime()
			killplayer(name)
		else
			minetest.chat_send_player(name, "You've come to your senses and decided to keep trying")
		end
		chat_confirm[name] = nil
		return true
	end
	return false -- let other modules see it.
end

local function restart (name, param)
	local nowtime = minetest.get_gametime()
	if timestamp[name] and ( timestamp[name] +300 ) > nowtime then
	   minetest.chat_send_player(name, "You can't use this command more than once per 5 minutes.")
	   return
	else
	   timestamp[name] = nil
	   minetest.chat_send_player(name, "Restarting does not leave bones.  Your inventory will be deleted.\nAre you sure?  Reply with: Yes")
	   chat_confirm[name]="restart";
	end
end

minetest.register_chatcommand("restart",{
	privs = {
		interact = true,
	},
	func = restart
})

minetest.register_chatcommand("respawn",{
	privs = {
		interact = true,
	},
	func = restart
})

minetest.register_on_chat_message(restart_confirm)

