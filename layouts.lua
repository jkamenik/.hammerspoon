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

   local screens = tablelength(hs.screen.allScreens())
   local screen  = findScreenByPosition(1,-1) -- Upper right
   local layout  = {}

   if screens == 1 then
      -- Only one screen so split them full width but 1/2 height
      print("only 1 screen")
      layout = {
         -- Top Half
         {globals.apps.mail,  nil, screen, {x=0,y=0,  w=full,h=half},   nil, nil},
         {globals.apps.messenger.work,    nil, screen, {x=0,y=.52,w=full,h=0.48},  nil, nil},
         {globals.apps.messenger.work1,    nil, screen, {x=0,y=.52,w=full,h=0.48},  nil, nil},
         -- Bottom Half
         {globals.apps.messenger.personal, nil, screen, {x=0,y=0,  w=full,h=half}, nil, nil},
         {globals.apps.todo.running_name, nil, screen, {x=0,y=mid,w=full,h=half},  nil, nil},
      } 
   else
      -- Many screens, one should be large enough to show all
      layout = {
         -- Mail, Zoom, MS Teams, and Slack at the top, w/ Zoom, mail, and teams stacked
         {globals.apps.messenger.work,     nil, screen, {x=mid,y=0,w=half,h=half},  nil, nil},
         {globals.apps.messenger.personal, nil, screen, {x=0,  y=0,w=half,h=half}, nil, nil},
         {globals.apps.mail,               nil, screen, {x=0,  y=0,w=half,h=half},   nil, nil},
         {globals.apps.meeting,            nil, screen, {x=0,  y=0,w=half,h=half},   nil, nil},
         -- Messages and Things at the bottom
         {globals.apps.messenger.personal1, nil, screen, {x=0,y=mid,w=half,h=half},  nil, nil},
         {globals.apps.calendar,            nil, screen, {x=0,y=mid,w=half,h=half}, nil, nil},
         {globals.apps.todo.running_name,   nil, screen, {x=mid,y=mid,w=half,h=half},  nil, nil},
         {globals.apps.messenger.work1,     nil, screen, {x=mid,y=mid,w=half,h=half},  nil, nil},
      }

   end

   hs.layout.apply(layout)
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "L", layout_message_apps)
table.insert(menuItems, {title = "Layout Messaging Apps\t\t⌘⌥⌃L", fn = layout_message_apps })
