local moduleInformation = {
    name = "cache",
    version = "1.0.1",
}

local cachePath = "/IPv2/"

-- LOCAL UTILITY FUNCTIONS
local function openCacheFile(name, mode)
    return fs.open(cachePath .. name, mode)
end

local function cacheFileExists(name)
    return fx.exists(cachePath .. name)
end

local function readCacheData(fileData)
    if fileData == nil then
        print("File is nil")
        return {}
    else
        return textutils.unserialize(fileData)
    end
end

-- MODULE SPECIFIC FUNCTIONS
function set(name, data)
    local fileStream = openCacheFile(name, "w")
    fileStream.write(textutils.serialize(data))
    fileStream.close()
end

function get(name)
    if not cacheFileExists(name) then
        return {}
    else
        local fileStream = openCacheFile(name, "r")
        local file = fileStream.readAll()
        fileStream.close()
        return readCacheData(file)
    end
end

-- REQUIRED MODULE FUNCTIONS
function getModuleInformation()
    return moduleInformation
end

function load()
    if not fs.exists("/IPv2") then
        fs.makeDir("/IPv2")
    end
end

function unload()
    
end
