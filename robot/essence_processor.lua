local robot = require "robot"
local computer = require "computer"
local comp = require "component"
local sides = require "sides"
local event = require "event"
local ser = require "serialization"
local c = comp.crafting
local ic = comp.inventory_controller
local m = comp.modem

local currentState

local OUTPUT_SLOT = 16
local INPUT_SLOT = 13
local PORT = 1000

local msgFinishedCrafting = {
    channel = "AEEssenceCrafting",
    type = "CraftingFinished",
    sender = computer.address()
}

-- Predefined recipes for crafting essences
--  0 = none
--  anything else = amount provided / given positions
local recipes = {
    default = {
        1, 1, 1,
        1, 0, 1,
        1, 1, 1
    },
    full = {
        1, 1, 1,
        1, 1, 1,
        1, 1, 1
    },
    dumbbell = {
        1, 1, 1,
        0, 1, 0,
        1, 1, 1
    },
    line = {
        1, 1, 1,
        0, 0, 0,
        0, 0, 0
    },
    cross = {
        0, 1, 0,
        1, 1, 1,
        0, 1, 0
    }
}

local MYSTICAL_AGRICULTURE = "mysticalagriculture:"
local MYSTICAL_AGRADDITIONS = "mysticalagradditions:"
local ESSENCE = "_essence"

-- Set up mappings of essence-name to recipe-layout
local mappings = {}
mappings[MYSTICAL_AGRICULTURE.."nether_quartz"..ESSENCE] = recipes["dumbbell"]
mappings[MYSTICAL_AGRICULTURE.."redstone"..ESSENCE] = recipes["full"]
mappings[MYSTICAL_AGRICULTURE.."silicon"..ESSENCE] = recipes["line"]
mappings[MYSTICAL_AGRICULTURE.."rubber"..ESSENCE] = recipes["line"]
mappings[MYSTICAL_AGRICULTURE.."blizz"..ESSENCE] = recipes["cross"]
mappings[MYSTICAL_AGRICULTURE.."basalz"..ESSENCE] = recipes["cross"]

function sumTable(t)
    local sum = 0
    for _, v in pairs(t) do
        sum = sum + v
    end
    return sum
end

function alignEssence()
    print("alignEssence")
    local couldAlign = false

    local essence = ic.getStackInInternalSlot(INPUT_SLOT)
    robot.select(INPUT_SLOT)

    local recipe = recipes["default"]

    if essence ~= nil then
        if mappings[essence["name"]] ~= nil then
            recipe = mappings[essence["name"]]
        end

        local amountPerPosition = 0

        print("Needed for one recipe: "..sumTable(recipe))
        print("In input slot: "..robot.count())
        if sumTable(recipe) ~= 0 then
            print("Calculation amountPerPosition")
            amountPerPosition = math.floor(robot.count() / sumTable(recipe))
        end

        print("aPP: ".. amountPerPosition)
        -- Only align items if pattern can be filled at least once
        if amountPerPosition >= 1 then
            print("Can align at least once. Aligning...")
            for position, amount in pairs(recipe) do
                if amount > 0 then
                    -- This mapping from position to inventory slot is not pretty, but it works
                    local slot = position
                    if position > 3 then
                        slot = slot + 1
                        if position > 6 then
                            slot = slot + 1
                        end
                    end
                    print("transfering stack")
                    robot.transferTo(slot, amountPerPosition)
                end
            end
            couldAlign = true
        end
    else
        couldAlign = false
    end
    os.sleep(0.5) -- buffer
    return couldAlign
end

function craftEssence()
    print("craftEssence")
    -- Only craft if essence could be aligned
    if alignEssence() then
        repeat
            print("Could align")
            local couldCraft = true
            -- Keep crafting and exporting while it works
            while couldCraft do
                print("could craft")
                robot.select(OUTPUT_SLOT)
                -- always try to craft a bit less than a stack, so there's no overflow
                couldCraft = c.craft(48)
                -- if something is in outputSlot, export it
                if robot.count() > 0 then
                    outputResult()
                end
            end
        until not alignEssence() -- repeat until input is not enough to fill pattern anymore
    else
        print("Could not craft anything: Too little essence")
    end
    cleanInv()
end

function cleanInv()
    robot.select(INPUT_SLOT)
    robot.drop()
end

function outputResult()
    print("outputResult")
    robot.drop()
end

function sendMessage(message)
    print("sendMessage: "..message["type"])
    m.broadcast(PORT, ser.serialize(message))
end

function main()
    craftEssence()
    os.sleep(0.5) -- buffer
    sendMessage(msgFinishedCrafting)
end

m.open(PORT)

while true do
    local _, _, _, _, _, message = event.pull("modem_message")
    message = ser.unserialize(message)
    if message["type"] == "CraftingStart" then
        main()
    end
end

-- main()