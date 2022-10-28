----------------------------------------
-- Lightsource API
-- allows creating light sources using fuel, e.g. oil lamps, lanterns, etc.
----------------------------------------

-- Internationalization
local S = tech.S

lightsource = {}

function lightsource.start_burning(pos, fuel, burn_rate)
    local meta = minetest.get_meta(pos)
    meta:set_int("fuel", fuel)
    minetest.get_node_timer(pos):start(burn_rate)
end

function lightsource.restore_from_inventory(pos, itemstack)
    local meta = minetest.get_meta(pos)
    local stack_meta = itemstack:get_meta()
    local fuel = stack_meta:get_int("fuel")
    if fuel > 0 then
        meta:set_int("fuel", fuel)
    end
end

--convert fuel number to a string
function lightsource.update_fuel_infotext(fuel, max_fuel, pos, meta)
    local fuel_string = ""
    if not fuel or fuel < 1 then
        fuel_string = S("Empty")
    else
        fuel_string = math.floor(fuel / max_fuel * 100).."% "..S("fuel left")
    end
    minimal.infotext_merge(pos, S("Status: ")..fuel_string, meta)
end

function lightsource.save_to_inventory(pos, node, digger, lightsource_name)
    if not digger then return false end
    if minetest.is_protected(pos, digger:get_player_name()) then
        return false
    end
    local meta = minetest.get_meta(pos)
    local fuel = meta:get_int("fuel")
    local new_stack = ItemStack(lightsource_name)
    local stack_meta = new_stack:get_meta()
    stack_meta:set_int("fuel", fuel)
    minetest.remove_node(pos)
    local player_inv = digger:get_inventory()
    if player_inv:room_for_item("main", new_stack) then
        player_inv:add_item("main", new_stack)
    else
        minetest.add_item(pos, new_stack)
    end
end

local function check_for_moisture(pos)
    return climate.get_rain(pos) or minetest.find_node_near(pos, 1, {"group:water"})
end

local function check_for_air(pos)
    return minetest.find_node_near(pos, 1, {"air"})
end

function lightsource.extinguish(pos, unlit_name)
    minetest.set_node(pos, {name = unlit_name})
    minetest.check_for_falling(pos)
end

-- FIXME: needs to actually spawn particles
function lightsource.spawn_particles(pos)
    -- if math.random() < 0.8 then
    --     minetest.sound_play("tech_fire_small",{pos = pos, max_hear_distance = 10, loop = false, gain = 0.1})
    --     --Smoke
    --     minetest.add_particlespawner(ncrafting.particle_smokesmall(pos))
    -- end
end

-- timer
function lightsource.burn_fuel(pos, unlit_name, put_out_by_moisture, max_fuel)
    local meta = minetest.get_meta(pos)
    local fuel = meta:get_int("fuel")
    local has_air = check_for_air(pos)
    local moisture = check_for_moisture(pos)
    lightsource.update_fuel_infotext(fuel, max_fuel, pos, meta)
    if fuel < 1 or not has_air or moisture and put_out_by_moisture then
        lightsource.extinguish(pos, unlit_name)
        return false -- stop timer
    else
        lightsource.spawn_particles(pos)
        meta:set_int("fuel", fuel - 1)
        return true -- next iteration
    end
end

function lightsource.ignite(pos, lit_name, max_fuel)
    local meta = minetest.get_meta(pos)
    local fuel = meta:get_int("fuel")
    if fuel and fuel > 0 then
        minimal.switch_node(pos, {name = lit_name})
        minetest.registered_nodes[lit_name].on_construct(pos)
        meta:set_int("fuel", fuel)
    end
    lightsource.update_fuel_infotext(fuel, max_fuel, pos, meta)
end

function lightsource.refill(pos, clicker, itemstack, fuel_name, max_fuel, refill_ratio)
    --hit it with oil to restore
    local stack_name = itemstack:get_name()
    local meta = minetest.get_meta(pos)
    local fuel = meta:get_int("fuel")
    if stack_name == fuel_name then
        if fuel and max_fuel - fuel > refill_ratio * max_fuel then
            -- sprinkle with some randomness
            fuel = fuel + refill_ratio * max_fuel + math.random(-0.005 * max_fuel, 0.01 * max_fuel)
            meta:set_int("fuel", fuel)
            local name = clicker:get_player_name()
            if not minetest.is_creative_enabled(name) then
                itemstack:take_item()
            end
            lightsource.update_fuel_infotext(fuel, max_fuel, pos, meta)
            return itemstack
        end
    end
end
