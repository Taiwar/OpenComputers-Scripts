local comp = require "component"
local event = require "event"
local ghelper = require "glasses_helper"

local g = comp.glasses

local base_y = 40
local base_x = 10
local base_width = 130
local base_text_scale = 0.8
local primary_color = {1, 1, 1 }

local time_text = ghelper.infoText("", base_x + base_width, base_y, base_text_scale, primary_color)
local time_text_id = time_text.getID()
local doTimeLoop = true

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

event.ignore("modem_message", checkCallback)
g.removeObject(time_text_id)