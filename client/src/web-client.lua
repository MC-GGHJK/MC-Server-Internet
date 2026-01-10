local SERVER_ID = 133
local TEMP_FILE = ".website.lua"
local BACKCOLOR = colors.gray
local VER = 2.0
local NVERURL = 'https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/version/version.txt'

local nver = "?"
local w, h = term.getSize()
local activeTabIndex = 1
local tabData = {
    { type = "home", domain = "", content = nil }
}

peripheral.find("modem", rednet.open)

local function drawUI()
    term.setBackgroundColor(BACKCOLOR)
    term.clear()
    
    term.setCursorPos(1, 1)
    term.setBackgroundColor(colors.lightGray)
    term.clearLine()
    
    local currentX = 1
    for i, tab in ipairs(tabData) do
        if i == activeTabIndex then
            term.setBackgroundColor(colors.white)
        else
            term.setBackgroundColor(colors.lightGray)
        end
        term.setTextColor(colors.black)
        local label = tab.type == "home" and "Home" or tab.domain
        local text = " [ " .. label .. " ] "
        tab.startX = currentX
        tab.endX = currentX + #text - 1
        term.write(text)
        currentX = tab.endX + 1
    end
    
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    term.write(" [ + ] ")
    local plusStartX = currentX
    local plusEndX = currentX + 6

    term.setCursorPos(1, 2)
    term.setBackgroundColor(colors.white)
    term.clearLine()
    term.setTextColor(colors.gray)
    local currentDomain = tabData[activeTabIndex].domain
    term.write(" (i)  gghjk://" .. (tabData[activeTabIndex].type == "web" and currentDomain or ""))
    
    term.setCursorPos(1, 3)
    term.setBackgroundColor(BACKCOLOR)
    term.setTextColor(colors.black)
    term.write(string.rep("-", w))

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

    term.setBackgroundColor(BACKCOLOR)
    local currentTab = tabData[activeTabIndex]
    if currentTab.type == "home" then
        term.setTextColor(colors.orange)
        term.setCursorPos(math.floor(w/2)-10, 6)
        term.write("GGHJK WEB ENGINE 2026")
        term.setTextColor(colors.white)
        term.setCursorPos(2, 8)
        term.write("Zalozka " .. activeTabIndex .. ": Zadejte domenu.")
    elseif currentTab.type == "web" and currentTab.content then
        local f = fs.open(TEMP_FILE, "w")
        f.write(currentTab.content)
        f.close()
        local success, err = pcall(shell.run, TEMP_FILE)
        if not success then
            term.setBackgroundColor(BACKCOLOR)
            term.setTextColor(colors.red)
            term.setCursorPos(1, 5)
            print(" CHYBA STRANKY: " .. tostring(err))
        end
        if fs.exists(TEMP_FILE) then fs.delete(TEMP_FILE) end
    end
    
    return plusStartX, plusEndX
end

local function checkVersion()
    local r = http.get(NVERURL)
    if r then nver = r.readAll():gsub("%s+", "") r.close() end
end

local function fetchAndRun(domain)
    tabData[activeTabIndex].domain = domain
    tabData[activeTabIndex].type = "web"
    drawUI()
    
    term.setBackgroundColor(BACKCOLOR)
    term.setCursorPos(1, 5)
    term.setTextColor(colors.white)
    print(" Vyhledavam: " .. domain)

    rednet.send(SERVER_ID, domain)
    local id, file_code = rednet.receive(5)
    
    if file_code and type(file_code) == "string" and file_code ~= "404 NOT FOUND" then
        local sanitized = file_code:gsub("^\xEF\xBB\xBF", ""):gsub("^%s*(.-)%s*$", "%1")
        tabData[activeTabIndex].content = sanitized
    else
        tabData[activeTabIndex].type = "home"
        tabData[activeTabIndex].domain = ""
        tabData[activeTabIndex].content = nil
        term.setCursorPos(1, 5)
        term.setTextColor(colors.red)
        print(" CHYBA: Stranka nenalezena.")
        sleep(2)
    end
    drawUI()
end

checkVersion()
local pStart, pEnd = drawUI()

while true do
    local event, p1, p2, p3 = os.pullEvent()
    
    if event == "mouse_click" then
        if p3 == 1 then
            local hitTab = false
            for i, tab in ipairs(tabData) do
                if p2 >= tab.startX and p2 <= tab.endX then
                    activeTabIndex = i
                    hitTab = true
                    break
                end
            end
            
            if not hitTab and p2 >= pStart and p2 <= pEnd then
                table.insert(tabData, { type = "home", domain = "", content = nil })
                activeTabIndex = #tabData
            elseif p3 == 1 and not hitTab and p1 == 1 then
                -- Kliknuti na adresni radek
            elseif p3 == 2 then
                -- Logika pro adresni radek nize
            end
            pStart, pEnd = drawUI()
        end
        
        if p3 == 2 then -- Kliknuti do adresniho radku
            term.setCursorPos(15, 2)
            term.setBackgroundColor(colors.white)
            term.setTextColor(colors.black)
            term.write(string.rep(" ", w-15))
            term.setCursorPos(15, 2)
            local domain = read()
            if domain ~= "" then fetchAndRun(domain) else pStart, pEnd = drawUI() end
        end

    elseif event == "key" and p1 == keys.enter then
        term.setCursorPos(15, 2)
        term.setBackgroundColor(colors.white)
        term.setTextColor(colors.black)
        local domain = read()
        if domain ~= "" then fetchAndRun(domain) else pStart, pEnd = drawUI() end
    end
end