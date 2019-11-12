local comp = require "component"
local event = require "event"
local serialization = require "serialization"
local ghelper = require "glasses_helper"

local g = comp.glasses

g.removeAll()

local base_y = 20
local base_x = 10
local base_width = 125
local base_text_scale = 0.8
local primary_color = {1, 0.22, 0.22}
local primary_color_dark = {primary_color[1] - 0.35, primary_color[2] - 0.35, primary_color[3] - 0.35}

local c_energy = 0
local energy_box = 0
local energy_box_translation = 0
local capacity_end_box
local capacity_start_box

function roundTo(nmbr, digits)
    local shift = 10 ^ digits
    return math.floor( nmbr*shift + 0.5 ) / shift
end

function initPowerDisplay(y)
    energy_box = g.addBox2D()
    capacity_end_box = g.addBox2D()
    capacity_start_box = g.addBox2D()

    capacity_start_box.setSize(0.8, 10.8)
    capacity_start_box.addTranslation(base_x - 0.8, y-0.4, 0)
    capacity_start_box.addColor(primary_color_dark[1], primary_color_dark[2] , primary_color_dark[3], 1)

    capacity_end_box.setSize(0.8, 10.8)
    capacity_end_box.addTranslation(base_x + base_width - 10, y-0.4, 0)
    capacity_end_box.addColor(primary_color_dark[1], primary_color_dark[2] , primary_color_dark[3], 1)

    energy_box.addColor(primary_color[1], primary_color[2] , primary_color[3], 0.9)
    energy_box_translation = energy_box.addTranslation(0, 0, 0)
end

function updatePowerDisplay(energy, capacity, y)
    local energy_ratio = energy/capacity
    local energy_width = energy_ratio*100*((base_width - 10)/100)

    energy_box.setSize(energy_width, 10)
    energy_box.modifiers[energy_box_translation](base_x, y, 0)
end

function cleanExit(_, _)
    event.ignore("closeWidget")
    event.ignore("interact_overlay")
    os.exit()
end

function requestSwitch(name)
    print("Requesting switchTo "..name)
    event.push("requestSwitch", name)
    cleanExit()
end

local box = ghelper.bgBox(base_x - 4, base_y - 10, base_width, 45, primary_color_dark, primary_color)
box.setHeadline("Energy", base_text_scale, primary_color)
local exitButton = box.addCornerButton("X", base_text_scale, primary_color)
ghelper.registerButton("Exit", exitButton, requestSwitch, "home")
local power_info = box.addText("", 1, 10, base_text_scale, {1, 1, 1})
local net_energy_info = box.addText("", 1, 20, base_text_scale, {1, 1, 1})
initPowerDisplay(base_y + 20)
power_info.setText("Waiting for signal")

function calculateNetEnergy(curr_energy)
    local energy_dif = curr_energy - c_energy

    net_energy_info.setText("Net-Energy in RF/t: "..roundTo((energy_dif)/20, 2))
    if energy_dif < 0 then
        net_energy_info.addColor(1, 0, 0, 1)
    elseif energy_dif == 0 then
        net_energy_info.addColor(1, 1, 1, 1)
    else
        net_energy_info.addColor(0, 1, 0, 1)
    end

    c_energy = curr_energy
end

event.listen("closeWidget", cleanExit)
event.listen("interact_overlay", ghelper.handleClick)

while true do
    local _, _, _, port, _, message = event.pull("modem_message")
    local msg = serialization.unserialize(message)

    if port == 8000 then
        power_info.setText("Energy stored in MRF: "..roundTo(msg["current"]/1000000, 2))
        calculateNetEnergy(msg["current"])
        updatePowerDisplay(msg["current"], msg["max"], base_y + 20)
    end
end

