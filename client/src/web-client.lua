-- Minimal Rednet client (fix nil)
local SERVER_ID = 107
local TEMP_FILE = ".website.lua"
local PROTOCOL = "gghjk_internet"

local modem = peripheral.find("modem")
if not modem then
    error("Žádný modem nenalezen!")
end
rednet.open(peripheral.getName(modem))

while true do
    io.write("Doména: ")
    local domain = read()
    if domain and domain ~= "" then
        rednet.send(SERVER_ID, domain, PROTOCOL)
        local sender, code = rednet.receive(PROTOCOL, 5)
        if sender == SERVER_ID and code then
            local f = fs.open(TEMP_FILE, "w")
            f.write(code)
            f.close()
            shell.run(TEMP_FILE)
            fs.delete(TEMP_FILE)
        else
            print("Server neodpověděl nebo poslal nil.")
        end
    else
        print("Neplatná doména.")
    end
end
