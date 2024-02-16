-- 元表
local vector = {}

local function NewVector(x, y, z, w)
    if type(x) ~= "table" or getmetatable(x) then
        -- 各元素
        return setmetatable({
            x or 0, y or 0, z or 0, w or 0
        }, vector)
    end
    if not y then
        -- 数组或其他向量
        return setmetatable({
            x[1] or 0, x[2] or 0, x[3] or 0, x[4] or 0
        }, vector)
    end
    -- 旋转轴和角度
    local c, s = cos(y / 2), sin(y / 2)
    x, y, z = x[1] or 0, x[2] or 0, x[3] or 0
    local dist = math.sqrt(x * x + y * y + z * z)
    return setmetatable({
        x / dist * s,
        y / dist * s,
        z / dist * s,
        c
    }, vector)
end
DG.Vector = NewVector

local function ToString(self)
    return tostring(self[1]) .. '\t'
        .. tostring(self[2]) .. '\t'
        .. tostring(self[3]) .. '\t'
        .. tostring(self[4]) .. '\t'
end
vector.__tostring = ToString

function vector:print()
    print(self)
end

local function LengthSquare(self)
    return self[1] * self[1]
        + self[2] * self[2]
        + self[3] * self[3]
        + self[4] * self[4]
end

local function Unit(self)
    local dist = self.length
    if dist == 0 then
        error("divided by zero!")
    end

    if self[4] < -1e-7 then
        dist = -dist
    end
    return self * (1 / dist)
end

local function Index(self, key)
    if rawget(vector, key) then
        return vector[key]
    elseif key == 'x' then
        return self[1]
    elseif key == 'y' then
        return self[2]
    elseif key == 'z' then
        return self[3]
    elseif key == 'w' then
        return self[4]
    elseif key == 'length' then
        return math.sqrt(LengthSquare(self))
    elseif key == 'unit' then
        return Unit(self)
    elseif key == 'T' then
        return setmetatable({
            -self[1], -self[2], -self[3], self[4]
        }, vector)
    elseif key == 'lensqr' then
        return LengthSquare(self)
    else
        error("invalid index key: " .. tostring(key))
    end
end
vector.__index = Index

local function NewIndex(self)
    error("DGlib.Vector is immutable!")
end
vector.__newindex = NewIndex

local function Unm(v)
    return setmetatable({
        -v[1], -v[2], -v[3], -v[4]
    }, vector)
end
vector.__unm = Unm
vector.unm = Unm

local function Add(u, v)
    return setmetatable({
        u[1] + v[1],
        u[2] + v[2],
        u[3] + v[3],
        u[4] + v[4],
    }, vector)
end
vector.__add = Add
vector.add = Add

local function Sub(u, v)
    return setmetatable({
        u[1] - v[1],
        u[2] - v[2],
        u[3] - v[3],
        u[4] - v[4],
    }, vector)
end
vector.__sub = Sub
vector.sub = Sub

local function MulNum(v, k)
    return setmetatable({
        v[1] * k,
        v[2] * k,
        v[3] * k,
        v[4] * k,
    }, vector)
end
vector.Mul = MulNum

local function QuatMul(u, v)
    return setmetatable({
        u[1] * v[4] + u[4] * v[1] + u[2] * v[3] - u[3] * v[2],
        u[2] * v[4] + u[4] * v[2] + u[3] * v[1] - u[1] * v[3],
        u[3] * v[4] + u[4] * v[3] + u[1] * v[2] - u[2] * v[1],
        u[4] * v[4] - u[1] * v[1] - u[2] * v[2] - u[3] * v[3],
    }, vector)
end

local function Mul(a, b)
    if type(a) == "number" then
        return MulNum(b, a)
    elseif type(b) == "number" then
        return MulNum(a, b)
    else
        return QuatMul(a, b)
    end
end
vector.__mul = Mul

local function DotMul(u, v)
    return u[1] * v[1]
        + u[2] * v[2]
        + u[3] * v[3]
        + u[4] * v[4]
end
vector.__pow = DotMul
vector.dot = DotMul

local function CrossMul2D(u, v)
    return u[1] * v[2] - u[2] * v[1]
end
vector.__div = CrossMul2D
vector.cross2d = CrossMul2D

local function CrossMul3D(u, v)
    return setmetatable({
        u[2] * v[3] - u[3] * v[2],
        u[3] * v[1] - u[1] * v[3],
        u[1] * v[2] - u[2] * v[1],
        0
    }, vector)
end
vector.__mod = CrossMul3D
vector.cross3d = CrossMul3D

local function rotate2d(self, a)
    return NewVector(
        self[1] * cos(a) - self[2] * sin(a),
        self[1] * sin(a) + self[2] * cos(a),
        self[3], self[4]
    )
end

function vector:rotate(axis, angle)
    if type(axis) == "number" then
        return rotate2d(self, axis)
    end
    if angle then
        axis = NewVector(axis, angle)
    end
    return axis * self * axis.T
end

local matrix = {}

local function NewBase(e1, e2, e3)
    if not e1 then
        return setmetatable({
            NewVector(1),
            NewVector(0, 1),
            NewVector(0, 0, 1)
        }, matrix)
    end
    return setmetatable({ e1, e2, e3 }, matrix)
end

local function MatAdd(A, B)
    return NewBase(
        A[1] + B[1],
        A[2] + B[2],
        A[3] + B[3]
    )
end
matrix.__add = MatAdd

local function CrossMat(v)
    return NewBase(
        NewVector(0, v[3], -v[2]),
        NewVector(-v[3], 0, v[1]),
        NewVector(v[2], -v[1], 0)
    )
end

local function MatMul(k, A)
    return NewBase(
        k * A[1],
        k * A[2],
        k * A[3]
    )
end
matrix.__mul = MatMul

local function MatSqr(A)
    local B = NewBase(
        NewVector(), NewVector(), NewVector()
    )
    for i = 1, 3 do
        for j = 1, 3 do
            local x = 0
            for k = 1, 3 do
                x = x + A[i][k] * A[k][j]
            end
            B[i][j] = x
        end
    end
    return B
end
matrix.__pow = MatSqr

function matrix:__tostring()
    return table.concat({
        table.concat(self[1], '\t', 1, 3),
        table.concat(self[2], '\t', 1, 3),
        table.concat(self[3], '\t', 1, 3),
    }, '\n')
end

DG.Convert = {}

local function QuatToBase(quat)
    local K = CrossMat(quat)
    return NewBase() + 2 * quat.w * K + 2 * K ^ 2
end
DG.Convert.QuatToBase = QuatToBase

local function BaseToQuat(base)
    local w = math.sqrt(base[1][1] + base[2][2] + base[3][3] + 1) / 2
    local x = (base[2][3] - base[3][2]) / (4 * w)
    local y = (base[3][1] - base[1][3]) / (4 * w)
    local z = (base[1][2] - base[2][1]) / (4 * w)
    return NewVector(x, y, z, w)
end
DG.Convert.BaseToQuat = BaseToQuat
