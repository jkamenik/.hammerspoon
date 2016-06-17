function start_work()
      print("starting work")
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", start_work)
table.insert(menuItems, {title = "Start Work Applications\t\tcmd+alt+ctrl+S", fn = start_work })
