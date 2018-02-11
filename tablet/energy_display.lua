local event = require("event")
local term = require("term")
local component = require("component")
local serialization = require("serialization")

local m = component.modem
local gpu = component.gpu
local msg = {}
local hub_adress = "c4f7e17c-a067-472d-af84-f86bd5c625da"

function handleMessage(_, _, _, port, _, packet)
    term.clear()
    last_msg = "{"..port..": "..packet.."}"
    local msg = serialization.unserialize(packet)
    print("Last msg:")
    print(last_msg)
end

print("startup")
m.open(8000)
event.listen("modem_message", handleMessage)