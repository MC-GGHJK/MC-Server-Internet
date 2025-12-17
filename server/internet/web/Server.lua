--DNS Records
local DOMAIN_MAP = {
    ["ai.net"] = "disk/internet/google/ai/src/ai-client",
    ["music.cc"] = "disk/internet/music/src/main.lua",
    ["news.net"] = "disk/internet/news/src/main.lua",
    ["update.net"] = "disk/internet/update/src/update.lua",
    ["host.net"] = "disk/internet/host/src/host.lua",
    ["info.net"] = "disk/internet/info/src/info-client.lua"
}
------------------------------------------------------------------
local function log(message)
    local hour = string.format("%02d", os.clock() / 3600 % 24)
    local min = string.format("%02d", os.clock() / 60 % 60)
    local sec = string.format("%02d", os.clock() % 60)
    print(string.format("[%s:%s:%s] SERVER LOG: %s", hour, min, sec, message))
end

-- 2. HLAVNÍ LOOP SERVERU
log("Initializing Rednet...")
peripheral.find("modem", rednet.open)
log("Code Server V9 (Hard-coded DNS) running. ID: " .. os.getComputerID())
log("Awaiting raw domain requests...")

while true do
    local client_id = nil
    local domain_raw = nil
    
    -- Krok 1: Bezpečný příjem dat
    local received_id, received_message, received_protocol = rednet.receive()
    
    if received_id then
        client_id = received_id
        domain_raw = received_message
        log("DEBUG: Received message. Sender ID: " .. client_id .. ", Message Type: " .. type(domain_raw))
    else
        goto continue
    end

    if domain_raw and type(domain_raw) == "string" then
        
        local domain = domain_raw:lower()
        log("Request received from ID: " .. client_id .. ". Domain: " .. domain)
        
        -- Krok 2: Mapování (Nyní bezpečné, protože DOMAIN_MAP je globální)
        local code_file = DOMAIN_MAP[domain]
        local code_to_send = "404 NOT FOUND" 
        
        if not code_file then
            log("MAP ERROR: Domain '" .. domain .. "' not found. Sending 404.")
        else
            log("SUCCESS: Mapped to file: " .. code_file)
            
            -- Krok 3: Načtení obsahu LUA souboru
            local file, err = fs.open(code_file, "r")
            
            if file then
                log("FILE SUCCESS: File opened. Reading content...")
                code_to_send = file.readAll()
                file.close()
                log("FILE SUCCESS: Content read successfully. Size: " .. #code_to_send .. " bytes.")
            else
                log("FILE ERROR: Failed to open file '" .. code_file .. "'. Error: " .. tostring(err))
                code_to_send = "404 NOT FOUND" 
            end
        end
        
        -- Krok 4: Odeslání odpovědi
        rednet.send(client_id, code_to_send)
        log("Response sent to ID: " .. client_id .. ". Message size: " .. #code_to_send)
    else
        log("COMMUNICATION ERROR: Received message was not a string or was invalid.")
        if received_id and domain_raw == nil then
            log("DIAGNOSTICS: Received ID " .. received_id .. " but message was nil.")
        elseif domain_raw ~= nil then
             log("DIAGNOSTICS: Received data type was " .. type(domain_raw) .. ", expected string. Raw content: " .. tostring(domain_raw))
        end
    end
    
    ::continue:: 
end
