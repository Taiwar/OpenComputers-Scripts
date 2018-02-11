local comp = require "component"
local event = require "event"
local serialization = require "serialization"
local ghelper = require "glasses_helper"

local g = comp.glasses

g.removeAll()

local base_y = 40
local base_x = 10
local base_width = 125
local base_text_scale = 0.8
local primary_color = {0.72, 0.44, 1}
local primary_color_dark = {primary_color[1] - 0.25, primary_color[2] - 0.25, primary_color[3] - 0.25}

local c_energy = 0
local energy_box = 0
local capacity_end_box
local capacity_start_box

function roundTo(nmbr, digits)
    local shift = 10 ^ digits
    return math.floor( nmbr*shift + 0.5 ) / shift
end

function initPowerDisplay(y)
    energy_box = g.addRect()
    capacity_end_box = g.addRect()
    capacity_start_box = g.addRect()

    capacity_start_box.setSize(0.8, 10.8)
    capacity_start_box.setPosition(base_x - 0.8, y-0.4)
    capacity_start_box.setColor(primary_color_dark[1], primary_color_dark[2] , primary_color_dark[3])

    capacity_end_box.setSize(0.8, 10.8)
    capacity_end_box.setPosition(base_x + base_width - 10, y-0.4)
    capacity_end_box.setColor(primary_color_dark[1], primary_color_dark[2] , primary_color_dark[3])

    energy_box.setColor(primary_color[1], primary_color[2] , primary_color[3])
    energy_box.setAlpha(0.9)
end

function updatePowerDisplay(energy, capacity, y)
    local energy_ratio = energy/capacity
    local energy_width = energy_ratio*100*((base_width - 10)/100)

    energy_box.setSize(energy_width, 10)
    energy_box.setPosition(base_x, y)
end

local box = ghelper.bgBox(base_x - 4, base_y - 10, base_width, 45, primary_color_dark, primary_color)
box.setHeadline("Energy", base_text_scale, primary_color)
local power_info = box.addText("", 1, 10, base_text_scale, primary_color)
local net_energy_info = box.addText("", 1, 20, base_text_scale, primary_color)
initPowerDisplay(base_y + 20)
power_info.setText("Waiting for signal")

function calculateNetEnergy(curr_energy)
    local energy_dif = curr_energy - c_energy

    net_energy_info.setText("Net-Energy in kRF/t: "..roundTo((energy_dif/1000)/20, 2))
    if energy_dif < 0 then
        net_energy_info.setColor(1, 0, 0)
    elseif energy_dif == 0 then
        net_energy_info.setColor(1, 1, 1)
    else
        net_energy_info.setColor(0, 1, 0)
    end

    c_energy = curr_energy
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
        power_info.setText("Energy stored in GRF: "..roundTo(msg[1]/1000000000, 2))
        calculateNetEnergy(msg[1])
        updatePowerDisplay(msg[1], msg[2], base_y + 20)
    end
end

