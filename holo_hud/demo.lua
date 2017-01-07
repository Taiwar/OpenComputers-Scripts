local comp = require "component"
local ghelper = require "glasses_helper"

local g = comp.glasses

g.removeAll()

local box = ghelper.bgBox(30, 30, 45, 100, {0.95, 0.95, 0.95}, {0.1, 0.1, 0.1})
local headline = box.setHeadline("headline", 0.9, {1, 0, 0})
local info = box.addText("info", 10, 10 , 0.8, {0, 1, 0})
