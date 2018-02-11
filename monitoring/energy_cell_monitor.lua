local component = require("component")
local serialization = require("serialization")
local m = component.modem
local ecell = component.proxy(component.list("energy_device")())
local msg_data = {}

local hub_adress = "654d6db4-a286-44f7-8556-c42c60875c11"

while true do
    msg_data["current"] = ecell.getEnergyStored()
    msg_data["max"] = ecell.getMaxEnergyStored()
    m.send(hub_adress, 8000, serialization.serialize(msg_data))
    os.sleep(1)
end