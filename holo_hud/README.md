# Holo Hud

A collection of my scripts for the OpenGlasses addon.
All scripts require the glasses_helper.lua to be installed on the computer in a lib folder (/home/lib, /usr/lib, ...)

The glasses_helper.lua is an API designed to make drawing information panels and text on the user's screen easier and more intuitive.
It is focused around a table of background rectangles on which you can draw headlines and text.
Using this method you can use coordinates relative to their "parent" background-group instead of to the whole screen.

### Example
```
local comp = require "component"
local ghelper = require "glasses_helper"

local g = comp.glasses

g.removeAll()

-- all colors are RGB tables meaning {red_value, green_value, blue_value}
-- all coords are relative to the top left cornor of the parent (computer screen or bg_group)
local box = ghelper.bgBox(30, 30, 45, 100, {0.95, 0.95, 0.95}, {0.1, 0.1, 0.1}) --Params: x, y, height, width, front panel color, back panel color
local headline = box.setHeadline("headline", 0.9, {1, 0, 0}) --Params: text, scale, color (x is calculated, y is one line below front panel)
local info = box.addText("info", 10, 10 , 0.8, {0, 1, 0}) --Params: text, x, y, color
```
![](https://i.imgur.com/uWwEKLV.png)
