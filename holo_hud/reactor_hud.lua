local comp = require "component"
local event = require "event"
local serialization = require "serialization"
local ghelper = require "glasses_helper"

local g = comp.glasses

g.removeAll()

local base_y = 40
local base_x = 10
local base_width = 130
local base_text_scale = 0.8
local primary_color = {1, 1, 1 }
local primary_color_dark = {primary_color[1] - 0.2, primary_color[2] - 0.2, primary_color[3] - 0.2}

local c_energy = 0
local waste_box = 0
local fuel_box = 0
local waste_info = 0
local net_energy_info = 0
local energy_box = 0
local r_capacity_end_box = 0
local r_capacity_start_box = 0
local capacity_end_box = 0
local capacity_start_box = 0

function initFuelDisplay(y)
    waste_box = g.addRect()
    fuel_box = g.addRect()
    capacity_end_box = g.addRect()
    capacity_start_box = g.addRect()

    capacity_start_box.setSize(10.8, 0.8)
    capacity_start_box.setPosition(base_x - 0.8, y-0.4)
    capacity_start_box.setColor(primary_color_dark[1], primary_color_dark[2] , primary_color_dark[3])

    capacity_end_box.setSize(10.8, 0.8)
    capacity_end_box.setPosition(base_x + base_width - 30, y-0.4)
    capacity_end_box.setColor(primary_color_dark[1], primary_color_dark[2] , primary_color_dark[3])

    waste_box.setColor(0.1059, 0, 0.902)
    waste_box.setAlpha(0.9)

    fuel_box.setColor(0.8431, 0.937, 0)
    fuel_box.setAlpha(0.9)
end

function initPowerDisplay(y)
    capacity_start_box = ghelper.rect(base_x - 0.8, y-0.4, 10.8, 0.8, primary_color_dark)
    capacity_end_box = ghelper.rect(base_x + base_width - 30, y-0.4, 10.8, 0.8, primary_color_dark)

    energy_box = g.addRect()
    energy_box.setColor(primary_color[1], primary_color[2] , primary_color[3])
    energy_box.setAlpha(0.9)
end

function updateFuelDisplay(fuel, waste, capacity, consumption, y)
    local waste_ratio = waste/capacity
    local fuel_ratio = fuel/capacity
    local waste_width = waste_ratio*100
    local fuel_width = fuel_ratio*100
    local seconds_til_burnout = ((fuel/consumption) / 20)

    if seconds_til_burnout < 600 then
        waste_info.setText("Fuel status CRITICAL")
        waste_info.setColor(1, 0, 0)
    end

    waste_box.setSize(10, waste_width)
    waste_box.setPosition(base_x + fuel_width, y)

    fuel_box.setSize(10, fuel_width)
    fuel_box.setPosition(base_x, y)
end

function updatePowerDisplay(energy, capacity, y)
    local energy_ratio = energy/capacity
    local energy_width = energy_ratio*100

    energy_box.setSize(10, energy_width)
    energy_box.setPosition(base_x, y)
end

function calculateNetEnergy(curr_energy)
    local energy_dif = curr_energy - c_energy

    net_energy_info.setText("Net-Energy in RF/t: "..energy_dif/20)
    if energy_dif < 0 then
        net_energy_info.setColor(1, 0, 0)
    elseif energy_dif == 0 then
        net_energy_info.setColor(1, 1, 1)
    else
        net_energy_info.setColor(0, 1, 0)
    end

    c_energy = curr_energy
end

local reactor_box = ghelper.bgBox(base_x - 4, base_y - 10, 46, base_width, primary_color, primary_color_dark)
reactor_box.setHeadline("Reactor", base_text_scale, primary_color)
local production_info = reactor_box.addText("", 1, 10, base_text_scale, primary_color)
local fuel_info = reactor_box.addText("Fuel status:", 1, 20, base_text_scale, primary_color)
initFuelDisplay(base_y + 20)

local capacitor_box = ghelper.bgBox(base_x - 4, base_y + 43, 46, base_width, primary_color, primary_color_dark)
capacitor_box.setHeadline("Capacitor", base_text_scale, primary_color)
local power_info = capacitor_box.addText("", 1, 76, base_text_scale, primary_color)
initPowerDisplay(base_y + 73)

production_info.setText("Waiting for signal")

function cleanExit(_, _)
    event.ignore("closeWidget")
    os.exit()
end

event.listen("closeWidget", cleanExit)

while true do
    local _, _, _, port, _, message = event.pull("modem_message")
    local msg = serialization.unserialize(message)

    if port == 8000 then
        if msg[1] then
            production_info.setText("Energy output in kRF/t: "..msg[4]/1000)
            power_info.setText("Energy stored in kRF: "..msg[7]/1000)
            updateFuelDisplay(msg[2], msg[3], msg[5], msg[6], base_y + 20)
            calculateNetEnergy(msg[7])
            updatePowerDisplay(msg[7], msg[8], base_y + 73)
        else
            production_info.setText("Reactor offline")
        end
    end
end

