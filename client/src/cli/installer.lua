--Download
local nverurl = 'https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/version/version.txt'

local nver = "?"
local r = http.get(nverurl)

if r then
  nver = tonumber(r.readAll()) or "?"
  r.close()
end
local iversion = 1.39
local TEXTCOLOR = colors.orange
local BACKCOLOR = colors.gray
 
term.setBackgroundColor(BACKCOLOR)
term.setTextColor(TEXTCOLOR)
term.clear()
print("Welcome to the Update Client!")
sleep(2)
print("Checking for updates...")
print("Loading updater...")
sleep(5)
sleep(2)
print("Current newest version: "..nver)
print("Launching updater...")
sleep(2)
term.clear()
print("Odstrani se:")
print("-gghjk-system/web-client.lua")
print("-web.lua")
print("")
print("Prida se:")
print("-gghjk-client/web-client.lua")
print("-web.lua")
print("")
print("Napiste Y/y pro instalaci")
print("Nebo N/n pro zruseni")
print("")
local rspn = read()
if rspn == "Y" or rspn == "y" then
print('Running Installer Version '..iversion.. ' Please Wait..' )
sleep(2)
print("")
print('Installing Internet Version ' ..nver.. ' Please Wait...')
print("")
print("Connecting to https://raw.githubusercontent/MC-GGHJK/MC-Server-Internet/Client")
print("Connecting to Server...")
print("")
sleep(10)
print("Downloading...")
fs.delete("gghjk-system/web-client.lua")
fs.delete("web.lua")
sleep(2)
print("Downloading web-client.lua...")
shell.run("wget https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/src/web-client.lua gghjk-system/web-client.lua")
sleep(2)
print("Downloading web.lua...")
sleep(2)
shell.run("wget https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/src/web.lua")
sleep(2)
print("Connecting to Server https://download.gghjk.net/mc/internet/client/src/")
fs.delete('internet_installer.java')
shell.run('wget https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/src/cli/install.lua internet_installer.java')
sleep(5)
print('')
print("")
print("Dont open gghjk-system/web-client.lua  Its System file of GGHJk System")
print('To run web client "type web" in the terminal')
print('Web client directory: web.lua')
print("Installation Complete!")
sleep(5)
elseif rspn == "N" or rspn == "n" then
print("Canceling Installation...")
fs.delete('internet_installer.java')
shell.run('wget https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/src/cli/install.lua internet_installer.java')
sleep(10)
print("Installation Canceled.")
sleep(0.9)
term.clear()
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
else
return
end
term.clear()
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
