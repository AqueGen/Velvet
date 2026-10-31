-- Copyright (c) 2026 AqueGen. All rights reserved. See LICENSE.
local helper = require("spec.helper")

describe("UI.Input", function()
  local UI, box
  before_each(function()
    UI = helper.load()
    box = UI.Input(UIParent, 80, 22)
  end)

  it("is a flat edit box in the well colour with a control edge", function()
    assert.equal("EditBox", box:GetObjectType())
    assert.equal(80, box:GetWidth())
    assert.equal(22, box:GetHeight())
    assert.equal(UI.FLAT, box:GetBackdrop())
    assert.is_true(helper.near(UI.T.well, box.backdropColor))
    assert.is_true(helper.near(UI.T.control, box.backdropBorder))
    assert.is_false(box.autoFocus)
  end)

  it("shows focus with the underline colour and drops it on Enter and Escape", function()
    box.scripts.OnEditFocusGained(box)
    assert.is_true(helper.near(UI.T.underline, box.backdropBorder))
    box.scripts.OnEnterPressed(box)
    assert.is_true(box.focusCleared)
    box.scripts.OnEditFocusLost(box)
    assert.is_true(helper.near(UI.T.control, box.backdropBorder))
    box.focusCleared = nil
    box.scripts.OnEscapePressed(box)
    assert.is_true(box.focusCleared)
  end)

  it("dims when disabled", function()
    box:SetEnabled(false)
    assert.equal(0.45, box:GetAlpha())
    box:SetEnabled(true)
    assert.equal(1, box:GetAlpha())
  end)
end)
