local moduleInformation = {
    name = "route",
    version = "1.0.0"
}

function isBroadcast(MAC)
    if (string.upper(MAC) == "FFFFFFFFFFFF") then
        return true
    else
        return false
    end
end

function isItForMe(MAC)
    if (_G.modems[MAC]) then
        return true
    end
end

function getMACRoute(MAC)
    if (string.upper(MAC) == "FFFFFFFFFFFF") then
        return true
    end
    if (_G.routes[MAC] == nil) then
        if (_G.modems[MAC] == nil) then
            return false
        else
            return true
        end
    else
        return _G.routes[MAC]
    end
    -- TRUE = The Router itself
    -- FALSE = We don't know
    -- STRING = Send out this interface's MAC
end


function addToMACRoute(MAC, modemMAC)
    if (MAC == "FFFFFFFFFFFF") then -- If it's a boradcast don't add it
        return false
    end
    _G.routes[MAC] = modemMAC
end

function getIPRoute(IP)
    if (_G.routes.IP[IP]) then
        return _G.routes.IP[IP]
    else
        return false
    end
end

-- REQUIRED MODULE FUNCTIONS
function getModuleInformation()
    return moduleInformation
end

function load()
    local cache = _G.modules.cache
    _G.routes = cache.get("routes")
end

function unload()
    local cache = _G.modules.cache
    cache.set("routes", _G.routes)
end