local comp = require "component"
local event = require "event"
local serialization = require "serialization"
local ghelper = require "glasses_helper"

local g = comp.glasses
local m = comp.modem

g.removeAll()

local base_y = 40
local base_x = 10
local base_width = 130
local base_text_scale = 0.8
local primary_color = {1, 1, 1 }
local primary_color_dark = {primary_color[1] - 0.2, primary_color[2] - 0.2, primary_color[3] - 0.2}

local tab_functions = {
    [1] = function() os.execute("home_hud.lua") os.exit() end,
    [2] = function() os.execute("draconic_energy_sphere_hud.lua") os.exit() end,
    [3] = function() os.execute("entity_sensor_hud.lua") os.exit() end,
    [4] = function() os.execute("time_widget.lua") end,
    [5] = function() g.removeAll() end,
    [6] = function() g.removeAll() os.exit() end
}

m.open(8000)
m.open(8001)
m.open(8002)

ghelper.bgBox(base_x - 4, base_y - 10, 46, base_width, primary_color_dark)
headline = ghelper.headlineText("Home", base_x, base_y, base_width, base_text_scale, primary_color)

while true do
    local _, _, _, port, _, message = event.pull("modem_message")
    local msg = serialization.unserialize(message)

    if port == 8001 and msg[1] ~= nil then
        print("executing function: "..msg[1])
        tab_functions[msg[1]]()
    end
end

