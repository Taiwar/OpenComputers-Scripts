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
r_capacity_end_box = 0
r_capacity_start_box = 0
capacity_end_box = 0
capacity_start_box = 0


tab_functions = {
    [1] = function() os.execute("home_hud.lua") os.exit() end,
    [2] = function() os.execute("reactor_hud.lua") os.exit() end,
    [3] = function() os.execute("entity_sensor_hud.lua") os.exit() end,
    [4] = function() os.execute("time_widget.lua") end,
    [5] = function() g.removeAll() end,
    [6] = function() g.removeAll() os.exit() end
}

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
    energy_box = g.addRect()
    capacity_end_box = g.addRect()
    capacity_start_box = g.addRect()

    capacity_start_box.setSize(10.8, 0.8)
    capacity_start_box.setPosition(base_x - 0.8, y-0.4)
    capacity_start_box.setColor(primary_color_dark[1], primary_color_dark[2] , primary_color_dark[3])

    capacity_end_box.setSize(10.8, 0.8)
    capacity_end_box.setPosition(base_x + base_width - 30, y-0.4)
    capacity_end_box.setColor(primary_color_dark[1], primary_color_dark[2] , primary_color_dark[3])

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

ghelper.bgBox(base_x - 4, base_y - 10, 46, base_width, primary_color_dark)
ghelper.headlineText("Reactor", base_x, base_y, base_width, base_text_scale, primary_color)
local production_info = ghelper.infoText("", base_x, base_y + 10, base_text_scale, primary_color)
ghelper.infoText("Fuel status:", base_x, base_y + 20, base_text_scale, primary_color)
initFuelDisplay(base_y + 20)

ghelper.bgBox(base_x - 4, base_y + 43, 46, base_width, primary_color_dark)
ghelper.headlineText("CapacitorBank", base_x, base_y + 66, base_width, base_text_scale, primary_color)
local power_info = ghelper.infoText("", base_x, base_y + 76, base_text_scale, primary_color)
ghelper.infoText("", base_x, base_y + 86, base_text_scale, primary_color)
initPowerDisplay(base_y + 73)

production_info.setText("Waiting for signal")

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
    elseif port == 8001 then
        print("executing function: "..msg[1])
        tab_functions[msg[1]]()
    end
end

