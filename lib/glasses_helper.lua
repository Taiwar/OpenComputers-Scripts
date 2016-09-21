comp = require "component"

g = comp.glasses

ghelper = {}

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
    label.setPosition(x_offset + math.floor(box_width / 2) - math.floor(string.len(text)*1.5), y)
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

function ghelper.createPanel(x, y, height, width, color)
    local panel_group = {}
    local text_x_offset = x + 4

    panel_group["bg_group"] = ghelper.bgBox(x, y, height, width, color)

    function panel_group.backpanel(self)
        return self["bg_group"]
    end

    function panel_group.addText(self, text, position_index, scale)
        self["text_group"][position_index] = ghelper.infoText(text, text_x_offset, y + position_index * 10, 1, sclae, color)
        return self
    end

    function panel_group.addText(self, text, position_index, scale)
        self["text_group"][position_index] = ghelper.infoText(text, text_x_offset, y + position_index * 10, 1, sclae, color)
        return self
    end

    return panel_group
end

return ghelper