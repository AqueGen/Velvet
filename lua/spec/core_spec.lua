-- Copyright (c) 2026 AqueGen. All rights reserved. See LICENSE.
local helper = require("spec.helper")

describe("LibVelvet core", function()
  local UI
  before_each(function() UI = helper.load() end)

  it("registers LibVelvet-1.0 at MINOR 1", function()
    assert.equal(1, UI.MINOR)
    assert.equal(UI, LibStub("LibVelvet-1.0"))
  end)

  it("keeps the loaded copy when an equal or older copy loads after it", function()
    local button = UI.Button
    helper.load()
    assert.equal(button, LibStub("LibVelvet-1.0").Button)
    assert.is_nil(LibStub("LibVelvet-1.0").loading)
  end)

  it("lets a newer copy replace the functions", function()
    local old = UI.Button
    local lib = LibStub:NewLibrary("LibVelvet-1.0", 2)
    assert.equal(UI, lib)
    lib.loading = true
    dofile("LibVelvet-1.0/Button.lua")
    lib.loading = nil
    assert.is_function(UI.Button)
    assert.are_not.equal(old, UI.Button)
  end)

  it("ships the spec's token values", function()
    local want = {
      bg = { 0.063, 0.075, 0.09, 0.99 }, panel = { 0.082, 0.098, 0.125, 1 }, border = { 0.18, 0.20, 0.235, 1 },
      control = { 0.275, 0.295, 0.337, 1 }, divider = { 0.19, 0.21, 0.247, 1 }, segfill = { 0.10, 0.118, 0.149, 1 },
      selected = { 0.196, 0.224, 0.282, 1 }, navSelected = { 0.14, 0.16, 0.204, 1 }, selLabel = { 0.97, 0.855, 0.50 },
      underline = { 0.91, 0.73, 0.275, 1 }, title = { 0.92, 0.78, 0.40 }, gold = { 1, 0.82, 0 }, text = { 0.9, 0.9, 0.9 },
      muted = { 0.72, 0.74, 0.78 }, hover = { 1, 1, 1, 0.04 }, track = { 0.17, 0.19, 0.235, 1 },
      trackFill = { 0.59, 0.49, 0.27, 1 }, thumb = { 0.83, 0.84, 0.87, 1 }, well = { 0.078, 0.09, 0.114, 1 },
      wellOn = { 0.157, 0.141, 0.094, 1 }, tick = { 0.94, 0.80, 0.39 },
    }
    for key, value in pairs(want) do
      assert.same(value, UI.T[key], key)
    end
    assert.equal(UI.T.title, UI.HEADER)
    assert.equal(8, UI.GAP)
    assert.equal(12, UI.PAD)
    assert.equal(1, UI.FLAT.edgeSize)
  end)

  it("keeps edge colours bright enough to survive UI scale 0.64", function()
    for _, key in ipairs({ "divider", "border", "control" }) do
      local c = UI.T[key]
      assert.is_true(0.299 * c[1] + 0.587 * c[2] + 0.114 * c[3] >= 0.18, key)
    end
  end)
end)
