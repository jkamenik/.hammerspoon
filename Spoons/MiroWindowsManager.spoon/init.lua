-- Copyright (c) 2018 Miro Mannino
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this
-- software and associated documentation files (the "Software"), to deal in the Software
-- without restriction, including without limitation the rights to use, copy, modify, merge,
-- publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
-- to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

--- === MiroWindowsManager ===
---
--- With this script you will be able to move the window in halves and in corners using your keyboard and mainly using arrows. You would also be able to resize them by thirds, quarters, or halves.
---
--- Official homepage for more info and documentation: [https://github.com/miromannino/miro-windows-manager](https://github.com/miromannino/miro-windows-manager)
---
--- Download: [https://github.com/miromannino/miro-windows-manager/raw/master/MiroWindowsManager.spoon.zip](https://github.com/miromannino/miro-windows-manager/raw/master/MiroWindowsManager.spoon.zip)
---

local obj={}
obj.__index = obj

-- Metadata
obj.name = "MiroWindowsManager"
obj.version = "1.1"
obj.author = "Miro Mannino <miro.mannino@gmail.com>"
obj.homepage = "https://github.com/miromannino/miro-windows-management"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- MiroWindowsManager.sizes
--- Variable
--- The sizes that the window can have.
--- The sizes are expressed as dividend of the entire screen's size.
--- For example `{2, 3, 3/2}` means that it can be 1/2, 1/3 and 2/3 of the total screen's size
obj.sizes = {2, 3, 3/2}

--- MiroWindowsManager.fullScreenSizes
--- Variable
--- The sizes that the window can have in full-screen.
--- The sizes are expressed as dividend of the entire screen's size.
--- For example `{1, 4/3, 2}` means that it can be 1/1 (hence full screen), 3/4 and 1/2 of the total screen's size
obj.fullScreenSizes = {1, 4/3, 2}

--- MiroWindowsManager.GRID
--- Variable
--- The screen's size using `hs.grid.setGrid()`
--- This parameter is used at the spoon's `:init()`
obj.GRID = {w = 24, h = 24}

obj._pressed = {
  up = false,
  down = false,
  left = false,
  right = false
}

function obj:_nextStep(dim, offs, cb)
  if hs.window.focusedWindow() then
    local axis = dim == 'w' and 'x' or 'y'
    local oppDim = dim == 'w' and 'h' or 'w'
    local oppAxis = dim == 'w' and 'y' or 'x'
    local win = hs.window.frontmostWindow()
    local id = win:id()
    local screen = win:screen()

    cell = hs.grid.get(win, screen)

    local nextSize = self.sizes[1]
    for i=1,#self.sizes do
      if cell[dim] == self.GRID[dim] / self.sizes[i] and
        (cell[axis] + (offs and cell[dim] or 0)) == (offs and self.GRID[dim] or 0)
        then
          nextSize = self.sizes[(i % #self.sizes) + 1]
        break
      end
    end

    cb(cell, nextSize)
    if cell[oppAxis] ~= 0 and cell[oppAxis] + cell[oppDim] ~= self.GRID[oppDim] then
      cell[oppDim] = self.GRID[oppDim]
      cell[oppAxis] = 0
    end

    hs.grid.set(win, cell, screen)
  end
end

function obj:_nextFullScreenStep()
  if hs.window.focusedWindow() then
    local win = hs.window.frontmostWindow()
    local id = win:id()
    local screen = win:screen()

    cell = hs.grid.get(win, screen)

    local nextSize = self.fullScreenSizes[1]
    for i=1,#self.fullScreenSizes do
      if cell.w == self.GRID.w / self.fullScreenSizes[i] and
         cell.h == self.GRID.h / self.fullScreenSizes[i] and
         cell.x == (self.GRID.w - self.GRID.w / self.fullScreenSizes[i]) / 2 and
         cell.y == (self.GRID.h - self.GRID.h / self.fullScreenSizes[i]) / 2 then
        nextSize = self.fullScreenSizes[(i % #self.fullScreenSizes) + 1]
        break
      end
    end

    cell.w = self.GRID.w / nextSize
    cell.h = self.GRID.h / nextSize
    cell.x = (self.GRID.w - self.GRID.w / nextSize) / 2
    cell.y = (self.GRID.h - self.GRID.h / nextSize) / 2

    hs.grid.set(win, cell, screen)
  end
end

obj._moveNextScreenBusy = false

-- Frames match when origin/size are within `tolerance` points (animation/rounding noise).
function obj:_framesRoughlyEqual(a, b, tolerance)
  tolerance = tolerance or 4
  return math.abs(a.x - b.x) <= tolerance
     and math.abs(a.y - b.y) <= tolerance
     and math.abs(a.w - b.w) <= tolerance
     and math.abs(a.h - b.h) <= tolerance
end

-- Ghostty/Supacode-style fullscreen: fills the display (under the menu bar) but is
-- NOT a Spaces fullscreen. Do not treat ordinary maximize (screen:frame) as fullscreen.
-- Moving via setFrame while in this mode leaves a ghost window on the old screen.
function obj:_isNonNativeFullScreen(win)
  if not win or win:isFullScreen() then return false end
  local screen = win:screen()
  if not screen then return false end
  return self:_framesRoughlyEqual(win:frame(), screen:fullFrame())
end

function obj:_windowStillFullScreen(win, mode)
  if not win then return false end
  if mode == "native" then
    return win:isFullScreen() == true
  end
  return self:_isNonNativeFullScreen(win)
end

-- Looser check used while waiting for re-enter (animation / visible-menu variants).
function obj:_looksEnteredFullScreen(win, mode)
  if not win then return false end
  if mode == "native" then
    return win:isFullScreen() == true
  end
  if win:isFullScreen() then return true end
  local screen = win:screen()
  if not screen then return false end
  local f = win:frame()
  local function covers(target)
    return f.w >= target.w * 0.95
       and f.h >= target.h * 0.95
       and math.abs(f.x - target.x) <= 24
       and math.abs(f.y - target.y) <= 24
  end
  return covers(screen:fullFrame()) or covers(screen:frame())
end

-- Only one shortcut per attempt. Sending both ⌃⌘F and fn+F can double-toggle
-- or mix native / non-native modes (common with Supacode / Ghostty).
function obj:_toggleFullScreenKeystroke(preferFn)
  if preferFn then
    hs.eventtap.keyStroke({"fn"}, "f", 0)
  else
    hs.eventtap.keyStroke({"ctrl", "cmd"}, "f", 0)
  end
end

function obj:_resolveWindow(id, fallback)
  return (id and hs.window.get(id)) or fallback
end

-- Exit native or non-native fullscreen, then call done(win).
-- Menus may show fn+F, but ⌃⌘F usually triggers the same Toggle Fullscreen action
-- and is far more reliable to synthesize than the Globe/fn key.
function obj:_exitFullScreenMode(win, mode, done)
  if not win then
    if done then done(nil) end
    return
  end

  local id = win:id()
  win:focus()

  if mode == "native" then
    win:setFullScreen(false)
  else
    self:_toggleFullScreenKeystroke(false)
  end

  local attempts = 0
  local maxAttempts = 24 -- ~3.6s
  local timer
  timer = hs.timer.doEvery(0.15, function()
    attempts = attempts + 1
    local current = self:_resolveWindow(id, win)

    if not self:_windowStillFullScreen(current, mode) then
      timer:stop()
      if done then done(current) end
      return
    end

    -- Escalating single-shortcut retries (never both at once).
    if attempts == 5 then
      if current then current:focus() end
      self:_toggleFullScreenKeystroke(false) -- ⌃⌘F
    elseif attempts == 10 then
      if current then current:focus() end
      self:_toggleFullScreenKeystroke(true) -- fn+F
    elseif attempts == 15 and mode == "native" then
      if current then
        current:focus()
        current:setFullScreen(false)
      end
    end

    if attempts >= maxAttempts then
      timer:stop()
      if done then done(current) end
    end
  end)
end

function obj:_focusWindowOnItsScreen(win)
  if not win then return end
  win:raise()
  win:focus()
  -- Moving the pointer onto the destination display helps macOS/app menu routing
  -- after moveToScreen (otherwise Toggle Fullscreen can target the old display).
  local f = win:frame()
  if f then
    hs.mouse.absolutePosition({x = f.x + f.w / 2, y = f.y + f.h / 2})
  end
end

function obj:_selectFullScreenMenuItem(win)
  local app = win and win:application()
  if not app then return false end

  local paths = {
    {"View", "Enter Full Screen"},
    {"View", "Toggle Full Screen"},
    {"View", "Toggle Fullscreen"},
    {"Window", "Enter Full Screen"},
    {"Window", "Full Screen"},
    {"Window", "Toggle Full Screen"},
    {"Window", "Toggle Fullscreen"},
  }
  for _, path in ipairs(paths) do
    if app:selectMenuItem(path) then return true end
  end

  -- Fuzzy match whatever the app labels the item (e.g. "Full Screen        fnF").
  if app:selectMenuItem("Enter Full Screen") then return true end
  if app:selectMenuItem("Toggle Full Screen") then return true end
  if app:selectMenuItem("Toggle Fullscreen") then return true end
  if app:selectMenuItem("Full Screen") then return true end
  return false
end

-- Enter fullscreen and keep trying until it sticks (or we give up).
-- Important: leave a long gap after each toggle. Re-sending ⌃⌘F during the
-- enter animation toggles fullscreen back OFF (the previous failure mode).
function obj:_enterFullScreenMode(win, mode, done)
  if not win then
    if done then done(false) end
    return
  end

  local id = win:id()
  self:_focusWindowOnItsScreen(win)

  if mode == "native" then
    win:setFullScreen(true)
  else
    self:_toggleFullScreenKeystroke(false)
  end

  -- Wait ~1.2s for the initial enter action before any retry (avoids double-toggle).
  local retryStep = 0
  local cooldown = 8
  local ticks = 0
  local maxTicks = 36 -- ~5.4s
  local timer
  timer = hs.timer.doEvery(0.15, function()
    ticks = ticks + 1
    local current = self:_resolveWindow(id, win)

    if self:_looksEnteredFullScreen(current, mode) then
      timer:stop()
      if done then done(true) end
      return
    end

    if cooldown > 0 then
      cooldown = cooldown - 1
    elseif current then
      self:_focusWindowOnItsScreen(current)
      retryStep = retryStep + 1
      if retryStep == 1 then
        self:_toggleFullScreenKeystroke(false) -- ⌃⌘F again
        cooldown = 8 -- ~1.2s
      elseif retryStep == 2 then
        self:_toggleFullScreenKeystroke(true) -- fn+F
        cooldown = 8
      elseif retryStep == 3 then
        self:_selectFullScreenMenuItem(current)
        cooldown = 8
      elseif retryStep == 4 then
        if mode == "native" then
          current:setFullScreen(true)
        else
          current:setFrame(current:screen():fullFrame(), 0)
        end
        cooldown = 4
      end
    end

    if ticks >= maxTicks then
      timer:stop()
      if done then done(self:_looksEnteredFullScreen(current, mode)) end
    end
  end)
end

function obj:_moveNextScreenStep()
  if self._moveNextScreenBusy then return end

  local win = hs.window.focusedWindow() or hs.window.frontmostWindow()
  if not win then return end

  local screen = win:screen()
  if not screen then return end
  local nextScreen = screen:next()
  if not nextScreen or nextScreen:id() == screen:id() then return end

  local id = win:id()
  local mode = nil
  if win:isFullScreen() then
    mode = "native"
  elseif self:_isNonNativeFullScreen(win) then
    mode = "nonnative"
  end

  local function relocate(current)
    current = current or self:_resolveWindow(id, win)
    if not current then return nil end
    -- Always move as a normal window. Do not setFrame(fullFrame) while still in
    -- non-native fullscreen — Ghostty leaves a remnant on the old screen.
    current:moveToScreen(nextScreen, false, true, 0)
    self:_focusWindowOnItsScreen(current)
    return current
  end

  if not mode then
    win:move(win:frame():toUnitRect(screen:frame()), nextScreen, true, 0)
    return
  end

  self._moveNextScreenBusy = true
  self:_exitFullScreenMode(win, mode, function(current)
    current = current or self:_resolveWindow(id, win)

    -- If we could not leave fullscreen, do not call move/setFrame — Ghostty
    -- force-exits mid-move and leaves a remnant window on the destination screen.
    if self:_windowStillFullScreen(current, mode) then
      hs.alert.show("Couldn't exit fullscreen — move aborted")
      self._moveNextScreenBusy = false
      return
    end

    current = relocate(current)
    -- Wait for the window to finish landing on the destination screen.
    hs.timer.doAfter(0.55, function()
      local landed = current or self:_resolveWindow(id, nil)
      if landed and landed:screen() and landed:screen():id() ~= nextScreen:id() then
        landed:moveToScreen(nextScreen, false, true, 0)
      end
      self:_enterFullScreenMode(landed or self:_resolveWindow(id, nil), mode, function(ok)
        if not ok then
          hs.alert.show("Moved, but couldn't re-enter fullscreen")
        end
        self._moveNextScreenBusy = false
      end)
    end)
  end)
end

function obj:_fullDimension(dim)
  if hs.window.focusedWindow() then
    local win = hs.window.frontmostWindow()
    local id = win:id()
    local screen = win:screen()
    cell = hs.grid.get(win, screen)

    if (dim == 'x') then
      cell = '0,0 ' .. self.GRID.w .. 'x' .. self.GRID.h
    else
      cell[dim] = self.GRID[dim]
      cell[dim == 'w' and 'x' or 'y'] = 0
    end

    hs.grid.set(win, cell, screen)
  end
end

--- MiroWindowsManager:bindHotkeys()
--- Method
--- Binds hotkeys for Miro's Windows Manager
--- Parameters:
---  * mapping - A table containing hotkey details for the following items:
---   * up: for the up action (usually {hyper, "up"})
---   * right: for the right action (usually {hyper, "right"})
---   * down: for the down action (usually {hyper, "down"})
---   * left: for the left action (usually {hyper, "left"})
---   * fullscreen: for the full-screen action (e.g. {hyper, "f"})
---   * nextscreen: for the multi monitor next screen action (e.g. {hyper, "n"})
---
--- A configuration example can be:
--- ```
--- local hyper = {"ctrl", "alt", "cmd"}
--- spoon.MiroWindowsManager:bindHotkeys({
---   up = {hyper, "up"},
---   right = {hyper, "right"},
---   down = {hyper, "down"},
---   left = {hyper, "left"},
---   fullscreen = {hyper, "f"}
---   nextscreen = {hyper, "n"}
--- })
--- ```
function obj:bindHotkeys(mapping)
  hs.inspect(mapping)
  print("Bind Hotkeys for Miro's Windows Manager")

  hs.hotkey.bind(mapping.down[1], mapping.down[2], function ()
    self._pressed.down = true
    if self._pressed.up then
      self:_fullDimension('h')
    else
      self:_nextStep('h', true, function (cell, nextSize)
        cell.y = self.GRID.h - self.GRID.h / nextSize
        cell.h = self.GRID.h / nextSize
      end)
    end
  end, function ()
    self._pressed.down = false
  end)

  hs.hotkey.bind(mapping.right[1], mapping.right[2], function ()
    self._pressed.right = true
    if self._pressed.left then
      self:_fullDimension('w')
    else
      self:_nextStep('w', true, function (cell, nextSize)
        cell.x = self.GRID.w - self.GRID.w / nextSize
        cell.w = self.GRID.w / nextSize
      end)
    end
  end, function ()
    self._pressed.right = false
  end)

  hs.hotkey.bind(mapping.left[1], mapping.left[2], function ()
    self._pressed.left = true
    if self._pressed.right then
      self:_fullDimension('w')
    else
      self:_nextStep('w', false, function (cell, nextSize)
        cell.x = 0
        cell.w = self.GRID.w / nextSize
      end)
    end
  end, function ()
    self._pressed.left = false
  end)

  hs.hotkey.bind(mapping.up[1], mapping.up[2], function ()
    self._pressed.up = true
    if self._pressed.down then
        self:_fullDimension('h')
    else
      self:_nextStep('h', false, function (cell, nextSize)
        cell.y = 0
        cell.h = self.GRID.h / nextSize
      end)
    end
  end, function ()
    self._pressed.up = false
  end)

  hs.hotkey.bind(mapping.fullscreen[1], mapping.fullscreen[2], function ()
    self:_nextFullScreenStep()
  end)

  hs.hotkey.bind(mapping.nextscreen[1], mapping.nextscreen[2], function ()
    self:_moveNextScreenStep()
  end)

end

function obj:init()
  print("Initializing Miro's Windows Manager")
  hs.grid.setGrid(obj.GRID.w .. 'x' .. obj.GRID.h)
  hs.grid.MARGINX = 0
  hs.grid.MARGINY = 0
end

return obj
