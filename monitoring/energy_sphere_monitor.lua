local comp = require "component"
local serialization = require "serialization"
local m = comp.modem
local drs = comp.draconic_rf_storage
local msg_data = {}

local hub_adress = "c4f7e17c-a067-472d-af84-f86bd5c625da"

while true do
    msg_data[1] = drs.getEnergyStored()
    msg_data[2] = drs.getMaxEnergyStored()
    m.send(hub_adress, 8000, serialization.serialize(msg_data))
    os.sleep(1)
end