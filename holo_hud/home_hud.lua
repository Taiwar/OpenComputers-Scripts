local comp = require "component"
local event = require "event"
local ghelper = require "glasses_helper"

local g = comp.glasses

g.removeAll()

local base_y = 40
local base_x = 10
local base_width = 130
local base_text_scale = 0.8
local primary_color = {1, 1, 1 }
local primary_color_dark = {primary_color[1] - 0.2, primary_color[2] - 0.2, primary_color[3] - 0.2}


local box = ghelper.bgBox(base_x - 4, base_y - 10, base_width, 45, primary_color, primary_color_dark)
box.setHeadline("Home", base_text_scale, primary_color)

function cleanExit(_, _)
    event.ignore("closeWidget")
    os.exit()
end

event.listen("closeWidget", cleanExit)

