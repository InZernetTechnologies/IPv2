-- Load the Library Manager (libman)
os.loadAPI("/disk/libraries/libman.lua")
local libman = _G["libman.lua"]

-- Set the library folder and load all the libraries
libman.init("/disk/libraries/")
libman.load()

-- Assign all the libraries we need from _G to a variable
local update = _G.modules.update
local modem = _G.modules.modem
local PDU = _G.modules.pdu

-- Takes care of anything we need to load before startup
function startup()

    parallel.waitForAny(CLI, modem_listener) -- Start CLI() and packetHandler()
end

local commands = {}

-- Handles CLI input
function CLI()
    while true do
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