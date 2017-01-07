local comp = require "component"
local serialization = require "serialization"
local m = comp.modem
local geo = comp.geolizer
local msg_data = {}

local hub_adress = "13d9efb3-05a5-4cef-b40d-1fde878df1ab"

while true do
    m.send(hub_adress, 8000, serialization.serialize(msg_data))
    os.sleep(1)
end