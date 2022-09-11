--restart.lua
--A chat command to allow users to start over

--Local table to store pending confirmations.  
local chat_confirm = {};
local timestamp = {}

local function killplayer(name)
   local player=minetest.get_player_by_name(name)
   local player_inv = player:get_inventory()
   for _, list_name in ipairs({'main','craft','cloths'}) do
	   if not player_inv:is_empty(list_name) then
		   player_inv:set_list(list_name,{})
	   end
   end
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

