---HSV to RGB
---@param H number # 0 - 360
---@param S number # 0 - 1
---@param V number # 0 - 1
---@return integer R # 0 - 255
---@return integer G # 0 - 255
---@return integer B # 0 - 255
function DG.HSVtoRGB(H, S, V)
    H = H % 360
    V = V * 255
    local I = int(H / 60)
    local F = H / 60 - I
    local P = V * (1 - S)
    local Q = V * (1 - F * S)
    local T = V * (1 - (1 - F) * S)

    if I == 0 then
        return V, T, P
    elseif I == 1 then
        return Q, V, P
    elseif I == 2 then
        return P, V, T
    elseif I == 3 then
        return P, Q, V
    elseif I == 4 then
        return T, P, V
    else -- if I == 5 then
        return V, P, Q
    end
end

---RGB to HSV
---@param R integer # 0 - 255
---@param G integer # 0 - 255
---@param B integer # 0 - 255
---@return number H # 0 - 360
---@return number S # 0 - 1
---@return number v # 0 - 1
function DG.RGBtoHSV(R, G, B)
    local H, S, V
    local Cmax = max(R, G, B)
    local Cmin = min(R, G, B)
    local D = Cmax - Cmin

    if D == 0 then
        H = 0
    elseif Cmax == R then
        H = 60 * ((G - B) / D + 0)
    elseif Cmax == G then
        H = 60 * ((B - R) / D + 2)
    elseif Cmax == B then
        H = 60 * ((R - G) / D + 4)
    end

    if Cmax == 0 then
        S = 0
    else
        S = D / Cmax
    end

    V = Cmax / 255

    return H, S, V
end
