--NASTAVEN�
local BGCOLOR = colors.gray --Barva Pozad�
local TEXTCOLOR = colors.orange --Barva Textu

--V�c uz neupravujte!!
local next_session_id = os.getComputerID()
local MODEM_SIDE = peripheral.find("modem",rednet.open)

term.setBackgroundColor(BGCOLOR)
term.setTextColor(TEXTCOLOR)
local PROXY_ID = 133

local function send_ai_query(query)
    local session_id = next_session_id
    next_session_id = next_session_id + 1
    
    term.write("Sending query (ID: " .. session_id .. ") to Proxy...")
    
    local message_data = {
        type = "AI_QUERY",
        session_id = session_id,
        text = query
    }
    
    rednet.send(PROXY_ID, message_data)
    
    print("\nWaiting for response with ID: " .. session_id .. "...")
    
    local response_data = nil
    local timeout = 60
    
    while not response_data do
        local sender_id, data = rednet.receive(timeout) 
        
        if data == nil then
            print("Request timed out.")
            return "Error: AI request timed out after " .. timeout .. " seconds."
        end
        
        if sender_id == PROXY_ID and type(data) == "table" and data.type == "AI_RESPONSE" and data.session_id == session_id then
            response_data = data -- Found the matching response
        elseif sender_id == PROXY_ID and type(data) == "table" and data.type == "AI_RESPONSE" then
            print("Received out-of-order response (ID: " .. data.session_id .. "). Waiting for our turn.")
        end
    end
    return response_data.text
end

term.clear()
term.setCursorPos(1, 1)
print("--- (c) GGHJK 2025 - AI Client ---")

while true do
local w, h = term.getSize()
term.setCursorPos(0,h-1)
term.write("-------------------------------------------------------------------------------------------")
term.setCursorPos(0,h)
    term.write("\nZprava > ")
    local input = read()
    
    if input == "quit_ai_client" or input == nil then
        break
    elseif input and input ~= "" then
        print("--------------------")
        local response = send_ai_query(input)
        print("--- Odpoved AI ---")
        print("")
        print(response)
        print("--------------------")
    end
end
