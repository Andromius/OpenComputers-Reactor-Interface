local component = require("component")
local gpu = component.gpu

Button = {}
Button.__index = Button

function Button.create(name, x, y, w, h, c)
    local instance = setmetatable({}, Button)
    instance.name = name
    instance.xPos = math.floor(x)
    instance.yPos = math.floor(y)
    instance.width = math.floor(w)
    instance.height = math.floor(h)
    instance.text = ""
    instance.vertText = false
    instance.color = c
    instance.textColor = 0xFFFFFF
    instance.rendered = true
    return instance
end

function Button:getName()
    return self.name
end

function Button:getPos()
    return self.xPos, self.yPos
end

function Button:getDim()
    return self.width, self.height
end

function Button:getColor()
    return self.color
end

function Button:getTextColor()
    return self.textColor
end

function Button:getRendered()
    return self.rendered
end

function Button:setPos(x, y)
    self.xPos = x
    self.yPos = y
end

function Button:setDim(w, h)
    self.width = w
    self.height = h
end

function Button:setText(string)
    self.text = string
end

function Button:setVertText(vt)
    self.vertText = vt
end

function Button:setColor(c)
    self.color = c
end

function Button:setTextColor(c)
    self.textColor = c
end

function Button:setRendered(r)
    self.rendered = r
end

function Button:draw()
    gpu.setBackground(self.color)
    gpu.setForeground(self.textColor)
    gpu.fill(self.xPos, self.yPos, self.width, self.height, " ")
    if self.vertText then
        gpu.set(self.xPos + math.floor(self.width/2),
                self.yPos + self.height/2 - string.len(self.text)/2,
                self.text, self.vertText)
        return
    end
    gpu.set(self.xPos + self.width/2 - string.len(self.text)/2,
    self.yPos + math.floor(self.height/2),
    self.text, self.vertText)
end