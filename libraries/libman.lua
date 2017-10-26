local moduleDir = ""

-- Load the module with the path supplied
function load_module(_sPath)

	-- sName is the name of the file, not the full filename
	local sName = fs.getName(_sPath)

	if (not fs.exists(_sPath) == true) then
		printError("[libman]: Could not find " .. sName)
		return false
	end

	-- tbh idk what this does, but i copied it from CC's bios
    local tEnv = {}
    setmetatable( tEnv, { __index = _G } )

	-- Checks the file to make sure it's error free
    local fnAPI, err = loadfile( _sPath, tEnv )
    if fnAPI then
        local ok, err = pcall( fnAPI )
        if not ok then
            printError( err )
            return false
        end
    else
        printError( err )
        return false
    end
    

	-- For each public function, put that into the table tAPI	
    local tAPI = {}
    for k,v in pairs( tEnv ) do
        if k ~= "_ENV" then
            tAPI[k] =  v
        end
    end

	-- Make sure that the 3 required functions are there, if not stop loading.
	if type(tAPI.getModuleInformation) ~= "function" or type(tAPI.load) ~= "function" or type(tAPI.unload) ~= "function" then
		printError("[libman]: Failed to load " .. sName .. ". One or more required functions is missing.")
		return false
	end

	-- Make sure the dependencies is either false or not there (nil)
	if not tAPI.getModuleInformation().dependencies == false and not tAPI.getModuleInformation().dependencies ~= nil then
		-- For each dependency
		for k, v in pairs(tAPI.getModuleInformation().dependencies) do
			-- If it is not loaded, attempt to load the module
			if not isLoaded(k) == true then
				print("[libman]: Attempting to load dependency [" .. v .. "]")
				if (load_module(moduleDir .. v) == false) then
					printError("[libman]: Failed to load dependency")
					printError("[libman]: Failed to load [" .. sName .. "]")
					break
				end
			else
				print("[libman]: Dependency already loaded [" .. v .. "]")
			end
		end
	end

	-- See if the module existed before
	if (_G.modules[tAPI.getModuleInformation().name] ~= nil) then
		-- Since it is, we will erase it (set it to nil), so we don't have to keep restarting the computer
		_G.modules[tAPI.getModuleInformation().name] = nil
	end

	-- Load module (from tAPI) to the correct name (from the function getModuleInformation())
	_G.modules[tAPI.getModuleInformation().name] = tAPI

	-- Run the load() function
	tAPI.load()

	print("[libman]: Successfully loaded [" .. sName .. "]")
end

-- check to see if the module is already loaded
function isLoaded(module)
	if type(_G.modules[module]) == "table" then
		return true
	else
		return false
	end
end

function unloadModule(_sName)
	if _sName ~= "_G" and type(_G.modules[_sName]) == "table" then
		-- Call our unload() method
		_G.moduled[_sName].unload()
		-- Actually clear it out
        _G.modules[_sName] = nil
    end
end

-- Initialize the Global module table
function init(vmoduleDir)
    moduleDir = vmoduleDir
	_G.modules = {}
end

-- For every module in /modules (except MM and the example) load it
function load()
    local files = fs.list(moduleDir)
    for i=1,#files do
        local j = files[i]
        if j ~= "libman.lua" and j ~= "example.lua" then
			print("[libman]: Attempting to load [" .. j .. "]")
            load_module(moduleDir .. j)
        end
    end
end