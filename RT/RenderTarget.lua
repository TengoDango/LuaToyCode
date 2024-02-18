-- metatable
local RTClass = {}
RTClass.__index = RTClass

-- Color(255, 255, 255, 255)
local white = Color(255, 255, 255, 255)

----------------------------------------

---@param name string
---@return DGlib.RenderTarget
---@diagnostic disable-next-line: duplicate-set-field
function DG.RenderTarget(name)
    local data = {
        name = name,
        blend = "",
        -- RenderTexture table
        rt = {
            { 0, 0, 0.5, 0, 0, white },
            { 0, 0, 0.5, 0, 0, white },
            { 0, 0, 0.5, 0, 0, white },
            { 0, 0, 0.5, 0, 0, white },
        },
        -- vertex (x,y)
        vx = { 0, 0, 0, 0 },
        vy = { 0, 0, 0, 0 },
        -- setmode xy-obj
        x = 0,
        y = 0,
        u = 0,
        v = 0,
        rot = 0,
        hscale = 1,
        vscale = 1,
        scale0 = screen.scale,
        -- state
        setcenter = false,
        setxyobj = false,
        setxy = false,
        setuv = false,
        viewmode = "",
    }
    ---@class DGlib.RenderTarget
    local self = { _data = data }
    return setmetatable(self, RTClass)
end

local function DeepCopy(self)
    if type(self) ~= "table" then
        return self
    end
    local other = {}
    for key, value in pairs(self) do
        other[key] = DeepCopy(value)
    end
    return other
end

---@param self DGlib.RenderTarget
---@return DGlib.RenderTarget
function RTClass.copy(self)
    return setmetatable({
        _data = DeepCopy(self._data)
    }, RTClass)
end

----------------------------------------

local function WorldToUI(x, y)
    local w = lstg.world
    return
        w.scrl + (w.scrr - w.scrl) * (x - w.l) / (w.r - w.l),
        w.scrb + (w.scrt - w.scrb) * (y - w.b) / (w.t - w.b)
end

local function UIToWorld(x, y)
    local w = lstg.world
    return
        w.l + (w.r - w.l) * (x - w.scrl) / (w.scrr - w.scrl),
        w.b + (w.t - w.b) * (y - w.scrb) / (w.scrt - w.scrb)
end

local function UIToUV(x, y)
    return
        screen.dx + screen.scale * x,
        screen.dy + screen.scale * (screen.height - y)
end

local function UVToUI(x, y)
    return
        (x - screen.dx) / screen.scale,
        screen.height - (y - screen.dy) / screen.scale
end

local function transToUI(x, y, from)
    if from == "world" then
        return WorldToUI(x, y)
    elseif from == "uv" then
        return UVToUI(x, y)
    else
        return x, y
    end
end

local function transFromUI(x, y, to)
    if to == "world" then
        return UIToWorld(x, y)
    elseif to == "uv" then
        return UIToUV(x, y)
    else
        return x, y
    end
end

local function Trans(x, y, from, to)
    if from == to or from == "" then return x, y end
    x, y = transToUI(x, y, from)
    x, y = transFromUI(x, y, to)
    return x, y
end

----------------------------------------

---@param self DGlib.RenderTarget
---@return DGlib.RenderTarget
function RTClass.push(self)
    PushRenderTarget(self._data.name)
    return self
end

---@param self DGlib.RenderTarget
---@return DGlib.RenderTarget
function RTClass.pop(self)
    PopRenderTarget()
    return self
end

---@param self DGlib.RenderTarget
---@return DGlib.RenderTarget
function RTClass.texture(self, name)
    self._data.name = name
    return self
end

---@param self DGlib.RenderTarget
---@return DGlib.RenderTarget
function RTClass.blend(self, blend)
    self._data.blend = blend or ""
    return self
end

---@param self DGlib.RenderTarget
---@return DGlib.RenderTarget
function RTClass.color(self, c1, c2, c3, c4)
    local rt = self._data.rt
    if c1 and c2 then
        rt[1][6] = c1
        rt[2][6] = c2
        rt[3][6] = c3
        rt[4][6] = c4
    else
        for i = 1, 4 do
            rt[i][6] = c1 or white
        end
    end
    return self
end

----------------------------------------

local function Rotate(x, y, a)
    return
        x * cos(a) - y * sin(a),
        x * sin(a) + y * cos(a)
end

---Set vertex (x,y,z), general method
---@param self DGlib.RenderTarget
local function SetXYZ(self, viewmode, setxyobj, ...)
    local data = self._data
    local rt = data.rt
    local pos = { ... }

    data.setxy = true
    data.setxyobj = setxyobj
    data.viewmode = viewmode

    if setxyobj then
        for i = 1, 4 do rt[i][3] = 0.5 end
    else
        for i = 1, 4 do
            data.vx[i], data.vy[i], rt[i][3]
            = pos[i * 3 - 2], pos[i * 3 - 1], pos[i * 3]
        end
    end
end

---@param self DGlib.RenderTarget
---@return DGlib.RenderTarget
function RTClass.xy(self, viewmode, x, y, rot, hscale, vscale)
    if not viewmode then
        self._data.setxy = false
        return self
    end

    SetXYZ(self, viewmode, true)

    local data = self._data
    data.x, data.y = x, y
    data.rot = rot or 0
    data.hscale = hscale or 1
    data.vscale = vscale or data.hscale

    return self
end

---@param self DGlib.RenderTarget
---@return DGlib.RenderTarget
function RTClass.xyrect(self, viewmode, left, right, bottom, top, rot)
    if not rot then
        SetXYZ(self, viewmode, false,
            left, top, 0.5,
            right, top, 0.5,
            right, bottom, 0.5,
            left, bottom, 0.5)
    else
        local x, y = (left + right) / 2, (bottom + top) / 2
        local dx1, dy1 = Rotate(left - x, top - y, rot)
        local dx2, dy2 = Rotate(right - x, top - y, rot)
        SetXYZ(
            self, viewmode, false,
            x + dx1, y + dy1, 0.5,
            x + dx2, y + dy2, 0.5,
            x - dx1, y - dy1, 0.5,
            x - dx2, y - dy2, 0.5
        )
    end
    return self
end

---@param self DGlib.RenderTarget
---@return DGlib.RenderTarget
function RTClass.xy4v(self, viewmode, x1, y1, x2, y2, x3, y3, x4, y4)
    SetXYZ(
        self, viewmode, false,
        x1, y1, 0.5,
        x2, y2, 0.5,
        x3, y3, 0.5,
        x4, y4, 0.5
    )
    return self
end

---@param self DGlib.RenderTarget
---@return DGlib.RenderTarget
function RTClass.xyz(self, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
    SetXYZ(
        self, "", false,
        x1, y1, z1,
        x2, y2, z2,
        x3, y3, z3,
        x4, y4, z4
    )
    return self
end

----------------------------------------

---@param self DGlib.RenderTarget
local function SetUV(self, viewmode, ...)
    local data = self._data
    local rt = data.rt
    local pos = { ... }
    data.setuv = true

    for i = 1, 4 do
        rt[i][4], rt[i][5] = Trans(
            pos[i * 2 - 1], pos[i * 2], viewmode, "uv"
        )
    end
end

---@param self DGlib.RenderTarget
---@return DGlib.RenderTarget
function RTClass.uv(self, viewmode, u, v, rot, a, b)
    if not viewmode then
        self._data.setuv = false
        return self
    end

    rot = rot or 0
    b = b or a

    local du1, dv1 = Rotate(-a, b, rot)
    local du2, dv2 = Rotate(a, b, rot)

    SetUV(
        self, viewmode,
        u + du1, v + dv1,
        u + du2, v + dv2,
        u - du1, v - dv1,
        u - du2, v - dv2
    )

    return self
end

---@param self DGlib.RenderTarget
---@return DGlib.RenderTarget
function RTClass.uvrect(self, viewmode, left, right, bottom, top, rot)
    if rot then
        RTClass.uv(
            self, viewmode,
            (left + right) / 2, (bottom + top) / 2, rot,
            (right - left) / 2, (top - bottom) / 2
        )
    else
        SetUV(
            self, viewmode,
            left, top,
            right, top,
            right, bottom,
            left, bottom
        )
    end
    return self
end

---@param self DGlib.RenderTarget
---@return DGlib.RenderTarget
function RTClass.uv4v(self, viewmode, u1, v1, u2, v2, u3, v3, u4, v4)
    SetUV(self, viewmode, u1, v1, u2, v2, u3, v3, u4, v4)
    return self
end

---@param self DGlib.RenderTarget
---@return DGlib.RenderTarget
function RTClass.center(self, viewmode, u, v)
    if not viewmode then
        self._data.setcenter = false
        return self
    end

    local data = self._data
    data.setcenter = true
    data.u, data.v = Trans(u, v, viewmode, "uv")
    return self
end

----------------------------------------

---@param self DGlib.RenderTarget
local function SetXYModeObj(self)
    local data = self._data
    local rt = data.rt

    local u, v = {}, {}
    for i = 1, 4 do
        u[i], v[i] = rt[i][4], rt[i][5]
    end
    if not data.setcenter then
        data.u = (u[1] + u[2] + u[3] + u[4]) / 4
        data.v = (v[1] + v[2] + v[3] + v[4]) / 4
    end

    for i = 1, 4 do
        u[i] = u[i] - data.u
        v[i] = data.v - v[i]
        u[i], v[i] = Rotate(
            u[i] * data.hscale / data.scale0,
            v[i] * data.vscale / data.scale0,
            data.rot
        )
        data.vx[i] = data.x + u[i]
        data.vy[i] = data.y + v[i]
    end
end

---@param self DGlib.RenderTarget
---@return DGlib.RenderTarget
function RTClass.render(self)
    local data = self._data
    local rt = data.rt

    -- default vertex (u,v)
    if not data.setuv then
        self:uvrect("ui", 0, screen.width, 0, screen.height)
    end

    -- default vertex (x,y)
    if not data.setxy then
        data.setxyobj = false
        data.viewmode = ""
        for i = 1, 4 do
            data.vx[i], data.vy[i] = Trans(
                rt[i][4], rt[i][5],
                "uv", lstg.viewmode
            )
        end
    end

    -- setmode xy-obj
    if data.setxyobj then
        SetXYModeObj(self)
    end

    -- vertex (x,y) to render (x,y)
    for i = 1, 4 do
        rt[i][1], rt[i][2] = Trans(
            data.vx[i], data.vy[i],
            data.viewmode, lstg.viewmode
        )
    end

    -- render
    RenderTexture(data.name, data.blend, unpack(rt))

    return self
end
