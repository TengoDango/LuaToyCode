local function quadratic(f, l, r)
    return (r - l) / 6 * (f(l) + f(r) + 4 * f((l + r) / 2))
end

---Integral Using Adaptive Simpson Rule
---@param func fun(x:number):number
---@param left number
---@param right number
---@param maxerror number? # default = 1e-9
---@return number
local function Integral(func, left, right, maxerror)
    maxerror = maxerror or 1e-9

    local mid = (left + right) / 2
    local leftInt = quadratic(func, left, mid)
    local rightInt = quadratic(func, mid, right)
    local allInt = quadratic(func, left, right)
    local error = abs(leftInt + rightInt - allInt) / 15
    if error < maxerror then
        return leftInt + rightInt + error
    else
        return Integral(func, left, mid, maxerror / 2)
            + Integral(func, mid, right, maxerror / 2)
    end
end
DG.Integral = Integral
