local goodFrameWithGoodIPv2 = {
    "000000000013",
    "000000000003",
    2048,
    {
        2,
        0,
        17,
        16,
        "1.1",
        "1.2",
        {
            "this",
            "is",
            "my",
            "data",
        }
    }
}

local goodBroadcastFrame = {
    "FFFFFFFFFFFF",
    "000000000003",
    2048,
    {
        2,
        0,
        17,
        16,
        "1.1",
        "1.2",
        {
            "this",
            "is",
            "my",
            "data",
        }
    }
}

local badFrame = {
    1,
    2,
    "98b",
}
write("What side do you want to conduct the test? > ")
local s = io.read()

local modem = peripheral.wrap(s)
write("How many times? > ")
local times = io.read()
write("Interval (s) > ")
local interval = tonumber(io.read())
for i=1,times do
    modem.transmit(1, 1, goodBroadcastFrame)
    sleep(interval)
end
print("Sent!")
