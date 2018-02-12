local component = require("component")
local serialization = require("serialization")
local m = component.modem
local ecell = component.proxy(component.list("energy_device")())
local msg_data = {}

local hub_adress = "db36e32b-fc33-462a-91f5-08689ed62120"

while true do
    msg_data["current"] = ecell.getEnergyStored()
    msg_data["max"] = ecell.getMaxEnergyStored()
    m.send(hub_adress, 8000, serialization.serialize(msg_data))
    os.sleep(1)
end