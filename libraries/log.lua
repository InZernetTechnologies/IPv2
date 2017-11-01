-- Log Module
-- By lifewcody
-- Last Updated 2017.04.04.21.23

local moduleInformation = {
	name = "log",
	version = "1.0.0",
	dependencies = {
		["cache"] = "cache.lua"
	}
}

local vLog = {}

-- LOCAL VARIABLES
local logLevel = 0

local logEvents = {
	["EMERG"] = colors.red,
	["ALERT"] = colors.red,
	["CRIT"] = colors.orange,
	["ERR"] = colors.orange,
	["WARN"] = colors.yellow,
	["NOTICE"] = colors.yellow,
	["INFO"] = colors.lightBlue,
	["DEBUG"] = colors.blue,
}

local logLevels = {
	[0] = {
		"EMERG",
		"ALERT",
		"CRIT",
		"ERR",
		"WARN",
		"NOTICE",
		"INFO",
		"DEBUG",
	},
	[1] = {
		"EMERG",
		"ALERT",
		"CRIT",
		"ERR",
		"WARN",
		"NOTICE",
		"INFO",
	},
	[2] = {
		"EMERG",
		"ALERT",
		"CRIT",
		"ERR",
		"WARN",
		"NOTICE",
	},
	[3] = {
		"EMERG",
		"ALERT",
		"CRIT",
		"ERR",
		"WARN",
	},
	[4] = {
		"EMERG",
		"ALERT",
		"CRIT",
		"ERR",
	},
	[5] = {
		"EMERG",
		"ALERT",
		"CRIT",
	},
	[6] = {
		"EMERG",
		"ALERT",
	},
	[7] = {
		"EMERG",
	},
	[8] = {},

}

-- LOG FUNCTIONS
function log(...)
	local args = {...}

	if #args >= 1 then
		table.insert(vLog, os.clock() .. " >> [" .. string.upper(args[1]) .. "] [" .. args[2] .. "]")
		if logEvents[string.upper(args[1])] ~= nil then
			local isInLogLevels = false
			for i=1, #logLevels[logLevel] do
				if logLevels[logLevel][i] == string.upper(args[1]) then
					isInLogLevels = true
				end
			end
			if isInLogLevels then
				local before = term.getTextColor()
				term.setTextColor(logEvents[string.upper(args[1])])
				print(args[2])
				term.setTextColor(before)
			end
		end
	else
		return false
	end
end

function clear()
	vLog = {}
end

function setLogLevel(level)
	if tonumber(level) then
		logLevel = tonumber(level)
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
    vLog = cache.get("log")
end

function unload()
    local cache = _G.modules.cache
    cache.set("log", vLog)
end