-- A controller designed to adapt to a user-specified resolution
-- Currently handles resolutions with the aspect ratio of 2:1 fairly well and others like 160:50 not so much
dofile( "/usr/lib/table-save.lua" )

local comp = require("component")
API = require("button_api")
local event = require("event")
local term = require("term")
local internet = require("internet")
local dials = comp.list("ep_dialling_device")
local ed = comp.os_entdetector
local gpu = comp.gpu
local adresses = comp.list("screen")
local screen = {}

-- IMO optimal resolutions but you can change them.
-- The secondary screen can have a much lower resolution if needed, because it doesn't display much
local primaryScreenRes = {120, 60} -- touch screen
local secondaryScreenRes = {160, 50} -- keyboard screen

local w = primaryScreenRes[1]
local h = primaryScreenRes[2]

local primaryScreen;
local secondaryScreen;

function round(x)
    if x%2 ~= 0.5 then
        return math.floor(x+0.5)
    end
    return x-0.5
end

function init()
    term.clear()
    print("Select touchscreen:")
    local loop_tracker = 1
    for adress in adresses do
        screen[loop_tracker] = adress
        print("["..loop_tracker.."]: "..adress)
        loop_tracker = loop_tracker + 1
    end

    primaryScreen = screen[tonumber(term.read())]
    term.clear()
    print("Select screen with keyboard:")
    for k,v in pairs(screen) do
        print("["..k.."]: "..v)
    end
    secondaryScreen = screen[tonumber(term.read())]

    term.clear()
    gpu.bind(primaryScreen)
    API.setRes(w, h)
end

function save_dests(destinations)
    assert(table.save(destinations, "destinations.lua") == nil)
end

function save_trespassers(trespassers)
    assert(table.save(trespassers, "trespassers.lua") == nil)
end

function load_dests()
    local dests, err = table.load("destinations.lua")
    if err == nil then
        return dests
    end
    return {}
end

function load_trespassers()
    local tps, err = table.load("trespassers.lua")
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
        API.setTable("Exit", cmd_exit, nil, w - 8, w - 2,2,4)
        API.setTable("Add", cmd_add_dest, nil, w - 12, w - 2, h - 4, h - 2)
        if next(destinations) ~= nil then
            for k,v in pairs(destinations) do
                API.setTable(v["name"], cmd_tp, v, w/12, w - w/12 - 6,10 + (k-1)*4,11 + (k-1)*4)
                API.setTable("Del "..k, cmd_delete_dest, k, w - w/12 - 4, w - w/12, 10 + (k-1)*4, 11 + (k-1)*4)
            end
            API.label("Available Dests: "..dests_amount, 2, h - 2)
        else
            API.centerLabel("No Destinations available", h/2)
        end
    elseif page == 1 then
        API.heading("Enter Destination UID")
        API.centerLabel("UID: ", h/2 + h/4)
        for i = 0, 26 do
            API.setTable(tostring(i), cmd_entered_char, tostring(i), w/12 + i * round(w/12 + w/48) - math.floor(i/9) * round(w - (w/12 + w/48)), w/6 + i * round(w/12 + w/48)  - math.floor(i/9) * round(w - (w/12 + w/48)), 5 + math.floor(i/9) * h/5, h/6 + math.floor(i/9) * h/5)
        end

        API.setTable(" ", cmd_entered_char, " ", w - 36, w - 26, h - 4, h - 2)
        API.setTable("Delete", cmd_delete, nil, w - 24, w - 14, h - 4, h - 2)
        API.setTable("Done", cmd_done, nil, w - 12, w - 2, h - 4, h - 2)
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
    API.setRes(secondaryScreenRes[1], secondaryScreenRes[2])
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
        API.centerLabel("UIDs always contain 9 glyphs!",  h/2 + h/4 + 2)
    end
    API.centerLabel("UID: "..destinations[dests_amount]["uid"], h/2 + h/4)
end

function cmd_done()
    API.flash("Done", 0.2)
    if dest_length == 9 then
        API.clearTable()
        API.centerLabel("!Enter name for new destination on screen with keyboard!", h/2)
        gpu.bind(secondaryScreen)
        API.setRes(secondaryScreenRes[1], secondaryScreenRes[2])
        API.clearTable()
        API.heading("Enter Name for: "..destinations[dests_amount]["uid"])
        while true do
            local _, char, code, _ = event.pull("key_down")
            if code == 8 or char == 0 then
                destinations[dests_amount]["name"] = string.sub(destinations[dests_amount]["name"], 1, #destinations[dests_amount]["name"]-1)
            elseif code == 13 then
                term.clear()
                gpu.bind(primaryScreen)
                API.setRes(w, h)
                save_dests(destinations)
                page = 0
                API.fillTable()
                break
            elseif #destinations[dests_amount ]["name"] <=30 then
                destinations[dests_amount]["name"] = destinations[dests_amount]["name"] .. string.char(code)
            end
            API.centerLabel(destinations[dests_amount]["name"], secondaryScreenRes[2]/2)
            API.centerLabel("Press enter when finished", secondaryScreenRes[2]/2 + 2)
        end
    else
        API.centerLabel("UIDs always contain 9 glyphs!",  h/2 + h/4 + 2)
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
    API.centerLabel("UID: "..destinations[dests_amount]["uid"], h/2 + h/4)
end

init()
term.setCursorBlink(false)
--API.customize(0xffffff, 0x333333, 0x4cc0ff, 0x000000)
API.clear()
API.fillTable()

while true do
    getClick()
end