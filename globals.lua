-- Do any gloabal things here
menu:setTitle('⚒')


-- Setup the globals
local Globals = {}

Globals.apps = {}
Globals.timers = {}

-- Preferred Apps
Globals.apps.mail = "Mail"
-- Globals.apps.mail = "Microsoft Outlook"
Globals.apps.editor  = "Atom"
Globals.apps.term    = "iTerm"
Globals.apps.browser = "Firefox"
Globals.apps.meeting = "Amazon Chime"

Globals.apps.todo              = {}
Globals.apps.todo.app_name     = "Things3"
Globals.apps.todo.running_name = "Things"

Globals.apps.messenger          = {}
Globals.apps.messenger.personal = "Messages"
Globals.apps.messenger.work     = "Slack"



-- ### Screen sizes ####
Globals.screen_size = {}
Globals.screen_size.full = 1.0
-- Slightly less then half to account for window padding
Globals.screen_size.half = 0.498

-- Mid is the starting point mid-way down or mid-way accross
Globals.screen_pos = {}
Globals.screen_pos.start = 0   -- Top left
Globals.screen_pos.mid   = 0.5 -- Mid way down, or accross

return Globals
