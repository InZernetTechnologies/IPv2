local moduleInformation = {
	name = "modem",
    version = "1.0.0",
    dependencies = {
        [ "cache" ] = "cache.lua"
    }
}

local sideTable = {
    [1] = "bottom",
    [2] = "top",
    [3] = "back",
    [4] = "front",
    [5] = "right",
    [6] = "left",
    [ "bottom" ] = 1,
    [ "top" ] = 2,
    [ "back" ] = 3,
    [ "front" ] = 4,
    [ "right" ] = 5,
    [ "left" ] = 6
}

function getSides()
    return sideTable
end

function getMAC(side)
  if not side then error("No side given",2) end
  side = tostring(side)
  if getSides()[side] then 
    local macBuffer = tostring(DecToBase(os.computerID() * 6 + getSides()[side],16))
    local MACaddr = string.rep("0",12-#macBuffer).. macBuffer
    return MACaddr
  end
end

function openModemWiFi(MAC)
    print("WiFi on " .. MAC)
    open(MAC, _G.modems[MAC]["WiFi"]["channel"])
	for k, v in pairs(_G.modems[MAC]["WiFi"]) do
		print(tostring(k) .. " >> " .. tostring(v))
	end
end

function open(MAC, vlan)
    peripheral.call(_G.modems[MAC]["side"], "open", vlan)
end

function generatePassword(length)
	local code
	local validChars = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	for i = 1, length do
		local idx = math.random(#validChars)
		if code == nil then
			code = validChars:sub(idx,idx)
		else
			code = code..validChars:sub(idx,idx)
		end
	end
	return code
end

function getSSID(side)
	return "CC" .. os.getComputerID() .. string.upper(string.sub(side,1,2))
end

function DecToBase(val,base)
	if val == 0 then return 0 end
	local b, k, result, d = base or 10, "0123456789ABCDEFGHIJKLMNOPQRSTUVW",""
	while val > 0 do
		val, d = math.floor(val/b), math.fmod(val,b)+1
		result = string.sub(k,d,d)..result
	end
	return result
end

local function getActiveSides()
	local as = {} -- Create empty table
	for s=1, 6 do -- For each side on the computer: right, back, etc
		if peripheral.getType(rs.getSides()[s]) == "modem" then -- If something is on that side and it is a modem
			as[rs.getSides()[s]] = peripheral.call(rs.getSides()[s], "isWireless") -- Set the table key to the side and set it to if it's wireless (true = wireless, false = modem)
		end
	end
	return as -- Return the table, empty or has entries
end

-- REQUIRED MODULE FUNCTIONS
function getModuleInformation()
    return moduleInformation
end

function load()
	
end

function unload()
    
end