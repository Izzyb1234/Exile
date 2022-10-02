---------------------------------------
-- Particles helpers
---------------------------------------

local particle_idx = {} -- a list of weathers currently active for particles
local particle_table = {}

-- trying to locate position for particles by player look direction for performance reason.
-- it is costly to generate many particles around player so goal is focus mainly on front view.
local get_random_pos = function(player, offset)
	local look_dir = player:get_look_dir()
	local player_pos = player:get_pos()

	local random_pos_x
	local random_pos_y
	local random_pos_z

	if look_dir.x > 0 then
		if look_dir.z > 0 then
			random_pos_x = math.random(player_pos.x - offset.back, player_pos.x + offset.front) + math.random()
			random_pos_z = math.random(player_pos.z - offset.back, player_pos.z + offset.front) + math.random()
		else
			random_pos_x = math.random(player_pos.x - offset.back, player_pos.x + offset.front) + math.random()
			random_pos_z = math.random(player_pos.z - offset.front, player_pos.z + offset.back) + math.random()
		end
	else
		if look_dir.z > 0 then
			random_pos_x = math.random(player_pos.x - offset.front, player_pos.x + offset.back) + math.random()
			random_pos_z = math.random(player_pos.z - offset.back, player_pos.z + offset.front) + math.random()
		else
			random_pos_x = math.random(player_pos.x - offset.front, player_pos.x + offset.back) + math.random()
			random_pos_z = math.random(player_pos.z - offset.front, player_pos.z + offset.back) + math.random()
		end
	end

	if offset.bottom ~= nil then
		random_pos_y = math.random(player_pos.y - offset.bottom, player_pos.y + offset.top)
	else
		random_pos_y = player_pos.y + offset.top
	end

	return {x=random_pos_x, y=random_pos_y, z=random_pos_z}
end



-- checks if player is undewater. This is needed in order to
-- turn off weather particles generation.
local is_underwater = function(player)
	local ppos = player:get_pos()
	local offset = player:get_eye_offset()
	local player_eye_pos = {
		x = ppos.x + offset.x,
		y = ppos.y + offset.y + 1.5,
		z = ppos.z + offset.z}
	local node_level = minetest.get_node_level(player_eye_pos)
	if node_level == 8 or node_level == 7 then
		return true
	end
	return false
end


-- outdoor check based on node light level
local is_outdoor = function(pos, offset_y)
	if offset_y == nil then
		offset_y = 0
	end

	if minimal.get_daylight({x=pos.x, y=pos.y + offset_y, z=pos.z}, 0.5) == 15 then
		return true
	end
	return false
end

climate.add_particle = function(vel, acc, ext, size, tex, player)
   if not player then
      return
   end
   if is_underwater(player) then
      return
   end

   --Far particle
   local offset = {
      front = 8,
      back = 5,
      top = 12
   }

   local random_pos = get_random_pos(player, offset)
   local name = player:get_player_name()

   --check if under cover
   if is_outdoor(random_pos) then

      minetest.add_particle({
	    pos = {x=random_pos.x, y=random_pos.y, z=random_pos.z},
	    velocity = {x=0, y= vel, z=0},
	    acceleration = {x=0, y=acc, z=0},
	    expirationtime = ext,
	    size = math.random(size/2, size),
	    collisiondetection = true,
	    collision_removal = true,
	    vertical = true,
	    texture = tex,
	    playername = name
      })

   end

   --close particle
   offset = {
      front = 2,
      back = 0,
      top = 6
   }

   random_pos = get_random_pos(player, offset)

   --check if under cover
   if is_outdoor(random_pos) then

      minetest.add_particle({
	    pos = {x=random_pos.x, y=random_pos.y, z=random_pos.z},
	    velocity = {x=0, y= vel, z=0},
	    acceleration = {x=0, y=acc, z=0},
	    expirationtime = ext/2,
	    size = math.random(size/2, size),
	    collisiondetection = true,
	    collision_removal = true,
	    vertical = true,
	    texture = tex,
	    playername = name
      })
   end
end

--e.g. duststorm, or more floaty
climate.add_blizzard_particle = function(velxz, vely, accxz, accy, ext,
					 size, tex, player)
   if not player then
      return
   end
   if is_underwater(player) then
      return
   end

   --Far particle
   local offset = {
      front = 7,
      back = 3,
      top = 6
   }

   local random_pos = get_random_pos(player, offset)
   local name = player:get_player_name()

   --check if under cover
   if is_outdoor(random_pos) then

      minetest.add_particle({
	    pos = {x=random_pos.x, y=random_pos.y, z=random_pos.z},
	    velocity = {x=velxz, y= vely, z=velxz},
	    acceleration = {x=accxz, y=accy, z=accxz},
	    expirationtime = ext,
	    size = math.random(size/2, size),
	    collisiondetection = true,
	    collision_removal = true,
	    vertical = true,
	    texture = tex,
	    playername = name
      })

   end

   --close particle
   offset = {
      front = 3,
      back = 1,
      top = 3
   }

   random_pos = get_random_pos(player, offset)

   --check if under cover
   if is_outdoor(random_pos) then

      minetest.add_particle({
	    pos = {x=random_pos.x, y=random_pos.y, z=random_pos.z},
	    velocity = {x=velxz, y= vely, z=velxz},
	    acceleration = {x=accxz, y=accy, z=accxz},
	    expirationtime = ext/2,
	    size = math.random(size/2, size),
	    collisiondetection = true,
	    collision_removal = true,
	    vertical = true,
	    texture = tex,
	    playername = name
      })
   end
end

function climate.add_player_particle(p_name, w_name, w_def)
   local p_obj = minetest.get_player_by_name(p_name)
   -- check player object: in case they disconnected, don't add them
   if not p_obj then return end
   -- no particles needed for some weathers
   if w_def.particle_function == nil then
      return
   end
   if not particle_table[w_name] then -- track a new weather's particles
      particle_table[w_name] = { w_func = w_def.particle_function,
				 duration = w_def.particle_interval,
				 timer = 0,
				 plist = { [p_name] = p_obj } }
      table.insert(particle_idx, w_name)
   else -- add player to an existing table entry
      particle_table[w_name].plist[p_name] = p_obj
      if not particle_idx[w_name] then
	 table.insert(particle_idx, w_name)
      end
   end
end

local function remove_from_idx(weathername)
   for i = 1, #particle_idx do
      if particle_idx[i] == weathername then
	 table.remove(particle_idx, i)
      end
   end
end

function climate.clear_player_particle(p_name, w_name)
   if not w_name then
      w_name = climate.override[p_name]
   end
   if particle_table[w_name] then
      if particle_table[w_name].plist[p_name] then
	 particle_table[w_name].plist[p_name] = nil
      end
      if not next(particle_table[w_name].plist) then
	 -- no one else is using this particle, don't process it
	 remove_from_idx(w_name)
      end
   end
end

local aw_timer = 0 -- timer for active weather, others are in particle_table
minetest.register_globalstep(function(dtime)
      -- do base weather
      local aw = climate.active_weather
      if aw.particle_interval then
	 aw_timer = aw_timer + dtime
	 if aw_timer > aw.particle_interval then
	    --do active weather particles
	    for _, player in pairs(minetest.get_connected_players()) do
	       local nm = player:get_player_name()
	       if not climate.override[nm] then
		  aw.particle_function(player)
	       end
	    end
	    aw_timer = 0
	 end
      end
      -- do override weathers, if any
      for i = 1, #particle_idx do
	 local cw_nm = particle_idx[i]
	 local wtable = particle_table[cw_nm]
	 if next(wtable.plist) then -- plist is not empty
	    wtable.timer = wtable.timer + dtime
	    if wtable.timer > wtable.duration then
	       for name, pobj in pairs(wtable.plist) do
		  if pobj then
		     particle_table[cw_nm].w_func(pobj)
		  else
		     wtable.plist[name] = nil
		  end
	       end
	       wtable.timer = 0
	    end
	 end
      end
end)
