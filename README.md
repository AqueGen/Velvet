# Velvet

The shared look of the settings windows in AqueGen's World of Warcraft addons: colour tokens and a few flat controls, shipped as an embedded LibStub library (`LibVelvet-1.0`).

All rights reserved - see LICENSE.

## Embedding

1. Copy the library into the addon: `pwsh tools/sync.ps1 -Target <addon root>` replaces `<addon root>/Libs/LibVelvet-1.0`.
2. List `Libs\LibVelvet-1.0\lib.xml` in the TOC before the addon's own UI files.
3. `local UI = LibStub("LibVelvet-1.0")`.

Several addons can embed it; LibStub keeps the newest copy, so an addon with an older copy runs on the newest code. Changes are additive only, and every release bumps `MINOR` in `Core.lua`.

## API

- `UI.T` - colour tokens `{ r, g, b[, a] }`: bg, panel, border, control, divider, segfill, selected, navSelected, selLabel, underline, title, gold, text, muted, hover, track, trackFill, thumb, well, wellOn, tick. `UI.HEADER` = menu header colour. `UI.FLAT` = flat backdrop. `UI.GAP`, `UI.PAD` = row gap and group padding.
- `UI.Button(parent, text, width, primary)` - flat 22-high button; `button.label`. `UI.SetPrimary(button, on)`.
- `UI.PaintGroup(box, title)` - paints a group box and its title; returns the fading rule under the title.
- `UI.NavEntry(parent, text, width, height)` and `UI.PaintNav(entry, "selected" | "normal" | "muted")` - side menu entries.
- `UI.Segments(parent, options, width, height, onSelect)` - `options = { { text, value }, ... }`; `set:Select(value)` paints without calling `onSelect`; `set:SetOff(off)`; `set.buttons`.
- `UI.Slider(parent, width)` - `slider:Setup(min, max, step)`, `slider:SetValue(value, silent)` (clamps and snaps), `slider:GetValue()`, `slider:SetEnabled(on)`, `slider.onChange = function(value) end`.
- `UI.Checkbox(parent, size)` - a CheckButton with the native API; it repaints from `PostClick`, so callers keep `OnClick` and leave `PostClick` alone.
- `UI.PreviewLayout(contentW, columnMin, zoneMin, zoneMax)` - `{ mode = "side" | "band", columnW, zoneW }`: the preview zone sits beside the settings column when both fit, otherwise it becomes a band above the column.
- `UI.FitScale(w, h, availW, availH)` - the scale that fits `w` x `h` into the space, never above 1.
- `UI.PreviewPane(parent)` - a pane with `.caption`, a clipped `.stage` over a fake game-world strip, and `.offLine`; `pane:SetCaption(text)`, `pane:SetOff(text)` (nil turns it back on), `pane:Fit(content, w, h)`.

## Tests

`busted` from `lua/` (Lua 5.1). On this machine: `MSYS_NO_PATHCONV=1 wsl bash -lc 'bash /mnt/g/Games/Velvet/tools/busted.sh'`.
