local API = {}
local button={}

local component = require("component")
local term = require("term")
local mon = component.gpu
local w, h = mon.getResolution()
local primary_color = 0xFF0000
local accent_color = 0x00AA00
local background_color = 0x000000

local buttonStatus

function API.clear()
    mon.setBackground(background_color)
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
        if on == true then currColor = accent_color else currColor = primary_color end
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
    local w, _ = mon.getResolution()
    term.setCursor((w-string.len(text))/2+1, 1)
    term.write(text)
end

function API.label(text, x, y)
    term.setCursor(x, y)
    term.write(text)
end

function API.centerLabel(text, y)
    local w, _ = mon.getResolution()
    term.setCursor((w-string.len(text))/2+1, y)
    term.write(text)
end

-- Function to allow for customization of button, background and text colors
function API.customize(background, primary, accent, text)
    background_color = background
    primary_color = primary
    accent_color = accent
    mon.setForeground(text)
end

function API.setRes(width, height)
    w = width
    h = height
    mon.setResolution(width, height)
end

return API