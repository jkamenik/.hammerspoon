function reloadConfig(files)
   doReload = false
   for _,file in pairs(files) do
      if file:sub(-4) == ".lua" then
         doReload = true
      end
   end
   if doReload then
      hs.reload()
   end
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

-- Create a menu bar
menu       = hs.menubar.new()
menuItems = {}

globals   = require("globals")
local layouts   = require("layouts")
local startwork = require("startwork")

menu:setMenu(menuItems)


hs.alert.show("Hammerspoon Config loaded")
