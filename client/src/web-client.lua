-- KONFIGURACE
local SERVER_ID = 133
local TEMP_FILE = ".website.lua"
local BACKCOLOR = colors.gray
local VER = 2.0
local NVERURL = 'https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/version/version.txt'

-- PROMENNE
local nver = "?"
local w, h = term.getSize()
local activeTab = "home" -- "home" nebo "web"
local lastDomain = ""

-- INICIALIZACE MODEMU
peripheral.find("modem", rednet.open)

-- FUNKCE PRO KRESLENI UI
local function drawUI()
    term.setBackgroundColor(BACKCOLOR)
    term.clear()
    
    -- 1. LISTA: Zalozky (Tabs bar) - Ted s barvou podle toho, co je aktivni
    term.setCursorPos(1, 1)
    term.setBackgroundColor(colors.lightGray)
    term.clearLine()
    
    -- Home Tab
    if activeTab == "home" then term.setBackgroundColor(colors.white) else term.setBackgroundColor(colors.lightGray) end
    term.setTextColor(colors.black)
    term.write(" [ Home ] ")
    
    -- Web Tab
    if activeTab == "web" then term.setBackgroundColor(colors.white) else term.setBackgroundColor(colors.lightGray) end
    term.setTextColor(colors.black)
    term.write(" [ Web: " .. (lastDomain ~= "" and lastDomain or "...") .. " ] ")
    
    -- 2. LISTA: Adresni radek
    term.setCursorPos(1, 2)
    term.setBackgroundColor(colors.white)
    term.clearLine()
    term.setTextColor(colors.gray)
    term.write(" (i)  gghjk://" .. (activeTab == "web" and lastDomain or ""))
    
    -- 3. LISTA: Dekorativni linka
    term.setCursorPos(1, 3)
    term.setBackgroundColor(BACKCOLOR)
    term.setTextColor(colors.black)
    term.write(string.rep("-", w))

    -- 4. LISTA: Stavova lista (Footer)
    term.setBackgroundColor(colors.black)
    term.setCursorPos(1, h)
    term.clearLine()
    term.setTextColor(colors.lightGray)
    term.write(" v" .. VER)
    
    local statusMsg = ""
    local statusColor = colors.green
    local num_nver = tonumber(nver)
    if nver == "?" then statusMsg = "Update check failed" statusColor = colors.yellow
    elseif VER < (num_nver or 0) then statusMsg = "Update available: v" .. nver statusColor = colors.red
    else statusMsg = "System Up-to-date" statusColor = colors.green end
    
    term.setCursorPos(w - #statusMsg, h)
    term.setTextColor(statusColor)
    term.write(statusMsg)

    -- Obsah plochy
    term.setBackgroundColor(BACKCOLOR)
    if activeTab == "home" then
        term.setTextColor(colors.orange)
        term.setCursorPos(math.floor(w/2)-10, 6)
        term.write("GGHJK WEB ENGINE 2026")
        term.setTextColor(colors.white)
        term.setCursorPos(2, 8)
        term.write("Zadejte domenu do radku vyse.")
    end
end

local function checkVersion()
    local r = http.get(NVERURL)
    if r then nver = r.readAll():gsub("%s+", "") r.close() end
end

local function fetchAndRun(domain)
    lastDomain = domain
    activeTab = "web"
    drawUI()
    
    term.setBackgroundColor(BACKCOLOR)
    term.setCursorPos(1, 5)
    term.setTextColor(colors.white)
    print(" Vyhledavam: " .. domain)

    rednet.send(SERVER_ID, domain)
    local id, file_code = rednet.receive(5)
    
    if file_code and type(file_code) == "string" and file_code ~= "404 NOT FOUND" then
        local sanitized = file_code:gsub("^\xEF\xBB\xBF", ""):gsub("^%s*(.-)%s*$", "%1")
        local f = fs.open(TEMP_FILE, "w")
        f.write(sanitized)
        f.close()
        
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.clear()
        term.setCursorPos(1, 1)
        
        local success, err = pcall(shell.run, TEMP_FILE)
        if not success then
            term.setBackgroundColor(BACKCOLOR)
            term.setTextColor(colors.red)
            print("\n CHYBA STRANKY: " .. tostring(err))
            sleep(3)
        end
        if fs.exists(TEMP_FILE) then fs.delete(TEMP_FILE) end
    else
        activeTab = "home"
        print(" CHYBA: Stranka nenalezena.")
        sleep(2)
    end
    drawUI()
end

-- START
checkVersion()
drawUI()

-- HLAVNI SMYCKA S PODPOROU MYSI
while true do
    local event, p1, p2, p3 = os.pullEvent()
    
    if event == "mouse_click" then
        -- Kliknuti na Home Tab (X od 1 do 10 na prvnim radku)
        if p3 == 1 and p2 >= 1 and p2 <= 10 then
            activeTab = "home"
            drawUI()
        -- Kliknuti na Web Tab (X od 11 do 30)
        elseif p3 == 1 and p2 >= 11 and p2 <= 30 and lastDomain ~= "" then
            activeTab = "web"
            fetchAndRun(lastDomain)
        -- Kliknuti na adresni radek (X kdekoli na radku 2)
        elseif p3 == 2 then
            term.setCursorPos(15, 2)
            term.setBackgroundColor(colors.white)
            term.setTextColor(colors.black)
            term.write(string.rep(" ", w-15))
            term.setCursorPos(15, 2)
            local domain = read()
            if domain ~= "" then fetchAndRun(domain) else drawUI() end
        end
        
    elseif event == "key" and p1 == keys.enter then
        term.setCursorPos(15, 2)
        term.setBackgroundColor(colors.white)
        term.setTextColor(colors.black)
        local domain = read()
        if domain ~= "" then fetchAndRun(domain) else drawUI() end
    end
end