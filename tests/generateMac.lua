os.loadAPI("/disk/libraries/modem.lua")
local modem = (_G["modem.lua"] == nil and _G.modem or _G["modem.lua"])
print("========== MAC TABLE ==========")
for k, v in ipairs(rs.getSides()) do
    print("[" .. v.. "] >>> [" .. modem.getMAC(v) .. "]")
end
print("This computer is >>> " .. modem.getCCID())