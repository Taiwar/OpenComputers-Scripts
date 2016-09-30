local robot = require "robot"
local sides = require "sides"
local event = require "event"
local comp = require "component"

local ic = comp.inventory_controller
local m = comp.modem
local gen = comp.generator

local in_side = sides.top
local out_side = sides.front
local inv_size = ic.getInventorySize(in_side)

local farmLoopDelay = 10
local idleLoopDelay = 30

local doFarmLoop = false

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
            elseif stack["name"] == "minecraft:coal" then
                print("found coal")
                robot.select(16)
                ic.suckFromSlot(in_side, i)
                gen.insert()
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
            ic.dropIntoSlot(out_side, k)
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

function checkMsg(_, _, _, _, _, msg)
    doFarmLoop = msg
end

m.open(8003)
event.listen("modem_message", checkMsg)

while true do
    if inv_size ~= nil then
        while doFarmLoop == true do
            if checkInput() == true then
                collectSeeds()
                dropSeeds(checkInv())
                event.timer(120, collectSeeds)
            end
            os.sleep(farmLoopDelay)
        end
    end
    os.sleep(idleLoopDelay)
end