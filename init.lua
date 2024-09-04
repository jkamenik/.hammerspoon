local rc = hs.loadSpoon("ReloadConfiguration")
rc:start()

-- local pp = hs.loadSpoon("PrettyPrint")
-- x = { "this", "that"}
-- print(x)
-- print(pp.stringify(x))

-- Load the windows manager
local hyper = {"ctrl", "alt", "cmd"}
hs.loadSpoon("MiroWindowsManager")

hs.window.animationDuration = 0.3
spoon.MiroWindowsManager.sizes = {1, 3/2, 2, 3} -- in 1/X units
spoon.MiroWindowsManager:bindHotkeys({
  up = {hyper, "up"},
  right = {hyper, "right"},
  down = {hyper, "down"},
  left = {hyper, "left"},
  fullscreen = {hyper, "f"},
  nextscreen = {hyper, "n"}
})

-- load Emojis
hs.loadSpoon("Emojis")
spoon.Emojis:bindHotkeys({
  toggle = {hyper, "e"}
})


-- Create a menu bar
menu       = hs.menubar.new()
menuItems = {}

globals   = require("globals")
utils     = require("utils")
local layouts   = require("layouts")
local startwork = require("startwork")

menu:setMenu(menuItems)

hs.alert.show("Hammerspoon Config loaded")
