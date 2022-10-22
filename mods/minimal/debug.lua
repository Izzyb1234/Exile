-- This file contains quick blocks of code that can be enabled for debugging
--
--
exile = exile
exile.debug = {}
__DEBUG__ = true

function exile.debug.print(message)
	if __DEBUG__ then
		print (message)
	end
end

function exile.debug.crafting_stations(station)
	for station,recipies in pairs(crafting.recipes) do
		print ("station: "..station.."(recipies: "..#recipies..")")
	end
	if station then
		print (dump(crafting.recipes[station]))
	end
end




if __DEBUG__ then
	minetest.register_on_mods_loaded(function()
		print("--------------------[ Modules Loaded [-----------------------------")
		exile.debug.crafting_stations('axe_mixing')
	end)
end

