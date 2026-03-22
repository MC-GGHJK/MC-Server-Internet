-- Minimal Rednet Client
local SERVER_ID = 107
local TEMP_FILE = ".website.lua"
local PROTOCOL = "gghjk_internet"

-- otevření modemu
peripheral.find("modem", rednet.open)

while true do
    io.write("Zadej domenu: ")
    local domain = read()
    if not domain or domain == "" then
        print("Neplatna doména.")
    else
        domain = domain:lower():gsub("^%s*(.-)%s*$", "%1")
        -- poslat požadavek
        rednet.send(SERVER_ID, domain, PROTOCOL)
        
        local sender_id, file_code = rednet.receive(PROTOCOL, 5)

        if not sender_id then
            print("Server neodpovedel (timeout).")
        elseif sender_id ~= SERVER_ID then
            print("Odpoved od neznameho serveru.")
        elseif not file_code then
            print("Server poslal prazdnou odpoved.")
        elseif file_code == "404 NOT FOUND" then
            print("Domena '" .. domain .. "' nebyla nalezena.")
        elseif type(file_code) == "string" then
            local sanitized_code = file_code
                :gsub("^\xEF\xBB\xBF", "")
                :gsub("^%s*(.-)%s*$", "%1")

            local f = fs.open(TEMP_FILE, "w")
            f.write(sanitized_code)
            f.close()

            local success, err = pcall(function()
                shell.run(TEMP_FILE)
            end)

            if not success then
                print("Program selhal: " .. tostring(err))
            end

            if fs.exists(TEMP_FILE) then fs.delete(TEMP_FILE) end
        else
            print("Neplatna odpoved od serveru.")
        end
    end
end
