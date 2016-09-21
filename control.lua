API = require("button_api")
local event = require("event")
local term = require("term")
local component = require("component")
local serialization = require "serialization"

local m = component.modem
local gpu = component.gpu

local msg = {}
local hub_adress = "13d9efb3-05a5-4cef-b40d-1fde878df1ab"

function API.fillTable()
    API.setTable("Home", cmd_showHome, 10,20,3,5)
    API.setTable("Reactor", cmd_showReactor, 22,32,3,5)
    API.setTable("Sensors", cmd_showSensors, 34,44,3,5)
    API.setTable("Time", cmd_toggleTime, 46,56,3,5)
    API.setTable("Clear", cmd_clearHUD, 22,32,8,10)
    API.setTable("Exit", cmd_exitHUD, 34,44,8,10)
    API.screen()
end

function getClick()
    local _, _, x, y = event.pull(1,touch)
    if x == nil or y == nil then
        local h, w = gpu.getResolution()
        gpu.set(h, w, ".")
        gpu.set(h, w, " ")
    else
        API.checkxy(x,y)
    end
end


function cmd_showHome()
    API.flash("Home",0.05)
    msg[1] = 1
    m.send(hub_adress, 8001, serialization.serialize(msg))
end

function cmd_showReactor()
    API.flash("Reactor",0.05)
    msg[1] = 2
    m.send(hub_adress, 8001, serialization.serialize(msg))
end

function cmd_showSensors()
    API.flash("Sensors",0.05)
    msg[1] = 3
    m.send(hub_adress, 8001, serialization.serialize(msg))
end

function cmd_toggleTime()
    API.toggleButton("Time")
    if buttonStatus == false then
        msg[1] = ""
        m.send(hub_adress, 8002, serialization.serialize(msg))
    else
        msg[1] = 4
        m.send(hub_adress, 8001, serialization.serialize(msg))
    end
end

function cmd_clearHUD()
    API.flash("Clear",0.05)
    msg[1] = 5
    m.send(hub_adress, 8001, serialization.serialize(msg))
end

function cmd_exitHUD()
    msg[1] = 6
    m.send(hub_adress, 8001, serialization.serialize(msg))
end


term.setCursorBlink(false)
gpu.setResolution(80, 25)
API.clear()
API.fillTable()
API.heading("Glasses Control")

while true do
    getClick()
end



--eof