local comp = require "component"
local event = require "event"
local serialization = require "serialization"
local ghelper = require "glasses_helper"

g = comp.glasses
m = comp.modem

base_y = 40
base_x = 10
base_width = 130
base_text_scale = 0.8
primary_color = {1, 1, 1 }
--primary_color = {0.467, 0, 1 }
primary_color_dark = {primary_color[1] - 0.2, primary_color[2] - 0.2, primary_color[3] - 0.2}

time_text = ghelper.infoText("", base_x + base_width, base_y, base_text_scale, primary_color)
time_text_id = time_text.getID()
doTimeLoop = true

function displayTime()
    local time = os.date("%H:%M", os.time())
    time_text.setText(time)
end

function checkCallback(_, _, _, port, _, _)
    if port == 8002 then
        doTimeLoop = false
    end
end

event.listen("modem_message", checkCallback)

while doTimeLoop == true do
    displayTime()
    os.sleep(1)
end

g.removeObject(time_text_id)