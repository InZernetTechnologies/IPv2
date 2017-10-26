local moduleInformation = {
    name = "pdu",
    version = "1.0.0"
}

function frameMACCheck(mac)
    if (#mac == 12) then
        return true
    else
        return false
    end
end

function frameCheck(frame)
    if not #frame == 4 then return false end -- Must be a table 6 in length
    if not (tonumber(frame[3])) then return false end -- Check if Type is a number
    if not frameMACCheck(frame[1]) or not frameMACCheck(frame[2]) then return false end -- The frame mac (to/from) must be valid macs
    if frame[4] == nil or frame[4] == {} then return false end -- Must contain some data
    return true -- If our frame meets all the criteria
end

function packetIPCheck(ip)
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

function packetCheck(packet)
    if not #packet == 6 then return false end -- Must be a table 6 in length
    if not (tonumber(packet[1]) == 2) then return false end -- Check IPv2
    if tonumber(packet[2]) ~= 1 and packet[2] ~= 6 and packet[2] ~= 17 then return false end -- Check ICMP, UDP, or TCP
    if not (tonumber(packet[3]) >= 1) then return false end -- TTL is greater or equal to 1
    if not packetIPCheck(packet[4]) or not packetIPCheck(packet[5]) then return false end -- The packet (to/from) must be numbers
    if packet[6] == nil or packet[6] == {} then return false end -- Must contain some data
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