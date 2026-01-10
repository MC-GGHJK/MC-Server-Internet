-- Download a verze
local nverurl = 'https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/version/version.txt'
local nver = "?"
local r = http.get(nverurl)

if r then
  nver = r.readAll():gsub("%s+", "") -- Odstrani konce radku
  r.close()
end

local iversion = 1.7
local TEXTCOLOR = colors.orange
local BACKCOLOR = colors.gray

-- Pomocna funkce pro zahlavi
local function drawHeader()
    term.setBackgroundColor(BACKCOLOR)
    term.clear()
    term.setCursorPos(1,1)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.yellow)
    term.clearLine()
    print(" GGHJK UPDATE CLIENT - v" .. iversion)
    term.setBackgroundColor(BACKCOLOR)
    term.setTextColor(TEXTCOLOR)
end

drawHeader()
print("\n Vitejte v Update Clientu!")
sleep(2)
print(" Kontrola aktualizaci...")
print(" Nacitani updateru...")
sleep(2)

drawHeader()
print("\n Nova verze na serveru: " .. nver)
print(" Spousteni...")
sleep(2)

drawHeader()
term.setTextColor(colors.red)
print(" Odstrani se:")
print(" - gghjk-system/web-client.lua")
print(" - web.lua")

print("\n")
term.setTextColor(colors.green)
print(" Prida se:")
print(" - gghjk-system/web-client.lua")
print(" - web.lua")

print("\n")
term.setTextColor(colors.white)
print(" Napiste Y pro instalaci")
print(" Napiste N pro zruseni")
print("")
write(" Volba > ")

local rspn = read():lower()

if rspn == "y" then
    drawHeader()
    print("\n Spoustim instalaci v" .. iversion)
    sleep(2)
    print(" Instaluji internet verzi " .. nver)
    print(" Pripojovani k GitHubu...")
    sleep(2)
    
    print(" Stahovani dat...")
    fs.delete("gghjk-system/web-client.lua")
    fs.delete("web.lua")
    sleep(1)
    
    print(" Stahuji: web-client.lua")
    shell.run("wget https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/src/web-client.lua gghjk-system/web-client.lua")
    
    print(" Stahuji: web.lua")
    shell.run("wget https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/src/web.lua")
    
    print(" Aktualizace instalatoru...")
    fs.delete('internet_installer.java')
    shell.run('wget https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/src/cli/install.lua internet_installer.java')
    
    print("\n-------------------------------------------")
    print(" Neotevirejte soubory v gghjk-system/")
    print(" Spusteni webu: prikaz 'web'")
    print(" INSTALACE DOKONCENA!")
    sleep(5)

elseif rspn == "n" then
    drawHeader()
    print("\n Ruseni instalace...")
    fs.delete('internet_installer.java')
    shell.run('wget https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/src/cli/install.lua internet_installer.java')
    sleep(2)
    print(" Instalace zrusena.")
    sleep(1)
end

-- Reset terminalu
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1,1)