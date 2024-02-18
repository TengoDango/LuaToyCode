---@param x number
---@param y number
---@return number x
---@return number y
function DG.WorldToUI(x, y)
    local w = lstg.world
    return
        w.scrl + (w.scrr - w.scrl) * (x - w.l) / (w.r - w.l),
        w.scrb + (w.scrt - w.scrb) * (y - w.b) / (w.t - w.b)
end

---@param x number
---@param y number
---@return number x
---@return number y
function DG.UIToWorld(x, y)
    local w = lstg.world
    return
        w.l + (w.r - w.l) * (x - w.scrl) / (w.scrr - w.scrl),
        w.b + (w.t - w.b) * (y - w.scrb) / (w.scrt - w.scrb)
end

---@param x number
---@param y number
---@return number x
---@return number y
function DG.UIToUV(x, y)
    return
        screen.dx + screen.scale * x,
        screen.dy + screen.scale * (screen.height - y)
end

---@param x number
---@param y number
---@return number x
---@return number y
function DG.UVToUI(x, y)
    return
        (x - screen.dx) / screen.scale,
        screen.height - (y - screen.dy) / screen.scale
end

---ViewMode for RenderTarget
---@param width number # Width of RenderTarget
---@param height number # Height of RenderTarget
function DG.SetViewModeUV(width, height)
    local l, r, b, t
    l, t = DG.UVToUI(0, 0)
    r, b = DG.UVToUI(width, height)
    ---@diagnostic disable-next-line: undefined-global
    SetRenderRect(0, width, 0, height, l, r, b, t)
end

local function sub(u, v)
    return { u[1] - v[1], u[2] - v[2], u[3] - v[3] }
end
local function dot(u, v)
    return u[1] * v[1] + u[2] * v[2] + u[3] * v[3]
end
local function cross(u, v)
    return {
        u[2] * v[3] - u[3] * v[2],
        u[3] * v[1] - u[1] * v[3],
        u[1] * v[2] - u[2] * v[1],
    }
end
local function unit(v)
    local r = math.sqrt(v[1] * v[1] + v[2] * v[2] + v[3] * v[3])
    v[1] = v[1] / r
    v[2] = v[2] / r
    v[3] = v[3] / r
    return v
end
local function inbound(x, y, z, zn, zf, fovy, aspect)
    return z >= zn and z <= zf and math.abs(x) <= aspect * z * math.tan(fovy) and math.abs(y) <= z * math.tan(fovy)
end

---ViewMode "3d" -> "world"
---@param x number
---@param y number
---@param z number
---@param view Lstg.View3D | nil
---@return number | nil
---@return number | nil
---@return number | nil
function DG.SpaceToWorld(x, y, z, view)
    local w = lstg.world
    view = view or lstg.view3d
    local r = sub({ x, y, z }, view.eye)
    local az = unit(sub(view.at, view.eye))
    local ax = unit(cross(view.up, az))
    local ay = cross(az, ax)
    x, y, z = dot(r, ax), dot(r, ay), dot(r, az)
    local zn, zf = view.z[1], view.z[2]
    local aspect = (w.r - w.l) / (w.t - w.b)

    if not inbound(x, y, z, zn, zf, view.fovy, aspect) then
        return
    end

    local cot = 1 / math.tan(view.fovy)
    local X = x * cot / aspect / z
    local Y = y * cot / z
    local Z = (z - zn) * zf / (zf - zn) / z

    local s1, s2 = 448, 522 -- how did this work???
    return X * s1, Y * s2, Z
end
