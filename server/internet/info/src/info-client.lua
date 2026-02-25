local nverurl = 'https://raw.githubusercontent.com/MC-GGHJK/MC-Server-Internet/refs/heads/main/client/version/version.txt'

local nver = "?"
local r = http.get(nverurl)
local cver = getfenv()._VERSION:match("%d+%.%d+")

if r then
  nver = tonumber(r.readAll()) or "?"
  r.close()
end

local report_url = "https://github.com/MC-GGHJK/MC-Server-Internet/issues"
local web_url = "https://gghjk.qzz.io"
local discord_url = "https://discord.gghjk.qzz.io"
local chat_url = "https://chat.gghjk.qzz.io"
local github_url = "https://github.com/MC-GGHJK"


print("Latest version: " .. nver)

print("Web: " .. web_url)
print("Discord: " .. discord_url)
print("Chat Web: " .. chat_url)
print("GitHub: " .. github_url)
print("Report issues at: " .. report_url)
print("More at discord, #gghjk-internet. Support at discord.gghjk.qzz.io")
print("Support https://www.gghjk.qzz.io/support.php")
print("(c)2025 GGHJK - Internet browser 2026")

sleep(10)