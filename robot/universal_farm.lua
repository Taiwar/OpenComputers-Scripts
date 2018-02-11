local robot = require("robot")
local sides = require("sides")
local event = require("event")
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
    for i = 0, rows do
        print("Continuing farming")
        if math.fmod(rows, 2) do
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
    end
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

print("Universal Farm")
print("Enter number of rows:")
rows = tonumber(io.read())
farmLoop()