local comp = require "component"
local event = require "event"
local serialization = require "serialization"
local ghelper = require "glasses_helper"

local g = comp.glasses

local totalFarmed = 0
local robotsRunning = {}
local loopsCompleted = 0

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

event.listen("closeWidget", cleanExit)

g.removeAll()

local base_y = 20
local base_x = 10
local base_width = 125
local base_text_scale = 0.8
local primary_color = {0.22, 1, 0.22}
local primary_color_dark = {primary_color[1] - 0.35, primary_color[2] - 0.35, primary_color[3] - 0.35}
local farming_box = 0

local box = ghelper.bgBox(base_x - 4, base_y - 10, base_width, 45, primary_color_dark, primary_color)
box.setHeadline("Farms", base_text_scale, primary_color)
local exitButton = box.addCornerButton("X", base_text_scale, primary_color)
ghelper.registerButton("Exit", exitButton, requestSwitch, "home")
local totalFarmedText = box.addText("", 1, 10, base_text_scale, {1, 1, 1})
local robotsRunningText = box.addText("", 1, 20, base_text_scale, {1, 1, 1})
local loopsCompletedText = box.addText("", 1, 30, base_text_scale, {1, 1, 1})
totalFarmedText.setText("Waiting for signal")

while true do
    local _, _, from, port, _, message = event.pull("modem_message")
    local msg = serialization.unserialize(message)

    if port == 80 then
        count = 0
        alreadyExists = false
        for _, v in pairs(robotsRunning) do
            if v == from then
                alreadyExists = true
                break
            end
            count = count + 1 
        end
        if not alreadyExists then
            table.insert(robotsRunning, from)
            count = count + 1
        end
        robotsRunningText.setText("Robots running: "..count)
        if msg["status"] == "finished" then
            loopsCompleted = loopsCompleted + 1
            totalFarmed = totalFarmed + msg["harvested"]
            totalFarmedText.setText("Crops harvested: "..totalFarmed)
            loopsCompletedText.setText("Loops completed: "..loopsCompleted)
        end
    end
end