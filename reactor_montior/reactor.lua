local comp = require "component"
local serialization = require "serialization"
local m = comp.modem
local r = comp.br_reactor
local c = comp.capacitor_bank
local msg_data = {}

local rod_count = r.getNumberOfControlRods()
local hub_adress = "13d9efb3-05a5-4cef-b40d-1fde878df1ab"

msg_data[9] = {}

while true do
    msg_data[1] = r.getActive()
    msg_data[2] = r.getFuelAmount()
    msg_data[3] = r.getWasteAmount()
    msg_data[4] = math.floor(r.getEnergyProducedLastTick())
    msg_data[5] = r.getFuelAmountMax()
    msg_data[6] = r.getFuelConsumedLastTick()
    msg_data[7] = c.getEnergyStored()
    msg_data[8] = c.getMaxEnergyStored()
    for i=1, rod_count-1 do
        msg_data[9][i] = r.getControlRodLevel(i)
    end
    m.send(hub_adress, 8000, serialization.serialize(msg_data))
    os.sleep(1)
end