local comp = require "component"
local dials = comp.list("ep_dialling_device")

API = require("button_api")
local event = require("event")
local term = require("term")
local component = require("component")

local gpu = component.gpu

destination = ""
page = 0

function API.fillTable()
    API.clear()
    API.clearTable()
    if page == 0 then
        API.setTable("Open", cmd_open, nil, 5,15,3,5)
        API.setTable("Close", cmd_close, nil, 17,27,3,5)
        API.setTable("Enter Dest", cmd_change_dest, nil, 29,39,3,5)
    else
        API.setTable(" ", cmd_entered_char, " ", 17,27,15,17)
        API.setTable("0", cmd_entered_char, "0", 5,15,15,17)
        API.setTable("1", cmd_entered_char, "1", 5,15,3,5)
        API.setTable("2", cmd_entered_char, "2", 17,27,3,5)
        API.setTable("3", cmd_entered_char, "3", 29,39,3,5)
        API.setTable("4", cmd_entered_char, "4", 5,15,7,9)
        API.setTable("5", cmd_entered_char, "5", 17,27,7,9)
        API.setTable("6", cmd_entered_char, "6", 29,39,7,9)
        API.setTable("7", cmd_entered_char, "7", 5,15,11,13)
        API.setTable("8", cmd_entered_char, "8", 17,27,11,13)
        API.setTable("9", cmd_entered_char, "9", 29,39,11,13)
        API.setTable("Done", cmd_done, nil, 50,60,11,13)
    end
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

function cmd_open()
    API.flash("Open",0.2)
    for adress in dials do
        local proxy = comp.proxy(adress)
        proxy.dial(destination)
    end
end

function cmd_close()
    API.flash("Close",0.2)
    for adress in dials do
        local proxy = comp.proxy(adress)
        proxy.terminate()
    end
end

function cmd_change_dest()
    page = 1
    destination = ""
    API.fillTable()
    API.heading("Choose Destination")
end

function cmd_entered_char(char)
    API.flash(char, 0.2)
    if destination ~= "" then
        destination = destination.." "..char
    else
        destination = char
    end
    API.heading("Choose Destination: "..destination)
end

function cmd_done()
    page = 0
    API.fillTable()
    API.heading("Portal Control: "..destination)
end

term.setCursorBlink(false)
gpu.setResolution(80, 25)
API.clear()
API.fillTable()
API.heading("Portal Control")

while true do
    getClick()
end