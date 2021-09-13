local logger = hs.logger.new("startwork",'info')

local humanTime = "10:50:00"
local earliest  = hs.timer.seconds(humanTime)

function open(args)
  local command = "open " .. args
  logger:i(command)
  hs.execute(command)
end

function start_work()
  local start = hs.application.launchOrFocus

  -- Start all the critical apps
  start(globals.apps.editor)
  start(globals.apps.browser)
  start(globals.apps.todo.app_name)
  start(globals.apps.calendar)
  start(globals.apps.messenger.personal)
  start(globals.apps.messenger.personal1)
  start(globals.apps.messenger.work)
  start(globals.apps.listening)

  -- critical bookmarks
  open("https://github.com/pulls/review-requested")
  open("https://madvantage.atlassian.net/secure/RapidBoard.jspa?rapidView=129&assignee=60ee1fbef314ff006a5669e5")

  -- Get the current date as a table
  date = os.date("*t")
  logger.f("%s-%s-%s %s:%s:%s", date.year, date.month, date.day, date.hour, date.min, date.sec)
  if date.hour < 9 then
    hs.alert.show("Before 9am, starting only critical apps")
  else
    hs.alert.show("After 9am, starting non-critical apps")
    start(globals.app.notes)
    start(globals.app.messenger.work1)
  end
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", start_work)
table.insert(menuItems, {title = "Start Work Applications\t\t⌘⌥⌃S", fn = start_work })
