function loadUI()
term.clear()
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
end
local news = 'GGHJK Has Official Internet - 13.12.2025'
loadUI()
print("News:")
print(news)
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