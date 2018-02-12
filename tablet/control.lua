local API = require("button_api")
local event = require("event")
local term = require("term")
local component = require("component")
local serialization = require "serialization"

local m = component.modem
local gpu = component.gpu

local msg = {}
local hub_adress = "db36e32b-fc33-462a-91f5-08689ed62120"

function API.fillTable()
    API.setTable("Home", cmd_showHome, nil, 5,15,3,5)
    API.setTable("Energy", cmd_showEnergy, nil, 17,27,3,5)
    API.setTable("Clear", cmd_clearHUD, nil, 29,39,3,5)
    API.setTable("Exit", cmd_exitHUD, nil, 5,15,7,9)
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
    msg["command"] = "home"
    m.send(hub_adress, 8001, serialization.serialize(msg))
end

function cmd_showEnergy()
    API.flash("Energy",0.05)
    msg["command"] = "energy"
    m.send(hub_adress, 8001, serialization.serialize(msg))
end

function cmd_clearHUD()
    API.flash("Clear",0.05)
    msg["command"] = "clear"
    m.send(hub_adress, 8001, serialization.serialize(msg))
end

function cmd_exitHUD()
    msg["command"] = "exit"
    m.send(hub_adress, 8001, serialization.serialize(msg))
    os.exit()
end

term.setCursorBlink(false)
API.setRes(80, 25)
API.clear()
API.fillTable()
API.heading("Glasses Control")

while true do
    getClick()
end