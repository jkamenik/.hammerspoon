function open(args)
  hs.execute("open " .. args)
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
  
  -- Jira to CRPI with "DevOps" filter selected.
  open("https://opaqnetworks.atlassian.net/secure/RapidBoard.jspa?rapidView=35&projectKey=CRPI&view=detail&quickFilter=99")
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", start_work)
table.insert(menuItems, {title = "Start Work Applications\t\tcmd+alt+ctrl+S", fn = start_work })
