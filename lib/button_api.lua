local API = {}
local button={}

local component = require("component")
local term = require("term")
local mon = component.gpu
local w, h = mon.getResolution()
local Green = 0x00AA00
local Red = 0xFF0000
local Black = 0x000000

buttonStatus = nil

function API.clear()
    mon.setBackground(Black)
    mon.fill(1, 1, w, h, " ")
end

function API.clearTable()
    button = {}
    API.clear()
end

function API.setTable(name, func, func_args, xmin, xmax, ymin, ymax)
    button[name] = {}
    button[name]["func"] = func
    button[name]["func_args"] = func_args
    button[name]["active"] = false
    button[name]["xmin"] = xmin
    button[name]["ymin"] = ymin
    button[name]["xmax"] = xmax
    button[name]["ymax"] = ymax
end

function API.fill(text, color, bData)
    local yspot = math.floor((bData["ymin"] + bData["ymax"]) /2)
    local xspot = math.floor((bData["xmax"] + bData["xmin"] - string.len(text)) /2)+1
    local oldColor = mon.setBackground(color)
    mon.fill(bData["xmin"], bData["ymin"], (bData["xmax"]-bData["xmin"]+1), (bData["ymax"]-bData["ymin"]+1), " ")
    mon.set(xspot, yspot, text)
    mon.setBackground(oldColor)
end

function API.screen()
    local currColor
    for name,data in pairs(button) do
        local on = data["active"]
        if on == true then currColor = Green else currColor = Red end
        API.fill(name, currColor, data)
    end
end

function API.toggleButton(name)
    button[name]["active"] = not button[name]["active"]
    buttonStatus = button[name]["active"]
    API.screen()
end

function API.flash(name,length)
    API.toggleButton(name)
    API.screen()
    os.sleep(length)
    API.toggleButton(name)
    API.screen()
end

function API.checkxy(x, y)
    for _, data in pairs(button) do
        if y>=data["ymin"] and  y <= data["ymax"] then
            if x>=data["xmin"] and x<= data["xmax"] then
                if data["func_args"] ~= nil then
                    data["func"](data["func_args"])
                else
                    data["func"]()
                end
                return true
            end
        end
    end
    return false
end

function API.heading(text)
    w, h = mon.getResolution()
    term.setCursor((w-string.len(text))/2+1, 1)
    term.write(text)
end

function API.label(w, h, text)
    term.setCursor(w, h)
    term.write(text)
end

return API
 
 