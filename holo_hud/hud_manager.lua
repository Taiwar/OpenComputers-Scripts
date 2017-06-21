local comp = require "component"
local event = require "event"
local serialization = require "serialization"
local computer = require "computer"

local g = comp.glasses
local m = comp.modem

g.removeAll()

local tab_functions = {
    [1] = function() switchTo("home_hud.lua") end,
    [2] = function() switchTo("draconic_energy_sphere_hud.lua") end,
    [3] = function() switchTo("entity_sensor_hud.lua") end,
    [4] = function() os.execute("time_widget.lua") end,
    [5] = function() g.removeAll() end,
    [6] = cleanExit
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
    print("got msg")
    print(port, packet)
    local msg = serialization.unserialize(packet)
    print("userialization finished")
    if port == 8001 and msg[1] ~= nil then
        print("executing function: "..msg[1])
        tab_functions[msg[1]]()
    else
        print("failed check")
    end
end

print("startup")
m.open(8000)
m.open(8001)
m.open(8002)
event.listen("modem_message", executeFunction)
