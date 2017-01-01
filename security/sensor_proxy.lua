local comp = require "component"
local event = require "event"
local serialization = require "serialization"

local m = comp.modem
local e = comp.os_entdetector

local entity_widgets = {}
local running = true
local base_y = 40
local base_x = 10
local base_width = 130
local msg

local entdetector_coords = {
    ["x"] = 899,
    ["z"] = -2200,
    ["y"] = 74
}

local terminal_coords = {
    ["x"] = 900,
    ["z"] = -2205,
    ["y"] = 68
}

local entdetector_center = {
    ["x"] = (base_x + base_width)*0.75,
    ["y"] = base_y + 40
}

function checkRfids()
    local i = 1
    local player = {}
    local rfids = rfid.scan()
    for _,v in pairs(rfids) do
        if v["data"] == password then
            v["verified"] = true
        else
            v["verified"] = false
        end
        player[i] = v
        i = i + 1
    end
    return player
end

function unknownEvent()

end

function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

function detect_entities()
    local entities = e.scanEntities(64)
    local index = 1

    for _, v in pairs(entity_widgets) do
        for _, id in pairs(v) do
            g.removeObject(id)
        end
    end

    for _, v in pairs(entities) do
        entity_widgets[index] = {}
        local ent_name = v["name"]
        local cube_x = (v["x"]-terminal_coords["x"]) - 0.5
        local cube_y = (v["y"]-terminal_coords["y"])
        local cube_z = (v["z"]-terminal_coords["z"]) - 0.5
        local dot_x = entdetector_center["x"] - (v["x"]-entdetector_coords["x"])*2
        local dot_y = entdetector_center["y"] - (v["z"]-entdetector_coords["z"])*2
        local label_x = dot_x*2 - string.len(ent_name) * 2
        local label_y = dot_y*2 - 10

        if not string.starts(ent_name, "item.") then

        end
        index = index + 1
    end
end

local entity_detect_timer = event.timer(0.25, detect_entities, math.huge)

function cleanExit()
    event.cancel(entity_detect_timer)
    running = false
    print("exiting")
end

while running == true do
    m.broadcast(8005, serialization.serialize(msg))
end

