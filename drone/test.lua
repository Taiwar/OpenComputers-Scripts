local drone = component.proxy(component.list("drone")())
local nav = component.proxy(component.list("navigation")())
 
local waypointLookRadius = 64
local colours = {["travelling"] = 0xFFFFFF, ["waiting"] = 0x0092FF, ["partying"] = 0x660066}
 
local cx, cy, cz
local BASE
local PARTY
 
function getWaypoints()
    BASE, PARTY = {}, {}
    cx, cy, cz = 0, 0, 0
    local waypoints = nav.findWaypoints(waypointLookRadius)
    for i=1, waypoints.n do
        if waypoints[i].label == "BASE" then
            BASE.x = waypoints[i].position[1]
            BASE.y = waypoints[i].position[2]
            BASE.z = waypoints[i].position[3]
        elseif waypoints[i].label == "PARTY" then
            PARTY.x = waypoints[i].position[1]
            PARTY.y = waypoints[i].position[2]
            PARTY.z = waypoints[i].position[3]
        end
    end
end
 
function colour(state)
    drone.setLightColor(colours[state] or 0x000000)
end
 
function move(tx, ty, tz)
    local dx = tx - cx
    local dy = ty - cy
    local dz = tz - cz
    drone.move(dx, dy, dz)
    while drone.getOffset() > 0.7 or drone.getVelocity() > 0.7 do
        computer.pullSignal(0.2)
    end
    cx, cy, cz = tx, ty, tz
end
 
function getCharge()
    return computer.energy()/computer.maxEnergy()
end

function partyHard() 
    colour("travelling")
    move(PARTY.x, PARTY.y+1, PARTY.z)
    colour("partying")
    for i=1, 8 do
        move(PARTY.x, PARTY.y+3, PARTY.z) 
        move(PARTY.x, PARTY.y+1, PARTY.z) 
    end
end
 
function waitAtBase()
    colour("travelling")
    move(BASE.x, BASE.y+1, BASE.z)

    colour("waiting")
    while getCharge() < 0.9 do
        computer.pullSignal(1)
    end
end
 
function init()
    getWaypoints()
    waitAtBase()
    while true do
        partyHard()
        if getCharge() < 0.9 then
            getWaypoints()
            waitAtBase()
        end
    end
end
 
init()