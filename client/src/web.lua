local path = "gghjk-system/web-client.lua"
local BACKCOLOR = colors.gray
local TEXTCOLOR = colors.orange

-- Nastaveni vzhledu pro chybu nebo uvod
term.setBackgroundColor(BACKCOLOR)
term.setTextColor(TEXTCOLOR)
term.clear()
term.setCursorPos(1,1)

local vaild = fs.exists(path)

if vaild == false then
    -- Zahlavi pri chybe
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.red)
    term.clearLine()
    print(" GGHJK SYSTEM - CHYBA")
    
    term.setBackgroundColor(BACKCOLOR)
    print("\n Soubor klienta nebyl nalezen!")
    term.setTextColor(colors.white)
    print(" Cesta: " .. path)
    print("\n Prosim, preinstalujte klient pres instalator.")
    print(" Zkuste to znovu pozdeji.")
    
    print("\n Pokus o automatickou opravu...")
    sleep(3)
    
    -- Spusteni instalatoru z Pastebinu
    shell.run("pastebin run vkKmg99G")
    
elseif vaild == true then
    -- Pokud soubor existuje, proste ho spusti (vse se vymaze v samotnem klientovi)
    shell.run(path)
end

-- Reset barev pri ukonceni (pokud by program spadl)
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)