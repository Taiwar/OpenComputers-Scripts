local robot = require "robot"
local sides = require "sides"
local comp = require "component"

local ic = comp.inventory_controller

local in_side = sides.front
local inv_size = ic.getInventorySize(in_side)

local sortLoopDelay = 30
local isAtFurnace = false

function checkInv()
    print("cataloging internal inv")
    local slots = {}

    for i = 1, 16 do
        local stack = ic.getStackInInternalSlot(i)
        if stack ~= nil then
            slots[i] = stack
        end
    end

    return slots
end

function checkInput()
    print("checking input inv")
    local gotNetherOre = false
    for i = 1, inv_size do
        local stack = ic.getStackInSlot(in_side, i)
        if stack ~= nil then
            local matches = string.match(stack["name"], 'NetherOres?')
            if matches ~= nil then
                robot.select(1)
                if not ic.suckFromSlot(in_side, i) then
                    break
                end
                gotNetherOre = true
            end
        end
    end
    return gotNetherOre
end

function switchPosition()
    if not isAtFurnace then
        for i = 1,3 do
            robot.back()
        end
        isAtFurnace = true
    else
        for i = 1,3 do
            robot.forward()
        end
        isAtFurnace = false
    end
    print("switched position")
end

function transferOre(internal_inv)
    print("tranferring ore")
    switchPosition()
    if internal_inv ~= nil then
        for k, v in pairs(internal_inv) do
            if v["name"] ~= nil then
                robot.select(k)
                robot.dropUp()
            end
        end
    end
    switchPosition()
end

while true do
    if checkInput() then
        print("found nether ore")
        transferOre(checkInv())
    end
    print("going to sleep")
    os.sleep(sortLoopDelay)
end