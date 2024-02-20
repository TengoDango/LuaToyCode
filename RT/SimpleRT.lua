---@diagnostic disable: undefined-global

---定义了一个全局函数 NewRTObject 和一个类 RenderTargetObject
---函数 NewRTObject 生成类的一个实例
---每个实例与一个渲染目标 (render target) 绑定
---实例含有设置渲染参数和执行渲染操作的方法, 这些方法均会返回原实例 (copy 除外)
---渲染参数包括: 混合模式, 顶点颜色, 顶点渲染坐标(x,y,z), 顶点纹理坐标(u,v) 等

------------------------------------------------------------
--#region 基本定义

---@alias RTObject.ViewMode
---| "world" # world 坐标系
---| "ui"    # ui 坐标系
---| "uv"    # 纹理坐标系
---| ""      # 依赖于所在环境, 一般不使用

---@class RenderTargetObject
local rtobject = {}
rtobject.__index = rtobject

---记录局部函数和变量
local private = {}
---记录原型方法
local proto = {}
---记录扩展方法, 扩展方法使用键值表作为参数
local extend = {}
---记录类型检查函数
local check = {}

--#endregion
------------------------------------------------------------
--#region 全局函数和类方法 (API)

---生成 RenderTargetObject 的一个实例
---@param name string # 要绑定的渲染目标 (render target)
---@return RenderTargetObject rtobject
function NewRTObject(name)
    --// 检查参数
    check.assert("NewRTObject()", "string", false, "name", name)

    --// 初始数据
    local data = {
        ---render target
        name = name,
        ---blend mode
        blend = "",
        -- RenderTexture table
        rt = {
            { 0, 0, 0.5, 0, 0, private.white },
            { 0, 0, 0.5, 0, 0, private.white },
            { 0, 0, 0.5, 0, 0, private.white },
            { 0, 0, 0.5, 0, 0, private.white },
        },
        ---vertex x
        vx = { 0, 0, 0, 0 },
        ---vertex y
        vy = { 0, 0, 0, 0 },

        x = 0,
        y = 0,
        u = 0,
        v = 0,
        rot = 0,
        hscale = 1,
        vscale = 1,
        scale0 = screen.scale,

        ---state: center is set
        setcenter = false,
        ---state: setmode XY-Render()
        setxyobj = false,
        ---state: vertex (x,y) is set
        setxy = false,
        ---state: vertex (u,v) is set
        setuv = false,
        ---viewmode of vertex (x,y)
        viewmode = "",
    }

    ---@class RenderTargetObject
    local self = { _data = data }
    return setmetatable(self, rtobject)
end

---复制一个实例
---@return RenderTargetObject other
function rtobject:copy()
    return setmetatable({
        _data = private.deepcopy(self._data)
    }, rtobject)
end

---对绑定的渲染目标执行 Push 操作
---@return RenderTargetObject self
function rtobject:push()
    PushRenderTarget(self._data.name)
    return self
end

---对绑定的渲染目标执行 Pop 操作
---@return RenderTargetObject self
function rtobject:pop()
    PopRenderTarget()
    return self
end

---执行渲染
---@return RenderTargetObject self
function rtobject:render()
    local data = self._data
    local rt = data.rt

    -- default vertex (u,v)
    if not data.setuv then
        proto.uvrect(self, "ui", 0, screen.width, 0, screen.height)
    end

    -- default vertex (x,y)
    if not data.setxy then
        for i = 1, 4 do
            data.vx[i], data.vy[i] = private.trans(
                rt[i][4], rt[i][5],
                "uv", lstg.viewmode
            )
        end
    end

    -- setmode xy-obj
    if data.setxyobj then
        private.xyobj(self)
    end

    -- vertex (x,y) to render (x,y)
    for i = 1, 4 do
        rt[i][1], rt[i][2] = private.trans(
            data.vx[i], data.vy[i],
            data.viewmode, lstg.viewmode
        )
    end

    -- render
    RenderTexture(data.name, data.blend, unpack(rt))

    return self
end

---重新设置绑定的渲染目标
---@param name string # 要绑定的渲染目标 (render target)
---@return RenderTargetObject self
function rtobject:texture(name)
    --// 检查参数
    check.assert("rtobject:texture()", "string", false, "name", name)

    self._data.name = name
    return self
end

---设置混合模式
---@param blend lstg.BlendMode? # 默认为 ""
---@return RenderTargetObject self
function rtobject:blend(blend)
    --// 检查参数
    check.assert("rtobject:blend()", "blend", true, "blend", blend)

    self._data.blend = blend or ""
    return self
end

---设置顶点颜色
---@overload fun(self):RenderTargetObject # 顶点设为纯白
---@overload fun(self, color:lstg.Color):RenderTargetObject
---@overload fun(self, params:table):RenderTargetObject
---@param color1 lstg.Color
---@param color2 lstg.Color
---@param color3 lstg.Color
---@param color4 lstg.Color
---@return RenderTargetObject self
function rtobject:color(color1, color2, color3, color4)
    --// 扩展方法
    if type(color1) == "table" then return extend.color(self, color1) end

    --// 检查参数
    if color2 or color3 or color4 then
        check.assert("rtobject:color()", "color", false, "color1", color1)
        check.assert("rtobject:color()", "color", false, "color2", color2)
        check.assert("rtobject:color()", "color", false, "color3", color3)
        check.assert("rtobject:color()", "color", false, "color4", color4)
    else
        check.assert("rtobject:color()", "color", true, "color", color1)
    end

    return proto.color(self, color1, color2, color3, color4)
end

---设置顶点 (x,y), 参数模仿 Render() 函数
---@overload fun(self):RenderTargetObject # 取消对 (x,y) 的设置
---@overload fun(self, params:table):RenderTargetObject
---@param viewmode RTObject.ViewMode
---@param x number
---@param y number
---@param rot number? # 默认为 0
---@param hscale number? # 默认为 1
---@param vscale number? # 默认跟随 hscale
---@return RenderTargetObject self
function rtobject:xy(viewmode, x, y, rot, hscale, vscale)
    --// 扩展方法
    if type(viewmode) == "table" then return extend.xy(self, viewmode) end

    --// 抛弃设置
    if not viewmode then return self:xydiscard() end

    --// 检查参数
    check.assert("rtobject:xy()", "viewmode", false, "viewmode", viewmode)
    check.assert("rtobject:xy()", "number", false, "x", x)
    check.assert("rtobject:xy()", "number", false, "y", y)
    check.assert("rtobject:xy()", "number", true, "rot", rot)
    check.assert("rtobject:xy()", "number", true, "hscale", hscale)
    check.assert("rtobject:xy()", "number", true, "vscale", vscale)

    return proto.xy(self, viewmode, x, y, rot, hscale, vscale)
end

---设置顶点 (x,y), 参数仿照 RenderRect() 函数
---@param viewmode RTObject.ViewMode
---@param left number
---@param right number
---@param bottom number
---@param top number
---@param rot number? # 默认为 0
function rtobject:xyrect(viewmode, left, right, bottom, top, rot)
    --// 检查参数
    check.assert("rtobject:xyrect()", "viewmode", false, "viewmode", viewmode)
    check.assert("rtobject:xyrect()", "number", false, "left", left)
    check.assert("rtobject:xyrect()", "number", false, "right", right)
    check.assert("rtobject:xyrect()", "number", false, "bottom", bottom)
    check.assert("rtobject:xyrect()", "number", false, "top", top)
    check.assert("rtobject:xyrect()", "number", true, "rot", rot)

    return proto.xyrect(self, viewmode, left, right, bottom, top, rot)
end

---设置顶点 (x,y), 参数仿照 Render4V() 函数
---@param viewmode RTObject.ViewMode
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param x3 number
---@param y3 number
---@param x4 number
---@param y4 number
---@return RenderTargetObject self
function rtobject:xy4v(viewmode, x1, y1, x2, y2, x3, y3, x4, y4)
    --// 检查参数
    check.assert("rtobject:xy4v()", "viewmode", false, "viewmode", viewmode)
    check.assert("rtobject:xy4v()", "number", false, "x1", x1)
    check.assert("rtobject:xy4v()", "number", false, "y1", y1)
    check.assert("rtobject:xy4v()", "number", false, "x2", x2)
    check.assert("rtobject:xy4v()", "number", false, "y2", y2)
    check.assert("rtobject:xy4v()", "number", false, "x3", x3)
    check.assert("rtobject:xy4v()", "number", false, "y3", y3)
    check.assert("rtobject:xy4v()", "number", false, "x4", x4)
    check.assert("rtobject:xy4v()", "number", false, "y4", y4)

    return proto.xy4v(self, viewmode, x1, y1, x2, y2, x3, y3, x4, y4)
end

---设置顶点 (x,y,z), 参数仿照 Render4V() 函数
---@param x1 number
---@param y1 number
---@param z1 number
---@param x2 number
---@param y2 number
---@param z2 number
---@param x3 number
---@param y3 number
---@param z3 number
---@param x4 number
---@param y4 number
---@param z4 number
---@return RenderTargetObject self
function rtobject:xyz(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
    check.assert("rtobject:xy4v()", "number", false, "x1", x1)
    check.assert("rtobject:xy4v()", "number", false, "y1", y1)
    check.assert("rtobject:xy4v()", "number", false, "z1", z1)
    check.assert("rtobject:xy4v()", "number", false, "x2", x2)
    check.assert("rtobject:xy4v()", "number", false, "y2", y2)
    check.assert("rtobject:xy4v()", "number", false, "z2", z2)
    check.assert("rtobject:xy4v()", "number", false, "x3", x3)
    check.assert("rtobject:xy4v()", "number", false, "y3", y3)
    check.assert("rtobject:xy4v()", "number", false, "z3", z3)
    check.assert("rtobject:xy4v()", "number", false, "x4", x4)
    check.assert("rtobject:xy4v()", "number", false, "y4", y4)
    check.assert("rtobject:xy4v()", "number", false, "z4", z4)

    return proto.xyz(self, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
end

---抛弃对顶点 (x,y) 的设置, 采取默认 (x,y) 策略
---默认为根据顶点纹理坐标 (u,v) 决定渲染位置 (x,y)
---@return RenderTargetObject self
function rtobject:xydiscard()
    local data = self._data
    data.setxy = false
    data.setxyobj = false
    data.viewmode = ""
    return self
end

---设置顶点 (u,v), 参数仿照 Render() 函数
---选取一块矩形区域
---@overload fun(self):RenderTargetObject # 抛弃对 (u,v) 的设置
---@overload fun(self, params:table):RenderTargetObject
---@param viewmode RTObject.ViewMode
---@param u number # 中心点坐标
---@param v number # 中心点坐标
---@param rot number? # 默认为 0
---@param a number # 半宽
---@param b number? # 半高, 默认跟随 a
---@return RenderTargetObject self
function rtobject:uv(viewmode, u, v, rot, a, b)
    --// 扩展方法
    if type(viewmode) == "table" then return extend.uv(self, viewmode) end

    --// 抛弃设置
    if not viewmode then return self:uvdiscard() end

    --// 检查参数
    check.assert("rtobject:uv()", "viewmode", false, "viewmode", viewmode)
    check.assert("rtobject:uv()", "number", false, "u", u)
    check.assert("rtobject:uv()", "number", false, "v", v)
    check.assert("rtobject:uv()", "number", true, "rot", rot)
    check.assert("rtobject:uv()", "number", false, "a", a)
    check.assert("rtobject:uv()", "number", true, "b", b)

    return proto.uv(self, viewmode, u, v, rot, a, b)
end

---设置顶点 (u,v), 参数仿照 RenderRect() 函数
---选取一块矩形区域
---@param viewmode RTObject.ViewMode
---@param left number
---@param right number
---@param bottom number
---@param top number
---@param rot number? # 默认为 0
---@return RenderTargetObject self
function rtobject:uvrect(viewmode, left, right, bottom, top, rot)
    --// 检查参数
    check.assert("rtobject:uvrect()", "viewmode", false, "viewmode", viewmode)
    check.assert("rtobject:uvrect()", "number", false, "left", left)
    check.assert("rtobject:uvrect()", "number", false, "right", right)
    check.assert("rtobject:uvrect()", "number", false, "bottom", bottom)
    check.assert("rtobject:uvrect()", "number", false, "top", top)
    check.assert("rtobject:uvrect()", "number", true, "rot", rot)

    return proto.uvrect(self, viewmode, left, right, bottom, top, rot)
end

---设置顶点 (u,v), 参数仿照 Render4V() 函数
---选取一块四边形区域
---@param viewmode RTObject.ViewMode
---@param u1 number
---@param v1 number
---@param u2 number
---@param v2 number
---@param u3 number
---@param v3 number
---@param u4 number
---@param v4 number
---@return RenderTargetObject self
function rtobject:uv4v(viewmode, u1, v1, u2, v2, u3, v3, u4, v4)
    --//检查参数
    check.assert("rtobject:uv4v()", "viewmode", false, "viewmode", viewmode)
    check.assert("rtobject:uv4v()", "number", false, "u1", u1)
    check.assert("rtobject:uv4v()", "number", false, "v1", v1)
    check.assert("rtobject:uv4v()", "number", false, "u2", u2)
    check.assert("rtobject:uv4v()", "number", false, "v2", v2)
    check.assert("rtobject:uv4v()", "number", false, "u3", u3)
    check.assert("rtobject:uv4v()", "number", false, "v3", v3)
    check.assert("rtobject:uv4v()", "number", false, "u4", u4)
    check.assert("rtobject:uv4v()", "number", false, "v4", v4)

    return proto.uv4v(self, viewmode, u1, v1, u2, v2, u3, v3, u4, v4)
end

---抛弃对顶点 (u,v) 的设置, 采取默认 (u,v) 策略
---选取整个渲染目标
---@return RenderTargetObject self
function rtobject:uvdiscard()
    self._data.setuv = false
    return self
end

---设置纹理中心点, 作用类似 SetImageCenter() 函数
---[不常用]
---@overload fun(self):RenderTargetObject # 取消纹理中心点设置
---@overload fun(self, params:table):RenderTargetObject
---@param viewmode RTObject.ViewMode
---@param u number
---@param v number
function rtobject:center(viewmode, u, v)
    --// 扩展方法
    if type(viewmode) == "table" then return extend.center(self, viewmode) end

    --// 抛弃设置
    if not viewmode then return proto.center(self) end

    --// 检查参数
    check.assert("rtobject:center()", "viewmode", false, "viewmode", viewmode)
    check.assert("rtobject:center()", "number", false, "u", u)
    check.assert("rtobject:center()", "number", false, "v", v)
end

--#endregion
------------------------------------------------------------
--#region 局部函数和变量

private.white = Color(255, 255, 255, 255)

local function Rotate(x, y, a)
    return
        x * cos(a) - y * sin(a),
        x * sin(a) + y * cos(a)
end
private.rotate = Rotate

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
private.deepcopy = DeepCopy

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

---通用坐标转换
---@param x number
---@param y number
---@param from RTObject.ViewMode
---@param to RTObject.ViewMode
---@return number x, number y
local function trans(x, y, from, to)
    if from == to or from == "" or to == "3d" then return x, y end
    x, y = transToUI(x, y, from)
    x, y = transFromUI(x, y, to)
    return x, y
end
private.trans = trans

---通用顶点 (x,y,z) 坐标设置
---@param self RenderTargetObject
---@param viewmode RTObject.ViewMode
---@param setxyobj boolean
---@param ... number
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

    return self
end
private.xyz = SetXYZ

---在 XY-Render() 模式下更新顶点实际坐标 (x,y)
---@param self RenderTargetObject
local function SetXYObj(self)
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
        u[i], v[i] = private.rotate(
            u[i] * data.hscale / data.scale0,
            v[i] * data.vscale / data.scale0,
            data.rot
        )
        data.vx[i] = data.x + u[i]
        data.vy[i] = data.y + v[i]
    end
end
private.xyobj = SetXYObj

local function KeysToString(tab)
    local skey = {}
    for k, _ in pairs(tab) do
        if type(k) == "number" then
            table.insert(skey, "[" .. k .. "]")
        elseif type(k) == "string" then
            table.insert(skey, "'" .. k .. "'")
        else
            table.insert(skey, tostring(k))
        end
    end
    return table.concat(skey, ", ")
end
private.keystostring = KeysToString

--#endregion
------------------------------------------------------------
--#region 类型检查

---@alias RTObject.Type
---| type
---| "color"
---| "blend"
---| "viewmode"

local viewmodeList = {
    ["world"] = true,
    ["ui"] = true,
    ["uv"] = true,
    [""] = true,
}

local blendList = {
    [""] = true,
    ["mul+alpha"] = true,
    ["mul+add"] = true,
    ["mul+rev"] = true,
    ["mul+sub"] = true,
    ["add+alpha"] = true,
    ["add+add"] = true,
    ["add+rev"] = true,
    ["add+sub"] = true,
    ["alpha+bal"] = true,
    ["mul+min"] = true,
    ["mul+max"] = true,
    ["mul+mul"] = true,
    ["mul+screen"] = true,
    ["add+min"] = true,
    ["add+max"] = true,
    ["add+mul"] = true,
    ["add+screen"] = true,
    ["one"] = true,
}

---检查 value 是否匹配 rtype 类型
---不匹配则返回错误信息
---@param rtype RTObject.Type
---@param value any
---@return string? errmsg
function check.type(rtype, value)
    if rtype == "color" then
        if type(value) ~= "userdata" then
            return "invalid color"
        end
    elseif rtype == "blend" then
        if type(value) ~= "string" then
            return ("string expected, got %s"):format(type(value))
        end
        if not blendList[value] then
            return ("invalid blend mode '%s'"):format(value)
        end
    elseif rtype == "viewmode" then
        if type(value) ~= "string" or not viewmodeList[value] then
            if type(value) ~= "string" then
                return ("string expected, got %s"):format(type(value))
            end
            if not viewmodeList[value] then
                return ("invalid viewmode '%s'"):format(value)
            end
        end
    elseif rtype == "table" then
        if type(value) ~= "table" then
            return ("table expected, got %s"):format(type(value))
        end
        if type(value[1]) ~= "number" or type(value[2]) ~= "number"
            or (value[3] and type(value[3]) ~= "number") then
            return ("invalid array")
        end
    elseif type(value) ~= rtype then
        return ("%s expected, got %s"):format(rtype, type(value))
    end
end

---检查类型情况
---@param prefix string
---@param rtype RTObject.Type
---@param allowNil boolean
---@param name string
---@param value any
---@param ... any
---@return any
function check.assert(prefix, rtype, allowNil, name, value, ...)
    local i = 1
    local params = { name, value, ... }
    local match = 0
    while params[i] do
        local errmsg = check.type(rtype, params[i + 1])
        if not errmsg and match == 0 then
            --// 值与类型匹配
            match = i
        elseif not errmsg and match ~= 0 then
            --// 同时存在两个值
            error(("%s: parameter '%s', '%s': duplicated."):format(
                prefix, params[match], params[i]
            ))
        elseif type(params[i + 1]) ~= "nil" then
            --值与类型冲突
            error(("%s: parameter '%s': %s."):format(
                prefix, params[i], errmsg
            ))
        end
        i = i + 2
    end
    if match ~= 0 then
        return params[match + 1]
    elseif allowNil then
        return nil
    else
        --// 没有匹配值
        if rtype == "blend" or rtype == "viewmode" then
            rtype = "string"
        end
        error(("%s: parameter '%s': %s expected, got nil."):format(
            prefix, name, rtype
        ))
    end
end

local function isEmpty(tab)
    for _, _ in pairs(tab) do
        return false
    end
    return true
end

---检查参数名正确性
---@param prefix string
---@param params table
---@param namelist table
function check.name(prefix, params, namelist)
    local invalid = {}
    for k, _ in pairs(params) do
        if not namelist[k] then
            invalid[k] = true
        end
    end
    if isEmpty(invalid) then return end
    error(("%s: invalid parameter: %s"):format(
        prefix, private.keystostring(invalid)
    ))
end

--#endregion
------------------------------------------------------------
--#region 原型方法

---@param self RenderTargetObject
---@return RenderTargetObject self
---@overload fun(self):RenderTargetObject
---@overload fun(self, color:lstg.Color):RenderTargetObject
---@param color1 lstg.Color
---@param color2 lstg.Color
---@param color3 lstg.Color
---@param color4 lstg.Color
function proto:color(color1, color2, color3, color4)
    local rt = self._data.rt
    if color1 and color2 then
        rt[1][6] = color1
        rt[2][6] = color2
        rt[3][6] = color3
        rt[4][6] = color4
    else
        for i = 1, 4 do
            rt[i][6] = color1 or private.white
        end
    end
    return self
end

---@param self RenderTargetObject
---@return RenderTargetObject self
---@param viewmode RTObject.ViewMode
---@param x number
---@param y number
---@param rot number?
---@param hscale number?
---@param vscale number?
function proto:xy(viewmode, x, y, rot, hscale, vscale)
    private.xyz(self, viewmode, true)

    local data = self._data
    data.x, data.y = x, y
    data.rot = rot or 0
    data.hscale = hscale or 1
    data.vscale = vscale or data.hscale

    return self
end

---@param self RenderTargetObject
---@return RenderTargetObject self
---@param viewmode RTObject.ViewMode
---@param left number
---@param right number
---@param bottom number
---@param top number
---@param rot number?
function proto:xyrect(viewmode, left, right, bottom, top, rot)
    if not rot then
        private.xyz(self, viewmode, false,
            left, top, 0.5,
            right, top, 0.5,
            right, bottom, 0.5,
            left, bottom, 0.5)
    else
        local x, y = (left + right) / 2, (bottom + top) / 2
        local dx1, dy1 = private.rotate(left - x, top - y, rot)
        local dx2, dy2 = private.rotate(right - x, top - y, rot)
        private.xyz(
            self, viewmode, false,
            x + dx1, y + dy1, 0.5,
            x + dx2, y + dy2, 0.5,
            x - dx1, y - dy1, 0.5,
            x - dx2, y - dy2, 0.5
        )
    end
    return self
end

---@param self RenderTargetObject
---@return RenderTargetObject self
---@param viewmode RTObject.ViewMode
function proto:xy4v(viewmode, x1, y1, x2, y2, x3, y3, x4, y4)
    private.xyz(
        self, viewmode, false,
        x1, y1, 0.5,
        x2, y2, 0.5,
        x3, y3, 0.5,
        x4, y4, 0.5
    )
    return self
end

---@param self RenderTargetObject
---@return RenderTargetObject self
function proto:xyz(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
    SetXYZ(
        self, "", false,
        x1, y1, z1,
        x2, y2, z2,
        x3, y3, z3,
        x4, y4, z4
    )
    return self
end

---@param self RenderTargetObject
---@return RenderTargetObject self
---@param viewmode RTObject.ViewMode
---@param u number
---@param v number
---@param rot number?
---@param a number
---@param b number?
function proto:uv(viewmode, u, v, rot, a, b)
    rot = rot or 0
    b = b or a

    local du1, dv1 = private.rotate(-a, b, rot)
    local du2, dv2 = private.rotate(a, b, rot)

    proto.uv4v(
        self, viewmode,
        u + du1, v + dv1,
        u + du2, v + dv2,
        u - du1, v - dv1,
        u - du2, v - dv2
    )

    return self
end

---@param self RenderTargetObject
---@return RenderTargetObject self
---@param viewmode DGlib.ViewMode
---@param left number
---@param right number
---@param bottom number
---@param top number
---@param rot number?
function proto:uvrect(viewmode, left, right, bottom, top, rot)
    if rot then
        proto.uv(
            self, viewmode,
            (left + right) / 2, (bottom + top) / 2, rot,
            (right - left) / 2, (top - bottom) / 2
        )
    else
        proto.uv4v(
            self, viewmode,
            left, top,
            right, top,
            right, bottom,
            left, bottom
        )
    end
    return self
end

---@param self RenderTargetObject
---@return RenderTargetObject self
---@param viewmode RTObject.ViewMode
function proto:uv4v(viewmode, u1, v1, u2, v2, u3, v3, u4, v4)
    local data = self._data
    local rt = data.rt
    data.setuv = true

    rt[1][4], rt[1][5] = private.trans(u1, v1, viewmode, "uv")
    rt[2][4], rt[2][5] = private.trans(u2, v2, viewmode, "uv")
    rt[3][4], rt[3][5] = private.trans(u3, v3, viewmode, "uv")
    rt[4][4], rt[4][5] = private.trans(u4, v4, viewmode, "uv")

    return self
end

---@param self RenderTargetObject
---@return RenderTargetObject self
---@param viewmode RTObject.ViewMode
---@param u number
---@param v number
---@overload fun(self):RenderTargetObject
function proto:center(viewmode, u, v)
    local data = self._data

    if not viewmode then
        data.setcenter = false
    else
        data.setcenter = true
        data.u, data.v = private.trans(u, v, viewmode, "uv")
    end
    return self
end

--#endregion
------------------------------------------------------------
--#region 扩展方法

local function makeName(names)
    local list = {}
    for _, name in ipairs(names) do
        list[name] = true
    end
    return list
end

local function makeMode(modes)
    local modelist = {}
    for mode, names in pairs(modes) do
        for _, name in ipairs(names) do
            modelist[name] = mode
        end
    end
    return modelist
end

local namelist = {
    center = makeName {
        "viewmode",
        "x", "u",
        "y", "v",
    },
    xyobj = makeName {
        "viewmode",
        "x", "y", "u", "v", "rot",
        "hscale", "vscale", "scale",
    },
    uvobj = makeName {
        "viewmode",
        "x", "y", "u", "v", "rot", "a", "b",
    },
    rect = makeName {
        "viewmode",
        "left", "right", "top", "bottom",
        "l", "r", "b", "t", "rot",
    },
    vertex = makeName {
        "viewmode",
        "topleft", "lefttop", "tl", "lt", 1,
        "topright", "righttop", "tr", "rt", 2,
        "bottomright", "rightbottom", "br", "rb", 3,
        "bottomleft", "leftbottom", "bl", "lb", 4,
    },
}

local modelist = makeMode {
    ["object"] = { "x", "y", "u", "v", "a", "hscale", "vscale", "scale" },
    ["rect"] = { "left", "right", "bottom", "top", "l", "r", "t" },
    ["4v"] = { 1, 2, 3, 4, "lefttop", "topleft", "righttop", "topright", "leftbottom", "bottomleft", "rightbottom", "bottomright", "lt", "tl", "rt", "tr", "lb", "bl", "rb", "br" }
}

local function isDiscard(params)
    for _, _ in pairs(params) do
        return false
    end
    return true
end

---@param params table
---@return "unknown"|"object"|"rect"|"4v"
local function searchMode(params)
    for name, _ in pairs(params) do
        if modelist[name] then return modelist[name] end
    end
    return "unknown"
end

---设置顶点颜色 (扩展)
---@param params table
---@param self RenderTargetObject
---@return RenderTargetObject self
function extend:color(params)
    check.name("rtobject:color()", params, namelist.vertex)
    return proto.color(self,
        check.assert("rtobject:color()", "color", true,
            "topleft", params.topleft,
            "lefttop", params.lefttop,
            "tl", params.tl,
            "lt", params.lt,
            "[1]", params[1]
        ) or private.white,
        check.assert("rtobject:color()", "color", true,
            "topright", params.topright,
            "righttop", params.righttop,
            "tr", params.tr,
            "rt", params.rt,
            "[2]", params[2]
        ) or private.white,
        check.assert("rtobject:color()", "color", true,
            "bottomright", params.bottomright,
            "rightbottom", params.rightbottom,
            "br", params.br,
            "rb", params.rb,
            "[3]", params[3]
        ) or private.white,
        check.assert("rtobject:color()", "color", true,
            "bottomleft", params.bottomleft,
            "leftbottom", params.leftbottom,
            "bl", params.bl,
            "lb", params.lb,
            "[4]", params[4]
        ) or private.white
    )
end

---@param self RenderTargetObject
---@return RenderTargetObject self
---@param viewmode RTObject.ViewMode
---@param p1 number[]
---@param p2 number[]
---@param p3 number[]
---@param p4 number[]
local function extend_set_xyz(self, viewmode, p1, p2, p3, p4)
    return private.xyz(self, viewmode, false,
        p1[1], p1[2], p1[3] or 0.5,
        p2[1], p2[2], p2[3] or 0.5,
        p3[1], p3[2], p3[3] or 0.5,
        p4[1], p4[2], p4[3] or 0.5
    )
end

---设置顶点渲染坐标 (x,y) (扩展)
---@param params table
---@param self RenderTargetObject
---@return RenderTargetObject self
function extend:xy(params)
    if isDiscard(params) then return self:xydiscard() end
    local mode = searchMode(params)

    if mode == "object" then
        check.name("rtobject:xy()", params, namelist.xyobj)
        return proto.xy(self,
            check.assert("rtobject:xy()", "viewmode", true,
                "viewmode", params.viewmode
            ) or "",
            check.assert("rtobject:xy()", "number", false,
                "x", params.x,
                "u", params.u
            ),
            check.assert("rtobject:xy()", "number", false,
                "y", params.y,
                "v", params.v
            ),
            check.assert("rtobject:xy()", "number", true,
                "rot", params.rot
            ),
            check.assert("rtobject:xy()", "number", true,
                "hscale", params.hscale,
                "scale", params.scale
            ) or 1,
            check.assert("rtobject:xy()", "number", true,
                "vscale", params.vscale,
                "scale", params.scale
            ) or 1
        )
    elseif mode == "rect" then
        check.name("rtobject:xy()", params, namelist.rect)
        return proto.xyrect(self,
            check.assert("rtobject:xy()", "viewmode", true,
                "viewmode", params.viewmode
            ) or "",
            check.assert("rtobject:xy()", "number", false,
                "left", params.left,
                "l", params.l
            ),
            check.assert("rtobject:xy()", "number", false,
                "right", params.right,
                "r", params.r
            ),
            check.assert("rtobject:xy()", "number", false,
                "bottom", params.bottom,
                "b", params.b
            ),
            check.assert("rtobject:xy()", "number", false,
                "top", params.top,
                "t", params.t
            ),
            check.assert("rtobject:xy()", "number", true,
                "rot", params.rot
            )
        )
    elseif mode == "4v" then
        check.name("rtobject:xy()", params, namelist.vertex)
        return extend_set_xyz(self,
            check.assert("rtobject:xy()", "viewmode", true,
                "viewmode", params.viewmode
            ) or "",
            check.assert("rtobject:xy()", "table", false,
                "topleft", params.topleft,
                "lefttop", params.lefttop,
                "tl", params.tl,
                "lt", params.lt,
                "[1]", params[1]
            ),
            check.assert("rtobject:xy()", "table", false,
                "topright", params.topright,
                "righttop", params.righttop,
                "tr", params.tr,
                "rt", params.rt,
                "[2]", params[2]
            ),
            check.assert("rtobject:xy()", "table", false,
                "bottomright", params.bottomright,
                "rightbottom", params.rightbottom,
                "br", params.br,
                "rb", params.rb,
                "[3]", params[3]
            ),
            check.assert("rtobject:xy()", "table", false,
                "bottomleft", params.bottomleft,
                "leftbottom", params.leftbottom,
                "bl", params.bl,
                "lb", params.lb,
                "[4]", params[4]
            )
        )
    else
        error(("%s: invalid parameter list: %s"):format(
            "rtobject:xy()", private.keystostring(params)
        ))
    end
end

---@param self RenderTargetObject
---@return RenderTargetObject self
---@param viewmode RTObject.ViewMode
---@param p1 number[]
---@param p2 number[]
---@param p3 number[]
---@param p4 number[]
local function extend_set_uv(self, viewmode, p1, p2, p3, p4)
    return proto.uv4v(self, viewmode,
        p1[1], p1[2],
        p2[1], p2[2],
        p3[1], p3[2],
        p4[1], p4[2]
    )
end

---设置顶点纹理坐标 (u,v) (扩展)
---@param params table
---@param self RenderTargetObject
---@return RenderTargetObject self
function extend:uv(params)
    if isDiscard(params) then return self:uvdiscard() end

    local mode = searchMode(params)

    if mode == "object" then
        check.name("rtobject:uv()", params, namelist.uvobj)
        return proto.uv(self,
            check.assert("rtobject:uv()", "viewmode", true,
                "viewmode", params.viewmode
            ) or "",
            check.assert("rtobject:uv()", "number", false,
                "u", params.u,
                "x", params.x
            ),
            check.assert("rtobject:uv()", "number", false,
                "v", params.v,
                "y", params.y
            ),
            check.assert("rtobject:uv()", "number", true,
                "rot", params.rot
            ),
            check.assert("rtobject:uv()", "number", true,
                "a", params.a
            ),
            check.assert("rtobject:uv()", "number", true,
                "b", params.b
            )
        )
    elseif mode == "rect" then
        check.name("rtobject:uv()", params, namelist.rect)
        return proto.uvrect(self,
            check.assert("rtobject:uv()", "viewmode", true,
                "viewmode", params.viewmode
            ) or "",
            check.assert("rtobject:uv()", "number", false,
                "left", params.left,
                "l", params.l
            ),
            check.assert("rtobject:uv()", "number", false,
                "right", params.right,
                "r", params.r
            ),
            check.assert("rtobject:uv()", "number", false,
                "bottom", params.bottom,
                "b", params.b
            ),
            check.assert("rtobject:uv()", "number", false,
                "top", params.top,
                "t", params.t
            ),
            check.assert("rtobject:uv()", "number", true,
                "rot", params.rot
            )
        )
    elseif mode == "4v" then
        check.name("rtobject:uv()", params, namelist.vertex)
        return extend_set_uv(self,
            check.assert("rtobject:uv()", "viewmode", true,
                "viewmode", params.viewmode
            ) or "",
            check.assert("rtobject:uv()", "table", false,
                "topleft", params.topleft,
                "lefttop", params.lefttop,
                "tl", params.tl,
                "lt", params.lt,
                "[1]", params[1]
            ),
            check.assert("rtobject:uv()", "table", false,
                "topright", params.topright,
                "righttop", params.righttop,
                "tr", params.tr,
                "rt", params.rt,
                "[2]", params[2]
            ),
            check.assert("rtobject:uv()", "table", false,
                "bottomright", params.bottomright,
                "rightbottom", params.rightbottom,
                "br", params.br,
                "rb", params.rb,
                "[3]", params[3]
            ),
            check.assert("rtobject:uv()", "table", false,
                "bottomleft", params.bottomleft,
                "leftbottom", params.leftbottom,
                "bl", params.bl,
                "lb", params.lb,
                "[4]", params[4]
            )
        )
    else
        error(("%s: invalid parameter list: %s"):format(
            "rtobject:uv()", private.keystostring(params)
        ))
    end
end

---设置纹理中心点 (扩展)
---@param params table
---@param self RenderTargetObject
---@return RenderTargetObject self
function extend:center(params)
    if isDiscard(params) then return proto.center(self) end
    check.name("rtobject:center()", params, namelist.center)

    return proto.center(self,
        check.assert("rtobject:center()", "viewmode", true,
            "viewmode", params.viewmode
        ) or "",
        check.assert("rtobject:center()", "number", false,
            "u", params.u,
            "x", params.x
        ),
        check.assert("rtobject:center()", "number", false,
            "v", params.v,
            "y", params.y
        )
    )
end

--#endregion
