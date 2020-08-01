local robot = require "robot"
local comp = require "component"
local sides = require("sides")
local tb = comp.tractor_beam
local rs = comp.redstone

local out_side = sides.bottom

function dropLoot()
    print("dropping")
    -- turn around
    robot.turnRight()
    robot.turnRight()
    -- iterate through all inv slots and drop them
    for i = 1, 16 do
        robot.select(i)
        robot.drop()
    end
    robot.turnRight()
    robot.turnRight()
end

function tractorSuckAll()
    print("sucking")
    local suckedSmth = true
    -- For as long as robot sucked something, suck
    while suckedSmth do
        suckedSmth = tb.suck()
        -- Wait a bit
        os.sleep(1)
    end
end

-- Setup

--empty inv
dropLoot()
-- set spawner to off
local currentRsStrength = rs.setOutput(out_side, 0)

while true do
    print("Current stored rs out: "..currentRsStrength)
    print("Current measured rs out: "..rs.getOutput(out_side))
    local anything, type = robot.detect()
    print(anything)
    print(type)
    if type == "entity" or robot.swing() then
        print("detected entity")
        print("stop spawning skellies")
        currentRsStrength = rs.setOutput(out_side, 0)

        local hitSmth = true
        while hitSmth do
            print("swinging")
            hitSmth, type = robot.swing()
            print("hit"..type)
        end

        tractorSuckAll()
        dropLoot()
    else
        print("spawning more skellies")
        currentRsStrength = rs.setOutput(out_side, 15)
    end

    -- sleep cycle
    os.sleep(1.5)
end