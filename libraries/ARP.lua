local moduleInformation = {
    name = "ARP",
    version = "1.0.0"
}

local ARPCache = {}

function set(MAC, IP)
    ARPCache[MAC] = IP
end

function get(KEY)
    if (ARPCache[KEY] ~= nil) then
        return ARPCache[KEY]
    else
        return false
    end
end

function isGood(packet)
    if (packet[1] == nil) then return false end
    if (packet[2] == nil) then return false end
    return true
end

function handle(packet)
    if tonumber(packet[5]) == 1 then

    elseif tonumber(packet[5] == 2) then

    else
    
    end
end

-- REQUIRED MODULE FUNCTIONS
function getModuleInformation()
    return moduleInformation
end

function load()
    
end

function unload()

end
