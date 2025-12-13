-- client_main.lua

-- KONFIGURACE
local SERVER_ID = 10 -- ZMENTE na skutecne RedNet ID vaseho Serveru!
local SERVER_CHANNEL = 420

-- Stav klienta
local current_token = nil
local current_username = nil

-- --- INICIALIZACE MODEMU ---
local ok, err = pcall(rednet.open, "right") -- Zkuste pripojit modem, napr. na "right"
if not ok then
    print("CHYBA: Nelze otevrit RedNet modem! Zkontrolujte, zda je pripojen a zapnut.")
    print("Chyba: " .. tostring(err))
    return -- Ukonci se, POKUD NENI MODEM PRIPOJEN
end
print("RedNet modem inicializovan.")
----------------------------------


-- Jednoducha simulace "hase" pro prihlaseni (musi se shodovat s ACCOUNTS na serveru)
local function get_password_hash(password)
    if password == "12345" then return "f1b3c9d4" end -- Heslo pro 'janek'
    if password == "qwert" then return "a2e8b7c6" end -- Heslo pro 'petra'
    return ""
end

-- Hlavni funkce pro odesilani pozadavku na server
local function send_request(request_data)
    rednet.send(SERVER_ID, request_data, SERVER_CHANNEL)
    local sender, response = rednet.receive(SERVER_CHANNEL, 5) -- Ceka 5 sekund
    if response and response.type == "error" then
        print("CHYBA SERVERU: " .. response.error)
        return nil
    end
    return response
end

-- --- LOGIN ---
local function doLogin()
    print("--- PRIHLASENI ---")
    write("Uziv. jmeno: ")
    local username = read()
    write("Heslo: ")
    local password = read("*") -- Cte bez echo

    local response = send_request({
        type = "login",
        username = username,
        password_hash = get_password_hash(password)
    })

    if response and response.type == "login_success" then
        current_token = response.token
        current_username = username
        print("\n[OK] Prihlaseni uspesne! Vitejte, " .. username .. ".")
        return true
    else
        print("\n[CHYBA] Prihlaseni selhalo.")
        return false
    end
end

-- --- OPERACE SOUBORU ---
local function doFileOperation(op_type, path, content)
    if not current_token then
        print("Musite byt prihlasen pro pristup do cloudu! Pouzijte 'login'.")
        return
    end
    -- ... (zbytek funkce doFileOperation beze zmeny) ...
    local request_data = {
        type = op_type,
        token = current_token,
        path = path
    }

    if content then
        request_data.content = content
    end

    local response = send_request(request_data)

    if response then
        if op_type == "read" and response.type == "read_success" then
            print("\n--- OBSAH SOUBORU (" .. path .. ") ---")
            print(response.content)
        elseif op_type == "write" and response.type == "write_success" then
            print("\n[OK] Soubor " .. path .. " byl uspesne zapsan.")
        elseif op_type == "list" and response.type == "list_success" then
            print("\n--- SLOZKA (" .. path .. ") ---")
            for _, file in ipairs(response.files) do
                print("- " .. file)
            end
        end
    end
end


-- --- ZOBRAZENI NOVIN ---
local function displayNews()
    print("\n--- STAHUJI NEJNOVJESI ZPRAVY ---")

    local response = send_request({
        type = "news" -- Pozadavek na noviny nevyzaduje token
    })

    if response and response.type == "news_success" then
        
        local articles = response.articles
        if not articles or #articles == 0 then
            print("Zadny clanek nebyl nalezen.")
            return
        end

        print("--------------------------------------------------")
        print("          AKTUALNI ZPRAVY (" .. #articles .. " clanku)")
        print("--------------------------------------------------")
        
        for i = 1, #articles do
            local article = articles[i]
            print("## " .. article.title)
            print("   Datum: " .. article.date .. " | Autor: " .. article.author)
            print("   " .. article.content)
            print("--------------------------------------------------")
        end
    else
        print("Chyba pri stahovani zpráv.")
    end
end


-- --- HLAVNI LOOP KLIENTA ---

print("\nCloud klient spusten. Pro pristup k souborum se prihlaste.")

while true do
    
    -- Zobrazeni stavu prihlaseni
    local status = current_username and ("Prihlasen: " .. current_username) or "ODHLASEN"
    print("\n-------------------------------------------")
    print(status)
    print("Prikazy: login, news, read <cesta>, write <cesta>, list <cesta>, exit")
    print("Priklad: read dokumenty/smlouva.txt")
    write("> ")
    local input = read()
    local parts = {}
    for part in input:gmatch("%S+") do table.insert(parts, part) end
    
    local command = parts[1]
    local path = parts[2]
    
    if command == "login" then
        doLogin()
    elseif command == "news" then
        displayNews()
    elseif command == "read" and path then
        doFileOperation("read", path)
    elseif command == "list" and path then
        doFileOperation("list", path)
    elseif command == "write" and path then
        write("Obsah (ukoncit CTRL+T): ")
        local content = read()
        doFileOperation("write", path, content)
    elseif command == "exit" then
        print("Odpojeni...")
        rednet.close()
        break
    else
        print("Neznamy prikaz nebo chybna cesta.")
    end
end