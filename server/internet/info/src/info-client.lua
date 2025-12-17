local nverurl = 'https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/version/version.txt'

local nver = "?"
local r = http.get(nverurl)
local cver = getfenv()._VERSION:match("%d+%.%d+")

if r then
  nver = tonumber(r.readAll()) or "?"
  r.close()
end

print("Current version: " .. cver)
print("Latest version: " .. nver)
if tonumber(cver) < nver then
  print("A new version " .. nver .. " is available! Please update your client.")
else
  print("You are up to date!")
end
print("More at discord, #gghjk-internet.")
print("(c)2025 GGHJK - Internet browser 2025")