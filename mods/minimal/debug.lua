-- This file contains quick blocks of code that can be enabled for debugging
--
--
exile = exile
exile.debug = exile.debug or {
	__DEBUG__ = false
}


local __DEBUG__ = exile.debug.__DEBUG__

function exile.debug.print(message)
	if exile.debug.__DEBUG__ then
		minetest.log('warning', message)
	end
end

function exile.debug.crafting_stations(station)
	for station,recipies in pairs(crafting.recipes) do
		minetest.log('warning', "station: "..station.."(recipies: "..#recipies..")")
	end
	if station then
		minetest.log('warning', dump(crafting.recipes[station]))
	end
end

function exile.debug.dump_nodedef_params(params, filter)
	if type(params) == 'string' then
		params = { params }
	end
	for node,def in pairs(minetest.registered_nodes) do
		if string.find(node,filter,1) then
			for _,param in ipairs(params) do
				minetest.log('warning', "Node: "..node.."  "..param..": "..dump(def[param]))
			end
		end
	end
end


if __DEBUG__ then
	minetest.register_on_mods_loaded(function()
		minetest.log('warning',"--------------------[ Modules Loaded [-----------------------------")
--		exile.debug.crafting_stations('axe_mixing')
		exile.debug.dump_nodedef_params('groups','depleted')
	end)
end

