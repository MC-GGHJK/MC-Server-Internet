-- Absolutně minimální Rednet client
local SERVER_ID = 107
local TEMP_FILE = ".website.lua"
local PROTOCOL = "gghjk_internet"

peripheral.find("modem", rednet.open)

while true do
    io.write("Doména: ")
    local domain = read()
    if not domain or domain == "" then
        print("Neplatná doména.")
    else
        rednet.send(SERVER_ID, domain, PROTOCOL)
        local sender, code = rednet.receive(PROTOCOL, 5)
        if sender then
            local f = fs.open(TEMP_FILE, "w")
            f.write(code)
            f.close()
            shell.run(TEMP_FILE)
            fs.delete(TEMP_FILE)
        else
            print("Server neodpověděl.")
        end
    end
end
