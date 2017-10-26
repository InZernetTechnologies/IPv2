os.loadAPI("/disk/libraries/modem.lua")
print("========== MAC TABLE ==========")
for k, v in ipairs(rs.getSides()) do
    print("[" .. v.. "] >>> [" .. _G["modem.lua"].getMAC(v) .. "]")
end