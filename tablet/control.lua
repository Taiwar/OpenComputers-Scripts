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
    API.setTable("Home", cmd_showHome, 5,15,3,5)
    API.setTable("Energy", cmd_showEnergy, 17,27,3,5)
    API.setTable("Sensors", cmd_showSensors, 29,39,3,5)
    API.setTable("Time", cmd_toggleTime, 41,51,3,5)
    API.setTable("Clear", cmd_clearHUD, 53,63,3,5)
    API.setTable("DroneLoop", cmd_toggleDroneLoop, 65,75,3,5)
    API.setTable("Exit", cmd_exitHUD, 5,15,7,9)
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

function cmd_showEnergy()
    API.flash("Energy",0.05)
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

function cmd_toggleDroneLoop()
    API.toggleButton("DroneLoop")
    if buttonStatus == false then
        msg = false
        m.broadcast(8003, msg)
    else
        msg = true
        m.broadcast(8003, msg)
    end
end

function cmd_loadBase()
    API.toggleButton("LoadBase")
    if buttonStatus == false then
        msg = 0
        m.broadcast(8006, msg)
    else
        msg = 15
        m.broadcast(8006, msg)
    end
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