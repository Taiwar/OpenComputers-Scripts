--[===[
<< Essence Processor >>
A script to automate crafting Mystical Agriculture essence into its products.
Works together with the Essence Extractor to pull essence from an AE system and push the products back into it.

Note
This is probably also a baseline for a generic robot-autocrafter with potentially dynamic recipes and mappings

Requirements (not minimum, just what it was tested on):
- Tier 2 Robot
- OpenOS (+ Screen, Keyboard & HDD)
- Inventory Upgrade
- Inventory Controller Upgrade
- Wireless Network Card
- Crafting Upgrade

Functionality:
- Waits for message from extractor that it has sent the essence
- Aligns input essence into crafting grid (top left 3x3 in robot inventory) according to recipe mappings (default is circle)
- Crafts until output slot is full
- Drops items in output slot out the front of the robot (should be an interface or a different inventory that the products should be stored in)
- Continues until input slot is empty/doesn't contain enough essence for recipe
- Sends message to extractor that robot is done crafting
- (repeat)
--]===]

local robot = require "robot"
local computer = require "computer"
local comp = require "component"
local event = require "event"
local ser = require "serialization"
local c = comp.crafting
local ic = comp.inventory_controller
local m = comp.modem

local currentState

-- Constants for operation
local OUTPUT_SLOT = 16
local INPUT_SLOT = 13
local PORT = 1000

-- Structure of "CraftingFinished" table
local msgFinishedCrafting = {
    channel = "AEEssenceCrafting",
    type = "CraftingFinished",
    sender = computer.address()
}

-- Predefined recipes for crafting essences
-- 0 = none
-- anything else = amount provided / given positions
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

-- String constants to make writing mappings easier and less error-prone
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
mappings[MYSTICAL_AGRICULTURE.."blitz"..ESSENCE] = recipes["cross"]
mappings[MYSTICAL_AGRICULTURE.."saltpeter"..ESSENCE] = recipes["line"]

-- Helper function to create sum of elements in table
-- Preconditions: t ~= nil and t only contains numbers
-- Returns: Sum of elements in table
function sumTable(t)
    local sum = 0
    for _, v in pairs(t) do
        sum = sum + v
    end
    return sum
end

-- Aligns essence into crafting grid
-- Returns: True if recipe could be formed at least once, otherwise false
function alignEssence()
    local couldAlign = false

    local essence = ic.getStackInInternalSlot(INPUT_SLOT)
    robot.select(INPUT_SLOT)

    -- Only process further if there is essence in the input slot
    if essence ~= nil then
        -- If no matching mapping can be found, use default recipe
        local recipe = recipes["default"]

        -- Check if there's an entry in mappings with this essence's name
        if mappings[essence["name"]] ~= nil then
            -- Set recipe to the one in the matching mapping
            recipe = mappings[essence["name"]]
        end

        -- Calculate amount of essence per position in recipe
        local amountPerPosition = 0
        -- Avoid division by 0
        if sumTable(recipe) ~= 0 then
            -- Amount per position is maximum (total / positions) rounded down
            amountPerPosition = math.floor(robot.count() / sumTable(recipe))
        end

        -- Only align items if pattern can be filled at least once
        if amountPerPosition >= 1 then
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
                    -- Transfer calculated amount to slot in "crafting table"
                    robot.transferTo(slot, amountPerPosition)
                end
            end
            couldAlign = true
        end
    end
    return couldAlign
end

-- Craft essences in input slot until no longer possible
function craftEssence()
    -- Only craft if essence could be aligned
    if alignEssence() then
        repeat
            local couldCraft = true
            -- Keep crafting and exporting while it works
            while couldCraft do
                robot.select(OUTPUT_SLOT)
                -- always try to craft a bit less than a stack, so there's no overflow
                couldCraft = c.craft(48) -- returns true if it was able to craft at least one result
                -- if something is in outputSlot, export it
                if robot.count() > 0 then
                    outputResult()
                end
            end
        until not alignEssence() -- repeat until input is not enough to fill pattern anymore
    end
    cleanInv()
end

-- Cleans robot's inventory
-- Precondition: Only input slot may contain something after craftEssence is done
-- (assumption is made to save time and should be true with how the other functions are written)
function cleanInv()
    robot.select(INPUT_SLOT)
    -- Drop out the front because in the example setup this is an interface and therefore passed back into the system for potential future use
    robot.drop()
end

-- Output results in output slot
function outputResult()
    robot.select(OUTPUT_SLOT)
    -- Drop out the front because in the example setup this is an interface
    robot.drop()
end

-- Helper function to serialize and send a table over the network
function sendMessage(message)
    m.broadcast(PORT, ser.serialize(message))
end

-- Main program function
function main()
    -- Open modem port to receive/send messages
    m.open(PORT)

    -- Main program loop
    while true do
        -- Wait for message
        local _, _, _, _, _, message = event.pull("modem_message")
        -- Deserialize it
        message = ser.unserialize(message)

        -- If it's the correct type, start crafting and send reply when done
        if message["type"] == "CraftingStart" then
            craftEssence()
            sendMessage(msgFinishedCrafting)
        end
    end
end

main()