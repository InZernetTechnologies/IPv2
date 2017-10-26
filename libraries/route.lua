local moduleInformation = {
    name = "route",
    version = "1.0.0"
}

function getRoute(MAC)
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
    -- STRING = Send it to this MAC
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