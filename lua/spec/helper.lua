-- Copyright (c) 2026 AqueGen. All rights reserved. See LICENSE.
local stub = require("spec.wow_stub")

local dir = "LibVelvet-1.0/"

local function files()
  local f = assert(io.open(dir .. "lib.xml", "rb"))
  local xml = f:read("*a")
  f:close()
  local list = {}
  for name in xml:gmatch('<Script file="([^"]+)"/>') do list[#list + 1] = name end
  return list
end

local helper = { stub = stub }

function helper.load()
  for _, name in ipairs(files()) do dofile(dir .. name) end
  return LibStub("LibVelvet-1.0")
end

function helper.find(frame, pred)
  for _, c in ipairs(frame.children) do
    if pred(c) then return c end
  end
end

function helper.point(region, name)
  for _, p in ipairs(region.points) do
    if p[1] == name then return unpack(p) end
  end
end

function helper.near(a, b)
  if type(a) ~= "table" or type(b) ~= "table" then return false end
  for i = 1, math.max(#a, #b) do
    if math.abs((a[i] or 1) - (b[i] or 1)) > 1e-6 then return false end
  end
  return true
end

return helper
