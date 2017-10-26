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

-- Takes care of anything we need to load before startup
function startup()
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
    parallel.waitForAny(CLI, modem_listener) -- Start CLI() and packetHandler()
end

local commands = {
    [ "exit" ] = function()
        print("Shutting down")
        libman.unload()
        continue = false
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
    print(PDU.frame.check(frame))
end

-- handles packets
function modem_listener()
    while true do
        local event, side, vlan, returnVlan, frame, distance = os.pullEvent("modem_message")
        handler(frame, side, vlan)
    end
end

startup() -- Launch it