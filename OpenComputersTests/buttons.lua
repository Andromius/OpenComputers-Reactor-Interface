local button = require("buttonAPI")
local reactors = require("reactors")

local allButtons = {}
local buttons = {}
local buttonsPanel = {}

local showPanel = false
local thresholdBool = false

local function hideButton(button)
    local defaultColor = button:getColor()
    local defaultTextColor = button:getTextColor()

    button:setColor(0x000000)
    button:setTextColor(0x000000)
    button:draw()

    button:setColor(defaultColor)
    button:setTextColor(defaultTextColor)
end

function togglePanel()
    for _, j in pairs(buttonsPanel) do
        j:setRendered(showPanel)
        if not showPanel then
            hideButton(j)
        end
    end
end

local function unknownBut()
end

local but = setmetatable({}, {__index = function() return unknownBut end})

function but.Exit()
    turnAllOff()
    exit = true
end

function but.Panel()
    if not showPanel then
        showPanel = true
        togglePanel()
        return
    end
    showPanel = false
    togglePanel()
end

function but.Next()
    if currentReactor + 1 > numReactors then
        currentReactor = 1
        return
    end
    currentReactor = currentReactor + 1
end

function but.Previous()
    if currentReactor - 1 < 1 then
        currentReactor = 6
        return
    end
    currentReactor = currentReactor - 1
end

function but.Threshold()
    if not thresholdBool then
        thresholdBool = true
        buttonsPanel[1]:setText("THRS_HI")
        return
    end
    thresholdBool = false
    buttonsPanel[1]:setText("THRS_LO")
end

function but.Add1()
    addThreshold(1)
end

function but.Add5()
    addThreshold(5)
end

function but.Add10()
    addThreshold(10)
end

function but.Sub1()
    subThreshold(1)
end

function but.Sub5()
    subThreshold(5)
end

function but.Sub10()
    subThreshold(10)
end

function but.Control()
    switchState()
end

function but.Auto()
    local status = currentGetAuto()
    if status then
        currentSetAuto(false)
        currentSetActive(false)
        return
    end
    currentSetAuto(true)
end

local function blink(button)
    local time = 0.05
    local t0 = os.clock()
    local defaultColor = button:getColor()
    
    button:setColor(0xFFFFFF)
    button:draw()
    while os.clock() - t0 <= time do --Waits for "time" seconds
    end
    button:setColor(defaultColor)
    button:draw()
end

function checkButton(xCoord, yCoord)
    for _, table in pairs(allButtons) do
        for _, button in pairs(table) do
            local width, height = button:getDim()
            local posX, posY = button:getPos()

            if xCoord >= posX and xCoord < (posX + width) and yCoord >= posY and yCoord < (posY + height) then      
                if not button:getRendered() then
                    return
                end
                blink(button)
                but[button:getName()]()
            end
        end
    end
end

function updateColors()
    if currentGetAuto() then
        buttons[6]:setColor(0x0000FF)
        return
    end
    buttons[6]:setColor(0x000055)
end

function drawButtons()
    for i, x in pairs(allButtons) do
        for _, button in pairs(x) do
            if button:getRendered() then
                button:draw()
            end
        end
    end
end

function createButtons()
    buttons = {
        Button.create("Exit", rw - 5, 1, 6, 1, 0xFF0000),
        Button.create("Panel", rw - rw/10, rh - rh/3, rw/10, rh/8, 0x551A8B),
        Button.create("Next", rw - rw/20, rh - rh/6, rw/20, rh/16, 0x1F00FF),
        Button.create("Previous", rw - rw/10, rh - rh/6, rw/20, rh/16, 0x1F00FF),
        Button.create("Control", rw - rw/10, rh - rh/2, rw/10, rh/8, 0xFF0000),
        Button.create("Auto", rw - rw/10, rh/3, rw/10, rh/8, 0x000055)
    }

    buttonsPanel = {
        Button.create("Threshold", rw/8, rh/4, rw/10, rh/8, 0x0000FF),
        Button.create("Add1", rw/4 + rw/10, rh/4, rw/10, rh/8, 0x0000FF),
        Button.create("Add5", rw/4 + rw/10, rh/4 + math.ceil(rh/8), rw/10, rh/8, 0x0000FF),
        Button.create("Add10", rw/4 + rw/10, rh/4 + math.ceil(2*(rh/8)), rw/10, rh/8, 0x0000FF),
        Button.create("Sub1", rw/4, rh/4, rw/10, rh/8, 0x0000FF),
        Button.create("Sub5", rw/4, rh/4 + math.ceil(rh/8), rw/10, rh/8, 0x0000FF),
        Button.create("Sub10", rw/4, rh/4 + math.ceil(2*(rh/8)), rw/10, rh/8, 0x0000FF)
    }

    buttons[1]:setText("EXIT")
    buttons[2]:setText("PANEL")
    buttons[3]:setText(">>>")
    buttons[4]:setText("<<<")
    buttons[5]:setText("ON/OFF")
    buttons[6]:setText("AUTO")

    buttonsPanel[1]:setText("THRS_LO")
    buttonsPanel[2]:setText("+1")
    buttonsPanel[3]:setText("+5")
    buttonsPanel[4]:setText("+10")
    buttonsPanel[5]:setText("-1")
    buttonsPanel[6]:setText("-5")
    buttonsPanel[7]:setText("-10")

    for i, btn in pairs(buttons) do
        if i ~= 1 then
            btn:setVertText(vertical)
        end
    end
    
    for _, btn in pairs(buttonsPanel) do
        btn:setRendered(false)
        btn:setVertText(vertical)
    end

    allButtons = {buttons, buttonsPanel}
end
