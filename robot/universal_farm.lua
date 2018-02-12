--[===[

<< UNIVERSAL FARM by Taiwar & Lumia >>
A script to automate a field of crops using a Robot.

Requirements:
- Tier 2 Robot
- OpenOS (+ Screen, Keyboard & HDD)
- Inventory Upgrade
- Hover Upgrade
- Wireless Network Card
- A container in Slot 16 matching the one at the end of a field
- (Optional) Solar Upgrade

Functionality:
Starts at the leftmost corner of a field, harvests + replants all crops in a strip
and moves onto the next strip until hitting a container at the end of one.
Dumps all remaining crops into this container and moves to starting position.
Robot also broadcasts start and finish of a farming operation.

Planned:
More wireless intercativity (e.g. Start/Stop command).
More error handling (e.g. Player blocking path).

--]===]
local robot = require("robot")
local sides = require("sides")
local event = require("event")
local math = require("math")
local component = require("component")
local computer = require("computer")

local m = component.modem


-- How long the robot will wait between farming operations. Can be changed as needed.
local sleepInterval = 120

-- Main farm loop
function farmLoop()
    print("Farming")
    -- Keeps track of how many rows the robot has moved. Used for returning to starting position.
    rows = 0
    m.broadcast(80, "farming_started")
    robot.select(1)
    -- Move into position
    robot.up()
    robot.forward()
    -- Keep farming strips until hitting the container
    isNotPassable, state = robot.detect()
    while true do
        -- Turn & move the right way at the end of a strip
        if not farmStrip(rows) then
            if checkForContainer() then
                print("Found chest, breaking...")
                break
            end
            print("Turning")
            if math.fmod(rows, 2) == 0 then
                robot.turnRight()
                -- Failsafe if something blocks path
                if not robot.forward() then
                    robot.turnLeft()
                    robot.back()
                    robot.turnRight()
                    robot.forward()
                    robot.turnRight()
                else
                    robot.turnRight()
                    robot.forward()
                end
            else
                robot.turnLeft()
                if not robot.forward() then
                    robot.turnRight()
                    robot.back()
                    robot.turnLeft()
                    robot.forward()
                    robot.turnLeft()
                else
                    robot.turnLeft()
                    robot.forward()
                end
            end
        end
        isNotPassable, state = robot.detect()
        rows = rows + 1
    end
    dropAndReturn(rows)
end

-- While above crops (aka "passable"), harvest, replant and move forward
function farmStrip(row)
    print("Farming row: "..row)
    isNotPassable, state = robot.detectDown()
    isAligned = false
    while state == "passable" do
        robot.swingDown()
        robot.suckDown()
        replantCrop()
        if not robot.forward() then
            print("Making sharp turn")
            if math.fmod(rows, 2) == 0 then
                robot.turnRight()
                robot.forward()
                robot.turnRight()
            else
                robot.turnLeft()
                robot.forward()
                robot.turnLeft()
            end
            isAligned = true
            break
        end
        isNotPassable, state = robot.detectDown()
    end
    print("Finished row")
    return isAligned
end

-- Drop all crops into container below and return to starting position
function dropAndReturn(distance)
    itemcount = 0
    for i = 1, 8 do
        robot.select(i)
        slotcount = robot.count(i)
        itemcount = itemcount + slotcount
        robot.dropDown()
    end
    robot.turnRight()
    for i = 1, distance do 
        robot.forward()
    end
    robot.turnRight()
    robot.down()
    m.broadcast(80, "farming_finished " .. tostring(itemcount))
end

-- Handles crops with multiple drops by looping through slots until one item successfully plants something
function replantCrop()
    slot = 1
    robot.select(slot)
    robot.placeDown()
    isNotPassable, state = robot.detectDown()
    while state == "air" do
        slot = slot + 1
        if slot > 16 then
            print("Error: Failed to plant seeds")
            os.exit()
        end
        robot.select(slot)
        robot.placeDown()
        isNotPassable, state = robot.detectDown()
    end
end

-- Check if container in slot 16 matches the block below
function checkForContainer()
    robot.select(16)
    isContainer = robot.compareDown()
    robot.select(1)
    return isContainer
end

-- Check energy level and charge when needed
function manageEnergy()
    while (computer.energy()/computer.maxEnergy()) < 0.8 do
        print("Charging...")
        os.sleep(1)
    end
end

print("<< [Universal Farm] >>")
print("Starting up...")
if robot.count(16) == 0 then
    print("Please insert a container into slot 16")
    os.exit()
end
while true do
    farmLoop()
    manageEnergy()
    print("Finished")
    os.sleep(sleepInterval)
end