-- Load the Library Manager (libman)
os.loadAPI("/disk/libraries/libman.lua")
local libman = (_G["libman.lua"] == nil and _G.libman or _G["libman.lua"]) -- CC fucked up everything. So in CC1.7.9 we use _G["libman.lua"] but in 1.8.0p1 we use _G.libman

-- Set the library folder and load all the libraries
libman.init("/disk/libraries/")
libman.load()

local continue = true -- If our program should keep going

-- Assign all the libraries we need from _G to a variable
local update = _G.modules.update
local modem = _G.modules.modem
local PDU = _G.modules.pdu
local cache = _G.modules.cache
local route = _G.modules.route
local log = _G.modules.log

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
                        modem.open(MAC, v) -- Open it
                    end
                end
            end
            cache.set("modems", _G.modems)
        end,
        [ "stop" ] = function()
            for MAC, tbl in pairs(_G.modems) do
                print("Shutting down [" .. MAC .. "]")
                for _, vlan in pairs(tbl["VLAN"]) do
                    modem.close(MAC, vlan)
                end
            end
        end
    }
}

-- Takes care of anything we need to load before startup
function startup()
    service.network.start()
    parallel.waitForAny(CLI, modem_listener) -- Start CLI() and modem_listener()
end

local commands = {
    [ "exit" ] = function()
        print("Shutting down")
        libman.unload()
        continue = false
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
    end
}

-- Handles CLI input
function CLI()
    while continue do
        write("[tty1@" .. os.getComputerID() .. "]# ")
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
            commands[splitCommand[1]](arguments)
        else
            printError(tostring(splitCommand[1]) .. ": command not found")
        end
    end
end

function handler(frame, side, vlan)
    if (not PDU.frameCheck(frame)) then return false end
    local route = route.getRoute(frame[1])
    if (route == true) then
        if (tonumber(frame[3]) == 31)
            RIP.process(frame[4])
        end
        print("Routing to router")
    else
        if (route == false) then
            print("We don't know where it goes, broadcast")
        else
            if (type(route) == "string") then
                print("Route to " .. route)
            else
                print("Critial routing error: " .. tostring(route))
            end
        end
    end
end

-- handles packets
function modem_listener()
    while continue do
        local event, side, vlan, returnVlan, frame, distance = os.pullEvent("modem_message")
        handler(frame, side, vlan)
    end
end

startup() -- Launch it