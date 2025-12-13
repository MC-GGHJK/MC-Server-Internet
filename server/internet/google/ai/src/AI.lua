local GEMINI_API_KEY = "AIzaSyCstzMdLxa2KUW5DGTTwC4tS8D0wd8aL9A"
local GEMINI_ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" .. GEMINI_API_KEY
local MODEL = "gemini-2.5-flash"

-- Open RedNet modem (adjust side if needed)
rednet.open("top") 
print("--- RedNet AI Proxy Running ---")
term.setCursorPos(1, 2)
print("Listening for queries...")

while true do
    -- Wait indefinitely for a message
    local senderID, message_data = rednet.receive()
    
    if type(message_data) == "table" and message_data.type == "AI_QUERY" then
        
        local request_session_id = message_data.session_id
        local query = message_data.text
        
        print(string.format("\n[%s] Q %d from PC %d", os.date("%H:%M:%S"), request_session_id, senderID))

        -- 1. Construct the CORRECT JSON payload for Gemini
        local request_body = {
            contents = {{ 
                parts = {{ text = query }} 
            }},
            -- *** FIX: Changed 'config' to 'generationConfig' per the API error ***
            generationConfig = { 
                temperature = 0.5 -- Set to 0.5 for balanced creativity
            }
        }
        local json_body = textutils.serializeJSON(request_body) 
        
        local response_text = "Proxy Error: Unknown failure."
        
        -- 2. Make the HTTP POST request to Gemini, capturing error details
        local response, err_msg, err_handle = http.post(GEMINI_ENDPOINT, json_body, {
            ["Content-Type"] = "application/json"
        })
        
        if response then
            -- Success: Connection established and we got a standard response body
            local raw_data = response.readAll()
            response.close()
            
            -- 3. Parse the JSON response from Gemini
            local json_response, err = textutils.unserializeJSON(raw_data)
            
            if json_response and json_response.candidates and json_response.candidates[1] then
                -- SUCCESS: Valid response received
                response_text = json_response.candidates[1].content.parts[1].text
            elseif json_response and json_response.error then
                -- API Error: Google sent back an explicit error message (e.g., 400, 403, 429)
                response_text = "API ERROR: " .. (json_response.error.message or "Unknown API error.")
                print("API Error Code: " .. (json_response.error.code or "Unknown"))
            else
                -- Parsing Error
                response_text = "Parsing Error: Could not interpret AI response."
            end
        elseif err_handle then
            -- Connection successful, but the server returned a generic error code (4xx or 5xx)
            local error_body = err_handle.readAll()
            err_handle.close()
            response_text = "HTTP ERROR CODE: " .. error_body
            print("Received HTTP Error Handle. Content: " .. error_body)
        elseif err_msg then
            -- Failure: Connection was blocked or timed out
            response_text = "CONNECTION BLOCKED/TIMED OUT: " .. err_msg
            print("Connection Failure Message: " .. err_msg)
        end
        
        -- 4. Send the final response back over RedNet
        local response_data = {
            type = "AI_RESPONSE",
            text = response_text,
            session_id = request_session_id 
        }
        
        rednet.send(senderID, response_data)
        print(string.format("[%s] R %d sent back to PC %d.", os.date("%H:%M:%S"), request_session_id, senderID))
    end
end
