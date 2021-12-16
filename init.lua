local rc = hs.loadSpoon("ReloadConfiguration")
rc:start()

-- local pp = hs.loadSpoon("PrettyPrint")
-- x = { "this", "that"}
-- print(x)
-- print(pp.stringify(x))

-- Create a menu bar
menu       = hs.menubar.new()
menuItems = {}

globals   = require("globals")
utils     = require("utils")
local layouts   = require("layouts")
local startwork = require("startwork")

menu:setMenu(menuItems)

hs.alert.show("Hammerspoon Config loaded")
