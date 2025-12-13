--Download
local version = 0.8
local iversion = 0.6
local TEXTCOLOR = colors.orange
local BACKCOLOR = colors.gray
 
term.setBackgroundColor(BACKCOLOR)
term.setTextColor(TEXTCOLOR)
term.clear()
print("Odstrani se:")
print("-gghjk-system/web-client.lua")
print("-web.lua")
print("")
print("Prida se:")
print("-gghjk-client/web-client.lua")
print("-web.lua")
print("")
print("Napiste Y pro instalaci")
print("Nebo N pro zruseni")
print("")
local rspn = read()
if rspn == "Y" then
print('Running Installer Version '..iversion..' Please Wait..' )
sleep(2)
print("")
print('Installing Internet Version ' ..version.. ' Please Wait...')
print("")
print("Connecting to https://raw.githubusercontent/MC-GGHJK/MC-Server-Internet/Client")
print("")
sleep(10)
print("Downloading...")
fs.delete("gghjk-system/web-client.lua")
shell.run("wget https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/src/web.lua")
shell.run("wget https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/src/web-client.lua gghjk-system/web-client.lua")
sleep(5)
print("")
print("Dont open gghjk-system/web-client.lua  Its System file of GGHJk System")
elseif rspn == "N" then
print("Canceling Installation...")
sleep(5)
term.clear()
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
else
return
end
