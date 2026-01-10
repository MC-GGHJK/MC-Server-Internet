local SERVER_ID = 133
local TEMP_FILE = ".website.lua"
local BACKCOLOR = colors.gray
local TEXTCOLOR = colors.orange
local ver = 2.0
local NVERURL = 'https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/version/version.txt'

local nver = "?"
local w, h = term.getSize()

peripheral.find("modem", rednet.open)

local function drawUI()
    term.setBackgroundColor(BACKCOLOR)
    term.clear()
    
    term.setCursorPos(1, 1)
    term.setBackgroundColor(colors.white)
    term.clearLine()
    term.setTextColor(colors.gray)
    term.write("gghjk://")
    
    term.setCursorPos(1, 2)
    term.setBackgroundColor(BACKCOLOR)
    term.setTextColor(colors.black)
    term.write(string.rep("-", w))

    term.setBackgroundColor(colors.black)
    term.setCursorPos(1, h)
    term.clearLine()
    
    if ver < nver then

      term.setCursorPos(1,h-1)

      term.write('A new version '..nver..' available!')

    elseif ver >= nver then

      term.setCursorPos(1,h-1)

      term.write('You are up to date!')

    elseif nver == "?" then

      term.setCursorPos(1,h-1)

      term.write('Unable to check for updates!')

    elseif ver == nver then

      term.setCursorPos(1,h-1)

      term.write('You are up to date!')

    else

      term.setCursorPos(1,h-1)

      term.write('Unable to check for updates!')

    end
local function checkVersion()
    local r = http.get(NVERURL)
    if r then
        nver = r.readAll():gsub("%s+", "")
        r.close()
    end
end

local function showError(msg)
    term.setBackgroundColor(BACKCOLOR)
    term.setTextColor(colors.red)
    term.setCursorPos(1, 4)
    print(" [!] ERROR: " .. msg)
    sleep(3)
    drawUI()
end

local function fetchAndRun(domain)
    term.setBackgroundColor(BACKCOLOR)
    term.setCursorPos(1, 4)
    term.setTextColor(colors.white)
    print(" Propojovani s dns://" .. domain .. "...")

    rednet.send(SERVER_ID, domain)
    local sender_id, file_code = rednet.receive(5)
    
    if not file_code then
        showError("Casovy limit vyprsel.")
        return
    end

    if file_code == "404 NOT FOUND" then
        showError("Stranka nenalezena.")
        return
    end
    
    if type(file_code) == "string" then
        local sanitized_code = file_code:gsub("^\xEF\xBB\xBF", ""):gsub("^%s*(.-)%s*$", "%1")

        local f = fs.open(TEMP_FILE, "w")
        f.write(sanitized_code)
        f.close()
        
        print(" Data prijata. Renderovani...")
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
            print("\n CRASH: " .. tostring(err))
            sleep(5)
        else
            term.setBackgroundColor(BACKCOLOR)
            term.setTextColor(colors.green)
            print("\n Prenos ukoncen.")
            sleep(1.5)
        end
        
        if fs.exists(TEMP_FILE) then fs.delete(TEMP_FILE) end
        drawUI()
    else
        showError("Neplatny format dat.")
    end
end

checkVersion()
drawUI()

while true do
    term.setCursorPos(15, 1)
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
    
    local domain_input = read()
    
    if domain_input and domain_input ~= "" and not tonumber(domain_input) then
        fetchAndRun(domain_input)
    else
        term.setCursorPos(1, 4)
        term.setBackgroundColor(BACKCOLOR)
        term.setTextColor(colors.red)
        print(" Neplatna URL adresa!")
        sleep(2)
        drawUI()
    end
end