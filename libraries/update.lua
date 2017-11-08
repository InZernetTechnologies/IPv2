-- Update Module
-- By lifewcody
-- Last Updated 2017.04.04.21.30

local moduleInformation = {
    name = "update",
    version = "1.0.0"
}

-- LOCAL VARIABLES
local version
local buildURL = "https://raw.githubusercontent.com/InZernetTechnologies/IPv2/master/version.cctbl"

-- UPDATE FUNCTION

function getVersionFile()
	if http.checkURL(buildURL) then
        local getVar = http.get(buildURL)
        version = textutils.unserialize(getVar.readAll())
        getVar.close()
		return true
    else
		return false
    end
end

function get()
    return version
end

-- REQUIRED MODULE FUNCTIONS
function getModuleInformation()
    return moduleInformation
end

function load()
    getVersionFile()
end

function unload()
    
end