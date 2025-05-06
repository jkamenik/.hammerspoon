function tablelength(T)
   local count = 0
   for _ in pairs(T) do count = count + 1 end
   return count
end

function screenDetails(screen)
   local details = string.format(
      "UUID: %s\nid: %s\nname: %s\nposition: %d, %d",
      screen:getUUID(),
      screen:id(),
      screen:name(),
      screen:position()
   )

   return details
end

--- findScreenByPosition(x, y)
--- Method
--- Find a screen by position (relative to the primary screen).
---
--- 0, 0 = Primary screen
--- Positive x = to the right of the Primary
--- Negative x = to the left
--- Positive y = below the primary screen
--- Negative y = above
---
--- If no screen is found then hs.screen.mainScreen() is returned
---
--- Parameters:
---  * x - The x position of the screen
---  * y - The y position of the screen
function findScreenByPosition(x, y)
   -- if a better screen cannot be found then use main
   local screen  = hs.screen.mainScreen()

   for idx, s in ipairs(hs.screen.allScreens()) do
      sx, sy = s:position()
      print(string.format(
         "looking for %d x %d\nfound %d x %d",
         x, y,
         sx, sy
      ))

      if x == sx and y == sy then
         print("screen found")
         screen = s
      end
   end

   return screen
end

function layout_message_apps()
   print('layout message apps')

   local full = 1.0
   local half = 0.498
   local mid  = 0.5
   local firstThird = 1 / 3
   local twoThirds  = 2 / 3

   local screens = tablelength(hs.screen.allScreens())
   local screen  = findScreenByPosition(1,-1) -- Upper right
   local layout  = {}

   local frame = screen:frame()

   print(screen)
   print(screen:frame())
   print("size x ", frame.w)
   print("size y ", frame.h)

   -- 2025-05-06 14:20:18: size x 	1800.0
   -- 2025-05-06 14:20:18: size y 	1125.0

   if frame.w <= 1800 then
      -- Small screen, stack
      print("only 1 screen")
      layout = {
         {globals.apps.messenger.personal,nil, screen, {x=0,         y=0,         w=twoThirds,h=twoThirds}, nil, nil},
         {globals.apps.messenger.work,    nil, screen, {x=firstThird,y=0,         w=twoThirds,h=twoThirds},  nil, nil},
         {globals.apps.calendar,          nil, screen, {x=0,         y=firstThird,w=twoThirds,h=twoThirds}, nil, nil},
         {globals.apps.todo.running_name, nil, screen, {x=firstThird,y=firstThird,w=twoThirds,h=twoThirds},  nil, nil},
      }
   else
      -- Large screen should be able to show them all
      layout = {
         ------ TOP ------
         ---- Right ----
         {globals.apps.messenger.personal, nil, screen, {x=0,  y=0,w=half,h=half}, nil, nil},
         ---- Left ----
         {globals.apps.messenger.work,     nil, screen, {x=mid,y=0,w=half,h=half},  nil, nil},

         ------ BOTTOM (Important) -----
         ---- Right ----
         {globals.apps.calendar,            nil, screen, {x=0,y=mid,w=half,h=half}, nil, nil},
         ---- Left ----
         {globals.apps.todo.running_name,   nil, screen, {x=mid,y=mid,w=half,h=half},  nil, nil},
      }

   end

   hs.layout.apply(layout)

   focus_important_apps()
end

function focus_important_apps()
   print("Focusing Important Apps")

   important = {
      globals.apps.messenger.personal,
      globals.apps.messenger.work,
      globals.apps.calendar,
      globals.apps.todo.running_name,
   }

   for x = 1, #important do
      appName = important[x]
      app = hs.application.find(appName)

      print("Important App: ", appName, app)

      if app == nil then
         print(appName, "is not open, skipping")
      else
         app:activate(true)
      end
   end
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "L", layout_message_apps)
table.insert(menuItems, {title = "Layout Messaging Apps\t\t⌘⌥⌃L", fn = layout_message_apps })
