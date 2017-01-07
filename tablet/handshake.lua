-- Exchanges uids between 2 computers and saves them for later use on pc
-- Useful for wireless communication
local event = require("event")
local component = require("component")
local term = require("term")

local m = component.modem

print("Enter port (has to be same as the computer you are trying to connect to)")
local port = tonumber(term.read())
m.open(port)

for i = 1, 10 do
    m.broadcast(port, "Hello World!")
    os.sleep(0.5)
end

function handleBC(_, _, remote_addr, _, _)
    print("got msg, writing to file: ", remote_addr)
    local file = io.open("uid","w")
    file:write(remote_addr)
    file:close()
    event.ignore("modem_message")
end

event.listen("modem_message", handleBC)
