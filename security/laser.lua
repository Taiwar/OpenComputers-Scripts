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