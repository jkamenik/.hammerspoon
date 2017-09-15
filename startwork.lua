function open(args)
  hs.execute("open " .. args)
end

function start_work()
  local start = hs.application.launchOrFocus
  
  start("Messages")
  --  start("WhatsApp")
  start("HipChat")
  start("Slack")
  start("Google Chrome")
  start("Things")
  -- start("Atom")
  -- start("iTerm")
  
  open("https://outlook.office365.com/owa/?realm=srcinc.com#path=/mail")
  open("https://fourvsystems.atlassian.net/secure/Dashboard.jspa")
  open("http://sensu.fourvdev.com:3000")
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", start_work)
table.insert(menuItems, {title = "Start Work Applications\t\tcmd+alt+ctrl+S", fn = start_work })
