local comp = require "component"
local event = require "event"
local serialization = require "serialization"
local ghelper = require "glasses_helper"
local computer = require "computer"

local authorized = {"Peter"}

local g = comp.glasses
local m = comp.modem
local rfid = comp.os_rfidreader
local e = comp.os_entdetector

g.removeAll()

local running = true
local player_dot = {}
local base_y = 40
local base_x = 10
local base_width = 130
local base_text_scale = 0.8
local primary_color = {1, 1, 1}
local primary_color_dark = {primary_color[1] - 0.2, primary_color[2] - 0.2, primary_color[3] - 0.2}
local red_color = {1, 0, 0 }
local green_color = {0, 1, 0}

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

m.open(8001)

function setContains(set, key)
    return set[key] ~= nil
end

function detect_players()
    local players = e.scanPlayers(64)
    for _, v in pairs(players) do
        local ent_name = v["name"]
        local cube_x = (v["x"]-terminal_coords["x"]) - 0.5
        local cube_y = (v["y"]-terminal_coords["y"])
        local cube_z = (v["z"]-terminal_coords["z"]) - 0.5
        local dot_x = entdetector_center["x"] - (v["x"]-entdetector_coords["x"])*2
        local dot_y = entdetector_center["y"] - (v["z"]-entdetector_coords["z"])*2
        local label_x = dot_x*2 - string.len(ent_name) * 2
        local label_y = dot_y*2 - 10

        for k, v in pairs(players) do
            for _, auth_name in pairs(authorized) do
                if auth_name == v["name"] then
                    v["isAuthorized"] = true
                else
                    v["isAuthorized"] = false
                end
            end
        end

        if  player_dot[ent_name] == nil then
            player_dot[ent_name] = {}
            if v["isAuthorized"] then
                player_dot[ent_name]["dot"] = ghelper.dot(dot_x, dot_y, 2, green_color)
                player_dot[ent_name]["label"] = ghelper.infoText(ent_name, label_x, label_y, 0.5, green_color)
                player_dot[ent_name]["cube"] = ghelper.cube(cube_x, cube_y, cube_z, 0.9, green_color, 0.75, true, 100)
            else
                player_dot[ent_name]["dot"] = ghelper.dot(dot_x, dot_y, 2, red_color)
                player_dot[ent_name]["label"] = ghelper.infoText(ent_name, label_x, label_y, 0.5, red_color)
                player_dot[ent_name]["cube"] = ghelper.cube(cube_x, cube_y, cube_z, 0.9, red_color, 0.75, true, 100)
            end
        else
            if math.abs(v["range"])<9.5 then
                player_dot[ent_name]["dot"].setAlpha(1)
                player_dot[ent_name]["label"].setAlpha(1)
                player_dot[ent_name]["cube"].setAlpha(0.75)

                player_dot[ent_name]["dot"].setPosition(dot_x, dot_y)
                player_dot[ent_name]["label"].setPosition(label_x, label_y)
                player_dot[ent_name]["cube"].set3DPos(cube_x, cube_y, cube_z)
            else
                player_dot[ent_name]["dot"].setAlpha(0.1)
                player_dot[ent_name]["label"].setAlpha(0.1)
                player_dot[ent_name]["cube"].setAlpha(0)
            end
        end
    end
    local players_msg = serialization.serialize(players)
    computer.pushSignal("radar", players_msg)
end

local player_detect_timer = event.timer(0.5, detect_players, math.huge)

function cleanExit()
    event.cancel(player_detect_timer)
    computer.pushSignal("radar_exit")
    running = false
    print("Radar: exiting")
end

local tab_functions = {
    [1] = function() cleanExit() os.execute("home_hud.lua") end,
    [2] = function() cleanExit() os.execute("reactor_hud.lua") end,
    [3] = function() cleanExit() os.execute("entity_sensor_hud.lua") end,
    [4] = function() cleanExit() os.execute("time_widget.lua") end,
    [5] = function() g.removeAll() end,
    [6] = function() g.removeAll() cleanExit() end
}

function handle_modem_message(_, _, _, port, _, msg)
    local msg = serialization.unserialize(msg)

    if port == 8001 then
        print("Radar: executing function: "..msg[1])
        tab_functions[msg[1]]()
    end
end


ghelper.bgBox(base_x - 4, base_y - 10, 100, base_width, primary_color_dark)
ghelper.headlineText("Sensor Grid", base_x, base_y, base_width, base_text_scale, primary_color)
ghelper.dot(entdetector_center["x"], entdetector_center["y"], 3, primary_color)

--os.execute("laser.lua")
while running == true do
    handle_modem_message(event.pull("modem_message"))
end

