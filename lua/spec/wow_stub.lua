-- Copyright (c) 2026 AqueGen. All rights reserved. See LICENSE.
local stub = { created = {} }
_G.strmatch = string.match

local Region = {}
Region.__index = Region

local function region(kind, parent)
  return setmetatable({ kind = kind, parent = parent, shown = true, alpha = 1, enabled = true, w = 0, h = 0,
    scripts = {}, children = {} }, Region)
end
stub.region = region

function Region:GetObjectType() return self.kind end
function Region:GetParent() return self.parent end
function Region:Show() self.shown = true end
function Region:Hide() self.shown = false end
function Region:IsShown() return self.shown end
function Region:SetShown(shown) self.shown = not not shown end
function Region:SetSize(w, h) self.w, self.h = w, h end
function Region:SetWidth(w) self.w = w end
function Region:SetHeight(h) self.h = h end
function Region:GetWidth() return self.w end
function Region:GetHeight() return self.h end
function Region:GetSize() return self.w, self.h end
function Region:ClearAllPoints() self.points = {} end
function Region:SetPoint(point, rel, relPoint, x, y)
  self.points = self.points or {}
  if type(rel) == "number" then rel, relPoint, x, y = nil, nil, rel, relPoint end
  self.points[#self.points + 1] = { point, rel, relPoint, x or 0, y or 0 }
end
function Region:SetAllPoints(rel) self.points = { { "ALL", rel or self.parent } } end
function Region:GetPoint(i) return unpack(self.points[i or 1]) end
function Region:SetAlpha(a) self.alpha = a end
function Region:GetAlpha() return self.alpha end
function Region:SetScript(name, fn) self.scripts[name] = fn end
function Region:GetScript(name) return self.scripts[name] end
function Region:HookScript(name, fn)
  local old = self.scripts[name]
  self.scripts[name] = function(...) if old then old(...) end fn(...) end
end
function Region:EnableMouse(on) self.mouse = on end
function Region:SetFrameLevel(level) self.level = level end
function Region:GetFrameLevel() return self.level or 1 end
function Region:SetHitRectInsets(...) self.hitInsets = { ... } end
function Region:SetMotionScriptsWhileDisabled(on) self.motionWhileDisabled = on end

function Region:SetColorTexture(r, g, b, a) self.color = { r, g, b, a } end
function Region:SetTexture(path) self.texture = path end
function Region:SetVertexColor(r, g, b, a) self.vertex = { r, g, b, a } end
function Region:SetDesaturated(on) self.desaturated = on end
function Region:SetGradient(orientation, from, to) self.gradient = { orientation, from, to } end
function Region:SetBlendMode(mode) self.blend = mode end

function Region:SetBackdrop(backdrop) self.backdrop = backdrop end
function Region:GetBackdrop() return self.backdrop end
function Region:SetBackdropColor(r, g, b, a) self.backdropColor = { r, g, b, a } end
function Region:SetBackdropBorderColor(r, g, b, a) self.backdropBorder = { r, g, b, a } end

function Region:SetText(text)
  if self.fontString then return self.fontString:SetText(text) end
  self.text = text
end
function Region:GetText() return self.fontString and self.fontString:GetText() or self.text end
function Region:SetTextColor(r, g, b, a) self.textColor = { r, g, b, a } end
function Region:SetFont(...) self.font = { ... } end
function Region:SetJustifyH(j) self.justifyH = j end
function Region:GetStringWidth() return #(self.text or "") * 6 end
function Region:SetFontString(fs) self.fontString = fs end
function Region:GetFontString() return self.fontString end

function Region:Enable() self.enabled = true end
function Region:Disable() self.enabled = false end
function Region:IsEnabled() return self.enabled end
function Region:SetEnabled(on) self.enabled = not not on end

function Region:SetChecked(on) self.checked = not not on end
function Region:GetChecked() return self.checked end
function Region:SetCheckedTexture(t) self.checkedTexture = t end
function Region:GetCheckedTexture() return self.checkedTexture end
function Region:SetHighlightTexture(t) self.highlightTexture = t end
function Region:GetHighlightTexture() return self.highlightTexture end
function Region:SetNormalTexture(t) self.normalTexture = t end

-- Like the client: a new range clamps the current value and reports the change.
function Region:SetMinMaxValues(lo, hi)
  self.min, self.max = lo, hi
  local v = self.value or 0
  local clamped = math.max(lo, math.min(hi, v))
  if clamped ~= v then self:SetValue(clamped) end
end
function Region:GetMinMaxValues() return self.min, self.max end
function Region:SetValueStep(step) self.step = step end
function Region:SetObeyStepOnDrag(on) self.obey = on end
function Region:SetOrientation(o) self.orientation = o end
function Region:SetThumbTexture(t) self.thumb = t end
function Region:GetThumbTexture() return self.thumb end
function Region:SetValue(v)
  self.value = v
  local fn = self.scripts.OnValueChanged
  if fn then fn(self, v, true) end
end
function Region:GetValue() return self.value end

-- Mimics the client: a disabled Button or CheckButton ignores clicks; a CheckButton flips before OnClick.
function Region:Click(button)
  if not self.enabled then return end
  if self.kind == "CheckButton" then self.checked = not self.checked end
  local fn = self.scripts.OnClick
  if fn then fn(self, button or "LeftButton", true) end
  fn = self.scripts.PostClick
  if fn then fn(self, button or "LeftButton", true) end
end

local function child(self, kind, layer)
  local r = region(kind, self)
  r.layer = layer
  self.children[#self.children + 1] = r
  return r
end
function Region:CreateTexture(_, layer) return child(self, "Texture", layer) end
function Region:CreateFontString(_, layer) return child(self, "FontString", layer) end

function CreateFrame(kind, name, parent, template)
  local f = region(kind, parent)
  f.name, f.template = name, template
  if parent then parent.children[#parent.children + 1] = f end
  stub.created[#stub.created + 1] = f
  if name then _G[name] = f end
  return f
end

function CreateColor(r, g, b, a) return { r = r, g = g, b = b, a = a } end

UIParent = region("Frame")
GameTooltip = region("GameTooltip")

function stub.reset() stub.created = {} end

return stub
