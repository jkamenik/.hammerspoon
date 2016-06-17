function open(args)
   hs.execute("open " .. args)
end

function start_work()
   local start = hs.application.launchOrFocus

   start("Messages")
   start("WhatsApp")
   start("HipChat")
   start("Slack")
   start("Google Chrome")
   start("Emacs")
   start("iTerm")

   open("https://outlook.office365.com/owa/?realm=srcinc.com#path=/mail")
   open("https://fourvsystems.atlassian.net/secure/Dashboard.jspa")
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", start_work)
table.insert(menuItems, {title = "Start Work Applications\t\tcmd+alt+ctrl+S", fn = start_work })
