local event = require("event")
local serialization = require("serialization")
local comp = require("component")
local turret = comp.os_energyturret

function init()
    turret.powerOn()
    turret.moveTo(0, 0)
    turret.setArmed(true)
    if turret.getShaftLength() > 0 then
        return turret.isReady()
    else
        turret.extendShaft(1)
        return turret.isReady()
    end
end

function lockOn(targetX, targetY, targetZ, targetDistance)
    local angleOffset;
    if targetZ < 0 then
        if targetX < 0 then
            angleOffset = 1.5 * math.pi
            targetX = -targetX
            targetZ = -targetZ
        else
            angleOffset = 0
            targetZ = -targetZ
        end
    else
        if targetX < 0 then
            angleOffset = math.pi
            targetX = -targetX
        else
            angleOffset = 0.5 * math.pi
        end
    end
    local XAngle = math.atan(targetX/targetZ)
    print("Laser: X", math.deg(XAngle))
    local YAngle = math.sin((targetY-1)/targetDistance)
    print("Laser: Y", math.deg(YAngle))
    if angleOffset == 90 or angleOffset == 270 then
        turret.moveTo(((90-math.deg(XAngle))+angleOffset), math.deg(YAngle))
    else
        turret.moveTo((math.deg(XAngle)+angleOffset), math.deg(YAngle))
    end
end

function handleTargets(_, players_msg)
    local players = serialization.unserialize(players_msg)
    for _,v in pairs(players) do
        if not v["isAuthorized"] then
            print("Laser: found target: ",v["x"], v["y"], v["z"], v["range"])
            lockOn(v["x"], v["y"], v["z"], v["range"])
            turret.fire()
        end
    end
end

function handleExit()
    event.ignore("radar", handleTargets)
    event.ignore("radar_exit", handleExit)
    print("Laser: exiting")
end

if init() then
    event.listen("radar", handleTargets)
    event.listen("radar_exit", handleExit)
else
    print("Laser: init failure")
end