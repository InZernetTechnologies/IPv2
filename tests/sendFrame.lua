local goodFrame = {
    "000000000005",
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
modem.transmit(1, 1, goodFrame)
print("Sent!")
