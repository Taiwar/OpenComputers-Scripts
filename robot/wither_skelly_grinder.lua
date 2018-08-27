local robot = require "robot"
local comp = require "component"
local sides = require("sides")
local tb = comp.tractor_beam
local rs = comp.redstone

local out_side = sides.back
local currentRsStrength
local failsafe = false

function dropLoot()
    for i = 1, 16 do
        robot.select(i)
        robot.dropDown()
    end
end

function tractorSuckAll()
    local suckedSmth = true
    while suckedSmth do
        suckedSmth = tb.suck()
    end
end

dropLoot()
currentRsStrength = rs.setOutput(out_side, 0)
while true do
    print("Current stored rs out: "..currentRsStrength)
    print("Current measured rs out: "..rs.getOutput(out_side))
    local anything, type = robot.detect()
    print(anything)
    print(type)
    if type == "entity" or robot.swing() then
        print("detected entity")
        currentRsStrength = rs.setOutput(out_side, 0)
        local hitSmth = true
        local type = "entity"
        while hitSmth and type == "entity" do
            print("swinging")
            hitSmth, type = robot.swing()
        end
        print("sucking")
        tractorSuckAll()
        print("dropping")
        dropLoot()
        failsafe = false
    else
        if not failsafe then
            print("spawning more skellies")
            currentRsStrength = rs.setOutput(out_side, 15)
            failsafe = true
        else
            print("Failsafe activated, giving the sensor a good whack")
            robot.swing()
        end
    end
    os.sleep(1.5)
end