local logger = hs.logger.new("startwork",'info')

local humanTime = "10:50:00"
local earliest  = hs.timer.seconds(humanTime)

function open(args)
  local command = "open " .. args
  logger:i(command)
  hs.execute(command)
end

function clearTimers()
  -- Clean any older timers
  if globals.timers.startWork then
    printf("Stopping startWork timer: %s",globals.timers.startWork)
    globals.timers.startWork:stop()
  end

  if globals.timers.startWorkMenu then
    print("Stopping startWorkMenu timer, %s", globals.timers.startWorkMenu)
    globals.timers.startWorkMenu:stop()
  end
end

-- The following are apps that, if started with everything else cause
-- distraction
function start_delayed_apps()
  print("-- starting delayed apps --")
  local start = hs.application.launchOrFocus

  clearTimers()

  start(globals.apps.mail)

  remove_delay_menu()
end

local delayedAppsMenuTitleFormat = "Start Delayed Apps Now (will start in %s at %s)"
local delayedAppsMenu = {
  title = "placeholder",
  fn    = start_delayed_apps
}
function delayedAppsMenu:updateTitle(s)
  self.title = string.format(delayedAppsMenuTitleFormat, humanSeconds(s), humanTime)
end

function remove_delay_menu()
  printf("Delay menu item %s", delayedAppsMenu)
  for k, v in pairs(menuItems) do
    printf("%s - %s", k, v)
    if v == delayedAppsMenu then
      printf("Removing %d menu item",k)
      table.remove(menuItems,k)
    end
  end
  menu:setMenu(menuItems)
end

function calculateCountdown()
  print("menu time function")
  local currentTime = hs.timer.localTime()

  delayedAppsMenu:updateTitle(earliest - currentTime)
  menu:setMenu(menuItems)
end

function start_work()
  local start = hs.application.launchOrFocus

  start(globals.apps.messenger.personal)
  start(globals.apps.messenger.work)
  start(globals.apps.browser)
  start(globals.apps.todo.app_name)
  start(globals.apps.calendar)
  start(globals.apps.meeting)
  start(globals.apps.term)
  start(globals.apps.editor)

  -- Jira to CRPI with "DevOps" filter selected.  Double escape the '\' so that '&' is escaped when sending to the terminal.
  -- open("https://opaqnetworks.atlassian.net/secure/RapidBoard.jspa?rapidView=35\\&quickFilter=99")

  -- Jira DevOps Kanban baord spanning multiple projects.
  open("https://opaqnetworks.atlassian.net/secure/RapidBoard.jspa?rapidView=49\\&selectedIssue=CRPI-7532\\&quickFilter=134")
  
  -- Bitbucket PR list
  open("https://bitbucket.org/dashboard/overview")

  -- Jira DSO main board.
  -- open("https://opaqnetworks.atlassian.net/secure/RapidBoard.jspa?rapidView=56")

  -- Now do some math, to figure out when to start delayed apps
  print("--- Delay logic ---")
  local currentTime = hs.timer.localTime()

  clearTimers()

  if currentTime >= earliest then
    print("After " .. humanTime)
    start_delayed_apps()
  else
    print("Before earliest")
    local timer = hs.timer.doAt(earliest, start_delayed_apps)
    globals.timers.startWork = timer
    printf("delayed app timer: %s", timer)

    timer = hs.timer.doEvery(1, calculateCountdown)
    globals.timers.startWorkMenu = timer
    printf("menu timer: %s", timer)

    print("Adding menu Items")
    table.insert(menuItems, delayedAppsMenu)
    menu:setMenu(menuItems)

    local message = string.format("Delayed app will start after %s (%s)",humanTime, humanSeconds(earliest-currentTime))
    print(message)
    hs.alert.show(message)
  end
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", start_work)
table.insert(menuItems, {title = "Start Work Applications\t\t⌘⌥⌃S", fn = start_work })
