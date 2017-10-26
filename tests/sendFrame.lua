local goodFrame = {
    "000000000001",
    "000000000001",
    2048,
    {
        "this",
        "is",
        "the",
        "data"
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
modem.transmit(1, 1, goodFrame)