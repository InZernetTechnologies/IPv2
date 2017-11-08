local arguments = { ... }

if #arguments == 0 then
    error("No tty specified")
end

local tty = arguments[1]

local continue = true -- If our program should keep going

local version = 1510100791

-- Assign all the libraries we need from _G to a variable
local update = _G.modules.update
local modem = _G.modules.modem
local cache = _G.modules.cache
local log = _G.modules.log
local IP = _G.modules.IP

local service = {
    [ "network" ] = {
        [ "start" ] = function ()
            local activeSides = modem.getActiveSides()
            for k, v in pairs(activeSides) do
                local MAC = modem.getMAC(k)
                if (_G.modems[MAC] == nil) then
                    -- Fresh modem, lets initialize :)
                    -- We're using the MAC as the Key because it makes for easier routing
                    if (v) then
                        -- It's wireless (⊙ ‿ ⊙)
                        _G.modems[MAC] = {
                            [ "WiFi"] = {
                                [ "channel" ] = math.random(150, 175), -- Open a random channel on 150 to 175
                                [ "SSID" ] = modem.getSSID(k), -- Generated the SSID. If it's on the top and CC ID is 1 then SSID is CC1TO
                                [ "password" ] = modem.generatePassword(6) -- Generates a 6 digit random password
                            }
                        }
                    else
                        _G.modems[MAC] = {
                            [ "VLAN" ] = {
                                1,
                            },
                        }
                    end
                    _G.modems[MAC]["side"] = k
                end
                print("Opening [" .. MAC .. "]")
                -- Now we can just open the modems, treat the old and new ones the same
                if (_G.modems[MAC]["WiFi"]) then
                    modem.openModemWiFi(MAC)
                else
                    for k, v in pairs(_G.modems[MAC]["VLAN"]) do -- For each VLAN
                        modem.openMAC(MAC, v) -- Open it
                    end
                end
            end
            cache.set("modems", _G.modems)
        end,
        [ "stop" ] = function()
            for MAC, tbl in pairs(_G.modems) do
                print("Shutting down [" .. MAC .. "]")
                for _, vlan in pairs(tbl["VLAN"]) do
                    modem.closeMAC(MAC, vlan)
                end
            end
        end
    }
}

-- Takes care of anything we need to load before startup
function startup()
    --[[print("Current version: " .. version)
    update.getVersionFile()
    print(update.get().iOS.router.cli)]]--
    oldPull = os.pullEvent
    os.pullEvent = os.pullEventRaw
    parallel.waitForAny(CLI, modem_listener) -- Start CLI() and modem_listener()
end

function shutdown()
    continue = false
    _G.tty[tty] = false
end

local interface

local commands = {
    [ "exit" ] = function()
        shutdown()
    end,
    [ "vlan" ] = function(arguments)
        if #arguments == 0 then
            return "vlan <interface MAC> <add/remove> <vlan #>"
        end
        if _G.modems[arguments[1]] then
            if not tonumber(arguments[3]) then
                return "VLAN is not a number"
            end
            if arguments[2] == "add" then
                for k, v in pairs(_G.modems[arguments[1]]["VLAN"]) do
                    if tonumber(v) == tonumber(arguments[3]) then
                        return "VLAN " .. v .. " is already on interface " .. arguments[1]
                    end
                end
                table.insert(_G.modems[arguments[1]]["VLAN"], arguments[3])
            elseif arguments[2] == "remove" then
                for k, v in pairs(_G.modems[arguments[1]]["VLAN"]) do
                    if tonumber(v) == tonumber(arguments[3]) then
                        _G.modems[arguments[1]]["VLAN"][k] = nil
                        return "Removed VLAN " .. v .. " from interface " .. arguments[1]
                    end
                    return "VLAN " .. arguments[3] .. " was not found"
                end
            else
                return "<add/remove>: Got " .. arguments[2]
            end
        else
            return "Modem does not exist"
        end
    end,
    [ "ifconfig" ] = function()
        for k, v in pairs(_G.modems) do
            print(k)
            for name, value in pairs(v) do
                if name == "VLAN" then
                    write("     VLANS:")
                    for _, vlan in pairs(value) do
                        write(" " .. vlan)
                    end
                    print("")
                end
            end
            local IP
            if (_G.modems[k]["IP"] ~= nil) then IP = _G.modems[k]["IP"] else IP ="Not set" end
            print("     IP: " .. IP)
        end
    end,

    [ "GGP" ] = function(arguments)
        if (#arguments == 0) then
            return "GGP <status/network>"
        end
        if arguments[1] == "status" then
            if arguments[2] == nil then
                print("Gateway-Gateway Protocol")
                print("     Status: " .. tostring(_G.configuration.GGP.status))
                print("     Networks advertised:")
                for _, network in pairs(_G.configuration.GGP.networks) do
                    print("         " .. network)
                end
                print("     Passive interfaces:")
                for _, int in pairs(_G.configuration.GGP.passive) do
                    print("         " .. int)
                end
                return
            end
            if arguments[2] == "on" then
                _G.configuration["GGP"]["status"] = true
                return "Gateway-Gateway Protocol on"
            elseif arguments[2] == "off" then
                _G.configuration["GGP"]["status"] = true
                return "Gateway-Gateway Protocol off"
            else
                return "GGP status <on/off>"
            end
        elseif arguments[1] == "add" then
            
        else
            return "GGP <status/network>"
        end
    end,

    [ "configuration" ] = function(arguments)
        if #arguments == 0 then
            return "configuration <view/reload>"
        end

        if arguments[1] == "view" then
            print(textutils.serialize(_G.configuration))
        elseif arguments[1] == "reload" then
            _G.configuration = _G.generateDefaultConfiguration()
            return "Configuration succesfully reloaded"
        end
    end,

    [ "service" ] = function(arguments)
        if #arguments == 0 then
            print("service <name> <reload>")
        end

        if arguments[1] == "network" then
            if arguments[2] == "reload" then
                service.network.stop()
                service.network.start()
            elseif arguments[2] == "stop" then
                service.network.stop()
            elseif arguments[2] == "start" then
                service.network.start()
            elseif arguments[2] == "reset" then
                write("Are you sure you want to reset the network? [Y/n] > ")
                local opt = io.read()
                if string.lower(opt) == "y" then
                    service.network.stop()
                    _G.modems = {}
                    service.network.start()
                else
                    return "Aborting..."
                end
            end
        end
    end,

    [ "continue-broadcast" ] = function(arguments)
        if (#arguments ~= 1) then
            return "continue-broadcast <on/off/status>"
        end
        if arguments[1] == "on" then
            _G.configuration["continue-broadcast"] = true
            return "Continue broadcast set to true"
        elseif arguments[1] == "off" then
            _G.configuration["continue-broadcast"] = false
            return "Continue broadcast set to false"
        elseif arguments[1] == "status" then
            print("Continue broadcast status: " .. tostring(_G.configuration["continue-broadcast"]))
        else
            return "continue-broadcast <on/off/status>"
        end
    end,
}

-- Handles CLI input
function CLI()
    while continue do
        write("[tty" .. tty .. "@" .. os.getComputerID() .. "]# ")
        local comm = read()

        local splitCommand = {}
        local arguments = {}

        for k in string.gmatch(comm, '[^ ]+') do
            table.insert(splitCommand, k)
        end

        for i=2, #splitCommand do
            table.insert(arguments, splitCommand[i])
        end

        if commands[splitCommand[1]] ~= nil then
            local no_error, message = pcall(commands[splitCommand[1]], arguments)
            if not no_error then
                print(message)
            end
            if message ~= nil then
                print(message)
            end
        else
            printError(tostring(splitCommand[1]) .. ": command not found")
            print("Available commands:")
            for k, _ in pairs(commands) do
                print("     " .. k)
            end
        end
    end
end

-- handles terminate event
function modem_listener()
    while continue do
        local event, side, vlan, returnVlan, frame, distance = os.pullEventRaw()
        if event == "terminate" then
            shutdown()
        end
    end
end

startup()