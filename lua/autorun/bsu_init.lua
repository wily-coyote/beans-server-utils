include("bsu/defines.lua")
if SERVER then AddCSLuaFile(BSU.DIR .. "defines.lua") end

local shLib = file.Find(BSU.DIR_LIB .. "*.lua", "LUA")
local clLib = file.Find(BSU.DIR_LIB .. "client/*.lua", "LUA")

-- load/send shared library
for _, file in ipairs(shLib) do
  include(BSU.DIR_LIB .. file)
  if SERVER then AddCSLuaFile(BSU.DIR_LIB .. file) end
end

if SERVER then
  local svLib = file.Find(BSU.DIR_LIB .. "server/*.lua", "LUA")

  -- load server library
  for _, file in ipairs(svLib) do
    include(BSU.DIR_LIB .. "server/" .. file)
  end

  -- send client library
  for _, file in ipairs(clLib) do
    AddCSLuaFile(BSU.DIR_LIB .. "client/" .. file)
  end

  -- initialize server-side
  include(BSU.DIR .."sv_init.lua")
  AddCSLuaFile(BSU.DIR .. "cl_init.lua")
else
  -- load client library
  for _, file in ipairs(clLib) do
    include(BSU.DIR_LIB .. "client/" .. file)
  end

  -- initialize client-side
  include(BSU.DIR .."cl_init.lua")
end