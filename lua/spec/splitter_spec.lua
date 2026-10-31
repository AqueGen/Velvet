-- Copyright (c) 2026 AqueGen. All rights reserved. See LICENSE.
local helper = require("spec.helper")

describe("UI.Splitter", function()
  local UI, cursor
  before_each(function()
    UI = helper.load()
    cursor = 100
    _G.GetCursorPosition = function() return cursor, 0 end
    UIParent.GetEffectiveScale = function() return 1 end
  end)

  it("reports the drag distance from where the press started and the end of the drag", function()
    local moves, done = {}, 0
    local bar = UI.Splitter(UIParent, function(dx) moves[#moves + 1] = dx end, function() done = done + 1 end)
    assert.is_true(bar.mouse)
    bar.scripts.OnMouseDown(bar, "LeftButton")
    cursor = 70
    bar.scripts.OnUpdate(bar, 0.016)
    cursor = 40
    bar.scripts.OnUpdate(bar, 0.016)
    bar.scripts.OnMouseUp(bar, "LeftButton")
    assert.same({ -30, -60 }, moves)
    assert.equal(1, done)
    assert.is_nil(bar.scripts.OnUpdate)
  end)

  it("lights its line on hover", function()
    local bar = UI.Splitter(UIParent, function() end)
    bar.scripts.OnEnter(bar)
    assert.is_true(helper.near(UI.T.underline, bar.line.color))
    bar.scripts.OnLeave(bar)
    assert.is_true(helper.near(UI.T.control, bar.line.color))
  end)
end)
