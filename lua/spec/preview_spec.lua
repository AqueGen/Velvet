-- Copyright (c) 2026 AqueGen. All rights reserved. See LICENSE.
local helper = require("spec.helper")

describe("UI.PreviewLayout", function()
  local UI
  before_each(function() UI = helper.load() end)

  it("puts the zone beside the column when both fit", function()
    assert.same({ mode = "side", columnW = 520, zoneW = 284 }, UI.PreviewLayout(812, 520, 260, 380))
  end)

  it("caps the zone and gives the column the rest", function()
    assert.same({ mode = "side", columnW = 812, zoneW = 380 }, UI.PreviewLayout(1200, 520, 260, 380))
  end)

  it("keeps the side form at the exact threshold", function()
    assert.same({ mode = "side", columnW = 520, zoneW = 260 }, UI.PreviewLayout(788, 520, 260, 380))
  end)

  it("falls back to a band above the column in a narrow window", function()
    assert.same({ mode = "band", columnW = 672, zoneW = 672 }, UI.PreviewLayout(672, 520, 260, 380))
  end)
end)

describe("UI.FitScale", function()
  local UI
  before_each(function() UI = helper.load() end)

  it("shrinks to the tighter side", function()
    assert.equal(0.5, UI.FitScale(400, 200, 200, 200))
  end)

  it("never enlarges", function()
    assert.equal(1, UI.FitScale(100, 50, 400, 400))
  end)

  it("treats an empty size as scale 1", function()
    assert.equal(1, UI.FitScale(0, 50, 100, 100))
    assert.equal(1, UI.FitScale(nil, nil, 100, 100))
  end)

  it("treats a stage with no size yet as scale 1", function()
    assert.equal(1, UI.FitScale(400, 200, 0, 0))
  end)
end)

describe("UI.PreviewPane", function()
  local UI, pane
  before_each(function()
    UI = helper.load()
    pane = UI.PreviewPane(UIParent)
  end)

  it("paints the pane and clips its stage", function()
    assert.is_true(helper.near(UI.T.panel, pane.backdropColor))
    assert.is_true(helper.near(UI.T.border, pane.backdropBorder))
    assert.is_true(pane.stage.clips)
    assert.equal("VERTICAL", pane.world.gradient[1])
    assert.is_false(pane.offLine.shown)
  end)

  it("sets the caption", function()
    pane:SetCaption("Preview: demo")
    assert.equal("Preview: demo", pane.caption:GetText())
  end)

  it("dims the stage and shows the off line, then restores both", function()
    pane:SetOff("Off: x")
    assert.equal(0.35, pane.stage:GetAlpha())
    assert.is_true(pane.offLine.shown)
    assert.equal("Off: x", pane.offLine:GetText())
    pane:SetOff(nil)
    assert.equal(1, pane.stage:GetAlpha())
    assert.is_false(pane.offLine.shown)
  end)

  it("scales content to fit the stage and centres it", function()
    pane.stage:SetSize(200, 200)
    local content = CreateFrame("Frame", nil, pane.stage)
    pane:Fit(content, 400, 200)
    assert.equal(0.5, content:GetScale())
    local point, rel = content:GetPoint(1)
    assert.equal("CENTER", point)
    assert.equal(pane.stage, rel)
  end)

  it("refits the content when the stage changes size", function()
    pane.stage:SetSize(200, 200)
    local content = CreateFrame("Frame", nil, pane.stage)
    pane:Fit(content, 400, 200)
    pane.stage:SetSize(100, 100)
    pane.stage:GetScript("OnSizeChanged")(pane.stage, 100, 100)
    assert.equal(0.25, content:GetScale())
  end)
end)
