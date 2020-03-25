function printf(...)
  print(string.format(...))
end

function humanSeconds(seconds)
  local days = 0
  local hours = 0
  local minutes = 0
  
  printf("%i days, %i hours, %i minutes, %i seconds",days,hours,minutes,seconds)
  
  if seconds >= 86400 then
    days = math.floor(seconds/86400)
    seconds = seconds - (days * 86400)
  end
  
  printf("%i days, %i hours, %i minutes, %i seconds",days,hours,minutes,seconds)
  
  if seconds >= 3600 then
    hours = math.floor(seconds/3600)
    seconds = seconds - (hours * 3600)
  end
  
  if seconds >= 60 then
    minutes = math.floor(seconds/60)
    seconds = seconds - (minutes * 60)
  end
  
  if days <= 0 then
    return string.format("%02i:%02i:%02i",hours,minutes,seconds)
  else
    return string.format("%id %02i:%02i:%02i",days,hours,minutes,seconds)
  end
end

-- tests = {}
-- tests["1 day"] = (1*86400)
-- tests["2 days 1 hour"] = ((2*86400)+(1*3600))
-- tests["0 days 0 hours 3 minutes 2 seconds"] = ((0*86400)+(0*3600)+(3*60)+2)
-- tests["0 days 0 hours 59 minutes 1 seconds"] = ((0*86400)+(0*3600)+(59*60)+1)
-- 
-- print("testing table")
-- for key, value in pairs(tests)
-- do
--   printf("%s (%i): %s", key, value, humanSeconds(value))
-- end