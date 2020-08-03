--[===[
<< Essence Extractor >>
A script to automate crafting Mystical Agriculture essence into its products.
Works together with the Essence Processor to pull essence from an AE system and push the products back into it.
NOTE: This is probably also a baseline for a generic ae-system controller/interactor

Requirements (not minimum, just what it was tested on):
- Tier 3 computer
- OpenOS (+ Screen, Keyboard & HDD)
- Wireless Network Card
- Database Upgrade (needs to hold all different types of essence you want to process)
- One or more adapters adjacent to (currently) exactly one export bus and an arbitrary number of AE2 network blocks
  that offer the common network API (export bus sadly does not offer it despite it being described as such in the ocdoc).
  The example setup uses an ME Interface to access the common network API.

Functionality:
- Clear database entries
- Get all items in the AE network
- Filter them (are part of the correct mods, are essence, are not excluded)
- Store the results in the database as well as a table with their database ids
- Iterate through table;
    - Tell export bus to export item stack
    - Tell robot it has items to craft
    - Wait for robot to confirm it has crafted stack
--]===]

local comp = require "component"
local sides = require "sides"
local computer = require "computer"
local event = require "event"
local ser = require "serialization"
local aeSystem = comp.me_interface
local exportBus = comp.me_exportbus
local db = comp.database
local m = comp.modem

-- Constants for operation
local EXPORT_BUS_DIRECTION = sides.down
local INPUT_SLOT = 13
local PORT = 1000
local LOOP = true

-- Structure of "CraftingStart" table
local msgStartCrafting = {
    channel = "AEEssenceCrafting",
    type = "CraftingStart",
    sender = computer.address()
}

-- String constants to make writing exclusions easier and less error-prone
local MYSTICAL_AGRICULTURE = "mysticalagriculture:"
local MYSTICAL_AGRADDITIONS = "mysticalagradditions:"
local ESSENCE = "_essence"

-- List of strings which, when found in an item, will exclude them from processing
-- These are mainly essences which have multiple recipes and you don't want to autocraft into one specific recipe all the time
local exclusions = {
    "insanium",
    "supremium",
    "superium",
    "intermedium",
    "prudentium",
    "inferium",
    "fertilized",
    "dirt",
    "nature",
    "dye",
    "wood",
    "water",
    "ice",
    "fire",
    "nether",
    "experience",
    "rabbit",
    "mystical flower"
}

-- How many item-stacks are stored in the database
local stored = 0

-- Find target items to process (essences) in all items and store their item-stack information (if not excluded) in database
-- Note: "item" in this context means a type of item in the system and is not limited in amount
-- Precondition: items ~= nil
-- Returns: Table-representation of all non-excluded found items (essences)
function findEssences(items)
    local results = {}
    -- Iterate over each item
    for _, item in pairs(items) do
        -- Make sure item is a table
        if type(item) == 'table' then
            -- Look for all items that have either "mysticalagriculture:" or "mysticalagradditions:" and has "_essence" in its name
            if (string.find(string.lower(item['name']), MYSTICAL_AGRICULTURE)
                    or string.find(string.lower(item['name']), MYSTICAL_AGRADDITIONS))
                    and string.find(string.lower(item['name']), ESSENCE)
            then
                -- Go through all entries of the exclusions list and match the name of the item contains an excluded string
                local isExcluded = false
                for _, v in pairs(exclusions) do
                    if string.find(string.lower(item['label']), v) then
                        isExcluded = true
                        break
                    end
                end
                if not isExcluded then
                    -- Store item-stack information in new slot in db
                    stored = stored + 1
                    -- filter by exact name of item, store into local db at new highest id and only store one result of filter
                    aeSystem.store({name=item["name"]}, db.address, stored, 1)
                    -- also add found item to table with the database id as the key
                    results[stored] = item
                end
            end
        end
    end
    return results
end

-- Instructs a connected export bus to export a specific item from the database
function requestEssence(dbId)
    -- Configure export bus properly
    exportBus.setExportConfiguration(EXPORT_BUS_DIRECTION, 1, db.address, dbId)
    -- Trigger export once into robot-input-slot
    exportBus.exportIntoSlot(EXPORT_BUS_DIRECTION, INPUT_SLOT)
end

-- Clears db of all previous entries
function clearDb()
    local notCleared = true
    local i = 1
    -- While db is not empty, clear all ids starting at 1 and increasing by 1 each loop
    while notCleared do
        notCleared = db.clear(i) -- If clear() actually cleared something, it returns true
        i = i + 1
    end
end

-- Helper function to serialize and send a table over the network
function sendMessage(message)
    m.broadcast(PORT, ser.serialize(message))
end

-- Main program function
function main()
    -- Open modem port to receive/send messages
    m.open(PORT)
    clearDb()

    -- Fetch all items currents in AE network with no filter
    -- (the filter options don't seem to allow any fuzzy/complex filters so we're filtering the results ourselves)
    local currentState = aeSystem.getItemsInNetwork({})

    -- Find/Filter all essences we want to process
    local essences = findEssences(currentState)
    -- Process each essence
    for dbId, item in pairs(essences) do
        print("Crafting "..item["label"])

        -- Craft until there's <9 essence in the AE system left
        local itemCount = item["size"]
        while itemCount >= 9 do
            -- Request essence to be exportet into robot (Essence Processor)
            requestEssence(dbId)
            os.sleep(0.2) -- Give export bus some time
            -- Tell robot to start crafting
            sendMessage(msgStartCrafting)
            -- Wait for robot response
            local craftingFinished = false
            while not craftingFinished do
                -- Wait for message
                local _, _, _, _, _, message = event.pull("modem_message")
                -- Deserialize it
                message = ser.unserialize(message)
                -- If it's the correct type, stop looping
                craftingFinished = message["type"] == "CraftingFinished"
            end
            -- Refresh count
            itemCount = aeSystem.getItemsInNetwork({name=item["name"]})[1]["size"]
        end
    end
end

if LOOP then
    while true do
        main()
    end
else
    main()
end
