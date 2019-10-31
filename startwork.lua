local logger = hs.logger.new("startwork",'info')

local humanTime = "11:00:00"
local earliest  = hs.timer.seconds(humanTime)

function open(args)
  local command = "open " .. args
  logger:i(command)
  hs.execute(command)
end

-- The following are apps that, if started with everything else cause
-- distraction
function start_delayed_apps()
  print("-- starting delayed apps --")
  local start = hs.application.launchOrFocus

  -- Clean any older timers
  if globals.timers.startWork then
    print("Stopping existing timer")
    globals.timers.startWork:stop()
  end

  start(globals.apps.mail)

  remove_delay_menu()
end

local delayedAppsMenu = {
  title = "Start Delayed Apps Now (will start at "..humanTime..")",
  fn    = start_delayed_apps
}
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

function start_work()
  local start = hs.application.launchOrFocus

  start(globals.apps.messenger.personal)
  start(globals.apps.messenger.work)
  start(globals.apps.browser)
  start(globals.apps.todo.app_name)
  start(globals.apps.meeting)
  start(globals.apps.term)
  start(globals.apps.editor)

  -- Jira to CRPI with "DevOps" filter selected.  Double escape the '\' so that '&' is escaped when sending to the terminal.
  -- open("https://opaqnetworks.atlassian.net/secure/RapidBoard.jspa?rapidView=35\\&quickFilter=99")

  -- Jira DevOps Kanban baord spanning multiple projects.
  open("https://opaqnetworks.atlassian.net/secure/RapidBoard.jspa?rapidView=49\\&selectedIssue=CRPI-7532\\&quickFilter=134")

  -- Jira DSO main board.
  -- open("https://opaqnetworks.atlassian.net/secure/RapidBoard.jspa?rapidView=56")

  -- Now do some math, to figure out when to start delayed apps
  print("--- Delay logic ---")
  local currentTime = hs.timer.localTime()

  -- Clean any older timers
  if globals.timers.startWork then
    print("Stopping existing timer")
    globals.timers.startWork:stop()
  end

  if currentTime >= earliest then
    print("After " .. humanTime)
    start_delayed_apps()
  else
    print("Before earliest")
    local timer = hs.timer.doAt(earliest, start_delayed_apps)
    globals.timers.startWork = timer
    print(timer)

    print("Adding menu Items")
    table.insert(menuItems, delayedAppsMenu)
    menu:setMenu(menuItems)

    local message = string.format("Delayed app will start after %s (approx. %ds)",humanTime, (earliest-currentTime))
    print(message)
    hs.alert.show(message)
  end
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", start_work)
table.insert(menuItems, {title = "Start Work Applications\t\t⌘⌥⌃S", fn = start_work })
