-- Minimal Rednet Client (bez UI, čistě text)
local SERVER_ID = 107
local TEMP_FILE = ".website.lua"

-- otevření modemu
local modem = peripheral.find("modem")
if not modem then error("Žádný modem nenalezen!") end
rednet.open(peripheral.getName(modem))

print("[CLIENT] Připojen, čekám na zadání domény.")

while true do
    io.write("Doména: ")
    local domain = read()

    -- kontrola vstupu
    if not domain or domain == "" then
        print("[CLIENT] Neplatná doména.")
    else
        -- lowercase a trim
        domain = domain:lower():gsub("^%s*(.-)%s*$", "%1")

        -- poslat požadavek
        rednet.send(SERVER_ID, domain)

        -- čekání na odpověď (timeout 5s)
        local sender, code = rednet.receive(nil, 5)

        -- validace odpovědi
        if sender == SERVER_ID and code and type(code) == "string" then
            -- zapis do TEMP_FILE
            local f = fs.open(TEMP_FILE, "w")
            f.write(code)
            f.close()

            print("[CLIENT] Kód přijat, spouštím...")
            local success, err = pcall(function()
                shell.run(TEMP_FILE)
            end)

            if not success then
                print("[CLIENT] Chyba při spouštění: "..tostring(err))
            else
                print("[CLIENT] Program ukončen.")
            end

            fs.delete(TEMP_FILE)
        else
            print("[CLIENT] Server neodpověděl nebo poslal neplatná data.")
        end
    end
end-- Minimal Rednet client (fix nil)
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
