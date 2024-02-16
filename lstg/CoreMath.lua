---@diagnostic disable: lowercase-global

int = math.floor
abs = math.abs
max = math.max
min = math.min
sqrt = math.sqrt

PI = math.pi
PIx2 = PI * 2
PI_2 = PI / 2
PI_4 = PI / 4
SQRT2 = sqrt(2)
SQRT3 = sqrt(3)
SQRT2_2 = sqrt(0.5)

---@param x number # degree
---@return number
function sin(x)
    return math.sin(math.rad(x))
end

---@param x number # degree
---@return number
function cos(x)
    return math.cos(math.rad(x))
end

---@param x number # degree
---@return number
function tan(x)
    return math.tan(math.rad(x))
end

---@param x number
---@return number # degree
function asin(x)
    return math.deg(math.asin(x))
end

---@param x number
---@return number # degree
function acos(x)
    return math.deg(math.acos(x))
end

---@param x number
---@return number # degree
function atan(x)
    return math.deg(math.atan(x))
end

---@param y number
---@param x number
---@return number # degree
function atan2(y, x)
    return math.deg(math.atan2(y, x))
end

---Get Module of Vector(x, y)
---@param x number
---@param y number
---@return number
function hypot(x, y)
    return math.sqrt(x * x + y * y)
end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@return number
function Dist(x1, y1, x2, y2)
    return hypot(x2 - x1, y2 - y1)
end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@return number # degree
function Angle(x1, y1, x2, y2)
    return atan2(y2 - y1, x2 - x1)
end
