local comp = require "component"

local g = comp.glasses

local ghelper = {}

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

function ghelper.rect(x, y, h, w, color)
    local rect = g.addRect()

    rect.setSize(h + 4, w + 4)
    rect.setPosition(x - 2, y - 2)
    rect.setColor(color[1], color[2] , color[3])

    return rect
end

function ghelper.bgBox(x, y, h, w, primary_color, secondary_color)
    local bg_group = {}

    bg_group["w"] = w
    bg_group["h"] = h
    bg_group["root"] = {x, y}

    bg_group["primary"] = ghelper.rect(x, y, h, w, primary_color)
    bg_group["primary"].setAlpha(0.6)

    bg_group["secondary"] = ghelper.rect(x - 2, y - 2, h + 4, w + 4, secondary_color)
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

return ghelper