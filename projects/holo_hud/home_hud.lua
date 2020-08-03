local comp = require "component"
local event = require "event"
local ghelper = require "glasses_helper"

local g = comp.glasses

g.removeAll()

local base_y = 20
local base_x = 10
local base_width = 130
local base_text_scale = 0.8
local primary_color = {1, 1, 1}
local primary_color_dark = {primary_color[1] - 0.2, primary_color[2] - 0.2, primary_color[3] - 0.2}

function cleanExit(_, _)
    event.ignore("closeWidget")
    event.listen("interact_overlay")
    os.exit()
end

function requestSwitch(name)
    print("Requesting switchTo "..name)
    event.push("requestSwitch", name)
    cleanExit()
end

local box = ghelper.bgBox(base_x - 4, base_y - 10, base_width, 45, primary_color, primary_color_dark)
box.setHeadline("Home", base_text_scale, primary_color)
local exitButton = box.addCornerButton("X", base_text_scale, primary_color)
local energyButton = box.addButton("Energy", 50, 10, 10, 10, base_text_scale, primary_color)
local farmsButton = box.addButton("Farms", 50, 10, 70, 10, base_text_scale, primary_color)
ghelper.registerButton("Energy", energyButton, requestSwitch, "energy")
ghelper.registerButton("Farms", farmsButton, requestSwitch, "farming")
ghelper.registerButton("Exit", exitButton, requestSwitch, "home")

event.listen("closeWidget", cleanExit)
event.listen("interact_overlay", ghelper.handleClick)

