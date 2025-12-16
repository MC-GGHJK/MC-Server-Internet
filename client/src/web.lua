local path = "gghjk-system/web-client.lua"

local vaild = fs.exists(path)
if vaild == false then
print("File doesnt exist")
print("Please reinstall the client via the installer.")
print("Try again.")
print ("")
print("Trying to reinstall the client...")
sleep(3)
shell.run("pastebin run vkKmg99G")
elseif vaild == true then
shell.run(path)
end 
