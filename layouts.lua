function tablelength(T)
   local count = 0
   for _ in pairs(T) do count = count + 1 end
   return count
end

function layout_message_apps()
   print('layout message apps')

   local full = 1.0
   local half = 0.498
   local mid  = 0.5

   local screens = tablelength(hs.screen.allScreens())
   local screen  = hs.screen.mainScreen() -- the one with the mouse
   local layout  = {}

   if screens == 1 then
      -- Only one screen so split them full width but 1/2 height
      print("only 1 screen")
      layout = {
         -- Outlook and Slack together, HipChat has a min size >half
         {globals.apps.mail,  nil, screen, {x=0,y=0,  w=full,h=half},   nil, nil},
         {globals.apps.messenger.work,    nil, screen, {x=0,y=.52,w=full,h=0.48},  nil, nil},
         -- Messages and Things together
         {globals.apps.messenger.personal, nil, screen, {x=0,y=0,  w=full,h=half}, nil, nil},
         {globals.apps.todo.running_name, nil, screen, {x=0,y=mid,w=full,h=half},  nil, nil},
      }
   else
      -- Many screens, one should be large enough to show all
      layout = {
         -- HipChat and Slack at the top
         {globals.apps.mail,  nil, screen, {x=0,  y=0,w=half,h=half},   nil, nil},
         {globals.apps.messenger.work,    nil, screen, {x=mid,y=0,w=half,h=half},  nil, nil},
         -- Messages and Things at the bottom
         {globals.apps.messenger.personal, nil, screen, {x=0,y=mid,w=half,h=half}, nil, nil},
         {globals.apps.todo.running_name, nil, screen, {x=mid,y=mid,w=half,h=half},  nil, nil},
      }

   end

   hs.layout.apply(layout)
end

function layout_work_apps()
   print('layout work apps')

   local screen = hs.screen.mainScreen()
   local layout = {
      {"Emacs",  nil, screen, {x=0,y=0,w=.498,h=1},  nil,nil},
      {"iTerm2", nil, screen, {x=.5,y=0,w=.498,h=1}, nil,nil}
   }
   hs.layout.apply(layout)
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "L", layout_message_apps)
table.insert(menuItems, {title = "Layout Messaging Apps\t\tcmd+alt+ctrl+L", fn = layout_message_apps })

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", layout_work_apps)
table.insert(menuItems, {title = "Layout Works Apps\t\t\tcmd+alt+ctrl+W", fn = layout_work_apps })
