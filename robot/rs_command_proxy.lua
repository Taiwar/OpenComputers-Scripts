local comp = require "component"
local sides = require "sides"
local event = require "event"

--local gen = comp.generator
local rs = comp.redstone
local m = comp.modem

local out_side = sides.front

m.open(8006)

while true do
    local _, _, _, _, _, message = event.pull("modem_message")

    rs.setOutput(out_side, message)
end
