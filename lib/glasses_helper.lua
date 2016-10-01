local comp = require "component"

local g = comp.glasses

local ghelper = {}

function ghelper.infoText(text, x, y , scale, color)
    local label = g.addTextLabel()
    label.setPosition(x, y)
    label.setScale(scale)
    label.setColor(color[1], color[2] , color[3])
    --label.setAlpha(0.8)
    label.setText(text)

    return label
end

function ghelper.headlineText(text, x_offset, y, box_width, scale, color)
    local label = g.addTextLabel()
    label.setPosition(x_offset + box_width/2 - string.len(text), y)
    label.setScale(scale)
    label.setColor(color[1], color[2] , color[3])
    --label.setAlpha(0.8)
    label.setText(text)

    return label
end

function ghelper.bgBox(x, y, height, width, color)
    local bg_group = {}

    bg_group["primary"] = g.addRect()
    bg_group["secondary"] = g.addRect()

    bg_group["primary"].setSize(height + 4, width + 4)
    bg_group["primary"].setPosition(x - 2, y - 2)
    bg_group["primary"].setColor(color[1], color[2] , color[3])
    bg_group["primary"].setAlpha(0.4)

    bg_group["secondary"].setSize(height, width)
    bg_group["secondary"].setPosition(x, y)
    bg_group["secondary"].setColor(0, 0 , 0)
    bg_group["secondary"].setAlpha(0.6)

    return bg_group
end

function ghelper.dot(x, y, scale, color)
    local dot = g.addDot()

    dot.setPosition(x, y)
    dot.setScale(scale)
    dot.setColor(color[1], color[2] , color[3])

    return dot
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