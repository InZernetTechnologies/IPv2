local moduleInformation = {
    name = "modem",
    version = "1.0.1",
    dependencies = {
        [ "cache" ] = "cache.lua",
        [ "log" ] = "log.lua"
    }
}

local sideTable = {
    [1] = "bottom",
    [2] = "top",
    [3] = "back",
    [4] = "front",
    [5] = "right",
    [6] = "left",
    [ "bottom" ] = 1,
    [ "top" ] = 2,
    [ "back" ] = 3,
    [ "front" ] = 4,
    [ "right" ] = 5,
    [ "left" ] = 6
}

-- LOCAL UTILITY FUNCTIONS
local function getMacBuffer(offset)
    return tostring(DecToBase(os.computerID()*7 + offset, 16))
end

local function getMacAddr(macBuffer)
    return string.rep("0", 12 - #macBuffer) .. macBuffer
end

local function hasModem(side)
    return peripheral.getType(rs.getSides()[side]) == "modem"
end

-- MODULE SPECIFIC FUNCTIONS
function getSides()
    return sideTable
end

function broadcastFrame(side, vlan, frame, mac)
    print("Broadcasting on " .. mac .. " [" .. side .. "]")
    peripheral.call(side, "transmit", vlan, vlan, frame)
end

function broadcastPacket()

end

function broadcastFrameExcept(side, vlan, frame)
    for MAC, tbl in pairs(_G.modems) do
        if side ~= tbl.side then
            broadcastFrame(tbl.side, vlan, frame, MAC)
        else
            print("Skipping broadcast on " .. MAC)
        end
    end
end

function getMAC(side)
    if not side then error("No side given", 2) end
    side = tostring(side)
    if getSides()[side] then 
        return getMacAddr(getMacBuffer(sideTable[side]))
    end
end

function getCCID()
    return getMacAddr(getMacBuffer(7))
end

function openModemWiFi(MAC)
    print("WiFi on " .. MAC)
    openMAC(MAC, _G.modems[MAC]["WiFi"]["channel"])
    for k, v in pairs(_G.modems[MAC]["WiFi"]) do
        print(tostring(k) .. " >> " .. tostring(v))
    end
end

function closeMAC(MAC, vlan)
    peripheral.call(_G.modems[MAC]["side"], "close", vlan)
end

function openMAC(MAC, vlan)
    peripheral.call(_G.modems[MAC]["side"], "open", vlan)
end

function generatePassword(length)
    local code
    local validChars = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    for i = 1, length do
        local idx = math.random(#validChars)
        if code == nil then
            code = validChars:sub(idx, idx)
        else
            code = code .. validChars:sub(idx, idx)
        end
    end
    return code
end

function getSSID(side)
    return "CC" .. os.getComputerID() .. string.upper(string.sub(side, 1, 2))
end

function DecToBase(val, base)
    if val == 0 then return 0 end
    local b, k, result, d = base or 10, "0123456789ABCDEFGHIJKLMNOPQRSTUVW", ""
    while val > 0 do
        val, d = math.floor(val / b), math.fmod(val, b) + 1
        result = string.sub(k, d, d) .. result
    end
    return result
end

function getActiveSides()
    local activeSides = {}
    for side = 1, 6 do
        if hasModem(side) then
            print("Active: " .. rs.getSides()[side] .. " as " .. peripheral.getType(rs.getSides()[side]))
            activeSides[rs.getSides()[side]] = peripheral.call(rs.getSides()[side], "isWireless") -- Set the table key to the side and set it to if it's wireless (true = wireless, false = modem)
        end
    end
    return activeSides
end

-- REQUIRED MODULE FUNCTIONS
function getModuleInformation()
    return moduleInformation
end

function load()
    local cache = _G.modules.cache
    _G.modems = cache.get("modems")
end

function unload()
    local cache = _G.modules.cache
    cache.set("modems", _G.modems)
end
