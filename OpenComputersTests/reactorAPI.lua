local component = require("component")
local sides = require("sides")

-------------------------------
--   Abstract reactor class  --
-------------------------------

AbstractReactor = {}
AbstractReactor.__index = AbstractReactor

function AbstractReactor:create(name, cmpnt, addr)
    local instance = setmetatable({}, self)
    instance.name = name
    instance.component = cmpnt
    instance.address = addr
    instance.auto = false
    instance.lowThreshold = 50
    instance.highThreshold = 60
    return instance
end

function AbstractReactor:getAuto()
    return self.auto
end

function AbstractReactor:getLowThreshold()
    return self.lowThreshold
end

function AbstractReactor:getHighThreshold()
    return self.highThreshold
end

function AbstractReactor:setLowThreshold(t)
    self.lowThreshold = t
end

function AbstractReactor:setHighThreshold(t)
    self.highThreshold = t
end

function AbstractReactor:setAuto(activate)
    self.auto = activate
end

function AbstractReactor:autoHandling()
end

function AbstractReactor:writeMethods()
    local file = io.open("ReactorMethods/"..self.name.."_methods.txt", "w")
    file:write("Reactor: "..self.name.."\n\n")
    file:write("Methods:\n\n")
    for method,_ in pairs(component.methods(self.address)) do
        file:write(method..'\n')
    end
    file:close()
end

-------------------------------
--     Extreme Reactors      --
-------------------------------

br_reactor = {}
br_reactor.__index = br_reactor
setmetatable(br_reactor, AbstractReactor)

function br_reactor:getActive()
    return self.component.getActive()
end

function br_reactor:setActive(activate)
    self.component.setActive(activate)
end

function br_reactor:getCurrentEnOutput()
    return math.floor(self.component.getEnergyProducedLastTick()*100)/100, "RF/t"
end

function br_reactor:getStoredEnergy()
    return self.component.getEnergyStored()
end

function br_reactor:autoHandling()
    if self.auto then
        local storedEn = (self:getStoredEnergy()/self.component.getEnergyCapacity())*100
        if storedEn < self.lowThreshold then
            self:setActive(true)
        elseif storedEn >= self.highThreshold then
            self:setActive(false)
        end
    end
end

-------------------------------
--       NuclearCraft        --
-------------------------------

nc_fission_reactor = {}
nc_fission_reactor.__index = nc_fission_reactor
setmetatable(nc_fission_reactor, AbstractReactor)

function nc_fission_reactor:getActive()
    return self.component.isProcessing()
end

function nc_fission_reactor:setActive(activate)
    if activate then
        self.component.activate()
        return
    end
    self.component.deactivate()
end

function nc_fission_reactor:getCurrentEnOutput()
    return self.component.getReactorProcessPower(), "RF/t"
end

function nc_fission_reactor:getStoredEnergy()
    return self.component.getEnergyStored()
end

function nc_fission_reactor:getHeat()
    return self.component.getHeatLevel()
end

function nc_fission_reactor:autoHandling()
    if self.auto then
        local storedEn = (self:getStoredEnergy()/self.component.getMaxEnergyStored())*100
        local heat = (self:getHeat()/self.component.getMaxHeatLevel())*100
        if (heat < self.lowThreshold) and (storedEn < self.lowThreshold) then
            self:setActive(true)
        elseif (heat >= self.highThreshold) or (storedEn >= self.highThreshold) then
            self:setActive(false)
        end
    end
end

---------------------------------------------------------------------------

nc_fusion_reactor = {}
nc_fusion_reactor.__index = nc_fusion_reactor
setmetatable(nc_fusion_reactor, nc_fission_reactor)

-------------------------------
--     IndustrialCraft2      --
-------------------------------

reactor = {}
reactor.__index = reactor
setmetatable(reactor, AbstractReactor)

function reactor:getActive()
    return self.component.producesEnergy()
end

function reactor:setActive(activate)
    if activate then
        component.redstone.setOutput(sides.north, 15)
        return
    end
    component.redstone.setOutput(sides.north, 0)
end

function reactor:getCurrentEnOutput()
    return self.component.getReactorEUOutput(), "EU/t"
end

function reactor:autoHandling()
    if self.auto then
        local heat = self.component.getHeat()
        if heat < self.lowThreshold*100 then
            self:setActive(true)
        elseif heat >= self.highThreshold*100 then
            self:setActive(false)
        end
    end
end

-------------------------------
--         Mekanism          --
-------------------------------

reactor_logic_adapter = {}
reactor_logic_adapter.__index = reactor_logic_adapter
setmetatable(reactor_logic_adapter, AbstractReactor)

function reactor_logic_adapter:getActive()
    return self.component.isIgnited()
end

function reactor_logic_adapter:setActive(activate)
    if activate then
        component.redstone.setOutput(sides.south, 15)
        return
    end
    component.redstone.setOutput(sides.south, 0)
end

function reactor_logic_adapter:getCurrentEnOutput()
    return self.component.getProducing(), "J/t"
end