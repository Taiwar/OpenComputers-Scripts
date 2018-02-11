local robot = require("robot")
local sides = require("sides")
local event = require("event")
local math = require("math")
local component = require("component")
local computer = require("computer")

local m = component.modem
local rows = 0

function farmLoop()
    print("Farming")
    robot.select(1)
    isNotPassable, state = robot.detectDown()
    if state == "solid" then
        robot.up()
    end
    robot.forward()
    farmStrip()
    isNotPassable, state = robot.detect()
    while state == "air" do
    -- for i = 0, rows do
        print("Continuing farming")
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
        print(state)
        rows = rows + 1
    end
    dropAndReturn()
end

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

function dropAndReturn()
    for i = 1, 4 do
        robot.select(i)
        robot.dropDown()
    end
    robot.turnRight()
    for i = 1, rows do 
        robot.forward()
    end
    robot.turnRight()
    robot.down()
end

print("Universal Farm")
-- print("Enter number of rows:")
-- rows = tonumber(io.read()) - 1
while true do
    farmLoop()
    if (computer.energy()/computer.maxEnergy()) < 0.8 do
        print("Dummy charging function")
    end
    os.sleep(60)
end