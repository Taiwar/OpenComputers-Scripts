dofile( "/usr/lib/table-save.lua" )

local comp = require("component")
local dials = comp.list("ep_dialling_device")
local ed = comp.os_entdetector
API = require("button_api")
local event = require("event")
local term = require("term")
local gpu = comp.gpu
local adresses = comp.list("screen")
local screen = {}
local internet = require("internet")

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
--gpu.setResolution(160, 50)

function save_dests(destinations)
    assert(table.save(destinations, "destinations.lua" ) == nil)
end

function save_trespassers(trespassers)
    assert(table.save(trespassers, "trespassers.lua" ) == nil)
end

function load_dests()
    local dests, err = table.load( "destinations.lua" )
    if err == nil then
        return dests
    end
    return {}
end

function load_trespassers()
    local tps, err = table.load( "trespassers.lua" )
    if err == nil then
        return tps
    end
    return {}
end

local destinations = load_dests()
local trespassers = load_trespassers()

local dests_amount = 0
for _,_ in pairs(destinations) do
    dests_amount = dests_amount + 1
end

local tps_amount = 0
for _,_ in pairs(trespassers) do
    tps_amount = tps_amount + 1
end

local dest_length = 0
local two_digits = false
local page = 0

function API.fillTable()
    API.clear()
    API.clearTable()
    if page == 0 then
        API.heading("Portal Control")
        API.setTable("Exit", cmd_exit, nil, 140,156,2,4)
        API.setTable("Add", cmd_add_dest, nil, 140,156,44,48)
        if next(destinations) ~= nil then
            for k,v in pairs(destinations) do
                API.setTable(v["name"], cmd_tp, v, 30,130,10 + (k-1)*4,11 + (k-1)*4)
                API.setTable("Del "..k, cmd_delete_dest, k, 134,140,10 + (k-1)*4,11 + (k-1)*4)
            end
            API.label(2, 50, "Available Dests: "..dests_amount)
        else
            API.label(70, 22, "No Destinations available")
        end
    elseif page == 1 then
        API.heading("Enter Destination UID")
        API.label(10, 40, "UID: ")
        for i = 0, 26 do
            API.setTable(tostring(i), cmd_entered_char, tostring(i), 10 + i*16 - math.floor(i/9) * 144, 22 + i*16  - math.floor(i/9) * 144, 5 + math.floor(i/9) * 12, 10 + math.floor(i/9) * 12)
        end

        API.setTable(" ", cmd_entered_char, " ", 82,102,40,44)
        API.setTable("Delete", cmd_delete, nil, 106,126,40,44)
        API.setTable("Done", cmd_done, nil, 130,152,40,44)
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
    --gpu.setResolution(160, 50)
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
        monitor_trespassers(destination["name"])
    end
    os.sleep(5)
    for adress in dials do
        local proxy = comp.proxy(adress)
        proxy.terminate()
    end
    API.toggleButton(destination["name"])
end

function monitor_trespassers(dest_name)
    tps_amount = tps_amount + 1
    trespassers[tps_amount] = {}
    local players = ed.scanPlayers(64)
    trespassers[tps_amount]["names"] = ""
    trespassers[tps_amount]["destination"] = dest_name
    for _, v in pairs(players) do
       trespassers[tps_amount]["names"] = trespassers[tps_amount]["names"].." "..v["name"]
    end
    trespassers[tps_amount]["time"] =  pcall(internet.request("http://www.timeapi.org/cet/now")())
    save_trespassers(trespassers)
    internet.request("https://muellersites.net/testsites/oc_api.php", {players = trespassers[tps_amount]["names"], destination = trespassers[tps_amount]["destination"], timestamp = trespassers[tps_amount]["time"]})
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
        gpu.setResolution(160, 50)
        API.clearTable()
        API.heading("Enter Name for: "..destinations[dests_amount]["uid"])
        while true do
            local _, char, code, _ = event.pull("key_down")
            if code == 8 or char == 0 then
                destinations[dests_amount]["name"] = string.sub(destinations[dests_amount]["name"], 1, #destinations[dests_amount]["name"]-1)
            elseif code == 13 then
                term.clear()
                gpu.bind(primaryScreen)
                --gpu.setResolution(160, 50)
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
--gpu.setResolution(160, 50)
API.clear()
API.fillTable()

while true do
    getClick()
end