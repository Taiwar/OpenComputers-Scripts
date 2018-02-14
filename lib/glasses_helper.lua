local comp = require "component"

local g = comp.glasses

local ghelper = {}
local buttons = {}

function ghelper.infoText(text, x, y , scale, color)
    local label = g.addTextLabel()
    label.setScale(scale)
    label.setPosition(x*(1/scale), y*(1/scale))
    label.setColor(color[1], color[2] , color[3])
    --label.setAlpha(0.8)
    label.setText(text)

    return label
end

function ghelper.dot(x, y, scale, color)
    local dot = g.addDot()

    dot.setPosition(x, y)
    dot.setScale(scale)
    dot.setColor(color[1], color[2] , color[3])

    return dot
end

function ghelper.rect(x, y, w, h, color)
    local rect = g.addRect()

    rect.setSize(w + 4, h + 4)
    rect.setPosition(x - 2, y - 2)
    rect.setColor(color[1], color[2] , color[3])

    return rect
end

function ghelper.bgBox(x, y, w, h, primary_color, secondary_color)
    local bg_group = {}

    bg_group["w"] = w
    bg_group["h"] = h
    bg_group["root"] = {x, y}

    bg_group["primary"] = ghelper.rect(x, y, w, h, primary_color)
    bg_group["primary"].setAlpha(0.6)

    bg_group["secondary"] = ghelper.rect(x - 2, y - 2, w + 4, h + 4, secondary_color)
    bg_group["secondary"].setAlpha(0.4)

    function bg_group.setHeadline(text, scale, color)
        local label = g.addTextLabel()
        label.setPosition((bg_group["root"][1] + (bg_group["w"]/2-((string.len(text)*4)/2)*scale))/scale, (bg_group["root"][2] + 1)/scale)
        label.setScale(scale)
        label.setColor(color[1], color[2] , color[3])
        label.setText(text)

        return label
    end

    function bg_group.addText(text, x, y, scale, color)
        local label = g.addTextLabel()
        label.setPosition((bg_group["root"][1] + x)/scale, (bg_group["root"][2] + y)/scale)
        label.setScale(scale)
        label.setColor(color[1], color[2] , color[3])
        --label.setAlpha(0.8)
        label.setText(text)

        return label
    end

    function bg_group.addButton(text, w, h, x, y, scale, color)
        local button = g.addRect()
        button.setSize(w, h)
        button.setPosition((bg_group["root"][1] + x), (bg_group["root"][2] + y))
        button.setColor(color[1], color[2] , color[3])

        local label = g.addTextLabel()
        local xspot = math.floor((x + x+w + bg_group["root"][1] - string.len(text)) /2) + 1
        local yspot = math.floor((bg_group["root"][2] + y + (h/2))) + (2/scale)
        label.setPosition(xspot, yspot)
        label.setColor(0.1, 0.1, 0.1)
        label.setScale(scale)
        label.setText(text)

        return button
    end

    return bg_group
end

function ghelper.cube(x, y, z, scale, color, alpha, xray, distance)
    local cube = g.addCube3D()

    cube.set3DPos(x, y, z)
    cube.setScale(scale)
    cube.setColor(color[1], color[2] , color[3])
    cube.setAlpha(alpha)
    cube.setVisibleThroughObjects(xray)
    cube.setViewDistance(distance)

    return cube
end

function ghelper.registerButton(name, object, func, func_args)
    buttons[name] = {}
    buttons[name]["func"] = func
    buttons[name]["func_args"] = func_args
    x, y = object.getPosition()
    buttons[name]["xmin"], buttons[name]["ymin"] = x, y
    w, h = object.getSize()
    buttons[name]["xmax"], buttons[name]["ymax"] = x + w, y + h
    print("Registered "..name.." at X: "..buttons[name]["xmin"].."-"..buttons[name]["xmax"].." and Y: "..buttons[name]["ymin"].."-"..buttons[name]["ymax"])
end

function ghelper.handleClick(_, _, _, x, y, _, _)
    print("Got click: "..x..":"..y)
    for _, data in pairs(buttons) do
        print("Checking")
        if y>=data["ymin"] and  y <= data["ymax"] then
            if x>=data["xmin"] and x<= data["xmax"] then
                print("Got one!")
                if data["func_args"] ~= nil then
                    data["func"](data["func_args"])
                else
                    data["func"]()
                end
                return true
            end
        end
    end
end

return ghelper