-- Copyright (c) 2026 AqueGen. All rights reserved. See LICENSE.
local helper = require("spec.helper")

describe("UI.Button", function()
  local UI
  before_each(function() UI = helper.load() end)

  it("is a flat 22-high button with a control edge and a text label", function()
    local b = UI.Button(UIParent, "Demo", 120)
    assert.equal(120, b:GetWidth())
    assert.equal(22, b:GetHeight())
    assert.equal(UI.FLAT, b:GetBackdrop())
    assert.is_true(helper.near(UI.T.panel, b.backdropColor))
    assert.is_true(helper.near(UI.T.control, b.backdropBorder))
    assert.equal("Demo", b.label:GetText())
    assert.is_true(helper.near(UI.T.text, b.label.textColor))
  end)

  it("has a soft white hover", function()
    local b = UI.Button(UIParent, "Demo", 120)
    assert.is_true(helper.near(UI.T.hover, b:GetHighlightTexture().color))
  end)

  it("switches to gold label and edge when primary and back", function()
    local b = UI.Button(UIParent, "Demo", 120, true)
    assert.is_true(helper.near(UI.T.gold, b.label.textColor))
    assert.is_true(helper.near(UI.T.gold, b.backdropBorder))
    UI.SetPrimary(b, false)
    assert.is_true(helper.near(UI.T.text, b.label.textColor))
    assert.is_true(helper.near(UI.T.control, b.backdropBorder))
  end)
end)
