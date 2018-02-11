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

-- Keeps track of how many rows the robot has moved. Used for returning to starting position.
local rows = 0
-- How long the robot will wait between farming operations. Can be changed as needed.
local sleepInterval = 60

-- Main farm loop
function farmLoop()
    print("Farming")
    m.broadcast(80, "farming_started")
    robot.select(1)
    -- Move into position
    robot.up()
    robot.forward()
    -- Farm first strip
    farmStrip()
    -- Keep farming strips until hitting the container
    isNotPassable, state = robot.detect()
    while not checkForContainer() do
        -- Turn & move the right way at the end of a strip
        if math.fmod(rows, 2) == 0 then
            robot.turnRight()
            robot.forward()
            robot.turnRight()
            robot.forward()
        else
            robot.turnLeft()
            robot.forward()
            robot.turnLeft()
            robot.forward()
        end
        farmStrip()
        isNotPassable, state = robot.detect()
        rows = rows + 1
    end
    dropAndReturn()
end

-- While above crops (aka "passable"), harvest, replant and move forward
function farmStrip()
    isNotPassable, state = robot.detectDown()
    while state == "passable" do
        robot.swingDown()
        robot.suckDown()
        robot.select(1)
        robot.placeDown()
        robot.forward()
        isNotPassable, state = robot.detectDown()
    end
end

-- Drop all crops into container below and return to starting position
function dropAndReturn()
    itemcount = 0
    for i = 1, 4 do
        robot.select(i)
        slotcount = robot.count(i)
        itemcount = itemcount + slotcount
        robot.dropDown()
    end
    robot.turnRight()
    for i = 1, rows do 
        robot.forward()
    end
    robot.turnRight()
    robot.down()
    m.broadcast(80, "farming_finished " .. tostring(itemcount))
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