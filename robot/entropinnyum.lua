local robot = require "robot"
local sides = require "sides"
local event = require "event"
local comp = require "component"
local computer = require "computer"

local rs = comp.redstone
local ic = comp.inventory_controller

local rs_in_side = sides.front
local rs_out_side = sides.bottom
local tnt_in_side = sides.top
-- local charger_side = sides.left
local flowerTimerDelay = 10
local flowers = 2

local timer

feedFlower = true
local flowerTimer = flowerTimerDelay

local eventHandlers = setmetatable({}, { __index = function() return unknownEvent end })

function eventHandlers.modem_message(_, _, _, _, _, msg)
    feedFlower = msg
end

function eventHandlers.redstone_changed(_, side, _, newValue)
    if side == rs_in_side and newValue > 0 then
        flowerTimer = flowerTimerDelay
    end
end

function eventHandlers.flowerTimer()
    print("handling timer event, timer: "..flowerTimer - 1)
    flowerTimer = flowerTimer - 1
    if flowerTimer < 0 then
        print("setting flowerTimer to: "..flowerTimerDelay)
        flowerTimer = flowerTimerDelay
        for i = 1, flowers do
            print("lighting tnt")
            light_tnt()
            os.sleep(4)
        end
    end
    -- if computer.energy() < 0.5 * computer.maxEnergy() then
    --    rs.setOutput(charger_side, 15)
    -- else
    --    rs.setOutput(charger_side, 0)
    -- end
    timer = event.timer(1, function() computer.pushSignal("flowerTimer") end)
end

function handleEvent(eventID, ...)
    if (eventID) and eventID == "modem_message" or eventID == "redstone_changed" or eventID == "flowerTimer" then
        print("got event: "..eventID)
        eventHandlers[eventID](...)
    end
end

function cleanExit()
    event.cancel(timer)
    os.exit()
end

function light_tnt()
    robot.select(1)
    -- robot.suckUp(1)
    ic.suckFromSlot(tnt_in_side, 1, 1)
    robot.placeDown()
    rs.setOutput(rs_out_side, 15)
    rs.setOutput(rs_out_side, 0)
end

timer = event.timer(1, function() computer.pushSignal("flowerTimer") end)

while true do
    handleEvent(event.pull())
end

