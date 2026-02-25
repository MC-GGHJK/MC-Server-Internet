function loadUI()
term.clear()
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
end
local news = 'GGHJK Has Official Internet - 13.12.2025'
local news2 = 'GGHJK Firmware 1 - 1.2.2026'
local news3 = 'GGHJK Internet 2.0 - 6.2.2026'
local news4 = 'GGHJK Internet 2.1 - 20.3.2026'
loadUI()
print("News:")
print(news)
print(news2)
print(news3)
print("")
print('"exit" pro ukonceni')
function wait()
local rsp = read()
if rsp == "exit" then
return
else
wait()
end
end

read()