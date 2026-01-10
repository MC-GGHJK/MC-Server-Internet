-- KONFIGURACE
local SERVER_ID = 133
local TEMP_FILE = ".website.lua"
local BACKCOLOR = colors.gray
local TEXTCOLOR = colors.orange
local VER = 1.9
local NVERURL = 'https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/version/version.txt'

-- PROMENNE
local nver = "?"
local w, h = term.getSize()

-- INICIALIZACE MODEMU
peripheral.find("modem", rednet.open)

-- FUNKCE PRO KRESLENI UI
local function drawUI()
    -- Zakladni pozadi
    term.setBackgroundColor(BACKCOLOR)
    term.clear()
    
    -- 1. LISTA: Zalozky (Tabs bar)
    term.setCursorPos(1, 1)
    term.setBackgroundColor(colors.lightGray)
    term.clearLine()
    term.setTextColor(colors.gray)
    term.write(" [ Novy tab ]  [ Domu ]  [ + ]")

    -- 2. LISTA: Adresni radek (Address bar)
    term.setCursorPos(1, 2)
    term.setBackgroundColor(colors.white)
    term.clearLine()
    term.setTextColor(colors.gray)
    term.write(" (i)  gghjk://")
    
    -- 3. LISTA: Dekorativni linka pod listou
    term.setCursorPos(1, 3)
    term.setBackgroundColor(BACKCOLOR)
    term.setTextColor(colors.black)
    term.write(string.rep("-", w))

    -- 4. LISTA: Stavova lista (Taskbar/Footer)
    term.setBackgroundColor(colors.black)
    term.setCursorPos(1, h)
    term.clearLine()
    
    -- Verze vlevo
    term.setTextColor(colors.lightGray)
    term.write(" v" .. VER)
    
    -- LOGIKA CHECKOVANI UPDATU (Vraceno zpet)
    local statusMsg = ""
    local statusColor = colors.green
    
    local num_nver = tonumber(nver)
    if nver == "?" then
        statusMsg = "Update check failed"
        statusColor = colors.yellow
    elseif VER < (num_nver or 0) then
        statusMsg = "Update available: v" .. nver
        statusColor = colors.red
    elseif VER >= (num_nver or 0) then
        statusMsg = "System Up-to-date"
        statusColor = colors.green
    end
    
    term.setCursorPos(w - #statusMsg, h)
    term.setTextColor(statusColor)
    term.write(statusMsg)

    -- 5. LISTA: Informacni panel nad patickou
    term.setBackgroundColor(BACKCOLOR)
    term.setTextColor(colors.white)
    term.setCursorPos(1, h - 2)
    term.write("(c) 2025-2026 GGHJK Web Engine")
    term.setCursorPos(1, h - 1)
    term.setTextColor(colors.lightGray)
    term.write("Discord: #gghjk-internet")
    
    -- Nastaveni kurzoru do adresniho radku
    term.setCursorPos(15, 2)
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
end

-- FUNKCE PRO KONTROLU VERZE
local function checkVersion()
    local r = http.get(NVERURL)
    if r then
        local raw = r.readAll()
        nver = raw:gsub("%s+", "") -- Vyčistí mezery a konce řádků
        r.close()
    end
end

-- POMOCNA FUNKCE PRO CHYBY
local function showError(msg)
    term.setBackgroundColor(BACKCOLOR)
    term.setTextColor(colors.red)
    term.setCursorPos(1, 5)
    print(" [!] ERROR: " .. msg)
    sleep(3)
    drawUI()
end

-- FUNKCE PRO NACITANI STRANEK
local function fetchAndRun(domain)
    term.setBackgroundColor(BACKCOLOR)
    term.setCursorPos(1, 5)
    term.setTextColor(colors.white)
    print(" Vyhledavam dns://" .. domain .. "...")

    rednet.send(SERVER_ID, domain)
    local sender_id, file_code = rednet.receive(5)
    
    if not file_code then
        showError("Server neodpovida (Timeout).")
        return
    end

    if file_code == "404 NOT FOUND" then
        showError("Stranka nebyla nalezena.")
        return
    end
    
    if type(file_code) == "string" then
        local sanitized_code = file_code:gsub("^\xEF\xBB\xBF", ""):gsub("^%s*(.-)%s*$", "%1")

        local f = fs.open(TEMP_FILE, "w")
        f.write(sanitized_code)
        f.close()
        
        print(" Stranka nactena. Spoustim...")
        sleep(0.5)
        
        -- SPUSTENI (FULLSCREEN)
        local success, err = pcall(function()
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
            term.clear()
            term.setCursorPos(1, 1)
            shell.run(TEMP_FILE)
        end)
        
        if not success then
            term.setBackgroundColor(BACKCOLOR)
            term.setTextColor(colors.red)
            print("\n CHYBA PRI BĚHU: " .. tostring(err))
            sleep(5)
        end
        
        if fs.exists(TEMP_FILE) then fs.delete(TEMP_FILE) end
        drawUI()
    else
        showError("Neplatna data ze serveru.")
    end
end

-- START PROGRAMU
checkVersion()
drawUI()

-- HLAVNI SMYCKA
while true do
    term.setCursorPos(15, 2)
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
    
    local domain_input = read()
    
    if domain_input and domain_input ~= "" and not tonumber(domain_input) then
        fetchAndRun(domain_input)
    else
        term.setCursorPos(1, 5)
        term.setBackgroundColor(BACKCOLOR)
        term.setTextColor(colors.red)
        print(" Neplatna URL adresa!")
        sleep(2)
        drawUI()
    end
end