--[[
    To do:   
        a) complete reactorAPI: automatic handling for Mekanism, Extrene Reactors, NuclearCraft
        b) Graphs: for energy stored, for energy production per tick
--]]

local eventHandler = require("eventHandler")
local term = require("term")
local event = require("event")
local component = require("component")
local buttons = require("buttons")
local reactors = require("reactors")

local gpu = component.gpu
local screen = component.screen
local TheAllMightyMagicNumber = 1.55
local TheAllMightyMagicNumber2 = 0.55 --Don't ask

bw, bh = screen.getAspectRatio() --bw:block width; bh:block height
mw, mh = gpu.maxResolution() --mw:max screen width; mh:max screen height

local scaleW = math.ceil((mw/(bw+bh))*bw)
local scaleH = math.ceil((mh/(bw+bh))*bh)*TheAllMightyMagicNumber
vertical = false
if bh > bw then
    vertical = true
    scaleW = math.ceil((mw/(bw+bh))*bw)*TheAllMightyMagicNumber2
    scaleH = math.ceil((mh/(bw+bh))*bh)
end

gpu.setResolution(scaleW,scaleH)
rw, rh = gpu.getResolution() --rw: real screen width, rh: real screen height

exit = false
currentReactor = 1
numReactors = findReactors()
createButtons()

-- txtReactorMethods() --uncomment if you want a .txt file of methods for all currently connected reactors

screen.setTouchModeInverted(true)
term.clear()

while not exit do
    handleEvent(event.pull(0.05))
    autoReactors()
    updateColors()
    drawButtons()
    printReactorStats()
end

screen.setTouchModeInverted(false)
gpu.setResolution(mw,mh)
gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF)
term.clear()
