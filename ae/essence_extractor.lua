local comp = require "component"
local sides = require "sides"
local computer = require "computer"
local event = require "event"
local ser = require "serialization"
local aeSystem = comp.me_interface
local exportBus = comp.me_exportbus
local db = comp.database
local m = comp.modem

local EXPORT_BUS_DIRECTION = sides.down
local OUTPUT_SLOT = 16
local INPUT_SLOT = 13
local PORT = 1000

local msgStartCrafting = {
    channel = "AEEssenceCrafting",
    type = "CraftingStart",
    sender = computer.address()
}

local MYSTICAL_AGRICULTURE = "mysticalagriculture:"
local MYSTICAL_AGRADDITIONS = "mysticalagradditions:"

local currentState
local stored = 0

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

function findEssences()
    print("findEssences")
    local results = {}
    for _, item in pairs(currentState) do
        if type(item) == 'table' then
            if (string.find(string.lower(item['name']), MYSTICAL_AGRICULTURE)
                    or string.find(string.lower(item['name']), MYSTICAL_AGRADDITIONS))
                    and string.find(string.lower(item['name']), 'essence')
            then
                local isExcluded = false
                for _, v in pairs(exclusions) do
                    if string.find(string.lower(item['label']), v) then
                        isExcluded = true
                        break
                    end
                end
                if not isExcluded then
                    aeSystem.store({name=item["name"]}, db.address, stored+1, 1)
                    stored = stored + 1
                    results[stored] = item
                end
            end
        end
    end
    return results
end

function requestEssence(dbId)
    print("requestEssence")
    exportBus.setExportConfiguration(EXPORT_BUS_DIRECTION, 1, db.address, dbId)
    exportBus.exportIntoSlot(EXPORT_BUS_DIRECTION, INPUT_SLOT)
end

function clearDb()
    print("clearDb")
    local notCleared = true
    local i = 1
    while notCleared do
        notCleared = db.clear(i) -- If clear() actually cleared something, it returns true
        i = i + 1
    end
end

function sendMessage(message)
    print("sendMessage: "..message["type"])
    m.broadcast(PORT, ser.serialize(message))
end

function main()
    clearDb()
    currentState = aeSystem.getItemsInNetwork({})
    local essences = findEssences()
    for dbId, item in pairs(essences) do
        print("Requesting "..item["label"])
        requestEssence(dbId)
        os.sleep(0.5) -- Give export bus some time
        sendMessage(msgStartCrafting)
        local craftingFinished = false
        while not craftingFinished do
            local _, _, _, _, _, message = event.pull("modem_message")
            message = ser.unserialize(message)
            craftingFinished = message["type"] == "CraftingFinished"
        end
    end
end

m.open(PORT)

main()