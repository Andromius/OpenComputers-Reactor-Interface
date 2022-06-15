local event = require("event")
local buttons = require("buttons")
local component = require("component")
local gpu = component.gpu

function unknownEvent()
end
   
local myEventHandlers = setmetatable({}, { __index = function() return unknownEvent end })

function myEventHandlers.touch(screenAddress, x, y, button, playerName)
    checkButton(x, y)
end

function handleEvent(eventID, ...)
    if (eventID) then
        myEventHandlers[eventID](...)
    end
end