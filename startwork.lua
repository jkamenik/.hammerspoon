local logger = hs.logger.new("startwork",'info')

function open(args)
  local command = "open " .. args
  logger:i(command)
  hs.execute(command)
end

function start_work()
  local start = hs.application.launchOrFocus
  
  start("Messages")
  --  start("WhatsApp")
  start("Microsoft Outlook")
  -- start("Microsoft Teams")
  -- start("HipChat")
  start("Slack")
  start("Google Chrome")
  start("Things3")
  -- start("Atom")
  -- start("iTerm")
  
  -- Jira to CRPI with "DevOps" filter selected.  Double escape the '\' so that '&' is escaped when sending to the terminal. 
  open("https://opaqnetworks.atlassian.net/secure/RapidBoard.jspa?rapidView=35\\&quickFilter=99")
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", start_work)
table.insert(menuItems, {title = "Start Work Applications\t\tcmd+alt+ctrl+S", fn = start_work })
