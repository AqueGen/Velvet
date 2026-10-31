-- Copyright (c) 2026 AqueGen. All rights reserved. See LICENSE.
local helper = require("spec.helper")

describe("UI.Segments", function()
  local UI, set, picked
  local OPTIONS = {
    { text = "None", value = "none" }, { text = "Glyph", value = "glyph" },
    { text = "Short text", value = "short" }, { text = "Full text", value = "full" },
  }
  before_each(function()
    UI = helper.load()
    picked = {}
    set = UI.Segments(UIParent, OPTIONS, 301, 22, function(value) picked[#picked + 1] = value end)
  end)

  local function underlines()
    local n = 0
    for _, b in ipairs(set.buttons) do if b.underline:IsShown() then n = n + 1 end end
    return n
  end

  it("splits the width over the segments and draws one outer edge with dividers", function()
    local sum = 0
    for _, b in ipairs(set.buttons) do sum = sum + b:GetWidth() end
    assert.equal(4, #set.buttons)
    assert.equal(301, sum)
    assert.equal(3, #set.dividers)
    assert.is_true(helper.near(UI.T.control, set.backdropBorder))
    assert.is_true(helper.near(UI.T.divider, set.dividers[1].color))
    for _, b in ipairs(set.buttons) do assert.is_nil(b.backdropBorder) end
  end)

  it("Select paints exactly one segment and does not call onSelect", function()
    set:Select("glyph")
    assert.equal(1, underlines())
    local b = set.buttons[2]
    assert.is_true(b.underline:IsShown())
    assert.is_true(helper.near(UI.T.selLabel, b.label.textColor))
    assert.is_true(helper.near(UI.T.selected, b.fill.color))
    assert.is_true(helper.near(UI.T.text, set.buttons[1].label.textColor))
    assert.is_true(helper.near(UI.T.segfill, set.buttons[1].fill.color))
    assert.same({}, picked)
  end)

  it("a click reports the value once and selects it", function()
    set.buttons[3]:Click()
    assert.same({ "short" }, picked)
    assert.is_true(set.buttons[3].underline:IsShown())
    assert.equal(1, underlines())
  end)

  it("when off it greys the labels, hides the underline and ignores clicks", function()
    set:Select("glyph")
    set:SetOff(true)
    set.buttons[3]:Click()
    assert.same({}, picked)
    assert.equal(0, underlines())
    assert.is_true(helper.near(UI.T.muted, set.buttons[2].label.textColor))
    set:SetOff(false)
    assert.equal(1, underlines())
  end)
end)
