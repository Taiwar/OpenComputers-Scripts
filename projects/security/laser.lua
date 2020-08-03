local event = require("event")
local comp = require("component")
local turret = comp.os_energyturret
local sensor = comp.sensor

local scanned_area = {
    ["width"] = 50,
    ["height"] = 50,
    ["depth"] = 50
};

local laser_coords = {
    -324,
    74,
    4109
}

local sensor_coords = {
    -324,
    73,
    4108
}

local scan_timer

function init()
    turret.powerOn()
    turret.moveTo(0, 0)
    turret.setArmed(true)
    if turret.getShaftLength() < 1 then
        turret.extendShaft(1)
    end
    while not turret.isReady() do
        os.sleep(0.2)
    end
end

function scan()
    local potential_targets = {}
    local entities = sensor.searchEntities(
            scanned_area["width"]/-2,
            scanned_area["height"]/-2,
            scanned_area["depth"]/-2,
            scanned_area["width"]/2,
            scanned_area["height"]/2,
            scanned_area["depth"]/2)
    local i = 0
    for _, e in pairs(entities) do
        if type(e) == "table" then
            if e.name == "pumpkinsteph" then
                print("Got hostile: "..e.name)
                potential_targets[i] = e
                i = i + 1
            end
        end
    end
    print("returning targets")
    return potential_targets
end

function calculateLength(v)
    return math.sqrt(v[1] * v[1]  + v[2] * v[2] + v[3] * v[3])
end

function calculateAngle(v1, v2)
    local dot_product = v1[1] * v2[1] + v1[2] * v2[2] + v1[3] * v2[3]
    local lengths = calculateLength(v1) * calculateLength(v2)
    return math.acos(dot_product / lengths)
end

function printVector(v)
    print("{ x: "..v[1]..", y: "..v[2]..", z: "..v[3].." }")
end

function calculateConnectingVector(v1, v2)
    local diff = {
        v2[1] - v1[1],
        v2[2] - v1[2],
        v2[3] - v1[3],
    }
    return diff
end

function addVectors(v1, v2)
    return {
        v1[1] + v2[1],
        v1[2] + v2[2],
        v1[3] + v2[3]
    }
end

local barrel_offsets = {
    0.5,
    0.5
}
local target_height = 0.7

function lockOn(target)
    printVector(target)
    local x_diff = target[1] - (laser_coords[1] + barrel_offsets[1])
    local z_diff = (laser_coords[3] + barrel_offsets[2]) - target[3]
    local vector_lengths = math.sqrt(x_diff * x_diff + z_diff * z_diff)
    local yaw = math.atan(x_diff, z_diff)
    local target_y = target[2] + target_height
    local y_diff = target_y - laser_coords[2]
    local pitch = math.atan(y_diff / vector_lengths)
    turret.moveToRadians(yaw, pitch)

    local breaker = 0;
--    while not turret.isOnTarget() and breaker < 10 do
--        os.sleep(0.2)
--        breaker = breaker + 1
--    end
end

function handleTargets()
    print("Searching for targets")
    local targets = scan()
    if targets ~= nil then
        for _, v in pairs(targets) do
            if not turret.isReady() then
                print("arming")
                turret.powerOn()
                turret.setArmed(true)
            end
            print("Shooting at "..v.name)
            local position = {
                v.pos.x,
                v.pos.y,
                v.pos.z
            }
            lockOn(addVectors(sensor_coords, position))
            print("shooting")
            turret.fire()
        end
    else
        print("not targets")
    end
end

function handleExit()
    event.cancel(scan_timer)
    print("Laser: exiting")
end
init()
while true do
    handleTargets()
    os.sleep(0.2)
end
-- scan_timer = event.timer(2, handleTargets, math.huge)
