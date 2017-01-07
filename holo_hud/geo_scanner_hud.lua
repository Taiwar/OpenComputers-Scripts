local comp = require "component"
local ghelper = require "glasses_helper"
local event = require "event"
local serialization = require "serialization"

local g = comp.glasses

g.removeAll()

local box = ghelper.bgBox(10, 40, 45, 100, {1, 1, 1}, {0.1, 0.1, 0.1})
box.setHeadline("Geoscanner", 0.9, {1, 1, 1})
local info = box.addText("inactive", 5, 5 , 0.8, {0, 1, 0})

function displayScan()
    info.setText("received data")
end

function cleanExit(_, _)
    event.ignore("closeWidget")
    os.exit()
end

event.listen("closeWidget", cleanExit)

while true do
    local _, _, _, port, _, message = event.pull("modem_message")
    local msg = serialization.unserialize(message)

    if port == 8000 then
        displayScan(msg)
    end
end

