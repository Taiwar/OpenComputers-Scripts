local robot = require "robot"
local sides = require "sides"
local event = require "event"
local comp = require "component"

local ic = comp.inventory_controller
local m = comp.modem
local gen = comp.generator
local rs = comp.redstone

local in_side = sides.top
local out_side = sides.front
local refuel_side = sides.back
local inv_size = ic.getInventorySize(in_side)

local farmLoopDelay = 10
local idleLoopDelay = 30

doFarmLoop = true

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
    local gotCrystals = false
    for i = 1, inv_size do
        local stack = ic.getStackInSlot(in_side, i)
        if stack ~= nil then
            if stack["name"] == "appliedenergistics2:item.ItemCrystalSeed" then
                print("found seeds")
                robot.select(1)
                ic.suckFromSlot(in_side, i)
                gotCrystals = true
            end
        end
    end
    return gotCrystals
end

function dropSeeds(internal_inv)
    print("dddrop the seeds")
    for k, v in pairs(internal_inv) do
        if v["name"] == "appliedenergistics2:item.ItemCrystalSeed" then
            robot.select(k)
            robot.dropDown()
        end
    end
end

function storeCrystals(internal_inv)
    print("store Crystals")
    for k, v in pairs(internal_inv) do
        if v["name"] == "appliedenergistics2:item.ItemMultiMaterial" then
            robot.select(k)
            robot.drop(out_side)
        end
    end
end

function collectSeeds()
    print("callback time!")
    local crystals_below = true
    robot.select(1)
    while crystals_below do
        crystals_below = robot.suckDown()
    end
    storeCrystals(checkInv())
    dropSeeds(checkInv())
end

function checkFuel()
    local coal_count = gen.count()

    if coal_count < 32 then
        print("Refueling...")
        rs.setOutput(refuel_side, 15)
        os.sleep(16)
        rs.setOutput(refuel_side, 0)

        for i = 1, inv_size do
            local stack = ic.getStackInSlot(in_side, i)
            if stack ~= nil then
                if stack["name"] == "minecraft:coal" then
                    robot.select(16)
                    ic.suckFromSlot(in_side, i)
                    gen.insert()
                end
            end
        end

        print("success!")
    end
end

function checkMsg(_, _, _, _, _, msg)
    doFarmLoop = msg
end

m.open(8003)
event.listen("modem_message", checkMsg)

while true do
    checkFuel()
    if inv_size ~= nil then
        while doFarmLoop == true do
            print("farmLoop")
            if checkInput() == true then
                collectSeeds()
                dropSeeds(checkInv())
                event.timer(140, collectSeeds)
            end
            os.sleep(farmLoopDelay)
        end
    end
    print("idleLoop")
    os.sleep(idleLoopDelay)
end