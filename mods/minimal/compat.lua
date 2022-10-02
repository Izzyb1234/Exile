minimal = minimal

minimal.mtversion = {}

local version = minetest.get_version()
local tabstr = string.split(version.string,".")
local major = tonumber(tabstr[1])
local minor = tonumber(tabstr[2])
local patch = tonumber(tabstr[3])
minetest.log("action", "Running on version: "..version.project.." "..
	     major.."."..minor.."."..patch)
minimal.mtversion = { project = version.project, major = major,
		      minor = minor, patch = patch }
print("VERSION : ",dump(minimal.mtversion))

function minimal.mt_required_version(maj, min, pat)
   if minimal.mtversion.project ~= "Minetest" then
      return false -- Not running Minetest? #TODO check indiv feature support
   end
   if minimal.mtversion.major > maj or
      ( minimal.mtversion.major == maj and
	minimal.mtversion.minor > min ) or
      ( minimal.mtversion.major == maj and
	minimal.mtversion.minor == min and
	minimal.mtversion.patch >= pat ) then
      return true
   else
      return false
   end
end

function minimal.get_daylight(pos, tod)
   if minetest.get_natural_light then
      minetest.get_natural_light(pos, tod)
   else
      minetest.get_node_light(pos,tod)
   end
end

minimal.compat_alpha = {}
if minimal.mt_required_version(5, 4, 0) then
   minimal.compat_alpha = {
      ["blend"] = "blend",
      ["opaque"] = "opaque",
      ["clip"] = "clip",
   }
else
   minimal.compat_alpha = {
      ["blend"] = true,
      ["opaque"] = false,
      ["clip"] = true, -- may be false for some draw types?
   }
end
