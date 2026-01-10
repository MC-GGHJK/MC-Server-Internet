-- GGHJK INTERNET UPDATER v1.39
-- Bez diakritiky pro maximalni kompatibilitu

local URL_VERSION = 'https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/version/version.txt'
local URL_SRC_CLIENT = 'https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/src/web-client.lua'
local URL_SRC_WEB = 'https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/src/web.lua'
local URL_INSTALLER = 'https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/src/cli/install.lua'

local IVERSION = 1.39
local TEXTCOLOR = colors.orange
local BACKCOLOR = colors.gray
local w, h = term.getSize()

-- FUNKCE PRO UI
local function drawHeader(title)
    term.setBackgroundColor(BACKCOLOR)
    term.clear()
    term.setCursorPos(1, 1)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.yellow)
    term.clearLine()
    print(" GGHJK UPDATER - " .. (title or "Sytem"))
    term.setBackgroundColor(BACKCOLOR)
    term.setTextColor(TEXTCOLOR)
end

local function status(msg, color)
    term.setTextColor(color or colors.white)
    print(" > " .. msg)
end

-- START PROGRAMU
drawHeader("Kontrola")
status("Overovani verze na GitHubu...", colors.lightGray)

local nver = "?"
local r = http.get(URL_VERSION)
if r then
    nver = r.readAll():gsub("%s+", "") -- Odstrani mezery/radky
    r.close()
end

sleep(1)
status("Aktualni verze na serveru: " .. nver, colors.green)
sleep(1)

-- INFORMACE O INSTALACI
drawHeader("Instalace")
print("\n Chysta se aktualizace systemu.")
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
term.setTextColor(colors.yellow)
write(" Pokracovat v instalaci? (Y/N): ")
local rspn = read():lower()

if rspn == "y" then
    drawHeader("Probiha zapis")
    status("Instalator v" .. IVERSION .. " spusten.", colors.yellow)
    status("Cilova verze: " .. nver, colors.yellow)
    
    -- MAZANI STARYCH SOUBORU
    status("Cisteni starych souboru...", colors.lightGray)
    if fs.exists("gghjk-system/web-client.lua") then fs.delete("gghjk-system/web-client.lua") end
    if fs.exists("web.lua") then fs.delete("web.lua") end
    sleep(1.5)

    -- STAHYOVANI
    status("Stahovani z GitHubu...", colors.white)
    
    -- Web Client
    shell.run("wget " .. URL_SRC_CLIENT .. " gghjk-system/web-client.lua")
    status("Soubor 'web-client.lua' ulozen.", colors.green)
    
    -- Web script
    shell.run("wget " .. URL_SRC_WEB .. " web.lua")
    status("Soubor 'web.lua' ulozen.", colors.green)
    
    -- Update instalatoru (prejmenovano z .java na .lua pro logiku)
    if fs.exists("internet_installer.java") then fs.delete("internet_installer.java") end
    shell.run("wget " .. URL_INSTALLER .. " internet_installer.java")
    
    status("Cisteni docasnych souboru...", colors.lightGray)
    sleep(2)

    drawHeader("Hotovo")
    term.setTextColor(colors.green)
    print("\n INSTALACE USPESNE DOKONCENA!")
    term.setTextColor(colors.white)
    print(" ------------------------------------------------")
    print(" Webovy klient spustite prikazem: web")
    print(" Nedotykejte se souboru v 'gghjk-system/'.")
    print(" ------------------------------------------------")
    sleep(5)

else
    drawHeader("Zruseno")
    status("Instalace byla prerusena uzivatelem.", colors.red)
    -- Uklid instalatoru i pri zruseni
    if fs.exists("internet_installer.java") then fs.delete("internet_installer.java") end
    shell.run("wget " .. URL_INSTALLER .. " internet_installer.java")
    sleep(2)
end

-- NAVRAT DO TERMINALU
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)