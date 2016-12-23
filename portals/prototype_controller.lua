dofile( "/usr/lib/table-save.lua" )

local comp = require("component")
local dials = comp.list("ep_dialling_device")
API = require("button_api")
local event = require("event")
local term = require("term")
local gpu = comp.gpu
local adresses = comp.list("screen")
local screen = {}

print("Enter Resolution")
term.write("X: ")
local screen_x = tonumber(term.read())
term.write("Y: ")
local screen_y = tonumber(term.read())
term.clear()
print("Select touchscreen:")
local loop_tracker = 1
for adress in adresses do
    screen[loop_tracker] = adress
    print("["..loop_tracker.."]: "..adress)
    loop_tracker = loop_tracker + 1
end
local primaryScreen = screen[tonumber(term.read())]
term.clear()
print("Select screen with keyboard:")
for k,v in pairs(screen) do
    print("["..k.."]: "..v)
end
local secondaryScreen = screen[tonumber(term.read())]
term.clear()
gpu.bind(primaryScreen)
gpu.setResolution(screen_x, screen_y)

function save_dests(destinations)
    assert( table.save( destinations, "destinations.lua" ) == nil )
end

function load_dests()
    local dests, err = table.load( "destinations.lua" )
    if err == nil then
        return dests
    end
    return {}
end

local destinations = load_dests()
local dests_amount = 0
for _,_ in pairs(destinations) do
    dests_amount = dests_amount + 1
end

local dest_length = 0
local two_digits = false
local page = 0

function API.fillTable()
    API.clear()
    API.clearTable()
    if page == 0 then
        API.heading("Portal Control")
        API.setTable("Exit", cmd_exit, nil, screen_x-14,screen_x-4,2,4)
        API.setTable("Add", cmd_add_dest, nil, screen_x-14,screen_x-4,screen_y-8,screen_y-4)
        if next(destinations) ~= nil then
            for k,v in pairs(destinations) do
                API.setTable(v["name"], cmd_tp, v, (screen_x - screen_x*0.9),(screen_x*0.85), 5 + (k-1)*(screen_y/15), 6 + (k-1)*(screen_y/15))
                API.setTable("Del "..k, cmd_delete_dest, k, (screen_x*0.85) + 2,(screen_x*0.85) + 8, 5 + (k-1)*(screen_y/15), 6 + (k-1)*(screen_y/15))
            end
            API.label(2, 50, "Available Dests: "..dests_amount)
        else
            API.label(70, 22, "No Destinations available")
        end
    elseif page == 1 then
        API.heading("Enter Destination UID")
        API.label(10, 40, "UID: ")
        for i = 0, 26 do
            API.setTable(tostring(i), cmd_entered_char, tostring(i), 10 + i*(screen_x/10) - math.floor(i/9) * (screen_x - 6), 22 + i*(screen_x/10)  - math.floor(i/9) * (screen_x - 6), 5 + math.floor(i/9) * (screen_y/10 * 2), 10 + math.floor(i/9) * (screen_y/10 * 2))
        end

        API.setTable(" ", cmd_entered_char, " ", screen_x-42,screen_x-32,screen_y-8,screen_y-4)
        API.setTable("Delete", cmd_delete, nil, screen_x-28,screen_x-18,screen_y-8,screen_y-4)
        API.setTable("Done", cmd_done, nil, screen_x-14,screen_x-4,screen_y-8,screen_y-4)
    end
    API.screen()
end

function getClick()
    local _, _, x, y = event.pull(1,touch)
    if x == nil or y == nil then
        local h, w = gpu.getResolution()
        gpu.set(h, w, ".")
        gpu.set(h, w, " ")
    else
        API.checkxy(x,y)
    end
end

function cmd_exit()
    API.clear()
    term.clear()
    gpu.bind(secondaryScreen)
    gpu.setResolution(screen_x, screen_y)
    os.exit()
end

function cmd_delete_dest(dest_key)
    API.flash("Del "..dest_key, 0.2)
    if destinations[dest_key + 1] == nil then
        destinations[dest_key] = nil
    else
        destinations[dest_key] = destinations[dest_key + 1]
        destinations[dest_key + 1] = nil
    end
    save_dests(destinations)
    API.fillTable()
end

function cmd_tp(destination)
    API.toggleButton(destination["name"])
    for adress in dials do
        local proxy = comp.proxy(adress)
        proxy.dial(destination["uid"])
    end
    os.sleep(5)
    for adress in dials do
        local proxy = comp.proxy(adress)
        proxy.terminate()
    end
    API.toggleButton(destination["name"])
end

function cmd_add_dest()
    page = 1
    dests_amount = dests_amount + 1
    destinations[dests_amount] = {}
    destinations[dests_amount]["uid"] = ""
    destinations[dests_amount]["name"] = ""
    dest_length = 0
    two_digits = false
    API.fillTable()
end

function cmd_entered_char(char)
    API.flash(char, 0.2)
    if dest_length < 9 then
        if string.len(char) < 2 then
            two_digits = false
        else
            two_digits = true
        end
        if dest_length ~= 0 then
            destinations[dests_amount]["uid"] = destinations[dests_amount]["uid"].." "..char
        else
            destinations[dests_amount]["uid"] = tostring(char)
        end

        dest_length = dest_length + 1
    else
        API.label(10, 42, "UID always contains 9 glyphs!")
    end
    API.label(10, 40, "UID: "..destinations[dests_amount]["uid"])
end

function cmd_done()
    API.flash("Done", 0.2)
    if dest_length == 9 then
        API.clearTable()
        API.label(50, 20, "!Enter name for new destination on screen with keyboard!")
        gpu.bind(secondaryScreen)
        gpu.setResolution(screen_x, screen_y)
        API.clearTable()
        API.heading("Enter Name for: "..destinations[dests_amount]["uid"])
        while true do
            local _, char, code, _ = event.pull("key_down")
            if code == 8 or char == 0 then
                destinations[dests_amount]["name"] = string.sub(destinations[dests_amount]["name"], 1, #destinations[dests_amount]["name"]-1)
            elseif code == 13 then
                term.clear()
                gpu.bind(primaryScreen)
                gpu.setResolution(screen_x, screen_y)
                save_dests(destinations)
                page = 0
                API.fillTable()
                break
            elseif #destinations[dests_amount ]["name"] <=30 then
                destinations[dests_amount]["name"] = destinations[dests_amount]["name"] .. string.char(code)
            end
            API.label(50, 20, destinations[dests_amount]["name"])
            API.label(50, 40, "Press enter when finished")
        end
    else
        API.label(10, 42, "UID always contains 9 glyphs!")
    end
end

function cmd_delete()
    API.flash("Delete", 0.2)
    if dest_length ~= 0 and not two_digits then
        destinations[dests_amount ]["uid"] = destinations[dests_amount]["uid"]:sub(2, -2)
        dest_length = dest_length - 1
    elseif dest_length ~= 0 and two_digits then
        destinations[dests_amount]["uid"] = destinations[dests_amount]["uid"]:sub(3, -2)
        dest_length = dest_length - 1
    end
    API.label(10, 40, "UID: "..destinations[dests_amount]["uid"])
end


term.setCursorBlink(false)
API.clear()
API.fillTable()

while true do
    getClick()
end