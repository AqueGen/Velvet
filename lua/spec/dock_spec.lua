-- Copyright (c) 2026 AqueGen. All rights reserved. See LICENSE.
local helper = require("spec.helper")
local stub = helper.stub

describe("UI.Dock", function()
  local UI, Dock
  local panels, saved, changed

  local function add(id, left, top, opts)
    opts = opts or {}
    local f = CreateFrame("Frame", nil, UIParent)
    f.left, f.top, f.w, f.h = left, top, opts.w or 100, opts.h or 50
    local pos = opts.pos or {}
    saved[id] = pos
    changed[id] = 0
    Dock.Register(id, {
      frame = f, root = opts.root,
      get = function() return pos end,
      set = function(p) saved[id] = p end,
      locked = function() return opts.locked end,
      merged = opts.merged,
      onChange = function() changed[id] = changed[id] + 1 end,
    })
    panels[id] = f
    return f
  end

  local function mergeFrame()
    for _, f in ipairs(stub.created) do
      if f.template == "BackdropTemplate" then return f end
    end
  end

  before_each(function()
    UI = helper.load()
    Dock = UI.Dock
    for id in pairs(UI.dock.panels) do UI.dock.panels[id] = nil end
    stub.reset()
    panels, saved, changed = {}, {}, {}
  end)

  it("anchors a member to the root edge and moves it with the root", function()
    local r = add("R", 100, 980, { root = true })
    local m = add("M", 0, 0, { pos = { dockTo = "R", side = "Right", offset = 10 } })
    Dock.Apply("M")
    local p, rel, relPoint, x, y = helper.point(m, "TOPLEFT")
    assert.equal("TOPLEFT", p)
    assert.equal(r, rel)
    assert.equal("TOPRIGHT", relPoint)
    assert.equal(6, x)
    assert.equal(-10, y)
  end)

  it("anchors the other three sides", function()
    local r = add("R", 100, 980, { root = true })
    local l = add("L", 0, 0, { pos = { dockTo = "R", side = "Left", offset = 4 } })
    local b = add("B", 0, 0, { pos = { dockTo = "R", side = "Below", offset = 7 } })
    local a = add("A", 0, 0, { pos = { dockTo = "R", side = "Above", offset = 7 } })
    Dock.Apply("L") Dock.Apply("B") Dock.Apply("A")
    assert.same({ "TOPRIGHT", r, "TOPLEFT", -6, -4 }, l.points[1])
    assert.same({ "TOPLEFT", r, "BOTTOMLEFT", 7, -6 }, b.points[1])
    assert.same({ "BOTTOMLEFT", r, "TOPLEFT", 7, 6 }, a.points[1])
  end)

  it("leaves a member on its own place when the target is missing", function()
    local m = add("M", 0, 0, { pos = { dockTo = "gone", side = "Right", offset = 0 } })
    Dock.Apply("M")
    assert.is_nil(m.points)
  end)

  it("leaves a member on its own place when the target is hidden", function()
    local r = add("R", 100, 980, { root = true })
    local m = add("M", 0, 0, { pos = { dockTo = "R", side = "Right", offset = 0 } })
    r:Hide()
    Dock.Apply("M")
    assert.is_nil(m.points)
  end)

  it("does not loop on a dock cycle", function()
    local a = add("a", 0, 0, { pos = { dockTo = "b", side = "Right", offset = 0 } })
    add("b", 0, 0, { pos = { dockTo = "a", side = "Right", offset = 0 } })
    assert.has_no.errors(function() Dock.Apply("a") end)
    assert.is_nil(a.points)
  end)

  it("lists members transitively", function()
    add("R", 100, 980, { root = true })
    add("M", 0, 0, { pos = { dockTo = "R", side = "Right", offset = 0 } })
    add("N", 0, 0, { pos = { dockTo = "M", side = "Below", offset = 0 } })
    add("X", 0, 0)
    local got = Dock.Members("R")
    table.sort(got)
    assert.same({ "M", "N" }, got)
  end)

  it("refuses drags in combat and when locked", function()
    add("P", 0, 0)
    add("L", 0, 0, { locked = true })
    assert.is_true(Dock.CanDrag("P"))
    assert.is_false(Dock.CanDrag("L"))
    stub.combat = true
    assert.is_false(Dock.CanDrag("P"))
  end)

  it("never anchors a root to a member", function()
    add("R", 100, 980, { root = true })
    add("P", 206, 980)
    Dock.Drop("R")
    assert.is_nil(saved.R.dockTo)
    assert.equal("R", saved.P.dockTo)
    assert.equal("Right", saved.P.side)
    assert.equal(0, saved.P.offset)
  end)

  it("docks a dropped member to the edge it touches", function()
    add("R", 100, 980, { root = true })
    add("P", 206, 970)
    Dock.Drop("P")
    assert.equal("R", saved.P.dockTo)
    assert.equal(10, saved.P.offset)
    assert.is_true(changed.P > 0)
  end)

  it("undocks a member dropped away from every edge and keeps it on screen", function()
    add("R", 100, 980, { root = true })
    local m = add("M", 600, 800, { pos = { dockTo = "R", side = "Right", offset = 0 } })
    Dock.Drop("M")
    assert.is_nil(saved.M.dockTo)
    local p, rel, relPoint, x, y = helper.point(m, "TOPLEFT")
    assert.equal(UIParent, rel)
    assert.equal(600, x)
    assert.equal(-280, y)
  end)

  it("undock clears the dock fields and re-anchors to the screen", function()
    add("R", 100, 980, { root = true })
    local m = add("M", 206, 980, { pos = { dockTo = "R", side = "Right", offset = 0 } })
    Dock.Undock("M")
    assert.is_nil(saved.M.dockTo)
    assert.is_nil(saved.M.side)
    assert.equal(UIParent, select(2, helper.point(m, "TOPLEFT")))
    assert.is_true(changed.M > 0)
  end)

  it("skips moving frames in combat", function()
    local r = add("R", 100, 980, { root = true })
    local m = add("M", 0, 0, { pos = { dockTo = "R", side = "Right", offset = 0 } })
    stub.combat = true
    Dock.Apply("M")
    assert.is_nil(m.points)
    assert.is_nil(r.points)
  end)

  it("uses no gap when merged", function()
    add("R", 100, 980, { root = true, merged = function() return true end })
    local m = add("M", 0, 0, { pos = { dockTo = "R", side = "Right", offset = 0 } })
    Dock.Apply("M")
    assert.equal(0, select(4, helper.point(m, "TOPLEFT")))
  end)

  it("snaps to a merged group without a gap", function()
    add("R", 100, 980, { root = true, merged = function() return true end })
    add("P", 203, 980)
    local x = Dock.Snap("P")
    assert.equal(200, x)
  end)

  it("anchors the merged frame by points only", function()
    local r = add("R", 100, 980, { root = true, merged = function() return true end })
    local m = add("M", 200, 980, { pos = { dockTo = "R", side = "Right", offset = 0 } })
    Dock.RefreshMerge("R")
    local frame = mergeFrame()
    assert.is_truthy(frame)
    assert.is_true(frame:IsShown())
    assert.equal(2, #frame.points)
    assert.equal(r, select(2, helper.point(frame, "TOPLEFT")))
    assert.equal(m, select(2, helper.point(frame, "BOTTOMRIGHT")))
    assert.equal(0, frame.w)
    assert.equal(0, frame.h)
    assert.is_true(changed.M > 0)
  end)

  it("hides the merged frame when not merged", function()
    local on = true
    add("R", 100, 980, { root = true, merged = function() return on end })
    add("M", 200, 980, { pos = { dockTo = "R", side = "Right", offset = 0 } })
    Dock.RefreshMerge("R")
    on = false
    Dock.RefreshMerge("R")
    local frame = mergeFrame()
    assert.is_false(frame:IsShown())
  end)

  it("reports hover over any member of the group", function()
    local r = add("R", 100, 980, { root = true })
    local m = add("M", 200, 980, { pos = { dockTo = "R", side = "Right", offset = 0 } })
    add("X", 500, 500)
    assert.is_false(Dock.Hovered("R"))
    stub.over[m] = true
    assert.is_true(Dock.Hovered("R"))
    assert.is_true(Dock.Hovered("M"))
    assert.is_false(Dock.Hovered("X"))
    stub.over[m] = nil
    stub.over[r] = true
    assert.is_true(Dock.Hovered("M"))
  end)

  it("shows the arrow only on hover", function()
    local r = add("R", 100, 980, { root = true })
    local arrow = Dock.Arrow(r, function() end, "R")
    r.scripts.OnUpdate(r, 0)
    assert.is_false(arrow:IsShown())
    stub.over[r] = true
    r.scripts.OnUpdate(r, 0)
    assert.is_true(arrow:IsShown())
    stub.over[r] = nil
    stub.over[arrow] = true
    r.scripts.OnUpdate(r, 0)
    assert.is_true(arrow:IsShown())
    stub.over[arrow] = nil
    r.scripts.OnUpdate(r, 0)
    assert.is_false(arrow:IsShown())
    assert.equal(14, arrow.w)
    assert.equal(14, arrow.h)
  end)

  it("flips the arrow chevron and forwards clicks", function()
    local r = add("R", 100, 980, { root = true })
    local clicks = 0
    local arrow = Dock.Arrow(r, function() clicks = clicks + 1 end)
    local expanded = arrow.fontString:GetText()
    arrow:SetCollapsed(true)
    assert.not_equal(expanded, arrow.fontString:GetText())
    arrow:SetCollapsed(false)
    assert.equal(expanded, arrow.fontString:GetText())
    arrow:Click()
    assert.equal(1, clicks)
  end)

  it("anchors the merged frame to the true extents of an L-shaped group", function()
    local r = add("R", 0, 1080, { root = true, w = 300, h = 60, merged = function() return true end })
    add("M", 0, 1020, { w = 150, h = 100, pos = { dockTo = "R", side = "Below", offset = 0 } })
    Dock.RefreshMerge("R")
    local frame = mergeFrame()
    local _, trel, _, _, ty = helper.point(frame, "TOPLEFT")
    local _, rel, _, _, by = helper.point(frame, "BOTTOMRIGHT")
    assert.equal(trel == r and 0 or 60, ty)
    assert.equal(r, rel)
    assert.equal(-100, by)
  end)

  it("uses raw UIParent units for merged frame offsets when members are scaled", function()
    add("R", 10, 1080, { root = true, w = 300, h = 60, merged = function() return true end })
    local m = add("M", 0, 680, { w = 100, h = 100, pos = { dockTo = "R", side = "Below", offset = 0 } })
    m.effScale = 1.5
    Dock.RefreshMerge("R")
    local _, trel, _, _, ty = helper.point(mergeFrame(), "TOPLEFT")
    assert.equal(m, trel)
    assert.equal(60, ty)
  end)

  it("puts the merged frame below the members even on the lowest strata", function()
    local r = add("R", 100, 980, { root = true, merged = function() return true end })
    add("M", 200, 980, { pos = { dockTo = "R", side = "Right", offset = 0 } }):SetFrameLevel(6)
    r:SetFrameStrata("BACKGROUND")
    r:SetFrameLevel(5)
    Dock.RefreshMerge("R")
    assert.equal(4, mergeFrame():GetFrameLevel())
  end)

  it("snaps a merged root to a free panel without a gap and docks it on drop", function()
    local r = add("R", 100, 980, { root = true, merged = function() return true end })
    add("P", 203, 980)
    local x = Dock.Snap("R")
    assert.equal(103, x)
    r.left = x
    Dock.Drop("R")
    assert.equal("R", saved.P.dockTo)
  end)

  it("ignores its own followers when snapping a member", function()
    add("Q", 100, 1039)
    add("P", 100, 980)
    add("N", 206, 980, { pos = { dockTo = "P", side = "Right", offset = 0 } })
    local _, y = Dock.Snap("P")
    assert.equal(97, y)
  end)

  it("keeps members docked when a collapsed root is dragged", function()
    add("R", 100, 980, { root = true, h = 20 })
    add("M", 206, 940, { pos = { dockTo = "R", side = "Right", offset = 40 } })
    Dock.Drop("R")
    assert.equal("R", saved.M.dockTo)
    assert.equal(40, saved.M.offset)
  end)

  it("keeps the merged frame when a panel registers again", function()
    local on = true
    local r = add("R", 100, 980, { root = true, merged = function() return on end })
    add("M", 200, 980, { pos = { dockTo = "R", side = "Right", offset = 0 } })
    Dock.RefreshMerge("R")
    on = false
    Dock.Register("R", { frame = r, root = true, get = function() return {} end, set = function() end,
      locked = function() return false end, merged = function() return false end })
    Dock.RefreshMerge("R")
    assert.is_false(mergeFrame():IsShown())
  end)

  it("does not undock in combat", function()
    add("R", 100, 980, { root = true })
    add("M", 206, 980, { pos = { dockTo = "R", side = "Right", offset = 0 } })
    stub.combat = true
    Dock.Undock("M")
    assert.equal("R", saved.M.dockTo)
  end)

  it("stops chain walks at a root with a stale dockTo", function()
    add("R", 100, 980, { root = true, pos = { dockTo = "M", side = "Right", offset = 0 } })
    local m = add("M", 0, 0, { pos = { dockTo = "R", side = "Right", offset = 0 } })
    assert.same({ "M" }, Dock.Members("R"))
    assert.same({}, Dock.Members("M"))
    Dock.Apply("M")
    assert.is_truthy(m.points)
  end)
end)
