local moduleInformation = {
    name = "pdu",
    version = "1.0.0"
}

local trafficClasses = {
    0,
    46,
    10,
    12,
    18,
    20
}

local nextHeader = {
    1,
    3,
    6,
    17
}

function MACCheck(mac)
    if (#mac == 12) then
        return true
    else
        return false
    end
end

function IPCheck(ip)
    local pIP = {} -- Create blank table
    if ip == nil then return false end -- If it's nil, forget it
    for octect in string.gmatch(ip, "[^.]+") do -- Find the . and put each side of it into a table
        table.insert(pIP, octect) -- Insert here ;)
    end -- Lua would be angry if we didn't end
    if #pIP == 2 then -- Our IPs are 2 octets, not more, not less -- 2.
        if tonumber(pIP[1]) and tonumber(pIP[2]) then return true end -- If they're both numbers, cool
    end
    return false -- If they're not, welp.
end

function frameCheck(frame)
    if frame == nil then return false end
    if not #frame == 4 then return false end -- Must be a table 4 in length
    if not (tonumber(frame[3])) then return false end -- Check if Type is a number
    if not MACCheck(frame[1]) or not MACCheck(frame[2]) then return false end -- The frame mac (to/from) must be valid macs
    if frame[4] == nil or frame[4] == {} then return false end -- Must contain some data
    return true -- If our frame meets all the criteria
end

function packetCheck(packet)
    if not #packet == 7 then return false end -- Must be a table 7 in length
    if not (tonumber(packet[1]) == 2) then return false end -- Check IPv2
    if not (tonumber(packet[2])) then return false end -- Check traffic class
    if not tonumber(packet[3]) then return false end -- Check if a number for next header
    if not (tonumber(packet[4]) >= 1) then return false end -- Hope Limit is greater or equal to 1
    if not IPCheck(packet[5]) or not IPCheck(packet[6]) then return false end -- The packet (to/from) must be numbers
    if packet[7] == nil or packet[7] == {} then return false end -- Must contain some data
    return true -- If our packet meets all the criteria
end

-- REQUIRED MODULE FUNCTIONS
function getModuleInformation()
    return moduleInformation
end

function load()
    
end

function unload()
    
end