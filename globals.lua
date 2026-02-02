-- Do any gloabal things here
menu:setTitle('⚒')


-- Setup the globals
local Globals = {}

Globals.apps = {}
Globals.timers = {}

-- Preferred Apps
Globals.apps.selector = "Alfred 5"
Globals.apps.mail = "Mail"
-- Globals.apps.mail = "Microsoft Outlook"
Globals.apps.editor  = "Visual Studio Code"
Globals.apps.term    = "iTerm"
Globals.apps.browser = "Safari"
Globals.apps.meeting = "zoom.us"
Globals.apps.notes   = "Obsidian"

Globals.apps.todo              = {}
Globals.apps.todo.app_name     = "Reminders"
Globals.apps.todo.running_name = "Reminders"

Globals.apps.messenger          = {}
Globals.apps.messenger.personal = "Messages"
Globals.apps.messenger.personal1 = "Skype"
Globals.apps.messenger.work     = "Slack"
Globals.apps.messenger.work1    = "Microsoft Teams"

Globals.apps.listening = "Podcasts"

Globals.apps.calendar = "Calendar"

Globals.apps.containers = "Docker"


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
