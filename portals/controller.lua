local comp = require "component"
local dials = comp.list("ep_dialling_device")

API = require("button_api")
local event = require("event")
local term = require("term")
local component = require("component")

local gpu = component.gpu

local destination = ""
local dest_length = 0
local two_digits = false
local page = 0

function API.fillTable()
    API.clear()
    API.clearTable()
    if page == 0 then
        API.setTable("Open", cmd_open, nil, 5,15,3,5)
        API.setTable("Close", cmd_close, nil, 17,27,3,5)
        API.setTable("Enter Dest", cmd_change_dest, nil, 29,39,3,5)
    else
        API.label(5, 20, "Dest: ")
        API.setTable(" ", cmd_entered_char, " ", 5,15,3,5)
        API.setTable("0", cmd_entered_char, "0", 17,27,3,5)
        API.setTable("1", cmd_entered_char, "1", 29,39,3,5)
        API.setTable("2", cmd_entered_char, "2", 41,51,3,5)
        API.setTable("3", cmd_entered_char, "3", 53,63,3,5)

        API.setTable("4", cmd_entered_char, "4", 5,15,7,9)
        API.setTable("5", cmd_entered_char, "5", 17,27,7,9)
        API.setTable("6", cmd_entered_char, "6", 29,39,7,9)
        API.setTable("7", cmd_entered_char, "7", 41,51,7,9)
        API.setTable("8", cmd_entered_char, "8", 53,63,7,9)

        API.setTable("9", cmd_entered_char, "9", 5,15,11,13)
        API.setTable("10", cmd_entered_char, "10", 17,27,11,13)
        API.setTable("11", cmd_entered_char, "11", 29,39,11,13)
        API.setTable("12", cmd_entered_char, "12", 41,51,11,13)
        API.setTable("13", cmd_entered_char, "13", 53,63,11,13)

        API.setTable("14", cmd_entered_char, "14", 5,15,15,17)
        API.setTable("15", cmd_entered_char, "15", 17,27,15,17)
        API.setTable("16", cmd_entered_char, "16", 29,39,15,17)
        API.setTable("17", cmd_entered_char, "17", 41,51,15,17)
        API.setTable("18", cmd_entered_char, "18", 53,63,15,17)
        API.setTable("19", cmd_entered_char, "19", 65,75,15,17)

        API.setTable("Done", cmd_done, nil, 53,63,20,22)
        API.setTable("Delete", cmd_delete, nil, 65,76,20,22)
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
    dest_length = 0
    two_digits = false
    API.fillTable()
    API.heading("Choose Destination")
end

function cmd_entered_char(char)
    API.flash(char, 0.2)
    if dest_length < 9 then
        if string.len(char) < 2 then
            two_digits = false
        else
            two_digits = true
        end
        if dest_length ~= 0 then
            destination = destination.." "..char
        else
            destination = char
        end

        dest_length = dest_length + 1
    else
        API.label(5, 19, "Destination always contains 9 glyphs!")
    end
    API.label(5, 20, "Dest: "..destination)
end

function cmd_done()
    if dest_length == 9 then
        page = 0
        API.fillTable()
        API.heading("Portal Control: "..destination)
    else
        API.label(5, 21, "Destination always contains 9 glyphs!")
    end
end

function cmd_delete()
    API.flash("Delete", 0.2)
    if dest_length ~= 0 and not two_digits then
        destination = destination:sub(2, -2)
        dest_length = dest_length - 1
    elseif dest_length ~= 0 and two_digits then
        destination = destination:sub(3, -2)
        dest_length = dest_length - 1
    end
    API.label(5, 20, "Dest: "..destination)
    API.screen()
end

term.setCursorBlink(false)
gpu.setResolution(80, 25)
API.clear()
API.fillTable()
API.heading("Portal Control")

while true do
    getClick()
end