local component = require("component")
local fs = require("filesystem")
require("reactorAPI")

local gpu = component.gpu
local reactors = {}
local enStringLen = 0
local unitStringLen = 0
local statusStringLen = 0

function findReactors()
    for k, v in pairs(component.list()) do
        if string.find(v, "reactor") ~= nil then
            if v == "br_reactor" then
                table.insert(reactors, br_reactor:create(v, component.proxy(k), k))
            elseif v == "nc_fission_reactor" then
                table.insert(reactors, nc_fission_reactor:create(v, component.proxy(k), k))
            elseif v == "nc_fusion_reactor" then
                table.insert(reactors, nc_fusion_reactor:create(v, component.proxy(k), k))
            elseif v == "reactor" or v == "reactor_chamber" then
                table.insert(reactors, reactor:create(v, component.proxy(k), k))
            elseif v == "reactor_logic_adapter" then
                table.insert(reactors, reactor_logic_adapter:create(v, component.proxy(k), k))
            end
        end
    end
    return #reactors
end

function currentSetActive(activate)
    reactors[currentReactor]:setActive(activate)
end

function currentSetAuto(activate)
    reactors[currentReactor]:setAuto(activate)
end

function currentGetAuto()
    return reactors[currentReactor]:getAuto()
end

function turnAllOff()
    for _, reactor in pairs(reactors) do
        reactor:setAuto(false)
        reactor:setActive(false)
    end
end

function switchState()
    gpu.setBackground(0x000000)
    local state = reactors[currentReactor]:getActive()
    if state then
        reactors[currentReactor]:setActive(false)
        return not state
    end
    reactors[currentReactor]:setActive(true)
    return not state
end

function subThreshold(num)
    local threshold = 0
    if not thresholdBool then
        threshold = reactors[currentReactor]:getLowThreshold()
        if threshold - num >= 0 then
            threshold = threshold - num
            reactors[currentReactor]:setLowThreshold(threshold)
        end
        return
    end
    threshold = reactors[currentReactor]:getHighThreshold()
    if threshold - num >= 0 then
        threshold = threshold - num
        reactors[currentReactor]:setHighThreshold(threshold)
    end
end

function addThreshold(num)
    local threshold = 0
    if not thresholdBool then
        threshold = reactors[currentReactor]:getLowThreshold()
        if threshold + num <= 100 then
            threshold = threshold + num
            reactors[currentReactor]:setLowThreshold(threshold)
        end
        return
    end
    threshold = reactors[currentReactor]:getHighThreshold()
    if threshold + num <= 100 then
        threshold = threshold + num
        reactors[currentReactor]:setHighThreshold(threshold)
    end
end

function txtReactorMethods()
    fs.makeDirectory("/OpenComputersTests/ReactorMethods")
    for k,v in pairs(reactors) do
        v:writeMethods()
    end
end

function printReactorStats()
    local status = "online"
    local en, unit = reactors[currentReactor]:getCurrentEnOutput()
    gpu.setBackground(0x000000)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(2, 2, enStringLen + unitStringLen + 1, 1, " ")
    gpu.set(2, 2, en.." "..unit)
    enStringLen = string.len(en)
    unitStringLen = string.len(unit)

    if reactors[currentReactor]:getActive() then
        gpu.setBackground(0x000000)
        gpu.set(1, 1, "Status: ")
        gpu.setForeground(0x00FF00)
        gpu.fill(9, 1, statusStringLen, 1, " ")
        gpu.set(9, 1, status)
        statusStringLen = string.len(status)
        return
    end
    status = "offline"
    gpu.setBackground(0x000000)
    gpu.set(1, 1, "Status: ")
    gpu.setForeground(0xFF0000)
    gpu.fill(9, 1, statusStringLen, 1, " ")
    gpu.set(9, 1, "offline")
    statusStringLen = string.len(status)
end

function autoReactors()
    for _, rctr in pairs(reactors) do
        rctr:autoHandling()
    end
end