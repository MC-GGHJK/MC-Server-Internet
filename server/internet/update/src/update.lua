local nverurl = 'https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/version/version.txt'

local nver = "?"
local r = http.get(nverurl)

if r then
  nver = tonumber(r.readAll()) or "?"
  r.close()
end

print("Welcome to the Update Client!")
sleep(2)
print("Checking for updates...")
print("Loading updater...")
sleep(5)
sleep(2)
print("Current newest version: "..nver)
print("Launching updater...")
sleep(2)
shell.run('pastebin run vkKmg99G')