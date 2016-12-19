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
        API.setTable("Open", cmd_open, 5,15,3,5)
        API.setTable("Close", cmd_close, 17,27,3,5)
        API.setTable("Enter Dest", cmd_change_dest, 29,39,3,5)
    else
        API.setTable("nothing", nmbr_space, 17,27,15,17)
        API.setTable("0", nmbr_0, 5,15,15,17)
        API.setTable("1", nmbr_1, 5,15,3,5)
        API.setTable("2", nmbr_2, 17,27,3,5)
        API.setTable("3", nmbr_3, 29,39,3,5)
        API.setTable("4", nmbr_4, 5,15,7,9)
        API.setTable("5", nmbr_5, 17,27,7,9)
        API.setTable("6", nmbr_6, 29,39,7,9)
        API.setTable("7", nmbr_7, 5,15,11,13)
        API.setTable("8", nmbr_8, 17,27,11,13)
        API.setTable("9", nmbr_9, 29,39,11,13)
        API.setTable("Done", cmd_done, 50,60,11,13)
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

function nmbr_space()
    API.flash("nothing",0.2)
    if destination ~= "" then
        destination = destination.." ".." "
    else
        destination = " "
    end
end

function nmbr_0()
    API.flash("0",0.2)
    if destination ~= "" then
        destination = destination.." ".."0"
    else
        destination = "0"
    end
end

function nmbr_1()
    API.flash("1",0.2)
    if destination ~= "" then
        destination = destination.." ".."1"
    else
        destination = "1"
    end
end

function nmbr_2()
    API.flash("2",0.2)
    if destination ~= "" then
        destination = destination.." ".."2"
    else
        destination = "2"
    end
end

function nmbr_3()
    API.flash("3",0.2)
    if destination ~= "" then
        destination = destination.." ".."3"
    else
        destination = "3"
    end
end

function nmbr_4()
    API.flash("4",0.2)
    if destination ~= "" then
        destination = destination.." ".."4"
    else
        destination = "4"
    end
end

function nmbr_5()
    API.flash("5",0.2)
    if destination ~= "" then
        destination = destination.." ".."5"
    else
        destination = "5"
    end
end

function nmbr_6()
    API.flash("6",0.2)
    if destination ~= "" then
        destination = destination.." ".."6"
    else
        destination = "6"
    end
end

function nmbr_7()
    API.flash("7",0.2)
    if destination ~= "" then
        destination = destination.." ".."7"
    else
        destination = "7"
    end
end

function nmbr_8()
    API.flash("8",0.2)
    if destination ~= "" then
        destination = destination.." ".."8"
    else
        destination = "8"
    end
end

function nmbr_9()
    API.flash("9",0.2)
    if destination ~= "" then
        destination = destination.." ".."9"
    else
        destination = "9"
    end
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