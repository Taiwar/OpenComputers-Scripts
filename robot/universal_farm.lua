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
    print(state)
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
    for i = 0, 4 do
        robot.select(i + 1)
        robot.dropDown()
    end
    robot.turnRight()
    for i = 1, rows do 
        robot.forward()
    end
    robot.turnRight()
end

print("Universal Farm")
-- print("Enter number of rows:")
-- rows = tonumber(io.read()) - 1
farmLoop()