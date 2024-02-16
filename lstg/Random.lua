math.randomseed(os.time())

---@class Lstg.Random
ran = {}

---Get Random Integer between a and b (Including a and b)
---@param a number
---@param b number
---@return integer
function ran:Int(a, b)
    return math.random(a, b)
end

---Get Random Floating Number between a and b
---@param a number
---@param b number
---@return number
function ran:Float(a, b)
    return math.random() * (b - a) + a
end

---Get Random 1 or -1
---@return integer
function ran:Sign()
    -- rand(1,2)==1 ? 1 : -1
    return math.random(2) == 1 and 1 or -1
end
