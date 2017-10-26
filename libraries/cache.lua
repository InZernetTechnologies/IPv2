local moduleInformation = {
	name = "cache",
	version = "1.0.0",
}

function set(name, data)
    local fileStream = fs.open("/IPv2/" .. name, "w")
    fileStream.write(textutils.serialize(data))
    fileStream.close()
end

function get(name)
    if fs.exists("/IPv2/" .. name) == false then
        return textutils.unserialize("{}")
    else
        local fileStream = fs.open("/IPv2/" .. name, "r")
        local file = fileStream.readAll()
        fileStream.close()
        if file == nil then
            print("File is nil")
            return textutils.unserialize("{}")
        else
            return textutils.unserialize(file)
        end
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