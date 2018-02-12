local comp = require "component"
local event = require "event"
local serialization = require "serialization"
local computer = require "computer"
local term = require "term"

local g = comp.glasses
local m = comp.modem

g.removeAll()
local last_cmd = ""
local last_msg = ""

local tab_functions = {
    ["home"] = function() switchTo("home_hud.lua") end,
    ["energy"] = function() switchTo("energy_hud.lua") end,
    ["clear"] = function() g.removeAll() end,
    -- ["timeOn"] = function() os.execute("time_widget.lua") end,
    -- ["sensor"] = function() switchTo("entity_sensor_hud.lua") end,
    ["exit"] = cleanExit
}

function switchTo(script_name)
    computer.pushSignal("closeWidget")
    os.execute(script_name)
end

function cleanExit()
    computer.pushSignal("closeWidget")
    g.removeAll()
    event.ignore("modem_message")
    m.close(8000)
    m.close(8001)
    m.close(8002)
    os.exit()
end

function executeFunction(_, _, _, port, _, packet)
    term.clear()
    last_msg = "{"..port..": "..packet.."}"
    local msg = serialization.unserialize(packet)
    if port == 8001 and msg["command"] ~= nil then
        last_cmd = "execute function: "..msg["command"]
        tab_functions[msg["command"]]()
    end
    print("Last msg:")
    print(last_msg)
    print("Last cmd:")
    print(last_cmd)
end

print("startup")
m.open(8000)
m.open(8001)
m.open(8002)
event.listen("modem_message", executeFunction)
event.listen("interrupted", cleanExit)
