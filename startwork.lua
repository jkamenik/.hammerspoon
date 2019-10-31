local logger = hs.logger.new("startwork",'info')

function open(args)
  local command = "open " .. args
  logger:i(command)
  hs.execute(command)
end

-- The following are apps that, if started with everything else cause
-- distraction
function start_delayed_apps()
  local start = hs.application.launchOrFocus

  start(globals.apps.mail)
end

function start_work()
  local start = hs.application.launchOrFocus

  start(globals.apps.messenger.personal)
  start(globals.apps.messenger.work)
  start(globals.apps.browser)
  start(globals.apps.todo.app_name)
  start(globals.apps.meeting)

  -- Jira to CRPI with "DevOps" filter selected.  Double escape the '\' so that '&' is escaped when sending to the terminal.
  -- open("https://opaqnetworks.atlassian.net/secure/RapidBoard.jspa?rapidView=35\\&quickFilter=99")

  -- Jira DevOps Kanban baord spanning multiple projects.
  open("https://opaqnetworks.atlassian.net/secure/RapidBoard.jspa?rapidView=49\\&selectedIssue=CRPI-7532\\&quickFilter=134")

  -- Jira DSO main board.
  -- open("https://opaqnetworks.atlassian.net/secure/RapidBoard.jspa?rapidView=56")

  -- Now do some math, to figure out when to start delayed apps
  print("--- Delay logic ---")
  -- local humanTime   = "09:00:00"
  local humanTime   = "09:00:00"
  local earliest    = hs.timer.seconds(humanTime)
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

    local message = string.format("Delayed app will start after %s (approx. %ds)",humanTime, (earliest-currentTime))
    print(message)
    hs.alert.show(message)
  end
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", start_work)
table.insert(menuItems, {title = "Start Work Applications\t\t⌘⌥⌃S", fn = start_work })
