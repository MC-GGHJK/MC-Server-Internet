local SERVER_ID = 107
local TEMP_FILE = ".website.lua" 
local BACKCOLOR = colors.gray
local TEXTCOLOR = colors.orange
local VER = 2.31
local NVERURL = 'https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/version/version.txt'

local nver = "?"
local w, h = term.getSize()

peripheral.find("modem", rednet.open)

local function drawUI()
    term.setBackgroundColor(BACKCOLOR)
    term.clear()
    
    term.setCursorPos(1, 1)
    term.setBackgroundColor(colors.black)
    term.clearLine()
    term.setTextColor(colors.yellow)
    term.write(" ADRESA > ")
    
    term.setCursorPos(1, 2)
    term.setBackgroundColor(BACKCOLOR)
    term.setTextColor(colors.black)
    term.write(string.rep("-", w))

    term.setTextColor(colors.white)
    term.setCursorPos(1, h - 3)
    term.write("(c) 2025-2026 GGHJK - Internet browser 2026")
    
    term.setCursorPos(1, h - 2)
    term.write("Verze: " .. VER .. " / Dostupna: " .. nver)

    term.setCursorPos(1, h - 1)
    if nver == "?" then
        term.setTextColor(colors.lightGray)
        term.write("Nelze overit aktualizace.")
    elseif VER < tonumber(nver or 0) then
        term.setTextColor(colors.red)
        term.write("Nova verze " .. nver .. " je dostupna!")
    else
        term.setTextColor(colors.green)
        term.write("Prohlizec je aktualni.")
    end

    term.setTextColor(colors.lightGray)
    term.setCursorPos(1, h)
    term.write("Discord: #gghjk-internet, Support: https://www.gghjk.qzz.io/support.php")
    
    term.setCursorPos(11, 1)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end

local function checkVersion()
    local r = http.get(NVERURL)
    if r then
        nver = r.readAll()
        r.close()
    end
end

local function showError(msg)
    term.setBackgroundColor(BACKCOLOR)
    term.setTextColor(colors.red)
    print("\n CHYBA: " .. msg)
    sleep(3)
    drawUI()
end

local function fetchAndRun(domain)
    term.setBackgroundColor(BACKCOLOR)
    term.setCursorPos(1, 4)
    term.setTextColor(colors.white)
    print(" Pripojovani k: " .. domain .. "...")

    -- odeslání requestu
    rednet.send(SERVER_ID, domain, PROTOCOL)

    local sender_id, file_code = rednet.receive(PROTOCOL, 5)

    -- ❌ timeout
    if not sender_id then
        showError("Server neodpovedel (Timed Out).")
        return
    end

    -- ❌ špatný sender
    if sender_id ~= SERVER_ID then
        showError("Prijata odpoved od neznameho serveru.")
        return
    end

    -- ❌ nil ochrana
    if not file_code then
        showError("Server poslal prazdnou odpoved.")
        return
    end

    -- ❌ 404
    if file_code == "404 NOT FOUND" then
        showError("Domena '" .. domain .. "' nebyla nalezena.")
        return
    end

    -- ❌ špatný typ
    if type(file_code) ~= "string" then
        showError("Prijata data nejsou platny kod.")
        return
    end

    -- ✅ sanitizace
    local sanitized_code = file_code
        :gsub("^\xEF\xBB\xBF", "")
        :gsub("^%s*(.-)%s*$", "%1")

    -- uložení
    local f = fs.open(TEMP_FILE, "w")
    f.write(sanitized_code)
    f.close()

    print(" Kod prijat. Spoustim...")
    sleep(0.5)

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
        print("\n!!! Program selhal !!!")
        print("Detaily: " .. tostring(err))
        sleep(5)
    else
        print("\n Program uspesne ukoncen.")
        sleep(1.5)
    end

    if fs.exists(TEMP_FILE) then fs.delete(TEMP_FILE) end
    drawUI()
end

checkVersion()
drawUI()

while true do
    term.setCursorPos(11, 1)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    
    local domain_input = read() 
    
    if domain_input and domain_input ~= "" and not tonumber(domain_input) then
        fetchAndRun(domain_input)
    else
        term.setCursorPos(1, 4)
        term.setBackgroundColor(BACKCOLOR)
        term.setTextColor(colors.red)
        print(" Neplatna adresa! Zadejte nazev domeny.")
        sleep(2)
        drawUI()
    end
end
