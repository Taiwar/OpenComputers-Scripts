local comp = require("component")

local g = comp.glasses

local ghelper = {}
local buttons = {}

function ghelper.calculatePosition(object)
    local modifiers = object.getModifiers()
    local x = 0
    local y = 0
    local z = 0
    if modifiers ~= nil then
        for _, value in pairs(modifiers) do
            if type(value) == "table" then
                local is_translate = false
                for _, val in pairs(value) do
                    if is_translate then
                        for k, v in pairs(val) do
                            if k == 1 then
                                x = x + v
                            elseif k == 2 then
                                y = y + v
                            elseif k == 3 then
                                z = z + v
                            end
                        end
                        break
                    else
                        if val == "TRANSLATE" then
                            is_translate = true
                        end
                    end
                end
            end
        end
    end

    return x, y, z
end

function ghelper.calculateScale(object)
    local modifiers = object.getModifiers()
    local width = 0
    local height = 0
    local depth = 0
    if modifiers ~= nil then
        for _, value in pairs(modifiers) do
            if type(value) == "table" then
                local is_scale = false
                for _, val in pairs(value) do
                    if is_scale then
                        for k, v in pairs(val) do
                            if k == 1 then
                                width = width + v
                            elseif k == 2 then
                                height = height + v
                            elseif k == 3 then
                                depth = depth + v
                            end
                        end
                        break
                    else
                        if val == "SCALE" then
                            is_scale = true
                        end
                    end
                end
            end
        end
    end

    return width, height, depth
end

function ghelper.infoText(text, x, y , scale, color)
    local label = g.addText2D()
    label.addScale(scale, scale, scale)
    label.addTranslation(x*(1/scale), y*(1/scale), 0)
    label.addColor(color[1], color[2] , color[3], 1)
    label.setText(text)

    return label
end

function ghelper.dot(x, y, scale, color)
    local dot = g.addDot()

    dot.addTranslation(x, y, 0)
    dot.addScale(scale, scale, scale)
    dot.addColor(color[1], color[2] , color[3], 1)

    return dot
end

function ghelper.rect(x, y, w, h, color, opacity)
    local rect = g.addBox2D()

    rect.setSize(w + 4, h + 4)
    rect.addTranslation(x - 2, y - 2, 0)
    rect.addColor(color[1], color[2] , color[3], opacity)

    return rect
end

function ghelper.bgBox(x, y, w, h, primary_color, secondary_color)
    local bg_group = {}

    bg_group["w"] = w
    bg_group["h"] = h
    bg_group["root"] = {x, y}

    bg_group["primary"] = ghelper.rect(x, y, w, h, primary_color, 0.6)
    bg_group["secondary"] = ghelper.rect(x - 2, y - 2, w + 4, h + 4, secondary_color, 0.4)

    function bg_group.setHeadline(text, scale, color)
        local label = g.addText2D()
        label.addTranslation((bg_group["root"][1] + (bg_group["w"]/2-((string.len(text)*4)/2)*scale))/scale, (bg_group["root"][2] + 1)/scale, 0)
        label.addScale(scale, scale, scale)
        label.addColor(color[1], color[2] , color[3], 1)
        label.setText(text)

        return label
    end

    function bg_group.addText(text, x, y, scale, color)
        local label = g.addText2D()
        label.addTranslation((bg_group["root"][1] + x)/scale, (bg_group["root"][2] + y)/scale, 0)
        label.addScale(scale, scale, scale)
        label.addColor(color[1], color[2] , color[3], 1)
        label.setText(text)

        return label
    end

    function bg_group.addButton(text, w, h, x, y, scale, color)
        local button = g.addBox2D()
        button.setSize(w, h)
        button.addTranslation((bg_group["root"][1] + x), (bg_group["root"][2] + y), 0)
        button.addColor(color[1], color[2] , color[3], 1)

        local label = g.addText2D()
        local xspot = (bg_group["root"][1] + x + (w/2) - (string.len(text)/scale))/scale
        local yspot = bg_group["root"][2] + y + (h/2)
        label.addTranslation(xspot, yspot, 0)
        label.addColor(0.1, 0.1, 0.1, 1)
        label.addScale(scale, scale, scale)
        label.setText(text)

        return button
    end

    function bg_group.addCornerButton(text, scale, color)
        w = 7
        h = 7
        x = bg_group["w"] - w + 2
        y = -2
        return bg_group.addButton(text, w, h, x, y, scale, color)
    end

    return bg_group
end

function ghelper.cube(x, y, z, scale, color, opacity, xray, distance)
    local cube = g.addCube3D()

    cube.addTranslation(x, y, z)
    cube.addScale(scale, scale, scale)
    cube.addColor(color[1], color[2] , color[3], opacity)
    cube.setVisibleThroughObjects(xray)
    cube.setViewDistance(distance)

    return cube
end

function ghelper.registerButton(name, object, func, func_args)
    buttons[name] = {}
    buttons[name]["func"] = func
    buttons[name]["func_args"] = func_args
    print(object.getModifiers())
    x, y, z = ghelper.calculatePosition(object)
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