local SERVER_ID = 133
local TEMP_FILE = ".website.lua" 
local BACKCOLOR = colors.gray
local TEXTCOLOR = colors.orange
-------------------------------------------
local ver = "1.6.9"
local nverurl = 'https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/version/version.txt'

local nver = "?"
local r = http.get(nverurl)

if r then
  nver = tonumber(r.readAll()) or "?"
  r.close()
end

local w, h = term.getSize()
    function loadUI()
    term.clear()
    term.setBackgroundColor(BACKCOLOR)
    term.setTextColor(TEXTCOLOR)
    term.clear()
    term.setCursorPos(1,h-3)
    term.write("(c)2025 GGHJK - Internet browser 2025")
    term.setCursorPos(1,h-2)
    term.write('Version '..ver..' / '..nver)

    if ver < nver then
      term.setCursorPos(1,h-1)
      term.write('A new version '..nver..' available!')
    elseif ver >= nver then
      term.setCursorPos(1,h-1)
      term.write('You are up to date!')
    elseif ver == "?" then
      term.setCursorPos(1,h-1)
      term.write('Unable to check for updates!')
    end


    term.setCursorPos(1,h)
    term.write("More at discord, #gghjk-internet.")
    term.setCursorPos(1,2)
    term.write("------------------------------------------------------------------------------------------------------------------------------------------------------")
    term.setCursorPos(1,1)
    term.write("Adresa> ")
    end

loadUI()

local function fetchAndRun(domain)
    print("\n--- FETCHING: " .. domain .. " ---")
    rednet.send(SERVER_ID, domain) 
    
    local sender_id, file_code = rednet.receive(5) 
    
    if file_code == nil then
        print("ERROR: Server neodpovedel vcas nebo odeslal neplatnou odpoved.")
        print("Zkontrolujte pripojeni k siti nebo spravnost domeny.")
        print("Polud problem pretrva, Kontaktujte podporu.")
        print("Timed Out.")
        sleep(3)
        loadUI()
        return
    end

    if file_code == "404 NOT FOUND" then
        print("ERROR: Domena '" .. domain .. "' nebyla nalezena (404: Forbidden).")
        sleep(3)
        loadUI()
        return
    end
    
    if file_code and type(file_code) == "string" then
        
        local sanitized_code = string.gsub(file_code, "^%s*(.-)%s*$", "%1")
        sanitized_code = string.gsub(sanitized_code, "\xEF\xBB\xBF", "")

        local temp_file_handle = fs.open(TEMP_FILE, "w")
        temp_file_handle.write(sanitized_code)
        temp_file_handle.close()
        
        print("Code received. Starting program...")
        
        local success, err_msg = pcall(function()
        term.clear()
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.clear()
        sleep(0.1)
            shell.run(TEMP_FILE) 
        end)
        
        if not success then
            print("\n!!! Program execution failed! !!!")
            print("Details: " .. tostring(err_msg))
            print("File not deleted. Check '"..TEMP_FILE.."' for errors.")
        else
            print("\nProgram finished successfully.")
            fs.delete(TEMP_FILE)
            loadUI()
        end
        
    else
        print("ERROR: Received data was not a valid code string (Type: " .. type(file_code) .. ").")
        sleep(3)
        loadUI()
    end
end

peripheral.find("modem", rednet.open)

while true do
    
    local domain_input = read() 
    
    if domain_input and domain_input ~= "" and domain_input ~= "0" and tonumber(domain_input) == nil then
        fetchAndRun(domain_input)
    else
        print("Invalid input. Please enter a domain name.")
        print("Domain names cannot be empty, '0', or purely numeric.")
        print("Try again.")
        print("")
        sleep(1)
        loadUI()
    end
end
