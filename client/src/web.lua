local path = "gghjk-system/web-client.lua"

local vaild = fs.exists(path)
if vaild == false then
print("File doesnt exist")
elseif vaild == true then
shell.run(path)
end 
