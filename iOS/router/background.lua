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
local ARP = _G.modules.ARP

local configuration, oldPull

local service = {
    [ "network" ] = {
        [ "start" ] = function ()
            local activeSides = modem.getActiveSides()
            for k, v in pairs(activeSides) do
                local interfaceIP = os.computerID() + modem.getSides()[k] .. ".0"
                log.log("INFO", "Interface IP is " .. interfaceIP)
                local MAC = modem.getMAC(k)
                if (_G.modems[MAC] == nil) then
                    log.log("DEBUG", "Found new modem")
                    -- Fresh modem, lets initialize :)
                    -- We're using the MAC as the Key because it makes for easier routing
                    if (v) then
                        log.log("DEBUG", "Wireless modem")
                        -- It's wireless (⊙ ‿ ⊙)
                        log.log("DEBUG", "Generating WiFi information")
                        _G.modems[MAC] = {
                            [ "WiFi"] = {
                                [ "channel" ] = math.random(150, 175), -- Open a random channel on 150 to 175
                                [ "SSID" ] = modem.getSSID(k), -- Generated the SSID. If it's on the top and CC ID is 1 then SSID is CC1TO
                                [ "password" ] = modem.generatePassword(6) -- Generates a 6 digit random password
                            }
                        }
                    else
                        log.log("DEBUG", "Wired modem")
                        _G.modems[MAC] = {
                            [ "VLAN" ] = {
                                1,
                            },
                        }
                    end
                    log.log("DEBUG", "Setting modem [" .. MAC .. "]")
                    _G.modems[MAC]["side"] = k
                    _G.modems[MAC]["IP"] = interfaceIP
                end
                _G.modems[MAC]["IP"] = interfaceIP
                log.log("INFO", "Opening modem [" .. MAC .. "]")
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
                log.log("INFO, Shutting down [" .. MAC .. "]")
                for _, vlan in pairs(tbl["VLAN"]) do
                    modem.closeMAC(MAC, vlan)
                end
            end
        end
    }
}

-- Takes care of anything we need to load before startup
function startup()
    log.log("DEBUG", "=== STARTING ===")
    oldPull = os.pullEvent
    os.pullEvent = os.pullEventRaw
    log.log("DEBUG", "Starting network services")
    service.network.start()
    log.log("INFO", "Loading configuration")
    _G.configuration = cache.get("configuration")
    if next(_G.configuration) == nil then
        print(#_G.configuration)
        log.log("WARN", "Configuration is blank. Ignore if first time starting up")
        _G.configuration = _G.generateDefaultConfiguration()
        log.log("INFO", "Generating default configuration")
    end
    log.log("DEBUG", "Start modem listener")
    modem_listener()
end

_G.generateDefaultConfiguration = function()
    local defaultConfiguration = {
        [ "continue-broadcast" ] = false,
        [ "GGP" ] = {
            [ "status" ] = false,
            [ "networks" ] = {},
            [ "passive" ] = {}
        }
    }
    return defaultConfiguration
end

function shutdown()
    continue = false
    print("Shutting down")
    cache.set("configuration", _G.configuration)
    libman.unload()
    os.pullEvent = oldPull
end

function handler(frame, side, vlan)
    if frame == nil then
        log.log("DEBUG", "Frame was nil")
        return false
    end
    if (not PDU.frameCheck(frame)) then log.log("INFO", "The frame was bad") return false end -- If it is a bad frame or not

    route.addToMACRoute(frame[2], modem.getMAC(side)) -- -- We know this mac is from that side. Ignored broadcast

    if (route.isBroadcast(frame[1])) then
        log.log("DEBUG", "Accepting Broadcast Frame")
    end
    if (route.isItForMe(frame[1])) then
        log.log("DEBUG", "Accepting Frame")
    end
    -- Accepts broadcasts and frames with a MAC of one of the modems, everything else we can ignore.
    if (tonumber(frame[3]) == 2048) then -- If the Ethernet contains IPv2
        log.log("DEBUG", "The frame is IPv2")
        local packet = frame[4] -- Strips the frame
        if (not PDU.packetCheck(packet)) then log.log("INFO", "We have a bad IPv2 packet") return false end --It's a bad packet
    elseif (tonumber(frame[3]) == 2054) then
        log.log("DEBUG", "The frame is ARP")

    else
        log.log("DEBUG", "Type is something else: " .. frame[3])
    end

    if (route.isBroadcast(frame[1]) and _G.configuration["continue-broadcast"]) then
        modem.broadcastFrameExcept(side, vlan, frame)
    end

end

-- handles packets
function modem_listener()
    while continue do
        local event, side, vlan, returnVlan, frame, distance = os.pullEventRaw()
        if event == "modem_message" then
            handler(frame, side, vlan)
        elseif event == "terminate" then
            shutdown()
        end
    end
end

startup() -- Launch it