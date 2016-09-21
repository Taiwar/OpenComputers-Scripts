local comp = require "component"
local event = require "event"
local serialization = require "serialization"
local ghelper = require "glasses_helper"

g = comp.glasses
m = comp.modem
s = comp.motion_sensor

g.removeAll()

base_y = 40
base_x = 10
base_width = 130
base_text_scale = 0.8
primary_color = {1, 1, 1 }
--primary_color = {0.467, 0, 1 }
primary_color_dark = {primary_color[1] - 0.2, primary_color[2] - 0.2, primary_color[3] - 0.2}

tab_functions = {
    [1] = function() os.execute("home_hud.lua") os.exit() end,
    [2] = function() os.execute("reactor_hud.lua") os.exit() end,
    [3] = function() os.execute("sensor_hud.lua") os.exit() end,
    [4] = function() os.execute("time_widget.lua") end,
    [5] = function() g.removeAll() end,
    [6] = function() g.removeAll() os.exit() end
}

m.open(8001)

ghelper.addBgBox(base_y, 46)
ghelper.addHeadlineText("Sensor Grid", base_y)

function detectMotion()
    local _, _, x, y, z, entity_name = event.pull("motion")
    print("X: "..x.." Y: "..y.." Z: "..z.." Name: "..entity_name)
    os.sleep(1)
end

while true do
    local _, _, _, port, _, message = event.pull("modem_message")
    local msg = serialization.unserialize(message)

    if port == 8001 then
        print("executing function: "..msg[1])
        tab_functions[msg[1]]()
    end
end

